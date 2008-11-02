From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver updates for 2.6.29
Date: Sun, 2 Nov 2008 09:12:54 -0500
Message-ID: <20081102141254.GA18264@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:54091 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753454AbYKBOMz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Nov 2008 09:12:55 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please pull from 'davem-next' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git davem-next

to receive the following updates:

 Documentation/networking/bonding.txt |   16 ++++---
 drivers/net/atlx/atl1.c              |   68 ++++++++++++---------------------
 drivers/net/atlx/atl1.h              |    4 +-
 drivers/net/atlx/atl2.c              |   63 +++++++++++++------------------
 drivers/net/atlx/atl2.h              |    1 -
 drivers/net/atlx/atlx.c              |   13 ------
 drivers/net/forcedeth.c              |    2 +-
 drivers/net/ixgbe/ixgbe.h            |    1 +
 drivers/net/ixgbe/ixgbe_82598.c      |   12 ++++++
 drivers/net/ixgbe/ixgbe_ethtool.c    |   27 +++++++++++++
 drivers/net/ixgbe/ixgbe_main.c       |   33 ++++++++++++++++
 drivers/net/ixgbe/ixgbe_phy.c        |   68 ++++++++++++++++++++++++++++++++++
 drivers/net/ixgbe/ixgbe_phy.h        |    7 +++
 drivers/net/ixgbe/ixgbe_type.h       |    6 +++
 drivers/net/smc91x.c                 |    2 +-
 15 files changed, 219 insertions(+), 104 deletions(-)

Andy Gospodarek (1):
      bonding: update docs to correctly reflect arp_ip_target behavior

Jesse Brandeburg (1):
      ixgbe: add device support for 82598AT (copper 10GbE) adapters

Joe Korty (1):
      forcdeth: increase max_interrupt_work

Mike Frysinger (1):
      smc91x: add __init markings to smc_drv_probe()

Stephen Hemminger (2):
      atlx: use embedded net_device_stats
      atlx: timer cleanup

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index 688dfe1..d733a42 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -922,17 +922,19 @@ USERCTL=no
 NETMASK, NETWORK and BROADCAST) to match your network configuration.
 
 	For later versions of initscripts, such as that found with Fedora
-7 and Red Hat Enterprise Linux version 5 (or later), it is possible, and,
-indeed, preferable, to specify the bonding options in the ifcfg-bond0
+7 (or later) and Red Hat Enterprise Linux version 5 (or later), it is possible,
+and, indeed, preferable, to specify the bonding options in the ifcfg-bond0
 file, e.g. a line of the format:
 
-BONDING_OPTS="mode=active-backup arp_interval=60 arp_ip_target=+192.168.1.254"
+BONDING_OPTS="mode=active-backup arp_interval=60 arp_ip_target=192.168.1.254"
 
 	will configure the bond with the specified options.  The options
 specified in BONDING_OPTS are identical to the bonding module parameters
-except for the arp_ip_target field.  Each target should be included as a
-separate option and should be preceded by a '+' to indicate it should be
-added to the list of queried targets, e.g.,
+except for the arp_ip_target field when using versions of initscripts older
+than and 8.57 (Fedora 8) and 8.45.19 (Red Hat Enterprise Linux 5.2).  When
+using older versions each target should be included as a separate option and
+should be preceded by a '+' to indicate it should be added to the list of
+queried targets, e.g.,
 
 	arp_ip_target=+192.168.1.1 arp_ip_target=+192.168.1.2
 
@@ -940,7 +942,7 @@ added to the list of queried targets, e.g.,
 options via BONDING_OPTS, it is not necessary to edit /etc/modules.conf or
 /etc/modprobe.conf.
 
-	For older versions of initscripts that do not support
+	For even older versions of initscripts that do not support
 BONDING_OPTS, it is necessary to edit /etc/modules.conf (or
 /etc/modprobe.conf, depending upon your distro) to load the bonding module
 with your desired options when the bond0 interface is brought up.  The
diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 246d92b..3836e62 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -1390,7 +1390,8 @@ static u32 atl1_check_link(struct atl1_adapter *adapter)
 	/* auto-neg, insert timer to re-config phy */
 	if (!adapter->phy_timer_pending) {
 		adapter->phy_timer_pending = true;
-		mod_timer(&adapter->phy_config_timer, jiffies + 3 * HZ);
+		mod_timer(&adapter->phy_config_timer,
+			  round_jiffies(jiffies + 3 * HZ));
 	}
 
 	return 0;
