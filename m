From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] r8169: fix offloaded tx checksum for small packets.
Date: Fri, 17 May 2013 00:38:57 +0200
Message-ID: <20130516223857.GA20140@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>,
	Stefan Bader <stefan.bader@canonical.com>,
	Holger =?utf-8?Q?Hoffst=C3=A4tte?=
	<holger.hoffstaette@googlemail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:38042 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754492Ab3EPWjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 May 2013 18:39:13 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

8168evl offloaded checksums are wrong since
e5195c1f31f399289347e043d6abf3ffa80f0005 pads small packets to
60 bytes (without ethernet checksum). Observed UDP checksums are
typically wrong by the count of added bytes.

It isn't worth compensating. Let's checksum by hand, then pad.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Hayes Wang <hayeswang@realtek.com>
Tested-by: Holger Hoffst=C3=A4tte <holger.hoffstaette@googlemail.com>
---
 drivers/net/ethernet/realtek/r8169.c | 40 +++++++++++++++++++++++-----=
--------
 1 file changed, 26 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/etherne=
t/realtek/r8169.c
index 79c520b..a05596c 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5856,7 +5856,15 @@ err_out:
 	return -EIO;
 }
=20
-static inline void rtl8169_tso_csum(struct rtl8169_private *tp,
+static bool rtl_skb_pad(struct sk_buff *skb)
+{
+	if (skb_padto(skb, ETH_ZLEN))
+		return false;
+	skb_put(skb, ETH_ZLEN - skb->len);
+	return true;
+}
+
+static inline bool rtl8169_tso_csum(struct rtl8169_private *tp,
 				    struct sk_buff *skb, u32 *opts)
 {
 	const struct rtl_tx_desc_info *info =3D tx_desc_info + tp->txd_versio=
n;
@@ -5869,13 +5877,24 @@ static inline void rtl8169_tso_csum(struct rtl8=
169_private *tp,
 	} else if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL) {
 		const struct iphdr *ip =3D ip_hdr(skb);
=20
+		if (unlikely(skb->len < ETH_ZLEN &&
+		    (tp->mac_version =3D=3D RTL_GIGA_MAC_VER_34))) {
+			skb_checksum_help(skb);
+			return rtl_skb_pad(skb);
+		}
+
 		if (ip->protocol =3D=3D IPPROTO_TCP)
 			opts[offset] |=3D info->checksum.tcp;
 		else if (ip->protocol =3D=3D IPPROTO_UDP)
 			opts[offset] |=3D info->checksum.udp;
 		else
 			WARN_ON_ONCE(1);
+	} else {
+		if (unlikely(skb->len < ETH_ZLEN &&
+		    (tp->mac_version =3D=3D RTL_GIGA_MAC_VER_34)))
+			return rtl_skb_pad(skb);
 	}
+	return true;
 }
=20
 static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
@@ -5896,17 +5915,15 @@ static netdev_tx_t rtl8169_start_xmit(struct sk=
_buff *skb,
 		goto err_stop_0;
 	}
=20
-	/* 8168evl does not automatically pad to minimum length. */
-	if (unlikely(tp->mac_version =3D=3D RTL_GIGA_MAC_VER_34 &&
-		     skb->len < ETH_ZLEN)) {
-		if (skb_padto(skb, ETH_ZLEN))
-			goto err_update_stats;
-		skb_put(skb, ETH_ZLEN - skb->len);
-	}
-
 	if (unlikely(le32_to_cpu(txd->opts1) & DescOwn))
 		goto err_stop_0;
=20
+	opts[1] =3D cpu_to_le32(rtl8169_tx_vlan_tag(skb));
+	opts[0] =3D DescOwn;
+
+	if (!rtl8169_tso_csum(tp, skb, opts))
+		goto err_update_stats;
+
 	len =3D skb_headlen(skb);
 	mapping =3D dma_map_single(d, skb->data, len, DMA_TO_DEVICE);
 	if (unlikely(dma_mapping_error(d, mapping))) {
@@ -5918,11 +5935,6 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_=
buff *skb,
 	tp->tx_skb[entry].len =3D len;
 	txd->addr =3D cpu_to_le64(mapping);
=20
-	opts[1] =3D cpu_to_le32(rtl8169_tx_vlan_tag(skb));
-	opts[0] =3D DescOwn;
-
-	rtl8169_tso_csum(tp, skb, opts);
-
 	frags =3D rtl8169_xmit_frags(tp, skb, opts);
 	if (frags < 0)
 		goto err_dma_1;
--=20
1.8.1.4
