From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2010-09-01
Date: Wed, 1 Sep 2010 14:17:11 -0400
Message-ID: <20100901181711.GG2486@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:54668 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751383Ab0IAS3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 14:29:40 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

This batch of fixes is intended for 2.6.36.

Included is a libertas fix for an alignment error introduced by a change
introduced through another tree during the merge window, an ath5k fix to
avoid a NULL pointer dereference when the rate control fails to give it
a usable transmission rate (which is another bug), a p54 fix to avoid
false transmission failure reports (which prevent power saving), a
fix for a mac80211 timer leak, a MAINTAINERS fix for a broken URL, a
wireless extension fix to plug an information leak, a fix for a lockdep
warning when cfg80211 registers its rfkill device, and a couple of ath9k
fixes related to regulatory compliance.

Please let me know if there are problems!

John

---

The following changes since commit b963ea89f00f13c648af4082e5efb2172d369727:

  netlink: Make NETLINK_USERSOCK work again. (2010-08-31 09:51:37 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Christian Lamparter (1):
      p54: fix tx feedback status flag check

Johannes Berg (2):
      mac80211: delete work timer
      wireless extensions: fix kernel heap content leak

John W. Linville (3):
      ath5k: check return value of ieee80211_get_tx_rate
      MAINTAINERS: change broken url for prism54
      wireless: register wiphy rfkill w/o holding cfg80211_mutex

Luis R. Rodriguez (2):
      ath9k_hw: Fix EEPROM uncompress block reading on AR9003
      ath9k_hw: fix parsing of HT40 5 GHz CTLs

Mike Rapoport (1):
      libertas: if_sdio: fix buffer alignment in struct if_sdio_card

 MAINTAINERS                                    |    2 +-
 drivers/net/wireless/ath/ath5k/base.c          |    4 ++++
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c |    2 +-
 drivers/net/wireless/ath/ath9k/eeprom.h        |    2 +-
 drivers/net/wireless/ath/regd.h                |    1 -
 drivers/net/wireless/libertas/if_sdio.c        |    2 +-
 drivers/net/wireless/p54/txrx.c                |    2 +-
 net/mac80211/main.c                            |    6 ++++++
 net/wireless/core.c                            |   21 ++++++++++++---------
 net/wireless/wext-compat.c                     |    3 +++
 net/wireless/wext-core.c                       |   16 ++++++++++++++++
 11 files changed, 46 insertions(+), 15 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 44620ae..8e85429 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4549,7 +4549,7 @@ F:	include/linux/preempt.h
 PRISM54 WIRELESS DRIVER
 M:	"Luis R. Rodriguez" <mcgrof@gmail.com>
 L:	linux-wireless@vger.kernel.org
-W:	http://prism54.org
+W:	http://wireless.kernel.org/en/users/Drivers/p54
 S:	Obsolete
 F:	drivers/net/wireless/prism54/
 
diff --git a/drivers/net/wireless/ath/ath5k/base.c b/drivers/net/wireless/ath/ath5k/base.c
index 373dcfe..d77ce99 100644
--- a/drivers/net/wireless/ath/ath5k/base.c
+++ b/drivers/net/wireless/ath/ath5k/base.c
@@ -1327,6 +1327,10 @@ ath5k_txbuf_setup(struct ath5k_softc *sc, struct ath5k_buf *bf,
 			PCI_DMA_TODEVICE);
 
 	rate = ieee80211_get_tx_rate(sc->hw, info);
+	if (!rate) {
+		ret = -EINVAL;
+		goto err_unmap;
+	}
 
 	if (info->flags & IEEE80211_TX_CTL_NO_ACK)
 		flags |= AR5K_TXDESC_NOACK;
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c b/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
index b883b17..057fb69 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
@@ -797,7 +797,7 @@ static bool ar9300_uncompress_block(struct ath_hw *ah,
 		length = block[it+1];
 		length &= 0xff;
 
-		if (length > 0 && spot >= 0 && spot+length < mdataSize) {
+		if (length > 0 && spot >= 0 && spot+length <= mdataSize) {
 			ath_print(common, ATH_DBG_EEPROM,
 				  "Restore at %d: spot=%d "
 				  "offset=%d length=%d\n",
diff --git a/drivers/net/wireless/ath/ath9k/eeprom.h b/drivers/net/wireless/ath/ath9k/eeprom.h
index 7f48df1..0b09db0 100644
--- a/drivers/net/wireless/ath/ath9k/eeprom.h
+++ b/drivers/net/wireless/ath/ath9k/eeprom.h
@@ -62,7 +62,7 @@
 
 #define SD_NO_CTL               0xE0
 #define NO_CTL                  0xff
-#define CTL_MODE_M              7
+#define CTL_MODE_M              0xf
 #define CTL_11A                 0
 #define CTL_11B                 1
 #define CTL_11G                 2
diff --git a/drivers/net/wireless/ath/regd.h b/drivers/net/wireless/ath/regd.h
index a1c3952..345dd97 100644
--- a/drivers/net/wireless/ath/regd.h
+++ b/drivers/net/wireless/ath/regd.h
@@ -31,7 +31,6 @@ enum ctl_group {
 #define NO_CTL 0xff
 #define SD_NO_CTL               0xE0
 #define NO_CTL                  0xff
-#define CTL_MODE_M              7
 #define CTL_11A                 0
 #define CTL_11B                 1
 #define CTL_11G                 2
diff --git a/drivers/net/wireless/libertas/if_sdio.c b/drivers/net/wireless/libertas/if_sdio.c
index 6e71346..382f237 100644
--- a/drivers/net/wireless/libertas/if_sdio.c
+++ b/drivers/net/wireless/libertas/if_sdio.c
@@ -126,7 +126,7 @@ struct if_sdio_card {
 	const char		*helper;
 	const char		*firmware;
 
-	u8			buffer[65536];
+	u8			buffer[65536] __attribute__((aligned(4)));
 
 	spinlock_t		lock;
 	struct if_sdio_packet	*packets;
diff --git a/drivers/net/wireless/p54/txrx.c b/drivers/net/wireless/p54/txrx.c
index 173aec3..0e937dc 100644
--- a/drivers/net/wireless/p54/txrx.c
+++ b/drivers/net/wireless/p54/txrx.c
@@ -446,7 +446,7 @@ static void p54_rx_frame_sent(struct p54_common *priv, struct sk_buff *skb)
 	}
 
 	if (!(info->flags & IEEE80211_TX_CTL_NO_ACK) &&
-	     (!payload->status))
+	     !(payload->status & P54_TX_FAILED))
 		info->flags |= IEEE80211_TX_STAT_ACK;
 	if (payload->status & P54_TX_PSM_CANCELLED)
 		info->flags |= IEEE80211_TX_STAT_TX_FILTERED;
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index 798a91b..ded5c38 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -732,6 +732,12 @@ void ieee80211_unregister_hw(struct ieee80211_hw *hw)
 
 	rtnl_unlock();
 
+	/*
+	 * Now all work items will be gone, but the
+	 * timer might still be armed, so delete it
+	 */
+	del_timer_sync(&local->work_timer);
+
 	cancel_work_sync(&local->reconfig_filter);
 
 	ieee80211_clear_tx_pending(local);
diff --git a/net/wireless/core.c b/net/wireless/core.c
index 541e2ff..d6d046b 100644
--- a/net/wireless/core.c
+++ b/net/wireless/core.c
@@ -475,12 +475,10 @@ int wiphy_register(struct wiphy *wiphy)
 	mutex_lock(&cfg80211_mutex);
 
 	res = device_add(&rdev->wiphy.dev);
-	if (res)
-		goto out_unlock;
-
-	res = rfkill_register(rdev->rfkill);
-	if (res)
-		goto out_rm_dev;
+	if (res) {
+		mutex_unlock(&cfg80211_mutex);
+		return res;
+	}
 
 	/* set up regulatory info */
 	wiphy_update_regulatory(wiphy, NL80211_REGDOM_SET_BY_CORE);
@@ -509,13 +507,18 @@ int wiphy_register(struct wiphy *wiphy)
 	cfg80211_debugfs_rdev_add(rdev);
 	mutex_unlock(&cfg80211_mutex);
 
+	/*
+	 * due to a locking dependency this has to be outside of the
+	 * cfg80211_mutex lock
+	 */
+	res = rfkill_register(rdev->rfkill);
+	if (res)
+		goto out_rm_dev;
+
 	return 0;
 
 out_rm_dev:
 	device_del(&rdev->wiphy.dev);
-
-out_unlock:
-	mutex_unlock(&cfg80211_mutex);
 	return res;
 }
 EXPORT_SYMBOL(wiphy_register);
diff --git a/net/wireless/wext-compat.c b/net/wireless/wext-compat.c
index bb5e0a5..7e5c3a4 100644
--- a/net/wireless/wext-compat.c
+++ b/net/wireless/wext-compat.c
@@ -1420,6 +1420,9 @@ int cfg80211_wext_giwessid(struct net_device *dev,
 {
 	struct wireless_dev *wdev = dev->ieee80211_ptr;
 
+	data->flags = 0;
+	data->length = 0;
+
 	switch (wdev->iftype) {
 	case NL80211_IFTYPE_ADHOC:
 		return cfg80211_ibss_wext_giwessid(dev, info, data, ssid);
diff --git a/net/wireless/wext-core.c b/net/wireless/wext-core.c
index 0ef17bc..8f5116f 100644
--- a/net/wireless/wext-core.c
+++ b/net/wireless/wext-core.c
@@ -782,6 +782,22 @@ static int ioctl_standard_iw_point(struct iw_point *iwp, unsigned int cmd,
 		}
 	}
 
+	if (IW_IS_GET(cmd) && !(descr->flags & IW_DESCR_FLAG_NOMAX)) {
+		/*
+		 * If this is a GET, but not NOMAX, it means that the extra
+		 * data is not bounded by userspace, but by max_tokens. Thus
+		 * set the length to max_tokens. This matches the extra data
+		 * allocation.
+		 * The driver should fill it with the number of tokens it
+		 * provided, and it may check iwp->length rather than having
+		 * knowledge of max_tokens. If the driver doesn't change the
+		 * iwp->length, this ioctl just copies back max_token tokens
+		 * filled with zeroes. Hopefully the driver isn't claiming
+		 * them to be valid data.
+		 */
+		iwp->length = descr->max_tokens;
+	}
+
 	err = handler(dev, info, (union iwreq_data *) iwp, extra);
 
 	iwp->length += essid_compat;
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
