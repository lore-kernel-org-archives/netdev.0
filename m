From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH 2/2] net/usb: hso: allocate serial_state_notification as
 separate buffer
Date: Wed, 07 Aug 2013 10:47:08 -0500
Message-ID: <1375890428.9837.3.camel@dcbw.foobar.com>
References: <20130807132902.14451.37517.stgit@localhost6.localdomain6>
	 <20130807132907.14451.2928.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-usb@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Jan Dumon <j.dumon@option.com>
To: Jussi Kivilinna <jussi.kivilinna@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60498 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756330Ab3HGPn5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Aug 2013 11:43:57 -0400
In-Reply-To: <20130807132907.14451.2928.stgit@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-08-07 at 16:29 +0300, Jussi Kivilinna wrote:
> URB transfer_buffers must not be allocated as part of larger structure because
> DMA coherence issues.
> 
> Patch changes hso to allocate serial_state_notification member of
> 'struct hso_tiocmget' as separate buffer.
> 
> Patch is only compile tested.

Tested-by: Dan Williams <dcbw@redhat.com>

> Cc: <stable@vger.kernel.org>
> Signed-off-by: Jussi Kivilinna <jussi.kivilinna@iki.fi>
> ---
>  drivers/net/usb/hso.c |   18 ++++++++++++++----
>  1 file changed, 14 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
> index fc082c0..21ffa6f 100644
> --- a/drivers/net/usb/hso.c
> +++ b/drivers/net/usb/hso.c
> @@ -211,7 +211,7 @@ struct hso_tiocmget {
>  	int    intr_completed;
>  	struct usb_endpoint_descriptor *endp;
>  	struct urb *urb;
> -	struct hso_serial_state_notification serial_state_notification;
> +	struct hso_serial_state_notification *serial_state_notification;
>  	u16    prev_UART_state_bitmap;
>  	struct uart_icount icount;
>  };
> @@ -1465,7 +1465,7 @@ static int tiocmget_submit_urb(struct hso_serial *serial,
>  			 usb_rcvintpipe(usb,
>  					tiocmget->endp->
>  					bEndpointAddress & 0x7F),
> -			 &tiocmget->serial_state_notification,
> +			 tiocmget->serial_state_notification,
>  			 sizeof(struct hso_serial_state_notification),
>  			 tiocmget_intr_callback, serial,
>  			 tiocmget->endp->bInterval);
> @@ -1499,7 +1499,7 @@ static void tiocmget_intr_callback(struct urb *urb)
>  	if (!tiocmget)
>  		return;
>  	usb = serial->parent->usb;
> -	serial_state_notification = &tiocmget->serial_state_notification;
> +	serial_state_notification = tiocmget->serial_state_notification;
>  	if (serial_state_notification->bmRequestType != BM_REQUEST_TYPE ||
>  	    serial_state_notification->bNotification != B_NOTIFICATION ||
>  	    le16_to_cpu(serial_state_notification->wValue) != W_VALUE ||
> @@ -2608,6 +2608,7 @@ static void hso_free_tiomget(struct hso_serial *serial)
>  		usb_free_urb(tiocmget->urb);
>  		tiocmget->urb = NULL;
>  		serial->tiocmget = NULL;
> +		kfree(tiocmget->serial_state_notification);
>  		kfree(tiocmget);
>  	}
>  }
> @@ -2664,6 +2665,13 @@ static struct hso_device *hso_create_bulk_serial_device(
>  		 */
>  		if (serial->tiocmget) {
>  			tiocmget = serial->tiocmget;
> +
> +			tiocmget->serial_state_notification = kzalloc(
> +				sizeof(struct hso_serial_state_notification),
> +				GFP_KERNEL);
> +			if (!tiocmget->serial_state_notification)
> +				goto tiocmget_fail;
> +
>  			tiocmget->urb = usb_alloc_urb(0, GFP_KERNEL);
>  			if (tiocmget->urb) {
>  				mutex_init(&tiocmget->mutex);
> @@ -2672,8 +2680,10 @@ static struct hso_device *hso_create_bulk_serial_device(
>  					interface,
>  					USB_ENDPOINT_XFER_INT,
>  					USB_DIR_IN);
> -			} else
> +			} else {
> +tiocmget_fail:
>  				hso_free_tiomget(serial);
> +			}
>  		}
>  	}
>  	else
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
