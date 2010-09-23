From: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Subject: Re: [PATCH v6 0/8] ptp: IEEE 1588 hardware clock support
Date: Thu, 23 Sep 2010 22:30:25 +0100
Message-ID: <20100923223025.2877cce2@lxorguk.ukuu.org.uk>
References: <cover.1285261533.git.richard.cochran@omicron.at>
	<20100923213654.0c64b047@lxorguk.ukuu.org.uk>
	<1285274952.2587.113.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
To: john stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1285274952.2587.113.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

O> I don't see how this is a problem, as it exposes the multiple hardware
> clocks via different posix clock ids. So in the boundary clock case, you
> can configure which side is the client and which side is the master in a
> config file and the PTPd will appropriately steer them individually.

They may all be slaves - that means you can't treat them as part of
system time.
> 

> on module unload, but I don't think we need a use-count to prevent the
> module from being unloaded.
> 
> My question would be: How do we handle a USB network device ($14.99 now
> with PTP!) being unplugged? We can't say "Sorry! That's in use!". So we
> note the hardware is gone, and return the proper error code.
> 
> Or am I missing something else?

Open list
Oh number 31 appears to be the device I want
Close list

	USB unplugged
	Random other device plugged

clock_op(31, ....)

Oh bugger I've just reprogrammed the wrong time source.

We don't have stop the device being removed, instead of a disaster you get

	clock_op(fd, blah)
	-ENODEV

which btw is how just about everything else USB works when you pull the
hardware.

> > And about 40 already supported by char driver interface clocks and rtcs
> > in the kernel...
> 
> And those char driver interfaces are all subtly different.
> 
> I actually recently submitted an RFC to expose the RTC devices via the
> posix clock/timer interface, because working with the RTC hardware
> device directly is terrible for managing alarm interrupts. 

Given that driver interfaces are sane and posix clock/timer interfaces
have totally broken enumeration maybe you have it backwards. But if you
follow through to my proposal maybe there is a saner answer still
 
> For instance, you easily run into the case where your TV recording
> application programs an alarm to record your favorite show at 8pm. Then
> your backup script programs an alarm to wake up at 2am to do your
> nightly backups. Your box suspends and the next morning, you're missing
> your favorite show!

Poor resource management, and yes I'd agree you want a sensible interface.


> > Drop the clockid_t and swap it for a file handle like a proper Unix or
> > Linux interface. The rest is much the same
> > 
> > 	fd = open /sys/class/timesource/[whatever]
> > 
> > 	various queries you may want to do to check the name etc
> > 
> > 	fclock_adjtime(fd, ...)
> > 	
> > 
> > The posix interface is fundamentally flawed. It only works for staticly
> > enumerable objects. Unix avoided that forty years ago by making the
> > identifier a handle which immediately cures all your object lifetime
> > problems in one swoop.
> 
> So, I don't really see how that's so different from what is being
> proposed. The clock_id is dynamically assigned per registered clock, and
> exposed via the sysfs interface from ptp hardware entry.
> 
> The only difference is the open/close reference counting, which I don't
> think is necessary here (since we can't always keep the hardware from
> going away).

It is absolutely neccessary in order that you can be sure that two calls
actually relate to the *same* device. It's as fundamental as the
difference betweeh chmod and fchmod although with the added ugliness of
some random numeric identifier stuck in the middle.

It also btw makes it much easier to fix up the existing random collection
of /dev/rtc devices - because you can open them and issue fclock_adjtime
if we are careful how we do it and it makes sense.

Alan
