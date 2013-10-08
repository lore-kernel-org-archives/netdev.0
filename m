From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net-next v2 5/5] xen-netback: enable IPv6 TCP GSO to the guest
Date: Tue, 8 Oct 2013 11:58:16 +0100
Message-ID: <1381229896-18657-6-git-send-email-paul.durrant@citrix.com>
References: <1381229896-18657-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:7529 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756053Ab3JHK6W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Oct 2013 06:58:22 -0400
In-Reply-To: <1381229896-18657-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds code to handle SKB_GSO_TCPV6 skbs and construct appropriate
extra or prefix segments to pass the large packet to the frontend. New
xenstore flags, feature-gso-tcpv6 and feature-gso-tcpv6-prefix, are sampled
to determine if the frontend is capable of handling such packets.

Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
Cc: Wei Liu <wei.liu2@citrix.com>
Cc: David Vrabel <david.vrabel@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
---
 drivers/net/xen-netback/common.h    |    6 +++--
 drivers/net/xen-netback/interface.c |    8 ++++--
 drivers/net/xen-netback/netback.c   |   47 +++++++++++++++++++++++++++--------
 drivers/net/xen-netback/xenbus.c    |   29 +++++++++++++++++++--
 4 files changed, 74 insertions(+), 16 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index b4a9a3c..720b1ca 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -87,6 +87,7 @@ struct pending_tx_info {
 struct xenvif_rx_meta {
 	int id;
 	int size;
+	int gso_type;
 	int gso_size;
 };
 
@@ -150,9 +151,10 @@ struct xenvif {
 	u8               fe_dev_addr[6];
 
 	/* Frontend feature information. */
+	int gso_mask;
+	int gso_prefix_mask;
+
 	u8 can_sg:1;
-	u8 gso:1;
-	u8 gso_prefix:1;
 	u8 ip_csum:1;
 	u8 ipv6_csum:1;
 
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index cb0d8ea..3d11387 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -214,8 +214,12 @@ static netdev_features_t xenvif_fix_features(struct net_device *dev,
 
 	if (!vif->can_sg)
 		features &= ~NETIF_F_SG;
-	if (!vif->gso && !vif->gso_prefix)
+	if (~(vif->gso_mask | vif->gso_prefix_mask) &
+	    (1 << XEN_NETIF_GSO_TYPE_TCPV4))
 		features &= ~NETIF_F_TSO;
+	if (~(vif->gso_mask | vif->gso_prefix_mask) &
+	    (1 << XEN_NETIF_GSO_TYPE_TCPV6))
+		features &= ~NETIF_F_TSO6;
 	if (!vif->ip_csum)
 		features &= ~NETIF_F_IP_CSUM;
 	if (!vif->ipv6_csum)
@@ -320,7 +324,7 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 	dev->netdev_ops	= &xenvif_netdev_ops;
 	dev->hw_features = NETIF_F_SG |
 		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
-		NETIF_F_TSO;
+		NETIF_F_TSO | NETIF_F_TSO6;
 	dev->features = dev->hw_features | NETIF_F_RXCSUM;
 	SET_ETHTOOL_OPS(dev, &xenvif_ethtool_ops);
 
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index ac42f73..ee0d55c 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -140,7 +140,7 @@ static int max_required_rx_slots(struct xenvif *vif)
 	int max = DIV_ROUND_UP(vif->dev->mtu, PAGE_SIZE);
 
 	/* XXX FIXME: RX path dependent on MAX_SKB_FRAGS */
-	if (vif->can_sg || vif->gso || vif->gso_prefix)
+	if (vif->can_sg || vif->gso_mask || vif->gso_prefix_mask)
 		max += MAX_SKB_FRAGS + 1; /* extra_info + frags */
 
 	return max;
@@ -334,6 +334,7 @@ static void xenvif_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
 	struct gnttab_copy *copy_gop;
 	struct xenvif_rx_meta *meta;
 	unsigned long bytes;
+	int gso_type;
 
 	/* Data must not cross a page boundary. */
 	BUG_ON(size + offset > PAGE_SIZE<<compound_order(page));
@@ -392,7 +393,14 @@ static void xenvif_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
 		}
 
 		/* Leave a gap for the GSO descriptor. */
-		if (*head && skb_shinfo(skb)->gso_size && !vif->gso_prefix)
+		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4)
+			gso_type = XEN_NETIF_GSO_TYPE_TCPV4;
+		else if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
+			gso_type = XEN_NETIF_GSO_TYPE_TCPV6;
+		else
+			gso_type = 0;
+
+		if (*head && ((1 << gso_type) & vif->gso_prefix_mask))
 			vif->rx.req_cons++;
 
 		*head = 0; /* There must be something in this buffer now. */
@@ -423,14 +431,28 @@ static int xenvif_gop_skb(struct sk_buff *skb,
 	unsigned char *data;
 	int head = 1;
 	int old_meta_prod;
+	int gso_type;
+	int gso_size;
 
 	old_meta_prod = npo->meta_prod;
 
+	if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4) {
+		gso_type = XEN_NETIF_GSO_TYPE_TCPV4;
+		gso_size = skb_shinfo(skb)->gso_size;
+	} else if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6) {
+		gso_type = XEN_NETIF_GSO_TYPE_TCPV6;
+		gso_size = skb_shinfo(skb)->gso_size;
+	} else {
+		gso_type = 0;
+		gso_size = 0;
+	}
+
 	/* Set up a GSO prefix descriptor, if necessary */
