From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 1/2] tcp: add helper for counter tweaking due mid-wq change
Date: Thu, 2 Apr 2009 12:15:17 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0904021212310.30150@wrl-59.cs.helsinki.fi>
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
 <Pine.LNX.4.64.0904011352470.30150@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/Mixed; boundary="-696208474-1341630150-1238584151=:30150"
Cc: Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Uwe Bugla <uwe.bugla@gmx.de>
To: Markus Trippelsdorf <markus@trippelsdorf.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:60698 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935266AbZDBJPZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 05:15:25 -0400
In-Reply-To: <Pine.LNX.4.64.0904011352470.30150@wrl-59.cs.helsinki.fi>
Content-ID: <Pine.LNX.4.64.0904021212311.30150@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1341630150-1238584151=:30150
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0904021212312.30150@wrl-59.cs.helsinki.fi>

On Wed, 1 Apr 2009, Ilpo Järvinen wrote:
> On Tue, 31 Mar 2009, Markus Trippelsdorf wrote:
> > On Tue, Mar 31, 2009 at 12:16:51PM +0300, Ilpo Järvinen wrote:
> > > 
> > > > If it ever occurs again I will notify you.
> > 
> > It happend again. In this case it took ~10 minutes from the warning to
> > the final crash. I'm pretty sure there must be some kind of relation
> > between the two. How else could one explain that the machine crashes just
> > minutes after _each_ instance of that WARNING?
> 
> Here's my try #1... It should silence the warning (we would have seen 
> a later warning in the console btw and finally an oops due to NULL 
> dereference would you have been able to capture it) and hopefully doesn't 
> introduce any other problem of any kind. So far I did only compile 
> test it.

A split series seems better to make the actual fix very obvious (in the 
second patch), this is the first helper part:


[PATCH 1/2] tcp: add helper for counter tweaking due mid-wq change

We need full-scale adjustment to fix a TCP miscount in the next
patch, so just move it into a helper and call for that from the
other places.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/tcp.h     |   15 -----------
 net/ipv4/tcp_output.c |   66 +++++++++++++++++++++++++-----------------------
 2 files changed, 34 insertions(+), 47 deletions(-)

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
index c1f259d..f1db89b 100644
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
 
-- 
1.5.2.2

---696208474-1341630150-1238584151=:30150--
