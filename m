From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver updates
Date: Fri, 11 May 2007 17:58:58 -0400
Message-ID: <20070511215858.GA5910@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:49187 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757793AbXEKV7D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 May 2007 17:59:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I went ahead and merged the drivers/atm Kconfig updates.

And this brings much-needed libertas updates.

Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 drivers/atm/Kconfig                     |   32 +-
 drivers/net/Kconfig                     |   16 +-
 drivers/net/mlx4/eq.c                   |    2 +-
 drivers/net/netxen/netxen_nic_main.c    |    2 +-
 drivers/net/pcmcia/Kconfig              |   23 +-
 drivers/net/phy/Kconfig                 |   22 +-
 drivers/net/phy/davicom.c               |   34 +-
 drivers/net/s2io.c                      |  368 +++++++-
 drivers/net/s2io.h                      |   32 +
 drivers/net/skge.c                      |    9 +
 drivers/net/sky2.c                      |   53 +-
 drivers/net/spider_net.c                |    8 +-
 drivers/net/wan/Kconfig                 |   34 +-
 drivers/net/wireless/libertas/Makefile  |    9 -
 drivers/net/wireless/libertas/README    |  516 -----------
 drivers/net/wireless/libertas/assoc.c   |   41 +-
 drivers/net/wireless/libertas/cmd.c     |   23 +-
 drivers/net/wireless/libertas/cmdresp.c |    4 +-
 drivers/net/wireless/libertas/debugfs.c |   31 +-
 drivers/net/wireless/libertas/defs.h    |   52 +-
 drivers/net/wireless/libertas/dev.h     |   14 +-
 drivers/net/wireless/libertas/fw.c      |    9 +-
 drivers/net/wireless/libertas/if_usb.c  |    5 +-
 drivers/net/wireless/libertas/if_usb.h  |    2 -
 drivers/net/wireless/libertas/ioctl.c   | 1529 +------------------------------
 drivers/net/wireless/libertas/join.c    |  194 +----
 drivers/net/wireless/libertas/join.h    |    7 -
 drivers/net/wireless/libertas/main.c    |    7 +
 drivers/net/wireless/libertas/rx.c      |    4 +-
 drivers/net/wireless/libertas/scan.c    |  203 ++---
 drivers/net/wireless/libertas/scan.h    |   22 +-
 drivers/net/wireless/libertas/tx.c      |    2 +-
 drivers/net/wireless/libertas/version.h |    7 -
 drivers/net/wireless/libertas/wext.c    |  448 +--------
 drivers/net/wireless/libertas/wext.h    |   85 --
 35 files changed, 750 insertions(+), 3099 deletions(-)

Andrew Morton (2):
      netxen_nic_main don't use deprecated irq flags
      mlx4: don't use deprecated IRQ flags

Dan Williams (19):
      libertas: remove WPA_SUPPLICANT structure
      libertas: use <net/ieee80211.h> for MAX_WPA_IE_LEN
      libertas: fix size of SSID comparison in stop_adhoc check
      libertas: remove 8021xauthalgs private ioctl
      libertas: remove setauthalg private ioctl
      libertas: remove incorrect vi modelines
      libertas: remove custom encryption mode stuff
      libertas: remove setwpaie private ioctl
      libertas: remove WLAN_802_11_AUTHENTICATION_MODE
      libertas: remove WLAN_802_11_WEP_STATUS enum
      libertas: remove WLAN_802_11_NETWORK_INFRASTRUCTURE enum
      libertas: Get rid of version.h
      libertas: Purge non-mesh ioctls
      libertas: remove SUPPORT_BOOT_COMMAND
      libertas: Clean up debug defines
      libertas: make debugfs.c sparse-clean
      libertas: fix missing unlock in TX error path
      libertas: sparse fixes
      libertas: 64-bit cleanups

Ishizaki Kou (1):
      spidernet: remove unnecessary accesses to phy

Jan Engelhardt (5):
      Use menuconfig objects: PHY
      Use menuconfig objects: netdev
      Use menuconfig objects II - netdev/atm
      Use menuconfig objects II - netdev/pcmcia
      Use menuconfig objects II - netdev/wan

Kim Phillips (1):
      Add support for the Davicom DM9161A PHY

Sreenivasa Honnur (3):
      S2IO: getringparam ethtool option
      S2IO: statistics for memory allocation failuers
      S2IO: Statistics for link up/down and memory allocated/freed

Stephen Hemminger (4):
      sky2: fix oops on shutdown
      skge: crash on shutdown/suspend
      sky2: 88e8071 support not ready
      sky2: only disable 88e8056 on some boards

diff --git a/drivers/atm/Kconfig b/drivers/atm/Kconfig
index 3368745..f5a47a4 100644
--- a/drivers/atm/Kconfig
+++ b/drivers/atm/Kconfig
@@ -2,19 +2,22 @@
 # ATM device configuration
 #
 
-menu "ATM drivers"
+menuconfig ATM_DRIVERS
+	bool "ATM drivers"
 	depends on NETDEVICES && ATM
+	default y
+
+if ATM_DRIVERS
 
 config ATM_DUMMY
 	tristate "Dummy ATM driver"
-	depends on ATM
 	help
 	  Dummy ATM driver. Useful for proxy signalling, testing,
 	  and development.  If unsure, say N.
 
 config ATM_TCP
 	tristate "ATM over TCP"
-	depends on INET && ATM
+	depends on INET
 	help
 	  ATM over TCP driver. Useful mainly for development and for
 	  experiments. If unsure, say N.
@@ -30,7 +33,7 @@ config ATM_LANAI
 
 config ATM_ENI
 	tristate "Efficient Networks ENI155P"
-	depends on PCI && ATM
+	depends on PCI
 	---help---
 	  Driver for the Efficient Networks ENI155p series and SMC ATM
 	  Power155 155 Mbps ATM adapters. Both, the versions with 512KB and
@@ -139,7 +142,7 @@ config ATM_ENI_BURST_RX_2W
 
 config ATM_FIRESTREAM
 	tristate "Fujitsu FireStream (FS50/FS155) "
-	depends on PCI && ATM
+	depends on PCI
 	help
 	  Driver for the Fujitsu FireStream 155 (MB86697) and
 	  FireStream 50 (MB86695) ATM PCI chips.
@@ -149,7 +152,7 @@ config ATM_FIRESTREAM
 
 config ATM_ZATM
 	tristate "ZeitNet ZN1221/ZN1225"
-	depends on PCI && ATM
+	depends on PCI
 	help
 	  Driver for the ZeitNet ZN1221 (MMF) and ZN1225 (UTP-5) 155 Mbps ATM
 	  adapters.
@@ -169,7 +172,7 @@ config ATM_ZATM_DEBUG
 
 config ATM_NICSTAR
 	tristate "IDT 77201 (NICStAR) (ForeRunnerLE)"
-	depends on PCI && ATM && !64BIT
+	depends on PCI && !64BIT
 	help
 	  The NICStAR chipset family is used in a large number of ATM NICs for
 	  25 and for 155 Mbps, including IDT cards and the Fore ForeRunnerLE
@@ -202,7 +205,7 @@ config ATM_NICSTAR_USE_IDT77105
 
 config ATM_IDT77252
 	tristate "IDT 77252 (NICStAR II)"
-	depends on PCI && ATM
+	depends on PCI
 	help
 	  Driver for the IDT 77252 ATM PCI chips.
 
@@ -237,7 +240,7 @@ config ATM_IDT77252_USE_SUNI
 
 config ATM_AMBASSADOR
 	tristate "Madge Ambassador (Collage PCI 155 Server)"
-	depends on PCI && ATM
+	depends on PCI
 	select BITREVERSE
 	help
 	  This is a driver for ATMizer based ATM card produced by Madge
@@ -262,7 +265,7 @@ config ATM_AMBASSADOR_DEBUG
 
 config ATM_HORIZON
 	tristate "Madge Horizon [Ultra] (Collage PCI 25 and Collage PCI 155 Client)"
-	depends on PCI && ATM
+	depends on PCI
 	help
 	  This is a driver for the Horizon chipset ATM adapter cards once
 	  produced by Madge Networks Ltd. Say Y (or M to compile as a module
@@ -286,7 +289,7 @@ config ATM_HORIZON_DEBUG
 
 config ATM_IA
 	tristate "Interphase ATM PCI x575/x525/x531"
-	depends on PCI && ATM && !64BIT
+	depends on PCI && !64BIT
 	---help---
 	  This is a driver for the Interphase (i)ChipSAR adapter cards
 	  which include a variety of variants in term of the size of the
@@ -319,7 +322,7 @@ config ATM_IA_DEBUG
 
 config ATM_FORE200E_MAYBE
 	tristate "FORE Systems 200E-series"
-	depends on (PCI || SBUS) && ATM
+	depends on PCI || SBUS
 	---help---
 	  This is a driver for the FORE Systems 200E-series ATM adapter
 	  cards. It simultaneously supports PCA-200E and SBA-200E models
@@ -436,7 +439,7 @@ config ATM_FORE200E
 
 config ATM_HE
 	tristate "ForeRunner HE Series"
-	depends on PCI && ATM
+	depends on PCI
 	help
 	  This is a driver for the Marconi ForeRunner HE-series ATM adapter
 	  cards. It simultaneously supports the 155 and 622 versions.
@@ -448,5 +451,4 @@ config ATM_HE_USE_SUNI
 	  Support for the S/UNI-Ultra and S/UNI-622 found in the ForeRunner
 	  HE cards.  This driver provides carrier detection some statistics.
 
-endmenu
-
+endif # ATM
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index fa489b1..8a7f9e9 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1898,8 +1898,12 @@ endmenu
 #	Gigabit Ethernet
 #
 
-menu "Ethernet (1000 Mbit)"
+menuconfig NETDEV_1000
+	bool "Ethernet (1000 Mbit)"
 	depends on !UML
+	default y
+
+if NETDEV_1000
 
 config ACENIC
 	tristate "Alteon AceNIC/3Com 3C985/NetGear GA620 Gigabit support"
@@ -2326,14 +2330,18 @@ config ATL1
 	  To compile this driver as a module, choose M here.  The module
 	  will be called atl1.
 
-endmenu
+endif # NETDEV_1000
 
 #
 #	10 Gigabit Ethernet
 #
 
-menu "Ethernet (10000 Mbit)"
+menuconfig NETDEV_10000
+	bool "Ethernet (10000 Mbit)"
 	depends on !UML
+	default y
+
+if NETDEV_10000
 
 config CHELSIO_T1
         tristate "Chelsio 10Gb Ethernet support"
@@ -2507,7 +2515,7 @@ config MLX4_DEBUG
 	  debug_level module parameter (which can also be set after
 	  the driver is loaded through sysfs).
 
-endmenu
+endif # NETDEV_10000
 
 source "drivers/net/tokenring/Kconfig"
 
diff --git a/drivers/net/mlx4/eq.c b/drivers/net/mlx4/eq.c
index acf1c80..af016d0 100644
--- a/drivers/net/mlx4/eq.c
+++ b/drivers/net/mlx4/eq.c
@@ -623,7 +623,7 @@ int __devinit mlx4_init_eq_table(struct mlx4_dev *dev)
 		priv->eq_table.eq[MLX4_EQ_CATAS].have_irq = 1;
 	} else {
 		err = request_irq(dev->pdev->irq, mlx4_interrupt,
-				  SA_SHIRQ, DRV_NAME, dev);
+				  IRQF_SHARED, DRV_NAME, dev);
 		if (err)
 			goto err_out_async;
 
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 4e32bb6..2c5c6d2 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -735,7 +735,7 @@ static int netxen_nic_open(struct net_device *netdev)
 		}
 		adapter->irq = adapter->ahw.pdev->irq;
 		err = request_irq(adapter->ahw.pdev->irq, netxen_intr,
-				  SA_SHIRQ | SA_SAMPLE_RANDOM, netdev->name,
+				  IRQF_SHARED|IRQF_SAMPLE_RANDOM, netdev->name,
 				  adapter);
 		if (err) {
 			printk(KERN_ERR "request_irq failed with: %d\n", err);
diff --git a/drivers/net/pcmcia/Kconfig b/drivers/net/pcmcia/Kconfig
index 74f8620..5d658bc 100644
--- a/drivers/net/pcmcia/Kconfig
+++ b/drivers/net/pcmcia/Kconfig
@@ -2,11 +2,9 @@
 # PCMCIA Network device configuration
 #
 
-menu "PCMCIA network device support"
-	depends on NETDEVICES && PCMCIA!=n
-
-config NET_PCMCIA
+menuconfig NET_PCMCIA
 	bool "PCMCIA network device support"
+	depends on PCMCIA
 	---help---
 	  Say Y if you would like to include support for any PCMCIA or CardBus
 	  network adapters, then say Y to the driver for your particular card
@@ -21,9 +19,10 @@ config NET_PCMCIA
 
 	  If unsure, say N.
 
+if NET_PCMCIA
+
 config PCMCIA_3C589
 	tristate "3Com 3c589 PCMCIA support"
-	depends on NET_PCMCIA && PCMCIA
 	help
 	  Say Y here if you intend to attach a 3Com 3c589 or compatible PCMCIA
 	  (PC-card) Ethernet card to your computer.
@@ -33,7 +32,6 @@ config PCMCIA_3C589
 
 config PCMCIA_3C574
 	tristate "3Com 3c574 PCMCIA support"
-	depends on NET_PCMCIA && PCMCIA
 	help
 	  Say Y here if you intend to attach a 3Com 3c574 or compatible PCMCIA
 	  (PC-card) Fast Ethernet card to your computer.
@@ -43,7 +41,6 @@ config PCMCIA_3C574
 
 config PCMCIA_FMVJ18X
 	tristate "Fujitsu FMV-J18x PCMCIA support"
-	depends on NET_PCMCIA && PCMCIA
 	select CRC32
 	help
 	  Say Y here if you intend to attach a Fujitsu FMV-J18x or compatible
@@ -54,7 +51,6 @@ config PCMCIA_FMVJ18X
 
 config PCMCIA_PCNET
 	tristate "NE2000 compatible PCMCIA support"
-	depends on NET_PCMCIA && PCMCIA
 	select CRC32
 	help
 	  Say Y here if you intend to attach an NE2000 compatible PCMCIA
@@ -65,7 +61,6 @@ config PCMCIA_PCNET
 
 config PCMCIA_NMCLAN
 	tristate "New Media PCMCIA support"
-	depends on NET_PCMCIA && PCMCIA
 	help
 	  Say Y here if you intend to attach a New Media Ethernet or LiveWire
 	  PCMCIA (PC-card) Ethernet card to your computer.
@@ -75,7 +70,6 @@ config PCMCIA_NMCLAN
 
 config PCMCIA_SMC91C92
 	tristate "SMC 91Cxx PCMCIA support"
-	depends on NET_PCMCIA && PCMCIA
 	select CRC32
 	select MII
 	help
@@ -87,7 +81,6 @@ config PCMCIA_SMC91C92
 
 config PCMCIA_XIRC2PS
 	tristate "Xircom 16-bit PCMCIA support"
-	depends on NET_PCMCIA && PCMCIA
 	help
 	  Say Y here if you intend to attach a Xircom 16-bit PCMCIA (PC-card)
 	  Ethernet or Fast Ethernet card to your computer.
@@ -97,7 +90,6 @@ config PCMCIA_XIRC2PS
 
 config PCMCIA_AXNET
 	tristate "Asix AX88190 PCMCIA support"
-	depends on NET_PCMCIA && PCMCIA
 	---help---
 	  Say Y here if you intend to attach an Asix AX88190-based PCMCIA
 	  (PC-card) Fast Ethernet card to your computer.  These cards are
@@ -109,7 +101,7 @@ config PCMCIA_AXNET
 
 config ARCNET_COM20020_CS
 	tristate "COM20020 ARCnet PCMCIA support"
-	depends on NET_PCMCIA && ARCNET_COM20020 && PCMCIA
+	depends on ARCNET_COM20020
 	help
 	  Say Y here if you intend to attach this type of ARCnet PCMCIA card
 	  to your computer.
@@ -119,7 +111,7 @@ config ARCNET_COM20020_CS
 
 config PCMCIA_IBMTR
 	tristate "IBM PCMCIA tokenring adapter support"
-	depends on NET_PCMCIA && IBMTR!=y && TR && PCMCIA && !64BIT
+	depends on IBMTR!=y && TR && !64BIT
 	help
 	  Say Y here if you intend to attach this type of Token Ring PCMCIA
 	  card to your computer. You then also need to say Y to "Token Ring
@@ -128,5 +120,4 @@ config PCMCIA_IBMTR
 	  To compile this driver as a module, choose M here: the module will be
 	  called ibmtr_cs.
 
-endmenu
-
+endif # NET_PCMCIA
diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index c0d3101..09b6f25 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -2,70 +2,61 @@
 # PHY Layer Configuration
 #
 
-menu "PHY device support"
-	depends on !S390
-
-config PHYLIB
+menuconfig PHYLIB
 	tristate "PHY Device support and infrastructure"
+	depends on !S390
 	depends on NET_ETHERNET && (BROKEN || !S390)
 	help
 	  Ethernet controllers are usually attached to PHY
 	  devices.  This option provides infrastructure for
 	  managing PHY devices.
 
+if PHYLIB
+
 comment "MII PHY device drivers"
-	depends on PHYLIB
 
 config MARVELL_PHY
 	tristate "Drivers for Marvell PHYs"
-	depends on PHYLIB
 	---help---
 	  Currently has a driver for the 88E1011S
 	
 config DAVICOM_PHY
 	tristate "Drivers for Davicom PHYs"
-	depends on PHYLIB
 	---help---
 	  Currently supports dm9161e and dm9131
 
 config QSEMI_PHY
 	tristate "Drivers for Quality Semiconductor PHYs"
-	depends on PHYLIB
 	---help---
 	  Currently supports the qs6612
 
 config LXT_PHY
 	tristate "Drivers for the Intel LXT PHYs"
-	depends on PHYLIB
 	---help---
 	  Currently supports the lxt970, lxt971
 
 config CICADA_PHY
 	tristate "Drivers for the Cicada PHYs"
-	depends on PHYLIB
 	---help---
 	  Currently supports the cis8204
+
 config VITESSE_PHY
         tristate "Drivers for the Vitesse PHYs"
-        depends on PHYLIB
         ---help---
           Currently supports the vsc8244
 
 config SMSC_PHY
 	tristate "Drivers for SMSC PHYs"
-	depends on PHYLIB
 	---help---
 	  Currently supports the LAN83C185 PHY
 
 config BROADCOM_PHY
 	tristate "Drivers for Broadcom PHYs"
-	depends on PHYLIB
 	---help---
 	  Currently supports the BCM5411, BCM5421 and BCM5461 PHYs.
 
 config FIXED_PHY
 	tristate "Drivers for PHY emulation on fixed speed/link"
-	depends on PHYLIB
 	---help---
 	  Adds the driver to PHY layer to cover the boards that do not have any PHY bound,
 	  but with the ability to manipulate the speed/link in software. The relevant MII
@@ -80,5 +71,4 @@ config FIXED_MII_100_FDX
 	bool "Emulation for 100M Fdx fixed PHY behavior"
 	depends on FIXED_PHY
 
-endmenu
-
+endif # PHYLIB
diff --git a/drivers/net/phy/davicom.c b/drivers/net/phy/davicom.c
index 519baa3..7ed632d 100644
--- a/drivers/net/phy/davicom.c
+++ b/drivers/net/phy/davicom.c
@@ -139,7 +139,7 @@ static int dm9161_ack_interrupt(struct phy_device *phydev)
 	return (err < 0) ? err : 0;
 }
 
-static struct phy_driver dm9161_driver = {
+static struct phy_driver dm9161e_driver = {
 	.phy_id		= 0x0181b880,
 	.name		= "Davicom DM9161E",
 	.phy_id_mask	= 0x0ffffff0,
@@ -147,7 +147,18 @@ static struct phy_driver dm9161_driver = {
 	.config_init	= dm9161_config_init,
 	.config_aneg	= dm9161_config_aneg,
 	.read_status	= genphy_read_status,
-	.driver 	= { .owner = THIS_MODULE,},
+	.driver		= { .owner = THIS_MODULE,},
+};
+
+static struct phy_driver dm9161a_driver = {
+	.phy_id		= 0x0181b8a0,
+	.name		= "Davicom DM9161A",
+	.phy_id_mask	= 0x0ffffff0,
+	.features	= PHY_BASIC_FEATURES,
+	.config_init	= dm9161_config_init,
+	.config_aneg	= dm9161_config_aneg,
+	.read_status	= genphy_read_status,
+	.driver		= { .owner = THIS_MODULE,},
 };
 
 static struct phy_driver dm9131_driver = {
@@ -160,31 +171,38 @@ static struct phy_driver dm9131_driver = {
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= dm9161_ack_interrupt,
 	.config_intr	= dm9161_config_intr,
-	.driver 	= { .owner = THIS_MODULE,},
+	.driver		= { .owner = THIS_MODULE,},
 };
 
 static int __init davicom_init(void)
 {
 	int ret;
 
-	ret = phy_driver_register(&dm9161_driver);
+	ret = phy_driver_register(&dm9161e_driver);
 	if (ret)
 		goto err1;
 
-	ret = phy_driver_register(&dm9131_driver);
+	ret = phy_driver_register(&dm9161a_driver);
 	if (ret)
 		goto err2;
+
+	ret = phy_driver_register(&dm9131_driver);
+	if (ret)
+		goto err3;
 	return 0;
 
- err2:	
-	phy_driver_unregister(&dm9161_driver);
+ err3:
+	phy_driver_unregister(&dm9161a_driver);
+ err2:
+	phy_driver_unregister(&dm9161e_driver);
  err1:
 	return ret;
 }
 
 static void __exit davicom_exit(void)
 {
-	phy_driver_unregister(&dm9161_driver);
+	phy_driver_unregister(&dm9161e_driver);
+	phy_driver_unregister(&dm9161a_driver);
 	phy_driver_unregister(&dm9131_driver);
 }
 
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 290e1c1..e3e6d41 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -84,7 +84,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
 
-#define DRV_VERSION "2.0.22.1"
+#define DRV_VERSION "2.0.23.1"
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";
@@ -281,6 +281,28 @@ static char ethtool_driver_stats_keys[][ETH_GSTRING_LEN] = {
 	("lro_out_of_sequence_pkts"),
 	("lro_flush_due_to_max_pkts"),
 	("lro_avg_aggr_pkts"),
+	("mem_alloc_fail_cnt"),
+	("watchdog_timer_cnt"),
+	("mem_allocated"),
+	("mem_freed"),
+	("link_up_cnt"),
+	("link_down_cnt"),
+	("link_up_time"),
+	("link_down_time"),
+	("tx_tcode_buf_abort_cnt"),
+	("tx_tcode_desc_abort_cnt"),
+	("tx_tcode_parity_err_cnt"),
+	("tx_tcode_link_loss_cnt"),
+	("tx_tcode_list_proc_err_cnt"),
+	("rx_tcode_parity_err_cnt"),
+	("rx_tcode_abort_cnt"),
+	("rx_tcode_parity_abort_cnt"),
+	("rx_tcode_rda_fail_cnt"),
+	("rx_tcode_unkn_prot_cnt"),
+	("rx_tcode_fcs_err_cnt"),
+	("rx_tcode_buf_size_err_cnt"),
+	("rx_tcode_rxd_corrupt_cnt"),
+	("rx_tcode_unkn_err_cnt")
 };
 
 #define S2IO_XENA_STAT_LEN sizeof(ethtool_xena_stats_keys)/ ETH_GSTRING_LEN
@@ -490,6 +512,7 @@ static int init_shared_mem(struct s2io_nic *nic)
 
 	struct mac_info *mac_control;
 	struct config_param *config;
+	unsigned long long mem_allocated = 0;
 
 	mac_control = &nic->mac_control;
 	config = &nic->config;
@@ -519,6 +542,7 @@ static int init_shared_mem(struct s2io_nic *nic)
 				  "Malloc failed for list_info\n");
 			return -ENOMEM;
 		}
+		mem_allocated += list_holder_size;
 		memset(mac_control->fifos[i].list_info, 0, list_holder_size);
 	}
 	for (i = 0; i < config->tx_fifo_num; i++) {
@@ -565,6 +589,7 @@ static int init_shared_mem(struct s2io_nic *nic)
 					DBG_PRINT(INFO_DBG, "failed for TxDL\n");
 					return -ENOMEM;
 				}
+				mem_allocated += PAGE_SIZE;
 			}
 			while (k < lst_per_page) {
 				int l = (j * lst_per_page) + k;
@@ -582,6 +607,7 @@ static int init_shared_mem(struct s2io_nic *nic)
 	nic->ufo_in_band_v = kcalloc(size, sizeof(u64), GFP_KERNEL);
 	if (!nic->ufo_in_band_v)
 		return -ENOMEM;
+	 mem_allocated += (size * sizeof(u64));
 
 	/* Allocation and initialization of RXDs in Rings */
 	size = 0;
@@ -639,6 +665,7 @@ static int init_shared_mem(struct s2io_nic *nic)
 				rx_blocks->block_virt_addr = tmp_v_addr;
 				return -ENOMEM;
 			}
+			mem_allocated += size;
 			memset(tmp_v_addr, 0, size);
 			rx_blocks->block_virt_addr = tmp_v_addr;
 			rx_blocks->block_dma_addr = tmp_p_addr;
@@ -647,6 +674,8 @@ static int init_shared_mem(struct s2io_nic *nic)
 						  GFP_KERNEL);
 			if (!rx_blocks->rxds)
 				return -ENOMEM;
+			mem_allocated += 
+			(sizeof(struct rxd_info)* rxd_count[nic->rxd_mode]);
 			for (l=0; l<rxd_count[nic->rxd_mode];l++) {
 				rx_blocks->rxds[l].virt_addr =
 					rx_blocks->block_virt_addr +
@@ -689,6 +718,7 @@ static int init_shared_mem(struct s2io_nic *nic)
 				     GFP_KERNEL);
 			if (!mac_control->rings[i].ba)
 				return -ENOMEM;
+			mem_allocated +=(sizeof(struct buffAdd *) * blk_cnt);
 			for (j = 0; j < blk_cnt; j++) {
 				int k = 0;
 				mac_control->rings[i].ba[j] =
@@ -697,6 +727,8 @@ static int init_shared_mem(struct s2io_nic *nic)
 						GFP_KERNEL);
 				if (!mac_control->rings[i].ba[j])
 					return -ENOMEM;
+				mem_allocated += (sizeof(struct buffAdd) *  \
+					(rxd_count[nic->rxd_mode] + 1));
 				while (k != rxd_count[nic->rxd_mode]) {
 					ba = &mac_control->rings[i].ba[j][k];
 
@@ -704,6 +736,8 @@ static int init_shared_mem(struct s2io_nic *nic)
 					    (BUF0_LEN + ALIGN_SIZE, GFP_KERNEL);
 					if (!ba->ba_0_org)
 						return -ENOMEM;
+					mem_allocated += 
+						(BUF0_LEN + ALIGN_SIZE);
 					tmp = (unsigned long)ba->ba_0_org;
 					tmp += ALIGN_SIZE;
 					tmp &= ~((unsigned long) ALIGN_SIZE);
@@ -713,6 +747,8 @@ static int init_shared_mem(struct s2io_nic *nic)
 					    (BUF1_LEN + ALIGN_SIZE, GFP_KERNEL);
 					if (!ba->ba_1_org)
 						return -ENOMEM;
+					mem_allocated 
+						+= (BUF1_LEN + ALIGN_SIZE);
 					tmp = (unsigned long) ba->ba_1_org;
 					tmp += ALIGN_SIZE;
 					tmp &= ~((unsigned long) ALIGN_SIZE);
@@ -736,6 +772,7 @@ static int init_shared_mem(struct s2io_nic *nic)
 		 */
 		return -ENOMEM;
 	}
+	mem_allocated += size;
 	mac_control->stats_mem_sz = size;
 
 	tmp_v_addr = mac_control->stats_mem;
@@ -743,7 +780,7 @@ static int init_shared_mem(struct s2io_nic *nic)
 	memset(tmp_v_addr, 0, size);
 	DBG_PRINT(INIT_DBG, "%s:Ring Mem PHY: 0x%llx\n", dev->name,
 		  (unsigned long long) tmp_p_addr);
-
+	mac_control->stats_info->sw_stat.mem_allocated += mem_allocated;
 	return SUCCESS;
 }
 
@@ -757,12 +794,14 @@ static int init_shared_mem(struct s2io_nic *nic)
 static void free_shared_mem(struct s2io_nic *nic)
 {
 	int i, j, blk_cnt, size;
+	u32 ufo_size = 0;
 	void *tmp_v_addr;
 	dma_addr_t tmp_p_addr;
 	struct mac_info *mac_control;
 	struct config_param *config;
 	int lst_size, lst_per_page;
 	struct net_device *dev = nic->dev;
+	int page_num = 0;
 
 	if (!nic)
 		return;
@@ -774,8 +813,9 @@ static void free_shared_mem(struct s2io_nic *nic)
 	lst_per_page = PAGE_SIZE / lst_size;
 
 	for (i = 0; i < config->tx_fifo_num; i++) {
-		int page_num = TXD_MEM_PAGE_CNT(config->tx_cfg[i].fifo_len,
-						lst_per_page);
+		ufo_size += config->tx_cfg[i].fifo_len;
+		page_num = TXD_MEM_PAGE_CNT(config->tx_cfg[i].fifo_len,
+							lst_per_page);
 		for (j = 0; j < page_num; j++) {
 			int mem_blks = (j * lst_per_page);
 			if (!mac_control->fifos[i].list_info)
@@ -790,6 +830,8 @@ static void free_shared_mem(struct s2io_nic *nic)
 					    mac_control->fifos[i].
 					    list_info[mem_blks].
 					    list_phy_addr);
+			nic->mac_control.stats_info->sw_stat.mem_freed 
+						+= PAGE_SIZE;
 		}
 		/* If we got a zero DMA address during allocation,
 		 * free the page now
@@ -803,8 +845,12 @@ static void free_shared_mem(struct s2io_nic *nic)
 				dev->name);
 			DBG_PRINT(INIT_DBG, "Virtual address %p\n",
 				mac_control->zerodma_virt_addr);
+			nic->mac_control.stats_info->sw_stat.mem_freed 
+						+= PAGE_SIZE;
 		}
 		kfree(mac_control->fifos[i].list_info);
+		nic->mac_control.stats_info->sw_stat.mem_freed += 
+		(nic->config.tx_cfg[i].fifo_len *sizeof(struct list_info_hold));
 	}
 
 	size = SIZE_OF_BLOCK;
@@ -819,7 +865,10 @@ static void free_shared_mem(struct s2io_nic *nic)
 				break;
 			pci_free_consistent(nic->pdev, size,
 					    tmp_v_addr, tmp_p_addr);
+			nic->mac_control.stats_info->sw_stat.mem_freed += size;
 			kfree(mac_control->rings[i].rx_blocks[j].rxds);
+			nic->mac_control.stats_info->sw_stat.mem_freed += 
+			( sizeof(struct rxd_info)* rxd_count[nic->rxd_mode]);
 		}
 	}
 
@@ -836,12 +885,20 @@ static void free_shared_mem(struct s2io_nic *nic)
 					struct buffAdd *ba =
 						&mac_control->rings[i].ba[j][k];
 					kfree(ba->ba_0_org);
+					nic->mac_control.stats_info->sw_stat.\
+					mem_freed += (BUF0_LEN + ALIGN_SIZE);
 					kfree(ba->ba_1_org);
+					nic->mac_control.stats_info->sw_stat.\
+					mem_freed += (BUF1_LEN + ALIGN_SIZE);
 					k++;
 				}
 				kfree(mac_control->rings[i].ba[j]);
+				nic->mac_control.stats_info->sw_stat.mem_freed 				+= (sizeof(struct buffAdd) * 
+				(rxd_count[nic->rxd_mode] + 1));
 			}
 			kfree(mac_control->rings[i].ba);
+			nic->mac_control.stats_info->sw_stat.mem_freed += 
+			(sizeof(struct buffAdd *) * blk_cnt);
 		}
 	}
 
@@ -850,9 +907,14 @@ static void free_shared_mem(struct s2io_nic *nic)
 				    mac_control->stats_mem_sz,
 				    mac_control->stats_mem,
 				    mac_control->stats_mem_phy);
+		nic->mac_control.stats_info->sw_stat.mem_freed += 
+			mac_control->stats_mem_sz;
 	}
-	if (nic->ufo_in_band_v)
+	if (nic->ufo_in_band_v) {
 		kfree(nic->ufo_in_band_v);
+		nic->mac_control.stats_info->sw_stat.mem_freed 
+			+= (ufo_size * sizeof(u64));
+	}
 }
 
 /**
@@ -2122,10 +2184,12 @@ static void free_tx_buffers(struct s2io_nic *nic)
 
 	for (i = 0; i < config->tx_fifo_num; i++) {
 		for (j = 0; j < config->tx_cfg[i].fifo_len - 1; j++) {
-			txdp = (struct TxD *) mac_control->fifos[i].list_info[j].
-			    list_virt_addr;
+			txdp = (struct TxD *) \
+			mac_control->fifos[i].list_info[j].list_virt_addr;
 			skb = s2io_txdl_getskb(&mac_control->fifos[i], txdp, j);
 			if (skb) {
+				nic->mac_control.stats_info->sw_stat.mem_freed 
+					+= skb->truesize;
 				dev_kfree_skb(skb);
 				cnt++;
 			}
@@ -2186,11 +2250,14 @@ static int fill_rxd_3buf(struct s2io_nic *nic, struct RxD_t *rxdp, struct \
 	/* skb_shinfo(skb)->frag_list will have L4 data payload */
 	skb_shinfo(skb)->frag_list = dev_alloc_skb(dev->mtu + ALIGN_SIZE);
 	if (skb_shinfo(skb)->frag_list == NULL) {
+		nic->mac_control.stats_info->sw_stat.mem_alloc_fail_cnt++;
 		DBG_PRINT(INFO_DBG, "%s: dev_alloc_skb failed\n ", dev->name);
 		return -ENOMEM ;
 	}
 	frag_list = skb_shinfo(skb)->frag_list;
 	skb->truesize += frag_list->truesize;
+	nic->mac_control.stats_info->sw_stat.mem_allocated 
+		+= frag_list->truesize;
 	frag_list->next = NULL;
 	tmp = (void *)ALIGN((long)frag_list->data, ALIGN_SIZE + 1);
 	frag_list->data = tmp;
@@ -2319,8 +2386,12 @@ static int fill_rx_buffers(struct s2io_nic *nic, int ring_no)
 				wmb();
 				first_rxdp->Control_1 |= RXD_OWN_XENA;
 			}
