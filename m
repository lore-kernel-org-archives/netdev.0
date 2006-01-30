From: Dan Williams <dcbw@redhat.com>
Subject: [2.6.15 patch] wireless/airo: add IWENCODEEXT and IWAUTH support
Date: Mon, 30 Jan 2006 11:58:00 -0500
Message-ID: <1138640281.12551.5.camel@dhcp83-115.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com,
	"John W. Linville" <linville@tuxdriver.com>,
	networkmanager-list@gnome.org
Return-path: <networkmanager-list-bounces@gnome.org>
To: breed@users.sourceforge.net
List-Unsubscribe: <http://mail.gnome.org/mailman/listinfo/networkmanager-list>,
	<mailto:networkmanager-list-request@gnome.org?subject=unsubscribe>
List-Archive: <http://mail.gnome.org/archives/networkmanager-list>
List-Post: <mailto:networkmanager-list@gnome.org>
List-Help: <mailto:networkmanager-list-request@gnome.org?subject=help>
List-Subscribe: <http://mail.gnome.org/mailman/listinfo/networkmanager-list>,
	<mailto:networkmanager-list-request@gnome.org?subject=subscribe>
Sender: networkmanager-list-bounces@gnome.org
Errors-To: networkmanager-list-bounces@gnome.org
List-Id: netdev.vger.kernel.org

This patch adds IWENCODEEXT and IWAUTH support to the airo driver for
WEP and unencrypted operation.  No WPA though.  It allows the driver to
operate more willingly with wpa_supplicant and NetworkManager.

Signed-off-by: Dan Williams <dcbw@redhat.com>

