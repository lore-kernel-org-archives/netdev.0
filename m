From: Dan Williams <dcbw@redhat.com>
Subject: [2.6.15 patch] wireless/atmel: add IWENCODEEXT, IWAUTH, and
	association event support
Date: Tue, 10 Jan 2006 00:56:11 -0500
Message-ID: <1136872572.10082.13.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <networkmanager-list-bounces@gnome.org>
To: simon@thekelleys.org.uk
List-Unsubscribe: <http://mail.gnome.org/mailman/listinfo/networkmanager-list>,
	<mailto:networkmanager-list-request@gnome.org?subject=unsubscribe>
List-Archive: </archives>
List-Post: <mailto:networkmanager-list@gnome.org>
List-Help: <mailto:networkmanager-list-request@gnome.org?subject=help>
List-Subscribe: <http://mail.gnome.org/mailman/listinfo/networkmanager-list>,
	<mailto:networkmanager-list-request@gnome.org?subject=subscribe>
Sender: networkmanager-list-bounces@gnome.org
Errors-To: networkmanager-list-bounces@gnome.org
List-Id: netdev.vger.kernel.org

Hi,

This patch allows the Atmel driver to work correctly with wpa_supplicant
and other programs that require some conformance with WEXT-18.  It
should not affect current behavior of the driver.  The patch does four
things:

1) Implements SIOCSIWENCODEEXT, SIOCGIWENCODEEXT, SIOCSIWAUTH, and
SIOCGIWAUTH calls for unencrypted and WEP operation

2) Accepts zero-filled addresses for SIOCSIWAP, which are legal and
should turn off any previous forced WAP address

3) Sends association and de-association events to userspace at most of
the appropriate times

4) Fixes erroneous order of CIPHER_SUITE_WEP_* arguments in one location
which are actually unused anyway

Signed-off-by: Dan Williams <dcbw@redhat.com>


--- a/drivers/net/wireless/atmel.c	2006-01-09 12:45:00.000000000 -0500
+++ b/drivers/net/wireless/atmel.c	2006-01-10 00:10:46.000000000 -0500
@@ -1407,6 +1407,17 @@
 {
 	struct atmel_private *priv = netdev_priv(dev);
 
+	/* Send event to userspace that we are disassociating */
+	if (priv->station_state == STATION_STATE_READY) {
+		union iwreq_data wrqu;
+
+		wrqu.data.length = 0;
+		wrqu.data.flags = 0;
+		wrqu.ap_addr.sa_family = ARPHRD_ETHER;
+		memset(wrqu.ap_addr.sa_data, 0, ETH_ALEN);
+		wireless_send_event(priv->dev, SIOCGIWAP, &wrqu, NULL);
+	}
+
 	atmel_enter_state(priv, STATION_STATE_DOWN);
 
 	if (priv->bus_type == BUS_TYPE_PCCARD)
@@ -1780,10 +1791,10 @@
 			priv->wep_is_on = 1;
 			priv->exclude_unencrypted = 1;
 			if (priv->wep_key_len[index] > 5) {
-				priv->pairwise_cipher_suite = CIPHER_SUITE_WEP_64;
+				priv->pairwise_cipher_suite = CIPHER_SUITE_WEP_128;
 				priv->encryption_level = 2;
 			} else {
-				priv->pairwise_cipher_suite = CIPHER_SUITE_WEP_128;
+				priv->pairwise_cipher_suite = CIPHER_SUITE_WEP_64;
 				priv->encryption_level = 1;
 			}
 		}
@@ -1853,6 +1864,181 @@
 	return 0;
 }
 
