From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC 03/13] esp: Add a software GRO codepath
Date: Thu, 4 Feb 2016 07:36:56 +0100
Message-ID: <1454567826-13018-4-git-send-email-steffen.klassert@secunet.com>
References: <1454567826-13018-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	<sowmini.varadhan@oracle.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:36685 "EHLO
	h-62.96.220.36.host.de.colt.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756622AbcBDHFv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 02:05:51 -0500
In-Reply-To: <1454567826-13018-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds GRO callbacks for ESP on ipv4 and ipv6.

In case the GRO layer detects an ESP packet, the
esp4_gro_receive() function calls the xfrm input layer
which decapsulates the packet and reinject it into
layer 2 by calling netif_rx(). We use on bit of the
sk_buff to flag xfrm_gro. If this bit is set, the
process_backlog() function calls napi_gro_receive()
intead of __netif_receive_skb(). We could avoid the
usage of xfrm_gro if we could call napi_gro_receive()
unconditionaly from process_backlog().

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/linux/netdevice.h       |  1 +
 include/linux/skbuff.h          |  3 +-
 net/core/dev.c                  | 14 ++++++-
 net/ipv4/Makefile               |  2 +-
 net/ipv4/esp4_offload.c         | 77 +++++++++++++++++++++++++++++++++++++++
 net/ipv4/xfrm4_input.c          |  3 ++
 net/ipv4/xfrm4_mode_transport.c |  3 +-
 net/ipv6/Makefile               |  2 +-
 net/ipv6/esp6_offload.c         | 81 +++++++++++++++++++++++++++++++++++++++++
 net/ipv6/xfrm6_input.c          |  3 ++
 net/xfrm/xfrm_input.c           |  8 +++-
 11 files changed, 191 insertions(+), 6 deletions(-)
 create mode 100644 net/ipv4/esp4_offload.c
 create mode 100644 net/ipv6/esp6_offload.c

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 289c231..6fd1f1d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -338,6 +338,7 @@ enum gro_result {
 	GRO_HELD,
 	GRO_NORMAL,
 	GRO_DROP,
+	GRO_CONSUMED,
 };
 typedef enum gro_result gro_result_t;
 
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 11f935c..b84245f 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -721,7 +721,8 @@ struct sk_buff {
 	__u8			ipvs_property:1;
 	__u8			inner_protocol_type:1;
 	__u8			remcsum_offload:1;
-	/* 3 or 5 bit hole */
+	__u8			xfrm_gro:1;
+	/* 2 or 4 bit hole */
 
 #ifdef CONFIG_NET_SCHED
 	__u16			tc_index;	/* traffic control index */
diff --git a/net/core/dev.c b/net/core/dev.c
index 8cba3d8..1a456ea 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4453,6 +4453,11 @@ static enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff
 	}
 	rcu_read_unlock();
 
+	if (PTR_ERR(pp) == -EINPROGRESS) {
+		ret = GRO_CONSUMED;
+		goto ok;
+	}
+
 	if (&ptype->list == head)
 		goto normal;
 
@@ -4559,6 +4564,7 @@ static gro_result_t napi_skb_finish(gro_result_t ret, struct sk_buff *skb)
 
 	case GRO_HELD:
 	case GRO_MERGED:
+	case GRO_CONSUMED:
 		break;
 	}
 
@@ -4629,6 +4635,7 @@ static gro_result_t napi_frags_finish(struct napi_struct *napi,
 		break;
 
 	case GRO_MERGED:
+	case GRO_CONSUMED:
 		break;
 	}
 
