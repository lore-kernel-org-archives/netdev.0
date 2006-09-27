From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 10/14] d80211: fix "iwconfig key [x]" behavior
Date: Wed, 27 Sep 2006 17:50:55 +0200 (CEST)
Message-ID: <20060927155055.1C5323BA254@silver.suse.cz>
References: <20060927175006.637430015.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:50828 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S964983AbWI0Ptu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 11:49:50 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060927175006.637430015.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hong Liu <hong.liu@intel.com>

"iwconfig key [x]" behavior is not correctly handled in the stack, also
modify the giwencode method to show the key info.

Signed-off-by: Hong Liu <hong.liu@intel.com>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211_ioctl.c |   32 +++++++++++++++++++++-----------
 1 files changed, 21 insertions(+), 11 deletions(-)

ad8c3766f67df906ff45143d393c924ad7297471
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index 34fdf40..b47a014 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -2867,9 +2867,10 @@ static int ieee80211_ioctl_siwencode(str
 		if (!sdata->default_key)
 			idx = 0;
 		else for (i = 0; i < NUM_DEFAULT_KEYS; i++) {
-			if (sdata->default_key == sdata->keys[i])
+			if (sdata->default_key == sdata->keys[i]) {
 				idx = i;
-			break;
+				break;
+			}
 		}
 		if (idx < 0)
 			return -EINVAL;
@@ -2880,16 +2881,21 @@ static int ieee80211_ioctl_siwencode(str
 		alg = ALG_NONE;
 	else if (erq->length == 0) {
 		/* No key data - just set the default TX key index */
-		sdata->default_key = sdata->keys[idx];
+		if (sdata->default_key != sdata->keys[idx]) {
+			if (sdata->default_key)
+				ieee80211_key_sysfs_remove_default(sdata);
+			sdata->default_key = sdata->keys[idx];
+			if (sdata->default_key)
+				ieee80211_key_sysfs_add_default(sdata);
+		}
+		return 0;
 	}
 
 	return ieee80211_set_encryption(
 		dev, bcaddr,
-		idx, erq->length == 0 ? ALG_NONE : ALG_WEP,
+		idx, alg,
 		!sdata->default_key,
 		NULL, keybuf, erq->length);
-
-	return 0;
 }
 
 
@@ -2908,9 +2914,10 @@ static int ieee80211_ioctl_giwencode(str
 		if (!sdata->default_key)
 			idx = 0;
 		else for (i = 0; i < NUM_DEFAULT_KEYS; i++) {
-			if (sdata->default_key == sdata->keys[i])
+			if (sdata->default_key == sdata->keys[i]) {
 				idx = i;
-			break;
+				break;
+			}
 		}
 		if (idx < 0)
 			return -EINVAL;
@@ -2925,7 +2932,9 @@ static int ieee80211_ioctl_giwencode(str
 		return 0;
 	}
 
-	erq->length = 0;
+	memcpy(key, sdata->keys[idx]->key,
+	       min((int)erq->length, sdata->keys[idx]->keylen));
+	erq->length = sdata->keys[idx]->keylen;
 	erq->flags |= IW_ENCODE_ENABLED;
 
 	return 0;
@@ -3054,9 +3063,10 @@ static int ieee80211_ioctl_siwencodeext(
 		if (!sdata->default_key)
 			idx = 0;
 		else for (i = 0; i < NUM_DEFAULT_KEYS; i++) {
-			if (sdata->default_key == sdata->keys[i])
+			if (sdata->default_key == sdata->keys[i]) {
 				idx = i;
-			break;
+				break;
+			}
 		}
 		if (idx < 0)
 			return -EINVAL;
-- 
1.3.0

