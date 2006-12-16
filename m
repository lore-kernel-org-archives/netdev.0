From: Michael Wu <flamingice@sourmilk.net>
Subject: [PATCH] d80211: add radiotap support
Date: Sat, 16 Dec 2006 18:01:03 -0500
Message-ID: <200612161801.08007.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart5975186.1XrX9NHdGi";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, John Linville <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:58957 "EHLO
	server8.tchmachines.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932652AbWLPXBb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Dec 2006 18:01:31 -0500
To: Jiri Benc <jbenc@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart5975186.1XrX9NHdGi
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

d80211: add radiotap support

This patch adds support for radiotap to d80211. The driver must set
IEEE80211_HW_MONITOR_DURING_OPER as well as
IEEE80211_HW_RADIOTAP_SUPPORTED, and it must send radiotap frames when
there is at least one monitor interface up. Tested with zd1211rw-d80211.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>
=2D--

 include/net/d80211.h         |    3 +++
 net/d80211/ieee80211.c       |   43 ++++++++++++++++++++++++++++++++------=
=2D---
 net/d80211/ieee80211_iface.c |    5 ++++-
 3 files changed, 40 insertions(+), 11 deletions(-)

diff --git a/include/net/d80211.h b/include/net/d80211.h
index 30980e1..27b2487 100644
=2D-- a/include/net/d80211.h
+++ b/include/net/d80211.h
@@ -501,6 +501,9 @@ struct ieee80211_hw {
 	 * per-packet RC4 key with each TX frame when doing hwcrypto */
 #define IEEE80211_HW_TKIP_REQ_PHASE2_KEY (1<<14)
=20
+	/* Driver supports radiotap. Temporary until all drivers support it. */
+#define IEEE80211_HW_RADIOTAP_SUPPORTED (1<<20)
+
 	u32 flags;			/* hardware flags defined above */
=20
 	/* Set to the size of a needed device specific skb headroom for TX skbs. =
*/
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 6e10db5..c686f02 100644
=2D-- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -8,6 +8,7 @@
  */
=20
 #include <net/d80211.h>
+#include <net/ieee80211_radiotap.h>
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/netdevice.h>
@@ -284,6 +285,14 @@ int ieee80211_get_hdrlen_from_skb(struct
 }
 EXPORT_SYMBOL(ieee80211_get_hdrlen_from_skb);
=20
+static int ieee80211_get_radiotap_len(struct sk_buff *skb)
+{
+	struct ieee80211_radiotap_header *hdr =3D
+		(struct ieee80211_radiotap_header *) skb->data;
+
+	return le16_to_cpu(hdr->it_len);
+}
+
 #ifdef CONFIG_D80211_LOWTX_FRAME_DUMP
 static void ieee80211_dump_frame(const char *ifname, const char *title,
 				 struct sk_buff *skb)
@@ -2650,24 +2659,26 @@ ieee80211_rx_monitor(struct net_device *
=20
 	sdata =3D IEEE80211_DEV_TO_SUB_IF(dev);
=20
=2D	if (skb_headroom(skb) < hlen) {
=2D		I802_DEBUG_INC(local->rx_expand_skb_head);
=2D		if (pskb_expand_head(skb, hlen, 0, GFP_ATOMIC)) {
=2D			dev_kfree_skb(skb);
=2D                        return;
+	if (!(local->hw.flags & IEEE80211_HW_RADIOTAP_SUPPORTED)) {
+		if (skb_headroom(skb) < hlen) {
+			I802_DEBUG_INC(local->rx_expand_skb_head);
+			if (pskb_expand_head(skb, hlen, 0, GFP_ATOMIC)) {
+				dev_kfree_skb(skb);
+				return;
+			}
 		}
=2D	}
=20
=2D	fi =3D (struct ieee80211_frame_info *) skb_push(skb, hlen);
+		fi =3D (struct ieee80211_frame_info *) skb_push(skb, hlen);
+		ieee80211_fill_frame_info(local, fi, status);
+	}
=20
=2D	ieee80211_fill_frame_info(local, fi, status);
 	sdata->stats.rx_packets++;
 	sdata->stats.rx_bytes +=3D skb->len;
=20
 	skb->mac.raw =3D skb->data;
 	skb->ip_summed =3D CHECKSUM_UNNECESSARY;
 	skb->pkt_type =3D PACKET_OTHERHOST;
=2D	skb->protocol =3D htons(ETH_P_802_2);
+	skb->protocol =3D __constant_htons(ETH_P_802_2);
 	memset(skb->cb, 0, sizeof(skb->cb));
 	netif_rx(skb);
 }
@@ -3064,6 +3075,10 @@ ieee80211_rx_h_monitor(struct ieee80211_
 		return TXRX_QUEUED;
 	}
=20
+	if (rx->local->monitors &&
+	    rx->local->hw.flags & IEEE80211_HW_RADIOTAP_SUPPORTED)
+		skb_pull(rx->skb, ieee80211_get_radiotap_len(rx->skb));
+
 	return TXRX_CONTINUE;
 }
=20
@@ -3628,6 +3643,13 @@ void __ieee80211_rx(struct ieee80211_hw
 	struct ieee80211_txrx_data rx;
 	u16 type;
 	int multicast;
+	int radiotap_len =3D 0;
+
+	if (local->monitors &&
+	    local->hw.flags & IEEE80211_HW_RADIOTAP_SUPPORTED) {
+		radiotap_len =3D ieee80211_get_radiotap_len(skb);
+		skb_pull(skb, radiotap_len);
+	}
=20
 	hdr =3D (struct ieee80211_hdr *) skb->data;
 	memset(&rx, 0, sizeof(rx));
@@ -3664,6 +3686,7 @@ void __ieee80211_rx(struct ieee80211_hw
 		goto end;
 	skb =3D rx.skb;
=20
+	skb_push(skb, radiotap_len);
 	if (sta && !sta->assoc_ap && !(sta->flags & WLAN_STA_WDS) &&
 	    !local->iff_promiscs && !multicast) {
 		rx.u.rx.ra_match =3D 1;
@@ -3672,7 +3695,7 @@ void __ieee80211_rx(struct ieee80211_hw
 	} else {
 		struct ieee80211_sub_if_data *prev =3D NULL;
 		struct sk_buff *skb_new;
=2D		u8 *bssid =3D ieee80211_get_bssid(hdr, skb->len);
+		u8 *bssid =3D ieee80211_get_bssid(hdr, skb->len - radiotap_len);
=20
 		list_for_each_entry(sdata, &local->sub_if_list, list) {
 			rx.u.rx.ra_match =3D 1;
diff --git a/net/d80211/ieee80211_iface.c b/net/d80211/ieee80211_iface.c
index 3e9d531..c1bb6d0 100644
=2D-- a/net/d80211/ieee80211_iface.c
+++ b/net/d80211/ieee80211_iface.c
@@ -198,7 +198,10 @@ void ieee80211_if_set_type(struct net_de
 		break;
 	}
 	case IEEE80211_IF_TYPE_MNTR:
=2D		dev->type =3D ARPHRD_IEEE80211_PRISM;
+		if (sdata->local->hw.flags & IEEE80211_HW_RADIOTAP_SUPPORTED)
+			dev->type =3D ARPHRD_IEEE80211_RADIOTAP;
+		else
+			dev->type =3D ARPHRD_IEEE80211_PRISM;
 		break;
 	default:
 		printk(KERN_WARNING "%s: %s: Unknown interface type 0x%x",

--nextPart5975186.1XrX9NHdGi
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFhHqzT3Oqt9AH4aERAo91AKCqkgWV1ievYoXlYwYuhD3COYJvYgCgrt+q
JzjGz80pfGB0HMl7Ko2xTXs=
=dHhR
-----END PGP SIGNATURE-----

--nextPart5975186.1XrX9NHdGi--
