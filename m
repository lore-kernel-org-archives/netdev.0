From: Marius Kotsbak <marius.kotsbak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] net/usb: Add Samsung Kalmia driver for Samsung GT-B3730
Date: Tue, 14 Jun 2011 11:32:00 +0200
Message-ID: <4DF72A90.1070702@gmail.com>
References: <20110611200625.GB14582@kroah.com> <1307829318-18246-1-git-send-email-marius@kotsbak.com> <201106141049.39150.oneukum@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	format=flowed
Content-Transfer-Encoding: 7BIT
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Marius B. Kotsbak" <marius-iy5w9mehe2BBDgjK7y7TUQ@public.gmane.org>
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201106141049.39150.oneukum-l3A5Bk7waGM@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Den 14. juni 2011 10:49, skrev Oliver Neukum:
> Am Samstag, 11. Juni 2011, 23:55:18 schrieb Marius B. Kotsbak:
>
>> +static int
>> +kalmia_init_and_get_ethernet_addr(struct usbnet *dev, u8 *ethernet_addr)
>> +{
>> +	char init_msg_1[] =
>> +		{ 0x57, 0x50, 0x04, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00,
>> +		0x00, 0x00 };
>> +	char init_msg_2[] =
>> +		{ 0x57, 0x50, 0x04, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0xf4,
>> +		0x00, 0x00 };
>> +	char receive_buf[28];
> You are doing DMA on the stack. This will fail on some architectures.
>

Okay, a bit strange that this API is available then. Which API functions 
should be used in this case?

>> +	int status;
>> +
>> +	status = kalmia_send_init_packet(dev, init_msg_1, sizeof(init_msg_1)
>> +		/ sizeof(init_msg_1[0]), receive_buf, 24);
>> +	if (status != 0)
>> +		return status;
>> +
>> +	status = kalmia_send_init_packet(dev, init_msg_2, sizeof(init_msg_2)
>> +		/ sizeof(init_msg_2[0]), receive_buf, 28);
>> +	if (status != 0)
>> +		return status;
>> +
>> +	memcpy(ethernet_addr, receive_buf + 10, ETH_ALEN);
>> +
>> +	return status;
>> +}
>> +
>> +static int
>> +kalmia_bind(struct usbnet *dev, struct usb_interface *intf)
>> +{
>> +	u8 status;
>> +	u8 ethernet_addr[ETH_ALEN];
>> +
>> +	/* Don't bind to AT command interface */
>> +	if (intf->cur_altsetting->desc.bInterfaceClass != USB_CLASS_VENDOR_SPEC)
>> +		return -EINVAL;
>> +
>> +	dev->in = usb_rcvbulkpipe(dev->udev, 0x81&  USB_ENDPOINT_NUMBER_MASK);
>> +	dev->out = usb_sndbulkpipe(dev->udev, 0x02&  USB_ENDPOINT_NUMBER_MASK);
>> +	dev->status = NULL;
>> +
>> +	dev->net->hard_header_len += KALMIA_HEADER_LENGTH;
>> +	dev->hard_mtu = 1400;
>> +	dev->rx_urb_size = dev->hard_mtu * 10; // Found as optimal after testing
>> +
>> +	status = kalmia_init_and_get_ethernet_addr(dev, ethernet_addr);
>> +
>> +	if (status<  0) {
>> +		usb_set_intfdata(intf, NULL);
>> +		usb_driver_release_interface(driver_of(intf), intf);
>> +		return status;
> Why are you doing this? What is to be undone?

You mean the 3 last lines? I just did the same as done in another 
similar usbnet based driver. Is it incorrect if the init fails?

>> +	}
>> +
>> +	memcpy(dev->net->dev_addr, ethernet_addr, ETH_ALEN);
>> +	memcpy(dev->net->perm_addr, ethernet_addr, ETH_ALEN);
>> +
>> +	return status;
>> +}
>> +
>> +static struct sk_buff *
>> +kalmia_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags)
>> +{
>> +	struct sk_buff *skb2 = NULL;
>> +	u16 content_len;
>> +	unsigned char *header_start;
>> +	unsigned char ether_type_1, ether_type_2;
>> +	u8 remainder, padlen = 0;
>> +
>> +	if (!skb_cloned(skb)) {
>> +		int headroom = skb_headroom(skb);
>> +		int tailroom = skb_tailroom(skb);
>> +
>> +		if ((tailroom>= KALMIA_ALIGN_SIZE)&&  (headroom
>> +			>= KALMIA_HEADER_LENGTH))
>> +			goto done;
>> +
>> +		if ((headroom + tailroom)>  (KALMIA_HEADER_LENGTH
>> +			+ KALMIA_ALIGN_SIZE)) {
>> +			skb->data = memmove(skb->head + KALMIA_HEADER_LENGTH,
>> +				skb->data, skb->len);
>> +			skb_set_tail_pointer(skb, skb->len);
>> +			goto done;
>> +		}
>> +	}
>> +
>> +	skb2 = skb_copy_expand(skb, KALMIA_HEADER_LENGTH,
>> +		KALMIA_ALIGN_SIZE, flags);
>> +	if (!skb2)
>> +		return NULL;
>> +
>> +	dev_kfree_skb_any(skb);
>> +	skb = skb2;
>> +
>> +	done: header_start = skb_push(skb, KALMIA_HEADER_LENGTH);
> coding style

The last line? I see.

>> +	ether_type_1 = header_start[KALMIA_HEADER_LENGTH + 12];
>> +	ether_type_2 = header_start[KALMIA_HEADER_LENGTH + 13];
>> +
>> +	netdev_dbg(dev->net, "Sending etherType: %02x%02x", ether_type_1,
>> +		ether_type_2);
>> +
>> +	/* According to empiric data for data packages */
>> +	header_start[0] = 0x57;
>> +	header_start[1] = 0x44;
>> +	content_len = skb->len - KALMIA_HEADER_LENGTH;
>> +	header_start[2] = (content_len&  0xff); /* low byte */
>> +	header_start[3] = (content_len>>  8); /* high byte */
> Please use an endianness macro

Wil fix. It will be very relevant to support other architectures for 
this driver, as I want to run it on a ARM based NAS as LTE router.

>> +	header_start[4] = ether_type_1;
>> +	header_start[5] = ether_type_2;
>> +
>> +	/* Align to 4 bytes by padding with zeros */
>> +	remainder = skb->len % KALMIA_ALIGN_SIZE;
>> +	if (remainder>  0) {
>> +		padlen = KALMIA_ALIGN_SIZE - remainder;
>> +		memset(skb_put(skb, padlen), 0, padlen);
>> +	}
>> +
>> +	netdev_dbg(
>> +		dev->net,
>> +		"Sending package with length %i and padding %i. Header: %02x:%02x:%02x:%02x:%02x:%02x.",
>> +		content_len, padlen, header_start[0], header_start[1],
>> +		header_start[2], header_start[3], header_start[4],
>> +		header_start[5]);
>> +
>> +	return skb;
>> +}
>> +
>> +static int
>> +kalmia_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
>> +{
>> +	/*
>> +	 * Our task here is to strip off framing, leaving skb with one
>> +	 * data frame for the usbnet framework code to process.
>> +	 */
>> +	const u8 HEADER_END_OF_USB_PACKET[] =
>> +		{ 0x57, 0x5a, 0x00, 0x00, 0x08, 0x00 };
>> +	const u8 EXPECTED_UNKNOWN_HEADER_1[] =
>> +		{ 0x57, 0x43, 0x1e, 0x00, 0x15, 0x02 };
>> +	const u8 EXPECTED_UNKNOWN_HEADER_2[] =
>> +		{ 0x57, 0x50, 0x0e, 0x00, 0x00, 0x00 };
> What does the compiler do to this declaration?

Not sure I understand what you mean here.

>> +	u8 i = 0;
> Why not int?

I can change that. Thought int was not to be used because it is of 
unknown size.
>> +
>> +	/* incomplete header? */
>> +	if (skb->len<  KALMIA_HEADER_LENGTH)
>> +		return 0;
>> +
>> +	do {
>> +		struct sk_buff *skb2 = NULL;
>> +		u8 *header_start;
>> +		u16 usb_packet_length, ether_packet_length;
>> +		int is_last;
>> +
>> +		header_start = skb->data;
>> +
>> +		if (unlikely(header_start[0] != 0x57 || header_start[1] != 0x44)) {
>> +			if (!memcmp(header_start, EXPECTED_UNKNOWN_HEADER_1,
>> +				sizeof(EXPECTED_UNKNOWN_HEADER_1)) || !memcmp(
>> +				header_start, EXPECTED_UNKNOWN_HEADER_2,
>> +				sizeof(EXPECTED_UNKNOWN_HEADER_2))) {
>> +				netdev_dbg(
>> +					dev->net,
>> +					"Received expected unknown frame header: %02x:%02x:%02x:%02x:%02x:%02x. Package length: %i\n",
>> +					header_start[0], header_start[1],
>> +					header_start[2], header_start[3],
>> +					header_start[4], header_start[5],
>> +					skb->len - KALMIA_HEADER_LENGTH);
>> +			}
>> +			else {
>> +				netdev_err(
>> +					dev->net,
>> +					"Received unknown frame header: %02x:%02x:%02x:%02x:%02x:%02x. Package length: %i\n",
>> +					header_start[0], header_start[1],
>> +					header_start[2], header_start[3],
>> +					header_start[4], header_start[5],
>> +					skb->len - KALMIA_HEADER_LENGTH);
>> +				return 0;
>> +			}
>> +		}
>> +		else
>> +			netdev_dbg(
>> +				dev->net,
>> +				"Received header: %02x:%02x:%02x:%02x:%02x:%02x. Package length: %i\n",
>> +				header_start[0], header_start[1], header_start[2],
>> +				header_start[3], header_start[4], header_start[5],
>> +				skb->len - KALMIA_HEADER_LENGTH);
>> +
>> +		/* subtract start header and end header */
>> +		usb_packet_length = skb->len - (2 * KALMIA_HEADER_LENGTH);
>> +		ether_packet_length = header_start[2] + (header_start[3]<<  8);
> Please use an endianness macro

Oki.
>> +		skb_pull(skb, KALMIA_HEADER_LENGTH);
>> +
>> +		/* Some small packets misses end marker */
>> +		if (usb_packet_length<  ether_packet_length) {
>> +			ether_packet_length = usb_packet_length
>> +				+ KALMIA_HEADER_LENGTH;
>> +			is_last = true;
>> +		}
>> +		else {
>> +			netdev_dbg(dev->net, "Correct package length #%i", i
>> +				+ 1);
>> +
>> +			is_last = (memcmp(skb->data + ether_packet_length,
>> +				HEADER_END_OF_USB_PACKET,
>> +				sizeof(HEADER_END_OF_USB_PACKET)) == 0);
>> +			if (!is_last) {
>> +				header_start = skb->data + ether_packet_length;
>> +				netdev_dbg(
>> +					dev->net,
>> +					"End header: %02x:%02x:%02x:%02x:%02x:%02x. Package length: %i\n",
>> +					header_start[0], header_start[1],
>> +					header_start[2], header_start[3],
>> +					header_start[4], header_start[5],
>> +					skb->len - KALMIA_HEADER_LENGTH);
>> +			}
>> +		}
>> +
>> +		if (is_last) {
>> +			skb2 = skb;
>> +		}
>> +		else {
>> +			skb2 = skb_clone(skb, GFP_ATOMIC);
>> +			if (unlikely(!skb2))
>> +				return 0;
>> +		}
>> +
>> +		skb_trim(skb2, ether_packet_length);
>> +
>> +		if (is_last) {
>> +			return 1;
>> +		}
>> +		else {
>> +			usbnet_skb_return(dev, skb2);
>> +			skb_pull(skb, ether_packet_length);
>> +		}
>> +
>> +		i++;
>> +	}
>> +	while (skb->len);
>> +
>> +	return 1;
>> +}
>> +
>> +static const struct driver_info kalmia_info = {
>> +	.description = "Samsung Kalmia LTE USB dongle",
>> +	.flags = FLAG_WWAN,
>> +	.bind = kalmia_bind,
>> +	.rx_fixup = kalmia_rx_fixup,
>> +	.tx_fixup = kalmia_tx_fixup
>> +};
>> +
>> +/*-------------------------------------------------------------------------*/
>> +
>> +static const struct usb_device_id products[] = {
>> +	/* The unswitched USB ID, to get the module auto loaded: */
>> +	{ USB_DEVICE(0x04e8, 0x689a) },
> Why is this needed? Doesn't the switch trigger an autoload?

Please see the comment from Dan Williams. Will test his proposal.

Anyway it should not do any damage for anyone (I think even the driver 
disk is available with this included). The module could in fact also do 
the switch into modem mode to avoid the dependency on usb_modeswitch.

--
Marius


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
