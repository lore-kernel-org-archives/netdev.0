From: Patrick McHardy <kaber@trash.net>
Subject: [NF+IPsec 4/6]: Make IPsec input processing symetrical to output
Date: Mon, 17 Oct 2005 02:22:32 +0200
Message-ID: <4352EEC8.9000602@trash.net>
Mime-Version: 1.0
Content-Type: text/x-patch;
 name="04.diff"
Content-Transfer-Encoding: 7bit
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Content-Disposition: inline;
 filename="04.diff"
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

[NETFILTER]: Make IPsec input processing symetrical to output

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 9b2748c756fd805c0fe5b37505735e02f06ebb28
tree 440bd33a45b20a01481876c5b379017cceec0388
parent 92dffb4b8138637d28173cc9c10fe5990914cf5d
author Patrick McHardy <kaber@trash.net> Mon, 17 Oct 2005 01:32:19 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 17 Oct 2005 01:32:19 +0200

 net/ipv4/xfrm4_input.c |   23 ++++++++++++++---------
 net/ipv6/xfrm6_input.c |   23 ++++++++++++++---------
 2 files changed, 28 insertions(+), 18 deletions(-)

diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -137,16 +137,21 @@ int xfrm4_rcv_encap(struct sk_buff *skb,
 	memcpy(skb->sp->x+skb->sp->len, xfrm_vec, xfrm_nr*sizeof(struct sec_decap_state));
 	skb->sp->len += xfrm_nr;
 
-	if (decaps) {
-		if (!(skb->dev->flags&IFF_LOOPBACK)) {
-			dst_release(skb->dst);
-			skb->dst = NULL;
-		}
-		netif_rx(skb);
-		return 0;
-	} else {
-		return -skb->nh.iph->protocol;
+	if (!decaps) {
+		if (skb_cloned(skb) &&
+		    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
+			goto drop;
+		__skb_push(skb, skb->data - skb->nh.raw);
+		skb->nh.iph->tot_len = htons(skb->len);
+		ip_send_check(skb->nh.iph);
 	}
+	if (!(skb->dev->flags&IFF_LOOPBACK)) {
+		dst_release(skb->dst);
+		skb->dst = NULL;
+	}
+	nf_reset(skb);
+	netif_rx(skb);
+	return 0;
 
 drop_unlock:
 	spin_unlock(&x->lock);
diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -121,16 +121,21 @@ int xfrm6_rcv_spi(struct sk_buff **pskb,
 	skb->sp->len += xfrm_nr;
 	skb->ip_summed = CHECKSUM_NONE;
 
-	if (decaps) {
-		if (!(skb->dev->flags&IFF_LOOPBACK)) {
-			dst_release(skb->dst);
-			skb->dst = NULL;
-		}
-		netif_rx(skb);
-		return -1;
-	} else {
-		return 1;
+	if (!decaps) {
+		if (skb_cloned(skb) &&
+		    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
+			goto drop;
+		/* FIXME: Jumbo payload option */
+		skb->nh.ipv6h->payload_len = htons(skb->len);
+		__skb_push(skb, skb->data - skb->nh.raw);
 	}
+	if (!(skb->dev->flags&IFF_LOOPBACK)) {
+		dst_release(skb->dst);
+		skb->dst = NULL;
+	}
+	nf_reset(skb);
+	netif_rx(skb);
+	return -1;
 
 drop_unlock:
 	spin_unlock(&x->lock);
