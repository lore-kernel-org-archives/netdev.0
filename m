From: john stultz <johnstul@us.ibm.com>
Subject: Re: [PATCH v6 0/8] ptp: IEEE 1588 hardware clock support
Date: Thu, 23 Sep 2010 15:03:40 -0700
Message-ID: <1285279420.2587.175.camel@localhost.localdomain>
References: <cover.1285261533.git.richard.cochran@omicron.at>
	 <20100923213654.0c64b047@lxorguk.ukuu.org.uk>
	 <1285274952.2587.113.camel@localhost.localdomain>
	 <20100923223025.2877cce2@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran@gmail.com>,
	linux-kernel@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	linux-api@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Christoph Lameter <cl@linux.com>,
	David Miller <davem@davemloft.net>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Peter Zijlstra <peterz@infradead.org>,
	Rodolfo Giometti <giometti@linux.it>,
	Thomas Gleixner <tglx@linutronix.de>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100923223025.2877cce2@lxorguk.ukuu.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-09-23 at 22:30 +0100, Alan Cox wrote:
> O> I don't see how this is a problem, as it exposes the multiple hardware
> > clocks via different posix clock ids. So in the boundary clock case, you
> > can configure which side is the client and which side is the master in a
> > config file and the PTPd will appropriately steer them individually.
> 
> They may all be slaves - that means you can't treat them as part of
> system time.

Sure, and that's something one would configure. So I'm not sure I see
how exposing the different hardware bits via a clock_id is problematic.
They're just clocks that are being exposed. The steering of system time
to PTP or PTP to system time  (or just PTP to other PTP clocks).


> > on module unload, but I don't think we need a use-count to prevent the
> > module from being unloaded.
> > 
> > My question would be: How do we handle a USB network device ($14.99 now
> > with PTP!) being unplugged? We can't say "Sorry! That's in use!". So we
> > note the hardware is gone, and return the proper error code.
> > 
> > Or am I missing something else?
> 
> Open list
> Oh number 31 appears to be the device I want
> Close list
> 
> 	USB unplugged
> 	Random other device plugged
> 
> clock_op(31, ....)
> 
> Oh bugger I've just reprogrammed the wrong time source.

Ok. So its just the issue of clock_id reuse. I was confusing it with
some sort of module use counting issue.  And yea, I can see how it might
be  easier to re-use the file descriptor then re-implementing the reuse
logic in the posix-clock registration.


> We don't have stop the device being removed, instead of a disaster you get
> 
> 	clock_op(fd, blah)
> 	-ENODEV
> 
> which btw is how just about everything else USB works when you pull the
> hardware.

Right, which was what I was thinking as well, but assuming we didn't
re-use clockids quickly.
 
> > So, I don't really see how that's so different from what is being
> > proposed. The clock_id is dynamically assigned per registered clock, and
> > exposed via the sysfs interface from ptp hardware entry.
> > 
> > The only difference is the open/close reference counting, which I don't
> > think is necessary here (since we can't always keep the hardware from
> > going away).
> 
> It is absolutely neccessary in order that you can be sure that two calls
> actually relate to the *same* device. It's as fundamental as the
> difference betweeh chmod and fchmod although with the added ugliness of
> some random numeric identifier stuck in the middle.
> 
> It also btw makes it much easier to fix up the existing random collection
> of /dev/rtc devices - because you can open them and issue fclock_adjtime
> if we are careful how we do it and it makes sense.

Wait, you're suggesting we add new fclock_* calls that duplicate the
posix interface? That doesn't sound great to me.

What did you think of Kyle Moffett's suggestion of utilizing the fd to
map to the clock_id which could then be used by the posix clocks
interface?

Although I'm still not sure if it wouldn't be so hard to just simply
increment the id on each registration and index to a clock through a
reasonably small hash table. I suspect that would solve the
enumeration/reuse issue without much trouble (but again, I'm open to
being corrected if I'm missing something larger).

But yes, in summary, this is an issue to be addressed one way or
another.

thanks
-john
