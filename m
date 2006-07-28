From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: What's new in 'bcm43xx' branch of wireless-2.6?
Date: Thu, 27 Jul 2006 20:37:53 -0400
Message-ID: <20060728003753.GC11621@tuxdriver.com>
References: <20060728002206.GA11621@tuxdriver.com>
	<20060728002358.GB11621@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Content-Disposition: inline
In-Reply-To: <20060728002358.GB11621-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
List-Unsubscribe: <http://bat.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <http://bat.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <http://bat.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

As most of us are painfully aware, there is a blockage in getting
bcm43xx patches upstream.(*)

In order to keep upstream bcm43xx development moving, I have opened
a bcm43xx branch in wireless-2.6.  Please make sure that any patches
submitted upstream can apply to that branch (at least w/ minimal
effort) if at all possible.  Critical (e.g. security) fixes would be
the exception, since we may want to get those upstream sooner than we
can count on resolving the issue blocking upstream progress of bcm43xx.

I appreciate your cooperation.  If anyone wants to be a hero, finding
a way to get rid of the potentially long busy waits in bcm43xx is
the ticket. :-)

Thanks,

John

(*) http://marc.theaimsgroup.com/?l=linux-netdev&m=115137403631920&w=2

---

The following changes since commit 8f0f850e240df5bea027caeb1723142c50e37e57:
  Daniel Drake:
        softmac: Add MAINTAINERS entry

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git bcm43xx

John W. Linville:
      bcm43xx: fix-up build breakage from merging patches out of order

Larry Finger:
      bcm43xx: improved statistics

Michael Buesch:
      bcm43xx: suspend MAC while executing long pwork
      bcm43xx: lower mac_suspend udelay
      bcm43xx: fix mac_suspend refcount
      bcm43xx: init routine rewrite

 drivers/net/wireless/bcm43xx/bcm43xx.h         |   52 +-
 drivers/net/wireless/bcm43xx/bcm43xx_debugfs.c |   46 ++
 drivers/net/wireless/bcm43xx/bcm43xx_debugfs.h |    1 
 drivers/net/wireless/bcm43xx/bcm43xx_main.c    |  686 ++++++++++++++----------
 drivers/net/wireless/bcm43xx/bcm43xx_main.h    |    3 
 drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c   |   70 ++
 drivers/net/wireless/bcm43xx/bcm43xx_wx.c      |   28 +
 drivers/net/wireless/bcm43xx/bcm43xx_xmit.c    |    5 
 8 files changed, 564 insertions(+), 327 deletions(-)

