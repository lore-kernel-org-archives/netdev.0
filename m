From: Arnaud Ebalard <arno@natisbad.org>
Subject: [PATCHv3 net-next-2.6 4/5] XFRM,IPv6: Add IRO remapping hook in xfrm_input()
Date: Wed, 29 Sep 2010 11:05:59 +0200
Message-ID: <cc9aa9a5b238d27701140d0d9230593954e53a39.1285749610.git.arno@natisbad.org>
References: <cover.1285749610.git.arno@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from copper.chdir.org ([88.191.97.87]:38538 "EHLO copper.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754453Ab0I2JFE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Sep 2010 05:05:04 -0400
In-Reply-To: <cover.1285749610.git.arno@natisbad.org>
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
introducing a call to the input_addr_check() handler from the
struct xfrm_state_afinfo associated with the address family.

Signed-off-by: Arnaud Ebalard <arno@natisbad.org>
---
 include/net/xfrm.h     |    5 +++
 net/ipv4/xfrm4_input.c |   12 ++++++++
 net/ipv4/xfrm4_state.c |    1 +
 net/ipv6/xfrm6_input.c |   70 +++++++++++++++++++++++++++++++++++++++++++++++-
 net/ipv6/xfrm6_state.c |    1 +
 net/xfrm/xfrm_input.c  |    5 ++-
 net/xfrm/xfrm_state.c  |    2 +-
 7 files changed, 92 insertions(+), 4 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 05b2b1f..5b84c19 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -312,6 +312,8 @@ struct xfrm_state_afinfo {
 						  struct sk_buff *skb);
 	int			(*transport_finish)(struct sk_buff *skb,
 						    int async);
+	int			(*input_addr_check)(struct sk_buff *skb,
+						    struct xfrm_state *x);
 };
 
 extern int xfrm_state_register_afinfo(struct xfrm_state_afinfo *afinfo);
@@ -623,6 +625,7 @@ struct xfrm_spi_skb_cb {
 		struct inet6_skb_parm h6;
 	} header;
 
+	unsigned int saddroff;
 	unsigned int daddroff;
 	unsigned int family;
 };
@@ -1405,6 +1408,7 @@ extern int xfrm4_rcv_encap(struct sk_buff *skb, int nexthdr, __be32 spi,
 			   int encap_type);
 extern int xfrm4_transport_finish(struct sk_buff *skb, int async);
 extern int xfrm4_rcv(struct sk_buff *skb);
+extern int xfrm4_input_addr_check(struct sk_buff *skb, struct xfrm_state *x);
 
 static inline int xfrm4_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi)
 {
@@ -1423,6 +1427,7 @@ extern int xfrm6_transport_finish(struct sk_buff *skb, int async);
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
diff --git a/net/ipv4/xfrm4_state.c b/net/ipv4/xfrm4_state.c
index 4794762..c6b038a 100644
--- a/net/ipv4/xfrm4_state.c
+++ b/net/ipv4/xfrm4_state.c
@@ -79,6 +79,7 @@ static struct xfrm_state_afinfo xfrm4_state_afinfo = {
 	.extract_input		= xfrm4_extract_input,
 	.extract_output		= xfrm4_extract_output,
 	.transport_finish	= xfrm4_transport_finish,
+	.input_addr_check	= xfrm4_input_addr_check,
 };
 
 void __init xfrm4_state_init(void)
diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index f8c3cf8..754ecf7 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -15,6 +15,7 @@
 #include <linux/netfilter_ipv6.h>
 #include <net/ipv6.h>
 #include <net/xfrm.h>
+#include <net/ip6_route.h> /* XXX for ip6_route_input() */
 
 int xfrm6_extract_input(struct xfrm_state *x, struct sk_buff *skb)
 {
@@ -24,6 +25,7 @@ int xfrm6_extract_input(struct xfrm_state *x, struct sk_buff *skb)
 int xfrm6_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi)
 {
 	XFRM_SPI_SKB_CB(skb)->family = AF_INET6;
+	XFRM_SPI_SKB_CB(skb)->saddroff = offsetof(struct ipv6hdr, saddr);
 	XFRM_SPI_SKB_CB(skb)->daddroff = offsetof(struct ipv6hdr, daddr);
 	return xfrm_input(skb, nexthdr, spi, 0);
 }
@@ -142,5 +144,71 @@ int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
 drop:
 	return -1;
 }
-
 EXPORT_SYMBOL(xfrm6_input_addr);
+
+#if defined(CONFIG_XFRM_SUB_POLICY)
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
+#else
+int xfrm6_input_addr_check(struct sk_buff *skb, struct xfrm_state *x)
+{
+	xfrm_address_t *daddr;
+	daddr = (xfrm_address_t *)(skb_network_header(skb) +
+				   XFRM_SPI_SKB_CB(skb)->daddroff);
+	return xfrm_addr_cmp(&x->id.daddr, daddr, AF_INET6);
+}
+#endif
+EXPORT_SYMBOL(xfrm6_input_addr_check);
diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
index a67575d..aeb4688 100644
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -179,6 +179,7 @@ static struct xfrm_state_afinfo xfrm6_state_afinfo = {
 	.extract_input		= xfrm6_extract_input,
 	.extract_output		= xfrm6_extract_output,
 	.transport_finish	= xfrm6_transport_finish,
+	.input_addr_check	= xfrm6_input_addr_check,
 };
 
 int __init xfrm6_state_init(void)
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 45f1c98..9ff65f6 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -152,8 +152,9 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 			goto drop;
 		}
 
-		x = xfrm_state_lookup(net, skb->mark, daddr, spi, nexthdr, family);
-		if (x == NULL) {
+		x = xfrm_state_lookup(net, skb->mark, NULL, spi, nexthdr, family);
+		if (x == NULL ||
+		    x->outer_mode->afinfo->input_addr_check(skb, x)) {
 			XFRM_INC_STATS(net, LINUX_MIB_XFRMINNOSTATES);
 			xfrm_audit_state_notfound(skb, family, spi, seq);
 			goto drop;
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index b6a4d8d..b8f7c08 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -685,7 +685,7 @@ static struct xfrm_state *__xfrm_state_lookup(struct net *net, u32 mark, xfrm_ad
 		if (x->props.family != family ||
 		    x->id.spi       != spi ||
 		    x->id.proto     != proto ||
-		    xfrm_addr_cmp(&x->id.daddr, daddr, family))
+		    (daddr && xfrm_addr_cmp(&x->id.daddr, daddr, family)))
 			continue;
 
 		if ((mark & x->mark.m) != x->mark.v)
-- 
1.7.1


