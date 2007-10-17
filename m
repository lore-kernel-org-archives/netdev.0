From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes (mostly)
Date: Tue, 16 Oct 2007 21:20:10 -0400
Message-ID: <20071017012010.GA12170@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:48286 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761053AbXJQBUM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2007 21:20:12 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mostly fixes, except a couple things from Stephen H and myself.

Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 drivers/net/3c59x.c             |    8 +-
 drivers/net/Kconfig             |   10 +
 drivers/net/bonding/bond_main.c |   11 +-
 drivers/net/bonding/bonding.h   |    4 +-
 drivers/net/e1000e/ethtool.c    |   35 ++-
 drivers/net/e1000e/hw.h         |    2 +-
 drivers/net/forcedeth.c         |  168 ++++++++------
 drivers/net/gianfar.c           |    7 +-
 drivers/net/ibm_newemac/mal.c   |   25 ++-
 drivers/net/skge.c              |  485 ++++++++++++++++++++++++++++++---------
 drivers/net/skge.h              |   17 +-
 drivers/net/tokenring/3c359.c   |    2 +-
 12 files changed, 558 insertions(+), 216 deletions(-)

Adrian Bunk (1):
      e1000e: fix error checks

Auke Kok (2):
      e1000e: Fix debug printk macro
      e1000e: don't poke PHY registers to retreive link status

Benjamin Herrenschmidt (1):
      net: Fix new EMAC driver for NAPI changes

Ingo Molnar (1):
      forcedeth: fix NAPI rx poll function

Jay Vosburgh (1):
      bonding: two small fixes for IPoIB support

Jeff Garzik (2):
      [netdrvr] forcedeth: improved probe info; dev_printk() cleanups
      [netdrvr] forcedeth: remove in-driver copy of net_device_stats

Li Yang (1):
      gianfar: Fix compile regression caused by 09f75cd7

Marcus Meissner (1):
      tokenring/3c359.c: fixed array index problem

Steffen Klassert (1):
      WOL bugfix for 3c59x.c

Stephen Hemminger (7):
      skge: fix ram buffer size calculation
      skge: changing MTU while running causes problems
      skge: XM PHY handling fixes
      skge: internal stats
      skge: eeprom support
      skge: add a debug interface
      skge 1.12

diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index 8d3893d..862f472 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -3118,7 +3118,13 @@ static void acpi_set_WOL(struct net_device *dev)
 		iowrite16(SetRxFilter|RxStation|RxMulticast|RxBroadcast, ioaddr + EL3_CMD);
 		iowrite16(RxEnable, ioaddr + EL3_CMD);
 
-		pci_enable_wake(VORTEX_PCI(vp), 0, 1);
+		if (pci_enable_wake(VORTEX_PCI(vp), PCI_D3hot, 1)) {
+			printk(KERN_INFO "%s: WOL not supported.\n",
+					pci_name(VORTEX_PCI(vp)));
+
+			vp->enable_wol = 0;
+			return;
+		}
 
 		/* Change the power state to D3; RxEnable doesn't take effect. */
 		pci_set_power_state(VORTEX_PCI(vp), PCI_D3hot);
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 8f99a06..83d52c8 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2173,6 +2173,16 @@ config SKGE
 	  To compile this driver as a module, choose M here: the module
 	  will be called skge.  This is recommended.
 
