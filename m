From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] bonding: allow arp_ip_targets to be on a
 separate vlan from bond device
Date: Wed, 02 Dec 2009 06:13:15 +0100
Message-ID: <4B15F76B.9040203@gmail.com>
References: <20091130201453.GF1639@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, fubar@us.ibm.com
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:36267 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750935AbZLBFNN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 00:13:13 -0500
In-Reply-To: <20091130201453.GF1639@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Gospodarek a =E9crit :
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 5d131c2..eeee269 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2439,8 +2439,8 @@ int netif_receive_skb(struct sk_buff *skb)
>  		skb->skb_iif =3D skb->dev->ifindex;
> =20
>  	null_or_orig =3D NULL;
> -	orig_dev =3D skb->dev;
> -	if (orig_dev->master) {
> +	orig_dev =3D __dev_get_by_index(dev_net(skb->dev),skb->skb_iif);
> +	if (orig_dev->master && !(skb->dev->priv_flags & IFF_802_1Q_VLAN)) =
{
>  		if (skb_bond_should_drop(skb))
>  			null_or_orig =3D orig_dev; /* deliver only exact match */
>  		else


Please dont add a __dev_get_by_index() call in netif_receive_skb()

=46irst, this is not safe against writers.

Second its very expensive on some setups.

Eventually, you could do something like :


Change prototypes of netif_receive_skb() to include the orig_dev in arg=
uments.
Change vlan code to call __netif_receive_skb(skb, orig_dev)
instead of netif_received_skb(skb)

int __netif_receive_skb(struct sk_buff *skb, struct net_device *orig_de=
v)
{
=2E..
	if (!skb->skb_iif) {
		skb->skb_iif =3D orig_dev->ifindex;
	} else {
		if (orig_dev->master &&  ...)=20
	}

}

int netif_receive_skb(struct sk_buff *skb)
{
	return __netif_receive_skb(skb, skb->dev);
}

