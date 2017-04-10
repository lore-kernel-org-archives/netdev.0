From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH v2 net-next RFC] Generic XDP
Date: Mon, 10 Apr 2017 14:39:35 -0400
Message-ID: <20170410183935.GB4730@C02RW35GFVH8.dhcp.broadcom.net>
References: <20170409.133528.660876505013192371.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, xdp-newbies@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35188 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752052AbdDJSjt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 14:39:49 -0400
Received: by mail-pg0-f65.google.com with SMTP id g2so26672354pge.2
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 11:39:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170409.133528.660876505013192371.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 09, 2017 at 01:35:28PM -0700, David Miller wrote:
> 
> This provides a generic non-optimized XDP implementation when the
> device driver does not provide an optimized one.
> 
> It is arguable that perhaps I should have required something like
> this as part of the initial XDP feature merge.
> 
> I believe this is critical for two reasons:
> 
> 1) Accessibility.  More people can play with XDP with less
>    dependencies.  Yes I know we have XDP support in virtio_net, but
>    that just creates another depedency for learning how to use this
>    facility.
> 
>    I wrote this to make life easier for the XDP newbies.
> 
> 2) As a model for what the expected semantics are.  If there is a pure
>    generic core implementation, it serves as a semantic example for
>    driver folks adding XDP support.
> 
> This is just a rough draft and is untested.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>

As promised, I did some testing today with bnxt_en's implementation of
XDP and this one.

I ran this on a desktop-class system I have (i7-6700 CPU @ 3.40GHz)
and used pktgen_sample03_burst_single_flow.sh from another system to
throw ~6.5Mpps as a single UDP stream towards the system running XDP.

I just commented out the ndo_xdp op in bnxt.c to test this patch.  The
differences were pretty dramatic.

Using the ndo_xdp ndo in bnxt_en, my perf report output looked like
this (not sure why X is still running on this system!):

    38.08%  swapper          [sysimgblt]                   [k] 0x0000000000005bd0
    11.80%  swapper          [kernel.vmlinux]              [k] intel_idle
    10.49%  swapper          [bnxt_en]                     [k] bnxt_rx_pkt
     6.31%  swapper          [bnxt_en]                     [k] bnxt_rx_xdp
     5.64%  swapper          [bnxt_en]                     [k] bnxt_poll
     4.22%  swapper          [kernel.vmlinux]              [k] poll_idle
     3.46%  swapper          [kernel.vmlinux]              [k] irq_entries_start
     2.95%  swapper          [kernel.vmlinux]              [k] napi_complete_done
     1.79%  swapper          [kernel.vmlinux]              [k] cpuidle_enter_state
     1.53%  swapper          [kernel.vmlinux]              [k] menu_select
     1.19%  swapper          [bnxt_en]                     [k] bnxt_reuse_rx_data
     1.00%  swapper          [sysimgblt]                   [k] 0x0000000000005c6f
     0.92%  swapper          [kernel.vmlinux]              [k] __next_timer_interrupt
     0.71%  swapper          [kernel.vmlinux]              [k] _raw_spin_lock_irqsave
     0.71%  swapper          [kernel.vmlinux]              [k] bpf_map_lookup_elem

mpstat reports that the CPU receiving and dropping the traffic is
basically running idle.  Dropping this amount of traffic in the driver
has very little impact on the system.

