From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Fix oops in xfrm4_dst_destroy()
Date: Mon, 26 Feb 2007 01:24:37 +0100
Message-ID: <45E228C5.3060108@trash.net>
References: <20070225204315.GB31715@strauss.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Miika Komu <miika@iki.fi>, netdev@vger.kernel.org
To: Bernhard Walle <bwalle@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53669 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933703AbXBZASt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Feb 2007 19:18:49 -0500
In-Reply-To: <20070225204315.GB31715@strauss.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bernhard Walle wrote:
> With 2.6.21-rc1, I get an oops when running 'ifdown eth0' and an IPsec
> connection is active. If I shut down the connection before running 'ifdown
> eth0', then there's no problem.  The critical operation of this script is to
> kill dhcpd.
> 
> The problem is probably caused by commit with git identifier
> 4337226228e1cfc1d70ee975789c6bd070fb597c (Linus tree) "[IPSEC]: IPv4 over IPv6
> IPsec tunnel".
> 
> This patch fixes that oops. I don't know the network code of the Linux kernel
> in deep, so if that fix is wrong, please change it. But please fix the oops. :)

Looks good, when the xfrm_dst is freed in __xfrm4_bundle_create
after a failed call to xfrm_dst_lookup the xfrm pointer is not
set, and this is also expected by xfrm_dst_destroy.

Acked-by: Patrick McHardy <kaber@trash.net>

> ---
>  net/ipv4/xfrm4_policy.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: linux-2.6.21-rc1/net/ipv4/xfrm4_policy.c
> ===================================================================
> --- linux-2.6.21-rc1.orig/net/ipv4/xfrm4_policy.c
> +++ linux-2.6.21-rc1/net/ipv4/xfrm4_policy.c
> @@ -291,7 +291,7 @@ static void xfrm4_dst_destroy(struct dst
>  
>  	if (likely(xdst->u.rt.idev))
>  		in_dev_put(xdst->u.rt.idev);
> -	if (dst->xfrm->props.family == AF_INET && likely(xdst->u.rt.peer))
> +	if (dst->xfrm && dst->xfrm->props.family == AF_INET && likely(xdst->u.rt.peer))
>  		inet_putpeer(xdst->u.rt.peer);
>  	xfrm_dst_destroy(xdst);
>  }

