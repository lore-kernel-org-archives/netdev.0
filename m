From: chunkeey@web.de
Subject: [PATCH] prism54: wpa support for fullmac cards
Date: Tue, 3 Oct 2006 14:57:33 +0200
Message-ID: <200610031457.33215.chunkeey@web.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_94lIF1mPqEAm6x9"
Cc: chunkeey@web.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate03.web.de ([217.72.192.234]:43710 "EHLO
	fmmailgate03.web.de") by vger.kernel.org with ESMTP id S932122AbWJCM5h
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Oct 2006 08:57:37 -0400
Received: from smtp07.web.de (fmsmtp07.dlan.cinetic.de [172.20.5.215])
	by fmmailgate03.web.de (Postfix) with ESMTP id 16DF52520728
	for <netdev@vger.kernel.org>; Tue,  3 Oct 2006 14:57:36 +0200 (CEST)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_94lIF1mPqEAm6x9
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

This patch (prism54-en-wpa3.patch) brings WPA/WPA2(RSN) with 
TKIP-Cipher to everyone with a FULLMAC Prism GT/Indigo/Duette card.
I removed all the parts(e.g.: Hostapd Support) which are not relevant for 
wpa_supplicant (client/managed mode).

now, you can connect to your WLAN with: 
wpa_supplicant -Dwext -c{WPA_CONF} -i{WPA_ETH} -dd

This code is just for review & testers...
so only a pre-signed-off for now. ;)
Pre- Signed-off-by: Christian Lamparter <chunkeey@web.de>
---

diffstat:
 isl_ioctl.c      | 1560 
+++++++++++++++++++++----------------------------------
 isl_ioctl.h      |    6
 isl_oid.h        |   99 ++-
 islpci_dev.c     |    1
 islpci_hotplug.c |   11
 islpci_mgt.h     |    4
 oid_mgt.c        |   48 +
 oid_mgt.h        |    2
 8 files changed, 724 insertions(+), 1007 deletions(-)

--Boundary-00=_94lIF1mPqEAm6x9
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="prism54-en-wpa3.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="prism54-en-wpa3.patch"

diff -Nurp a/drivers/net/wireless/prism54/isl_ioctl.c b/drivers/net/wireless/prism54/isl_ioctl.c
--- a/drivers/net/wireless/prism54/isl_ioctl.c	2006-09-28 21:13:25.000000000 +0200
+++ b/drivers/net/wireless/prism54/isl_ioctl.c	2006-10-03 14:27:01.000000000 +0200
@@ -4,6 +4,7 @@
  *            (C) 2003,2004 Aurelien Alleaume <slts@free.fr>
  *            (C) 2003 Herbert Valerio Riedel <hvr@gnu.org>
  *            (C) 2003 Luis R. Rodriguez <mcgrof@ruslug.rutgers.edu>
+ *            (C) 2006 Christian Lamparter <chunkeey@web.de>
  *
  *  This program is free software; you can redistribute it and/or modify
  *  it under the terms of the GNU General Public License as published by
@@ -35,10 +36,12 @@
 
 #include <net/iw_handler.h>	/* New driver API */
 
-#define KEY_SIZE_WEP104 13	/* 104/128-bit WEP keys */
-#define KEY_SIZE_WEP40  5	/* 40/64-bit WEP keys */
+#define KEY_SIZE_WEP40 5	/* short WEP keys */
 /* KEY_SIZE_TKIP should match isl_oid.h, struct obj_key.key[] size */
-#define KEY_SIZE_TKIP   32	/* TKIP keys */
+#define MAC2STR(a) (a)[0], (a)[1], (a)[2], (a)[3], (a)[4], (a)[5]
+#define MACSTR "%02x:%02x:%02x:%02x:%02x:%02x"
+
+static u8 wpa_oid[4] = { 0x00, 0x50, 0xf2, 1 };
 
 static void prism54_wpa_bss_ie_add(islpci_private *priv, u8 *bssid,
 				u8 *wpa_ie, size_t wpa_ie_len);
