From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCH] usbnet: prevent device rpm suspend in usbnet_probe
 function
Date: Fri, 4 Nov 2016 09:26:20 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1611040923110.6787-100000@netrider.rowland.org>
References: <20161104095735.21071-1-kai.heng.feng@canonical.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: oneukum@suse.com, <netdev@vger.kernel.org>,
        <linux-usb@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Kai-Heng Feng <kai.heng.feng@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161104095735.21071-1-kai.heng.feng@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 4 Nov 2016, Kai-Heng Feng wrote:

> Sometimes cdc_mbim failed to probe if runtime pm is enabled:
> [    9.305626] cdc_mbim: probe of 2-2:1.12 failed with error -22
> 
> This can be solved by increase its pm usage counter.

This should not be needed.  The USB core increments the PM usage 
counter of a device before probing its interfaces.

Alan Stern

> Signed-off-by: Kai-Heng Feng <kai.heng.feng@canonical.com>
> ---
>  drivers/net/usb/usbnet.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> index d5071e3..f77b4bf 100644
> --- a/drivers/net/usb/usbnet.c
> +++ b/drivers/net/usb/usbnet.c
> @@ -1674,12 +1674,15 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
>  	net->watchdog_timeo = TX_TIMEOUT_JIFFIES;
>  	net->ethtool_ops = &usbnet_ethtool_ops;
>  
> +	if (usb_autopm_get_interface(dev->intf) < 0)
> +		goto out1;
> +
>  	// allow device-specific bind/init procedures
>  	// NOTE net->name still not usable ...
>  	if (info->bind) {
>  		status = info->bind (dev, udev);
>  		if (status < 0)
> -			goto out1;
> +			goto out2;
>  
>  		// heuristic:  "usb%d" for links we know are two-host,
>  		// else "eth%d" when there's reasonable doubt.  userspace
> @@ -1772,6 +1775,8 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
>  out3:
>  	if (info->unbind)
>  		info->unbind (dev, udev);
> +out2:
> +	usb_autopm_put_interface(dev->intf);
>  out1:
>  	/* subdrivers must undo all they did in bind() if they
>  	 * fail it, but we may fail later and a deferred kevent
> 
