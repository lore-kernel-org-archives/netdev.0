From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH iproute2] route: label externally offloaded routes
Date: Mon, 9 Mar 2015 10:02:41 -0400
Message-ID: <20150309140241.GI502@gospo.home.greyhouse.net>
References: <1425795335-6416-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	jiri@resnulli.us
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f181.google.com ([209.85.216.181]:35853 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753874AbbCIOCr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 10:02:47 -0400
Received: by qcxm20 with SMTP id m20so2213328qcx.3
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 07:02:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1425795335-6416-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 07, 2015 at 10:15:35PM -0800, sfeldma@gmail.com wrote:
> From: Scott Feldman <sfeldma@gmail.com>
> 
> On ip route print dump, label externally offloaded routes with "external".
> Offloaded routes are flagged with RTNH_F_EXTERNAL, a recent additon to
> net-next.  For example:
> 
> $ ip route
> default via 192.168.0.2 dev eth0
> 11.0.0.0/30 dev swp1  proto kernel  scope link  src 11.0.0.2 external
> 11.0.0.4/30 via 11.0.0.1 dev swp1  proto zebra  metric 20 external
> 11.0.0.8/30 dev swp2  proto kernel  scope link  src 11.0.0.10 external
> 11.0.0.12/30 via 11.0.0.9 dev swp2  proto zebra  metric 20 external
> 12.0.0.2  proto zebra  metric 30 external
>         nexthop via 11.0.0.1  dev swp1 weight 1
>         nexthop via 11.0.0.9  dev swp2 weight 1
> 12.0.0.3 via 11.0.0.1 dev swp1  proto zebra  metric 20 external
> 12.0.0.4 via 11.0.0.9 dev swp2  proto zebra  metric 20 external
> 192.168.0.0/24 dev eth0  proto kernel  scope link  src 192.168.0.15
> 
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>

You know we cannot have a thread about nomenclature without a comment
from me.  ;)

My only concern about 'external' is whether or not people will gloss
over it since many of the routes listed will be to networks that
actually are external to the system.  That namespace collision could
seem awkward if you are not a traditional follower of this list.
Listing an FDB entry as 'external' does not have the same issue since
all FDB entries are local to the system, so I didn't even
think about the potential when that set was posted.

I would like to just call this 'hardware' since that is what we appear
to be using for offload and would make it clear to the user that this
route was in hardware as well as in the kernel.  I'd say the same for
FDB entries, too.

Scott, you have lots of experience in both traditional and Linux worlds,
do you think my concern about confusion is unnecessary?

> ---
>  include/linux/rtnetlink.h |    1 +
>  ip/iproute.c              |    2 ++
>  2 files changed, 3 insertions(+)
> 
> diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
> index 3eb7810..c74773c 100644
> --- a/include/linux/rtnetlink.h
> +++ b/include/linux/rtnetlink.h
> @@ -332,6 +332,7 @@ struct rtnexthop {
>  #define RTNH_F_DEAD		1	/* Nexthop is dead (used by multipath)	*/
>  #define RTNH_F_PERVASIVE	2	/* Do recursive gateway lookup	*/
>  #define RTNH_F_ONLINK		4	/* Gateway is forced on link	*/
> +#define RTNH_F_EXTERNAL		8	/* Route installed externally   */
>  
>  /* Macros to handle hexthops */
>  
> diff --git a/ip/iproute.c b/ip/iproute.c
> index 76d8e36..fdb0a98 100644
> --- a/ip/iproute.c
> +++ b/ip/iproute.c
> @@ -426,6 +426,8 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
>  		fprintf(fp, "onlink ");
>  	if (r->rtm_flags & RTNH_F_PERVASIVE)
>  		fprintf(fp, "pervasive ");
> +	if (r->rtm_flags & RTNH_F_EXTERNAL)
> +		fprintf(fp, "external ");
>  	if (r->rtm_flags & RTM_F_NOTIFY)
>  		fprintf(fp, "notify ");
>  	if (tb[RTA_MARK]) {
> -- 
> 1.7.10.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
