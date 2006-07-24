From: Michael Wu <flamingice@sourmilk.net>
Subject: [PATCH wireless-dev 2/5] orinoco: Switch to d80211.h
Date: Sun, 23 Jul 2006 20:40:20 -0700
Message-ID: <200607232040.37823.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2192800.WXhmpifJTv";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org, proski@gnu.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:42214 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S1751392AbWGXDyK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Jul 2006 23:54:10 -0400
To: linville@tuxdriver.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2192800.WXhmpifJTv
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

orinoco: Switch to d80211.h

This patch "converts" the orinoco driver to use d80211.h instead of
ieee80211.h. It also copies the IEEE80211_DATA_LEN definition to
d80211.h for use by the stack and drivers.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>
=2D--

 drivers/net/wireless/orinoco.c |   37 +++++++++++++++++++------------------
 include/net/d80211.h           |    9 +++++++++
 net/d80211/ieee80211.c         |    4 ++--
 3 files changed, 30 insertions(+), 20 deletions(-)

diff --git a/drivers/net/wireless/orinoco.c b/drivers/net/wireless/orinoco.c
index d6ed578..bdc8d37 100644
=2D-- a/drivers/net/wireless/orinoco.c
+++ b/drivers/net/wireless/orinoco.c
@@ -83,8 +83,9 @@ #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
 #include <linux/wireless.h>
+#include <linux/if_arp.h>
 #include <net/iw_handler.h>
=2D#include <net/ieee80211.h>
+#include <net/d80211.h>
=20
 #include "hermes_rid.h"
 #include "orinoco.h"
