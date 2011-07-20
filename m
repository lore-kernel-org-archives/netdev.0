From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 04/47] nes: do vlan cleanup
Date: Wed, 20 Jul 2011 16:54:06 +0200
Message-ID: <1311173689-17419-5-git-send-email-jpirko@redhat.com>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com,
	faisal.latif@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36416 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751626Ab1GTOzD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 10:55:03 -0400
In-Reply-To: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- unify vlan and nonvlan rx path
- kill nesvnic->vlan_grp and nes_netdev_vlan_rx_register
- allow to turn on/off rx/tx vlan accel via ethtool (set_features)

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/infiniband/hw/nes/nes_hw.c  |   19 +++++--------
 drivers/infiniband/hw/nes/nes_hw.h  |    4 ---
 drivers/infiniband/hw/nes/nes_nic.c |   50 ++++++++++++++++++++++++++--------
 3 files changed, 45 insertions(+), 28 deletions(-)

diff --git a/drivers/infiniband/hw/nes/nes_hw.c b/drivers/infiniband/hw/nes/nes_hw.c
index 96fa9a4..be36cbe 100644
--- a/drivers/infiniband/hw/nes/nes_hw.c
+++ b/drivers/infiniband/hw/nes/nes_hw.c
@@ -2917,24 +2917,19 @@ void nes_nic_ce_handler(struct nes_device *nesdev, struct nes_hw_nic_cq *cq)
 					goto skip_rx_indicate0;
 
 
