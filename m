From: john stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH V8 02/13] ntp: add ADJ_SETOFFSET mode bit
Date: Tue, 11 Jan 2011 12:55:09 -0800
Message-ID: <1294779309.3441.66.camel@work-vm>
References: <cover.1293820862.git.richard.cochran@omicron.at>
	 <fe2bec763bec155381d62721aa9da84aeca2785c.1293820862.git.richard.cochran@omicron.at>
	 <AANLkTini2WdT-1v4k9V3JOZYDkA59P+SyscTe8-fK2Wk@mail.gmail.com>
	 <20110108175028.GA22308@riccoc20.at.omicron.at>
	 <AANLkTikigXGSACF6R6kfNHyKZ7GFWrUrCMxygvL3fUC6@mail.gmail.com>
	 <1294678145.3068.6.camel@work-vm>
	 <AANLkTikdg4Pb5c4wcCU3d3Eku=mpiW_TEkBz0A2VPdVp@mail.gmail.com>
	 <1294693597.3068.12.camel@work-vm>
	 <AANLkTik+2udoJ6JyZMhkd1yhr2W9hSWO_vD_zdm+BoOG@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
To: "Kuwahara,T." <6vvetjsrt26xsrzlh1z0zn4d2grdah-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AANLkTik+2udoJ6JyZMhkd1yhr2W9hSWO_vD_zdm+BoOG-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-01-12 at 05:32 +0900, Kuwahara,T. wrote:
> On Tue, Jan 11, 2011 at 6:06 AM, john stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> > On Tue, 2011-01-11 at 05:45 +0900, Kuwahara,T. wrote:
> >> On Tue, Jan 11, 2011 at 1:49 AM, john stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> >> > Leapsecond processing is done via an absolute hrtimer. Thus when the
> >> > time offset is set, the hrtimers that should have expired will fire
> >> > (just like with settimeofday) and the adjustment will then be made.
> >>
> >> How do you convert relative time to absolute time?  It's not trivial
> >> because TAI offset is also a variable.
> >
> > I don't believe I understand what you're getting at.
> >
> > The proposed interface is almost identical in functionality to a
> > userland application doing the following:
> >
> >        offset = my_calculate_offset();
> >        clock_gettime(CLOCK_REALTIME, &now);
> >        newtime = my_add_ts(now, offset);
> >        settimeofday(&newtime, 0);
> >
> > The only difference is that you avoid the error from the delay between
> > the gettime call and the settime call. It just adds the offset directly
> > to the CLOCK_REALTIME.
> 
> For example, what time was it 3 seconds after 2008-12-31 23:59:59?
> You may say, of course it's 2009-01-01 00:00:02.  But it's not true.
> You wonder why?  Because a leap second had been added at midnight.
> 
> 	unix time   UTC     offset
> 	---------- -------- ---
> 	1230767997 23:59:57  -2
> 	1230767998 23:59:58  -1
> 	1230767999 23:59:59   0
> 	1230768000 23:59:60   1 (leap second)
> 	1230768000 00:00:00   2
> 	1230768001 00:00:01   3
> 	1230768002 00:00:02   4
> 
> That's why I said it's not trivial, and that your patch is broken and
> thus useless. 

So the kernel handles leap second insertion via a timer. Thus at the end
of 23:59:59, it will inject a leapsecond by setting the time back by one
second (back to 23:59:59) and setting the TIME_OOP flag.

This timer is an absolute timer, so if someone moves the clock forward
across the 23:59:59 boundary, the adjustment will still be made.

The patch is not broken, nor useless. 

>  Unfortunately, there's no remedy for this as long as a
> nonlinear timescale such as the unix time is being used, since the
> leap second insertion/deletion is a non-deterministic event.

Indeed. Leapseconds in unix time are frustrating to deal with, and
complicates applications having to be careful with them. But we do
manage them properly and applications can detect that they are pending
(via checking for TIME_INS) or if they are in effect (TIME_OOP).

Richards patch is in no different from settimeofday() solutions for
correcting for an offset, with the exception of the fact that it does
not introduce error due to delay beteween any gettime and settime call. 

If your complaint is that leapseconds are ugly to deal with in unix
time, then I agree. However, I'm at a total loss for understanding your
passionate objections to Richard's patch.

thanks
-john
