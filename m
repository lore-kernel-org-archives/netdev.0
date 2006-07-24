From: Michael Wu <flamingice@sourmilk.net>
Subject: [PATCH wireless-dev 5/5] airo: Switch to d80211.h
Date: Sun, 23 Jul 2006 20:50:26 -0700
Message-ID: <200607232050.32467.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart5369700.GZiG4YUjiz";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:44262 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S1751396AbWGXDyL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Jul 2006 23:54:11 -0400
To: linville@tuxdriver.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart5369700.GZiG4YUjiz
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

airo: Switch to d80211.h

This patch "converts" the airo driver to use d80211.h instead of
ieee80211.h. It also adds struct ieee80211_info_element and
modifies d80211 to use that.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>
=2D--

 drivers/net/wireless/airo.c |   15 ++++----
 include/net/d80211.h        |    6 +++
 net/d80211/ieee80211_sta.c  |   85 +++++++++++++++++++++------------------=
=2D---
 3 files changed, 54 insertions(+), 52 deletions(-)

diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index a4dd139..c08767a 100644
=2D-- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -46,7 +46,8 @@ #include <linux/if_arp.h>
 #include <linux/ioport.h>
 #include <linux/pci.h>
 #include <asm/uaccess.h>
=2D#include <net/ieee80211.h>
+#include <net/d80211.h>
+#include <net/d80211_mgmt.h>
=20
 #include "airo.h"
=20
@@ -7317,31 +7318,29 @@ static inline char *airo_translate_scan(
 			}
