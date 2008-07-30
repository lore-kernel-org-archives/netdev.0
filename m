From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver updates
Date: Wed, 30 Jul 2008 17:41:21 -0400
Message-ID: <20080730214121.GA28639@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:41166 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751403AbYG3VlW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jul 2008 17:41:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Still working through the queue...  here's the first part

Please pull from 'upstream-davem' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-davem

to receive the following updates:

 arch/arm/mach-kirkwood/rd88f6281-setup.c     |    3 +
 arch/arm/mach-orion5x/rd88f5181l-fxo-setup.c |    3 +
 arch/arm/mach-orion5x/rd88f5181l-ge-setup.c  |    3 +
 arch/arm/mach-orion5x/wnr854t-setup.c        |    3 +
 arch/arm/mach-orion5x/wrt350n-v2-setup.c     |    3 +
 drivers/net/Kconfig                          |    4 +-
 drivers/net/bfin_mac.c                       |  111 +++++--
 drivers/net/cxgb3/t3_hw.c                    |    2 +-
 drivers/net/ehea/ehea_main.c                 |    4 +-
 drivers/net/enc28j60.c                       |    6 +-
 drivers/net/forcedeth.c                      |   64 ++++-
 drivers/net/mv643xx_eth.c                    |  358 ++++++++++++++--------
 drivers/net/ne.c                             |    6 +-
 drivers/net/s2io.c                           |   29 ++-
 drivers/net/sh_eth.c                         |  202 ++++++++++---
 drivers/net/sh_eth.h                         |  426 +++++++++++++++++++-------
 drivers/net/usb/dm9601.c                     |   52 +++-
 drivers/net/wd.c                             |    2 +-
 18 files changed, 948 insertions(+), 333 deletions(-)

Alan Cox (1):
      [netdrvr] wd: fix build breakage with new NS8390p API

Ayaz Abdulla (1):
      forcedeth bug fix: realtek phy 8211c errata

Breno Leitao (1):
      S2io: fix statistics flush after a MTU change

Bryan Wu (1):
      Blackfin EMAC Driver: enable TXDWA new feature for new silicon (rev > 0.2)

David Brownell (1):
      enc28j60: don't specify (wrong) IRQ type

Julia Lawall (1):
      drivers/net/ehea/ehea_main.c: Release mutex in error handling code

Lennert Buytenhek (12):
      mv643xx_eth: fix TX hang erratum workaround
      mv643xx_eth: prevent breakage when link goes down during transmit
      mv643xx_eth: fix transmit-reclaim-in-napi-poll
      mv643xx_eth: don't fiddle with maximum receive packet size setting
      mv643xx_eth: also check TX_IN_PROGRESS when disabling transmit path
      mv643xx_eth: use longer DMA bursts
      mv643xx_eth: use symbolic MII register addresses and values
      mv643xx_eth: print driver version on init
      mv643xx_eth: use auto phy polling for configuring (R)(G)MII interface
      mv643xx_eth: print message on link status change
      mv643xx_eth: enable hardware TX checksumming with vlan tags
      mv643xx_eth: bump version to 1.2

Michael Hennerich (1):
      Blackfin EMAC Driver: Functional power management support

Mikael Pettersson (1):
      fix NE2000 linkage error

Mike Frysinger (1):
      Blackfin EMAC Driver: add proper __devinit/__devexit markings

Nobuhiro Iwamatsu (1):
      sh_eth: Add support of SH7763 to sh_eth

Peter Korsgaard (1):
      dm9601: don't do usb transfers of data on stack

Stephen Hemminger (1):
      blackfin_mac: unneeded assignment

Steve Wise (1):
      cxgb3: Allow 64KB firmware images.

diff --git a/arch/arm/mach-kirkwood/rd88f6281-setup.c b/arch/arm/mach-kirkwood/rd88f6281-setup.c
index e1f8de2..b6437f4 100644
--- a/arch/arm/mach-kirkwood/rd88f6281-setup.c
+++ b/arch/arm/mach-kirkwood/rd88f6281-setup.c
@@ -18,6 +18,7 @@
 #include <linux/timer.h>
 #include <linux/ata_platform.h>
 #include <linux/mv643xx_eth.h>
+#include <linux/ethtool.h>
 #include <asm/mach-types.h>
 #include <asm/mach/arch.h>
 #include <asm/mach/pci.h>
