From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH, RFT] bcm43xx: init routine rewrite (bugfix)
Date: Sat, 1 Jul 2006 22:14:23 +0200
Message-ID: <200607012214.24335.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stefano Brivio <stefano.brivio@polimi.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:43928
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751015AbWGAUSm
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Jul 2006 16:18:42 -0400
To: bcm43xx-dev@lists.berlios.de
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This patch is a rewrite of the bcm43xx init routine.
It is supposed to fix several issues:
* up-down-up.. sequence stale-data issue
  (This may fix dhclient issues)
* Fix init vs IRQ race.
* Fix init for cards with multiple cores (APHY)
  (untested)
* Fix controller restart breakage.
* Make used wireless core (phymode) selectable at runtime.
* Well, few others. Don't remember :)

--

Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx.h
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx.h	2006-07-01 22:07:00.000000000 +0200
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx.h	2006-07-01 22:08:47.000000000 +0200
@@ -502,6 +502,12 @@
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
 
 
@@ -591,12 +597,14 @@
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
@@ -645,7 +653,10 @@
 	BCM43xx_STAT_RESTARTING,	/* controller_restart() called. */
 };
 #define bcm43xx_status(bcm)		atomic_read(&(bcm)->init_status)
-#define bcm43xx_set_status(bcm, stat)	atomic_set(&(bcm)->init_status, (stat))
+#define bcm43xx_set_status(bcm, stat)	do {			\
+		atomic_set(&(bcm)->init_status, (stat));	\
+		smp_wmb();					\
+					} while (0)
 
 struct bcm43xx_private {
 	struct ieee80211_device *ieee;
@@ -706,10 +717,6 @@
 	struct bcm43xx_coreinfo core_80211[ BCM43xx_MAX_80211_CORES ];
 	/* Additional information, specific to the 80211 cores. */
 	struct bcm43xx_coreinfo_80211 core_80211_ext[ BCM43xx_MAX_80211_CORES ];
-	/* Index of the current 80211 core. If current_core is not
-	 * an 80211 core, this is -1.
-	 */
-	int current_80211_core_idx;
 	/* Number of available 80211 cores. */
 	int nr_80211_available;
 
@@ -744,12 +751,6 @@
 	struct bcm43xx_key key[54];
 	u8 default_key_idx;
 
-	/* Firmware. */
-	const struct firmware *ucode;
-	const struct firmware *pcm;
-	const struct firmware *initvals0;
-	const struct firmware *initvals1;
-
 	/* Debugging stuff follows. */
 #ifdef CONFIG_BCM43XX_DEBUG
 	struct bcm43xx_dfsentry *dfsentry;
@@ -857,34 +858,33 @@
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
 
 
Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-07-01 22:07:00.000000000 +0200
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-07-01 22:08:47.000000000 +0200
@@ -537,7 +537,6 @@
 	u16 manufact;
 	u16 version;
 	u8 revision;
-	s8 i;
 
 	if (bcm->chip_id == 0x4317) {
 		if (bcm->chip_rev == 0x00)
@@ -580,20 +579,11 @@
 	radio->version = version;
 	radio->revision = revision;
 
-	/* Set default attenuation values. */
-	radio->baseband_atten = bcm43xx_default_baseband_attenuation(bcm);
-	radio->radio_atten = bcm43xx_default_radio_attenuation(bcm);
-	radio->txctl1 = bcm43xx_default_txctl1(bcm);
-	radio->txctl2 = 0xFFFF;
 	if (phy->type == BCM43xx_PHYTYPE_A)
 		radio->txpower_desired = bcm->sprom.maxpower_aphy;
 	else
 		radio->txpower_desired = bcm->sprom.maxpower_bgphy;
 
-	/* Initialize the in-memory nrssi Lookup Table. */
-	for (i = 0; i < 64; i++)
-		radio->nrssi_lt[i] = i;
-
 	return 0;
 
 err_unsupported_radio:
@@ -1250,10 +1240,6 @@
 		goto out;
 
 	bcm->current_core = new_core;
-	bcm->current_80211_core_idx = -1;
-	if (new_core->id == BCM43xx_COREID_80211)
-		bcm->current_80211_core_idx = (int)(new_core - &(bcm->core_80211[0]));
-
 out:
 	return err;
 }
@@ -1423,15 +1409,10 @@
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
@@ -1445,21 +1426,6 @@
 	sbtmstatelow |= 0x80000;
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
@@ -1885,14 +1851,8 @@
 
 	spin_lock(&bcm->irq_lock);
 
-	/* Only accept IRQs, if we are initialized properly.
-	 * This avoids an RX race while initializing.
-	 * We should probably not enable IRQs before we are initialized
-	 * completely, but some careful work is needed to fix this. I think it
-	 * is best to stay with this cheap workaround for now... .
-	 */
-	if (unlikely(bcm43xx_status(bcm) != BCM43xx_STAT_INITIALIZED))
-		goto out;
+	assert(bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED);
+	assert(bcm->current_core->id == BCM43xx_COREID_80211);
 
 	reason = bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON);
 	if (reason == 0xffffffff) {
@@ -1930,16 +1890,18 @@
 
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
@@ -1950,11 +1912,11 @@
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
@@ -1963,12 +1925,12 @@
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
@@ -1977,7 +1939,7 @@
 		}
 	}
 
