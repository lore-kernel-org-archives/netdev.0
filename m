From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: [PATCH 2/2] bcm43xx: convert driver to use ssb
Date: Wed, 23 Aug 2006 12:01:07 +0200
Message-ID: <200608231201.07991.mb@bu3sch.de>
References: <200608231158.06178.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
In-Reply-To: <200608231158.06178.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch converts the bcm43xx driver to use the new
ssb driver backend.

Signed-off-by: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>

Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h	2006-08-23 10:47:32.000000000 +0200
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h	2006-08-23 11:27:27.000000000 +0200
@@ -11,6 +11,7 @@
 #include <asm/atomic.h>
 #include <asm/io.h>
 
+#include <linux/ssb.h>
 #include <linux/wireless.h>
 #include <net/d80211.h>
 #include <net/d80211_mgmt.h>
@@ -22,18 +23,10 @@
 
 #define PFX				KBUILD_MODNAME ": "
 
-#define BCM43xx_SWITCH_CORE_MAX_RETRIES	50
 #define BCM43xx_IRQWAIT_MAX_RETRIES	50
 
 #define BCM43xx_IO_SIZE			8192
 
-/* Active Core PCI Configuration Register. */
-#define BCM43xx_PCICFG_ACTIVE_CORE	0x80
-/* SPROM control register. */
-#define BCM43xx_PCICFG_SPROMCTL		0x88
-/* Interrupt Control PCI Configuration Register. (Only on PCI cores with rev >= 6) */
-#define BCM43xx_PCICFG_ICR		0x94
-
 /* MMIO offsets */
 #define BCM43xx_MMIO_DMA0_REASON	0x20
 #define BCM43xx_MMIO_DMA0_IRQ_MASK	0x24
@@ -104,29 +97,7 @@
 #define BCM43xx_MMIO_TSF_3		0x638 /* core rev < 3 only */
 #define BCM43xx_MMIO_POWERUP_DELAY	0x6A8
 
-/* SPROM offsets. */
-#define BCM43xx_SPROM_BASE		0x1000
-#define BCM43xx_SPROM_BOARDFLAGS2	0x1c
-#define BCM43xx_SPROM_IL0MACADDR	0x24
-#define BCM43xx_SPROM_ET0MACADDR	0x27
-#define BCM43xx_SPROM_ET1MACADDR	0x2a
-#define BCM43xx_SPROM_ETHPHY		0x2d
-#define BCM43xx_SPROM_BOARDREV		0x2e
-#define BCM43xx_SPROM_PA0B0		0x2f
-#define BCM43xx_SPROM_PA0B1		0x30
-#define BCM43xx_SPROM_PA0B2		0x31
-#define BCM43xx_SPROM_WL0GPIO0		0x32
-#define BCM43xx_SPROM_WL0GPIO2		0x33
-#define BCM43xx_SPROM_MAXPWR		0x34
-#define BCM43xx_SPROM_PA1B0		0x35
-#define BCM43xx_SPROM_PA1B1		0x36
-#define BCM43xx_SPROM_PA1B2		0x37
-#define BCM43xx_SPROM_IDL_TSSI_TGT	0x38
-#define BCM43xx_SPROM_BOARDFLAGS	0x39
-#define BCM43xx_SPROM_ANTENNA_GAIN	0x3a
-#define BCM43xx_SPROM_VERSION		0x3f
-
-/* BCM43xx_SPROM_BOARDFLAGS values */
+/* SPROM boardflags_lo values */
 #define BCM43xx_BFL_BTCOEXIST		0x0001 /* implements Bluetooth coexistance */
 #define BCM43xx_BFL_PACTRL		0x0002 /* GPIO 9 controlling the PA */
 #define BCM43xx_BFL_AIRLINEMODE		0x0004 /* implements GPIO 13 radio disable indication */
@@ -158,35 +129,6 @@
 #define BCM43xx_MACFILTER_SELF		0x0000
 #define BCM43xx_MACFILTER_ASSOC		0x0003
 
-/* Chipcommon registers. */
-#define BCM43xx_CHIPCOMMON_CAPABILITIES 	0x04
-#define BCM43xx_CHIPCOMMON_PLLONDELAY		0xB0
-#define BCM43xx_CHIPCOMMON_FREFSELDELAY		0xB4
-#define BCM43xx_CHIPCOMMON_SLOWCLKCTL		0xB8
-#define BCM43xx_CHIPCOMMON_SYSCLKCTL		0xC0
-
-/* PCI core specific registers. */
-#define BCM43xx_PCICORE_BCAST_ADDR	0x50
-#define BCM43xx_PCICORE_BCAST_DATA	0x54
-#define BCM43xx_PCICORE_SBTOPCI2	0x108
-
-/* SBTOPCI2 values. */
-#define BCM43xx_SBTOPCI2_PREFETCH	0x4
-#define BCM43xx_SBTOPCI2_BURST		0x8
-
-/* Chipcommon capabilities. */
-#define BCM43xx_CAPABILITIES_PCTL		0x00040000
-#define BCM43xx_CAPABILITIES_PLLMASK		0x00030000
-#define BCM43xx_CAPABILITIES_PLLSHIFT		16
-#define BCM43xx_CAPABILITIES_FLASHMASK		0x00000700
-#define BCM43xx_CAPABILITIES_FLASHSHIFT		8
-#define BCM43xx_CAPABILITIES_EXTBUSPRESENT	0x00000040
-#define BCM43xx_CAPABILITIES_UARTGPIO		0x00000020
-#define BCM43xx_CAPABILITIES_UARTCLOCKMASK	0x00000018
-#define BCM43xx_CAPABILITIES_UARTCLOCKSHIFT	3
-#define BCM43xx_CAPABILITIES_MIPSBIGENDIAN	0x00000004
-#define BCM43xx_CAPABILITIES_NRUARTSMASK	0x00000003
-
 /* PowerControl */
 #define BCM43xx_PCTL_IN			0xB0
 #define BCM43xx_PCTL_OUT		0xB4
@@ -203,67 +145,6 @@
 #define BCM43xx_PCTL_FORCE_PLL		0x1000
 #define BCM43xx_PCTL_DYN_XTAL		0x2000
 
-/* COREIDs */
-#define BCM43xx_COREID_CHIPCOMMON	0x800
-#define BCM43xx_COREID_ILINE20          0x801
-#define BCM43xx_COREID_SDRAM            0x803
-#define BCM43xx_COREID_PCI		0x804
-#define BCM43xx_COREID_MIPS             0x805
-#define BCM43xx_COREID_ETHERNET         0x806
-#define BCM43xx_COREID_V90		0x807
-#define BCM43xx_COREID_USB11_HOSTDEV    0x80a
-#define BCM43xx_COREID_IPSEC            0x80b
-#define BCM43xx_COREID_PCMCIA		0x80d
-#define BCM43xx_COREID_EXT_IF           0x80f
-#define BCM43xx_COREID_80211		0x812
-#define BCM43xx_COREID_MIPS_3302        0x816
-#define BCM43xx_COREID_USB11_HOST       0x817
-#define BCM43xx_COREID_USB11_DEV        0x818
-#define BCM43xx_COREID_USB20_HOST       0x819
-#define BCM43xx_COREID_USB20_DEV        0x81a
-#define BCM43xx_COREID_SDIO_HOST        0x81b
-
-/* Core Information Registers */
-#define BCM43xx_CIR_BASE		0xf00
-#define BCM43xx_CIR_SBTPSFLAG		(BCM43xx_CIR_BASE + 0x18)
-#define BCM43xx_CIR_SBIMSTATE		(BCM43xx_CIR_BASE + 0x90)
-#define BCM43xx_CIR_SBINTVEC		(BCM43xx_CIR_BASE + 0x94)
-#define BCM43xx_CIR_SBTMSTATELOW	(BCM43xx_CIR_BASE + 0x98)
-#define BCM43xx_CIR_SBTMSTATEHIGH	(BCM43xx_CIR_BASE + 0x9c)
-#define BCM43xx_CIR_SBIMCONFIGLOW	(BCM43xx_CIR_BASE + 0xa8)
-#define BCM43xx_CIR_SB_ID_HI		(BCM43xx_CIR_BASE + 0xfc)
-
-/* Mask to get the Backplane Flag Number from SBTPSFLAG. */
-#define BCM43xx_BACKPLANE_FLAG_NR_MASK	0x3f
-
-/* SBIMCONFIGLOW values/masks. */
-#define BCM43xx_SBIMCONFIGLOW_SERVICE_TOUT_MASK		0x00000007
-#define BCM43xx_SBIMCONFIGLOW_SERVICE_TOUT_SHIFT	0
-#define BCM43xx_SBIMCONFIGLOW_REQUEST_TOUT_MASK		0x00000070
-#define BCM43xx_SBIMCONFIGLOW_REQUEST_TOUT_SHIFT	4
-#define BCM43xx_SBIMCONFIGLOW_CONNID_MASK		0x00ff0000
-#define BCM43xx_SBIMCONFIGLOW_CONNID_SHIFT		16
-
-/* sbtmstatelow state flags */
-#define BCM43xx_SBTMSTATELOW_RESET		0x01
-#define BCM43xx_SBTMSTATELOW_REJECT		0x02
-#define BCM43xx_SBTMSTATELOW_CLOCK		0x10000
-#define BCM43xx_SBTMSTATELOW_FORCE_GATE_CLOCK	0x20000
-
-/* sbtmstatehigh state flags */
-#define BCM43xx_SBTMSTATEHIGH_SERROR		0x00000001
-#define BCM43xx_SBTMSTATEHIGH_BUSY		0x00000004
-#define BCM43xx_SBTMSTATEHIGH_TIMEOUT		0x00000020
-#define BCM43xx_SBTMSTATEHIGH_COREFLAGS		0x1FFF0000
-#define BCM43xx_SBTMSTATEHIGH_DMA64BIT		0x10000000
-#define BCM43xx_SBTMSTATEHIGH_GATEDCLK		0x20000000
-#define BCM43xx_SBTMSTATEHIGH_BISTFAILED	0x40000000
-#define BCM43xx_SBTMSTATEHIGH_BISTCOMPLETE	0x80000000
-
-/* sbimstate flags */
-#define BCM43xx_SBIMSTATE_IB_ERROR		0x20000
-#define BCM43xx_SBIMSTATE_TIMEOUT		0x40000
-
 /* PHYVersioning */
 #define BCM43xx_PHYTYPE_A		0x00
 #define BCM43xx_PHYTYPE_B		0x01
@@ -429,54 +310,6 @@
 	u32 value;
 } __attribute__((__packed__));
 
