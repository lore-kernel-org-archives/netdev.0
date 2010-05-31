From: Steven Walter <stevenrwalter@gmail.com>
Subject: [PATCH 2/2] tulip: implement wake-on-lan support
Date: Mon, 31 May 2010 18:34:43 -0400
Message-ID: <1275345283-10650-2-git-send-email-stevenrwalter@gmail.com>
References: <1275345283-10650-1-git-send-email-stevenrwalter@gmail.com>
Cc: Steven Walter <stevenrwalter@gmail.com>
To: grundler@parisc-linux.org, kyle@mcmartin.ca, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:41553 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753909Ab0EaWfE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 May 2010 18:35:04 -0400
Received: by gye5 with SMTP id 5so628254gye.19
        for <netdev@vger.kernel.org>; Mon, 31 May 2010 15:35:03 -0700 (PDT)
In-Reply-To: <1275345283-10650-1-git-send-email-stevenrwalter@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on a patch from http://simon.baatz.info/wol-support-for-an983b/

Tested to resume from suspend by magic packet.

Signed-off-by: Steven Walter <stevenrwalter@gmail.com>
---
 drivers/net/tulip/tulip.h      |   64 +++++++++++++++++------
 drivers/net/tulip/tulip_core.c |  115 +++++++++++++++++++++++++++++++++++++---
 2 files changed, 156 insertions(+), 23 deletions(-)

diff --git a/drivers/net/tulip/tulip.h b/drivers/net/tulip/tulip.h
index 0afa2d4..e525875 100644
--- a/drivers/net/tulip/tulip.h
+++ b/drivers/net/tulip/tulip.h
@@ -20,6 +20,7 @@
 #include <linux/types.h>
 #include <linux/spinlock.h>
 #include <linux/netdevice.h>
+#include <linux/ethtool.h>
 #include <linux/timer.h>
 #include <linux/delay.h>
 #include <linux/pci.h>
