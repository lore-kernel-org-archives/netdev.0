From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver updates
Date: Tue, 6 May 2008 12:42:57 -0400
Message-ID: <20080506164257.GA18393@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:53576 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761940AbYEFQm7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2008 12:42:59 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


various fixes, two cleanups (pcnet32, 3c59x)

Please pull from 'upstream-davem' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-davem

to receive the following updates:

 arch/arm/mach-orion5x/common.c            |    2 +
 arch/powerpc/platforms/chrp/pegasos_eth.c |    4 +
 arch/powerpc/sysdev/mv64x60_dev.c         |    2 +
 arch/ppc/syslib/mv64x60.c                 |    3 +
 drivers/net/3c59x.c                       |   73 +++----
 drivers/net/Kconfig                       |   14 --
 drivers/net/appletalk/cops.c              |   16 +-
 drivers/net/bonding/bond_main.c           |   24 ++-
 drivers/net/bonding/bond_sysfs.c          |   16 +-
 drivers/net/cxgb3/cxgb3_main.c            |    4 +-
 drivers/net/e1000e/defines.h              |   10 +
 drivers/net/e1000e/e1000.h                |    7 +-
 drivers/net/e1000e/ethtool.c              |   45 +++-
 drivers/net/e1000e/hw.h                   |   22 ++
 drivers/net/e1000e/ich8lan.c              |   83 +++++++-
 drivers/net/e1000e/netdev.c               |  330 ++++++++++++++++++++++++++++-
 drivers/net/e1000e/phy.c                  |  278 ++++++++++++++++++++++++
 drivers/net/eexpress.c                    |   11 +-
 drivers/net/fs_enet/mii-fec.c             |    3 +-
 drivers/net/gianfar.c                     |    5 +-
 drivers/net/gianfar.h                     |    3 +
 drivers/net/gianfar_sysfs.c               |   10 +-
 drivers/net/mv643xx_eth.c                 |  160 +++++++++++----
 drivers/net/pcnet32.c                     |   61 +-----
 drivers/net/phy/phy.c                     |    2 +-
 drivers/net/tulip/uli526x.c               |   38 ++--
 drivers/net/ucc_geth.c                    |  278 +++++++++++++------------
 drivers/net/ucc_geth.h                    |   48 +++--
 drivers/net/ucc_geth_ethtool.c            |    6 -
 drivers/net/ucc_geth_mii.c                |    4 +-
 include/linux/mv643xx_eth.h               |   16 ++-
 include/linux/phy.h                       |    5 +
 32 files changed, 1193 insertions(+), 390 deletions(-)

Alan Cox (1):
      cxgb3: Use CAP_SYS_RAWIO for firmware

Andy Fleming (3):
      gianfar: Fix a locking bug in gianfar's sysfs code
      phylib: Fix some sparse warnings
      ucc_geth: Fix a bunch of sparse warnings

Anton Vorontsov (2):
      uli526x: initialize the hardware prior to requesting interrupts
      uli526x: fix endianness issues in the setup frame

Bruce Allan (1):
      e1000e: Add support for BM PHYs on ICH9

Bruce Robson (1):
      [netdrvr] eexpress: IPv6 fails - multicast problems

Don Fry (1):
      pcnet32: delete non NAPI code from driver.

Gunnar Larisch (1):
      3c980-TX needs EXTRA_PREAMBLE

Jay Vosburgh (2):
      bonding: fix error unwind in bonding_store_bonds
      bonding: fix enslavement error unwinds

Jeff Garzik (1):
      fix warning in drivers/net/appletalk/cops.c

Joakim Tjernlund (1):
      ucc_geth: Don't use RX clock as TX clock.

Kok, Auke (1):
      e1000e: don't return half-read eeprom on error

Lennert Buytenhek (5):
      mv643xx_eth: get rid of static variables, allow multiple instances
      mv643xx_eth: mbus decode window support
      mv643xx_eth: configurable t_clk
      mv643xx_eth: shorten shared platform driver name
      mv643xx_eth: inter-mv643xx SMI port sharing

Paulius Zaleckas (1):
      3c59x: use netstats in net_device structure

Pavel Emelyanov (2):
      bonding: Do not call free_netdev for already registered device.
      bonding: Deadlock between bonding_store_bonds and bond_destroy_sysfs.

Scott Wood (1):
      fs_enet: Fix a memory leak in fs_enet_mdio_probe

diff --git a/arch/arm/mach-orion5x/common.c b/arch/arm/mach-orion5x/common.c
index 968deb5..0ecff5a 100644
--- a/arch/arm/mach-orion5x/common.c
+++ b/arch/arm/mach-orion5x/common.c
@@ -223,7 +223,9 @@ static struct platform_device orion5x_eth = {
 
 void __init orion5x_eth_init(struct mv643xx_eth_platform_data *eth_data)
 {
+	eth_data->shared = &orion5x_eth_shared;
 	orion5x_eth.dev.platform_data = eth_data;
+
 	platform_device_register(&orion5x_eth_shared);
 	platform_device_register(&orion5x_eth);
 }
diff --git a/arch/powerpc/platforms/chrp/pegasos_eth.c b/arch/powerpc/platforms/chrp/pegasos_eth.c
index 5bcc58d..130ff72 100644
--- a/arch/powerpc/platforms/chrp/pegasos_eth.c
+++ b/arch/powerpc/platforms/chrp/pegasos_eth.c
@@ -58,7 +58,9 @@ static struct resource mv643xx_eth0_resources[] = {
 
 
 static struct mv643xx_eth_platform_data eth0_pd = {
+	.shared		= &mv643xx_eth_shared_device,
 	.port_number	= 0,
+
 	.tx_sram_addr = PEGASOS2_SRAM_BASE_ETH0,
 	.tx_sram_size = PEGASOS2_SRAM_TXRING_SIZE,
 	.tx_queue_size = PEGASOS2_SRAM_TXRING_SIZE/16,
@@ -88,7 +90,9 @@ static struct resource mv643xx_eth1_resources[] = {
 };
 
 static struct mv643xx_eth_platform_data eth1_pd = {
+	.shared		= &mv643xx_eth_shared_device,
 	.port_number	= 1,
+
 	.tx_sram_addr = PEGASOS2_SRAM_BASE_ETH1,
 	.tx_sram_size = PEGASOS2_SRAM_TXRING_SIZE,
 	.tx_queue_size = PEGASOS2_SRAM_TXRING_SIZE/16,
diff --git a/arch/powerpc/sysdev/mv64x60_dev.c b/arch/powerpc/sysdev/mv64x60_dev.c
index 41af122..a132e0d 100644
--- a/arch/powerpc/sysdev/mv64x60_dev.c
+++ b/arch/powerpc/sysdev/mv64x60_dev.c
@@ -239,6 +239,8 @@ static int __init mv64x60_eth_device_setup(struct device_node *np, int id,
 
 	memset(&pdata, 0, sizeof(pdata));
 
+	pdata.shared = shared_pdev;
+
 	prop = of_get_property(np, "reg", NULL);
 	if (!prop)
 		return -ENODEV;
diff --git a/arch/ppc/syslib/mv64x60.c b/arch/ppc/syslib/mv64x60.c
index 90fe904..418f305 100644
--- a/arch/ppc/syslib/mv64x60.c
+++ b/arch/ppc/syslib/mv64x60.c
@@ -341,6 +341,7 @@ static struct resource mv64x60_eth0_resources[] = {
 };
 
 static struct mv643xx_eth_platform_data eth0_pd = {
+	.shared		= &mv64x60_eth_shared_device;
 	.port_number	= 0,
 };
 
@@ -366,6 +367,7 @@ static struct resource mv64x60_eth1_resources[] = {
 };
 
 static struct mv643xx_eth_platform_data eth1_pd = {
+	.shared		= &mv64x60_eth_shared_device;
 	.port_number	= 1,
 };
 
@@ -391,6 +393,7 @@ static struct resource mv64x60_eth2_resources[] = {
 };
 
 static struct mv643xx_eth_platform_data eth2_pd = {
+	.shared		= &mv64x60_eth_shared_device;
 	.port_number	= 2,
 };
 
diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index 6f8e7d4..2edda8c 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -319,7 +319,7 @@ static struct vortex_chip_info {
 	{"3c920B-EMB-WNM (ATI Radeon 9100 IGP)",
 	 PCI_USES_MASTER, IS_TORNADO|HAS_MII|HAS_HWCKSM, 128, },
 	{"3c980 Cyclone",
-	 PCI_USES_MASTER, IS_CYCLONE|HAS_HWCKSM, 128, },
+	 PCI_USES_MASTER, IS_CYCLONE|HAS_HWCKSM|EXTRA_PREAMBLE, 128, },
 
 	{"3c980C Python-T",
 	 PCI_USES_MASTER, IS_CYCLONE|HAS_NWAY|HAS_HWCKSM, 128, },
@@ -600,7 +600,6 @@ struct vortex_private {
 	struct sk_buff* tx_skbuff[TX_RING_SIZE];
 	unsigned int cur_rx, cur_tx;		/* The next free ring entry */
 	unsigned int dirty_rx, dirty_tx;	/* The ring entries to be free()ed. */
-	struct net_device_stats stats;		/* Generic stats */
 	struct vortex_extra_stats xstats;	/* NIC-specific extra stats */
 	struct sk_buff *tx_skb;				/* Packet being eaten by bus master ctrl.  */
 	dma_addr_t tx_skb_dma;				/* Allocated DMA address for bus master ctrl DMA.   */
@@ -1875,7 +1874,7 @@ static void vortex_tx_timeout(struct net_device *dev)
 
 	issue_and_wait(dev, TxReset);
 
-	vp->stats.tx_errors++;
+	dev->stats.tx_errors++;
 	if (vp->full_bus_master_tx) {
 		printk(KERN_DEBUG "%s: Resetting the Tx ring pointer.\n", dev->name);
 		if (vp->cur_tx - vp->dirty_tx > 0  &&  ioread32(ioaddr + DownListPtr) == 0)
@@ -1887,7 +1886,7 @@ static void vortex_tx_timeout(struct net_device *dev)
 			iowrite8(PKT_BUF_SZ>>8, ioaddr + TxFreeThreshold);
 		iowrite16(DownUnstall, ioaddr + EL3_CMD);
 	} else {
-		vp->stats.tx_dropped++;
+		dev->stats.tx_dropped++;
 		netif_wake_queue(dev);
 	}
 
@@ -1928,8 +1927,8 @@ vortex_error(struct net_device *dev, int status)
 			}
 			dump_tx_ring(dev);
 		}
-		if (tx_status & 0x14)  vp->stats.tx_fifo_errors++;
-		if (tx_status & 0x38)  vp->stats.tx_aborted_errors++;
+		if (tx_status & 0x14)  dev->stats.tx_fifo_errors++;
+		if (tx_status & 0x38)  dev->stats.tx_aborted_errors++;
 		if (tx_status & 0x08)  vp->xstats.tx_max_collisions++;
 		iowrite8(0, ioaddr + TxStatus);
 		if (tx_status & 0x30) {			/* txJabber or txUnderrun */
@@ -2051,8 +2050,8 @@ vortex_start_xmit(struct sk_buff *skb, struct net_device *dev)
 				if (vortex_debug > 2)
 				  printk(KERN_DEBUG "%s: Tx error, status %2.2x.\n",
 						 dev->name, tx_status);
-				if (tx_status & 0x04) vp->stats.tx_fifo_errors++;
-				if (tx_status & 0x38) vp->stats.tx_aborted_errors++;
+				if (tx_status & 0x04) dev->stats.tx_fifo_errors++;
+				if (tx_status & 0x38) dev->stats.tx_aborted_errors++;
 				if (tx_status & 0x30) {
 					issue_and_wait(dev, TxReset);
 				}
@@ -2350,7 +2349,7 @@ boomerang_interrupt(int irq, void *dev_id)
 				} else {
 					printk(KERN_DEBUG "boomerang_interrupt: no skb!\n");
 				}
-				/* vp->stats.tx_packets++;  Counted below. */
+				/* dev->stats.tx_packets++;  Counted below. */
 				dirty_tx++;
 			}
 			vp->dirty_tx = dirty_tx;
@@ -2409,12 +2408,12 @@ static int vortex_rx(struct net_device *dev)
 			unsigned char rx_error = ioread8(ioaddr + RxErrors);
 			if (vortex_debug > 2)
 				printk(KERN_DEBUG " Rx error: status %2.2x.\n", rx_error);
-			vp->stats.rx_errors++;
-			if (rx_error & 0x01)  vp->stats.rx_over_errors++;
-			if (rx_error & 0x02)  vp->stats.rx_length_errors++;
-			if (rx_error & 0x04)  vp->stats.rx_frame_errors++;
-			if (rx_error & 0x08)  vp->stats.rx_crc_errors++;
-			if (rx_error & 0x10)  vp->stats.rx_length_errors++;
+			dev->stats.rx_errors++;
+			if (rx_error & 0x01)  dev->stats.rx_over_errors++;
+			if (rx_error & 0x02)  dev->stats.rx_length_errors++;
+			if (rx_error & 0x04)  dev->stats.rx_frame_errors++;
+			if (rx_error & 0x08)  dev->stats.rx_crc_errors++;
+			if (rx_error & 0x10)  dev->stats.rx_length_errors++;
 		} else {
 			/* The packet length: up to 4.5K!. */
 			int pkt_len = rx_status & 0x1fff;
@@ -2446,7 +2445,7 @@ static int vortex_rx(struct net_device *dev)
 				skb->protocol = eth_type_trans(skb, dev);
 				netif_rx(skb);
 				dev->last_rx = jiffies;
-				vp->stats.rx_packets++;
+				dev->stats.rx_packets++;
 				/* Wait a limited time to go to next packet. */
 				for (i = 200; i >= 0; i--)
 					if ( ! (ioread16(ioaddr + EL3_STATUS) & CmdInProgress))
@@ -2455,7 +2454,7 @@ static int vortex_rx(struct net_device *dev)
 			} else if (vortex_debug > 0)
 				printk(KERN_NOTICE "%s: No memory to allocate a sk_buff of "
 					   "size %d.\n", dev->name, pkt_len);
-			vp->stats.rx_dropped++;
+			dev->stats.rx_dropped++;
 		}
 		issue_and_wait(dev, RxDiscard);
 	}
@@ -2482,12 +2481,12 @@ boomerang_rx(struct net_device *dev)
 			unsigned char rx_error = rx_status >> 16;
 			if (vortex_debug > 2)
 				printk(KERN_DEBUG " Rx error: status %2.2x.\n", rx_error);
-			vp->stats.rx_errors++;
-			if (rx_error & 0x01)  vp->stats.rx_over_errors++;
-			if (rx_error & 0x02)  vp->stats.rx_length_errors++;
-			if (rx_error & 0x04)  vp->stats.rx_frame_errors++;
-			if (rx_error & 0x08)  vp->stats.rx_crc_errors++;
-			if (rx_error & 0x10)  vp->stats.rx_length_errors++;
+			dev->stats.rx_errors++;
+			if (rx_error & 0x01)  dev->stats.rx_over_errors++;
+			if (rx_error & 0x02)  dev->stats.rx_length_errors++;
+			if (rx_error & 0x04)  dev->stats.rx_frame_errors++;
+			if (rx_error & 0x08)  dev->stats.rx_crc_errors++;
+			if (rx_error & 0x10)  dev->stats.rx_length_errors++;
 		} else {
 			/* The packet length: up to 4.5K!. */
 			int pkt_len = rx_status & 0x1fff;
@@ -2529,7 +2528,7 @@ boomerang_rx(struct net_device *dev)
 			}
 			netif_rx(skb);
 			dev->last_rx = jiffies;
-			vp->stats.rx_packets++;
+			dev->stats.rx_packets++;
 		}
 		entry = (++vp->cur_rx) % RX_RING_SIZE;
 	}
@@ -2591,7 +2590,7 @@ vortex_down(struct net_device *dev, int final_down)
 	del_timer_sync(&vp->rx_oom_timer);
 	del_timer_sync(&vp->timer);
 
-	/* Turn off statistics ASAP.  We update vp->stats below. */
+	/* Turn off statistics ASAP.  We update dev->stats below. */
 	iowrite16(StatsDisable, ioaddr + EL3_CMD);
 
 	/* Disable the receiver and transmitter. */
@@ -2728,7 +2727,7 @@ static struct net_device_stats *vortex_get_stats(struct net_device *dev)
 		update_stats(ioaddr, dev);
 		spin_unlock_irqrestore (&vp->lock, flags);
 	}
-	return &vp->stats;
+	return &dev->stats;
 }
 
 /*  Update statistics.
@@ -2748,18 +2747,18 @@ static void update_stats(void __iomem *ioaddr, struct net_device *dev)
 	/* Unlike the 3c5x9 we need not turn off stats updates while reading. */
 	/* Switch to the stats window, and read everything. */
 	EL3WINDOW(6);
-	vp->stats.tx_carrier_errors		+= ioread8(ioaddr + 0);
-	vp->stats.tx_heartbeat_errors		+= ioread8(ioaddr + 1);
-	vp->stats.tx_window_errors		+= ioread8(ioaddr + 4);
-	vp->stats.rx_fifo_errors		+= ioread8(ioaddr + 5);
-	vp->stats.tx_packets			+= ioread8(ioaddr + 6);
-	vp->stats.tx_packets			+= (ioread8(ioaddr + 9)&0x30) << 4;
+	dev->stats.tx_carrier_errors		+= ioread8(ioaddr + 0);
+	dev->stats.tx_heartbeat_errors		+= ioread8(ioaddr + 1);
+	dev->stats.tx_window_errors		+= ioread8(ioaddr + 4);
+	dev->stats.rx_fifo_errors		+= ioread8(ioaddr + 5);
+	dev->stats.tx_packets			+= ioread8(ioaddr + 6);
+	dev->stats.tx_packets			+= (ioread8(ioaddr + 9)&0x30) << 4;
 	/* Rx packets	*/			ioread8(ioaddr + 7);   /* Must read to clear */
 	/* Don't bother with register 9, an extension of registers 6&7.
 	   If we do use the 6&7 values the atomic update assumption above
 	   is invalid. */
-	vp->stats.rx_bytes 			+= ioread16(ioaddr + 10);
-	vp->stats.tx_bytes 			+= ioread16(ioaddr + 12);
+	dev->stats.rx_bytes 			+= ioread16(ioaddr + 10);
+	dev->stats.tx_bytes 			+= ioread16(ioaddr + 12);
 	/* Extra stats for get_ethtool_stats() */
 	vp->xstats.tx_multiple_collisions	+= ioread8(ioaddr + 2);
 	vp->xstats.tx_single_collisions         += ioread8(ioaddr + 3);
@@ -2767,14 +2766,14 @@ static void update_stats(void __iomem *ioaddr, struct net_device *dev)
 	EL3WINDOW(4);
 	vp->xstats.rx_bad_ssd			+= ioread8(ioaddr + 12);
 
-	vp->stats.collisions = vp->xstats.tx_multiple_collisions
+	dev->stats.collisions = vp->xstats.tx_multiple_collisions
 		+ vp->xstats.tx_single_collisions
 		+ vp->xstats.tx_max_collisions;
 
 	{
 		u8 up = ioread8(ioaddr + 13);
-		vp->stats.rx_bytes += (up & 0x0f) << 16;
-		vp->stats.tx_bytes += (up & 0xf0) << 12;
+		dev->stats.rx_bytes += (up & 0x0f) << 16;
+		dev->stats.tx_bytes += (up & 0xf0) << 12;
 	}
 
 	EL3WINDOW(old_window >> 13);
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index af46341..d27f54a 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1273,20 +1273,6 @@ config PCNET32
 	  To compile this driver as a module, choose M here. The module
 	  will be called pcnet32.
 
