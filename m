From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6] net: remove the unnecessary dance around
 skb_bond_should_drop
Date: Sat, 12 Feb 2011 13:51:29 +0100
Message-ID: <4D568251.7000305@gmail.com>
References: <20110212104605.GA2786@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:54907 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751929Ab1BLMvd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Feb 2011 07:51:33 -0500
Received: by bwz15 with SMTP id 15so4060086bwz.19
        for <netdev@vger.kernel.org>; Sat, 12 Feb 2011 04:51:32 -0800 (PST)
In-Reply-To: <20110212104605.GA2786@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 12/02/2011 11:46, Jiri Pirko a =E9crit :
> No need to check (master) twice and to drive in and out the header fi=
le.
>
> Signed-off-by: Jiri Pirko<jpirko@redhat.com>

Reviewed-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>

> ---
>   include/linux/netdevice.h |   11 -----------
>   net/core/dev.c            |    6 +++---
>   2 files changed, 3 insertions(+), 14 deletions(-)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index c7d7074..5a5baea 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -2437,17 +2437,6 @@ static inline void netif_set_gso_max_size(stru=
ct net_device *dev,
>   	dev->gso_max_size =3D size;
>   }
>
> -extern int __skb_bond_should_drop(struct sk_buff *skb,
> -				  struct net_device *master);
> -
> -static inline int skb_bond_should_drop(struct sk_buff *skb,
> -				       struct net_device *master)
> -{
> -	if (master)
> -		return __skb_bond_should_drop(skb, master);
> -	return 0;
> -}
> -
>   extern struct pernet_operations __net_initdata loopback_net_ops;
>
>   static inline int dev_ethtool_get_settings(struct net_device *dev,
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 6392ea0..d874fd1 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3105,7 +3105,8 @@ static inline void skb_bond_set_mac_by_master(s=
truct sk_buff *skb,
>    * duplicates except for 802.3ad ETH_P_SLOW, alb non-mcast/bcast, a=
nd
>    * ARP on active-backup slaves with arp_validate enabled.
>    */
> -int __skb_bond_should_drop(struct sk_buff *skb, struct net_device *m=
aster)
> +static int __skb_bond_should_drop(struct sk_buff *skb,
> +				  struct net_device *master)
>   {
>   	struct net_device *dev =3D skb->dev;
>
> @@ -3139,7 +3140,6 @@ int __skb_bond_should_drop(struct sk_buff *skb,=
 struct net_device *master)
>   	}
>   	return 0;
>   }
> -EXPORT_SYMBOL(__skb_bond_should_drop);
>
>   static int __netif_receive_skb(struct sk_buff *skb)
>   {
> @@ -3177,7 +3177,7 @@ static int __netif_receive_skb(struct sk_buff *=
skb)
>   	if (skb->deliver_no_wcard)
>   		null_or_orig =3D orig_dev;
>   	else if (master) {
> -		if (skb_bond_should_drop(skb, master)) {
> +		if (__skb_bond_should_drop(skb, master)) {
>   			skb->deliver_no_wcard =3D 1;
>   			null_or_orig =3D orig_dev; /* deliver only exact match */
>   		} else

