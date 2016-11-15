From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v3 3/7] vxlan: simplify exception handling
Date: Tue, 15 Nov 2016 15:30:14 +0100
Message-ID: <20161115153014.38fa2480@griffin>
References: <1479098638-4921-1-git-send-email-pshelar@ovn.org>
        <1479098638-4921-4-git-send-email-pshelar@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35108 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S964936AbcKOOaS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Nov 2016 09:30:18 -0500
In-Reply-To: <1479098638-4921-4-git-send-email-pshelar@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 13 Nov 2016 20:43:54 -0800, Pravin B Shelar wrote:
> @@ -1927,13 +1923,13 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
>  	struct ip_tunnel_info *info;
>  	struct vxlan_dev *vxlan = netdev_priv(dev);
>  	struct sock *sk;
> -	struct rtable *rt = NULL;
>  	const struct iphdr *old_iph;
>  	union vxlan_addr *dst;
>  	union vxlan_addr remote_ip, local_ip;
>  	union vxlan_addr *src;
>  	struct vxlan_metadata _md;
>  	struct vxlan_metadata *md = &_md;
> +	struct dst_entry *ndst = NULL;
>  	__be16 src_port = 0, dst_port;
>  	__be32 vni, label;
>  	__be16 df = 0;
> @@ -2009,6 +2005,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
>  
>  	if (dst->sa.sa_family == AF_INET) {
>  		struct vxlan_sock *sock4 = rcu_dereference(vxlan->vn4_sock);
> +		struct rtable *rt;
>  
>  		if (!sock4)
>  			goto drop;
> @@ -2030,7 +2027,8 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
>  			netdev_dbg(dev, "circular route to %pI4\n",
>  				   &dst->sin.sin_addr.s_addr);
>  			dev->stats.collisions++;
> -			goto rt_tx_error;
> +			ip_rt_put(rt);
> +			goto tx_error;
>  		}
>  
>  		/* Bypass encapsulation if the destination is local */
> @@ -2053,12 +2051,13 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
>  		else if (info->key.tun_flags & TUNNEL_DONT_FRAGMENT)
>  			df = htons(IP_DF);
>  
> +		ndst = &rt->dst;

It would be a bit cleaner to do this assignment just after rt is
assigned (but after the IS_ERR(rt) condition), get rid of the added
ip_rt_put call above and move the existing ip_rt_put call in the bypass
case just before the vxlan_encap_bypass call...

>  		tos = ip_tunnel_ecn_encap(tos, old_iph, skb);
>  		ttl = ttl ? : ip4_dst_hoplimit(&rt->dst);
> -		err = vxlan_build_skb(skb, &rt->dst, sizeof(struct iphdr),
> +		err = vxlan_build_skb(skb, ndst, sizeof(struct iphdr),
>  				      vni, md, flags, udp_sum);
>  		if (err < 0)
> -			goto xmit_tx_error;
> +			goto tx_error;
>  
>  		udp_tunnel_xmit_skb(rt, sk, skb, src->sin.sin_addr.s_addr,
>  				    dst->sin.sin_addr.s_addr, tos, ttl, df,
> @@ -2066,7 +2065,6 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
>  #if IS_ENABLED(CONFIG_IPV6)
>  	} else {
>  		struct vxlan_sock *sock6 = rcu_dereference(vxlan->vn6_sock);
> -		struct dst_entry *ndst;
>  		u32 rt6i_flags;
>  
>  		ndst = vxlan6_get_route(vxlan, sock6, skb,
> @@ -2078,13 +2076,13 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
>  			netdev_dbg(dev, "no route to %pI6\n",
>  				   &dst->sin6.sin6_addr);
>  			dev->stats.tx_carrier_errors++;
> +			ndst = NULL;
>  			goto tx_error;
>  		}
>  
>  		if (ndst->dev == dev) {
>  			netdev_dbg(dev, "circular route to %pI6\n",
>  				   &dst->sin6.sin6_addr);
> -			dst_release(ndst);
>  			dev->stats.collisions++;
>  			goto tx_error;
>  		}
> @@ -2096,12 +2094,12 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
>  		    !(rt6i_flags & (RTCF_BROADCAST | RTCF_MULTICAST))) {
>  			struct vxlan_dev *dst_vxlan;
>  
> -			dst_release(ndst);
>  			dst_vxlan = vxlan_find_vni(vxlan->net, vni,
>  						   dst->sa.sa_family, dst_port,
>  						   vxlan->flags);
>  			if (!dst_vxlan)
>  				goto tx_error;
> +			dst_release(ndst);
>  			vxlan_encap_bypass(skb, vxlan, dst_vxlan);
>  			return;
>  		}

...the same way you have it here, in the IPv6 part. Could you change
the IPv4 part to match it?

Looks good otherwise. Seeing it, I like this version much more than v2.

Thanks!

 Jiri
