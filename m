From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v2] cgroup: fix panic in netprio_cgroup
Date: Thu, 5 Jul 2012 08:40:30 -0400
Message-ID: <20120705124029.GA2795@neilslaptop.think-freely.org>
References: <1341480520-25081-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tj@kernel.org, lizefan@huawei.com,
	eric.dumazet@gmail.com
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1341480520-25081-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 05, 2012 at 05:28:40PM +0800, Gao feng wrote:
> we set max_prioidx to the first zero bit index of prioidx_map in
> function get_prioidx.
> 
> So when we delete the low index netprio cgroup and adding a new
> netprio cgroup again,the max_prioidx will be set to the low index.
> 
> when we set the high index cgroup's net_prio.ifpriomap,the function
> write_priomap will call update_netdev_tables to alloc memory which
> size is sizeof(struct netprio_map) + sizeof(u32) * (max_prioidx + 1),
> so the size of array that map->priomap point to is max_prioidx +1,
> which is low than what we actually need.
> 
> fix this by adding check in get_prioidx,only set max_prioidx when
> max_prioidx low than the new prioidx.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> ---
>  net/core/netprio_cgroup.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
> index 5b8aa2f..aa907ed 100644
> --- a/net/core/netprio_cgroup.c
> +++ b/net/core/netprio_cgroup.c
> @@ -49,8 +49,9 @@ static int get_prioidx(u32 *prio)
>  		return -ENOSPC;
>  	}
>  	set_bit(prioidx, prioidx_map);
> +	if (atomic_read(&max_prioidx) < prioidx)
> +		atomic_set(&max_prioidx, prioidx);
>  	spin_unlock_irqrestore(&prioidx_map_lock, flags);
> -	atomic_set(&max_prioidx, prioidx);
>  	*prio = prioidx;
>  	return 0;
>  }
> -- 
> 1.7.7.6
> 
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
