From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net 2/2] xdp: disallow use of native and generic hook at
 once
Date: Tue, 9 May 2017 20:18:42 -0700
Message-ID: <20170509201842.2ed5e330@cakuba.netronome.com>
References: <cover.1494379046.git.daniel@iogearbox.net>
        <f8405a8769dca09a0f21d11eab3793e30f608531.1494379046.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, alexei.starovoitov@gmail.com,
        john.fastabend@gmail.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.9]:7377 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750946AbdEJDTE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 9 May 2017 23:19:04 -0400
In-Reply-To: <f8405a8769dca09a0f21d11eab3793e30f608531.1494379046.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 10 May 2017 03:31:31 +0200, Daniel Borkmann wrote:
> While working on the iproute2 generic XDP frontend, I noticed that
> as of right now it's possible to have native *and* generic XDP
> programs loaded both at the same time for the case when a driver
> supports native XDP.

Nice improvement!  A couple of absolute nitpicks below..

> The intended model for generic XDP from b5cdae3291f7 ("net: Generic
> XDP") is, however, that only one out of the two can be present at
> once which is also indicated as such in the XPD netlink dump part.
                                              ^^^
                                                 XDP

> @@ -6851,6 +6851,32 @@ int dev_change_proto_down(struct net_device *dev, bool proto_down)
>  }
>  EXPORT_SYMBOL(dev_change_proto_down);
>  
> +bool __dev_xdp_attached(struct net_device *dev, xdp_op_t xdp_op)

Out of curiosity - the leading underscores refer to caller having to
hold rtnl?  I assume they are not needed in the function below because
it's static?

> +{
> +	struct netdev_xdp xdp;
> +
> +	memset(&xdp, 0, sizeof(xdp));
> +	xdp.command = XDP_QUERY_PROG;

Probably personal preference, but seems like designated struct
initializer would do quite nicely here and save the memset :)

> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index dda9f16..99320f0 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -1251,24 +1251,20 @@ static int rtnl_xdp_fill(struct sk_buff *skb, struct net_device *dev)
>  {
>  	struct nlattr *xdp;
>  	u32 xdp_flags = 0;
> -	u8 val = 0;
>  	int err;
> +	u8 val;
>  
>  	xdp = nla_nest_start(skb, IFLA_XDP);
>  	if (!xdp)
>  		return -EMSGSIZE;
> +
>  	if (rcu_access_pointer(dev->xdp_prog)) {
>  		xdp_flags = XDP_FLAGS_SKB_MODE;
>  		val = 1;
> -	} else if (dev->netdev_ops->ndo_xdp) {
> -		struct netdev_xdp xdp_op = {};
> -
> -		xdp_op.command = XDP_QUERY_PROG;
> -		err = dev->netdev_ops->ndo_xdp(dev, &xdp_op);
> -		if (err)
> -			goto err_cancel;
> -		val = xdp_op.prog_attached;
> +	} else {
> +		val = dev_xdp_attached(dev);
> 	}

Would it make sense to set xdp_flags to XDP_FLAGS_DRV_MODE here to keep
things symmetrical?  I know you are just preserving existing behaviour
but it may seem slightly arbitrary to a new comer to report one of the
very similarly named flags in the dump but not the other.
