From: Daniele Venzano <venza@brownhat.org>
Subject: [PATCH] Add Wake on LAN support to sis900 (2)
Date: Tue, 11 Oct 2005 09:44:30 +0200
Message-ID: <20051011074430.GA29824@renditai.milesteg.arr>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="y0ulUmNC+osPPQO6"
Cc: akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, NetDev <netdev@oss.sgi.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--y0ulUmNC+osPPQO6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Sorry, but that day I had smoked somthing too heavy for me, the patch
didn't apply. Here's a new one.

The patch availble below adds support for Wake on LAN to the sis900
driver. Some register addresses were added to sis900.h and two new
functions were implemented in sis900.c. WoL status is controlled by
ethtool.
Patch is against 2.6.13.

Comments are welcome, but also consider for inclusion in the -mm series.

Signed-off-by: Daniele Venzano <venza@brownhat.org>

-- 
------------------------------
Daniele Venzano
Web: http://teg.homeunix.org

--y0ulUmNC+osPPQO6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="sis900_c_127.diff"

--- a/drivers/net/sis900.h	2005-07-17 10:43:23.000000000 +0200
+++ b/drivers/net/sis900.h	2005-10-06 12:49:37.000000000 +0200
@@ -33,6 +33,7 @@
         rxcfg=0x34,             //Receive Configuration Register
         flctrl=0x38,            //Flow Control Register
         rxlen=0x3c,             //Receive Packet Length Register
+        cfgpmcsr=0x44,          //Configuration Power Management Control/Status Register
         rfcr=0x48,              //Receive Filter Control Register
         rfdr=0x4C,              //Receive Filter Data Register
         pmctrl=0xB0,            //Power Management Control Register
@@ -140,6 +141,50 @@
 	EEREQ = 0x00000400, EEDONE = 0x00000200, EEGNT = 0x00000100
 };
 
+/* PCI Registers */
+enum sis900_pci_registers {
+	CFGPMC 	 = 0x40,
+	CFGPMCSR = 0x44
+};
+
+/* Power management capabilities bits */
+enum sis900_cfgpmc_register_bits {
+	PMVER	= 0x00070000, 
+	DSI	= 0x00100000,
+	PMESP	= 0xf8000000
+};
+
+enum sis900_pmesp_bits {
+	PME_D0 = 0x1,
+	PME_D1 = 0x2,
+	PME_D2 = 0x4,
+	PME_D3H = 0x8,
+	PME_D3C = 0x10
+};
+
+/* Power management control/status bits */
+enum sis900_cfgpmcsr_register_bits {
+	PMESTS = 0x00004000,
+	PME_EN = 0x00000100, // Power management enable
+	PWR_STA = 0x00000003 // Current power state
+};
+
+/* Wake-on-LAN support. */
+enum sis900_power_management_control_register_bits {
+	LINKLOSS  = 0x00000001,
+	LINKON    = 0x00000002,
+	MAGICPKT  = 0x00000400,
+	ALGORITHM = 0x00000800,
+	FRM1EN    = 0x00100000,
+	FRM2EN    = 0x00200000,
+	FRM3EN    = 0x00400000,
+	FRM1ACS   = 0x01000000,
+	FRM2ACS   = 0x02000000,
+	FRM3ACS   = 0x04000000,
+	WAKEALL   = 0x40000000,
+	GATECLK   = 0x80000000
+};
+
 /* Management Data I/O (mdio) frame */
 #define MIIread         0x6000
 #define MIIwrite        0x5002
--- a/drivers/net/sis900.c	2005-10-06 12:06:06.000000000 +0200
+++ b/drivers/net/sis900.c	2005-10-06 12:05:45.000000000 +0200
@@ -1,6 +1,6 @@
 /* sis900.c: A SiS 900/7016 PCI Fast Ethernet driver for Linux.
    Copyright 1999 Silicon Integrated System Corporation 
-   Revision:	1.08.08 Jan. 22 2005
+   Revision:	1.08.09 Sep. 19 2005
    
    Modified from the driver which is originally written by Donald Becker.
    
@@ -17,6 +17,7 @@
    SiS 7014 Single Chip 100BASE-TX/10BASE-T Physical Layer Solution,
    preliminary Rev. 1.0 Jan. 18, 1998
 
+   Rev 1.08.09 Sep. 19 2005 Daniele Venzano add Wake on LAN support
    Rev 1.08.08 Jan. 22 2005 Daniele Venzano use netif_msg for debugging messages
    Rev 1.08.07 Nov.  2 2003 Daniele Venzano <webvenza@libero.it> add suspend/resume support
    Rev 1.08.06 Sep. 24 2002 Mufasa Yang bug fix for Tx timeout & add SiS963 support
@@ -76,7 +77,7 @@
 #include "sis900.h"
 
 #define SIS900_MODULE_NAME "sis900"
-#define SIS900_DRV_VERSION "v1.08.08 Jan. 22 2005"
+#define SIS900_DRV_VERSION "v1.08.09 Sep. 19 2005"
 
 static char version[] __devinitdata =
 KERN_INFO "sis900.c: " SIS900_DRV_VERSION "\n";
@@ -538,6 +539,11 @@
 		printk("%2.2x:", (u8)net_dev->dev_addr[i]);
 	printk("%2.2x.\n", net_dev->dev_addr[i]);
 
+	/* Detect Wake on Lan support */
+	ret = inl(CFGPMC & PMESP);
+	if (netif_msg_probe(sis_priv) && (ret & PME_D3C) == 0)
+		printk(KERN_INFO "%s: Wake on LAN only available from suspend to RAM.", net_dev->name);
+
 	return 0;
 
  err_unmap_rx:
