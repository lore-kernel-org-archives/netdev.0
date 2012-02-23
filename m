From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bug 42809] New: kernel panic when receiving an ipsec packet
Date: Thu, 23 Feb 2012 03:06:25 +0100
Message-ID: <1329962785.15610.8.camel@edumazet-laptop>
References: <bug-42809-100@https.bugzilla.kernel.org/>
	  <20120222092056.5fca788b@nehalam.linuxnetplumber.net>
	  <4F4528CE.7080702@linuxsystems.it> <4F458F82.3060808@linuxsystems.it>
	 <1329961083.15610.2.camel@edumazet-laptop>
	 <4F459E37.9010507@linuxsystems.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Networking Developer Mailing List <netdev@vger.kernel.org>,
	openadsl-users@lists.sourceforge.net,
	openadsl-devel@lists.sourceforge.net
To: =?ISO-8859-1?Q?Niccol=F2?= Belli <darkbasic@linuxsystems.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:34742 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752407Ab2BWCGh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2012 21:06:37 -0500
Received: by wics10 with SMTP id s10so437293wic.19
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2012 18:06:36 -0800 (PST)
In-Reply-To: <4F459E37.9010507@linuxsystems.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 23 f=C3=A9vrier 2012 =C3=A0 03:02 +0100, Niccol=C3=B2 Belli a =
=C3=A9crit :
> Il 23/02/2012 02:38, Eric Dumazet ha scritto:
> > Which driver handles this Traverse Solos card ?
>=20
> drivers/atm/solos-pci.c
>=20
> ~# lsmod | grep solos
> solos_pci              20009  2
> atm                    32378  7 pppoatm,br2684,solos_pci
>=20

Thanks !

Please try following patch.

diff --git a/net/ipv4/xfrm4_mode_tunnel.c b/net/ipv4/xfrm4_mode_tunnel.=
c
index 534972e..f170933 100644
--- a/net/ipv4/xfrm4_mode_tunnel.c
+++ b/net/ipv4/xfrm4_mode_tunnel.c
@@ -84,9 +84,11 @@ static int xfrm4_mode_tunnel_input(struct xfrm_state=
 *x, struct sk_buff *skb)
 	if (!(x->props.flags & XFRM_STATE_NOECN))
 		ipip_ecn_decapsulate(skb);
=20
-	old_mac =3D skb_mac_header(skb);
-	skb_set_mac_header(skb, -skb->mac_len);
-	memmove(skb_mac_header(skb), old_mac, skb->mac_len);
+	if (skb_mac_header_was_set(skb)) {
+		old_mac =3D skb_mac_header(skb);
+		skb_set_mac_header(skb, -skb->mac_len);
+		memmove(skb_mac_header(skb), old_mac, skb->mac_len);
+	}
 	skb_reset_network_header(skb);
 	err =3D 0;
=20
