From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next v2 1/5] xen-netback: add IPv6 checksum offload
 to guest
Date: Tue, 8 Oct 2013 14:10:00 +0100
Message-ID: <20131008131000.GH28411@zion.uk.xensource.com>
References: <1381229896-18657-1-git-send-email-paul.durrant@citrix.com>
 <1381229896-18657-2-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:54510 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752191Ab3JHNKD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Oct 2013 09:10:03 -0400
Content-Disposition: inline
In-Reply-To: <1381229896-18657-2-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 08, 2013 at 11:58:12AM +0100, Paul Durrant wrote:
> Check xenstore flag feature-ipv6-csum-offload to determine if a
> guest is happy to accept IPv6 packets with only partial checksum.
> Also check analogous feature-ip-csum-offload to determone if a

determone -> determine

> guest is happy to accept IPv4 packets with only partial checksum
> as a replacement for a negated feature-no-csum-offload value and
> add a comment to deprecate use of feature-no-csum-offload.
> 
[...]
> @@ -306,7 +308,7 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
>  	vif->domid  = domid;
>  	vif->handle = handle;
>  	vif->can_sg = 1;
> -	vif->csum = 1;
> +	vif->ip_csum = 1;

Not setting a default value for vif->ipv6_csum?

>  	vif->dev = dev;
>  
[...]
> +	/* Before feature-ipv6-csum-offload was introduced, checksum offload
> +	 * was turned on by a zero value in (or lack of)
> +	 * feature-no-csum-offload. Therefore, for compatibility, assume
> +	 * that if feature-ip-csum-offload is missing that IP (v4) offload
> +	 * is turned on. If this is not the case then the flag will be
> +	 * cleared when we subsequently sample feature-no-csum-offload.
> +	 */
> +	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-ip-csum-offload",
> +			 "%d", &val) < 0)
> +		val = 1;
> +	vif->ip_csum = !!val;
> +
> +	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-ipv6-csum-offload",
> +			 "%d", &val) < 0)
> +		val = 0;
> +	vif->ipv6_csum = !!val;
> +
> +	/* This is deprecated. Frontends should set IP v4 and v6 checksum
> +	 * offload using feature-ip-csum-offload and
> +	 * feature-ipv6-csum-offload respectively.
> +	 */

These comments on feature flags should also be synchronized to master
netif.h in Xen and Linux's header. We've been trying to document thing
along the way for quite some time and the long term benifit is big.

>  	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-no-csum-offload",
>  			 "%d", &val) < 0)
>  		val = 0;
> -	vif->csum = !val;
> +	if (val)
> +		vif->ip_csum = 0;

Do you also need to set vif->ipv6_csum to 0? I don't think a frontend
which cannot deal with V4 csum offload has the ability to deal with V6
csum offload.

Wei.
