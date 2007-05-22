From: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: [PATCH] zd1211rw-mac80211: Extend RF layer
Date: Tue, 22 May 2007 01:00:29 +0100 (BST)
Message-ID: <20070522000030.19D897B409F@zog.reactivated.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

These changes are needed for UW2453 RF support:

Add pointer which RF drivers can use to store private RF data
Add exit hook so that RF drivers can free private data
Allow RF's to disable the generic TX power integration handling code

Signed-off-by: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
---
 drivers/net/wireless/mac80211/zd1211rw/zd_chip.c |    3 +++
 drivers/net/wireless/mac80211/zd1211rw/zd_rf.c   |    6 ++++++
 drivers/net/wireless/mac80211/zd1211rw/zd_rf.h   |   13 +++++++++++++
 3 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_chip.c b/drivers/net/wireless/mac80211/zd1211rw/zd_chip.c
index 8dc8f88..4078fbe 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_chip.c
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_chip.c
@@ -1228,6 +1228,9 @@ static int update_channel_integration_and_calibration(struct zd_chip *chip,
 {
 	int r;
 
+	if (!zd_rf_should_update_pwr_int(&chip->rf))
+		return 0;
+
 	r = update_pwr_int(chip, channel);
 	if (r)
 		return r;
diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_rf.c b/drivers/net/wireless/mac80211/zd1211rw/zd_rf.c
index 549c23b..c4981ad 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_rf.c
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_rf.c
@@ -52,10 +52,16 @@ const char *zd_rf_name(u8 type)
 void zd_rf_init(struct zd_rf *rf)
 {
 	memset(rf, 0, sizeof(*rf));
+
+	/* default to update channel integration, as almost all RF's do want
+	 * this */
+	rf->update_channel_int = 1;
 }
 
 void zd_rf_clear(struct zd_rf *rf)
 {
+	if (rf->clear)
+		rf->clear(rf);
 	ZD_MEMCLEAR(rf, sizeof(*rf));
 }
 
diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_rf.h b/drivers/net/wireless/mac80211/zd1211rw/zd_rf.h
index aa9cc10..c204f9a 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_rf.h
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_rf.h
@@ -48,12 +48,20 @@ struct zd_rf {
 
 	u8 channel;
 
+	/* whether channel integration and calibration should be updated
+	 * defaults to 1 (yes) */
+	u8 update_channel_int:1;
+
+	/* private RF driver data */
+	void *priv;
+
 	/* RF-specific functions */
 	int (*init_hw)(struct zd_rf *rf);
 	int (*set_channel)(struct zd_rf *rf, u8 channel);
 	int (*switch_radio_on)(struct zd_rf *rf);
 	int (*switch_radio_off)(struct zd_rf *rf);
 	int (*patch_6m_band_edge)(struct zd_rf *rf, u8 channel);
+	void (*clear)(struct zd_rf *rf);
 };
 
 const char *zd_rf_name(u8 type);
@@ -71,6 +79,11 @@ int zd_switch_radio_off(struct zd_rf *rf);
 int zd_rf_patch_6m_band_edge(struct zd_rf *rf, u8 channel);
 int zd_rf_generic_patch_6m(struct zd_rf *rf, u8 channel);
 
+static inline int zd_rf_should_update_pwr_int(struct zd_rf *rf)
+{
+	return rf->update_channel_int;
+}
+
 /* Functions for individual RF chips */
 
 int zd_rf_init_rf2959(struct zd_rf *rf);
-- 
1.5.2
