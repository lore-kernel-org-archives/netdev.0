From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] vlan: allow VLAN ID 0 to be used
Date: Mon, 26 Oct 2009 17:13:58 +0100
Message-ID: <4AE5CAC6.4000604@gmail.com>
References: <477963.52849.qm@web32605.mail.mud.yahoo.com> <m34opmr2fz.fsf@ursa.amorsen.dk> <4AE563C7.5070702@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Benny Amorsen <benny+usenet@amorsen.dk>,
	Gertjan Hofman <gertjan_hofman@yahoo.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:45642 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752999AbZJZQOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 12:14:04 -0400
In-Reply-To: <4AE563C7.5070702@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =C3=A9crit :
> VLAN id 0 is not usable on current kernel because we use 16 bits in s=
kb to
>  store vlan_tci, and vlan_tci =3D 0 means there is no VLAN tagging.
>=20
>=20
> We could use high order bit (0x8000) to tell if vlan tagging is set o=
r not.
>=20

Here is the patch I cooked that permitted VLAN 0 to be used with tg3
(and other HW accelerated vlan nics I suppose)

[PATCH] vlan: allow VLAN ID 0 to be used

We currently use a 16 bit field (vlan_tci) to store VLAN ID on a skb.

0 value is used a special value, meaning VLAN ID not set.
This forbids use of VLAN ID 0

As VLAN ID is 12 bits, we can use high order bit as a flag, and
allow VLAN ID 0

Reported-by: Gertjan Hofman <gertjan_hofman@yahoo.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 7ff9af1..7dfcdb5 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -105,8 +105,9 @@ static inline void vlan_group_set_device(struct vla=
n_group *vg,
 	array[vlan_id % VLAN_GROUP_ARRAY_PART_LEN] =3D dev;
 }
=20
-#define vlan_tx_tag_present(__skb)	((__skb)->vlan_tci)
-#define vlan_tx_tag_get(__skb)		((__skb)->vlan_tci)
+#define VLAN_TAG_PRESENT		0x8000
+#define vlan_tx_tag_present(__skb)	((__skb)->vlan_tci & VLAN_TAG_PRESE=
NT)
+#define vlan_tx_tag_get(__skb)		((__skb)->vlan_tci & 0x7fff)
=20
 #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
 extern struct net_device *vlan_dev_real_dev(const struct net_device *d=
ev);
@@ -231,7 +232,7 @@ static inline struct sk_buff *__vlan_put_tag(struct=
 sk_buff *skb, u16 vlan_tci)
 static inline struct sk_buff *__vlan_hwaccel_put_tag(struct sk_buff *s=
kb,
 						     u16 vlan_tci)
 {
-	skb->vlan_tci =3D vlan_tci;
+	skb->vlan_tci =3D VLAN_TAG_PRESENT | vlan_tci;
 	return skb;
 }
=20
@@ -284,7 +285,7 @@ static inline int __vlan_hwaccel_get_tag(const stru=
ct sk_buff *skb,
 					 u16 *vlan_tci)
 {
 	if (vlan_tx_tag_present(skb)) {
-		*vlan_tci =3D skb->vlan_tci;
+		*vlan_tci =3D vlan_tx_tag_get(skb);
 		return 0;
 	} else {
 		*vlan_tci =3D 0;
