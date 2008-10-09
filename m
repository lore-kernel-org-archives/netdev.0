From: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Subject: Re: small design problem with hso driver
Date: Thu, 09 Oct 2008 11:56:38 +0200
Message-ID: <48EDD556.1070508@option.com>
References: <48ECBB26.7080402@option.com>	<20081008174556.GA15387@kroah.com>	<48EDC887.8010403@option.com> <20081009103259.066cc94a@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>,
	Linux USB kernel mailing list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux netdev Mailing list <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Filip Aben <F.Aben-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>,
	Andrew Bird <ajb-5+cxppFmGx6/3pe1ocb+s/XRex20P6io@public.gmane.org>,
	Paul Hardwick <P.Hardwick-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20081009103259.066cc94a-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Alan,
No they are not.
Have a look at.
/drivers/char/nozomi.c
admittedly it's written by some of the same guys.
/* Called when the userspace process opens the tty, /dev/noz*.  */
static int ntty_open(struct tty_struct *tty, struct file *file)
{
	struct port *port = get_port_by_tty(tty);
	struct nozomi *dc = get_dc_by_tty(tty);
	unsigned long flags;

	if (!port || !dc || dc->state != NOZOMI_STATE_READY)
		return -ENODEV;

	if (mutex_lock_interruptible(&port->tty_sem))
		return -ERESTARTSYS;

	port->tty_open_count++;
	dc->open_ttys++;

	/* Enable interrupt downlink for channel */
	if (port->tty_open_count == 1) {
		tty->low_latency = 1;
		tty->driver_data = port;
		port->tty = tty;
		DBG1("open: %d", port->token_dl);
		spin_lock_irqsave(&dc->spin_mutex, flags);
		dc->last_ier = dc->last_ier | port->token_dl;
		writew(dc->last_ier, dc->reg_ier);
		spin_unlock_irqrestore(&dc->spin_mutex, flags);
	}

	mutex_unlock(&port->tty_sem);

	return 0;
}

/* Called when the userspace process close the tty, /dev/noz*. */
static void ntty_close(struct tty_struct *tty, struct file *file)
{
	struct nozomi *dc = get_dc_by_tty(tty);
	struct port *port = tty->driver_data;
	unsigned long flags;

	if (!dc || !port)
		return;

	if (mutex_lock_interruptible(&port->tty_sem))
		return;

	if (!port->tty_open_count)
		goto exit;

	dc->open_ttys--;
	port->tty_open_count--;

	if (port->tty_open_count == 0) {
		DBG1("close: %d", port->token_dl);
		spin_lock_irqsave(&dc->spin_mutex, flags);
		dc->last_ier &= ~(port->token_dl);
		writew(dc->last_ier, dc->reg_ier);
		spin_unlock_irqrestore(&dc->spin_mutex, flags);
	}

exit:
	mutex_unlock(&port->tty_sem);
}


Alan Cox wrote:
>> Surely if the driver returns an error code on hso_serial_open
>> hso_serial_close shouldn't be called
>> or have I a complete misunderstanding
>> of char driver semantics.
> 
> Generally yes that would be sane. The tty layer has always called the
> close method of drivers on a failed open and the drivers are all written
> assuming that.
> 
> It would be nice to change but there are far bigger fish to fry.
> 
> Alan


-- 
best regards,
D.J. Barrow
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
