From: Patrick McHardy <kaber@trash.net>
Subject: Re: VLAN I/F's and TX queue.
Date: Mon, 10 May 2010 16:26:27 +0200
Message-ID: <4BE81793.3060905@trash.net>
References: <OF5A42C874.3AF220FE-ONC1257718.003ABC6E-C1257718.003F94D2@LocalDomain>	 <OF3F4D7278.DC6A6E51-ONC125771C.002B1AF4-C125771C.002C64E3@transmode.se> <1273222403.2261.26.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joakim Tjernlund <joakim.tjernlund@transmode.se>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47114 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750715Ab0EJO0c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 10:26:32 -0400
In-Reply-To: <1273222403.2261.26.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Le vendredi 07 mai 2010 =E0 10:04 +0200, Joakim Tjernlund a =E9crit :
>> So I did some more testing
>> two nodes A and B connected over a slow link.
>> Create two VLAN's as above and start pinging from A to B
>> with pkg size 9600, start a few(4-10) parallel ping processes.
>>
>> Now I see dropped packages on B, the receiver of pings, and no
>> pkg loss on A.
>>
>=20
> dropped on RX path or TX path ?
>=20
>> 1) since the link is symmetrical, why do I only see pkg loss
>>    at B?
>>
>> 2) pkg loss in B only manifests on the VLAN's interfaces and
>>    always in pair as if one lost pkg is counted twice?
>>
>=20
> Congestion notifications can be stacked since commit cbbef5e183079
> (vlan/macvlan: propagate transmission state to upper layers)
>=20
>> 3) I would expect lost pkgs to be accounted on eth0 instead of
>>    the VLAN interface(s) since that is where the pkg is lost, why
>>    isn't it so?
>=20
> You try to send packets on eth0.XXX, some are dropped, and accounted =
for
> on eth0.XXX stats. What is wrong with this ?
>=20
> If you want to avoid this, just add queues to your vlans
>=20
> ip link add link eth0 eth0.103 txqueuelen 100 type vlan id 103
>=20
> Patrick what do you think of special casing NET_XMIT_CN ?

Is the intention just to avoid accounting the packet as dropped?
That seems fine to me since in case of NET_XMIT_CN its actually
not the currently transmitted packet that was dropped.

But part of the intention of the above mentioned patch was actually
to inform higher layers of congestion so they can take action if
desired, which would be defeated by this patch.

> diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
> index b5249c5..c671b1a 100644
> --- a/net/8021q/vlan_dev.c
> +++ b/net/8021q/vlan_dev.c
> @@ -327,6 +327,8 @@ static netdev_tx_t vlan_dev_hard_start_xmit(struc=
t sk_buff *skb,
>  	len =3D skb->len;
>  	ret =3D dev_queue_xmit(skb);
> =20
> +	ret =3D net_xmit_eval(ret);
> +
>  	if (likely(ret =3D=3D NET_XMIT_SUCCESS)) {
>  		txq->tx_packets++;
>  		txq->tx_bytes +=3D len;
> @@ -353,6 +355,8 @@ static netdev_tx_t vlan_dev_hwaccel_hard_start_xm=
it(struct sk_buff *skb,
>  	len =3D skb->len;
>  	ret =3D dev_queue_xmit(skb);
> =20
> +	ret =3D net_xmit_eval(ret);
> +
>  	if (likely(ret =3D=3D NET_XMIT_SUCCESS)) {
>  		txq->tx_packets++;
>  		txq->tx_bytes +=3D len;
>=20
>=20

