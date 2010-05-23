From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: Receiving of priority tagged packets
Date: Sun, 23 May 2010 22:32:31 +0200
Message-ID: <1274646751.5020.78.camel@edumazet-laptop>
References: <8628FE4E7912BF47A96AE7DD7BAC0AADDDC6675BEC@SJEXCHCCR02.corp.ad.broadcom.com>
	 <1274609194.5020.68.camel@edumazet-laptop>
	 <8628FE4E7912BF47A96AE7DD7BAC0AADDDC6675BF5@SJEXCHCCR02.corp.ad.broadcom.com>
	 <8628FE4E7912BF47A96AE7DD7BAC0AADDDC6675BF8@SJEXCHCCR02.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Vladislav Zolotarov <vladz@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:35406 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754047Ab0EWUcg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 May 2010 16:32:36 -0400
Received: by wwe15 with SMTP id 15so82590wwe.19
        for <netdev@vger.kernel.org>; Sun, 23 May 2010 13:32:34 -0700 (PDT)
In-Reply-To: <8628FE4E7912BF47A96AE7DD7BAC0AADDDC6675BF8@SJEXCHCCR02.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 23 mai 2010 =C3=A0 03:51 -0700, Vladislav Zolotarov a =C3=A9=
crit :
>=20
> > -----Original Message-----
> > From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel=
=2Eorg] On
> > Behalf Of Vladislav Zolotarov
> > Sent: Sunday, May 23, 2010 1:23 PM
> > To: Eric Dumazet
> > Cc: netdev@vger.kernel.org
> > Subject: RE: Receiving of priority tagged packets
> >=20
> >=20
> > > -----Original Message-----
> > > From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
> > > Sent: Sunday, May 23, 2010 1:07 PM
> > > To: Vladislav Zolotarov
> > > Cc: netdev@vger.kernel.org
> > > Subject: Re: Receiving of priority tagged packets
> > >
> > > Le dimanche 23 mai 2010 =C3=A0 02:36 -0700, Vladislav Zolotarov a=
 =C3=A9crit :
> > > > Hello,
> > > > We were playing with FCoE in our labs and saw the strange behav=
ior of
> > Linux
> > > networking stack in regard to priority-tagged frames (the ones th=
at have a
> > > zero VID in a VLAN tag). We saw that until we explicitly added a =
zero vlan
> > > interface (vconfig add ethX 0) the stack refused to accept such p=
ackets
> > both
> > > in HW VLAN acceleration mode (skb is indicated using
> > > vlan_hwaccel_receive_skb()) and in a regular mode (skb is indicat=
ed with
> > > netif_receive_skb()).
> > > >
> > > > However "IEEE Std 802.1Q, 2006 Edition DRAFT D0.1" in section 6=
=2E7 states
> > > the following:
> > > >
> > > > Each Bridge Port shall support the following parameters for use=
 by these
> > > (EISS tagging and detagging) functions:
> > > > 	c) an Acceptable Frame Types parameter with at least one of th=
e
> > > following values:
> > > > 		1) Admit Only VLAN-tagged frames;
> > > > 		2) Admit Only Untagged and Priority-tagged frames;
> > > > 		3) Admit All frames
> > > >
> > > > So I guess this means that priority tagged frames should be acc=
epted
> > > together with the untagged frames on the default interface ethX.
> > > >
> > > > Could anyone explain, pls., what's the expected behavior of the=
 Linux
> > > Networking Stack in regard to the priority-tagged frames and what=
's
> > expected
> > > to be configured in order to start accepting them?
> > > >
> > > > Thanks in advance,
> > > > vlad
> > >
> > > So if eth0.0 is setup, incoming vlanid=3D0 frames are delivered t=
o eth0.0,
> > > OK ? (This works in and out since commit 05423b241311c93)
> > >
> > > Now, if eth0.0 is not setup, you believe these frames should be d=
irected
> > > to eth0, as if they were not tagged ?
> > >
> > > That seems a bit strange.
> >=20
> > Well, as far as I understood this is what IEEE 802.1Q spec states..=
=2E
>=20
> From the same spec:
>=20
> ***************
> 3.38 Priority-tagged frame: A tagged frame whose tag header carries p=
riority information but carries no
> VLAN identification information.
> ***************
>=20
> Namely priority-tagged frames are frames that carry no VLAN identific=
ation information and namely should be treated as non-VLAN packets.
>=20
> However, as u mentioned above, current Networking Stack implementatio=
n handles them as if they have VID 0.
>=20
> These two are quite different ways to handle the frame, don=E2=80=99t=
 u think?

=46ollowing patch should fix it ?

=46allback to ethX is ethX.0 is not used.

diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index bd537fc..909f6e7 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -8,6 +8,9 @@
 int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
 		      u16 vlan_tci, int polling)
 {
+	struct net_device *vlan_dev;
+	u16 vlan_id;
+
 	if (netpoll_rx(skb))
 		return NET_RX_DROP;
=20
@@ -16,10 +19,14 @@ int __vlan_hwaccel_rx(struct sk_buff *skb, struct v=
lan_group *grp,
=20
 	skb->skb_iif =3D skb->dev->ifindex;
 	__vlan_hwaccel_put_tag(skb, vlan_tci);
-	skb->dev =3D vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);
+	vlan_id =3D vlan_tci & VLAN_VID_MASK;
+	vlan_dev =3D vlan_group_get_device(grp, vlan_id);
=20
-	if (!skb->dev)
-		goto drop;
+	if (vlan_dev)
+		skb->dev =3D vlan_dev;
+	else
+		if (vlan_id)
+			goto drop;
=20
 	return (polling ? netif_receive_skb(skb) : netif_rx(skb));
=20
@@ -82,16 +89,22 @@ vlan_gro_common(struct napi_struct *napi, struct vl=
an_group *grp,
 		unsigned int vlan_tci, struct sk_buff *skb)
 {
 	struct sk_buff *p;
+	struct net_device *vlan_dev;
+	u16 vlan_id;
=20
 	if (skb_bond_should_drop(skb, ACCESS_ONCE(skb->dev->master)))
 		goto drop;
=20
 	skb->skb_iif =3D skb->dev->ifindex;
 	__vlan_hwaccel_put_tag(skb, vlan_tci);
-	skb->dev =3D vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);
-
-	if (!skb->dev)
-		goto drop;
+	vlan_id =3D vlan_tci & VLAN_VID_MASK;
+	vlan_dev =3D vlan_group_get_device(grp, vlan_id);
+
+	if (vlan_dev)
+		skb->dev =3D vlan_dev;
+	else
+		if (vlan_id)
+			goto drop;
=20
 	for (p =3D napi->gro_list; p; p =3D p->next) {
 		NAPI_GRO_CB(p)->same_flow =3D




