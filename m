From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v2 2/3] net: usb: cdc_enc: New driver exposing USB CDC encapsulated protocols
Date: Sun, 15 Jan 2012 14:36:29 +0100
Message-ID: <201201151436.29794.oliver@neukum.org>
References: <cover.1326607234.git.bjorn@mork.no> <d11888532ee381806b35974e71af4c0122255c05.1326607234.git.bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Thomas =?utf-8?q?Sch=C3=A4fer?= <tschaefer-zqRNUXuvxA0b1SvskN2V4Q@public.gmane.org>
To: =?utf-8?q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <d11888532ee381806b35974e71af4c0122255c05.1326607234.git.bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Sonntag, 15. Januar 2012, 07:40:36 schrieb Bj=C3=B8rn Mork:
> USB CDC Ethernet devices may encapsulate vendor specific protocols in=
side
> USB_CDC_SEND_ENCAPSULATED_COMMAND +USB_CDC_GET_ENCAPSULATED_RESPONSE
> control messages. Devices based on Qualcomm MSM
> chipsets are known to use this for exporting the Qualcomm
> MSM Interface (QMI) protocol. Examples of such devices are
> the Huawei E392 and E398 LTE modems.

The problem is that this is another version of the code already
in cdc-wdm, which is tested well.
I'd really like to unify this stuff.

> +static ssize_t cdc_enc_fops_read(struct file *file, char __user *buf=
, size_t size, loff_t *pos)
> +{
> +	struct cdc_enc_client *client =3D file->private_data;
> +	int ret =3D -EFAULT;
> +
> +	if (!client || !client->cdc_enc)
> +		return -ENODEV;
> +
> +	while (!test_bit(CDC_ENC_CLIENT_RX, &client->flags)) {/* no data */
> +		if (file->f_flags & O_NONBLOCK)
> +			return -EAGAIN;
> +
> +		if (wait_for_completion_interruptible(&client->ready) < 0)
> +			return -EINTR;
> +
> +		/* shutdown requested? */
> +		if (test_bit(CDC_ENC_CLIENT_SHUTDOWN, &client->flags))
> +			return -ENXIO;
> +	}
> +
> +	/* someone else is using our buffer */
> +	if (test_and_set_bit(CDC_ENC_CLIENT_BUSY, &client->flags))
> +		return -ERESTARTSYS;
> +
> +	/* must read a complete packet */
> +	if (client->len > size || copy_to_user(buf, client->buf, client->le=
n)) {

This is not nice at all.

> +		ret =3D -EFAULT;
> +		goto err;
> +	}
> +	ret =3D client->len;
> +
> +err:
> +	/* order is important! */
> +	clear_bit(CDC_ENC_CLIENT_RX, &client->flags);
> +	clear_bit(CDC_ENC_CLIENT_BUSY, &client->flags);

If order is important here, you need write barriers.
And read barriers at another place.

> +	return ret;
> +}
> +
> +static ssize_t cdc_enc_fops_write(struct file *file, const char __us=
er *buf, size_t size, loff_t *pos)
> +{
> +	struct cdc_enc_client *client =3D file->private_data;
> +	int ret =3D -EFAULT;
> +
> +	if (!client || !client->cdc_enc)
> +		return -ENODEV;
> +
> +	/* shutdown requested? */
> +	if (test_bit(CDC_ENC_CLIENT_SHUTDOWN, &client->flags))
> +		return -ENXIO;
> +
> +	/* no meaning in attempting to send an incomplete packet */
> +	if (size > sizeof(client->tx_buf))
> +		return -EFAULT;
> +
> +	/* are someone else using our buffer? */
> +	if (test_and_set_bit(CDC_ENC_CLIENT_TX, &client->flags))
> +		return -ERESTARTSYS;
> +
> +	if (size > sizeof(client->tx_buf) || copy_from_user(client->tx_buf,=
 buf, size))
> +		goto err;
> +
> +	/* send to the device */
> +	ret =3D cdc_enc_send_sync(client, client->tx_buf, size);
> +	if (ret < 0)
> +		return -EFAULT;

Error handling is shot. The device is now eternally busy.

> +static int cdc_enc_fops_open(struct inode *inode, struct file *file)
> +{
> +	struct cdc_enc_state *cdc_enc;
> +	struct cdc_enc_client *client;
> +
> +	/* associate the file with our backing CDC_ENC device */
> +	cdc_enc =3D container_of(inode->i_cdev, struct cdc_enc_state, cdev)=
;
> +	if (!cdc_enc)
> +		return -ENODEV;
> +
> +	/* don't allow interface to sleep while we are using it */
> +	usb_autopm_get_interface(cdc_enc->intf);

This can fail.

> +	/* enable status URB even if networking is down */
> +	cdc_enc_status_urb(cdc_enc, GFP_KERNEL);
> +
> +	/* set up a ring buffer to receive our readable data? */
> +	client =3D cdc_enc_add_client(cdc_enc, cdc_enc_newdata_rcvd);
> +
> +	if (!client)
> +		return -ENOMEM;

Error handling. The device now can never again autosuspend.

> +
> +	file->private_data =3D client;
> +	return 0;
> +}

[..]
> +/* disable and free a CDC_ENC state device */
> +int cdc_enc_free_one(struct cdc_enc_state *cdc_enc)
> +{
> +	struct cdc_enc_client *tmp;
> +
> +	/* kill any pending recv urb */
> +	cdc_enc_kill_readurb(cdc_enc);
> +
> +	/* wait for all clients to exit first ... */
> +	list_for_each_entry(tmp, &cdc_enc->clients, list) {
> +		dev_dbg(&cdc_enc->intf->dev, "waiting for client %p to die\n", tmp=
);
> +		set_bit(CDC_ENC_CLIENT_SHUTDOWN, &tmp->flags);
> +		complete(&tmp->ready);
> +	}
> +	wait_event_interruptible(cdc_enc->waitq, list_empty(&cdc_enc->clien=
ts));

If you wait interruptably, you need to handle being interrupted.

> +
> +/* per CDC_ENC interface state */
> +struct cdc_enc_state {
> +	struct usb_interface *intf;
> +	struct urb *urb;		/* receive urb */
> +	struct urb *interrupt;		/* interrupt urb */
> +	unsigned char rcvbuf[CDC_ENC_BUFLEN];     /* receive buffer */

This is a violation of the DMA requirements. You must use kmalloc.

I had a not very detailed look at this driver, but I would really prefe=
r
if you could have a look at making unified code for this, cdc-wdm and c=
dc-acm.

	Regards
		Oliver
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