@@ -69,6 +70,8 @@ static struct platform_device rd88f6281_nand_flash = {
 
 static struct mv643xx_eth_platform_data rd88f6281_ge00_data = {
 	.phy_addr	= -1,
+	.speed		= SPEED_1000,
+	.duplex		= DUPLEX_FULL,
 };
 
 static struct mv_sata_platform_data rd88f6281_sata_data = {
diff --git a/arch/arm/mach-orion5x/rd88f5181l-fxo-setup.c b/arch/arm/mach-orion5x/rd88f5181l-fxo-setup.c
index d50e365..73e9242 100644
--- a/arch/arm/mach-orion5x/rd88f5181l-fxo-setup.c
+++ b/arch/arm/mach-orion5x/rd88f5181l-fxo-setup.c
@@ -15,6 +15,7 @@
 #include <linux/irq.h>
 #include <linux/mtd/physmap.h>
 #include <linux/mv643xx_eth.h>
+#include <linux/ethtool.h>
 #include <asm/mach-types.h>
 #include <asm/gpio.h>
 #include <asm/leds.h>
@@ -88,6 +89,8 @@ static struct orion5x_mpp_mode rd88f5181l_fxo_mpp_modes[] __initdata = {
 
 static struct mv643xx_eth_platform_data rd88f5181l_fxo_eth_data = {
 	.phy_addr	= -1,
+	.speed		= SPEED_1000,
+	.duplex		= DUPLEX_FULL,
 };
 
 static void __init rd88f5181l_fxo_init(void)
diff --git a/arch/arm/mach-orion5x/rd88f5181l-ge-setup.c b/arch/arm/mach-orion5x/rd88f5181l-ge-setup.c
index b56447d..ac48201 100644
--- a/arch/arm/mach-orion5x/rd88f5181l-ge-setup.c
+++ b/arch/arm/mach-orion5x/rd88f5181l-ge-setup.c
@@ -15,6 +15,7 @@
 #include <linux/irq.h>
 #include <linux/mtd/physmap.h>
 #include <linux/mv643xx_eth.h>
+#include <linux/ethtool.h>
 #include <linux/i2c.h>
 #include <asm/mach-types.h>
 #include <asm/gpio.h>
@@ -89,6 +90,8 @@ static struct orion5x_mpp_mode rd88f5181l_ge_mpp_modes[] __initdata = {
 
 static struct mv643xx_eth_platform_data rd88f5181l_ge_eth_data = {
 	.phy_addr	= -1,
+	.speed		= SPEED_1000,
+	.duplex		= DUPLEX_FULL,
 };
 
 static struct i2c_board_info __initdata rd88f5181l_ge_i2c_rtc = {
diff --git a/arch/arm/mach-orion5x/wnr854t-setup.c b/arch/arm/mach-orion5x/wnr854t-setup.c
index 1af093f..25568c2 100644
--- a/arch/arm/mach-orion5x/wnr854t-setup.c
+++ b/arch/arm/mach-orion5x/wnr854t-setup.c
@@ -14,6 +14,7 @@
 #include <linux/delay.h>
 #include <linux/mtd/physmap.h>
 #include <linux/mv643xx_eth.h>
+#include <linux/ethtool.h>
 #include <asm/mach-types.h>
 #include <asm/gpio.h>
 #include <asm/mach/arch.h>
@@ -92,6 +93,8 @@ static struct platform_device wnr854t_nor_flash = {
 
 static struct mv643xx_eth_platform_data wnr854t_eth_data = {
 	.phy_addr	= -1,
+	.speed		= SPEED_1000,
+	.duplex		= DUPLEX_FULL,
 };
 
 static void __init wnr854t_init(void)
diff --git a/arch/arm/mach-orion5x/wrt350n-v2-setup.c b/arch/arm/mach-orion5x/wrt350n-v2-setup.c
index aeab55c..9b8ee8c 100644
--- a/arch/arm/mach-orion5x/wrt350n-v2-setup.c
+++ b/arch/arm/mach-orion5x/wrt350n-v2-setup.c
@@ -14,6 +14,7 @@
 #include <linux/delay.h>
 #include <linux/mtd/physmap.h>
 #include <linux/mv643xx_eth.h>
+#include <linux/ethtool.h>
 #include <asm/mach-types.h>
 #include <asm/gpio.h>
 #include <asm/mach/arch.h>
@@ -100,6 +101,8 @@ static struct platform_device wrt350n_v2_nor_flash = {
 
 static struct mv643xx_eth_platform_data wrt350n_v2_eth_data = {
 	.phy_addr	= -1,
+	.speed		= SPEED_1000,
+	.duplex		= DUPLEX_FULL,
 };
 
 static void __init wrt350n_v2_init(void)
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index fa533c2..8a03875 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -510,14 +510,14 @@ config STNIC
 config SH_ETH
 	tristate "Renesas SuperH Ethernet support"
 	depends on SUPERH && \
-		(CPU_SUBTYPE_SH7710 || CPU_SUBTYPE_SH7712)
+		(CPU_SUBTYPE_SH7710 || CPU_SUBTYPE_SH7712 || CPU_SUBTYPE_SH7763)
 	select CRC32
 	select MII
 	select MDIO_BITBANG
 	select PHYLIB
 	help
 	  Renesas SuperH Ethernet device driver.
-	  This driver support SH7710 and SH7712.
+	  This driver support SH7710, SH7712 and SH7763.
 
 config SUNLANCE
 	tristate "Sun LANCE support"
diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index a8ec60e..3db7db1 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -605,36 +605,87 @@ adjust_head:
 static int bfin_mac_hard_start_xmit(struct sk_buff *skb,
 				struct net_device *dev)
 {
-	unsigned int data;
+	u16 *data;
 
 	current_tx_ptr->skb = skb;
 
-	/*
-	 * Is skb->data always 16-bit aligned?
-	 * Do we need to memcpy((char *)(tail->packet + 2), skb->data, len)?
-	 */
-	if ((((unsigned int)(skb->data)) & 0x02) == 2) {
-		/* move skb->data to current_tx_ptr payload */
-		data = (unsigned int)(skb->data) - 2;
-		*((unsigned short *)data) = (unsigned short)(skb->len);
-		current_tx_ptr->desc_a.start_addr = (unsigned long)data;
-		/* this is important! */
-		blackfin_dcache_flush_range(data, (data + (skb->len)) + 2);
-
+	if (ANOMALY_05000285) {
+		/*
+		 * TXDWA feature is not avaible to older revision < 0.3 silicon
+		 * of BF537
+		 *
+		 * Only if data buffer is ODD WORD alignment, we do not
+		 * need to memcpy
+		 */
+		u32 data_align = (u32)(skb->data) & 0x3;
+		if (data_align == 0x2) {
+			/* move skb->data to current_tx_ptr payload */
+			data = (u16 *)(skb->data) - 1;
+			*data = (u16)(skb->len);
+			current_tx_ptr->desc_a.start_addr = (u32)data;
+			/* this is important! */
+			blackfin_dcache_flush_range((u32)data,
+					(u32)((u8 *)data + skb->len + 4));
+		} else {
+			*((u16 *)(current_tx_ptr->packet)) = (u16)(skb->len);
+			memcpy((u8 *)(current_tx_ptr->packet + 2), skb->data,
+				skb->len);
+			current_tx_ptr->desc_a.start_addr =
+				(u32)current_tx_ptr->packet;
+			if (current_tx_ptr->status.status_word != 0)
+				current_tx_ptr->status.status_word = 0;
+			blackfin_dcache_flush_range(
+				(u32)current_tx_ptr->packet,
+				(u32)(current_tx_ptr->packet + skb->len + 2));
+		}
 	} else {
-		*((unsigned short *)(current_tx_ptr->packet)) =
-		    (unsigned short)(skb->len);
-		memcpy((char *)(current_tx_ptr->packet + 2), skb->data,
-		       (skb->len));
-		current_tx_ptr->desc_a.start_addr =
-		    (unsigned long)current_tx_ptr->packet;
-		if (current_tx_ptr->status.status_word != 0)
-			current_tx_ptr->status.status_word = 0;
-		blackfin_dcache_flush_range((unsigned int)current_tx_ptr->
-					    packet,
-					    (unsigned int)(current_tx_ptr->
-							   packet + skb->len) +
-					    2);
+		/*
+		 * TXDWA feature is avaible to revision < 0.3 silicon of
+		 * BF537 and always avaible to BF52x
+		 */
+		u32 data_align = (u32)(skb->data) & 0x3;
+		if (data_align == 0x0) {
+			u16 sysctl = bfin_read_EMAC_SYSCTL();
+			sysctl |= TXDWA;
+			bfin_write_EMAC_SYSCTL(sysctl);
+
+			/* move skb->data to current_tx_ptr payload */
+			data = (u16 *)(skb->data) - 2;
+			*data = (u16)(skb->len);
+			current_tx_ptr->desc_a.start_addr = (u32)data;
+			/* this is important! */
+			blackfin_dcache_flush_range(
+					(u32)data,
+					(u32)((u8 *)data + skb->len + 4));
+		} else if (data_align == 0x2) {
+			u16 sysctl = bfin_read_EMAC_SYSCTL();
+			sysctl &= ~TXDWA;
+			bfin_write_EMAC_SYSCTL(sysctl);
+
+			/* move skb->data to current_tx_ptr payload */
+			data = (u16 *)(skb->data) - 1;
+			*data = (u16)(skb->len);
+			current_tx_ptr->desc_a.start_addr = (u32)data;
+			/* this is important! */
+			blackfin_dcache_flush_range(
+					(u32)data,
+					(u32)((u8 *)data + skb->len + 4));
+		} else {
+			u16 sysctl = bfin_read_EMAC_SYSCTL();
+			sysctl &= ~TXDWA;
+			bfin_write_EMAC_SYSCTL(sysctl);
+
+			*((u16 *)(current_tx_ptr->packet)) = (u16)(skb->len);
+			memcpy((u8 *)(current_tx_ptr->packet + 2), skb->data,
+				skb->len);
+			current_tx_ptr->desc_a.start_addr =
+				(u32)current_tx_ptr->packet;
+			if (current_tx_ptr->status.status_word != 0)
+				current_tx_ptr->status.status_word = 0;
+			blackfin_dcache_flush_range(
+				(u32)current_tx_ptr->packet,
+				(u32)(current_tx_ptr->packet + skb->len + 2));
+		}
 	}
 
 	/* enable this packet's dma */
@@ -691,7 +742,6 @@ static void bfin_mac_rx(struct net_device *dev)
 					 (unsigned long)skb->tail);
 
 	dev->last_rx = jiffies;
-	skb->dev = dev;
 	skb->protocol = eth_type_trans(skb, dev);
 #if defined(BFIN_MAC_CSUM_OFFLOAD)
 	skb->csum = current_rx_ptr->status.ip_payload_csum;
@@ -920,6 +970,7 @@ static int bfin_mac_open(struct net_device *dev)
 	phy_start(lp->phydev);
 	phy_write(lp->phydev, MII_BMCR, BMCR_RESET);
 	setup_system_regs(dev);
+	setup_mac_addr(dev->dev_addr);
 	bfin_mac_disable();
 	bfin_mac_enable();
 	pr_debug("hardware init finished\n");
@@ -955,7 +1006,7 @@ static int bfin_mac_close(struct net_device *dev)
 	return 0;
 }
 
-static int __init bfin_mac_probe(struct platform_device *pdev)
+static int __devinit bfin_mac_probe(struct platform_device *pdev)
 {
 	struct net_device *ndev;
 	struct bfin_mac_local *lp;
@@ -1081,7 +1132,7 @@ out_err_probe_mac:
 	return rc;
 }
 
-static int bfin_mac_remove(struct platform_device *pdev)
+static int __devexit bfin_mac_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct bfin_mac_local *lp = netdev_priv(ndev);
@@ -1128,7 +1179,7 @@ static int bfin_mac_resume(struct platform_device *pdev)
 
 static struct platform_driver bfin_mac_driver = {
 	.probe = bfin_mac_probe,
-	.remove = bfin_mac_remove,
+	.remove = __devexit_p(bfin_mac_remove),
 	.resume = bfin_mac_resume,
 	.suspend = bfin_mac_suspend,
 	.driver = {
diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index 47d5178..04c0e90 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -683,7 +683,7 @@ enum {
 	SF_ERASE_SECTOR = 0xd8,	/* erase sector */
 
 	FW_FLASH_BOOT_ADDR = 0x70000,	/* start address of FW in flash */
-	FW_VERS_ADDR = 0x77ffc,    /* flash address holding FW version */
+	FW_VERS_ADDR = 0x7fffc,    /* flash address holding FW version */
 	FW_MIN_SIZE = 8            /* at least version and csum */
 };
 
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 0920b79..b70c531 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -2937,9 +2937,9 @@ static void ehea_rereg_mrs(struct work_struct *work)
 				}
 			}
 		}
-       mutex_unlock(&dlpar_mem_lock);
-       ehea_info("re-initializing driver complete");
+	ehea_info("re-initializing driver complete");
 out:
+	mutex_unlock(&dlpar_mem_lock);
 	return;
 }
 
diff --git a/drivers/net/enc28j60.c b/drivers/net/enc28j60.c
index c05cb15..aa0bf6e 100644
--- a/drivers/net/enc28j60.c
+++ b/drivers/net/enc28j60.c
@@ -1547,8 +1547,10 @@ static int __devinit enc28j60_probe(struct spi_device *spi)
 	random_ether_addr(dev->dev_addr);
 	enc28j60_set_hw_macaddr(dev);
 
-	ret = request_irq(spi->irq, enc28j60_irq, IRQF_TRIGGER_FALLING,
-			  DRV_NAME, priv);
+	/* Board setup must set the relevant edge trigger type;
+	 * level triggers won't currently work.
+	 */
+	ret = request_irq(spi->irq, enc28j60_irq, 0, DRV_NAME, priv);
 	if (ret < 0) {
 		if (netif_msg_probe(priv))
 			dev_err(&spi->dev, DRV_NAME ": request irq %d failed "
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 4ed89fa..01b38b0 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -333,6 +333,7 @@ enum {
 	NvRegPowerState2 = 0x600,
 #define NVREG_POWERSTATE2_POWERUP_MASK		0x0F11
 #define NVREG_POWERSTATE2_POWERUP_REV_A3	0x0001
+#define NVREG_POWERSTATE2_PHY_RESET		0x0004
 };
 
 /* Big endian: should work, but is untested */
@@ -529,6 +530,7 @@ union ring_type {
 #define PHY_REALTEK_INIT_REG4	0x14
 #define PHY_REALTEK_INIT_REG5	0x18
 #define PHY_REALTEK_INIT_REG6	0x11
+#define PHY_REALTEK_INIT_REG7	0x01
 #define PHY_REALTEK_INIT1	0x0000
 #define PHY_REALTEK_INIT2	0x8e00
 #define PHY_REALTEK_INIT3	0x0001
@@ -537,6 +539,9 @@ union ring_type {
 #define PHY_REALTEK_INIT6	0xf5c7
 #define PHY_REALTEK_INIT7	0x1000
 #define PHY_REALTEK_INIT8	0x0003
+#define PHY_REALTEK_INIT9	0x0008
+#define PHY_REALTEK_INIT10	0x0005
+#define PHY_REALTEK_INIT11	0x0200
 #define PHY_REALTEK_INIT_MSK1	0x0003
 
 #define PHY_GIGABIT	0x0100
@@ -1149,6 +1154,42 @@ static int phy_init(struct net_device *dev)
 				return PHY_ERROR;
 			}
 		}
+		if (np->phy_model == PHY_MODEL_REALTEK_8211 &&
+		    np->phy_rev == PHY_REV_REALTEK_8211C) {
+			u32 powerstate = readl(base + NvRegPowerState2);
+
+			/* need to perform hw phy reset */
+			powerstate |= NVREG_POWERSTATE2_PHY_RESET;
+			writel(powerstate, base + NvRegPowerState2);
+			msleep(25);
+
+			powerstate &= ~NVREG_POWERSTATE2_PHY_RESET;
+			writel(powerstate, base + NvRegPowerState2);
+			msleep(25);
+
+			reg = mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG6, MII_READ);
+			reg |= PHY_REALTEK_INIT9;
+			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG6, reg)) {
+				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				return PHY_ERROR;
+			}
+			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT10)) {
+				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				return PHY_ERROR;
+			}
+			reg = mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG7, MII_READ);
+			if (!(reg & PHY_REALTEK_INIT11)) {
+				reg |= PHY_REALTEK_INIT11;
+				if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG7, reg)) {
+					printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+					return PHY_ERROR;
+				}
+			}
+			if (mii_rw(dev, np->phyaddr, PHY_REALTEK_INIT_REG1, PHY_REALTEK_INIT1)) {
+				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+				return PHY_ERROR;
+			}
+		}
 		if (np->phy_model == PHY_MODEL_REALTEK_8201) {
 			if (np->device_id == PCI_DEVICE_ID_NVIDIA_NVENET_32 ||
 			    np->device_id == PCI_DEVICE_ID_NVIDIA_NVENET_33 ||
@@ -1201,12 +1242,23 @@ static int phy_init(struct net_device *dev)
 	mii_control = mii_rw(dev, np->phyaddr, MII_BMCR, MII_READ);
 	mii_control |= BMCR_ANENABLE;
 
-	/* reset the phy
-	 * (certain phys need bmcr to be setup with reset)
-	 */
-	if (phy_reset(dev, mii_control)) {
-		printk(KERN_INFO "%s: phy reset failed\n", pci_name(np->pci_dev));
-		return PHY_ERROR;
+	if (np->phy_oui == PHY_OUI_REALTEK &&
+	    np->phy_model == PHY_MODEL_REALTEK_8211 &&
+	    np->phy_rev == PHY_REV_REALTEK_8211C) {
+		/* start autoneg since we already performed hw reset above */
+		mii_control |= BMCR_ANRESTART;
+		if (mii_rw(dev, np->phyaddr, MII_BMCR, mii_control)) {
+			printk(KERN_INFO "%s: phy init failed\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
+	} else {
+		/* reset the phy
+		 * (certain phys need bmcr to be setup with reset)
+		 */
+		if (phy_reset(dev, mii_control)) {
+			printk(KERN_INFO "%s: phy reset failed\n", pci_name(np->pci_dev));
+			return PHY_ERROR;
+		}
 	}
 
 	/* phy vendor specific configuration */
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 8a97a00..46819af 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -55,7 +55,7 @@
 #include <asm/system.h>
 
 static char mv643xx_eth_driver_name[] = "mv643xx_eth";
-static char mv643xx_eth_driver_version[] = "1.1";
+static char mv643xx_eth_driver_version[] = "1.2";
 
 #define MV643XX_ETH_CHECKSUM_OFFLOAD_TX
 #define MV643XX_ETH_NAPI
@@ -90,12 +90,21 @@ static char mv643xx_eth_driver_version[] = "1.1";
 #define PORT_SERIAL_CONTROL(p)		(0x043c + ((p) << 10))
 #define PORT_STATUS(p)			(0x0444 + ((p) << 10))
 #define  TX_FIFO_EMPTY			0x00000400
+#define  TX_IN_PROGRESS			0x00000080
+#define  PORT_SPEED_MASK		0x00000030
+#define  PORT_SPEED_1000		0x00000010
+#define  PORT_SPEED_100			0x00000020
+#define  PORT_SPEED_10			0x00000000
+#define  FLOW_CONTROL_ENABLED		0x00000008
+#define  FULL_DUPLEX			0x00000004
+#define  LINK_UP			0x00000002
 #define TXQ_COMMAND(p)			(0x0448 + ((p) << 10))
 #define TXQ_FIX_PRIO_CONF(p)		(0x044c + ((p) << 10))
 #define TX_BW_RATE(p)			(0x0450 + ((p) << 10))
 #define TX_BW_MTU(p)			(0x0458 + ((p) << 10))
 #define TX_BW_BURST(p)			(0x045c + ((p) << 10))
 #define INT_CAUSE(p)			(0x0460 + ((p) << 10))
+#define  INT_TX_END_0			0x00080000
 #define  INT_TX_END			0x07f80000
 #define  INT_RX				0x0007fbfc
 #define  INT_EXT			0x00000002
@@ -127,21 +136,21 @@ static char mv643xx_eth_driver_version[] = "1.1";
 /*
  * SDMA configuration register.
  */
-#define RX_BURST_SIZE_4_64BIT		(2 << 1)
+#define RX_BURST_SIZE_16_64BIT		(4 << 1)
 #define BLM_RX_NO_SWAP			(1 << 4)
 #define BLM_TX_NO_SWAP			(1 << 5)
-#define TX_BURST_SIZE_4_64BIT		(2 << 22)
+#define TX_BURST_SIZE_16_64BIT		(4 << 22)
 
 #if defined(__BIG_ENDIAN)
 #define PORT_SDMA_CONFIG_DEFAULT_VALUE		\
-		RX_BURST_SIZE_4_64BIT	|	\
-		TX_BURST_SIZE_4_64BIT
+		RX_BURST_SIZE_16_64BIT	|	\
+		TX_BURST_SIZE_16_64BIT
 #elif defined(__LITTLE_ENDIAN)
 #define PORT_SDMA_CONFIG_DEFAULT_VALUE		\
-		RX_BURST_SIZE_4_64BIT	|	\
+		RX_BURST_SIZE_16_64BIT	|	\
 		BLM_RX_NO_SWAP		|	\
 		BLM_TX_NO_SWAP		|	\
-		TX_BURST_SIZE_4_64BIT
+		TX_BURST_SIZE_16_64BIT
 #else
 #error One of __BIG_ENDIAN or __LITTLE_ENDIAN must be defined
 #endif
@@ -153,9 +162,7 @@ static char mv643xx_eth_driver_version[] = "1.1";
 #define SET_MII_SPEED_TO_100			(1 << 24)
 #define SET_GMII_SPEED_TO_1000			(1 << 23)
 #define SET_FULL_DUPLEX_MODE			(1 << 21)
-#define MAX_RX_PACKET_1522BYTE			(1 << 17)
 #define MAX_RX_PACKET_9700BYTE			(5 << 17)
-#define MAX_RX_PACKET_MASK			(7 << 17)
 #define DISABLE_AUTO_NEG_SPEED_GMII		(1 << 13)
 #define DO_NOT_FORCE_LINK_FAIL			(1 << 10)
 #define SERIAL_PORT_CONTROL_RESERVED		(1 << 9)
@@ -228,6 +235,8 @@ struct tx_desc {
 #define GEN_IP_V4_CHECKSUM		0x00040000
 #define GEN_TCP_UDP_CHECKSUM		0x00020000
 #define UDP_FRAME			0x00010000
+#define MAC_HDR_EXTRA_4_BYTES		0x00008000
+#define MAC_HDR_EXTRA_8_BYTES		0x00000200
 
 #define TX_IHL_SHIFT			11
 
@@ -404,6 +413,17 @@ static void rxq_disable(struct rx_queue *rxq)
 		udelay(10);
 }
 
+static void txq_reset_hw_ptr(struct tx_queue *txq)
+{
+	struct mv643xx_eth_private *mp = txq_to_mp(txq);
+	int off = TXQ_CURRENT_DESC_PTR(mp->port_num, txq->index);
+	u32 addr;
+
+	addr = (u32)txq->tx_desc_dma;
+	addr += txq->tx_curr_desc * sizeof(struct tx_desc);
+	wrl(mp, off, addr);
+}
+
 static void txq_enable(struct tx_queue *txq)
 {
 	struct mv643xx_eth_private *mp = txq_to_mp(txq);
@@ -614,6 +634,12 @@ static int mv643xx_eth_poll(struct napi_struct *napi, int budget)
 		for (i = 0; i < 8; i++)
 			if (mp->txq_mask & (1 << i))
 				txq_reclaim(mp->txq + i, 0);
+
+		if (netif_carrier_ok(mp->dev)) {
+			spin_lock(&mp->lock);
+			__txq_maybe_wake(mp->txq + mp->txq_primary);
+			spin_unlock(&mp->lock);
+		}
 	}
 #endif
 
@@ -706,6 +732,7 @@ static inline __be16 sum16_as_be(__sum16 sum)
 
 static void txq_submit_skb(struct tx_queue *txq, struct sk_buff *skb)
 {
+	struct mv643xx_eth_private *mp = txq_to_mp(txq);
 	int nr_frags = skb_shinfo(skb)->nr_frags;
 	int tx_index;
 	struct tx_desc *desc;
@@ -732,12 +759,36 @@ static void txq_submit_skb(struct tx_queue *txq, struct sk_buff *skb)
 	desc->buf_ptr = dma_map_single(NULL, skb->data, length, DMA_TO_DEVICE);
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		BUG_ON(skb->protocol != htons(ETH_P_IP));
+		int mac_hdr_len;
+
+		BUG_ON(skb->protocol != htons(ETH_P_IP) &&
+		       skb->protocol != htons(ETH_P_8021Q));
 
 		cmd_sts |= GEN_TCP_UDP_CHECKSUM |
 			   GEN_IP_V4_CHECKSUM   |
 			   ip_hdr(skb)->ihl << TX_IHL_SHIFT;
 
+		mac_hdr_len = (void *)ip_hdr(skb) - (void *)skb->data;
+		switch (mac_hdr_len - ETH_HLEN) {
+		case 0:
+			break;
+		case 4:
+			cmd_sts |= MAC_HDR_EXTRA_4_BYTES;
+			break;
+		case 8:
+			cmd_sts |= MAC_HDR_EXTRA_8_BYTES;
+			break;
+		case 12:
+			cmd_sts |= MAC_HDR_EXTRA_4_BYTES;
+			cmd_sts |= MAC_HDR_EXTRA_8_BYTES;
+			break;
+		default:
+			if (net_ratelimit())
+				dev_printk(KERN_ERR, &txq_to_mp(txq)->dev->dev,
+				   "mac header length is %d?!\n", mac_hdr_len);
+			break;
+		}
+
 		switch (ip_hdr(skb)->protocol) {
 		case IPPROTO_UDP:
 			cmd_sts |= UDP_FRAME;
@@ -759,6 +810,10 @@ static void txq_submit_skb(struct tx_queue *txq, struct sk_buff *skb)
 	wmb();
 	desc->cmd_sts = cmd_sts;
 
+	/* clear TX_END interrupt status */
+	wrl(mp, INT_CAUSE(mp->port_num), ~(INT_TX_END_0 << txq->index));
+	rdl(mp, INT_CAUSE(mp->port_num));
+
 	/* ensure all descriptors are written before poking hardware */
 	wmb();
 	txq_enable(txq);
@@ -1112,10 +1167,28 @@ static int mv643xx_eth_get_settings(struct net_device *dev, struct ethtool_cmd *
 
 static int mv643xx_eth_get_settings_phyless(struct net_device *dev, struct ethtool_cmd *cmd)
 {
+	struct mv643xx_eth_private *mp = netdev_priv(dev);
+	u32 port_status;
+
+	port_status = rdl(mp, PORT_STATUS(mp->port_num));
+
 	cmd->supported = SUPPORTED_MII;
 	cmd->advertising = ADVERTISED_MII;
-	cmd->speed = SPEED_1000;
-	cmd->duplex = DUPLEX_FULL;
+	switch (port_status & PORT_SPEED_MASK) {
+	case PORT_SPEED_10:
+		cmd->speed = SPEED_10;
+		break;
+	case PORT_SPEED_100:
+		cmd->speed = SPEED_100;
+		break;
+	case PORT_SPEED_1000:
+		cmd->speed = SPEED_1000;
+		break;
+	default:
+		cmd->speed = -1;
+		break;
+	}
+	cmd->duplex = (port_status & FULL_DUPLEX) ? DUPLEX_FULL : DUPLEX_HALF;
 	cmd->port = PORT_MII;
 	cmd->phy_address = 0;
 	cmd->transceiver = XCVR_INTERNAL;
@@ -1539,8 +1612,11 @@ static int txq_init(struct mv643xx_eth_private *mp, int index)
 
 	tx_desc = (struct tx_desc *)txq->tx_desc_area;
 	for (i = 0; i < txq->tx_ring_size; i++) {
+		struct tx_desc *txd = tx_desc + i;
 		int nexti = (i + 1) % txq->tx_ring_size;
-		tx_desc[i].next_desc_ptr = txq->tx_desc_dma +
+
+		txd->cmd_sts = 0;
+		txd->next_desc_ptr = txq->tx_desc_dma +
 					nexti * sizeof(struct tx_desc);
 	}
 
@@ -1577,8 +1653,11 @@ static void txq_reclaim(struct tx_queue *txq, int force)
 		desc = &txq->tx_desc_area[tx_index];
 		cmd_sts = desc->cmd_sts;
 
-		if (!force && (cmd_sts & BUFFER_OWNED_BY_DMA))
-			break;
+		if (cmd_sts & BUFFER_OWNED_BY_DMA) {
+			if (!force)
+				break;
+			desc->cmd_sts = cmd_sts & ~BUFFER_OWNED_BY_DMA;
+		}
 
 		txq->tx_used_desc = (tx_index + 1) % txq->tx_ring_size;
 		txq->tx_desc_count--;
@@ -1632,49 +1711,61 @@ static void txq_deinit(struct tx_queue *txq)
 
 
 /* netdev ops and related ***************************************************/
-static void update_pscr(struct mv643xx_eth_private *mp, int speed, int duplex)
+static void handle_link_event(struct mv643xx_eth_private *mp)
 {
-	u32 pscr_o;
-	u32 pscr_n;
-
-	pscr_o = rdl(mp, PORT_SERIAL_CONTROL(mp->port_num));
+	struct net_device *dev = mp->dev;
+	u32 port_status;
+	int speed;
+	int duplex;
+	int fc;
+
+	port_status = rdl(mp, PORT_STATUS(mp->port_num));
+	if (!(port_status & LINK_UP)) {
+		if (netif_carrier_ok(dev)) {
+			int i;
 
-	/* clear speed, duplex and rx buffer size fields */
-	pscr_n = pscr_o & ~(SET_MII_SPEED_TO_100   |
-			    SET_GMII_SPEED_TO_1000 |
-			    SET_FULL_DUPLEX_MODE   |
-			    MAX_RX_PACKET_MASK);
+			printk(KERN_INFO "%s: link down\n", dev->name);
 
-	if (speed == SPEED_1000) {
-		pscr_n |= SET_GMII_SPEED_TO_1000 | MAX_RX_PACKET_9700BYTE;
-	} else {
-		if (speed == SPEED_100)
-			pscr_n |= SET_MII_SPEED_TO_100;
-		pscr_n |= MAX_RX_PACKET_1522BYTE;
-	}
+			netif_carrier_off(dev);
+			netif_stop_queue(dev);
 
-	if (duplex == DUPLEX_FULL)
-		pscr_n |= SET_FULL_DUPLEX_MODE;
+			for (i = 0; i < 8; i++) {
+				struct tx_queue *txq = mp->txq + i;
 
-	if (pscr_n != pscr_o) {
-		if ((pscr_o & SERIAL_PORT_ENABLE) == 0)
-			wrl(mp, PORT_SERIAL_CONTROL(mp->port_num), pscr_n);
-		else {
-			int i;
+				if (mp->txq_mask & (1 << i)) {
+					txq_reclaim(txq, 1);
+					txq_reset_hw_ptr(txq);
+				}
+			}
+		}
+		return;
+	}
 
-			for (i = 0; i < 8; i++)
-				if (mp->txq_mask & (1 << i))
-					txq_disable(mp->txq + i);
+	switch (port_status & PORT_SPEED_MASK) {
+	case PORT_SPEED_10:
+		speed = 10;
+		break;
+	case PORT_SPEED_100:
+		speed = 100;
+		break;
+	case PORT_SPEED_1000:
+		speed = 1000;
+		break;
+	default:
+		speed = -1;
+		break;
+	}
+	duplex = (port_status & FULL_DUPLEX) ? 1 : 0;
+	fc = (port_status & FLOW_CONTROL_ENABLED) ? 1 : 0;
 
-			pscr_o &= ~SERIAL_PORT_ENABLE;
-			wrl(mp, PORT_SERIAL_CONTROL(mp->port_num), pscr_o);
-			wrl(mp, PORT_SERIAL_CONTROL(mp->port_num), pscr_n);
-			wrl(mp, PORT_SERIAL_CONTROL(mp->port_num), pscr_n);
+	printk(KERN_INFO "%s: link up, %d Mb/s, %s duplex, "
+			 "flow control %sabled\n", dev->name,
+			 speed, duplex ? "full" : "half",
+			 fc ? "en" : "dis");
 
-			for (i = 0; i < 8; i++)
-				if (mp->txq_mask & (1 << i))
-					txq_enable(mp->txq + i);
-		}
+	if (!netif_carrier_ok(dev)) {
+		netif_carrier_on(dev);
+		netif_wake_queue(dev);
 	}
 }
 
@@ -1684,7 +1775,6 @@ static irqreturn_t mv643xx_eth_irq(int irq, void *dev_id)
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
 	u32 int_cause;
 	u32 int_cause_ext;
-	u32 txq_active;
 
 	int_cause = rdl(mp, INT_CAUSE(mp->port_num)) &
 			(INT_TX_END | INT_RX | INT_EXT);
@@ -1698,30 +1788,8 @@ static irqreturn_t mv643xx_eth_irq(int irq, void *dev_id)
 		wrl(mp, INT_CAUSE_EXT(mp->port_num), ~int_cause_ext);
 	}
 
-	if (int_cause_ext & (INT_EXT_PHY | INT_EXT_LINK)) {
-		if (mp->phy_addr == -1 || mii_link_ok(&mp->mii)) {
-			int i;
-
-			if (mp->phy_addr != -1) {
-				struct ethtool_cmd cmd;
-
-				mii_ethtool_gset(&mp->mii, &cmd);
-				update_pscr(mp, cmd.speed, cmd.duplex);
-			}
-
-			for (i = 0; i < 8; i++)
-				if (mp->txq_mask & (1 << i))
-					txq_enable(mp->txq + i);
-
-			if (!netif_carrier_ok(dev)) {
-				netif_carrier_on(dev);
-				__txq_maybe_wake(mp->txq + mp->txq_primary);
-			}
-		} else if (netif_carrier_ok(dev)) {
-			netif_stop_queue(dev);
-			netif_carrier_off(dev);
-		}
-	}
+	if (int_cause_ext & (INT_EXT_PHY | INT_EXT_LINK))
+		handle_link_event(mp);
 
 	/*
 	 * RxBuffer or RxError set for any of the 8 queues?
@@ -1743,8 +1811,6 @@ static irqreturn_t mv643xx_eth_irq(int irq, void *dev_id)
 	}
 #endif
 
-	txq_active = rdl(mp, TXQ_COMMAND(mp->port_num));
-
 	/*
 	 * TxBuffer or TxError set for any of the 8 queues?
 	 */
@@ -1754,6 +1820,16 @@ static irqreturn_t mv643xx_eth_irq(int irq, void *dev_id)
 		for (i = 0; i < 8; i++)
 			if (mp->txq_mask & (1 << i))
 				txq_reclaim(mp->txq + i, 0);
+
+		/*
+		 * Enough space again in the primary TX queue for a
+		 * full packet?
+		 */
+		if (netif_carrier_ok(dev)) {
+			spin_lock(&mp->lock);
+			__txq_maybe_wake(mp->txq + mp->txq_primary);
+			spin_unlock(&mp->lock);
+		}
 	}
 
 	/*
@@ -1763,19 +1839,25 @@ static irqreturn_t mv643xx_eth_irq(int irq, void *dev_id)
 		int i;
 
 		wrl(mp, INT_CAUSE(mp->port_num), ~(int_cause & INT_TX_END));
+
+		spin_lock(&mp->lock);
 		for (i = 0; i < 8; i++) {
 			struct tx_queue *txq = mp->txq + i;
-			if (txq->tx_desc_count && !((txq_active >> i) & 1))
+			u32 hw_desc_ptr;
+			u32 expected_ptr;
+
+			if ((int_cause & (INT_TX_END_0 << i)) == 0)
+				continue;
+
+			hw_desc_ptr =
+				rdl(mp, TXQ_CURRENT_DESC_PTR(mp->port_num, i));
+			expected_ptr = (u32)txq->tx_desc_dma +
+				txq->tx_curr_desc * sizeof(struct tx_desc);
+
+			if (hw_desc_ptr != expected_ptr)
 				txq_enable(txq);
 		}
-	}
-
-	/*
-	 * Enough space again in the primary TX queue for a full packet?
-	 */
-	if (int_cause_ext & INT_EXT_TX) {
-		struct tx_queue *txq = mp->txq + mp->txq_primary;
-		__txq_maybe_wake(txq);
+		spin_unlock(&mp->lock);
 	}
 
 	return IRQ_HANDLED;
@@ -1785,14 +1867,14 @@ static void phy_reset(struct mv643xx_eth_private *mp)
 {
 	unsigned int data;
 
-	smi_reg_read(mp, mp->phy_addr, 0, &data);
-	data |= 0x8000;
-	smi_reg_write(mp, mp->phy_addr, 0, data);
+	smi_reg_read(mp, mp->phy_addr, MII_BMCR, &data);
+	data |= BMCR_RESET;
+	smi_reg_write(mp, mp->phy_addr, MII_BMCR, data);
 
 	do {
 		udelay(1);
-		smi_reg_read(mp, mp->phy_addr, 0, &data);
-	} while (data & 0x8000);
+		smi_reg_read(mp, mp->phy_addr, MII_BMCR, &data);
+	} while (data & BMCR_RESET);
 }
 
 static void port_start(struct mv643xx_eth_private *mp)
@@ -1801,23 +1883,6 @@ static void port_start(struct mv643xx_eth_private *mp)
 	int i;
 
 	/*
-	 * Configure basic link parameters.
-	 */
-	pscr = rdl(mp, PORT_SERIAL_CONTROL(mp->port_num));
-	pscr &= ~(SERIAL_PORT_ENABLE | FORCE_LINK_PASS);
-	wrl(mp, PORT_SERIAL_CONTROL(mp->port_num), pscr);
-	pscr |= DISABLE_AUTO_NEG_FOR_FLOW_CTRL |
-		DISABLE_AUTO_NEG_SPEED_GMII    |
-		DISABLE_AUTO_NEG_FOR_DUPLEX    |
-		DO_NOT_FORCE_LINK_FAIL	       |
-		SERIAL_PORT_CONTROL_RESERVED;
-	wrl(mp, PORT_SERIAL_CONTROL(mp->port_num), pscr);
-	pscr |= SERIAL_PORT_ENABLE;
-	wrl(mp, PORT_SERIAL_CONTROL(mp->port_num), pscr);
-
-	wrl(mp, SDMA_CONFIG(mp->port_num), PORT_SDMA_CONFIG_DEFAULT_VALUE);
-
-	/*
 	 * Perform PHY reset, if there is a PHY.
 	 */
 	if (mp->phy_addr != -1) {
@@ -1829,21 +1894,31 @@ static void port_start(struct mv643xx_eth_private *mp)
 	}
 
 	/*
+	 * Configure basic link parameters.
+	 */
+	pscr = rdl(mp, PORT_SERIAL_CONTROL(mp->port_num));
+
+	pscr |= SERIAL_PORT_ENABLE;
+	wrl(mp, PORT_SERIAL_CONTROL(mp->port_num), pscr);
+
+	pscr |= DO_NOT_FORCE_LINK_FAIL;
+	if (mp->phy_addr == -1)
+		pscr |= FORCE_LINK_PASS;
+	wrl(mp, PORT_SERIAL_CONTROL(mp->port_num), pscr);
+
+	wrl(mp, SDMA_CONFIG(mp->port_num), PORT_SDMA_CONFIG_DEFAULT_VALUE);
+
+	/*
 	 * Configure TX path and queues.
 	 */
 	tx_set_rate(mp, 1000000000, 16777216);
 	for (i = 0; i < 8; i++) {
 		struct tx_queue *txq = mp->txq + i;
-		int off = TXQ_CURRENT_DESC_PTR(mp->port_num, i);
-		u32 addr;
 
 		if ((mp->txq_mask & (1 << i)) == 0)
 			continue;
 
-		addr = (u32)txq->tx_desc_dma;
-		addr += txq->tx_curr_desc * sizeof(struct tx_desc);
-		wrl(mp, off, addr);
-
+		txq_reset_hw_ptr(txq);
 		txq_set_rate(txq, 1000000000, 16777216);
 		txq_set_fixed_prio_mode(txq);
 	}
@@ -1965,6 +2040,9 @@ static int mv643xx_eth_open(struct net_device *dev)
 	napi_enable(&mp->napi);
 #endif
 
+	netif_carrier_off(dev);
+	netif_stop_queue(dev);
+
 	port_start(mp);
 
 	set_rx_coal(mp, 0);
@@ -1999,8 +2077,14 @@ static void port_reset(struct mv643xx_eth_private *mp)
 		if (mp->txq_mask & (1 << i))
 			txq_disable(mp->txq + i);
 	}
-	while (!(rdl(mp, PORT_STATUS(mp->port_num)) & TX_FIFO_EMPTY))
+
+	while (1) {
+		u32 ps = rdl(mp, PORT_STATUS(mp->port_num));
+
+		if ((ps & (TX_IN_PROGRESS | TX_FIFO_EMPTY)) == TX_FIFO_EMPTY)
+			break;
 		udelay(10);
+	}
 
 	/* Reset the Enable bit in the Configuration Register */
 	data = rdl(mp, PORT_SERIAL_CONTROL(mp->port_num));
@@ -2202,7 +2286,8 @@ static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 	int ret;
 
 	if (!mv643xx_eth_version_printed++)
-		printk(KERN_NOTICE "MV-643xx 10/100/1000 Ethernet Driver\n");
+		printk(KERN_NOTICE "MV-643xx 10/100/1000 ethernet "
+			"driver version %s\n", mv643xx_eth_driver_version);
 
 	ret = -EINVAL;
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
@@ -2338,14 +2423,14 @@ static int phy_detect(struct mv643xx_eth_private *mp)
 	unsigned int data;
 	unsigned int data2;
 
-	smi_reg_read(mp, mp->phy_addr, 0, &data);
-	smi_reg_write(mp, mp->phy_addr, 0, data ^ 0x1000);
+	smi_reg_read(mp, mp->phy_addr, MII_BMCR, &data);
+	smi_reg_write(mp, mp->phy_addr, MII_BMCR, data ^ BMCR_ANENABLE);
 
-	smi_reg_read(mp, mp->phy_addr, 0, &data2);
-	if (((data ^ data2) & 0x1000) == 0)
+	smi_reg_read(mp, mp->phy_addr, MII_BMCR, &data2);
+	if (((data ^ data2) & BMCR_ANENABLE) == 0)
 		return -ENODEV;
 
-	smi_reg_write(mp, mp->phy_addr, 0, data);
+	smi_reg_write(mp, mp->phy_addr, MII_BMCR, data);
 
 	return 0;
 }
@@ -2393,12 +2478,39 @@ static int phy_init(struct mv643xx_eth_private *mp,
 		cmd.duplex = pd->duplex;
 	}
 
-	update_pscr(mp, cmd.speed, cmd.duplex);
 	mv643xx_eth_set_settings(mp->dev, &cmd);
 
 	return 0;
 }
 
+static void init_pscr(struct mv643xx_eth_private *mp, int speed, int duplex)
+{
+	u32 pscr;
+
+	pscr = rdl(mp, PORT_SERIAL_CONTROL(mp->port_num));
+	if (pscr & SERIAL_PORT_ENABLE) {
+		pscr &= ~SERIAL_PORT_ENABLE;
+		wrl(mp, PORT_SERIAL_CONTROL(mp->port_num), pscr);
+	}
+
+	pscr = MAX_RX_PACKET_9700BYTE | SERIAL_PORT_CONTROL_RESERVED;
+	if (mp->phy_addr == -1) {
+		pscr |= DISABLE_AUTO_NEG_SPEED_GMII;
+		if (speed == SPEED_1000)
+			pscr |= SET_GMII_SPEED_TO_1000;
+		else if (speed == SPEED_100)
+			pscr |= SET_MII_SPEED_TO_100;
+
+		pscr |= DISABLE_AUTO_NEG_FOR_FLOW_CTRL;
+
+		pscr |= DISABLE_AUTO_NEG_FOR_DUPLEX;
+		if (duplex == DUPLEX_FULL)
+			pscr |= SET_FULL_DUPLEX_MODE;
+	}
+
+	wrl(mp, PORT_SERIAL_CONTROL(mp->port_num), pscr);
+}
+
 static int mv643xx_eth_probe(struct platform_device *pdev)
 {
 	struct mv643xx_eth_platform_data *pd;
@@ -2452,6 +2564,7 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	} else {
 		SET_ETHTOOL_OPS(dev, &mv643xx_eth_ethtool_ops_phyless);
 	}
+	init_pscr(mp, pd->speed, pd->duplex);
 
 
 	res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
@@ -2478,6 +2591,7 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	 * have to map the buffers to ISA memory which is only 16 MB
 	 */
 	dev->features = NETIF_F_SG | NETIF_F_IP_CSUM;
+	dev->vlan_features = NETIF_F_SG | NETIF_F_IP_CSUM;
 #endif
 
 	SET_NETDEV_DEV(dev, &pdev->dev);
diff --git a/drivers/net/ne.c b/drivers/net/ne.c
index 2fec612..42443d6 100644
--- a/drivers/net/ne.c
+++ b/drivers/net/ne.c
@@ -536,7 +536,7 @@ static int __init ne_probe1(struct net_device *dev, unsigned long ioaddr)
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = eip_poll;
 #endif
-	NS8390_init(dev, 0);
+	NS8390p_init(dev, 0);
 
 	ret = register_netdev(dev);
 	if (ret)
@@ -794,7 +794,7 @@ retry:
 		if (time_after(jiffies, dma_start + 2*HZ/100)) {		/* 20ms */
 			printk(KERN_WARNING "%s: timeout waiting for Tx RDC.\n", dev->name);
 			ne_reset_8390(dev);
-			NS8390_init(dev,1);
+			NS8390p_init(dev, 1);
 			break;
 		}
 
@@ -855,7 +855,7 @@ static int ne_drv_resume(struct platform_device *pdev)
 
 	if (netif_running(dev)) {
 		ne_reset_8390(dev);
-		NS8390_init(dev, 1);
+		NS8390p_init(dev, 1);
 		netif_device_attach(dev);
 	}
 	return 0;
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 86d77d0..a2b0730 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -3143,7 +3143,7 @@ static void tx_intr_handler(struct fifo_info *fifo_data)
 		pkt_cnt++;
 
 		/* Updating the statistics block */
-		nic->stats.tx_bytes += skb->len;
+		nic->dev->stats.tx_bytes += skb->len;
 		nic->mac_control.stats_info->sw_stat.mem_freed += skb->truesize;
 		dev_kfree_skb_irq(skb);
 
@@ -4896,25 +4896,42 @@ static struct net_device_stats *s2io_get_stats(struct net_device *dev)
 	/* Configure Stats for immediate updt */
 	s2io_updt_stats(sp);
 
+	/* Using sp->stats as a staging area, because reset (due to mtu
+	   change, for example) will clear some hardware counters */
+	dev->stats.tx_packets +=
+		le32_to_cpu(mac_control->stats_info->tmac_frms) - 
+		sp->stats.tx_packets;
 	sp->stats.tx_packets =
 		le32_to_cpu(mac_control->stats_info->tmac_frms);
+	dev->stats.tx_errors +=
+		le32_to_cpu(mac_control->stats_info->tmac_any_err_frms) -
+		sp->stats.tx_errors;
 	sp->stats.tx_errors =
 		le32_to_cpu(mac_control->stats_info->tmac_any_err_frms);
+	dev->stats.rx_errors +=
+		le64_to_cpu(mac_control->stats_info->rmac_drop_frms) -
+		sp->stats.rx_errors;
 	sp->stats.rx_errors =
 		le64_to_cpu(mac_control->stats_info->rmac_drop_frms);
+	dev->stats.multicast =
+		le32_to_cpu(mac_control->stats_info->rmac_vld_mcst_frms) - 
+		sp->stats.multicast;
 	sp->stats.multicast =
 		le32_to_cpu(mac_control->stats_info->rmac_vld_mcst_frms);
+	dev->stats.rx_length_errors =
+		le64_to_cpu(mac_control->stats_info->rmac_long_frms) - 
+		sp->stats.rx_length_errors;
 	sp->stats.rx_length_errors =
 		le64_to_cpu(mac_control->stats_info->rmac_long_frms);
 
 	/* collect per-ring rx_packets and rx_bytes */
-	sp->stats.rx_packets = sp->stats.rx_bytes = 0;
+	dev->stats.rx_packets = dev->stats.rx_bytes = 0;
 	for (i = 0; i < config->rx_ring_num; i++) {
-		sp->stats.rx_packets += mac_control->rings[i].rx_packets;
-		sp->stats.rx_bytes += mac_control->rings[i].rx_bytes;
+		dev->stats.rx_packets += mac_control->rings[i].rx_packets;
+		dev->stats.rx_bytes += mac_control->rings[i].rx_bytes;
 	}
 
-	return (&sp->stats);
+	return (&dev->stats);
 }
 
 /**
@@ -7419,7 +7436,7 @@ static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp)
 		if (err_mask != 0x5) {
 			DBG_PRINT(ERR_DBG, "%s: Rx error Value: 0x%x\n",
 				dev->name, err_mask);
-			sp->stats.rx_crc_errors++;
+			dev->stats.rx_crc_errors++;
 			sp->mac_control.stats_info->sw_stat.mem_freed
 				+= skb->truesize;
 			dev_kfree_skb(skb);
diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index c69ba13..6a06b95 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -1,7 +1,7 @@
 /*
  *  SuperH Ethernet device driver
  *
- *  Copyright (C) 2006,2007 Nobuhiro Iwamatsu
+ *  Copyright (C) 2006-2008 Nobuhiro Iwamatsu
  *  Copyright (C) 2008 Renesas Solutions Corp.
  *
  *  This program is free software; you can redistribute it and/or modify it
@@ -143,13 +143,39 @@ static struct mdiobb_ops bb_ops = {
 	.get_mdio_data = sh_get_mdio,
 };
 
+/* Chip Reset */
 static void sh_eth_reset(struct net_device *ndev)
 {
 	u32 ioaddr = ndev->base_addr;
 
+#if defined(CONFIG_CPU_SUBTYPE_SH7763)
+	int cnt = 100;
+
+	ctrl_outl(EDSR_ENALL, ioaddr + EDSR);
+	ctrl_outl(ctrl_inl(ioaddr + EDMR) | EDMR_SRST, ioaddr + EDMR);
+	while (cnt > 0) {
+		if (!(ctrl_inl(ioaddr + EDMR) & 0x3))
+			break;
+		mdelay(1);
+		cnt--;
+	}
+	if (cnt < 0)
+		printk(KERN_ERR "Device reset fail\n");
+
+	/* Table Init */
+	ctrl_outl(0x0, ioaddr + TDLAR);
+	ctrl_outl(0x0, ioaddr + TDFAR);
+	ctrl_outl(0x0, ioaddr + TDFXR);
+	ctrl_outl(0x0, ioaddr + TDFFR);
+	ctrl_outl(0x0, ioaddr + RDLAR);
+	ctrl_outl(0x0, ioaddr + RDFAR);
+	ctrl_outl(0x0, ioaddr + RDFXR);
+	ctrl_outl(0x0, ioaddr + RDFFR);
+#else
 	ctrl_outl(ctrl_inl(ioaddr + EDMR) | EDMR_SRST, ioaddr + EDMR);
 	mdelay(3);
 	ctrl_outl(ctrl_inl(ioaddr + EDMR) & ~EDMR_SRST, ioaddr + EDMR);
+#endif
 }
 
 /* free skb and descriptor buffer */
@@ -180,6 +206,7 @@ static void sh_eth_ring_free(struct net_device *ndev)
 /* format skb and descriptor buffer */
 static void sh_eth_ring_format(struct net_device *ndev)
 {
+	u32 ioaddr = ndev->base_addr, reserve = 0;
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 	int i;
 	struct sk_buff *skb;
@@ -201,9 +228,15 @@ static void sh_eth_ring_format(struct net_device *ndev)
 		mdp->rx_skbuff[i] = skb;
 		if (skb == NULL)
 			break;
-		skb->dev = ndev;	/* Mark as being used by this device. */
+		skb->dev = ndev; /* Mark as being used by this device. */
+#if defined(CONFIG_CPU_SUBTYPE_SH7763)
+		reserve = SH7763_SKB_ALIGN
+			- ((uint32_t)skb->data & (SH7763_SKB_ALIGN-1));
+		if (reserve)
+			skb_reserve(skb, reserve);
+#else
 		skb_reserve(skb, RX_OFFSET);
-
+#endif
 		/* RX descriptor */
 		rxdesc = &mdp->rx_ring[i];
 		rxdesc->addr = (u32)skb->data & ~0x3UL;
@@ -211,12 +244,25 @@ static void sh_eth_ring_format(struct net_device *ndev)
 
 		/* The size of the buffer is 16 byte boundary. */
 		rxdesc->buffer_length = (mdp->rx_buf_sz + 16) & ~0x0F;
+		/* Rx descriptor address set */
+		if (i == 0) {
+			ctrl_outl((u32)rxdesc, ioaddr + RDLAR);
+#if defined(CONFIG_CPU_SUBTYPE_SH7763)
+			ctrl_outl((u32)rxdesc, ioaddr + RDFAR);
+#endif
+		}
 	}
 
+	/* Rx descriptor address set */
+#if defined(CONFIG_CPU_SUBTYPE_SH7763)
+	ctrl_outl((u32)rxdesc, ioaddr + RDFXR);
+	ctrl_outl(0x1, ioaddr + RDFFR);
+#endif
+
 	mdp->dirty_rx = (u32) (i - RX_RING_SIZE);
 
 	/* Mark the last entry as wrapping the ring. */
-	rxdesc->status |= cpu_to_le32(RC_RDEL);
+	rxdesc->status |= cpu_to_le32(RD_RDEL);
 
 	memset(mdp->tx_ring, 0, tx_ringsize);
 
@@ -226,8 +272,21 @@ static void sh_eth_ring_format(struct net_device *ndev)
 		txdesc = &mdp->tx_ring[i];
 		txdesc->status = cpu_to_le32(TD_TFP);
 		txdesc->buffer_length = 0;
+		if (i == 0) {
+			/* Rx descriptor address set */
+			ctrl_outl((u32)txdesc, ioaddr + TDLAR);
+#if defined(CONFIG_CPU_SUBTYPE_SH7763)
+			ctrl_outl((u32)txdesc, ioaddr + TDFAR);
+#endif
+		}
 	}
 
+	/* Rx descriptor address set */
+#if defined(CONFIG_CPU_SUBTYPE_SH7763)
+	ctrl_outl((u32)txdesc, ioaddr + TDFXR);
+	ctrl_outl(0x1, ioaddr + TDFFR);
+#endif
+
 	txdesc->status |= cpu_to_le32(TD_TDLE);
 }
 
@@ -311,31 +370,43 @@ static int sh_eth_dev_init(struct net_device *ndev)
 	/* Soft Reset */
 	sh_eth_reset(ndev);
 
-	ctrl_outl(RPADIR_PADS1, ioaddr + RPADIR);	/* SH7712-DMA-RX-PAD2 */
+	/* Descriptor format */
+	sh_eth_ring_format(ndev);
+	ctrl_outl(RPADIR_INIT, ioaddr + RPADIR);
 
 	/* all sh_eth int mask */
 	ctrl_outl(0, ioaddr + EESIPR);
 
-	/* FIFO size set */
+#if defined(CONFIG_CPU_SUBTYPE_SH7763)
+	ctrl_outl(EDMR_EL, ioaddr + EDMR);
+#else
 	ctrl_outl(0, ioaddr + EDMR);	/* Endian change */
+#endif
 
+	/* FIFO size set */
 	ctrl_outl((FIFO_SIZE_T | FIFO_SIZE_R), ioaddr + FDR);
 	ctrl_outl(0, ioaddr + TFTR);
 
+	/* Frame recv control */
 	ctrl_outl(0, ioaddr + RMCR);
 
 	rx_int_var = mdp->rx_int_var = DESC_I_RINT8 | DESC_I_RINT5;
 	tx_int_var = mdp->tx_int_var = DESC_I_TINT2;
 	ctrl_outl(rx_int_var | tx_int_var, ioaddr + TRSCER);
 
+#if defined(CONFIG_CPU_SUBTYPE_SH7763)
+	/* Burst sycle set */
+	ctrl_outl(0x800, ioaddr + BCULR);
+#endif
+
 	ctrl_outl((FIFO_F_D_RFF | FIFO_F_D_RFD), ioaddr + FCFTR);
-	ctrl_outl(0, ioaddr + TRIMD);
 
-	/* Descriptor format */
-	sh_eth_ring_format(ndev);
+#if !defined(CONFIG_CPU_SUBTYPE_SH7763)
+	ctrl_outl(0, ioaddr + TRIMD);
+#endif
 
-	ctrl_outl((u32)mdp->rx_ring, ioaddr + RDLAR);
-	ctrl_outl((u32)mdp->tx_ring, ioaddr + TDLAR);
+	/* Recv frame limit set register */
+	ctrl_outl(RFLR_VALUE, ioaddr + RFLR);
 
 	ctrl_outl(ctrl_inl(ioaddr + EESR), ioaddr + EESR);
 	ctrl_outl((DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff), ioaddr + EESIPR);
@@ -345,21 +416,26 @@ static int sh_eth_dev_init(struct net_device *ndev)
 		ECMR_ZPF | (mdp->duplex ? ECMR_DM : 0) | ECMR_TE | ECMR_RE;
 
 	ctrl_outl(val, ioaddr + ECMR);
-	ctrl_outl(ECSR_BRCRX | ECSR_PSRTO | ECSR_LCHNG | ECSR_ICD |
-		  ECSIPR_MPDIP, ioaddr + ECSR);
-	ctrl_outl(ECSIPR_BRCRXIP | ECSIPR_PSRTOIP | ECSIPR_LCHNGIP |
-		  ECSIPR_ICDIP | ECSIPR_MPDIP, ioaddr + ECSIPR);
+
+	/* E-MAC Status Register clear */
+	ctrl_outl(ECSR_INIT, ioaddr + ECSR);
+
+	/* E-MAC Interrupt Enable register */
+	ctrl_outl(ECSIPR_INIT, ioaddr + ECSIPR);
 
 	/* Set MAC address */
 	update_mac_address(ndev);
 
 	/* mask reset */
-#if defined(CONFIG_CPU_SUBTYPE_SH7710)
+#if defined(CONFIG_CPU_SUBTYPE_SH7710) || defined(CONFIG_CPU_SUBTYPE_SH7763)
 	ctrl_outl(APR_AP, ioaddr + APR);
 	ctrl_outl(MPR_MP, ioaddr + MPR);
 	ctrl_outl(TPAUSER_UNLIMITED, ioaddr + TPAUSER);
+#endif
+#if defined(CONFIG_CPU_SUBTYPE_SH7710)
 	ctrl_outl(BCFR_UNLIMITED, ioaddr + BCFR);
 #endif
+
 	/* Setting the Rx mode will start the Rx process. */
 	ctrl_outl(EDRRR_R, ioaddr + EDRRR);
 
@@ -407,7 +483,7 @@ static int sh_eth_rx(struct net_device *ndev)
 	int boguscnt = (mdp->dirty_rx + RX_RING_SIZE) - mdp->cur_rx;
 	struct sk_buff *skb;
 	u16 pkt_len = 0;
-	u32 desc_status;
+	u32 desc_status, reserve = 0;
 
 	rxdesc = &mdp->rx_ring[entry];
 	while (!(rxdesc->status & cpu_to_le32(RD_RACT))) {
@@ -454,28 +530,38 @@ static int sh_eth_rx(struct net_device *ndev)
 	for (; mdp->cur_rx - mdp->dirty_rx > 0; mdp->dirty_rx++) {
 		entry = mdp->dirty_rx % RX_RING_SIZE;
 		rxdesc = &mdp->rx_ring[entry];
+		/* The size of the buffer is 16 byte boundary. */
+		rxdesc->buffer_length = (mdp->rx_buf_sz + 16) & ~0x0F;
+
 		if (mdp->rx_skbuff[entry] == NULL) {
 			skb = dev_alloc_skb(mdp->rx_buf_sz);
 			mdp->rx_skbuff[entry] = skb;
 			if (skb == NULL)
 				break;	/* Better luck next round. */
 			skb->dev = ndev;
+#if defined(CONFIG_CPU_SUBTYPE_SH7763)
+			reserve = SH7763_SKB_ALIGN
+				- ((uint32_t)skb->data & (SH7763_SKB_ALIGN-1));
+			if (reserve)
+				skb_reserve(skb, reserve);
+#else
 			skb_reserve(skb, RX_OFFSET);
+#endif
+			skb->ip_summed = CHECKSUM_NONE;
 			rxdesc->addr = (u32)skb->data & ~0x3UL;
 		}
-		/* The size of the buffer is 16 byte boundary. */
-		rxdesc->buffer_length = (mdp->rx_buf_sz + 16) & ~0x0F;
 		if (entry >= RX_RING_SIZE - 1)
 			rxdesc->status |=
-			cpu_to_le32(RD_RACT | RD_RFP | RC_RDEL);
+				cpu_to_le32(RD_RACT | RD_RFP | RD_RDEL);
 		else
 			rxdesc->status |=
-			cpu_to_le32(RD_RACT | RD_RFP);
+				cpu_to_le32(RD_RACT | RD_RFP);
 	}
 
 	/* Restart Rx engine if stopped. */
 	/* If we don't need to check status, don't. -KDU */
-	ctrl_outl(EDRRR_R, ndev->base_addr + EDRRR);
+	if (!(ctrl_inl(ndev->base_addr + EDRRR) & EDRRR_R))
+		ctrl_outl(EDRRR_R, ndev->base_addr + EDRRR);
 
 	return 0;
 }
@@ -529,13 +615,14 @@ static void sh_eth_error(struct net_device *ndev, int intr_status)
 			printk(KERN_ERR "Receive Frame Overflow\n");
 		}
 	}
