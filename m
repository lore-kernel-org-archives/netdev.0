From: Timo Teras <timo.teras@iki.fi>
Subject: Re: [1/2,v3] ipv4: Cache dst in tunnels
Date: Thu, 24 Apr 2014 15:16:47 +0300
Message-ID: <20140424151647.2a917ff1@vostro>
References: <alpine.DEB.2.02.1401021140190.32659@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:43280 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753185AbaDXMPC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 08:15:02 -0400
Received: by mail-la0-f49.google.com with SMTP id ec20so1597014lab.22
        for <netdev@vger.kernel.org>; Thu, 24 Apr 2014 05:15:01 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.02.1401021140190.32659@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2 Jan 2014 11:48:26 -0800 (PST)
Tom Herbert <therbert@google.com> wrote:

> Avoid doing a route lookup on every packet being tunneled.
> 
> In ip_tunnel.c cache the route returned from ip_route_output if
> the tunnel is "connected" so that all the rouitng parameters are
> taken from tunnel parms for a packet. Specifically, not NBMA tunnel
> and tos is from tunnel parms (not inner packet).

Sorry for late reply. The 'connected' check you do is not sufficient.
It breaks NBMA mode gre. See below.

> @@ -528,10 +574,11 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct
> net_device *dev, struct flowi4 fl4;
>  	u8     tos, ttl;
>  	__be16 df;
> -	struct rtable *rt;		/* Route to the other host
> */
> +	struct rtable *rt = NULL;	/* Route to the other host
> */ unsigned int max_headroom;	/* The extra header space needed
> */ __be32 dst;
>  	int err;
> +	bool connected = true;
>  
>  	inner_iph = (const struct iphdr
> *)skb_inner_network_header(skb); 
> @@ -581,27 +628,39 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct
> net_device *dev, #endif
>  		else
>  			goto tx_error;
> +
> +		connected = false;
>  	}

The assumption in these two hunks is wrong. Even if tnl_params->daddr is
set, it might be an NBMA mode tunnel.

This happens (at least) when ipgre_header() is used and it pushes the
modified iphdr to skb. In that case ipgre_xmit just pulls it, and gives
that as the tnl_params argument.

I don't remember fully if tnl_params->daddr can be zero in
ip_tunnel_xmit. It *might* be a leftover dead-code path.

Any ideas how to fix this in a proper manner?

Thanks. Timo.
