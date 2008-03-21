From: Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Subject: Re: use of preempt_count instead of in_atomic() at leds-gpio.c
Date: Fri, 21 Mar 2008 14:47:50 +0100
Message-ID: <20080321134750.GB4128@osiris.boeblingen.de.ibm.com>
References: <Pine.LNX.4.44L0.0803202126240.11234-100000@netrider.rowland.org> <200803210236.52063.mb@bu3sch.de> <20080320192719.6a32386e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	Henrique de Moraes Holschuh <hmh-N3TV7GIv+o9fyO9Q7EP/yw@public.gmane.org>,
	David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>,
	Richard Purdie <rpurdie-Fm38FmjxZ/leoWH0uzbU5w@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>,
	Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	video4linux-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	Stefan Richter <stefanr-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org>,
	lm-sensors-GZX6beZjE8VD60Wz+7aTrA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080320192719.6a32386e.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 20, 2008 at 07:27:19PM -0700, Andrew Morton wrote:
> On Fri, 21 Mar 2008 02:36:51 +0100 Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org> wrote:
> > On Friday 21 March 2008 02:31:44 Alan Stern wrote:
> > > On Thu, 20 Mar 2008, Andrew Morton wrote:
> > > > On Thu, 20 Mar 2008 21:36:04 -0300 Henrique de Moraes Holschuh <hmh-N3TV7GIv+o9fyO9Q7EP/yw@public.gmane.org> wrote:
> > > > 
> > > > > Well, so far so good for LEDs, but what about the other users of in_atomic
> > > > > that apparently should not be doing it either?
> > > > 
> > > > Ho hum.  Lots of cc's added.
> > > 
> > > ...
> > > 
> > > > The usual pattern for most of the above is
> > > > 
> > > > 	if (!in_atomic())
> > > > 		do_something_which_might_sleep();
> > > > 
> > > > problem is, in_atomic() returns false inside spinlock on non-preptible
> > > > kernels.  So if anyone calls those functions inside spinlock they will
> > > > incorrectly schedule and another task can then come in and try take the
> > > > already-held lock.
> > > > 
> > > > Now, it happens that in_atomic() returns true on non-preemtible kernels
> > > > when running in interrupt or softirq context.  But if the above code really
> > > > is using in_atomic() to detect am-i-called-from-interrupt and NOT
> > > > am-i-called-from-inside-spinlock, they should be using in_irq(),
> > > > in_softirq() or in_interrupt().
> > > 
> > > Presumably most of these places are actually trying to detect 
> > > am-i-allowed-to-sleep.  Isn't that what in_atomic() is supposed to do?  
> > 
> > No, I think there is no such check in the kernel. Most likely for performance
> > reasons, as it would require a global flag that is set on each spinlock.
> 
> Yup.  non-preemptible kernels avoid the inc/dec of
> current_thread_info->preempt_count on spin_lock/spin_unlock
> 
> > You simply must always _know_, if you are allowed to sleep or not. This is
> > done by defining an API. The call-context is part of any kernel API.
> 
> Yup.  99.99% of kernel code manages to do this...

This is difficult for console drivers. They get called and are supposed to
print something and don't have the slightest clue which context they are
running in and if they are allowed to schedule.
This is the problem with e.g. s390's sclp driver. If there are no write
buffers available anymore it tries to allocate memory if schedule is allowed
or otherwise has to wait until finally a request finished and memory is
available again.
And now we have to always busy wait if we are out of buffers, since we
cannot tell which context we are in?
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
