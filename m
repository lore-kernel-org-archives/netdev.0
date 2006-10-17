From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'upstream-fixes' branch of wireless-2.6
Date: Tue, 17 Oct 2006 17:34:18 -0400
Message-ID: <20061017213412.GD32614@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:14091 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1750765AbWJQVfh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2006 17:35:37 -0400
To: jeff@garzik.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit 51018b0a3160d253283173c2f54f16746cee5852:
  Ulrich Drepper:
        make UML compile (FC6/x86-64)

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-fixes

Dave Kleikamp:
      airo: check if need to freeze

Eric Sesterhenn:
      zd1201: Possible NULL dereference

Florin Malita:
      airo.c: check returned values

Jean Tourrilhes:
      orinoco: fix WE-21 buffer overflow
      wireless: More WE-21 potential overflows...

John W. Linville:
      zd1211rw: fix build-break caused by association race fix

Larry Finger:
      bcm43xx-softmac: check returned value from pci_enable_device
      bcm43xx-softmac: Fix system hang for x86-64 with >1GB RAM

Laurent Riffard:
      sotftmac: fix a slab corruption in WEP restricted key association

Michael Buesch:
      bcm43xx: fix race condition in periodic work handler
      softmac: Fix WX and association related races

 drivers/net/wireless/airo.c                     |  105 +++++++++++++++++------
 drivers/net/wireless/atmel.c                    |    2 
 drivers/net/wireless/bcm43xx/bcm43xx_dma.c      |   28 +++++-
 drivers/net/wireless/bcm43xx/bcm43xx_dma.h      |   17 ++++
 drivers/net/wireless/bcm43xx/bcm43xx_leds.c     |    2 
 drivers/net/wireless/bcm43xx/bcm43xx_main.c     |   34 +++----
 drivers/net/wireless/bcm43xx/bcm43xx_wx.c       |    2 
 drivers/net/wireless/orinoco.c                  |   16 ++--
 drivers/net/wireless/ray_cs.c                   |    1 
 drivers/net/wireless/zd1201.c                   |    6 -
 drivers/net/wireless/zd1211rw/zd_mac.c          |    2 
 include/net/ieee80211softmac.h                  |   35 ++++----
 net/ieee80211/softmac/ieee80211softmac_assoc.c  |   56 ++++++------
 net/ieee80211/softmac/ieee80211softmac_io.c     |   11 ++
 net/ieee80211/softmac/ieee80211softmac_module.c |    1 
 net/ieee80211/softmac/ieee80211softmac_wx.c     |   71 ++++++++++------
 16 files changed, 238 insertions(+), 151 deletions(-)

diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index 0a33c8a..efcdaf1 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -2897,6 +2897,8 @@ static struct net_device *_init_airo_car
 		goto err_out_map;
 	}
 	ai->wifidev = init_wifidev(ai, dev);