@@ -1662,6 +1663,7 @@ static void atl1_via_workaround(struct atl1_adapter *adapter)
 
 static void atl1_inc_smb(struct atl1_adapter *adapter)
 {
+	struct net_device *netdev = adapter->netdev;
 	struct stats_msg_block *smb = adapter->smb.smb;
 
 	/* Fill out the OS statistics structure */
@@ -1704,30 +1706,30 @@ static void atl1_inc_smb(struct atl1_adapter *adapter)
 	adapter->soft_stats.tx_trunc += smb->tx_trunc;
 	adapter->soft_stats.tx_pause += smb->tx_pause;
 
-	adapter->net_stats.rx_packets = adapter->soft_stats.rx_packets;
-	adapter->net_stats.tx_packets = adapter->soft_stats.tx_packets;
-	adapter->net_stats.rx_bytes = adapter->soft_stats.rx_bytes;
-	adapter->net_stats.tx_bytes = adapter->soft_stats.tx_bytes;
-	adapter->net_stats.multicast = adapter->soft_stats.multicast;
-	adapter->net_stats.collisions = adapter->soft_stats.collisions;
-	adapter->net_stats.rx_errors = adapter->soft_stats.rx_errors;
-	adapter->net_stats.rx_over_errors =
+	netdev->stats.rx_packets = adapter->soft_stats.rx_packets;
+	netdev->stats.tx_packets = adapter->soft_stats.tx_packets;
+	netdev->stats.rx_bytes = adapter->soft_stats.rx_bytes;
+	netdev->stats.tx_bytes = adapter->soft_stats.tx_bytes;
+	netdev->stats.multicast = adapter->soft_stats.multicast;
+	netdev->stats.collisions = adapter->soft_stats.collisions;
+	netdev->stats.rx_errors = adapter->soft_stats.rx_errors;
+	netdev->stats.rx_over_errors =
 		adapter->soft_stats.rx_missed_errors;
-	adapter->net_stats.rx_length_errors =
+	netdev->stats.rx_length_errors =
 		adapter->soft_stats.rx_length_errors;
-	adapter->net_stats.rx_crc_errors = adapter->soft_stats.rx_crc_errors;
-	adapter->net_stats.rx_frame_errors =
+	netdev->stats.rx_crc_errors = adapter->soft_stats.rx_crc_errors;
+	netdev->stats.rx_frame_errors =
 		adapter->soft_stats.rx_frame_errors;
-	adapter->net_stats.rx_fifo_errors = adapter->soft_stats.rx_fifo_errors;
-	adapter->net_stats.rx_missed_errors =
+	netdev->stats.rx_fifo_errors = adapter->soft_stats.rx_fifo_errors;
+	netdev->stats.rx_missed_errors =
 		adapter->soft_stats.rx_missed_errors;
-	adapter->net_stats.tx_errors = adapter->soft_stats.tx_errors;
-	adapter->net_stats.tx_fifo_errors = adapter->soft_stats.tx_fifo_errors;
-	adapter->net_stats.tx_aborted_errors =
+	netdev->stats.tx_errors = adapter->soft_stats.tx_errors;
+	netdev->stats.tx_fifo_errors = adapter->soft_stats.tx_fifo_errors;
+	netdev->stats.tx_aborted_errors =
 		adapter->soft_stats.tx_aborted_errors;
-	adapter->net_stats.tx_window_errors =
+	netdev->stats.tx_window_errors =
 		adapter->soft_stats.tx_window_errors;
-	adapter->net_stats.tx_carrier_errors =
+	netdev->stats.tx_carrier_errors =
 		adapter->soft_stats.tx_carrier_errors;
 }
 
@@ -1860,7 +1862,7 @@ static u16 atl1_alloc_rx_buffers(struct atl1_adapter *adapter)
 				       adapter->rx_buffer_len + NET_IP_ALIGN);
 		if (unlikely(!skb)) {
 			/* Better luck next round */
-			adapter->net_stats.rx_dropped++;
+			adapter->netdev->stats.rx_dropped++;
 			break;
 		}
 
@@ -2524,17 +2526,6 @@ static irqreturn_t atl1_intr(int irq, void *data)
 	return IRQ_HANDLED;
 }
 
