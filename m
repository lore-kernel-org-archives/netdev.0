From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] bcm43xx-d80211: init routine rewrite
Date: Mon, 10 Jul 2006 23:38:38 +0200
Message-ID: <200607102338.39969.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org,
	"Francois Barre" <francois.barre@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:50366
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S965253AbWGJVk0
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jul 2006 17:40:26 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi John,

Please apply this to wireless-dev.

--

Rewrite of the bcm43xx initialization routines.
This fixes several issues:
* up-down-up-down-up... stale data issue
  (May fix some DHCP issues)
* Fix the init vs IRQ handler race (and remove the workaround)
* Fix init for cards with multiple cores (APHY)
  The active PHY is selected through d80211.
* Fix the controller restart code.
  Controller restart can now also be triggered through
  echo 1 > /debug/bcm43xx/ethX/restart

Signed-off-by: Michael Buesch <mb@bu3sch.de>

Index: wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h
===================================================================
--- wireless-dev-dscapeports.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h	2006-07-10 00:41:15.000000000 +0200
+++ wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h	2006-07-10 00:54:11.000000000 +0200
@@ -493,6 +493,12 @@
 	 * This lock is only used by bcm43xx_phy_{un}lock()
 	 */
 	spinlock_t lock;
+
+	/* Firmware. */
+	const struct firmware *ucode;
+	const struct firmware *pcm;
+	const struct firmware *initvals0;
+	const struct firmware *initvals1;
 };
 
 
@@ -583,12 +589,14 @@
 	u8 available:1,
 	   enabled:1,
 	   initialized:1;
-	/** core_id ID number */
-	u16 id;
 	/** core_rev revision number */
 	u8 rev;
 	/** Index number for _switch_core() */
 	u8 index;
+	/** core_id ID number */
+	u16 id;
+	/** Core-specific data. */
+	void *priv;
 };
 
 /* Additional information for each 80211 core. */
@@ -658,7 +666,10 @@
 	BCM43xx_STAT_RESTARTING,	/* controller_restart() called. */
 };
 #define bcm43xx_status(bcm)		atomic_read(&(bcm)->init_status)
-#define bcm43xx_set_status(bcm, stat)	atomic_set(&(bcm)->init_status, (stat))
+#define bcm43xx_set_status(bcm, stat)	do {			\
+		atomic_set(&(bcm)->init_status, (stat));	\
+		smp_wmb();					\
+					} while (0)
 
 /*    *** THEORY OF LOCKING ***
  *
@@ -740,10 +751,6 @@
 	struct bcm43xx_coreinfo core_80211[ BCM43xx_MAX_80211_CORES ];
 	/* Additional information, specific to the 80211 cores. */
 	struct bcm43xx_coreinfo_80211 core_80211_ext[ BCM43xx_MAX_80211_CORES ];
-	/* Index of the current 80211 core. If current_core is not
-	 * an 80211 core, this is -1.
-	 */
-	int current_80211_core_idx;
 	/* Number of available 80211 cores. */
 	int nr_80211_available;
 
@@ -776,12 +783,6 @@
 	struct bcm43xx_key key[54];
 	u8 default_key_idx;
 
-	/* Firmware. */
-	const struct firmware *ucode;
-	const struct firmware *pcm;
-	const struct firmware *initvals0;
-	const struct firmware *initvals1;
-
 	/* Cached beacon template while uploading the template. */
 	struct sk_buff *cached_beacon;
 
@@ -828,34 +829,33 @@
  * any of these functions.
  */
 static inline
+struct bcm43xx_coreinfo_80211 *
+bcm43xx_current_80211_priv(struct bcm43xx_private *bcm)
+{
+	assert(bcm->current_core->id == BCM43xx_COREID_80211);
+	return bcm->current_core->priv;
+}
+static inline
 struct bcm43xx_pio * bcm43xx_current_pio(struct bcm43xx_private *bcm)
 {
 	assert(bcm43xx_using_pio(bcm));
-	assert(bcm->current_80211_core_idx >= 0);
-	assert(bcm->current_80211_core_idx < BCM43xx_MAX_80211_CORES);
-	return &(bcm->core_80211_ext[bcm->current_80211_core_idx].pio);
+	return &(bcm43xx_current_80211_priv(bcm)->pio);
 }
 static inline
 struct bcm43xx_dma * bcm43xx_current_dma(struct bcm43xx_private *bcm)
 {
 	assert(!bcm43xx_using_pio(bcm));
-	assert(bcm->current_80211_core_idx >= 0);
-	assert(bcm->current_80211_core_idx < BCM43xx_MAX_80211_CORES);
-	return &(bcm->core_80211_ext[bcm->current_80211_core_idx].dma);
+	return &(bcm43xx_current_80211_priv(bcm)->dma);
 }
 static inline
 struct bcm43xx_phyinfo * bcm43xx_current_phy(struct bcm43xx_private *bcm)
 {
-	assert(bcm->current_80211_core_idx >= 0);
-	assert(bcm->current_80211_core_idx < BCM43xx_MAX_80211_CORES);
-	return &(bcm->core_80211_ext[bcm->current_80211_core_idx].phy);
+	return &(bcm43xx_current_80211_priv(bcm)->phy);
 }
 static inline
 struct bcm43xx_radioinfo * bcm43xx_current_radio(struct bcm43xx_private *bcm)
 {
-	assert(bcm->current_80211_core_idx >= 0);
-	assert(bcm->current_80211_core_idx < BCM43xx_MAX_80211_CORES);
-	return &(bcm->core_80211_ext[bcm->current_80211_core_idx].radio);
+	return &(bcm43xx_current_80211_priv(bcm)->radio);
 }
 
 
Index: wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-dev-dscapeports.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c	2006-07-10 00:41:15.000000000 +0200
+++ wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c	2006-07-10 00:54:11.000000000 +0200
@@ -147,6 +147,73 @@
 MODULE_DEVICE_TABLE(pci, bcm43xx_pci_tbl);
 
 
+#define RATETAB_ENT(_rateid, _flags) \
+	{						\
+		.rate	= (((_rateid) * 10) / 2),	\
+		.val	= (_rateid),			\
+		.val2	= (_rateid),			\
+		.flags	= (_flags),			\
+	}
+static const struct ieee80211_rate bcm43xx_cck_ratetable[] = {
+	RATETAB_ENT(BCM43xx_CCK_RATE_1MB, IEEE80211_RATE_CCK),
+	RATETAB_ENT(BCM43xx_CCK_RATE_2MB, IEEE80211_RATE_CCK_2),
+	RATETAB_ENT(BCM43xx_CCK_RATE_5MB, IEEE80211_RATE_CCK_2),
+	RATETAB_ENT(BCM43xx_CCK_RATE_11MB, IEEE80211_RATE_CCK_2),
+};
+static const struct ieee80211_rate bcm43xx_ofdm_ratetable[] = {
+	RATETAB_ENT(BCM43xx_OFDM_RATE_6MB, IEEE80211_RATE_OFDM),
+	RATETAB_ENT(BCM43xx_OFDM_RATE_9MB, IEEE80211_RATE_OFDM),
+	RATETAB_ENT(BCM43xx_OFDM_RATE_12MB, IEEE80211_RATE_OFDM),
+	RATETAB_ENT(BCM43xx_OFDM_RATE_18MB, IEEE80211_RATE_OFDM),
+	RATETAB_ENT(BCM43xx_OFDM_RATE_24MB, IEEE80211_RATE_OFDM),
+	RATETAB_ENT(BCM43xx_OFDM_RATE_36MB, IEEE80211_RATE_OFDM),
+	RATETAB_ENT(BCM43xx_OFDM_RATE_48MB, IEEE80211_RATE_OFDM),
+	RATETAB_ENT(BCM43xx_OFDM_RATE_54MB, IEEE80211_RATE_OFDM),
+};
+#define CHANTAB_ENT(_chanid, _freq) \
+	{							\
+		.chan	= (_chanid),				\
+		.freq	= (_freq),				\
+		.val	= (_chanid),				\
+		.flag	= IEEE80211_CHAN_W_SCAN |		\
+			  IEEE80211_CHAN_W_ACTIVE_SCAN |	\
+			  IEEE80211_CHAN_W_IBSS,		\
+		.power_level	= 0xFF,				\
+		.antenna_max	= 0xFF,				\
+	}
+static const struct ieee80211_channel bcm43xx_bg_chantable[] = {
+	CHANTAB_ENT(1, 2412),
+	CHANTAB_ENT(2, 2417),
+	CHANTAB_ENT(3, 2422),
+	CHANTAB_ENT(4, 2427),
+	CHANTAB_ENT(5, 2432),
+	CHANTAB_ENT(6, 2437),
+	CHANTAB_ENT(7, 2442),
+	CHANTAB_ENT(8, 2447),
+	CHANTAB_ENT(9, 2452),
+	CHANTAB_ENT(10, 2457),
+	CHANTAB_ENT(11, 2462),
+	CHANTAB_ENT(12, 2467),
+	CHANTAB_ENT(13, 2472),
+	CHANTAB_ENT(14, 2484),
+};
+static const struct ieee80211_channel bcm43xx_a_chantable[] = {
+	CHANTAB_ENT(36, 5180),
+	CHANTAB_ENT(40, 5200),
+	CHANTAB_ENT(44, 5220),
+	CHANTAB_ENT(48, 5240),
+	CHANTAB_ENT(52, 5260),
+	CHANTAB_ENT(56, 5280),
+	CHANTAB_ENT(60, 5300),
+	CHANTAB_ENT(64, 5320),
+	CHANTAB_ENT(149, 5745),
+	CHANTAB_ENT(153, 5765),
+	CHANTAB_ENT(157, 5785),
+	CHANTAB_ENT(161, 5805),
+	CHANTAB_ENT(165, 5825),
+};
+
+
 static void bcm43xx_ram_write(struct bcm43xx_private *bcm, u16 offset, u32 val)
 {
 	u32 status;
@@ -516,23 +583,19 @@
 }
 
 /* Make sure we don't receive more data from the device. */
-static int bcm43xx_disable_interrupts_sync(struct bcm43xx_private *bcm, u32 *oldstate)
+static int bcm43xx_disable_interrupts_sync(struct bcm43xx_private *bcm)
 {
 	unsigned long flags;
-	u32 old;
 
 	spin_lock_irqsave(&bcm->irq_lock, flags);
 	if (unlikely(bcm43xx_status(bcm) != BCM43xx_STAT_INITIALIZED)) {
 		spin_unlock_irqrestore(&bcm->irq_lock, flags);
 		return -EBUSY;
 	}
-	old = bcm43xx_interrupt_disable(bcm, BCM43xx_IRQ_ALL);
+	bcm43xx_interrupt_disable(bcm, BCM43xx_IRQ_ALL);
 	spin_unlock_irqrestore(&bcm->irq_lock, flags);
 	bcm43xx_synchronize_irq(bcm);
 
-	if (oldstate)
-		*oldstate = old;
-
 	return 0;
 }
 
@@ -544,7 +607,6 @@
 	u16 manufact;
 	u16 version;
 	u8 revision;
-	s8 i;
 
 	if (bcm->chip_id == 0x4317) {
 		if (bcm->chip_rev == 0x00)
@@ -587,17 +649,6 @@
 	radio->version = version;
 	radio->revision = revision;
 
-	/* Set default attenuation values. */
-	radio->baseband_atten = bcm43xx_default_baseband_attenuation(bcm);
-	radio->radio_atten = bcm43xx_default_radio_attenuation(bcm);
-	radio->txctl1 = bcm43xx_default_txctl1(bcm);
-	radio->txctl2 = 0xFFFF;
-	radio->power_level = ~0;
-
-	/* Initialize the in-memory nrssi Lookup Table. */
-	for (i = 0; i < 64; i++)
-		radio->nrssi_lt[i] = i;
-
 	return 0;
 
 err_unsupported_radio:
@@ -1150,10 +1201,6 @@
 		goto out;
 
 	bcm->current_core = new_core;
-	bcm->current_80211_core_idx = -1;
-	if (new_core->id == BCM43xx_COREID_80211)
-		bcm->current_80211_core_idx = (int)(new_core - &(bcm->core_80211[0]));
-
 out:
 	return err;
 }
@@ -1323,43 +1370,23 @@
 	bcm43xx_core_disable(bcm, 0);
 }
 
-/* Mark the current 80211 core inactive.
- * "active_80211_core" is the other 80211 core, which is used.
- */
-static int bcm43xx_wireless_core_mark_inactive(struct bcm43xx_private *bcm,
-					       struct bcm43xx_coreinfo *active_80211_core)
+/* Mark the current 80211 core inactive. */
+static void bcm43xx_wireless_core_mark_inactive(struct bcm43xx_private *bcm)
 {
 	u32 sbtmstatelow;
-	struct bcm43xx_coreinfo *old_core;
-	int err = 0;
 
 	bcm43xx_interrupt_disable(bcm, BCM43xx_IRQ_ALL);
 	bcm43xx_radio_turn_off(bcm);
 	sbtmstatelow = bcm43xx_read32(bcm, BCM43xx_CIR_SBTMSTATELOW);
-	sbtmstatelow &= ~0x200a0000;
-	sbtmstatelow |= 0xa0000;
+	sbtmstatelow &= 0xDFF5FFFF;
+	sbtmstatelow |= 0x000A0000;
 	bcm43xx_write32(bcm, BCM43xx_CIR_SBTMSTATELOW, sbtmstatelow);
 	udelay(1);
 	sbtmstatelow = bcm43xx_read32(bcm, BCM43xx_CIR_SBTMSTATELOW);
-	sbtmstatelow &= ~0xa0000;
-	sbtmstatelow |= 0x80000;
+	sbtmstatelow &= 0xFFF5FFFF;
+	sbtmstatelow |= 0x00080000;
 	bcm43xx_write32(bcm, BCM43xx_CIR_SBTMSTATELOW, sbtmstatelow);
 	udelay(1);
-
-	if (bcm43xx_current_phy(bcm)->type == BCM43xx_PHYTYPE_G) {
-		old_core = bcm->current_core;
-		err = bcm43xx_switch_core(bcm, active_80211_core);
-		if (err)
-			goto out;
-		sbtmstatelow = bcm43xx_read32(bcm, BCM43xx_CIR_SBTMSTATELOW);
-		sbtmstatelow &= ~0x20000000;
-		sbtmstatelow |= 0x20000000;
-		bcm43xx_write32(bcm, BCM43xx_CIR_SBTMSTATELOW, sbtmstatelow);
-		err = bcm43xx_switch_core(bcm, old_core);
-	}
-
-out:
-	return err;
 }
 
 static void handle_irq_transmit_status(struct bcm43xx_private *bcm)
@@ -2008,6 +2035,9 @@
 
 	spin_lock(&bcm->irq_lock);
 
