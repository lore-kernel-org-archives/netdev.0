From: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: [PATCH] zd1211rw: Extend RF layer
Date: Thu, 24 May 2007 01:06:41 +0100 (BST)
Message-ID: <20070524000641.3DE757B409F@zog.reactivated.net>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

These changes are needed for UW2453 RF support:

Add pointer which RF drivers can use to store private RF data
Add exit hook so that RF drivers can free private data
Allow RF's to disable the generic TX power integration handling code

Signed-off-by: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
---
 zd_chip.c |    3 +++
 zd_rf.c   |    6 ++++++
 zd_rf.h   |   13 +++++++++++++
 3 files changed, 22 insertions(+), 0 deletions(-)

Index: linux/drivers/net/wireless/zd1211rw/zd_chip.c
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_chip.c
+++ linux/drivers/net/wireless/zd1211rw/zd_chip.c
@@ -1253,6 +1253,9 @@ static int update_channel_integration_an
 {
 	int r;
 
+	if (!zd_rf_should_update_pwr_int(&chip->rf))
+		return 0;
+
 	r = update_pwr_int(chip, channel);
 	if (r)
 		return r;
Index: linux/drivers/net/wireless/zd1211rw/zd_rf.c
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_rf.c
+++ linux/drivers/net/wireless/zd1211rw/zd_rf.c
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
 
Index: linux/drivers/net/wireless/zd1211rw/zd_rf.h
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_rf.h
+++ linux/drivers/net/wireless/zd1211rw/zd_rf.h
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
@@ -71,6 +79,11 @@ int zd_switch_radio_off(struct zd_rf *rf
 int zd_rf_patch_6m_band_edge(struct zd_rf *rf, u8 channel);
 int zd_rf_generic_patch_6m(struct zd_rf *rf, u8 channel);
 
+static inline int zd_rf_should_update_pwr_int(struct zd_rf *rf)
+{
+	return rf->update_channel_int;
+}
+
 /* Functions for individual RF chips */
 
 int zd_rf_init_rf2959(struct zd_rf *rf);
