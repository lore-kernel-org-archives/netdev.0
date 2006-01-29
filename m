From: Carlos =?utf-8?q?Mart=C3=ADn?= <carlos@cmartin.tk>
Subject: [PATH] acxsm: Move WEP code into softmac
Date: Sun, 29 Jan 2006 15:26:04 +0100
Message-ID: <200601291526.09333.carlos@cmartin.tk>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart24755635.70YmUoZoj8";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: acx100-devel@lists.sourceforge.net
Sender: acx100-devel-admin@lists.sourceforge.net
Errors-To: acx100-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:acx100-devel@lists.sourceforge.net>
List-Help: <mailto:acx100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=acx100-devel>
List-Id: netdev.vger.kernel.org

--nextPart24755635.70YmUoZoj8
Content-Type: multipart/mixed;
  boundary="Boundary-01=_8BN3DM5LeY3Wk76"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

--Boundary-01=_8BN3DM5LeY3Wk76
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi,

 This patch moves the WEP handling code to use the softmac layer and=20
implements acx_e_ieee80211_set_security(), based on the rt2x00 project's on=
e.

 I do have a couple of questions though:

1) adev->wep_restricted =3D 0 is the same as an open auth system, and=20
adev->wep_restricted =3D 1 is the same as having a shared key auth system,=
=20
right?

2) What is the purpose of the index field in key_struct_t? I've assumed it =
is=20
the same as adev->wep_current_index, but I'm not sure this is correct.

   cmn
=2D-=20
Carlos Mart=C3=ADn       http://www.cmartin.tk

"Erdbeben? Sicherlich etwas, das mit Erdberen zu tun hat." -- me, paraphras=
ed

--Boundary-01=_8BN3DM5LeY3Wk76
Content-Type: text/x-diff;
  charset="utf-8";
  name="acxsm-move-wep-into-softmac.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline;
	filename="acxsm-move-wep-into-softmac.patch"

diff -urp acxsm-0123.orig/acx_struct.h acxsm-0123/acx_struct.h
=2D-- acxsm-0123.orig/acx_struct.h	2006-01-16 15:25:41.000000000 +0100
+++ acxsm-0123/acx_struct.h	2006-01-29 14:06:17.000000000 +0100
@@ -603,31 +603,6 @@ typedef struct fw_ver {
=20
 #define FW_ID_SIZE 20
=20
=2D
=2D/*--- WEP stuff --------------------------------------------------------=
=2D-----*/
=2D#define DOT11_MAX_DEFAULT_WEP_KEYS	4
=2D
=2D/* non-firmware struct, no packing necessary */
=2Dtypedef struct wep_key {
=2D	size_t	size; /* most often used member first */
=2D	u8	index;
=2D	u8	key[29];
=2D	u16	strange_filler;
=2D} wep_key_t;			/* size =3D 264 bytes (33*8) */
=2D/* FIXME: We don't have size 264! Or is there 2 bytes beyond the key
=2D * (strange_filler)? */
=2D
=2D/* non-firmware struct, no packing necessary */
=2Dtypedef struct key_struct {
=2D	u8	addr[ETH_ALEN];	/* 0x00 */
=2D	u16	filler1;	/* 0x06 */
=2D	u32	filler2;	/* 0x08 */
=2D	u32	index;		/* 0x0c */
=2D	u16	len;		/* 0x10 */
=2D	u8	key[29];	/* 0x12; is this long enough??? */
=2D} key_struct_t;			/* size =3D 276. FIXME: where is the remaining space??=
 */
=2D
=2D
 /*--- Client (peer) info -------------------------------------------------=
=2D---*/
 /* adev->sta_list[] is used for:
 ** accumulating and processing of scan results
@@ -1286,14 +1261,6 @@ struct acx_device {
 	u8		rate_supported_len;
 	u8		rate_supported[13];
=20
=2D	/*** Encryption settings (WEP) ***/
=2D	u32		auth_alg;		/* used in transmit_authen1 */
=2D	u8		wep_enabled;
=2D	u8		wep_restricted;
=2D	u8		wep_current_index;
=2D	wep_key_t	wep_keys[DOT11_MAX_DEFAULT_WEP_KEYS];	/* the default WEP keys=
 */
=2D	key_struct_t	wep_key_struct[10];
=2D
 	/*** Unknown ***/
 	u8		dtim_interval;
=20
diff -urp acxsm-0123.orig/common.c acxsm-0123/common.c
=2D-- acxsm-0123.orig/common.c	2006-01-19 11:28:23.000000000 +0100
+++ acxsm-0123/common.c	2006-01-29 14:59:46.000000000 +0100
@@ -1137,8 +1137,8 @@ acx_s_proc_diag_output(char *buf, acx_de
 		"WEP ena %d, restricted %d, idx %d\n",
 		adev->essid, adev->essid_active, (int)adev->essid_len,
 		adev->essid_for_assoc, adev->nick,
=2D		adev->wep_enabled, adev->wep_restricted,
=2D		adev->wep_current_index);
+		adev->ieee->sec.enabled, adev->ieee->sec.auth_mode,
+		adev->ieee->sec.active_key);
 	p +=3D sprintf(p, "dev_addr  "MACSTR"\n", MAC(adev->dev_addr));
 	p +=3D sprintf(p, "bssid     "MACSTR"\n", MAC(adev->bssid));
 	p +=3D sprintf(p, "ap_filter "MACSTR"\n", MAC(adev->ap));
