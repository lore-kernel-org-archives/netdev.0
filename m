From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: optimize some skb_shinfo(skb) uses
Date: Thu, 05 Dec 2013 22:31:30 -0800
Message-ID: <1386311490.30495.243.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:58104 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751185Ab3LFGbc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 01:31:32 -0500
Received: by mail-pd0-f173.google.com with SMTP id p10so478062pdj.4
        for <netdev@vger.kernel.org>; Thu, 05 Dec 2013 22:31:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Compiler doesn't know skb_shinfo(skb) pointer is usually constant.

By using a temporary variable, we help generating smaller code.

For example, tcp_init_nondata_skb() is inlined after this patch.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_output.c |   36 +++++++++++++++++++++---------------
 1 file changed, 21 insertions(+), 15 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 7820f3a7dd70..993da005e087 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -363,15 +363,17 @@ static inline void TCP_ECN_send(struct sock *sk, struct sk_buff *skb,
  */
 static void tcp_init_nondata_skb(struct sk_buff *skb, u32 seq, u8 flags)
 {
+	struct skb_shared_info *shinfo = skb_shinfo(skb);
+
 	skb->ip_summed = CHECKSUM_PARTIAL;
 	skb->csum = 0;
 
 	TCP_SKB_CB(skb)->tcp_flags = flags;
 	TCP_SKB_CB(skb)->sacked = 0;
 
-	skb_shinfo(skb)->gso_segs = 1;
-	skb_shinfo(skb)->gso_size = 0;
-	skb_shinfo(skb)->gso_type = 0;
+	shinfo->gso_segs = 1;
+	shinfo->gso_size = 0;
+	shinfo->gso_type = 0;
 
 	TCP_SKB_CB(skb)->seq = seq;
 	if (flags & (TCPHDR_SYN | TCPHDR_FIN))
@@ -986,6 +988,8 @@ static void tcp_queue_skb(struct sock *sk, struct sk_buff *skb)
 static void tcp_set_skb_tso_segs(const struct sock *sk, struct sk_buff *skb,
 				 unsigned int mss_now)
 {
+	struct skb_shared_info *shinfo = skb_shinfo(skb);
+
 	/* Make sure we own this skb before messing gso_size/gso_segs */
 	WARN_ON_ONCE(skb_cloned(skb));
 
@@ -993,13 +997,13 @@ static void tcp_set_skb_tso_segs(const struct sock *sk, struct sk_buff *skb,
 		/* Avoid the costly divide in the normal
 		 * non-TSO case.
 		 */
-		skb_shinfo(skb)->gso_segs = 1;
-		skb_shinfo(skb)->gso_size = 0;
-		skb_shinfo(skb)->gso_type = 0;
+		shinfo->gso_segs = 1;
+		shinfo->gso_size = 0;
+		shinfo->gso_type = 0;
 	} else {
-		skb_shinfo(skb)->gso_segs = DIV_ROUND_UP(skb->len, mss_now);
-		skb_shinfo(skb)->gso_size = mss_now;
-		skb_shinfo(skb)->gso_type = sk->sk_gso_type;
+		shinfo->gso_segs = DIV_ROUND_UP(skb->len, mss_now);
+		shinfo->gso_size = mss_now;
+		shinfo->gso_type = sk->sk_gso_type;
 	}
 }
 
@@ -1146,6 +1150,7 @@ int tcp_fragment(struct sock *sk, struct sk_buff *skb, u32 len,
  */
 static void __pskb_trim_head(struct sk_buff *skb, int len)
 {
+	struct skb_shared_info *shinfo;
 	int i, k, eat;
 
 	eat = min_t(int, len, skb_headlen(skb));
@@ -1157,23 +1162,24 @@ static void __pskb_trim_head(struct sk_buff *skb, int len)
 	}
 	eat = len;
 	k = 0;
-	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-		int size = skb_frag_size(&skb_shinfo(skb)->frags[i]);
+	shinfo = skb_shinfo(skb);
+	for (i = 0; i < shinfo->nr_frags; i++) {
+		int size = skb_frag_size(&shinfo->frags[i]);
 
 		if (size <= eat) {
 			skb_frag_unref(skb, i);
 			eat -= size;
 		} else {
-			skb_shinfo(skb)->frags[k] = skb_shinfo(skb)->frags[i];
+			shinfo->frags[k] = shinfo->frags[i];
 			if (eat) {
-				skb_shinfo(skb)->frags[k].page_offset += eat;
-				skb_frag_size_sub(&skb_shinfo(skb)->frags[k], eat);
+				shinfo->frags[k].page_offset += eat;
+				skb_frag_size_sub(&shinfo->frags[k], eat);
 				eat = 0;
 			}
 			k++;
 		}
 	}
-	skb_shinfo(skb)->nr_frags = k;
+	shinfo->nr_frags = k;
 
 	skb_reset_tail_pointer(skb);
 	skb->data_len -= len;
