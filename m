From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'fixes-jgarzik' branch of wireless-2.6
Date: Sat, 15 Dec 2007 23:31:48 -0500
Message-ID: <20071216043148.GE3096@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4524 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756367AbXLPE6j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Dec 2007 23:58:39 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff,

A few more fixes for 2.6.24...let me know if there are any problems!

Thanks,

John

P.S.  The zd1211rw patch is already in netdev-2.6#upstream, but it
belongs in 2.6.24 as well.

---

Individual patches available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/fixes-jgarzik

---

The following changes since commit 82d29bf6dc7317aeb0a3a13c2348ca8591965875:
  Linus Torvalds (1):
        Linux 2.6.24-rc5

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git fixes-jgarzik

Adrian Bunk (1):
      wireless/ipw2200.c: add __dev{init,exit} annotations

Andrew Morton (1):
      bcm43xx_debugfs sscanf fix

Cyrill Gorcunov (2):
      ieee80211_rate: missed unlock
      iwlwifi3945/4965: fix rate control algo reference leak

Dan Williams (1):
      libertas: select WIRELESS_EXT

Larry Finger (1):
      b43: Fix rfkill radio LED

Stefano Brivio (1):
      libertas: add Dan Williams as maintainer

Ulrich Kunitz (1):
      zd1211rw: Fix alignment problems

Zhu Yi (1):
      iwlwifi: fix rf_kill state inconsistent during suspend and resume

 MAINTAINERS                                    |    6 ++++
 drivers/net/wireless/Kconfig                   |    1 +
 drivers/net/wireless/b43/leds.c                |    4 ++
 drivers/net/wireless/b43/main.c                |   22 +++++++-------
 drivers/net/wireless/b43/rfkill.c              |   37 ++++++++++++++++++++---
 drivers/net/wireless/bcm43xx/bcm43xx_debugfs.c |    2 +-
 drivers/net/wireless/ipw2200.c                 |    7 ++--
 drivers/net/wireless/iwlwifi/iwl3945-base.c    |    5 ++-
 drivers/net/wireless/iwlwifi/iwl4965-base.c    |    5 ++-
 drivers/net/wireless/zd1211rw/zd_mac.c         |   10 +++++-
 net/mac80211/ieee80211_rate.c                  |    1 +
 11 files changed, 76 insertions(+), 24 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 9507b42..c331ba3 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2489,6 +2489,12 @@ M:	mtk.manpages@gmail.com
 W:	ftp://ftp.kernel.org/pub/linux/docs/manpages
 S:	Maintained
 
+MARVELL LIBERTAS WIRELESS DRIVER
+P:	Dan Williams
+M:	dcbw@redhat.com
+L:	libertas-dev@lists.infradead.org
+S:	Maintained
+
 MARVELL MV643XX ETHERNET DRIVER
 P:	Dale Farnsworth
 M:	dale@farnsworth.org
diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index 2b733c5..5583719 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -264,6 +264,7 @@ config IPW2200_DEBUG
 config LIBERTAS
 	tristate "Marvell 8xxx Libertas WLAN driver support"
 	depends on WLAN_80211
+	select WIRELESS_EXT
 	select IEEE80211
 	select FW_LOADER
 	---help---
diff --git a/drivers/net/wireless/b43/leds.c b/drivers/net/wireless/b43/leds.c
index 19e5885..6c0e2b9 100644
--- a/drivers/net/wireless/b43/leds.c
+++ b/drivers/net/wireless/b43/leds.c
@@ -163,6 +163,9 @@ static void b43_map_led(struct b43_wldev *dev,
 		b43_register_led(dev, &dev->led_radio, name,
 				 b43_rfkill_led_name(dev),
 				 led_index, activelow);
+		/* Sync the RF-kill LED state with the switch state. */
+		if (dev->radio_hw_enable)
+			b43_led_turn_on(dev, led_index, activelow);
 		break;
 	case B43_LED_WEIRD:
 	case B43_LED_ASSOC:
@@ -232,4 +235,5 @@ void b43_leds_exit(struct b43_wldev *dev)
 	b43_unregister_led(&dev->led_tx);
 	b43_unregister_led(&dev->led_rx);
 	b43_unregister_led(&dev->led_assoc);
+	b43_unregister_led(&dev->led_radio);
 }
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index b45eecc..1c93b4f 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -2163,7 +2163,6 @@ static void b43_mgmtframe_txantenna(struct b43_wldev *dev, int antenna)
 static void b43_chip_exit(struct b43_wldev *dev)
 {
 	b43_radio_turn_off(dev, 1);
-	b43_leds_exit(dev);
 	b43_gpio_cleanup(dev);
 	/* firmware is released later */
 }