-	if (!bcm->initvals0) {
+	if (!phy->initvals0) {
 		if (rev == 2 || rev == 4) {
 			switch (phy->type) {
 			case BCM43xx_PHYTYPE_A:
@@ -2008,20 +1970,20 @@
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
 
@@ -2043,14 +2005,14 @@
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
@@ -2070,12 +2032,13 @@
 
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
@@ -2084,8 +2047,8 @@
 	}
 
 	/* Upload PCM data. */
-	data = (u32 *)(bcm->pcm->data);
-	len = bcm->pcm->size / sizeof(u32);
+	data = (u32 *)(phy->pcm->data);
+	len = phy->pcm->size / sizeof(u32);
 	bcm43xx_shm_control_word(bcm, BCM43xx_SHM_PCM, 0x01ea);
 	bcm43xx_write32(bcm, BCM43xx_MMIO_SHM_DATA, 0x00004000);
 	bcm43xx_shm_control_word(bcm, BCM43xx_SHM_PCM, 0x01eb);
@@ -2131,15 +2094,16 @@
 
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
@@ -2156,9 +2120,7 @@
 
 static int bcm43xx_initialize_irq(struct bcm43xx_private *bcm)
 {
-	int res;
-	unsigned int i;
-	u32 data;
+	int err;
 
 	bcm->irq = bcm->pci_dev->irq;
 #ifdef CONFIG_BCM947XX
@@ -2175,32 +2137,12 @@
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
@@ -2394,7 +2336,6 @@
 	if (!modparam_noleds)
 		bcm43xx_leds_exit(bcm);
 	bcm43xx_gpio_cleanup(bcm);
-	free_irq(bcm->irq, bcm);
 	bcm43xx_release_firmware(bcm, 0);
 }
 
@@ -2406,7 +2347,7 @@
 	struct bcm43xx_radioinfo *radio = bcm43xx_current_radio(bcm);
 	struct bcm43xx_phyinfo *phy = bcm43xx_current_phy(bcm);
 	int err;
-	int tmp;
+	int i, tmp;
 	u32 value32;
 	u16 value16;
 
@@ -2419,13 +2360,26 @@
 		goto out;
 	bcm43xx_upload_microcode(bcm);
 
-	err = bcm43xx_initialize_irq(bcm);
-	if (err)
-		goto err_release_fw;
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
 
 	err = bcm43xx_gpio_init(bcm);
 	if (err)
-		goto err_free_irq;
+		goto err_release_fw;
 
 	err = bcm43xx_upload_initvals(bcm);
 	if (err)
@@ -2509,8 +2463,6 @@
 	bcm43xx_radio_turn_off(bcm);
 err_gpio_cleanup:
 	bcm43xx_gpio_cleanup(bcm);
-err_free_irq:
-	free_irq(bcm->irq, bcm);
 err_release_fw:
 	bcm43xx_release_firmware(bcm, 1);
 	goto out;
@@ -2550,11 +2502,9 @@
 {
 	/* Initialize a "phyinfo" structure. The structure is already
 	 * zeroed out.
+	 * This is called on insmod time to initialize members.
 	 */
-	phy->antenna_diversity = 0xFFFF;
 	phy->savedpctlreg = 0xFFFF;
-	phy->minlowsig[0] = 0xFFFF;
-	phy->minlowsig[1] = 0xFFFF;
 	spin_lock_init(&phy->lock);
 }
 
@@ -2562,14 +2512,11 @@
 {
 	/* Initialize a "radioinfo" structure. The structure is already
 	 * zeroed out.
+	 * This is called on insmod time to initialize members.
 	 */
 	radio->interfmode = BCM43xx_RADIO_INTERFMODE_NONE;
 	radio->channel = 0xFF;
 	radio->initial_channel = 0xFF;
-	radio->lofcal = 0xFFFF;
-	radio->initval = 0xFFFF;
-	radio->nrssi[0] = -1000;
-	radio->nrssi[1] = -1000;
 }
 
 static int bcm43xx_probe_cores(struct bcm43xx_private *bcm)
@@ -2587,7 +2534,6 @@
 				    * BCM43xx_MAX_80211_CORES);
 	memset(&bcm->core_80211_ext, 0, sizeof(struct bcm43xx_coreinfo_80211)
 					* BCM43xx_MAX_80211_CORES);
-	bcm->current_80211_core_idx = -1;
 	bcm->nr_80211_available = 0;
 	bcm->current_core = NULL;
 	bcm->active_80211_core = NULL;
@@ -2757,6 +2703,7 @@
 				goto out;
 			}
 			bcm->nr_80211_available++;
+			core->priv = ext_80211;
 			bcm43xx_init_struct_phyinfo(&ext_80211->phy);
 			bcm43xx_init_struct_radioinfo(&ext_80211->radio);
 			break;
@@ -2857,7 +2804,8 @@
 }
 
 /* http://bcm-specs.sipsolutions.net/80211Init */
