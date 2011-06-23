From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH] vmxnet3: Convert to new vlan model.
Date: Thu, 23 Jun 2011 16:04:39 -0700
Message-ID: <1308870279-30773-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, Shreyas Bhatewara <sbhatewara@vmware.com>,
	VMware PV-Drivers <pv-drivers@vmware.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:50527 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933959Ab1FWXEr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2011 19:04:47 -0400
Received: by pvg12 with SMTP id 12so1404817pvg.19
        for <netdev@vger.kernel.org>; Thu, 23 Jun 2011 16:04:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This converts the vmxnet3 driver to use the new vlan model.  In doing so
it fixes missing tags in tcpdump and failure to do checksum offload when
tx vlan offload is disabled.

CC: Shreyas Bhatewara <sbhatewara@vmware.com>
CC: VMware PV-Drivers <pv-drivers@vmware.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 drivers/net/vmxnet3/vmxnet3_drv.c     |  111 +++++++++------------------------
 drivers/net/vmxnet3/vmxnet3_ethtool.c |    9 +++-
 drivers/net/vmxnet3/vmxnet3_int.h     |    3 +-
 3 files changed, 40 insertions(+), 83 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 33097ec..c84b1dd 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -918,7 +918,7 @@ vmxnet3_tq_xmit(struct sk_buff *skb, struct vmxnet3_tx_queue *tq,
 	count = VMXNET3_TXD_NEEDED(skb_headlen(skb)) +
 		skb_shinfo(skb)->nr_frags + 1;
 
-	ctx.ipv4 = (skb->protocol == cpu_to_be16(ETH_P_IP));
+	ctx.ipv4 = (vlan_get_protocol(skb) == cpu_to_be16(ETH_P_IP));
 
 	ctx.mss = skb_shinfo(skb)->gso_size;
 	if (ctx.mss) {
@@ -1231,12 +1231,10 @@ vmxnet3_rq_rx_complete(struct vmxnet3_rx_queue *rq,
 					(union Vmxnet3_GenericDesc *)rcd);
 			skb->protocol = eth_type_trans(skb, adapter->netdev);
 
-			if (unlikely(adapter->vlan_grp && rcd->ts)) {
-				vlan_hwaccel_receive_skb(skb,
-						adapter->vlan_grp, rcd->tci);
-			} else {
-				netif_receive_skb(skb);
-			}
+			if (unlikely(rcd->ts))
+				__vlan_hwaccel_put_tag(skb, rcd->tci);
+
+			netif_receive_skb(skb);
 
 			ctx->skb = NULL;
 		}
@@ -1856,79 +1854,18 @@ vmxnet3_free_irqs(struct vmxnet3_adapter *adapter)
 	}
 }
 
