From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 13/13] esp: Add a software GRO codepath
Date: Thu, 16 Feb 2017 13:18:47 +0100
Message-ID: <1487247527-17925-14-git-send-email-steffen.klassert@secunet.com>
References: <1487247527-17925-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:49314 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754687AbdBPMTA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Feb 2017 07:19:00 -0500
In-Reply-To: <1487247527-17925-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds GRO ifrastructure and callbacks for ESP on
ipv4 and ipv6.

In case the GRO layer detects an ESP packet, the
esp{4,6}_gro_receive() function does a xfrm state lookup
and calls the xfrm input layer if it finds a matching state.
The packet will be decapsulated and reinjected it into layer 2.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h              |   1 +
 net/ipv4/Kconfig                |  13 +++++
 net/ipv4/Makefile               |   1 +
 net/ipv4/esp4_offload.c         | 106 +++++++++++++++++++++++++++++++++++++++
 net/ipv4/xfrm4_input.c          |   6 +++
 net/ipv4/xfrm4_mode_transport.c |   4 +-
 net/ipv6/Kconfig                |  13 +++++
 net/ipv6/Makefile               |   1 +
 net/ipv6/esp6_offload.c         | 108 ++++++++++++++++++++++++++++++++++++++++
 net/ipv6/xfrm6_input.c          |   7 +++
 net/ipv6/xfrm6_mode_transport.c |   4 +-
 net/xfrm/xfrm_input.c           |  31 ++++++++++--
 12 files changed, 288 insertions(+), 7 deletions(-)
 create mode 100644 net/ipv4/esp4_offload.c
 create mode 100644 net/ipv6/esp6_offload.c

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 10086a0..14d82bf 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -682,6 +682,7 @@ struct xfrm_spi_skb_cb {
 
 	unsigned int daddroff;
 	unsigned int family;
+	__be32 seq;
 };
 
 #define XFRM_SPI_SKB_CB(__skb) ((struct xfrm_spi_skb_cb *)&((__skb)->cb[0]))
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 6e7baaf..e0878c3 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -360,6 +360,19 @@ config INET_ESP
 
 	  If unsure, say Y.
 
+config INET_ESP_OFFLOAD
+	tristate "IP: ESP transformation offload"
+	depends on INET_ESP
+	select XFRM_OFFLOAD
+	default n
+	---help---
+	  Support for ESP transformation offload. This makes sense
+	  only if this system really does IPsec and want to do it
+	  with high throughput. A typical desktop system does not
+	  need it, even if it does IPsec.
+
+	  If unsure, say N.
+
 config INET_IPCOMP
 	tristate "IP: IPComp transformation"
 	select INET_XFRM_TUNNEL
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index 48af58a..c6d4238 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -29,6 +29,7 @@ obj-$(CONFIG_NET_IPVTI) += ip_vti.o
 obj-$(CONFIG_SYN_COOKIES) += syncookies.o
 obj-$(CONFIG_INET_AH) += ah4.o
 obj-$(CONFIG_INET_ESP) += esp4.o
+obj-$(CONFIG_INET_ESP_OFFLOAD) += esp4_offload.o
 obj-$(CONFIG_INET_IPCOMP) += ipcomp.o
 obj-$(CONFIG_INET_XFRM_TUNNEL) += xfrm4_tunnel.o
 obj-$(CONFIG_INET_XFRM_MODE_BEET) += xfrm4_mode_beet.o
