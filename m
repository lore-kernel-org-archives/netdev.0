From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver updates
Date: Tue, 8 May 2007 02:33:37 -0400
Message-ID: <20070508063337.GA12474@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755420AbXEHGdw@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 arch/mips/Kconfig                                  |    2 -
 arch/mips/configs/rbhma4500_defconfig              |   31 --
 .../toshiba_rbtx4927/toshiba_rbtx4927_setup.c      |   19 +
 arch/mips/tx4938/toshiba_rbtx4938/setup.c          |   20 +
 arch/powerpc/platforms/pasemi/pci.c                |   13 -
 arch/powerpc/platforms/pasemi/setup.c              |    1 -
 drivers/net/Kconfig                                |    3 +-
 drivers/net/arm/at91_ether.c                       |   49 +++-
 drivers/net/arm/at91_ether.h                       |   49 ++-
 drivers/net/atl1/atl1_ethtool.c                    |   19 +-
 drivers/net/atl1/atl1_hw.c                         |   44 +--
 drivers/net/atl1/atl1_main.c                       |   83 ++---
 drivers/net/atl1/atl1_param.c                      |   32 +-
 drivers/net/dm9000.c                               |   15 +-
 drivers/net/ehea/ehea_main.c                       |    6 +-
 drivers/net/myri10ge/myri10ge.c                    |  261 +++++++------
 drivers/net/myri10ge/myri10ge_mcp.h                |   20 +-
 drivers/net/natsemi.c                              |   70 ++++-
 drivers/net/ne.c                                   |  123 +++++-
 drivers/net/pasemi_mac.c                           |  404 +++++++++++++++-----
 drivers/net/pasemi_mac.h                           |   23 +-
 drivers/net/pcmcia/xirc2ps_cs.c                    |   14 +-
 drivers/net/skge.c                                 |    9 +-
 drivers/net/sky2.c                                 |   17 +-
 drivers/net/smc91x.h                               |   34 ++
 drivers/net/tc35815.c                              |    1 -
 drivers/net/wireless/Kconfig                       |    2 +-
 drivers/s390/cio/qdio.c                            |   37 ++-
 drivers/s390/cio/qdio.h                            |    4 +-
 drivers/s390/net/netiucv.c                         |    5 +-
 drivers/s390/net/qeth_eddp.c                       |    4 +-
 drivers/s390/net/qeth_eddp.h                       |    3 +-
 drivers/s390/net/qeth_main.c                       |   45 ++-
 drivers/s390/net/qeth_mpc.c                        |  101 +++++
 drivers/s390/net/qeth_mpc.h                        |  219 ++++++-----
 drivers/s390/net/qeth_sys.c                        |    2 -
 include/asm-s390/qdio.h                            |    1 +
 37 files changed, 1228 insertions(+), 557 deletions(-)

Andrew Victor (2):
      AT91RM9200 Ethernet: Support additional PHYs
      AT91RM9200 Ethernet: Fix multicast addressing

Atsushi Nemoto (6):
      ne: Add platform_driver
      ne: Misc fixes for platform driver.
      ne: Add NEEDS_PORTLIST to control ISA auto-probe
      ne: MIPS: Use platform_driver for ne on RBTX49XX
      MIPS: Drop unnecessary CONFIG_ISA from RBTX49XX
      tc35815: Remove unnecessary skb->dev assignment

Ben Dooks (1):
      DM9000: fix use of kfree() on net device

Brice Goglin (5):
      myri10ge: support new firmware counters
      myri10ge: update firmware headers
      myri10ge: fix restoring of multicast list after reset
      myri10ge: move the DMA test code into its own function
      myri10ge: replace the chipset whitelist with firmware autodetection

Jay Cliburn (2):
      atl1: use dev_printk macros
      atl1: fix whitespace damage

Jeff Garzik (1):
      [netdrvr] atl1: fix build

John W. Linville (1):
      libertas: fix for wireless Kconfig changes

Komuro (1):
      PCMCIA-NETDEV : xirc2ps_cs: bugfix of multicast code

Mark Brown (2):
      natsemi: Improve diagnostics for DspCfg workaround
      Subject: natsemi: Allow users to disable workaround for DspCfg reset

Nobuhiro Iwamatsu (1):
      smc91x SuperH support

Olof Johansson (10):
      pasemi_mac: A couple of minor bugfixes.
      pasemi_mac: Move the IRQ mapping from the PCI layer to the driver
      pasemi_mac: Abstract and fix up interrupt restart routines
      pasemi_mac: Timer and interrupt fixes
      pasemi_mac: Add SKB reuse / copy-break
      pasemi_mac: Minor cleanup / define fixes
      pasemi_mac: Logic cleanup / rx performance improvements
      pasemi_mac: Add msglevel support and "debug" module param
      pasemi_mac: PHY support
      pasemi_mac: Use local-mac-address instead of mac-address if available

Peter Tiedemann (1):
      s390: qeth driver hardware specs adaptions

Richard Knutsson (1):
      drivers/net/dm9000: Convert to generic boolean

Stephen Hemminger (2):
      skge: allow WOL except for known broken chips
      sky2: re-enable 88E8056 for most motherboards

Thomas Klein (1):
      ehea: Fix skb header access

Ursula Braun (3):
      s390: qeth driver connection hang
      s390: free skbs in finite amount of time in qeth
      s390: fix Oops when unloading module netiucv

diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
index 7441a2c..b7cb048 100644
--- a/arch/mips/Kconfig
+++ b/arch/mips/Kconfig
@@ -784,7 +784,6 @@ config TOSHIBA_RBTX4927
 	select HAS_TXX9_SERIAL
 	select HW_HAS_PCI
 	select I8259
-	select ISA
 	select SWAP_IO_SPACE
 	select SYS_HAS_CPU_TX49XX
 	select SYS_SUPPORTS_32BIT_KERNEL
@@ -806,7 +805,6 @@ config TOSHIBA_RBTX4938
 	select HAS_TXX9_SERIAL
 	select HW_HAS_PCI
 	select I8259
-	select ISA
 	select SWAP_IO_SPACE
 	select SYS_HAS_CPU_TX49XX
 	select SYS_SUPPORTS_32BIT_KERNEL
diff --git a/arch/mips/configs/rbhma4500_defconfig b/arch/mips/configs/rbhma4500_defconfig
index 29e0df9..7d0f217 100644
--- a/arch/mips/configs/rbhma4500_defconfig
+++ b/arch/mips/configs/rbhma4500_defconfig
@@ -245,7 +245,6 @@ CONFIG_DEFAULT_IOSCHED="anticipatory"
 #
 CONFIG_HW_HAS_PCI=y
 CONFIG_PCI=y
-CONFIG_ISA=y
 CONFIG_MMU=y
 
 #
@@ -573,7 +572,6 @@ CONFIG_MTD_CFI_UTIL=y
 #
 # Plug and Play support
 #
-# CONFIG_PNP is not set
 # CONFIG_PNPACPI is not set
 
 #
@@ -658,7 +656,6 @@ CONFIG_BLK_DEV_IT8213=m
 # CONFIG_BLK_DEV_VIA82CXXX is not set
 CONFIG_BLK_DEV_TC86C001=m
 # CONFIG_IDE_ARM is not set
-# CONFIG_IDE_CHIPSETS is not set
 CONFIG_BLK_DEV_IDEDMA=y
 # CONFIG_IDEDMA_IVB is not set
 # CONFIG_IDEDMA_AUTO is not set
@@ -677,11 +674,6 @@ CONFIG_RAID_ATTRS=m
 # CONFIG_ATA is not set
 
 #
-# Old CD-ROM drivers (not SCSI, not IDE)
-#
-# CONFIG_CD_NO_IDESCSI is not set
-
-#
 # Multi-device support (RAID and LVM)
 #
 # CONFIG_MD is not set
@@ -742,37 +734,20 @@ CONFIG_NET_ETHERNET=y
 # CONFIG_SUNGEM is not set
 # CONFIG_CASSINI is not set
 # CONFIG_NET_VENDOR_3COM is not set
-# CONFIG_NET_VENDOR_SMC is not set
 # CONFIG_DM9000 is not set
-# CONFIG_NET_VENDOR_RACAL is not set
 
 #
 # Tulip family network device support
 #
 # CONFIG_NET_TULIP is not set
-# CONFIG_AT1700 is not set
-# CONFIG_DEPCA is not set
 # CONFIG_HP100 is not set
-CONFIG_NET_ISA=y
-# CONFIG_E2100 is not set
-# CONFIG_EWRK3 is not set
-# CONFIG_EEXPRESS is not set
-# CONFIG_EEXPRESS_PRO is not set
-# CONFIG_HPLAN_PLUS is not set
-# CONFIG_HPLAN is not set
-# CONFIG_LP486E is not set
-# CONFIG_ETH16I is not set
 CONFIG_NE2000=y
-# CONFIG_SEEQ8005 is not set
 CONFIG_NET_PCI=y
 # CONFIG_PCNET32 is not set
 # CONFIG_AMD8111_ETH is not set
 # CONFIG_ADAPTEC_STARFIRE is not set
-# CONFIG_AC3200 is not set
-# CONFIG_APRICOT is not set
 # CONFIG_B44 is not set
 # CONFIG_FORCEDETH is not set
-# CONFIG_CS89x0 is not set
 # CONFIG_DGRS is not set
 # CONFIG_EEPRO100 is not set
 # CONFIG_E100 is not set
@@ -833,8 +808,6 @@ CONFIG_NET_RADIO=y
 # Obsolete Wireless cards support (pre-802.11)
 #
 # CONFIG_STRIP is not set
-# CONFIG_ARLAN is not set
-# CONFIG_WAVELAN is not set
 
 #
 # Wireless 802.11b ISA/PCI cards support
@@ -920,9 +893,6 @@ CONFIG_KEYBOARD_ATKBD=y
 CONFIG_INPUT_MOUSE=y
 CONFIG_MOUSE_PS2=y
 # CONFIG_MOUSE_SERIAL is not set
-# CONFIG_MOUSE_INPORT is not set
-# CONFIG_MOUSE_LOGIBM is not set
-# CONFIG_MOUSE_PC110PAD is not set
 # CONFIG_MOUSE_VSXXXAA is not set
 # CONFIG_INPUT_JOYSTICK is not set
 # CONFIG_INPUT_TOUCHSCREEN is not set
@@ -1072,7 +1042,6 @@ CONFIG_FB_ATY_CT=y
 #
 CONFIG_VGA_CONSOLE=y
 # CONFIG_VGACON_SOFT_SCROLLBACK is not set
-# CONFIG_MDA_CONSOLE is not set
 CONFIG_DUMMY_CONSOLE=y
 # CONFIG_FRAMEBUFFER_CONSOLE is not set
 
diff --git a/arch/mips/tx4927/toshiba_rbtx4927/toshiba_rbtx4927_setup.c b/arch/mips/tx4927/toshiba_rbtx4927/toshiba_rbtx4927_setup.c
index 0f7576d..a0c11ef 100644
--- a/arch/mips/tx4927/toshiba_rbtx4927/toshiba_rbtx4927_setup.c
+++ b/arch/mips/tx4927/toshiba_rbtx4927/toshiba_rbtx4927_setup.c
@@ -1049,3 +1049,22 @@ static int __init toshiba_rbtx4927_rtc_init(void)
 	return IS_ERR(dev) ? PTR_ERR(dev) : 0;
 }
 device_initcall(toshiba_rbtx4927_rtc_init);
+
+static int __init rbtx4927_ne_init(void)
+{
+	static struct resource __initdata res[] = {
+		{
+			.start	= RBTX4927_RTL_8019_BASE,
+			.end	= RBTX4927_RTL_8019_BASE + 0x20 - 1,
+			.flags	= IORESOURCE_IO,
+		}, {
+			.start	= RBTX4927_RTL_8019_IRQ,
+			.flags	= IORESOURCE_IRQ,
+		}
+	};
+	struct platform_device *dev =
+		platform_device_register_simple("ne", -1,
+						res, ARRAY_SIZE(res));
+	return IS_ERR(dev) ? PTR_ERR(dev) : 0;
+}
+device_initcall(rbtx4927_ne_init);
diff --git a/arch/mips/tx4938/toshiba_rbtx4938/setup.c b/arch/mips/tx4938/toshiba_rbtx4938/setup.c
index 66163ba..f5d1ce7 100644
--- a/arch/mips/tx4938/toshiba_rbtx4938/setup.c
+++ b/arch/mips/tx4938/toshiba_rbtx4938/setup.c
@@ -20,6 +20,7 @@
 #include <linux/console.h>
 #include <linux/pci.h>
 #include <linux/pm.h>
+#include <linux/platform_device.h>
 
 #include <asm/wbflush.h>
 #include <asm/reboot.h>
@@ -1037,3 +1038,22 @@ static int __init tx4938_spi_proc_setup(void)
 
 __initcall(tx4938_spi_proc_setup);
 #endif
+
+static int __init rbtx4938_ne_init(void)
+{
+	struct resource res[] = {
+		{
+			.start	= RBTX4938_RTL_8019_BASE,
+			.end	= RBTX4938_RTL_8019_BASE + 0x20 - 1,
+			.flags	= IORESOURCE_IO,
+		}, {
+			.start	= RBTX4938_RTL_8019_IRQ,
+			.flags	= IORESOURCE_IRQ,
+		}
+	};
+	struct platform_device *dev =
+		platform_device_register_simple("ne", -1,
+						res, ARRAY_SIZE(res));
+	return IS_ERR(dev) ? PTR_ERR(dev) : 0;
+}
+device_initcall(rbtx4938_ne_init);
diff --git a/arch/powerpc/platforms/pasemi/pci.c b/arch/powerpc/platforms/pasemi/pci.c
index 056243d..bbc6dfc 100644
--- a/arch/powerpc/platforms/pasemi/pci.c
+++ b/arch/powerpc/platforms/pasemi/pci.c
@@ -173,19 +173,6 @@ static void __init pas_fixup_phb_resources(void)
 }
 
 
-void __devinit pas_pci_irq_fixup(struct pci_dev *dev)
-{
-	/* DMA is special, 84 interrupts (128 -> 211), all but 128
-	 * need to be mapped by hand here.
-	 */
-	if (dev->vendor == 0x1959 && dev->device == 0xa007) {
-		int i;
-		for (i = 129; i < 212; i++)
-			irq_create_mapping(NULL, i);
-	}
-}
-
-
 void __init pas_pci_init(void)
 {
 	struct device_node *np, *root;
diff --git a/arch/powerpc/platforms/pasemi/setup.c b/arch/powerpc/platforms/pasemi/setup.c
index f88f0ec..5bdd6ab 100644
--- a/arch/powerpc/platforms/pasemi/setup.c
+++ b/arch/powerpc/platforms/pasemi/setup.c
@@ -248,5 +248,4 @@ define_machine(pas) {
 	.calibrate_decr		= generic_calibrate_decr,
 	.progress		= pas_progress,
 	.machine_check_exception = pas_machine_check_handler,
-	.pci_irq_fixup		= pas_pci_irq_fixup,
 };
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 279ec62..b86ccd2 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1104,7 +1104,7 @@ config ETH16I
 
 config NE2000
 	tristate "NE2000/NE1000 support"
-	depends on NET_ISA || (Q40 && m) || M32R
+	depends on NET_ISA || (Q40 && m) || M32R || TOSHIBA_RBTX4927 || TOSHIBA_RBTX4938
 	select CRC32
 	---help---
 	  If you have a network (Ethernet) card of this type, say Y and read
@@ -2488,6 +2488,7 @@ config NETXEN_NIC
 config PASEMI_MAC
 	tristate "PA Semi 1/10Gbit MAC"
 	depends on PPC64 && PCI
+	select PHYLIB
 	help
 	  This driver supports the on-chip 1/10Gbit Ethernet controller on
 	  PA Semi's PWRficient line of chips.
diff --git a/drivers/net/arm/at91_ether.c b/drivers/net/arm/at91_ether.c
index 152fa7a..ef2cc80 100644
--- a/drivers/net/arm/at91_ether.c
+++ b/drivers/net/arm/at91_ether.c
@@ -225,6 +225,16 @@ static irqreturn_t at91ether_phy_interrupt(int irq, void *dev_id)
 		if (!(phy & ((1 << 2) | 1)))
 			goto done;
 	}
+	else if (lp->phy_type == MII_T78Q21x3_ID) {			/* ack interrupt in Teridian PHY */
+		read_phy(lp->phy_address, MII_T78Q21INT_REG, &phy);
+		if (!(phy & ((1 << 2) | 1)))
+			goto done;
+	}
+	else if (lp->phy_type == MII_DP83848_ID) {
+		read_phy(lp->phy_address, MII_DPPHYSTS_REG, &phy);	/* ack interrupt in DP83848 PHY */
+		if (!(phy & (1 << 7)))
+			goto done;
+	}
 
 	update_linkspeed(dev, 0);
 
@@ -280,6 +290,19 @@ static void enable_phyirq(struct net_device *dev)
 		dsintr = (1 << 10) | ( 1 << 8);
 		write_phy(lp->phy_address, MII_TPISTATUS, dsintr);
 	}
+	else if (lp->phy_type == MII_T78Q21x3_ID) {	/* for Teridian PHY */
+		read_phy(lp->phy_address, MII_T78Q21INT_REG, &dsintr);
+		dsintr = dsintr | 0x500;		/* set bits 8, 10 */
+		write_phy(lp->phy_address, MII_T78Q21INT_REG, dsintr);
+	}
+	else if (lp->phy_type == MII_DP83848_ID) {	/* National Semiconductor DP83848 PHY */
+		read_phy(lp->phy_address, MII_DPMISR_REG, &dsintr);
+		dsintr = dsintr | 0x3c;			/* set bits 2..5 */
+		write_phy(lp->phy_address, MII_DPMISR_REG, dsintr);
+		read_phy(lp->phy_address, MII_DPMICR_REG, &dsintr);
+		dsintr = dsintr | 0x3;			/* set bits 0,1 */
+		write_phy(lp->phy_address, MII_DPMICR_REG, dsintr);
+	}
 
 	disable_mdi();
 	spin_unlock_irq(&lp->lock);
@@ -323,6 +346,19 @@ static void disable_phyirq(struct net_device *dev)
 		dsintr = ~((1 << 10) | (1 << 8));
 		write_phy(lp->phy_address, MII_TPISTATUS, dsintr);
 	}
+	else if (lp->phy_type == MII_T78Q21x3_ID) {	/* for Teridian PHY */
+		read_phy(lp->phy_address, MII_T78Q21INT_REG, &dsintr);
+		dsintr = dsintr & ~0x500;			/* clear bits 8, 10 */
+		write_phy(lp->phy_address, MII_T78Q21INT_REG, dsintr);
+	}
+	else if (lp->phy_type == MII_DP83848_ID) {	/* National Semiconductor DP83848 PHY */
+		read_phy(lp->phy_address, MII_DPMICR_REG, &dsintr);
+		dsintr = dsintr & ~0x3;				/* clear bits 0, 1 */
+		write_phy(lp->phy_address, MII_DPMICR_REG, dsintr);
+		read_phy(lp->phy_address, MII_DPMISR_REG, &dsintr);
+		dsintr = dsintr & ~0x3c;			/* clear bits 2..5 */
+		write_phy(lp->phy_address, MII_DPMISR_REG, dsintr);
+	}
 
 	disable_mdi();
 	spin_unlock_irq(&lp->lock);
@@ -535,8 +571,8 @@ static void at91ether_sethashtable(struct net_device *dev)
 		mc_filter[bitnr >> 5] |= 1 << (bitnr & 31);
 	}
 
-	at91_emac_write(AT91_EMAC_HSH, mc_filter[0]);
-	at91_emac_write(AT91_EMAC_HSL, mc_filter[1]);
+	at91_emac_write(AT91_EMAC_HSL, mc_filter[0]);
+	at91_emac_write(AT91_EMAC_HSH, mc_filter[1]);
 }
 
 /*
@@ -1062,10 +1098,16 @@ static int __init at91ether_setup(unsigned long phy_type, unsigned short phy_add
 		printk(KERN_INFO "%s: Broadcom BCM5221 PHY\n", dev->name);
 	else if (phy_type == MII_DP83847_ID)
 		printk(KERN_INFO "%s: National Semiconductor DP83847 PHY\n", dev->name);
+	else if (phy_type == MII_DP83848_ID)
+		printk(KERN_INFO "%s: National Semiconductor DP83848 PHY\n", dev->name);
 	else if (phy_type == MII_AC101L_ID)
 		printk(KERN_INFO "%s: Altima AC101L PHY\n", dev->name);
 	else if (phy_type == MII_KS8721_ID)
 		printk(KERN_INFO "%s: Micrel KS8721 PHY\n", dev->name);
+	else if (phy_type == MII_T78Q21x3_ID)
+		printk(KERN_INFO "%s: Teridian 78Q21x3 PHY\n", dev->name);
+	else if (phy_type == MII_LAN83C185_ID)
+		printk(KERN_INFO "%s: SMSC LAN83C185 PHY\n", dev->name);
 
 	return 0;
 }
@@ -1103,8 +1145,11 @@ static int __init at91ether_probe(struct platform_device *pdev)
 			case MII_RTL8201_ID:		/* Realtek RTL8201: PHY_ID1 = 0, PHY_ID2 = 0x8201 */
 			case MII_BCM5221_ID:		/* Broadcom BCM5221: PHY_ID1 = 0x40, PHY_ID2 = 0x61e0 */
 			case MII_DP83847_ID:		/* National Semiconductor DP83847:  */