-/*
- * atl1_watchdog - Timer Call-back
- * @data: pointer to netdev cast into an unsigned long
- */
-static void atl1_watchdog(unsigned long data)
-{
-	struct atl1_adapter *adapter = (struct atl1_adapter *)data;
-
-	/* Reset the timer */
-	mod_timer(&adapter->watchdog_timer, jiffies + 2 * HZ);
-}
 
 /*
  * atl1_phy_config - Timer Call-back
@@ -2607,7 +2598,6 @@ static s32 atl1_up(struct atl1_adapter *adapter)
 	if (unlikely(err))
 		goto err_up;
 
-	mod_timer(&adapter->watchdog_timer, jiffies);
 	atlx_irq_enable(adapter);
 	atl1_check_link(adapter);
 	netif_start_queue(netdev);
@@ -2625,7 +2615,6 @@ static void atl1_down(struct atl1_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 
 	netif_stop_queue(netdev);
-	del_timer_sync(&adapter->watchdog_timer);
 	del_timer_sync(&adapter->phy_config_timer);
 	adapter->phy_timer_pending = false;
 
@@ -2983,7 +2972,7 @@ static int __devinit atl1_probe(struct pci_dev *pdev,
 	netdev->open = &atl1_open;
 	netdev->stop = &atl1_close;
 	netdev->hard_start_xmit = &atl1_xmit_frame;
-	netdev->get_stats = &atlx_get_stats;
+
 	netdev->set_multicast_list = &atlx_set_multi;
 	netdev->set_mac_address = &atl1_set_mac;
 	netdev->change_mtu = &atl1_change_mtu;
@@ -3049,13 +3038,8 @@ static int __devinit atl1_probe(struct pci_dev *pdev,
 	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);
 
-	init_timer(&adapter->watchdog_timer);
-	adapter->watchdog_timer.function = &atl1_watchdog;
-	adapter->watchdog_timer.data = (unsigned long)adapter;
-
-	init_timer(&adapter->phy_config_timer);
-	adapter->phy_config_timer.function = &atl1_phy_config;
-	adapter->phy_config_timer.data = (unsigned long)adapter;
+	setup_timer(&adapter->phy_config_timer, &atl1_phy_config,
+		    (unsigned long)adapter);
 	adapter->phy_timer_pending = false;
 
 	INIT_WORK(&adapter->tx_timeout_task, atl1_tx_timeout_task);
@@ -3173,8 +3157,6 @@ static struct atl1_stats atl1_gstrings_stats[] = {
 	{"tx_bytes", ATL1_STAT(soft_stats.tx_bytes)},
 	{"rx_errors", ATL1_STAT(soft_stats.rx_errors)},
 	{"tx_errors", ATL1_STAT(soft_stats.tx_errors)},
-	{"rx_dropped", ATL1_STAT(net_stats.rx_dropped)},
-	{"tx_dropped", ATL1_STAT(net_stats.tx_dropped)},
 	{"multicast", ATL1_STAT(soft_stats.multicast)},
 	{"collisions", ATL1_STAT(soft_stats.collisions)},
 	{"rx_length_errors", ATL1_STAT(soft_stats.rx_length_errors)},
diff --git a/drivers/net/atlx/atl1.h b/drivers/net/atlx/atl1.h
index ffa73fc..146372f 100644
--- a/drivers/net/atlx/atl1.h
+++ b/drivers/net/atlx/atl1.h
@@ -754,7 +754,7 @@ struct atl1_hw {
 struct atl1_adapter {
 	struct net_device *netdev;
 	struct pci_dev *pdev;
-	struct net_device_stats net_stats;
+
 	struct atl1_sft_stats soft_stats;
 	struct vlan_group *vlgrp;
 	u32 rx_buffer_len;
@@ -765,7 +765,7 @@ struct atl1_adapter {
 	struct work_struct tx_timeout_task;
 	struct work_struct link_chg_task;
 	struct work_struct pcie_dma_to_rst_task;
-	struct timer_list watchdog_timer;
+
 	struct timer_list phy_config_timer;
 	bool phy_timer_pending;
 
diff --git a/drivers/net/atlx/atl2.c b/drivers/net/atlx/atl2.c
index f5bdc92..21ca6dd 100644
--- a/drivers/net/atlx/atl2.c
+++ b/drivers/net/atlx/atl2.c
@@ -418,7 +418,7 @@ static void atl2_intr_rx(struct atl2_adapter *adapter)
 				 * Check that some rx space is free. If not,
 				 * free one and mark stats->rx_dropped++.
 				 */
-				adapter->net_stats.rx_dropped++;
+				netdev->stats.rx_dropped++;
 				break;
 			}
 			skb_reserve(skb, NET_IP_ALIGN);
@@ -435,20 +435,20 @@ static void atl2_intr_rx(struct atl2_adapter *adapter)
 			} else
 #endif
 			netif_rx(skb);
