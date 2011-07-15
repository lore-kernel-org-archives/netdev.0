From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 05/21] atl1c: do vlan cleanup
Date: Fri, 15 Jul 2011 23:33:23 +0200
Message-ID: <1310765619-27827-6-git-send-email-jpirko@redhat.com>
References: <1310765619-27827-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18671 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753512Ab1GOVe0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jul 2011 17:34:26 -0400
In-Reply-To: <1310765619-27827-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- unify vlan and nonvlan rx path
- kill adapter->vlgrp and atl1c_vlan_rx_register
- enable vlan hw accel always

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/atl1c/atl1c.h      |    1 -
 drivers/net/atl1c/atl1c_main.c |   51 ++++-----------------------------------
 2 files changed, 6 insertions(+), 46 deletions(-)

diff --git a/drivers/net/atl1c/atl1c.h b/drivers/net/atl1c/atl1c.h
index 0f481b9..ca70e16 100644
--- a/drivers/net/atl1c/atl1c.h
+++ b/drivers/net/atl1c/atl1c.h
@@ -555,7 +555,6 @@ struct atl1c_smb {
 struct atl1c_adapter {
 	struct net_device   *netdev;
 	struct pci_dev      *pdev;
-	struct vlan_group   *vlgrp;
 	struct napi_struct  napi;
 	struct atl1c_hw        hw;
 	struct atl1c_hw_stats  hw_stats;
diff --git a/drivers/net/atl1c/atl1c_main.c b/drivers/net/atl1c/atl1c_main.c
index 1269ba5..2abef19 100644
--- a/drivers/net/atl1c/atl1c_main.c
+++ b/drivers/net/atl1c/atl1c_main.c
@@ -411,41 +411,6 @@ static void atl1c_set_multi(struct net_device *netdev)
 	}
 }
 
-static void atl1c_vlan_rx_register(struct net_device *netdev,
-				   struct vlan_group *grp)
-{
-	struct atl1c_adapter *adapter = netdev_priv(netdev);
-	struct pci_dev *pdev = adapter->pdev;
-	u32 mac_ctrl_data = 0;
-
-	if (netif_msg_pktdata(adapter))
-		dev_dbg(&pdev->dev, "atl1c_vlan_rx_register\n");
-
-	atl1c_irq_disable(adapter);
-
-	adapter->vlgrp = grp;
-	AT_READ_REG(&adapter->hw, REG_MAC_CTRL, &mac_ctrl_data);
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
-	atl1c_irq_enable(adapter);
-}
-
-static void atl1c_restore_vlan(struct atl1c_adapter *adapter)
-{
-	struct pci_dev *pdev = adapter->pdev;
-
-	if (netif_msg_pktdata(adapter))
-		dev_dbg(&pdev->dev, "atl1c_restore_vlan !");
-	atl1c_vlan_rx_register(adapter->netdev, adapter->vlgrp);
-}
 /*
  * atl1c_set_mac - Change the Ethernet Address of the NIC
  * @netdev: network interface device structure
@@ -1433,8 +1398,7 @@ static void atl1c_setup_mac_ctrl(struct atl1c_adapter *adapter)
 	mac_ctrl_data |= ((hw->preamble_len & MAC_CTRL_PRMLEN_MASK) <<
 			MAC_CTRL_PRMLEN_SHIFT);
 
-	if (adapter->vlgrp)
-		mac_ctrl_data |= MAC_CTRL_RMV_VLAN;
+	mac_ctrl_data |= MAC_CTRL_RMV_VLAN;
 
 	mac_ctrl_data |= MAC_CTRL_BC_EN;
 	if (netdev->flags & IFF_PROMISC)
@@ -1878,14 +1842,14 @@ rrs_checked:
 		skb_put(skb, length - ETH_FCS_LEN);
 		skb->protocol = eth_type_trans(skb, netdev);
 		atl1c_rx_checksum(adapter, skb, rrs);
-		if (unlikely(adapter->vlgrp) && rrs->word3 & RRS_VLAN_INS) {
+		if (rrs->word3 & RRS_VLAN_INS) {
 			u16 vlan;
 
 			AT_TAG_TO_VLAN(rrs->vlan_tag, vlan);
 			vlan = le16_to_cpu(vlan);
-			vlan_hwaccel_receive_skb(skb, adapter->vlgrp, vlan);
-		} else
-			netif_receive_skb(skb);
+			__vlan_hwaccel_put_tag(skb, vlan);
+		}
+		netif_receive_skb(skb);
 
 		(*work_done)++;
 		count++;
@@ -2320,7 +2284,6 @@ static int atl1c_up(struct atl1c_adapter *adapter)
 	netif_carrier_off(netdev);
 	atl1c_init_ring_ptrs(adapter);
 	atl1c_set_multi(netdev);
-	atl1c_restore_vlan(adapter);
 
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		num = atl1c_alloc_rx_buffer(adapter, i);
@@ -2507,8 +2470,7 @@ static int atl1c_suspend(struct device *dev)
 		/* clear phy interrupt */
 		atl1c_read_phy_reg(hw, MII_ISR, &mii_intr_status_data);
 		/* Config MAC Ctrl register */
-		if (adapter->vlgrp)
-			mac_ctrl_data |= MAC_CTRL_RMV_VLAN;
+		mac_ctrl_data |= MAC_CTRL_RMV_VLAN;
 
 		/* magic packet maybe Broadcast&multicast&Unicast frame */
 		if (wufc & AT_WUFC_MAG)
@@ -2588,7 +2550,6 @@ static const struct net_device_ops atl1c_netdev_ops = {
 	.ndo_do_ioctl		= atl1c_ioctl,
 	.ndo_tx_timeout		= atl1c_tx_timeout,
 	.ndo_get_stats		= atl1c_get_stats,
-	.ndo_vlan_rx_register	= atl1c_vlan_rx_register,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= atl1c_netpoll,
 #endif
-- 
1.7.6

