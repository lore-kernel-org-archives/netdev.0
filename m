From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH] prism54: update to WE-19 for WPA support
Date: Mon, 17 Jul 2006 21:21:47 -0400
Message-ID: <1153185707.2968.7.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>, developers@islsm.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:27051 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1751287AbWGRBVL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2006 21:21:11 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add WE-19 capabilities to prism54 fullmac driver so that it supports the
necessary Wireless Extensions WPA calls.  Convert reporting of WPA/RSN
Generic Information Elements to IWEVGENIE rather than pre-WE-19
IWEVCUSTOM as well.

Signed-off-by: Dan Williams <dcbw@redhat.com>


diff --git a/drivers/net/wireless/prism54/isl_ioctl.c b/drivers/net/wireless/prism54/isl_ioctl.c
index 989599a..f1cc3ba 100644
--- a/drivers/net/wireless/prism54/isl_ioctl.c
+++ b/drivers/net/wireless/prism54/isl_ioctl.c
@@ -35,10 +35,14 @@ #include "oid_mgt.h"
 
 #include <net/iw_handler.h>	/* New driver API */
 
+#define KEY_SIZE_WEP104 13	/* 104/128-bit WEP keys */
+#define KEY_SIZE_WEP40  5	/* 40/64-bit WEP keys */
+/* KEY_SIZE_TKIP should match isl_oid.h, struct obj_key.key[] size */
+#define KEY_SIZE_TKIP   32	/* TKIP keys */
 