-			adapter->net_stats.rx_bytes += rx_size;
-			adapter->net_stats.rx_packets++;
+			netdev->stats.rx_bytes += rx_size;
+			netdev->stats.rx_packets++;
 			netdev->last_rx = jiffies;
 		} else {
-			adapter->net_stats.rx_errors++;
+			netdev->stats.rx_errors++;
 
 			if (rxd->status.ok && rxd->status.pkt_size <= 60)
-				adapter->net_stats.rx_length_errors++;
+				netdev->stats.rx_length_errors++;
 			if (rxd->status.mcast)
-				adapter->net_stats.multicast++;
+				netdev->stats.multicast++;
 			if (rxd->status.crc)
-				adapter->net_stats.rx_crc_errors++;
+				netdev->stats.rx_crc_errors++;
 			if (rxd->status.align)
-				adapter->net_stats.rx_frame_errors++;
+				netdev->stats.rx_frame_errors++;
 		}
 
 		/* advance write ptr */
@@ -463,6 +463,7 @@ static void atl2_intr_rx(struct atl2_adapter *adapter)
 
 static void atl2_intr_tx(struct atl2_adapter *adapter)
 {
+	struct net_device *netdev = adapter->netdev;
 	u32 txd_read_ptr;
 	u32 txs_write_ptr;
 	struct tx_pkt_status *txs;
@@ -522,20 +523,20 @@ static void atl2_intr_tx(struct atl2_adapter *adapter)
 
 		/* tx statistics: */
 		if (txs->ok) {
-			adapter->net_stats.tx_bytes += txs->pkt_size;
-			adapter->net_stats.tx_packets++;
+			netdev->stats.tx_bytes += txs->pkt_size;
+			netdev->stats.tx_packets++;
 		}
 		else
-			adapter->net_stats.tx_errors++;
+			netdev->stats.tx_errors++;
 
 		if (txs->defer)
-			adapter->net_stats.collisions++;
+			netdev->stats.collisions++;
 		if (txs->abort_col)
-			adapter->net_stats.tx_aborted_errors++;
+			netdev->stats.tx_aborted_errors++;
 		if (txs->late_col)
-			adapter->net_stats.tx_window_errors++;
+			netdev->stats.tx_window_errors++;
 		if (txs->underun)
-			adapter->net_stats.tx_fifo_errors++;
+			netdev->stats.tx_fifo_errors++;
 	} while (1);
 
 	if (free_hole) {
@@ -621,7 +622,7 @@ static irqreturn_t atl2_intr(int irq, void *data)
 
 	/* link event */
 	if (status & (ISR_PHY | ISR_MANUAL)) {
-		adapter->net_stats.tx_carrier_errors++;
+		adapter->netdev->stats.tx_carrier_errors++;
 		atl2_check_for_link(adapter);
 	}
 
@@ -723,7 +724,7 @@ static int atl2_open(struct net_device *netdev)
 
 	clear_bit(__ATL2_DOWN, &adapter->flags);
 
-	mod_timer(&adapter->watchdog_timer, jiffies + 4*HZ);
+	mod_timer(&adapter->watchdog_timer, round_jiffies(jiffies + 4*HZ));
 
 	val = ATL2_READ_REG(&adapter->hw, REG_MASTER_CTRL);
 	ATL2_WRITE_REG(&adapter->hw, REG_MASTER_CTRL,
@@ -900,19 +901,6 @@ static int atl2_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 }
 
 /*
- * atl2_get_stats - Get System Network Statistics
- * @netdev: network interface device structure
- *
- * Returns the address of the device statistics structure.
- * The statistics are actually updated from the timer callback.
- */
-static struct net_device_stats *atl2_get_stats(struct net_device *netdev)
-{
-	struct atl2_adapter *adapter = netdev_priv(netdev);
-	return &adapter->net_stats;
-}
-
-/*
  * atl2_change_mtu - Change the Maximum Transfer Unit
  * @netdev: network interface device structure
  * @new_mtu: new value for maximum frame size
@@ -1050,18 +1038,21 @@ static void atl2_tx_timeout(struct net_device *netdev)
 static void atl2_watchdog(unsigned long data)
 {
 	struct atl2_adapter *adapter = (struct atl2_adapter *) data;
-	u32 drop_rxd, drop_rxs;
-	unsigned long flags;
 
 	if (!test_bit(__ATL2_DOWN, &adapter->flags)) {
+		u32 drop_rxd, drop_rxs;
+		unsigned long flags;
+
 		spin_lock_irqsave(&adapter->stats_lock, flags);
 		drop_rxd = ATL2_READ_REG(&adapter->hw, REG_STS_RXD_OV);
 		drop_rxs = ATL2_READ_REG(&adapter->hw, REG_STS_RXS_OV);
-		adapter->net_stats.rx_over_errors += (drop_rxd+drop_rxs);
 		spin_unlock_irqrestore(&adapter->stats_lock, flags);
 
+		adapter->netdev->stats.rx_over_errors += drop_rxd + drop_rxs;
+
 		/* Reset the timer */
-		mod_timer(&adapter->watchdog_timer, jiffies + 4 * HZ);
+		mod_timer(&adapter->watchdog_timer,
+			  round_jiffies(jiffies + 4 * HZ));
 	}
 }
 
