From: David Dillow <dave@thedillows.org>
Subject: [PATCH 2.6-bk] typhoon: PCI cleanups and ethtool_ops conversion
Date: 10 Sep 2004 16:47:18 -0400
Sender: linux-net-owner@vger.kernel.org
Message-ID: <1094849238.3900.11.camel@ori.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, Netdev <netdev@oss.sgi.com>,
	rl@hellgate.ch
Return-path: <linux-net-owner@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
List-Id: netdev.vger.kernel.org

Jeff, please do a

	bk pull http://typhoon.bkbits.net/typhoon-2.5

This will update the following files:

 drivers/net/typhoon.c |  259
++++++++++++++++++++++++++------------------------
 1 files changed, 136 insertions(+), 123 deletions(-)

through these ChangeSets:

<dave@thedillows.org> (04/09/09 1.2061)
   PCI cleanups and convert to ethtool_ops
   *) Reorder MWI initialization
   *) Perform proper cleanup on probe failure
   *) Remove cruft, and avoid locking up NIC on reset
   
   Signed-off-by: David A. Dillow <dave@thedillows.org>




# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/09/09 22:57:10-04:00 dave@thedillows.org 
#   PCI cleanups and convert to ethtool_ops
#   *) Reorder MWI initialization
#   *) Perform proper cleanup on probe failure
#   *) Remove cruft, and avoid locking up NIC on reset
#   
#   Signed-off-by: David A. Dillow <dave@thedillows.org>
# 
# drivers/net/typhoon.c
#   2004/09/09 22:49:47-04:00 dave@thedillows.org +12 -4
#   Update release date and version, add TODO list.
# 
# drivers/net/typhoon.c
#   2004/09/09 00:55:56-04:00 dave@thedillows.org +0 -6
#   Remove cruft from when the typhoon driver left the NIC in D3 state.
#   Its remove could be a problem on a warm-boot from Windows if 3Com's
#   drivers left the card in D3, but they don't do that, and the code
#   is blocking progress elsewhere in the PCI system.
# 
# drivers/net/typhoon.c
#   2004/09/09 00:30:09-04:00 dave@thedillows.org +81 -84
#   Convert to using ethtool_ops, and add some extra abilities.
# 
# drivers/net/typhoon.c
#   2004/09/08 23:30:07-04:00 dave@thedillows.org +14 -14
#   Make use of netdev_priv()
# 
# drivers/net/typhoon.c
#   2004/09/08 01:28:47-04:00 dave@thedillows.org +9 -8
#   Still seeing hangs with 100us wait, so bump it to 5ms if we can
#   sleep, and 500us otherwise.
# 
# drivers/net/typhoon.c
#   2004/09/08 00:50:01-04:00 dave@thedillows.org +21 -8
#   PCI cleanups:
#   * move pci_set_mwi() earlier in setup
#   * call pci_clear_mwi() in ->remove() and ->probe() error path
#   * call pci_disable_device() on probe error
#   * make use of DMA_32BIT_MASK constant
# 
diff -Nru a/drivers/net/typhoon.c b/drivers/net/typhoon.c
--- a/drivers/net/typhoon.c	2004-09-09 22:59:32 -04:00
+++ b/drivers/net/typhoon.c	2004-09-09 22:59:32 -04:00
@@ -1,6 +1,6 @@
 /* typhoon.c: A Linux Ethernet device driver for 3Com 3CR990 family of NICs */
 /*
-	Written 2002-2003 by David Dillow <dave@thedillows.org>
+	Written 2002-2004 by David Dillow <dave@thedillows.org>
 	Based on code written 1998-2000 by Donald Becker <becker@scyld.com> and
 	Linux 2.2.x driver by David P. McLean <davidpmclean@yahoo.com>.
 
@@ -33,8 +33,16 @@
 	*) Waiting for a command response takes 8ms due to non-preemptable
 		polling. Only significant for getting stats and creating
 		SAs, but an ugly wart never the less.
-	*) I've not tested multicast. I think it works, but reports welcome.
+
+	TODO:
 	*) Doesn't do IPSEC offloading. Yet. Keep yer pants on, it's coming.
+	*) Add more support for ethtool (especially for NIC stats)
+	*) Allow disabling of RX checksum offloading
+	*) Fix MAC changing to work while the interface is up
+		(Need to put commands on the TX ring, which changes
+		the locking)
+	*) Add in FCS to {rx,tx}_bytes, since the hardware doesn't. See
+		http://oss.sgi.com/cgi-bin/mesg.cgi?a=netdev&i=20031215152211.7003fe8e.rddunlap%40osdl.org
 */
 
 /* Set the copy breakpoint for the copy-only-tiny-frames scheme.
@@ -85,8 +93,8 @@
 #define PKT_BUF_SZ		1536
 
 #define DRV_MODULE_NAME		"typhoon"
-#define DRV_MODULE_VERSION 	"1.5.3"
-#define DRV_MODULE_RELDATE	"03/12/15"
+#define DRV_MODULE_VERSION 	"1.5.4"
+#define DRV_MODULE_RELDATE	"04/09/09"
 #define PFX			DRV_MODULE_NAME ": "
 #define ERR_PFX			KERN_ERR PFX
 
@@ -410,21 +418,22 @@
 out:
 	writel(TYPHOON_INTR_ALL, ioaddr + TYPHOON_REG_INTR_MASK);
 	writel(TYPHOON_INTR_ALL, ioaddr + TYPHOON_REG_INTR_STATUS);
-	udelay(100);
-	return err;
 
 	/* The 3XP seems to need a little extra time to complete the load
 	 * of the sleep image before we can reliably boot it. Failure to
 	 * do this occasionally results in a hung adapter after boot in
 	 * typhoon_init_one() while trying to read the MAC address or
 	 * putting the card to sleep. 3Com's driver waits 5ms, but
-	 * that seems to be overkill -- with a 50usec delay, it survives
-	 * 35000 typhoon_init_one() calls, where it only make it 25-100
-	 * without it.
-	 *
-	 * As it turns out, still occasionally getting a hung adapter,
-	 * so I'm bumping it to 100us.
+	 * that seems to be overkill. However, if we can sleep, we might
+	 * as well give it that much time. Otherwise, we'll give it 500us,
+	 * which should be enough (I've see it work well at 100us, but still
+	 * saw occasional problems.)
 	 */
