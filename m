From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net] cdc_ether: Fix handling connection notification
Date: Wed, 30 Nov 2016 22:51:16 +0100
Message-ID: <87shq83acr.fsf@miraculix.mork.no>
References: <20161130184216.4224-1-kristian.evensen@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: oliver@neukum.org, linux-usb@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        henning.schild@siemens.com
To: Kristian Evensen <kristian.evensen@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161130184216.4224-1-kristian.evensen@gmail.com> (Kristian
        Evensen's message of "Wed, 30 Nov 2016 19:42:16 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kristian Evensen <kristian.evensen@gmail.com> writes:

> +void usbnet_cdc_zte_status(struct usbnet *dev, struct urb *urb)
> +{
> +	struct usb_cdc_notification *event;
> +
> +	if (urb->actual_length < sizeof(*event))
> +		return;
> +
> +	event =3D urb->transfer_buffer;
> +
> +	if (event->bNotificationType !=3D USB_CDC_NOTIFY_NETWORK_CONNECTION) {
> +		usbnet_cdc_status(dev, urb);
> +		return;
> +	}
> +
> +	netif_dbg(dev, timer, dev->net, "CDC: carrier %s\n",
> +		  event->wValue ? "on" : "off");
> +
> +	if (event->wValue &&
> +	    !test_bit(__LINK_STATE_NOCARRIER, &dev->net->state))
> +		usbnet_link_change(dev, 0, 0);
> +
> +	usbnet_link_change(dev, !!event->wValue, 0);
> +}

As Henning said: Use netif_carrier_ok instead of open coding it.

But I also think you need to replace the first usbnet_link_change() with
a plain netif_carrier_off(dev->net).  Calling usbnet_link_change() twice
here is only going to set off the "kevent XX may have been dropped"
message since you call schedule_work() twice without giving the work
queue a chance to be processed.  No need to do that.


Bj=C3=B8rn
