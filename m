From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next] sunvnet:Invoke SET_NETDEV_DEV() to set up the vdev
 in vnet_new()
Date: Fri, 18 Sep 2015 17:47:55 -0400
Message-ID: <20150918214755.GI26826@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, david.stevens@oracle.com,
	sowmini.varadhan@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:25503 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753353AbbIRVsA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 17:48:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

`ls /sys/devices/channel-devices/vnet-port-0-0/net' is missing without
this change, and applications like NetworkManager are looking in
sysfs for the information.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 drivers/net/ethernet/sun/sunvnet.c |   17 +++++++++++------
 1 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index 53fe200..cc106d8 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -1756,7 +1756,8 @@ static const struct net_device_ops vnet_ops = {
 #endif
 };
 
-static struct vnet *vnet_new(const u64 *local_mac)
+static struct vnet *vnet_new(const u64 *local_mac,
+			     struct vio_dev *vdev)
 {
 	struct net_device *dev;
 	struct vnet *vp;
@@ -1790,6 +1791,8 @@ static struct vnet *vnet_new(const u64 *local_mac)
 			   NETIF_F_HW_CSUM | NETIF_F_SG;
 	dev->features = dev->hw_features;
 
+	SET_NETDEV_DEV(dev, &vdev->dev);
+
 	err = register_netdev(dev);
 	if (err) {
 		pr_err("Cannot register net device, aborting\n");
@@ -1808,7 +1811,8 @@ static struct vnet *vnet_new(const u64 *local_mac)
 	return ERR_PTR(err);
 }
 
-static struct vnet *vnet_find_or_create(const u64 *local_mac)
+static struct vnet *vnet_find_or_create(const u64 *local_mac,
+					struct vio_dev *vdev)
 {
 	struct vnet *iter, *vp;
 
@@ -1821,7 +1825,7 @@ static struct vnet *vnet_find_or_create(const u64 *local_mac)
 		}
 	}
 	if (!vp)
-		vp = vnet_new(local_mac);
+		vp = vnet_new(local_mac, vdev);
 	mutex_unlock(&vnet_list_mutex);
 
 	return vp;
@@ -1848,7 +1852,8 @@ static void vnet_cleanup(void)
 static const char *local_mac_prop = "local-mac-address";
 
 static struct vnet *vnet_find_parent(struct mdesc_handle *hp,
-						u64 port_node)
+				     u64 port_node,
+				     struct vio_dev *vdev)
 {
 	const u64 *local_mac = NULL;
 	u64 a;
@@ -1869,7 +1874,7 @@ static struct vnet *vnet_find_parent(struct mdesc_handle *hp,
 	if (!local_mac)
 		return ERR_PTR(-ENODEV);
 
-	return vnet_find_or_create(local_mac);
+	return vnet_find_or_create(local_mac, vdev);
 }
 
 static struct ldc_channel_config vnet_ldc_cfg = {
@@ -1923,7 +1928,7 @@ static int vnet_port_probe(struct vio_dev *vdev, const struct vio_device_id *id)
 
 	hp = mdesc_grab();
 
-	vp = vnet_find_parent(hp, vdev->mp);
+	vp = vnet_find_parent(hp, vdev->mp, vdev);
 	if (IS_ERR(vp)) {
 		pr_err("Cannot find port parent vnet\n");
 		err = PTR_ERR(vp);
-- 
1.7.1