@@ -2191,11 +2190,10 @@ static int b43_chip_init(struct b43_wldev *dev)
 	err = b43_gpio_init(dev);
 	if (err)
 		goto out;	/* firmware is released later */
-	b43_leds_init(dev);
 
 	err = b43_upload_initvals(dev);
 	if (err)
-		goto err_leds_exit;
+		goto err_gpio_clean;
 	b43_radio_turn_on(dev);
 
 	b43_write16(dev, 0x03E6, 0x0000);
@@ -2271,8 +2269,7 @@ out:
 
 err_radio_off:
 	b43_radio_turn_off(dev, 1);
-err_leds_exit:
-	b43_leds_exit(dev);
+err_gpio_clean:
 	b43_gpio_cleanup(dev);
 	return err;
 }
@@ -3273,10 +3270,7 @@ static void b43_wireless_core_exit(struct b43_wldev *dev)
 		return;
 	b43_set_status(dev, B43_STAT_UNINIT);
 
-	mutex_unlock(&dev->wl->mutex);
-	b43_rfkill_exit(dev);
-	mutex_lock(&dev->wl->mutex);
-
+	b43_leds_exit(dev);
 	b43_rng_exit(dev->wl);
 	b43_pio_free(dev);
 	b43_dma_free(dev);
@@ -3405,12 +3399,12 @@ static int b43_wireless_core_init(struct b43_wldev *dev)
 	memset(wl->mac_addr, 0, ETH_ALEN);
 	b43_upload_card_macaddress(dev);
 	b43_security_init(dev);
-	b43_rfkill_init(dev);
 	b43_rng_init(wl);
 
 	b43_set_status(dev, B43_STAT_INITIALIZED);
 
-      out:
+	b43_leds_init(dev);
+out:
 	return err;
 
       err_chip_exit:
@@ -3499,6 +3493,10 @@ static int b43_start(struct ieee80211_hw *hw)
 	int did_init = 0;
 	int err = 0;
 
+	/* First register RFkill.
+	 * LEDs that are registered later depend on it. */
+	b43_rfkill_init(dev);
+
 	mutex_lock(&wl->mutex);
 
 	if (b43_status(dev) < B43_STAT_INITIALIZED) {
@@ -3528,6 +3526,8 @@ static void b43_stop(struct ieee80211_hw *hw)
 	struct b43_wl *wl = hw_to_b43_wl(hw);
 	struct b43_wldev *dev = wl->current_dev;
 
+	b43_rfkill_exit(dev);
+
 	mutex_lock(&wl->mutex);
 	if (b43_status(dev) >= B43_STAT_STARTED)
 		b43_wireless_core_stop(dev);
diff --git a/drivers/net/wireless/b43/rfkill.c b/drivers/net/wireless/b43/rfkill.c
index 9b1f905..98cf70c 100644
--- a/drivers/net/wireless/b43/rfkill.c
+++ b/drivers/net/wireless/b43/rfkill.c
@@ -25,6 +25,8 @@
 #include "rfkill.h"
 #include "b43.h"
 
+#include <linux/kmod.h>
+
 
 /* Returns TRUE, if the radio is enabled in hardware. */
 static bool b43_is_hw_radio_enabled(struct b43_wldev *dev)
@@ -50,7 +52,10 @@ static void b43_rfkill_poll(struct input_polled_dev *poll_dev)
 	bool report_change = 0;
 
 	mutex_lock(&wl->mutex);
-	B43_WARN_ON(b43_status(dev) < B43_STAT_INITIALIZED);
+	if (unlikely(b43_status(dev) < B43_STAT_INITIALIZED)) {
+		mutex_unlock(&wl->mutex);
+		return;
+	}
 	enabled = b43_is_hw_radio_enabled(dev);
 	if (unlikely(enabled != dev->radio_hw_enable)) {
 		dev->radio_hw_enable = enabled;
@@ -60,8 +65,12 @@ static void b43_rfkill_poll(struct input_polled_dev *poll_dev)
 	}
 	mutex_unlock(&wl->mutex);
 
-	if (unlikely(report_change))
-		input_report_key(poll_dev->input, KEY_WLAN, enabled);
+	/* send the radio switch event to the system - note both a key press
+	 * and a release are required */
+	if (unlikely(report_change)) {
+		input_report_key(poll_dev->input, KEY_WLAN, 1);
+		input_report_key(poll_dev->input, KEY_WLAN, 0);
+	}
 }
 
 /* Called when the RFKILL toggled in software. */
