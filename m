From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [RFC PATCH V3 10/16] netback: rework of per-cpu scratch space.
Date: Mon, 30 Jan 2012 16:53:32 -0500
Message-ID: <20120130215332.GA16747@phenom.dumpdata.com>
References: <1327934734-8908-1-git-send-email-wei.liu2@citrix.com>
 <1327934734-8908-11-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, xen-devel@lists.xensource.com,
	ian.campbell@citrix.com
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:53601 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752527Ab2A3V4I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 16:56:08 -0500
Content-Disposition: inline
In-Reply-To: <1327934734-8908-11-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 30, 2012 at 02:45:28PM +0000, Wei Liu wrote:
> If we allocate large arrays in per-cpu section, multi-page ring
> feature is likely to blow up the per-cpu section. So avoid allocating
> large arrays, instead we only store pointers to scratch spaces in
> per-cpu section.
> 
> CPU hotplug event is also taken care of.
> 
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> ---
>  drivers/net/xen-netback/netback.c |  140 +++++++++++++++++++++++++++----------
>  1 files changed, 104 insertions(+), 36 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index a8d58a9..2ac9b84 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -39,6 +39,7 @@
>  #include <linux/kthread.h>
>  #include <linux/if_vlan.h>
>  #include <linux/udp.h>
> +#include <linux/cpu.h>
>  
>  #include <net/tcp.h>
>  
> @@ -49,15 +50,15 @@
>  #include <asm/xen/page.h>
>  
>  
> -struct gnttab_copy *tx_copy_ops;
> +DEFINE_PER_CPU(struct gnttab_copy *, tx_copy_ops);
>  
>  /*
>   * Given MAX_BUFFER_OFFSET of 4096 the worst case is that each
>   * head/fragment page uses 2 copy operations because it
>   * straddles two buffers in the frontend.
>   */
> -struct gnttab_copy *grant_copy_op;
> -struct xenvif_rx_meta *meta;
> +DEFINE_PER_CPU(struct gnttab_copy *, grant_copy_op);
> +DEFINE_PER_CPU(struct xenvif_rx_meta *, meta);
>  
>  static void xenvif_idx_release(struct xenvif *vif, u16 pending_idx);
>  static void make_tx_response(struct xenvif *vif,
> @@ -481,8 +482,8 @@ void xenvif_rx_action(struct xenvif *vif)
>  	struct skb_cb_overlay *sco;
>  	int need_to_notify = 0;
>  
> -	struct gnttab_copy *gco = get_cpu_ptr(grant_copy_op);
> -	struct xenvif_rx_meta *m = get_cpu_ptr(meta);
> +	struct gnttab_copy *gco = get_cpu_var(grant_copy_op);
> +	struct xenvif_rx_meta *m = get_cpu_var(meta);
>  
>  	struct netrx_pending_operations npo = {
>  		.copy  = gco,
> @@ -512,8 +513,8 @@ void xenvif_rx_action(struct xenvif *vif)
>  	BUG_ON(npo.meta_prod > MAX_PENDING_REQS);
>  
>  	if (!npo.copy_prod) {
> -		put_cpu_ptr(gco);
> -		put_cpu_ptr(m);
> +		put_cpu_var(grant_copy_op);
> +		put_cpu_var(meta);
>  		return;
>  	}
>  
> @@ -599,8 +600,8 @@ void xenvif_rx_action(struct xenvif *vif)
>  	if (!skb_queue_empty(&vif->rx_queue))
>  		xenvif_kick_thread(vif);
>  
> -	put_cpu_ptr(gco);
> -	put_cpu_ptr(m);
> +	put_cpu_var(grant_copy_op);
> +	put_cpu_var(meta);
>  }
>  
>  void xenvif_queue_tx_skb(struct xenvif *vif, struct sk_buff *skb)
> @@ -1287,12 +1288,12 @@ int xenvif_tx_action(struct xenvif *vif, int budget)
>  	if (unlikely(!tx_work_todo(vif)))
>  		return 0;
>  
> -	tco = get_cpu_ptr(tx_copy_ops);
> +	tco = get_cpu_var(tx_copy_ops);
>  
>  	nr_gops = xenvif_tx_build_gops(vif, tco);
>  
>  	if (nr_gops == 0) {
> -		put_cpu_ptr(tco);
> +		put_cpu_var(tx_copy_ops);
>  		return 0;
>  	}
>  
> @@ -1301,7 +1302,7 @@ int xenvif_tx_action(struct xenvif *vif, int budget)
>  
>  	work_done = xenvif_tx_submit(vif, tco, budget);
>  
> -	put_cpu_ptr(tco);
> +	put_cpu_var(tx_copy_ops);
>  
>  	return work_done;
>  }
> @@ -1452,31 +1453,97 @@ int xenvif_kthread(void *data)
>  	return 0;
>  }
>  
> +static int __create_percpu_scratch_space(unsigned int cpu)
> +{
> +	per_cpu(tx_copy_ops, cpu) =
> +		vzalloc(sizeof(struct gnttab_copy) * MAX_PENDING_REQS);
> +
> +	per_cpu(grant_copy_op, cpu) =
> +		vzalloc(sizeof(struct gnttab_copy)
> +			* 2 * XEN_NETIF_RX_RING_SIZE);
> +
> +	per_cpu(meta, cpu) = vzalloc(sizeof(struct xenvif_rx_meta)
> +				     * 2 * XEN_NETIF_RX_RING_SIZE);
> +
> +	if (!per_cpu(tx_copy_ops, cpu) ||
> +	    !per_cpu(grant_copy_op, cpu) ||
> +	    !per_cpu(meta, cpu))

Hm, shouldn't you vfree one at least them? It might be that just one of
them failed.

> +		return -ENOMEM;
> +
> +	return 0;
> +}
> +
> +static void __free_percpu_scratch_space(unsigned int cpu)
> +{
> +	/* freeing NULL pointer is legit */
> +	vfree(per_cpu(tx_copy_ops, cpu));
> +	vfree(per_cpu(grant_copy_op, cpu));
> +	vfree(per_cpu(meta, cpu));
> +}
> +
> +static int __netback_percpu_callback(struct notifier_block *nfb,
> +				     unsigned long action, void *hcpu)
> +{
> +	unsigned int cpu = (unsigned long)hcpu;
> +	int rc = NOTIFY_DONE;
> +
> +	switch (action) {
> +	case CPU_ONLINE:
> +	case CPU_ONLINE_FROZEN:
> +		printk(KERN_INFO
> +		       "netback: CPU %x online, creating scratch space\n", cpu);

Is there any way to use 'pr_info(DRV_NAME' for these printk's? It might
require another patch, but it would  make it nicer.

> +		rc = __create_percpu_scratch_space(cpu);
> +		if (rc) {
> +			printk(KERN_ALERT
> +			       "netback: failed to create scratch space for CPU"
> +			       " %x\n", cpu);
> +			/* FIXME: nothing more we can do here, we will
> +			 * print out warning message when thread or
> +			 * NAPI runs on this cpu. Also stop getting
> +			 * called in the future.
> +			 */
> +			__free_percpu_scratch_space(cpu);
> +			rc = NOTIFY_BAD;
> +		} else {
> +			rc = NOTIFY_OK;
> +		}
> +		break;
> +	case CPU_DEAD:
> +	case CPU_DEAD_FROZEN:
> +		printk("netback: CPU %x offline, destroying scratch space\n",
> +		       cpu);

pr_debug?

> +		__free_percpu_scratch_space(cpu);
> +		rc = NOTIFY_OK;
> +		break;
> +	default:
> +		break;
> +	}
> +
> +	return rc;
> +}
> +
> +static struct notifier_block netback_notifier_block = {
> +	.notifier_call = __netback_percpu_callback,
> +};
>  
>  static int __init netback_init(void)
>  {
>  	int rc = -ENOMEM;
> +	int cpu;
>  
>  	if (!xen_domain())
>  		return -ENODEV;
>  
> -	tx_copy_ops = __alloc_percpu(sizeof(struct gnttab_copy)
> -				     * MAX_PENDING_REQS,
> -				     __alignof__(struct gnttab_copy));
> -	if (!tx_copy_ops)
> -		goto failed_init;
> +	/* Don't need to disable preempt here, since nobody else will
> +	 * touch these percpu areas during start up. */
> +	for_each_online_cpu(cpu) {
> +		rc = __create_percpu_scratch_space(cpu);
>  
> -	grant_copy_op = __alloc_percpu(sizeof(struct gnttab_copy)
> -				       * 2 * XEN_NETIF_RX_RING_SIZE,
> -				       __alignof__(struct gnttab_copy));
> -	if (!grant_copy_op)
> -		goto failed_init_gco;
> +		if (rc)
> +			goto failed_init;
> +	}
>  
> -	meta = __alloc_percpu(sizeof(struct xenvif_rx_meta)
> -			      * 2 * XEN_NETIF_RX_RING_SIZE,
> -			      __alignof__(struct xenvif_rx_meta));
> -	if (!meta)
> -		goto failed_init_meta;
> +	register_hotcpu_notifier(&netback_notifier_block);
>  
>  	rc = page_pool_init();
>  	if (rc)
> @@ -1491,25 +1558,26 @@ static int __init netback_init(void)
>  failed_init_xenbus:
>  	page_pool_destroy();
>  failed_init_pool:
> -	free_percpu(meta);
> -failed_init_meta:
> -	free_percpu(grant_copy_op);
> -failed_init_gco:
> -	free_percpu(tx_copy_ops);
> +	for_each_online_cpu(cpu)
> +		__free_percpu_scratch_space(cpu);
>  failed_init:
>  	return rc;

We don't want to try to clean up the per_cpu_spaces that might
have gotten allocated in the loop?

> -
>  }
>  
>  module_init(netback_init);
>  
>  static void __exit netback_exit(void)
>  {
> +	int cpu;
> +
>  	xenvif_xenbus_exit();
>  	page_pool_destroy();
> -	free_percpu(meta);
> -	free_percpu(grant_copy_op);
> -	free_percpu(tx_copy_ops);
> +
> +	unregister_hotcpu_notifier(&netback_notifier_block);
> +
> +	/* Since we're here, nobody else will touch per-cpu area. */
> +	for_each_online_cpu(cpu)
> +		__free_percpu_scratch_space(cpu);
>  }
>  module_exit(netback_exit);
>  
> -- 
> 1.7.2.5
