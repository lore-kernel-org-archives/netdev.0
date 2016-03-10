From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next PATCH V2 2/3] mlx4: use napi_consume_skb API to get
 bulk free operations
Date: Thu, 10 Mar 2016 16:59:08 +0300
Message-ID: <56E17DAC.2060305@cogentembedded.com>
References: <20160310121414.3680.45727.stgit@firesoul>
 <20160310121542.3680.84170.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eugenia@mellanox.com, Alexander Duyck <alexander.duyck@gmail.com>,
	alexei.starovoitov@gmail.com, saeedm@mellanox.com,
	gerlitz.or@gmail.com
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:33278 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751550AbcCJN7P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 08:59:15 -0500
Received: by mail-lb0-f176.google.com with SMTP id k15so114261079lbg.0
        for <netdev@vger.kernel.org>; Thu, 10 Mar 2016 05:59:15 -0800 (PST)
In-Reply-To: <20160310121542.3680.84170.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 3/10/2016 3:15 PM, Jesper Dangaard Brouer wrote:

> Bulk free of SKBs happen transparently by the API call napi_consume_skb().
> The napi budget parameter is usually needed by napi_consume_skb()
> to detect if called from netpoll.  In this patch it have an extra meaning.

    It has.

> For mlx4 driver, the mlx4_en_stop_port() call is done outside
> NAPI/softirq context, and cleanup the entire TX ring via
> mlx4_en_free_tx_buf().  The code mlx4_en_free_tx_desc() for
> freeing SKBs are shared with NAPI calls.
>
> To handle this shared use the zero budget indication is reused,
> and handled appropiately in napi_consume_skb(). To reflect this,

    Appropriately.

> variable is called napi_mode for the function call that needed
> this distinction.
>
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ---
>   drivers/net/ethernet/mellanox/mlx4/en_tx.c |   16 ++++++++++------
>   1 file changed, 10 insertions(+), 6 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> index e0946ab22010..1b41feafce9e 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
[...]
> @@ -371,7 +373,9 @@ int mlx4_en_free_tx_buf(struct net_device *dev, struct mlx4_en_tx_ring *ring)
>   	while (ring->cons != ring->prod) {
>   		ring->last_nr_txbb = mlx4_en_free_tx_desc(priv, ring,
>   						ring->cons & ring->size_mask,
> -						!!(ring->cons & ring->size), 0);
> +						!!(ring->cons & ring->size), 0,
> +						0 /* none-NAPI caller */

    Non-NAPI, perhaps?

[...]

MBR, Sergei