diff --git a/drivers/net/wireless/bcm43xx/bcm43xx.h b/drivers/net/wireless/bcm43xx/bcm43xx.h
index ee6571e..c6ee1e9 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx.h
+++ b/drivers/net/wireless/bcm43xx/bcm43xx.h
@@ -504,6 +504,12 @@ struct bcm43xx_phyinfo {
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
 
 
@@ -593,12 +599,14 @@ struct bcm43xx_coreinfo {
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
@@ -647,7 +655,10 @@ enum {
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
@@ -721,10 +732,6 @@ #endif
 	struct bcm43xx_coreinfo core_80211[ BCM43xx_MAX_80211_CORES ];
 	/* Additional information, specific to the 80211 cores. */
 	struct bcm43xx_coreinfo_80211 core_80211_ext[ BCM43xx_MAX_80211_CORES ];
-	/* Index of the current 80211 core. If current_core is not
-	 * an 80211 core, this is -1.
-	 */
-	int current_80211_core_idx;
 	/* Number of available 80211 cores. */
 	int nr_80211_available;
 
@@ -737,6 +744,8 @@ #endif
 	u32 irq_savedstate;
 	/* Link Quality calculation context. */
 	struct bcm43xx_noise_calculation noisecalc;
+	/* if > 0 MAC is suspended. if == 0 MAC is enabled. */
+	int mac_suspended;
 
 	/* Threshold values. */
 	//TODO: The RTS thr has to be _used_. Currently, it is only set via WX.
@@ -759,12 +768,6 @@ #endif
 	struct bcm43xx_key key[54];
 	u8 default_key_idx;
 
-	/* Firmware. */
-	const struct firmware *ucode;
-	const struct firmware *pcm;
-	const struct firmware *initvals0;
-	const struct firmware *initvals1;
-
 	/* Random Number Generator. */
 	struct hwrng rng;
 	char rng_name[20 + 1];
@@ -827,34 +830,33 @@ #endif
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
 
 
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_debugfs.c b/drivers/net/wireless/bcm43xx/bcm43xx_debugfs.c
index 2600ee4..923275e 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_debugfs.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_debugfs.c
@@ -316,6 +316,42 @@ static ssize_t txstat_read_file(struct f
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
+	mutex_lock(&(bcm)->mutex);
+	spin_lock_irqsave(&(bcm)->irq_lock, flags);
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
+	spin_unlock_irqrestore(&(bcm)->irq_lock, flags);
+	mutex_unlock(&(bcm)->mutex);
+out_up:
+	up(&big_buffer_sem);
+	return res;
+}
+
 #undef fappend
 
 
@@ -349,6 +385,11 @@ static struct file_operations txstat_fop
 	.open = open_file_generic,
 };
 
+static struct file_operations restart_fops = {
+	.write = restart_write_file,
+	.open = open_file_generic,
+};
+
 
 void bcm43xx_debugfs_add_device(struct bcm43xx_private *bcm)
 {
@@ -400,6 +441,10 @@ void bcm43xx_debugfs_add_device(struct b
 						bcm, &txstat_fops);
 	if (!e->dentry_txstat)
 		printk(KERN_ERR PFX "debugfs: creating \"tx_status\" for \"%s\" failed!\n", devdir);
+	e->dentry_restart = debugfs_create_file("restart", 0222, e->subdir,
+						bcm, &restart_fops);
+	if (!e->dentry_restart)
+		printk(KERN_ERR PFX "debugfs: creating \"restart\" for \"%s\" failed!\n", devdir);
 }
 
 void bcm43xx_debugfs_remove_device(struct bcm43xx_private *bcm)
@@ -415,6 +460,7 @@ void bcm43xx_debugfs_remove_device(struc
 	debugfs_remove(e->dentry_devinfo);
 	debugfs_remove(e->dentry_tsf);
 	debugfs_remove(e->dentry_txstat);
+	debugfs_remove(e->dentry_restart);
 	debugfs_remove(e->subdir);
 	kfree(e->xmitstatus_buffer);
 	kfree(e->xmitstatus_print_buffer);
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_debugfs.h b/drivers/net/wireless/bcm43xx/bcm43xx_debugfs.h
index 50ce267..a40d1af 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_debugfs.h
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_debugfs.h
@@ -20,6 +20,7 @@ struct bcm43xx_dfsentry {
 	struct dentry *dentry_spromdump;
 	struct dentry *dentry_tsf;
 	struct dentry *dentry_txstat;
+	struct dentry *dentry_restart;
 
 	struct bcm43xx_private *bcm;
 
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
index ab3a0ee..24d531e 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -509,23 +509,19 @@ static void bcm43xx_synchronize_irq(stru
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
 
@@ -537,7 +533,6 @@ static int bcm43xx_read_radioinfo(struct
 	u16 manufact;
 	u16 version;
 	u8 revision;
-	s8 i;
 
 	if (bcm->chip_id == 0x4317) {
 		if (bcm->chip_rev == 0x00)
@@ -580,20 +575,11 @@ static int bcm43xx_read_radioinfo(struct
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
@@ -1250,10 +1236,6 @@ int bcm43xx_switch_core(struct bcm43xx_p
 		goto out;
 
 	bcm->current_core = new_core;
-	bcm->current_80211_core_idx = -1;
-	if (new_core->id == BCM43xx_COREID_80211)
-		bcm->current_80211_core_idx = (int)(new_core - &(bcm->core_80211[0]));
-
 out:
 	return err;
 }
@@ -1423,43 +1405,23 @@ static void bcm43xx_wireless_core_disabl
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
@@ -1885,14 +1847,8 @@ static irqreturn_t bcm43xx_interrupt_han
 
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
@@ -1930,16 +1886,18 @@ out:
 
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
@@ -1950,11 +1908,11 @@ static int bcm43xx_request_firmware(stru
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
@@ -1963,12 +1921,12 @@ static int bcm43xx_request_firmware(stru
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
@@ -1977,7 +1935,7 @@ static int bcm43xx_request_firmware(stru
 		}
 	}
 
-	if (!bcm->initvals0) {
+	if (!phy->initvals0) {
 		if (rev == 2 || rev == 4) {
 			switch (phy->type) {
 			case BCM43xx_PHYTYPE_A:
@@ -2008,20 +1966,20 @@ static int bcm43xx_request_firmware(stru
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
 
@@ -2043,14 +2001,14 @@ static int bcm43xx_request_firmware(stru
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
@@ -2070,12 +2028,13 @@ err_noinitval:
 
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
@@ -2084,8 +2043,8 @@ static void bcm43xx_upload_microcode(str
 	}
 
 	/* Upload PCM data. */
-	data = (u32 *)(bcm->pcm->data);
-	len = bcm->pcm->size / sizeof(u32);
+	data = (u32 *)(phy->pcm->data);
+	len = phy->pcm->size / sizeof(u32);
 	bcm43xx_shm_control_word(bcm, BCM43xx_SHM_PCM, 0x01ea);
 	bcm43xx_write32(bcm, BCM43xx_MMIO_SHM_DATA, 0x00004000);
 	bcm43xx_shm_control_word(bcm, BCM43xx_SHM_PCM, 0x01eb);
@@ -2131,15 +2090,16 @@ err_format:
 
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
@@ -2156,9 +2116,7 @@ #endif
 
 static int bcm43xx_initialize_irq(struct bcm43xx_private *bcm)
 {
-	int res;
-	unsigned int i;
-	u32 data;
+	int err;
 
 	bcm->irq = bcm->pci_dev->irq;
 #ifdef CONFIG_BCM947XX
@@ -2175,32 +2133,12 @@ #ifdef CONFIG_BCM947XX
 		}
 	}
 #endif
-	res = request_irq(bcm->irq, bcm43xx_interrupt_handler,
+	err = request_irq(bcm->irq, bcm43xx_interrupt_handler,
 			  IRQF_SHARED, KBUILD_MODNAME, bcm);
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
@@ -2298,13 +2236,17 @@ static int bcm43xx_gpio_cleanup(struct b
 /* http://bcm-specs.sipsolutions.net/EnableMac */
 void bcm43xx_mac_enable(struct bcm43xx_private *bcm)
 {
-	bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS_BITFIELD,
-	                bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD)
-			| BCM43xx_SBF_MAC_ENABLED);
-	bcm43xx_write32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON, BCM43xx_IRQ_READY);
-	bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD); /* dummy read */
-	bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON); /* dummy read */
-	bcm43xx_power_saving_ctl_bits(bcm, -1, -1);
+	bcm->mac_suspended--;
+	assert(bcm->mac_suspended >= 0);
+	if (bcm->mac_suspended == 0) {
+		bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS_BITFIELD,
+		                bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD)
+				| BCM43xx_SBF_MAC_ENABLED);
+		bcm43xx_write32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON, BCM43xx_IRQ_READY);
+		bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD); /* dummy read */
+		bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON); /* dummy read */
+		bcm43xx_power_saving_ctl_bits(bcm, -1, -1);
+	}
 }
 
 /* http://bcm-specs.sipsolutions.net/SuspendMAC */
@@ -2313,18 +2255,23 @@ void bcm43xx_mac_suspend(struct bcm43xx_
 	int i;
 	u32 tmp;
 
-	bcm43xx_power_saving_ctl_bits(bcm, -1, 1);
-	bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS_BITFIELD,
-	                bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD)
-			& ~BCM43xx_SBF_MAC_ENABLED);
-	bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON); /* dummy read */
-	for (i = 100000; i; i--) {
-		tmp = bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON);
-		if (tmp & BCM43xx_IRQ_READY)
-			return;
-		udelay(10);
+	assert(bcm->mac_suspended >= 0);
+	if (bcm->mac_suspended == 0) {
+		bcm43xx_power_saving_ctl_bits(bcm, -1, 1);
+		bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS_BITFIELD,
+		                bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD)
+				& ~BCM43xx_SBF_MAC_ENABLED);
+		bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON); /* dummy read */
+		for (i = 100000; i; i--) {
+			tmp = bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON);
+			if (tmp & BCM43xx_IRQ_READY)
+				goto out;
+			udelay(1);
+		}
+		printkl(KERN_ERR PFX "MAC suspend failed\n");
 	}
