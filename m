From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: Intel and TOE in the news
Date: Sat, 19 Feb 2005 21:29:32 +0100
Message-ID: <20050219202931.GA21315@xi.wantstofly.org>
References: <4216B62D.6000502@pobox.com> <20050219041007.GA17896@xi.wantstofly.org> <20050219114624.373af63f.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050219114624.373af63f.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Feb 19, 2005 at 11:46:24AM -0800, David S. Miller wrote:

> > I wonder if they could just take the network processing circuitry from
> > the IXP2800 (an extra 16-core (!) RISCy processor on-die, dedicated to
> > doing just network stuff, and a 10gbps pipe going straight into the CPU
> > itself) and graft it onto the Xeon.
> > 
> > Now _that_ would be something worth experiencing.
> 
> No, that would be garbage.
> 
> Read what they are doing.  The idea is not to have all of this network
> protocol logic off-cpu, the idea is to "reduce some of the time
> a processor typically spends waiting for memory to feed back information"

I agree that offloading just for the sake of offloading is silly.

The reason a 1.4GHz IXP2800 processes 15Mpps while a high-end PC hardly
does 1Mpps is exactly because the PC spends all of its cycles stalling on
memory and PCI reads (i.e. 'latency'), and the IXP2800 has various ways
of mitigating this cost that the PC doesn't have.  First of all, the IXP
has 16 cores which are 8-way 'hyperthreaded' each (128 threads total.)
Second, the SDRAM controller and the the NIC circuitry are all on-chip, 
which saves you having to cross the FSB and the PCI bus a gazillion
times for everything you do.  (An L2 miss is hundreds of wasted cycles,
and just reading the interrupt status register of the e1000 that's on
a dedicated 64bit 100MHz PCI bus is ~2500 wasted cycles on my Xeon
2.4GHz.)  Third, SDRAM is treated as an async resource -- i.e. you
submit a memory read or write, and get an async signal when it's done,
so you can do other stuff instead of stalling.

The goal of the IXP2800 design, AFAICS, was not to create the possiblity
to offload the TCP stack per se, but to create an architecture that is
better suited to the kind of nonlocal reference patterns that you see
with network traffic.  It wasn't even specifically designed for
offloading things as such.

For something somewhat more conventional, look at the Broadcom BCM1250:
a dual core MIPS CPU, relatively slow (600MHz-1GHz), but with three
GigE MACs and a SDRAM controller inside the CPU.  It gives the PC a
good run for its money for networking stuff.

Any kind of "make networking go faster" solution will be all about
reducing the cost of latency, and less about increasing raw processing
power.  Multi-core CPUs help not because they have more MIPS, but
because if they stall, it's only one core that stalls and all the
other cores just keep on going.  For certain tasks, I'll take a 4-core
1.0GHz CPU over a single-core 4.0GHz one any day.


--L