@@ -1265,7 +1256,8 @@ static int atl2_check_link(struct atl2_adapter *adapter)
 	 * (if interval smaller than 5 seconds, something strange) */
 	if (!test_bit(__ATL2_DOWN, &adapter->flags)) {
 		if (!test_and_set_bit(0, &adapter->cfg_phy))
-			mod_timer(&adapter->phy_config_timer, jiffies + 5 * HZ);
+			mod_timer(&adapter->phy_config_timer,
+				  round_jiffies(jiffies + 5 * HZ));
 	}
 
 	return 0;
@@ -1396,7 +1388,6 @@ static int __devinit atl2_probe(struct pci_dev *pdev,
 	netdev->open = &atl2_open;
 	netdev->stop = &atl2_close;
 	netdev->hard_start_xmit = &atl2_xmit_frame;
-	netdev->get_stats = &atl2_get_stats;
 	netdev->set_multicast_list = &atl2_set_multi;
 	netdev->set_mac_address = &atl2_set_mac;
 	netdev->change_mtu = &atl2_change_mtu;
diff --git a/drivers/net/atlx/atl2.h b/drivers/net/atlx/atl2.h
index 09974df..d918bbe 100644
--- a/drivers/net/atlx/atl2.h
+++ b/drivers/net/atlx/atl2.h
@@ -453,7 +453,6 @@ struct atl2_adapter {
 	/* OS defined structs */
 	struct net_device *netdev;
 	struct pci_dev *pdev;
-	struct net_device_stats net_stats;
 #ifdef NETIF_F_HW_VLAN_TX
 	struct vlan_group *vlgrp;
 #endif
diff --git a/drivers/net/atlx/atlx.c b/drivers/net/atlx/atlx.c
index 3cc9d10..3dc0142 100644
--- a/drivers/net/atlx/atlx.c
+++ b/drivers/net/atlx/atlx.c
@@ -182,19 +182,6 @@ static void atlx_clear_phy_int(struct atlx_adapter *adapter)
 }
 
 /*
- * atlx_get_stats - Get System Network Statistics
- * @netdev: network interface device structure
- *
- * Returns the address of the device statistics structure.
- * The statistics are actually updated from the timer callback.
- */
-static struct net_device_stats *atlx_get_stats(struct net_device *netdev)
-{
-	struct atlx_adapter *adapter = netdev_priv(netdev);
-	return &adapter->net_stats;
-}
-
-/*
  * atlx_tx_timeout - Respond to a Tx Hang
  * @netdev: network interface device structure
  */
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 74c588e..0b12e48 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -818,7 +818,7 @@ struct fe_priv {
  * Maximum number of loops until we assume that a bit in the irq mask
  * is stuck. Overridable with module param.
  */
-static int max_interrupt_work = 5;
+static int max_interrupt_work = 15;
 
 /*
  * Optimization can be either throuput mode or cpu mode
diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index e116d34..132854f 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -267,6 +267,7 @@ struct ixgbe_adapter {
 #define IXGBE_FLAG_RSS_CAPABLE                  (u32)(1 << 17)
 #define IXGBE_FLAG_VMDQ_CAPABLE                 (u32)(1 << 18)
 #define IXGBE_FLAG_VMDQ_ENABLED                 (u32)(1 << 19)
+#define IXGBE_FLAG_FAN_FAIL_CAPABLE             (u32)(1 << 20)
 #define IXGBE_FLAG_NEED_LINK_UPDATE             (u32)(1 << 22)
 #define IXGBE_FLAG_IN_WATCHDOG_TASK             (u32)(1 << 23)
 
diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index 7cddcfb..c2cdb04 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -59,6 +59,11 @@ static s32 ixgbe_get_invariants_82598(struct ixgbe_hw *hw)
 
 	/* PHY Init */
 	switch (phy->type) {
+	case ixgbe_phy_tn:
+		phy->ops.check_link = &ixgbe_check_phy_link_tnx;
+		phy->ops.get_firmware_version =
+		             &ixgbe_get_phy_firmware_version_tnx;
+		break;
 	default:
 		break;
 	}
@@ -189,6 +194,9 @@ static enum ixgbe_media_type ixgbe_get_media_type_82598(struct ixgbe_hw *hw)
 	case IXGBE_DEV_ID_82598EB_XF_LR:
 		media_type = ixgbe_media_type_fiber;
 		break;
+	case IXGBE_DEV_ID_82598AT:
+		media_type = ixgbe_media_type_copper;
+		break;
 	default:
 		media_type = ixgbe_media_type_unknown;
 		break;
@@ -872,6 +880,10 @@ s32 ixgbe_get_supported_physical_layer_82598(struct ixgbe_hw *hw)
 	case IXGBE_DEV_ID_82598EB_XF_LR:
 		physical_layer = IXGBE_PHYSICAL_LAYER_10GBASE_LR;
 		break;
+	case IXGBE_DEV_ID_82598AT:
+		physical_layer = (IXGBE_PHYSICAL_LAYER_10GBASE_T |
+		                  IXGBE_PHYSICAL_LAYER_1000BASE_T);
+		break;
 
 	default:
 		physical_layer = IXGBE_PHYSICAL_LAYER_UNKNOWN;
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 81a9c4b..fee56a3 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -149,6 +149,8 @@ static int ixgbe_set_settings(struct net_device *netdev,
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
+	u32 advertised, old;
+	s32 err;
 
 	switch (hw->phy.media_type) {
 	case ixgbe_media_type_fiber:
@@ -157,6 +159,31 @@ static int ixgbe_set_settings(struct net_device *netdev,
 			return -EINVAL;
 		/* in this case we currently only support 10Gb/FULL */
 		break;
+	case ixgbe_media_type_copper:
+		/* 10000/copper and 1000/copper must autoneg
+		 * this function does not support any duplex forcing, but can
+		 * limit the advertising of the adapter to only 10000 or 1000 */
+		if (ecmd->autoneg == AUTONEG_DISABLE)
+			return -EINVAL;
+
+		old = hw->phy.autoneg_advertised;
+		advertised = 0;
+		if (ecmd->advertising & ADVERTISED_10000baseT_Full)
+			advertised |= IXGBE_LINK_SPEED_10GB_FULL;
+
+		if (ecmd->advertising & ADVERTISED_1000baseT_Full)
+			advertised |= IXGBE_LINK_SPEED_1GB_FULL;
+
+		if (old == advertised)
+			break;
+		/* this sets the link speed and restarts auto-neg */
+		err = hw->mac.ops.setup_link_speed(hw, advertised, true, true);
+		if (err) {
+			DPRINTK(PROBE, INFO,
+			        "setup link failed with code %d\n", err);
+			hw->mac.ops.setup_link_speed(hw, old, true, true);
+		}
+		break;
 	default:
 		break;
 	}
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 028bfb2..2a12e97 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -68,6 +68,8 @@ static struct pci_device_id ixgbe_pci_tbl[] = {
 	 board_82598 },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598AF_SINGLE_PORT),
 	 board_82598 },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598AT),
+	 board_82598 },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598EB_CX4),
 	 board_82598 },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598_CX4_DUAL_PORT),
