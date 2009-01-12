From: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Subject: Re: another race in hso
Date: Mon, 12 Jan 2009 17:35:37 +0100
Message-ID: <496B7159.3000500@option.com>
References: <200812221454.57794.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
To: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	Linux USB kernel mailing list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux netdev Mailing list <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200812221454.57794.oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Oliver,
Your patch fails in 3 places against 2.6.29-rc1,
The first place being hso_serial_tiocmget.
the spin_lock_irqsave is spin_lock_irq in my kernel sources.
What kernel is this patch supposed to apply against?

Oliver Neukum wrote:
> Am Freitag, 19. Dezember 2008 13:26:34 schrieb Chris Snook:
>> Denis Joseph Barrow wrote:
>>> Get Martin Schwidefsky to look over it.
>>> I hope he needs to write a 3g modem driver for linux on the z series anyway
>>> so he may as well get used to the code.
>> I hope they come out with one soon, so I can get that ultraportable mainframe 
>> I've been thinking about.
> 
> Hi,
> 
> if nobody has tested the last patch, don't bother. Here's a newer version.
> 
> 	Regards
> 		Oliver
> 
> ---
> diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
> index cc75c8b..52f12fb 100644
> --- a/drivers/net/usb/hso.c
> +++ b/drivers/net/usb/hso.c
> @@ -167,7 +167,6 @@ struct hso_net {
>  	struct sk_buff *skb_tx_buf;
>  
>  	enum pkt_parse_state rx_parse_state;
> -	spinlock_t net_lock;
>  
>  	unsigned short rx_buf_size;
>  	unsigned short rx_buf_missing;
> @@ -216,7 +215,6 @@ struct hso_serial {
>  	/* from usb_serial_port */
>  	struct tty_struct *tty;
>  	int open_count;
> -	spinlock_t serial_lock;
>  
>  	int (*write_data) (struct hso_serial *serial);
>  	/* Hacks required to get flow control
> @@ -238,10 +236,13 @@ struct hso_device {
>  
>  	u32 port_spec;
>  
> -	u8 is_active;
> -	u8 usb_gone;
> +	char is_active:1;
> +	char is_suspended:1;
> +	char is_elevated:1;
> +	char usb_gone:1;
>  	struct work_struct async_get_intf;
>  	struct work_struct async_put_intf;
> +	spinlock_t lock;
>  
>  	struct usb_device *usb;
>  	struct usb_interface *interface;
> @@ -642,7 +643,6 @@ static void log_usb_status(int status, const char *function)
>  static int hso_net_open(struct net_device *net)
>  {
>  	struct hso_net *odev = netdev_priv(net);
> -	unsigned long flags = 0;
>  
>  	if (!odev) {
>  		dev_err(&net->dev, "No net device !\n");
> @@ -652,11 +652,11 @@ static int hso_net_open(struct net_device *net)
>  	odev->skb_tx_buf = NULL;
>  
>  	/* setup environment */
> -	spin_lock_irqsave(&odev->net_lock, flags);
> +	spin_lock_irq(&odev->parent->lock);
>  	odev->rx_parse_state = WAIT_IP;
>  	odev->rx_buf_size = 0;
>  	odev->rx_buf_missing = sizeof(struct iphdr);
> -	spin_unlock_irqrestore(&odev->net_lock, flags);
> +	spin_unlock_irq(&odev->parent->lock);
>  
>  	/* We are up and running. */
>  	set_bit(HSO_NET_RUNNING, &odev->flags);
> @@ -708,7 +708,9 @@ static void write_bulk_callback(struct urb *urb)
>  	if (status)
>  		log_usb_status(status, __func__);
>  
> +	spin_lock(&odev->parent->lock);
>  	hso_put_activity(odev->parent);
> +	spin_unlock(&odev->parent->lock);
>  
>  	/* Tell the network interface we are ready for another frame */
>  	netif_wake_queue(odev->net);
> @@ -718,14 +720,26 @@ static void write_bulk_callback(struct urb *urb)
>  static int hso_net_start_xmit(struct sk_buff *skb, struct net_device *net)
>  {
>  	struct hso_net *odev = netdev_priv(net);
> -	int result;
> +	struct hso_device *pdev = odev->parent;
> +	int result = 0;
>  
>  	/* Tell the kernel, "No more frames 'til we are done with this one." */
>  	netif_stop_queue(net);
> -	if (hso_get_activity(odev->parent) == -EAGAIN) {
> -		odev->skb_tx_buf = skb;
> -		return 0;
> +
> +	usb_mark_last_busy(pdev->usb);
> +	spin_lock(&pdev->lock);
> +	if (!pdev->is_active) {
> +		if (!pdev->is_suspended) {
> +			pdev->is_active = 1;
> +		} else {
> +			odev->skb_tx_buf = skb;
> +			hso_get_activity(pdev);
> +			result = 1;
> +		}
>  	}
> +	spin_unlock(&pdev->lock);
> +	if (result)
> +		return 0;
>  
>  	/* log if asked */
>  	DUMP1(skb->data, skb->len);
> @@ -735,8 +749,8 @@ static int hso_net_start_xmit(struct sk_buff *skb, struct net_device *net)
>  
>  	/* Fill in the URB for shipping it out. */
>  	usb_fill_bulk_urb(odev->mux_bulk_tx_urb,
> -			  odev->parent->usb,
> -			  usb_sndbulkpipe(odev->parent->usb,
> +			  pdev->usb,
> +			  usb_sndbulkpipe(pdev->usb,
>  					  odev->out_endp->
>  					  bEndpointAddress & 0x7F),
>  			  odev->mux_bulk_tx_buf, skb->len, write_bulk_callback,
> @@ -748,7 +762,7 @@ static int hso_net_start_xmit(struct sk_buff *skb, struct net_device *net)
>  	/* Send the URB on its merry way. */
>  	result = usb_submit_urb(odev->mux_bulk_tx_urb, GFP_ATOMIC);
>  	if (result) {
> -		dev_warn(&odev->parent->interface->dev,
> +		dev_warn(&pdev->interface->dev,
>  			"failed mux_bulk_tx_urb %d", result);
>  		net->stats.tx_errors++;
>  		netif_start_queue(net);
> @@ -976,11 +990,11 @@ static void read_bulk_callback(struct urb *urb)
>  	if (urb->actual_length) {
>  		/* Handle the IP stream, add header and push it onto network
>  		 * stack if the packet is complete. */
> -		spin_lock(&odev->net_lock);
> +		spin_lock(&odev->parent->lock);
>  		packetizeRx(odev, urb->transfer_buffer, urb->actual_length,
>  			    (urb->transfer_buffer_length >
>  			     urb->actual_length) ? 1 : 0);
> -		spin_unlock(&odev->net_lock);
> +		spin_unlock(&odev->parent->lock);
>  	}
>  
>  	/* We are done with this URB, resubmit it. Prep the USB to wait for
> @@ -1167,17 +1181,17 @@ static void hso_std_serial_read_bulk_callback(struct urb *urb)
>  			}
>  		}
>  		/* Valid data, handle RX data */
> -		spin_lock(&serial->serial_lock);
> +		spin_lock(&serial->parent->lock);
>  		serial->rx_urb_filled[hso_urb_to_index(serial, urb)] = 1;
>  		put_rxbuf_data_and_resubmit_bulk_urb(serial);
> -		spin_unlock(&serial->serial_lock);
> +		spin_unlock(&serial->parent->lock);
>  	} else if (status == -ENOENT || status == -ECONNRESET) {
>  		/* Unlinked - check for throttled port. */
>  		D2("Port %d, successfully unlinked urb", serial->minor);
> -		spin_lock(&serial->serial_lock);
> +		spin_lock(&serial->parent->lock);
>  		serial->rx_urb_filled[hso_urb_to_index(serial, urb)] = 0;
>  		hso_resubmit_rx_bulk_urb(serial, urb);
> -		spin_unlock(&serial->serial_lock);
> +		spin_unlock(&serial->parent->lock);
>  	} else {
>  		D2("Port %d, status = %d for read urb", serial->minor, status);
>  		return;
> @@ -1192,12 +1206,12 @@ void hso_unthrottle_tasklet(struct hso_serial *serial)
>  {
>  	unsigned long flags;
>  
> -	spin_lock_irqsave(&serial->serial_lock, flags);
> +	spin_lock_irqsave(&serial->parent->lock, flags);
>  	if ((serial->parent->port_spec & HSO_INTF_MUX))
>  		put_rxbuf_data_and_resubmit_ctrl_urb(serial);
>  	else
>  		put_rxbuf_data_and_resubmit_bulk_urb(serial);
> -	spin_unlock_irqrestore(&serial->serial_lock, flags);
> +	spin_unlock_irqrestore(&serial->parent->lock, flags);
>  }
>  
>  static	void hso_unthrottle(struct tty_struct *tty)
> @@ -1322,7 +1336,7 @@ static int hso_serial_write(struct tty_struct *tty, const unsigned char *buf,
>  		return -ENODEV;
>  	}
>  
> -	spin_lock_irqsave(&serial->serial_lock, flags);
> +	spin_lock_irqsave(&serial->parent->lock, flags);
>  
>  	space = serial->tx_data_length - serial->tx_buffer_count;
>  	tx_bytes = (count < space) ? count : space;
> @@ -1334,7 +1348,7 @@ static int hso_serial_write(struct tty_struct *tty, const unsigned char *buf,
>  	serial->tx_buffer_count += tx_bytes;
>  
>  out:
> -	spin_unlock_irqrestore(&serial->serial_lock, flags);
> +	spin_unlock_irqrestore(&serial->parent->lock, flags);
>  
>  	hso_kick_transmit(serial);
>  	/* done */
> @@ -1348,9 +1362,9 @@ static int hso_serial_write_room(struct tty_struct *tty)
>  	int room;
>  	unsigned long flags;
>  
> -	spin_lock_irqsave(&serial->serial_lock, flags);
> +	spin_lock_irqsave(&serial->parent->lock, flags);
>  	room = serial->tx_data_length - serial->tx_buffer_count;
> -	spin_unlock_irqrestore(&serial->serial_lock, flags);
> +	spin_unlock_irqrestore(&serial->parent->lock, flags);
>  
>  	/* return free room */
>  	return room;
> @@ -1367,12 +1381,12 @@ static void hso_serial_set_termios(struct tty_struct *tty, struct ktermios *old)
>  		   tty->termios->c_cflag, old->c_cflag);
>  
>  	/* the actual setup */
> -	spin_lock_irqsave(&serial->serial_lock, flags);
> +	spin_lock_irqsave(&serial->parent->lock, flags);
>  	if (serial->open_count)
>  		_hso_serial_set_termios(tty, old);
>  	else
>  		tty->termios = old;
> -	spin_unlock_irqrestore(&serial->serial_lock, flags);
> +	spin_unlock_irqrestore(&serial->parent->lock, flags);
>  
>  	/* done */
>  	return;
> @@ -1389,9 +1403,9 @@ static int hso_serial_chars_in_buffer(struct tty_struct *tty)
>  	if (serial == NULL)
>  		return 0;
>  
> -	spin_lock_irqsave(&serial->serial_lock, flags);
> +	spin_lock_irqsave(&serial->parent->lock, flags);
>  	chars = serial->tx_buffer_count;
> -	spin_unlock_irqrestore(&serial->serial_lock, flags);
> +	spin_unlock_irqrestore(&serial->parent->lock, flags);
>  
>  	return chars;
>  }
> @@ -1408,10 +1422,10 @@ static int hso_serial_tiocmget(struct tty_struct *tty, struct file *file)
>  		return -EINVAL;
>  	}
>  
> -	spin_lock_irqsave(&serial->serial_lock, flags);
> +	spin_lock_irqsave(&serial->parent->lock, flags);
>  	value = ((serial->rts_state) ? TIOCM_RTS : 0) |
>  	    ((serial->dtr_state) ? TIOCM_DTR : 0);
> -	spin_unlock_irqrestore(&serial->serial_lock, flags);
> +	spin_unlock_irqrestore(&serial->parent->lock, flags);
>  
>  	return value;
>  }
> @@ -1431,7 +1445,7 @@ static int hso_serial_tiocmset(struct tty_struct *tty, struct file *file,
>  	}
>  	if_num = serial->parent->interface->altsetting->desc.bInterfaceNumber;
>  
> -	spin_lock_irqsave(&serial->serial_lock, flags);
> +	spin_lock_irqsave(&serial->parent->lock, flags);
>  	if (set & TIOCM_RTS)
>  		serial->rts_state = 1;
>  	if (set & TIOCM_DTR)
> @@ -1447,7 +1461,7 @@ static int hso_serial_tiocmset(struct tty_struct *tty, struct file *file,
>  	if (serial->rts_state)
>  		val |= 0x02;
>  
> -	spin_unlock_irqrestore(&serial->serial_lock, flags);
> +	spin_unlock_irqrestore(&serial->parent->lock, flags);
>  
>  	return usb_control_msg(serial->parent->usb,
>  			       usb_rcvctrlpipe(serial->parent->usb, 0), 0x22,
> @@ -1462,7 +1476,7 @@ static void hso_kick_transmit(struct hso_serial *serial)
>  	unsigned long flags;
>  	int res;
>  
> -	spin_lock_irqsave(&serial->serial_lock, flags);
> +	spin_lock_irqsave(&serial->parent->lock, flags);
>  	if (!serial->tx_buffer_count)
>  		goto out;
>  
> @@ -1470,7 +1484,8 @@ static void hso_kick_transmit(struct hso_serial *serial)
>  		goto out;
>  
>  	/* Wakeup USB interface if necessary */
> -	if (hso_get_activity(serial->parent) == -EAGAIN)
> +	hso_get_activity(serial->parent);
> +	if (serial->parent->is_suspended)
>  		goto out;
>  
>  	/* Switch pointers around to avoid memcpy */
> @@ -1487,7 +1502,7 @@ static void hso_kick_transmit(struct hso_serial *serial)
>  			serial->tx_urb_used = 1;
>  	}
>  out:
> -	spin_unlock_irqrestore(&serial->serial_lock, flags);
> +	spin_unlock_irqrestore(&serial->parent->lock, flags);
>  }
>  
>  /* make a request (for reading and writing data to muxed serial port) */
> @@ -1607,7 +1622,7 @@ static void intr_callback(struct urb *urb)
>  								   (1 << i));
>  			if (serial != NULL) {
>  				D1("Pending read interrupt on port %d\n", i);
> -				spin_lock(&serial->serial_lock);
> +				spin_lock(&serial->parent->lock);
>  				if (serial->rx_state == RX_IDLE) {
>  					/* Setup and send a ctrl req read on
>  					 * port i */
> @@ -1621,7 +1636,7 @@ static void intr_callback(struct urb *urb)
>  					D1("Already pending a read on "
>  					   "port %d\n", i);
>  				}
> -				spin_unlock(&serial->serial_lock);
> +				spin_unlock(&serial->parent->lock);
>  			}
>  		}
>  	}
> @@ -1655,9 +1670,9 @@ static void hso_std_serial_write_bulk_callback(struct urb *urb)
>  		return;
>  	}
>  
> -	spin_lock(&serial->serial_lock);
> +	spin_lock(&serial->parent->lock);
>  	serial->tx_urb_used = 0;
> -	spin_unlock(&serial->serial_lock);
> +	spin_unlock(&serial->parent->lock);
>  	if (status) {
>  		log_usb_status(status, __func__);
>  		return;
> @@ -1706,9 +1721,9 @@ static void ctrl_callback(struct urb *urb)
>  	if (!serial)
>  		return;
>  
> -	spin_lock(&serial->serial_lock);
> +	spin_lock(&serial->parent->lock);
>  	serial->tx_urb_used = 0;
> -	spin_unlock(&serial->serial_lock);
> +	spin_unlock(&serial->parent->lock);
>  	if (status) {
>  		log_usb_status(status, __func__);
>  		return;
> @@ -1724,9 +1739,9 @@ static void ctrl_callback(struct urb *urb)
>  	    (USB_DIR_IN | USB_TYPE_OPTION_VENDOR | USB_RECIP_INTERFACE)) {
>  		/* response to a read command */
>  		serial->rx_urb_filled[0] = 1;
> -		spin_lock(&serial->serial_lock);
> +		spin_lock(&serial->parent->lock);
>  		put_rxbuf_data_and_resubmit_ctrl_urb(serial);
> -		spin_unlock(&serial->serial_lock);
> +		spin_unlock(&serial->parent->lock);
>  	} else {
>  		hso_put_activity(serial->parent);
>  		if (serial->tty)
> @@ -1999,7 +2014,7 @@ static int hso_serial_common_create(struct hso_serial *serial, int num_urbs,
>  	/* fill in specific data for later use */
>  	serial->minor = minor;
>  	serial->magic = HSO_SERIAL_MAGIC;
> -	spin_lock_init(&serial->serial_lock);
> +	spin_lock_init(&serial->parent->lock);
>  	serial->num_rx_urbs = num_urbs;
>  
>  	/* RX, allocate urb and initialize */
> @@ -2140,9 +2155,6 @@ static void hso_net_init(struct net_device *net)
>  	net->mtu = DEFAULT_MTU - 14;
>  	net->tx_queue_len = 10;
>  	SET_ETHTOOL_OPS(net, &ops);
> -
> -	/* and initialize the semaphore */
> -	spin_lock_init(&hso_net->net_lock);
>  }
>  
>  /* Adds a network device in the network device table */
> @@ -2630,6 +2642,7 @@ static int hso_probe(struct usb_interface *interface,
>  		goto exit;
>  	}
>  
> +	spin_lock_init(&hso_dev->lock);
>  	usb_driver_claim_interface(&hso_driver, interface, hso_dev);
>  
>  	/* save our data pointer in this device */
> @@ -2669,38 +2682,36 @@ static void async_put_intf(struct work_struct *data)
>  
>  static int hso_get_activity(struct hso_device *hso_dev)
>  {
> -	if (hso_dev->usb->state == USB_STATE_SUSPENDED) {
> -		if (!hso_dev->is_active) {
> -			hso_dev->is_active = 1;
> -			schedule_work(&hso_dev->async_get_intf);
> -		}
> +	if (!hso_dev->is_elevated) {
> +		hso_dev->is_elevated = 1;
> +		schedule_work(&hso_dev->async_get_intf);
>  	}
> -
> -	if (hso_dev->usb->state != USB_STATE_CONFIGURED)
> -		return -EAGAIN;
> -
> -	usb_mark_last_busy(hso_dev->usb);
> -
>  	return 0;
>  }
>  
>  static int hso_put_activity(struct hso_device *hso_dev)
>  {
> -	if (hso_dev->usb->state != USB_STATE_SUSPENDED) {
> -		if (hso_dev->is_active) {
> -			hso_dev->is_active = 0;
> -			schedule_work(&hso_dev->async_put_intf);
> -			return -EAGAIN;
> -		}
> +	if (hso_dev->is_elevated) {
> +		hso_dev->is_elevated = 0;
> +		schedule_work(&hso_dev->async_put_intf);
>  	}
> -	hso_dev->is_active = 0;
>  	return 0;
>  }
>  
>  /* called by kernel when we need to suspend device */
>  static int hso_suspend(struct usb_interface *iface, pm_message_t message)
>  {
> -	int i, result;
> +	struct hso_device *pdev = usb_get_intfdata(iface);
> +	int i, result = 0;
> +
> +	spin_lock_irq(&pdev->lock);
> +	if (pdev->usb->auto_pm && pdev->is_active)
> +		result = -EBUSY;
> +	else
> +		pdev->is_suspended = 1;
> +	spin_unlock_irq(&pdev->lock);
> +	if (result)
> +		return result;
>  
>  	/* Stop all serial ports */
>  	for (i = 0; i < HSO_SERIAL_TTY_MINORS; i++) {
> @@ -2730,6 +2741,7 @@ static int hso_resume(struct usb_interface *iface)
>  {
>  	int i, result = 0;
>  	struct hso_net *hso_net;
> +	struct hso_device *pdev = usb_get_intfdata(iface);
>  
>  	/* Start all serial ports */
>  	for (i = 0; i < HSO_SERIAL_TTY_MINORS; i++) {
> @@ -2765,6 +2777,10 @@ static int hso_resume(struct usb_interface *iface)
>  	}
>  
>  out:
> +	spin_lock_irq(&pdev->lock);
> +	pdev->is_suspended = 0;
> +	spin_unlock_irq(&pdev->lock);
> +
>  	return result;
>  }
>  


-- 
best regards,
D.J. Barrow

Linux Kernel Developer
Option NV, Gaston Geenslaan 14, 3001 Leuven, Belgium
 
T: +32 16 311 621
F: +32 16 207 164
d.barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org
www.option.com

Disclaimer:
http://www.option.com/company/disclaimer.shtml
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