-				if ((cqe_misc & NES_NIC_CQE_TAG_VALID) &&
-				    (nesvnic->vlan_grp != NULL)) {
+				if (cqe_misc & NES_NIC_CQE_TAG_VALID) {
 					vlan_tag = (u16)(le32_to_cpu(
 							cq->cq_vbase[head].cqe_words[NES_NIC_CQE_TAG_PKT_TYPE_IDX])
 							>> 16);
 					nes_debug(NES_DBG_CQ, "%s: Reporting stripped VLAN packet. Tag = 0x%04X\n",
 							nesvnic->netdev->name, vlan_tag);
-					if (nes_use_lro)
-						lro_vlan_hwaccel_receive_skb(&nesvnic->lro_mgr, rx_skb,
-								nesvnic->vlan_grp, vlan_tag, NULL);
-					else
-						nes_vlan_rx(rx_skb, nesvnic->vlan_grp, vlan_tag);
-				} else {
-					if (nes_use_lro)
-						lro_receive_skb(&nesvnic->lro_mgr, rx_skb, NULL);
-					else
-						nes_netif_rx(rx_skb);
+
+					__vlan_hwaccel_put_tag(rx_skb, vlan_tag);
 				}
+				if (nes_use_lro)
+					lro_receive_skb(&nesvnic->lro_mgr, rx_skb, NULL);
+				else
+					netif_receive_skb(rx_skb);
 
 skip_rx_indicate0:
 				;
diff --git a/drivers/infiniband/hw/nes/nes_hw.h b/drivers/infiniband/hw/nes/nes_hw.h
index 9159411..c324147 100644
--- a/drivers/infiniband/hw/nes/nes_hw.h
+++ b/drivers/infiniband/hw/nes/nes_hw.h
@@ -1211,7 +1211,6 @@ struct nes_vnic {
 	/* void *mem; */
 	struct nes_device *nesdev;
 	struct net_device *netdev;
-	struct vlan_group *vlan_grp;
 	atomic_t          rx_skbs_needed;
 	atomic_t          rx_skb_timer_running;
 	int               budget;
@@ -1357,7 +1356,4 @@ struct nes_terminate_hdr {
 #define NES_LINK_RECHECK_DELAY	msecs_to_jiffies(50)
 #define NES_LINK_RECHECK_MAX	60
 
-#define nes_vlan_rx vlan_hwaccel_receive_skb
-#define nes_netif_rx netif_receive_skb
-
 #endif		/* __NES_HW_H */
diff --git a/drivers/infiniband/hw/nes/nes_nic.c b/drivers/infiniband/hw/nes/nes_nic.c
index d3a1c41..fb4dda4 100644
--- a/drivers/infiniband/hw/nes/nes_nic.c
+++ b/drivers/infiniband/hw/nes/nes_nic.c
@@ -1584,23 +1584,19 @@ static const struct ethtool_ops nes_ethtool_ops = {
 	.set_pauseparam = nes_netdev_set_pauseparam,
 };
 
-
-static void nes_netdev_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
+static void nes_vlan_mode(struct nes_device *nesdev, u32 features)
 {
-	struct nes_vnic *nesvnic = netdev_priv(netdev);
-	struct nes_device *nesdev = nesvnic->nesdev;
 	struct nes_adapter *nesadapter = nesdev->nesadapter;
 	u32 u32temp;
 	unsigned long flags;
 
 	spin_lock_irqsave(&nesadapter->phy_lock, flags);
-	nesvnic->vlan_grp = grp;
 
 	nes_debug(NES_DBG_NETDEV, "%s: %s\n", __func__, netdev->name);
 
 	/* Enable/Disable VLAN Stripping */
 	u32temp = nes_read_indexed(nesdev, NES_IDX_PCIX_DIAG);
-	if (grp)
+	if (features & NETIF_F_HW_VLAN_RX)
 		u32temp &= 0xfdffffff;
 	else
 		u32temp	|= 0x02000000;
@@ -1609,17 +1605,44 @@ static void nes_netdev_vlan_rx_register(struct net_device *netdev, struct vlan_g
 	spin_unlock_irqrestore(&nesadapter->phy_lock, flags);
 }
 
+static u32 nes_fix_features(struct net_device *netdev, u32 features)
+{
+	/*
+	 * Since there is no support for separate rx/tx vlan accel
+	 * enable/disable make sure tx flag is always in same state as rx.
+	 */
+	if (features & NETIF_F_HW_VLAN_RX)
+		features |= NETIF_F_HW_VLAN_TX;
+	else
+		features &= ~NETIF_F_HW_VLAN_TX;
+
+	return features;
+}
+
+static int nes_set_features(struct net_device *netdev, u32 features)
+{
+	struct nes_vnic *nesvnic = netdev_priv(netdev);
+	struct nes_device *nesdev = nesvnic->nesdev;
+	u32 changed = netdev->features ^ features;
+
+	if (changed & NETIF_F_HW_VLAN_RX)
+		nes_vlan_mode(nesdev, features);
+
+	return 0;
+}
+
 static const struct net_device_ops nes_netdev_ops = {
-	.ndo_open 		= nes_netdev_open,
+	.ndo_open		= nes_netdev_open,
 	.ndo_stop		= nes_netdev_stop,
-	.ndo_start_xmit 	= nes_netdev_start_xmit,
+	.ndo_start_xmit		= nes_netdev_start_xmit,
 	.ndo_get_stats		= nes_netdev_get_stats,
-	.ndo_tx_timeout 	= nes_netdev_tx_timeout,
+	.ndo_tx_timeout		= nes_netdev_tx_timeout,
 	.ndo_set_mac_address	= nes_netdev_set_mac_address,
 	.ndo_set_multicast_list = nes_netdev_set_multicast_list,
 	.ndo_change_mtu		= nes_netdev_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_vlan_rx_register 	= nes_netdev_vlan_rx_register,
+	.ndo_fix_features	= nes_fix_features,
+	.ndo_set_features	= nes_set_features,
 };
 
 /**
@@ -1656,7 +1679,7 @@ struct net_device *nes_netdev_init(struct nes_device *nesdev,
 	netdev->ethtool_ops = &nes_ethtool_ops;
 	netif_napi_add(netdev, &nesvnic->napi, nes_netdev_poll, 128);
 	nes_debug(NES_DBG_INIT, "Enabling VLAN Insert/Delete.\n");
-	netdev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
+	netdev->features |= NETIF_F_HW_VLAN_TX;
 
 	/* Fill in the port structure */
 	nesvnic->netdev = netdev;
@@ -1683,7 +1706,8 @@ struct net_device *nes_netdev_init(struct nes_device *nesdev,
 	netdev->dev_addr[5] = (u8)u64temp;
 	memcpy(netdev->perm_addr, netdev->dev_addr, 6);
 
-	netdev->hw_features = NETIF_F_RXCSUM | NETIF_F_SG | NETIF_F_IP_CSUM;
+	netdev->hw_features = NETIF_F_RXCSUM | NETIF_F_SG | NETIF_F_IP_CSUM |
+			      NETIF_F_HW_VLAN_RX;
 	if ((nesvnic->logical_port < 2) || (nesdev->nesadapter->hw_rev != NE020_REV))
 		netdev->hw_features |= NETIF_F_TSO;
 	netdev->features |= netdev->hw_features;
@@ -1815,6 +1839,8 @@ struct net_device *nes_netdev_init(struct nes_device *nesdev,
 		nes_init_phy(nesdev);
 	}
 
+	nes_vlan_mode(nesdev, netdev->features);
+
 	return netdev;
 }
 
-- 
1.7.6