@@ -904,6 +906,17 @@ static void ixgbe_set_itr_msix(struct ixgbe_q_vector *q_vector)
 	return;
 }
 
+static void ixgbe_check_fan_failure(struct ixgbe_adapter *adapter, u32 eicr)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+
+	if ((adapter->flags & IXGBE_FLAG_FAN_FAIL_CAPABLE) &&
+	    (eicr & IXGBE_EICR_GPI_SDP1)) {
+		DPRINTK(PROBE, CRIT, "Fan has stopped, replace the adapter\n");
+		/* write to clear the interrupt */
+		IXGBE_WRITE_REG(hw, IXGBE_EICR, IXGBE_EICR_GPI_SDP1);
+	}
+}
 
 static void ixgbe_check_lsc(struct ixgbe_adapter *adapter)
 {
@@ -928,6 +941,8 @@ static irqreturn_t ixgbe_msix_lsc(int irq, void *data)
 	if (eicr & IXGBE_EICR_LSC)
 		ixgbe_check_lsc(adapter);
 
+	ixgbe_check_fan_failure(adapter, eicr);
+
 	if (!test_bit(__IXGBE_DOWN, &adapter->state))
 		IXGBE_WRITE_REG(hw, IXGBE_EIMS, IXGBE_EIMS_OTHER);
 
@@ -1316,6 +1331,8 @@ static irqreturn_t ixgbe_intr(int irq, void *data)
 	if (eicr & IXGBE_EICR_LSC)
 		ixgbe_check_lsc(adapter);
 
+	ixgbe_check_fan_failure(adapter, eicr);
+
 	if (netif_rx_schedule_prep(netdev, &adapter->q_vector[0].napi)) {
 		adapter->tx_ring[0].total_packets = 0;
 		adapter->tx_ring[0].total_bytes = 0;
@@ -1418,6 +1435,8 @@ static inline void ixgbe_irq_enable(struct ixgbe_adapter *adapter)
 {
 	u32 mask;
 	mask = IXGBE_EIMS_ENABLE_MASK;
+	if (adapter->flags & IXGBE_FLAG_FAN_FAIL_CAPABLE)
+		mask |= IXGBE_EIMS_GPI_SDP1;
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS, mask);
 	IXGBE_WRITE_FLUSH(&adapter->hw);
 }
@@ -1927,6 +1946,13 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 		IXGBE_WRITE_REG(hw, IXGBE_EIAM, IXGBE_EICS_RTX_QUEUE);
 	}
 
