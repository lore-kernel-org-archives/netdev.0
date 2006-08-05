From: Michael Wu <flamingice@sourmilk.net>
Subject: [PATCH wireless-dev] d80211: Fix issues with QOS bitwise ops
Date: Fri, 4 Aug 2006 23:30:48 -0700
Message-ID: <200608042330.54266.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart11436908.cIMkbD23Eq";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, Jouni Malinen <jkm@devicescape.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:54168 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S1161518AbWHEGbJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Aug 2006 02:31:09 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart11436908.cIMkbD23Eq
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

d80211: Fix issues with QOS ops

This patch fixes various bitwise ops dealing with QOS that didn't get=20
converted properly during the transition to IEEE80211_ style names. Thanks =
to=20
Jouni Malinen for pointing this out.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>
=2D--

 net/d80211/ieee80211.c |    6 +++---
 net/d80211/wme.c       |    4 ++--
 net/d80211/wpa.c       |    2 +-
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 60eca90..bf0e86b 100644
=2D-- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -250,7 +250,7 @@ int ieee80211_get_hdrlen(u16 fc)
 	case IEEE80211_FTYPE_DATA:
 		if ((fc & IEEE80211_FCTL_FROMDS) && (fc & IEEE80211_FCTL_TODS))
 			hdrlen =3D 30; /* Addr4 */
=2D		if ((fc & IEEE80211_FCTL_STYPE) =3D=3D IEEE80211_STYPE_QOS_DATA)
+		if (fc & IEEE80211_STYPE_QOS_DATA)
 			hdrlen +=3D 2; /* QoS Control Field */
 		break;
 	case IEEE80211_FTYPE_CTL:
@@ -1519,7 +1519,7 @@ static int ieee80211_subif_start_xmit(st
 	sta =3D sta_info_get(local, hdr.addr1);
 	if (sta) {
 		if (sta->flags & WLAN_STA_WME) {
=2D			fc |=3D IEEE80211_STYPE_QOS_DATA << 4;
+			fc |=3D IEEE80211_STYPE_QOS_DATA;
 			hdrlen +=3D 2;
 		}
 		sta_info_put(sta);
@@ -4009,7 +4009,7 @@ static void ieee80211_remove_tx_extra(st
 		struct ieee80211_hdr *hdr =3D (struct ieee80211_hdr *) skb->data;
 		u16 fc =3D le16_to_cpu(hdr->frame_control);
 		if ((fc & 0x8C) =3D=3D 0x88) /* QoS Control Field */ {
=2D			fc &=3D ~(IEEE80211_STYPE_QOS_DATA << 4);
+			fc &=3D ~IEEE80211_STYPE_QOS_DATA;
 			hdr->frame_control =3D cpu_to_le16(fc);
 			memmove(skb->data + 2, skb->data, hdrlen - 2);
 			skb_pull(skb, 2);
diff --git a/net/d80211/wme.c b/net/d80211/wme.c
index c3c961d..fc2a113 100644
=2D-- a/net/d80211/wme.c
+++ b/net/d80211/wme.c
@@ -76,7 +76,7 @@ ieee80211_rx_h_remove_qos_control(struct
 	memmove(data + 2, data, ieee80211_get_hdrlen(fc) - 2);
 	hdr =3D (struct ieee80211_hdr *) skb_pull(rx->skb, 2);
 	/* change frame type to non QOS */
=2D	rx->fc =3D fc &=3D ~(IEEE80211_STYPE_QOS_DATA << 4);
+	rx->fc =3D fc &=3D ~IEEE80211_STYPE_QOS_DATA;
 	hdr->frame_control =3D cpu_to_le16(fc);
=20
 	return TXRX_CONTINUE;
@@ -199,7 +199,7 @@ static inline int classify80211(struct s
 	}
=20
 	/* is this a QoS frame? */
=2D	qos =3D fc & (IEEE80211_STYPE_QOS_DATA << 4);
+	qos =3D fc & IEEE80211_STYPE_QOS_DATA;
=20
 	if (!qos) {
 		skb->priority =3D 0; /* required for correct WPA/11i MIC */
diff --git a/net/d80211/wpa.c b/net/d80211/wpa.c
index 7919620..fe5861f 100644
=2D-- a/net/d80211/wpa.c
+++ b/net/d80211/wpa.c
@@ -70,7 +70,7 @@ int ieee80211_get_hdr_info(const struct=20
 	a4_included =3D (fc & (IEEE80211_FCTL_TODS | IEEE80211_FCTL_FROMDS)) =3D=
=3D
 		(IEEE80211_FCTL_TODS | IEEE80211_FCTL_FROMDS);
 	if ((fc & IEEE80211_FCTL_FTYPE) =3D=3D IEEE80211_FTYPE_DATA &&
=2D	    (fc & IEEE80211_FCTL_STYPE) & IEEE80211_STYPE_QOS_DATA) {
+	    fc & IEEE80211_STYPE_QOS_DATA) {
 		pos =3D (u8 *) &hdr->addr4;
 		if (a4_included)
 			pos +=3D 6;

--nextPart11436908.cIMkbD23Eq
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBE1DseT3Oqt9AH4aERAjfSAKCh0R2UoE8XxfUs+4Xy8wxuovI50QCeIi7i
dbWd/C3xs51F+9AODEzIQGQ=
=F9f+
-----END PGP SIGNATURE-----

--nextPart11436908.cIMkbD23Eq--
