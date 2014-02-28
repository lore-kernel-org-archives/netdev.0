From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net] bna: fix vlan tag stripping and implement its toggling
Date: Fri, 28 Feb 2014 10:11:14 +0100
Message-ID: <1393578674-12658-1-git-send-email-ivecera@redhat.com>
Cc: davem@davemloft.net, rmody@brocade.com, jiri@resnulli.us
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50617 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750907AbaB1JLW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Feb 2014 04:11:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The recent commit "fe1624c bna: RX Filter Enhancements" disables
VLAN tag stripping if the NIC is in promiscuous mode. This causes
__vlan_hwaccel_put_tag() is called when the stripping is disabled.
Because of this VLAN over bna does not work and causes BUGs in conjunction
with openvswitch like this:

=====
[18370.665074] kernel BUG at include/linux/skbuff.h:1497!
...
[18370.876769] Call Trace:
[18370.879455]  <IRQ>
[18370.881569]  [<ffffffffa063a3c6>] internal_dev_recv+0xb6/0x130 [openvswitch]
[18370.889552]  [<ffffffffa06398ed>] ovs_vport_send+0x1d/0x80 [openvswitch]
[18370.896922]  [<ffffffffa063016a>] do_output+0x2a/0x50 [openvswitch]
[18370.903814]  [<ffffffffa06304cd>] do_execute_actions+0x19d/0xb20 [openvswitch]
[18370.911757]  [<ffffffffa0630e7b>] ovs_execute_actions+0x2b/0x30 [openvswitch]
[18370.919602]  [<ffffffffa0633722>] ovs_dp_process_received_packet+0x92/0x120 [openvswitch]
[18370.928597]  [<ffffffff8109be83>] ? find_busiest_group+0x103/0x880
[18370.935396]  [<ffffffffa063982a>] ovs_vport_receive+0x2a/0x30 [openvswitch]
[18370.943053]  [<ffffffffa063a6b1>] netdev_frame_hook+0xc1/0x120 [openvswitch]
[18370.950802]  [<ffffffff814b27c2>] __netif_receive_skb_core+0x262/0x840
[18370.957982]  [<ffffffff81019a00>] ? flush_ptrace_hw_breakpoint+0x10/0x40
[18370.965349]  [<ffffffff814b2db8>] __netif_receive_skb+0x18/0x60
[18370.971855]  [<ffffffff814b2e33>] netif_receive_skb+0x33/0xb0
[18370.978172]  [<ffffffff814b3736>] napi_gro_frags+0x116/0x170
[18370.984407]  [<ffffffffa0c7aaa4>] bnad_napi_poll_rx+0x3f4/0x8f0 [bna]
[18370.991488]  [<ffffffff814b31ba>] net_rx_action+0x15a/0x250
...
===

The following patch makes the following changes so the driver:
1. Implements .ndo_set_features so an user can toggle VLAN tag stripping
   on/off
2. Does not disable VLAN tag stripping in promiscuous mode so the driver
   respect user's choice
3. Calls __vlan_hwaccel_put_tag() only when the stripping is enabled

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/brocade/bna/bnad.c | 36 ++++++++++++++++++++++++---------
 1 file changed, 27 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index cf64f3d..bc09056 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -707,7 +707,8 @@ bnad_cq_process(struct bnad *bnad, struct bna_ccb *ccb, int budget)
 		else
 			skb_checksum_none_assert(skb);
 
-		if (flags & BNA_CQ_EF_VLAN)
+		if ((flags & BNA_CQ_EF_VLAN) &&
+		    (bnad->netdev->features & NETIF_F_HW_VLAN_CTAG_RX))
 			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), ntohs(cmpl->vlan_tag));
 
 		if (BNAD_RXBUF_IS_SK_BUFF(unmap_q->type))
@@ -3245,11 +3246,6 @@ bnad_set_rx_mode(struct net_device *netdev)
 			BNA_RXMODE_ALLMULTI;
 	bna_rx_mode_set(bnad->rx_info[0].rx, new_mode, mode_mask, NULL);
 
-	if (bnad->cfg_flags & BNAD_CF_PROMISC)
-		bna_rx_vlan_strip_disable(bnad->rx_info[0].rx);
-	else
-		bna_rx_vlan_strip_enable(bnad->rx_info[0].rx);
-
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 }
 
@@ -3374,6 +3370,27 @@ bnad_vlan_rx_kill_vid(struct net_device *netdev, __be16 proto, u16 vid)
 	return 0;
 }
 
+int bnad_set_features(struct net_device *dev, netdev_features_t features)
+{
+	struct bnad *bnad = netdev_priv(dev);
+	netdev_features_t changed = features ^ dev->features;
+
+	if ((changed & NETIF_F_HW_VLAN_CTAG_RX) && netif_running(dev)) {
+		unsigned long flags;
+
+		spin_lock_irqsave(&bnad->bna_lock, flags);
+
+		if (features & NETIF_F_HW_VLAN_CTAG_RX)
+			bna_rx_vlan_strip_enable(bnad->rx_info[0].rx);
+		else
+			bna_rx_vlan_strip_disable(bnad->rx_info[0].rx);
+
+		spin_unlock_irqrestore(&bnad->bna_lock, flags);
+	}
+
+	return 0;
+}
+
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void
 bnad_netpoll(struct net_device *netdev)
@@ -3421,6 +3438,7 @@ static const struct net_device_ops bnad_netdev_ops = {
 	.ndo_change_mtu		= bnad_change_mtu,
 	.ndo_vlan_rx_add_vid    = bnad_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid   = bnad_vlan_rx_kill_vid,
+	.ndo_set_features	= bnad_set_features,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller    = bnad_netpoll
 #endif
@@ -3433,14 +3451,14 @@ bnad_netdev_init(struct bnad *bnad, bool using_dac)
 
 	netdev->hw_features = NETIF_F_SG | NETIF_F_RXCSUM |
 		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
-		NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_HW_VLAN_CTAG_TX;
+		NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_HW_VLAN_CTAG_TX |
+		NETIF_F_HW_VLAN_CTAG_RX;
 
 	netdev->vlan_features = NETIF_F_SG | NETIF_F_HIGHDMA |
 		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
 		NETIF_F_TSO | NETIF_F_TSO6;
 
-	netdev->features |= netdev->hw_features |
-		NETIF_F_HW_VLAN_CTAG_RX | NETIF_F_HW_VLAN_CTAG_FILTER;
+	netdev->features |= netdev->hw_features | NETIF_F_HW_VLAN_CTAG_FILTER;
 
 	if (using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
-- 
1.8.3.2