-	if (skb_shinfo(skb)->gso_size && vif->gso_prefix) {
+	if ((1 << gso_type) & vif->gso_prefix_mask) {
 		req = RING_GET_REQUEST(&vif->rx, vif->rx.req_cons++);
 		meta = npo->meta + npo->meta_prod++;
-		meta->gso_size = skb_shinfo(skb)->gso_size;
+		meta->gso_type = gso_type;
+		meta->gso_size = gso_size;
 		meta->size = 0;
 		meta->id = req->id;
 	}
@@ -438,10 +460,13 @@ static int xenvif_gop_skb(struct sk_buff *skb,
 	req = RING_GET_REQUEST(&vif->rx, vif->rx.req_cons++);
 	meta = npo->meta + npo->meta_prod++;
 
-	if (!vif->gso_prefix)
-		meta->gso_size = skb_shinfo(skb)->gso_size;
-	else
+	if ((1 << gso_type) & vif->gso_mask) {
+		meta->gso_type = gso_type;
+		meta->gso_size = gso_size;
+	} else {
+		meta->gso_type = 0;
 		meta->gso_size = 0;
+	}
 
 	meta->size = 0;
 	meta->id = req->id;
@@ -587,7 +612,8 @@ void xenvif_rx_action(struct xenvif *vif)
 
 		vif = netdev_priv(skb->dev);
 
-		if (vif->meta[npo.meta_cons].gso_size && vif->gso_prefix) {
+		if ((1 << vif->meta[npo.meta_cons].gso_type) &
+		    vif->gso_prefix_mask) {
 			resp = RING_GET_RESPONSE(&vif->rx,
 						 vif->rx.rsp_prod_pvt++);
 
@@ -624,7 +650,8 @@ void xenvif_rx_action(struct xenvif *vif)
 					vif->meta[npo.meta_cons].size,
 					flags);
 
-		if (vif->meta[npo.meta_cons].gso_size && !vif->gso_prefix) {
+		if ((1 << vif->meta[npo.meta_cons].gso_type) &
+		    vif->gso_mask) {
 			struct xen_netif_extra_info *gso =
 				(struct xen_netif_extra_info *)
 				RING_GET_RESPONSE(&vif->rx,
@@ -632,8 +659,8 @@ void xenvif_rx_action(struct xenvif *vif)
 
 			resp->flags |= XEN_NETRXF_extra_info;
 
+			gso->u.gso.type = vif->meta[npo.meta_cons].gso_type;
 			gso->u.gso.size = vif->meta[npo.meta_cons].gso_size;
-			gso->u.gso.type = XEN_NETIF_GSO_TYPE_TCPV4;
 			gso->u.gso.pad = 0;
 			gso->u.gso.features = 0;
 
diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index 389fa72..4894256 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -573,15 +573,40 @@ static int connect_rings(struct backend_info *be)
 		val = 0;
 	vif->can_sg = !!val;
 
+	vif->gso_mask = 0;
+	vif->gso_prefix_mask = 0;
+
 	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-gso-tcpv4",
 			 "%d", &val) < 0)
 		val = 0;
-	vif->gso = !!val;
+	if (val)
+		vif->gso_mask = 1 << XEN_NETIF_GSO_TYPE_TCPV4;
 
 	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-gso-tcpv4-prefix",
 			 "%d", &val) < 0)
 		val = 0;
-	vif->gso_prefix = !!val;
+	if (val)
+		vif->gso_prefix_mask = 1 << XEN_NETIF_GSO_TYPE_TCPV4;
+
+	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-gso-tcpv6",
+			 "%d", &val) < 0)
+		val = 0;
+	if (val)
+		vif->gso_mask = 1 << XEN_NETIF_GSO_TYPE_TCPV6;
+
+	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-gso-tcpv6-prefix",
+			 "%d", &val) < 0)
+		val = 0;
+	if (val)
+		vif->gso_prefix_mask = 1 << XEN_NETIF_GSO_TYPE_TCPV6;
+
+	if (vif->gso_mask & vif->gso_prefix_mask) {
+		xenbus_dev_fatal(dev, err,
+				 "%s: gso and gso prefix flags are not "
+				 "mutually exclusive",
+				 dev->otherend);
+		return -EOPNOTSUPP;
+	}
 
 	/* Before feature-ipv6-csum-offload was introduced, checksum offload
 	 * was turned on by a zero value in (or lack of)
-- 
1.7.10.4