-config PCNET32_NAPI
-	bool "Use RX polling (NAPI)"
-	depends on PCNET32
-	help
-	  NAPI is a new driver API designed to reduce CPU and interrupt load
-	  when the driver is receiving lots of packets from the card. It is
-	  still somewhat experimental and thus not yet enabled by default.
-
-	  If your estimated Rx load is 10kpps or more, or if the card will be
-	  deployed on potentially unfriendly networks (e.g. in a firewall),
-	  then say Y here.
-
-	  If in doubt, say N.
-
 config AMD8111_ETH
 	tristate "AMD 8111 (new PCI lance) support"
 	depends on NET_PCI && PCI
diff --git a/drivers/net/appletalk/cops.c b/drivers/net/appletalk/cops.c
index 82e9a5b..a0b4c85 100644
--- a/drivers/net/appletalk/cops.c
+++ b/drivers/net/appletalk/cops.c
@@ -499,19 +499,13 @@ static void cops_reset(struct net_device *dev, int sleep)
         {
                 outb(0, ioaddr+DAYNA_RESET);	/* Assert the reset port */
                 inb(ioaddr+DAYNA_RESET);	/* Clear the reset */
-                if(sleep)
-                {
-                        long snap=jiffies;
-
-			/* Let card finish initializing, about 1/3 second */
-			while (time_before(jiffies, snap + HZ/3))
-                                schedule();
-                }
-                else
-                        mdelay(333);
+		if (sleep)
+			msleep(333);
+		else
+			mdelay(333);
         }
+
 	netif_wake_queue(dev);
-	return;
 }
 
 static void cops_load (struct net_device *dev)
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 6425603..50a40e4 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1425,13 +1425,13 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	res = netdev_set_master(slave_dev, bond_dev);
 	if (res) {
 		dprintk("Error %d calling netdev_set_master\n", res);
-		goto err_close;
+		goto err_restore_mac;
 	}
 	/* open the slave since the application closed it */
 	res = dev_open(slave_dev);
 	if (res) {
 		dprintk("Openning slave %s failed\n", slave_dev->name);
-		goto err_restore_mac;
+		goto err_unset_master;
 	}
 
 	new_slave->dev = slave_dev;
@@ -1444,7 +1444,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		 */
 		res = bond_alb_init_slave(bond, new_slave);
 		if (res) {
-			goto err_unset_master;
+			goto err_close;
 		}
 	}
 
@@ -1619,7 +1619,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 
 	res = bond_create_slave_symlinks(bond_dev, slave_dev);
 	if (res)
-		goto err_unset_master;
+		goto err_close;
 
 	printk(KERN_INFO DRV_NAME
 	       ": %s: enslaving %s as a%s interface with a%s link.\n",
@@ -1631,12 +1631,12 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	return 0;
 
 /* Undo stages on error */
-err_unset_master:
-	netdev_set_master(slave_dev, NULL);
-
 err_close:
 	dev_close(slave_dev);
 
+err_unset_master:
+	netdev_set_master(slave_dev, NULL);
+
 err_restore_mac:
 	if (!bond->params.fail_over_mac) {
 		memcpy(addr.sa_data, new_slave->perm_hwaddr, ETH_ALEN);
@@ -4936,7 +4936,9 @@ int bond_create(char *name, struct bond_params *params, struct bonding **newbond
 	if (res < 0) {
 		rtnl_lock();
 		down_write(&bonding_rwsem);
-		goto out_bond;
+		bond_deinit(bond_dev);
+		unregister_netdevice(bond_dev);
+		goto out_rtnl;
 	}
 
 	return 0;
@@ -4990,9 +4992,10 @@ err:
 		destroy_workqueue(bond->wq);
 	}
 
+	bond_destroy_sysfs();
+
 	rtnl_lock();
 	bond_free_all();
-	bond_destroy_sysfs();
 	rtnl_unlock();
 out:
 	return res;
@@ -5004,9 +5007,10 @@ static void __exit bonding_exit(void)
 	unregister_netdevice_notifier(&bond_netdev_notifier);
 	unregister_inetaddr_notifier(&bond_inetaddr_notifier);
 
+	bond_destroy_sysfs();
+
 	rtnl_lock();
 	bond_free_all();
-	bond_destroy_sysfs();
 	rtnl_unlock();
 }
 
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 979c2d0..68c41a0 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -146,29 +146,29 @@ static ssize_t bonding_store_bonds(struct class *cls, const char *buffer, size_t
 						": Unable remove bond %s due to open references.\n",
 						ifname);
 					res = -EPERM;
-					goto out;
+					goto out_unlock;
 				}
 				printk(KERN_INFO DRV_NAME
 					": %s is being deleted...\n",
 					bond->dev->name);
 				bond_destroy(bond);
-				up_write(&bonding_rwsem);
-				rtnl_unlock();
-				goto out;
+				goto out_unlock;
 			}
 
 		printk(KERN_ERR DRV_NAME
 			": unable to delete non-existent bond %s\n", ifname);
 		res = -ENODEV;
-		up_write(&bonding_rwsem);
-		rtnl_unlock();
-		goto out;
+		goto out_unlock;
 	}
 
 err_no_cmd:
 	printk(KERN_ERR DRV_NAME
 		": no command found in bonding_masters. Use +ifname or -ifname.\n");
-	res = -EPERM;
+	return -EPERM;
+
+out_unlock:
+	up_write(&bonding_rwsem);
+	rtnl_unlock();
 
 	/* Always return either count or an error.  If you return 0, you'll
 	 * get called forever, which is bad.
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 05e5f59..ce949d5 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -1894,11 +1894,11 @@ static int cxgb_extension_ioctl(struct net_device *dev, void __user *useraddr)
 		u8 *fw_data;
 		struct ch_mem_range t;
 
-		if (!capable(CAP_NET_ADMIN))
+		if (!capable(CAP_SYS_RAWIO))
 			return -EPERM;
 		if (copy_from_user(&t, useraddr, sizeof(t)))
 			return -EFAULT;
-
+		/* Check t.len sanity ? */
 		fw_data = kmalloc(t.len, GFP_KERNEL);
 		if (!fw_data)
 			return -ENOMEM;
diff --git a/drivers/net/e1000e/defines.h b/drivers/net/e1000e/defines.h
index 2a53875..f823b8b 100644
--- a/drivers/net/e1000e/defines.h
+++ b/drivers/net/e1000e/defines.h
@@ -648,6 +648,8 @@
 #define IFE_E_PHY_ID         0x02A80330
 #define IFE_PLUS_E_PHY_ID    0x02A80320
 #define IFE_C_E_PHY_ID       0x02A80310
+#define BME1000_E_PHY_ID     0x01410CB0
+#define BME1000_E_PHY_ID_R2  0x01410CB1
 
 /* M88E1000 Specific Registers */
 #define M88E1000_PHY_SPEC_CTRL     0x10  /* PHY Specific Control Register */
@@ -701,6 +703,14 @@
 #define M88EC018_EPSCR_DOWNSHIFT_COUNTER_MASK  0x0E00
 #define M88EC018_EPSCR_DOWNSHIFT_COUNTER_5X    0x0800
 
+/* BME1000 PHY Specific Control Register */
+#define BME1000_PSCR_ENABLE_DOWNSHIFT   0x0800 /* 1 = enable downshift */
+
+
+#define PHY_PAGE_SHIFT 5
+#define PHY_REG(page, reg) (((page) << PHY_PAGE_SHIFT) | \
+                           ((reg) & MAX_PHY_REG_ADDRESS))
+
 /*
  * Bits...
  * 15-5: page
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 38bfd0d..d3bc6f8 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -127,7 +127,7 @@ struct e1000_buffer {
 		/* arrays of page information for packet split */
 		struct e1000_ps_page *ps_pages;
 	};
-
+	struct page *page;
 };
 
 struct e1000_ring {
@@ -304,6 +304,7 @@ struct e1000_info {
 #define FLAG_HAS_CTRLEXT_ON_LOAD          (1 << 5)
 #define FLAG_HAS_SWSM_ON_LOAD             (1 << 6)
 #define FLAG_HAS_JUMBO_FRAMES             (1 << 7)
+#define FLAG_IS_ICH                       (1 << 9)
 #define FLAG_HAS_SMART_POWER_DOWN         (1 << 11)
 #define FLAG_IS_QUAD_PORT_A               (1 << 12)
 #define FLAG_IS_QUAD_PORT                 (1 << 13)
@@ -386,6 +387,7 @@ extern void e1000e_set_kmrn_lock_loss_workaround_ich8lan(struct e1000_hw *hw,
 						 bool state);
 extern void e1000e_igp3_phy_powerdown_workaround_ich8lan(struct e1000_hw *hw);
 extern void e1000e_gig_downshift_workaround_ich8lan(struct e1000_hw *hw);
+extern void e1000e_disable_gig_wol_ich8lan(struct e1000_hw *hw);
 
 extern s32 e1000e_check_for_copper_link(struct e1000_hw *hw);
 extern s32 e1000e_check_for_fiber_link(struct e1000_hw *hw);
@@ -443,6 +445,9 @@ extern s32 e1000e_get_phy_info_m88(struct e1000_hw *hw);
 extern s32 e1000e_read_phy_reg_m88(struct e1000_hw *hw, u32 offset, u16 *data);
 extern s32 e1000e_write_phy_reg_m88(struct e1000_hw *hw, u32 offset, u16 data);
 extern enum e1000_phy_type e1000e_get_phy_type_from_id(u32 phy_id);
+extern s32 e1000e_determine_phy_address(struct e1000_hw *hw);
+extern s32 e1000e_write_phy_reg_bm(struct e1000_hw *hw, u32 offset, u16 data);
+extern s32 e1000e_read_phy_reg_bm(struct e1000_hw *hw, u32 offset, u16 *data);
 extern void e1000e_phy_force_speed_duplex_setup(struct e1000_hw *hw, u16 *phy_ctrl);
 extern s32 e1000e_write_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 data);
 extern s32 e1000e_read_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 *data);
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index ce045ac..a14561f 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -494,8 +494,12 @@ static int e1000_get_eeprom(struct net_device *netdev,
 		for (i = 0; i < last_word - first_word + 1; i++) {
 			ret_val = e1000_read_nvm(hw, first_word + i, 1,
 						      &eeprom_buff[i]);
-			if (ret_val)
+			if (ret_val) {
+				/* a read error occurred, throw away the
+				 * result */
+				memset(eeprom_buff, 0xff, sizeof(eeprom_buff));
 				break;
+			}
 		}
 	}
 
@@ -803,8 +807,7 @@ static int e1000_reg_test(struct e1000_adapter *adapter, u64 *data)
 	/* restore previous status */
 	ew32(STATUS, before);
 