+	assert(bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED);
+	assert(bcm->current_core->id == BCM43xx_COREID_80211);
+
 	reason = bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON);
 	if (reason == 0xffffffff) {
 		/* irq not for us (shared irq) */
@@ -2028,21 +2058,11 @@
 			     & 0x0001dc00;
 
 	bcm43xx_interrupt_ack(bcm, reason);
-
-	/* Only accept IRQs, if we are initialized properly.
-	 * This avoids an RX race while initializing.
-	 * We should probably not enable IRQs before we are initialized
-	 * completely, but some careful work is needed to fix this. I think it
-	 * is best to stay with this cheap workaround for now... .
-	 */
-	if (likely(bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED)) {
-		/* disable all IRQs. They are enabled again in the bottom half. */
-		bcm->irq_savedstate = bcm43xx_interrupt_disable(bcm, BCM43xx_IRQ_ALL);
-		/* save the reason code and call our bottom half. */
-		bcm->irq_reason = reason;
-		tasklet_schedule(&bcm->isr_tasklet);
-	}
-
+	/* disable all IRQs. They are enabled again in the bottom half. */
+	bcm->irq_savedstate = bcm43xx_interrupt_disable(bcm, BCM43xx_IRQ_ALL);
+	/* save the reason code and call our bottom half. */
+	bcm->irq_reason = reason;
+	tasklet_schedule(&bcm->isr_tasklet);
 out:
 	mmiowb();
 	spin_unlock(&bcm->irq_lock);
@@ -2052,16 +2072,18 @@
 
 static void bcm43xx_release_firmware(struct bcm43xx_private *bcm, int force)
 {
+	struct bcm43xx_phyinfo *phy = bcm43xx_current_phy(bcm);
+
 	if (bcm->firmware_norelease && !force)
 		return; /* Suspending or controller reset. */
-	release_firmware(bcm->ucode);
-	bcm->ucode = NULL;
-	release_firmware(bcm->pcm);
-	bcm->pcm = NULL;
-	release_firmware(bcm->initvals0);
-	bcm->initvals0 = NULL;
-	release_firmware(bcm->initvals1);
-	bcm->initvals1 = NULL;
+	release_firmware(phy->ucode);
+	phy->ucode = NULL;
+	release_firmware(phy->pcm);
+	phy->pcm = NULL;
+	release_firmware(phy->initvals0);
+	phy->initvals0 = NULL;
+	release_firmware(phy->initvals1);
+	phy->initvals1 = NULL;
 }
 
 static int bcm43xx_request_firmware(struct bcm43xx_private *bcm)
@@ -2072,11 +2094,11 @@
 	int nr;
 	char buf[22 + sizeof(modparam_fwpostfix) - 1] = { 0 };
 
-	if (!bcm->ucode) {
+	if (!phy->ucode) {
 		snprintf(buf, ARRAY_SIZE(buf), "bcm43xx_microcode%d%s.fw",
 			 (rev >= 5 ? 5 : rev),
 			 modparam_fwpostfix);
-		err = request_firmware(&bcm->ucode, buf, &bcm->pci_dev->dev);
+		err = request_firmware(&phy->ucode, buf, &bcm->pci_dev->dev);
 		if (err) {
 			printk(KERN_ERR PFX 
 			       "Error: Microcode \"%s\" not available or load failed.\n",
@@ -2085,12 +2107,12 @@
 		}
 	}
 
-	if (!bcm->pcm) {
+	if (!phy->pcm) {
 		snprintf(buf, ARRAY_SIZE(buf),
 			 "bcm43xx_pcm%d%s.fw",
 			 (rev < 5 ? 4 : 5),
 			 modparam_fwpostfix);
-		err = request_firmware(&bcm->pcm, buf, &bcm->pci_dev->dev);
+		err = request_firmware(&phy->pcm, buf, &bcm->pci_dev->dev);
 		if (err) {
 			printk(KERN_ERR PFX
 			       "Error: PCM \"%s\" not available or load failed.\n",
@@ -2099,7 +2121,7 @@
 		}
 	}
 
-	if (!bcm->initvals0) {
+	if (!phy->initvals0) {
 		if (rev == 2 || rev == 4) {
 			switch (phy->type) {
 			case BCM43xx_PHYTYPE_A:
@@ -2130,20 +2152,20 @@
 		snprintf(buf, ARRAY_SIZE(buf), "bcm43xx_initval%02d%s.fw",
 			 nr, modparam_fwpostfix);
 
-		err = request_firmware(&bcm->initvals0, buf, &bcm->pci_dev->dev);
+		err = request_firmware(&phy->initvals0, buf, &bcm->pci_dev->dev);
 		if (err) {
 			printk(KERN_ERR PFX 
 			       "Error: InitVals \"%s\" not available or load failed.\n",
 			        buf);
 			goto error;
 		}
-		if (bcm->initvals0->size % sizeof(struct bcm43xx_initval)) {
+		if (phy->initvals0->size % sizeof(struct bcm43xx_initval)) {
 			printk(KERN_ERR PFX "InitVals fileformat error.\n");
 			goto error;
 		}
 	}
 
-	if (!bcm->initvals1) {
+	if (!phy->initvals1) {
 		if (rev >= 5) {
 			u32 sbtmstatehigh;
 
@@ -2165,14 +2187,14 @@
 			snprintf(buf, ARRAY_SIZE(buf), "bcm43xx_initval%02d%s.fw",
 				 nr, modparam_fwpostfix);
 
-			err = request_firmware(&bcm->initvals1, buf, &bcm->pci_dev->dev);
+			err = request_firmware(&phy->initvals1, buf, &bcm->pci_dev->dev);
 			if (err) {
 				printk(KERN_ERR PFX 
 				       "Error: InitVals \"%s\" not available or load failed.\n",
 			        	buf);
 				goto error;
 			}
-			if (bcm->initvals1->size % sizeof(struct bcm43xx_initval)) {
+			if (phy->initvals1->size % sizeof(struct bcm43xx_initval)) {
 				printk(KERN_ERR PFX "InitVals fileformat error.\n");
 				goto error;
 			}
@@ -2192,12 +2214,13 @@
 
 static void bcm43xx_upload_microcode(struct bcm43xx_private *bcm)
 {
+	struct bcm43xx_phyinfo *phy = bcm43xx_current_phy(bcm);
 	const u32 *data;
 	unsigned int i, len;
 
 	/* Upload Microcode. */
-	data = (u32 *)(bcm->ucode->data);
-	len = bcm->ucode->size / sizeof(u32);
+	data = (u32 *)(phy->ucode->data);
+	len = phy->ucode->size / sizeof(u32);
 	bcm43xx_shm_control_word(bcm, BCM43xx_SHM_UCODE, 0x0000);
 	for (i = 0; i < len; i++) {
 		bcm43xx_write32(bcm, BCM43xx_MMIO_SHM_DATA,
@@ -2206,8 +2229,8 @@
 	}
 
 	/* Upload PCM data. */
-	data = (u32 *)(bcm->pcm->data);
-	len = bcm->pcm->size / sizeof(u32);
+	data = (u32 *)(phy->pcm->data);
+	len = phy->pcm->size / sizeof(u32);
 	bcm43xx_shm_control_word(bcm, BCM43xx_SHM_PCM, 0x01ea);
 	bcm43xx_write32(bcm, BCM43xx_MMIO_SHM_DATA, 0x00004000);
 	bcm43xx_shm_control_word(bcm, BCM43xx_SHM_PCM, 0x01eb);
@@ -2253,15 +2276,16 @@
 
 static int bcm43xx_upload_initvals(struct bcm43xx_private *bcm)
 {
+	struct bcm43xx_phyinfo *phy = bcm43xx_current_phy(bcm);
 	int err;
 
-	err = bcm43xx_write_initvals(bcm, (struct bcm43xx_initval *)bcm->initvals0->data,
-				     bcm->initvals0->size / sizeof(struct bcm43xx_initval));
+	err = bcm43xx_write_initvals(bcm, (struct bcm43xx_initval *)phy->initvals0->data,
+				     phy->initvals0->size / sizeof(struct bcm43xx_initval));
 	if (err)
 		goto out;
-	if (bcm->initvals1) {
-		err = bcm43xx_write_initvals(bcm, (struct bcm43xx_initval *)bcm->initvals1->data,
-					     bcm->initvals1->size / sizeof(struct bcm43xx_initval));
+	if (phy->initvals1) {
+		err = bcm43xx_write_initvals(bcm, (struct bcm43xx_initval *)phy->initvals1->data,
+					     phy->initvals1->size / sizeof(struct bcm43xx_initval));
 		if (err)
 			goto out;
 	}
@@ -2271,9 +2295,7 @@
 
 static int bcm43xx_initialize_irq(struct bcm43xx_private *bcm)
 {
-	int res;
-	unsigned int i;
-	u32 data;
+	int err;
 
 	bcm->irq = bcm->pci_dev->irq;
 #ifdef CONFIG_BCM947XX
@@ -2286,32 +2308,12 @@
 		}
 	}
 #endif
-	res = request_irq(bcm->irq, bcm43xx_interrupt_handler,
+	err = request_irq(bcm->irq, bcm43xx_interrupt_handler,
 			  SA_SHIRQ, KBUILD_MODNAME, bcm);
-	if (res) {
+	if (err)
 		printk(KERN_ERR PFX "Cannot register IRQ%d\n", bcm->irq);
-		return -ENODEV;
-	}
-	bcm43xx_write32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON, 0xffffffff);
-	bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS_BITFIELD, 0x00020402);
-	i = 0;
-	while (1) {
-		data = bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON);
-		if (data == BCM43xx_IRQ_READY)
-			break;
-		i++;
-		if (i >= BCM43xx_IRQWAIT_MAX_RETRIES) {
-			printk(KERN_ERR PFX "Card IRQ register not responding. "
-					    "Giving up.\n");
-			free_irq(bcm->irq, bcm);
-			return -ENODEV;
-		}
-		udelay(10);
-	}
-	// dummy read
-	bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON);
 
-	return 0;
+	return err;
 }
 
 /* Switch to the core used to write the GPIO register.
@@ -2498,6 +2500,46 @@
 	bcm43xx_write16(bcm, 0x0612, value);
 }
 
+static void bcm43xx_rate_memory_write(struct bcm43xx_private *bcm,
+				      u16 rate,
+				      int is_ofdm)
+{
+	u16 offset;
+
+	if (is_ofdm) {
+		offset = 0x480;
+		offset += (bcm43xx_plcp_get_ratecode_ofdm(rate) & 0x000F) * 2;
+	} else {
+		offset = 0x4C0;
+		offset += (bcm43xx_plcp_get_ratecode_cck(rate) & 0x000F) * 2;
+	}
+	bcm43xx_shm_write16(bcm, BCM43xx_SHM_SHARED, offset + 0x20,
+			    bcm43xx_shm_read16(bcm, BCM43xx_SHM_SHARED, offset));
+}
+
+static void bcm43xx_rate_memory_init(struct bcm43xx_private *bcm)
+{
+	switch (bcm43xx_current_phy(bcm)->type) {
+	case BCM43xx_PHYTYPE_A:
+	case BCM43xx_PHYTYPE_G:
+		bcm43xx_rate_memory_write(bcm, BCM43xx_OFDM_RATE_6MB, 1);
+		bcm43xx_rate_memory_write(bcm, BCM43xx_OFDM_RATE_12MB, 1);
+		bcm43xx_rate_memory_write(bcm, BCM43xx_OFDM_RATE_18MB, 1);
+		bcm43xx_rate_memory_write(bcm, BCM43xx_OFDM_RATE_24MB, 1);
+		bcm43xx_rate_memory_write(bcm, BCM43xx_OFDM_RATE_36MB, 1);
+		bcm43xx_rate_memory_write(bcm, BCM43xx_OFDM_RATE_48MB, 1);
+		bcm43xx_rate_memory_write(bcm, BCM43xx_OFDM_RATE_54MB, 1);
+	case BCM43xx_PHYTYPE_B:
+		bcm43xx_rate_memory_write(bcm, BCM43xx_CCK_RATE_1MB, 0);
+		bcm43xx_rate_memory_write(bcm, BCM43xx_CCK_RATE_2MB, 0);
+		bcm43xx_rate_memory_write(bcm, BCM43xx_CCK_RATE_5MB, 0);
+		bcm43xx_rate_memory_write(bcm, BCM43xx_CCK_RATE_11MB, 0);
+		break;
+	default:
+		assert(0);
+	}
+}
+
 /* This is the opposite of bcm43xx_chip_init() */
 static void bcm43xx_chip_cleanup(struct bcm43xx_private *bcm)
 {
@@ -2505,7 +2547,6 @@
 	if (!modparam_noleds)
 		bcm43xx_leds_exit(bcm);
 	bcm43xx_gpio_cleanup(bcm);
-	free_irq(bcm->irq, bcm);
 	bcm43xx_release_firmware(bcm, 0);
 }
 
@@ -2517,7 +2558,7 @@
 	struct bcm43xx_radioinfo *radio = bcm43xx_current_radio(bcm);
 	struct bcm43xx_phyinfo *phy = bcm43xx_current_phy(bcm);
 	int err;
-	int tmp;
+	int i, tmp;
 	u32 value32;
 	u16 value16;
 
@@ -2529,12 +2570,27 @@
 	if (err)
 		goto out;
 	bcm43xx_upload_microcode(bcm);
-	err = bcm43xx_initialize_irq(bcm);
-	if (err)
-		goto err_release_fw;
+
+	bcm43xx_write32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON, 0xFFFFFFFF);
+	bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS_BITFIELD, 0x00020402);
+	i = 0;
+	while (1) {
+		value32 = bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON);
+		if (value32 == BCM43xx_IRQ_READY)
+			break;
+		i++;
+		if (i >= BCM43xx_IRQWAIT_MAX_RETRIES) {
+			printk(KERN_ERR PFX "IRQ_READY timeout\n");
+			err = -ENODEV;
+			goto err_release_fw;
+		}
+		udelay(10);
+	}
+	bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON); /* dummy read */
+
 	err = bcm43xx_gpio_init(bcm);
 	if (err)
-		goto err_free_irq;
+		goto err_release_fw;
 	err = bcm43xx_upload_initvals(bcm);
 	if (err)
 		goto err_gpio_cleanup;
@@ -2617,140 +2673,457 @@
 	bcm43xx_radio_turn_off(bcm);
 err_gpio_cleanup:
 	bcm43xx_gpio_cleanup(bcm);
-err_free_irq:
-	free_irq(bcm->irq, bcm);
 err_release_fw:
 	bcm43xx_release_firmware(bcm, 1);
 	goto out;
 }
-	
-/* Validate chip access
- * http://bcm-specs.sipsolutions.net/ValidateChipAccess */
-static int bcm43xx_validate_chip(struct bcm43xx_private *bcm)
-{
-	u32 value;
-	u32 shm_backup;
-
-	shm_backup = bcm43xx_shm_read32(bcm, BCM43xx_SHM_SHARED, 0x0000);
-	bcm43xx_shm_write32(bcm, BCM43xx_SHM_SHARED, 0x0000, 0xAA5555AA);
-	if (bcm43xx_shm_read32(bcm, BCM43xx_SHM_SHARED, 0x0000) != 0xAA5555AA)
-		goto error;
-	bcm43xx_shm_write32(bcm, BCM43xx_SHM_SHARED, 0x0000, 0x55AAAA55);
-	if (bcm43xx_shm_read32(bcm, BCM43xx_SHM_SHARED, 0x0000) != 0x55AAAA55)
-		goto error;
-	bcm43xx_shm_write32(bcm, BCM43xx_SHM_SHARED, 0x0000, shm_backup);
-
-	value = bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD);
-	if ((value | 0x80000000) != 0x80000400)
-		goto error;
-
-	value = bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON);
-	if (value != 0x00000000)
-		goto error;
-
-	return 0;
-error:
-	printk(KERN_ERR PFX "Failed to validate the chipaccess\n");
-	return -ENODEV;
-}
 
-static void bcm43xx_init_struct_phyinfo(struct bcm43xx_phyinfo *phy)
+static void bcm43xx_wireless_core_cleanup(struct bcm43xx_private *bcm)
 {
-	/* Initialize a "phyinfo" structure. The structure is already
-	 * zeroed out.
-	 */
-	phy->antenna_diversity = 0xFFFF;
-	phy->savedpctlreg = 0xFFFF;
-	phy->minlowsig[0] = 0xFFFF;
-	phy->minlowsig[1] = 0xFFFF;
-	spin_lock_init(&phy->lock);
-}
+	bcm43xx_chip_cleanup(bcm);
+	bcm43xx_pio_free(bcm);
+	bcm43xx_dma_free(bcm);
 
-static void bcm43xx_init_struct_radioinfo(struct bcm43xx_radioinfo *radio)
-{
-	/* Initialize a "radioinfo" structure. The structure is already
-	 * zeroed out.
-	 */
-	radio->interfmode = BCM43xx_RADIO_INTERFMODE_NONE;
-	radio->channel = 0xFF;
-	radio->initial_channel = 0xFF;
-	radio->lofcal = 0xFFFF;
-	radio->initval = 0xFFFF;
-	radio->nrssi[0] = -1000;
-	radio->nrssi[1] = -1000;
+	bcm->current_core->initialized = 0;
 }
 
-static int bcm43xx_probe_cores(struct bcm43xx_private *bcm)
+/* http://bcm-specs.sipsolutions.net/80211Init */
+static int bcm43xx_wireless_core_init(struct bcm43xx_private *bcm,
+				      int active_wlcore)
 {
-	int err, i;
-	int current_core;
-	u32 core_vendor, core_id, core_rev;
-	u32 sb_id_hi, chip_id_32 = 0;
-	u16 pci_device, chip_id_16;
-	u8 core_count;
+	struct bcm43xx_phyinfo *phy = bcm43xx_current_phy(bcm);
+	struct bcm43xx_radioinfo *radio = bcm43xx_current_radio(bcm);
+	u32 ucodeflags;
+	int err;
+	u32 sbimconfiglow;
+	u8 limit;
 
-	memset(&bcm->core_chipcommon, 0, sizeof(struct bcm43xx_coreinfo));
-	memset(&bcm->core_pci, 0, sizeof(struct bcm43xx_coreinfo));
-	memset(&bcm->core_80211, 0, sizeof(struct bcm43xx_coreinfo)
-				    * BCM43xx_MAX_80211_CORES);
-	memset(&bcm->core_80211_ext, 0, sizeof(struct bcm43xx_coreinfo_80211)
-					* BCM43xx_MAX_80211_CORES);
-	bcm->current_80211_core_idx = -1;
-	bcm->nr_80211_available = 0;
-	bcm->current_core = NULL;
-	bcm->active_80211_core = NULL;
+	if (bcm->chip_rev < 5) {
+		sbimconfiglow = bcm43xx_read32(bcm, BCM43xx_CIR_SBIMCONFIGLOW);
+		sbimconfiglow &= ~ BCM43xx_SBIMCONFIGLOW_REQUEST_TOUT_MASK;
+		sbimconfiglow &= ~ BCM43xx_SBIMCONFIGLOW_SERVICE_TOUT_MASK;
+		if (bcm->bustype == BCM43xx_BUSTYPE_PCI)
+			sbimconfiglow |= 0x32;
+		else if (bcm->bustype == BCM43xx_BUSTYPE_SB)
+			sbimconfiglow |= 0x53;
+		else
+			assert(0);
+		bcm43xx_write32(bcm, BCM43xx_CIR_SBIMCONFIGLOW, sbimconfiglow);
+	}
 
-	/* map core 0 */
-	err = _switch_core(bcm, 0);
+	bcm43xx_phy_calibrate(bcm);
+	err = bcm43xx_chip_init(bcm);
 	if (err)
 		goto out;
 
-	/* fetch sb_id_hi from core information registers */
-	sb_id_hi = bcm43xx_read32(bcm, BCM43xx_CIR_SB_ID_HI);
+	bcm43xx_shm_write16(bcm, BCM43xx_SHM_SHARED, 0x0016, bcm->current_core->rev);
+	ucodeflags = bcm43xx_shm_read32(bcm, BCM43xx_SHM_SHARED, BCM43xx_UCODEFLAGS_OFFSET);
 
-	core_id = (sb_id_hi & 0xFFF0) >> 4;
-	core_rev = (sb_id_hi & 0xF);
-	core_vendor = (sb_id_hi & 0xFFFF0000) >> 16;
+	if (0 /*FIXME: which condition has to be used here? */)
+		ucodeflags |= 0x00000010;
 
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
-#ifdef CONFIG_BCM947XX
-		else if ((pci_device >= 0x4320) && (pci_device <= 0x4325))
-			chip_id_16 = 0x4309;
-#endif
-		else {
-			printk(KERN_ERR PFX "Could not determine Chip ID\n");
-			return -ENODEV;
-		}
-	}
+	/* HW decryption needs to be set now. */
+	ucodeflags |= 0x40000000;
 
-	/* ChipCommon with Core Rev >=4 encodes number of cores,
-	 * otherwise consult hardcoded table */
-	if ((core_id == BCM43xx_COREID_CHIPCOMMON) && (core_rev >= 4)) {
-		core_count = (chip_id_32 & 0x0F000000) >> 24;
-	} else {
-		switch (chip_id_16) {
+	if (phy->type == BCM43xx_PHYTYPE_G) {
+		ucodeflags |= BCM43xx_UCODEFLAG_UNKBGPHY;
+		if (phy->rev == 1)
+			ucodeflags |= BCM43xx_UCODEFLAG_UNKGPHY;
+		if (bcm->sprom.boardflags & BCM43xx_BFL_PACTRL)
+			ucodeflags |= BCM43xx_UCODEFLAG_UNKPACTRL;
+	} else if (phy->type == BCM43xx_PHYTYPE_B) {
+		ucodeflags |= BCM43xx_UCODEFLAG_UNKBGPHY;
+		if (phy->rev >= 2 && radio->version == 0x2050)
+			ucodeflags &= ~BCM43xx_UCODEFLAG_UNKGPHY;
+	}
+
+	if (ucodeflags != bcm43xx_shm_read32(bcm, BCM43xx_SHM_SHARED,
+					     BCM43xx_UCODEFLAGS_OFFSET)) {
+		bcm43xx_shm_write32(bcm, BCM43xx_SHM_SHARED,
+				    BCM43xx_UCODEFLAGS_OFFSET, ucodeflags);
+	}
+
+	/* Short/Long Retry Limit.
+	 * The retry-limit is a 4-bit counter. Enforce this to avoid overflowing
+	 * the chip-internal counter.
+	 */
+	limit = limit_value(modparam_short_retry, 0, 0xF);
+	bcm43xx_shm_write32(bcm, BCM43xx_SHM_WIRELESS, 0x0006, limit);
+	limit = limit_value(modparam_long_retry, 0, 0xF);
+	bcm43xx_shm_write32(bcm, BCM43xx_SHM_WIRELESS, 0x0007, limit);
+
+	bcm43xx_shm_write16(bcm, BCM43xx_SHM_SHARED, 0x0044, 3);
+	bcm43xx_shm_write16(bcm, BCM43xx_SHM_SHARED, 0x0046, 2);
+
+	bcm43xx_rate_memory_init(bcm);
+
+	/* Minimum Contention Window */
+	if (phy->type == BCM43xx_PHYTYPE_B)
+		bcm43xx_shm_write32(bcm, BCM43xx_SHM_WIRELESS, 0x0003, 0x0000001f);
+	else
+		bcm43xx_shm_write32(bcm, BCM43xx_SHM_WIRELESS, 0x0003, 0x0000000f);
+	/* Maximum Contention Window */
+	bcm43xx_shm_write32(bcm, BCM43xx_SHM_WIRELESS, 0x0004, 0x000003ff);
+
+	bcm43xx_write_mac_bssid_templates(bcm);
+
+	if (bcm->current_core->rev >= 5)
+		bcm43xx_write16(bcm, 0x043C, 0x000C);
+
+	if (active_wlcore) {
+		if (bcm43xx_using_pio(bcm))
+			err = bcm43xx_pio_init(bcm);
+		else
+			err = bcm43xx_dma_init(bcm);
+		if (err)
+			goto err_chip_cleanup;
+	}
+	bcm43xx_write16(bcm, 0x0612, 0x0050);
+	bcm43xx_shm_write16(bcm, BCM43xx_SHM_SHARED, 0x0416, 0x0050);
+	bcm43xx_shm_write16(bcm, BCM43xx_SHM_SHARED, 0x0414, 0x01F4);
+
+	if (active_wlcore) {
+		if (radio->initial_channel != 0xFF)
+			bcm43xx_radio_selectchannel(bcm, radio->initial_channel, 0);
+	}
+
+	/* Don't enable MAC/IRQ here, as it will race with the IRQ handler.
+	 * We enable it later.
+	 */
+	bcm->current_core->initialized = 1;
+out:
+	return err;
+
+err_chip_cleanup:
+	bcm43xx_chip_cleanup(bcm);
+	goto out;
+}
+
+static void bcm43xx_periodic_every120sec(struct bcm43xx_private *bcm)
+{
+	struct bcm43xx_phyinfo *phy = bcm43xx_current_phy(bcm);
+
+	if (phy->type != BCM43xx_PHYTYPE_G || phy->rev < 2)
+		return;
+
+	bcm43xx_mac_suspend(bcm);
+	bcm43xx_phy_lo_g_measure(bcm);
+	bcm43xx_mac_enable(bcm);
+}
+
+static void bcm43xx_periodic_every60sec(struct bcm43xx_private *bcm)
+{
+	bcm43xx_phy_lo_mark_all_unused(bcm);
+	if (bcm->sprom.boardflags & BCM43xx_BFL_RSSI) {
+		bcm43xx_mac_suspend(bcm);
+		bcm43xx_calc_nrssi_slope(bcm);
+		bcm43xx_mac_enable(bcm);
+	}
+}
+
+static void bcm43xx_periodic_every30sec(struct bcm43xx_private *bcm)
+{
+	/* Update device statistics. */
+	bcm43xx_calculate_link_quality(bcm);
+}
+
+static void bcm43xx_periodic_every15sec(struct bcm43xx_private *bcm)
+{
+	struct bcm43xx_phyinfo *phy = bcm43xx_current_phy(bcm);
+	struct bcm43xx_radioinfo *radio = bcm43xx_current_radio(bcm);
+
+	if (phy->type == BCM43xx_PHYTYPE_G) {
+		//TODO: update_aci_moving_average
+		if (radio->aci_enable && radio->aci_wlan_automatic) {
+			bcm43xx_mac_suspend(bcm);
+			if (!radio->aci_enable && 1 /*TODO: not scanning? */) {
+				if (0 /*TODO: bunch of conditions*/) {
+					bcm43xx_radio_set_interference_mitigation(bcm,
+										  BCM43xx_RADIO_INTERFMODE_MANUALWLAN);
+				}
+			} else if (1/*TODO*/) {
+				/*
+				if ((aci_average > 1000) && !(bcm43xx_radio_aci_scan(bcm))) {
+					bcm43xx_radio_set_interference_mitigation(bcm,
+										  BCM43xx_RADIO_INTERFMODE_NONE);
+				}
+				*/
+			}
+			bcm43xx_mac_enable(bcm);
+		} else if (radio->interfmode == BCM43xx_RADIO_INTERFMODE_NONWLAN &&
+			   phy->rev == 1) {
+			//TODO: implement rev1 workaround
+		}
+	}
+	bcm43xx_phy_xmitpower(bcm); //FIXME: unless scanning?
+	//TODO for APHY (temperature?)
+}
+
+static void do_periodic_work(struct bcm43xx_private *bcm)
+{
+	unsigned int state;
+
+	state = bcm->periodic_state;
+	if (state % 8 == 0)
+		bcm43xx_periodic_every120sec(bcm);
+	if (state % 4 == 0)
+		bcm43xx_periodic_every60sec(bcm);
+	if (state % 2 == 0)
+		bcm43xx_periodic_every30sec(bcm);
+	if (state % 1 == 0)
+		bcm43xx_periodic_every15sec(bcm);
+	bcm->periodic_state = state + 1;
+
+	schedule_delayed_work(&bcm->periodic_work, HZ * 15);
+}
+
+/* Estimate a "Badness" value based on the periodic work
+ * state-machine state. "Badness" is worse (bigger), if the
+ * periodic work will take longer.
+ */
+static int estimate_periodic_work_badness(unsigned int state)
+{
+	int badness = 0;
+
+	if (state % 8 == 0) /* every 120 sec */
+		badness += 10;
+	if (state % 4 == 0) /* every 60 sec */
+		badness += 5;
+	if (state % 2 == 0) /* every 30 sec */
+		badness += 1;
+	if (state % 1 == 0) /* every 15 sec */
+		badness += 1;
+
+#define BADNESS_LIMIT	4
+	return badness;
+}
+
+static void bcm43xx_periodic_work_handler(void *d)
+{
+	struct bcm43xx_private *bcm = d;
+	unsigned long flags;
+	u32 savedirqs = 0;
+	int badness;
+
+	badness = estimate_periodic_work_badness(bcm->periodic_state);
+	if (badness > BADNESS_LIMIT) {
+		/* Periodic work will take a long time, so we want it to
+		 * be preemtible.
+		 */
+		netif_stop_queue(bcm->net_dev);
+		synchronize_net();
+		spin_lock_irqsave(&bcm->irq_lock, flags);
+		bcm43xx_mac_suspend(bcm);
+		if (bcm43xx_using_pio(bcm))
+			bcm43xx_pio_freeze_txqueues(bcm);
+		savedirqs = bcm43xx_interrupt_disable(bcm, BCM43xx_IRQ_ALL);
+		spin_unlock_irqrestore(&bcm->irq_lock, flags);
+		mutex_lock(&bcm->mutex);
+		bcm43xx_synchronize_irq(bcm);
+	} else {
+		/* Periodic work should take short time, so we want low
+		 * locking overhead.
+		 */
+		mutex_lock(&bcm->mutex);
+		spin_lock_irqsave(&bcm->irq_lock, flags);
+	}
+
+	do_periodic_work(bcm);
+
+	if (badness > BADNESS_LIMIT) {
+		spin_lock_irqsave(&bcm->irq_lock, flags);
+		if (likely(bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED)) {
+			tasklet_enable(&bcm->isr_tasklet);
+			bcm43xx_interrupt_enable(bcm, savedirqs);
+			if (bcm43xx_using_pio(bcm))
+				bcm43xx_pio_thaw_txqueues(bcm);
+			bcm43xx_mac_enable(bcm);
+		}
+		netif_wake_queue(bcm->net_dev);
+	}
+	mmiowb();
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
+	mutex_unlock(&bcm->mutex);
+}
+
+static void bcm43xx_periodic_tasks_delete(struct bcm43xx_private *bcm)
+{
+	cancel_rearming_delayed_work(&bcm->periodic_work);
+}
+
+static void bcm43xx_periodic_tasks_setup(struct bcm43xx_private *bcm)
+{
+	struct work_struct *work = &(bcm->periodic_work);
+
+	assert(bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED);
+	INIT_WORK(work, bcm43xx_periodic_work_handler, bcm);
+	schedule_work(work);
+}
+
+static int bcm43xx_shutdown_all_wireless_cores(struct bcm43xx_private *bcm)
+{
+	int ret = 0;
+	int i, err;
+	struct bcm43xx_coreinfo *core;
+
+	bcm43xx_set_status(bcm, BCM43xx_STAT_SHUTTINGDOWN);
+	for (i = 0; i < bcm->nr_80211_available; i++) {
+		core = &(bcm->core_80211[i]);
+		assert(core->available);
+		if (!core->initialized)
+			continue;
+		err = bcm43xx_switch_core(bcm, core);
+		if (err) {
+			dprintk(KERN_ERR PFX "shutdown_all_wireless_cores "
+					     "switch_core failed (%d)\n", err);
+			ret = err;
+			continue;
+		}
+		bcm43xx_interrupt_disable(bcm, BCM43xx_IRQ_ALL);
+		bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON); /* dummy read */
+		bcm43xx_wireless_core_cleanup(bcm);
+		if (core == bcm->active_80211_core)
+			bcm->active_80211_core = NULL;
+	}
+	free_irq(bcm->irq, bcm);
+	bcm43xx_set_status(bcm, BCM43xx_STAT_UNINIT);
+
+	return ret;
+}
+
+/* This is the opposite of bcm43xx_init_board() */
+static void bcm43xx_free_board(struct bcm43xx_private *bcm)
+{
+	bcm43xx_sysfs_unregister(bcm);
+	bcm43xx_periodic_tasks_delete(bcm);
+
+	mutex_lock(&bcm->mutex);
+	bcm43xx_shutdown_all_wireless_cores(bcm);
+	bcm43xx_pctl_set_crystal(bcm, 0);
+	mutex_unlock(&bcm->mutex);
+}
+
+/* Validate chip access
+ * http://bcm-specs.sipsolutions.net/ValidateChipAccess */
+static int bcm43xx_validate_chip(struct bcm43xx_private *bcm)
+{
+	u32 value;
+	u32 shm_backup;
+
+	shm_backup = bcm43xx_shm_read32(bcm, BCM43xx_SHM_SHARED, 0x0000);
+	bcm43xx_shm_write32(bcm, BCM43xx_SHM_SHARED, 0x0000, 0xAA5555AA);
+	if (bcm43xx_shm_read32(bcm, BCM43xx_SHM_SHARED, 0x0000) != 0xAA5555AA)
+		goto error;
+	bcm43xx_shm_write32(bcm, BCM43xx_SHM_SHARED, 0x0000, 0x55AAAA55);
+	if (bcm43xx_shm_read32(bcm, BCM43xx_SHM_SHARED, 0x0000) != 0x55AAAA55)
+		goto error;
+	bcm43xx_shm_write32(bcm, BCM43xx_SHM_SHARED, 0x0000, shm_backup);
+
+	value = bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD);
+	if ((value | 0x80000000) != 0x80000400)
+		goto error;
+
+	value = bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON);
+	if (value != 0x00000000)
+		goto error;
+
+	return 0;
+error:
+	printk(KERN_ERR PFX "Failed to validate the chipaccess\n");
+	return -ENODEV;
+}
+
+static void bcm43xx_init_struct_phyinfo(struct bcm43xx_phyinfo *phy)
+{
+	/* Initialize a "phyinfo" structure. The structure is already
+	 * zeroed out.
+	 * This is called on insmod time to initialize members.
+	 */
+	phy->savedpctlreg = 0xFFFF;
+	spin_lock_init(&phy->lock);
+}
+
+static void bcm43xx_init_struct_radioinfo(struct bcm43xx_radioinfo *radio)
+{
+	/* Initialize a "radioinfo" structure. The structure is already
+	 * zeroed out.
+	 * This is called on insmod time to initialize members.
+	 */
+	radio->interfmode = BCM43xx_RADIO_INTERFMODE_NONE;
+	radio->channel = 0xFF;
+	radio->initial_channel = 0xFF;
+}
+
+static int bcm43xx_probe_cores(struct bcm43xx_private *bcm)
+{
+	int err, i;
+	int current_core;
+	u32 core_vendor, core_id, core_rev;
+	u32 sb_id_hi, chip_id_32 = 0;
+	u16 pci_device, chip_id_16;
+	u8 core_count;
+
+	memset(&bcm->core_chipcommon, 0, sizeof(struct bcm43xx_coreinfo));
+	memset(&bcm->core_pci, 0, sizeof(struct bcm43xx_coreinfo));
+	memset(&bcm->core_80211, 0, sizeof(struct bcm43xx_coreinfo)
+				    * BCM43xx_MAX_80211_CORES);
+	memset(&bcm->core_80211_ext, 0, sizeof(struct bcm43xx_coreinfo_80211)
+					* BCM43xx_MAX_80211_CORES);
+	bcm->nr_80211_available = 0;
+	bcm->current_core = NULL;
+	bcm->active_80211_core = NULL;
+
+	/* map core 0 */
+	err = _switch_core(bcm, 0);
+	if (err)
+		goto out;
+
+	/* fetch sb_id_hi from core information registers */
+	sb_id_hi = bcm43xx_read32(bcm, BCM43xx_CIR_SB_ID_HI);
+
+	core_id = (sb_id_hi & 0xFFF0) >> 4;
+	core_rev = (sb_id_hi & 0xF);
+	core_vendor = (sb_id_hi & 0xFFFF0000) >> 16;
+
+	/* if present, chipcommon is always core 0; read the chipid from it */
+	if (core_id == BCM43xx_COREID_CHIPCOMMON) {
+		chip_id_32 = bcm43xx_read32(bcm, 0);
+		chip_id_16 = chip_id_32 & 0xFFFF;
+		bcm->core_chipcommon.available = 1;
+		bcm->core_chipcommon.id = core_id;
+		bcm->core_chipcommon.rev = core_rev;
+		bcm->core_chipcommon.index = 0;
+		/* While we are at it, also read the capabilities. */
+		bcm->chipcommon_capabilities = bcm43xx_read32(bcm, BCM43xx_CHIPCOMMON_CAPABILITIES);
+	} else {
+		/* without a chipCommon, use a hard coded table. */
+		pci_device = bcm->pci_dev->device;
+		if (pci_device == 0x4301)
+			chip_id_16 = 0x4301;
+		else if ((pci_device >= 0x4305) && (pci_device <= 0x4307))
+			chip_id_16 = 0x4307;
+		else if ((pci_device >= 0x4402) && (pci_device <= 0x4403))
+			chip_id_16 = 0x4402;
+		else if ((pci_device >= 0x4610) && (pci_device <= 0x4615))
+			chip_id_16 = 0x4610;
+		else if ((pci_device >= 0x4710) && (pci_device <= 0x4715))
+			chip_id_16 = 0x4710;
+#ifdef CONFIG_BCM947XX
+		else if ((pci_device >= 0x4320) && (pci_device <= 0x4325))
+			chip_id_16 = 0x4309;
+#endif
+		else {
+			printk(KERN_ERR PFX "Could not determine Chip ID\n");
+			return -ENODEV;
+		}
+	}
+
+	/* ChipCommon with Core Rev >=4 encodes number of cores,
+	 * otherwise consult hardcoded table */
+	if ((core_id == BCM43xx_COREID_CHIPCOMMON) && (core_rev >= 4)) {
+		core_count = (chip_id_32 & 0x0F000000) >> 24;
+	} else {
+		switch (chip_id_16) {
 			case 0x4610:
 			case 0x4704:
 			case 0x4710:
@@ -2865,6 +3238,7 @@
 				goto out;
 			}
 			bcm->nr_80211_available++;
+			core->priv = ext_80211;
 			bcm43xx_init_struct_phyinfo(&ext_80211->phy);
 			bcm43xx_init_struct_radioinfo(&ext_80211->radio);
 			break;
@@ -2876,174 +3250,21 @@
 			core->available = 1;
 			core->id = core_id;
 			core->rev = core_rev;
-			core->index = current_core;
-		}
-	}
-
-	if (!bcm->core_80211[0].available) {
-		printk(KERN_ERR PFX "Error: No 80211 core found!\n");
-		err = -ENODEV;
-		goto out;
-	}
-
-	err = bcm43xx_switch_core(bcm, &bcm->core_80211[0]);
-
-	assert(err == 0);
-out:
-	return err;
-}
-
-static void bcm43xx_rate_memory_write(struct bcm43xx_private *bcm,
-				      u16 rate,
-				      int is_ofdm)
-{
-	u16 offset;
-
-	if (is_ofdm) {
-		offset = 0x480;
-		offset += (bcm43xx_plcp_get_ratecode_ofdm(rate) & 0x000F) * 2;
-	} else {
-		offset = 0x4C0;
-		offset += (bcm43xx_plcp_get_ratecode_cck(rate) & 0x000F) * 2;
-	}
-	bcm43xx_shm_write16(bcm, BCM43xx_SHM_SHARED, offset + 0x20,
-			    bcm43xx_shm_read16(bcm, BCM43xx_SHM_SHARED, offset));
-}
-
-static void bcm43xx_rate_memory_init(struct bcm43xx_private *bcm)
-{
-	switch (bcm43xx_current_phy(bcm)->type) {
-	case BCM43xx_PHYTYPE_A:
-	case BCM43xx_PHYTYPE_G:
-		bcm43xx_rate_memory_write(bcm, BCM43xx_OFDM_RATE_6MB, 1);
-		bcm43xx_rate_memory_write(bcm, BCM43xx_OFDM_RATE_12MB, 1);
-		bcm43xx_rate_memory_write(bcm, BCM43xx_OFDM_RATE_18MB, 1);
-		bcm43xx_rate_memory_write(bcm, BCM43xx_OFDM_RATE_24MB, 1);
-		bcm43xx_rate_memory_write(bcm, BCM43xx_OFDM_RATE_36MB, 1);
-		bcm43xx_rate_memory_write(bcm, BCM43xx_OFDM_RATE_48MB, 1);
-		bcm43xx_rate_memory_write(bcm, BCM43xx_OFDM_RATE_54MB, 1);
-	case BCM43xx_PHYTYPE_B:
-		bcm43xx_rate_memory_write(bcm, BCM43xx_CCK_RATE_1MB, 0);
-		bcm43xx_rate_memory_write(bcm, BCM43xx_CCK_RATE_2MB, 0);
-		bcm43xx_rate_memory_write(bcm, BCM43xx_CCK_RATE_5MB, 0);
-		bcm43xx_rate_memory_write(bcm, BCM43xx_CCK_RATE_11MB, 0);
-		break;
-	default:
-		assert(0);
-	}
-}
-
-static void bcm43xx_wireless_core_cleanup(struct bcm43xx_private *bcm)
-{
-	bcm43xx_chip_cleanup(bcm);
-	bcm43xx_pio_free(bcm);
-	bcm43xx_dma_free(bcm);
-
-	bcm->current_core->initialized = 0;
-}
-
-/* http://bcm-specs.sipsolutions.net/80211Init */
-static int bcm43xx_wireless_core_init(struct bcm43xx_private *bcm)
-{
-	struct bcm43xx_phyinfo *phy = bcm43xx_current_phy(bcm);
-	struct bcm43xx_radioinfo *radio = bcm43xx_current_radio(bcm);
-	u32 ucodeflags;
-	int err;
-	u32 sbimconfiglow;
-	u8 limit;
-
-	if (bcm->chip_rev < 5) {
-		sbimconfiglow = bcm43xx_read32(bcm, BCM43xx_CIR_SBIMCONFIGLOW);
-		sbimconfiglow &= ~ BCM43xx_SBIMCONFIGLOW_REQUEST_TOUT_MASK;
-		sbimconfiglow &= ~ BCM43xx_SBIMCONFIGLOW_SERVICE_TOUT_MASK;
-		if (bcm->bustype == BCM43xx_BUSTYPE_PCI)
-			sbimconfiglow |= 0x32;
-		else if (bcm->bustype == BCM43xx_BUSTYPE_SB)
-			sbimconfiglow |= 0x53;
-		else
-			assert(0);
-		bcm43xx_write32(bcm, BCM43xx_CIR_SBIMCONFIGLOW, sbimconfiglow);
-	}
-
-	bcm43xx_phy_calibrate(bcm);
-	err = bcm43xx_chip_init(bcm);
-	if (err)
-		goto out;
-
-	bcm43xx_shm_write16(bcm, BCM43xx_SHM_SHARED, 0x0016, bcm->current_core->rev);
-	ucodeflags = bcm43xx_shm_read32(bcm, BCM43xx_SHM_SHARED, BCM43xx_UCODEFLAGS_OFFSET);
-
-	if (0 /*FIXME: which condition has to be used here? */)
-		ucodeflags |= 0x00000010;
-
-	/* HW decryption needs to be set now. */
-	ucodeflags |= 0x40000000;
-
-	if (phy->type == BCM43xx_PHYTYPE_G) {
-		ucodeflags |= BCM43xx_UCODEFLAG_UNKBGPHY;
-		if (phy->rev == 1)
-			ucodeflags |= BCM43xx_UCODEFLAG_UNKGPHY;
-		if (bcm->sprom.boardflags & BCM43xx_BFL_PACTRL)
-			ucodeflags |= BCM43xx_UCODEFLAG_UNKPACTRL;
-	} else if (phy->type == BCM43xx_PHYTYPE_B) {
-		ucodeflags |= BCM43xx_UCODEFLAG_UNKBGPHY;
-		if (phy->rev >= 2 && radio->version == 0x2050)
-			ucodeflags &= ~BCM43xx_UCODEFLAG_UNKGPHY;
-	}
-
-	if (ucodeflags != bcm43xx_shm_read32(bcm, BCM43xx_SHM_SHARED,
-					     BCM43xx_UCODEFLAGS_OFFSET)) {
-		bcm43xx_shm_write32(bcm, BCM43xx_SHM_SHARED,
-				    BCM43xx_UCODEFLAGS_OFFSET, ucodeflags);
+			core->index = current_core;
+		}
 	}
 
-	/* Short/Long Retry Limit.
-	 * The retry-limit is a 4-bit counter. Enforce this to avoid overflowing
-	 * the chip-internal counter.
-	 */
-	limit = limit_value(modparam_short_retry, 0, 0xF);
-	bcm43xx_shm_write32(bcm, BCM43xx_SHM_WIRELESS, 0x0006, limit);
-	limit = limit_value(modparam_long_retry, 0, 0xF);
-	bcm43xx_shm_write32(bcm, BCM43xx_SHM_WIRELESS, 0x0007, limit);
-
-	bcm43xx_shm_write16(bcm, BCM43xx_SHM_SHARED, 0x0044, 3);
-	bcm43xx_shm_write16(bcm, BCM43xx_SHM_SHARED, 0x0046, 2);
-
-	bcm43xx_rate_memory_init(bcm);
-
-	/* Minimum Contention Window */
-	if (phy->type == BCM43xx_PHYTYPE_B)
-		bcm43xx_shm_write32(bcm, BCM43xx_SHM_WIRELESS, 0x0003, 0x0000001f);
-	else
-		bcm43xx_shm_write32(bcm, BCM43xx_SHM_WIRELESS, 0x0003, 0x0000000f);
-	/* Maximum Contention Window */
-	bcm43xx_shm_write32(bcm, BCM43xx_SHM_WIRELESS, 0x0004, 0x000003ff);
-
-	bcm43xx_write_mac_bssid_templates(bcm);
-
-	if (bcm->current_core->rev >= 5)
-		bcm43xx_write16(bcm, 0x043C, 0x000C);
-
-	if (bcm43xx_using_pio(bcm))
-		err = bcm43xx_pio_init(bcm);
-	else
-		err = bcm43xx_dma_init(bcm);
-	if (err)
-		goto err_chip_cleanup;
-	bcm43xx_write16(bcm, 0x0612, 0x0050);
-	bcm43xx_shm_write16(bcm, BCM43xx_SHM_SHARED, 0x0416, 0x0050);
-	bcm43xx_shm_write16(bcm, BCM43xx_SHM_SHARED, 0x0414, 0x01F4);
+	if (!bcm->core_80211[0].available) {
+		printk(KERN_ERR PFX "Error: No 80211 core found!\n");
+		err = -ENODEV;
+		goto out;
+	}
 
-	bcm43xx_mac_enable(bcm);
-	bcm43xx_interrupt_enable(bcm, bcm->irq_savedstate);
+	err = bcm43xx_switch_core(bcm, &bcm->core_80211[0]);
 
-	bcm->current_core->initialized = 1;
+	assert(err == 0);
 out:
 	return err;
-
-err_chip_cleanup:
-	bcm43xx_chip_cleanup(bcm);
-	goto out;
 }
 
 static int bcm43xx_chipset_attach(struct bcm43xx_private *bcm)
@@ -3151,167 +3372,6 @@
 	return err;
 }
 
