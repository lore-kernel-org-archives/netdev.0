From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'upstream' branch of wireless-2.6
Date: Mon, 11 Sep 2006 19:59:13 -0400
Message-ID: <20060911235912.GC32752@tuxdriver.com>
References: <20060911235803.GB32752@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:14 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S965194AbWIKX7z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2006 19:59:55 -0400
To: jeff@garzik.org
Content-Disposition: inline
In-Reply-To: <20060911235803.GB32752@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit 34fa0e319c760189f1fc226acc5b3b387dc58099:
  John W. Linville:
        Merge branch 'upstream-fixes' into upstream

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream

Christian Steineck:
      hostap_cs: added support for Proxim Harmony PCI W-Lan card

Daniel Drake:
      zd1211rw: Add ID for Siemens Gigaset USB Stick 54
      zd1211rw: Add ID for Asus WL-159g

Jean Tourrilhes:
      Prism54 : add bitrates to scan result

Larry Finger:
      bcm43xx-softmac: Init, shutdown and restart fixes
      bcm43xx: Correct out of sequence initialization step
      bcm43xx: remove dead statistics code
      bcm43xx: Add firmware version printout
      bcm43xx: ucode debug status via sysfs
      bcm43xx: remove dead code in bcm43xx_sysfs.c

Ulrich Kunitz:
      zd1211rw: Removed unneeded packed attributes

 drivers/net/wireless/bcm43xx/bcm43xx.h       |    7 ++
 drivers/net/wireless/bcm43xx/bcm43xx_main.c  |   78 +++++++++++++++++---------
 drivers/net/wireless/bcm43xx/bcm43xx_main.h  |    3 +
 drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c |   74 ++++++++++++++++++++++---
 drivers/net/wireless/hostap/hostap_cs.c      |    1 
 drivers/net/wireless/prism54/isl_ioctl.c     |   30 ++++++++++
 drivers/net/wireless/zd1211rw/zd_ieee80211.h |    2 -
 drivers/net/wireless/zd1211rw/zd_mac.c       |    2 -
 drivers/net/wireless/zd1211rw/zd_mac.h       |    4 +
 drivers/net/wireless/zd1211rw/zd_usb.c       |    2 +
 drivers/net/wireless/zd1211rw/zd_usb.h       |   14 ++---
 11 files changed, 169 insertions(+), 48 deletions(-)

diff --git a/drivers/net/wireless/bcm43xx/bcm43xx.h b/drivers/net/wireless/bcm43xx/bcm43xx.h
index 62fd7e2..6d4ea36 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx.h
+++ b/drivers/net/wireless/bcm43xx/bcm43xx.h
@@ -306,6 +306,13 @@ #define BCM43xx_SBF_NO_SSID_BCAST	0x0800
 #define BCM43xx_SBF_TIME_UPDATE		0x10000000
 #define BCM43xx_SBF_80000000		0x80000000 /*FIXME: fix name*/
 
+/* Microcode */
+#define BCM43xx_UCODE_REVISION		0x0000
+#define BCM43xx_UCODE_PATCHLEVEL	0x0002
+#define BCM43xx_UCODE_DATE		0x0004
+#define BCM43xx_UCODE_TIME		0x0006
+#define BCM43xx_UCODE_STATUS		0x0040
+
 /* MicrocodeFlagsBitfield (addr + lo-word values?)*/
 #define BCM43xx_UCODEFLAGS_OFFSET	0x005E
 
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
index 966815b..cb9a3ae 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -519,6 +519,7 @@ static int bcm43xx_disable_interrupts_sy
 		return -EBUSY;
 	}
 	bcm43xx_interrupt_disable(bcm, BCM43xx_IRQ_ALL);
+	bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_MASK); /* flush */
 	spin_unlock_irqrestore(&bcm->irq_lock, flags);
 	bcm43xx_synchronize_irq(bcm);
 
@@ -1545,17 +1546,7 @@ static void handle_irq_noise(struct bcm4
 		else
 			average -= 48;
 
-/* FIXME: This is wrong, but people want fancy stats. well... */
-bcm->stats.noise = average;
-		if (average > -65)
-			bcm->stats.link_quality = 0;
-		else if (average > -75)
-			bcm->stats.link_quality = 1;
-		else if (average > -85)
-			bcm->stats.link_quality = 2;
-		else
-			bcm->stats.link_quality = 3;
-//		dprintk(KERN_INFO PFX "Link Quality: %u (avg was %d)\n", bcm->stats.link_quality, average);
+		bcm->stats.noise = average;
 drop_calculation:
 		bcm->noisecalc.calculation_running = 0;
 		return;
@@ -2393,6 +2384,33 @@ static int bcm43xx_chip_init(struct bcm4
 	}
 	bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON); /* dummy read */
 
