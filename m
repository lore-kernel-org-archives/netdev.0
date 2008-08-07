From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 09/12] pegasus: add blacklist support to fix Belkin bluetooth
 dongle.
Date: Thu, 07 Aug 2008 02:24:09 -0400
Message-ID: <489A9509.90306@garzik.org>
References: <200807301939.m6UJd2PA012599@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ben.collins@canonical.com,
	david-b@pacbell.net, gregkh@suse.de, stefan.bader@canonical.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53825 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755963AbYHGGYO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Aug 2008 02:24:14 -0400
In-Reply-To: <200807301939.m6UJd2PA012599@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Ben Collins <ben.collins@canonical.com>
> 
> Reference: https://launchpad.net/bugs/140511
> 
> The Belkin bluetooth dongle unfortunately shares the vendor and device id
> with the network adapter which causes lockups whenever the bluetooth
> dongle is inserted.
> 
> Signed-off-by: Stefan Bader <stefan.bader@canonical.com>
> Signed-off-by: Ben Collins <ben.collins@canonical.com>
> Cc: Jeff Garzik <jeff@garzik.org>
> Cc: Greg Kroah-Hartman <gregkh@suse.de>
> Cc: David Brownell <david-b@pacbell.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/usb/pegasus.c |   21 +++++++++++++++++++++
>  1 file changed, 21 insertions(+)
> 
> diff -puN drivers/net/usb/pegasus.c~pegasus-add-blacklist-support-to-fix-belkin-bluetooth-dongle drivers/net/usb/pegasus.c
> --- a/drivers/net/usb/pegasus.c~pegasus-add-blacklist-support-to-fix-belkin-bluetooth-dongle
> +++ a/drivers/net/usb/pegasus.c
> @@ -1285,6 +1285,21 @@ static void check_carrier(struct work_st
>  	}
>  }
>  
> +static int pegasus_blacklisted(struct usb_device *udev)
> +{
> +	struct usb_device_descriptor *udd = &udev->descriptor;
> +
> +	/* Special quirk to keep the driver from handling the Belkin Bluetooth
> +	 * dongle which happens to have the same ID.
> +	 */
> +	if ((udd->idVendor == VENDOR_BELKIN && udd->idProduct == 0x0121) &&
> +	    (udd->bDeviceClass == USB_CLASS_WIRELESS_CONTROLLER) &&
> +	    (udd->bDeviceProtocol == 1))
> +		return 1;
> +
> +	return 0;
> +}
> +
>  static int pegasus_probe(struct usb_interface *intf,
>  			 const struct usb_device_id *id)
>  {
> @@ -1296,6 +1311,12 @@ static int pegasus_probe(struct usb_inte
>  	DECLARE_MAC_BUF(mac);
>  
>  	usb_get_dev(dev);
> +
> +	if (pegasus_blacklisted(dev)) {
> +		res = -ENODEV;
> +		goto out;
> +	}
> +

applied


