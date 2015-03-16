From: sfeldma@gmail.com
Subject: [PATCH net-next v2 2/3] switchdev: use new swdev ops
Date: Sun, 15 Mar 2015 18:45:20 -0700
Message-ID: <1426470321-48669-3-git-send-email-sfeldma@gmail.com>
References: <1426470321-48669-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com,
	simon.horman@netronome.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36427 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751831AbbCPBoR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 21:44:17 -0400
Received: by padcy3 with SMTP id cy3so49050278pad.3
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 18:44:17 -0700 (PDT)
In-Reply-To: <1426470321-48669-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Move swdev wrappers over to new swdev ops (from previous ndo ops).  No
functional changes to the implementation.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>

rocker: move to new swdev ops

Signed-off-by: Scott Feldman <sfeldma@gmail.com>

dsa: move to new swdev ops

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |   64 +++++++++++++++++++---------------
 net/dsa/slave.c                      |    8 +++--
 net/switchdev/switchdev.c            |   42 +++++++++++-----------
 3 files changed, 63 insertions(+), 51 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 223348d..bc5f27a 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4131,8 +4131,26 @@ static int rocker_port_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 				       rocker_port->brport_flags, mask);
 }
 
-static int rocker_port_switch_parent_id_get(struct net_device *dev,
-					    struct netdev_phys_item_id *psid)
+static const struct net_device_ops rocker_port_netdev_ops = {
+	.ndo_open			= rocker_port_open,
+	.ndo_stop			= rocker_port_stop,
+	.ndo_start_xmit			= rocker_port_xmit,
+	.ndo_set_mac_address		= rocker_port_set_mac_address,
+	.ndo_vlan_rx_add_vid		= rocker_port_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid		= rocker_port_vlan_rx_kill_vid,
+	.ndo_fdb_add			= rocker_port_fdb_add,
+	.ndo_fdb_del			= rocker_port_fdb_del,
+	.ndo_fdb_dump			= rocker_port_fdb_dump,
+	.ndo_bridge_setlink		= rocker_port_bridge_setlink,
+	.ndo_bridge_getlink		= rocker_port_bridge_getlink,
+};
+
+/********************
+ * swdev interface
+ ********************/
+
+static int rocker_port_swdev_parent_id_get(struct net_device *dev,
+					   struct netdev_phys_item_id *psid)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
 	struct rocker *rocker = rocker_port->rocker;
@@ -4142,18 +4160,18 @@ static int rocker_port_switch_parent_id_get(struct net_device *dev,
 	return 0;
 }
 
-static int rocker_port_switch_port_stp_update(struct net_device *dev, u8 state)
+static int rocker_port_swdev_port_stp_update(struct net_device *dev, u8 state)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
 
 	return rocker_port_stp_update(rocker_port, state);
 }
 
-static int rocker_port_switch_fib_ipv4_add(struct net_device *dev,
-					   __be32 dst, int dst_len,
-					   struct fib_info *fi,
-					   u8 tos, u8 type,
-					   u32 nlflags, u32 tb_id)
+static int rocker_port_swdev_fib_ipv4_add(struct net_device *dev,
+					  __be32 dst, int dst_len,
+					  struct fib_info *fi,
+					  u8 tos, u8 type,
+					  u32 nlflags, u32 tb_id)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
 	int flags = 0;
@@ -4162,10 +4180,10 @@ static int rocker_port_switch_fib_ipv4_add(struct net_device *dev,
 				    fi, tb_id, flags);
 }
 
-static int rocker_port_switch_fib_ipv4_del(struct net_device *dev,
-					   __be32 dst, int dst_len,
-					   struct fib_info *fi,
-					   u8 tos, u8 type, u32 tb_id)
+static int rocker_port_swdev_fib_ipv4_del(struct net_device *dev,
+					  __be32 dst, int dst_len,
+					  struct fib_info *fi,
+					  u8 tos, u8 type, u32 tb_id)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
 	int flags = ROCKER_OP_FLAG_REMOVE;
@@ -4174,22 +4192,11 @@ static int rocker_port_switch_fib_ipv4_del(struct net_device *dev,
 				    fi, tb_id, flags);
 }
 
-static const struct net_device_ops rocker_port_netdev_ops = {
-	.ndo_open			= rocker_port_open,
-	.ndo_stop			= rocker_port_stop,
-	.ndo_start_xmit			= rocker_port_xmit,
-	.ndo_set_mac_address		= rocker_port_set_mac_address,
-	.ndo_vlan_rx_add_vid		= rocker_port_vlan_rx_add_vid,
-	.ndo_vlan_rx_kill_vid		= rocker_port_vlan_rx_kill_vid,
-	.ndo_fdb_add			= rocker_port_fdb_add,
-	.ndo_fdb_del			= rocker_port_fdb_del,
-	.ndo_fdb_dump			= rocker_port_fdb_dump,
-	.ndo_bridge_setlink		= rocker_port_bridge_setlink,
-	.ndo_bridge_getlink		= rocker_port_bridge_getlink,
-	.ndo_switch_parent_id_get	= rocker_port_switch_parent_id_get,
-	.ndo_switch_port_stp_update	= rocker_port_switch_port_stp_update,
-	.ndo_switch_fib_ipv4_add	= rocker_port_switch_fib_ipv4_add,
-	.ndo_switch_fib_ipv4_del	= rocker_port_switch_fib_ipv4_del,
+static const struct swdev_ops rocker_port_swdev_ops = {
+	.swdev_parent_id_get		= rocker_port_swdev_parent_id_get,
+	.swdev_port_stp_update		= rocker_port_swdev_port_stp_update,
+	.swdev_fib_ipv4_add		= rocker_port_swdev_fib_ipv4_add,
+	.swdev_fib_ipv4_del		= rocker_port_swdev_fib_ipv4_del,
 };
 
 /********************
@@ -4544,6 +4551,7 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 	rocker_port_dev_addr_init(rocker, rocker_port);
 	dev->netdev_ops = &rocker_port_netdev_ops;
 	dev->ethtool_ops = &rocker_port_ethtool_ops;
+	dev->swdev_ops = &rocker_port_swdev_ops;
 	netif_napi_add(dev, &rocker_port->napi_tx, rocker_port_poll_tx,
 		       NAPI_POLL_WEIGHT);
 	netif_napi_add(dev, &rocker_port->napi_rx, rocker_port_poll_rx,
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 6511552..2138d99 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -572,8 +572,11 @@ static const struct net_device_ops dsa_slave_netdev_ops = {
 	.ndo_set_rx_mode	= dsa_slave_set_rx_mode,
 	.ndo_set_mac_address	= dsa_slave_set_mac_address,
 	.ndo_do_ioctl		= dsa_slave_ioctl,
-	.ndo_switch_parent_id_get = dsa_slave_parent_id_get,
-	.ndo_switch_port_stp_update = dsa_slave_stp_update,
+};
+
+static const struct swdev_ops dsa_slave_swdev_ops = {
+	.swdev_parent_id_get = dsa_slave_parent_id_get,
+	.swdev_port_stp_update = dsa_slave_stp_update,
 };
 
 static void dsa_slave_adjust_link(struct net_device *dev)
@@ -755,6 +758,7 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	eth_hw_addr_inherit(slave_dev, master);
 	slave_dev->tx_queue_len = 0;
 	slave_dev->netdev_ops = &dsa_slave_netdev_ops;
+	slave_dev->swdev_ops = &dsa_slave_swdev_ops;
 
 	SET_NETDEV_DEV(slave_dev, parent);
 	slave_dev->dev.of_node = ds->pd->port_dn[port];
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
