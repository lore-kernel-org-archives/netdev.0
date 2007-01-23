From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] bcm43xx: Fix problem with >1 GB RAM
Date: Tue, 23 Jan 2007 10:18:36 -0500
Message-ID: <1169565516.2777.13.camel@localhost.localdomain>
References: <45b240d6.SHryQ/4Jr/1MvQso%Larry.Finger@lwfinger.net>
	 <200701221920.28938.mb@bu3sch.de>  <45B51C31.10000@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>,
	John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org,
	Bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:51632 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932091AbXAWPRd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jan 2007 10:17:33 -0500
To: Larry Finger <larry.finger@lwfinger.net>
In-Reply-To: <45B51C31.10000@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-01-22 at 14:18 -0600, Larry Finger wrote:
> Michael Buesch wrote:
> > On Saturday 20 January 2007 17:18, Larry Finger wrote:
> >> Some versions of the bcm43xx chips only support 30-bit DMA, which means
> >> that the descriptors and buffers must be in the first 1 GB of RAM. On
> >> the i386 and x86_64 architectures with more than 1 GB RAM, an incorrect
> >> assignment may occur. This patch ensures that the various DMA addresses
> >> are within the capability of the chip. Testing has been limited to x86_64
> >> as no one has an i386 system with more than 1 GB RAM.
> >>
> >> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> >> ---
> 
> ..snip..
> 
> >>  	assert(!ring->tx);
> >>  
> >> -	dma_sync_single_for_cpu(&ring->bcm->pci_dev->dev,
> >> -				addr, len, DMA_FROM_DEVICE);
> >> +	pci_dma_sync_single_for_cpu(ring->bcm->pci_dev,
> >> +				    addr, len, PCI_DMA_FROMDEVICE);
> >>  }
> > 
> > Any special reason why you convert the DMA operations to the PCI
> > stuff? I ask, because if this makes a difference, it affects the
> > new SSB subsystem as well.
> 
> When I looked at the b44 driver to see how that code handled the problem, it used the pci-form of
> the calls rather than the dma-version. Thus I switched early in the debug process - even before I
> had the necessary hardware. Once I got it working and understood the problem, I never tried
> restoring the dma-forms.
> 
> At present, I have a problem getting NetworkManager to see the d80211 wireless interface. Once I get
> that solved, I plan to use my system to test with > 1 GB RAM on your git tree. In that case, I'll
> switch to the pci-form only if necessary.

NM should show the interface if HAL sees the interface and has assigned
it a "net.80211" capability.  We had all agreed that HAL should be a bit
smarter about detecting d80211 devices, but we were postponing that
until we figured out what to do with the master device.  Now that we
think it will actually go away, it will be easier to find the actual
wlan devices in sysfs or in /proc/net/wireless.

I think HAL still looks in /proc/net/wireless to determine whether a
network interface that it found is actually a wireless interface.

The long and short of it is that if HAL says it has "net.80211"
capability, NM should be able to find the device.

Dan

> > 
> >>  static inline
> >> @@ -194,8 +192,8 @@ void sync_descbuffer_for_device(struct b
> 
> ..snip..
> 
> >> -	goto out;
> >> +no_dma:
> >> +#ifdef CONFIG_BCM43XX_PIO
> >> +	printk(KERN_WARNING PFX "DMA not supported on this device."
> >> +				" Falling back to PIO.\n");
> >> +	bcm->__using_pio = 1;
> >> +	BUG();
> > 
> > That isn't a BUG. Just remove this call, please.
> 
> It was accidentally left in from my debugging. I have already submitted a revised version to
> Linville that removes this, and one other BUG statement that you didn't note.
> 
> 
> >> +	return -ENOSYS;
> >> +#else
> >> +	printk(KERN_ERR PFX "FATAL: DMA not supported and PIO not configured. "
> >> +			    "Please recompile the driver with PIO support.\n");
> >> +	return -ENODEV;
> >> +#endif /* CONFIG_BCM43XX_PIO */
> >>  }
> 
> ..snip..
> 
> >>  	u16 board_vendor;
> >>  	u16 board_type;
> > 
> > The rest is OK, I think.
> > Thanks for the nice work.
> 
> Thank you. It certainly was a lot easier with the necessary hardware in house.
> 
> Larry
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

