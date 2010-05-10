From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2010-05-10
Date: Mon, 10 May 2010 13:43:29 -0400
Message-ID: <20100510174329.GC11681@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

Here are three more candidates for 2.6.34.  I hesitated to push them,
but at least two of them are documented regressions and the other (i.e.
"iwlwifi: work around passive scan issue") avoids some rather annoying
firmware restarts at little or no risk.  I think it would be good to
take these now rather than later.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 80ea76bb2575c426154b8d61d324197ee3592baa:
  David S. Miller (1):
        phy: Fix initialization in micrel driver.

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Christian Lamparter (1):
      ar9170: wait for asynchronous firmware loading

Johannes Berg (1):
      iwlwifi: work around passive scan issue

Reinette Chatre (1):
      mac80211: remove association work when processing deauth request

 drivers/net/wireless/ath/ar9170/usb.c       |   11 +++++++++++
 drivers/net/wireless/ath/ar9170/usb.h       |    1 +
 drivers/net/wireless/iwlwifi/iwl-commands.h |    4 +++-
 drivers/net/wireless/iwlwifi/iwl-scan.c     |   23 ++++++++++++++++++-----
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    3 ++-
 net/mac80211/mlme.c                         |    3 ++-
 6 files changed, 37 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wireless/ath/ar9170/usb.c b/drivers/net/wireless/ath/ar9170/usb.c
index 6b1cb70..24dc555 100644
--- a/drivers/net/wireless/ath/ar9170/usb.c
+++ b/drivers/net/wireless/ath/ar9170/usb.c
@@ -726,12 +726,16 @@ static void ar9170_usb_firmware_failed(struct ar9170_usb *aru)
 {
 	struct device *parent = aru->udev->dev.parent;
 
+	complete(&aru->firmware_loading_complete);
+
 	/* unbind anything failed */
 	if (parent)
 		down(&parent->sem);
 	device_release_driver(&aru->udev->dev);
 	if (parent)
 		up(&parent->sem);
+
+	usb_put_dev(aru->udev);
 }
 
 static void ar9170_usb_firmware_finish(const struct firmware *fw, void *context)
@@ -760,6 +764,8 @@ static void ar9170_usb_firmware_finish(const struct firmware *fw, void *context)
 	if (err)
 		goto err_unrx;
 
+	complete(&aru->firmware_loading_complete);
+	usb_put_dev(aru->udev);
 	return;
 
  err_unrx:
@@ -857,6 +863,7 @@ static int ar9170_usb_probe(struct usb_interface *intf,
 	init_usb_anchor(&aru->tx_pending);
 	init_usb_anchor(&aru->tx_submitted);
 	init_completion(&aru->cmd_wait);
+	init_completion(&aru->firmware_loading_complete);
 	spin_lock_init(&aru->tx_urb_lock);
 
 	aru->tx_pending_urbs = 0;
@@ -876,6 +883,7 @@ static int ar9170_usb_probe(struct usb_interface *intf,
 	if (err)
 		goto err_freehw;
 
+	usb_get_dev(aru->udev);
 	return request_firmware_nowait(THIS_MODULE, 1, "ar9170.fw",
 				       &aru->udev->dev, GFP_KERNEL, aru,
 				       ar9170_usb_firmware_step2);
@@ -895,6 +903,9 @@ static void ar9170_usb_disconnect(struct usb_interface *intf)
 		return;
 
 	aru->common.state = AR9170_IDLE;
+
+	wait_for_completion(&aru->firmware_loading_complete);
+
 	ar9170_unregister(&aru->common);
 	ar9170_usb_cancel_urbs(aru);
 
diff --git a/drivers/net/wireless/ath/ar9170/usb.h b/drivers/net/wireless/ath/ar9170/usb.h
index a2ce3b1..919b060 100644
--- a/drivers/net/wireless/ath/ar9170/usb.h
+++ b/drivers/net/wireless/ath/ar9170/usb.h
@@ -71,6 +71,7 @@ struct ar9170_usb {
 	unsigned int tx_pending_urbs;
 
 	struct completion cmd_wait;
+	struct completion firmware_loading_complete;
 	int readlen;
 	u8 *readbuf;
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-commands.h b/drivers/net/wireless/iwlwifi/iwl-commands.h
index 6383d9f..f4e59ae 100644
--- a/drivers/net/wireless/iwlwifi/iwl-commands.h
+++ b/drivers/net/wireless/iwlwifi/iwl-commands.h
@@ -2621,7 +2621,9 @@ struct iwl_ssid_ie {
 #define PROBE_OPTION_MAX_3945		4
 #define PROBE_OPTION_MAX		20
 #define TX_CMD_LIFE_TIME_INFINITE	cpu_to_le32(0xFFFFFFFF)
-#define IWL_GOOD_CRC_TH			cpu_to_le16(1)
+#define IWL_GOOD_CRC_TH_DISABLED	0
+#define IWL_GOOD_CRC_TH_DEFAULT		cpu_to_le16(1)
+#define IWL_GOOD_CRC_TH_NEVER		cpu_to_le16(0xffff)
 #define IWL_MAX_SCAN_SIZE 1024
 #define IWL_MAX_CMD_SIZE 4096
 #define IWL_MAX_PROBE_REQUEST		200
diff --git a/drivers/net/wireless/iwlwifi/iwl-scan.c b/drivers/net/wireless/iwlwifi/iwl-scan.c
index 5062f4e..2367286 100644
--- a/drivers/net/wireless/iwlwifi/iwl-scan.c
+++ b/drivers/net/wireless/iwlwifi/iwl-scan.c
@@ -812,16 +812,29 @@ static void iwl_bg_request_scan(struct work_struct *data)
 			rate = IWL_RATE_1M_PLCP;
 			rate_flags = RATE_MCS_CCK_MSK;
 		}
-		scan->good_CRC_th = 0;
+		scan->good_CRC_th = IWL_GOOD_CRC_TH_DISABLED;
 	} else if (priv->scan_bands & BIT(IEEE80211_BAND_5GHZ)) {
 		band = IEEE80211_BAND_5GHZ;
 		rate = IWL_RATE_6M_PLCP;
 		/*
-		 * If active scaning is requested but a certain channel
-		 * is marked passive, we can do active scanning if we
-		 * detect transmissions.
+		 * If active scanning is requested but a certain channel is
+		 * marked passive, we can do active scanning if we detect
+		 * transmissions.
+		 *
+		 * There is an issue with some firmware versions that triggers
+		 * a sysassert on a "good CRC threshold" of zero (== disabled),
+		 * on a radar channel even though this means that we should NOT
+		 * send probes.
+		 *
+		 * The "good CRC threshold" is the number of frames that we
+		 * need to receive during our dwell time on a channel before
+		 * sending out probes -- setting this to a huge value will
+		 * mean we never reach it, but at the same time work around
+		 * the aforementioned issue. Thus use IWL_GOOD_CRC_TH_NEVER
+		 * here instead of IWL_GOOD_CRC_TH_DISABLED.
 		 */
-		scan->good_CRC_th = is_active ? IWL_GOOD_CRC_TH : 0;
+		scan->good_CRC_th = is_active ? IWL_GOOD_CRC_TH_DEFAULT :
+						IWL_GOOD_CRC_TH_NEVER;
 
 		/* Force use of chains B and C (0x6) for scan Rx for 4965
 		 * Avoid A (0x1) because of its off-channel reception on A-band.
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index e276f2a..2f47d93 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -2966,7 +2966,8 @@ static void iwl3945_bg_request_scan(struct work_struct *data)
 		 * is marked passive, we can do active scanning if we
 		 * detect transmissions.
 		 */
-		scan->good_CRC_th = is_active ? IWL_GOOD_CRC_TH : 0;
+		scan->good_CRC_th = is_active ? IWL_GOOD_CRC_TH_DEFAULT :
+						IWL_GOOD_CRC_TH_DISABLED;
 		band = IEEE80211_BAND_5GHZ;
 	} else {
 		IWL_WARN(priv, "Invalid scan band count\n");
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 8a96503..6ccd48e 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -2029,7 +2029,8 @@ int ieee80211_mgd_deauth(struct ieee80211_sub_if_data *sdata,
 				continue;
 
 			if (wk->type != IEEE80211_WORK_DIRECT_PROBE &&
-			    wk->type != IEEE80211_WORK_AUTH)
+			    wk->type != IEEE80211_WORK_AUTH &&
+			    wk->type != IEEE80211_WORK_ASSOC)
 				continue;
 
 			if (memcmp(req->bss->bssid, wk->filter_ta, ETH_ALEN))
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
