From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH 1/2] smsc75xx: refactor entering suspend modes
Date: Tue, 27 Nov 2012 15:50:52 +0100
Message-ID: <87624r9k1f.fsf@nemi.mork.no>
References: <1354026482-10443-1-git-send-email-steve.glendinning@shawell.net>
	<1354026482-10443-2-git-send-email-steve.glendinning@shawell.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Steve Glendinning <steve.glendinning-nksJyM/082jR7s880joybQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1354026482-10443-2-git-send-email-steve.glendinning-nksJyM/082jR7s880joybQ@public.gmane.org>
	(Steve Glendinning's message of "Tue, 27 Nov 2012 14:28:01 +0000")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

I believe the drivers/net/usb patches should be CCed to linux-usb for
review, because they often touch USB specific things.  So I added that
CC and did not strip any of the quoted text.


Steve Glendinning <steve.glendinning-nksJyM/082jR7s880joybQ@public.gmane.org> writes:

> This patch splits out the logic for entering suspend modes
> to separate functions, to reduce the complexity of the
> smsc75xx_suspend function.
>
> Signed-off-by: Steve Glendinning <steve.glendinning-nksJyM/082jR7s880joybQ@public.gmane.org>
> ---
>  drivers/net/usb/smsc75xx.c |   62 +++++++++++++++++++++++++++-----------------
>  1 file changed, 38 insertions(+), 24 deletions(-)
>
> diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
> index 953c4f4..4655c01 100644
> --- a/drivers/net/usb/smsc75xx.c
> +++ b/drivers/net/usb/smsc75xx.c
> @@ -1213,6 +1213,42 @@ static int smsc75xx_write_wuff(struct usbnet *dev, int filter, u32 wuf_cfg,
>  	return 0;
>  }
>  
> +static int smsc75xx_enter_suspend0(struct usbnet *dev)
> +{
> +	u32 val;
> +	int ret;
> +
> +	ret = smsc75xx_read_reg_nopm(dev, PMT_CTL, &val);
> +	check_warn_return(ret, "Error reading PMT_CTL\n");
> +
> +	val &= (~(PMT_CTL_SUS_MODE | PMT_CTL_PHY_RST));
> +	val |= PMT_CTL_SUS_MODE_0 | PMT_CTL_WOL_EN | PMT_CTL_WUPS;
> +
> +	ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
> +	check_warn_return(ret, "Error writing PMT_CTL\n");
> +
> +	smsc75xx_set_feature(dev, USB_DEVICE_REMOTE_WAKEUP);

As mentioned in another comment to the smsc95xx driver: This is weird.
Do you really need to do that?

This is an USB interface driver.  The USB device is handled by the
generic "usb" driver, which will do the right thing.  See 
drivers/usb/generic.c and drivers/usb/core/hub.c


generic_suspend() calls usb_port_suspend() which does:

        /* enable remote wakeup when appropriate; this lets the device
         * wake up the upstream hub (including maybe the root hub).
         *
         * NOTE:  OTG devices may issue remote wakeup (or SRP) even when
         * we don't explicitly enable it here.
         */
        if (udev->do_remote_wakeup) {
                if (!hub_is_superspeed(hub->hdev)) {
                        status = usb_control_msg(udev, usb_sndctrlpipe(udev, 0),
                                        USB_REQ_SET_FEATURE, USB_RECIP_DEVICE,
                                        USB_DEVICE_REMOTE_WAKEUP, 0,
                                        NULL, 0,
                                        USB_CTRL_SET_TIMEOUT);
                } else {
                        /* Assume there's only one function on the USB 3.0
                         * device and enable remote wake for the first
                         * interface. FIXME if the interface association
                         * descriptor shows there's more than one function.
                         */
                        status = usb_control_msg(udev, usb_sndctrlpipe(udev, 0),
                                        USB_REQ_SET_FEATURE,
                                        USB_RECIP_INTERFACE,
                                        USB_INTRF_FUNC_SUSPEND,
                                        USB_INTRF_FUNC_SUSPEND_RW |
                                        USB_INTRF_FUNC_SUSPEND_LP,
                                        NULL, 0,
                                        USB_CTRL_SET_TIMEOUT);
                }




So you should not need to touch the USB device feature directly from your
interface driver.


> +
> +	return 0;
> +}
> +
> +static int smsc75xx_enter_suspend2(struct usbnet *dev)
> +{
> +	u32 val;
> +	int ret;
> +
> +	ret = smsc75xx_read_reg_nopm(dev, PMT_CTL, &val);
> +	check_warn_return(ret, "Error reading PMT_CTL\n");
> +
> +	val &= ~(PMT_CTL_SUS_MODE | PMT_CTL_WUPS | PMT_CTL_PHY_RST);
> +	val |= PMT_CTL_SUS_MODE_2;
> +
> +	ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
> +	check_warn_return(ret, "Error writing PMT_CTL\n");
> +
> +	return 0;
> +}
> +
>  static int smsc75xx_suspend(struct usb_interface *intf, pm_message_t message)
>  {
>  	struct usbnet *dev = usb_get_intfdata(intf);
> @@ -1244,17 +1280,7 @@ static int smsc75xx_suspend(struct usb_interface *intf, pm_message_t message)
>  		ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
>  		check_warn_return(ret, "Error writing PMT_CTL\n");
>  
> -		/* enter suspend2 mode */
> -		ret = smsc75xx_read_reg_nopm(dev, PMT_CTL, &val);
> -		check_warn_return(ret, "Error reading PMT_CTL\n");
> -
> -		val &= ~(PMT_CTL_SUS_MODE | PMT_CTL_WUPS | PMT_CTL_PHY_RST);
> -		val |= PMT_CTL_SUS_MODE_2;
> -
> -		ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
> -		check_warn_return(ret, "Error writing PMT_CTL\n");
> -
> -		return 0;
> +		return smsc75xx_enter_suspend2(dev);
>  	}
>  
>  	if (pdata->wolopts & (WAKE_MCAST | WAKE_ARP)) {
> @@ -1368,19 +1394,7 @@ static int smsc75xx_suspend(struct usb_interface *intf, pm_message_t message)
>  
>  	/* some wol options are enabled, so enter SUSPEND0 */
>  	netdev_info(dev->net, "entering SUSPEND0 mode\n");
> -
> -	ret = smsc75xx_read_reg_nopm(dev, PMT_CTL, &val);
> -	check_warn_return(ret, "Error reading PMT_CTL\n");
> -
> -	val &= (~(PMT_CTL_SUS_MODE | PMT_CTL_PHY_RST));
> -	val |= PMT_CTL_SUS_MODE_0 | PMT_CTL_WOL_EN | PMT_CTL_WUPS;
> -
> -	ret = smsc75xx_write_reg_nopm(dev, PMT_CTL, val);
> -	check_warn_return(ret, "Error writing PMT_CTL\n");
> -
> -	smsc75xx_set_feature(dev, USB_DEVICE_REMOTE_WAKEUP);
> -
> -	return 0;
> +	return smsc75xx_enter_suspend0(dev);
>  }
>  
>  static int smsc75xx_resume(struct usb_interface *intf)
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