-static void bcm43xx_periodic_every120sec(struct bcm43xx_private *bcm)
-{
-	struct bcm43xx_phyinfo *phy = bcm43xx_current_phy(bcm);
-
-	if (phy->type != BCM43xx_PHYTYPE_G || phy->rev < 2)
-		return;
-
-	bcm43xx_mac_suspend(bcm);
-	bcm43xx_phy_lo_g_measure(bcm);
-	bcm43xx_mac_enable(bcm);
-}
-
-static void bcm43xx_periodic_every60sec(struct bcm43xx_private *bcm)
-{
-	bcm43xx_phy_lo_mark_all_unused(bcm);
-	if (bcm->sprom.boardflags & BCM43xx_BFL_RSSI) {
-		bcm43xx_mac_suspend(bcm);
-		bcm43xx_calc_nrssi_slope(bcm);
-		bcm43xx_mac_enable(bcm);
-	}
-}
-
-static void bcm43xx_periodic_every30sec(struct bcm43xx_private *bcm)
-{
-	/* Update device statistics. */
-	bcm43xx_calculate_link_quality(bcm);
-}
-
-static void bcm43xx_periodic_every15sec(struct bcm43xx_private *bcm)
-{
-	struct bcm43xx_phyinfo *phy = bcm43xx_current_phy(bcm);
-	struct bcm43xx_radioinfo *radio = bcm43xx_current_radio(bcm);
-
-	if (phy->type == BCM43xx_PHYTYPE_G) {
-		//TODO: update_aci_moving_average
-		if (radio->aci_enable && radio->aci_wlan_automatic) {
-			bcm43xx_mac_suspend(bcm);
-			if (!radio->aci_enable && 1 /*TODO: not scanning? */) {
-				if (0 /*TODO: bunch of conditions*/) {
-					bcm43xx_radio_set_interference_mitigation(bcm,
-										  BCM43xx_RADIO_INTERFMODE_MANUALWLAN);
-				}
-			} else if (1/*TODO*/) {
-				/*
-				if ((aci_average > 1000) && !(bcm43xx_radio_aci_scan(bcm))) {
-					bcm43xx_radio_set_interference_mitigation(bcm,
-										  BCM43xx_RADIO_INTERFMODE_NONE);
-				}
-				*/
-			}
-			bcm43xx_mac_enable(bcm);
-		} else if (radio->interfmode == BCM43xx_RADIO_INTERFMODE_NONWLAN &&
-			   phy->rev == 1) {
-			//TODO: implement rev1 workaround
-		}
-	}
-	bcm43xx_phy_xmitpower(bcm); //FIXME: unless scanning?
-	//TODO for APHY (temperature?)
-}
-
-static void do_periodic_work(struct bcm43xx_private *bcm)
-{
-	unsigned int state;
-
-	state = bcm->periodic_state;
-	if (state % 8 == 0)
-		bcm43xx_periodic_every120sec(bcm);
-	if (state % 4 == 0)
-		bcm43xx_periodic_every60sec(bcm);
-	if (state % 2 == 0)
-		bcm43xx_periodic_every30sec(bcm);
-	if (state % 1 == 0)
-		bcm43xx_periodic_every15sec(bcm);
-	bcm->periodic_state = state + 1;
-
-	schedule_delayed_work(&bcm->periodic_work, HZ * 15);
-}
-
-/* Estimate a "Badness" value based on the periodic work
- * state-machine state. "Badness" is worse (bigger), if the
- * periodic work will take longer.
- */
-static int estimate_periodic_work_badness(unsigned int state)
-{
-	int badness = 0;
-
-	if (state % 8 == 0) /* every 120 sec */
-		badness += 10;
-	if (state % 4 == 0) /* every 60 sec */
-		badness += 5;
-	if (state % 2 == 0) /* every 30 sec */
-		badness += 1;
-	if (state % 1 == 0) /* every 15 sec */
-		badness += 1;
-
-#define BADNESS_LIMIT	4
-	return badness;
-}
-
-static void bcm43xx_periodic_work_handler(void *d)
-{
-	struct bcm43xx_private *bcm = d;
-	unsigned long flags;
-	u32 savedirqs = 0;
-	int badness;
-
-	badness = estimate_periodic_work_badness(bcm->periodic_state);
-	if (badness > BADNESS_LIMIT) {
-		/* Periodic work will take a long time, so we want it to
-		 * be preemtible.
-		 */
-		netif_stop_queue(bcm->net_dev);
-		synchronize_net();
-		spin_lock_irqsave(&bcm->irq_lock, flags);
-		bcm43xx_mac_suspend(bcm);
-		if (bcm43xx_using_pio(bcm))
-			bcm43xx_pio_freeze_txqueues(bcm);
-		savedirqs = bcm43xx_interrupt_disable(bcm, BCM43xx_IRQ_ALL);
-		spin_unlock_irqrestore(&bcm->irq_lock, flags);
-		mutex_lock(&bcm->mutex);
-		bcm43xx_synchronize_irq(bcm);
-	} else {
-		/* Periodic work should take short time, so we want low
-		 * locking overhead.
-		 */
-		mutex_lock(&bcm->mutex);
-		spin_lock_irqsave(&bcm->irq_lock, flags);
-	}
-
-	do_periodic_work(bcm);
-
-	if (badness > BADNESS_LIMIT) {
-		spin_lock_irqsave(&bcm->irq_lock, flags);
-		if (likely(bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED)) {
-			tasklet_enable(&bcm->isr_tasklet);
-			bcm43xx_interrupt_enable(bcm, savedirqs);
-			if (bcm43xx_using_pio(bcm))
-				bcm43xx_pio_thaw_txqueues(bcm);
-			bcm43xx_mac_enable(bcm);
-		}
-		netif_wake_queue(bcm->net_dev);
-	}
-	mmiowb();
-	spin_unlock_irqrestore(&bcm->irq_lock, flags);
-	mutex_unlock(&bcm->mutex);
-}
-
-static void bcm43xx_periodic_tasks_delete(struct bcm43xx_private *bcm)
-{
-	cancel_rearming_delayed_work(&bcm->periodic_work);
-}
-
-static void bcm43xx_periodic_tasks_setup(struct bcm43xx_private *bcm)
-{
-	struct work_struct *work = &(bcm->periodic_work);
-
-	assert(bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED);
-	INIT_WORK(work, bcm43xx_periodic_work_handler, bcm);
-	schedule_work(work);
-}
-
 static void bcm43xx_free_modes(struct bcm43xx_private *bcm)
 {
 	struct ieee80211_hw *ieee = bcm->ieee;
@@ -3331,7 +3391,9 @@
 			       int nr_channels,
 			       const struct ieee80211_channel *channels,
 			       int nr_rates,
-			       const struct ieee80211_rate *rates)
+			       const struct ieee80211_rate *rates,
+			       int nr_rates2,
+			       const struct ieee80211_rate *rates2)
 {
 	struct ieee80211_hw_modes *mode;
 	int err = -ENOMEM;
@@ -3340,609 +3402,87 @@
 
 	mode->mode = mode_id;
 	mode->num_channels = nr_channels;
-	mode->channels = kzalloc(sizeof(*channels) * nr_channels, GFP_KERNEL);
-	if (!mode->channels)
-		goto out;
-	memcpy(mode->channels, channels, sizeof(*channels) * nr_channels);
-
-	mode->num_rates = nr_rates;
-	mode->rates = kzalloc(sizeof(*rates) * nr_rates, GFP_KERNEL);
-	if (!mode->rates)
-		goto err_free_channels;
-	memcpy(mode->rates, rates, sizeof(*rates) * nr_rates);
-
-	ieee->num_modes++;
-	err = 0;
-out:
-	return err;
-
-err_free_channels:
-	kfree(mode->channels);
-	goto out;
-}
-
-static int bcm43xx_setup_modes_aphy(struct bcm43xx_private *bcm)
-{
-	int err = 0;
-
-	static const struct ieee80211_rate rates[] = {
-		{
-			.rate	= 60,
-			.val	= BCM43xx_OFDM_RATE_6MB,
-			.flags	= IEEE80211_RATE_OFDM,
-			.val2	= BCM43xx_OFDM_RATE_6MB,
-		}, {
-			.rate	= 90,
-			.val	= BCM43xx_OFDM_RATE_9MB,
-			.flags	= IEEE80211_RATE_OFDM,
-			.val2	= BCM43xx_OFDM_RATE_9MB,
-		}, {
-			.rate	= 120,
-			.val	= BCM43xx_OFDM_RATE_12MB,
-			.flags	= IEEE80211_RATE_OFDM,
-			.val2	= BCM43xx_OFDM_RATE_12MB,
-		}, {
-			.rate	= 180,
-			.val	= BCM43xx_OFDM_RATE_18MB,
-			.flags	= IEEE80211_RATE_OFDM,
-			.val2	= BCM43xx_OFDM_RATE_18MB,
-		}, {
-			.rate	= 240,
-			.val	= BCM43xx_OFDM_RATE_24MB,
-			.flags	= IEEE80211_RATE_OFDM,
-			.val2	= BCM43xx_OFDM_RATE_24MB,
-		}, {
-			.rate	= 360,
-			.val	= BCM43xx_OFDM_RATE_36MB,
-			.flags	= IEEE80211_RATE_OFDM,
-			.val2	= BCM43xx_OFDM_RATE_36MB,
-		}, {
-			.rate	= 480,
-			.val	= BCM43xx_OFDM_RATE_48MB,
-			.flags	= IEEE80211_RATE_OFDM,
-			.val2	= BCM43xx_OFDM_RATE_48MB,
-		}, {
-			.rate	= 540,
-			.val	= BCM43xx_OFDM_RATE_54MB,
-			.flags	= IEEE80211_RATE_OFDM,
-			.val2	= BCM43xx_OFDM_RATE_54MB,
-		},
-	};
-	static const struct ieee80211_channel channels[] = {
-		{
-			.chan		= 36,
-			.freq		= 5180,
-			.val		= 36,
-			.flag		= IEEE80211_CHAN_W_SCAN |
-					  IEEE80211_CHAN_W_ACTIVE_SCAN |
-					  IEEE80211_CHAN_W_IBSS,
-			.power_level	= 0xFF,
-			.antenna_max	= 0xFF,
-		}, {
-			.chan		= 40,
-			.freq		= 5200,
-			.val		= 40,
-			.flag		= IEEE80211_CHAN_W_SCAN |
-					  IEEE80211_CHAN_W_ACTIVE_SCAN |
-					  IEEE80211_CHAN_W_IBSS,
-			.power_level	= 0xFF,
-			.antenna_max	= 0xFF,
-		}, {
-			.chan		= 44,
-			.freq		= 5220,
-			.val		= 44,
-			.flag		= IEEE80211_CHAN_W_SCAN |
-					  IEEE80211_CHAN_W_ACTIVE_SCAN |
-					  IEEE80211_CHAN_W_IBSS,
-			.power_level	= 0xFF,
-			.antenna_max	= 0xFF,
-		}, {
-			.chan		= 48,
-			.freq		= 5240,
-			.val		= 48,
-			.flag		= IEEE80211_CHAN_W_SCAN |
-					  IEEE80211_CHAN_W_ACTIVE_SCAN |
-					  IEEE80211_CHAN_W_IBSS,
-			.power_level	= 0xFF,
-			.antenna_max	= 0xFF,
-		}, {
-			.chan		= 52,
-			.freq		= 5260,
-			.val		= 52,
-			.flag		= IEEE80211_CHAN_W_SCAN |
-					  IEEE80211_CHAN_W_ACTIVE_SCAN |
-					  IEEE80211_CHAN_W_IBSS,
-			.power_level	= 0xFF,
-			.antenna_max	= 0xFF,
-		}, {
-			.chan		= 56,
-			.freq		= 5280,
-			.val		= 56,
-			.flag		= IEEE80211_CHAN_W_SCAN |
-					  IEEE80211_CHAN_W_ACTIVE_SCAN |
-					  IEEE80211_CHAN_W_IBSS,
-			.power_level	= 0xFF,
-			.antenna_max	= 0xFF,
-		}, {
-			.chan		= 60,
-			.freq		= 5300,
-			.val		= 60,
-			.flag		= IEEE80211_CHAN_W_SCAN |
-					  IEEE80211_CHAN_W_ACTIVE_SCAN |
-					  IEEE80211_CHAN_W_IBSS,
-			.power_level	= 0xFF,
-			.antenna_max	= 0xFF,
-		}, {
-			.chan		= 64,
-			.freq		= 5320,
-			.val		= 64,
-			.flag		= IEEE80211_CHAN_W_SCAN |
-					  IEEE80211_CHAN_W_ACTIVE_SCAN |
-					  IEEE80211_CHAN_W_IBSS,
-			.power_level	= 0xFF,
-			.antenna_max	= 0xFF,
-		}, {
-			.chan		= 149,
-			.freq		= 5745,
-			.val		= 149,
-			.flag		= IEEE80211_CHAN_W_SCAN |
-					  IEEE80211_CHAN_W_ACTIVE_SCAN |
-					  IEEE80211_CHAN_W_IBSS,
-			.power_level	= 0xFF,
-			.antenna_max	= 0xFF,
-		}, {
-			.chan		= 153,
-			.freq		= 5765,
-			.val		= 153,
-			.flag		= IEEE80211_CHAN_W_SCAN |
-					  IEEE80211_CHAN_W_ACTIVE_SCAN |
-					  IEEE80211_CHAN_W_IBSS,
-			.power_level	= 0xFF,
-			.antenna_max	= 0xFF,
-		}, {
-			.chan		= 157,
-			.freq		= 5785,
-			.val		= 157,
-			.flag		= IEEE80211_CHAN_W_SCAN |
-					  IEEE80211_CHAN_W_ACTIVE_SCAN |
-					  IEEE80211_CHAN_W_IBSS,
-			.power_level	= 0xFF,
-			.antenna_max	= 0xFF,
-		}, {
-			.chan		= 161,
-			.freq		= 5805,
-			.val		= 161,
-			.flag		= IEEE80211_CHAN_W_SCAN |
-					  IEEE80211_CHAN_W_ACTIVE_SCAN |
-					  IEEE80211_CHAN_W_IBSS,
-			.power_level	= 0xFF,
-			.antenna_max	= 0xFF,
-		}, {
-			.chan		= 165,
-			.freq		= 5825,
-			.val		= 165,
-			.flag		= IEEE80211_CHAN_W_SCAN |
-					  IEEE80211_CHAN_W_ACTIVE_SCAN |
-					  IEEE80211_CHAN_W_IBSS,
-			.power_level	= 0xFF,
-			.antenna_max	= 0xFF,
-		},
-	};
-
-	if (bcm43xx_current_phy(bcm)->type == BCM43xx_PHYTYPE_A) {
-		err = bcm43xx_append_mode(bcm->ieee, MODE_IEEE80211A,
-					  ARRAY_SIZE(channels), channels,
-					  ARRAY_SIZE(rates), rates);
-	}
-
-	return err;
-}
-
-static int bcm43xx_setup_modes_bphy(struct bcm43xx_private *bcm)
-{
-	int err = 0;
-
-	static const struct ieee80211_rate rates[] = {
-		{
-			.rate	= 10,
-			.val	= BCM43xx_CCK_RATE_1MB,
-			.flags	= IEEE80211_RATE_CCK,
-			.val2	= BCM43xx_CCK_RATE_1MB,
-		}, {
-			.rate	= 20,
-			.val	= BCM43xx_CCK_RATE_2MB,
-			.flags	= IEEE80211_RATE_CCK_2,
-			.val2	= BCM43xx_CCK_RATE_2MB,
-		}, {
-			.rate	= 55,
-			.val	= BCM43xx_CCK_RATE_5MB,
-			.flags	= IEEE80211_RATE_CCK_2,
-			.val2	= BCM43xx_CCK_RATE_5MB,
-		}, {
-			.rate	= 110,
-			.val	= BCM43xx_CCK_RATE_11MB,
-			.flags	= IEEE80211_RATE_CCK_2,
-			.val2	= BCM43xx_CCK_RATE_11MB,
-		},
-	};
-	static const struct ieee80211_channel channels[] = {
-		{
-			.chan		= 1,
-			.freq		= 2412,
-			.val		= 1,
-			.flag		= IEEE80211_CHAN_W_SCAN |
-					  IEEE80211_CHAN_W_ACTIVE_SCAN |
-					  IEEE80211_CHAN_W_IBSS,
-			.power_level	= 0xFF,
-			.antenna_max	= 0xFF,
-		}, {
-			.chan		= 2,
-			.freq		= 2417,
-			.val		= 2,
-			.flag		= IEEE80211_CHAN_W_SCAN |
-					  IEEE80211_CHAN_W_ACTIVE_SCAN |
-					  IEEE80211_CHAN_W_IBSS,
-			.power_level	= 0xFF,
-			.antenna_max	= 0xFF,
-		}, {
-			.chan		= 3,
-			.freq		= 2422,
-			.val		= 3,
-			.flag		= IEEE80211_CHAN_W_SCAN |
-					  IEEE80211_CHAN_W_ACTIVE_SCAN |
-					  IEEE80211_CHAN_W_IBSS,
-			.power_level	= 0xFF,
-			.antenna_max	= 0xFF,
-		}, {
-			.chan		= 4,
-			.freq		= 2427,
-			.val		= 4,
-			.flag		= IEEE80211_CHAN_W_SCAN |
-					  IEEE80211_CHAN_W_ACTIVE_SCAN |
-					  IEEE80211_CHAN_W_IBSS,
-			.power_level	= 0xFF,
-			.antenna_max	= 0xFF,
-		}, {
-			.chan		= 5,
-			.freq		= 2432,
-			.val		= 5,
-			.flag		= IEEE80211_CHAN_W_SCAN |
-					  IEEE80211_CHAN_W_ACTIVE_SCAN |
-					  IEEE80211_CHAN_W_IBSS,
-			.power_level	= 0xFF,
-			.antenna_max	= 0xFF,
-		}, {
-			.chan		= 6,
-			.freq		= 2437,
-			.val		= 6,
-			.flag		= IEEE80211_CHAN_W_SCAN |
-					  IEEE80211_CHAN_W_ACTIVE_SCAN |
-					  IEEE80211_CHAN_W_IBSS,
-			.power_level	= 0xFF,
-			.antenna_max	= 0xFF,
-		}, {
-			.chan		= 7,
-			.freq		= 2442,
-			.val		= 7,
-			.flag		= IEEE80211_CHAN_W_SCAN |
-					  IEEE80211_CHAN_W_ACTIVE_SCAN |
-					  IEEE80211_CHAN_W_IBSS,
-			.power_level	= 0xFF,
-			.antenna_max	= 0xFF,
-		}, {
-			.chan		= 8,
-			.freq		= 2447,
-			.val		= 8,
-			.flag		= IEEE80211_CHAN_W_SCAN |
-					  IEEE80211_CHAN_W_ACTIVE_SCAN |
-					  IEEE80211_CHAN_W_IBSS,
-			.power_level	= 0xFF,
-			.antenna_max	= 0xFF,
-		}, {
-			.chan		= 9,
-			.freq		= 2452,
-			.val		= 9,
-			.flag		= IEEE80211_CHAN_W_SCAN |
-					  IEEE80211_CHAN_W_ACTIVE_SCAN |
-					  IEEE80211_CHAN_W_IBSS,
-			.power_level	= 0xFF,
-			.antenna_max	= 0xFF,
-		}, {
-			.chan		= 10,
-			.freq		= 2457,
-			.val		= 10,
-			.flag		= IEEE80211_CHAN_W_SCAN |
-					  IEEE80211_CHAN_W_ACTIVE_SCAN |
-					  IEEE80211_CHAN_W_IBSS,
-			.power_level	= 0xFF,
-			.antenna_max	= 0xFF,
-		}, {
-			.chan		= 11,
-			.freq		= 2462,
-			.val		= 11,
-			.flag		= IEEE80211_CHAN_W_SCAN |
-					  IEEE80211_CHAN_W_ACTIVE_SCAN |
-					  IEEE80211_CHAN_W_IBSS,
-			.power_level	= 0xFF,
-			.antenna_max	= 0xFF,
-		}, {
-			.chan		= 12,
-			.freq		= 2467,
-			.val		= 12,
-			.flag		= IEEE80211_CHAN_W_SCAN |
-					  IEEE80211_CHAN_W_ACTIVE_SCAN |
-					  IEEE80211_CHAN_W_IBSS,
-			.power_level	= 0xFF,
-			.antenna_max	= 0xFF,
-		}, {
-			.chan		= 13,
-			.freq		= 2472,
-			.val		= 13,
-			.flag		= IEEE80211_CHAN_W_SCAN |
-					  IEEE80211_CHAN_W_ACTIVE_SCAN |
-					  IEEE80211_CHAN_W_IBSS,
-			.power_level	= 0xFF,
-			.antenna_max	= 0xFF,
-		}, /*{
-			.chan		= 14,
-			.freq		= 2484,
-			.val		= 14,
-			.flag		= IEEE80211_CHAN_W_SCAN |
-					  IEEE80211_CHAN_W_ACTIVE_SCAN |
-					  IEEE80211_CHAN_W_IBSS,
-			.power_level	= 0xFF,
-			.antenna_max	= 0xFF,
-		},*/
-	};
-
-	if (bcm43xx_current_phy(bcm)->type == BCM43xx_PHYTYPE_B ||
-	    bcm43xx_current_phy(bcm)->type == BCM43xx_PHYTYPE_G) {
-		err = bcm43xx_append_mode(bcm->ieee, MODE_IEEE80211B,
-					  ARRAY_SIZE(channels), channels,
-					  ARRAY_SIZE(rates), rates);
-	}
-
-	return err;
-}
-
-static int bcm43xx_setup_modes_gphy(struct bcm43xx_private *bcm)
-{
-	int err = 0;
-
-	static const struct ieee80211_rate rates[] = {
-		{
-			.rate	= 10,
-			.val	= BCM43xx_CCK_RATE_1MB,
-			.flags	= IEEE80211_RATE_CCK,
-			.val2	= BCM43xx_CCK_RATE_1MB,
-		}, {
-			.rate	= 20,
-			.val	= BCM43xx_CCK_RATE_2MB,
-			.flags	= IEEE80211_RATE_CCK_2,
-			.val2	= BCM43xx_CCK_RATE_2MB,
-		}, {
-			.rate	= 55,
-			.val	= BCM43xx_CCK_RATE_5MB,
-			.flags	= IEEE80211_RATE_CCK_2,
-			.val2	= BCM43xx_CCK_RATE_5MB,
-		}, {
-			.rate	= 60,
-			.val	= BCM43xx_OFDM_RATE_6MB,
-			.flags	= IEEE80211_RATE_OFDM,
-			.val2	= BCM43xx_OFDM_RATE_6MB,
-		}, {
-			.rate	= 90,
-			.val	= BCM43xx_OFDM_RATE_9MB,
-			.flags	= IEEE80211_RATE_OFDM,
-			.val2	= BCM43xx_OFDM_RATE_9MB,
-		}, {
-			.rate	= 110,
-			.val	= BCM43xx_CCK_RATE_11MB,
-			.flags	= IEEE80211_RATE_CCK_2,
-			.val2	= BCM43xx_CCK_RATE_11MB,
-		}, {
-			.rate	= 120,
-			.val	= BCM43xx_OFDM_RATE_12MB,
-			.flags	= IEEE80211_RATE_OFDM,
-			.val2	= BCM43xx_OFDM_RATE_12MB,
-		}, {
-			.rate	= 180,
-			.val	= BCM43xx_OFDM_RATE_18MB,
-			.flags	= IEEE80211_RATE_OFDM,
-			.val2	= BCM43xx_OFDM_RATE_18MB,
-		}, {
-			.rate	= 240,
-			.val	= BCM43xx_OFDM_RATE_24MB,
-			.flags	= IEEE80211_RATE_OFDM,
-			.val2	= BCM43xx_OFDM_RATE_24MB,
-		}, {
-			.rate	= 360,
-			.val	= BCM43xx_OFDM_RATE_36MB,
-			.flags	= IEEE80211_RATE_OFDM,
-			.val2	= BCM43xx_OFDM_RATE_36MB,
-		}, {
-			.rate	= 480,
-			.val	= BCM43xx_OFDM_RATE_48MB,
-			.flags	= IEEE80211_RATE_OFDM,
-			.val2	= BCM43xx_OFDM_RATE_48MB,
-		}, {
-			.rate	= 540,
-			.val	= BCM43xx_OFDM_RATE_54MB,
-			.flags	= IEEE80211_RATE_OFDM,
-			.val2	= BCM43xx_OFDM_RATE_54MB,
-		},
-	};
-	static const struct ieee80211_channel channels[] = {
-		{
-			.chan		= 1,
-			.freq		= 2412,
-			.val		= 1,
-			.flag		= IEEE80211_CHAN_W_SCAN |
-					  IEEE80211_CHAN_W_ACTIVE_SCAN |
-					  IEEE80211_CHAN_W_IBSS,
-			.power_level	= 0xFF,
-			.antenna_max	= 0xFF,
-		}, {
-			.chan		= 2,
-			.freq		= 2417,
-			.val		= 2,
-			.flag		= IEEE80211_CHAN_W_SCAN |
-					  IEEE80211_CHAN_W_ACTIVE_SCAN |
-					  IEEE80211_CHAN_W_IBSS,
-			.power_level	= 0xFF,
-			.antenna_max	= 0xFF,
-		}, {
-			.chan		= 3,
-			.freq		= 2422,
-			.val		= 3,
-			.flag		= IEEE80211_CHAN_W_SCAN |
-					  IEEE80211_CHAN_W_ACTIVE_SCAN |
-					  IEEE80211_CHAN_W_IBSS,
-			.power_level	= 0xFF,
-			.antenna_max	= 0xFF,
-		}, {
-			.chan		= 4,
-			.freq		= 2427,
-			.val		= 4,
-			.flag		= IEEE80211_CHAN_W_SCAN |
-					  IEEE80211_CHAN_W_ACTIVE_SCAN |
-					  IEEE80211_CHAN_W_IBSS,
-			.power_level	= 0xFF,
-			.antenna_max	= 0xFF,
-		}, {
-			.chan		= 5,
-			.freq		= 2432,
-			.val		= 5,
-			.flag		= IEEE80211_CHAN_W_SCAN |
-					  IEEE80211_CHAN_W_ACTIVE_SCAN |
-					  IEEE80211_CHAN_W_IBSS,
-			.power_level	= 0xFF,
-			.antenna_max	= 0xFF,
-		}, {
-			.chan		= 6,
-			.freq		= 2437,
-			.val		= 6,
-			.flag		= IEEE80211_CHAN_W_SCAN |
-					  IEEE80211_CHAN_W_ACTIVE_SCAN |
-					  IEEE80211_CHAN_W_IBSS,
-			.power_level	= 0xFF,
-			.antenna_max	= 0xFF,
-		}, {
-			.chan		= 7,
-			.freq		= 2442,
-			.val		= 7,
-			.flag		= IEEE80211_CHAN_W_SCAN |
-					  IEEE80211_CHAN_W_ACTIVE_SCAN |
-					  IEEE80211_CHAN_W_IBSS,
-			.power_level	= 0xFF,
-			.antenna_max	= 0xFF,
-		}, {
-			.chan		= 8,
-			.freq		= 2447,
-			.val		= 8,
-			.flag		= IEEE80211_CHAN_W_SCAN |
-					  IEEE80211_CHAN_W_ACTIVE_SCAN |
-					  IEEE80211_CHAN_W_IBSS,
-			.power_level	= 0xFF,
-			.antenna_max	= 0xFF,
-		}, {
-			.chan		= 9,
-			.freq		= 2452,
-			.val		= 9,
-			.flag		= IEEE80211_CHAN_W_SCAN |
-					  IEEE80211_CHAN_W_ACTIVE_SCAN |
-					  IEEE80211_CHAN_W_IBSS,
-			.power_level	= 0xFF,
-			.antenna_max	= 0xFF,
-		}, {
-			.chan		= 10,
-			.freq		= 2457,
-			.val		= 10,
-			.flag		= IEEE80211_CHAN_W_SCAN |
-					  IEEE80211_CHAN_W_ACTIVE_SCAN |
-					  IEEE80211_CHAN_W_IBSS,
-			.power_level	= 0xFF,
-			.antenna_max	= 0xFF,
-		}, {
-			.chan		= 11,
-			.freq		= 2462,
-			.val		= 11,
-			.flag		= IEEE80211_CHAN_W_SCAN |
-					  IEEE80211_CHAN_W_ACTIVE_SCAN |
-					  IEEE80211_CHAN_W_IBSS,
-			.power_level	= 0xFF,
-			.antenna_max	= 0xFF,
-		}, {
-			.chan		= 12,
-			.freq		= 2467,
-			.val		= 12,
-			.flag		= IEEE80211_CHAN_W_SCAN |
-					  IEEE80211_CHAN_W_ACTIVE_SCAN |
-					  IEEE80211_CHAN_W_IBSS,
-			.power_level	= 0xFF,
-			.antenna_max	= 0xFF,
-		}, {
-			.chan		= 13,
-			.freq		= 2472,
-			.val		= 13,
-			.flag		= IEEE80211_CHAN_W_SCAN |
-					  IEEE80211_CHAN_W_ACTIVE_SCAN |
-					  IEEE80211_CHAN_W_IBSS,
-			.power_level	= 0xFF,
-			.antenna_max	= 0xFF,
-		}, /*{
-			.chan		= 14,
-			.freq		= 2484,
-			.val		= 14,
-			.flag		= IEEE80211_CHAN_W_SCAN |
-					  IEEE80211_CHAN_W_ACTIVE_SCAN |
-					  IEEE80211_CHAN_W_IBSS,
-			.power_level	= 0xFF,
-			.antenna_max	= 0xFF,
-		},*/
-	};
+	mode->channels = kzalloc(sizeof(*channels) * nr_channels, GFP_KERNEL);
+	if (!mode->channels)
+		goto out;
+	memcpy(mode->channels, channels, sizeof(*channels) * nr_channels);
 
-	if (bcm43xx_current_phy(bcm)->type == BCM43xx_PHYTYPE_G) {
-		err = bcm43xx_append_mode(bcm->ieee, MODE_IEEE80211G,
-					  ARRAY_SIZE(channels), channels,
-					  ARRAY_SIZE(rates), rates);
+	mode->num_rates = nr_rates;
+	mode->rates = kzalloc(sizeof(*rates) * (nr_rates + nr_rates2),
+			      GFP_KERNEL);
+	if (!mode->rates)
+		goto err_free_channels;
+	memcpy(mode->rates, rates, sizeof(*rates) * nr_rates);
+	if (nr_rates2) {
+		mode->num_rates += nr_rates2;
+		memcpy(mode->rates + nr_rates, rates2,
+		       sizeof(*rates2) * nr_rates2);
 	}
 
+	ieee->num_modes++;
+	err = 0;
+out:
 	return err;
+
+err_free_channels:
+	kfree(mode->channels);
+	goto out;
 }
 
 static int bcm43xx_setup_modes(struct bcm43xx_private *bcm)
 {
-	struct bcm43xx_phyinfo *phy = bcm43xx_current_phy(bcm);
 	int err = -ENOMEM;
-	int nr;
 	struct ieee80211_hw *ieee = bcm->ieee;
-
-	if (phy->type == BCM43xx_PHYTYPE_A)
-		nr = 1;
-	else if (phy->type == BCM43xx_PHYTYPE_B)
-		nr = 1;
-	else
-		nr = 2;
-	ieee->modes = kzalloc(sizeof(*(ieee->modes)) * nr, GFP_KERNEL);
+	struct bcm43xx_coreinfo *core;
+	struct bcm43xx_coreinfo_80211 *wlext;
+	int i, nr_modes;
+
+	nr_modes = bcm->nr_80211_available;
+	ieee->modes = kzalloc(sizeof(*(ieee->modes)) * nr_modes,
+			      GFP_KERNEL);
 	if (!ieee->modes)
 		goto out;
 	ieee->num_modes = 0;
 
-	err = bcm43xx_setup_modes_aphy(bcm);
-	if (err)
-		goto error;
-	err = bcm43xx_setup_modes_gphy(bcm);
-	if (err)
-		goto error;
-	err = bcm43xx_setup_modes_bphy(bcm);
-	if (err)
-		goto error;
+	for (i = 0; i < bcm->nr_80211_available; i++) {
+		core = &(bcm->core_80211[i]);
+		wlext = core->priv;
 
-	assert(ieee->num_modes == nr && nr > 0);
+		switch (wlext->phy.type) {
+		case BCM43xx_PHYTYPE_A:
+			err = bcm43xx_append_mode(bcm->ieee, MODE_IEEE80211A,
+						  ARRAY_SIZE(bcm43xx_a_chantable),
+						  bcm43xx_a_chantable,
+						  ARRAY_SIZE(bcm43xx_ofdm_ratetable),
+						  bcm43xx_ofdm_ratetable,
+						  0, NULL);
+			break;
+		case BCM43xx_PHYTYPE_B:
+			err = bcm43xx_append_mode(bcm->ieee, MODE_IEEE80211B,
+						  ARRAY_SIZE(bcm43xx_bg_chantable),
+						  bcm43xx_bg_chantable,
+						  ARRAY_SIZE(bcm43xx_cck_ratetable),
+						  bcm43xx_cck_ratetable,
+						  0, NULL);
+			break;
+		case BCM43xx_PHYTYPE_G:
+			err = bcm43xx_append_mode(bcm->ieee, MODE_IEEE80211G,
+						  ARRAY_SIZE(bcm43xx_bg_chantable),
+						  bcm43xx_bg_chantable,
+						  ARRAY_SIZE(bcm43xx_ofdm_ratetable),
+						  bcm43xx_ofdm_ratetable,
+						  ARRAY_SIZE(bcm43xx_cck_ratetable),
+						  bcm43xx_cck_ratetable);
+			break;
+		default:
+			err = 0;
+			assert(0);
+		}
+		if (err)
+			goto error;
+	}
 out:
 	return err;
-
 error:
 	bcm43xx_free_modes(bcm);
 	goto out;
@@ -3955,99 +3495,222 @@
 	bcm43xx_clear_keys(bcm);
 }
 
-/* This is the opposite of bcm43xx_init_board() */
-static void bcm43xx_free_board(struct bcm43xx_private *bcm)
+static void prepare_phydata_for_init(struct bcm43xx_phyinfo *phy)
 {
-	int i, err;
+	phy->antenna_diversity = 0xFFFF;
+	memset(phy->minlowsig, 0xFF, sizeof(phy->minlowsig));
+	memset(phy->minlowsigpos, 0, sizeof(phy->minlowsigpos));
 
-	mutex_lock(&bcm->mutex);
-	bcm43xx_sysfs_unregister(bcm);
-	bcm43xx_periodic_tasks_delete(bcm);
+	/* Flags */
+	phy->calibrated = 0;
+	phy->is_locked = 0;
 
-	bcm43xx_set_status(bcm, BCM43xx_STAT_SHUTTINGDOWN);
+	if (phy->_lo_pairs) {
+		memset(phy->_lo_pairs, 0,
+		       sizeof(struct bcm43xx_lopair) * BCM43xx_LO_COUNT);
+	}
+	memset(phy->loopback_gain, 0, sizeof(phy->loopback_gain));
+}
+
+static void prepare_radiodata_for_init(struct bcm43xx_private *bcm,
+				       struct bcm43xx_radioinfo *radio)
+{
+	int i;
+
+	/* Set default attenuation values. */
+	radio->baseband_atten = bcm43xx_default_baseband_attenuation(bcm);
+	radio->radio_atten = bcm43xx_default_radio_attenuation(bcm);
+	radio->txctl1 = bcm43xx_default_txctl1(bcm);
+	radio->txctl2 = 0xFFFF;
+	radio->txpwr_offset = 0;
+
+	/* NRSSI */
+	radio->nrssislope = 0;
+	for (i = 0; i < ARRAY_SIZE(radio->nrssi); i++)
+		radio->nrssi[i] = -1000;
+	for (i = 0; i < ARRAY_SIZE(radio->nrssi_lt); i++)
+		radio->nrssi_lt[i] = i;
+
+	radio->lofcal = 0xFFFF;
+	radio->initval = 0xFFFF;
+
+	radio->aci_enable = 0;
+	radio->aci_wlan_automatic = 0;
+	radio->aci_hw_rssi = 0;
+}
+
+static void prepare_priv_for_init(struct bcm43xx_private *bcm)
+{
+	int i;
+	struct bcm43xx_coreinfo *core;
+	struct bcm43xx_coreinfo_80211 *wlext;
+
+	assert(!bcm->active_80211_core);
+
+	bcm43xx_set_status(bcm, BCM43xx_STAT_INITIALIZING);
 
+	/* Flags */
+	bcm->was_initialized = 0;
+	bcm->reg124_set_0x4 = 0;
+
+	/* Stats */
+	memset(&bcm->stats, 0, sizeof(bcm->stats));
+
+	/* Wireless core data */
 	for (i = 0; i < BCM43xx_MAX_80211_CORES; i++) {
-		if (!bcm->core_80211[i].available)
-			continue;
-		if (!bcm->core_80211[i].initialized)
+		core = &(bcm->core_80211[i]);
+		wlext = core->priv;
+
+		if (!core->available)
 			continue;
+		assert(wlext == &(bcm->core_80211_ext[i]));
 
-		err = bcm43xx_switch_core(bcm, &bcm->core_80211[i]);
-		assert(err == 0);
-		bcm43xx_wireless_core_cleanup(bcm);
+		prepare_phydata_for_init(&wlext->phy);
+		prepare_radiodata_for_init(bcm, &wlext->radio);
 	}
 
-	bcm43xx_pctl_set_crystal(bcm, 0);
-	bcm43xx_free_modes(bcm);
+	/* IRQ related flags */
+	bcm->irq_reason = 0;
+	memset(bcm->dma_reason, 0, sizeof(bcm->dma_reason));
+	bcm->irq_savedstate = BCM43xx_IRQ_INITIAL;
 
-	bcm43xx_set_status(bcm, BCM43xx_STAT_UNINIT);
-	mutex_unlock(&bcm->mutex);
+	bcm->mac_suspended = 1;
+
+	/* Noise calculation context */
+	memset(&bcm->noisecalc, 0, sizeof(bcm->noisecalc));
+
+	/* Periodic work context */
+	bcm->periodic_state = 0;
 }
 
-static int bcm43xx_init_board(struct bcm43xx_private *bcm)
+static int wireless_core_up(struct bcm43xx_private *bcm,
+			    int active_wlcore)
+{
+	int err;
+
+	if (!bcm43xx_core_enabled(bcm))
+		bcm43xx_wireless_core_reset(bcm, 1);
+	if (!active_wlcore)
+		bcm43xx_wireless_core_mark_inactive(bcm);
+	err = bcm43xx_wireless_core_init(bcm, active_wlcore);
+	if (err)
+		goto out;
+	if (!active_wlcore)
+		bcm43xx_radio_turn_off(bcm);
+out:
+	return err;
+}
+
+/* Select and enable the "to be used" wireless core.
+ * Locking: bcm->mutex must be aquired before calling this.
+ *          bcm->irq_lock must not be aquired.
+ */
+int bcm43xx_select_wireless_core(struct bcm43xx_private *bcm,
+				 int phytype)
 {
 	int i, err;
-	int connect_phy;
+	struct bcm43xx_coreinfo *active_core = NULL;
+	struct bcm43xx_coreinfo_80211 *active_wlext = NULL;
+	struct bcm43xx_coreinfo *core;
+	struct bcm43xx_coreinfo_80211 *wlext;
+	int adjust_active_sbtmstatelow = 0;
 
 	might_sleep();
 
-	mutex_lock(&bcm->mutex);
-	bcm43xx_set_status(bcm, BCM43xx_STAT_INITIALIZING);
+	if (phytype < 0) {
+		/* If no phytype is requested, select the first core. */
+		assert(bcm->core_80211[0].available);
+		wlext = bcm->core_80211[0].priv;
+		phytype = wlext->phy.type;
+	}
+	/* Find the requested core. */
+	for (i = 0; i < bcm->nr_80211_available; i++) {
+		core = &(bcm->core_80211[i]);
+		wlext = core->priv;
+		if (wlext->phy.type == phytype) {
+			active_core = core;
+			active_wlext = wlext;
+			break;
+		}
+	}
+	if (!active_core)
+		return -ESRCH; /* No such PHYTYPE on this board. */
+
+	if (bcm->active_80211_core) {
+		/* We already selected a wl core in the past.
+		 * So first clean up everything.
+		 */
+		dprintk(KERN_INFO PFX "select_wireless_core: cleanup\n");
+		ieee80211_netif_oper(bcm->net_dev, NETIF_STOP);
+		ieee80211_netif_oper(bcm->net_dev, NETIF_DETACH);
+		bcm43xx_set_status(bcm, BCM43xx_STAT_INITIALIZED);
+		err = bcm43xx_disable_interrupts_sync(bcm);
+		assert(!err);
+		tasklet_enable(&bcm->isr_tasklet);
+		err = bcm43xx_shutdown_all_wireless_cores(bcm);
+		if (err)
+			goto error;
+		/* Ok, everything down, continue to re-initialize. */
+		bcm43xx_set_status(bcm, BCM43xx_STAT_INITIALIZING);
+	}
+
+	/* Reset all data structures. */
+	prepare_priv_for_init(bcm);
 
-	err = bcm43xx_pctl_set_crystal(bcm, 1);
-	if (err)
-		goto out;
-	err = bcm43xx_pctl_init(bcm);
-	if (err)
-		goto err_crystal_off;
 	err = bcm43xx_pctl_set_clock(bcm, BCM43xx_PCTL_CLK_FAST);
 	if (err)
-		goto err_crystal_off;
+		goto error;
 
-	tasklet_enable(&bcm->isr_tasklet);
+	/* Mark all unused cores "inactive". */
 	for (i = 0; i < bcm->nr_80211_available; i++) {
-		err = bcm43xx_switch_core(bcm, &bcm->core_80211[i]);
-		assert(err != -ENODEV);
-		if (err)
-			goto err_80211_unwind;
+		core = &(bcm->core_80211[i]);
+		wlext = core->priv;
 
-		/* Enable the selected wireless core.
-		 * Connect PHY only on the first core.
-		 */
-		if (!bcm43xx_core_enabled(bcm)) {
-			if (bcm->nr_80211_available == 1) {
-				connect_phy = bcm43xx_current_phy(bcm)->connected;
-			} else {
-				if (i == 0)
-					connect_phy = 1;
-				else
-					connect_phy = 0;
-			}
-			bcm43xx_wireless_core_reset(bcm, connect_phy);
+		if (core == active_core)
+			continue;
+		err = bcm43xx_switch_core(bcm, core);
+		if (err) {
+			dprintk(KERN_ERR PFX "Could not switch to inactive "
+					     "802.11 core (%d)\n", err);
+			goto error;
 		}
+		err = wireless_core_up(bcm, 0);
+		if (err) {
+			dprintk(KERN_ERR PFX "core_up for inactive 802.11 core "
+					     "failed (%d)\n", err);
+			goto error;
+		}
+		adjust_active_sbtmstatelow = 1;
+	}
 
-		if (i != 0)
-			bcm43xx_wireless_core_mark_inactive(bcm, &bcm->core_80211[0]);
-
-		err = bcm43xx_wireless_core_init(bcm);
-		if (err)
-			goto err_80211_unwind;
+	/* Now initialize the active 802.11 core. */
+	err = bcm43xx_switch_core(bcm, active_core);
+	if (err) {
+		dprintk(KERN_ERR PFX "Could not switch to active "
+				     "802.11 core (%d)\n", err);
+		goto error;
+	}
+	if (adjust_active_sbtmstatelow &&
+	    active_wlext->phy.type == BCM43xx_PHYTYPE_G) {
+		u32 sbtmstatelow;
 
-		if (i != 0) {
-			bcm43xx_mac_suspend(bcm);
-			bcm43xx_interrupt_disable(bcm, BCM43xx_IRQ_ALL);
-			bcm43xx_radio_turn_off(bcm);
-		}
+		sbtmstatelow = bcm43xx_read32(bcm, BCM43xx_CIR_SBTMSTATELOW);
+		sbtmstatelow |= 0x20000000;
+		bcm43xx_write32(bcm, BCM43xx_CIR_SBTMSTATELOW, sbtmstatelow);
 	}
-	bcm->active_80211_core = &bcm->core_80211[0];
-	if (bcm->nr_80211_available >= 2) {
-		bcm43xx_switch_core(bcm, &bcm->core_80211[0]);
-		bcm43xx_mac_enable(bcm);
+	err = wireless_core_up(bcm, 1);
+	if (err) {
+		dprintk(KERN_ERR PFX "core_up for active 802.11 core "
+				     "failed (%d)\n", err);
+		goto error;
 	}
+	err = bcm43xx_pctl_set_clock(bcm, BCM43xx_PCTL_CLK_DYNAMIC);
+	if (err)
+		goto error;
+	bcm->active_80211_core = active_core;
+
 	bcm43xx_macfilter_clear(bcm, BCM43xx_MACFILTER_ASSOC);
 	bcm43xx_macfilter_set(bcm, BCM43xx_MACFILTER_SELF, (u8 *)(bcm->net_dev->dev_addr));
-	dprintk(KERN_INFO PFX "80211 cores initialized\n");
-	bcm43xx_setup_modes(bcm);
 	bcm43xx_security_init(bcm);
 	bcm43xx_measure_channel_change_time(bcm);
 	ieee80211_update_hw(bcm->net_dev, bcm->ieee);
@@ -4055,37 +3718,59 @@
 	ieee80211_netif_oper(bcm->net_dev, NETIF_START);
 	ieee80211_netif_oper(bcm->net_dev, NETIF_WAKE);
 
-	bcm43xx_pctl_set_clock(bcm, BCM43xx_PCTL_CLK_DYNAMIC);
+	/* Let's go! Be careful after enabling the IRQs.
+	 * Don't switch cores, for example.
+	 */
+	bcm43xx_mac_enable(bcm);
+	bcm43xx_set_status(bcm, BCM43xx_STAT_INITIALIZED);
+	err = bcm43xx_initialize_irq(bcm);
+	if (err)
+		goto error;
+	bcm43xx_interrupt_enable(bcm, bcm->irq_savedstate);
+
+	dprintk(KERN_INFO PFX "Selected 802.11 core (phytype %d)\n",
+		active_wlext->phy.type);
 
-	if (bcm43xx_current_radio(bcm)->initial_channel != 0xFF) {
-		bcm43xx_mac_suspend(bcm);
-		bcm43xx_radio_selectchannel(bcm, bcm43xx_current_radio(bcm)->initial_channel, 0);
-		bcm43xx_mac_enable(bcm);
-	}
+	return 0;
 
-	/* Initialization of the board is done. Flag it as such. */
-	bcm43xx_set_status(bcm, BCM43xx_STAT_INITIALIZED);
+error:
+	bcm43xx_set_status(bcm, BCM43xx_STAT_UNINIT);
+	bcm43xx_pctl_set_clock(bcm, BCM43xx_PCTL_CLK_SLOW);
+	return err;
+}
 
-	bcm43xx_periodic_tasks_setup(bcm);
-	bcm43xx_sysfs_register(bcm);
+static int bcm43xx_init_board(struct bcm43xx_private *bcm)
+{
+	int err;
 
-	assert(err == 0);
+	mutex_lock(&bcm->mutex);
+
+	tasklet_enable(&bcm->isr_tasklet);
+	err = bcm43xx_pctl_set_crystal(bcm, 1);
+	if (err)
+		goto err_tasklet;
+	err = bcm43xx_pctl_init(bcm);
+	if (err)
+		goto err_crystal_off;
+	err = bcm43xx_select_wireless_core(bcm, -1);
+	if (err)
+		goto err_crystal_off;
+
+	bcm43xx_periodic_tasks_setup(bcm);
+	err = bcm43xx_sysfs_register(bcm);
+	if (err)
+		goto err_wlshutdown;
 out:
 	mutex_unlock(&bcm->mutex);
 
 	return err;
 
-err_80211_unwind:
-	tasklet_disable(&bcm->isr_tasklet);
-	/* unwind all 80211 initialization */
-	for (i = 0; i < bcm->nr_80211_available; i++) {
-		if (!bcm->core_80211[i].initialized)
-			continue;
-		bcm43xx_interrupt_disable(bcm, BCM43xx_IRQ_ALL);
-		bcm43xx_wireless_core_cleanup(bcm);
-	}
+err_wlshutdown:
+	bcm43xx_shutdown_all_wireless_cores(bcm);
 err_crystal_off:
 	bcm43xx_pctl_set_crystal(bcm, 0);
+err_tasklet:
+	tasklet_disable(&bcm->isr_tasklet);
 	goto out;
 }
 
@@ -4106,6 +3791,7 @@
 		if (bcm->core_80211_ext[i].phy.dyn_tssi_tbl)
 			kfree(bcm->core_80211_ext[i].phy.tssi2dbm);
 	}
+	bcm43xx_free_modes(bcm);
 }
 
 static int bcm43xx_read_phyinfo(struct bcm43xx_private *bcm)
@@ -4263,6 +3949,7 @@
 		memcpy(bcm->net_dev->dev_addr, bcm->sprom.et1macaddr, 6);
 	else
 		memcpy(bcm->net_dev->dev_addr, bcm->sprom.il0macaddr, 6);
+	bcm43xx_setup_modes(bcm);
 
 	snprintf(bcm->nick, IW_ESSID_MAX_SIZE,
 		 "Broadcom %04X", bcm->chip_id);
@@ -4328,16 +4015,44 @@
 	struct bcm43xx_radioinfo *radio;
 	struct bcm43xx_phyinfo *phy;
 	unsigned long flags;
+	int new_phymode = -1;
+	int new_antennadiv = 0;
+	int err = 0;
 
+	mutex_lock(&bcm->mutex);
 	spin_lock_irqsave(&bcm->irq_lock, flags);
 	if (bcm43xx_status(bcm) != BCM43xx_STAT_INITIALIZED)
 		goto out_unlock;
-	radio = bcm43xx_current_radio(bcm);
 	phy = bcm43xx_current_phy(bcm);
+	radio = bcm43xx_current_radio(bcm);
+
+	/* Switch the PHY mode (if necessary). */
+	switch (conf->phymode) {
+	case MODE_IEEE80211A:
+		new_phymode = BCM43xx_PHYTYPE_A;
+		break;
+	case MODE_IEEE80211B:
+		new_phymode = BCM43xx_PHYTYPE_B;
+		break;
+	case MODE_IEEE80211G:
+		new_phymode = BCM43xx_PHYTYPE_G;
+		break;
+	default:
+		assert(0);
+	}
+	if (phy->type != new_phymode) {
+		err = bcm43xx_select_wireless_core(bcm, new_phymode);
+		if (err)
+			goto out_unlock;
+		phy = bcm43xx_current_phy(bcm);
+		radio = bcm43xx_current_radio(bcm);
+	}
 
-	if (conf->channel != radio->channel)
-		bcm43xx_radio_selectchannel(bcm, conf->channel, 0);
+	/* Switch to the requested channel. */
+	if (conf->channel_val != radio->channel)
+		bcm43xx_radio_selectchannel(bcm, conf->channel_val, 0);
 
+	/* Enable/Disable ShortSlot timing. */
 	if (conf->short_slot_time != bcm->short_slot) {
 		assert(phy->type == BCM43xx_PHYTYPE_G);
 		if (conf->short_slot_time)
@@ -4346,11 +4061,13 @@
 			bcm43xx_short_slot_timing_disable(bcm);
 	}
 
+	/* Adjust the desired TX power level. */
 	if (conf->power_level != 0) {
 		radio->power_level = conf->power_level;
 		bcm43xx_phy_xmitpower(bcm);
 	}
 
+	/* Hide/Show the SSID (AP mode only). */
 	if (conf->ssid_hidden) {
 		bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS_BITFIELD,
 				bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD)
@@ -4361,20 +4078,26 @@
 				& ~BCM43xx_SBF_NO_SSID_BCAST);
 	}
 
