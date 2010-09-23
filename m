From: john stultz <johnstul@us.ibm.com>
Subject: Re: [PATCH v6 0/8] ptp: IEEE 1588 hardware clock support
Date: Thu, 23 Sep 2010 13:49:12 -0700
Message-ID: <1285274952.2587.113.camel@localhost.localdomain>
References: <cover.1285261533.git.richard.cochran@omicron.at>
	<20100923213654.0c64b047@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Rodolfo Giometti <giometti@linux.it>, Arnd Bergmann <arnd@arndb.de>,
	Peter Zijlstra <peterz@infradead.org>, linux-api@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org,
	linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	Christoph Lameter <cl@linux.com>, linuxppc-dev@lists.ozlabs.org,
	Richard Cochran <richardcochran@gmail.com>,
	linux-arm-kernel@lists.infradead.org, Krzysztof Halasa <khc@pm.waw.pl>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <20100923213654.0c64b047@lxorguk.ukuu.org.uk>
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

On Thu, 2010-09-23 at 21:36 +0100, Alan Cox wrote:
> >    So as far as the POSIX standard is concerned, offering a clock id
> >    to represent the PHC would be acceptable.
> 
> But completely useless as you may have more than one entirely different
> time managed by PTP and in which you are not master but must work with
> the timebases provided.

I don't see how this is a problem, as it exposes the multiple hardware
clocks via different posix clock ids. So in the boundary clock case, you
can configure which side is the client and which side is the master in a
config file and the PTPd will appropriately steer them individually.


> 
> >     /sys/class/timesource/<name>/id
> >     /sys/class/ptp/ptp_clock_X/id
> > 
> >     Note: I am not too sure that this is exactly what people imagined,
> >           but it is my best understanding so far. I gleaned two
> >           different ideas about where to offer the clock id. In order
> >           to keep just one way, I will be happy to remove the less
> >           popular one.
> 
> I see no fix proposed for the race condition I pointed out. This doesn't
> work.

So, if I recall this was: "How do you keep the module from unloading
while its being used?" 

There may need to be proper locking for unregistering the posix clock_id
on module unload, but I don't think we need a use-count to prevent the
module from being unloaded.

My question would be: How do we handle a USB network device ($14.99 now
with PTP!) being unplugged? We can't say "Sorry! That's in use!". So we
note the hardware is gone, and return the proper error code.

Or am I missing something else?


> >    If the Linux system time is synchronized to the PHC via the PPS
> 
> To which PHC we can have several
> 
> >    + Intel IXP465
> >      - Auxiliary Slave/Master Mode Snapshot (optional interrupt)
> >      - Target Time (optional interrupt)
> 
> And about 40 already supported by char driver interface clocks and rtcs
> in the kernel...

And those char driver interfaces are all subtly different.

I actually recently submitted an RFC to expose the RTC devices via the
posix clock/timer interface, because working with the RTC hardware
device directly is terrible for managing alarm interrupts. 

For instance, you easily run into the case where your TV recording
application programs an alarm to record your favorite show at 8pm. Then
your backup script programs an alarm to wake up at 2am to do your
nightly backups. Your box suspends and the next morning, you're missing
your favorite show!


> I'd say the inability to have multiple clocks and the race condition
> because of the clockid stuff leaves the proposal dead in the water.
> 
> It also ignores the existing APIs we have floating around attached to
> devices.
> 
> You need to make one small important change. You need to take the POSIX
> crap about enumerating things out and shoot it, bury it at a crossroads
> and sprinkle holy water on it.

We agree the list-by-name stuff isn't the way to go. :)


> Drop the clockid_t and swap it for a file handle like a proper Unix or
> Linux interface. The rest is much the same
> 
> 	fd = open /sys/class/timesource/[whatever]
> 
> 	various queries you may want to do to check the name etc
> 
> 	fclock_adjtime(fd, ...)
> 	
> 
> The posix interface is fundamentally flawed. It only works for staticly
> enumerable objects. Unix avoided that forty years ago by making the
> identifier a handle which immediately cures all your object lifetime
> problems in one swoop.

So, I don't really see how that's so different from what is being
proposed. The clock_id is dynamically assigned per registered clock, and
exposed via the sysfs interface from ptp hardware entry.

The only difference is the open/close reference counting, which I don't
think is necessary here (since we can't always keep the hardware from
going away).

thanks
-john
