From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH] typhoon: use request_firmware
Date: Sun, 27 Jul 2008 21:43:20 -0400
Message-ID: <1217209400.22789.47.camel@obelisk.thedillows.org>
References: <1217170232.3537.6.camel@jaswinder.satnam>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, becker@scyld.com,
	davidpmclean@yahoo.com, Jeff Garzik <jeff@garzik.org>,
	netdev <netdev@vger.kernel.org>,
	David Woodhouse <dwmw2@infradead.org>
To: Jaswinder Singh <jaswinder@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.knology.net ([24.214.63.101]:59943 "EHLO smtp.knology.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751323AbYG1BnX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Jul 2008 21:43:23 -0400
In-Reply-To: <1217170232.3537.6.camel@jaswinder.satnam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2008-07-27 at 20:20 +0530, Jaswinder Singh wrote:
> --- a/drivers/net/typhoon.c
> +++ b/drivers/net/typhoon.c

>  MODULE_LICENSE("GPL");
> +MODULE_LICENSE("3com/typhoon.bin");

Uhm, MODULE_FIRMWARE()?

> @@ -1368,8 +1371,14 @@ typhoon_download_firmware(struct typhoon *tp)
>  	int i;
>  	int err;
>  
> +	err = request_firmware(&fw, fw_name, &tp->pdev->dev);
> +	if (err) {
> +		printk(KERN_ERR "%s: Failed to load firmware \"%s\"\n",
> +		       tp->name, fw_name);
> +		return err;
> +	}
>  	err = -EINVAL;
> -	fHdr = (struct typhoon_file_header *) typhoon_firmware_image;
> +	fHdr = (struct typhoon_file_header *) fw->data;
>  	image_data = (u8 *) fHdr;
>  
>  	if(memcmp(fHdr->tag, "TYPHOON", 8)) {
> @@ -1494,6 +1503,7 @@ err_out_irq:
>  	pci_free_consistent(pdev, PAGE_SIZE, dpage, dpage_dma);
>  
>  err_out:
> +	release_firmware(fw);
>  	return err;
>  }

It is not quite this simple. By not loading the firmware on device
probe, you have opened the door to a broken resume, and the driver will
now try to sleep in an atomic context, when typhoon_tx_timeout() is
called at the very least.

I've said that I was thinking about doing the conversion myself, and I
think the firmware loader makes some sense for new drivers. But the more
I think about converting old -- fairly static -- drivers such as
typhoon, I wonder "what's the point?" We don't save memory, we add code,
and we add failure points that weren't there before. Where's the upside?

Dave

