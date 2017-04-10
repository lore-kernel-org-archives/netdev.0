From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 net-next RFC] Generic XDP
Date: Mon, 10 Apr 2017 23:08:27 +0200
Message-ID: <58EBF44B.80404@iogearbox.net>
References: <20170409.133528.660876505013192371.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xdp-newbies@vger.kernel.org
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34892 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752151AbdDJVIs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 17:08:48 -0400
In-Reply-To: <20170409.133528.660876505013192371.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/09/2017 10:35 PM, David Miller wrote:
[...]
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index cc07c3b..f8ff49c 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1892,6 +1892,7 @@ struct net_device {
>   	struct lock_class_key	*qdisc_tx_busylock;
>   	struct lock_class_key	*qdisc_running_key;
>   	bool			proto_down;
> +	struct bpf_prog __rcu	*xdp_prog;

Should this be moved rather near other rx members for locality?
My config has last member of rx group in a new cacheline, which
is really waste ...

[...]
         /* --- cacheline 14 boundary (896 bytes) --- */
         struct hlist_node          index_hlist;          /*   896    16 */

         /* XXX 48 bytes hole, try to pack */
[...]

... but given this layout can change significantly for a given
config, perhaps could be a union with something exotic that is
currently always built in like ax25_ptr; would then require to
depend on ax25 not being built, though. :/ Otoh, we potentially
have to linearize the skb in data path, which is slow anyway,
so probably okay as is, too.

[...]
> @@ -4247,6 +4248,83 @@ static int __netif_receive_skb(struct sk_buff *skb)
>   	return ret;
>   }
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

Would be nice to extend this here, so that in the current 'ip link'
output we could indicate next to the 'xdp' flag that this does /not/
run natively in the driver.

Also, when the user loads a prog f.e. via 'ip link set dev em1 xdp obj prog.o',
we should add a flag where it could be specified that running non-natively
/is/ okay. Thus that the rtnl bits bail out if there's no ndo_xdp callback.
I could imagine that this could be overseen quickly and people wonder why
performance is significantly less than usually expected.

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

Wondering regarding XDP_PACKET_HEADROOM requirement,
presumably we would need to guarantee enough headroom
here as well, so that there's no difference to a native
driver implementation.

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
