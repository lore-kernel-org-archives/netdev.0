From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: use of preempt_count instead of in_atomic() at leds-gpio.c
Date: Thu, 20 Mar 2008 20:17:23 -0700
Message-ID: <20080320201723.b87b3732.akpm@linux-foundation.org>
References: <20080320192719.6a32386e.akpm@linux-foundation.org>
	<Pine.LNX.4.44L0.0803202301140.16520-100000@netrider.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>,
	Henrique de Moraes Holschuh <hmh-N3TV7GIv+o9fyO9Q7EP/yw@public.gmane.org>,
	David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>,
	Richard Purdie <rpurdie-Fm38FmjxZ/leoWH0uzbU5w@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>,
	Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	<linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<video4linux-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Stefan Richter <stefanr-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org>,
	<lm-sensors-GZX6beZjE8VD60Wz+7aTrA@public.gmane.org>
To: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.44L0.0803202301140.16520-100000-pYrvlCTfrz9XsRXLowluHWD2FQJk+8+b@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 20 Mar 2008 23:07:16 -0400 (EDT) Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org> wrote:

> On Thu, 20 Mar 2008, Andrew Morton wrote:
> 
> > > > > Now, it happens that in_atomic() returns true on non-preemtible kernels
> > > > > when running in interrupt or softirq context.  But if the above code really
> > > > > is using in_atomic() to detect am-i-called-from-interrupt and NOT
> > > > > am-i-called-from-inside-spinlock, they should be using in_irq(),
> > > > > in_softirq() or in_interrupt().
> > > > 
> > > > Presumably most of these places are actually trying to detect 
> > > > am-i-allowed-to-sleep.  Isn't that what in_atomic() is supposed to do?  
> > > 
> > > No, I think there is no such check in the kernel. Most likely for performance
> > > reasons, as it would require a global flag that is set on each spinlock.
> > 
> > Yup.  non-preemptible kernels avoid the inc/dec of
> > current_thread_info->preempt_count on spin_lock/spin_unlock
> 
> So then what's the point of having in_atomic() at all?  Is it nothing 
> more than a shorthand form of (in_irq() | in_softirq() | 
> in_interrupt())?

in_atomic() is for core kernel use only.  Because in special circumstances
(ie: kmap_atomic()) we run inc_preempt_count() even on non-preemptible
kernels to tell the per-arch fault handler that it was invoked by
copy_*_user() inside kmap_atomic(), and it must fail.

> In short, you are saying that there is _no_ reliable way to determine
> am-i-called-from-inside-spinlock.

That's correct.

>  Well, why isn't there?

The reasons I identified: it adds additional overhead and it encourages
poorly-thought-out design.

Now we _could_ change kernel design principles from
caller-knows-whats-going-on over to callee-works-out-whats-going-on.  But
that would affect more than this particular thing.

>  Would it be 
> so terrible if non-preemptible kernels did adjust preempt_count on 
> spin_lock/unlock?

The vast, vast majority of kernel code has managed to get through life
without needing this hidden-argument-passing.  The handful of errant
callsites should be able to do so as well...

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