@@ -168,14 +171,16 @@ prism54_update_stats(islpci_private *pri
 	if (down_interruptible(&priv->stats_sem))
 		return;
 
-/* Noise floor.
- * I'm not sure if the unit is dBm.
- * Note : If we are not connected, this value seems to be irrelevant. */
+	/* Noise floor.
+	 * I'm not sure if the unit is dBm.
+
+	 * Note :
+	 * If we are not connected, this value seems to be irrelevant. */
 
 	mgt_get_request(priv, DOT11_OID_NOISEFLOOR, 0, NULL, &r);
 	priv->local_iwstatistics.qual.noise = r.u;
 
-/* Get the rssi of the link. To do this we need to retrieve a bss. */
+	/* Get the rssi of the link. To do this we need to retrieve a bss. */
 
 	/* First get the MAC address of the AP we are associated with. */
 	mgt_get_request(priv, DOT11_OID_BSSID, 0, NULL, &r);
@@ -200,11 +205,11 @@ prism54_update_stats(islpci_private *pri
 	/* report that the stats are new */
 	priv->local_iwstatistics.qual.updated = 0x7;
 
-/* Rx : unable to decrypt the MPDU */
+	/* Rx : unable to decrypt the MPDU */
 	mgt_get_request(priv, DOT11_OID_PRIVRXFAILED, 0, NULL, &r);
 	priv->local_iwstatistics.discard.code = r.u;
 
-/* Tx : Max MAC retries num reached */
+	/* Tx : Max MAC retries num reached */
 	mgt_get_request(priv, DOT11_OID_MPDUTXFAILED, 0, NULL, &r);
 	priv->local_iwstatistics.discard.retries = r.u;
 
@@ -436,11 +441,11 @@ prism54_get_range(struct net_device *nde
 	/* Now the encoding capabilities */
 	range->num_encoding_sizes = 3;
 	/* 64(40) bits WEP */
-	range->encoding_size[0] = 5;
+	range->encoding_size[0] = KEY_SIZE_WEP40;
 	/* 128(104) bits WEP */
-	range->encoding_size[1] = 13;
+	range->encoding_size[1] = WEP_KEY_LEN;
 	/* 256 bits for WPA-PSK */
-	range->encoding_size[2] = 32;
+	range->encoding_size[2] = SCM_KEY_LEN;
 	/* 4 keys are allowed */
 	range->max_encoding_tokens = 4;
 
@@ -876,15 +881,6 @@ prism54_set_rate(struct net_device *ndev
 		data[1] = 0;
 	}
 
-/*
-	i = 0;
-	printk("prism54 rate: ");
-	while(data[i]) {
-		printk("%u ", data[i]);
-		i++;
-	}
-	printk("0\n");
-*/
 	profile = -1;
 	ret = mgt_set_request(priv, DOT11_OID_PROFILES, 0, &profile);
 	ret |= mgt_set_request(priv, DOT11_OID_EXTENDEDRATES, 0, data);
@@ -1053,18 +1049,58 @@ prism54_get_retry(struct net_device *nde
 }
 
 static int
+prism54_set_auth_alg(islpci_private *priv,	u32 flag)
+{
+	int authen = DOT11_AUTH_NONE, invoke = 0, exunencrypt = 0;
+	int ret;
+
+	if (flag & IW_ENCODE_RESTRICTED) {
+		authen = DOT11_AUTH_SK;
+		invoke = 1;
+		exunencrypt = 1;
+	}
+
+	if (flag & IW_ENCODE_OPEN) {
+		authen = DOT11_AUTH_OS;
+		invoke = 1;
+	/*
+	This is very wrong here, but we've to ensure bug-to-bug compatibility.
+
+	If we set exunencrypt, the Firmware adds the "Privacy" flag to the
+	Capability Information, which is misreaded by many STA/AP as
+	"the device supports WEP, WPA and WPA2"
+	*/
+		exunencrypt = 1; 
+	}
+
+	ret =
+	    mgt_set_request(priv, DOT11_OID_AUTHENABLE,
+				0, &authen);
+	ret |=
+	    mgt_set_request(priv, DOT11_OID_PRIVACYINVOKED,
+				0, &invoke);
+	ret |=
+	    mgt_set_request(priv, DOT11_OID_EXUNENCRYPTED,
+				0,&exunencrypt);
+
+	return ret;
+}
+
+static int
 prism54_set_encode(struct net_device *ndev, struct iw_request_info *info,
 		   struct iw_point *dwrq, char *extra)
 {
 	islpci_private *priv = netdev_priv(ndev);
-	int rvalue = 0, force = 0;
-	int authen = DOT11_AUTH_OS, invoke = 0, exunencrypt = 0;
+	int rvalue = 0, flags = dwrq->flags;
 	union oid_res_t r;
 
 	/* with the new API, it's impossible to get a NULL pointer.
 	 * New version of iwconfig set the IW_ENCODE_NOKEY flag
 	 * when no key is given, but older versions don't. */
 
+	if (islpci_get_state(priv) < PRV_STATE_INIT)
+		return -EINVAL;
+
 	if (dwrq->length > 0) {
 		/* we have a key to set */
 		int index = (dwrq->flags & IW_ENCODE_INDEX) - 1;
@@ -1076,23 +1112,23 @@ prism54_set_encode(struct net_device *nd
 		current_index = r.u;
 		/* Verify that the key is not marked as invalid */
 		if (!(dwrq->flags & IW_ENCODE_NOKEY)) {
-			if (dwrq->length > KEY_SIZE_TKIP) {
+			if (dwrq->length > MAX_KEY_LEN) {
 				/* User-provided key data too big */
 				return -EINVAL;
 			}
-			if (dwrq->length > KEY_SIZE_WEP104) {
+			if (dwrq->length > WEP_KEY_LEN) {
 				/* WPA-PSK TKIP */
 				key.type = DOT11_PRIV_TKIP;
-				key.length = KEY_SIZE_TKIP;
+				key.length = MAX_KEY_LEN;
 			} else if (dwrq->length > KEY_SIZE_WEP40) {
 				/* WEP 104/128 */
-				key.length = KEY_SIZE_WEP104;
+				key.length = WEP_KEY_LEN;
 			} else {
 				/* WEP 40/64 */
 				key.length = KEY_SIZE_WEP40;
 			}
 			memset(key.key, 0, sizeof (key.key));
-			memcpy(key.key, extra, dwrq->length);
+			memcpy(key.key, extra, key.length);
 
 			if ((index < 0) || (index > 3))
 				/* no index provided use the current one */
@@ -1109,95 +1145,111 @@ prism54_set_encode(struct net_device *nd
 		 * This is also how "iwconfig ethX key on" works
 		 */
 		if ((index == current_index) && (key.length > 0))
-			force = 1;
+			flags |= IW_ENCODE_RESTRICTED;
 	} else {
-		int index = (dwrq->flags & IW_ENCODE_INDEX) - 1;
+		int index = (flags & IW_ENCODE_INDEX) - 1;
 		if ((index >= 0) && (index <= 3)) {
 			/* we want to set the key index */
 			rvalue |=
 			    mgt_set_request(priv, DOT11_OID_DEFKEYID, 0,
 					    &index);
 		} else {
-			if (!dwrq->flags & IW_ENCODE_MODE) {
+			if (!(flags & IW_ENCODE_MODE)) {
 				/* we cannot do anything. Complain. */
 				return -EINVAL;
 			}
 		}
 	}
-	/* now read the flags */
-	if (dwrq->flags & IW_ENCODE_DISABLED) {
-		/* Encoding disabled, 
-		 * authen = DOT11_AUTH_OS;
-		 * invoke = 0;
-		 * exunencrypt = 0; */
-	}
-	if (dwrq->flags & IW_ENCODE_OPEN)
-		/* Encode but accept non-encoded packets. No auth */
-		invoke = 1;
-	if ((dwrq->flags & IW_ENCODE_RESTRICTED) || force) {
-		/* Refuse non-encoded packets. Auth */
-		authen = DOT11_AUTH_BOTH;
-		invoke = 1;
-		exunencrypt = 1;
-	}
 	/* do the change if requested  */
-	if ((dwrq->flags & IW_ENCODE_MODE) || force) {
-		rvalue |=
-		    mgt_set_request(priv, DOT11_OID_AUTHENABLE, 0, &authen);
-		rvalue |=
-		    mgt_set_request(priv, DOT11_OID_PRIVACYINVOKED, 0, &invoke);
-		rvalue |=
-		    mgt_set_request(priv, DOT11_OID_EXUNENCRYPTED, 0,
-				    &exunencrypt);
-	}
+	if (flags & IW_ENCODE_MODE)
+		rvalue = prism54_set_auth_alg(priv, flags);
+
 	return rvalue;
 }
 
 static int
+prism54_get_auth_algs(islpci_private *priv)
+{
+	u32 authen = 0, invoke = 0, exunencrypt = 0;
+	union oid_res_t r;
+	int ret = 0;
+
+	ret = mgt_get_request(priv, DOT11_OID_AUTHENABLE, 0, NULL, &r);
+	authen = r.u;
+	ret |= mgt_get_request(priv, DOT11_OID_PRIVACYINVOKED, 0, NULL, &r);
+	invoke = r.u;
+	ret |= mgt_get_request(priv, DOT11_OID_EXUNENCRYPTED, 0, NULL, &r);
+	exunencrypt = r.u;
+
+	if (ret)
+		return ret;
+
+	if (invoke && exunencrypt &&
+		((authen == DOT11_AUTH_SK) || (authen == DOT11_AUTH_BOTH)))
+			ret = IW_ENCODE_RESTRICTED | IW_ENCODE_ENABLED;
+	else if ((authen == DOT11_AUTH_OS)) {
+		if (invoke)
+			ret = IW_ENCODE_OPEN | IW_ENCODE_ENABLED;
+		else {
+			ret = IW_ENCODE_DISABLED;
+			}
+	}
+	else {
+		ret = IW_ENCODE_DISABLED;
+	}
+
+	return ret;
+}
+
+static int
 prism54_get_encode(struct net_device *ndev, struct iw_request_info *info,
 		   struct iw_point *dwrq, char *extra)
 {
 	islpci_private *priv = netdev_priv(ndev);
 	struct obj_key *key;
 	u32 devindex, index = (dwrq->flags & IW_ENCODE_INDEX) - 1;
-	u32 authen = 0, invoke = 0, exunencrypt = 0;
-	int rvalue;
+	int rvalue = 0, flags;
 	union oid_res_t r;
 
+	if (islpci_get_state(priv) < PRV_STATE_INIT) {
+		dwrq->flags = IW_ENCODE_DISABLED;
+		dwrq->length = 0;
+		return 0;
+		}
+
 	/* first get the flags */
-	rvalue = mgt_get_request(priv, DOT11_OID_AUTHENABLE, 0, NULL, &r);
-	authen = r.u;
-	rvalue |= mgt_get_request(priv, DOT11_OID_PRIVACYINVOKED, 0, NULL, &r);
-	invoke = r.u;
-	rvalue |= mgt_get_request(priv, DOT11_OID_EXUNENCRYPTED, 0, NULL, &r);
-	exunencrypt = r.u;
+	if ((flags = prism54_get_auth_algs(priv)) < 0)
+		return rvalue;	
 
-	if (invoke && (authen == DOT11_AUTH_BOTH) && exunencrypt)
-		dwrq->flags = IW_ENCODE_RESTRICTED;
-	else if ((authen == DOT11_AUTH_OS) && !exunencrypt) {
-		if (invoke)
-			dwrq->flags = IW_ENCODE_OPEN;
-		else
-			dwrq->flags = IW_ENCODE_DISABLED;
-	} else
-		/* The card should not work in this state */
-		dwrq->flags = 0;
+	memset(extra, 0x0, dwrq->length);
+	dwrq->flags = flags;
 
-	/* get the current device key index */
-	rvalue |= mgt_get_request(priv, DOT11_OID_DEFKEYID, 0, NULL, &r);
-	devindex = r.u;
-	/* Now get the key, return it */
-	if ((index < 0) || (index > 3))
-		/* no index provided, use the current one */
-		index = devindex;
-	rvalue |= mgt_get_request(priv, DOT11_OID_DEFKEYX, index, NULL, &r);
-	key = r.ptr;
-	dwrq->length = key->length;
-	memcpy(extra, key->key, dwrq->length);
-	kfree(key);
-	/* return the used key index */
-	dwrq->flags |= devindex + 1;
+	if (flags != IW_ENCODE_DISABLED) {
+		/* get the current device key index */
+		rvalue = mgt_get_request(priv, DOT11_OID_DEFKEYID, 0, NULL, &r);
+		devindex = r.u;
+
+		/* Now get the key, return it */
+		if ((index < 0) || (index > 3))
+			/* no index provided, use the current one */
+			index = devindex;
+
+		rvalue |= mgt_get_request(priv, DOT11_OID_DEFKEYX, index, NULL, &r);
+		key = r.ptr;
+
+		if (dwrq->length < key->length) {
+			kfree(key);
+			return -EINVAL;
+		}
 
+		dwrq->length = key->length;
+		memcpy(extra, key->key, dwrq->length);
+		kfree(key);
+		/* return the used key index */
+		dwrq->flags |= devindex + 1;
+	} else
+		rvalue = 0;
+	
 	return rvalue;
 }
 
@@ -1213,7 +1265,7 @@ prism54_get_txpower(struct net_device *n
 	/* intersil firmware operates in 0.25 dBm (1/4 dBm) */
 	vwrq->value = (s32) r.u / 4;
 	vwrq->fixed = 1;
-	/* radio is not turned of
+	/* radio is not turned off
 	 * btw: how is possible to turn off only the radio 
 	 */
 	vwrq->disabled = 0;
@@ -1247,18 +1299,21 @@ prism54_set_txpower(struct net_device *n
 	}
 }
 
-static int prism54_set_genie(struct net_device *ndev,
-			     struct iw_request_info *info,
-			     struct iw_point *data, char *extra)
+static int 
+prism54_set_genie(struct net_device *ndev, struct iw_request_info *info,
+			struct iw_point *data, char *extra)
 {
 	islpci_private *priv = netdev_priv(ndev);
 	int alen, ret = 0;
 	struct obj_attachment *attach;
-
+	
 	if (data->length > MAX_WPA_IE_LEN ||
 	    (data->length && extra == NULL))
 		return -EINVAL;
 
+	if (islpci_get_state(priv) < PRV_STATE_INIT)
+		return -EINVAL;
+
 	memcpy(priv->wpa_ie, extra, data->length);
 	priv->wpa_ie_len = data->length;
 
@@ -1267,28 +1322,25 @@ static int prism54_set_genie(struct net_
 	if (attach == NULL)
 		return -ENOMEM;
 
-#define WLAN_FC_TYPE_MGMT 0
-#define WLAN_FC_STYPE_ASSOC_REQ 0
-#define WLAN_FC_STYPE_REASSOC_REQ 2
-
 	/* Note: endianness is covered by mgt_set_varlen */
-	attach->type = (WLAN_FC_TYPE_MGMT << 2) |
-               (WLAN_FC_STYPE_ASSOC_REQ << 4);
-	attach->id = -1;
-	attach->size = priv->wpa_ie_len;
-	memcpy(attach->data, extra, priv->wpa_ie_len);
-
-	ret = mgt_set_varlen(priv, DOT11_OID_ATTACHMENT, attach,
-		priv->wpa_ie_len);
-	if (ret == 0) {
-		attach->type = (WLAN_FC_TYPE_MGMT << 2) |
-			(WLAN_FC_STYPE_REASSOC_REQ << 4);
-
-		ret = mgt_set_varlen(priv, DOT11_OID_ATTACHMENT, attach,
-			priv->wpa_ie_len);
-		if (ret == 0)
-			printk(KERN_DEBUG "%s: WPA IE Attachment was set\n",
-				ndev->name);
+	attach->id = -1; // global IE
+	attach->size = data->length;
+	memcpy(attach->data, extra, data->length);
+
+	if (priv->iw_mode == IW_MODE_MASTER) {
+		attach->type = DOT11_PKT_BEACON;
+		ret = mgt_set_varlen(priv, DOT11_OID_ATTACHMENT,
+			attach, data->length);
+		attach->type = DOT11_PKT_PROBE_RESP;
+		ret |= mgt_set_varlen(priv, DOT11_OID_ATTACHMENT,
+			attach, data->length);
+	}
+	else {
+		attach->type = DOT11_PKT_ASSOC_REQ;
+		ret = mgt_set_varlen(priv, DOT11_OID_ATTACHMENT, attach, data->length);
+		attach->type = DOT11_PKT_REASSOC_REQ;
+		ret |= mgt_set_varlen(priv, DOT11_OID_ATTACHMENT,
+				     attach, data->length);
 	}
 
 	kfree(attach);
@@ -1296,9 +1348,9 @@ static int prism54_set_genie(struct net_
 }
 
 
-static int prism54_get_genie(struct net_device *ndev,
-			     struct iw_request_info *info,
-			     struct iw_point *data, char *extra)
+static int
+prism54_get_genie(struct net_device *ndev, struct iw_request_info *info,
+			struct iw_point *data, char *extra)
 {
 	islpci_private *priv = netdev_priv(ndev);
 	int len = priv->wpa_ie_len;
@@ -1317,38 +1369,17 @@ static int prism54_get_genie(struct net_
 	return 0;
 }
 
-static int prism54_set_auth(struct net_device *ndev,
-			       struct iw_request_info *info,
-			       union iwreq_data *wrqu, char *extra)
+static int
+prism54_set_auth(struct net_device *ndev, struct iw_request_info *info,
+			union iwreq_data *wrqu, char *extra)
 {
 	islpci_private *priv = netdev_priv(ndev);
 	struct iw_param *param = &wrqu->param;
-	u32 mlmelevel = 0, authen = 0, dot1x = 0;
-	u32 exunencrypt = 0, privinvoked = 0, wpa = 0;
-	u32 old_wpa;
-	int ret = 0;
-	union oid_res_t r;
+	u32 set = 0;
+	int rvalue = 0;
 
 	if (islpci_get_state(priv) < PRV_STATE_INIT)
-		return 0;
-
-	/* first get the flags */
-	down_write(&priv->mib_sem);
-	wpa = old_wpa = priv->wpa;
-	up_write(&priv->mib_sem);
-	ret = mgt_get_request(priv, DOT11_OID_AUTHENABLE, 0, NULL, &r);
-	authen = r.u;
-	ret = mgt_get_request(priv, DOT11_OID_PRIVACYINVOKED, 0, NULL, &r);
-	privinvoked = r.u;
-	ret = mgt_get_request(priv, DOT11_OID_EXUNENCRYPTED, 0, NULL, &r);
-	exunencrypt = r.u;
-	ret = mgt_get_request(priv, DOT11_OID_DOT1XENABLE, 0, NULL, &r);
-	dot1x = r.u;
-	ret = mgt_get_request(priv, DOT11_OID_MLMEAUTOLEVEL, 0, NULL, &r);
-	mlmelevel = r.u;
-
-	if (ret < 0)
-		goto out;
+		return -EINVAL;
 
 	switch (param->flags & IW_AUTH_INDEX) {
 	case IW_AUTH_CIPHER_PAIRWISE:
@@ -1356,103 +1387,72 @@ static int prism54_set_auth(struct net_d
 	case IW_AUTH_KEY_MGMT:
 		break;
 
-	case IW_AUTH_WPA_ENABLED:
-		/* Do the same thing as IW_AUTH_WPA_VERSION */
-		if (param->value) {
-			wpa = 1;
-			privinvoked = 1; /* For privacy invoked */
-			exunencrypt = 1; /* Filter out all unencrypted frames */
-			dot1x = 0x01; /* To enable eap filter */
-			mlmelevel = DOT11_MLME_EXTENDED;
-			authen = DOT11_AUTH_OS; /* Only WEP uses _SK and _BOTH */
-		} else {
-			wpa = 0;
-			privinvoked = 0;
-			exunencrypt = 0; /* Do not filter un-encrypted data */
-			dot1x = 0;
-			mlmelevel = DOT11_MLME_AUTO;
-		}
-		break;
-
 	case IW_AUTH_WPA_VERSION:
-		if (param->value & IW_AUTH_WPA_VERSION_DISABLED) {
-			wpa = 0;
-			privinvoked = 0;
-			exunencrypt = 0; /* Do not filter un-encrypted data */
-			dot1x = 0;
-			mlmelevel = DOT11_MLME_AUTO;
-		} else {
-			if (param->value & IW_AUTH_WPA_VERSION_WPA)
-				wpa = 1;
-			else if (param->value & IW_AUTH_WPA_VERSION_WPA2)
-				wpa = 2;
-			privinvoked = 1; /* For privacy invoked */
-			exunencrypt = 1; /* Filter out all unencrypted frames */
-			dot1x = 0x01; /* To enable eap filter */
-			mlmelevel = DOT11_MLME_EXTENDED;
-			authen = DOT11_AUTH_OS; /* Only WEP uses _SK and _BOTH */
-		}
+		if (set & IW_AUTH_WPA_VERSION_WPA)
+			set = 1;
+		if (set & IW_AUTH_WPA_VERSION_WPA2)
+			set |= 2;
+	case IW_AUTH_WPA_ENABLED:
+		if (!set) 
+			set = param->value ? 3 : 0;
+		rvalue = prism54_set_wpa(ndev, info, &set, extra);
 		break;
 
 	case IW_AUTH_RX_UNENCRYPTED_EAPOL:
-		dot1x = param->value ? 1 : 0;
+		set = param->value ? 1 : 0;
+		rvalue = mgt_set_request(priv, DOT11_OID_DOT1XENABLE, 
+				0, &set);
 		break;
 
 	case IW_AUTH_PRIVACY_INVOKED:
-		privinvoked = param->value ? 1 : 0;
+		set = param->value ? 1 : 0;
+		rvalue = mgt_set_request(priv, DOT11_OID_PRIVACYINVOKED, 
+			0, &set);
+		break;
 
 	case IW_AUTH_DROP_UNENCRYPTED:
-		exunencrypt = param->value ? 1 : 0;
+		set = param->value ? 1 : 0;
+		rvalue = mgt_set_request(priv, DOT11_OID_EXUNENCRYPTED,
+			 0, &set);
 		break;
 
 	case IW_AUTH_80211_AUTH_ALG:
-		if (param->value & IW_AUTH_ALG_SHARED_KEY) {
-			/* Only WEP uses _SK and _BOTH */
-			if (wpa > 0) {
-				ret = -EINVAL;
-				goto out;
-			}
-			authen = DOT11_AUTH_SK;
-		} else if (param->value & IW_AUTH_ALG_OPEN_SYSTEM) {
-			authen = DOT11_AUTH_OS;
-		} else {
-			ret = -EINVAL;
-			goto out;
+		switch (param->value) {
+		case IW_AUTH_ALG_OPEN_SYSTEM:
+			set = DOT11_AUTH_OS;
+			break;
+		case IW_AUTH_ALG_SHARED_KEY:
+			set = DOT11_AUTH_SK;
+			break;
+		default:
+			return -EINVAL;
+			break;
 		}
+		rvalue = mgt_set_request(priv, DOT11_OID_AUTHENABLE, 
+				0, &set);
 		break;
 
 	default:
-		return -EOPNOTSUPP;
+		rvalue = -EOPNOTSUPP;
+		break;
 	}
 
-	/* Set all the values */
-	down_write(&priv->mib_sem);
-	priv->wpa = wpa;
-	up_write(&priv->mib_sem);
-	mgt_set_request(priv, DOT11_OID_AUTHENABLE, 0, &authen);
-	mgt_set_request(priv, DOT11_OID_PRIVACYINVOKED, 0, &privinvoked);
-	mgt_set_request(priv, DOT11_OID_EXUNENCRYPTED, 0, &exunencrypt);
-	mgt_set_request(priv, DOT11_OID_DOT1XENABLE, 0, &dot1x);
-	mgt_set_request(priv, DOT11_OID_MLMEAUTOLEVEL, 0, &mlmelevel);
-
-out:
-	return ret;
+	return rvalue;
 }
 
-static int prism54_get_auth(struct net_device *ndev,
-			    struct iw_request_info *info,
-			    union iwreq_data *wrqu, char *extra)
+static int
+prism54_get_auth(struct net_device *ndev, struct iw_request_info *info,
+			union iwreq_data *wrqu, char *extra)
 {
 	islpci_private *priv = netdev_priv(ndev);
 	struct iw_param *param = &wrqu->param;
-	u32 wpa = 0;
-	int ret = 0;
 	union oid_res_t r;
+	u32 wpa = 0;
+	int rvalue = 0;
 
 	if (islpci_get_state(priv) < PRV_STATE_INIT)
 		return 0;
 
-	/* first get the flags */
 	down_write(&priv->mib_sem);
 	wpa = priv->wpa;
 	up_write(&priv->mib_sem);
@@ -1464,277 +1464,292 @@ static int prism54_get_auth(struct net_d
 		/*
 		 * wpa_supplicant will control these internally
 		 */
-		ret = -EOPNOTSUPP;
-		break;
+		param->value = 0;
+		return -EOPNOTSUPP;
+	break;
 
 	case IW_AUTH_WPA_VERSION:
-		switch (wpa) {
-		case 1:
-			param->value = IW_AUTH_WPA_VERSION_WPA;
-			break;
-		case 2:
-			param->value = IW_AUTH_WPA_VERSION_WPA2;
-			break;
-		case 0:
-		default:
+		if (!wpa)
 			param->value = IW_AUTH_WPA_VERSION_DISABLED;
-			break;
-		}
+		if (wpa & 1)
+			param->value = IW_AUTH_WPA_VERSION_WPA;
+		if (wpa & 2)
+			param->value |= IW_AUTH_WPA_VERSION_WPA2;
+		
 		break;
 
 	case IW_AUTH_DROP_UNENCRYPTED:
-		ret = mgt_get_request(priv, DOT11_OID_EXUNENCRYPTED, 0, NULL, &r);
-		if (ret >= 0)
-			param->value = r.u > 0 ? 1 : 0;
+		rvalue = mgt_get_request(priv, DOT11_OID_EXUNENCRYPTED, 
+			0, NULL, &r);
+		param->value = r.u;
 		break;
 
 	case IW_AUTH_80211_AUTH_ALG:
-		ret = mgt_get_request(priv, DOT11_OID_AUTHENABLE, 0, NULL, &r);
-		if (ret >= 0) {
-			switch (r.u) {
-			case DOT11_AUTH_OS:
-				param->value = IW_AUTH_ALG_OPEN_SYSTEM;
-				break;
-			case DOT11_AUTH_BOTH:
-			case DOT11_AUTH_SK:
-				param->value = IW_AUTH_ALG_SHARED_KEY;
-			case DOT11_AUTH_NONE:
-			default:
-				param->value = 0;
-				break;
-			}
+		rvalue = mgt_get_request(priv, DOT11_OID_AUTHENABLE,
+			 0, NULL, &r);
+
+		switch (r.u) {
+		case DOT11_AUTH_OS:
+			param->value = IW_AUTH_ALG_OPEN_SYSTEM;
+			break;
+		case DOT11_AUTH_BOTH:
+		case DOT11_AUTH_SK:
+			param->value = IW_AUTH_ALG_SHARED_KEY;
+			break;
+		default:
+			param->value = 0;
+			rvalue = -EOPNOTSUPP;
+			break;
 		}
 		break;
 
 	case IW_AUTH_WPA_ENABLED:
-		param->value = wpa > 0 ? 1 : 0;
+		param->value = wpa ? 0 : 1;
 		break;
 
 	case IW_AUTH_RX_UNENCRYPTED_EAPOL:
-		ret = mgt_get_request(priv, DOT11_OID_DOT1XENABLE, 0, NULL, &r);
-		if (ret >= 0)
-			param->value = r.u > 0 ? 1 : 0;
+		rvalue = mgt_get_request(priv, DOT11_OID_DOT1XENABLE, 
+			0, NULL, &r);
+		param->value = r.u;
 		break;
 
 	case IW_AUTH_PRIVACY_INVOKED:
-		ret = mgt_get_request(priv, DOT11_OID_PRIVACYINVOKED, 0, NULL, &r);
-		if (ret >= 0)
-			param->value = r.u > 0 ? 1 : 0;
+		rvalue = mgt_get_request(priv, DOT11_OID_PRIVACYINVOKED, 
+			0, NULL, &r);
+		param->value = r.u;
 		break;
 
 	default:
 		return -EOPNOTSUPP;
+		break;
 	}
-	return ret;
+
+	return 0;
 }
 
-static int prism54_set_encodeext(struct net_device *ndev,
-				 struct iw_request_info *info,
-				 union iwreq_data *wrqu,
-				 char *extra)
+static int
+prism54_set_encodeext(struct net_device *ndev, struct iw_request_info *info,
+			struct iw_point *dwrq, char *extra)
 {
 	islpci_private *priv = netdev_priv(ndev);
-	struct iw_point *encoding = &wrqu->encoding;
-	struct iw_encode_ext *ext = (struct iw_encode_ext *)extra;
-	int idx, alg = ext->alg, set_key = 1;
+	struct iw_encode_ext *enc = (struct iw_encode_ext *)extra;
+	struct obj_stakey* key;
 	union oid_res_t r;
-	int authen = DOT11_AUTH_OS, invoke = 0, exunencrypt = 0;
-	int ret = 0;
-
-	if (islpci_get_state(priv) < PRV_STATE_INIT)
-		return 0;
-
-	/* Determine and validate the key index */
-	idx = (encoding->flags & IW_ENCODE_INDEX) - 1;
-	if (idx) {
-		if (idx < 0 || idx > 3)
-			return -EINVAL;
-	} else {
-		ret = mgt_get_request(priv, DOT11_OID_DEFKEYID, 0, NULL, &r);
-		if (ret < 0)
-			goto out;
-		idx = r.u;
-	}
-
-	if (encoding->flags & IW_ENCODE_DISABLED)
-		alg = IW_ENCODE_ALG_NONE;
+	int index, key_type;
+	int ret = -EINVAL;
 
-	if (ext->ext_flags & IW_ENCODE_EXT_SET_TX_KEY) {
-		/* Only set transmit key index here, actual
-		 * key is set below if needed.
-		 */
-		ret = mgt_set_request(priv, DOT11_OID_DEFKEYID, 0, &idx);
-		set_key = ext->key_len > 0 ? 1 : 0;
-	}
+	if ((islpci_get_state(priv) < PRV_STATE_INIT) ||
+	   (enc->key_len > (dwrq->length - sizeof(*enc))) ||
+	   (enc->addr.sa_family != ARPHRD_ETHER))
+		return -EINVAL;
 
-	if (set_key) {
-		struct obj_key key = { DOT11_PRIV_WEP, 0, "" };
-		switch (alg) {
+	switch (enc->alg) {
 		case IW_ENCODE_ALG_NONE:
+			return 0;
 			break;
 		case IW_ENCODE_ALG_WEP:
-			if (ext->key_len > KEY_SIZE_WEP104) {
-				ret = -EINVAL;
-				goto out;
-			}
-			if (ext->key_len > KEY_SIZE_WEP40)
-				key.length = KEY_SIZE_WEP104;
-			else
-				key.length = KEY_SIZE_WEP40;
+			key_type = DOT11_PRIV_WEP;
 			break;
 		case IW_ENCODE_ALG_TKIP:
-			if (ext->key_len > KEY_SIZE_TKIP) {
-				ret = -EINVAL;
-				goto out;
-			}
-			key.type = DOT11_PRIV_TKIP;
-			key.length = KEY_SIZE_TKIP;
+			key_type = DOT11_PRIV_TKIP;
+			break;
 		default:
-			return -EINVAL;
-		}
-
-		if (key.length) {
-			memset(key.key, 0, sizeof(key.key));
-			memcpy(key.key, ext->key, ext->key_len);
-			ret = mgt_set_request(priv, DOT11_OID_DEFKEYX, idx,
-					    &key);
-			if (ret < 0)
-				goto out;
-		}
+			return -EOPNOTSUPP;
 	}
 
-	/* Read the flags */
-	if (encoding->flags & IW_ENCODE_DISABLED) {
-		/* Encoding disabled,
-		 * authen = DOT11_AUTH_OS;
-		 * invoke = 0;
-		 * exunencrypt = 0; */
-	}
-	if (encoding->flags & IW_ENCODE_OPEN) {
-		/* Encode but accept non-encoded packets. No auth */
-		invoke = 1;
-	}
-	if (encoding->flags & IW_ENCODE_RESTRICTED) {
-		/* Refuse non-encoded packets. Auth */
-		authen = DOT11_AUTH_BOTH;
-		invoke = 1;
-		exunencrypt = 1;
+	index = dwrq->flags & IW_ENCODE_INDEX;
+	if ((index < 0) || (index > 3)) {
+		 /* no index provided, so get the current one */
+		ret = mgt_get_request(priv, DOT11_OID_DEFKEYID, 0, NULL, &r);
+		if (ret)
+			return ret;
+		index = r.u;
 	}
 
-	/* do the change if requested  */
-	if (encoding->flags & IW_ENCODE_MODE) {
-		ret = mgt_set_request(priv, DOT11_OID_AUTHENABLE, 0,
-				      &authen);
-		ret = mgt_set_request(priv, DOT11_OID_PRIVACYINVOKED, 0,
-				      &invoke);
-		ret = mgt_set_request(priv, DOT11_OID_EXUNENCRYPTED, 0,
-				      &exunencrypt);
+	key = kzalloc(sizeof(*key) + enc->key_len, GFP_KERNEL);
+	if (!key)
+		return -ENOMEM;
+
+	key->type = key_type;
+	key->length = enc->key_len;
+	key->keyid = index;
+	key->reserved = 0;
+	if (!(enc->ext_flags & IW_ENCODE_EXT_GROUP_KEY))
+		key->options = DOT11_STAKEY_OPTION_DEFAULTKEY;
+	else 
+		key->options = DOT11_STAKEY_OPTION_GROUPKEY;
+
+	memcpy(key->key, enc->key, key->length);
+	memcpy(key->address, enc->addr.sa_data, ETH_ALEN);
+
+	ret = mgt_set_request(priv, DOT11_OID_STAKEY, 0, key);
+	kfree(key);
+	if (ret)
+		return ret;
+
+	if (enc->ext_flags & IW_ENCODE_EXT_RX_SEQ_VALID) {
+		struct obj_stasc *stasc;
+		stasc = kzalloc(sizeof(*stasc), GFP_KERNEL);
+		if (!stasc)
+			return -ENOMEM;
+		memcpy(stasc->address, enc->addr.sa_data, ETH_ALEN);	
+		stasc->keyid = index;
+		stasc->tx_sc = 1; 
+		memcpy(stasc->sc, enc->rx_seq, 6);
+		ret = mgt_set_request(priv, DOT11_OID_STASC, 0, stasc);
+		kfree(stasc);
+		if (ret)
+			return ret;
 	}
 
-out:
+	if (dwrq->flags & IW_ENCODE_MODE)
+		ret = prism54_set_auth_alg(priv, dwrq->flags);
+
 	return ret;
 }
 
-
-static int prism54_get_encodeext(struct net_device *ndev,
-				 struct iw_request_info *info,
-				 union iwreq_data *wrqu,
-				 char *extra)
+static int
+prism54_get_encodeext(struct net_device *ndev,
+		struct iw_request_info *info, struct iw_point *dwrq, char *extra)
 {
 	islpci_private *priv = netdev_priv(ndev);
-	struct iw_point *encoding = &wrqu->encoding;
-	struct iw_encode_ext *ext = (struct iw_encode_ext *)extra;
-	int idx, max_key_len;
+	struct iw_encode_ext *enc = (struct iw_encode_ext *)extra;
+	struct obj_stasc   *stasc;
 	union oid_res_t r;
-	int authen = DOT11_AUTH_OS, invoke = 0, exunencrypt = 0, wpa = 0;
-	int ret = 0;
+	int index;
+	int ret = -EINVAL;
+	int max_key_len;
 
-	if (islpci_get_state(priv) < PRV_STATE_INIT)
-		return 0;
-
-	/* first get the flags */
-	ret = mgt_get_request(priv, DOT11_OID_AUTHENABLE, 0, NULL, &r);
-	authen = r.u;
-	ret = mgt_get_request(priv, DOT11_OID_PRIVACYINVOKED, 0, NULL, &r);
-	invoke = r.u;
-	ret = mgt_get_request(priv, DOT11_OID_EXUNENCRYPTED, 0, NULL, &r);
-	exunencrypt = r.u;
-	if (ret < 0)
-		goto out;
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
 
-	max_key_len = encoding->length - sizeof(*ext);
+	max_key_len = dwrq->length - sizeof(*enc);
 	if (max_key_len < 0)
 		return -EINVAL;
 
-	idx = (encoding->flags & IW_ENCODE_INDEX) - 1;
-	if (idx) {
-		if (idx < 0 || idx > 3)
-			return -EINVAL;
-	} else {
-		ret = mgt_get_request(priv, DOT11_OID_DEFKEYID, 0, NULL, &r);
-		if (ret < 0)
-			goto out;
-		idx = r.u;
-	}
+	memset(enc, 0, sizeof(*enc));
 
-	encoding->flags = idx + 1;
-	memset(ext, 0, sizeof(*ext));
-
-	switch (authen) {
-	case DOT11_AUTH_BOTH:
-	case DOT11_AUTH_SK:
-		wrqu->encoding.flags |= IW_ENCODE_RESTRICTED;
-	case DOT11_AUTH_OS:
-	default:
-		wrqu->encoding.flags |= IW_ENCODE_OPEN;
-		break;
-	}
+	if (islpci_get_state(priv) < PRV_STATE_INIT) {
+		dwrq->flags = IW_ENCODE_DISABLED;
+		return 0;
+		}
 
-	down_write(&priv->mib_sem);
-	wpa = priv->wpa;
-	up_write(&priv->mib_sem);
+	index = (dwrq->flags & IW_ENCODE_INDEX) - 1;
+	if ((index < 0) || (index > 3)) {
+		 /* no index provided, so get the current one */
+		ret = mgt_get_request(priv, DOT11_OID_DEFKEYID, 0, NULL, &r);
+		if (ret)
+			return ret;
+		index = r.u;
+	}
 
-	if (authen == DOT11_AUTH_OS && !exunencrypt && !invoke && !wpa) {
-		/* No encryption */
-		ext->alg = IW_ENCODE_ALG_NONE;
-		ext->key_len = 0;
-		wrqu->encoding.flags |= IW_ENCODE_DISABLED;
-	} else {
+	if (enc->addr.sa_family != ARPHRD_ETHER) {
+		/* no "per-station key" */
 		struct obj_key *key;
-
-		ret = mgt_get_request(priv, DOT11_OID_DEFKEYX, idx, NULL, &r);
-		if (ret < 0)
-			goto out;
+		ret = mgt_get_request(priv, DOT11_OID_DEFKEYX, index, NULL, &r);
 		key = r.ptr;
-		if (max_key_len < key->length) {
-			ret = -E2BIG;
-			goto out;
+		if (ret) {
+			kfree(key);
+			return ret;
+			}
+
+		if (key->length > max_key_len) {
+			kfree(key);
+			return -E2BIG;
 		}
-		memcpy(ext->key, key->key, key->length);
-		ext->key_len = key->length;
 
+		enc->key_len = key->length;
 		switch (key->type) {
-		case DOT11_PRIV_TKIP:
-			ext->alg = IW_ENCODE_ALG_TKIP;
+		case DOT11_PRIV_WEP:
+			enc->alg = IW_ENCODE_ALG_WEP;
 			break;
+		case DOT11_PRIV_TKIP:
+			enc->alg = IW_ENCODE_ALG_TKIP;
+		break;
 		default:
-		case DOT11_PRIV_WEP:
-			ext->alg = IW_ENCODE_ALG_WEP;
+			kfree(key);
+			return -EIO;
 			break;
 		}
-		wrqu->encoding.flags |= IW_ENCODE_ENABLED;
-	}
-
-out:
-	return ret;
-}
 
+		dwrq->flags |= IW_ENCODE_ENABLED;
+		memcpy(enc->key, key->key, enc->key_len);
+		dwrq->flags |= index +1;
+		return ret;
 
-static int
-prism54_reset(struct net_device *ndev, struct iw_request_info *info,
-	      __u32 * uwrq, char *extra)
-{
-	islpci_reset(netdev_priv(ndev), 0);
+	}
+	else {
+		/* no "per-station key" */
+		struct obj_stakey *key;
+		key = kzalloc(sizeof(*key), GFP_KERNEL);
+		if (!key)
+			return -ENOMEM;
+	
+		memcpy(key->address, enc->addr.sa_data, ETH_ALEN);
+		key->keyid = index;
+		ret = mgt_get_request(priv, DOT11_OID_STAKEY, 0, (void*)key, &r);
+		kfree(key);
+		key = (struct obj_stakey*)r.ptr;
+		if (ret) {
+			kfree(key);
+			return ret;
+		}
+
+		if (key->length > max_key_len) {
+			kfree(key);
+			return -EINVAL;
+		}
+
+		switch (key->type) {
+			case DOT11_PRIV_WEP:
+				enc->alg = IW_ENCODE_ALG_WEP;
+			break;
+			case DOT11_PRIV_TKIP:
+				enc->alg = IW_ENCODE_ALG_TKIP;
+			break;
+			default:
+				kfree(key);
+				return -EIO;
+			break;
+		}
+
+		enc->key_len = key->length;
+		dwrq->flags = index + 1;
+		memcpy(enc->key, key->key, key->length);
+		kfree(key);
+
+		/* add replay counter */
+		stasc = kzalloc(sizeof(*stasc), GFP_KERNEL);
+		if (!stasc)
+			return -ENOMEM;
+
+		memcpy(stasc->address, enc->addr.sa_data, ETH_ALEN);
+		stasc->keyid = index;
+		stasc->tx_sc = 1;
+		ret = mgt_get_request(priv, DOT11_OID_STASC, 0, (void*)stasc, &r);
+		kfree(stasc);
+		stasc = (struct obj_stasc*)r.ptr;
+		if (ret) {
+			kfree(stasc);
+			return ret;
+		}
+
+		memset(enc->tx_seq, 0, IW_ENCODE_SEQ_MAX_SIZE);
+		// prism's FW has only a 6 byte wide RSC!
+		memcpy(enc->tx_seq, stasc->sc, IW_ENCODE_SEQ_MAX_SIZE - 2);
+		enc->ext_flags |= IW_ENCODE_EXT_TX_SEQ_VALID;
+		kfree(stasc);
+
+	}
+
+	return ret;
+}
+
+static int
+prism54_reset(struct net_device *ndev, struct iw_request_info *info,
+	      __u32 * uwrq, char *extra)
+{
+	islpci_reset(netdev_priv(ndev), 0);
 
 	return 0;
 }
@@ -2033,12 +2048,11 @@ format_event(islpci_private *priv, char 
 {
 	const u8 *a = mlme->address;
 	int n = snprintf(dest, IW_CUSTOM_MAX,
-			 "%s %s %2.2X:%2.2X:%2.2X:%2.2X:%2.2X:%2.2X %s (%2.2X)",
+			 "%s %s %2.2X:%2.2X:%2.2X:%2.2X:%2.2X:%2.2X [%2.2x %2.2X %4.4X]",
 			 str,
 			 ((priv->iw_mode == IW_MODE_MASTER) ? "from" : "to"),
 			 a[0], a[1], a[2], a[3], a[4], a[5],
-			 (error ? (mlme->code ? " : REJECTED " : " : ACCEPTED ")
-			  : ""), mlme->code);
+			 mlme->state, mlme->code, mlme->id);
 	BUG_ON(n > IW_CUSTOM_MAX);
 	*length = n;
 }
@@ -2104,12 +2118,6 @@ struct ieee80211_beacon_phdr {
 	u16 capab_info;
 } __attribute__ ((packed));
 
-#define WLAN_EID_GENERIC 0xdd
-static u8 wpa_oid[4] = { 0x00, 0x50, 0xf2, 1 };
-
-#define MAC2STR(a) (a)[0], (a)[1], (a)[2], (a)[3], (a)[4], (a)[5]
-#define MACSTR "%02x:%02x:%02x:%02x:%02x:%02x"
-
 static void
 prism54_wpa_bss_ie_add(islpci_private *priv, u8 *bssid,
 		       u8 *wpa_ie, size_t wpa_ie_len)
@@ -2141,10 +2149,9 @@ prism54_wpa_bss_ie_add(islpci_private *p
 					 struct islpci_bss_wpa_ie, list);
 			list_del(&bss->list);
 		} else {
-			bss = kmalloc(sizeof (*bss), GFP_ATOMIC);
+			bss = kzalloc(sizeof (*bss), GFP_ATOMIC);
 			if (bss != NULL) {
 				priv->num_bss_wpa++;
-				memset(bss, 0, sizeof (*bss));
 			}
 		}
 		if (bss != NULL) {
@@ -2236,11 +2243,16 @@ prism54_process_bss_data(islpci_private 
 	end = payload + len;
 	while (pos < end) {
 		if (pos + 2 + pos[1] > end) {
-			printk(KERN_DEBUG "Parsing Beacon/ProbeResp failed "
-			       "for " MACSTR "\n", MAC2STR(addr));
+			printk(KERN_DEBUG "Parsing %s failed "
+			       "for " MACSTR "\n", (oid == DOT11_OID_BEACON ? "Beacon" : "ProbeResp"), MAC2STR(addr));
 			return;
 		}
-		if (pos[0] == WLAN_EID_GENERIC && pos[1] >= 4 &&
+		/* Don't forget RSN/WPA2 ! */
+		if (pos[0] == MFIE_TYPE_RSN && pos[1] > 4) {
+			prism54_wpa_bss_ie_add(priv, addr, pos, pos[1] + 2);
+			return;
+		}
+		if (pos[0] == MFIE_TYPE_GENERIC && pos[1] >= 4 &&
 		    memcmp(pos + 2, wpa_oid, 4) == 0) {
 			prism54_wpa_bss_ie_add(priv, addr, pos, pos[1] + 2);
 			return;
@@ -2265,39 +2277,78 @@ handle_request(islpci_private *priv, str
 }
 
 static int
+prism54_process_sta_trap(islpci_private *priv, enum oid_num_t oid,
+				struct obj_mlmeex* mlmeex)
+{
+	struct obj_mlme *mlme = (struct obj_mlme*)mlmeex;
+	int ret = 0;
+
+	switch (oid) {
+	case DOT11_OID_DEAUTHENTICATEEX:
+		send_formatted_event(priv, "DeAuthenticate request", 
+				       mlme, 0);
+		break;
+
+	case DOT11_OID_AUTHENTICATEEX:
+		if (prism54_mac_accept(&priv->acl, mlmeex->address) &&
+			(mlmeex->state == DOT11_STATE_AUTH)) {
+
+			mlmeex->state = DOT11_STATE_ASSOCING;
+			mlmeex->code = 0;
+			mlmeex->size = 0;
+			ret = mgt_set_request(priv, DOT11_OID_ASSOCIATEEX, 
+				0, mlmeex);
+			if (ret)
+				return ret;
+		}
+		if (mlmeex->code != 0)
+			send_formatted_event(priv, "Authenticate request", mlme, 1);
+		break;
+
+	case DOT11_OID_DISASSOCIATEEX:
+		send_formatted_event(priv, "Disassociate request", mlme, 0);
+		break;
+
+	case DOT11_OID_ASSOCIATEEX:
+		if (mlmeex->code)
+			send_formatted_event(priv, "Associate request", mlme, 1);
+		break;
+
+	case DOT11_OID_REASSOCIATEEX:
+		if (mlmeex->code)
+			send_formatted_event(priv, "Reassociate request",
+				       mlme, 1);
+		break;
+
+	default:
+		printk(KERN_INFO "%s: Unhandled OID %x, " 
+			"please fill a bug-report!\n", priv->ndev->name, oid);
+		break;
+	}
+
+	return ret;
+}
+
+static int
 prism54_process_trap_helper(islpci_private *priv, enum oid_num_t oid,
 			    char *data)
 {
 	struct obj_mlme *mlme = (struct obj_mlme *) data;
 	struct obj_mlmeex *mlmeex = (struct obj_mlmeex *) data;
-	struct obj_mlmeex *confirm;
-	u8 wpa_ie[MAX_WPA_IE_LEN];
-	int wpa_ie_len;
-	size_t len = 0; /* u16, better? */
-	u8 *payload = NULL, *pos = NULL;
-	int ret;
-
-	/* I think all trapable objects are listed here.
-	 * Some oids have a EX version. The difference is that they are emitted
-	 * in DOT11_MLME_EXTENDED mode (set with DOT11_OID_MLMEAUTOLEVEL)
-	 * with more info.
-	 * The few events already defined by the wireless tools are not really
-	 * suited. We use the more flexible custom event facility.
-	 */
-
-	if (oid >= DOT11_OID_BEACON) {
-		len = mlmeex->size;
-		payload = pos = mlmeex->data;
-	}
+	int ret = 0;
 
 	/* I fear prism54_process_bss_data won't work with big endian data */
-	if ((oid == DOT11_OID_BEACON) || (oid == DOT11_OID_PROBE))
-		prism54_process_bss_data(priv, oid, mlmeex->address,
-					 payload, len);
 
 	mgt_le_to_cpu(isl_oid[oid].flags & OID_FLAG_TYPE, (void *) mlme);
 
 	switch (oid) {
+	case DOT11_OID_BEACON:
+	case DOT11_OID_PROBE:
+		if (priv->iw_mode != IW_MODE_MASTER 
+			&& mlmeex->state != DOT11_STATE_AUTHING)
+			prism54_process_bss_data(priv, oid, mlmeex->address,
+						 mlmeex->data, mlmeex->size);
+		break;
 
 	case GEN_OID_LINKSTATE:
 		link_changed(priv->ndev, (u32) *data);
@@ -2330,163 +2381,12 @@ prism54_process_trap_helper(islpci_priva
 		send_formatted_event(priv, "ReAssociate request", mlme, 1);
 		break;
 
-	case DOT11_OID_BEACON:
-		send_formatted_event(priv,
-				     "Received a beacon from an unkown AP",
-				     mlme, 0);
-		break;
-
-	case DOT11_OID_PROBE:
-		/* we received a probe from a client. */
-		send_formatted_event(priv, "Received a probe from client", mlme,
-				     0);
-		break;
-
-		/* Note : "mlme" is actually a "struct obj_mlmeex *" here, but this
-		 * is backward compatible layout-wise with "struct obj_mlme".
-		 */
-
-	case DOT11_OID_DEAUTHENTICATEEX:
-		send_formatted_event(priv, "DeAuthenticate request", mlme, 0);
-		break;
-
-	case DOT11_OID_AUTHENTICATEEX:
-		handle_request(priv, mlme, oid);
-		send_formatted_event(priv, "Authenticate request (ex)", mlme, 1);
-
-		if (priv->iw_mode != IW_MODE_MASTER 
-				&& mlmeex->state != DOT11_STATE_AUTHING)
-			break;
-
-		confirm = kmalloc(sizeof(struct obj_mlmeex) + 6, GFP_ATOMIC);
-
-		if (!confirm) 
-			break;
-
-		memcpy(&confirm->address, mlmeex->address, ETH_ALEN);
-		printk(KERN_DEBUG "Authenticate from: address:\t%02x:%02x:%02x:%02x:%02x:%02x\n", 
-				mlmeex->address[0],
-				mlmeex->address[1],
-				mlmeex->address[2],
-				mlmeex->address[3],
-				mlmeex->address[4],
-				mlmeex->address[5]
-				);
-		confirm->id = -1; /* or mlmeex->id ? */
-		confirm->state = 0; /* not used */
-		confirm->code = 0;
-		confirm->size = 6;
-		confirm->data[0] = 0x00;
-		confirm->data[1] = 0x00;
-		confirm->data[2] = 0x02;
-		confirm->data[3] = 0x00;
-		confirm->data[4] = 0x00;
-		confirm->data[5] = 0x00;
-
-		ret = mgt_set_varlen(priv, DOT11_OID_ASSOCIATEEX, confirm, 6);
-
-		kfree(confirm);
-		if (ret)
-			return ret;
-		break;
-
-	case DOT11_OID_DISASSOCIATEEX:
-		send_formatted_event(priv, "Disassociate request (ex)", mlme, 0);
-		break;
-
-	case DOT11_OID_ASSOCIATEEX:
-		handle_request(priv, mlme, oid);
-		send_formatted_event(priv, "Associate request (ex)", mlme, 1);
-
-		if (priv->iw_mode != IW_MODE_MASTER 
-				&& mlmeex->state != DOT11_STATE_ASSOCING)
-			break;
-		
-		confirm = kmalloc(sizeof(struct obj_mlmeex), GFP_ATOMIC);
-
-		if (!confirm)
-			break;
-
-		memcpy(&confirm->address, mlmeex->address, ETH_ALEN);
-
-		confirm->id = ((struct obj_mlmeex *)mlme)->id;
-		confirm->state = 0; /* not used */
-		confirm->code = 0;
-
-		wpa_ie_len = prism54_wpa_bss_ie_get(priv, mlmeex->address, wpa_ie);
-
-		if (!wpa_ie_len) {
-			printk(KERN_DEBUG "No WPA IE found from "
-					"address:\t%02x:%02x:%02x:%02x:%02x:%02x\n", 
-				mlmeex->address[0],
-				mlmeex->address[1],
-				mlmeex->address[2],
-				mlmeex->address[3],
-				mlmeex->address[4],
-				mlmeex->address[5]
-				);
-			kfree(confirm);
-			break;
-		}
-
-		confirm->size = wpa_ie_len;
-		memcpy(&confirm->data, wpa_ie, wpa_ie_len);
-
-		mgt_set_varlen(priv, oid, confirm, wpa_ie_len);
-
-		kfree(confirm);
-		
-		break;
-
-	case DOT11_OID_REASSOCIATEEX:
-		handle_request(priv, mlme, oid);
-		send_formatted_event(priv, "Reassociate request (ex)", mlme, 1);
-
-		if (priv->iw_mode != IW_MODE_MASTER 
-				&& mlmeex->state != DOT11_STATE_ASSOCING)
-			break;
-
-		confirm = kmalloc(sizeof(struct obj_mlmeex), GFP_ATOMIC);
-
-		if (!confirm)
-			break;
-
-		memcpy(&confirm->address, mlmeex->address, ETH_ALEN);
-
-		confirm->id = mlmeex->id;
-		confirm->state = 0; /* not used */
-		confirm->code = 0;
-
-		wpa_ie_len = prism54_wpa_bss_ie_get(priv, mlmeex->address, wpa_ie);
-
-		if (!wpa_ie_len) {
-			printk(KERN_DEBUG "No WPA IE found from "
-					"address:\t%02x:%02x:%02x:%02x:%02x:%02x\n", 
-				mlmeex->address[0],
-				mlmeex->address[1],
-				mlmeex->address[2],
-				mlmeex->address[3],
-				mlmeex->address[4],
-				mlmeex->address[5]
-				);
-			kfree(confirm);
-			break;
-		}
-
-		confirm->size = wpa_ie_len; 
-		memcpy(&confirm->data, wpa_ie, wpa_ie_len);
-
-		mgt_set_varlen(priv, oid, confirm, wpa_ie_len);
-
-		kfree(confirm);
-		
-		break;
-
 	default:
-		return -EINVAL;
+		ret = prism54_process_sta_trap(priv, oid, mlmeex);
+		break;
 	}
 
-	return 0;
+	return ret;
 }
 
 /*
@@ -2522,368 +2422,33 @@ prism54_set_mac_address(struct net_devic
 	return ret;
 }
 
-/* Note: currently, use hostapd ioctl from the Host AP driver for WPA
- * support. This is to be replaced with Linux wireless extensions once they
- * get WPA support. */
-
-/* Note II: please leave all this together as it will be easier to remove later,
- * once wireless extensions add WPA support -mcgrof */
-
-/* PRISM54_HOSTAPD ioctl() cmd: */
-enum {
-	PRISM2_SET_ENCRYPTION = 6,
-	PRISM2_HOSTAPD_SET_GENERIC_ELEMENT = 12,
-	PRISM2_HOSTAPD_MLME = 13,
-	PRISM2_HOSTAPD_SCAN_REQ = 14,
-};
-
-#define PRISM54_SET_WPA			SIOCIWFIRSTPRIV+12
-#define PRISM54_HOSTAPD			SIOCIWFIRSTPRIV+25
-#define PRISM54_DROP_UNENCRYPTED	SIOCIWFIRSTPRIV+26
-
-#define PRISM2_HOSTAPD_MAX_BUF_SIZE 1024
-#define PRISM2_HOSTAPD_GENERIC_ELEMENT_HDR_LEN \
-((int) (&((struct prism2_hostapd_param *) 0)->u.generic_elem.data))
-
-/* Maximum length for algorithm names (-1 for nul termination) 
- * used in ioctl() */
-#define HOSTAP_CRYPT_ALG_NAME_LEN 16
-	
-struct prism2_hostapd_param {
-	u32 cmd;
-	u8 sta_addr[ETH_ALEN];
-	union {
-	       struct {
-		       u8 alg[HOSTAP_CRYPT_ALG_NAME_LEN];
-		       u32 flags;
-		       u32 err;
-		       u8 idx;
-		       u8 seq[8]; /* sequence counter (set: RX, get: TX) */
-		       u16 key_len;
-		       u8 key[0];
-		       } crypt;
-               struct {
-                       u8 len;
-                       u8 data[0];
-               } generic_elem;
-               struct {
-#define MLME_STA_DEAUTH 0
-#define MLME_STA_DISASSOC 1
-                       u16 cmd;
-                       u16 reason_code;
-               } mlme;
-               struct {
-                       u8 ssid_len;
-                       u8 ssid[32];
-               } scan_req;
-       } u;
-};
-
-
-static int
-prism2_ioctl_set_encryption(struct net_device *dev,
-	struct prism2_hostapd_param *param,
-	int param_len)
-{
-	islpci_private *priv = netdev_priv(dev);
-	int rvalue = 0, force = 0;
-	int authen = DOT11_AUTH_OS, invoke = 0, exunencrypt = 0;
-	union oid_res_t r;
-
-	/* with the new API, it's impossible to get a NULL pointer.
-	 * New version of iwconfig set the IW_ENCODE_NOKEY flag
-	 * when no key is given, but older versions don't. */
-
-	if (param->u.crypt.key_len > 0) {
-		/* we have a key to set */
-		int index = param->u.crypt.idx;
-		int current_index;
-		struct obj_key key = { DOT11_PRIV_TKIP, 0, "" };
-
-		/* get the current key index */
-		rvalue = mgt_get_request(priv, DOT11_OID_DEFKEYID, 0, NULL, &r);
-		current_index = r.u;
-		/* Verify that the key is not marked as invalid */
-		if (!(param->u.crypt.flags & IW_ENCODE_NOKEY)) {
-			key.length = param->u.crypt.key_len > sizeof (param->u.crypt.key) ?
-			    sizeof (param->u.crypt.key) : param->u.crypt.key_len;
-			memcpy(key.key, param->u.crypt.key, key.length);
-			if (key.length == 32)
-				/* we want WPA-PSK */
-				key.type = DOT11_PRIV_TKIP;
-			if ((index < 0) || (index > 3))
-				/* no index provided use the current one */
-				index = current_index;
-
-			/* now send the key to the card  */
-			rvalue |=
-			    mgt_set_request(priv, DOT11_OID_DEFKEYX, index,
-					    &key);
-		}
-		/*
-		 * If a valid key is set, encryption should be enabled 
-		 * (user may turn it off later).
-		 * This is also how "iwconfig ethX key on" works
-		 */
-		if ((index == current_index) && (key.length > 0))
-			force = 1;
-	} else {
-		int index = (param->u.crypt.flags & IW_ENCODE_INDEX) - 1;
-		if ((index >= 0) && (index <= 3)) {
-			/* we want to set the key index */
-			rvalue |=
-			    mgt_set_request(priv, DOT11_OID_DEFKEYID, 0,
-					    &index);
-		} else {
-			if (!param->u.crypt.flags & IW_ENCODE_MODE) {
-				/* we cannot do anything. Complain. */
-				return -EINVAL;
-			}
-		}
-	}
-	/* now read the flags */
-	if (param->u.crypt.flags & IW_ENCODE_DISABLED) {
-		/* Encoding disabled, 
-		 * authen = DOT11_AUTH_OS;
-		 * invoke = 0;
-		 * exunencrypt = 0; */
-	}
-	if (param->u.crypt.flags & IW_ENCODE_OPEN)
-		/* Encode but accept non-encoded packets. No auth */
-		invoke = 1;
-	if ((param->u.crypt.flags & IW_ENCODE_RESTRICTED) || force) {
-		/* Refuse non-encoded packets. Auth */
-		authen = DOT11_AUTH_BOTH;
-		invoke = 1;
-		exunencrypt = 1;
-	}
-	/* do the change if requested  */
-	if ((param->u.crypt.flags & IW_ENCODE_MODE) || force) {
-		rvalue |=
-		    mgt_set_request(priv, DOT11_OID_AUTHENABLE, 0, &authen);
-		rvalue |=
-		    mgt_set_request(priv, DOT11_OID_PRIVACYINVOKED, 0, &invoke);
-		rvalue |=
-		    mgt_set_request(priv, DOT11_OID_EXUNENCRYPTED, 0,
-				    &exunencrypt);
-	}
-	return rvalue;
-}
-
-static int
-prism2_ioctl_set_generic_element(struct net_device *ndev,
-	struct prism2_hostapd_param *param,
-	int param_len)
-{
-       islpci_private *priv = netdev_priv(ndev);
-       int max_len, len, alen, ret=0;
-       struct obj_attachment *attach;
-
-       len = param->u.generic_elem.len;
-       max_len = param_len - PRISM2_HOSTAPD_GENERIC_ELEMENT_HDR_LEN;
-       if (max_len < 0 || max_len < len)
-               return -EINVAL;
-
-       alen = sizeof(*attach) + len;
-       attach = kmalloc(alen, GFP_KERNEL);
-       if (attach == NULL)
-               return -ENOMEM;
-
-       memset(attach, 0, alen);
-#define WLAN_FC_TYPE_MGMT 0
-#define WLAN_FC_STYPE_ASSOC_REQ 0
-#define WLAN_FC_STYPE_REASSOC_REQ 2
-
-       /* Note: endianness is covered by mgt_set_varlen */
-
-       attach->type = (WLAN_FC_TYPE_MGMT << 2) |
-               (WLAN_FC_STYPE_ASSOC_REQ << 4);
-       attach->id = -1;
-       attach->size = len;
-       memcpy(attach->data, param->u.generic_elem.data, len);
-
-       ret = mgt_set_varlen(priv, DOT11_OID_ATTACHMENT, attach, len);
-
-       if (ret == 0) {
-               attach->type = (WLAN_FC_TYPE_MGMT << 2) |
-                       (WLAN_FC_STYPE_REASSOC_REQ << 4);
-
-	       ret = mgt_set_varlen(priv, DOT11_OID_ATTACHMENT, attach, len);
-
-	       if (ret == 0) 
-		       printk(KERN_DEBUG "%s: WPA IE Attachment was set\n",
-				       ndev->name);
-       }
-
-       kfree(attach);
-       return ret;
-
-}
-
-static int
-prism2_ioctl_mlme(struct net_device *dev, struct prism2_hostapd_param *param)
-{
-	return -EOPNOTSUPP;
-}
-
-static int
-prism2_ioctl_scan_req(struct net_device *ndev,
-                     struct prism2_hostapd_param *param)
-{
-	islpci_private *priv = netdev_priv(ndev);
-	int i, rvalue;
-	struct obj_bsslist *bsslist;
-	u32 noise = 0;
-	char *extra = "";
-	char *current_ev = "foo";
-	union oid_res_t r;
-
-	if (islpci_get_state(priv) < PRV_STATE_INIT) {
-		/* device is not ready, fail gently */
-		return 0;
-	}
-
-	/* first get the noise value. We will use it to report the link quality */
-	rvalue = mgt_get_request(priv, DOT11_OID_NOISEFLOOR, 0, NULL, &r);
-	noise = r.u;
-
-	/* Ask the device for a list of known bss. We can report at most
-	 * IW_MAX_AP=64 to the range struct. But the device won't repport anything
-	 * if you change the value of IWMAX_BSS=24.
-	 */
-	rvalue |= mgt_get_request(priv, DOT11_OID_BSSLIST, 0, NULL, &r);
-	bsslist = r.ptr;
-
-	/* ok now, scan the list and translate its info */
-	for (i = 0; i < min(IW_MAX_AP, (int) bsslist->nr); i++)
-		current_ev = prism54_translate_bss(ndev, current_ev,
-						   extra + IW_SCAN_MAX_DATA,
-						   &(bsslist->bsslist[i]),
-						   noise);
-	kfree(bsslist);
-
-	return rvalue;
-}
-
-static int
-prism54_hostapd(struct net_device *ndev, struct iw_point *p)
-{
-       struct prism2_hostapd_param *param;
-       int ret = 0;
-       u32 uwrq;
-
-       printk(KERN_DEBUG "prism54_hostapd - len=%d\n", p->length);
-       if (p->length < sizeof(struct prism2_hostapd_param) ||
-           p->length > PRISM2_HOSTAPD_MAX_BUF_SIZE || !p->pointer)
-               return -EINVAL;
-
-       param = (struct prism2_hostapd_param *) kmalloc(p->length, GFP_KERNEL);
-       if (param == NULL)
-               return -ENOMEM;
-
-       if (copy_from_user(param, p->pointer, p->length)) {
-               kfree(param);
-               return -EFAULT;
-       }
-
-       switch (param->cmd) {
-       case PRISM2_SET_ENCRYPTION:
-	       printk(KERN_DEBUG "%s: Caught WPA supplicant set encryption request\n",
-			       ndev->name);
-               ret = prism2_ioctl_set_encryption(ndev, param, p->length);
-               break;
-       case PRISM2_HOSTAPD_SET_GENERIC_ELEMENT:
-	       printk(KERN_DEBUG "%s: Caught WPA supplicant set WPA IE request\n",
-			       ndev->name);
-               ret = prism2_ioctl_set_generic_element(ndev, param,
-                                                      p->length);
-               break;
-       case PRISM2_HOSTAPD_MLME:
-	       printk(KERN_DEBUG "%s: Caught WPA supplicant MLME request\n",
-			       ndev->name);
-               ret = prism2_ioctl_mlme(ndev, param);
-               break;
-       case PRISM2_HOSTAPD_SCAN_REQ:
-	       printk(KERN_DEBUG "%s: Caught WPA supplicant scan request\n",
-			       ndev->name);
-               ret = prism2_ioctl_scan_req(ndev, param);
-               break;
-	case PRISM54_SET_WPA:
-	       printk(KERN_DEBUG "%s: Caught WPA supplicant wpa init request\n",
-			       ndev->name);
-	       uwrq = 1;
-	       ret = prism54_set_wpa(ndev, NULL, &uwrq, NULL);
-	       break;
-	case PRISM54_DROP_UNENCRYPTED:
-	       printk(KERN_DEBUG "%s: Caught WPA drop unencrypted request\n",
-			       ndev->name);
-#if 0
-	       uwrq = 0x01;
-	       mgt_set(priv, DOT11_OID_EXUNENCRYPTED, &uwrq);
-	       down_write(&priv->mib_sem);
-	       mgt_commit(priv);
-	       up_write(&priv->mib_sem);
-#endif
-	       /* Not necessary, as set_wpa does it, should we just do it here though? */
-	       ret = 0;
-	       break;
-       default:
-	       printk(KERN_DEBUG "%s: Caught a WPA supplicant request that is not supported\n",
-			       ndev->name);
-               ret = -EOPNOTSUPP;
-               break;
-       }
-
-       if (ret == 0 && copy_to_user(p->pointer, param, p->length))
-               ret = -EFAULT;
-
-       kfree(param);
-
-       return ret;
-}
-
 static int
 prism54_set_wpa(struct net_device *ndev, struct iw_request_info *info,
 		__u32 * uwrq, char *extra)
 {
 	islpci_private *priv = netdev_priv(ndev);
-	u32 mlme, authen, dot1x, filter, wep;
+	u32 mlme, dot1x;
 
 	if (islpci_get_state(priv) < PRV_STATE_INIT)
 		return 0;
 
-	wep = 1; /* For privacy invoked */
-	filter = 1; /* Filter out all unencrypted frames */
-	dot1x = 0x01; /* To enable eap filter */
-	mlme = DOT11_MLME_EXTENDED;
-	authen = DOT11_AUTH_OS; /* Only WEP uses _SK and _BOTH */
+	dot1x = 0; // disable global filtering
+	mlme = DOT11_MLME_AUTO;
 
 	down_write(&priv->mib_sem);
 	priv->wpa = *uwrq;
 
-	switch (priv->wpa) {
-		default:
-		case 0: /* Clears/disables WPA and friends */
-			wep = 0;
-			filter = 0; /* Do not filter un-encrypted data */
-			dot1x = 0;
-			mlme = DOT11_MLME_AUTO;
-			printk("%s: Disabling WPA\n", ndev->name);
-			break;
-		case 2: 
-		case 1: /* WPA */
-			printk("%s: Enabling WPA\n", ndev->name);
-			break;
+	if (priv->wpa) {
+		if (priv->iw_mode == IW_MODE_MASTER) 
+			dot1x = 1;
+		mlme = DOT11_MLME_EXTENDED;
 	}
 	up_write(&priv->mib_sem);
 
-	mgt_set_request(priv, DOT11_OID_AUTHENABLE, 0, &authen);
-	mgt_set_request(priv, DOT11_OID_PRIVACYINVOKED, 0, &wep);
-	mgt_set_request(priv, DOT11_OID_EXUNENCRYPTED, 0, &filter);
 	mgt_set_request(priv, DOT11_OID_DOT1XENABLE, 0, &dot1x);
 	mgt_set_request(priv, DOT11_OID_MLMEAUTOLEVEL, 0, &mlme);
 
-	return 0;
+	return prism54_set_auth_alg(priv, IW_ENCODE_OPEN);
 }
 
 static int
@@ -2891,7 +2456,9 @@ prism54_get_wpa(struct net_device *ndev,
 		__u32 * uwrq, char *extra)
 {
 	islpci_private *priv = netdev_priv(ndev);
+	down_write(&priv->mib_sem);
 	*uwrq = priv->wpa;
+	up_write(&priv->mib_sem);
 	return 0;
 }
 
@@ -3026,6 +2593,80 @@ prism54_set_spy(struct net_device *ndev,
 	return iw_handler_set_spy(ndev, info, uwrq, extra);
 }
 
+static int
+prism54_send_mlme(struct net_device *ndev, struct iw_request_info *info,
+		  struct iw_point *dwrq, char *extra)
+{
+	islpci_private *priv = netdev_priv(ndev);
+	struct iw_mlme *iwmlme;
+	struct obj_mlme mlme;
+	struct obj_sta *sta;
+	union oid_res_t r;
+	int ret = 0;
+	
+	if (dwrq->length != sizeof(*iwmlme))
+		return -EINVAL;
+
+	iwmlme = (struct iw_mlme*)extra;
+
+	if (iwmlme->addr.sa_family != ARPHRD_ETHER)
+		return -EINVAL;
+
+	/* get STA/AP Id.
+	or the card will BROADCAST the mgmt packets! */
+
+	sta = (struct obj_sta*)kzalloc(sizeof(*sta), GFP_KERNEL);
+	if (!sta)
+		return -ENOMEM;
+
+	memcpy(sta->address, iwmlme->addr.sa_data, ETH_ALEN);
+	ret = mgt_get_request(priv, DOT11_OID_CLIENTFIND, 0, sta, &r);
+	kfree(sta); 
+
+	if (ret) {
+		sta = r.ptr;
+		memcpy(mlme.address, iwmlme->addr.sa_data, ETH_ALEN);
+	
+		if (sta->node >= 1)
+			mlme.id = sta->node; 
+		else
+			mlme.id = -1;
+	} else 
+		/* use broadcast id */
+		mlme.id = -1;
+
+	mlme.code = iwmlme->reason_code;
+
+	kfree(r.ptr);
+	switch (iwmlme->cmd) {
+	case IW_MLME_DEAUTH:
+		mlme.state = DOT11_STATE_NONE;
+		return mgt_set_request(priv, DOT11_OID_DEAUTHENTICATE,
+				       0, &mlme);
+		break;
+	case IW_MLME_DISASSOC:
+		mlme.state = DOT11_STATE_NONE;
+		return mgt_set_request(priv, DOT11_OID_DISASSOCIATE,
+				       0, &mlme);
+		break;
+#if 0
+	/* not in WEXT yet */
+	case IW_MLME_AUTH:
+		mlme.state = DOT11_STATE_AUTH;
+		return mgt_set_request(priv, DOT11_OID_AUTHENTICATE,
+				       0, &mlme);
+		break;
+	case IW_MLME_ASSOC:
+		mlme.state = DOT11_STATE_ASSOC;
+		return mgt_set_request(priv, DOT11_OID_ASSOCIATE,
+				       0, &mlme);
+		break;
+#endif
+	}
+	
+	return -EOPNOTSUPP;
+}
+
 static const iw_handler prism54_handler[] = {
 	(iw_handler) prism54_commit,	/* SIOCSIWCOMMIT */
 	(iw_handler) prism54_get_name,	/* SIOCGIWNAME */
@@ -3049,7 +2690,7 @@ static const iw_handler prism54_handler[
 	iw_handler_get_thrspy,	/* SIOCGIWTHRSPY */
 	(iw_handler) prism54_set_wap,	/* SIOCSIWAP */
 	(iw_handler) prism54_get_wap,	/* SIOCGIWAP */
-	(iw_handler) NULL,	/* -- hole -- */
+	(iw_handler) prism54_send_mlme,	/* SIOCSIWMLME */
 	(iw_handler) NULL,	/* SIOCGIWAPLIST depreciated */
 	(iw_handler) prism54_set_scan,	/* SIOCSIWSCAN */
 	(iw_handler) prism54_get_scan,	/* SIOCGIWSCAN */
@@ -3073,15 +2714,15 @@ static const iw_handler prism54_handler[
 	(iw_handler) prism54_get_encode,	/* SIOCGIWENCODE */
 	(iw_handler) NULL,	/* SIOCSIWPOWER */
 	(iw_handler) NULL,	/* SIOCGIWPOWER */
-	NULL,			/* -- hole -- */
-	NULL,			/* -- hole -- */
+	(iw_handler) NULL,	/* -- hole -- */
+	(iw_handler) NULL,	/* -- hole -- */
 	(iw_handler) prism54_set_genie,	/* SIOCSIWGENIE */
 	(iw_handler) prism54_get_genie,	/* SIOCGIWGENIE */
 	(iw_handler) prism54_set_auth,	/* SIOCSIWAUTH */
 	(iw_handler) prism54_get_auth,	/* SIOCGIWAUTH */
-	(iw_handler) prism54_set_encodeext, /* SIOCSIWENCODEEXT */
-	(iw_handler) prism54_get_encodeext, /* SIOCGIWENCODEEXT */
-	NULL,			/* SIOCSIWPMKSA */
+	(iw_handler) prism54_set_encodeext,	/* SIOCSIWENCODEEXT */
+	(iw_handler) prism54_get_encodeext,	/* SIOCGIWENCODEEXT */
+	(iw_handler) NULL			/* SIOCSIWPMKSA */
 };
 
 /* The low order bit identify a SET (0) or a GET (1) ioctl.  */
@@ -3260,14 +2901,5 @@ const struct iw_handler_def prism54_hand
 int
 prism54_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
 {
-	struct iwreq *wrq = (struct iwreq *) rq;
-	int ret = -1;
-	switch (cmd) {
-		case PRISM54_HOSTAPD:
-		if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-		ret = prism54_hostapd(ndev, &wrq->u.data);
-		return ret;
-	}
 	return -EOPNOTSUPP;
 }
diff -Nurp a/drivers/net/wireless/prism54/isl_ioctl.h b/drivers/net/wireless/prism54/isl_ioctl.h
--- a/drivers/net/wireless/prism54/isl_ioctl.h	2006-09-28 21:13:25.000000000 +0200
+++ b/drivers/net/wireless/prism54/isl_ioctl.h	2006-10-02 20:26:37.000000000 +0200
@@ -22,12 +22,11 @@
 #ifndef _ISL_IOCTL_H
 #define _ISL_IOCTL_H
 
+#include <net/iw_handler.h>	/* New driver API */
 #include "islpci_mgt.h"
 #include "islpci_dev.h"
 
-#include <net/iw_handler.h>	/* New driver API */
-
-#define SUPPORTED_WIRELESS_EXT                  19
+#define SUPPORTED_WIRELESS_EXT                  21
 
 void prism54_mib_init(islpci_private *);
 
@@ -48,4 +47,5 @@ int prism54_ioctl(struct net_device *, s
 
 extern const struct iw_handler_def prism54_handler_def;
 
+
 #endif				/* _ISL_IOCTL_H */
diff -Nurp a/drivers/net/wireless/prism54/isl_oid.h b/drivers/net/wireless/prism54/isl_oid.h
--- a/drivers/net/wireless/prism54/isl_oid.h	2006-09-20 05:42:06.000000000 +0200
+++ b/drivers/net/wireless/prism54/isl_oid.h	2006-10-03 14:26:22.000000000 +0200
@@ -4,6 +4,7 @@
  *  Copyright (C) 2003 Herbert Valerio Riedel <hvr@gnu.org>
  *  Copyright (C) 2004 Luis R. Rodriguez <mcgrof@ruslug.rutgers.edu>
  *  Copyright (C) 2004 Aurelien Alleaume <slts@free.fr>
+ *  Copyright (C) 2006 Christian Lamparter <chunkeey@web.de>
  *
  *  This program is free software; you can redistribute it and/or modify
  *  it under the terms of the GNU General Public License as published by
@@ -28,6 +29,8 @@
  * with the device firmware
  */
 
+#define MAX_KEY_LEN 32
+
 struct obj_ssid {
 	u8 length;
 	char octets[33];
@@ -36,18 +39,28 @@ struct obj_ssid {
 struct obj_key {
 	u8 type;		/* dot11_priv_t */
 	u8 length;
-	char key[32];
+	char key[MAX_KEY_LEN];
+} __attribute__ ((packed));
+
+struct obj_stakey {
+	u8 address[ETH_ALEN];
+	u8 keyid;
+	u8 reserved;
+	u16 options;	// dot11_stakey_opt_t
+	u8 type;		/* dot11_priv_t */
+	u8 length;
+	char key[MAX_KEY_LEN];
 } __attribute__ ((packed));
 
 struct obj_mlme {
-	u8 address[6];
+	u8 address[ETH_ALEN];
 	u16 id;
 	u16 state;
 	u16 code;
 } __attribute__ ((packed));
 
 struct obj_mlmeex {
-	u8 address[6];
+	u8 address[ETH_ALEN];
 	u16 id;
 	u16 state;
 	u16 code;
@@ -61,7 +74,7 @@ struct obj_buffer {
 } __attribute__ ((packed));
 
 struct obj_bss {
-	u8 address[6];
+	u8 address[ETH_ALEN];
 	int:16;			/* padding */
 
 	char state;
@@ -99,6 +112,25 @@ struct obj_attachment {
 	char data[0];
 } __attribute__((packed));
 
+struct obj_stasc {
+	char address[ETH_ALEN];
+	char keyid;
+	char tx_sc;
+	char sc[6];
+} __attribute__ ((packed));
+
+struct obj_sta {
+	u8 address[ETH_ALEN];
+	int: 16;
+	u8 state;
+	u8 node; // STA ID
+	u16 age;
+	u8 reserved1;
+	u8 rssi;
+	u8 rate;
+	u8 reserved2;
+} __attribute__ ((packed));
+
 /* 
  * in case everything's ok, the inlined function below will be
  * optimized away by the compiler...
@@ -114,6 +146,10 @@ __bug_on_wrong_struct_sizes(void)
 	BUG_ON(sizeof (struct obj_bss) != 60);
 	BUG_ON(sizeof (struct obj_bsslist) != 4);
 	BUG_ON(sizeof (struct obj_frequencies) != 2);
+	BUG_ON(sizeof (struct obj_sta) != 16);
+	BUG_ON(sizeof (struct obj_stasc) != 14);
+	BUG_ON(sizeof (struct obj_stakey) != 44);
+	BUG_ON(sizeof (struct obj_attachment) != 6);
 }
 
 enum dot11_state_t {
@@ -121,7 +157,7 @@ enum dot11_state_t {
 	DOT11_STATE_AUTHING = 1,
 	DOT11_STATE_AUTH = 2,
 	DOT11_STATE_ASSOCING = 3,
-
+	DOT11_STATE_REASSOC = 4,
 	DOT11_STATE_ASSOC = 5,
 	DOT11_STATE_IBSS = 6,
 	DOT11_STATE_WDS = 7
@@ -466,31 +502,32 @@ enum oid_num_t {
 	OID_NUM_LAST
 };
 
-#define OID_FLAG_CACHED		0x80
-#define OID_FLAG_TYPE		0x7f
-
-#define OID_TYPE_U32		0x01
-#define OID_TYPE_SSID		0x02
-#define OID_TYPE_KEY		0x03
-#define OID_TYPE_BUFFER		0x04
-#define OID_TYPE_BSS		0x05
-#define OID_TYPE_BSSLIST	0x06
-#define OID_TYPE_FREQUENCIES	0x07
-#define OID_TYPE_MLME		0x08
-#define OID_TYPE_MLMEEX		0x09
-#define OID_TYPE_ADDR		0x0A
-#define OID_TYPE_RAW		0x0B
-#define OID_TYPE_ATTACH		0x0C
+enum oid_types_t {
+	OID_TYPE_U32 = 0x01,
+	OID_TYPE_SSID = 0x02,
+	OID_TYPE_KEY = 0x03,
+	OID_TYPE_BUFFER = 0x04,
+	OID_TYPE_BSS = 0x05,
+	OID_TYPE_BSSLIST = 0x06,
+	OID_TYPE_FREQUENCIES = 0x07,
+	OID_TYPE_MLME = 0x08,
+	OID_TYPE_MLMEEX = 0x09,
+	OID_TYPE_ADDR = 0x0A,
+	OID_TYPE_RAW = 0x0B,
+	OID_TYPE_ATTACH = 0x0C,
+	OID_TYPE_STASC = 0x0D,
+	OID_TYPE_STAKEY = 0x0E,
+	OID_TYPE_STAINFO = 0x0F,
 
-/* OID_TYPE_MLMEEX is special because of a variable size field when sending.
- * Not yet implemented (not used in driver anyway).
- */
+	OID_FLAG_CACHED = 0x80,
+	OID_FLAG_TYPE = 0x7f
+};
 
 struct oid_t {
 	enum oid_num_t oid;
 	short range;		/* to define a range of oid */
 	short size;		/* max size of the associated data */
-	char flags;
+	enum oid_types_t flags;
 };
 
 union oid_res_t {
@@ -503,5 +540,19 @@ union oid_res_t {
 #define IWMAX_FREQ	30
 #define PRIV_STR_SIZE	1024
 
+enum dot11_pkt_t {
+	DOT11_PKT_ASSOC_REQ = 0x00,
+	DOT11_PKT_ASSOC_RESP = 0x10,
+	DOT11_PKT_REASSOC_REQ = 0x20,
+	DOT11_PKT_REASSOC_RESP = 0x30,
+	DOT11_PKT_PROBE_RESP = 0x50,
+	DOT11_PKT_BEACON = 0x80
+};
+
+enum dot11_stakey_opt_t {
+	DOT11_STAKEY_OPTION_GROUPKEY = 0x0000,
+	DOT11_STAKEY_OPTION_DEFAULTKEY = 0x0001
+};
+
 #endif				/* !defined(_ISL_OID_H) */
 /* EOF */
diff -Nurp a/drivers/net/wireless/prism54/islpci_dev.c b/drivers/net/wireless/prism54/islpci_dev.c
--- a/drivers/net/wireless/prism54/islpci_dev.c	2006-09-28 21:13:25.000000000 +0200
+++ b/drivers/net/wireless/prism54/islpci_dev.c	2006-09-28 23:42:47.000000000 +0200
@@ -453,6 +453,7 @@ islpci_upload_fw(islpci_private *priv)
 
 	printk(KERN_DEBUG "%s: uploading firmware...\n", priv->ndev->name);
 
+	request_module("firmware_class");
 	rc = isl_upload_firmware(priv);
 	if (rc) {
 		/* error uploading the firmware */
diff -Nurp a/drivers/net/wireless/prism54/islpci_hotplug.c b/drivers/net/wireless/prism54/islpci_hotplug.c
--- a/drivers/net/wireless/prism54/islpci_hotplug.c	2006-09-28 21:13:25.000000000 +0200
+++ b/drivers/net/wireless/prism54/islpci_hotplug.c	2006-10-03 12:41:59.000000000 +0200
@@ -171,7 +171,10 @@ prism54_probe(struct pci_dev *pdev, cons
 	pci_set_master(pdev);
 
 	/* enable MWI */
-	pci_set_mwi(pdev);
+	if (pci_set_mwi(pdev)) {
+		printk(KERN_ERR "%s: could not enabke MWI\n", DRV_NAME);
+		goto do_pci_release_regions;
+	}	
 
 	/* setup the network device interface and its structure */
 	if (!(ndev = islpci_setup(pdev))) {
@@ -290,7 +293,11 @@ prism54_resume(struct pci_dev *pdev)
 	islpci_private *priv = ndev ? netdev_priv(ndev) : NULL;
 	BUG_ON(!priv);
 
-	pci_enable_device(pdev);
+	// what can we do, if pci_enable_device fails?
+	if (pci_enable_device(pdev) < 0) {
+		printk(KERN_ERR "%s: pci_enable_device() failed.\n", DRV_NAME);
+		return -ENODEV;
+	}
 
 	printk(KERN_NOTICE "%s: got resume request\n", ndev->name);
 
diff -Nurp a/drivers/net/wireless/prism54/islpci_mgt.h b/drivers/net/wireless/prism54/islpci_mgt.h
--- a/drivers/net/wireless/prism54/islpci_mgt.h	2006-09-20 05:42:06.000000000 +0200
+++ b/drivers/net/wireless/prism54/islpci_mgt.h	2006-09-29 14:22:05.000000000 +0200
@@ -65,8 +65,8 @@ extern int pc_debug;
 #define CARD_DEFAULT_WEP                        0
 #define CARD_DEFAULT_FILTER                     0
 #define CARD_DEFAULT_WDS                        0
-#define	CARD_DEFAULT_AUTHEN                     DOT11_AUTH_OS
-#define	CARD_DEFAULT_DOT1X			0
+#define CARD_DEFAULT_AUTHEN                     DOT11_AUTH_OS
+#define CARD_DEFAULT_DOT1X			0
 #define CARD_DEFAULT_MLME_MODE			DOT11_MLME_AUTO
 #define CARD_DEFAULT_CONFORMANCE                OID_INL_CONFORMANCE_NONE
 #define CARD_DEFAULT_PROFILE			DOT11_PROFILE_MIXED_G_WIFI
diff -Nurp a/drivers/net/wireless/prism54/oid_mgt.c b/drivers/net/wireless/prism54/oid_mgt.c
--- a/drivers/net/wireless/prism54/oid_mgt.c	2006-09-20 05:42:06.000000000 +0200
+++ b/drivers/net/wireless/prism54/oid_mgt.c	2006-10-03 12:33:09.000000000 +0200
@@ -59,7 +59,7 @@ struct oid_t isl_oid[] = {
 	OID_UNKNOWN(GEN_OID_MIBOP, 0x00000003),
 	OID_UNKNOWN(GEN_OID_OPTIONS, 0x00000004),
 	OID_UNKNOWN(GEN_OID_LEDCONFIG, 0x00000005),
-
+	
 	/* 802.11 */
 	OID_U32_C(DOT11_OID_BSSTYPE, 0x10000000),
 	OID_STRUCT_C(DOT11_OID_BSSID, 0x10000001, u8[6], OID_TYPE_RAW),
@@ -85,9 +85,9 @@ struct oid_t isl_oid[] = {
 	OID_U32_C(DOT11_OID_DEFKEYID, 0x12000003),
 	[DOT11_OID_DEFKEYX] = {0x12000004, 3, sizeof (struct obj_key),
 			       OID_FLAG_CACHED | OID_TYPE_KEY},	/* DOT11_OID_DEFKEY1,...DOT11_OID_DEFKEY4 */
-	OID_UNKNOWN(DOT11_OID_STAKEY, 0x12000008),
+	OID_STRUCT(DOT11_OID_STAKEY, 0x12000008, struct obj_stakey, OID_TYPE_STAKEY),
 	OID_U32(DOT11_OID_REKEYTHRESHOLD, 0x12000009),
-	OID_UNKNOWN(DOT11_OID_STASC, 0x1200000a),
+	OID_STRUCT(DOT11_OID_STASC, 0x1200000a, struct obj_stasc, OID_TYPE_STASC),
 
 	OID_U32(DOT11_OID_PRIVTXREJECTED, 0x1a000000),
 	OID_U32(DOT11_OID_PRIVRXPLAIN, 0x1a000001),
@@ -122,9 +122,9 @@ struct oid_t isl_oid[] = {
 	OID_U32(DOT11_OID_BRIDGELOCAL, 0x15000000),
 	OID_U32(DOT11_OID_CLIENTS, 0x15000001),
 	OID_U32(DOT11_OID_CLIENTSASSOCIATED, 0x15000002),
-	[DOT11_OID_CLIENTX] = {0x15000003, 2006, 0, 0},	/* DOT11_OID_CLIENTX,...DOT11_OID_CLIENT2007 */
+	[DOT11_OID_CLIENTX] = {0x15000003, 2006, sizeof(struct obj_sta), OID_TYPE_STAINFO},	/* DOT11_OID_CLIENTX,...DOT11_OID_CLIENT2007 */
 
-	OID_STRUCT(DOT11_OID_CLIENTFIND, 0x150007DB, u8[6], OID_TYPE_ADDR),
+	OID_STRUCT(DOT11_OID_CLIENTFIND, 0x150007DB, struct obj_sta, OID_TYPE_STAINFO),
 	OID_STRUCT(DOT11_OID_WDSLINKADD, 0x150007DC, u8[6], OID_TYPE_ADDR),
 	OID_STRUCT(DOT11_OID_WDSLINKREMOVE, 0x150007DD, u8[6], OID_TYPE_ADDR),
 	OID_STRUCT(DOT11_OID_EAPAUTHSTA, 0x150007DE, u8[6], OID_TYPE_ADDR),
@@ -201,8 +201,7 @@ struct oid_t isl_oid[] = {
 	OID_U32(DOT11_OID_STATIMEOUT, 0x19000000),
 	OID_U32_C(DOT11_OID_MLMEAUTOLEVEL, 0x19000001),
 	OID_U32(DOT11_OID_BSSTIMEOUT, 0x19000002),
-	[DOT11_OID_ATTACHMENT] = {0x19000003, 0,
-		sizeof(struct obj_attachment), OID_TYPE_ATTACH},
+	OID_STRUCT_C(DOT11_OID_ATTACHMENT, 0x19000003, sizeof(struct obj_attachment), OID_TYPE_ATTACH),
 	OID_STRUCT_C(DOT11_OID_PSMBUFFER, 0x19000004, struct obj_buffer,
 		     OID_TYPE_BUFFER),
 
@@ -277,7 +276,7 @@ mgt_clean(islpci_private *priv)
 }
 
 void
-mgt_le_to_cpu(int type, void *data)
+mgt_le_to_cpu(enum oid_types_t type, void *data)
 {
 	switch (type) {
 	case OID_TYPE_U32:
@@ -334,19 +333,31 @@ mgt_le_to_cpu(int type, void *data)
 			attach->id = le16_to_cpu(attach->id);
 			attach->size = le16_to_cpu(attach->size);
 			break;
-	}
+		}
+	case OID_TYPE_STAKEY: {
+			struct obj_stakey *stakey = data;
+			stakey->options = le16_to_cpu(stakey->options);
+			break;
+		}
+	case OID_TYPE_STAINFO: {
+			struct obj_sta *sta = data;
+			sta->age = le16_to_cpu(sta->age);
+			break;
+		}
 	case OID_TYPE_SSID:
 	case OID_TYPE_KEY:
 	case OID_TYPE_ADDR:
 	case OID_TYPE_RAW:
+	case OID_TYPE_STASC:
 		break;
 	default:
 		BUG();
+		break;
 	}
 }
 
 static void
-mgt_cpu_to_le(int type, void *data)
+mgt_cpu_to_le(enum oid_types_t type, void *data)
 {
 	switch (type) {
 	case OID_TYPE_U32:
@@ -403,14 +414,26 @@ mgt_cpu_to_le(int type, void *data)
 			attach->id = cpu_to_le16(attach->id);
 			attach->size = cpu_to_le16(attach->size);
 			break;
-	}
+		}
+	case OID_TYPE_STAKEY: {
+			struct obj_stakey *stakey = data;
+			stakey->options = cpu_to_le16(stakey->options);
+			break;
+		}
+	case OID_TYPE_STAINFO: {
+			struct obj_sta *sta = data;
+			sta->age = cpu_to_le16(sta->age);
+			break;
+		}
 	case OID_TYPE_SSID:
 	case OID_TYPE_KEY:
 	case OID_TYPE_ADDR:
 	case OID_TYPE_RAW:
+	case OID_TYPE_STASC:
 		break;
 	default:
 		BUG();
+		break;
 	}
 }
 
@@ -658,13 +681,16 @@ static enum oid_num_t commit_part1[] = {
 
 static enum oid_num_t commit_part2[] = {
 	DOT11_OID_SSID,
+	/* unstable with WPA
 	DOT11_OID_PSMBUFFER,
+	*/
 	DOT11_OID_AUTHENABLE,
 	DOT11_OID_PRIVACYINVOKED,
 	DOT11_OID_EXUNENCRYPTED,
 	DOT11_OID_DEFKEYX,	/* MULTIPLE */
 	DOT11_OID_DEFKEYID,
 	DOT11_OID_DOT1XENABLE,
+	DOT11_OID_ATTACHMENT,
 	OID_INL_DOT11D_CONFORMANCE,
 	/* Do not initialize this - fw < 1.0.4.3 rejects it
 	OID_INL_OUTPUTPOWER,
diff -Nurp a/drivers/net/wireless/prism54/oid_mgt.h b/drivers/net/wireless/prism54/oid_mgt.h
--- a/drivers/net/wireless/prism54/oid_mgt.h	2006-09-20 05:42:06.000000000 +0200
+++ b/drivers/net/wireless/prism54/oid_mgt.h	2006-09-29 20:25:17.000000000 +0200
@@ -32,7 +32,7 @@ void mgt_clean(islpci_private *);
 extern const int frequency_list_a[];
 int channel_of_freq(int);
 
-void mgt_le_to_cpu(int, void *);
+void mgt_le_to_cpu(enum oid_types_t, void *);
 
 int mgt_set_request(islpci_private *, enum oid_num_t, int, void *);
 int mgt_set_varlen(islpci_private *, enum oid_num_t, void *, int);

--Boundary-00=_94lIF1mPqEAm6x9--
