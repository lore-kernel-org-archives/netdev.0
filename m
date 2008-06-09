From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2008-06-09
Date: Mon, 9 Jun 2008 17:08:58 -0400
Message-ID: <20080609210858.GB15375@tuxdriver.com>
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

Here is another round of fixes intended for 2.6.26.  Most of them are
small and obvious.

The ipw2200 one [1] is big, but a lot of it is moving and/or deleting some
old code.  It fixes a problem that can cause a new scan request to
eclipse and existing one in a way that keeps userland from getting the
requested scan results.

Please let me know if there are problems!

Thanks,

John

[1] This one was also originally in a pending wireless-next-2.6 request.
I'm reformulating that request and will resend it.

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit 24b95685ffcdb3dc28f64b9e8af6ea3e8360fbc5:
  James Chapman (1):
        l2tp: Fix possible oops if transmitting or receiving when tunnel goes down

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Adrian Bunk (1):
      include/linux/ssb/ssb_driver_gige.h typo fix

Assaf Krauss (2):
      mac80211: Fixing slow IBSS rejoin
      mac80211: Checking IBSS support while changing channel in ad-hoc mode

Dan Williams (3):
      ipw2200: queue direct scans
      mac80211: send association event on IBSS create
      mac80211: decrease IBSS creation latency

Holger Schurig (1):
      libertas: fix sleep confirmation

Marcin Slusarz (1):
      iwlwifi: fix oops in iwl3945_led_brightness_set

Michael Buesch (1):
      zd1211rw: Fix data padding for QoS

 drivers/net/wireless/ipw2200.c              |  176 +++++++++++++--------------
 drivers/net/wireless/ipw2200.h              |    6 +-
 drivers/net/wireless/iwlwifi/iwl-3945-led.c |    5 +-
 drivers/net/wireless/libertas/cmd.c         |    5 +-
 drivers/net/wireless/libertas/main.c        |    2 +-
 drivers/net/wireless/zd1211rw/zd_mac.c      |    2 +-
 include/linux/ssb/ssb_driver_gige.h         |    2 +-
 net/mac80211/ieee80211_i.h                  |    2 +-
 net/mac80211/main.c                         |    1 +
 net/mac80211/mlme.c                         |   18 ++--
 net/mac80211/wext.c                         |   15 ++-
 11 files changed, 120 insertions(+), 114 deletions(-)

diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index 7293367..6e70460 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -1753,6 +1753,8 @@ static int ipw_radio_kill_sw(struct ipw_priv *priv, int disable_radio)
 
 		if (priv->workqueue) {
 			cancel_delayed_work(&priv->request_scan);
+			cancel_delayed_work(&priv->request_direct_scan);
+			cancel_delayed_work(&priv->request_passive_scan);
 			cancel_delayed_work(&priv->scan_event);
 		}
 		queue_work(priv->workqueue, &priv->down);
@@ -2005,6 +2007,8 @@ static void ipw_irq_tasklet(struct ipw_priv *priv)
 		wake_up_interruptible(&priv->wait_command_queue);
 		priv->status &= ~(STATUS_ASSOCIATED | STATUS_ASSOCIATING);
 		cancel_delayed_work(&priv->request_scan);
+		cancel_delayed_work(&priv->request_direct_scan);
+		cancel_delayed_work(&priv->request_passive_scan);
 		cancel_delayed_work(&priv->scan_event);
 		schedule_work(&priv->link_down);
 		queue_delayed_work(priv->workqueue, &priv->rf_kill, 2 * HZ);
