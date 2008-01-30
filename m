From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Wed, 30 Jan 2008 04:44:40 -0500
Message-ID: <20080130094440.GA4652@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:51955 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752594AbYA3Jom (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 04:44:42 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First pass through the queue that built up over the weekend (plus a few
others that just missed 2.6.24 release), with a focus specifically on
fixes.

Please pull from 'upstream-davem' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-davem

to receive the following updates:

 MAINTAINERS                     |    2 -
 drivers/net/Kconfig             |    9 ++--
 drivers/net/arm/at91_ether.c    |    2 +-
 drivers/net/bfin_mac.c          |  107 +++++++++++++++++++++++++--------------
 drivers/net/bfin_mac.h          |   31 ++----------
 drivers/net/bonding/bond_main.c |  106 ++++++++++++++++++++------------------
 drivers/net/bonding/bonding.h   |    4 +-
 drivers/net/cxgb3/mc5.c         |    2 +-
 drivers/net/cxgb3/sge.c         |    2 +-
 drivers/net/cxgb3/t3_hw.c       |   22 ++++----
 drivers/net/forcedeth.c         |   61 ++++++++++------------
 drivers/net/natsemi.c           |   18 +------
 drivers/net/pci-skeleton.c      |   49 +++++++++---------
 drivers/net/phy/Kconfig         |    5 ++
 drivers/net/phy/Makefile        |    1 +
 drivers/net/phy/mdio_bus.c      |    2 +-
 drivers/net/phy/phy.c           |   68 +++++++++++++++++--------
 drivers/net/phy/phy_device.c    |   11 ++--
 drivers/net/phy/realtek.c       |   80 +++++++++++++++++++++++++++++
 drivers/net/sis190.c            |    2 +-
 drivers/net/sky2.c              |   14 +++--
 include/linux/phy.h             |    5 +-
 22 files changed, 355 insertions(+), 248 deletions(-)
 create mode 100644 drivers/net/phy/realtek.c

Aidan Williams (1):
      EMAC driver: bf537 MAC multicast hash filtering patch

Alexey Demin (1):
      EMAC driver: fix bug - invalidate data cache of new_skb->data range when cache is WB

Andy Gospodarek (1):
      bonding: fix race that causes invalid statistics

Ayaz Abdulla (6):
      forcedeth: reset register fix
      forcedeth: checksum fix
      forcedeth: updated copyright section
      forcedeth: tx pause fix
      forcedeth: multicast fix
      forcedeth: mac address mcp77/79

Bryan Wu (3):
      EMAC driver: shorten the mdelay value to solve netperf performance issue
      EMAC driver: define MDC_CLK=2.5MHz and caculate mdc_div according to SCLK.
      EMAC driver: Fix bug: The clock divisor is set to all ones at reset.

Jay Vosburgh (6):
      bonding: fix parameter parsing
      bonding: fix set_multicast_list locking
      bonding: fix NULL pointer deref in startup processing
      bonding: do not acquire rtnl in ARP monitor
      bonding: update version
      bonding: update MAINTAINERS

Jeff Garzik (1):
      [netdrvr] sis190: build fix

Jike Song (1):
      pci-skeleton: Misc fixes to build neatly

Kim Phillips (1):
      phylib: Add Realtek 821x eth PHY support

Mark Brown (1):
      natsemi: Update locking documentation

Michael Hennerich (1):
      EMAC driver: ADSP-BF52x arch/mach support

Mike Frysinger (1):
      EMAC driver: use simpler comment headers and strip out information that is maintained in the scm's log

Nate Case (1):
      PHYLIB: Locking fixes for PHY I/O potentially sleeping

Roel Kluin (1):
      drivers/net/arm/at91_ether.c: logical/bitand typo in function reset_phy()

Roland Dreier (1):
      cxgb3: Remove incorrect __devinit annotations

Stephen Hemminger (2):
      sky2: restore multicast addresses after recovery
      sky2: fix Wake On Lan interaction with BIOS

Vitja Makarov (1):
      EMAC driver: add power down mode

diff --git a/MAINTAINERS b/MAINTAINERS
index 10011d9..77ad82a 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -939,8 +939,6 @@ M:	maxk@qualcomm.com
 S:	Maintained
 
 BONDING DRIVER
-P:	Chad Tindel
-M:	ctindel@users.sourceforge.net
 P:	Jay Vosburgh
 M:	fubar@us.ibm.com
 L:	bonding-devel@lists.sourceforge.net
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 5a2d1dd..ca2552b 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -814,8 +814,8 @@ config ULTRA32
 	  will be called smc-ultra32.
 
 config BFIN_MAC
-	tristate "Blackfin 536/537 on-chip mac support"
-	depends on NET_ETHERNET && (BF537 || BF536) && (!BF537_PORT_H)
+	tristate "Blackfin 527/536/537 on-chip mac support"
+	depends on NET_ETHERNET && (BF527 || BF537 || BF536) && (!BF537_PORT_H)
 	select CRC32
 	select MII
 	select PHYLIB
@@ -828,7 +828,7 @@ config BFIN_MAC
 
 config BFIN_MAC_USE_L1
 	bool "Use L1 memory for rx/tx packets"
-	depends on BFIN_MAC && BF537
+	depends on BFIN_MAC && (BF527 || BF537)
 	default y
 	help
 	  To get maximum network performance, you should use L1 memory as rx/tx buffers.
@@ -855,7 +855,8 @@ config BFIN_RX_DESC_NUM
 config BFIN_MAC_RMII
 	bool "RMII PHY Interface (EXPERIMENTAL)"
 	depends on BFIN_MAC && EXPERIMENTAL
-	default n
+	default y if BFIN527_EZKIT
+	default n if BFIN537_STAMP
 	help
 	  Use Reduced PHY MII Interface
 
diff --git a/drivers/net/arm/at91_ether.c b/drivers/net/arm/at91_ether.c
index 25b114a..0ae0d83 100644
--- a/drivers/net/arm/at91_ether.c
+++ b/drivers/net/arm/at91_ether.c
@@ -384,7 +384,7 @@ static void reset_phy(struct net_device *dev)
 	/* Wait until PHY reset is complete */
 	do {
 		read_phy(lp->phy_address, MII_BMCR, &bmcr);
-	} while (!(bmcr && BMCR_RESET));
+	} while (!(bmcr & BMCR_RESET));
 
 	disable_mdi();
 	spin_unlock_irq(&lp->lock);
diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index eb97175..c993a32 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -1,34 +1,11 @@
 /*
- * File:	drivers/net/bfin_mac.c
- * Based on:
- * Maintainer:
- * 		Bryan Wu <bryan.wu@analog.com>
+ * Blackfin On-Chip MAC Driver
  *
- * Original author:
- * 		Luke Yang <luke.yang@analog.com>
+ * Copyright 2004-2007 Analog Devices Inc.
  *
- * Created:
- * Description:
+ * Enter bugs at http://blackfin.uclinux.org/
  *
- * Modified:
- *		Copyright 2004-2006 Analog Devices Inc.
- *
- * Bugs:	Enter bugs at http://blackfin.uclinux.org/
- *
- * This program is free software ;  you can redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation ;  either version 2, or (at your option)
- * any later version.
- *
- * This program is distributed in the hope that it will be useful,
- * but WITHOUT ANY WARRANTY ;  without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- * GNU General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program ;  see the file COPYING.
- * If not, write to the Free Software Foundation,
- * 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
+ * Licensed under the GPL-2 or later.
  */
 
 #include <linux/init.h>
@@ -65,7 +42,7 @@
 #define DRV_NAME	"bfin_mac"
 #define DRV_VERSION	"1.1"
 #define DRV_AUTHOR	"Bryan Wu, Luke Yang"
-#define DRV_DESC	"Blackfin BF53[67] on-chip Ethernet MAC driver"
+#define DRV_DESC	"Blackfin BF53[67] BF527 on-chip Ethernet MAC driver"
 
 MODULE_AUTHOR(DRV_AUTHOR);
 MODULE_LICENSE("GPL");
