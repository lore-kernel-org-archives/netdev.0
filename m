From: John Linn <John.Linn@xilinx.com>
Subject: RE: [PATCH] net: emaclite: adding MDIO and phy lib support
Date: Fri, 5 Feb 2010 11:50:08 -0700
Message-ID: <a3cfa41e-7220-460d-8fce-96db4752ab08@SG2EHSMHS012.ehs.local>
References: <1265244560-23593-1-git-send-email-john.linn@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <john.williams@petalogix.com>,
	"Sadanand Mutyala" <sadanan@xilinx.com>
To: "John Linn" <john.linn@xilinx.com>, <netdev@vger.kernel.org>,
	<linuxppc-dev@ozlabs.org>, <jgarzik@pobox.com>,
	<grant.likely@secretlab.ca>, <jwboyer@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sg2ehsobe002.messaging.microsoft.com ([207.46.51.76]:18500 "EHLO
	SG2EHSOBE002.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S933806Ab0BETF3 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Feb 2010 14:05:29 -0500
Content-Class: urn:content-classes:message
In-Reply-To: <1265244560-23593-1-git-send-email-john.linn@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Grant Likely
> Sent: Thurs, 4 Feb 2010 11:12:29 AM
> To: John Linn
> Subject: FW: [PATCH] net: emaclite: adding MDIO and phy lib support
> 
> Hi John and Sadanand.  Looks like a good patch, but a few issues to
> resolve.  Comments below.
> 
> g.

Somehow I didn't get this message but found it out on the web, so this
is a contrived version of the message so I could respond :)

> 
> On Wed, Feb 3, 2010 at 5:49 PM, John Linn <john.linn@xxxxxxxxxx>
wrote:
> > These changes add MDIO and phy lib support to the driver as the
> > IP core now supports the MDIO bus.
> >
> > The MDIO bus and phy are added as a child to the emaclite in the
device
> > tree as illustrated below.
> >
> > mdio {
> >        #address-cells = <1>;
> >        #size-cells = <0>;
> >        phy0: phy@7 {
> >                reg = <7>;
> 
> For completeness, phy node need a "compatible" property.

It seems like this is in the device tree only but the driver won't use
it. So no real affect on the driver unless I'm not synced up with you.

> 
> >        } ;
> > }
> >
> > Signed-off-by: Sadanand Mutyala <Sadanand.Mutyala@xxxxxxxxxx>
> > Signed-off-by: John Linn <john.linn@xxxxxxxxxx>
> > ---
> >  drivers/net/Kconfig           |    1 +
> >  drivers/net/xilinx_emaclite.c |  362
++++++++++++++++++++++++++++++++++++-----
> >  2 files changed, 319 insertions(+), 44 deletions(-)
> >
> > diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> > index 396fd38..2056cd2 100644
> > --- a/drivers/net/Kconfig
> > +++ b/drivers/net/Kconfig
> > @@ -1947,6 +1947,7 @@ config ATL2
> >  config XILINX_EMACLITE
> >        tristate "Xilinx 10/100 Ethernet Lite support"
> >        depends on PPC32 || MICROBLAZE
> > +       select PHYLIB
> >        help
> >          This driver supports the 10/100 Ethernet Lite from Xilinx.
> >
> 
> Patch appears to be whitespace damaged.  All tabs have been converted
to spaces.

Ok, will look at this.

<snip>

