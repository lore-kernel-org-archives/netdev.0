From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 3/9] net: Remove e_nobufs label from ip_route_input_slow
Date: Tue, 22 Sep 2015 21:15:22 -0500
Message-ID: <877fnhc24l.fsf@x220.int.ebiederm.org>
References: <1442962523-3974-1-git-send-email-dsa@cumulusnetworks.com>
	<1442962523-3974-4-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:55916 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759819AbbIWCWk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 22:22:40 -0400
In-Reply-To: <1442962523-3974-4-git-send-email-dsa@cumulusnetworks.com> (David
	Ahern's message of "Tue, 22 Sep 2015 15:55:17 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Ahern <dsa@cumulusnetworks.com> writes:

> e_nobufs has 1 user. Move setting err to -ENOBUFS for the 1 user and
> use the goto out label instead of e_nobufs. Stepping stone patch; next
> one moves rth code into a helper function.

Ick you are pessimizing the code.

You will almost certainly have better code generation if you hoist
the assignment of "err = -ENOBUFS" above the rt_dst_alloc then you
don't need to do anything in your error path except "goto out;"

Eric

> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>  net/ipv4/route.c | 10 ++++------
>  1 file changed, 4 insertions(+), 6 deletions(-)
>
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 3c5000db5972..e3b18cc1952f 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1805,8 +1805,10 @@ out:	return err;
>  
>  	rth = rt_dst_alloc(net->loopback_dev, flags | RTCF_LOCAL, res.type,
>  			   IN_DEV_CONF_GET(in_dev, NOPOLICY), false, do_cache);
> -	if (!rth)
> -		goto e_nobufs;
> +	if (!rth) {
> +		err = -ENOBUFS;
> +		goto out;
> +	}
>  
>  	rth->dst.output= ip_rt_bug;
>  #ifdef CONFIG_IP_ROUTE_CLASSID
> @@ -1852,10 +1854,6 @@ out:	return err;
>  #endif
>  	goto out;
>  
> -e_nobufs:
> -	err = -ENOBUFS;
> -	goto out;
> -
>  martian_source:
>  	ip_handle_martian_source(dev, in_dev, skb, daddr, saddr);
>  	goto out;