+	if (!ai->wifidev)
+		goto err_out_reg;
 
 	set_bit(FLAG_REGISTERED,&ai->flags);
 	airo_print_info(dev->name, "MAC enabled %x:%x:%x:%x:%x:%x",
@@ -2908,11 +2910,18 @@ static struct net_device *_init_airo_car
 		for( i = 0; i < MAX_FIDS; i++ )
 			ai->fids[i] = transmit_allocate(ai,AIRO_DEF_MTU,i>=MAX_FIDS/2);
 
-	setup_proc_entry( dev, dev->priv ); /* XXX check for failure */
+	if (setup_proc_entry(dev, dev->priv) < 0)
+		goto err_out_wifi;
+
 	netif_start_queue(dev);
 	SET_MODULE_OWNER(dev);
 	return dev;
 
+err_out_wifi:
+	unregister_netdev(ai->wifidev);
+	free_netdev(ai->wifidev);
+err_out_reg:
+	unregister_netdev(dev);
 err_out_map:
 	if (test_bit(FLAG_MPI,&ai->flags) && pci) {
 		pci_free_consistent(pci, PCI_SHARED_LEN, ai->shared, ai->shared_dma);
@@ -3089,7 +3098,8 @@ static int airo_thread(void *data) {
 						set_bit(JOB_AUTOWEP, &ai->jobs);
 						break;
 					}
-					if (!kthread_should_stop()) {
+					if (!kthread_should_stop() &&
+					    !freezing(current)) {
 						unsigned long wake_at;
 						if (!ai->expires || !ai->scan_timeout) {
 							wake_at = max(ai->expires,
@@ -3101,7 +3111,8 @@ static int airo_thread(void *data) {
 						schedule_timeout(wake_at - jiffies);
 						continue;
 					}
-				} else if (!kthread_should_stop()) {
+				} else if (!kthread_should_stop() &&
+					   !freezing(current)) {
 					schedule();
 					continue;
 				}
@@ -4495,91 +4506,128 @@ static int setup_proc_entry( struct net_
 	apriv->proc_entry = create_proc_entry(apriv->proc_name,
 					      S_IFDIR|airo_perm,
 					      airo_entry);
-        apriv->proc_entry->uid = proc_uid;
-        apriv->proc_entry->gid = proc_gid;
-        apriv->proc_entry->owner = THIS_MODULE;
+	if (!apriv->proc_entry)
+		goto fail;
+	apriv->proc_entry->uid = proc_uid;
+	apriv->proc_entry->gid = proc_gid;
+	apriv->proc_entry->owner = THIS_MODULE;
 
 	/* Setup the StatsDelta */
 	entry = create_proc_entry("StatsDelta",
 				  S_IFREG | (S_IRUGO&proc_perm),
 				  apriv->proc_entry);
-        entry->uid = proc_uid;
-        entry->gid = proc_gid;
+	if (!entry)
+		goto fail_stats_delta;
+	entry->uid = proc_uid;
+	entry->gid = proc_gid;
 	entry->data = dev;
-        entry->owner = THIS_MODULE;
+	entry->owner = THIS_MODULE;
 	SETPROC_OPS(entry, proc_statsdelta_ops);
 
 	/* Setup the Stats */
 	entry = create_proc_entry("Stats",
 				  S_IFREG | (S_IRUGO&proc_perm),
 				  apriv->proc_entry);
-        entry->uid = proc_uid;
-        entry->gid = proc_gid;
+	if (!entry)
+		goto fail_stats;
+	entry->uid = proc_uid;
+	entry->gid = proc_gid;
 	entry->data = dev;
-        entry->owner = THIS_MODULE;
+	entry->owner = THIS_MODULE;
 	SETPROC_OPS(entry, proc_stats_ops);
 
 	/* Setup the Status */
 	entry = create_proc_entry("Status",
 				  S_IFREG | (S_IRUGO&proc_perm),
 				  apriv->proc_entry);
-        entry->uid = proc_uid;
-        entry->gid = proc_gid;
+	if (!entry)
+		goto fail_status;
+	entry->uid = proc_uid;
+	entry->gid = proc_gid;
 	entry->data = dev;
-        entry->owner = THIS_MODULE;
+	entry->owner = THIS_MODULE;
 	SETPROC_OPS(entry, proc_status_ops);
 
 	/* Setup the Config */
 	entry = create_proc_entry("Config",
 				  S_IFREG | proc_perm,
 				  apriv->proc_entry);
-        entry->uid = proc_uid;
-        entry->gid = proc_gid;
+	if (!entry)
+		goto fail_config;
+	entry->uid = proc_uid;
+	entry->gid = proc_gid;
 	entry->data = dev;
-        entry->owner = THIS_MODULE;
+	entry->owner = THIS_MODULE;
 	SETPROC_OPS(entry, proc_config_ops);
 
 	/* Setup the SSID */
 	entry = create_proc_entry("SSID",
 				  S_IFREG | proc_perm,
 				  apriv->proc_entry);
-        entry->uid = proc_uid;
-        entry->gid = proc_gid;
+	if (!entry)
+		goto fail_ssid;
+	entry->uid = proc_uid;
+	entry->gid = proc_gid;
 	entry->data = dev;
-        entry->owner = THIS_MODULE;
+	entry->owner = THIS_MODULE;
 	SETPROC_OPS(entry, proc_SSID_ops);
 
 	/* Setup the APList */
 	entry = create_proc_entry("APList",
 				  S_IFREG | proc_perm,
 				  apriv->proc_entry);
-        entry->uid = proc_uid;
-        entry->gid = proc_gid;
+	if (!entry)
+		goto fail_aplist;
+	entry->uid = proc_uid;
+	entry->gid = proc_gid;
 	entry->data = dev;
-        entry->owner = THIS_MODULE;
+	entry->owner = THIS_MODULE;
 	SETPROC_OPS(entry, proc_APList_ops);
 
 	/* Setup the BSSList */
 	entry = create_proc_entry("BSSList",
 				  S_IFREG | proc_perm,
 				  apriv->proc_entry);
+	if (!entry)
+		goto fail_bsslist;
 	entry->uid = proc_uid;
 	entry->gid = proc_gid;
 	entry->data = dev;
-        entry->owner = THIS_MODULE;
+	entry->owner = THIS_MODULE;
 	SETPROC_OPS(entry, proc_BSSList_ops);
 
 	/* Setup the WepKey */
 	entry = create_proc_entry("WepKey",
 				  S_IFREG | proc_perm,
 				  apriv->proc_entry);
-        entry->uid = proc_uid;
-        entry->gid = proc_gid;
+	if (!entry)
+		goto fail_wepkey;
+	entry->uid = proc_uid;
+	entry->gid = proc_gid;
 	entry->data = dev;
-        entry->owner = THIS_MODULE;
+	entry->owner = THIS_MODULE;
 	SETPROC_OPS(entry, proc_wepkey_ops);
 
 	return 0;
+
+fail_wepkey:
+	remove_proc_entry("BSSList", apriv->proc_entry);
+fail_bsslist:
+	remove_proc_entry("APList", apriv->proc_entry);
+fail_aplist:
+	remove_proc_entry("SSID", apriv->proc_entry);
+fail_ssid:
+	remove_proc_entry("Config", apriv->proc_entry);
+fail_config:
+	remove_proc_entry("Status", apriv->proc_entry);
+fail_status:
+	remove_proc_entry("Stats", apriv->proc_entry);
+fail_stats:
+	remove_proc_entry("StatsDelta", apriv->proc_entry);
+fail_stats_delta:
+	remove_proc_entry(apriv->proc_name, airo_entry);
+fail:
+	return -ENOMEM;
 }
 
 static int takedown_proc_entry( struct net_device *dev,
@@ -5924,7 +5972,6 @@ static int airo_get_essid(struct net_dev
 
 	/* Get the current SSID */
 	memcpy(extra, status_rid.SSID, status_rid.SSIDlen);
-	extra[status_rid.SSIDlen] = '\0';
 	/* If none, we may want to get the one that was set */
 
 	/* Push it out ! */
diff --git a/drivers/net/wireless/atmel.c b/drivers/net/wireless/atmel.c
index 31eed85..0c07b8b 100644
--- a/drivers/net/wireless/atmel.c
+++ b/drivers/net/wireless/atmel.c
@@ -1678,11 +1678,9 @@ static int atmel_get_essid(struct net_de
 	/* Get the current SSID */
 	if (priv->new_SSID_size != 0) {
 		memcpy(extra, priv->new_SSID, priv->new_SSID_size);
-		extra[priv->new_SSID_size] = '\0';
 		dwrq->length = priv->new_SSID_size;
 	} else {
 		memcpy(extra, priv->SSID, priv->SSID_size);
-		extra[priv->SSID_size] = '\0';
 		dwrq->length = priv->SSID_size;
 	}
 
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_dma.c b/drivers/net/wireless/bcm43xx/bcm43xx_dma.c
index 76e3aed..978ed09 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_dma.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_dma.c
@@ -705,11 +705,30 @@ int bcm43xx_dma_init(struct bcm43xx_priv
 	struct bcm43xx_dmaring *ring;
 	int err = -ENOMEM;
 	int dma64 = 0;
-	u32 sbtmstatehi;
+	u64 mask = bcm43xx_get_supported_dma_mask(bcm);
+	int nobits;
 
-	sbtmstatehi = bcm43xx_read32(bcm, BCM43xx_CIR_SBTMSTATEHIGH);
-	if (sbtmstatehi & BCM43xx_SBTMSTATEHIGH_DMA64BIT)
+	if (mask == DMA_64BIT_MASK) {
 		dma64 = 1;
+		nobits = 64;
+	} else if (mask == DMA_32BIT_MASK)
+		nobits = 32;
+	else
+		nobits = 30;
+	err = pci_set_dma_mask(bcm->pci_dev, mask);
+	err |= pci_set_consistent_dma_mask(bcm->pci_dev, mask);
+	if (err) {
+#ifdef CONFIG_BCM43XX_PIO
+		printk(KERN_WARNING PFX "DMA not supported on this device."
+					" Falling back to PIO.\n");
+		bcm->__using_pio = 1;
+		return -ENOSYS;
+#else
+		printk(KERN_ERR PFX "FATAL: DMA not supported and PIO not configured. "
+				    "Please recompile the driver with PIO support.\n");
+		return -ENODEV;
+#endif /* CONFIG_BCM43XX_PIO */
+	}
 
 	/* setup TX DMA channels. */
 	ring = bcm43xx_setup_dmaring(bcm, 0, 1, dma64);
@@ -755,8 +774,7 @@ int bcm43xx_dma_init(struct bcm43xx_priv
 		dma->rx_ring3 = ring;
 	}
 
-	dprintk(KERN_INFO PFX "%s DMA initialized\n",
-			dma64 ? "64-bit" : "32-bit");
+	dprintk(KERN_INFO PFX "%d-bit DMA initialized\n", nobits);
 	err = 0;
 out:
 	return err;
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_dma.h b/drivers/net/wireless/bcm43xx/bcm43xx_dma.h
index e04bcad..ea16078 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_dma.h
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_dma.h
@@ -314,6 +314,23 @@ int bcm43xx_dma_tx(struct bcm43xx_privat
 		   struct ieee80211_txb *txb);
 void bcm43xx_dma_rx(struct bcm43xx_dmaring *ring);
 
+/* Helper function that returns the dma mask for this device. */
+static inline
+u64 bcm43xx_get_supported_dma_mask(struct bcm43xx_private *bcm)
+{
+	int dma64 = bcm43xx_read32(bcm, BCM43xx_CIR_SBTMSTATEHIGH) &
+				   BCM43xx_SBTMSTATEHIGH_DMA64BIT;
+	u16 mmio_base = bcm43xx_dmacontroller_base(dma64, 0);
+	u32 mask = BCM43xx_DMA32_TXADDREXT_MASK;
+
+	if (dma64)
+		return DMA_64BIT_MASK;
+	bcm43xx_write32(bcm, mmio_base + BCM43xx_DMA32_TXCTL, mask);
+	if (bcm43xx_read32(bcm, mmio_base + BCM43xx_DMA32_TXCTL) & mask)
+		return DMA_32BIT_MASK;
+	return DMA_30BIT_MASK;
+}
+
 #else /* CONFIG_BCM43XX_DMA */
 
 
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_leds.c b/drivers/net/wireless/bcm43xx/bcm43xx_leds.c
index c3f90c8..2ddbec6 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_leds.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_leds.c
@@ -242,7 +242,7 @@ void bcm43xx_leds_update(struct bcm43xx_
 			//TODO
 			break;
 		case BCM43xx_LED_ASSOC:
-			if (bcm->softmac->associated)
+			if (bcm->softmac->associnfo.associated)
 				turn_on = 1;
 			break;
 #ifdef CONFIG_BCM43XX_DEBUG
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
index bad3452..a94c6d8 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -2925,10 +2925,13 @@ static int bcm43xx_wireless_core_init(st
 		bcm43xx_write16(bcm, 0x043C, 0x000C);
 
 	if (active_wlcore) {
-		if (bcm43xx_using_pio(bcm))
+		if (bcm43xx_using_pio(bcm)) {
 			err = bcm43xx_pio_init(bcm);
-		else
+		} else {
 			err = bcm43xx_dma_init(bcm);
+			if (err == -ENOSYS)
+				err = bcm43xx_pio_init(bcm);
+		}
 		if (err)
 			goto err_chip_cleanup;
 	}
@@ -3164,12 +3167,12 @@ static void bcm43xx_periodic_work_handle
 	u32 savedirqs = 0;
 	int badness;
 
+	mutex_lock(&bcm->mutex);
 	badness = estimate_periodic_work_badness(bcm->periodic_state);
 	if (badness > BADNESS_LIMIT) {
 		/* Periodic work will take a long time, so we want it to
 		 * be preemtible.
 		 */
-		mutex_lock(&bcm->mutex);
 		netif_tx_disable(bcm->net_dev);
 		spin_lock_irqsave(&bcm->irq_lock, flags);
 		bcm43xx_mac_suspend(bcm);
@@ -3182,7 +3185,6 @@ static void bcm43xx_periodic_work_handle
 		/* Periodic work should take short time, so we want low
 		 * locking overhead.
 		 */
-		mutex_lock(&bcm->mutex);
 		spin_lock_irqsave(&bcm->irq_lock, flags);
 	}
 
@@ -3993,8 +3995,6 @@ static int bcm43xx_init_private(struct b
 				struct net_device *net_dev,
 				struct pci_dev *pci_dev)
 {
-	int err;
-
 	bcm43xx_set_status(bcm, BCM43xx_STAT_UNINIT);
 	bcm->ieee = netdev_priv(net_dev);
 	bcm->softmac = ieee80211_priv(net_dev);
@@ -4012,22 +4012,8 @@ static int bcm43xx_init_private(struct b
 		     (void (*)(unsigned long))bcm43xx_interrupt_tasklet,
 		     (unsigned long)bcm);
 	tasklet_disable_nosync(&bcm->isr_tasklet);
-	if (modparam_pio) {
+	if (modparam_pio)
 		bcm->__using_pio = 1;
-	} else {
-		err = pci_set_dma_mask(pci_dev, DMA_30BIT_MASK);
-		err |= pci_set_consistent_dma_mask(pci_dev, DMA_30BIT_MASK);
-		if (err) {
-#ifdef CONFIG_BCM43XX_PIO
-			printk(KERN_WARNING PFX "DMA not supported. Falling back to PIO.\n");
-			bcm->__using_pio = 1;
-#else
-			printk(KERN_ERR PFX "FATAL: DMA not supported and PIO not configured. "
-					    "Recompile the driver with PIO support, please.\n");
-			return -ENODEV;
-#endif /* CONFIG_BCM43XX_PIO */
-		}
-	}
 	bcm->rts_threshold = BCM43xx_DEFAULT_RTS_THRESHOLD;
 
 	/* default to sw encryption for now */
@@ -4208,7 +4194,11 @@ static int bcm43xx_resume(struct pci_dev
 	dprintk(KERN_INFO PFX "Resuming...\n");
 
 	pci_set_power_state(pdev, 0);
-	pci_enable_device(pdev);
+	err = pci_enable_device(pdev);
+	if (err) {
+		printk(KERN_ERR PFX "Failure with pci_enable_device!\n");
+		return err;
+	}
 	pci_restore_state(pdev);
 
 	bcm43xx_chipset_attach(bcm);
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_wx.c b/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
index 9b7b15c..d27016f 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
@@ -847,7 +847,7 @@ static struct iw_statistics *bcm43xx_get
 	unsigned long flags;
 
 	wstats = &bcm->stats.wstats;
-	if (!mac->associated) {
+	if (!mac->associnfo.associated) {
 		wstats->miss.beacon = 0;
 //		bcm->ieee->ieee_stats.tx_retry_limit_exceeded = 0; // FIXME: should this be cleared here?
 		wstats->discard.retries = 0;
diff --git a/drivers/net/wireless/orinoco.c b/drivers/net/wireless/orinoco.c
index b779c7d..336caba 100644
--- a/drivers/net/wireless/orinoco.c
+++ b/drivers/net/wireless/orinoco.c
@@ -2457,6 +2457,7 @@ void free_orinocodev(struct net_device *
 /* Wireless extensions                                              */
 /********************************************************************/
 
+/* Return : < 0 -> error code ; >= 0 -> length */
 static int orinoco_hw_get_essid(struct orinoco_private *priv, int *active,
 				char buf[IW_ESSID_MAX_SIZE+1])
 {
@@ -2501,9 +2502,9 @@ static int orinoco_hw_get_essid(struct o
 	len = le16_to_cpu(essidbuf.len);
 	BUG_ON(len > IW_ESSID_MAX_SIZE);
 
-	memset(buf, 0, IW_ESSID_MAX_SIZE+1);
+	memset(buf, 0, IW_ESSID_MAX_SIZE);
 	memcpy(buf, p, len);
-	buf[len] = '\0';
+	err = len;
 
  fail_unlock:
 	orinoco_unlock(priv, &flags);
@@ -3027,17 +3028,18 @@ static int orinoco_ioctl_getessid(struct
 
 	if (netif_running(dev)) {
 		err = orinoco_hw_get_essid(priv, &active, essidbuf);
-		if (err)
+		if (err < 0)
 			return err;
+		erq->length = err;
 	} else {
 		if (orinoco_lock(priv, &flags) != 0)
 			return -EBUSY;
-		memcpy(essidbuf, priv->desired_essid, IW_ESSID_MAX_SIZE + 1);
+		memcpy(essidbuf, priv->desired_essid, IW_ESSID_MAX_SIZE);
+		erq->length = strlen(priv->desired_essid);
 		orinoco_unlock(priv, &flags);
 	}
 
 	erq->flags = 1;
-	erq->length = strlen(essidbuf);
 
 	return 0;
 }
@@ -3075,10 +3077,10 @@ static int orinoco_ioctl_getnick(struct 
 	if (orinoco_lock(priv, &flags) != 0)
 		return -EBUSY;
 
-	memcpy(nickbuf, priv->nick, IW_ESSID_MAX_SIZE+1);
+	memcpy(nickbuf, priv->nick, IW_ESSID_MAX_SIZE);
 	orinoco_unlock(priv, &flags);
 
-	nrq->length = strlen(nickbuf);
+	nrq->length = strlen(priv->nick);
 
 	return 0;
 }
diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index 0b381d7..7fbfc9e 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -1198,7 +1198,6 @@ static int ray_get_essid(struct net_devi
 
 	/* Get the essid that was set */
 	memcpy(extra, local->sparm.b5.a_current_ess_id, IW_ESSID_MAX_SIZE);
-	extra[IW_ESSID_MAX_SIZE] = '\0';
 
 	/* Push it out ! */
 	dwrq->length = strlen(extra);
diff --git a/drivers/net/wireless/zd1201.c b/drivers/net/wireless/zd1201.c
index 30057a3..36b29ff 100644
--- a/drivers/net/wireless/zd1201.c
+++ b/drivers/net/wireless/zd1201.c
@@ -193,10 +193,8 @@ static void zd1201_usbrx(struct urb *urb
 	struct sk_buff *skb;
 	unsigned char type;
 
-	if (!zd) {
-		free = 1;
-		goto exit;
-	}
+	if (!zd)
+		return;
 
 	switch(urb->status) {
 		case -EILSEQ:
diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wireless/zd1211rw/zd_mac.c
index 2d12837..a7d29bd 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -1099,7 +1099,7 @@ static void link_led_handler(void *p)
 	int r;
 
 	spin_lock_irq(&mac->lock);
-	is_associated = sm->associated != 0;
+	is_associated = sm->associnfo.associated != 0;
 	spin_unlock_irq(&mac->lock);
 
 	r = zd_chip_control_leds(chip,
diff --git a/include/net/ieee80211softmac.h b/include/net/ieee80211softmac.h
index 425b3a5..617b672 100644
--- a/include/net/ieee80211softmac.h
+++ b/include/net/ieee80211softmac.h
@@ -63,13 +63,11 @@ struct ieee80211softmac_wpa {
 
 /*
  * Information about association
- *
- * Do we need a lock for this?
- * We only ever use this structure inlined
- * into our global struct. I've used its lock,
- * but maybe we need a local one here?
  */
 struct ieee80211softmac_assoc_info {
+
+	struct mutex mutex;
+
 	/*
 	 * This is the requested ESSID. It is written
 	 * only by the WX handlers.
@@ -99,12 +97,13 @@ struct ieee80211softmac_assoc_info {
 	 *
 	 * bssfixed is used for SIOCSIWAP.
 	 */
-	u8 static_essid:1,
-	   short_preamble_available:1,
-	   associating:1,
-	   assoc_wait:1,
-	   bssvalid:1,
-	   bssfixed:1;
+	u8 static_essid;
+	u8 short_preamble_available;
+	u8 associating;
+	u8 associated;
+	u8 assoc_wait;
+	u8 bssvalid;
+	u8 bssfixed;
 
 	/* Scan retries remaining */
 	int scan_retry;
@@ -229,12 +228,10 @@ struct ieee80211softmac_device {
 	/* private stuff follows */
 	/* this lock protects this structure */
 	spinlock_t lock;
-	
-	/* couple of flags */
-	u8 scanning:1, /* protects scanning from being done multiple times at once */
-	   associated:1,
-	   running:1;
-	
+
+	u8 running; /* SoftMAC started? */
+	u8 scanning;
+
 	struct ieee80211softmac_scaninfo *scaninfo;
 	struct ieee80211softmac_assoc_info associnfo;
 	struct ieee80211softmac_bss_info bssinfo;
@@ -250,7 +247,7 @@ struct ieee80211softmac_device {
 
 	/* we need to keep a list of network structs we copied */
 	struct list_head network_list;
-	
+
 	/* This must be the last item so that it points to the data
 	 * allocated beyond this structure by alloc_ieee80211 */
 	u8 priv[0];
@@ -295,7 +292,7 @@ static inline u8 ieee80211softmac_sugges
 {
 	struct ieee80211softmac_txrates *txrates = &mac->txrates;
 
-	if (!mac->associated)
+	if (!mac->associnfo.associated)
 		return txrates->mgt_mcast_rate;
 
 	/* We are associated, sending unicast frame */
diff --git a/net/ieee80211/softmac/ieee80211softmac_assoc.c b/net/ieee80211/softmac/ieee80211softmac_assoc.c
index 589f6d2..cf51c87 100644
--- a/net/ieee80211/softmac/ieee80211softmac_assoc.c
+++ b/net/ieee80211/softmac/ieee80211softmac_assoc.c
@@ -48,7 +48,7 @@ ieee80211softmac_assoc(struct ieee80211s
 	dprintk(KERN_INFO PFX "sent association request!\n");
 
 	spin_lock_irqsave(&mac->lock, flags);
-	mac->associated = 0; /* just to make sure */
+	mac->associnfo.associated = 0; /* just to make sure */
 
 	/* Set a timer for timeout */
 	/* FIXME: make timeout configurable */
@@ -62,24 +62,22 @@ ieee80211softmac_assoc_timeout(void *d)
 {
 	struct ieee80211softmac_device *mac = (struct ieee80211softmac_device *)d;
 	struct ieee80211softmac_network *n;
-	unsigned long flags;
 
-	spin_lock_irqsave(&mac->lock, flags);
+	mutex_lock(&mac->associnfo.mutex);
 	/* we might race against ieee80211softmac_handle_assoc_response,
 	 * so make sure only one of us does something */
-	if (!mac->associnfo.associating) {
-		spin_unlock_irqrestore(&mac->lock, flags);
-		return;
-	}
+	if (!mac->associnfo.associating)
+		goto out;
 	mac->associnfo.associating = 0;
 	mac->associnfo.bssvalid = 0;
-	mac->associated = 0;
+	mac->associnfo.associated = 0;
 
 	n = ieee80211softmac_get_network_by_bssid_locked(mac, mac->associnfo.bssid);
-	spin_unlock_irqrestore(&mac->lock, flags);
 
 	dprintk(KERN_INFO PFX "assoc request timed out!\n");
 	ieee80211softmac_call_events(mac, IEEE80211SOFTMAC_EVENT_ASSOCIATE_TIMEOUT, n);
+out:
+	mutex_unlock(&mac->associnfo.mutex);
 }
 
 void
@@ -93,7 +91,7 @@ ieee80211softmac_disassoc(struct ieee802
 
 	netif_carrier_off(mac->dev);
 
-	mac->associated = 0;
+	mac->associnfo.associated = 0;
 	mac->associnfo.bssvalid = 0;
 	mac->associnfo.associating = 0;
 	ieee80211softmac_init_bss(mac);
@@ -107,7 +105,7 @@ ieee80211softmac_send_disassoc_req(struc
 {
 	struct ieee80211softmac_network *found;
 
-	if (mac->associnfo.bssvalid && mac->associated) {
+	if (mac->associnfo.bssvalid && mac->associnfo.associated) {
 		found = ieee80211softmac_get_network_by_bssid(mac, mac->associnfo.bssid);
 		if (found)
 			ieee80211softmac_send_mgt_frame(mac, found, IEEE80211_STYPE_DISASSOC, reason);
@@ -196,17 +194,18 @@ ieee80211softmac_assoc_work(void *d)
 	int bssvalid;
 	unsigned long flags;
 
+	mutex_lock(&mac->associnfo.mutex);
+
+	if (!mac->associnfo.associating)
+		goto out;
+
 	/* ieee80211_disassoc might clear this */
 	bssvalid = mac->associnfo.bssvalid;
 
 	/* meh */
-	if (mac->associated)
+	if (mac->associnfo.associated)
 		ieee80211softmac_send_disassoc_req(mac, WLAN_REASON_DISASSOC_STA_HAS_LEFT);
 
-	spin_lock_irqsave(&mac->lock, flags);
-	mac->associnfo.associating = 1;
-	spin_unlock_irqrestore(&mac->lock, flags);
-
 	/* try to find the requested network in our list, if we found one already */
 	if (bssvalid || mac->associnfo.bssfixed)
 		found = ieee80211softmac_get_network_by_bssid(mac, mac->associnfo.bssid);	
@@ -260,10 +259,8 @@ ieee80211softmac_assoc_work(void *d)
 
 	if (!found) {
 		if (mac->associnfo.scan_retry > 0) {
-			spin_lock_irqsave(&mac->lock, flags);
 			mac->associnfo.scan_retry--;
-			spin_unlock_irqrestore(&mac->lock, flags);
-		
+
 			/* We know of no such network. Let's scan. 
 			 * NB: this also happens if we had no memory to copy the network info...
 			 * Maybe we can hope to have more memory after scanning finishes ;)
@@ -272,19 +269,17 @@ ieee80211softmac_assoc_work(void *d)
 			ieee80211softmac_notify(mac->dev, IEEE80211SOFTMAC_EVENT_SCAN_FINISHED, ieee80211softmac_assoc_notify_scan, NULL);
 			if (ieee80211softmac_start_scan(mac))
 				dprintk(KERN_INFO PFX "Associate: failed to initiate scan. Is device up?\n");
-			return;
+			goto out;
 		} else {
-			spin_lock_irqsave(&mac->lock, flags);
 			mac->associnfo.associating = 0;
-			mac->associated = 0;
-			spin_unlock_irqrestore(&mac->lock, flags);
+			mac->associnfo.associated = 0;
 
 			dprintk(KERN_INFO PFX "Unable to find matching network after scan!\n");
 			/* reset the retry counter for the next user request since we
 			 * break out and don't reschedule ourselves after this point. */
 			mac->associnfo.scan_retry = IEEE80211SOFTMAC_ASSOC_SCAN_RETRY_LIMIT;
 			ieee80211softmac_call_events(mac, IEEE80211SOFTMAC_EVENT_ASSOCIATE_NET_NOT_FOUND, NULL);
-			return;
+			goto out;
 		}
 	}
 
@@ -297,7 +292,7 @@ ieee80211softmac_assoc_work(void *d)
 	/* copy the ESSID for displaying it */
 	mac->associnfo.associate_essid.len = found->essid.len;
 	memcpy(mac->associnfo.associate_essid.data, found->essid.data, IW_ESSID_MAX_SIZE + 1);
-	
+
 	/* we found a network! authenticate (if necessary) and associate to it. */
 	if (found->authenticating) {
 		dprintk(KERN_INFO PFX "Already requested authentication, waiting...\n");
@@ -305,7 +300,7 @@ ieee80211softmac_assoc_work(void *d)
 			mac->associnfo.assoc_wait = 1;
 			ieee80211softmac_notify_internal(mac, IEEE80211SOFTMAC_EVENT_ANY, found, ieee80211softmac_assoc_notify_auth, NULL, GFP_KERNEL);
 		}
-		return;
+		goto out;
 	}
 	if (!found->authenticated && !found->authenticating) {
 		/* This relies on the fact that _auth_req only queues the work,
@@ -321,11 +316,14 @@ ieee80211softmac_assoc_work(void *d)
 			mac->associnfo.assoc_wait = 0;
 			ieee80211softmac_call_events(mac, IEEE80211SOFTMAC_EVENT_ASSOCIATE_FAILED, found);
 		}
-		return;
+		goto out;
 	}
 	/* finally! now we can start associating */
 	mac->associnfo.assoc_wait = 0;
 	ieee80211softmac_assoc(mac, found);
+
+out:
+	mutex_unlock(&mac->associnfo.mutex);
 }
 
 /* call this to do whatever is necessary when we're associated */
@@ -341,7 +339,7 @@ ieee80211softmac_associated(struct ieee8
 	mac->bssinfo.supported_rates = net->supported_rates;
 	ieee80211softmac_recalc_txrates(mac);
 
-	mac->associated = 1;
+	mac->associnfo.associated = 1;
 
 	mac->associnfo.short_preamble_available =
 		(cap & WLAN_CAPABILITY_SHORT_PREAMBLE) != 0;
@@ -421,7 +419,7 @@ ieee80211softmac_handle_assoc_response(s
 			dprintk(KERN_INFO PFX "associating failed (reason: 0x%x)!\n", status);
 			mac->associnfo.associating = 0;
 			mac->associnfo.bssvalid = 0;
-			mac->associated = 0;
+			mac->associnfo.associated = 0;
 			ieee80211softmac_call_events_locked(mac, IEEE80211SOFTMAC_EVENT_ASSOCIATE_FAILED, network);
 	}
 	
diff --git a/net/ieee80211/softmac/ieee80211softmac_io.c b/net/ieee80211/softmac/ieee80211softmac_io.c
index 82bfddb..b969310 100644
--- a/net/ieee80211/softmac/ieee80211softmac_io.c
+++ b/net/ieee80211/softmac/ieee80211softmac_io.c
@@ -304,7 +304,7 @@ ieee80211softmac_auth(struct ieee80211_a
 		2 +		/* Auth Transaction Seq */
 		2 +		/* Status Code */
 		 /* Challenge Text IE */
-		is_shared_response ? 0 : 1 + 1 + net->challenge_len
+		(is_shared_response ? 1 + 1 + net->challenge_len : 0)
 	);
 	if (unlikely((*pkt) == NULL))
 		return 0;
@@ -475,8 +475,13 @@ int ieee80211softmac_handle_beacon(struc
 {
 	struct ieee80211softmac_device *mac = ieee80211_priv(dev);
 
-	if (mac->associated && memcmp(network->bssid, mac->associnfo.bssid, ETH_ALEN) == 0)
-		ieee80211softmac_process_erp(mac, network->erp_value);
+	/* This might race, but we don't really care and it's not worth
+	 * adding heavyweight locking in this fastpath.
+	 */
+	if (mac->associnfo.associated) {
+		if (memcmp(network->bssid, mac->associnfo.bssid, ETH_ALEN) == 0)
+			ieee80211softmac_process_erp(mac, network->erp_value);
+	}
 
 	return 0;
 }
diff --git a/net/ieee80211/softmac/ieee80211softmac_module.c b/net/ieee80211/softmac/ieee80211softmac_module.c
index addea1c..33aff4f 100644
--- a/net/ieee80211/softmac/ieee80211softmac_module.c
+++ b/net/ieee80211/softmac/ieee80211softmac_module.c
@@ -57,6 +57,7 @@ struct net_device *alloc_ieee80211softma
 	INIT_LIST_HEAD(&softmac->network_list);
 	INIT_LIST_HEAD(&softmac->events);
 
+	mutex_init(&softmac->associnfo.mutex);
 	INIT_WORK(&softmac->associnfo.work, ieee80211softmac_assoc_work, softmac);
 	INIT_WORK(&softmac->associnfo.timeout, ieee80211softmac_assoc_timeout, softmac);
 	softmac->start_scan = ieee80211softmac_start_scan_implementation;
diff --git a/net/ieee80211/softmac/ieee80211softmac_wx.c b/net/ieee80211/softmac/ieee80211softmac_wx.c
index 2aa779d..23068a8 100644
--- a/net/ieee80211/softmac/ieee80211softmac_wx.c
+++ b/net/ieee80211/softmac/ieee80211softmac_wx.c
@@ -73,13 +73,14 @@ ieee80211softmac_wx_set_essid(struct net
 	struct ieee80211softmac_network *n;
 	struct ieee80211softmac_auth_queue_item *authptr;
 	int length = 0;
-	unsigned long flags;
+
+	mutex_lock(&sm->associnfo.mutex);
 
 	/* Check if we're already associating to this or another network
 	 * If it's another network, cancel and start over with our new network
 	 * If it's our network, ignore the change, we're already doing it!
 	 */
-	if((sm->associnfo.associating || sm->associated) &&
+	if((sm->associnfo.associating || sm->associnfo.associated) &&
 	   (data->essid.flags && data->essid.length)) {
 		/* Get the associating network */
 		n = ieee80211softmac_get_network_by_bssid(sm, sm->associnfo.bssid);
@@ -87,10 +88,9 @@ ieee80211softmac_wx_set_essid(struct net
 		   !memcmp(n->essid.data, extra, n->essid.len)) {
 			dprintk(KERN_INFO PFX "Already associating or associated to "MAC_FMT"\n",
 				MAC_ARG(sm->associnfo.bssid));
-			return 0;
+			goto out;
 		} else {
 			dprintk(KERN_INFO PFX "Canceling existing associate request!\n");
-			spin_lock_irqsave(&sm->lock,flags);
 			/* Cancel assoc work */
 			cancel_delayed_work(&sm->associnfo.work);
 			/* We don't have to do this, but it's a little cleaner */
@@ -98,14 +98,13 @@ ieee80211softmac_wx_set_essid(struct net
 				cancel_delayed_work(&authptr->work);
 			sm->associnfo.bssvalid = 0;
 			sm->associnfo.bssfixed = 0;
-			spin_unlock_irqrestore(&sm->lock,flags);
 			flush_scheduled_work();
+			sm->associnfo.associating = 0;
+			sm->associnfo.associated = 0;
 		}
 	}
 
 
-	spin_lock_irqsave(&sm->lock, flags);
-
 	sm->associnfo.static_essid = 0;
 	sm->associnfo.assoc_wait = 0;
 
@@ -121,10 +120,12 @@ ieee80211softmac_wx_set_essid(struct net
 	 * If applicable, we have already copied the data in */
 	sm->associnfo.req_essid.len = length;
 
+	sm->associnfo.associating = 1;
 	/* queue lower level code to do work (if necessary) */
 	schedule_work(&sm->associnfo.work);
+out:
+	mutex_unlock(&sm->associnfo.mutex);
 
-	spin_unlock_irqrestore(&sm->lock, flags);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(ieee80211softmac_wx_set_essid);
@@ -136,10 +137,8 @@ ieee80211softmac_wx_get_essid(struct net
 			      char *extra)
 {
 	struct ieee80211softmac_device *sm = ieee80211_priv(net_dev);
-	unsigned long flags;
 
-	/* avoid getting inconsistent information */
-	spin_lock_irqsave(&sm->lock, flags);
+	mutex_lock(&sm->associnfo.mutex);
 	/* If all fails, return ANY (empty) */
 	data->essid.length = 0;
 	data->essid.flags = 0;  /* active */
@@ -152,12 +151,13 @@ ieee80211softmac_wx_get_essid(struct net
 	}
 	
 	/* If we're associating/associated, return that */
-	if (sm->associated || sm->associnfo.associating) {
+	if (sm->associnfo.associated || sm->associnfo.associating) {
 		data->essid.length = sm->associnfo.associate_essid.len;
 		data->essid.flags = 1;  /* active */
 		memcpy(extra, sm->associnfo.associate_essid.data, sm->associnfo.associate_essid.len);
 	}
-	spin_unlock_irqrestore(&sm->lock, flags);
+	mutex_unlock(&sm->associnfo.mutex);
+
 	return 0;
 }
 EXPORT_SYMBOL_GPL(ieee80211softmac_wx_get_essid);
@@ -322,15 +322,15 @@ ieee80211softmac_wx_get_wap(struct net_d
 {
 	struct ieee80211softmac_device *mac = ieee80211_priv(net_dev);
 	int err = 0;
-	unsigned long flags;
 
-	spin_lock_irqsave(&mac->lock, flags);
+	mutex_lock(&mac->associnfo.mutex);
 	if (mac->associnfo.bssvalid)
 		memcpy(data->ap_addr.sa_data, mac->associnfo.bssid, ETH_ALEN);
 	else
 		memset(data->ap_addr.sa_data, 0xff, ETH_ALEN);
 	data->ap_addr.sa_family = ARPHRD_ETHER;
-	spin_unlock_irqrestore(&mac->lock, flags);
+	mutex_unlock(&mac->associnfo.mutex);
+
 	return err;
 }
 EXPORT_SYMBOL_GPL(ieee80211softmac_wx_get_wap);
@@ -342,28 +342,27 @@ ieee80211softmac_wx_set_wap(struct net_d
 			    char *extra)
 {
 	struct ieee80211softmac_device *mac = ieee80211_priv(net_dev);
-	unsigned long flags;
 
 	/* sanity check */
 	if (data->ap_addr.sa_family != ARPHRD_ETHER) {
 		return -EINVAL;
 	}
 
-	spin_lock_irqsave(&mac->lock, flags);
+	mutex_lock(&mac->associnfo.mutex);
 	if (is_broadcast_ether_addr(data->ap_addr.sa_data)) {
 		/* the bssid we have is not to be fixed any longer,
 		 * and we should reassociate to the best AP. */
 		mac->associnfo.bssfixed = 0;
 		/* force reassociation */
 		mac->associnfo.bssvalid = 0;
-		if (mac->associated)
+		if (mac->associnfo.associated)
 			schedule_work(&mac->associnfo.work);
 	} else if (is_zero_ether_addr(data->ap_addr.sa_data)) {
 		/* the bssid we have is no longer fixed */
 		mac->associnfo.bssfixed = 0;
         } else {
 		if (!memcmp(mac->associnfo.bssid, data->ap_addr.sa_data, ETH_ALEN)) {
-			if (mac->associnfo.associating || mac->associated) {
+			if (mac->associnfo.associating || mac->associnfo.associated) {
 			/* bssid unchanged and associated or associating - just return */
 				goto out;
 			}
@@ -378,7 +377,8 @@ ieee80211softmac_wx_set_wap(struct net_d
         }
 
  out:
-	spin_unlock_irqrestore(&mac->lock, flags);
+	mutex_unlock(&mac->associnfo.mutex);
+
 	return 0;
 }
 EXPORT_SYMBOL_GPL(ieee80211softmac_wx_set_wap);
@@ -394,7 +394,8 @@ ieee80211softmac_wx_set_genie(struct net
 	int err = 0;
 	char *buf;
 	int i;
-	
+
+	mutex_lock(&mac->associnfo.mutex);
 	spin_lock_irqsave(&mac->lock, flags);
 	/* bleh. shouldn't be locked for that kmalloc... */
 
@@ -432,6 +433,8 @@ ieee80211softmac_wx_set_genie(struct net
 
  out:	
 	spin_unlock_irqrestore(&mac->lock, flags);
+	mutex_unlock(&mac->associnfo.mutex);
+
 	return err;
 }
 EXPORT_SYMBOL_GPL(ieee80211softmac_wx_set_genie);
@@ -446,7 +449,8 @@ ieee80211softmac_wx_get_genie(struct net
 	unsigned long flags;
 	int err = 0;
 	int space = wrqu->data.length;
-	
+
+	mutex_lock(&mac->associnfo.mutex);
 	spin_lock_irqsave(&mac->lock, flags);
 	
 	wrqu->data.length = 0;
@@ -459,6 +463,8 @@ ieee80211softmac_wx_get_genie(struct net
 			err = -E2BIG;
 	}
 	spin_unlock_irqrestore(&mac->lock, flags);
+	mutex_lock(&mac->associnfo.mutex);
+
 	return err;
 }
 EXPORT_SYMBOL_GPL(ieee80211softmac_wx_get_genie);
@@ -473,10 +479,13 @@ ieee80211softmac_wx_set_mlme(struct net_
 	struct iw_mlme *mlme = (struct iw_mlme *)extra;
 	u16 reason = cpu_to_le16(mlme->reason_code);
 	struct ieee80211softmac_network *net;
+	int err = -EINVAL;
+
+	mutex_lock(&mac->associnfo.mutex);
 
 	if (memcmp(mac->associnfo.bssid, mlme->addr.sa_data, ETH_ALEN)) {
 		printk(KERN_DEBUG PFX "wx_set_mlme: requested operation on net we don't use\n");
-		return -EINVAL;
+		goto out;
 	}
 
 	switch (mlme->cmd) {
@@ -484,14 +493,22 @@ ieee80211softmac_wx_set_mlme(struct net_
 		net = ieee80211softmac_get_network_by_bssid_locked(mac, mlme->addr.sa_data);
 		if (!net) {
 			printk(KERN_DEBUG PFX "wx_set_mlme: we should know the net here...\n");
-			return -EINVAL;
+			goto out;
 		}
 		return ieee80211softmac_deauth_req(mac, net, reason);
 	case IW_MLME_DISASSOC:
 		ieee80211softmac_send_disassoc_req(mac, reason);
-		return 0;
+		mac->associnfo.associated = 0;
+		mac->associnfo.associating = 0;
+		err = 0;
+		goto out;
 	default:
-		return -EOPNOTSUPP;
+		err = -EOPNOTSUPP;
 	}
+
+out:
+	mutex_unlock(&mac->associnfo.mutex);
+
+	return err;
 }
 EXPORT_SYMBOL_GPL(ieee80211softmac_wx_set_mlme);
-- 
John W. Linville
linville@tuxdriver.com
