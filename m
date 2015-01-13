From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH 5/6] net: davinci_emac: Fix ioremap for devices with MDIO
 within the EMAC address space
Date: Tue, 13 Jan 2015 11:59:58 -0800
Message-ID: <20150113195957.GH2419@atomide.com>
References: <1421177368-19756-1-git-send-email-tony@atomide.com>
 <1421177368-19756-6-git-send-email-tony@atomide.com>
 <20150113195405.GU16533@saruman>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-omap@vger.kernel.org, Brian Hutchinson <b.hutchman@gmail.com>
To: Felipe Balbi <balbi@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150113195405.GU16533@saruman>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Felipe Balbi <balbi@ti.com> [150113 11:57]:
> On Tue, Jan 13, 2015 at 11:29:27AM -0800, Tony Lindgren wrote:
> > Some devices like dm816x have the MDIO registers within the first EMAC
> > instance address space. Let's fix the issue by allowing to pass an
> > optional second IO range for the EMAC control register area.
> > 
> > Cc: Brian Hutchinson <b.hutchman@gmail.com>
> > Cc: Felipe Balbi <balbi@ti.com>
> > Signed-off-by: Tony Lindgren <tony@atomide.com>
> > ---
> >  drivers/net/ethernet/ti/davinci_emac.c | 15 ++++++++++++---
> >  1 file changed, 12 insertions(+), 3 deletions(-)
> > 
> > diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
> > index 4c8d82c..0342273 100644
> > --- a/drivers/net/ethernet/ti/davinci_emac.c
> > +++ b/drivers/net/ethernet/ti/davinci_emac.c
> > @@ -1877,7 +1877,7 @@ davinci_emac_of_get_pdata(struct platform_device *pdev, struct emac_priv *priv)
> >  static int davinci_emac_probe(struct platform_device *pdev)
> >  {
> >  	int rc = 0;
> > -	struct resource *res;
> > +	struct resource *res, *res_ctrl;
> >  	struct net_device *ndev;
> >  	struct emac_priv *priv;
> >  	unsigned long hw_ram_addr;
> > @@ -1936,11 +1936,20 @@ static int davinci_emac_probe(struct platform_device *pdev)
> >  		rc = PTR_ERR(priv->remap_addr);
> >  		goto no_pdata;
> >  	}
> > +
> > +	res_ctrl = platform_get_resource(pdev, IORESOURCE_MEM, 1);
> > +	if (res_ctrl) {
> 
> devm_ioremap_resource() will check for res_ctrl being a valid pointer,
> perhaps below would be slightly better ?
> 
> 
> 	res_ctrl = platform_get_resource(pdev, IORESOURCE_MEM, 1);
> 	priv->ctrl_base = devm_ioremap_resource(&pdev->dev, res_ctrl);
> 	if (IS_ERR(priv->ctrl_base))
> 		priv->ctrl_base = priv->remap_addr + pdata->ctrl_mod_reg_offset;
> 

We have a pile of devices using just one ioremap area so the second
ioremap area needs to be optional. That's why we only do it based on
if (res_ctrl).

Regards,

Tony