+config SKGE_DEBUG
+       bool "Debugging interface"
+       depends on SKGE && DEBUG_FS
+       help
+	 This option adds the ability to dump driver state for debugging.
+	 The file debugfs/skge/ethX displays the state of the internal
+	 transmit and receive rings.
+
+	 If unsure, say N.
+
 config SKY2
 	tristate "SysKonnect Yukon2 support"
 	depends on PCI
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index db80f24..6f85cc3 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1263,6 +1263,7 @@ static void bond_setup_by_slave(struct net_device *bond_dev,
 	struct bonding *bond = bond_dev->priv;
 
 	bond_dev->neigh_setup           = slave_dev->neigh_setup;
+	bond_dev->header_ops		= slave_dev->header_ops;
 
 	bond_dev->type		    = slave_dev->type;
 	bond_dev->hard_header_len   = slave_dev->hard_header_len;
@@ -3351,7 +3352,10 @@ static int bond_slave_netdev_event(unsigned long event, struct net_device *slave
 	switch (event) {
 	case NETDEV_UNREGISTER:
 		if (bond_dev) {
-			bond_release(bond_dev, slave_dev);
+			if (bond->setup_by_slave)
+				bond_release_and_destroy(bond_dev, slave_dev);
+			else
+				bond_release(bond_dev, slave_dev);
 		}
 		break;
 	case NETDEV_CHANGE:
@@ -3366,11 +3370,6 @@ static int bond_slave_netdev_event(unsigned long event, struct net_device *slave
 		 * ... Or is it this?
 		 */
 		break;
-	case NETDEV_GOING_DOWN:
-		dprintk("slave %s is going down\n", slave_dev->name);
-		if (bond->setup_by_slave)
-			bond_release_and_destroy(bond_dev, slave_dev);
-		break;
 	case NETDEV_CHANGEMTU:
 		/*
 		 * TODO: Should slaves be allowed to
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index a8bbd56..b818060 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -22,8 +22,8 @@
 #include "bond_3ad.h"
 #include "bond_alb.h"
 
-#define DRV_VERSION	"3.2.0"
-#define DRV_RELDATE	"September 13, 2007"
+#define DRV_VERSION	"3.2.1"
+#define DRV_RELDATE	"October 15, 2007"
 #define DRV_NAME	"bonding"
 #define DRV_DESCRIPTION	"Ethernet Channel Bonding Driver"
 
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index b7a7e2a..0666e62 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -110,6 +110,7 @@ static int e1000_get_settings(struct net_device *netdev,
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
+	u32 status;
 
 	if (hw->media_type == e1000_media_type_copper) {
 
@@ -147,16 +148,16 @@ static int e1000_get_settings(struct net_device *netdev,
 		ecmd->transceiver = XCVR_EXTERNAL;
 	}
 
-	if (er32(STATUS) & E1000_STATUS_LU) {
-
-		adapter->hw.mac.ops.get_link_up_info(hw, &adapter->link_speed,
-						  &adapter->link_duplex);
-		ecmd->speed = adapter->link_speed;
-
-		/* unfortunately FULL_DUPLEX != DUPLEX_FULL
-		 *	  and HALF_DUPLEX != DUPLEX_HALF */
+	status = er32(STATUS);
+	if (status & E1000_STATUS_LU) {
+		if (status & E1000_STATUS_SPEED_1000)
+			ecmd->speed = 1000;
+		else if (status & E1000_STATUS_SPEED_100)
+			ecmd->speed = 100;
+		else
+			ecmd->speed = 10;
 
-		if (adapter->link_duplex == FULL_DUPLEX)
+		if (status & E1000_STATUS_FD)
 			ecmd->duplex = DUPLEX_FULL;
 		else
 			ecmd->duplex = DUPLEX_HALF;
@@ -170,6 +171,16 @@ static int e1000_get_settings(struct net_device *netdev,
 	return 0;
 }
 
+static u32 e1000_get_link(struct net_device *netdev)
+{
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
+	u32 status;
+	
+	status = er32(STATUS);
+	return (status & E1000_STATUS_LU);
+}
+
 static int e1000_set_spd_dplx(struct e1000_adapter *adapter, u16 spddplx)
 {
 	struct e1000_mac_info *mac = &adapter->hw.mac;
@@ -1451,11 +1462,11 @@ static int e1000_loopback_test(struct e1000_adapter *adapter, u64 *data)
 	}
 
 	*data = e1000_setup_desc_rings(adapter);
-	if (data)
+	if (*data)
 		goto out;
 
 	*data = e1000_setup_loopback_test(adapter);
-	if (data)
+	if (*data)
 		goto err_loopback;
 
 	*data = e1000_run_loopback_test(adapter);
@@ -1751,7 +1762,7 @@ static const struct ethtool_ops e1000_ethtool_ops = {
 	.get_msglevel		= e1000_get_msglevel,
 	.set_msglevel		= e1000_set_msglevel,
 	.nway_reset		= e1000_nway_reset,
-	.get_link		= ethtool_op_get_link,
+	.get_link		= e1000_get_link,
 	.get_eeprom_len		= e1000_get_eeprom_len,
 	.get_eeprom		= e1000_get_eeprom,
 	.set_eeprom		= e1000_set_eeprom,
diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index aa82f1a..6451578 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -852,7 +852,7 @@ struct e1000_hw {
 
 #ifdef DEBUG
 #define hw_dbg(hw, format, arg...) \
-	printk(KERN_DEBUG, "%s: " format, e1000e_get_hw_dev_name(hw), ##arg);
+	printk(KERN_DEBUG "%s: " format, e1000e_get_hw_dev_name(hw), ##arg)
 #else
 static inline int __attribute__ ((format (printf, 2, 3)))
 hw_dbg(struct e1000_hw *hw, const char *format, ...)
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index dae30b7..cfbb7aa 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -128,7 +128,7 @@
 #else
 #define DRIVERNAPI
 #endif
-#define FORCEDETH_VERSION		"0.60"
+#define FORCEDETH_VERSION		"0.61"
 #define DRV_NAME			"forcedeth"
 
 #include <linux/module.h>
@@ -752,7 +752,6 @@ struct fe_priv {
 
 	/* General data:
 	 * Locking: spin_lock(&np->lock); */
-	struct net_device_stats stats;
 	struct nv_ethtool_stats estats;
 	int in_shutdown;
 	u32 linkspeed;
@@ -1505,15 +1504,16 @@ static struct net_device_stats *nv_get_stats(struct net_device *dev)
 		nv_get_hw_stats(dev);
 
 		/* copy to net_device stats */
-		np->stats.tx_bytes = np->estats.tx_bytes;
-		np->stats.tx_fifo_errors = np->estats.tx_fifo_errors;
-		np->stats.tx_carrier_errors = np->estats.tx_carrier_errors;
-		np->stats.rx_crc_errors = np->estats.rx_crc_errors;
-		np->stats.rx_over_errors = np->estats.rx_over_errors;
-		np->stats.rx_errors = np->estats.rx_errors_total;
-		np->stats.tx_errors = np->estats.tx_errors_total;
-	}
-	return &np->stats;
+		dev->stats.tx_bytes = np->estats.tx_bytes;
+		dev->stats.tx_fifo_errors = np->estats.tx_fifo_errors;
+		dev->stats.tx_carrier_errors = np->estats.tx_carrier_errors;
+		dev->stats.rx_crc_errors = np->estats.rx_crc_errors;
+		dev->stats.rx_over_errors = np->estats.rx_over_errors;
+		dev->stats.rx_errors = np->estats.rx_errors_total;
+		dev->stats.tx_errors = np->estats.tx_errors_total;
+	}
+
+	return &dev->stats;
 }
 
 /*
@@ -1733,7 +1733,7 @@ static void nv_drain_tx(struct net_device *dev)
 			np->tx_ring.ex[i].buflow = 0;
 		}
 		if (nv_release_txskb(dev, &np->tx_skb[i]))
-			np->stats.tx_dropped++;
+			dev->stats.tx_dropped++;
 	}
 }
 
@@ -2049,13 +2049,13 @@ static void nv_tx_done(struct net_device *dev)
 			if (flags & NV_TX_LASTPACKET) {
 				if (flags & NV_TX_ERROR) {
 					if (flags & NV_TX_UNDERFLOW)
-						np->stats.tx_fifo_errors++;
+						dev->stats.tx_fifo_errors++;
 					if (flags & NV_TX_CARRIERLOST)
-						np->stats.tx_carrier_errors++;
-					np->stats.tx_errors++;
+						dev->stats.tx_carrier_errors++;
+					dev->stats.tx_errors++;
 				} else {
-					np->stats.tx_packets++;
-					np->stats.tx_bytes += np->get_tx_ctx->skb->len;
+					dev->stats.tx_packets++;
+					dev->stats.tx_bytes += np->get_tx_ctx->skb->len;
 				}
 				dev_kfree_skb_any(np->get_tx_ctx->skb);
 				np->get_tx_ctx->skb = NULL;
@@ -2064,13 +2064,13 @@ static void nv_tx_done(struct net_device *dev)
 			if (flags & NV_TX2_LASTPACKET) {
 				if (flags & NV_TX2_ERROR) {
 					if (flags & NV_TX2_UNDERFLOW)
-						np->stats.tx_fifo_errors++;
+						dev->stats.tx_fifo_errors++;
 					if (flags & NV_TX2_CARRIERLOST)
-						np->stats.tx_carrier_errors++;
-					np->stats.tx_errors++;
+						dev->stats.tx_carrier_errors++;
+					dev->stats.tx_errors++;
 				} else {
-					np->stats.tx_packets++;
-					np->stats.tx_bytes += np->get_tx_ctx->skb->len;
+					dev->stats.tx_packets++;
+					dev->stats.tx_bytes += np->get_tx_ctx->skb->len;
 				}
 				dev_kfree_skb_any(np->get_tx_ctx->skb);
 				np->get_tx_ctx->skb = NULL;
@@ -2107,7 +2107,7 @@ static void nv_tx_done_optimized(struct net_device *dev, int limit)
 
 		if (flags & NV_TX2_LASTPACKET) {
 			if (!(flags & NV_TX2_ERROR))
-				np->stats.tx_packets++;
+				dev->stats.tx_packets++;
 			dev_kfree_skb_any(np->get_tx_ctx->skb);
 			np->get_tx_ctx->skb = NULL;
 		}
@@ -2268,13 +2268,13 @@ static int nv_rx_process(struct net_device *dev, int limit)
 {
 	struct fe_priv *np = netdev_priv(dev);
 	u32 flags;
-	u32 rx_processed_cnt = 0;
+	int rx_work = 0;
 	struct sk_buff *skb;
 	int len;
 
 	while((np->get_rx.orig != np->put_rx.orig) &&
 	      !((flags = le32_to_cpu(np->get_rx.orig->flaglen)) & NV_RX_AVAIL) &&
-		(rx_processed_cnt++ < limit)) {
+		(rx_work < limit)) {
 
 		dprintk(KERN_DEBUG "%s: nv_rx_process: flags 0x%x.\n",
 					dev->name, flags);
@@ -2308,7 +2308,7 @@ static int nv_rx_process(struct net_device *dev, int limit)
 					if (flags & NV_RX_ERROR4) {
 						len = nv_getlen(dev, skb->data, len);
 						if (len < 0) {
-							np->stats.rx_errors++;
+							dev->stats.rx_errors++;
 							dev_kfree_skb(skb);
 							goto next_pkt;
 						}
@@ -2322,12 +2322,12 @@ static int nv_rx_process(struct net_device *dev, int limit)
 					/* the rest are hard errors */
 					else {
 						if (flags & NV_RX_MISSEDFRAME)
-							np->stats.rx_missed_errors++;
+							dev->stats.rx_missed_errors++;
 						if (flags & NV_RX_CRCERR)
-							np->stats.rx_crc_errors++;
+							dev->stats.rx_crc_errors++;
 						if (flags & NV_RX_OVERFLOW)
-							np->stats.rx_over_errors++;
-						np->stats.rx_errors++;
+							dev->stats.rx_over_errors++;
+						dev->stats.rx_errors++;
 						dev_kfree_skb(skb);
 						goto next_pkt;
 					}
@@ -2343,7 +2343,7 @@ static int nv_rx_process(struct net_device *dev, int limit)
 					if (flags & NV_RX2_ERROR4) {
 						len = nv_getlen(dev, skb->data, len);
 						if (len < 0) {
-							np->stats.rx_errors++;
+							dev->stats.rx_errors++;
 							dev_kfree_skb(skb);
 							goto next_pkt;
 						}
@@ -2357,10 +2357,10 @@ static int nv_rx_process(struct net_device *dev, int limit)
 					/* the rest are hard errors */
 					else {
 						if (flags & NV_RX2_CRCERR)
-							np->stats.rx_crc_errors++;
+							dev->stats.rx_crc_errors++;
 						if (flags & NV_RX2_OVERFLOW)
-							np->stats.rx_over_errors++;
-						np->stats.rx_errors++;
+							dev->stats.rx_over_errors++;
+						dev->stats.rx_errors++;
 						dev_kfree_skb(skb);
 						goto next_pkt;
 					}
@@ -2389,16 +2389,18 @@ static int nv_rx_process(struct net_device *dev, int limit)
 		netif_rx(skb);
 #endif
 		dev->last_rx = jiffies;
-		np->stats.rx_packets++;
-		np->stats.rx_bytes += len;
+		dev->stats.rx_packets++;
+		dev->stats.rx_bytes += len;
 next_pkt:
 		if (unlikely(np->get_rx.orig++ == np->last_rx.orig))
 			np->get_rx.orig = np->first_rx.orig;
 		if (unlikely(np->get_rx_ctx++ == np->last_rx_ctx))
 			np->get_rx_ctx = np->first_rx_ctx;
+
+		rx_work++;
 	}
 
-	return rx_processed_cnt;
+	return rx_work;
 }
 
 static int nv_rx_process_optimized(struct net_device *dev, int limit)
@@ -2505,8 +2507,8 @@ static int nv_rx_process_optimized(struct net_device *dev, int limit)
 			}
 
 			dev->last_rx = jiffies;
-			np->stats.rx_packets++;
-			np->stats.rx_bytes += len;
+			dev->stats.rx_packets++;
+			dev->stats.rx_bytes += len;
 		} else {
 			dev_kfree_skb(skb);
 		}
@@ -3727,7 +3729,7 @@ static void nv_do_stats_poll(unsigned long data)
 static void nv_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
 	struct fe_priv *np = netdev_priv(dev);
-	strcpy(info->driver, "forcedeth");
+	strcpy(info->driver, DRV_NAME);
 	strcpy(info->version, FORCEDETH_VERSION);
 	strcpy(info->bus_info, pci_name(np->pci_dev));
 }
@@ -4991,6 +4993,11 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 	u32 phystate_orig = 0, phystate;
 	int phyinitialized = 0;
 	DECLARE_MAC_BUF(mac);
+	static int printed_version;
+
+	if (!printed_version++)
+		printk(KERN_INFO "%s: Reverse Engineered nForce ethernet"
+		       " driver. Version %s.\n", DRV_NAME, FORCEDETH_VERSION);
 
 	dev = alloc_etherdev(sizeof(struct fe_priv));
 	err = -ENOMEM;
@@ -5014,11 +5021,8 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 	np->stats_poll.function = &nv_do_stats_poll;	/* timer handler */
 
 	err = pci_enable_device(pci_dev);
-	if (err) {
-		printk(KERN_INFO "forcedeth: pci_enable_dev failed (%d) for device %s\n",
-				err, pci_name(pci_dev));
+	if (err)
 		goto out_free;
-	}
 
 	pci_set_master(pci_dev);
 
@@ -5047,8 +5051,8 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 		}
 	}
 	if (i == DEVICE_COUNT_RESOURCE) {
-		printk(KERN_INFO "forcedeth: Couldn't find register window for device %s.\n",
-					pci_name(pci_dev));
+		dev_printk(KERN_INFO, &pci_dev->dev,
+			   "Couldn't find register window\n");
 		goto out_relreg;
 	}
 
@@ -5061,16 +5065,14 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 		np->desc_ver = DESC_VER_3;
 		np->txrxctl_bits = NVREG_TXRXCTL_DESC_3;
 		if (dma_64bit) {
-			if (pci_set_dma_mask(pci_dev, DMA_39BIT_MASK)) {
-				printk(KERN_INFO "forcedeth: 64-bit DMA failed, using 32-bit addressing for device %s.\n",
-				       pci_name(pci_dev));
-			} else {
+			if (pci_set_dma_mask(pci_dev, DMA_39BIT_MASK))
+				dev_printk(KERN_INFO, &pci_dev->dev,
+					"64-bit DMA failed, using 32-bit addressing\n");
+			else
 				dev->features |= NETIF_F_HIGHDMA;
-				printk(KERN_INFO "forcedeth: using HIGHDMA\n");
-			}
 			if (pci_set_consistent_dma_mask(pci_dev, DMA_39BIT_MASK)) {
-				printk(KERN_INFO "forcedeth: 64-bit DMA (consistent) failed, using 32-bit ring buffers for device %s.\n",
-				       pci_name(pci_dev));
+				dev_printk(KERN_INFO, &pci_dev->dev,
+					"64-bit DMA (consistent) failed, using 32-bit ring buffers\n");
 			}
 		}
 	} else if (id->driver_data & DEV_HAS_LARGEDESC) {
@@ -5205,9 +5207,11 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 		 * Bad mac address. At least one bios sets the mac address
 		 * to 01:23:45:67:89:ab
 		 */
-		printk(KERN_ERR "%s: Invalid Mac address detected: %s\n",
-		       pci_name(pci_dev), print_mac(mac, dev->dev_addr));
-		printk(KERN_ERR "Please complain to your hardware vendor. Switching to a random MAC.\n");
+		dev_printk(KERN_ERR, &pci_dev->dev,
+			"Invalid Mac address detected: %s\n",
+		        print_mac(mac, dev->dev_addr));
+		dev_printk(KERN_ERR, &pci_dev->dev,
+			"Please complain to your hardware vendor. Switching to a random MAC.\n");
 		dev->dev_addr[0] = 0x00;
 		dev->dev_addr[1] = 0x00;
 		dev->dev_addr[2] = 0x6c;
@@ -5321,8 +5325,8 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 		break;
 	}
 	if (i == 33) {
-		printk(KERN_INFO "%s: open: Could not find a valid PHY.\n",
-		       pci_name(pci_dev));
+		dev_printk(KERN_INFO, &pci_dev->dev,
+			"open: Could not find a valid PHY.\n");
 		goto out_error;
 	}
 
