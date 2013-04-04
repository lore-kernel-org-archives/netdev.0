From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 1/2] net: ipv6: add tokenized interface identifier support
Date: Thu, 4 Apr 2013 17:58:37 +0200
Message-ID: <20130404155837.GA23056@order.stressinduktion.org>
References: <1365086258-4512-1-git-send-email-dborkman@redhat.com> <1365086258-4512-2-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:51213 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760047Ab3DDP6i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 11:58:38 -0400
Content-Disposition: inline
In-Reply-To: <1365086258-4512-2-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 04, 2013 at 04:37:37PM +0200, Daniel Borkmann wrote:
> This patch adds support for tokenized IIDs, that allow for
> administrators to assign well-known host-part addresses to
> nodes whilst still obtaining global network prefix from
> Router Advertisements. It is currently in IETF RFC draft
> status [1]:
> 
>   The primary target for such support is server platforms
>   where addresses are usually manually configured, rather
>   than using DHCPv6 or SLAAC. By using tokenised identifiers,
>   hosts can still determine their network prefix by use of
>   SLAAC, but more readily be automatically renumbered should
>   their network prefix change.
> 
>  [1] http://tools.ietf.org/html/draft-chown-6man-tokenised-ipv6-identifiers-02
> 
> The implementation is partially based on top of Mark K.
> Thompson's proof of concept. Successfully tested by myself.

Cool, this looks really useful.

One comment so far:

> +#define IPV6_ADDR_SCOPE_TYPE(scope)	((scope) << 16)
> +

I think we should not export this macro but instead...

> +	/* Well, that's kinda nasty ... */
> +	list_for_each_entry(ifp, &idev->addr_list, if_list) {
> +		spin_lock(&ifp->lock);
> +		if (__ipv6_addr_type(&ifp->addr) &
> +		    IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_GLOBAL)) {

...use

if (ipv6_addr_src_scope(&ifp->addr) == IPV6_ADDR_SCOPE_GLOBAL) {

here.

> diff --git a/net/ipv6/addrconf_core.c b/net/ipv6/addrconf_core.c
> index d051e5f..8b723de 100644
> --- a/net/ipv6/addrconf_core.c
> +++ b/net/ipv6/addrconf_core.c
> @@ -6,8 +6,6 @@
>  #include <linux/export.h>
>  #include <net/ipv6.h>
>  
> -#define IPV6_ADDR_SCOPE_TYPE(scope)	((scope) << 16)
> -

This hunk can be dropped then.

Thanks,

  Hannes