@@ -69,13 +78,15 @@ static int b43_rfkill_soft_toggle(void *data, enum rfkill_state state)
 {
 	struct b43_wldev *dev = data;
 	struct b43_wl *wl = dev->wl;
-	int err = 0;
+	int err = -EBUSY;
 
 	if (!wl->rfkill.registered)
 		return 0;
 
 	mutex_lock(&wl->mutex);
-	B43_WARN_ON(b43_status(dev) < B43_STAT_INITIALIZED);
+	if (b43_status(dev) < B43_STAT_INITIALIZED)
+		goto out_unlock;
+	err = 0;
 	switch (state) {
 	case RFKILL_STATE_ON:
 		if (!dev->radio_hw_enable) {
@@ -133,9 +144,25 @@ void b43_rfkill_init(struct b43_wldev *dev)
 	rfk->poll_dev->poll = b43_rfkill_poll;
 	rfk->poll_dev->poll_interval = 1000; /* msecs */
 
+	rfk->poll_dev->input->name = rfk->name;
+	rfk->poll_dev->input->id.bustype = BUS_HOST;
+	rfk->poll_dev->input->id.vendor = dev->dev->bus->boardinfo.vendor;
+	rfk->poll_dev->input->evbit[0] = BIT(EV_KEY);
+	set_bit(KEY_WLAN, rfk->poll_dev->input->keybit);
+
 	err = rfkill_register(rfk->rfkill);
 	if (err)
 		goto err_free_polldev;
+
+#ifdef CONFIG_RFKILL_INPUT_MODULE
+	/* B43 RF-kill isn't useful without the rfkill-input subsystem.
+	 * Try to load the module. */
+	err = request_module("rfkill-input");
+	if (err)
+		b43warn(wl, "Failed to load the rfkill-input module. "
+			"The built-in radio LED will not work.\n");
+#endif /* CONFIG_RFKILL_INPUT */
+
 	err = input_register_polled_device(rfk->poll_dev);
 	if (err)
 		goto err_unreg_rfk;
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_debugfs.c b/drivers/net/wireless/bcm43xx/bcm43xx_debugfs.c
index 35dbe45..76e9dd8 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_debugfs.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_debugfs.c
@@ -219,7 +219,7 @@ static ssize_t tsf_write_file(struct file *file, const char __user *user_buf,
 	ssize_t buf_size;
 	ssize_t res;
 	unsigned long flags;
-	u64 tsf;
+	unsigned long long tsf;
 
 	buf_size = min(count, sizeof (really_big_buffer) - 1);
 	down(&big_buffer_sem);
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index 54f44e5..da51f47 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -10751,7 +10751,7 @@ static void ipw_bg_link_down(struct work_struct *work)
 	mutex_unlock(&priv->mutex);
 }
 
-static int ipw_setup_deferred_work(struct ipw_priv *priv)
+static int __devinit ipw_setup_deferred_work(struct ipw_priv *priv)
 {
 	int ret = 0;
 
@@ -11600,7 +11600,8 @@ static void ipw_prom_free(struct ipw_priv *priv)
 #endif
 
 
-static int ipw_pci_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
+static int __devinit ipw_pci_probe(struct pci_dev *pdev,
+				   const struct pci_device_id *ent)
 {
 	int err = 0;
 	struct net_device *net_dev;
@@ -11767,7 +11768,7 @@ static int ipw_pci_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	return err;
 }
 
-static void ipw_pci_remove(struct pci_dev *pdev)
+static void __devexit ipw_pci_remove(struct pci_dev *pdev)
 {
 	struct ipw_priv *priv = pci_get_drvdata(pdev);
 	struct list_head *p, *q;
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 4bdf237..8797233 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -4743,8 +4743,10 @@ static void iwl_irq_tasklet(struct iwl_priv *priv)
 		 *   when we loaded driver, and is now set to "enable".
 		 * After we're Alive, RF_KILL gets handled by
 		 *   iwl_rx_card_state_notif() */
-		if (!hw_rf_kill && !test_bit(STATUS_ALIVE, &priv->status))
+		if (!hw_rf_kill && !test_bit(STATUS_ALIVE, &priv->status)) {
+			clear_bit(STATUS_RF_KILL_HW, &priv->status);
 			queue_work(priv->workqueue, &priv->restart);
+		}
 
 		handled |= CSR_INT_BIT_RF_KILL;
 	}
@@ -6171,6 +6173,7 @@ static void iwl_alive_start(struct iwl_priv *priv)
 		mutex_lock(&priv->mutex);
 
 		if (rc) {
+			iwl3945_rate_control_unregister(priv->hw);
 			IWL_ERROR("Failed to register network "
 				  "device (error %d)\n", rc);
 			return;
diff --git a/drivers/net/wireless/iwlwifi/iwl4965-base.c b/drivers/net/wireless/iwlwifi/iwl4965-base.c
index 8f85564..d7cc514 100644
--- a/drivers/net/wireless/iwlwifi/iwl4965-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl4965-base.c
@@ -5059,8 +5059,10 @@ static void iwl_irq_tasklet(struct iwl_priv *priv)
 		 *   when we loaded driver, and is now set to "enable".
 		 * After we're Alive, RF_KILL gets handled by
 		 *   iwl_rx_card_state_notif() */
-		if (!hw_rf_kill && !test_bit(STATUS_ALIVE, &priv->status))
+		if (!hw_rf_kill && !test_bit(STATUS_ALIVE, &priv->status)) {
+			clear_bit(STATUS_RF_KILL_HW, &priv->status);
 			queue_work(priv->workqueue, &priv->restart);
+		}
 
 		handled |= CSR_INT_BIT_RF_KILL;
 	}
@@ -6527,6 +6529,7 @@ static void iwl_alive_start(struct iwl_priv *priv)
 		mutex_lock(&priv->mutex);
 
 		if (rc) {
+			iwl4965_rate_control_unregister(priv->hw);
 			IWL_ERROR("Failed to register network "
 				  "device (error %d)\n", rc);
 			return;
diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wireless/zd1211rw/zd_mac.c
index a903645..5298a8b 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -1130,6 +1130,8 @@ static void zd_mac_rx(struct zd_mac *mac, struct sk_buff *skb)
 	__skb_trim(skb, skb->len -
 		        (IEEE80211_FCS_LEN + sizeof(struct rx_status)));
 
+	ZD_ASSERT(IS_ALIGNED((unsigned long)skb->data, 4));
+
 	update_qual_rssi(mac, skb->data, skb->len, stats.signal,
 		         status->signal_strength);
 
@@ -1166,15 +1168,19 @@ static void do_rx(unsigned long mac_ptr)
 int zd_mac_rx_irq(struct zd_mac *mac, const u8 *buffer, unsigned int length)
 {
 	struct sk_buff *skb;
+	unsigned int reserved =
+		ALIGN(max_t(unsigned int,
+		            sizeof(struct zd_rt_hdr), ZD_PLCP_HEADER_SIZE), 4) -
+		ZD_PLCP_HEADER_SIZE;
 
-	skb = dev_alloc_skb(sizeof(struct zd_rt_hdr) + length);
+	skb = dev_alloc_skb(reserved + length);
 	if (!skb) {
 		struct ieee80211_device *ieee = zd_mac_to_ieee80211(mac);
 		dev_warn(zd_mac_dev(mac), "Could not allocate skb.\n");
 		ieee->stats.rx_dropped++;
 		return -ENOMEM;
 	}
-	skb_reserve(skb, sizeof(struct zd_rt_hdr));
+	skb_reserve(skb, reserved);
 	memcpy(__skb_put(skb, length), buffer, length);
 	skb_queue_tail(&mac->rx_queue, skb);
 	tasklet_schedule(&mac->rx_tasklet);
diff --git a/net/mac80211/ieee80211_rate.c b/net/mac80211/ieee80211_rate.c
index 7254bd6..3260a4a 100644
--- a/net/mac80211/ieee80211_rate.c
+++ b/net/mac80211/ieee80211_rate.c
@@ -33,6 +33,7 @@ int ieee80211_rate_control_register(struct rate_control_ops *ops)
 		if (!strcmp(alg->ops->name, ops->name)) {
 			/* don't register an algorithm twice */
 			WARN_ON(1);
+			mutex_unlock(&rate_ctrl_mutex);
 			return -EALREADY;
 		}
 	}
-- 
John W. Linville
linville@tuxdriver.com
