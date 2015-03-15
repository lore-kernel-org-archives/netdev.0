From: sfeldma@gmail.com
Subject: [PATCH net-next 3/5] rocker: move to new swdev ops
Date: Sat, 14 Mar 2015 23:15:05 -0700
Message-ID: <1426400107-6072-4-git-send-email-sfeldma@gmail.com>
References: <1426400107-6072-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:33505 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751068AbbCOGOS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 02:14:18 -0400
Received: by pdnc3 with SMTP id c3so25860663pdn.0
        for <netdev@vger.kernel.org>; Sat, 14 Mar 2015 23:14:17 -0700 (PDT)
In-Reply-To: <1426400107-6072-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |   64 +++++++++++++++++++---------------
 1 file changed, 36 insertions(+), 28 deletions(-)

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
-- 
1.7.10.4