+			case MII_DP83848_ID:		/* National Semiconductor DP83848:  */
 			case MII_AC101L_ID:		/* Altima AC101L: PHY_ID1 = 0x22, PHY_ID2 = 0x5520 */
 			case MII_KS8721_ID:		/* Micrel KS8721: PHY_ID1 = 0x22, PHY_ID2 = 0x1610 */
+			case MII_T78Q21x3_ID:		/* Teridian 78Q21x3: PHY_ID1 = 0x0E, PHY_ID2 = 7237 */
+			case MII_LAN83C185_ID:		/* SMSC LAN83C185: PHY_ID1 = 0x0007, PHY_ID2 = 0xC0A1 */
 				detected = at91ether_setup(phy_id, phy_address, pdev, ether_clk);
 				break;
 		}
diff --git a/drivers/net/arm/at91_ether.h b/drivers/net/arm/at91_ether.h
index b6b665d..a38fd2d 100644
--- a/drivers/net/arm/at91_ether.h
+++ b/drivers/net/arm/at91_ether.h
@@ -17,39 +17,46 @@
 
 
 /* Davicom 9161 PHY */
-#define MII_DM9161_ID	0x0181b880
-#define MII_DM9161A_ID	0x0181b8a0
-
-/* Davicom specific registers */
-#define MII_DSCR_REG	16
-#define MII_DSCSR_REG	17
-#define MII_DSINTR_REG	21
+#define MII_DM9161_ID		0x0181b880
+#define MII_DM9161A_ID		0x0181b8a0
+#define MII_DSCR_REG		16
+#define MII_DSCSR_REG		17
+#define MII_DSINTR_REG		21
 
 /* Intel LXT971A PHY */
-#define MII_LXT971A_ID	0x001378E0
-
-/* Intel specific registers */
-#define MII_ISINTE_REG	18
-#define MII_ISINTS_REG	19
-#define MII_LEDCTRL_REG	20
+#define MII_LXT971A_ID		0x001378E0
+#define MII_ISINTE_REG		18
+#define MII_ISINTS_REG		19
+#define MII_LEDCTRL_REG		20
 
 /* Realtek RTL8201 PHY */
-#define MII_RTL8201_ID	0x00008200
+#define MII_RTL8201_ID		0x00008200
 
 /* Broadcom BCM5221 PHY */
-#define MII_BCM5221_ID	0x004061e0
-
-/* Broadcom specific registers */
-#define MII_BCMINTR_REG	26
+#define MII_BCM5221_ID		0x004061e0
+#define MII_BCMINTR_REG		26
 
 /* National Semiconductor DP83847 */
-#define MII_DP83847_ID	0x20005c30
+#define MII_DP83847_ID		0x20005c30
+
+/* National Semiconductor DP83848 */
+#define MII_DP83848_ID		0x20005c90
+#define MII_DPPHYSTS_REG	16
+#define MII_DPMICR_REG		17
+#define MII_DPMISR_REG		18
 
 /* Altima AC101L PHY */
-#define MII_AC101L_ID	0x00225520
+#define MII_AC101L_ID		0x00225520
 
 /* Micrel KS8721 PHY */
-#define MII_KS8721_ID	0x00221610
+#define MII_KS8721_ID		0x00221610
+
+/* Teridian 78Q2123/78Q2133 */
+#define MII_T78Q21x3_ID		0x000e7230
+#define MII_T78Q21INT_REG	17
+
+/* SMSC LAN83C185 */
+#define MII_LAN83C185_ID	0x0007C0A0
 
 /* ........................................................................ */
 
