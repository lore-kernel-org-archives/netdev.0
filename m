From: mcgrof@ruslug.rutgers.edu (Luis R. Rodriguez)
Subject: Re: [PATCH] wpa_supplicant: update driver_prism54.c
Date: Thu, 19 Aug 2004 20:10:48 -0400
Sender: prism54-devel-bounces@prism54.org
Message-ID: <20040820001048.GE6044@ruslug.rutgers.edu>
References: <20040819232720.GD6044@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1617587924=="
Return-path: <prism54-devel-bounces@prism54.org>
To: Jouni Malinen <jkmaline@cc.hut.fi>, hostap <hostap@shmoo.com>,
	prism54-devel@prism54.org, Jeff Garzik <jgarzik@pobox.com>,
	Netdev <netdev@oss.sgi.com>
In-Reply-To: <20040819232720.GD6044@ruslug.rutgers.edu>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Mime-version: 1.0
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org


--===============1617587924==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="DITGHUV3p5DjDsXt"
Content-Disposition: inline


--DITGHUV3p5DjDsXt
Content-Type: multipart/mixed; boundary="7VkxxUl3xUvPtoxk"
Content-Disposition: inline


--7VkxxUl3xUvPtoxk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


Oh yea-- the patch ;)

	Luis

On Thu, Aug 19, 2004 at 07:27:20PM -0400, Luis R. Rodriguez wrote:
>=20
> Jouni,
>=20
> the attached patch adds some startup work for wpa_supplicant support for
> prism54. I just integrated some work for wpa_supplicant support into
> prism54 CVS and sumbitted to Jeff for inclusion in 2.6 and 2.4. This
> work is not yet complete but should get the ball rolling for us to
> complete it.
>=20
> People wishing to help advance this work should check out prism54 CVS
> and use the attached patch for wpa_supplicant.
>=20
> Thanks,
>=20
> 	Luis
>=20
> --=20
> GnuPG Key fingerprint =3D 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 5=
25E



> _______________________________________________
> HostAP mailing list
> HostAP@shmoo.com
> http://lists.shmoo.com/mailman/listinfo/hostap


--=20
GnuPG Key fingerprint =3D 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E

--7VkxxUl3xUvPtoxk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="prism54-wpa_supplicant.diff"
Content-Transfer-Encoding: quoted-printable

--- wpa_supplicant/driver_prism54.c.orig	Thu Aug 19 19:16:50 2004
+++ wpa_supplicant/driver_prism54.c	Thu Aug 19 19:20:47 2004
@@ -1,6 +1,7 @@
 /*
  * WPA Supplicant - driver interaction with Linux Prism54.org driver
  * Copyright (c) 2003-2004, Jouni Malinen <jkmaline@cc.hut.fi>
+ * Copyright (c) 2004, Luis R. Rodriguez <mcgrof@ruslug.rutgers.edu>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -23,25 +24,175 @@
 #include "common.h"
 #include "driver.h"
 #include "driver_wext.h"
+#include "hostap_common.h"
 #include "wpa_supplicant.h"
=20
=20
-static int wpa_driver_prism54_set_wpa(const char *ifname, int enabled)
+#define PRISM54_SET_WPA    		SIOCIWFIRSTPRIV+12
+#define PRISM54_HOSTAPD    		SIOCIWFIRSTPRIV+25
+#define PRISM54_DROP_UNENCRYPTED	SIOCIWFIRSTPRIV+26
+
+static int hostapd_ioctl_prism54(const char *, struct prism2_hostapd_param=
 *, int, int);
+static void show_set_key_error(struct prism2_hostapd_param *);
+
+static int hostapd_ioctl_prism54(const char *dev,
+				 struct prism2_hostapd_param *param,
+				 int len, int show_err)
 {
-	/* FIX */
-	printf("wpa_driver_prism54_set_wpa - not yet implemented\n");
+	int s;
+	struct iwreq iwr;
+
+	s =3D socket(PF_INET, SOCK_DGRAM, 0);
+	if (s < 0) {
+		perror("socket");
+		return -1;
+	}
+
+	memset(&iwr, 0, sizeof(iwr));
+	strncpy(iwr.ifr_name, dev, IFNAMSIZ);
+	iwr.u.data.pointer =3D (caddr_t) param;
+	iwr.u.data.length =3D len;
+
+	if (ioctl(s, PRISM54_HOSTAPD, &iwr) < 0) {
+		int ret;
+		close(s);
+		ret =3D errno;
+		if (show_err)=20
+			perror("ioctl[PRISM54_HOSTAPD]");
+		return ret;
+	}
+	close(s);
+
 	return 0;
 }
