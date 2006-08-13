From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] zd1211rw: Convert installer CDROM device into WLAN device
Date: Sun, 13 Aug 2006 11:31:31 +0200
Message-ID: <200608131131.31693.mb@bu3sch.de>
References: <20060812165953.4E84E8E7773@zog.reactivated.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org, kune@deine-taler.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:58771
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1750854AbWHMJcq
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Aug 2006 05:32:46 -0400
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <20060812165953.4E84E8E7773@zog.reactivated.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 12 August 2006 18:59, Daniel Drake wrote:
> +static int eject_installer(struct usb_interface *intf)
> +{
> +	struct usb_device *udev = interface_to_usbdev(intf);
> +	struct usb_host_interface *iface_desc = &intf->altsetting[0];
> +	struct usb_endpoint_descriptor *endpoint;
> +	unsigned char *cmd;
> +	u8 bulk_out_ep;
> +	int r;
> +
> +	/* Find bulk out endpoint */
> +	endpoint = &iface_desc->endpoint[1].desc;
> +	if ((endpoint->bEndpointAddress & USB_TYPE_MASK) == USB_DIR_OUT &&
> +	    (endpoint->bmAttributes & USB_ENDPOINT_XFERTYPE_MASK) ==
> +	    USB_ENDPOINT_XFER_BULK) {
> +		bulk_out_ep = endpoint->bEndpointAddress;
> +	} else {
> +		dev_err(&udev->dev,
> +			"zd1211rw: Could not find bulk out endpoint\n");
> +		return -ENODEV;
> +	}
> +
> +	cmd = kzalloc(31, GFP_KERNEL);
> +	if (cmd == NULL)
> +		return -ENODEV;
> +
> +	/* USB bulk command block */
> +	cmd[0] = 0x55;	/* bulk command signature */
> +	cmd[1] = 0x53;	/* bulk command signature */
> +	cmd[2] = 0x42;	/* bulk command signature */
> +	cmd[3] = 0x43;	/* bulk command signature */
> +	cmd[14] = 6;	/* command length */
> +
> +	cmd[15] = 0x1b;	/* SCSI command: START STOP UNIT */
> +	cmd[19] = 0x2;	/* eject disc */
> +
> +	dev_info(&udev->dev, "Ejecting virtual installer media...\n");
> +	r = usb_bulk_msg(udev, usb_sndbulkpipe(udev, bulk_out_ep),
> +		cmd, 31, NULL, 2000);

Does usb_bulk_msg kfree cmd, or are we leaking it here?

> +	if (r)
> +		return r;
> +
> +	/* At this point, the device disconnects and reconnects with the real
> +	 * ID numbers. */
> +
> +	usb_set_intfdata(intf, NULL);
> +	return 0;
> +}

-- 
Greetings Michael.
