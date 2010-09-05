From: Ondrej Zary <linux@rainbow-software.org>
Subject: Re: [PATCH] cxacru: ignore cx82310_eth devices
Date: Sun, 5 Sep 2010 19:01:11 +0200
Message-ID: <201009051901.13851.linux@rainbow-software.org>
References: <201009032317.14954.linux@rainbow-software.org> <4C82741C.2000106@simon.arlott.org.uk> <20100905040352.GA18538@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Simon Arlott <simon@fire.lp0.eu>,
	David Brownell <dbrownell@users.sourceforge.net>,
	netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: Greg KH <greg@kroah.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100905040352.GA18538@kroah.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 05 September 2010 06:03:52 Greg KH wrote:
> On Sat, Sep 04, 2010 at 05:30:20PM +0100, Simon Arlott wrote:
> > Ignore ADSL routers, which can have the same vendor and product IDs
> > as ADSL modems but should be handled by the cx82310_eth driver.
> >
> > This intentionally ignores device IDs that aren't currently handled
> > by cx82310_eth. There may be other device IDs that perhaps shouldn't
> > be claimed by cxacru.
> >
> > Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
> > [SA: Moved to cxacru_usb_probe, message level lowered to info]
> > Signed-off-by: Simon Arlott <simon@fire.lp0.eu>
> > ---
> >  drivers/usb/atm/cxacru.c |   18 ++++++++++++++++--
> >  1 files changed, 16 insertions(+), 2 deletions(-)
> >
> > diff --git a/drivers/usb/atm/cxacru.c b/drivers/usb/atm/cxacru.c
> > index 593fc5e..96fa736 100644
> > --- a/drivers/usb/atm/cxacru.c
> > +++ b/drivers/usb/atm/cxacru.c
> > @@ -1324,8 +1324,22 @@ static struct usbatm_driver cxacru_driver = {
> >  	.tx_padding	= 11,
> >  };
> >
> > -static int cxacru_usb_probe(struct usb_interface *intf, const struct
> > usb_device_id *id) -{
> > +static int cxacru_usb_probe(struct usb_interface *intf,
> > +		const struct usb_device_id *id) {
> > +	struct usb_device *usb_dev = interface_to_usbdev(intf);
> > +	char buf[15];
> > +
> > +	/* avoid ADSL routers (cx82310_eth)
> > +	 * abort if bDeviceClass is 0xff and iProduct is "USB NET CARD" */
> > +	if (usb_dev->descriptor.bDeviceClass == 0xff
>
> vendor class?  We have a macro for that?
>
> > +			&& usb_dev->descriptor.iProduct
>
> Almost everyone has a iProduct, right?  Why even test for that?
>
> > +			&& usb_string(usb_dev,
> > +				usb_dev->descriptor.iProduct, buf, sizeof(buf))
>
> usb_string() should handle a 0 string, right?
>
> > +			&& !strcmp(buf, "USB NET CARD")) {
>
> Just to make it a bit easier to follow, how about you do the
> usb_string() call in the if statment, and then compare the string and
>
> then, if that matches you do:
> > +		dev_info(&intf->dev, "ignoring cx82310_eth device\n");
> > +		return -ENODEV;

Does it look that much better?:

	if (usb_dev->descriptor.bDeviceClass == USB_CLASS_VENDOR_SPEC
			&& usb_string(usb_dev, usb_dev->descriptor.iProduct,
				buf, sizeof(buf)) > 0)
		if (!strcmp(buf, "USB NET CARD")) {
			dev_info(&intf->dev, "ignoring cx82310_eth device\n");
			return -ENODEV;
		}

I also found a bug in my first patch - usb_string() can return negative value 
which can cause problems when not checked for.

> Well, actually, dev_info?  I guess so, but do you really want to see
> this message every time?
>
> thanks,
>
> greg k-h



-- 
Ondrej Zary
