From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: pktgen
Date: Mon, 29 Nov 2004 09:57:50 -0700
Message-ID: <20041129165750.GA11413@colo.lackof.org>
References: <20041125030450.GA24417@xi.wantstofly.org> <16805.40983.937641.670275@robur.slu.se> <20041127002841.GA17184@xi.wantstofly.org> <20041127004325.GA17401@xi.wantstofly.org> <16808.28005.74903.881087@robur.slu.se> <20041127135354.GA24617@xi.wantstofly.org> <20041127143923.GA25155@xi.wantstofly.org> <1101567861.1044.87.camel@jzny.localdomain> <20041128183143.GD6045@xi.wantstofly.org> <1101736191.1044.196.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lennert Buytenhek <buytenh@wantstofly.org>,
        Robert Olsson <Robert.Olsson@data.slu.se>, netdev@oss.sgi.com,
        Grant Grundler <grundler@parisc-linux.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1101736191.1044.196.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Nov 29, 2004 at 08:49:52AM -0500, jamal wrote:
> On Sun, 2004-11-28 at 13:31, Lennert Buytenhek wrote:
> > Indeed.  Right now it feels like I'm just poking around in the dark.  I'm
> > really interested by now in finding out exactly what part of packet TX is
> > taking how long and where all my cycles are going.

ia64 PMU can measure exactly where/why the CPU is stalling.
MMIO reads are by far the worst offenders - but not the only ones.
"bubbles" in the pipeline can be caused by lots of other
stalls and will affect CPU utilization as well.
A very nice description of CPU stalls caused by memory subsystem is here:

	http://www.gelato.org/pdf/mysql_itanium2_perf.pdf

Gelato.org, sgi.com, intel.com, hp.com have more white papers
on ia64 performance tools and tuning.

> > I don't have an Itanic but it's still possible to instrument the driver
> > and do some stuff Grant talks about in his OLS paper, something like the
> > attached.  (Exports # of MMIO reads/writes/flushes in the RX frame/
> > TX carrier/collision stats field.  Beware, flushes are double-counted
> > as reads.  Produces lots of output.)

I'd be happy to give you access to an IA64 machine to poke at.
If you can send me:
o preferred login
o public ssh key
o work telephone #

BTW, Jamal, I'm expecting we'll be able to get Robur an RX2600
to play with this quarter. I need to ask about that again.

> > During a 10Mpkt pktgen session (~16 seconds), I'm seeing:
> > - 131757 interrupts, ~8k ints/sec, ~76 pkts/int
> > - 131789 pure MMIO reads (i.e. not counting MMIO reads intended as write
> > 	flushes), which is E1000_READ_REG(icr) in the irq handler
> > - 10263536 MMIO writes (which would be 1 per packet plus 2 per interrupt)
> > - 131757 MMIO write flushes (readl() of the e1000 status register after
> > 	re-enabling IRQs in dev->poll())
> > 
> > Pretty consistent with what Grant was seeing.

yup.

> > 
> > MMIO reads from the e1000 are somewhere between 2000 and 3000 cycles a
> > pop on my hardware.  2400MHz CPU -> ~1us/each.  (Reading netdevice stats
> > does ~50 of those in a row.)
> > 
> 
> Reads are known to be expensive. Good to see how much they are reduced. 
> Not sure if this applies to MMIO reads though. Grant?

I don't differentiate between "pure" MMIO reads and posted MMIO write
flushes. They cost the same AFAIK. If one can tweak the algorithm so
either is not needed, it's a win.

But I didn't see any opportunity to do that in e1000 driver.
There is such an opportunity in tg3 though. I just won't have
a chance to pursue it. :^(

The absolute cost in CPU cycles of an MMIO read will depend on chipset,
CPU speed, and number of bridges the transaction has to cross.
On an idle 1Ghz system, I've measured ~1000-1200 cycles.
When measured in time (not CPU cycles), the cost hasn't changed that
much in the past 6-8 years (mostly 66Mhz PCI busses).
Adding or removing a PCI-PCI bridge is the biggest variable in
absolute time.

thanks,
grant
