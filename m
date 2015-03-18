From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] of_net: factor out repetitive code from of_get_mac_address()
Date: Wed, 18 Mar 2015 12:46:34 -0700
Message-ID: <5509D61A.4080009@gmail.com>
References: <1776166.J84mUn2Yu8@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
	grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1776166.J84mUn2Yu8-gHKXc3Y1Z8zGSmamagVegGFoWSdPRAKMAL8bYrjMMd8@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 18/03/15 12:25, Sergei Shtylyov wrote:
> of_get_mac_address() basically does the same  thing thrice, every  time with  a
> different  property  name,  so it makes sense to factor out the repetitive code
> into separate function. While at it, we can start using ETH_ALEN instead of the
> bare number and drop unnecessary parens around the property length check.
> 
> The resulting ARM object file is 100 bytes less in size than before the patch.
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>

Acked-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

> 
> ---
> The patch is against Grant Likely's 'linux.git' repo's 'devicetree/next' branch.
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


-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
