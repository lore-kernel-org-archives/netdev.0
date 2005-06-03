From: jamal <hadi@cyberus.ca>
Subject: Re: RFC: NAPI packet weighting patch
Date: Fri, 03 Jun 2005 14:42:30 -0400
Message-ID: <1117824150.6071.34.camel@localhost.localdomain>
References: <468F3FDA28AA87429AD807992E22D07E0450BFDB@orsmsx408>
	 <20050602.171812.48807872.davem@davemloft.net>
	 <1117765954.6095.49.camel@localhost.localdomain>
	 <Pine.CYG.4.58.0506030929300.2788@mawilli1-desk2.amr.corp.intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        "Ronciak, John" <john.ronciak@intel.com>, jdmason@us.ibm.com,
        shemminger@osdl.org, netdev@oss.sgi.com, Robert.Olsson@data.slu.se,
        "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitch Williams <mitch.a.williams@intel.com>
In-Reply-To: <Pine.CYG.4.58.0506030929300.2788@mawilli1-desk2.amr.corp.intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-03-06 at 10:43 -0700, Mitch Williams wrote:
> 
> On Thu, 2 Jun 2005, jamal wrote:
> >
> > Heres what i think i saw as a flow of events:
> > Someone posted a theory that if you happen to reduce the weight
> > (iirc the reduction was via a shift) then the DRR would give less CPU
> > time cycle to the driver - Whats the big suprise there? thats DRR design
> > intent.
> 
> Well, that was me.  Or at least I was the original poster on this thread.
> But my theory (if you can call it that) really wasn't about CPU time.  I
> spent several weeks in our lab with the somewhat nebulous task of "look at
> Linux performance".  And what I found was, to me, counterintuitive:
> reducing weight improved performance, sometimes significantly.
> 

When you reduce the weight, the system is spending less time in the
softirq processing packets before softirq yields. If this gives more
opportunity to your app to run, then the performance will go up.
Is this what you are seeing? 

> OK, well, call me a blasphemer (against whom?).
> I'm not really saying
> that the DRR algorithm is not real-world, but rather that NAPI as
> currently implemented has some significant performance limitations.
> 

And we need to be fair and investigate why.

> In my mind, there are two major problems with NAPI as it stands today.
> First, at Gigabit and higher speeds, the default settings don't allow the
> driver to process received packets in a timely manner.

What do you mean by timely?

>   This causes
> dropped packets due to lack of receive resources.  Lowering the weight can
> fix this, at least in a single-adapter environment.
> 

If your know your workload you could tune the weight. Additionaly you
could tune the softirq using nice.

> Second, at 10Mbps and 100Mbps, modern processors are just too fast for the
> network.  The NAPI polling loop runs so much quicker than the wire speed
> that only one or two packets are processed per softirq -- which
> effectively puts the adapter back in interrupt mode.  Because of this, you
> can easily bog down a very fast box with relatively slow traffic, just due
> to the massive number of interrupts generated.
> 

Massive is an overstatement. The issue is really IO. If you process one
packet in each interupt then NAPI does add extra IO costs at "low"
traffic levels. 
Note that this is also a known issue - reference the threads from waay
back from people like Manfred Spraul and recently from the SGI folks.

IO unfortunately hasnt kept up with CPU speeds; hardware vendors such as
your company have been busy making processors faster but forgetting
about IO and RAM latencies. PCI-E seems promising from what i have
heard, interim PCI-E bridging to PCI-X is form what i have heard on its
IO performance worse.

> My original post (and patch) were to address the first issue.  By using
> the shift value on the quota, I effectively lowered the weight for every
> driver in the system.   Stephen sent out a patch that allowed you to
> adjust each driver's weight individually.  My testing has shown that, as
> expected, you can achieve the same performance gain either way.
> 

Ok, glad to hear thats resolved.

> In a multiple-adapter environment, you need to adjust the weight of all
> drivers together to fix the dropped packets issue.  Lowering the weight on
> one adapter won't help it if the other interfaces are still taking up a
> lot of time in their receive loops.
> 
> My patch gave you one knob to twiddle that would correct this issue.
> Stephen's patch gave you one knob for each adapter, but now you need to
> twiddle them all to see any benefit.
> 

makes sense

> The second issue currently has no fix.  What is needed is a way for the
> driver to request a delayed poll, possibly based on line speed.  If we
> could wait, say, 8 packet times before polling, we could significantly
> reduce the number of interrupts the system has to deal with, at the cost
> of higher latency.  We haven't had time to investigate this at all, but
> the need is clearly present -- we've had customer calls about this issue.
> 

I can believe you (note it has to do with IO costs though) having seen
how horrific MMIO numbers are on faster processors. Talk to Jesse, he
has seen a little program from Lennert/Robert/Harald that does MMIO
measurements.
It seems the trend is that as CPUs get faster, IO gets more expensive in
both cpu cycles as well as absolute time.
The solution to this issue is to be found in mitigation at the moment in
conjunction with NAPI.
The SGI folks have made some real progress with recent patches from
Davem and Michael Chan on tg3.
I have been experimenting with some patches but they introduce
unacceptable jitter in latency.
So lets summarize it this way: This is something that needs to be
resolved - but whatever solution needs to be generic.

> Either way, I think the netdev community needs to look critically at NAPI,
> and make some changes.   

I think what you call as the second issue needs a solution. Mitigation
is the only generic solution at the moment.

> Network performance in 2.6.12-rcWhatever is
> pretty poor.  2.4.30 beats it handily, and it really shouldn't be that
> way.
> 

Are you using NAPI as well on 2.4.30?

cheers,
jamal
