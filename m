From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2 net-next RFC] Generic XDP
Date: Sun, 9 Apr 2017 19:18:09 -0700
Message-ID: <20170410021807.GA17150@ast-mbp.thefacebook.com>
References: <20170409.133528.660876505013192371.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, xdp-newbies@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34260 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751602AbdDJCSO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Apr 2017 22:18:14 -0400
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
...
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

do we need to force disable gro ?
Otherwise if we linearize skb_is_gso packet it will be huge
and not similar to normal xdp packets?
gso probably needs to disabled too to avoid veth surprises?

> +
> +	hlen = skb_headlen(skb);
> +	xdp.data = skb->data;

it probably should be
hlen = skb_headlen(skb) + skb->mac_len;
xdp.data = skb->data - skb->mac_len;
to make sure xdp program is looking at l2 header.

> +	xdp.data_end = xdp.data + hlen;
> +	xdp.data_hard_start = xdp.data - skb_headroom(skb);
> +	orig_data = xdp.data;
> +	act = bpf_prog_run_xdp(xdp_prog, &xdp);
> +
> +	off = xdp.data - orig_data;
> +	if (off)
> +		__skb_push(skb, off);

and restore l2 back somehow and get new skb->protocol ?
if we simply do __skb_pull(skb, skb->mac_len); like
we do with cls_bpf, it will not work correctly,
since if the program did ip->ipip encap (like our balancer
does and the test tools/testing/selftests/bpf/test_xdp.c)
the skb metadata fields will be wrong.
So we need to repeat eth_type_trans() here if (xdp.data != orig_data)

In case of cls_bpf when we mess with skb sizes we always
adjust skb metafields in helpers, so there it's fine
and __skb_pull(skb, skb->mac_len); is enough.
Here we need to be a bit more careful.

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

That's indeed the best attachment point in the stack.
I was trying to see whether it can be lowered into something like
dev_gro_receive(), but not everyone calls it.
Another option to put it into eth_type_trans() itself, then
there are no problems with gro, l2 headers, and adjust_head,
but changing all drivers is too much.

> +
> +			if (act != XDP_PASS) {
> +				rcu_read_unlock();
> +				if (act == XDP_TX)
> +					dev_queue_xmit(skb);

It should be fine. For cls_bpf we do recursion check __bpf_tx_skb()
but I forgot specific details. May be here it's fine as-is.
Daniel, do we need recursion check here?

> @@ -6725,14 +6819,16 @@ int dev_change_xdp_fd(struct net_device *dev, int fd, u32 flags)
>  
>  	ASSERT_RTNL();
>  
> -	if (!ops->ndo_xdp)
> -		return -EOPNOTSUPP;
> +	xdp_op = ops->ndo_xdp;
> +	if (!xdp_op)
> +		xdp_op = generic_xdp_install;

I suspect there always be drivers that don't support xdp (like e100),
so this generic_xdp_install() will stay with us forever.
Since it will stay, can we enable it for xdp enabled drivers too?
This will allow us to test both raw xdp and skb-based paths neck to neck.
Today bpf-newbies typically start developing with cls_bpf, since
it can run on tap/veth and then refactor the program to xdp.
Unfortunately cls_bpf and xdp programs are substantially different,
so it pretty much means that cls_bpf prog is a throw away.
If we can add a flag to this xdp netlink attach command
that says 'enable skb-based xdp', we'll have exactly the same
program running on raw dma buffer and on skb, which will help
developing on veth/tap and moving the same prog into physical
eth0 later. And users will be able to switch between skb-based
mode on eth0 and raw-buffer mode back and forth to see perf difference
(and hopefully nothing else).

Another advantage that it will help to flush out the differences
between skb- and raw- modes in the drivers that support xdp already.

Yet another benefit is it will allow measuring of cost of skb-alloc path.

Right now we have XDP_FLAGS_UPDATE_IF_NOEXIST flag.
We can add something like XDP_FLAGS_SKB_MODE flag for this purpose
and in the drivers that don't support XDP at the moment, this flag
will be assumed automatically.
Thoughts?
