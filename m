From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net-next v2] xen-netfront: add support for IPv6 offloads
Date: Wed, 15 Jan 2014 17:30:33 +0000
Message-ID: <1389807033-11105-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:33736 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751992AbaAORag (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jan 2014 12:30:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for IPv6 checksum offload and GSO when those
features are available in the backend.

Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: David Vrabel <david.vrabel@citrix.com>
---
v2:
- Use xenbus_write rather than xenbus_printf

 drivers/net/xen-netfront.c |   48 +++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 43 insertions(+), 5 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index c41537b..d7bee8a 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -617,7 +617,9 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		tx->flags |= XEN_NETTXF_extra_info;
 
 		gso->u.gso.size = skb_shinfo(skb)->gso_size;
-		gso->u.gso.type = XEN_NETIF_GSO_TYPE_TCPV4;
+		gso->u.gso.type = (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6) ?
+			XEN_NETIF_GSO_TYPE_TCPV6 :
+			XEN_NETIF_GSO_TYPE_TCPV4;
 		gso->u.gso.pad = 0;
 		gso->u.gso.features = 0;
 
@@ -809,15 +811,18 @@ static int xennet_set_skb_gso(struct sk_buff *skb,
 		return -EINVAL;
 	}
 
-	/* Currently only TCPv4 S.O. is supported. */
-	if (gso->u.gso.type != XEN_NETIF_GSO_TYPE_TCPV4) {
+	if (gso->u.gso.type != XEN_NETIF_GSO_TYPE_TCPV4 &&
+	    gso->u.gso.type != XEN_NETIF_GSO_TYPE_TCPV6) {
 		if (net_ratelimit())
 			pr_warn("Bad GSO type %d\n", gso->u.gso.type);
 		return -EINVAL;
 	}
 
 	skb_shinfo(skb)->gso_size = gso->u.gso.size;
-	skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
+	skb_shinfo(skb)->gso_type =
+		(gso->u.gso.type == XEN_NETIF_GSO_TYPE_TCPV4) ?
+		SKB_GSO_TCPV4 :
+		SKB_GSO_TCPV6;
 
 	/* Header must be checked, and gso_segs computed. */
 	skb_shinfo(skb)->gso_type |= SKB_GSO_DODGY;
@@ -1191,6 +1196,15 @@ static netdev_features_t xennet_fix_features(struct net_device *dev,
 			features &= ~NETIF_F_SG;
 	}
 
+	if (features & NETIF_F_IPV6_CSUM) {
+		if (xenbus_scanf(XBT_NIL, np->xbdev->otherend,
+				 "feature-ipv6-csum-offload", "%d", &val) < 0)
+			val = 0;
+
+		if (!val)
+			features &= ~NETIF_F_IPV6_CSUM;
+	}
+
 	if (features & NETIF_F_TSO) {
 		if (xenbus_scanf(XBT_NIL, np->xbdev->otherend,
 				 "feature-gso-tcpv4", "%d", &val) < 0)
@@ -1200,6 +1214,15 @@ static netdev_features_t xennet_fix_features(struct net_device *dev,
 			features &= ~NETIF_F_TSO;
 	}
 
+	if (features & NETIF_F_TSO6) {
+		if (xenbus_scanf(XBT_NIL, np->xbdev->otherend,
+				 "feature-gso-tcpv6", "%d", &val) < 0)
+			val = 0;
+
+		if (!val)
+			features &= ~NETIF_F_TSO6;
+	}
+
 	return features;
 }
 
@@ -1338,7 +1361,9 @@ static struct net_device *xennet_create_dev(struct xenbus_device *dev)
 	netif_napi_add(netdev, &np->napi, xennet_poll, 64);
 	netdev->features        = NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
 				  NETIF_F_GSO_ROBUST;
-	netdev->hw_features	= NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_TSO;
+	netdev->hw_features	= NETIF_F_SG |
+				  NETIF_F_IPV6_CSUM |
+				  NETIF_F_TSO | NETIF_F_TSO6;
 
 	/*
          * Assume that all hw features are available for now. This set
@@ -1716,6 +1741,19 @@ again:
 		goto abort_transaction;
 	}
 
+	err = xenbus_write(xbt, dev->nodename, "feature-gso-tcpv6", "1");
+	if (err) {
+		message = "writing feature-gso-tcpv6";
+		goto abort_transaction;
+	}
+
+	err = xenbus_write(xbt, dev->nodename, "feature-ipv6-csum-offload",
+			   "1");
+	if (err) {
+		message = "writing feature-ipv6-csum-offload";
+		goto abort_transaction;
+	}
+
 	err = xenbus_transaction_end(xbt, 0);
 	if (err) {
 		if (err == -EAGAIN)
-- 
1.7.10.4
