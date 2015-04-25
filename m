From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 6/6] ipv6: netfilter: simply if-else statements
Date: Sat, 25 Apr 2015 09:17:44 -0700
Message-ID: <1429978664.32250.24.camel@perches.com>
References: <1429954020-11763-1-git-send-email-ipm@chirality.org.uk>
	 <1429954020-11763-7-git-send-email-ipm@chirality.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ian Morris <ipm@chirality.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0194.hostedemail.com ([216.40.44.194]:44957 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S964772AbbDYQRs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Apr 2015 12:17:48 -0400
In-Reply-To: <1429954020-11763-7-git-send-email-ipm@chirality.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2015-04-25 at 10:27 +0100, Ian Morris wrote:
> Remove "else" branch of "if" statements where a return is always done
> when the condition is true.

trivia:

> diff --git a/net/ipv6/netfilter/ip6t_hbh.c b/net/ipv6/netfilter/ip6t_hbh.c
[]
> @@ -95,70 +95,67 @@ hbh_mt6(const struct sk_buff *skb, struct xt_action_param *par)
>  
>  	ptr += 2;
>  	hdrlen -= 2;
> -	if (!(optinfo->flags & IP6T_OPTS_OPTS)) {
> +	if (!(optinfo->flags & IP6T_OPTS_OPTS))
>  		return ret;
> -	} else {
> -		pr_debug("Strict ");
> -		pr_debug("#%d ", optinfo->optsnr);
> -		for (temp = 0; temp < optinfo->optsnr; temp++) {
> -			/* type field exists ? */
> -			if (hdrlen < 1)
> +
> +	pr_debug("Strict ");
> +	pr_debug("#%d ", optinfo->optsnr);

I think the logging is a bit broken.

> +	for (temp = 0; temp < optinfo->optsnr; temp++) {
> +		/* type field exists ? */
> +		if (hdrlen < 1)
> +			break;
> +		tp = skb_header_pointer(skb, ptr, sizeof(_opttype),
> +					&_opttype);

fits on a single line
		tp = skb_header_pointer(skb, ptr, sizeof(_opttype), &_opttype);

[]

> +			if (spec_len != 0x00FF && spec_len != *lp) {
> +				pr_debug("Lbad %02X %04X\n", *lp,
> +					 spec_len);

My preference is to keep format and arguments on
separate lines when it's necessary to use multiple lines.

				pr_debug("Lbad %02X %04X\n",
					 *lp, spec_len);

> diff --git a/net/ipv6/netfilter/ip6t_rt.c b/net/ipv6/netfilter/ip6t_rt.c
[]
> @@ -119,66 +119,62 @@ static bool rt_mt6(const struct sk_buff *skb, struct xt_action_param *par)
[]
> +		pr_debug("#%d ", rtinfo->addrnr);
> +		for (temp = 0;
> +		     temp < (unsigned int)((hdrlen - 8) / 16);

I believe the cast isn't necessary

> +		     temp++) {

so this could be

		for (temp = 0; temp < (hdrlen - 8) / 16, temp++) {

> +			ap = skb_header_pointer(skb,
> +						ptr
> +						+ sizeof(struct rt0_hdr)
> +						+ temp * sizeof(_addr),
> +						sizeof(_addr),
> +						&_addr);

That's an unfortunate calculation of ptr + ...
It might be clearer to use a temporary.