-static void prism54_wpa_ie_add(islpci_private *priv, u8 *bssid,
+static void prism54_wpa_bss_ie_add(islpci_private *priv, u8 *bssid,
 				u8 *wpa_ie, size_t wpa_ie_len);
-static size_t prism54_wpa_ie_get(islpci_private *priv, u8 *bssid, u8 *wpa_ie);
+static size_t prism54_wpa_bss_ie_get(islpci_private *priv, u8 *bssid, u8 *wpa_ie);
 static int prism54_set_wpa(struct net_device *, struct iw_request_info *,
 				__u32 *, char *);
 
@@ -468,6 +472,9 @@ prism54_get_range(struct net_device *nde
 	range->event_capa[1] = IW_EVENT_CAPA_K_1;
 	range->event_capa[4] = IW_EVENT_CAPA_MASK(IWEVCUSTOM);
 
+	range->enc_capa = IW_ENC_CAPA_WPA | IW_ENC_CAPA_WPA2 |
+		IW_ENC_CAPA_CIPHER_TKIP;
+
 	if (islpci_get_state(priv) < PRV_STATE_INIT)
 		return 0;
 
@@ -567,6 +574,8 @@ prism54_translate_bss(struct net_device 
 	struct iw_event iwe;	/* Temporary buffer */
 	short cap;
 	islpci_private *priv = netdev_priv(ndev);
+	u8 wpa_ie[MAX_WPA_IE_LEN];
+	size_t wpa_ie_len;
 
 	/* The first entry must be the MAC address */
 	memcpy(iwe.u.ap_addr.sa_data, bss->address, 6);
@@ -627,27 +636,14 @@ #define CAP_CRYPT 0x10
 	current_ev =
 	    iwe_stream_add_event(current_ev, end_buf, &iwe, IW_EV_QUAL_LEN);
 
-	if (priv->wpa) {
-		u8 wpa_ie[MAX_WPA_IE_LEN];
-		char *buf, *p;
-		size_t wpa_ie_len;
-		int i;
-
-		wpa_ie_len = prism54_wpa_ie_get(priv, bss->address, wpa_ie);
-		if (wpa_ie_len > 0 &&
-		    (buf = kmalloc(wpa_ie_len * 2 + 10, GFP_ATOMIC))) {
-			p = buf;
-			p += sprintf(p, "wpa_ie=");
-			for (i = 0; i < wpa_ie_len; i++) {
-				p += sprintf(p, "%02x", wpa_ie[i]);
-			}
-			memset(&iwe, 0, sizeof (iwe));
-			iwe.cmd = IWEVCUSTOM;
-			iwe.u.data.length = strlen(buf);
-			current_ev = iwe_stream_add_point(current_ev, end_buf,
-							  &iwe, buf);
-			kfree(buf);
-		}
+	/* Add WPA/RSN Information Element, if any */
+	wpa_ie_len = prism54_wpa_bss_ie_get(priv, bss->address, wpa_ie);
+	if (wpa_ie_len > 0) {
+		iwe.cmd = IWEVGENIE;
+		iwe.u.data.length = min((u16)wpa_ie_len,
+					  MAX_WPA_IE_LEN);
+		current_ev = iwe_stream_add_point(current_ev, end_buf,
+				&iwe, wpa_ie);
 	}
 	return current_ev;
 }
@@ -1051,12 +1047,24 @@ prism54_set_encode(struct net_device *nd
 		current_index = r.u;
 		/* Verify that the key is not marked as invalid */
 		if (!(dwrq->flags & IW_ENCODE_NOKEY)) {
-			key.length = dwrq->length > sizeof (key.key) ?
-			    sizeof (key.key) : dwrq->length;
-			memcpy(key.key, extra, key.length);
-			if (key.length == 32)
-				/* we want WPA-PSK */
+			if (dwrq->length > KEY_SIZE_TKIP) {
+				/* User-provided key data too big */
+				return -EINVAL;
+			}
+			if (dwrq->length > KEY_SIZE_WEP104) {
+				/* WPA-PSK TKIP */
 				key.type = DOT11_PRIV_TKIP;
+				key.length = KEY_SIZE_TKIP;
+			} else if (dwrq->length > KEY_SIZE_WEP40) {
+				/* WEP 104/128 */
+				key.length = KEY_SIZE_WEP104;
+			} else {
+				/* WEP 40/64 */
+				key.length = KEY_SIZE_WEP40;
+			}
+			memset(key.key, 0, sizeof (key.key));
+			memcpy(key.key, extra, dwrq->length);
+
 			if ((index < 0) || (index > 3))
 				/* no index provided use the current one */
 				index = current_index;
@@ -1210,6 +1218,489 @@ prism54_set_txpower(struct net_device *n
 	}
 }
 
+static int prism54_set_genie(struct net_device *ndev,
+			     struct iw_request_info *info,
+			     struct iw_point *data, char *extra)
+{
+	islpci_private *priv = netdev_priv(ndev);
+	int alen, ret = 0;
+	struct obj_attachment *attach;
+
+	if (data->length > MAX_WPA_IE_LEN ||
+	    (data->length && extra == NULL))
+		return -EINVAL;
+
+	memcpy(priv->wpa_ie, extra, data->length);
+	priv->wpa_ie_len = data->length;
+
+	alen = sizeof(*attach) + priv->wpa_ie_len;
+	attach = kzalloc(alen, GFP_KERNEL);
+	if (attach == NULL)
+		return -ENOMEM;
+
+#define WLAN_FC_TYPE_MGMT 0
+#define WLAN_FC_STYPE_ASSOC_REQ 0
+#define WLAN_FC_STYPE_REASSOC_REQ 2
+
+	/* Note: endianness is covered by mgt_set_varlen */
+	attach->type = (WLAN_FC_TYPE_MGMT << 2) |
+               (WLAN_FC_STYPE_ASSOC_REQ << 4);
+	attach->id = -1;
+	attach->size = priv->wpa_ie_len;
+	memcpy(attach->data, extra, priv->wpa_ie_len);
+
+	ret = mgt_set_varlen(priv, DOT11_OID_ATTACHMENT, attach,
+		priv->wpa_ie_len);
+	if (ret == 0) {
+		attach->type = (WLAN_FC_TYPE_MGMT << 2) |
+			(WLAN_FC_STYPE_REASSOC_REQ << 4);
+
+		ret = mgt_set_varlen(priv, DOT11_OID_ATTACHMENT, attach,
+			priv->wpa_ie_len);
+		if (ret == 0) 
+			printk(KERN_DEBUG "%s: WPA IE Attachment was set\n",
+				ndev->name);
+	}
+
+	kfree(attach);
+	return ret;
+}
+
+
+static int prism54_get_genie(struct net_device *ndev,
+			     struct iw_request_info *info,
+			     struct iw_point *data, char *extra)
+{
+	islpci_private *priv = netdev_priv(ndev);
+	int len = priv->wpa_ie_len;
+
+	if (len <= 0) {
+		data->length = 0;
+		return 0;
+	}
+
+	if (data->length < len)
+		return -E2BIG;
+
+	data->length = len;
+	memcpy(extra, priv->wpa_ie, len);
+
+	return 0;
+}
+
+static int prism54_set_auth(struct net_device *ndev,
+			       struct iw_request_info *info,
+			       union iwreq_data *wrqu, char *extra)
+{
+	islpci_private *priv = netdev_priv(ndev);
+	struct iw_param *param = &wrqu->param;
+	u32 mlmelevel = 0, authen = 0, dot1x = 0;
+	u32 exunencrypt = 0, privinvoked = 0, wpa = 0;
+	u32 old_wpa;
+	int ret = 0;
+	union oid_res_t r;
+
+	if (islpci_get_state(priv) < PRV_STATE_INIT)
+		return 0;
+
+	/* first get the flags */
+	down_write(&priv->mib_sem);
+	wpa = old_wpa = priv->wpa;
+	up_write(&priv->mib_sem);
+	ret = mgt_get_request(priv, DOT11_OID_AUTHENABLE, 0, NULL, &r);
+	authen = r.u;
+	ret = mgt_get_request(priv, DOT11_OID_PRIVACYINVOKED, 0, NULL, &r);
+	privinvoked = r.u;
+	ret = mgt_get_request(priv, DOT11_OID_EXUNENCRYPTED, 0, NULL, &r);
+	exunencrypt = r.u;
+	ret = mgt_get_request(priv, DOT11_OID_DOT1XENABLE, 0, NULL, &r);
+	dot1x = r.u;
+	ret = mgt_get_request(priv, DOT11_OID_MLMEAUTOLEVEL, 0, NULL, &r);
+	mlmelevel = r.u;
+
+	if (ret < 0)
+		goto out;
+
+	switch (param->flags & IW_AUTH_INDEX) {
+	case IW_AUTH_CIPHER_PAIRWISE:
+	case IW_AUTH_CIPHER_GROUP:
+	case IW_AUTH_KEY_MGMT:
+		break;
+
+	case IW_AUTH_WPA_ENABLED:
+		/* Do the same thing as IW_AUTH_WPA_VERSION */
+		if (param->value) {
+			wpa = 1;
+			privinvoked = 1; /* For privacy invoked */
+			exunencrypt = 1; /* Filter out all unencrypted frames */
+			dot1x = 0x01; /* To enable eap filter */
+			mlmelevel = DOT11_MLME_EXTENDED;
+			authen = DOT11_AUTH_OS; /* Only WEP uses _SK and _BOTH */
+		} else {
+			wpa = 0;
+			privinvoked = 0;
+			exunencrypt = 0; /* Do not filter un-encrypted data */
+			dot1x = 0;
+			mlmelevel = DOT11_MLME_AUTO;
+		}
+		break;
+
+	case IW_AUTH_WPA_VERSION:
+		if (param->value & IW_AUTH_WPA_VERSION_DISABLED) {
+			wpa = 0;
+			privinvoked = 0;
+			exunencrypt = 0; /* Do not filter un-encrypted data */
+			dot1x = 0;
+			mlmelevel = DOT11_MLME_AUTO;
+		} else {
+			if (param->value & IW_AUTH_WPA_VERSION_WPA)
+				wpa = 1;
+			else if (param->value & IW_AUTH_WPA_VERSION_WPA2)
+				wpa = 2;
+			privinvoked = 1; /* For privacy invoked */
+			exunencrypt = 1; /* Filter out all unencrypted frames */
+			dot1x = 0x01; /* To enable eap filter */
+			mlmelevel = DOT11_MLME_EXTENDED;
+			authen = DOT11_AUTH_OS; /* Only WEP uses _SK and _BOTH */
+		}
+		break;
+
+	case IW_AUTH_RX_UNENCRYPTED_EAPOL:
+		dot1x = param->value ? 1 : 0;
+		break;
+
+	case IW_AUTH_PRIVACY_INVOKED:
+		privinvoked = param->value ? 1 : 0;
+
+	case IW_AUTH_DROP_UNENCRYPTED:
+		exunencrypt = param->value ? 1 : 0;
+		break;
+
+	case IW_AUTH_80211_AUTH_ALG:
+		if (param->value & IW_AUTH_ALG_SHARED_KEY) {
+			/* Only WEP uses _SK and _BOTH */
+			if (wpa > 0) {
+				ret = -EINVAL;
+				goto out;
+			}
+			authen = DOT11_AUTH_SK;
+		} else if (param->value & IW_AUTH_ALG_OPEN_SYSTEM) {
+			authen = DOT11_AUTH_OS;
+		} else {
+			ret = -EINVAL;
+			goto out;
+		}
+		break;
+
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	/* Set all the values */
+	down_write(&priv->mib_sem);
+	priv->wpa = wpa;
+	up_write(&priv->mib_sem);
+	mgt_set_request(priv, DOT11_OID_AUTHENABLE, 0, &authen);
+	mgt_set_request(priv, DOT11_OID_PRIVACYINVOKED, 0, &privinvoked);
+	mgt_set_request(priv, DOT11_OID_EXUNENCRYPTED, 0, &exunencrypt);
+	mgt_set_request(priv, DOT11_OID_DOT1XENABLE, 0, &dot1x);
+	mgt_set_request(priv, DOT11_OID_MLMEAUTOLEVEL, 0, &mlmelevel);
+
+out:
+	return ret;
+}
+
+static int prism54_get_auth(struct net_device *ndev,
+			    struct iw_request_info *info,
+			    union iwreq_data *wrqu, char *extra)
+{
+	islpci_private *priv = netdev_priv(ndev);
+	struct iw_param *param = &wrqu->param;
+	u32 wpa = 0;
+	int ret = 0;
+	union oid_res_t r;
+
+	if (islpci_get_state(priv) < PRV_STATE_INIT)
+		return 0;
+
+	/* first get the flags */
+	down_write(&priv->mib_sem);
+	wpa = priv->wpa;
+	up_write(&priv->mib_sem);
+
+	switch (param->flags & IW_AUTH_INDEX) {
+	case IW_AUTH_CIPHER_PAIRWISE:
+	case IW_AUTH_CIPHER_GROUP:
+	case IW_AUTH_KEY_MGMT:
+		/*
+		 * wpa_supplicant will control these internally
+		 */
+		ret = -EOPNOTSUPP;
+		break;
+
+	case IW_AUTH_WPA_VERSION:
+		switch (wpa) {
+		case 1:
+			param->value = IW_AUTH_WPA_VERSION_WPA;
+			break;
+		case 2:
+			param->value = IW_AUTH_WPA_VERSION_WPA2;
+			break;
+		case 0:
+		default:
+			param->value = IW_AUTH_WPA_VERSION_DISABLED;
+			break;
+		}
+		break;
+
+	case IW_AUTH_DROP_UNENCRYPTED:
+		ret = mgt_get_request(priv, DOT11_OID_EXUNENCRYPTED, 0, NULL, &r);
+		if (ret >= 0)
+			param->value = r.u > 0 ? 1 : 0;
+		break;
+
+	case IW_AUTH_80211_AUTH_ALG:
+		ret = mgt_get_request(priv, DOT11_OID_AUTHENABLE, 0, NULL, &r);
+		if (ret >= 0) {
+			switch (r.u) {
+			case DOT11_AUTH_OS:
+				param->value = IW_AUTH_ALG_OPEN_SYSTEM;
+				break;
+			case DOT11_AUTH_BOTH:
+			case DOT11_AUTH_SK:
+				param->value = IW_AUTH_ALG_SHARED_KEY;
+			case DOT11_AUTH_NONE:
+			default:
+				param->value = 0;
+				break;
+			}
+		}
+		break;
+
+	case IW_AUTH_WPA_ENABLED:
+		param->value = wpa > 0 ? 1 : 0;
+		break;
+
+	case IW_AUTH_RX_UNENCRYPTED_EAPOL:
+		ret = mgt_get_request(priv, DOT11_OID_DOT1XENABLE, 0, NULL, &r);
+		if (ret >= 0)
+			param->value = r.u > 0 ? 1 : 0;
+		break;
+
+	case IW_AUTH_PRIVACY_INVOKED:
+		ret = mgt_get_request(priv, DOT11_OID_PRIVACYINVOKED, 0, NULL, &r);
+		if (ret >= 0)
+			param->value = r.u > 0 ? 1 : 0;
+		break;
+
+	default:
+		return -EOPNOTSUPP;
+	}
+	return ret;
+}
+
+static int prism54_set_encodeext(struct net_device *ndev,
+				 struct iw_request_info *info,
+				 union iwreq_data *wrqu,
+				 char *extra)
+{
+	islpci_private *priv = netdev_priv(ndev);
+	struct iw_point *encoding = &wrqu->encoding;
+	struct iw_encode_ext *ext = (struct iw_encode_ext *)extra;
+	int idx, alg = ext->alg, set_key = 1;
+	union oid_res_t r;
+	int authen = DOT11_AUTH_OS, invoke = 0, exunencrypt = 0;
+	int ret = 0;
+
+	if (islpci_get_state(priv) < PRV_STATE_INIT)
+		return 0;
+
+	/* Determine and validate the key index */
+	idx = (encoding->flags & IW_ENCODE_INDEX) - 1;
+	if (idx) {
+		if (idx < 0 || idx > 3)
+			return -EINVAL;
+	} else {
+		ret = mgt_get_request(priv, DOT11_OID_DEFKEYID, 0, NULL, &r);
+		if (ret < 0)
+			goto out;
+		idx = r.u;
+	}
+
+	if (encoding->flags & IW_ENCODE_DISABLED)
+		alg = IW_ENCODE_ALG_NONE;
+
+	if (ext->ext_flags & IW_ENCODE_EXT_SET_TX_KEY) {
+		/* Only set transmit key index here, actual
+		 * key is set below if needed.
+		 */
+		ret = mgt_set_request(priv, DOT11_OID_DEFKEYID, 0, &idx);
+		set_key = ext->key_len > 0 ? 1 : 0;
+	}
+
+	if (set_key) {
+		struct obj_key key = { DOT11_PRIV_WEP, 0, "" };
+		switch (alg) {
+		case IW_ENCODE_ALG_NONE:
+			break;
+		case IW_ENCODE_ALG_WEP:
+			if (ext->key_len > KEY_SIZE_WEP104) {
+				ret = -EINVAL;
+				goto out;
+			}
+			if (ext->key_len > KEY_SIZE_WEP40)
+				key.length = KEY_SIZE_WEP104;
+			else
+				key.length = KEY_SIZE_WEP40;
+			break;
+		case IW_ENCODE_ALG_TKIP:
+			if (ext->key_len > KEY_SIZE_TKIP) {
+				ret = -EINVAL;
+				goto out;
+			}
+			key.type = DOT11_PRIV_TKIP;
+			key.length = KEY_SIZE_TKIP;
+		default:
+			return -EINVAL;
+		}
+
+		if (key.length) {
+			memset(key.key, 0, sizeof(key.key));
+			memcpy(key.key, ext->key, ext->key_len);
+			ret = mgt_set_request(priv, DOT11_OID_DEFKEYX, idx,
+					    &key);
+			if (ret < 0)
+				goto out;
+		}
+	}
+
+	/* Read the flags */
+	if (encoding->flags & IW_ENCODE_DISABLED) {
+		/* Encoding disabled, 
+		 * authen = DOT11_AUTH_OS;
+		 * invoke = 0;
+		 * exunencrypt = 0; */
+	}
+	if (encoding->flags & IW_ENCODE_OPEN) {
+		/* Encode but accept non-encoded packets. No auth */
+		invoke = 1;
+	}
+	if (encoding->flags & IW_ENCODE_RESTRICTED) {
+		/* Refuse non-encoded packets. Auth */
+		authen = DOT11_AUTH_BOTH;
+		invoke = 1;
+		exunencrypt = 1;
+	}
+
+	/* do the change if requested  */
+	if (encoding->flags & IW_ENCODE_MODE) {
+		ret = mgt_set_request(priv, DOT11_OID_AUTHENABLE, 0,
+				      &authen);
+		ret = mgt_set_request(priv, DOT11_OID_PRIVACYINVOKED, 0,
+				      &invoke);
+		ret = mgt_set_request(priv, DOT11_OID_EXUNENCRYPTED, 0,
+				      &exunencrypt);
+	}
+
+out:
+	return ret;
+}
+
+
+static int prism54_get_encodeext(struct net_device *ndev,
+				 struct iw_request_info *info,
+				 union iwreq_data *wrqu,
+				 char *extra)
+{
+	islpci_private *priv = netdev_priv(ndev);
+	struct iw_point *encoding = &wrqu->encoding;
+	struct iw_encode_ext *ext = (struct iw_encode_ext *)extra;
+	int idx, max_key_len;
+	union oid_res_t r;
+	int authen = DOT11_AUTH_OS, invoke = 0, exunencrypt = 0, wpa = 0;
+	int ret = 0;
+
+	if (islpci_get_state(priv) < PRV_STATE_INIT)
+		return 0;
+
+	/* first get the flags */
+	ret = mgt_get_request(priv, DOT11_OID_AUTHENABLE, 0, NULL, &r);
+	authen = r.u;
+	ret = mgt_get_request(priv, DOT11_OID_PRIVACYINVOKED, 0, NULL, &r);
+	invoke = r.u;
+	ret = mgt_get_request(priv, DOT11_OID_EXUNENCRYPTED, 0, NULL, &r);
+	exunencrypt = r.u;
+	if (ret < 0)
+		goto out;
+
+	max_key_len = encoding->length - sizeof(*ext);
+	if (max_key_len < 0)
+		return -EINVAL;
+
+	idx = (encoding->flags & IW_ENCODE_INDEX) - 1;
+	if (idx) {
+		if (idx < 0 || idx > 3)
+			return -EINVAL;
+	} else {
+		ret = mgt_get_request(priv, DOT11_OID_DEFKEYID, 0, NULL, &r);
+		if (ret < 0)
+			goto out;
+		idx = r.u;
+	}
+
+	encoding->flags = idx + 1;
+	memset(ext, 0, sizeof(*ext));
+
+	switch (authen) {
+	case DOT11_AUTH_BOTH:
+	case DOT11_AUTH_SK:
+		wrqu->encoding.flags |= IW_ENCODE_RESTRICTED;
+	case DOT11_AUTH_OS:
+	default:
+		wrqu->encoding.flags |= IW_ENCODE_OPEN;
+		break;
+	}
+
+	down_write(&priv->mib_sem);
+	wpa = priv->wpa;
+	up_write(&priv->mib_sem);
+
+	if (authen == DOT11_AUTH_OS && !exunencrypt && !invoke && !wpa) {
+		/* No encryption */
+		ext->alg = IW_ENCODE_ALG_NONE;
+		ext->key_len = 0;
+		wrqu->encoding.flags |= IW_ENCODE_DISABLED;
+	} else {
+		struct obj_key *key;
+
+		ret = mgt_get_request(priv, DOT11_OID_DEFKEYX, idx, NULL, &r);
+		if (ret < 0)
+			goto out;
+		key = r.ptr;
+		if (max_key_len < key->length) {
+			ret = -E2BIG;
+			goto out;
+		}
+		memcpy(ext->key, key->key, key->length);
+		ext->key_len = key->length;
+
+		switch (key->type) {
+		case DOT11_PRIV_TKIP:
+			ext->alg = IW_ENCODE_ALG_TKIP;
+			break;
+		default:
+		case DOT11_PRIV_WEP:
+			ext->alg = IW_ENCODE_ALG_WEP;
+			break;
+		}
+		wrqu->encoding.flags |= IW_ENCODE_ENABLED;
+	}
+
+out:
+	return ret;
+}
+
+
 static int
 prism54_reset(struct net_device *ndev, struct iw_request_info *info,
 	      __u32 * uwrq, char *extra)
@@ -1591,8 +2082,8 @@ #define MAC2STR(a) (a)[0], (a)[1], (a)[2
 #define MACSTR "%02x:%02x:%02x:%02x:%02x:%02x"
 
 static void
-prism54_wpa_ie_add(islpci_private *priv, u8 *bssid,
-		   u8 *wpa_ie, size_t wpa_ie_len)
+prism54_wpa_bss_ie_add(islpci_private *priv, u8 *bssid,
+		       u8 *wpa_ie, size_t wpa_ie_len)
 {
 	struct list_head *ptr;
 	struct islpci_bss_wpa_ie *bss = NULL;
@@ -1658,7 +2149,7 @@ prism54_wpa_ie_add(islpci_private *priv,
 }
 
 static size_t
-prism54_wpa_ie_get(islpci_private *priv, u8 *bssid, u8 *wpa_ie)
+prism54_wpa_bss_ie_get(islpci_private *priv, u8 *bssid, u8 *wpa_ie)
 {
 	struct list_head *ptr;
 	struct islpci_bss_wpa_ie *bss = NULL;
@@ -1683,14 +2174,14 @@ prism54_wpa_ie_get(islpci_private *priv,
 }
 
 void
-prism54_wpa_ie_init(islpci_private *priv)
+prism54_wpa_bss_ie_init(islpci_private *priv)
 {
 	INIT_LIST_HEAD(&priv->bss_wpa_list);
 	sema_init(&priv->wpa_sem, 1);
 }
 
 void
-prism54_wpa_ie_clean(islpci_private *priv)
+prism54_wpa_bss_ie_clean(islpci_private *priv)
 {
 	struct list_head *ptr, *n;
 
@@ -1722,7 +2213,7 @@ prism54_process_bss_data(islpci_private 
 		}
 		if (pos[0] == WLAN_EID_GENERIC && pos[1] >= 4 &&
 		    memcmp(pos + 2, wpa_oid, 4) == 0) {
-			prism54_wpa_ie_add(priv, addr, pos, pos[1] + 2);
+			prism54_wpa_bss_ie_add(priv, addr, pos, pos[1] + 2);
 			return;
 		}
 		pos += 2 + pos[1];
@@ -1879,7 +2370,7 @@ prism54_process_trap_helper(islpci_priva
 		send_formatted_event(priv, "Associate request (ex)", mlme, 1);
 
 		if (priv->iw_mode != IW_MODE_MASTER 
-				&& mlmeex->state != DOT11_STATE_AUTHING)
+				&& mlmeex->state != DOT11_STATE_ASSOCING)
 			break;
 		
 		confirm = kmalloc(sizeof(struct obj_mlmeex), GFP_ATOMIC);
@@ -1893,7 +2384,7 @@ prism54_process_trap_helper(islpci_priva
 		confirm->state = 0; /* not used */
 		confirm->code = 0;
 
-		wpa_ie_len = prism54_wpa_ie_get(priv, mlmeex->address, wpa_ie);
+		wpa_ie_len = prism54_wpa_bss_ie_get(priv, mlmeex->address, wpa_ie);
 
 		if (!wpa_ie_len) {
 			printk(KERN_DEBUG "No WPA IE found from "
@@ -1937,7 +2428,7 @@ prism54_process_trap_helper(islpci_priva
 		confirm->state = 0; /* not used */
 		confirm->code = 0;
 
-		wpa_ie_len = prism54_wpa_ie_get(priv, mlmeex->address, wpa_ie);
+		wpa_ie_len = prism54_wpa_bss_ie_get(priv, mlmeex->address, wpa_ie);
 
 		if (!wpa_ie_len) {
 			printk(KERN_DEBUG "No WPA IE found from "
@@ -2553,6 +3044,15 @@ static const iw_handler prism54_handler[
 	(iw_handler) prism54_get_encode,	/* SIOCGIWENCODE */
 	(iw_handler) NULL,	/* SIOCSIWPOWER */
 	(iw_handler) NULL,	/* SIOCGIWPOWER */
+	NULL,			/* -- hole -- */
+	NULL,			/* -- hole -- */
+	(iw_handler) prism54_set_genie,	/* SIOCSIWGENIE */
+	(iw_handler) prism54_get_genie,	/* SIOCGIWGENIE */
+	(iw_handler) prism54_set_auth,	/* SIOCSIWAUTH */
+	(iw_handler) prism54_get_auth,	/* SIOCGIWAUTH */
+	(iw_handler) prism54_set_encodeext, /* SIOCSIWENCODEEXT */
+	(iw_handler) prism54_get_encodeext, /* SIOCGIWENCODEEXT */
+	NULL,			/* SIOCSIWPMKSA */
 };
 
 /* The low order bit identify a SET (0) or a GET (1) ioctl.  */
diff --git a/drivers/net/wireless/prism54/isl_ioctl.h b/drivers/net/wireless/prism54/isl_ioctl.h
index 46d5cde..65f33ac 100644
--- a/drivers/net/wireless/prism54/isl_ioctl.h
+++ b/drivers/net/wireless/prism54/isl_ioctl.h
@@ -27,7 +27,7 @@ #include "islpci_dev.h"
 
 #include <net/iw_handler.h>	/* New driver API */
 
-#define SUPPORTED_WIRELESS_EXT                  16
+#define SUPPORTED_WIRELESS_EXT                  19
 
 void prism54_mib_init(islpci_private *);
 
@@ -39,8 +39,8 @@ void prism54_acl_clean(struct islpci_acl
 
 void prism54_process_trap(void *);
 
-void prism54_wpa_ie_init(islpci_private *priv);
-void prism54_wpa_ie_clean(islpci_private *priv);
+void prism54_wpa_bss_ie_init(islpci_private *priv);
+void prism54_wpa_bss_ie_clean(islpci_private *priv);
 
 int prism54_set_mac_address(struct net_device *, void *);
 
diff --git a/drivers/net/wireless/prism54/islpci_dev.c b/drivers/net/wireless/prism54/islpci_dev.c
index 5ddf295..ab3c5a2 100644
--- a/drivers/net/wireless/prism54/islpci_dev.c
+++ b/drivers/net/wireless/prism54/islpci_dev.c
@@ -715,7 +715,7 @@ #endif
 	}
 
 	prism54_acl_init(&priv->acl);
-	prism54_wpa_ie_init(priv);
+	prism54_wpa_bss_ie_init(priv);
 	if (mgt_init(priv)) 
 		goto out_free;
 
@@ -774,7 +774,7 @@ islpci_free_memory(islpci_private *priv)
 
 	/* Free the acces control list and the WPA list */
 	prism54_acl_clean(&priv->acl);
-	prism54_wpa_ie_clean(priv);
+	prism54_wpa_bss_ie_clean(priv);
 	mgt_clean(priv);
 
 	return 0;
diff --git a/drivers/net/wireless/prism54/islpci_dev.h b/drivers/net/wireless/prism54/islpci_dev.h
index 0705316..5049f37 100644
--- a/drivers/net/wireless/prism54/islpci_dev.h
+++ b/drivers/net/wireless/prism54/islpci_dev.h
@@ -179,6 +179,8 @@ typedef struct {
 	struct list_head bss_wpa_list;
 	int num_bss_wpa;
 	struct semaphore wpa_sem;
+	u8 wpa_ie[MAX_WPA_IE_LEN];
+	size_t wpa_ie_len;
 
 	struct work_struct reset_task;
 	int reset_task_pending;


