From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [2/2] [IPSEC] Move xfrm[46]_tunnel_check_size into xfrm[46]_output.c
Date: Mon, 2 Aug 2004 19:35:00 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040802093500.GA19747@gondor.apana.org.au>
References: <20040802093153.GA19706@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="82I3+IH0IqGh5yIs"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040802093153.GA19706@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--82I3+IH0IqGh5yIs
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

This patch moves xfrm[46]_tunnel_check_size() into xfrm[46]_output.c
where it can be made static since it's only used there.

While moving the icmp.h inclusions over I also discovered that the
tunnel files are missing an inclusion of net/protocol.h.  So I've
added them as well.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--82I3+IH0IqGh5yIs
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p2

===== include/net/xfrm.h 1.62 vs edited =====
--- 1.62/include/net/xfrm.h	2004-08-02 07:15:02 +10:00
+++ edited/include/net/xfrm.h	2004-08-02 18:02:32 +10:00
@@ -821,12 +821,10 @@
 extern int xfrm4_output(struct sk_buff **pskb);
 extern int xfrm4_tunnel_register(struct xfrm_tunnel *handler);
 extern int xfrm4_tunnel_deregister(struct xfrm_tunnel *handler);
-extern int xfrm4_tunnel_check_size(struct sk_buff *skb);
 extern int xfrm6_rcv(struct sk_buff **pskb, unsigned int *nhoffp);
 extern int xfrm6_output(struct sk_buff **pskb);
 extern int xfrm6_tunnel_register(struct xfrm6_tunnel *handler);
 extern int xfrm6_tunnel_deregister(struct xfrm6_tunnel *handler);
-extern int xfrm6_tunnel_check_size(struct sk_buff *skb);
 extern u32 xfrm6_tunnel_alloc_spi(xfrm_address_t *saddr);
 extern void xfrm6_tunnel_free_spi(xfrm_address_t *saddr);
 extern u32 xfrm6_tunnel_spi_lookup(xfrm_address_t *saddr);
===== net/ipv4/xfrm4_output.c 1.1 vs edited =====
--- 1.1/net/ipv4/xfrm4_output.c	2004-07-11 04:53:15 +10:00
+++ edited/net/ipv4/xfrm4_output.c	2004-08-02 17:58:15 +10:00
@@ -13,6 +13,7 @@
 #include <net/inet_ecn.h>
 #include <net/ip.h>
 #include <net/xfrm.h>
