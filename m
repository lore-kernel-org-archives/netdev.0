From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net] ipv4: fix problems from the RTNH_F_LINKDOWN
 introduction
Date: Mon, 26 Oct 2015 16:31:07 -0400
Message-ID: <20151026203104.GE3567@gospo.home.greyhouse.net>
References: <1445710800-8320-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f174.google.com ([209.85.220.174]:33664 "EHLO
	mail-qk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751281AbbJZUbK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 16:31:10 -0400
Received: by qkcy65 with SMTP id y65so114179879qkc.0
        for <netdev@vger.kernel.org>; Mon, 26 Oct 2015 13:31:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1445710800-8320-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 24, 2015 at 09:20:00PM +0300, Julian Anastasov wrote:
> When fib_netdev_event calls fib_disable_ip on NETDEV_DOWN event
> we should not delete the local routes if the local address
> is still present. The confusion comes from the fact that both
> fib_netdev_event and fib_inetaddr_event use the NETDEV_DOWN
> constant. Fix it by returning back the variable 'force'.
> 
> Steps to reproduce:
> modprobe dummy
> ifconfig dummy0 192.168.168.1 up
> ip route list table local | grep dummy | grep host
> local 192.168.168.1 dev dummy0  proto kernel  scope host  src 192.168.168.1
I tested this before and after your patch and I don't see a different
output.  Was I supposed to see something different?

> Second fix
I would prefer you move these two fixes into 2 separate patches as it
isn't totally clear which hunks fix each of these issues.

> is for fib_sync_up: when nexthop is part of multipath
> route we should clear the LINKDOWN flag when link goes UP
> or when first address is added. This is needed because we always
> set LINKDOWN flag when DEAD flag is set but now the nexthop
> is not dead anymore. Examples when LINKDOWN bit can be forgotten:
> 
> - link goes down (LINKDOWN is set), then link goes UP and device
> shows carrier OK but LINKDOWN remains set
> 
> - last address is deleted (LINKDOWN is set), then address is
> added and device shows carrier OK but LINKDOWN remains set

Are you seeing this with iproute2 (or other tools) or are you just
seeing this by monitoring netlink messages/looking at a netlink cache
you have built inside an application?

I have seen a problem similar to what you have reported with netlink
caches and have a fix I can give you if you would like to try it.  It is
a slightly larger structural change, but it appears to cover covers a
few more cases than this fix does.

> 
> Fixes: 8a3d03166f19 ("net: track link-status of ipv4 nexthops")
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
>  include/net/ip_fib.h     |  2 +-
>  net/ipv4/fib_frontend.c  | 13 +++++++------
>  net/ipv4/fib_semantics.c | 18 +++++++++++++++---
>  3 files changed, 23 insertions(+), 10 deletions(-)
> 
> diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
> index 727d6e9..654aec1 100644
> --- a/include/net/ip_fib.h
> +++ b/include/net/ip_fib.h
> @@ -317,7 +317,7 @@ void fib_flush_external(struct net *net);
>  
>  /* Exported by fib_semantics.c */
>  int ip_fib_check_default(__be32 gw, struct net_device *dev);
> -int fib_sync_down_dev(struct net_device *dev, unsigned long event);
> +int fib_sync_down_dev(struct net_device *dev, unsigned long event, int force);
>  int fib_sync_down_addr(struct net *net, __be32 local);
>  int fib_sync_up(struct net_device *dev, unsigned int nh_flags);
>  void fib_select_multipath(struct fib_result *res);
> diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
> index 690bcbc..4826a22 100644
> --- a/net/ipv4/fib_frontend.c
> +++ b/net/ipv4/fib_frontend.c
> @@ -1110,9 +1110,10 @@ static void nl_fib_lookup_exit(struct net *net)
>  	net->ipv4.fibnl = NULL;
>  }
>  
> -static void fib_disable_ip(struct net_device *dev, unsigned long event)
> +static void fib_disable_ip(struct net_device *dev, unsigned long event,
> +			   int force)
>  {
> -	if (fib_sync_down_dev(dev, event))
> +	if (fib_sync_down_dev(dev, event, force))
>  		fib_flush(dev_net(dev));
>  	rt_cache_flush(dev_net(dev));
>  	arp_ifdown(dev);
> @@ -1140,7 +1141,7 @@ static int fib_inetaddr_event(struct notifier_block *this, unsigned long event,
>  			/* Last address was deleted from this interface.
>  			 * Disable IP.
>  			 */
> -			fib_disable_ip(dev, event);
> +			fib_disable_ip(dev, event, 1);
>  		} else {
>  			rt_cache_flush(dev_net(dev));
>  		}
> @@ -1157,7 +1158,7 @@ static int fib_netdev_event(struct notifier_block *this, unsigned long event, vo
>  	unsigned int flags;
>  
>  	if (event == NETDEV_UNREGISTER) {
> -		fib_disable_ip(dev, event);
> +		fib_disable_ip(dev, event, 2);
>  		rt_flush_dev(dev);
>  		return NOTIFY_DONE;
>  	}
> @@ -1178,14 +1179,14 @@ static int fib_netdev_event(struct notifier_block *this, unsigned long event, vo
>  		rt_cache_flush(net);
>  		break;
>  	case NETDEV_DOWN:
> -		fib_disable_ip(dev, event);
> +		fib_disable_ip(dev, event, 0);
>  		break;
>  	case NETDEV_CHANGE:
>  		flags = dev_get_flags(dev);
>  		if (flags & (IFF_RUNNING | IFF_LOWER_UP))
>  			fib_sync_up(dev, RTNH_F_LINKDOWN);
>  		else
> -			fib_sync_down_dev(dev, event);
> +			fib_sync_down_dev(dev, event, 0);
>  		/* fall through */
>  	case NETDEV_CHANGEMTU:
>  		rt_cache_flush(net);
> diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
> index 064bd3c..f657418 100644
> --- a/net/ipv4/fib_semantics.c
> +++ b/net/ipv4/fib_semantics.c
> @@ -1281,7 +1281,13 @@ int fib_sync_down_addr(struct net *net, __be32 local)
>  	return ret;
>  }
>  
> -int fib_sync_down_dev(struct net_device *dev, unsigned long event)
> +/* Event              force Flags           Description
> + * NETDEV_CHANGE      0     LINKDOWN        Carrier OFF, not for scope host
> + * NETDEV_DOWN        0     LINKDOWN|DEAD   Link down, not for scope host
> + * NETDEV_DOWN        1     LINKDOWN|DEAD   Last address removed
> + * NETDEV_UNREGISTER  2     LINKDOWN|DEAD   Device removed
> + */
> +int fib_sync_down_dev(struct net_device *dev, unsigned long event, int force)
>  {
>  	int ret = 0;
>  	int scope = RT_SCOPE_NOWHERE;
> @@ -1290,8 +1296,7 @@ int fib_sync_down_dev(struct net_device *dev, unsigned long event)
>  	struct hlist_head *head = &fib_info_devhash[hash];
>  	struct fib_nh *nh;
>  
> -	if (event == NETDEV_UNREGISTER ||
> -	    event == NETDEV_DOWN)
> +	if (force)
>  		scope = -1;
>  
>  	hlist_for_each_entry(nh, head, nh_hash) {
> @@ -1440,6 +1445,13 @@ int fib_sync_up(struct net_device *dev, unsigned int nh_flags)
>  	if (!(dev->flags & IFF_UP))
>  		return 0;
>  
> +	if (nh_flags & RTNH_F_DEAD) {
> +		unsigned int flags = dev_get_flags(dev);
> +
> +		if (flags & (IFF_RUNNING | IFF_LOWER_UP))
> +			nh_flags |= RTNH_F_LINKDOWN;
> +	}
> +
>  	prev_fi = NULL;
>  	hash = fib_devindex_hashfn(dev->ifindex);
>  	head = &fib_info_devhash[hash];
> -- 
> 1.9.3
> 