+			nic->mac_control.stats_info->sw_stat. \
+				mem_alloc_fail_cnt++;
 			return -ENOMEM ;
 		}
+		nic->mac_control.stats_info->sw_stat.mem_allocated 
+			+= skb->truesize;
 		if (nic->rxd_mode == RXD_MODE_1) {
 			/* 1 buffer mode - normal operation mode */
 			memset(rxdp, 0, sizeof(struct RxD1));
@@ -2328,7 +2399,8 @@ static int fill_rx_buffers(struct s2io_nic *nic, int ring_no)
 			((struct RxD1*)rxdp)->Buffer0_ptr = pci_map_single
 			    (nic->pdev, skb->data, size - NET_IP_ALIGN,
 				PCI_DMA_FROMDEVICE);
-			rxdp->Control_2 = SET_BUFFER0_SIZE_1(size - NET_IP_ALIGN);
+			rxdp->Control_2 = 
+				SET_BUFFER0_SIZE_1(size - NET_IP_ALIGN);
 
 		} else if (nic->rxd_mode >= RXD_MODE_3A) {
 			/*
@@ -2342,7 +2414,7 @@ static int fill_rx_buffers(struct s2io_nic *nic, int ring_no)
 			 * payload
 			 */
 
-			/* save the buffer pointers to avoid frequent dma mapping */
+			/* save buffer pointers to avoid frequent dma mapping */
 			Buffer0_ptr = ((struct RxD3*)rxdp)->Buffer0_ptr;
 			Buffer1_ptr = ((struct RxD3*)rxdp)->Buffer1_ptr;
 			memset(rxdp, 0, sizeof(struct RxD3));
@@ -2364,7 +2436,7 @@ static int fill_rx_buffers(struct s2io_nic *nic, int ring_no)
 					   PCI_DMA_FROMDEVICE);
 			else
 				pci_dma_sync_single_for_device(nic->pdev,
-				    (dma_addr_t) ((struct RxD3*)rxdp)->Buffer0_ptr,
+				(dma_addr_t) ((struct RxD3*)rxdp)->Buffer0_ptr,
 				    BUF0_LEN, PCI_DMA_FROMDEVICE);
 			rxdp->Control_2 = SET_BUFFER0_SIZE_3(BUF0_LEN);
 			if (nic->rxd_mode == RXD_MODE_3B) {
@@ -2391,6 +2463,8 @@ static int fill_rx_buffers(struct s2io_nic *nic, int ring_no)
 			} else {
 				/* 3 buffer mode */
 				if (fill_rxd_3buf(nic, rxdp, skb) == -ENOMEM) {
+					nic->mac_control.stats_info->sw_stat.\
+					mem_freed += skb->truesize;
 					dev_kfree_skb_irq(skb);
 					if (first_rxdp) {
 						wmb();
@@ -2491,6 +2565,7 @@ static void free_rxd_blk(struct s2io_nic *sp, int ring_no, int blk)
 				PCI_DMA_FROMDEVICE);
 			memset(rxdp, 0, sizeof(struct RxD3));
 		}
+		sp->mac_control.stats_info->sw_stat.mem_freed += skb->truesize;
 		dev_kfree_skb(skb);
 		atomic_dec(&sp->rx_bufs_left[ring_no]);
 	}
@@ -2820,13 +2895,35 @@ static void tx_intr_handler(struct fifo_info *fifo_data)
 				nic->mac_control.stats_info->sw_stat.
 						parity_err_cnt++;
 			}
-			if ((err >> 48) == 0xA) {
-				DBG_PRINT(TX_DBG, "TxD returned due \
-						to loss of link\n");
-			}
-			else {
-				DBG_PRINT(ERR_DBG, "***TxD error %llx\n", err);
-			}
+
+			/* update t_code statistics */
+			err >>= 48;
+			switch(err) {
+				case 2:
+					nic->mac_control.stats_info->sw_stat.
+							tx_buf_abort_cnt++;
+				break;
+
+				case 3:
+					nic->mac_control.stats_info->sw_stat.
+							tx_desc_abort_cnt++;
+				break;
+
+				case 7:
+					nic->mac_control.stats_info->sw_stat.
+							tx_parity_err_cnt++;
+				break;
+
+				case 10:
+					nic->mac_control.stats_info->sw_stat.
+							tx_link_loss_cnt++;
+				break;
+
+				case 15:
+					nic->mac_control.stats_info->sw_stat.
+							tx_list_proc_err_cnt++;
+				break;
+                        }
 		}
 
 		skb = s2io_txdl_getskb(fifo_data, txdlp, get_info.offset);
@@ -2839,6 +2936,7 @@ static void tx_intr_handler(struct fifo_info *fifo_data)
 
 		/* Updating the statistics block */
 		nic->stats.tx_bytes += skb->len;
+		nic->mac_control.stats_info->sw_stat.mem_freed += skb->truesize;
 		dev_kfree_skb_irq(skb);
 
 		get_info.offset++;
@@ -3314,7 +3412,9 @@ static void s2io_reset(struct s2io_nic * sp)
 	u16 subid, pci_cmd;
 	int i;
 	u16 val16;
-	unsigned long long reset_cnt = 0;
+	unsigned long long up_cnt, down_cnt, up_time, down_time, reset_cnt;
+	unsigned long long mem_alloc_cnt, mem_free_cnt, watchdog_cnt;
+
 	DBG_PRINT(INIT_DBG,"%s - Resetting XFrame card %s\n",
 			__FUNCTION__, sp->dev->name);
 
@@ -3380,11 +3480,26 @@ new_way:
 
 	/* Reset device statistics maintained by OS */
 	memset(&sp->stats, 0, sizeof (struct net_device_stats));
-	/* save reset count */
+	
+	up_cnt = sp->mac_control.stats_info->sw_stat.link_up_cnt;
+	down_cnt = sp->mac_control.stats_info->sw_stat.link_down_cnt;
+	up_time = sp->mac_control.stats_info->sw_stat.link_up_time;
+	down_time = sp->mac_control.stats_info->sw_stat.link_down_time;
 	reset_cnt = sp->mac_control.stats_info->sw_stat.soft_reset_cnt;
+	mem_alloc_cnt = sp->mac_control.stats_info->sw_stat.mem_allocated;
+	mem_free_cnt = sp->mac_control.stats_info->sw_stat.mem_freed;
+	watchdog_cnt = sp->mac_control.stats_info->sw_stat.watchdog_timer_cnt;
+	/* save link up/down time/cnt, reset/memory/watchdog cnt */
 	memset(sp->mac_control.stats_info, 0, sizeof(struct stat_block));
-	/* restore reset count */
+	/* restore link up/down time/cnt, reset/memory/watchdog cnt */
+	sp->mac_control.stats_info->sw_stat.link_up_cnt = up_cnt;
+	sp->mac_control.stats_info->sw_stat.link_down_cnt = down_cnt;
+	sp->mac_control.stats_info->sw_stat.link_up_time = up_time;
+	sp->mac_control.stats_info->sw_stat.link_down_time = down_time;
 	sp->mac_control.stats_info->sw_stat.soft_reset_cnt = reset_cnt;
+	sp->mac_control.stats_info->sw_stat.mem_allocated = mem_alloc_cnt;
+	sp->mac_control.stats_info->sw_stat.mem_freed = mem_free_cnt;
+	sp->mac_control.stats_info->sw_stat.watchdog_timer_cnt = watchdog_cnt;
 
 	/* SXE-002: Configure link and activity LED to turn it off */
 	subid = sp->pdev->subsystem_device;
@@ -3672,19 +3787,29 @@ static int s2io_enable_msi_x(struct s2io_nic *nic)
 	nic->entries = kmalloc(MAX_REQUESTED_MSI_X * sizeof(struct msix_entry),
 			       GFP_KERNEL);
 	if (nic->entries == NULL) {
-		DBG_PRINT(INFO_DBG, "%s: Memory allocation failed\n", __FUNCTION__);
+		DBG_PRINT(INFO_DBG, "%s: Memory allocation failed\n", \
+			__FUNCTION__);
+		nic->mac_control.stats_info->sw_stat.mem_alloc_fail_cnt++;
 		return -ENOMEM;
 	}
-	memset(nic->entries, 0, MAX_REQUESTED_MSI_X * sizeof(struct msix_entry));
+	nic->mac_control.stats_info->sw_stat.mem_allocated 
+		+= (MAX_REQUESTED_MSI_X * sizeof(struct msix_entry));
+	memset(nic->entries, 0,MAX_REQUESTED_MSI_X * sizeof(struct msix_entry));
 
 	nic->s2io_entries =
 		kmalloc(MAX_REQUESTED_MSI_X * sizeof(struct s2io_msix_entry),
 				   GFP_KERNEL);
 	if (nic->s2io_entries == NULL) {
-		DBG_PRINT(INFO_DBG, "%s: Memory allocation failed\n", __FUNCTION__);
+		DBG_PRINT(INFO_DBG, "%s: Memory allocation failed\n", 
+			__FUNCTION__);
+		nic->mac_control.stats_info->sw_stat.mem_alloc_fail_cnt++;
 		kfree(nic->entries);
+		nic->mac_control.stats_info->sw_stat.mem_freed 
+			+= (MAX_REQUESTED_MSI_X * sizeof(struct msix_entry));
 		return -ENOMEM;
 	}
+	 nic->mac_control.stats_info->sw_stat.mem_allocated 
+		+= (MAX_REQUESTED_MSI_X * sizeof(struct s2io_msix_entry));
 	memset(nic->s2io_entries, 0,
 	       MAX_REQUESTED_MSI_X * sizeof(struct s2io_msix_entry));
 
@@ -3708,7 +3833,8 @@ static int s2io_enable_msi_x(struct s2io_nic *nic)
 		rx_mat = readq(&bar0->rx_mat);
 		for (j=0; j<nic->config.rx_ring_num; j++, msix_indx++) {
 			rx_mat |= RX_MAT_SET(j, msix_indx);
-			nic->s2io_entries[msix_indx].arg = &nic->mac_control.rings[j];
+			nic->s2io_entries[msix_indx].arg 
+				= &nic->mac_control.rings[j];
 			nic->s2io_entries[msix_indx].type = MSIX_RING_TYPE;
 			nic->s2io_entries[msix_indx].in_use = MSIX_FLG;
 		}
@@ -3717,7 +3843,8 @@ static int s2io_enable_msi_x(struct s2io_nic *nic)
 		tx_mat = readq(&bar0->tx_mat0_n[7]);
 		for (j=0; j<nic->config.rx_ring_num; j++, msix_indx++) {
 			tx_mat |= TX_MAT_SET(i, msix_indx);
-			nic->s2io_entries[msix_indx].arg = &nic->mac_control.rings[j];
+			nic->s2io_entries[msix_indx].arg 
+				= &nic->mac_control.rings[j];
 			nic->s2io_entries[msix_indx].type = MSIX_RING_TYPE;
 			nic->s2io_entries[msix_indx].in_use = MSIX_FLG;
 		}
@@ -3734,7 +3861,11 @@ static int s2io_enable_msi_x(struct s2io_nic *nic)
 	if (ret) {
 		DBG_PRINT(ERR_DBG, "%s: Enabling MSIX failed\n", nic->dev->name);
 		kfree(nic->entries);
+		nic->mac_control.stats_info->sw_stat.mem_freed 
+			+= (MAX_REQUESTED_MSI_X * sizeof(struct msix_entry));
 		kfree(nic->s2io_entries);
+		nic->mac_control.stats_info->sw_stat.mem_freed 
+		+= (MAX_REQUESTED_MSI_X * sizeof(struct s2io_msix_entry));
 		nic->entries = NULL;
 		nic->s2io_entries = NULL;
 		nic->avail_msix_vectors = 0;
@@ -3802,10 +3933,16 @@ static int s2io_open(struct net_device *dev)
 
 hw_init_failed:
 	if (sp->intr_type == MSI_X) {
-		if (sp->entries)
+		if (sp->entries) {
 			kfree(sp->entries);
-		if (sp->s2io_entries)
+			sp->mac_control.stats_info->sw_stat.mem_freed 
+			+= (MAX_REQUESTED_MSI_X * sizeof(struct msix_entry));
+		}
+		if (sp->s2io_entries) {
 			kfree(sp->s2io_entries);
+			sp->mac_control.stats_info->sw_stat.mem_freed 
+			+= (MAX_REQUESTED_MSI_X * sizeof(struct s2io_msix_entry));
+		}
 	}
 	return err;
 }
@@ -3866,6 +4003,13 @@ static int s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 	config = &sp->config;
 
 	DBG_PRINT(TX_DBG, "%s: In Neterion Tx routine\n", dev->name);
+
+	if (unlikely(skb->len <= 0)) {
+		DBG_PRINT(TX_DBG, "%s:Buffer has no data..\n", dev->name);
+		dev_kfree_skb_any(skb);
+		return 0;
+}
+
 	spin_lock_irqsave(&sp->tx_lock, flags);
 	if (atomic_read(&sp->card_state) == CARD_DOWN) {
 		DBG_PRINT(TX_DBG, "%s: Card going down for reset\n",
@@ -3876,7 +4020,6 @@ static int s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	queue = 0;
-
 	/* Get Fifo number to Transmit based on vlan priority */
 	if (sp->vlgrp && vlan_tx_tag_present(skb)) {
 		vlan_tag = vlan_tx_tag_get(skb);
@@ -3900,14 +4043,6 @@ static int s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 		return 0;
 	}
 
-	/* A buffer with no data will be dropped */
-	if (!skb->len) {
-		DBG_PRINT(TX_DBG, "%s:Buffer has no data..\n", dev->name);
-		dev_kfree_skb(skb);
-		spin_unlock_irqrestore(&sp->tx_lock, flags);
-		return 0;
-	}
-
 	offload_type = s2io_offload_type(skb);
 	if (offload_type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6)) {
 		txdp->Control_1 |= TXD_TCP_LSO_EN;
@@ -4003,7 +4138,7 @@ static int s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 			  put_off, get_off);
 		netif_stop_queue(dev);
 	}
-
+	mac_control->stats_info->sw_stat.mem_allocated += skb->truesize;
 	dev->trans_start = jiffies;
 	spin_unlock_irqrestore(&sp->tx_lock, flags);
 
@@ -4775,6 +4910,40 @@ static int s2io_ethtool_idnic(struct net_device *dev, u32 data)
 	return 0;
 }
 
+static void s2io_ethtool_gringparam(struct net_device *dev,
+                                    struct ethtool_ringparam *ering)
+{
+	struct s2io_nic *sp = dev->priv;
+	int i,tx_desc_count=0,rx_desc_count=0;
+
+	if (sp->rxd_mode == RXD_MODE_1)
+		ering->rx_max_pending = MAX_RX_DESC_1;
+	else if (sp->rxd_mode == RXD_MODE_3B)
+		ering->rx_max_pending = MAX_RX_DESC_2;
+	else if (sp->rxd_mode == RXD_MODE_3A)
+		ering->rx_max_pending = MAX_RX_DESC_3;
+
+	ering->tx_max_pending = MAX_TX_DESC;
+	for (i = 0 ; i < sp->config.tx_fifo_num ; i++) {
+		tx_desc_count += sp->config.tx_cfg[i].fifo_len;
+	}
+	DBG_PRINT(INFO_DBG,"\nmax txds : %d\n",sp->config.max_txds);
+	ering->tx_pending = tx_desc_count;
+	rx_desc_count = 0;
+	for (i = 0 ; i < sp->config.rx_ring_num ; i++) {
+		rx_desc_count += sp->config.rx_cfg[i].num_rxd;
+	}
+	ering->rx_pending = rx_desc_count;
+
+	ering->rx_mini_max_pending = 0;
+	ering->rx_mini_pending = 0;
+	if(sp->rxd_mode == RXD_MODE_1)
+		ering->rx_jumbo_max_pending = MAX_RX_DESC_1;
+	else if (sp->rxd_mode == RXD_MODE_3B)
+		ering->rx_jumbo_max_pending = MAX_RX_DESC_2;
+	ering->rx_jumbo_pending = rx_desc_count;
+}
+
 /**
  * s2io_ethtool_getpause_data -Pause frame frame generation and reception.
  * @sp : private member of the device structure, which is a pointer to the
@@ -4981,8 +5150,11 @@ static void s2io_vpd_read(struct s2io_nic *nic)
 	strcpy(nic->serial_num, "NOT AVAILABLE");
 
 	vpd_data = kmalloc(256, GFP_KERNEL);
-	if (!vpd_data)
+	if (!vpd_data) {
+		nic->mac_control.stats_info->sw_stat.mem_alloc_fail_cnt++;
 		return;
+	}
+	nic->mac_control.stats_info->sw_stat.mem_allocated += 256;
 
 	for (i = 0; i < 256; i +=4 ) {
 		pci_write_config_byte(nic->pdev, (vpd_addr + 2), i);
@@ -5022,6 +5194,7 @@ static void s2io_vpd_read(struct s2io_nic *nic)
 		memcpy(nic->product_name, &vpd_data[3], vpd_data[1]);
 	}
 	kfree(vpd_data);
+	nic->mac_control.stats_info->sw_stat.mem_freed += 256;
 }
 
 /**
@@ -5742,6 +5915,30 @@ static void s2io_get_ethtool_stats(struct net_device *dev,
 	}
 	else
 		tmp_stats[i++] = 0;
+	tmp_stats[i++] = stat_info->sw_stat.mem_alloc_fail_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.watchdog_timer_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.mem_allocated;
+	tmp_stats[i++] = stat_info->sw_stat.mem_freed;
+	tmp_stats[i++] = stat_info->sw_stat.link_up_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.link_down_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.link_up_time;
+	tmp_stats[i++] = stat_info->sw_stat.link_down_time;
+
+	tmp_stats[i++] = stat_info->sw_stat.tx_buf_abort_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.tx_desc_abort_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.tx_parity_err_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.tx_link_loss_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.tx_list_proc_err_cnt;
+
+	tmp_stats[i++] = stat_info->sw_stat.rx_parity_err_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.rx_abort_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.rx_parity_abort_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.rx_rda_fail_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.rx_unkn_prot_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.rx_fcs_err_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.rx_buf_size_err_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.rx_rxd_corrupt_cnt;
+	tmp_stats[i++] = stat_info->sw_stat.rx_unkn_err_cnt;
 }
 
 static int s2io_ethtool_get_regs_len(struct net_device *dev)
@@ -5854,6 +6051,7 @@ static const struct ethtool_ops netdev_ethtool_ops = {
 	.get_eeprom_len = s2io_get_eeprom_len,
 	.get_eeprom = s2io_ethtool_geeprom,
 	.set_eeprom = s2io_ethtool_seeprom,
+	.get_ringparam = s2io_ethtool_gringparam,
 	.get_pauseparam = s2io_ethtool_getpause_data,
 	.set_pauseparam = s2io_ethtool_setpause_data,
 	.get_rx_csum = s2io_ethtool_get_rx_csum,
@@ -5962,7 +6160,7 @@ static void s2io_tasklet(unsigned long dev_addr)
 			if (ret == -ENOMEM) {
 				DBG_PRINT(INFO_DBG, "%s: Out of ",
 					  dev->name);
-				DBG_PRINT(ERR_DBG, "memory in tasklet\n");
+				DBG_PRINT(INFO_DBG, "memory in tasklet\n");
 				break;
 			} else if (ret == -EFILL) {
 				DBG_PRINT(INFO_DBG,
@@ -6077,9 +6275,14 @@ static int set_rxd_buffer_pointer(struct s2io_nic *sp, struct RxD_t *rxdp,
 			*skb = dev_alloc_skb(size);
 			if (!(*skb)) {
 				DBG_PRINT(INFO_DBG, "%s: Out of ", dev->name);
-				DBG_PRINT(INFO_DBG, "memory to allocate SKBs\n");
+				DBG_PRINT(INFO_DBG, "memory to allocate ");
+				DBG_PRINT(INFO_DBG, "1 buf mode SKBs\n");
+				sp->mac_control.stats_info->sw_stat. \
+					mem_alloc_fail_cnt++;
 				return -ENOMEM ;
 			}
+			sp->mac_control.stats_info->sw_stat.mem_allocated 
+				+= (*skb)->truesize;
 			/* storing the mapped addr in a temp variable
 			 * such it will be used for next rxd whose
 			 * Host Control is NULL
@@ -6099,10 +6302,15 @@ static int set_rxd_buffer_pointer(struct s2io_nic *sp, struct RxD_t *rxdp,
 		} else {
 			*skb = dev_alloc_skb(size);
 			if (!(*skb)) {
-				DBG_PRINT(INFO_DBG, "%s: dev_alloc_skb failed\n",
-					dev->name);
+				DBG_PRINT(INFO_DBG, "%s: Out of ", dev->name);
+				DBG_PRINT(INFO_DBG, "memory to allocate ");
+				DBG_PRINT(INFO_DBG, "2 buf mode SKBs\n");
+				sp->mac_control.stats_info->sw_stat. \
+					mem_alloc_fail_cnt++;
 				return -ENOMEM;
 			}
+			sp->mac_control.stats_info->sw_stat.mem_allocated 
+				+= (*skb)->truesize;
 			((struct RxD3*)rxdp)->Buffer2_ptr = *temp2 =
 				pci_map_single(sp->pdev, (*skb)->data,
 					       dev->mtu + 4,
@@ -6126,10 +6334,15 @@ static int set_rxd_buffer_pointer(struct s2io_nic *sp, struct RxD_t *rxdp,
 		} else {
 			*skb = dev_alloc_skb(size);
 			if (!(*skb)) {
-				DBG_PRINT(INFO_DBG, "%s: dev_alloc_skb failed\n",
-					  dev->name);
+				DBG_PRINT(INFO_DBG, "%s: Out of ", dev->name);
+				DBG_PRINT(INFO_DBG, "memory to allocate ");
+				DBG_PRINT(INFO_DBG, "3 buf mode SKBs\n");
+				sp->mac_control.stats_info->sw_stat. \
+					mem_alloc_fail_cnt++;
 				return -ENOMEM;
 			}
+			sp->mac_control.stats_info->sw_stat.mem_allocated 
+				+= (*skb)->truesize;
 			((struct RxD3*)rxdp)->Buffer0_ptr = *temp0 =
 				pci_map_single(sp->pdev, ba->ba_0, BUF0_LEN,
 					       PCI_DMA_FROMDEVICE);
@@ -6147,10 +6360,14 @@ static int set_rxd_buffer_pointer(struct s2io_nic *sp, struct RxD_t *rxdp,
 			if (skb_shinfo(*skb)->frag_list == NULL) {
 				DBG_PRINT(ERR_DBG, "%s: dev_alloc_skb \
 					  failed\n ", dev->name);
+				sp->mac_control.stats_info->sw_stat. \
+					mem_alloc_fail_cnt++;
 				return -ENOMEM ;
 			}
 			frag_list = skb_shinfo(*skb)->frag_list;
 			frag_list->next = NULL;
+			sp->mac_control.stats_info->sw_stat.mem_allocated 
+				+= frag_list->truesize;
 			/*
 			 * Buffer-2 receives L4 data payload
 			 */
@@ -6566,6 +6783,7 @@ static void s2io_tx_watchdog(struct net_device *dev)
 	struct s2io_nic *sp = dev->priv;
 
 	if (netif_carrier_ok(dev)) {
+		sp->mac_control.stats_info->sw_stat.watchdog_timer_cnt++;
 		schedule_work(&sp->rst_timer_task);
 		sp->mac_control.stats_info->sw_stat.soft_reset_cnt++;
 	}
@@ -6606,7 +6824,53 @@ static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp)
 		if (err & 0x1) {
 			sp->mac_control.stats_info->sw_stat.parity_err_cnt++;
 		}
+		err >>= 48;
+		switch(err) {
+			case 1:
+				sp->mac_control.stats_info->sw_stat.
+				rx_parity_err_cnt++;
+			break;
 
+			case 2:
+				sp->mac_control.stats_info->sw_stat.
+				rx_abort_cnt++;
+			break;
+
+			case 3:
+				sp->mac_control.stats_info->sw_stat.
+				rx_parity_abort_cnt++;
+			break;
+
+			case 4:
+				sp->mac_control.stats_info->sw_stat.
+				rx_rda_fail_cnt++;
+			break;
+
+			case 5:
+				sp->mac_control.stats_info->sw_stat.
+				rx_unkn_prot_cnt++;
+			break;
+
+			case 6:
+				sp->mac_control.stats_info->sw_stat.
+				rx_fcs_err_cnt++;
+			break;
+
+			case 7:
+				sp->mac_control.stats_info->sw_stat.
+				rx_buf_size_err_cnt++;
+			break;
+
+			case 8:
+				sp->mac_control.stats_info->sw_stat.
+				rx_rxd_corrupt_cnt++;
+			break;
+
+			case 15:
+				sp->mac_control.stats_info->sw_stat.
+				rx_unkn_err_cnt++;
+			break;
+		}
 		/*
 		* Drop the packet if bad transfer code. Exception being
 		* 0x5, which could be due to unsupported IPv6 extension header.
@@ -6614,10 +6878,12 @@ static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp)
 		* Note that in this case, since checksum will be incorrect,
 		* stack will validate the same.
 		*/
-		if (err && ((err >> 48) != 0x5)) {
+		if (err != 0x5) {
 			DBG_PRINT(ERR_DBG, "%s: Rx error Value: 0x%llx\n",
 				dev->name, err);
 			sp->stats.rx_crc_errors++;
+			sp->mac_control.stats_info->sw_stat.mem_freed 
+				+= skb->truesize;
 			dev_kfree_skb(skb);
 			atomic_dec(&sp->rx_bufs_left[ring_no]);
 			rxdp->Host_Control = 0;
@@ -6627,7 +6893,6 @@ static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp)
 
 	/* Updating statistics */
 	rxdp->Host_Control = 0;
-	sp->stats.rx_packets++;
 	if (sp->rxd_mode == RXD_MODE_1) {
 		int len = RXD_GET_BUFFER0_SIZE_1(rxdp->Control_2);
 
@@ -6731,7 +6996,7 @@ static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp)
 	} else {
 		skb->ip_summed = CHECKSUM_NONE;
 	}
-
+	sp->mac_control.stats_info->sw_stat.mem_freed += skb->truesize;
 	if (!sp->lro) {
 		skb->protocol = eth_type_trans(skb, dev);
 		if ((sp->vlgrp && RXD_GET_VLAN_TAG(rxdp->Control_2) &&
@@ -6780,12 +7045,21 @@ static void s2io_link(struct s2io_nic * sp, int link)
 		if (link == LINK_DOWN) {
 			DBG_PRINT(ERR_DBG, "%s: Link down\n", dev->name);
 			netif_carrier_off(dev);
+			if(sp->mac_control.stats_info->sw_stat.link_up_cnt)
+			sp->mac_control.stats_info->sw_stat.link_up_time = 
+				jiffies - sp->start_time;
+			sp->mac_control.stats_info->sw_stat.link_down_cnt++;
 		} else {
 			DBG_PRINT(ERR_DBG, "%s: Link Up\n", dev->name);
+			if (sp->mac_control.stats_info->sw_stat.link_down_cnt)
+			sp->mac_control.stats_info->sw_stat.link_down_time = 
+				jiffies - sp->start_time;
+			sp->mac_control.stats_info->sw_stat.link_up_cnt++;
 			netif_carrier_on(dev);
 		}
 	}
 	sp->last_link_state = link;
+	sp->start_time = jiffies;
 }
 
 /**
diff --git a/drivers/net/s2io.h b/drivers/net/s2io.h
index a656d18..54baa0b 100644
--- a/drivers/net/s2io.h
+++ b/drivers/net/s2io.h
@@ -95,6 +95,32 @@ struct swStat {
 	unsigned long long flush_max_pkts;
 	unsigned long long sum_avg_pkts_aggregated;
 	unsigned long long num_aggregations;
+	/* Other statistics */
+	unsigned long long mem_alloc_fail_cnt;
+	unsigned long long watchdog_timer_cnt;
+	unsigned long long mem_allocated;
+	unsigned long long mem_freed;
+	unsigned long long link_up_cnt;
+	unsigned long long link_down_cnt;
+	unsigned long long link_up_time;
+	unsigned long long link_down_time;
+
+	/* Transfer Code statistics */
+	unsigned long long tx_buf_abort_cnt;
+	unsigned long long tx_desc_abort_cnt;
+	unsigned long long tx_parity_err_cnt;
+	unsigned long long tx_link_loss_cnt;
+	unsigned long long tx_list_proc_err_cnt;
+
+	unsigned long long rx_parity_err_cnt;
+	unsigned long long rx_abort_cnt;
+	unsigned long long rx_parity_abort_cnt;
+	unsigned long long rx_rda_fail_cnt;
+	unsigned long long rx_unkn_prot_cnt;
+	unsigned long long rx_fcs_err_cnt;
+	unsigned long long rx_buf_size_err_cnt;
+	unsigned long long rx_rxd_corrupt_cnt;
+	unsigned long long rx_unkn_err_cnt;
 };
 
 /* Xpak releated alarm and warnings */