@@ -5344,12 +5348,37 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 
 	err = register_netdev(dev);
 	if (err) {
-		printk(KERN_INFO "forcedeth: unable to register netdev: %d\n", err);
+		dev_printk(KERN_INFO, &pci_dev->dev,
+			   "unable to register netdev: %d\n", err);
 		goto out_error;
 	}
-	printk(KERN_INFO "%s: forcedeth.c: subsystem: %05x:%04x bound to %s\n",
-			dev->name, pci_dev->subsystem_vendor, pci_dev->subsystem_device,
-			pci_name(pci_dev));
+
+	dev_printk(KERN_INFO, &pci_dev->dev, "ifname %s, PHY OUI 0x%x @ %d, "
+		   "addr %2.2x:%2.2x:%2.2x:%2.2x:%2.2x:%2.2x\n",
+		   dev->name,
+		   np->phy_oui,
+		   np->phyaddr,
+		   dev->dev_addr[0],
+		   dev->dev_addr[1],
+		   dev->dev_addr[2],
+		   dev->dev_addr[3],
+		   dev->dev_addr[4],
+		   dev->dev_addr[5]);
+
+	dev_printk(KERN_INFO, &pci_dev->dev, "%s%s%s%s%s%s%s%s%s%sdesc-v%u\n",
+		   dev->features & NETIF_F_HIGHDMA ? "highdma " : "",
+		   dev->features & (NETIF_F_HW_CSUM | NETIF_F_SG) ?
+		   	"csum " : "",
+		   dev->features & (NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_TX) ?
+		   	"vlan " : "",
+		   id->driver_data & DEV_HAS_POWER_CNTRL ? "pwrctl " : "",
+		   id->driver_data & DEV_HAS_MGMT_UNIT ? "mgmt " : "",
+		   id->driver_data & DEV_NEED_TIMERIRQ ? "timirq " : "",
+		   np->gigabit == PHY_GIGABIT ? "gbit " : "",
+		   np->need_linktimer ? "lnktim " : "",
+		   np->msi_flags & NV_MSI_CAPABLE ? "msi " : "",
+		   np->msi_flags & NV_MSI_X_CAPABLE ? "msi-x " : "",
+		   np->desc_ver);
 
 	return 0;
 
