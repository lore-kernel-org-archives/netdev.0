From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Subject: Re: [PATCH 1/1] net/macb: add DT support
Date: Sun, 20 Nov 2011 17:47:40 +0100
Message-ID: <20111120164740.GC21480@game.jcrosoft.org>
References: <1321626565-11261-1-git-send-email-plagnioj@jcrosoft.com>
 <20111118155824.GA9981@totoro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devicetree-discuss@ozlabs.org, netdev@vger.kernel.org,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: Jamie Iles <jamie@jamieiles.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 8.mo2.mail-out.ovh.net ([188.165.52.147]:57685 "EHLO
	mo2.mail-out.ovh.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753067Ab1KTQuB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Nov 2011 11:50:01 -0500
Received: from mail190.ha.ovh.net (b7.ovh.net [213.186.33.57])
	by mo2.mail-out.ovh.net (Postfix) with SMTP id 004BADC5C2A
	for <netdev@vger.kernel.org>; Sun, 20 Nov 2011 17:56:14 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20111118155824.GA9981@totoro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15:58 Fri 18 Nov     , Jamie Iles wrote:
> Hi Jean-Christophe,
> 
> On Fri, Nov 18, 2011 at 03:29:25PM +0100, Jean-Christophe PLAGNIOL-VILLARD wrote:
> > allow the DT to pass the mac address and the phy mode
> > 
> > Signed-off-by: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
> > Cc: Jamie Iles <jamie@jamieiles.com>
> > Cc: Nicolas Ferre <nicolas.ferre@atmel.com>
> 
> This looks OK to me in principle.  I can't easily test this at the 
> moment, but as I don't have a DT platform that has the clk framework up 
> and running.  A couple of nits/questions inline, but thanks for doing 
> this!
> 
> Jamie
> 
> > ---
> >  Documentation/devicetree/bindings/net/macb.txt |   22 ++++++++
> >  drivers/net/ethernet/cadence/macb.c            |   65 +++++++++++++++++++++---
> >  drivers/net/ethernet/cadence/macb.h            |    2 +
> >  3 files changed, 81 insertions(+), 8 deletions(-)
> >  create mode 100644 Documentation/devicetree/bindings/net/macb.txt
> > 
> > diff --git a/Documentation/devicetree/bindings/net/macb.txt b/Documentation/devicetree/bindings/net/macb.txt
> > new file mode 100644
> > index 0000000..2b727ec
> > --- /dev/null
> > +++ b/Documentation/devicetree/bindings/net/macb.txt
> > @@ -0,0 +1,22 @@
> > +* Cadence EMACB
> > +
> > +Implemeted on Atmel AT91 & AVR32 SoC
> 
> I think something along the lines of "Binding for the Cadence MACB 
> Ethernet controller" rather than listing specific parts might be 
> clearer.
I prefer as we will have implementation detail in the binding
> 
> > +
> > +Required properties:
> > +- compatible : Should be "atmel,macb" for Atmel
> > +- reg : Address and length of the register set for the device
> > +- interrupts : Should contain macb interrupt
> > +- phy-mode : String, operation mode of the PHY interface.
> > +  Supported values are: "mii", "rmii",
> > +
> > +Optional properties:
> > +- local-mac-address : 6 bytes, mac address
> > +
> > +Examples:
> > +
> > +	macb0: macb@fffc4000 {
> 
> Rob pointed out to me a little while ago that the preferred naming from 
> the ePAPR document would be:
> 
> 	macb0: ethernet@fffc4000
> 
> so it might be worth being consistent here.
ok
> 
> > +		compatible = "atmel,macb";
> 
> This should be "cdns,macb" as it isn't Atmel specific.  I believe cdns 
> is the correct stock ticker symbol for Cadence.
here I put "atmel,macb" on purpose to specify the difference of the IP between
the soc, in fact it should have been atmel-at91,macb

> 
> > +		reg = <oxfffc4000 0x4000>;
> > +		interrupts = <21>;
> > +		phy-mode = "mii";
> > +	};
> > diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> > index a437b46..2c345bc 100644
> > --- a/drivers/net/ethernet/cadence/macb.c
> > +++ b/drivers/net/ethernet/cadence/macb.c
> > @@ -20,6 +20,9 @@
> >  #include <linux/etherdevice.h>
> >  #include <linux/dma-mapping.h>
> >  #include <linux/platform_device.h>
> > +#include <linux/of.h>
> > +#include <linux/of_device.h>
> > +#include <linux/of_net.h>
> >  #include <linux/phy.h>
> >  
> >  #include <mach/board.h>
> > @@ -81,6 +84,20 @@ static void __init macb_get_hwaddr(struct macb *bp)
> >  	addr[4] = top & 0xff;
> >  	addr[5] = (top >> 8) & 0xff;
> >  
> > +#ifdef CONFIG_OF
> > +	/*
> > +	 * 2) from device tree data
> > +	 */
> > +	if (!is_valid_ether_addr(addr)) {
> > +		struct device_node *np = bp->pdev->dev.of_node;
> > +		if (np) {
> > +			const char *mac = of_get_mac_address(np);
> > +			if (mac)
> > +				memcpy(addr, mac, sizeof(addr));
> > +		}
> > +	}
> > +#endif
> 
> I'm a bit conflicted here.  I think we should always use the MAC address 
> from the device tree if it is present even if the current MAC address is 
> valid.
if the mac is already programmed in the register we just keep it
I prefer this way if the bootloader set it we keep it

Best Regards,
J.