+	if(wait_type == WaitSleep)
+		msleep(5);
+	else
+		udelay(500);
+	return err;
 }
 
 static int
@@ -688,7 +697,7 @@
 static void
 typhoon_vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
 {
-	struct typhoon *tp = (struct typhoon *) dev->priv;
+	struct typhoon *tp = netdev_priv(dev);
 	struct cmd_desc xp_cmd;
 	int err;
 
@@ -726,7 +735,7 @@
 static void
 typhoon_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
 {
-	struct typhoon *tp = (struct typhoon *) dev->priv;
+	struct typhoon *tp = netdev_priv(dev);
 	spin_lock_bh(&tp->state_lock);
 	if(tp->vlgrp)
 		tp->vlgrp->vlan_devices[vid] = NULL;
@@ -757,7 +766,7 @@
 static int
 typhoon_start_tx(struct sk_buff *skb, struct net_device *dev)
 {
-	struct typhoon *tp = (struct typhoon *) dev->priv;
+	struct typhoon *tp = netdev_priv(dev);
 	struct transmit_ring *txRing;
 	struct tx_desc *txd, *first_txd;
 	dma_addr_t skb_dma;
@@ -908,7 +917,7 @@
 static void
 typhoon_set_rx_mode(struct net_device *dev)
 {
-	struct typhoon *tp = (struct typhoon *) dev->priv;
+	struct typhoon *tp = netdev_priv(dev);
 	struct cmd_desc xp_cmd;
 	u32 mc_filter[2];
 	u16 filter;
@@ -965,6 +974,9 @@
 
 	/* 3Com's Linux driver uses txMultipleCollisions as it's
 	 * collisions value, but there is some other collision info as well...
+	 *
+	 * The extra status reported would be a good candidate for
+	 * ethtool_ops->get_{strings,stats}()
 	 */
 	stats->tx_packets = le32_to_cpu(s->txPackets);
 	stats->tx_bytes = le32_to_cpu(s->txBytes);
@@ -1002,7 +1014,7 @@
 static struct net_device_stats *
 typhoon_get_stats(struct net_device *dev)
 {
-	struct typhoon *tp = (struct typhoon *) dev->priv;
+	struct typhoon *tp = netdev_priv(dev);
 	struct net_device_stats *stats = &tp->stats;
 	struct net_device_stats *saved = &tp->stats_saved;
 
@@ -1030,9 +1042,10 @@
 	return 0;
 }
 
-static inline void
-typhoon_ethtool_gdrvinfo(struct typhoon *tp, struct ethtool_drvinfo *info)
+static void
+typhoon_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
+	struct typhoon *tp = netdev_priv(dev);
 	struct pci_dev *pci_dev = tp->pdev;
 	struct cmd_desc xp_cmd;
 	struct resp_desc xp_resp[3];
@@ -1055,9 +1068,11 @@
 	strcpy(info->bus_info, pci_name(pci_dev));
 }
 
-static inline void
-typhoon_ethtool_gset(struct typhoon *tp, struct ethtool_cmd *cmd)
+static int
+typhoon_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
+	struct typhoon *tp = netdev_priv(dev);
+
 	cmd->supported = SUPPORTED_100baseT_Half | SUPPORTED_100baseT_Full |
 				SUPPORTED_Autoneg;
 
@@ -1107,15 +1122,19 @@
 		cmd->autoneg = AUTONEG_DISABLE;
 	cmd->maxtxpkt = 1;
 	cmd->maxrxpkt = 1;
+
+	return 0;
 }
 
-static inline int
-typhoon_ethtool_sset(struct typhoon *tp, struct ethtool_cmd *cmd)
+static int
+typhoon_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
+	struct typhoon *tp = netdev_priv(dev);
 	struct cmd_desc xp_cmd;
 	int xcvr;
 	int err;
 
+	err = -EINVAL;
 	if(cmd->autoneg == AUTONEG_ENABLE) {
 		xcvr = TYPHOON_XCVR_AUTONEG;
 	} else {
@@ -1125,23 +1144,23 @@
 			else if(cmd->speed == SPEED_100)
 				xcvr = TYPHOON_XCVR_100HALF;
 			else
-				return -EINVAL;
+				goto out;
 		} else if(cmd->duplex == DUPLEX_FULL) {
 			if(cmd->speed == SPEED_10)
 				xcvr = TYPHOON_XCVR_10FULL;
 			else if(cmd->speed == SPEED_100)
 				xcvr = TYPHOON_XCVR_100FULL;
 			else
-				return -EINVAL;
+				goto out;
 		} else
-			return -EINVAL;
+			goto out;
 	}
 
 	INIT_COMMAND_NO_RESPONSE(&xp_cmd, TYPHOON_CMD_XCVR_SELECT);
 	xp_cmd.parm1 = cpu_to_le16(xcvr);
 	err = typhoon_issue_command(tp, 1, &xp_cmd, 0, NULL);
 	if(err < 0)
-		return err;
+		goto out;
 
 	tp->xcvr_select = xcvr;
 	if(cmd->autoneg == AUTONEG_ENABLE) {
@@ -1152,93 +1171,80 @@
 		tp->duplex = cmd->duplex;
 	}
 
-	return 0;
+out:
+	return err;
 }
 
