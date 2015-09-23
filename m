From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 2/9] net: Remove e_inval label from
 ip_route_input_slow
Date: Wed, 23 Sep 2015 08:45:05 -0700
Message-ID: <5602C901.2050404@gmail.com>
References: <1443021322-48621-1-git-send-email-dsa@cumulusnetworks.com>
 <1443021322-48621-3-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33128 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751877AbbIWPpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 11:45:07 -0400
Received: by pacex6 with SMTP id ex6so43834278pac.0
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 08:45:06 -0700 (PDT)
In-Reply-To: <1443021322-48621-3-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/23/2015 08:15 AM, David Ahern wrote:
> e_inval has 1 explicit user and 1 fallthrough user -- martian_destination.
> Move setting err to EINVAL before the 2 users and use the goto out label
> instead of e_inval.
>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>   net/ipv4/route.c | 7 +++----
>   1 file changed, 3 insertions(+), 4 deletions(-)
>
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index ef36dfed24da..3c5000db5972 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1775,8 +1775,9 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
>   out:	return err;
>   
>   brd_input:
> +	err = -EINVAL;
>   	if (skb->protocol != htons(ETH_P_IP))
> -		goto e_inval;
> +		goto out;
>   
>   	if (!ipv4_is_zeronet(saddr)) {
>   		err = fib_validate_source(skb, saddr, 0, tos, 0, dev,
> @@ -1842,15 +1843,13 @@ out:	return err;
>   	 *	Do not cache martian addresses: they should be logged (RFC1812)
>   	 */
>   martian_destination:
> +	err = -EINVAL;
>   	RT_CACHE_STAT_INC(in_martian_dst);
>   #ifdef CONFIG_IP_ROUTE_VERBOSE
>   	if (IN_DEV_LOG_MARTIANS(in_dev))
>   		net_warn_ratelimited("martian destination %pI4 from %pI4, dev %s\n",
>   				     &daddr, &saddr, dev->name);
>   #endif
> -
> -e_inval:
> -	err = -EINVAL;
>   	goto out;
>   
>   e_nobufs:

This is adding unnecessary bloat to the code.  I really think if you 
want to simplify this just replace "goto e_inval;" with "return -EINVAL;".

Also why is it you end up leaving the out label through all of these 
patches?  It seems like that would be one of the first places to start 
in terms of removing the labels.

- Alex
