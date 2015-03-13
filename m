From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ip6_tunnel: fix error code when tunnel exists
Date: Fri, 13 Mar 2015 06:43:47 -0700
Message-ID: <1426254227.11398.183.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1426251537-31870-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	me@pierre-cheynier.net,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:36463 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755301AbbCMNn7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 09:43:59 -0400
Received: by iegc3 with SMTP id c3so108199311ieg.3
        for <netdev@vger.kernel.org>; Fri, 13 Mar 2015 06:43:58 -0700 (PDT)
In-Reply-To: <1426251537-31870-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-03-13 at 13:58 +0100, Nicolas Dichtel wrote:
> After commit 2b0bb01b6edb, the kernel returns -ENOBUFS when user tries to add
> an existing tunnel with ioctl API:
> $ ip -6 tunnel add ip6tnl1 mode ip6ip6 dev eth1
> add tunnel "ip6tnl0" failed: No buffer space available
> 
> It's confusing, the right error is EEXIST.
> 
> Fixes: 2b0bb01b6edb ("ip6_tunnel: Return an error when adding an existing tunnel.")
> CC: Steffen Klassert <steffen.klassert@secunet.com>
> Reported-by: Pierre Cheynier <me@pierre-cheynier.net>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>  net/ipv6/ip6_tunnel.c | 22 +++++++++++++---------
>  1 file changed, 13 insertions(+), 9 deletions(-)
> 
> diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
> index 266a264ec212..7ba5608d64c5 100644
> --- a/net/ipv6/ip6_tunnel.c
> +++ b/net/ipv6/ip6_tunnel.c
> @@ -380,7 +380,7 @@ static struct ip6_tnl *ip6_tnl_locate(struct net *net,
>  		if (ipv6_addr_equal(local, &t->parms.laddr) &&
>  		    ipv6_addr_equal(remote, &t->parms.raddr)) {
>  			if (create)
> -				return NULL;
> +				return ERR_PTR(-EEXIST);
>  
>  			return t;
>  		}
> @@ -1420,7 +1420,7 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
>  			}
>  			ip6_tnl_parm_from_user(&p1, &p);
>  			t = ip6_tnl_locate(net, &p1, 0);
> -			if (t == NULL)
> +			if (IS_ERR_OR_NULL(t))

These IS_ERR_OR_NULL(t) looks like defensive/lazy programming to me.

A NULL pointer should not be allowed here.

If t is not valid, it should be a plain error code mapping.

I wish we get rid of all IS_ERR_OR_NULL() uses in networking tree,
instead of adding plenty of them.
