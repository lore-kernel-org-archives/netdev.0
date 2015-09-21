From: Ondrej Zary <linux@rainbow-software.org>
Subject: [PATCH v3 1/2] airo: fix IW_AUTH_ALG_OPEN_SYSTEM
Date: Mon, 21 Sep 2015 15:44:24 +0200
Message-ID: <1442843065-30234-1-git-send-email-linux@rainbow-software.org>
Cc: Dan Williams <dcbw@redhat.com>, netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.gsystem.sk ([62.176.172.50]:49965 "EHLO gsystem.sk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753417AbbIUNom (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Sep 2015 09:44:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IW_AUTH_ALG_OPEN_SYSTEM is ambiguous in set_auth for WEP as
wpa_supplicant uses it for both no encryption and WEP open system.
Cache the last mode set (only of these two) and use it here.

This allows wpa_supplicant to work with unencrypted APs.

Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
---
 drivers/net/wireless/airo.c |   59 +++++++++++++++++++++++++------------------
 1 file changed, 35 insertions(+), 24 deletions(-)

diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index d0c97c2..67001a8 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -1237,6 +1237,7 @@ struct airo_info {
 
 	int			wep_capable;
 	int			max_wep_idx;
+	int			last_auth;
 
 	/* WPA-related stuff */
 	unsigned int bssListFirst;
@@ -3786,6 +3787,16 @@ badrx:
 	}
 }
 
+static inline void set_auth_type(struct airo_info *local, int auth_type)
+{
+	local->config.authType = auth_type;
+	/* Cache the last auth type used (of AUTH_OPEN and AUTH_ENCRYPT).
+	 * Used by airo_set_auth()
+	 */
+	if (auth_type == AUTH_OPEN || auth_type == AUTH_ENCRYPT)
+		local->last_auth = auth_type;
+}
+
 static u16 setup_card(struct airo_info *ai, u8 *mac, int lock)
 {
 	Cmd cmd;
@@ -3862,7 +3873,7 @@ static u16 setup_card(struct airo_info *ai, u8 *mac, int lock)
 						"level scale");
 		}
 		ai->config.opmode = adhoc ? MODE_STA_IBSS : MODE_STA_ESS;
-		ai->config.authType = AUTH_OPEN;
+		set_auth_type(ai, AUTH_OPEN);
 		ai->config.modulation = MOD_CCK;
 
 		if (le16_to_cpu(cap_rid.len) >= sizeof(cap_rid) &&
@@ -4880,13 +4891,13 @@ static void proc_config_on_close(struct inode *inode, struct file *file)
 			line += 5;
 			switch( line[0] ) {
 			case 's':
-				ai->config.authType = AUTH_SHAREDKEY;
+				set_auth_type(ai, AUTH_SHAREDKEY);
 				break;
 			case 'e':
-				ai->config.authType = AUTH_ENCRYPT;
+				set_auth_type(ai, AUTH_ENCRYPT);
 				break;
 			default:
-				ai->config.authType = AUTH_OPEN;
+				set_auth_type(ai, AUTH_OPEN);
 				break;
 			}
 			set_bit (FLAG_COMMIT, &ai->flags);
@@ -6368,9 +6379,8 @@ static int airo_set_encode(struct net_device *dev,
 		 * should be enabled (user may turn it off later)
 		 * This is also how "iwconfig ethX key on" works */
 		if((index == current_index) && (key.len > 0) &&
-		   (local->config.authType == AUTH_OPEN)) {
-			local->config.authType = AUTH_ENCRYPT;
-		}
+		   (local->config.authType == AUTH_OPEN))
+			set_auth_type(local, AUTH_ENCRYPT);
 	} else {
 		/* Do we want to just set the transmit key index ? */
 		int index = (dwrq->flags & IW_ENCODE_INDEX) - 1;
@@ -6389,12 +6399,12 @@ static int airo_set_encode(struct net_device *dev,
 		}
 	}
 	/* Read the flags */
-	if(dwrq->flags & IW_ENCODE_DISABLED)
-		local->config.authType = AUTH_OPEN;	// disable encryption
+	if (dwrq->flags & IW_ENCODE_DISABLED)
+		set_auth_type(local, AUTH_OPEN);	/* disable encryption */
 	if(dwrq->flags & IW_ENCODE_RESTRICTED)
-		local->config.authType = AUTH_SHAREDKEY;	// Only Both
-	if(dwrq->flags & IW_ENCODE_OPEN)
-		local->config.authType = AUTH_ENCRYPT;	// Only Wep
+		set_auth_type(local, AUTH_SHAREDKEY);	/* Only Both */
+	if (dwrq->flags & IW_ENCODE_OPEN)
+		set_auth_type(local, AUTH_ENCRYPT);	/* Only Wep */
 	/* Commit the changes to flags if needed */
 	if (local->config.authType != currentAuthType)
 		set_bit (FLAG_COMMIT, &local->flags);
@@ -6549,12 +6559,12 @@ static int airo_set_encodeext(struct net_device *dev,
 	}
 
 	/* Read the flags */
-	if(encoding->flags & IW_ENCODE_DISABLED)
-		local->config.authType = AUTH_OPEN;	// disable encryption
+	if (encoding->flags & IW_ENCODE_DISABLED)
+		set_auth_type(local, AUTH_OPEN);	/* disable encryption */
 	if(encoding->flags & IW_ENCODE_RESTRICTED)
-		local->config.authType = AUTH_SHAREDKEY;	// Only Both
-	if(encoding->flags & IW_ENCODE_OPEN)
-		local->config.authType = AUTH_ENCRYPT;	// Only Wep
+		set_auth_type(local, AUTH_SHAREDKEY);	/* Only Both */
+	if (encoding->flags & IW_ENCODE_OPEN)
+		set_auth_type(local, AUTH_ENCRYPT);
 	/* Commit the changes to flags if needed */
 	if (local->config.authType != currentAuthType)
 		set_bit (FLAG_COMMIT, &local->flags);
@@ -6659,9 +6669,9 @@ static int airo_set_auth(struct net_device *dev,
 		if (param->value) {
 			/* Only change auth type if unencrypted */
 			if (currentAuthType == AUTH_OPEN)
-				local->config.authType = AUTH_ENCRYPT;
+				set_auth_type(local, AUTH_ENCRYPT);
 		} else {
-			local->config.authType = AUTH_OPEN;
+			set_auth_type(local, AUTH_OPEN);
 		}
 
 		/* Commit the changes to flags if needed */
@@ -6670,13 +6680,14 @@ static int airo_set_auth(struct net_device *dev,
 		break;
 
 	case IW_AUTH_80211_AUTH_ALG: {
-			/* FIXME: What about AUTH_OPEN?  This API seems to
-			 * disallow setting our auth to AUTH_OPEN.
-			 */
 			if (param->value & IW_AUTH_ALG_SHARED_KEY) {
-				local->config.authType = AUTH_SHAREDKEY;
+				set_auth_type(local, AUTH_SHAREDKEY);
 			} else if (param->value & IW_AUTH_ALG_OPEN_SYSTEM) {
-				local->config.authType = AUTH_ENCRYPT;
+				/* We don't know here if WEP open system or
+				 * unencrypted mode was requested - so use the
+				 * last mode (of these two) used last time
+				 */
+				set_auth_type(local, local->last_auth);
 			} else
 				return -EINVAL;
 
-- 
Ondrej Zary