+#include <net/icmp.h>
 
 /* Add encapsulation header.
  *
@@ -65,6 +66,30 @@
 	top_iph->protocol = IPPROTO_IPIP;
 
 	memset(&(IPCB(skb)->opt), 0, sizeof(struct ip_options));
+}
+
+static int xfrm4_tunnel_check_size(struct sk_buff *skb)
+{
+	int mtu, ret = 0;
+	struct dst_entry *dst;
+	struct iphdr *iph = skb->nh.iph;
+
+	if (IPCB(skb)->flags & IPSKB_XFRM_TUNNEL_SIZE)
+		goto out;
+
+	IPCB(skb)->flags |= IPSKB_XFRM_TUNNEL_SIZE;
+	
+	if (!(iph->frag_off & htons(IP_DF)))
+		goto out;
+
+	dst = skb->dst;
+	mtu = dst_pmtu(dst) - dst->header_len - dst->trailer_len;
+	if (skb->len > mtu) {
+		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu));
+		ret = -EMSGSIZE;
+	}
+out:
+	return ret;
 }
 
 int xfrm4_output(struct sk_buff **pskb)
===== net/ipv4/xfrm4_tunnel.c 1.14 vs edited =====
--- 1.14/net/ipv4/xfrm4_tunnel.c	2004-08-02 17:53:26 +10:00
+++ edited/net/ipv4/xfrm4_tunnel.c	2004-08-02 18:06:32 +10:00
@@ -6,31 +6,7 @@
 #include <linux/skbuff.h>
 #include <net/xfrm.h>
 #include <net/ip.h>
-#include <net/icmp.h>
-
-int xfrm4_tunnel_check_size(struct sk_buff *skb)
-{
-	int mtu, ret = 0;
-	struct dst_entry *dst;
-	struct iphdr *iph = skb->nh.iph;
-
-	if (IPCB(skb)->flags & IPSKB_XFRM_TUNNEL_SIZE)
-		goto out;
-
-	IPCB(skb)->flags |= IPSKB_XFRM_TUNNEL_SIZE;
-	
-	if (!(iph->frag_off & htons(IP_DF)))
-		goto out;
-
-	dst = skb->dst;
-	mtu = dst_pmtu(dst) - dst->header_len - dst->trailer_len;
-	if (skb->len > mtu) {
-		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu));
-		ret = -EMSGSIZE;
-	}
-out:
-	return ret;
-}
+#include <net/protocol.h>
 
 static int ipip_output(struct sk_buff **pskb)
 {
===== net/ipv6/xfrm6_output.c 1.1 vs edited =====
--- 1.1/net/ipv6/xfrm6_output.c	2004-07-30 12:17:21 +10:00
+++ edited/net/ipv6/xfrm6_output.c	2004-08-02 18:01:03 +10:00
@@ -11,6 +11,7 @@
 
 #include <linux/skbuff.h>
 #include <linux/spinlock.h>
+#include <linux/icmpv6.h>
 #include <net/inet_ecn.h>
 #include <net/ipv6.h>
 #include <net/xfrm.h>
@@ -66,6 +67,23 @@
 	top_iph->hop_limit = iph->hop_limit;
 	ipv6_addr_copy(&top_iph->saddr, (struct in6_addr *)&x->props.saddr);
 	ipv6_addr_copy(&top_iph->daddr, (struct in6_addr *)&x->id.daddr);
+}
+
+static int xfrm6_tunnel_check_size(struct sk_buff *skb)
+{
+	int mtu, ret = 0;
+	struct dst_entry *dst = skb->dst;
+
+	mtu = dst_pmtu(dst) - sizeof(struct ipv6hdr);
+	if (mtu < IPV6_MIN_MTU)
+		mtu = IPV6_MIN_MTU;
+
+	if (skb->len > mtu) {
+		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu, skb->dev);
+		ret = -EMSGSIZE;
+	}
+
+	return ret;
 }
 
 int xfrm6_output(struct sk_buff **pskb)
===== net/ipv6/xfrm6_tunnel.c 1.4 vs edited =====
--- 1.4/net/ipv6/xfrm6_tunnel.c	2004-08-02 07:15:03 +10:00
+++ edited/net/ipv6/xfrm6_tunnel.c	2004-08-02 18:07:06 +10:00
@@ -27,8 +27,8 @@
 #include <linux/list.h>
 #include <net/ip.h>
 #include <net/xfrm.h>
-#include <net/icmp.h>
 #include <net/ipv6.h>
+#include <net/protocol.h>
 #include <linux/ipv6.h>
 #include <linux/icmpv6.h>
 
@@ -342,25 +342,6 @@
 }
 
 EXPORT_SYMBOL(xfrm6_tunnel_free_spi);
-
-int xfrm6_tunnel_check_size(struct sk_buff *skb)
-{
-	int mtu, ret = 0;
-	struct dst_entry *dst = skb->dst;
-
-	mtu = dst_pmtu(dst) - sizeof(struct ipv6hdr);
-	if (mtu < IPV6_MIN_MTU)
-		mtu = IPV6_MIN_MTU;
-
-	if (skb->len > mtu) {
-		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu, skb->dev);
-		ret = -EMSGSIZE;
-	}
-
-	return ret;
-}
-
-EXPORT_SYMBOL(xfrm6_tunnel_check_size);
 
 static int xfrm6_tunnel_output(struct sk_buff **pskb)
 {
===== net/xfrm/xfrm_export.c 1.2 vs edited =====
--- 1.2/net/xfrm/xfrm_export.c	2004-06-18 16:20:58 +10:00
+++ edited/net/xfrm/xfrm_export.c	2004-08-02 17:58:32 +10:00
@@ -35,7 +35,6 @@
 EXPORT_SYMBOL(xfrm4_rcv);
 EXPORT_SYMBOL(xfrm4_tunnel_register);
 EXPORT_SYMBOL(xfrm4_tunnel_deregister);
-EXPORT_SYMBOL(xfrm4_tunnel_check_size);
 EXPORT_SYMBOL(xfrm_register_type);
 EXPORT_SYMBOL(xfrm_unregister_type);
 EXPORT_SYMBOL(xfrm_get_type);

--82I3+IH0IqGh5yIs--
