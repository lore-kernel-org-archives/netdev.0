From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net-next 1/5] xen-netback: add IPv6 checksum offload to guest
Date: Tue, 8 Oct 2013 11:44:37 +0100
Message-ID: <1381229081-17814-2-git-send-email-paul.durrant@citrix.com>
References: <1381229081-17814-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>,
	Wei Liu <wei.liuw2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:25958 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756949Ab3JHKot (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 06:44:49 -0400
In-Reply-To: <1381229081-17814-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check xenstore flag feature-ipv6-csum-offload to determine if a
guest is happy to accept IPv6 packets with only partial checksum.
Also check analogous feature-ip-csum-offload to determone if a
guest is happy to accept IPv4 packets with only partial checksum
as a replacement for a negated feature-no-csum-offload value and
add a comment to deprecate use of feature-no-csum-offload.

Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
Cc: Wei Liu <wei.liuw2@citrix.com>
Cc: David Vrabel <david.vrabel@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
---
 drivers/net/xen-netback/common.h    |    3 ++-
 drivers/net/xen-netback/interface.c |   10 +++++++---
 drivers/net/xen-netback/xenbus.c    |   24 +++++++++++++++++++++++-
 3 files changed, 32 insertions(+), 5 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 5715318..b4a9a3c 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -153,7 +153,8 @@ struct xenvif {
 	u8 can_sg:1;
 	u8 gso:1;
 	u8 gso_prefix:1;
-	u8 csum:1;
+	u8 ip_csum:1;
+	u8 ipv6_csum:1;
 
 	/* Internal feature information. */
 	u8 can_queue:1;	    /* can queue packets for receiver? */
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 01bb854..8e92783 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -216,8 +216,10 @@ static netdev_features_t xenvif_fix_features(struct net_device *dev,
 		features &= ~NETIF_F_SG;
 	if (!vif->gso && !vif->gso_prefix)
 		features &= ~NETIF_F_TSO;
-	if (!vif->csum)
+	if (!vif->ip_csum)
 		features &= ~NETIF_F_IP_CSUM;
+	if (!vif->ipv6_csum)
+		features &= ~NETIF_F_IPV6_CSUM;
 
 	return features;
 }
@@ -306,7 +308,7 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 	vif->domid  = domid;
 	vif->handle = handle;
 	vif->can_sg = 1;
-	vif->csum = 1;
+	vif->ip_csum = 1;
 	vif->dev = dev;
 
 	vif->credit_bytes = vif->remaining_credit = ~0UL;
@@ -316,7 +318,9 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 	vif->credit_timeout.expires = jiffies;
 
 	dev->netdev_ops	= &xenvif_netdev_ops;
-	dev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO;
+	dev->hw_features = NETIF_F_SG |
+		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
+		NETIF_F_TSO;
 	dev->features = dev->hw_features;
 	SET_ETHTOOL_OPS(dev, &xenvif_ethtool_ops);
 
diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index b45bce2..5e45b00 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -567,10 +567,32 @@ static int connect_rings(struct backend_info *be)
 		val = 0;
 	vif->gso_prefix = !!val;
 
+	/* Before feature-ipv6-csum-offload was introduced, checksum offload
+	 * was turned on by a zero value in (or lack of)
+	 * feature-no-csum-offload. Therefore, for compatibility, assume
+	 * that if feature-ip-csum-offload is missing that IP (v4) offload
+	 * is turned on. If this is not the case then the flag will be
+	 * cleared when we subsequently sample feature-no-csum-offload.
+	 */
+	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-ip-csum-offload",
+			 "%d", &val) < 0)
+		val = 1;
+	vif->ip_csum = !!val;
+
+	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-ipv6-csum-offload",
+			 "%d", &val) < 0)
+		val = 0;
+	vif->ipv6_csum = !!val;
+
+	/* This is deprecated. Frontends should set IP v4 and v6 checksum
+	 * offload using feature-ip-csum-offload and
+	 * feature-ipv6-csum-offload respectively.
+	 */
 	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-no-csum-offload",
 			 "%d", &val) < 0)
 		val = 0;
-	vif->csum = !val;
+	if (val)
+		vif->ip_csum = 0;
 
 	/* Map the shared frame, irq etc. */
 	err = xenvif_connect(vif, tx_ring_ref, rx_ring_ref,
-- 
1.7.10.4