-static void
-vmxnet3_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
-{
-	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
-	struct Vmxnet3_DriverShared *shared = adapter->shared;
-	u32 *vfTable = adapter->shared->devRead.rxFilterConf.vfTable;
-	unsigned long flags;
-
-	if (grp) {
-		/* add vlan rx stripping. */
-		if (adapter->netdev->features & NETIF_F_HW_VLAN_RX) {
-			int i;
-			adapter->vlan_grp = grp;
-
-			/*
-			 *  Clear entire vfTable; then enable untagged pkts.
-			 *  Note: setting one entry in vfTable to non-zero turns
-			 *  on VLAN rx filtering.
-			 */
-			for (i = 0; i < VMXNET3_VFT_SIZE; i++)
-				vfTable[i] = 0;
-
-			VMXNET3_SET_VFTABLE_ENTRY(vfTable, 0);
-			spin_lock_irqsave(&adapter->cmd_lock, flags);
-			VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
-					       VMXNET3_CMD_UPDATE_VLAN_FILTERS);
-			spin_unlock_irqrestore(&adapter->cmd_lock, flags);
-		} else {
-			printk(KERN_ERR "%s: vlan_rx_register when device has "
-			       "no NETIF_F_HW_VLAN_RX\n", netdev->name);
-		}
-	} else {
-		/* remove vlan rx stripping. */
-		struct Vmxnet3_DSDevRead *devRead = &shared->devRead;
-		adapter->vlan_grp = NULL;
-
-		if (devRead->misc.uptFeatures & UPT1_F_RXVLAN) {
-			int i;
-
-			for (i = 0; i < VMXNET3_VFT_SIZE; i++) {
-				/* clear entire vfTable; this also disables
-				 * VLAN rx filtering
-				 */
-				vfTable[i] = 0;
-			}
-			spin_lock_irqsave(&adapter->cmd_lock, flags);
-			VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
-					       VMXNET3_CMD_UPDATE_VLAN_FILTERS);
-			spin_unlock_irqrestore(&adapter->cmd_lock, flags);
-		}
-	}
-}
-
 
 static void
 vmxnet3_restore_vlan(struct vmxnet3_adapter *adapter)
 {
-	if (adapter->vlan_grp) {
-		u16 vid;
-		u32 *vfTable = adapter->shared->devRead.rxFilterConf.vfTable;
-		bool activeVlan = false;
+	u32 *vfTable = adapter->shared->devRead.rxFilterConf.vfTable;
+	u16 vid;
 
-		for (vid = 0; vid < VLAN_N_VID; vid++) {
-			if (vlan_group_get_device(adapter->vlan_grp, vid)) {
-				VMXNET3_SET_VFTABLE_ENTRY(vfTable, vid);
-				activeVlan = true;
-			}
-		}
-		if (activeVlan) {
-			/* continue to allow untagged pkts */
-			VMXNET3_SET_VFTABLE_ENTRY(vfTable, 0);
-		}
-	}
+	/* allow untagged pkts */
+	VMXNET3_SET_VFTABLE_ENTRY(vfTable, 0);
+
+	for_each_set_bit(vid, adapter->active_vlans, VLAN_N_VID)
+		VMXNET3_SET_VFTABLE_ENTRY(vfTable, vid);
 }
 
 
@@ -1944,6 +1881,8 @@ vmxnet3_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 	VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
 			       VMXNET3_CMD_UPDATE_VLAN_FILTERS);
 	spin_unlock_irqrestore(&adapter->cmd_lock, flags);
+
+	set_bit(vid, adapter->active_vlans);
 }
 
 
@@ -1959,6 +1898,8 @@ vmxnet3_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 	VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
 			       VMXNET3_CMD_UPDATE_VLAN_FILTERS);
 	spin_unlock_irqrestore(&adapter->cmd_lock, flags);
+
+	clear_bit(vid, adapter->active_vlans);
 }
 
 
@@ -1995,8 +1936,14 @@ vmxnet3_set_mc(struct net_device *netdev)
 	u8 *new_table = NULL;
 	u32 new_mode = VMXNET3_RXM_UCAST;
 
-	if (netdev->flags & IFF_PROMISC)
+	if (netdev->flags & IFF_PROMISC) {
+		u32 *vfTable = adapter->shared->devRead.rxFilterConf.vfTable;
+		memset(vfTable, 0, VMXNET3_VFT_SIZE * sizeof(*vfTable));
+
 		new_mode |= VMXNET3_RXM_PROMISC;
+	} else {
+		vmxnet3_restore_vlan(adapter);
+	}
 
 	if (netdev->flags & IFF_BROADCAST)
 		new_mode |= VMXNET3_RXM_BCAST;
@@ -2030,6 +1977,8 @@ vmxnet3_set_mc(struct net_device *netdev)
 		rxConf->rxMode = cpu_to_le32(new_mode);
 		VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
 				       VMXNET3_CMD_UPDATE_RX_MODE);
+		VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
+				       VMXNET3_CMD_UPDATE_VLAN_FILTERS);
 	}
 
 	VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