-	if ((mac->type != e1000_ich8lan) &&
-	    (mac->type != e1000_ich9lan)) {
+	if (!(adapter->flags & FLAG_IS_ICH)) {
 		REG_PATTERN_TEST(E1000_FCAL, 0xFFFFFFFF, 0xFFFFFFFF);
 		REG_PATTERN_TEST(E1000_FCAH, 0x0000FFFF, 0xFFFFFFFF);
 		REG_PATTERN_TEST(E1000_FCT, 0x0000FFFF, 0xFFFFFFFF);
@@ -824,15 +827,13 @@ static int e1000_reg_test(struct e1000_adapter *adapter, u64 *data)
 
 	REG_SET_AND_CHECK(E1000_RCTL, 0xFFFFFFFF, 0x00000000);
 
-	before = (((mac->type == e1000_ich8lan) ||
-		   (mac->type == e1000_ich9lan)) ? 0x06C3B33E : 0x06DFB3FE);
+	before = ((adapter->flags & FLAG_IS_ICH) ? 0x06C3B33E : 0x06DFB3FE);
 	REG_SET_AND_CHECK(E1000_RCTL, before, 0x003FFFFB);
 	REG_SET_AND_CHECK(E1000_TCTL, 0xFFFFFFFF, 0x00000000);
 
 	REG_SET_AND_CHECK(E1000_RCTL, before, 0xFFFFFFFF);
 	REG_PATTERN_TEST(E1000_RDBAL, 0xFFFFFFF0, 0xFFFFFFFF);
-	if ((mac->type != e1000_ich8lan) &&
-	    (mac->type != e1000_ich9lan))
+	if (!(adapter->flags & FLAG_IS_ICH))
 		REG_PATTERN_TEST(E1000_TXCW, 0xC000FFFF, 0x0000FFFF);
 	REG_PATTERN_TEST(E1000_TDBAL, 0xFFFFFFF0, 0xFFFFFFFF);
 	REG_PATTERN_TEST(E1000_TIDV, 0x0000FFFF, 0x0000FFFF);
@@ -911,9 +912,7 @@ static int e1000_intr_test(struct e1000_adapter *adapter, u64 *data)
 
 	/* Test each interrupt */
 	for (i = 0; i < 10; i++) {
-
-		if (((adapter->hw.mac.type == e1000_ich8lan) ||
-		     (adapter->hw.mac.type == e1000_ich9lan)) && i == 8)
+		if ((adapter->flags & FLAG_IS_ICH) && (i == 8))
 			continue;
 
 		/* Interrupt to test */
@@ -1184,6 +1183,7 @@ static int e1000_integrated_phy_loopback(struct e1000_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 	u32 ctrl_reg = 0;
 	u32 stat_reg = 0;
+	u16 phy_reg = 0;
 
 	hw->mac.autoneg = 0;
 
@@ -1211,6 +1211,28 @@ static int e1000_integrated_phy_loopback(struct e1000_adapter *adapter)
 			     E1000_CTRL_SPD_100 |/* Force Speed to 100 */
 			     E1000_CTRL_FD);	 /* Force Duplex to FULL */
 		break;
+	case e1000_phy_bm:
+		/* Set Default MAC Interface speed to 1GB */
+		e1e_rphy(hw, PHY_REG(2, 21), &phy_reg);
+		phy_reg &= ~0x0007;
+		phy_reg |= 0x006;
+		e1e_wphy(hw, PHY_REG(2, 21), phy_reg);
+		/* Assert SW reset for above settings to take effect */
+		e1000e_commit_phy(hw);
+		mdelay(1);
+		/* Force Full Duplex */
+		e1e_rphy(hw, PHY_REG(769, 16), &phy_reg);
+		e1e_wphy(hw, PHY_REG(769, 16), phy_reg | 0x000C);
+		/* Set Link Up (in force link) */
+		e1e_rphy(hw, PHY_REG(776, 16), &phy_reg);
+		e1e_wphy(hw, PHY_REG(776, 16), phy_reg | 0x0040);
+		/* Force Link */
+		e1e_rphy(hw, PHY_REG(769, 16), &phy_reg);
+		e1e_wphy(hw, PHY_REG(769, 16), phy_reg | 0x0040);
+		/* Set Early Link Enable */
+		e1e_rphy(hw, PHY_REG(769, 20), &phy_reg);
+		e1e_wphy(hw, PHY_REG(769, 20), phy_reg | 0x0400);
+		/* fall through */
 	default:
 		/* force 1000, set loopback */
 		e1e_wphy(hw, PHY_CONTROL, 0x4140);
@@ -1224,8 +1246,7 @@ static int e1000_integrated_phy_loopback(struct e1000_adapter *adapter)
 			     E1000_CTRL_SPD_1000 |/* Force Speed to 1000 */
 			     E1000_CTRL_FD);	 /* Force Duplex to FULL */
 
-		if ((adapter->hw.mac.type == e1000_ich8lan) ||
-		    (adapter->hw.mac.type == e1000_ich9lan))
+		if (adapter->flags & FLAG_IS_ICH)
 			ctrl_reg |= E1000_CTRL_SLU;	/* Set Link Up */
 	}
 
diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index a930e6d..74f263a 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -216,6 +216,21 @@ enum e1e_registers {
 #define IGP01E1000_PHY_LINK_HEALTH	0x13 /* PHY Link Health */
 #define IGP02E1000_PHY_POWER_MGMT	0x19 /* Power Management */
 #define IGP01E1000_PHY_PAGE_SELECT	0x1F /* Page Select */
+#define BM_PHY_PAGE_SELECT		22   /* Page Select for BM */
+#define IGP_PAGE_SHIFT			5
+#define PHY_REG_MASK			0x1F
+
+#define BM_WUC_PAGE			800
+#define BM_WUC_ADDRESS_OPCODE		0x11
+#define BM_WUC_DATA_OPCODE		0x12
+#define BM_WUC_ENABLE_PAGE		769
+#define BM_WUC_ENABLE_REG		17
+#define BM_WUC_ENABLE_BIT		(1 << 2)
+#define BM_WUC_HOST_WU_BIT		(1 << 4)
+
+#define BM_WUC	PHY_REG(BM_WUC_PAGE, 1)
+#define BM_WUFC PHY_REG(BM_WUC_PAGE, 2)
+#define BM_WUS	PHY_REG(BM_WUC_PAGE, 3)
 
 #define IGP01E1000_PHY_PCS_INIT_REG	0x00B4
 #define IGP01E1000_PHY_POLARITY_MASK	0x0078
@@ -331,10 +346,16 @@ enum e1e_registers {
 #define E1000_DEV_ID_ICH8_IFE_G			0x10C5
 #define E1000_DEV_ID_ICH8_IGP_M			0x104D
 #define E1000_DEV_ID_ICH9_IGP_AMT		0x10BD
+#define E1000_DEV_ID_ICH9_IGP_M_AMT		0x10F5
+#define E1000_DEV_ID_ICH9_IGP_M			0x10BF
+#define E1000_DEV_ID_ICH9_IGP_M_V		0x10CB
 #define E1000_DEV_ID_ICH9_IGP_C			0x294C
 #define E1000_DEV_ID_ICH9_IFE			0x10C0
 #define E1000_DEV_ID_ICH9_IFE_GT		0x10C3
 #define E1000_DEV_ID_ICH9_IFE_G			0x10C2
+#define E1000_DEV_ID_ICH10_R_BM_LM		0x10CC
+#define E1000_DEV_ID_ICH10_R_BM_LF		0x10CD
+#define E1000_DEV_ID_ICH10_R_BM_V		0x10CE
 
 #define E1000_FUNC_1 1
 
@@ -378,6 +399,7 @@ enum e1000_phy_type {
 	e1000_phy_gg82563,
 	e1000_phy_igp_3,
 	e1000_phy_ife,
+	e1000_phy_bm,
 };
 
 enum e1000_bus_width {
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 768485d..9e38452 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -38,6 +38,12 @@
  * 82566DM Gigabit Network Connection
  * 82566MC Gigabit Network Connection
  * 82566MM Gigabit Network Connection
+ * 82567LM Gigabit Network Connection
+ * 82567LF Gigabit Network Connection
+ * 82567LM-2 Gigabit Network Connection
+ * 82567LF-2 Gigabit Network Connection
+ * 82567V-2 Gigabit Network Connection
+ * 82562GT-3 10/100 Network Connection
  */
 
 #include <linux/netdevice.h>
@@ -198,6 +204,19 @@ static s32 e1000_init_phy_params_ich8lan(struct e1000_hw *hw)
 	phy->addr			= 1;
 	phy->reset_delay_us		= 100;
 
+	/*
+	 * We may need to do this twice - once for IGP and if that fails,
+	 * we'll set BM func pointers and try again
+	 */
+	ret_val = e1000e_determine_phy_address(hw);
+	if (ret_val) {
+		hw->phy.ops.write_phy_reg = e1000e_write_phy_reg_bm;
+		hw->phy.ops.read_phy_reg  = e1000e_read_phy_reg_bm;
+		ret_val = e1000e_determine_phy_address(hw);
+		if (ret_val)
+			return ret_val;
+	}
+
 	phy->id = 0;
 	while ((e1000_phy_unknown == e1000e_get_phy_type_from_id(phy->id)) &&
 	       (i++ < 100)) {
@@ -219,6 +238,13 @@ static s32 e1000_init_phy_params_ich8lan(struct e1000_hw *hw)
 		phy->type = e1000_phy_ife;
 		phy->autoneg_mask = E1000_ALL_NOT_GIG;
 		break;
+	case BME1000_E_PHY_ID:
+		phy->type = e1000_phy_bm;
+		phy->autoneg_mask = AUTONEG_ADVERTISE_SPEED_DEFAULT;
+		hw->phy.ops.read_phy_reg = e1000e_read_phy_reg_bm;
+		hw->phy.ops.write_phy_reg = e1000e_write_phy_reg_bm;
+		hw->phy.ops.commit_phy = e1000e_phy_sw_reset;
+		break;
 	default:
 		return -E1000_ERR_PHY;
 		break;
@@ -664,6 +690,7 @@ static s32 e1000_get_phy_info_ich8lan(struct e1000_hw *hw)
 		return e1000_get_phy_info_ife_ich8lan(hw);
 		break;
 	case e1000_phy_igp_3:
+	case e1000_phy_bm:
 		return e1000e_get_phy_info_igp(hw);
 		break;
 	default:
@@ -728,7 +755,7 @@ static s32 e1000_set_d0_lplu_state_ich8lan(struct e1000_hw *hw, bool active)
 	s32 ret_val = 0;
 	u16 data;
 
-	if (phy->type != e1000_phy_igp_3)
+	if (phy->type == e1000_phy_ife)
 		return ret_val;
 
 	phy_ctrl = er32(PHY_CTRL);
@@ -1918,8 +1945,35 @@ static s32 e1000_setup_copper_link_ich8lan(struct e1000_hw *hw)
 		ret_val = e1000e_copper_link_setup_igp(hw);
 		if (ret_val)
 			return ret_val;
+	} else if (hw->phy.type == e1000_phy_bm) {
+		ret_val = e1000e_copper_link_setup_m88(hw);
+		if (ret_val)
+			return ret_val;
 	}
 
+	if (hw->phy.type == e1000_phy_ife) {
+		ret_val = e1e_rphy(hw, IFE_PHY_MDIX_CONTROL, &reg_data);
+		if (ret_val)
+			return ret_val;
+
+		reg_data &= ~IFE_PMC_AUTO_MDIX;
+
+		switch (hw->phy.mdix) {
+		case 1:
+			reg_data &= ~IFE_PMC_FORCE_MDIX;
+			break;
+		case 2:
+			reg_data |= IFE_PMC_FORCE_MDIX;
+			break;
+		case 0:
+		default:
+			reg_data |= IFE_PMC_AUTO_MDIX;
+			break;
+		}
+		ret_val = e1e_wphy(hw, IFE_PHY_MDIX_CONTROL, reg_data);
+		if (ret_val)
+			return ret_val;
+	}
 	return e1000e_setup_copper_link(hw);
 }
 
@@ -2127,6 +2181,31 @@ void e1000e_gig_downshift_workaround_ich8lan(struct e1000_hw *hw)
 }
 
 /**
+ *  e1000e_disable_gig_wol_ich8lan - disable gig during WoL
+ *  @hw: pointer to the HW structure
+ *
+ *  During S0 to Sx transition, it is possible the link remains at gig
+ *  instead of negotiating to a lower speed.  Before going to Sx, set
+ *  'LPLU Enabled' and 'Gig Disable' to force link speed negotiation
+ *  to a lower speed.
+ *
+ *  Should only be called for ICH9 devices.
+ **/
+void e1000e_disable_gig_wol_ich8lan(struct e1000_hw *hw)
+{
+	u32 phy_ctrl;
+
+	if (hw->mac.type == e1000_ich9lan) {
+		phy_ctrl = er32(PHY_CTRL);
+		phy_ctrl |= E1000_PHY_CTRL_D0A_LPLU |
+		            E1000_PHY_CTRL_GBE_DISABLE;
+		ew32(PHY_CTRL, phy_ctrl);
+	}
+
+	return;
+}
+
+/**
  *  e1000_cleanup_led_ich8lan - Restore the default LED operation
  *  @hw: pointer to the HW structure
  *
@@ -2247,6 +2326,7 @@ static struct e1000_nvm_operations ich8_nvm_ops = {
 struct e1000_info e1000_ich8_info = {
 	.mac			= e1000_ich8lan,
 	.flags			= FLAG_HAS_WOL
+				  | FLAG_IS_ICH
 				  | FLAG_RX_CSUM_ENABLED
 				  | FLAG_HAS_CTRLEXT_ON_LOAD
 				  | FLAG_HAS_AMT
@@ -2262,6 +2342,7 @@ struct e1000_info e1000_ich8_info = {
 struct e1000_info e1000_ich9_info = {
 	.mac			= e1000_ich9lan,
 	.flags			= FLAG_HAS_JUMBO_FRAMES
+				  | FLAG_IS_ICH
 				  | FLAG_HAS_WOL
 				  | FLAG_RX_CSUM_ENABLED
 				  | FLAG_HAS_CTRLEXT_ON_LOAD
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 8991ab8..8cbb40f 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -43,10 +43,11 @@
 #include <linux/if_vlan.h>
 #include <linux/cpu.h>
 #include <linux/smp.h>
+#include <linux/pm_qos_params.h>
 
 #include "e1000.h"
 
-#define DRV_VERSION "0.2.1"
+#define DRV_VERSION "0.3.3.3-k2"
 char e1000e_driver_name[] = "e1000e";
 const char e1000e_driver_version[] = DRV_VERSION;
 
@@ -341,6 +342,89 @@ no_buffers:
 }
 
 /**
+ * e1000_alloc_jumbo_rx_buffers - Replace used jumbo receive buffers
+ * @adapter: address of board private structure
+ * @rx_ring: pointer to receive ring structure
+ * @cleaned_count: number of buffers to allocate this pass
+ **/
+
+static void e1000_alloc_jumbo_rx_buffers(struct e1000_adapter *adapter,
+                                         int cleaned_count)
+{
+	struct net_device *netdev = adapter->netdev;
+	struct pci_dev *pdev = adapter->pdev;
+	struct e1000_rx_desc *rx_desc;
+	struct e1000_ring *rx_ring = adapter->rx_ring;
+	struct e1000_buffer *buffer_info;
+	struct sk_buff *skb;
+	unsigned int i;
+	unsigned int bufsz = 256 -
+	                     16 /* for skb_reserve */ -
+	                     NET_IP_ALIGN;
+
+	i = rx_ring->next_to_use;
+	buffer_info = &rx_ring->buffer_info[i];
+
+	while (cleaned_count--) {
+		skb = buffer_info->skb;
+		if (skb) {
+			skb_trim(skb, 0);
+			goto check_page;
+		}
+
+		skb = netdev_alloc_skb(netdev, bufsz);
+		if (unlikely(!skb)) {
+			/* Better luck next round */
+			adapter->alloc_rx_buff_failed++;
+			break;
+		}
+
+		/* Make buffer alignment 2 beyond a 16 byte boundary
+		 * this will result in a 16 byte aligned IP header after
+		 * the 14 byte MAC header is removed
+		 */
+		skb_reserve(skb, NET_IP_ALIGN);
+
+		buffer_info->skb = skb;
+check_page:
+		/* allocate a new page if necessary */
+		if (!buffer_info->page) {
+			buffer_info->page = alloc_page(GFP_ATOMIC);
+			if (unlikely(!buffer_info->page)) {
+				adapter->alloc_rx_buff_failed++;
+				break;
+			}
+		}
+
+		if (!buffer_info->dma)
+			buffer_info->dma = pci_map_page(pdev,
+			                                buffer_info->page, 0,
+			                                PAGE_SIZE,
+			                                PCI_DMA_FROMDEVICE);
+
+		rx_desc = E1000_RX_DESC(*rx_ring, i);
+		rx_desc->buffer_addr = cpu_to_le64(buffer_info->dma);
+
+		if (unlikely(++i == rx_ring->count))
+			i = 0;
+		buffer_info = &rx_ring->buffer_info[i];
+	}
+
+	if (likely(rx_ring->next_to_use != i)) {
+		rx_ring->next_to_use = i;
+		if (unlikely(i-- == 0))
+			i = (rx_ring->count - 1);
+
+		/* Force memory writes to complete before letting h/w
+		 * know there are new descriptors to fetch.  (Only
+		 * applicable for weak-ordered memory model archs,
+		 * such as IA-64). */
+		wmb();
+		writel(i, adapter->hw.hw_addr + rx_ring->tail);
+	}
+}
+
+/**
  * e1000_clean_rx_irq - Send received data up the network stack; legacy
  * @adapter: board private structure
  *
@@ -783,6 +867,186 @@ next_desc:
 }
 
 /**
+ * e1000_consume_page - helper function
+ **/
+static void e1000_consume_page(struct e1000_buffer *bi, struct sk_buff *skb,
+                               u16 length)
+{
+	bi->page = NULL;
+	skb->len += length;
+	skb->data_len += length;
+	skb->truesize += length;
+}
+
+/**
+ * e1000_clean_jumbo_rx_irq - Send received data up the network stack; legacy
+ * @adapter: board private structure
+ *
+ * the return value indicates whether actual cleaning was done, there
+ * is no guarantee that everything was cleaned
+ **/
+
+static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
+                                     int *work_done, int work_to_do)
+{
+	struct net_device *netdev = adapter->netdev;
+	struct pci_dev *pdev = adapter->pdev;
+	struct e1000_ring *rx_ring = adapter->rx_ring;
+	struct e1000_rx_desc *rx_desc, *next_rxd;
+	struct e1000_buffer *buffer_info, *next_buffer;
+	u32 length;
+	unsigned int i;
+	int cleaned_count = 0;
+	bool cleaned = false;
+	unsigned int total_rx_bytes=0, total_rx_packets=0;
+
+	i = rx_ring->next_to_clean;
+	rx_desc = E1000_RX_DESC(*rx_ring, i);
+	buffer_info = &rx_ring->buffer_info[i];
+
+	while (rx_desc->status & E1000_RXD_STAT_DD) {
+		struct sk_buff *skb;
+		u8 status;
+
+		if (*work_done >= work_to_do)
+			break;
+		(*work_done)++;
+
+		status = rx_desc->status;
+		skb = buffer_info->skb;
+		buffer_info->skb = NULL;
+
+		++i;
+		if (i == rx_ring->count)
+			i = 0;
+		next_rxd = E1000_RX_DESC(*rx_ring, i);
+		prefetch(next_rxd);
+
+		next_buffer = &rx_ring->buffer_info[i];
+
+		cleaned = true;
+		cleaned_count++;
+		pci_unmap_page(pdev, buffer_info->dma, PAGE_SIZE,
+		               PCI_DMA_FROMDEVICE);
+		buffer_info->dma = 0;
+
+		length = le16_to_cpu(rx_desc->length);
+
+		/* errors is only valid for DD + EOP descriptors */
+		if (unlikely((status & E1000_RXD_STAT_EOP) &&
+		    (rx_desc->errors & E1000_RXD_ERR_FRAME_ERR_MASK))) {
+				/* recycle both page and skb */
+				buffer_info->skb = skb;
+				/* an error means any chain goes out the window
+				 * too */
+				if (rx_ring->rx_skb_top)
+					dev_kfree_skb(rx_ring->rx_skb_top);
+				rx_ring->rx_skb_top = NULL;
+				goto next_desc;
+		}
+
+#define rxtop rx_ring->rx_skb_top
+		if (!(status & E1000_RXD_STAT_EOP)) {
+			/* this descriptor is only the beginning (or middle) */
+			if (!rxtop) {
+				/* this is the beginning of a chain */
+				rxtop = skb;
+				skb_fill_page_desc(rxtop, 0, buffer_info->page,
+				                   0, length);
+			} else {
+				/* this is the middle of a chain */
+				skb_fill_page_desc(rxtop,
+				    skb_shinfo(rxtop)->nr_frags,
+				    buffer_info->page, 0, length);
+				/* re-use the skb, only consumed the page */
+				buffer_info->skb = skb;
+			}
+			e1000_consume_page(buffer_info, rxtop, length);
+			goto next_desc;
+		} else {
+			if (rxtop) {
+				/* end of the chain */
+				skb_fill_page_desc(rxtop,
+				    skb_shinfo(rxtop)->nr_frags,
+				    buffer_info->page, 0, length);
+				/* re-use the current skb, we only consumed the
+				 * page */
+				buffer_info->skb = skb;
+				skb = rxtop;
+				rxtop = NULL;
+				e1000_consume_page(buffer_info, skb, length);
+			} else {
+				/* no chain, got EOP, this buf is the packet
+				 * copybreak to save the put_page/alloc_page */
+				if (length <= copybreak &&
+				    skb_tailroom(skb) >= length) {
+					u8 *vaddr;
+					vaddr = kmap_atomic(buffer_info->page,
+					                   KM_SKB_DATA_SOFTIRQ);
+					memcpy(skb_tail_pointer(skb), vaddr,
+					       length);
+					kunmap_atomic(vaddr,
+					              KM_SKB_DATA_SOFTIRQ);
+					/* re-use the page, so don't erase
+					 * buffer_info->page */
+					skb_put(skb, length);
+				} else {
+					skb_fill_page_desc(skb, 0,
+					                   buffer_info->page, 0,
+				                           length);
+					e1000_consume_page(buffer_info, skb,
+					                   length);
+				}
+			}
+		}
+
+		/* Receive Checksum Offload XXX recompute due to CRC strip? */
+		e1000_rx_checksum(adapter,
+		                  (u32)(status) |
+		                  ((u32)(rx_desc->errors) << 24),
+		                  le16_to_cpu(rx_desc->csum), skb);
+
+		/* probably a little skewed due to removing CRC */
+		total_rx_bytes += skb->len;
+		total_rx_packets++;
+
+		/* eth type trans needs skb->data to point to something */
+		if (!pskb_may_pull(skb, ETH_HLEN)) {
+			ndev_err(netdev, "pskb_may_pull failed.\n");
+			dev_kfree_skb(skb);
+			goto next_desc;
+		}
+
+		e1000_receive_skb(adapter, netdev, skb, status,
+		                  rx_desc->special);
+
+next_desc:
+		rx_desc->status = 0;
+
+		/* return some buffers to hardware, one at a time is too slow */
+		if (unlikely(cleaned_count >= E1000_RX_BUFFER_WRITE)) {
+			adapter->alloc_rx_buf(adapter, cleaned_count);
+			cleaned_count = 0;
+		}
+
+		/* use prefetched values */
+		rx_desc = next_rxd;
+		buffer_info = next_buffer;
+	}
+	rx_ring->next_to_clean = i;
+
+	cleaned_count = e1000_desc_unused(rx_ring);
+	if (cleaned_count)
+		adapter->alloc_rx_buf(adapter, cleaned_count);
+
+	adapter->total_rx_bytes += total_rx_bytes;
+	adapter->total_rx_packets += total_rx_packets;
+	adapter->net_stats.rx_bytes += total_rx_bytes;
+	adapter->net_stats.rx_packets += total_rx_packets;
+	return cleaned;
+}
+
+/**
  * e1000_clean_rx_ring - Free Rx Buffers per Queue
  * @adapter: board private structure
  **/
@@ -802,6 +1066,10 @@ static void e1000_clean_rx_ring(struct e1000_adapter *adapter)
 				pci_unmap_single(pdev, buffer_info->dma,
 						 adapter->rx_buffer_len,
 						 PCI_DMA_FROMDEVICE);
+			else if (adapter->clean_rx == e1000_clean_jumbo_rx_irq)
+				pci_unmap_page(pdev, buffer_info->dma,
+				               PAGE_SIZE,
+				               PCI_DMA_FROMDEVICE);
 			else if (adapter->clean_rx == e1000_clean_rx_irq_ps)
 				pci_unmap_single(pdev, buffer_info->dma,
 						 adapter->rx_ps_bsize0,
@@ -809,6 +1077,11 @@ static void e1000_clean_rx_ring(struct e1000_adapter *adapter)
 			buffer_info->dma = 0;
 		}
 
+		if (buffer_info->page) {
+			put_page(buffer_info->page);
+			buffer_info->page = NULL;
+		}
+
 		if (buffer_info->skb) {
 			dev_kfree_skb(buffer_info->skb);
 			buffer_info->skb = NULL;
@@ -1755,10 +2028,12 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 	 * a lot of memory, since we allocate 3 pages at all times
 	 * per packet.
 	 */
-	adapter->rx_ps_pages = 0;
 	pages = PAGE_USE_COUNT(adapter->netdev->mtu);
-	if ((pages <= 3) && (PAGE_SIZE <= 16384) && (rctl & E1000_RCTL_LPE))
+	if (!(adapter->flags & FLAG_IS_ICH) && (pages <= 3) &&
+	    (PAGE_SIZE <= 16384) && (rctl & E1000_RCTL_LPE))
 		adapter->rx_ps_pages = pages;
+	else
+		adapter->rx_ps_pages = 0;
 
 	if (adapter->rx_ps_pages) {
 		/* Configure extra packet-split registers */
@@ -1819,9 +2094,12 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
 			sizeof(union e1000_rx_desc_packet_split);
 		adapter->clean_rx = e1000_clean_rx_irq_ps;
 		adapter->alloc_rx_buf = e1000_alloc_rx_buffers_ps;
+	} else if (adapter->netdev->mtu > ETH_FRAME_LEN + ETH_FCS_LEN) {
+		rdlen = rx_ring->count * sizeof(struct e1000_rx_desc);
+		adapter->clean_rx = e1000_clean_jumbo_rx_irq;
+		adapter->alloc_rx_buf = e1000_alloc_jumbo_rx_buffers;
 	} else {
-		rdlen = rx_ring->count *
-			sizeof(struct e1000_rx_desc);
+		rdlen = rx_ring->count * sizeof(struct e1000_rx_desc);
 		adapter->clean_rx = e1000_clean_rx_irq;
 		adapter->alloc_rx_buf = e1000_alloc_rx_buffers;
 	}
@@ -1885,8 +2163,21 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
 	 * units), e.g. using jumbo frames when setting to E1000_ERT_2048
 	 */
 	if ((adapter->flags & FLAG_HAS_ERT) &&
-	    (adapter->netdev->mtu > ETH_DATA_LEN))
-		ew32(ERT, E1000_ERT_2048);
+	    (adapter->netdev->mtu > ETH_DATA_LEN)) {
+		u32 rxdctl = er32(RXDCTL(0));
+		ew32(RXDCTL(0), rxdctl | 0x3);
+		ew32(ERT, E1000_ERT_2048 | (1 << 13));
+		/*
+		 * With jumbo frames and early-receive enabled, excessive
+		 * C4->C2 latencies result in dropped transactions.
+		 */
+		pm_qos_update_requirement(PM_QOS_CPU_DMA_LATENCY,
+					  e1000e_driver_name, 55);
+	} else {
+		pm_qos_update_requirement(PM_QOS_CPU_DMA_LATENCY,
+					  e1000e_driver_name,
+					  PM_QOS_DEFAULT_VALUE);
+	}
 
 	/* Enable Receives */
 	ew32(RCTL, rctl);
@@ -2155,6 +2446,14 @@ void e1000e_reset(struct e1000_adapter *adapter)
 
 	/* Allow time for pending master requests to run */
 	mac->ops.reset_hw(hw);
+
+	/*
+	 * For parts with AMT enabled, let the firmware know
+	 * that the network interface is in control
+	 */
+	if ((adapter->flags & FLAG_HAS_AMT) && e1000e_check_mng_mode(hw))
+		e1000_get_hw_control(adapter);
+
 	ew32(WUC, 0);
 
 	if (mac->ops.init_hw(hw))
@@ -3469,6 +3768,8 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 	 * means we reserve 2 more, this pushes us to allocate from the next
 	 * larger slab size.
 	 * i.e. RXBUFFER_2048 --> size-4096 slab
