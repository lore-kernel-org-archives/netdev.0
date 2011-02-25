From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] be2net: add rxhash support
Date: Fri, 25 Feb 2011 19:21:36 +0100
Message-ID: <1298658096.2659.101.camel@edumazet-laptop>
References: <20110225174425.GA11203@akhaparde-VBox>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ajit Khaparde <ajit.khaparde@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:63140 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756259Ab1BYSVn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 13:21:43 -0500
Received: by bwz15 with SMTP id 15so2185147bwz.19
        for <netdev@vger.kernel.org>; Fri, 25 Feb 2011 10:21:42 -0800 (PST)
In-Reply-To: <20110225174425.GA11203@akhaparde-VBox>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 25 f=C3=A9vrier 2011 =C3=A0 11:44 -0600, Ajit Khaparde a =C3=
=A9crit :
> > -----Original Message-----
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Sent: Thursday, February 24, 2011 2:25 PM
> > To: Khaparde, Ajit
> > Cc: netdev@vger.kernel.org
> > Subject: [RFC] be2net: add rxhash support
> >=20
> > Ajit, it seems be2net provides RSS hash value in rx compl descripto=
r ?
> >=20
> > Could we feed skb->rxhash with it ?
> >=20
> > Thanks !
> Thanks Eric. Sure.
> This is a long pending change which fell through the cracks.
> But then because hashing is enabled in the device only when
> Number of Rx Queues is > 1, I would suggest the following patch.
>=20
> Unaware of exact conventions, I have added signed-off-by to the patch=
 already.
>=20
> Thanks
>=20
> -----
> [PATCH net-next] be2net: add rxhash support
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
> ---
>  drivers/net/benet/be_main.c |   11 +++++++++++
>  1 files changed, 11 insertions(+), 0 deletions(-)
>=20
> diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.=
c
> index 26f9c56..8c4b782 100644
> --- a/drivers/net/benet/be_main.c
> +++ b/drivers/net/benet/be_main.c
> @@ -1038,6 +1038,10 @@ static void be_rx_compl_process(struct be_adap=
ter *adapter,
> =20
>  	skb->truesize =3D skb->len + sizeof(struct sk_buff);
>  	skb->protocol =3D eth_type_trans(skb, adapter->netdev);
> +	if (adapter->netdev->features & NETIF_F_RXHASH)
> +		skb->rxhash =3D AMAP_GET_BITS(struct amap_eth_rx_compl,
> +					rsshash, rxcp);
> +
> =20
>  	vlanf =3D AMAP_GET_BITS(struct amap_eth_rx_compl, vtp, rxcp);
>  	vtm =3D AMAP_GET_BITS(struct amap_eth_rx_compl, vtm, rxcp);
> @@ -1099,6 +1103,10 @@ static void be_rx_compl_process_gro(struct be_=
adapter *adapter,
>  		return;
>  	}
> =20
> +	if (adapter->netdev->features & NETIF_F_RXHASH)
> +		skb->rxhash =3D AMAP_GET_BITS(struct amap_eth_rx_compl,
> +						rsshash, rxcp);
> +
>  	remaining =3D pkt_size;
>  	for (i =3D 0, j =3D -1; i < num_rcvd; i++) {
>  		page_info =3D get_rx_page_info(adapter, rxo, rxq_idx);
> @@ -2619,6 +2627,9 @@ static void be_netdev_init(struct net_device *n=
etdev)
>  		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
>  		NETIF_F_GRO | NETIF_F_TSO6;
> =20
> +	if (be_multi_rxq(adapter))
> +		netdev->features |=3D NETIF_F_RXHASH;
> +
>  	netdev->vlan_features |=3D NETIF_F_SG | NETIF_F_TSO |
>  		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
> =20


I added some traces, and I am not sure its OK :

With one active tcp flow, I got different rxhash values :

[ 1064.674253] rxhash=3Dbbd37952 rsshp=3D1 bank=3D1
[ 1064.738104] rxhash=3D37acd31d rsshp=3D1 bank=3D1
[ 1064.741684] rxhash=3Dbbd37952 rsshp=3D1 bank=3D1
[ 1064.874283] rxhash=3Dbbd37952 rsshp=3D1 bank=3D1
[ 1064.940201] rxhash=3Dbbd37952 rsshp=3D1 bank=3D1
[ 1064.955278] rxhash=3Db668ace2 rsshp=3D1 bank=3D1
[ 1065.080028] rxhash=3Dbbd37952 rsshp=3D1 bank=3D1
[ 1065.153360] rxhash=3Dbbd37952 rsshp=3D1 bank=3D1
[ 1065.293164] rxhash=3Dbbd37952 rsshp=3D1 bank=3D1
[ 1065.401862] rxhash=3Dbbd37952 rsshp=3D1 bank=3D1
[ 1065.460506] rxhash=3Dbbd37952 rsshp=3D1 bank=3D1
[ 1065.519980] rxhash=3Dbbd37952 rsshp=3D1 bank=3D1
[ 1065.650160] rxhash=3Dbbd37952 rsshp=3D1 bank=3D1
[ 1065.717585] rxhash=3Dbbd37952 rsshp=3D1 bank=3D1
[ 1065.730909] rxhash=3D37acd31d rsshp=3D1 bank=3D1
[ 1065.840350] rxhash=3Dbbd37952 rsshp=3D1 bank=3D1
[ 1065.900704] rxhash=3Dbbd37952 rsshp=3D1 bank=3D1
[ 1065.931526] rxhash=3Db668ace2 rsshp=3D1 bank=3D1
[ 1066.503657] rxhash=3Dbbd37952 rsshp=3D1 bank=3D1
[ 1066.570138] rxhash=3Dbbd37952 rsshp=3D1 bank=3D1

How is it possible ?

(I have a VLAN config on top of a bonding)



