From: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Subject: Re: [PATCH] lan78xx: Protect runtime_auto check by #ifdef CONFIG_PM
Date: Tue, 22 Mar 2016 10:21:44 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1603221014500.1793-100000@iolanthe.rowland.org>
References: <1458640209.1990.8.camel@suse.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>,
	Microchip Linux Driver Support <UNGLinuxDriver-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org>,
	Woojung Huh <woojung.huh-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-LthD3rsA81gm4RdzfppkhA@public.gmane.org>,
	Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1458640209.1990.8.camel-IBi9RG/b67k@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 22 Mar 2016, Oliver Neukum wrote:

> On Mon, 2016-03-21 at 15:30 -0400, Alan Stern wrote:
> > On Mon, 21 Mar 2016, Oliver Neukum wrote:
> > 
> 
> > > We have an autosuspend timeout because we think that IO, if it will
> > > come at all, is likeliest to come soon. If, however, the IO is
> > > periodic that heuristics is false.
> > > To save most power the driver must either decide that the interval
> > > is too short or suspend immediately. So if we are lucky enough
> > > to have the frequency in the kernel, we should use that information.
> > 
> > The autosuspend timeout is set by userspace.  The kernel may assign a
> 
> Thus it should apply to all IO originating in user space.
> But only to that IO.

Fair enough.

> > default value, but the user can always override it.  Given this, I 
> > don't see how the kernel can use frequency information (and I'm not 
> > sure where that information would come from in the first place).
> 
> It can ignore internal IO for the purpose of the timeout.
> If such IO is performed while the device is active, don't
> alter the timer.

Come to think of it, we don't.  If pm_runtime_get_sync() and then
pm_runtime_put() are called while the device is already at full power, 
the PM core doesn't update the last_busy time.  So if the driver 
doesn't update it either, the statistics collection won't interfere 
with autosuspend (except when it races with the autosuspend timer 
expiration).

> Otherwise resume the device and look at
> the provided hint and suspend again immediately if the period is long
> enough.

I don't see any point in resuming the device just in order to collect 
operating statistics.  If it was already suspended then it wasn't 
operating, so there will be no statistics to collect.

> If IO is generated periodically in the kernel, the kernel must know that
> period.

Alan Stern

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
