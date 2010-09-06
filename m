From: "Simon Arlott" <simon@fire.lp0.eu>
Subject: Re: [PATCH] cxacru: ignore cx82310_eth devices
Date: Mon, 6 Sep 2010 12:45:02 +0100
Message-ID: <cc069c0375a79353917235d6bf5890821f075cad@8b5064a13e22126c1b9329f0dc35b8915774b7c3.invalid>
References: <201009032317.14954.linux@rainbow-software.org>
    <201009051901.13851.linux@rainbow-software.org>
    <20100905191412.GA10835@kroah.com>
    <201009052212.37015.linux@rainbow-software.org>
    <20100905210446.GA4472@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain;charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "Ondrej Zary" <linux@rainbow-software.org>,
	"David Brownell" <dbrownell@users.sourceforge.net>,
	netdev@vger.kernel.org,
	"Kernel development list" <linux-kernel@vger.kernel.org>
To: "Greg KH" <greg@kroah.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100905210446.GA4472@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, September 5, 2010 22:04, Greg KH wrote:
> On Sun, Sep 05, 2010 at 10:12:33PM +0200, Ondrej Zary wrote:
>> Ignore ADSL routers, which can have the same vendor and product IDs
>> as ADSL modems but should be handled by the cx82310_eth driver.
>>
>> This intentionally ignores device IDs that aren't currently handled
>> by cx82310_eth. There may be other device IDs that perhaps shouldn't
>> be claimed by cxacru.
>>
>> Signed-off-by: Ondrej Zary <linux@rainbow-software.org>

Missing Signed-off-by: you're modifying my changes.

>> --- linux-2.6.36-rc3-orig/drivers/usb/atm/cxacru.c	2010-08-29 17:36:04.000000000 +0200
>> +++ linux-2.6.36-rc3/drivers/usb/atm/cxacru.c	2010-09-05 18:54:56.000000000 +0200
>> @@ -1324,8 +1324,22 @@ static struct usbatm_driver cxacru_drive
>>  	.tx_padding	= 11,
>>  };
>>
>> -static int cxacru_usb_probe(struct usb_interface *intf, const struct usb_device_id *id)
>> -{
>> +static int cxacru_usb_probe(struct usb_interface *intf,
>> +		const struct usb_device_id *id) {
>
> Ick, what?

Sorry, this was my fault. I wasn't thinking when I changed it.

>> +	struct usb_device *usb_dev = interface_to_usbdev(intf);
>> +	char buf[15];
>> +
>> +	/* avoid ADSL routers (cx82310_eth)
>> +	 * abort if bDeviceClass is 0xff and iProduct is "USB NET CARD" */
>> +	if (usb_dev->descriptor.bDeviceClass == USB_CLASS_VENDOR_SPEC
>> +			&& usb_string(usb_dev, usb_dev->descriptor.iProduct,
>> +				buf, sizeof(buf)) > 0) {
>> +		if (!strcmp(buf, "USB NET CARD")) {
>> +			dev_info(&intf->dev, "ignoring cx82310_eth device\n");
>> +			return -ENODEV;
>> +		}
>> +	}
>
> In thinking about this a bit more, don't you also want to check the
> vendor and product id?  You can't always be sure about the string of any
> old device, right?

This is already checked using the driver's id_table.

I don't know if the vendor and product IDs for the cx82310_eth device should
be claimed by cxacru or not. Either Conexant are sharing IDs between devices,
or someone added it without confirming it works. There's no comment in the
code from 2003 explaining what device it's supposed to be. For this reason
I'd prefer to ignore all cxacru-claimed devices that appear to be an "USB NET
CARD", and log that it did so.

The 3 variants of the hardware I have all use an iProduct of "ADSL USB MODEM",
but I don't want to restrict cxacru to just that in case some devices have
different values.

-- 
Simon Arlott
