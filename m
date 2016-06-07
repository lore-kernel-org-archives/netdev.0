From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 2/5] net: dsa: Initialize
 ds->enabled_port_mask and ds->phys_mii_mask
Date: Tue, 7 Jun 2016 15:05:47 +0200
Message-ID: <20160607130547.GA20617@lunn.ch>
References: <1465254895-11152-1-git-send-email-f.fainelli@gmail.com>
 <1465254895-11152-3-git-send-email-f.fainelli@gmail.com>
 <20160607002212.GO12165@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemlof.net,
	vivien.didelot@savoirfairelinux.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:33128 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754803AbcFGNFt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2016 09:05:49 -0400
Content-Disposition: inline
In-Reply-To: <20160607002212.GO12165@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 07, 2016 at 02:22:12AM +0200, Andrew Lunn wrote:
> > @@ -304,6 +312,18 @@ static int dsa_ds_apply(struct dsa_switch_tree *dst, struct dsa_switch *ds)
> >  	if (err < 0)
> >  		return err;
> >  
> > +	if (!ds->slave_mii_bus && ds->drv->phy_read) {
> > +		ds->slave_mii_bus = devm_mdiobus_alloc(ds->dev);
> > +		if (!ds->slave_mii_bus)
> > +			return err;
> > +
> > +		dsa_slave_mii_bus_init(ds);
> > +
> > +		err = mdiobus_register(ds->slave_mii_bus);
> > +		if (err < 0)
> > +			return err;
> > +	}
> > +
> >  	for (index = 0; index < DSA_MAX_PORTS; index++) {
> >  		port = ds->ports[index].dn;
> >  		if (!port)
> 
> Hi Florian

...
 
> It is also missing the unregister in dsa_ds_unapply().

Looking at this again...

You use devm_mdiobus_alloc(), so the memory for the bus will get freed
eventually. However, it won't get unregistered before it is freed.  So
an explicit unregister is needed. Doing that in dsa_ds_unapply() makes
sense, so we have a clear life cycle for this mdio bus.

       Andrew