+	/* Enable fan failure interrupt if media type is copper */
+	if (adapter->flags & IXGBE_FLAG_FAN_FAIL_CAPABLE) {
+		gpie = IXGBE_READ_REG(hw, IXGBE_GPIE);
+		gpie |= IXGBE_SDP1_GPIEN;
+		IXGBE_WRITE_REG(hw, IXGBE_GPIE, gpie);
+	}
+
 	mhadd = IXGBE_READ_REG(hw, IXGBE_MHADD);
 	if (max_frame != (mhadd >> IXGBE_MHADD_MFS_SHIFT)) {
 		mhadd &= ~IXGBE_MHADD_MFS_MASK;
@@ -2564,6 +2590,9 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	rss = min(IXGBE_MAX_RSS_INDICES, (int)num_online_cpus());
 	adapter->ring_feature[RING_F_RSS].indices = rss;
 	adapter->flags |= IXGBE_FLAG_RSS_ENABLED;
+	if (hw->mac.ops.get_media_type &&
+	    (hw->mac.ops.get_media_type(hw) == ixgbe_media_type_copper))
+		adapter->flags |= IXGBE_FLAG_FAN_FAIL_CAPABLE;
 
 	/* default flow control settings */
 	hw->fc.original_type = ixgbe_fc_none;
@@ -3691,6 +3720,10 @@ static int ixgbe_link_config(struct ixgbe_hw *hw)
 	/* must always autoneg for both 1G and 10G link */
 	hw->mac.autoneg = true;
 
+	if ((hw->mac.type == ixgbe_mac_82598EB) &&
+	    (hw->phy.media_type == ixgbe_media_type_copper))
+		autoneg = IXGBE_LINK_SPEED_82598_AUTONEG;
+
 	return hw->mac.ops.setup_link_speed(hw, autoneg, true, true);
 }
 