-static inline int
-typhoon_ethtool_ioctl(struct net_device *dev, void __user *useraddr)
+static void
+typhoon_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
-	struct typhoon *tp = (struct typhoon *) dev->priv;
-	u32 ethcmd;
+	struct typhoon *tp = netdev_priv(dev);
 
-	if(copy_from_user(&ethcmd, useraddr, sizeof(ethcmd)))
-		return -EFAULT;
-
-	switch (ethcmd) {
-	case ETHTOOL_GDRVINFO: {
-			struct ethtool_drvinfo info = { ETHTOOL_GDRVINFO };
-
-			typhoon_ethtool_gdrvinfo(tp, &info);
-			if(copy_to_user(useraddr, &info, sizeof(info)))
-				return -EFAULT;
-			return 0;
-		}
-	case ETHTOOL_GSET: {
-			struct ethtool_cmd cmd = { ETHTOOL_GSET };
-
-			typhoon_ethtool_gset(tp, &cmd);
-			if(copy_to_user(useraddr, &cmd, sizeof(cmd)))
-				return -EFAULT;
-			return 0;
-		}
-	case ETHTOOL_SSET: {
-			struct ethtool_cmd cmd;
-			if(copy_from_user(&cmd, useraddr, sizeof(cmd)))
-				return -EFAULT;
+	wol->supported = WAKE_PHY | WAKE_MAGIC;
+	wol->wolopts = 0;
+	if(tp->wol_events & TYPHOON_WAKE_LINK_EVENT)
+		wol->wolopts |= WAKE_PHY;
+	if(tp->wol_events & TYPHOON_WAKE_MAGIC_PKT)
+		wol->wolopts |= WAKE_MAGIC;
+	memset(&wol->sopass, 0, sizeof(wol->sopass));
+}
 
-			return typhoon_ethtool_sset(tp, &cmd);
-		}
-	case ETHTOOL_GLINK:{
-			struct ethtool_value edata = { ETHTOOL_GLINK };
+static int
+typhoon_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
+{
+	struct typhoon *tp = netdev_priv(dev);
 
-			edata.data = netif_carrier_ok(dev) ? 1 : 0;
-			if(copy_to_user(useraddr, &edata, sizeof(edata)))
-				return -EFAULT;
-			return 0;
-		}
-	case ETHTOOL_GWOL: {
-			struct ethtool_wolinfo wol = { ETHTOOL_GWOL };
+	if(wol->wolopts & ~(WAKE_PHY | WAKE_MAGIC))
+		return -EINVAL;
 
-			if(tp->wol_events & TYPHOON_WAKE_LINK_EVENT)
-				wol.wolopts |= WAKE_PHY;
-			if(tp->wol_events & TYPHOON_WAKE_MAGIC_PKT)
-				wol.wolopts |= WAKE_MAGIC;
-			if(copy_to_user(useraddr, &wol, sizeof(wol)))
-				return -EFAULT;
-			return 0;
-	}
-	case ETHTOOL_SWOL: {
-			struct ethtool_wolinfo wol;
-
-			if(copy_from_user(&wol, useraddr, sizeof(wol)))
-				return -EFAULT;
-			tp->wol_events = 0;
-			if(wol.wolopts & WAKE_PHY)
-				tp->wol_events |= TYPHOON_WAKE_LINK_EVENT;
-			if(wol.wolopts & WAKE_MAGIC)
-				tp->wol_events |= TYPHOON_WAKE_MAGIC_PKT;
-			return 0;
-	}
-	default:
-		break;
-	}
+	tp->wol_events = 0;
+	if(wol->wolopts & WAKE_PHY)
+		tp->wol_events |= TYPHOON_WAKE_LINK_EVENT;
+	if(wol->wolopts & WAKE_MAGIC)
+		tp->wol_events |= TYPHOON_WAKE_MAGIC_PKT;
 
