From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [RFC PATCH 11/16] net: dsa: Refactor selection of tag ops into a function
Date: Fri, 27 May 2016 15:35:57 -0400
Message-ID: <878tyvz42q.fsf@ketchup.mtl.sfl>
References: <1464312050-23023-1-git-send-email-andrew@lunn.ch> <1464312050-23023-12-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	John Crispin <john@phrozen.org>, Bryan.Whitehead@microchip.com,
	Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:36309 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751017AbcE0TgC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2016 15:36:02 -0400
In-Reply-To: <1464312050-23023-12-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> @@ -26,6 +26,7 @@ enum dsa_tag_protocol {
>  	DSA_TAG_PROTO_TRAILER,
>  	DSA_TAG_PROTO_EDSA,
>  	DSA_TAG_PROTO_BRCM,
> +	_DSA_TAG_LAST,
>  };

I would avoid _ prefixed functions or symbols, we've seen in mv88e6xxx
that it doesn't make the code really readable.

There's already an implicit "DSA_TAG_PROTO" namespace, so I suggest
"DSA_MAX_TAGS" to keep it consistent with DSA_MAX_{PORTS,SWITCHES}.

[...]

> +	/*
> +	 * Tagging protocol operations for adding and removing an
> +	 * encapsulation tag.
> +	 */
> +	const struct dsa_device_ops *tag_ops;

dsa_device_ops seems too generic for the xmit/rcv tag-related pair. That
being said, I don't really have better suggestions. Any idea?

[...]

> +const struct dsa_device_ops *dsa_device_ops[_DSA_TAG_LAST] = {
> +#ifdef CONFIG_NET_DSA_TAG_DSA
> +	[DSA_TAG_PROTO_DSA] = &dsa_netdev_ops,
> +#endif
> +#ifdef CONFIG_NET_DSA_TAG_EDSA
> +	[DSA_TAG_PROTO_EDSA] = &edsa_netdev_ops,
> +#endif
> +#ifdef CONFIG_NET_DSA_TAG_TRAILER
> +	[DSA_TAG_PROTO_TRAILER] = &trailer_netdev_ops,
> +#endif
> +#ifdef CONFIG_NET_DSA_TAG_BRCM
> +	[DSA_TAG_PROTO_BRCM] = &brcm_netdev_ops,
> +#endif
> +	[DSA_TAG_PROTO_NONE] = &none_ops,
> +};
>  
>  /* switch driver registration ***********************************************/
>  static DEFINE_MUTEX(dsa_switch_drivers_mutex);
> @@ -225,6 +252,20 @@ static int dsa_cpu_dsa_setups(struct dsa_switch *ds, struct device *dev)
>  	return 0;
>  }
>  
> +const struct dsa_device_ops *dsa_resolve_tag_protocol(int tag_protocol)
> +{
> +	const struct dsa_device_ops *ops;
> +
> +	if (tag_protocol >= _DSA_TAG_LAST)
> +		return ERR_PTR(-EINVAL);
> +	ops = dsa_device_ops[tag_protocol];
> +
> +	if (!ops)
> +		return ERR_PTR(-ENOPROTOOPT);
> +
> +	return ops;
> +}

I don't see the need to add a dsa_device_ops array. I'd keep the switch
case on tag_protocol within this new dsa_resolve_tag_protocol function,
to make it more readable (no value checking necessary).

Thanks,

        Vivien