+	value16 = bcm43xx_shm_read16(bcm, BCM43xx_SHM_SHARED,
+				     BCM43xx_UCODE_REVISION);
+
+	dprintk(KERN_INFO PFX "Microcode rev 0x%x, pl 0x%x "
+		"(20%.2i-%.2i-%.2i  %.2i:%.2i:%.2i)\n", value16,
+		bcm43xx_shm_read16(bcm, BCM43xx_SHM_SHARED,
+				   BCM43xx_UCODE_PATCHLEVEL),
+		(bcm43xx_shm_read16(bcm, BCM43xx_SHM_SHARED,
+				    BCM43xx_UCODE_DATE) >> 12) & 0xf,
+		(bcm43xx_shm_read16(bcm, BCM43xx_SHM_SHARED,
+				    BCM43xx_UCODE_DATE) >> 8) & 0xf,
+		bcm43xx_shm_read16(bcm, BCM43xx_SHM_SHARED,
+				   BCM43xx_UCODE_DATE) & 0xff,
+		(bcm43xx_shm_read16(bcm, BCM43xx_SHM_SHARED,
+				   BCM43xx_UCODE_TIME) >> 11) & 0x1f,
+		(bcm43xx_shm_read16(bcm, BCM43xx_SHM_SHARED,
+				   BCM43xx_UCODE_TIME) >> 5) & 0x3f,
+		bcm43xx_shm_read16(bcm, BCM43xx_SHM_SHARED,
+				   BCM43xx_UCODE_TIME) & 0x1f);
+
+	if ( value16 > 0x128 ) {
+		dprintk(KERN_ERR PFX
+			"Firmware: no support for microcode rev > 0x128\n");
+		err = -1;
+		goto err_release_fw;
+	}
+
 	err = bcm43xx_gpio_init(bcm);
 	if (err)
 		goto err_release_fw;
@@ -3150,6 +3168,7 @@ static void bcm43xx_periodic_work_handle
 		/* Periodic work will take a long time, so we want it to
 		 * be preemtible.
 		 */
+		mutex_lock(&bcm->mutex);
 		netif_stop_queue(bcm->net_dev);
 		synchronize_net();
 		spin_lock_irqsave(&bcm->irq_lock, flags);
@@ -3158,7 +3177,6 @@ static void bcm43xx_periodic_work_handle
 			bcm43xx_pio_freeze_txqueues(bcm);
 		savedirqs = bcm43xx_interrupt_disable(bcm, BCM43xx_IRQ_ALL);
 		spin_unlock_irqrestore(&bcm->irq_lock, flags);
