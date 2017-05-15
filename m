From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net] ipv6: avoid dad-failures for addresses with NODAD
Date: Mon, 15 May 2017 05:56:29 -0600
Message-ID: <0f49737f-f6d1-6025-4eb2-2cabc2f88688@gmail.com>
References: <20170513000339.15843-1-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
        Mahesh Bandewar <maheshb@google.com>
To: Mahesh Bandewar <mahesh@bandewar.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36222 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755231AbdEOL4h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 07:56:37 -0400
Received: by mail-io0-f193.google.com with SMTP id f102so11287781ioi.3
        for <netdev@vger.kernel.org>; Mon, 15 May 2017 04:56:37 -0700 (PDT)
In-Reply-To: <20170513000339.15843-1-mahesh@bandewar.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/12/17 6:03 PM, Mahesh Bandewar wrote:
> From: Mahesh Bandewar <maheshb@google.com>
> 
> Every address gets added with TENTATIVE flag even for the addresses with
> IFA_F_NODAD flag and dad-work is scheduled for them. During this DAD process
> we realize it's an address with NODAD and complete the process without
> sending any probe. However the TENTATIVE flags stays on the
> address for sometime enough to cause misinterpretation when we receive a NS.
> While processing NS, if the address has TENTATIVE flag, we mark it DADFAILED
> and endup with an address that was originally configured as NODAD with
> DADFAILED.
> 
> We can't avoid scheduling dad_work for addresses with NODAD but we can
> avoid adding TENTATIVE flag to avoid this racy situation.
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
>  net/ipv6/addrconf.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index b09ac38d8dc4..53f2dc092023 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -1022,7 +1022,10 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
>  	INIT_HLIST_NODE(&ifa->addr_lst);
>  	ifa->scope = scope;
>  	ifa->prefix_len = pfxlen;
> -	ifa->flags = flags | IFA_F_TENTATIVE;
> +	ifa->flags = flags;
> +	/* No need to add the TENTATIVE flag for addresses with NODAD */
> +	if (!(flags & IFA_F_NODAD))
> +		ifa->flags |= IFA_F_TENTATIVE;
>  	ifa->valid_lft = valid_lft;
>  	ifa->prefered_lft = prefered_lft;
>  	ifa->cstamp = ifa->tstamp = jiffies;
> 

LGTM.

Acked-by: David Ahern <dsahern@gmail.com>