@@ -400,7 +401,7 @@ static int orinoco_change_mtu(struct net
 	if ( (new_mtu < ORINOCO_MIN_MTU) || (new_mtu > ORINOCO_MAX_MTU) )
 		return -EINVAL;
=20
=2D	if ( (new_mtu + ENCAPS_OVERHEAD + IEEE80211_HLEN) >
+	if ( (new_mtu + ENCAPS_OVERHEAD + sizeof(struct ieee80211_hdr)) >
 	     (priv->nicbuf_size - ETH_HLEN) )
 		return -EINVAL;
=20
@@ -720,29 +721,29 @@ static void orinoco_rx_monitor(struct ne
=20
 	/* Determine the size of the header and the data */
 	fc =3D le16_to_cpu(desc->frame_ctl);
=2D	switch (fc & IEEE80211_FCTL_FTYPE) {
=2D	case IEEE80211_FTYPE_DATA:
=2D		if ((fc & IEEE80211_FCTL_TODS)
=2D		    && (fc & IEEE80211_FCTL_FROMDS))
+	switch (WLAN_FC_GET_TYPE(fc)) {
+	case WLAN_FC_TYPE_DATA:
+		if ((fc & WLAN_FC_TODS)
+		    && (fc & WLAN_FC_FROMDS))
 			hdrlen =3D 30;
 		else
 			hdrlen =3D 24;
 		datalen =3D len;
 		break;
=2D	case IEEE80211_FTYPE_MGMT:
+	case WLAN_FC_TYPE_MGMT:
 		hdrlen =3D 24;
 		datalen =3D len;
 		break;
=2D	case IEEE80211_FTYPE_CTL:
=2D		switch (fc & IEEE80211_FCTL_STYPE) {
=2D		case IEEE80211_STYPE_PSPOLL:
=2D		case IEEE80211_STYPE_RTS:
=2D		case IEEE80211_STYPE_CFEND:
=2D		case IEEE80211_STYPE_CFENDACK:
+	case WLAN_FC_TYPE_CTRL:
+		switch (WLAN_FC_GET_STYPE(fc)) {
+		case WLAN_FC_STYPE_PSPOLL:
+		case WLAN_FC_STYPE_RTS:
+		case WLAN_FC_STYPE_CFEND:
+		case WLAN_FC_STYPE_CFENDACK:
 			hdrlen =3D 16;
 			break;
=2D		case IEEE80211_STYPE_CTS:
=2D		case IEEE80211_STYPE_ACK:
+		case WLAN_FC_STYPE_CTS:
+		case WLAN_FC_STYPE_ACK:
 			hdrlen =3D 10;
 			break;
 		}
@@ -908,7 +909,7 @@ static void __orinoco_ev_rx(struct net_d
 		hdr->h_proto =3D htons(length);
 	}
 	memcpy(hdr->h_dest, desc.addr1, ETH_ALEN);
=2D	if (fc & IEEE80211_FCTL_FROMDS)
+	if (fc & WLAN_FC_FROMDS)
 		memcpy(hdr->h_source, desc.addr3, ETH_ALEN);
 	else
 		memcpy(hdr->h_source, desc.addr2, ETH_ALEN);
@@ -917,7 +918,7 @@ static void __orinoco_ev_rx(struct net_d
 	skb->dev =3D dev;
 	skb->protocol =3D eth_type_trans(skb, dev);
 	skb->ip_summed =3D CHECKSUM_NONE;
=2D	if (fc & IEEE80211_FCTL_TODS)
+	if (fc & WLAN_FC_TODS)
 		skb->pkt_type =3D PACKET_OTHERHOST;
 =09
 	/* Process the wireless stats if needed */
@@ -2229,7 +2230,7 @@ static int orinoco_init(struct net_devic
=20
 	/* No need to lock, the hw_unavailable flag is already set in
 	 * alloc_orinocodev() */
=2D	priv->nicbuf_size =3D IEEE80211_FRAME_LEN + ETH_HLEN;
+	priv->nicbuf_size =3D IEEE80211_DATA_LEN + sizeof(struct ieee80211_hdr) +=
 ETH_HLEN;
=20
 	/* Initialize the firmware */
 	err =3D hermes_init(hw);
diff --git a/include/net/d80211.h b/include/net/d80211.h
index b9d4b24..6bf1b08 100644
=2D-- a/include/net/d80211.h
+++ b/include/net/d80211.h
@@ -958,6 +958,15 @@ #define WLAN_FC_STYPE_QOS_CFACKPOLL	15
 #define IEEE80211_MAX_FRAG_THRESHOLD 2346
 #define IEEE80211_MAX_RTS_THRESHOLD 2347
=20
+#define IEEE80211_DATA_LEN              2304
+/* Maximum size for the MA-UNITDATA primitive, 802.11 standard section
+   6.2.1.1.2.
+
+   The figure in section 7.1.2 suggests a body size of up to 2312
+   bytes is allowed, which is a bit confusing, I suspect this
+   represents the 2304 bytes of real data, plus a possible 8 bytes of
+   WEP IV and ICV. (this interpretation suggested by Ramiro Barreiro) */
+
 struct ieee80211_hdr {
 	__le16 frame_control;
 	__le16 duration_id;
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 71f9005..9c38905 100644
=2D-- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -1969,7 +1969,7 @@ static int ieee80211_change_mtu(struct n
 {
 	/* FIX: what would be proper limits for MTU?
 	 * This interface uses 802.3 frames. */
=2D	if (new_mtu < 256 || new_mtu > 2304 - 24 - 6) {
+	if (new_mtu < 256 || new_mtu > IEEE80211_DATA_LEN - 24 - 6) {
 		printk(KERN_WARNING "%s: invalid MTU %d\n",
 		       dev->name, new_mtu);
 		return -EINVAL;
@@ -1987,7 +1987,7 @@ static int ieee80211_change_mtu_apdev(st
 {
 	/* FIX: what would be proper limits for MTU?
 	 * This interface uses 802.11 frames. */
=2D	if (new_mtu < 256 || new_mtu > 2304) {
+	if (new_mtu < 256 || new_mtu > IEEE80211_DATA_LEN) {
 		printk(KERN_WARNING "%s: invalid MTU %d\n",
 		       dev->name, new_mtu);
 		return -EINVAL;

--nextPart2192800.WXhmpifJTv
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBExEE1T3Oqt9AH4aERAlh1AJwP7XXYMOJ5P76xJUqjluIww7DOJQCgv0CM
iK0+Y9hyPUYCw9me1mIfsR4=
=TqTF
-----END PGP SIGNATURE-----

--nextPart2192800.WXhmpifJTv--
