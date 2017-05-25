From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next 8/8] net: ipv6: RTM_GETROUTE: return matched fib
 result when requested
Date: Wed, 24 May 2017 20:35:24 -0600
Message-ID: <2106987d-7c19-b739-0103-97af3a3071da@gmail.com>
References: <1495649951-30417-1-git-send-email-roopa@cumulusnetworks.com>
 <1495649951-30417-9-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36501 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S937786AbdEYCf2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 22:35:28 -0400
Received: by mail-pf0-f194.google.com with SMTP id n23so35932903pfb.3
        for <netdev@vger.kernel.org>; Wed, 24 May 2017 19:35:27 -0700 (PDT)
In-Reply-To: <1495649951-30417-9-git-send-email-roopa@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since you have to do a v2 ...

On 5/24/17 12:19 PM, Roopa Prabhu wrote:
> @@ -3622,6 +3623,7 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
>  	memset(&fl6, 0, sizeof(fl6));
>  	rtm = nlmsg_data(nlh);
>  	fl6.flowlabel = ip6_make_flowinfo(rtm->rtm_tos, 0);
> +	fibmatch = (rtm->rtm_flags & RTM_F_FIB_MATCH) ? true : false;
this is typically done as !!(rtm->rtm_flags & RTM_F_FIB_MATCH)
>  
>  	if (tb[RTA_SRC]) {
>  		if (nla_len(tb[RTA_SRC]) < sizeof(struct in6_addr))
> @@ -3667,12 +3669,27 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
>  		if (!ipv6_addr_any(&fl6.saddr))
>  			flags |= RT6_LOOKUP_F_HAS_SADDR;
>  
> -		rt = (struct rt6_info *)ip6_route_input_lookup(net, dev, &fl6,
> -							       flags);
> +		if (!fibmatch)
> +			rt = (struct rt6_info *)ip6_route_input_lookup(net, dev,
> +								       &fl6,
> +								       flags);
>  	} else {
>  		fl6.flowi6_oif = oif;
>  
> -		rt = (struct rt6_info *)ip6_route_output(net, NULL, &fl6);
> +		if (!fibmatch)
> +			rt = (struct rt6_info *)ip6_route_output_flags(net,
> +								       NULL,
> +								       &fl6, 0);
> +	}
> +
> +	if (fibmatch) {
> +		rt = (struct rt6_info *)ip6_route_lookup(net, &fl6, 0);
> +		if (rt->dst.error) {
> +			err = rt->dst.error;
> +			ip6_rt_put(rt);
> +			goto errout;
> +		}
> +

I'd prefer to see the typecasts go away and use container_of to go from
dst_entry to rt6_info. I realize some of this is movement of existing
code, but better to clean up as we go.