@@ -5567,17 +5596,16 @@ static struct pci_device_id pci_tbl[] = {
 };
 
 static struct pci_driver driver = {
-	.name = "forcedeth",
-	.id_table = pci_tbl,
-	.probe = nv_probe,
-	.remove = __devexit_p(nv_remove),
-	.suspend = nv_suspend,
-	.resume	= nv_resume,
+	.name		= DRV_NAME,
+	.id_table	= pci_tbl,
+	.probe		= nv_probe,
+	.remove		= __devexit_p(nv_remove),
+	.suspend	= nv_suspend,
+	.resume		= nv_resume,
 };
 
 static int __init init_nic(void)
 {
-	printk(KERN_INFO "forcedeth.c: Reverse Engineered nForce ethernet driver. Version %s.\n", FORCEDETH_VERSION);
 	return pci_register_driver(&driver);
 }
 
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 558440c..cc288d8 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1237,8 +1237,6 @@ static int gfar_change_mtu(struct net_device *dev, int new_mtu)
  * starting over will fix the problem. */
 static void gfar_timeout(struct net_device *dev)
 {
-	struct gfar_private *priv = netdev_priv(dev);
-
 	dev->stats.tx_errors++;
 
 	if (dev->flags & IFF_UP) {
@@ -1344,8 +1342,9 @@ struct sk_buff * gfar_new_skb(struct net_device *dev, struct rxbd8 *bdp)
 	return skb;
 }
 
-static inline void count_errors(unsigned short status, struct gfar_private *priv)
+static inline void count_errors(unsigned short status, struct net_device *dev)
 {
+	struct gfar_private *priv = netdev_priv(dev);
 	struct net_device_stats *stats = &dev->stats;
 	struct gfar_extra_stats *estats = &priv->extra_stats;
 
@@ -1539,7 +1538,7 @@ int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit)
 
 			dev->stats.rx_bytes += pkt_len;
 		} else {
-			count_errors(bdp->status, priv);
+			count_errors(bdp->status, dev);
 
 			if (skb)
 				dev_kfree_skb_any(skb);
diff --git a/drivers/net/ibm_newemac/mal.c b/drivers/net/ibm_newemac/mal.c
index 39f4cb6..a680eb0 100644
--- a/drivers/net/ibm_newemac/mal.c
+++ b/drivers/net/ibm_newemac/mal.c
@@ -45,6 +45,8 @@ int __devinit mal_register_commac(struct mal_instance	*mal,
 		return -EBUSY;
 	}
 
+	if (list_empty(&mal->list))
+		napi_enable(&mal->napi);
 	mal->tx_chan_mask |= commac->tx_chan_mask;
 	mal->rx_chan_mask |= commac->rx_chan_mask;
 	list_add(&commac->list, &mal->list);
@@ -67,6 +69,8 @@ void __devexit mal_unregister_commac(struct mal_instance	*mal,
 	mal->tx_chan_mask &= ~commac->tx_chan_mask;
 	mal->rx_chan_mask &= ~commac->rx_chan_mask;
 	list_del_init(&commac->list);
+	if (list_empty(&mal->list))
+		napi_disable(&mal->napi);
 
 	spin_unlock_irqrestore(&mal->lock, flags);
 }
@@ -182,7 +186,7 @@ static inline void mal_enable_eob_irq(struct mal_instance *mal)
 	set_mal_dcrn(mal, MAL_CFG, get_mal_dcrn(mal, MAL_CFG) | MAL_CFG_EOPIE);
 }
 
-/* synchronized by __LINK_STATE_RX_SCHED bit in ndev->state */
+/* synchronized by NAPI state */
 static inline void mal_disable_eob_irq(struct mal_instance *mal)
 {
 	// XXX might want to cache MAL_CFG as the DCR read can be slooooow
@@ -317,8 +321,8 @@ void mal_poll_disable(struct mal_instance *mal, struct mal_commac *commac)
 	while (test_and_set_bit(MAL_COMMAC_POLL_DISABLED, &commac->flags))
 		msleep(1);
 
-	/* Synchronize with the MAL NAPI poller. */
-	napi_disable(&mal->napi);
+	/* Synchronize with the MAL NAPI poller */
+	__napi_synchronize(&mal->napi);
 }
 
 void mal_poll_enable(struct mal_instance *mal, struct mal_commac *commac)
@@ -326,7 +330,12 @@ void mal_poll_enable(struct mal_instance *mal, struct mal_commac *commac)
 	smp_wmb();
 	clear_bit(MAL_COMMAC_POLL_DISABLED, &commac->flags);
 
-	// XXX might want to kick a poll now...
+	/* Feels better to trigger a poll here to catch up with events that
+	 * may have happened on this channel while disabled. It will most
+	 * probably be delayed until the next interrupt but that's mostly a
+	 * non-issue in the context where this is called.
+	 */
+	napi_schedule(&mal->napi);
 }
 
 static int mal_poll(struct napi_struct *napi, int budget)
@@ -336,8 +345,7 @@ static int mal_poll(struct napi_struct *napi, int budget)
 	int received = 0;
 	unsigned long flags;
 
-	MAL_DBG2(mal, "poll(%d) %d ->" NL, *budget,
-		 rx_work_limit);
+	MAL_DBG2(mal, "poll(%d)" NL, budget);
  again:
 	/* Process TX skbs */
 	list_for_each(l, &mal->poll_list) {
@@ -528,11 +536,12 @@ static int __devinit mal_probe(struct of_device *ofdev,
 	}
 
 	INIT_LIST_HEAD(&mal->poll_list);
-	mal->napi.weight = CONFIG_IBM_NEW_EMAC_POLL_WEIGHT;
-	mal->napi.poll = mal_poll;
 	INIT_LIST_HEAD(&mal->list);
 	spin_lock_init(&mal->lock);
 
+	netif_napi_add(NULL, &mal->napi, mal_poll,
+		       CONFIG_IBM_NEW_EMAC_POLL_WEIGHT);
+
 	/* Load power-on reset defaults */
 	mal_reset(mal);
 
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index 2aae9fe..b9961dc 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -36,13 +36,15 @@
 #include <linux/delay.h>
 #include <linux/crc32.h>
 #include <linux/dma-mapping.h>
+#include <linux/debugfs.h>
+#include <linux/seq_file.h>
 #include <linux/mii.h>
 #include <asm/irq.h>
 
 #include "skge.h"
 
 #define DRV_NAME		"skge"
-#define DRV_VERSION		"1.11"
+#define DRV_VERSION		"1.12"
 #define PFX			DRV_NAME " "
 
 #define DEFAULT_TX_RING_SIZE	128
@@ -57,7 +59,10 @@
 #define TX_WATCHDOG		(5 * HZ)
 #define NAPI_WEIGHT		64
 #define BLINK_MS		250
-#define LINK_HZ			(HZ/2)
+#define LINK_HZ			HZ
+
+#define SKGE_EEPROM_MAGIC	0x9933aabb
+
 
 MODULE_DESCRIPTION("SysKonnect Gigabit Ethernet driver");
 MODULE_AUTHOR("Stephen Hemminger <shemminger@linux-foundation.org>");
@@ -445,15 +450,15 @@ static struct net_device_stats *skge_get_stats(struct net_device *dev)
 	else
 		yukon_get_stats(skge, data);
 
-	skge->net_stats.tx_bytes = data[0];
-	skge->net_stats.rx_bytes = data[1];
-	skge->net_stats.tx_packets = data[2] + data[4] + data[6];
-	skge->net_stats.rx_packets = data[3] + data[5] + data[7];
-	skge->net_stats.multicast = data[3] + data[5];
-	skge->net_stats.collisions = data[10];
-	skge->net_stats.tx_aborted_errors = data[12];
+	dev->stats.tx_bytes = data[0];
+	dev->stats.rx_bytes = data[1];
+	dev->stats.tx_packets = data[2] + data[4] + data[6];
+	dev->stats.rx_packets = data[3] + data[5] + data[7];
+	dev->stats.multicast = data[3] + data[5];
+	dev->stats.collisions = data[10];
+	dev->stats.tx_aborted_errors = data[12];
 
-	return &skge->net_stats;
+	return &dev->stats;
 }
 
 static void skge_get_strings(struct net_device *dev, u32 stringset, u8 *data)
@@ -798,6 +803,98 @@ static int skge_phys_id(struct net_device *dev, u32 data)
 	return 0;
 }
 
