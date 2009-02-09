From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: commit 64ff3b938ec6782e6585a83d5459b98b0c3f6eb8 breaks rlogin
Date: Mon, 9 Feb 2009 09:13:00 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0902090853360.20576@wrl-59.cs.helsinki.fi>
References: <20090206054541.GA4954@gondor.apana.org.au>
 <b6a2187b0902060335h646e8d86pf00773035f577665@mail.gmail.com>
 <20090209055848.GA3889@gondor.apana.org.au> <20090208.220357.261414983.davem@davemloft.net>
 <20090209061151.GA3982@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1817757509-1234163580=:20576"
Cc: David Miller <davem@davemloft.net>, jeff.chua.linux@gmail.com,
	rjw@sisk.pl, torvalds@linux-foundation.org,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:57437 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753689AbZBIHNE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 02:13:04 -0500
In-Reply-To: <20090209061151.GA3982@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1817757509-1234163580=:20576
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Mon, 9 Feb 2009, Herbert Xu wrote:

> On Sun, Feb 08, 2009 at 10:03:57PM -0800, David Miller wrote:
> > 
> > I would expect to see the URG packets from rlogin not rlogind, from
> > things like hitting Ctrl-C etc.
> 
> That's what I thought too, however, the strace says otherwise:
> 
> connect(3, {sa_family=AF_INET, sin_port=htons(513), sin_addr=inet_addr("192.168.243.118")}, 16) = 0
> write(3, "\0", 1)                       = 1
> writev(3, [{"root\0", 5}, {"root\0", 5}, {"xterm/38400\0", 12}], 3) = 22
> read(3, "\0", 1)                        = 1
> rt_sigprocmask(SIG_SETMASK, [USR1 URG], [USR1 URG], 8) = 0
> setsockopt(3, SOL_IP, IP_TOS, [16], 4)  = 0
> setuid32(0)                             = 0
> ioctl(0, SNDCTL_TMR_TIMEBASE or TCGETS, {B38400 opost isig icanon echo ...}) = 0
> rt_sigaction(SIGINT, {SIG_IGN}, {SIG_DFL}, 8) = 0
> rt_sigprocmask(SIG_BLOCK, [HUP], [USR1 URG], 8) = 0
> rt_sigaction(SIGHUP, {0x8048bdc, [HUP], SA_RESTART}, {SIG_IGN}, 8) = 0
> rt_sigaction(SIGHUP, {SIG_IGN}, {0x8048bdc, [HUP], SA_RESTART}, 8) = 0
> rt_sigprocmask(SIG_SETMASK, [USR1 URG], [HUP USR1 URG], 8) = 0
> rt_sigprocmask(SIG_BLOCK, [QUIT], [USR1 URG], 8) = 0
> rt_sigaction(SIGQUIT, {0x8048bdc, [QUIT], SA_RESTART}, {SIG_DFL}, 8) = 0
> rt_sigprocmask(SIG_SETMASK, [USR1 URG], [QUIT USR1 URG], 8) = 0
> rt_sigaction(SIGCHLD, {0x8049f20, [CHLD], SA_RESTART}, {SIG_DFL}, 8) = 0
> clone(child_stack=0, flags=CLONE_CHILD_CLEARTID|CLONE_CHILD_SETTID|SIGCHLD, child_tidptr=0xb7d81918) = 6433
> rt_sigaction(SIGURG, {0x80491d0, [URG], SA_RESTART}, {SIG_DFL}, 8) = 0
> rt_sigaction(SIGUSR1, {0x8048de0, [USR1], SA_RESTART}, {SIG_DFL}, 8) = 0
> rt_sigprocmask(SIG_SETMASK, [], [USR1 URG], 8) = 0
> --- SIGURG (Urgent I/O condition) @ 0 (0) ---
> kill(6433, SIGURG)                      = 0
> 
> FD 3 is the TCP socket.  As you can see, the only operations done
> were write/writev/read/setsockopt.  None of these can enter urgent
> mode for sending, so that's how I concluded that my patch should
> have zero effect on this side.
> 
> Note also that we got an SIGURG, which indicates that we received
> urgent data.

Hmm, what happens if a opposite dir ACK gets sent (it's zero sized seqno 
range will be above urgent sequence when urg is not yet acknowledged)? So 
we'll take the later branch after your change and send bogus 0xffff urg?
I think you're change might have actually broken bidir tcp completely (and 
probably window probing as well under some conditions). Congraz, two flies 
with a single stroke :-). You would have needed an additional check that 
the tcb->seq is below urg...

...Below is a patch but Jeff might need to revert the revert first if
he tests with the latest Linus' tree.


-- 
 i.

[PATCH] tcp: check that we're still < urg instead of sending a bogus one

Opposite dir ACK with zero sized seqno range can go into the
later condition once urg is in the outstanding window not
yet acknowledge (we're still in urg mode but seqno we sent in
the ack won't be below snd_up). Need to check that we never
advertize bogus urg for a segment which is after the snd_up.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 557fe16..c808d73 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -667,7 +667,8 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 		if (between(tp->snd_up, tcb->seq + 1, tcb->seq + 0xFFFF)) {
 			th->urg_ptr = htons(tp->snd_up - tcb->seq);
 			th->urg = 1;
-		} else if (after(tcb->seq + 0xFFFF, tp->snd_nxt)) {
+		} else if (after(tcb->seq + 0xFFFF, tp->snd_nxt) &&
+			   before(tcb->seq, tcp->snd_up)) {
 			th->urg_ptr = 0xFFFF;
 			th->urg = 1;
 		}
-- 
1.5.6.5

---696208474-1817757509-1234163580=:20576--
