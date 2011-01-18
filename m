From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] bnx2 + vlan + TSO : doesnt work
Date: Tue, 18 Jan 2011 01:00:44 +0100
Message-ID: <1295308844.3362.135.camel@edumazet-laptop>
References: <1295307669.3362.106.camel@edumazet-laptop>
	 <1295308041.6264.22.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jesse Gross <jesse@nicira.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:50362 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753215Ab1ARAAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jan 2011 19:00:49 -0500
Received: by wwa36 with SMTP id 36so5885592wwa.1
        for <netdev@vger.kernel.org>; Mon, 17 Jan 2011 16:00:47 -0800 (PST)
In-Reply-To: <1295308041.6264.22.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 17 janvier 2011 =C3=A0 23:47 +0000, Ben Hutchings a =C3=A9crit=
 :
> On Tue, 2011-01-18 at 00:41 +0100, Eric Dumazet wrote:
> > Oh well, my dev machine, with bnx2 and tg3 NICs, isnt working at al=
l
> > with current linux-2.6 tree (I need vlans on my setup)
> >=20
> > tg3 : vlan not working
> >=20
> > bnx2 : vlan + TSO not working (or very slowly, since only non GSO f=
rames
> > are OK)
> >=20
> > I suspect recent commits from Jesse are the problem.
> > (bnx2_xmit() is feeded with zeroed vlan_tci skbs)
> >=20
> > Maybe f01a5236bd4b1401 (net offloading: Generalize
> > netif_get_vlan_features().) ?
> >=20
> > I dont see NETIF_F_HW_VLAN_TX being set in vlan_features in net dri=
vers.
> > They only set this flag in dev->features
> >=20
> > I dont think changing all drivers to also set vlan_features makes s=
ense.
> >=20
> > Is following patch the right path ? (It does solve my problem)
>=20
> This isn't right.  NETIF_F_HW_VLAN_TX in vlan_features would mean tha=
t
> the hardware can do two levels of VLAN tag insertion, which is genera=
lly
> not true.
>=20

So should we revert part of Jesse patch ? I want my vlan back ;)

diff --git a/net/core/dev.c b/net/core/dev.c
index 54277df..8209d93 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2076,7 +2076,7 @@ int dev_hard_start_xmit(struct sk_buff *skb, stru=
ct net_device *dev,
 		features =3D netif_skb_features(skb);
=20
 		if (vlan_tx_tag_present(skb) &&
-		    !(features & NETIF_F_HW_VLAN_TX)) {
+		    !(dev->features & NETIF_F_HW_VLAN_TX)) {
 			skb =3D __vlan_put_tag(skb, vlan_tx_tag_get(skb));
 			if (unlikely(!skb))
 				goto out;


