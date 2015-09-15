From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm: Add oif to dst lookups
Date: Tue, 15 Sep 2015 11:28:38 +0200
Message-ID: <20150915092838.GK25499@secunet.com>
References: <1439247491-80410-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <herbert@gondor.apana.org.au>,
	<davem@davemloft.net>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53034 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754852AbbIOJ2m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Sep 2015 05:28:42 -0400
Content-Disposition: inline
In-Reply-To: <1439247491-80410-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 10, 2015 at 04:58:11PM -0600, David Ahern wrote:
> Rules can be installed that direct route lookups to specific tables based
> on oif. Plumb the oif through the xfrm lookups so it gets set in the flow
> struct and passed to the resolver routines.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

David, this change broke vti tunnels.

> @@ -1690,8 +1694,8 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
>  
>  		if (xfrm[i]->props.mode != XFRM_MODE_TRANSPORT) {
>  			family = xfrm[i]->props.family;
> -			dst = xfrm_dst_lookup(xfrm[i], tos, &saddr, &daddr,
> -					      family);
> +			dst = xfrm_dst_lookup(xfrm[i], tos, fl->flowi_oif,
> +					      &saddr, &daddr, family);

Passing the original output interface to xfrm_dst_lookup will generate
a routing loop whenever the original output interface is not identical
to the tunnel endpoint, like it is with vti. We can not ask for a route
through a specific interface here. This is the lookup for the tunnel
endpoints, so it must return a route through the local tunnel endpoint
device.

I don't know how you are going to use this with your vrf changes, so
I'm not sure how to fix this in a way that it works with vrf. Please
look into this.