@@ -2007,6 +2013,67 @@
 	return mii_nway_restart(&sis_priv->mii_info);
 }
 
+/**
+ *	sis900_set_wol - Set up Wake on Lan registers
+ *	@net_dev: the net device to probe
+ *	@wol: container for info passed to the driver
+ *
+ *	Process ethtool command "wol" to setup wake on lan features.
+ *	SiS900 supports sending WoL events if a correct packet is received,
+ *	but there is no simple way to filter them to only a subset (broadcast,
+ *	multicast, unicast or arp).
+ */
+ 
+static int sis900_set_wol(struct net_device *net_dev, struct ethtool_wolinfo *wol)
+{
+	struct sis900_private *sis_priv = net_dev->priv;
+	long pmctrl_addr = net_dev->base_addr + pmctrl;
+	u32 cfgpmcsr = 0, pmctrl_bits = 0;
+
+	if (wol->wolopts == 0) {
+		pci_read_config_dword(sis_priv->pci_dev, CFGPMCSR, &cfgpmcsr);
+		cfgpmcsr |= ~PME_EN;
+		pci_write_config_dword(sis_priv->pci_dev, CFGPMCSR, cfgpmcsr);
+		outl(pmctrl_bits, pmctrl_addr);
+		if (netif_msg_wol(sis_priv))
+			printk(KERN_DEBUG "%s: Wake on LAN disabled\n", net_dev->name);
+		return 0;
+	}
+
+	if (wol->wolopts & (WAKE_MAGICSECURE | WAKE_UCAST | WAKE_MCAST
+				| WAKE_BCAST | WAKE_ARP))
+		return -EINVAL;
+
+	if (wol->wolopts & WAKE_MAGIC)
+		pmctrl_bits |= MAGICPKT;
+	if (wol->wolopts & WAKE_PHY)
+		pmctrl_bits |= LINKON;
+	
+	outl(pmctrl_bits, pmctrl_addr);
+
+	pci_read_config_dword(sis_priv->pci_dev, CFGPMCSR, &cfgpmcsr);
+	cfgpmcsr |= PME_EN;
+	pci_write_config_dword(sis_priv->pci_dev, CFGPMCSR, cfgpmcsr);
+	if (netif_msg_wol(sis_priv))
+		printk(KERN_DEBUG "%s: Wake on LAN enabled\n", net_dev->name);
+
+	return 0;
+}
+
+static void sis900_get_wol(struct net_device *net_dev, struct ethtool_wolinfo *wol)
+{
+	long pmctrl_addr = net_dev->base_addr + pmctrl;
+	u32 pmctrl_bits;
+
+	pmctrl_bits = inl(pmctrl_addr);
+	if (pmctrl_bits & MAGICPKT)
+		wol->wolopts |= WAKE_MAGIC;
+	if (pmctrl_bits & LINKON)
+		wol->wolopts |= WAKE_PHY;
+
+	wol->supported = (WAKE_PHY | WAKE_MAGIC);
+}
+
 static struct ethtool_ops sis900_ethtool_ops = {
 	.get_drvinfo 	= sis900_get_drvinfo,
 	.get_msglevel	= sis900_get_msglevel,
@@ -2015,6 +2082,8 @@
 	.get_settings	= sis900_get_settings,
 	.set_settings	= sis900_set_settings,
 	.nway_reset	= sis900_nway_reset,
+	.get_wol	= sis900_get_wol,
+	.set_wol	= sis900_set_wol
 };
 
 /**

--y0ulUmNC+osPPQO6--
