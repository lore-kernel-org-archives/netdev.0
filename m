From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [RFC PATCH 2/5] mlx5: Add support for UDP tunnel segmentation
 with outer checksum offload
Date: Wed, 20 Apr 2016 20:40:22 +0300
Message-ID: <CALzJLG-8enmxxvjbVbcygVgM0VhX7Eo=6B=2pZF5jQzN9L9YEg@mail.gmail.com>
References: <20160419185949.11723.50506.stgit@ahduyck-xeon-server> <20160419190603.11723.31623.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: eugenia@mellanox.com, bruce.w.allan@intel.com,
	Saeed Mahameed <saeedm@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	intel-wired-lan@lists.osuosl.org, ariel.elior@qlogic.com,
	mchan@broadcom.com, Matthew Finlay <matt@mellanox.com>
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:36321 "EHLO
	mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751807AbcDTRkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 13:40:42 -0400
Received: by mail-yw0-f195.google.com with SMTP id u62so7683965ywe.3
        for <netdev@vger.kernel.org>; Wed, 20 Apr 2016 10:40:42 -0700 (PDT)
In-Reply-To: <20160419190603.11723.31623.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 19, 2016 at 10:06 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
> This patch assumes that the mlx5 hardware will ignore existing IPv4/v6
> header fields for length and checksum as well as the length and checksum
> fields for outer UDP headers.
>
> I have no means of testing this as I do not have any mlx5 hardware but
> thought I would submit it as an RFC to see if anyone out there wants to
> test this and see if this does in fact enable this functionality allowing
> us to to segment UDP tunneled frames that have an outer checksum.
>
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
> ---
>  drivers/net/ethernet/mellanox/mlx5/core/en_main.c |    7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> index e0adb604f461..57d8da796d50 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> @@ -2390,13 +2390,18 @@ static void mlx5e_build_netdev(struct net_device *netdev)
>         netdev->hw_features      |= NETIF_F_HW_VLAN_CTAG_FILTER;
>
>         if (mlx5e_vxlan_allowed(mdev)) {
> -               netdev->hw_features     |= NETIF_F_GSO_UDP_TUNNEL;
> +               netdev->hw_features     |= NETIF_F_GSO_UDP_TUNNEL |
> +                                          NETIF_F_GSO_UDP_TUNNEL_CSUM |
> +                                          NETIF_F_GSO_PARTIAL;
>                 netdev->hw_enc_features |= NETIF_F_IP_CSUM;
>                 netdev->hw_enc_features |= NETIF_F_RXCSUM;
>                 netdev->hw_enc_features |= NETIF_F_TSO;
>                 netdev->hw_enc_features |= NETIF_F_TSO6;
>                 netdev->hw_enc_features |= NETIF_F_RXHASH;
>                 netdev->hw_enc_features |= NETIF_F_GSO_UDP_TUNNEL;
> +               netdev->hw_enc_features |= NETIF_F_GSO_UDP_TUNNEL_CSUM |
> +                                          NETIF_F_GSO_PARTIAL;
> +               netdev->gso_partial_features = NETIF_F_GSO_UDP_TUNNEL_CSUM;
>         }
>
>         netdev->features          = netdev->hw_features;
>

Hi Alex,

Adding Matt, VxLAN feature owner from Mellanox,
Matt please correct me if am wrong, but We already tested GSO VxLAN
and we saw the TCP/IP checksum offloads for both inner and outer
headers handled by the hardware.

And looking at mlx5e_sq_xmit:

if (likely(skb->ip_summed == CHECKSUM_PARTIAL)) {
        eseg->cs_flags = MLX5_ETH_WQE_L3_CSUM;
if (skb->encapsulation) {
        eseg->cs_flags |= MLX5_ETH_WQE_L3_INNER_CSUM |
MLX5_ETH_WQE_L4_INNER_CSUM;
        sq->stats.csum_offload_inner++;
} else {
        eseg->cs_flags |= MLX5_ETH_WQE_L4_CSUM;
}

We enable inner/outer hardware checksumming unconditionally without
looking at the features Alex is suggesting in this patch,
Alex, can you elaborate more on the meaning of those features ? and
why would it work for us without declaring them ?
