From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 4/7] net: use dst_cache for vxlan device
Date: Thu, 11 Feb 2016 12:11:12 +0100
Message-ID: <20160211121112.3e347ea9@griffin>
References: <cover.1455184959.git.pabeni@redhat.com>
	<2661aab079345237e14b9b2bc261f8d53c4071cf.1455184959.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Pravin B Shelar <pshelar@nicira.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Tom Herbert <therbert@google.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52571 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751282AbcBKLLR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Feb 2016 06:11:17 -0500
In-Reply-To: <2661aab079345237e14b9b2bc261f8d53c4071cf.1455184959.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 11 Feb 2016 11:12:00 +0100, Paolo Abeni wrote:
> @@ -1857,6 +1867,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
>  	struct rtable *rt = NULL;
>  	const struct iphdr *old_iph;
>  	union vxlan_addr *dst;
> +	struct dst_entry *ndst;
>  	union vxlan_addr remote_ip;
>  	struct vxlan_metadata _md;
>  	struct vxlan_metadata *md = &_md;
[...]
> @@ -1982,7 +2015,6 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
>  				    src_port, dst_port, xnet, !udp_sum);
>  #if IS_ENABLED(CONFIG_IPV6)
>  	} else {
> -		struct dst_entry *ndst;
>  		struct in6_addr saddr;
>  		u32 rt6i_flags;

Please keep the ndst variable local to the else branch, there's no need
to move it.

> @@ -1990,14 +2022,26 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
>  			goto drop;
>  		sk = vxlan->vn6_sock->sock->sk;
>  
> -		ndst = vxlan6_get_route(vxlan, skb,
> -					rdst ? rdst->remote_ifindex : 0,
> -					&dst->sin6.sin6_addr, &saddr);
> -		if (IS_ERR(ndst)) {
> -			netdev_dbg(dev, "no route to %pI6\n",
> -				   &dst->sin6.sin6_addr);
> -			dev->stats.tx_carrier_errors++;
> -			goto tx_error;
> +		use_cache = rdst && !skb->mark;

All of this use_cache stuff belongs to vxlan{6}_get_route. It should
either return the cached route, or look it up and cache it. This will
also make the code less error prone - if we base the route lookup on
more parameters in the future, the decision to skip the cache (because
the route depends on data from the inner packet) will be at the same
place as the added parameters, making it obvious that the cache skip
condition needs to be updated, too.

Overall, I'm not sure how much gain this dst caching will be in real
life, though. It surely looks nice in benchmarks. But as soon as you
step out of the most trivial case and start using TOS and skb marks,
the cache will be ineffective. But then, maybe the most trivial cases
are 90% of the deployment. No idea.

 Jiri

-- 
Jiri Benc
