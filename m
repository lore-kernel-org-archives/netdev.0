From: Grant Likely <grant.likely@linaro.org>
Subject: Re: [PATCH] of_net: factor out repetitive code from
 of_get_mac_address()
Date: Sat, 28 Mar 2015 13:34:45 +0000
Message-ID: <20150328133445.52B51C40AAB@trevor.secretlab.ca>
References: <1776166.J84mUn2Yu8@wasted.cogentembedded.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	robh+dt@kernel.org, devicetree@vger.kernel.org,
	f.fainelli@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:35365 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753340AbbC1OvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Mar 2015 10:51:07 -0400
Received: by wgdm6 with SMTP id m6so127432776wgd.2
        for <netdev@vger.kernel.org>; Sat, 28 Mar 2015 07:51:06 -0700 (PDT)
In-Reply-To: <1776166.J84mUn2Yu8@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 18 Mar 2015 22:25:46 +0300
, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
 wrote:
> of_get_mac_address() basically does the same  thing thrice, every  time with  a
> different  property  name,  so it makes sense to factor out the repetitive code
> into separate function. While at it, we can start using ETH_ALEN instead of the
> bare number and drop unnecessary parens around the property length check.
> 
> The resulting ARM object file is 100 bytes less in size than before the patch.
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> 
> ---
> The patch is against Grant Likely's 'linux.git' repo's 'devicetree/next' branch.

Thanks for looking at this, I've merged it.

Since you're already playing with this, could you also write a unittest
of of_get_mac_addr()? (drivers/of/unittest.c & drivers/of/unittest-data)

g.

> 
>  drivers/of/of_net.c |   29 +++++++++++++++++------------
>  1 file changed, 17 insertions(+), 12 deletions(-)
> 
> Index: linux/drivers/of/of_net.c
> ===================================================================
> --- linux.orig/drivers/of/of_net.c
> +++ linux/drivers/of/of_net.c
> @@ -38,6 +38,15 @@ int of_get_phy_mode(struct device_node *
>  }
>  EXPORT_SYMBOL_GPL(of_get_phy_mode);
>  
> +static const void *of_get_mac_addr(struct device_node *np, const char *name)
> +{
> +	struct property *pp = of_find_property(np, name, NULL);
> +
> +	if (pp && pp->length == ETH_ALEN && is_valid_ether_addr(pp->value))
> +		return pp->value;
> +	return NULL;
> +}
> +
>  /**
>   * Search the device tree for the best MAC address to use.  'mac-address' is
>   * checked first, because that is supposed to contain to "most recent" MAC
> @@ -58,20 +67,16 @@ EXPORT_SYMBOL_GPL(of_get_phy_mode);
>  */
>  const void *of_get_mac_address(struct device_node *np)
>  {
> -	struct property *pp;
> +	const void *addr;
>  
> -	pp = of_find_property(np, "mac-address", NULL);
> -	if (pp && (pp->length == 6) && is_valid_ether_addr(pp->value))
> -		return pp->value;
> +	addr = of_get_mac_addr(np, "mac-address");
> +	if (addr)
> +		return addr;
>  
> -	pp = of_find_property(np, "local-mac-address", NULL);
> -	if (pp && (pp->length == 6) && is_valid_ether_addr(pp->value))
> -		return pp->value;
> +	addr = of_get_mac_addr(np, "local-mac-address");
> +	if (addr)
> +		return addr;
>  
> -	pp = of_find_property(np, "address", NULL);
> -	if (pp && (pp->length == 6) && is_valid_ether_addr(pp->value))
> -		return pp->value;
> -
> -	return NULL;
> +	return of_get_mac_addr(np, "address");
>  }
>  EXPORT_SYMBOL(of_get_mac_address);
> 
