From: Carlos =?utf-8?q?Mart=C3=ADn?= <carlos@cmartin.tk>
Subject: [PATCH] acxsm: Change acx_ioctl_{get,set}_encode to use softmac
Date: Tue, 7 Feb 2006 00:32:57 +0100
Message-ID: <200602070033.02698.carlos@cmartin.tk>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart10958420.KCEIve152B";
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

--nextPart10958420.KCEIve152B
Content-Type: multipart/mixed;
  boundary="Boundary-01=_qy95Dzmt8DFj/8Y"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

--Boundary-01=_qy95Dzmt8DFj/8Y
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi,

 The attached patch changes the acx_ioctl_{get,set}_encode functions to use=
=20
the 80211 stack in the kernel, so they become mere wrappers.

Signed-off-by: Carlos Martin <carlos@cmartin.tk>

   cmn
=2D-=20
Carlos Mart=C3=ADn       http://www.cmartin.tk

"Erdbeben? Sicherlich etwas, das mit Erdberen zu tun hat." -- me, paraphras=
ed

--Boundary-01=_qy95Dzmt8DFj/8Y
Content-Type: text/x-diff;
  charset="utf-8";
  name="acx-ioctl-getset-encode-sm.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline;
	filename="acx-ioctl-getset-encode-sm.patch"

diff --git a/ioctl.c b/ioctl.c
index 1502938..041f165 100644
=2D-- a/ioctl.c
+++ b/ioctl.c
@@ -1007,87 +1007,7 @@ acx_ioctl_set_encode(
 	union iwreq_data *wrqu,
 	char *extra)
 {
=2D	struct iw_point *dwrq =3D &wrqu->encoding;
=2D	acx_device_t *adev =3D ndev2adev(ndev);
=2D	int index;
=2D	int result;
=2D
=2D	FN_ENTER;
=2D
=2D	log(L_IOCTL, "set encoding flags=3D0x%04X, size=3D%d, key: %s\n",
=2D			dwrq->flags, dwrq->length, extra ? "set" : "No key");
=2D
=2D	acx_sem_lock(adev);
=2D
=2D	index =3D (dwrq->flags & IW_ENCODE_INDEX) - 1;
=2D
=2D	if (dwrq->length > 0) {
=2D		/* if index is 0 or invalid, use default key */
=2D		if ((index < 0) || (index > 3))
=2D			index =3D (int)adev->ieee->sec.active_key;
=2D
=2D		if (0 =3D=3D (dwrq->flags & IW_ENCODE_NOKEY)) {
=2D			if (dwrq->length > 29)
=2D				dwrq->length =3D 29; /* restrict it */
=2D
=2D			if (dwrq->length > 13) {
=2D				/* 29*8 =3D=3D 232, WEP256 */
=2D				adev->ieee->sec.key_sizes[index] =3D 29;
=2D			} else if (dwrq->length > 5) {
=2D				/* 13*8 =3D=3D 104bit, WEP128 */
=2D				adev->ieee->sec.key_sizes[index] =3D 13;
=2D			} else if (dwrq->length > 0) {
=2D				/* 5*8 =3D=3D 40bit, WEP64 */
=2D				adev->ieee->sec.key_sizes[index] =3D 5;
=2D			} else {
=2D				/* disable key */
=2D				adev->ieee->sec.key_sizes[index] =3D 0;
=2D			}
=2D
=2D			memset(adev->ieee->sec.keys[index], 0,
=2D				sizeof(adev->ieee->sec.keys[index]));
=2D			memcpy(adev->ieee->sec.keys[index], extra, dwrq->length);
=2D		}
=2D	} else {
=2D		/* set transmit key */
=2D		if ((index >=3D 0) && (index <=3D 3))
=2D			adev->ieee->sec.active_key =3D index;
=2D		else if (0 =3D=3D (dwrq->flags & IW_ENCODE_MODE)) {
=2D			/* complain if we were not just setting
=2D			 * the key mode */
=2D			result =3D -EINVAL;
=2D			goto end_unlock;
=2D		}
=2D	}
=2D
=2D	adev->ieee->sec.enabled =3D !(dwrq->flags & IW_ENCODE_DISABLED);
=2D
=2D	if (dwrq->flags & IW_ENCODE_OPEN) {
=2D		adev->ieee->sec.auth_mode =3D WLAN_AUTH_OPEN;
=2D
=2D	} else if (dwrq->flags & IW_ENCODE_RESTRICTED) {
=2D	  adev->ieee->sec.auth_mode =3D WLAN_AUTH_SHARED_KEY;
=2D	}
=2D
=2D	/* set flag to make sure the card WEP settings get updated */
=2D	SET_BIT(adev->set_mask, GETSET_WEP);
=2D
=2D	log(L_IOCTL, "len=3D%d, key at 0x%p, flags=3D0x%X\n",
=2D		dwrq->length, extra, dwrq->flags);
=2D
=2D	for (index =3D 0; index <=3D 3; index++) {
=2D		if (adev->ieee->sec.key_sizes[index]) {
=2D			log(L_IOCTL,	"index=3D%d, size=3D%d, key at 0x%p\n",
=2D				adev->ieee->sec.active_key,
=2D				(int) adev->ieee->sec.key_sizes[index],
=2D				adev->ieee->sec.keys[index]);
=2D		}
=2D	}
=2D	result =3D -EINPROGRESS;
=2D
=2Dend_unlock:
=2D	acx_sem_unlock(adev);
=2D
+	int result =3D ieee80211_wx_set_encode(netdev_priv(ndev), info, wrqu, ext=
ra);
 	FN_EXIT1(result);
 	return result;
 }