@@ -308,6 +334,11 @@ struct stat_block {
 #define MAX_TX_FIFOS 8
 #define MAX_RX_RINGS 8
 
+#define MAX_RX_DESC_1  (MAX_RX_RINGS * MAX_RX_BLOCKS_PER_RING * 127 )
+#define MAX_RX_DESC_2  (MAX_RX_RINGS * MAX_RX_BLOCKS_PER_RING * 85 )
+#define MAX_RX_DESC_3  (MAX_RX_RINGS * MAX_RX_BLOCKS_PER_RING * 85 )
+#define MAX_TX_DESC    (MAX_AVAILABLE_TXDS)
+
 /* FIFO mappings for all possible number of fifos configured */
 static int fifo_map[][MAX_TX_FIFOS] = {
 	{0, 0, 0, 0, 0, 0, 0, 0},
@@ -819,6 +850,7 @@ struct s2io_nic {
 #define	LINK_UP		2
 
 	int task_flag;
+	unsigned long long start_time;
 #define CARD_DOWN 1
 #define CARD_UP 2
 	atomic_t card_state;
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index e048957..7766929 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -3802,6 +3802,9 @@ static int skge_suspend(struct pci_dev *pdev, pm_message_t state)
 	struct skge_hw *hw  = pci_get_drvdata(pdev);
 	int i, err, wol = 0;
 
+	if (!hw)
+		return 0;
+
 	err = pci_save_state(pdev);
 	if (err)
 		return err;
@@ -3830,6 +3833,9 @@ static int skge_resume(struct pci_dev *pdev)
 	struct skge_hw *hw  = pci_get_drvdata(pdev);
 	int i, err;
 
+	if (!hw)
+		return 0;
+
 	err = pci_set_power_state(pdev, PCI_D0);
 	if (err)
 		goto out;
@@ -3868,6 +3874,9 @@ static void skge_shutdown(struct pci_dev *pdev)
 	struct skge_hw *hw  = pci_get_drvdata(pdev);
 	int i, wol = 0;
 
+	if (!hw)
+		return;
+
 	for (i = 0; i < hw->ports; i++) {
 		struct net_device *dev = hw->dev[i];
 		struct skge_port *skge = netdev_priv(dev);
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index a307310..104e204 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -40,6 +40,7 @@
 #include <linux/if_vlan.h>
 #include <linux/prefetch.h>
 #include <linux/mii.h>
+#include <linux/dmi.h>
 
 #include <asm/irq.h>
 
@@ -130,7 +131,7 @@ static const struct pci_device_id sky2_id_table[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4368) }, /* 88EC034 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4369) }, /* 88EC042 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x436A) }, /* 88E8058 */
-	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x436B) }, /* 88E8071 */
+//	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x436B) }, /* 88E8071 */
 	{ 0 }
 };
 
@@ -150,6 +151,8 @@ static const char *yukon2_name[] = {
 	"FE",		/* 0xb7 */
 };
 
+static int dmi_blacklisted;
+
 /* Access to external PHY */
 static int gm_phy_write(struct sky2_hw *hw, unsigned port, u16 reg, u16 val)
 {
@@ -2531,6 +2534,17 @@ static int __devinit sky2_init(struct sky2_hw *hw)
 		return -EOPNOTSUPP;
 	}
 
+
+	/* Some Gigabyte motherboards have 88e8056 but cause problems
+	 * There is some unresolved hardware related problem that causes
+	 * descriptor errors and receive data corruption.
+	 */
+	if (hw->chip_id == CHIP_ID_YUKON_EC_U && dmi_blacklisted) {
+		dev_err(&hw->pdev->dev,
+			"88E8056 on this motherboard not supported\n");
+		return -EOPNOTSUPP;
+	}
+
 	hw->pmd_type = sky2_read8(hw, B2_PMD_TYP);
 	hw->ports = 1;
 	t8 = sky2_read8(hw, B2_Y2_HW_RES);
@@ -3578,17 +3592,6 @@ static int __devinit sky2_probe(struct pci_dev *pdev,
 		goto err_out;
 	}
 
-	/* Some Gigabyte motherboards have 88e8056 but cause problems
-	 * There is some unresolved hardware related problem that causes
-	 * descriptor errors and receive data corruption.
-	 */
-	if (pdev->vendor == PCI_VENDOR_ID_MARVELL &&
-	    pdev->device == 0x4364 && pdev->subsystem_vendor == 0x1458) {
-		dev_err(&pdev->dev,
-			"88E8056 on Gigabyte motherboards not supported\n");
-		goto err_out_disable;
-	}
-
 	err = pci_request_regions(pdev, DRV_NAME);
 	if (err) {
 		dev_err(&pdev->dev, "cannot obtain PCI resources\n");
@@ -3732,6 +3735,7 @@ err_out_free_regions:
 err_out_disable:
 	pci_disable_device(pdev);
 err_out:
+	pci_set_drvdata(pdev, NULL);
 	return err;
 }
 
@@ -3784,6 +3788,9 @@ static int sky2_suspend(struct pci_dev *pdev, pm_message_t state)
 	struct sky2_hw *hw = pci_get_drvdata(pdev);
 	int i, wol = 0;
 
+	if (!hw)
+		return 0;
+
 	del_timer_sync(&hw->idle_timer);
 	netif_poll_disable(hw->dev[0]);
 
@@ -3815,6 +3822,9 @@ static int sky2_resume(struct pci_dev *pdev)
 	struct sky2_hw *hw = pci_get_drvdata(pdev);
 	int i, err;
 
+	if (!hw)
+		return 0;
+
 	err = pci_set_power_state(pdev, PCI_D0);
 	if (err)
 		goto out;
@@ -3861,6 +3871,9 @@ static void sky2_shutdown(struct pci_dev *pdev)
 	struct sky2_hw *hw = pci_get_drvdata(pdev);
 	int i, wol = 0;
 
+	if (!hw)
+		return;
+
 	del_timer_sync(&hw->idle_timer);
 	netif_poll_disable(hw->dev[0]);
 
@@ -3897,8 +3910,24 @@ static struct pci_driver sky2_driver = {
 	.shutdown = sky2_shutdown,
 };
 
+static struct dmi_system_id __initdata broken_dmi_table[] = {
+	{
+		.ident = "Gigabyte 965P-S3",
+		.matches = {
+			DMI_MATCH(DMI_SYS_VENDOR, "Gigabyte Technology Co., Ltd."),
+			DMI_MATCH(DMI_PRODUCT_NAME, "965P-S3"),
+
+		},
+	},
+	{ }
+};
+
 static int __init sky2_init_module(void)
 {
+	/* Look for sick motherboards */
+	if (dmi_check_system(broken_dmi_table))
+		dmi_blacklisted = 1;
+
 	return pci_register_driver(&sky2_driver);
 }
 