-/* Values for bcm430x_sprominfo.locale */
-enum {
-	BCM43xx_LOCALE_WORLD = 0,
-	BCM43xx_LOCALE_THAILAND,
-	BCM43xx_LOCALE_ISRAEL,
-	BCM43xx_LOCALE_JORDAN,
-	BCM43xx_LOCALE_CHINA,
-	BCM43xx_LOCALE_JAPAN,
-	BCM43xx_LOCALE_USA_CANADA_ANZ,
-	BCM43xx_LOCALE_EUROPE,
-	BCM43xx_LOCALE_USA_LOW,
-	BCM43xx_LOCALE_JAPAN_HIGH,
-	BCM43xx_LOCALE_ALL,
-	BCM43xx_LOCALE_NONE,
-};
-
-#define BCM43xx_SPROM_SIZE	64 /* in 16-bit words. */
-struct bcm43xx_sprominfo {
-	u16 boardflags2;
-	u8 il0macaddr[6];
-	u8 et0macaddr[6];
-	u8 et1macaddr[6];
-	u8 et0phyaddr:5;
-	u8 et1phyaddr:5;
-	u8 et0mdcport:1;
-	u8 et1mdcport:1;
-	u8 boardrev;
-	u8 locale:4;
-	u8 antennas_aphy:2;
-	u8 antennas_bgphy:2;
-	u16 pa0b0;
-	u16 pa0b1;
-	u16 pa0b2;
-	u8 wl0gpio0;
-	u8 wl0gpio1;
-	u8 wl0gpio2;
-	u8 wl0gpio3;
-	u8 maxpower_aphy;
-	u8 maxpower_bgphy;
-	u16 pa1b0;
-	u16 pa1b1;
-	u16 pa1b2;
-	u8 idle_tssi_tgt_aphy;
-	u8 idle_tssi_tgt_bgphy;
-	u16 boardflags;
-	u16 antennagain_aphy;
-	u16 antennagain_bgphy;
-};
 
 /* Value pair to measure the LocalOscillator. */
 struct bcm43xx_lopair {
@@ -604,29 +437,9 @@
 
 #define BCM43xx_MAX_80211_CORES		2
 
-#ifdef CONFIG_BCM947XX
-#define core_offset(bcm) (bcm)->current_core_offset
-#else
-#define core_offset(bcm) 0
-#endif
-
-/* Generic information about a core. */
-struct bcm43xx_coreinfo {
-	u8 available:1,
-	   enabled:1,
-	   initialized:1;
-	/** core_rev revision number */
-	u8 rev;
-	/** Index number for _switch_core() */
-	u8 index;
-	/** core_id ID number */
-	u16 id;
-	/** Core-specific data. */
-	void *priv;
-};
-
 /* Additional information for each 80211 core. */
-struct bcm43xx_coreinfo_80211 {
+struct bcm43xx_corepriv_80211 {
+	u8 initialized:1;
 	/* PHY device. */
 	struct bcm43xx_phyinfo phy;
 	/* Radio device. */
@@ -641,7 +454,7 @@
 
 /* Context information for a noise calculation (Link Quality). */
 struct bcm43xx_noise_calculation {
-	struct bcm43xx_coreinfo *core_at_start;
+	struct ssb_core *core_at_start;
 	u8 channel_at_start;
 	u8 calculation_running:1;
 	u8 nr_samples;
@@ -711,15 +524,15 @@
  */
 
 struct bcm43xx_private {
+	/* The Sonics Silicon Backplane. */
+	struct ssb ssb;
+
 	struct ieee80211_hw *ieee;
 	struct ieee80211_low_level_stats ieee_stats;
 
 	struct net_device *net_dev;
-	struct pci_dev *pci_dev;
 	unsigned int irq;
 
-	void __iomem *mmio_addr;
-
 	spinlock_t irq_lock;
 	struct mutex mutex;
 
@@ -752,36 +565,24 @@
 	u16 board_type;
 	u16 board_revision;
 
-	u16 chip_id;
-	u8 chip_rev;
-	u8 chip_package;
-
-	struct bcm43xx_sprominfo sprom;
+	struct ssb_sprom sprom;
 #define BCM43xx_NR_LEDS		4
 	struct bcm43xx_led leds[BCM43xx_NR_LEDS];
 	spinlock_t leds_lock;
 
-	/* The currently active core. */
-	struct bcm43xx_coreinfo *current_core;
-#ifdef CONFIG_BCM947XX
-	/** current core memory offset */
-	u32 current_core_offset;
-#endif
-	struct bcm43xx_coreinfo *active_80211_core;
-	/* coreinfo structs for all possible cores follow.
-	 * Note that a core might not exist.
-	 * So check the coreinfo flags before using it.
+	/* Pointers to the available cores.
+	 * If a core is not available, this is NULL.
 	 */
-	struct bcm43xx_coreinfo core_chipcommon;
-	struct bcm43xx_coreinfo core_pci;
-	struct bcm43xx_coreinfo core_80211[ BCM43xx_MAX_80211_CORES ];
+	struct ssb_core *core_80211[ BCM43xx_MAX_80211_CORES ];
+	struct ssb_core *active_80211_core;
+	struct ssb_core *core_chipcommon;
+	struct ssb_core *core_pci;
+
 	/* Additional information, specific to the 80211 cores. */
-	struct bcm43xx_coreinfo_80211 core_80211_ext[ BCM43xx_MAX_80211_CORES ];
+	struct bcm43xx_corepriv_80211 corepriv_80211[ BCM43xx_MAX_80211_CORES ];
 	/* Number of available 80211 cores. */
 	int nr_80211_available;
 
-	u32 chipcommon_capabilities;
-
 	/* Reason code of the last interrupt. */
 	u32 irq_reason;
 	u32 dma_reason[6];
@@ -801,9 +602,6 @@
 
 	struct work_struct restart_work;
 
-	/* Informational stuff. */
-	char nick[IW_ESSID_MAX_SIZE + 1];
-
 	/* encryption/decryption */
 	u16 security_offset;
 	struct bcm43xx_key key[54];
@@ -825,6 +623,12 @@
 	return ieee80211_dev_hw_data(dev);
 }
 
+static inline
+struct bcm43xx_private * ssb_to_bcm43xx(struct ssb *ssb)
+{
+	return container_of(ssb, struct bcm43xx_private, ssb);
+}
+
 /* Helper function, which returns a boolean.
  * TRUE, if PIO is used; FALSE, if DMA is used.
  */
@@ -855,11 +659,11 @@
  * any of these functions.
  */
 static inline
-struct bcm43xx_coreinfo_80211 *
+struct bcm43xx_corepriv_80211 *
 bcm43xx_current_80211_priv(struct bcm43xx_private *bcm)
 {
-	assert(bcm->current_core->id == BCM43xx_COREID_80211);
-	return bcm->current_core->priv;
+	assert(bcm->ssb.current_core->cc == SSB_CC_80211);
+	return bcm->ssb.current_core->priv;
 }
 static inline
 struct bcm43xx_pio * bcm43xx_current_pio(struct bcm43xx_private *bcm)
@@ -920,49 +724,49 @@
 static inline
 u16 bcm43xx_read16(struct bcm43xx_private *bcm, u16 offset)
 {
-	return ioread16(bcm->mmio_addr + core_offset(bcm) + offset);
+	return ioread16(bcm->ssb.mmio + ssb_core_offset(&bcm->ssb) + offset);
 }
 
 static inline
 void bcm43xx_write16(struct bcm43xx_private *bcm, u16 offset, u16 value)
 {
-	iowrite16(value, bcm->mmio_addr + core_offset(bcm) + offset);
+	iowrite16(value, bcm->ssb.mmio + ssb_core_offset(&bcm->ssb) + offset);
 }
 
 static inline
 u32 bcm43xx_read32(struct bcm43xx_private *bcm, u16 offset)
 {
-	return ioread32(bcm->mmio_addr + core_offset(bcm) + offset);
+	return ioread32(bcm->ssb.mmio + ssb_core_offset(&bcm->ssb) + offset);
 }
 
 static inline
 void bcm43xx_write32(struct bcm43xx_private *bcm, u16 offset, u32 value)
 {
-	iowrite32(value, bcm->mmio_addr + core_offset(bcm) + offset);
+	iowrite32(value, bcm->ssb.mmio + ssb_core_offset(&bcm->ssb) + offset);
 }
 
 static inline
 int bcm43xx_pci_read_config16(struct bcm43xx_private *bcm, int offset, u16 *value)
 {
-	return pci_read_config_word(bcm->pci_dev, offset, value);
+	return pci_read_config_word(bcm->ssb.pci_dev, offset, value);
 }
 
 static inline
 int bcm43xx_pci_read_config32(struct bcm43xx_private *bcm, int offset, u32 *value)
 {
-	return pci_read_config_dword(bcm->pci_dev, offset, value);
+	return pci_read_config_dword(bcm->ssb.pci_dev, offset, value);
 }
 
 static inline
 int bcm43xx_pci_write_config16(struct bcm43xx_private *bcm, int offset, u16 value)
 {
-	return pci_write_config_word(bcm->pci_dev, offset, value);
+	return pci_write_config_word(bcm->ssb.pci_dev, offset, value);
 }
 
 static inline
 int bcm43xx_pci_write_config32(struct bcm43xx_private *bcm, int offset, u32 value)
 {
-	return pci_write_config_dword(bcm->pci_dev, offset, value);
+	return pci_write_config_dword(bcm->ssb.pci_dev, offset, value);
 }
 
 /** Limit a value between two limits */
Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c	2006-08-23 10:47:32.000000000 +0200
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c	2006-08-23 11:40:07.000000000 +0200
@@ -118,6 +118,9 @@
 //#define DEBUG_ENABLE_PCILOG
 
 
+static int bcm43xx_net_stop(struct net_device *net_dev);
+static int bcm43xx_net_open(struct net_device *net_dev);
+
 /* Detailed list maintained at:
  * http://openfacts.berlios.de/index-en.phtml?title=Bcm43xxDevices
  */
@@ -341,7 +344,7 @@
 	 * We try to be atomic here, by restaring the read process,
 	 * if any of the high registers changed (overflew).
 	 */
-	if (bcm->current_core->rev >= 3) {
+	if (bcm->ssb.current_core->rev >= 3) {
 		u32 low, high, high2;
 
 		do {
@@ -406,7 +409,7 @@
 	 * First zero out the low register, so we have a full
 	 * register-overflow duration to complete the operation.
 	 */
-	if (bcm->current_core->rev >= 3) {
+	if (bcm->ssb.current_core->rev >= 3) {
 		u32 lo = (tsf & 0x00000000FFFFFFFFULL);
 		u32 hi = (tsf & 0xFFFFFFFF00000000ULL) >> 32;
 
@@ -609,10 +612,10 @@
 	u16 version;
 	u8 revision;
 
-	if (bcm->chip_id == 0x4317) {
-		if (bcm->chip_rev == 0x00)
+	if (bcm->ssb.chip_id == 0x4317) {
+		if (bcm->ssb.chip_rev == 0x00)
 			radio_id = 0x3205017F;
-		else if (bcm->chip_rev == 0x01)
+		else if (bcm->ssb.chip_rev == 0x01)
 			radio_id = 0x4205017F;
 		else
 			radio_id = 0x5205017F;
@@ -657,140 +660,10 @@
 	return -ENODEV;
 }
 
-static inline u8 bcm43xx_crc8(u8 crc, u8 data)
-{
-	static const u8 t[] = {
-		0x00, 0xF7, 0xB9, 0x4E, 0x25, 0xD2, 0x9C, 0x6B,
-		0x4A, 0xBD, 0xF3, 0x04, 0x6F, 0x98, 0xD6, 0x21,
-		0x94, 0x63, 0x2D, 0xDA, 0xB1, 0x46, 0x08, 0xFF,
-		0xDE, 0x29, 0x67, 0x90, 0xFB, 0x0C, 0x42, 0xB5,
-		0x7F, 0x88, 0xC6, 0x31, 0x5A, 0xAD, 0xE3, 0x14,
-		0x35, 0xC2, 0x8C, 0x7B, 0x10, 0xE7, 0xA9, 0x5E,
-		0xEB, 0x1C, 0x52, 0xA5, 0xCE, 0x39, 0x77, 0x80,
-		0xA1, 0x56, 0x18, 0xEF, 0x84, 0x73, 0x3D, 0xCA,
-		0xFE, 0x09, 0x47, 0xB0, 0xDB, 0x2C, 0x62, 0x95,
-		0xB4, 0x43, 0x0D, 0xFA, 0x91, 0x66, 0x28, 0xDF,
-		0x6A, 0x9D, 0xD3, 0x24, 0x4F, 0xB8, 0xF6, 0x01,
-		0x20, 0xD7, 0x99, 0x6E, 0x05, 0xF2, 0xBC, 0x4B,
-		0x81, 0x76, 0x38, 0xCF, 0xA4, 0x53, 0x1D, 0xEA,
-		0xCB, 0x3C, 0x72, 0x85, 0xEE, 0x19, 0x57, 0xA0,
-		0x15, 0xE2, 0xAC, 0x5B, 0x30, 0xC7, 0x89, 0x7E,
-		0x5F, 0xA8, 0xE6, 0x11, 0x7A, 0x8D, 0xC3, 0x34,
-		0xAB, 0x5C, 0x12, 0xE5, 0x8E, 0x79, 0x37, 0xC0,
-		0xE1, 0x16, 0x58, 0xAF, 0xC4, 0x33, 0x7D, 0x8A,
-		0x3F, 0xC8, 0x86, 0x71, 0x1A, 0xED, 0xA3, 0x54,
-		0x75, 0x82, 0xCC, 0x3B, 0x50, 0xA7, 0xE9, 0x1E,
-		0xD4, 0x23, 0x6D, 0x9A, 0xF1, 0x06, 0x48, 0xBF,
-		0x9E, 0x69, 0x27, 0xD0, 0xBB, 0x4C, 0x02, 0xF5,
-		0x40, 0xB7, 0xF9, 0x0E, 0x65, 0x92, 0xDC, 0x2B,
-		0x0A, 0xFD, 0xB3, 0x44, 0x2F, 0xD8, 0x96, 0x61,
-		0x55, 0xA2, 0xEC, 0x1B, 0x70, 0x87, 0xC9, 0x3E,
-		0x1F, 0xE8, 0xA6, 0x51, 0x3A, 0xCD, 0x83, 0x74,
-		0xC1, 0x36, 0x78, 0x8F, 0xE4, 0x13, 0x5D, 0xAA,
-		0x8B, 0x7C, 0x32, 0xC5, 0xAE, 0x59, 0x17, 0xE0,
-		0x2A, 0xDD, 0x93, 0x64, 0x0F, 0xF8, 0xB6, 0x41,
-		0x60, 0x97, 0xD9, 0x2E, 0x45, 0xB2, 0xFC, 0x0B,
-		0xBE, 0x49, 0x07, 0xF0, 0x9B, 0x6C, 0x22, 0xD5,
-		0xF4, 0x03, 0x4D, 0xBA, 0xD1, 0x26, 0x68, 0x9F,
-	};
-	return t[crc ^ data];
-}
-
-static u8 bcm43xx_sprom_crc(const u16 *sprom)
-{
-	int word;
-	u8 crc = 0xFF;
-
-	for (word = 0; word < BCM43xx_SPROM_SIZE - 1; word++) {
-		crc = bcm43xx_crc8(crc, sprom[word] & 0x00FF);
-		crc = bcm43xx_crc8(crc, (sprom[word] & 0xFF00) >> 8);
-	}
-	crc = bcm43xx_crc8(crc, sprom[BCM43xx_SPROM_VERSION] & 0x00FF);
-	crc ^= 0xFF;
-
-	return crc;
-}
-
-int bcm43xx_sprom_read(struct bcm43xx_private *bcm, u16 *sprom)
-{
-	int i;
-	u8 crc, expected_crc;
-
-	for (i = 0; i < BCM43xx_SPROM_SIZE; i++)
-		sprom[i] = bcm43xx_read16(bcm, BCM43xx_SPROM_BASE + (i * 2));
-	/* CRC-8 check. */
-	crc = bcm43xx_sprom_crc(sprom);
-	expected_crc = (sprom[BCM43xx_SPROM_VERSION] & 0xFF00) >> 8;
-	if (crc != expected_crc) {
-		printk(KERN_WARNING PFX "WARNING: Invalid SPROM checksum "
-					"(0x%02X, expected: 0x%02X)\n",
-		       crc, expected_crc);
-		return -EINVAL;
-	}
-
-	return 0;
-}
-
-int bcm43xx_sprom_write(struct bcm43xx_private *bcm, const u16 *sprom)
-{
-	int i, err;
-	u8 crc, expected_crc;
-	u32 spromctl;
-
-	/* CRC-8 validation of the input data. */
-	crc = bcm43xx_sprom_crc(sprom);
-	expected_crc = (sprom[BCM43xx_SPROM_VERSION] & 0xFF00) >> 8;
-	if (crc != expected_crc) {
-		printk(KERN_ERR PFX "SPROM input data: Invalid CRC\n");
-		return -EINVAL;
-	}
-
-	printk(KERN_INFO PFX "Writing SPROM. Do NOT turn off the power! Please stand by...\n");
-	err = bcm43xx_pci_read_config32(bcm, BCM43xx_PCICFG_SPROMCTL, &spromctl);
-	if (err)
-		goto err_ctlreg;
-	spromctl |= 0x10; /* SPROM WRITE enable. */
-	bcm43xx_pci_write_config32(bcm, BCM43xx_PCICFG_SPROMCTL, spromctl);
-	if (err)
-		goto err_ctlreg;
-	/* We must burn lots of CPU cycles here, but that does not
-	 * really matter as one does not write the SPROM every other minute...
-	 */
-	printk(KERN_INFO PFX "[ 0%%");
-	mdelay(500);
-	for (i = 0; i < BCM43xx_SPROM_SIZE; i++) {
-		if (i == 16)
-			printk("25%%");
-		else if (i == 32)
-			printk("50%%");
-		else if (i == 48)
-			printk("75%%");
-		else if (i % 2)
-			printk(".");
-		bcm43xx_write16(bcm, BCM43xx_SPROM_BASE + (i * 2), sprom[i]);
-		mmiowb();
-		mdelay(20);
-	}
-	spromctl &= ~0x10; /* SPROM WRITE enable. */
-	bcm43xx_pci_write_config32(bcm, BCM43xx_PCICFG_SPROMCTL, spromctl);
-	if (err)
-		goto err_ctlreg;
-	mdelay(500);
-	printk("100%% ]\n");
-	printk(KERN_INFO PFX "SPROM written.\n");
-	bcm43xx_controller_restart(bcm, "SPROM update");
-
-	return 0;
-err_ctlreg:
-	printk(KERN_ERR PFX "Could not access SPROM control register.\n");
-	return -ENODEV;
-}
-
 #ifdef CONFIG_BCM947XX
-static void bcm43xx_aton(const char *str, char *dest)
+static void bcm43xx_aton(const char *str, u8 *dest)
 {
 	int i = 0;
-	u16 *d = (u16 *)dest;
 
 	for (;;) {
 		dest[i++] = (char)simple_strtoul(str, NULL, 16);
@@ -798,173 +671,76 @@
 		if (!*str++ || i == 6)
 			break;
 	}
-	for (i = 0; i < 3; i++)
-		d[i] = be16_to_cpu(d[i]);
 }
 #endif
 
 static int bcm43xx_sprom_extract(struct bcm43xx_private *bcm)
 {
-	u16 value;
-	u16 *sprom;
-#ifdef CONFIG_BCM947XX
-	const char *c;
-#endif
-
-	sprom = kzalloc(BCM43xx_SPROM_SIZE * sizeof(u16),
-			GFP_KERNEL);
-	if (!sprom) {
-		printk(KERN_ERR PFX "sprom_extract OOM\n");
-		return -ENOMEM;
-	}
-
-	bcm43xx_sprom_read(bcm, sprom);
+	int err = 0;
 
 #ifdef CONFIG_BCM947XX
-	/* In the case some settings are found in nvram, use them
-	 * to override those read from sprom.
+	char *c;
+
+	/* Can't read the SPROM on this embedded device.
+	 * (This would result in a bus error). Data is
+	 * stored in nvram instead.
 	 */
-	c = nvram_get("boardflags2");
-	if (c)
-		sprom[BCM43xx_SPROM_BOARDFLAGS2] = simple_strtoul(c, NULL, 0);
         c = nvram_get("boardflags");
 	if (c)
-		sprom[BCM43xx_SPROM_BOARDFLAGS] = simple_strtoul(c, NULL, 0);
+		bcm->sprom.r1.boardflags_lo = simple_strtoul(c, NULL, 0);
 	c = nvram_get("il0macaddr");
 	if (c)
-		bcm43xx_aton(c, (char *)&(sprom[BCM43xx_SPROM_IL0MACADDR]));
+		bcm43xx_aton(c, bcm->sprom.r1.il0mac);
 	c = nvram_get("et1macaddr");
 	if (c)
-		bcm43xx_aton(c, (char *)&(sprom[BCM43xx_SPROM_ET1MACADDR]));
+		bcm43xx_aton(c, bcm->sprom.r1.et1mac);
 	c = nvram_get("pa0b0");
 	if (c)
-		sprom[BCM43xx_SPROM_PA0B0] = simple_strtoul(c, NULL, 0);
+		bcm->sprom.r1.pa0b0 = simple_strtoul(c, NULL, 0);
 	c = nvram_get("pa0b1");
 	if (c)
-		sprom[BCM43xx_SPROM_PA0B1] = simple_strtoul(c, NULL, 0);
+		bcm->sprom.r1.pa0b1 = simple_strtoul(c, NULL, 0);
 	c = nvram_get("pa0b2");
 	if (c)
-		sprom[BCM43xx_SPROM_PA0B2] = simple_strtoul(c, NULL, 0);
+		bcm->sprom.r1.pa0b2 = simple_strtoul(c, NULL, 0);
 	c = nvram_get("pa1b0");
 	if (c)
-		sprom[BCM43xx_SPROM_PA1B0] = simple_strtoul(c, NULL, 0);
+		bcm->sprom.r1.pa1b0 = simple_strtoul(c, NULL, 0);
 	c = nvram_get("pa1b1");
 	if (c)
-		sprom[BCM43xx_SPROM_PA1B1] = simple_strtoul(c, NULL, 0);
+		bcm->sprom.r1.pa1b1 = simple_strtoul(c, NULL, 0);
 	c = nvram_get("pa1b2");
 	if (c)
-		sprom[BCM43xx_SPROM_PA1B2] = simple_strtoul(c, NULL, 0);
+		bcm->sprom.r1.pa1b2 = simple_strtoul(c, NULL, 0);
 	c = nvram_get("boardrev");
 	if (c)
-		sprom[BCM43xx_SPROM_BOARDREV] = simple_strtoul(c, NULL, 0);
-#endif
+		bcm->sprom.r1.board_rev = simple_strtoul(c, NULL, 0);
+	if (0)
+		goto out; /* suppress gcc warning about unused "out" */
+#else /* CONFIG_BCM947XX */
+
+	err = ssb_sprom_read(&bcm->ssb, &bcm->sprom, 0);
+	if (err)
+		goto out;
+
+#endif /* CONFIG_BCM947XX */
 
-	/* boardflags2 */
-	value = sprom[BCM43xx_SPROM_BOARDFLAGS2];
-	bcm->sprom.boardflags2 = value;
-
-	/* il0macaddr */
-	value = sprom[BCM43xx_SPROM_IL0MACADDR + 0];
-	*(((u16 *)bcm->sprom.il0macaddr) + 0) = cpu_to_be16(value);
-	value = sprom[BCM43xx_SPROM_IL0MACADDR + 1];
-	*(((u16 *)bcm->sprom.il0macaddr) + 1) = cpu_to_be16(value);
-	value = sprom[BCM43xx_SPROM_IL0MACADDR + 2];
-	*(((u16 *)bcm->sprom.il0macaddr) + 2) = cpu_to_be16(value);
-
-	/* et0macaddr */
-	value = sprom[BCM43xx_SPROM_ET0MACADDR + 0];
-	*(((u16 *)bcm->sprom.et0macaddr) + 0) = cpu_to_be16(value);
-	value = sprom[BCM43xx_SPROM_ET0MACADDR + 1];
-	*(((u16 *)bcm->sprom.et0macaddr) + 1) = cpu_to_be16(value);
-	value = sprom[BCM43xx_SPROM_ET0MACADDR + 2];
-	*(((u16 *)bcm->sprom.et0macaddr) + 2) = cpu_to_be16(value);
-
-	/* et1macaddr */
-	value = sprom[BCM43xx_SPROM_ET1MACADDR + 0];
-	*(((u16 *)bcm->sprom.et1macaddr) + 0) = cpu_to_be16(value);
-	value = sprom[BCM43xx_SPROM_ET1MACADDR + 1];
-	*(((u16 *)bcm->sprom.et1macaddr) + 1) = cpu_to_be16(value);
-	value = sprom[BCM43xx_SPROM_ET1MACADDR + 2];
-	*(((u16 *)bcm->sprom.et1macaddr) + 2) = cpu_to_be16(value);
-
-	/* ethernet phy settings */
-	value = sprom[BCM43xx_SPROM_ETHPHY];
-	bcm->sprom.et0phyaddr = (value & 0x001F);
-	bcm->sprom.et1phyaddr = (value & 0x03E0) >> 5;
-	bcm->sprom.et0mdcport = (value & (1 << 14)) >> 14;
-	bcm->sprom.et1mdcport = (value & (1 << 15)) >> 15;
-
-	/* boardrev, antennas, locale */
-	value = sprom[BCM43xx_SPROM_BOARDREV];
-	bcm->sprom.boardrev = (value & 0x00FF);
-	bcm->sprom.locale = (value & 0x0F00) >> 8;
-	bcm->sprom.antennas_aphy = (value & 0x3000) >> 12;
-	bcm->sprom.antennas_bgphy = (value & 0xC000) >> 14;
-
-	/* pa0b* */
-	value = sprom[BCM43xx_SPROM_PA0B0];
-	bcm->sprom.pa0b0 = value;
-	value = sprom[BCM43xx_SPROM_PA0B1];
-	bcm->sprom.pa0b1 = value;
-	value = sprom[BCM43xx_SPROM_PA0B2];
-	bcm->sprom.pa0b2 = value;
-
-	/* wl0gpio* */
-	value = sprom[BCM43xx_SPROM_WL0GPIO0];
-	if (value == 0x0000)
-		value = 0xFFFF;
-	bcm->sprom.wl0gpio0 = value & 0x00FF;
-	bcm->sprom.wl0gpio1 = (value & 0xFF00) >> 8;
-	value = sprom[BCM43xx_SPROM_WL0GPIO2];
-	if (value == 0x0000)
-		value = 0xFFFF;
-	bcm->sprom.wl0gpio2 = value & 0x00FF;
-	bcm->sprom.wl0gpio3 = (value & 0xFF00) >> 8;
-
-	/* maxpower */
-	value = sprom[BCM43xx_SPROM_MAXPWR];
-	bcm->sprom.maxpower_aphy = (value & 0xFF00) >> 8;
-	bcm->sprom.maxpower_bgphy = value & 0x00FF;
-
-	/* pa1b* */
-	value = sprom[BCM43xx_SPROM_PA1B0];
-	bcm->sprom.pa1b0 = value;
-	value = sprom[BCM43xx_SPROM_PA1B1];
-	bcm->sprom.pa1b1 = value;
-	value = sprom[BCM43xx_SPROM_PA1B2];
-	bcm->sprom.pa1b2 = value;
-
-	/* idle tssi target */
-	value = sprom[BCM43xx_SPROM_IDL_TSSI_TGT];
-	bcm->sprom.idle_tssi_tgt_aphy = value & 0x00FF;
-	bcm->sprom.idle_tssi_tgt_bgphy = (value & 0xFF00) >> 8;
-
-	/* boardflags */
-	value = sprom[BCM43xx_SPROM_BOARDFLAGS];
-	if (value == 0xFFFF)
-		value = 0x0000;
-	bcm->sprom.boardflags = value;
 	/* boardflags workarounds */
 	if (bcm->board_vendor == PCI_VENDOR_ID_DELL &&
-	    bcm->chip_id == 0x4301 &&
+	    bcm->ssb.chip_id == 0x4301 &&
 	    bcm->board_revision == 0x74)
-		bcm->sprom.boardflags |= BCM43xx_BFL_BTCOEXIST;
+		bcm->sprom.r1.boardflags_lo |= BCM43xx_BFL_BTCOEXIST;
 	if (bcm->board_vendor == PCI_VENDOR_ID_APPLE &&
 	    bcm->board_type == 0x4E &&
 	    bcm->board_revision > 0x40)
-		bcm->sprom.boardflags |= BCM43xx_BFL_PACTRL;
+		bcm->sprom.r1.boardflags_lo |= BCM43xx_BFL_PACTRL;
 
-	/* antenna gain */
-	value = sprom[BCM43xx_SPROM_ANTENNA_GAIN];
-	if (value == 0x0000 || value == 0xFFFF)
-		value = 0x0202;
-	/* convert values to Q5.2 */
-	bcm->sprom.antennagain_aphy = ((value & 0xFF00) >> 8) * 4;
-	bcm->sprom.antennagain_bgphy = (value & 0x00FF) * 4;
+	/* Convert Antennagain values to Q5.2 */
+	bcm->sprom.r1.antenna_gain_a <<= 2;
+	bcm->sprom.r1.antenna_gain_bg <<= 2;
 
-	kfree(sprom);
-
-	return 0;
+out:
+	return err;
 }
 
 /* DummyTransmission function, as documented on 
@@ -1079,7 +855,7 @@
 		return;
 
 	index -= 4;
-	if (bcm->current_core->rev >= 5) {
+	if (bcm->ssb.current_core->rev >= 5) {
 		bcm43xx_shm_write32(bcm,
 				    BCM43xx_SHM_HWMAC,
 				    index * 2,
@@ -1128,7 +904,7 @@
 	unsigned int i,j, nr_keys = 54;
 	u16 offset;
 
-	if (bcm->current_core->rev < 5)
+	if (bcm->ssb.current_core->rev < 5)
 		nr_keys = 16;
 	assert(nr_keys <= ARRAY_SIZE(bcm->key));
 
@@ -1147,194 +923,12 @@
 	dprintk(KERN_INFO PFX "Keys cleared\n");
 }
 
-/* Lowlevel core-switch function. This is only to be used in
- * bcm43xx_switch_core() and bcm43xx_probe_cores()
- */
-static int _switch_core(struct bcm43xx_private *bcm, int core)
-{
-	int err;
-	int attempts = 0;
-	u32 current_core;
-
-	assert(core >= 0);
-	while (1) {
-		err = bcm43xx_pci_write_config32(bcm, BCM43xx_PCICFG_ACTIVE_CORE,
-						 (core * 0x1000) + 0x18000000);
-		if (unlikely(err))
-			goto error;
-		err = bcm43xx_pci_read_config32(bcm, BCM43xx_PCICFG_ACTIVE_CORE,
-						&current_core);
-		if (unlikely(err))
-			goto error;
-		current_core = (current_core - 0x18000000) / 0x1000;
-		if (current_core == core)
-			break;
-
-		if (unlikely(attempts++ > BCM43xx_SWITCH_CORE_MAX_RETRIES))
-			goto error;
-		udelay(10);
-	}
-#ifdef CONFIG_BCM947XX
-	if (bcm->pci_dev->bus->number == 0)
-		bcm->current_core_offset = 0x1000 * core;
-	else
-		bcm->current_core_offset = 0;
-#endif
-
-	return 0;
-error:
-	printk(KERN_ERR PFX "Failed to switch to core %d\n", core);
-	return -ENODEV;
-}
-
-int bcm43xx_switch_core(struct bcm43xx_private *bcm, struct bcm43xx_coreinfo *new_core)
-{
-	int err;
-
-	if (unlikely(!new_core))
-		return 0;
-	if (!new_core->available)
-		return -ENODEV;
-	if (bcm->current_core == new_core)
-		return 0;
-	err = _switch_core(bcm, new_core->index);
-	if (unlikely(err))
-		goto out;
-
-	bcm->current_core = new_core;
-out:
-	return err;
-}
-
-static int bcm43xx_core_enabled(struct bcm43xx_private *bcm)
-{
-	u32 value;
-
-	value = bcm43xx_read32(bcm, BCM43xx_CIR_SBTMSTATELOW);
-	value &= BCM43xx_SBTMSTATELOW_CLOCK | BCM43xx_SBTMSTATELOW_RESET
-		 | BCM43xx_SBTMSTATELOW_REJECT;
-
-	return (value == BCM43xx_SBTMSTATELOW_CLOCK);
-}
-
-/* disable current core */
-static int bcm43xx_core_disable(struct bcm43xx_private *bcm, u32 core_flags)
-{
-	u32 sbtmstatelow;
-	u32 sbtmstatehigh;
-	int i;
-
-	/* fetch sbtmstatelow from core information registers */
-	sbtmstatelow = bcm43xx_read32(bcm, BCM43xx_CIR_SBTMSTATELOW);
-
-	/* core is already in reset */
-	if (sbtmstatelow & BCM43xx_SBTMSTATELOW_RESET)
-		goto out;
-
-	if (sbtmstatelow & BCM43xx_SBTMSTATELOW_CLOCK) {
-		sbtmstatelow = BCM43xx_SBTMSTATELOW_CLOCK |
-			       BCM43xx_SBTMSTATELOW_REJECT;
-		bcm43xx_write32(bcm, BCM43xx_CIR_SBTMSTATELOW, sbtmstatelow);
-
-		for (i = 0; i < 1000; i++) {
-			sbtmstatelow = bcm43xx_read32(bcm, BCM43xx_CIR_SBTMSTATELOW);
-			if (sbtmstatelow & BCM43xx_SBTMSTATELOW_REJECT) {
-				i = -1;
-				break;
-			}
-			udelay(10);
-		}
-		if (i != -1) {
-			printk(KERN_ERR PFX "Error: core_disable() REJECT timeout!\n");
-			return -EBUSY;
-		}
-
-		for (i = 0; i < 1000; i++) {
-			sbtmstatehigh = bcm43xx_read32(bcm, BCM43xx_CIR_SBTMSTATEHIGH);
-			if (!(sbtmstatehigh & BCM43xx_SBTMSTATEHIGH_BUSY)) {
-				i = -1;
-				break;
-			}
-			udelay(10);
-		}
-		if (i != -1) {
-			printk(KERN_ERR PFX "Error: core_disable() BUSY timeout!\n");
-			return -EBUSY;
-		}
-
-		sbtmstatelow = BCM43xx_SBTMSTATELOW_FORCE_GATE_CLOCK |
-			       BCM43xx_SBTMSTATELOW_REJECT |
-			       BCM43xx_SBTMSTATELOW_RESET |
-			       BCM43xx_SBTMSTATELOW_CLOCK |
-			       core_flags;
-		bcm43xx_write32(bcm, BCM43xx_CIR_SBTMSTATELOW, sbtmstatelow);
-		udelay(10);
-	}
-
-	sbtmstatelow = BCM43xx_SBTMSTATELOW_RESET |
-		       BCM43xx_SBTMSTATELOW_REJECT |
-		       core_flags;
-	bcm43xx_write32(bcm, BCM43xx_CIR_SBTMSTATELOW, sbtmstatelow);
-
-out:
-	bcm->current_core->enabled = 0;
-
-	return 0;
-}
-
-/* enable (reset) current core */
-static int bcm43xx_core_enable(struct bcm43xx_private *bcm, u32 core_flags)
-{
-	u32 sbtmstatelow;
-	u32 sbtmstatehigh;
-	u32 sbimstate;
-	int err;
-
-	err = bcm43xx_core_disable(bcm, core_flags);
-	if (err)
-		goto out;
-
-	sbtmstatelow = BCM43xx_SBTMSTATELOW_CLOCK |
-		       BCM43xx_SBTMSTATELOW_RESET |
-		       BCM43xx_SBTMSTATELOW_FORCE_GATE_CLOCK |
-		       core_flags;
-	bcm43xx_write32(bcm, BCM43xx_CIR_SBTMSTATELOW, sbtmstatelow);
-	udelay(1);
-
-	sbtmstatehigh = bcm43xx_read32(bcm, BCM43xx_CIR_SBTMSTATEHIGH);
-	if (sbtmstatehigh & BCM43xx_SBTMSTATEHIGH_SERROR) {
-		sbtmstatehigh = 0x00000000;
-		bcm43xx_write32(bcm, BCM43xx_CIR_SBTMSTATEHIGH, sbtmstatehigh);
-	}
-
-	sbimstate = bcm43xx_read32(bcm, BCM43xx_CIR_SBIMSTATE);
-	if (sbimstate & (BCM43xx_SBIMSTATE_IB_ERROR | BCM43xx_SBIMSTATE_TIMEOUT)) {
-		sbimstate &= ~(BCM43xx_SBIMSTATE_IB_ERROR | BCM43xx_SBIMSTATE_TIMEOUT);
-		bcm43xx_write32(bcm, BCM43xx_CIR_SBIMSTATE, sbimstate);
-	}
-
-	sbtmstatelow = BCM43xx_SBTMSTATELOW_CLOCK |
-		       BCM43xx_SBTMSTATELOW_FORCE_GATE_CLOCK |
-		       core_flags;
-	bcm43xx_write32(bcm, BCM43xx_CIR_SBTMSTATELOW, sbtmstatelow);
-	udelay(1);
-
-	sbtmstatelow = BCM43xx_SBTMSTATELOW_CLOCK | core_flags;
-	bcm43xx_write32(bcm, BCM43xx_CIR_SBTMSTATELOW, sbtmstatelow);
-	udelay(1);
-
-	bcm->current_core->enabled = 1;
-	assert(err == 0);
-out:
-	return err;
-}
-
 /* http://bcm-specs.sipsolutions.net/80211CoreReset */
 void bcm43xx_wireless_core_reset(struct bcm43xx_private *bcm, int connect_phy)
 {
 	u32 flags = 0x00040000;
 
-	if ((bcm43xx_core_enabled(bcm)) &&
+	if ((ssb_core_is_enabled(&bcm->ssb)) &&
 	    !bcm43xx_using_pio(bcm)) {
 //FIXME: Do we _really_ want #ifndef CONFIG_BCM947XX here?
 #if 0
@@ -1345,7 +939,7 @@
 		bcm43xx_dmacontroller_tx_reset(bcm, BCM43xx_MMIO_DMA3_BASE);
 		bcm43xx_dmacontroller_tx_reset(bcm, BCM43xx_MMIO_DMA4_BASE);
 		bcm43xx_dmacontroller_rx_reset(bcm, BCM43xx_MMIO_DMA1_BASE);
-		if (bcm->current_core->rev < 5)
+		if (bcm->ssb.current_core->rev < 5)
 			bcm43xx_dmacontroller_rx_reset(bcm, BCM43xx_MMIO_DMA4_BASE);
 #endif
 #endif
@@ -1358,7 +952,7 @@
 		if (connect_phy)
 			flags |= 0x20000000;
 		bcm43xx_phy_connect(bcm, connect_phy);
-		bcm43xx_core_enable(bcm, flags);
+		ssb_core_enable(&bcm->ssb, flags);
 		bcm43xx_write16(bcm, 0x03E6, 0x0000);
 		bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS_BITFIELD,
 				bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD)
@@ -1370,7 +964,7 @@
 {
 	bcm43xx_radio_turn_off(bcm);
 	bcm43xx_write16(bcm, 0x03E6, 0x00F4);
-	bcm43xx_core_disable(bcm, 0);
+	ssb_core_disable(&bcm->ssb, 0);
 }
 
 /* Mark the current 80211 core inactive. */
@@ -1380,15 +974,15 @@
 
 	bcm43xx_interrupt_disable(bcm, BCM43xx_IRQ_ALL);
 	bcm43xx_radio_turn_off(bcm);
-	sbtmstatelow = bcm43xx_read32(bcm, BCM43xx_CIR_SBTMSTATELOW);
+	sbtmstatelow = bcm43xx_read32(bcm, SSB_TMSLOW);
 	sbtmstatelow &= 0xDFF5FFFF;
 	sbtmstatelow |= 0x000A0000;
-	bcm43xx_write32(bcm, BCM43xx_CIR_SBTMSTATELOW, sbtmstatelow);
+	bcm43xx_write32(bcm, SSB_TMSLOW, sbtmstatelow);
 	udelay(1);
-	sbtmstatelow = bcm43xx_read32(bcm, BCM43xx_CIR_SBTMSTATELOW);
+	sbtmstatelow = bcm43xx_read32(bcm, SSB_TMSLOW);
 	sbtmstatelow &= 0xFFF5FFFF;
 	sbtmstatelow |= 0x00080000;
-	bcm43xx_write32(bcm, BCM43xx_CIR_SBTMSTATELOW, sbtmstatelow);
+	bcm43xx_write32(bcm, SSB_TMSLOW, sbtmstatelow);
 	udelay(1);
 }
 
@@ -1433,7 +1027,7 @@
 	bcm43xx_shm_write16(bcm, BCM43xx_SHM_SHARED, 0x40A, 0x7F7F);
 	bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS2_BITFIELD,
 			bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS2_BITFIELD) | (1 << 4));
-	assert(bcm->noisecalc.core_at_start == bcm->current_core);
+	assert(bcm->noisecalc.core_at_start == bcm->ssb.current_core);
 	assert(bcm->noisecalc.channel_at_start == bcm43xx_current_radio(bcm)->channel);
 }
 
@@ -1443,7 +1037,7 @@
 
 	if (bcm->noisecalc.calculation_running)
 		return;
-	bcm->noisecalc.core_at_start = bcm->current_core;
+	bcm->noisecalc.core_at_start = bcm->ssb.current_core;
 	bcm->noisecalc.channel_at_start = bcm43xx_current_radio(bcm)->channel;
 	bcm->noisecalc.calculation_running = 1;
 	bcm->noisecalc.nr_samples = 0;
@@ -1462,7 +1056,7 @@
 	/* Bottom half of Link Quality calculation. */
 
 	assert(bcm->noisecalc.calculation_running);
-	if (bcm->noisecalc.core_at_start != bcm->current_core ||
+	if (bcm->noisecalc.core_at_start != bcm->ssb.current_core ||
 	    bcm->noisecalc.channel_at_start != radio->channel)
 		goto drop_calculation;
 	tmp = bcm43xx_shm_read16(bcm, BCM43xx_SHM_SHARED, 0x408);
@@ -1804,7 +1398,7 @@
 static void bcm43xx_set_beacon_int(struct bcm43xx_private *bcm, u16 beacon_int)
 {
 	bcm43xx_time_lock(bcm);
-	if (bcm->current_core->rev >= 3) {
+	if (bcm->ssb.current_core->rev >= 3) {
 		bcm43xx_write32(bcm, 0x188, (beacon_int << 16));
 	} else {
 		bcm43xx_write16(bcm, 0x606, (beacon_int >> 6));
@@ -1995,7 +1589,7 @@
 static void bcm43xx_interrupt_ack(struct bcm43xx_private *bcm, u32 reason)
 {
 	if (bcm43xx_using_pio(bcm) &&
-	    (bcm->current_core->rev < 3) &&
+	    (bcm->ssb.current_core->rev < 3) &&
 	    (!(reason & BCM43xx_IRQ_PIO_WORKAROUND))) {
 		/* Apply a PIO specific workaround to the dma_reasons */
 		pio_irq_workaround(bcm, BCM43xx_MMIO_PIO1_BASE, 0);
@@ -2033,7 +1627,7 @@
 	spin_lock(&bcm->irq_lock);
 
 	assert(bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED);
-	assert(bcm->current_core->id == BCM43xx_COREID_80211);
+	assert(bcm->ssb.current_core->cc == SSB_CC_80211);
 
 	reason = bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON);
 	if (reason == 0xffffffff) {
@@ -2090,7 +1684,7 @@
 static int bcm43xx_request_firmware(struct bcm43xx_private *bcm)
 {
 	struct bcm43xx_phyinfo *phy = bcm43xx_current_phy(bcm);
-	u8 rev = bcm->current_core->rev;
+	u8 rev = bcm->ssb.current_core->rev;
 	int err = 0;
 	int nr;
 	char buf[22 + sizeof(modparam_fwpostfix) - 1] = { 0 };
@@ -2099,7 +1693,7 @@
 		snprintf(buf, ARRAY_SIZE(buf), "bcm43xx_microcode%d%s.fw",
 			 (rev >= 5 ? 5 : rev),
 			 modparam_fwpostfix);
-		err = request_firmware(&phy->ucode, buf, &bcm->pci_dev->dev);
+		err = request_firmware(&phy->ucode, buf, &bcm->ssb.pci_dev->dev);
 		if (err) {
 			printk(KERN_ERR PFX 
 			       "Error: Microcode \"%s\" not available or load failed.\n",
@@ -2113,7 +1707,7 @@
 			 "bcm43xx_pcm%d%s.fw",
 			 (rev < 5 ? 4 : 5),
 			 modparam_fwpostfix);
-		err = request_firmware(&phy->pcm, buf, &bcm->pci_dev->dev);
+		err = request_firmware(&phy->pcm, buf, &bcm->ssb.pci_dev->dev);
 		if (err) {
 			printk(KERN_ERR PFX
 			       "Error: PCM \"%s\" not available or load failed.\n",
@@ -2153,7 +1747,7 @@
 		snprintf(buf, ARRAY_SIZE(buf), "bcm43xx_initval%02d%s.fw",
 			 nr, modparam_fwpostfix);
 
-		err = request_firmware(&phy->initvals0, buf, &bcm->pci_dev->dev);
+		err = request_firmware(&phy->initvals0, buf, &bcm->ssb.pci_dev->dev);
 		if (err) {
 			printk(KERN_ERR PFX 
 			       "Error: InitVals \"%s\" not available or load failed.\n",
@@ -2172,7 +1766,7 @@
 
 			switch (phy->type) {
 			case BCM43xx_PHYTYPE_A:
-				sbtmstatehigh = bcm43xx_read32(bcm, BCM43xx_CIR_SBTMSTATEHIGH);
+				sbtmstatehigh = bcm43xx_read32(bcm, SSB_TMSHIGH);
 				if (sbtmstatehigh & 0x00010000)
 					nr = 9;
 				else
@@ -2188,7 +1782,7 @@
 			snprintf(buf, ARRAY_SIZE(buf), "bcm43xx_initval%02d%s.fw",
 				 nr, modparam_fwpostfix);
 
-			err = request_firmware(&phy->initvals1, buf, &bcm->pci_dev->dev);
+			err = request_firmware(&phy->initvals1, buf, &bcm->ssb.pci_dev->dev);
 			if (err) {
 				printk(KERN_ERR PFX 
 				       "Error: InitVals \"%s\" not available or load failed.\n",
@@ -2298,9 +1892,9 @@
 {
 	int err;
 
-	bcm->irq = bcm->pci_dev->irq;
+	bcm->irq = bcm->ssb.pci_dev->irq;
 #ifdef CONFIG_BCM947XX
-	if (bcm->pci_dev->bus->number == 0) {
+	if (bcm->ssb.pci_dev->bus->number == 0) {
 		struct pci_dev *d = NULL;
 		/* FIXME: we will probably need more device IDs here... */
 		d = pci_find_device(PCI_VENDOR_ID_BROADCOM, 0x4324, NULL);
@@ -2322,22 +1916,26 @@
  */
 static int switch_to_gpio_core(struct bcm43xx_private *bcm)
 {
-	int err;
+	int err = -ENODEV;
 
 	/* Where to find the GPIO register depends on the chipset.
 	 * If it has a ChipCommon, its register at offset 0x6c is the GPIO
 	 * control register. Otherwise the register at offset 0x6c in the
 	 * PCI core is the GPIO control register.
 	 */
-	err = bcm43xx_switch_core(bcm, &bcm->core_chipcommon);
-	if (err == -ENODEV) {
-		err = bcm43xx_switch_core(bcm, &bcm->core_pci);
-		if (unlikely(err == -ENODEV)) {
-			printk(KERN_ERR PFX "gpio error: "
-			       "Neither ChipCommon nor PCI core available!\n");
-		}
+	if (bcm->core_chipcommon) {
+		err = ssb_switch_core(&bcm->ssb, bcm->core_chipcommon);
+		if (err)
+			goto out;
+	} else if (bcm->core_pci) {
+		err = ssb_switch_core(&bcm->ssb, bcm->core_pci);
+		if (err)
+			goto out;
+	} else {
+		printk(KERN_ERR PFX "gpio error: "
+				    "Neither ChipCommon nor PCI core available!\n");
 	}
-
+out:
 	return err;
 }
 
@@ -2346,7 +1944,7 @@
  */
 static int bcm43xx_gpio_init(struct bcm43xx_private *bcm)
 {
-	struct bcm43xx_coreinfo *old_core;
+	struct ssb_core *old_core;
 	int err;
 	u32 mask, set;
 
@@ -2360,7 +1958,7 @@
 
 	mask = 0x0000001F;
 	set = 0x0000000F;
-	if (bcm->chip_id == 0x4301) {
+	if (bcm->ssb.chip_id == 0x4301) {
 		mask |= 0x0060;
 		set |= 0x0060;
 	}
@@ -2371,23 +1969,23 @@
 		mask |= 0x0180;
 		set |= 0x0180;
 	}
-	if (bcm->sprom.boardflags & BCM43xx_BFL_PACTRL) {
+	if (bcm->sprom.r1.boardflags_lo & BCM43xx_BFL_PACTRL) {
 		bcm43xx_write16(bcm, BCM43xx_MMIO_GPIO_MASK,
 				bcm43xx_read16(bcm, BCM43xx_MMIO_GPIO_MASK)
 				| 0x0200);
 		mask |= 0x0200;
 		set |= 0x0200;
 	}
-	if (bcm->current_core->rev >= 2)
+	if (bcm->ssb.current_core->rev >= 2)
 		mask  |= 0x0010; /* FIXME: This is redundant. */
 
-	old_core = bcm->current_core;
+	old_core = bcm->ssb.current_core;
 	err = switch_to_gpio_core(bcm);
 	if (err)
 		goto out;
 	bcm43xx_write32(bcm, BCM43xx_GPIO_CONTROL,
 	                (bcm43xx_read32(bcm, BCM43xx_GPIO_CONTROL) & mask) | set);
-	err = bcm43xx_switch_core(bcm, old_core);
+	err = ssb_switch_core(&bcm->ssb, old_core);
 out:
 	return err;
 }
@@ -2395,15 +1993,15 @@
 /* Turn off all GPIO stuff. Call this on module unload, for example. */
 static int bcm43xx_gpio_cleanup(struct bcm43xx_private *bcm)
 {
-	struct bcm43xx_coreinfo *old_core;
+	struct ssb_core *old_core;
 	int err;
 
-	old_core = bcm->current_core;
+	old_core = bcm->ssb.current_core;
 	err = switch_to_gpio_core(bcm);
 	if (err)
 		return err;
 	bcm43xx_write32(bcm, BCM43xx_GPIO_CONTROL, 0x00000000);
-	err = bcm43xx_switch_core(bcm, old_core);
+	err = ssb_switch_core(&bcm->ssb, old_core);
 	assert(err == 0);
 
 	return 0;
@@ -2493,7 +2091,7 @@
 	value = 0x0002;
 	if ((status & BCM43xx_SBF_MODE_NOTADHOC) &&
 	    !(status & BCM43xx_SBF_MODE_AP)) {
-		if (bcm->chip_id == 0x4306 && bcm->chip_rev == 3)
+		if (bcm->ssb.chip_id == 0x4306 && bcm->ssb.chip_rev == 3)
 			value = 0x0064;
 		else
 			value = 0x0032;
@@ -2615,7 +2213,7 @@
 		bcm43xx_write16(bcm, 0x005E, value16);
 	}
 	bcm43xx_write32(bcm, 0x0100, 0x01000000);
-	if (bcm->current_core->rev < 5)
+	if (bcm->ssb.current_core->rev < 5)
 		bcm43xx_write32(bcm, 0x010C, 0x01000000);
 
 	value32 = bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD);
@@ -2644,7 +2242,7 @@
 	/* Initially set the wireless operation mode. */
 	bcm43xx_select_opmode(bcm);
 
-	if (bcm->current_core->rev < 3) {
+	if (bcm->ssb.current_core->rev < 3) {
 		bcm43xx_write16(bcm, 0x060E, 0x0000);
 		bcm43xx_write16(bcm, 0x0610, 0x8000);
 		bcm43xx_write16(bcm, 0x0604, 0x0000);
@@ -2661,9 +2259,9 @@
 	bcm43xx_write32(bcm, BCM43xx_MMIO_DMA4_IRQ_MASK, 0x0000DC00);
 	bcm43xx_write32(bcm, BCM43xx_MMIO_DMA5_IRQ_MASK, 0x0000DC00);
 
-	value32 = bcm43xx_read32(bcm, BCM43xx_CIR_SBTMSTATELOW);
+	value32 = bcm43xx_read32(bcm, SSB_TMSLOW);
 	value32 |= 0x00100000;
-	bcm43xx_write32(bcm, BCM43xx_CIR_SBTMSTATELOW, value32);
+	bcm43xx_write32(bcm, SSB_TMSLOW, value32);
 
 	bcm43xx_write16(bcm, BCM43xx_MMIO_POWERUP_DELAY, bcm43xx_pctl_powerup_delay(bcm));
 
@@ -2687,7 +2285,7 @@
 	bcm43xx_pio_free(bcm);
 	bcm43xx_dma_free(bcm);
 
-	bcm->current_core->initialized = 0;
+	bcm43xx_current_80211_priv(bcm)->initialized = 0;
 }
 
 /* http://bcm-specs.sipsolutions.net/80211Init */
@@ -2701,17 +2299,17 @@
 	u32 sbimconfiglow;
 	u8 limit;
 
-	if (bcm->chip_rev < 5) {
-		sbimconfiglow = bcm43xx_read32(bcm, BCM43xx_CIR_SBIMCONFIGLOW);
-		sbimconfiglow &= ~ BCM43xx_SBIMCONFIGLOW_REQUEST_TOUT_MASK;
-		sbimconfiglow &= ~ BCM43xx_SBIMCONFIGLOW_SERVICE_TOUT_MASK;
+	if (bcm->ssb.chip_rev < 5) {
+		sbimconfiglow = bcm43xx_read32(bcm, SSB_IMCFGLO);
+		sbimconfiglow &= ~SSB_IMCFGLO_REQTO;
+		sbimconfiglow &= ~SSB_IMCFGLO_SERTO;
 		if (bcm->bustype == BCM43xx_BUSTYPE_PCI)
 			sbimconfiglow |= 0x32;
 		else if (bcm->bustype == BCM43xx_BUSTYPE_SB)
 			sbimconfiglow |= 0x53;
 		else
 			assert(0);
-		bcm43xx_write32(bcm, BCM43xx_CIR_SBIMCONFIGLOW, sbimconfiglow);
+		bcm43xx_write32(bcm, SSB_IMCFGLO, sbimconfiglow);
 	}
 
 	bcm43xx_phy_calibrate(bcm);
@@ -2719,7 +2317,7 @@
 	if (err)
 		goto out;
 
-	bcm43xx_shm_write16(bcm, BCM43xx_SHM_SHARED, 0x0016, bcm->current_core->rev);
+	bcm43xx_shm_write16(bcm, BCM43xx_SHM_SHARED, 0x0016, bcm->ssb.current_core->rev);
 	ucodeflags = bcm43xx_shm_read32(bcm, BCM43xx_SHM_SHARED, BCM43xx_UCODEFLAGS_OFFSET);
 
 	if (0 /*FIXME: which condition has to be used here? */)
@@ -2732,7 +2330,7 @@
 		ucodeflags |= BCM43xx_UCODEFLAG_UNKBGPHY;
 		if (phy->rev == 1)
 			ucodeflags |= BCM43xx_UCODEFLAG_UNKGPHY;
-		if (bcm->sprom.boardflags & BCM43xx_BFL_PACTRL)
+		if (bcm->sprom.r1.boardflags_lo & BCM43xx_BFL_PACTRL)
 			ucodeflags |= BCM43xx_UCODEFLAG_UNKPACTRL;
 	} else if (phy->type == BCM43xx_PHYTYPE_B) {
 		ucodeflags |= BCM43xx_UCODEFLAG_UNKBGPHY;
@@ -2770,7 +2368,7 @@
 
 	bcm43xx_write_mac_bssid_templates(bcm);
 
-	if (bcm->current_core->rev >= 5)
+	if (bcm->ssb.current_core->rev >= 5)
 		bcm43xx_write16(bcm, 0x043C, 0x000C);
 
 	if (active_wlcore) {
@@ -2793,7 +2391,7 @@
 	/* Don't enable MAC/IRQ here, as it will race with the IRQ handler.
 	 * We enable it later.
 	 */
-	bcm->current_core->initialized = 1;
+	bcm43xx_current_80211_priv(bcm)->initialized = 1;
 out:
 	return err;
 
@@ -2817,7 +2415,7 @@
 static void bcm43xx_periodic_every60sec(struct bcm43xx_private *bcm)
 {
 	bcm43xx_phy_lo_mark_all_unused(bcm);
-	if (bcm->sprom.boardflags & BCM43xx_BFL_RSSI) {
+	if (bcm->sprom.r1.boardflags_lo & BCM43xx_BFL_RSSI) {
 		bcm43xx_mac_suspend(bcm);
 		bcm43xx_calc_nrssi_slope(bcm);
 		bcm43xx_mac_enable(bcm);
@@ -2965,15 +2563,16 @@
 {
 	int ret = 0;
 	int i, err;
-	struct bcm43xx_coreinfo *core;
+	struct ssb_core *core;
+	struct bcm43xx_corepriv_80211 *wlpriv;
 
 	bcm43xx_set_status(bcm, BCM43xx_STAT_SHUTTINGDOWN);
 	for (i = 0; i < bcm->nr_80211_available; i++) {
-		core = &(bcm->core_80211[i]);
-		assert(core->available);
-		if (!core->initialized)
+		core = bcm->core_80211[i];
+		wlpriv = core->priv;
+		if (!wlpriv->initialized)
 			continue;
-		err = bcm43xx_switch_core(bcm, core);
+		err = ssb_switch_core(&bcm->ssb, core);
 		if (err) {
 			dprintk(KERN_ERR PFX "shutdown_all_wireless_cores "
 					     "switch_core failed (%d)\n", err);
@@ -3057,213 +2656,122 @@
 
 static int bcm43xx_probe_cores(struct bcm43xx_private *bcm)
 {
-	int err, i;
-	int current_core;
-	u32 core_vendor, core_id, core_rev;
-	u32 sb_id_hi, chip_id_32 = 0;
-	u16 pci_device, chip_id_16;
-	u8 core_count;
-
-	memset(&bcm->core_chipcommon, 0, sizeof(struct bcm43xx_coreinfo));
-	memset(&bcm->core_pci, 0, sizeof(struct bcm43xx_coreinfo));
-	memset(&bcm->core_80211, 0, sizeof(struct bcm43xx_coreinfo)
-				    * BCM43xx_MAX_80211_CORES);
-	memset(&bcm->core_80211_ext, 0, sizeof(struct bcm43xx_coreinfo_80211)
-					* BCM43xx_MAX_80211_CORES);
-	bcm->nr_80211_available = 0;
-	bcm->current_core = NULL;
-	bcm->active_80211_core = NULL;
-
-	/* map core 0 */
-	err = _switch_core(bcm, 0);
-	if (err)
-		goto out;
+	struct ssb *ssb = &bcm->ssb;
+	int err;
+	u16 chipid_fallback = 0;
+	struct ssb_core *core;
+	struct bcm43xx_corepriv_80211 *priv_80211;
+	int i;
 
-	/* fetch sb_id_hi from core information registers */
-	sb_id_hi = bcm43xx_read32(bcm, BCM43xx_CIR_SB_ID_HI);
+	static const struct ssb_nrcores_elem nrcores_fallback[] = {
+		{ .chip_id_key = 0x5365, .nr_cores_value = 7, },
+		{ .chip_id_key = 0x4306, .nr_cores_value = 6, },
+		{ .chip_id_key = 0x4310, .nr_cores_value = 8, },
+		{ .chip_id_key = 0x4307, .nr_cores_value = 5, },
+		{ .chip_id_key = 0x4301, .nr_cores_value = 5, },
+		{ .chip_id_key = 0x4402, .nr_cores_value = 3, },
+		{ .chip_id_key = 0x4710, .nr_cores_value = 9, },
+		{ .chip_id_key = 0x4610, .nr_cores_value = 9, },
+		{ .chip_id_key = 0x4704, .nr_cores_value = 9, },
+	};
 
-	core_id = (sb_id_hi & 0xFFF0) >> 4;
-	core_rev = (sb_id_hi & 0xF);
-	core_vendor = (sb_id_hi & 0xFFFF0000) >> 16;
-
-	/* if present, chipcommon is always core 0; read the chipid from it */
-	if (core_id == BCM43xx_COREID_CHIPCOMMON) {
-		chip_id_32 = bcm43xx_read32(bcm, 0);
-		chip_id_16 = chip_id_32 & 0xFFFF;
-		bcm->core_chipcommon.available = 1;
-		bcm->core_chipcommon.id = core_id;
-		bcm->core_chipcommon.rev = core_rev;
-		bcm->core_chipcommon.index = 0;
-		/* While we are at it, also read the capabilities. */
-		bcm->chipcommon_capabilities = bcm43xx_read32(bcm, BCM43xx_CHIPCOMMON_CAPABILITIES);
-	} else {
-		/* without a chipCommon, use a hard coded table. */
-		pci_device = bcm->pci_dev->device;
-		if (pci_device == 0x4301)
-			chip_id_16 = 0x4301;
-		else if ((pci_device >= 0x4305) && (pci_device <= 0x4307))
-			chip_id_16 = 0x4307;
-		else if ((pci_device >= 0x4402) && (pci_device <= 0x4403))
-			chip_id_16 = 0x4402;
-		else if ((pci_device >= 0x4610) && (pci_device <= 0x4615))
-			chip_id_16 = 0x4610;
-		else if ((pci_device >= 0x4710) && (pci_device <= 0x4715))
-			chip_id_16 = 0x4710;
+	switch (bcm->ssb.pci_dev->device) {
+	case 0x4301:
+		chipid_fallback = 0x4301;
+		break;
+	case 0x4305 ... 0x4307:
+		chipid_fallback = 0x4307;
+		break;
+	case 0x4402 ... 0x4403:
+		chipid_fallback = 0x4402;
+		break;
+	case 0x4610 ... 0x4615:
+		chipid_fallback = 0x4610;
+		break;
+	case 0x4710 ... 0x4715:
+		chipid_fallback = 0x4710;
+		break;
 #ifdef CONFIG_BCM947XX
-		else if ((pci_device >= 0x4320) && (pci_device <= 0x4325))
-			chip_id_16 = 0x4309;
+	case 0x4320 ... 0x4325:
+		chipid_fallback = 0x4309;
+		break;
 #endif
-		else {
-			printk(KERN_ERR PFX "Could not determine Chip ID\n");
-			return -ENODEV;
-		}
-	}
-
-	/* ChipCommon with Core Rev >=4 encodes number of cores,
-	 * otherwise consult hardcoded table */
-	if ((core_id == BCM43xx_COREID_CHIPCOMMON) && (core_rev >= 4)) {
-		core_count = (chip_id_32 & 0x0F000000) >> 24;
-	} else {
-		switch (chip_id_16) {
-			case 0x4610:
-			case 0x4704:
-			case 0x4710:
-				core_count = 9;
-				break;
-			case 0x4310:
-				core_count = 8;
-				break;
-			case 0x5365:
-				core_count = 7;
-				break;
-			case 0x4306:
-				core_count = 6;
-				break;
-			case 0x4301:
-			case 0x4307:
-				core_count = 5;
-				break;
-			case 0x4402:
-				core_count = 3;
-				break;
-			default:
-				/* SOL if we get here */
-				assert(0);
-				core_count = 1;
-		}
-	}
-
-	bcm->chip_id = chip_id_16;
-	bcm->chip_rev = (chip_id_32 & 0x000F0000) >> 16;
-	bcm->chip_package = (chip_id_32 & 0x00F00000) >> 20;
-
-	dprintk(KERN_INFO PFX "Chip ID 0x%x, rev 0x%x\n",
-		bcm->chip_id, bcm->chip_rev);
-	dprintk(KERN_INFO PFX "Number of cores: %d\n", core_count);
-	if (bcm->core_chipcommon.available) {
-		dprintk(KERN_INFO PFX "Core 0: ID 0x%x, rev 0x%x, vendor 0x%x, %s\n",
-			core_id, core_rev, core_vendor,
-			bcm43xx_core_enabled(bcm) ? "enabled" : "disabled");
 	}
+	err = ssb_probe_cores(ssb, chipid_fallback,
+			      nrcores_fallback,
+			      ARRAY_SIZE(nrcores_fallback));
+	if (err)
+		goto out;
 
-	if (bcm->core_chipcommon.available)
-		current_core = 1;
-	else
-		current_core = 0;
-	for ( ; current_core < core_count; current_core++) {
-		struct bcm43xx_coreinfo *core;
-		struct bcm43xx_coreinfo_80211 *ext_80211;
+	bcm->nr_80211_available = 0;
+	bcm->active_80211_core = NULL;
+	for (i = 0; i < ssb->nr_cores; i++) {
+		core = &(ssb->cores[i]);
 
-		err = _switch_core(bcm, current_core);
-		if (err)
-			goto out;
-		/* Gather information */
-		/* fetch sb_id_hi from core information registers */
-		sb_id_hi = bcm43xx_read32(bcm, BCM43xx_CIR_SB_ID_HI);
-
-		/* extract core_id, core_rev, core_vendor */
-		core_id = (sb_id_hi & 0xFFF0) >> 4;
-		core_rev = (sb_id_hi & 0xF);
-		core_vendor = (sb_id_hi & 0xFFFF0000) >> 16;
-
-		dprintk(KERN_INFO PFX "Core %d: ID 0x%x, rev 0x%x, vendor 0x%x, %s\n",
-			current_core, core_id, core_rev, core_vendor,
-			bcm43xx_core_enabled(bcm) ? "enabled" : "disabled" );
-
-		core = NULL;
-		switch (core_id) {
-		case BCM43xx_COREID_PCI:
-			core = &bcm->core_pci;
-			if (core->available) {
+		switch (core->cc) {
+		case SSB_CC_PCI:
+			if (bcm->core_pci) {
 				printk(KERN_WARNING PFX "Multiple PCI cores found.\n");
-				continue;
+				break;
 			}
+			bcm->core_pci = core;
 			break;
-		case BCM43xx_COREID_80211:
-			for (i = 0; i < BCM43xx_MAX_80211_CORES; i++) {
-				core = &(bcm->core_80211[i]);
-				ext_80211 = &(bcm->core_80211_ext[i]);
-				if (!core->available)
-					break;
-				core = NULL;
-			}
-			if (!core) {
-				printk(KERN_WARNING PFX "More than %d cores of type 802.11 found.\n",
+		case SSB_CC_80211:
+			if (bcm->nr_80211_available == BCM43xx_MAX_80211_CORES) {
+				printk(KERN_WARNING PFX "More tham %d cores of "
+							"type 802.11 found.\n",
 				       BCM43xx_MAX_80211_CORES);
-				continue;
+				break;
 			}
-			if (i != 0) {
+			if (bcm->nr_80211_available == 1) {
 				/* More than one 80211 core is only supported
 				 * by special chips.
 				 * There are chips with two 80211 cores, but with
 				 * dangling pins on the second core. Be careful
 				 * and ignore these cores here.
 				 */
-				if (bcm->pci_dev->device != 0x4324) {
+				if (bcm->ssb.pci_dev->device != 0x4324) {
 					dprintk(KERN_INFO PFX "Ignoring additional 802.11 core.\n");
-					continue;
+					break;
 				}
 			}
-			switch (core_rev) {
-			case 2:
-			case 4:
-			case 5:
-			case 6:
-			case 7:
-			case 9:
+
+			bcm->core_80211[bcm->nr_80211_available] = core;
+			priv_80211 = &(bcm->corepriv_80211[bcm->nr_80211_available]);
+			bcm->nr_80211_available++;
+
+			switch (core->rev) {
+			case 2: case 4: case 5: case 6:
+			case 7: case 9:
 				break;
 			default:
 				printk(KERN_ERR PFX "Error: Unsupported 80211 core revision %u\n",
-				       core_rev);
+				       core->rev);
 				err = -ENODEV;
 				goto out;
 			}
-			bcm->nr_80211_available++;
-			core->priv = ext_80211;
-			bcm43xx_init_struct_phyinfo(&ext_80211->phy);
-			bcm43xx_init_struct_radioinfo(&ext_80211->radio);
+			core->priv = priv_80211;
+			bcm43xx_init_struct_phyinfo(&priv_80211->phy);
+			bcm43xx_init_struct_radioinfo(&priv_80211->radio);
 			break;
-		case BCM43xx_COREID_CHIPCOMMON:
-			printk(KERN_WARNING PFX "Multiple CHIPCOMMON cores found.\n");
+		case SSB_CC_CHIPCOMMON:
+			if (bcm->core_chipcommon) {
+				printk(KERN_WARNING PFX "Multiple CHIPCOMMON cores found.\n");
+				break;
+			}
+			bcm->core_chipcommon = core;
 			break;
 		}
-		if (core) {
-			core->available = 1;
-			core->id = core_id;
-			core->rev = core_rev;
-			core->index = current_core;
-		}
 	}
-
-	if (!bcm->core_80211[0].available) {
+	if (!bcm->core_80211[0]) {
 		printk(KERN_ERR PFX "Error: No 80211 core found!\n");
 		err = -ENODEV;
 		goto out;
 	}
+	err = ssb_switch_core(ssb, bcm->core_80211[0]);
+	if (err)
+		goto out;
 
-	err = bcm43xx_switch_core(bcm, &bcm->core_80211[0]);
-
-	assert(err == 0);
 out:
 	return err;
 }
@@ -3289,90 +2797,6 @@
 	bcm43xx_pctl_set_crystal(bcm, 0);
 }
 
-static void bcm43xx_pcicore_broadcast_value(struct bcm43xx_private *bcm,
-					    u32 address,
-					    u32 data)
-{
-	bcm43xx_write32(bcm, BCM43xx_PCICORE_BCAST_ADDR, address);
-	bcm43xx_write32(bcm, BCM43xx_PCICORE_BCAST_DATA, data);
-}
-
-static int bcm43xx_pcicore_commit_settings(struct bcm43xx_private *bcm)
-{
-	int err;
-	struct bcm43xx_coreinfo *old_core;
-
-	old_core = bcm->current_core;
-	err = bcm43xx_switch_core(bcm, &bcm->core_pci);
-	if (err)
-		goto out;
-
-	bcm43xx_pcicore_broadcast_value(bcm, 0xfd8, 0x00000000);
-
-	bcm43xx_switch_core(bcm, old_core);
-	assert(err == 0);
-out:
-	return err;
-}
-
-/* Make an I/O Core usable. "core_mask" is the bitmask of the cores to enable.
- * To enable core 0, pass a core_mask of 1<<0
- */
-static int bcm43xx_setup_backplane_pci_connection(struct bcm43xx_private *bcm,
-						  u32 core_mask)
-{
-	u32 backplane_flag_nr;
-	u32 value;
-	struct bcm43xx_coreinfo *old_core;
-	int err = 0;
-
-	value = bcm43xx_read32(bcm, BCM43xx_CIR_SBTPSFLAG);
-	backplane_flag_nr = value & BCM43xx_BACKPLANE_FLAG_NR_MASK;
-
-	old_core = bcm->current_core;
-	err = bcm43xx_switch_core(bcm, &bcm->core_pci);
-	if (err)
-		goto out;
-
-	if (bcm->core_pci.rev < 6) {
-		value = bcm43xx_read32(bcm, BCM43xx_CIR_SBINTVEC);
-		value |= (1 << backplane_flag_nr);
-		bcm43xx_write32(bcm, BCM43xx_CIR_SBINTVEC, value);
-	} else {
-		err = bcm43xx_pci_read_config32(bcm, BCM43xx_PCICFG_ICR, &value);
-		if (err) {
-			printk(KERN_ERR PFX "Error: ICR setup failure!\n");
-			goto out_switch_back;
-		}
-		value |= core_mask << 8;
-		err = bcm43xx_pci_write_config32(bcm, BCM43xx_PCICFG_ICR, value);
-		if (err) {
-			printk(KERN_ERR PFX "Error: ICR setup failure!\n");
-			goto out_switch_back;
-		}
-	}
-
-	value = bcm43xx_read32(bcm, BCM43xx_PCICORE_SBTOPCI2);
-	value |= BCM43xx_SBTOPCI2_PREFETCH | BCM43xx_SBTOPCI2_BURST;
-	bcm43xx_write32(bcm, BCM43xx_PCICORE_SBTOPCI2, value);
-
-	if (bcm->core_pci.rev < 5) {
-		value = bcm43xx_read32(bcm, BCM43xx_CIR_SBIMCONFIGLOW);
-		value |= (2 << BCM43xx_SBIMCONFIGLOW_SERVICE_TOUT_SHIFT)
-			 & BCM43xx_SBIMCONFIGLOW_SERVICE_TOUT_MASK;
-		value |= (3 << BCM43xx_SBIMCONFIGLOW_REQUEST_TOUT_SHIFT)
-			 & BCM43xx_SBIMCONFIGLOW_REQUEST_TOUT_MASK;
-		bcm43xx_write32(bcm, BCM43xx_CIR_SBIMCONFIGLOW, value);
-		err = bcm43xx_pcicore_commit_settings(bcm);
-		assert(err == 0);
-	}
-
-out_switch_back:
-	err = bcm43xx_switch_core(bcm, old_core);
-out:
-	return err;
-}
-
 static void bcm43xx_free_modes(struct bcm43xx_private *bcm)
 {
 	struct ieee80211_hw *ieee = bcm->ieee;
@@ -3434,8 +2858,8 @@
 {
 	int err = -ENOMEM;
 	struct ieee80211_hw *ieee = bcm->ieee;
-	struct bcm43xx_coreinfo *core;
-	struct bcm43xx_coreinfo_80211 *wlext;
+	struct ssb_core *core;
+	struct bcm43xx_corepriv_80211 *wlpriv;
 	int i, nr_modes;
 
 	nr_modes = bcm->nr_80211_available;
@@ -3446,10 +2870,10 @@
 	ieee->num_modes = 0;
 
 	for (i = 0; i < bcm->nr_80211_available; i++) {
-		core = &(bcm->core_80211[i]);
-		wlext = core->priv;
+		core = bcm->core_80211[i];
+		wlpriv = core->priv;
 
-		switch (wlext->phy.type) {
+		switch (wlpriv->phy.type) {
 		case BCM43xx_PHYTYPE_A:
 			err = bcm43xx_append_mode(bcm->ieee, MODE_IEEE80211A,
 						  ARRAY_SIZE(bcm43xx_a_chantable),
@@ -3543,8 +2967,8 @@
 static void prepare_priv_for_init(struct bcm43xx_private *bcm)
 {
 	int i;
-	struct bcm43xx_coreinfo *core;
-	struct bcm43xx_coreinfo_80211 *wlext;
+	struct ssb_core *core;
+	struct bcm43xx_corepriv_80211 *wlpriv;
 
 	assert(!bcm->active_80211_core);
 
@@ -3558,16 +2982,13 @@
 	memset(&bcm->stats, 0, sizeof(bcm->stats));
 
 	/* Wireless core data */
-	for (i = 0; i < BCM43xx_MAX_80211_CORES; i++) {
-		core = &(bcm->core_80211[i]);
-		wlext = core->priv;
-
-		if (!core->available)
-			continue;
-		assert(wlext == &(bcm->core_80211_ext[i]));
+	for (i = 0; i < bcm->nr_80211_available; i++) {
+		core = bcm->core_80211[i];
+		wlpriv = core->priv;
+		assert(wlpriv == &(bcm->corepriv_80211[i]));
 
-		prepare_phydata_for_init(&wlext->phy);
-		prepare_radiodata_for_init(bcm, &wlext->radio);
+		prepare_phydata_for_init(&wlpriv->phy);
+		prepare_radiodata_for_init(bcm, &wlpriv->radio);
 	}
 
 	/* IRQ related flags */
@@ -3589,7 +3010,7 @@
 {
 	int err;
 
-	if (!bcm43xx_core_enabled(bcm))
+	if (!ssb_core_is_enabled(&bcm->ssb))
 		bcm43xx_wireless_core_reset(bcm, 1);
 	if (!active_wlcore)
 		bcm43xx_wireless_core_mark_inactive(bcm);
@@ -3610,27 +3031,27 @@
 				 int phytype)
 {
 	int i, err;
-	struct bcm43xx_coreinfo *active_core = NULL;
-	struct bcm43xx_coreinfo_80211 *active_wlext = NULL;
-	struct bcm43xx_coreinfo *core;
-	struct bcm43xx_coreinfo_80211 *wlext;
+	struct ssb_core *active_core = NULL;
+	struct bcm43xx_corepriv_80211 *active_wlpriv = NULL;
+	struct ssb_core *core;
+	struct bcm43xx_corepriv_80211 *wlpriv;
 	int adjust_active_sbtmstatelow = 0;
 
 	might_sleep();
 
 	if (phytype < 0) {
 		/* If no phytype is requested, select the first core. */
-		assert(bcm->core_80211[0].available);
-		wlext = bcm->core_80211[0].priv;
-		phytype = wlext->phy.type;
+		assert(bcm->nr_80211_available != 0);
+		wlpriv = bcm->core_80211[0]->priv;
+		phytype = wlpriv->phy.type;
 	}
 	/* Find the requested core. */
 	for (i = 0; i < bcm->nr_80211_available; i++) {
-		core = &(bcm->core_80211[i]);
-		wlext = core->priv;
-		if (wlext->phy.type == phytype) {
+		core = bcm->core_80211[i];
+		wlpriv = core->priv;
+		if (wlpriv->phy.type == phytype) {
 			active_core = core;
-			active_wlext = wlext;
+			active_wlpriv = wlpriv;
 			break;
 		}
 	}
@@ -3667,12 +3088,12 @@
 
 	/* Mark all unused cores "inactive". */
 	for (i = 0; i < bcm->nr_80211_available; i++) {
-		core = &(bcm->core_80211[i]);
-		wlext = core->priv;
+		core = bcm->core_80211[i];
+		wlpriv = core->priv;
 
 		if (core == active_core)
 			continue;
-		err = bcm43xx_switch_core(bcm, core);
+		err = ssb_switch_core(&bcm->ssb, core);
 		if (err) {
 			dprintk(KERN_ERR PFX "Could not switch to inactive "
 					     "802.11 core (%d)\n", err);
@@ -3688,19 +3109,19 @@
 	}
 
 	/* Now initialize the active 802.11 core. */
-	err = bcm43xx_switch_core(bcm, active_core);
+	err = ssb_switch_core(&bcm->ssb, active_core);
 	if (err) {
 		dprintk(KERN_ERR PFX "Could not switch to active "
 				     "802.11 core (%d)\n", err);
 		goto error;
 	}
 	if (adjust_active_sbtmstatelow &&
-	    active_wlext->phy.type == BCM43xx_PHYTYPE_G) {
+	    active_wlpriv->phy.type == BCM43xx_PHYTYPE_G) {
 		u32 sbtmstatelow;
 
-		sbtmstatelow = bcm43xx_read32(bcm, BCM43xx_CIR_SBTMSTATELOW);
+		sbtmstatelow = bcm43xx_read32(bcm, SSB_TMSLOW);
 		sbtmstatelow |= 0x20000000;
-		bcm43xx_write32(bcm, BCM43xx_CIR_SBTMSTATELOW, sbtmstatelow);
+		bcm43xx_write32(bcm, SSB_TMSLOW, sbtmstatelow);
 	}
 	err = wireless_core_up(bcm, 1);
 	if (err) {
@@ -3732,7 +3153,7 @@
 	bcm43xx_interrupt_enable(bcm, bcm->irq_savedstate);
 
 	dprintk(KERN_INFO PFX "Selected 802.11 core (phytype %d)\n",
-		active_wlext->phy.type);
+		active_wlpriv->phy.type);
 
 	return 0;
 
@@ -3778,20 +3199,21 @@
 
 static void bcm43xx_detach_board(struct bcm43xx_private *bcm)
 {
-	struct pci_dev *pci_dev = bcm->pci_dev;
+	struct pci_dev *pci_dev = bcm->ssb.pci_dev;
 	int i;
 
 	bcm43xx_chipset_detach(bcm);
+	ssb_exit(&bcm->ssb);
 	/* Do _not_ access the chip, after it is detached. */
-	pci_iounmap(pci_dev, bcm->mmio_addr);
+	pci_iounmap(pci_dev, bcm->ssb.mmio);
 	pci_release_regions(pci_dev);
 	pci_disable_device(pci_dev);
 
 	/* Free allocated structures/fields */
 	for (i = 0; i < BCM43xx_MAX_80211_CORES; i++) {
-		kfree(bcm->core_80211_ext[i].phy._lo_pairs);
-		if (bcm->core_80211_ext[i].phy.dyn_tssi_tbl)
-			kfree(bcm->core_80211_ext[i].phy.tssi2dbm);
+		kfree(bcm->corepriv_80211[i].phy._lo_pairs);
+		if (bcm->corepriv_80211[i].phy.dyn_tssi_tbl)
+			kfree(bcm->corepriv_80211[i].phy.tssi2dbm);
 	}
 	bcm43xx_free_modes(bcm);
 }
@@ -3852,13 +3274,42 @@
 	return 0;
 }
 
-static int bcm43xx_attach_board(struct bcm43xx_private *bcm)
+static int bcm43xx_ssb_suspend(struct ssb *ssb)
+{
+	int i;
+	int err;
+	struct bcm43xx_private *bcm = ssb_to_bcm43xx(ssb);
+
+	for (i = 0; i < bcm->ieee->queues; i++)
+		ieee80211_stop_queue(bcm->net_dev, i);
+	ieee80211_netif_oper(bcm->net_dev, NETIF_DETACH);
+
+	err = bcm43xx_net_stop(bcm->net_dev);
+	if (!err)
+		mutex_lock(&bcm->mutex);
+
+	return err;
+}
+
+static int bcm43xx_ssb_resume(struct ssb *ssb)
+{
+	int err;
+	struct bcm43xx_private *bcm = ssb_to_bcm43xx(ssb);
+
+	mutex_unlock(&bcm->mutex);
+	err = bcm43xx_net_open(bcm->net_dev);
+
+	return err;
+}
+
+static int bcm43xx_attach_board(struct bcm43xx_private *bcm,
+				struct pci_dev *pci_dev)
 {
-	struct pci_dev *pci_dev = bcm->pci_dev;
 	struct net_device *net_dev = bcm->net_dev;
 	int err;
 	int i;
 	u32 coremask;
+	void __iomem *mmio;
 
 	err = pci_enable_device(pci_dev);
 	if (err) {
@@ -3872,13 +3323,19 @@
 	}
 	/* enable PCI bus-mastering */
 	pci_set_master(pci_dev);
-	bcm->mmio_addr = pci_iomap(pci_dev, 0, ~0UL);
-	if (!bcm->mmio_addr) {
+	mmio = pci_iomap(pci_dev, 0, ~0UL);
+	if (!mmio) {
 		printk(KERN_ERR PFX "pci_iomap() failed\n");
 		err = -EIO;
 		goto err_pci_release;
 	}
-	net_dev->base_addr = (unsigned long)bcm->mmio_addr;
+	net_dev->base_addr = (unsigned long)mmio;
+
+	err = ssb_init(&bcm->ssb, pci_dev, mmio,
+		       bcm43xx_ssb_suspend,
+		       bcm43xx_ssb_resume);
+	if (err)
+		goto err_iounmap;
 
 	bcm43xx_pci_read_config16(bcm, PCI_SUBSYSTEM_VENDOR_ID,
 	                          &bcm->board_vendor);
@@ -3889,22 +3346,23 @@
 
 	err = bcm43xx_chipset_attach(bcm);
 	if (err)
-		goto err_iounmap;
+		goto err_ssb_exit;
 	err = bcm43xx_pctl_init(bcm);
 	if (err)
 		goto err_chipset_detach;
 	err = bcm43xx_probe_cores(bcm);
 	if (err)
 		goto err_chipset_detach;
-	
+
+	printk(KERN_INFO PFX "Broadcom %04X WLAN found\n", bcm->ssb.chip_id);
+
 	/* Attach all IO cores to the backplane. */
 	coremask = 0;
 	for (i = 0; i < bcm->nr_80211_available; i++)
-		coremask |= (1 << bcm->core_80211[i].index);
-	//FIXME: Also attach some non80211 cores?
-	err = bcm43xx_setup_backplane_pci_connection(bcm, coremask);
+		coremask |= (1 << bcm->core_80211[i]->index);
+	err = ssb_cores_connect(&bcm->ssb, coremask);
 	if (err) {
-		printk(KERN_ERR PFX "Backplane->PCI connection failed!\n");
+		printk(KERN_ERR PFX "Could not connect cores\n");
 		goto err_chipset_detach;
 	}
 
@@ -3916,7 +3374,7 @@
 		goto err_chipset_detach;
 
 	for (i = 0; i < bcm->nr_80211_available; i++) {
-		err = bcm43xx_switch_core(bcm, &bcm->core_80211[i]);
+		err = ssb_switch_core(&bcm->ssb, bcm->core_80211[i]);
 		assert(err != -ENODEV);
 		if (err)
 			goto err_80211_unwind;
@@ -3947,29 +3405,28 @@
 	bcm43xx_pctl_set_crystal(bcm, 0);
 
 	/* Set the MAC address in the networking subsystem */
-	if (is_valid_ether_addr(bcm->sprom.et1macaddr))
-		memcpy(bcm->net_dev->dev_addr, bcm->sprom.et1macaddr, 6);
+	if (is_valid_ether_addr(bcm->sprom.r1.et1mac))
+		memcpy(bcm->net_dev->dev_addr, bcm->sprom.r1.et1mac, 6);
 	else
-		memcpy(bcm->net_dev->dev_addr, bcm->sprom.il0macaddr, 6);
+		memcpy(bcm->net_dev->dev_addr, bcm->sprom.r1.il0mac, 6);
 	bcm43xx_setup_modes(bcm);
 
-	snprintf(bcm->nick, IW_ESSID_MAX_SIZE,
-		 "Broadcom %04X", bcm->chip_id);
-
 	assert(err == 0);
 out:
 	return err;
 
 err_80211_unwind:
 	for (i = 0; i < BCM43xx_MAX_80211_CORES; i++) {
-		kfree(bcm->core_80211_ext[i].phy._lo_pairs);
-		if (bcm->core_80211_ext[i].phy.dyn_tssi_tbl)
-			kfree(bcm->core_80211_ext[i].phy.tssi2dbm);
+		kfree(bcm->corepriv_80211[i].phy._lo_pairs);
+		if (bcm->corepriv_80211[i].phy.dyn_tssi_tbl)
+			kfree(bcm->corepriv_80211[i].phy.tssi2dbm);
 	}
 err_chipset_detach:
 	bcm43xx_chipset_detach(bcm);
+err_ssb_exit:
+	ssb_exit(&bcm->ssb);
 err_iounmap:
-	pci_iounmap(pci_dev, bcm->mmio_addr);
+	pci_iounmap(pci_dev, mmio);
 err_pci_release:
 	pci_release_regions(pci_dev);
 err_pci_disable:
@@ -4386,7 +3843,6 @@
 
 	bcm->ieee = ieee;
 	bcm->irq_savedstate = BCM43xx_IRQ_INITIAL;
-	bcm->pci_dev = pci_dev;
 	bcm->net_dev = net_dev;
 	bcm->bad_frames_preempt = modparam_bad_frames_preempt;
 	spin_lock_init(&bcm->irq_lock);
@@ -4475,7 +3931,7 @@
 	pci_set_drvdata(pdev, net_dev);
 	SET_NETDEV_DEV(net_dev, &pdev->dev);
 
-	err = bcm43xx_attach_board(bcm);
+	err = bcm43xx_attach_board(bcm, pdev);
 	if (err)
 		goto err_free_netdev;
 	err = ieee80211_register_hw(net_dev, ieee);
@@ -4632,7 +4088,6 @@
 
 static int __init bcm43xx_init(void)
 {
-	printk(KERN_INFO KBUILD_MODNAME " driver\n");
 	bcm43xx_debugfs_init();
 	return pci_register_driver(&bcm43xx_pci_driver);
 }
Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_debugfs.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_debugfs.c	2006-08-23 10:47:32.000000000 +0200
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_debugfs.c	2006-08-23 10:58:41.000000000 +0200
@@ -84,7 +84,7 @@
 		goto out;
 	}
 	net_dev = bcm->net_dev;
-	pci_dev = bcm->pci_dev;
+	pci_dev = bcm->ssb.pci_dev;
 
 	/* This is where the information is written to the "devinfo" file */
 	fappend("*** %s devinfo ***\n", net_dev->name);
@@ -93,23 +93,23 @@
 	fappend("subsystem_vendor: 0x%04x   subsystem_device: 0x%04x\n",
 		pci_dev->subsystem_vendor, pci_dev->subsystem_device);
 	fappend("IRQ: %d\n", bcm->irq);
-	fappend("mmio_addr: 0x%p\n", bcm->mmio_addr);
-	fappend("chip_id: 0x%04x   chip_rev: 0x%02x\n", bcm->chip_id, bcm->chip_rev);
-	if ((bcm->core_80211[0].rev >= 3) && (bcm43xx_read32(bcm, 0x0158) & (1 << 16)))
+	fappend("mmio: 0x%p\n", bcm->ssb.mmio);
+	fappend("chip_id: 0x%04x   chip_rev: 0x%02x\n", bcm->ssb.chip_id, bcm->ssb.chip_rev);
+	if ((bcm->core_80211[0]->rev >= 3) && (bcm43xx_read32(bcm, 0x0158) & (1 << 16)))
 		fappend("Radio disabled by hardware!\n");
-	if ((bcm->core_80211[0].rev < 3) && !(bcm43xx_read16(bcm, 0x049A) & (1 << 4)))
+	if ((bcm->core_80211[0]->rev < 3) && !(bcm43xx_read16(bcm, 0x049A) & (1 << 4)))
 		fappend("Radio disabled by hardware!\n");
 	fappend("board_vendor: 0x%04x   board_type: 0x%04x\n", bcm->board_vendor,
 	        bcm->board_type);
 
 	fappend("\nCores:\n");
-#define fappend_core(name, info) fappend("core \"" name "\" %s, %s, id: 0x%04x, "	\
+#define fappend_core(name, info) fappend("core \"" name "\" %s, id: 0x%04x, "		\
 					 "rev: 0x%02x, index: 0x%02x\n",		\
-					 (info).available				\
+					 (info)						\
 						? "available" : "nonavailable",		\
-					 (info).enabled					\
-						? "enabled" : "disabled",		\
-					 (info).id, (info).rev, (info).index)
+					 (info) ? (info)->cc : 0,			\
+					 (info) ? (info)->rev : 0,			\
+					 (info) ? (info)->index : 0)
 	fappend_core("CHIPCOMMON", bcm->core_chipcommon);
 	fappend_core("PCI", bcm->core_pci);
 	fappend_core("first 80211", bcm->core_80211[0]);
@@ -149,36 +149,6 @@
 	return res;
 }
 
-static ssize_t spromdump_read_file(struct file *file, char __user *userbuf,
-				 size_t count, loff_t *ppos)
-{
-	const size_t len = REALLY_BIG_BUFFER_SIZE;
-
-	struct bcm43xx_private *bcm = file->private_data;
-	char *buf = really_big_buffer;
-	size_t pos = 0;
-	ssize_t res;
-	unsigned long flags;
-
-	down(&big_buffer_sem);
-	mutex_lock(&bcm->mutex);
-	spin_lock_irqsave(&bcm->irq_lock, flags);
-	if (bcm43xx_status(bcm) != BCM43xx_STAT_INITIALIZED) {
-		fappend("Board not initialized.\n");
-		goto out;
-	}
-
-	/* This is where the information is written to the "sprom_dump" file */
-	fappend("boardflags: 0x%04x\n", bcm->sprom.boardflags);
-
-out:
-	spin_unlock_irqrestore(&bcm->irq_lock, flags);
-	mutex_unlock(&bcm->mutex);
-	res = simple_read_from_buffer(userbuf, count, ppos, buf, pos);
-	up(&big_buffer_sem);
-	return res;
-}
-
 static ssize_t tsf_read_file(struct file *file, char __user *userbuf,
 			     size_t count, loff_t *ppos)
 {
@@ -361,12 +331,6 @@
 	.open = open_file_generic,
 };
 
-static struct file_operations spromdump_fops = {
-	.read = spromdump_read_file,
-	.write = write_file_dummy,
-	.open = open_file_generic,
-};
-
 static struct file_operations drvinfo_fops = {
 	.read = drvinfo_read_file,
 	.write = write_file_dummy,
@@ -429,10 +393,6 @@
 						bcm, &devinfo_fops);
 	if (!e->dentry_devinfo)
 		printk(KERN_ERR PFX "debugfs: creating \"devinfo\" for \"%s\" failed!\n", devdir);
-	e->dentry_spromdump = debugfs_create_file("sprom_dump", 0444, e->subdir,
-						  bcm, &spromdump_fops);
-	if (!e->dentry_spromdump)
-		printk(KERN_ERR PFX "debugfs: creating \"sprom_dump\" for \"%s\" failed!\n", devdir);
 	e->dentry_tsf = debugfs_create_file("tsf", 0666, e->subdir,
 	                                    bcm, &tsf_fops);
 	if (!e->dentry_tsf)
@@ -456,7 +416,6 @@
 
 	e = bcm->dfsentry;
 	assert(e);
-	debugfs_remove(e->dentry_spromdump);
 	debugfs_remove(e->dentry_devinfo);
 	debugfs_remove(e->dentry_tsf);
 	debugfs_remove(e->dentry_txstat);
Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c	2006-08-23 10:47:32.000000000 +0200
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c	2006-08-23 10:58:41.000000000 +0200
@@ -327,11 +327,11 @@
 	dma_addr_t dmaaddr;
 
 	if (tx) {
-		dmaaddr = dma_map_single(&ring->bcm->pci_dev->dev,
+		dmaaddr = dma_map_single(&ring->bcm->ssb.pci_dev->dev,
 					 buf, len,
 					 DMA_TO_DEVICE);
 	} else {
-		dmaaddr = dma_map_single(&ring->bcm->pci_dev->dev,
+		dmaaddr = dma_map_single(&ring->bcm->ssb.pci_dev->dev,
 					 buf, len,
 					 DMA_FROM_DEVICE);
 	}
@@ -346,11 +346,11 @@
 		      int tx)
 {
 	if (tx) {
-		dma_unmap_single(&ring->bcm->pci_dev->dev,
+		dma_unmap_single(&ring->bcm->ssb.pci_dev->dev,
 				 addr, len,
 				 DMA_TO_DEVICE);
 	} else {
-		dma_unmap_single(&ring->bcm->pci_dev->dev,
+		dma_unmap_single(&ring->bcm->ssb.pci_dev->dev,
 				 addr, len,
 				 DMA_FROM_DEVICE);
 	}
@@ -363,7 +363,7 @@
 {
 	assert(!ring->tx);
 
-	dma_sync_single_for_cpu(&ring->bcm->pci_dev->dev,
+	dma_sync_single_for_cpu(&ring->bcm->ssb.pci_dev->dev,
 				addr, len, DMA_FROM_DEVICE);
 }
 
@@ -374,7 +374,7 @@
 {
 	assert(!ring->tx);
 
-	dma_sync_single_for_device(&ring->bcm->pci_dev->dev,
+	dma_sync_single_for_device(&ring->bcm->ssb.pci_dev->dev,
 				   addr, len, DMA_FROM_DEVICE);
 }
 
@@ -393,7 +393,7 @@
 
 static int alloc_ringmemory(struct bcm43xx_dmaring *ring)
 {
-	struct device *dev = &(ring->bcm->pci_dev->dev);
+	struct device *dev = &(ring->bcm->ssb.pci_dev->dev);
 
 	ring->descbase = dma_alloc_coherent(dev, BCM43xx_DMA_RINGMEMSIZE,
 					    &(ring->dmabase), GFP_KERNEL);
@@ -408,7 +408,7 @@
 
 static void free_ringmemory(struct bcm43xx_dmaring *ring)
 {
-	struct device *dev = &(ring->bcm->pci_dev->dev);
+	struct device *dev = &(ring->bcm->ssb.pci_dev->dev);
 
 	dma_free_coherent(dev, BCM43xx_DMA_RINGMEMSIZE,
 			  ring->descbase, ring->dmabase);
@@ -727,7 +727,7 @@
 	if (dma64)
 		ring->routing = BCM43xx_DMA64_CLIENTTRANS;
 #ifdef CONFIG_BCM947XX
-	if (bcm->pci_dev->bus->number == 0)
+	if (bcm->ssb.pci_dev->bus->number == 0)
 		ring->routing = dma64 ? BCM43xx_DMA64_NOTRANS : BCM43xx_DMA32_NOTRANS;
 #endif
 
@@ -832,8 +832,8 @@
 	int dma64 = 0;
 	u32 sbtmstatehi;
 
-	sbtmstatehi = bcm43xx_read32(bcm, BCM43xx_CIR_SBTMSTATEHIGH);
-	if (sbtmstatehi & BCM43xx_SBTMSTATEHIGH_DMA64BIT)
+	sbtmstatehi = bcm43xx_read32(bcm, SSB_TMSHIGH);
+	if (sbtmstatehi & SSB_TMSHIGH_DMA64)
 		dma64 = 1;
 
 	/* setup TX DMA channels. */
@@ -873,7 +873,7 @@
 		goto err_destroy_tx5;
 	dma->rx_ring0 = ring;
 
-	if (bcm->current_core->rev < 5) {
+	if (bcm->ssb.current_core->rev < 5) {
 		ring = bcm43xx_setup_dmaring(bcm, 3, 0, dma64);
 		if (!ring)
 			goto err_destroy_rx0;
Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.h
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.h	2006-08-23 10:47:32.000000000 +0200
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.h	2006-08-23 10:58:41.000000000 +0200
@@ -128,8 +128,6 @@
 
 void bcm43xx_dummy_transmission(struct bcm43xx_private *bcm);
 
-int bcm43xx_switch_core(struct bcm43xx_private *bcm, struct bcm43xx_coreinfo *new_core);
-
 int bcm43xx_select_wireless_core(struct bcm43xx_private *bcm,
 				 int phytype);
 
@@ -140,7 +138,4 @@
 
 void bcm43xx_controller_restart(struct bcm43xx_private *bcm, const char *reason);
 
-int bcm43xx_sprom_read(struct bcm43xx_private *bcm, u16 *sprom);
-int bcm43xx_sprom_write(struct bcm43xx_private *bcm, const u16 *sprom);
-
 #endif /* BCM43xx_MAIN_H_ */
Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c	2006-08-23 10:47:32.000000000 +0200
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c	2006-08-23 10:58:41.000000000 +0200
@@ -90,7 +90,7 @@
 		phy->is_locked = 0;
 		return;
 	}
-	if (bcm->current_core->rev < 3) {
+	if (bcm->ssb.current_core->rev < 3) {
 		bcm43xx_mac_suspend(bcm);
 		spin_lock(&phy->lock);
 	} else {
@@ -105,7 +105,7 @@
 	struct bcm43xx_phyinfo *phy = bcm43xx_current_phy(bcm);
 
 	assert(irqs_disabled());
-	if (bcm->current_core->rev < 3) {
+	if (bcm->ssb.current_core->rev < 3) {
 		if (phy->is_locked) {
 			spin_unlock(&phy->lock);
 			bcm43xx_mac_enable(bcm);
@@ -161,22 +161,22 @@
 	struct bcm43xx_phyinfo *phy = bcm43xx_current_phy(bcm);
 	u32 flags;
 
-	if (bcm->current_core->rev < 5)
+	if (bcm->ssb.current_core->rev < 5)
 		goto out;
 
-	flags = bcm43xx_read32(bcm, BCM43xx_CIR_SBTMSTATEHIGH);
+	flags = bcm43xx_read32(bcm, SSB_TMSHIGH);
 	if (connect) {
 		if (!(flags & 0x00010000))
 			return -ENODEV;
-		flags = bcm43xx_read32(bcm, BCM43xx_CIR_SBTMSTATELOW);
+		flags = bcm43xx_read32(bcm, SSB_TMSLOW);
 		flags |= (0x800 << 18);
-		bcm43xx_write32(bcm, BCM43xx_CIR_SBTMSTATELOW, flags);
+		bcm43xx_write32(bcm, SSB_TMSLOW, flags);
 	} else {
 		if (!(flags & 0x00020000))
 			return -ENODEV;
-		flags = bcm43xx_read32(bcm, BCM43xx_CIR_SBTMSTATELOW);
+		flags = bcm43xx_read32(bcm, SSB_TMSHIGH);
 		flags &= ~(0x800 << 18);
-		bcm43xx_write32(bcm, BCM43xx_CIR_SBTMSTATELOW, flags);
+		bcm43xx_write32(bcm, SSB_TMSLOW, flags);
 	}
 out:
 	phy->connected = connect;
@@ -565,7 +565,7 @@
 		bcm43xx_phy_setupa(bcm);
 	} else {
 		bcm43xx_phy_setupg(bcm);
-		if (bcm->sprom.boardflags & BCM43xx_BFL_PACTRL)
+		if (bcm->sprom.r1.boardflags_lo & BCM43xx_BFL_PACTRL)
 			bcm43xx_phy_write(bcm, 0x046E, 0x03CF);
 		return;
 	}
@@ -715,7 +715,7 @@
 	if (radio->version == 0x2050)
 		bcm43xx_phy_write(bcm, 0x002A, 0x88C2);
 	bcm43xx_radio_set_txpower_bg(bcm, 0xFFFF, 0xFFFF, 0xFFFF);
-	if (bcm->sprom.boardflags & BCM43xx_BFL_RSSI) {
+	if (bcm->sprom.r1.boardflags_lo & BCM43xx_BFL_RSSI) {
 		bcm43xx_calc_nrssi_slope(bcm);
 		bcm43xx_calc_nrssi_threshold(bcm);
 	}
@@ -895,7 +895,7 @@
 		bcm43xx_radio_write16(bcm, 0x005A, 0x0088);
 		bcm43xx_radio_write16(bcm, 0x005B, 0x006B);
 		bcm43xx_radio_write16(bcm, 0x005C, 0x000F);
-		if (bcm->sprom.boardflags & 0x8000) {
+		if (bcm->sprom.r1.boardflags_lo & 0x8000) {
 			bcm43xx_radio_write16(bcm, 0x005D, 0x00FA);
 			bcm43xx_radio_write16(bcm, 0x005E, 0x00D8);
 		} else {
@@ -985,7 +985,7 @@
 		bcm43xx_phy_write(bcm, 0x0062, 0x0007);
 		(void) bcm43xx_radio_calibrationvalue(bcm);
 		bcm43xx_phy_lo_b_measure(bcm);
-		if (bcm->sprom.boardflags & BCM43xx_BFL_RSSI) {
+		if (bcm->sprom.r1.boardflags_lo & BCM43xx_BFL_RSSI) {
 			bcm43xx_calc_nrssi_slope(bcm);
 			bcm43xx_calc_nrssi_threshold(bcm);
 		}
@@ -1105,7 +1105,7 @@
 			  bcm43xx_phy_read(bcm, 0x0811) | 0x0100);
 	bcm43xx_phy_write(bcm, 0x0812,
 			  bcm43xx_phy_read(bcm, 0x0812) & 0xCFFF);
-	if (bcm->sprom.boardflags & BCM43xx_BFL_EXTLNA) {
+	if (bcm->sprom.r1.boardflags_lo & BCM43xx_BFL_EXTLNA) {
 		if (phy->rev >= 7) {
 			bcm43xx_phy_write(bcm, 0x0811,
 					  bcm43xx_phy_read(bcm, 0x0811)
@@ -1252,7 +1252,7 @@
 					   & 0xF000) | (FIXME << 12));
 			*/
 		}
-		if (bcm->sprom.boardflags & BCM43xx_BFL_PACTRL)
+		if (bcm->sprom.r1.boardflags_lo & BCM43xx_BFL_PACTRL)
 			bcm43xx_phy_write(bcm, 0x002E, 0x8075);
 		else
 			bcm43xx_phy_write(bcm, 0x003E, 0x807F);
@@ -1266,7 +1266,7 @@
 		bcm43xx_phy_write(bcm, 0x080F, 0x8078);
 	}
 
-	if (!(bcm->sprom.boardflags & BCM43xx_BFL_RSSI)) {
+	if (!(bcm->sprom.r1.boardflags_lo & BCM43xx_BFL_RSSI)) {
 		/* The specs state to update the NRSSI LT with
 		 * the value 0x7FFFFFFF here. I think that is some weird
 		 * compiler optimization in the original driver.
@@ -1287,7 +1287,7 @@
 	if (radio->revision == 8)
 		bcm43xx_phy_write(bcm, 0x0805, 0x3230);
 	bcm43xx_phy_init_pctl(bcm);
-	if (bcm->chip_id == 0x4306 && bcm->chip_package == 2) {
+	if (bcm->ssb.chip_id == 0x4306 && bcm->ssb.chip_package == 2) {
 		bcm43xx_phy_write(bcm, 0x0429,
 				  bcm43xx_phy_read(bcm, 0x0429) & 0xBFFF);
 		bcm43xx_phy_write(bcm, 0x04C3,
@@ -1985,9 +1985,9 @@
 
 		estimated_pwr = bcm43xx_phy_estimate_power_out(bcm, average);
 
-		max_pwr = bcm->sprom.maxpower_bgphy;
+		max_pwr = bcm->sprom.r1.maxpwr_bg;
 
-		if ((bcm->sprom.boardflags & BCM43xx_BFL_PACTRL) &&
+		if ((bcm->sprom.r1.boardflags_lo & BCM43xx_BFL_PACTRL) &&
 		    (phy->type == BCM43xx_PHYTYPE_G))
 			max_pwr -= 0x3;
 
@@ -2043,7 +2043,7 @@
 					txpower = 3;
 					radio_attenuation += 2;
 					baseband_attenuation += 2;
-				} else if (bcm->sprom.boardflags & BCM43xx_BFL_PACTRL) {
+				} else if (bcm->sprom.r1.boardflags_lo & BCM43xx_BFL_PACTRL) {
 					baseband_attenuation += 4 * (radio_attenuation - 2);
 					radio_attenuation = 2;
 				}
@@ -2116,16 +2116,16 @@
 	s8 *dyn_tssi2dbm;
 	
 	if (phy->type == BCM43xx_PHYTYPE_A) {
-		pab0 = (s16)(bcm->sprom.pa1b0);
-		pab1 = (s16)(bcm->sprom.pa1b1);
-		pab2 = (s16)(bcm->sprom.pa1b2);
+		pab0 = (s16)(bcm->sprom.r1.pa1b0);
+		pab1 = (s16)(bcm->sprom.r1.pa1b1);
+		pab2 = (s16)(bcm->sprom.r1.pa1b2);
 	} else {
-		pab0 = (s16)(bcm->sprom.pa0b0);
-		pab1 = (s16)(bcm->sprom.pa0b1);
-		pab2 = (s16)(bcm->sprom.pa0b2);
+		pab0 = (s16)(bcm->sprom.r1.pa0b0);
+		pab1 = (s16)(bcm->sprom.r1.pa0b1);
+		pab2 = (s16)(bcm->sprom.r1.pa0b2);
 	}
 
-	if ((bcm->chip_id == 0x4301) && (radio->version != 0x2050)) {
+	if ((bcm->ssb.chip_id == 0x4301) && (radio->version != 0x2050)) {
 		phy->idle_tssi = 0x34;
 		phy->tssi2dbm = bcm43xx_tssi2dbm_b_table;
 		return 0;
@@ -2135,15 +2135,15 @@
 	    pab0 != -1 && pab1 != -1 && pab2 != -1) {
 		/* The pabX values are set in SPROM. Use them. */
 		if (phy->type == BCM43xx_PHYTYPE_A) {
-			if ((s8)bcm->sprom.idle_tssi_tgt_aphy != 0 &&
-			    (s8)bcm->sprom.idle_tssi_tgt_aphy != -1)
-				phy->idle_tssi = (s8)(bcm->sprom.idle_tssi_tgt_aphy);
+			if ((s8)bcm->sprom.r1.itssi_a != 0 &&
+			    (s8)bcm->sprom.r1.itssi_a != -1)
+				phy->idle_tssi = (s8)(bcm->sprom.r1.itssi_a);
 			else
 				phy->idle_tssi = 62;
 		} else {
-			if ((s8)bcm->sprom.idle_tssi_tgt_bgphy != 0 &&
-			    (s8)bcm->sprom.idle_tssi_tgt_bgphy != -1)
-				phy->idle_tssi = (s8)(bcm->sprom.idle_tssi_tgt_bgphy);
+			if ((s8)bcm->sprom.r1.itssi_bg != 0 &&
+			    (s8)bcm->sprom.r1.itssi_bg != -1)
+				phy->idle_tssi = (s8)(bcm->sprom.r1.itssi_bg);
 			else
 				phy->idle_tssi = 62;
 		}
@@ -2329,7 +2329,7 @@
 		}
 		break;
 	case BCM43xx_PHYTYPE_B:
-		if (bcm->current_core->rev == 2)
+		if (bcm->ssb.current_core->rev == 2)
 			value = (3/*automatic*/ << 7);
 		else
 			value = (antennadiv << 7);
Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.c	2006-08-23 10:47:32.000000000 +0200
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.c	2006-08-23 10:58:41.000000000 +0200
@@ -315,7 +315,7 @@
 
 	queue->bcm = bcm;
 	queue->mmio_base = pio_mmio_base;
-	queue->need_workarounds = (bcm->current_core->rev < 3);
+	queue->need_workarounds = (bcm->ssb.current_core->rev < 3);
 
 	INIT_LIST_HEAD(&queue->txfree);
 	INIT_LIST_HEAD(&queue->txqueue);
@@ -419,7 +419,7 @@
 		goto err_destroy2;
 	pio->queue3 = queue;
 
-	if (bcm->current_core->rev < 3)
+	if (bcm->ssb.current_core->rev < 3)
 		bcm->irq_savedstate |= BCM43xx_IRQ_PIO_WORKAROUND;
 
 	dprintk(KERN_INFO PFX "PIO initialized\n");
Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_power.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_power.c	2006-08-23 10:47:32.000000000 +0200
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_power.c	2006-08-23 10:58:41.000000000 +0200
@@ -41,8 +41,8 @@
 	u32 tmp;
 	int err;
 
-	assert(bcm->current_core == &bcm->core_chipcommon);
-	if (bcm->current_core->rev < 6) {
+	assert(bcm->ssb.current_core == bcm->core_chipcommon);
+	if (bcm->ssb.current_core->rev < 6) {
 		if (bcm->bustype == BCM43xx_BUSTYPE_PCMCIA ||
 		    bcm->bustype == BCM43xx_BUSTYPE_SB)
 			return BCM43xx_PCTL_CLKSRC_XTALOS;
@@ -54,8 +54,8 @@
 			return BCM43xx_PCTL_CLKSRC_XTALOS;
 		}
 	}
-	if (bcm->current_core->rev < 10) {
-		tmp = bcm43xx_read32(bcm, BCM43xx_CHIPCOMMON_SLOWCLKCTL);
+	if (bcm->ssb.current_core->rev < 10) {
+		tmp = bcm43xx_read32(bcm, SSB_CHIPCOMMON_SLOWCLKCTL);
 		tmp &= 0x7;
 		if (tmp == 0)
 			return BCM43xx_PCTL_CLKSRC_LOPWROS;
@@ -79,11 +79,11 @@
 	int divisor;
 	u32 tmp;
 
-	assert(bcm->chipcommon_capabilities & BCM43xx_CAPABILITIES_PCTL);
-	assert(bcm->current_core == &bcm->core_chipcommon);
+	assert(bcm->ssb.chipcommon_capabilities & SSB_CHIPCOMMON_CAP_PCTL);
+	assert(bcm->ssb.current_core == bcm->core_chipcommon);
 
 	clocksrc = bcm43xx_pctl_get_slowclksrc(bcm);
-	if (bcm->current_core->rev < 6) {
+	if (bcm->ssb.current_core->rev < 6) {
 		switch (clocksrc) {
 		case BCM43xx_PCTL_CLKSRC_PCI:
 			divisor = 64;
@@ -95,14 +95,14 @@
 			assert(0);
 			divisor = 1;
 		}
-	} else if (bcm->current_core->rev < 10) {
+	} else if (bcm->ssb.current_core->rev < 10) {
 		switch (clocksrc) {
 		case BCM43xx_PCTL_CLKSRC_LOPWROS:
 			divisor = 1;
 			break;
 		case BCM43xx_PCTL_CLKSRC_XTALOS:
 		case BCM43xx_PCTL_CLKSRC_PCI:
-			tmp = bcm43xx_read32(bcm, BCM43xx_CHIPCOMMON_SLOWCLKCTL);
+			tmp = bcm43xx_read32(bcm, SSB_CHIPCOMMON_SLOWCLKCTL);
 			divisor = ((tmp & 0xFFFF0000) >> 16) + 1;
 			divisor *= 4;
 			break;
@@ -111,7 +111,7 @@
 			divisor = 1;
 		}
 	} else {
-		tmp = bcm43xx_read32(bcm, BCM43xx_CHIPCOMMON_SYSCLKCTL);
+		tmp = bcm43xx_read32(bcm, SSB_CHIPCOMMON_SYSCLKCTL);
 		divisor = ((tmp & 0xFFFF0000) >> 16) + 1;
 		divisor *= 4;
 	}
@@ -151,24 +151,25 @@
 int bcm43xx_pctl_init(struct bcm43xx_private *bcm)
 {
 	int err, maxfreq;
-	struct bcm43xx_coreinfo *old_core;
+	struct ssb_core *old_core;
 
-	if (!(bcm->chipcommon_capabilities & BCM43xx_CAPABILITIES_PCTL))
+	if (!(bcm->ssb.chipcommon_capabilities & SSB_CHIPCOMMON_CAP_PCTL))
 		return 0;
-	old_core = bcm->current_core;
-	err = bcm43xx_switch_core(bcm, &bcm->core_chipcommon);
-	if (err == -ENODEV)
+	if (!bcm->core_chipcommon)
 		return 0;
+
+	old_core = bcm->ssb.current_core;
+	err = ssb_switch_core(&bcm->ssb, bcm->core_chipcommon);
 	if (err)
 		goto out;
 
 	maxfreq = bcm43xx_pctl_clockfreqlimit(bcm, 1);
-	bcm43xx_write32(bcm, BCM43xx_CHIPCOMMON_PLLONDELAY,
+	bcm43xx_write32(bcm, SSB_CHIPCOMMON_PLLONDELAY,
 			(maxfreq * 150 + 999999) / 1000000);
-	bcm43xx_write32(bcm, BCM43xx_CHIPCOMMON_FREFSELDELAY,
+	bcm43xx_write32(bcm, SSB_CHIPCOMMON_FREFSELDELAY,
 			(maxfreq * 15 + 999999) / 1000000);
 
-	err = bcm43xx_switch_core(bcm, old_core);
+	err = ssb_switch_core(&bcm->ssb, old_core);
 	assert(err == 0);
 
 out:
@@ -180,23 +181,26 @@
 	u16 delay = 0;
 	int err;
 	u32 pll_on_delay;
-	struct bcm43xx_coreinfo *old_core;
+	struct ssb_core *old_core;
 	int minfreq;
 
 	if (bcm->bustype != BCM43xx_BUSTYPE_PCI)
 		goto out;
-	if (!(bcm->chipcommon_capabilities & BCM43xx_CAPABILITIES_PCTL))
+	if (!(bcm->ssb.chipcommon_capabilities & SSB_CHIPCOMMON_CAP_PCTL))
 		goto out;
-	old_core = bcm->current_core;
-	err = bcm43xx_switch_core(bcm, &bcm->core_chipcommon);
-	if (err == -ENODEV)
+	if (!bcm->core_chipcommon)
+		goto out;
+
+	old_core = bcm->ssb.current_core;
+	err = ssb_switch_core(&bcm->ssb, bcm->core_chipcommon);
+	if (err)
 		goto out;
 
 	minfreq = bcm43xx_pctl_clockfreqlimit(bcm, 0);
-	pll_on_delay = bcm43xx_read32(bcm, BCM43xx_CHIPCOMMON_PLLONDELAY);
+	pll_on_delay = bcm43xx_read32(bcm, SSB_CHIPCOMMON_PLLONDELAY);
 	delay = (((pll_on_delay + 2) * 1000000) + (minfreq - 1)) / minfreq;
 
-	err = bcm43xx_switch_core(bcm, old_core);
+	err = ssb_switch_core(&bcm->ssb, old_core);
 	assert(err == 0);
 
 out:
@@ -209,47 +213,48 @@
 int bcm43xx_pctl_set_clock(struct bcm43xx_private *bcm, u16 mode)
 {
 	int err;
-	struct bcm43xx_coreinfo *old_core;
+	struct ssb_core *old_core;
 	u32 tmp;
 
-	old_core = bcm->current_core;
-	err = bcm43xx_switch_core(bcm, &bcm->core_chipcommon);
-	if (err == -ENODEV)
+	if (!bcm->core_chipcommon)
 		return 0;
+
+	old_core = bcm->ssb.current_core;
+	err = ssb_switch_core(&bcm->ssb, bcm->core_chipcommon);
 	if (err)
 		goto out;
-	
-	if (bcm->core_chipcommon.rev < 6) {
+
+	if (bcm->core_chipcommon->rev < 6) {
 		if (mode == BCM43xx_PCTL_CLK_FAST) {
 			err = bcm43xx_pctl_set_crystal(bcm, 1);
 			if (err)
 				goto out;
 		}
 	} else {
-		if ((bcm->chipcommon_capabilities & BCM43xx_CAPABILITIES_PCTL) &&
-			(bcm->core_chipcommon.rev < 10)) {
+		if ((bcm->ssb.chipcommon_capabilities & SSB_CHIPCOMMON_CAP_PCTL) &&
+		    (bcm->core_chipcommon->rev < 10)) {
 			switch (mode) {
 			case BCM43xx_PCTL_CLK_FAST:
-				tmp = bcm43xx_read32(bcm, BCM43xx_CHIPCOMMON_SLOWCLKCTL);
+				tmp = bcm43xx_read32(bcm, SSB_CHIPCOMMON_SLOWCLKCTL);
 				tmp = (tmp & ~BCM43xx_PCTL_FORCE_SLOW) | BCM43xx_PCTL_FORCE_PLL;
-				bcm43xx_write32(bcm, BCM43xx_CHIPCOMMON_SLOWCLKCTL, tmp);
+				bcm43xx_write32(bcm, SSB_CHIPCOMMON_SLOWCLKCTL, tmp);
 				break;
 			case BCM43xx_PCTL_CLK_SLOW:
-				tmp = bcm43xx_read32(bcm, BCM43xx_CHIPCOMMON_SLOWCLKCTL);
+				tmp = bcm43xx_read32(bcm, SSB_CHIPCOMMON_SLOWCLKCTL);
 				tmp |= BCM43xx_PCTL_FORCE_SLOW;
-				bcm43xx_write32(bcm, BCM43xx_CHIPCOMMON_SLOWCLKCTL, tmp);
+				bcm43xx_write32(bcm, SSB_CHIPCOMMON_SLOWCLKCTL, tmp);
 				break;
 			case BCM43xx_PCTL_CLK_DYNAMIC:
-				tmp = bcm43xx_read32(bcm, BCM43xx_CHIPCOMMON_SLOWCLKCTL);
+				tmp = bcm43xx_read32(bcm, SSB_CHIPCOMMON_SLOWCLKCTL);
 				tmp &= ~BCM43xx_PCTL_FORCE_SLOW;
 				tmp |= BCM43xx_PCTL_FORCE_PLL;
 				tmp &= ~BCM43xx_PCTL_DYN_XTAL;
-				bcm43xx_write32(bcm, BCM43xx_CHIPCOMMON_SLOWCLKCTL, tmp);
+				bcm43xx_write32(bcm, SSB_CHIPCOMMON_SLOWCLKCTL, tmp);
 			}
 		}
 	}
 	
-	err = bcm43xx_switch_core(bcm, old_core);
+	err = ssb_switch_core(&bcm->ssb, old_core);
 	assert(err == 0);
 
 out:
@@ -261,6 +266,8 @@
 	int err;
 	u32 in, out, outenable;
 
+	might_sleep();
+
 	err = bcm43xx_pci_read_config32(bcm, BCM43xx_PCTL_IN, &in);
 	if (err)
 		goto err_pci;
@@ -285,33 +292,34 @@
 		err = bcm43xx_pci_write_config32(bcm, BCM43xx_PCTL_OUTENABLE, outenable);
 		if (err)
 			goto err_pci;
-		udelay(1000);
+		msleep(1);
 
 		out &= ~BCM43xx_PCTL_PLL_POWERDOWN;
 		err = bcm43xx_pci_write_config32(bcm, BCM43xx_PCTL_OUT, out);
 		if (err)
 			goto err_pci;
-		udelay(5000);
+		msleep(5);
 	} else {
-		if (bcm->current_core->rev < 5)
+		if (!bcm->ssb.current_core)
+			return 0;
+		if (bcm->ssb.current_core->rev < 5)
 			return 0;
-		if (bcm->sprom.boardflags & BCM43xx_BFL_XTAL_NOSLOW)
+		if (bcm->sprom.r1.boardflags_lo & BCM43xx_BFL_XTAL_NOSLOW)
 			return 0;
 
 /*		XXX: Why BCM43xx_MMIO_RADIO_HWENABLED_xx can't be read at this time?
  *		err = bcm43xx_switch_core(bcm, bcm->active_80211_core);
  *		if (err)
  *			return err;
- *		if (((bcm->current_core->rev >= 3) &&
+ *		if (((bcm->ssb.current_core->rev >= 3) &&
  *			(bcm43xx_read32(bcm, BCM43xx_MMIO_RADIO_HWENABLED_HI) & (1 << 16))) ||
- *		      ((bcm->current_core->rev < 3) &&
+ *		      ((bcm->ssb.current_core->rev < 3) &&
  *			!(bcm43xx_read16(bcm, BCM43xx_MMIO_RADIO_HWENABLED_LO) & (1 << 4))))
  *			return 0;
  *		err = bcm43xx_switch_core(bcm, &bcm->core_chipcommon);
  *		if (err)
  *			return err;
  */
-		
 		err = bcm43xx_pctl_set_clock(bcm, BCM43xx_PCTL_CLK_SLOW);
 		if (err)
 			goto out;
@@ -369,7 +377,7 @@
 	else
 		status &= ~BCM43xx_SBF_PS2;
 	bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS_BITFIELD, status);
-	if (bit26 && bcm->current_core->rev >= 5) {
+	if (bit26 && bcm->ssb.current_core->rev >= 5) {
 		for (i = 0; i < 100; i++) {
 			if (bcm43xx_shm_read32(bcm, BCM43xx_SHM_SHARED, 0x0040) != 4)
 				break;
Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_radio.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_radio.c	2006-08-23 10:47:32.000000000 +0200
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_radio.c	2006-08-23 10:58:41.000000000 +0200
@@ -791,7 +791,7 @@
 	case BCM43xx_PHYTYPE_B: {
 		if (radio->version != 0x2050)
 			return;
-		if (!(bcm->sprom.boardflags & BCM43xx_BFL_RSSI))
+		if (!(bcm->sprom.r1.boardflags_lo & BCM43xx_BFL_RSSI))
 			return;
 
 		if (radio->revision >= 6) {
@@ -819,7 +819,7 @@
 	}
 	case BCM43xx_PHYTYPE_G:
 		if (!phy->connected ||
-		    !(bcm->sprom.boardflags & BCM43xx_BFL_RSSI)) {
+		    !(bcm->sprom.r1.boardflags_lo & BCM43xx_BFL_RSSI)) {
 			tmp16 = bcm43xx_nrssi_hw_read(bcm, 0x20);
 			if (tmp16 >= 0x20)
 				tmp16 -= 0x40;
@@ -1661,7 +1661,7 @@
 				channel2freq_bg(channel));
 
 		if (channel == 14) {
-			if (bcm->sprom.locale == BCM43xx_LOCALE_JAPAN) {
+			if (bcm->sprom.r1.country_code == SSB_SPROM1CCODE_JAPAN) {
 				bcm43xx_shm_write32(bcm, BCM43xx_SHM_SHARED,
 						    BCM43xx_UCODEFLAGS_OFFSET,
 						    bcm43xx_shm_read32(bcm, BCM43xx_SHM_SHARED,
@@ -1900,7 +1900,7 @@
 				else if (bcm->board_vendor == PCI_VENDOR_ID_BROADCOM &&
 					 bcm->board_type == 0x416)
 					att = 5;
-				else if (bcm->chip_id == 0x4320)
+				else if (bcm->ssb.chip_id == 0x4320)
 					att = 4;
 				else
 					att = 3;
@@ -1997,7 +1997,7 @@
 		bcm43xx_phy_write(bcm, 0x0010, bcm43xx_phy_read(bcm, 0x0010) | 0x0008);
 		bcm43xx_phy_write(bcm, 0x0011, bcm43xx_phy_read(bcm, 0x0011) | 0x0008);
 	}
-	if (phy->type == BCM43xx_PHYTYPE_G && bcm->current_core->rev >= 5) {
+	if (phy->type == BCM43xx_PHYTYPE_G && bcm->ssb.current_core->rev >= 5) {
 		bcm43xx_phy_write(bcm, 0x0811, bcm43xx_phy_read(bcm, 0x0811) | 0x008C);
 		bcm43xx_phy_write(bcm, 0x0812, bcm43xx_phy_read(bcm, 0x0812) & 0xFF73);
 	} else
Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/Kconfig
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/Kconfig	2006-08-23 10:47:32.000000000 +0200
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/Kconfig	2006-08-23 10:58:41.000000000 +0200
@@ -2,6 +2,7 @@
 	tristate "Broadcom BCM43xx wireless support (DeviceScape stack)"
 	depends on PCI && D80211 && NET_RADIO && EXPERIMENTAL
 	select FW_LOADER
+	select SONICS_SILICON_BACKPLANE
 	---help---
 	  This is an experimental driver for the Broadcom 43xx wireless chip,
 	  found in the Apple Airport Extreme and various other devices.
Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_debugfs.h
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_debugfs.h	2006-08-23 10:47:32.000000000 +0200
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_debugfs.h	2006-08-23 10:58:41.000000000 +0200
@@ -17,7 +17,6 @@
 struct bcm43xx_dfsentry {
 	struct dentry *subdir;
 	struct dentry *dentry_devinfo;
-	struct dentry *dentry_spromdump;
 	struct dentry *dentry_tsf;
 	struct dentry *dentry_txstat;
 	struct dentry *dentry_restart;
Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_leds.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_leds.c	2006-08-23 10:47:32.000000000 +0200
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_leds.c	2006-08-23 10:58:41.000000000 +0200
@@ -133,10 +133,10 @@
 	u8 sprom[4];
 	int i;
 
-	sprom[0] = bcm->sprom.wl0gpio0;
-	sprom[1] = bcm->sprom.wl0gpio1;
-	sprom[2] = bcm->sprom.wl0gpio2;
-	sprom[3] = bcm->sprom.wl0gpio3;
+	sprom[0] = bcm->sprom.r1.gpio0;
+	sprom[1] = bcm->sprom.r1.gpio1;
+	sprom[2] = bcm->sprom.r1.gpio2;
+	sprom[3] = bcm->sprom.r1.gpio3;
 
 	for (i = 0; i < BCM43xx_NR_LEDS; i++) {
 		led = &(bcm->leds[i]);
Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_sysfs.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_sysfs.c	2006-08-23 10:47:32.000000000 +0200
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_sysfs.c	2006-08-23 10:58:41.000000000 +0200
@@ -71,106 +71,6 @@
 	return -EINVAL;
 }
 
-static int sprom2hex(const u16 *sprom, char *buf, size_t buf_len)
-{
-	int i, pos = 0;
-
-	for (i = 0; i < BCM43xx_SPROM_SIZE; i++) {
-		pos += snprintf(buf + pos, buf_len - pos - 1,
-				"%04X", swab16(sprom[i]) & 0xFFFF);
-	}
-	pos += snprintf(buf + pos, buf_len - pos - 1, "\n");
-
-	return pos + 1;
-}
-
-static int hex2sprom(u16 *sprom, const char *dump, size_t len)
-{
-	char tmp[5] = { 0 };
-	int cnt = 0;
-	unsigned long parsed;
-
-	if (len < BCM43xx_SPROM_SIZE * sizeof(u16) * 2)
-		return -EINVAL;
-
-	while (cnt < BCM43xx_SPROM_SIZE) {
-		memcpy(tmp, dump, 4);
-		dump += 4;
-		parsed = simple_strtoul(tmp, NULL, 16);
-		sprom[cnt++] = swab16((u16)parsed);
-	}
-
-	return 0;
-}
-
-static ssize_t bcm43xx_attr_sprom_show(struct device *dev,
-				       struct device_attribute *attr,
-				       char *buf)
-{
-	struct bcm43xx_private *bcm = dev_to_bcm(dev);
-	u16 *sprom;
-	unsigned long flags;
-	int err;
-
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
-	assert(BCM43xx_SPROM_SIZE * sizeof(u16) <= PAGE_SIZE);
-	sprom = kmalloc(BCM43xx_SPROM_SIZE * sizeof(*sprom),
-			GFP_KERNEL);
-	if (!sprom)
-		return -ENOMEM;
-	mutex_lock(&bcm->mutex);
-	spin_lock_irqsave(&bcm->irq_lock, flags);
-	err = bcm43xx_sprom_read(bcm, sprom);
-	if (!err)
-		err = sprom2hex(sprom, buf, PAGE_SIZE);
-	mmiowb();
-	spin_unlock_irqrestore(&bcm->irq_lock, flags);
-	mutex_unlock(&bcm->mutex);
-	kfree(sprom);
-
-	return err;
-}
-
-static ssize_t bcm43xx_attr_sprom_store(struct device *dev,
-					struct device_attribute *attr,
-					const char *buf, size_t count)
-{
-	struct bcm43xx_private *bcm = dev_to_bcm(dev);
-	u16 *sprom;
-	unsigned long flags;
-	int err;
-
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
-	sprom = kmalloc(BCM43xx_SPROM_SIZE * sizeof(*sprom),
-			GFP_KERNEL);
-	if (!sprom)
-		return -ENOMEM;
-	err = hex2sprom(sprom, buf, count);
-	if (err)
-		goto out_kfree;
-	mutex_lock(&bcm->mutex);
-	spin_lock_irqsave(&bcm->irq_lock, flags);
-	spin_lock(&bcm->leds_lock);
-	err = bcm43xx_sprom_write(bcm, sprom);
-	mmiowb();
-	spin_unlock(&bcm->leds_lock);
-	spin_unlock_irqrestore(&bcm->irq_lock, flags);
-	mutex_unlock(&bcm->mutex);
-out_kfree:
-	kfree(sprom);
-
-	return err ? err : count;
-
-}
-
-static DEVICE_ATTR(sprom, 0600,
-		   bcm43xx_attr_sprom_show,
-		   bcm43xx_attr_sprom_store);
-
 static ssize_t bcm43xx_attr_interfmode_show(struct device *dev,
 					    struct device_attribute *attr,
 					    char *buf)
@@ -311,17 +211,14 @@
 
 int bcm43xx_sysfs_register(struct bcm43xx_private *bcm)
 {
-	struct device *dev = &bcm->pci_dev->dev;
+	struct device *dev = &bcm->ssb.pci_dev->dev;
 	int err;
 
 	assert(bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED);
 
-	err = device_create_file(dev, &dev_attr_sprom);
-	if (err)
-		goto out;
 	err = device_create_file(dev, &dev_attr_interference);
 	if (err)
-		goto err_remove_sprom;
+		goto out;
 	err = device_create_file(dev, &dev_attr_shortpreamble);
 	if (err)
 		goto err_remove_interfmode;
@@ -330,16 +227,13 @@
 	return err;
 err_remove_interfmode:
 	device_remove_file(dev, &dev_attr_interference);
-err_remove_sprom:
-	device_remove_file(dev, &dev_attr_sprom);
 	goto out;
 }
 
 void bcm43xx_sysfs_unregister(struct bcm43xx_private *bcm)
 {
-	struct device *dev = &bcm->pci_dev->dev;
+	struct device *dev = &bcm->ssb.pci_dev->dev;
 
 	device_remove_file(dev, &dev_attr_shortpreamble);
 	device_remove_file(dev, &dev_attr_interference);
-	device_remove_file(dev, &dev_attr_sprom);
 }
Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c	2006-08-23 10:47:32.000000000 +0200
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c	2006-08-23 10:58:41.000000000 +0200
@@ -390,7 +390,7 @@
 			else
 				tmp -= 3;
 		} else {
-			if (bcm->sprom.boardflags & BCM43xx_BFL_RSSI) {
+			if (bcm->sprom.r1.boardflags_lo & BCM43xx_BFL_RSSI) {
 				if (in_rssi > 63)
 					in_rssi = 63;
 				tmp = radio->nrssi_lt[in_rssi];
Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_ethtool.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_ethtool.c	2006-08-23 10:47:32.000000000 +0200
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_ethtool.c	2006-08-23 10:58:41.000000000 +0200
@@ -42,7 +42,7 @@
 
 	strncpy(info->driver, KBUILD_MODNAME, sizeof(info->driver));
 	strncpy(info->version, UTS_RELEASE, sizeof(info->version));
-	strncpy(info->bus_info, pci_name(bcm->pci_dev), ETHTOOL_BUSINFO_LEN);
+	strncpy(info->bus_info, pci_name(bcm->ssb.pci_dev), ETHTOOL_BUSINFO_LEN);
 }
 
 struct ethtool_ops bcm43xx_ethtool_ops = {


-- 
Greetings Michael.
