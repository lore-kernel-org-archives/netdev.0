From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 1/2] net: dsa: integrate with SWITCHDEV for HW
 bridging
Date: Wed, 18 Feb 2015 02:19:55 +0100
Message-ID: <20150218011955.GA17155@lunn.ch>
References: <1424201196-4901-1-git-send-email-f.fainelli@gmail.com>
 <1424201196-4901-2-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	cphealy@gmail.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45356 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751701AbbBRBWp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Feb 2015 20:22:45 -0500
Content-Disposition: inline
In-Reply-To: <1424201196-4901-2-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +/* Return a bitmask of all ports being currently bridged. Note that on
> + * leave, the mask will still return the bitmask of ports currently bridged,
> + * prior to port removal, and this is exactly what we want.
> + */
> +static u32 dsa_slave_br_port_mask(struct dsa_switch *ds)
> +{
> +	unsigned int port;
> +	u32 mask = 0;
> +
> +	for (port = 0; port < DSA_MAX_PORTS; port++) {
> +		if (!((1 << port) & ds->phys_port_mask))
> +			continue;
> +
> +		if (ds->ports[port]->priv_flags & IFF_BRIDGE_PORT)
> +			mask |= 1 << port;
> +	}
> +
> +       return mask;
> +}
> +
> +static int dsa_slave_bridge_port_join(struct net_device *dev,
> +				      struct net_device *bridge)
> +{
> +	struct dsa_slave_priv *p = netdev_priv(dev);
> +	struct dsa_switch *ds = p->parent;
> +	int ret = -EOPNOTSUPP;
> +
> +	if (ds->drv->port_join_bridge)
> +		ret = ds->drv->port_join_bridge(ds, p->port,
> +						dsa_slave_br_port_mask(ds));

Hi Florian

Shouldn't this bridge port mask also be dependent on bridge?

I'm thinking of cases like

brctl addbr br0
brctl addif br0 lan0
brctl addif br0 lan1

brctl addbr br1
brctl addif br1 lan2
brctl addif br1 lan3

We have two software bridges, so need two masks.  It does look like
your hardware and the Marvell hardware supports this, disjoint sets of
bridged ports.  But with the current implementation, your going to end
up with one hardware bridge with four ports, and broken STP.

       Andrew
