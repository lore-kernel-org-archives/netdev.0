From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net] be2net: Export tunnel offloads only when a VxLAN tunnel is created
Date: Wed, 10 Dec 2014 04:56:04 -0500
Message-ID: <1418205364-28979-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.emulex.com ([138.239.224.100]:34211 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752972AbaLJJyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 04:54:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sriharsha Basavapatna <sriharsha.basavapatna@emulex.com>

The encapsulated offload flags shouldn't be unconditionally exported
to the stack. The stack expects offloading to work across all tunnel
types when those flags are set. This would break other tunnels (like
GRE) since be2net currently supports tunnel offload for VxLAN only.

Also, with VxLANs Skyhawk-R can offload only 1 UDP dport. If more
than 1 UDP port is added, we should disable offloads in that case too.

Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |  1 +
 drivers/net/ethernet/emulex/benet/be_main.c | 41 ++++++++++++++++++++++-------
 2 files changed, 32 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 9a2d752..712e7f8 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -522,6 +522,7 @@ struct be_adapter {
 	u8 hba_port_num;
 	u16 pvid;
 	__be16 vxlan_port;
+	int vxlan_port_count;
 	struct phy_info phy;
 	u8 wol_cap;
 	bool wol_en;
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 597c463..5bb14ca 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3123,6 +3123,8 @@ static void be_mac_clear(struct be_adapter *adapter)
 #ifdef CONFIG_BE2NET_VXLAN
 static void be_disable_vxlan_offloads(struct be_adapter *adapter)
 {
+	struct net_device *netdev = adapter->netdev;
+
 	if (adapter->flags & BE_FLAGS_VXLAN_OFFLOADS)
 		be_cmd_manage_iface(adapter, adapter->if_handle,
 				    OP_CONVERT_TUNNEL_TO_NORMAL);
@@ -3132,6 +3134,9 @@ static void be_disable_vxlan_offloads(struct be_adapter *adapter)
 
 	adapter->flags &= ~BE_FLAGS_VXLAN_OFFLOADS;
 	adapter->vxlan_port = 0;
+
+	netdev->hw_enc_features = 0;
+	netdev->hw_features &= ~(NETIF_F_GSO_UDP_TUNNEL);
 }
 #endif
 
@@ -4369,6 +4374,19 @@ static int be_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 }
 
 #ifdef CONFIG_BE2NET_VXLAN
+/* VxLAN offload Notes:
+ *
+ * The stack defines tunnel offload flags (hw_enc_features) for IP and doesn't
+ * distinguish various types of transports (VxLAN, GRE, NVGRE ..). So, offload
+ * is expected to work across all types of IP tunnels once exported. Skyhawk
+ * supports offloads for either VxLAN or NVGRE, exclusively. So we export VxLAN
+ * offloads in hw_enc_features only when a VxLAN port is added. Note this only
+ * ensures that other tunnels work fine while VxLAN offloads are not enabled.
+ *
+ * Skyhawk supports VxLAN offloads only for one UDP dport. So, if the stack
+ * adds more than one port, disable offloads and don't re-enable them again
+ * until after all the tunnels are removed.
+ */
 static void be_add_vxlan_port(struct net_device *netdev, sa_family_t sa_family,
 			      __be16 port)
 {
@@ -4380,13 +4398,16 @@ static void be_add_vxlan_port(struct net_device *netdev, sa_family_t sa_family,
 		return;
 
 	if (adapter->flags & BE_FLAGS_VXLAN_OFFLOADS) {
-		dev_warn(dev, "Cannot add UDP port %d for VxLAN offloads\n",
-			 be16_to_cpu(port));
 		dev_info(dev,
 			 "Only one UDP port supported for VxLAN offloads\n");
-		return;
+		dev_info(dev, "Disabling VxLAN offloads\n");
+		adapter->vxlan_port_count++;
+		goto err;
 	}
 
+	if (adapter->vxlan_port_count++ >= 1)
+		return;
+
 	status = be_cmd_manage_iface(adapter, adapter->if_handle,
 				     OP_CONVERT_NORMAL_TO_TUNNEL);
 	if (status) {
@@ -4402,6 +4423,10 @@ static void be_add_vxlan_port(struct net_device *netdev, sa_family_t sa_family,
 	adapter->flags |= BE_FLAGS_VXLAN_OFFLOADS;
 	adapter->vxlan_port = port;
 
+	netdev->hw_enc_features |= (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
+	    NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_GSO_UDP_TUNNEL);
+	netdev->hw_features |= NETIF_F_GSO_UDP_TUNNEL;
+
 	dev_info(dev, "Enabled VxLAN offloads for UDP port %d\n",
 		 be16_to_cpu(port));
 	return;
@@ -4418,13 +4443,15 @@ static void be_del_vxlan_port(struct net_device *netdev, sa_family_t sa_family,
 		return;
 
 	if (adapter->vxlan_port != port)
-		return;
+		goto done;
 
 	be_disable_vxlan_offloads(adapter);
 
 	dev_info(&adapter->pdev->dev,
 		 "Disabled VxLAN offloads for UDP port %d\n",
 		 be16_to_cpu(port));
+done:
+	adapter->vxlan_port_count--;
 }
 
 static bool be_gso_check(struct sk_buff *skb, struct net_device *dev)
@@ -4468,12 +4495,6 @@ static void be_netdev_init(struct net_device *netdev)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
 
-	if (skyhawk_chip(adapter)) {
-		netdev->hw_enc_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
-					   NETIF_F_TSO | NETIF_F_TSO6 |
-					   NETIF_F_GSO_UDP_TUNNEL;
-		netdev->hw_features |= NETIF_F_GSO_UDP_TUNNEL;
-	}
 	netdev->hw_features |= NETIF_F_SG | NETIF_F_TSO | NETIF_F_TSO6 |
 		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM | NETIF_F_RXCSUM |
 		NETIF_F_HW_VLAN_CTAG_TX;
-- 
2.2.0