=20
=20
+static int wpa_driver_prism54_set_wpa_ie(const char *ifname,
+					 const char *wpa_ie,
+					 size_t wpa_ie_len)
+{
+	struct prism2_hostapd_param *param;
+	int res;
+	size_t blen =3D PRISM2_HOSTAPD_GENERIC_ELEMENT_HDR_LEN + wpa_ie_len;
+	if (blen < sizeof(*param))
+		blen =3D sizeof(*param);
+
+	param =3D (struct prism2_hostapd_param *) malloc(blen);
+	if (param =3D=3D NULL)
+		return -1;
+=09
+	memset(param, 0, blen);
+	param->cmd =3D PRISM2_HOSTAPD_SET_GENERIC_ELEMENT;
+	param->u.generic_elem.len =3D wpa_ie_len;
+	memcpy(param->u.generic_elem.data, wpa_ie, wpa_ie_len);
+	res =3D hostapd_ioctl_prism54(ifname, param, blen, 1);
+
+	free(param);
+
+	return res;
+}
+
+
+/* This is called at wpa_supplicant daemon init time */
+static int wpa_driver_prism54_set_wpa(const char *ifname, int enabled)
+{
+	struct prism2_hostapd_param *param;
+	int res;
+	size_t blen =3D PRISM2_HOSTAPD_GENERIC_ELEMENT_HDR_LEN;
+	if (blen < sizeof(*param))
+		blen =3D sizeof(*param);
+
+	param =3D (struct prism2_hostapd_param *) malloc(blen);
+	if (param =3D=3D NULL)
+		return -1;
+
+	memset(param, 0, blen);
+	param->cmd =3D PRISM54_SET_WPA;
+	param->u.generic_elem.len =3D 0;
+	res =3D hostapd_ioctl_prism54(ifname, param, blen, 1);
+
+	free(param);
+
+	return res;
+}
+
+
 static int wpa_driver_prism54_set_key(const char *ifname, wpa_alg alg,
 				      unsigned char *addr, int key_idx,
 				      int set_tx, u8 *seq, size_t seq_len,
 				      u8 *key, size_t key_len)
 {
-	/* FIX */
-	printf("wpa_driver_prism54_set_key - not yet implemented\n");
-	return 0;
+	struct prism2_hostapd_param *param;
+	u8 *buf;
+	size_t blen;
+	int ret =3D 0;
+	char *alg_name;
+
+	switch (alg) {
+	case WPA_ALG_NONE:
+		alg_name =3D "none";
+		return -1;
+		break;
+	case WPA_ALG_WEP:
+		alg_name =3D "WEP";
+		return -1;
+		break;
+	case WPA_ALG_TKIP:
+		alg_name =3D "TKIP";
+		break;
+	case WPA_ALG_CCMP:
+		alg_name =3D "CCMP";
+		return -1;
+		break;
+	default:
+		return -1;
+	}
+
+	wpa_printf(MSG_DEBUG, "%s: alg=3D%s key_idx=3D%d set_tx=3D%d seq_len=3D%d=
 "
+		   "key_len=3D%d", __FUNCTION__, alg_name, key_idx, set_tx,
+		   seq_len, key_len);
+
+	if (seq_len > 8)
+		return -2;
+
+	blen =3D sizeof(*param) + key_len;
+	buf =3D malloc(blen);
+	if (buf =3D=3D NULL)
+		return -1;
+	memset(buf, 0, blen);
+
+	param =3D (struct prism2_hostapd_param *) buf;
+	param->cmd =3D PRISM2_SET_ENCRYPTION;
+	/* TODO: In theory, STA in client mode can use five keys; four default
+	 * keys for receiving (with keyidx 0..3) and one individual key for
+	 * both transmitting and receiving (keyidx 0) _unicast_ packets. Now,
+	 * keyidx 0 is reserved for this unicast use and default keys can only
+	 * use keyidx 1..3 (i.e., default key with keyidx 0 is not supported).
+	 * This should be fine for more or less all cases, but for completeness
+	 * sake, the driver could be enhanced to support the missing key. */
+#if 0
+	if (addr =3D=3D NULL)
+		memset(param->sta_addr, 0xff, ETH_ALEN);
+	else
+		memcpy(param->sta_addr, addr, ETH_ALEN);
+#else
+	memset(param->sta_addr, 0xff, ETH_ALEN);
+#endif
+	strncpy(param->u.crypt.alg, alg_name, HOSTAP_CRYPT_ALG_NAME_LEN);
+	param->u.crypt.flags =3D set_tx ? HOSTAP_CRYPT_FLAG_SET_TX_KEY : 0;
+	param->u.crypt.idx =3D key_idx;
+	memcpy(param->u.crypt.seq, seq, seq_len);
+	param->u.crypt.key_len =3D key_len;
+	memcpy((u8 *) (param + 1), key, key_len);
+
+	if (hostapd_ioctl_prism54(ifname, param, blen, 1)) {
+		wpa_printf(MSG_WARNING, "Failed to set encryption.");
+		show_set_key_error(param);
+		ret =3D -1;
+	}
+	free(buf);
+
+	return ret;
 }
