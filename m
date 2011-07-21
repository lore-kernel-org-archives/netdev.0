From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 21/47 V2] qlge: do vlan cleanup
Date: Thu, 21 Jul 2011 15:24:11 +0200
Message-ID: <20110721132354.GD2107@minipsycho>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
 <1311173689-17419-22-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com,
	jitendra.kalsaria@qlogic.com, ron.mercer@qlogic.com,
	linux-driver@qlogic.com, jesse@nicira.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8255 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750769Ab1GUNYp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jul 2011 09:24:45 -0400
Content-Disposition: inline
In-Reply-To: <1311173689-17419-22-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- unify vlan and nonvlan path
- kill qdev->vlgrp and qlge_vlan_rx_register
- allow to turn on/off rx/tx vlan accel via ethtool (set_features)

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/qlge/qlge.h      |    3 +-
 drivers/net/qlge/qlge_main.c |  163 ++++++++++++++++++++++++------------------
 2 files changed, 94 insertions(+), 72 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index 794252c..8731f79 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -11,6 +11,7 @@
 #include <linux/pci.h>
 #include <linux/netdevice.h>
 #include <linux/rtnetlink.h>
+#include <linux/if_vlan.h>
 
 /*
  * General definitions...
@@ -2052,7 +2053,7 @@ struct ql_adapter {
 
 	struct nic_stats nic_stats;
 
-	struct vlan_group *vlgrp;
+	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
 
 	/* PCI Configuration information for this device */
 	struct pci_dev *pdev;
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 68fbfac..743e3ec 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -7,6 +7,7 @@
  */
 #include <linux/kernel.h>
 #include <linux/init.h>
+#include <linux/bitops.h>
 #include <linux/types.h>
 #include <linux/module.h>
 #include <linux/list.h>
@@ -33,6 +34,7 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
+#include <linux/if_vlan.h>
 #include <linux/skbuff.h>
 #include <linux/if_vlan.h>
 #include <linux/delay.h>
@@ -415,7 +417,7 @@ static int ql_set_mac_addr_reg(struct ql_adapter *qdev, u8 *addr, u32 type,
 				      (qdev->
 				       func << CAM_OUT_FUNC_SHIFT) |
 					(0 << CAM_OUT_CQ_ID_SHIFT));
-			if (qdev->vlgrp)
+			if (qdev->ndev->features & NETIF_F_HW_VLAN_RX)
 				cam_output |= CAM_OUT_RV;
 			/* route to NIC core */
 			ql_write32(qdev, MAC_ADDR_DATA, cam_output);
@@ -1507,10 +1509,9 @@ static void ql_process_mac_rx_gro_page(struct ql_adapter *qdev,
 	rx_ring->rx_bytes += length;
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 	skb_record_rx_queue(skb, rx_ring->cq_id);
-	if (qdev->vlgrp && (vlan_id != 0xffff))
-		vlan_gro_frags(&rx_ring->napi, qdev->vlgrp, vlan_id);
-	else
-		napi_gro_frags(napi);
+	if (vlan_id != 0xffff)
+		__vlan_hwaccel_put_tag(skb, vlan_id);
+	napi_gro_frags(napi);
 }
 
 /* Process an inbound completion from an rx ring. */
@@ -1594,17 +1595,12 @@ static void ql_process_mac_rx_page(struct ql_adapter *qdev,
 	}
 
 	skb_record_rx_queue(skb, rx_ring->cq_id);
-	if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
-		if (qdev->vlgrp && (vlan_id != 0xffff))
-			vlan_gro_receive(napi, qdev->vlgrp, vlan_id, skb);
-		else
-			napi_gro_receive(napi, skb);
-	} else {
-		if (qdev->vlgrp && (vlan_id != 0xffff))
-			vlan_hwaccel_receive_skb(skb, qdev->vlgrp, vlan_id);
-		else
-			netif_receive_skb(skb);
-	}
+	if (vlan_id != 0xffff)
+		__vlan_hwaccel_put_tag(skb, vlan_id);
+	if (skb->ip_summed == CHECKSUM_UNNECESSARY)
+		napi_gro_receive(napi, skb);
+	else
+		netif_receive_skb(skb);
 	return;
 err_out:
 	dev_kfree_skb_any(skb);
