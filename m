From: David Dillow <dave@thedillows.org>
Subject: [PATCH 2/2] typhoon: update to new VLAN acceleration model
Date: Sun, 24 Oct 2010 16:20:21 -0400
Message-ID: <1287951621-25170-2-git-send-email-dave@thedillows.org>
References: <1287951621-25170-1-git-send-email-dave@thedillows.org>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from amavis-smtp.knology.net ([75.76.199.6]:45087 "EHLO
	amavis-smtp.knology.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757157Ab0JXUU2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Oct 2010 16:20:28 -0400
In-Reply-To: <1287951621-25170-1-git-send-email-dave@thedillows.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also correct the byteswapping as we keep the TCI in host order.

Signed-off-by: David Dillow <dave@thedillows.org>
---
 drivers/net/typhoon.c |   88 ++++++++++++++-----------------------------------
 1 files changed, 25 insertions(+), 63 deletions(-)

diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 5957d4e..b550da0 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -24,10 +24,6 @@
 	3XP Processor. It has been tested on x86 and sparc64.
 
 	KNOWN ISSUES:
-	*) The current firmware always strips the VLAN tag off, even if
-		we tell it not to. You should filter VLANs at the switch
-		as a workaround (good practice in any event) until we can
-		get this fixed.
 	*) Cannot DMA Rx packets to a 2 byte aligned address. Also firmware
 		issue. Hopefully 3Com will fix it.
 	*) Waiting for a command response takes 8ms due to non-preemptable
@@ -280,8 +276,6 @@ struct typhoon {
 	struct pci_dev *	pdev;
 	struct net_device *	dev;
 	struct napi_struct	napi;
-	spinlock_t		state_lock;
-	struct vlan_group *	vlgrp;
 	struct basic_ring	rxHiRing;
 	struct basic_ring	rxBuffRing;
 	struct rxbuff_ent	rxbuffers[RXENT_ENTRIES];
@@ -695,44 +689,6 @@ out:
 	return err;
 }
 
-static void
-typhoon_vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
-{
-	struct typhoon *tp = netdev_priv(dev);
-	struct cmd_desc xp_cmd;
-	int err;
-
-	spin_lock_bh(&tp->state_lock);
-	if(!tp->vlgrp != !grp) {
-		/* We've either been turned on for the first time, or we've
-		 * been turned off. Update the 3XP.
-		 */
-		if(grp)
-			tp->offload |= TYPHOON_OFFLOAD_VLAN;
-		else
-			tp->offload &= ~TYPHOON_OFFLOAD_VLAN;
-
-		/* If the interface is up, the runtime is running -- and we
-		 * must be up for the vlan core to call us.
-		 *
-		 * Do the command outside of the spin lock, as it is slow.
-		 */
-		INIT_COMMAND_WITH_RESPONSE(&xp_cmd,
-					TYPHOON_CMD_SET_OFFLOAD_TASKS);
-		xp_cmd.parm2 = tp->offload;
-		xp_cmd.parm3 = tp->offload;
-		spin_unlock_bh(&tp->state_lock);
-		err = typhoon_issue_command(tp, 1, &xp_cmd, 0, NULL);
-		if(err < 0)
-			netdev_err(tp->dev, "vlan offload error %d\n", -err);
-		spin_lock_bh(&tp->state_lock);
-	}
-
-	/* now make the change visible */
-	tp->vlgrp = grp;
-	spin_unlock_bh(&tp->state_lock);
-}
-
 static inline void
 typhoon_tso_fill(struct sk_buff *skb, struct transmit_ring *txRing,
 			u32 ring_dma)
@@ -818,7 +774,7 @@ typhoon_start_tx(struct sk_buff *skb, struct net_device *dev)
 		first_txd->processFlags |=
 		    TYPHOON_TX_PF_INSERT_VLAN | TYPHOON_TX_PF_VLAN_PRIORITY;
 		first_txd->processFlags |=
-		    cpu_to_le32(ntohs(vlan_tx_tag_get(skb)) <<
+		    cpu_to_le32(htons(vlan_tx_tag_get(skb)) <<
 				TYPHOON_TX_PF_VLAN_TAG_SHIFT);
 	}
 
@@ -1198,6 +1154,20 @@ typhoon_get_rx_csum(struct net_device *dev)
 	return 1;
 }
 
