From: Michael Buesch <mb@bu3sch.de>
Subject: Re: The new SSB subsystem for bcm43xx (and others)
Date: Sat, 10 Feb 2007 23:14:53 +0100
Message-ID: <200702102314.54194.mb@bu3sch.de>
References: <200612221359.25093.mb@bu3sch.de> <200702102203.57411.mb@bu3sch.de> <20070210221150.GA28338@srcf.ucam.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bcm43xx-dev@lists.berlios.de,
	Felix Fietkau <nbd@nbd.name>
To: Matthew Garrett <mjg59@srcf.ucam.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:40124
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752036AbXBJWPV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Feb 2007 17:15:21 -0500
In-Reply-To: <20070210221150.GA28338@srcf.ucam.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 10 February 2007 23:11, Matthew Garrett wrote:
> On Sat, Feb 10, 2007 at 10:03:57PM +0100, Michael Buesch wrote:
> > On Saturday 10 February 2007 21:46, Matthew Garrett wrote:
> > > I'm testing with your bcm43xx git tree, which I'm guessing is the 
> > > current ssb code. The only problem I've found is that there doesn't seem 
> > > to be any sysfs relationship between the ssb bus and (in this case) the 
> > > PCI device that it's associated with. Is this fixable? Right now it 
> > > appears as an entirely separate branch of the device tree, which doesn't 
> > > seem quite right.
> > 
> > I guess that's fixable, but I didn't care too much, yet.
> 
> Ok, here's a patch. The stack of PCMCIA headers are needed to get the 
> pcmcia_device structure. Seems to work fine for PCI - I don't have any 
> PCMCIA devices. The SSB devices now appear underneath the PCI device 
> rather than in the top level of /sys/devices.
> 
> Signed-off-by: Matthew Garrett <mjg59@srcf.ucam.org>

Ok, nice. Thanks for figuring this out.
I'll apply this too my tree.

> ---
> 
> diff --git a/drivers/ssb/scan.c b/drivers/ssb/scan.c
> index 64f94b8..b16cee9 100644
> --- a/drivers/ssb/scan.c
> +++ b/drivers/ssb/scan.c
> @@ -15,6 +15,11 @@
>  #include <linux/ssb/ssb.h>
>  #include <linux/ssb/ssb_regs.h>
>  #include <linux/pci.h>
> +#include <pcmcia/cs_types.h>
> +#include <pcmcia/cs.h>
> +#include <pcmcia/cistpl.h>
> +#include <pcmcia/ciscode.h>
> +#include <pcmcia/ds.h>
>  #include <asm/io.h>
>  
>  #include "ssb_private.h"
> @@ -306,8 +311,12 @@ int ssb_bus_scan(struct ssb_bus *bus,
>  		dev->id.vendor = (idhi & SSB_IDHIGH_VC) >> SSB_IDHIGH_VC_SHIFT;
>  		dev->core_index = i;
>  		dev->bus = bus;
> -		if ((dev->bus->bustype == SSB_BUSTYPE_PCI) && (bus->host_pci))
> +		if ((dev->bus->bustype == SSB_BUSTYPE_PCI) && (bus->host_pci)) {
>  			dev->irq = bus->host_pci->irq;
> +			dev->dev.parent = &bus->host_pci->dev;
> +		} else if (dev->bus->bustype == SSB_BUSTYPE_PCMCIA) {
> +		        dev->dev.parent = &bus->host_pcmcia->dev;
> +		}
>  
>  		ssb_dprintk(KERN_INFO PFX
>  			    "Core %d found: %s "
> 

-- 
Greetings Michael.
