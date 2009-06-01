From: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Subject: Re: [PATCH 09/10] ieee802154: add serial dongle driver
Date: Mon, 1 Jun 2009 22:52:05 +0100
Message-ID: <20090601225205.1e7e8944@lxorguk.ukuu.org.uk>
References: <1243868091-5315-2-git-send-email-dbaryshkov@gmail.com>
	<1243868091-5315-3-git-send-email-dbaryshkov@gmail.com>
	<1243868091-5315-4-git-send-email-dbaryshkov@gmail.com>
	<1243868091-5315-5-git-send-email-dbaryshkov@gmail.com>
	<1243868091-5315-6-git-send-email-dbaryshkov@gmail.com>
	<1243868091-5315-7-git-send-email-dbaryshkov@gmail.com>
	<1243868091-5315-8-git-send-email-dbaryshkov@gmail.com>
	<1243868091-5315-9-git-send-email-dbaryshkov@gmail.com>
	<1243868091-5315-10-git-send-email-dbaryshkov@gmail.com>
	<20090601162732.4a070c43@lxorguk.ukuu.org.uk>
	<20090601202946.GB7143@doriath.ww600.siemens.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org,
	maxim.osipov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org, dmitry.baryshkov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org,
	oliver.fendt-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org
To: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090601202946.GB7143-nIupHZaCssqR2kOLt6zJ8ErlnG4Plg33XqFh9Ls21Oc@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> > > +	return _send_pending_data(zbdev);
> > 
> > Where do you check that the tty has enough space ?
> 
> Basically that means checking for ->write result, doesn't it?

You should check write_room before writing if you want some control - you
can also then respect internal flow control via the wakeup mechanism.

Something like:
                /* Wait for space */
                while ((space = tty_write_room(tty)) < len) {
                        if (file->f_flags & O_NONBLOCK) {
                                err = -EAGAIN;
                                break;
                        }
                        interruptible_sleep_on(&tty->write_wait);
                        if (signal_pending(current)) {
                                err = -EINTR;
                                break;
                        }
                }
                /* Shove the entire frame down */
                tty->ops->write(tty, data, len);
 
> > In all these ERR cases what stops a remote device from having fun spewing
> > garbage at you and filling the log ?
> 
> And what stops your precious IDE controller from spewing garbage and
> filling the log? Nothing I think. I'll lower the priority of the
> messages though.

The fact the drive is entirely under my control and not potentially being
spewed at from a hostile network. Also the fact that it takes about 30
seconds to spank a misbehaving drive and reset it. The network laye
generally uses time checks (search for ratelimit()).

> any RS-232 device which implements IEEE 802.15.4 PHY layer and doesn't
> follow this protocol, we can extend the ldisc to be more like hci-uart:
> a multiplexor of protocols.

Ok

> > > +	zbdev->tty = tty;
> > 
> > Refcounting ?
> 
> Sample code? SLIP, hci-uart, ppp don't do it.

No I'm still running around clobbering them all - and slip needed a
partial rewrite first.

	zbdev->tty = tty_kref_get(tty);

	tty_kref_put(foo);

> > You can't go around mashing driver internal values - many drivers don't
> > support low_latency mode and this will make them crash.
> 
> C&P from drivers/bluetooth/hci-ldisc.c, around line 466. We had problems
> working with low-latency unset.

The bluetooth one needs killing too. I will do that tomorrow ...

How many releases ago - the entire tty buffering layer has been rewritten
over time. tty->low_latency requires driver specific support that most
don't have. Also as of 2.6.30rc you'll get debug spew if you misuse it.

If you still need it we need to know why.


> That's not a 'no, I won't do it', but rather 'wait, all those are also
> buggy ?!'

The tty layer has a lot of "yes, those are also buggy" - which is why I'm
currently half way through systematically brutalising it.


> > > +	default:
> > > +		pr_debug("Unknown ioctl cmd: %u\n", cmd);
> > > +		return -EINVAL;
> > 
> > This will break default ioctl processing. You probably want to call into
> > some of the generic handlers at this point depending upon your hardware.
> > Either way -EINVAL is wrong.
> 
> 
> n_tty_ioctl_helper ?

That depends what you need. tty_mode_ioctl() gives you all the mode
stuff, n_tty_ioctl_helper adds things like software flow management which
don't actually look relevant to your ldisc ?

Any other queries let me know, and if the tty->low_latency is still
needed let me know and we'll figure out why between us, as it should not
be.

Alan
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
