From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH v2 00/14] Move vlan acceleration into networking core.
Date: Wed, 20 Oct 2010 22:02:59 -0400
Message-ID: <1287626579.11431.9.camel@obelisk.thedillows.org>
References: <1287618974-4714-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from amavis-smtp.knology.net ([75.76.199.6]:36151 "EHLO
	amavis-smtp.knology.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757083Ab0JUCfK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Oct 2010 22:35:10 -0400
In-Reply-To: <1287618974-4714-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-10-20 at 16:56 -0700, Jesse Gross wrote:
> The first eleven patches can be applied immediately, while the last three need
> to wait until all drivers that support vlan acceleration are updated.  If
> people agree that this patch set makes sense I will go ahead and switch over
> the dozen or so drivers that would need to change.

Here's a first pass at converting typhoon to the new methods. It is
compile tested, but I have to put the hardware back in a machine to do
some testing, which I may not be able to do before the weekend.

Of course, we could just change it to not offload by default if we need
to push this sooner.

Applies to net-next-2.6 with the vlan changes.



diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 1cc6713..5ee0324 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -280,8 +280,6 @@ struct typhoon {
 	struct pci_dev *	pdev;
 	struct net_device *	dev;
 	struct napi_struct	napi;
-	spinlock_t		state_lock;
-	struct vlan_group *	vlgrp;
 	struct basic_ring	rxHiRing;
 	struct basic_ring	rxBuffRing;
 	struct rxbuff_ent	rxbuffers[RXENT_ENTRIES];
@@ -695,42 +693,39 @@ out:
 	return err;
 }
 
-static void
-typhoon_vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
+static int
+typhoon_offload_vlan(struct net_device *dev, bool enabled)
 {
 	struct typhoon *tp = netdev_priv(dev);
+	__le32 offload = tp->offload;
 	struct cmd_desc xp_cmd;
 	int err;
 
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
+	if (enabled)
+		offload |= TYPHOON_OFFLOAD_VLAN;
+	else
+		offload &= ~TYPHOON_OFFLOAD_VLAN;
+
+	if (offload == tp->offload)
+		return 0;
+
+	/* We've either been turned on for the first time, or we've
+	 * been turned off. Save the setting, and update the 3XP if the
+	 * runtime is active.
+	 *
+	 * Caller must hold the RTNL lock.
+	 */
+	tp->offload = offload;
+	if (!netif_running(dev))
+		return 0;
+
+	INIT_COMMAND_WITH_RESPONSE(&xp_cmd, TYPHOON_CMD_SET_OFFLOAD_TASKS);
+	xp_cmd.parm2 = tp->offload;
+	xp_cmd.parm3 = tp->offload;
+	err = typhoon_issue_command(tp, 1, &xp_cmd, 0, NULL);
+	if(err < 0)
+		netdev_err(tp->dev, "vlan offload error %d\n", -err);
+	return err;
 }
 
 static inline void
@@ -1198,6 +1193,30 @@ typhoon_get_rx_csum(struct net_device *dev)
 	return 1;
 }
 
+static int
+typhoon_set_flags(struct net_device *dev, u32 data)
+{
+	u32 orig_flags = dev->features;
+	int rc;
+
+	/* VLAN offloading is a package deal on the 3XP -- if enabled,
+	 * we'll always have RX offload active, but we can choose to
+	 * not use the TX offload.
+	 */
+	if ((data & ETH_FLAG_TXVLAN) && !(data & ETH_FLAG_RXVLAN))
+		return -EINVAL;
+
+	rc = ethtool_op_set_flags(dev, data, ETH_FLAG_RXVLAN | ETH_FLAG_TXVLAN);
+	if (rc)
+		return rc;
+
+	data &= ETH_FLAG_RXVLAN | ETH_FLAG_TXVLAN;
+	rc = typhoon_offload_vlan(dev, data);
+	if (rc)
+		dev->features = orig_flags;
+	return rc;
+}
+
 static void
 typhoon_get_ringparam(struct net_device *dev, struct ethtool_ringparam *ering)
 {
@@ -1224,6 +1243,8 @@ static const struct ethtool_ops typhoon_ethtool_ops = {
 	.set_sg			= ethtool_op_set_sg,
 	.set_tso		= ethtool_op_set_tso,
 	.get_ringparam		= typhoon_get_ringparam,
+	.set_flags		= typhoon_set_flags,
+	.get_flags		= ethtool_op_get_flags,
 };
 
 static int
@@ -1309,9 +1330,9 @@ typhoon_init_interface(struct typhoon *tp)
 
 	tp->offload = TYPHOON_OFFLOAD_IP_CHKSUM | TYPHOON_OFFLOAD_TCP_CHKSUM;
 	tp->offload |= TYPHOON_OFFLOAD_UDP_CHKSUM | TSO_OFFLOAD_ON;
+	tp->offload |= TYPHOON_OFFLOAD_VLAN;
 
 	spin_lock_init(&tp->command_lock);
-	spin_lock_init(&tp->state_lock);
 
 	/* Force the writes to the shared memory area out before continuing. */
 	wmb();
@@ -1762,13 +1783,10 @@ typhoon_rx(struct typhoon *tp, struct basic_ring *rxRing, volatile __le32 * read
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
@@ -1989,11 +2007,9 @@ typhoon_start_runtime(struct typhoon *tp)
 		goto error_out;
 
 	INIT_COMMAND_NO_RESPONSE(&xp_cmd, TYPHOON_CMD_SET_OFFLOAD_TASKS);
-	spin_lock_bh(&tp->state_lock);
 	xp_cmd.parm2 = tp->offload;
 	xp_cmd.parm3 = tp->offload;
 	err = typhoon_issue_command(tp, 1, &xp_cmd, 0, NULL);
-	spin_unlock_bh(&tp->state_lock);
 	if(err < 0)
 		goto error_out;
 
@@ -2231,13 +2247,9 @@ typhoon_suspend(struct pci_dev *pdev, pm_message_t state)
 	if(!netif_running(dev))
 		return 0;
 
-	spin_lock_bh(&tp->state_lock);
-	if(tp->vlgrp && tp->wol_events & TYPHOON_WAKE_MAGIC_PKT) {
-		spin_unlock_bh(&tp->state_lock);
-		netdev_err(dev, "cannot do WAKE_MAGIC with VLANS\n");
-		return -EBUSY;
-	}
-	spin_unlock_bh(&tp->state_lock);
+	if(tp->offload & TYPHOON_OFFLOAD_VLAN &&
+				tp->wol_events & TYPHOON_WAKE_MAGIC_PKT)
+		netdev_warn(dev, "WAKE_MAGIC does not work with VLANS\n");
 
 	netif_device_detach(dev);
 
@@ -2338,7 +2350,6 @@ static const struct net_device_ops typhoon_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= typhoon_set_mac_address,
 	.ndo_change_mtu		= eth_change_mtu,
-	.ndo_vlan_rx_register	= typhoon_vlan_rx_register,
 };
 
 static int __devinit


