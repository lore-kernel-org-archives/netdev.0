From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC ipsec-next 5/5] esp: Add a software GRO codepath
Date: Wed, 4 Jan 2017 09:23:50 +0100
Message-ID: <1483518230-6777-6-git-send-email-steffen.klassert@secunet.com>
References: <1483518230-6777-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Ilan Tayari <ilant@mellanox.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:51680 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757419AbdADIZr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Jan 2017 03:25:47 -0500
In-Reply-To: <1483518230-6777-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds GRO callbacks for ESP on ipv4 and ipv6.

In case the GRO layer detects an ESP packet, the
esp{4,6}_gro_receive() function calls the xfrm input layer
which decapsulates the packet and reinject it into
layer 2 by calling netif_rx().

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/Kconfig                |  6 +++
 net/ipv4/Makefile               |  1 +
 net/ipv4/esp4.c                 |  5 +++
 net/ipv4/esp4_offload.c         | 94 +++++++++++++++++++++++++++++++++++++++
 net/ipv4/ip_vti.c               |  4 ++
 net/ipv4/xfrm4_input.c          |  6 +++
 net/ipv4/xfrm4_mode_transport.c |  3 +-
 net/ipv6/Kconfig                |  6 +++
 net/ipv6/Makefile               |  1 +
 net/ipv6/esp6.c                 |  5 +++
 net/ipv6/esp6_offload.c         | 98 +++++++++++++++++++++++++++++++++++++++++
 net/ipv6/xfrm6_input.c          |  5 +++
 net/xfrm/xfrm_input.c           | 27 +++++++++---
 13 files changed, 253 insertions(+), 8 deletions(-)
 create mode 100644 net/ipv4/esp4_offload.c
 create mode 100644 net/ipv6/esp6_offload.c

diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 6e7baaf..27df99f 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -360,6 +360,12 @@ config INET_ESP
 
 	  If unsure, say Y.
 
+config INET_ESP_OFFLOAD
+	tristate "IP: ESP transformation offload"
+	depends on INET_ESP
+	select XFRM_OFFLOAD
+	default n
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
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index b1e2444..4563aeb 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -629,6 +629,11 @@ static int esp_input(struct xfrm_state *x, struct sk_buff *skb)
 			nfrags = 1;
 
 			goto skip_cow;
+		} else if (skb_xfrm_gro(skb)) {
+			nfrags = skb_shinfo(skb)->nr_frags;
+			nfrags++;
+
+			goto skip_cow;
 		} else if (!skb_has_frag_list(skb)) {
 			nfrags = skb_shinfo(skb)->nr_frags;
 			nfrags++;
diff --git a/net/ipv4/esp4_offload.c b/net/ipv4/esp4_offload.c
new file mode 100644
index 0000000..7277d15
--- /dev/null
+++ b/net/ipv4/esp4_offload.c
@@ -0,0 +1,94 @@
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
+	int err;
+	if (NAPI_GRO_CB(skb)->flush)
+		goto out;
+
+	skb_pull(skb, skb_gro_offset(skb));
+	skb->xfrm_gro = 1;
+
+	err = xfrm4_rcv_encap(skb, IPPROTO_ESP, 0, -2);
+	if (err == -EOPNOTSUPP) {
+		skb_push(skb, skb_gro_offset(skb));
+		NAPI_GRO_CB(skb)->same_flow = 0;
+		NAPI_GRO_CB(skb)->flush = 1;
+		skb->xfrm_gro = 0;
+		goto out;
+	}
+
+	return ERR_PTR(-EINPROGRESS);
+out:
+	return NULL;
+}
+
+static int esp4_gro_complete(struct sk_buff *skb, int nhoff)
+{
+	struct xfrm_state *x = xfrm_input_state(skb);
+	struct crypto_aead *aead = x->data;
+	struct ip_esp_hdr *esph = (struct ip_esp_hdr *)(skb->data + nhoff);
+	struct packet_offload *ptype;
+	int err = -ENOENT;
+	__be16 type = skb->protocol;
+
+	rcu_read_lock();
+	ptype = gro_find_complete_by_type(type);
+	if (ptype != NULL)
+		err = ptype->callbacks.gro_complete(skb, nhoff + sizeof(*esph) + crypto_aead_ivsize(aead));
+
+	rcu_read_unlock();
+
+	return err;
+}
+
+static const struct net_offload esp4_offload = {
+	.callbacks = {
+		.gro_receive = esp4_gro_receive,
+		.gro_complete = esp4_gro_complete,
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
diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 8b14f14..f275feb 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -60,6 +60,10 @@ static int vti_input(struct sk_buff *skb, int nexthdr, __be32 spi,
 	tunnel = ip_tunnel_lookup(itn, skb->dev->ifindex, TUNNEL_NO_KEY,
 				  iph->saddr, iph->daddr, 0);
 	if (tunnel) {
+		/* encap_type < -1 indicates a GRO call, we don't support this. */
+		if (encap_type < -1)
+			return -EOPNOTSUPP;
+
 		if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb))
 			goto drop;
 
diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
index 62e1e72..6fe1a68 100644
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -53,6 +53,12 @@ int xfrm4_transport_finish(struct sk_buff *skb, int async)
 	iph->tot_len = htons(skb->len);
 	ip_send_check(iph);
 
+
+	if (skb_xfrm_gro(skb)) {
+		skb_mac_header_rebuild(skb);
+		return 0;
+	}
+
 	NF_HOOK(NFPROTO_IPV4, NF_INET_PRE_ROUTING,
 		dev_net(skb->dev), NULL, skb, skb->dev, NULL,
 		xfrm4_rcv_encap_finish);
diff --git a/net/ipv4/xfrm4_mode_transport.c b/net/ipv4/xfrm4_mode_transport.c
index fd840c7..7b447f3 100644
--- a/net/ipv4/xfrm4_mode_transport.c
+++ b/net/ipv4/xfrm4_mode_transport.c
@@ -50,7 +50,8 @@ static int xfrm4_transport_input(struct xfrm_state *x, struct sk_buff *skb)
 		skb->network_header = skb->transport_header;
 	}
 	ip_hdr(skb)->tot_len = htons(skb->len + ihl);
-	skb_reset_transport_header(skb);
+	if (!skb_xfrm_gro(skb))
+		skb_reset_transport_header(skb);
 	return 0;
 }
 
diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index ec1267e..8b0713b 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -75,6 +75,12 @@ config INET6_ESP
 
 	  If unsure, say Y.
 
+config INET6_ESP_OFFLOAD
+	tristate "IPv6: ESP transformation offload"
+	depends on INET6_ESP
+	select XFRM_OFFLOAD
+	default n
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
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index ff54faa..1cca0f1 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -571,6 +571,11 @@ static int esp6_input(struct xfrm_state *x, struct sk_buff *skb)
 			nfrags = 1;
 
 			goto skip_cow;
+		} else if (skb_xfrm_gro(skb)) {
+			nfrags = skb_shinfo(skb)->nr_frags;
+			nfrags++;
+
+			goto skip_cow;
 		} else if (!skb_has_frag_list(skb)) {
 			nfrags = skb_shinfo(skb)->nr_frags;
 			nfrags++;
diff --git a/net/ipv6/esp6_offload.c b/net/ipv6/esp6_offload.c
new file mode 100644
index 0000000..e0006cf
--- /dev/null
+++ b/net/ipv6/esp6_offload.c
@@ -0,0 +1,98 @@
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
+	int err;
+	if (NAPI_GRO_CB(skb)->flush)
+		goto out;
+
+	skb_pull(skb, skb_gro_offset(skb));
+	skb->xfrm_gro = 1;
+
+	XFRM_SPI_SKB_CB(skb)->family = AF_INET6;
+	XFRM_SPI_SKB_CB(skb)->daddroff = offsetof(struct ipv6hdr, daddr);
+	err = xfrm_input(skb, IPPROTO_ESP, 0, -2);
+	if (err == -EOPNOTSUPP) {
+		skb_push(skb, skb_gro_offset(skb));
+		NAPI_GRO_CB(skb)->same_flow = 0;
+		NAPI_GRO_CB(skb)->flush = 1;
+		skb->xfrm_gro = 0;
+		goto out;
+	}
+
+	return ERR_PTR(-EINPROGRESS);
+out:
+	return NULL;
+}
+
+static int esp6_gro_complete(struct sk_buff *skb, int nhoff)
+{
+	struct xfrm_state *x = xfrm_input_state(skb);
+	struct crypto_aead *aead = x->data;
+	struct ip_esp_hdr *esph = (struct ip_esp_hdr *)(skb->data + nhoff);
+	struct packet_offload *ptype;
+	int err = -ENOENT;
+	__be16 type = skb->protocol;
+
+	rcu_read_lock();
+	ptype = gro_find_complete_by_type(type);
+	if (ptype != NULL)
+		err = ptype->callbacks.gro_complete(skb, nhoff + sizeof(*esph) + crypto_aead_ivsize(aead));
+
+	rcu_read_unlock();
+
+	return err;
+}
+
+static const struct net_offload esp6_offload = {
+	.callbacks = {
+		.gro_receive = esp6_gro_receive,
+		.gro_complete = esp6_gro_complete,
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
index b578956..8ed16c8 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -44,6 +44,11 @@ int xfrm6_transport_finish(struct sk_buff *skb, int async)
 	ipv6_hdr(skb)->payload_len = htons(skb->len);
 	__skb_push(skb, skb->data - skb_network_header(skb));
 
+	if (skb_xfrm_gro(skb)) {
+		skb_mac_header_rebuild(skb);
+		return -1;
+	}
+
 	NF_HOOK(NFPROTO_IPV6, NF_INET_PRE_ROUTING,
 		dev_net(skb->dev), NULL, skb, skb->dev, NULL,
 		ip6_rcv_finish);
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 6e3f025..893263e 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -193,13 +193,17 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 	int decaps = 0;
 	int async = 0;
 
-	/* A negative encap_type indicates async resumption. */
 	if (encap_type < 0) {
-		async = 1;
-		x = xfrm_input_state(skb);
-		seq = XFRM_SKB_CB(skb)->seq.input.low;
-		family = x->outer_mode->afinfo->family;
-		goto resume;
+		/* An encap_type of -1 indicates async resumption. */
+		if (encap_type == -1) {
+			async = 1;
+			x = xfrm_input_state(skb);
+			seq = XFRM_SKB_CB(skb)->seq.input.low;
+			family = x->outer_mode->afinfo->family;
+			goto resume;
+		}
+		/* encap_type < -1 indicates a GRO call. */
+		encap_type = 0;
 	}
 
 	daddr = (xfrm_address_t *)(skb_network_header(skb) +
@@ -374,7 +378,16 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 		netif_rx(skb);
 		return 0;
 	} else {
-		return x->inner_mode->afinfo->transport_finish(skb, async);
+		int xfrm_gro = skb_xfrm_gro(skb);
+
+		err = x->inner_mode->afinfo->transport_finish(skb, async);
+		if (xfrm_gro) {
+			skb_dst_drop(skb);
+			netif_rx(skb);
+			return 0;
+		}
+
+		return err;
 	}
 
 drop_unlock:
-- 
1.9.1