@@ -51,22 +52,23 @@ struct tulip_chip_table {
 
 
 enum tbl_flag {
-	HAS_MII			= 0x0001,
-	HAS_MEDIA_TABLE		= 0x0002,
-	CSR12_IN_SROM		= 0x0004,
-	ALWAYS_CHECK_MII	= 0x0008,
-	HAS_ACPI		= 0x0010,
-	MC_HASH_ONLY		= 0x0020, /* Hash-only multicast filter. */
-	HAS_PNICNWAY		= 0x0080,
-	HAS_NWAY		= 0x0040, /* Uses internal NWay xcvr. */
-	HAS_INTR_MITIGATION	= 0x0100,
-	IS_ASIX			= 0x0200,
-	HAS_8023X		= 0x0400,
-	COMET_MAC_ADDR		= 0x0800,
-	HAS_PCI_MWI		= 0x1000,
-	HAS_PHY_IRQ		= 0x2000,
-	HAS_SWAPPED_SEEPROM	= 0x4000,
-	NEEDS_FAKE_MEDIA_TABLE	= 0x8000,
+	HAS_MII			= 0x00001,
+	HAS_MEDIA_TABLE		= 0x00002,
+	CSR12_IN_SROM		= 0x00004,
+	ALWAYS_CHECK_MII	= 0x00008,
+	HAS_ACPI		= 0x00010,
+	MC_HASH_ONLY		= 0x00020, /* Hash-only multicast filter. */
+	HAS_PNICNWAY		= 0x00080,
+	HAS_NWAY		= 0x00040, /* Uses internal NWay xcvr. */
+	HAS_INTR_MITIGATION	= 0x00100,
+	IS_ASIX			= 0x00200,
+	HAS_8023X		= 0x00400,
+	COMET_MAC_ADDR		= 0x00800,
+	HAS_PCI_MWI		= 0x01000,
+	HAS_PHY_IRQ		= 0x02000,
+	HAS_SWAPPED_SEEPROM	= 0x04000,
+	NEEDS_FAKE_MEDIA_TABLE	= 0x08000,
+	COMET_PM		= 0x10000,
 };
 
 
@@ -120,6 +122,11 @@ enum tulip_offsets {
 	CSR13 = 0x68,
 	CSR14 = 0x70,
 	CSR15 = 0x78,
+	CSR18 = 0x88,
+	CSR19 = 0x8c,
+	CSR20 = 0x90,
+	CSR27 = 0xAC,
+	CSR28 = 0xB0,
 };
 
 /* register offset and bits for CFDD PCI config reg */
@@ -289,6 +296,30 @@ enum t21143_csr6_bits {
 	csr6_mask_100bt = (csr6_scr | csr6_pcs | csr6_hbd),
 };
 
+enum tulip_comet_csr13_bits {
+/* The LINKOFFE and LINKONE work in conjunction with LSCE, i.e. they
+ * determine which link status transition wakes up if LSCE is
+ * enabled */
+        comet_csr13_linkoffe = (1 << 17),
+        comet_csr13_linkone = (1 << 16),
+        comet_csr13_wfre = (1 << 10),
+        comet_csr13_mpre = (1 << 9),
+        comet_csr13_lsce = (1 << 8),
+        comet_csr13_wfr = (1 << 2),
+        comet_csr13_mpr = (1 << 1),
+        comet_csr13_lsc = (1 << 0),
+};
+
+enum tulip_comet_csr18_bits {
+        comet_csr18_pmes_sticky = (1 << 24),
+        comet_csr18_pm_mode = (1 << 19),
+        comet_csr18_apm_mode = (1 << 18),
+        comet_csr18_d3a = (1 << 7)
+};
+
+enum tulip_comet_csr20_bits {
+        comet_csr20_pmes = (1 << 15),
+};
 
 /* Keep the ring sizes a power of two for efficiency.
    Making the Tx ring too large decreases the effectiveness of channel
@@ -411,6 +442,7 @@ struct tulip_private {
 	unsigned int csr6;	/* Current CSR6 control settings. */
 	unsigned char eeprom[EEPROM_SIZE];	/* Serial EEPROM contents. */
 	void (*link_change) (struct net_device * dev, int csr5);
+        struct ethtool_wolinfo wolinfo;        /* WOL settings */
 	u16 sym_advertise, mii_advertise; /* NWay capabilities advertised.  */
 	u16 lpar;		/* 21143 Link partner ability. */
 	u16 advertising[4];
diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
index bb8c0ee..f57fcf8 100644
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -30,7 +30,6 @@
 #include <linux/etherdevice.h>
 #include <linux/delay.h>
 #include <linux/mii.h>
-#include <linux/ethtool.h>
 #include <linux/crc32.h>
 #include <asm/unaligned.h>
 #include <asm/uaccess.h>
@@ -272,6 +271,7 @@ static void tulip_down(struct net_device *dev);
 static struct net_device_stats *tulip_get_stats(struct net_device *dev);
 static int private_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 static void set_rx_mode(struct net_device *dev);
+static void tulip_set_wolopts(struct pci_dev *pdev, u32 wolopts);
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void poll_tulip(struct net_device *dev);
 #endif
@@ -309,6 +309,11 @@ static void tulip_up(struct net_device *dev)
 	/* Wake the chip from sleep/snooze mode. */
 	tulip_set_power_state (tp, 0, 0);
 
+	/* Disable all WOL events */
+	pci_enable_wake(tp->pdev, PCI_D3hot, 0);
+	pci_enable_wake(tp->pdev, PCI_D3cold, 0);
+	tulip_set_wolopts(tp->pdev, 0);
+
 	/* On some chip revs we must set the MII/SYM port before the reset!? */
 	if (tp->mii_cnt  ||  (tp->mtable  &&  tp->mtable->has_mii))
 		iowrite32(0x00040000, ioaddr + CSR6);
@@ -345,8 +350,8 @@ static void tulip_up(struct net_device *dev)
 		} else if (tp->flags & COMET_MAC_ADDR) {
 			iowrite32(addr_low,  ioaddr + 0xA4);
 			iowrite32(addr_high, ioaddr + 0xA8);
-			iowrite32(0, ioaddr + 0xAC);
-			iowrite32(0, ioaddr + 0xB0);
+			iowrite32(0, ioaddr + CSR27);
+			iowrite32(0, ioaddr + CSR28);
 		}
 	} else {
 		/* This is set_rx_mode(), but without starting the transmitter. */
@@ -878,8 +883,35 @@ static void tulip_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *in
 	strcpy(info->bus_info, pci_name(np->pdev));
 }
 
+
+static int tulip_ethtool_set_wol(struct net_device *dev,
+				 struct ethtool_wolinfo *wolinfo)
+{
+	struct tulip_private *tp = netdev_priv(dev);
+
+	if (wolinfo->wolopts & (~tp->wolinfo.supported))
+		   return -EOPNOTSUPP;
+
+	tp->wolinfo.wolopts = wolinfo->wolopts;
+	device_set_wakeup_enable(&tp->pdev->dev, tp->wolinfo.wolopts);
+	return 0;
+}
+
+static void tulip_ethtool_get_wol(struct net_device *dev,
+				  struct ethtool_wolinfo *wolinfo)
+{
+	struct tulip_private *tp = netdev_priv(dev);
+
+	wolinfo->supported = tp->wolinfo.supported;
+	wolinfo->wolopts = tp->wolinfo.wolopts;
+	return;
+}
+
+
 static const struct ethtool_ops ops = {
-	.get_drvinfo = tulip_get_drvinfo
+	.get_drvinfo = tulip_get_drvinfo,
+	.set_wol     = tulip_ethtool_set_wol,
+	.get_wol     = tulip_ethtool_get_wol,
 };
 
 /* Provide ioctl() calls to examine the MII xcvr state. */
