From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next v2] net: Add table id from route lookup to route
 response
Date: Wed, 2 Sep 2015 13:41:08 -0700
Message-ID: <55E75EE4.2050602@gmail.com>
References: <20150902190836.GD20527@pox.localdomain>
 <1441224980-6201-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35559 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755419AbbIBUlL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 16:41:11 -0400
Received: by pacfv12 with SMTP id fv12so22670612pac.2
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2015 13:41:10 -0700 (PDT)
In-Reply-To: <1441224980-6201-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/02/2015 01:16 PM, David Ahern wrote:
> IPv4 ABI has the table hardcoded as RT_TABLE_MAIN regardless of the table
> hit for the route lookup. Add the table using a new attribute,
> RTA_TABLE_LOOKUP, to maintain the ABI yet return the right table id.
>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>
> Thomas: Something like this?
>
> The current ABI is returning wrong data in some cases; that seems worse
> to me than breaking the ABI.
>
>   include/uapi/linux/rtnetlink.h | 1 +
>   net/ipv4/route.c               | 5 +++++
>   net/ipv6/route.c               | 4 ++++
>   3 files changed, 10 insertions(+)
>
> diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
> index 702024769c74..5add1468350a 100644
> --- a/include/uapi/linux/rtnetlink.h
> +++ b/include/uapi/linux/rtnetlink.h
> @@ -310,6 +310,7 @@ enum rtattr_type_t {
>   	RTA_PREF,
>   	RTA_ENCAP_TYPE,
>   	RTA_ENCAP,
> +	RTA_TABLE_LOOKUP,  /* table hit for fib lookup */
>   	__RTA_MAX
>   };
>
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 92acc95b7578..95454c368e66 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -2328,6 +2328,11 @@ static int rt_fill_info(struct net *net,  __be32 dst, __be32 src,
>   	r->rtm_table	= RT_TABLE_MAIN;
>   	if (nla_put_u32(skb, RTA_TABLE, RT_TABLE_MAIN))
>   		goto nla_put_failure;
> +
> +	if (rt->rt_table_id && rt->rt_table_id != RT_TABLE_MAIN &&
> +	    nla_put_u32(skb, RTA_TABLE_LOOKUP, rt->rt_table_id))
> +		goto nla_put_failure;
> +
>   	r->rtm_type	= rt->rt_type;
>   	r->rtm_scope	= RT_SCOPE_UNIVERSE;
>   	r->rtm_protocol = RTPROT_UNSPEC;

Why not implement this this same for IPv4 and IPv6?  It looks like it is 
only included if it is non-zer and not MAIN in the above case, and then 
below as long as a table ID is non-zero you are setting the value.  Why 
not just include the value in all cases where it is defined just like 
for IPv6?

> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index f45cac6f8356..3c5d3a50bb7b 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -2922,6 +2922,10 @@ static int rt6_fill_node(struct net *net,
>   	rtm->rtm_table = table;
>   	if (nla_put_u32(skb, RTA_TABLE, table))
>   		goto nla_put_failure;
> +
> +	if (table && nla_put_u32(skb, RTA_TABLE_LOOKUP, table))
> +		goto nla_put_failure;
> +
>   	if (rt->rt6i_flags & RTF_REJECT) {
>   		switch (rt->dst.error) {
>   		case -EINVAL:
>
