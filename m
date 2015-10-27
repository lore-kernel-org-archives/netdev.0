From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCHv2 net 2/2] ipv4: update RTNH_F_LINKDOWN flag on UP event
Date: Tue, 27 Oct 2015 00:52:04 -0400
Message-ID: <20151027045203.GG3567@gospo.home.greyhouse.net>
References: <1445896753-14464-1-git-send-email-ja@ssi.bg>
 <1445896753-14464-3-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f43.google.com ([209.85.192.43]:34394 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750920AbbJ0EwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 00:52:08 -0400
Received: by qgem9 with SMTP id m9so137710030qge.1
        for <netdev@vger.kernel.org>; Mon, 26 Oct 2015 21:52:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1445896753-14464-3-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 26, 2015 at 11:59:13PM +0200, Julian Anastasov wrote:
> When nexthop is part of multipath route we should clear the
> LINKDOWN flag when link goes UP or when first address is added.
> This is needed because we always set LINKDOWN flag when DEAD flag
> was set but now on UP the nexthop is not dead anymore. Examples when
> LINKDOWN bit can be forgotten when no NETDEV_CHANGE is delivered:
> 
> - link goes down (LINKDOWN is set), then link goes UP and device
> shows carrier OK but LINKDOWN remains set
> 
> - last address is deleted (LINKDOWN is set), then address is
> added and device shows carrier OK but LINKDOWN remains set
> 
> Steps to reproduce:
> modprobe dummy
> ifconfig dummy0 192.168.168.1 up
> 
> here add a multipath route where one nexthop is for dummy0:
> 
> ip route add 1.2.3.4 nexthop dummy0 nexthop SOME_OTHER_DEVICE
> ifconfig dummy0 down
> ifconfig dummy0 up
> 
> now ip route shows nexthop that is not dead. Now set the sysctl var:
> 
> echo 1 > /proc/sys/net/ipv4/conf/dummy0/ignore_routes_with_linkdown
> 
> now ip route will show a dead nexthop because the forgotten
> RTNH_F_LINKDOWN is propagated as RTNH_F_DEAD.

I tested this patch and I now see that your reported problem is a result
of dummy never taking carrier down.  There was a presumption that
carrier notification would go down when hardware went down (or when the
logical device backing the hardware went down, but this is clearly not
always the case.

> Fixes: 8a3d03166f19 ("net: track link-status of ipv4 nexthops")
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
>  net/ipv4/fib_semantics.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
> index f493eff..f657418 100644
> --- a/net/ipv4/fib_semantics.c
> +++ b/net/ipv4/fib_semantics.c
> @@ -1445,6 +1445,13 @@ int fib_sync_up(struct net_device *dev, unsigned int nh_flags)
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

Logically this patch makes sense, but I feel as though there may be a
slightly better option.  Possibly this:

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 42778d9..7eb7c40 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -1376,7 +1376,8 @@ int fib_sync_down_dev(struct net_device *dev, unsigned long event)
 					nexthop_nh->nh_flags |= RTNH_F_DEAD;
 					/* fall through */
 				case NETDEV_CHANGE:
-					nexthop_nh->nh_flags |= RTNH_F_LINKDOWN;
+					if (!netif_carrier_ok(dev))
+						nexthop_nh->nh_flags |= RTNH_F_LINKDOWN;
 					break;
 				}
 				dead++;
@@ -1396,7 +1397,8 @@ int fib_sync_down_dev(struct net_device *dev, unsigned long event)
 				fi->fib_flags |= RTNH_F_DEAD;
 				/* fall through */
 			case NETDEV_CHANGE:
-				fi->fib_flags |= RTNH_F_LINKDOWN;
+				if (!netif_carrier_ok(dev))
+					fi->fib_flags |= RTNH_F_LINKDOWN;
 				break;
 			}
 			ret++;