=20
=20
@@ -58,10 +209,24 @@ static int wpa_driver_prism54_set_counte
 static int wpa_driver_prism54_set_drop_unencrypted(const char *ifname,
 						  int enabled)
 {
-	/* FIX */
-	printf("wpa_driver_prism54_set_drop_unencrypted - not yet "
-	       "implemented\n");
-	return 0;
+	struct prism2_hostapd_param *param;
+	int res;
+	size_t blen =3D PRISM2_HOSTAPD_GENERIC_ELEMENT_HDR_LEN;
+	if (blen < sizeof(*param))
+		blen =3D sizeof(*param);
+
+	param =3D (struct prism2_hostapd_param *) malloc(blen);
+	if (param =3D=3D NULL)
+		return -1;
+
+	memset(param, 0, blen);
+	param->cmd =3D PRISM54_DROP_UNENCRYPTED;
+	param->u.generic_elem.len =3D 0;
+	res =3D hostapd_ioctl_prism54(ifname, param, blen, 1);
+
+	free(param);
+
+	return res;
 }
=20
=20
@@ -93,9 +258,8 @@ static int wpa_driver_prism54_associate(
 {
 	int ret =3D 0;
=20
-	/* FIX: set wpa_ie */
-	printf("wpa_driver_prism54_associate - WPA IE setting not yet "
-	       "implemented\n");
+	if (wpa_driver_prism54_set_wpa_ie(ifname, wpa_ie, wpa_ie_len) < 0)
+		ret =3D -1;
 	if (wpa_driver_wext_set_freq(ifname, freq) < 0)
 		ret =3D -1;
 	if (wpa_driver_wext_set_ssid(ifname, ssid, ssid_len) < 0)
@@ -106,6 +270,35 @@ static int wpa_driver_prism54_associate(
 	return ret;
 }
=20
+static void show_set_key_error(struct prism2_hostapd_param *param)
+{
+	switch (param->u.crypt.err) {
+	case HOSTAP_CRYPT_ERR_UNKNOWN_ALG:
+		wpa_printf(MSG_INFO, "Unknown algorithm '%s'.",
+			   param->u.crypt.alg);
+		wpa_printf(MSG_INFO, "You may need to load kernel module to "
+			   "register that algorithm.");
+		wpa_printf(MSG_INFO, "E.g., 'modprobe hostap_crypt_wep' for "
+			   "WEP.");
+		break;
+	case HOSTAP_CRYPT_ERR_UNKNOWN_ADDR:
+		wpa_printf(MSG_INFO, "Unknown address " MACSTR ".",
+			   MAC2STR(param->sta_addr));
+		break;
+	case HOSTAP_CRYPT_ERR_CRYPT_INIT_FAILED:
+		wpa_printf(MSG_INFO, "Crypt algorithm initialization failed.");
+		break;
+	case HOSTAP_CRYPT_ERR_KEY_SET_FAILED:
+		wpa_printf(MSG_INFO, "Key setting failed.");
+		break;
+	case HOSTAP_CRYPT_ERR_TX_KEY_SET_FAILED:
+		wpa_printf(MSG_INFO, "TX key index setting failed.");
+		break;
+	case HOSTAP_CRYPT_ERR_CARD_CONF_FAILED:
+		wpa_printf(MSG_INFO, "Card configuration failed.");
+		break;
+	}
+}
=20
 struct wpa_driver_ops wpa_driver_prism54_ops =3D {
 	.get_bssid =3D wpa_driver_wext_get_bssid,

--7VkxxUl3xUvPtoxk--

--DITGHUV3p5DjDsXt
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFBJUGIat1JN+IKUl4RAqO8AJ96UIyzhj6vSBo9BDpKzIBu3MQVdgCgpKH1
uqbkRcQ7emFafLfzSPfKnBY=
=HkRm
-----END PGP SIGNATURE-----

--DITGHUV3p5DjDsXt--

--===============1617587924==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--===============1617587924==--