@@ -4712,6 +4716,12 @@ static void ipw_rx_notification(struct ipw_priv *priv,
 			priv->status &= ~STATUS_SCAN_FORCED;
 #endif				/* CONFIG_IPW2200_MONITOR */
 
+			/* Do queued direct scans first */
+			if (priv->status & STATUS_DIRECT_SCAN_PENDING) {
+				queue_delayed_work(priv->workqueue,
+						   &priv->request_direct_scan, 0);
+			}
+
 			if (!(priv->status & (STATUS_ASSOCIATED |
 					      STATUS_ASSOCIATING |
 					      STATUS_ROAMING |
@@ -6267,7 +6277,7 @@ static void ipw_add_scan_channels(struct ipw_priv *priv,
 	}
 }
 
-static int ipw_request_scan_helper(struct ipw_priv *priv, int type)
+static int ipw_request_scan_helper(struct ipw_priv *priv, int type, int direct)
 {
 	struct ipw_scan_request_ext scan;
 	int err = 0, scan_type;
@@ -6278,22 +6288,31 @@ static int ipw_request_scan_helper(struct ipw_priv *priv, int type)
 
 	mutex_lock(&priv->mutex);
 
+	if (direct && (priv->direct_scan_ssid_len == 0)) {
+		IPW_DEBUG_HC("Direct scan requested but no SSID to scan for\n");
+		priv->status &= ~STATUS_DIRECT_SCAN_PENDING;
+		goto done;
+	}
+
 	if (priv->status & STATUS_SCANNING) {
-		IPW_DEBUG_HC("Concurrent scan requested.  Ignoring.\n");
-		priv->status |= STATUS_SCAN_PENDING;
+		IPW_DEBUG_HC("Concurrent scan requested.  Queuing.\n");
+		priv->status |= direct ? STATUS_DIRECT_SCAN_PENDING :
+					STATUS_SCAN_PENDING;
 		goto done;
 	}
 
 	if (!(priv->status & STATUS_SCAN_FORCED) &&
 	    priv->status & STATUS_SCAN_ABORTING) {
 		IPW_DEBUG_HC("Scan request while abort pending.  Queuing.\n");
-		priv->status |= STATUS_SCAN_PENDING;
+		priv->status |= direct ? STATUS_DIRECT_SCAN_PENDING :
+					STATUS_SCAN_PENDING;
 		goto done;
 	}
 
 	if (priv->status & STATUS_RF_KILL_MASK) {
-		IPW_DEBUG_HC("Aborting scan due to RF Kill activation\n");
-		priv->status |= STATUS_SCAN_PENDING;
+		IPW_DEBUG_HC("Queuing scan due to RF Kill activation\n");
+		priv->status |= direct ? STATUS_DIRECT_SCAN_PENDING :
+					STATUS_SCAN_PENDING;
 		goto done;
 	}
 
@@ -6321,6 +6340,7 @@ static int ipw_request_scan_helper(struct ipw_priv *priv, int type)
 		cpu_to_le16(20);
 
   	scan.dwell_time[IPW_SCAN_PASSIVE_FULL_DWELL_SCAN] = cpu_to_le16(120);
+	scan.dwell_time[IPW_SCAN_ACTIVE_DIRECT_SCAN] = cpu_to_le16(20);
 
 #ifdef CONFIG_IPW2200_MONITOR
 	if (priv->ieee->iw_mode == IW_MODE_MONITOR) {
@@ -6360,13 +6380,23 @@ static int ipw_request_scan_helper(struct ipw_priv *priv, int type)
 			cpu_to_le16(2000);
 	} else {
 #endif				/* CONFIG_IPW2200_MONITOR */
-		/* If we are roaming, then make this a directed scan for the
-		 * current network.  Otherwise, ensure that every other scan
-		 * is a fast channel hop scan */
-		if ((priv->status & STATUS_ROAMING)
-		    || (!(priv->status & STATUS_ASSOCIATED)
-			&& (priv->config & CFG_STATIC_ESSID)
-			&& (le32_to_cpu(scan.full_scan_index) % 2))) {
+		/* Honor direct scans first, otherwise if we are roaming make
+		 * this a direct scan for the current network.  Finally,
+		 * ensure that every other scan is a fast channel hop scan */
+		if (direct) {
+			err = ipw_send_ssid(priv, priv->direct_scan_ssid,
+			                    priv->direct_scan_ssid_len);
+			if (err) {
+				IPW_DEBUG_HC("Attempt to send SSID command  "
+					     "failed\n");
+				goto done;
+			}
+
+			scan_type = IPW_SCAN_ACTIVE_BROADCAST_AND_DIRECT_SCAN;
+		} else if ((priv->status & STATUS_ROAMING)
+			   || (!(priv->status & STATUS_ASSOCIATED)
+			       && (priv->config & CFG_STATIC_ESSID)
+			       && (le32_to_cpu(scan.full_scan_index) % 2))) {
 			err = ipw_send_ssid(priv, priv->essid, priv->essid_len);
 			if (err) {
 				IPW_DEBUG_HC("Attempt to send SSID command "
@@ -6391,7 +6421,12 @@ send_request:
 	}
 
 	priv->status |= STATUS_SCANNING;
-	priv->status &= ~STATUS_SCAN_PENDING;
+	if (direct) {
+		priv->status &= ~STATUS_DIRECT_SCAN_PENDING;
+		priv->direct_scan_ssid_len = 0;
+	} else
+		priv->status &= ~STATUS_SCAN_PENDING;
+
 	queue_delayed_work(priv->workqueue, &priv->scan_check,
 			   IPW_SCAN_CHECK_WATCHDOG);
 done:
@@ -6402,15 +6437,22 @@ done:
 static void ipw_request_passive_scan(struct work_struct *work)
 {
 	struct ipw_priv *priv =
-		container_of(work, struct ipw_priv, request_passive_scan);
-  	ipw_request_scan_helper(priv, IW_SCAN_TYPE_PASSIVE);
+		container_of(work, struct ipw_priv, request_passive_scan.work);
+	ipw_request_scan_helper(priv, IW_SCAN_TYPE_PASSIVE, 0);
 }
 
 static void ipw_request_scan(struct work_struct *work)
 {
 	struct ipw_priv *priv =
 		container_of(work, struct ipw_priv, request_scan.work);
-	ipw_request_scan_helper(priv, IW_SCAN_TYPE_ACTIVE);
+	ipw_request_scan_helper(priv, IW_SCAN_TYPE_ACTIVE, 0);
+}
+
+static void ipw_request_direct_scan(struct work_struct *work)
+{
+	struct ipw_priv *priv =
+		container_of(work, struct ipw_priv, request_direct_scan.work);
+	ipw_request_scan_helper(priv, IW_SCAN_TYPE_ACTIVE, 1);
 }
 
 static void ipw_bg_abort_scan(struct work_struct *work)
@@ -9477,99 +9519,38 @@ static int ipw_wx_get_retry(struct net_device *dev,
 	return 0;
 }
 
-static int ipw_request_direct_scan(struct ipw_priv *priv, char *essid,
-				   int essid_len)
-{
-	struct ipw_scan_request_ext scan;
-	int err = 0, scan_type;
-
-	if (!(priv->status & STATUS_INIT) ||
-	    (priv->status & STATUS_EXIT_PENDING))
-		return 0;
-
-	mutex_lock(&priv->mutex);
-
-	if (priv->status & STATUS_RF_KILL_MASK) {
-		IPW_DEBUG_HC("Aborting scan due to RF kill activation\n");
-		priv->status |= STATUS_SCAN_PENDING;
-		goto done;
-	}
-
-	IPW_DEBUG_HC("starting request direct scan!\n");
-
-	if (priv->status & (STATUS_SCANNING | STATUS_SCAN_ABORTING)) {
-		/* We should not sleep here; otherwise we will block most
-		 * of the system (for instance, we hold rtnl_lock when we
-		 * get here).
-		 */
-		err = -EAGAIN;
-		goto done;
-	}
-	memset(&scan, 0, sizeof(scan));
-
-	if (priv->config & CFG_SPEED_SCAN)
-		scan.dwell_time[IPW_SCAN_ACTIVE_BROADCAST_SCAN] =
-		    cpu_to_le16(30);
-	else
-		scan.dwell_time[IPW_SCAN_ACTIVE_BROADCAST_SCAN] =
-		    cpu_to_le16(20);
-
-	scan.dwell_time[IPW_SCAN_ACTIVE_BROADCAST_AND_DIRECT_SCAN] =
-	    cpu_to_le16(20);
-	scan.dwell_time[IPW_SCAN_PASSIVE_FULL_DWELL_SCAN] = cpu_to_le16(120);
-	scan.dwell_time[IPW_SCAN_ACTIVE_DIRECT_SCAN] = cpu_to_le16(20);
-
-	scan.full_scan_index = cpu_to_le32(ieee80211_get_scans(priv->ieee));
-
-	err = ipw_send_ssid(priv, essid, essid_len);
-	if (err) {
-		IPW_DEBUG_HC("Attempt to send SSID command failed\n");
-		goto done;
-	}
-	scan_type = IPW_SCAN_ACTIVE_BROADCAST_AND_DIRECT_SCAN;
-
-	ipw_add_scan_channels(priv, &scan, scan_type);
-
-	err = ipw_send_scan_request_ext(priv, &scan);
-	if (err) {
-		IPW_DEBUG_HC("Sending scan command failed: %08X\n", err);
-		goto done;
-	}
-
-	priv->status |= STATUS_SCANNING;
-
-      done:
-	mutex_unlock(&priv->mutex);
-	return err;
-}
-
 static int ipw_wx_set_scan(struct net_device *dev,
 			   struct iw_request_info *info,
 			   union iwreq_data *wrqu, char *extra)
 {
 	struct ipw_priv *priv = ieee80211_priv(dev);
 	struct iw_scan_req *req = (struct iw_scan_req *)extra;
+	struct delayed_work *work = NULL;
 
 	mutex_lock(&priv->mutex);
+
 	priv->user_requested_scan = 1;
-	mutex_unlock(&priv->mutex);
 
 	if (wrqu->data.length == sizeof(struct iw_scan_req)) {
 		if (wrqu->data.flags & IW_SCAN_THIS_ESSID) {
-			ipw_request_direct_scan(priv, req->essid,
-						req->essid_len);
-			return 0;
-		}
-		if (req->scan_type == IW_SCAN_TYPE_PASSIVE) {
-			queue_work(priv->workqueue,
-				   &priv->request_passive_scan);
-			return 0;
+			int len = min((int)req->essid_len,
+			              (int)sizeof(priv->direct_scan_ssid));
+			memcpy(priv->direct_scan_ssid, req->essid, len);
+			priv->direct_scan_ssid_len = len;
+			work = &priv->request_direct_scan;
+		} else if (req->scan_type == IW_SCAN_TYPE_PASSIVE) {
+			work = &priv->request_passive_scan;
 		}
+	} else {
+		/* Normal active broadcast scan */
+		work = &priv->request_scan;
 	}
 
+	mutex_unlock(&priv->mutex);
+
 	IPW_DEBUG_WX("Start scan\n");
 
-	queue_delayed_work(priv->workqueue, &priv->request_scan, 0);
+	queue_delayed_work(priv->workqueue, work, 0);
 
 	return 0;
 }
@@ -10731,6 +10712,8 @@ static void ipw_link_up(struct ipw_priv *priv)
 	}
 
 	cancel_delayed_work(&priv->request_scan);
+	cancel_delayed_work(&priv->request_direct_scan);
+	cancel_delayed_work(&priv->request_passive_scan);
 	cancel_delayed_work(&priv->scan_event);
 	ipw_reset_stats(priv);
 	/* Ensure the rate is updated immediately */
@@ -10761,6 +10744,8 @@ static void ipw_link_down(struct ipw_priv *priv)
 
 	/* Cancel any queued work ... */
 	cancel_delayed_work(&priv->request_scan);
+	cancel_delayed_work(&priv->request_direct_scan);
+	cancel_delayed_work(&priv->request_passive_scan);
 	cancel_delayed_work(&priv->adhoc_check);
 	cancel_delayed_work(&priv->gather_stats);
 
@@ -10800,8 +10785,9 @@ static int __devinit ipw_setup_deferred_work(struct ipw_priv *priv)
 	INIT_WORK(&priv->up, ipw_bg_up);
 	INIT_WORK(&priv->down, ipw_bg_down);
 	INIT_DELAYED_WORK(&priv->request_scan, ipw_request_scan);
+	INIT_DELAYED_WORK(&priv->request_direct_scan, ipw_request_direct_scan);
+	INIT_DELAYED_WORK(&priv->request_passive_scan, ipw_request_passive_scan);
 	INIT_DELAYED_WORK(&priv->scan_event, ipw_scan_event);
-	INIT_WORK(&priv->request_passive_scan, ipw_request_passive_scan);
 	INIT_DELAYED_WORK(&priv->gather_stats, ipw_bg_gather_stats);
 	INIT_WORK(&priv->abort_scan, ipw_bg_abort_scan);
 	INIT_WORK(&priv->roam, ipw_bg_roam);
@@ -11835,6 +11821,8 @@ static void __devexit ipw_pci_remove(struct pci_dev *pdev)
 	cancel_delayed_work(&priv->adhoc_check);
 	cancel_delayed_work(&priv->gather_stats);
 	cancel_delayed_work(&priv->request_scan);
+	cancel_delayed_work(&priv->request_direct_scan);
+	cancel_delayed_work(&priv->request_passive_scan);
 	cancel_delayed_work(&priv->scan_event);
 	cancel_delayed_work(&priv->rf_kill);
 	cancel_delayed_work(&priv->scan_check);
diff --git a/drivers/net/wireless/ipw2200.h b/drivers/net/wireless/ipw2200.h
index cd3295b..d4ab28b 100644
--- a/drivers/net/wireless/ipw2200.h
+++ b/drivers/net/wireless/ipw2200.h
@@ -1037,6 +1037,7 @@ struct ipw_cmd {	 /* XXX */
 #define STATUS_DISASSOC_PENDING (1<<12)
 #define STATUS_STATE_PENDING    (1<<13)
 
+#define STATUS_DIRECT_SCAN_PENDING (1<<19)
 #define STATUS_SCAN_PENDING     (1<<20)
 #define STATUS_SCANNING         (1<<21)
 #define STATUS_SCAN_ABORTING    (1<<22)
@@ -1292,6 +1293,8 @@ struct ipw_priv {
 	struct iw_public_data wireless_data;
 
 	int user_requested_scan;
+	u8 direct_scan_ssid[IW_ESSID_MAX_SIZE];
+	u8 direct_scan_ssid_len;
 
 	struct workqueue_struct *workqueue;
 
@@ -1301,8 +1304,9 @@ struct ipw_priv {
 	struct work_struct system_config;
 	struct work_struct rx_replenish;
 	struct delayed_work request_scan;
+	struct delayed_work request_direct_scan;
+	struct delayed_work request_passive_scan;
 	struct delayed_work scan_event;
-  	struct work_struct request_passive_scan;
 	struct work_struct adapter_restart;
 	struct delayed_work rf_kill;
 	struct work_struct up;
diff --git a/drivers/net/wireless/iwlwifi/iwl-3945-led.c b/drivers/net/wireless/iwlwifi/iwl-3945-led.c
index d200d08..8b1528e 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945-led.c
+++ b/drivers/net/wireless/iwlwifi/iwl-3945-led.c
@@ -229,14 +229,15 @@ static int iwl3945_led_register_led(struct iwl3945_priv *priv,
 	led->led_dev.brightness_set = iwl3945_led_brightness_set;
 	led->led_dev.default_trigger = trigger;
 
+	led->priv = priv;
+	led->type = type;
+
 	ret = led_classdev_register(device, &led->led_dev);
 	if (ret) {
 		IWL_ERROR("Error: failed to register led handler.\n");
 		return ret;
 	}
 
-	led->priv = priv;
-	led->type = type;
 	led->registered = 1;
 
 	if (set_led && led->led_on)
diff --git a/drivers/net/wireless/libertas/cmd.c b/drivers/net/wireless/libertas/cmd.c
index 6328b95..8124fd9 100644
--- a/drivers/net/wireless/libertas/cmd.c
+++ b/drivers/net/wireless/libertas/cmd.c
@@ -1842,6 +1842,9 @@ static void lbs_send_confirmsleep(struct lbs_private *priv)
 
 	spin_lock_irqsave(&priv->driver_lock, flags);
 
+	/* We don't get a response on the sleep-confirmation */
+	priv->dnld_sent = DNLD_RES_RECEIVED;
+
 	/* If nothing to do, go back to sleep (?) */
 	if (!__kfifo_len(priv->event_fifo) && !priv->resp_len[priv->resp_idx])
 		priv->psstate = PS_STATE_SLEEP;
@@ -1904,12 +1907,12 @@ void lbs_ps_confirm_sleep(struct lbs_private *priv)
 
 	lbs_deb_enter(LBS_DEB_HOST);
 
+	spin_lock_irqsave(&priv->driver_lock, flags);
 	if (priv->dnld_sent) {
 		allowed = 0;
 		lbs_deb_host("dnld_sent was set\n");
 	}
 
-	spin_lock_irqsave(&priv->driver_lock, flags);
 	/* In-progress command? */
 	if (priv->cur_cmd) {
 		allowed = 0;
diff --git a/drivers/net/wireless/libertas/main.c b/drivers/net/wireless/libertas/main.c
index e1f0660..acfc4bf 100644
--- a/drivers/net/wireless/libertas/main.c
+++ b/drivers/net/wireless/libertas/main.c
@@ -732,8 +732,8 @@ static int lbs_thread(void *data)
 		lbs_deb_thread("4: currenttxskb %p, dnld_sent %d\n",
 		       priv->currenttxskb, priv->dnld_sent);
 
-		spin_lock_irq(&priv->driver_lock);
 		/* Process any pending command response */
+		spin_lock_irq(&priv->driver_lock);
 		resp_idx = priv->resp_idx;
 		if (priv->resp_len[resp_idx]) {
 			spin_unlock_irq(&priv->driver_lock);
diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wireless/zd1211rw/zd_mac.c
index 6424e5a..418606a 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -719,7 +719,7 @@ int zd_mac_rx(struct ieee80211_hw *hw, const u8 *buffer, unsigned int length)
 	fc = le16_to_cpu(*((__le16 *) buffer));
 
 	is_qos = ((fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_DATA) &&
-		 ((fc & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_QOS_DATA);
+		 (fc & IEEE80211_STYPE_QOS_DATA);
 	is_4addr = (fc & (IEEE80211_FCTL_TODS | IEEE80211_FCTL_FROMDS)) ==
 		   (IEEE80211_FCTL_TODS | IEEE80211_FCTL_FROMDS);
 	need_padding = is_qos ^ is_4addr;
diff --git a/include/linux/ssb/ssb_driver_gige.h b/include/linux/ssb/ssb_driver_gige.h
index 01fbdf5..942e387 100644
--- a/include/linux/ssb/ssb_driver_gige.h
+++ b/include/linux/ssb/ssb_driver_gige.h
@@ -100,7 +100,7 @@ extern char * nvram_get(const char *name);
 /* Get the device MAC address */
 static inline void ssb_gige_get_macaddr(struct pci_dev *pdev, u8 *macaddr)
 {
-#ifdef CONFIG_BCM947XX
+#ifdef CONFIG_BCM47XX
 	char *res = nvram_get("et0macaddr");
 	if (res)
 		memcpy(macaddr, res, 6);
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index c7314bf..006486b 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -899,7 +899,7 @@ extern const struct iw_handler_def ieee80211_iw_handler_def;
 
 
 /* ieee80211_ioctl.c */
-int ieee80211_set_freq(struct ieee80211_local *local, int freq);
+int ieee80211_set_freq(struct net_device *dev, int freq);
 /* ieee80211_sta.c */
 void ieee80211_sta_timer(unsigned long data);
 void ieee80211_sta_work(struct work_struct *work);
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index 5c87645..98c0b5e 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -511,6 +511,7 @@ static int ieee80211_stop(struct net_device *dev)
 	case IEEE80211_IF_TYPE_STA:
 	case IEEE80211_IF_TYPE_IBSS:
 		sdata->u.sta.state = IEEE80211_DISABLED;
+		memset(sdata->u.sta.bssid, 0, ETH_ALEN);
 		del_timer_sync(&sdata->u.sta.timer);
 		/*
 		 * When we get here, the interface is marked down.
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 841278f..4d2b582 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -44,7 +44,7 @@
 #define IEEE80211_RETRY_AUTH_INTERVAL (1 * HZ)
 #define IEEE80211_SCAN_INTERVAL (2 * HZ)
 #define IEEE80211_SCAN_INTERVAL_SLOW (15 * HZ)
-#define IEEE80211_IBSS_JOIN_TIMEOUT (20 * HZ)
+#define IEEE80211_IBSS_JOIN_TIMEOUT (7 * HZ)
 
 #define IEEE80211_PROBE_DELAY (HZ / 33)
 #define IEEE80211_CHANNEL_TIME (HZ / 33)
@@ -2336,6 +2336,7 @@ static int ieee80211_sta_join_ibss(struct net_device *dev,
 	u8 *pos;
 	struct ieee80211_sub_if_data *sdata;
 	struct ieee80211_supported_band *sband;
+	union iwreq_data wrqu;
 
 	sband = local->hw.wiphy->bands[local->hw.conf.channel->band];
 
@@ -2358,13 +2359,10 @@ static int ieee80211_sta_join_ibss(struct net_device *dev,
 	sdata->drop_unencrypted = bss->capability &
 		WLAN_CAPABILITY_PRIVACY ? 1 : 0;
 
-	res = ieee80211_set_freq(local, bss->freq);
+	res = ieee80211_set_freq(dev, bss->freq);
 
-	if (local->oper_channel->flags & IEEE80211_CHAN_NO_IBSS) {
-		printk(KERN_DEBUG "%s: IBSS not allowed on frequency "
-		       "%d MHz\n", dev->name, local->oper_channel->center_freq);
-		return -1;
-	}
+	if (res)
+		return res;
 
 	/* Set beacon template */
 	skb = dev_alloc_skb(local->hw.extra_tx_headroom + 400);
@@ -2479,6 +2477,10 @@ static int ieee80211_sta_join_ibss(struct net_device *dev,
 	ifsta->state = IEEE80211_IBSS_JOINED;
 	mod_timer(&ifsta->timer, jiffies + IEEE80211_IBSS_MERGE_INTERVAL);
 
+	memset(&wrqu, 0, sizeof(wrqu));
+	memcpy(wrqu.ap_addr.sa_data, bss->bssid, ETH_ALEN);
+	wireless_send_event(dev, SIOCGIWAP, &wrqu, NULL);
+
 	return res;
 }
 
@@ -3486,7 +3488,7 @@ static int ieee80211_sta_config_auth(struct net_device *dev,
 	spin_unlock_bh(&local->sta_bss_lock);
 
 	if (selected) {
-		ieee80211_set_freq(local, selected->freq);
+		ieee80211_set_freq(dev, selected->freq);
 		if (!(ifsta->flags & IEEE80211_STA_SSID_SET))
 			ieee80211_sta_set_ssid(dev, selected->ssid,
 					       selected->ssid_len);
diff --git a/net/mac80211/wext.c b/net/mac80211/wext.c
index 8311bb2..a8bb8e3 100644
--- a/net/mac80211/wext.c
+++ b/net/mac80211/wext.c
@@ -290,14 +290,22 @@ static int ieee80211_ioctl_giwmode(struct net_device *dev,
 	return 0;
 }
 
-int ieee80211_set_freq(struct ieee80211_local *local, int freqMHz)
+int ieee80211_set_freq(struct net_device *dev, int freqMHz)
 {
 	int ret = -EINVAL;
 	struct ieee80211_channel *chan;
+	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 
 	chan = ieee80211_get_channel(local->hw.wiphy, freqMHz);
 
 	if (chan && !(chan->flags & IEEE80211_CHAN_DISABLED)) {
+		if (sdata->vif.type == IEEE80211_IF_TYPE_IBSS &&
+		    chan->flags & IEEE80211_CHAN_NO_IBSS) {
+			printk(KERN_DEBUG "%s: IBSS not allowed on frequency "
+				"%d MHz\n", dev->name, chan->center_freq);
+			return ret;
+		}
 		local->oper_channel = chan;
 
 		if (local->sta_sw_scanning || local->sta_hw_scanning)
@@ -315,7 +323,6 @@ static int ieee80211_ioctl_siwfreq(struct net_device *dev,
 				   struct iw_request_info *info,
 				   struct iw_freq *freq, char *extra)
 {
-	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 
 	if (sdata->vif.type == IEEE80211_IF_TYPE_STA)
@@ -329,14 +336,14 @@ static int ieee80211_ioctl_siwfreq(struct net_device *dev,
 					IEEE80211_STA_AUTO_CHANNEL_SEL;
 			return 0;
 		} else
-			return ieee80211_set_freq(local,
+			return ieee80211_set_freq(dev,
 				ieee80211_channel_to_frequency(freq->m));
 	} else {
 		int i, div = 1000000;
 		for (i = 0; i < freq->e; i++)
 			div /= 10;
 		if (div > 0)
-			return ieee80211_set_freq(local, freq->m / div);
+			return ieee80211_set_freq(dev, freq->m / div);
 		else
 			return -EINVAL;
 	}
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
