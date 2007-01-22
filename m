From: Larry Finger <larry.finger@lwfinger.net>
Subject: Re: [PATCH] bcm43xx: Fix problem with >1 GB RAM
Date: Mon, 22 Jan 2007 14:18:57 -0600
Message-ID: <45B51C31.10000@lwfinger.net>
References: <45b240d6.SHryQ/4Jr/1MvQso%Larry.Finger@lwfinger.net> <200701221920.28938.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org,
	Bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:64342 "EHLO
	mtiwmhc12.worldnet.att.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751965AbXAVUVB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jan 2007 15:21:01 -0500
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200701221920.28938.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> On Saturday 20 January 2007 17:18, Larry Finger wrote:
>> Some versions of the bcm43xx chips only support 30-bit DMA, which means
>> that the descriptors and buffers must be in the first 1 GB of RAM. On
>> the i386 and x86_64 architectures with more than 1 GB RAM, an incorrect
>> assignment may occur. This patch ensures that the various DMA addresses
>> are within the capability of the chip. Testing has been limited to x86_64
>> as no one has an i386 system with more than 1 GB RAM.
>>
>> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
>> ---

..snip..

>>  	assert(!ring->tx);
>>  
>> -	dma_sync_single_for_cpu(&ring->bcm->pci_dev->dev,
>> -				addr, len, DMA_FROM_DEVICE);
>> +	pci_dma_sync_single_for_cpu(ring->bcm->pci_dev,
>> +				    addr, len, PCI_DMA_FROMDEVICE);
>>  }
> 
> Any special reason why you convert the DMA operations to the PCI
> stuff? I ask, because if this makes a difference, it affects the
> new SSB subsystem as well.

When I looked at the b44 driver to see how that code handled the problem, it used the pci-form of
the calls rather than the dma-version. Thus I switched early in the debug process - even before I
had the necessary hardware. Once I got it working and understood the problem, I never tried
restoring the dma-forms.

At present, I have a problem getting NetworkManager to see the d80211 wireless interface. Once I get
that solved, I plan to use my system to test with > 1 GB RAM on your git tree. In that case, I'll
switch to the pci-form only if necessary.

> 
>>  static inline
>> @@ -194,8 +192,8 @@ void sync_descbuffer_for_device(struct b

..snip..

>> -	goto out;
>> +no_dma:
>> +#ifdef CONFIG_BCM43XX_PIO
>> +	printk(KERN_WARNING PFX "DMA not supported on this device."
>> +				" Falling back to PIO.\n");
>> +	bcm->__using_pio = 1;
>> +	BUG();
> 
> That isn't a BUG. Just remove this call, please.

It was accidentally left in from my debugging. I have already submitted a revised version to
Linville that removes this, and one other BUG statement that you didn't note.


>> +	return -ENOSYS;
>> +#else
>> +	printk(KERN_ERR PFX "FATAL: DMA not supported and PIO not configured. "
>> +			    "Please recompile the driver with PIO support.\n");
>> +	return -ENODEV;
>> +#endif /* CONFIG_BCM43XX_PIO */
>>  }

..snip..

>>  	u16 board_vendor;
>>  	u16 board_type;
> 
> The rest is OK, I think.
> Thanks for the nice work.

Thank you. It certainly was a lot easier with the necessary hardware in house.

Larry

