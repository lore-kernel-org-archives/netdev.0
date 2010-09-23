From: john stultz <johnstul@us.ibm.com>
Subject: Re: [PATCH v6 0/8] ptp: IEEE 1588 hardware clock support
Date: Thu, 23 Sep 2010 12:38:53 -0700
Message-ID: <1285270733.2587.46.camel@localhost.localdomain>
References: <cover.1285261533.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Rodolfo Giometti <giometti@linux.it>, Arnd Bergmann <arnd@arndb.de>,
	Peter Zijlstra <peterz@infradead.org>, linux-api@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org, linux-kernel@vger.kernel.org,
	Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	Christoph Lameter <cl@linux.com>, linuxppc-dev@lists.ozlabs.org,
	David Miller <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org,
	Krzysztof Halasa <khc@pm.waw.pl>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <cover.1285261533.git.richard.cochran@omicron.at>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-09-23 at 19:30 +0200, Richard Cochran wrote:
> Here is the sixth version of my patch set adding PTP hardware clock
> support to the Linux kernel. The main difference to v5 is that the
> character device interface has been replaced with one based on the
> posix clock system calls.
> 
> The first three patches add necessary background support in the posix
> clock code. The last five add the new PTP hardware clock features.
> Previously, I had tried to present the posix clock changes all by
> themselves, but commentators asked to see the whole context.

Richard,
	Its great to see this work continue and the patch set is shaping up
nicely! There's still a few details to work out, but I think the
remaining issues are relatively small.


> 3.2.3 Dynamic POSIX Clock IDs 
> ------------------------------
> 
>     The reaction on the list to having a static id like CLOCK_PTP was
>     mostly negative. However, the idea of generating a clock id
>     dynamically seems to have gained acceptance. The general idea is
>     to advertise the available clock ids to user space via sysfs. This
>     patch set implements two different ways:
> 
>     /sys/class/timesource/<name>/id
>     /sys/class/ptp/ptp_clock_X/id
> 
>     Note: I am not too sure that this is exactly what people imagined,
>           but it is my best understanding so far. I gleaned two
>           different ideas about where to offer the clock id. In order
>           to keep just one way, I will be happy to remove the less
>           popular one.

So yea, I'm not a fan of the "timesource" sysfs interface. One, I think
the name is poor (posix_clocks or something a little more specific would
be an improvement), and second, I don't like the dictionary interface,
where one looks up the clock by name.

Instead, I think having the id hanging off the class driver is much
better, as it allows mapping the actual hardware to the id more clearly.

So I'd drop the "timesource" listing. And maybe change "id" to
"clock_id" so its a little more clear what the id is for.



> 3.3 Synchronizing the Linux System Time 
> ========================================
> 
>    One could offer a PHC as a combined clock source and clock event
>    device. The advantage of this approach would be that it obviates
>    the need for synchronization when the PHC is selected as the system
>    timer. However, some PHCs, namely the PHY based clocks, cannot be
>    used in this way.

Again, I'd scratch this. 

What I think you might want to mention is that an application like NTP
could use the PTP clockid much like NTP currently can be configured to
use the RTC to steer the system time.

Possibly the PTPd could just do this, reducing the number of deamons and
avoiding mixing NTP up in what is really a different sync algorithm.

>    Instead, the patch set provides a way to offer a Pulse Per Second
>    (PPS) event from the PHC to the Linux PPS subsystem. A user space
>    application can read the PPS events and tune the system clock, just
>    like when using other external time sources like radio clocks or
>    GPS.

Forgive me for a bit of a tangent here:
	So while I think this PPS method is a neat idea, I'm a little curious
how much of a difference the PPS method for syncing the clock would be
over just a simple reading of the two clocks and correcting the offset.

It seems much of it depends on the read latency of the PTP hardware vs
the interrupt latency. Also the PTP clock granularity would effect the
read accuracy (like on the RTC, you don't really know how close to the
second boundary you are).

Have you done any such measurements between the two methods? I just
wonder if it would actually be something noticeable, and if its not, how
much lighter this patch-set would be without the PPS connection.

Again, this isn't super critical, just trying to make sure we don't end
up adding a bunch of code that doesn't end up being used. Also PPS
interrupts are awfully frequent, so systems concerned with power-saving
and deep idles probably would like something that could be done at a
more coarse interval.


> 3.5 User timers 
> ================
> 
>    Using the POSIX clock API gived user space the possibility to
>    create and use timers with timer_create and timer_settime. In the
>    current patch set the kernel functionality is not implemented,
>    since there are some issues to consider first. I see two ways to do
>    about this.
> 
>    1. Implement the functionality anew. This approach might end up
>       duplicating similar code that already exists. Also, looking at
>       the hrtimer code, getting user timers right seems to have a
>       number of gotchas and thorny issues.
> 
>    2. Reuse the hrtimer code. Since the hrtimer code uses a clock
>       event device under the hood, it might be possible (in theory) to
>       offer capable PHCs as clock event devices. However, the current
>       hrtimers are hard-coded to the event device via a per-cpu
>       global. Perhaps one could associate an event device with a
>       hrtimer via the timer itself.
> 
>    At this point I am not optimistic about either approach, and I
>    would vote for postponing the timer issue indefinitely. The
>    implementation effort would be high, but the utility low.

So I'm working on this! I've pulled out the basic rbtree based timer
list manipulation out of the hrtimer code and into its own lib code.

I'll send those patches out for RFC shortly.


>    If the Linux system time is synchronized to the PHC via the PPS
>    method, then using standard hrtimers would be good enough for most
>    purposes. Consider the time scales involved. The PHC can be
>    synchronized to within 100 nanoseconds of an external time source,
>    while timer wakeup latency (even with rt kernels) is tens of
>    microseconds.

Hmm. I think this point touches on my earlier tangent.



> 4 Drivers 
> ~~~~~~~~~~
> 
> 4.1 Supported Hardware Clocks 
> ==============================
> 
>    + Standard Linux system timer
>      This driver exports the standard Linux timer as a PTP clock.
>      Although this duplicates CLOCK_REALTIME, the code serves as a
>      simple example for driver development and lets people who without
>      special hardware try the new API.

Still not a fan of this one, figure the app should handle the special
case where there are no PTP clocks and just use CLOCK_REALTIME rather
then funneling CLOCK_REALTIME through the PTP interface.

thanks
-john
