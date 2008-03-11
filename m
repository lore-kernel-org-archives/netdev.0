From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Treason uncloaked spams syslog with latest git
Date: Tue, 11 Mar 2008 12:20:53 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0803111138360.5423@kivilampi-30.cs.helsinki.fi>
References: <alpine.LFD.1.00.0803061140380.3099@apollo.tec.linutronix.de>
 <20080306153129.e247cd1a.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0803071547370.5423@kivilampi-30.cs.helsinki.fi>
 <alpine.LFD.1.00.0803072050410.3099@apollo.tec.linutronix.de>
 <alpine.LFD.1.00.0803102046420.3781@apollo.tec.linutronix.de>
Mime-Version: 1.0
Content-Type: MULTIPART/Mixed; boundary="8323328-569145175-1205178487=:3781"
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757418AbYCKKVZ@vger.kernel.org>
In-Reply-To: <alpine.LFD.1.00.0803102046420.3781@apollo.tec.linutronix.de>
Content-ID: <Pine.LNX.4.64.0803111138361.5423@kivilampi-30.cs.helsinki.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-569145175-1205178487=:3781
Content-Type: TEXT/PLAIN; charset=iso-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0803111138362.5423@kivilampi-30.cs.helsinki.fi>

On Mon, 10 Mar 2008, Thomas Gleixner wrote:

> On Fri, 7 Mar 2008, Thomas Gleixner wrote:
> > On Fri, 7 Mar 2008, Ilpo Järvinen wrote:
> > > On Thu, 6 Mar 2008, Andrew Morton wrote:
> > > 
> > > > On Thu, 6 Mar 2008 11:47:12 +0100 (CET)
> > > > Thomas Gleixner <tglx@linutronix.de> wrote:
> > > > 
> > > > > Since I updated one of my compile boxen to latest git I get the syslog
> > > > > flooded with:
> > > > > 
> > > > > TCP: Treason uncloaked! Peer 192.168.0.1:10245/56637 shrinks window
> > > > > 2748077551:2748080447. Repaired.
> > > > > TCP: Treason uncloaked! Peer 192.168.0.68:10245/39915 shrinks window
> > > > > 2890195332:2890201124. Repaired.
> > > > > TCP: Treason uncloaked! Peer 192.168.0.65:10245/46058 shrinks window
> > > > > 2880740873:2880745217. Repaired.
> > > > > 
> > > > > This happens _always_ when I compile kernels with distcc or icecc. All
> > > > > systems involved run Linux with kernels >= 2.6.23 and are on the same
> > > > > network; no routers, firewalls or other fancy stuff.
> > > > > 
> > > > > Any idea what's going on here ?
> > > > > 
> > > 
> > > Could you tcpdump it?
> > 
> > Will do.
> 
> http://www.tglx.de/~tglx/treason.cap
> 
> That's on -rc5

Thanks, I think I found the reason. Does the patch below fix it...

-- 
 i.

--
[PATCH net-2.6] [TCP]: Prevent sending past receiver window with TSO (at last skb)

With TSO it was possible to send past the receiver window when
the skb to be sent was the last in the write queue while the
receiver window is the limiting factor. One can notice that
there's a loophole in the tcp_mss_split_point that lacked
a receiver window check for the tcp_write_queue_tail() if also
cwnd was smaller than the full skb.

Noticed by Thomas Gleixner <tglx@linutronix.de> in form of
"Treason uncloaked! Peer ... shrinks window .... Repaired."
messages (the peer didn't actually shrink its window as the
message suggests, we had just sent something past it without
a permission to do so).

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index cbfef8b..67f84f5 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1035,6 +1035,13 @@ static void tcp_cwnd_validate(struct sock *sk)
  * introducing MSS oddities to segment boundaries. In rare cases where
  * mss_now != mss_cache, we will request caller to create a small skb
  * per input skb which could be mostly avoided here (if desired).
+ *
+ * We explicitly want to create a request for splitting write queue tail
+ * to a small skb for Nagle purposes while avoiding unnecessary modulos,
+ * thus all the complexity (cwnd_len is always MSS multiple which we
+ * return whenever allowed by the other factors). Basically we need the
+ * modulo only when the receiver window alone is the limiting factor or
+ * when we would be allowed to send the split-due-to-Nagle skb fully.
  */
 static unsigned int tcp_mss_split_point(struct sock *sk, struct sk_buff *skb,
 					unsigned int mss_now, unsigned int cwnd)
@@ -1048,10 +1055,11 @@ static unsigned int tcp_mss_split_point(struct sock *sk, struct sk_buff *skb,
 	if (likely(cwnd_len <= window && skb != tcp_write_queue_tail(sk)))
 		return cwnd_len;
 
-	if (skb == tcp_write_queue_tail(sk) && cwnd_len <= skb->len)
+	needed = min(skb->len, window);
+
+	if (skb == tcp_write_queue_tail(sk) && cwnd_len <= needed)
 		return cwnd_len;
 
-	needed = min(skb->len, window);
 	return needed - needed % mss_now;
 }
 
-- 
1.5.2.2

--8323328-569145175-1205178487=:3781--
