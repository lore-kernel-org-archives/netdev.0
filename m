From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/2] [RFC] posix clock tuning
Date: Mon, 6 Sep 2010 09:09:51 +0200
Message-ID: <20100906070951.GB4549@riccoc20.at.omicron.at>
References: <cover.1283504065.git.richard.cochran@omicron.at>
 <alpine.DEB.2.00.1009041221240.888@router.home>
 <4C828652.4060804@gmail.com>
 <alpine.DEB.2.00.1009042042130.9425@router.home>
 <20100905062240.GB2699@riccoc20.at.omicron.at>
 <20100905072041.GA2928@riccoc20.at.omicron.at>
 <alpine.DEB.2.00.1009051759100.3480@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christian Riesch <christian.riesch-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, john stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
To: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1009051759100.3480-sBS69tsa9Uj/9pzu0YdTqQ@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

(Taking John Stultz on CC.)

On Sun, Sep 05, 2010 at 06:13:33PM -0500, Christoph Lameter wrote:
> On Sun, 5 Sep 2010, Richard Cochran wrote:
> > When I get some more time, I'll try to put together an executive
> > summary of PTP and of all the discussions that have taken place over
> > the last few months on linux-netdev and the lkml.
> 
> I know PTP,

Ah, thats good.

> I just dont know why you would need to extend the existing
> apis for support. Maybe you could just simply write a PTP clock driver? If

That is what I already did in this patch set:

   http://lkml.org/lkml/2010/8/16/90

However, people asked, why not just use the posix clock API?  And so,
I implemented that idea, too. Now the question is, which API is the
better choice. I like the posix clock idea, but I am also fine with
the character device. That was my original approach.

> you follow the way hpet is implemented then you dont even need a clock id.
> See drivers/char/hpet.c. I cannot imagine why someone would want to set
> PTP to a different time and speed (vs. realtime not the hardware
> configuration) than the standard clock. The API you proposed so far is
> not needed as far as I can tell.

No one wants to set a different time, but the fact remains that we
have two separate clocks. The two clocks need to be synchronized, but
how do you do this?

My idea was this. Simply use the PPS subsystem to synchronize the
Linux system time to the PTP time in the PTP hardware clock. That is
just like using a GPS or radio clock. The only requirement is that the
hardware clocks provides one interrupt.

It will happen that some hardware will be build without any interrupt
between the PTP hardware clock and the CPU. Even so, such a setup can
still be useful, for example in an embedded control application. The
userland software can simply ignore the wrong system time. I think the
PTP hardware clock infrastructure should be rich enough to support
this situation.

> I really would like a PTP clock as soon as possible. Very very important
> for time sync via the network.

Good, me too!
 
> Then there is CLOCK_SGI_CYCLE. Another hw clock that can be set and gotten
> already with the standard posix interface. See drivers/char/mmtimer.c. The
> main benefit from CLOCK_SGI_CYCLE is that you can set it manually (maybe
> you want an offset to realtime? But I do not know of any usecase for
> setting the clock) and that the clock can cause hardware IRQ events
> to cause timer timers in user space (would be great to know if PTP needs
> this?).

Some PTP hardware clocks provide interrupts to the main CPU. These can
used to implement a PPS input, user alarms, and user timers.

> I would not think that PTP needs any of this specialized functionality.

Well, to make the super-synchronized time in the PTP hardware clock
really useful, there needs to be some extra functionality, like
timestamping external signals or producing periodic or one-shot output
signals.

If you don't have or need such functionality, then running PTP with
plain old software timestamping (no special PTP hardware clock) should
be good enough for most purposes.

> John point about not wanting to proliferate different APIs and useless
> clock ids is valid. An intial implementation using hpet style stuff would
> be satisfactory and as far as I can tell would be rather trivial to do.
> 
> Standardizing the ioctls between the different clock drivers would be
> useful so that they can all be controlled with some common API. But it
> would be great to first have a release of a clock_ptp listing all the
> needed ioctl so that we can see what the common subset is.

Okay, I think I have already done that in the above patch set. Would
you care to comment on it?

As I said before, I prefer the posix clock idea, but the character
device implementation is fine, too. Heck, we can offer both
avenues. My goal is to support PTP hardware clocks in the kernel.

Thanks,
Richard
