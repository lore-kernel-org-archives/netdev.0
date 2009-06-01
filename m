From: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Subject: Re: [PATCH 09/10] ieee802154: add serial dongle driver
Date: Mon, 1 Jun 2009 16:27:32 +0100
Message-ID: <20090601162732.4a070c43@lxorguk.ukuu.org.uk>
References: <1243868091-5315-1-git-send-email-dbaryshkov@gmail.com>
	<1243868091-5315-2-git-send-email-dbaryshkov@gmail.com>
	<1243868091-5315-3-git-send-email-dbaryshkov@gmail.com>
	<1243868091-5315-4-git-send-email-dbaryshkov@gmail.com>
	<1243868091-5315-5-git-send-email-dbaryshkov@gmail.com>
	<1243868091-5315-6-git-send-email-dbaryshkov@gmail.com>
	<1243868091-5315-7-git-send-email-dbaryshkov@gmail.com>
	<1243868091-5315-8-git-send-email-dbaryshkov@gmail.com>
	<1243868091-5315-9-git-send-email-dbaryshkov@gmail.com>
	<1243868091-5315-10-git-send-email-dbaryshkov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org,
	maxim.osipov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org, dmitry.baryshkov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org,
	oliver.fendt-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org,
	Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1243868091-5315-10-git-send-email-dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> +	zbdev->pending_data = kzalloc(zbdev->pending_size, GFP_KERNEL);
> +	if (!zbdev->pending_data) {
> +		printk(KERN_ERR "%s(): unable to allocate memory\n", __func__);
> +		zbdev->pending_id = 0;
> +		zbdev->pending_size = 0;
> +		return -ENOMEM;
> +	}
> +	memcpy(zbdev->pending_data, buf, len);
> +
> +	return _send_pending_data(zbdev);

Where do you check that the tty has enough space ?


> +	case STATE_WAIT_COMMAND:
> +		if (is_command(c)) {
> +			zbdev->id = c;
> +			zbdev->state = STATE_WAIT_PARAM1;
> +		} else {
> +			cleanup(zbdev);
> +			printk(KERN_ERR "%s, unexpected command id: %x\n", __func__, c);

In all these ERR cases what stops a remote device from having fun spewing
garbage at you and filling the log ?

>
> +	 * channels 0-10 are not valid for us */
> +	BUG_ON(channel < 11 || channel > 26);
> +	/* ...  but our crappy firmware numbers channels from 1 to 16
> +	 * which is a mystery. We suould enforce that using PIB API
> +	 * but additional checking here won't kill, and gcc will
> +	 * optimize this stuff anyway. */
> +	BUG_ON((channel - 10) < 1 && (channel - 10) > 16);

Shouldn't be driver specific hacks in the ldisc surely - or is the ldisc
only applicable to a specific single bit of hardware ?

> + minor = tty->index + tty->driver->minor_start;
> +	zbdev->dev->parent = class_find_device(tty_class, NULL, &minor, dev_minor_match);
> +

That sort of thing shouldn't be buried in the depths of a driver. I'm not
entirely averse to that sort of thing but it belongs in a helper in the
tty layer.

> +	zbdev->tty = tty;

Refcounting ?

> +	cleanup(zbdev);
> +
> +	tty->disc_data = zbdev;
> +	tty->receive_room = MAX_DATA_SIZE;
> +	tty->low_latency = 1;

You can't go around mashing driver internal values - many drivers don't
support low_latency mode and this will make them crash.

> +
> +	/* FIXME: why is this needed. Note don't use ldisc_ref here as the
> +	   open path is before the ldisc is referencable */
> +

[Because otherwise after a SET_LDISC there may be bits from the old stuff
 left over - this one will go away as I finish the ldisc switching
 rewrite that is in the ttydev tree]

> +/*
> + * Called when the tty is put into another line discipline or it hangs up. We
> + * have to wait for any cpu currently executing in any of the other zb_tty_*
> + * routines to finish before we can call zb_tty_close and free the
> + * zb_serial_dev struct. This routine must be called from process context, not
> + * interrupt or softirq context.
> + */
> +static void
> +ieee802154_tty_close(struct tty_struct *tty)
> +{
> +	struct zb_device *zbdev;
> +
> +	zbdev = tty->disc_data;
> +	if (NULL == zbdev) {
> +		printk(KERN_WARNING "%s: match is not found\n", __func__);
> +		return;
> +	}
> +
> +	tty->disc_data = NULL;
> +	zbdev->tty = NULL;

Again you want a refcount on these I suspect. You may actually be safe
anyway but it would be cleaner to take/drop refs.



> +static int
> +ieee802154_tty_ioctl(struct tty_struct *tty, struct file *file, unsigned int cmd, unsigned long arg)
> +{
> +	struct zb_device *zbdev;
> +	struct ifreq ifr;
> +	int err;
> +	void __user *argp = (void __user *) arg;
> +
> +	pr_debug("cmd = 0x%x\n", cmd);
> +	memset(&ifr, 0, sizeof(ifr));
> +
> +	zbdev = tty->disc_data;
> +	if (NULL == zbdev) {
> +		pr_debug("match is not found\n");
> +		return -EINVAL;
> +	}

If that is NULL it's a serious bug so WARN on it I think

> +	default:
> +		pr_debug("Unknown ioctl cmd: %u\n", cmd);
> +		return -EINVAL;

This will break default ioctl processing. You probably want to call into
some of the generic handlers at this point depending upon your hardware.
Either way -EINVAL is wrong.

> +	}
> +	return 0;

Unreachable

> +static void
> +ieee802154_tty_receive(struct tty_struct *tty, const unsigned char *buf, char *cflags, int count)
> +{
> +	struct zb_device *zbdev;
> +	int i;
> +
> +	/* Debug info */
> +	printk(KERN_INFO "%lu %s, received %d bytes:", jiffies, __func__, count);
> +	for (i = 0; i < count; ++i)
> +		printk(KERN_CONT " 0x%02X", buf[i]);
> +	printk(KERN_CONT "\n");

I don't think the above is meant to be there....

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
