From: Mitch Williams <mitch.a.williams@intel.com>
Subject: Re: RFC: NAPI packet weighting patch
Date: Fri, 3 Jun 2005 12:28:10 -0700
Message-ID: <Pine.CYG.4.58.0506031202280.3344@mawilli1-desk2.amr.corp.intel.com>
References: <1117765954.6095.49.camel@localhost.localdomain>
 <Pine.CYG.4.58.0506030929300.2788@mawilli1-desk2.amr.corp.intel.com>
 <1117824150.6071.34.camel@localhost.localdomain> <20050603.120126.41874584.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: hadi@cyberus.ca, mitch.a.williams@intel.com, john.ronciak@intel.com,
        jdmason@us.ibm.com, shemminger@osdl.org, netdev@oss.sgi.com,
        Robert.Olsson@data.slu.se, ganesh.venkatesan@intel.com,
        jesse.brandeburg@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050603.120126.41874584.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Fri, 3 Jun 2005, David S. Miller wrote:

> From: jamal <hadi@cyberus.ca>
> Date: Fri, 03 Jun 2005 14:42:30 -0400
>
> > When you reduce the weight, the system is spending less time in the
> > softirq processing packets before softirq yields. If this gives more
> > opportunity to your app to run, then the performance will go up.
> > Is this what you are seeing?
>
> Jamal, this is my current theory as well, we hit the jiffies
> check.

Well, I hate to mess up your guys' theories, but the real reason is
simpler:  hardware receive resources, specifically descriptors and
buffers.

In a typical NAPI polling loop, the driver processes receive packets until
it either hits the quota or runs out of packets.  Then, at the end of the
loop, it returns all of those now-free receive resources back to the
hardware.

With a heavy receive load, the hardware will run out of receive
descriptors in the time it takes the driver/NAPI/stack to process 64
packets.  So it drops them on the floor.  And, as we know, dropped packets
are A Bad Thing.

By reducing the driver weight, we cause the driver to give receive
resources back to the hardware more often, which prevents dropped packets.

As Ben Greer noticed, increasing the number of descriptors can help with
this issue.   But it really can't eliminate the problem -- once the ring
is full, it doesn't matter how big it is, it's still full.

In my testing (Dual 2.8GHz Xeon, PCI-X bus, Gigabit network, 10 clients),
I was able to completely eliminate dropped packets in most cases by
reducing the driver weight down to about 20.

Now for some speculation:

Aside from dropped packets, I saw continued performance gain with even
lower weights, with the sweet spot (on a single adapter) being about 8 to
10.  I don't have a definite answer for why this is happening, but my
theory is that it's latency.  Packets are processed more often, meaning
they spend less time sitting in hardware-owned buffers, which means they
get to the stack quicker, which means less latency.

But I'm happy to admit I might be wrong with this theory.  Nevertheless,
the effect exists, and I've seen it on drivers other than just e1000.
(And, no, I'm not allowed to say which other drivers I've used, or give
specific numbers, or our lawyers will string me up by my toes.)

Anybody else got a theory?

-Mitch