+static int skge_get_eeprom_len(struct net_device *dev)
+{
+	struct skge_port *skge = netdev_priv(dev);
+	u32 reg2;
+
+	pci_read_config_dword(skge->hw->pdev, PCI_DEV_REG2, &reg2);
+	return 1 << ( ((reg2 & PCI_VPD_ROM_SZ) >> 14) + 8);
+}
+
+static u32 skge_vpd_read(struct pci_dev *pdev, int cap, u16 offset)
+{
+	u32 val;
+
+	pci_write_config_word(pdev, cap + PCI_VPD_ADDR, offset);
+
+	do {
+		pci_read_config_word(pdev, cap + PCI_VPD_ADDR, &offset);
+	} while (!(offset & PCI_VPD_ADDR_F));
+
+	pci_read_config_dword(pdev, cap + PCI_VPD_DATA, &val);
+	return val;
+}
+
+static void skge_vpd_write(struct pci_dev *pdev, int cap, u16 offset, u32 val)
+{
+	pci_write_config_dword(pdev, cap + PCI_VPD_DATA, val);
+	pci_write_config_word(pdev, cap + PCI_VPD_ADDR,
+			      offset | PCI_VPD_ADDR_F);
+
+	do {
+		pci_read_config_word(pdev, cap + PCI_VPD_ADDR, &offset);
+	} while (offset & PCI_VPD_ADDR_F);
+}
+
+static int skge_get_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
+			   u8 *data)
+{
+	struct skge_port *skge = netdev_priv(dev);
+	struct pci_dev *pdev = skge->hw->pdev;
+	int cap = pci_find_capability(pdev, PCI_CAP_ID_VPD);
+	int length = eeprom->len;
+	u16 offset = eeprom->offset;
+
+	if (!cap)
+		return -EINVAL;
+
+	eeprom->magic = SKGE_EEPROM_MAGIC;
+
+	while (length > 0) {
+		u32 val = skge_vpd_read(pdev, cap, offset);
+		int n = min_t(int, length, sizeof(val));
+
+		memcpy(data, &val, n);
+		length -= n;
+		data += n;
+		offset += n;
+	}
+	return 0;
+}
+
+static int skge_set_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
+			   u8 *data)
+{
+	struct skge_port *skge = netdev_priv(dev);
+	struct pci_dev *pdev = skge->hw->pdev;
+	int cap = pci_find_capability(pdev, PCI_CAP_ID_VPD);
+	int length = eeprom->len;
+	u16 offset = eeprom->offset;
+
+	if (!cap)
+		return -EINVAL;
+
+	if (eeprom->magic != SKGE_EEPROM_MAGIC)
+		return -EINVAL;
+
+	while (length > 0) {
+		u32 val;
+		int n = min_t(int, length, sizeof(val));
+
+		if (n < sizeof(val))
+			val = skge_vpd_read(pdev, cap, offset);
+		memcpy(&val, data, n);
+
+		skge_vpd_write(pdev, cap, offset, val);
+
+		length -= n;
+		data += n;
+		offset += n;
+	}
+	return 0;
+}
+
 static const struct ethtool_ops skge_ethtool_ops = {
 	.get_settings	= skge_get_settings,
 	.set_settings	= skge_set_settings,
@@ -810,6 +907,9 @@ static const struct ethtool_ops skge_ethtool_ops = {
 	.set_msglevel	= skge_set_msglevel,
 	.nway_reset	= skge_nway_reset,
 	.get_link	= ethtool_op_get_link,
+	.get_eeprom_len	= skge_get_eeprom_len,
+	.get_eeprom	= skge_get_eeprom,
+	.set_eeprom	= skge_set_eeprom,
 	.get_ringparam	= skge_get_ring_param,
 	.set_ringparam	= skge_set_ring_param,
 	.get_pauseparam = skge_get_pauseparam,
@@ -995,19 +1095,15 @@ static void xm_link_down(struct skge_hw *hw, int port)
 {
 	struct net_device *dev = hw->dev[port];
 	struct skge_port *skge = netdev_priv(dev);
-	u16 cmd, msk;
+	u16 cmd = xm_read16(hw, port, XM_MMU_CMD);
 
-	if (hw->phy_type == SK_PHY_XMAC) {
-		msk = xm_read16(hw, port, XM_IMSK);
-		msk |= XM_IS_INP_ASS | XM_IS_LIPA_RC | XM_IS_RX_PAGE | XM_IS_AND;
-		xm_write16(hw, port, XM_IMSK, msk);
-	}
+	xm_write16(hw, port, XM_IMSK, XM_IMSK_DISABLE);
 
-	cmd = xm_read16(hw, port, XM_MMU_CMD);
 	cmd &= ~(XM_MMU_ENA_RX | XM_MMU_ENA_TX);
 	xm_write16(hw, port, XM_MMU_CMD, cmd);
+
 	/* dummy read to ensure writing */
-	(void) xm_read16(hw, port, XM_MMU_CMD);
+	xm_read16(hw, port, XM_MMU_CMD);
 
 	if (netif_carrier_ok(dev))
 		skge_link_down(skge);
@@ -1103,7 +1199,7 @@ static void genesis_reset(struct skge_hw *hw, int port)
 
 	/* reset the statistics module */
 	xm_write32(hw, port, XM_GP_PORT, XM_GP_RES_STAT);
-	xm_write16(hw, port, XM_IMSK, 0xffff);	/* disable XMAC IRQs */
+	xm_write16(hw, port, XM_IMSK, XM_IMSK_DISABLE);
 	xm_write32(hw, port, XM_MODE, 0);		/* clear Mode Reg */
 	xm_write16(hw, port, XM_TX_CMD, 0);	/* reset TX CMD Reg */
 	xm_write16(hw, port, XM_RX_CMD, 0);	/* reset RX CMD Reg */
@@ -1141,7 +1237,7 @@ static void bcom_check_link(struct skge_hw *hw, int port)
 	u16 status;
 
 	/* read twice because of latch */
-	(void) xm_phy_read(hw, port, PHY_BCOM_STAT);
+	xm_phy_read(hw, port, PHY_BCOM_STAT);
 	status = xm_phy_read(hw, port, PHY_BCOM_STAT);
 
 	if ((status & PHY_ST_LSYNC) == 0) {
@@ -1342,7 +1438,7 @@ static void xm_phy_init(struct skge_port *skge)
 	mod_timer(&skge->link_timer, jiffies + LINK_HZ);
 }
 
-static void xm_check_link(struct net_device *dev)
+static int xm_check_link(struct net_device *dev)
 {
 	struct skge_port *skge = netdev_priv(dev);
 	struct skge_hw *hw = skge->hw;
@@ -1350,25 +1446,25 @@ static void xm_check_link(struct net_device *dev)
 	u16 status;
 
 	/* read twice because of latch */
-	(void) xm_phy_read(hw, port, PHY_XMAC_STAT);
+	xm_phy_read(hw, port, PHY_XMAC_STAT);
 	status = xm_phy_read(hw, port, PHY_XMAC_STAT);
 
 	if ((status & PHY_ST_LSYNC) == 0) {
 		xm_link_down(hw, port);
-		return;
+		return 0;
 	}
 
 	if (skge->autoneg == AUTONEG_ENABLE) {
 		u16 lpa, res;
 
 		if (!(status & PHY_ST_AN_OVER))
-			return;
+			return 0;
 
 		lpa = xm_phy_read(hw, port, PHY_XMAC_AUNE_LP);
 		if (lpa & PHY_B_AN_RF) {
 			printk(KERN_NOTICE PFX "%s: remote fault\n",
 			       dev->name);
-			return;
+			return 0;
 		}
 
 		res = xm_phy_read(hw, port, PHY_XMAC_RES_ABI);
@@ -1384,7 +1480,7 @@ static void xm_check_link(struct net_device *dev)
 		default:
 			printk(KERN_NOTICE PFX "%s: duplex mismatch\n",
 			       dev->name);
-			return;
+			return 0;
 		}
 
 		/* We are using IEEE 802.3z/D5.0 Table 37-4 */
@@ -1408,11 +1504,14 @@ static void xm_check_link(struct net_device *dev)
 
 	if (!netif_carrier_ok(dev))
 		genesis_link_up(skge);
+	return 1;
 }
 
 /* Poll to check for link coming up.
+ *
  * Since internal PHY is wired to a level triggered pin, can't
- * get an interrupt when carrier is detected.
+ * get an interrupt when carrier is detected, need to poll for
+ * link coming up.
  */
 static void xm_link_timer(unsigned long arg)
 {
@@ -1420,29 +1519,35 @@ static void xm_link_timer(unsigned long arg)
 	struct net_device *dev = skge->netdev;
  	struct skge_hw *hw = skge->hw;
 	int port = skge->port;
+	int i;
+	unsigned long flags;
 
 	if (!netif_running(dev))
 		return;
 
-	if (netif_carrier_ok(dev)) {
+	spin_lock_irqsave(&hw->phy_lock, flags);
+
+	/*
+	 * Verify that the link by checking GPIO register three times.
+	 * This pin has the signal from the link_sync pin connected to it.
+	 */
+	for (i = 0; i < 3; i++) {
+		if (xm_read16(hw, port, XM_GP_PORT) & XM_GP_INP_ASS)
+			goto link_down;
+	}
+
+        /* Re-enable interrupt to detect link down */
+	if (xm_check_link(dev)) {
+		u16 msk = xm_read16(hw, port, XM_IMSK);
+		msk &= ~XM_IS_INP_ASS;
+		xm_write16(hw, port, XM_IMSK, msk);
 		xm_read16(hw, port, XM_ISRC);
-		if (!(xm_read16(hw, port, XM_ISRC) & XM_IS_INP_ASS))
-			goto nochange;
 	} else {
-		if (xm_read32(hw, port, XM_GP_PORT) & XM_GP_INP_ASS)
-			goto nochange;
-		xm_read16(hw, port, XM_ISRC);
-		if (xm_read16(hw, port, XM_ISRC) & XM_IS_INP_ASS)
-			goto nochange;
+link_down:
+		mod_timer(&skge->link_timer,
+			  round_jiffies(jiffies + LINK_HZ));
 	}
-
-	spin_lock(&hw->phy_lock);
-	xm_check_link(dev);
-	spin_unlock(&hw->phy_lock);
-
-nochange:
-	if (netif_running(dev))
-		mod_timer(&skge->link_timer, jiffies + LINK_HZ);
+	spin_unlock_irqrestore(&hw->phy_lock, flags);
 }
 
 static void genesis_mac_init(struct skge_hw *hw, int port)
@@ -1679,24 +1784,27 @@ static void genesis_get_stats(struct skge_port *skge, u64 *data)
 
 static void genesis_mac_intr(struct skge_hw *hw, int port)
 {
-	struct skge_port *skge = netdev_priv(hw->dev[port]);
+	struct net_device *dev = hw->dev[port];
+	struct skge_port *skge = netdev_priv(dev);
 	u16 status = xm_read16(hw, port, XM_ISRC);
 
 	if (netif_msg_intr(skge))
 		printk(KERN_DEBUG PFX "%s: mac interrupt status 0x%x\n",
-		       skge->netdev->name, status);
+		       dev->name, status);
 
-	if (hw->phy_type == SK_PHY_XMAC &&
-	    (status & (XM_IS_INP_ASS | XM_IS_LIPA_RC)))
-		xm_link_down(hw, port);
+	if (hw->phy_type == SK_PHY_XMAC && (status & XM_IS_INP_ASS)) {
+  		xm_link_down(hw, port);
+		mod_timer(&skge->link_timer, jiffies + 1);
+	}
 
 	if (status & XM_IS_TXF_UR) {
 		xm_write32(hw, port, XM_MODE, XM_MD_FTF);
-		++skge->net_stats.tx_fifo_errors;
+		++dev->stats.tx_fifo_errors;
 	}
+
 	if (status & XM_IS_RXF_OV) {
 		xm_write32(hw, port, XM_MODE, XM_MD_FRF);
-		++skge->net_stats.rx_fifo_errors;
+		++dev->stats.rx_fifo_errors;
 	}
 }
 
@@ -1753,11 +1861,12 @@ static void genesis_link_up(struct skge_port *skge)
 	}
 
 	xm_write32(hw, port, XM_MODE, mode);
-	msk = XM_DEF_MSK;
-	if (hw->phy_type != SK_PHY_XMAC)
-		msk |= XM_IS_INP_ASS;	/* disable GP0 interrupt bit */
 
+	/* Turn on detection of Tx underrun, Rx overrun */
+	msk = xm_read16(hw, port, XM_IMSK);
+	msk &= ~(XM_IS_RXF_OV | XM_IS_TXF_UR);
 	xm_write16(hw, port, XM_IMSK, msk);
+
 	xm_read16(hw, port, XM_ISRC);
 
 	/* get MMU Command Reg. */
@@ -2192,12 +2301,12 @@ static void yukon_mac_intr(struct skge_hw *hw, int port)
 		       dev->name, status);
 
 	if (status & GM_IS_RX_FF_OR) {
-		++skge->net_stats.rx_fifo_errors;
+		++dev->stats.rx_fifo_errors;
 		skge_write8(hw, SK_REG(port, RX_GMF_CTRL_T), GMF_CLI_RX_FO);
 	}
 
 	if (status & GM_IS_TX_FF_UR) {
-		++skge->net_stats.tx_fifo_errors;
+		++dev->stats.tx_fifo_errors;
 		skge_write8(hw, SK_REG(port, TX_GMF_CTRL_T), GMF_CLI_TX_FU);
 	}
 
@@ -2403,32 +2512,31 @@ static int skge_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	return err;
 }
 
