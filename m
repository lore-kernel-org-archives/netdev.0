From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 4/9] net: dsa: Initialize ds->enabled_port_mask
 and ds->phys_mii_mask
Date: Sat, 4 Jun 2016 22:29:59 +0200
Message-ID: <20160604202959.GF2063@lunn.ch>
References: <1464998733-10405-1-git-send-email-f.fainelli@gmail.com>
 <1464998733-10405-7-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com, john@phrozen.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59637 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750787AbcFDUaE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Jun 2016 16:30:04 -0400
Content-Disposition: inline
In-Reply-To: <1464998733-10405-7-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> @@ -517,6 +541,15 @@ static int dsa_parse_ports_dn(struct device_node *ports, struct dsa_switch *ds)
>  			return -EINVAL;
>  
>  		ds->ports[reg].dn = port;
> +
> +		if (dsa_port_is_cpu(port))
> +			ds->dst->cpu_port = reg;
> +		else
> +			/* Initialize enabled_port_mask now for drv->setup()
> +			 * to have access to a correct value, just like what
> +			 * net/dsa/dsa.c::dsa_switch_setup_one does.
> +			 */
> +			ds->enabled_port_mask |= 1 << reg;

Hi Florian

You need to be careful here. There can be multiple CPU ports, in
different switches. We want dst->cpu_port to be deterministic,
independent of the order switches are registered. Which is why i set
it as part of dsa_cpu_parse(), which only happens when all the
switches have registered, and we are parsing their device tree nodes
in order. So we guarantee dst->cpu_port is the first CPU node.

You now set dst->cpu_port via dsa_parse_ports_dn(), so it is now non
deterministic, it depends on the probe order of the switches.

In the long run, i want to deprecate and then remove dst->cpu_port,
but i'm not that far yet.

Please rethink this part of the patch, keeping in mind you have
multiple switches, with multiple CPU and DSA ports, all connected in
some crazy fashion.

       Andrew
