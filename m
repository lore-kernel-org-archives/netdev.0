From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v3 net-next RFC] Generic XDP
Date: Thu, 13 Apr 2017 17:57:06 +0200
Message-ID: <58EF9FD2.90807@iogearbox.net>
References: <20170412.145415.1441440342830198148.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xdp-newbies@vger.kernel.org
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45185 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751654AbdDMP5J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 11:57:09 -0400
In-Reply-To: <20170412.145415.1441440342830198148.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/12/2017 08:54 PM, David Miller wrote:
[...]
> +static u32 netif_receive_generic_xdp(struct sk_buff *skb,
> +				     struct bpf_prog *xdp_prog)
> +{
> +	struct xdp_buff xdp;
> +	u32 act = XDP_DROP;
> +	void *orig_data;
> +	int hlen, off;
> +
> +	if (skb_linearize(skb))

Btw, given the skb can come from all kind of points in the stack,
it could also be a clone at this point. One example is act_mirred
which in fact does skb_clone() and can push the skb back to
ingress path through netif_receive_skb() and thus could then go
into generic xdp processing, where skb can be mangled.

Instead of skb_linearize() we would therefore need to use something
like skb_ensure_writable(skb, skb->len) as equivalent, which also
makes sure that we unclone whenever needed.

> +		goto do_drop;
> +
> +	/* The XDP program wants to see the packet starting at the MAC
> +	 * header.
> +	 */
> +	hlen = skb_headlen(skb) + skb->mac_len;
> +	xdp.data = skb->data - skb->mac_len;
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
> +	case XDP_TX:
> +		__skb_push(skb, skb->mac_len);
> +		/* fall through */
> +	case XDP_PASS:
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
>   static int netif_receive_skb_internal(struct sk_buff *skb)
>   {
>   	int ret;
> @@ -4258,6 +4341,21 @@ static int netif_receive_skb_internal(struct sk_buff *skb)
>
>   	rcu_read_lock();
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
[...]