-	return -EOPNOTSUPP;
+	return 0;
 }
 
-static int
-typhoon_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
+static u32
+typhoon_get_rx_csum(struct net_device *dev)
 {
-	switch (cmd) {
-	case SIOCETHTOOL:
-		return typhoon_ethtool_ioctl(dev, ifr->ifr_data);
-	default:
-		break;
-	}
-
-	return -EOPNOTSUPP;
+	/* For now, we don't allow turning off RX checksums.
+	 */
+	return 1;
 }
 
+static void
+typhoon_get_ringparam(struct net_device *dev, struct ethtool_ringparam *ering)
+{
+	ering->rx_max_pending = RXENT_ENTRIES;
+	ering->rx_mini_max_pending = 0;
+	ering->rx_jumbo_max_pending = 0;
+	ering->tx_max_pending = TXLO_ENTRIES - 1;
+
+	ering->rx_pending = RXENT_ENTRIES;
+	ering->rx_mini_pending = 0;
+	ering->rx_jumbo_pending = 0;
+	ering->tx_pending = TXLO_ENTRIES - 1;
+}
+
+static struct ethtool_ops typhoon_ethtool_ops = {
+	.get_settings		= typhoon_get_settings,
+	.set_settings		= typhoon_set_settings,
+	.get_drvinfo		= typhoon_get_drvinfo,
+	.get_wol		= typhoon_get_wol,
+	.set_wol		= typhoon_set_wol,
+	.get_link		= ethtool_op_get_link,
+	.get_rx_csum		= typhoon_get_rx_csum,
+	.get_tx_csum		= ethtool_op_get_tx_csum,
+	.set_tx_csum		= ethtool_op_set_tx_csum,
+	.get_sg			= ethtool_op_get_sg,
+	.set_sg			= ethtool_op_set_sg,
+	.get_tso		= ethtool_op_get_tso,
+	.set_tso		= ethtool_op_set_tso,
+	.get_ringparam		= typhoon_get_ringparam,
+};
+
 static int
 typhoon_wait_interrupt(unsigned long ioaddr)
 {
@@ -1756,7 +1762,7 @@
 static int
 typhoon_poll(struct net_device *dev, int *total_budget)
 {
-	struct typhoon *tp = (struct typhoon *) dev->priv;
+	struct typhoon *tp = netdev_priv(dev);
 	struct typhoon_indexes *indexes = tp->indexes;
 	int orig_budget = *total_budget;
 	int budget, work_done, done;
@@ -2068,7 +2074,7 @@
 static void
 typhoon_tx_timeout(struct net_device *dev)
 {
-	struct typhoon *tp = (struct typhoon *) dev->priv;
+	struct typhoon *tp = netdev_priv(dev);
 
 	if(typhoon_reset(dev->base_addr, WaitNoSleep) < 0) {
 		printk(KERN_WARNING "%s: could not reset in tx timeout\n",
@@ -2098,7 +2104,7 @@
 static int
 typhoon_open(struct net_device *dev)
 {
-	struct typhoon *tp = (struct typhoon *) dev->priv;
+	struct typhoon *tp = netdev_priv(dev);
 	int err;
 
 	err = typhoon_wakeup(tp, WaitSleep);
@@ -2140,7 +2146,7 @@
 static int
 typhoon_close(struct net_device *dev)
 {
-	struct typhoon *tp = (struct typhoon *) dev->priv;
+	struct typhoon *tp = netdev_priv(dev);
 
 	netif_stop_queue(dev);
 
@@ -2168,7 +2174,7 @@
 typhoon_resume(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
-	struct typhoon *tp = (struct typhoon *) dev->priv;
+	struct typhoon *tp = netdev_priv(dev);
 
 	/* If we're down, resume when we are upped.
 	 */
@@ -2200,7 +2206,7 @@
 typhoon_suspend(struct pci_dev *pdev, u32 state)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
-	struct typhoon *tp = (struct typhoon *) dev->priv;
+	struct typhoon *tp = netdev_priv(dev);
 	struct cmd_desc xp_cmd;
 
 	/* If we're down, we're already suspended.
@@ -2303,17 +2309,17 @@
 		goto error_out_dev;
 	}
 
-	/* If we transitioned from D3->D0 in pci_enable_device(),
-	 * we lost our configuration and need to restore it to the
-	 * conditions at boot.
-	 */
-	pci_restore_state(pdev, NULL);
+	err = pci_set_mwi(pdev);
+	if(err < 0) {
+		printk(ERR_PFX "%s: unable to set MWI\n", pci_name(pdev));
+		goto error_out_disable;
+	}
 
-	err = pci_set_dma_mask(pdev, 0xffffffffULL);
+	err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
 	if(err < 0) {
 		printk(ERR_PFX "%s: No usable DMA configuration\n",
 		       pci_name(pdev));
-		goto error_out_dev;
+		goto error_out_mwi;
 	}
 
 	/* sanity checks, resource #1 is our mmio area
@@ -2323,25 +2329,22 @@
 		       "%s: region #1 not a PCI MMIO resource, aborting\n",
 		       pci_name(pdev));
 		err = -ENODEV;
-		goto error_out_dev;
+		goto error_out_mwi;
 	}
 	if(pci_resource_len(pdev, 1) < 128) {
 		printk(ERR_PFX "%s: Invalid PCI MMIO region size, aborting\n",
 		       pci_name(pdev));
 		err = -ENODEV;
-		goto error_out_dev;
+		goto error_out_mwi;
 	}
 
 	err = pci_request_regions(pdev, "typhoon");
 	if(err < 0) {
 		printk(ERR_PFX "%s: could not request regions\n",
 		       pci_name(pdev));
-		goto error_out_dev;
+		goto error_out_mwi;
 	}
 
-	pci_set_master(pdev);
-	pci_set_mwi(pdev);
-
 	/* map our MMIO region
 	 */
 	ioaddr = pci_resource_start(pdev, 1);
@@ -2366,7 +2369,7 @@
 	}
 
 	dev->irq = pdev->irq;
-	tp = dev->priv;
+	tp = netdev_priv(dev);
 	tp->shared = (struct typhoon_shared *) shared;
 	tp->shared_dma = shared_dma;
 	tp->pdev = pdev;
@@ -2391,6 +2394,11 @@
 		goto error_out_dma;
 	}
 
+	/* Now that we've reset the 3XP and are sure it's not going to
+	 * write all over memory, enable bus mastering.
+	 */
+	pci_set_master(pdev);
+
 	/* dev->name is not valid until we register, but we need to
 	 * use some common routines to initialize the card. So that those
 	 * routines print the right name, we keep our oun pointer to the name
@@ -2460,11 +2468,11 @@
 	dev->set_multicast_list	= typhoon_set_rx_mode;
 	dev->tx_timeout		= typhoon_tx_timeout;
 	dev->poll		= typhoon_poll;
+	dev->ethtool_ops	= &typhoon_ethtool_ops;
 	dev->weight		= 16;
 	dev->watchdog_timeo	= TX_TIMEOUT;
 	dev->get_stats		= typhoon_get_stats;
 	dev->set_mac_address	= typhoon_set_mac_address;
-	dev->do_ioctl		= typhoon_ioctl;
 	dev->vlan_rx_register	= typhoon_vlan_rx_register;
 	dev->vlan_rx_kill_vid	= typhoon_vlan_rx_kill_vid;
 
@@ -2527,6 +2535,10 @@
 	iounmap((void *) ioaddr);
 error_out_regions:
 	pci_release_regions(pdev);
+error_out_mwi:
+	pci_clear_mwi(pdev);
+error_out_disable:
+	pci_disable_device(pdev);
 error_out_dev:
 	free_netdev(dev);
 error_out:
@@ -2537,7 +2549,7 @@
 typhoon_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
-	struct typhoon *tp = (struct typhoon *) (dev->priv);
+	struct typhoon *tp = netdev_priv(dev);
 
 	unregister_netdev(dev);
 	pci_set_power_state(pdev, 0);
@@ -2547,6 +2559,7 @@
 	pci_free_consistent(pdev, sizeof(struct typhoon_shared),
 			    tp->shared, tp->shared_dma);
 	pci_release_regions(pdev);
+	pci_clear_mwi(pdev);
 	pci_disable_device(pdev);
 	pci_set_drvdata(pdev, NULL);
 	free_netdev(dev);



