From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Subject: Re: [RFC PATCH] fix problems with NETIF_F_HIGHDMA in networking drivers
Date: Fri, 26 Feb 2010 16:25:24 +0100
Message-ID: <201002261625.24523.bzolnier@gmail.com>
References: <4B834159.7070105@gmail.com> <20100226.013637.255461265.davem@davemloft.net> <51f3faa71002260646r705891e8tdbab1f6faeeb4b81@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Robert Hancock <hancockrwd@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51f3faa71002260646r705891e8tdbab1f6faeeb4b81@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 26 February 2010 03:46:45 pm Robert Hancock wrote:
> On Fri, Feb 26, 2010 at 3:36 AM, David Miller <davem@davemloft.net> wrote:
> > From: Robert Hancock <hancockrwd@gmail.com>
> > Date: Mon, 22 Feb 2010 20:45:45 -0600
> >
> >> Many networking drivers have issues with the use of the NETIF_F_HIGHDMA flag.
> >> This flag actually indicates whether or not the device/driver can handle
> >> skbs located in high memory (as opposed to lowmem). However, many drivers
> >> incorrectly treat this flag as indicating that 64-bit DMA is supported, which
> >> has nothing to do with its actual function. It makes no sense to make setting
> >> NETIF_F_HIGHDMA conditional on whether a 64-bit DMA mask has been set, as many
> >> drivers do, since if highmem DMA is supported at all, it should work regardless
> >> of whether 64-bit DMA is supported. Failing to set NETIF_F_HIGHDMA when it
> >> should be can hurt performance on architectures which use highmem since it
> >> results in needless data copying.
> >>
> >> This fixes up the networking drivers which currently use NETIF_F_HIGHDMA to
> >> not do so conditionally on DMA mask settings.
> >>
> >> For the USB kaweth and usbnet drivers, this patch also uncomments and corrects
> >> some code to set NETIF_F_HIGHDMA based on the USB host controller's DMA mask.
> >> These drivers should be able to access highmem unless the host controller is
> >> non-DMA-capable, which is indicated by the DMA mask being null.
> >>
> >> Signed-off-by: Robert Hancock <hancockrwd@gmail.com>
> >
> > Well, if the device isn't using 64-bit DMA addressing and the platform
> > uses direct (no-iommu) mapping of physical to DMA addresses , won't
> > your change break things?  The device will get a >4GB DMA address or
> > the DMA mapping layer will signal an error.
> >
> > That's really part of the what the issue is I think.
> >
> > So, this trigger the check in check_addr() in
> > arch/x86/kernel/pci-nommu.c when such packets try to get mapped by the
> > driver, right?
> >
> > That will make the DMA mapping call fail, and the packet will be
> > dropped permanently.  And hey, on top of it, many of these drivers you
> > remove the setting from don't even check the mapping call return
> > values for errors.
> >
> > So even bigger breakage.  One example is drivers/net/8139cp.c,
> > it just does dma_map_single() and uses the result.
> >
> > It really depends upon that NETIF_F_HIGHDMA setting for correct
> > operation.
> >
> > And even if something like swiotlb is available, now we're going
> > to do bounce buffering which is largely equivalent to what
> > a lack of NETIF_F_HIGHDMA will do.  Except that once NETIF_F_HIGHDMA
> > copies the packet to lowmem it will only do that once, whereas if
> > the packet goes to multiple devices swiotlb might copy the packet
> > to a bounce buffer multiple times.
> >
> > We definitely can't apply your patch as-is.
> 
> Hmm.. Yeah, there is a bit of a mess there. I'm thinking of the
> particular example of i386 where you have 32-bit DMA devices with more
> than 4GB of RAM. If you then allow the device to access highmem then
> the DMA mapping API can get presented with addresses above 4GB and
> AFAIK I don't think it can cope with that situation on that platform.
> 
> Problem is that the NETIF_F_HIGHDMA check is generally too restrictive
> in that situation, and it's really conflating two things into one (the
> genuine can't-access-highmem part, and the "oh by the way, if highmem
> can be >4GB then we can't access that") . If you have 3GB of RAM on
> i386 with one of these drivers, you'll have packets being bounced
> through lowmem without any real reason. I'll have a look into things a
> bit further..

Maybe it would be useful to start with splitting NETIF_F_HIGHDMA on two
independent flags, i.e.:

	#define	NETIF_F_DMA_HIGH	(1 << 27)
	#define NETIF_F_DMA_64BIT	(1 << 28)

and keeping NETIF_F_HIGHDMA as

	#define NETIF_F_HIGHDMA		(NETIF_F_DMA_HIGH | NET_F_DMA_64BIT)

for now..?

[ Next step would involve fixing illegal_highdma() check in net/core/dev.c
  to distinguish between those new flags which in turn should allow sorting
  out code in the device drivers on *per-driver* basis. ]

--
Bartlomiej Zolnierkiewicz