With v2 of this patch I see the following from perf report:

    19.69%  ksoftirqd/3      [kernel.vmlinux]              [k] memcpy_erms
    16.30%  ksoftirqd/3      [kernel.vmlinux]              [k] __bpf_prog_run
    10.11%  ksoftirqd/3      [bnxt_en]                     [k] bnxt_rx_pkt
     7.69%  ksoftirqd/3      [kernel.vmlinux]              [k] __build_skb
     4.25%  ksoftirqd/3      [kernel.vmlinux]              [k] inet_gro_receive
     3.74%  ksoftirqd/3      [kernel.vmlinux]              [k] kmem_cache_alloc
     3.53%  ksoftirqd/3      [kernel.vmlinux]              [k] dev_gro_receive
     3.43%  ksoftirqd/3      [kernel.vmlinux]              [k] page_frag_free
     3.12%  ksoftirqd/3      [kernel.vmlinux]              [k] kmem_cache_free
     2.56%  ksoftirqd/3      [bnxt_en]                     [k] bnxt_poll
     2.46%  ksoftirqd/3      [kernel.vmlinux]              [k] netif_receive_skb_internal
     2.13%  ksoftirqd/3      [kernel.vmlinux]              [k] __udp4_lib_lookup
     1.63%  ksoftirqd/3      [kernel.vmlinux]              [k] __napi_alloc_skb
     1.51%  ksoftirqd/3      [kernel.vmlinux]              [k] eth_type_trans
     1.42%  ksoftirqd/3      [kernel.vmlinux]              [k] udp_gro_receive
     1.29%  ksoftirqd/3      [kernel.vmlinux]              [k] napi_gro_receive
     1.25%  ksoftirqd/3      [kernel.vmlinux]              [k] udp4_gro_receive
     1.18%  ksoftirqd/3      [bnxt_en]                     [k] bnxt_rx_xdp
     1.17%  ksoftirqd/3      [kernel.vmlinux]              [k] skb_release_data
     1.11%  ksoftirqd/3      [bnxt_en]                     [k] bnxt_reuse_rx_data
     1.07%  ksoftirqd/3      [kernel.vmlinux]              [k] net_rx_action

mpstat reports that the CPU receiving and dropping the traffic is about
98% utilized running in softirq context.

Unsurprisingly, in-driver XDP is significantly more efficient than in-stack
XDP.

I also noted that...

xdp1 not parsing the protocol correctly.   All traffic was showing up as
protocol '0' instead of '17' in the output.  

xdp2 was not actually sending the frames back out when using this patch.

I'll take a look in a bit and see if I can track these two issues down.

