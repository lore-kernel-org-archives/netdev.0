From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/2] net: mpls: Don't show nexthop if device
 has been deleted
Date: Sun, 26 Mar 2017 10:20:50 -0700
Message-ID: <58D7F872.9070707@cumulusnetworks.com>
References: <1490394117-19268-1-git-send-email-dsa@cumulusnetworks.com> <1490394117-19268-2-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rshearma@brocade.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:33312 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751889AbdCZRU5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 26 Mar 2017 13:20:57 -0400
Received: by mail-pg0-f51.google.com with SMTP id n5so10389660pgh.0
        for <netdev@vger.kernel.org>; Sun, 26 Mar 2017 10:20:56 -0700 (PDT)
In-Reply-To: <1490394117-19268-2-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/24/17, 3:21 PM, David Ahern wrote:
> If the device for a nexthop in a multipath route is deleted, the nexthop
> is effectively removed from the route. Currently, a route dump still
> returns the nexhop though without the device set:
>
> $ ip -f mpls ro ls
> 100
> 	nexthopvia inet 10.11.1.2  dev br0
> 	nexthopvia inet 10.100.3.1  dev eth3
> $ ip li del br0
> $ ip -f mpls ro ls
> 100
> 	nexthopvia inet 10.11.1.2  dev * dead linkdown
> 	nexthopvia inet 10.100.3.1  dev eth3
>
> Since the nexthop is effectively deleted, drop the hop from the route
> dump.
>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>  net/mpls/af_mpls.c | 8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
>
> diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
> index cd8be8d5e4ad..3861f8dfa9c1 100644
> --- a/net/mpls/af_mpls.c
> +++ b/net/mpls/af_mpls.c
> @@ -1769,13 +1769,15 @@ static int mpls_dump_route(struct sk_buff *skb, u32 portid, u32 seq, int event,
>  			goto nla_put_failure;
>  
>  		for_nexthops(rt) {
> +			dev = rtnl_dereference(nh->nh_dev);
> +			if (!dev)
> +				continue;
> +

size calculation may have to account for this too ?.
>  			rtnh = nla_reserve_nohdr(skb, sizeof(*rtnh));
>  			if (!rtnh)
>  				goto nla_put_failure;
>  
> -			dev = rtnl_dereference(nh->nh_dev);
> -			if (dev)
> -				rtnh->rtnh_ifindex = dev->ifindex;
> +			rtnh->rtnh_ifindex = dev->ifindex;
>  			if (nh->nh_flags & RTNH_F_LINKDOWN) {
>  				rtnh->rtnh_flags |= RTNH_F_LINKDOWN;
>  				linkdown++;



Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>