@@ -296,7 +273,7 @@ static void mdio_poll(void)
 
 	/* poll the STABUSY bit */
 	while ((bfin_read_EMAC_STAADD()) & STABUSY) {
-		mdelay(10);
+		udelay(1);
 		if (timeout_cnt-- < 0) {
 			printk(KERN_ERR DRV_NAME
 			": wait MDC/MDIO transaction to complete timeout\n");
@@ -412,20 +389,26 @@ static void bf537_adjust_link(struct net_device *dev)
 	spin_unlock_irqrestore(&lp->lock, flags);
 }
 
+/* MDC  = 2.5 MHz */
+#define MDC_CLK 2500000
+
 static int mii_probe(struct net_device *dev)
 {
 	struct bf537mac_local *lp = netdev_priv(dev);
 	struct phy_device *phydev = NULL;
 	unsigned short sysctl;
 	int i;
+	u32 sclk, mdc_div;
 
 	/* Enable PHY output early */
 	if (!(bfin_read_VR_CTL() & PHYCLKOE))
 		bfin_write_VR_CTL(bfin_read_VR_CTL() | PHYCLKOE);
 
-	/* MDC  = 2.5 MHz */
+	sclk = get_sclk();
+	mdc_div = ((sclk / MDC_CLK) / 2) - 1;
+
 	sysctl = bfin_read_EMAC_SYSCTL();
-	sysctl |= SET_MDCDIV(24);
+	sysctl = (sysctl & ~MDCDIV) | SET_MDCDIV(mdc_div);
 	bfin_write_EMAC_SYSCTL(sysctl);
 
 	/* search for connect PHY device */
@@ -477,8 +460,10 @@ static int mii_probe(struct net_device *dev)
 	lp->phydev = phydev;
 
 	printk(KERN_INFO "%s: attached PHY driver [%s] "
-	       "(mii_bus:phy_addr=%s, irq=%d)\n",
-	       DRV_NAME, phydev->drv->name, phydev->dev.bus_id, phydev->irq);
+	       "(mii_bus:phy_addr=%s, irq=%d, mdc_clk=%dHz(mdc_div=%d)"
+	       "@sclk=%dMHz)\n",
+	       DRV_NAME, phydev->drv->name, phydev->dev.bus_id, phydev->irq,
+	       MDC_CLK, mdc_div, sclk/1000000);
 
 	return 0;
 }
@@ -551,7 +536,7 @@ static void adjust_tx_list(void)
 	 */
 	if (current_tx_ptr->next->next == tx_list_head) {
 		while (tx_list_head->status.status_word == 0) {
-			mdelay(10);
+			mdelay(1);
 			if (tx_list_head->status.status_word != 0
 			    || !(bfin_read_DMA2_IRQ_STATUS() & 0x08)) {
 				goto adjust_head;
@@ -666,6 +651,12 @@ static void bf537mac_rx(struct net_device *dev)
 	current_rx_ptr->skb = new_skb;
 	current_rx_ptr->desc_a.start_addr = (unsigned long)new_skb->data - 2;
 
+	/* Invidate the data cache of skb->data range when it is write back
+	 * cache. It will prevent overwritting the new data from DMA
+	 */
+	blackfin_dcache_invalidate_range((unsigned long)new_skb->head,
+					 (unsigned long)new_skb->end);
+
 	len = (unsigned short)((current_rx_ptr->status.status_word) & RX_FRLEN);
 	skb_put(skb, len);
 	blackfin_dcache_invalidate_range((unsigned long)skb->head,
@@ -767,7 +758,7 @@ static void bf537mac_enable(void)
 
 #if defined(CONFIG_BFIN_MAC_RMII)
 	opmode |= RMII; /* For Now only 100MBit are supported */
-#ifdef CONFIG_BF_REV_0_2
+#if (defined(CONFIG_BF537) || defined(CONFIG_BF536)) && CONFIG_BF_REV_0_2
 	opmode |= TE;
 #endif
 #endif
@@ -792,6 +783,39 @@ static void bf537mac_timeout(struct net_device *dev)
 	netif_wake_queue(dev);
 }
 
+static void bf537mac_multicast_hash(struct net_device *dev)
+{
+	u32 emac_hashhi, emac_hashlo;
+	struct dev_mc_list *dmi = dev->mc_list;
+	char *addrs;
+	int i;
+	u32 crc;
+
+	emac_hashhi = emac_hashlo = 0;
+
+	for (i = 0; i < dev->mc_count; i++) {
+		addrs = dmi->dmi_addr;
+		dmi = dmi->next;
+
+		/* skip non-multicast addresses */
+		if (!(*addrs & 1))
+			continue;
+
+		crc = ether_crc(ETH_ALEN, addrs);
+		crc >>= 26;
+
+		if (crc & 0x20)
+			emac_hashhi |= 1 << (crc & 0x1f);
+		else
+			emac_hashlo |= 1 << (crc & 0x1f);
+	}
+
+	bfin_write_EMAC_HASHHI(emac_hashhi);
+	bfin_write_EMAC_HASHLO(emac_hashlo);
+
+	return;
+}
+
 /*
  * This routine will, depending on the values passed to it,
  * either make it accept multicast packets, go into
@@ -807,11 +831,17 @@ static void bf537mac_set_multicast_list(struct net_device *dev)
 		sysctl = bfin_read_EMAC_OPMODE();
 		sysctl |= RAF;
 		bfin_write_EMAC_OPMODE(sysctl);
-	} else if (dev->flags & IFF_ALLMULTI || dev->mc_count) {
+	} else if (dev->flags & IFF_ALLMULTI) {
 		/* accept all multicast */
 		sysctl = bfin_read_EMAC_OPMODE();
 		sysctl |= PAM;
 		bfin_write_EMAC_OPMODE(sysctl);
+	} else if (dev->mc_count) {
+		/* set up multicast hash table */
+		sysctl = bfin_read_EMAC_OPMODE();
+		sysctl |= HM;
+		bfin_write_EMAC_OPMODE(sysctl);
+		bf537mac_multicast_hash(dev);
 	} else {
 		/* clear promisc or multicast mode */
 		sysctl = bfin_read_EMAC_OPMODE();
@@ -860,10 +890,10 @@ static int bf537mac_open(struct net_device *dev)
 		return retval;
 
 	phy_start(lp->phydev);
+	phy_write(lp->phydev, MII_BMCR, BMCR_RESET);
 	setup_system_regs(dev);
 	bf537mac_disable();
 	bf537mac_enable();
-
 	pr_debug("hardware init finished\n");
 	netif_start_queue(dev);
 	netif_carrier_on(dev);
@@ -886,6 +916,7 @@ static int bf537mac_close(struct net_device *dev)
 	netif_carrier_off(dev);
 
 	phy_stop(lp->phydev);
+	phy_write(lp->phydev, MII_BMCR, BMCR_PDOWN);
 
 	/* clear everything */
 	bf537mac_shutdown(dev);
@@ -970,7 +1001,7 @@ static int __init bf537mac_probe(struct net_device *dev)
 	/* register irq handler */
 	if (request_irq
 	    (IRQ_MAC_RX, bf537mac_interrupt, IRQF_DISABLED | IRQF_SHARED,
-	     "BFIN537_MAC_RX", dev)) {
+	     "EMAC_RX", dev)) {
 		printk(KERN_WARNING DRV_NAME
 		       ": Unable to attach BlackFin MAC RX interrupt\n");
 		return -EBUSY;
diff --git a/drivers/net/bfin_mac.h b/drivers/net/bfin_mac.h
index 5970ea7..f774d5a 100644
--- a/drivers/net/bfin_mac.h
+++ b/drivers/net/bfin_mac.h
@@ -1,34 +1,11 @@
 /*
- * File:	drivers/net/bfin_mac.c
- * Based on:
- * Maintainer:
- * 		Bryan Wu <bryan.wu@analog.com>
+ * Blackfin On-Chip MAC Driver
  *
- * Original author:
- * 		Luke Yang <luke.yang@analog.com>
+ * Copyright 2004-2007 Analog Devices Inc.
  *
- * Created:
- * Description:
+ * Enter bugs at http://blackfin.uclinux.org/
  *
- * Modified:
- *		Copyright 2004-2006 Analog Devices Inc.
- *
- * Bugs:	Enter bugs at http://blackfin.uclinux.org/
- *
- * This program is free software ;  you can redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation ;  either version 2, or (at your option)
- * any later version.
- *
- * This program is distributed in the hope that it will be useful,
- * but WITHOUT ANY WARRANTY ;  without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- * GNU General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program ;  see the file COPYING.
- * If not, write to the Free Software Foundation,
- * 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
+ * Licensed under the GPL-2 or later.
  */
 
 #define BFIN_MAC_CSUM_OFFLOAD
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 2039f78..0942d82 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1464,10 +1464,12 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 			dev_set_allmulti(slave_dev, 1);
 		}
 
+		netif_tx_lock_bh(bond_dev);
 		/* upload master's mc_list to new slave */
 		for (dmi = bond_dev->mc_list; dmi; dmi = dmi->next) {
 			dev_mc_add (slave_dev, dmi->dmi_addr, dmi->dmi_addrlen, 0);
 		}
+		netif_tx_unlock_bh(bond_dev);
 	}
 
 	if (bond->params.mode == BOND_MODE_8023AD) {
@@ -1821,7 +1823,9 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 		}
 
 		/* flush master's mc_list from slave */
+		netif_tx_lock_bh(bond_dev);
 		bond_mc_list_flush(bond_dev, slave_dev);
+		netif_tx_unlock_bh(bond_dev);
 	}
 
 	netdev_set_master(slave_dev, NULL);
