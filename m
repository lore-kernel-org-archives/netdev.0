From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2008-06-27
Date: Fri, 27 Jun 2008 15:14:12 -0400
Message-ID: <20080627191412.GA24606@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Another quick round of fixes hoping to see 2.6.26...

Thanks!

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit 7ac3b02536c9ccfcc8aabc4c135a371ac4641805:
  David S. Miller (1):
        Merge branch 'master' of master.kernel.org:/.../linville/wireless-2.6

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Emmanuel Grumbach (1):
      mac80211: fix an oops in several failure paths in key allocation

Harvey Harrison (1):
      prism: islpci_eth.c endianness fix

Ivo van Doorn (1):
      rt2x00: Fix lock dependency errror

 drivers/net/wireless/prism54/islpci_eth.c |    2 +-
 drivers/net/wireless/rt2x00/rt2x00.h      |    1 +
 drivers/net/wireless/rt2x00/rt2x00dev.c   |   38 +++++++++++++++++++----------
 drivers/net/wireless/rt2x00/rt2x00mac.c   |    4 +-
 net/mac80211/key.c                        |    9 +++++++
 5 files changed, 38 insertions(+), 16 deletions(-)

diff --git a/drivers/net/wireless/prism54/islpci_eth.c b/drivers/net/wireless/prism54/islpci_eth.c
index 762e85b..e43bae9 100644
--- a/drivers/net/wireless/prism54/islpci_eth.c
+++ b/drivers/net/wireless/prism54/islpci_eth.c
@@ -290,7 +290,7 @@ islpci_monitor_rx(islpci_private *priv, struct sk_buff **skb)
 
 		avs->version = cpu_to_be32(P80211CAPTURE_VERSION);
 		avs->length = cpu_to_be32(sizeof (struct avs_80211_1_header));
-		avs->mactime = cpu_to_be64(le64_to_cpu(clock));
+		avs->mactime = cpu_to_be64(clock);
 		avs->hosttime = cpu_to_be64(jiffies);
 		avs->phytype = cpu_to_be32(6);	/*OFDM: 6 for (g), 8 for (a) */
 		avs->channel = cpu_to_be32(channel_of_freq(freq));
diff --git a/drivers/net/wireless/rt2x00/rt2x00.h b/drivers/net/wireless/rt2x00/rt2x00.h
index 611d983..b4bf1e0 100644
--- a/drivers/net/wireless/rt2x00/rt2x00.h
+++ b/drivers/net/wireless/rt2x00/rt2x00.h
@@ -821,6 +821,7 @@ struct rt2x00_dev {
 	/*
 	 * Scheduled work.
 	 */
+	struct workqueue_struct *workqueue;
 	struct work_struct intf_work;
 	struct work_struct filter_work;
 
diff --git a/drivers/net/wireless/rt2x00/rt2x00dev.c b/drivers/net/wireless/rt2x00/rt2x00dev.c
index 2673d56..c997d4f 100644
--- a/drivers/net/wireless/rt2x00/rt2x00dev.c
+++ b/drivers/net/wireless/rt2x00/rt2x00dev.c
@@ -75,7 +75,7 @@ static void rt2x00lib_start_link_tuner(struct rt2x00_dev *rt2x00dev)
 
 	rt2x00lib_reset_link_tuner(rt2x00dev);
 
-	queue_delayed_work(rt2x00dev->hw->workqueue,
+	queue_delayed_work(rt2x00dev->workqueue,
 			   &rt2x00dev->link.work, LINK_TUNE_INTERVAL);
 }
 
@@ -137,14 +137,6 @@ void rt2x00lib_disable_radio(struct rt2x00_dev *rt2x00dev)
 		return;
 
 	/*
-	 * Stop all scheduled work.
-	 */
-	if (work_pending(&rt2x00dev->intf_work))
-		cancel_work_sync(&rt2x00dev->intf_work);
-	if (work_pending(&rt2x00dev->filter_work))
-		cancel_work_sync(&rt2x00dev->filter_work);
-
-	/*
 	 * Stop the TX queues.
 	 */
 	ieee80211_stop_queues(rt2x00dev->hw);
@@ -398,8 +390,8 @@ static void rt2x00lib_link_tuner(struct work_struct *work)
 	 * Increase tuner counter, and reschedule the next link tuner run.
 	 */
 	rt2x00dev->link.count++;
-	queue_delayed_work(rt2x00dev->hw->workqueue, &rt2x00dev->link.work,
-			   LINK_TUNE_INTERVAL);
+	queue_delayed_work(rt2x00dev->workqueue,
+			   &rt2x00dev->link.work, LINK_TUNE_INTERVAL);
 }
 
 static void rt2x00lib_packetfilter_scheduled(struct work_struct *work)