diff --git a/net/ipv4/esp4_offload.c b/net/ipv4/esp4_offload.c
new file mode 100644
index 0000000..1de4426
--- /dev/null
+++ b/net/ipv4/esp4_offload.c
@@ -0,0 +1,106 @@
+/*
+ * IPV4 GSO/GRO offload support
+ * Linux INET implementation
+ *
+ * Copyright (C) 2016 secunet Security Networks AG
+ * Author: Steffen Klassert <steffen.klassert@secunet.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * ESP GRO support
+ */
+
+#include <linux/skbuff.h>
+#include <linux/init.h>
+#include <net/protocol.h>
+#include <crypto/aead.h>
+#include <crypto/authenc.h>
+#include <linux/err.h>
+#include <linux/module.h>
+#include <net/ip.h>
+#include <net/xfrm.h>
+#include <net/esp.h>
+#include <linux/scatterlist.h>
+#include <linux/kernel.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <net/udp.h>
+
+static struct sk_buff **esp4_gro_receive(struct sk_buff **head,
+					 struct sk_buff *skb)
+{
+	int offset = skb_gro_offset(skb);
+	struct xfrm_offload *xo;
+	struct xfrm_state *x;
+	__be32 seq;
+	__be32 spi;
+	int err;
+
+	skb_pull(skb, offset);
+
+	if ((err = xfrm_parse_spi(skb, IPPROTO_ESP, &spi, &seq)) != 0)
+		goto out;
+
+	err = secpath_set(skb);
+	if (err)
+		goto out;
+
+	if (skb->sp->len == XFRM_MAX_DEPTH)
+		goto out;
+
+	x = xfrm_state_lookup(dev_net(skb->dev), skb->mark,
+			      (xfrm_address_t *)&ip_hdr(skb)->daddr,
+			      spi, IPPROTO_ESP, AF_INET);
+	if (!x)
+		goto out;
+
+	skb->sp->xvec[skb->sp->len++] = x;
+	skb->sp->olen++;
+
+	xo = xfrm_offload(skb);
+	if (!xo) {
+		xfrm_state_put(x);
+		goto out;
+	}
+	xo->flags |= XFRM_GRO;
+
+	XFRM_TUNNEL_SKB_CB(skb)->tunnel.ip4 = NULL;
+	XFRM_SPI_SKB_CB(skb)->family = AF_INET;
+	XFRM_SPI_SKB_CB(skb)->daddroff = offsetof(struct iphdr, daddr);
+	XFRM_SPI_SKB_CB(skb)->seq = seq;
+
+	/* We don't need to handle errors from xfrm_input, it does all
+	 * the error handling and frees the resources on error. */
+	xfrm_input(skb, IPPROTO_ESP, spi, -2);
+
+	return ERR_PTR(-EINPROGRESS);
+out:
+	skb_push(skb, offset);
+	NAPI_GRO_CB(skb)->same_flow = 0;
+	NAPI_GRO_CB(skb)->flush = 1;
+
+	return NULL;
+}
+
+static const struct net_offload esp4_offload = {
+	.callbacks = {
+		.gro_receive = esp4_gro_receive,
+	},
+};
+
+static int __init esp4_offload_init(void)
+{
+	return inet_add_offload(&esp4_offload, IPPROTO_ESP);
+}
+
+static void __exit esp4_offload_exit(void)
+{
+	inet_del_offload(&esp4_offload, IPPROTO_ESP);
+}
+
+module_init(esp4_offload_init);
+module_exit(esp4_offload_exit);
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Steffen Klassert <steffen.klassert@secunet.com>");
diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
index 62e1e72..1fc6841 100644
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -40,6 +40,7 @@ static inline int xfrm4_rcv_encap_finish(struct net *net, struct sock *sk,
 
 int xfrm4_transport_finish(struct sk_buff *skb, int async)
 {
+	struct xfrm_offload *xo = xfrm_offload(skb);
 	struct iphdr *iph = ip_hdr(skb);
 
 	iph->protocol = XFRM_MODE_SKB_CB(skb)->protocol;
@@ -53,6 +54,11 @@ int xfrm4_transport_finish(struct sk_buff *skb, int async)
 	iph->tot_len = htons(skb->len);
 	ip_send_check(iph);
 
+	if (xo && (xo->flags & XFRM_GRO)) {
+		skb_mac_header_rebuild(skb);
+		return 0;
+	}
+
 	NF_HOOK(NFPROTO_IPV4, NF_INET_PRE_ROUTING,
 		dev_net(skb->dev), NULL, skb, skb->dev, NULL,
 		xfrm4_rcv_encap_finish);
diff --git a/net/ipv4/xfrm4_mode_transport.c b/net/ipv4/xfrm4_mode_transport.c
index fd840c7..4acc050 100644
--- a/net/ipv4/xfrm4_mode_transport.c
+++ b/net/ipv4/xfrm4_mode_transport.c
@@ -43,6 +43,7 @@ static int xfrm4_transport_output(struct xfrm_state *x, struct sk_buff *skb)
 static int xfrm4_transport_input(struct xfrm_state *x, struct sk_buff *skb)
 {
 	int ihl = skb->data - skb_transport_header(skb);
+	struct xfrm_offload *xo = xfrm_offload(skb);
 
 	if (skb->transport_header != skb->network_header) {
 		memmove(skb_transport_header(skb),
@@ -50,7 +51,8 @@ static int xfrm4_transport_input(struct xfrm_state *x, struct sk_buff *skb)
 		skb->network_header = skb->transport_header;
 	}
 	ip_hdr(skb)->tot_len = htons(skb->len + ihl);
-	skb_reset_transport_header(skb);
+	if (!xo || !(xo->flags & XFRM_GRO))
+		skb_reset_transport_header(skb);
 	return 0;
 }
 
diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index ec1267e..b2a85cc 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -75,6 +75,19 @@ config INET6_ESP
 
 	  If unsure, say Y.
 
+config INET6_ESP_OFFLOAD
+	tristate "IPv6: ESP transformation offload"
+	depends on INET6_ESP
+	select XFRM_OFFLOAD
+	default n
+	---help---
+	  Support for ESP transformation offload. This makes sense
+	  only if this system really does IPsec and want to do it
+	  with high throughput. A typical desktop system does not
+	  need it, even if it does IPsec.
+
+	  If unsure, say N.
+
 config INET6_IPCOMP
 	tristate "IPv6: IPComp transformation"
 	select INET6_XFRM_TUNNEL
diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index a9e9fec..217e9ff 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -30,6 +30,7 @@ ipv6-objs += $(ipv6-y)
 
 obj-$(CONFIG_INET6_AH) += ah6.o
 obj-$(CONFIG_INET6_ESP) += esp6.o
+obj-$(CONFIG_INET6_ESP_OFFLOAD) += esp6_offload.o
 obj-$(CONFIG_INET6_IPCOMP) += ipcomp6.o
 obj-$(CONFIG_INET6_XFRM_TUNNEL) += xfrm6_tunnel.o
 obj-$(CONFIG_INET6_TUNNEL) += tunnel6.o
diff --git a/net/ipv6/esp6_offload.c b/net/ipv6/esp6_offload.c
new file mode 100644
index 0000000..d914eb9
--- /dev/null
+++ b/net/ipv6/esp6_offload.c
@@ -0,0 +1,108 @@
+/*
+ * IPV6 GSO/GRO offload support
+ * Linux INET implementation
+ *
+ * Copyright (C) 2016 secunet Security Networks AG
+ * Author: Steffen Klassert <steffen.klassert@secunet.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * ESP GRO support
+ */
+
+#include <linux/skbuff.h>
+#include <linux/init.h>
+#include <net/protocol.h>
+#include <crypto/aead.h>
+#include <crypto/authenc.h>
+#include <linux/err.h>
+#include <linux/module.h>
+#include <net/ip.h>
+#include <net/xfrm.h>
+#include <net/esp.h>
+#include <linux/scatterlist.h>
+#include <linux/kernel.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <net/ip6_route.h>
+#include <net/ipv6.h>
+#include <linux/icmpv6.h>
+
+static struct sk_buff **esp6_gro_receive(struct sk_buff **head,
+					 struct sk_buff *skb)
+{
+	int offset = skb_gro_offset(skb);
+	struct xfrm_offload *xo;
+	struct xfrm_state *x;
+	__be32 seq;
+	__be32 spi;
+	int err;
+
+	skb_pull(skb, offset);
+
+	if ((err = xfrm_parse_spi(skb, IPPROTO_ESP, &spi, &seq)) != 0)
+		goto out;
+
+	err = secpath_set(skb);
+	if (err)
+		goto out;
+
+	if (skb->sp->len == XFRM_MAX_DEPTH)
+		goto out;
+
+	x = xfrm_state_lookup(dev_net(skb->dev), skb->mark,
+			      (xfrm_address_t *)&ipv6_hdr(skb)->daddr,
+			      spi, IPPROTO_ESP, AF_INET6);
+	if (!x)
+		goto out;
+
+	skb->sp->xvec[skb->sp->len++] = x;
+	skb->sp->olen++;
+
+	xo = xfrm_offload(skb);
+	if (!xo) {
+		xfrm_state_put(x);
+		goto out;
+	}
+	xo->flags |= XFRM_GRO;
+
+	XFRM_TUNNEL_SKB_CB(skb)->tunnel.ip6 = NULL;
+	XFRM_SPI_SKB_CB(skb)->family = AF_INET6;
+	XFRM_SPI_SKB_CB(skb)->daddroff = offsetof(struct ipv6hdr, daddr);
+	XFRM_SPI_SKB_CB(skb)->seq = seq;
+
+	/* We don't need to handle errors from xfrm_input, it does all
+	 * the error handling and frees the resources on error. */
+	xfrm_input(skb, IPPROTO_ESP, spi, -2);
+
+	return ERR_PTR(-EINPROGRESS);
+out:
+	skb_push(skb, offset);
+	NAPI_GRO_CB(skb)->same_flow = 0;
+	NAPI_GRO_CB(skb)->flush = 1;
+
+	return NULL;
+}
+
+static const struct net_offload esp6_offload = {
+	.callbacks = {
+		.gro_receive = esp6_gro_receive,
+	},
+};
+
+static int __init esp6_offload_init(void)
+{
+	return inet6_add_offload(&esp6_offload, IPPROTO_ESP);
+}
+
+static void __exit esp6_offload_exit(void)
+{
+	inet6_del_offload(&esp6_offload, IPPROTO_ESP);
+}
+
+module_init(esp6_offload_init);
+module_exit(esp6_offload_exit);
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Steffen Klassert <steffen.klassert@secunet.com>");
diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index 662fb2c..08a807b 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -33,6 +33,8 @@ int xfrm6_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi,
 
 int xfrm6_transport_finish(struct sk_buff *skb, int async)
 {
+	struct xfrm_offload *xo = xfrm_offload(skb);
+
 	skb_network_header(skb)[IP6CB(skb)->nhoff] =
 		XFRM_MODE_SKB_CB(skb)->protocol;
 
@@ -44,6 +46,11 @@ int xfrm6_transport_finish(struct sk_buff *skb, int async)
 	ipv6_hdr(skb)->payload_len = htons(skb->len);
 	__skb_push(skb, skb->data - skb_network_header(skb));
 
+	if (xo && (xo->flags & XFRM_GRO)) {
+		skb_mac_header_rebuild(skb);
+		return -1;
+	}
+
 	NF_HOOK(NFPROTO_IPV6, NF_INET_PRE_ROUTING,
 		dev_net(skb->dev), NULL, skb, skb->dev, NULL,
 		ip6_rcv_finish);
diff --git a/net/ipv6/xfrm6_mode_transport.c b/net/ipv6/xfrm6_mode_transport.c
index 4e34410..4439ee4 100644
--- a/net/ipv6/xfrm6_mode_transport.c
+++ b/net/ipv6/xfrm6_mode_transport.c
@@ -47,6 +47,7 @@ static int xfrm6_transport_output(struct xfrm_state *x, struct sk_buff *skb)
 static int xfrm6_transport_input(struct xfrm_state *x, struct sk_buff *skb)
 {
 	int ihl = skb->data - skb_transport_header(skb);
+	struct xfrm_offload *xo = xfrm_offload(skb);
 
 	if (skb->transport_header != skb->network_header) {
 		memmove(skb_transport_header(skb),
@@ -55,7 +56,8 @@ static int xfrm6_transport_input(struct xfrm_state *x, struct sk_buff *skb)
 	}
 	ipv6_hdr(skb)->payload_len = htons(skb->len + ihl -
 					   sizeof(struct ipv6hdr));
-	skb_reset_transport_header(skb);
+	if (!xo || !(xo->flags & XFRM_GRO))
+		skb_reset_transport_header(skb);
 	return 0;
 }
 
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index d2ff712..46bdb4f 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -207,14 +207,23 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 	unsigned int family;
 	int decaps = 0;
 	int async = 0;
+	struct xfrm_offload *xo;
+	bool xfrm_gro = false;
 
-	/* A negative encap_type indicates async resumption. */
 	if (encap_type < 0) {
-		async = 1;
 		x = xfrm_input_state(skb);
-		seq = XFRM_SKB_CB(skb)->seq.input.low;
 		family = x->outer_mode->afinfo->family;
-		goto resume;
+
+		/* An encap_type of -1 indicates async resumption. */
+		if (encap_type == -1) {
+			async = 1;
+			seq = XFRM_SKB_CB(skb)->seq.input.low;
+			goto resume;
+		}
+		/* encap_type < -1 indicates a GRO call. */
+		encap_type = 0;
+		seq = XFRM_SPI_SKB_CB(skb)->seq;
+		goto lock;
 	}
 
 	daddr = (xfrm_address_t *)(skb_network_header(skb) +
@@ -260,6 +269,7 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 
 		skb->sp->xvec[skb->sp->len++] = x;
 
+lock:
 		spin_lock(&x->lock);
 
 		if (unlikely(x->km.state != XFRM_STATE_VALID)) {
@@ -381,7 +391,18 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 		gro_cells_receive(&gro_cells, skb);
 		return 0;
 	} else {
-		return x->inner_mode->afinfo->transport_finish(skb, async);
+		xo = xfrm_offload(skb);
+		if (xo)
+			xfrm_gro = xo->flags & XFRM_GRO;
+
+		err = x->inner_mode->afinfo->transport_finish(skb, async);
+		if (xfrm_gro) {
+			skb_dst_drop(skb);
+			gro_cells_receive(&gro_cells, skb);
+			return err;
+		}
+
+		return err;
 	}
 
 drop_unlock:
-- 
1.9.1
