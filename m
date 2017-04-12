From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC ipsec-next 04/14] xfrm: Add mode handlers for IPsec on layer 2
Date: Wed, 12 Apr 2017 08:26:43 +0200
Message-ID: <1491978413-5700-5-git-send-email-steffen.klassert@secunet.com>
References: <1491978413-5700-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        Ilan Tayari <ilant@mellanox.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:57550 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752278AbdDLG2D (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 02:28:03 -0400
In-Reply-To: <1491978413-5700-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a gso_segment and xmit callback for the
xfrm_mode and implement these functions for tunnel and
transport mode.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h              | 10 ++++++++++
 net/ipv4/xfrm4_mode_transport.c | 32 ++++++++++++++++++++++++++++++++
 net/ipv4/xfrm4_mode_tunnel.c    | 25 +++++++++++++++++++++++++
 net/ipv6/xfrm6_mode_transport.c | 33 +++++++++++++++++++++++++++++++++
 net/ipv6/xfrm6_mode_tunnel.c    | 24 ++++++++++++++++++++++++
 5 files changed, 124 insertions(+)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index ac984da..54515d9 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -444,6 +444,16 @@ struct xfrm_mode {
 	 */
 	int (*output)(struct xfrm_state *x, struct sk_buff *skb);
 
+	/*
+	 * Adjust pointers into the packet and do GSO segmentation.
+	 */
+	struct sk_buff *(*gso_segment)(struct xfrm_state *x, struct sk_buff *skb, netdev_features_t features);
+
+	/*
+	 * Adjust pointers into the packet when IPsec is done at layer2.
+	 */
+	void (*xmit)(struct xfrm_state *x, struct sk_buff *skb);
+
 	struct xfrm_state_afinfo *afinfo;
 	struct module *owner;
 	unsigned int encap;
diff --git a/net/ipv4/xfrm4_mode_transport.c b/net/ipv4/xfrm4_mode_transport.c
index 4acc050..6c2411d 100644
--- a/net/ipv4/xfrm4_mode_transport.c
+++ b/net/ipv4/xfrm4_mode_transport.c
@@ -12,6 +12,7 @@
 #include <net/dst.h>
 #include <net/ip.h>
 #include <net/xfrm.h>
+#include <net/protocol.h>
 
 /* Add encapsulation header.
  *
@@ -56,9 +57,40 @@ static int xfrm4_transport_input(struct xfrm_state *x, struct sk_buff *skb)
 	return 0;
 }
 
+static struct sk_buff *xfrm4_transport_gso_segment(struct xfrm_state *x,
+						   struct sk_buff *skb,
+						   netdev_features_t features)
+{
+	const struct net_offload *ops;
+	struct sk_buff *segs = ERR_PTR(-EINVAL);
+	struct xfrm_offload *xo = xfrm_offload(skb);
+
+	skb->transport_header += x->props.header_len;
+	ops = rcu_dereference(inet_offloads[xo->proto]);
+	if (likely(ops && ops->callbacks.gso_segment))
+		segs = ops->callbacks.gso_segment(skb, features);
+
+	return segs;
+}
+
+static void xfrm4_transport_xmit(struct xfrm_state *x, struct sk_buff *skb)
+{
+	struct xfrm_offload *xo = xfrm_offload(skb);
+
+	skb_reset_mac_len(skb);
+	pskb_pull(skb, skb->mac_len + sizeof(struct iphdr) + x->props.header_len);
+
+	if (xo->flags & XFRM_GSO_SEGMENT) {
+		 skb_reset_transport_header(skb);
+		 skb->transport_header -= x->props.header_len;
+	}
+}
+
 static struct xfrm_mode xfrm4_transport_mode = {
 	.input = xfrm4_transport_input,
 	.output = xfrm4_transport_output,
+	.gso_segment = xfrm4_transport_gso_segment,
+	.xmit = xfrm4_transport_xmit,
 	.owner = THIS_MODULE,
 	.encap = XFRM_MODE_TRANSPORT,
 };
diff --git a/net/ipv4/xfrm4_mode_tunnel.c b/net/ipv4/xfrm4_mode_tunnel.c
index 35feda6..d3f2434 100644
--- a/net/ipv4/xfrm4_mode_tunnel.c
+++ b/net/ipv4/xfrm4_mode_tunnel.c
@@ -96,11 +96,36 @@ static int xfrm4_mode_tunnel_input(struct xfrm_state *x, struct sk_buff *skb)
 	return err;
 }
 
+static struct sk_buff *xfrm4_mode_tunnel_gso_segment(struct xfrm_state *x,
+						     struct sk_buff *skb,
+						     netdev_features_t features)
+{
+	__skb_push(skb, skb->mac_len);
+	return skb_mac_gso_segment(skb, features);
+
+}
+
+static void xfrm4_mode_tunnel_xmit(struct xfrm_state *x, struct sk_buff *skb)
+{
+	struct xfrm_offload *xo = xfrm_offload(skb);
+
+	if (xo->flags & XFRM_GSO_SEGMENT) {
+		skb->network_header = skb->network_header - x->props.header_len;
+		skb->transport_header = skb->network_header +
+					sizeof(struct iphdr);
+	}
+
+	skb_reset_mac_len(skb);
+	pskb_pull(skb, skb->mac_len + x->props.header_len);
+}
+
 static struct xfrm_mode xfrm4_tunnel_mode = {
 	.input2 = xfrm4_mode_tunnel_input,
 	.input = xfrm_prepare_input,
 	.output2 = xfrm4_mode_tunnel_output,
 	.output = xfrm4_prepare_output,
+	.gso_segment = xfrm4_mode_tunnel_gso_segment,
+	.xmit = xfrm4_mode_tunnel_xmit,
 	.owner = THIS_MODULE,
 	.encap = XFRM_MODE_TUNNEL,
 	.flags = XFRM_MODE_FLAG_TUNNEL,
diff --git a/net/ipv6/xfrm6_mode_transport.c b/net/ipv6/xfrm6_mode_transport.c
index 4439ee4..eb9b36b 100644
--- a/net/ipv6/xfrm6_mode_transport.c
+++ b/net/ipv6/xfrm6_mode_transport.c
@@ -13,6 +13,7 @@
 #include <net/dst.h>
 #include <net/ipv6.h>
 #include <net/xfrm.h>
+#include <net/protocol.h>
 
 /* Add encapsulation header.
  *
@@ -61,9 +62,41 @@ static int xfrm6_transport_input(struct xfrm_state *x, struct sk_buff *skb)
 	return 0;
 }
 
+static struct sk_buff *xfrm4_transport_gso_segment(struct xfrm_state *x,
+						   struct sk_buff *skb,
+						   netdev_features_t features)
+{
+	const struct net_offload *ops;
+	struct sk_buff *segs = ERR_PTR(-EINVAL);
+	struct xfrm_offload *xo = xfrm_offload(skb);
+
+	skb->transport_header += x->props.header_len;
+	ops = rcu_dereference(inet6_offloads[xo->proto]);
+	if (likely(ops && ops->callbacks.gso_segment))
+		segs = ops->callbacks.gso_segment(skb, features);
+
+	return segs;
+}
+
+static void xfrm6_transport_xmit(struct xfrm_state *x, struct sk_buff *skb)
+{
+	struct xfrm_offload *xo = xfrm_offload(skb);
+
+	skb_reset_mac_len(skb);
+	pskb_pull(skb, skb->mac_len + sizeof(struct ipv6hdr) + x->props.header_len);
+
+	if (xo->flags & XFRM_GSO_SEGMENT) {
+		 skb_reset_transport_header(skb);
+		 skb->transport_header -= x->props.header_len;
+	}
+}
+
+
 static struct xfrm_mode xfrm6_transport_mode = {
 	.input = xfrm6_transport_input,
 	.output = xfrm6_transport_output,
+	.gso_segment = xfrm4_transport_gso_segment,
+	.xmit = xfrm6_transport_xmit,
 	.owner = THIS_MODULE,
 	.encap = XFRM_MODE_TRANSPORT,
 };
diff --git a/net/ipv6/xfrm6_mode_tunnel.c b/net/ipv6/xfrm6_mode_tunnel.c
index 372855e..19a60fc 100644
--- a/net/ipv6/xfrm6_mode_tunnel.c
+++ b/net/ipv6/xfrm6_mode_tunnel.c
@@ -96,11 +96,35 @@ static int xfrm6_mode_tunnel_input(struct xfrm_state *x, struct sk_buff *skb)
 	return err;
 }
 
+static struct sk_buff *xfrm6_mode_tunnel_gso_segment(struct xfrm_state *x,
+						     struct sk_buff *skb,
+						     netdev_features_t features)
+{
+	__skb_push(skb, skb->mac_len);
+	return skb_mac_gso_segment(skb, features);
+
+}
+
+static void xfrm6_mode_tunnel_xmit(struct xfrm_state *x, struct sk_buff *skb)
+{
+	struct xfrm_offload *xo = xfrm_offload(skb);
+
+	if (xo->flags & XFRM_GSO_SEGMENT) {
+		skb->network_header = skb->network_header - x->props.header_len;
+		skb->transport_header = skb->network_header + sizeof(struct ipv6hdr);
+	}
+
+	skb_reset_mac_len(skb);
+	pskb_pull(skb, skb->mac_len + x->props.header_len);
+}
+
 static struct xfrm_mode xfrm6_tunnel_mode = {
 	.input2 = xfrm6_mode_tunnel_input,
 	.input = xfrm_prepare_input,
 	.output2 = xfrm6_mode_tunnel_output,
 	.output = xfrm6_prepare_output,
+	.gso_segment = xfrm6_mode_tunnel_gso_segment,
+	.xmit = xfrm6_mode_tunnel_xmit,
 	.owner = THIS_MODULE,
 	.encap = XFRM_MODE_TUNNEL,
 	.flags = XFRM_MODE_FLAG_TUNNEL,
-- 
2.7.4
