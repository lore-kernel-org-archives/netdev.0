From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net] net: check and errout if res->fi is NULL when
 RTM_F_FIB_MATCH is set
Date: Tue, 15 Aug 2017 20:56:24 -0600
Message-ID: <577b280e-5bef-ff83-ab72-fe61b42e02f9@cumulusnetworks.com>
References: <1502851818-17811-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de, idaifish@gmail.com,
        syzkaller@googlegroups.com, dvyukov@google.com,
        eric.dumazet@gmail.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:35931 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752832AbdHPC40 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 22:56:26 -0400
Received: by mail-pf0-f181.google.com with SMTP id c28so557136pfe.3
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 19:56:26 -0700 (PDT)
In-Reply-To: <1502851818-17811-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/15/17 8:50 PM, Roopa Prabhu wrote:
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 7effa62..49a018f 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -2763,14 +2763,21 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
>  	if (rtm->rtm_flags & RTM_F_LOOKUP_TABLE)
>  		table_id = rt->rt_table_id;
>  
> -	if (rtm->rtm_flags & RTM_F_FIB_MATCH)
> +	if (rtm->rtm_flags & RTM_F_FIB_MATCH) {
> +		if (!res.fi) {
> +			err = fib_props[res->type].error;
> +			if (!err)
> +				err = -EINVAL;

I think -EHOSTUNREACH is a better error than EINVAL. Nothing about the
user inputs are invalid; rather the lookup is failing, but indirectly.