-
+#if !defined(CONFIG_CPU_SUBTYPE_SH7763)
 	if (intr_status & EESR_ADE) {
 		if (intr_status & EESR_TDE) {
 			if (intr_status & EESR_TFE)
 				mdp->stats.tx_fifo_errors++;
 		}
 	}
+#endif
 
 	if (intr_status & EESR_RDE) {
 		/* Receive Descriptor Empty int */
@@ -550,8 +637,11 @@ static void sh_eth_error(struct net_device *ndev, int intr_status)
 		mdp->stats.rx_fifo_errors++;
 		printk(KERN_ERR "Receive FIFO Overflow\n");
 	}
-	if (intr_status &
-	    (EESR_TWB | EESR_TABT | EESR_ADE | EESR_TDE | EESR_TFE)) {
+	if (intr_status & (EESR_TWB | EESR_TABT |
+#if !defined(CONFIG_CPU_SUBTYPE_SH7763)
+			EESR_ADE |
+#endif
+			EESR_TDE | EESR_TFE)) {
 		/* Tx error */
 		u32 edtrr = ctrl_inl(ndev->base_addr + EDTRR);
 		/* dmesg */
@@ -582,17 +672,23 @@ static irqreturn_t sh_eth_interrupt(int irq, void *netdev)
 	ioaddr = ndev->base_addr;
 	spin_lock(&mdp->lock);
 
+	/* Get interrpt stat */
 	intr_status = ctrl_inl(ioaddr + EESR);
 	/* Clear interrupt */
 	ctrl_outl(intr_status, ioaddr + EESR);
 
-	if (intr_status & (EESR_FRC | EESR_RINT8 |
-			   EESR_RINT5 | EESR_RINT4 | EESR_RINT3 | EESR_RINT2 |
-			   EESR_RINT1))
+	if (intr_status & (EESR_FRC | /* Frame recv*/
+			EESR_RMAF | /* Multi cast address recv*/
+			EESR_RRF  | /* Bit frame recv */
+			EESR_RTLF | /* Long frame recv*/
+			EESR_RTSF | /* short frame recv */
+			EESR_PRE  | /* PHY-LSI recv error */
+			EESR_CERF)){ /* recv frame CRC error */
 		sh_eth_rx(ndev);
-	if (intr_status & (EESR_FTC |
-			   EESR_TINT4 | EESR_TINT3 | EESR_TINT2 | EESR_TINT1)) {
+	}
 
+	/* Tx Check */
+	if (intr_status & TX_CHECK) {
 		sh_eth_txfree(ndev);
 		netif_wake_queue(ndev);
 	}
@@ -631,11 +727,32 @@ static void sh_eth_adjust_link(struct net_device *ndev)
 		if (phydev->duplex != mdp->duplex) {
 			new_state = 1;
 			mdp->duplex = phydev->duplex;
+#if defined(CONFIG_CPU_SUBTYPE_SH7763)
+			if (mdp->duplex) { /*  FULL */
+				ctrl_outl(ctrl_inl(ioaddr + ECMR) | ECMR_DM,
+						ioaddr + ECMR);
+			} else {	/* Half */
+				ctrl_outl(ctrl_inl(ioaddr + ECMR) & ~ECMR_DM,
+						ioaddr + ECMR);
+			}
+#endif
 		}
 
 		if (phydev->speed != mdp->speed) {
 			new_state = 1;
 			mdp->speed = phydev->speed;
+#if defined(CONFIG_CPU_SUBTYPE_SH7763)
+			switch (mdp->speed) {
+			case 10: /* 10BASE */
+				ctrl_outl(GECMR_10, ioaddr + GECMR); break;
+			case 100:/* 100BASE */
+				ctrl_outl(GECMR_100, ioaddr + GECMR); break;
+			case 1000: /* 1000BASE */
+				ctrl_outl(GECMR_1000, ioaddr + GECMR); break;
+			default:
+				break;
+			}
+#endif
 		}
 		if (mdp->link == PHY_DOWN) {
 			ctrl_outl((ctrl_inl(ioaddr + ECMR) & ~ECMR_TXF)
@@ -730,7 +847,7 @@ static int sh_eth_open(struct net_device *ndev)
 	/* Set the timer to check for link beat. */
 	init_timer(&mdp->timer);
 	mdp->timer.expires = (jiffies + (24 * HZ)) / 10;/* 2.4 sec. */
-	setup_timer(&mdp->timer, sh_eth_timer, ndev);
+	setup_timer(&mdp->timer, sh_eth_timer, (unsigned long)ndev);
 
 	return ret;
 
@@ -820,7 +937,9 @@ static int sh_eth_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 
 	mdp->cur_tx++;
 
-	ctrl_outl(EDTRR_TRNS, ndev->base_addr + EDTRR);
+	if (!(ctrl_inl(ndev->base_addr + EDTRR) & EDTRR_TRNS))
+		ctrl_outl(EDTRR_TRNS, ndev->base_addr + EDTRR);
+
 	ndev->trans_start = jiffies;
 
 	return 0;
@@ -877,9 +996,15 @@ static struct net_device_stats *sh_eth_get_stats(struct net_device *ndev)
 	ctrl_outl(0, ioaddr + CDCR);	/* (write clear) */
 	mdp->stats.tx_carrier_errors += ctrl_inl(ioaddr + LCCR);
 	ctrl_outl(0, ioaddr + LCCR);	/* (write clear) */
+#if defined(CONFIG_CPU_SUBTYPE_SH7763)
+	mdp->stats.tx_carrier_errors += ctrl_inl(ioaddr + CERCR);/* CERCR */
+	ctrl_outl(0, ioaddr + CERCR);	/* (write clear) */
+	mdp->stats.tx_carrier_errors += ctrl_inl(ioaddr + CEECR);/* CEECR */
+	ctrl_outl(0, ioaddr + CEECR);	/* (write clear) */
+#else
 	mdp->stats.tx_carrier_errors += ctrl_inl(ioaddr + CNDCR);
 	ctrl_outl(0, ioaddr + CNDCR);	/* (write clear) */
-
+#endif
 	return &mdp->stats;
 }
 
@@ -929,8 +1054,13 @@ static void sh_eth_tsu_init(u32 ioaddr)
 	ctrl_outl(0, ioaddr + TSU_FWSL0);
 	ctrl_outl(0, ioaddr + TSU_FWSL1);
 	ctrl_outl(TSU_FWSLC_POSTENU | TSU_FWSLC_POSTENL, ioaddr + TSU_FWSLC);
+#if defined(CONFIG_CPU_SUBTYPE_SH7763)
+	ctrl_outl(0, ioaddr + TSU_QTAG0);	/* Disable QTAG(0->1) */
+	ctrl_outl(0, ioaddr + TSU_QTAG1);	/* Disable QTAG(1->0) */
+#else
 	ctrl_outl(0, ioaddr + TSU_QTAGM0);	/* Disable QTAG(0->1) */
 	ctrl_outl(0, ioaddr + TSU_QTAGM1);	/* Disable QTAG(1->0) */
+#endif
 	ctrl_outl(0, ioaddr + TSU_FWSR);	/* all interrupt status clear */
 	ctrl_outl(0, ioaddr + TSU_FWINMK);	/* Disable all interrupt */
 	ctrl_outl(0, ioaddr + TSU_TEN);	/* Disable all CAM entry */
@@ -1088,7 +1218,7 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 	/* First device only init */
 	if (!devno) {
 		/* reset device */
-		ctrl_outl(ARSTR_ARSTR, ndev->base_addr + ARSTR);
+		ctrl_outl(ARSTR_ARSTR, ARSTR);
 		mdelay(1);
 
 		/* TSU init (Init only)*/
@@ -1110,8 +1240,8 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 	       ndev->name, CARDNAME, (u32) ndev->base_addr);
 
 	for (i = 0; i < 5; i++)
-		printk(KERN_INFO "%2.2x:", ndev->dev_addr[i]);
-	printk(KERN_INFO "%2.2x, IRQ %d.\n", ndev->dev_addr[i], ndev->irq);
+		printk(KERN_INFO "%02X:", ndev->dev_addr[i]);
+	printk(KERN_INFO "%02X, IRQ %d.\n", ndev->dev_addr[i], ndev->irq);
 
 	platform_set_drvdata(pdev, ndev);
 
diff --git a/drivers/net/sh_eth.h b/drivers/net/sh_eth.h
index e01e1c3..45ad1b0 100644
--- a/drivers/net/sh_eth.h
+++ b/drivers/net/sh_eth.h
@@ -32,118 +32,249 @@
 
 #define CARDNAME	"sh-eth"
 #define TX_TIMEOUT	(5*HZ)
-
-#define TX_RING_SIZE	128	/* Tx ring size */
-#define RX_RING_SIZE	128	/* Rx ring size */
-#define RX_OFFSET		2	/* skb offset */
+#define TX_RING_SIZE	64	/* Tx ring size */
+#define RX_RING_SIZE	64	/* Rx ring size */
 #define ETHERSMALL		60
 #define PKT_BUF_SZ		1538
 
+#ifdef CONFIG_CPU_SUBTYPE_SH7763
+
+#define SH7763_SKB_ALIGN 32
 /* Chip Base Address */
-#define SH_TSU_ADDR 0xA7000804
+# define SH_TSU_ADDR  0xFFE01800
+# define ARSTR 		  0xFFE01800
+
+/* Chip Registers */
+/* E-DMAC */
+# define EDSR    0x000
+# define EDMR    0x400
+# define EDTRR   0x408
+# define EDRRR   0x410
+# define EESR    0x428
+# define EESIPR  0x430
+# define TDLAR   0x010
+# define TDFAR   0x014
+# define TDFXR   0x018
+# define TDFFR   0x01C
+# define RDLAR   0x030
+# define RDFAR   0x034
+# define RDFXR   0x038
+# define RDFFR   0x03C
+# define TRSCER  0x438
+# define RMFCR   0x440
+# define TFTR    0x448
+# define FDR     0x450
+# define RMCR    0x458
+# define RPADIR  0x460
+# define FCFTR   0x468
+
+/* Ether Register */
+# define ECMR    0x500
+# define ECSR    0x510
+# define ECSIPR  0x518
+# define PIR     0x520
+# define PSR     0x528
+# define PIPR    0x52C
+# define RFLR    0x508
+# define APR     0x554
+# define MPR     0x558
+# define PFTCR	 0x55C
+# define PFRCR	 0x560
+# define TPAUSER 0x564
+# define GECMR   0x5B0
+# define BCULR   0x5B4
+# define MAHR    0x5C0
+# define MALR    0x5C8
+# define TROCR   0x700
+# define CDCR    0x708
+# define LCCR    0x710
+# define CEFCR   0x740
+# define FRECR   0x748
+# define TSFRCR  0x750
+# define TLFRCR  0x758
+# define RFCR    0x760
+# define CERCR   0x768
+# define CEECR   0x770
+# define MAFCR   0x778
+
+/* TSU Absolute Address */
+# define TSU_CTRST       0x004
+# define TSU_FWEN0       0x010
+# define TSU_FWEN1       0x014
+# define TSU_FCM         0x18
+# define TSU_BSYSL0      0x20
+# define TSU_BSYSL1      0x24
+# define TSU_PRISL0      0x28
+# define TSU_PRISL1      0x2C
+# define TSU_FWSL0       0x30
+# define TSU_FWSL1       0x34
+# define TSU_FWSLC       0x38
+# define TSU_QTAG0       0x40
+# define TSU_QTAG1       0x44
+# define TSU_FWSR        0x50
+# define TSU_FWINMK      0x54
+# define TSU_ADQT0       0x48
+# define TSU_ADQT1       0x4C
+# define TSU_VTAG0       0x58
+# define TSU_VTAG1       0x5C
+# define TSU_ADSBSY      0x60
+# define TSU_TEN         0x64
+# define TSU_POST1       0x70
+# define TSU_POST2       0x74
+# define TSU_POST3       0x78
+# define TSU_POST4       0x7C
+# define TSU_ADRH0       0x100
+# define TSU_ADRL0       0x104
+# define TSU_ADRH31      0x1F8
+# define TSU_ADRL31      0x1FC
+
+# define TXNLCR0         0x80
+# define TXALCR0         0x84
+# define RXNLCR0         0x88
+# define RXALCR0         0x8C
+# define FWNLCR0         0x90
+# define FWALCR0         0x94
+# define TXNLCR1         0xA0
+# define TXALCR1         0xA4
+# define RXNLCR1         0xA8
+# define RXALCR1         0xAC
+# define FWNLCR1         0xB0
+# define FWALCR1         0x40
+
+#else /* CONFIG_CPU_SUBTYPE_SH7763 */
+# define RX_OFFSET 2	/* skb offset */
+/* Chip base address */
+# define SH_TSU_ADDR  0xA7000804
+# define ARSTR		  0xA7000800
 
 /* Chip Registers */
 /* E-DMAC */
-#define EDMR	0x0000
-#define EDTRR	0x0004
-#define EDRRR	0x0008
-#define TDLAR	0x000C
-#define RDLAR	0x0010
-#define EESR	0x0014
-#define EESIPR	0x0018
-#define TRSCER	0x001C
-#define RMFCR	0x0020
-#define TFTR	0x0024
-#define FDR		0x0028
-#define RMCR	0x002C
-#define EDOCR	0x0030
-#define FCFTR	0x0034
-#define RPADIR	0x0038
-#define TRIMD	0x003C
-#define RBWAR	0x0040
-#define RDFAR	0x0044
-#define TBRAR	0x004C
-#define TDFAR	0x0050
+# define EDMR	0x0000
+# define EDTRR	0x0004
+# define EDRRR	0x0008
+# define TDLAR	0x000C
+# define RDLAR	0x0010
+# define EESR	0x0014
+# define EESIPR	0x0018
+# define TRSCER	0x001C
+# define RMFCR	0x0020
+# define TFTR	0x0024
+# define FDR	0x0028
+# define RMCR	0x002C
+# define EDOCR	0x0030
+# define FCFTR	0x0034
+# define RPADIR	0x0038
+# define TRIMD	0x003C
+# define RBWAR	0x0040
+# define RDFAR	0x0044
+# define TBRAR	0x004C
+# define TDFAR	0x0050
+
 /* Ether Register */
-#define ECMR	0x0160
-#define ECSR	0x0164
-#define ECSIPR	0x0168
-#define PIR		0x016C
-#define MAHR	0x0170
-#define MALR	0x0174
-#define RFLR	0x0178
-#define PSR		0x017C
-#define TROCR	0x0180
-#define CDCR	0x0184
-#define LCCR	0x0188
-#define CNDCR	0x018C
-#define CEFCR	0x0194
-#define FRECR	0x0198
-#define TSFRCR	0x019C
-#define TLFRCR	0x01A0
-#define RFCR	0x01A4
-#define MAFCR	0x01A8
-#define IPGR	0x01B4
-#if defined(CONFIG_CPU_SUBTYPE_SH7710)
-#define APR		0x01B8
-#define MPR 	0x01BC
-#define TPAUSER 0x1C4
-#define BCFR	0x1CC
-#endif /* CONFIG_CPU_SH7710 */
-
-#define ARSTR	0x0800
+# define ECMR	0x0160
+# define ECSR	0x0164
+# define ECSIPR	0x0168
+# define PIR	0x016C
+# define MAHR	0x0170
+# define MALR	0x0174
+# define RFLR	0x0178
+# define PSR	0x017C
+# define TROCR	0x0180
+# define CDCR	0x0184
+# define LCCR	0x0188
+# define CNDCR	0x018C
+# define CEFCR	0x0194
+# define FRECR	0x0198
+# define TSFRCR	0x019C
+# define TLFRCR	0x01A0
+# define RFCR	0x01A4
+# define MAFCR	0x01A8
+# define IPGR	0x01B4
+# if defined(CONFIG_CPU_SUBTYPE_SH7710)
+# define APR	0x01B8
+# define MPR 	0x01BC
+# define TPAUSER 0x1C4
+# define BCFR	0x1CC
+# endif /* CONFIG_CPU_SH7710 */
 
 /* TSU */
-#define TSU_CTRST	0x004
-#define TSU_FWEN0	0x010
-#define TSU_FWEN1	0x014
-#define TSU_FCM		0x018
-#define TSU_BSYSL0	0x020
-#define TSU_BSYSL1	0x024
-#define TSU_PRISL0	0x028
-#define TSU_PRISL1	0x02C
-#define TSU_FWSL0	0x030
-#define TSU_FWSL1	0x034
-#define TSU_FWSLC	0x038
-#define TSU_QTAGM0	0x040
-#define TSU_QTAGM1	0x044
-#define TSU_ADQT0 	0x048
-#define TSU_ADQT1	0x04C
-#define TSU_FWSR	0x050
-#define TSU_FWINMK	0x054
-#define TSU_ADSBSY	0x060
-#define TSU_TEN		0x064
-#define TSU_POST1	0x070
-#define TSU_POST2	0x074
-#define TSU_POST3	0x078
-#define TSU_POST4	0x07C
-#define TXNLCR0		0x080
-#define TXALCR0		0x084
-#define RXNLCR0		0x088
-#define RXALCR0		0x08C
-#define FWNLCR0		0x090
-#define FWALCR0		0x094
-#define TXNLCR1		0x0A0
-#define TXALCR1		0x0A4
-#define RXNLCR1		0x0A8
-#define RXALCR1		0x0AC
-#define FWNLCR1		0x0B0
-#define FWALCR1		0x0B4
+# define TSU_CTRST	0x004
+# define TSU_FWEN0	0x010
+# define TSU_FWEN1	0x014
+# define TSU_FCM	0x018
+# define TSU_BSYSL0	0x020
+# define TSU_BSYSL1	0x024
+# define TSU_PRISL0	0x028
+# define TSU_PRISL1	0x02C
+# define TSU_FWSL0	0x030
+# define TSU_FWSL1	0x034
+# define TSU_FWSLC	0x038
+# define TSU_QTAGM0	0x040
+# define TSU_QTAGM1	0x044
+# define TSU_ADQT0 	0x048
+# define TSU_ADQT1	0x04C
+# define TSU_FWSR	0x050
+# define TSU_FWINMK	0x054
+# define TSU_ADSBSY	0x060
+# define TSU_TEN	0x064
+# define TSU_POST1	0x070
+# define TSU_POST2	0x074
+# define TSU_POST3	0x078
+# define TSU_POST4	0x07C
+# define TXNLCR0	0x080
+# define TXALCR0	0x084
+# define RXNLCR0	0x088
+# define RXALCR0	0x08C
+# define FWNLCR0	0x090
+# define FWALCR0	0x094
+# define TXNLCR1	0x0A0
+# define TXALCR1	0x0A4
+# define RXNLCR1	0x0A8
+# define RXALCR1	0x0AC
+# define FWNLCR1	0x0B0
+# define FWALCR1	0x0B4
 
 #define TSU_ADRH0	0x0100
 #define TSU_ADRL0	0x0104
 #define TSU_ADRL31	0x01FC
 
-/* Register's bits */
+#endif /* CONFIG_CPU_SUBTYPE_SH7763 */
+
+/*
+ * Register's bits
+ */
+#ifdef CONFIG_CPU_SUBTYPE_SH7763
+/* EDSR */
+enum EDSR_BIT {
+	EDSR_ENT = 0x01, EDSR_ENR = 0x02,
+};
+#define EDSR_ENALL (EDSR_ENT|EDSR_ENR)
+
+/* GECMR */
+enum GECMR_BIT {
+	GECMR_10 = 0x0, GECMR_100 = 0x04, GECMR_1000 = 0x01,
+};
+#endif
 
 /* EDMR */
 enum DMAC_M_BIT {
-	EDMR_DL1 = 0x20, EDMR_DL0 = 0x10, EDMR_SRST = 0x01,
+	EDMR_DL1 = 0x20, EDMR_DL0 = 0x10,
+#ifdef CONFIG_CPU_SUBTYPE_SH7763
+	EDMR_SRST	= 0x03,
+	EMDR_DESC_R	= 0x30, /* Descriptor reserve size */
+	EDMR_EL		= 0x40, /* Litte endian */
+#else /* CONFIG_CPU_SUBTYPE_SH7763 */
+	EDMR_SRST = 0x01,
+#endif
 };
 
 /* EDTRR */
 enum DMAC_T_BIT {
+#ifdef CONFIG_CPU_SUBTYPE_SH7763
+	EDTRR_TRNS = 0x03,
+#else
 	EDTRR_TRNS = 0x01,
+#endif
 };
 
 /* EDRRR*/
@@ -173,21 +304,47 @@ enum PHY_STATUS_BIT { PHY_ST_LINK = 0x01, };
 
 /* EESR */
 enum EESR_BIT {
-	EESR_TWB = 0x40000000, EESR_TABT = 0x04000000,
+#ifndef CONFIG_CPU_SUBTYPE_SH7763
+	EESR_TWB  = 0x40000000,
+#else
+	EESR_TWB  = 0xC0000000,
+	EESR_TC1  = 0x20000000,
+	EESR_TUC  = 0x10000000,
+	EESR_ROC  = 0x80000000,
+#endif
+	EESR_TABT = 0x04000000,
 	EESR_RABT = 0x02000000, EESR_RFRMER = 0x01000000,
-	EESR_ADE = 0x00800000, EESR_ECI = 0x00400000,
-	EESR_FTC = 0x00200000, EESR_TDE = 0x00100000,
-	EESR_TFE = 0x00080000, EESR_FRC = 0x00040000,
-	EESR_RDE = 0x00020000, EESR_RFE = 0x00010000,
-	EESR_TINT4 = 0x00000800, EESR_TINT3 = 0x00000400,
-	EESR_TINT2 = 0x00000200, EESR_TINT1 = 0x00000100,
-	EESR_RINT8 = 0x00000080, EESR_RINT5 = 0x00000010,
-	EESR_RINT4 = 0x00000008, EESR_RINT3 = 0x00000004,
-	EESR_RINT2 = 0x00000002, EESR_RINT1 = 0x00000001,
-};
-
-#define EESR_ERR_CHECK	(EESR_TWB | EESR_TABT | EESR_RABT | EESR_RDE \
+#ifndef CONFIG_CPU_SUBTYPE_SH7763
+	EESR_ADE  = 0x00800000,
+#endif
+	EESR_ECI  = 0x00400000,
+	EESR_FTC  = 0x00200000, EESR_TDE  = 0x00100000,
+	EESR_TFE  = 0x00080000, EESR_FRC  = 0x00040000,
+	EESR_RDE  = 0x00020000, EESR_RFE  = 0x00010000,
+#ifndef CONFIG_CPU_SUBTYPE_SH7763
+	EESR_CND  = 0x00000800,
+#endif
+	EESR_DLC  = 0x00000400,
+	EESR_CD   = 0x00000200, EESR_RTO  = 0x00000100,
+	EESR_RMAF = 0x00000080, EESR_CEEF = 0x00000040,
+	EESR_CELF = 0x00000020, EESR_RRF  = 0x00000010,
+	EESR_RTLF = 0x00000008, EESR_RTSF = 0x00000004,
+	EESR_PRE  = 0x00000002, EESR_CERF = 0x00000001,
+};
+
+
+#ifdef CONFIG_CPU_SUBTYPE_SH7763
+# define TX_CHECK (EESR_TC1 | EESR_FTC)
+# define EESR_ERR_CHECK	(EESR_TWB | EESR_TABT | EESR_RABT | EESR_RDE \
+		| EESR_RFRMER | EESR_TFE | EESR_TDE | EESR_ECI)
+# define TX_ERROR_CEHCK (EESR_TWB | EESR_TABT | EESR_TDE | EESR_TFE)
+
+#else
+# define TX_CHECK (EESR_FTC | EESR_CND | EESR_DLC | EESR_CD | EESR_RTO)
+# define EESR_ERR_CHECK	(EESR_TWB | EESR_TABT | EESR_RABT | EESR_RDE \
 		| EESR_RFRMER | EESR_ADE | EESR_TFE | EESR_TDE | EESR_ECI)
+# define TX_ERROR_CEHCK (EESR_TWB | EESR_TABT | EESR_ADE | EESR_TDE | EESR_TFE)
+#endif
 
 /* EESIPR */
 enum DMAC_IM_BIT {
@@ -207,8 +364,8 @@ enum DMAC_IM_BIT {
 
 /* Receive descriptor bit */
 enum RD_STS_BIT {
-	RD_RACT = 0x80000000, RC_RDEL = 0x40000000,
-	RC_RFP1 = 0x20000000, RC_RFP0 = 0x10000000,
+	RD_RACT = 0x80000000, RD_RDEL = 0x40000000,
+	RD_RFP1 = 0x20000000, RD_RFP0 = 0x10000000,
 	RD_RFE = 0x08000000, RD_RFS10 = 0x00000200,
 	RD_RFS9 = 0x00000100, RD_RFS8 = 0x00000080,
 	RD_RFS7 = 0x00000040, RD_RFS6 = 0x00000020,
@@ -216,9 +373,9 @@ enum RD_STS_BIT {
 	RD_RFS3 = 0x00000004, RD_RFS2 = 0x00000002,
 	RD_RFS1 = 0x00000001,
 };
-#define RDF1ST	RC_RFP1
-#define RDFEND	RC_RFP0
-#define RD_RFP	(RC_RFP1|RC_RFP0)
+#define RDF1ST	RD_RFP1
+#define RDFEND	RD_RFP0
+#define RD_RFP	(RD_RFP1|RD_RFP0)
 
 /* FCFTR */
 enum FCFTR_BIT {
@@ -231,7 +388,8 @@ enum FCFTR_BIT {
 
 /* Transfer descriptor bit */
 enum TD_STS_BIT {
-	TD_TACT = 0x80000000, TD_TDLE = 0x40000000, TD_TFP1 = 0x20000000,
+	TD_TACT = 0x80000000,
+	TD_TDLE = 0x40000000, TD_TFP1 = 0x20000000,
 	TD_TFP0 = 0x10000000,
 };
 #define TDF1ST	TD_TFP1
@@ -242,6 +400,10 @@ enum TD_STS_BIT {
 enum RECV_RST_BIT { RMCR_RST = 0x01, };
 /* ECMR */
 enum FELIC_MODE_BIT {
+#ifdef CONFIG_CPU_SUBTYPE_SH7763
+	ECMR_TRCCM = 0x04000000, ECMR_RCSC = 0x00800000,
+	ECMR_DPAD = 0x00200000, ECMR_RZPF = 0x00100000,
+#endif
 	ECMR_ZPF = 0x00080000, ECMR_PFR = 0x00040000, ECMR_RXF = 0x00020000,
 	ECMR_TXF = 0x00010000, ECMR_MCT = 0x00002000, ECMR_PRCEF = 0x00001000,
 	ECMR_PMDE = 0x00000200, ECMR_RE = 0x00000040, ECMR_TE = 0x00000020,
@@ -249,18 +411,45 @@ enum FELIC_MODE_BIT {
 	ECMR_PRM = 0x00000001,
 };
 
+#ifdef CONFIG_CPU_SUBTYPE_SH7763
+#define ECMR_CHG_DM	(ECMR_TRCCM | ECMR_RZPF | ECMR_ZPF |\
+			ECMR_PFR | ECMR_RXF | ECMR_TXF | ECMR_MCT)
+#else
+#define ECMR_CHG_DM	(ECMR_ZPF | ECMR_PFR ECMR_RXF | ECMR_TXF | ECMR_MCT)
+#endif
+
 /* ECSR */
 enum ECSR_STATUS_BIT {
-	ECSR_BRCRX = 0x20, ECSR_PSRTO = 0x10, ECSR_LCHNG = 0x04,
+#ifndef CONFIG_CPU_SUBTYPE_SH7763
+	ECSR_BRCRX = 0x20, ECSR_PSRTO = 0x10,
+#endif
+	ECSR_LCHNG = 0x04,
 	ECSR_MPD = 0x02, ECSR_ICD = 0x01,
 };
 
+#ifdef CONFIG_CPU_SUBTYPE_SH7763
+# define ECSR_INIT (ECSR_ICD | ECSIPR_MPDIP)
+#else
+# define ECSR_INIT (ECSR_BRCRX | ECSR_PSRTO | \
+			ECSR_LCHNG | ECSR_ICD | ECSIPR_MPDIP)
+#endif
+
 /* ECSIPR */
 enum ECSIPR_STATUS_MASK_BIT {
-	ECSIPR_BRCRXIP = 0x20, ECSIPR_PSRTOIP = 0x10, ECSIPR_LCHNGIP = 0x04,
+#ifndef CONFIG_CPU_SUBTYPE_SH7763
+	ECSIPR_BRCRXIP = 0x20, ECSIPR_PSRTOIP = 0x10,
+#endif
+	ECSIPR_LCHNGIP = 0x04,
 	ECSIPR_MPDIP = 0x02, ECSIPR_ICDIP = 0x01,
 };
 
+#ifdef CONFIG_CPU_SUBTYPE_SH7763
+# define ECSIPR_INIT (ECSIPR_LCHNGIP | ECSIPR_ICDIP | ECSIPR_MPDIP)
+#else
+# define ECSIPR_INIT (ECSIPR_BRCRXIP | ECSIPR_PSRTOIP | ECSIPR_LCHNGIP | \
+				ECSIPR_ICDIP | ECSIPR_MPDIP)
+#endif
+
 /* APR */
 enum APR_BIT {
 	APR_AP = 0x00000001,
@@ -285,6 +474,15 @@ enum RPADIR_BIT {
 	RPADIR_PADR = 0x0003f,
 };
 
+#if defined(CONFIG_CPU_SUBTYPE_SH7763)
+# define RPADIR_INIT (0x00)
+#else
+# define RPADIR_INIT (RPADIR_PADS1)
+#endif
+
+/* RFLR */
+#define RFLR_VALUE 0x1000
+
 /* FDR */
 enum FIFO_SIZE_BIT {
 	FIFO_SIZE_T = 0x00000700, FIFO_SIZE_R = 0x00000007,
@@ -316,7 +514,7 @@ enum PHY_ANA_BIT {
 	PHY_A_NP = 0x8000, PHY_A_ACK = 0x4000, PHY_A_RF = 0x2000,
 	PHY_A_FCS = 0x0400, PHY_A_T4 = 0x0200, PHY_A_FDX = 0x0100,
 	PHY_A_HDX = 0x0080, PHY_A_10FDX = 0x0040, PHY_A_10HDX = 0x0020,
-	PHY_A_SEL = 0x001f,
+	PHY_A_SEL = 0x001e,
 };
 /* PHY_ANL */
 enum PHY_ANL_BIT {
@@ -449,6 +647,10 @@ struct sh_eth_private {
 	struct net_device_stats tsu_stats;	/* TSU forward status */
 };
 
+#ifdef CONFIG_CPU_SUBTYPE_SH7763
+/* SH7763 has endian control register */
+#define swaps(x, y)
+#else
 static void swaps(char *src, int len)
 {
 #ifdef __LITTLE_ENDIAN__
@@ -460,5 +662,5 @@ static void swaps(char *src, int len)
 		*p = swab32(*p);
 #endif
 }
-
+#endif /* CONFIG_CPU_SUBTYPE_SH7763 */
 #endif
diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index f7319d3..78df2be 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -55,12 +55,28 @@
 
 static int dm_read(struct usbnet *dev, u8 reg, u16 length, void *data)
 {
+	void *buf;
+	int err = -ENOMEM;
+
 	devdbg(dev, "dm_read() reg=0x%02x length=%d", reg, length);
-	return usb_control_msg(dev->udev,
-			       usb_rcvctrlpipe(dev->udev, 0),
-			       DM_READ_REGS,
-			       USB_DIR_IN | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
-			       0, reg, data, length, USB_CTRL_SET_TIMEOUT);
+
+	buf = kmalloc(length, GFP_KERNEL);
+	if (!buf)
+		goto out;
+
+	err = usb_control_msg(dev->udev,
+			      usb_rcvctrlpipe(dev->udev, 0),
+			      DM_READ_REGS,
+			      USB_DIR_IN | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
+			      0, reg, buf, length, USB_CTRL_SET_TIMEOUT);
+	if (err == length)
+		memcpy(data, buf, length);
+	else if (err >= 0)
+		err = -EINVAL;
+	kfree(buf);
+
+ out:
+	return err;
 }
 
 static int dm_read_reg(struct usbnet *dev, u8 reg, u8 *value)
@@ -70,12 +86,28 @@ static int dm_read_reg(struct usbnet *dev, u8 reg, u8 *value)
 
 static int dm_write(struct usbnet *dev, u8 reg, u16 length, void *data)
 {
+	void *buf = NULL;
+	int err = -ENOMEM;
+
 	devdbg(dev, "dm_write() reg=0x%02x, length=%d", reg, length);
-	return usb_control_msg(dev->udev,
-			       usb_sndctrlpipe(dev->udev, 0),
-			       DM_WRITE_REGS,
-			       USB_DIR_OUT | USB_TYPE_VENDOR |USB_RECIP_DEVICE,
-			       0, reg, data, length, USB_CTRL_SET_TIMEOUT);
+
+	if (data) {
+		buf = kmalloc(length, GFP_KERNEL);
+		if (!buf)
+			goto out;
+		memcpy(buf, data, length);
+	}
+
+	err = usb_control_msg(dev->udev,
+			      usb_sndctrlpipe(dev->udev, 0),
+			      DM_WRITE_REGS,
+			      USB_DIR_OUT | USB_TYPE_VENDOR |USB_RECIP_DEVICE,
+			      0, reg, buf, length, USB_CTRL_SET_TIMEOUT);
+	kfree(buf);
+	if (err >= 0 && err < length)
+		err = -EINVAL;
+ out:
+	return err;
 }
 
 static int dm_write_reg(struct usbnet *dev, u8 reg, u8 value)
diff --git a/drivers/net/wd.c b/drivers/net/wd.c
index fa14255..6f9aa16 100644
--- a/drivers/net/wd.c
+++ b/drivers/net/wd.c
@@ -337,7 +337,7 @@ static int __init wd_probe1(struct net_device *dev, int ioaddr)
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = ei_poll;
 #endif
-	NS8390_init(dev, 0);
+	NS8390p_init(dev, 0);
 
 #if 1
 	/* Enable interrupt generation on softconfig cards -- M.U */
