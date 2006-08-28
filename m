From: Hong Liu <hong.liu@intel.com>
Subject: [PATCH]d80211: fix "iwconfig key [x]" behavior
Date: Mon, 28 Aug 2006 16:36:39 +0800
Message-ID: <1156754199.6061.3.camel@devlinux-hong>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-9mZho/VNcAIp2Etg2iPO"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:13957 "EHLO
	orsmga102-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S1751296AbWH1Ikq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Aug 2006 04:40:46 -0400
To: jbenc@suse.cz
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-9mZho/VNcAIp2Etg2iPO
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

"iwconfig key [x]" behavior is not correctly handled in the stack, also
modify the giwencode method to show the key info.

Thanks,
Hong

--=-9mZho/VNcAIp2Etg2iPO
Content-Disposition: attachment; filename=d80211-fix-iwconfig-key.patch
Content-Type: text/x-patch; name=d80211-fix-iwconfig-key.patch; charset=UTF-8
Content-Transfer-Encoding: 7bit

[PATCH]d80211: fix "iwconfig key [x]" behavior

Signed-off-by: Hong Liu <hong.liu@intel.com>

diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index dd52555..d3dc59c 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -2811,9 +2811,10 @@ static int ieee80211_ioctl_siwencode(str
 		if (sdata->default_key == NULL)
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
@@ -2824,16 +2825,22 @@ static int ieee80211_ioctl_siwencode(str
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
 		sdata->default_key == NULL,
 		NULL, keybuf, erq->length);
 
-	return 0;
 }
 
 
@@ -2852,9 +2859,10 @@ static int ieee80211_ioctl_giwencode(str
 		if (sdata->default_key == NULL)
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
@@ -2869,7 +2877,8 @@ static int ieee80211_ioctl_giwencode(str
 		return 0;
 	}
 
-	erq->length = 0;
+	erq->length = sdata->keys[idx]->keylen;
+	memcpy(key, sdata->keys[idx]->key, erq->length);
 	erq->flags |= IW_ENCODE_ENABLED;
 
 	return 0;

--=-9mZho/VNcAIp2Etg2iPO--