@@ -2639,12 +2588,13 @@ vmxnet3_declare_features(struct vmxnet3_adapter *adapter, bool dma64)
 
 	netdev->hw_features = NETIF_F_SG | NETIF_F_RXCSUM |
 		NETIF_F_HW_CSUM | NETIF_F_HW_VLAN_TX |
-		NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_LRO;
+		NETIF_F_HW_VLAN_RX | NETIF_F_TSO | NETIF_F_TSO6 |
+		NETIF_F_LRO;
 	if (dma64)
 		netdev->features |= NETIF_F_HIGHDMA;
-	netdev->vlan_features = netdev->hw_features & ~NETIF_F_HW_VLAN_TX;
-	netdev->features = netdev->hw_features |
-		NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER;
+	netdev->vlan_features = netdev->hw_features &
+				~(NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX);
+	netdev->features = netdev->hw_features | NETIF_F_HW_VLAN_FILTER;
 
 	netdev_info(adapter->netdev,
 		"features: sg csum vlan jf tso tsoIPv6 lro%s\n",
@@ -2865,7 +2815,6 @@ vmxnet3_probe_device(struct pci_dev *pdev,
 		.ndo_get_stats64 = vmxnet3_get_stats64,
 		.ndo_tx_timeout = vmxnet3_tx_timeout,
 		.ndo_set_multicast_list = vmxnet3_set_mc,
-		.ndo_vlan_rx_register = vmxnet3_vlan_rx_register,
 		.ndo_vlan_rx_add_vid = vmxnet3_vlan_rx_add_vid,
 		.ndo_vlan_rx_kill_vid = vmxnet3_vlan_rx_kill_vid,
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/vmxnet3/vmxnet3_ethtool.c b/drivers/net/vmxnet3/vmxnet3_ethtool.c
index bba7c15..27400ed 100644
--- a/drivers/net/vmxnet3/vmxnet3_ethtool.c
+++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c
@@ -268,7 +268,7 @@ int vmxnet3_set_features(struct net_device *netdev, u32 features)
 	unsigned long flags;
 	u32 changed = features ^ netdev->features;
 
-	if (changed & (NETIF_F_RXCSUM|NETIF_F_LRO)) {
+	if (changed & (NETIF_F_RXCSUM | NETIF_F_LRO | NETIF_F_HW_VLAN_RX)) {
 		if (features & NETIF_F_RXCSUM)
 			adapter->shared->devRead.misc.uptFeatures |=
 			UPT1_F_RXCSUM;
@@ -284,6 +284,13 @@ int vmxnet3_set_features(struct net_device *netdev, u32 features)
 			adapter->shared->devRead.misc.uptFeatures &=
 							~UPT1_F_LRO;
 
+		if (features & NETIF_F_HW_VLAN_RX)
+			adapter->shared->devRead.misc.uptFeatures |=
+			UPT1_F_RXVLAN;
+		else
+			adapter->shared->devRead.misc.uptFeatures &=
+			~UPT1_F_RXVLAN;
+
 		spin_lock_irqsave(&adapter->cmd_lock, flags);
 		VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
 				       VMXNET3_CMD_UPDATE_FEATURE);
diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index 0e567c24..2e37985 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -27,6 +27,7 @@
 #ifndef _VMXNET3_INT_H
 #define _VMXNET3_INT_H
 
+#include <linux/bitops.h>
 #include <linux/ethtool.h>
 #include <linux/delay.h>
 #include <linux/netdevice.h>
@@ -315,7 +316,7 @@ struct vmxnet3_intr {
 struct vmxnet3_adapter {
 	struct vmxnet3_tx_queue		tx_queue[VMXNET3_DEVICE_MAX_TX_QUEUES];
 	struct vmxnet3_rx_queue		rx_queue[VMXNET3_DEVICE_MAX_RX_QUEUES];
-	struct vlan_group		*vlan_grp;
+	unsigned long			active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
 	struct vmxnet3_intr		intr;
 	spinlock_t			cmd_lock;
 	struct Vmxnet3_DriverShared	*shared;
-- 
1.7.4.1

