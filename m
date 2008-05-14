From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: HSO: add option hso driver
Date: Wed, 14 May 2008 19:36:00 +0200
Message-ID: <1210786560.7025.0.camel@violet.holtmann.net>
References: <20080513215134.GC6139@kroah.com>
	 <20080513232727.21c74bb2@core> <482A23B8.7050705@pobox.com>
	 <20080514015815.GA29785@kroah.com> <20080514045712.GA2843@kroah.com>
	 <482AF058.3020505@teltonika.lt>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <482AF058.3020505-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Paulius,

> > +/* called once for each interface upon device insertion */
> > +static int hso_probe(struct usb_interface *interface,
> > +		     const struct usb_device_id *id)
> > +{
> > +	int mux, i, if_num, port_spec;
> > +	unsigned char port_mask;
> > +	struct hso_device *hso_dev = NULL;
> > +	struct hso_shared_int *shared_int;
> > +	struct hso_device *tmp_dev = NULL;
> > +
> > +	if_num = interface->altsetting->desc.bInterfaceNumber;
> > +
> > +	/* Get the interface/port specification from either driver_info or from
> > +	 * the device itself */
> > +	if (id->driver_info)
> > +		port_spec = ((u32 *)(id->driver_info))[if_num];
> > +	else
> > +		port_spec = hso_get_config_data(interface);
> > +
> > +	if (interface->cur_altsetting->desc.bInterfaceClass != 0xFF) {
> > +		dev_err(&interface->dev, "Not our interface\n");
> > +		return -ENODEV;
> > +	}
> > +	/* Check if we need to switch to alt interfaces prior to port
> > +	 * configuration */
> > +	if (interface->num_altsetting > 1)
> > +		usb_set_interface(interface_to_usbdev(interface), if_num, 1);
> > +	interface->needs_remote_wakeup = 1;
> > +
> > +	/* Allocate new hso device(s) */
> > +	switch (port_spec & HSO_INTF_MASK) {
> > +	case HSO_INTF_MUX:
> > +		if ((port_spec & HSO_PORT_MASK) == HSO_PORT_NETWORK) {
> > +			/* Create the network device */
> > +			if (!disable_net) {
> > +				hso_dev = hso_create_net_device(interface);
> > +				if (!hso_dev)
> > +					goto exit;
> > +				tmp_dev = hso_dev;
> > +			}
> > +		}
> > +
> > +		if (hso_get_mux_ports(interface, &port_mask))
> > +			/* TODO: de-allocate everything */
> > +			goto exit;
> > +
> > +		shared_int = hso_create_shared_int(interface);
> > +		if (!shared_int)
> > +			goto exit;
> > +
> > +		for (i = 1, mux = 0; i < 0x100; i = i << 1, mux++) {
> > +			if (port_mask & i) {
> > +				hso_dev = hso_create_mux_serial_device(
> > +						interface, i, shared_int);
> > +				if (!hso_dev)
> > +					goto exit;
> > +			}
> > +		}
> > +
> > +		if (tmp_dev)
> > +			hso_dev = tmp_dev;
> > +		break;
> > +
> > +	case HSO_INTF_BULK:
> > +		/* It's a regular bulk interface */
> > +		if (((port_spec & HSO_PORT_MASK) == HSO_PORT_NETWORK)
> > +		    && !disable_net)
> > +			hso_dev = hso_create_net_device(interface);
> > +		else
> > +			hso_dev =
> > +			    hso_create_bulk_serial_device(interface, port_spec);
> > +		if (!hso_dev)
> > +			goto exit;
> > +		break;
> > +	default:
> > +		goto exit;
> > +	}
> > +
> > +	usb_driver_claim_interface(&hso_driver, interface, hso_dev);
> 
> Is usb_driver_claim_interface really needed?

no it is not. That can be removed.

Regards

Marcel


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