@@ -1942,7 +1946,9 @@ static int bond_release_all(struct net_device *bond_dev)
 			}
 
 			/* flush master's mc_list from slave */
+			netif_tx_lock_bh(bond_dev);
 			bond_mc_list_flush(bond_dev, slave_dev);
+			netif_tx_unlock_bh(bond_dev);
 		}
 
 		netdev_set_master(slave_dev, NULL);
@@ -2795,14 +2801,11 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 	}
 
 	if (do_failover) {
-		rtnl_lock();
 		write_lock_bh(&bond->curr_slave_lock);
 
 		bond_select_active_slave(bond);
 
 		write_unlock_bh(&bond->curr_slave_lock);
-		rtnl_unlock();
-
 	}
 
 re_arm:
@@ -2859,8 +2862,6 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 
 				slave->link = BOND_LINK_UP;
 
-				rtnl_lock();
-
 				write_lock_bh(&bond->curr_slave_lock);
 
 				if ((!bond->curr_active_slave) &&
@@ -2896,7 +2897,6 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 				}
 
 				write_unlock_bh(&bond->curr_slave_lock);
-				rtnl_unlock();
 			}
 		} else {
 			read_lock(&bond->curr_slave_lock);
@@ -2966,7 +2966,6 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 			       bond->dev->name,
 			       slave->dev->name);
 
-			rtnl_lock();
 			write_lock_bh(&bond->curr_slave_lock);
 
 			bond_select_active_slave(bond);
@@ -2974,8 +2973,6 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 
 			write_unlock_bh(&bond->curr_slave_lock);
 
-			rtnl_unlock();
-
 			bond->current_arp_slave = slave;
 
 			if (slave) {
@@ -2993,13 +2990,10 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 			       bond->primary_slave->dev->name);
 
 			/* primary is up so switch to it */
-			rtnl_lock();
 			write_lock_bh(&bond->curr_slave_lock);
 			bond_change_active_slave(bond, bond->primary_slave);
 			write_unlock_bh(&bond->curr_slave_lock);
 
-			rtnl_unlock();
-
 			slave = bond->primary_slave;
 			slave->jiffies = jiffies;
 		} else {
@@ -3769,42 +3763,45 @@ static struct net_device_stats *bond_get_stats(struct net_device *bond_dev)
 {
 	struct bonding *bond = bond_dev->priv;
 	struct net_device_stats *stats = &(bond->stats), *sstats;
+	struct net_device_stats local_stats;
 	struct slave *slave;
 	int i;
 
-	memset(stats, 0, sizeof(struct net_device_stats));
+	memset(&local_stats, 0, sizeof(struct net_device_stats));
 
 	read_lock_bh(&bond->lock);
 
 	bond_for_each_slave(bond, slave, i) {
 		sstats = slave->dev->get_stats(slave->dev);
-		stats->rx_packets += sstats->rx_packets;
-		stats->rx_bytes += sstats->rx_bytes;
-		stats->rx_errors += sstats->rx_errors;
-		stats->rx_dropped += sstats->rx_dropped;
+		local_stats.rx_packets += sstats->rx_packets;
+		local_stats.rx_bytes += sstats->rx_bytes;
+		local_stats.rx_errors += sstats->rx_errors;
+		local_stats.rx_dropped += sstats->rx_dropped;
 
-		stats->tx_packets += sstats->tx_packets;
-		stats->tx_bytes += sstats->tx_bytes;
-		stats->tx_errors += sstats->tx_errors;
-		stats->tx_dropped += sstats->tx_dropped;
+		local_stats.tx_packets += sstats->tx_packets;
+		local_stats.tx_bytes += sstats->tx_bytes;
+		local_stats.tx_errors += sstats->tx_errors;
+		local_stats.tx_dropped += sstats->tx_dropped;
 
-		stats->multicast += sstats->multicast;
-		stats->collisions += sstats->collisions;
+		local_stats.multicast += sstats->multicast;
+		local_stats.collisions += sstats->collisions;
 
-		stats->rx_length_errors += sstats->rx_length_errors;
-		stats->rx_over_errors += sstats->rx_over_errors;
-		stats->rx_crc_errors += sstats->rx_crc_errors;
-		stats->rx_frame_errors += sstats->rx_frame_errors;
-		stats->rx_fifo_errors += sstats->rx_fifo_errors;
-		stats->rx_missed_errors += sstats->rx_missed_errors;
+		local_stats.rx_length_errors += sstats->rx_length_errors;
+		local_stats.rx_over_errors += sstats->rx_over_errors;
+		local_stats.rx_crc_errors += sstats->rx_crc_errors;
+		local_stats.rx_frame_errors += sstats->rx_frame_errors;
+		local_stats.rx_fifo_errors += sstats->rx_fifo_errors;
+		local_stats.rx_missed_errors += sstats->rx_missed_errors;
 
-		stats->tx_aborted_errors += sstats->tx_aborted_errors;
-		stats->tx_carrier_errors += sstats->tx_carrier_errors;
-		stats->tx_fifo_errors += sstats->tx_fifo_errors;
-		stats->tx_heartbeat_errors += sstats->tx_heartbeat_errors;
-		stats->tx_window_errors += sstats->tx_window_errors;
+		local_stats.tx_aborted_errors += sstats->tx_aborted_errors;
+		local_stats.tx_carrier_errors += sstats->tx_carrier_errors;
+		local_stats.tx_fifo_errors += sstats->tx_fifo_errors;
+		local_stats.tx_heartbeat_errors += sstats->tx_heartbeat_errors;
+		local_stats.tx_window_errors += sstats->tx_window_errors;
 	}
 
+	memcpy(stats, &local_stats, sizeof(struct net_device_stats));
+
 	read_unlock_bh(&bond->lock);
 
 	return stats;
@@ -3937,8 +3934,6 @@ static void bond_set_multicast_list(struct net_device *bond_dev)
 	struct bonding *bond = bond_dev->priv;
 	struct dev_mc_list *dmi;
 
-	write_lock_bh(&bond->lock);
-
 	/*
 	 * Do promisc before checking multicast_mode
 	 */
@@ -3959,6 +3954,8 @@ static void bond_set_multicast_list(struct net_device *bond_dev)
 		bond_set_allmulti(bond, -1);
 	}
 
+	read_lock(&bond->lock);
+
 	bond->flags = bond_dev->flags;
 
 	/* looking for addresses to add to slaves' mc list */
@@ -3979,7 +3976,7 @@ static void bond_set_multicast_list(struct net_device *bond_dev)
 	bond_mc_list_destroy(bond);
 	bond_mc_list_copy(bond_dev->mc_list, bond, GFP_ATOMIC);
 
-	write_unlock_bh(&bond->lock);
+	read_unlock(&bond->lock);
 }
 
 /*
@@ -4526,7 +4523,9 @@ static void bond_free_all(void)
 		struct net_device *bond_dev = bond->dev;
 
 		bond_work_cancel_all(bond);
+		netif_tx_lock_bh(bond_dev);
 		bond_mc_list_destroy(bond);
+		netif_tx_unlock_bh(bond_dev);
 		/* Release the bonded slaves */
 		bond_release_all(bond_dev);
 		bond_deinit(bond_dev);