-static int bcm43xx_wireless_core_init(struct bcm43xx_private *bcm)
+static int bcm43xx_wireless_core_init(struct bcm43xx_private *bcm,
+				      int active_wlcore)
 {
 	struct bcm43xx_phyinfo *phy = bcm43xx_current_phy(bcm);
 	struct bcm43xx_radioinfo *radio = bcm43xx_current_radio(bcm);
@@ -2939,19 +2887,26 @@
 	if (bcm->current_core->rev >= 5)
 		bcm43xx_write16(bcm, 0x043C, 0x000C);
 
-	if (bcm43xx_using_pio(bcm))
-		err = bcm43xx_pio_init(bcm);
-	else
-		err = bcm43xx_dma_init(bcm);
-	if (err)
-		goto err_chip_cleanup;
+	if (active_wlcore) {
+		if (bcm43xx_using_pio(bcm))
+			err = bcm43xx_pio_init(bcm);
+		else
+			err = bcm43xx_dma_init(bcm);
+		if (err)
+			goto err_chip_cleanup;
+	}
 	bcm43xx_write16(bcm, 0x0612, 0x0050);
 	bcm43xx_shm_write16(bcm, BCM43xx_SHM_SHARED, 0x0416, 0x0050);
 	bcm43xx_shm_write16(bcm, BCM43xx_SHM_SHARED, 0x0414, 0x01F4);
 
-	bcm43xx_mac_enable(bcm);
-	bcm43xx_interrupt_enable(bcm, bcm->irq_savedstate);
+	if (active_wlcore) {
+		if (radio->initial_channel != 0xFF)
+			bcm43xx_radio_selectchannel(bcm, radio->initial_channel, 0);
+	}
 
+	/* Don't enable MAC/IRQ here, as it will race with the IRQ handler.
+	 * We enable it later.
+	 */
 	bcm->current_core->initialized = 1;
 out:
 	return err;
@@ -3066,11 +3021,6 @@
 	return err;
 }
 