@@ -433,6 +425,15 @@ static void rt2x00lib_intf_scheduled_iter(void *data, u8 *mac,
 
 	spin_unlock(&intf->lock);
 
+	/*
+	 * It is possible the radio was disabled while the work had been
+	 * scheduled. If that happens we should return here immediately,
+	 * note that in the spinlock protected area above the delayed_flags
+	 * have been cleared correctly.
+	 */
+	if (!test_bit(DEVICE_ENABLED_RADIO, &rt2x00dev->flags))
+		return;
+
 	if (delayed_flags & DELAYED_UPDATE_BEACON) {
 		skb = ieee80211_beacon_get(rt2x00dev->hw, vif, &control);
 		if (skb && rt2x00dev->ops->hw->beacon_update(rt2x00dev->hw,
@@ -441,7 +442,7 @@ static void rt2x00lib_intf_scheduled_iter(void *data, u8 *mac,
 	}
 
 	if (delayed_flags & DELAYED_CONFIG_ERP)
-		rt2x00lib_config_erp(rt2x00dev, intf, &intf->conf);
+		rt2x00lib_config_erp(rt2x00dev, intf, &conf);
 
 	if (delayed_flags & DELAYED_LED_ASSOC)
 		rt2x00leds_led_assoc(rt2x00dev, !!rt2x00dev->intf_associated);
@@ -487,7 +488,7 @@ void rt2x00lib_beacondone(struct rt2x00_dev *rt2x00dev)
 						   rt2x00lib_beacondone_iter,
 						   rt2x00dev);
 
-	queue_work(rt2x00dev->hw->workqueue, &rt2x00dev->intf_work);
+	queue_work(rt2x00dev->workqueue, &rt2x00dev->intf_work);
 }
 EXPORT_SYMBOL_GPL(rt2x00lib_beacondone);
 
@@ -1130,6 +1131,10 @@ int rt2x00lib_probe_dev(struct rt2x00_dev *rt2x00dev)
 	/*
 	 * Initialize configuration work.
 	 */
+	rt2x00dev->workqueue = create_singlethread_workqueue("rt2x00lib");
+	if (!rt2x00dev->workqueue)
+		goto exit;
+
 	INIT_WORK(&rt2x00dev->intf_work, rt2x00lib_intf_scheduled);
 	INIT_WORK(&rt2x00dev->filter_work, rt2x00lib_packetfilter_scheduled);
 	INIT_DELAYED_WORK(&rt2x00dev->link.work, rt2x00lib_link_tuner);
@@ -1190,6 +1195,13 @@ void rt2x00lib_remove_dev(struct rt2x00_dev *rt2x00dev)
 	rt2x00leds_unregister(rt2x00dev);
 
 	/*
+	 * Stop all queued work. Note that most tasks will already be halted
+	 * during rt2x00lib_disable_radio() and rt2x00lib_uninitialize().
+	 */
+	flush_workqueue(rt2x00dev->workqueue);
+	destroy_workqueue(rt2x00dev->workqueue);
+
+	/*
 	 * Free ieee80211_hw memory.
 	 */
 	rt2x00lib_remove_hw(rt2x00dev);
diff --git a/drivers/net/wireless/rt2x00/rt2x00mac.c b/drivers/net/wireless/rt2x00/rt2x00mac.c
index 87e280a..9cb023e 100644
--- a/drivers/net/wireless/rt2x00/rt2x00mac.c
+++ b/drivers/net/wireless/rt2x00/rt2x00mac.c
@@ -428,7 +428,7 @@ void rt2x00mac_configure_filter(struct ieee80211_hw *hw,
 	if (!test_bit(DRIVER_REQUIRE_SCHEDULED, &rt2x00dev->flags))
 		rt2x00dev->ops->lib->config_filter(rt2x00dev, *total_flags);
 	else
-		queue_work(rt2x00dev->hw->workqueue, &rt2x00dev->filter_work);
+		queue_work(rt2x00dev->workqueue, &rt2x00dev->filter_work);
 }
 EXPORT_SYMBOL_GPL(rt2x00mac_configure_filter);
 
@@ -509,7 +509,7 @@ void rt2x00mac_bss_info_changed(struct ieee80211_hw *hw,
 	memcpy(&intf->conf, bss_conf, sizeof(*bss_conf));
 	if (delayed) {
 		intf->delayed_flags |= delayed;
-		queue_work(rt2x00dev->hw->workqueue, &rt2x00dev->intf_work);
+		queue_work(rt2x00dev->workqueue, &rt2x00dev->intf_work);
 	}
 	spin_unlock(&intf->lock);
 }
diff --git a/net/mac80211/key.c b/net/mac80211/key.c
index 150d66d..220e83b 100644
--- a/net/mac80211/key.c
+++ b/net/mac80211/key.c
@@ -380,6 +380,15 @@ void ieee80211_key_free(struct ieee80211_key *key)
 	if (!key)
 		return;
 
+	if (!key->sdata) {
+		/* The key has not been linked yet, simply free it
+		 * and don't Oops */
+		if (key->conf.alg == ALG_CCMP)
+			ieee80211_aes_key_free(key->u.ccmp.tfm);
+		kfree(key);
+		return;
+	}
+
 	spin_lock_irqsave(&key->sdata->local->key_lock, flags);
 	__ieee80211_key_free(key);
 	spin_unlock_irqrestore(&key->sdata->local->key_lock, flags);
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