@@ -4770,7 +4777,12 @@ static int process_backlog(struct napi_struct *napi, int quota)
 		while ((skb = __skb_dequeue(&sd->process_queue))) {
 			rcu_read_lock();
 			local_irq_enable();
-			__netif_receive_skb(skb);
+
+			if (skb->xfrm_gro)
+				napi_gro_receive(napi, skb);
+			else
+				__netif_receive_skb(skb);
+
 			rcu_read_unlock();
 			local_irq_disable();
 			input_queue_head_incr(sd);
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index 62c049b..48d3390 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -28,7 +28,7 @@ obj-$(CONFIG_NET_UDP_TUNNEL) += udp_tunnel.o
 obj-$(CONFIG_NET_IPVTI) += ip_vti.o
 obj-$(CONFIG_SYN_COOKIES) += syncookies.o
 obj-$(CONFIG_INET_AH) += ah4.o
-obj-$(CONFIG_INET_ESP) += esp4.o
+obj-$(CONFIG_INET_ESP) += esp4.o esp4_offload.o
 obj-$(CONFIG_INET_IPCOMP) += ipcomp.o
 obj-$(CONFIG_INET_XFRM_TUNNEL) += xfrm4_tunnel.o
 obj-$(CONFIG_INET_XFRM_MODE_BEET) += xfrm4_mode_beet.o
diff --git a/net/ipv4/esp4_offload.c b/net/ipv4/esp4_offload.c
new file mode 100644
index 0000000..f2b0d6d
--- /dev/null
+++ b/net/ipv4/esp4_offload.c
@@ -0,0 +1,77 @@
+/*
+ * IPV4 GSO/GRO offload support
+ * Linux INET implementation
+ *
+ * Copyright (C) 2015 secunet Security Networks AG
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
+	if (NAPI_GRO_CB(skb)->flush)
+		goto out;
+
+	skb_pull(skb, skb_gro_offset(skb));
+	skb->xfrm_gro = 1;
+
+	xfrm4_rcv_encap(skb, IPPROTO_ESP, 0, 0);
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
+device_initcall(esp4_offload_init);
diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
index 62e1e72..0fbc40f 100644
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -53,6 +53,9 @@ int xfrm4_transport_finish(struct sk_buff *skb, int async)
 	iph->tot_len = htons(skb->len);
 	ip_send_check(iph);
 
+	if (skb->xfrm_gro)
+		return 0;
+
 	NF_HOOK(NFPROTO_IPV4, NF_INET_PRE_ROUTING,
 		dev_net(skb->dev), NULL, skb, skb->dev, NULL,
 		xfrm4_rcv_encap_finish);
diff --git a/net/ipv4/xfrm4_mode_transport.c b/net/ipv4/xfrm4_mode_transport.c
index fd840c7..ce59c34 100644
--- a/net/ipv4/xfrm4_mode_transport.c
+++ b/net/ipv4/xfrm4_mode_transport.c
@@ -50,7 +50,8 @@ static int xfrm4_transport_input(struct xfrm_state *x, struct sk_buff *skb)
 		skb->network_header = skb->transport_header;
 	}
 	ip_hdr(skb)->tot_len = htons(skb->len + ihl);
-	skb_reset_transport_header(skb);
+	if (!skb->xfrm_gro)
+		skb_reset_transport_header(skb);
 	return 0;
 }
 
diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index 2fbd90b..64e3c4c 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -25,7 +25,7 @@ ipv6-$(CONFIG_SYN_COOKIES) += syncookies.o
 ipv6-objs += $(ipv6-y)
 
 obj-$(CONFIG_INET6_AH) += ah6.o
-obj-$(CONFIG_INET6_ESP) += esp6.o
+obj-$(CONFIG_INET6_ESP) += esp6.o esp6_offload.o
 obj-$(CONFIG_INET6_IPCOMP) += ipcomp6.o
 obj-$(CONFIG_INET6_XFRM_TUNNEL) += xfrm6_tunnel.o
 obj-$(CONFIG_INET6_TUNNEL) += tunnel6.o
diff --git a/net/ipv6/esp6_offload.c b/net/ipv6/esp6_offload.c
new file mode 100644
index 0000000..54bcd61
--- /dev/null
+++ b/net/ipv6/esp6_offload.c
@@ -0,0 +1,81 @@
+/*
+ * IPV6 GSO/GRO offload support
+ * Linux INET implementation
+ *
+ * Copyright (C) 2015 secunet Security Networks AG
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
+	if (NAPI_GRO_CB(skb)->flush)
+		goto out;
+
+	skb_pull(skb, skb_gro_offset(skb));
+	skb->xfrm_gro = 1;
+
+	XFRM_SPI_SKB_CB(skb)->family = AF_INET6;
+	XFRM_SPI_SKB_CB(skb)->daddroff = offsetof(struct ipv6hdr, daddr);
+	xfrm_input(skb, IPPROTO_ESP, 0, 0);
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
+device_initcall(esp6_offload_init);
diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index 0eaab1f..d0c73f0 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -42,6 +42,9 @@ int xfrm6_transport_finish(struct sk_buff *skb, int async)
 	ipv6_hdr(skb)->payload_len = htons(skb->len);
 	__skb_push(skb, skb->data - skb_network_header(skb));
 
+	if (skb->xfrm_gro)
+		return -1;
+
 	NF_HOOK(NFPROTO_IPV6, NF_INET_PRE_ROUTING,
 		dev_net(skb->dev), NULL, skb, skb->dev, NULL,
 		ip6_rcv_finish);
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index ad7f5b3..aa56252 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -371,7 +371,13 @@ resume:
 		netif_rx(skb);
 		return 0;
 	} else {
-		return x->inner_mode->afinfo->transport_finish(skb, async);
+		err = x->inner_mode->afinfo->transport_finish(skb, async);
+		if (skb->xfrm_gro) {
+			netif_rx(skb);
+			return 0;
+		}
+
+		return err;
 	}
 
 drop_unlock:
-- 
1.9.1
