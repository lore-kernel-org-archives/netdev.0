From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH V11 2/4] ptp: Added a clock that uses the eTSEC found
 on the MPC85xx.
Date: Thu, 24 Feb 2011 18:26:52 +0100
Message-ID: <20110224172652.GC15234@riccoc20.at.omicron.at>
References: <cover.1298447722.git.richard.cochran@omicron.at>
 <be1f5e801e8cd0145dd23aadae7c2055bb3c1d47.1298447722.git.richard.cochran@omicron.at>
 <20110223165058.GE14597@angua.secretlab.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>,
	Mike Frysinger <vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>,
	Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>,
	Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
To: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110223165058.GE14597-MrY2KI0G/OVr83L8+7iqerDks+cytr/Z@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 23, 2011 at 09:50:58AM -0700, Grant Likely wrote:
> On Wed, Feb 23, 2011 at 11:38:17AM +0100, Richard Cochran wrote:
> > +Clock Properties:
> > +
> > +  - tclk-period  Timer reference clock period in nanoseconds.
> > +  - tmr-prsc     Prescaler, divides the output clock.
> > +  - tmr-add      Frequency compensation value.
> > +  - cksel        0= external clock, 1= eTSEC system clock, 3= RTC clock input.
> > +                 Currently the driver only supports choice "1".
> 
> I'd be hesitant about defining something that isn't actually
> implemented yet.  You may find the binding to be insufficient at a
> later date.

Okay, I'll remove it.
We never got the external VCO working anyhow.

> > +  - tmr-fiper1   Fixed interval period pulse generator.
> > +  - tmr-fiper2   Fixed interval period pulse generator.
> > +  - max-adj      Maximum frequency adjustment in parts per billion.
> 
> These are all custom properties (not part of any shared binding) so
> they should probably be prefixed with 'fsl,'.

Okay, fine.

> > +  The calculation for tmr_fiper2 is the same as for tmr_fiper1. The
> > +  driver expects that tmr_fiper1 will be correctly set to produce a 1
> > +  Pulse Per Second (PPS) signal, since this will be offered to the PPS
> > +  subsystem to synchronize the Linux clock.
> 
> Good documentation, thanks.  Question though, how many of these values
> will the end user (or board builder) be likely to want to change.  It
> is risky encoding the calculation results into the device tree when
> they aren't the actually parameters that will be manipulated, or at
> least very user-unfriendly.

The whole thing is pretty opaque, and my explanation is (IMHO) way
better that Freescale's documentation of how the fipers work.

The board designer / system designer will want to set these carefully,
but never change them. Basically, for a given input clock, there is
only one optimal setting.

I think the device tree is the right place for that kind of setting.

The fiper1 signal should always be a 1 PPS.  We could make fiper2 run
time programmable via PHC ioctls, but I think this can wait.


> > +	etsects->irq = irq_of_parse_and_map(node, 0);
> 
> Use platform_get_irq().

Okay.

> > +	etsects->regs = of_iomap(node, 0);
> 
> Use platform_get_resource(), and don't forget to request the
> resources.

Okay, but didn't you tell me before to do this way?

   http://marc.info/?l=linux-netdev&m=127662247203659&w=4

> > +static struct of_platform_driver gianfar_ptp_driver = {
> 
> Use a platform_driver instead.  of_platform_driver is deprecated and
> being removed.

Ja, should have noticed that myself, sorry.

> > +++ b/drivers/net/gianfar_ptp_reg.h
> 
> This data is only used by gianfar_ptp.c, so there is no need for a
> separate include file.  Move the contents of gianfar_ptp_reg.h into
> gianfar_ptp.c

You are right, of course, since private #defines and declarations
should simply stay in their .c files. Some people think that all
#defines and declarations must go into a header file.

I am not one of those people, but in this case, I generated the file
from a little tool I wrote and so kept it separate.

Still, it is no trouble to combine the header into the driver .c file.

Thanks for your review,

Richard