-		mutex_lock(&bcm->mutex);
 		bcm43xx_synchronize_irq(bcm);
 	} else {
 		/* Periodic work should take short time, so we want low
@@ -3172,13 +3190,11 @@ static void bcm43xx_periodic_work_handle
 
 	if (badness > BADNESS_LIMIT) {
 		spin_lock_irqsave(&bcm->irq_lock, flags);
-		if (likely(bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED)) {
-			tasklet_enable(&bcm->isr_tasklet);
-			bcm43xx_interrupt_enable(bcm, savedirqs);
-			if (bcm43xx_using_pio(bcm))
-				bcm43xx_pio_thaw_txqueues(bcm);
-			bcm43xx_mac_enable(bcm);
-		}
+		tasklet_enable(&bcm->isr_tasklet);
+		bcm43xx_interrupt_enable(bcm, savedirqs);
+		if (bcm43xx_using_pio(bcm))
+			bcm43xx_pio_thaw_txqueues(bcm);
+		bcm43xx_mac_enable(bcm);
 		netif_wake_queue(bcm->net_dev);
 	}
 	mmiowb();
@@ -3186,12 +3202,12 @@ static void bcm43xx_periodic_work_handle
 	mutex_unlock(&bcm->mutex);
 }
 
-static void bcm43xx_periodic_tasks_delete(struct bcm43xx_private *bcm)
+void bcm43xx_periodic_tasks_delete(struct bcm43xx_private *bcm)
 {
 	cancel_rearming_delayed_work(&bcm->periodic_work);
 }
 
-static void bcm43xx_periodic_tasks_setup(struct bcm43xx_private *bcm)
+void bcm43xx_periodic_tasks_setup(struct bcm43xx_private *bcm)
 {
 	struct work_struct *work = &(bcm->periodic_work);
 
@@ -3539,14 +3555,13 @@ static int bcm43xx_init_board(struct bcm
 	err = bcm43xx_select_wireless_core(bcm, -1);
 	if (err)
 		goto err_crystal_off;
-
-	bcm43xx_periodic_tasks_setup(bcm);
 	err = bcm43xx_sysfs_register(bcm);
 	if (err)
 		goto err_wlshutdown;
 	err = bcm43xx_rng_init(bcm);
 	if (err)
 		goto err_sysfs_unreg;
+	bcm43xx_periodic_tasks_setup(bcm);
 
 	/*FIXME: This should be handled by softmac instead. */
 	schedule_work(&bcm->softmac->associnfo.work);
@@ -3969,6 +3984,7 @@ static int bcm43xx_net_stop(struct net_d
 	err = bcm43xx_disable_interrupts_sync(bcm);
 	assert(!err);
 	bcm43xx_free_board(bcm);
+	flush_scheduled_work();
 
 	return 0;
 }
@@ -4119,11 +4135,16 @@ static void bcm43xx_chip_reset(void *_bc
 {
 	struct bcm43xx_private *bcm = _bcm;
 	struct bcm43xx_phyinfo *phy;
-	int err;
+	int err = -ENODEV;
 
 	mutex_lock(&(bcm)->mutex);
-	phy = bcm43xx_current_phy(bcm);
-	err = bcm43xx_select_wireless_core(bcm, phy->type);
+	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED) {
+		bcm43xx_periodic_tasks_delete(bcm);
+		phy = bcm43xx_current_phy(bcm);
+		err = bcm43xx_select_wireless_core(bcm, phy->type);
+		if (!err)
+			bcm43xx_periodic_tasks_setup(bcm);
+	}
 	mutex_unlock(&(bcm)->mutex);
 
 	printk(KERN_ERR PFX "Controller restart%s\n",
@@ -4132,11 +4153,12 @@ static void bcm43xx_chip_reset(void *_bc
 
 /* Hard-reset the chip.
  * This can be called from interrupt or process context.
+ * bcm->irq_lock must be locked.
  */
 void bcm43xx_controller_restart(struct bcm43xx_private *bcm, const char *reason)
 {
-	assert(bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED);
-	bcm43xx_set_status(bcm, BCM43xx_STAT_RESTARTING);
+	if (bcm43xx_status(bcm) != BCM43xx_STAT_INITIALIZED)
+		return;
 	printk(KERN_ERR PFX "Controller RESET (%s) ...\n", reason);
 	INIT_WORK(&bcm->restart_work, bcm43xx_chip_reset, bcm);
 	schedule_work(&bcm->restart_work);
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_main.h b/drivers/net/wireless/bcm43xx/bcm43xx_main.h
index 505c86e..f763571 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_main.h
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.h
@@ -141,6 +141,9 @@ void bcm43xx_wireless_core_reset(struct 
 void bcm43xx_mac_suspend(struct bcm43xx_private *bcm);
 void bcm43xx_mac_enable(struct bcm43xx_private *bcm);
 
+void bcm43xx_periodic_tasks_delete(struct bcm43xx_private *bcm);
+void bcm43xx_periodic_tasks_setup(struct bcm43xx_private *bcm);
+
 void bcm43xx_controller_restart(struct bcm43xx_private *bcm, const char *reason);
 
 int bcm43xx_sprom_read(struct bcm43xx_private *bcm, u16 *sprom);
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c b/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c
index ece3351..c71b998 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c
@@ -176,7 +176,6 @@ static ssize_t bcm43xx_attr_interfmode_s
 					    char *buf)
 {
 	struct bcm43xx_private *bcm = dev_to_bcm(dev);
-	int err;
 	ssize_t count = 0;
 
 	if (!capable(CAP_NET_ADMIN))
@@ -197,11 +196,10 @@ static ssize_t bcm43xx_attr_interfmode_s
 	default:
 		assert(0);
 	}
-	err = 0;
 
 	mutex_unlock(&bcm->mutex);
 
-	return err ? err : count;
+	return count;
 
 }
 
@@ -259,7 +257,6 @@ static ssize_t bcm43xx_attr_preamble_sho
 					  char *buf)
 {
 	struct bcm43xx_private *bcm = dev_to_bcm(dev);
-	int err;
 	ssize_t count;
 
 	if (!capable(CAP_NET_ADMIN))
@@ -272,10 +269,9 @@ static ssize_t bcm43xx_attr_preamble_sho
 	else
 		count = snprintf(buf, PAGE_SIZE, "0 (Short Preamble disabled)\n");
 
-	err = 0;
 	mutex_unlock(&bcm->mutex);
 
-	return err ? err : count;
+	return count;
 }
 
 static ssize_t bcm43xx_attr_preamble_store(struct device *dev,
@@ -284,7 +280,6 @@ static ssize_t bcm43xx_attr_preamble_sto
 {
 	struct bcm43xx_private *bcm = dev_to_bcm(dev);
 	unsigned long flags;
-	int err;
 	int value;
 
 	if (!capable(CAP_NET_ADMIN))
@@ -298,11 +293,10 @@ static ssize_t bcm43xx_attr_preamble_sto
 
 	bcm->short_preamble = !!value;
 
-	err = 0;
 	spin_unlock_irqrestore(&bcm->irq_lock, flags);
 	mutex_unlock(&bcm->mutex);
 
-	return err ? err : count;
+	return count;
 }
 
 static DEVICE_ATTR(shortpreamble, 0644,
@@ -333,8 +327,11 @@ static ssize_t bcm43xx_attr_phymode_stor
 		goto out;
 	}
 
+	bcm43xx_periodic_tasks_delete(bcm);
 	mutex_lock(&(bcm)->mutex);
 	err = bcm43xx_select_wireless_core(bcm, phytype);
+	if (!err)
+		bcm43xx_periodic_tasks_setup(bcm);
 	mutex_unlock(&(bcm)->mutex);
 	if (err == -ESRCH)
 		err = -ENODEV;
@@ -373,6 +370,59 @@ static DEVICE_ATTR(phymode, 0644,
 		   bcm43xx_attr_phymode_show,
 		   bcm43xx_attr_phymode_store);
 
+static ssize_t bcm43xx_attr_microcode_show(struct device *dev,
+					   struct device_attribute *attr,
+					   char *buf)
+{
+	unsigned long flags;
+	struct bcm43xx_private *bcm = dev_to_bcm(dev);
+	ssize_t count = 0;
+	u16 status;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	mutex_lock(&(bcm)->mutex);
+	spin_lock_irqsave(&bcm->irq_lock, flags);
+	status = bcm43xx_shm_read16(bcm, BCM43xx_SHM_SHARED,
+				    BCM43xx_UCODE_STATUS);
+
+	spin_unlock_irqrestore(&bcm->irq_lock, flags);
+	mutex_unlock(&(bcm)->mutex);
+	switch (status) {
+	case 0x0000:
+		count = snprintf(buf, PAGE_SIZE, "0x%.4x (invalid)\n",
+				 status);
+		break;
+	case 0x0001:
+		count = snprintf(buf, PAGE_SIZE, "0x%.4x (init)\n",
+				 status);
+		break;
+	case 0x0002:
+		count = snprintf(buf, PAGE_SIZE, "0x%.4x (active)\n",
+				 status);
+		break;
+	case 0x0003:
+		count = snprintf(buf, PAGE_SIZE, "0x%.4x (suspended)\n",
+				 status);
+		break;
+	case 0x0004:
+		count = snprintf(buf, PAGE_SIZE, "0x%.4x (asleep)\n",
+				 status);
+		break;
+	default:
+		count = snprintf(buf, PAGE_SIZE, "0x%.4x (unknown)\n",
+				 status);
+		break;
+	}
+
+	return count;
+}
+
+static DEVICE_ATTR(microcodestatus, 0444,
+		   bcm43xx_attr_microcode_show,
+		   NULL);
+
 int bcm43xx_sysfs_register(struct bcm43xx_private *bcm)
 {
 	struct device *dev = &bcm->pci_dev->dev;
@@ -392,9 +442,14 @@ int bcm43xx_sysfs_register(struct bcm43x
 	err = device_create_file(dev, &dev_attr_phymode);
 	if (err)
 		goto err_remove_shortpreamble;
+	err = device_create_file(dev, &dev_attr_microcodestatus);
+	if (err)
+		goto err_remove_phymode;
 
 out:
 	return err;
+err_remove_phymode:
+	device_remove_file(dev, &dev_attr_phymode);
 err_remove_shortpreamble:
 	device_remove_file(dev, &dev_attr_shortpreamble);
 err_remove_interfmode:
@@ -408,6 +463,7 @@ void bcm43xx_sysfs_unregister(struct bcm
 {
 	struct device *dev = &bcm->pci_dev->dev;
 
+	device_remove_file(dev, &dev_attr_microcodestatus);
 	device_remove_file(dev, &dev_attr_phymode);
 	device_remove_file(dev, &dev_attr_shortpreamble);
 	device_remove_file(dev, &dev_attr_interference);
diff --git a/drivers/net/wireless/hostap/hostap_cs.c b/drivers/net/wireless/hostap/hostap_cs.c
index 52e6df5..686d895 100644
--- a/drivers/net/wireless/hostap/hostap_cs.c
+++ b/drivers/net/wireless/hostap/hostap_cs.c
@@ -847,6 +847,7 @@ static struct pcmcia_device_id hostap_cs
 	PCMCIA_DEVICE_MANF_CARD(0xd601, 0x0002),
 	PCMCIA_DEVICE_MANF_CARD(0xd601, 0x0005),
 	PCMCIA_DEVICE_MANF_CARD(0xd601, 0x0010),
+	PCMCIA_DEVICE_MANF_CARD(0x0126, 0x0002),
 	PCMCIA_DEVICE_MANF_CARD_PROD_ID1(0x0156, 0x0002, "INTERSIL",
 					 0x74c5e40d),
 	PCMCIA_DEVICE_MANF_CARD_PROD_ID1(0x0156, 0x0002, "Intersil",
diff --git a/drivers/net/wireless/prism54/isl_ioctl.c b/drivers/net/wireless/prism54/isl_ioctl.c
index 0c30fe7..c09fbf7 100644
--- a/drivers/net/wireless/prism54/isl_ioctl.c
+++ b/drivers/net/wireless/prism54/isl_ioctl.c
@@ -46,6 +46,10 @@ static size_t prism54_wpa_bss_ie_get(isl
 static int prism54_set_wpa(struct net_device *, struct iw_request_info *,
 				__u32 *, char *);
 
+/* In 500 kbps */
+static const unsigned char scan_rate_list[] = { 2, 4, 11, 22,
+						12, 18, 24, 36,
+						48, 72, 96, 108 };
 
 /**
  * prism54_mib_mode_helper - MIB change mode helper function
@@ -644,6 +648,32 @@ #define CAP_CRYPT 0x10
 		current_ev = iwe_stream_add_point(current_ev, end_buf,
 				&iwe, wpa_ie);
 	}
+	/* Do the bitrates */
+	{
+		char *	current_val = current_ev + IW_EV_LCP_LEN;
+		int i;
+		int mask;
+
+		iwe.cmd = SIOCGIWRATE;
+		/* Those two flags are ignored... */
+		iwe.u.bitrate.fixed = iwe.u.bitrate.disabled = 0;
+
+		/* Parse the bitmask */
+		mask = 0x1;
+		for(i = 0; i < sizeof(scan_rate_list); i++) {
+			if(bss->rates & mask) {
+				iwe.u.bitrate.value = (scan_rate_list[i] * 500000);
+				current_val = iwe_stream_add_value(current_ev, current_val,
+								   end_buf, &iwe,
+								   IW_EV_PARAM_LEN);
+			}
+			mask <<= 1;
+		}
+		/* Check if we added any event */
+		if ((current_val - current_ev) > IW_EV_LCP_LEN)
+			current_ev = current_val;
+	}
+
 	return current_ev;
 }
 
diff --git a/drivers/net/wireless/zd1211rw/zd_ieee80211.h b/drivers/net/wireless/zd1211rw/zd_ieee80211.h
index 3632989..f63245b 100644
--- a/drivers/net/wireless/zd1211rw/zd_ieee80211.h
+++ b/drivers/net/wireless/zd1211rw/zd_ieee80211.h
@@ -64,7 +64,7 @@ struct cck_plcp_header {
 	u8 service;
 	__le16 length;
 	__le16 crc16;
-} __attribute__((packed));
+};
 
 static inline u8 zd_cck_plcp_header_rate(const struct cck_plcp_header *header)
 {
diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wireless/zd1211rw/zd_mac.c
index 0ddccf8..1989f1c 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -714,7 +714,7 @@ struct zd_rt_hdr {
 	u8  rt_rate;
 	u16 rt_channel;
 	u16 rt_chbitmask;
-} __attribute__((packed));
+};
 
 static void fill_rt_header(void *buffer, struct zd_mac *mac,
 	                   const struct ieee80211_rx_stats *stats,
diff --git a/drivers/net/wireless/zd1211rw/zd_mac.h b/drivers/net/wireless/zd1211rw/zd_mac.h
index 2b596cc..29b51fd 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.h
+++ b/drivers/net/wireless/zd1211rw/zd_mac.h
@@ -82,7 +82,7 @@ #define ZD_PLCP_HEADER_SIZE		5
 struct rx_length_info {
 	__le16 length[3];
 	__le16 tag;
-} __attribute__((packed));
+};
 
 #define RX_LENGTH_INFO_TAG		0x697e
 
@@ -93,7 +93,7 @@ struct rx_status {
 	u8 signal_quality_ofdm;
 	u8 decryption_type;
 	u8 frame_status;
-} __attribute__((packed));
+};
 
 /* rx_status field decryption_type */
 #define ZD_RX_NO_WEP	0
diff --git a/drivers/net/wireless/zd1211rw/zd_usb.c b/drivers/net/wireless/zd1211rw/zd_usb.c
index 47489fe..31027e5 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -44,6 +44,8 @@ static struct usb_device_id usb_ids[] = 
 	{ USB_DEVICE(0x1740, 0x2000), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x157e, 0x3204), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x0586, 0x3402), .driver_info = DEVICE_ZD1211 },
+	{ USB_DEVICE(0x0b3b, 0x5630), .driver_info = DEVICE_ZD1211 },
+	{ USB_DEVICE(0x0b05, 0x170c), .driver_info = DEVICE_ZD1211 },
 	/* ZD1211B */
 	{ USB_DEVICE(0x0ace, 0x1215), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x157e, 0x300d), .driver_info = DEVICE_ZD1211B },
diff --git a/drivers/net/wireless/zd1211rw/zd_usb.h b/drivers/net/wireless/zd1211rw/zd_usb.h
index 92746f7..ded39de 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.h
+++ b/drivers/net/wireless/zd1211rw/zd_usb.h
@@ -74,17 +74,17 @@ enum control_requests {
 struct usb_req_read_regs {
 	__le16 id;
 	__le16 addr[0];
-} __attribute__((packed));
+};
 
 struct reg_data {
 	__le16 addr;
 	__le16 value;
-} __attribute__((packed));
+};
 
 struct usb_req_write_regs {
 	__le16 id;
 	struct reg_data reg_writes[0];
-} __attribute__((packed));
+};
 
 enum {
 	RF_IF_LE = 0x02,
@@ -101,7 +101,7 @@ struct usb_req_rfwrite {
 	/* RF2595: 24 */
 	__le16 bit_values[0];
 	/* (CR203 & ~(RF_IF_LE | RF_CLK | RF_DATA)) | (bit ? RF_DATA : 0) */
-} __attribute__((packed));
+};
 
 /* USB interrupt */
 
@@ -118,12 +118,12 @@ enum usb_int_flags {
 struct usb_int_header {
 	u8 type;	/* must always be 1 */
 	u8 id;
-} __attribute__((packed));
+};
 
 struct usb_int_regs {
 	struct usb_int_header hdr;
 	struct reg_data regs[0];
-} __attribute__((packed));
+};
 
 struct usb_int_retry_fail {
 	struct usb_int_header hdr;
@@ -131,7 +131,7 @@ struct usb_int_retry_fail {
 	u8 _dummy;
 	u8 addr[ETH_ALEN];
 	u8 ibss_wakeup_dest;
-} __attribute__((packed));
+};
 
 struct read_regs_int {
 	struct completion completion;
-- 
John W. Linville
linville@tuxdriver.com