--- a/drivers/net/wireless/airo.c	2006-01-30 10:14:23.000000000 -0500
+++ b/drivers/net/wireless/airo.c	2006-01-30 11:05:15.000000000 -0500
@@ -5802,11 +5802,13 @@ static int airo_set_wap(struct net_devic
 	Cmd cmd;
 	Resp rsp;
 	APListRid APList_rid;
-	static const unsigned char bcast[ETH_ALEN] = { 255, 255, 255, 255, 255, 255 };
+	static const u8 any[ETH_ALEN] = { 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF };
+	static const u8 off[ETH_ALEN] = { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };
 
 	if (awrq->sa_family != ARPHRD_ETHER)
 		return -EINVAL;
-	else if (!memcmp(bcast, awrq->sa_data, ETH_ALEN)) {
+	else if (!memcmp(any, awrq->sa_data, ETH_ALEN) ||
+	         !memcmp(off, awrq->sa_data, ETH_ALEN)) {
 		memset(&cmd, 0, sizeof(cmd));
 		cmd.cmd=CMD_LOSE_SYNC;
 		if (down_interruptible(&local->sem))
@@ -6297,6 +6299,267 @@ static int airo_get_encode(struct net_de
 
 /*------------------------------------------------------------------*/
 /*
+ * Wireless Handler : set extended Encryption parameters
+ */
+static int airo_set_encodeext(struct net_device *dev,
+			   struct iw_request_info *info,
+			    union iwreq_data *wrqu,
+			    char *extra)
+{
+	struct airo_info *local = dev->priv;
+	struct iw_point *encoding = &wrqu->encoding;
+	struct iw_encode_ext *ext = (struct iw_encode_ext *)extra;
+	CapabilityRid cap_rid;		/* Card capability info */
+	int perm = ( encoding->flags & IW_ENCODE_TEMP ? 0 : 1 );
+	u16 currentAuthType = local->config.authType;
+	int idx, key_len, alg = ext->alg;	/* Check encryption mode */
+	wep_key_t key;
+
+	/* Is WEP supported ? */
+	readCapabilityRid(local, &cap_rid, 1);
+	/* Older firmware doesn't support this...
+	if(!(cap_rid.softCap & 2)) {
+		return -EOPNOTSUPP;
+	} */
+	readConfigRid(local, 1);
+
+	/* Determine and validate the key index */
+	idx = encoding->flags & IW_ENCODE_INDEX;
+	if (idx) {
+		if (idx < 1 || idx > ((cap_rid.softCap & 0x80) ? 4:1))
+			return -EINVAL;
+		idx--;
+	} else
+		idx = get_wep_key(local, 0xffff);
+
+	if (encoding->flags & IW_ENCODE_DISABLED)
+		alg = IW_ENCODE_ALG_NONE;
+
+	/* Just setting the transmit key? */
+	if (ext->ext_flags & IW_ENCODE_EXT_SET_TX_KEY) {
+		set_wep_key(local, idx, NULL, 0, perm, 1);
+	} else {
+		/* Set the requested key first */
+		memset(key.key, 0, MAX_KEY_SIZE);
+		switch (alg) {
+		case IW_ENCODE_ALG_NONE:
+			key.len = 0;
+			break;
+		case IW_ENCODE_ALG_WEP:
+			if (ext->key_len > MIN_KEY_SIZE) {
+				key.len = MAX_KEY_SIZE;
+			} else if (ext->key_len > 0) {
+				key.len = MIN_KEY_SIZE;
+			} else {
+				return -EINVAL;
+			}
+			key_len = min (ext->key_len, key.len);
+			memcpy(key.key, ext->key, key_len);
+			break;
+		default:
+			return -EINVAL;
+		}
+		/* Send the key to the card */
+		set_wep_key(local, idx, key.key, key.len, perm, 1);
+	}
+
+	/* Read the flags */
+	if(encoding->flags & IW_ENCODE_DISABLED)
+		local->config.authType = AUTH_OPEN;	// disable encryption
+	if(encoding->flags & IW_ENCODE_RESTRICTED)
+		local->config.authType = AUTH_SHAREDKEY;	// Only Both
+	if(encoding->flags & IW_ENCODE_OPEN)
+		local->config.authType = AUTH_ENCRYPT;	// Only Wep
+	/* Commit the changes to flags if needed */
+	if (local->config.authType != currentAuthType)
+		set_bit (FLAG_COMMIT, &local->flags);
+
+	return -EINPROGRESS;
+}
+
+
+/*------------------------------------------------------------------*/
+/*
+ * Wireless Handler : get extended Encryption parameters
+ */
+static int airo_get_encodeext(struct net_device *dev,
+			    struct iw_request_info *info,
+			    union iwreq_data *wrqu,
+			    char *extra)
+{
+	struct airo_info *local = dev->priv;
+	struct iw_point *encoding = &wrqu->encoding;
+	struct iw_encode_ext *ext = (struct iw_encode_ext *)extra;
+	CapabilityRid cap_rid;		/* Card capability info */
+	int idx, max_key_len;
+
+	/* Is it supported ? */
+	readCapabilityRid(local, &cap_rid, 1);
+	if(!(cap_rid.softCap & 2)) {
+		return -EOPNOTSUPP;
+	}
+	readConfigRid(local, 1);
+
+	max_key_len = encoding->length - sizeof(*ext);
+	if (max_key_len < 0)
+		return -EINVAL;
+
+	idx = encoding->flags & IW_ENCODE_INDEX;
+	if (idx) {
+		if (idx < 1 || idx > ((cap_rid.softCap & 0x80) ? 4:1))
+			return -EINVAL;
+		idx--;
+	} else
+		idx = get_wep_key(local, 0xffff);
+
+	encoding->flags = idx + 1;
+	memset(ext, 0, sizeof(*ext));
+
+	/* Check encryption mode */
+	switch(local->config.authType) {
+		case AUTH_ENCRYPT:
+			encoding->flags = IW_ENCODE_ALG_WEP | IW_ENCODE_ENABLED;
+			break;
+		case AUTH_SHAREDKEY:
+			encoding->flags = IW_ENCODE_ALG_WEP | IW_ENCODE_ENABLED;
+			break;
+		default:
+		case AUTH_OPEN:
+			encoding->flags = IW_ENCODE_ALG_NONE | IW_ENCODE_DISABLED;
+			break;
+	}
+	/* We can't return the key, so set the proper flag and return zero */
+	encoding->flags |= IW_ENCODE_NOKEY;
+	memset(extra, 0, 16);
+	
+	/* Copy the key to the user buffer */
+	ext->key_len = get_wep_key(local, idx);
+	if (ext->key_len > 16) {
+		ext->key_len=0;
+	}
+
+	return 0;
+}
+
+
+/*------------------------------------------------------------------*/
+/*
+ * Wireless Handler : set extended authentication parameters
+ */
+static int airo_set_auth(struct net_device *dev,
+			       struct iw_request_info *info,
+			       union iwreq_data *wrqu, char *extra)
+{
+	struct airo_info *local = dev->priv;
+	struct iw_param *param = &wrqu->param;
+	u16 currentAuthType = local->config.authType;
+
+	switch (param->flags & IW_AUTH_INDEX) {
+	case IW_AUTH_WPA_VERSION:
+	case IW_AUTH_CIPHER_PAIRWISE:
+	case IW_AUTH_CIPHER_GROUP:
+	case IW_AUTH_KEY_MGMT:
+	case IW_AUTH_RX_UNENCRYPTED_EAPOL:
+	case IW_AUTH_PRIVACY_INVOKED:
+		/*
+		 * airo does not use these parameters
+		 */
+		break;
+
+	case IW_AUTH_DROP_UNENCRYPTED:
+		if (param->value) {
+			/* Only change auth type if unencrypted */
+			if (currentAuthType == AUTH_OPEN)
+				local->config.authType = AUTH_ENCRYPT;
+		} else {
+			local->config.authType = AUTH_OPEN;
+		}
+
+		/* Commit the changes to flags if needed */
+		if (local->config.authType != currentAuthType)
+			set_bit (FLAG_COMMIT, &local->flags);
+		break;
+
+	case IW_AUTH_80211_AUTH_ALG: {
+			/* FIXME: What about AUTH_OPEN?  This API seems to
+			 * disallow setting our auth to AUTH_OPEN.
+			 */
+			if (param->value & IW_AUTH_ALG_SHARED_KEY) {
+				local->config.authType = AUTH_SHAREDKEY;
+			} else if (param->value & IW_AUTH_ALG_OPEN_SYSTEM) {
+				local->config.authType = AUTH_ENCRYPT;
+			} else
+				return -EINVAL;
+			break;
+
+			/* Commit the changes to flags if needed */
+			if (local->config.authType != currentAuthType)
+				set_bit (FLAG_COMMIT, &local->flags);
+		}
+
+	case IW_AUTH_WPA_ENABLED:
+		/* Silently accept disable of WPA */
+		if (param->value > 0)
+			return -EOPNOTSUPP;
+		break;
+
+	default:
+		return -EOPNOTSUPP;
+	}
+	return -EINPROGRESS;
+}
+
+
+/*------------------------------------------------------------------*/
+/*
+ * Wireless Handler : get extended authentication parameters
+ */
+static int airo_get_auth(struct net_device *dev,
+			       struct iw_request_info *info,
+			       union iwreq_data *wrqu, char *extra)
+{
+	struct airo_info *local = dev->priv;
+	struct iw_param *param = &wrqu->param;
+	u16 currentAuthType = local->config.authType;
+
+	switch (param->flags & IW_AUTH_INDEX) {
+	case IW_AUTH_DROP_UNENCRYPTED:
+		switch (currentAuthType) {
+		case AUTH_SHAREDKEY:
+		case AUTH_ENCRYPT:
+			param->value = 1;
+			break;
+		default:
+			param->value = 0;
+			break;
+		}
+		break;
+
+	case IW_AUTH_80211_AUTH_ALG:
+		switch (currentAuthType) {
+		case AUTH_SHAREDKEY:
+			param->value = IW_AUTH_ALG_SHARED_KEY;
+			break;
+		case AUTH_ENCRYPT:
+		default:
+			param->value = IW_AUTH_ALG_OPEN_SYSTEM;
+			break;
+		}
+		break;
+
+	case IW_AUTH_WPA_ENABLED:
+		param->value = 0;
+		break;
+
+	default:
+		return -EOPNOTSUPP;
+	}
+	return 0;
+}
+
+
+/*------------------------------------------------------------------*/
+/*
  * Wireless Handler : set Tx-Power
  */
 static int airo_set_txpow(struct net_device *dev,
@@ -7051,6 +7314,15 @@ static const iw_handler		airo_handler[] 
 	(iw_handler) airo_get_encode,		/* SIOCGIWENCODE */
 	(iw_handler) airo_set_power,		/* SIOCSIWPOWER */
 	(iw_handler) airo_get_power,		/* SIOCGIWPOWER */
+	(iw_handler) NULL,			/* -- hole -- */
+	(iw_handler) NULL,			/* -- hole -- */
+	(iw_handler) NULL,			/* SIOCSIWGENIE */
+	(iw_handler) NULL,			/* SIOCGIWGENIE */
+	(iw_handler) airo_set_auth,		/* SIOCSIWAUTH */
+	(iw_handler) airo_get_auth,		/* SIOCGIWAUTH */
+	(iw_handler) airo_set_encodeext,	/* SIOCSIWENCODEEXT */
+	(iw_handler) airo_get_encodeext,	/* SIOCGIWENCODEEXT */
+	(iw_handler) NULL,			/* SIOCSIWPMKSA */
 };
 
 /* Note : don't describe AIROIDIFC and AIROOLDIDIFC in here.