> > +static int xemaclite_mdio_read(struct mii_bus *bus, int phy_id, int
reg)
> > +{
> > +       struct net_local *lp = bus->priv;
> > +       u32 ctrl_reg;
> > +       u32 rc;
> > +
> > +       /* Wait till the device is ready */
> > +       do {
> > +               ctrl_reg = in_be32(lp->base_addr +
XEL_MDIOCTRL_OFFSET);
> > +       } while (ctrl_reg & XEL_MDIOCTRL_MDIOSTS_MASK);
> 
> This is a busywait loop that just burns cycles while waiting for the
> MDIO bus to become non-busy, and further down...

Yep agreed.

> 
> > +
> > +       /* Write the PHY address, register number and set the OP bit
in the
> > +        * MDIO Address register. Set the Status bit in the MDIO
Control
> > +        * register to start a MDIO read transaction.
> > +        */
> > +       out_be32(lp->base_addr + XEL_MDIOADDR_OFFSET,
> > +                XEL_MDIOADDR_OP_MASK |
> > +                ((phy_id << XEL_MDIOADDR_PHYADR_SHIFT) | reg));
> > +       out_be32(lp->base_addr + XEL_MDIOCTRL_OFFSET,
> > +                ctrl_reg | XEL_MDIOCTRL_MDIOSTS_MASK);
> > +
> > +       /* Wait for the device to complete the transaction and read
the value
> > +        * from MDIO Read Data register.
> > +        */
> > +       do {
> > +               ctrl_reg = in_be32(lp->base_addr +
XEL_MDIOCTRL_OFFSET);
> > +       } while (ctrl_reg & XEL_MDIOCTRL_MDIOSTS_MASK);
> 
> ... I see the same thing waiting for the issued transaction to
> complete.  Busywaiting on slow events, like MDIO transfers, wastes a
> lot of cycles that could be used for running other threads.
> 
> At the very least, the wait loop should msleep() so that other threads
> get scheduled.  Even better is if a completion is used and the MDIO
> irq can be used to wake up the thread.
> 
> Another problem with this busywait is that is has no failure path if
> the MDIO bus hangs up.  The thread could get stuck spinning on this
> loop forever with no way to kill it.
> 

Agree, will fix all these, probably not use an interrupt.

<snip>

> >  * Return:     0, if the driver is bound to the Emaclite device, or
> >  *             a negative error if there is failure.
> > @@ -853,7 +1104,6 @@ static int __devinit xemaclite_of_probe(struct
of_device *ofdev,
> >        struct net_local *lp = NULL;
> >        struct device *dev = &ofdev->dev;
> >        const void *mac_address;
> > -
> 
> Unrelated whitespace change.

Yep.

> 
> >        int rc = 0;
> >
> >        dev_info(dev, "Device Tree Probing\n");
> > @@ -880,6 +1130,7 @@ static int __devinit xemaclite_of_probe(struct
of_device *ofdev,
> >        }
> >
> >        dev_set_drvdata(dev, ndev);
> > +       SET_NETDEV_DEV(ndev, &ofdev->dev);
> >
> >        ndev->irq = r_irq.start;
> >        ndev->mem_start = r_mem.start;
> > @@ -923,7 +1174,16 @@ static int __devinit xemaclite_of_probe(struct
of_device *ofdev,
> >        out_be32(lp->base_addr + XEL_BUFFER_OFFSET + XEL_TSR_OFFSET,
0);
> >
> >        /* Set the MAC address in the EmacLite device */
> > -       xemaclite_set_mac_address(lp, ndev->dev_addr);
> > +       xemaclite_update_address(lp, ndev->dev_addr);
> > +
> > +       /* Check if MDIO is included in the HW */
> > +       lp->has_mdio = get_bool(ofdev, "xlnx,include-mdio");
> > +       if (lp->has_mdio) {
> > +               lp->phy_node = of_parse_phandle(ofdev->node,
"phy-handle", 0);
> > +               rc = xemaclite_mdio_setup(lp, &ofdev->dev);
> > +               if (rc)
> > +                       dev_warn(&ofdev->dev, "error registering
MDIO bus\n");
> > +       }
> 
> What if the phy is attached to a different MDIO bus (which is
> completely possible)?  The fetching of phy_node should be performed
> regardless of whether or not xlnx,include-mdio is set.
> 

So the issue here is that the IP core can be built without any PHY
interface and MDIO bus.

Maybe we can still do that, I'll need to test it.  

Will get a new patch ready soon.

Thanks,
John

This email and any attachments are intended for the sole use of the named recipient(s) and contain(s) confidential information that may be proprietary, privileged or copyrighted under applicable law. If you are not the intended recipient, do not read, copy, or forward this email message or any attachments. Delete this email message and any attachments immediately.


