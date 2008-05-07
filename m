From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Fix FRTO+NewReno problem (Was: Re: This has a work around)
Date: Thu, 8 May 2008 01:26:59 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805072357240.23091@wrl-59.cs.helsinki.fi>
References: <48207F06.50306@damtek.com> <Pine.LNX.4.64.0805061912350.8965@wrl-59.cs.helsinki.fi>
 <4821C37A.7040306@damtek.com>
Mime-Version: 1.0
Content-Type: MULTIPART/Mixed; boundary="=_courier-30903-1210172285-0001-2"
Cc: Bug 213081 <213081@bugs.launchpad.net>, 478062@bugs.debian.org,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: "Damon L. Chesser" <damon@damtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:40312 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933120AbYEGW1G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 18:27:06 -0400
In-Reply-To: <4821C37A.7040306@damtek.com>
Content-ID: <Pine.LNX.4.64.0805072357241.23091@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--=_courier-30903-1210172285-0001-2
Content-Type: TEXT/PLAIN; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0805072357242.23091@wrl-59.cs.helsinki.fi>

Added Cc netdev (=linux network developers list).

On Wed, 7 May 2008, Damon L. Chesser wrote:

> Ilpo Järvinen wrote:
> >
> > So the problem was 100% reproducable for you with FRTO (I'm still catching
> > up the details here :-))?
> >   
> 
> Yes, 100% reproducible if you turn FRTO = 2.  Printing works as it is 
> supposed to if FRTO = 0
>
> > I suspect there's some corner case which might be buggy in kernel, but there
> > are other possibilities currently as well. I'd like to get this fixed if
> > it's a kernel bug, and think about work-arounds if it seems to be elsewhere
> > (end-point or middlebox). It might be that those devices just blantantly
> > discard any out-of-order segments, it could explain this kind of phenomena,
> > but we'll soon see what's doing
> 
> I also suspect a corner case.  I suspect the hardware used has a "narrow
> window" in which to allow the network traffic and the *new* kernels for some
> reason are outside this window.  However, just because FC8, Ubuntu 8.04 and
> Debian all see the same thing does not rule out an issue with cupsys.

