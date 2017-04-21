From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net v2] ipv4: Avoid caching l3mdev dst on mismatched local
 route
Date: Fri, 21 Apr 2017 14:37:56 -0600
Message-ID: <e9fe3b0a-2ff8-b597-c13e-e8e6bfa4a7c5@cumulusnetworks.com>
References: <f3a3ab2d-4a32-a3ec-6a72-071e56577017@brocade.com>
 <1492806899-6215-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Robert Shearman <rshearma@brocade.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:34582 "EHLO
        mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1162468AbdDUUh7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 16:37:59 -0400
Received: by mail-io0-f178.google.com with SMTP id a103so133946864ioj.1
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 13:37:58 -0700 (PDT)
In-Reply-To: <1492806899-6215-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/21/17 2:34 PM, Robert Shearman wrote:
> David reported that doing the following:
> 
>     ip li add red type vrf table 10
>     ip link set dev eth1 vrf red
>     ip addr add 127.0.0.1/8 dev red
>     ip link set dev eth1 up
>     ip li set red up
>     ping -c1 -w1 -I red 127.0.0.1
>     ip li del red
> 
> when either policy routing IP rules are present or the local table
> lookup ip rule is before the l3mdev lookup results in a hang with
> these messages:
> 
>     unregister_netdevice: waiting for red to become free. Usage count = 1
> 
> The problem is caused by caching the dst used for sending the packet
> out of the specified interface on a local route with a different
> nexthop interface. Thus the dst could stay around until the route in
> the table the lookup was done is deleted which may be never.
> 
> Address the problem by not forcing output device to be the l3mdev in
> the flow's output interface if the lookup didn't use the l3mdev. This
> then results in the dst using the right device according to the route.
> 
> Changes in v2:
>  - make the dev_out passed in by __ip_route_output_key_hash correct
>    instead of checking the nh dev if FLOWI_FLAG_SKIP_NH_OIF is set as
>    suggested by David.
> 
> Fixes: 5f02ce24c2696 ("net: l3mdev: Allow the l3mdev to be a loopback")
> Reported-by: David Ahern <dsa@cumulusnetworks.com>
> Suggested-by: David Ahern <dsa@cumulusnetworks.com>
> Signed-off-by: Robert Shearman <rshearma@brocade.com>
> ---
>  net/ipv4/route.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index acd69cfe2951..d9724889ff09 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -2359,7 +2359,8 @@ struct rtable *__ip_route_output_key_hash(struct net *net, struct flowi4 *fl4,
>  		}
>  
>  		/* L3 master device is the loopback for that domain */
> -		dev_out = l3mdev_master_dev_rcu(dev_out) ? : net->loopback_dev;
> +		dev_out = l3mdev_master_dev_rcu(FIB_RES_DEV(res)) ? :
> +			net->loopback_dev;
>  		fl4->flowi4_oif = dev_out->ifindex;
>  		flags |= RTCF_LOCAL;
>  		goto make_route;
> 

LGTM

Acked-by: David Ahern <dsa@cumulusnetworks.com>
Tested-by: David Ahern <dsa@cumulusnetworks.com>
