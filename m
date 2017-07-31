From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net] ipv6: set fc_protocol with 0 when rtm_protocol is
 RTPROT_REDIRECT
Date: Sun, 30 Jul 2017 20:35:08 -0600
Message-ID: <9fcbffcb-4a14-764c-7fe4-2108b8944c17@gmail.com>
References: <e9342d18b97fc227cacc19db1b43f4c7350eed3f.1501419097.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, grawity@gmail.com
To: Xin Long <lucien.xin@gmail.com>,
        network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:33797 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751705AbdGaCfF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Jul 2017 22:35:05 -0400
Received: by mail-pg0-f42.google.com with SMTP id u185so26605260pgb.1
        for <netdev@vger.kernel.org>; Sun, 30 Jul 2017 19:35:05 -0700 (PDT)
In-Reply-To: <e9342d18b97fc227cacc19db1b43f4c7350eed3f.1501419097.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/30/17 6:51 AM, Xin Long wrote:
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 4d30c96..187580f 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -2912,9 +2912,11 @@ static int rtm_to_fib6_config(struct sk_buff *skb, struct nlmsghdr *nlh,
>  	cfg->fc_dst_len = rtm->rtm_dst_len;
>  	cfg->fc_src_len = rtm->rtm_src_len;
>  	cfg->fc_flags = RTF_UP;
> -	cfg->fc_protocol = rtm->rtm_protocol;
>  	cfg->fc_type = rtm->rtm_type;
>  
> +	if (rtm->rtm_protocol != RTPROT_REDIRECT)
> +		cfg->fc_protocol = rtm->rtm_protocol;
> +
>  	if (rtm->rtm_type == RTN_UNREACHABLE ||
>  	    rtm->rtm_type == RTN_BLACKHOLE ||
>  	    rtm->rtm_type == RTN_PROHIBIT ||

Did you look at removing this hunk from rt6_fill_node:

        if (rt->rt6i_flags & RTF_DYNAMIC)
                rtm->rtm_protocol = RTPROT_REDIRECT;
        else if (rt->rt6i_flags & RTF_ADDRCONF) {
                if (rt->rt6i_flags & (RTF_DEFAULT | RTF_ROUTEINFO))
                        rtm->rtm_protocol = RTPROT_RA;
                else
                        rtm->rtm_protocol = RTPROT_KERNEL;
        }

And have rtm_protocol set properly on the route when it is installed?