-static void bcm43xx_softmac_init(struct bcm43xx_private *bcm)
-{
-	ieee80211softmac_start(bcm->net_dev);
-}
-
 static void bcm43xx_periodic_every120sec(struct bcm43xx_private *bcm)
 {
 	struct bcm43xx_phyinfo *phy = bcm43xx_current_phy(bcm);
@@ -3238,135 +3188,323 @@
 	bcm43xx_clear_keys(bcm);
 }
 
-/* This is the opposite of bcm43xx_init_board() */
-static void bcm43xx_free_board(struct bcm43xx_private *bcm)
+static int bcm43xx_shutdown_all_wireless_cores(struct bcm43xx_private *bcm)
 {
+	int ret = 0;
 	int i, err;
+	struct bcm43xx_coreinfo *core;
 
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
 	bcm43xx_lock_noirq(bcm);
 	bcm43xx_sysfs_unregister(bcm);
 	bcm43xx_periodic_tasks_delete(bcm);
 
-	bcm43xx_set_status(bcm, BCM43xx_STAT_SHUTTINGDOWN);
+	bcm43xx_shutdown_all_wireless_cores(bcm);
+	bcm43xx_pctl_set_crystal(bcm, 0);
+
+	bcm43xx_unlock_noirq(bcm);
+}
 
