From: tndave <tushar.n.dave-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: clean up and modularize arch dma_mapping interface V2
Date: Mon, 26 Jun 2017 15:06:25 -0700
Message-ID: <91360640-546b-edab-9f4a-952c7a1d0061@oracle.com>
References: <20170616181059.19206-1-hch@lst.de>
	<162d7932-5766-4c29-5471-07d1b699190a@oracle.com>
	<20170624071855.GD14580@lst.de>
	<1498318616.31581.87.camel@kernel.crashing.org>
	<20170626094739.GB13981@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-samsung-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-c6x-dev-jPsnJVOj+W6hPH1hqNUYSQ@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org,
	x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, dmaengine-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, openrisc-cunTk1MwBs9a3B2Vnqf2dGD2FQJk+8+b@public.gmane.org,
	linux-hexagon-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>,
	Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20170626094739.GB13981-jcswGhMUV9g@public.gmane.org>
Content-Language: en-US
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/iommu/>
List-Post: <mailto:iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 06/26/2017 02:47 AM, Christoph Hellwig wrote:
> On Sat, Jun 24, 2017 at 10:36:56AM -0500, Benjamin Herrenschmidt wrote:
>> I think we still need to do it. For example we have a bunch new "funky"
>> cases.
> 
> I have no plan to do away with the selection - I just want a better
> interface than the current one.
I agree we need better interface than the current one.
Like Benjamin mentioned cases for powerpc , sparc also need some special
treatment for ATU IOMMU depending on device's DMA mask.

For sparc, I am in process of enabling one or more dedicated IOTSB (I/O
Translation Storage Buffer) per PCI BDF (contrary to current design
where all PCI device under root complex share a 32bit and/or 64bit IOTSB
depending on 32bit and/or 64bit DMA). I am planning to use DMA set mask
APIs as hook where based on device's dma mask values (dma_mask and
coherent_dma_mask) one or more IOTSB resource will be allocated (and
released [1]).

Without set_dma_mask ops, I can still rely on HAVE_ARCH_DMA_SET_MASK and
dma_supported() that allows me to distinguish if device is setting
its streaming dma_mask and coherent_dma_mask respectively.

-Tushar

[1] By default, every PCI BDF will have one dedicated 32bit IOTSB. This
is to support default case where some device drivers even don't bother
to set DMA mask but instead are fine with default 32bit mask.
A 64bit IOTSB will be allocated when device request 64bit dma_mask.
However if device wants 64bit dma mask for both coherent and
non-coherent, a default 32bit IOTSB will be released as well. Wasting an
IOTSB is not a good idea because there is a hard limit on max number of
IOTSB per guest domain per root complex.


> --
> To unsubscribe from this list: send the line "unsubscribe sparclinux" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
