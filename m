From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next] bonding: handle more gso types
Date: Fri, 23 Jan 2015 10:33:31 -0800
Message-ID: <CA+mtBx98Hem6+L1gt9ZK-JDs0f=aNdJakFnGWspoTzdYcAcpBA@mail.gmail.com>
References: <1422021446.29618.8.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:43930 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752510AbbAWSdc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 13:33:32 -0500
Received: by mail-ie0-f170.google.com with SMTP id y20so4612622ier.1
        for <netdev@vger.kernel.org>; Fri, 23 Jan 2015 10:33:32 -0800 (PST)
In-Reply-To: <1422021446.29618.8.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 23, 2015 at 5:57 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> In commit 5a7baa78851b ("bonding: Advertize vxlan offload features when
> supported"), Or Gerlitz added support conditional vxlan offload.
>
> In this patch I also add support for GRE, IPIP and SIT tunnels,
> but we allow a bonding device to not require segmentation,
> as it is always better to make this segmentation at the very last stage,
> if a particular slave device requires it.
>
> Tested:
>
> ethtool -K bond0 tx-gre-segmentation off
>
> super_netperf 50 --google-pacing-rate 30000000 -H 10.7.8.152 -l 15
> 7538.32
>
> ethtool -K bond0 tx-gre-segmentation on
>
> super_netperf 50 --google-pacing-rate 30000000 -H 10.7.8.152 -l 15
> 10200.5
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Or Gerlitz <ogerlitz@mellanox.com>
> ---
>  drivers/net/bonding/bond_main.c |    9 ++++++---
>  1 file changed, 6 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 0dceba1a2ba15f4706922a5423f680e7cd17ef77..1e837fceb3fb7b739c543b0d5babc4da4797caf3 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -998,7 +998,10 @@ static netdev_features_t bond_fix_features(struct net_device *dev,
>                                  NETIF_F_HIGHDMA | NETIF_F_LRO)
>
>  #define BOND_ENC_FEATURES      (NETIF_F_ALL_CSUM | NETIF_F_SG | NETIF_F_RXCSUM |\
> -                                NETIF_F_TSO | NETIF_F_GSO_UDP_TUNNEL)
> +                                NETIF_F_TSO)
> +
Is there any reason not to add NETIF_F_GSO_UDP_TUNNEL_CSUM and
NETIF_F_GSO_UDP_REMCSUM also?

> +#define BOND_ENC_ALWAYS                (NETIF_F_GSO_GRE | NETIF_F_GSO_IPIP | \
> +                                NETIF_F_GSO_SIT | NETIF_F_GSO_UDP_TUNNEL)
>
>  static void bond_compute_features(struct bonding *bond)
>  {
> @@ -1034,7 +1037,7 @@ static void bond_compute_features(struct bonding *bond)
>
>  done:
>         bond_dev->vlan_features = vlan_features;
> -       bond_dev->hw_enc_features = enc_features;
> +       bond_dev->hw_enc_features = enc_features | BOND_ENC_ALWAYS;
>         bond_dev->hard_header_len = max_hard_header_len;
>         bond_dev->gso_max_segs = gso_max_segs;
>         netif_set_gso_max_size(bond_dev, gso_max_size);
> @@ -4010,7 +4013,7 @@ void bond_setup(struct net_device *bond_dev)
>                                 NETIF_F_HW_VLAN_CTAG_FILTER;
>
>         bond_dev->hw_features &= ~(NETIF_F_ALL_CSUM & ~NETIF_F_HW_CSUM);
> -       bond_dev->hw_features |= NETIF_F_GSO_UDP_TUNNEL;
> +       bond_dev->hw_features |= BOND_ENC_ALWAYS;
>         bond_dev->features |= bond_dev->hw_features;
>  }
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