+static void prepare_phydata_for_init(struct bcm43xx_phyinfo *phy)
+{
+	phy->antenna_diversity = 0xFFFF;
+	memset(phy->minlowsig, 0xFF, sizeof(phy->minlowsig));
+	memset(phy->minlowsigpos, 0, sizeof(phy->minlowsigpos));
+
+	/* Flags */
+	phy->calibrated = 0;
+	phy->is_locked = 0;
+
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
+	bcm43xx_set_status(bcm, BCM43xx_STAT_INITIALIZING);
+
+	/* Flags */
+	bcm->was_initialized = 0;
+	bcm->reg124_set_0x4 = 0;
+	bcm->firmware_norelease = 0;
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
+	/* IRQ related flags */
+	bcm->irq_reason = 0;
+	memset(bcm->dma_reason, 0, sizeof(bcm->dma_reason));
+	bcm->irq_savedstate = BCM43xx_IRQ_INITIAL;
 
-	bcm43xx_set_status(bcm, BCM43xx_STAT_UNINIT);
-	bcm43xx_unlock_noirq(bcm);
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
 
-	bcm43xx_lock_noirq(bcm);
-	bcm43xx_set_status(bcm, BCM43xx_STAT_INITIALIZING);
+	if (phytype < 0) {
+		/* If no phytype is requested, select the first core. */
+		assert(bcm->core_80211[0].available);
+		wlext = bcm->core_80211[0].priv;
+		phytype = wlext->phy.type;
+	}
+
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
+	if (!active_core) {
+		/* No such PHYTYPE on this board. */
+		return -ESRCH;
+	}
+
+	if (bcm->active_80211_core) {
+		/* We already selected a wl core in the past.
+		 * So first clean up everything.
+		 */
+		dprintk(KERN_INFO PFX "select_wireless_core: cleanup\n");
+		ieee80211softmac_stop(bcm->net_dev);
+		bcm43xx_set_status(bcm, BCM43xx_STAT_INITIALIZED);
+		err = bcm43xx_disable_interrupts_sync(bcm, NULL);
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
+		if (wlext->phy.type == BCM43xx_PHYTYPE_G)
+			adjust_active_sbtmstatelow = 1;
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
+	if (adjust_active_sbtmstatelow) {
+		u32 sbtmstatelow;
 
-		if (i != 0) {
-			bcm43xx_mac_suspend(bcm);
-			bcm43xx_interrupt_disable(bcm, BCM43xx_IRQ_ALL);
-			bcm43xx_radio_turn_off(bcm);
-		}
+		/* Some inactive 80211 core is a GPHY. */
+		sbtmstatelow = bcm43xx_read32(bcm, BCM43xx_CIR_SBTMSTATELOW);
+		sbtmstatelow &= ~0x20000000;
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
 	bcm43xx_security_init(bcm);
-	bcm43xx_softmac_init(bcm);
+	ieee80211softmac_start(bcm->net_dev);
 
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
 
-	if (bcm43xx_current_radio(bcm)->initial_channel != 0xFF) {
-		bcm43xx_mac_suspend(bcm);
-		bcm43xx_radio_selectchannel(bcm, bcm43xx_current_radio(bcm)->initial_channel, 0);
-		bcm43xx_mac_enable(bcm);
-	}
+	dprintk(KERN_INFO PFX "Selected 802.11 core (phytype %d)\n",
+		active_wlext->phy.type);
 
-	/* Initialization of the board is done. Flag it as such. */
-	bcm43xx_set_status(bcm, BCM43xx_STAT_INITIALIZED);
+	return 0;
+
+error:
+	bcm43xx_set_status(bcm, BCM43xx_STAT_UNINIT);
+	bcm43xx_pctl_set_clock(bcm, BCM43xx_PCTL_CLK_SLOW);
+	return err;
+}
+
+static int bcm43xx_init_board(struct bcm43xx_private *bcm)
+{
+	int err;
+
+	bcm43xx_lock_noirq(bcm);
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
 
 	bcm43xx_periodic_tasks_setup(bcm);
-	bcm43xx_sysfs_register(bcm);
-	//FIXME: check for bcm43xx_sysfs_register failure. This function is a bit messy regarding unwinding, though...
+	err = bcm43xx_sysfs_register(bcm);
+	if (err)
+		goto err_wlshutdown;
 
 	/*FIXME: This should be handled by softmac instead. */
 	schedule_work(&bcm->softmac->associnfo.work);
 
-	assert(err == 0);
 out:
 	bcm43xx_unlock_noirq(bcm);
 
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
 
@@ -3744,7 +3882,8 @@
 	unsigned long flags;
 
 	local_irq_save(flags);
-	bcm43xx_interrupt_handler(bcm->irq, bcm, NULL);
+	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED)
+		bcm43xx_interrupt_handler(bcm->irq, bcm, NULL);
 	local_irq_restore(flags);
 }
 #endif /* CONFIG_NET_POLL_CONTROLLER */
@@ -3903,7 +4042,6 @@
 	bcm43xx_debugfs_remove_device(bcm);
 	unregister_netdev(net_dev);
 	bcm43xx_detach_board(bcm);
-	assert(bcm->ucode == NULL);
 	free_ieee80211softmac(net_dev);
 }
 
