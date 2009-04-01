From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: WARNING: at net/ipv4/tcp_input.c:2927 tcp_ack+0xd55/0x1991()
Date: Wed, 1 Apr 2009 14:09:11 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0904011352470.30150@wrl-59.cs.helsinki.fi>
References: <20090327211202.GA10014@gentoox2.trippelsdorf.de>
 <Pine.LNX.4.64.0903280031080.5904@wrl-59.cs.helsinki.fi>
 <20090328045056.GA2394@gentoox2.trippelsdorf.de>
 <Pine.LNX.4.64.0903280930440.6696@wrl-59.cs.helsinki.fi>
 <20090328095514.GA2599@gentoox2.trippelsdorf.de>
 <Pine.LNX.4.64.0903301155150.30150@wrl-59.cs.helsinki.fi>
 <20090330164035.GA2652@gentoox2.trippelsdorf.de>
 <Pine.LNX.4.64.0903302137100.29272@wrl-59.cs.helsinki.fi>
 <20090331071018.GA2641@gentoox2.trippelsdorf.de>
 <Pine.LNX.4.64.0903311205070.30150@wrl-59.cs.helsinki.fi>
 <20090331184959.GA2725@gentoox2.trippelsdorf.de>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1341630150-1238584151=:30150"
Cc: Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Markus Trippelsdorf <markus@trippelsdorf.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762531AbZDALJt@vger.kernel.org>
In-Reply-To: <20090331184959.GA2725@gentoox2.trippelsdorf.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1341630150-1238584151=:30150
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Tue, 31 Mar 2009, Markus Trippelsdorf wrote:

> On Tue, Mar 31, 2009 at 12:16:51PM +0300, Ilpo Järvinen wrote:
> > On Tue, 31 Mar 2009, Markus Trippelsdorf wrote:
> > 
> > > On Mon, Mar 30, 2009 at 09:52:55PM +0300, Ilpo Järvinen wrote:
> > > > On Mon, 30 Mar 2009, Markus Trippelsdorf wrote:
> > > > 
> > > > > On Mon, Mar 30, 2009 at 07:01:22PM +0300, Ilpo Järvinen wrote:
> > > > > > On Sat, 28 Mar 2009, Markus Trippelsdorf wrote:
> > > > > > > On Sat, Mar 28, 2009 at 10:29:58AM +0200, Ilpo Järvinen wrote:
> > > > > > 
> > > > > > ...And, let me guess, you're in X and therefore unable to catch a final 
> > > > > > oops if any would be printed? It would be nice to get around that as well, 
> > > > > > either use serial/netconsole or hang in text mode while waiting for the 
> > > > > > crash (should be too hard if you are able to setup the workload first 
> > > > > > and then switch away from X and if reproducing takes about an hour)...
> > > > > 
> > > > > OK, I will try this later.
> > > > 
> > > > Lets hope that gives some clue where it ends up going boom (if it is 
> > > > caused by TCP we certainly should see something more sensible in console 
> > > > than just a hang)... ...I once again read through tcp commits but just 
> > > > cannot find anything that could cause fackets_out miscount, not to speak 
> > > > of crash prone changes so we'll just have to wait and see...
> > > 
> > > The machine hanged again this night and I took two pictures:
> > > http://www.mypicx.com/uploadimg/1055813374_03302009_2.jpg
> > > http://www.mypicx.com/uploadimg/1543678904_03302009_1.jpg
> > >
> > > But this time there was no tcp related warning in the logs.
> > 
> > Right. If that oops would be hit often enough one can easily mix the 
> > warning with that hang though there is no relation (the fact that final 
> > oops always goes unnoticed in X amplifies the effect).
> > 
> > > I then pulled the lateset git changes, rebuild, rebooted and setup the
> > > workload again. The machine was still up and running in the morning 
> > > (~4 hours uptime). So it may well be that the issue was fixed with
> > > the latest changes.
> > 
> > Lets hope so, in any case if you still see hangs please get the final oops.
> > 
> > > If it ever occurs again I will notify you.
> 
> It happend again. In this case it took ~10 minutes from the warning to
> the final crash. I'm pretty sure there must be some kind of relation
> between the two. How else could one explain that the machine crashes just
> minutes after _each_ instance of that WARNING?

Here's my try #1... It should silence the warning (we would have seen 
a later warning in the console btw and finally an oops due to NULL 
dereference would you have been able to capture it) and hopefully doesn't 
introduce any other problem of any kind. So far I did only compile 
test it.

-- 
 i.


--
[PATCH] tcp: miscounts due to tcp_fragment pcount reset

It seems that trivial reset of pcount to one was not sufficient
in tcp_retransmit_skb. Multiple counters experience a positive
miscount when skb's pcount gets lowered without the necessary
adjustments (depending on skb's sacked bits which exactly), at
worst a packets_out miscount can crash at RTO if the write queue
is empty!

Triggering this requires mss change, so bidir tcp or mtu probe or
like.

We need full-scale adjustment which is easier to just move into
a helper and call for that from the other places. Probably saves
some space too but I didn't check how much.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
Reported-by: Markus Trippelsdorf <markus@trippelsdorf.de>

---
 include/net/tcp.h     |   15 ----------
 net/ipv4/tcp_output.c |   73 +++++++++++++++++++++++++++----------------------
 2 files changed, 40 insertions(+), 48 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index e54c76d..1b94b9b 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -616,21 +616,6 @@ static inline int tcp_skb_mss(const struct sk_buff *skb)
 	return skb_shinfo(skb)->gso_size;
 }
 