=20
 			switch (info_element->id) {
=2D			case MFIE_TYPE_SSID:
+			case WLAN_EID_SSID:
 				/* Two zero-length SSID elements
 				 * mean we're done parsing elements */
 				if (!info_element->len)
 					num_null_ies++;
 				break;
=20
=2D			case MFIE_TYPE_GENERIC:
+			case WLAN_EID_GENERIC:
 				if (info_element->len >=3D 4 &&
 				    info_element->data[0] =3D=3D 0x00 &&
 				    info_element->data[1] =3D=3D 0x50 &&
 				    info_element->data[2] =3D=3D 0xf2 &&
 				    info_element->data[3] =3D=3D 0x01) {
 					iwe.cmd =3D IWEVGENIE;
=2D					iwe.u.data.length =3D min(info_element->len + 2,
=2D								  MAX_WPA_IE_LEN);
+					iwe.u.data.length =3D min(info_element->len + 2, 64);
 					current_ev =3D iwe_stream_add_point(current_ev, end_buf,
 							&iwe, (char *) info_element);
 				}
 				break;
=20
=2D			case MFIE_TYPE_RSN:
+			case WLAN_EID_RSN:
 				iwe.cmd =3D IWEVGENIE;
=2D				iwe.u.data.length =3D min(info_element->len + 2,
=2D							  MAX_WPA_IE_LEN);
+				iwe.u.data.length =3D min(info_element->len + 2, 64);
 				current_ev =3D iwe_stream_add_point(current_ev, end_buf,
 						&iwe, (char *) info_element);
 				break;
diff --git a/include/net/d80211.h b/include/net/d80211.h
index 6bf1b08..10ef570 100644
=2D-- a/include/net/d80211.h
+++ b/include/net/d80211.h
@@ -977,6 +977,12 @@ struct ieee80211_hdr {
 	u8 addr4[6];
 } __attribute__ ((packed));
=20
+struct ieee80211_info_element {
+	u8 id;
+	u8 len;
+	u8 data[0];
+} __attribute__ ((packed));
+
 /* return a pointer to the source address (SA) */
 static inline u8 *ieee80211_get_SA(struct ieee80211_hdr *hdr)
 {
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index b0cfff1..d206b16 100644
=2D-- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -110,91 +110,88 @@ static ParseRes ieee802_11_parse_elems(u
 				       struct ieee802_11_elems *elems)
 {
 	size_t left =3D len;
=2D	u8 *pos =3D start;
+	struct ieee80211_info_element *info =3D (struct ieee80211_info_element *)=
 start;
 	int unknown =3D 0;
=20
 	memset(elems, 0, sizeof(*elems));
=20
 	while (left >=3D 2) {
=2D		u8 id, elen;
=2D
=2D		id =3D *pos++;
=2D		elen =3D *pos++;
 		left -=3D 2;
=20
=2D		if (elen > left) {
+		if (info->len > left) {
 #if 0
 			if (net_ratelimit())
 				printk(KERN_DEBUG "IEEE 802.11 element parse "
 				       "failed (id=3D%d elen=3D%d left=3D%d)\n",
=2D				       id, elen, left);
+				       info->id, info->len, left);
 #endif
 			return ParseFailed;
 		}
=20
=2D		switch (id) {
+		switch (info->id) {
 		case WLAN_EID_SSID:
=2D			elems->ssid =3D pos;
=2D			elems->ssid_len =3D elen;
+			elems->ssid =3D info->data;
+			elems->ssid_len =3D info->len;
 			break;
 		case WLAN_EID_SUPP_RATES:
=2D			elems->supp_rates =3D pos;
=2D			elems->supp_rates_len =3D elen;
+			elems->supp_rates =3D info->data;
+			elems->supp_rates_len =3D info->len;
 			break;
 		case WLAN_EID_FH_PARAMS:
=2D			elems->fh_params =3D pos;
=2D			elems->fh_params_len =3D elen;
+			elems->fh_params =3D info->data;
+			elems->fh_params_len =3D info->len;
 			break;
 		case WLAN_EID_DS_PARAMS:
=2D			elems->ds_params =3D pos;
=2D			elems->ds_params_len =3D elen;
+			elems->ds_params =3D info->data;
+			elems->ds_params_len =3D info->len;
 			break;
 		case WLAN_EID_CF_PARAMS:
=2D			elems->cf_params =3D pos;
=2D			elems->cf_params_len =3D elen;
+			elems->cf_params =3D info->data;
+			elems->cf_params_len =3D info->len;
 			break;
 		case WLAN_EID_TIM:
=2D			elems->tim =3D pos;
=2D			elems->tim_len =3D elen;
+			elems->tim =3D info->data;
+			elems->tim_len =3D info->len;
 			break;
 		case WLAN_EID_IBSS_PARAMS:
=2D			elems->ibss_params =3D pos;
=2D			elems->ibss_params_len =3D elen;
+			elems->ibss_params =3D info->data;
+			elems->ibss_params_len =3D info->len;
 			break;
 		case WLAN_EID_CHALLENGE:
=2D			elems->challenge =3D pos;
=2D			elems->challenge_len =3D elen;
+			elems->challenge =3D info->data;
+			elems->challenge_len =3D info->len;
 			break;
 		case WLAN_EID_WPA:
=2D			if (elen >=3D 4 && pos[0] =3D=3D 0x00 && pos[1] =3D=3D 0x50 &&
=2D			    pos[2] =3D=3D 0xf2) {
+			if (info->len >=3D 4 && info->data[0] =3D=3D 0x00 &&
+			    info->data[1] =3D=3D 0x50 && info->data[2] =3D=3D 0xf2) {
 				/* Microsoft OUI (00:50:F2) */
=2D				if (pos[3] =3D=3D 1) {
+				if (info->data[3] =3D=3D 1) {
 					/* OUI Type 1 - WPA IE */
=2D					elems->wpa =3D pos;
=2D					elems->wpa_len =3D elen;
=2D				} else if (elen >=3D 5 && pos[3] =3D=3D 2) {
=2D					if (pos[4] =3D=3D 0) {
=2D						elems->wmm_info =3D pos;
=2D						elems->wmm_info_len =3D elen;
=2D					} else if (pos[4] =3D=3D 1) {
=2D						elems->wmm_param =3D pos;
=2D						elems->wmm_param_len =3D elen;
+					elems->wpa =3D info->data;
+					elems->wpa_len =3D info->len;
+				} else if (info->len >=3D 5 &&
+					   info->data[3] =3D=3D 2) {
+					if (info->data[4] =3D=3D 0) {
+						elems->wmm_info =3D info->data;
+						elems->wmm_info_len =3D info->len;
+					} else if (info->data[4] =3D=3D 1) {
+						elems->wmm_param =3D info->data;
+						elems->wmm_param_len =3D info->len;
 					}
 				}
 			}
 			break;
 		case WLAN_EID_RSN:
=2D			elems->rsn =3D pos;
=2D			elems->rsn_len =3D elen;
+			elems->rsn =3D info->data;
+			elems->rsn_len =3D info->len;
 			break;
 		case WLAN_EID_ERP_INFO:
=2D			elems->erp_info =3D pos;
=2D			elems->erp_info_len =3D elen;
+			elems->erp_info =3D info->data;
+			elems->erp_info_len =3D info->len;
 			break;
 		case WLAN_EID_EXT_SUPP_RATES:
=2D			elems->ext_supp_rates =3D pos;
=2D			elems->ext_supp_rates_len =3D elen;
+			elems->ext_supp_rates =3D info->data;
+			elems->ext_supp_rates_len =3D info->len;
 			break;
 		default:
 #if 0
@@ -206,8 +203,8 @@ #endif
 			break;
 		}
=20
=2D		left -=3D elen;
=2D		pos +=3D elen;
+		left -=3D info->len;
+		info  =3D (void *)info + sizeof(*info) + info->len;
 	}
=20
 	/* Do not trigger error if left =3D=3D 1 as Apple Airport base stations

--nextPart5369700.GZiG4YUjiz
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBExEOIT3Oqt9AH4aERAmuVAKDR6nW7sShN9vRRENhZSvHeaBSpCACeJFmK
/ZJu7cgX4pM3WBDqobkkrck=
=Jh1y
-----END PGP SIGNATURE-----

--nextPart5369700.GZiG4YUjiz--
