From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: Spurious timeouts in mvmdio
Date: Tue, 3 Dec 2013 12:40:34 +0000
Message-ID: <20131203124033.GT16735@n2100.arm.linux.org.uk>
References: <529CA42A.3040504@freebox.fr> <20131203122346.GD29282@titan.lakedaemon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Schichan <nschichan@freebox.fr>,
	Leigh Brown <leigh@solinno.co.uk>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	Florian Fainelli <florian@openwrt.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Jason Cooper <jason@lakedaemon.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131203122346.GD29282@titan.lakedaemon.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 03, 2013 at 07:23:46AM -0500, Jason Cooper wrote:
> On Mon, Dec 02, 2013 at 04:15:54PM +0100, Nicolas Schichan wrote:
> > During 3.13-rc1 testing, I have found out that the mvmdio driver
> > would report timeouts on the kernel console:
> > 
> > [   11.011334] orion-mdio orion-mdio: Timeout: SMI busy for too long
> > 
> > The hardware is a MV88F6281 Kirkwood CPU. The mvmdio driver is using
> > the irq line 46 (ge00_err).
> > 
> > I am inclined to believe that it is due to the fact that
> > wait_event_timeout() is called with a timeout parameter of 1 jiffy
> > in orion_mdio_wait_ready(). If the timer interrupt ticks right after
> > calling wait_event_timeout(), we may end up spending much less time
> > than MVMDIO_SMI_TIMEOUT (1 msec) in wait_event_timeout(), and as a
> > result report a timeout as the MDIO access did not complete in such
> > a short time.
> > 
> > As to how to fix this, I see two options (I don't know which one
> > would be prefered):
> > 
> > - Option 1: always pass a timeout of at least 2 jiffy to wait_event_timeout().
> > - Option 2: switch to wait_event_hrtimeout().
> > 
> > I can provide patches for both options.
> 
> Based on yesterday's irc chat, option 1 sounds good.  Here's the dump
> from yesterday where Sebastian provided a thorough explanation:
> 
> 11:29 < shesselba> increasing max timeout to 2 ticks at least sounds reasonable
> 11:29 < shesselba> 10ms should be enough for every CONFIG_HZ there is
> 
> 11:30 < kos_tom> why make the timeout tied to the ticks? there are functions/macros to convert real time numbers into ticks.
> 11:30 < kos_tom> msecs_to_jiffies() or something
> 
> 11:31 < shesselba> kos_tom: it is already using usecs_to_jiffies()
> 11:31 < shesselba> the thing is: 1ms is less than a jiffy

Yes, and the kernels time conversion functions aren't stupid.  Let's
look at this function's implementation:

unsigned long usecs_to_jiffies(const unsigned int u)
{
        if (u > jiffies_to_usecs(MAX_JIFFY_OFFSET))
                return MAX_JIFFY_OFFSET;
#if HZ <= USEC_PER_SEC && !(USEC_PER_SEC % HZ)
        return (u + (USEC_PER_SEC / HZ) - 1) / (USEC_PER_SEC / HZ);
#elif HZ > USEC_PER_SEC && !(HZ % USEC_PER_SEC)
        return u * (HZ / USEC_PER_SEC);
#else
        return (USEC_TO_HZ_MUL32 * u + USEC_TO_HZ_ADJ32)
                >> USEC_TO_HZ_SHR32;
#endif
}

Now, assuming HZ=100 and USEC_PER_SEC=1000000, we will use:

	return (u + (USEC_PER_SEC / HZ) - 1) / (USEC_PER_SEC / HZ);

If you ask for 1us, this comes out as:

	return (1 + (1000000 / 100) - 1) / (1000000 / 100);

which is one jiffy.  So, for a requested 1us period, you're given a
1 jiffy interval, or 10ms.  For other (sensible) values:

        return (USEC_TO_HZ_MUL32 * u + USEC_TO_HZ_ADJ32)
                >> USEC_TO_HZ_SHR32;

gets used, which has a similar behaviour.

Now, depending on how you use this one jiffy interval, the thing to realise
is that with this kind of loop:

	timeout = jiffies + usecs_to_jiffies(1);
	do {
		something;
	} while (time_is_before_jiffies(timeout));

what this equates to is:

	} while (jiffies - timeout < 0);

What this means is that the loop breaks at jiffies = timeout, so it can
indeed timeout before one tick - within 0 to 10ms for HZ=100.  The problem
is not the usecs_to_jiffies(), it's with the implementation.

If you use time_is_before_eq_jiffies() instead, it will also loop if
jiffies == timeout, which will give you the additional safety margin -
meaning it will timeout after 10 to 20ms instead.

You may wish to consider coding this differently as well - if you have
the error interrupt, there's no need for this loop.  You only need the
loop if you're using usleep_range().  Note the return value of
wait_event_timeout() will tell you positively and correctly if the waited
condition succeeded or you timed out.
