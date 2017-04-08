From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH net-next v2] can: initial support for network namespaces
Date: Sat, 8 Apr 2017 19:24:13 +0200
Message-ID: <17a0be47-6b8b-1c4f-308b-b09d6f66b86d@hartkopp.net>
References: <63994a75-c87d-e9d4-f002-afe14127d6a0@kicherer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Mario Kicherer <dev@kicherer.org>, netdev@vger.kernel.org,
        linux-can@vger.kernel.org, mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <63994a75-c87d-e9d4-f002-afe14127d6a0@kicherer.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Mario,

unfortunately Marc pushed this patch before I finally was able to review 
it ... :-(

Some questions:

On 02/21/2017 12:19 PM, Mario Kicherer wrote:
> This patch adds initial support for network namespaces. The changes only
> enable support in the CAN raw, proc and af_can code. GW and BCM still
> have their checks that ensure that they are used only from the main
> namespace.
>
> The patch boils down to moving the global structures, i.e. the global
> filter list and their /proc stats, into a per-namespace structure and passing
> around the corresponding "struct net" in a lot of different places.

(..)

> diff --git a/include/net/netns/can.h b/include/net/netns/can.h
> new file mode 100644
> index 0000000..e8beba7
> --- /dev/null
> +++ b/include/net/netns/can.h
> @@ -0,0 +1,31 @@
> +/*
> + * can in net namespaces
> + */
> +
> +#ifndef __NETNS_CAN_H__
> +#define __NETNS_CAN_H__
> +
> +#include <linux/spinlock.h>
> +
> +struct dev_rcv_lists;
> +
> +struct netns_can {
> +#if IS_ENABLED(CONFIG_PROC_FS)
> +	struct proc_dir_entry *proc_dir;
> +	struct proc_dir_entry *pde_version;
> +	struct proc_dir_entry *pde_stats;
> +	struct proc_dir_entry *pde_reset_stats;
> +	struct proc_dir_entry *pde_rcvlist_all;
> +	struct proc_dir_entry *pde_rcvlist_fil;
> +	struct proc_dir_entry *pde_rcvlist_inv;
> +	struct proc_dir_entry *pde_rcvlist_sff;
> +	struct proc_dir_entry *pde_rcvlist_eff;
> +	struct proc_dir_entry *pde_rcvlist_err;
> +#endif
> +
> +	/* receive filters subscribed for 'all' CAN devices */
> +	struct dev_rcv_lists *can_rx_alldev_list;
> +	spinlock_t can_rcvlists_lock;

You didn't include the statistics here:

+       struct s_stats *can_stats;      /* packet statistics */
+       struct s_pstats *can_pstats;    /* receive list statistics */

which need to be per-net too, right?

(..)
> @@ -877,6 +871,41 @@ static int can_notifier(struct notifier_block *nb, unsigned long msg,
>  	return NOTIFY_DONE;
>  }
>
> +int can_pernet_init(struct net *net)
> +{
> +	net->can.can_rcvlists_lock =
> +		__SPIN_LOCK_UNLOCKED(net->can.can_rcvlists_lock);
> +	net->can.can_rx_alldev_list =
> +		kzalloc(sizeof(struct dev_rcv_lists), GFP_KERNEL);
> +	memset(net->can.can_rx_alldev_list, 0, sizeof(struct dev_rcv_lists));
> +
> +	if (IS_ENABLED(CONFIG_PROC_FS))
> +		can_init_proc(net);
> +
> +	return 0;
> +}
> +
> +void can_pernet_exit(struct net *net)
> +{
> +	struct net_device *dev;
> +
> +	if (IS_ENABLED(CONFIG_PROC_FS))
> +		can_remove_proc(net);
> +
> +	/* remove created dev_rcv_lists from still registered CAN devices */
> +	rcu_read_lock();
> +	for_each_netdev_rcu(net, dev) {
> +		if (dev->type == ARPHRD_CAN && dev->ml_priv) {
> +			struct dev_rcv_lists *d = dev->ml_priv;
> +
> +			BUG_ON(d->entries);
> +			kfree(d);
> +			dev->ml_priv = NULL;
> +		}
> +	}
> +	rcu_read_unlock();

You do a kzalloc(sizeof(struct dev_rcv_lists), GFP_KERNEL) in 
can_pernet_init().

Doesn't it need a kfree(net->can.can_rx_alldev_list) then??

Regards,
Oliver
