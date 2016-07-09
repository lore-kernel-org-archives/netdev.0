From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net] ipv4: reject RTNH_F_LINKDOWN for incompatible routes
Date: Sat, 9 Jul 2016 13:23:28 -0400
Message-ID: <20160709172327.GP18787@gospo.rdu.cumulusnetworks.com>
References: <1468054815-24766-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Vegard Nossum <vegard.nossum@oracle.com>,
	Dinesh Dutt <ddutt@cumulusnetworks.com>,
	Scott Feldman <sfeldma@gmail.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f179.google.com ([209.85.161.179]:34431 "EHLO
	mail-yw0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751897AbcGIRXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jul 2016 13:23:32 -0400
Received: by mail-yw0-f179.google.com with SMTP id i12so61036721ywa.1
        for <netdev@vger.kernel.org>; Sat, 09 Jul 2016 10:23:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1468054815-24766-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 09, 2016 at 12:00:15PM +0300, Julian Anastasov wrote:
> Vegard Nossum is reporting for a crash in fib_dump_info (fib_nhs==1)
> when nh_dev = NULL. Problem happens when RTNH_F_LINKDOWN is
> provided from user space for routes that do not use the flag,
> catched with netlink fuzzer.

Can you also include the panic log in the changelog or at a minimum post
it here?

> RTNH_F_LINKDOWN should be used only for link routes, not for
> local routes or for routes with error code. Do not complicate
> fast path with more checks, reject the flag early when configured
> for incompatible routes.

Did the netlink fuzzer (trinity?) happen to check any of the other flags
(liks RTNH_F_DEAD) that are normally set by the kernel but could be
problematic when send down from userspace?

> Reported-by: Vegard Nossum <vegard.nossum@oracle.com>
> Fixes: 0eeb075fad73 ("net: ipv4 sysctl option to ignore routes when nexthop link is down")
> Tested-by: Vegard Nossum <vegard.nossum@oracle.com>
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> Cc: Andy Gospodarek <gospo@cumulusnetworks.com>
> Cc: Dinesh Dutt <ddutt@cumulusnetworks.com>
> Cc: Scott Feldman <sfeldma@gmail.com>
> ---
>  net/ipv4/fib_semantics.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> Note: works for all kernels: net, net-next, 4.4.14, 4.5.7, 4.6.3
> 
> diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
> index d09173b..b642479 100644
> --- a/net/ipv4/fib_semantics.c
> +++ b/net/ipv4/fib_semantics.c
> @@ -1113,7 +1113,8 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
>  	}
>  
>  	if (fib_props[cfg->fc_type].error) {
> -		if (cfg->fc_gw || cfg->fc_oif || cfg->fc_mp)
> +		if (cfg->fc_gw || cfg->fc_oif || cfg->fc_mp ||
> +		    (fi->fib_nh->nh_flags & RTNH_F_LINKDOWN))
>  			goto err_inval;

It looks a bit odd to use cfg in the existing checkd and fi->fib_nh in
the rest, but not a huge issue since cfg->fc_flags and
fi->fib_nh->nh_flags should be equivalent should be the same for single
and multipath routes.

>  		goto link_it;
>  	} else {
> @@ -1136,7 +1137,7 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
>  		struct fib_nh *nh = fi->fib_nh;
>  
>  		/* Local address is added. */
> -		if (nhs != 1 || nh->nh_gw)
> +		if (nhs != 1 || nh->nh_gw || (nh->nh_flags & RTNH_F_LINKDOWN))
>  			goto err_inval;
>  		nh->nh_scope = RT_SCOPE_NOWHERE;
>  		nh->nh_dev = dev_get_by_index(net, fi->fib_nh->nh_oif);
> -- 
> 1.9.3
> 
