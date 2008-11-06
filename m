From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [git patches] net driver fixes for 2.6.28-rc
Date: Thu, 06 Nov 2008 00:42:56 -0500
Message-ID: <491283E0.2010009@garzik.org>
References: <20081104075138.GA2096@earth.li>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jonathan McDowell <noodles@earth.li>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34697 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753213AbYKFFnC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Nov 2008 00:43:02 -0500
In-Reply-To: <20081104075138.GA2096@earth.li>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jonathan McDowell wrote:
> In article <490F824E.3070809@garzik.org> (earth.lists.linux-kernel) you wrote:
>> Marcel Holtmann wrote:
>>> are you also queuing patches for drivers/net/usb/hso.c, because the 
>>> current state of that driver is fully broken. It oopses and shows up 
>>> with a WLAN RFKILL switch instead of WWAN. Also it has some weird 
>>> disconnect race with the TTY layer. Some patches have been posted, but 
>>> seems that nobody has picked them up so far.
> 
>> Last patch sent me was sent on 9/16 by Denis Joseph Barrow; I replied 
>> and never received a response after that.
> 
>> Patches welcome...
> 
>> I don't see any hso patches on
>> http://patchwork.ozlabs.org/project/netdev/list/ nor in my inbox, so I'm 
>> guessing that no one sent me or netdev any hso patches.
> 
> I sent the below to netdev@, Greg K-H and Andrew Bird (the people listed
> in hso.c). I can't see it in the netdev archives but it did hit lkml ok
> at:
> 
> http://lkml.org/lkml/2008/10/30/92
> 
> A subsequent fix for the rfkill layer has also been sent (and that did
> hit netdev ok and got acked), but this hso cleanup is still appropriate.
> 
> The WLAN/WWAN change is obviously a one line fix but I didn't see any
> point sending a patch for it until I knew I was going to get some sort
> of response about it; I can knock one up if that's helpful.
> 
> Original message:
> 
> [PATCH] Cleanup hso rfkill error handling
> 
> Yup, this appears to be the problem, thanks. I think &hso_net->net->dev
> is more intuitive for the error message, so I've used that. I've also
> added missing line endings on the error messages and set our local
> rfkill structure element to NULL on failure so we don't try to call
> rfkill_unregister on driver removal if we failed to register at all.
> 
> The patch below Works For Me (TM); the device is detected fine, can be
> removed without problems and connects ok. I'll have a prod at why the
> rfkill stuff isn't working next, but I believe this cleanup of the error
> handling is appropriate no matter what the issue with registration is.
> 
> Signed-Off-By: Jonathan McDowell <noodles@earth.li>
> 
> -----
> diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
> index 1164c52..9d9622b 100644
> --- a/drivers/net/usb/hso.c
> +++ b/drivers/net/usb/hso.c
> @@ -2184,19 +2184,20 @@ static void hso_create_rfkill(struct hso_device *hso_dev,
>  			     struct usb_interface *interface)
>  {
>  	struct hso_net *hso_net = dev2net(hso_dev);
> -	struct device *dev = hso_dev->dev;
> +	struct device *dev = &hso_net->net->dev;
>  	char *rfkn;
>  
>  	hso_net->rfkill = rfkill_allocate(&interface_to_usbdev(interface)->dev,
>  				 RFKILL_TYPE_WLAN);
>  	if (!hso_net->rfkill) {
> -		dev_err(dev, "%s - Out of memory", __func__);
> +		dev_err(dev, "%s - Out of memory\n", __func__);
>  		return;
>  	}
>  	rfkn = kzalloc(20, GFP_KERNEL);
>  	if (!rfkn) {
>  		rfkill_free(hso_net->rfkill);
> -		dev_err(dev, "%s - Out of memory", __func__);
> +		hso_net->rfkill = NULL;
> +		dev_err(dev, "%s - Out of memory\n", __func__);
>  		return;
>  	}
>  	snprintf(rfkn, 20, "hso-%d",
> @@ -2209,7 +2210,8 @@ static void hso_create_rfkill(struct hso_device *hso_dev,
>  		kfree(rfkn);
>  		hso_net->rfkill->name = NULL;
>  		rfkill_free(hso_net->rfkill);
> -		dev_err(dev, "%s - Failed to register rfkill", __func__);
> +		hso_net->rfkill = NULL;
> +		dev_err(dev, "%s - Failed to register rfkill\n", __func__);
>  		return;

applied


