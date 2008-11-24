From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: respin of hso patches for linux-2.6.28-rc6 hso_close_fix.patch [patch 2/6 ]
Date: Mon, 24 Nov 2008 17:45:49 +0100
Message-ID: <FBF372EF-F4F8-479B-B2E7-0E93D96B252B@holtmann.org>
References: <492ABD5A.4000006@option.com>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Linux USB kernel mailing list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux netdev Mailing list <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <492ABD5A.4000006-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Denis,

> Moved serial_open_count in hso_serial_open to
> prevent crashes owing to the serial structure being made NULL
> when hso_serial_close is called even though hso_serial_open
> returned -ENODEV, Alan Cox pointed out this happens,
> also put in sanity check in hso_serial_close
> to check for a valid serial structure which should prevent
> the most reproducable crash in the driver when the hso device
> is disconnected while in use.
> Signed-off-by: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
> ---
> Index: linux-2.6.28-rc6.patches/drivers/net/usb/hso.c
> ===================================================================
> --- linux-2.6.28-rc6.patches.orig/drivers/net/usb/hso.c	2008-11-24  
> 14:01:45.000000000 +0100
> +++ linux-2.6.28-rc6.patches/drivers/net/usb/hso.c	2008-11-24  
> 14:10:15.000000000 +0100
> @@ -1235,6 +1235,11 @@
> 	}
>
> 	mutex_lock(&serial->parent->mutex);
> +	/* check for port already opened, if not set the termios */
> +	/* The serial->open count needs to be here as hso_serial_close
> +	 *  will be called even if hso_serial_open returns -ENODEV.
> +	 */
> +	serial->open_count++;
> 	result = usb_autopm_get_interface(serial->parent->interface);
> 	if (result < 0)
> 		goto err_out;
> @@ -1246,8 +1251,6 @@
> 	tty->driver_data = serial;
> 	serial->tty = tty;
>
> -	/* check for port already opened, if not set the termios */
> -	serial->open_count++;
> 	if (serial->open_count == 1) {
> 		tty->low_latency = 1;
> 		serial->rx_state = RX_IDLE;
> @@ -1285,6 +1288,10 @@
> 	u8 usb_gone;
>
> 	D1("Closing serial port");
> +	if (serial == NULL || serial->magic != HSO_SERIAL_MAGIC) {
> +		D1("invalid serial structure bailing out.\n");
> +		return;
> +	}

using !serial instead of serial == NULL would be better.

Regards

Marcel

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