No we're not sending past the window this time, that bug got resolved 
before 2.6.25 got released (and it wasn't in 2.6.24 at all)... :-)

There were couple of interesting aspect in the tcpdump log: 

- The printer is using advertized window of 1024 whole the time => mss is 
set to 512 to allow two segments per rtt, we won't get a larger window at 
all.
- The printer wasn't exactly blantantly discarding all received 
out-of-order segments, it correctly sent dupacks (most of the time), 
though the rate it's able to receive segments seems quite low, thus
there were some losses as well (and therefore "missing" dupACKs too).
- FRTOs occur during a previous recovery.

After some code reading, I found the causing bug in the kernel:
The printer won't negotiate SACK, yet F-RTO is using in couple of places
a condition which lacks check for this making F-RTO to select wrongly
SACK enabled behavior. ...There are two bugs actually with the same 
sympthoms, one for non-SACK case and the other for SACK-enabled case.
...The fix below is for non-SACK case.

> > I suppose you're willing to test some kernel patch as well if that becomes
> > necessary?
> 
> Yup.  I found it.  I *own* it.  This impacts a very small amount of people as
> evidenced by the resounding silence of complaints about it (which is shy I
> think the hardware has a "small window" to accept packets)  I will have to
> dust off my kernel patching skills, been a long long time since I had to patch
> a kernel.
>
> Interesting:  I have stopped the cups print job, I have reset the printer,
> powered off the printerserver device, and re-seated the network cable
> (required to clear the stuck tcp packets so that the other packets can get to
> the printer), I have stopped cupsysd and netstat still shows an tcp connection
> with 192.168.200.150 (printer).  I include this info as this might be needed
> by you.  I suspect that that is not *normal* behavior, but I have never ran
> netstat --tcp -c on a print job that failed, so I don't know:

This is expected, once you had make the printer unreachabled, TCP will try 
a number of retransmissions without getting any response from printer 
before giving up, it would have just taken even longer time to get it 
cleaned up. The printer on the other hand will lose TCP states when you 
resetted it and therefore it's able to receive more stuff right away.

> Ran the tcpdump for a solid 20 minutes, attached.

Thanks, tcpdump was helpful.

> Let me know if you need anything else.

Could you next try with tcp_frto set to 1, if my theory proves to be 
correct, it too should be "enough" to fix the problem (in this 
particular case). Of course you can verify the patch below too if you want 
to, the patch should allow cups<->printer to work with tcp_frto = 2 too. 
In case you have problem to apply the patch to the particular version 
you're want to try with, just send a note about the version number to me 
so I can adapt the patch for you (space etc. formatting issues may show up 
because I recently run a code style cleanup on the tcp code).

-- 
 i.


--
[PATCH] [TCP] FRTO: SACK variant is errorneously used with NewReno

Note: there's actually another bug in FRTO's SACK variant, which
is the causing failure in NewReno case because of the error
that's fixed here. I'll fix the SACK case separately (it's
a separate bug really, though related, but in order to fix that
I need to audit tp->snd_nxt usage a bit).

There were two places where SACK variant of FRTO is getting
incorrectly used even if SACK wasn't negotiated by the TCP flow.
This leads to incorrect setting of frto_highmark with NewReno
if a previous recovery was interrupted by another RTO.

An eventual fallback to conventional recovery then incorrectly
considers one or couple of segments as forward transmissions
though they weren't, which then are not LOST marked during
fallback making them "non-retransmittable" until the next RTO.
In a bad case, those segments are really lost and are the only
one left in the window. Thus TCP needs another RTO to continue.
The next FRTO, however, could again repeat the same events
making the progress of the TCP flow extremely slow.

In order for these events to occur at all, FRTO must occur
again in FRTOs step 3 while the key segments must be lost as
well, which is not too likely in practice. It seems to most
frequently with some small devices such as network printers
that *seem* to accept TCP segments only in-order. In cases
were key segments weren't lost, things get automatically
resolved because those wrongly marked segments don't need to be
retransmitted in order to continue.

I found a reproducer after digging up relevant reports (few
reports in total, none at netdev or lkml I know of), some
cases seemed to indicate middlebox issues which seems now
to be a false assumption some people had made. Bugzilla
#10063 _might_ be related. Damon L. Chesser <damon@damtek.com>
had a reproducable case and was kind enough to tcpdump it
for me. With the tcpdump log it was quite trivial to figure
out.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 0298f80..5c503e0 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -113,8 +113,6 @@ int sysctl_tcp_abc __read_mostly;
 #define FLAG_FORWARD_PROGRESS	(FLAG_ACKED|FLAG_DATA_SACKED)
 #define FLAG_ANY_PROGRESS	(FLAG_FORWARD_PROGRESS|FLAG_SND_UNA_ADVANCED)
 
-#define IsSackFrto() (sysctl_tcp_frto == 0x2)
-
 #define TCP_REMNANT (TCP_FLAG_FIN|TCP_FLAG_URG|TCP_FLAG_SYN|TCP_FLAG_PSH)
 #define TCP_HP_BITS (~(TCP_RESERVED_BITS|TCP_FLAG_PSH))
 
@@ -1685,6 +1683,10 @@ static inline void tcp_reset_reno_sack(struct tcp_sock *tp)
 	tp->sacked_out = 0;
 }
 
+static int tcp_is_sackfrto(const struct tcp_sock *tp) {
+	return (sysctl_tcp_frto == 0x2) && !tcp_is_reno(tp);
+}
+
 /* F-RTO can only be used if TCP has never retransmitted anything other than
  * head (SACK enhanced variant from Appendix B of RFC4138 is more robust here)
  */
@@ -1701,7 +1703,7 @@ int tcp_use_frto(struct sock *sk)
 	if (icsk->icsk_mtup.probe_size)
 		return 0;
 
-	if (IsSackFrto())
+	if (tcp_is_sackfrto(tp))
 		return 1;
 
 	/* Avoid expensive walking of rexmit queue if possible */
@@ -1791,7 +1793,7 @@ void tcp_enter_frto(struct sock *sk)
 	/* Earlier loss recovery underway (see RFC4138; Appendix B).
 	 * The last condition is necessary at least in tp->frto_counter case.
 	 */
-	if (IsSackFrto() && (tp->frto_counter ||
+	if (tcp_is_sackfrto(tp) && (tp->frto_counter ||
 	    ((1 << icsk->icsk_ca_state) & (TCPF_CA_Recovery|TCPF_CA_Loss))) &&
 	    after(tp->high_seq, tp->snd_una)) {
 		tp->frto_highmark = tp->high_seq;
@@ -3123,7 +3125,7 @@ static int tcp_process_frto(struct sock *sk, int flag)
 		return 1;
 	}
 
-	if (!IsSackFrto() || tcp_is_reno(tp)) {
+	if (!tcp_is_sackfrto(tp)) {
 		/* RFC4138 shortcoming in step 2; should also have case c):
 		 * ACK isn't duplicate nor advances window, e.g., opposite dir
 		 * data, winupdate
-- 
1.5.2.2

--=_courier-30903-1210172285-0001-2--
