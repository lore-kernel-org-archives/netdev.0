From: Mitch Williams <mitch.a.williams@intel.com>
Subject: Re: RFC: NAPI packet weighting patch
Date: Fri, 3 Jun 2005 10:43:32 -0700
Message-ID: <Pine.CYG.4.58.0506030929300.2788@mawilli1-desk2.amr.corp.intel.com>
References: <468F3FDA28AA87429AD807992E22D07E0450BFDB@orsmsx408>
 <20050602.171812.48807872.davem@davemloft.net> <1117765954.6095.49.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
        "Ronciak, John" <john.ronciak@intel.com>, jdmason@us.ibm.com,
        shemminger@osdl.org, netdev@oss.sgi.com, Robert.Olsson@data.slu.se,
        "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <1117765954.6095.49.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Thu, 2 Jun 2005, jamal wrote:
>
> Heres what i think i saw as a flow of events:
> Someone posted a theory that if you happen to reduce the weight
> (iirc the reduction was via a shift) then the DRR would give less CPU
> time cycle to the driver - Whats the big suprise there? thats DRR design
> intent.

Well, that was me.  Or at least I was the original poster on this thread.
But my theory (if you can call it that) really wasn't about CPU time.  I
spent several weeks in our lab with the somewhat nebulous task of "look at
Linux performance".  And what I found was, to me, counterintuitive:
reducing weight improved performance, sometimes significantly.

>
> Stephen has a patch which allows people to reduce the weight.
> DRR  provides fairness. If you have 10 NICs coming at different wire
> rates, the weights provide a fairness quota without caring about what
> those speeds are. So it doesnt make any sense IMO to have the weight
> based on what the NIC speed is. Infact i claim it is _nonsense_. You
> dont need to factor speed. And the claim that DRR is not real world
> is blasphemous.

OK, well, call me a blasphemer (against whom?).  I'm not really saying
that the DRR algorithm is not real-world, but rather that NAPI as
currently implemented has some significant performance limitations.

In my mind, there are two major problems with NAPI as it stands today.
First, at Gigabit and higher speeds, the default settings don't allow the
driver to process received packets in a timely manner.  This causes
dropped packets due to lack of receive resources.  Lowering the weight can
fix this, at least in a single-adapter environment.

Second, at 10Mbps and 100Mbps, modern processors are just too fast for the
network.  The NAPI polling loop runs so much quicker than the wire speed
that only one or two packets are processed per softirq -- which
effectively puts the adapter back in interrupt mode.  Because of this, you
can easily bog down a very fast box with relatively slow traffic, just due
to the massive number of interrupts generated.

My original post (and patch) were to address the first issue.  By using
the shift value on the quota, I effectively lowered the weight for every
driver in the system.   Stephen sent out a patch that allowed you to
adjust each driver's weight individually.  My testing has shown that, as
expected, you can achieve the same performance gain either way.

In a multiple-adapter environment, you need to adjust the weight of all
drivers together to fix the dropped packets issue.  Lowering the weight on
one adapter won't help it if the other interfaces are still taking up a
lot of time in their receive loops.

My patch gave you one knob to twiddle that would correct this issue.
Stephen's patch gave you one knob for each adapter, but now you need to
twiddle them all to see any benefit.

The second issue currently has no fix.  What is needed is a way for the
driver to request a delayed poll, possibly based on line speed.  If we
could wait, say, 8 packet times before polling, we could significantly
reduce the number of interrupts the system has to deal with, at the cost
of higher latency.  We haven't had time to investigate this at all, but
the need is clearly present -- we've had customer calls about this issue.

>
> Having said that:
> I have a feeling that issue which is which is being waded around is the
> amount that the softirq chews in the CPU (unfortunately a well known
> issue) and to some extent the packet flow a specific driver chews
> depending on the path it takes.

I fiddled with this concept a little bit, but didn't see much performance
gain by doing so.  But it may be something that we can go back and look
at.

Either way, I think the netdev community needs to look critically at NAPI,
and make some changes.   Network performance in 2.6.12-rcWhatever is
pretty poor.  2.4.30 beats it handily, and it really shouldn't be that
way.


> This, however, does not eradicate the need for DRR and is absolutely not
> driver specific.

Agreed.  All of the changes I've experimented with at the NAPI level have
affected performance similarly on multiple drivers.

-Mitch
