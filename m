From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v4 net-next] net: ipv4: Consider failed nexthops in
 multipath routes
Date: Mon, 4 Apr 2016 00:57:07 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1604040039020.1534@ja.home.ssi.bg>
References: <1459711147-18825-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:59889 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751569AbcDCV5P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Apr 2016 17:57:15 -0400
In-Reply-To: <1459711147-18825-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Sun, 3 Apr 2016, David Ahern wrote:

> --- a/Documentation/networking/ip-sysctl.txt
> +++ b/Documentation/networking/ip-sysctl.txt
> @@ -63,6 +63,16 @@ fwmark_reflect - BOOLEAN
>  	fwmark of the packet they are replying to.
>  	Default: 0
>  
> +fib_multipath_use_neigh - BOOLEAN
> +	Use status of existing neighbor entry when determining nexthop for
> +	multipath routes. If disabled neighbor information is not used and

	Comma from v3 is removed?

> +	packets could be directed to a failed nexthop. Only valid for kernels

> --- a/net/ipv4/fib_semantics.c
> +++ b/net/ipv4/fib_semantics.c
>  void fib_select_multipath(struct fib_result *res, int hash)
>  {
>  	struct fib_info *fi = res->fi;
> +	struct net *net = fi->fib_net;
> +	bool first = false;
>  
>  	for_nexthops(fi) {
>  		if (hash > atomic_read(&nh->nh_upper_bound))
>  			continue;
>  
> -		res->nh_sel = nhsel;
> -		return;
> +		if (!net->ipv4.sysctl_fib_multipath_use_neigh ||
> +		    fib_good_nh(nh)) {
> +			res->nh_sel = nhsel;
> +			return;
> +		}
> +		if (!first) {
> +			res->nh_sel = nhsel;
> +			first = true;
> +		}
>  	} endfor_nexthops(fi);
>  
>  	/* Race condition: route has just become dead. */

	The 'res->nh_sel = 0;' that is here should be
removed because it invalidates the above assignment.

Regards