@@ -1103,35 +1023,9 @@ acx_ioctl_get_encode(
 	union iwreq_data *wrqu,
 	char *extra)
 {
=2D	struct iw_point *dwrq =3D &wrqu->encoding;
=2D	acx_device_t *adev =3D ndev2adev(ndev);
=2D	int index =3D (dwrq->flags & IW_ENCODE_INDEX) - 1;
=2D
=2D	FN_ENTER;
=2D
=2D	if (adev->ieee->sec.enabled =3D=3D 0) {
=2D		dwrq->flags =3D IW_ENCODE_DISABLED;
=2D	} else {
=2D		if ((index < 0) || (index > 3))
=2D			index =3D (int)adev->ieee->sec.active_key;
=2D
=2D		dwrq->flags =3D (adev->ieee->sec.auth_mode =3D=3D WLAN_AUTH_SHARED_KEY=
) ?
=2D				IW_ENCODE_RESTRICTED : IW_ENCODE_OPEN;
=2D		dwrq->length =3D adev->ieee->sec.key_sizes[index];
=2D
=2D		memcpy(extra, adev->ieee->sec.keys[index],
=2D			      adev->ieee->sec.key_sizes[index]);
=2D	}
=2D
=2D	/* set the current index */
=2D	SET_BIT(dwrq->flags, index + 1);
=2D
=2D	log(L_IOCTL, "len=3D%d, key=3D%p, flags=3D0x%X\n",
=2D	       dwrq->length, dwrq->pointer,
=2D	       dwrq->flags);
=2D
=2D	FN_EXIT1(OK);
=2D	return OK;
+	int result =3D ieee80211_wx_get_encode(netdev_priv(ndev), info, wrqu, ext=
ra);
+	FN_EXIT1(result);
+	return result;
 }
=20
=20

--Boundary-01=_qy95Dzmt8DFj/8Y--

--nextPart10958420.KCEIve152B
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBD59yuEVXxXOiy6a4RAt4RAJ9upFDTH+sAfcjsBXWNScX799IYngCcDM8o
zilTNtMauIfOdjwR8qd9YNM=
=uLKM
-----END PGP SIGNATURE-----

--nextPart10958420.KCEIve152B--


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
