From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Please pull 'fixes-jgarzik' branch of wireless-2.6 (this time for
	real!)
Date: Wed, 7 Nov 2007 20:34:29 -0500
Message-ID: <20071108013429.GA11957@tuxdriver.com>
References: <20071106200700.GF4440@tuxdriver.com> <20071107191329.GC30169@tuxdriver.com> <20071107192419.GA15784@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20071107192419.GA15784-oTNwCEtKUwI/11+TDStg7g@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 07, 2007 at 02:24:19PM -0500, Jeff Garzik wrote:
> On Wed, Nov 07, 2007 at 02:13:29PM -0500, John W. Linville wrote:
> > Jeff,
> > 
> > If you haven't already pulled this then please hold-off.  I'll post
> > a new request soon.
> 
> Haven't pulled yet...

Jeff,

These fixes are additive on top of the previous request in this thread.
That request is archived here:

	http://marc.info/?l=linux-wireless&m=119438263704232&w=2

Also, note that the first three from Michael Buesch in the list below
were already sent to you directed for 2.6.25, but I think they belong in
2.6.24 instead.  I cherry-picked them, so I'm fairly certain git will be
smart enough to drop them from your 2.6.25 branch when you rebase.

Let me know if there are any problems!

Thanks,

John

---

The entire series (i.e. both from yesterday and today) is available
here:

	http://www.kernel.org/pub//linux/kernel/people/linville/wireless-2.6/fixes-jgarzik/

---

The following changes since commit 33a463d0c82cad08a64526c217f6d835a51dfc1c:
  Michael Buesch (1):
        b43: pcmcia-host initialization bugfixes

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git fixes-jgarzik

Michael Buesch (6):
      b43: Fix rfkill callback deadlock
      b43: debugfs SHM read buffer overrun fix
      b43: Rewrite and fix rfkill init
      b43: properly request pcmcia IRQ
      b43legacy: Fix sparse warning
      b43: Fix kconfig dependencies for rfkill and leds

Stefano Brivio (4):
      b43legacy: fix possible buffer overrun in debugfs
      b43legacy: add me as maintainer and fix URLs
      b43: fix shared IRQ race condition
      b43legacy: fix shared IRQ race condition

 MAINTAINERS                              |   10 ++-
 drivers/net/wireless/b43/Kconfig         |   10 ++-
 drivers/net/wireless/b43/debugfs.c       |    2 +-
 drivers/net/wireless/b43/main.c          |   19 +++---
 drivers/net/wireless/b43/pcmcia.c        |    8 ++
 drivers/net/wireless/b43/rfkill.c        |  115 +++++++++++++----------------
 drivers/net/wireless/b43/rfkill.h        |   14 +---
 drivers/net/wireless/b43legacy/debugfs.c |    2 +-
 drivers/net/wireless/b43legacy/main.c    |   21 +++---
 9 files changed, 100 insertions(+), 101 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 1c7c229..6a97027 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -787,23 +787,25 @@ B43 WIRELESS DRIVER
 P:	Michael Buesch
 M:	mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org
 P:	Stefano Brivio
-M:	st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org
+M:	stefano.brivio-hl5o88x/ua9eoWH0uzbU5w@public.gmane.org
 L:	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
-W:	http://bcm43xx.berlios.de/
+W:	http://linuxwireless.org/en/users/Drivers/b43
 S:	Maintained
 
 B43LEGACY WIRELESS DRIVER
 P:	Larry Finger
 M:	Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org
+P:	Stefano Brivio
+M:	stefano.brivio-hl5o88x/ua9eoWH0uzbU5w@public.gmane.org
 L:	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
-W:	http://bcm43xx.berlios.de/
+W:	http://linuxwireless.org/en/users/Drivers/b43
 S:	Maintained
 
 BCM43XX WIRELESS DRIVER (SOFTMAC BASED VERSION)
 P:	Larry Finger
 M:	Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org
 P:	Stefano Brivio
-M:	st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org
+M:	stefano.brivio-hl5o88x/ua9eoWH0uzbU5w@public.gmane.org
 L:	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
 W:	http://bcm43xx.berlios.de/
 S:	Maintained
diff --git a/drivers/net/wireless/b43/Kconfig b/drivers/net/wireless/b43/Kconfig
index e3c573e..fdbc351 100644
--- a/drivers/net/wireless/b43/Kconfig
+++ b/drivers/net/wireless/b43/Kconfig
@@ -61,16 +61,18 @@ config B43_PCMCIA
 
 	  If unsure, say N.
 