@@ -1092,8 +1124,8 @@ static void set_rx_mode(struct net_device *dev)
 				iowrite32(3, ioaddr + CSR13);
 				iowrite32(mc_filter[1], ioaddr + CSR14);
 			} else if (tp->flags & COMET_MAC_ADDR) {
-				iowrite32(mc_filter[0], ioaddr + 0xAC);
-				iowrite32(mc_filter[1], ioaddr + 0xB0);
+				iowrite32(mc_filter[0], ioaddr + CSR27);
+				iowrite32(mc_filter[1], ioaddr + CSR28);
 			}
 			tp->mc_filter[0] = mc_filter[0];
 			tp->mc_filter[1] = mc_filter[1];
@@ -1433,6 +1465,19 @@ static int __devinit tulip_init_one (struct pci_dev *pdev,
 
 	tp->chip_id = chip_idx;
 	tp->flags = tulip_tbl[chip_idx].flags;
+
+	tp->wolinfo.supported = 0;
+	tp->wolinfo.wolopts = 0;
+	/* COMET: Enable power management only for AN983B */
+	if (chip_idx == COMET ) {
+		u32 sig;
+		pci_read_config_dword (pdev, 0x80, &sig);
+		if (sig == 0x09811317) {
+			tp->flags |= COMET_PM;
+			tp->wolinfo.supported = WAKE_PHY | WAKE_MAGIC;
+			printk(KERN_INFO "tulip_init_one: Enabled WOL support for AN983B\n");
+		}
+	}
 	tp->pdev = pdev;
 	tp->base_addr = ioaddr;
 	tp->revision = pdev->revision;
@@ -1765,11 +1810,43 @@ err_out_free_netdev:
 }
 
 
+/* set the registers according to the given wolopts */
+static void tulip_set_wolopts (struct pci_dev *pdev, u32 wolopts)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct tulip_private *tp = netdev_priv(dev);
+	void __iomem *ioaddr = tp->base_addr;
+
+	if (tp->flags & COMET_PM) {
+	  
+		unsigned int tmp;
+			
+		tmp = ioread32(ioaddr + CSR18);
+		tmp &= ~(comet_csr18_pmes_sticky | comet_csr18_apm_mode | comet_csr18_d3a);
+		tmp |= comet_csr18_pm_mode;
+		iowrite32(tmp, ioaddr + CSR18);
+			
+		/* Set the Wake-up Control/Status Register to the given WOL options*/
+		tmp = ioread32(ioaddr + CSR13);
+		tmp &= ~(comet_csr13_linkoffe | comet_csr13_linkone | comet_csr13_wfre | comet_csr13_lsce | comet_csr13_mpre);
+		if (wolopts & WAKE_MAGIC)
+			tmp |= comet_csr13_mpre;
+		if (wolopts & WAKE_PHY)
+			tmp |= comet_csr13_linkoffe | comet_csr13_linkone | comet_csr13_lsce;
+		/* Clear the event flags */
+		tmp |= comet_csr13_wfr | comet_csr13_mpr | comet_csr13_lsc;
+		iowrite32(tmp, ioaddr + CSR13);
+	}
+}
+
 #ifdef CONFIG_PM
 
+
 static int tulip_suspend (struct pci_dev *pdev, pm_message_t state)
 {
+	pci_power_t pstate;
 	struct net_device *dev = pci_get_drvdata(pdev);
+	struct tulip_private *tp = netdev_priv(dev);
 
 	if (!dev)
 		return -EINVAL;
@@ -1785,7 +1862,16 @@ static int tulip_suspend (struct pci_dev *pdev, pm_message_t state)
 save_state:
 	pci_save_state(pdev);
 	pci_disable_device(pdev);
-	pci_set_power_state(pdev, pci_choose_state(pdev, state));
+	pstate = pci_choose_state(pdev, state);
+	if (state.event == PM_EVENT_SUSPEND && pstate != PCI_D0) {
+		int rc;
+
+		tulip_set_wolopts(pdev, tp->wolinfo.wolopts);
+		rc = pci_enable_wake(pdev, pstate, tp->wolinfo.wolopts);
+		if (rc)
+			printk("tulip: pci_enable_wake failed (%d)\n", rc);
+	}
+	pci_set_power_state(pdev, pstate);
 
 	return 0;
 }
@@ -1794,7 +1880,10 @@ save_state:
 static int tulip_resume(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
+	struct tulip_private *tp = netdev_priv(dev);
+	void __iomem *ioaddr = tp->base_addr;
 	int retval;
+	unsigned int tmp;
 
 	if (!dev)
 		return -EINVAL;
@@ -1815,6 +1904,18 @@ static int tulip_resume(struct pci_dev *pdev)
 		return retval;
 	}
 
+	if (tp->flags & COMET_PM) {
+		pci_enable_wake(pdev, PCI_D3hot, 0);
+		pci_enable_wake(pdev, PCI_D3cold, 0);
+
+		/* Clear the PMES flag */
+		tmp = ioread32(ioaddr + CSR20);
+		tmp |= comet_csr20_pmes;
+		iowrite32(tmp, ioaddr + CSR20);
+
+		/* Disable all wake-up events */
+		tulip_set_wolopts(pdev, 0);
+	}
 	netif_device_attach(dev);
 
 	if (netif_running(dev))
-- 
1.6.3.3

