From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw-mac80211: Make CCK gain patching conditional on RF type
Date: Tue, 22 May 2007 01:03:54 +0100 (BST)
Message-ID: <20070522000355.469E07B409F@zog.reactivated.net>
Cc: linux-wireless@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout02-winn.ispmail.ntl.com ([81.103.221.48]:33930 "EHLO
	mtaout02-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756542AbXEVADv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2007 20:03:51 -0400
Cc: netdev@vger.kernel.org
Cc: kune@deine-taler.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The vendor driver code suggests that CR47 patching happens on every channel
change for every RF (depending on bit 8 in POD).

Due to a bug in their driver (upper bits of RF_Mode get zeroed out, then
are examined for 1s when setting some other flags), this isn't actually
what happens, and their generic CCK patching routine never takes effect.

Some of their RF configurations do include explicit (duplicated) code
for CR47 patching though. This patch makes zd1211rw match that
behaviour.

Signed-off-by: Daniel Drake <dsd@gentoo.org>
---
 drivers/net/wireless/mac80211/zd1211rw/zd_chip.c   |    2 +-
 drivers/net/wireless/mac80211/zd1211rw/zd_rf.h     |   14 ++++++++++++++
 .../net/wireless/mac80211/zd1211rw/zd_rf_al2230.c  |    1 +
 .../net/wireless/mac80211/zd1211rw/zd_rf_al7230b.c |    1 +
 4 files changed, 17 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_chip.c b/drivers/net/wireless/mac80211/zd1211rw/zd_chip.c
index 4078fbe..fcf78ab 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_chip.c
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_chip.c
@@ -1261,7 +1261,7 @@ static int patch_cck_gain(struct zd_chip *chip)
 	int r;
 	u32 value;
 
-	if (!chip->patch_cck_gain)
+	if (!chip->patch_cck_gain || !zd_rf_should_patch_cck_gain(&chip->rf))
 		return 0;
 
 	ZD_ASSERT(mutex_is_locked(&chip->mutex));
diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_rf.h b/drivers/net/wireless/mac80211/zd1211rw/zd_rf.h
index 6dced2a..44c46e2 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_rf.h
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_rf.h
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
 
@@ -84,6 +90,14 @@ static inline int zd_rf_should_update_pwr_int(struct zd_rf *rf)
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
diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_rf_al2230.c b/drivers/net/wireless/mac80211/zd1211rw/zd_rf_al2230.c
index 511392a..e7a4ecf 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_rf_al2230.c
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_rf_al2230.c
@@ -432,5 +432,6 @@ int zd_rf_init_al2230(struct zd_rf *rf)
 		rf->switch_radio_on = zd1211_al2230_switch_radio_on;
 	}
 	rf->patch_6m_band_edge = zd_rf_generic_patch_6m;
+	rf->patch_cck_gain = 1;
 	return 0;
 }
diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_rf_al7230b.c b/drivers/net/wireless/mac80211/zd1211rw/zd_rf_al7230b.c
index 5e5e9dd..f4e8b6a 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_rf_al7230b.c
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_rf_al7230b.c
@@ -483,6 +483,7 @@ int zd_rf_init_al7230b(struct zd_rf *rf)
 		rf->switch_radio_on = zd1211_al7230b_switch_radio_on;
 		rf->set_channel = zd1211_al7230b_set_channel;
 		rf->patch_6m_band_edge = zd_rf_generic_patch_6m;
+		rf->patch_cck_gain = 1;
 	}
 
 	rf->switch_radio_off = al7230b_switch_radio_off;
-- 
1.5.2

