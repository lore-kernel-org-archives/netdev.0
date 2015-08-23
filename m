From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 4/9] net: dsa: Allow configuration of CPU & DSA
 port speeds/duplex
Date: Sun, 23 Aug 2015 23:24:04 +0200
Message-ID: <20150823212404.GD20710@lunn.ch>
References: <1440323220-20438-1-git-send-email-andrew@lunn.ch>
 <1440323220-20438-5-git-send-email-andrew@lunn.ch>
 <55DA1340.9080604@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38243 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751612AbbHWVb3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Aug 2015 17:31:29 -0400
Content-Disposition: inline
In-Reply-To: <55DA1340.9080604@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > +		port_dn = cd->port_dn[port];
> > +		if (of_phy_is_fixed_link(port_dn)) {
> > +			ret = of_phy_register_fixed_link(port_dn);
> > +			if (ret) {
> > +				netdev_err(master,
> > +					   "failed to register fixed PHY\n");
> > +				return ret;
> > +			}
> > +			phydev = of_phy_find_device(port_dn);
> > +			genphy_config_init(phydev);
> > +			genphy_read_status(phydev);
> > +			if (ds->drv->adjust_link)
> > +				ds->drv->adjust_link(ds, port, phydev);
> 
> This kind of hack here because what you really need is just the link
> parameters, but you cannot obtain such information without first
> configuring the PHY up to a certain point in genphy_config_init(), and
> then have genphy_read_status() copy these values in your phydev structure.
> 
> Maybe we should really consider something like this after all:
> 
> https://lkml.org/lkml/2015/8/5/490

Hi Florian

This half solves the problem. The nice thing about using the
fixed_link, is that i can just call the adjust_link function with it.
The fixed_phy_status cannot be passed directly to adjust_link. Some
code refactoring or duplication would be needed.
 
> Or maybe, we should really introduce this "cpu" network device after all
> with a dropping xmit function, such that we get ethtool counters to work
> on it, and we can also attach it to a PHY device to configure link
> parameters?

I keep humming and harring about this. I don't really like the idea of
having an interface which you cannot send/receive packets. Yet it
solves a number of problems like this, and gives you access to
statistics and registers in the usual way. If we do it for the CPU
port, we should also do it for the DSA ports. And we probably want the
call for up to return -ENOSUP, just to make it clear it cannot be used
for anything.

      Andrew
