From: Wade Farnsworth <wfarnsworth@mvista.com>
Subject: Re: [PATCH] emac: add bamboo support
Date: 28 Jul 2005 10:25:07 -0700
Message-ID: <1122571506.22059.146.camel@rhino.az.mvista.com>
References: <20050727104247.C1114@cox.net>
	 <20050728065943.GA16041@gate.ebshome.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Matt Porter <mporter@kernel.crashing.org>, jgarzik@pobox.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Eugene Surovegin <ebs@ebshome.net>
In-Reply-To: <20050728065943.GA16041@gate.ebshome.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-07-27 at 23:59, Eugene Surovegin wrote:
> On Wed, Jul 27, 2005 at 10:42:47AM -0700, Matt Porter wrote:
> > Adds support for the Bamboo board phys in the EMAC driver.
> > Please apply.
> > 
> > Signed-off-by: Wade Farnsworth <wfarnsworth@mvista.com>
> > Signed-off-by: Matt Porter <mporter@kernel.crashing.org>
> > 
> 
> [snip]
> 
> > +#ifdef CONFIG_BAMBOO
> > +static int ac104_init(struct mii_phy *phy)
> > +{
> > +	/*
> > +	 * SW2 on the Bamboo is used for ethernet configuration and is accessed
> > +	 * via the CONFIG2 register in the FPGA.  If the ANEG pin is set,
> > +	 * overwrite the supported features with the settings in SW2.
> > +	 */
> 
> I wonder, how this SW2 works. Is it just a way to tell software not to 
> use autoneg and force some settings, or it disables autoneg on hw 
> level (I'm kinda doubt that)?

Yes, SW2 is completely ignored by the PHY.

> 
> If this is just some board specific configuration option which doesn't 
> affect this PHY directly, let's drop this stuff completely and always 
> use autoneg, if user wants to force something - he should ethtool.

I guess my comment does not explain the real reason for this function. 
The Rev. 0 Bamboo has improperly biased RJ45 sockets.  This causes the
PHY to only work at 10 Mbps.  One can remove the inductors L17 and L18
from the board to enable 100Mbps, but this also disables 10Mbps. 
Attempting to bring up ethernet in one of the unavailable speeds causes
ethernet to hang until the board is reset.  AMCC has no plans to replace
the Rev. 0, so there are users that will need some reliable way to
determine which speed is available and select that speed at boot.

A previous version of the patch did this by attempting to determine the
board rev.  If a rev 0 was found, then keep the speed determined by the
firmware, since we know that works.  Rev 1's would be allowed to use
both speeds.  The board rev was determined by reading the cpu rev from
the PVR.  This assumes that all rev 0 boards have rev A cpu's and rev 1
boards have rev B cpu's.  I believe you had some reservations about this
method.

PIBS uses a similar method to what this patch does.  In order to
tftpboot using a 10Mbps-enabled rev. 0 the ANEG pin and the Force
100Mbps pin must be disabled.  Similarly, the patch will read those same
pins and only allow the speed selected.  Additionally, the patch reads
the Duplex pin and determines which duplex mode is available.  The
duplex has no bearing on the above bug, so this can be safely removed. 
However, since we're already determining phy speed using SW2, I think
users would expect us to determine the duplex mode in the same manner.

I realize that this departs from what the other boards/phys do in this
driver, but we do need some way for the appropriate speed to be selected
on the rev. 0 boards.  If you know of a better way of doing this please
let me know.

-Wade Farnsworth
