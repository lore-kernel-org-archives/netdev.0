From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] cxacru: ignore cx82310_eth devices
Date: Sun, 5 Sep 2010 14:04:46 -0700
Message-ID: <20100905210446.GA4472@kroah.com>
References: <201009032317.14954.linux@rainbow-software.org> <201009051901.13851.linux@rainbow-software.org> <20100905191412.GA10835@kroah.com> <201009052212.37015.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simon Arlott <simon@fire.lp0.eu>,
	David Brownell <dbrownell@users.sourceforge.net>,
	netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: Ondrej Zary <linux@rainbow-software.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201009052212.37015.linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 05, 2010 at 10:12:33PM +0200, Ondrej Zary wrote:
> Ignore ADSL routers, which can have the same vendor and product IDs
> as ADSL modems but should be handled by the cx82310_eth driver.
> 
> This intentionally ignores device IDs that aren't currently handled
> by cx82310_eth. There may be other device IDs that perhaps shouldn't
> be claimed by cxacru.
> 
> Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
> 
> --- linux-2.6.36-rc3-orig/drivers/usb/atm/cxacru.c	2010-08-29 17:36:04.000000000 +0200
> +++ linux-2.6.36-rc3/drivers/usb/atm/cxacru.c	2010-09-05 18:54:56.000000000 +0200
> @@ -1324,8 +1324,22 @@ static struct usbatm_driver cxacru_drive
>  	.tx_padding	= 11,
>  };
>  
> -static int cxacru_usb_probe(struct usb_interface *intf, const struct usb_device_id *id)
> -{
> +static int cxacru_usb_probe(struct usb_interface *intf,
> +		const struct usb_device_id *id) {

Ick, what?

Did you run this patch through scripts/checkpatch.pl?

As you didn't change the function arguments, just leave the long line
alone, but even if you did change it, the '{' has to be on the next line
by itself.  See Documentation/CodingStyle for details.

> +	struct usb_device *usb_dev = interface_to_usbdev(intf);
> +	char buf[15];
> +
> +	/* avoid ADSL routers (cx82310_eth)
> +	 * abort if bDeviceClass is 0xff and iProduct is "USB NET CARD" */
> +	if (usb_dev->descriptor.bDeviceClass == USB_CLASS_VENDOR_SPEC
> +			&& usb_string(usb_dev, usb_dev->descriptor.iProduct,
> +				buf, sizeof(buf)) > 0) {
> +		if (!strcmp(buf, "USB NET CARD")) {
> +			dev_info(&intf->dev, "ignoring cx82310_eth device\n");
> +			return -ENODEV;
> +		}
> +	}

In thinking about this a bit more, don't you also want to check the
vendor and product id?  You can't always be sure about the string of any
old device, right?

thanks,

greg k-h