@@ -3913,47 +4051,25 @@
 static void bcm43xx_chip_reset(void *_bcm)
 {
 	struct bcm43xx_private *bcm = _bcm;
-	struct net_device *net_dev = bcm->net_dev;
-	struct pci_dev *pci_dev = bcm->pci_dev;
+	struct bcm43xx_phyinfo *phy;
 	int err;
-	int was_initialized = (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED);
 
-	netif_stop_queue(bcm->net_dev);
-	tasklet_disable(&bcm->isr_tasklet);
-
-	bcm->firmware_norelease = 1;
-	if (was_initialized)
-		bcm43xx_free_board(bcm);
-	bcm->firmware_norelease = 0;
-	bcm43xx_detach_board(bcm);
-	err = bcm43xx_init_private(bcm, net_dev, pci_dev);
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
-	netif_wake_queue(bcm->net_dev);
-	printk(KERN_INFO PFX "Controller restarted\n");
+	bcm43xx_lock_noirq(bcm);
+	phy = bcm43xx_current_phy(bcm);
+	err = bcm43xx_select_wireless_core(bcm, phy->type);
+	bcm43xx_unlock_noirq(bcm);
 
-	return;
-failure:
-	printk(KERN_ERR PFX "Controller restart failed\n");
+	printk(KERN_ERR PFX "Controller restart%s\n",
+	       (err == 0) ? "ed" : " failed");
 }
 
 /* Hard-reset the chip.
  * This can be called from interrupt or process context.
- * Make sure to _not_ re-enable device interrupts after this has been called.
-*/
+ */
 void bcm43xx_controller_restart(struct bcm43xx_private *bcm, const char *reason)
 {
+	assert(bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED);
 	bcm43xx_set_status(bcm, BCM43xx_STAT_RESTARTING);
-	bcm43xx_interrupt_disable(bcm, BCM43xx_IRQ_ALL);
-	bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD); /* dummy read */
 	printk(KERN_ERR PFX "Controller RESET (%s) ...\n", reason);
 	INIT_WORK(&bcm->restart_work, bcm43xx_chip_reset, bcm);
 	schedule_work(&bcm->restart_work);
Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_debugfs.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_debugfs.c	2006-07-01 22:07:00.000000000 +0200
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_debugfs.c	2006-07-01 22:08:47.000000000 +0200
@@ -306,6 +306,40 @@
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
+	bcm43xx_lock_irqsafe(bcm, flags);
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
+	bcm43xx_unlock_irqsafe(bcm, flags);
+out_up:
+	up(&big_buffer_sem);
+	return res;
+}
+
 #undef fappend
 
 
@@ -339,6 +373,11 @@
 	.open = open_file_generic,
 };
 
+static struct file_operations restart_fops = {
+	.write = restart_write_file,
+	.open = open_file_generic,
+};
+
 
 void bcm43xx_debugfs_add_device(struct bcm43xx_private *bcm)
 {
@@ -390,6 +429,10 @@
 						bcm, &txstat_fops);
 	if (!e->dentry_txstat)
 		printk(KERN_ERR PFX "debugfs: creating \"tx_status\" for \"%s\" failed!\n", devdir);
+	e->dentry_restart = debugfs_create_file("restart", 0222, e->subdir,
+						bcm, &restart_fops);
+	if (!e->dentry_restart)
+		printk(KERN_ERR PFX "debugfs: creating \"restart\" for \"%s\" failed!\n", devdir);
 }
 
 void bcm43xx_debugfs_remove_device(struct bcm43xx_private *bcm)
@@ -405,6 +448,7 @@
 	debugfs_remove(e->dentry_devinfo);
 	debugfs_remove(e->dentry_tsf);
 	debugfs_remove(e->dentry_txstat);
+	debugfs_remove(e->dentry_restart);
 	debugfs_remove(e->subdir);
 	kfree(e->xmitstatus_buffer);
 	kfree(e->xmitstatus_print_buffer);
Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_debugfs.h
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_debugfs.h	2006-07-01 22:07:00.000000000 +0200
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_debugfs.h	2006-07-01 22:08:47.000000000 +0200
@@ -20,6 +20,7 @@
 	struct dentry *dentry_spromdump;
 	struct dentry *dentry_tsf;
 	struct dentry *dentry_txstat;
+	struct dentry *dentry_restart;
 
 	struct bcm43xx_private *bcm;
 
Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.h
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.h	2006-07-01 22:07:00.000000000 +0200
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.h	2006-07-01 22:08:47.000000000 +0200
@@ -133,6 +133,9 @@
 
 int bcm43xx_switch_core(struct bcm43xx_private *bcm, struct bcm43xx_coreinfo *new_core);
 
