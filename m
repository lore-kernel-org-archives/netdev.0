From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: VLAN I/F's and TX queue.
Date: Fri, 07 May 2010 10:53:23 +0200
Message-ID: <1273222403.2261.26.camel@edumazet-laptop>
References: <OF5A42C874.3AF220FE-ONC1257718.003ABC6E-C1257718.003F94D2@LocalDomain>
	 <OF3F4D7278.DC6A6E51-ONC125771C.002B1AF4-C125771C.002C64E3@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:50419 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754589Ab0EGIxa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 May 2010 04:53:30 -0400
Received: by bwz19 with SMTP id 19so438636bwz.21
        for <netdev@vger.kernel.org>; Fri, 07 May 2010 01:53:27 -0700 (PDT)
In-Reply-To: <OF3F4D7278.DC6A6E51-ONC125771C.002B1AF4-C125771C.002C64E3@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 07 mai 2010 =C3=A0 10:04 +0200, Joakim Tjernlund a =C3=A9cr=
it :
> Joakim Tjernlund/Transmode wrote on 2010/05/03 13:34:28:
> >
> > We noted dropped pkgs on our VLAN interfaces and i stated to look
> > for a cause. Here is a ifconfig example:
> >
> > eth0      Link encap:Ethernet  HWaddr 00:AA:BB:CC:DD:EE
> >           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
> >           RX packets:8886910 errors:0 dropped:0 overruns:0 frame:0
> >           TX packets:8880219 errors:0 dropped:0 overruns:0 carrier:=
0
> >           collisions:0 txqueuelen:100
> >           RX bytes:1626842951 (1.5 GiB)  TX bytes:1555540810 (1.4 G=
iB)
> >
> > eth0.1    Link encap:Ethernet  HWaddr 00:AA:BB:CC:DD:EE
> >           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
> >           RX packets:2163164 errors:0 dropped:0 overruns:0 frame:0
> >           TX packets:2161943 errors:0 dropped:98 overruns:0 carrier=
:0
> >           collisions:0 txqueuelen:0
> >           RX bytes:2467090557 (2.2 GiB)  TX bytes:2480246455 (2.3 G=
iB)
> >
> > eth0.1.1  Link encap:Ethernet  HWaddr 00:AA:BB:CC:DD:EE
> >           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
> >           RX packets:2163164 errors:0 dropped:0 overruns:0 frame:0
> >           TX packets:2161943 errors:0 dropped:98 overruns:0 carrier=
:0
> >           collisions:0 txqueuelen:0
> >           RX bytes:2458437901 (2.2 GiB)  TX bytes:2471598683 (2.3 G=
iB)
> >
> > Here I note that txqueuelen is 0 for eth0.1/eth0.1.1 and 100 for et=
h0 and
> > that it is only eth0.1 and eth0.1.1 that drops pkgs. It feels as if=
 eth0.1
> > bypasses eth0's tx queue and passes pkgs directly to the HW driver.=
 Is that so?
> > If so, that feels a bit strange and I am not sure how to best
> > fix this. Any ides?
> >
> > Using kernel 2.6.33
>=20
> So I did some more testing
> two nodes A and B connected over a slow link.
> Create two VLAN's as above and start pinging from A to B
> with pkg size 9600, start a few(4-10) parallel ping processes.
>=20
> Now I see dropped packages on B, the receiver of pings, and no
> pkg loss on A.
>=20

dropped on RX path or TX path ?

> 1) since the link is symmetrical, why do I only see pkg loss
>    at B?
>=20
> 2) pkg loss in B only manifests on the VLAN's interfaces and
>    always in pair as if one lost pkg is counted twice?
>=20

Congestion notifications can be stacked since commit cbbef5e183079
(vlan/macvlan: propagate transmission state to upper layers)

> 3) I would expect lost pkgs to be accounted on eth0 instead of
>    the VLAN interface(s) since that is where the pkg is lost, why
>    isn't it so?

You try to send packets on eth0.XXX, some are dropped, and accounted fo=
r
on eth0.XXX stats. What is wrong with this ?

If you want to avoid this, just add queues to your vlans

ip link add link eth0 eth0.103 txqueuelen 100 type vlan id 103

Patrick what do you think of special casing NET_XMIT_CN ?


diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index b5249c5..c671b1a 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -327,6 +327,8 @@ static netdev_tx_t vlan_dev_hard_start_xmit(struct =
sk_buff *skb,
 	len =3D skb->len;
 	ret =3D dev_queue_xmit(skb);
=20
+	ret =3D net_xmit_eval(ret);
+
 	if (likely(ret =3D=3D NET_XMIT_SUCCESS)) {
 		txq->tx_packets++;
 		txq->tx_bytes +=3D len;
@@ -353,6 +355,8 @@ static netdev_tx_t vlan_dev_hwaccel_hard_start_xmit=
(struct sk_buff *skb,
 	len =3D skb->len;
 	ret =3D dev_queue_xmit(skb);
=20
+	ret =3D net_xmit_eval(ret);
+
 	if (likely(ret =3D=3D NET_XMIT_SUCCESS)) {
 		txq->tx_packets++;
 		txq->tx_bytes +=3D len;