diff --git a/drivers/net/spider_net.c b/drivers/net/spider_net.c
index c15e972..108adbf 100644
--- a/drivers/net/spider_net.c
+++ b/drivers/net/spider_net.c
@@ -175,12 +175,10 @@ spider_net_setup_aneg(struct spider_net_card *card)
 {
 	struct mii_phy *phy = &card->phy;
 	u32 advertise = 0;
-	u16 bmcr, bmsr, stat1000, estat;
+	u16 bmsr, estat;
 
-	bmcr     = spider_net_read_phy(card->netdev, phy->mii_id, MII_BMCR);
-	bmsr     = spider_net_read_phy(card->netdev, phy->mii_id, MII_BMSR);
-	stat1000 = spider_net_read_phy(card->netdev, phy->mii_id, MII_STAT1000);
-	estat    = spider_net_read_phy(card->netdev, phy->mii_id, MII_ESTATUS);
+	bmsr  = spider_net_read_phy(card->netdev, phy->mii_id, MII_BMSR);
+	estat = spider_net_read_phy(card->netdev, phy->mii_id, MII_ESTATUS);
 
 	if (bmsr & BMSR_10HALF)
 		advertise |= ADVERTISED_10baseT_Half;
diff --git a/drivers/net/wan/Kconfig b/drivers/net/wan/Kconfig
index 8897f53..4fc8681 100644
--- a/drivers/net/wan/Kconfig
+++ b/drivers/net/wan/Kconfig
@@ -2,10 +2,7 @@
 # wan devices configuration
 #
 
-menu "Wan interfaces"
-	depends on NETDEVICES
-
-config WAN
+menuconfig WAN
 	bool "Wan interfaces support"
 	---help---
 	  Wide Area Networks (WANs), such as X.25, Frame Relay and leased
@@ -23,10 +20,12 @@ config WAN
 
 	  If unsure, say N.
 
+if WAN
+
 # There is no way to detect a comtrol sv11 - force it modular for now.
 config HOSTESS_SV11
 	tristate "Comtrol Hostess SV-11 support"
-	depends on WAN && ISA && m && ISA_DMA_API && INET
+	depends on ISA && m && ISA_DMA_API && INET
 	help
 	  Driver for Comtrol Hostess SV-11 network card which
 	  operates on low speed synchronous serial links at up to
@@ -38,7 +37,7 @@ config HOSTESS_SV11
 # The COSA/SRP driver has not been tested as non-modular yet.
 config COSA
 	tristate "COSA/SRP sync serial boards support"
-	depends on WAN && ISA && m && ISA_DMA_API
+	depends on ISA && m && ISA_DMA_API
 	---help---
 	  Driver for COSA and SRP synchronous serial boards.
 
@@ -62,7 +61,7 @@ config COSA
 #
 config LANMEDIA
 	tristate "LanMedia Corp. SSI/V.35, T1/E1, HSSI, T3 boards"
-	depends on WAN && PCI
+	depends on PCI
 	---help---
 	  Driver for the following Lan Media family of serial boards:
 
@@ -89,7 +88,7 @@ config LANMEDIA
 # There is no way to detect a Sealevel board. Force it modular
 config SEALEVEL_4021
 	tristate "Sealevel Systems 4021 support"
-	depends on WAN && ISA && m && ISA_DMA_API && INET
+	depends on ISA && m && ISA_DMA_API && INET
 	help
 	  This is a driver for the Sealevel Systems ACB 56 serial I/O adapter.
 
@@ -99,7 +98,6 @@ config SEALEVEL_4021
 # Generic HDLC
 config HDLC
 	tristate "Generic HDLC layer"
-	depends on WAN
 	help
 	  Say Y to this option if your Linux box contains a WAN (Wide Area
 	  Network) card supported by this driver and you are planning to
@@ -167,7 +165,7 @@ config HDLC_X25
 	  If unsure, say N.
 
 comment "X.25/LAPB support is disabled"
-	depends on WAN && HDLC && (LAPB!=m || HDLC!=m) && LAPB!=y
+	depends on HDLC && (LAPB!=m || HDLC!=m) && LAPB!=y
 
 config PCI200SYN
 	tristate "Goramo PCI200SYN support"
@@ -230,10 +228,10 @@ config PC300_MLPPP
 	  Multilink PPP over the PC300 synchronous communication boards.
 
 comment "Cyclades-PC300 MLPPP support is disabled."
-	depends on WAN && HDLC && PC300 && (PPP=n || !PPP_MULTILINK || PPP_SYNC_TTY=n || !HDLC_PPP)
+	depends on HDLC && PC300 && (PPP=n || !PPP_MULTILINK || PPP_SYNC_TTY=n || !HDLC_PPP)
 
 comment "Refer to the file README.mlppp, provided by PC300 package."
-	depends on WAN && HDLC && PC300 && (PPP=n || !PPP_MULTILINK || PPP_SYNC_TTY=n || !HDLC_PPP)
+	depends on HDLC && PC300 && (PPP=n || !PPP_MULTILINK || PPP_SYNC_TTY=n || !HDLC_PPP)
 
 config PC300TOO
 	tristate "Cyclades PC300 RSV/X21 alternative support"
@@ -338,7 +336,6 @@ config DSCC4_PCI_RST
 
 config DLCI
 	tristate "Frame Relay DLCI support"
-	depends on WAN
 	---help---
 	  Support for the Frame Relay protocol.
 
@@ -385,7 +382,7 @@ config SDLA
 # Wan router core.
 config WAN_ROUTER_DRIVERS
 	tristate "WAN router drivers"
-	depends on WAN && WAN_ROUTER
+	depends on WAN_ROUTER
 	---help---
 	  Connect LAN to WAN via Linux box.
 
@@ -440,7 +437,7 @@ config CYCLOMX_X25
 # X.25 network drivers
 config LAPBETHER
 	tristate "LAPB over Ethernet driver (EXPERIMENTAL)"
-	depends on WAN && LAPB && X25
+	depends on LAPB && X25
 	---help---
 	  Driver for a pseudo device (typically called /dev/lapb0) which allows
 	  you to open an LAPB point-to-point connection to some other computer
@@ -456,7 +453,7 @@ config LAPBETHER
 
 config X25_ASY
 	tristate "X.25 async driver (EXPERIMENTAL)"
-	depends on WAN && LAPB && X25
+	depends on LAPB && X25
 	---help---
 	  Send and receive X.25 frames over regular asynchronous serial
 	  lines such as telephone lines equipped with ordinary modems.
@@ -471,7 +468,7 @@ config X25_ASY
 
 config SBNI
 	tristate "Granch SBNI12 Leased Line adapter support"
-	depends on WAN && X86
+	depends on X86
 	---help---
 	  Driver for ISA SBNI12-xx cards which are low cost alternatives to
 	  leased line modems.
@@ -497,5 +494,4 @@ config SBNI_MULTILINE
 
 	  If unsure, say N.
 
-endmenu
-
+endif # WAN
diff --git a/drivers/net/wireless/libertas/Makefile b/drivers/net/wireless/libertas/Makefile
index 19c9350..56a8ea1 100644
--- a/drivers/net/wireless/libertas/Makefile
+++ b/drivers/net/wireless/libertas/Makefile
@@ -1,5 +1,3 @@
-# EXTRA_CFLAGS += -Wpacked
-
 usb8xxx-objs := main.o fw.o wext.o \
 		rx.o tx.o cmd.o 	  \
 		cmdresp.o scan.o	  \
@@ -7,13 +5,6 @@ usb8xxx-objs := main.o fw.o wext.o \
 		ioctl.o debugfs.o	  \
 		ethtool.o assoc.o
 
-ifeq ($(CONFIG_LIBERTAS_USB_DEBUG), y)
-EXTRA_CFLAGS += -DDEBUG -DPROC_DEBUG
-endif
-
-
-# This is needed to support the newer boot2 bootloader (v >= 3104)
-EXTRA_CFLAGS += -DSUPPORT_BOOT_COMMAND
 usb8xxx-objs += if_bootcmd.o
 usb8xxx-objs += if_usb.o
 
diff --git a/drivers/net/wireless/libertas/README b/drivers/net/wireless/libertas/README
index 688da4c..3785772 100644
--- a/drivers/net/wireless/libertas/README
+++ b/drivers/net/wireless/libertas/README
@@ -40,64 +40,11 @@ NAME
 SYNOPSIS
 	iwpriv <ethX> <command> [sub-command] ...
 
-	iwpriv ethX version
-	iwpriv ethX scantype [sub-command]
-	iwpriv ethX getSNR <n>
-	iwpriv ethX getNF <n>
-	iwpriv ethX getRSSI <n>
-	iwpriv ethX setrxant <n>
-	iwpriv ethX getrxant
-	iwpriv ethX settxant <n>
-	iwpriv ethX gettxant
-	iwpriv ethX authalgs <n>
-	iwpriv ethX pre-TBTT <n>
-	iwpriv ethX 8021xauthalgs <n>
-	iwpriv ethX encryptionmode <n>
 	iwpriv ethX setregioncode <n>
 	iwpriv ethX getregioncode
-	iwpriv ethX setbcnavg <n>
-	iwpriv ethX getbcnavg
-	iwpriv ethX setdataavg <n>
-	iwpriv ethX setlisteninter <n>
-	iwpriv ethX getlisteninter
-	iwpriv ethX setmultipledtim <n>
-	iwpriv ethX getmultipledtim
-	iwpriv ethX atimwindow <n>
-	iwpriv ethX deauth
-	iwpriv ethX adhocstop
-	iwpriv ethX radioon
-	iwpriv ethX radiooff
-	iwpriv ethX reasso-on
-	iwpriv ethX reasso-off
-	iwpriv ethX scanmode  [sub-command]
-	iwpriv ethX setwpaie <n>
-	iwpriv ethX wlanidle-off
-	iwpriv ethX wlanidle-on
-	iwpriv ethX getcis
-	iwpriv ethX getlog
-	iwpriv ethX getadhocstatus
-	iwpriv ethX adhocgrate <n>
-
-Version 4 Command:
-	iwpriv ethX inactvityto <n>
-	iwpriv ethX sleeppd <n>
-	iwpriv ethX enable11d <n>
-	iwpriv ethX tpccfg <n>
-	iwpriv ethX powercfg <n>
-	iwpriv ethX setafc <n>
-	iwpriv ethX getafc
 
 Version 5 Command:
 	iwpriv ethX ledgpio <n>
-	iwpriv ethX scanprobes <n>
-	iwpriv ethX lolisteninter <n>
-	iwpriv ethX rateadapt <n> <m>
-	iwpriv ethX txcontrol <n>
-	iwpriv ethX psnullinterval <n>
-	iwpriv ethX prescan <n>
-	iwpriv ethX getrxinfo
-	iwpriv ethX gettxrate
-	iwpriv ethX beaconinterval
 
 BT Commands:
 	The blinding table (BT) contains a list of mac addresses that should be
@@ -150,114 +97,6 @@ DESCRIPTION
 	The ethX parameter specifies the network device that is to be used to
 		perform this command on. it could be eth0, eth1 etc.
 
-version
-	This is used to get the current version of the driver and the firmware.
-
-scantype
-	This command is used to set the scan type to be used by the driver in
-	the scan command. This setting will not be used while performing a scan
-	for a specific SSID, as it is always done with scan type being active.
-
-	where the sub-commands are: -
-			active 	-- to set the scan type to active
-			passive -- to set the scan type to passive
-			get 	-- to get the scan type set in the driver
-
-getSNR
-	This command gets the average and non average value of Signal to Noise
-	Ratio of Beacon and Data.
-
-	where value is:-
-			0 	-- Beacon non-average.
-			1 	-- Beacon average.
-			2 	-- Data non-average.
-			3 	-- Data average.
-
-	If no value is given, all four values are returned in the order mentioned
-	above.
-
-	Note: This command is available only when STA is connected.
-
-getRSSI
-	This command gets the average and non average value os Receive Signal
-	Strength of Beacon and Data.
-
-	where value is:-
-			0 	-- Beacon non-average.
-			1 	-- Beacon average.
-			2 	-- Data non-average.
-			3 	-- Data average.
-
-	Note: This command is available only when STA is connected.
-
-getNF
-	This command gets the average and non average value of Noise Floor of
-	Beacon and Data.
-
-	where value is:-
-			0 	-- Beacon non-average.
-			1 	-- Beacon average.
-			2 	-- Data non-average.
-			3 	-- Data average.
-
-	Note: This command is available only when STA is connected.
-
-setrxant
-	This command is used to set the mode for Rx antenna.
-
-	The options that can be sent are:-
-			1 	-- Antenna 1.
-			2 	-- Antenna 2.
-			0xFFFF 	-- Diversity.
-
-	Usage:
-		iwpriv ethX setrxant 0x01: select Antenna 1.
-
-getrxant
-	This command is used to get the mode for Rx antenna.
-
-
-settxant
-	This command is used to set the mode for Tx antenna.
-		The options that can be sent are:-
-			1 	-- Antenna 1.
-			2 	-- Antenna 2.
-			0xFFFF 	-- Diversity.
-	Usage:
-		iwpriv ethX settxant 0x01: select Antenna 1.
-
-gettxant
-	This command is used to get the mode for Tx antenna.
-
-authalgs
-	This command is used by the WPA supplicant to set the authentication
-	algorithms in the station.
-
-8021xauthalgs
-	This command is used by the WPA supplicant to set the 8021.x authentication algorithm type
-	station.
-
-	where values can be:-
-			1 	-- None
-			2 	-- LEAP
-			4 	-- TLS
-			8 	-- TTLs
-			16	-- MD5
-
-
-encryptionmode
-	This command is used by the WPA supplicant to set the encryption algorithm.
-
-	where values can be:-
-			0 	-- NONE
-			1 	-- WEP40
-			2 	-- TKIP
-			3 	-- CCMP
-			4 	-- WEP104
-
-pre-TBTT
-	This command is used to set pre-TBTT time period where value is in microseconds.
-
 setregioncode
 	This command is used to set the region code in the station.
 	where value is 'region code' for various regions like
@@ -270,114 +109,6 @@ getregioncode
 	This command is used to get the region code information set in the
 	station.
 
-setbcnavg
-	Set the weighting factor for calculating RSSI.
-
-getbcnavg
-	Get weighting factor for calculating RSSI.
-
-setdataavg
-	Set the weighting factor for calculating SNR.
-
-setlisteninter
-	This command is used to set the listen interval in the
-	station.
-
-	where the value ranges between 1 - 255
-
-getlisteninter
-	This command is used to get the listen interval value set in the
-	station.
-
-setmultipledtim
-	This command is used to set the multiple dtim value in the
-	station.
-		where the value is 1,2,3,4,5,0xfffe
-		0xfffe means the firmware will use listen interval in association
-		command for waking up
-
-getmultipledtim
-	This command is used to get the multiple dtim value set in the station.
-
-atimwindow
-	This command is used to set the atim value in the
-	station.
-
-	where the value ranges between 0 - 50
-
-deauth
-	This command is used to send the de-authentication to the AP with which
-	the station is associated. This command is valid only when
-	station is in Infrastructure mode.
-
-	Note: This command is available only when STA is connected.
-
-adhocstop
-	This command is used to stop beacon transmission from the station and
-	go into idle state in ad-hoc mode.
-
-	Note: This command is available only when STA is connected.
-
-radioon
-	This command is used to turn on the RF antenna.
-
-radiooff
-	This command is sued to turn off the RF antenna.
-
-scanmode
-	This command is used to set the station to scan for either IBSS
-	networks or BSS networks or both BSS and IBSS networks. This
-	command can be used with sub commands,
-
-	where the value for
-			bss 	-- Scan All the BSS networks.
-			ibss 	-- Scan All the IBSS networks.
-			any 	-- Scan both BSS and IBSS networks.
-
-
-
-setwpaie
-	This command is used by WPA supplicant to send the WPA-IE to the driver.
-
-wlanidle-off
-	This command is used to get into idle state.
-
-	Note: This command is available only when STA is connected.
-
-wlanidle-on
-	This command is used to get off the idle state.
-
-	Note: This command is available only when STA is connected.
-
-
-getlog
-	This command is used to get the 802.11 statistics available in the
-		station.
-
-	Note: This command is available only when STA is connected.
-
-getadhocstatus
-	This command is used to get the ad-hoc Network Status.
-
-	The various status codes are:
-		AdhocStarted
-		AdhocJoined
-		AdhocIdle
-		InfraMode
-		AutoUnknownMode
-
-	Note: This command is available only when STA is connected.
-
-adhocgrate
-	This command is used to enable(1) g_rate, Disable(0) g_rate
-	and request(2) the status which g_rate is disabled/enabled,
-	for Ad-hoc creator.
-
-	where value is:-
-		0	-- Disabled
-		1	-- Enabled
-		2	-- Get
-
 ledgpio
 	This command is used to set/get LEDs.
 
@@ -400,253 +131,6 @@ ledgpio
 	Note: LED0 is invalid
 	Note: Maximum Number of LEDs are 16.
 
-inactivityto
-	This command is used by the host to set/get the inactivity timeout value,
-	which specifies when WLAN device is put to sleep.
-
-	Usage:
-		iwpriv ethX inactivityto [<timeout>]
-
-	where the parameter are:
-		timeout: timeout value in milliseconds.
-
-	Example:
-		iwpriv eth1 inactivityto
-			"get the timeout value"
-
-		iwpriv eth1 inactivityto X
-			"set timeout value to X ms"
-
-
-sleeppd
-	This command is used to configure the sleep period of the WLAN device.
-
-	Usage:
-		iwpriv ethX sleeppd [<sleep period>]
-
-	where the parameter are:
-		Period: sleep period in milliseconds. Range 10~60.
-
-	Example:
-		iwpriv eth1 sleeppd 10
-			"set period as 10 ms"
-		iwpriv eth1 sleeppd
-			"get the sleep period configuration"
-
-enable11d
-	This command is used to control 11d
-	where value is:-
-		1	-- Enabled
-		0	-- Disabled
-		2	-- Get
-
-
-
-
-tpccfg
-	Enables or disables automatic transmit power control.
-
-	The first parameter turns this feature on (1) or off (0).  When turning
-	on, the user must also supply four more parameters in the following
-	order:
-		-UseSNR (Use SNR (in addition to PER) for TPC algorithm),
-		-P0 (P0 power level for TPC),
-		-P1 (P1 power level for TPC),
-		-P2 (P2 power level for TPC).
-
-	Usage:
-		iwpriv ethX tpccfg: Get current configuration
-		iwpriv ethX tpccfg 0: disable auto TPC
-		iwpriv ethX tpccfg 0x01 0x00 0x05 0x0a 0x0d: enable auto TPC; do not use SNR;
-							     P0=0x05; P1=0x0a; P2=0x0d;
-		iwpriv ethX tpccfg 0x01 0x01 0x05 0x0a 0x0d: enable auto TPC; use SNR;
-							     P0=0x05; P1=0x0a; P2=0x0d.
-
-powercfg
-	Enables or disables power adaptation.
-
-	The first parameter turns this feature on (1) or off (0).  When turning
-	on, the user must also supply three more parameters in the following
-	order:
-		-P0 (P0 power level for Power Adaptation),
-		-P1 (P1 power level for Power Adaptation),
-		-P2 (P2 power level for Power Adaptation).
-
-	Usage:
-		iwpriv ethX powercfg: Get current configuration
-		iwpriv ethX powercfg 0: disable power adaptation
-		iwpriv ethX powercfg 1 0x0d 0x0f 0x12: enable power adaptation;
-						       P0=0x0d; P1=0x0f; P2=0x12.
-
-getafc
-	This command returns automatic frequency control parameters.  It returns
-	three integers:
-		-P0: automatic is on (1), or off (0),
-		-P1: current timing offset in PPM (part per million), and
-		-P2: current frequency offset in PPM.
-
-setafc
-	Set automatic frequency control options.
-
-	The first parameter turns automatic on (1) or off (0).
-	The user must supply two more parameters in either case, in the following
-  order:
-
-  When auto is on:
-
-		-P0 (automatic adjustment frequency threshold in PPM),
-		-P1 (automatic adjustment period in beacon period),
-
-  When auto is off:
-
-		-P0 (manual adjustment timing offset in PPM), and
-		-P1 (manual adjustment frequency offset in PPM).
-
-	Usage:
-		iwpriv ethX setafc 0 10 10: manual adjustment, both timing and frequcncy
-    offset are 10 PPM.
-
-		iwpriv ethX setafc 1 10 10 enable afc, automatic adjustment,
-    frequency threshold 10 PPM, for every 10 beacon periods.
-
-
-
-scanprobes
-	This command sets number of probe requests per channel.
-
-	Usage:
-		iwpriv ethX scanprobes 3 (set scan probes to 3)
-		iwpriv ethX scanprobes   (get scan probes)
-
-lolisteninter
-	This command sets the value of listen interval.
-
-	Usage:
-	iwpriv ethX lolisteninter 234 (set the lolisteninter to 234)
-	iwpriv ethX lolisteninter     (get the lolisteninter value)
-
-rateadapt
-	This command sets the data rates bitmap.
-	Where <n>
-		0: Disable auto rate adapt
-		1: Enable auto rate adapt
-
-	      <m>
-		 data rate bitmap
-			Bit	Data rate
-			0	1 Mbps
-			1	2 Mbps
-			2	5.5 Mbps
-			3	11 Mbps
-			4	Reserved
-			5	6 Mbps
-			6	9 Mbps
-			7	12 Mbps
-			8	18 Mbps
-			9	24 Mbps
-			10	36 Mbps
-			11	48 Mbps
-			12	54 Mbps
-			12-15	Reserved
-
-	Usage:
-	iwpriv ethX rateadapt
-			read the currect data rate setting
-	iwpriv ethX rateadapt 1 0x07
-			enable auto data rate adapt and
-			data rates are 1Mbps, 2Mbsp and 5.5Mbps
-
-
-txcontrol
-	This command is used to set the Tx rate, ack policy, and retry limit on a per packet basis.
-
-	Where value <n> is:
-	    if bit[4] == 1:
-		bit[3:0]        -- 0   1   2   3   4   5   6   7   8   9   10   11   12   13-16
-		Data Rate(Mbps) -- 1   2   5.5 11  Rsv 6   9   12  18  24  36   48   54   Rsv
-
-	    bit[12:8]
-		if bit[12] == 1, bit[11:8] specifies the Tx retry limit.
-
-	    bit[14:13] specifies per packet ack policy:
-		bit[14:13]
-		     1  0	use immediate ack policy for this packet
-		     1  1       use no ack policy for this packet
-		     0  x	use the per-packet ack policy setting
-
-	Usage:
-	iwpriv ethX txcontrol 0x7513
-			Use no-ack policy, 5 retires for Tx, 11Mbps rate
-
-
-
-psnullinterval
-	This command is used to set/request NULL package interval for Power Save
-	under infrastructure mode.
-
-	where value is:-
-		-1	-- Disabled
-		n>0	-- Set interval as n (seconds)
-
-prescan
-	This command is used to enable (1)/disable(0) auto prescan before assoicate to the ap
-
-	where value is:-
-		0	-- Disabled
-		1	-- Enabled
-		2       -- Get
-
-getrxinfo
-	This command gets non average value of Signal to Noise Ratio of Data and rate index.
-
-	The following table shows RateIndex and Rate
-
-		     RateIndex	Data rate
-			0	1 Mbps
-			1	2 Mbps
-			2	5.5 Mbps
-			3	11 Mbps
-			4	Reserved
-			5	6 Mbps
-			6	9 Mbps
-			7	12 Mbps
-			8	18 Mbps
-			9	24 Mbps
-			10	36 Mbps
-			11	48 Mbps
-			12	54 Mbps
-			13-15	Reserved
-
-gettxrate
-	This command gets current Tx rate index of the first packet associated with Rate Adaptation.
-
-	The following table shows RateIndex and Rate
-
-		     RateIndex	Data rate
-			0	1 Mbps
-			1	2 Mbps
-			2	5.5 Mbps
-			3	11 Mbps
-			4	Reserved
-			5	6 Mbps
-			6	9 Mbps
-			7	12 Mbps
-			8	18 Mbps
-			9	24 Mbps
-			10	36 Mbps
-			11	48 Mbps
-			12	54 Mbps
-			13-15	Reserved
-
-bcninterval
-	This command is used to sets beacon interval in adhoc mode when an argument is given, and gets current adhoc
-	beacon interval when no argument is given. The valid beacon interval is between 20 - 1000,
-	default beacon interval is 100.
-
-	Usage:
-		iwpriv ethX bcninterval 100  (set adhoc beacon interval to 100)
-		iwpriv ethX bcninterval      (get adhoc beacon interval)
-
 fwt_add
 	This command is used to insert an entry into the FWT table. The list of
 	parameters must follow the following structure:
diff --git a/drivers/net/wireless/libertas/assoc.c b/drivers/net/wireless/libertas/assoc.c
index b55c7f5..c260bd1 100644
--- a/drivers/net/wireless/libertas/assoc.c
+++ b/drivers/net/wireless/libertas/assoc.c
@@ -23,13 +23,13 @@ static int assoc_helper_essid(wlan_private *priv,
 	ENTER();
 
 	lbs_pr_debug(1, "New SSID requested: %s\n", assoc_req->ssid.ssid);
-	if (assoc_req->mode == wlan802_11infrastructure) {
+	if (assoc_req->mode == IW_MODE_INFRA) {
 		if (adapter->prescan) {
 			libertas_send_specific_SSID_scan(priv, &assoc_req->ssid, 1);
 		}
 
 		i = libertas_find_SSID_in_list(adapter, &assoc_req->ssid,
-				NULL, wlan802_11infrastructure);
+				NULL, IW_MODE_INFRA);
 		if (i >= 0) {
 			lbs_pr_debug(1,
 			       "SSID found in scan list ... associating...\n");
@@ -44,7 +44,7 @@ static int assoc_helper_essid(wlan_private *priv,
 			lbs_pr_debug(1, "SSID '%s' not found; cannot associate\n",
 				assoc_req->ssid.ssid);
 		}
-	} else if (assoc_req->mode == wlan802_11ibss) {
+	} else if (assoc_req->mode == IW_MODE_ADHOC) {
 		/* Scan for the network, do not save previous results.  Stale
 		 *   scan data will cause us to join a non-existant adhoc network
 		 */
@@ -52,7 +52,7 @@ static int assoc_helper_essid(wlan_private *priv,
 
 		/* Search for the requested SSID in the scan table */
 		i = libertas_find_SSID_in_list(adapter, &assoc_req->ssid, NULL,
-				wlan802_11ibss);
+				IW_MODE_ADHOC);
 		if (i >= 0) {
 			lbs_pr_debug(1, "SSID found at %d in List, so join\n", ret);
 			libertas_join_adhoc_network(priv, &adapter->scantable[i]);
@@ -90,10 +90,10 @@ static int assoc_helper_bssid(wlan_private *priv,
 		goto out;
 	}
 
-	if (assoc_req->mode == wlan802_11infrastructure) {
+	if (assoc_req->mode == IW_MODE_INFRA) {
 		ret = wlan_associate(priv, &adapter->scantable[i]);
 		lbs_pr_debug(1, "ASSOC: return from wlan_associate(bssd) was %d\n", ret);
-	} else if (assoc_req->mode == wlan802_11ibss) {
+	} else if (assoc_req->mode == IW_MODE_ADHOC) {
 		libertas_join_adhoc_network(priv, &adapter->scantable[i]);
 	}
 	memcpy(&assoc_req->ssid, &adapter->scantable[i].ssid,
@@ -142,23 +142,23 @@ static int assoc_helper_mode(wlan_private *priv,
 
 	ENTER();
 
-	if (assoc_req->mode == adapter->inframode) {
+	if (assoc_req->mode == adapter->mode) {
 		LEAVE();
 		return 0;
 	}
 
-	if (assoc_req->mode == wlan802_11infrastructure) {
+	if (assoc_req->mode == IW_MODE_INFRA) {
 		if (adapter->psstate != PS_STATE_FULL_POWER)
 			libertas_ps_wakeup(priv, cmd_option_waitforrsp);
 		adapter->psmode = wlan802_11powermodecam;
 	}
 
-	adapter->inframode = assoc_req->mode;
+	adapter->mode = assoc_req->mode;
 	ret = libertas_prepare_and_send_command(priv,
 				    cmd_802_11_snmp_mib,
 				    0, cmd_option_waitforrsp,
 				    OID_802_11_INFRASTRUCTURE_MODE,
-				    (void *) assoc_req->mode);
+				    (void *) (size_t) assoc_req->mode);
 
 	LEAVE();
 	return ret;
@@ -196,7 +196,7 @@ static int assoc_helper_wep_keys(wlan_private *priv,
 		goto out;
 
 	/* enable/disable the MAC's WEP packet filter */
-	if (assoc_req->secinfo.WEPstatus == wlan802_11WEPenabled)
+	if (assoc_req->secinfo.wep_enabled)
 		adapter->currentpacketfilter |= cmd_act_mac_wep_enable;
 	else
 		adapter->currentpacketfilter &= ~cmd_act_mac_wep_enable;
@@ -300,8 +300,7 @@ static int should_deauth_infrastructure(wlan_adapter *adapter,
 	}
 
 	if (test_bit(ASSOC_FLAG_SECINFO, &assoc_req->flags)) {
-		if (adapter->secinfo.authmode !=
-		    assoc_req->secinfo.authmode) {
+		if (adapter->secinfo.auth_mode != assoc_req->secinfo.auth_mode) {
 			lbs_pr_debug(1, "Deauthenticating due to updated security "
 				"info in configuration request.\n");
 			return 1;
@@ -316,7 +315,7 @@ static int should_deauth_infrastructure(wlan_adapter *adapter,
 
 	/* FIXME: deal with 'auto' mode somehow */
 	if (test_bit(ASSOC_FLAG_MODE, &assoc_req->flags)) {
-		if (assoc_req->mode != wlan802_11infrastructure)
+		if (assoc_req->mode != IW_MODE_INFRA)
 			return 1;
 	}
 
@@ -333,12 +332,12 @@ static int should_stop_adhoc(wlan_adapter *adapter,
 	if (adapter->curbssparams.ssid.ssidlength != assoc_req->ssid.ssidlength)
 		return 1;
 	if (memcmp(adapter->curbssparams.ssid.ssid, assoc_req->ssid.ssid,
-			sizeof(struct WLAN_802_11_SSID)))
+			adapter->curbssparams.ssid.ssidlength))
 		return 1;
 
 	/* FIXME: deal with 'auto' mode somehow */
 	if (test_bit(ASSOC_FLAG_MODE, &assoc_req->flags)) {
-		if (assoc_req->mode != wlan802_11ibss)
+		if (assoc_req->mode != IW_MODE_ADHOC)
 			return 1;
 	}
 
@@ -382,7 +381,7 @@ void wlan_association_worker(struct work_struct *work)
 	}
 
 	if (find_any_ssid) {
-		enum WLAN_802_11_NETWORK_INFRASTRUCTURE new_mode;
+		u8 new_mode;
 
 		ret = libertas_find_best_network_SSID(priv, &assoc_req->ssid,
 				assoc_req->mode, &new_mode);
@@ -393,7 +392,7 @@ void wlan_association_worker(struct work_struct *work)
 		}
 
 		/* Ensure we switch to the mode of the AP */
-		if (assoc_req->mode == wlan802_11autounknown) {
+		if (assoc_req->mode == IW_MODE_AUTO) {
 			set_bit(ASSOC_FLAG_MODE, &assoc_req->flags);
 			assoc_req->mode = new_mode;
 		}
@@ -403,7 +402,7 @@ void wlan_association_worker(struct work_struct *work)
 	 * Check if the attributes being changing require deauthentication
 	 * from the currently associated infrastructure access point.
 	 */
-	if (adapter->inframode == wlan802_11infrastructure) {
+	if (adapter->mode == IW_MODE_INFRA) {
 		if (should_deauth_infrastructure(adapter, assoc_req)) {
 			ret = libertas_send_deauthentication(priv);
 			if (ret) {
@@ -412,7 +411,7 @@ void wlan_association_worker(struct work_struct *work)
 					ret);
 			}
 		}
-	} else if (adapter->inframode == wlan802_11ibss) {
+	} else if (adapter->mode == IW_MODE_ADHOC) {
 		if (should_stop_adhoc(adapter, assoc_req)) {
 			ret = libertas_stop_adhoc_network(priv);
 			if (ret) {
@@ -543,7 +542,7 @@ struct assoc_request * wlan_get_association_request(wlan_adapter *adapter)
 		assoc_req->channel = adapter->curbssparams.channel;
 
 	if (!test_bit(ASSOC_FLAG_MODE, &assoc_req->flags))
-		assoc_req->mode = adapter->inframode;
+		assoc_req->mode = adapter->mode;
 
 	if (!test_bit(ASSOC_FLAG_BSSID, &assoc_req->flags)) {
 		memcpy(&assoc_req->bssid, adapter->curbssparams.bssid,
diff --git a/drivers/net/wireless/libertas/cmd.c b/drivers/net/wireless/libertas/cmd.c
index bfdac58..de9cb46 100644
--- a/drivers/net/wireless/libertas/cmd.c
+++ b/drivers/net/wireless/libertas/cmd.c
@@ -381,15 +381,16 @@ static int wlan_cmd_802_11_snmp_mib(wlan_private * priv,
 	switch (cmd_oid) {
 	case OID_802_11_INFRASTRUCTURE_MODE:
 	{
-		enum WLAN_802_11_NETWORK_INFRASTRUCTURE mode =
-			(enum WLAN_802_11_NETWORK_INFRASTRUCTURE) pdata_buf;
+		u8 mode = (u8) (size_t) pdata_buf;
 		pSNMPMIB->querytype = cpu_to_le16(cmd_act_set);
 		pSNMPMIB->oid = cpu_to_le16((u16) desired_bsstype_i);
 		pSNMPMIB->bufsize = sizeof(u8);
-		if (mode == wlan802_11infrastructure)
-			ucTemp = SNMP_MIB_VALUE_INFRA;
-		else
+		if (mode == IW_MODE_ADHOC) {
 			ucTemp = SNMP_MIB_VALUE_ADHOC;
+		} else {
+			/* Infra and Auto modes */
+			ucTemp = SNMP_MIB_VALUE_INFRA;
+		}
 
 		memmove(pSNMPMIB->value, &ucTemp, sizeof(u8));
 
@@ -947,8 +948,8 @@ void libertas_queue_cmd(wlan_adapter * adapter, struct cmd_ctrl_node *cmdnode, u
 
 	spin_unlock_irqrestore(&adapter->driver_lock, flags);
 
-	lbs_pr_debug(1, "QUEUE_CMD: Inserted node=0x%x, cmd=0x%x in cmdpendingq\n",
-	       (u32) cmdnode,
+	lbs_pr_debug(1, "QUEUE_CMD: Inserted node=%p, cmd=0x%x in cmdpendingq\n",
+	       cmdnode,
 	       ((struct cmd_ds_gen*)cmdnode->bufvirtualaddr)->command);
 
 done:
@@ -976,8 +977,8 @@ static int DownloadcommandToStation(wlan_private * priv,
 	ENTER();
 
 	if (!adapter || !cmdnode) {
-		lbs_pr_debug(1, "DNLD_CMD: adapter = %#x, cmdnode = %#x\n",
-		       (int)adapter, (int)cmdnode);
+		lbs_pr_debug(1, "DNLD_CMD: adapter = %p, cmdnode = %p\n",
+		       adapter, cmdnode);
 		if (cmdnode) {
 			spin_lock_irqsave(&adapter->driver_lock, flags);
 			__libertas_cleanup_and_insert_cmd(priv, cmdnode);
@@ -1174,8 +1175,8 @@ int libertas_prepare_and_send_command(wlan_private * priv,
 
 	cmdptr = (struct cmd_ds_command *)cmdnode->bufvirtualaddr;
 
-	lbs_pr_debug(1, "PREP_CMD: Val of cmd ptr =0x%x, command=0x%X\n",
-	       (u32) cmdptr, cmd_no);
+	lbs_pr_debug(1, "PREP_CMD: Val of cmd ptr=%p, command=0x%X\n",
+	       cmdptr, cmd_no);
 
 	if (!cmdptr) {
 		lbs_pr_debug(1, "PREP_CMD: bufvirtualaddr of cmdnode is NULL\n");
diff --git a/drivers/net/wireless/libertas/cmdresp.c b/drivers/net/wireless/libertas/cmdresp.c
index cdb012c..c864540 100644
--- a/drivers/net/wireless/libertas/cmdresp.c
+++ b/drivers/net/wireless/libertas/cmdresp.c
@@ -72,8 +72,6 @@ void libertas_mac_event_disconnected(wlan_private * priv)
 	adapter->secinfo.WPAenabled = 0;
 	adapter->secinfo.WPA2enabled = 0;
 	adapter->wpa_ie_len = 0;
-	adapter->secinfo.auth1xalg = WLAN_1X_AUTH_ALG_NONE;
-	adapter->secinfo.Encryptionmode = CIPHER_NONE;
 
 	adapter->connect_status = libertas_disconnected;
 
@@ -811,7 +809,7 @@ int libertas_process_rx_command(wlan_private * priv)
 		if (result) {
 			lbs_pr_debug(1, "CMD_RESP: PS command failed- %#x \n",
 			       resp->result);
-			if (adapter->inframode == wlan802_11ibss) {
+			if (adapter->mode == IW_MODE_ADHOC) {
 				/*
 				 * We should not re-try enter-ps command in
 				 * ad-hoc mode. It takes place in
diff --git a/drivers/net/wireless/libertas/debugfs.c b/drivers/net/wireless/libertas/debugfs.c
index 51dfd20..7d7bc5e 100644
--- a/drivers/net/wireless/libertas/debugfs.c
+++ b/drivers/net/wireless/libertas/debugfs.c
@@ -7,6 +7,7 @@
 #include "dev.h"
 #include "decl.h"
 #include "host.h"
+#include "debugfs.h"
 
 static struct dentry *libertas_dir = NULL;
 static char *szStates[] = {
@@ -276,7 +277,7 @@ static void libertas_parse_ssid(char *buf, size_t count,
 	if (!end)
 		end = buf + count - 1;
 
-	size = min(IW_ESSID_MAX_SIZE, end - hold);
+	size = min((size_t)IW_ESSID_MAX_SIZE, (size_t) (end - hold));
 	strncpy(scan_cfg->specificSSID, hold, size);
 
 	return;
@@ -1648,7 +1649,7 @@ struct libertas_debugfs_files {
 	struct file_operations fops;
 };
 
-struct libertas_debugfs_files debugfs_files[] = {
+static struct libertas_debugfs_files debugfs_files[] = {
 	{ "info", 0444, FOPS(libertas_dev_info, write_file_dummy), },
 	{ "getscantable", 0444, FOPS(libertas_getscantable,
 					write_file_dummy), },
@@ -1658,7 +1659,7 @@ struct libertas_debugfs_files debugfs_files[] = {
 	{ "setuserscan", 0600, FOPS(NULL, libertas_setuserscan), },
 };
 
-struct libertas_debugfs_files debugfs_events_files[] = {
+static struct libertas_debugfs_files debugfs_events_files[] = {
 	{"low_rssi", 0644, FOPS(libertas_lowrssi_read,
 				libertas_lowrssi_write), },
 	{"low_snr", 0644, FOPS(libertas_lowsnr_read,
@@ -1673,7 +1674,7 @@ struct libertas_debugfs_files debugfs_events_files[] = {
 				libertas_highsnr_write), },
 };
 
-struct libertas_debugfs_files debugfs_regs_files[] = {
+static struct libertas_debugfs_files debugfs_regs_files[] = {
 	{"rdmac", 0644, FOPS(libertas_rdmac_read, libertas_rdmac_write), },
 	{"wrmac", 0600, FOPS(NULL, libertas_wrmac_write), },
 	{"rdbbp", 0644, FOPS(libertas_rdbbp_read, libertas_rdbbp_write), },
@@ -1778,7 +1779,7 @@ void libertas_debugfs_remove_one(wlan_private *priv)
 struct debug_data {
 	char name[32];
 	u32 size;
-	u32 addr;
+	size_t addr;
 };
 
 /* To debug any member of wlan_adapter, simply add one line here.
@@ -1825,6 +1826,8 @@ static ssize_t wlan_debugfs_read(struct file *file, char __user *userbuf,
 			val = *((u16 *) d[i].addr);
 		else if (d[i].size == 4)
 			val = *((u32 *) d[i].addr);
+		else if (d[i].size == 8)
+			val = *((u64 *) d[i].addr);
 
 		pos += sprintf(p + pos, "%s=%d\n", d[i].name, val);
 	}
@@ -1844,7 +1847,7 @@ static ssize_t wlan_debugfs_read(struct file *file, char __user *userbuf,
  *  @param data    data to write
  *  @return 	   number of data
  */
-static int wlan_debugfs_write(struct file *f, const char __user *buf,
+static ssize_t wlan_debugfs_write(struct file *f, const char __user *buf,
 			    size_t cnt, loff_t *ppos)
 {
 	int r, i;
@@ -1886,12 +1889,14 @@ static int wlan_debugfs_write(struct file *f, const char __user *buf,
 				*((u16 *) d[i].addr) = (u16) r;
 			else if (d[i].size == 4)
 				*((u32 *) d[i].addr) = (u32) r;
+			else if (d[i].size == 8)
+				*((u64 *) d[i].addr) = (u64) r;
 			break;
 		} while (1);
 	}
 	kfree(pdata);
 
-	return cnt;
+	return (ssize_t)cnt;
 }
 
 static struct file_operations libertas_debug_fops = {
@@ -1916,20 +1921,10 @@ void libertas_debug_init(wlan_private * priv, struct net_device *dev)
 		return;
 
 	for (i = 0; i < num_of_items; i++)
-		items[i].addr += (u32) priv->adapter;
+		items[i].addr += (size_t) priv->adapter;
 
 	priv->debugfs_debug = debugfs_create_file("debug", 0644,
 						  priv->debugfs_dir, &items[0],
 						  &libertas_debug_fops);
 }
 
-/**
- *  @brief remove proc file
- *
- *  @param priv	   pointer wlan_private
- *  @return 	   N/A
- */
-void libertas_debug_remove(wlan_private * priv)
-{
-	debugfs_remove(priv->debugfs_debug);
-}
diff --git a/drivers/net/wireless/libertas/defs.h b/drivers/net/wireless/libertas/defs.h
index fb1478c..80dd9ea 100644
--- a/drivers/net/wireless/libertas/defs.h
+++ b/drivers/net/wireless/libertas/defs.h
@@ -9,6 +9,11 @@
 
 extern unsigned int libertas_debug;
 
+#ifdef CONFIG_LIBERTAS_DEBUG
+#define DEBUG
+#define PROC_DEBUG
+#endif
+
 #define DRV_NAME		"usb8xxx"
 
 #define lbs_pr_info(format, args...) \
@@ -223,31 +228,6 @@ enum SNRNF_DATA {
 	MAX_TYPE_AVG
 };
 
-/** WLAN_802_11_AUTH_ALG*/
-enum WLAN_802_11_AUTH_ALG {
-	AUTH_ALG_OPEN_SYSTEM = 1,
-	AUTH_ALG_SHARED_KEY = 2,
-	AUTH_ALG_NETWORK_EAP = 8,
-};
-
-/** WLAN_802_1X_AUTH_ALG */
-enum WLAN_802_1X_AUTH_ALG {
-	WLAN_1X_AUTH_ALG_NONE = 1,
-	WLAN_1X_AUTH_ALG_LEAP = 2,
-	WLAN_1X_AUTH_ALG_TLS = 4,
-	WLAN_1X_AUTH_ALG_TTLS = 8,
-	WLAN_1X_AUTH_ALG_MD5 = 16,
-};
-
-/** WLAN_802_11_ENCRYPTION_MODE */
-enum WLAN_802_11_ENCRYPTION_MODE {
-	CIPHER_NONE,
-	CIPHER_WEP40,
-	CIPHER_TKIP,
-	CIPHER_CCMP,
-	CIPHER_WEP104,
-};
-
 /** WLAN_802_11_POWER_MODE */
 enum WLAN_802_11_POWER_MODE {
 	wlan802_11powermodecam,
@@ -292,28 +272,6 @@ enum mv_ms_type {
 	MVMS_EVENT
 };
 
-/** WLAN_802_11_NETWORK_INFRASTRUCTURE */
-enum WLAN_802_11_NETWORK_INFRASTRUCTURE {
-	wlan802_11ibss,
-	wlan802_11infrastructure,
-	wlan802_11autounknown,
-	/*defined as upper bound */
-	wlan802_11infrastructuremax
-};
-
-/** WLAN_802_11_AUTHENTICATION_MODE */
-enum WLAN_802_11_AUTHENTICATION_MODE {
-	wlan802_11authmodeopen = 0x00,
-	wlan802_11authmodeshared = 0x01,
-	wlan802_11authmodenetworkEAP = 0x80,
-};
-
-/** WLAN_802_11_WEP_STATUS */
-enum WLAN_802_11_WEP_STATUS {
-	wlan802_11WEPenabled,
-	wlan802_11WEPdisabled,
-};
-
 /** SNMP_MIB_INDEX_e */
 enum SNMP_MIB_INDEX_e {
 	desired_bsstype_i = 0,
diff --git a/drivers/net/wireless/libertas/dev.h b/drivers/net/wireless/libertas/dev.h
index b1f876f..e8b9020 100644
--- a/drivers/net/wireless/libertas/dev.h
+++ b/drivers/net/wireless/libertas/dev.h
@@ -10,6 +10,7 @@
 #include <linux/wireless.h>
 #include <linux/ethtool.h>
 #include <linux/debugfs.h>
+#include <net/ieee80211.h>
 
 #include "defs.h"
 #include "scan.h"
@@ -56,10 +57,8 @@ struct region_channel {
 struct wlan_802_11_security {
 	u8 WPAenabled;
 	u8 WPA2enabled;
-	enum WLAN_802_11_WEP_STATUS WEPstatus;
-	enum WLAN_802_11_AUTHENTICATION_MODE authmode;
-	enum WLAN_802_1X_AUTH_ALG auth1xalg;
-	enum WLAN_802_11_ENCRYPTION_MODE Encryptionmode;
+	u8 wep_enabled;
+	u8 auth_mode;
 };
 
 /** Current Basic Service Set State Structure */
@@ -184,7 +183,7 @@ struct assoc_request {
 
 	struct WLAN_802_11_SSID ssid;
 	u8 channel;
-	enum WLAN_802_11_NETWORK_INFRASTRUCTURE mode;
+	u8 mode;
 	u8 bssid[ETH_ALEN];
 
 	/** WEP keys */
@@ -198,7 +197,6 @@ struct assoc_request {
 	struct wlan_802_11_security secinfo;
 
 	/** WPA Information Elements*/
-#define MAX_WPA_IE_LEN 64
 	u8 wpa_ie[MAX_WPA_IE_LEN];
 	u8 wpa_ie_len;
 };
@@ -254,7 +252,8 @@ struct _wlan_adapter {
 	/** current ssid/bssid related parameters*/
 	struct current_bss_params curbssparams;
 
-	enum WLAN_802_11_NETWORK_INFRASTRUCTURE inframode;
+	/* IW_MODE_* */
+	u8 mode;
 
 	struct bss_descriptor *pattemptedbssdesc;
 
@@ -339,7 +338,6 @@ struct _wlan_adapter {
 	struct WLAN_802_11_KEY wpa_unicast_key;
 
 	/** WPA Information Elements*/
-#define MAX_WPA_IE_LEN 64
 	u8 wpa_ie[MAX_WPA_IE_LEN];
 	u8 wpa_ie_len;
 
diff --git a/drivers/net/wireless/libertas/fw.c b/drivers/net/wireless/libertas/fw.c
index b194a45..441123c 100644
--- a/drivers/net/wireless/libertas/fw.c
+++ b/drivers/net/wireless/libertas/fw.c
@@ -194,16 +194,13 @@ static void wlan_init_adapter(wlan_private * priv)
 	adapter->scanmode = cmd_bss_type_any;
 
 	/* 802.11 specific */
-	adapter->secinfo.WEPstatus = wlan802_11WEPdisabled;
+	adapter->secinfo.wep_enabled = 0;
 	for (i = 0; i < sizeof(adapter->wep_keys) / sizeof(adapter->wep_keys[0]);
 	     i++)
 		memset(&adapter->wep_keys[i], 0, sizeof(struct WLAN_802_11_KEY));
 	adapter->wep_tx_keyidx = 0;
-	adapter->secinfo.WEPstatus = wlan802_11WEPdisabled;
-	adapter->secinfo.authmode = wlan802_11authmodeopen;
-	adapter->secinfo.auth1xalg = WLAN_1X_AUTH_ALG_NONE;
-	adapter->secinfo.Encryptionmode = CIPHER_NONE;
-	adapter->inframode = wlan802_11infrastructure;
+	adapter->secinfo.auth_mode = IW_AUTH_ALG_OPEN_SYSTEM;
+	adapter->mode = IW_MODE_INFRA;
 
 	adapter->assoc_req = NULL;
 
diff --git a/drivers/net/wireless/libertas/if_usb.c b/drivers/net/wireless/libertas/if_usb.c
index 695fb6a..ae6f72a 100644
--- a/drivers/net/wireless/libertas/if_usb.c
+++ b/drivers/net/wireless/libertas/if_usb.c
@@ -388,7 +388,7 @@ static int __if_usb_submit_rx_urb(wlan_private * priv,
 	usb_fill_bulk_urb(cardp->rx_urb, cardp->udev,
 			  usb_rcvbulkpipe(cardp->udev,
 					  cardp->bulk_in_endpointAddr),
-			  skb->tail + IPFIELD_ALIGN_OFFSET,
+			  (void *) (skb->tail + (size_t) IPFIELD_ALIGN_OFFSET),
 			  MRVDRV_ETH_RX_PACKET_BUFFER_SIZE, callbackfn,
 			  rinfo);
 
@@ -626,6 +626,7 @@ static void if_usb_receive(struct urb *urb)
 			    cardp->usb_event_cause);
 		if (cardp->usb_event_cause & 0xffff0000) {
 			libertas_send_tx_feedback(priv);
+			spin_unlock(&priv->adapter->driver_lock);
 			break;
 		}
 		cardp->usb_event_cause = le32_to_cpu(cardp->usb_event_cause) << 3;
@@ -775,7 +776,6 @@ restart:
 		return -1;
 	}
 
-#ifdef SUPPORT_BOOT_COMMAND
 	cardp->bootcmdresp = 0;
 	do {
 		int j = 0;
@@ -796,7 +796,6 @@ restart:
 		}
 		return -1;
 	}
-#endif
 
 	i = 0;
 	priv->adapter->fw_ready = 0;
diff --git a/drivers/net/wireless/libertas/if_usb.h b/drivers/net/wireless/libertas/if_usb.h
index 7851167..170dfe6 100644
--- a/drivers/net/wireless/libertas/if_usb.h
+++ b/drivers/net/wireless/libertas/if_usb.h
@@ -12,7 +12,6 @@
 #define USB8388_VID_2	0x05a3
 #define USB8388_PID_2	0x8388
 
-#ifdef SUPPORT_BOOT_COMMAND
 #define BOOT_CMD_FW_BY_USB     0x01
 #define BOOT_CMD_FW_IN_EEPROM  0x02
 #define BOOT_CMD_UPDATE_BOOT2  0x03
@@ -36,7 +35,6 @@ struct bootcmdrespStr
 	u8  u8result;
 	u8  au8dumy[2];
 };
-#endif /* SUPPORT_BOOT_COMMAND */
 
 /* read callback private data */
 struct read_cb_info {
diff --git a/drivers/net/wireless/libertas/ioctl.c b/drivers/net/wireless/libertas/ioctl.c
index 82b3964..a8f76c3 100644
--- a/drivers/net/wireless/libertas/ioctl.c
+++ b/drivers/net/wireless/libertas/ioctl.c
@@ -27,95 +27,6 @@
 
 #define WAIT_FOR_SCAN_RRESULT_MAX_TIME (10 * HZ)
 
-static int setrxantenna(wlan_private * priv, int mode)
-{
-	int ret = 0;
-	wlan_adapter *adapter = priv->adapter;
-
-	if (mode != RF_ANTENNA_1 && mode != RF_ANTENNA_2
-	    && mode != RF_ANTENNA_AUTO) {
-		return -EINVAL;
-	}
-
-	adapter->rxantennamode = mode;
-
-	lbs_pr_debug(1, "SET RX Antenna mode to 0x%04x\n", adapter->rxantennamode);
-
-	ret = libertas_prepare_and_send_command(priv, cmd_802_11_rf_antenna,
-				    cmd_act_set_rx,
-				    cmd_option_waitforrsp, 0,
-				    &adapter->rxantennamode);
-	return ret;
-}
-
-static int settxantenna(wlan_private * priv, int mode)
-{
-	int ret = 0;
-	wlan_adapter *adapter = priv->adapter;
-
-	if ((mode != RF_ANTENNA_1) && (mode != RF_ANTENNA_2)
-	    && (mode != RF_ANTENNA_AUTO)) {
-		return -EINVAL;
-	}
-
-	adapter->txantennamode = mode;
-
-	lbs_pr_debug(1, "SET TX Antenna mode to 0x%04x\n", adapter->txantennamode);
-
-	ret = libertas_prepare_and_send_command(priv, cmd_802_11_rf_antenna,
-				    cmd_act_set_tx,
-				    cmd_option_waitforrsp, 0,
-				    &adapter->txantennamode);
-
-	return ret;
-}
-
-static int getrxantenna(wlan_private * priv, char *buf)
-{
-	int ret = 0;
-	wlan_adapter *adapter = priv->adapter;
-
-	// clear it, so we will know if the value
-	// returned below is correct or not.
-	adapter->rxantennamode = 0;
-
-	ret = libertas_prepare_and_send_command(priv, cmd_802_11_rf_antenna,
-				    cmd_act_get_rx,
-				    cmd_option_waitforrsp, 0, NULL);
-
-	if (ret) {
-		LEAVE();
-		return ret;
-	}
-
-	lbs_pr_debug(1, "Get Rx Antenna mode:0x%04x\n", adapter->rxantennamode);
-
-	return sprintf(buf, "0x%04x", adapter->rxantennamode) + 1;
-}
-
-static int gettxantenna(wlan_private * priv, char *buf)
-{
-	int ret = 0;
-	wlan_adapter *adapter = priv->adapter;
-
-	// clear it, so we will know if the value
-	// returned below is correct or not.
-	adapter->txantennamode = 0;
-
-	ret = libertas_prepare_and_send_command(priv, cmd_802_11_rf_antenna,
-				    cmd_act_get_tx,
-				    cmd_option_waitforrsp, 0, NULL);
-
-	if (ret) {
-		LEAVE();
-		return ret;
-	}
-
-	lbs_pr_debug(1, "Get Tx Antenna mode:0x%04x\n", adapter->txantennamode);
-
-	return sprintf(buf, "0x%04x", adapter->txantennamode) + 1;
-}
-
 static int wlan_set_region(wlan_private * priv, u16 region_code)
 {
 	int i;
@@ -144,998 +55,6 @@ static int wlan_set_region(wlan_private * priv, u16 region_code)
 	return 0;
 }
 
-/**
- *  @brief Get/Set Firmware wakeup method
- *
- *  @param priv		A pointer to wlan_private structure
- *  @param wrq	   	A pointer to user data
- *  @return 	   	0--success, otherwise fail
- */
-static int wlan_txcontrol(wlan_private * priv, struct iwreq *wrq)
-{
-	wlan_adapter *adapter = priv->adapter;
-	int data;
-	ENTER();
-
-	if ((int)wrq->u.data.length == 0) {
-		if (copy_to_user
-		    (wrq->u.data.pointer, &adapter->pkttxctrl, sizeof(u32))) {
-			lbs_pr_alert("copy_to_user failed!\n");
-			return -EFAULT;
-		}
-	} else {
-		if ((int)wrq->u.data.length > 1) {
-			lbs_pr_alert("ioctl too many args!\n");
-			return -EFAULT;
-		}
-		if (copy_from_user(&data, wrq->u.data.pointer, sizeof(int))) {
-			lbs_pr_alert("Copy from user failed\n");
-			return -EFAULT;
-		}
-
-		adapter->pkttxctrl = (u32) data;
-	}
-
-	wrq->u.data.length = 1;
-
-	LEAVE();
-	return 0;
-}
-
-/**
- *  @brief Get/Set NULL Package generation interval
- *
- *  @param priv		A pointer to wlan_private structure
- *  @param wrq	   	A pointer to user data
- *  @return 	   	0--success, otherwise fail
- */
-static int wlan_null_pkt_interval(wlan_private * priv, struct iwreq *wrq)
-{
-	wlan_adapter *adapter = priv->adapter;
-	int data;
-	ENTER();
-
-	if ((int)wrq->u.data.length == 0) {
-		data = adapter->nullpktinterval;
-
-		if (copy_to_user(wrq->u.data.pointer, &data, sizeof(int))) {
-			lbs_pr_alert( "copy_to_user failed!\n");
-			return -EFAULT;
-		}
-	} else {
-		if ((int)wrq->u.data.length > 1) {
-			lbs_pr_alert( "ioctl too many args!\n");
-			return -EFAULT;
-		}
-		if (copy_from_user(&data, wrq->u.data.pointer, sizeof(int))) {
-			lbs_pr_debug(1, "Copy from user failed\n");
-			return -EFAULT;
-		}
-
-		adapter->nullpktinterval = data;
-	}
-
-	wrq->u.data.length = 1;
-
-	LEAVE();
-	return 0;
-}
-
-static int wlan_get_rxinfo(wlan_private * priv, struct iwreq *wrq)
-{
-	wlan_adapter *adapter = priv->adapter;
-	int data[2];
-	ENTER();
-	data[0] = adapter->SNR[TYPE_RXPD][TYPE_NOAVG];
-	data[1] = adapter->rxpd_rate;
-	if (copy_to_user(wrq->u.data.pointer, data, sizeof(int) * 2)) {
-		lbs_pr_debug(1, "Copy to user failed\n");
-		return -EFAULT;
-	}
-	wrq->u.data.length = 2;
-	LEAVE();
-	return 0;
-}
-
-static int wlan_get_snr(wlan_private * priv, struct iwreq *wrq)
-{
-	int ret = 0;
-	wlan_adapter *adapter = priv->adapter;
-	int data[4];
-
-	ENTER();
-	memset(data, 0, sizeof(data));
-	if (wrq->u.data.length) {
-		if (copy_from_user(data, wrq->u.data.pointer,
-		     min_t(size_t, wrq->u.data.length, 4) * sizeof(int)))
-			return -EFAULT;
-	}
-	if ((wrq->u.data.length == 0) || (data[0] == 0) || (data[0] == 1)) {
-		if (adapter->connect_status == libertas_connected) {
-			ret = libertas_prepare_and_send_command(priv,
-						    cmd_802_11_rssi,
-						    0,
-						    cmd_option_waitforrsp,
-						    0, NULL);
-
-			if (ret) {
-				LEAVE();
-				return ret;
-			}
-		}
-	}
-
-	if (wrq->u.data.length == 0) {
-		data[0] = adapter->SNR[TYPE_BEACON][TYPE_NOAVG];
-		data[1] = adapter->SNR[TYPE_BEACON][TYPE_AVG];
-		data[2] = adapter->SNR[TYPE_RXPD][TYPE_NOAVG];
-		data[3] = adapter->SNR[TYPE_RXPD][TYPE_AVG] / AVG_SCALE;
-		if (copy_to_user(wrq->u.data.pointer, data, sizeof(int) * 4))
-			return -EFAULT;
-		wrq->u.data.length = 4;
-	} else if (data[0] == 0) {
-		data[0] = adapter->SNR[TYPE_BEACON][TYPE_NOAVG];
-		if (copy_to_user(wrq->u.data.pointer, data, sizeof(int)))
-			return -EFAULT;
-		wrq->u.data.length = 1;
-	} else if (data[0] == 1) {
-		data[0] = adapter->SNR[TYPE_BEACON][TYPE_AVG];
-		if (copy_to_user(wrq->u.data.pointer, data, sizeof(int)))
-			return -EFAULT;
-		wrq->u.data.length = 1;
-	} else if (data[0] == 2) {
-		data[0] = adapter->SNR[TYPE_RXPD][TYPE_NOAVG];
-		if (copy_to_user(wrq->u.data.pointer, data, sizeof(int)))
-			return -EFAULT;
-		wrq->u.data.length = 1;
-	} else if (data[0] == 3) {
-		data[0] = adapter->SNR[TYPE_RXPD][TYPE_AVG] / AVG_SCALE;
-		if (copy_to_user(wrq->u.data.pointer, data, sizeof(int)))
-			return -EFAULT;
-		wrq->u.data.length = 1;
-	} else
-		return -ENOTSUPP;
-
-	LEAVE();
-	return 0;
-}
-
-static int wlan_beacon_interval(wlan_private * priv, struct iwreq *wrq)
-{
-	int data;
-	wlan_adapter *adapter = priv->adapter;
-
-	if (wrq->u.data.length > 0) {
-		if (copy_from_user(&data, wrq->u.data.pointer, sizeof(int)))
-			return -EFAULT;
-
-		lbs_pr_debug(1, "WLAN SET BEACON INTERVAL: %d\n", data);
-		if ((data > MRVDRV_MAX_BEACON_INTERVAL)
-		    || (data < MRVDRV_MIN_BEACON_INTERVAL))
-			return -ENOTSUPP;
-		adapter->beaconperiod = data;
-	}
-	data = adapter->beaconperiod;
-	if (copy_to_user(wrq->u.data.pointer, &data, sizeof(int)))
-		return -EFAULT;
-
-	wrq->u.data.length = 1;
-
-	return 0;
-}
-
-static int wlan_get_rssi(wlan_private * priv, struct iwreq *wrq)
-{
-	int ret = 0;
-	wlan_adapter *adapter = priv->adapter;
-	int temp;
-	int data = 0;
-	int *val;
-
-	ENTER();
-	data = SUBCMD_DATA(wrq);
-	if ((data == 0) || (data == 1)) {
-		ret = libertas_prepare_and_send_command(priv,
-					    cmd_802_11_rssi,
-					    0, cmd_option_waitforrsp,
-					    0, NULL);
-		if (ret) {
-			LEAVE();
-			return ret;
-		}
-	}
-
-	switch (data) {
-	case 0:
-
-		temp = CAL_RSSI(adapter->SNR[TYPE_BEACON][TYPE_NOAVG],
-				adapter->NF[TYPE_BEACON][TYPE_NOAVG]);
-		break;
-	case 1:
-		temp = CAL_RSSI(adapter->SNR[TYPE_BEACON][TYPE_AVG],
-				adapter->NF[TYPE_BEACON][TYPE_AVG]);
-		break;
-	case 2:
-		temp = CAL_RSSI(adapter->SNR[TYPE_RXPD][TYPE_NOAVG],
-				adapter->NF[TYPE_RXPD][TYPE_NOAVG]);
-		break;
-	case 3:
-		temp = CAL_RSSI(adapter->SNR[TYPE_RXPD][TYPE_AVG] / AVG_SCALE,
-				adapter->NF[TYPE_RXPD][TYPE_AVG] / AVG_SCALE);
-		break;
-	default:
-		return -ENOTSUPP;
-	}
-	val = (int *)wrq->u.name;
-	*val = temp;
-
-	LEAVE();
-	return 0;
-}
-
-static int wlan_get_nf(wlan_private * priv, struct iwreq *wrq)
-{
-	int ret = 0;
-	wlan_adapter *adapter = priv->adapter;
-	int temp;
-	int data = 0;
-	int *val;
-
-	data = SUBCMD_DATA(wrq);
-	if ((data == 0) || (data == 1)) {
-		ret = libertas_prepare_and_send_command(priv,
-					    cmd_802_11_rssi,
-					    0, cmd_option_waitforrsp,
-					    0, NULL);
-
-		if (ret) {
-			LEAVE();
-			return ret;
-		}
-	}
-
-	switch (data) {
-	case 0:
-		temp = adapter->NF[TYPE_BEACON][TYPE_NOAVG];
-		break;
-	case 1:
-		temp = adapter->NF[TYPE_BEACON][TYPE_AVG];
-		break;
-	case 2:
-		temp = adapter->NF[TYPE_RXPD][TYPE_NOAVG];
-		break;
-	case 3:
-		temp = adapter->NF[TYPE_RXPD][TYPE_AVG] / AVG_SCALE;
-		break;
-	default:
-		return -ENOTSUPP;
-	}
-
-	temp = CAL_NF(temp);
-
-	lbs_pr_debug(1, "%s: temp = %d\n", __FUNCTION__, temp);
-	val = (int *)wrq->u.name;
-	*val = temp;
-	return 0;
-}
-
-static int wlan_get_txrate_ioctl(wlan_private * priv, struct ifreq *req)
-{
-	wlan_adapter *adapter = priv->adapter;
-	int *pdata;
-	struct iwreq *wrq = (struct iwreq *)req;
-	int ret = 0;
-	adapter->txrate = 0;
-	lbs_pr_debug(1, "wlan_get_txrate_ioctl\n");
-	ret = libertas_prepare_and_send_command(priv, cmd_802_11_tx_rate_query,
-				    cmd_act_get, cmd_option_waitforrsp,
-				    0, NULL);
-	if (ret)
-		return ret;
-
-	pdata = (int *)wrq->u.name;
-	*pdata = (int)adapter->txrate;
-	return 0;
-}
-
-static int wlan_get_adhoc_status_ioctl(wlan_private * priv, struct iwreq *wrq)
-{
-	char status[64];
-	wlan_adapter *adapter = priv->adapter;
-
-	memset(status, 0, sizeof(status));
-
-	switch (adapter->inframode) {
-	case wlan802_11ibss:
-		if (adapter->connect_status == libertas_connected) {
-			if (adapter->adhoccreate)
-				memcpy(&status, "AdhocStarted", sizeof(status));
-			else
-				memcpy(&status, "AdhocJoined", sizeof(status));
-		} else {
-			memcpy(&status, "AdhocIdle", sizeof(status));
-		}
-		break;
-	case wlan802_11infrastructure:
-		memcpy(&status, "Inframode", sizeof(status));
-		break;
-	default:
-		memcpy(&status, "AutoUnknownmode", sizeof(status));
-		break;
-	}
-
-	lbs_pr_debug(1, "status = %s\n", status);
-	wrq->u.data.length = strlen(status) + 1;
-
-	if (wrq->u.data.pointer) {
-		if (copy_to_user(wrq->u.data.pointer,
-				 &status, wrq->u.data.length))
-			return -EFAULT;
-	}
-
-	LEAVE();
-	return 0;
-}
-
-/**
- *  @brief Set/Get WPA IE
- *  @param priv                 A pointer to wlan_private structure
- *  @param req			A pointer to ifreq structure
- *  @return 	   		0 --success, otherwise fail
- */
-static int wlan_setwpaie_ioctl(wlan_private * priv, struct ifreq *req)
-{
-	struct iwreq *wrq = (struct iwreq *)req;
-	wlan_adapter *adapter = priv->adapter;
-	int ret = 0;
-
-	ENTER();
-
-	if (wrq->u.data.length) {
-		if (wrq->u.data.length > sizeof(adapter->wpa_ie)) {
-			lbs_pr_debug(1, "failed to copy WPA IE, too big \n");
-			return -EFAULT;
-		}
-		if (copy_from_user(adapter->wpa_ie, wrq->u.data.pointer,
-				   wrq->u.data.length)) {
-			lbs_pr_debug(1, "failed to copy WPA IE \n");
-			return -EFAULT;
-		}
-		adapter->wpa_ie_len = wrq->u.data.length;
-		lbs_pr_debug(1, "Set wpa_ie_len=%d IE=%#x\n", adapter->wpa_ie_len,
-		       adapter->wpa_ie[0]);
-		lbs_dbg_hex("wpa_ie", adapter->wpa_ie, adapter->wpa_ie_len);
-		if (adapter->wpa_ie[0] == WPA_IE)
-			adapter->secinfo.WPAenabled = 1;
-		else if (adapter->wpa_ie[0] == WPA2_IE)
-			adapter->secinfo.WPA2enabled = 1;
-		else {
-			adapter->secinfo.WPAenabled = 0;
-			adapter->secinfo.WPA2enabled = 0;
-		}
-	} else {
-		memset(adapter->wpa_ie, 0, sizeof(adapter->wpa_ie));
-		adapter->wpa_ie_len = wrq->u.data.length;
-		lbs_pr_debug(1, "Reset wpa_ie_len=%d IE=%#x\n",
-		       adapter->wpa_ie_len, adapter->wpa_ie[0]);
-		adapter->secinfo.WPAenabled = 0;
-		adapter->secinfo.WPA2enabled = 0;
-	}
-
-	// enable/disable RSN in firmware if WPA is enabled/disabled
-	// depending on variable adapter->secinfo.WPAenabled is set or not
-	ret = libertas_prepare_and_send_command(priv, cmd_802_11_enable_rsn,
-				    cmd_act_set, cmd_option_waitforrsp,
-				    0, NULL);
-
-	LEAVE();
-	return ret;
-}
-
-/**
- *  @brief Set Auto prescan
- *  @param priv                 A pointer to wlan_private structure
- *  @param wrq			A pointer to iwreq structure
- *  @return 	   		0 --success, otherwise fail
- */
-static int wlan_subcmd_setprescan_ioctl(wlan_private * priv, struct iwreq *wrq)
-{
-	int data;
-	wlan_adapter *adapter = priv->adapter;
-	int *val;
-
-	data = SUBCMD_DATA(wrq);
-	lbs_pr_debug(1, "WLAN_SUBCMD_SET_PRESCAN %d\n", data);
-	adapter->prescan = data;
-
-	val = (int *)wrq->u.name;
-	*val = data;
-	return 0;
-}
-
-static int wlan_set_multiple_dtim_ioctl(wlan_private * priv, struct ifreq *req)
-{
-	struct iwreq *wrq = (struct iwreq *)req;
-	u32 mdtim;
-	int idata;
-	int ret = -EINVAL;
-
-	ENTER();
-
-	idata = SUBCMD_DATA(wrq);
-	mdtim = (u32) idata;
-	if (((mdtim >= MRVDRV_MIN_MULTIPLE_DTIM)
-	     && (mdtim <= MRVDRV_MAX_MULTIPLE_DTIM))
-	    || (mdtim == MRVDRV_IGNORE_MULTIPLE_DTIM)) {
-		priv->adapter->multipledtim = mdtim;
-		ret = 0;
-	}
-	if (ret)
-		lbs_pr_debug(1, "Invalid parameter, multipledtim not changed.\n");
-
-	LEAVE();
-	return ret;
-}
-
-/**
- *  @brief Set authentication mode
- *  @param priv                 A pointer to wlan_private structure
- *  @param req			A pointer to ifreq structure
- *  @return 	   		0 --success, otherwise fail
- */
-static int wlan_setauthalg_ioctl(wlan_private * priv, struct ifreq *req)
-{
-	int alg;
-	struct iwreq *wrq = (struct iwreq *)req;
-	wlan_adapter *adapter = priv->adapter;
-
-	if (wrq->u.data.flags == 0) {
-		//from iwpriv subcmd
-		alg = SUBCMD_DATA(wrq);
-	} else {
-		//from wpa_supplicant subcmd
-		if (copy_from_user(&alg, wrq->u.data.pointer, sizeof(alg))) {
-			lbs_pr_debug(1, "Copy from user failed\n");
-			return -EFAULT;
-		}
-	}
-
-	lbs_pr_debug(1, "auth alg is %#x\n", alg);
-
-	switch (alg) {
-	case AUTH_ALG_SHARED_KEY:
-		adapter->secinfo.authmode = wlan802_11authmodeshared;
-		break;
-	case AUTH_ALG_NETWORK_EAP:
-		adapter->secinfo.authmode =
-		    wlan802_11authmodenetworkEAP;
-		break;
-	case AUTH_ALG_OPEN_SYSTEM:
-	default:
-		adapter->secinfo.authmode = wlan802_11authmodeopen;
-		break;
-	}
-	return 0;
-}
-
-/**
- *  @brief Set 802.1x authentication mode
- *  @param priv                 A pointer to wlan_private structure
- *  @param req			A pointer to ifreq structure
- *  @return 	   		0 --success, otherwise fail
- */
-static int wlan_set8021xauthalg_ioctl(wlan_private * priv, struct ifreq *req)
-{
-	int alg;
-	struct iwreq *wrq = (struct iwreq *)req;
-
-	if (wrq->u.data.flags == 0) {
-		//from iwpriv subcmd
-		alg = SUBCMD_DATA(wrq);
-	} else {
-		//from wpa_supplicant subcmd
-		if (copy_from_user(&alg, wrq->u.data.pointer, sizeof(int))) {
-			lbs_pr_debug(1, "Copy from user failed\n");
-			return -EFAULT;
-		}
-	}
-	lbs_pr_debug(1, "802.1x auth alg is %#x\n", alg);
-	priv->adapter->secinfo.auth1xalg = alg;
-	return 0;
-}
-
-static int wlan_setencryptionmode_ioctl(wlan_private * priv, struct ifreq *req)
-{
-	int mode;
-	struct iwreq *wrq = (struct iwreq *)req;
-
-	ENTER();
-
-	if (wrq->u.data.flags == 0) {
-		//from iwpriv subcmd
-		mode = SUBCMD_DATA(wrq);
-	} else {
-		//from wpa_supplicant subcmd
-		if (copy_from_user(&mode, wrq->u.data.pointer, sizeof(int))) {
-			lbs_pr_debug(1, "Copy from user failed\n");
-			return -EFAULT;
-		}
-	}
-	lbs_pr_debug(1, "encryption mode is %#x\n", mode);
-	priv->adapter->secinfo.Encryptionmode = mode;
-
-	LEAVE();
-	return 0;
-}
-
-static void adjust_mtu(wlan_private * priv)
-{
-	int mtu_increment = 0;
-
-	if (priv->adapter->linkmode == WLAN_LINKMODE_802_11)
-		mtu_increment += sizeof(struct ieee80211_hdr_4addr);
-
-	if (priv->adapter->radiomode == WLAN_RADIOMODE_RADIOTAP)
-		mtu_increment += max(sizeof(struct tx_radiotap_hdr),
-				     sizeof(struct rx_radiotap_hdr));
-	priv->wlan_dev.netdev->mtu = ETH_FRAME_LEN
-	    - sizeof(struct ethhdr)
-	    + mtu_increment;
-}
-
-/**
- *  @brief Set Link-Layer Layer mode
- *  @param priv                 A pointer to wlan_private structure
- *  @param req			A pointer to ifreq structure
- *  @return 	   		0 --success, otherwise fail
- */
-static int wlan_set_linkmode_ioctl(wlan_private * priv, struct ifreq *req)
-{
-	int mode;
-
-	mode = (int)((struct ifreq *)((u8 *) req + 4))->ifr_data;
-
-	switch (mode) {
-	case WLAN_LINKMODE_802_3:
-		priv->adapter->linkmode = mode;
-		break;
-	case WLAN_LINKMODE_802_11:
-		priv->adapter->linkmode = mode;
-		break;
-	default:
-		lbs_pr_info("usb8388-5: invalid link-layer mode (%#x)\n",
-		       mode);
-		return -EINVAL;
-		break;
-	}
-	lbs_pr_debug(1, "usb8388-5: link-layer mode is %#x\n", mode);
-
-	adjust_mtu(priv);
-
-	return 0;
-}
-
-/**
- *  @brief Set Radio header mode
- *  @param priv                 A pointer to wlan_private structure
- *  @param req			A pointer to ifreq structure
- *  @return 	   		0 --success, otherwise fail
- */
-static int wlan_set_radiomode_ioctl(wlan_private * priv, struct ifreq *req)
-{
-	int mode;
-
-	mode = (int)((struct ifreq *)((u8 *) req + 4))->ifr_data;
-
-	switch (mode) {
-	case WLAN_RADIOMODE_NONE:
-		priv->adapter->radiomode = mode;
-		break;
-	case WLAN_RADIOMODE_RADIOTAP:
-		priv->adapter->radiomode = mode;
-		break;
-	default:
-		lbs_pr_debug(1, "usb8388-5: invalid radio header mode (%#x)\n",
-		       mode);
-		return -EINVAL;
-	}
-	lbs_pr_debug(1, "usb8388-5: radio-header mode is %#x\n", mode);
-
-	adjust_mtu(priv);
-	return 0;
-}
-
-/**
- *  @brief Set Debug header mode
- *  @param priv                 A pointer to wlan_private structure
- *  @param req			A pointer to ifreq structure
- *  @return 	   		0 --success, otherwise fail
- */
-static int wlan_set_debugmode_ioctl(wlan_private * priv, struct ifreq *req)
-{
-	priv->adapter->debugmode = (int)((struct ifreq *)
-					 ((u8 *) req + 4))->ifr_data;
-	return 0;
-}
-
-static int wlan_subcmd_getrxantenna_ioctl(wlan_private * priv,
-					  struct ifreq *req)
-{
-	int len;
-	char buf[8];
-	struct iwreq *wrq = (struct iwreq *)req;
-
-	lbs_pr_debug(1, "WLAN_SUBCMD_GETRXANTENNA\n");
-	len = getrxantenna(priv, buf);
-
-	wrq->u.data.length = len;
-	if (wrq->u.data.pointer) {
-		if (copy_to_user(wrq->u.data.pointer, &buf, len)) {
-			lbs_pr_debug(1, "CopyToUser failed\n");
-			return -EFAULT;
-		}
-	}
-
-	return 0;
-}
-
-static int wlan_subcmd_gettxantenna_ioctl(wlan_private * priv,
-					  struct ifreq *req)
-{
-	int len;
-	char buf[8];
-	struct iwreq *wrq = (struct iwreq *)req;
-
-	lbs_pr_debug(1, "WLAN_SUBCMD_GETTXANTENNA\n");
-	len = gettxantenna(priv, buf);
-
-	wrq->u.data.length = len;
-	if (wrq->u.data.pointer) {
-		if (copy_to_user(wrq->u.data.pointer, &buf, len)) {
-			lbs_pr_debug(1, "CopyToUser failed\n");
-			return -EFAULT;
-		}
-	}
-	return 0;
-}
-
-/**
- *  @brief Get the MAC TSF value from the firmware
- *
- *  @param priv         A pointer to wlan_private structure
- *  @param wrq          A pointer to iwreq structure containing buffer
- *                      space to store a TSF value retrieved from the firmware
- *
- *  @return             0 if successful; IOCTL error code otherwise
- */
-static int wlan_get_tsf_ioctl(wlan_private * priv, struct iwreq *wrq)
-{
-	u64 tsfval;
-	int ret;
-
-	ret = libertas_prepare_and_send_command(priv,
-				    cmd_get_tsf,
-				    0, cmd_option_waitforrsp, 0, &tsfval);
-
-	lbs_pr_debug(1, "IOCTL: Get TSF = 0x%016llx\n", tsfval);
-
-	if (ret != 0) {
-		lbs_pr_debug(1, "IOCTL: Get TSF; command exec failed\n");
-		ret = -EFAULT;
-	} else {
-		if (copy_to_user(wrq->u.data.pointer,
-				 &tsfval,
-				 min_t(size_t, wrq->u.data.length,
-				     sizeof(tsfval))) != 0) {
-
-			lbs_pr_debug(1, "IOCTL: Get TSF; Copy to user failed\n");
-			ret = -EFAULT;
-		} else {
-			ret = 0;
-		}
-	}
-	return ret;
-}
-
-/**
- *  @brief Get/Set adapt rate
- *  @param priv                 A pointer to wlan_private structure
- *  @param wrq			A pointer to iwreq structure
- *  @return 	   		0 --success, otherwise fail
- */
-static int wlan_adapt_rateset(wlan_private * priv, struct iwreq *wrq)
-{
-	int ret;
-	wlan_adapter *adapter = priv->adapter;
-	int data[2];
-
-	memset(data, 0, sizeof(data));
-	if (!wrq->u.data.length) {
-		lbs_pr_debug(1, "Get ADAPT RATE SET\n");
-		ret = libertas_prepare_and_send_command(priv,
-					    cmd_802_11_rate_adapt_rateset,
-					    cmd_act_get,
-					    cmd_option_waitforrsp, 0, NULL);
-		data[0] = adapter->enablehwauto;
-		data[1] = adapter->ratebitmap;
-		if (copy_to_user(wrq->u.data.pointer, data, sizeof(int) * 2)) {
-			lbs_pr_debug(1, "Copy to user failed\n");
-			return -EFAULT;
-		}
-#define GET_TWO_INT	2
-		wrq->u.data.length = GET_TWO_INT;
-	} else {
-		lbs_pr_debug(1, "Set ADAPT RATE SET\n");
-		if (wrq->u.data.length > 2)
-			return -EINVAL;
-		if (copy_from_user
-		    (data, wrq->u.data.pointer,
-		     sizeof(int) * wrq->u.data.length)) {
-			lbs_pr_debug(1, "Copy from user failed\n");
-			return -EFAULT;
-		}
-
-		adapter->enablehwauto = data[0];
-		adapter->ratebitmap = data[1];
-		ret = libertas_prepare_and_send_command(priv,
-					    cmd_802_11_rate_adapt_rateset,
-					    cmd_act_set,
-					    cmd_option_waitforrsp, 0, NULL);
-	}
-	return ret;
-}
-
-/**
- *  @brief Get/Set inactivity timeout
- *  @param priv                 A pointer to wlan_private structure
- *  @param wrq			A pointer to iwreq structure
- *  @return 	   		0 --success, otherwise fail
- */
-static int wlan_inactivity_timeout(wlan_private * priv, struct iwreq *wrq)
-{
-	int ret;
-	int data = 0;
-	u16 timeout = 0;
-
-	ENTER();
-	if (wrq->u.data.length > 1)
-		return -ENOTSUPP;
-
-	if (wrq->u.data.length == 0) {
-		/* Get */
-		ret = libertas_prepare_and_send_command(priv,
-					    cmd_802_11_inactivity_timeout,
-					    cmd_act_get,
-					    cmd_option_waitforrsp, 0,
-					    &timeout);
-		data = timeout;
-		if (copy_to_user(wrq->u.data.pointer, &data, sizeof(int))) {
-			lbs_pr_debug(1, "Copy to user failed\n");
-			return -EFAULT;
-		}
-	} else {
-		/* Set */
-		if (copy_from_user(&data, wrq->u.data.pointer, sizeof(int))) {
-			lbs_pr_debug(1, "Copy from user failed\n");
-			return -EFAULT;
-		}
-
-		timeout = data;
-		ret = libertas_prepare_and_send_command(priv,
-					    cmd_802_11_inactivity_timeout,
-					    cmd_act_set,
-					    cmd_option_waitforrsp, 0,
-					    &timeout);
-	}
-
-	wrq->u.data.length = 1;
-
-	LEAVE();
-	return ret;
-}
-
-static int wlan_do_getlog_ioctl(wlan_private * priv, struct iwreq *wrq)
-{
-	int ret;
-	char buf[GETLOG_BUFSIZE - 1];
-	wlan_adapter *adapter = priv->adapter;
-
-	lbs_pr_debug(1, " GET STATS\n");
-
-	ret = libertas_prepare_and_send_command(priv, cmd_802_11_get_log,
-				    0, cmd_option_waitforrsp, 0, NULL);
-
-	if (ret) {
-		return ret;
-	}
-
-	if (wrq->u.data.pointer) {
-		sprintf(buf, "\n  mcasttxframe %u failed %u retry %u "
-			"multiretry %u framedup %u "
-			"rtssuccess %u rtsfailure %u ackfailure %u\n"
-			"rxfrag %u mcastrxframe %u fcserror %u "
-			"txframe %u wepundecryptable %u ",
-			adapter->logmsg.mcasttxframe,
-			adapter->logmsg.failed,
-			adapter->logmsg.retry,
-			adapter->logmsg.multiretry,
-			adapter->logmsg.framedup,
-			adapter->logmsg.rtssuccess,
-			adapter->logmsg.rtsfailure,
-			adapter->logmsg.ackfailure,
-			adapter->logmsg.rxfrag,
-			adapter->logmsg.mcastrxframe,
-			adapter->logmsg.fcserror,
-			adapter->logmsg.txframe,
-			adapter->logmsg.wepundecryptable);
-		wrq->u.data.length = strlen(buf) + 1;
-		if (copy_to_user(wrq->u.data.pointer, buf, wrq->u.data.length)) {
-			lbs_pr_debug(1, "Copy to user failed\n");
-			return -EFAULT;
-		}
-	}
-
-	return 0;
-}
-
-static int wlan_scan_type_ioctl(wlan_private * priv, struct iwreq *wrq)
-{
-	u8 buf[12];
-	u8 *option[] = { "active", "passive", "get", };
-	int i, max_options = (sizeof(option) / sizeof(option[0]));
-	int ret = 0;
-	wlan_adapter *adapter = priv->adapter;
-
-	if (priv->adapter->enable11d) {
-		lbs_pr_debug(1, "11D: Cannot set scantype when 11D enabled\n");
-		return -EFAULT;
-	}
-
-	memset(buf, 0, sizeof(buf));
-
-	if (copy_from_user(buf, wrq->u.data.pointer, min_t(size_t, sizeof(buf),
-							 wrq->u.data.length)))
-		return -EFAULT;
-
-	lbs_pr_debug(1, "Scan type Option = %s\n", buf);
-
-	buf[sizeof(buf) - 1] = '\0';
-
-	for (i = 0; i < max_options; i++) {
-		if (!strcmp(buf, option[i]))
-			break;
-	}
-
-	switch (i) {
-	case 0:
-		adapter->scantype = cmd_scan_type_active;
-		break;
-	case 1:
-		adapter->scantype = cmd_scan_type_passive;
-		break;
-	case 2:
-		wrq->u.data.length = strlen(option[adapter->scantype]) + 1;
-
-		if (copy_to_user(wrq->u.data.pointer,
-				 option[adapter->scantype],
-				 wrq->u.data.length)) {
-			lbs_pr_debug(1, "Copy to user failed\n");
-			ret = -EFAULT;
-		}
-
-		break;
-	default:
-		lbs_pr_debug(1, "Invalid Scan type Ioctl Option\n");
-		ret = -EINVAL;
-		break;
-	}
-
-	return ret;
-}
-
-static int wlan_scan_mode_ioctl(wlan_private * priv, struct iwreq *wrq)
-{
-	wlan_adapter *adapter = priv->adapter;
-	u8 buf[12];
-	u8 *option[] = { "bss", "ibss", "any", "get" };
-	int i, max_options = (sizeof(option) / sizeof(option[0]));
-	int ret = 0;
-
-	ENTER();
-
-	memset(buf, 0, sizeof(buf));
-
-	if (copy_from_user(buf, wrq->u.data.pointer, min_t(size_t, sizeof(buf),
-							 wrq->u.data.length))) {
-		lbs_pr_debug(1, "Copy from user failed\n");
-		return -EFAULT;
-	}
-
-	lbs_pr_debug(1, "Scan mode Option = %s\n", buf);
-
-	buf[sizeof(buf) - 1] = '\0';
-
-	for (i = 0; i < max_options; i++) {
-		if (!strcmp(buf, option[i]))
-			break;
-	}
-
-	switch (i) {
-
-	case 0:
-		adapter->scanmode = cmd_bss_type_bss;
-		break;
-	case 1:
-		adapter->scanmode = cmd_bss_type_ibss;
-		break;
-	case 2:
-		adapter->scanmode = cmd_bss_type_any;
-		break;
-	case 3:
-
-		wrq->u.data.length = strlen(option[adapter->scanmode - 1]) + 1;
-
-		lbs_pr_debug(1, "Get Scan mode Option = %s\n",
-		       option[adapter->scanmode - 1]);
-
-		lbs_pr_debug(1, "Scan mode length %d\n", wrq->u.data.length);
-
-		if (copy_to_user(wrq->u.data.pointer,
-				 option[adapter->scanmode - 1],
-				 wrq->u.data.length)) {
-			lbs_pr_debug(1, "Copy to user failed\n");
-			ret = -EFAULT;
-		}
-		lbs_pr_debug(1, "GET Scan type Option after copy = %s\n",
-		       (char *)wrq->u.data.pointer);
-
-		break;
-
-	default:
-		lbs_pr_debug(1, "Invalid Scan mode Ioctl Option\n");
-		ret = -EINVAL;
-		break;
-	}
-
-	LEAVE();
-	return ret;
-}
-
-/**
- *  @brief Get/Set Adhoc G Rate
- *
- *  @param priv		A pointer to wlan_private structure
- *  @param wrq	   	A pointer to user data
- *  @return 	   	0--success, otherwise fail
- */
-static int wlan_do_set_grate_ioctl(wlan_private * priv, struct iwreq *wrq)
-{
-	wlan_adapter *adapter = priv->adapter;
-	int data, data1;
-	int *val;
-
-	ENTER();
-
-	data1 = SUBCMD_DATA(wrq);
-	switch (data1) {
-	case 0:
-		adapter->adhoc_grate_enabled = 0;
-		break;
-	case 1:
-		adapter->adhoc_grate_enabled = 1;
-		break;
-	case 2:
-		break;
-	default:
-		return -EINVAL;
-	}
-	data = adapter->adhoc_grate_enabled;
-	val = (int *)wrq->u.name;
-	*val = data;
-	LEAVE();
-	return 0;
-}
-
 static inline int hex2int(char c)
 {
 	if (c >= '0' && c <= '9')
@@ -1761,6 +680,7 @@ static int wlan_fwt_list_neighbor_ioctl(wlan_private * priv, struct ifreq *req)
  */
 static int wlan_fwt_cleanup_ioctl(wlan_private * priv, struct ifreq *req)
 {
+	struct iwreq *wrq = (struct iwreq *)req;
 	static struct cmd_ds_fwt_access fwt_access;
 	int ret;
 
@@ -1776,7 +696,7 @@ static int wlan_fwt_cleanup_ioctl(wlan_private * priv, struct ifreq *req)
 				    (void *)&fwt_access);
 
 	if (ret == 0)
-		req->ifr_data = (char *)(le32_to_cpu(fwt_access.references));
+		wrq->u.param.value = le32_to_cpu(fwt_access.references);
 	else
 		return -EFAULT;
 
@@ -1792,6 +712,7 @@ static int wlan_fwt_cleanup_ioctl(wlan_private * priv, struct ifreq *req)
  */
 static int wlan_fwt_time_ioctl(wlan_private * priv, struct ifreq *req)
 {
+	struct iwreq *wrq = (struct iwreq *)req;
 	static struct cmd_ds_fwt_access fwt_access;
 	int ret;
 
@@ -1807,7 +728,7 @@ static int wlan_fwt_time_ioctl(wlan_private * priv, struct ifreq *req)
 				    (void *)&fwt_access);
 
 	if (ret == 0)
-		req->ifr_data = (char *)(le32_to_cpu(fwt_access.references));
+		wrq->u.param.value = le32_to_cpu(fwt_access.references);
 	else
 		return -EFAULT;
 
@@ -1823,6 +744,7 @@ static int wlan_fwt_time_ioctl(wlan_private * priv, struct ifreq *req)
  */
 static int wlan_mesh_get_ttl_ioctl(wlan_private * priv, struct ifreq *req)
 {
+	struct iwreq *wrq = (struct iwreq *)req;
 	struct cmd_ds_mesh_access mesh_access;
 	int ret;
 
@@ -1835,9 +757,8 @@ static int wlan_mesh_get_ttl_ioctl(wlan_private * priv, struct ifreq *req)
 				    cmd_option_waitforrsp, 0,
 				    (void *)&mesh_access);
 
-	if (ret == 0) {
-		req->ifr_data = (char *)(le32_to_cpu(mesh_access.data[0]));
-	}
+	if (ret == 0)
+		wrq->u.param.value = le32_to_cpu(mesh_access.data[0]);
 	else
 		return -EFAULT;
 
@@ -1898,36 +819,8 @@ int libertas_do_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 
 	lbs_pr_debug(1, "libertas_do_ioctl: ioctl cmd = 0x%x\n", cmd);
 	switch (cmd) {
-	case WLANSCAN_TYPE:
-		lbs_pr_debug(1, "Scan type Ioctl\n");
-		ret = wlan_scan_type_ioctl(priv, wrq);
-		break;
-
 	case WLAN_SETNONE_GETNONE:	/* set WPA mode on/off ioctl #20 */
 		switch (wrq->u.data.flags) {
-		case WLANDEAUTH:
-			lbs_pr_debug(1, "Deauth\n");
-			libertas_send_deauth(priv);
-			break;
-
-		case WLANADHOCSTOP:
-			lbs_pr_debug(1, "Adhoc stop\n");
-			ret = libertas_do_adhocstop_ioctl(priv);
-			break;
-
-		case WLANRADIOON:
-			wlan_radio_ioctl(priv, 1);
-			break;
-
-		case WLANRADIOOFF:
-			wlan_radio_ioctl(priv, 0);
-			break;
-		case WLANWLANIDLEON:
-			libertas_idle_on(priv);
-			break;
-		case WLANWLANIDLEOFF:
-			libertas_idle_off(priv);
-			break;
 		case WLAN_SUBCMD_BT_RESET:	/* bt_reset */
 			wlan_bt_reset_ioctl(priv);
 			break;
@@ -1937,162 +830,19 @@ int libertas_do_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 		}		/* End of switch */
 		break;
 
-	case WLANSETWPAIE:
-		ret = wlan_setwpaie_ioctl(priv, req);
-		break;
-	case WLAN_SETINT_GETINT:
-		/* The first 4 bytes of req->ifr_data is sub-ioctl number
-		 * after 4 bytes sits the payload.
-		 */
-		subcmd = (int)req->ifr_data;	//from iwpriv subcmd
-		switch (subcmd) {
-		case WLANNF:
-			ret = wlan_get_nf(priv, wrq);
-			break;
-		case WLANRSSI:
-			ret = wlan_get_rssi(priv, wrq);
-			break;
-		case WLANENABLE11D:
-			ret = libertas_cmd_enable_11d(priv, wrq);
-			break;
-		case WLANADHOCGRATE:
-			ret = wlan_do_set_grate_ioctl(priv, wrq);
-			break;
-		case WLAN_SUBCMD_SET_PRESCAN:
-			ret = wlan_subcmd_setprescan_ioctl(priv, wrq);
-			break;
-		}
-		break;
-
-	case WLAN_SETONEINT_GETONEINT:
-		switch (wrq->u.data.flags) {
-		case WLAN_BEACON_INTERVAL:
-			ret = wlan_beacon_interval(priv, wrq);
-			break;
-
-		case WLAN_LISTENINTRVL:
-			if (!wrq->u.data.length) {
-				int data;
-				lbs_pr_debug(1, "Get locallisteninterval value\n");
-#define GET_ONE_INT	1
-				data = adapter->locallisteninterval;
-				if (copy_to_user(wrq->u.data.pointer,
-						 &data, sizeof(int))) {
-					lbs_pr_debug(1, "Copy to user failed\n");
-					return -EFAULT;
-				}
-
-				wrq->u.data.length = GET_ONE_INT;
-			} else {
-				int data;
-				if (copy_from_user
-				    (&data, wrq->u.data.pointer, sizeof(int))) {
-					lbs_pr_debug(1, "Copy from user failed\n");
-					return -EFAULT;
-				}
-
-				lbs_pr_debug(1, "Set locallisteninterval = %d\n",
-				       data);
-#define MAX_U16_VAL	65535
-				if (data > MAX_U16_VAL) {
-					lbs_pr_debug(1, "Exceeds U16 value\n");
-					return -EINVAL;
-				}
-				adapter->locallisteninterval = data;
-			}
-			break;
-		case WLAN_TXCONTROL:
-			ret = wlan_txcontrol(priv, wrq);	//adds for txcontrol ioctl
-			break;
-
-		case WLAN_NULLPKTINTERVAL:
-			ret = wlan_null_pkt_interval(priv, wrq);
-			break;
-
-		default:
-			ret = -EOPNOTSUPP;
-			break;
-		}
-		break;
-
 	case WLAN_SETONEINT_GETNONE:
 		/* The first 4 bytes of req->ifr_data is sub-ioctl number
 		 * after 4 bytes sits the payload.
 		 */
-		subcmd = wrq->u.data.flags;	//from wpa_supplicant subcmd
-
+		subcmd = wrq->u.data.flags;
 		if (!subcmd)
-			subcmd = (int)req->ifr_data;	//from iwpriv subcmd
+			subcmd = (int)wrq->u.param.value;
 
 		switch (subcmd) {
-		case WLAN_SUBCMD_SETRXANTENNA:	/* SETRXANTENNA */
-			idata = SUBCMD_DATA(wrq);
-			ret = setrxantenna(priv, idata);
-			break;
-		case WLAN_SUBCMD_SETTXANTENNA:	/* SETTXANTENNA */
-			idata = SUBCMD_DATA(wrq);
-			ret = settxantenna(priv, idata);
-			break;
-		case WLAN_SET_ATIM_WINDOW:
-			adapter->atimwindow = SUBCMD_DATA(wrq);
-			adapter->atimwindow = min_t(__u16, adapter->atimwindow, 50);
-			break;
-		case WLANSETBCNAVG:
-			adapter->bcn_avg_factor = SUBCMD_DATA(wrq);
-			if (adapter->bcn_avg_factor == 0)
-				adapter->bcn_avg_factor =
-				    DEFAULT_BCN_AVG_FACTOR;
-			if (adapter->bcn_avg_factor > DEFAULT_BCN_AVG_FACTOR)
-				adapter->bcn_avg_factor =
-				    DEFAULT_BCN_AVG_FACTOR;
-			break;
-		case WLANSETDATAAVG:
-			adapter->data_avg_factor = SUBCMD_DATA(wrq);
-			if (adapter->data_avg_factor == 0)
-				adapter->data_avg_factor =
-				    DEFAULT_DATA_AVG_FACTOR;
-			if (adapter->data_avg_factor > DEFAULT_DATA_AVG_FACTOR)
-				adapter->data_avg_factor =
-				    DEFAULT_DATA_AVG_FACTOR;
-			break;
 		case WLANSETREGION:
 			idata = SUBCMD_DATA(wrq);
 			ret = wlan_set_region(priv, (u16) idata);
 			break;
-
-		case WLAN_SET_LISTEN_INTERVAL:
-			idata = SUBCMD_DATA(wrq);
-			adapter->listeninterval = (u16) idata;
-			break;
-
-		case WLAN_SET_MULTIPLE_DTIM:
-			ret = wlan_set_multiple_dtim_ioctl(priv, req);
-			break;
-
-		case WLANSETAUTHALG:
-			ret = wlan_setauthalg_ioctl(priv, req);
-			break;
-
-		case WLANSET8021XAUTHALG:
-			ret = wlan_set8021xauthalg_ioctl(priv, req);
-			break;
-
-		case WLANSETENCRYPTIONMODE:
-			ret = wlan_setencryptionmode_ioctl(priv, req);
-			break;
-
-		case WLAN_SET_LINKMODE:
-			ret = wlan_set_linkmode_ioctl(priv, req);
-			break;
-
-		case WLAN_SET_RADIOMODE:
-			ret = wlan_set_radiomode_ioctl(priv, req);
-			break;
-
-		case WLAN_SET_DEBUGMODE:
-			ret = wlan_set_debugmode_ioctl(priv, req);
-			break;
-
 		case WLAN_SUBCMD_MESH_SET_TTL:
 			idata = SUBCMD_DATA(wrq);
 			ret = wlan_mesh_set_ttl_ioctl(priv, idata);
@@ -2105,38 +855,8 @@ int libertas_do_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 
 		break;
 
-	case WLAN_SETNONE_GETTWELVE_CHAR:	/* Get Antenna settings */
-		/*
-		 * We've not used IW_PRIV_TYPE_FIXED so sub-ioctl number is
-		 * in flags of iwreq structure, otherwise it will be in
-		 * mode member of iwreq structure.
-		 */
-		switch ((int)wrq->u.data.flags) {
-		case WLAN_SUBCMD_GETRXANTENNA:	/* Get Rx Antenna */
-			ret = wlan_subcmd_getrxantenna_ioctl(priv, req);
-			break;
-
-		case WLAN_SUBCMD_GETTXANTENNA:	/* Get Tx Antenna */
-			ret = wlan_subcmd_gettxantenna_ioctl(priv, req);
-			break;
-
-		case WLAN_GET_TSF:
-			ret = wlan_get_tsf_ioctl(priv, wrq);
-			break;
-		}
-		break;
-
 	case WLAN_SET128CHAR_GET128CHAR:
 		switch ((int)wrq->u.data.flags) {
-
-		case WLANSCAN_MODE:
-			lbs_pr_debug(1, "Scan mode Ioctl\n");
-			ret = wlan_scan_mode_ioctl(priv, wrq);
-			break;
-
-		case WLAN_GET_ADHOC_STATUS:
-			ret = wlan_get_adhoc_status_ioctl(priv, wrq);
-			break;
 		case WLAN_SUBCMD_BT_ADD:
 			ret = wlan_bt_add_ioctl(priv, req);
 			break;
@@ -2168,41 +888,11 @@ int libertas_do_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 		break;
 
 	case WLAN_SETNONE_GETONEINT:
-		switch ((int)req->ifr_data) {
-		case WLANGETBCNAVG:
-			pdata = (int *)wrq->u.name;
-			*pdata = (int)adapter->bcn_avg_factor;
-			break;
-
+		switch (wrq->u.param.value) {
 		case WLANGETREGION:
 			pdata = (int *)wrq->u.name;
 			*pdata = (int)adapter->regioncode;
 			break;
-
-		case WLAN_GET_LISTEN_INTERVAL:
-			pdata = (int *)wrq->u.name;
-			*pdata = (int)adapter->listeninterval;
-			break;
-
-		case WLAN_GET_LINKMODE:
-			req->ifr_data = (char *)((u32) adapter->linkmode);
-			break;
-
-		case WLAN_GET_RADIOMODE:
-			req->ifr_data = (char *)((u32) adapter->radiomode);
-			break;
-
-		case WLAN_GET_DEBUGMODE:
-			req->ifr_data = (char *)((u32) adapter->debugmode);
-			break;
-
-		case WLAN_GET_MULTIPLE_DTIM:
-			pdata = (int *)wrq->u.name;
-			*pdata = (int)adapter->multipledtim;
-			break;
-		case WLAN_GET_TX_RATE:
-			ret = wlan_get_txrate_ioctl(priv, req);
-			break;
 		case WLAN_SUBCMD_FWT_CLEANUP:	/* fwt_cleanup */
 			ret = wlan_fwt_cleanup_ioctl(priv, req);
 			break;
@@ -2222,196 +912,8 @@ int libertas_do_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 
 		break;
 
-	case WLANGETLOG:
-		ret = wlan_do_getlog_ioctl(priv, wrq);
-		break;
-
 	case WLAN_SET_GET_SIXTEEN_INT:
 		switch ((int)wrq->u.data.flags) {
-		case WLAN_TPCCFG:
-			{
-				int data[5];
-				struct cmd_ds_802_11_tpc_cfg cfg;
-				memset(&cfg, 0, sizeof(cfg));
-				if ((wrq->u.data.length > 1)
-				    && (wrq->u.data.length != 5))
-					return -1;
-
-				if (wrq->u.data.length == 0) {
-					cfg.action =
-					    cpu_to_le16
-					    (cmd_act_get);
-				} else {
-					if (copy_from_user
-					    (data, wrq->u.data.pointer,
-					     sizeof(int) * 5)) {
-						lbs_pr_debug(1,
-						       "Copy from user failed\n");
-						return -EFAULT;
-					}
-
-					cfg.action =
-					    cpu_to_le16
-					    (cmd_act_set);
-					cfg.enable = data[0];
-					cfg.usesnr = data[1];
-					cfg.P0 = data[2];
-					cfg.P1 = data[3];
-					cfg.P2 = data[4];
-				}
-
-				ret =
-				    libertas_prepare_and_send_command(priv,
-							  cmd_802_11_tpc_cfg,
-							  0,
-							  cmd_option_waitforrsp,
-							  0, (void *)&cfg);
-
-				data[0] = cfg.enable;
-				data[1] = cfg.usesnr;
-				data[2] = cfg.P0;
-				data[3] = cfg.P1;
-				data[4] = cfg.P2;
-				if (copy_to_user
-				    (wrq->u.data.pointer, data,
-				     sizeof(int) * 5)) {
-					lbs_pr_debug(1, "Copy to user failed\n");
-					return -EFAULT;
-				}
-
-				wrq->u.data.length = 5;
-			}
-			break;
-
-		case WLAN_POWERCFG:
-			{
-				int data[4];
-				struct cmd_ds_802_11_pwr_cfg cfg;
-				memset(&cfg, 0, sizeof(cfg));
-				if ((wrq->u.data.length > 1)
-				    && (wrq->u.data.length != 4))
-					return -1;
-				if (wrq->u.data.length == 0) {
-					cfg.action =
-					    cpu_to_le16
-					    (cmd_act_get);
-				} else {
-					if (copy_from_user
-					    (data, wrq->u.data.pointer,
-					     sizeof(int) * 4)) {
-						lbs_pr_debug(1,
-						       "Copy from user failed\n");
-						return -EFAULT;
-					}
-
-					cfg.action =
-					    cpu_to_le16
-					    (cmd_act_set);
-					cfg.enable = data[0];
-					cfg.PA_P0 = data[1];
-					cfg.PA_P1 = data[2];
-					cfg.PA_P2 = data[3];
-				}
-				ret =
-				    libertas_prepare_and_send_command(priv,
-							  cmd_802_11_pwr_cfg,
-							  0,
-							  cmd_option_waitforrsp,
-							  0, (void *)&cfg);
-				data[0] = cfg.enable;
-				data[1] = cfg.PA_P0;
-				data[2] = cfg.PA_P1;
-				data[3] = cfg.PA_P2;
-				if (copy_to_user
-				    (wrq->u.data.pointer, data,
-				     sizeof(int) * 4)) {
-					lbs_pr_debug(1, "Copy to user failed\n");
-					return -EFAULT;
-				}
-
-				wrq->u.data.length = 4;
-			}
-			break;
-		case WLAN_AUTO_FREQ_SET:
-			{
-				int data[3];
-				struct cmd_ds_802_11_afc afc;
-				memset(&afc, 0, sizeof(afc));
-				if (wrq->u.data.length != 3)
-					return -1;
-				if (copy_from_user
-				    (data, wrq->u.data.pointer,
-				     sizeof(int) * 3)) {
-					lbs_pr_debug(1, "Copy from user failed\n");
-					return -EFAULT;
-				}
-				afc.afc_auto = data[0];
-
-				if (afc.afc_auto != 0) {
-					afc.threshold = data[1];
-					afc.period = data[2];
-				} else {
-					afc.timing_offset = data[1];
-					afc.carrier_offset = data[2];
-				}
-				ret =
-				    libertas_prepare_and_send_command(priv,
-							  cmd_802_11_set_afc,
-							  0,
-							  cmd_option_waitforrsp,
-							  0, (void *)&afc);
-			}
-			break;
-		case WLAN_AUTO_FREQ_GET:
-			{
-				int data[3];
-				struct cmd_ds_802_11_afc afc;
-				memset(&afc, 0, sizeof(afc));
-				ret =
-				    libertas_prepare_and_send_command(priv,
-							  cmd_802_11_get_afc,
-							  0,
-							  cmd_option_waitforrsp,
-							  0, (void *)&afc);
-				data[0] = afc.afc_auto;
-				data[1] = afc.timing_offset;
-				data[2] = afc.carrier_offset;
-				if (copy_to_user
-				    (wrq->u.data.pointer, data,
-				     sizeof(int) * 3)) {
-					lbs_pr_debug(1, "Copy to user failed\n");
-					return -EFAULT;
-				}
-
-				wrq->u.data.length = 3;
-			}
-			break;
-		case WLAN_SCANPROBES:
-			{
-				int data;
-				if (wrq->u.data.length > 0) {
-					if (copy_from_user
-					    (&data, wrq->u.data.pointer,
-					     sizeof(int))) {
-						lbs_pr_debug(1,
-						       "Copy from user failed\n");
-						return -EFAULT;
-					}
-
-					adapter->scanprobes = data;
-				} else {
-					data = adapter->scanprobes;
-					if (copy_to_user
-					    (wrq->u.data.pointer, &data,
-					     sizeof(int))) {
-						lbs_pr_debug(1,
-						       "Copy to user failed\n");
-						return -EFAULT;
-					}
-				}
-				wrq->u.data.length = 1;
-			}
-			break;
 		case WLAN_LED_GPIO_CTRL:
 			{
 				int i;
@@ -2475,17 +977,6 @@ int libertas_do_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 				wrq->u.data.length = gpio->header.len;
 			}
 			break;
-		case WLAN_ADAPT_RATESET:
-			ret = wlan_adapt_rateset(priv, wrq);
-			break;
-		case WLAN_INACTIVITY_TIMEOUT:
-			ret = wlan_inactivity_timeout(priv, wrq);
-			break;
-		case WLANSNR:
-			ret = wlan_get_snr(priv, wrq);
-			break;
-		case WLAN_GET_RXINFO:
-			ret = wlan_get_rxinfo(priv, wrq);
 		}
 		break;
 
diff --git a/drivers/net/wireless/libertas/join.c b/drivers/net/wireless/libertas/join.c
index 11682cb..d4926b8 100644
--- a/drivers/net/wireless/libertas/join.c
+++ b/drivers/net/wireless/libertas/join.c
@@ -15,6 +15,8 @@
 #include "join.h"
 #include "dev.h"
 
+#define AD_HOC_CAP_PRIVACY_ON 1
+
 /**
  *  @brief This function finds out the common rates between rate1 and rate2.
  *
@@ -85,7 +87,7 @@ int libertas_send_deauth(wlan_private * priv)
 	wlan_adapter *adapter = priv->adapter;
 	int ret = 0;
 
-	if (adapter->inframode == wlan802_11infrastructure &&
+	if (adapter->mode == IW_MODE_INFRA &&
 	    adapter->connect_status == libertas_connected)
 		ret = libertas_send_deauthentication(priv);
 	else
@@ -94,20 +96,6 @@ int libertas_send_deauth(wlan_private * priv)
 	return ret;
 }
 
-int libertas_do_adhocstop_ioctl(wlan_private * priv)
-{
-	wlan_adapter *adapter = priv->adapter;
-	int ret = 0;
-
-	if (adapter->inframode == wlan802_11ibss &&
-	    adapter->connect_status == libertas_connected)
-		ret = libertas_stop_adhoc_network(priv);
-	else
-		ret = -ENOTSUPP;
-
-	return ret;
-}
-
 /**
  *  @brief Associate to a specific BSS discovered in a scan
  *
@@ -207,8 +195,7 @@ int libertas_join_adhoc_network(wlan_private * priv, struct bss_descriptor * pbs
 	/* check if the requested SSID is already joined */
 	if (adapter->curbssparams.ssid.ssidlength
 	    && !libertas_SSID_cmp(&pbssdesc->ssid, &adapter->curbssparams.ssid)
-	    && (adapter->curbssparams.bssdescriptor.inframode ==
-		wlan802_11ibss)) {
+	    && (adapter->mode == IW_MODE_ADHOC)) {
 
         lbs_pr_debug(1,
 		       "ADHOC_J_CMD: New ad-hoc SSID is the same as current, "
@@ -261,130 +248,6 @@ int libertas_send_deauthentication(wlan_private * priv)
 }
 
 /**
- *  @brief Set Idle Off
- *
- *  @param priv         A pointer to wlan_private structure
- *  @return             0 --success, otherwise fail
- */
-int libertas_idle_off(wlan_private * priv)
-{
-	wlan_adapter *adapter = priv->adapter;
-	int ret = 0;
-	const u8 zeromac[] = { 0, 0, 0, 0, 0, 0 };
-	int i;
-
-	ENTER();
-
-	if (adapter->connect_status == libertas_disconnected) {
-		if (adapter->inframode == wlan802_11infrastructure) {
-			if (memcmp(adapter->previousbssid, zeromac,
-				   sizeof(zeromac)) != 0) {
-
-				lbs_pr_debug(1, "Previous SSID = %s\n",
-				       adapter->previousssid.ssid);
-				lbs_pr_debug(1, "Previous BSSID = "
-				       "%02x:%02x:%02x:%02x:%02x:%02x:\n",
-				       adapter->previousbssid[0],
-				       adapter->previousbssid[1],
-				       adapter->previousbssid[2],
-				       adapter->previousbssid[3],
-				       adapter->previousbssid[4],
-				       adapter->previousbssid[5]);
-
-				i = libertas_find_SSID_in_list(adapter,
-						   &adapter->previousssid,
-						   adapter->previousbssid,
-						   adapter->inframode);
-
-				if (i < 0) {
-					libertas_send_specific_BSSID_scan(priv,
-							      adapter->
-							      previousbssid,
-							      1);
-					i = libertas_find_SSID_in_list(adapter,
-							   &adapter->
-							   previousssid,
-							   adapter->
-							   previousbssid,
-							   adapter->
-							   inframode);
-				}
-
-				if (i < 0) {
-					/* If the BSSID could not be found, try just the SSID */
-					i = libertas_find_SSID_in_list(adapter,
-							   &adapter->
-							   previousssid, NULL,
-							   adapter->
-							   inframode);
-				}
-
-				if (i < 0) {
-					libertas_send_specific_SSID_scan(priv,
-							     &adapter->
-							     previousssid,
-							     1);
-					i = libertas_find_SSID_in_list(adapter,
-							   &adapter->
-							   previousssid, NULL,
-							   adapter->
-							   inframode);
-				}
-
-				if (i >= 0) {
-					ret =
-					    wlan_associate(priv,
-							   &adapter->
-							   scantable[i]);
-				}
-			}
-		} else if (adapter->inframode == wlan802_11ibss) {
-			ret = libertas_prepare_and_send_command(priv,
-						    cmd_802_11_ad_hoc_start,
-						    0,
-						    cmd_option_waitforrsp,
-						    0, &adapter->previousssid);
-		}
-	}
-	/* else it is connected */
-
-	lbs_pr_debug(1, "\nwlanidle is off");
-	LEAVE();
-	return ret;
-}
-
-/**
- *  @brief Set Idle On
- *
- *  @param priv         A pointer to wlan_private structure
- *  @return             0 --success, otherwise fail
- */
-int libertas_idle_on(wlan_private * priv)
-{
-	wlan_adapter *adapter = priv->adapter;
-	int ret = 0;
-
-	if (adapter->connect_status == libertas_connected) {
-		if (adapter->inframode == wlan802_11infrastructure) {
-			lbs_pr_debug(1, "Previous SSID = %s\n",
-			       adapter->previousssid.ssid);
-			memmove(&adapter->previousssid,
-				&adapter->curbssparams.ssid,
-				sizeof(struct WLAN_802_11_SSID));
-			libertas_send_deauth(priv);
-
-		} else if (adapter->inframode == wlan802_11ibss) {
-			ret = libertas_stop_adhoc_network(priv);
-		}
-
-	}
-
-	lbs_pr_debug(1, "\nwlanidle is on");
-
-	return ret;
-}
-
-/**
  *  @brief This function prepares command of authenticate.
  *
  *  @param priv      A pointer to wlan_private structure
@@ -398,22 +261,39 @@ int libertas_cmd_80211_authenticate(wlan_private * priv,
 				 void *pdata_buf)
 {
 	wlan_adapter *adapter = priv->adapter;
-	struct cmd_ds_802_11_authenticate *pauthenticate =
-	    &cmd->params.auth;
+	struct cmd_ds_802_11_authenticate *pauthenticate = &cmd->params.auth;
+	int ret = -1;
 	u8 *bssid = pdata_buf;
 
 	cmd->command = cpu_to_le16(cmd_802_11_authenticate);
-	cmd->size =
-	    cpu_to_le16(sizeof(struct cmd_ds_802_11_authenticate)
-			     + S_DS_GEN);
+	cmd->size = cpu_to_le16(sizeof(struct cmd_ds_802_11_authenticate)
+	                        + S_DS_GEN);
+
+	/* translate auth mode to 802.11 defined wire value */
+	switch (adapter->secinfo.auth_mode) {
+	case IW_AUTH_ALG_OPEN_SYSTEM:
+		pauthenticate->authtype = 0x00;
+		break;
+	case IW_AUTH_ALG_SHARED_KEY:
+		pauthenticate->authtype = 0x01;
+		break;
+	case IW_AUTH_ALG_LEAP:
+		pauthenticate->authtype = 0x80;
+		break;
+	default:
+		lbs_pr_debug(1, "AUTH_CMD: invalid auth alg 0x%X\n",
+		             adapter->secinfo.auth_mode);
+		goto out;
+	}
 
-	pauthenticate->authtype = adapter->secinfo.authmode;
 	memcpy(pauthenticate->macaddr, bssid, ETH_ALEN);
 
 	lbs_pr_debug(1, "AUTH_CMD: Bssid is : %x:%x:%x:%x:%x:%x\n",
 	       bssid[0], bssid[1], bssid[2], bssid[3], bssid[4], bssid[5]);
+	ret = 0;
 
-	return 0;
+out:
+	return ret;
 }
 
 int libertas_cmd_80211_deauthenticate(wlan_private * priv,
@@ -550,7 +430,7 @@ int libertas_cmd_80211_associate(wlan_private * priv,
 	lbs_pr_debug(1, "ASSOC_CMD: rates->header.len = %d\n", rates->header.len);
 
 	/* set IBSS field */
-	if (pbssdesc->inframode == wlan802_11infrastructure) {
+	if (pbssdesc->mode == IW_MODE_INFRA) {
 #define CAPINFO_ESS_MODE 1
 		passo->capinfo.ess = CAPINFO_ESS_MODE;
 	}
@@ -624,7 +504,7 @@ int libertas_cmd_80211_ad_hoc_start(wlan_private * priv,
 
 	/* set the BSS type */
 	adhs->bsstype = cmd_bss_type_ibss;
-	pbssdesc->inframode = wlan802_11ibss;
+	pbssdesc->mode = IW_MODE_ADHOC;
 	adhs->beaconperiod = adapter->beaconperiod;
 
 	/* set Physical param set */
@@ -666,15 +546,12 @@ int libertas_cmd_80211_ad_hoc_start(wlan_private * priv,
 	adhs->probedelay = cpu_to_le16(cmd_scan_probe_delay_time);
 
 	/* set up privacy in adapter->scantable[i] */
-	if (adapter->secinfo.WEPstatus == wlan802_11WEPenabled) {
-
-#define AD_HOC_CAP_PRIVACY_ON 1
-		lbs_pr_debug(1, "ADHOC_S_CMD: WEPstatus set, privacy to WEP\n");
+	if (adapter->secinfo.wep_enabled) {
+		lbs_pr_debug(1, "ADHOC_S_CMD: WEP enabled, setting privacy on\n");
 		pbssdesc->privacy = wlan802_11privfilter8021xWEP;
 		adhs->cap.privacy = AD_HOC_CAP_PRIVACY_ON;
 	} else {
-		lbs_pr_debug(1, "ADHOC_S_CMD: WEPstatus NOT set, Setting "
-		       "privacy to ACCEPT ALL\n");
+		lbs_pr_debug(1, "ADHOC_S_CMD: WEP disabled, setting privacy off\n");
 		pbssdesc->privacy = wlan802_11privfilteracceptall;
 	}
 
@@ -786,9 +663,6 @@ int libertas_cmd_80211_ad_hoc_join(wlan_private * priv,
 	       padhocjoin->bssdescriptor.BSSID[5],
 	       padhocjoin->bssdescriptor.SSID);
 
-	lbs_pr_debug(1, "ADHOC_J_CMD: Data Rate = %x\n",
-	       (u32) padhocjoin->bssdescriptor.datarates);
-
 	/* failtimeout */
 	padhocjoin->failtimeout = cpu_to_le16(MRVDRV_ASSOCIATION_TIME_OUT);
 
@@ -832,7 +706,7 @@ int libertas_cmd_80211_ad_hoc_join(wlan_private * priv,
 	padhocjoin->bssdescriptor.ssparamset.ibssparamset.atimwindow =
 	    cpu_to_le16(pbssdesc->atimwindow);
 
-	if (adapter->secinfo.WEPstatus == wlan802_11WEPenabled) {
+	if (adapter->secinfo.wep_enabled) {
 		padhocjoin->bssdescriptor.cap.privacy = AD_HOC_CAP_PRIVACY_ON;
 	}
 
diff --git a/drivers/net/wireless/libertas/join.h b/drivers/net/wireless/libertas/join.h
index 8efa245..115f5a8 100644
--- a/drivers/net/wireless/libertas/join.h
+++ b/drivers/net/wireless/libertas/join.h
@@ -1,6 +1,3 @@
-/* -*- mode: C; tab-width: 4; indent-tabs-mode: nil -*- */
-/* vi: set expandtab shiftwidth=4 tabstop=4 textwidth=78: */
-
 /**
   * Interface for the wlan infrastructure and adhoc join routines
   *
@@ -40,10 +37,6 @@ extern int libertas_ret_80211_disassociate(wlan_private * priv,
 extern int libertas_ret_80211_associate(wlan_private * priv,
 				     struct cmd_ds_command *resp);
 
-extern int libertas_idle_on(wlan_private * priv);
-extern int libertas_idle_off(wlan_private * priv);
-
-extern int libertas_do_adhocstop_ioctl(wlan_private * priv);
 extern int libertas_reassociation_thread(void *data);
 
 struct WLAN_802_11_SSID;
diff --git a/drivers/net/wireless/libertas/main.c b/drivers/net/wireless/libertas/main.c
index dcbf102..b9b25ce 100644
--- a/drivers/net/wireless/libertas/main.c
+++ b/drivers/net/wireless/libertas/main.c
@@ -21,6 +21,13 @@
 #include "debugfs.h"
 #include "assoc.h"
 
+#define DRIVER_RELEASE_VERSION "320.p0"
+const char libertas_driver_version[] = "COMM-USB8388-" DRIVER_RELEASE_VERSION
+#ifdef  DEBUG
+    "-dbg"
+#endif
+    "";
+
 #ifdef ENABLE_PM
 static struct pm_dev *wlan_pm_dev = NULL;
 #endif
diff --git a/drivers/net/wireless/libertas/rx.c b/drivers/net/wireless/libertas/rx.c
index 7e3f78f..d17924f 100644
--- a/drivers/net/wireless/libertas/rx.c
+++ b/drivers/net/wireless/libertas/rx.c
@@ -210,7 +210,7 @@ int libertas_process_rxed_packet(wlan_private * priv, struct sk_buff *skb)
 		goto done;
 	}
 
-	lbs_pr_debug(1, "RX Data: skb->len - sizeof(RxPd) = %d - %d = %d\n",
+	lbs_pr_debug(1, "RX Data: skb->len - sizeof(RxPd) = %d - %zd = %zd\n",
 	       skb->len, sizeof(struct rxpd), skb->len - sizeof(struct rxpd));
 
 	lbs_dbg_hex("RX Data: Dest", p_rx_pkt->eth803_hdr.dest_addr,
@@ -364,7 +364,7 @@ static int process_rxed_802_11_packet(wlan_private * priv, struct sk_buff *skb)
 		priv->stats.rx_errors++;
 	}
 
-	lbs_pr_debug(1, "RX Data: skb->len - sizeof(RxPd) = %d - %d = %d\n",
+	lbs_pr_debug(1, "RX Data: skb->len - sizeof(RxPd) = %d - %zd = %zd\n",
 	       skb->len, sizeof(struct rxpd), skb->len - sizeof(struct rxpd));
 
 	/* create the exported radio header */
diff --git a/drivers/net/wireless/libertas/scan.c b/drivers/net/wireless/libertas/scan.c
index e187062..3c0b1a2 100644
--- a/drivers/net/wireless/libertas/scan.c
+++ b/drivers/net/wireless/libertas/scan.c
@@ -1,6 +1,3 @@
-/* -*- mode: C; tab-width: 4; indent-tabs-mode: nil -*- */
-/* vi: set expandtab shiftwidth=4 tabstop=4 textwidth=78: */
-
 /**
   * Functions implementing wlan scan IOCTL and firmware command APIs
   *
@@ -87,118 +84,95 @@
  *
  *  @return        Index in scantable, or error code if negative
  */
-static int is_network_compatible(wlan_adapter * adapter, int index, int mode)
+static int is_network_compatible(wlan_adapter * adapter, int index, u8 mode)
 {
 	ENTER();
 
-	if (adapter->scantable[index].inframode == mode) {
-		if (adapter->secinfo.WEPstatus == wlan802_11WEPdisabled
+	if (adapter->scantable[index].mode == mode) {
+		if (   !adapter->secinfo.wep_enabled
 		    && !adapter->secinfo.WPAenabled
 		    && !adapter->secinfo.WPA2enabled
-		    && adapter->scantable[index].wpa_supplicant.wpa_ie[0] !=
-		    WPA_IE
-		    && adapter->scantable[index].wpa2_supplicant.wpa_ie[0] !=
-		    WPA2_IE && adapter->secinfo.Encryptionmode == CIPHER_NONE
+		    && adapter->scantable[index].wpa_ie[0] != WPA_IE
+		    && adapter->scantable[index].rsn_ie[0] != WPA2_IE
 		    && !adapter->scantable[index].privacy) {
 			/* no security */
 			LEAVE();
 			return index;
-		} else if (adapter->secinfo.WEPstatus == wlan802_11WEPenabled
+		} else if (   adapter->secinfo.wep_enabled
 			   && !adapter->secinfo.WPAenabled
 			   && !adapter->secinfo.WPA2enabled
 			   && adapter->scantable[index].privacy) {
 			/* static WEP enabled */
 			LEAVE();
 			return index;
-		} else if (adapter->secinfo.WEPstatus == wlan802_11WEPdisabled
+		} else if (   !adapter->secinfo.wep_enabled
 			   && adapter->secinfo.WPAenabled
 			   && !adapter->secinfo.WPA2enabled
-			   && (adapter->scantable[index].wpa_supplicant.
-			       wpa_ie[0]
-			       == WPA_IE)
+			   && (adapter->scantable[index].wpa_ie[0] == WPA_IE)
 			   /* privacy bit may NOT be set in some APs like LinkSys WRT54G
 			      && adapter->scantable[index].privacy */
 		    ) {
 			/* WPA enabled */
-            lbs_pr_debug(1,
+			lbs_pr_debug(1,
 			       "is_network_compatible() WPA: index=%d wpa_ie=%#x "
-			       "wpa2_ie=%#x WEP=%s WPA=%s WPA2=%s Encmode=%#x "
+			       "wpa2_ie=%#x WEP=%s WPA=%s WPA2=%s "
 			       "privacy=%#x\n", index,
-			       adapter->scantable[index].wpa_supplicant.
-			       wpa_ie[0],
-			       adapter->scantable[index].wpa2_supplicant.
-			       wpa_ie[0],
-			       (adapter->secinfo.WEPstatus ==
-				wlan802_11WEPenabled) ? "e" : "d",
-			       (adapter->secinfo.WPAenabled) ? "e" : "d",
-			       (adapter->secinfo.WPA2enabled) ? "e" : "d",
-			       adapter->secinfo.Encryptionmode,
+			       adapter->scantable[index].wpa_ie[0],
+			       adapter->scantable[index].rsn_ie[0],
+			       adapter->secinfo.wep_enabled ? "e" : "d",
+			       adapter->secinfo.WPAenabled ? "e" : "d",
+			       adapter->secinfo.WPA2enabled ? "e" : "d",
 			       adapter->scantable[index].privacy);
 			LEAVE();
 			return index;
-		} else if (adapter->secinfo.WEPstatus == wlan802_11WEPdisabled
+		} else if (   !adapter->secinfo.wep_enabled
 			   && !adapter->secinfo.WPAenabled
 			   && adapter->secinfo.WPA2enabled
-			   && (adapter->scantable[index].wpa2_supplicant.
-			       wpa_ie[0]
-			       == WPA2_IE)
+			   && (adapter->scantable[index].rsn_ie[0] == WPA2_IE)
 			   /* privacy bit may NOT be set in some APs like LinkSys WRT54G
 			      && adapter->scantable[index].privacy */
 		    ) {
 			/* WPA2 enabled */
-            lbs_pr_debug(1,
+			lbs_pr_debug(1,
 			       "is_network_compatible() WPA2: index=%d wpa_ie=%#x "
-			       "wpa2_ie=%#x WEP=%s WPA=%s WPA2=%s Encmode=%#x "
+			       "wpa2_ie=%#x WEP=%s WPA=%s WPA2=%s "
 			       "privacy=%#x\n", index,
-			       adapter->scantable[index].wpa_supplicant.
-			       wpa_ie[0],
-			       adapter->scantable[index].wpa2_supplicant.
-			       wpa_ie[0],
-			       (adapter->secinfo.WEPstatus ==
-				wlan802_11WEPenabled) ? "e" : "d",
-			       (adapter->secinfo.WPAenabled) ? "e" : "d",
-			       (adapter->secinfo.WPA2enabled) ? "e" : "d",
-			       adapter->secinfo.Encryptionmode,
+			       adapter->scantable[index].wpa_ie[0],
+			       adapter->scantable[index].rsn_ie[0],
+			       adapter->secinfo.wep_enabled ? "e" : "d",
+			       adapter->secinfo.WPAenabled ? "e" : "d",
+			       adapter->secinfo.WPA2enabled ? "e" : "d",
 			       adapter->scantable[index].privacy);
 			LEAVE();
 			return index;
-		} else if (adapter->secinfo.WEPstatus == wlan802_11WEPdisabled
+		} else if (   !adapter->secinfo.wep_enabled
 			   && !adapter->secinfo.WPAenabled
 			   && !adapter->secinfo.WPA2enabled
-			   && (adapter->scantable[index].wpa_supplicant.
-			       wpa_ie[0]
-			       != WPA_IE)
-			   && (adapter->scantable[index].wpa2_supplicant.
-			       wpa_ie[0]
-			       != WPA2_IE)
-			   && adapter->secinfo.Encryptionmode != CIPHER_NONE
+			   && (adapter->scantable[index].wpa_ie[0] != WPA_IE)
+			   && (adapter->scantable[index].rsn_ie[0] != WPA2_IE)
 			   && adapter->scantable[index].privacy) {
 			/* dynamic WEP enabled */
-            lbs_pr_debug(1,
+			lbs_pr_debug(1,
 			       "is_network_compatible() dynamic WEP: index=%d "
-			       "wpa_ie=%#x wpa2_ie=%#x Encmode=%#x privacy=%#x\n",
+			       "wpa_ie=%#x wpa2_ie=%#x privacy=%#x\n",
 			       index,
-			       adapter->scantable[index].wpa_supplicant.
-			       wpa_ie[0],
-			       adapter->scantable[index].wpa2_supplicant.
-			       wpa_ie[0], adapter->secinfo.Encryptionmode,
+			       adapter->scantable[index].wpa_ie[0],
+			       adapter->scantable[index].rsn_ie[0],
 			       adapter->scantable[index].privacy);
 			LEAVE();
 			return index;
 		}
 
 		/* security doesn't match */
-        lbs_pr_debug(1,
+		lbs_pr_debug(1,
 		       "is_network_compatible() FAILED: index=%d wpa_ie=%#x "
-		       "wpa2_ie=%#x WEP=%s WPA=%s WPA2=%s Encmode=%#x privacy=%#x\n",
+		       "wpa2_ie=%#x WEP=%s WPA=%s WPA2=%s privacy=%#x\n",
 		       index,
-		       adapter->scantable[index].wpa_supplicant.wpa_ie[0],
-		       adapter->scantable[index].wpa2_supplicant.wpa_ie[0],
-		       (adapter->secinfo.WEPstatus ==
-			wlan802_11WEPenabled) ? "e" : "d",
-		       (adapter->secinfo.WPAenabled) ? "e" : "d",
-		       (adapter->secinfo.WPA2enabled) ? "e" : "d",
-		       adapter->secinfo.Encryptionmode,
+		       adapter->scantable[index].wpa_ie[0],
+		       adapter->scantable[index].rsn_ie[0],
+		       adapter->secinfo.wep_enabled ? "e" : "d",
+		       adapter->secinfo.WPAenabled ? "e" : "d",
+		       adapter->secinfo.WPA2enabled ? "e" : "d",
 		       adapter->scantable[index].privacy);
 		LEAVE();
 		return -ECONNREFUSED;
@@ -924,8 +898,6 @@ static int InterpretBSSDescriptionWithIE(struct bss_descriptor * pBSSEntry,
 	u8 founddatarateie;
 	int bytesleftforcurrentbeacon;
 
-	struct WPA_SUPPLICANT *pwpa_supplicant;
-	struct WPA_SUPPLICANT *pwpa2_supplicant;
 	struct IE_WPA *pIe;
 	const u8 oui01[4] = { 0x00, 0x50, 0xf2, 0x01 };
 
@@ -962,9 +934,6 @@ static int InterpretBSSDescriptionWithIE(struct bss_descriptor * pBSSEntry,
 
 	bytesleftforcurrentbeacon = beaconsize;
 
-	pwpa_supplicant = &pBSSEntry->wpa_supplicant;
-	pwpa2_supplicant = &pBSSEntry->wpa2_supplicant;
-
 	memcpy(pBSSEntry->macaddress, pcurrentptr, ETH_ALEN);
 	lbs_pr_debug(1, "InterpretIE: AP MAC Addr-%x:%x:%x:%x:%x:%x\n",
 	       pBSSEntry->macaddress[0], pBSSEntry->macaddress[1],
@@ -1027,9 +996,9 @@ static int InterpretBSSDescriptionWithIE(struct bss_descriptor * pBSSEntry,
 	}
 
 	if (pcap->ibss == 1) {
-		pBSSEntry->inframode = wlan802_11ibss;
+		pBSSEntry->mode = IW_MODE_ADHOC;
 	} else {
-		pBSSEntry->inframode = wlan802_11infrastructure;
+		pBSSEntry->mode = IW_MODE_INFRA;
 	}
 
 	/* process variable IE */
@@ -1116,7 +1085,7 @@ static int InterpretBSSDescriptionWithIE(struct bss_descriptor * pBSSEntry,
 			    sizeof(pcountryinfo->countrycode)
 			    || pcountryinfo->len > 254) {
 				lbs_pr_debug(1, "InterpretIE: 11D- Err "
-				       "CountryInfo len =%d min=%d max=254\n",
+				       "CountryInfo len =%d min=%zd max=254\n",
 				       pcountryinfo->len,
 				       sizeof(pcountryinfo->countrycode));
 				LEAVE();
@@ -1160,27 +1129,27 @@ static int InterpretBSSDescriptionWithIE(struct bss_descriptor * pBSSEntry,
 #define IE_ID_LEN_FIELDS_BYTES 2
 			pIe = (struct IE_WPA *)pcurrentptr;
 
-			if (!memcmp(pIe->oui, oui01, sizeof(oui01))) {
-				pwpa_supplicant->wpa_ie_len
-				    = min_t(size_t, elemlen + IE_ID_LEN_FIELDS_BYTES,
-					  sizeof(pwpa_supplicant->wpa_ie));
-				memcpy(pwpa_supplicant->wpa_ie,
-				       pcurrentptr,
-				       pwpa_supplicant->wpa_ie_len);
-				lbs_dbg_hex("InterpretIE: Resp WPA_IE",
-					pwpa_supplicant->wpa_ie, elemlen);
-			}
+			if (memcmp(pIe->oui, oui01, sizeof(oui01)))
+				break;
+
+			pBSSEntry->wpa_ie_len = min_t(size_t,
+				elemlen + IE_ID_LEN_FIELDS_BYTES,
+				sizeof(pBSSEntry->wpa_ie));
+			memcpy(pBSSEntry->wpa_ie, pcurrentptr,
+				pBSSEntry->wpa_ie_len);
+			lbs_dbg_hex("InterpretIE: Resp WPA_IE",
+				pBSSEntry->wpa_ie, elemlen);
 			break;
 		case WPA2_IE:
 			pIe = (struct IE_WPA *)pcurrentptr;
-			pwpa2_supplicant->wpa_ie_len
-			    = min_t(size_t, elemlen + IE_ID_LEN_FIELDS_BYTES,
-				  sizeof(pwpa2_supplicant->wpa_ie));
-			memcpy(pwpa2_supplicant->wpa_ie,
-			       pcurrentptr, pwpa2_supplicant->wpa_ie_len);
 
+			pBSSEntry->rsn_ie_len = min_t(size_t,
+				elemlen + IE_ID_LEN_FIELDS_BYTES,
+				sizeof(pBSSEntry->rsn_ie));
+			memcpy(pBSSEntry->rsn_ie, pcurrentptr,
+				pBSSEntry->rsn_ie_len);
 			lbs_dbg_hex("InterpretIE: Resp WPA2_IE",
-				pwpa2_supplicant->wpa_ie, elemlen);
+				pBSSEntry->rsn_ie, elemlen);
 			break;
 		case TIM:
 			break;
@@ -1227,7 +1196,7 @@ int libertas_SSID_cmp(struct WLAN_802_11_SSID *ssid1, struct WLAN_802_11_SSID *s
  *
  *  @return         index in BSSID list, or error return code (< 0)
  */
-int libertas_find_BSSID_in_list(wlan_adapter * adapter, u8 * bssid, int mode)
+int libertas_find_BSSID_in_list(wlan_adapter * adapter, u8 * bssid, u8 mode)
 {
 	int ret = -ENETUNREACH;
 	int i;
@@ -1247,8 +1216,8 @@ int libertas_find_BSSID_in_list(wlan_adapter * adapter, u8 * bssid, int mode)
 	for (i = 0; ret < 0 && i < adapter->numinscantable; i++) {
 		if (!memcmp(adapter->scantable[i].macaddress, bssid, ETH_ALEN)) {
 			switch (mode) {
-			case wlan802_11infrastructure:
-			case wlan802_11ibss:
+			case IW_MODE_INFRA:
+			case IW_MODE_ADHOC:
 				ret = is_network_compatible(adapter, i, mode);
 				break;
 			default:
@@ -1272,7 +1241,7 @@ int libertas_find_BSSID_in_list(wlan_adapter * adapter, u8 * bssid, int mode)
  *  @return         index in BSSID list
  */
 int libertas_find_SSID_in_list(wlan_adapter * adapter,
-		   struct WLAN_802_11_SSID *ssid, u8 * bssid, int mode)
+		   struct WLAN_802_11_SSID *ssid, u8 * bssid, u8 mode)
 {
 	int net = -ENETUNREACH;
 	u8 bestrssi = 0;
@@ -1287,8 +1256,8 @@ int libertas_find_SSID_in_list(wlan_adapter * adapter,
 		     !memcmp(adapter->scantable[i].
 			     macaddress, bssid, ETH_ALEN))) {
 			switch (mode) {
-			case wlan802_11infrastructure:
-			case wlan802_11ibss:
+			case IW_MODE_INFRA:
+			case IW_MODE_ADHOC:
 				j = is_network_compatible(adapter, i, mode);
 
 				if (j >= 0) {
@@ -1311,7 +1280,7 @@ int libertas_find_SSID_in_list(wlan_adapter * adapter,
 					}
 				}
 				break;
-			case wlan802_11autounknown:
+			case IW_MODE_AUTO:
 			default:
 				if (SCAN_RSSI(adapter->scantable[i].rssi)
 				    > bestrssi) {
@@ -1338,8 +1307,7 @@ int libertas_find_SSID_in_list(wlan_adapter * adapter,
  *
  *  @return         index in BSSID list
  */
-int libertas_find_best_SSID_in_list(wlan_adapter * adapter,
-                                    enum WLAN_802_11_NETWORK_INFRASTRUCTURE mode)
+int libertas_find_best_SSID_in_list(wlan_adapter * adapter, u8 mode)
 {
 	int bestnet = -ENETUNREACH;
 	u8 bestrssi = 0;
@@ -1351,8 +1319,8 @@ int libertas_find_best_SSID_in_list(wlan_adapter * adapter,
 
 	for (i = 0; i < adapter->numinscantable; i++) {
 		switch (mode) {
-		case wlan802_11infrastructure:
-		case wlan802_11ibss:
+		case IW_MODE_INFRA:
+		case IW_MODE_ADHOC:
 			if (is_network_compatible(adapter, i, mode) >= 0) {
 				if (SCAN_RSSI(adapter->scantable[i].rssi) >
 				    bestrssi) {
@@ -1363,7 +1331,7 @@ int libertas_find_best_SSID_in_list(wlan_adapter * adapter,
 				}
 			}
 			break;
-		case wlan802_11autounknown:
+		case IW_MODE_AUTO:
 		default:
 			if (SCAN_RSSI(adapter->scantable[i].rssi) > bestrssi) {
 				bestrssi =
@@ -1388,8 +1356,7 @@ int libertas_find_best_SSID_in_list(wlan_adapter * adapter,
  */
 int libertas_find_best_network_SSID(wlan_private * priv,
                                     struct WLAN_802_11_SSID *pSSID,
-                                    enum WLAN_802_11_NETWORK_INFRASTRUCTURE preferred_mode,
-                                    enum WLAN_802_11_NETWORK_INFRASTRUCTURE *out_mode)
+                                    u8 preferred_mode, u8 *out_mode)
 {
 	wlan_adapter *adapter = priv->adapter;
 	int ret = 0;
@@ -1414,7 +1381,7 @@ int libertas_find_best_network_SSID(wlan_private * priv,
 	preqbssid = &adapter->scantable[i];
 	memcpy(pSSID, &preqbssid->ssid,
 	       sizeof(struct WLAN_802_11_SSID));
-	*out_mode = preqbssid->inframode;
+	*out_mode = preqbssid->mode;
 
 	if (!pSSID->ssidlength) {
 		ret = -1;
@@ -1584,7 +1551,7 @@ int libertas_get_scan(struct net_device *dev, struct iw_request_info *info,
 	for (i = 0; i < adapter->numinscantable; i++) {
 		if ((current_ev + MAX_SCAN_CELL_SIZE) >= end_buf) {
 			lbs_pr_debug(1, "i=%d break out: current_ev=%p end_buf=%p "
-			       "MAX_SCAN_CELL_SIZE=%d\n",
+			       "MAX_SCAN_CELL_SIZE=%zd\n",
 			       i, current_ev, end_buf, MAX_SCAN_CELL_SIZE);
 			break;
 		}
@@ -1632,7 +1599,7 @@ int libertas_get_scan(struct net_device *dev, struct iw_request_info *info,
 
 		//Add mode
 		iwe.cmd = SIOCGIWMODE;
-		iwe.u.mode = adapter->scantable[i].inframode + 1;
+		iwe.u.mode = adapter->scantable[i].mode;
 		iwe.len = IW_EV_UINT_LEN;
 		current_ev =
 		    iwe_stream_add_event(current_ev, end_buf, &iwe, iwe.len);
@@ -1666,7 +1633,7 @@ int libertas_get_scan(struct net_device *dev, struct iw_request_info *info,
 			iwe.u.qual.noise =
 			    CAL_NF(adapter->NF[TYPE_BEACON][TYPE_NOAVG]);
 		}
-		if ((adapter->inframode == wlan802_11ibss) &&
+		if ((adapter->mode == IW_MODE_ADHOC) &&
 		    !libertas_SSID_cmp(&adapter->curbssparams.ssid,
 			     &adapter->scantable[i].ssid)
 		    && adapter->adhoccreate) {
@@ -1731,7 +1698,7 @@ int libertas_get_scan(struct net_device *dev, struct iw_request_info *info,
 						 end_buf, &iwe, iwe.len);
 
 		}
-		if ((adapter->scantable[i].inframode == wlan802_11ibss)
+		if ((adapter->scantable[i].mode == IW_MODE_ADHOC)
 		    && !libertas_SSID_cmp(&adapter->curbssparams.ssid,
 				&adapter->scantable[i].ssid)
 		    && adapter->adhoccreate) {
@@ -1745,30 +1712,24 @@ int libertas_get_scan(struct net_device *dev, struct iw_request_info *info,
 		/* Add new value to event */
 		current_val = current_ev + IW_EV_LCP_LEN;
 
-		if (adapter->scantable[i].wpa2_supplicant.wpa_ie[0] == WPA2_IE) {
+		if (adapter->scantable[i].rsn_ie[0] == WPA2_IE) {
 			memset(&iwe, 0, sizeof(iwe));
 			memset(buf, 0, sizeof(buf));
-			memcpy(buf, adapter->scantable[i].
-						wpa2_supplicant.wpa_ie,
-					adapter->scantable[i].wpa2_supplicant.
-						wpa_ie_len);
+			memcpy(buf, adapter->scantable[i].rsn_ie,
+					adapter->scantable[i].rsn_ie_len);
 			iwe.cmd = IWEVGENIE;
-			iwe.u.data.length = adapter->scantable[i].
-					wpa2_supplicant.wpa_ie_len;
+			iwe.u.data.length = adapter->scantable[i].rsn_ie_len;
 			iwe.len = IW_EV_POINT_LEN + iwe.u.data.length;
 			current_ev = iwe_stream_add_point(current_ev, end_buf,
 					&iwe, buf);
 		}
-		if (adapter->scantable[i].wpa_supplicant.wpa_ie[0] == WPA_IE) {
+		if (adapter->scantable[i].wpa_ie[0] == WPA_IE) {
 			memset(&iwe, 0, sizeof(iwe));
 			memset(buf, 0, sizeof(buf));
-			memcpy(buf, adapter->scantable[i].
-						wpa_supplicant.wpa_ie,
-					adapter->scantable[i].wpa_supplicant.
-						wpa_ie_len);
+			memcpy(buf, adapter->scantable[i].wpa_ie,
+					adapter->scantable[i].wpa_ie_len);
 			iwe.cmd = IWEVGENIE;
-			iwe.u.data.length = adapter->scantable[i].
-					wpa_supplicant.wpa_ie_len;
+			iwe.u.data.length = adapter->scantable[i].wpa_ie_len;
 			iwe.len = IW_EV_POINT_LEN + iwe.u.data.length;
 			current_ev = iwe_stream_add_point(current_ev, end_buf,
 					&iwe, buf);
diff --git a/drivers/net/wireless/libertas/scan.h b/drivers/net/wireless/libertas/scan.h
index d93aa7f..405f4f0 100644
--- a/drivers/net/wireless/libertas/scan.h
+++ b/drivers/net/wireless/libertas/scan.h
@@ -1,6 +1,3 @@
-/* -*- mode: C; tab-width: 4; indent-tabs-mode: nil -*- */
-/* vi: set expandtab shiftwidth=4 tabstop=4 textwidth=78: */
-
 /**
   * Interface for the wlan network scan routines
   *
@@ -10,6 +7,7 @@
 #ifndef _WLAN_SCAN_H
 #define _WLAN_SCAN_H
 
+#include <net/ieee80211.h>
 #include "hostcmd.h"
 
 /**
@@ -155,7 +153,7 @@ struct bss_descriptor {
 
 	u32 atimwindow;
 
-	enum WLAN_802_11_NETWORK_INFRASTRUCTURE inframode;
+	u8 mode;
 	u8 libertas_supported_rates[WLAN_SUPPORTED_RATES];
 
 	int extra_ie;
@@ -170,22 +168,22 @@ struct bss_descriptor {
 
 	struct ieeetypes_countryinfofullset countryinfo;
 
-	struct WPA_SUPPLICANT wpa_supplicant;
-	struct WPA_SUPPLICANT wpa2_supplicant;
-
+	u8 wpa_ie[MAX_WPA_IE_LEN];
+	size_t wpa_ie_len;
+	u8 rsn_ie[MAX_WPA_IE_LEN];
+	size_t rsn_ie_len;
 };
 
 extern int libertas_SSID_cmp(struct WLAN_802_11_SSID *ssid1,
 		   struct WLAN_802_11_SSID *ssid2);
 extern int libertas_find_SSID_in_list(wlan_adapter * adapter, struct WLAN_802_11_SSID *ssid,
-			  u8 * bssid, int mode);
-int libertas_find_best_SSID_in_list(wlan_adapter * adapter, enum WLAN_802_11_NETWORK_INFRASTRUCTURE mode);
-extern int libertas_find_BSSID_in_list(wlan_adapter * adapter, u8 * bssid, int mode);
+			  u8 * bssid, u8 mode);
+int libertas_find_best_SSID_in_list(wlan_adapter * adapter, u8 mode);
+extern int libertas_find_BSSID_in_list(wlan_adapter * adapter, u8 * bssid, u8 mode);
 
 int libertas_find_best_network_SSID(wlan_private * priv,
 			struct WLAN_802_11_SSID *pSSID,
-			enum WLAN_802_11_NETWORK_INFRASTRUCTURE preferred_mode,
-			enum WLAN_802_11_NETWORK_INFRASTRUCTURE *out_mode);
+			u8 preferred_mode, u8 *out_mode);
 
 extern int libertas_send_specific_SSID_scan(wlan_private * priv,
 				struct WLAN_802_11_SSID *prequestedssid,
diff --git a/drivers/net/wireless/libertas/tx.c b/drivers/net/wireless/libertas/tx.c
index 82d0622..d4b1347 100644
--- a/drivers/net/wireless/libertas/tx.c
+++ b/drivers/net/wireless/libertas/tx.c
@@ -78,7 +78,7 @@ static int SendSinglePacket(wlan_private * priv, struct sk_buff *skb)
 			 min_t(unsigned int, skb->len, 100));
 
 	if (!skb->len || (skb->len > MRVDRV_ETH_TX_PACKET_BUFFER_SIZE)) {
-		lbs_pr_debug(1, "Tx error: Bad skb length %d : %d\n",
+		lbs_pr_debug(1, "Tx error: Bad skb length %d : %zd\n",
 		       skb->len, MRVDRV_ETH_TX_PACKET_BUFFER_SIZE);
 		ret = -1;
 		goto done;
diff --git a/drivers/net/wireless/libertas/version.h b/drivers/net/wireless/libertas/version.h
index e86f65a..8b13789 100644
--- a/drivers/net/wireless/libertas/version.h
+++ b/drivers/net/wireless/libertas/version.h
@@ -1,8 +1 @@
-#define DRIVER_RELEASE_VERSION "320.p0"
-const char libertas_driver_version[] = "COMM-USB8388-" DRIVER_RELEASE_VERSION
-#ifdef  DEBUG
-    "-dbg"
-#endif
-    "";
-
 
diff --git a/drivers/net/wireless/libertas/wext.c b/drivers/net/wireless/libertas/wext.c
index 4a52336..69f52b6 100644
--- a/drivers/net/wireless/libertas/wext.c
+++ b/drivers/net/wireless/libertas/wext.c
@@ -17,7 +17,6 @@
 #include "defs.h"
 #include "dev.h"
 #include "join.h"
-#include "version.h"
 #include "wext.h"
 #include "assoc.h"
 
@@ -233,7 +232,7 @@ static int changeadhocchannel(wlan_private * priv, int channel)
 
 		// find out the BSSID that matches the current SSID
 		i = libertas_find_SSID_in_list(adapter, &curadhocssid, NULL,
-				   wlan802_11ibss);
+				   IW_MODE_ADHOC);
 
 		if (i >= 0) {
 			lbs_pr_debug(1, "SSID found at %d in List,"
@@ -316,13 +315,11 @@ static int get_active_data_rates(wlan_adapter * adapter,
 	ENTER();
 
 	if (adapter->connect_status != libertas_connected) {
-		if (adapter->inframode == wlan802_11infrastructure) {
-			//Infra. mode
+		if (adapter->mode == IW_MODE_INFRA) {
 			lbs_pr_debug(1, "Infra\n");
 			k = copyrates(rates, k, libertas_supported_rates,
 				      sizeof(libertas_supported_rates));
 		} else {
-			//ad-hoc mode
 			lbs_pr_debug(1, "Adhoc G\n");
 			k = copyrates(rates, k, libertas_adhoc_rates_g,
 				      sizeof(libertas_adhoc_rates_g));
@@ -586,20 +583,7 @@ static int wlan_get_mode(struct net_device *dev,
 
 	ENTER();
 
-	switch (adapter->inframode) {
-	case wlan802_11ibss:
-		*uwrq = IW_MODE_ADHOC;
-		break;
-
-	case wlan802_11infrastructure:
-		*uwrq = IW_MODE_INFRA;
-		break;
-
-	default:
-	case wlan802_11autounknown:
-		*uwrq = IW_MODE_AUTO;
-		break;
-	}
+	*uwrq = adapter->mode;
 
 	LEAVE();
 	return 0;
@@ -1002,149 +986,18 @@ static const struct iw_priv_args wlan_private_args[] = {
 	/*
 	 * { cmd, set_args, get_args, name }
 	 */
-	{
-	 WLANSCAN_TYPE,
-	 IW_PRIV_TYPE_CHAR | 8,
-	 IW_PRIV_TYPE_CHAR | 8,
-	 "scantype"},
-
-	{
-	 WLAN_SETINT_GETINT,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 ""},
-	{
-	 WLANNF,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 "getNF"},
-	{
-	 WLANRSSI,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 "getRSSI"},
-	{
-	 WLANENABLE11D,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 "enable11d"},
-	{
-	 WLANADHOCGRATE,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 "adhocgrate"},
-
-	{
-	 WLAN_SUBCMD_SET_PRESCAN,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 "prescan"},
-	{
-	 WLAN_SETONEINT_GETONEINT,
-	 IW_PRIV_TYPE_INT | 1,
-	 IW_PRIV_TYPE_INT | 1,
-	 ""},
-	{
-	 WLAN_BEACON_INTERVAL,
-	 IW_PRIV_TYPE_INT | 1,
-	 IW_PRIV_TYPE_INT | 1,
-	 "bcninterval"},
-	{
-	 WLAN_LISTENINTRVL,
-	 IW_PRIV_TYPE_INT | 1,
-	 IW_PRIV_TYPE_INT | 1,
-	 "lolisteninter"},
-	{
-	 WLAN_TXCONTROL,
-	 IW_PRIV_TYPE_INT | 1,
-	 IW_PRIV_TYPE_INT | 1,
-	 "txcontrol"},
-	{
-	 WLAN_NULLPKTINTERVAL,
-	 IW_PRIV_TYPE_INT | 1,
-	 IW_PRIV_TYPE_INT | 1,
-	 "psnullinterval"},
 	/* Using iwpriv sub-command feature */
 	{
 	 WLAN_SETONEINT_GETNONE,	/* IOCTL: 24 */
 	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
 	 IW_PRIV_TYPE_NONE,
 	 ""},
-
-	{
-	 WLAN_SUBCMD_SETRXANTENNA,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 IW_PRIV_TYPE_NONE,
-	 "setrxant"},
-	{
-	 WLAN_SUBCMD_SETTXANTENNA,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 IW_PRIV_TYPE_NONE,
-	 "settxant"},
-	{
-	 WLANSETAUTHALG,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 IW_PRIV_TYPE_NONE,
-	 "authalgs",
-	 },
-	{
-	 WLANSET8021XAUTHALG,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 IW_PRIV_TYPE_NONE,
-	 "8021xauthalgs",
-	 },
-	{
-	 WLANSETENCRYPTIONMODE,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 IW_PRIV_TYPE_NONE,
-	 "encryptionmode",
-	 },
 	{
 	 WLANSETREGION,
 	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
 	 IW_PRIV_TYPE_NONE,
 	 "setregioncode"},
 	{
-	 WLAN_SET_LISTEN_INTERVAL,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 IW_PRIV_TYPE_NONE,
-	 "setlisteninter"},
-	{
-	 WLAN_SET_MULTIPLE_DTIM,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 IW_PRIV_TYPE_NONE,
-	 "setmultipledtim"},
-	{
-	 WLAN_SET_ATIM_WINDOW,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 IW_PRIV_TYPE_NONE,
-	 "atimwindow"},
-	{
-	 WLANSETBCNAVG,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 IW_PRIV_TYPE_NONE,
-	 "setbcnavg"},
-	{
-	 WLANSETDATAAVG,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 IW_PRIV_TYPE_NONE,
-	 "setdataavg"},
-	{
-	 WLAN_SET_LINKMODE,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 IW_PRIV_TYPE_NONE,
-	 "linkmode"},
-	{
-	 WLAN_SET_RADIOMODE,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 IW_PRIV_TYPE_NONE,
-	 "radiomode"},
-	{
-	 WLAN_SET_DEBUGMODE,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 IW_PRIV_TYPE_NONE,
-	 "debugmode"},
-	{
 	 WLAN_SUBCMD_MESH_SET_TTL,
 	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
 	 IW_PRIV_TYPE_NONE,
@@ -1160,41 +1013,6 @@ static const struct iw_priv_args wlan_private_args[] = {
 	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
 	 "getregioncode"},
 	{
-	 WLAN_GET_LISTEN_INTERVAL,
-	 IW_PRIV_TYPE_NONE,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 "getlisteninter"},
-	{
-	 WLAN_GET_MULTIPLE_DTIM,
-	 IW_PRIV_TYPE_NONE,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 "getmultipledtim"},
-	{
-	 WLAN_GET_TX_RATE,
-	 IW_PRIV_TYPE_NONE,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 "gettxrate"},
-	{
-	 WLANGETBCNAVG,
-	 IW_PRIV_TYPE_NONE,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 "getbcnavg"},
-	{
-	 WLAN_GET_LINKMODE,
-	 IW_PRIV_TYPE_NONE,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 "get_linkmode"},
-	{
-	 WLAN_GET_RADIOMODE,
-	 IW_PRIV_TYPE_NONE,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 "get_radiomode"},
-	{
-	 WLAN_GET_DEBUGMODE,
-	 IW_PRIV_TYPE_NONE,
-	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
-	 "get_debugmode"},
-	{
 	 WLAN_SUBCMD_FWT_CLEANUP,
 	 IW_PRIV_TYPE_NONE,
 	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
@@ -1210,61 +1028,11 @@ static const struct iw_priv_args wlan_private_args[] = {
 	 IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1,
 	 "mesh_get_ttl"},
 	{
-	 WLAN_SETNONE_GETTWELVE_CHAR,
-	 IW_PRIV_TYPE_NONE,
-	 IW_PRIV_TYPE_CHAR | 12,
-	 ""},
-	{
-	 WLAN_SUBCMD_GETRXANTENNA,
-	 IW_PRIV_TYPE_NONE,
-	 IW_PRIV_TYPE_CHAR | 12,
-	 "getrxant"},
-	{
-	 WLAN_SUBCMD_GETTXANTENNA,
-	 IW_PRIV_TYPE_NONE,
-	 IW_PRIV_TYPE_CHAR | 12,
-	 "gettxant"},
-	{
-	 WLAN_GET_TSF,
-	 IW_PRIV_TYPE_NONE,
-	 IW_PRIV_TYPE_CHAR | 12,
-	 "gettsf"},
-	{
 	 WLAN_SETNONE_GETNONE,
 	 IW_PRIV_TYPE_NONE,
 	 IW_PRIV_TYPE_NONE,
 	 ""},
 	{
-	 WLANDEAUTH,
-	 IW_PRIV_TYPE_NONE,
-	 IW_PRIV_TYPE_NONE,
-	 "deauth"},
-	{
-	 WLANADHOCSTOP,
-	 IW_PRIV_TYPE_NONE,
-	 IW_PRIV_TYPE_NONE,
-	 "adhocstop"},
-	{
-	 WLANRADIOON,
-	 IW_PRIV_TYPE_NONE,
-	 IW_PRIV_TYPE_NONE,
-	 "radioon"},
-	{
-	 WLANRADIOOFF,
-	 IW_PRIV_TYPE_NONE,
-	 IW_PRIV_TYPE_NONE,
-	 "radiooff"},
-	{
-	 WLANWLANIDLEON,
-	 IW_PRIV_TYPE_NONE,
-	 IW_PRIV_TYPE_NONE,
-	 "wlanidle-on"},
-	{
-	 WLANWLANIDLEOFF,
-	 IW_PRIV_TYPE_NONE,
-	 IW_PRIV_TYPE_NONE,
-	 "wlanidle-off"},
-	{
 	 WLAN_SUBCMD_FWT_RESET,
 	 IW_PRIV_TYPE_NONE,
 	 IW_PRIV_TYPE_NONE,
@@ -1327,90 +1095,15 @@ static const struct iw_priv_args wlan_private_args[] = {
 	 IW_PRIV_TYPE_CHAR | 128,
 	 "fwt_list_route"},
 	{
-	 WLANSCAN_MODE,
-	 IW_PRIV_TYPE_CHAR | 128,
-	 IW_PRIV_TYPE_CHAR | 128,
-	 "scanmode"},
-	{
-	 WLAN_GET_ADHOC_STATUS,
-	 IW_PRIV_TYPE_CHAR | 128,
-	 IW_PRIV_TYPE_CHAR | 128,
-	 "getadhocstatus"},
-	{
-	 WLAN_SETNONE_GETWORDCHAR,
-	 IW_PRIV_TYPE_NONE,
-	 IW_PRIV_TYPE_CHAR | 128,
-	 ""},
-	{
-	 WLANSETWPAIE,
-	 IW_PRIV_TYPE_CHAR | IW_PRIV_SIZE_FIXED | 24,
-	 IW_PRIV_TYPE_NONE,
-	 "setwpaie"},
-	{
-	 WLANGETLOG,
-	 IW_PRIV_TYPE_NONE,
-	 IW_PRIV_TYPE_CHAR | GETLOG_BUFSIZE,
-	 "getlog"},
-	{
 	 WLAN_SET_GET_SIXTEEN_INT,
 	 IW_PRIV_TYPE_INT | 16,
 	 IW_PRIV_TYPE_INT | 16,
 	 ""},
 	{
-	 WLAN_TPCCFG,
-	 IW_PRIV_TYPE_INT | 16,
-	 IW_PRIV_TYPE_INT | 16,
-	 "tpccfg"},
-	{
-	 WLAN_POWERCFG,
-	 IW_PRIV_TYPE_INT | 16,
-	 IW_PRIV_TYPE_INT | 16,
-	 "powercfg"},
-	{
-	 WLAN_AUTO_FREQ_SET,
-	 IW_PRIV_TYPE_INT | 16,
-	 IW_PRIV_TYPE_INT | 16,
-	 "setafc"},
-	{
-	 WLAN_AUTO_FREQ_GET,
-	 IW_PRIV_TYPE_INT | 16,
-	 IW_PRIV_TYPE_INT | 16,
-	 "getafc"},
-	{
-	 WLAN_SCANPROBES,
-	 IW_PRIV_TYPE_INT | 16,
-	 IW_PRIV_TYPE_INT | 16,
-	 "scanprobes"},
-	{
 	 WLAN_LED_GPIO_CTRL,
 	 IW_PRIV_TYPE_INT | 16,
 	 IW_PRIV_TYPE_INT | 16,
 	 "ledgpio"},
-	{
-	 WLAN_ADAPT_RATESET,
-	 IW_PRIV_TYPE_INT | 16,
-	 IW_PRIV_TYPE_INT | 16,
-	 "rateadapt"},
-	{
-	 WLAN_INACTIVITY_TIMEOUT,
-	 IW_PRIV_TYPE_INT | 16,
-	 IW_PRIV_TYPE_INT | 16,
-	 "inactivityto"},
-	{
-	 WLANSNR,
-	 IW_PRIV_TYPE_INT | 16,
-	 IW_PRIV_TYPE_INT | 16,
-	 "getSNR"},
-	{
-	 WLAN_GET_RATE,
-	 IW_PRIV_TYPE_INT | 16,
-	 IW_PRIV_TYPE_INT | 16,
-	 "getrate"},
-	{
-	 WLAN_GET_RXINFO,
-	 IW_PRIV_TYPE_INT | 16,
-	 IW_PRIV_TYPE_INT | 16,
-	 "getrxinfo"},
 };
 
 static struct iw_statistics *wlan_get_wireless_stats(struct net_device *dev)
@@ -1434,7 +1127,7 @@ static struct iw_statistics *wlan_get_wireless_stats(struct net_device *dev)
 
 	ENTER();
 
-	priv->wstats.status = adapter->inframode;
+	priv->wstats.status = adapter->mode;
 
 	/* If we're not associated, all quality values are meaningless */
 	if (adapter->connect_status != libertas_connected)
@@ -1568,13 +1261,12 @@ static int wlan_set_freq(struct net_device *dev, struct iw_request_info *info,
 		if (!cfp) {
 			rc = -EINVAL;
 		} else {
-			if (adapter->inframode == wlan802_11ibss) {
+			if (adapter->mode == IW_MODE_ADHOC) {
 				rc = changeadhocchannel(priv, channel);
 				/*  If station is WEP enabled, send the
 				 *  command to set WEP in firmware
 				 */
-				if (adapter->secinfo.WEPstatus ==
-				    wlan802_11WEPenabled) {
+				if (adapter->secinfo.wep_enabled) {
 					lbs_pr_debug(1, "set_freq: WEP enabled\n");
 					ret = libertas_prepare_and_send_command(priv,
 								    cmd_802_11_set_wep,
@@ -1716,49 +1408,31 @@ static int wlan_set_mode(struct net_device *dev,
 	wlan_private *priv = dev->priv;
 	wlan_adapter *adapter = priv->adapter;
 	struct assoc_request * assoc_req;
-	enum WLAN_802_11_NETWORK_INFRASTRUCTURE new_mode;
 
 	ENTER();
 
-	switch (*uwrq) {
-	case IW_MODE_ADHOC:
-		lbs_pr_debug(1, "Wanted mode is ad-hoc: current datarate=%#x\n",
-		       adapter->datarate);
-		new_mode = wlan802_11ibss;
-		adapter->adhocchannel = DEFAULT_AD_HOC_CHANNEL;
-		break;
-
-	case IW_MODE_INFRA:
-		lbs_pr_debug(1, "Wanted mode is Infrastructure\n");
-		new_mode = wlan802_11infrastructure;
-		break;
-
-	case IW_MODE_AUTO:
-		lbs_pr_debug(1, "Wanted mode is Auto\n");
-		new_mode = wlan802_11autounknown;
-		break;
-
-	default:
-		lbs_pr_debug(1, "Wanted mode is Unknown: 0x%x\n", *uwrq);
-		return -EINVAL;
+	if (   (*uwrq != IW_MODE_ADHOC)
+	    && (*uwrq != IW_MODE_INFRA)
+	    && (*uwrq != IW_MODE_AUTO)) {
+		lbs_pr_debug(1, "Invalid mode: 0x%x\n", *uwrq);
+		ret = -EINVAL;
+		goto out;
 	}
 
 	mutex_lock(&adapter->lock);
 	assoc_req = wlan_get_association_request(adapter);
 	if (!assoc_req) {
 		ret = -ENOMEM;
+		wlan_cancel_association_work(priv);
 	} else {
-		assoc_req->mode = new_mode;
-	}
-
-	if (ret == 0) {
+		assoc_req->mode = *uwrq;
 		set_bit(ASSOC_FLAG_MODE, &assoc_req->flags);
 		wlan_postpone_association_work(priv);
-	} else {
-		wlan_cancel_association_work(priv);
+		lbs_pr_debug(1, "Switching to mode: 0x%x\n", *uwrq);
 	}
 	mutex_unlock(&adapter->lock);
 
+out:
 	LEAVE();
 	return ret;
 }
@@ -1789,13 +1463,13 @@ static int wlan_get_encode(struct net_device *dev,
 	dwrq->flags = 0;
 
 	/* Authentication method */
-	switch (adapter->secinfo.authmode) {
-	case wlan802_11authmodeopen:
+	switch (adapter->secinfo.auth_mode) {
+	case IW_AUTH_ALG_OPEN_SYSTEM:
 		dwrq->flags = IW_ENCODE_OPEN;
 		break;
 
-	case wlan802_11authmodeshared:
-	case wlan802_11authmodenetworkEAP:
+	case IW_AUTH_ALG_SHARED_KEY:
+	case IW_AUTH_ALG_LEAP:
 		dwrq->flags = IW_ENCODE_RESTRICTED;
 		break;
 	default:
@@ -1803,8 +1477,9 @@ static int wlan_get_encode(struct net_device *dev,
 		break;
 	}
 
-	if ((adapter->secinfo.WEPstatus == wlan802_11WEPenabled)
-	    || adapter->secinfo.WPAenabled || adapter->secinfo.WPA2enabled) {
+	if (   adapter->secinfo.wep_enabled
+	    || adapter->secinfo.WPAenabled
+	    || adapter->secinfo.WPA2enabled) {
 		dwrq->flags &= ~IW_ENCODE_DISABLED;
 	} else {
 		dwrq->flags |= IW_ENCODE_DISABLED;
@@ -1818,8 +1493,7 @@ static int wlan_get_encode(struct net_device *dev,
 	if (index < 0)
 		index = adapter->wep_tx_keyidx;
 
-	if ((adapter->wep_keys[index].len) &&
-	    (adapter->secinfo.WEPstatus == wlan802_11WEPenabled)) {
+	if ((adapter->wep_keys[index].len) && adapter->secinfo.wep_enabled) {
 		memcpy(extra, adapter->wep_keys[index].key,
 		       adapter->wep_keys[index].len);
 		dwrq->length = adapter->wep_keys[index].len;
@@ -1903,7 +1577,7 @@ static int wlan_set_wep_key(struct assoc_request *assoc_req,
 		assoc_req->wep_tx_keyidx = index;
 	}
 
-	assoc_req->secinfo.WEPstatus = wlan802_11WEPenabled;
+	assoc_req->secinfo.wep_enabled = 1;
 
 	LEAVE();
 	return 0;
@@ -1932,10 +1606,10 @@ static void disable_wep(struct assoc_request *assoc_req)
 	int i;
 
 	/* Set Open System auth mode */
-	assoc_req->secinfo.authmode = wlan802_11authmodeopen;
+	assoc_req->secinfo.auth_mode = IW_AUTH_ALG_OPEN_SYSTEM;
 
 	/* Clear WEP keys and mark WEP as disabled */
-	assoc_req->secinfo.WEPstatus = wlan802_11WEPdisabled;
+	assoc_req->secinfo.wep_enabled = 0;
 	for (i = 0; i < 4; i++)
 		assoc_req->wep_keys[i].len = 0;
 
@@ -1987,8 +1661,7 @@ static int wlan_set_encode(struct net_device *dev,
 	/* If WEP isn't enabled, or if there is no key data but a valid
 	 * index, set the TX key.
 	 */
-	if ((assoc_req->secinfo.WEPstatus != wlan802_11WEPenabled)
-	    || (dwrq->length == 0 && !is_default))
+	if (!assoc_req->secinfo.wep_enabled || (dwrq->length == 0 && !is_default))
 		set_tx_key = 1;
 
 	ret = wlan_set_wep_key(assoc_req, extra, dwrq->length, index, set_tx_key);
@@ -2001,9 +1674,9 @@ static int wlan_set_encode(struct net_device *dev,
 		set_bit(ASSOC_FLAG_WEP_TX_KEYIDX, &assoc_req->flags);
 
 	if (dwrq->flags & IW_ENCODE_RESTRICTED) {
-		assoc_req->secinfo.authmode = wlan802_11authmodeshared;
+		assoc_req->secinfo.auth_mode = IW_AUTH_ALG_SHARED_KEY;
 	} else if (dwrq->flags & IW_ENCODE_OPEN) {
-		assoc_req->secinfo.authmode = wlan802_11authmodeopen;
+		assoc_req->secinfo.auth_mode = IW_AUTH_ALG_OPEN_SYSTEM;
 	}
 
 out:
@@ -2056,30 +1729,31 @@ static int wlan_get_encodeext(struct net_device *dev,
 
 	if (!ext->ext_flags & IW_ENCODE_EXT_GROUP_KEY &&
 	    ext->alg != IW_ENCODE_ALG_WEP) {
-		if (index != 0 || adapter->inframode != wlan802_11infrastructure)
+		if (index != 0 || adapter->mode != IW_MODE_INFRA)
 			goto out;
 	}
 
 	dwrq->flags = index + 1;
 	memset(ext, 0, sizeof(*ext));
 
-	if ((adapter->secinfo.WEPstatus == wlan802_11WEPdisabled)
-	    && !adapter->secinfo.WPAenabled && !adapter->secinfo.WPA2enabled) {
+	if (   !adapter->secinfo.wep_enabled
+	    && !adapter->secinfo.WPAenabled
+	    && !adapter->secinfo.WPA2enabled) {
 		ext->alg = IW_ENCODE_ALG_NONE;
 		ext->key_len = 0;
 		dwrq->flags |= IW_ENCODE_DISABLED;
 	} else {
 		u8 *key = NULL;
 
-		if ((adapter->secinfo.WEPstatus == wlan802_11WEPenabled)
+		if (   adapter->secinfo.wep_enabled
 		    && !adapter->secinfo.WPAenabled
 		    && !adapter->secinfo.WPA2enabled) {
 			ext->alg = IW_ENCODE_ALG_WEP;
 			ext->key_len = adapter->wep_keys[index].len;
 			key = &adapter->wep_keys[index].key[0];
-		} else if ((adapter->secinfo.WEPstatus == wlan802_11WEPdisabled) &&
-		           (adapter->secinfo.WPAenabled ||
-		            adapter->secinfo.WPA2enabled)) {
+		} else if (   !adapter->secinfo.wep_enabled
+		           && (adapter->secinfo.WPAenabled ||
+		               adapter->secinfo.WPA2enabled)) {
 			/* WPA */
 			ext->alg = IW_ENCODE_ALG_TKIP;
 			ext->key_len = 0;
@@ -2149,7 +1823,7 @@ static int wlan_set_encodeext(struct net_device *dev,
 		/* If WEP isn't enabled, or if there is no key data but a valid
 		 * index, or if the set-TX-key flag was passed, set the TX key.
 		 */
-		if ((assoc_req->secinfo.WEPstatus != wlan802_11WEPenabled)
+		if (   !assoc_req->secinfo.wep_enabled
 		    || (dwrq->length == 0 && !is_default)
 		    || (ext->ext_flags & IW_ENCODE_EXT_SET_TX_KEY))
 			set_tx_key = 1;
@@ -2161,11 +1835,9 @@ static int wlan_set_encodeext(struct net_device *dev,
 			goto out;
 
 		if (dwrq->flags & IW_ENCODE_RESTRICTED) {
-			assoc_req->secinfo.authmode =
-			    wlan802_11authmodeshared;
+			assoc_req->secinfo.auth_mode = IW_AUTH_ALG_SHARED_KEY;
 		} else if (dwrq->flags & IW_ENCODE_OPEN) {
-			assoc_req->secinfo.authmode =
-			    wlan802_11authmodeopen;
+			assoc_req->secinfo.auth_mode = IW_AUTH_ALG_OPEN_SYSTEM;
 		}
 
 		/* Mark the various WEP bits as modified */
@@ -2350,15 +2022,13 @@ static int wlan_set_auth(struct net_device *dev,
 		}
 		if (dwrq->value & IW_AUTH_WPA_VERSION_WPA) {
 			assoc_req->secinfo.WPAenabled = 1;
-			assoc_req->secinfo.WEPstatus = wlan802_11WEPdisabled;
-			assoc_req->secinfo.authmode =
-			    wlan802_11authmodeopen;
+			assoc_req->secinfo.wep_enabled = 0;
+			assoc_req->secinfo.auth_mode = IW_AUTH_ALG_OPEN_SYSTEM;
 		}
 		if (dwrq->value & IW_AUTH_WPA_VERSION_WPA2) {
 			assoc_req->secinfo.WPA2enabled = 1;
-			assoc_req->secinfo.WEPstatus = wlan802_11WEPdisabled;
-			assoc_req->secinfo.authmode =
-			    wlan802_11authmodeopen;
+			assoc_req->secinfo.wep_enabled = 0;
+			assoc_req->secinfo.auth_mode = IW_AUTH_ALG_OPEN_SYSTEM;
 		}
 		updated = 1;
 		break;
@@ -2376,14 +2046,11 @@ static int wlan_set_auth(struct net_device *dev,
 
 	case IW_AUTH_80211_AUTH_ALG:
 		if (dwrq->value & IW_AUTH_ALG_SHARED_KEY) {
-			assoc_req->secinfo.authmode =
-			    wlan802_11authmodeshared;
+			assoc_req->secinfo.auth_mode = IW_AUTH_ALG_SHARED_KEY;
 		} else if (dwrq->value & IW_AUTH_ALG_OPEN_SYSTEM) {
-			assoc_req->secinfo.authmode =
-			    wlan802_11authmodeopen;
+			assoc_req->secinfo.auth_mode = IW_AUTH_ALG_OPEN_SYSTEM;
 		} else if (dwrq->value & IW_AUTH_ALG_LEAP) {
-			assoc_req->secinfo.authmode =
-			    wlan802_11authmodenetworkEAP;
+			assoc_req->secinfo.auth_mode = IW_AUTH_ALG_LEAP;
 		} else {
 			ret = -EINVAL;
 		}
@@ -2396,9 +2063,8 @@ static int wlan_set_auth(struct net_device *dev,
 			    !assoc_req->secinfo.WPA2enabled) {
 				assoc_req->secinfo.WPAenabled = 1;
 				assoc_req->secinfo.WPA2enabled = 1;
-				assoc_req->secinfo.WEPstatus = wlan802_11WEPdisabled;
-				assoc_req->secinfo.authmode =
-				    wlan802_11authmodeopen;
+				assoc_req->secinfo.wep_enabled = 0;
+				assoc_req->secinfo.auth_mode = IW_AUTH_ALG_OPEN_SYSTEM;
 			}
 		} else {
 			assoc_req->secinfo.WPAenabled = 0;
@@ -2455,19 +2121,7 @@ static int wlan_get_auth(struct net_device *dev,
 		break;
 
 	case IW_AUTH_80211_AUTH_ALG:
-		switch (adapter->secinfo.authmode) {
-		case wlan802_11authmodeshared:
-			dwrq->value = IW_AUTH_ALG_SHARED_KEY;
-			break;
-		case wlan802_11authmodeopen:
-			dwrq->value = IW_AUTH_ALG_OPEN_SYSTEM;
-			break;
-		case wlan802_11authmodenetworkEAP:
-			dwrq->value = IW_AUTH_ALG_LEAP;
-			break;
-		default:
-			break;
-		}
+		dwrq->value = adapter->secinfo.auth_mode;
 		break;
 
 	case IW_AUTH_WPA_ENABLED:
diff --git a/drivers/net/wireless/libertas/wext.h b/drivers/net/wireless/libertas/wext.h
index 39f367c..15cfaaf 100644
--- a/drivers/net/wireless/libertas/wext.h
+++ b/drivers/net/wireless/libertas/wext.h
@@ -10,88 +10,22 @@
 /** PRIVATE CMD ID */
 #define	WLANIOCTL			SIOCIWFIRSTPRIV
 
-#define WLANSETWPAIE			(WLANIOCTL + 0)
-
-#define WLAN_SETINT_GETINT		(WLANIOCTL + 7)
-#define WLANNF					1
-#define WLANRSSI				2
-#define WLANENABLE11D				5
-#define WLANADHOCGRATE				6
-#define WLAN_SUBCMD_SET_PRESCAN			11
-
 #define WLAN_SETNONE_GETNONE	        (WLANIOCTL + 8)
-#define WLANDEAUTH                  		1
-#define WLANRADIOON                 		2
-#define WLANRADIOOFF                		3
-#define WLANREMOVEADHOCAES          		4
-#define WLANADHOCSTOP               		5
-#define WLANCIPHERTEST              		6
-#define WLANCRYPTOTEST				7
-
-#define WLANWLANIDLEON				10
-#define WLANWLANIDLEOFF				11
 #define WLAN_SUBCMD_BT_RESET			13
 #define WLAN_SUBCMD_FWT_RESET			14
 
-#define WLANGETLOG                  	(WLANIOCTL + 9)
-#define GETLOG_BUFSIZE  300
-
-#define WLANSCAN_TYPE			(WLANIOCTL + 11)
-
 #define WLAN_SETNONE_GETONEINT		(WLANIOCTL + 15)
 #define WLANGETREGION				1
-#define WLAN_GET_LISTEN_INTERVAL		2
-#define WLAN_GET_MULTIPLE_DTIM			3
-#define WLAN_GET_TX_RATE			4
-#define	WLANGETBCNAVG				5
 
-#define WLAN_GET_LINKMODE			6
-#define WLAN_GET_RADIOMODE			7
-#define WLAN_GET_DEBUGMODE			8
 #define WLAN_SUBCMD_FWT_CLEANUP			15
 #define WLAN_SUBCMD_FWT_TIME			16
 #define WLAN_SUBCMD_MESH_GET_TTL		17
 
-#define WLANREGCFRDWR			(WLANIOCTL + 18)
-
-#define WLAN_SETNONE_GETTWELVE_CHAR (WLANIOCTL + 19)
-#define WLAN_SUBCMD_GETRXANTENNA    1
-#define WLAN_SUBCMD_GETTXANTENNA    2
-#define WLAN_GET_TSF                3
-
-#define WLAN_SETNONE_GETWORDCHAR	(WLANIOCTL + 21)
-#define WLANGETADHOCAES				1
-
-#define WLAN_SETONEINT_GETONEINT	(WLANIOCTL + 23)
-#define WLAN_BEACON_INTERVAL			1
-#define	WLAN_LISTENINTRVL			4
-
-#define WLAN_TXCONTROL				6
-#define WLAN_NULLPKTINTERVAL			7
-
 #define WLAN_SETONEINT_GETNONE		(WLANIOCTL + 24)
-#define WLAN_SUBCMD_SETRXANTENNA		1
-#define WLAN_SUBCMD_SETTXANTENNA		2
-#define WLANSETAUTHALG				5
-#define WLANSET8021XAUTHALG			6
-#define WLANSETENCRYPTIONMODE			7
 #define WLANSETREGION				8
-#define WLAN_SET_LISTEN_INTERVAL		9
-
-#define WLAN_SET_MULTIPLE_DTIM			10
-#define WLAN_SET_ATIM_WINDOW			11
-#define WLANSETBCNAVG				13
-#define WLANSETDATAAVG				14
-#define WLAN_SET_LINKMODE			15
-#define WLAN_SET_RADIOMODE			16
-#define WLAN_SET_DEBUGMODE			17
 #define WLAN_SUBCMD_MESH_SET_TTL		18
 
 #define WLAN_SET128CHAR_GET128CHAR	(WLANIOCTL + 25)
-#define WLANSCAN_MODE				6
-
-#define WLAN_GET_ADHOC_STATUS			9
-
 #define WLAN_SUBCMD_BT_ADD			18
 #define WLAN_SUBCMD_BT_DEL   			19
 #define WLAN_SUBCMD_BT_LIST			20
@@ -103,27 +37,8 @@
 #define WLAN_SUBCMD_FWT_LIST_ROUTE			26
 
 #define WLAN_SET_GET_SIXTEEN_INT       (WLANIOCTL + 29)
-#define WLAN_TPCCFG                             1
-#define WLAN_POWERCFG                           2
-
-#define WLAN_AUTO_FREQ_SET			3
-#define WLAN_AUTO_FREQ_GET			4
 #define WLAN_LED_GPIO_CTRL			5
-#define WLAN_SCANPROBES 			6
-#define	WLAN_ADAPT_RATESET			8
-#define	WLAN_INACTIVITY_TIMEOUT			9
-#define WLANSNR					10
-#define WLAN_GET_RATE				11
-#define	WLAN_GET_RXINFO				12
-
-#define WLANCMD52RDWR			(WLANIOCTL + 30)
-#define WLANCMD53RDWR			(WLANIOCTL + 31)
-#define CMD53BUFLEN				32
 
-#define	REG_MAC					0x19
-#define	REG_BBP					0x1a
-#define	REG_RF					0x1b
-#define	REG_EEPROM				0x59
 #define WLAN_LINKMODE_802_3			0
 #define WLAN_LINKMODE_802_11			2
 #define WLAN_RADIOMODE_NONE    			0
