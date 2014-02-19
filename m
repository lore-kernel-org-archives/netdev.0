From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] sit: fix panic with route cache in ip tunnels
Date: Wed, 19 Feb 2014 08:43:29 -0800
Message-ID: <1392828209.18849.4.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1392826532-19282-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Tom Herbert <therbert@google.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:38634 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754458AbaBSQne (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Feb 2014 11:43:34 -0500
Received: by mail-pa0-f45.google.com with SMTP id lf10so623580pab.32
        for <netdev@vger.kernel.org>; Wed, 19 Feb 2014 08:43:33 -0800 (PST)
In-Reply-To: <1392826532-19282-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-02-19 at 17:15 +0100, Nicolas Dichtel wrote:
> Bug introduced by commit 7d442fab0a67 ("ipv4: Cache dst in tunnels").
> 
> Because sit code does not call ip_tunnel_init(), the dst_cache was not
> initialized.
> 
> CC: Tom Herbert <therbert@google.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>  net/ipv6/sit.c | 9 +++++++++
>  1 file changed, 9 insertions(+)
> 
> diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
> index 3dfbcf1dcb1c..5ff33d9bd5de 100644
> --- a/net/ipv6/sit.c
> +++ b/net/ipv6/sit.c
> @@ -1326,6 +1326,9 @@ static const struct net_device_ops ipip6_netdev_ops = {
>  
>  static void ipip6_dev_free(struct net_device *dev)
>  {
> +	struct ip_tunnel *tunnel = netdev_priv(dev);
> +
> +	free_percpu(tunnel->dst_cache);
>  	free_percpu(dev->tstats);
>  	free_netdev(dev);
>  }
> @@ -1375,6 +1378,12 @@ static int ipip6_tunnel_init(struct net_device *dev)
>  		u64_stats_init(&ipip6_tunnel_stats->syncp);
>  	}
>  
> +	tunnel->dst_cache = alloc_percpu(struct ip_tunnel_dst);
> +	if (!tunnel->dst_cache) {
> +		free_percpu(dev->tstats);
> +		return -ENOMEM;
> +	}
> +
>  	return 0;
>  }
>  

I do not think this patch is complete.

It seems to lack a tunnel_dst_reset_all() or something to properly
release the dst.