+int bcm43xx_select_wireless_core(struct bcm43xx_private *bcm,
+				 int phytype);
+
 void bcm43xx_wireless_core_reset(struct bcm43xx_private *bcm, int connect_phy);
 
 void bcm43xx_mac_suspend(struct bcm43xx_private *bcm);
Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c	2006-07-01 22:07:00.000000000 +0200
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c	2006-07-01 22:08:47.000000000 +0200
@@ -299,6 +299,70 @@
 		   bcm43xx_attr_preamble_show,
 		   bcm43xx_attr_preamble_store);
 
+static ssize_t bcm43xx_attr_phymode_store(struct device *dev,
+					  struct device_attribute *attr,
+					  const char *buf, size_t count)
+{
+	struct bcm43xx_private *bcm = dev_to_bcm(dev);
+	int phytype;
+	int err = -EINVAL;
+
+	if (count < 1)
+		goto out;
+	switch (buf[0]) {
+	case 'a':  case 'A':
+		phytype = BCM43xx_PHYTYPE_A;
+		break;
+	case 'b':  case 'B':
+		phytype = BCM43xx_PHYTYPE_B;
+		break;
+	case 'g':  case 'G':
+		phytype = BCM43xx_PHYTYPE_G;
+		break;
+	default:
+		goto out;
+	}
+
+	bcm43xx_lock_noirq(bcm);
+	err = bcm43xx_select_wireless_core(bcm, phytype);
+	bcm43xx_unlock_noirq(bcm);
+	if (err == -ESRCH)
+		err = -ENODEV;
+
+out:
+	return err ? err : count;
+}
+
+static ssize_t bcm43xx_attr_phymode_show(struct device *dev,
+					 struct device_attribute *attr,
+					 char *buf)
+{
+	struct bcm43xx_private *bcm = dev_to_bcm(dev);
+	ssize_t count = 0;
+
+	bcm43xx_lock_noirq(bcm);
+	switch (bcm43xx_current_phy(bcm)->type) {
+	case BCM43xx_PHYTYPE_A:
+		snprintf(buf, PAGE_SIZE, "A");
+		break;
+	case BCM43xx_PHYTYPE_B:
+		snprintf(buf, PAGE_SIZE, "B");
+		break;
+	case BCM43xx_PHYTYPE_G:
+		snprintf(buf, PAGE_SIZE, "G");
+		break;
+	default:
+		assert(0);
+	}
+	bcm43xx_unlock_noirq(bcm);
+
+	return count;
+}
+
+static DEVICE_ATTR(phymode, 0644,
+		   bcm43xx_attr_phymode_show,
+		   bcm43xx_attr_phymode_store);
+
 int bcm43xx_sysfs_register(struct bcm43xx_private *bcm)
 {
 	struct device *dev = &bcm->pci_dev->dev;
@@ -315,9 +379,14 @@
 	err = device_create_file(dev, &dev_attr_shortpreamble);
 	if (err)
 		goto err_remove_interfmode;
+	err = device_create_file(dev, &dev_attr_phymode);
+	if (err)
+		goto err_remove_shortpreamble;
 
 out:
 	return err;
+err_remove_shortpreamble:
+	device_remove_file(dev, &dev_attr_shortpreamble);
 err_remove_interfmode:
 	device_remove_file(dev, &dev_attr_interference);
 err_remove_sprom:
@@ -329,6 +398,7 @@
 {
 	struct device *dev = &bcm->pci_dev->dev;
 
+	device_remove_file(dev, &dev_attr_phymode);
 	device_remove_file(dev, &dev_attr_shortpreamble);
 	device_remove_file(dev, &dev_attr_interference);
 	device_remove_file(dev, &dev_attr_sprom);


-- 
Greetings Michael.
