From: Juergen Gross <jgross@suse.com>
Subject: [PATCH 07/12] xen: make use of xenbus_read_unsigned() in xen-netfront
Date: Mon, 31 Oct 2016 17:48:25 +0100
Message-ID: <1477932510-28594-8-git-send-email-jgross@suse.com>
References: <1477932510-28594-1-git-send-email-jgross@suse.com>
Cc: david.vrabel@citrix.com, boris.ostrovsky@oracle.com,
        Juergen Gross <jgross@suse.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, xen-devel@lists.xen.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1477932510-28594-1-git-send-email-jgross@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use xenbus_read_unsigned() instead of xenbus_scanf() when possible.
This requires to change the type of some reads from int to unsigned,
but these cases have been wrong before: negative values are not allowed
for the modified cases.

Cc: netdev@vger.kernel.org

Signed-off-by: Juergen Gross <jgross@suse.com>
---
 drivers/net/xen-netfront.c | 67 +++++++++++++---------------------------------
 1 file changed, 18 insertions(+), 49 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index e17879d..95d664e 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1169,43 +1169,23 @@ static netdev_features_t xennet_fix_features(struct net_device *dev,
 	netdev_features_t features)
 {
 	struct netfront_info *np = netdev_priv(dev);
-	int val;
 
-	if (features & NETIF_F_SG) {
-		if (xenbus_scanf(XBT_NIL, np->xbdev->otherend, "feature-sg",
-				 "%d", &val) < 0)
-			val = 0;
+	if (features & NETIF_F_SG &&
+	    !xenbus_read_unsigned(np->xbdev->otherend, "feature-sg", 0))
+		features &= ~NETIF_F_SG;
 
-		if (!val)
-			features &= ~NETIF_F_SG;
-	}
+	if (features & NETIF_F_IPV6_CSUM &&
+	    !xenbus_read_unsigned(np->xbdev->otherend,
+				  "feature-ipv6-csum-offload", 0))
+		features &= ~NETIF_F_IPV6_CSUM;
 
-	if (features & NETIF_F_IPV6_CSUM) {
-		if (xenbus_scanf(XBT_NIL, np->xbdev->otherend,
-				 "feature-ipv6-csum-offload", "%d", &val) < 0)
-			val = 0;
+	if (features & NETIF_F_TSO &&
+	    !xenbus_read_unsigned(np->xbdev->otherend, "feature-gso-tcpv4", 0))
+		features &= ~NETIF_F_TSO;
 
-		if (!val)
-			features &= ~NETIF_F_IPV6_CSUM;
-	}
-
-	if (features & NETIF_F_TSO) {
-		if (xenbus_scanf(XBT_NIL, np->xbdev->otherend,
-				 "feature-gso-tcpv4", "%d", &val) < 0)
-			val = 0;
-
-		if (!val)
-			features &= ~NETIF_F_TSO;
-	}
-
-	if (features & NETIF_F_TSO6) {
-		if (xenbus_scanf(XBT_NIL, np->xbdev->otherend,
-				 "feature-gso-tcpv6", "%d", &val) < 0)
-			val = 0;
-
-		if (!val)
-			features &= ~NETIF_F_TSO6;
-	}
+	if (features & NETIF_F_TSO6 &&
+	    !xenbus_read_unsigned(np->xbdev->otherend, "feature-gso-tcpv6", 0))
+		features &= ~NETIF_F_TSO6;
 
 	return features;
 }
@@ -1821,18 +1801,13 @@ static int talk_to_netback(struct xenbus_device *dev,
 	info->netdev->irq = 0;
 
 	/* Check if backend supports multiple queues */
-	err = xenbus_scanf(XBT_NIL, info->xbdev->otherend,
-			   "multi-queue-max-queues", "%u", &max_queues);
-	if (err < 0)
-		max_queues = 1;
+	max_queues = xenbus_read_unsigned(info->xbdev->otherend,
+					  "multi-queue-max-queues", 1);
 	num_queues = min(max_queues, xennet_max_queues);
 
 	/* Check feature-split-event-channels */
-	err = xenbus_scanf(XBT_NIL, info->xbdev->otherend,
-			   "feature-split-event-channels", "%u",
-			   &feature_split_evtchn);
-	if (err < 0)
-		feature_split_evtchn = 0;
+	feature_split_evtchn = xenbus_read_unsigned(info->xbdev->otherend,
+					"feature-split-event-channels", 0);
 
 	/* Read mac addr. */
 	err = xen_net_read_mac(dev, info->netdev->dev_addr);
@@ -1966,16 +1941,10 @@ static int xennet_connect(struct net_device *dev)
 	struct netfront_info *np = netdev_priv(dev);
 	unsigned int num_queues = 0;
 	int err;
-	unsigned int feature_rx_copy;
 	unsigned int j = 0;
 	struct netfront_queue *queue = NULL;
 
-	err = xenbus_scanf(XBT_NIL, np->xbdev->otherend,
-			   "feature-rx-copy", "%u", &feature_rx_copy);
-	if (err != 1)
-		feature_rx_copy = 0;
-
-	if (!feature_rx_copy) {
+	if (!xenbus_read_unsigned(np->xbdev->otherend, "feature-rx-copy", 0)) {
 		dev_info(&dev->dev,
 			 "backend does not support copying receive path\n");
 		return -ENODEV;
-- 
2.6.6
