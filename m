From: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
Subject: Re: [PATCH net 2/3] r8152: fix remote wakeup
Date: Thu, 23 Jul 2015 10:30:58 +0200
Message-ID: <1437640258.4377.6.camel@suse.com>
References: <1394712342-15778-148-Taiwan-albertk@realtek.com>
	 <1394712342-15778-150-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394712342-15778-150-Taiwan-albertk-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-07-23 at 15:09 +0800, Hayes Wang wrote:
> Set needs_remote_wakeup only when the device supports it.
> 
> Signed-off-by: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
> ---
>  drivers/net/usb/r8152.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
> index e3a0110..eff1f25 100644
> --- a/drivers/net/usb/r8152.c
> +++ b/drivers/net/usb/r8152.c
> @@ -4059,7 +4059,8 @@ static int rtl8152_probe(struct usb_interface *intf,
>  		break;
>  	}
>  
> -	intf->needs_remote_wakeup = 1;
> +	if (udev->actconfig->desc.bmAttributes & USB_CONFIG_ATT_WAKEUP)
> +		intf->needs_remote_wakeup = 1;

Hi,

this is most likely wrong. Usbcore does check for a device's ability to
do remote wakeup and will block a runtime suspend if it detects that
a remote wakeup would be required but the device cannot deliver.
(static int autosuspend_check())

So by removing the flag in the probe() method means that devices will
suspend during operations without remote wakeup requested. Thus an
incoming packet cannot wake them up.

If you remove setting the flag on probe() you need to set it at open()
[and reset on close()], as devices which cannot do remote wakeup must
only be suspended when they are down.

	Regards
		Oliver



--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