-static void skge_ramset(struct skge_hw *hw, u16 q, u32 start, size_t len)
+/* Assign Ram Buffer allocation to queue */
+static void skge_ramset(struct skge_hw *hw, u16 q, u32 start, u32 space)
 {
 	u32 end;
 
-	start /= 8;
-	len /= 8;
-	end = start + len - 1;
+	/* convert from K bytes to qwords used for hw register */
+	start *= 1024/8;
+	space *= 1024/8;
+	end = start + space - 1;
 
 	skge_write8(hw, RB_ADDR(q, RB_CTRL), RB_RST_CLR);
 	skge_write32(hw, RB_ADDR(q, RB_START), start);
+	skge_write32(hw, RB_ADDR(q, RB_END), end);
 	skge_write32(hw, RB_ADDR(q, RB_WP), start);
 	skge_write32(hw, RB_ADDR(q, RB_RP), start);
-	skge_write32(hw, RB_ADDR(q, RB_END), end);
 
 	if (q == Q_R1 || q == Q_R2) {
+		u32 tp = space - space/4;
+
 		/* Set thresholds on receive queue's */
-		skge_write32(hw, RB_ADDR(q, RB_RX_UTPP),
-			     start + (2*len)/3);
-		skge_write32(hw, RB_ADDR(q, RB_RX_LTPP),
-			     start + (len/3));
-	} else {
-		/* Enable store & forward on Tx queue's because
-		 * Tx FIFO is only 4K on Genesis and 1K on Yukon
-		 */
+		skge_write32(hw, RB_ADDR(q, RB_RX_UTPP), tp);
+		skge_write32(hw, RB_ADDR(q, RB_RX_LTPP), space/4);
+	} else if (hw->chip_id != CHIP_ID_GENESIS)
+		/* Genesis Tx Fifo is too small for normal store/forward */
 		skge_write8(hw, RB_ADDR(q, RB_CTRL), RB_ENA_STFWD);
-	}
 
 	skge_write8(hw, RB_ADDR(q, RB_CTRL), RB_ENA_OP_MD);
 }
@@ -2456,7 +2564,7 @@ static int skge_up(struct net_device *dev)
 	struct skge_port *skge = netdev_priv(dev);
 	struct skge_hw *hw = skge->hw;
 	int port = skge->port;
-	u32 chunk, ram_addr;
+	u32 ramaddr, ramsize, rxspace;
 	size_t rx_size, tx_size;
 	int err;
 
@@ -2511,14 +2619,15 @@ static int skge_up(struct net_device *dev)
 	spin_unlock_bh(&hw->phy_lock);
 
 	/* Configure RAMbuffers */
