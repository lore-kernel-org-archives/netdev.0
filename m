From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: [PATCH wireless-2.6 10/10] hostap: Update to use the new WE18 proposal
Date: Sat, 12 Mar 2005 16:41:30 -0800
Message-ID: <20050313004130.GK8253@jm.kir.nu>
References: <20050313001706.GA8253@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20050313001706.GA8253@jm.kir.nu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Note: This depends on WE18 patch being applied first.

Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>

Index: jm-wireless-2.6/drivers/net/wireless/hostap/hostap_ioctl.c
===================================================================
--- jm-wireless-2.6.orig/drivers/net/wireless/hostap/hostap_ioctl.c	2005-03-12 16:10:42.000000000 -0800
+++ jm-wireless-2.6/drivers/net/wireless/hostap/hostap_ioctl.c	2005-03-12 16:39:05.000000000 -0800
@@ -1000,7 +1000,7 @@
 	}
 
 	range->we_version_compiled = WIRELESS_EXT;
-	range->we_version_source = 16;
+	range->we_version_source = 18;
 
 	range->retry_capa = IW_RETRY_LIMIT;
 	range->retry_flags = IW_RETRY_LIMIT;
@@ -1076,6 +1076,9 @@
 				IW_EVENT_CAPA_MASK(IWEVREGISTERED) |
 				IW_EVENT_CAPA_MASK(IWEVEXPIRED));
 
+	range->enc_capa = IW_ENC_CAPA_WPA | IW_ENC_CAPA_WPA2 |
+		IW_ENC_CAPA_CIPHER_TKIP | IW_ENC_CAPA_CIPHER_CCMP;
+
 	return 0;
 }
 
@@ -1731,10 +1734,15 @@
 	struct hostap_interface *iface;
 	local_info_t *local;
 	int ret;
+	u8 *ssid = NULL, ssid_len = 0;
+	struct iw_scan_req *req = (struct iw_scan_req *) extra;
 
 	iface = netdev_priv(dev);
 	local = iface->local;
 