diff --git a/drivers/net/atl1/atl1_ethtool.c b/drivers/net/atl1/atl1_ethtool.c
index c11c277..1f616c5 100644
--- a/drivers/net/atl1/atl1_ethtool.c
+++ b/drivers/net/atl1/atl1_ethtool.c
@@ -156,8 +156,7 @@ static int atl1_set_settings(struct net_device *netdev,
 	u16 old_media_type = hw->media_type;
 
 	if (netif_running(adapter->netdev)) {
-		printk(KERN_DEBUG "%s: ethtool shutting down adapter\n",
-			atl1_driver_name);
+		dev_dbg(&adapter->pdev->dev, "ethtool shutting down adapter\n");
 		atl1_down(adapter);
 	}
 
@@ -166,9 +165,8 @@ static int atl1_set_settings(struct net_device *netdev,
 	else {
 		if (ecmd->speed == SPEED_1000) {
 			if (ecmd->duplex != DUPLEX_FULL) {
-				printk(KERN_WARNING
-				       "%s: can't force to 1000M half duplex\n",
-					atl1_driver_name);
+				dev_warn(&adapter->pdev->dev,
+					"can't force to 1000M half duplex\n");
 				ret_val = -EINVAL;
 				goto exit_sset;
 			}
@@ -206,9 +204,8 @@ static int atl1_set_settings(struct net_device *netdev,
 	}
 	if (atl1_phy_setup_autoneg_adv(hw)) {
 		ret_val = -EINVAL;
-		printk(KERN_WARNING
-			"%s: invalid ethtool speed/duplex setting\n",
-			atl1_driver_name);
+		dev_warn(&adapter->pdev->dev,
+			"invalid ethtool speed/duplex setting\n");
 		goto exit_sset;
 	}
 	if (hw->media_type == MEDIA_TYPE_AUTO_SENSOR ||
@@ -239,12 +236,10 @@ exit_sset:
 		hw->media_type = old_media_type;
 
 	if (netif_running(adapter->netdev)) {
-		printk(KERN_DEBUG "%s: ethtool starting adapter\n",
-			atl1_driver_name);
+		dev_dbg(&adapter->pdev->dev, "ethtool starting adapter\n");
 		atl1_up(adapter);
 	} else if (!ret_val) {
-		printk(KERN_DEBUG "%s: ethtool resetting adapter\n",
-			atl1_driver_name);
+		dev_dbg(&adapter->pdev->dev, "ethtool resetting adapter\n");
 		atl1_reset(adapter);
 	}
 	return ret_val;
diff --git a/drivers/net/atl1/atl1_hw.c b/drivers/net/atl1/atl1_hw.c
index 69482e0..ef886bd 100644
--- a/drivers/net/atl1/atl1_hw.c
+++ b/drivers/net/atl1/atl1_hw.c
@@ -2,20 +2,20 @@
  * Copyright(c) 2005 - 2006 Attansic Corporation. All rights reserved.
  * Copyright(c) 2006 Chris Snook <csnook@redhat.com>
  * Copyright(c) 2006 Jay Cliburn <jcliburn@gmail.com>
- * 
+ *
  * Derived from Intel e1000 driver
  * Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
- * 
+ *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License as published by the Free
  * Software Foundation; either version 2 of the License, or (at your option)
  * any later version.
- * 
+ *
  * This program is distributed in the hope that it will be useful, but WITHOUT
  * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
  * more details.
- * 
+ *
  * You should have received a copy of the GNU General Public License along with
  * this program; if not, write to the Free Software Foundation, Inc., 59
  * Temple Place - Suite 330, Boston, MA  02111-1307, USA.
@@ -38,12 +38,13 @@
  */
 s32 atl1_reset_hw(struct atl1_hw *hw)
 {
+	struct pci_dev *pdev = hw->back->pdev;
 	u32 icr;
 	int i;
 
-	/* 
+	/*
 	 * Clear Interrupt mask to stop board from generating
-	 * interrupts & Clear any pending interrupt events 
+	 * interrupts & Clear any pending interrupt events
 	 */
 	/*
 	 * iowrite32(0, hw->hw_addr + REG_IMR);
@@ -74,7 +75,7 @@ s32 atl1_reset_hw(struct atl1_hw *hw)
 	}
 
 	if (icr) {
-		printk (KERN_DEBUG "icr = %x\n", icr); 
+		dev_dbg(&pdev->dev, "ICR = 0x%x\n", icr);
 		return icr;
 	}
 
@@ -136,8 +137,8 @@ s32 atl1_read_phy_reg(struct atl1_hw *hw, u16 reg_addr, u16 *phy_data)
 	int i;
 
 	val = ((u32) (reg_addr & MDIO_REG_ADDR_MASK)) << MDIO_REG_ADDR_SHIFT |
-	    	MDIO_START | MDIO_SUP_PREAMBLE | MDIO_RW | MDIO_CLK_25_4 <<
- 		MDIO_CLK_SEL_SHIFT;
+		MDIO_START | MDIO_SUP_PREAMBLE | MDIO_RW | MDIO_CLK_25_4 <<
+		MDIO_CLK_SEL_SHIFT;
 	iowrite32(val, hw->hw_addr + REG_MDIO_CTRL);
 	ioread32(hw->hw_addr + REG_MDIO_CTRL);
 
@@ -204,7 +205,7 @@ static bool atl1_spi_read(struct atl1_hw *hw, u32 addr, u32 *buf)
 
 /*
  * get_permanent_address
- * return 0 if get valid mac address, 
+ * return 0 if get valid mac address,
  */
 static int atl1_get_permanent_address(struct atl1_hw *hw)
 {
@@ -301,7 +302,7 @@ static int atl1_get_permanent_address(struct atl1_hw *hw)
 }
 
 /*
- * Reads the adapter's MAC address from the EEPROM 
+ * Reads the adapter's MAC address from the EEPROM
  * hw - Struct containing variables accessed by shared code
  */
 s32 atl1_read_mac_addr(struct atl1_hw *hw)
@@ -437,6 +438,7 @@ s32 atl1_phy_enter_power_saving(struct atl1_hw *hw)
  */
 static s32 atl1_phy_reset(struct atl1_hw *hw)
 {
+	struct pci_dev *pdev = hw->back->pdev;
 	s32 ret_val;
 	u16 phy_data;
 
@@ -468,8 +470,7 @@ static s32 atl1_phy_reset(struct atl1_hw *hw)
 		u32 val;
 		int i;
 		/* pcie serdes link may be down! */
-		printk(KERN_DEBUG "%s: autoneg caused pcie phy link down\n", 
-			atl1_driver_name);
+		dev_dbg(&pdev->dev, "pcie phy link down\n");
 
 		for (i = 0; i < 25; i++) {
 			msleep(1);
@@ -479,9 +480,7 @@ static s32 atl1_phy_reset(struct atl1_hw *hw)
 		}
 
 		if ((val & (MDIO_START | MDIO_BUSY)) != 0) {
-			printk(KERN_WARNING 
-				"%s: pcie link down at least for 25ms\n", 
-				atl1_driver_name);
+			dev_warn(&pdev->dev, "pcie link down at least 25ms\n");
 			return ret_val;
 		}
 	}
@@ -571,6 +570,7 @@ s32 atl1_phy_setup_autoneg_adv(struct atl1_hw *hw)
  */
 static s32 atl1_setup_link(struct atl1_hw *hw)
 {
+	struct pci_dev *pdev = hw->back->pdev;
 	s32 ret_val;
 
 	/*
@@ -581,15 +581,13 @@ static s32 atl1_setup_link(struct atl1_hw *hw)
 	 */
 	ret_val = atl1_phy_setup_autoneg_adv(hw);
 	if (ret_val) {
-		printk(KERN_DEBUG "%s: error setting up autonegotiation\n", 
-			atl1_driver_name);
+		dev_dbg(&pdev->dev, "error setting up autonegotiation\n");
 		return ret_val;
 	}
 	/* SW.Reset , En-Auto-Neg if needed */
 	ret_val = atl1_phy_reset(hw);
 	if (ret_val) {
-		printk(KERN_DEBUG "%s: error resetting the phy\n", 
-			atl1_driver_name);
+		dev_dbg(&pdev->dev, "error resetting phy\n");
 		return ret_val;
 	}
 	hw->phy_configured = true;
@@ -631,7 +629,7 @@ static void atl1_init_flash_opcode(struct atl1_hw *hw)
  * Performs basic configuration of the adapter.
  * hw - Struct containing variables accessed by shared code
  * Assumes that the controller has previously been reset and is in a
- * post-reset uninitialized state. Initializes multicast table, 
+ * post-reset uninitialized state. Initializes multicast table,
  * and  Calls routines to setup link
  * Leaves the transmit and receive units disabled and uninitialized.
  */
@@ -669,6 +667,7 @@ s32 atl1_init_hw(struct atl1_hw *hw)
  */
 s32 atl1_get_speed_and_duplex(struct atl1_hw *hw, u16 *speed, u16 *duplex)
 {
+	struct pci_dev *pdev = hw->back->pdev;
 	s32 ret_val;
 	u16 phy_data;
 
@@ -691,8 +690,7 @@ s32 atl1_get_speed_and_duplex(struct atl1_hw *hw, u16 *speed, u16 *duplex)
 		*speed = SPEED_10;
 		break;
 	default:
-		printk(KERN_DEBUG "%s: error getting speed\n", 
-			atl1_driver_name);
+		dev_dbg(&pdev->dev, "error getting speed\n");
 		return ATL1_ERR_PHY_SPEED;
 		break;
 	}
diff --git a/drivers/net/atl1/atl1_main.c b/drivers/net/atl1/atl1_main.c
index 4b1d4d1..d28f88b 100644
--- a/drivers/net/atl1/atl1_main.c
+++ b/drivers/net/atl1/atl1_main.c
@@ -188,8 +188,7 @@ s32 atl1_setup_ring_resources(struct atl1_adapter *adapter)
 	size = sizeof(struct atl1_buffer) * (tpd_ring->count + rfd_ring->count);
 	tpd_ring->buffer_info = kzalloc(size, GFP_KERNEL);
 	if (unlikely(!tpd_ring->buffer_info)) {
-		printk(KERN_WARNING "%s: kzalloc failed , size = D%d\n",
-			atl1_driver_name, size);
+		dev_err(&pdev->dev, "kzalloc failed , size = D%d\n", size);
 		goto err_nomem;
 	}
 	rfd_ring->buffer_info =
@@ -207,9 +206,7 @@ s32 atl1_setup_ring_resources(struct atl1_adapter *adapter)
 	ring_header->desc = pci_alloc_consistent(pdev, ring_header->size,
 						&ring_header->dma);
 	if (unlikely(!ring_header->desc)) {
-		printk(KERN_WARNING
-			"%s: pci_alloc_consistent failed, size = D%d\n",
-			atl1_driver_name, size);
+		dev_err(&pdev->dev, "pci_alloc_consistent failed\n");
 		goto err_nomem;
 	}
 
@@ -373,8 +370,7 @@ static void atl1_rx_checksum(struct atl1_adapter *adapter,
 		if (rrd->err_flg & (ERR_FLAG_CRC | ERR_FLAG_TRUNC |
 					ERR_FLAG_CODE | ERR_FLAG_OV)) {
 			adapter->hw_csum_err++;
-			printk(KERN_DEBUG "%s: rx checksum error\n",
-				atl1_driver_name);
+			dev_dbg(&adapter->pdev->dev, "rx checksum error\n");
 			return;
 		}
 	}
@@ -393,8 +389,9 @@ static void atl1_rx_checksum(struct atl1_adapter *adapter,
 	}
 
 	/* IPv4, but hardware thinks its checksum is wrong */
-	printk(KERN_DEBUG "%s: hw csum wrong pkt_flag:%x, err_flag:%x\n",
-		atl1_driver_name, rrd->pkt_flg, rrd->err_flg);
+	dev_dbg(&adapter->pdev->dev,
+		"hw csum wrong, pkt_flag:%x, err_flag:%x\n",
+		rrd->pkt_flg, rrd->err_flg);
 	skb->ip_summed = CHECKSUM_COMPLETE;
 	skb->csum = htons(rrd->xsz.xsum_sz.rx_chksum);
 	adapter->hw_csum_err++;
@@ -507,14 +504,13 @@ chk_rrd:
 			/* rrd seems to be bad */
 			if (unlikely(i-- > 0)) {
 				/* rrd may not be DMAed completely */
-				printk(KERN_DEBUG
-					"%s: RRD may not be DMAed completely\n",
-					atl1_driver_name);
+				dev_dbg(&adapter->pdev->dev,
+					"incomplete RRD DMA transfer\n");
 				udelay(1);
 				goto chk_rrd;
 			}
 			/* bad rrd */
-			printk(KERN_DEBUG "%s: bad RRD\n", atl1_driver_name);
+			dev_dbg(&adapter->pdev->dev, "bad RRD\n");
 			/* see if update RFD index */
 			if (rrd->num_buf > 1) {
 				u16 num_buf;
@@ -685,8 +681,8 @@ static void atl1_check_for_link(struct atl1_adapter *adapter)
 	/* notify upper layer link down ASAP */
 	if (!(phy_data & BMSR_LSTATUS)) {	/* Link Down */
 		if (netif_carrier_ok(netdev)) {	/* old link state: Up */
-			printk(KERN_INFO "%s: %s link is down\n",
-			       atl1_driver_name, netdev->name);
+			dev_info(&adapter->pdev->dev, "%s link is down\n",
+				netdev->name);
 			adapter->link_speed = SPEED_0;
 			netif_carrier_off(netdev);
 			netif_stop_queue(netdev);
@@ -731,8 +727,8 @@ static irqreturn_t atl1_intr(int irq, void *data)
 
 		/* check if PCIE PHY Link down */
 		if (status & ISR_PHY_LINKDOWN) {
-			printk(KERN_DEBUG "%s: pcie phy link down %x\n",
-				atl1_driver_name, status);
+			dev_dbg(&adapter->pdev->dev, "pcie phy link down %x\n",
+				status);
 			if (netif_running(adapter->netdev)) {	/* reset MAC */
 				iowrite32(0, adapter->hw.hw_addr + REG_IMR);
 				schedule_work(&adapter->pcie_dma_to_rst_task);
@@ -742,9 +738,9 @@ static irqreturn_t atl1_intr(int irq, void *data)
 
 		/* check if DMA read/write error ? */
 		if (status & (ISR_DMAR_TO_RST | ISR_DMAW_TO_RST)) {
-			printk(KERN_DEBUG
-				"%s: pcie DMA r/w error (status = 0x%x)\n",
-				atl1_driver_name, status);
+			dev_dbg(&adapter->pdev->dev,
+				"pcie DMA r/w error (status = 0x%x)\n",
+				status);
 			iowrite32(0, adapter->hw.hw_addr + REG_IMR);
 			schedule_work(&adapter->pcie_dma_to_rst_task);
 			return IRQ_HANDLED;
@@ -762,14 +758,13 @@ static irqreturn_t atl1_intr(int irq, void *data)
 
 		/* rx exception */
 		if (unlikely(status & (ISR_RXF_OV | ISR_RFD_UNRUN |
+			ISR_RRD_OV | ISR_HOST_RFD_UNRUN |
+			ISR_HOST_RRD_OV | ISR_CMB_RX))) {
+			if (status & (ISR_RXF_OV | ISR_RFD_UNRUN |
 				ISR_RRD_OV | ISR_HOST_RFD_UNRUN |
-				ISR_HOST_RRD_OV | ISR_CMB_RX))) {
-			if (status &
-			    (ISR_RXF_OV | ISR_RFD_UNRUN | ISR_RRD_OV |
-			     ISR_HOST_RFD_UNRUN | ISR_HOST_RRD_OV))
-				printk(KERN_INFO
-					"%s: rx exception: status = 0x%x\n",
-					atl1_driver_name, status);
+				ISR_HOST_RRD_OV))
+				dev_dbg(&adapter->pdev->dev,
+					"rx exception, ISR = 0x%x\n", status);
 			atl1_intr_rx(adapter);
 		}
 
@@ -874,8 +869,7 @@ static u32 atl1_check_link(struct atl1_adapter *adapter)
 	atl1_read_phy_reg(hw, MII_BMSR, &phy_data);
 	if (!(phy_data & BMSR_LSTATUS)) {	/* link down */
 		if (netif_carrier_ok(netdev)) {	/* old link state: Up */
-			printk(KERN_INFO "%s: link is down\n",
-				atl1_driver_name);
+			dev_info(&adapter->pdev->dev, "link is down\n");
 			adapter->link_speed = SPEED_0;
 			netif_carrier_off(netdev);
 			netif_stop_queue(netdev);
@@ -918,11 +912,11 @@ static u32 atl1_check_link(struct atl1_adapter *adapter)
 			adapter->link_speed = speed;
 			adapter->link_duplex = duplex;
 			atl1_setup_mac_ctrl(adapter);
-			printk(KERN_INFO "%s: %s link is up %d Mbps %s\n",
-			       atl1_driver_name, netdev->name,
-			       adapter->link_speed,
-			       adapter->link_duplex ==
-			       FULL_DUPLEX ? "full duplex" : "half duplex");
+			dev_info(&adapter->pdev->dev,
+				"%s link is up %d Mbps %s\n",
+				netdev->name, adapter->link_speed,
+				adapter->link_duplex == FULL_DUPLEX ?
+				"full duplex" : "half duplex");
 		}
 		if (!netif_carrier_ok(netdev)) {	/* Link down -> Up */
 			netif_carrier_on(netdev);
@@ -1330,8 +1324,8 @@ static int atl1_tx_csum(struct atl1_adapter *adapter, struct sk_buff *skb,
 		cso = skb_transport_offset(skb);
 		css = cso + skb->csum_offset;
 		if (unlikely(cso & 0x1)) {
-			printk(KERN_DEBUG "%s: payload offset != even number\n",
-				atl1_driver_name);
+			dev_dbg(&adapter->pdev->dev,
+				"payload offset not an even number\n");
 			return -1;
 		}
 		csum->csumpl |= (cso & CSUM_PARAM_PLOADOFFSET_MASK) <<
@@ -1579,7 +1573,7 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	if (!spin_trylock(&adapter->lock)) {
 		/* Can't get lock - tell upper layer to requeue */
 		local_irq_restore(flags);
-		printk(KERN_DEBUG "%s: TX locked\n", atl1_driver_name);
+		dev_dbg(&adapter->pdev->dev, "tx locked\n");
 		return NETDEV_TX_LOCKED;
 	}
 
@@ -1587,7 +1581,7 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		/* not enough descriptors */
 		netif_stop_queue(netdev);
 		spin_unlock_irqrestore(&adapter->lock, flags);
-		printk(KERN_DEBUG "%s: TX busy\n", atl1_driver_name);
+		dev_dbg(&adapter->pdev->dev, "tx busy\n");
 		return NETDEV_TX_BUSY;
 	}
 
@@ -1841,8 +1835,7 @@ static int atl1_change_mtu(struct net_device *netdev, int new_mtu)
 
 	if ((max_frame < MINIMUM_ETHERNET_FRAME_SIZE) ||
 	    (max_frame > MAX_JUMBO_FRAME_SIZE)) {
-		printk(KERN_WARNING "%s: invalid MTU setting\n",
-			atl1_driver_name);
+		dev_warn(&adapter->pdev->dev, "invalid MTU setting\n");
 		return -EINVAL;
 	}
 
@@ -2136,9 +2129,7 @@ static int __devinit atl1_probe(struct pci_dev *pdev,
 	if (err) {
 		err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
 		if (err) {
-			printk(KERN_DEBUG
-				"%s: no usable DMA configuration, aborting\n",
-				atl1_driver_name);
+			dev_err(&pdev->dev, "no usable DMA configuration\n");
 			goto err_dma;
 		}
 		pci_using_64 = false;
@@ -2175,7 +2166,9 @@ static int __devinit atl1_probe(struct pci_dev *pdev,
 		goto err_pci_iomap;
 	}
 	/* get device revision number */
-	adapter->hw.dev_rev = ioread16(adapter->hw.hw_addr + (REG_MASTER_CTRL + 2));
+	adapter->hw.dev_rev = ioread16(adapter->hw.hw_addr +
+					(REG_MASTER_CTRL + 2));
+	dev_info(&pdev->dev, "version %s\n", DRIVER_VERSION);
 
 	/* set default ring resource counts */
 	adapter->rfd_ring.count = adapter->rrd_ring.count = ATL1_DEFAULT_RFD;
@@ -2466,8 +2459,6 @@ static void __exit atl1_exit_module(void)
  */
 static int __init atl1_init_module(void)
 {
-	printk(KERN_INFO "%s - version %s\n", atl1_driver_string, DRIVER_VERSION);
-	printk(KERN_INFO "%s\n", atl1_copyright);
 	return pci_register_driver(&atl1_driver);
 }
 
diff --git a/drivers/net/atl1/atl1_param.c b/drivers/net/atl1/atl1_param.c
index bcd0bd8..4246bb9 100644
--- a/drivers/net/atl1/atl1_param.c
+++ b/drivers/net/atl1/atl1_param.c
@@ -23,6 +23,7 @@
 
 #include <linux/types.h>
 #include <linux/moduleparam.h>
+#include <linux/pci.h>
 #include "atl1.h"
 
 /*
@@ -93,7 +94,7 @@ struct atl1_option {
 	} arg;
 };
 
-static int __devinit atl1_validate_option(int *value, struct atl1_option *opt)
+static int __devinit atl1_validate_option(int *value, struct atl1_option *opt, struct pci_dev *pdev)
 {
 	if (*value == OPTION_UNSET) {
 		*value = opt->def;
@@ -104,19 +105,17 @@ static int __devinit atl1_validate_option(int *value, struct atl1_option *opt)
 	case enable_option:
 		switch (*value) {
 		case OPTION_ENABLED:
-			printk(KERN_INFO "%s: %s Enabled\n", atl1_driver_name,
-				opt->name);
+			dev_info(&pdev->dev, "%s enabled\n", opt->name);
 			return 0;
 		case OPTION_DISABLED:
-			printk(KERN_INFO "%s: %s Disabled\n", atl1_driver_name,
-				opt->name);
+			dev_info(&pdev->dev, "%s disabled\n", opt->name);
 			return 0;
 		}
 		break;
 	case range_option:
 		if (*value >= opt->arg.r.min && *value <= opt->arg.r.max) {
-			printk(KERN_INFO "%s: %s set to %i\n",
-				atl1_driver_name, opt->name, *value);
+			dev_info(&pdev->dev, "%s set to %i\n", opt->name,
+				*value);
 			return 0;
 		}
 		break;
@@ -128,8 +127,8 @@ static int __devinit atl1_validate_option(int *value, struct atl1_option *opt)
 				ent = &opt->arg.l.p[i];
 				if (*value == ent->i) {
 					if (ent->str[0] != '\0')
-						printk(KERN_INFO "%s: %s\n",
-						       atl1_driver_name, ent->str);
+						dev_info(&pdev->dev, "%s\n",
+							ent->str);
 					return 0;
 				}
 			}
@@ -140,8 +139,8 @@ static int __devinit atl1_validate_option(int *value, struct atl1_option *opt)
 		break;
 	}
 
-	printk(KERN_INFO "%s: invalid %s specified (%i) %s\n",
-	       atl1_driver_name, opt->name, *value, opt->err);
+	dev_info(&pdev->dev, "invalid %s specified (%i) %s\n",
+		opt->name, *value, opt->err);
 	*value = opt->def;
 	return -1;
 }
@@ -157,12 +156,11 @@ static int __devinit atl1_validate_option(int *value, struct atl1_option *opt)
  */
 void __devinit atl1_check_options(struct atl1_adapter *adapter)
 {
+	struct pci_dev *pdev = adapter->pdev;
 	int bd = adapter->bd_number;
 	if (bd >= ATL1_MAX_NIC) {
-		printk(KERN_NOTICE "%s: warning: no configuration for board #%i\n",
-			atl1_driver_name, bd);
-		printk(KERN_NOTICE "%s: using defaults for all values\n",
-			atl1_driver_name);
+		dev_notice(&pdev->dev, "no configuration for board#%i\n", bd);
+		dev_notice(&pdev->dev, "using defaults for all values\n");
 	}
 	{			/* Interrupt Moderate Timer */
 		struct atl1_option opt = {
@@ -177,7 +175,7 @@ void __devinit atl1_check_options(struct atl1_adapter *adapter)
 		int val;
 		if (num_int_mod_timer > bd) {
 			val = int_mod_timer[bd];
-			atl1_validate_option(&val, &opt);
+			atl1_validate_option(&val, &opt, pdev);
 			adapter->imt = (u16) val;
 		} else
 			adapter->imt = (u16) (opt.def);
@@ -197,7 +195,7 @@ void __devinit atl1_check_options(struct atl1_adapter *adapter)
 		int val;
 		if (num_flash_vendor > bd) {
 			val = flash_vendor[bd];
-			atl1_validate_option(&val, &opt);
+			atl1_validate_option(&val, &opt, pdev);
 			adapter->hw.flash_vendor = (u8) val;
 		} else
 			adapter->hw.flash_vendor = (u8) (opt.def);
diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index 8cc1174..264fa0e 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -77,9 +77,6 @@
 
 #define DM9000_PHY		0x40	/* PHY address 0x01 */
 
-#define TRUE			1
-#define FALSE			0
-
 #define CARDNAME "dm9000"
 #define PFX CARDNAME ": "
 
@@ -601,7 +598,7 @@ dm9000_probe(struct platform_device *pdev)
 	printk("%s: not found (%d).\n", CARDNAME, ret);
 
 	dm9000_release_board(pdev, db);
-	kfree(ndev);
+	free_netdev(ndev);
 
 	return ret;
 }
@@ -896,7 +893,7 @@ dm9000_rx(struct net_device *dev)
 	struct dm9000_rxhdr rxhdr;
 	struct sk_buff *skb;
 	u8 rxbyte, *rdptr;
-	int GoodPacket;
+	bool GoodPacket;
 	int RxLen;
 
 	/* Check packet ready or not */
@@ -918,7 +915,7 @@ dm9000_rx(struct net_device *dev)
 			return;
 
 		/* A packet ready now  & Get status/length */
-		GoodPacket = TRUE;
+		GoodPacket = true;
 		writeb(DM9000_MRCMD, db->io_addr);
 
 		(db->inblk)(db->io_data, &rxhdr, sizeof(rxhdr));
@@ -927,7 +924,7 @@ dm9000_rx(struct net_device *dev)
 
 		/* Packet Status check */
 		if (RxLen < 0x40) {
-			GoodPacket = FALSE;
+			GoodPacket = false;
 			PRINTK1("Bad Packet received (runt)\n");
 		}
 
@@ -936,7 +933,7 @@ dm9000_rx(struct net_device *dev)
 		}
 
 		if (rxhdr.RxStatus & 0xbf00) {
-			GoodPacket = FALSE;
+			GoodPacket = false;
 			if (rxhdr.RxStatus & 0x100) {
 				PRINTK1("fifo error\n");
 				db->stats.rx_fifo_errors++;
@@ -1193,7 +1190,7 @@ dm9000_drv_remove(struct platform_device *pdev)
 
 	unregister_netdev(ndev);
 	dm9000_release_board(pdev, (board_info_t *) ndev->priv);
-	kfree(ndev);		/* free device structure */
+	free_netdev(ndev);		/* free device structure */
 
 	PRINTK1("clean_module() exit\n");
 
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index c7a5614..7211648 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -1803,10 +1803,10 @@ static inline int ehea_hash_skb(struct sk_buff *skb, int num_qps)
 	u32 tmp;
 
 	if ((skb->protocol == htons(ETH_P_IP)) &&
-	    (skb->nh.iph->protocol == IPPROTO_TCP)) {
-		tcp = (struct tcphdr*)(skb->nh.raw + (skb->nh.iph->ihl * 4));
+	    (ip_hdr(skb)->protocol == IPPROTO_TCP)) {
+		tcp = (struct tcphdr*)(skb_network_header(skb) + (ip_hdr(skb)->ihl * 4));
 		tmp = (tcp->source + (tcp->dest << 16)) % 31;
-		tmp += skb->nh.iph->daddr % 31;
+		tmp += ip_hdr(skb)->daddr % 31;
 		return tmp % num_qps;
 	}
 	else
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 16e3c43..5d14be7 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -290,6 +290,8 @@ MODULE_PARM_DESC(myri10ge_wcfifo, "Enable WC Fifo when WC is enabled\n");
 
 #define myri10ge_pio_copy(to,from,size) __iowrite64_copy(to,from,size/8)
 
+static void myri10ge_set_multicast_list(struct net_device *dev);
+
 static inline void put_be32(__be32 val, __be32 __iomem * p)
 {
 	__raw_writel((__force __u32) val, (__force void __iomem *)p);
@@ -353,6 +355,8 @@ myri10ge_send_cmd(struct myri10ge_priv *mgp, u32 cmd,
 			return 0;
 		} else if (result == MXGEFW_CMD_UNKNOWN) {
 			return -ENOSYS;
+		} else if (result == MXGEFW_CMD_ERROR_UNALIGNED) {
+			return -E2BIG;
 		} else {
 			dev_err(&mgp->pdev->dev,
 				"command %d failed, result = %d\n",
@@ -712,14 +716,78 @@ myri10ge_change_promisc(struct myri10ge_priv *mgp, int promisc, int atomic)
 		       mgp->dev->name);
 }
 
-static int myri10ge_reset(struct myri10ge_priv *mgp)
+static int myri10ge_dma_test(struct myri10ge_priv *mgp, int test_type)
 {
 	struct myri10ge_cmd cmd;
 	int status;
-	size_t bytes;
 	u32 len;
 	struct page *dmatest_page;
 	dma_addr_t dmatest_bus;
+	char *test = " ";
+
+	dmatest_page = alloc_page(GFP_KERNEL);
+	if (!dmatest_page)
+		return -ENOMEM;
+	dmatest_bus = pci_map_page(mgp->pdev, dmatest_page, 0, PAGE_SIZE,
+				   DMA_BIDIRECTIONAL);
+
+	/* Run a small DMA test.
+	 * The magic multipliers to the length tell the firmware
+	 * to do DMA read, write, or read+write tests.  The
+	 * results are returned in cmd.data0.  The upper 16
+	 * bits or the return is the number of transfers completed.
+	 * The lower 16 bits is the time in 0.5us ticks that the
+	 * transfers took to complete.
+	 */
+
+	len = mgp->tx.boundary;
+
+	cmd.data0 = MYRI10GE_LOWPART_TO_U32(dmatest_bus);
+	cmd.data1 = MYRI10GE_HIGHPART_TO_U32(dmatest_bus);
+	cmd.data2 = len * 0x10000;
+	status = myri10ge_send_cmd(mgp, test_type, &cmd, 0);
+	if (status != 0) {
+		test = "read";
+		goto abort;
+	}
+	mgp->read_dma = ((cmd.data0 >> 16) * len * 2) / (cmd.data0 & 0xffff);
+	cmd.data0 = MYRI10GE_LOWPART_TO_U32(dmatest_bus);
+	cmd.data1 = MYRI10GE_HIGHPART_TO_U32(dmatest_bus);
+	cmd.data2 = len * 0x1;
+	status = myri10ge_send_cmd(mgp, test_type, &cmd, 0);
+	if (status != 0) {
+		test = "write";
+		goto abort;
+	}
+	mgp->write_dma = ((cmd.data0 >> 16) * len * 2) / (cmd.data0 & 0xffff);
+
+	cmd.data0 = MYRI10GE_LOWPART_TO_U32(dmatest_bus);
+	cmd.data1 = MYRI10GE_HIGHPART_TO_U32(dmatest_bus);
+	cmd.data2 = len * 0x10001;
+	status = myri10ge_send_cmd(mgp, test_type, &cmd, 0);
+	if (status != 0) {
+		test = "read/write";
+		goto abort;
+	}
+	mgp->read_write_dma = ((cmd.data0 >> 16) * len * 2 * 2) /
+	    (cmd.data0 & 0xffff);
+
+abort:
+	pci_unmap_page(mgp->pdev, dmatest_bus, PAGE_SIZE, DMA_BIDIRECTIONAL);
+	put_page(dmatest_page);
+
+	if (status != 0 && test_type != MXGEFW_CMD_UNALIGNED_TEST)
+		dev_warn(&mgp->pdev->dev, "DMA %s benchmark failed: %d\n",
+			 test, status);
+
+	return status;
+}
+
+static int myri10ge_reset(struct myri10ge_priv *mgp)
+{
+	struct myri10ge_cmd cmd;
+	int status;
+	size_t bytes;
 
 	/* try to send a reset command to the card to see if it
 	 * is alive */
@@ -729,11 +797,8 @@ static int myri10ge_reset(struct myri10ge_priv *mgp)
 		dev_err(&mgp->pdev->dev, "failed reset\n");
 		return -ENXIO;
 	}
-	dmatest_page = alloc_page(GFP_KERNEL);
-	if (!dmatest_page)
-		return -ENOMEM;
-	dmatest_bus = pci_map_page(mgp->pdev, dmatest_page, 0, PAGE_SIZE,
-				   DMA_BIDIRECTIONAL);
+
+	(void)myri10ge_dma_test(mgp, MXGEFW_DMA_TEST);
 
 	/* Now exchange information about interrupts  */
 
@@ -761,52 +826,6 @@ static int myri10ge_reset(struct myri10ge_priv *mgp)
 	}
 	put_be32(htonl(mgp->intr_coal_delay), mgp->intr_coal_delay_ptr);
 
-	/* Run a small DMA test.
-	 * The magic multipliers to the length tell the firmware
-	 * to do DMA read, write, or read+write tests.  The
-	 * results are returned in cmd.data0.  The upper 16
-	 * bits or the return is the number of transfers completed.
-	 * The lower 16 bits is the time in 0.5us ticks that the
-	 * transfers took to complete.
-	 */
-
-	len = mgp->tx.boundary;
-
-	cmd.data0 = MYRI10GE_LOWPART_TO_U32(dmatest_bus);
-	cmd.data1 = MYRI10GE_HIGHPART_TO_U32(dmatest_bus);
-	cmd.data2 = len * 0x10000;
-	status = myri10ge_send_cmd(mgp, MXGEFW_DMA_TEST, &cmd, 0);
-	if (status == 0)
-		mgp->read_dma = ((cmd.data0 >> 16) * len * 2) /
-		    (cmd.data0 & 0xffff);
-	else
-		dev_warn(&mgp->pdev->dev, "DMA read benchmark failed: %d\n",
-			 status);
-	cmd.data0 = MYRI10GE_LOWPART_TO_U32(dmatest_bus);
-	cmd.data1 = MYRI10GE_HIGHPART_TO_U32(dmatest_bus);
-	cmd.data2 = len * 0x1;
-	status = myri10ge_send_cmd(mgp, MXGEFW_DMA_TEST, &cmd, 0);
-	if (status == 0)
-		mgp->write_dma = ((cmd.data0 >> 16) * len * 2) /
-		    (cmd.data0 & 0xffff);
-	else
-		dev_warn(&mgp->pdev->dev, "DMA write benchmark failed: %d\n",
-			 status);
-
-	cmd.data0 = MYRI10GE_LOWPART_TO_U32(dmatest_bus);
-	cmd.data1 = MYRI10GE_HIGHPART_TO_U32(dmatest_bus);
-	cmd.data2 = len * 0x10001;
-	status = myri10ge_send_cmd(mgp, MXGEFW_DMA_TEST, &cmd, 0);
-	if (status == 0)
-		mgp->read_write_dma = ((cmd.data0 >> 16) * len * 2 * 2) /
-		    (cmd.data0 & 0xffff);
-	else
-		dev_warn(&mgp->pdev->dev,
-			 "DMA read/write benchmark failed: %d\n", status);
-
-	pci_unmap_page(mgp->pdev, dmatest_bus, PAGE_SIZE, DMA_BIDIRECTIONAL);
-	put_page(dmatest_page);
-
 	memset(mgp->rx_done.entry, 0, bytes);
 
 	/* reset mcp/driver shared state back to 0 */
@@ -820,10 +839,8 @@ static int myri10ge_reset(struct myri10ge_priv *mgp)
 	mgp->rx_done.cnt = 0;
 	mgp->link_changes = 0;
 	status = myri10ge_update_mac_address(mgp, mgp->dev->dev_addr);
-	myri10ge_change_promisc(mgp, 0, 0);
 	myri10ge_change_pause(mgp, mgp->pause);
-	if (mgp->adopted_rx_filter_bug)
-		(void)myri10ge_send_cmd(mgp, MXGEFW_ENABLE_ALLMULTI, &cmd, 1);
+	myri10ge_set_multicast_list(mgp->dev);
 	return status;
 }
 
@@ -1355,7 +1372,9 @@ static const char myri10ge_gstrings_stats[][ETH_GSTRING_LEN] = {
 	"tx_req", "tx_done", "rx_small_cnt", "rx_big_cnt",
 	"wake_queue", "stop_queue", "watchdog_resets", "tx_linearized",
 	"link_changes", "link_up", "dropped_link_overflow",
-	"dropped_link_error_or_filtered", "dropped_multicast_filtered",
+	"dropped_link_error_or_filtered",
+	"dropped_pause", "dropped_bad_phy", "dropped_bad_crc32",
+	"dropped_unicast_filtered", "dropped_multicast_filtered",
 	"dropped_runt", "dropped_overrun", "dropped_no_small_buffer",
 	"dropped_no_big_buffer"
 };
@@ -1412,6 +1431,11 @@ myri10ge_get_ethtool_stats(struct net_device *netdev,
 	data[i++] = (unsigned int)ntohl(mgp->fw_stats->dropped_link_overflow);
 	data[i++] =
 	    (unsigned int)ntohl(mgp->fw_stats->dropped_link_error_or_filtered);
+	data[i++] = (unsigned int)ntohl(mgp->fw_stats->dropped_pause);
+	data[i++] = (unsigned int)ntohl(mgp->fw_stats->dropped_bad_phy);
+	data[i++] = (unsigned int)ntohl(mgp->fw_stats->dropped_bad_crc32);
+	data[i++] =
+	    (unsigned int)ntohl(mgp->fw_stats->dropped_unicast_filtered);
 	data[i++] =
 	    (unsigned int)ntohl(mgp->fw_stats->dropped_multicast_filtered);
 	data[i++] = (unsigned int)ntohl(mgp->fw_stats->dropped_runt);
@@ -2276,7 +2300,7 @@ static void myri10ge_set_multicast_list(struct net_device *dev)
 	myri10ge_change_promisc(mgp, dev->flags & IFF_PROMISC, 1);
 
 	/* This firmware is known to not support multicast */
-	if (!mgp->fw_multicast_support || mgp->adopted_rx_filter_bug)
+	if (!mgp->fw_multicast_support)
 		return;
 
 	/* Disable multicast filtering */
@@ -2288,7 +2312,7 @@ static void myri10ge_set_multicast_list(struct net_device *dev)
 		goto abort;
 	}
 
-	if (dev->flags & IFF_ALLMULTI) {
+	if ((dev->flags & IFF_ALLMULTI) || mgp->adopted_rx_filter_bug) {
 		/* request to disable multicast filtering, so quit here */
 		return;
 	}
@@ -2461,8 +2485,6 @@ static void myri10ge_enable_ecrc(struct myri10ge_priv *mgp)
 	err_cap |= PCI_ERR_CAP_ECRC_GENE;
 	pci_write_config_dword(bridge, cap + PCI_ERR_CAP, err_cap);
 	dev_info(dev, "Enabled ECRC on upstream bridge %s\n", pci_name(bridge));
-	mgp->tx.boundary = 4096;
-	mgp->fw_name = myri10ge_fw_aligned;
 }
 
 /*
@@ -2484,22 +2506,70 @@ static void myri10ge_enable_ecrc(struct myri10ge_priv *mgp)
  * firmware image, and set tx.boundary to 4KB.
  */
 
-#define PCI_DEVICE_ID_INTEL_E5000_PCIE23 0x25f7
-#define PCI_DEVICE_ID_INTEL_E5000_PCIE47 0x25fa
-#define PCI_DEVICE_ID_INTEL_6300ESB_PCIEE1 0x3510
-#define PCI_DEVICE_ID_INTEL_6300ESB_PCIEE4 0x351b
-#define PCI_DEVICE_ID_INTEL_E3000_PCIE	0x2779
-#define PCI_DEVICE_ID_INTEL_E3010_PCIE	0x277a
-#define PCI_DEVICE_ID_SERVERWORKS_HT2100_PCIE_FIRST 0x140
-#define PCI_DEVICE_ID_SERVERWORKS_HT2100_PCIE_LAST 0x142
-
-static void myri10ge_select_firmware(struct myri10ge_priv *mgp)
+static void myri10ge_firmware_probe(struct myri10ge_priv *mgp)
 {
-	struct pci_dev *bridge = mgp->pdev->bus->self;
+	struct pci_dev *pdev = mgp->pdev;
+	struct device *dev = &pdev->dev;
+	int cap, status;
+	u16 val;
+
+	mgp->tx.boundary = 4096;
+	/*
+	 * Verify the max read request size was set to 4KB
+	 * before trying the test with 4KB.
+	 */
+	cap = pci_find_capability(pdev, PCI_CAP_ID_EXP);
+	if (cap < 64) {
+		dev_err(dev, "Bad PCI_CAP_ID_EXP location %d\n", cap);
+		goto abort;
+	}
+	status = pci_read_config_word(pdev, cap + PCI_EXP_DEVCTL, &val);
+	if (status != 0) {
+		dev_err(dev, "Couldn't read max read req size: %d\n", status);
+		goto abort;
+	}
+	if ((val & (5 << 12)) != (5 << 12)) {
+		dev_warn(dev, "Max Read Request size != 4096 (0x%x)\n", val);
+		mgp->tx.boundary = 2048;
+	}
+	/*
+	 * load the optimized firmware (which assumes aligned PCIe
+	 * completions) in order to see if it works on this host.
+	 */
+	mgp->fw_name = myri10ge_fw_aligned;
+	status = myri10ge_load_firmware(mgp);
+	if (status != 0) {
+		goto abort;
+	}
+
+	/*
+	 * Enable ECRC if possible
+	 */
+	myri10ge_enable_ecrc(mgp);
+
+	/*
+	 * Run a DMA test which watches for unaligned completions and
+	 * aborts on the first one seen.
+	 */
 
+	status = myri10ge_dma_test(mgp, MXGEFW_CMD_UNALIGNED_TEST);
+	if (status == 0)
+		return;		/* keep the aligned firmware */
+
+	if (status != -E2BIG)
+		dev_warn(dev, "DMA test failed: %d\n", status);
+	if (status == -ENOSYS)
+		dev_warn(dev, "Falling back to ethp! "
+			 "Please install up to date fw\n");
+abort:
+	/* fall back to using the unaligned firmware */
 	mgp->tx.boundary = 2048;
 	mgp->fw_name = myri10ge_fw_unaligned;
 
+}
+
+static void myri10ge_select_firmware(struct myri10ge_priv *mgp)
+{
 	if (myri10ge_force_firmware == 0) {
 		int link_width, exp_cap;
 		u16 lnk;
@@ -2508,8 +2578,6 @@ static void myri10ge_select_firmware(struct myri10ge_priv *mgp)
 		pci_read_config_word(mgp->pdev, exp_cap + PCI_EXP_LNKSTA, &lnk);
 		link_width = (lnk >> 4) & 0x3f;
 
-		myri10ge_enable_ecrc(mgp);
-
 		/* Check to see if Link is less than 8 or if the
 		 * upstream bridge is known to provide aligned
 		 * completions */
@@ -2518,46 +2586,8 @@ static void myri10ge_select_firmware(struct myri10ge_priv *mgp)
 				 link_width);
 			mgp->tx.boundary = 4096;
 			mgp->fw_name = myri10ge_fw_aligned;
-		} else if (bridge &&
-			   /* ServerWorks HT2000/HT1000 */
-			   ((bridge->vendor == PCI_VENDOR_ID_SERVERWORKS
-			     && bridge->device ==
-			     PCI_DEVICE_ID_SERVERWORKS_HT2000_PCIE)
-			    /* ServerWorks HT2100 */
-			    || (bridge->vendor == PCI_VENDOR_ID_SERVERWORKS
-				&& bridge->device >=
-				PCI_DEVICE_ID_SERVERWORKS_HT2100_PCIE_FIRST
-				&& bridge->device <=
-				PCI_DEVICE_ID_SERVERWORKS_HT2100_PCIE_LAST)
-			    /* All Intel E3000/E3010 PCIE ports */
-			    || (bridge->vendor == PCI_VENDOR_ID_INTEL
-				&& (bridge->device ==
-				    PCI_DEVICE_ID_INTEL_E3000_PCIE
-				    || bridge->device ==
-				    PCI_DEVICE_ID_INTEL_E3010_PCIE))
-			    /* All Intel 6310/6311/6321ESB PCIE ports */
-			    || (bridge->vendor == PCI_VENDOR_ID_INTEL
-				&& bridge->device >=
-				PCI_DEVICE_ID_INTEL_6300ESB_PCIEE1
-				&& bridge->device <=
-				PCI_DEVICE_ID_INTEL_6300ESB_PCIEE4)
-			    /* All Intel E5000 PCIE ports */
-			    || (bridge->vendor == PCI_VENDOR_ID_INTEL
-				&& bridge->device >=
-				PCI_DEVICE_ID_INTEL_E5000_PCIE23
-				&& bridge->device <=
-				PCI_DEVICE_ID_INTEL_E5000_PCIE47))) {
-			dev_info(&mgp->pdev->dev,
-				 "Assuming aligned completions (0x%x:0x%x)\n",
-				 bridge->vendor, bridge->device);
-			mgp->tx.boundary = 4096;
-			mgp->fw_name = myri10ge_fw_aligned;
-		} else if (bridge &&
-			   bridge->vendor == PCI_VENDOR_ID_SGI &&
-			   bridge->device == 0x4002 /* TIOCE pcie-port */ ) {
-			/* this pcie bridge does not support 4K rdma request */
-			mgp->tx.boundary = 2048;
-			mgp->fw_name = myri10ge_fw_aligned;
+		} else {
+			myri10ge_firmware_probe(mgp);
 		}
 	} else {
 		if (myri10ge_force_firmware == 1) {
@@ -2825,7 +2855,6 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		status = -ENODEV;
 		goto abort_with_netdev;
 	}
-	myri10ge_select_firmware(mgp);
 
 	/* Find the vendor-specific cap so we can check
 	 * the reboot register later on */
@@ -2919,6 +2948,8 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto abort_with_ioremap;
 	memset(mgp->rx_done.entry, 0, bytes);
 
+	myri10ge_select_firmware(mgp);
+
 	status = myri10ge_load_firmware(mgp);
 	if (status != 0) {
 		dev_err(&pdev->dev, "failed to load firmware\n");
diff --git a/drivers/net/myri10ge/myri10ge_mcp.h b/drivers/net/myri10ge/myri10ge_mcp.h
index 29463b3..a1d2a22 100644
--- a/drivers/net/myri10ge/myri10ge_mcp.h
+++ b/drivers/net/myri10ge/myri10ge_mcp.h
@@ -200,6 +200,13 @@ enum myri10ge_mcp_cmd_type {
 	/* data0, data1 = bus addr,
 	 * data2 = sizeof(struct mcp_irq_data) from driver point of view, allows
 	 * adding new stuff to mcp_irq_data without changing the ABI */
+
+	MXGEFW_CMD_UNALIGNED_TEST,
+	/* same than DMA_TEST (same args) but abort with UNALIGNED on unaligned
+	 * chipset */
+
+	MXGEFW_CMD_UNALIGNED_STATUS
+	    /* return data = boolean, true if the chipset is known to be unaligned */
 };
 
 enum myri10ge_mcp_cmd_status {
@@ -212,18 +219,27 @@ enum myri10ge_mcp_cmd_status {
 	MXGEFW_CMD_ERROR_HASH_ERROR,
 	MXGEFW_CMD_ERROR_BAD_PORT,
 	MXGEFW_CMD_ERROR_RESOURCES,
-	MXGEFW_CMD_ERROR_MULTICAST
+	MXGEFW_CMD_ERROR_MULTICAST,
+	MXGEFW_CMD_ERROR_UNALIGNED
 };
 
 #define MXGEFW_OLD_IRQ_DATA_LEN 40
 
 struct mcp_irq_data {
 	/* add new counters at the beginning */
-	__be32 future_use[5];
+	__be32 future_use[1];
+	__be32 dropped_pause;
+	__be32 dropped_unicast_filtered;
+	__be32 dropped_bad_crc32;
+	__be32 dropped_bad_phy;
 	__be32 dropped_multicast_filtered;
 	/* 40 Bytes */
 	__be32 send_done_count;
 
+#define MXGEFW_LINK_DOWN 0
+#define MXGEFW_LINK_UP 1
+#define MXGEFW_LINK_MYRINET 2
+#define MXGEFW_LINK_UNKNOWN 3
 	__be32 link_up;
 	__be32 dropped_link_overflow;
 	__be32 dropped_link_error_or_filtered;
diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index a8d7ff2..223e0e6 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -81,6 +81,8 @@ static const int multicast_filter_limit = 100;
    Setting to > 1518 effectively disables this feature. */
 static int rx_copybreak;
 
+static int dspcfg_workaround = 1;
+
 /* Used to pass the media type, etc.
    Both 'options[]' and 'full_duplex[]' should exist for driver
    interoperability.
@@ -139,12 +141,14 @@ MODULE_LICENSE("GPL");
 module_param(mtu, int, 0);
 module_param(debug, int, 0);
 module_param(rx_copybreak, int, 0);
+module_param(dspcfg_workaround, int, 1);
 module_param_array(options, int, NULL, 0);
 module_param_array(full_duplex, int, NULL, 0);
 MODULE_PARM_DESC(mtu, "DP8381x MTU (all boards)");
 MODULE_PARM_DESC(debug, "DP8381x default debug level");
 MODULE_PARM_DESC(rx_copybreak,
 	"DP8381x copy breakpoint for copy-only-tiny-frames");
+MODULE_PARM_DESC(dspcfg_workaround, "DP8381x: control DspCfg workaround");
 MODULE_PARM_DESC(options,
 	"DP8381x: Bits 0-3: media type, bit 17: full duplex");
 MODULE_PARM_DESC(full_duplex, "DP8381x full duplex setting(s) (1)");
@@ -590,6 +594,7 @@ struct netdev_private {
 	u32 srr;
 	/* expected DSPCFG value */
 	u16 dspcfg;
+	int dspcfg_workaround;
 	/* parms saved in ethtool format */
 	u16	speed;		/* The forced speed, 10Mb, 100Mb, gigabit */
 	u8	duplex;		/* Duplex, half or full */
@@ -656,6 +661,56 @@ static int netdev_get_regs(struct net_device *dev, u8 *buf);
 static int netdev_get_eeprom(struct net_device *dev, u8 *buf);
 static const struct ethtool_ops ethtool_ops;
 
+#define NATSEMI_ATTR(_name) \
+static ssize_t natsemi_show_##_name(struct device *dev, \
+         struct device_attribute *attr, char *buf); \
+	 static ssize_t natsemi_set_##_name(struct device *dev, \
+		struct device_attribute *attr, \
+	        const char *buf, size_t count); \
+	 static DEVICE_ATTR(_name, 0644, natsemi_show_##_name, natsemi_set_##_name)
+
+#define NATSEMI_CREATE_FILE(_dev, _name) \
+         device_create_file(&_dev->dev, &dev_attr_##_name)
+#define NATSEMI_REMOVE_FILE(_dev, _name) \
+         device_create_file(&_dev->dev, &dev_attr_##_name)
+
+NATSEMI_ATTR(dspcfg_workaround);
+
+static ssize_t natsemi_show_dspcfg_workaround(struct device *dev,
+				  	      struct device_attribute *attr, 
+					      char *buf)
+{
+	struct netdev_private *np = netdev_priv(to_net_dev(dev));
+
+	return sprintf(buf, "%s\n", np->dspcfg_workaround ? "on" : "off");
+}
+
+static ssize_t natsemi_set_dspcfg_workaround(struct device *dev,
+					     struct device_attribute *attr,
+					     const char *buf, size_t count)
+{
+	struct netdev_private *np = netdev_priv(to_net_dev(dev));
+	int new_setting;
+	u32 flags;
+
+        /* Find out the new setting */
+        if (!strncmp("on", buf, count - 1) || !strncmp("1", buf, count - 1))
+                new_setting = 1;
+        else if (!strncmp("off", buf, count - 1)
+                 || !strncmp("0", buf, count - 1))
+		new_setting = 0;
+	else
+                 return count; 
+
+	spin_lock_irqsave(&np->lock, flags);
+
+	np->dspcfg_workaround = new_setting;
+
+	spin_unlock_irqrestore(&np->lock, flags);
+
+	return count;
+}
+
 static inline void __iomem *ns_ioaddr(struct net_device *dev)
 {
 	return (void __iomem *) dev->base_addr;
@@ -820,6 +875,7 @@ static int __devinit natsemi_probe1 (struct pci_dev *pdev,
 		np->ignore_phy = 1;
 	else
 		np->ignore_phy = 0;
+	np->dspcfg_workaround = dspcfg_workaround;
 
 	/* Initial port:
 	 * - If configured to ignore the PHY set up for external.
@@ -899,6 +955,9 @@ static int __devinit natsemi_probe1 (struct pci_dev *pdev,
 	if (i)
 		goto err_register_netdev;
 
+	if (NATSEMI_CREATE_FILE(pdev, dspcfg_workaround))
+		goto err_create_file;
+
 	if (netif_msg_drv(np)) {
 		printk(KERN_INFO "natsemi %s: %s at %#08lx (%s), ",
 			dev->name, natsemi_pci_info[chip_idx].name, iostart,
@@ -915,6 +974,9 @@ static int __devinit natsemi_probe1 (struct pci_dev *pdev,
 	}
 	return 0;
 
+ err_create_file:
+ 	unregister_netdev(dev);
+
  err_register_netdev:
 	iounmap(ioaddr);
 
@@ -1727,7 +1789,8 @@ static void init_registers(struct net_device *dev)
  *    It seems that a reference set for this chip went out with incorrect info,
  *    and there exist boards that aren't quite right.  An unexpected voltage
  *    drop can cause the PHY to get itself in a weird state (basically reset).
- *    NOTE: this only seems to affect revC chips.
+ *    NOTE: this only seems to affect revC chips.  The user can disable
+ *    this check via dspcfg_workaround sysfs option.
  * 3) check of death of the RX path due to OOM
  */
 static void netdev_timer(unsigned long data)
@@ -1753,10 +1816,10 @@ static void netdev_timer(unsigned long data)
 		writew(1, ioaddr+PGSEL);
 		dspcfg = readw(ioaddr+DSPCFG);
 		writew(0, ioaddr+PGSEL);
-		if (dspcfg != np->dspcfg) {
+		if (np->dspcfg_workaround && dspcfg != np->dspcfg) {
 			if (!netif_queue_stopped(dev)) {
 				spin_unlock_irq(&np->lock);
-				if (netif_msg_hw(np))
+				if (netif_msg_drv(np))
 					printk(KERN_NOTICE "%s: possible phy reset: "
 						"re-initializing\n", dev->name);
 				disable_irq(dev->irq);
@@ -3157,6 +3220,7 @@ static void __devexit natsemi_remove1 (struct pci_dev *pdev)
 	struct net_device *dev = pci_get_drvdata(pdev);
 	void __iomem * ioaddr = ns_ioaddr(dev);
 
+	NATSEMI_REMOVE_FILE(pdev, dspcfg_workaround);
 	unregister_netdev (dev);
 	pci_release_regions (pdev);
 	iounmap(ioaddr);
diff --git a/drivers/net/ne.c b/drivers/net/ne.c
index a5c4199..c9f74bf 100644
--- a/drivers/net/ne.c
+++ b/drivers/net/ne.c
@@ -51,14 +51,11 @@ static const char version2[] =
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/jiffies.h>
+#include <linux/platform_device.h>
 
 #include <asm/system.h>
 #include <asm/io.h>
 
-#if defined(CONFIG_TOSHIBA_RBTX4927) || defined(CONFIG_TOSHIBA_RBTX4938)
-#include <asm/tx4938/rbtx4938.h>
-#endif
-
 #include "8390.h"
 
 #define DRV_NAME "ne"
@@ -77,8 +74,13 @@ static const char version2[] =
 /* Do we have a non std. amount of memory? (in units of 256 byte pages) */
 /* #define PACKETBUF_MEMSIZE	0x40 */
 
+#if !defined(MODULE) && (defined(CONFIG_ISA) || defined(CONFIG_M32R))
+/* Do we need a portlist for the ISA auto-probe ? */
+#define NEEDS_PORTLIST
+#endif
+
 /* A zero-terminated list of I/O addresses to be probed at boot. */
-#ifndef MODULE
+#ifdef NEEDS_PORTLIST
 static unsigned int netcard_portlist[] __initdata = {
 	0x300, 0x280, 0x320, 0x340, 0x360, 0x380, 0
 };
@@ -146,7 +148,7 @@ bad_clone_list[] __initdata = {
 #  define DCR_VAL 0x49
 #endif
 
-static int ne_probe1(struct net_device *dev, int ioaddr);
+static int ne_probe1(struct net_device *dev, unsigned long ioaddr);
 static int ne_probe_isapnp(struct net_device *dev);
 
 static int ne_open(struct net_device *dev);
@@ -184,8 +186,8 @@ static void ne_block_output(struct net_device *dev, const int count,
 
 static int __init do_ne_probe(struct net_device *dev)
 {
-	unsigned int base_addr = dev->base_addr;
-#ifndef MODULE
+	unsigned long base_addr = dev->base_addr;
+#ifdef NEEDS_PORTLIST
 	int orig_irq = dev->irq;
 #endif
 
@@ -201,7 +203,7 @@ static int __init do_ne_probe(struct net_device *dev)
 	if (isapnp_present() && (ne_probe_isapnp(dev) == 0))
 		return 0;
 
-#ifndef MODULE
+#ifdef NEEDS_PORTLIST
 	/* Last resort. The semi-risky ISA auto-probe. */
 	for (base_addr = 0; netcard_portlist[base_addr] != 0; base_addr++) {
 		int ioaddr = netcard_portlist[base_addr];
@@ -226,10 +228,6 @@ struct net_device * __init ne_probe(int unit)
 	sprintf(dev->name, "eth%d", unit);
 	netdev_boot_setup_check(dev);
 
-#ifdef CONFIG_TOSHIBA_RBTX4938
-	dev->base_addr = RBTX4938_RTL_8019_BASE;
-	dev->irq = RBTX4938_RTL_8019_IRQ;
-#endif
 	err = do_ne_probe(dev);
 	if (err)
 		goto out;
@@ -285,7 +283,7 @@ static int __init ne_probe_isapnp(struct net_device *dev)
 	return -ENODEV;
 }
 
-static int __init ne_probe1(struct net_device *dev, int ioaddr)
+static int __init ne_probe1(struct net_device *dev, unsigned long ioaddr)
 {
 	int i;
 	unsigned char SA_prom[32];
@@ -324,7 +322,7 @@ static int __init ne_probe1(struct net_device *dev, int ioaddr)
 	if (ei_debug  &&  version_printed++ == 0)
 		printk(KERN_INFO "%s" KERN_INFO "%s", version1, version2);
 
-	printk(KERN_INFO "NE*000 ethercard probe at %#3x:", ioaddr);
+	printk(KERN_INFO "NE*000 ethercard probe at %#3lx:", ioaddr);
 
 	/* A user with a poor card that fails to ack the reset, or that
 	   does not have a valid 0x57,0x57 signature can still use this
@@ -516,8 +514,7 @@ static int __init ne_probe1(struct net_device *dev, int ioaddr)
 	}
 #endif
 
-	printk("\n%s: %s found at %#x, using IRQ %d.\n",
-		dev->name, name, ioaddr, dev->irq);
+	printk("\n");
 
 	ei_status.name = name;
 	ei_status.tx_start_page = start_page;
@@ -547,6 +544,8 @@ static int __init ne_probe1(struct net_device *dev, int ioaddr)
 	ret = register_netdev(dev);
 	if (ret)
 		goto out_irq;
+	printk(KERN_INFO "%s: %s found at %#lx, using IRQ %d.\n",
+	       dev->name, name, ioaddr, dev->irq);
 	return 0;
 
 out_irq:
@@ -807,6 +806,87 @@ retry:
 	return;
 }
 
+static int __init ne_drv_probe(struct platform_device *pdev)
+{
+	struct net_device *dev;
+	struct resource *res;
+	int err, irq;
+
+	res = platform_get_resource(pdev, IORESOURCE_IO, 0);
+	irq = platform_get_irq(pdev, 0);
+	if (!res || irq < 0)
+		return -ENODEV;
+
+	dev = alloc_ei_netdev();
+	if (!dev)
+		return -ENOMEM;
+	dev->irq = irq;
+	dev->base_addr = res->start;
+	err = do_ne_probe(dev);
+	if (err) {
+		free_netdev(dev);
+		return err;
+	}
+	platform_set_drvdata(pdev, dev);
+	return 0;
+}
+
+static int __exit ne_drv_remove(struct platform_device *pdev)
+{
+	struct net_device *dev = platform_get_drvdata(pdev);
+
+	unregister_netdev(dev);
+	free_irq(dev->irq, dev);
+	release_region(dev->base_addr, NE_IO_EXTENT);
+	free_netdev(dev);
+	return 0;
+}
+
+#ifdef CONFIG_PM
+static int ne_drv_suspend(struct platform_device *pdev, pm_message_t state)
+{
+	struct net_device *dev = platform_get_drvdata(pdev);
+
+	if (netif_running(dev))
+		netif_device_detach(dev);
+	return 0;
+}
+
+static int ne_drv_resume(struct platform_device *pdev)
+{
+	struct net_device *dev = platform_get_drvdata(pdev);
+
+	if (netif_running(dev)) {
+		ne_reset_8390(dev);
+		NS8390_init(dev, 1);
+		netif_device_attach(dev);
+	}
+	return 0;
+}
+#else
+#define ne_drv_suspend NULL
+#define ne_drv_resume NULL
+#endif
+
+static struct platform_driver ne_driver = {
+	.remove		= __exit_p(ne_drv_remove),
+	.suspend	= ne_drv_suspend,
+	.resume		= ne_drv_resume,
+	.driver		= {
+		.name	= DRV_NAME,
+		.owner	= THIS_MODULE,
+	},
+};
+
+static int __init ne_init(void)
+{
+	return platform_driver_probe(&ne_driver, ne_drv_probe);
+}
+
+static void __exit ne_exit(void)
+{
+	platform_driver_unregister(&ne_driver);
+}
 
 #ifdef MODULE
 #define MAX_NE_CARDS	4	/* Max number of NE cards per module */
@@ -832,6 +912,7 @@ ISA device autoprobes on a running machine are not recommended anyway. */
 int __init init_module(void)
 {
 	int this_dev, found = 0;
+	int plat_found = !ne_init();
 
 	for (this_dev = 0; this_dev < MAX_NE_CARDS; this_dev++) {
 		struct net_device *dev = alloc_ei_netdev();
@@ -845,7 +926,7 @@ int __init init_module(void)
 			continue;
 		}
 		free_netdev(dev);
-		if (found)
+		if (found || plat_found)
 			break;
 		if (io[this_dev] != 0)
 			printk(KERN_WARNING "ne.c: No NE*000 card found at i/o = %#x\n", io[this_dev]);
@@ -853,7 +934,7 @@ int __init init_module(void)
 			printk(KERN_NOTICE "ne.c: You must supply \"io=0xNNN\" value(s) for ISA cards.\n");
 		return -ENXIO;
 	}
-	if (found)
+	if (found || plat_found)
 		return 0;
 	return -ENODEV;
 }
@@ -871,6 +952,7 @@ void __exit cleanup_module(void)
 {
 	int this_dev;
 
+	ne_exit();
 	for (this_dev = 0; this_dev < MAX_NE_CARDS; this_dev++) {
 		struct net_device *dev = dev_ne[this_dev];
 		if (dev) {
@@ -880,4 +962,7 @@ void __exit cleanup_module(void)
 		}
 	}
 }
+#else /* MODULE */
+module_init(ne_init);
+module_exit(ne_exit);
 #endif /* MODULE */
diff --git a/drivers/net/pasemi_mac.c b/drivers/net/pasemi_mac.c
index 76fe9dd..b8f976b 100644
--- a/drivers/net/pasemi_mac.c
+++ b/drivers/net/pasemi_mac.c
@@ -33,6 +33,8 @@
 #include <linux/tcp.h>
 #include <net/checksum.h>
 
+#include <asm/irq.h>
+
 #include "pasemi_mac.h"
 
 
@@ -51,6 +53,16 @@
 #define RX_RING_SIZE 512
 #define TX_RING_SIZE 512
 
+#define DEFAULT_MSG_ENABLE	  \
+	(NETIF_MSG_DRV		| \
+	 NETIF_MSG_PROBE	| \
+	 NETIF_MSG_LINK		| \
+	 NETIF_MSG_TIMER	| \
+	 NETIF_MSG_IFDOWN	| \
+	 NETIF_MSG_IFUP		| \
+	 NETIF_MSG_RX_ERR	| \
+	 NETIF_MSG_TX_ERR)
+
 #define TX_DESC(mac, num)	((mac)->tx->desc[(num) & (TX_RING_SIZE-1)])
 #define TX_DESC_INFO(mac, num)	((mac)->tx->desc_info[(num) & (TX_RING_SIZE-1)])
 #define RX_DESC(mac, num)	((mac)->rx->desc[(num) & (RX_RING_SIZE-1)])
@@ -59,11 +71,13 @@
 
 #define BUF_SIZE 1646 /* 1500 MTU + ETH_HLEN + VLAN_HLEN + 2 64B cachelines */
 
-/* XXXOJN these should come out of the device tree some day */
-#define PAS_DMA_CAP_BASE   0xe00d0040
-#define PAS_DMA_CAP_SIZE   0x100
-#define PAS_DMA_COM_BASE   0xe00d0100
-#define PAS_DMA_COM_SIZE   0x100
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR ("Olof Johansson <olof@lixom.net>");
+MODULE_DESCRIPTION("PA Semi PWRficient Ethernet driver");
+
+static int debug = -1;	/* -1 == use DEFAULT_MSG_ENABLE as value */
+module_param(debug, int, 0);
+MODULE_PARM_DESC(debug, "PA Semi MAC bitmapped debugging message enable value");
 
 static struct pasdma_status *dma_status;
 
@@ -80,7 +94,12 @@ static int pasemi_get_mac_addr(struct pasemi_mac *mac)
 		return -ENOENT;
 	}
 
-	maddr = get_property(dn, "mac-address", NULL);
+	maddr = get_property(dn, "local-mac-address", NULL);
+
+	/* Fall back to mac-address for older firmware */
+	if (maddr == NULL)
+		maddr = get_property(dn, "mac-address", NULL);
+
 	if (maddr == NULL) {
 		dev_warn(&pdev->dev,
 			 "no mac address in device tree, not configuring\n");
@@ -277,8 +296,8 @@ static void pasemi_mac_free_rx_resources(struct net_device *dev)
 	for (i = 0; i < RX_RING_SIZE; i++) {
 		info = &RX_DESC_INFO(mac, i);
 		dp = &RX_DESC(mac, i);
-		if (info->dma) {
-			if (info->skb) {
+		if (info->skb) {
+			if (info->dma) {
 				pci_unmap_single(mac->dma_pdev,
 						 info->dma,
 						 info->skb->len,
@@ -309,82 +328,120 @@ static void pasemi_mac_replenish_rx_ring(struct net_device *dev)
 	struct pasemi_mac *mac = netdev_priv(dev);
 	unsigned int i;
 	int start = mac->rx->next_to_fill;
-	unsigned int count;
+	unsigned int limit, count;
 
-	count = (mac->rx->next_to_clean + RX_RING_SIZE -
+	limit = (mac->rx->next_to_clean + RX_RING_SIZE -
 		 mac->rx->next_to_fill) & (RX_RING_SIZE - 1);
 
 	/* Check to see if we're doing first-time setup */
 	if (unlikely(mac->rx->next_to_clean == 0 && mac->rx->next_to_fill == 0))
-		count = RX_RING_SIZE;
+		limit = RX_RING_SIZE;
 
-	if (count <= 0)
+	if (limit <= 0)
 		return;
 
-	for (i = start; i < start + count; i++) {
+	i = start;
+	for (count = limit; count; count--) {
 		struct pasemi_mac_buffer *info = &RX_DESC_INFO(mac, i);
 		u64 *buff = &RX_BUFF(mac, i);
 		struct sk_buff *skb;
 		dma_addr_t dma;
 
-		skb = dev_alloc_skb(BUF_SIZE);
+		/* skb might still be in there for recycle on short receives */
+		if (info->skb)
+			skb = info->skb;
+		else
+			skb = dev_alloc_skb(BUF_SIZE);
 
-		if (!skb) {
-			count = i - start;
+		if (unlikely(!skb))
 			break;
-		}
 
 		dma = pci_map_single(mac->dma_pdev, skb->data, skb->len,
 				     PCI_DMA_FROMDEVICE);
 
-		if (dma_mapping_error(dma)) {
+		if (unlikely(dma_mapping_error(dma))) {
 			dev_kfree_skb_irq(info->skb);
-			count = i - start;
 			break;
 		}
 
 		info->skb = skb;
 		info->dma = dma;
 		*buff = XCT_RXB_LEN(BUF_SIZE) | XCT_RXB_ADDR(dma);
+		i++;
 	}
 
 	wmb();
 
 	pci_write_config_dword(mac->dma_pdev,
 			       PAS_DMA_RXCHAN_INCR(mac->dma_rxch),
-			       count);
+			       limit - count);
 	pci_write_config_dword(mac->dma_pdev,
 			       PAS_DMA_RXINT_INCR(mac->dma_if),
-			       count);
+			       limit - count);
 
-	mac->rx->next_to_fill += count;
+	mac->rx->next_to_fill += limit - count;
 }
 
+static void pasemi_mac_restart_rx_intr(struct pasemi_mac *mac)
+{
+	unsigned int reg, stat;
+	/* Re-enable packet count interrupts: finally
+	 * ack the packet count interrupt we got in rx_intr.
+	 */
+
+	pci_read_config_dword(mac->iob_pdev,
+			      PAS_IOB_DMA_RXCH_STAT(mac->dma_rxch),
+			      &stat);
+
+	reg = PAS_IOB_DMA_RXCH_RESET_PCNT(stat & PAS_IOB_DMA_RXCH_STAT_CNTDEL_M)
+		| PAS_IOB_DMA_RXCH_RESET_PINTC;
+
+	pci_write_config_dword(mac->iob_pdev,
+			       PAS_IOB_DMA_RXCH_RESET(mac->dma_rxch),
+			       reg);
+}
+
+static void pasemi_mac_restart_tx_intr(struct pasemi_mac *mac)
+{
+	unsigned int reg, stat;
+
+	/* Re-enable packet count interrupts */
+	pci_read_config_dword(mac->iob_pdev,
+			      PAS_IOB_DMA_TXCH_STAT(mac->dma_txch), &stat);
+
+	reg = PAS_IOB_DMA_TXCH_RESET_PCNT(stat & PAS_IOB_DMA_TXCH_STAT_CNTDEL_M)
+		| PAS_IOB_DMA_TXCH_RESET_PINTC;
+
+	pci_write_config_dword(mac->iob_pdev,
+			       PAS_IOB_DMA_TXCH_RESET(mac->dma_txch), reg);
+}
+
+
 static int pasemi_mac_clean_rx(struct pasemi_mac *mac, int limit)
 {
-	unsigned int i;
-	int start, count;
+	unsigned int n;
+	int count;
+	struct pas_dma_xct_descr *dp;
+	struct pasemi_mac_buffer *info;
+	struct sk_buff *skb;
+	unsigned int i, len;
+	u64 macrx;
+	dma_addr_t dma;
 
 	spin_lock(&mac->rx->lock);
 
-	start = mac->rx->next_to_clean;
-	count = 0;
+	n = mac->rx->next_to_clean;
 
-	for (i = start; i < (start + RX_RING_SIZE) && count < limit; i++) {
-		struct pas_dma_xct_descr *dp;
-		struct pasemi_mac_buffer *info;
-		struct sk_buff *skb;
-		unsigned int j, len;
-		dma_addr_t dma;
+	for (count = limit; count; count--) {
 
 		rmb();
 
-		dp = &RX_DESC(mac, i);
+		dp = &RX_DESC(mac, n);
+		macrx = dp->macrx;
 
-		if (!(dp->macrx & XCT_MACRX_O))
+		if (!(macrx & XCT_MACRX_O))
 			break;
 
-		count++;
 
 		info = NULL;
 
@@ -396,29 +453,42 @@ static int pasemi_mac_clean_rx(struct pasemi_mac *mac, int limit)
 		 */
 
 		dma = (dp->ptr & XCT_PTR_ADDR_M);
-		for (j = start; j < (start + RX_RING_SIZE); j++) {
-			info = &RX_DESC_INFO(mac, j);
+		for (i = n; i < (n + RX_RING_SIZE); i++) {
+			info = &RX_DESC_INFO(mac, i);
 			if (info->dma == dma)
 				break;
 		}
 
-		BUG_ON(!info);
-		BUG_ON(info->dma != dma);
+		skb = info->skb;
+		info->dma = 0;
 
-		pci_unmap_single(mac->dma_pdev, info->dma, info->skb->len,
+		pci_unmap_single(mac->dma_pdev, dma, skb->len,
 				 PCI_DMA_FROMDEVICE);
 
-		skb = info->skb;
-
-		len = (dp->macrx & XCT_MACRX_LLEN_M) >> XCT_MACRX_LLEN_S;
+		len = (macrx & XCT_MACRX_LLEN_M) >> XCT_MACRX_LLEN_S;
+
+		if (len < 256) {
+			struct sk_buff *new_skb =
+			    netdev_alloc_skb(mac->netdev, len + NET_IP_ALIGN);
+			if (new_skb) {
+				skb_reserve(new_skb, NET_IP_ALIGN);
+				memcpy(new_skb->data - NET_IP_ALIGN,
+					skb->data - NET_IP_ALIGN,
+					len + NET_IP_ALIGN);
+				/* save the skb in buffer_info as good */
+				skb = new_skb;
+			}
+			/* else just continue with the old one */
+		} else
+			info->skb = NULL;
 
 		skb_put(skb, len);
 
 		skb->protocol = eth_type_trans(skb, mac->netdev);
 
-		if ((dp->macrx & XCT_MACRX_HTY_M) == XCT_MACRX_HTY_IPV4_OK) {
+		if ((macrx & XCT_MACRX_HTY_M) == XCT_MACRX_HTY_IPV4_OK) {
 			skb->ip_summed = CHECKSUM_COMPLETE;
-			skb->csum = (dp->macrx & XCT_MACRX_CSUM_M) >>
+			skb->csum = (macrx & XCT_MACRX_CSUM_M) >>
 					   XCT_MACRX_CSUM_S;
 		} else
 			skb->ip_summed = CHECKSUM_NONE;
@@ -428,13 +498,13 @@ static int pasemi_mac_clean_rx(struct pasemi_mac *mac, int limit)
 
 		netif_receive_skb(skb);
 
-		info->dma = 0;
-		info->skb = NULL;
 		dp->ptr = 0;
 		dp->macrx = 0;
+
+		n++;
 	}
 
-	mac->rx->next_to_clean += count;
+	mac->rx->next_to_clean += limit - count;
 	pasemi_mac_replenish_rx_ring(mac->netdev);
 
 	spin_unlock(&mac->rx->lock);
@@ -476,6 +546,8 @@ static int pasemi_mac_clean_tx(struct pasemi_mac *mac)
 	mac->tx->next_to_clean += count;
 	spin_unlock_irqrestore(&mac->tx->lock, flags);
 
+	netif_wake_queue(mac->netdev);
+
 	return count;
 }
 
@@ -486,18 +558,28 @@ static irqreturn_t pasemi_mac_rx_intr(int irq, void *data)
 	struct pasemi_mac *mac = netdev_priv(dev);
 	unsigned int reg;
 
-	if (!(*mac->rx_status & PAS_STATUS_INT))
+	if (!(*mac->rx_status & PAS_STATUS_CAUSE_M))
 		return IRQ_NONE;
 
-	netif_rx_schedule(dev);
-	pci_write_config_dword(mac->iob_pdev, PAS_IOB_DMA_COM_TIMEOUTCFG,
-			       PAS_IOB_DMA_COM_TIMEOUTCFG_TCNT(0));
+	if (*mac->rx_status & PAS_STATUS_ERROR)
+		printk("rx_status reported error\n");
+
+	/* Don't reset packet count so it won't fire again but clear
+	 * all others.
+	 */
+
+	pci_read_config_dword(mac->dma_pdev, PAS_DMA_RXINT_RCMDSTA(mac->dma_if), &reg);
 
-	reg = PAS_IOB_DMA_RXCH_RESET_PINTC | PAS_IOB_DMA_RXCH_RESET_SINTC |
-	      PAS_IOB_DMA_RXCH_RESET_DINTC;
+	reg = 0;
+	if (*mac->rx_status & PAS_STATUS_SOFT)
+		reg |= PAS_IOB_DMA_RXCH_RESET_SINTC;
+	if (*mac->rx_status & PAS_STATUS_ERROR)
+		reg |= PAS_IOB_DMA_RXCH_RESET_DINTC;
 	if (*mac->rx_status & PAS_STATUS_TIMER)
 		reg |= PAS_IOB_DMA_RXCH_RESET_TINTC;
 
+	netif_rx_schedule(dev);
+
 	pci_write_config_dword(mac->iob_pdev,
 			       PAS_IOB_DMA_RXCH_RESET(mac->dma_rxch), reg);
 
@@ -510,31 +592,137 @@ static irqreturn_t pasemi_mac_tx_intr(int irq, void *data)
 	struct net_device *dev = data;
 	struct pasemi_mac *mac = netdev_priv(dev);
 	unsigned int reg;
-	int was_full;
 
-	was_full = mac->tx->next_to_clean - mac->tx->next_to_use == TX_RING_SIZE;
-
-	if (!(*mac->tx_status & PAS_STATUS_INT))
+	if (!(*mac->tx_status & PAS_STATUS_CAUSE_M))
 		return IRQ_NONE;
 
 	pasemi_mac_clean_tx(mac);
 
-	reg = PAS_IOB_DMA_TXCH_RESET_PINTC | PAS_IOB_DMA_TXCH_RESET_SINTC;
-	if (*mac->tx_status & PAS_STATUS_TIMER)
-		reg |= PAS_IOB_DMA_TXCH_RESET_TINTC;
+	reg = PAS_IOB_DMA_TXCH_RESET_PINTC;
+
+	if (*mac->tx_status & PAS_STATUS_SOFT)
+		reg |= PAS_IOB_DMA_TXCH_RESET_SINTC;
+	if (*mac->tx_status & PAS_STATUS_ERROR)
+		reg |= PAS_IOB_DMA_TXCH_RESET_DINTC;
 
 	pci_write_config_dword(mac->iob_pdev, PAS_IOB_DMA_TXCH_RESET(mac->dma_txch),
 			       reg);
 
-	if (was_full)
-		netif_wake_queue(dev);
-
 	return IRQ_HANDLED;
 }
 
+static void pasemi_adjust_link(struct net_device *dev)
+{
+	struct pasemi_mac *mac = netdev_priv(dev);
+	int msg;
+	unsigned int flags;
+	unsigned int new_flags;
+
+	if (!mac->phydev->link) {
+		/* If no link, MAC speed settings don't matter. Just report
+		 * link down and return.
+		 */
+		if (mac->link && netif_msg_link(mac))
+			printk(KERN_INFO "%s: Link is down.\n", dev->name);
+
+		netif_carrier_off(dev);
+		mac->link = 0;
+
+		return;
+	} else
+		netif_carrier_on(dev);
+
+	pci_read_config_dword(mac->pdev, PAS_MAC_CFG_PCFG, &flags);
+	new_flags = flags & ~(PAS_MAC_CFG_PCFG_HD | PAS_MAC_CFG_PCFG_SPD_M |
+			      PAS_MAC_CFG_PCFG_TSR_M);
+
+	if (!mac->phydev->duplex)
+		new_flags |= PAS_MAC_CFG_PCFG_HD;
+
+	switch (mac->phydev->speed) {
+	case 1000:
+		new_flags |= PAS_MAC_CFG_PCFG_SPD_1G |
+			     PAS_MAC_CFG_PCFG_TSR_1G;
+		break;
+	case 100:
+		new_flags |= PAS_MAC_CFG_PCFG_SPD_100M |
+			     PAS_MAC_CFG_PCFG_TSR_100M;
+		break;
+	case 10:
+		new_flags |= PAS_MAC_CFG_PCFG_SPD_10M |
+			     PAS_MAC_CFG_PCFG_TSR_10M;
+		break;
+	default:
+		printk("Unsupported speed %d\n", mac->phydev->speed);
+	}
+
+	/* Print on link or speed/duplex change */
+	msg = mac->link != mac->phydev->link || flags != new_flags;
+
+	mac->duplex = mac->phydev->duplex;
+	mac->speed = mac->phydev->speed;
+	mac->link = mac->phydev->link;
+
+	if (new_flags != flags)
+		pci_write_config_dword(mac->pdev, PAS_MAC_CFG_PCFG, new_flags);
+
+	if (msg && netif_msg_link(mac))
+		printk(KERN_INFO "%s: Link is up at %d Mbps, %s duplex.\n",
+		       dev->name, mac->speed, mac->duplex ? "full" : "half");
+}
+
+static int pasemi_mac_phy_init(struct net_device *dev)
+{
+	struct pasemi_mac *mac = netdev_priv(dev);
+	struct device_node *dn, *phy_dn;
+	struct phy_device *phydev;
+	unsigned int phy_id;
+	const phandle *ph;
+	const unsigned int *prop;
+	struct resource r;
+	int ret;
+
+	dn = pci_device_to_OF_node(mac->pdev);
+	ph = get_property(dn, "phy-handle", NULL);
+	if (!ph)
+		return -ENODEV;
+	phy_dn = of_find_node_by_phandle(*ph);
+
+	prop = get_property(phy_dn, "reg", NULL);
+	ret = of_address_to_resource(phy_dn->parent, 0, &r);
+	if (ret)
+		goto err;
+
+	phy_id = *prop;
+	snprintf(mac->phy_id, BUS_ID_SIZE, PHY_ID_FMT, (int)r.start, phy_id);
+
+	of_node_put(phy_dn);
+
+	mac->link = 0;
+	mac->speed = 0;
+	mac->duplex = -1;
+
+	phydev = phy_connect(dev, mac->phy_id, &pasemi_adjust_link, 0, PHY_INTERFACE_MODE_SGMII);
+
+	if (IS_ERR(phydev)) {
+		printk(KERN_ERR "%s: Could not attach to phy\n", dev->name);
+		return PTR_ERR(phydev);
+	}
+
+	mac->phydev = phydev;
+
+	return 0;
+
+err:
+	of_node_put(phy_dn);
+	return -ENODEV;
+}
+
+
 static int pasemi_mac_open(struct net_device *dev)
 {
 	struct pasemi_mac *mac = netdev_priv(dev);
+	int base_irq;
 	unsigned int flags;
 	int ret;
 
@@ -558,10 +746,18 @@ static int pasemi_mac_open(struct net_device *dev)
 	flags |= PAS_MAC_CFG_PCFG_TSR_1G | PAS_MAC_CFG_PCFG_SPD_1G;
 
 	pci_write_config_dword(mac->iob_pdev, PAS_IOB_DMA_RXCH_CFG(mac->dma_rxch),
-			       PAS_IOB_DMA_RXCH_CFG_CNTTH(30));
+			       PAS_IOB_DMA_RXCH_CFG_CNTTH(1));
 
+	pci_write_config_dword(mac->iob_pdev, PAS_IOB_DMA_TXCH_CFG(mac->dma_txch),
+			       PAS_IOB_DMA_TXCH_CFG_CNTTH(32));
+
+	/* Clear out any residual packet count state from firmware */
+	pasemi_mac_restart_rx_intr(mac);
+	pasemi_mac_restart_tx_intr(mac);
+
+	/* 0xffffff is max value, about 16ms */
 	pci_write_config_dword(mac->iob_pdev, PAS_IOB_DMA_COM_TIMEOUTCFG,
-			       PAS_IOB_DMA_COM_TIMEOUTCFG_TCNT(1000000));
+			       PAS_IOB_DMA_COM_TIMEOUTCFG_TCNT(0xffffff));
 
 	pci_write_config_dword(mac->pdev, PAS_MAC_CFG_PCFG, flags);
 
@@ -595,31 +791,50 @@ static int pasemi_mac_open(struct net_device *dev)
 
 	pasemi_mac_replenish_rx_ring(dev);
 
+	ret = pasemi_mac_phy_init(dev);
+	/* Some configs don't have PHYs (XAUI etc), so don't complain about
+	 * failed init due to -ENODEV.
+	 */
+	if (ret && ret != -ENODEV)
+		dev_warn(&mac->pdev->dev, "phy init failed: %d\n", ret);
+
 	netif_start_queue(dev);
 	netif_poll_enable(dev);
 
-	ret = request_irq(mac->dma_pdev->irq + mac->dma_txch,
-			  &pasemi_mac_tx_intr, IRQF_DISABLED,
+	/* Interrupts are a bit different for our DMA controller: While
+	 * it's got one a regular PCI device header, the interrupt there
+	 * is really the base of the range it's using. Each tx and rx
+	 * channel has it's own interrupt source.
+	 */
+
+	base_irq = virq_to_hw(mac->dma_pdev->irq);
+
+	mac->tx_irq = irq_create_mapping(NULL, base_irq + mac->dma_txch);
+	mac->rx_irq = irq_create_mapping(NULL, base_irq + 20 + mac->dma_txch);
+
+	ret = request_irq(mac->tx_irq, &pasemi_mac_tx_intr, IRQF_DISABLED,
 			  mac->tx->irq_name, dev);
 	if (ret) {
 		dev_err(&mac->pdev->dev, "request_irq of irq %d failed: %d\n",
-		       mac->dma_pdev->irq + mac->dma_txch, ret);
+			base_irq + mac->dma_txch, ret);
 		goto out_tx_int;
 	}
 
-	ret = request_irq(mac->dma_pdev->irq + 20 + mac->dma_rxch,
-			  &pasemi_mac_rx_intr, IRQF_DISABLED,
+	ret = request_irq(mac->rx_irq, &pasemi_mac_rx_intr, IRQF_DISABLED,
 			  mac->rx->irq_name, dev);
 	if (ret) {
 		dev_err(&mac->pdev->dev, "request_irq of irq %d failed: %d\n",
-		       mac->dma_pdev->irq + 20 + mac->dma_rxch, ret);
+			base_irq + 20 + mac->dma_rxch, ret);
 		goto out_rx_int;
 	}
 
+	if (mac->phydev)
+		phy_start(mac->phydev);
+
 	return 0;
 
 out_rx_int:
-	free_irq(mac->dma_pdev->irq + mac->dma_txch, dev);
+	free_irq(mac->tx_irq, dev);
 out_tx_int:
 	netif_poll_disable(dev);
 	netif_stop_queue(dev);
@@ -639,6 +854,11 @@ static int pasemi_mac_close(struct net_device *dev)
 	unsigned int stat;
 	int retries;
 
+	if (mac->phydev) {
+		phy_stop(mac->phydev);
+		phy_disconnect(mac->phydev);
+	}
+
 	netif_stop_queue(dev);
 
 	/* Clean out any pending buffers */
@@ -660,40 +880,37 @@ static int pasemi_mac_close(struct net_device *dev)
 		pci_read_config_dword(mac->dma_pdev,
 				      PAS_DMA_TXCHAN_TCMDSTA(mac->dma_txch),
 				      &stat);
-		if (stat & PAS_DMA_TXCHAN_TCMDSTA_ACT)
+		if (!(stat & PAS_DMA_TXCHAN_TCMDSTA_ACT))
 			break;
 		cond_resched();
 	}
 
-	if (!(stat & PAS_DMA_TXCHAN_TCMDSTA_ACT)) {
+	if (stat & PAS_DMA_TXCHAN_TCMDSTA_ACT)
 		dev_err(&mac->dma_pdev->dev, "Failed to stop tx channel\n");
-	}
 
 	for (retries = 0; retries < MAX_RETRIES; retries++) {
 		pci_read_config_dword(mac->dma_pdev,
 				      PAS_DMA_RXCHAN_CCMDSTA(mac->dma_rxch),
 				      &stat);
-		if (stat & PAS_DMA_RXCHAN_CCMDSTA_ACT)
+		if (!(stat & PAS_DMA_RXCHAN_CCMDSTA_ACT))
 			break;
 		cond_resched();
 	}
 
-	if (!(stat & PAS_DMA_RXCHAN_CCMDSTA_ACT)) {
+	if (stat & PAS_DMA_RXCHAN_CCMDSTA_ACT)
 		dev_err(&mac->dma_pdev->dev, "Failed to stop rx channel\n");
-	}
 
 	for (retries = 0; retries < MAX_RETRIES; retries++) {
 		pci_read_config_dword(mac->dma_pdev,
 				      PAS_DMA_RXINT_RCMDSTA(mac->dma_if),
 				      &stat);
-		if (stat & PAS_DMA_RXINT_RCMDSTA_ACT)
+		if (!(stat & PAS_DMA_RXINT_RCMDSTA_ACT))
 			break;
 		cond_resched();
 	}
 
-	if (!(stat & PAS_DMA_RXINT_RCMDSTA_ACT)) {
+	if (stat & PAS_DMA_RXINT_RCMDSTA_ACT)
 		dev_err(&mac->dma_pdev->dev, "Failed to stop rx interface\n");
-	}
 
 	/* Then, disable the channel. This must be done separately from
 	 * stopping, since you can't disable when active.
@@ -706,8 +923,8 @@ static int pasemi_mac_close(struct net_device *dev)
 	pci_write_config_dword(mac->dma_pdev,
 			       PAS_DMA_RXINT_RCMDSTA(mac->dma_if), 0);
 
-	free_irq(mac->dma_pdev->irq + mac->dma_txch, dev);
-	free_irq(mac->dma_pdev->irq + 20 + mac->dma_rxch, dev);
+	free_irq(mac->tx_irq, dev);
+	free_irq(mac->rx_irq, dev);
 
 	/* Free resources */
 	pasemi_mac_free_rx_resources(dev);
@@ -802,6 +1019,7 @@ static struct net_device_stats *pasemi_mac_get_stats(struct net_device *dev)
 	return &mac->stats;
 }
 
+
 static void pasemi_mac_set_rx_mode(struct net_device *dev)
 {
 	struct pasemi_mac *mac = netdev_priv(dev);
@@ -826,18 +1044,17 @@ static int pasemi_mac_poll(struct net_device *dev, int *budget)
 
 	pkts = pasemi_mac_clean_rx(mac, limit);
 
+	dev->quota -= pkts;
+	*budget -= pkts;
+
 	if (pkts < limit) {
 		/* all done, no more packets present */
 		netif_rx_complete(dev);
 
-		/* re-enable receive interrupts */
-		pci_write_config_dword(mac->iob_pdev, PAS_IOB_DMA_COM_TIMEOUTCFG,
-				       PAS_IOB_DMA_COM_TIMEOUTCFG_TCNT(1000000));
+		pasemi_mac_restart_rx_intr(mac);
 		return 0;
 	} else {
 		/* used up our quantum, so reschedule */
-		dev->quota -= pkts;
-		*budget -= pkts;
 		return 1;
 	}
 }
@@ -937,6 +1154,11 @@ pasemi_mac_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	mac->rx_status = &dma_status->rx_sta[mac->dma_rxch];
 	mac->tx_status = &dma_status->tx_sta[mac->dma_txch];
 
+	mac->msg_enable = netif_msg_init(debug, DEFAULT_MSG_ENABLE);
+
+	/* Enable most messages by default */
+	mac->msg_enable = (NETIF_MSG_IFUP << 1 ) - 1;
+
 	err = register_netdev(dev);
 
 	if (err) {
@@ -1011,9 +1233,5 @@ int pasemi_mac_init_module(void)
 	return pci_register_driver(&pasemi_mac_driver);
 }
 
-MODULE_LICENSE("GPL");
-MODULE_AUTHOR ("Olof Johansson <olof@lixom.net>");
-MODULE_DESCRIPTION("PA Semi PWRficient Ethernet driver");
-
 module_init(pasemi_mac_init_module);
 module_exit(pasemi_mac_cleanup_module);
diff --git a/drivers/net/pasemi_mac.h b/drivers/net/pasemi_mac.h
index c3e37e4..8bc0cea 100644
--- a/drivers/net/pasemi_mac.h
+++ b/drivers/net/pasemi_mac.h
@@ -24,6 +24,7 @@
 #include <linux/ethtool.h>
 #include <linux/netdevice.h>
 #include <linux/spinlock.h>
+#include <linux/phy.h>
 
 struct pasemi_mac_txring {
 	spinlock_t	 lock;
@@ -54,6 +55,7 @@ struct pasemi_mac {
 	struct pci_dev *pdev;
 	struct pci_dev *dma_pdev;
 	struct pci_dev *iob_pdev;
+	struct phy_device *phydev;
 	struct net_device_stats stats;
 
 	/* Pointer to the cacheable per-channel status registers */
@@ -73,6 +75,14 @@ struct pasemi_mac {
 
 	struct pasemi_mac_txring *tx;
 	struct pasemi_mac_rxring *rx;
+	unsigned long	tx_irq;
+	unsigned long	rx_irq;
+	int	link;
+	int	speed;
+	int	duplex;
+
+	unsigned int	msg_enable;
+	char	phy_id[BUS_ID_SIZE];
 };
 
 /* Software status descriptor (desc_info) */
@@ -193,11 +203,15 @@ enum {
 #define PAS_DMA_RXINT_RCMDSTA(i)	(0x200+(i)*_PAS_DMA_RXINT_STRIDE)
 #define    PAS_DMA_RXINT_RCMDSTA_EN	0x00000001
 #define    PAS_DMA_RXINT_RCMDSTA_ST	0x00000002
-#define    PAS_DMA_RXINT_RCMDSTA_OO	0x00000100
-#define    PAS_DMA_RXINT_RCMDSTA_BP	0x00000200
-#define    PAS_DMA_RXINT_RCMDSTA_DR	0x00000400
+#define    PAS_DMA_RXINT_RCMDSTA_MBT	0x00000008
+#define    PAS_DMA_RXINT_RCMDSTA_MDR	0x00000010
+#define    PAS_DMA_RXINT_RCMDSTA_MOO	0x00000020
+#define    PAS_DMA_RXINT_RCMDSTA_MBP	0x00000040
 #define    PAS_DMA_RXINT_RCMDSTA_BT	0x00000800
-#define    PAS_DMA_RXINT_RCMDSTA_TB	0x00001000
+#define    PAS_DMA_RXINT_RCMDSTA_DR	0x00001000
+#define    PAS_DMA_RXINT_RCMDSTA_OO	0x00002000
+#define    PAS_DMA_RXINT_RCMDSTA_BP	0x00004000
+#define    PAS_DMA_RXINT_RCMDSTA_TB	0x00008000
 #define    PAS_DMA_RXINT_RCMDSTA_ACT	0x00010000
 #define    PAS_DMA_RXINT_RCMDSTA_DROPS_M	0xfffe0000
 #define    PAS_DMA_RXINT_RCMDSTA_DROPS_S	17
@@ -297,6 +311,7 @@ enum {
 #define    PAS_STATUS_DCNT_S		16
 #define    PAS_STATUS_BPCNT_M		0x0000ffff00000000ull
 #define    PAS_STATUS_BPCNT_S		32
+#define    PAS_STATUS_CAUSE_M		0xf000000000000000ull
 #define    PAS_STATUS_TIMER		0x1000000000000000ull
 #define    PAS_STATUS_ERROR		0x2000000000000000ull
 #define    PAS_STATUS_SOFT		0x4000000000000000ull
diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2ps_cs.c
index 809ec44..258d6f3 100644
--- a/drivers/net/pcmcia/xirc2ps_cs.c
+++ b/drivers/net/pcmcia/xirc2ps_cs.c
@@ -1420,7 +1420,7 @@ set_addresses(struct net_device *dev)
     kio_addr_t ioaddr = dev->base_addr;
     local_info_t *lp = netdev_priv(dev);
     struct dev_mc_list *dmi = dev->mc_list;
-    char *addr;
+    unsigned char *addr;
     int i,j,k,n;
 
     SelectPage(k=0x50);
@@ -1429,6 +1429,9 @@ set_addresses(struct net_device *dev)
 	    if (++n > 9)
 		break;
 	    i = 0;
+	    if (n > 1 && n <= dev->mc_count && dmi) {
+	   	 dmi = dmi->next;
+	    }
 	}
 	if (j > 15) {
 	    j = 8;
@@ -1436,10 +1439,9 @@ set_addresses(struct net_device *dev)
 	    SelectPage(k);
 	}
 
-	if (n && n <= dev->mc_count && dmi) {
+	if (n && n <= dev->mc_count && dmi)
 	    addr = dmi->dmi_addr;
-	    dmi = dmi->next;
-	} else
+	else
 	    addr = dev->dev_addr;
 
 	if (lp->mohawk)
@@ -1465,10 +1467,10 @@ set_multicast_list(struct net_device *dev)
     if (dev->flags & IFF_PROMISC) { /* snoop */
 	PutByte(XIRCREG42_SWC1, 0x06); /* set MPE and PME */
     } else if (dev->mc_count > 9 || (dev->flags & IFF_ALLMULTI)) {
-	PutByte(XIRCREG42_SWC1, 0x06); /* set MPE */
+	PutByte(XIRCREG42_SWC1, 0x02); /* set MPE */
     } else if (dev->mc_count) {
 	/* the chip can filter 9 addresses perfectly */
-	PutByte(XIRCREG42_SWC1, 0x00);
+	PutByte(XIRCREG42_SWC1, 0x01);
 	SelectPage(0x40);
 	PutByte(XIRCREG40_CMD0, Offline);
 	set_addresses(dev);
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index 21afe10..b07da10 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -135,10 +135,13 @@ static void skge_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 /* Wake on Lan only supported on Yukon chips with rev 1 or above */
 static u32 wol_supported(const struct skge_hw *hw)
 {
-	if (hw->chip_id == CHIP_ID_YUKON && hw->chip_rev != 0)
-		return WAKE_MAGIC | WAKE_PHY;
-	else
+	if (hw->chip_id == CHIP_ID_GENESIS)
 		return 0;
+
+	if (hw->chip_id == CHIP_ID_YUKON && hw->chip_rev == 0)
+		return 0;
+
+	return WAKE_MAGIC | WAKE_PHY;
 }
 
 static u32 pci_wake_enabled(struct pci_dev *dev)
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 238c2ca..a307310 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -124,10 +124,7 @@ static const struct pci_device_id sky2_id_table[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4361) }, /* 88E8050 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4362) }, /* 88E8053 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4363) }, /* 88E8055 */
-#ifdef broken
-	/* This device causes data corruption problems that are not resolved */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4364) }, /* 88E8056 */
-#endif
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4366) }, /* 88EC036 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4367) }, /* 88EC032 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_MARVELL, 0x4368) }, /* 88EC034 */
@@ -3581,10 +3578,21 @@ static int __devinit sky2_probe(struct pci_dev *pdev,
 		goto err_out;
 	}
 
+	/* Some Gigabyte motherboards have 88e8056 but cause problems
+	 * There is some unresolved hardware related problem that causes
+	 * descriptor errors and receive data corruption.
+	 */
+	if (pdev->vendor == PCI_VENDOR_ID_MARVELL &&
+	    pdev->device == 0x4364 && pdev->subsystem_vendor == 0x1458) {
+		dev_err(&pdev->dev,
+			"88E8056 on Gigabyte motherboards not supported\n");
+		goto err_out_disable;
+	}
+
 	err = pci_request_regions(pdev, DRV_NAME);
 	if (err) {
 		dev_err(&pdev->dev, "cannot obtain PCI resources\n");
-		goto err_out;
+		goto err_out_disable;
 	}
 
 	pci_set_master(pdev);
@@ -3721,6 +3729,7 @@ err_out_free_hw:
 	kfree(hw);
 err_out_free_regions:
 	pci_release_regions(pdev);
+err_out_disable:
 	pci_disable_device(pdev);
 err_out:
 	return err;
diff --git a/drivers/net/smc91x.h b/drivers/net/smc91x.h
index 7053026..111f23d 100644
--- a/drivers/net/smc91x.h
+++ b/drivers/net/smc91x.h
@@ -279,6 +279,40 @@ SMC_outw(u16 val, void __iomem *ioaddr, int reg)
 #define SMC_insw(a, r, p, l)	insw((a) + (r), p, l)
 #define SMC_outsw(a, r, p, l)	outsw((a) + (r), p, l)
 
+#elif   defined(CONFIG_SUPERH)
+
+#if defined(CONFIG_SH_7780_SOLUTION_ENGINE) || defined(CONFIG_SH_7722_SOLUTION_ENGINE)
+#define SMC_CAN_USE_8BIT       0
+#define SMC_CAN_USE_16BIT      1
+#define SMC_CAN_USE_32BIT      0
+#define SMC_IO_SHIFT           0
+#define SMC_NOWAIT             1
+
+#define SMC_inb(a, r)          (inw((a) + ((r)&~1)) >> (8*(r%2)))&0xff
+#define SMC_inw(a, r)          inw((a) + (r))
+#define SMC_outb(v, a, r)      outw(((inw((a)+((r)&~1))*(0xff<<8*(r%2)))) | ((v)<<(8*(r&2)))), (a) + ((r)&~1))
+
+#define SMC_outw(v, a, r)      outw(v, (a) + (r))
+#define SMC_insw(a, r, p, l)   insw((a) + (r), p, l)
+#define SMC_outsw(a, r, p, l)  outsw((a) + (r), p, l)
+
+#else /* BOARDS */
+
+#define SMC_CAN_USE_8BIT       1
+#define SMC_CAN_USE_16BIT      1
+#define SMC_CAN_USE_32BIT      1
+
+#define SMC_inb(a, r)          inb((a) + (r))
+#define SMC_inw(a, r)          inw((a) + (r))
+#define SMC_outb(v, a, r)      outb(v, (a) + (r))
+#define SMC_outw(v, a, r)      outw(v, (a) + (r))
+#define SMC_insw(a, r, p, l)   insw((a) + (r), p, l)
+#define SMC_outsw(a, r, p, l)  outsw((a) + (r), p, l)
+
+#endif  /* BOARDS */
+
+#define set_irq_type(irq, type) do {} while (0)
+
 #elif   defined(CONFIG_M32R)
 
 #define SMC_CAN_USE_8BIT	0
diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index f1e2dfc..463d600 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -540,7 +540,6 @@ static struct sk_buff *alloc_rxbuf_skb(struct net_device *dev,
 	skb = dev_alloc_skb(RX_BUF_SIZE);
 	if (!skb)
 		return NULL;
-	skb->dev = dev;
 	*dma_handle = pci_map_single(hwdev, skb->data, RX_BUF_SIZE,
 				     PCI_DMA_FROMDEVICE);
 	if (pci_dma_mapping_error(*dma_handle)) {
diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index 0184614..e273347 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -267,7 +267,7 @@ config IPW2200_DEBUG
 
 config LIBERTAS_USB
 	tristate "Marvell Libertas 8388 802.11a/b/g cards"
-	depends on NET_RADIO && USB
+	depends on USB && WLAN_80211
 	select FW_LOADER
 	---help---
 	  A driver for Marvell Libertas 8388 USB devices.
diff --git a/drivers/s390/cio/qdio.c b/drivers/s390/cio/qdio.c
index cba64e4..f770018 100644
--- a/drivers/s390/cio/qdio.c
+++ b/drivers/s390/cio/qdio.c
@@ -996,18 +996,25 @@ __qdio_outbound_processing(struct qdio_q *q)
 	if (qdio_has_outbound_q_moved(q))
 		qdio_kick_outbound_handler(q);
 
-	if (q->is_iqdio_q) {
+	if (q->queue_type == QDIO_ZFCP_QFMT) {
+		if ((!q->hydra_gives_outbound_pcis) &&
+		    (!qdio_is_outbound_q_done(q)))
+			qdio_mark_q(q);
+	}
+	else if (((!q->is_iqdio_q) && (!q->is_pci_out)) ||
+		 (q->queue_type == QDIO_IQDIO_QFMT_ASYNCH)) {
 		/* 
-		 * for asynchronous queues, we better check, if the sent
-		 * buffer is already switched from PRIMED to EMPTY.
+		 * make sure buffer switch from PRIMED to EMPTY is noticed
+		 * and outbound_handler is called
 		 */
-		if ((q->queue_type == QDIO_IQDIO_QFMT_ASYNCH) &&
-		    !qdio_is_outbound_q_done(q))
-			qdio_mark_q(q);
-
-	} else if (!q->hydra_gives_outbound_pcis)
-		if (!qdio_is_outbound_q_done(q))
-			qdio_mark_q(q);
+		if (qdio_is_outbound_q_done(q)) {
+			del_timer(&q->timer);
+		} else {
+			if (!timer_pending(&q->timer))
+				mod_timer(&q->timer, jiffies +
+					  QDIO_FORCE_CHECK_TIMEOUT);
+		}
+	}
 
 	qdio_release_q(q);
 }
@@ -1826,6 +1833,7 @@ qdio_fill_qs(struct qdio_irq *irq_ptr, struct ccw_device *cdev,
 			q->queue_type = QDIO_IQDIO_QFMT_ASYNCH;
 		q->int_parm=int_parm;
 		q->is_input_q=0;
+		q->is_pci_out = 0;
 		q->schid = irq_ptr->schid;
 		q->cdev = cdev;
 		q->irq_ptr = irq_ptr;
@@ -1838,6 +1846,10 @@ qdio_fill_qs(struct qdio_irq *irq_ptr, struct ccw_device *cdev,
 		q->tasklet.data=(unsigned long)q;
 		q->tasklet.func=(void(*)(unsigned long))
 			&qdio_outbound_processing;
+		q->timer.function=(void(*)(unsigned long))
+			&qdio_outbound_processing;
+		q->timer.data = (long)q;
+		init_timer(&q->timer);
 
 		atomic_set(&q->busy_siga_counter,0);
 		q->timing.busy_start=0;
@@ -2635,6 +2647,7 @@ qdio_shutdown(struct ccw_device *cdev, int how)
 
 	for (i=0;i<irq_ptr->no_output_qs;i++) {
 		tasklet_kill(&irq_ptr->output_qs[i]->tasklet);
+		del_timer(&irq_ptr->output_qs[i]->timer);
 		wait_event_interruptible_timeout(cdev->private->wait_q,
 						 !atomic_read(&irq_ptr->
 							      output_qs[i]->
@@ -3458,6 +3471,10 @@ do_qdio_handle_outbound(struct qdio_q *q, unsigned int callflags,
 		qdio_perf_stat_inc(&perf_stats.outbound_cnt);
 		return;
 	}
+	if (callflags & QDIO_FLAG_PCI_OUT)
+		q->is_pci_out = 1;
+	else
+		q->is_pci_out = 0;
 	if (q->is_iqdio_q) {
 		/* one siga for every sbal */
 		while (count--)
diff --git a/drivers/s390/cio/qdio.h b/drivers/s390/cio/qdio.h
index 2895392..6d7aad1 100644
--- a/drivers/s390/cio/qdio.h
+++ b/drivers/s390/cio/qdio.h
@@ -60,6 +60,7 @@
 #define QDIO_ACTIVATE_TIMEOUT ((5*HZ)>>10)
 #define QDIO_CLEANUP_CLEAR_TIMEOUT (20*HZ)
 #define QDIO_CLEANUP_HALT_TIMEOUT (10*HZ)
+#define QDIO_FORCE_CHECK_TIMEOUT (10*HZ)
 
 enum qdio_irq_states {
 	QDIO_IRQ_STATE_INACTIVE,
@@ -511,8 +512,8 @@ struct qdio_q {
 
 	void *irq_ptr;
 
-#ifdef QDIO_USE_TIMERS_FOR_POLLING
 	struct timer_list timer;
+#ifdef QDIO_USE_TIMERS_FOR_POLLING
 	atomic_t timer_already_set;
 	spinlock_t timer_lock;
 #else /* QDIO_USE_TIMERS_FOR_POLLING */
@@ -558,6 +559,7 @@ struct qdio_q {
 	} timing;
 	atomic_t busy_siga_counter;
         unsigned int queue_type;
+	unsigned int is_pci_out;
 
 	/* leave this member at the end. won't be cleared in qdio_fill_qs */
 	struct slib *slib; /* a page is allocated under this pointer,
diff --git a/drivers/s390/net/netiucv.c b/drivers/s390/net/netiucv.c
index e10e85e..c358764 100644
--- a/drivers/s390/net/netiucv.c
+++ b/drivers/s390/net/netiucv.c
@@ -1862,12 +1862,14 @@ static void netiucv_remove_connection(struct iucv_connection *conn)
 	write_lock_bh(&iucv_connection_rwlock);
 	list_del_init(&conn->list);
 	write_unlock_bh(&iucv_connection_rwlock);
+	fsm_deltimer(&conn->timer);
+	netiucv_purge_skb_queue(&conn->collect_queue);
 	if (conn->path) {
 		iucv_path_sever(conn->path, iucvMagic);
 		kfree(conn->path);
 		conn->path = NULL;
 	}
-	fsm_deltimer(&conn->timer);
+	netiucv_purge_skb_queue(&conn->commit_queue);
 	kfree_fsm(conn->fsm);
 	kfree_skb(conn->rx_buff);
 	kfree_skb(conn->tx_buff);
@@ -2115,7 +2117,6 @@ static void __exit netiucv_exit(void)
 	while (!list_empty(&iucv_connection_list)) {
 		cp = list_entry(iucv_connection_list.next,
 				struct iucv_connection, list);
-		list_del(&cp->list);
 		ndev = cp->netdev;
 		priv = netdev_priv(ndev);
 		dev = priv->dev;
diff --git a/drivers/s390/net/qeth_eddp.c b/drivers/s390/net/qeth_eddp.c
index dd7034f..4640f32 100644
--- a/drivers/s390/net/qeth_eddp.c
+++ b/drivers/s390/net/qeth_eddp.c
@@ -620,10 +620,10 @@ qeth_eddp_create_context_tcp(struct qeth_card *card, struct sk_buff *skb,
 
 struct qeth_eddp_context *
 qeth_eddp_create_context(struct qeth_card *card, struct sk_buff *skb,
-			 struct qeth_hdr *qhdr)
+			 struct qeth_hdr *qhdr, unsigned char sk_protocol)
 {
 	QETH_DBF_TEXT(trace, 5, "creddpc");
-	switch (skb->sk->sk_protocol){
+	switch (sk_protocol) {
 	case IPPROTO_TCP:
 		return qeth_eddp_create_context_tcp(card, skb, qhdr);
 	default:
diff --git a/drivers/s390/net/qeth_eddp.h b/drivers/s390/net/qeth_eddp.h
index 103768d..52910c9 100644
--- a/drivers/s390/net/qeth_eddp.h
+++ b/drivers/s390/net/qeth_eddp.h
@@ -34,7 +34,8 @@ struct qeth_eddp_context_reference {
 };
 
 extern struct qeth_eddp_context *
-qeth_eddp_create_context(struct qeth_card *,struct sk_buff *,struct qeth_hdr *);
+qeth_eddp_create_context(struct qeth_card *,struct sk_buff *,
+			 struct qeth_hdr *, unsigned char);
 
 extern void
 qeth_eddp_put_context(struct qeth_eddp_context *);
diff --git a/drivers/s390/net/qeth_main.c b/drivers/s390/net/qeth_main.c
index 6fd8870..29d1760 100644
--- a/drivers/s390/net/qeth_main.c
+++ b/drivers/s390/net/qeth_main.c
@@ -1682,6 +1682,21 @@ qeth_put_reply(struct qeth_reply *reply)
 		kfree(reply);
 }
 
+static void
+qeth_issue_ipa_msg(struct qeth_ipa_cmd *cmd, struct qeth_card *card)
+{
+	int rc;
+	int com;
+	char * ipa_name;
+
+	com = cmd->hdr.command;
+	rc  = cmd->hdr.return_code;
+	ipa_name = qeth_get_ipa_cmd_name(com);
+
+	PRINT_ERR("%s(x%X) for %s returned x%X \"%s\"\n", ipa_name, com,
+		   QETH_CARD_IFNAME(card), rc, qeth_get_ipa_msg(rc));
+}
+
 static struct qeth_ipa_cmd *
 qeth_check_ipa_data(struct qeth_card *card, struct qeth_cmd_buffer *iob)
 {
@@ -1690,8 +1705,11 @@ qeth_check_ipa_data(struct qeth_card *card, struct qeth_cmd_buffer *iob)
 	QETH_DBF_TEXT(trace,5,"chkipad");
 	if (IS_IPA(iob->data)){
 		cmd = (struct qeth_ipa_cmd *) PDU_ENCAPSULATION(iob->data);
-		if (IS_IPA_REPLY(cmd))
+		if (IS_IPA_REPLY(cmd)) {
+			if (cmd->hdr.return_code)
+				qeth_issue_ipa_msg(cmd, card);
 			return cmd;
+		}
 		else {
 			switch (cmd->hdr.command) {
 			case IPA_CMD_STOPLAN:
@@ -2816,6 +2834,7 @@ qeth_flush_buffers(struct qeth_qdio_out_q *queue, int under_int,
 	struct qeth_qdio_out_buffer *buf;
 	int rc;
 	int i;
+	unsigned int qdio_flags;
 
 	QETH_DBF_TEXT(trace, 6, "flushbuf");
 
@@ -2859,13 +2878,13 @@ qeth_flush_buffers(struct qeth_qdio_out_q *queue, int under_int,
 		queue->card->perf_stats.outbound_do_qdio_start_time =
 			qeth_get_micros();
 	}
+	qdio_flags = QDIO_FLAG_SYNC_OUTPUT;
 	if (under_int)
-		rc = do_QDIO(CARD_DDEV(queue->card),
-			     QDIO_FLAG_SYNC_OUTPUT | QDIO_FLAG_UNDER_INTERRUPT,
-			     queue->queue_no, index, count, NULL);
-	else
-		rc = do_QDIO(CARD_DDEV(queue->card), QDIO_FLAG_SYNC_OUTPUT,
-			     queue->queue_no, index, count, NULL);
+		qdio_flags |= QDIO_FLAG_UNDER_INTERRUPT;
+	if (atomic_read(&queue->set_pci_flags_count))
+		qdio_flags |= QDIO_FLAG_PCI_OUT;
+	rc = do_QDIO(CARD_DDEV(queue->card), qdio_flags,
+		     queue->queue_no, index, count, NULL);
 	if (queue->card->options.performance_stats)
 		queue->card->perf_stats.outbound_do_qdio_time +=
 			qeth_get_micros() -
@@ -4490,7 +4509,8 @@ qeth_send_packet(struct qeth_card *card, struct sk_buff *skb)
 		qeth_fill_header(card, hdr, new_skb, ipv, cast_type);
 	}
 	if (large_send == QETH_LARGE_SEND_EDDP) {
-		ctx = qeth_eddp_create_context(card, new_skb, hdr);
+		ctx = qeth_eddp_create_context(card, new_skb, hdr,
+					       skb->sk->sk_protocol);
 		if (ctx == NULL) {
 			__qeth_free_new_skb(skb, new_skb);
 			PRINT_WARN("could not create eddp context\n");
@@ -5948,9 +5968,6 @@ qeth_layer2_send_setmac_cb(struct qeth_card *card,
 	cmd = (struct qeth_ipa_cmd *) data;
 	if (cmd->hdr.return_code) {
 		QETH_DBF_TEXT_(trace, 2, "L2er%x", cmd->hdr.return_code);
-		PRINT_WARN("Error in registering MAC address on " \
-			   "device %s: x%x\n", CARD_BUS_ID(card),
-			   cmd->hdr.return_code);
 		card->info.mac_bits &= ~QETH_LAYER2_MAC_REGISTERED;
 		cmd->hdr.return_code = -EIO;
 	} else {
@@ -5985,9 +6002,6 @@ qeth_layer2_send_delmac_cb(struct qeth_card *card,
 	QETH_DBF_TEXT(trace, 2, "L2Dmaccb");
 	cmd = (struct qeth_ipa_cmd *) data;
 	if (cmd->hdr.return_code) {
-		PRINT_WARN("Error in deregistering MAC address on " \
-			   "device %s: x%x\n", CARD_BUS_ID(card),
-			   cmd->hdr.return_code);
 		QETH_DBF_TEXT_(trace, 2, "err%d", cmd->hdr.return_code);
 		cmd->hdr.return_code = -EIO;
 		return 0;
@@ -6651,7 +6665,7 @@ qeth_setadpparms_change_macaddr_cb(struct qeth_card *card,
 	QETH_DBF_TEXT(trace,4,"chgmaccb");
 
 	cmd = (struct qeth_ipa_cmd *) data;
-	if (!card->options.layer2 || card->info.guestlan ||
+	if (!card->options.layer2 ||
 	    !(card->info.mac_bits & QETH_LAYER2_MAC_READ)) {
 		memcpy(card->dev->dev_addr,
 		       &cmd->data.setadapterparms.data.change_addr.addr,
@@ -8497,6 +8511,7 @@ __qeth_reboot_event_card(struct device *dev, void *data)
 	card = (struct qeth_card *) dev->driver_data;
 	qeth_clear_ip_list(card, 0, 0);
 	qeth_qdio_clear_card(card, 0);
+	qeth_clear_qdio_buffers(card);
 	return 0;
 }
 
diff --git a/drivers/s390/net/qeth_mpc.c b/drivers/s390/net/qeth_mpc.c
index 77c8320..f54fdfd 100644
--- a/drivers/s390/net/qeth_mpc.c
+++ b/drivers/s390/net/qeth_mpc.c
@@ -157,12 +157,113 @@ unsigned char READ_CCW[]={
 };
 
 
+struct ipa_rc_msg {
+	enum qeth_ipa_return_codes rc;
+	char *msg;
+};
 
+struct ipa_rc_msg qeth_ipa_rc_msg[] = {
+	{IPA_RC_SUCCESS,		"success"},
+	{IPA_RC_NOTSUPP,		"Command not supported"},
+	{IPA_RC_IP_TABLE_FULL,		"Add Addr IP Table Full - ipv6"},
+	{IPA_RC_UNKNOWN_ERROR,		"IPA command failed - reason unknown"},
+	{IPA_RC_UNSUPPORTED_COMMAND,	"Command not supported"},
+	{IPA_RC_DUP_IPV6_REMOTE,"ipv6 address already registered remote"},
+	{IPA_RC_DUP_IPV6_HOME,		"ipv6 address already registered"},
+	{IPA_RC_UNREGISTERED_ADDR,	"Address not registered"},
+	{IPA_RC_NO_ID_AVAILABLE,	"No identifiers available"},
+	{IPA_RC_ID_NOT_FOUND,		"Identifier not found"},
+	{IPA_RC_INVALID_IP_VERSION,	"IP version incorrect"},
+	{IPA_RC_LAN_FRAME_MISMATCH,	"LAN and frame mismatch"},
+	{IPA_RC_L2_UNSUPPORTED_CMD,	"Unsupported layer 2 command"},
+	{IPA_RC_L2_DUP_MAC,		"Duplicate MAC address"},
+	{IPA_RC_L2_ADDR_TABLE_FULL,	"Layer2 address table full"},
+	{IPA_RC_L2_DUP_LAYER3_MAC,	"Duplicate with layer 3 MAC"},
+	{IPA_RC_L2_GMAC_NOT_FOUND,	"GMAC not found"},
+	{IPA_RC_L2_MAC_NOT_FOUND,	"L2 mac address not found"},
+	{IPA_RC_L2_INVALID_VLAN_ID,	"L2 invalid vlan id"},
+	{IPA_RC_L2_DUP_VLAN_ID,		"L2 duplicate vlan id"},
+	{IPA_RC_L2_VLAN_ID_NOT_FOUND,	"L2 vlan id not found"},
+	{IPA_RC_DATA_MISMATCH,		"Data field mismatch (v4/v6 mixed)"},
+	{IPA_RC_INVALID_MTU_SIZE,	"Invalid MTU size"},
+	{IPA_RC_INVALID_LANTYPE,	"Invalid LAN type"},
+	{IPA_RC_INVALID_LANNUM,		"Invalid LAN num"},
+	{IPA_RC_DUPLICATE_IP_ADDRESS,	"Address already registered"},
+	{IPA_RC_IP_ADDR_TABLE_FULL,	"IP address table full"},
+	{IPA_RC_LAN_PORT_STATE_ERROR,	"LAN port state error"},
+	{IPA_RC_SETIP_NO_STARTLAN,	"Setip no startlan received"},
+	{IPA_RC_SETIP_ALREADY_RECEIVED,	"Setip already received"},
+	{IPA_RC_IP_ADDR_ALREADY_USED,	"IP address already in use on LAN"},
+	{IPA_RC_MULTICAST_FULL,		"No task available, multicast full"},
+	{IPA_RC_SETIP_INVALID_VERSION,	"SETIP invalid IP version"},
+	{IPA_RC_UNSUPPORTED_SUBCMD,	"Unsupported assist subcommand"},
+	{IPA_RC_ARP_ASSIST_NO_ENABLE,	"Only partial success, no enable"},
+	{IPA_RC_PRIMARY_ALREADY_DEFINED,"Primary already defined"},
+	{IPA_RC_SECOND_ALREADY_DEFINED,	"Secondary already defined"},
+	{IPA_RC_INVALID_SETRTG_INDICATOR,"Invalid SETRTG indicator"},
+	{IPA_RC_MC_ADDR_ALREADY_DEFINED,"Multicast address already defined"},
+	{IPA_RC_LAN_OFFLINE,		"STRTLAN_LAN_DISABLED - LAN offline"},
+	{IPA_RC_INVALID_IP_VERSION2,	"Invalid IP version"},
+	{IPA_RC_FFFF,			"Unknown Error"}
+};
 
 
 
+char *
+qeth_get_ipa_msg(enum qeth_ipa_return_codes rc)
+{
+	int x = 0;
+	qeth_ipa_rc_msg[sizeof(qeth_ipa_rc_msg) /
+			sizeof(struct ipa_rc_msg) - 1].rc = rc;
+	while(qeth_ipa_rc_msg[x].rc != rc)
+		x++;
+	return qeth_ipa_rc_msg[x].msg;
+}
 
 
+struct ipa_cmd_names {
+	enum qeth_ipa_cmds cmd;
+	char *name;
+};
+
+struct ipa_cmd_names qeth_ipa_cmd_names[] = {
+	{IPA_CMD_STARTLAN,	"startlan"},
+	{IPA_CMD_STOPLAN,	"stoplan"},
+	{IPA_CMD_SETVMAC,	"setvmac"},
+	{IPA_CMD_DELVMAC,	"delvmca"},
+	{IPA_CMD_SETGMAC,	"setgmac"},
+	{IPA_CMD_DELGMAC,	"delgmac"},
+	{IPA_CMD_SETVLAN,	"setvlan"},
+	{IPA_CMD_DELVLAN,	"delvlan"},
+	{IPA_CMD_SETCCID,	"setccid"},
+	{IPA_CMD_DELCCID,	"delccid"},
+	{IPA_CMD_MODCCID,	"setip"},
+	{IPA_CMD_SETIP,		"setip"},
+	{IPA_CMD_QIPASSIST,	"qipassist"},
+	{IPA_CMD_SETASSPARMS,	"setassparms"},
+	{IPA_CMD_SETIPM,	"setipm"},
+	{IPA_CMD_DELIPM,	"delipm"},
+	{IPA_CMD_SETRTG,	"setrtg"},
+	{IPA_CMD_DELIP,		"delip"},
+	{IPA_CMD_SETADAPTERPARMS, "setadapterparms"},
+	{IPA_CMD_SET_DIAG_ASS,	"set_diag_ass"},
+	{IPA_CMD_CREATE_ADDR,	"create_addr"},
+	{IPA_CMD_DESTROY_ADDR,	"destroy_addr"},
+	{IPA_CMD_REGISTER_LOCAL_ADDR,	"register_local_addr"},
+	{IPA_CMD_UNREGISTER_LOCAL_ADDR,	"unregister_local_addr"},
+	{IPA_CMD_UNKNOWN,	"unknown"},
+};
 
+char *
+qeth_get_ipa_cmd_name(enum qeth_ipa_cmds cmd)
+{
+	int x = 0;
+	qeth_ipa_cmd_names[
+		sizeof(qeth_ipa_cmd_names)/
+			sizeof(struct ipa_cmd_names)-1].cmd = cmd;
+	while(qeth_ipa_cmd_names[x].cmd != cmd)
+		x++;
+	return qeth_ipa_cmd_names[x].name;
+}
 
 
diff --git a/drivers/s390/net/qeth_mpc.h b/drivers/s390/net/qeth_mpc.h
index d74bc43..1d8083c 100644
--- a/drivers/s390/net/qeth_mpc.h
+++ b/drivers/s390/net/qeth_mpc.h
@@ -25,14 +25,14 @@ extern unsigned char IPA_PDU_HEADER[];
 
 #define IPA_CMD_LENGTH	(IPA_PDU_HEADER_SIZE + sizeof(struct qeth_ipa_cmd))
 
-#define QETH_SEQ_NO_LENGTH 	4
-#define QETH_MPC_TOKEN_LENGTH 	4
+#define QETH_SEQ_NO_LENGTH	4
+#define QETH_MPC_TOKEN_LENGTH	4
 #define QETH_MCL_LENGTH		4
 #define OSA_ADDR_LEN		6
 
-#define QETH_TIMEOUT 		(10 * HZ)
-#define QETH_IPA_TIMEOUT 	(45 * HZ)
-#define QETH_IDX_COMMAND_SEQNO 	0xffff0000
+#define QETH_TIMEOUT		(10 * HZ)
+#define QETH_IPA_TIMEOUT	(45 * HZ)
+#define QETH_IDX_COMMAND_SEQNO	0xffff0000
 #define SR_INFO_LEN		16
 
 #define QETH_CLEAR_CHANNEL_PARM	-10
@@ -93,79 +93,107 @@ enum qeth_checksum_types {
  */
 #define RESET_ROUTING_FLAG 0x10 /* indicate that routing type shall be set */
 enum qeth_routing_types {
-	NO_ROUTER           = 0, /* TODO: set to bit flag used in IPA Command */
-	PRIMARY_ROUTER      = 1,
-	SECONDARY_ROUTER    = 2,
-	MULTICAST_ROUTER    = 3,
-	PRIMARY_CONNECTOR   = 4,
-	SECONDARY_CONNECTOR = 5,
+	NO_ROUTER		= 0, /* TODO: set to bit flag used in IPA Command */
+	PRIMARY_ROUTER		= 1,
+	SECONDARY_ROUTER	= 2,
+	MULTICAST_ROUTER	= 3,
+	PRIMARY_CONNECTOR	= 4,
+	SECONDARY_CONNECTOR	= 5,
 };
 
-
 /* IPA Commands */
 enum qeth_ipa_cmds {
-	IPA_CMD_STARTLAN              = 0x01,
-	IPA_CMD_STOPLAN               = 0x02,
-	IPA_CMD_SETVMAC 	      = 0x21,
-	IPA_CMD_DELVMAC 	      =	0x22,
-	IPA_CMD_SETGMAC  	      = 0x23,
-	IPA_CMD_DELGMAC 	      = 0x24,
-	IPA_CMD_SETVLAN 	      = 0x25,
-	IPA_CMD_DELVLAN 	      = 0x26,
-	IPA_CMD_SETCCID               = 0x41,
-	IPA_CMD_DELCCID               = 0x42,
-	IPA_CMD_MODCCID               = 0x43,
-	IPA_CMD_SETIP                 = 0xb1,
-	IPA_CMD_DELIP                 = 0xb7,
-	IPA_CMD_QIPASSIST             = 0xb2,
-	IPA_CMD_SETASSPARMS           = 0xb3,
-	IPA_CMD_SETIPM                = 0xb4,
-	IPA_CMD_DELIPM                = 0xb5,
-	IPA_CMD_SETRTG                = 0xb6,
-	IPA_CMD_SETADAPTERPARMS       = 0xb8,
-	IPA_CMD_IPFRAME               = 0xb9,
-	IPA_CMD_ADD_ADDR_ENTRY        = 0xc1,
-	IPA_CMD_DELETE_ADDR_ENTRY     = 0xc2,
-	IPA_CMD_CREATE_ADDR           = 0xc3,
-	IPA_CMD_DESTROY_ADDR          = 0xc4,
-	IPA_CMD_REGISTER_LOCAL_ADDR   = 0xd1,
-	IPA_CMD_UNREGISTER_LOCAL_ADDR = 0xd2,
+	IPA_CMD_STARTLAN		= 0x01,
+	IPA_CMD_STOPLAN			= 0x02,
+	IPA_CMD_SETVMAC			= 0x21,
+	IPA_CMD_DELVMAC			= 0x22,
+	IPA_CMD_SETGMAC			= 0x23,
+	IPA_CMD_DELGMAC			= 0x24,
+	IPA_CMD_SETVLAN			= 0x25,
+	IPA_CMD_DELVLAN			= 0x26,
+	IPA_CMD_SETCCID			= 0x41,
+	IPA_CMD_DELCCID			= 0x42,
+	IPA_CMD_MODCCID			= 0x43,
+	IPA_CMD_SETIP			= 0xb1,
+	IPA_CMD_QIPASSIST		= 0xb2,
+	IPA_CMD_SETASSPARMS		= 0xb3,
+	IPA_CMD_SETIPM			= 0xb4,
+	IPA_CMD_DELIPM			= 0xb5,
+	IPA_CMD_SETRTG			= 0xb6,
+	IPA_CMD_DELIP			= 0xb7,
+	IPA_CMD_SETADAPTERPARMS		= 0xb8,
+	IPA_CMD_SET_DIAG_ASS		= 0xb9,
+	IPA_CMD_CREATE_ADDR		= 0xc3,
+	IPA_CMD_DESTROY_ADDR		= 0xc4,
+	IPA_CMD_REGISTER_LOCAL_ADDR	= 0xd1,
+	IPA_CMD_UNREGISTER_LOCAL_ADDR	= 0xd2,
+	IPA_CMD_UNKNOWN			= 0x00
 };
 
 enum qeth_ip_ass_cmds {
 	IPA_CMD_ASS_START	= 0x0001,
 	IPA_CMD_ASS_STOP	= 0x0002,
-	IPA_CMD_ASS_CONFIGURE 	= 0x0003,
-	IPA_CMD_ASS_ENABLE 	= 0x0004,
+	IPA_CMD_ASS_CONFIGURE	= 0x0003,
+	IPA_CMD_ASS_ENABLE	= 0x0004,
 };
 
 enum qeth_arp_process_subcmds {
-	IPA_CMD_ASS_ARP_SET_NO_ENTRIES 	= 0x0003,
-	IPA_CMD_ASS_ARP_QUERY_CACHE 	= 0x0004,
-	IPA_CMD_ASS_ARP_ADD_ENTRY 	= 0x0005,
-	IPA_CMD_ASS_ARP_REMOVE_ENTRY 	= 0x0006,
-	IPA_CMD_ASS_ARP_FLUSH_CACHE 	= 0x0007,
-	IPA_CMD_ASS_ARP_QUERY_INFO 	= 0x0104,
-	IPA_CMD_ASS_ARP_QUERY_STATS 	= 0x0204,
+	IPA_CMD_ASS_ARP_SET_NO_ENTRIES	= 0x0003,
+	IPA_CMD_ASS_ARP_QUERY_CACHE	= 0x0004,
+	IPA_CMD_ASS_ARP_ADD_ENTRY	= 0x0005,
+	IPA_CMD_ASS_ARP_REMOVE_ENTRY	= 0x0006,
+	IPA_CMD_ASS_ARP_FLUSH_CACHE	= 0x0007,
+	IPA_CMD_ASS_ARP_QUERY_INFO	= 0x0104,
+	IPA_CMD_ASS_ARP_QUERY_STATS	= 0x0204,
 };
 
-/* Return Codes for IPA Commands */
+
+/* Return Codes for IPA Commands
+ * according to OSA card Specs */
+
 enum qeth_ipa_return_codes {
-	IPA_RC_SUCCESS             = 0x0000,
-	IPA_RC_NOTSUPP             = 0x0001,
-	IPA_RC_NO_ACCESS           = 0x0002,
-	IPA_RC_FAILED              = 0x0003,
-	IPA_RC_DATA_MISMATCH       = 0xe001,
-	IPA_RC_INVALID_LAN_TYPE    = 0xe003,
-	IPA_RC_INVALID_LAN_NO      = 0xe004,
-	IPA_RC_IPADDR_ALREADY_REG  = 0xe005,
-	IPA_RC_IPADDR_TABLE_FULL   = 0xe006,
-	IPA_RC_IPADDR_ALREADY_USED = 0xe00a,
-	IPA_RC_ASSNO_NOT_SUPP      = 0xe00d,
-	IPA_RC_ASSCMD_START_FAILED = 0xe00e,
-	IPA_RC_ASSCMD_PART_SUCCESS = 0xe00f,
-	IPA_RC_IPADDR_NOT_DEFINED  = 0xe010,
-	IPA_RC_LAN_OFFLINE         = 0xe080,
+	IPA_RC_SUCCESS			= 0x0000,
+	IPA_RC_NOTSUPP			= 0x0001,
+	IPA_RC_IP_TABLE_FULL		= 0x0002,
+	IPA_RC_UNKNOWN_ERROR		= 0x0003,
+	IPA_RC_UNSUPPORTED_COMMAND	= 0x0004,
+	IPA_RC_DUP_IPV6_REMOTE		= 0x0008,
+	IPA_RC_DUP_IPV6_HOME		= 0x0010,
+	IPA_RC_UNREGISTERED_ADDR	= 0x0011,
+	IPA_RC_NO_ID_AVAILABLE		= 0x0012,
+	IPA_RC_ID_NOT_FOUND		= 0x0013,
+	IPA_RC_INVALID_IP_VERSION	= 0x0020,
+	IPA_RC_LAN_FRAME_MISMATCH	= 0x0040,
+	IPA_RC_L2_UNSUPPORTED_CMD	= 0x2003,
+	IPA_RC_L2_DUP_MAC		= 0x2005,
+	IPA_RC_L2_ADDR_TABLE_FULL	= 0x2006,
+	IPA_RC_L2_DUP_LAYER3_MAC	= 0x200a,
+	IPA_RC_L2_GMAC_NOT_FOUND	= 0x200b,
+	IPA_RC_L2_MAC_NOT_FOUND		= 0x2010,
+	IPA_RC_L2_INVALID_VLAN_ID	= 0x2015,
+	IPA_RC_L2_DUP_VLAN_ID		= 0x2016,
+	IPA_RC_L2_VLAN_ID_NOT_FOUND	= 0x2017,
+	IPA_RC_DATA_MISMATCH		= 0xe001,
+	IPA_RC_INVALID_MTU_SIZE		= 0xe002,
+	IPA_RC_INVALID_LANTYPE		= 0xe003,
+	IPA_RC_INVALID_LANNUM		= 0xe004,
+	IPA_RC_DUPLICATE_IP_ADDRESS	= 0xe005,
+	IPA_RC_IP_ADDR_TABLE_FULL	= 0xe006,
+	IPA_RC_LAN_PORT_STATE_ERROR	= 0xe007,
+	IPA_RC_SETIP_NO_STARTLAN	= 0xe008,
+	IPA_RC_SETIP_ALREADY_RECEIVED	= 0xe009,
+	IPA_RC_IP_ADDR_ALREADY_USED	= 0xe00a,
+	IPA_RC_MULTICAST_FULL		= 0xe00b,
+	IPA_RC_SETIP_INVALID_VERSION	= 0xe00d,
+	IPA_RC_UNSUPPORTED_SUBCMD	= 0xe00e,
+	IPA_RC_ARP_ASSIST_NO_ENABLE	= 0xe00f,
+	IPA_RC_PRIMARY_ALREADY_DEFINED	= 0xe010,
+	IPA_RC_SECOND_ALREADY_DEFINED	= 0xe011,
+	IPA_RC_INVALID_SETRTG_INDICATOR	= 0xe012,
+	IPA_RC_MC_ADDR_ALREADY_DEFINED	= 0xe013,
+	IPA_RC_LAN_OFFLINE		= 0xe080,
+	IPA_RC_INVALID_IP_VERSION2	= 0xf001,
+	IPA_RC_FFFF			= 0xffff
 };
 
 /* IPA function flags; each flag marks availability of respective function */
@@ -183,7 +211,9 @@ enum qeth_ipa_funcs {
 	IPA_SETADAPTERPARMS     = 0x00000400L,
 	IPA_VLAN_PRIO           = 0x00000800L,
 	IPA_PASSTHRU            = 0x00001000L,
+	IPA_FLUSH_ARP_SUPPORT   = 0x00002000L,
 	IPA_FULL_VLAN           = 0x00004000L,
+	IPA_INBOUND_PASSTHRU    = 0x00008000L,
 	IPA_SOURCE_MAC          = 0x00010000L,
 	IPA_OSA_MC_ROUTER       = 0x00020000L,
 	IPA_QUERY_ARP_ASSIST	= 0x00040000L,
@@ -204,31 +234,30 @@ enum qeth_ipa_setdelip_flags {
 /* SETADAPTER IPA Command: ****************************************************/
 enum qeth_ipa_setadp_cmd {
 	IPA_SETADP_QUERY_COMMANDS_SUPPORTED	= 0x01,
-	IPA_SETADP_ALTER_MAC_ADDRESS 		= 0x02,
-	IPA_SETADP_ADD_DELETE_GROUP_ADDRESS 	= 0x04,
-	IPA_SETADP_ADD_DELETE_FUNCTIONAL_ADDR 	= 0x08,
-	IPA_SETADP_SET_ADDRESSING_MODE 		= 0x10,
-	IPA_SETADP_SET_CONFIG_PARMS 		= 0x20,
-	IPA_SETADP_SET_CONFIG_PARMS_EXTENDED 	= 0x40,
-	IPA_SETADP_SET_BROADCAST_MODE 		= 0x80,
-	IPA_SETADP_SEND_OSA_MESSAGE 		= 0x0100,
-	IPA_SETADP_SET_SNMP_CONTROL 		= 0x0200,
-	IPA_SETADP_READ_SNMP_PARMS 		= 0x0400,
+	IPA_SETADP_ALTER_MAC_ADDRESS		= 0x02,
+	IPA_SETADP_ADD_DELETE_GROUP_ADDRESS	= 0x04,
+	IPA_SETADP_ADD_DELETE_FUNCTIONAL_ADDR	= 0x08,
+	IPA_SETADP_SET_ADDRESSING_MODE		= 0x10,
+	IPA_SETADP_SET_CONFIG_PARMS		= 0x20,
+	IPA_SETADP_SET_CONFIG_PARMS_EXTENDED	= 0x40,
+	IPA_SETADP_SET_BROADCAST_MODE		= 0x80,
+	IPA_SETADP_SEND_OSA_MESSAGE		= 0x0100,
+	IPA_SETADP_SET_SNMP_CONTROL		= 0x0200,
+	IPA_SETADP_QUERY_CARD_INFO		= 0x0400,
 	IPA_SETADP_SET_PROMISC_MODE		= 0x0800,
-	IPA_SETADP_QUERY_CARD_INFO 		= 0x1000,
 };
 enum qeth_ipa_mac_ops {
-	CHANGE_ADDR_READ_MAC 		= 0,
-	CHANGE_ADDR_REPLACE_MAC 	= 1,
-	CHANGE_ADDR_ADD_MAC 		= 2,
-	CHANGE_ADDR_DEL_MAC 		= 4,
-	CHANGE_ADDR_RESET_MAC 		= 8,
+	CHANGE_ADDR_READ_MAC		= 0,
+	CHANGE_ADDR_REPLACE_MAC		= 1,
+	CHANGE_ADDR_ADD_MAC		= 2,
+	CHANGE_ADDR_DEL_MAC		= 4,
+	CHANGE_ADDR_RESET_MAC		= 8,
 };
 enum qeth_ipa_addr_ops {
-	CHANGE_ADDR_READ_ADDR 		= 0,
-	CHANGE_ADDR_ADD_ADDR 		= 1,
-	CHANGE_ADDR_DEL_ADDR 		= 2,
-	CHANGE_ADDR_FLUSH_ADDR_TABLE 	= 4,
+	CHANGE_ADDR_READ_ADDR		= 0,
+	CHANGE_ADDR_ADD_ADDR		= 1,
+	CHANGE_ADDR_DEL_ADDR		= 2,
+	CHANGE_ADDR_FLUSH_ADDR_TABLE	= 4,
 };
 enum qeth_ipa_promisc_modes {
 	SET_PROMISC_MODE_OFF		= 0,
@@ -407,15 +436,15 @@ struct qeth_ipacmd_hdr {
 struct qeth_ipa_cmd {
 	struct qeth_ipacmd_hdr hdr;
 	union {
-		struct qeth_ipacmd_setdelip4   		setdelip4;
-		struct qeth_ipacmd_setdelip6   		setdelip6;
+		struct qeth_ipacmd_setdelip4		setdelip4;
+		struct qeth_ipacmd_setdelip6		setdelip6;
 		struct qeth_ipacmd_setdelipm		setdelipm;
-		struct qeth_ipacmd_setassparms 		setassparms;
-		struct qeth_ipacmd_layer2setdelmac  	setdelmac;
-		struct qeth_ipacmd_layer2setdelvlan 	setdelvlan;
-		struct qeth_create_destroy_address 	create_destroy_addr;
-		struct qeth_ipacmd_setadpparms 		setadapterparms;
-		struct qeth_set_routing 		setrtg;
+		struct qeth_ipacmd_setassparms		setassparms;
+		struct qeth_ipacmd_layer2setdelmac	setdelmac;
+		struct qeth_ipacmd_layer2setdelvlan	setdelvlan;
+		struct qeth_create_destroy_address	create_destroy_addr;
+		struct qeth_ipacmd_setadpparms		setadapterparms;
+		struct qeth_set_routing			setrtg;
 	} data;
 } __attribute__ ((packed));
 
@@ -433,6 +462,12 @@ enum qeth_ipa_arp_return_codes {
 	QETH_IPA_ARP_RC_Q_NO_DATA    = 0x0008,
 };
 
+
+extern char *
+qeth_get_ipa_msg(enum qeth_ipa_return_codes rc);
+extern char *
+qeth_get_ipa_cmd_name(enum qeth_ipa_cmds cmd);
+
 #define QETH_SETASS_BASE_LEN (sizeof(struct qeth_ipacmd_hdr) + \
 			       sizeof(struct qeth_ipacmd_setassparms_hdr))
 #define QETH_IPA_ARP_DATA_POS(buffer) (buffer + IPA_PDU_HEADER_SIZE + \
@@ -521,7 +556,7 @@ extern unsigned char DM_ACT[];
 extern unsigned char IDX_ACTIVATE_READ[];
 extern unsigned char IDX_ACTIVATE_WRITE[];
 
-#define IDX_ACTIVATE_SIZE 	0x22
+#define IDX_ACTIVATE_SIZE	0x22
 #define QETH_IDX_ACT_ISSUER_RM_TOKEN(buffer) (buffer+0x0c)
 #define QETH_IDX_NO_PORTNAME_REQUIRED(buffer) ((buffer)[0x0b]&0x80)
 #define QETH_IDX_ACT_FUNC_LEVEL(buffer) (buffer+0x10)
diff --git a/drivers/s390/net/qeth_sys.c b/drivers/s390/net/qeth_sys.c
index d518419..65ffc21 100644
--- a/drivers/s390/net/qeth_sys.c
+++ b/drivers/s390/net/qeth_sys.c
@@ -384,8 +384,6 @@ qeth_dev_route_store(struct qeth_card *card, struct qeth_routing_info *route,
 		route->type = PRIMARY_CONNECTOR;
 	} else if (!strcmp(tmp, "secondary_connector")) {
 		route->type = SECONDARY_CONNECTOR;
-	} else if (!strcmp(tmp, "multicast_router")) {
-		route->type = MULTICAST_ROUTER;
 	} else if (!strcmp(tmp, "primary_router")) {
 		route->type = PRIMARY_ROUTER;
 	} else if (!strcmp(tmp, "secondary_router")) {
diff --git a/include/asm-s390/qdio.h b/include/asm-s390/qdio.h
index 127f72e..74db1dc 100644
--- a/include/asm-s390/qdio.h
+++ b/include/asm-s390/qdio.h
@@ -120,6 +120,7 @@ extern unsigned long qdio_get_status(int irq);
 #define QDIO_FLAG_NO_INPUT_INTERRUPT_CONTEXT 0x08 /* no effect on
 						     adapter interrupts */
 #define QDIO_FLAG_DONT_SIGA 0x10
+#define QDIO_FLAG_PCI_OUT   0x20
 
 extern int do_QDIO(struct ccw_device*, unsigned int flags, 
 		   unsigned int queue_number,