-	chunk = hw->ram_size / ((hw->ports + 1)*2);
-	ram_addr = hw->ram_offset + 2 * chunk * port;
+	ramsize = (hw->ram_size - hw->ram_offset) / hw->ports;
+	ramaddr = hw->ram_offset + port * ramsize;
+	rxspace = 8 + (2*(ramsize - 16))/3;
 
-	skge_ramset(hw, rxqaddr[port], ram_addr, chunk);
-	skge_qset(skge, rxqaddr[port], skge->rx_ring.to_clean);
+	skge_ramset(hw, rxqaddr[port], ramaddr, rxspace);
+	skge_ramset(hw, txqaddr[port], ramaddr + rxspace, ramsize - rxspace);
 
+	skge_qset(skge, rxqaddr[port], skge->rx_ring.to_clean);
 	BUG_ON(skge->tx_ring.to_use != skge->tx_ring.to_clean);
-	skge_ramset(hw, txqaddr[port], ram_addr+chunk, chunk);
 	skge_qset(skge, txqaddr[port], skge->tx_ring.to_use);
 
 	/* Start receiver BMU */
@@ -2544,6 +2653,15 @@ static int skge_up(struct net_device *dev)
 	return err;
 }
 
+/* stop receiver */
+static void skge_rx_stop(struct skge_hw *hw, int port)
+{
+	skge_write8(hw, Q_ADDR(rxqaddr[port], Q_CSR), CSR_STOP);
+	skge_write32(hw, RB_ADDR(port ? Q_R2 : Q_R1, RB_CTRL),
+		     RB_RST_SET|RB_DIS_OP_MD);
+	skge_write32(hw, Q_ADDR(rxqaddr[port], Q_CSR), CSR_SET_RESET);
+}
+
 static int skge_down(struct net_device *dev)
 {
 	struct skge_port *skge = netdev_priv(dev);
@@ -2595,11 +2713,8 @@ static int skge_down(struct net_device *dev)
 
 	/* Reset the RAM Buffer async Tx queue */
 	skge_write8(hw, RB_ADDR(port == 0 ? Q_XA1 : Q_XA2, RB_CTRL), RB_RST_SET);
-	/* stop receiver */
-	skge_write8(hw, Q_ADDR(rxqaddr[port], Q_CSR), CSR_STOP);
-	skge_write32(hw, RB_ADDR(port ? Q_R2 : Q_R1, RB_CTRL),
-		     RB_RST_SET|RB_DIS_OP_MD);
-	skge_write32(hw, Q_ADDR(rxqaddr[port], Q_CSR), CSR_SET_RESET);
+
+	skge_rx_stop(hw, port);
 
 	if (hw->chip_id == CHIP_ID_GENESIS) {
 		skge_write8(hw, SK_REG(port, TX_MFF_CTRL2), MFF_RST_SET);
@@ -2782,7 +2897,11 @@ static void skge_tx_timeout(struct net_device *dev)
 
 static int skge_change_mtu(struct net_device *dev, int new_mtu)
 {
+	struct skge_port *skge = netdev_priv(dev);
+	struct skge_hw *hw = skge->hw;
+	int port = skge->port;
 	int err;
+	u16 ctl, reg;
 
 	if (new_mtu < ETH_ZLEN || new_mtu > ETH_JUMBO_MTU)
 		return -EINVAL;
@@ -2792,13 +2911,40 @@ static int skge_change_mtu(struct net_device *dev, int new_mtu)
 		return 0;
 	}
 
-	skge_down(dev);
+	skge_write32(hw, B0_IMSK, 0);
+	dev->trans_start = jiffies;	/* prevent tx timeout */
+	netif_stop_queue(dev);
+	napi_disable(&skge->napi);
+
+	ctl = gma_read16(hw, port, GM_GP_CTRL);
+	gma_write16(hw, port, GM_GP_CTRL, ctl & ~GM_GPCR_RX_ENA);
+
+	skge_rx_clean(skge);
+	skge_rx_stop(hw, port);
 
 	dev->mtu = new_mtu;
 
-	err = skge_up(dev);
+	reg = GM_SMOD_VLAN_ENA | IPG_DATA_VAL(IPG_DATA_DEF);
+	if (new_mtu > 1500)
+		reg |= GM_SMOD_JUMBO_ENA;
+	gma_write16(hw, port, GM_SERIAL_MODE, reg);
+
+	skge_write8(hw, RB_ADDR(rxqaddr[port], RB_CTRL), RB_ENA_OP_MD);
+
+	err = skge_rx_fill(dev);
+	wmb();
+	if (!err)
+		skge_write8(hw, Q_ADDR(rxqaddr[port], Q_CSR), CSR_START | CSR_IRQ_CL_F);
+	skge_write32(hw, B0_IMSK, hw->intr_mask);
+
 	if (err)
 		dev_close(dev);
+	else {
+		gma_write16(hw, port, GM_GP_CTRL, ctl);
+
+		napi_enable(&skge->napi);
+		netif_wake_queue(dev);
+	}
 
 	return err;
 }
@@ -2994,18 +3140,18 @@ error:
 
 	if (skge->hw->chip_id == CHIP_ID_GENESIS) {
 		if (status & (XMR_FS_RUNT|XMR_FS_LNG_ERR))
-			skge->net_stats.rx_length_errors++;
+			dev->stats.rx_length_errors++;
 		if (status & XMR_FS_FRA_ERR)
-			skge->net_stats.rx_frame_errors++;
+			dev->stats.rx_frame_errors++;
 		if (status & XMR_FS_FCS_ERR)
-			skge->net_stats.rx_crc_errors++;
+			dev->stats.rx_crc_errors++;
 	} else {
 		if (status & (GMR_FS_LONG_ERR|GMR_FS_UN_SIZE))
-			skge->net_stats.rx_length_errors++;
+			dev->stats.rx_length_errors++;
 		if (status & GMR_FS_FRAGMENT)
-			skge->net_stats.rx_frame_errors++;
+			dev->stats.rx_frame_errors++;
 		if (status & GMR_FS_CRC_ERR)
-			skge->net_stats.rx_crc_errors++;
+			dev->stats.rx_crc_errors++;
 	}
 
 resubmit:
@@ -3103,10 +3249,7 @@ static void skge_mac_parity(struct skge_hw *hw, int port)
 {
 	struct net_device *dev = hw->dev[port];
 
-	if (dev) {
-		struct skge_port *skge = netdev_priv(dev);
-		++skge->net_stats.tx_heartbeat_errors;
-	}
+	++dev->stats.tx_heartbeat_errors;
 
 	if (hw->chip_id == CHIP_ID_GENESIS)
 		skge_write16(hw, SK_REG(port, TX_MFF_CTRL1),
@@ -3259,9 +3402,7 @@ static irqreturn_t skge_intr(int irq, void *dev_id)
 		skge_write16(hw, B3_PA_CTRL, PA_CLR_TO_TX1);
 
 	if (status & IS_PA_TO_RX1) {
-		struct skge_port *skge = netdev_priv(hw->dev[0]);
-
-		++skge->net_stats.rx_over_errors;
+		++hw->dev[0]->stats.rx_over_errors;
 		skge_write16(hw, B3_PA_CTRL, PA_CLR_TO_RX1);
 	}
 
@@ -3278,7 +3419,7 @@ static irqreturn_t skge_intr(int irq, void *dev_id)
 		}
 
 		if (status & IS_PA_TO_RX2) {
-			++skge->net_stats.rx_over_errors;
+			++hw->dev[1]->stats.rx_over_errors;
 			skge_write16(hw, B3_PA_CTRL, PA_CLR_TO_RX2);
 		}
 
@@ -3450,15 +3591,12 @@ static int skge_reset(struct skge_hw *hw)
 	if (hw->chip_id == CHIP_ID_GENESIS) {
 		if (t8 == 3) {
 			/* special case: 4 x 64k x 36, offset = 0x80000 */
-			hw->ram_size = 0x100000;
-			hw->ram_offset = 0x80000;
+			hw->ram_size = 1024;
+			hw->ram_offset = 512;
 		} else
 			hw->ram_size = t8 * 512;
-	}
-	else if (t8 == 0)
-		hw->ram_size = 0x20000;
-	else
-		hw->ram_size = t8 * 4096;
+	} else /* Yukon */
+		hw->ram_size = t8 ? t8 * 4 : 128;
 
 	hw->intr_mask = IS_HW_ERR;
 
@@ -3540,6 +3678,145 @@ static int skge_reset(struct skge_hw *hw)
 	return 0;
 }
 
