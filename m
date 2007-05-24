From: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: [PATCH] zd1211rw: Make CCK gain patching conditional on RF type
Date: Thu, 24 May 2007 01:07:15 +0100 (BST)
Message-ID: <20070524000719.A0EC07B409F@zog.reactivated.net>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The vendor driver code suggests that CR47 patching happens on every channel
change for every RF (depending on bit 8 in POD).

Due to a bug in their driver (upper bits of RF_Mode get zeroed out, then
are examined for 1s when setting some other flags), this isn't actually
what happens, and their generic CCK patching routine never takes effect.

Some of their RF configurations do include explicit (duplicated) code
for CR47 patching though. This patch makes zd1211rw match that
behaviour.

Signed-off-by: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
---
 zd_chip.c       |    2 +-
 zd_rf.h         |   14 ++++++++++++++
 zd_rf_al2230.c  |    1 +
 zd_rf_al7230b.c |    1 +
 4 files changed, 17 insertions(+), 1 deletions(-)

Index: linux/drivers/net/wireless/zd1211rw/zd_chip.c
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_chip.c
+++ linux/drivers/net/wireless/zd1211rw/zd_chip.c
@@ -1286,7 +1286,7 @@ static int patch_cck_gain(struct zd_chip
 	int r;
 	u32 value;
 
-	if (!chip->patch_cck_gain)
+	if (!chip->patch_cck_gain || !zd_rf_should_patch_cck_gain(&chip->rf))
 		return 0;
 
 	ZD_ASSERT(mutex_is_locked(&chip->mutex));
Index: linux/drivers/net/wireless/zd1211rw/zd_rf.h
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_rf.h
+++ linux/drivers/net/wireless/zd1211rw/zd_rf.h
@@ -52,6 +52,12 @@ struct zd_rf {
 	 * defaults to 1 (yes) */
 	u8 update_channel_int:1;
 
+	/* whether CR47 should be patched from the EEPROM, if the appropriate
+	 * flag is set in the POD. The vendor driver suggests that this should
+	 * be done for all RF's, but a bug in their code prevents but their 
+	 * HW_OverWritePhyRegFromE2P() routine from ever taking effect. */
+	u8 patch_cck_gain:1;
+
 	/* private RF driver data */
 	void *priv;
 
@@ -84,6 +90,14 @@ static inline int zd_rf_should_update_pw
 	return rf->update_channel_int;
 }
 
+static inline int zd_rf_should_patch_cck_gain(struct zd_rf *rf)
+{
+	return rf->patch_cck_gain;
+}
+
+int zd_rf_patch_6m_band_edge(struct zd_rf *rf, u8 channel);
+int zd_rf_generic_patch_6m(struct zd_rf *rf, u8 channel);
+
 /* Functions for individual RF chips */
 
 int zd_rf_init_rf2959(struct zd_rf *rf);
Index: linux/drivers/net/wireless/zd1211rw/zd_rf_al2230.c
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_rf_al2230.c
+++ linux/drivers/net/wireless/zd1211rw/zd_rf_al2230.c
@@ -432,5 +432,6 @@ int zd_rf_init_al2230(struct zd_rf *rf)
 		rf->switch_radio_on = zd1211_al2230_switch_radio_on;
 	}
 	rf->patch_6m_band_edge = zd_rf_generic_patch_6m;
+	rf->patch_cck_gain = 1;
 	return 0;
 }
Index: linux/drivers/net/wireless/zd1211rw/zd_rf_al7230b.c
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_rf_al7230b.c
+++ linux/drivers/net/wireless/zd1211rw/zd_rf_al7230b.c
@@ -483,6 +483,7 @@ int zd_rf_init_al7230b(struct zd_rf *rf)
 		rf->switch_radio_on = zd1211_al7230b_switch_radio_on;
 		rf->set_channel = zd1211_al7230b_set_channel;
 		rf->patch_6m_band_edge = zd_rf_generic_patch_6m;
+		rf->patch_cck_gain = 1;
 	}
 
 	rf->switch_radio_off = al7230b_switch_radio_off;