+static int
+typhoon_set_flags(struct net_device *dev, u32 data)
+{
+	/* There's no way to turn off the RX VLAN offloading and stripping
+	 * on the current 3XP firmware -- it does not respect the offload
+	 * settings -- so we only allow the user to toggle the TX processing.
+	 */
+	if (!(data & ETH_FLAG_RXVLAN))
+		return -EINVAL;
+
+	return ethtool_op_set_flags(dev, data,
+				    ETH_FLAG_RXVLAN | ETH_FLAG_TXVLAN);
+}
+
 static void
 typhoon_get_ringparam(struct net_device *dev, struct ethtool_ringparam *ering)
 {
@@ -1224,6 +1194,8 @@ static const struct ethtool_ops typhoon_ethtool_ops = {
 	.set_sg			= ethtool_op_set_sg,
 	.set_tso		= ethtool_op_set_tso,
 	.get_ringparam		= typhoon_get_ringparam,
+	.set_flags		= typhoon_set_flags,
+	.get_flags		= ethtool_op_get_flags,
 };
 
 static int
@@ -1309,9 +1281,9 @@ typhoon_init_interface(struct typhoon *tp)
 
 	tp->offload = TYPHOON_OFFLOAD_IP_CHKSUM | TYPHOON_OFFLOAD_TCP_CHKSUM;
 	tp->offload |= TYPHOON_OFFLOAD_UDP_CHKSUM | TSO_OFFLOAD_ON;
+	tp->offload |= TYPHOON_OFFLOAD_VLAN;
 
 	spin_lock_init(&tp->command_lock);
-	spin_lock_init(&tp->state_lock);
 
 	/* Force the writes to the shared memory area out before continuing. */
 	wmb();
@@ -1762,13 +1734,10 @@ typhoon_rx(struct typhoon *tp, struct basic_ring *rxRing, volatile __le32 * read
 		} else
 			skb_checksum_none_assert(new_skb);
 
-		spin_lock(&tp->state_lock);
-		if(tp->vlgrp != NULL && rx->rxStatus & TYPHOON_RX_VLAN)
-			vlan_hwaccel_receive_skb(new_skb, tp->vlgrp,
-						 ntohl(rx->vlanTag) & 0xffff);
-		else
-			netif_receive_skb(new_skb);
-		spin_unlock(&tp->state_lock);
+		if (rx->rxStatus & TYPHOON_RX_VLAN)
+			__vlan_hwaccel_put_tag(new_skb,
+					       ntohl(rx->vlanTag) & 0xffff);
+		netif_receive_skb(new_skb);
 
 		received++;
 		budget--;
@@ -1989,11 +1958,9 @@ typhoon_start_runtime(struct typhoon *tp)
 		goto error_out;
 
 	INIT_COMMAND_NO_RESPONSE(&xp_cmd, TYPHOON_CMD_SET_OFFLOAD_TASKS);
-	spin_lock_bh(&tp->state_lock);
 	xp_cmd.parm2 = tp->offload;
 	xp_cmd.parm3 = tp->offload;
 	err = typhoon_issue_command(tp, 1, &xp_cmd, 0, NULL);
-	spin_unlock_bh(&tp->state_lock);
 	if(err < 0)
 		goto error_out;
 
@@ -2231,13 +2198,9 @@ typhoon_suspend(struct pci_dev *pdev, pm_message_t state)
 	if(!netif_running(dev))
 		return 0;
 
-	spin_lock_bh(&tp->state_lock);
-	if(tp->vlgrp && tp->wol_events & TYPHOON_WAKE_MAGIC_PKT) {
-		spin_unlock_bh(&tp->state_lock);
-		netdev_err(dev, "cannot do WAKE_MAGIC with VLANS\n");
-		return -EBUSY;
-	}
-	spin_unlock_bh(&tp->state_lock);
+	/* TYPHOON_OFFLOAD_VLAN is always on now, so this doesn't work */
+	if(tp->wol_events & TYPHOON_WAKE_MAGIC_PKT)
+		netdev_warn(dev, "cannot do WAKE_MAGIC with VLAN offloading\n");
 
 	netif_device_detach(dev);
 
@@ -2338,7 +2301,6 @@ static const struct net_device_ops typhoon_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= typhoon_set_mac_address,
 	.ndo_change_mtu		= eth_change_mtu,
-	.ndo_vlan_rx_register	= typhoon_vlan_rx_register,
 };
 
 static int __devinit
-- 
1.7.2.3

