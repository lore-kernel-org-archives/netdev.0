From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [net-next PATCH v2 5/9] mlx4: Add support for UDP tunnel
 segmentation with outer checksum offload
Date: Sun, 1 May 2016 23:28:59 +0300
Message-ID: <CALzJLG9+s+u54ELmUKHMLaa70vWPhXp=-4=Kj9uvooLpXUsvoQ@mail.gmail.com>
References: <20160429222735.12418.61229.stgit@ahduyck-xeon-server> <20160429224333.12418.13862.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tal Alon <talal@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	michael.chan@broadcom.com, "David S. Miller" <davem@davemloft.net>,
	Gal Pressman <galp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:34071 "EHLO
	mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752150AbcEAU3T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 May 2016 16:29:19 -0400
Received: by mail-yw0-f195.google.com with SMTP id i22so16834621ywc.1
        for <netdev@vger.kernel.org>; Sun, 01 May 2016 13:29:19 -0700 (PDT)
In-Reply-To: <20160429224333.12418.13862.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 30, 2016 at 1:43 AM, Alexander Duyck <aduyck@mirantis.com> wrote:
> This patch assumes that the mlx4 hardware will ignore existing IPv4/v6
> header fields for length and checksum as well as the length and checksum
> fields for outer UDP headers.
>
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   17 +++++++++++++----
>  1 file changed, 13 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> index 8bd143dda95d..bce37cbfde24 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> @@ -2358,7 +2358,9 @@ out:
>
>         /* set offloads */
>         priv->dev->hw_enc_features |= NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
> -                                     NETIF_F_TSO | NETIF_F_GSO_UDP_TUNNEL;
> +                                     NETIF_F_TSO | NETIF_F_GSO_UDP_TUNNEL |
> +                                     NETIF_F_GSO_UDP_TUNNEL_CSUM |
> +                                     NETIF_F_GSO_PARTIAL;
>  }
>
>  static void mlx4_en_del_vxlan_offloads(struct work_struct *work)
> @@ -2368,7 +2370,9 @@ static void mlx4_en_del_vxlan_offloads(struct work_struct *work)
>                                                  vxlan_del_task);
>         /* unset offloads */
>         priv->dev->hw_enc_features &= ~(NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
> -                                     NETIF_F_TSO | NETIF_F_GSO_UDP_TUNNEL);
> +                                       NETIF_F_TSO | NETIF_F_GSO_UDP_TUNNEL |
> +                                       NETIF_F_GSO_UDP_TUNNEL_CSUM |
> +                                       NETIF_F_GSO_PARTIAL);

I know it is not related to your patch, but is it ok to dynamically
modify priv->dev->hw_enc_features every vxlan add/del_port request ?
especially on a deferred work !
Shouldn't we at least notify the stack ?
