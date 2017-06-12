From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH v3 7/9] net: mvmdio: add xmdio xsmi support
Date: Mon, 12 Jun 2017 11:07:56 +0100
Message-ID: <20170612100756.GZ4902@n2100.armlinux.org.uk>
References: <20170612095745.11300-1-antoine.tenart@free-electrons.com>
 <20170612095745.11300-8-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com, f.fainelli@gmail.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        mw@semihalf.com, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:36588 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752129AbdFLKIU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2017 06:08:20 -0400
Content-Disposition: inline
In-Reply-To: <20170612095745.11300-8-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 12, 2017 at 11:57:43AM +0200, Antoine Tenart wrote:
> +static void orion_mdio_xsmi_start_read_op(struct orion_mdio_dev *dev,
> +					  int mii_id, int regnum)
> +{
> +	u16 dev_addr = (regnum >> 16) & GENMASK(4, 0);
> +
> +	writel(regnum & GENMASK(15, 0), dev->regs + MVMDIO_XSMI_ADDR_REG);
> +	writel((mii_id << MVMDIO_XSMI_PHYADDR_SHIFT) |
> +	       (dev_addr << MVMDIO_XSMI_DEVADDR_SHIFT) |
> +	       MVMDIO_XSMI_READ_OPERATION,
> +	       dev->regs + MVMDIO_XSMI_MGNT_REG);

So what happens if this function gets passed a Clause 22 formatted
request?  Both regnum and mii_id are in the range 0-31.  MII_ADDR_C45
in regnum is clear.

The answer is we produce two Clause 45 frames on the bus, which is
certainly not correct.  You need to trap and error out if MII_ADDR_C45
is not set (as I've already said previously.)

The SMI operations need to do the reverse - they need to fail if they
receive a regnum with MII_ADDR_C45 set, as they are unable to produce
Clause 45 frames.

> +static void orion_mdio_xsmi_write_op(struct orion_mdio_dev *dev, int mii_id,
> +				     int regnum, u16 value)
> +{
> +	u16 dev_addr = (regnum >> 16) & GENMASK(4, 0);
> +
> +	writel(regnum & GENMASK(15, 0), dev->regs + MVMDIO_XSMI_ADDR_REG);
> +	writel((mii_id << MVMDIO_XSMI_PHYADDR_SHIFT) |
> +	       (dev_addr << MVMDIO_XSMI_DEVADDR_SHIFT) |
> +	       MVMDIO_XSMI_WRITE_OPERATION | value,
> +	       dev->regs + MVMDIO_XSMI_MGNT_REG);

It's even more important here, as a Clause 22 write will produce a
valid Clause 45 pair of frames with dev_addr = 0.

Again, the corresponding SMI code needs to reject Clause 45 requests
as the SMI interface is unable to produce Clause 45 frames.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
