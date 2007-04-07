From: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: [PATCH] zd1211rw-mac80211: rework band edge patching
Date: Sat,  7 Apr 2007 15:44:55 +0100 (BST)
Message-ID: <20070407144456.171A57B409F@zog.reactivated.net>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This change allows RF drivers to provide their own 6M band edge patching
implementation, while providing a generic implementation shared by most
currently supported RF's.

The upcoming ZD1211B/AL7230B code will use this to define its own
patching function, which is different from the other RF configurations.

Signed-off-by: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
---
 drivers/net/wireless/mac80211/zd1211rw/zd_chip.c   |   16 ++++++++++++----
 drivers/net/wireless/mac80211/zd1211rw/zd_chip.h   |    1 +
 drivers/net/wireless/mac80211/zd1211rw/zd_rf.c     |   14 ++++++++++++++
 drivers/net/wireless/mac80211/zd1211rw/zd_rf.h     |    9 ++++-----
 .../net/wireless/mac80211/zd1211rw/zd_rf_al2230.c  |    2 +-
 .../net/wireless/mac80211/zd1211rw/zd_rf_al7230b.c |    2 +-
 6 files changed, 33 insertions(+), 11 deletions(-)

diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_chip.c b/drivers/net/wireless/mac80211/zd1211rw/zd_chip.c
index 3b1cd65..303c38d 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_chip.c
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_chip.c
@@ -615,16 +615,24 @@ static int patch_cr157(struct zd_chip *chip)
  * Vendor driver says: for FCC regulation, enabled per HWFeature 6M band edge
  * bit (for AL2230, AL2230S)
  */
-static int patch_6m_band_edge(struct zd_chip *chip, int channel)
+static int patch_6m_band_edge(struct zd_chip *chip, u8 channel)
+{
+	ZD_ASSERT(mutex_is_locked(&chip->mutex));
+	if (!chip->patch_6m_band_edge)
+		return 0;
+
+	return zd_rf_patch_6m_band_edge(&chip->rf, channel);
+}
+
+/* Generic implementation of 6M band edge patching, used by most RFs via
+ * zd_rf_generic_patch_6m() */
+int zd_chip_generic_patch_6m_band(struct zd_chip *chip, int channel)
 {
 	struct zd_ioreq16 ioreqs[] = {
 		{ CR128, 0x14 }, { CR129, 0x12 }, { CR130, 0x10 },
 		{ CR47,  0x1e },
 	};
 
-	if (!chip->patch_6m_band_edge || !chip->rf.patch_6m_band_edge)
-		return 0;
-
 	/* FIXME: Channel 11 is not the edge for all regulatory domains. */
 	if (channel == 1 || channel == 11)
 		ioreqs[0].value = 0x12;
diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_chip.h b/drivers/net/wireless/mac80211/zd1211rw/zd_chip.h
index 0a8f0e5..584b1c8 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_chip.h
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_chip.h
@@ -828,6 +828,7 @@ int zd_chip_enable_rx(struct zd_chip *chip);
 void zd_chip_disable_rx(struct zd_chip *chip);
 int zd_chip_enable_hwint(struct zd_chip *chip);
 int zd_chip_disable_hwint(struct zd_chip *chip);
+int zd_chip_generic_patch_6m_band(struct zd_chip *chip, int channel);
 
 static inline int zd_get_encryption_type(struct zd_chip *chip, u32 *type)
 {
diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_rf.c b/drivers/net/wireless/mac80211/zd1211rw/zd_rf.c
index 9af8c16..7407409 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_rf.c
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_rf.c
@@ -161,3 +161,17 @@ int zd_switch_radio_off(struct zd_rf *rf)
 		r = t;
 	return r;
 }
+
+int zd_rf_patch_6m_band_edge(struct zd_rf *rf, u8 channel)
+{
+	if (!rf->patch_6m_band_edge)
+		return 0;
+
+	return rf->patch_6m_band_edge(rf, channel);
+}
+
+int zd_rf_generic_patch_6m(struct zd_rf *rf, u8 channel)
+{
+	return zd_chip_generic_patch_6m_band(zd_rf_to_chip(rf), channel);
+}
+
diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_rf.h b/drivers/net/wireless/mac80211/zd1211rw/zd_rf.h
index 1110724..a05186b 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_rf.h
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_rf.h
@@ -47,11 +47,6 @@ struct zd_rf {
 	u8 type;
 
 	u8 channel;
-	/*
-	 * Whether this RF should patch the 6M band edge
-	 * (assuming E2P_POD agrees)
-	 */
-	u8 patch_6m_band_edge:1;
 
 	/* whether channel integration and calibration should be updated
 	 * defaults to 1 (yes) */
@@ -66,6 +61,7 @@ struct zd_rf {
 	int (*switch_radio_on)(struct zd_rf *rf);
 	int (*switch_radio_off)(struct zd_rf *rf);
 	void (*clear)(struct zd_rf *rf);
+	int (*patch_6m_band_edge)(struct zd_rf *rf, u8 channel);
 };
 
 const char *zd_rf_name(u8 type);
@@ -85,6 +81,9 @@ static inline int zd_rf_should_update_pwr_int(struct zd_rf *rf)
 	return rf->update_channel_int;
 }
 
+int zd_rf_patch_6m_band_edge(struct zd_rf *rf, u8 channel);
+int zd_rf_generic_patch_6m(struct zd_rf *rf, u8 channel);
+
 /* Functions for individual RF chips */
 
 int zd_rf_init_rf2959(struct zd_rf *rf);
diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_rf_al2230.c b/drivers/net/wireless/mac80211/zd1211rw/zd_rf_al2230.c
index 85a9ad2..511392a 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_rf_al2230.c
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_rf_al2230.c
@@ -431,6 +431,6 @@ int zd_rf_init_al2230(struct zd_rf *rf)
 		rf->set_channel = zd1211_al2230_set_channel;
 		rf->switch_radio_on = zd1211_al2230_switch_radio_on;
 	}
-	rf->patch_6m_band_edge = 1;
+	rf->patch_6m_band_edge = zd_rf_generic_patch_6m;
 	return 0;
 }
diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_rf_al7230b.c b/drivers/net/wireless/mac80211/zd1211rw/zd_rf_al7230b.c
index bd07c9b..d2c3ee6 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_rf_al7230b.c
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_rf_al7230b.c
@@ -269,6 +269,6 @@ int zd_rf_init_al7230b(struct zd_rf *rf)
 	rf->set_channel = al7230b_set_channel;
 	rf->switch_radio_on = al7230b_switch_radio_on;
 	rf->switch_radio_off = al7230b_switch_radio_off;
-	rf->patch_6m_band_edge = 1;
+	rf->patch_6m_band_edge = zd_rf_generic_patch_6m;
 	return 0;
 }
-- 
1.5.1
