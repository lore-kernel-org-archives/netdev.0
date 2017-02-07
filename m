From: Tariq Toukan <tariqt@mellanox.com>
Subject: Re: [PATCH net v2] mlx4: Invoke softirqs after napi_reschedule
Date: Tue, 7 Feb 2017 10:23:09 +0200
Message-ID: <9515d1ae-cc06-7f70-ed75-aa3ba8005fe3@mellanox.com>
References: <1486403641.7793.43.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170206181431.9664-1-bpoirier@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tariq Toukan <tariqt@mellanox.com>,
        Yishai Hadas <yishaih@mellanox.com>,
        <linux-rdma@vger.kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>
To: Benjamin Poirier <bpoirier@suse.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr40066.outbound.protection.outlook.com ([40.107.4.66]:47808
        "EHLO EUR03-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752043AbdBGIX0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 7 Feb 2017 03:23:26 -0500
In-Reply-To: <20170206181431.9664-1-bpoirier@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 06/02/2017 8:14 PM, Benjamin Poirier wrote:
> mlx4 may schedule napi from a workqueue. Afterwards, softirqs are not run
> in a deterministic time frame and the following message may be logged:
> NOHZ: local_softirq_pending 08
>
> The problem is the same as what was described in commit ec13ee80145c
> ("virtio_net: invoke softirqs after __napi_schedule") and this patch
> applies the same fix to mlx4.
>
> Fixes: 07841f9d94c1 ("net/mlx4_en: Schedule napi when RX buffers allocation fails")
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Benjamin Poirier <bpoirier@suse.com>
> ---
>   drivers/net/ethernet/mellanox/mlx4/en_rx.c | 5 ++++-
>   1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> index eac527e25ec9..cc003fdf0ed9 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> @@ -514,8 +514,11 @@ void mlx4_en_recover_from_oom(struct mlx4_en_priv *priv)
>   		return;
>   
>   	for (ring = 0; ring < priv->rx_ring_num; ring++) {
> -		if (mlx4_en_is_ring_empty(priv->rx_ring[ring]))
> +		if (mlx4_en_is_ring_empty(priv->rx_ring[ring])) {
> +			local_bh_disable();
>   			napi_reschedule(&priv->rx_cq[ring]->napi);
> +			local_bh_enable();
> +		}
>   	}
>   }
>   
Reviewed-by: Tariq Toukan <tariqt@mellanox.com>

Thanks!
