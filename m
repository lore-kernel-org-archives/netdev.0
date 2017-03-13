From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH] mpls: Do not decrement alive counter for unregister
 events
Date: Mon, 13 Mar 2017 11:10:56 +0000
Message-ID: <342ff118-9d48-e974-98e0-0789f6efb4f3@brocade.com>
References: <1489183899-2397-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <roopa@cumulusnetworks.com>
To: David Ahern <dsa@cumulusnetworks.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:34163 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752359AbdCMLLJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 07:11:09 -0400
In-Reply-To: <1489183899-2397-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/03/17 22:11, David Ahern wrote:
> Multipath routes can be rendered usesless when a device in one of the
> paths is deleted. For example:
>
> $ ip -f mpls ro ls
> 100
> 	nexthop as to 200 via inet 172.16.2.2  dev virt12
> 	nexthop as to 300 via inet 172.16.3.2  dev br0
> 101
> 	nexthop as to 201 via inet6 2000:2::2  dev virt12
> 	nexthop as to 301 via inet6 2000:3::2  dev br0
>
> $ ip li del br0
>
> When br0 is deleted the other hop is not considered in
> mpls_select_multipath because of the alive check -- rt_nhn_alive
> is 0.
>
> rt_nhn_alive is decremented once in mpls_ifdown when the device is taken
> down (NETDEV_DOWN) and again when it is deleted (NETDEV_UNREGISTER). For
> a 2 hop route, deleting one device drops the alive count to 0. Since
> devices are taken down before unregistering, the decrement on
> NETDEV_UNREGISTER is redundant.
>
> Fixes: c89359a42e2a4 ("mpls: support for dead routes")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>  net/mpls/af_mpls.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
> index ccdac9c44fdc..22a9971aa484 100644
> --- a/net/mpls/af_mpls.c
> +++ b/net/mpls/af_mpls.c
> @@ -1288,7 +1288,8 @@ static void mpls_ifdown(struct net_device *dev, int event)
>  				/* fall through */
>  			case NETDEV_CHANGE:
>  				nh->nh_flags |= RTNH_F_LINKDOWN;
> -				ACCESS_ONCE(rt->rt_nhn_alive) = rt->rt_nhn_alive - 1;
> +				if (event != NETDEV_UNREGISTER)
> +					ACCESS_ONCE(rt->rt_nhn_alive) = rt->rt_nhn_alive - 1;
>  				break;
>  			}
>  			if (event == NETDEV_UNREGISTER)
>

Doesn't this leave the problem that if the device's link goes down and 
then the device gets deleted the alive count will be decremented twice 
for the same path?

Perhaps it would be better to change the condition for decrementing the 
alive count to be "!(nh->nh_flags & (RTNH_F_LINKDOWN | RTNH_F_DEAD))"?

Thanks,
Rob
