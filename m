From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] USB: remove dbg() usage in USB networking drivers
Date: Wed, 19 Sep 2012 10:53:32 -0700
Message-ID: <1348077212.22122.13.camel@joe2Laptop>
References: <20120919171316.GA12248@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120919171316.GA12248@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-09-19 at 18:13 +0100, Greg Kroah-Hartman wrote:
> The dbg() USB macro is so old, it predates me.  The USB networking drivers are
> the last hold-out using this macro, and we want to get rid of it, so replace
> the usage of it with the proper netdev_dbg() or dev_dbg() (depending on the
> context) calls.

There's a missing newline.

There are several dev_err(&intf-dev, ...) to dev_err(dev, ...)
conversions.

Either those should be in a separate patch or you should mention
those changes in the commit message.

> diff --git a/drivers/net/usb/catc.c b/drivers/net/usb/catc.c
> index 26c5beb..6bf5672 100644
> --- a/drivers/net/usb/catc.c
> +++ b/drivers/net/usb/catc.c
> @@ -236,7 +236,8 @@ static void catc_rx_done(struct urb *urb)
>  	}
>  
>  	if (status) {
> -		dbg("rx_done, status %d, length %d", status, urb->actual_length);
> +		dev_dbg(&urb->dev->dev, "rx_done, status %d, length %d",
> +			status, urb->actual_length);

newline

> @@ -774,7 +783,7 @@ static int catc_probe(struct usb_interface *intf, const struct usb_device_id *id
>  
>  	if (usb_set_interface(usbdev,
>  			intf->altsetting->desc.bInterfaceNumber, 1)) {
> -                dev_err(&intf->dev, "Can't set altsetting 1.\n");
> +		dev_err(dev, "Can't set altsetting 1.\n");

?  Odd conversion.

> diff --git a/drivers/net/usb/kaweth.c b/drivers/net/usb/kaweth.c
[]
> @@ -787,7 +787,8 @@ static void kaweth_usb_transmit_complete(struct urb *urb)
>  
>  	if (unlikely(status != 0))
>  		if (status != -ENOENT)
> -			dbg("%s: TX status %d.", kaweth->net->name, status);
> +			dev_dbg(&urb->dev->dev, "%s: TX status %d.\n",
> +				kaweth->net->name, status);

probably
			netdev_dbg(kaweth->net, "TX status %d\n", status);

[] 

> @@ -1003,36 +1005,37 @@ static int kaweth_probe(
>  		const struct usb_device_id *id      /* from id_table */
>  	)
>  {
> -	struct usb_device *dev = interface_to_usbdev(intf);
> +	struct device *dev = &intf->dev;
> +	struct usb_device *udev = interface_to_usbdev(intf);

Miscellaneous renaming.

[]

> diff --git a/drivers/net/usb/net1080.c b/drivers/net/usb/net1080.c
> index 28c4d51..aad7abe 100644
> --- a/drivers/net/usb/net1080.c
> +++ b/drivers/net/usb/net1080.c
> @@ -156,11 +156,11 @@ static void nc_dump_registers(struct usbnet *dev)
>  	u16	*vp = kmalloc(sizeof (u16));
>  
>  	if (!vp) {
> -		dbg("no memory?");
> +		netdev_dbg(dev->net, "no memory?\n");

could delete altogether.
