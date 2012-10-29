From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net-next] ipv6: fix a potential NULL deref
Date: Mon, 29 Oct 2012 07:10:05 +0100
Message-ID: <1351491005.7394.7.camel@edumazet-glaptop>
References: <1351482620-11008-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:46261 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751934Ab2J2GKN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2012 02:10:13 -0400
Received: by mail-ee0-f46.google.com with SMTP id b15so1894122eek.19
        for <netdev@vger.kernel.org>; Sun, 28 Oct 2012 23:10:11 -0700 (PDT)
In-Reply-To: <1351482620-11008-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-10-29 at 11:50 +0800, Cong Wang wrote:
> In ipv6_del_addr():
> 
>                 if (rt != net->ipv6.ip6_null_entry &&
>                     addrconf_is_prefix_route(rt)) {
>                         if (onlink == 0) {
>                                 ip6_del_rt(rt);
>                                 rt = NULL;
>                         } else if (!(rt->rt6i_flags & RTF_EXPIRES)) {
>                                 rt6_set_expires(rt, expires);
>                         }
>                 }
>                 dst_release(&rt->dst);
> 
> obviously rt could be NULL'd before dst_release(), so
> we have to check if rt is NULL before calling it.
> 
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>
> 
> ---
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 8f0b12a..c467dbb 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -951,7 +951,8 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
>  				rt6_set_expires(rt, expires);
>  			}
>  		}
> -		dst_release(&rt->dst);
> +		if (rt)
> +			dst_release(&rt->dst);
>  	}
>  

dst_release() is like kfree(), it accepts a NULL argument.
