From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net-next v4 1/5] xen-netback: add support for IPv6
 checksum offload to guest
Date: Mon, 14 Oct 2013 11:53:33 +0100
Message-ID: <1381748013.24708.102.camel@kazak.uk.xensource.com>
References: <1381503982-1418-1-git-send-email-paul.durrant@citrix.com>
	 <1381503982-1418-2-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:28213 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754097Ab3JNKzT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Oct 2013 06:55:19 -0400
In-Reply-To: <1381503982-1418-2-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-10-11 at 16:06 +0100, Paul Durrant wrote:
> Check xenstore flag feature-ipv6-csum-offload to determine if a
> guest is happy to accept IPv6 packets with only partial checksum.
> Also check analogous feature-ip-csum-offload to determine if a
> guest is happy to accept IPv4 packets with only partial checksum
> as a replacement for a negated feature-no-csum-offload value and
> add a comment to deprecate use of feature-no-csum-offload.
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>
> Cc: David Vrabel <david.vrabel@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>

Shouldn't this come later in the series, i.e. after netback is actually
able to cope with ipv6 offloads?

> diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
> index 5715318..b4a9a3c 100644
> --- a/drivers/net/xen-netback/common.h
> +++ b/drivers/net/xen-netback/common.h
> @@ -153,7 +153,8 @@ struct xenvif {
>  	u8 can_sg:1;
>  	u8 gso:1;
>  	u8 gso_prefix:1;
> -	u8 csum:1;
> +	u8 ip_csum:1;
> +	u8 ipv6_csum:1;

Why not ipv4_csum for consistency/unambiguity?

> diff --git a/include/xen/interface/io/netif.h b/include/xen/interface/io/netif.h
> index eb262e3..d9fb44739 100644
> --- a/include/xen/interface/io/netif.h
> +++ b/include/xen/interface/io/netif.h
> @@ -51,6 +51,16 @@
>   */
>  
>  /*
> + * "feature-no-csum-offload" was used to turn off IPv4 TCP/UDP checksum
> + * offload but is now deprecated. Two new feature flags should now be used
> + * to control checksum offload:

How is a frontend to know which sort of backend it is talking too? Is
there going to be a feature flag to indicate support for these new
flags?

In particular a new frontend running on an old backend needs to know
that it needs to set no-csum-offload instead of ip-csum-offload somehow.

> + * "feature-ip-csum-offload" should be used to turn IPv4 TCP/UDP checksum

"ipv4" again?

> + * offload on or off. If it is missing then the feature is assumed to be on.
> + * "feature-ipv6-csum-offload" should be used to turn IPv6 TCP/UDP checksum
> + * offload on or off. If it is missing then the feature is assumed to be off.
> + */
> +
> +/*
>   * This is the 'wire' format for packets:
>   *  Request 1: xen_netif_tx_request  -- XEN_NETTXF_* (any flags)
>   * [Request 2: xen_netif_extra_info]    (only if request 1 has XEN_NETTXF_extra_info)