+
+#ifdef CONFIG_SKGE_DEBUG
+
+static struct dentry *skge_debug;
+
+static int skge_debug_show(struct seq_file *seq, void *v)
+{
+	struct net_device *dev = seq->private;
+	const struct skge_port *skge = netdev_priv(dev);
+	const struct skge_hw *hw = skge->hw;
+	const struct skge_element *e;
+
+	if (!netif_running(dev))
+		return -ENETDOWN;
+
+	seq_printf(seq, "IRQ src=%x mask=%x\n", skge_read32(hw, B0_ISRC),
+		   skge_read32(hw, B0_IMSK));
+
+	seq_printf(seq, "Tx Ring: (%d)\n", skge_avail(&skge->tx_ring));
+	for (e = skge->tx_ring.to_clean; e != skge->tx_ring.to_use; e = e->next) {
+		const struct skge_tx_desc *t = e->desc;
+		seq_printf(seq, "%#x dma=%#x%08x %#x csum=%#x/%x/%x\n",
+			   t->control, t->dma_hi, t->dma_lo, t->status,
+			   t->csum_offs, t->csum_write, t->csum_start);
+	}
+
+	seq_printf(seq, "\nRx Ring: \n");
+	for (e = skge->rx_ring.to_clean; ; e = e->next) {
+		const struct skge_rx_desc *r = e->desc;
+
+		if (r->control & BMU_OWN)
+			break;
+
+		seq_printf(seq, "%#x dma=%#x%08x %#x %#x csum=%#x/%x\n",
+			   r->control, r->dma_hi, r->dma_lo, r->status,
+			   r->timestamp, r->csum1, r->csum1_start);
+	}
+
+	return 0;
+}
+
+static int skge_debug_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, skge_debug_show, inode->i_private);
+}
+
+static const struct file_operations skge_debug_fops = {
+	.owner		= THIS_MODULE,
+	.open		= skge_debug_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
+/*
+ * Use network device events to create/remove/rename
+ * debugfs file entries
+ */
+static int skge_device_event(struct notifier_block *unused,
+			     unsigned long event, void *ptr)
+{
+	struct net_device *dev = ptr;
+	struct skge_port *skge;
+	struct dentry *d;
+
+	if (dev->open != &skge_up || !skge_debug)
+		goto done;
+
+	skge = netdev_priv(dev);
+	switch(event) {
+	case NETDEV_CHANGENAME:
+		if (skge->debugfs) {
+			d = debugfs_rename(skge_debug, skge->debugfs,
+					   skge_debug, dev->name);
+			if (d)
+				skge->debugfs = d;
+			else {
+				pr_info(PFX "%s: rename failed\n", dev->name);
+				debugfs_remove(skge->debugfs);
+			}
+		}
+		break;
+
+	case NETDEV_GOING_DOWN:
+		if (skge->debugfs) {
+			debugfs_remove(skge->debugfs);
+			skge->debugfs = NULL;
+		}
+		break;
+
+	case NETDEV_UP:
+		d = debugfs_create_file(dev->name, S_IRUGO,
+					skge_debug, dev,
+					&skge_debug_fops);
+		if (!d || IS_ERR(d))
+			pr_info(PFX "%s: debugfs create failed\n",
+			       dev->name);
+		else
+			skge->debugfs = d;
+		break;
+	}
+
+done:
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block skge_notifier = {
+	.notifier_call = skge_device_event,
+};
+
+
+static __init void skge_debug_init(void)
+{
+	struct dentry *ent;
+
+	ent = debugfs_create_dir("skge", NULL);
+	if (!ent || IS_ERR(ent)) {
+		pr_info(PFX "debugfs create directory failed\n");
+		return;
+	}
+
+	skge_debug = ent;
+	register_netdevice_notifier(&skge_notifier);
+}
+
+static __exit void skge_debug_cleanup(void)
+{
+	if (skge_debug) {
+		unregister_netdevice_notifier(&skge_notifier);
+		debugfs_remove(skge_debug);
+		skge_debug = NULL;
+	}
+}
+
+#else
+#define skge_debug_init()
+#define skge_debug_cleanup()
+#endif
+
 /* Initialize network device */
 static struct net_device *skge_devinit(struct skge_hw *hw, int port,
 				       int highmem)
@@ -3904,12 +4181,14 @@ static struct pci_driver skge_driver = {
 
 static int __init skge_init_module(void)
 {
+	skge_debug_init();
 	return pci_register_driver(&skge_driver);
 }
 
 static void __exit skge_cleanup_module(void)
 {
 	pci_unregister_driver(&skge_driver);
+	skge_debug_cleanup();
 }
 
 module_init(skge_init_module);
diff --git a/drivers/net/skge.h b/drivers/net/skge.h
index 1a57bdd..17caccb 100644
--- a/drivers/net/skge.h
+++ b/drivers/net/skge.h
@@ -1,5 +1,5 @@
 /*
- * Definitions for the new Marvell Yukon / SysKonenct driver.
+ * Definitions for the new Marvell Yukon / SysKonnect driver.
  */
 #ifndef _SKGE_H
 #define _SKGE_H
@@ -8,8 +8,10 @@
 #define PCI_DEV_REG1	0x40
 #define  PCI_PHY_COMA	0x8000000
 #define  PCI_VIO	0x2000000
+
 #define PCI_DEV_REG2	0x44
-#define  PCI_REV_DESC	 0x4
+#define  PCI_VPD_ROM_SZ	7L<<14	/* VPD ROM size 0=256, 1=512, ... */
+#define  PCI_REV_DESC	1<<2	/* Reverse Descriptor bytes */
 
 #define PCI_STATUS_ERROR_BITS (PCI_STATUS_DETECTED_PARITY | \
 			       PCI_STATUS_SIG_SYSTEM_ERROR | \
@@ -2191,11 +2193,9 @@ enum {
 	XM_IS_TXF_UR	= 1<<2,	/* Bit  2:	Transmit FIFO Underrun */
 	XM_IS_TX_COMP	= 1<<1,	/* Bit  1:	Frame Tx Complete */
 	XM_IS_RX_COMP	= 1<<0,	/* Bit  0:	Frame Rx Complete */
-};
-
-#define XM_DEF_MSK	(~(XM_IS_INP_ASS | XM_IS_LIPA_RC | \
-			   XM_IS_RXF_OV | XM_IS_TXF_UR))
 
+	XM_IMSK_DISABLE	= 0xffff,
+};
 
 /*	XM_HW_CFG	16 bit r/w	Hardware Config Register */
 enum {
@@ -2469,8 +2469,9 @@ struct skge_port {
 	void		     *mem;	/* PCI memory for rings */
 	dma_addr_t	     dma;
 	unsigned long	     mem_size;
-
-	struct net_device_stats net_stats;
+#ifdef CONFIG_SKGE_DEBUG
+	struct dentry	     *debugfs;
+#endif
 };
 
 
diff --git a/drivers/net/tokenring/3c359.c b/drivers/net/tokenring/3c359.c
index 7224d36..5d31519 100644
--- a/drivers/net/tokenring/3c359.c
+++ b/drivers/net/tokenring/3c359.c
@@ -760,7 +760,7 @@ static int xl_open_hw(struct net_device *dev)
 	if (xl_priv->xl_laa[0]) {  /* If using a LAA address */
 		for (i=10;i<16;i++) { 
 			writel( (MEM_BYTE_WRITE | 0xD0000 | xl_priv->srb) + i, xl_mmio + MMIO_MAC_ACCESS_CMD) ; 
-			writeb(xl_priv->xl_laa[i],xl_mmio + MMIO_MACDATA) ; 
+			writeb(xl_priv->xl_laa[i-10],xl_mmio + MMIO_MACDATA) ;
 		}
 		memcpy(dev->dev_addr,xl_priv->xl_laa,dev->addr_len) ; 
 	} else { /* Regular hardware address */ 