-//FIXME: This does not seem to wake up:
-#if 0
-	if (conf->power_level == 0) {
-		if (radio->enabled)
-			bcm43xx_radio_turn_off(bcm);
-	} else {
-		if (!radio->enabled)
-			bcm43xx_radio_turn_on(bcm);
+	/* Select the TX Antenna. */
+	switch (conf->antenna_sel) {
+	case 0: /* default/diversity */
+		new_antennadiv = BCM43xx_RADIO_TXANTENNA_DEFAULT;
+		break;
+	case 1: /* Antenna 0 */
+		new_antennadiv = BCM43xx_RADIO_TXANTENNA_0;
+		break;
+	case 2: /* Antenna 1 */
+		new_antennadiv = BCM43xx_RADIO_TXANTENNA_1;
+		break;
+	default:
+		assert(0);
+	}
+	if (new_antennadiv != phy->antenna_diversity) {
+		phy->antenna_diversity = new_antennadiv;
+		bcm43xx_phy_set_antenna_diversity(bcm);
 	}
-#endif
-
-	//TODO: phymode
-	//TODO: antennas
 
+	/* Update templates for AP mode. */
 	if (bcm43xx_is_mode(bcm, IEEE80211_IF_TYPE_AP)) {
 		bcm43xx_set_beacon_int(bcm, conf->beacon_int);
 		bcm43xx_refresh_templates(bcm);
@@ -4382,8 +4105,9 @@
 
 out_unlock:
 	spin_unlock_irqrestore(&bcm->irq_lock, flags);
+	mutex_unlock(&bcm->mutex);
 
-	return 0;
+	return err;
 }
 
 static int bcm43xx_net_set_key(struct net_device *net_dev,
@@ -4504,7 +4228,8 @@
 	unsigned long flags;
 
 	local_irq_save(flags);
-	bcm43xx_interrupt_handler(bcm->irq, bcm, NULL);
+	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED)
+		bcm43xx_interrupt_handler(bcm->irq, bcm, NULL);
 	local_irq_restore(flags);
 }
 #endif /* CONFIG_NET_POLL_CONTROLLER */
