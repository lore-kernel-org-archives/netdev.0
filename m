From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC] Call xfrm6_rcv in xfrm6_tunnel_rcv
Date: Tue, 17 Aug 2004 22:26:38 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040817122638.GA1855@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="liOOAslEiF7prFVr"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--liOOAslEiF7prFVr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

This patch reuses the code in xfrm6_input.c for receiving xfrm6_tunnel
packets.  This removes duplicate code as well as fixing the bugs unique
to xfrm6_tunnel_input.  For example, it didn't move the MAC header down.
Nor did it do anything with ECN.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--liOOAslEiF7prFVr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== include/net/xfrm.h 1.66 vs edited =====
--- 1.66/include/net/xfrm.h	2004-08-17 21:45:38 +10:00
+++ edited/include/net/xfrm.h	2004-08-17 22:14:07 +10:00
@@ -780,6 +780,7 @@
 extern int xfrm4_output(struct sk_buff **pskb);
 extern int xfrm4_tunnel_register(struct xfrm_tunnel *handler);
 extern int xfrm4_tunnel_deregister(struct xfrm_tunnel *handler);
+extern int xfrm6_rcv_spi(struct sk_buff **pskb, unsigned int *nhoffp, u32 spi);
 extern int xfrm6_rcv(struct sk_buff **pskb, unsigned int *nhoffp);
 extern int xfrm6_tunnel_register(struct xfrm6_tunnel *handler);
 extern int xfrm6_tunnel_deregister(struct xfrm6_tunnel *handler);
===== net/ipv6/xfrm6_input.c 1.17 vs edited =====
--- 1.17/net/ipv6/xfrm6_input.c	2004-07-30 21:16:40 +10:00
+++ edited/net/ipv6/xfrm6_input.c	2004-08-17 22:15:25 +10:00
@@ -9,6 +9,7 @@
  *		IPv6 support
  */
 
+#include <linux/module.h>
 #include <linux/string.h>
 #include <net/inet_ecn.h>
 #include <net/ip.h>
@@ -25,11 +26,11 @@
 		IP6_ECN_set_ce(inner_iph);
 }
 
-int xfrm6_rcv(struct sk_buff **pskb, unsigned int *nhoffp)
+int xfrm6_rcv_spi(struct sk_buff **pskb, unsigned int *nhoffp, u32 spi)
 {
 	struct sk_buff *skb = *pskb;
 	int err;
-	u32 spi, seq;
+	u32 seq;
 	struct sec_decap_state xfrm_vec[XFRM_MAX_DEPTH];
 	struct xfrm_state *x;
 	int xfrm_nr = 0;
@@ -40,7 +41,8 @@
 	nhoff = *nhoffp;
 	nexthdr = skb->nh.raw[nhoff];
 
-	if ((err = xfrm_parse_spi(skb, nexthdr, &spi, &seq)) != 0)
+	seq = 0;
+	if (!spi && (err = xfrm_parse_spi(skb, nexthdr, &spi, &seq)) != 0)
 		goto drop;
 	
 	do {
@@ -136,4 +138,11 @@
 		xfrm_state_put(xfrm_vec[xfrm_nr].xvec);
 	kfree_skb(skb);
 	return -1;
+}
+
+EXPORT_SYMBOL(xfrm6_rcv_spi);
+
+int xfrm6_rcv(struct sk_buff **pskb, unsigned int *nhoffp)
+{
+	return xfrm6_rcv_spi(pskb, nhoffp, 0);
 }
===== net/ipv6/xfrm6_tunnel.c 1.7 vs edited =====
--- 1.7/net/ipv6/xfrm6_tunnel.c	2004-08-14 20:59:44 +10:00
+++ edited/net/ipv6/xfrm6_tunnel.c	2004-08-17 22:23:54 +10:00
@@ -356,17 +356,6 @@
 
 static int xfrm6_tunnel_input(struct xfrm_state *x, struct xfrm_decap_state *decap, struct sk_buff *skb)
 {
-	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr))) 
-		return -EINVAL;
-
-	skb->mac.raw = skb->nh.raw;
-	skb->nh.raw = skb->data;
-	dst_release(skb->dst);
-	skb->dst = NULL;
-	skb->protocol = htons(ETH_P_IPV6);
-	skb->pkt_type = PACKET_HOST;
-	netif_rx(skb);
-
 	return 0;
 }
 
@@ -413,49 +402,15 @@
 {
 	struct sk_buff *skb = *pskb;
 	struct xfrm6_tunnel *handler = xfrm6_tunnel_handler;
-	struct xfrm_state *x = NULL;
 	struct ipv6hdr *iph = skb->nh.ipv6h;
-	int err = 0;
 	u32 spi;
 
 	/* device-like_ip6ip6_handler() */
-	if (handler) {
-		err = handler->handler(pskb, nhoffp);
-		if (!err)
-			goto out;
-	}
+	if (handler && handler->handler(pskb, nhoffp) == 0)
+		return 0;
 
 	spi = xfrm6_tunnel_spi_lookup((xfrm_address_t *)&iph->saddr);
-	x = xfrm_state_lookup((xfrm_address_t *)&iph->daddr, 
-			spi,
-			IPPROTO_IPV6, AF_INET6);
-
-	if (!x)
-		goto drop;
-
-	spin_lock(&x->lock);
-
-	if (unlikely(x->km.state != XFRM_STATE_VALID))
-		goto drop_unlock;
-
-	err = xfrm6_tunnel_input(x, NULL, skb);
-	if (err)
-		goto drop_unlock;
-
-	x->curlft.bytes += skb->len;
-	x->curlft.packets++; 
-	spin_unlock(&x->lock); 
-	xfrm_state_put(x); 
-
-out:
-	return 0;
-
-drop_unlock:
-	spin_unlock(&x->lock);
-	xfrm_state_put(x);
-drop:
-	kfree_skb(skb);
-	return -1;
+	return xfrm6_rcv_spi(pskb, nhoffp, spi);
 }
 
 static void xfrm6_tunnel_err(struct sk_buff *skb, struct inet6_skb_parm *opt,

--liOOAslEiF7prFVr--
