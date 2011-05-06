From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v6 BONUS 4/3] ipv4: Store rtable entries directly in
 FIB
Date: Fri, 6 May 2011 12:12:26 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1105060944230.1435@ja.ssi.bg>
References: <20110505.163614.212671515.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, tgraf@suug.ch, jpirko@redhat.com,
	herbert@gondor.hengli.com.au, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:54097 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754420Ab1EFJLg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 May 2011 05:11:36 -0400
In-Reply-To: <20110505.163614.212671515.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Thu, 5 May 2011, David Miller wrote:

> Ok, here is the fun patch showing the scheme I'm working on.  Two
> things going on here.
> 
> First, we store pre-constructed rtable entries, on demand, inside of
> the routing table objects themselves.
> 
> Second, we get rid of RT_TABLE_LOCAL and load all routes equally
> into RT_TABLE_MAIN.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
> index 10422ef..f3c9598 100644
> --- a/include/net/ip_fib.h
> +++ b/include/net/ip_fib.h
> @@ -44,6 +44,7 @@ struct fib_config {
>   };
>  
>  struct fib_info;
> +struct rtable;
>  
>  struct fib_nh {
>  	struct net_device	*nh_dev;
> @@ -62,6 +63,7 @@ struct fib_nh {
>  	__be32			nh_gw;
>  	__be32			nh_saddr;
>  	int			nh_saddr_genid;
> +	struct rtable		*nh_rtable;

	Caching results of __mkroute_output in NH does
not work well for RTN_MULTICAST because ip_check_mc_rcu
wants to further restrict local delivery depending on
the source address and protocol. Even the routing cache
does not cache the protocol as key. May be received IGMP report
can create input cache entry with RTCF_LOCAL flag and later the
UDP stack can see unwatned incoming traffic that should be
dropped by MCAST_INCLUDE/MCAST_EXCLUDE settings for the same
group. I.e. the routing code calls ip_check_mc_rcu for IGMP
but the cache prevents the next calls for UDP to drop these
sources.

	Before now ip_rt_multicast_event was used to
notify about changes in subscriptions for groups and
the routing cache can update its information (RTCF_LOCAL)
per indev+saddr+daddr (but no protocol). Without routing cache
we can not solve the ip_check_mc_rcu problem with
nh_mc_genid fields because NH can be used for many
different saddr addresses.

	Same problem is in ip_route_input_common,
we have to call ip_check_mc_rcu for every packet and
this can be a problem with long lists. But I'm not
sure if the stack can see many filters. If yes, may be
only using hash table for in_dev->mc_list and its
"sources" can help here because we have to call
ip_check_mc_rcu for every input and output packet
if dev+saddr+daddr+proto results are not cached for mcast.

Regards

--
Julian Anastasov <ja@ssi.bg>