-static inline void tcp_dec_pcount_approx_int(__u32 *count, const int decr)
-{
-	if (*count) {
-		*count -= decr;
-		if ((int)*count < 0)
-			*count = 0;
-	}
-}
-
-static inline void tcp_dec_pcount_approx(__u32 *count,
-					 const struct sk_buff *skb)
-{
-	tcp_dec_pcount_approx_int(count, tcp_skb_pcount(skb));
-}
-
 /* Events passed to congestion control interface */
 enum tcp_ca_event {
 	CA_EVENT_TX_START,	/* first transmit when no packets in flight */
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index c1f259d..53300fa 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -754,6 +754,36 @@ static void tcp_adjust_fackets_out(struct sock *sk, struct sk_buff *skb,
 		tp->fackets_out -= decr;
 }
 
+/* Pcount in the middle of the write queue got changed, we need to do various
+ * tweaks to fix counters
+ */
+static void tcp_adjust_pcount(struct sock *sk, struct sk_buff *skb, int decr)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	tp->packets_out -= decr;
+
+	if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED)
+		tp->sacked_out -= decr;
+	if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_RETRANS)
+		tp->retrans_out -= decr;
+	if (TCP_SKB_CB(skb)->sacked & TCPCB_LOST)
+		tp->lost_out -= decr;
+
+	/* Reno case is special. Sigh... */
+	if (tcp_is_reno(tp) && decr > 0)
+		tp->sacked_out -= min_t(u32, tp->sacked_out, decr);
+
+	tcp_adjust_fackets_out(sk, skb, decr);
+
+	if (tp->lost_skb_hint &&
+	    before(TCP_SKB_CB(skb)->seq, TCP_SKB_CB(tp->lost_skb_hint)->seq) &&
+	    (tcp_is_fack(tp) || TCP_SKB_CB(skb)->sacked))
+		tp->lost_cnt_hint -= decr;
+
+	tcp_verify_left_out(tp);
+}
+
 /* Function to create two new TCP segments.  Shrinks the given segment
  * to the specified size and appends a new segment with the rest of the
  * packet to the list.  This won't be called frequently, I hope.
@@ -836,28 +866,8 @@ int tcp_fragment(struct sock *sk, struct sk_buff *skb, u32 len,
 		int diff = old_factor - tcp_skb_pcount(skb) -
 			tcp_skb_pcount(buff);
 
-		tp->packets_out -= diff;
-
-		if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED)
-			tp->sacked_out -= diff;
-		if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_RETRANS)
-			tp->retrans_out -= diff;
-
-		if (TCP_SKB_CB(skb)->sacked & TCPCB_LOST)
-			tp->lost_out -= diff;
-
-		/* Adjust Reno SACK estimate. */
-		if (tcp_is_reno(tp) && diff > 0) {
-			tcp_dec_pcount_approx_int(&tp->sacked_out, diff);
-			tcp_verify_left_out(tp);
-		}
-		tcp_adjust_fackets_out(sk, skb, diff);
-
-		if (tp->lost_skb_hint &&
-		    before(TCP_SKB_CB(skb)->seq,
-			   TCP_SKB_CB(tp->lost_skb_hint)->seq) &&
-		    (tcp_is_fack(tp) || TCP_SKB_CB(skb)->sacked))
-			tp->lost_cnt_hint -= diff;
+		if (diff)
+			tcp_adjust_pcount(sk, skb, diff);
 	}
 
 	/* Link BUFF into the send queue. */
@@ -1768,22 +1778,14 @@ static void tcp_collapse_retrans(struct sock *sk, struct sk_buff *skb)
 	 * packet counting does not break.
 	 */
 	TCP_SKB_CB(skb)->sacked |= TCP_SKB_CB(next_skb)->sacked & TCPCB_EVER_RETRANS;
-	if (TCP_SKB_CB(next_skb)->sacked & TCPCB_SACKED_RETRANS)
-		tp->retrans_out -= tcp_skb_pcount(next_skb);
-	if (TCP_SKB_CB(next_skb)->sacked & TCPCB_LOST)
-		tp->lost_out -= tcp_skb_pcount(next_skb);
-	/* Reno case is special. Sigh... */
-	if (tcp_is_reno(tp) && tp->sacked_out)
-		tcp_dec_pcount_approx(&tp->sacked_out, next_skb);
-
-	tcp_adjust_fackets_out(sk, next_skb, tcp_skb_pcount(next_skb));
-	tp->packets_out -= tcp_skb_pcount(next_skb);
 
 	/* changed transmit queue under us so clear hints */
 	tcp_clear_retrans_hints_partial(tp);
 	if (next_skb == tp->retransmit_skb_hint)
 		tp->retransmit_skb_hint = skb;
 
+	tcp_adjust_pcount(sk, next_skb, tcp_skb_pcount(next_skb));
+
 	sk_wmem_free_skb(sk, next_skb);
 }
 
@@ -1891,7 +1893,12 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 		if (tcp_fragment(sk, skb, cur_mss, cur_mss))
 			return -ENOMEM; /* We'll try again later. */
 	} else {
-		tcp_init_tso_segs(sk, skb, cur_mss);
+		int oldpcount = tcp_skb_pcount(skb);
+
+		if (unlikely(oldpcount > 1)) {
+			tcp_init_tso_segs(sk, skb, cur_mss);
+			tcp_adjust_pcount(sk, skb, oldpcount - tcp_skb_pcount(skb));
+		}
 	}
 
 	tcp_retrans_try_collapse(sk, skb, cur_mss);
-- 
tg: (7c757eb..) fix/miscounts (depends on: origin/master)
---696208474-1341630150-1238584151=:30150--
