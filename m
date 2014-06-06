From: Octavian Purdila <octavian.purdila@intel.com>
Subject: [PATCH] tcp: add gfp parameter to tcp_fragment
Date: Fri,  6 Jun 2014 17:32:37 +0300
Message-ID: <1402065157-29595-1-git-send-email-octavian.purdila@intel.com>
Cc: christoph.paasch@uclouvain.be,
	Octavian Purdila <octavian.purdila@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:3641 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751477AbaFFOdp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jun 2014 10:33:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp_fragment can be called from process context (from tso_fragment).
Add a new gfp parameter to allow it to preserve atomic memory if
possible.

Signed-off-by: Octavian Purdila <octavian.purdila@intel.com>
Reviewed-by: Christoph Paasch <christoph.paasch@uclouvain.be>
---
 include/net/tcp.h     |  2 +-
 net/ipv4/tcp_input.c  |  5 +++--
 net/ipv4/tcp_output.c | 15 ++++++++-------
 3 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index e80abe4..7286db8 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -535,7 +535,7 @@ void tcp_retransmit_timer(struct sock *sk);
 void tcp_xmit_retransmit_queue(struct sock *);
 void tcp_simple_retransmit(struct sock *);
 int tcp_trim_head(struct sock *, struct sk_buff *, u32);
-int tcp_fragment(struct sock *, struct sk_buff *, u32, unsigned int);
+int tcp_fragment(struct sock *, struct sk_buff *, u32, unsigned int, gfp_t);
 
 void tcp_send_probe0(struct sock *);
 void tcp_send_partial(struct sock *);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 931529d..40661fc 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1167,7 +1167,7 @@ static int tcp_match_skb_to_sack(struct sock *sk, struct sk_buff *skb,
 			}
 			pkt_len = new_len;
 		}
-		err = tcp_fragment(sk, skb, pkt_len, mss);
+		err = tcp_fragment(sk, skb, pkt_len, mss, GFP_ATOMIC);
 		if (err < 0)
 			return err;
 	}
@@ -2241,7 +2241,8 @@ static void tcp_mark_head_lost(struct sock *sk, int packets, int mark_head)
 				break;
 
 			mss = skb_shinfo(skb)->gso_size;
-			err = tcp_fragment(sk, skb, (packets - oldcnt) * mss, mss);
+			err = tcp_fragment(sk, skb, (packets - oldcnt) * mss,
+					   mss, GFP_ATOMIC);
 			if (err < 0)
 				break;
 			cnt = packets;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index d463c35..ad7549f 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1074,7 +1074,7 @@ static void tcp_adjust_pcount(struct sock *sk, const struct sk_buff *skb, int de
  * Remember, these are still headerless SKBs at this point.
  */
 int tcp_fragment(struct sock *sk, struct sk_buff *skb, u32 len,
-		 unsigned int mss_now)
+		 unsigned int mss_now, gfp_t gfp)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *buff;
@@ -1089,11 +1089,11 @@ int tcp_fragment(struct sock *sk, struct sk_buff *skb, u32 len,
 	if (nsize < 0)
 		nsize = 0;
 
-	if (skb_unclone(skb, GFP_ATOMIC))
+	if (skb_unclone(skb, gfp))
 		return -ENOMEM;
 
 	/* Get a new skb... force flag on. */
-	buff = sk_stream_alloc_skb(sk, nsize, GFP_ATOMIC);
+	buff = sk_stream_alloc_skb(sk, nsize, gfp);
 	if (buff == NULL)
 		return -ENOMEM; /* We'll just try again later. */
 
@@ -1625,7 +1625,7 @@ static int tso_fragment(struct sock *sk, struct sk_buff *skb, unsigned int len,
 
 	/* All of a TSO frame must be composed of paged data.  */
 	if (skb->len != skb->data_len)
-		return tcp_fragment(sk, skb, len, mss_now);
+		return tcp_fragment(sk, skb, len, mss_now, gfp);
 
 	buff = sk_stream_alloc_skb(sk, 0, gfp);
 	if (unlikely(buff == NULL))
@@ -2122,7 +2122,8 @@ void tcp_send_loss_probe(struct sock *sk)
 		goto rearm_timer;
 
 	if ((pcount > 1) && (skb->len > (pcount - 1) * mss)) {
-		if (unlikely(tcp_fragment(sk, skb, (pcount - 1) * mss, mss)))
+		if (unlikely(tcp_fragment(sk, skb, (pcount - 1) * mss, mss,
+					  GFP_ATOMIC)))
 			goto rearm_timer;
 		skb = tcp_write_queue_tail(sk);
 	}
@@ -2463,7 +2464,7 @@ int __tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 		return -EAGAIN;
 
 	if (skb->len > cur_mss) {
-		if (tcp_fragment(sk, skb, cur_mss, cur_mss))
+		if (tcp_fragment(sk, skb, cur_mss, cur_mss, GFP_ATOMIC))
 			return -ENOMEM; /* We'll try again later. */
 	} else {
 		int oldpcount = tcp_skb_pcount(skb);
@@ -3244,7 +3245,7 @@ int tcp_write_wakeup(struct sock *sk)
 		    skb->len > mss) {
 			seg_size = min(seg_size, mss);
 			TCP_SKB_CB(skb)->tcp_flags |= TCPHDR_PSH;
-			if (tcp_fragment(sk, skb, seg_size, mss))
+			if (tcp_fragment(sk, skb, seg_size, mss, GFP_ATOMIC))
 				return -1;
 		} else if (!tcp_skb_pcount(skb))
 			tcp_set_skb_tso_segs(sk, skb, mss);
-- 
1.8.3.2