+	 * However with the new *_jumbo_rx* routines, jumbo receives will use
+	 * fragmented skbs
 	 */
 
 	if (max_frame <= 256)
@@ -3626,6 +3927,9 @@ static int e1000_suspend(struct pci_dev *pdev, pm_message_t state)
 			ew32(CTRL_EXT, ctrl_ext);
 		}
 
+		if (adapter->flags & FLAG_IS_ICH)
+			e1000e_disable_gig_wol_ich8lan(&adapter->hw);
+
 		/* Allow time for pending master requests to run */
 		e1000e_disable_pcie_master(&adapter->hw);
 
@@ -4292,6 +4596,13 @@ static struct pci_device_id e1000_pci_tbl[] = {
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH9_IFE_GT), board_ich9lan },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH9_IGP_AMT), board_ich9lan },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH9_IGP_C), board_ich9lan },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH9_IGP_M), board_ich9lan },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH9_IGP_M_AMT), board_ich9lan },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH9_IGP_M_V), board_ich9lan },
+
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH10_R_BM_LM), board_ich9lan },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH10_R_BM_LF), board_ich9lan },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH10_R_BM_V), board_ich9lan },
 
 	{ }	/* terminate list */
 };
@@ -4326,7 +4637,9 @@ static int __init e1000_init_module(void)
 	printk(KERN_INFO "%s: Copyright (c) 1999-2008 Intel Corporation.\n",
 	       e1000e_driver_name);
 	ret = pci_register_driver(&e1000_driver);
-
+	pm_qos_add_requirement(PM_QOS_CPU_DMA_LATENCY, e1000e_driver_name,
+			       PM_QOS_DEFAULT_VALUE);
+				
 	return ret;
 }
 module_init(e1000_init_module);
@@ -4340,6 +4653,7 @@ module_init(e1000_init_module);
 static void __exit e1000_exit_module(void)
 {
 	pci_unregister_driver(&e1000_driver);
+	pm_qos_remove_requirement(PM_QOS_CPU_DMA_LATENCY, e1000e_driver_name);
 }
 module_exit(e1000_exit_module);
 
diff --git a/drivers/net/e1000e/phy.c b/drivers/net/e1000e/phy.c
index e102332..b133dcf 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -34,6 +34,9 @@ static s32 e1000_get_phy_cfg_done(struct e1000_hw *hw);
 static s32 e1000_phy_force_speed_duplex(struct e1000_hw *hw);
 static s32 e1000_set_d0_lplu_state(struct e1000_hw *hw, bool active);
 static s32 e1000_wait_autoneg(struct e1000_hw *hw);
+static u32 e1000_get_phy_addr_for_bm_page(u32 page, u32 reg);
+static s32 e1000_access_phy_wakeup_reg_bm(struct e1000_hw *hw, u32 offset,
+					  u16 *data, bool read);
 
 /* Cable length tables */
 static const u16 e1000_m88_cable_length_table[] =
@@ -465,6 +468,10 @@ s32 e1000e_copper_link_setup_m88(struct e1000_hw *hw)
 	if (phy->disable_polarity_correction == 1)
 		phy_data |= M88E1000_PSCR_POLARITY_REVERSAL;
 
+	/* Enable downshift on BM (disabled by default) */
+	if (phy->type == e1000_phy_bm)
+		phy_data |= BME1000_PSCR_ENABLE_DOWNSHIFT;
+
 	ret_val = e1e_wphy(hw, M88E1000_PHY_SPEC_CTRL, phy_data);
 	if (ret_val)
 		return ret_val;
@@ -1776,6 +1783,10 @@ enum e1000_phy_type e1000e_get_phy_type_from_id(u32 phy_id)
 	case IFE_C_E_PHY_ID:
 		phy_type = e1000_phy_ife;
 		break;
+	case BME1000_E_PHY_ID:
+	case BME1000_E_PHY_ID_R2:
+		phy_type = e1000_phy_bm;
+		break;
 	default:
 		phy_type = e1000_phy_unknown;
 		break;
@@ -1784,6 +1795,273 @@ enum e1000_phy_type e1000e_get_phy_type_from_id(u32 phy_id)
 }
 
 /**
+ *  e1000e_determine_phy_address - Determines PHY address.
+ *  @hw: pointer to the HW structure
+ *
+ *  This uses a trial and error method to loop through possible PHY
+ *  addresses. It tests each by reading the PHY ID registers and
+ *  checking for a match.
+ **/
+s32 e1000e_determine_phy_address(struct e1000_hw *hw)
+{
+	s32 ret_val = -E1000_ERR_PHY_TYPE;
+	u32 phy_addr= 0;
+	u32 i = 0;
+	enum e1000_phy_type phy_type = e1000_phy_unknown;
+
+	do {
+		for (phy_addr = 0; phy_addr < 4; phy_addr++) {
+			hw->phy.addr = phy_addr;
+			e1000e_get_phy_id(hw);
+			phy_type = e1000e_get_phy_type_from_id(hw->phy.id);
+
+			/* 
+			 * If phy_type is valid, break - we found our
+			 * PHY address
+			 */
+			if (phy_type  != e1000_phy_unknown) {
+				ret_val = 0;
+				break;
+			}
+		}
+		i++;
+	} while ((ret_val != 0) && (i < 100));
+
+	return ret_val;
+}
+
+/**
+ *  e1000_get_phy_addr_for_bm_page - Retrieve PHY page address
+ *  @page: page to access
+ *
+ *  Returns the phy address for the page requested.
+ **/
+static u32 e1000_get_phy_addr_for_bm_page(u32 page, u32 reg)
+{
+	u32 phy_addr = 2;
+
+	if ((page >= 768) || (page == 0 && reg == 25) || (reg == 31))
+		phy_addr = 1;
+
+	return phy_addr;
+}
+
+/**
+ *  e1000e_write_phy_reg_bm - Write BM PHY register
+ *  @hw: pointer to the HW structure
+ *  @offset: register offset to write to
+ *  @data: data to write at register offset
+ *
+ *  Acquires semaphore, if necessary, then writes the data to PHY register
+ *  at the offset.  Release any acquired semaphores before exiting.
+ **/
+s32 e1000e_write_phy_reg_bm(struct e1000_hw *hw, u32 offset, u16 data)
+{
+	s32 ret_val;
+	u32 page_select = 0;
+	u32 page = offset >> IGP_PAGE_SHIFT;
+	u32 page_shift = 0;
+
+	/* Page 800 works differently than the rest so it has its own func */
+	if (page == BM_WUC_PAGE) {
+		ret_val = e1000_access_phy_wakeup_reg_bm(hw, offset, &data,
+							 false);
+		goto out;
+	}
+
+	ret_val = hw->phy.ops.acquire_phy(hw);
+	if (ret_val)
+		goto out;
+
+	hw->phy.addr = e1000_get_phy_addr_for_bm_page(page, offset);
+
+	if (offset > MAX_PHY_MULTI_PAGE_REG) {
+		/*
+		 * Page select is register 31 for phy address 1 and 22 for
+		 * phy address 2 and 3. Page select is shifted only for
+		 * phy address 1.
+		 */
+		if (hw->phy.addr == 1) {
+			page_shift = IGP_PAGE_SHIFT;
+			page_select = IGP01E1000_PHY_PAGE_SELECT;
+		} else {
+			page_shift = 0;
+			page_select = BM_PHY_PAGE_SELECT;
+		}
+
+		/* Page is shifted left, PHY expects (page x 32) */
+		ret_val = e1000e_write_phy_reg_mdic(hw, page_select,
+		                                    (page << page_shift));
+		if (ret_val) {
+			hw->phy.ops.release_phy(hw);
+			goto out;
+		}
+	}
+
+	ret_val = e1000e_write_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & offset,
+	                                    data);
+
+	hw->phy.ops.release_phy(hw);
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000e_read_phy_reg_bm - Read BM PHY register
+ *  @hw: pointer to the HW structure
+ *  @offset: register offset to be read
+ *  @data: pointer to the read data
+ *
+ *  Acquires semaphore, if necessary, then reads the PHY register at offset
+ *  and storing the retrieved information in data.  Release any acquired
+ *  semaphores before exiting.
+ **/
+s32 e1000e_read_phy_reg_bm(struct e1000_hw *hw, u32 offset, u16 *data)
+{
+	s32 ret_val;
+	u32 page_select = 0;
+	u32 page = offset >> IGP_PAGE_SHIFT;
+	u32 page_shift = 0;
+
+	/* Page 800 works differently than the rest so it has its own func */
+	if (page == BM_WUC_PAGE) {
+		ret_val = e1000_access_phy_wakeup_reg_bm(hw, offset, data,
+							 true);
+		goto out;
+	}
+
+	ret_val = hw->phy.ops.acquire_phy(hw);
+	if (ret_val)
+		goto out;
+
+	hw->phy.addr = e1000_get_phy_addr_for_bm_page(page, offset);
+
+	if (offset > MAX_PHY_MULTI_PAGE_REG) {
+		/*
+		 * Page select is register 31 for phy address 1 and 22 for
+		 * phy address 2 and 3. Page select is shifted only for
+		 * phy address 1.
+		 */
+		if (hw->phy.addr == 1) {
+			page_shift = IGP_PAGE_SHIFT;
+			page_select = IGP01E1000_PHY_PAGE_SELECT;
+		} else {
+			page_shift = 0;
+			page_select = BM_PHY_PAGE_SELECT;
+		}
+
+		/* Page is shifted left, PHY expects (page x 32) */
+		ret_val = e1000e_write_phy_reg_mdic(hw, page_select,
+		                                    (page << page_shift));
+		if (ret_val) {
+			hw->phy.ops.release_phy(hw);
+			goto out;
+		}
+	}
+
+	ret_val = e1000e_read_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & offset,
+	                                   data);
+	hw->phy.ops.release_phy(hw);
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_access_phy_wakeup_reg_bm - Read BM PHY wakeup register
+ *  @hw: pointer to the HW structure
+ *  @offset: register offset to be read or written
+ *  @data: pointer to the data to read or write
+ *  @read: determines if operation is read or write
+ *
+ *  Acquires semaphore, if necessary, then reads the PHY register at offset
+ *  and storing the retrieved information in data.  Release any acquired
+ *  semaphores before exiting. Note that procedure to read the wakeup
+ *  registers are different. It works as such:
+ *  1) Set page 769, register 17, bit 2 = 1
+ *  2) Set page to 800 for host (801 if we were manageability)
+ *  3) Write the address using the address opcode (0x11)
+ *  4) Read or write the data using the data opcode (0x12)
+ *  5) Restore 769_17.2 to its original value
+ **/
+static s32 e1000_access_phy_wakeup_reg_bm(struct e1000_hw *hw, u32 offset,
+					  u16 *data, bool read)
+{
+	s32 ret_val;
+	u16 reg = ((u16)offset) & PHY_REG_MASK;
+	u16 phy_reg = 0;
+	u8  phy_acquired = 1;
+
+
+	ret_val = hw->phy.ops.acquire_phy(hw);
+	if (ret_val) {
+		phy_acquired = 0;
+		goto out;
+	}
+
+	/* All operations in this function are phy address 1 */
+	hw->phy.addr = 1;
+
+	/* Set page 769 */
+	e1000e_write_phy_reg_mdic(hw, IGP01E1000_PHY_PAGE_SELECT,
+	                          (BM_WUC_ENABLE_PAGE << IGP_PAGE_SHIFT));
+
+	ret_val = e1000e_read_phy_reg_mdic(hw, BM_WUC_ENABLE_REG, &phy_reg);
+	if (ret_val)
+		goto out;
+
+	/* First clear bit 4 to avoid a power state change */
+	phy_reg &= ~(BM_WUC_HOST_WU_BIT);
+	ret_val = e1000e_write_phy_reg_mdic(hw, BM_WUC_ENABLE_REG, phy_reg);
+	if (ret_val)
+		goto out;
+
+	/* Write bit 2 = 1, and clear bit 4 to 769_17 */
+	ret_val = e1000e_write_phy_reg_mdic(hw, BM_WUC_ENABLE_REG,
+	                                    phy_reg | BM_WUC_ENABLE_BIT);
+	if (ret_val)
+		goto out;
+
+	/* Select page 800 */
+	ret_val = e1000e_write_phy_reg_mdic(hw, IGP01E1000_PHY_PAGE_SELECT,
+	                                    (BM_WUC_PAGE << IGP_PAGE_SHIFT));
+
+	/* Write the page 800 offset value using opcode 0x11 */
+	ret_val = e1000e_write_phy_reg_mdic(hw, BM_WUC_ADDRESS_OPCODE, reg);
+	if (ret_val)
+		goto out;
+
+	if (read) {
+	        /* Read the page 800 value using opcode 0x12 */
+		ret_val = e1000e_read_phy_reg_mdic(hw, BM_WUC_DATA_OPCODE,
+		                                   data);
+	} else {
+	        /* Read the page 800 value using opcode 0x12 */
+		ret_val = e1000e_write_phy_reg_mdic(hw, BM_WUC_DATA_OPCODE,
+						    *data);
+	}
+
+	if (ret_val)
+		goto out;
+
+	/*
+	 * Restore 769_17.2 to its original value
+	 * Set page 769
+	 */
+	e1000e_write_phy_reg_mdic(hw, IGP01E1000_PHY_PAGE_SELECT,
+	                          (BM_WUC_ENABLE_PAGE << IGP_PAGE_SHIFT));
+
+	/* Clear 769_17.2 */
+	ret_val = e1000e_write_phy_reg_mdic(hw, BM_WUC_ENABLE_REG, phy_reg);
+
+out:
+	if (phy_acquired == 1)
+		hw->phy.ops.release_phy(hw);
+	return ret_val;
+}
+
+/**
  *  e1000e_commit_phy - Soft PHY reset
  *  @hw: pointer to the HW structure
  *
diff --git a/drivers/net/eexpress.c b/drivers/net/eexpress.c
index 2eb82ab..795c594 100644
--- a/drivers/net/eexpress.c
+++ b/drivers/net/eexpress.c
@@ -202,7 +202,7 @@ static unsigned short start_code[] = {
 	0x0000,Cmd_MCast,
 	0x0076,                 /* link to next command */
 #define CONF_NR_MULTICAST 0x44
-	0x0000,                 /* number of multicast addresses */
+	0x0000,                 /* number of bytes in multicast address(es) */
 #define CONF_MULTICAST 0x46
 	0x0000, 0x0000, 0x0000, /* some addresses */
 	0x0000, 0x0000, 0x0000,
@@ -1569,7 +1569,7 @@ static void eexp_hw_init586(struct net_device *dev)
 
 static void eexp_setup_filter(struct net_device *dev)
 {
-	struct dev_mc_list *dmi = dev->mc_list;
+	struct dev_mc_list *dmi;
 	unsigned short ioaddr = dev->base_addr;
 	int count = dev->mc_count;
 	int i;
@@ -1580,9 +1580,9 @@ static void eexp_setup_filter(struct net_device *dev)
 	}
 
 	outw(CONF_NR_MULTICAST & ~31, ioaddr+SM_PTR);