> ---
> 
> v2:
>  - Add some "fall through" comments in switch statements based
>    upon feedback from Andrew Lunn
>  - Use RCU for generic xdp_prog, thanks to Johannes Berg.
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index cc07c3b..f8ff49c 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1892,6 +1892,7 @@ struct net_device {
>  	struct lock_class_key	*qdisc_tx_busylock;
>  	struct lock_class_key	*qdisc_running_key;
>  	bool			proto_down;
> +	struct bpf_prog __rcu	*xdp_prog;
>  };
>  #define to_net_dev(d) container_of(d, struct net_device, dev)
>  
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 7efb417..ad6de2d 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -95,6 +95,7 @@
>  #include <linux/notifier.h>
>  #include <linux/skbuff.h>
>  #include <linux/bpf.h>
> +#include <linux/bpf_trace.h>
>  #include <net/net_namespace.h>
>  #include <net/sock.h>
>  #include <net/busy_poll.h>
> @@ -4247,6 +4248,83 @@ static int __netif_receive_skb(struct sk_buff *skb)
>  	return ret;
>  }
>  
> +static struct static_key generic_xdp_needed __read_mostly;
> +
> +static int generic_xdp_install(struct net_device *dev, struct netdev_xdp *xdp)
> +{
> +	struct bpf_prog *new = xdp->prog;
> +	int ret = 0;
> +
> +	switch (xdp->command) {
> +	case XDP_SETUP_PROG: {
> +		struct bpf_prog *old = rtnl_dereference(dev->xdp_prog);
> +
> +		rcu_assign_pointer(dev->xdp_prog, new);
> +		if (old)
> +			bpf_prog_put(old);
> +
> +		if (old && !new)
> +			static_key_slow_dec(&generic_xdp_needed);
> +		else if (new && !old)
> +			static_key_slow_inc(&generic_xdp_needed);
> +		break;
> +	}
> +
> +	case XDP_QUERY_PROG:
> +		xdp->prog_attached = !!rcu_access_pointer(dev->xdp_prog);
> +		break;
> +
> +	default:
> +		ret = -EINVAL;
> +		break;
> +	}
> +
> +	return ret;
> +}
> +
> +static u32 netif_receive_generic_xdp(struct sk_buff *skb,
> +				     struct bpf_prog *xdp_prog)
> +{
> +	struct xdp_buff xdp;
> +	u32 act = XDP_DROP;
> +	void *orig_data;
> +	int hlen, off;
> +
> +	if (skb_linearize(skb))
> +		goto do_drop;
> +
> +	hlen = skb_headlen(skb);
> +	xdp.data = skb->data;
> +	xdp.data_end = xdp.data + hlen;
> +	xdp.data_hard_start = xdp.data - skb_headroom(skb);
> +	orig_data = xdp.data;
> +
> +	act = bpf_prog_run_xdp(xdp_prog, &xdp);
> +
> +	off = xdp.data - orig_data;
> +	if (off)
> +		__skb_push(skb, off);
> +
> +	switch (act) {
> +	case XDP_PASS:
> +	case XDP_TX:
> +		break;
> +
> +	default:
> +		bpf_warn_invalid_xdp_action(act);
> +		/* fall through */
> +	case XDP_ABORTED:
> +		trace_xdp_exception(skb->dev, xdp_prog, act);
> +		/* fall through */
> +	case XDP_DROP:
> +	do_drop:
> +		kfree_skb(skb);
> +		break;
> +	}
> +
> +	return act;
> +}
> +
>  static int netif_receive_skb_internal(struct sk_buff *skb)
>  {
>  	int ret;
> @@ -4258,6 +4336,21 @@ static int netif_receive_skb_internal(struct sk_buff *skb)
>  
>  	rcu_read_lock();
>  
> +	if (static_key_false(&generic_xdp_needed)) {
> +		struct bpf_prog *xdp_prog = rcu_dereference(skb->dev->xdp_prog);
> +
> +		if (xdp_prog) {
> +			u32 act = netif_receive_generic_xdp(skb, xdp_prog);
> +
> +			if (act != XDP_PASS) {
> +				rcu_read_unlock();
> +				if (act == XDP_TX)
> +					dev_queue_xmit(skb);
> +				return NET_RX_DROP;
> +			}
> +		}
> +	}
> +
>  #ifdef CONFIG_RPS
>  	if (static_key_false(&rps_needed)) {
>  		struct rps_dev_flow voidflow, *rflow = &voidflow;
> @@ -6718,6 +6811,7 @@ EXPORT_SYMBOL(dev_change_proto_down);
>   */
>  int dev_change_xdp_fd(struct net_device *dev, int fd, u32 flags)
>  {
> +	int (*xdp_op)(struct net_device *dev, struct netdev_xdp *xdp);
>  	const struct net_device_ops *ops = dev->netdev_ops;
>  	struct bpf_prog *prog = NULL;
>  	struct netdev_xdp xdp;
> @@ -6725,14 +6819,16 @@ int dev_change_xdp_fd(struct net_device *dev, int fd, u32 flags)
>  
>  	ASSERT_RTNL();
>  
> -	if (!ops->ndo_xdp)
> -		return -EOPNOTSUPP;
> +	xdp_op = ops->ndo_xdp;
> +	if (!xdp_op)
> +		xdp_op = generic_xdp_install;
> +
>  	if (fd >= 0) {
>  		if (flags & XDP_FLAGS_UPDATE_IF_NOEXIST) {
>  			memset(&xdp, 0, sizeof(xdp));
>  			xdp.command = XDP_QUERY_PROG;
>  
> -			err = ops->ndo_xdp(dev, &xdp);
> +			err = xdp_op(dev, &xdp);
>  			if (err < 0)
>  				return err;
>  			if (xdp.prog_attached)
> @@ -6748,7 +6844,7 @@ int dev_change_xdp_fd(struct net_device *dev, int fd, u32 flags)
>  	xdp.command = XDP_SETUP_PROG;
>  	xdp.prog = prog;
>  
> -	err = ops->ndo_xdp(dev, &xdp);
> +	err = xdp_op(dev, &xdp);
>  	if (err < 0 && prog)
>  		bpf_prog_put(prog);
>  
> @@ -7789,6 +7885,7 @@ EXPORT_SYMBOL(alloc_netdev_mqs);
>  void free_netdev(struct net_device *dev)
>  {
>  	struct napi_struct *p, *n;
> +	struct bpf_prog *prog;
>  
>  	might_sleep();
>  	netif_free_tx_queues(dev);
> @@ -7807,6 +7904,12 @@ void free_netdev(struct net_device *dev)
>  	free_percpu(dev->pcpu_refcnt);
>  	dev->pcpu_refcnt = NULL;
>  
> +	prog = rcu_dereference(dev->xdp_prog);
> +	if (prog) {
> +		bpf_prog_put(prog);
> +		static_key_slow_dec(&generic_xdp_needed);
> +	}
> +
>  	/*  Compatibility with error handling in drivers */
>  	if (dev->reg_state == NETREG_UNINITIALIZED) {
>  		netdev_freemem(dev);
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index b2bd4c9..c73c7b7 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -896,15 +896,12 @@ static size_t rtnl_port_size(const struct net_device *dev,
>  		return port_self_size;
>  }
>  
> -static size_t rtnl_xdp_size(const struct net_device *dev)
> +static size_t rtnl_xdp_size(void)
>  {
>  	size_t xdp_size = nla_total_size(0) +	/* nest IFLA_XDP */
>  			  nla_total_size(1);	/* XDP_ATTACHED */
>  
> -	if (!dev->netdev_ops->ndo_xdp)
> -		return 0;
> -	else
> -		return xdp_size;
> +	return xdp_size;
>  }
>  
>  static noinline size_t if_nlmsg_size(const struct net_device *dev,
> @@ -943,7 +940,7 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
>  	       + nla_total_size(MAX_PHYS_ITEM_ID_LEN) /* IFLA_PHYS_PORT_ID */
>  	       + nla_total_size(MAX_PHYS_ITEM_ID_LEN) /* IFLA_PHYS_SWITCH_ID */
>  	       + nla_total_size(IFNAMSIZ) /* IFLA_PHYS_PORT_NAME */
> -	       + rtnl_xdp_size(dev) /* IFLA_XDP */
> +	       + rtnl_xdp_size() /* IFLA_XDP */
>  	       + nla_total_size(4)  /* IFLA_EVENT */
>  	       + nla_total_size(1); /* IFLA_PROTO_DOWN */
>  
> @@ -1252,20 +1249,25 @@ static int rtnl_fill_link_ifmap(struct sk_buff *skb, struct net_device *dev)
>  
>  static int rtnl_xdp_fill(struct sk_buff *skb, struct net_device *dev)
>  {
> -	struct netdev_xdp xdp_op = {};
>  	struct nlattr *xdp;
>  	int err;
> +	u8 val;
>  
> -	if (!dev->netdev_ops->ndo_xdp)
> -		return 0;
>  	xdp = nla_nest_start(skb, IFLA_XDP);
>  	if (!xdp)
>  		return -EMSGSIZE;
> -	xdp_op.command = XDP_QUERY_PROG;
> -	err = dev->netdev_ops->ndo_xdp(dev, &xdp_op);
> -	if (err)
> -		goto err_cancel;
> -	err = nla_put_u8(skb, IFLA_XDP_ATTACHED, xdp_op.prog_attached);
> +	if (dev->netdev_ops->ndo_xdp) {
> +		struct netdev_xdp xdp_op = {};
> +
> +		xdp_op.command = XDP_QUERY_PROG;
> +		err = dev->netdev_ops->ndo_xdp(dev, &xdp_op);
> +		if (err)
> +			goto err_cancel;
> +		val = xdp_op.prog_attached;
> +	} else {
> +		val = rcu_access_pointer(dev->xdp_prog) ? 1 : 0;
> +	}
> +	err = nla_put_u8(skb, IFLA_XDP_ATTACHED, val);
>  	if (err)
>  		goto err_cancel;
>  
