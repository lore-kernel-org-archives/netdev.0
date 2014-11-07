From: Ido Shamay <idos@dev.mellanox.co.il>
Subject: Re: [PATCH V2 net-next 2/2] net/mlx4_en: Extend checksum offloading
 by CHECKSUM COMPLETE
Date: Fri, 07 Nov 2014 10:40:34 +0200
Message-ID: <545C8582.4070408@dev.mellanox.co.il>
References: <1415291324-22069-1-git-send-email-ogerlitz@mellanox.com> <1415291324-22069-3-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Shani Michaeli <shanim@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Jerry Chu <hkchu@google.com>
To: Or Gerlitz <ogerlitz@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:36632 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750962AbaKGIkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2014 03:40:43 -0500
Received: by mail-wg0-f50.google.com with SMTP id z12so3117906wgg.37
        for <netdev@vger.kernel.org>; Fri, 07 Nov 2014 00:40:42 -0800 (PST)
In-Reply-To: <1415291324-22069-3-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/6/2014 6:28 PM, Or Gerlitz wrote:
>   		if (likely(dev->features & NETIF_F_RXCSUM)) {
> -			if ((cqe->status & cpu_to_be16(MLX4_CQE_STATUS_IPOK)) &&
> -			    (cqe->checksum == cpu_to_be16(0xffff))) {
> -				ring->csum_ok++;
> -				ip_summed = CHECKSUM_UNNECESSARY;
> +			if (cqe->status & cpu_to_be16(MLX4_CQE_STATUS_TCP |
> +						      MLX4_CQE_STATUS_UDP)) {
> +				if ((cqe->status & cpu_to_be16(MLX4_CQE_STATUS_IPOK)) &&
> +				    cqe->checksum == cpu_to_be16(0xffff)) {
> +					ip_summed = CHECKSUM_UNNECESSARY;
> +					ring->csum_ok++;
> +				} else {
> +					ip_summed = CHECKSUM_NONE;
> +					ring->csum_none++;
> +				}
>   			} else {
> -				ip_summed = CHECKSUM_NONE;
> -				ring->csum_none++;
> +				if (priv->flags & MLX4_EN_FLAG_RX_CSUM_NON_TCP_UDP &&
> +				    (cqe->status & cpu_to_be16(MLX4_CQE_STATUS_IPV4 |
> +							       MLX4_CQE_STATUS_IPV6))) {
> +					ip_summed = CHECKSUM_COMPLETE;
> +					ring->csum_complete++;
> +				} else {
> +					ip_summed = CHECKSUM_NONE;
> +					ring->csum_none++;
> +				}
>   			}
>   		} else {
>   			ip_summed = CHECKSUM_NONE;
> @@ -776,6 +874,14 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
>   			if (!nr)
>   				goto next;
>
> +			if (ip_summed == CHECKSUM_COMPLETE) {
> +				va = skb_frag_address(skb_shinfo(gro_skb)->frags);
> +				if (check_csum(cqe, gro_skb, va, ring->hwtstamp_rx_filter)) {
> +					ip_summed = CHECKSUM_NONE;
> +					ring->csum_none++;

When check_csum returns non zero value, then ring->csum_complete counter 
was already incremented, and now we are incrementing ring->csum_none 
(for the same packet), so need to --ring->csum_complete.