+static int atmel_set_encodeext(struct net_device *dev,
+			    struct iw_request_info *info,
+			    union iwreq_data *wrqu,
+			    char *extra)
+{
+	struct atmel_private *priv = netdev_priv(dev);
+	struct iw_point *encoding = &wrqu->encoding;
+	struct iw_encode_ext *ext = (struct iw_encode_ext *)extra;
+	int idx, key_len;
+
+	/* Determine and validate the key index */
+	idx = encoding->flags & IW_ENCODE_INDEX;
+	if (idx) {
+		if (idx < 1 || idx > WEP_KEYS)
+			return -EINVAL;
+		idx--;
+	} else
+		idx = priv->default_key;
+
+	if ((encoding->flags & IW_ENCODE_DISABLED) ||
+	    ext->alg == IW_ENCODE_ALG_NONE) {
+		priv->wep_is_on = 0;
+		priv->encryption_level = 0;
+		priv->pairwise_cipher_suite = CIPHER_SUITE_NONE;
+	}
+
+	if (ext->ext_flags & IW_ENCODE_EXT_SET_TX_KEY)
+		priv->default_key = idx;
+
+	/* Set the requested key */
+	switch (ext->alg) {
+	case IW_ENCODE_ALG_NONE:
+		break;
+	case IW_ENCODE_ALG_WEP:
+		if (ext->key_len > 5) {
+			priv->wep_key_len[idx] = 13;
+			priv->pairwise_cipher_suite = CIPHER_SUITE_WEP_128;
+			priv->encryption_level = 2;
+		} else if (ext->key_len > 0) {
+			priv->wep_key_len[idx] = 5;
+			priv->pairwise_cipher_suite = CIPHER_SUITE_WEP_64;
+			priv->encryption_level = 1;
+		} else {
+			return -EINVAL;
+		}
+		priv->wep_is_on = 1;
+		memset(priv->wep_keys[idx], 0, 13);
+		key_len = min ((int)ext->key_len, priv->wep_key_len[idx]);
+		memcpy(priv->wep_keys[idx], ext->key, key_len);
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	return -EINPROGRESS;
+}
+
+static int atmel_get_encodeext(struct net_device *dev,
+			    struct iw_request_info *info,
+			    union iwreq_data *wrqu,
+			    char *extra)
+{
+	struct atmel_private *priv = netdev_priv(dev);
+	struct iw_point *encoding = &wrqu->encoding;
+	struct iw_encode_ext *ext = (struct iw_encode_ext *)extra;
+	int idx, max_key_len;
+
+	max_key_len = encoding->length - sizeof(*ext);
+	if (max_key_len < 0)
+		return -EINVAL;
+
+	idx = encoding->flags & IW_ENCODE_INDEX;
+	if (idx) {
+		if (idx < 1 || idx > WEP_KEYS)
+			return -EINVAL;
+		idx--;
+	} else
+		idx = priv->default_key;
+
+	encoding->flags = idx + 1;
+	memset(ext, 0, sizeof(*ext));
+	
+	if (!priv->wep_is_on) {
+		ext->alg = IW_ENCODE_ALG_NONE;
+		ext->key_len = 0;
+		encoding->flags |= IW_ENCODE_DISABLED;
+	} else {
+		if (priv->encryption_level > 0)
+			ext->alg = IW_ENCODE_ALG_WEP;
+		else
+			return -EINVAL;
+
+		ext->key_len = priv->wep_key_len[idx];
+		memcpy(ext->key, priv->wep_keys[idx], ext->key_len);
+		encoding->flags |= IW_ENCODE_ENABLED;
+	}
+
+	return 0;
+}
+
+static int atmel_set_auth(struct net_device *dev,
+			       struct iw_request_info *info,
+			       union iwreq_data *wrqu, char *extra)
+{
+	struct atmel_private *priv = netdev_priv(dev);
+	struct iw_param *param = &wrqu->param;
+
+	switch (param->flags & IW_AUTH_INDEX) {
+	case IW_AUTH_WPA_VERSION:
+	case IW_AUTH_CIPHER_PAIRWISE:
+	case IW_AUTH_CIPHER_GROUP:
+	case IW_AUTH_KEY_MGMT:
+	case IW_AUTH_RX_UNENCRYPTED_EAPOL:
+	case IW_AUTH_PRIVACY_INVOKED:
+		/*
+		 * atmel does not use these parameters
+		 */
+		break;
+
+	case IW_AUTH_DROP_UNENCRYPTED:
+		priv->exclude_unencrypted = param->value ? 1 : 0;
+		break;
+
+	case IW_AUTH_80211_AUTH_ALG: {
+			if (param->value & IW_AUTH_ALG_SHARED_KEY) {
+				priv->exclude_unencrypted = 1;
+			} else if (param->value & IW_AUTH_ALG_OPEN_SYSTEM) {
+				priv->exclude_unencrypted = 0;
+			} else
+				return -EINVAL;
+			break;
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
+static int atmel_get_auth(struct net_device *dev,
+			       struct iw_request_info *info,
+			       union iwreq_data *wrqu, char *extra)
+{
+	struct atmel_private *priv = netdev_priv(dev);
+	struct iw_param *param = &wrqu->param;
+
+	switch (param->flags & IW_AUTH_INDEX) {
+	case IW_AUTH_DROP_UNENCRYPTED:
+		param->value = priv->exclude_unencrypted;
+		break;
+
+	case IW_AUTH_80211_AUTH_ALG:
+		if (priv->exclude_unencrypted == 1)
+			param->value = IW_AUTH_ALG_SHARED_KEY;
+		else
+			param->value = IW_AUTH_ALG_OPEN_SYSTEM;
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
 static int atmel_get_name(struct net_device *dev,
 			  struct iw_request_info *info,
 			  char *cwrq,
@@ -2289,13 +2475,15 @@
 {
 	struct atmel_private *priv = netdev_priv(dev);
 	int i;
-	static const u8 bcast[] = { 255, 255, 255, 255, 255, 255 };
+	static const u8 any[] = { 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF };
+	static const u8 off[] = { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };
 	unsigned long flags;
 
 	if (awrq->sa_family != ARPHRD_ETHER)
 		return -EINVAL;
 
-	if (memcmp(bcast, awrq->sa_data, 6) == 0) {
+	if (!memcmp(any, awrq->sa_data, 6) ||
+	    !memcmp(off, awrq->sa_data, 6)) {
 		del_timer_sync(&priv->management_timer);
 		spin_lock_irqsave(&priv->irqlock, flags);
 		atmel_scan(priv, 1);
@@ -2378,6 +2566,15 @@
 	(iw_handler) atmel_get_encode,		/* SIOCGIWENCODE */
 	(iw_handler) atmel_set_power,		/* SIOCSIWPOWER */
 	(iw_handler) atmel_get_power,		/* SIOCGIWPOWER */
+	(iw_handler) NULL,			/* -- hole -- */
+	(iw_handler) NULL,			/* -- hole -- */
+	(iw_handler) NULL,			/* SIOCSIWGENIE */
+	(iw_handler) NULL,			/* SIOCGIWGENIE */
+	(iw_handler) atmel_set_auth,		/* SIOCSIWAUTH */
+	(iw_handler) atmel_get_auth,		/* SIOCGIWAUTH */
+	(iw_handler) atmel_set_encodeext,	/* SIOCSIWENCODEEXT */
+	(iw_handler) atmel_get_encodeext,	/* SIOCGIWENCODEEXT */
+	(iw_handler) NULL,			/* SIOCSIWPMKSA */
 };
 
 static const iw_handler atmel_private_handler[] =
@@ -2924,6 +3121,8 @@
 	u16 ass_id = le16_to_cpu(ass_resp->ass_id);
 	u16 rates_len = ass_resp->length > 4 ? 4 : ass_resp->length;
 
+	union iwreq_data wrqu;
+
 	if (frame_len < 8 + rates_len)
 		return;
 
@@ -2954,6 +3153,14 @@
 		priv->station_is_associated = 1;
 		priv->station_was_associated = 1;
 		atmel_enter_state(priv, STATION_STATE_READY);
+
+		/* Send association event to userspace */
+		wrqu.data.length = 0;
+		wrqu.data.flags = 0;
+		memcpy(wrqu.ap_addr.sa_data, priv->CurrentBSSID, ETH_ALEN);
+		wrqu.ap_addr.sa_family = ARPHRD_ETHER;
+		wireless_send_event(priv->dev, SIOCGIWAP, &wrqu, NULL);
+
 		return;
 	}
 
@@ -3632,6 +3839,7 @@
 
 	struct atmel_private *priv = netdev_priv(dev);
 	u8 configuration;
+	int old_state = priv->station_state;
 
 	/* data to add to the firmware names, in priority order
 	   this implemenents firmware versioning */
@@ -3792,6 +4000,17 @@
 	else
 		build_wep_mib(priv);
 
+	if (old_state == STATION_STATE_READY)
+	{
+		union iwreq_data wrqu;
+
+		wrqu.data.length = 0;
+		wrqu.data.flags = 0;
+		wrqu.ap_addr.sa_family = ARPHRD_ETHER;
+		memset(wrqu.ap_addr.sa_data, 0, ETH_ALEN);
+		wireless_send_event(priv->dev, SIOCGIWAP, &wrqu, NULL);
+	}
+
 	return 1;
 }