-# LED support
+# This config option automatically enables b43 LEDS support,
+# if it's possible.
 config B43_LEDS
 	bool
-	depends on B43 && MAC80211_LEDS
+	depends on B43 && MAC80211_LEDS && (LEDS_CLASS = y || LEDS_CLASS = B43)
 	default y
 
-# RFKILL support
+# This config option automatically enables b43 RFKILL support,
+# if it's possible.
 config B43_RFKILL
 	bool
-	depends on B43 && RFKILL && RFKILL_INPUT && INPUT_POLLDEV
+	depends on B43 && (RFKILL = y || RFKILL = B43) && RFKILL_INPUT && (INPUT_POLLDEV = y || INPUT_POLLDEV = B43)
 	default y
 
 config B43_DEBUG
diff --git a/drivers/net/wireless/b43/debugfs.c b/drivers/net/wireless/b43/debugfs.c
index 734e70e..ef0075d 100644
--- a/drivers/net/wireless/b43/debugfs.c
+++ b/drivers/net/wireless/b43/debugfs.c
@@ -128,7 +128,7 @@ static ssize_t shm_read_file(struct b43_wldev *dev,
 	__le16 *le16buf = (__le16 *)buf;
 
 	for (i = 0; i < 0x1000; i++) {
-		if (bufsize <= 0)
+		if (bufsize < sizeof(tmp))
 			break;
 		tmp = b43_shm_read16(dev, B43_SHM_SHARED, 2 * i);
 		le16buf[i] = cpu_to_le16(tmp);
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index 5058e60..2b17c1d 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -2985,6 +2985,16 @@ static void b43_wireless_core_stop(struct b43_wldev *dev)
 
 	if (b43_status(dev) < B43_STAT_STARTED)
 		return;
+
+	/* Disable and sync interrupts. We must do this before than
+	 * setting the status to INITIALIZED, as the interrupt handler
+	 * won't care about IRQs then. */
+	spin_lock_irqsave(&wl->irq_lock, flags);
+	dev->irq_savedstate = b43_interrupt_disable(dev, B43_IRQ_ALL);
+	b43_read32(dev, B43_MMIO_GEN_IRQ_MASK);	/* flush */
+	spin_unlock_irqrestore(&wl->irq_lock, flags);
+	b43_synchronize_irq(dev);
+
 	b43_set_status(dev, B43_STAT_INITIALIZED);
 
 	mutex_unlock(&wl->mutex);
@@ -2995,13 +3005,6 @@ static void b43_wireless_core_stop(struct b43_wldev *dev)
 
 	ieee80211_stop_queues(wl->hw);	//FIXME this could cause a deadlock, as mac80211 seems buggy.
 
-	/* Disable and sync interrupts. */
-	spin_lock_irqsave(&wl->irq_lock, flags);
-	dev->irq_savedstate = b43_interrupt_disable(dev, B43_IRQ_ALL);
-	b43_read32(dev, B43_MMIO_GEN_IRQ_MASK);	/* flush */
-	spin_unlock_irqrestore(&wl->irq_lock, flags);
-	b43_synchronize_irq(dev);
-
 	b43_mac_suspend(dev);
 	free_irq(dev->dev->irq, dev);
 	b43dbg(wl, "Wireless interface stopped\n");
@@ -3661,7 +3664,6 @@ static int b43_setup_modes(struct b43_wldev *dev,
 
 static void b43_wireless_core_detach(struct b43_wldev *dev)
 {
-	b43_rfkill_free(dev);
 	/* We release firmware that late to not be required to re-request
 	 * is all the time when we reinit the core. */
 	b43_release_firmware(dev);
@@ -3747,7 +3749,6 @@ static int b43_wireless_core_attach(struct b43_wldev *dev)
 	if (!wl->current_dev)
 		wl->current_dev = dev;
 	INIT_WORK(&dev->restart_work, b43_chip_reset);
-	b43_rfkill_alloc(dev);
 
 	b43_radio_turn_off(dev, 1);
 	b43_switch_analog(dev, 0);
diff --git a/drivers/net/wireless/b43/pcmcia.c b/drivers/net/wireless/b43/pcmcia.c
index 4b6648f..b79a6bd 100644
--- a/drivers/net/wireless/b43/pcmcia.c
+++ b/drivers/net/wireless/b43/pcmcia.c
@@ -112,6 +112,14 @@ static int __devinit b43_pcmcia_probe(struct pcmcia_device *dev)
 	if (res != CS_SUCCESS)
 		goto err_disable;
 
+	dev->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING | IRQ_FIRST_SHARED;
+	dev->irq.IRQInfo1 = IRQ_LEVEL_ID | IRQ_SHARE_ID;
+	dev->irq.Handler = NULL; /* The handler is registered later. */
+	dev->irq.Instance = NULL;
+	res = pcmcia_request_irq(dev, &dev->irq);
+	if (res != CS_SUCCESS)
+		goto err_disable;
+
 	res = pcmcia_request_configuration(dev, &dev->conf);
 	if (res != CS_SUCCESS)
 		goto err_disable;
diff --git a/drivers/net/wireless/b43/rfkill.c b/drivers/net/wireless/b43/rfkill.c
index 800e0a6..9b1f905 100644
--- a/drivers/net/wireless/b43/rfkill.c
+++ b/drivers/net/wireless/b43/rfkill.c
@@ -47,32 +47,35 @@ static void b43_rfkill_poll(struct input_polled_dev *poll_dev)
 	struct b43_wldev *dev = poll_dev->private;
 	struct b43_wl *wl = dev->wl;
 	bool enabled;
+	bool report_change = 0;
 
 	mutex_lock(&wl->mutex);
 	B43_WARN_ON(b43_status(dev) < B43_STAT_INITIALIZED);
 	enabled = b43_is_hw_radio_enabled(dev);
 	if (unlikely(enabled != dev->radio_hw_enable)) {
 		dev->radio_hw_enable = enabled;
+		report_change = 1;
 		b43info(wl, "Radio hardware status changed to %s\n",
 			enabled ? "ENABLED" : "DISABLED");
-		mutex_unlock(&wl->mutex);
+	}
+	mutex_unlock(&wl->mutex);
+
+	if (unlikely(report_change))
 		input_report_key(poll_dev->input, KEY_WLAN, enabled);
-	} else
-		mutex_unlock(&wl->mutex);
 }
 
-/* Called when the RFKILL toggled in software.
- * This is called without locking. */
+/* Called when the RFKILL toggled in software. */
 static int b43_rfkill_soft_toggle(void *data, enum rfkill_state state)
 {
 	struct b43_wldev *dev = data;
 	struct b43_wl *wl = dev->wl;
 	int err = 0;
 
-	mutex_lock(&wl->mutex);
-	if (b43_status(dev) < B43_STAT_INITIALIZED)
-		goto out_unlock;
+	if (!wl->rfkill.registered)
+		return 0;
 
+	mutex_lock(&wl->mutex);
+	B43_WARN_ON(b43_status(dev) < B43_STAT_INITIALIZED);
 	switch (state) {
 	case RFKILL_STATE_ON:
 		if (!dev->radio_hw_enable) {
@@ -89,7 +92,6 @@ static int b43_rfkill_soft_toggle(void *data, enum rfkill_state state)
 			b43_radio_turn_off(dev, 0);
 		break;
 	}
-
 out_unlock:
 	mutex_unlock(&wl->mutex);
 
@@ -98,11 +100,11 @@ out_unlock:
 
 char * b43_rfkill_led_name(struct b43_wldev *dev)
 {
-	struct b43_wl *wl = dev->wl;
+	struct b43_rfkill *rfk = &(dev->wl->rfkill);
 
-	if (!wl->rfkill.rfkill)
+	if (!rfk->registered)
 		return NULL;
-	return rfkill_get_led_name(wl->rfkill.rfkill);
+	return rfkill_get_led_name(rfk->rfkill);
 }
 
 void b43_rfkill_init(struct b43_wldev *dev)
@@ -111,53 +113,13 @@ void b43_rfkill_init(struct b43_wldev *dev)
 	struct b43_rfkill *rfk = &(wl->rfkill);
 	int err;
 
-	if (rfk->rfkill) {
-		err = rfkill_register(rfk->rfkill);
-		if (err) {
-			b43warn(wl, "Failed to register RF-kill button\n");
-			goto err_free_rfk;
-		}
-	}
-	if (rfk->poll_dev) {
-		err = input_register_polled_device(rfk->poll_dev);
-		if (err) {
-			b43warn(wl, "Failed to register RF-kill polldev\n");
-			goto err_free_polldev;
-		}
-	}
-
-	return;
-err_free_rfk:
-	rfkill_free(rfk->rfkill);
-	rfk->rfkill = NULL;
-err_free_polldev:
-	input_free_polled_device(rfk->poll_dev);
-	rfk->poll_dev = NULL;
-}
-
-void b43_rfkill_exit(struct b43_wldev *dev)
-{
-	struct b43_rfkill *rfk = &(dev->wl->rfkill);
-
-	if (rfk->poll_dev)
-		input_unregister_polled_device(rfk->poll_dev);
-	if (rfk->rfkill)
-		rfkill_unregister(rfk->rfkill);
-}
-
-void b43_rfkill_alloc(struct b43_wldev *dev)
-{
-	struct b43_wl *wl = dev->wl;
-	struct b43_rfkill *rfk = &(wl->rfkill);
+	rfk->registered = 0;
 
+	rfk->rfkill = rfkill_allocate(dev->dev->dev, RFKILL_TYPE_WLAN);
+	if (!rfk->rfkill)
+		goto out_error;
 	snprintf(rfk->name, sizeof(rfk->name),
 		 "b43-%s", wiphy_name(wl->hw->wiphy));
-
-	rfk->rfkill = rfkill_allocate(dev->dev->dev, RFKILL_TYPE_WLAN);
-	if (!rfk->rfkill) {
-		b43warn(wl, "Failed to allocate RF-kill button\n");
-		return;
-	}
 	rfk->rfkill->name = rfk->name;
 	rfk->rfkill->state = RFKILL_STATE_ON;
 	rfk->rfkill->data = dev;
@@ -165,18 +127,45 @@ void b43_rfkill_alloc(struct b43_wldev *dev)
 	rfk->rfkill->user_claim_unsupported = 1;
 
 	rfk->poll_dev = input_allocate_polled_device();
-	if (rfk->poll_dev) {
-		rfk->poll_dev->private = dev;
-		rfk->poll_dev->poll = b43_rfkill_poll;
-		rfk->poll_dev->poll_interval = 1000; /* msecs */
-	} else
-		b43warn(wl, "Failed to allocate RF-kill polldev\n");
+	if (!rfk->poll_dev)
+		goto err_free_rfk;
+	rfk->poll_dev->private = dev;
+	rfk->poll_dev->poll = b43_rfkill_poll;
+	rfk->poll_dev->poll_interval = 1000; /* msecs */
+
+	err = rfkill_register(rfk->rfkill);
+	if (err)
+		goto err_free_polldev;
+	err = input_register_polled_device(rfk->poll_dev);
+	if (err)
+		goto err_unreg_rfk;
+
+	rfk->registered = 1;
+
+	return;
+err_unreg_rfk:
+	rfkill_unregister(rfk->rfkill);
+err_free_polldev:
+	input_free_polled_device(rfk->poll_dev);
+	rfk->poll_dev = NULL;
+err_free_rfk:
+	rfkill_free(rfk->rfkill);
+	rfk->rfkill = NULL;
+out_error:
+	rfk->registered = 0;
+	b43warn(wl, "RF-kill button init failed\n");
 }
 
-void b43_rfkill_free(struct b43_wldev *dev)
+void b43_rfkill_exit(struct b43_wldev *dev)
 {
 	struct b43_rfkill *rfk = &(dev->wl->rfkill);
 
+	if (!rfk->registered)
+		return;
+	rfk->registered = 0;
+
+	input_unregister_polled_device(rfk->poll_dev);
+	rfkill_unregister(rfk->rfkill);
 	input_free_polled_device(rfk->poll_dev);
 	rfk->poll_dev = NULL;
 	rfkill_free(rfk->rfkill);
diff --git a/drivers/net/wireless/b43/rfkill.h b/drivers/net/wireless/b43/rfkill.h
index 29544e8..adacf93 100644
--- a/drivers/net/wireless/b43/rfkill.h
+++ b/drivers/net/wireless/b43/rfkill.h
@@ -15,14 +15,14 @@ struct b43_rfkill {
 	struct rfkill *rfkill;
 	/* The poll device for the RFKILL input button */
 	struct input_polled_dev *poll_dev;
+	/* Did initialization succeed? Used for freeing. */
+	bool registered;
 	/* The unique name of this rfkill switch */
-	char name[32];
+	char name[sizeof("b43-phy4294967295")];
 };
 
-/* All the init functions return void, because we are not interested
+/* The init function returns void, because we are not interested
  * in failing the b43 init process when rfkill init failed. */
-void b43_rfkill_alloc(struct b43_wldev *dev);
-void b43_rfkill_free(struct b43_wldev *dev);
 void b43_rfkill_init(struct b43_wldev *dev);
 void b43_rfkill_exit(struct b43_wldev *dev);
 
@@ -36,12 +36,6 @@ struct b43_rfkill {
 	/* empty */
 };
 
-static inline void b43_rfkill_alloc(struct b43_wldev *dev)
-{
-}
-static inline void b43_rfkill_free(struct b43_wldev *dev)
-{
-}
 static inline void b43_rfkill_init(struct b43_wldev *dev)
 {
 }
diff --git a/drivers/net/wireless/b43legacy/debugfs.c b/drivers/net/wireless/b43legacy/debugfs.c
index eefa6fb..619b453 100644
--- a/drivers/net/wireless/b43legacy/debugfs.c
+++ b/drivers/net/wireless/b43legacy/debugfs.c
@@ -124,7 +124,7 @@ static ssize_t shm_read_file(struct b43legacy_wldev *dev, char *buf, size_t bufs
 	__le16 *le16buf = (__le16 *)buf;
 
 	for (i = 0; i < 0x1000; i++) {
-		if (bufsize <= 0)
+		if (bufsize < sizeof(tmp))
 			break;
 		tmp = b43legacy_shm_read16(dev, B43legacy_SHM_SHARED, 2 * i);
 		le16buf[i] = cpu_to_le16(tmp);
diff --git a/drivers/net/wireless/b43legacy/main.c b/drivers/net/wireless/b43legacy/main.c
index f0e56df..3bde1e9 100644
--- a/drivers/net/wireless/b43legacy/main.c
+++ b/drivers/net/wireless/b43legacy/main.c
@@ -2781,6 +2781,17 @@ static void b43legacy_wireless_core_stop(struct b43legacy_wldev *dev)
 
 	if (b43legacy_status(dev) < B43legacy_STAT_STARTED)
 		return;
+
+	/* Disable and sync interrupts. We must do this before than
+	 * setting the status to INITIALIZED, as the interrupt handler
+	 * won't care about IRQs then. */
+	spin_lock_irqsave(&wl->irq_lock, flags);
+	dev->irq_savedstate = b43legacy_interrupt_disable(dev,
+							  B43legacy_IRQ_ALL);
+	b43legacy_read32(dev, B43legacy_MMIO_GEN_IRQ_MASK); /* flush */
+	spin_unlock_irqrestore(&wl->irq_lock, flags);
+	b43legacy_synchronize_irq(dev);
+
 	b43legacy_set_status(dev, B43legacy_STAT_INITIALIZED);
 
 	mutex_unlock(&wl->mutex);
@@ -2791,14 +2802,6 @@ static void b43legacy_wireless_core_stop(struct b43legacy_wldev *dev)
 
 	ieee80211_stop_queues(wl->hw); /* FIXME this could cause a deadlock */
 
-	/* Disable and sync interrupts. */
-	spin_lock_irqsave(&wl->irq_lock, flags);
-	dev->irq_savedstate = b43legacy_interrupt_disable(dev,
-							  B43legacy_IRQ_ALL);
-	b43legacy_read32(dev, B43legacy_MMIO_GEN_IRQ_MASK); /* flush */
-	spin_unlock_irqrestore(&wl->irq_lock, flags);
-	b43legacy_synchronize_irq(dev);
-
 	b43legacy_mac_suspend(dev);
 	free_irq(dev->dev->irq, dev);
 	b43legacydbg(wl, "Wireless interface stopped\n");
@@ -3332,7 +3335,7 @@ out_mutex_unlock:
 	return err;
 }
 
-void b43legacy_stop(struct ieee80211_hw *hw)
+static void b43legacy_stop(struct ieee80211_hw *hw)
 {
 	struct b43legacy_wl *wl = hw_to_b43legacy_wl(hw);
 	struct b43legacy_wldev *dev = wl->current_dev;
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
