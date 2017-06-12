From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH v3 7/9] net: mvmdio: add xmdio xsmi support
Date: Mon, 12 Jun 2017 11:41:26 +0100
Message-ID: <20170612104126.GB4902@n2100.armlinux.org.uk>
References: <20170612095745.11300-1-antoine.tenart@free-electrons.com>
 <20170612095745.11300-8-antoine.tenart@free-electrons.com>
 <20170612101739.GA4902@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: thomas.petazzoni@free-electrons.com, andrew@lunn.ch,
        f.fainelli@gmail.com, jason@lakedaemon.net, netdev@vger.kernel.org,
        nadavh@marvell.com, gregory.clement@free-electrons.com,
        mw@semihalf.com, davem@davemloft.net,
        linux-arm-kernel@lists.infradead.org,
        sebastian.hesselbarth@gmail.com
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:37042 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751604AbdFLKlm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2017 06:41:42 -0400
Content-Disposition: inline
In-Reply-To: <20170612101739.GA4902@n2100.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 12, 2017 at 11:17:39AM +0100, Russell King - ARM Linux wrote:
> On Mon, Jun 12, 2017 at 11:57:43AM +0200, Antoine Tenart wrote:
> > +static const struct orion_mdio_ops *orion_mdio_get_ops(struct orion_mdio_dev *dev,
> > +						       int regnum)
> > +{
> > +	if (dev->bus_type == BUS_TYPE_XSMI && (regnum & MII_ADDR_C45))
> > +		return &orion_mdio_xsmi_ops;
> > +	else if (dev->bus_type == BUS_TYPE_SMI)
> > +		return &orion_mdio_smi_ops;
> > +
> > +	return ERR_PTR(-EOPNOTSUPP);
> > +}
> 
> Oh, this is where you're doing it - I'm not sure having this complexity
> is really necessary - there is no dynamic choice between the two.  This
> seems to be way over-engineered.
> 
> You might as well make the SMI operations fail if MII_ADDR_C45 is set,
> and the XSMI operations fail if MII_ADDR_C45 is not set.
> 
> Hmm, I think this whole driver is over-engineered:
> 
> 1. the mdio read/write functions implement their own locking.
> 
>    At the MDIO level, there is already locking in the form of a per-bus
>    lock "bus->mdio_lock" which will be taken whenever either of these
>    functions is called.  So the driver's "dev->lock" is redundant.
> 
> 2. with the redundant locking removed, orion_mdio_write() becomes a
>    call to orion_mdio_wait_ready() followed by a call to dev->ops->write.
>    It seems that orion_mdio_wait_ready() could be a library function
>    shared between a SMI version of orion_mdio_write() and a XSMI version.
> 
> 3. the same is really true of orion_mdio_read(), although that function
>    is a little more complex in itself, the result would actually end up
>    being simpler.
> 
> With those changes together, it elimates "struct orion_mdio_ops" entirely,
> and I think makes the driver smaller, simpler, and cleaner.

I wasn't able to completely get rid of the ops structure, but I think
this is cleaner.  I haven't tested these two patches yet.

 drivers/net/ethernet/marvell/mvmdio.c | 276 +++++++++++++++-------------------
 1 file changed, 123 insertions(+), 153 deletions(-)

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