diff --git a/drivers/net/ixgbe/ixgbe_phy.c b/drivers/net/ixgbe/ixgbe_phy.c
index 764035a..981e6d8 100644
--- a/drivers/net/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ixgbe/ixgbe_phy.c
@@ -121,6 +121,9 @@ static enum ixgbe_phy_type ixgbe_get_phy_type_from_id(u32 phy_id)
 	enum ixgbe_phy_type phy_type;
 
 	switch (phy_id) {
+	case TN1010_PHY_ID:
+		phy_type = ixgbe_phy_tn;
+		break;
 	case QT2022_PHY_ID:
 		phy_type = ixgbe_phy_qt;
 		break;
@@ -426,3 +429,68 @@ s32 ixgbe_setup_phy_link_speed_generic(struct ixgbe_hw *hw,
 	return 0;
 }
 
+/**
+ *  ixgbe_check_phy_link_tnx - Determine link and speed status
+ *  @hw: pointer to hardware structure
+ *
+ *  Reads the VS1 register to determine if link is up and the current speed for
+ *  the PHY.
+ **/
+s32 ixgbe_check_phy_link_tnx(struct ixgbe_hw *hw, ixgbe_link_speed *speed,
+                             bool *link_up)
+{
+	s32 status = 0;
+	u32 time_out;
+	u32 max_time_out = 10;
+	u16 phy_link = 0;
+	u16 phy_speed = 0;
+	u16 phy_data = 0;
+
+	/* Initialize speed and link to default case */
+	*link_up = false;
+	*speed = IXGBE_LINK_SPEED_10GB_FULL;
+
+	/*
+	 * Check current speed and link status of the PHY register.
+	 * This is a vendor specific register and may have to
+	 * be changed for other copper PHYs.
+	 */
+	for (time_out = 0; time_out < max_time_out; time_out++) {
+		udelay(10);
+		status = hw->phy.ops.read_reg(hw,
+		                        IXGBE_MDIO_VENDOR_SPECIFIC_1_STATUS,
+		                        IXGBE_MDIO_VENDOR_SPECIFIC_1_DEV_TYPE,
+		                        &phy_data);
+		phy_link = phy_data &
+		           IXGBE_MDIO_VENDOR_SPECIFIC_1_LINK_STATUS;
+		phy_speed = phy_data &
+		            IXGBE_MDIO_VENDOR_SPECIFIC_1_SPEED_STATUS;
+		if (phy_link == IXGBE_MDIO_VENDOR_SPECIFIC_1_LINK_STATUS) {
+			*link_up = true;
+			if (phy_speed ==
+			    IXGBE_MDIO_VENDOR_SPECIFIC_1_SPEED_STATUS)
+				*speed = IXGBE_LINK_SPEED_1GB_FULL;
+			break;
+		}
+	}
+
+	return status;
+}
+
+/**
+ *  ixgbe_get_phy_firmware_version_tnx - Gets the PHY Firmware Version
+ *  @hw: pointer to hardware structure
+ *  @firmware_version: pointer to the PHY Firmware Version
+ **/
+s32 ixgbe_get_phy_firmware_version_tnx(struct ixgbe_hw *hw,
+                                       u16 *firmware_version)
+{
+	s32 status = 0;
+
+	status = hw->phy.ops.read_reg(hw, TNX_FW_REV,
+	                              IXGBE_MDIO_VENDOR_SPECIFIC_1_DEV_TYPE,
+	                              firmware_version);
+
+	return status;
+}
+
diff --git a/drivers/net/ixgbe/ixgbe_phy.h b/drivers/net/ixgbe/ixgbe_phy.h
index 9bfe3f2..5cc063d 100644
--- a/drivers/net/ixgbe/ixgbe_phy.h
+++ b/drivers/net/ixgbe/ixgbe_phy.h
@@ -77,4 +77,11 @@ s32 ixgbe_setup_phy_link_speed_generic(struct ixgbe_hw *hw,
                                        bool autoneg,
                                        bool autoneg_wait_to_complete);
 
+/* PHY specific */
+s32 ixgbe_check_phy_link_tnx(struct ixgbe_hw *hw,
+                             ixgbe_link_speed *speed,
+                             bool *link_up);
+s32 ixgbe_get_phy_firmware_version_tnx(struct ixgbe_hw *hw,
+                                       u16 *firmware_version);
+
 #endif /* _IXGBE_PHY_H_ */
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index c6f8fa1..51df39d 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -36,6 +36,7 @@
 /* Device IDs */
 #define IXGBE_DEV_ID_82598AF_DUAL_PORT   0x10C6
 #define IXGBE_DEV_ID_82598AF_SINGLE_PORT 0x10C7
+#define IXGBE_DEV_ID_82598AT             0x10C8
 #define IXGBE_DEV_ID_82598EB_CX4         0x10DD
 #define IXGBE_DEV_ID_82598_CX4_DUAL_PORT 0x10EC
 #define IXGBE_DEV_ID_82598EB_XF_LR       0x10F4
@@ -488,6 +489,8 @@
 #define IXGBE_MAX_PHY_ADDR             32
 
 /* PHY IDs*/
+#define TN1010_PHY_ID    0x00A19410
+#define TNX_FW_REV       0xB
 #define QT2022_PHY_ID    0x0043A400
 
 /* PHY Types */
@@ -1202,6 +1205,7 @@ enum ixgbe_mac_type {
 
 enum ixgbe_phy_type {
 	ixgbe_phy_unknown = 0,
+	ixgbe_phy_tn,
 	ixgbe_phy_qt,
 	ixgbe_phy_xaui,
 	ixgbe_phy_tw_tyco,
@@ -1396,6 +1400,8 @@ struct ixgbe_phy_operations {
 	s32 (*setup_link)(struct ixgbe_hw *);
 	s32 (*setup_link_speed)(struct ixgbe_hw *, ixgbe_link_speed, bool,
 	                        bool);
+	s32 (*check_link)(struct ixgbe_hw *, ixgbe_link_speed *, bool *);
+	s32 (*get_firmware_version)(struct ixgbe_hw *, u16 *);
 	s32 (*read_i2c_byte)(struct ixgbe_hw *, u8, u8, u8 *);
 	s32 (*write_i2c_byte)(struct ixgbe_hw *, u8, u8, u8);
 	s32 (*read_i2c_eeprom)(struct ixgbe_hw *, u8 , u8 *);
diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
index 2d8bfa7..b5ff632 100644
--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -2123,7 +2123,7 @@ static void smc_release_datacs(struct platform_device *pdev, struct net_device *
  *	0 --> there is a device
  *	anything else, error
  */
-static int smc_drv_probe(struct platform_device *pdev)
+static int __init smc_drv_probe(struct platform_device *pdev)
 {
 	struct smc91x_platdata *pd = pdev->dev.platform_data;
 	struct smc_local *lp;
