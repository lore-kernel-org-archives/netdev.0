From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCHv2 net-next] sunvnet: clean up objects created in vnet_new()
 on vnet_exit()
Date: Wed, 16 Jul 2014 10:02:26 -0400
Message-ID: <20140716140226.GA29999@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, dave.kleikamp@oracle.com, karl.volz@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:48565 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934090AbaGPOCf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2014 10:02:35 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Nothing cleans up the objects created by
vnet_new(), they are completely leaked.

vnet_exit(), after doing the vio_unregister_driver() to clean
up ports, should call a helper function that iterates over vnet_list
and cleans up those objects. This includes unregister_netdevice()
as well as free_netdev().

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Acked-by: Dave Kleikamp <dave.kleikamp@oracle.com>
Reviewed-by: Karl Volz <karl.volz@oracle.com>

---
v2: incorporated comments from David Miller.
v3: muttrc config tweaks to avoid list-rejection
and set up correct From/Message-ID headers.

 drivers/net/ethernet/sun/sunvnet.c | 20 +++++++++++++++++++-
 1 file changed, 19 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index 1c24a8f..fd411d6 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -1083,6 +1083,24 @@ static struct vnet *vnet_find_or_create(const u64 *local_mac)
 	return vp;
 }
 
+static void vnet_cleanup(void)
+{
+	struct vnet *vp;
+	struct net_device *dev;
+
+	mutex_lock(&vnet_list_mutex);
+	while (!list_empty(&vnet_list)) {
+		vp = list_first_entry(&vnet_list, struct vnet, list);
+		list_del(&vp->list);
+		dev = vp->dev;
+		/* vio_unregister_driver() should have cleaned up port_list */
+		BUG_ON(!list_empty(&vp->port_list));
+		unregister_netdev(dev);
+		free_netdev(dev);
+	}
+	mutex_unlock(&vnet_list_mutex);
+}
+
 static const char *local_mac_prop = "local-mac-address";
 
 static struct vnet *vnet_find_parent(struct mdesc_handle *hp,
@@ -1240,7 +1258,6 @@ static int vnet_port_remove(struct vio_dev *vdev)
 
 		kfree(port);
 
-		unregister_netdev(vp->dev);
 	}
 	return 0;
 }
@@ -1268,6 +1285,7 @@ static int __init vnet_init(void)
 static void __exit vnet_exit(void)
 {
 	vio_unregister_driver(&vnet_port_driver);
+	vnet_cleanup();
 }
 
 module_init(vnet_init);
-- 
1.8.4.2
