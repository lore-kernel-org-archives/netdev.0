From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 01/21] nes: do vlan cleanup
Date: Fri, 15 Jul 2011 23:33:19 +0200
Message-ID: <1310765619-27827-2-git-send-email-jpirko@redhat.com>
References: <1310765619-27827-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com,
	faisal.latif@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6981 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753282Ab1GOVeS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jul 2011 17:34:18 -0400
In-Reply-To: <1310765619-27827-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- unify vlan and nonvlan rx path
- kill nesvnic->vlan_grp and nes_netdev_vlan_rx_register
- enable vlan stripping always

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/infiniband/hw/nes/nes_hw.c  |   19 +++++----------
 drivers/infiniband/hw/nes/nes_hw.h  |    4 ---
 drivers/infiniband/hw/nes/nes_nic.c |   42 ++++++++++------------------------
 3 files changed, 20 insertions(+), 45 deletions(-)

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
index d3a1c41..abdb326 100644
--- a/drivers/infiniband/hw/nes/nes_nic.c
+++ b/drivers/infiniband/hw/nes/nes_nic.c
@@ -127,6 +127,15 @@ static int nes_netdev_poll(struct napi_struct *napi, int budget)
 	return nescq->rx_pkts_indicated;
 }
 
+/* Enable VLAN Stripping */
+static void __net_vlan_enable(struct nes_device *nesdev)
+{
+	u32 u32temp;
+
+	u32temp = nes_read_indexed(nesdev, NES_IDX_PCIX_DIAG);
+	u32temp &= 0xfdffffff;
+	nes_write_indexed(nesdev, NES_IDX_PCIX_DIAG, u32temp);
+}
 
 /**
  * nes_netdev_open - Activate the network interface; ifconfig
@@ -248,6 +257,7 @@ static int nes_netdev_open(struct net_device *netdev)
 		nesdev->link_recheck = 1;
 		schedule_delayed_work(&nesdev->work, NES_LINK_RECHECK_DELAY);
 	}
+	__net_vlan_enable(nesdev);
 	spin_unlock_irqrestore(&nesdev->nesadapter->phy_lock, flags);
 
 	spin_lock_irqsave(&nesvnic->port_ibevent_lock, flags);
@@ -1584,42 +1594,16 @@ static const struct ethtool_ops nes_ethtool_ops = {
 	.set_pauseparam = nes_netdev_set_pauseparam,
 };
 
-
-static void nes_netdev_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
-{
-	struct nes_vnic *nesvnic = netdev_priv(netdev);
-	struct nes_device *nesdev = nesvnic->nesdev;
-	struct nes_adapter *nesadapter = nesdev->nesadapter;
-	u32 u32temp;
-	unsigned long flags;
-
-	spin_lock_irqsave(&nesadapter->phy_lock, flags);
-	nesvnic->vlan_grp = grp;
-
-	nes_debug(NES_DBG_NETDEV, "%s: %s\n", __func__, netdev->name);
-
-	/* Enable/Disable VLAN Stripping */
-	u32temp = nes_read_indexed(nesdev, NES_IDX_PCIX_DIAG);
-	if (grp)
-		u32temp &= 0xfdffffff;
-	else
-		u32temp	|= 0x02000000;
-
-	nes_write_indexed(nesdev, NES_IDX_PCIX_DIAG, u32temp);
-	spin_unlock_irqrestore(&nesadapter->phy_lock, flags);
-}
-
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
 };
 
 /**
-- 
1.7.6

