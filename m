From: arno@natisbad.org (Arnaud Ebalard)
Subject: [PATCH net-next-2.6 4/5] XFRM,IPv6: Add IRO remapping hook in xfrm_input()
Date: Fri, 24 Sep 2010 21:25:39 +0200
Message-ID: <87r5gjq6z0.fsf@small.ssi.corp>
References: <87bp7nrlvy.fsf@small.ssi.corp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from copper.chdir.org ([88.191.97.87]:55486 "EHLO copper.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757777Ab0IXTZJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Sep 2010 15:25:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Add a hook in xfrm_input() to allow IRO remapping to occur when
an incoming packet matching an existing SA (based on SPI) with
an unexpected destination or source address is received.
Because IRO does not consume additional bits in a packet (that's
the point), there is no way to demultiplex based on something
like nh or spi. Instead, IRO input handlers (for source and
destination address remapping) are called upon address mismatch
during IPsec processing.
For that to work, we rely on the fact that SPI values generated
locally are no more linked to destination address (first patch
of the set) and we postpone a bit the expected address check in
xfrm_input() (inside xfrm_state_lookup() against daddr param) by
introducing xfrm_input_addr_check() helper.

Signed-off-by: Arnaud Ebalard <arno@natisbad.org>
---
 include/net/xfrm.h     |    3 ++
 net/ipv4/xfrm4_input.c |   12 +++++++++
 net/ipv6/xfrm6_input.c |   65 +++++++++++++++++++++++++++++++++++++++++++++++-
 net/xfrm/xfrm_input.c  |   25 ++++++++++++++++--
 net/xfrm/xfrm_state.c  |    2 +-
 5 files changed, 102 insertions(+), 5 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 7ac6abe..61a0562 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -623,6 +623,7 @@ struct xfrm_spi_skb_cb {
 		struct inet6_skb_parm h6;
 	} header;
 
+	unsigned int saddroff;
 	unsigned int daddroff;
 	unsigned int family;
 };
@@ -1405,6 +1406,7 @@ extern int xfrm4_rcv_encap(struct sk_buff *skb, int nexthdr, __be32 spi,
 			   int encap_type);
 extern int xfrm4_transport_finish(struct sk_buff *skb, int async);
 extern int xfrm4_rcv(struct sk_buff *skb);
+extern int xfrm4_input_addr_check(struct sk_buff *skb, struct xfrm_state *x);
 
 static inline int xfrm4_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi)
 {
@@ -1423,6 +1425,7 @@ extern int xfrm6_transport_finish(struct sk_buff *skb, int async);
 extern int xfrm6_rcv(struct sk_buff *skb);
 extern int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
 			    xfrm_address_t *saddr, u8 proto);
+extern int xfrm6_input_addr_check(struct sk_buff *skb, struct xfrm_state *x);
 extern int xfrm6_tunnel_register(struct xfrm6_tunnel *handler, unsigned short family);
 extern int xfrm6_tunnel_deregister(struct xfrm6_tunnel *handler, unsigned short family);
 extern __be32 xfrm6_tunnel_alloc_spi(struct net *net, xfrm_address_t *saddr);
diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
index 06814b6..82e23ec 100644
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -41,6 +41,7 @@ int xfrm4_rcv_encap(struct sk_buff *skb, int nexthdr, __be32 spi,
 		    int encap_type)
 {
 	XFRM_SPI_SKB_CB(skb)->family = AF_INET;
+	XFRM_SPI_SKB_CB(skb)->saddroff = offsetof(struct iphdr, saddr);
 	XFRM_SPI_SKB_CB(skb)->daddroff = offsetof(struct iphdr, daddr);
 	return xfrm_input(skb, nexthdr, spi, encap_type);
 }
@@ -164,3 +165,14 @@ int xfrm4_rcv(struct sk_buff *skb)
 	return xfrm4_rcv_spi(skb, ip_hdr(skb)->protocol, 0);
 }
 EXPORT_SYMBOL(xfrm4_rcv);
+
+int xfrm4_input_addr_check(struct sk_buff *skb, struct xfrm_state *x)
+{
+	xfrm_address_t *daddr;
+
+	daddr = (xfrm_address_t *)(skb_network_header(skb) +
+				   XFRM_SPI_SKB_CB(skb)->daddroff);
+
+	return xfrm_addr_cmp(&x->id.daddr, daddr, AF_INET);
+}
+EXPORT_SYMBOL(xfrm4_input_addr_check);
diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index f8c3cf8..dda3175 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -15,6 +15,8 @@
 #include <linux/netfilter_ipv6.h>
 #include <net/ipv6.h>
 #include <net/xfrm.h>
+#include <net/addrconf.h> /* XXX for ipv6_chk_home_addr() */
+#include <net/ip6_route.h> /* XXX for ip6_route_input() */
 
 int xfrm6_extract_input(struct xfrm_state *x, struct sk_buff *skb)
 {
@@ -24,6 +26,7 @@ int xfrm6_extract_input(struct xfrm_state *x, struct sk_buff *skb)
 int xfrm6_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi)
 {
 	XFRM_SPI_SKB_CB(skb)->family = AF_INET6;
+	XFRM_SPI_SKB_CB(skb)->saddroff = offsetof(struct ipv6hdr, saddr);
 	XFRM_SPI_SKB_CB(skb)->daddroff = offsetof(struct ipv6hdr, daddr);
 	return xfrm_input(skb, nexthdr, spi, 0);
 }
