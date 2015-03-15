From: sfeldma@gmail.com
Subject: [PATCH net-next 2/5] switchdev: use new swdev ops
Date: Sat, 14 Mar 2015 23:15:04 -0700
Message-ID: <1426400107-6072-3-git-send-email-sfeldma@gmail.com>
References: <1426400107-6072-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:35750 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751068AbbCOGOQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 02:14:16 -0400
Received: by pdbop1 with SMTP id op1so25869409pdb.2
        for <netdev@vger.kernel.org>; Sat, 14 Mar 2015 23:14:15 -0700 (PDT)
In-Reply-To: <1426400107-6072-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Move swdev wrappers over to new swdev ops (from previous ndo ops).  No
functional changes to the implementation.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 net/switchdev/switchdev.c |   42 +++++++++++++++++++++---------------------
 1 file changed, 21 insertions(+), 21 deletions(-)

diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index b7a2313..c9bfa00 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -28,11 +28,11 @@
 int netdev_switch_parent_id_get(struct net_device *dev,
 				struct netdev_phys_item_id *psid)
 {
-	const struct net_device_ops *ops = dev->netdev_ops;
+	const struct swdev_ops *ops = dev->swdev_ops;
 
-	if (!ops->ndo_switch_parent_id_get)
+	if (!ops || !ops->swdev_parent_id_get)
 		return -EOPNOTSUPP;
-	return ops->ndo_switch_parent_id_get(dev, psid);
+	return ops->swdev_parent_id_get(dev, psid);
 }
 EXPORT_SYMBOL_GPL(netdev_switch_parent_id_get);
 
@@ -46,12 +46,12 @@ EXPORT_SYMBOL_GPL(netdev_switch_parent_id_get);
  */
 int netdev_switch_port_stp_update(struct net_device *dev, u8 state)
 {
-	const struct net_device_ops *ops = dev->netdev_ops;
+	const struct swdev_ops *ops = dev->swdev_ops;
 
-	if (!ops->ndo_switch_port_stp_update)
+	if (!ops || !ops->swdev_port_stp_update)
 		return -EOPNOTSUPP;
-	WARN_ON(!ops->ndo_switch_parent_id_get);
-	return ops->ndo_switch_port_stp_update(dev, state);
+	WARN_ON(!ops->swdev_parent_id_get);
+	return ops->swdev_port_stp_update(dev, state);
 }
 EXPORT_SYMBOL_GPL(netdev_switch_port_stp_update);
 
@@ -230,17 +230,17 @@ EXPORT_SYMBOL_GPL(ndo_dflt_netdev_switch_port_bridge_dellink);
 
 static struct net_device *netdev_switch_get_lowest_dev(struct net_device *dev)
 {
-	const struct net_device_ops *ops = dev->netdev_ops;
+	const struct swdev_ops *ops = dev->swdev_ops;
 	struct net_device *lower_dev;
 	struct net_device *port_dev;
 	struct list_head *iter;
 
 	/* Recusively search down until we find a sw port dev.
-	 * (A sw port dev supports ndo_switch_parent_id_get).
+	 * (A sw port dev supports swdev_parent_id_get).
 	 */
 
 	if (dev->features & NETIF_F_HW_SWITCH_OFFLOAD &&
-	    ops->ndo_switch_parent_id_get)
+	    ops && ops->swdev_parent_id_get)
 		return dev;
 
 	netdev_for_each_lower_dev(dev, lower_dev, iter) {
@@ -304,7 +304,7 @@ int netdev_switch_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 			       u8 tos, u8 type, u32 nlflags, u32 tb_id)
 {
 	struct net_device *dev;
-	const struct net_device_ops *ops;
+	const struct swdev_ops *ops;
 	int err = 0;
 
 	/* Don't offload route if using custom ip rules or if
@@ -322,12 +322,12 @@ int netdev_switch_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 	dev = netdev_switch_get_dev_by_nhs(fi);
 	if (!dev)
 		return 0;
-	ops = dev->netdev_ops;
+	ops = dev->swdev_ops;
 
-	if (ops->ndo_switch_fib_ipv4_add) {
-		err = ops->ndo_switch_fib_ipv4_add(dev, htonl(dst), dst_len,
-						   fi, tos, type, nlflags,
-						   tb_id);
+	if (ops->swdev_fib_ipv4_add) {
+		err = ops->swdev_fib_ipv4_add(dev, htonl(dst), dst_len,
+					      fi, tos, type, nlflags,
+					      tb_id);
 		if (!err)
 			fi->fib_flags |= RTNH_F_EXTERNAL;
 	}
@@ -352,7 +352,7 @@ int netdev_switch_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
 			       u8 tos, u8 type, u32 tb_id)
 {
 	struct net_device *dev;
-	const struct net_device_ops *ops;
+	const struct swdev_ops *ops;
 	int err = 0;
 
 	if (!(fi->fib_flags & RTNH_F_EXTERNAL))
@@ -361,11 +361,11 @@ int netdev_switch_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
 	dev = netdev_switch_get_dev_by_nhs(fi);
 	if (!dev)
 		return 0;
-	ops = dev->netdev_ops;
+	ops = dev->swdev_ops;
 
-	if (ops->ndo_switch_fib_ipv4_del) {
-		err = ops->ndo_switch_fib_ipv4_del(dev, htonl(dst), dst_len,
-						   fi, tos, type, tb_id);
+	if (ops->swdev_fib_ipv4_del) {
+		err = ops->swdev_fib_ipv4_del(dev, htonl(dst), dst_len,
+					      fi, tos, type, tb_id);
 		if (!err)
 			fi->fib_flags &= ~RTNH_F_EXTERNAL;
 	}
-- 
1.7.10.4
