From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: Re: [PATCH 09/10] ieee802154: add serial dongle driver
Date: Tue, 2 Jun 2009 00:29:47 +0400
Message-ID: <20090601202946.GB7143@doriath.ww600.siemens.net>
References: <1243868091-5315-2-git-send-email-dbaryshkov@gmail.com> <1243868091-5315-3-git-send-email-dbaryshkov@gmail.com> <1243868091-5315-4-git-send-email-dbaryshkov@gmail.com> <1243868091-5315-5-git-send-email-dbaryshkov@gmail.com> <1243868091-5315-6-git-send-email-dbaryshkov@gmail.com> <1243868091-5315-7-git-send-email-dbaryshkov@gmail.com> <1243868091-5315-8-git-send-email-dbaryshkov@gmail.com> <1243868091-5315-9-git-send-email-dbaryshkov@gmail.com> <1243868091-5315-10-git-send-email-dbaryshkov@gmail.com> <20090601162732.4a070c43@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, slapin@ossfans.org,
	maxim.osipov@siemens.com, dmitry.baryshkov@siemens.com,
	oliver.fendt@siemens.com
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:18299 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755641AbZFAUaA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2009 16:30:00 -0400
Content-Disposition: inline
In-Reply-To: <20090601162732.4a070c43@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the review, Alan,

On Mon, Jun 01, 2009 at 04:27:32PM +0100, Alan Cox wrote:
> > +	zbdev->pending_data = kzalloc(zbdev->pending_size, GFP_KERNEL);
> > +	if (!zbdev->pending_data) {
> > +		printk(KERN_ERR "%s(): unable to allocate memory\n", __func__);
> > +		zbdev->pending_id = 0;
> > +		zbdev->pending_size = 0;
> > +		return -ENOMEM;
> > +	}
> > +	memcpy(zbdev->pending_data, buf, len);
> > +
> > +	return _send_pending_data(zbdev);
> 
> Where do you check that the tty has enough space ?

Basically that means checking for ->write result, doesn't it?

> 
> 
> > +	case STATE_WAIT_COMMAND:
> > +		if (is_command(c)) {
> > +			zbdev->id = c;
> > +			zbdev->state = STATE_WAIT_PARAM1;
> > +		} else {
> > +			cleanup(zbdev);
> > +			printk(KERN_ERR "%s, unexpected command id: %x\n", __func__, c);
> 
> In all these ERR cases what stops a remote device from having fun spewing
> garbage at you and filling the log ?

And what stops your precious IDE controller from spewing garbage and
filling the log? Nothing I think. I'll lower the priority of the
messages though.

> > +	 * channels 0-10 are not valid for us */
> > +	BUG_ON(channel < 11 || channel > 26);
> > +	/* ...  but our crappy firmware numbers channels from 1 to 16
> > +	 * which is a mystery. We suould enforce that using PIB API
> > +	 * but additional checking here won't kill, and gcc will
> > +	 * optimize this stuff anyway. */
> > +	BUG_ON((channel - 10) < 1 && (channel - 10) > 16);
> 
> Shouldn't be driver specific hacks in the ldisc surely - or is the ldisc
> only applicable to a specific single bit of hardware ?

Currently it's applicable to only one (well, two) type of evkits from
FreeScale flashed with pretty much specific firmware. For other evkits
one have to write firmware on his own. Unlike bluetooth there is no
standard for such communication over serial proto. Also if there will be
any RS-232 device which implements IEEE 802.15.4 PHY layer and doesn't
follow this protocol, we can extend the ldisc to be more like hci-uart:
a multiplexor of protocols.

> > + minor = tty->index + tty->driver->minor_start;
> > +	zbdev->dev->parent = class_find_device(tty_class, NULL, &minor, dev_minor_match);
> > +
> 
> That sort of thing shouldn't be buried in the depths of a driver. I'm not
> entirely averse to that sort of thing but it belongs in a helper in the
> tty layer.

Fine with me. I'll move this into helper in tty layer.

> > +	zbdev->tty = tty;
> 
> Refcounting ?

Sample code? SLIP, hci-uart, ppp don't do it.

> > +	cleanup(zbdev);
> > +
> > +	tty->disc_data = zbdev;
> > +	tty->receive_room = MAX_DATA_SIZE;
> > +	tty->low_latency = 1;
> 
> You can't go around mashing driver internal values - many drivers don't
> support low_latency mode and this will make them crash.

C&P from drivers/bluetooth/hci-ldisc.c, around line 466. We had problems
working with low-latency unset.

> > +/*
> > + * Called when the tty is put into another line discipline or it hangs up. We
> > + * have to wait for any cpu currently executing in any of the other zb_tty_*
> > + * routines to finish before we can call zb_tty_close and free the
> > + * zb_serial_dev struct. This routine must be called from process context, not
> > + * interrupt or softirq context.
> > + */
> > +static void
> > +ieee802154_tty_close(struct tty_struct *tty)
> > +{
> > +	struct zb_device *zbdev;
> > +
> > +	zbdev = tty->disc_data;
> > +	if (NULL == zbdev) {
> > +		printk(KERN_WARNING "%s: match is not found\n", __func__);
> > +		return;
> > +	}
> > +
> > +	tty->disc_data = NULL;
> > +	zbdev->tty = NULL;
> 
> Again you want a refcount on these I suspect. You may actually be safe
> anyway but it would be cleaner to take/drop refs.

See above. Didn't see refounting in any of ldiscs checked.
That's not a 'no, I won't do it', but rather 'wait, all those are also
buggy ?!'

> > +static int
> > +ieee802154_tty_ioctl(struct tty_struct *tty, struct file *file, unsigned int cmd, unsigned long arg)
> > +{
> > +	struct zb_device *zbdev;
> > +	struct ifreq ifr;
> > +	int err;
> > +	void __user *argp = (void __user *) arg;
> > +
> > +	pr_debug("cmd = 0x%x\n", cmd);
> > +	memset(&ifr, 0, sizeof(ifr));
> > +
> > +	zbdev = tty->disc_data;
> > +	if (NULL == zbdev) {
> > +		pr_debug("match is not found\n");
> > +		return -EINVAL;
> > +	}
> 
> If that is NULL it's a serious bug so WARN on it I think

I tend to agree.


> > +	default:
> > +		pr_debug("Unknown ioctl cmd: %u\n", cmd);
> > +		return -EINVAL;
> 
> This will break default ioctl processing. You probably want to call into
> some of the generic handlers at this point depending upon your hardware.
> Either way -EINVAL is wrong.


n_tty_ioctl_helper ?

> > +static void
> > +ieee802154_tty_receive(struct tty_struct *tty, const unsigned char *buf, char *cflags, int count)
> > +{
> > +	struct zb_device *zbdev;
> > +	int i;
> > +
> > +	/* Debug info */
> > +	printk(KERN_INFO "%lu %s, received %d bytes:", jiffies, __func__, count);
> > +	for (i = 0; i < count; ++i)
> > +		printk(KERN_CONT " 0x%02X", buf[i]);
> > +	printk(KERN_CONT "\n");
> 
> I don't think the above is meant to be there....

In final version, it will go away.

-- 
With best wishes
Dmitry

