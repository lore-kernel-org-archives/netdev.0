From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: change tcp_skb_pcount() location
Date: Wed, 24 Sep 2014 04:11:22 -0700
Message-ID: <1411557082.15395.24.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Willem de Bruijn <willemb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:55468 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750828AbaIXLLU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 07:11:20 -0400
Received: by mail-pa0-f48.google.com with SMTP id bj1so1183817pad.7
        for <netdev@vger.kernel.org>; Wed, 24 Sep 2014 04:11:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Our goal is to access no more than one cache line access per skb in
a write or receive queue when doing the various walks.

After recent TCP_SKB_CB() reorganizations, it is almost done.

Last part is tcp_skb_pcount() which currently uses
skb_shinfo(skb)->gso_segs, which is a terrible choice, because it needs
3 cache lines in current kernel (skb->head, skb->end, and
shinfo->gso_segs are all in 3 different cache lines, far from skb->cb)

This very simple patch reuses space currently taken by tcp_tw_isn
only in input path, as tcp_skb_pcount is only needed for skb stored in
write queue.

This considerably speeds up tcp_ack(), granted we avoid shinfo->tx_flags
to get SKBTX_ACK_TSTAMP, which seems possible.

This also speeds up all sack processing in general.

This speeds up tcp_sendmsg() because it no longer has to access/dirty
shinfo.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
Note : This patch applies cleanly after "tcp: better TCP_SKB_CB layout"
patch serie.

 include/net/tcp.h     |   23 +++++++++++++++++++++--
 net/ipv4/tcp.c        |    4 ++--
 net/ipv4/tcp_input.c  |    8 ++++----
 net/ipv4/tcp_output.c |    9 ++++++---
 4 files changed, 33 insertions(+), 11 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 4dc6641ee990..222fd43b36c8 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -698,7 +698,16 @@ static inline u32 tcp_skb_timestamp(const struct sk_buff *skb)
 struct tcp_skb_cb {
 	__u32		seq;		/* Starting sequence number	*/
 	__u32		end_seq;	/* SEQ + FIN + SYN + datalen	*/
-	__u32		tcp_tw_isn;	/* isn chosen by tcp_timewait_state_process() */
+	union {
+		/* Note : tcp_tw_isn is used in input path only
+		 *	  (isn chosen by tcp_timewait_state_process())
+		 *
+		 * 	  tcp_gso_segs is used in write queue only,
+		 *	  cf tcp_skb_pcount()
+		 */
+		__u32		tcp_tw_isn;
+		__u32		tcp_gso_segs;
+	};
 	__u8		tcp_flags;	/* TCP header flags. (tcp[13])	*/
 
 	__u8		sacked;		/* State flags for SACK/FACK.	*/
@@ -746,7 +755,17 @@ TCP_ECN_create_request(struct request_sock *req, const struct sk_buff *skb,
  */
 static inline int tcp_skb_pcount(const struct sk_buff *skb)
 {
-	return skb_shinfo(skb)->gso_segs;
+	return TCP_SKB_CB(skb)->tcp_gso_segs;
+}
+
+static inline void tcp_skb_pcount_set(struct sk_buff *skb, int segs)
+{
+	TCP_SKB_CB(skb)->tcp_gso_segs = segs;
+}
+
+static inline void tcp_skb_pcount_add(struct sk_buff *skb, int segs)
+{
+	TCP_SKB_CB(skb)->tcp_gso_segs += segs;
 }
 
 /* This is valid iff tcp_skb_pcount() > 1. */
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 070aeff1b131..414f590bfee4 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -963,7 +963,7 @@ new_segment:
 		skb->ip_summed = CHECKSUM_PARTIAL;
 		tp->write_seq += copy;
 		TCP_SKB_CB(skb)->end_seq += copy;
-		skb_shinfo(skb)->gso_segs = 0;
+		tcp_skb_pcount_set(skb, 0);
 
 		if (!copied)
 			TCP_SKB_CB(skb)->tcp_flags &= ~TCPHDR_PSH;
@@ -1261,7 +1261,7 @@ new_segment:
 
 			tp->write_seq += copy;
 			TCP_SKB_CB(skb)->end_seq += copy;
-			skb_shinfo(skb)->gso_segs = 0;
+			tcp_skb_pcount_set(skb, 0);
 
 			from += copy;
 			copied += copy;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 13f3da4762e3..da88c0bb287a 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1295,9 +1295,9 @@ static bool tcp_shifted_skb(struct sock *sk, struct sk_buff *skb,
 	TCP_SKB_CB(prev)->end_seq += shifted;
 	TCP_SKB_CB(skb)->seq += shifted;
 
-	skb_shinfo(prev)->gso_segs += pcount;
-	BUG_ON(skb_shinfo(skb)->gso_segs < pcount);
-	skb_shinfo(skb)->gso_segs -= pcount;
+	tcp_skb_pcount_add(prev, pcount);
+	BUG_ON(tcp_skb_pcount(skb) < pcount);
+	tcp_skb_pcount_add(skb, -pcount);
 
 	/* When we're adding to gso_segs == 1, gso_size will be zero,
 	 * in theory this shouldn't be necessary but as long as DSACK
@@ -1310,7 +1310,7 @@ static bool tcp_shifted_skb(struct sock *sk, struct sk_buff *skb,
 	}
 
 	/* CHECKME: To clear or not to clear? Mimics normal skb currently */
-	if (skb_shinfo(skb)->gso_segs <= 1) {
+	if (tcp_skb_pcount(skb) <= 1) {
 		skb_shinfo(skb)->gso_size = 0;
 		skb_shinfo(skb)->gso_type = 0;
 	}
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 6c7949cafd99..b2869a078766 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -384,7 +384,7 @@ static void tcp_init_nondata_skb(struct sk_buff *skb, u32 seq, u8 flags)
 	TCP_SKB_CB(skb)->tcp_flags = flags;
 	TCP_SKB_CB(skb)->sacked = 0;
 
-	shinfo->gso_segs = 1;
+	tcp_skb_pcount_set(skb, 1);
 	shinfo->gso_size = 0;
 	shinfo->gso_type = 0;
 
@@ -972,6 +972,9 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 		TCP_ADD_STATS(sock_net(sk), TCP_MIB_OUTSEGS,
 			      tcp_skb_pcount(skb));
 
+	/* OK, its time to fill skb_shinfo(skb)->gso_segs */
+	skb_shinfo(skb)->gso_segs = tcp_skb_pcount(skb);
+
 	/* Our usage of tstamp should remain private */
 	skb->tstamp.tv64 = 0;
 
@@ -1019,11 +1022,11 @@ static void tcp_set_skb_tso_segs(const struct sock *sk, struct sk_buff *skb,
 		/* Avoid the costly divide in the normal
 		 * non-TSO case.
 		 */
-		shinfo->gso_segs = 1;
+		tcp_skb_pcount_set(skb, 1);
 		shinfo->gso_size = 0;
 		shinfo->gso_type = 0;
 	} else {
-		shinfo->gso_segs = DIV_ROUND_UP(skb->len, mss_now);
+		tcp_skb_pcount_set(skb, DIV_ROUND_UP(skb->len, mss_now));
 		shinfo->gso_size = mss_now;
 		shinfo->gso_type = sk->sk_gso_type;
 	}
