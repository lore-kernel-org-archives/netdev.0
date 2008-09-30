From: "Denis V. Lunev" <den@parallels.com>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when
	gc_elasticity is exceeded
Date: Tue, 30 Sep 2008 18:17:12 +0400
Message-ID: <1222784232.23573.22.camel@iris.sw.ru>
References: <20080929191254.GA20074@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, davem@davemloft.net,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:5820 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752789AbYI3ORH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Sep 2008 10:17:07 -0400
In-Reply-To: <20080929191254.GA20074@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch is wrong in respect to
  for_each_net
usage.

It should be used under rtnl. It is not held at the moment :(

Regards,
	Den

On Mon, 2008-09-29 at 15:12 -0400, Neil Horman wrote:
> Hey all-
> 	We currently have the ability to disable our route cache secret interval
> rebuild timer (by setting it to zero), but if we do that its possible for an
> attacker (if they guess our route cache hash secret, to fill our system with
> routes that all hash to the same bucket, destroying our performance.  This patch
> provides a backstop for that issues.  In the event that our rebuild interval is
> disabled (or very large), if any hash chain exceeds ip_rt_gc_elasticity, we do
> an emergency hash rebuild.  During the hash rebuild we:
> 1) warn the user of the emergency
> 2) disable the rebuild timer
> 3) invalidate the route caches
> 4) re-enable the rebuild timer with its old value
> 
> Regards
> Neil
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> 
> 
>  route.c |   36 +++++++++++++++++++++++++++++++++++-
>  1 file changed, 35 insertions(+), 1 deletion(-)
> 
> 
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 6ee5354..b95e02a 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -145,7 +145,7 @@ static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst);
>  static void		 ipv4_link_failure(struct sk_buff *skb);
>  static void		 ip_rt_update_pmtu(struct dst_entry *dst, u32 mtu);
>  static int rt_garbage_collect(struct dst_ops *ops);
> -
> +static void rt_emergency_hash_rebuild(void);
>  
>  static struct dst_ops ipv4_dst_ops = {
>  	.family =		AF_INET,
> @@ -1056,6 +1056,15 @@ restart:
>  			*candp = cand->u.dst.rt_next;
>  			rt_free(cand);
>  		}
> +	} else if (chain_length > ip_rt_gc_elasticity) {
> +		/*
> +		 * We didn't find a route entry we could safely free,
> +		 * yet our chain length is over our elasticity value.
> +		 * Someone may have guessed our hash secret and is artifically
> +		 * filling up our route cache.  Lets do an emergency rebuild
> +		 * to be safe
> +		 */
> +		rt_emergency_hash_rebuild();
>  	}
>  
>  	/* Try to bind route to arp only if it is output
> @@ -2946,6 +2955,31 @@ static void rt_secret_reschedule(int old)
>  	rtnl_unlock();
>  }
>  
> +static void rt_secret_rebuild_oneshot(void) {
> +	struct net *net;
> +	int old_interval = ip_rt_secret_interval;
> +
> +	ip_rt_secret_interval = 0;
> +
> +	rt_secret_reschedule(old_interval);
> +
> +	for_each_net(net) 
> +		rt_cache_invalidate(net);
> +
> +	ip_rt_secret_interval = old_interval;
> +
> +	rt_secret_reschedule(0);
> +}
> +
> +static void rt_emergency_hash_rebuild(void) {
> +	if (net_ratelimit()) {
> +		printk(KERN_WARNING "Route hash chain too long!\n");
> +		printk(KERN_WARNING "Adjust your secret_interval!\n");
> +	}
> +
> +	rt_secret_rebuild_oneshot();
> +}
> +
>  static int ipv4_sysctl_rt_secret_interval(ctl_table *ctl, int write,
>  					  struct file *filp,
>  					  void __user *buffer, size_t *lenp,