@@ -1707,18 +1703,12 @@ static void ql_process_mac_rx_skb(struct ql_adapter *qdev,
 	}
 
 	skb_record_rx_queue(skb, rx_ring->cq_id);
-	if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
-		if (qdev->vlgrp && (vlan_id != 0xffff))
-			vlan_gro_receive(&rx_ring->napi, qdev->vlgrp,
-						vlan_id, skb);
-		else
-			napi_gro_receive(&rx_ring->napi, skb);
-	} else {
-		if (qdev->vlgrp && (vlan_id != 0xffff))
-			vlan_hwaccel_receive_skb(skb, qdev->vlgrp, vlan_id);
-		else
-			netif_receive_skb(skb);
-	}
+	if (vlan_id != 0xffff)
+		__vlan_hwaccel_put_tag(skb, vlan_id);
+	if (skb->ip_summed == CHECKSUM_UNNECESSARY)
+		napi_gro_receive(&rx_ring->napi, skb);
+	else
+		netif_receive_skb(skb);
 }
 
 static void ql_realign_skb(struct sk_buff *skb, int len)
@@ -2028,22 +2018,12 @@ static void ql_process_mac_split_rx_intr(struct ql_adapter *qdev,
 	rx_ring->rx_packets++;
 	rx_ring->rx_bytes += skb->len;
 	skb_record_rx_queue(skb, rx_ring->cq_id);
-	if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
-		if (qdev->vlgrp &&
-			(ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_V) &&
-			(vlan_id != 0))
-			vlan_gro_receive(&rx_ring->napi, qdev->vlgrp,
-				vlan_id, skb);
-		else
-			napi_gro_receive(&rx_ring->napi, skb);
-	} else {
-		if (qdev->vlgrp &&
-			(ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_V) &&
-			(vlan_id != 0))
-			vlan_hwaccel_receive_skb(skb, qdev->vlgrp, vlan_id);
-		else
-			netif_receive_skb(skb);
-	}
+	if ((ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_V) && (vlan_id != 0))
+		__vlan_hwaccel_put_tag(skb, vlan_id);
+	if (skb->ip_summed == CHECKSUM_UNNECESSARY)
+		napi_gro_receive(&rx_ring->napi, skb);
+	else
+		netif_receive_skb(skb);
 }
 
 /* Process an inbound completion from an rx ring. */
@@ -2334,71 +2314,111 @@ static int ql_napi_poll_msix(struct napi_struct *napi, int budget)
 	return work_done;
 }
 
