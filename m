From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 06/21] atl1e: do vlan cleanup
Date: Fri, 15 Jul 2011 23:33:24 +0200
Message-ID: <1310765619-27827-7-git-send-email-jpirko@redhat.com>
References: <1310765619-27827-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51907 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751762Ab1GOVd7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jul 2011 17:33:59 -0400
In-Reply-To: <1310765619-27827-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- unify vlan and nonvlan rx path
- kill adapter->vlgrp and atl1e_vlan_rx_register
- enable vlan hw accel always

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/atl1e/atl1e.h      |    1 -
 drivers/net/atl1e/atl1e_main.c |   49 +++++-----------------------------------
 2 files changed, 6 insertions(+), 44 deletions(-)

diff --git a/drivers/net/atl1e/atl1e.h b/drivers/net/atl1e/atl1e.h
index 8c8181b..829b5ad 100644
--- a/drivers/net/atl1e/atl1e.h
+++ b/drivers/net/atl1e/atl1e.h
@@ -433,7 +433,6 @@ struct atl1e_rx_ring {
 struct atl1e_adapter {
 	struct net_device   *netdev;
 	struct pci_dev      *pdev;
-	struct vlan_group   *vlgrp;
 	struct napi_struct  napi;
 	struct mii_if_info  mii;    /* MII interface info */
 	struct atl1e_hw        hw;
diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e_main.c
index c3c5db1..c4c022a 100644
--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -313,36 +313,6 @@ static void atl1e_set_multi(struct net_device *netdev)
 	}
 }
 
-static void atl1e_vlan_rx_register(struct net_device *netdev,
-				   struct vlan_group *grp)
-{
-	struct atl1e_adapter *adapter = netdev_priv(netdev);
-	u32 mac_ctrl_data = 0;
-
-	netdev_dbg(adapter->netdev, "%s\n", __func__);
-
-	atl1e_irq_disable(adapter);
-
-	adapter->vlgrp = grp;
-	mac_ctrl_data = AT_READ_REG(&adapter->hw, REG_MAC_CTRL);
-
-	if (grp) {
-		/* enable VLAN tag insert/strip */
-		mac_ctrl_data |= MAC_CTRL_RMV_VLAN;
-	} else {
-		/* disable VLAN tag insert/strip */
-		mac_ctrl_data &= ~MAC_CTRL_RMV_VLAN;
-	}
-
-	AT_WRITE_REG(&adapter->hw, REG_MAC_CTRL, mac_ctrl_data);
-	atl1e_irq_enable(adapter);
-}
-
-static void atl1e_restore_vlan(struct atl1e_adapter *adapter)
-{
-	netdev_dbg(adapter->netdev, "%s\n", __func__);
-	atl1e_vlan_rx_register(adapter->netdev, adapter->vlgrp);
-}
 /*
  * atl1e_set_mac - Change the Ethernet Address of the NIC
  * @netdev: network interface device structure
@@ -1039,8 +1009,7 @@ static void atl1e_setup_mac_ctrl(struct atl1e_adapter *adapter)
 	value |= (((u32)adapter->hw.preamble_len &
 		  MAC_CTRL_PRMLEN_MASK) << MAC_CTRL_PRMLEN_SHIFT);
 
-	if (adapter->vlgrp)
-		value |= MAC_CTRL_RMV_VLAN;
+	value |= MAC_CTRL_RMV_VLAN;
 
 	value |= MAC_CTRL_BC_EN;
 	if (netdev->flags & IFF_PROMISC)
@@ -1423,19 +1392,16 @@ static void atl1e_clean_rx_irq(struct atl1e_adapter *adapter, u8 que,
 			skb->protocol = eth_type_trans(skb, netdev);
 			atl1e_rx_checksum(adapter, skb, prrs);
 
-			if (unlikely(adapter->vlgrp &&
-				(prrs->pkt_flag & RRS_IS_VLAN_TAG))) {
+			if (prrs->pkt_flag & RRS_IS_VLAN_TAG) {
 				u16 vlan_tag = (prrs->vtag >> 4) |
 					       ((prrs->vtag & 7) << 13) |
 					       ((prrs->vtag & 8) << 9);
 				netdev_dbg(netdev,
 					   "RXD VLAN TAG<RRD>=0x%04x\n",
 					   prrs->vtag);
-				vlan_hwaccel_receive_skb(skb, adapter->vlgrp,
-							 vlan_tag);
-			} else {
-				netif_receive_skb(skb);
+				__vlan_hwaccel_put_tag(skb, vlan_tag);
 			}
+			netif_receive_skb(skb);
 
 skip_pkt:
 	/* skip current packet whether it's ok or not. */
@@ -1811,7 +1777,7 @@ static netdev_tx_t atl1e_xmit_frame(struct sk_buff *skb,
 
 	tpd = atl1e_get_tpd(adapter);
 
-	if (unlikely(vlan_tx_tag_present(skb))) {
+	if (vlan_tx_tag_present(skb)) {
 		u16 vlan_tag = vlan_tx_tag_get(skb);
 		u16 atl1e_vlan_tag;
 
@@ -1898,7 +1864,6 @@ int atl1e_up(struct atl1e_adapter *adapter)
 	}
 	atl1e_init_ring_ptrs(adapter);
 	atl1e_set_multi(netdev);
-	atl1e_restore_vlan(adapter);
 
 	if (atl1e_configure(adapter)) {
 		err = -EIO;
@@ -2093,8 +2058,7 @@ static int atl1e_suspend(struct pci_dev *pdev, pm_message_t state)
 				 MAC_CTRL_PRMLEN_MASK) <<
 				 MAC_CTRL_PRMLEN_SHIFT);
 
-		if (adapter->vlgrp)
-			mac_ctrl_data |= MAC_CTRL_RMV_VLAN;
+		mac_ctrl_data |= MAC_CTRL_RMV_VLAN;
 
 		/* magic packet maybe Broadcast&multicast&Unicast frame */
 		if (wufc & AT_WUFC_MAG)
@@ -2198,7 +2162,6 @@ static const struct net_device_ops atl1e_netdev_ops = {
 	.ndo_change_mtu		= atl1e_change_mtu,
 	.ndo_do_ioctl		= atl1e_ioctl,
 	.ndo_tx_timeout		= atl1e_tx_timeout,
-	.ndo_vlan_rx_register	= atl1e_vlan_rx_register,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= atl1e_netpoll,
 #endif
-- 
1.7.6