@@ -142,5 +145,65 @@ int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
 drop:
 	return -1;
 }
-
 EXPORT_SYMBOL(xfrm6_input_addr);
+
+/* Perform check on source and destination addresses and possibly IRO
+ * address remapping upon mismatch and if matching IRO state exists. */
+int xfrm6_input_addr_check(struct sk_buff *skb, struct xfrm_state *x)
+{
+	xfrm_address_t *saddr, *exp_saddr, *daddr, *exp_daddr;
+
+	saddr = (xfrm_address_t *)(skb_network_header(skb) +
+				   XFRM_SPI_SKB_CB(skb)->saddroff);
+	daddr = (xfrm_address_t *)(skb_network_header(skb) +
+				   XFRM_SPI_SKB_CB(skb)->daddroff);
+
+	exp_daddr = &x->id.daddr;
+	if (xfrm_addr_cmp(exp_daddr, daddr, AF_INET6)) {
+		/* Destination address mismatch: check if we have an IRO
+		 * destination remapping state to explain that.
+		 *
+		 * Note: saddr is provided as a hint. If source address
+		 * is also a remapped one, xfrm6_input_addr() will manage
+		 * to find IRO destination remapping state */
+		if (xfrm6_input_addr(skb, exp_daddr, saddr,
+				     XFRM_PROTO_IRO_DST) < 0)
+			return -1;
+
+		if (!ipv6_chk_home_addr(dev_net(skb_dst(skb)->dev),
+					(struct in6_addr *)exp_daddr))
+			return -1;
+
+		/* Copy destination address to sec_path for sock opts and
+		 * replace packet destination address with expected HoA */
+		ipv6_addr_copy(&skb->sp->irodst, (struct in6_addr *)daddr);
+		ipv6_addr_copy((struct in6_addr *)daddr,
+			       (struct in6_addr *)exp_daddr);
+
+		skb_dst_drop(skb);
+		ip6_route_input(skb);
+		if (skb_dst(skb)->error)
+			return -1;
+	}
+
+	exp_saddr = &x->props.saddr;
+	if (xfrm_addr_cmp(exp_saddr, saddr, AF_INET6)) {
+		/* Source address mismatch: check if we have an IRO
+		 * source remapping state to explain that.
+		 *
+		 * Note: unlike for destination addresses above, a
+		 * source mismatch is not considered fatal */
+		if (xfrm6_input_addr(skb, daddr, exp_saddr,
+				     XFRM_PROTO_IRO_SRC) < 0)
+			return 0;
+
+		/* Copy destination address to sec_path for sock opts and
+		 * then replace source address with expected peer's HoA */
+		ipv6_addr_copy(&skb->sp->irosrc, (struct in6_addr *)saddr);
+		ipv6_addr_copy((struct in6_addr *)saddr,
+			       (struct in6_addr *)exp_saddr);
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(xfrm6_input_addr_check);
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 45f1c98..95e19ac 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -102,13 +102,30 @@ int xfrm_prepare_input(struct xfrm_state *x, struct sk_buff *skb)
 }
 EXPORT_SYMBOL(xfrm_prepare_input);
 
+int xfrm_input_addr_check(struct sk_buff *skb, struct xfrm_state *x,
+			  unsigned int family)
+{
+	switch (family) {
+	case AF_INET:
+		if (xfrm4_input_addr_check(skb, x))
+			return -1;
+		break;
+	case AF_INET6:
+		if (xfrm6_input_addr_check(skb, x))
+			return -1;
+		break;
+	}
+
+	return 0;
+}
+
 int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 {
 	struct net *net = dev_net(skb->dev);
 	int err;
 	__be32 seq;
 	struct xfrm_state *x;
-	xfrm_address_t *daddr;
+	xfrm_address_t *saddr, *daddr;
 	struct xfrm_mode *inner_mode;
 	unsigned int family;
 	int decaps = 0;
@@ -136,6 +153,8 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 		skb->sp = sp;
 	}
 
+	saddr = (xfrm_address_t *)(skb_network_header(skb) +
+				   XFRM_SPI_SKB_CB(skb)->saddroff);
 	daddr = (xfrm_address_t *)(skb_network_header(skb) +
 				   XFRM_SPI_SKB_CB(skb)->daddroff);
 	family = XFRM_SPI_SKB_CB(skb)->family;
@@ -152,8 +171,8 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 			goto drop;
 		}
 
-		x = xfrm_state_lookup(net, skb->mark, daddr, spi, nexthdr, family);
-		if (x == NULL) {
+		x = xfrm_state_lookup(net, skb->mark, NULL, spi, nexthdr, family);
+		if (x == NULL || xfrm_input_addr_check(skb, x, family)) {
 			XFRM_INC_STATS(net, LINUX_MIB_XFRMINNOSTATES);
 			xfrm_audit_state_notfound(skb, family, spi, seq);
 			goto drop;
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 7ad4462..688efc1 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -677,7 +677,7 @@ static struct xfrm_state *__xfrm_state_lookup(struct net *net, u32 mark, xfrm_ad
 		if (x->props.family != family ||
 		    x->id.spi       != spi ||
 		    x->id.proto     != proto ||
-		    xfrm_addr_cmp(&x->id.daddr, daddr, family))
+		    (daddr && xfrm_addr_cmp(&x->id.daddr, daddr, family)))
 			continue;
 
 		if ((mark & x->mark.m) != x->mark.v)
-- 
1.7.1