-static void qlge_vlan_rx_register(struct net_device *ndev, struct vlan_group *grp)
+static void qlge_vlan_mode(struct net_device *ndev, u32 features)
 {
 	struct ql_adapter *qdev = netdev_priv(ndev);
 
-	qdev->vlgrp = grp;
-	if (grp) {
-		netif_printk(qdev, ifup, KERN_DEBUG, qdev->ndev,
+	if (features & NETIF_F_HW_VLAN_RX) {
+		netif_printk(qdev, ifup, KERN_DEBUG, ndev,
 			     "Turning on VLAN in NIC_RCV_CFG.\n");
 		ql_write32(qdev, NIC_RCV_CFG, NIC_RCV_CFG_VLAN_MASK |
-			   NIC_RCV_CFG_VLAN_MATCH_AND_NON);
+				 NIC_RCV_CFG_VLAN_MATCH_AND_NON);
 	} else {
-		netif_printk(qdev, ifup, KERN_DEBUG, qdev->ndev,
+		netif_printk(qdev, ifup, KERN_DEBUG, ndev,
 			     "Turning off VLAN in NIC_RCV_CFG.\n");
 		ql_write32(qdev, NIC_RCV_CFG, NIC_RCV_CFG_VLAN_MASK);
 	}
 }
 
-static void qlge_vlan_rx_add_vid(struct net_device *ndev, u16 vid)
+static u32 qlge_fix_features(struct net_device *ndev, u32 features)
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
+static int qlge_set_features(struct net_device *ndev, u32 features)
+{
+	u32 changed = ndev->features ^ features;
+
+	if (changed & NETIF_F_HW_VLAN_RX)
+		qlge_vlan_mode(ndev, features);
+
+	return 0;
+}
+
+static void __qlge_vlan_rx_add_vid(struct ql_adapter *qdev, u16 vid)
 {
-	struct ql_adapter *qdev = netdev_priv(ndev);
 	u32 enable_bit = MAC_ADDR_E;
-	int status;
 
-	status = ql_sem_spinlock(qdev, SEM_MAC_ADDR_MASK);
-	if (status)
-		return;
 	if (ql_set_mac_addr_reg
 	    (qdev, (u8 *) &enable_bit, MAC_ADDR_TYPE_VLAN, vid)) {
 		netif_err(qdev, ifup, qdev->ndev,
 			  "Failed to init vlan address.\n");
 	}
-	ql_sem_unlock(qdev, SEM_MAC_ADDR_MASK);
 }
 
-static void qlge_vlan_rx_kill_vid(struct net_device *ndev, u16 vid)
+static void qlge_vlan_rx_add_vid(struct net_device *ndev, u16 vid)
 {
 	struct ql_adapter *qdev = netdev_priv(ndev);
-	u32 enable_bit = 0;
 	int status;
 
 	status = ql_sem_spinlock(qdev, SEM_MAC_ADDR_MASK);
 	if (status)
 		return;
 
+	__qlge_vlan_rx_add_vid(qdev, vid);
+	set_bit(vid, qdev->active_vlans);
+
+	ql_sem_unlock(qdev, SEM_MAC_ADDR_MASK);
+}
+
+static void __qlge_vlan_rx_kill_vid(struct ql_adapter *qdev, u16 vid)
+{
+	u32 enable_bit = 0;
+
 	if (ql_set_mac_addr_reg
 	    (qdev, (u8 *) &enable_bit, MAC_ADDR_TYPE_VLAN, vid)) {
 		netif_err(qdev, ifup, qdev->ndev,
 			  "Failed to clear vlan address.\n");
 	}
-	ql_sem_unlock(qdev, SEM_MAC_ADDR_MASK);
+}
+
+static void qlge_vlan_rx_kill_vid(struct net_device *ndev, u16 vid)
+{
+	struct ql_adapter *qdev = netdev_priv(ndev);
+	int status;
+
+	status = ql_sem_spinlock(qdev, SEM_MAC_ADDR_MASK);
+	if (status)
+		return;
+
+	__qlge_vlan_rx_kill_vid(qdev, vid);
+	clear_bit(vid, qdev->active_vlans);
 
+	ql_sem_unlock(qdev, SEM_MAC_ADDR_MASK);
 }
 
 static void qlge_restore_vlan(struct ql_adapter *qdev)
 {
-	qlge_vlan_rx_register(qdev->ndev, qdev->vlgrp);
+	int status;
+	u16 vid;
 
-	if (qdev->vlgrp) {
-		u16 vid;
-		for (vid = 0; vid < VLAN_N_VID; vid++) {
-			if (!vlan_group_get_device(qdev->vlgrp, vid))
-				continue;
-			qlge_vlan_rx_add_vid(qdev->ndev, vid);
-		}
-	}
+	status = ql_sem_spinlock(qdev, SEM_MAC_ADDR_MASK);
+	if (status)
+		return;
+
+	for_each_set_bit(vid, qdev->active_vlans, VLAN_N_VID)
+		__qlge_vlan_rx_add_vid(qdev, vid);
+
+	ql_sem_unlock(qdev, SEM_MAC_ADDR_MASK);
 }
 
 /* MSI-X Multiple Vector Interrupt Handler for inbound completions. */
@@ -4661,7 +4681,8 @@ static const struct net_device_ops qlge_netdev_ops = {
 	.ndo_set_mac_address	= qlge_set_mac_address,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_tx_timeout		= qlge_tx_timeout,
-	.ndo_vlan_rx_register	= qlge_vlan_rx_register,
+	.ndo_fix_features	= qlge_fix_features,
+	.ndo_set_features	= qlge_set_features,
 	.ndo_vlan_rx_add_vid	= qlge_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	= qlge_vlan_rx_kill_vid,
 };
-- 
1.7.6

