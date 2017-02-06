From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net] mlx4: Invoke softirqs after napi_reschedule
Date: Mon, 06 Feb 2017 09:54:01 -0800
Message-ID: <1486403641.7793.43.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170206171046.3765-1-bpoirier@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Yishai Hadas <yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Benjamin Poirier <bpoirier-IBi9RG/b67k@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170206171046.3765-1-bpoirier-IBi9RG/b67k@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-02-06 at 09:10 -0800, Benjamin Poirier wrote:
> mlx4 may schedule napi from a workqueue. Afterwards, softirqs are not run
> in a deterministic time frame and the following message may be logged:
> NOHZ: local_softirq_pending 08
> 
> The problem is the same as what was described in commit ec13ee80145c
> ("virtio_net: invoke softirqs after __napi_schedule") and this patch
> applies the same fix to mlx4.
> 
> Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Benjamin Poirier <bpoirier-IBi9RG/b67k@public.gmane.org>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> index eac527e25ec9..14ce1549b638 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> @@ -513,10 +513,12 @@ void mlx4_en_recover_from_oom(struct mlx4_en_priv *priv)
>  	if (!priv->port_up)
>  		return;
>  
> +	local_bh_disable();
>  	for (ring = 0; ring < priv->rx_ring_num; ring++) {
>  		if (mlx4_en_is_ring_empty(priv->rx_ring[ring]))
>  			napi_reschedule(&priv->rx_cq[ring]->napi);
>  	}
> +	local_bh_enable();
>  }
>  

I would prefer having the local_bh_disable()/enable inside the loop,
as done with commit 8cf699ec849f4ca1413cea01289bd7d37dbcc626

This gives more chance to service one queue at a time, avoiding to
capture all queues into one cpu.

Thanks.


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