@@ -2143,7 +2143,7 @@ acx_s_set_defaults(acx_device_t *adev)
 	/* reported to break scanning: adev->scan_probe_delay =3D adev->cfgopt_pr=
obe_delay; */
 	adev->scan_rate =3D ACX_SCAN_RATE_1;
=20
=2D	adev->auth_alg =3D WLAN_AUTH_ALG_OPENSYSTEM;
+	adev->ieee->sec.auth_mode =3D WLAN_AUTH_OPEN;
 	adev->preamble_mode =3D 2; /* auto */
 	adev->listen_interval =3D 100;
 	adev->beacon_interval =3D DEFAULT_BEACON_INTERVAL;
@@ -5435,14 +5435,14 @@ acx100_s_set_wepkey(acx_device_t *adev)
 	ie_dot11WEPDefaultKey_t dk;
 	int i;
=20
=2D	for (i =3D 0; i < DOT11_MAX_DEFAULT_WEP_KEYS; i++) {
=2D		if (adev->wep_keys[i].size !=3D 0) {
+	for (i =3D 0; i < WEP_KEYS; i++) {
+		if (adev->ieee->sec.key_sizes[i] !=3D 0) {
 			log(L_INIT, "setting WEP key: %d with "
=2D				"total size: %d\n", i, (int) adev->wep_keys[i].size);
+				"total size: %d\n", i, (int) adev->ieee->sec.key_sizes[i]);
 			dk.action =3D 1;
=2D			dk.keySize =3D adev->wep_keys[i].size;
+			dk.keySize =3D adev->ieee->sec.key_sizes[i];
 			dk.defaultKeyNum =3D i;
=2D			memcpy(dk.key, adev->wep_keys[i].key, dk.keySize);
+			memcpy(dk.key, adev->ieee->sec.keys[i], dk.keySize);
 			acx_s_configure(adev, &dk, ACX100_IE_DOT11_WEP_DEFAULT_KEY_WRITE);
 		}
 	}
@@ -5454,20 +5454,20 @@ acx111_s_set_wepkey(acx_device_t *adev)
 	acx111WEPDefaultKey_t dk;
 	int i;
=20
=2D	for (i =3D 0; i < DOT11_MAX_DEFAULT_WEP_KEYS; i++) {
=2D		if (adev->wep_keys[i].size !=3D 0) {
+	for (i =3D 0; i < WEP_KEYS; i++) {
+		if (adev->ieee->sec.key_sizes[i] !=3D 0) {
 			log(L_INIT, "setting WEP key: %d with "
=2D				"total size: %d\n", i, (int) adev->wep_keys[i].size);
+				"total size: %d\n", i, (int) adev->ieee->sec.key_sizes[i]);
 			memset(&dk, 0, sizeof(dk));
 			dk.action =3D cpu_to_le16(1); /* "add key"; yes, that's a 16bit value */
=2D			dk.keySize =3D adev->wep_keys[i].size;
+			dk.keySize =3D adev->ieee->sec.key_sizes[i];
=20
 			/* are these two lines necessary? */
 			dk.type =3D 0;              /* default WEP key */
 			dk.index =3D 0;             /* ignored when setting default key */
=20
 			dk.defaultKeyNum =3D i;
=2D			memcpy(dk.key, adev->wep_keys[i].key, dk.keySize);
+			memcpy(dk.key, adev->ieee->sec.keys[i], dk.keySize);
 			acx_s_issue_cmd(adev, ACX1xx_CMD_WEP_MGMT, &dk, sizeof(dk));
 		}
 	}
@@ -5514,7 +5514,7 @@ acx100_s_init_wep(acx_device_t *adev)
 	}
=20
 	/* let's choose maximum setting: 4 default keys, plus 10 other keys: */
=2D	options.NumKeys =3D cpu_to_le16(DOT11_MAX_DEFAULT_WEP_KEYS + 10);
+	options.NumKeys =3D cpu_to_le16(WEP_KEYS + 10);
 	options.WEPOption =3D 0x00;
=20
 	log(L_ASSOC, "%s: writing WEP options\n", __func__);
@@ -5522,10 +5522,10 @@ acx100_s_init_wep(acx_device_t *adev)
=20
 	acx100_s_set_wepkey(adev);
=20
=2D	if (adev->wep_keys[adev->wep_current_index].size !=3D 0) {
+	if (adev->ieee->sec.key_sizes[adev->ieee->sec.active_key] !=3D 0) {
 		log(L_ASSOC, "setting active default WEP key number: %d\n",
=2D				adev->wep_current_index);
=2D		dk.KeyID =3D adev->wep_current_index;
+				adev->ieee->sec.active_key);
+		dk.KeyID =3D adev->ieee->sec.active_key;
 		acx_s_configure(adev, &dk, ACX1xx_IE_DOT11_WEP_DEFAULT_KEY_SET); /* 0x10=
10 */
 	}
 	/* FIXME!!! wep_key_struct is filled nowhere! But adev
@@ -6581,7 +6581,7 @@ acx_s_update_card_settings(acx_device_t=20
=20
 		acx_s_set_wepkey(adev);
=20
=2D		dkey.KeyID =3D adev->wep_current_index;
+		dkey.KeyID =3D adev->ieee->sec.active_key;
 		log(L_INIT, "setting WEP key %u as default\n", dkey.KeyID);
 		acx_s_configure(adev, &dkey, ACX1xx_IE_DOT11_WEP_DEFAULT_KEY_SET);
 #ifdef DEBUG_WEP
@@ -6602,7 +6602,7 @@ acx_s_update_card_settings(acx_device_t=20
=20
 			/* let's choose maximum setting: 4 default keys,
 			 * plus 10 other keys: */
=2D			options.NumKeys =3D cpu_to_le16(DOT11_MAX_DEFAULT_WEP_KEYS + 10);
+			options.NumKeys =3D cpu_to_le16(WEP_KEYS + 10);
 			/* don't decrypt default key only,
 			 * don't override decryption: */
 			options.WEPOption =3D 0;
@@ -6905,7 +6905,7 @@ acx_update_capabilities(acx_device_t *ad
 	/* other types of stations do not emit beacons */
 	}
=20
=2D	if (adev->wep_restricted) {
+	if (adev->ieee->sec.auth_mode =3D=3D WLAN_AUTH_SHARED_KEY) {
 		SET_BIT(cap, WF_MGMT_CAP_PRIVACY);
 	}
 	if (adev->cfgopt_dot11ShortPreambleOption) {
@@ -7135,10 +7135,74 @@ module_exit(acx_e_cleanup_module)
=20
 //SM
 void
=2Dacx_e_ieee80211_set_security(struct net_device *dev,
+acx_e_ieee80211_set_security(struct net_device *ndev,
 		struct ieee80211_security *sec)
 {
=2D//todo
+/* Shamelessly copied from the rt2x00 project. */
+	acx_device_t *adev =3D ndev2adev(ndev);
+	unsigned long flags;
+	int i;
+
+	acx_sem_lock(adev);
+	acx_lock(adev, flags);
+
+	for (i =3D 0; i < WEP_KEYS; ++i) {
+		/* This gives us the flag for the 4 WEP keys. */
+		if (sec->flags & (1 << i)) {
+			adev->ieee->sec.encode_alg[i] =3D sec->encode_alg[i];
+			adev->ieee->sec.key_sizes[i] =3D sec->key_sizes[i];
+
+			if (sec->key_sizes[i] !=3D 0) {
+				memcpy(adev->ieee->sec.keys[i], sec->keys[i],
+				       sec->key_sizes[i]);
+				/* Make sure WEP flag is set. */
+				adev->ieee->sec.flags |=3D (1 << i);
+			} else if (sec->level !=3D SEC_LEVEL_1)
+				/* Make sure WEP flag isn't set. */
+				adev->ieee->sec.flags &=3D ~(1 << i);
+		}
+		SET_BIT(adev->set_mask, SET_WEP_OPTIONS);
+	}
+
+	if (sec->flags & SEC_ACTIVE_KEY) {
+		/* Check the key number is valid. */
+		if (sec->active_key < WEP_KEYS) {
+			adev->ieee->sec.active_key =3D sec->active_key;
+			adev->ieee->sec.flags |=3D SEC_ACTIVE_KEY;
+		} else
+			adev->ieee->sec.flags &=3D ~SEC_ACTIVE_KEY;
+	=09
+	} else
+		adev->ieee->sec.flags &=3D ~SEC_ACTIVE_KEY;
+
+	if (sec->flags & SEC_AUTH_MODE) {
+		adev->ieee->sec.auth_mode =3D sec->auth_mode;
+		adev->ieee->sec.flags |=3D SEC_AUTH_MODE;
+		SET_BIT(adev->set_mask, SET_WEP_OPTIONS);
+	}
+
+	if (sec->flags & SEC_ENCRYPT) {
+		adev->ieee->sec.encrypt =3D sec->encrypt;
+		adev->ieee->sec.flags |=3D SEC_ENCRYPT;
+		SET_BIT(adev->set_mask, GETSET_WEP);
+	}
+
+	if (sec->flags & SEC_ENABLED) {
+		adev->ieee->sec.enabled =3D sec->enabled;
+		adev->ieee->sec.flags |=3D SEC_ENABLED;
+		SET_BIT(adev->set_mask, GETSET_WEP);
+	}
+
+	if (sec->flags & SEC_LEVEL) {
+		adev->ieee->sec.level =3D sec->level;
+		adev->ieee->sec.flags |=3D SEC_LEVEL;
+		SET_BIT(adev->set_mask, GETSET_WEP);
+	}
+=09
+	acx_unlock(adev, flags);
+	acx_sem_unlock(adev);
+
+	acx_s_update_card_settings(adev);
 }
=20
=20
diff -urp acxsm-0123.orig/ioctl.c acxsm-0123/ioctl.c
=2D-- acxsm-0123.orig/ioctl.c	2006-01-16 15:25:41.000000000 +0100
+++ acxsm-0123/ioctl.c	2006-01-29 14:07:08.000000000 +0100
@@ -1024,7 +1024,7 @@ acx_ioctl_set_encode(
 	if (dwrq->length > 0) {
 		/* if index is 0 or invalid, use default key */
 		if ((index < 0) || (index > 3))
=2D			index =3D (int)adev->wep_current_index;
+			index =3D (int)adev->ieee->sec.active_key;
=20
 		if (0 =3D=3D (dwrq->flags & IW_ENCODE_NOKEY)) {
 			if (dwrq->length > 29)
@@ -1032,26 +1032,26 @@ acx_ioctl_set_encode(
=20
 			if (dwrq->length > 13) {
 				/* 29*8 =3D=3D 232, WEP256 */
=2D				adev->wep_keys[index].size =3D 29;
+				adev->ieee->sec.key_sizes[index] =3D 29;
 			} else if (dwrq->length > 5) {
 				/* 13*8 =3D=3D 104bit, WEP128 */
=2D				adev->wep_keys[index].size =3D 13;
+				adev->ieee->sec.key_sizes[index] =3D 13;
 			} else if (dwrq->length > 0) {
 				/* 5*8 =3D=3D 40bit, WEP64 */
=2D				adev->wep_keys[index].size =3D 5;
+				adev->ieee->sec.key_sizes[index] =3D 5;
 			} else {
 				/* disable key */
=2D				adev->wep_keys[index].size =3D 0;
+				adev->ieee->sec.key_sizes[index] =3D 0;
 			}
=20
=2D			memset(adev->wep_keys[index].key, 0,
=2D				sizeof(adev->wep_keys[index].key));
=2D			memcpy(adev->wep_keys[index].key, extra, dwrq->length);
+			memset(adev->ieee->sec.keys[index], 0,
+				sizeof(adev->ieee->sec.keys[index]));
+			memcpy(adev->ieee->sec.keys[index], extra, dwrq->length);
 		}
 	} else {
 		/* set transmit key */
 		if ((index >=3D 0) && (index <=3D 3))
=2D			adev->wep_current_index =3D index;
+			adev->ieee->sec.active_key =3D index;
 		else if (0 =3D=3D (dwrq->flags & IW_ENCODE_MODE)) {
 			/* complain if we were not just setting
 			 * the key mode */
@@ -1060,15 +1060,13 @@ acx_ioctl_set_encode(
 		}
 	}
=20
=2D	adev->wep_enabled =3D !(dwrq->flags & IW_ENCODE_DISABLED);
+	adev->ieee->sec.enabled =3D !(dwrq->flags & IW_ENCODE_DISABLED);
=20
 	if (dwrq->flags & IW_ENCODE_OPEN) {
=2D		adev->auth_alg =3D WLAN_AUTH_ALG_OPENSYSTEM;
=2D		adev->wep_restricted =3D 0;
+		adev->ieee->sec.auth_mode =3D WLAN_AUTH_OPEN;
=20
 	} else if (dwrq->flags & IW_ENCODE_RESTRICTED) {
=2D		adev->auth_alg =3D WLAN_AUTH_ALG_SHAREDKEY;
=2D		adev->wep_restricted =3D 1;
+	  adev->ieee->sec.auth_mode =3D WLAN_AUTH_SHARED_KEY;
 	}
=20
 	/* set flag to make sure the card WEP settings get updated */
@@ -1078,11 +1076,11 @@ acx_ioctl_set_encode(
 		dwrq->length, extra, dwrq->flags);
=20
 	for (index =3D 0; index <=3D 3; index++) {
=2D		if (adev->wep_keys[index].size) {
+		if (adev->ieee->sec.key_sizes[index]) {
 			log(L_IOCTL,	"index=3D%d, size=3D%d, key at 0x%p\n",
=2D				adev->wep_keys[index].index,
=2D				(int) adev->wep_keys[index].size,
=2D				adev->wep_keys[index].key);
+				adev->ieee->sec.active_key,
+				(int) adev->ieee->sec.key_sizes[index],
+				adev->ieee->sec.keys[index]);
 		}
 	}
 	result =3D -EINPROGRESS;
@@ -1111,18 +1109,18 @@ acx_ioctl_get_encode(
=20
 	FN_ENTER;
=20
=2D	if (adev->wep_enabled =3D=3D 0) {
+	if (adev->ieee->sec.enabled =3D=3D 0) {
 		dwrq->flags =3D IW_ENCODE_DISABLED;
 	} else {
 		if ((index < 0) || (index > 3))
=2D			index =3D (int)adev->wep_current_index;
+			index =3D (int)adev->ieee->sec.active_key;
=20
=2D		dwrq->flags =3D (adev->wep_restricted =3D=3D 1) ?
+		dwrq->flags =3D (adev->ieee->sec.auth_mode =3D=3D WLAN_AUTH_SHARED_KEY) ?
 				IW_ENCODE_RESTRICTED : IW_ENCODE_OPEN;
=2D		dwrq->length =3D adev->wep_keys[index].size;
+		dwrq->length =3D adev->ieee->sec.key_sizes[index];
=20
=2D		memcpy(extra, adev->wep_keys[index].key,
=2D			      adev->wep_keys[index].size);
+		memcpy(extra, adev->ieee->sec.keys[index],
+			      adev->ieee->sec.key_sizes[index]);
 	}
=20
 	/* set the current index */
diff -urp acxsm-0123.orig/pci.c acxsm-0123/pci.c
=2D-- acxsm-0123.orig/pci.c	2006-01-22 16:48:35.000000000 +0100
+++ acxsm-0123/pci.c	2006-01-29 15:23:51.000000000 +0100
@@ -1641,6 +1641,10 @@ acxpci_e_probe(struct pci_dev *pdev, con
 	adev->softmac =3D ieee80211_priv(ndev);
 	adev->softmac->set_channel =3D acx_e_ieee80211_set_chan;
=20
+	adev->ieee->sec.encrypt =3D 0;
+	adev->ieee->sec.enabled =3D 0;
+	adev->ieee->sec.auth_mode =3D WLAN_AUTH_OPEN;
+
 #ifdef NONESSENTIAL_FEATURES
 	acx_show_card_eeprom_id(adev);
 #endif /* NONESSENTIAL_FEATURES */
diff -urp acxsm-0123.orig/usb.c acxsm-0123/usb.c
=2D-- acxsm-0123.orig/usb.c	2006-01-15 23:55:25.000000000 +0100
+++ acxsm-0123/usb.c	2006-01-28 20:59:40.000000000 +0100
@@ -677,6 +677,10 @@ acxusb_e_probe(struct usb_interface *int
 	adev->softmac =3D ieee80211_priv(ndev);
 	adev->softmac->set_channel =3D acx_e_ieee80211_set_chan;
=20
+	adev->ieee->sec.enabled =3D 0;
+	adev->ieee->sec.encrypt =3D 0;
+	adev->ieee->sec.auth_mode =3D WLAN_AUTH_OPEN;
+
 	/* Check that this is really the hardware we know about.
 	** If not sure, at least notify the user that he
 	** may be in trouble...

--Boundary-01=_8BN3DM5LeY3Wk76--

--nextPart24755635.70YmUoZoj8
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBD3NCBEVXxXOiy6a4RAgX6AKCmV2A5LPIaAus8kPjVvVIcCV+UtgCcDFhu
m5PSt0m9YKEYB3vkTdVQhEs=
=H86e
-----END PGP SIGNATURE-----

--nextPart24755635.70YmUoZoj8--


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