@@ -4522,7 +4247,7 @@
 	int err;
 
 	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED) {
-		err = bcm43xx_disable_interrupts_sync(bcm, NULL);
+		err = bcm43xx_disable_interrupts_sync(bcm);
 		assert(!err);
 		bcm43xx_free_board(bcm);
 	}
@@ -4781,7 +4506,6 @@
 	if (bcm->cached_beacon)
 		kfree_skb(bcm->cached_beacon);
 	bcm->cached_beacon = NULL;
-	assert(bcm->ucode == NULL);
 	ieee80211_free_hw(net_dev);
 	kfree(ieee);
 }
@@ -4792,48 +4516,26 @@
 static void bcm43xx_chip_reset(void *_bcm)
 {
 	struct bcm43xx_private *bcm = _bcm;
-	struct net_device *net_dev = bcm->net_dev;
-	struct pci_dev *pci_dev = bcm->pci_dev;
-	struct ieee80211_hw *ieee = bcm->ieee;
+	struct bcm43xx_phyinfo *phy;
 	int err;
-	int was_initialized = (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED);
-
-	ieee80211_netif_oper(bcm->net_dev, NETIF_DETACH);
-	tasklet_disable(&bcm->isr_tasklet);
 
-	bcm->firmware_norelease = 1;
-	if (was_initialized)
-		bcm43xx_free_board(bcm);
-	bcm->firmware_norelease = 0;
-	bcm43xx_detach_board(bcm);
-	err = bcm43xx_init_private(bcm, net_dev, pci_dev, ieee);
-	if (err)
-		goto failure;
-	err = bcm43xx_attach_board(bcm);
-	if (err)
-		goto failure;
-	if (was_initialized) {
-		err = bcm43xx_init_board(bcm);
-		if (err)
-			goto failure;
-	}
-	ieee80211_netif_oper(bcm->net_dev, NETIF_ATTACH);
-	printk(KERN_INFO PFX "Controller restarted\n");
+	mutex_lock(&bcm->mutex);
+	phy = bcm43xx_current_phy(bcm);
+	err = bcm43xx_select_wireless_core(bcm, phy->type);
+	mutex_unlock(&bcm->mutex);
 
-	return;
-failure:
-	printk(KERN_ERR PFX "Controller restart failed\n");
+	printk("%s" PFX "Controller restart%s\n",
+	       (err == 0) ? KERN_INFO : KERN_ERR,
+	       (err == 0) ? "ed" : " failed");
 }
 
 /* Hard-reset the chip.
  * This can be called from interrupt or process context.
- * Make sure to _not_ re-enable device interrupts after this has been called.
  */
 void bcm43xx_controller_restart(struct bcm43xx_private *bcm, const char *reason)
 {
+	assert(bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED);
 	bcm43xx_set_status(bcm, BCM43xx_STAT_RESTARTING);
-	bcm43xx_interrupt_disable(bcm, BCM43xx_IRQ_ALL);
-	bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD); /* dummy read */
 	printk(KERN_ERR PFX "Controller RESET (%s) ...\n", reason);
 	INIT_WORK(&bcm->restart_work, bcm43xx_chip_reset, bcm);
 	schedule_work(&bcm->restart_work);
