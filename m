From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] cgroup: fix panic in netprio_cgroup
Date: Sun, 08 Jul 2012 21:50:43 +0200
Message-ID: <1341777043.3265.1786.camel@edumazet-glaptop>
References: <1341480520-25081-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tj@kernel.org, lizefan@huawei.com
To: Gao feng <gaofeng@cn.fujitsu.com>, nhorman@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1341480520-25081-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-07-05 at 17:28 +0800, Gao feng wrote:
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

This patch seems fine to me.

Acked-by: Eric Dumazet <edumazet@google.com>

Neil, looking at this file, I believe something is wrong.

dev->priomap is allocated by extend_netdev_table() called from
update_netdev_tables(). And this is only called if write_priomap() is
called.

But if write_priomap() is not called, it seems we can have out of bounds
accesses in cgrp_destroy() and read_priomap()

What do you think of following patch ?

diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index 5b8aa2f..80150d2 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -141,7 +141,7 @@ static void cgrp_destroy(struct cgroup *cgrp)
 	rtnl_lock();
 	for_each_netdev(&init_net, dev) {
 		map = rtnl_dereference(dev->priomap);
-		if (map)
+		if (map && cs->prioidx < map->priomap_len)
 			map->priomap[cs->prioidx] = 0;
 	}
 	rtnl_unlock();
@@ -165,7 +165,7 @@ static int read_priomap(struct cgroup *cont, struct cftype *cft,
 	rcu_read_lock();
 	for_each_netdev_rcu(&init_net, dev) {
 		map = rcu_dereference(dev->priomap);
-		priority = map ? map->priomap[prioidx] : 0;
+		priority = (map && prioidx < map->priomap_len) ? map->priomap[prioidx] : 0;
 		cb->fill(cb, dev->name, priority);
 	}
 	rcu_read_unlock();
