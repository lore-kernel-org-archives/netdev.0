From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH] net/fec: add device tree probe support
Date: Mon, 4 Jul 2011 14:25:22 +0800
Message-ID: <20110704062521.GD10245@S2100-06.ap.freescale.net>
References: <1309680401-22904-1-git-send-email-shawn.guo@linaro.org>
	<20110703212312.GD13742@ponder.secretlab.ca>
	<20110704055021.GC10245@S2100-06.ap.freescale.net>
	<20110704055956.GD15152@ponder.secretlab.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: patches@linaro.org, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org, Jason Liu <jason.hui@linaro.org>,
	Shawn Guo <shawn.guo@linaro.org>, "David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20110704055956.GD15152@ponder.secretlab.ca>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 03, 2011 at 11:59:56PM -0600, Grant Likely wrote:
> On Mon, Jul 04, 2011 at 01:50:22PM +0800, Shawn Guo wrote:
> > On Sun, Jul 03, 2011 at 03:23:12PM -0600, Grant Likely wrote:
> > > On Sun, Jul 03, 2011 at 04:06:41PM +0800, Shawn Guo wrote:
> > > > It adds device tree probe support for fec driver.
> > > > 
> > > > Signed-off-by: Jason Liu <jason.hui@linaro.org>
> > > > Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
> > > > Cc: David S. Miller <davem@davemloft.net>
> > > > Cc: Grant Likely <grant.likely@secretlab.ca>
> > > 
> > > Minor comments below.  After addressing them you can add my:
> > > 
> > > Acked-by: Grant Likely <grant.likely@secretlab.ca>
> > > 
> > > I don't see any reason not to merge this one in v3.1
> > > 
> > > g.
> > > 
> > > > ---
> > > >  Documentation/devicetree/bindings/net/fsl-fec.txt |   24 ++++
> > > >  drivers/net/fec.c                                 |  120 ++++++++++++++++++++-
> > > >  2 files changed, 139 insertions(+), 5 deletions(-)
> > > >  create mode 100644 Documentation/devicetree/bindings/net/fsl-fec.txt
> > > > 
> > > > diff --git a/Documentation/devicetree/bindings/net/fsl-fec.txt b/Documentation/devicetree/bindings/net/fsl-fec.txt
> > > > new file mode 100644
> > > > index 0000000..1dad888
> > > > --- /dev/null
> > > > +++ b/Documentation/devicetree/bindings/net/fsl-fec.txt
> > > > @@ -0,0 +1,24 @@
> > > > +* Freescale Fast Ethernet Controller (FEC)
> > > > +
> > > > +Required properties:
> > > > +- compatible : Should be "fsl,<soc>-fec"
> > > > +- reg : Address and length of the register set for the device
> > > > +- interrupts : Should contain fec interrupt
> > > > +- phy-mode : String, operation mode of the PHY interface.
> > > > +  Supported values are: "mii", "gmii", "sgmii", "tbi", "rmii",
> > > > +  "rgmii", "rgmii-id", "rgmii-rxid", "rgmii-txid", "rtbi".
> > > 
> > > We don't have a common binding for this yet.  Should be
> > > "fsl,phy-mode".
> > > 
> > There is nothing really fsl specific.
> 
> That's not really the point.  It might be that phy-mode as you're
> defining it here will not be sufficient for other ethernet devices.

I'm not defining the phy mode.  Instead, it's just a direct mapping
of 'enum phy_interface_t' found in include/linux/phy.h, which is
something common and generic, I think?

> You should avoid creating 'generic' property definitions, unless
> you're doing the leg work of figuring out which devices would use this
> property and creating multiple users.
> 

Any net device driver currently referring to 'enum phy_interface_t'
is going to need this property when migrating to dt, I guess.

> So, you may be right that this isn't fsl specific, but it is still
> good practise to use that "fsl," prefix.
> 
> 
> > How does thn following patch
> > look to you?
> > 
> > ---8<---------
> > diff --git a/drivers/of/of_net.c b/drivers/of/of_net.c
> > index 86f334a..cc117db 100644
> > --- a/drivers/of/of_net.c
> > +++ b/drivers/of/of_net.c
> > @@ -8,6 +8,49 @@
> >  #include <linux/etherdevice.h>
> >  #include <linux/kernel.h>
> >  #include <linux/of_net.h>
> > +#include <linux/phy.h>
> > +
> > +/**
> > + * It maps 'enum phy_interface_t' found in include/linux/phy.h
> > + * into the device tree binding of 'phy-mode', so that Ethernet
> > + * device driver can get phy interface from device tree.
> > + */
> > +static const char *phy_modes[] = {
> > +       [PHY_INTERFACE_MODE_MII]        = "mii",
> > +       [PHY_INTERFACE_MODE_GMII]       = "gmii",
> > +       [PHY_INTERFACE_MODE_SGMII]      = "sgmii",
> > +       [PHY_INTERFACE_MODE_TBI]        = "tbi",
> > +       [PHY_INTERFACE_MODE_RMII]       = "rmii",
> > +       [PHY_INTERFACE_MODE_RGMII]      = "rgmii",
> > +       [PHY_INTERFACE_MODE_RGMII_ID]   = "rgmii-id",
> > +       [PHY_INTERFACE_MODE_RGMII_RXID] = "rgmii-rxid",
> > +       [PHY_INTERFACE_MODE_RGMII_TXID] = "rgmii-txid",
> > +       [PHY_INTERFACE_MODE_RTBI]       = "rtbi",
> > +};
> > +
> > +/**
> > + * of_get_phy_mode - Get phy mode for given device_node
> > + * @np:        Pointer to the given device_node
> > + *
> > + * The function gets phy interface string from property 'phy-mode',
> > + * and return its index in phy_modes table, or errno in error case.
> > + */
> > +const int of_get_phy_mode(struct device_node *np)
> > +{
> > +       const char *pm;
> > +       int err, i;
> > +
> > +       err = of_property_read_string(np, "phy-mode", &pm);
> > +       if (err < 0)
> > +               return err;
> > +
> > +       for (i = 0; i < ARRAY_SIZE(phy_modes); i++)
> > +               if (!strcasecmp(pm, phy_modes[i]))
> > +                       return i;
> > +
> > +       return -ENODEV;
> > +}
> > +EXPORT_SYMBOL_GPL(of_get_phy_mode);
> 
> The code looks fine, but I'm just not keen on this until I see
> multiple users.  What are the other DT-aware network drivers doing
> right now?
> 
You can find a bunch of examples using 'phy-mode' in this way with
the grep below.

$ grep phy-mode arch/powerpc/boot/dts/*

The code I can find is drivers/net/ibm_newemac/core.c, function
emac_init_config.  And I think it should use 'enum phy_interface_t'
than defining its own PHY_MODE_*.

-- 
Regards,
Shawn
