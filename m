From: Michael Buesch <mb@bu3sch.de>
Subject: [patch RFC 2/3] bcm43xx-d80211: convert to ssb module
Date: Tue, 15 Aug 2006 00:17:27 +0200
Message-ID: <200608150017.28615.mb@bu3sch.de>
References: <200608150014.19661.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, zambrano@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:11241
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S965015AbWHNWXp
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 18:23:45 -0400
To: netdev@vger.kernel.org
In-Reply-To: <200608150014.19661.mb@bu3sch.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

More #defines in bcm43xx.h can be deleted and the corresponding
#defines in ssh.h can be used instead. But I leave this alone for now...

Signed-off-by: Michael Buesch <mb@bu3sch>

Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h	2006-08-14 22:05:06.000000000 +0200
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h	2006-08-14 23:19:39.000000000 +0200
@@ -11,6 +11,7 @@
 #include <asm/atomic.h>
 #include <asm/io.h>
 
+#include <linux/ssb.h>
 #include <linux/wireless.h>
 #include <net/d80211.h>
 #include <net/d80211_mgmt.h>
@@ -186,25 +187,7 @@
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
+// FIXME: deletes SSB duplicates.
 
 /* Core Information Registers */
 #define BCM43xx_CIR_BASE		0xf00
@@ -578,29 +561,9 @@
 
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
@@ -615,7 +578,7 @@
 
 /* Context information for a noise calculation (Link Quality). */
 struct bcm43xx_noise_calculation {
-	struct bcm43xx_coreinfo *core_at_start;
+	struct ssb_core *core_at_start;
 	u8 channel_at_start;
 	u8 calculation_running:1;
 	u8 nr_samples;
@@ -685,6 +648,8 @@
  */
 
 struct bcm43xx_private {
+	/* Pointer to the Sonics Silicon Backplane. */
+	struct ssb *ssb;
 	struct ieee80211_hw *ieee;
 	struct ieee80211_low_level_stats ieee_stats;
 
@@ -735,27 +700,19 @@
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
+	struct ssb_core *active_80211_core;//FIXME remove?
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
 	u32 dma_reason[4];
@@ -829,11 +786,11 @@
  * any of these functions.
  */
 static inline
-struct bcm43xx_coreinfo_80211 *
+struct bcm43xx_corepriv_80211 *
 bcm43xx_current_80211_priv(struct bcm43xx_private *bcm)
 {
-	assert(bcm->current_core->id == BCM43xx_COREID_80211);
-	return bcm->current_core->priv;
+	assert(bcm->ssb->current_core->cc == SSB_CC_80211);
+	return bcm->ssb->current_core->priv;
 }
 static inline
 struct bcm43xx_pio * bcm43xx_current_pio(struct bcm43xx_private *bcm)
@@ -894,25 +851,25 @@
 static inline
 u16 bcm43xx_read16(struct bcm43xx_private *bcm, u16 offset)
 {
-	return ioread16(bcm->mmio_addr + core_offset(bcm) + offset);
+	return ioread16(bcm->mmio_addr + ssb_core_offset(bcm->ssb) + offset);
 }
 
 static inline
 void bcm43xx_write16(struct bcm43xx_private *bcm, u16 offset, u16 value)
 {
-	iowrite16(value, bcm->mmio_addr + core_offset(bcm) + offset);
+	iowrite16(value, bcm->mmio_addr + ssb_core_offset(bcm->ssb) + offset);
 }
 
 static inline
 u32 bcm43xx_read32(struct bcm43xx_private *bcm, u16 offset)
 {
-	return ioread32(bcm->mmio_addr + core_offset(bcm) + offset);
+	return ioread32(bcm->mmio_addr + ssb_core_offset(bcm->ssb) + offset);
 }
 
 static inline
 void bcm43xx_write32(struct bcm43xx_private *bcm, u16 offset, u32 value)
 {
-	iowrite32(value, bcm->mmio_addr + core_offset(bcm) + offset);
+	iowrite32(value, bcm->mmio_addr + ssb_core_offset(bcm->ssb) + offset);
 }
 
 static inline
Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c	2006-08-14 22:05:06.000000000 +0200
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c	2006-08-14 23:20:59.000000000 +0200
@@ -341,7 +341,7 @@
 	 * We try to be atomic here, by restaring the read process,
 	 * if any of the high registers changed (overflew).
 	 */
-	if (bcm->current_core->rev >= 3) {
+	if (bcm->ssb->current_core->rev >= 3) {
 		u32 low, high, high2;
 
 		do {
@@ -406,7 +406,7 @@
 	 * First zero out the low register, so we have a full
 	 * register-overflow duration to complete the operation.
 	 */
-	if (bcm->current_core->rev >= 3) {
+	if (bcm->ssb->current_core->rev >= 3) {
 		u32 lo = (tsf & 0x00000000FFFFFFFFULL);
 		u32 hi = (tsf & 0xFFFFFFFF00000000ULL) >> 32;
 
@@ -1079,7 +1079,7 @@
 		return;
 
 	index -= 4;
-	if (bcm->current_core->rev >= 5) {
+	if (bcm->ssb->current_core->rev >= 5) {
 		bcm43xx_shm_write32(bcm,
 				    BCM43xx_SHM_HWMAC,
 				    index * 2,
@@ -1128,7 +1128,7 @@
 	unsigned int i,j, nr_keys = 54;
 	u16 offset;
 
-	if (bcm->current_core->rev < 5)
+	if (bcm->ssb->current_core->rev < 5)
 		nr_keys = 16;
 	assert(nr_keys <= ARRAY_SIZE(bcm->key));
 
@@ -1147,194 +1147,12 @@
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
+	if ((ssb_core_is_enabled(bcm->ssb)) &&
 	    !bcm43xx_using_pio(bcm)) {
 //FIXME: Do we _really_ want #ifndef CONFIG_BCM947XX here?
 #ifndef CONFIG_BCM947XX
@@ -1344,7 +1162,7 @@
 		bcm43xx_dmacontroller_tx_reset(bcm, BCM43xx_MMIO_DMA3_BASE);
 		bcm43xx_dmacontroller_tx_reset(bcm, BCM43xx_MMIO_DMA4_BASE);
 		bcm43xx_dmacontroller_rx_reset(bcm, BCM43xx_MMIO_DMA1_BASE);
-		if (bcm->current_core->rev < 5)
+		if (bcm->ssb->current_core->rev < 5)
 			bcm43xx_dmacontroller_rx_reset(bcm, BCM43xx_MMIO_DMA4_BASE);
 #endif
 	}
@@ -1356,7 +1174,7 @@
 		if (connect_phy)
 			flags |= 0x20000000;
 		bcm43xx_phy_connect(bcm, connect_phy);
-		bcm43xx_core_enable(bcm, flags);
+		ssb_core_enable(bcm->ssb, flags);
 		bcm43xx_write16(bcm, 0x03E6, 0x0000);
 		bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS_BITFIELD,
 				bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD)
@@ -1368,7 +1186,7 @@
 {
 	bcm43xx_radio_turn_off(bcm);
 	bcm43xx_write16(bcm, 0x03E6, 0x00F4);
-	bcm43xx_core_disable(bcm, 0);
+	ssb_core_disable(bcm->ssb, 0);
 }
 
 /* Mark the current 80211 core inactive. */
@@ -1431,7 +1249,7 @@
 	bcm43xx_shm_write16(bcm, BCM43xx_SHM_SHARED, 0x40A, 0x7F7F);
 	bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS2_BITFIELD,
 			bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS2_BITFIELD) | (1 << 4));
-	assert(bcm->noisecalc.core_at_start == bcm->current_core);
+	assert(bcm->noisecalc.core_at_start == bcm->ssb->current_core);
 	assert(bcm->noisecalc.channel_at_start == bcm43xx_current_radio(bcm)->channel);
 }
 
@@ -1441,7 +1259,7 @@
 
 	if (bcm->noisecalc.calculation_running)
 		return;
-	bcm->noisecalc.core_at_start = bcm->current_core;
+	bcm->noisecalc.core_at_start = bcm->ssb->current_core;
 	bcm->noisecalc.channel_at_start = bcm43xx_current_radio(bcm)->channel;
 	bcm->noisecalc.calculation_running = 1;
 	bcm->noisecalc.nr_samples = 0;
@@ -1460,7 +1278,7 @@
 	/* Bottom half of Link Quality calculation. */
 
 	assert(bcm->noisecalc.calculation_running);
-	if (bcm->noisecalc.core_at_start != bcm->current_core ||
+	if (bcm->noisecalc.core_at_start != bcm->ssb->current_core ||
 	    bcm->noisecalc.channel_at_start != radio->channel)
 		goto drop_calculation;
 	tmp = bcm43xx_shm_read16(bcm, BCM43xx_SHM_SHARED, 0x408);
@@ -1802,7 +1620,7 @@
 static void bcm43xx_set_beacon_int(struct bcm43xx_private *bcm, u16 beacon_int)
 {
 	bcm43xx_time_lock(bcm);
-	if (bcm->current_core->rev >= 3) {
+	if (bcm->ssb->current_core->rev >= 3) {
 		bcm43xx_write32(bcm, 0x188, (beacon_int << 16));
 	} else {
 		bcm43xx_write16(bcm, 0x606, (beacon_int >> 6));
@@ -1989,7 +1807,7 @@
 static void bcm43xx_interrupt_ack(struct bcm43xx_private *bcm, u32 reason)
 {
 	if (bcm43xx_using_pio(bcm) &&
-	    (bcm->current_core->rev < 3) &&
+	    (bcm->ssb->current_core->rev < 3) &&
 	    (!(reason & BCM43xx_IRQ_PIO_WORKAROUND))) {
 		/* Apply a PIO specific workaround to the dma_reasons */
 		pio_irq_workaround(bcm, BCM43xx_MMIO_PIO1_BASE, 0);
@@ -2023,7 +1841,7 @@
 	spin_lock(&bcm->irq_lock);
 
 	assert(bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED);
-	assert(bcm->current_core->id == BCM43xx_COREID_80211);
+	assert(bcm->ssb->current_core->cc == SSB_CC_80211);
 
 	reason = bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON);
 	if (reason == 0xffffffff) {
@@ -2076,7 +1894,7 @@
 static int bcm43xx_request_firmware(struct bcm43xx_private *bcm)
 {
 	struct bcm43xx_phyinfo *phy = bcm43xx_current_phy(bcm);
-	u8 rev = bcm->current_core->rev;
+	u8 rev = bcm->ssb->current_core->rev;
 	int err = 0;
 	int nr;
 	char buf[22 + sizeof(modparam_fwpostfix) - 1] = { 0 };
@@ -2308,22 +2126,26 @@
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
+		err = ssb_switch_core(bcm->ssb, bcm->core_chipcommon);
+		if (err)
+			goto out;
+	} else if (bcm->core_pci) {
+		err = ssb_switch_core(bcm->ssb, bcm->core_pci);
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
 
@@ -2332,7 +2154,7 @@
  */
 static int bcm43xx_gpio_init(struct bcm43xx_private *bcm)
 {
-	struct bcm43xx_coreinfo *old_core;
+	struct ssb_core *old_core;
 	int err;
 	u32 mask, set;
 
@@ -2364,16 +2186,16 @@
 		mask |= 0x0200;
 		set |= 0x0200;
 	}
-	if (bcm->current_core->rev >= 2)
+	if (bcm->ssb->current_core->rev >= 2)
 		mask  |= 0x0010; /* FIXME: This is redundant. */
 
-	old_core = bcm->current_core;
+	old_core = bcm->ssb->current_core;
 	err = switch_to_gpio_core(bcm);
 	if (err)
 		goto out;
 	bcm43xx_write32(bcm, BCM43xx_GPIO_CONTROL,
 	                (bcm43xx_read32(bcm, BCM43xx_GPIO_CONTROL) & mask) | set);
-	err = bcm43xx_switch_core(bcm, old_core);
+	err = ssb_switch_core(bcm->ssb, old_core);
 out:
 	return err;
 }
@@ -2381,15 +2203,15 @@
 /* Turn off all GPIO stuff. Call this on module unload, for example. */
 static int bcm43xx_gpio_cleanup(struct bcm43xx_private *bcm)
 {
-	struct bcm43xx_coreinfo *old_core;
+	struct ssb_core *old_core;
 	int err;
 
-	old_core = bcm->current_core;
+	old_core = bcm->ssb->current_core;
 	err = switch_to_gpio_core(bcm);
 	if (err)
 		return err;
 	bcm43xx_write32(bcm, BCM43xx_GPIO_CONTROL, 0x00000000);
-	err = bcm43xx_switch_core(bcm, old_core);
+	err = ssb_switch_core(bcm->ssb, old_core);
 	assert(err == 0);
 
 	return 0;
@@ -2601,7 +2423,7 @@
 		bcm43xx_write16(bcm, 0x005E, value16);
 	}
 	bcm43xx_write32(bcm, 0x0100, 0x01000000);
-	if (bcm->current_core->rev < 5)
+	if (bcm->ssb->current_core->rev < 5)
 		bcm43xx_write32(bcm, 0x010C, 0x01000000);
 
 	value32 = bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD);
@@ -2630,7 +2452,7 @@
 	/* Initially set the wireless operation mode. */
 	bcm43xx_select_opmode(bcm);
 
-	if (bcm->current_core->rev < 3) {
+	if (bcm->ssb->current_core->rev < 3) {
 		bcm43xx_write16(bcm, 0x060E, 0x0000);
 		bcm43xx_write16(bcm, 0x0610, 0x8000);
 		bcm43xx_write16(bcm, 0x0604, 0x0000);
@@ -2671,7 +2493,7 @@
 	bcm43xx_pio_free(bcm);
 	bcm43xx_dma_free(bcm);
 
-	bcm->current_core->initialized = 0;
+	bcm43xx_current_80211_priv(bcm)->initialized = 0;
 }
 
 /* http://bcm-specs.sipsolutions.net/80211Init */
@@ -2703,7 +2525,7 @@
 	if (err)
 		goto out;
 
-	bcm43xx_shm_write16(bcm, BCM43xx_SHM_SHARED, 0x0016, bcm->current_core->rev);
+	bcm43xx_shm_write16(bcm, BCM43xx_SHM_SHARED, 0x0016, bcm->ssb->current_core->rev);
 	ucodeflags = bcm43xx_shm_read32(bcm, BCM43xx_SHM_SHARED, BCM43xx_UCODEFLAGS_OFFSET);
 
 	if (0 /*FIXME: which condition has to be used here? */)
@@ -2754,7 +2576,7 @@
 
 	bcm43xx_write_mac_bssid_templates(bcm);
 
-	if (bcm->current_core->rev >= 5)
+	if (bcm->ssb->current_core->rev >= 5)
 		bcm43xx_write16(bcm, 0x043C, 0x000C);
 
 	if (active_wlcore) {
@@ -2777,7 +2599,7 @@
 	/* Don't enable MAC/IRQ here, as it will race with the IRQ handler.
 	 * We enable it later.
 	 */
-	bcm->current_core->initialized = 1;
+	bcm43xx_current_80211_priv(bcm)->initialized = 1;
 out:
 	return err;
 
@@ -2949,15 +2771,16 @@
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
+		err = ssb_switch_core(bcm->ssb, core);
 		if (err) {
 			dprintk(KERN_ERR PFX "shutdown_all_wireless_cores "
 					     "switch_core failed (%d)\n", err);
@@ -3041,162 +2864,74 @@
 
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
+	struct ssb *ssb = bcm->ssb;
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
+	switch (bcm->pci_dev->device) {
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
@@ -3205,49 +2940,46 @@
 				 */
 				if (bcm->pci_dev->device != 0x4324) {
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
@@ -3273,90 +3005,6 @@
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
@@ -3418,8 +3066,8 @@
 {
 	int err = -ENOMEM;
 	struct ieee80211_hw *ieee = bcm->ieee;
-	struct bcm43xx_coreinfo *core;
-	struct bcm43xx_coreinfo_80211 *wlext;
+	struct ssb_core *core;
+	struct bcm43xx_corepriv_80211 *wlpriv;
 	int i, nr_modes;
 
 	nr_modes = bcm->nr_80211_available;
@@ -3430,10 +3078,10 @@
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
@@ -3527,8 +3175,8 @@
 static void prepare_priv_for_init(struct bcm43xx_private *bcm)
 {
 	int i;
-	struct bcm43xx_coreinfo *core;
-	struct bcm43xx_coreinfo_80211 *wlext;
+	struct ssb_core *core;
+	struct bcm43xx_corepriv_80211 *wlpriv;
 
 	assert(!bcm->active_80211_core);
 
@@ -3542,16 +3190,13 @@
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
@@ -3573,7 +3218,7 @@
 {
 	int err;
 
-	if (!bcm43xx_core_enabled(bcm))
+	if (!ssb_core_is_enabled(bcm->ssb))
 		bcm43xx_wireless_core_reset(bcm, 1);
 	if (!active_wlcore)
 		bcm43xx_wireless_core_mark_inactive(bcm);
@@ -3594,27 +3239,27 @@
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
@@ -3651,12 +3296,12 @@
 
 	/* Mark all unused cores "inactive". */
 	for (i = 0; i < bcm->nr_80211_available; i++) {
-		core = &(bcm->core_80211[i]);
-		wlext = core->priv;
+		core = bcm->core_80211[i];
+		wlpriv = core->priv;
 
 		if (core == active_core)
 			continue;
-		err = bcm43xx_switch_core(bcm, core);
+		err = ssb_switch_core(bcm->ssb, core);
 		if (err) {
 			dprintk(KERN_ERR PFX "Could not switch to inactive "
 					     "802.11 core (%d)\n", err);
@@ -3672,14 +3317,14 @@
 	}
 
 	/* Now initialize the active 802.11 core. */
-	err = bcm43xx_switch_core(bcm, active_core);
+	err = ssb_switch_core(bcm->ssb, active_core);
 	if (err) {
 		dprintk(KERN_ERR PFX "Could not switch to active "
 				     "802.11 core (%d)\n", err);
 		goto error;
 	}
 	if (adjust_active_sbtmstatelow &&
-	    active_wlext->phy.type == BCM43xx_PHYTYPE_G) {
+	    active_wlpriv->phy.type == BCM43xx_PHYTYPE_G) {
 		u32 sbtmstatelow;
 
 		sbtmstatelow = bcm43xx_read32(bcm, BCM43xx_CIR_SBTMSTATELOW);
@@ -3716,7 +3361,7 @@
 	bcm43xx_interrupt_enable(bcm, bcm->irq_savedstate);
 
 	dprintk(KERN_INFO PFX "Selected 802.11 core (phytype %d)\n",
-		active_wlext->phy.type);
+		active_wlpriv->phy.type);
 
 	return 0;
 
@@ -3766,6 +3411,7 @@
 	int i;
 
 	bcm43xx_chipset_detach(bcm);
+	ssb_free(bcm->ssb);
 	/* Do _not_ access the chip, after it is detached. */
 	pci_iounmap(pci_dev, bcm->mmio_addr);
 	pci_release_regions(pci_dev);
@@ -3773,9 +3419,9 @@
 
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
@@ -3843,6 +3489,7 @@
 	int err;
 	int i;
 	u32 coremask;
+	struct ssb *ssb;
 
 	err = pci_enable_device(pci_dev);
 	if (err) {
@@ -3864,6 +3511,11 @@
 	}
 	net_dev->base_addr = (unsigned long)bcm->mmio_addr;
 
+	ssb = ssb_alloc(pci_dev, bcm->mmio_addr);
+	if (!ssb)
+		goto err_iounmap;
+	bcm->ssb = ssb;
+
 	bcm43xx_pci_read_config16(bcm, PCI_SUBSYSTEM_VENDOR_ID,
 	                          &bcm->board_vendor);
 	bcm43xx_pci_read_config16(bcm, PCI_SUBSYSTEM_ID,
@@ -3873,7 +3525,7 @@
 
 	err = bcm43xx_chipset_attach(bcm);
 	if (err)
-		goto err_iounmap;
+		goto err_free_ssb;
 	err = bcm43xx_pctl_init(bcm);
 	if (err)
 		goto err_chipset_detach;
@@ -3884,9 +3536,9 @@
 	/* Attach all IO cores to the backplane. */
 	coremask = 0;
 	for (i = 0; i < bcm->nr_80211_available; i++)
-		coremask |= (1 << bcm->core_80211[i].index);
+		coremask |= (1 << bcm->core_80211[i]->index);
 	//FIXME: Also attach some non80211 cores?
-	err = bcm43xx_setup_backplane_pci_connection(bcm, coremask);
+	err = ssb_cores_connect(bcm->ssb, coremask);
 	if (err) {
 		printk(KERN_ERR PFX "Backplane->PCI connection failed!\n");
 		goto err_chipset_detach;
@@ -3900,7 +3552,7 @@
 		goto err_chipset_detach;
 
 	for (i = 0; i < bcm->nr_80211_available; i++) {
-		err = bcm43xx_switch_core(bcm, &bcm->core_80211[i]);
+		err = ssb_switch_core(bcm->ssb, bcm->core_80211[i]);
 		assert(err != -ENODEV);
 		if (err)
 			goto err_80211_unwind;
@@ -3946,12 +3598,14 @@
 
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
+err_free_ssb:
+	ssb_free(ssb);
 err_iounmap:
 	pci_iounmap(pci_dev, bcm->mmio_addr);
 err_pci_release:
Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_debugfs.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_debugfs.c	2006-08-14 22:05:06.000000000 +0200
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_debugfs.c	2006-08-14 23:19:39.000000000 +0200
@@ -95,21 +95,21 @@
 	fappend("IRQ: %d\n", bcm->irq);
 	fappend("mmio_addr: 0x%p\n", bcm->mmio_addr);
 	fappend("chip_id: 0x%04x   chip_rev: 0x%02x\n", bcm->chip_id, bcm->chip_rev);
-	if ((bcm->core_80211[0].rev >= 3) && (bcm43xx_read32(bcm, 0x0158) & (1 << 16)))
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
Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c	2006-08-14 22:05:06.000000000 +0200
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c	2006-08-14 23:19:39.000000000 +0200
@@ -569,7 +569,7 @@
 		goto err_destroy_tx3;
 	dma->rx_ring0 = ring;
 
-	if (bcm->current_core->rev < 5) {
+	if (bcm->ssb->current_core->rev < 5) {
 		ring = bcm43xx_setup_dmaring(bcm, BCM43xx_MMIO_DMA4_BASE,
 					     BCM43xx_RXRING_SLOTS, 0);
 		if (!ring)
Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.h
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.h	2006-08-14 22:05:06.000000000 +0200
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.h	2006-08-14 23:19:39.000000000 +0200
@@ -128,8 +128,6 @@
 
 void bcm43xx_dummy_transmission(struct bcm43xx_private *bcm);
 
-int bcm43xx_switch_core(struct bcm43xx_private *bcm, struct bcm43xx_coreinfo *new_core);
-
 int bcm43xx_select_wireless_core(struct bcm43xx_private *bcm,
 				 int phytype);
 
Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c	2006-08-14 22:05:06.000000000 +0200
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c	2006-08-14 23:19:39.000000000 +0200
@@ -90,7 +90,7 @@
 		phy->is_locked = 0;
 		return;
 	}
-	if (bcm->current_core->rev < 3) {
+	if (bcm->ssb->current_core->rev < 3) {
 		bcm43xx_mac_suspend(bcm);
 		spin_lock(&phy->lock);
 	} else {
@@ -105,7 +105,7 @@
 	struct bcm43xx_phyinfo *phy = bcm43xx_current_phy(bcm);
 
 	assert(irqs_disabled());
-	if (bcm->current_core->rev < 3) {
+	if (bcm->ssb->current_core->rev < 3) {
 		if (phy->is_locked) {
 			spin_unlock(&phy->lock);
 			bcm43xx_mac_enable(bcm);
@@ -161,7 +161,7 @@
 	struct bcm43xx_phyinfo *phy = bcm43xx_current_phy(bcm);
 	u32 flags;
 
-	if (bcm->current_core->rev < 5)
+	if (bcm->ssb->current_core->rev < 5)
 		goto out;
 
 	flags = bcm43xx_read32(bcm, BCM43xx_CIR_SBTMSTATEHIGH);
@@ -2329,7 +2329,7 @@
 		}
 		break;
 	case BCM43xx_PHYTYPE_B:
-		if (bcm->current_core->rev == 2)
+		if (bcm->ssb->current_core->rev == 2)
 			value = (3/*automatic*/ << 7);
 		else
 			value = (antennadiv << 7);
Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.c	2006-08-14 22:05:06.000000000 +0200
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.c	2006-08-14 23:19:39.000000000 +0200
@@ -316,7 +316,7 @@
 
 	queue->bcm = bcm;
 	queue->mmio_base = pio_mmio_base;
-	queue->need_workarounds = (bcm->current_core->rev < 3);
+	queue->need_workarounds = (bcm->ssb->current_core->rev < 3);
 
 	INIT_LIST_HEAD(&queue->txfree);
 	INIT_LIST_HEAD(&queue->txqueue);
@@ -420,7 +420,7 @@
 		goto err_destroy2;
 	pio->queue3 = queue;
 
-	if (bcm->current_core->rev < 3)
+	if (bcm->ssb->current_core->rev < 3)
 		bcm->irq_savedstate |= BCM43xx_IRQ_PIO_WORKAROUND;
 
 	dprintk(KERN_INFO PFX "PIO initialized\n");
Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_power.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_power.c	2006-08-14 22:05:06.000000000 +0200
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_power.c	2006-08-14 23:19:39.000000000 +0200
@@ -41,8 +41,8 @@
 	u32 tmp;
 	int err;
 
-	assert(bcm->current_core == &bcm->core_chipcommon);
-	if (bcm->current_core->rev < 6) {
+	assert(bcm->ssb->current_core == bcm->core_chipcommon);
+	if (bcm->ssb->current_core->rev < 6) {
 		if (bcm->bustype == BCM43xx_BUSTYPE_PCMCIA ||
 		    bcm->bustype == BCM43xx_BUSTYPE_SB)
 			return BCM43xx_PCTL_CLKSRC_XTALOS;
@@ -54,7 +54,7 @@
 			return BCM43xx_PCTL_CLKSRC_XTALOS;
 		}
 	}
-	if (bcm->current_core->rev < 10) {
+	if (bcm->ssb->current_core->rev < 10) {
 		tmp = bcm43xx_read32(bcm, BCM43xx_CHIPCOMMON_SLOWCLKCTL);
 		tmp &= 0x7;
 		if (tmp == 0)
@@ -79,11 +79,11 @@
 	int divisor;
 	u32 tmp;
 
-	assert(bcm->chipcommon_capabilities & BCM43xx_CAPABILITIES_PCTL);
-	assert(bcm->current_core == &bcm->core_chipcommon);
+	assert(bcm->ssb->chipcommon_capabilities & BCM43xx_CAPABILITIES_PCTL);
+	assert(bcm->ssb->current_core == bcm->core_chipcommon);
 
 	clocksrc = bcm43xx_pctl_get_slowclksrc(bcm);
-	if (bcm->current_core->rev < 6) {
+	if (bcm->ssb->current_core->rev < 6) {
 		switch (clocksrc) {
 		case BCM43xx_PCTL_CLKSRC_PCI:
 			divisor = 64;
@@ -95,7 +95,7 @@
 			assert(0);
 			divisor = 1;
 		}
-	} else if (bcm->current_core->rev < 10) {
+	} else if (bcm->ssb->current_core->rev < 10) {
 		switch (clocksrc) {
 		case BCM43xx_PCTL_CLKSRC_LOPWROS:
 			divisor = 1;
@@ -151,14 +151,15 @@
 int bcm43xx_pctl_init(struct bcm43xx_private *bcm)
 {
 	int err, maxfreq;
-	struct bcm43xx_coreinfo *old_core;
+	struct ssb_core *old_core;
 
-	if (!(bcm->chipcommon_capabilities & BCM43xx_CAPABILITIES_PCTL))
+	if (!(bcm->ssb->chipcommon_capabilities & BCM43xx_CAPABILITIES_PCTL))
 		return 0;
-	old_core = bcm->current_core;
-	err = bcm43xx_switch_core(bcm, &bcm->core_chipcommon);
-	if (err == -ENODEV)
+	if (!bcm->core_chipcommon)
 		return 0;
+
+	old_core = bcm->ssb->current_core;
+	err = ssb_switch_core(bcm->ssb, bcm->core_chipcommon);
 	if (err)
 		goto out;
 
@@ -168,7 +169,7 @@
 	bcm43xx_write32(bcm, BCM43xx_CHIPCOMMON_FREFSELDELAY,
 			(maxfreq * 15 + 999999) / 1000000);
 
-	err = bcm43xx_switch_core(bcm, old_core);
+	err = ssb_switch_core(bcm->ssb, old_core);
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
+	if (!(bcm->ssb->chipcommon_capabilities & BCM43xx_CAPABILITIES_PCTL))
 		goto out;
-	old_core = bcm->current_core;
-	err = bcm43xx_switch_core(bcm, &bcm->core_chipcommon);
-	if (err == -ENODEV)
+	if (!bcm->core_chipcommon)
+		goto out;
+
+	old_core = bcm->ssb->current_core;
+	err = ssb_switch_core(bcm->ssb, bcm->core_chipcommon);
+	if (err)
 		goto out;
 
 	minfreq = bcm43xx_pctl_clockfreqlimit(bcm, 0);
 	pll_on_delay = bcm43xx_read32(bcm, BCM43xx_CHIPCOMMON_PLLONDELAY);
 	delay = (((pll_on_delay + 2) * 1000000) + (minfreq - 1)) / minfreq;
 
-	err = bcm43xx_switch_core(bcm, old_core);
+	err = ssb_switch_core(bcm->ssb, old_core);
 	assert(err == 0);
 
 out:
@@ -209,25 +213,26 @@
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
+	old_core = bcm->ssb->current_core;
+	err = ssb_switch_core(bcm->ssb, bcm->core_chipcommon);
 	if (err)
 		goto out;
 	
-	if (bcm->core_chipcommon.rev < 6) {
+	if (bcm->core_chipcommon->rev < 6) {
 		if (mode == BCM43xx_PCTL_CLK_FAST) {
 			err = bcm43xx_pctl_set_crystal(bcm, 1);
 			if (err)
 				goto out;
 		}
 	} else {
-		if ((bcm->chipcommon_capabilities & BCM43xx_CAPABILITIES_PCTL) &&
-			(bcm->core_chipcommon.rev < 10)) {
+		if ((bcm->ssb->chipcommon_capabilities & BCM43xx_CAPABILITIES_PCTL) &&
+		    (bcm->core_chipcommon->rev < 10)) {
 			switch (mode) {
 			case BCM43xx_PCTL_CLK_FAST:
 				tmp = bcm43xx_read32(bcm, BCM43xx_CHIPCOMMON_SLOWCLKCTL);
@@ -249,7 +254,7 @@
 		}
 	}
 	
-	err = bcm43xx_switch_core(bcm, old_core);
+	err = ssb_switch_core(bcm->ssb, old_core);
 	assert(err == 0);
 
 out:
@@ -293,7 +298,7 @@
 			goto err_pci;
 		udelay(5000);
 	} else {
-		if (bcm->current_core->rev < 5)
+		if (bcm->ssb->current_core->rev < 5)
 			return 0;
 		if (bcm->sprom.boardflags & BCM43xx_BFL_XTAL_NOSLOW)
 			return 0;
@@ -302,9 +307,9 @@
  *		err = bcm43xx_switch_core(bcm, bcm->active_80211_core);
  *		if (err)
  *			return err;
- *		if (((bcm->current_core->rev >= 3) &&
+ *		if (((bcm->ssb->current_core->rev >= 3) &&
  *			(bcm43xx_read32(bcm, BCM43xx_MMIO_RADIO_HWENABLED_HI) & (1 << 16))) ||
- *		      ((bcm->current_core->rev < 3) &&
+ *		      ((bcm->ssb->current_core->rev < 3) &&
  *			!(bcm43xx_read16(bcm, BCM43xx_MMIO_RADIO_HWENABLED_LO) & (1 << 4))))
  *			return 0;
  *		err = bcm43xx_switch_core(bcm, &bcm->core_chipcommon);
@@ -369,7 +374,7 @@
 	else
 		status &= ~BCM43xx_SBF_PS2;
 	bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS_BITFIELD, status);
-	if (bit26 && bcm->current_core->rev >= 5) {
+	if (bit26 && bcm->ssb->current_core->rev >= 5) {
 		for (i = 0; i < 100; i++) {
 			if (bcm43xx_shm_read32(bcm, BCM43xx_SHM_SHARED, 0x0040) != 4)
 				break;
Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_radio.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_radio.c	2006-08-14 22:05:06.000000000 +0200
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_radio.c	2006-08-14 23:19:39.000000000 +0200
@@ -1997,7 +1997,7 @@
 		bcm43xx_phy_write(bcm, 0x0010, bcm43xx_phy_read(bcm, 0x0010) | 0x0008);
 		bcm43xx_phy_write(bcm, 0x0011, bcm43xx_phy_read(bcm, 0x0011) | 0x0008);
 	}
-	if (phy->type == BCM43xx_PHYTYPE_G && bcm->current_core->rev >= 5) {
+	if (phy->type == BCM43xx_PHYTYPE_G && bcm->ssb->current_core->rev >= 5) {
 		bcm43xx_phy_write(bcm, 0x0811, bcm43xx_phy_read(bcm, 0x0811) | 0x008C);
 		bcm43xx_phy_write(bcm, 0x0812, bcm43xx_phy_read(bcm, 0x0812) & 0xFF73);
 	} else
Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/Kconfig
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/Kconfig	2006-08-14 22:05:06.000000000 +0200
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/Kconfig	2006-08-14 23:19:39.000000000 +0200
@@ -1,6 +1,6 @@
 config BCM43XX_D80211
 	tristate "Broadcom BCM43xx wireless support (DeviceScape stack)"
-	depends on PCI && D80211 && NET_RADIO && EXPERIMENTAL
+	depends on PCI && SONICS_SILICON_BACKPLANE && D80211 && NET_RADIO && EXPERIMENTAL
 	select FW_LOADER
 	---help---
 	  This is an experimental driver for the Broadcom 43xx wireless chip,

-- 
Greetings Michael.
