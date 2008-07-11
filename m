From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 10/13]: net: Implement simple sw TX hashing.
Date: Fri, 11 Jul 2008 22:49:47 +0200
Message-ID: <4877C76B.6010504@cosmosbay.com>
References: <20080710.035713.204601759.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2e.orange.fr ([80.12.242.113]:56299 "EHLO smtp2e.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752221AbYGKUxn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2008 16:53:43 -0400
In-Reply-To: <20080710.035713.204601759.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> It just xor hashes over IPv4/IPv6 addresses and ports of transport.
>=20
> The only assumption it makes is that skb_network_header() is set
> correctly.
>=20
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/core/dev.c |   52 ++++++++++++++++++++++++++++++++++++++++++++++=
++++++
>  1 files changed, 52 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/core/dev.c b/net/core/dev.c
> index db95b49..62459ea 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -121,6 +121,9 @@
>  #include <linux/ctype.h>
>  #include <linux/if_arp.h>
>  #include <linux/if_vlan.h>
> +#include <linux/ip.h>
> +#include <linux/ipv6.h>
> +#include <linux/in.h>
> =20
>  #include "net-sysfs.h"
> =20
> @@ -1665,6 +1668,53 @@ out_kfree_skb:
>   *          --BLG
>   */
> =20
> +static u16 simple_tx_hash(struct net_device *dev, struct sk_buff *sk=
b)
> +{
> +	u32 *addr, *ports, hash, ihl;
> +	u8 ip_proto;
> +	int alen;
> +
> +	switch (skb->protocol) {
> +	case __constant_htons(ETH_P_IP):
> +		ip_proto =3D ip_hdr(skb)->protocol;
> +		addr =3D &ip_hdr(skb)->saddr;
> +		ihl =3D ip_hdr(skb)->ihl;
> +		alen =3D 2;
> +		break;
> +	case __constant_htons(ETH_P_IPV6):
> +		ip_proto =3D ipv6_hdr(skb)->nexthdr;
> +		addr =3D &ipv6_hdr(skb)->saddr.s6_addr32[0];
> +		ihl =3D (40 >> 2);
> +		alen =3D 8;
> +		break;
> +	default:
> +		return 0;
> +	}
> +
> +	ports =3D (u32 *) (skb_network_header(skb) + (ihl * 4));
> +
> +	hash =3D 0;
> +	while (alen--)
> +		hash ^=3D *addr++;
> +
> +	switch (ip_proto) {
> +	case IPPROTO_TCP:
> +	case IPPROTO_UDP:
> +	case IPPROTO_DCCP:
> +	case IPPROTO_ESP:
> +	case IPPROTO_AH:
> +	case IPPROTO_SCTP:
> +	case IPPROTO_UDPLITE:
> +		hash ^=3D *ports;
> +		break;
> +
> +	default:
> +		break;
> +	}
> +
> +	return hash % dev->real_num_tx_queues;

simple but expensive... but could be changed to use reciprocal_divide()=
 if necessary...

> +}
> +
>  static struct netdev_queue *dev_pick_tx(struct net_device *dev,
>  					struct sk_buff *skb)
>  {
> @@ -1672,6 +1722,8 @@ static struct netdev_queue *dev_pick_tx(struct =
net_device *dev,
> =20
>  	if (dev->select_queue)
>  		queue_index =3D dev->select_queue(dev, skb);
> +	else if (dev->real_num_tx_queues)

I guess your intent was to check you have at least 2 queues ?

"else if (dev->real_num_tx_queues > 1)"

> +		queue_index =3D simple_tx_hash(dev, skb);
> =20
>  	skb_set_queue_mapping(skb, queue_index);
>  	return netdev_get_tx_queue(dev, queue_index);