@@ -4549,14 +4548,19 @@ static void bond_free_all(void)
 int bond_parse_parm(const char *buf, struct bond_parm_tbl *tbl)
 {
 	int mode = -1, i, rv;
-	char modestr[BOND_MAX_MODENAME_LEN + 1] = { 0, };
+	char *p, modestr[BOND_MAX_MODENAME_LEN + 1] = { 0, };
 
-	rv = sscanf(buf, "%d", &mode);
-	if (!rv) {
+	for (p = (char *)buf; *p; p++)
+		if (!(isdigit(*p) || isspace(*p)))
+			break;
+
+	if (*p)
 		rv = sscanf(buf, "%20s", modestr);
-		if (!rv)
-			return -1;
-	}
+	else
+		rv = sscanf(buf, "%d", &mode);
+
+	if (!rv)
+		return -1;
 
 	for (i = 0; tbl[i].modename; i++) {
 		if (mode == tbl[i].mode)
@@ -4883,14 +4887,16 @@ int bond_create(char *name, struct bond_params *params, struct bonding **newbond
 	down_write(&bonding_rwsem);
 
 	/* Check to see if the bond already exists. */
-	list_for_each_entry_safe(bond, nxt, &bond_dev_list, bond_list)
-		if (strnicmp(bond->dev->name, name, IFNAMSIZ) == 0) {
-			printk(KERN_ERR DRV_NAME
+	if (name) {
+		list_for_each_entry_safe(bond, nxt, &bond_dev_list, bond_list)
+			if (strnicmp(bond->dev->name, name, IFNAMSIZ) == 0) {
+				printk(KERN_ERR DRV_NAME
 			       ": cannot add bond %s; it already exists\n",
-			       name);
-			res = -EPERM;
-			goto out_rtnl;
-		}
+				       name);
+				res = -EPERM;
+				goto out_rtnl;
+			}
+	}
 
 	bond_dev = alloc_netdev(sizeof(struct bonding), name ? name : "",
 				ether_setup);
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 6d83be4..67ccad6 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -22,8 +22,8 @@
 #include "bond_3ad.h"
 #include "bond_alb.h"
 
-#define DRV_VERSION	"3.2.3"
-#define DRV_RELDATE	"December 6, 2007"
+#define DRV_VERSION	"3.2.4"
+#define DRV_RELDATE	"January 28, 2008"
 #define DRV_NAME	"bonding"
 #define DRV_DESCRIPTION	"Ethernet Channel Bonding Driver"
 
diff --git a/drivers/net/cxgb3/mc5.c b/drivers/net/cxgb3/mc5.c
index 84c1ffa..4c4d6e8 100644
--- a/drivers/net/cxgb3/mc5.c
+++ b/drivers/net/cxgb3/mc5.c
@@ -452,7 +452,7 @@ void t3_mc5_intr_handler(struct mc5 *mc5)
 	t3_write_reg(adap, A_MC5_DB_INT_CAUSE, cause);
 }
 
-void __devinit t3_mc5_prep(struct adapter *adapter, struct mc5 *mc5, int mode)
+void t3_mc5_prep(struct adapter *adapter, struct mc5 *mc5, int mode)
 {
 #define K * 1024
 
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index cb684d3..9ca8c66 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -2836,7 +2836,7 @@ void t3_sge_init(struct adapter *adap, struct sge_params *p)
  *	defaults for the assorted SGE parameters, which admins can change until
  *	they are used to initialize the SGE.
  */
-void __devinit t3_sge_prep(struct adapter *adap, struct sge_params *p)
+void t3_sge_prep(struct adapter *adap, struct sge_params *p)
 {
 	int i;
 
diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index 7469935..a99496a 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -2675,7 +2675,7 @@ void t3_tp_set_max_rxsize(struct adapter *adap, unsigned int size)
 		     V_PMMAXXFERLEN0(size) | V_PMMAXXFERLEN1(size));
 }
 
-static void __devinit init_mtus(unsigned short mtus[])
+static void init_mtus(unsigned short mtus[])
 {
 	/*
 	 * See draft-mathis-plpmtud-00.txt for the values.  The min is 88 so
@@ -2703,7 +2703,7 @@ static void __devinit init_mtus(unsigned short mtus[])
 /*
  * Initial congestion control parameters.
  */
-static void __devinit init_cong_ctrl(unsigned short *a, unsigned short *b)
+static void init_cong_ctrl(unsigned short *a, unsigned short *b)
 {
 	a[0] = a[1] = a[2] = a[3] = a[4] = a[5] = a[6] = a[7] = a[8] = 1;
 	a[9] = 2;
@@ -3354,8 +3354,7 @@ out_err:
  *	Determines a card's PCI mode and associated parameters, such as speed
  *	and width.
  */
-static void __devinit get_pci_mode(struct adapter *adapter,
-				   struct pci_params *p)
+static void get_pci_mode(struct adapter *adapter, struct pci_params *p)
 {
 	static unsigned short speed_map[] = { 33, 66, 100, 133 };
 	u32 pci_mode, pcie_cap;
@@ -3395,8 +3394,7 @@ static void __devinit get_pci_mode(struct adapter *adapter,
  *	capabilities and default speed/duplex/flow-control/autonegotiation
  *	settings.
  */
-static void __devinit init_link_config(struct link_config *lc,
-				       unsigned int caps)
+static void init_link_config(struct link_config *lc, unsigned int caps)
 {
 	lc->supported = caps;
 	lc->requested_speed = lc->speed = SPEED_INVALID;
@@ -3419,7 +3417,7 @@ static void __devinit init_link_config(struct link_config *lc,
  *	Calculates the size of an MC7 memory in bytes from the value of its
  *	configuration register.
  */
-static unsigned int __devinit mc7_calc_size(u32 cfg)
+static unsigned int mc7_calc_size(u32 cfg)
 {
 	unsigned int width = G_WIDTH(cfg);
 	unsigned int banks = !!(cfg & F_BKS) + 1;
@@ -3430,8 +3428,8 @@ static unsigned int __devinit mc7_calc_size(u32 cfg)
 	return MBs << 20;
 }
 
-static void __devinit mc7_prep(struct adapter *adapter, struct mc7 *mc7,
-			       unsigned int base_addr, const char *name)
+static void mc7_prep(struct adapter *adapter, struct mc7 *mc7,
+		     unsigned int base_addr, const char *name)
 {
 	u32 cfg;
 
@@ -3517,7 +3515,7 @@ static int t3_reset_adapter(struct adapter *adapter)
 	return 0;
 }
 
-static int __devinit init_parity(struct adapter *adap)
+static int init_parity(struct adapter *adap)
 {
 		int i, err, addr;
 
@@ -3552,8 +3550,8 @@ static int __devinit init_parity(struct adapter *adap)
  * for some adapter tunables, take PHYs out of reset, and initialize the MDIO
  * interface.
  */
-int __devinit t3_prep_adapter(struct adapter *adapter,
-			      const struct adapter_info *ai, int reset)
+int t3_prep_adapter(struct adapter *adapter, const struct adapter_info *ai,
+		    int reset)
 {
 	int ret;
 	unsigned int i, j = 0;
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 7667a62..3634223 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -13,7 +13,7 @@
  * Copyright (C) 2004 Andrew de Quincey (wol support)
  * Copyright (C) 2004 Carl-Daniel Hailfinger (invalid MAC handling, insane
  *		IRQ rate fixes, bigendian fixes, cleanups, verification)
- * Copyright (c) 2004,5,6 NVIDIA Corporation
+ * Copyright (c) 2004,2005,2006,2007,2008 NVIDIA Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -226,7 +226,7 @@ enum {
 #define NVREG_MISC1_HD		0x02
 #define NVREG_MISC1_FORCE	0x3b0f3c
 
-	NvRegMacReset = 0x3c,
+	NvRegMacReset = 0x34,
 #define NVREG_MAC_RESET_ASSERT	0x0F3
 	NvRegTransmitterControl = 0x084,
 #define NVREG_XMITCTL_START	0x01
@@ -277,7 +277,9 @@ enum {
 #define NVREG_MCASTADDRA_FORCE	0x01
 	NvRegMulticastAddrB = 0xB4,
 	NvRegMulticastMaskA = 0xB8,
+#define NVREG_MCASTMASKA_NONE		0xffffffff
 	NvRegMulticastMaskB = 0xBC,
+#define NVREG_MCASTMASKB_NONE		0xffff
 
 	NvRegPhyInterface = 0xC0,
 #define PHY_RGMII		0x10000000
@@ -316,8 +318,8 @@ enum {
 	NvRegTxRingPhysAddrHigh = 0x148,
 	NvRegRxRingPhysAddrHigh = 0x14C,
 	NvRegTxPauseFrame = 0x170,
-#define NVREG_TX_PAUSEFRAME_DISABLE	0x1ff0080
-#define NVREG_TX_PAUSEFRAME_ENABLE	0x0c00030
+#define NVREG_TX_PAUSEFRAME_DISABLE	0x01ff0080
+#define NVREG_TX_PAUSEFRAME_ENABLE	0x01800010
 	NvRegMIIStatus = 0x180,
 #define NVREG_MIISTAT_ERROR		0x0001
 #define NVREG_MIISTAT_LINKCHANGE	0x0008
@@ -471,9 +473,9 @@ union ring_type {
 #define NV_RX_AVAIL		(1<<31)
 
 #define NV_RX2_CHECKSUMMASK	(0x1C000000)
-#define NV_RX2_CHECKSUMOK1	(0x10000000)
-#define NV_RX2_CHECKSUMOK2	(0x14000000)
-#define NV_RX2_CHECKSUMOK3	(0x18000000)
+#define NV_RX2_CHECKSUM_IP	(0x10000000)
+#define NV_RX2_CHECKSUM_IP_TCP	(0x14000000)
+#define NV_RX2_CHECKSUM_IP_UDP	(0x18000000)
 #define NV_RX2_DESCRIPTORVALID	(1<<29)
 #define NV_RX2_SUBSTRACT1	(1<<25)
 #define NV_RX2_ERROR1		(1<<18)
@@ -2375,14 +2377,9 @@ static int nv_rx_process(struct net_device *dev, int limit)
 						goto next_pkt;
 					}
 				}
-				if ((flags & NV_RX2_CHECKSUMMASK) == NV_RX2_CHECKSUMOK2)/*ip and tcp */ {
+				if (((flags & NV_RX2_CHECKSUMMASK) == NV_RX2_CHECKSUM_IP_TCP) || /*ip and tcp */
+				    ((flags & NV_RX2_CHECKSUMMASK) == NV_RX2_CHECKSUM_IP_UDP))   /*ip and udp */
 					skb->ip_summed = CHECKSUM_UNNECESSARY;
-				} else {
-					if ((flags & NV_RX2_CHECKSUMMASK) == NV_RX2_CHECKSUMOK1 ||
-					    (flags & NV_RX2_CHECKSUMMASK) == NV_RX2_CHECKSUMOK3) {
-						skb->ip_summed = CHECKSUM_UNNECESSARY;
-					}
-				}
 			} else {
 				dev_kfree_skb(skb);
 				goto next_pkt;
@@ -2474,14 +2471,9 @@ static int nv_rx_process_optimized(struct net_device *dev, int limit)
 				}
 			}
 
-			if ((flags & NV_RX2_CHECKSUMMASK) == NV_RX2_CHECKSUMOK2)/*ip and tcp */ {
+			if (((flags & NV_RX2_CHECKSUMMASK) == NV_RX2_CHECKSUM_IP_TCP) || /*ip and tcp */
+			    ((flags & NV_RX2_CHECKSUMMASK) == NV_RX2_CHECKSUM_IP_UDP))   /*ip and udp */
 				skb->ip_summed = CHECKSUM_UNNECESSARY;
-			} else {
-				if ((flags & NV_RX2_CHECKSUMMASK) == NV_RX2_CHECKSUMOK1 ||
-				    (flags & NV_RX2_CHECKSUMMASK) == NV_RX2_CHECKSUMOK3) {
-					skb->ip_summed = CHECKSUM_UNNECESSARY;
-				}
-			}
 
 			/* got a valid packet - forward it to the network core */
 			skb_put(skb, len);
@@ -2703,6 +2695,9 @@ static void nv_set_multicast(struct net_device *dev)
 			addr[1] = alwaysOn[1];
 			mask[0] = alwaysOn[0] | alwaysOff[0];
 			mask[1] = alwaysOn[1] | alwaysOff[1];
+		} else {
+			mask[0] = NVREG_MCASTMASKA_NONE;
+			mask[1] = NVREG_MCASTMASKB_NONE;
 		}
 	}
 	addr[0] |= NVREG_MCASTADDRA_FORCE;
@@ -4813,8 +4808,8 @@ static int nv_open(struct net_device *dev)
 		nv_mac_reset(dev);
 	writel(NVREG_MCASTADDRA_FORCE, base + NvRegMulticastAddrA);
 	writel(0, base + NvRegMulticastAddrB);
-	writel(0, base + NvRegMulticastMaskA);
-	writel(0, base + NvRegMulticastMaskB);
+	writel(NVREG_MCASTMASKA_NONE, base + NvRegMulticastMaskA);
+	writel(NVREG_MCASTMASKB_NONE, base + NvRegMulticastMaskB);
 	writel(0, base + NvRegPacketFilterFlags);
 
 	writel(0, base + NvRegTransmitterControl);
@@ -4908,8 +4903,8 @@ static int nv_open(struct net_device *dev)
 	spin_lock_irq(&np->lock);
 	writel(NVREG_MCASTADDRA_FORCE, base + NvRegMulticastAddrA);
 	writel(0, base + NvRegMulticastAddrB);
-	writel(0, base + NvRegMulticastMaskA);
-	writel(0, base + NvRegMulticastMaskB);
+	writel(NVREG_MCASTMASKA_NONE, base + NvRegMulticastMaskA);
+	writel(NVREG_MCASTMASKB_NONE, base + NvRegMulticastMaskB);
 	writel(NVREG_PFF_ALWAYS|NVREG_PFF_MYADDR, base + NvRegPacketFilterFlags);
 	/* One manual link speed update: Interrupts are enabled, future link
 	 * speed changes cause interrupts and are handled by nv_link_irq().
@@ -5603,35 +5598,35 @@ static struct pci_device_id pci_tbl[] = {
 	},
 	{	/* MCP77 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_32),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
 	},
 	{	/* MCP77 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_33),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
 	},
 	{	/* MCP77 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_34),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
 	},
 	{	/* MCP77 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_35),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
 	},
 	{	/* MCP79 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_36),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
 	},
 	{	/* MCP79 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_37),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
 	},
 	{	/* MCP79 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_38),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
 	},
 	{	/* MCP79 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_39),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
 	},
 	{0,},
 };
diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index c329a4f..0a3e604 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -203,22 +203,8 @@ skbuff at an offset of "+2", 16-byte aligning the IP header.
 IIId. Synchronization
 
 Most operations are synchronized on the np->lock irq spinlock, except the
-performance critical codepaths:
-
-The rx process only runs in the interrupt handler. Access from outside
-the interrupt handler is only permitted after disable_irq().
-
-The rx process usually runs under the netif_tx_lock. If np->intr_tx_reap
-is set, then access is permitted under spin_lock_irq(&np->lock).
-
-Thus configuration functions that want to access everything must call
-	disable_irq(dev->irq);
-	netif_tx_lock_bh(dev);
-	spin_lock_irq(&np->lock);
-
-IV. Notes
-
-NatSemi PCI network controllers are very uncommon.
+recieve and transmit paths which are synchronised using a combination of
+hardware descriptor ownership, disabling interrupts and NAPI poll scheduling.
 
 IVb. References
 
diff --git a/drivers/net/pci-skeleton.c b/drivers/net/pci-skeleton.c
index ed402e0..fffc49b 100644
--- a/drivers/net/pci-skeleton.c
+++ b/drivers/net/pci-skeleton.c
@@ -541,7 +541,7 @@ static void netdrv_hw_start (struct net_device *dev);
 #define NETDRV_W32_F(reg, val32)	do { writel ((val32), ioaddr + (reg)); readl (ioaddr + (reg)); } while (0)
 
 
-#if MMIO_FLUSH_AUDIT_COMPLETE
+#ifdef MMIO_FLUSH_AUDIT_COMPLETE
 
 /* write MMIO register */
 #define NETDRV_W8(reg, val8)	writeb ((val8), ioaddr + (reg))
@@ -603,7 +603,7 @@ static int __devinit netdrv_init_board (struct pci_dev *pdev,
 		return -ENOMEM;
 	}
 	SET_NETDEV_DEV(dev, &pdev->dev);
-	tp = dev->priv;
+	tp = netdev_priv(dev);
 
 	/* enable device (incl. PCI PM wakeup), and bus-mastering */
 	rc = pci_enable_device (pdev);
@@ -759,7 +759,7 @@ static int __devinit netdrv_init_one (struct pci_dev *pdev,
 		return i;
 	}
 
-	tp = dev->priv;
+	tp = netdev_priv(dev);
 
 	assert (ioaddr != NULL);
 	assert (dev != NULL);
@@ -783,7 +783,7 @@ static int __devinit netdrv_init_one (struct pci_dev *pdev,
 	dev->base_addr = (unsigned long) ioaddr;
 
 	/* dev->priv/tp zeroed and aligned in alloc_etherdev */
-	tp = dev->priv;
+	tp = netdev_priv(dev);
 
 	/* note: tp->chipset set in netdrv_init_board */
 	tp->drv_flags = PCI_COMMAND_IO | PCI_COMMAND_MEMORY |
@@ -841,7 +841,7 @@ static void __devexit netdrv_remove_one (struct pci_dev *pdev)
 
 	assert (dev != NULL);
 
-	np = dev->priv;
+	np = netdev_priv(dev);
 	assert (np != NULL);
 
 	unregister_netdev (dev);
@@ -974,7 +974,7 @@ static void mdio_sync (void *mdio_addr)
 
 static int mdio_read (struct net_device *dev, int phy_id, int location)
 {
-	struct netdrv_private *tp = dev->priv;
+	struct netdrv_private *tp = netdev_priv(dev);
 	void *mdio_addr = tp->mmio_addr + Config4;
 	int mii_cmd = (0xf6 << 10) | (phy_id << 5) | location;
 	int retval = 0;
@@ -1017,7 +1017,7 @@ static int mdio_read (struct net_device *dev, int phy_id, int location)
 static void mdio_write (struct net_device *dev, int phy_id, int location,
 			int value)
 {
-	struct netdrv_private *tp = dev->priv;
+	struct netdrv_private *tp = netdev_priv(dev);
 	void *mdio_addr = tp->mmio_addr + Config4;
 	int mii_cmd =
 	    (0x5002 << 16) | (phy_id << 23) | (location << 18) | value;
@@ -1060,7 +1060,7 @@ static void mdio_write (struct net_device *dev, int phy_id, int location,
 
 static int netdrv_open (struct net_device *dev)
 {
-	struct netdrv_private *tp = dev->priv;
+	struct netdrv_private *tp = netdev_priv(dev);
 	int retval;
 #ifdef NETDRV_DEBUG
 	void *ioaddr = tp->mmio_addr;
@@ -1121,7 +1121,7 @@ static int netdrv_open (struct net_device *dev)
 /* Start the hardware at open or resume. */
 static void netdrv_hw_start (struct net_device *dev)
 {
-	struct netdrv_private *tp = dev->priv;
+	struct netdrv_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	u32 i;
 
@@ -1191,7 +1191,7 @@ static void netdrv_hw_start (struct net_device *dev)
 /* Initialize the Rx and Tx rings, along with various 'dev' bits. */
 static void netdrv_init_ring (struct net_device *dev)
 {
-	struct netdrv_private *tp = dev->priv;
+	struct netdrv_private *tp = netdev_priv(dev);
 	int i;
 
 	DPRINTK ("ENTER\n");
@@ -1213,7 +1213,7 @@ static void netdrv_init_ring (struct net_device *dev)
 static void netdrv_timer (unsigned long data)
 {
 	struct net_device *dev = (struct net_device *) data;
-	struct netdrv_private *tp = dev->priv;
+	struct netdrv_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	int next_tick = 60 * HZ;
 	int mii_lpa;
@@ -1252,9 +1252,10 @@ static void netdrv_timer (unsigned long data)
 }
 
 
-static void netdrv_tx_clear (struct netdrv_private *tp)
+static void netdrv_tx_clear (struct net_device *dev)
 {
 	int i;
+	struct netdrv_private *tp = netdev_priv(dev);
 
 	atomic_set (&tp->cur_tx, 0);
 	atomic_set (&tp->dirty_tx, 0);
@@ -1278,7 +1279,7 @@ static void netdrv_tx_clear (struct netdrv_private *tp)
 
 static void netdrv_tx_timeout (struct net_device *dev)
 {
-	struct netdrv_private *tp = dev->priv;
+	struct netdrv_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	int i;
 	u8 tmp8;
@@ -1311,7 +1312,7 @@ static void netdrv_tx_timeout (struct net_device *dev)
 	/* Stop a shared interrupt from scavenging while we are. */
 	spin_lock_irqsave (&tp->lock, flags);
 
-	netdrv_tx_clear (tp);
+	netdrv_tx_clear (dev);
 
 	spin_unlock_irqrestore (&tp->lock, flags);
 
@@ -1325,7 +1326,7 @@ static void netdrv_tx_timeout (struct net_device *dev)
 
 static int netdrv_start_xmit (struct sk_buff *skb, struct net_device *dev)
 {
-	struct netdrv_private *tp = dev->priv;
+	struct netdrv_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	int entry;
 
@@ -1525,7 +1526,7 @@ static void netdrv_rx_interrupt (struct net_device *dev,
 		DPRINTK ("%s:  netdrv_rx() status %4.4x, size %4.4x,"
 			 " cur %4.4x.\n", dev->name, rx_status,
 			 rx_size, cur_rx);
-#if NETDRV_DEBUG > 2
+#if defined(NETDRV_DEBUG) && (NETDRV_DEBUG > 2)
 		{
 			int i;
 			DPRINTK ("%s: Frame contents ", dev->name);
@@ -1648,7 +1649,7 @@ static void netdrv_weird_interrupt (struct net_device *dev,
 static irqreturn_t netdrv_interrupt (int irq, void *dev_instance)
 {
 	struct net_device *dev = (struct net_device *) dev_instance;
-	struct netdrv_private *tp = dev->priv;
+	struct netdrv_private *tp = netdev_priv(dev);
 	int boguscnt = max_interrupt_work;
 	void *ioaddr = tp->mmio_addr;
 	int status = 0, link_changed = 0; /* avoid bogus "uninit" warning */
@@ -1711,7 +1712,7 @@ static irqreturn_t netdrv_interrupt (int irq, void *dev_instance)
 
 static int netdrv_close (struct net_device *dev)
 {
-	struct netdrv_private *tp = dev->priv;
+	struct netdrv_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	unsigned long flags;
 
@@ -1738,10 +1739,10 @@ static int netdrv_close (struct net_device *dev)
 
 	spin_unlock_irqrestore (&tp->lock, flags);
 
-	synchronize_irq ();
+	synchronize_irq (dev->irq);
 	free_irq (dev->irq, dev);
 
-	netdrv_tx_clear (tp);
+	netdrv_tx_clear (dev);
 
 	pci_free_consistent(tp->pci_dev, RX_BUF_TOT_LEN,
 			    tp->rx_ring, tp->rx_ring_dma);
@@ -1762,7 +1763,7 @@ static int netdrv_close (struct net_device *dev)
 
 static int netdrv_ioctl (struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct netdrv_private *tp = dev->priv;
+	struct netdrv_private *tp = netdev_priv(dev);
 	struct mii_ioctl_data *data = if_mii(rq);
 	unsigned long flags;
 	int rc = 0;
@@ -1805,7 +1806,7 @@ static int netdrv_ioctl (struct net_device *dev, struct ifreq *rq, int cmd)
 
 static void netdrv_set_rx_mode (struct net_device *dev)
 {
-	struct netdrv_private *tp = dev->priv;
+	struct netdrv_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	u32 mc_filter[2];	/* Multicast hash filter */
 	int i, rx_mode;
@@ -1862,7 +1863,7 @@ static void netdrv_set_rx_mode (struct net_device *dev)
 static int netdrv_suspend (struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *dev = pci_get_drvdata (pdev);
-	struct netdrv_private *tp = dev->priv;
+	struct netdrv_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	unsigned long flags;
 
@@ -1892,7 +1893,7 @@ static int netdrv_suspend (struct pci_dev *pdev, pm_message_t state)
 static int netdrv_resume (struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata (pdev);
-	struct netdrv_private *tp = dev->priv;
+	/*struct netdrv_private *tp = netdev_priv(dev);*/
 
 	if (!netif_running(dev))
 		return 0;
diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 54b2ba9..e4594bc 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -60,6 +60,11 @@ config ICPLUS_PHY
 	---help---
 	  Currently supports the IP175C PHY.
 
+config REALTEK_PHY
+	tristate "Drivers for Realtek PHYs"
+	---help---
+	  Supports the Realtek 821x PHY.
+
 config FIXED_PHY
 	tristate "Drivers for PHY emulation on fixed speed/link"
 	---help---
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index 3d6cc7b..5997d6e 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -12,5 +12,6 @@ obj-$(CONFIG_SMSC_PHY)		+= smsc.o
 obj-$(CONFIG_VITESSE_PHY)	+= vitesse.o
 obj-$(CONFIG_BROADCOM_PHY)	+= broadcom.o
 obj-$(CONFIG_ICPLUS_PHY)	+= icplus.o
+obj-$(CONFIG_REALTEK_PHY)	+= realtek.o
 obj-$(CONFIG_FIXED_PHY)		+= fixed.o
 obj-$(CONFIG_MDIO_BITBANG)	+= mdio-bitbang.o
diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index c30196d..6e9f619 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -49,7 +49,7 @@ int mdiobus_register(struct mii_bus *bus)
 	int i;
 	int err = 0;
 
-	spin_lock_init(&bus->mdio_lock);
+	mutex_init(&bus->mdio_lock);
 
 	if (NULL == bus || NULL == bus->name ||
 			NULL == bus->read ||
diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 7c9e6e3..12fccb1 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -26,7 +26,6 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
-#include <linux/spinlock.h>
 #include <linux/mm.h>
 #include <linux/module.h>
 #include <linux/mii.h>
@@ -72,9 +71,11 @@ int phy_read(struct phy_device *phydev, u16 regnum)
 	int retval;
 	struct mii_bus *bus = phydev->bus;
 
-	spin_lock_bh(&bus->mdio_lock);
+	BUG_ON(in_interrupt());
+
+	mutex_lock(&bus->mdio_lock);
 	retval = bus->read(bus, phydev->addr, regnum);
-	spin_unlock_bh(&bus->mdio_lock);
+	mutex_unlock(&bus->mdio_lock);
 
 	return retval;
 }
@@ -95,9 +96,11 @@ int phy_write(struct phy_device *phydev, u16 regnum, u16 val)
 	int err;
 	struct mii_bus *bus = phydev->bus;
 
-	spin_lock_bh(&bus->mdio_lock);
+	BUG_ON(in_interrupt());
+
+	mutex_lock(&bus->mdio_lock);
 	err = bus->write(bus, phydev->addr, regnum, val);
-	spin_unlock_bh(&bus->mdio_lock);
+	mutex_unlock(&bus->mdio_lock);
 
 	return err;
 }
@@ -428,7 +431,7 @@ int phy_start_aneg(struct phy_device *phydev)
 {
 	int err;
 
-	spin_lock_bh(&phydev->lock);
+	mutex_lock(&phydev->lock);
 
 	if (AUTONEG_DISABLE == phydev->autoneg)
 		phy_sanitize_settings(phydev);
@@ -449,13 +452,14 @@ int phy_start_aneg(struct phy_device *phydev)
 	}
 
 out_unlock:
-	spin_unlock_bh(&phydev->lock);
+	mutex_unlock(&phydev->lock);
 	return err;
 }
 EXPORT_SYMBOL(phy_start_aneg);
 
 
 static void phy_change(struct work_struct *work);
+static void phy_state_machine(struct work_struct *work);
 static void phy_timer(unsigned long data);
 
 /**
@@ -476,6 +480,7 @@ void phy_start_machine(struct phy_device *phydev,
 {
 	phydev->adjust_state = handler;
 
+	INIT_WORK(&phydev->state_queue, phy_state_machine);
 	init_timer(&phydev->phy_timer);
 	phydev->phy_timer.function = &phy_timer;
 	phydev->phy_timer.data = (unsigned long) phydev;
@@ -493,11 +498,12 @@ void phy_start_machine(struct phy_device *phydev,
 void phy_stop_machine(struct phy_device *phydev)
 {
 	del_timer_sync(&phydev->phy_timer);
+	cancel_work_sync(&phydev->state_queue);
 
-	spin_lock_bh(&phydev->lock);
+	mutex_lock(&phydev->lock);
 	if (phydev->state > PHY_UP)
 		phydev->state = PHY_UP;
-	spin_unlock_bh(&phydev->lock);
+	mutex_unlock(&phydev->lock);
 
 	phydev->adjust_state = NULL;
 }
@@ -541,9 +547,9 @@ static void phy_force_reduction(struct phy_device *phydev)
  */
 void phy_error(struct phy_device *phydev)
 {
-	spin_lock_bh(&phydev->lock);
+	mutex_lock(&phydev->lock);
 	phydev->state = PHY_HALTED;
-	spin_unlock_bh(&phydev->lock);
+	mutex_unlock(&phydev->lock);
 }
 
 /**
@@ -705,10 +711,10 @@ static void phy_change(struct work_struct *work)
 	if (err)
 		goto phy_err;
 
-	spin_lock_bh(&phydev->lock);
+	mutex_lock(&phydev->lock);
 	if ((PHY_RUNNING == phydev->state) || (PHY_NOLINK == phydev->state))
 		phydev->state = PHY_CHANGELINK;
-	spin_unlock_bh(&phydev->lock);
+	mutex_unlock(&phydev->lock);
 
 	atomic_dec(&phydev->irq_disable);
 	enable_irq(phydev->irq);
@@ -735,7 +741,7 @@ phy_err:
  */
 void phy_stop(struct phy_device *phydev)
 {
-	spin_lock_bh(&phydev->lock);
+	mutex_lock(&phydev->lock);
 
 	if (PHY_HALTED == phydev->state)
 		goto out_unlock;
@@ -751,7 +757,7 @@ void phy_stop(struct phy_device *phydev)
 	phydev->state = PHY_HALTED;
 
 out_unlock:
-	spin_unlock_bh(&phydev->lock);
+	mutex_unlock(&phydev->lock);
 
 	/*
 	 * Cannot call flush_scheduled_work() here as desired because
@@ -773,7 +779,7 @@ out_unlock:
  */
 void phy_start(struct phy_device *phydev)
 {
-	spin_lock_bh(&phydev->lock);
+	mutex_lock(&phydev->lock);
 
 	switch (phydev->state) {
 		case PHY_STARTING:
@@ -787,19 +793,26 @@ void phy_start(struct phy_device *phydev)
 		default:
 			break;
 	}
-	spin_unlock_bh(&phydev->lock);
+	mutex_unlock(&phydev->lock);
 }
 EXPORT_SYMBOL(phy_stop);
 EXPORT_SYMBOL(phy_start);
 
-/* PHY timer which handles the state machine */
-static void phy_timer(unsigned long data)
+/**
+ * phy_state_machine - Handle the state machine
+ * @work: work_struct that describes the work to be done
+ *
+ * Description: Scheduled by the state_queue workqueue each time
+ *   phy_timer is triggered.
+ */
+static void phy_state_machine(struct work_struct *work)
 {
-	struct phy_device *phydev = (struct phy_device *)data;
+	struct phy_device *phydev =
+			container_of(work, struct phy_device, state_queue);
 	int needs_aneg = 0;
 	int err = 0;
 
-	spin_lock_bh(&phydev->lock);
+	mutex_lock(&phydev->lock);
 
 	if (phydev->adjust_state)
 		phydev->adjust_state(phydev->attached_dev);
@@ -965,7 +978,7 @@ static void phy_timer(unsigned long data)
 			break;
 	}
 
-	spin_unlock_bh(&phydev->lock);
+	mutex_unlock(&phydev->lock);
 
 	if (needs_aneg)
 		err = phy_start_aneg(phydev);
@@ -976,3 +989,14 @@ static void phy_timer(unsigned long data)
 	mod_timer(&phydev->phy_timer, jiffies + PHY_STATE_TIME * HZ);
 }
 
+/* PHY timer which schedules the state machine work */
+static void phy_timer(unsigned long data)
+{
+	struct phy_device *phydev = (struct phy_device *)data;
+
+	/*
+	 * PHY I/O operations can potentially sleep so we ensure that
+	 * it's done from a process context
+	 */
+	schedule_work(&phydev->state_queue);
+}
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 5b9e175..f4c4fd8 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -25,7 +25,6 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
-#include <linux/spinlock.h>
 #include <linux/mm.h>
 #include <linux/module.h>
 #include <linux/mii.h>
@@ -80,7 +79,7 @@ struct phy_device* phy_device_create(struct mii_bus *bus, int addr, int phy_id)
 
 	dev->state = PHY_DOWN;
 
-	spin_lock_init(&dev->lock);
+	mutex_init(&dev->lock);
 
 	return dev;
 }
@@ -656,7 +655,7 @@ static int phy_probe(struct device *dev)
 	if (!(phydrv->flags & PHY_HAS_INTERRUPT))
 		phydev->irq = PHY_POLL;
 
-	spin_lock_bh(&phydev->lock);
+	mutex_lock(&phydev->lock);
 
 	/* Start out supporting everything. Eventually,
 	 * a controller will attach, and may modify one
@@ -670,7 +669,7 @@ static int phy_probe(struct device *dev)
 	if (phydev->drv->probe)
 		err = phydev->drv->probe(phydev);
 
-	spin_unlock_bh(&phydev->lock);
+	mutex_unlock(&phydev->lock);
 
 	return err;
 
@@ -682,9 +681,9 @@ static int phy_remove(struct device *dev)
 
 	phydev = to_phy_device(dev);
 
-	spin_lock_bh(&phydev->lock);
+	mutex_lock(&phydev->lock);
 	phydev->state = PHY_DOWN;
-	spin_unlock_bh(&phydev->lock);
+	mutex_unlock(&phydev->lock);
 
 	if (phydev->drv->remove)
 		phydev->drv->remove(phydev);
diff --git a/drivers/net/phy/realtek.c b/drivers/net/phy/realtek.c
new file mode 100644
index 0000000..a052a67
--- /dev/null
+++ b/drivers/net/phy/realtek.c
@@ -0,0 +1,80 @@
+/*
+ * drivers/net/phy/realtek.c
+ *
+ * Driver for Realtek PHYs
+ *
+ * Author: Johnson Leung <r58129@freescale.com>
+ *
+ * Copyright (c) 2004 Freescale Semiconductor, Inc.
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ */
+#include <linux/phy.h>
+
+#define RTL821x_PHYSR		0x11
+#define RTL821x_PHYSR_DUPLEX	0x2000
+#define RTL821x_PHYSR_SPEED	0xc000
+#define RTL821x_INER		0x12
+#define RTL821x_INER_INIT	0x6400
+#define RTL821x_INSR		0x13
+
+MODULE_DESCRIPTION("Realtek PHY driver");
+MODULE_AUTHOR("Johnson Leung");
+MODULE_LICENSE("GPL");
+
+static int rtl821x_ack_interrupt(struct phy_device *phydev)
+{
+	int err;
+
+	err = phy_read(phydev, RTL821x_INSR);
+
+	return (err < 0) ? err : 0;
+}
+
+static int rtl821x_config_intr(struct phy_device *phydev)
+{
+	int err;
+
+	if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
+		err = phy_write(phydev, RTL821x_INER,
+				RTL821x_INER_INIT);
+	else
+		err = phy_write(phydev, RTL821x_INER, 0);
+
+	return err;
+}
+
+/* RTL8211B */
+static struct phy_driver rtl821x_driver = {
+	.phy_id		= 0x001cc912,
+	.name		= "RTL821x Gigabit Ethernet",
+	.phy_id_mask	= 0x001fffff,
+	.features	= PHY_GBIT_FEATURES,
+	.flags		= PHY_HAS_INTERRUPT,
+	.config_aneg	= &genphy_config_aneg,
+	.read_status	= &genphy_read_status,
+	.ack_interrupt	= &rtl821x_ack_interrupt,
+	.config_intr	= &rtl821x_config_intr,
+	.driver		= { .owner = THIS_MODULE,},
+};
+
+static int __init realtek_init(void)
+{
+	int ret;
+
+	ret = phy_driver_register(&rtl821x_driver);
+
+	return ret;
+}
+
+static void __exit realtek_exit(void)
+{
+	phy_driver_unregister(&rtl821x_driver);
+}
+
+module_init(realtek_init);
+module_exit(realtek_exit);
diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index b570402..2e9e88b 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -326,7 +326,7 @@ static const struct {
 	{ "SiS 191 PCI Gigabit Ethernet adapter" },
 };
 
-static struct pci_device_id sis190_pci_tbl[] __devinitdata = {
+static struct pci_device_id sis190_pci_tbl[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_SI, 0x0190), 0, 0, 0 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_SI, 0x0191), 0, 0, 1 },
 	{ 0, },
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 626190e..dc06236 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -623,6 +623,7 @@ static void sky2_phy_power(struct sky2_hw *hw, unsigned port, int onoff)
 	static const u32 phy_power[] = { PCI_Y2_PHY1_POWD, PCI_Y2_PHY2_POWD };
 	static const u32 coma_mode[] = { PCI_Y2_PHY1_COMA, PCI_Y2_PHY2_COMA };
 
+	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
 	reg1 = sky2_pci_read32(hw, PCI_DEV_REG1);
 	/* Turn on/off phy power saving */
 	if (onoff)
@@ -634,7 +635,8 @@ static void sky2_phy_power(struct sky2_hw *hw, unsigned port, int onoff)
 		reg1 |= coma_mode[port];
 
 	sky2_pci_write32(hw, PCI_DEV_REG1, reg1);
-	reg1 = sky2_pci_read32(hw, PCI_DEV_REG1);
+	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
+	sky2_pci_read32(hw, PCI_DEV_REG1);
 
 	udelay(100);
 }
@@ -1422,6 +1424,7 @@ static int sky2_up(struct net_device *dev)
 	imask |= portirq_msk[port];
 	sky2_write32(hw, B0_IMSK, imask);
 
+	sky2_set_multicast(dev);
 	return 0;
 
 err_out:
@@ -2436,6 +2439,7 @@ static void sky2_hw_intr(struct sky2_hw *hw)
 	if (status & (Y2_IS_MST_ERR | Y2_IS_IRQ_STAT)) {
 		u16 pci_err;
 
+		sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
 		pci_err = sky2_pci_read16(hw, PCI_STATUS);
 		if (net_ratelimit())
 			dev_err(&pdev->dev, "PCI hardware error (0x%x)\n",
@@ -2443,12 +2447,14 @@ static void sky2_hw_intr(struct sky2_hw *hw)
 
 		sky2_pci_write16(hw, PCI_STATUS,
 				      pci_err | PCI_STATUS_ERROR_BITS);
+		sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
 	}
 
 	if (status & Y2_IS_PCI_EXP) {
 		/* PCI-Express uncorrectable Error occurred */
 		u32 err;
 
+		sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
 		err = sky2_read32(hw, Y2_CFG_AER + PCI_ERR_UNCOR_STATUS);
 		sky2_write32(hw, Y2_CFG_AER + PCI_ERR_UNCOR_STATUS,
 			     0xfffffffful);
@@ -2456,6 +2462,7 @@ static void sky2_hw_intr(struct sky2_hw *hw)
 			dev_err(&pdev->dev, "PCI Express error (0x%x)\n", err);
 
 		sky2_read32(hw, Y2_CFG_AER + PCI_ERR_UNCOR_STATUS);
+		sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
 	}
 
 	if (status & Y2_HWE_L1_MASK)
@@ -2831,6 +2838,7 @@ static void sky2_reset(struct sky2_hw *hw)
 	}
 
 	sky2_power_on(hw);
+	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
 
 	for (i = 0; i < hw->ports; i++) {
 		sky2_write8(hw, SK_REG(i, GMAC_LINK_CTRL), GMLC_RST_SET);
@@ -3554,8 +3562,6 @@ static int sky2_set_ringparam(struct net_device *dev,
 		err = sky2_up(dev);
 		if (err)
 			dev_close(dev);
-		else
-			sky2_set_multicast(dev);
 	}
 
 	return err;
@@ -4389,8 +4395,6 @@ static int sky2_resume(struct pci_dev *pdev)
 				dev_close(dev);
 				goto out;
 			}
-
-			sky2_set_multicast(dev);
 		}
 	}
 
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 554836e..5e43ae7 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -88,7 +88,7 @@ struct mii_bus {
 
 	/* A lock to ensure that only one thing can read/write
 	 * the MDIO bus at a time */
-	spinlock_t mdio_lock;
+	struct mutex mdio_lock;
 
 	struct device *dev;
 
@@ -284,10 +284,11 @@ struct phy_device {
 
 	/* Interrupt and Polling infrastructure */
 	struct work_struct phy_queue;
+	struct work_struct state_queue;
 	struct timer_list phy_timer;
 	atomic_t irq_disable;
 
-	spinlock_t lock;
+	struct mutex lock;
 
 	struct net_device *attached_dev;
 
