From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 1/9]: TCP: The Road to Super TSO
Date: Mon, 06 Jun 2005 21:16:17 -0700 (PDT)
Message-ID: <20050606.211617.92588086.davem@davemloft.net>
References: <20050606.210846.07641049.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, jheffner@psc.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20050606.210846.07641049.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


[TCP]: Simplify SKB data portion allocation with NETIF_F_SG.

The ideal and most optimal layout for an SKB when doing
scatter-gather is to put all the headers at skb->data, and
all the user data in the page array.

This makes SKB splitting and combining extremely simple,
especially before a packet goes onto the wire the first
time.

So, when sk_stream_alloc_pskb() is given a zero size, make
sure there is no skb_tailroom().  This is achieved by applying
SKB_DATA_ALIGN() to the header length used here.

Next, make select_size() in TCP output segmentation use a
length of zero when NETIF_F_SG is true on the outgoing
interface.

Signed-off-by: David S. Miller <davem@davemloft.net>

28f78ef8dcc90a2a26499dab76678bd6813d7793 (from 3f5948fa2cbbda1261eec9a39ef3004b3caf73fb)
diff --git a/include/net/sock.h b/include/net/sock.h
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1130,13 +1130,16 @@ static inline void sk_stream_moderate_sn
 static inline struct sk_buff *sk_stream_alloc_pskb(struct sock *sk,
 						   int size, int mem, int gfp)
 {
-	struct sk_buff *skb = alloc_skb(size + sk->sk_prot->max_header, gfp);
+	struct sk_buff *skb;
+	int hdr_len;
 
+	hdr_len = SKB_DATA_ALIGN(sk->sk_prot->max_header);
+	skb = alloc_skb(size + hdr_len, gfp);
 	if (skb) {
 		skb->truesize += mem;
 		if (sk->sk_forward_alloc >= (int)skb->truesize ||
 		    sk_stream_mem_schedule(sk, skb->truesize, 0)) {
-			skb_reserve(skb, sk->sk_prot->max_header);
+			skb_reserve(skb, hdr_len);
 			return skb;
 		}
 		__kfree_skb(skb);
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -775,13 +775,9 @@ static inline int select_size(struct soc
 {
 	int tmp = tp->mss_cache_std;
 
-	if (sk->sk_route_caps & NETIF_F_SG) {
-		int pgbreak = SKB_MAX_HEAD(MAX_TCP_HEADER);
+	if (sk->sk_route_caps & NETIF_F_SG)
+		tmp = 0;
 
-		if (tmp >= pgbreak &&
-		    tmp <= pgbreak + (MAX_SKB_FRAGS - 1) * PAGE_SIZE)
-			tmp = pgbreak;
-	}
 	return tmp;
 }
 
@@ -891,11 +887,6 @@ new_segment:
 					tcp_mark_push(tp, skb);
 					goto new_segment;
 				} else if (page) {
-					/* If page is cached, align
-					 * offset to L1 cache boundary
-					 */
-					off = (off + L1_CACHE_BYTES - 1) &
-					      ~(L1_CACHE_BYTES - 1);
 					if (off == PAGE_SIZE) {
 						put_page(page);
 						TCP_PAGE(sk) = page = NULL;
