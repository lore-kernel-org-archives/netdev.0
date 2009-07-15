From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] USB host CDC Phonet network interface driver
Date: Wed, 15 Jul 2009 16:20:31 +0200
Message-ID: <200907151620.31509.oliver@neukum.org>
References: <1247666341-7121-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "=?utf-8?q?R=C3=A9mi?= Denis-Courmont"
	<remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1247666341-7121-1-git-send-email-remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Mittwoch, 15. Juli 2009 15:59:01 schrieb R=C3=A9mi Denis-Courmont:

Hello,

> +	netif_stop_queue(dev);
> +	if (atomic_inc_return(&pnd->tx_queue) < dev->tx_queue_len)
> +		netif_wake_queue(dev);

This is unelegant.


> +	err =3D usb_set_interface(pnd->usb, num, pnd->active_setting);
> +	if (err)
> +		return err;
> +
> +	for (i =3D 0; i < rxq_size; i++) {
> +		struct urb *req =3D usb_alloc_urb(0, GFP_KERNEL);
> +
> +		if (req && rx_submit(pnd, req, GFP_KERNEL)) {
> +			usb_free_urb(req);
> +			req =3D NULL;
> +		}
> +		pnd->urbs[i] =3D req;
> +	}

You should fail if you cannot get a minimum number of URBs running.
> +
> +	netif_wake_queue(dev);
> +	return 0;
> +}
[..]
> +	/* Endpoints */
> +	if ((data_desc->endpoint[0].desc.bEndpointAddress & USB_DIR_IN) =3D=
=3D
> +			USB_DIR_IN) {

Please use the macro.

> +		pnd->rx_pipe =3D usb_rcvbulkpipe(usbdev,
> +			data_desc->endpoint[0].desc.bEndpointAddress);
> +		pnd->tx_pipe =3D usb_sndbulkpipe(usbdev,
> +			data_desc->endpoint[1].desc.bEndpointAddress);
> +	} else {
> +		pnd->rx_pipe =3D usb_rcvbulkpipe(usbdev,
> +			data_desc->endpoint[1].desc.bEndpointAddress);
> +		pnd->tx_pipe =3D usb_sndbulkpipe(usbdev,
> +			data_desc->endpoint[0].desc.bEndpointAddress);
> +	}
> +	pnd->active_setting =3D data_desc - data_intf->altsetting;
> +
> +	err =3D usb_driver_claim_interface(&usbpn_driver, data_intf, pnd);
> +	if (err)
> +		goto out;
> +
> +	/* Force inactive mode until the network device is brought UP */
> +	usb_set_interface(usbdev, union_header->bSlaveInterface0,
> +				!pnd->active_setting);
> +	usb_set_intfdata(intf, pnd);
> +	BUG_ON(!usb_get_intfdata(intf));

What for?

> +
> +	err =3D register_netdev(dev);
> +	if (err) {
> +		usb_driver_release_interface(&usbpn_driver, data_intf);
> +		goto out;
> +	}
> +
> +	dev_dbg(&dev->dev, "USB CDC Phonet device found\n");
> +	return 0;
> +
> +out:
> +	usb_set_intfdata(intf, NULL);
> +	free_netdev(dev);
> +	return err;
> +}
> +
> +static void usbpn_disconnect(struct usb_interface *intf)
> +{
> +	struct usbpn_dev *pnd =3D usb_get_intfdata(intf);
> +

What happens if this happens in the unexpected order?

> +	if (intf !=3D pnd->data_intf) {
> +		usb_driver_release_interface(&usbpn_driver, pnd->data_intf);
> +		return;
> +	}
> +
> +	unregister_netdev(pnd->dev);
> +	usb_put_dev(pnd->usb);
> +}

	Regards
		Oliver

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
