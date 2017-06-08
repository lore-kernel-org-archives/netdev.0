From: Binoy Jayan <binoy.jayan@linaro.org>
Subject: [PATCH] mwifiex: Replace semaphore async_sem with mutex
Date: Thu,  8 Jun 2017 15:33:03 +0530
Message-ID: <1496916183-4097-1-git-send-email-binoy.jayan@linaro.org>
Cc: linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
        Rajendra <rnayak@codeaurora.org>,
        Mark Brown <broonie@kernel.org>,
        Amitkumar Karwar <amitkarwar@gmail.com>,
        Nishant Sarmukadam <nishants@marvell.com>,
        Ganapathi Bhat <gbhat@marvell.com>,
        Xinming Hu <huxm@marvell.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Binoy Jayan <binoy.jayan@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The semaphore 'async_sem' is used as a simple mutex, so
it should be written as one. Semaphores are going away in the future.

Signed-off-by: Binoy Jayan <binoy.jayan@linaro.org>
---

This patch is part of a bigger effort to eliminate unwanted
semaphores from the linux kernel.

 drivers/net/wireless/marvell/mwifiex/cfg80211.c | 2 +-
 drivers/net/wireless/marvell/mwifiex/main.h     | 2 +-
 drivers/net/wireless/marvell/mwifiex/scan.c     | 4 ++--
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/marvell/mwifiex/cfg80211.c b/drivers/net/wireless/marvell/mwifiex/cfg80211.c
index 7ec06bf..9e0d638 100644
--- a/drivers/net/wireless/marvell/mwifiex/cfg80211.c
+++ b/drivers/net/wireless/marvell/mwifiex/cfg80211.c
@@ -3059,7 +3059,7 @@ struct wireless_dev *mwifiex_add_virtual_intf(struct wiphy *wiphy,
 	INIT_DELAYED_WORK(&priv->dfs_chan_sw_work,
 			  mwifiex_dfs_chan_sw_work_queue);
 
-	sema_init(&priv->async_sem, 1);
+	mutex_init(&priv->async_mutex);
 
 	mwifiex_dbg(adapter, INFO,
 		    "info: %s: Marvell 802.11 Adapter\n", dev->name);
diff --git a/drivers/net/wireless/marvell/mwifiex/main.h b/drivers/net/wireless/marvell/mwifiex/main.h
index bb2a467..9c2cb33 100644
--- a/drivers/net/wireless/marvell/mwifiex/main.h
+++ b/drivers/net/wireless/marvell/mwifiex/main.h
@@ -628,7 +628,7 @@ struct mwifiex_private {
 	struct dentry *dfs_dev_dir;
 #endif
 	u16 current_key_index;
-	struct semaphore async_sem;
+	struct mutex async_mutex;
 	struct cfg80211_scan_request *scan_request;
 	u8 cfg_bssid[6];
 	struct wps wps;
diff --git a/drivers/net/wireless/marvell/mwifiex/scan.c b/drivers/net/wireless/marvell/mwifiex/scan.c
index ce6936d..ae9630b 100644
--- a/drivers/net/wireless/marvell/mwifiex/scan.c
+++ b/drivers/net/wireless/marvell/mwifiex/scan.c
@@ -2809,7 +2809,7 @@ int mwifiex_request_scan(struct mwifiex_private *priv,
 {
 	int ret;
 
-	if (down_interruptible(&priv->async_sem)) {
+	if (mutex_lock_interruptible(&priv->async_mutex)) {
 		mwifiex_dbg(priv->adapter, ERROR,
 			    "%s: acquire semaphore fail\n",
 			    __func__);
@@ -2825,7 +2825,7 @@ int mwifiex_request_scan(struct mwifiex_private *priv,
 		/* Normal scan */
 		ret = mwifiex_scan_networks(priv, NULL);
 
-	up(&priv->async_sem);
+	mutex_unlock(&priv->async_mutex);
 
 	return ret;
 }
-- 
Binoy Jayan