@@ -4845,17 +4547,16 @@
 {
 	struct net_device *net_dev = pci_get_drvdata(pdev);
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
-	int try_to_shutdown = 0, err;
+	int err;
 
 	dprintk(KERN_INFO PFX "Suspending...\n");
 
-	bcm->was_initialized = (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED);
-	if (bcm->was_initialized)
-		try_to_shutdown = 1;
-
+	ieee80211_netif_oper(bcm->net_dev, NETIF_STOP);
 	ieee80211_netif_oper(bcm->net_dev, NETIF_DETACH);
-	if (try_to_shutdown) {
-		err = bcm43xx_disable_interrupts_sync(bcm, &bcm->irq_savedstate);
+	bcm->was_initialized = 0;
+	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED) {
+		bcm->was_initialized = 1;
+		err = bcm43xx_disable_interrupts_sync(bcm);
 		if (unlikely(err)) {
 			dprintk(KERN_ERR PFX "Suspend failed.\n");
 			return -EAGAIN;
@@ -4888,16 +4589,14 @@
 	pci_restore_state(pdev);
 
 	bcm43xx_chipset_attach(bcm);
-	if (bcm->was_initialized) {
-		bcm->irq_savedstate = BCM43xx_IRQ_INITIAL;
+	if (bcm->was_initialized)
 		err = bcm43xx_init_board(bcm);
-	}
 	if (err) {
 		printk(KERN_ERR PFX "Resume failed!\n");
 		return err;
 	}
-
 	ieee80211_netif_oper(bcm->net_dev, NETIF_ATTACH);
+	ieee80211_netif_oper(bcm->net_dev, NETIF_WAKE);
 
 	dprintk(KERN_INFO PFX "Device resumed.\n");
 
Index: wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_debugfs.c
===================================================================
--- wireless-dev-dscapeports.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_debugfs.c	2006-07-10 00:41:15.000000000 +0200
+++ wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_debugfs.c	2006-07-10 00:54:11.000000000 +0200
@@ -316,6 +316,42 @@
 	return res;
 }
 
+static ssize_t restart_write_file(struct file *file, const char __user *user_buf,
+				  size_t count, loff_t *ppos)
+{
+	struct bcm43xx_private *bcm = file->private_data;
+	char *buf = really_big_buffer;
+	ssize_t buf_size;
+	ssize_t res;
+	unsigned long flags;
+
+	buf_size = min(count, sizeof (really_big_buffer) - 1);
+	down(&big_buffer_sem);
+	if (copy_from_user(buf, user_buf, buf_size)) {
+	        res = -EFAULT;
+		goto out_up;
+	}
+	mutex_lock(&bcm->mutex);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
+	if (bcm43xx_status(bcm) != BCM43xx_STAT_INITIALIZED) {
+		printk(KERN_INFO PFX "debugfs: Board not initialized.\n");
+		res = -EFAULT;
+		goto out_unlock;
+	}
+	if (count > 0 && buf[0] == '1') {
+		bcm43xx_controller_restart(bcm, "manually restarted");
+		res = count;
+	} else
+		res = -EINVAL;
+
+out_unlock:
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
+	mutex_unlock(&bcm->mutex);
+out_up:
+	up(&big_buffer_sem);
+	return res;
+}
+
 #undef fappend
 
 
@@ -349,6 +385,11 @@
 	.open = open_file_generic,
 };
 
+static struct file_operations restart_fops = {
+	.write = restart_write_file,
+	.open = open_file_generic,
+};
+
 
 void bcm43xx_debugfs_add_device(struct bcm43xx_private *bcm)
 {
@@ -400,6 +441,10 @@
 						bcm, &txstat_fops);
 	if (!e->dentry_txstat)
 		printk(KERN_ERR PFX "debugfs: creating \"tx_status\" for \"%s\" failed!\n", devdir);
+	e->dentry_restart = debugfs_create_file("restart", 0222, e->subdir,
+						bcm, &restart_fops);
+	if (!e->dentry_restart)
+		printk(KERN_ERR PFX "debugfs: creating \"restart\" for \"%s\" failed!\n", devdir);
 }
 
 void bcm43xx_debugfs_remove_device(struct bcm43xx_private *bcm)
