From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net v2] net: enable interface alias removal via rtnl
Date: Tue, 10 Oct 2017 08:50:45 -0600
Message-ID: <c81359e7-feb8-475e-69d7-3eacc3406caf@gmail.com>
References: <1cccbbaa-455b-66e0-a447-7f7e3b3bb375@gmail.com>
 <20171010124138.27342-1-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oliver@hartkopp.net,
        Stephen Hemminger <stephen@networkplumber.org>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36067 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751385AbdJJOur (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 10:50:47 -0400
Received: by mail-pf0-f196.google.com with SMTP id z11so18819924pfk.3
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 07:50:47 -0700 (PDT)
In-Reply-To: <20171010124138.27342-1-nicolas.dichtel@6wind.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/10/17 6:41 AM, Nicolas Dichtel wrote:
> IFLA_IFALIAS is defined as NLA_STRING. It means that the minimal length of
> the attribute is 1 ("\0"). However, to remove an alias, the attribute
> length must be 0 (see dev_set_alias()).
> 
> Let's define the type to NLA_BINARY, so that the alias can be removed.

not to be pedantic, but we need to be clear that the type is changed
only for policy validation.

> 
> Example:
> $ ip l s dummy0 alias foo
> $ ip l l dev dummy0
> 5: dummy0: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
>     link/ether ae:20:30:4f:a7:f3 brd ff:ff:ff:ff:ff:ff
>     alias foo
> 
> Before the patch:
> $ ip l s dummy0 alias ""
> RTNETLINK answers: Numerical result out of range
> 
> After the patch:
> $ ip l s dummy0 alias ""
> $ ip l l dev dummy0
> 5: dummy0: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
>     link/ether ae:20:30:4f:a7:f3 brd ff:ff:ff:ff:ff:ff
> 
> CC: Oliver Hartkopp <oliver@hartkopp.net>
> CC: Stephen Hemminger <stephen@networkplumber.org>
> Fixes: 96ca4a2cc145 ("net: remove ifalias on empty given alias")
> Reported-by: Julien FLoret <julien.floret@6wind.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
> 
> v1 -> v2: add the comment
> 
>  net/core/rtnetlink.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index d4bcdcc68e92..5343565d88b7 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -1483,7 +1483,10 @@ static const struct nla_policy ifla_policy[IFLA_MAX+1] = {
>  	[IFLA_LINKINFO]		= { .type = NLA_NESTED },
>  	[IFLA_NET_NS_PID]	= { .type = NLA_U32 },
>  	[IFLA_NET_NS_FD]	= { .type = NLA_U32 },
> -	[IFLA_IFALIAS]	        = { .type = NLA_STRING, .len = IFALIASZ-1 },
> +	/* IFLA_IFALIAS is a string, but policy is set to NLA_BINARY to
> +	 * allow 0-length string (needed to remove an alias).
> +	 */
> +	[IFLA_IFALIAS]	        = { .type = NLA_BINARY, .len = IFALIASZ - 1 },
>  	[IFLA_VFINFO_LIST]	= {. type = NLA_NESTED },
>  	[IFLA_VF_PORTS]		= { .type = NLA_NESTED },
>  	[IFLA_PORT_SELF]	= { .type = NLA_NESTED },
> 

Seems like a reasonable solution.

Acked-by: David Ahern <dsahern@gmail.com>