-	outw(count, ioaddr+SHADOW(CONF_NR_MULTICAST));
-	for (i = 0; i < count; i++) {
-		unsigned short *data = (unsigned short *)dmi->dmi_addr;
+	outw(6*count, ioaddr+SHADOW(CONF_NR_MULTICAST));
+	for (i = 0, dmi = dev->mc_list; i < count; i++, dmi = dmi->next) {
+		unsigned short *data;
 		if (!dmi) {
 			printk(KERN_INFO "%s: too few multicast addresses\n", dev->name);
 			break;
@@ -1591,6 +1591,7 @@ static void eexp_setup_filter(struct net_device *dev)
 			printk(KERN_INFO "%s: invalid multicast address length given.\n", dev->name);
 			continue;
 		}
+		data = (unsigned short *)dmi->dmi_addr;
 		outw((CONF_MULTICAST+(6*i)) & ~31, ioaddr+SM_PTR);
 		outw(data[0], ioaddr+SHADOW(CONF_MULTICAST+(6*i)));
 		outw((CONF_MULTICAST+(6*i)+2) & ~31, ioaddr+SM_PTR);
diff --git a/drivers/net/fs_enet/mii-fec.c b/drivers/net/fs_enet/mii-fec.c
index ba75efc..f0014cf 100644
--- a/drivers/net/fs_enet/mii-fec.c
+++ b/drivers/net/fs_enet/mii-fec.c
@@ -194,7 +194,7 @@ static int __devinit fs_enet_mdio_probe(struct of_device *ofdev,
 
 	ret = of_address_to_resource(ofdev->node, 0, &res);
 	if (ret)
-		return ret;
+		goto out_res;
 
 	snprintf(new_bus->id, MII_BUS_ID_SIZE, "%x", res.start);
 
@@ -236,6 +236,7 @@ out_free_irqs:
 	kfree(new_bus->irq);
 out_unmap_regs:
 	iounmap(fec->fecp);
+out_res:
 out_fec:
 	kfree(fec);
 out_mii:
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 587afe7..6f22f06 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -138,6 +138,7 @@ static int gfar_poll(struct napi_struct *napi, int budget);
 static void gfar_netpoll(struct net_device *dev);
 #endif
 int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit);
+static int gfar_clean_tx_ring(struct net_device *dev);
 static int gfar_process_frame(struct net_device *dev, struct sk_buff *skb, int length);
 static void gfar_vlan_rx_register(struct net_device *netdev,
 		                struct vlan_group *grp);
@@ -1141,7 +1142,7 @@ static int gfar_close(struct net_device *dev)
 }
 
 /* Changes the mac address if the controller is not running. */
-int gfar_set_mac_address(struct net_device *dev)
+static int gfar_set_mac_address(struct net_device *dev)
 {
 	gfar_set_mac_for_addr(dev, 0, dev->dev_addr);
 
@@ -1260,7 +1261,7 @@ static void gfar_timeout(struct net_device *dev)
 }
 
 /* Interrupt Handler for Transmit complete */
-int gfar_clean_tx_ring(struct net_device *dev)
+static int gfar_clean_tx_ring(struct net_device *dev)
 {
 	struct txbd8 *bdp;
 	struct gfar_private *priv = netdev_priv(dev);
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index fd487be..27f37c8 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -782,5 +782,8 @@ extern void gfar_halt(struct net_device *dev);
 extern void gfar_phy_test(struct mii_bus *bus, struct phy_device *phydev,
 		int enable, u32 regnum, u32 read);
 void gfar_init_sysfs(struct net_device *dev);
+int gfar_local_mdio_write(struct gfar_mii __iomem *regs, int mii_id,
+			  int regnum, u16 value);
+int gfar_local_mdio_read(struct gfar_mii __iomem *regs, int mii_id, int regnum);
 
 #endif /* __GIANFAR_H */
diff --git a/drivers/net/gianfar_sysfs.c b/drivers/net/gianfar_sysfs.c
index 230878b..5116f68 100644
--- a/drivers/net/gianfar_sysfs.c
+++ b/drivers/net/gianfar_sysfs.c
@@ -103,10 +103,10 @@ static ssize_t gfar_set_rx_stash_size(struct device *dev,
 
 	spin_lock_irqsave(&priv->rxlock, flags);
 	if (length > priv->rx_buffer_size)
-		return count;
+		goto out;
 
 	if (length == priv->rx_stash_size)
-		return count;
+		goto out;
 
 	priv->rx_stash_size = length;
 
@@ -125,6 +125,7 @@ static ssize_t gfar_set_rx_stash_size(struct device *dev,
 
 	gfar_write(&priv->regs->attr, temp);
 
+out:
 	spin_unlock_irqrestore(&priv->rxlock, flags);
 
 	return count;
@@ -154,10 +155,10 @@ static ssize_t gfar_set_rx_stash_index(struct device *dev,
 
 	spin_lock_irqsave(&priv->rxlock, flags);
 	if (index > priv->rx_stash_size)
-		return count;
+		goto out;
 
 	if (index == priv->rx_stash_index)
-		return count;
+		goto out;
 
 	priv->rx_stash_index = index;
 
@@ -166,6 +167,7 @@ static ssize_t gfar_set_rx_stash_index(struct device *dev,
 	temp |= ATTRELI_EI(index);
 	gfar_write(&priv->regs->attreli, flags);
 
+out:
 	spin_unlock_irqrestore(&priv->rxlock, flags);
 
 	return count;
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 381b36e..b7915cd 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -91,6 +91,11 @@
  */
 #define PHY_ADDR_REG				0x0000
 #define SMI_REG					0x0004
+#define WINDOW_BASE(i)				(0x0200 + ((i) << 3))
+#define WINDOW_SIZE(i)				(0x0204 + ((i) << 3))
+#define WINDOW_REMAP_HIGH(i)			(0x0280 + ((i) << 2))
+#define WINDOW_BAR_ENABLE			0x0290
+#define WINDOW_PROTECT(i)			(0x0294 + ((i) << 4))
 
 /*
  * Per-port registers.
@@ -507,9 +512,23 @@ struct mv643xx_mib_counters {
 	u32 late_collision;
 };
 
+struct mv643xx_shared_private {
+	void __iomem *eth_base;
+
+	/* used to protect SMI_REG, which is shared across ports */
+	spinlock_t phy_lock;
+
+	u32 win_protect;
+
+	unsigned int t_clk;
+};
+
 struct mv643xx_private {
+	struct mv643xx_shared_private *shared;
 	int port_num;			/* User Ethernet port number	*/
 
+	struct mv643xx_shared_private *shared_smi;
+
 	u32 rx_sram_addr;		/* Base address of rx sram area */
 	u32 rx_sram_size;		/* Size of rx sram area		*/
 	u32 tx_sram_addr;		/* Base address of tx sram area */
@@ -614,19 +633,14 @@ static const struct ethtool_ops mv643xx_ethtool_ops;
 static char mv643xx_driver_name[] = "mv643xx_eth";
 static char mv643xx_driver_version[] = "1.0";
 
-static void __iomem *mv643xx_eth_base;
-
-/* used to protect SMI_REG, which is shared across ports */
-static DEFINE_SPINLOCK(mv643xx_eth_phy_lock);
-
 static inline u32 rdl(struct mv643xx_private *mp, int offset)
 {
-	return readl(mv643xx_eth_base + offset);
+	return readl(mp->shared->eth_base + offset);
 }
 
 static inline void wrl(struct mv643xx_private *mp, int offset, u32 data)
 {
-	writel(data, mv643xx_eth_base + offset);
+	writel(data, mp->shared->eth_base + offset);
 }
 
 /*
@@ -1119,7 +1133,6 @@ static irqreturn_t mv643xx_eth_int_handler(int irq, void *dev_id)
  *
  * INPUT:
  *	struct mv643xx_private *mp	Ethernet port
- *	unsigned int t_clk		t_clk of the MV-643xx chip in HZ units
  *	unsigned int delay		Delay in usec
  *
  * OUTPUT:
@@ -1130,10 +1143,10 @@ static irqreturn_t mv643xx_eth_int_handler(int irq, void *dev_id)
  *
  */
 static unsigned int eth_port_set_rx_coal(struct mv643xx_private *mp,
-					unsigned int t_clk, unsigned int delay)
+					unsigned int delay)
 {
 	unsigned int port_num = mp->port_num;
-	unsigned int coal = ((t_clk / 1000000) * delay) / 64;
+	unsigned int coal = ((mp->shared->t_clk / 1000000) * delay) / 64;
 
 	/* Set RX Coalescing mechanism */
 	wrl(mp, SDMA_CONFIG_REG(port_num),
@@ -1158,7 +1171,6 @@ static unsigned int eth_port_set_rx_coal(struct mv643xx_private *mp,
  *
  * INPUT:
  *	struct mv643xx_private *mp	Ethernet port
- *	unsigned int t_clk		t_clk of the MV-643xx chip in HZ units
  *	unsigned int delay		Delay in uSeconds
  *
  * OUTPUT:
@@ -1169,9 +1181,9 @@ static unsigned int eth_port_set_rx_coal(struct mv643xx_private *mp,
  *
  */
 static unsigned int eth_port_set_tx_coal(struct mv643xx_private *mp,
-					unsigned int t_clk, unsigned int delay)
+					unsigned int delay)
 {
-	unsigned int coal = ((t_clk / 1000000) * delay) / 64;
+	unsigned int coal = ((mp->shared->t_clk / 1000000) * delay) / 64;
 
 	/* Set TX Coalescing mechanism */
 	wrl(mp, TX_FIFO_URGENT_THRESHOLD_REG(mp->port_num), coal << 4);
@@ -1413,11 +1425,11 @@ static int mv643xx_eth_open(struct net_device *dev)
 
 #ifdef MV643XX_COAL
 	mp->rx_int_coal =
-		eth_port_set_rx_coal(mp, 133000000, MV643XX_RX_COAL);
+		eth_port_set_rx_coal(mp, MV643XX_RX_COAL);
 #endif
 
 	mp->tx_int_coal =
-		eth_port_set_tx_coal(mp, 133000000, MV643XX_TX_COAL);
+		eth_port_set_tx_coal(mp, MV643XX_TX_COAL);
 
 	/* Unmask phy and link status changes interrupts */
 	wrl(mp, INTERRUPT_EXTEND_MASK_REG(port_num), ETH_INT_UNMASK_ALL_EXT);
@@ -1827,6 +1839,11 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 		return -ENODEV;
 	}
 
+	if (pd->shared == NULL) {
+		printk(KERN_ERR "No mv643xx_eth_platform_data->shared\n");
+		return -ENODEV;
+	}
+
 	dev = alloc_etherdev(sizeof(struct mv643xx_private));
 	if (!dev)
 		return -ENOMEM;
@@ -1877,8 +1894,16 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 
 	spin_lock_init(&mp->lock);
 
+	mp->shared = platform_get_drvdata(pd->shared);
 	port_num = mp->port_num = pd->port_number;
 
+	if (mp->shared->win_protect)
+		wrl(mp, WINDOW_PROTECT(port_num), mp->shared->win_protect);
+
+	mp->shared_smi = mp->shared;
+	if (pd->shared_smi != NULL)
+		mp->shared_smi = platform_get_drvdata(pd->shared_smi);
+
 	/* set default config values */
 	eth_port_uc_addr_get(mp, dev->dev_addr);
 	mp->rx_ring_size = PORT_DEFAULT_RECEIVE_QUEUE_SIZE;
@@ -1983,30 +2008,91 @@ static int mv643xx_eth_remove(struct platform_device *pdev)
 	return 0;
 }
 
+static void mv643xx_eth_conf_mbus_windows(struct mv643xx_shared_private *msp,
+					  struct mbus_dram_target_info *dram)
+{
+	void __iomem *base = msp->eth_base;
+	u32 win_enable;
+	u32 win_protect;
+	int i;
+
+	for (i = 0; i < 6; i++) {
+		writel(0, base + WINDOW_BASE(i));
+		writel(0, base + WINDOW_SIZE(i));
+		if (i < 4)
+			writel(0, base + WINDOW_REMAP_HIGH(i));
+	}
+
+	win_enable = 0x3f;
+	win_protect = 0;
+
+	for (i = 0; i < dram->num_cs; i++) {
+		struct mbus_dram_window *cs = dram->cs + i;
+
+		writel((cs->base & 0xffff0000) |
+			(cs->mbus_attr << 8) |
+			dram->mbus_dram_target_id, base + WINDOW_BASE(i));
+		writel((cs->size - 1) & 0xffff0000, base + WINDOW_SIZE(i));
+
+		win_enable &= ~(1 << i);
+		win_protect |= 3 << (2 * i);
+	}
+
+	writel(win_enable, base + WINDOW_BAR_ENABLE);
+	msp->win_protect = win_protect;
+}
+
 static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 {
 	static int mv643xx_version_printed = 0;
+	struct mv643xx_eth_shared_platform_data *pd = pdev->dev.platform_data;
+	struct mv643xx_shared_private *msp;
 	struct resource *res;
+	int ret;
 
 	if (!mv643xx_version_printed++)
 		printk(KERN_NOTICE "MV-643xx 10/100/1000 Ethernet Driver\n");
 
+	ret = -EINVAL;
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	if (res == NULL)
-		return -ENODEV;
+		goto out;
 
-	mv643xx_eth_base = ioremap(res->start, res->end - res->start + 1);
-	if (mv643xx_eth_base == NULL)
-		return -ENOMEM;
+	ret = -ENOMEM;
+	msp = kmalloc(sizeof(*msp), GFP_KERNEL);
+	if (msp == NULL)
+		goto out;
+	memset(msp, 0, sizeof(*msp));
+
+	msp->eth_base = ioremap(res->start, res->end - res->start + 1);
+	if (msp->eth_base == NULL)
+		goto out_free;
+
+	spin_lock_init(&msp->phy_lock);
+	msp->t_clk = (pd != NULL && pd->t_clk != 0) ? pd->t_clk : 133000000;
+
+	platform_set_drvdata(pdev, msp);
+
+	/*
+	 * (Re-)program MBUS remapping windows if we are asked to.
+	 */
+	if (pd != NULL && pd->dram != NULL)
+		mv643xx_eth_conf_mbus_windows(msp, pd->dram);
 
 	return 0;
 
+out_free:
+	kfree(msp);
+out:
+	return ret;
 }
 
 static int mv643xx_eth_shared_remove(struct platform_device *pdev)
 {
-	iounmap(mv643xx_eth_base);
-	mv643xx_eth_base = NULL;
+	struct mv643xx_shared_private *msp = platform_get_drvdata(pdev);
+
+	iounmap(msp->eth_base);
+	kfree(msp);
 
 	return 0;
 }
@@ -2906,15 +2992,16 @@ static void eth_port_reset(struct mv643xx_private *mp)
 static void eth_port_read_smi_reg(struct mv643xx_private *mp,
 				unsigned int phy_reg, unsigned int *value)
 {
+	void __iomem *smi_reg = mp->shared_smi->eth_base + SMI_REG;
 	int phy_addr = ethernet_phy_get(mp);
 	unsigned long flags;
 	int i;
 
 	/* the SMI register is a shared resource */
-	spin_lock_irqsave(&mv643xx_eth_phy_lock, flags);
+	spin_lock_irqsave(&mp->shared_smi->phy_lock, flags);
 
 	/* wait for the SMI register to become available */
-	for (i = 0; rdl(mp, SMI_REG) & ETH_SMI_BUSY; i++) {
+	for (i = 0; readl(smi_reg) & ETH_SMI_BUSY; i++) {
 		if (i == PHY_WAIT_ITERATIONS) {
 			printk("%s: PHY busy timeout\n", mp->dev->name);
 			goto out;
@@ -2922,11 +3009,11 @@ static void eth_port_read_smi_reg(struct mv643xx_private *mp,
 		udelay(PHY_WAIT_MICRO_SECONDS);
 	}
 
-	wrl(mp, SMI_REG,
-		(phy_addr << 16) | (phy_reg << 21) | ETH_SMI_OPCODE_READ);
+	writel((phy_addr << 16) | (phy_reg << 21) | ETH_SMI_OPCODE_READ,
+		smi_reg);
 
 	/* now wait for the data to be valid */
-	for (i = 0; !(rdl(mp, SMI_REG) & ETH_SMI_READ_VALID); i++) {
+	for (i = 0; !(readl(smi_reg) & ETH_SMI_READ_VALID); i++) {
 		if (i == PHY_WAIT_ITERATIONS) {
 			printk("%s: PHY read timeout\n", mp->dev->name);
 			goto out;
@@ -2934,9 +3021,9 @@ static void eth_port_read_smi_reg(struct mv643xx_private *mp,
 		udelay(PHY_WAIT_MICRO_SECONDS);
 	}
 
-	*value = rdl(mp, SMI_REG) & 0xffff;
+	*value = readl(smi_reg) & 0xffff;
 out:
-	spin_unlock_irqrestore(&mv643xx_eth_phy_lock, flags);
+	spin_unlock_irqrestore(&mp->shared_smi->phy_lock, flags);
 }
 
 /*
@@ -2962,17 +3049,16 @@ out:
 static void eth_port_write_smi_reg(struct mv643xx_private *mp,
 				   unsigned int phy_reg, unsigned int value)
 {
-	int phy_addr;
-	int i;
+	void __iomem *smi_reg = mp->shared_smi->eth_base + SMI_REG;
+	int phy_addr = ethernet_phy_get(mp);
 	unsigned long flags;
-
-	phy_addr = ethernet_phy_get(mp);
+	int i;
 
 	/* the SMI register is a shared resource */
-	spin_lock_irqsave(&mv643xx_eth_phy_lock, flags);
+	spin_lock_irqsave(&mp->shared_smi->phy_lock, flags);
 
 	/* wait for the SMI register to become available */
-	for (i = 0; rdl(mp, SMI_REG) & ETH_SMI_BUSY; i++) {
+	for (i = 0; readl(smi_reg) & ETH_SMI_BUSY; i++) {
 		if (i == PHY_WAIT_ITERATIONS) {
 			printk("%s: PHY busy timeout\n", mp->dev->name);
 			goto out;
@@ -2980,10 +3066,10 @@ static void eth_port_write_smi_reg(struct mv643xx_private *mp,
 		udelay(PHY_WAIT_MICRO_SECONDS);
 	}
 
-	wrl(mp, SMI_REG, (phy_addr << 16) | (phy_reg << 21) |
-				ETH_SMI_OPCODE_WRITE | (value & 0xffff));
+	writel((phy_addr << 16) | (phy_reg << 21) |
+		ETH_SMI_OPCODE_WRITE | (value & 0xffff), smi_reg);
 out:
-	spin_unlock_irqrestore(&mv643xx_eth_phy_lock, flags);
+	spin_unlock_irqrestore(&mp->shared_smi->phy_lock, flags);
 }
 
 /*
diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index 4eb322e..a1c454d 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -22,12 +22,8 @@
  *************************************************************************/
 
 #define DRV_NAME	"pcnet32"
-#ifdef CONFIG_PCNET32_NAPI
-#define DRV_VERSION	"1.34-NAPI"
-#else
-#define DRV_VERSION	"1.34"
-#endif
-#define DRV_RELDATE	"14.Aug.2007"
+#define DRV_VERSION	"1.35"
+#define DRV_RELDATE	"21.Apr.2008"
 #define PFX		DRV_NAME ": "
 
 static const char *const version =
@@ -445,30 +441,24 @@ static struct pcnet32_access pcnet32_dwio = {
 
 static void pcnet32_netif_stop(struct net_device *dev)
 {
-#ifdef CONFIG_PCNET32_NAPI
 	struct pcnet32_private *lp = netdev_priv(dev);
-#endif
+
 	dev->trans_start = jiffies;
-#ifdef CONFIG_PCNET32_NAPI
 	napi_disable(&lp->napi);
-#endif
 	netif_tx_disable(dev);
 }
 
 static void pcnet32_netif_start(struct net_device *dev)
 {
-#ifdef CONFIG_PCNET32_NAPI
 	struct pcnet32_private *lp = netdev_priv(dev);
 	ulong ioaddr = dev->base_addr;
 	u16 val;
-#endif
+
 	netif_wake_queue(dev);
-#ifdef CONFIG_PCNET32_NAPI
 	val = lp->a.read_csr(ioaddr, CSR3);
 	val &= 0x00ff;
 	lp->a.write_csr(ioaddr, CSR3, val);
 	napi_enable(&lp->napi);
-#endif
 }
 
 /*
@@ -911,11 +901,7 @@ static int pcnet32_loopback_test(struct net_device *dev, uint64_t * data1)
 	rc = 1;			/* default to fail */
 
 	if (netif_running(dev))
-#ifdef CONFIG_PCNET32_NAPI
 		pcnet32_netif_stop(dev);
-#else
-		pcnet32_close(dev);
-#endif
 
 	spin_lock_irqsave(&lp->lock, flags);
 	lp->a.write_csr(ioaddr, CSR0, CSR0_STOP);	/* stop the chip */
@@ -1046,7 +1032,6 @@ static int pcnet32_loopback_test(struct net_device *dev, uint64_t * data1)
 	x = a->read_bcr(ioaddr, 32);	/* reset internal loopback */
 	a->write_bcr(ioaddr, 32, (x & ~0x0002));
 
-#ifdef CONFIG_PCNET32_NAPI
 	if (netif_running(dev)) {
 		pcnet32_netif_start(dev);
 		pcnet32_restart(dev, CSR0_NORMAL);
@@ -1055,16 +1040,6 @@ static int pcnet32_loopback_test(struct net_device *dev, uint64_t * data1)
 		lp->a.write_bcr(ioaddr, 20, 4);	/* return to 16bit mode */
 	}
 	spin_unlock_irqrestore(&lp->lock, flags);
-#else
-	if (netif_running(dev)) {
-		spin_unlock_irqrestore(&lp->lock, flags);
-		pcnet32_open(dev);
-	} else {
-		pcnet32_purge_rx_ring(dev);
-		lp->a.write_bcr(ioaddr, 20, 4);	/* return to 16bit mode */
-		spin_unlock_irqrestore(&lp->lock, flags);
-	}
-#endif
 
 	return (rc);
 }				/* end pcnet32_loopback_test  */
@@ -1270,11 +1245,7 @@ static void pcnet32_rx_entry(struct net_device *dev,
 	}
 	dev->stats.rx_bytes += skb->len;
 	skb->protocol = eth_type_trans(skb, dev);
-#ifdef CONFIG_PCNET32_NAPI
 	netif_receive_skb(skb);
-#else
-	netif_rx(skb);
-#endif
 	dev->last_rx = jiffies;
 	dev->stats.rx_packets++;
 	return;
@@ -1403,7 +1374,6 @@ static int pcnet32_tx(struct net_device *dev)
 	return must_restart;
 }
 
-#ifdef CONFIG_PCNET32_NAPI
 static int pcnet32_poll(struct napi_struct *napi, int budget)
 {
 	struct pcnet32_private *lp = container_of(napi, struct pcnet32_private, napi);
@@ -1442,7 +1412,6 @@ static int pcnet32_poll(struct napi_struct *napi, int budget)
 	}
 	return work_done;
 }
-#endif
 
 #define PCNET32_REGS_PER_PHY	32
 #define PCNET32_MAX_PHYS	32
@@ -1864,9 +1833,7 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 	/* napi.weight is used in both the napi and non-napi cases */
 	lp->napi.weight = lp->rx_ring_size / 2;
 
-#ifdef CONFIG_PCNET32_NAPI
 	netif_napi_add(dev, &lp->napi, pcnet32_poll, lp->rx_ring_size / 2);
-#endif
 
 	if (fdx && !(lp->options & PCNET32_PORT_ASEL) &&
 	    ((cards_found >= MAX_UNITS) || full_duplex[cards_found]))
@@ -2297,9 +2264,7 @@ static int pcnet32_open(struct net_device *dev)
 		goto err_free_ring;
 	}
 
-#ifdef CONFIG_PCNET32_NAPI
 	napi_enable(&lp->napi);
-#endif
 
 	/* Re-initialize the PCNET32, and start it when done. */
 	lp->a.write_csr(ioaddr, 1, (lp->init_dma_addr & 0xffff));
@@ -2623,7 +2588,6 @@ pcnet32_interrupt(int irq, void *dev_id)
 				       dev->name, csr0);
 			/* unlike for the lance, there is no restart needed */
 		}
-#ifdef CONFIG_PCNET32_NAPI
 		if (netif_rx_schedule_prep(dev, &lp->napi)) {
 			u16 val;
 			/* set interrupt masks */
@@ -2634,24 +2598,9 @@ pcnet32_interrupt(int irq, void *dev_id)
 			__netif_rx_schedule(dev, &lp->napi);
 			break;
 		}
-#else
-		pcnet32_rx(dev, lp->napi.weight);
-		if (pcnet32_tx(dev)) {
-			/* reset the chip to clear the error condition, then restart */
-			lp->a.reset(ioaddr);
-			lp->a.write_csr(ioaddr, CSR4, 0x0915); /* auto tx pad */
-			pcnet32_restart(dev, CSR0_START);
-			netif_wake_queue(dev);
-		}
-#endif
 		csr0 = lp->a.read_csr(ioaddr, CSR0);
 	}
 
-#ifndef CONFIG_PCNET32_NAPI
-	/* Set interrupt enable. */
-	lp->a.write_csr(ioaddr, CSR0, CSR0_INTEN);
-#endif
-
 	if (netif_msg_intr(lp))
 		printk(KERN_DEBUG "%s: exiting interrupt, csr0=%#4.4x.\n",
 		       dev->name, lp->a.read_csr(ioaddr, CSR0));
@@ -2670,9 +2619,7 @@ static int pcnet32_close(struct net_device *dev)
 	del_timer_sync(&lp->watchdog_timer);
 
 	netif_stop_queue(dev);
-#ifdef CONFIG_PCNET32_NAPI
 	napi_disable(&lp->napi);
-#endif
 
 	spin_lock_irqsave(&lp->lock, flags);
 
diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 3c18bb5..45cc291 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -547,7 +547,7 @@ static void phy_force_reduction(struct phy_device *phydev)
  * Must not be called from interrupt context, or while the
  * phydev->lock is held.
  */
-void phy_error(struct phy_device *phydev)
+static void phy_error(struct phy_device *phydev)
 {
 	mutex_lock(&phydev->lock);
 	phydev->state = PHY_HALTED;
diff --git a/drivers/net/tulip/uli526x.c b/drivers/net/tulip/uli526x.c
index a59c1f2..2511ca7 100644
--- a/drivers/net/tulip/uli526x.c
+++ b/drivers/net/tulip/uli526x.c
@@ -434,10 +434,6 @@ static int uli526x_open(struct net_device *dev)
 
 	ULI526X_DBUG(0, "uli526x_open", 0);
 
-	ret = request_irq(dev->irq, &uli526x_interrupt, IRQF_SHARED, dev->name, dev);
-	if (ret)
-		return ret;
-
 	/* system variable init */
 	db->cr6_data = CR6_DEFAULT | uli526x_cr6_user_set;
 	db->tx_packet_cnt = 0;
@@ -456,6 +452,10 @@ static int uli526x_open(struct net_device *dev)
 	/* Initialize ULI526X board */
 	uli526x_init(dev);
 
+	ret = request_irq(dev->irq, &uli526x_interrupt, IRQF_SHARED, dev->name, dev);
+	if (ret)
+		return ret;
+
 	/* Active System Interface */
 	netif_wake_queue(dev);
 
@@ -1368,6 +1368,12 @@ static void update_cr6(u32 cr6_data, unsigned long ioaddr)
  *	This setup frame initialize ULI526X address filter mode
  */
 
+#ifdef __BIG_ENDIAN
+#define FLT_SHIFT 16
+#else
+#define FLT_SHIFT 0
+#endif
+
 static void send_filter_frame(struct net_device *dev, int mc_cnt)
 {
 	struct uli526x_board_info *db = netdev_priv(dev);
@@ -1384,27 +1390,27 @@ static void send_filter_frame(struct net_device *dev, int mc_cnt)
 
 	/* Node address */
 	addrptr = (u16 *) dev->dev_addr;
-	*suptr++ = addrptr[0];
-	*suptr++ = addrptr[1];
-	*suptr++ = addrptr[2];
+	*suptr++ = addrptr[0] << FLT_SHIFT;
+	*suptr++ = addrptr[1] << FLT_SHIFT;
+	*suptr++ = addrptr[2] << FLT_SHIFT;
 
 	/* broadcast address */
-	*suptr++ = 0xffff;
-	*suptr++ = 0xffff;
-	*suptr++ = 0xffff;
+	*suptr++ = 0xffff << FLT_SHIFT;
+	*suptr++ = 0xffff << FLT_SHIFT;
+	*suptr++ = 0xffff << FLT_SHIFT;
 
 	/* fit the multicast address */
 	for (mcptr = dev->mc_list, i = 0; i < mc_cnt; i++, mcptr = mcptr->next) {
 		addrptr = (u16 *) mcptr->dmi_addr;
-		*suptr++ = addrptr[0];
-		*suptr++ = addrptr[1];
-		*suptr++ = addrptr[2];
+		*suptr++ = addrptr[0] << FLT_SHIFT;
+		*suptr++ = addrptr[1] << FLT_SHIFT;
+		*suptr++ = addrptr[2] << FLT_SHIFT;
 	}
 
 	for (; i<14; i++) {
-		*suptr++ = 0xffff;
-		*suptr++ = 0xffff;
-		*suptr++ = 0xffff;
+		*suptr++ = 0xffff << FLT_SHIFT;
+		*suptr++ = 0xffff << FLT_SHIFT;
+		*suptr++ = 0xffff << FLT_SHIFT;
 	}
 
 	/* prepare the setup frame */
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 281ce3d..ca0bdac 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -62,7 +62,6 @@
 #endif				/* UGETH_VERBOSE_DEBUG */
 #define UGETH_MSG_DEFAULT	(NETIF_MSG_IFUP << 1 ) - 1
 
-void uec_set_ethtool_ops(struct net_device *netdev);
 
 static DEFINE_SPINLOCK(ugeth_lock);
 
@@ -216,7 +215,8 @@ static struct list_head *dequeue(struct list_head *lh)
 	}
 }
 
-static struct sk_buff *get_new_skb(struct ucc_geth_private *ugeth, u8 *bd)
+static struct sk_buff *get_new_skb(struct ucc_geth_private *ugeth,
+		u8 __iomem *bd)
 {
 	struct sk_buff *skb = NULL;
 
@@ -236,21 +236,22 @@ static struct sk_buff *get_new_skb(struct ucc_geth_private *ugeth, u8 *bd)
 
 	skb->dev = ugeth->dev;
 
-	out_be32(&((struct qe_bd *)bd)->buf,
+	out_be32(&((struct qe_bd __iomem *)bd)->buf,
 		      dma_map_single(NULL,
 				     skb->data,
 				     ugeth->ug_info->uf_info.max_rx_buf_length +
 				     UCC_GETH_RX_DATA_BUF_ALIGNMENT,
 				     DMA_FROM_DEVICE));
 
-	out_be32((u32 *)bd, (R_E | R_I | (in_be32((u32 *)bd) & R_W)));
+	out_be32((u32 __iomem *)bd,
+			(R_E | R_I | (in_be32((u32 __iomem*)bd) & R_W)));
 
 	return skb;
 }
 
 static int rx_bd_buffer_set(struct ucc_geth_private *ugeth, u8 rxQ)
 {
-	u8 *bd;
+	u8 __iomem *bd;
 	u32 bd_status;
 	struct sk_buff *skb;
 	int i;
@@ -259,7 +260,7 @@ static int rx_bd_buffer_set(struct ucc_geth_private *ugeth, u8 rxQ)
 	i = 0;
 
 	do {
-		bd_status = in_be32((u32*)bd);
+		bd_status = in_be32((u32 __iomem *)bd);
 		skb = get_new_skb(ugeth, bd);
 
 		if (!skb)	/* If can not allocate data buffer,
@@ -277,7 +278,7 @@ static int rx_bd_buffer_set(struct ucc_geth_private *ugeth, u8 rxQ)
 }
 
 static int fill_init_enet_entries(struct ucc_geth_private *ugeth,
-				  volatile u32 *p_start,
+				  u32 *p_start,
 				  u8 num_entries,
 				  u32 thread_size,
 				  u32 thread_alignment,
@@ -316,7 +317,7 @@ static int fill_init_enet_entries(struct ucc_geth_private *ugeth,
 }
 
 static int return_init_enet_entries(struct ucc_geth_private *ugeth,
-				    volatile u32 *p_start,
+				    u32 *p_start,
 				    u8 num_entries,
 				    enum qe_risc_allocation risc,
 				    int skip_page_for_first_entry)
@@ -326,21 +327,22 @@ static int return_init_enet_entries(struct ucc_geth_private *ugeth,
 	int snum;
 
 	for (i = 0; i < num_entries; i++) {
+		u32 val = *p_start;
+
 		/* Check that this entry was actually valid --
 		needed in case failed in allocations */
-		if ((*p_start & ENET_INIT_PARAM_RISC_MASK) == risc) {
+		if ((val & ENET_INIT_PARAM_RISC_MASK) == risc) {
 			snum =
-			    (u32) (*p_start & ENET_INIT_PARAM_SNUM_MASK) >>
+			    (u32) (val & ENET_INIT_PARAM_SNUM_MASK) >>
 			    ENET_INIT_PARAM_SNUM_SHIFT;
 			qe_put_snum((u8) snum);
 			if (!((i == 0) && skip_page_for_first_entry)) {
 			/* First entry of Rx does not have page */
 				init_enet_offset =
-				    (in_be32(p_start) &
-				     ENET_INIT_PARAM_PTR_MASK);
+				    (val & ENET_INIT_PARAM_PTR_MASK);
 				qe_muram_free(init_enet_offset);
 			}
-			*(p_start++) = 0;	/* Just for cosmetics */
+			*p_start++ = 0;
 		}
 	}
 
@@ -349,7 +351,7 @@ static int return_init_enet_entries(struct ucc_geth_private *ugeth,
 
 #ifdef DEBUG
 static int dump_init_enet_entries(struct ucc_geth_private *ugeth,
-				  volatile u32 *p_start,
+				  u32 __iomem *p_start,
 				  u8 num_entries,
 				  u32 thread_size,
 				  enum qe_risc_allocation risc,
@@ -360,11 +362,13 @@ static int dump_init_enet_entries(struct ucc_geth_private *ugeth,
 	int snum;
 
 	for (i = 0; i < num_entries; i++) {
+		u32 val = in_be32(p_start);
+
 		/* Check that this entry was actually valid --
 		needed in case failed in allocations */
-		if ((*p_start & ENET_INIT_PARAM_RISC_MASK) == risc) {
+		if ((val & ENET_INIT_PARAM_RISC_MASK) == risc) {
 			snum =
-			    (u32) (*p_start & ENET_INIT_PARAM_SNUM_MASK) >>
+			    (u32) (val & ENET_INIT_PARAM_SNUM_MASK) >>
 			    ENET_INIT_PARAM_SNUM_SHIFT;
 			qe_put_snum((u8) snum);
 			if (!((i == 0) && skip_page_for_first_entry)) {
@@ -440,7 +444,7 @@ static int hw_add_addr_in_paddr(struct ucc_geth_private *ugeth,
 
 static int hw_clear_addr_in_paddr(struct ucc_geth_private *ugeth, u8 paddr_num)
 {
-	struct ucc_geth_82xx_address_filtering_pram *p_82xx_addr_filt;
+	struct ucc_geth_82xx_address_filtering_pram __iomem *p_82xx_addr_filt;
 
 	if (!(paddr_num < NUM_OF_PADDRS)) {
 		ugeth_warn("%s: Illagel paddr_num.", __FUNCTION__);
@@ -448,7 +452,7 @@ static int hw_clear_addr_in_paddr(struct ucc_geth_private *ugeth, u8 paddr_num)
 	}
 
 	p_82xx_addr_filt =
-	    (struct ucc_geth_82xx_address_filtering_pram *) ugeth->p_rx_glbl_pram->
+	    (struct ucc_geth_82xx_address_filtering_pram __iomem *) ugeth->p_rx_glbl_pram->
 	    addressfiltering;
 
 	/* Writing address ff.ff.ff.ff.ff.ff disables address
@@ -463,11 +467,11 @@ static int hw_clear_addr_in_paddr(struct ucc_geth_private *ugeth, u8 paddr_num)
 static void hw_add_addr_in_hash(struct ucc_geth_private *ugeth,
                                 u8 *p_enet_addr)
 {
-	struct ucc_geth_82xx_address_filtering_pram *p_82xx_addr_filt;
+	struct ucc_geth_82xx_address_filtering_pram __iomem *p_82xx_addr_filt;
 	u32 cecr_subblock;
 
 	p_82xx_addr_filt =
-	    (struct ucc_geth_82xx_address_filtering_pram *) ugeth->p_rx_glbl_pram->
+	    (struct ucc_geth_82xx_address_filtering_pram __iomem *) ugeth->p_rx_glbl_pram->
 	    addressfiltering;
 
 	cecr_subblock =
@@ -487,7 +491,7 @@ static void hw_add_addr_in_hash(struct ucc_geth_private *ugeth,
 static void magic_packet_detection_enable(struct ucc_geth_private *ugeth)
 {
 	struct ucc_fast_private *uccf;
-	struct ucc_geth *ug_regs;
+	struct ucc_geth __iomem *ug_regs;
 	u32 maccfg2, uccm;
 
 	uccf = ugeth->uccf;
@@ -507,7 +511,7 @@ static void magic_packet_detection_enable(struct ucc_geth_private *ugeth)
 static void magic_packet_detection_disable(struct ucc_geth_private *ugeth)
 {
 	struct ucc_fast_private *uccf;
-	struct ucc_geth *ug_regs;
+	struct ucc_geth __iomem *ug_regs;
 	u32 maccfg2, uccm;
 
 	uccf = ugeth->uccf;
@@ -538,13 +542,13 @@ static void get_statistics(struct ucc_geth_private *ugeth,
 			   rx_firmware_statistics,
 			   struct ucc_geth_hardware_statistics *hardware_statistics)
 {
-	struct ucc_fast *uf_regs;
-	struct ucc_geth *ug_regs;
+	struct ucc_fast __iomem *uf_regs;
+	struct ucc_geth __iomem *ug_regs;
 	struct ucc_geth_tx_firmware_statistics_pram *p_tx_fw_statistics_pram;
 	struct ucc_geth_rx_firmware_statistics_pram *p_rx_fw_statistics_pram;
 
 	ug_regs = ugeth->ug_regs;
-	uf_regs = (struct ucc_fast *) ug_regs;
+	uf_regs = (struct ucc_fast __iomem *) ug_regs;
 	p_tx_fw_statistics_pram = ugeth->p_tx_fw_statistics_pram;
 	p_rx_fw_statistics_pram = ugeth->p_rx_fw_statistics_pram;
 
@@ -1132,9 +1136,9 @@ static void dump_regs(struct ucc_geth_private *ugeth)
 }
 #endif /* DEBUG */
 
-static void init_default_reg_vals(volatile u32 *upsmr_register,
-				  volatile u32 *maccfg1_register,
-				  volatile u32 *maccfg2_register)
+static void init_default_reg_vals(u32 __iomem *upsmr_register,
+				  u32 __iomem *maccfg1_register,
+				  u32 __iomem *maccfg2_register)
 {
 	out_be32(upsmr_register, UCC_GETH_UPSMR_INIT);
 	out_be32(maccfg1_register, UCC_GETH_MACCFG1_INIT);
@@ -1148,7 +1152,7 @@ static int init_half_duplex_params(int alt_beb,
 				   u8 alt_beb_truncation,
 				   u8 max_retransmissions,
 				   u8 collision_window,
-				   volatile u32 *hafdup_register)
+				   u32 __iomem *hafdup_register)
 {
 	u32 value = 0;
 
@@ -1180,7 +1184,7 @@ static int init_inter_frame_gap_params(u8 non_btb_cs_ipg,
 				       u8 non_btb_ipg,
 				       u8 min_ifg,
 				       u8 btb_ipg,
-				       volatile u32 *ipgifg_register)
+				       u32 __iomem *ipgifg_register)
 {
 	u32 value = 0;
 
@@ -1215,9 +1219,9 @@ int init_flow_control_params(u32 automatic_flow_control_mode,
 				    int tx_flow_control_enable,
 				    u16 pause_period,
 				    u16 extension_field,
-				    volatile u32 *upsmr_register,
-				    volatile u32 *uempr_register,
-				    volatile u32 *maccfg1_register)
+				    u32 __iomem *upsmr_register,
+				    u32 __iomem *uempr_register,
+				    u32 __iomem *maccfg1_register)
 {
 	u32 value = 0;
 
@@ -1243,8 +1247,8 @@ int init_flow_control_params(u32 automatic_flow_control_mode,
 
 static int init_hw_statistics_gathering_mode(int enable_hardware_statistics,
 					     int auto_zero_hardware_statistics,
-					     volatile u32 *upsmr_register,
-					     volatile u16 *uescr_register)
+					     u32 __iomem *upsmr_register,
+					     u16 __iomem *uescr_register)
 {
 	u32 upsmr_value = 0;
 	u16 uescr_value = 0;
@@ -1270,12 +1274,12 @@ static int init_hw_statistics_gathering_mode(int enable_hardware_statistics,
 static int init_firmware_statistics_gathering_mode(int
 		enable_tx_firmware_statistics,
 		int enable_rx_firmware_statistics,
-		volatile u32 *tx_rmon_base_ptr,
+		u32 __iomem *tx_rmon_base_ptr,
 		u32 tx_firmware_statistics_structure_address,
-		volatile u32 *rx_rmon_base_ptr,
+		u32 __iomem *rx_rmon_base_ptr,
 		u32 rx_firmware_statistics_structure_address,
-		volatile u16 *temoder_register,
-		volatile u32 *remoder_register)
+		u16 __iomem *temoder_register,
+		u32 __iomem *remoder_register)
 {
 	/* Note: this function does not check if */
 	/* the parameters it receives are NULL   */
@@ -1307,8 +1311,8 @@ static int init_mac_station_addr_regs(u8 address_byte_0,
 				      u8 address_byte_3,
 				      u8 address_byte_4,
 				      u8 address_byte_5,
-				      volatile u32 *macstnaddr1_register,
-				      volatile u32 *macstnaddr2_register)
+				      u32 __iomem *macstnaddr1_register,
+				      u32 __iomem *macstnaddr2_register)
 {
 	u32 value = 0;
 
@@ -1344,7 +1348,7 @@ static int init_mac_station_addr_regs(u8 address_byte_0,
 }
 
 static int init_check_frame_length_mode(int length_check,
-					volatile u32 *maccfg2_register)
+					u32 __iomem *maccfg2_register)
 {
 	u32 value = 0;
 
@@ -1360,7 +1364,7 @@ static int init_check_frame_length_mode(int length_check,
 }
 
 static int init_preamble_length(u8 preamble_length,
-				volatile u32 *maccfg2_register)
+				u32 __iomem *maccfg2_register)
 {
 	u32 value = 0;
 
@@ -1376,7 +1380,7 @@ static int init_preamble_length(u8 preamble_length,
 
 static int init_rx_parameters(int reject_broadcast,
 			      int receive_short_frames,
-			      int promiscuous, volatile u32 *upsmr_register)
+			      int promiscuous, u32 __iomem *upsmr_register)
 {
 	u32 value = 0;
 
@@ -1403,7 +1407,7 @@ static int init_rx_parameters(int reject_broadcast,
 }
 
 static int init_max_rx_buff_len(u16 max_rx_buf_len,
-				volatile u16 *mrblr_register)
+				u16 __iomem *mrblr_register)
 {
 	/* max_rx_buf_len value must be a multiple of 128 */
 	if ((max_rx_buf_len == 0)
@@ -1415,8 +1419,8 @@ static int init_max_rx_buff_len(u16 max_rx_buf_len,
 }
 
 static int init_min_frame_len(u16 min_frame_length,
-			      volatile u16 *minflr_register,
-			      volatile u16 *mrblr_register)
+			      u16 __iomem *minflr_register,
+			      u16 __iomem *mrblr_register)
 {
 	u16 mrblr_value = 0;
 
@@ -1431,8 +1435,8 @@ static int init_min_frame_len(u16 min_frame_length,
 static int adjust_enet_interface(struct ucc_geth_private *ugeth)
 {
 	struct ucc_geth_info *ug_info;
-	struct ucc_geth *ug_regs;
-	struct ucc_fast *uf_regs;
+	struct ucc_geth __iomem *ug_regs;
+	struct ucc_fast __iomem *uf_regs;
 	int ret_val;
 	u32 upsmr, maccfg2, tbiBaseAddress;
 	u16 value;
@@ -1517,8 +1521,8 @@ static int adjust_enet_interface(struct ucc_geth_private *ugeth)
 static void adjust_link(struct net_device *dev)
 {
 	struct ucc_geth_private *ugeth = netdev_priv(dev);
-	struct ucc_geth *ug_regs;
-	struct ucc_fast *uf_regs;
+	struct ucc_geth __iomem *ug_regs;
+	struct ucc_fast __iomem *uf_regs;
 	struct phy_device *phydev = ugeth->phydev;
 	unsigned long flags;
 	int new_state = 0;
@@ -1678,9 +1682,9 @@ static int ugeth_graceful_stop_rx(struct ucc_geth_private * ugeth)
 	uccf = ugeth->uccf;
 
 	/* Clear acknowledge bit */
-	temp = ugeth->p_rx_glbl_pram->rxgstpack;
+	temp = in_8(&ugeth->p_rx_glbl_pram->rxgstpack);
 	temp &= ~GRACEFUL_STOP_ACKNOWLEDGE_RX;
-	ugeth->p_rx_glbl_pram->rxgstpack = temp;
+	out_8(&ugeth->p_rx_glbl_pram->rxgstpack, temp);
 
 	/* Keep issuing command and checking acknowledge bit until
 	it is asserted, according to spec */
@@ -1692,7 +1696,7 @@ static int ugeth_graceful_stop_rx(struct ucc_geth_private * ugeth)
 		qe_issue_cmd(QE_GRACEFUL_STOP_RX, cecr_subblock,
 			     QE_CR_PROTOCOL_ETHERNET, 0);
 
-		temp = ugeth->p_rx_glbl_pram->rxgstpack;
+		temp = in_8(&ugeth->p_rx_glbl_pram->rxgstpack);
 	} while (!(temp & GRACEFUL_STOP_ACKNOWLEDGE_RX));
 
 	uccf->stopped_rx = 1;
@@ -1991,19 +1995,20 @@ static int ugeth_82xx_filtering_clear_all_addr_in_hash(struct ucc_geth_private *
 						       enum enet_addr_type
 						       enet_addr_type)
 {
-	struct ucc_geth_82xx_address_filtering_pram *p_82xx_addr_filt;
+	struct ucc_geth_82xx_address_filtering_pram __iomem *p_82xx_addr_filt;
 	struct ucc_fast_private *uccf;
 	enum comm_dir comm_dir;
 	struct list_head *p_lh;
 	u16 i, num;
-	u32 *addr_h, *addr_l;
+	u32 __iomem *addr_h;
+	u32 __iomem *addr_l;
 	u8 *p_counter;
 
 	uccf = ugeth->uccf;
 
 	p_82xx_addr_filt =
-	    (struct ucc_geth_82xx_address_filtering_pram *) ugeth->p_rx_glbl_pram->
-	    addressfiltering;
+	    (struct ucc_geth_82xx_address_filtering_pram __iomem *)
+	    ugeth->p_rx_glbl_pram->addressfiltering;
 
 	if (enet_addr_type == ENET_ADDR_TYPE_GROUP) {
 		addr_h = &(p_82xx_addr_filt->gaddr_h);
@@ -2079,7 +2084,7 @@ static int ugeth_82xx_filtering_clear_addr_in_paddr(struct ucc_geth_private *uge
 static void ucc_geth_memclean(struct ucc_geth_private *ugeth)
 {
 	u16 i, j;
-	u8 *bd;
+	u8 __iomem *bd;
 
 	if (!ugeth)
 		return;
@@ -2154,8 +2159,8 @@ static void ucc_geth_memclean(struct ucc_geth_private *ugeth)
 		for (j = 0; j < ugeth->ug_info->bdRingLenTx[i]; j++) {
 			if (ugeth->tx_skbuff[i][j]) {
 				dma_unmap_single(NULL,
-						 ((struct qe_bd *)bd)->buf,
-						 (in_be32((u32 *)bd) &
+						 in_be32(&((struct qe_bd __iomem *)bd)->buf),
+						 (in_be32((u32 __iomem *)bd) &
 						  BD_LENGTH_MASK),
 						 DMA_TO_DEVICE);
 				dev_kfree_skb_any(ugeth->tx_skbuff[i][j]);
@@ -2182,7 +2187,7 @@ static void ucc_geth_memclean(struct ucc_geth_private *ugeth)
 			for (j = 0; j < ugeth->ug_info->bdRingLenRx[i]; j++) {
 				if (ugeth->rx_skbuff[i][j]) {
 					dma_unmap_single(NULL,
-						((struct qe_bd *)bd)->buf,
+						in_be32(&((struct qe_bd __iomem *)bd)->buf),
 						ugeth->ug_info->
 						uf_info.max_rx_buf_length +
 						UCC_GETH_RX_DATA_BUF_ALIGNMENT,
@@ -2218,8 +2223,8 @@ static void ucc_geth_set_multi(struct net_device *dev)
 {
 	struct ucc_geth_private *ugeth;
 	struct dev_mc_list *dmi;
-	struct ucc_fast *uf_regs;
-	struct ucc_geth_82xx_address_filtering_pram *p_82xx_addr_filt;
+	struct ucc_fast __iomem *uf_regs;
+	struct ucc_geth_82xx_address_filtering_pram __iomem *p_82xx_addr_filt;
 	int i;
 
 	ugeth = netdev_priv(dev);
@@ -2228,14 +2233,14 @@ static void ucc_geth_set_multi(struct net_device *dev)
 
 	if (dev->flags & IFF_PROMISC) {
 
-		uf_regs->upsmr |= UPSMR_PRO;
+		out_be32(&uf_regs->upsmr, in_be32(&uf_regs->upsmr) | UPSMR_PRO);
 
 	} else {
 
-		uf_regs->upsmr &= ~UPSMR_PRO;
+		out_be32(&uf_regs->upsmr, in_be32(&uf_regs->upsmr)&~UPSMR_PRO);
 
 		p_82xx_addr_filt =
-		    (struct ucc_geth_82xx_address_filtering_pram *) ugeth->
+		    (struct ucc_geth_82xx_address_filtering_pram __iomem *) ugeth->
 		    p_rx_glbl_pram->addressfiltering;
 
 		if (dev->flags & IFF_ALLMULTI) {
@@ -2270,7 +2275,7 @@ static void ucc_geth_set_multi(struct net_device *dev)
 
 static void ucc_geth_stop(struct ucc_geth_private *ugeth)
 {
-	struct ucc_geth *ug_regs = ugeth->ug_regs;
+	struct ucc_geth __iomem *ug_regs = ugeth->ug_regs;
 	struct phy_device *phydev = ugeth->phydev;
 	u32 tempval;
 
@@ -2419,20 +2424,20 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 		return -ENOMEM;
 	}
 
-	ugeth->ug_regs = (struct ucc_geth *) ioremap(uf_info->regs, sizeof(struct ucc_geth));
+	ugeth->ug_regs = (struct ucc_geth __iomem *) ioremap(uf_info->regs, sizeof(struct ucc_geth));
 
 	return 0;
 }
 
 static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 {
-	struct ucc_geth_82xx_address_filtering_pram *p_82xx_addr_filt;
-	struct ucc_geth_init_pram *p_init_enet_pram;
+	struct ucc_geth_82xx_address_filtering_pram __iomem *p_82xx_addr_filt;
+	struct ucc_geth_init_pram __iomem *p_init_enet_pram;
 	struct ucc_fast_private *uccf;
 	struct ucc_geth_info *ug_info;
 	struct ucc_fast_info *uf_info;
-	struct ucc_fast *uf_regs;
-	struct ucc_geth *ug_regs;
+	struct ucc_fast __iomem *uf_regs;
+	struct ucc_geth __iomem *ug_regs;
 	int ret_val = -EINVAL;
 	u32 remoder = UCC_GETH_REMODER_INIT;
 	u32 init_enet_pram_offset, cecr_subblock, command, maccfg1;
@@ -2440,7 +2445,8 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	u16 temoder = UCC_GETH_TEMODER_INIT;
 	u16 test;
 	u8 function_code = 0;
-	u8 *bd, *endOfRing;
+	u8 __iomem *bd;
+	u8 __iomem *endOfRing;
 	u8 numThreadsRxNumerical, numThreadsTxNumerical;
 
 	ugeth_vdbg("%s: IN", __FUNCTION__);
@@ -2602,11 +2608,11 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			if (UCC_GETH_TX_BD_RING_ALIGNMENT > 4)
 				align = UCC_GETH_TX_BD_RING_ALIGNMENT;
 			ugeth->tx_bd_ring_offset[j] =
-				kmalloc((u32) (length + align), GFP_KERNEL);
+				(u32) kmalloc((u32) (length + align), GFP_KERNEL);
 
 			if (ugeth->tx_bd_ring_offset[j] != 0)
 				ugeth->p_tx_bd_ring[j] =
-					(void*)((ugeth->tx_bd_ring_offset[j] +
+					(u8 __iomem *)((ugeth->tx_bd_ring_offset[j] +
 					align) & ~(align - 1));
 		} else if (uf_info->bd_mem_part == MEM_PART_MURAM) {
 			ugeth->tx_bd_ring_offset[j] =
@@ -2614,7 +2620,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 					   UCC_GETH_TX_BD_RING_ALIGNMENT);
 			if (!IS_ERR_VALUE(ugeth->tx_bd_ring_offset[j]))
 				ugeth->p_tx_bd_ring[j] =
-				    (u8 *) qe_muram_addr(ugeth->
+				    (u8 __iomem *) qe_muram_addr(ugeth->
 							 tx_bd_ring_offset[j]);
 		}
 		if (!ugeth->p_tx_bd_ring[j]) {
@@ -2626,8 +2632,8 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			return -ENOMEM;
 		}
 		/* Zero unused end of bd ring, according to spec */
-		memset(ugeth->p_tx_bd_ring[j] +
-		       ug_info->bdRingLenTx[j] * sizeof(struct qe_bd), 0,
+		memset_io((void __iomem *)(ugeth->p_tx_bd_ring[j] +
+		       ug_info->bdRingLenTx[j] * sizeof(struct qe_bd)), 0,
 		       length - ug_info->bdRingLenTx[j] * sizeof(struct qe_bd));
 	}
 
@@ -2639,10 +2645,10 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			if (UCC_GETH_RX_BD_RING_ALIGNMENT > 4)
 				align = UCC_GETH_RX_BD_RING_ALIGNMENT;
 			ugeth->rx_bd_ring_offset[j] =
-				kmalloc((u32) (length + align), GFP_KERNEL);
+				(u32) kmalloc((u32) (length + align), GFP_KERNEL);
 			if (ugeth->rx_bd_ring_offset[j] != 0)
 				ugeth->p_rx_bd_ring[j] =
-					(void*)((ugeth->rx_bd_ring_offset[j] +
+					(u8 __iomem *)((ugeth->rx_bd_ring_offset[j] +
 					align) & ~(align - 1));
 		} else if (uf_info->bd_mem_part == MEM_PART_MURAM) {
 			ugeth->rx_bd_ring_offset[j] =
@@ -2650,7 +2656,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 					   UCC_GETH_RX_BD_RING_ALIGNMENT);
 			if (!IS_ERR_VALUE(ugeth->rx_bd_ring_offset[j]))
 				ugeth->p_rx_bd_ring[j] =
-				    (u8 *) qe_muram_addr(ugeth->
+				    (u8 __iomem *) qe_muram_addr(ugeth->
 							 rx_bd_ring_offset[j]);
 		}
 		if (!ugeth->p_rx_bd_ring[j]) {
@@ -2685,14 +2691,14 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		bd = ugeth->confBd[j] = ugeth->txBd[j] = ugeth->p_tx_bd_ring[j];
 		for (i = 0; i < ug_info->bdRingLenTx[j]; i++) {
 			/* clear bd buffer */
-			out_be32(&((struct qe_bd *)bd)->buf, 0);
+			out_be32(&((struct qe_bd __iomem *)bd)->buf, 0);
 			/* set bd status and length */
-			out_be32((u32 *)bd, 0);
+			out_be32((u32 __iomem *)bd, 0);
 			bd += sizeof(struct qe_bd);
 		}
 		bd -= sizeof(struct qe_bd);
 		/* set bd status and length */
-		out_be32((u32 *)bd, T_W);	/* for last BD set Wrap bit */
+		out_be32((u32 __iomem *)bd, T_W); /* for last BD set Wrap bit */
 	}
 
 	/* Init Rx bds */
@@ -2717,14 +2723,14 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		bd = ugeth->rxBd[j] = ugeth->p_rx_bd_ring[j];
 		for (i = 0; i < ug_info->bdRingLenRx[j]; i++) {
 			/* set bd status and length */
-			out_be32((u32 *)bd, R_I);
+			out_be32((u32 __iomem *)bd, R_I);
 			/* clear bd buffer */
-			out_be32(&((struct qe_bd *)bd)->buf, 0);
+			out_be32(&((struct qe_bd __iomem *)bd)->buf, 0);
 			bd += sizeof(struct qe_bd);
 		}
 		bd -= sizeof(struct qe_bd);
 		/* set bd status and length */
-		out_be32((u32 *)bd, R_W); /* for last BD set Wrap bit */
+		out_be32((u32 __iomem *)bd, R_W); /* for last BD set Wrap bit */
 	}
 
 	/*
@@ -2744,10 +2750,10 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		return -ENOMEM;
 	}
 	ugeth->p_tx_glbl_pram =
-	    (struct ucc_geth_tx_global_pram *) qe_muram_addr(ugeth->
+	    (struct ucc_geth_tx_global_pram __iomem *) qe_muram_addr(ugeth->
 							tx_glbl_pram_offset);
 	/* Zero out p_tx_glbl_pram */
-	memset(ugeth->p_tx_glbl_pram, 0, sizeof(struct ucc_geth_tx_global_pram));
+	memset_io((void __iomem *)ugeth->p_tx_glbl_pram, 0, sizeof(struct ucc_geth_tx_global_pram));
 
 	/* Fill global PRAM */
 
@@ -2768,7 +2774,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	}
 
 	ugeth->p_thread_data_tx =
-	    (struct ucc_geth_thread_data_tx *) qe_muram_addr(ugeth->
+	    (struct ucc_geth_thread_data_tx __iomem *) qe_muram_addr(ugeth->
 							thread_dat_tx_offset);
 	out_be32(&ugeth->p_tx_glbl_pram->tqptr, ugeth->thread_dat_tx_offset);
 
@@ -2779,7 +2785,8 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 
 	/* iphoffset */
 	for (i = 0; i < TX_IP_OFFSET_ENTRY_MAX; i++)
-		ugeth->p_tx_glbl_pram->iphoffset[i] = ug_info->iphoffset[i];
+		out_8(&ugeth->p_tx_glbl_pram->iphoffset[i],
+				ug_info->iphoffset[i]);
 
 	/* SQPTR */
 	/* Size varies with number of Tx queues */
@@ -2797,7 +2804,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	}
 
 	ugeth->p_send_q_mem_reg =
-	    (struct ucc_geth_send_queue_mem_region *) qe_muram_addr(ugeth->
+	    (struct ucc_geth_send_queue_mem_region __iomem *) qe_muram_addr(ugeth->
 			send_q_mem_reg_offset);
 	out_be32(&ugeth->p_tx_glbl_pram->sqptr, ugeth->send_q_mem_reg_offset);
 
@@ -2841,25 +2848,26 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		}
 
 		ugeth->p_scheduler =
-		    (struct ucc_geth_scheduler *) qe_muram_addr(ugeth->
+		    (struct ucc_geth_scheduler __iomem *) qe_muram_addr(ugeth->
 							   scheduler_offset);
 		out_be32(&ugeth->p_tx_glbl_pram->schedulerbasepointer,
 			 ugeth->scheduler_offset);
 		/* Zero out p_scheduler */
-		memset(ugeth->p_scheduler, 0, sizeof(struct ucc_geth_scheduler));
+		memset_io((void __iomem *)ugeth->p_scheduler, 0, sizeof(struct ucc_geth_scheduler));
 
 		/* Set values in scheduler */
 		out_be32(&ugeth->p_scheduler->mblinterval,
 			 ug_info->mblinterval);
 		out_be16(&ugeth->p_scheduler->nortsrbytetime,
 			 ug_info->nortsrbytetime);
-		ugeth->p_scheduler->fracsiz = ug_info->fracsiz;
-		ugeth->p_scheduler->strictpriorityq = ug_info->strictpriorityq;
-		ugeth->p_scheduler->txasap = ug_info->txasap;
-		ugeth->p_scheduler->extrabw = ug_info->extrabw;
+		out_8(&ugeth->p_scheduler->fracsiz, ug_info->fracsiz);
+		out_8(&ugeth->p_scheduler->strictpriorityq,
+				ug_info->strictpriorityq);
+		out_8(&ugeth->p_scheduler->txasap, ug_info->txasap);
+		out_8(&ugeth->p_scheduler->extrabw, ug_info->extrabw);
 		for (i = 0; i < NUM_TX_QUEUES; i++)
-			ugeth->p_scheduler->weightfactor[i] =
-			    ug_info->weightfactor[i];
+			out_8(&ugeth->p_scheduler->weightfactor[i],
+			    ug_info->weightfactor[i]);
 
 		/* Set pointers to cpucount registers in scheduler */
 		ugeth->p_cpucount[0] = &(ugeth->p_scheduler->cpucount0);
@@ -2890,10 +2898,10 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			return -ENOMEM;
 		}
 		ugeth->p_tx_fw_statistics_pram =
-		    (struct ucc_geth_tx_firmware_statistics_pram *)
+		    (struct ucc_geth_tx_firmware_statistics_pram __iomem *)
 		    qe_muram_addr(ugeth->tx_fw_statistics_pram_offset);
 		/* Zero out p_tx_fw_statistics_pram */
-		memset(ugeth->p_tx_fw_statistics_pram,
+		memset_io((void __iomem *)ugeth->p_tx_fw_statistics_pram,
 		       0, sizeof(struct ucc_geth_tx_firmware_statistics_pram));
 	}
 
@@ -2930,10 +2938,10 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		return -ENOMEM;
 	}
 	ugeth->p_rx_glbl_pram =
-	    (struct ucc_geth_rx_global_pram *) qe_muram_addr(ugeth->
+	    (struct ucc_geth_rx_global_pram __iomem *) qe_muram_addr(ugeth->
 							rx_glbl_pram_offset);
 	/* Zero out p_rx_glbl_pram */
-	memset(ugeth->p_rx_glbl_pram, 0, sizeof(struct ucc_geth_rx_global_pram));
+	memset_io((void __iomem *)ugeth->p_rx_glbl_pram, 0, sizeof(struct ucc_geth_rx_global_pram));
 
 	/* Fill global PRAM */
 
@@ -2953,7 +2961,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	}
 
 	ugeth->p_thread_data_rx =
-	    (struct ucc_geth_thread_data_rx *) qe_muram_addr(ugeth->
+	    (struct ucc_geth_thread_data_rx __iomem *) qe_muram_addr(ugeth->
 							thread_dat_rx_offset);
 	out_be32(&ugeth->p_rx_glbl_pram->rqptr, ugeth->thread_dat_rx_offset);
 
@@ -2976,10 +2984,10 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			return -ENOMEM;
 		}
 		ugeth->p_rx_fw_statistics_pram =
-		    (struct ucc_geth_rx_firmware_statistics_pram *)
+		    (struct ucc_geth_rx_firmware_statistics_pram __iomem *)
 		    qe_muram_addr(ugeth->rx_fw_statistics_pram_offset);
 		/* Zero out p_rx_fw_statistics_pram */
-		memset(ugeth->p_rx_fw_statistics_pram, 0,
+		memset_io((void __iomem *)ugeth->p_rx_fw_statistics_pram, 0,
 		       sizeof(struct ucc_geth_rx_firmware_statistics_pram));
 	}
 
@@ -3000,7 +3008,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	}
 
 	ugeth->p_rx_irq_coalescing_tbl =
-	    (struct ucc_geth_rx_interrupt_coalescing_table *)
+	    (struct ucc_geth_rx_interrupt_coalescing_table __iomem *)
 	    qe_muram_addr(ugeth->rx_irq_coalescing_tbl_offset);
 	out_be32(&ugeth->p_rx_glbl_pram->intcoalescingptr,
 		 ugeth->rx_irq_coalescing_tbl_offset);
@@ -3069,11 +3077,11 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	}
 
 	ugeth->p_rx_bd_qs_tbl =
-	    (struct ucc_geth_rx_bd_queues_entry *) qe_muram_addr(ugeth->
+	    (struct ucc_geth_rx_bd_queues_entry __iomem *) qe_muram_addr(ugeth->
 				    rx_bd_qs_tbl_offset);
 	out_be32(&ugeth->p_rx_glbl_pram->rbdqptr, ugeth->rx_bd_qs_tbl_offset);
 	/* Zero out p_rx_bd_qs_tbl */
-	memset(ugeth->p_rx_bd_qs_tbl,
+	memset_io((void __iomem *)ugeth->p_rx_bd_qs_tbl,
 	       0,
 	       ug_info->numQueuesRx * (sizeof(struct ucc_geth_rx_bd_queues_entry) +
 				       sizeof(struct ucc_geth_rx_prefetched_bds)));
@@ -3133,7 +3141,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		&ugeth->p_rx_glbl_pram->remoder);
 
 	/* function code register */
-	ugeth->p_rx_glbl_pram->rstate = function_code;
+	out_8(&ugeth->p_rx_glbl_pram->rstate, function_code);
 
 	/* initialize extended filtering */
 	if (ug_info->rxExtendedFiltering) {
@@ -3160,7 +3168,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		}
 
 		ugeth->p_exf_glbl_param =
-		    (struct ucc_geth_exf_global_pram *) qe_muram_addr(ugeth->
+		    (struct ucc_geth_exf_global_pram __iomem *) qe_muram_addr(ugeth->
 				 exf_glbl_param_offset);
 		out_be32(&ugeth->p_rx_glbl_pram->exfGlobalParam,
 			 ugeth->exf_glbl_param_offset);
@@ -3175,7 +3183,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			ugeth_82xx_filtering_clear_addr_in_paddr(ugeth, (u8) j);
 
 		p_82xx_addr_filt =
-		    (struct ucc_geth_82xx_address_filtering_pram *) ugeth->
+		    (struct ucc_geth_82xx_address_filtering_pram __iomem *) ugeth->
 		    p_rx_glbl_pram->addressfiltering;
 
 		ugeth_82xx_filtering_clear_all_addr_in_hash(ugeth,
@@ -3307,17 +3315,21 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		return -ENOMEM;
 	}
 	p_init_enet_pram =
-	    (struct ucc_geth_init_pram *) qe_muram_addr(init_enet_pram_offset);
+	    (struct ucc_geth_init_pram __iomem *) qe_muram_addr(init_enet_pram_offset);
 
 	/* Copy shadow InitEnet command parameter structure into PRAM */
-	p_init_enet_pram->resinit1 = ugeth->p_init_enet_param_shadow->resinit1;
-	p_init_enet_pram->resinit2 = ugeth->p_init_enet_param_shadow->resinit2;
-	p_init_enet_pram->resinit3 = ugeth->p_init_enet_param_shadow->resinit3;
-	p_init_enet_pram->resinit4 = ugeth->p_init_enet_param_shadow->resinit4;
+	out_8(&p_init_enet_pram->resinit1,
+			ugeth->p_init_enet_param_shadow->resinit1);
+	out_8(&p_init_enet_pram->resinit2,
+			ugeth->p_init_enet_param_shadow->resinit2);
+	out_8(&p_init_enet_pram->resinit3,
+			ugeth->p_init_enet_param_shadow->resinit3);
+	out_8(&p_init_enet_pram->resinit4,
+			ugeth->p_init_enet_param_shadow->resinit4);
 	out_be16(&p_init_enet_pram->resinit5,
 		 ugeth->p_init_enet_param_shadow->resinit5);
-	p_init_enet_pram->largestexternallookupkeysize =
-	    ugeth->p_init_enet_param_shadow->largestexternallookupkeysize;
+	out_8(&p_init_enet_pram->largestexternallookupkeysize,
+	    ugeth->p_init_enet_param_shadow->largestexternallookupkeysize);
 	out_be32(&p_init_enet_pram->rgftgfrxglobal,
 		 ugeth->p_init_enet_param_shadow->rgftgfrxglobal);
 	for (i = 0; i < ENET_INIT_PARAM_MAX_ENTRIES_RX; i++)
@@ -3371,7 +3383,7 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 #ifdef CONFIG_UGETH_TX_ON_DEMAND
 	struct ucc_fast_private *uccf;
 #endif
-	u8 *bd;			/* BD pointer */
+	u8 __iomem *bd;			/* BD pointer */
 	u32 bd_status;
 	u8 txQ = 0;
 
@@ -3383,7 +3395,7 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* Start from the next BD that should be filled */
 	bd = ugeth->txBd[txQ];
-	bd_status = in_be32((u32 *)bd);
+	bd_status = in_be32((u32 __iomem *)bd);
 	/* Save the skb pointer so we can free it later */
 	ugeth->tx_skbuff[txQ][ugeth->skb_curtx[txQ]] = skb;
 
@@ -3393,7 +3405,7 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	     1) & TX_RING_MOD_MASK(ugeth->ug_info->bdRingLenTx[txQ]);
 
 	/* set up the buffer descriptor */
-	out_be32(&((struct qe_bd *)bd)->buf,
+	out_be32(&((struct qe_bd __iomem *)bd)->buf,
 		      dma_map_single(NULL, skb->data, skb->len, DMA_TO_DEVICE));
 
 	/* printk(KERN_DEBUG"skb->data is 0x%x\n",skb->data); */
@@ -3401,7 +3413,7 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	bd_status = (bd_status & T_W) | T_R | T_I | T_L | skb->len;
 
 	/* set bd status and length */
-	out_be32((u32 *)bd, bd_status);
+	out_be32((u32 __iomem *)bd, bd_status);
 
 	dev->trans_start = jiffies;
 
@@ -3441,7 +3453,7 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 static int ucc_geth_rx(struct ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit)
 {
 	struct sk_buff *skb;
-	u8 *bd;
+	u8 __iomem *bd;
 	u16 length, howmany = 0;
 	u32 bd_status;
 	u8 *bdBuffer;
@@ -3454,11 +3466,11 @@ static int ucc_geth_rx(struct ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit
 	/* collect received buffers */
 	bd = ugeth->rxBd[rxQ];
 
-	bd_status = in_be32((u32 *)bd);
+	bd_status = in_be32((u32 __iomem *)bd);
 
 	/* while there are received buffers and BD is full (~R_E) */
 	while (!((bd_status & (R_E)) || (--rx_work_limit < 0))) {
-		bdBuffer = (u8 *) in_be32(&((struct qe_bd *)bd)->buf);
+		bdBuffer = (u8 *) in_be32(&((struct qe_bd __iomem *)bd)->buf);
 		length = (u16) ((bd_status & BD_LENGTH_MASK) - 4);
 		skb = ugeth->rx_skbuff[rxQ][ugeth->skb_currx[rxQ]];
 
@@ -3516,7 +3528,7 @@ static int ucc_geth_rx(struct ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit
 		else
 			bd += sizeof(struct qe_bd);
 
-		bd_status = in_be32((u32 *)bd);
+		bd_status = in_be32((u32 __iomem *)bd);
 	}
 
 	ugeth->rxBd[rxQ] = bd;
@@ -3527,11 +3539,11 @@ static int ucc_geth_tx(struct net_device *dev, u8 txQ)
 {
 	/* Start from the next BD that should be filled */
 	struct ucc_geth_private *ugeth = netdev_priv(dev);
-	u8 *bd;			/* BD pointer */
+	u8 __iomem *bd;		/* BD pointer */
 	u32 bd_status;
 
 	bd = ugeth->confBd[txQ];
-	bd_status = in_be32((u32 *)bd);
+	bd_status = in_be32((u32 __iomem *)bd);
 
 	/* Normal processing. */
 	while ((bd_status & T_R) == 0) {
@@ -3561,7 +3573,7 @@ static int ucc_geth_tx(struct net_device *dev, u8 txQ)
 			bd += sizeof(struct qe_bd);
 		else
 			bd = ugeth->p_tx_bd_ring[txQ];
-		bd_status = in_be32((u32 *)bd);
+		bd_status = in_be32((u32 __iomem *)bd);
 	}
 	ugeth->confBd[txQ] = bd;
 	return 0;
@@ -3910,7 +3922,7 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 			return -EINVAL;
 		}
 	} else {
-		prop = of_get_property(np, "rx-clock", NULL);
+		prop = of_get_property(np, "tx-clock", NULL);
 		if (!prop) {
 			printk(KERN_ERR
 				"ucc_geth: mising tx-clock-name property\n");
diff --git a/drivers/net/ucc_geth.h b/drivers/net/ucc_geth.h
index 9f8b758..abc0e22 100644
--- a/drivers/net/ucc_geth.h
+++ b/drivers/net/ucc_geth.h
@@ -700,8 +700,8 @@ struct ucc_geth_82xx_address_filtering_pram {
 	u32 iaddr_l;		/* individual address filter, low */
 	u32 gaddr_h;		/* group address filter, high */
 	u32 gaddr_l;		/* group address filter, low */
-	struct ucc_geth_82xx_enet_address taddr;
-	struct ucc_geth_82xx_enet_address paddr[NUM_OF_PADDRS];
+	struct ucc_geth_82xx_enet_address __iomem taddr;
+	struct ucc_geth_82xx_enet_address __iomem paddr[NUM_OF_PADDRS];
 	u8 res0[0x40 - 0x38];
 } __attribute__ ((packed));
 
@@ -1186,40 +1186,40 @@ struct ucc_geth_private {
 	struct ucc_fast_private *uccf;
 	struct net_device *dev;
 	struct napi_struct napi;
-	struct ucc_geth *ug_regs;
+	struct ucc_geth __iomem *ug_regs;
 	struct ucc_geth_init_pram *p_init_enet_param_shadow;
-	struct ucc_geth_exf_global_pram *p_exf_glbl_param;
+	struct ucc_geth_exf_global_pram __iomem *p_exf_glbl_param;
 	u32 exf_glbl_param_offset;
-	struct ucc_geth_rx_global_pram *p_rx_glbl_pram;
+	struct ucc_geth_rx_global_pram __iomem *p_rx_glbl_pram;
 	u32 rx_glbl_pram_offset;
-	struct ucc_geth_tx_global_pram *p_tx_glbl_pram;
+	struct ucc_geth_tx_global_pram __iomem *p_tx_glbl_pram;
 	u32 tx_glbl_pram_offset;
-	struct ucc_geth_send_queue_mem_region *p_send_q_mem_reg;
+	struct ucc_geth_send_queue_mem_region __iomem *p_send_q_mem_reg;
 	u32 send_q_mem_reg_offset;
-	struct ucc_geth_thread_data_tx *p_thread_data_tx;
+	struct ucc_geth_thread_data_tx __iomem *p_thread_data_tx;
 	u32 thread_dat_tx_offset;
-	struct ucc_geth_thread_data_rx *p_thread_data_rx;
+	struct ucc_geth_thread_data_rx __iomem *p_thread_data_rx;
 	u32 thread_dat_rx_offset;
-	struct ucc_geth_scheduler *p_scheduler;
+	struct ucc_geth_scheduler __iomem *p_scheduler;
 	u32 scheduler_offset;
-	struct ucc_geth_tx_firmware_statistics_pram *p_tx_fw_statistics_pram;
+	struct ucc_geth_tx_firmware_statistics_pram __iomem *p_tx_fw_statistics_pram;
 	u32 tx_fw_statistics_pram_offset;
-	struct ucc_geth_rx_firmware_statistics_pram *p_rx_fw_statistics_pram;
+	struct ucc_geth_rx_firmware_statistics_pram __iomem *p_rx_fw_statistics_pram;
 	u32 rx_fw_statistics_pram_offset;
-	struct ucc_geth_rx_interrupt_coalescing_table *p_rx_irq_coalescing_tbl;
+	struct ucc_geth_rx_interrupt_coalescing_table __iomem *p_rx_irq_coalescing_tbl;
 	u32 rx_irq_coalescing_tbl_offset;
-	struct ucc_geth_rx_bd_queues_entry *p_rx_bd_qs_tbl;
+	struct ucc_geth_rx_bd_queues_entry __iomem *p_rx_bd_qs_tbl;
 	u32 rx_bd_qs_tbl_offset;
-	u8 *p_tx_bd_ring[NUM_TX_QUEUES];
+	u8 __iomem *p_tx_bd_ring[NUM_TX_QUEUES];
 	u32 tx_bd_ring_offset[NUM_TX_QUEUES];
-	u8 *p_rx_bd_ring[NUM_RX_QUEUES];
+	u8 __iomem *p_rx_bd_ring[NUM_RX_QUEUES];
 	u32 rx_bd_ring_offset[NUM_RX_QUEUES];
-	u8 *confBd[NUM_TX_QUEUES];
-	u8 *txBd[NUM_TX_QUEUES];
-	u8 *rxBd[NUM_RX_QUEUES];
+	u8 __iomem *confBd[NUM_TX_QUEUES];
+	u8 __iomem *txBd[NUM_TX_QUEUES];
+	u8 __iomem *rxBd[NUM_RX_QUEUES];
 	int badFrame[NUM_RX_QUEUES];
 	u16 cpucount[NUM_TX_QUEUES];
-	volatile u16 *p_cpucount[NUM_TX_QUEUES];
+	u16 __iomem *p_cpucount[NUM_TX_QUEUES];
 	int indAddrRegUsed[NUM_OF_PADDRS];
 	u8 paddr[NUM_OF_PADDRS][ENET_NUM_OCTETS_PER_ADDRESS];	/* ethernet address */
 	u8 numGroupAddrInHash;
@@ -1251,4 +1251,12 @@ struct ucc_geth_private {
 	int oldlink;
 };
 
+void uec_set_ethtool_ops(struct net_device *netdev);
+int init_flow_control_params(u32 automatic_flow_control_mode,
+		int rx_flow_control_enable, int tx_flow_control_enable,
+		u16 pause_period, u16 extension_field,
+		u32 __iomem *upsmr_register, u32 __iomem *uempr_register,
+		u32 __iomem *maccfg1_register);
+
+
 #endif				/* __UCC_GETH_H__ */
diff --git a/drivers/net/ucc_geth_ethtool.c b/drivers/net/ucc_geth_ethtool.c
index 9a9622c..299b7f1 100644
--- a/drivers/net/ucc_geth_ethtool.c
+++ b/drivers/net/ucc_geth_ethtool.c
@@ -108,12 +108,6 @@ static char rx_fw_stat_gstrings[][ETH_GSTRING_LEN] = {
 #define UEC_TX_FW_STATS_LEN ARRAY_SIZE(tx_fw_stat_gstrings)
 #define UEC_RX_FW_STATS_LEN ARRAY_SIZE(rx_fw_stat_gstrings)
 
-extern int init_flow_control_params(u32 automatic_flow_control_mode,
-		int rx_flow_control_enable,
-		int tx_flow_control_enable, u16 pause_period,
-		u16 extension_field, volatile u32 *upsmr_register,
-		volatile u32 *uempr_register, volatile u32 *maccfg1_register);
-
 static int
 uec_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 {
diff --git a/drivers/net/ucc_geth_mii.c b/drivers/net/ucc_geth_mii.c
index 2af4907..9404747 100644
--- a/drivers/net/ucc_geth_mii.c
+++ b/drivers/net/ucc_geth_mii.c
@@ -104,7 +104,7 @@ int uec_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 }
 
 /* Reset the MIIM registers, and wait for the bus to free */
-int uec_mdio_reset(struct mii_bus *bus)
+static int uec_mdio_reset(struct mii_bus *bus)
 {
 	struct ucc_mii_mng __iomem *regs = (void __iomem *)bus->priv;
 	unsigned int timeout = PHY_INIT_TIMEOUT;
@@ -240,7 +240,7 @@ reg_map_fail:
 	return err;
 }
 
-int uec_mdio_remove(struct of_device *ofdev)
+static int uec_mdio_remove(struct of_device *ofdev)
 {
 	struct device *device = &ofdev->dev;
 	struct mii_bus *bus = dev_get_drvdata(device);
diff --git a/include/linux/mv643xx_eth.h b/include/linux/mv643xx_eth.h
index 30e11aa..a15cdd4 100644
--- a/include/linux/mv643xx_eth.h
+++ b/include/linux/mv643xx_eth.h
@@ -1,19 +1,31 @@
 /*
  * MV-643XX ethernet platform device data definition file.
  */
+
 #ifndef __LINUX_MV643XX_ETH_H
 #define __LINUX_MV643XX_ETH_H
 
-#define MV643XX_ETH_SHARED_NAME		"mv643xx_eth_shared"
-#define MV643XX_ETH_NAME		"mv643xx_eth"
+#include <linux/mbus.h>
+
+#define MV643XX_ETH_SHARED_NAME		"mv643xx_eth"
+#define MV643XX_ETH_NAME		"mv643xx_eth_port"
 #define MV643XX_ETH_SHARED_REGS		0x2000
 #define MV643XX_ETH_SHARED_REGS_SIZE	0x2000
 #define MV643XX_ETH_BAR_4		0x2220
 #define MV643XX_ETH_SIZE_REG_4		0x2224
 #define MV643XX_ETH_BASE_ADDR_ENABLE_REG	0x2290
 
+struct mv643xx_eth_shared_platform_data {
+	struct mbus_dram_target_info	*dram;
+	unsigned int	t_clk;
+};
+
 struct mv643xx_eth_platform_data {
+	struct platform_device	*shared;
 	int		port_number;
+
+	struct platform_device	*shared_smi;
+
 	u16		force_phy_addr;	/* force override if phy_addr == 0 */
 	u16		phy_addr;
 
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 02df20f..7224c40 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -412,6 +412,8 @@ int mdiobus_register(struct mii_bus *bus);
 void mdiobus_unregister(struct mii_bus *bus);
 void phy_sanitize_settings(struct phy_device *phydev);
 int phy_stop_interrupts(struct phy_device *phydev);
+int phy_enable_interrupts(struct phy_device *phydev);
+int phy_disable_interrupts(struct phy_device *phydev);
 
 static inline int phy_read_status(struct phy_device *phydev) {
 	return phydev->drv->read_status(phydev);
@@ -447,5 +449,8 @@ int phy_register_fixup_for_uid(u32 phy_uid, u32 phy_uid_mask,
 		int (*run)(struct phy_device *));
 int phy_scan_fixups(struct phy_device *phydev);
 
+int __init mdio_bus_init(void);
+void mdio_bus_exit(void);
+
 extern struct bus_type mdio_bus_type;
 #endif /* __PHY_H */
