From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH V8 02/13] ntp: add ADJ_SETOFFSET mode bit
Date: Sat, 8 Jan 2011 18:50:28 +0100
Message-ID: <20110108175028.GA22308@riccoc20.at.omicron.at>
References: <cover.1293820862.git.richard.cochran@omicron.at>
 <fe2bec763bec155381d62721aa9da84aeca2785c.1293820862.git.richard.cochran@omicron.at>
 <AANLkTini2WdT-1v4k9V3JOZYDkA59P+SyscTe8-fK2Wk@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	John Stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
To: "Kuwahara,T." <6vvetjsrt26xsrzlh1z0zn4d2grdah-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AANLkTini2WdT-1v4k9V3JOZYDkA59P+SyscTe8-fK2Wk-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 02, 2011 at 05:38:19AM +0900, Kuwahara,T. wrote:
> As you know, it conflicts with MOD_PPSMAX.  And also, it is logically
> the same as ADJ_OFFSET, unless the kernel PLL is enabled explicitly.

I choose another bit, for the next version of the patch series.

> 
> So here's my simple solution:
> 

I have read the API documentation in the nanokernel source archive. It
explains the (very complex looking) timex structure quite clearly and
nicely. Now I am more convinced than ever that adding a new mode bit
is the best way to go, as opposed to ADJ_OFFSET/!STA_PLL, because:

1. The mode bits update kernel variables. That is what we want.
2. Clearing STA_PLL means disable adjustments.
3. The range of the timex.offset is way too small.

I expand on each point, below. BTW, the API document is also available
for online reading here:

   http://www.slac.stanford.edu/comp/unix/package/rtems/src/ssrlApps/ntpNanoclock/api.htm

1. Looking at the API, the documentation for the bits of the 'modes'
   field states:

        These bits control which field of the timex structure are used
        to update the corresponding kernel variable. The bits may be
        set in any combination. See the description below for which
        bits control which variable.

   With the ADJ_SETOFFSET mode, we are telling the kernel to update
   the instantaneous value of the 'current time' variable. That usage
   agrees with the sematics of the other mode bits.

2. The documentation for STA_PLL states:

        Master enable switch for the PLL/FLL loop. The algorithm is
        responsive to time and/or frequency updates if set; otherwise,
        no change in the current time or frequency will be made other
        than to complete a pending phase adjustment. This bit does not
        affect the PPS loop.

   So when we clear this bit, the kernel promises that it will make
   "no change in the current time." The proposed ADJ_OFFSET/!STA_PLL
   solution would break this pattern.

3. The timex.offset field is of type "long" and represents either
   nanoseconds or microseconds. On 32 bit architectures, the maximum
   possible adjustment would be

   2^31 * 10^-6 = 2147.5 seconds

   which is less than one hour. For the first adjustment of a clock,
   we want to be able to jump the clock arbitrarily. Not every
   computer has an RTC, and so some boot up believing that it is still
   the year 1970.

Richard