+	if (data->length < sizeof(struct iw_scan_req))
+		req = NULL;
+
 	if (local->iw_mode == IW_MODE_MASTER) {
 		/* In master mode, we just return the results of our local
 		 * tables, so we don't need to start anything...
@@ -1746,8 +1754,19 @@
 	if (!local->dev_enabled)
 		return -ENETDOWN;
 
+	if (req && data->flags & IW_SCAN_THIS_ESSID) {
+		ssid = req->essid;
+		ssid_len = req->essid_len;
+
+		if (ssid_len &&
+		    ((local->iw_mode != IW_MODE_INFRA &&
+		      local->iw_mode != IW_MODE_ADHOC) ||
+		     (local->sta_fw_ver < PRISM2_FW_VER(1,3,1))))
+			return -EOPNOTSUPP;
+	}
+
 	if (local->sta_fw_ver >= PRISM2_FW_VER(1,3,1))
-		ret = prism2_request_hostscan(dev, NULL, 0);
+		ret = prism2_request_hostscan(dev, ssid, ssid_len);
 	else
 		ret = prism2_request_scan(dev);
 
@@ -1926,32 +1945,20 @@
 		}
 	}
 
-	if (bss && bss->wpa_ie_len > 0 && bss->wpa_ie_len <= MAX_WPA_IE_LEN ) {
-		u8 *p = buf;
-		p += sprintf(p, "wpa_ie=");
-		for (i = 0; i < bss->wpa_ie_len; i++) {
-			p += sprintf(p, "%02x", bss->wpa_ie[i]);
-		}
-
+	if (bss && bss->wpa_ie_len > 0 && bss->wpa_ie_len <= MAX_WPA_IE_LEN) {
 		memset(&iwe, 0, sizeof(iwe));
-		iwe.cmd = IWEVCUSTOM;
-		iwe.u.data.length = strlen(buf);
+		iwe.cmd = IWEVGENIE;
+		iwe.u.data.length = bss->wpa_ie_len;
 		current_ev = iwe_stream_add_point(
-			current_ev, end_buf, &iwe, buf);
+			current_ev, end_buf, &iwe, bss->wpa_ie);
 	}
 
-	if (bss && bss->rsn_ie_len > 0 && bss->rsn_ie_len <= MAX_WPA_IE_LEN ) {
-		u8 *p = buf;
-		p += sprintf(p, "rsn_ie=");
-		for (i = 0; i < bss->rsn_ie_len; i++) {
-			p += sprintf(p, "%02x", bss->rsn_ie[i]);
-		}
-
+	if (bss && bss->rsn_ie_len > 0 && bss->rsn_ie_len <= MAX_WPA_IE_LEN) {
 		memset(&iwe, 0, sizeof(iwe));
-		iwe.cmd = IWEVCUSTOM;
-		iwe.u.data.length = strlen(buf);
+		iwe.cmd = IWEVGENIE;
+		iwe.u.data.length = bss->rsn_ie_len;
 		current_ev = iwe_stream_add_point(
-			current_ev, end_buf, &iwe, buf);
+			current_ev, end_buf, &iwe, bss->rsn_ie);
 	}
 
 	return current_ev;
@@ -3098,6 +3105,387 @@
 #endif /* PRISM2_DOWNLOAD_SUPPORT */
 
 
+static int prism2_set_genericelement(struct net_device *dev, u8 *elem,
+				     size_t len)
+{
+	struct hostap_interface *iface = dev->priv;
+	local_info_t *local = iface->local;
+	u8 *buf;
+
+	/*
+	 * Add 16-bit length in the beginning of the buffer because Prism2 RID
+	 * includes it.
+	 */
+	buf = kmalloc(len + 2, GFP_KERNEL);
+	if (buf == NULL)
+		return -ENOMEM;
+
+	*((u16 *) buf) = cpu_to_le16(len);
+	memcpy(buf + 2, elem, len);
+
+	kfree(local->generic_elem);
+	local->generic_elem = buf;
+	local->generic_elem_len = len + 2;
+
+	return local->func->set_rid(local->dev, HFA384X_RID_GENERICELEMENT,
+				    buf, len + 2);
+}
+
+
+static int prism2_ioctl_siwauth(struct net_device *dev,
+				struct iw_request_info *info,
+				struct iw_param *data, char *extra)
+{
+	struct hostap_interface *iface = dev->priv;
+	local_info_t *local = iface->local;
+
+	switch (data->flags & IW_AUTH_INDEX) {
+	case IW_AUTH_WPA_VERSION:
+	case IW_AUTH_CIPHER_PAIRWISE:
+	case IW_AUTH_CIPHER_GROUP:
+	case IW_AUTH_KEY_MGMT:
+		/*
+		 * Host AP driver does not use these parameters and allows
+		 * wpa_supplicant to control them internally.
+		 */
+		break;
+	case IW_AUTH_TKIP_COUNTERMEASURES:
+		local->tkip_countermeasures = data->value;
+		break;
+	case IW_AUTH_DROP_UNENCRYPTED:
+		local->drop_unencrypted = data->value;
+		break;
+	case IW_AUTH_80211_AUTH_ALG:
+		local->auth_algs = data->value;
+		break;
+	case IW_AUTH_WPA_ENABLED:
+		if (data->value == 0) {
+			local->wpa = 0;
+			if (local->sta_fw_ver < PRISM2_FW_VER(1,7,0))
+				break;
+			prism2_set_genericelement(dev, "", 0);
+			local->host_roaming = 0;
+			local->privacy_invoked = 0;
+			if (hostap_set_word(dev, HFA384X_RID_SSNHANDLINGMODE,
+					    0) ||
+			    hostap_set_roaming(local) ||
+			    hostap_set_encryption(local) ||
+			    local->func->reset_port(dev))
+				return -EINVAL;
+			break;
+		}
+		if (local->sta_fw_ver < PRISM2_FW_VER(1,7,0))
+			return -EOPNOTSUPP;
+		local->host_roaming = 2;
+		local->privacy_invoked = 1;
+		local->wpa = 1;
+		if (hostap_set_word(dev, HFA384X_RID_SSNHANDLINGMODE, 1) ||
+		    hostap_set_roaming(local) ||
+		    hostap_set_encryption(local) ||
+		    local->func->reset_port(dev))
+			return -EINVAL;
+		break;
+	case IW_AUTH_RX_UNENCRYPTED_EAPOL:
+		local->ieee_802_1x = data->value;
+		break;
+	case IW_AUTH_PRIVACY_INVOKED:
+		local->privacy_invoked = data->value;
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+	return 0;
+}
+
+
+static int prism2_ioctl_giwauth(struct net_device *dev,
+				struct iw_request_info *info,
+				struct iw_param *data, char *extra)
+{
+	struct hostap_interface *iface = dev->priv;
+	local_info_t *local = iface->local;
+
+	switch (data->flags & IW_AUTH_INDEX) {
+	case IW_AUTH_WPA_VERSION:
+	case IW_AUTH_CIPHER_PAIRWISE:
+	case IW_AUTH_CIPHER_GROUP:
+	case IW_AUTH_KEY_MGMT:
+		/*
+		 * Host AP driver does not use these parameters and allows
+		 * wpa_supplicant to control them internally.
+		 */
+		return -EOPNOTSUPP;
+	case IW_AUTH_TKIP_COUNTERMEASURES:
+		data->value = local->tkip_countermeasures;
+		break;
+	case IW_AUTH_DROP_UNENCRYPTED:
+		data->value = local->drop_unencrypted;
+		break;
+	case IW_AUTH_80211_AUTH_ALG:
+		data->value = local->auth_algs;
+		break;
+	case IW_AUTH_WPA_ENABLED:
+		data->value = local->wpa;
+		break;
+	case IW_AUTH_RX_UNENCRYPTED_EAPOL:
+		data->value = local->ieee_802_1x;
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+	return 0;
+}
+
+
+static int prism2_ioctl_siwencodeext(struct net_device *dev,
+				     struct iw_request_info *info,
+				     struct iw_point *erq, char *extra)
+{
+	struct hostap_interface *iface = dev->priv;
+	local_info_t *local = iface->local;
+	struct iw_encode_ext *ext = (struct iw_encode_ext *) extra;
+	int i, ret = 0;
+	struct hostap_crypto_ops *ops;
+	struct prism2_crypt_data **crypt;
+	void *sta_ptr;
+	u8 *addr;
+	const char *alg, *module;
+
+	i = erq->flags & IW_ENCODE_INDEX;
+	if (i > WEP_KEYS)
+		return -EINVAL;
+	if (i < 1 || i > WEP_KEYS)
+		i = local->tx_keyidx;
+	else
+		i--;
+	if (i < 0 || i >= WEP_KEYS)
+		return -EINVAL;
+
+	addr = ext->addr.sa_data;
+	if (addr[0] == 0xff && addr[1] == 0xff && addr[2] == 0xff &&
+	    addr[3] == 0xff && addr[4] == 0xff && addr[5] == 0xff) {
+		sta_ptr = NULL;
+		crypt = &local->crypt[i];
+	} else {
+		if (i != 0)
+			return -EINVAL;
+		sta_ptr = ap_crypt_get_ptrs(local->ap, addr, 0, &crypt);
+		if (sta_ptr == NULL) {
+			if (local->iw_mode == IW_MODE_INFRA) {
+				/*
+				 * TODO: add STA entry for the current AP so
+				 * that unicast key can be used. For now, this
+				 * is emulated by using default key idx 0.
+				 */
+				i = 0;
+				crypt = &local->crypt[i];
+			} else
+				return -EINVAL;
+		}
+	}
+
+	if ((erq->flags & IW_ENCODE_DISABLED) ||
+	    ext->alg == IW_ENCODE_ALG_NONE) {
+		if (*crypt)
+			prism2_crypt_delayed_deinit(local, crypt);
+		goto done;
+	}
+
+	switch (ext->alg) {
+	case IW_ENCODE_ALG_WEP:
+		alg = "WEP";
+		module = "hostap_crypt_wep";
+		break;
+	case IW_ENCODE_ALG_TKIP:
+		alg = "TKIP";
+		module = "hostap_crypt_tkip";
+		break;
+	case IW_ENCODE_ALG_CCMP:
+		alg = "CCMP";
+		module = "hostap_crypt_ccmp";
+		break;
+	default:
+		printk(KERN_DEBUG "%s: unsupported algorithm %d\n",
+		       local->dev->name, ext->alg);
+		ret = -EOPNOTSUPP;
+		goto done;
+	}
+
+	ops = hostap_get_crypto_ops(alg);
+	if (ops == NULL) {
+		request_module(module);
+		ops = hostap_get_crypto_ops(alg);
+	}
+	if (ops == NULL) {
+		printk(KERN_DEBUG "%s: unknown crypto alg '%s'\n",
+		       local->dev->name, alg);
+		ret = -EOPNOTSUPP;
+		goto done;
+	}
+
+	if (sta_ptr || ext->alg != IW_ENCODE_ALG_WEP) {
+		/*
+		 * Per station encryption and other than WEP algorithms
+		 * require host-based encryption, so force them on
+		 * automatically.
+		 */
+		local->host_decrypt = local->host_encrypt = 1;
+	}
+
+	if (*crypt == NULL || (*crypt)->ops != ops) {
+		struct prism2_crypt_data *new_crypt;
+
+		prism2_crypt_delayed_deinit(local, crypt);
+
+		new_crypt = (struct prism2_crypt_data *)
+			kmalloc(sizeof(struct prism2_crypt_data), GFP_KERNEL);
+		if (new_crypt == NULL) {
+			ret = -ENOMEM;
+			goto done;
+		}
+		memset(new_crypt, 0, sizeof(struct prism2_crypt_data));
+		new_crypt->ops = ops;
+		new_crypt->priv = new_crypt->ops->init(i);
+		if (new_crypt->priv == NULL) {
+			kfree(new_crypt);
+			ret = -EINVAL;
+			goto done;
+		}
+
+		*crypt = new_crypt;
+	}
+
+	/*
+	 * TODO: if ext_flags does not have IW_ENCODE_EXT_RX_SEQ_VALID, the
+	 * existing seq# should not be changed.
+	 * TODO: if ext_flags has IW_ENCODE_EXT_TX_SEQ_VALID, next TX seq#
+	 * should be changed to something else than zero.
+	 */
+	if ((!(ext->ext_flags & IW_ENCODE_EXT_SET_TX_KEY) || ext->key_len > 0)
+	    && (*crypt)->ops->set_key &&
+	    (*crypt)->ops->set_key(ext->key, ext->key_len, ext->rx_seq,
+				   (*crypt)->priv) < 0) {
+		printk(KERN_DEBUG "%s: key setting failed\n",
+		       local->dev->name);
+		ret = -EINVAL;
+		goto done;
+	}
+
+	if (ext->ext_flags & IW_ENCODE_EXT_SET_TX_KEY) {
+		if (!sta_ptr)
+			local->tx_keyidx = i;
+		else if (i) {
+			ret = -EINVAL;
+			goto done;
+		}
+	}
+
+
+	if (sta_ptr == NULL && ext->key_len > 0) {
+		int first = 1, j;
+		for (j = 0; j < WEP_KEYS; j++) {
+			if (j != i && local->crypt[j]) {
+				first = 0;
+				break;
+			}
+		}
+		if (first)
+			local->tx_keyidx = i;
+	}
+
+ done:
+	if (sta_ptr)
+		hostap_handle_sta_release(sta_ptr);
+
+	local->open_wep = erq->flags & IW_ENCODE_OPEN;
+
+	/*
+	 * Do not reset port0 if card is in Managed mode since resetting will
+	 * generate new IEEE 802.11 authentication which may end up in looping
+	 * with IEEE 802.1X. Prism2 documentation seem to require port reset
+	 * after WEP configuration. However, keys are apparently changed at
+	 * least in Managed mode.
+	 */
+	if (ret == 0 &&
+	    (hostap_set_encryption(local) ||
+	     (local->iw_mode != IW_MODE_INFRA &&
+	      local->func->reset_port(local->dev))))
+		ret = -EINVAL;
+
+	return ret;
+}
+
+
+static int prism2_ioctl_giwencodeext(struct net_device *dev,
+				     struct iw_request_info *info,
+				     struct iw_point *erq, char *extra)
+{
+	struct hostap_interface *iface = dev->priv;
+	local_info_t *local = iface->local;
+	struct prism2_crypt_data **crypt;
+	void *sta_ptr;
+	int max_key_len, i;
+	struct iw_encode_ext *ext = (struct iw_encode_ext *) extra;
+	u8 *addr;
+
+	max_key_len = erq->length - sizeof(*ext);
+	if (max_key_len < 0)
+		return -EINVAL;
+
+	i = erq->flags & IW_ENCODE_INDEX;
+	if (i < 1 || i > WEP_KEYS)
+		i = local->tx_keyidx;
+	else
+		i--;
+
+	addr = ext->addr.sa_data;
+	if (addr[0] == 0xff && addr[1] == 0xff && addr[2] == 0xff &&
+	    addr[3] == 0xff && addr[4] == 0xff && addr[5] == 0xff) {
+		sta_ptr = NULL;
+		crypt = &local->crypt[i];
+	} else {
+		i = 0;
+		sta_ptr = ap_crypt_get_ptrs(local->ap, addr, 0, &crypt);
+		if (sta_ptr == NULL)
+			return -EINVAL;
+	}
+	erq->flags = i + 1;
+	memset(ext, 0, sizeof(*ext));
+
+	if (*crypt == NULL || (*crypt)->ops == NULL) {
+		ext->alg = IW_ENCODE_ALG_NONE;
+		ext->key_len = 0;
+		erq->flags |= IW_ENCODE_DISABLED;
+	} else {
+		if (strcmp((*crypt)->ops->name, "WEP") == 0)
+			ext->alg = IW_ENCODE_ALG_WEP;
+		else if (strcmp((*crypt)->ops->name, "TKIP") == 0)
+			ext->alg = IW_ENCODE_ALG_TKIP;
+		else if (strcmp((*crypt)->ops->name, "CCMP") == 0)
+			ext->alg = IW_ENCODE_ALG_CCMP;
+		else
+			return -EINVAL;
+
+		if ((*crypt)->ops->get_key) {
+			ext->key_len =
+				(*crypt)->ops->get_key(ext->key,
+						       max_key_len,
+						       ext->tx_seq,
+						       (*crypt)->priv);
+			if (ext->key_len &&
+			    (ext->alg == IW_ENCODE_ALG_TKIP ||
+			     ext->alg == IW_ENCODE_ALG_CCMP))
+				ext->ext_flags |= IW_ENCODE_EXT_TX_SEQ_VALID;
+		}
+	}
+
+	if (sta_ptr)
+		hostap_handle_sta_release(sta_ptr);
+
+	return 0;
+}
+
+
 static int prism2_ioctl_set_encryption(local_info_t *local,
 				       struct prism2_hostapd_param *param,
 				       int param_len)
@@ -3342,33 +3730,76 @@
 }
 
 
+static int prism2_ioctl_siwgenie(struct net_device *dev,
+				 struct iw_request_info *info,
+				 struct iw_point *data, char *extra)
+{
+	return prism2_set_genericelement(dev, extra, data->length);
+}
+
+
+static int prism2_ioctl_giwgenie(struct net_device *dev,
+				 struct iw_request_info *info,
+				 struct iw_point *data, char *extra)
+{
+	struct hostap_interface *iface = dev->priv;
+	local_info_t *local = iface->local;
+	int len = local->generic_elem_len - 2;
+
+	if (len <= 0 || local->generic_elem == NULL) {
+		data->length = 0;
+		return 0;
+	}
+
+	if (data->length < len)
+		return -E2BIG;
+
+	data->length = len;
+	memcpy(extra, local->generic_elem + 2, len);
+
+	return 0;
+}
+
+
 static int prism2_ioctl_set_generic_element(local_info_t *local,
 					    struct prism2_hostapd_param *param,
 					    int param_len)
 {
 	int max_len, len;
-	u8 *buf;
 
 	len = param->u.generic_elem.len;
 	max_len = param_len - PRISM2_HOSTAPD_GENERIC_ELEMENT_HDR_LEN;
 	if (max_len < 0 || max_len < len)
 		return -EINVAL;
 
-	/* Add 16-bit length in the beginning of the buffer because Prism2 RID
-	 * includes it. */
-	buf = kmalloc(len + 2, GFP_KERNEL);
-	if (buf == NULL)
-		return -ENOMEM;
+	return prism2_set_genericelement(local->dev,
+					 param->u.generic_elem.data, len);
+}
 
-	*((u16 *) buf) = cpu_to_le16(len);
-	memcpy(buf + 2, param->u.generic_elem.data, len);
 
-	kfree(local->generic_elem);
-	local->generic_elem = buf;
-	local->generic_elem_len = len + 2;
+static int prism2_ioctl_siwmlme(struct net_device *dev,
+				struct iw_request_info *info,
+				struct iw_point *data, char *extra)
+{
+	struct hostap_interface *iface = dev->priv;
+	local_info_t *local = iface->local;
+	struct iw_mlme *mlme = (struct iw_mlme *) extra;
+	u16 reason;
 
-	return local->func->set_rid(local->dev, HFA384X_RID_GENERICELEMENT,
-				    buf, len + 2);
+	reason = cpu_to_le16(mlme->reason_code);
+
+	switch (mlme->cmd) {
+	case IW_MLME_DEAUTH:
+		return prism2_sta_send_mgmt(local, mlme->addr.sa_data,
+					    WLAN_FC_STYPE_DEAUTH,
+					    (u8 *) &reason, 2);
+	case IW_MLME_DISASSOC:
+		return prism2_sta_send_mgmt(local, mlme->addr.sa_data,
+					    WLAN_FC_STYPE_DISASSOC,
+					    (u8 *) &reason, 2);
+	default:
+		return -EOPNOTSUPP;
+	}
 }
 
 
@@ -3532,7 +3963,7 @@
 	iw_handler_get_thrspy,				/* SIOCGIWTHRSPY */
 	(iw_handler) prism2_ioctl_siwap,		/* SIOCSIWAP */
 	(iw_handler) prism2_ioctl_giwap,		/* SIOCGIWAP */
-	(iw_handler) NULL,				/* -- hole -- */
+	(iw_handler) prism2_ioctl_siwmlme,		/* SIOCSIWMLME */
 	(iw_handler) prism2_ioctl_giwaplist,		/* SIOCGIWAPLIST */
 	(iw_handler) prism2_ioctl_siwscan,		/* SIOCSIWSCAN */
 	(iw_handler) prism2_ioctl_giwscan,		/* SIOCGIWSCAN */
@@ -3556,6 +3987,16 @@
 	(iw_handler) prism2_ioctl_giwencode,		/* SIOCGIWENCODE */
 	(iw_handler) prism2_ioctl_siwpower,		/* SIOCSIWPOWER */
 	(iw_handler) prism2_ioctl_giwpower,		/* SIOCGIWPOWER */
+	(iw_handler) NULL,				/* -- hole -- */
+	(iw_handler) NULL,				/* -- hole -- */
+	(iw_handler) prism2_ioctl_siwgenie,		/* SIOCSIWGENIE */
+	(iw_handler) prism2_ioctl_giwgenie,		/* SIOCGIWGENIE */
+	(iw_handler) prism2_ioctl_siwauth,		/* SIOCSIWAUTH */
+	(iw_handler) prism2_ioctl_giwauth,		/* SIOCGIWAUTH */
+	(iw_handler) prism2_ioctl_siwencodeext,		/* SIOCSIWENCODEEXT */
+	(iw_handler) prism2_ioctl_giwencodeext,		/* SIOCGIWENCODEEXT */
+	(iw_handler) NULL,				/* SIOCSIWPMKSA */
+	(iw_handler) NULL,				/* -- hole -- */
 };
 
 static const iw_handler prism2_private_handler[] =


-- 
Jouni Malinen                                            PGP id EFC895FA