@@ -415,6 +460,7 @@
 	debugfs_remove(e->dentry_devinfo);
 	debugfs_remove(e->dentry_tsf);
 	debugfs_remove(e->dentry_txstat);
+	debugfs_remove(e->dentry_restart);
 	debugfs_remove(e->subdir);
 	kfree(e->xmitstatus_buffer);
 	kfree(e->xmitstatus_print_buffer);
Index: wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_debugfs.h
===================================================================
--- wireless-dev-dscapeports.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_debugfs.h	2006-07-10 00:41:15.000000000 +0200
+++ wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_debugfs.h	2006-07-10 00:54:11.000000000 +0200
@@ -20,6 +20,7 @@
 	struct dentry *dentry_spromdump;
 	struct dentry *dentry_tsf;
 	struct dentry *dentry_txstat;
+	struct dentry *dentry_restart;
 
 	struct bcm43xx_private *bcm;
 
Index: wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.h
===================================================================
--- wireless-dev-dscapeports.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.h	2006-07-10 00:41:15.000000000 +0200
+++ wireless-dev-dscapeports/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.h	2006-07-10 00:54:11.000000000 +0200
@@ -152,6 +152,9 @@
 
 int bcm43xx_switch_core(struct bcm43xx_private *bcm, struct bcm43xx_coreinfo *new_core);
 
+int bcm43xx_select_wireless_core(struct bcm43xx_private *bcm,
+				 int phytype);
+
 void bcm43xx_wireless_core_reset(struct bcm43xx_private *bcm, int connect_phy);
 
 void bcm43xx_mac_suspend(struct bcm43xx_private *bcm);

-- 
Greetings Michael.