-	printkl(KERN_ERR PFX "MAC suspend failed\n");
+out:
+	bcm->mac_suspended++;
 }
 
 void bcm43xx_set_iwmode(struct bcm43xx_private *bcm,
@@ -2394,7 +2341,6 @@ static void bcm43xx_chip_cleanup(struct 
 	if (!modparam_noleds)
 		bcm43xx_leds_exit(bcm);
 	bcm43xx_gpio_cleanup(bcm);
-	free_irq(bcm->irq, bcm);
 	bcm43xx_release_firmware(bcm, 0);
 }
 
@@ -2406,7 +2352,7 @@ static int bcm43xx_chip_init(struct bcm4
 	struct bcm43xx_radioinfo *radio = bcm43xx_current_radio(bcm);
 	struct bcm43xx_phyinfo *phy = bcm43xx_current_phy(bcm);
 	int err;
-	int tmp;
+	int i, tmp;
 	u32 value32;
 	u16 value16;
 
@@ -2419,13 +2365,26 @@ static int bcm43xx_chip_init(struct bcm4
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
@@ -2509,8 +2468,6 @@ err_radio_off:
 	bcm43xx_radio_turn_off(bcm);
 err_gpio_cleanup:
 	bcm43xx_gpio_cleanup(bcm);
-err_free_irq:
-	free_irq(bcm->irq, bcm);
 err_release_fw:
 	bcm43xx_release_firmware(bcm, 1);
 	goto out;
@@ -2550,11 +2507,9 @@ static void bcm43xx_init_struct_phyinfo(
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
 
@@ -2562,14 +2517,11 @@ static void bcm43xx_init_struct_radioinf
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
@@ -2587,7 +2539,6 @@ static int bcm43xx_probe_cores(struct bc
 				    * BCM43xx_MAX_80211_CORES);
 	memset(&bcm->core_80211_ext, 0, sizeof(struct bcm43xx_coreinfo_80211)
 					* BCM43xx_MAX_80211_CORES);
-	bcm->current_80211_core_idx = -1;
 	bcm->nr_80211_available = 0;
 	bcm->current_core = NULL;
 	bcm->active_80211_core = NULL;
@@ -2757,6 +2708,7 @@ #endif
 				goto out;
 			}
 			bcm->nr_80211_available++;
+			core->priv = ext_80211;
 			bcm43xx_init_struct_phyinfo(&ext_80211->phy);
 			bcm43xx_init_struct_radioinfo(&ext_80211->radio);
 			break;
@@ -2857,7 +2809,8 @@ static void bcm43xx_wireless_core_cleanu
 }
 
 /* http://bcm-specs.sipsolutions.net/80211Init */
-static int bcm43xx_wireless_core_init(struct bcm43xx_private *bcm)
+static int bcm43xx_wireless_core_init(struct bcm43xx_private *bcm,
+				      int active_wlcore)
 {
 	struct bcm43xx_phyinfo *phy = bcm43xx_current_phy(bcm);
 	struct bcm43xx_radioinfo *radio = bcm43xx_current_radio(bcm);
@@ -2939,19 +2892,26 @@ static int bcm43xx_wireless_core_init(st
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
@@ -3066,11 +3026,6 @@ out:
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
@@ -3183,7 +3138,9 @@ static void bcm43xx_periodic_work_handle
 		 * be preemtible.
 		 */
 		netif_stop_queue(bcm->net_dev);
+		synchronize_net();
 		spin_lock_irqsave(&bcm->irq_lock, flags);
+		bcm43xx_mac_suspend(bcm);
 		if (bcm43xx_using_pio(bcm))
 			bcm43xx_pio_freeze_txqueues(bcm);
 		savedirqs = bcm43xx_interrupt_disable(bcm, BCM43xx_IRQ_ALL);
@@ -3207,6 +3164,7 @@ static void bcm43xx_periodic_work_handle
 			bcm43xx_interrupt_enable(bcm, savedirqs);
 			if (bcm43xx_using_pio(bcm))
 				bcm43xx_pio_thaw_txqueues(bcm);
+			bcm43xx_mac_enable(bcm);
 		}
 		netif_wake_queue(bcm->net_dev);
 	}
@@ -3241,9 +3199,9 @@ static int bcm43xx_rng_read(struct hwrng
 	struct bcm43xx_private *bcm = (struct bcm43xx_private *)rng->priv;
 	unsigned long flags;
 
-	bcm43xx_lock_irqonly(bcm, flags);
+	spin_lock_irqsave(&(bcm)->irq_lock, flags);
 	*data = bcm43xx_read16(bcm, BCM43xx_MMIO_RNG);
-	bcm43xx_unlock_irqonly(bcm, flags);
+	spin_unlock_irqrestore(&(bcm)->irq_lock, flags);
 
 	return (sizeof(u16));
 }
@@ -3269,139 +3227,322 @@ static int bcm43xx_rng_init(struct bcm43
 	return err;
 }
 
-/* This is the opposite of bcm43xx_init_board() */
-static void bcm43xx_free_board(struct bcm43xx_private *bcm)
+static int bcm43xx_shutdown_all_wireless_cores(struct bcm43xx_private *bcm)
 {
+	int ret = 0;
 	int i, err;
+	struct bcm43xx_coreinfo *core;
 
-	mutex_lock(&bcm->mutex);
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
 	bcm43xx_sysfs_unregister(bcm);
 	bcm43xx_periodic_tasks_delete(bcm);
 
-	bcm43xx_set_status(bcm, BCM43xx_STAT_SHUTTINGDOWN);
+	mutex_lock(&(bcm)->mutex);
+	bcm43xx_shutdown_all_wireless_cores(bcm);
+	bcm43xx_pctl_set_crystal(bcm, 0);
+	mutex_unlock(&(bcm)->mutex);
+}
+
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
 
-	bcm43xx_rng_exit(bcm);
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
+	/* IRQ related flags */
+	bcm->irq_reason = 0;
+	memset(bcm->dma_reason, 0, sizeof(bcm->dma_reason));
+	bcm->irq_savedstate = BCM43xx_IRQ_INITIAL;
 
-	bcm43xx_set_status(bcm, BCM43xx_STAT_UNINIT);
-	mutex_unlock(&bcm->mutex);
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
+		ieee80211softmac_stop(bcm->net_dev);
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
-	err = bcm43xx_rng_init(bcm);
+	err = bcm43xx_pctl_set_clock(bcm, BCM43xx_PCTL_CLK_DYNAMIC);
 	if (err)
-		goto err_80211_unwind;
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
+	mutex_lock(&(bcm)->mutex);
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
-	mutex_unlock(&bcm->mutex);
+	mutex_unlock(&(bcm)->mutex);
 
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
 
@@ -3783,7 +3924,8 @@ static void bcm43xx_net_poll_controller(
 	unsigned long flags;
 
 	local_irq_save(flags);
-	bcm43xx_interrupt_handler(bcm->irq, bcm, NULL);
+	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED)
+		bcm43xx_interrupt_handler(bcm->irq, bcm, NULL);
 	local_irq_restore(flags);
 }
 #endif /* CONFIG_NET_POLL_CONTROLLER */
@@ -3801,7 +3943,7 @@ static int bcm43xx_net_stop(struct net_d
 	int err;
 
 	ieee80211softmac_stop(net_dev);
-	err = bcm43xx_disable_interrupts_sync(bcm, NULL);
+	err = bcm43xx_disable_interrupts_sync(bcm);
 	assert(!err);
 	bcm43xx_free_board(bcm);
 
@@ -3943,7 +4085,6 @@ static void __devexit bcm43xx_remove_one
 	bcm43xx_debugfs_remove_device(bcm);
 	unregister_netdev(net_dev);
 	bcm43xx_detach_board(bcm);
-	assert(bcm->ucode == NULL);
 	free_ieee80211softmac(net_dev);
 }
 
@@ -3953,47 +4094,25 @@ static void __devexit bcm43xx_remove_one
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
+	mutex_lock(&(bcm)->mutex);
+	phy = bcm43xx_current_phy(bcm);
+	err = bcm43xx_select_wireless_core(bcm, phy->type);
+	mutex_unlock(&(bcm)->mutex);
 
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
-
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
@@ -4005,18 +4124,16 @@ static int bcm43xx_suspend(struct pci_de
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
 	netif_device_detach(net_dev);
-	if (try_to_shutdown) {
+	bcm->was_initialized = 0;
+	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED) {
+		bcm->was_initialized = 1;
 		ieee80211softmac_stop(net_dev);
-		err = bcm43xx_disable_interrupts_sync(bcm, &bcm->irq_savedstate);
+		err = bcm43xx_disable_interrupts_sync(bcm);
 		if (unlikely(err)) {
 			dprintk(KERN_ERR PFX "Suspend failed.\n");
 			return -EAGAIN;
@@ -4049,17 +4166,14 @@ static int bcm43xx_resume(struct pci_dev
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
 	netif_device_attach(net_dev);
-	
+
 	dprintk(KERN_INFO PFX "Device resumed.\n");
 
 	return 0;
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_main.h b/drivers/net/wireless/bcm43xx/bcm43xx_main.h
index 1164936..505c86e 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_main.h
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.h
@@ -133,6 +133,9 @@ void bcm43xx_dummy_transmission(struct b
 
 int bcm43xx_switch_core(struct bcm43xx_private *bcm, struct bcm43xx_coreinfo *new_core);
 
+int bcm43xx_select_wireless_core(struct bcm43xx_private *bcm,
+				 int phytype);
+
 void bcm43xx_wireless_core_reset(struct bcm43xx_private *bcm, int connect_phy);
 
 void bcm43xx_mac_suspend(struct bcm43xx_private *bcm);
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c b/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c
index cc1ff3c..ece3351 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c
@@ -309,6 +309,70 @@ static DEVICE_ATTR(shortpreamble, 0644,
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
+	mutex_lock(&(bcm)->mutex);
+	err = bcm43xx_select_wireless_core(bcm, phytype);
+	mutex_unlock(&(bcm)->mutex);
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
+	mutex_lock(&(bcm)->mutex);
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
+	mutex_unlock(&(bcm)->mutex);
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
@@ -325,9 +389,14 @@ int bcm43xx_sysfs_register(struct bcm43x
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
@@ -339,6 +408,7 @@ void bcm43xx_sysfs_unregister(struct bcm
 {
 	struct device *dev = &bcm->pci_dev->dev;
 
+	device_remove_file(dev, &dev_attr_phymode);
 	device_remove_file(dev, &dev_attr_shortpreamble);
 	device_remove_file(dev, &dev_attr_interference);
 	device_remove_file(dev, &dev_attr_sprom);
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_wx.c b/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
index 8ffd760..1d3a3aa 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
@@ -47,9 +47,8 @@ #include "bcm43xx_phy.h"
 #define BCM43xx_WX_VERSION	18
 
 #define MAX_WX_STRING		80
-/* FIXME: the next line is a guess as to what the maximum value of RX power
-          (in dBm) might be */
-#define RX_POWER_MAX		-10
+/* FIXME: the next line is a guess as to what the maximum RSSI value might be */
+#define RX_RSSI_MAX		60
 
 
 static int bcm43xx_wx_get_name(struct net_device *net_dev,
@@ -230,9 +229,8 @@ static int bcm43xx_wx_get_rangeparams(st
 	range->throughput = 27 * 1000 * 1000;
 
 	range->max_qual.qual = 100;
-	/* TODO: Real max RSSI */
-	range->max_qual.level = 0;
-	range->max_qual.noise = 0;
+	range->max_qual.level = 152; /* set floor at -104 dBm (152 - 256) */
+	range->max_qual.noise = 152;
 	range->max_qual.updated = IW_QUAL_ALL_UPDATED;
 
 	range->avg_qual.qual = 50;
@@ -845,6 +843,7 @@ static struct iw_statistics *bcm43xx_get
 	struct iw_statistics *wstats;
 	struct ieee80211_network *network = NULL;
 	static int tmp_level = 0;
+	static int tmp_qual = 0;
 	unsigned long flags;
 
 	wstats = &bcm->stats.wstats;
@@ -863,25 +862,28 @@ static struct iw_statistics *bcm43xx_get
 		wstats->qual.level = 0;
 		wstats->qual.noise = 0;
 		wstats->qual.updated = 7;
-		wstats->qual.updated |= IW_QUAL_ALL_UPDATED;
+		wstats->qual.updated |= IW_QUAL_ALL_UPDATED | IW_QUAL_DBM;
 		return wstats;
 	}
 	/* fill in the real statistics when iface associated */
 	spin_lock_irqsave(&mac->ieee->lock, flags);
 	list_for_each_entry(network, &mac->ieee->network_list, list) {
 		if (!memcmp(mac->associnfo.bssid, network->bssid, ETH_ALEN)) {
-			if (!tmp_level)		/* get initial value */
-				tmp_level = network->stats.rssi;
-			else			/* smooth results */
-				tmp_level = (7 * tmp_level + network->stats.rssi)/8;
+			if (!tmp_level)	{	/* get initial values */
+				tmp_level = network->stats.signal;
+				tmp_qual = network->stats.rssi;
+			} else {		/* smooth results */
+				tmp_level = (15 * tmp_level + network->stats.signal)/16;
+				tmp_qual = (15 * tmp_qual + network->stats.rssi)/16;
+			}
 			break;
 		}
 	}
 	spin_unlock_irqrestore(&mac->ieee->lock, flags);
 	wstats->qual.level = tmp_level;
-	wstats->qual.qual = 100 + tmp_level - RX_POWER_MAX; // TODO: get the real signal quality
+	wstats->qual.qual = 100 * tmp_qual / RX_RSSI_MAX;
 	wstats->qual.noise = bcm->stats.noise;
-	wstats->qual.updated = IW_QUAL_ALL_UPDATED;
+	wstats->qual.updated = IW_QUAL_ALL_UPDATED | IW_QUAL_DBM;
 	wstats->discard.code = bcm->ieee->ieee_stats.rx_discards_undecryptable;
 	wstats->discard.retries = bcm->ieee->ieee_stats.tx_retry_limit_exceeded;
 	wstats->discard.nwid = bcm->ieee->ieee_stats.tx_discards_wrong_sa;
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c b/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
index 6dbd855..c0efbfe 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
@@ -492,16 +492,15 @@ int bcm43xx_rx(struct bcm43xx_private *b
 
 	memset(&stats, 0, sizeof(stats));
 	stats.mac_time = le16_to_cpu(rxhdr->mactime);
-	stats.rssi = bcm43xx_rssi_postprocess(bcm, rxhdr->rssi, is_ofdm,
+	stats.rssi = rxhdr->rssi;
+	stats.signal = bcm43xx_rssi_postprocess(bcm, rxhdr->rssi, is_ofdm,
 					      !!(rxflags1 & BCM43xx_RXHDR_FLAGS1_2053RSSIADJ),
 					      !!(rxflags3 & BCM43xx_RXHDR_FLAGS3_2050RSSIADJ));
-	stats.signal = rxhdr->signal_quality;	//FIXME
 //TODO	stats.noise = 
 	if (is_ofdm)
 		stats.rate = bcm43xx_plcp_get_bitrate_ofdm(plcp);
 	else
 		stats.rate = bcm43xx_plcp_get_bitrate_cck(plcp);
-//printk("RX ofdm %d, rate == %u\n", is_ofdm, stats.rate);
 	stats.received_channel = radio->channel;
 //TODO	stats.control = 
 	stats.mask = IEEE80211_STATMASK_SIGNAL |
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
