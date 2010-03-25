From: "Ira W. Snyder" <iws-lulEs6mt1IksTUYHLfqkUA@public.gmane.org>
Subject: Re: [PATCH 1/3] mfd: add support for Janz CMOD-IO PCI MODULbus
	Carrier Board
Date: Thu, 25 Mar 2010 16:22:44 -0700
Message-ID: <20100325232244.GG10454@ovro.caltech.edu>
References: <> <1268930324-29841-2-git-send-email-iws@ovro.caltech.edu>
	<20100319163849.GB30409@sortiz.org>
	<20100319182209.GD13672@ovro.caltech.edu>
	<20100325225929.GA20618@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100325225929.GA20618-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 25, 2010 at 11:59:30PM +0100, Samuel Ortiz wrote:
> Hi Ira,
> 
> First of all, sorry for the late reply. Then my answers:
> 
> On Fri, Mar 19, 2010 at 11:22:09AM -0700, Ira W. Snyder wrote:
> > 
> > > > +/*
> > > > + * Subdevice Support
> > > > + */
> > > Please use the mfd-core API for building and registering platform sub devices.
> > > The pieces of code below should shrink significantly.
> > > 
> > 
> > Using this framework, how is it possible to create  the devices that I
> > do down below. For each subdevice, I need three resources:
> > 
> > 1) MODULbus registers -- PCI BAR3 + (0x200 * module_num)
> > 2) PLX Control Registers -- PCI BAR4
> > 3) IRQ
> > 
> > Specifically, the way IORESOURCE_MEM resources are copied seems wrong.
> > They start at the base address of only one resource and use the offsets
> > provided in the struct mfd_cell. See the if-statement at
> > drivers/mfd/mfd-core.c line 48.
> > 
> > I need two use two different parent resources. The mfd_add_devices()
> > function doesn't support this.
> I would still like you to use the mfd-core API. Here is my proposal:
> 
> 1) I modify mfd_add_device() to support a NULL mem_base argument. When
> mem_base is NULL, we would have:
> 
> res[r].parent = NULL and res[r].start = cell->resources[r].start;
> 
> The platform code will use iomem_resource as the parent for this resource.
> 

I don't know the implications of using iomem_resource as the parent
resource. If you think it is ok, I have no objections.

If it helps, I can provide the PCI resource as a parent resource in my
resources. Then, when mem_base is NULL, the mfd-core could do this:

res[r].parent = cell->resources[r].parent

This is basically what I did in my patch. I used the PCI resource as the
parent of all child resources. I don't know if that is safe, but it
works. :)

The mfd_add_device() function does this for IORESOURCE_IO resources. It
only tries to be smart for IORESOURCE_MEM and IORESOURCE_IRQ resources.

> 2) Your mfd_cell cells would have 3 resources, and you just need to set the
> IORESOURCE_MEM ones at probe time, with pci->resource[n]->start + offset as
> the start field.
> 
> Would that make sense to you ?
> 

Yep, that makes sense.

> > > > +	/* Onboard configuration registers */
> > > > +	priv->ctrl = pci_ioremap_bar(dev, 4);
> > > Why 4 ?
> > > 
> > > 
> > 
> > Because that is how the device works ;) There is a comment up above that
> > describes them as the "PLX control registers". Are you suggesting that I
> > add a comment here too?
> No, that's ok, I missed the comment.
> 
> > > > +#define PCI_VENDOR_ID_JANZ		0x13c3
> > > That probably belongs to pci_ids.h
> > > 
> > 
> > Should I add a patch to the series for this?
> Either that or merge the pci_ids.h changes with this patch.
> 

I guess it is a trivial enough change to merge with this patch.

I'll wait for your patch to the mfd-core API before making changes and
sending out the next round of updates.

Thanks for replying,
Ira
