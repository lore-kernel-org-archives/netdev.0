From: jamal <hadi@cyberus.ca>
Subject: Re: [1/2] CARP implementation. HA master's failover.
Date: 17 Jul 2004 12:29:41 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1090081781.1063.1346.camel@jzny.localdomain>
References: <1089898303.6114.859.camel@uganda>
	 <1089898595.6114.866.camel@uganda>
	 <1089902654.1029.23.camel@jzny.localdomain>
	 <1089905244.6114.887.camel@uganda>
	 <1089907622.1027.48.camel@jzny.localdomain>
	 <1089910760.6114.967.camel@uganda>
	 <1089912285.1028.93.camel@jzny.localdomain>
	 <20040715235313.69897131@zanzibar.2ka.mipt.ru>
	 <1089983064.1060.1328.camel@jzny.localdomain>
	 <1089990401.6114.2843.camel@uganda>
	 <1090068454.1064.1258.camel@jzny.localdomain>
	 <20040717180019.7db1473f@zanzibar.2ka.mipt.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netfilter-failover@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: johnpol@2ka.mipt.ru
In-Reply-To: <20040717180019.7db1473f@zanzibar.2ka.mipt.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2004-07-17 at 10:00, Evgeniy Polyakov wrote:
> On 17 Jul 2004 08:47:34 -0400
> jamal <hadi@cyberus.ca> wrote:

> jamal> App2app doesnt have to go across kernel unless it turns out it is
> jamal> the best way.
> jamal> Alternatives include: unix or local host sockets, IPCs such as
> jamal> pipes or 
> jamal> just shared libraries.
> 
> MICROKERNEL, I see it :)

Maybe subconsciouly, but not intentional ;->

> Non broacast/multicast will _strongly_ complicate protocol.
> Broadcast will waste apprication/kernel "bandwidth".

You could run multicast UDP over localhost; But that will be valuable if
you have one-to-many relationship. I guess theres such a relationship
between CARPd and other apps.


> 
> jamal> The interesting thing about CARP is the ARP balancing feature in
> jamal> which X nodes 
> jamal> maybe masters of different IP flows all within the
> jamal> same subnet. 
> jamal> VRRP load balances by subnet. I am not sure how
> jamal> challenge this will present to 
> jamal> to ctsyncd.
> 
> CARP may do it, but it requires in-kernel hack into arp code.
> Actually OpenBSD's one has it's entry in if_ether.c so their CARP always
> has access to any network dataflow.

Look at my comment in other email. Pick 2.6.8-rc1 and you could do that
in a hearbeat.

> BTW, with your approach hack from arp code needs to send a message to
> userspace carp to ask if it "good or bad" packet.
> Or you need to create tc for arp.

carpd gets a policy to tell it what rules to install.
It installs them via netlink or tc.
Unwanted arp packets get dropped before they ARP code sees them.

> Or to communicate with in-kernel CARP. :)

>                                         userspace
>                  |
> -----------------+-------------------------------
>                 CARP                  kernelspace
>                  |
>                  |
> +----------+-----+-----+---------+-------
> |          |           |         |
> ct_sync  iSCSI       e1000      CPU
> 
> 
> >>My main idea for in-kernel CARP was to implement invisible HA
> >>mechanism
> >>suitable for in-kernel use. You do not need to create netlink protocol
> >>parser, you do not need to create extra userspace overhead, you do not
> >>need to create suitable for userspace control hooks in kernel
> >>infrastructure. Just register callback.
> >>But even with such simple approach you have opportunity to collaborate
> >>with userspace. If you need.
> 
> >>Why creating all userspace cruft if/when you need only kernel one?
> 
> jamal> 
> jamal> so we now move appA, B, C to the kernel too?
> jamal> There is absolutely no need to put this in kernel space.
> jamal> If you do this, your next step should be to put zebra in the
> jamal> kernel
> 
> No.
> And this is the beauty of the in-kernel CARP.
> You _already_ has in-kernel parts which may need master/slave failover.
> 
> You just need to connect it to arbiter.

Sure - such arbitrer could reside in user space too.
And apps could connect to it as well. 
App wishing to listen to mastership changes joins a UDP mcast on
localhost. CARPd announces such changes on localhost mcast channel.
To make it more interesting, allow apps to query mastership and
other state.

> With userspace you _need_ to create all those Apps connected to
> userspace carp, with in-kernel CARP you need to just register callback.
> One function call.

Maybe i didnt explain well. Only apps interested in carp activities
connect to it; such an app would be ctsyncd. If you use shared
libraries, then you register a callback. Or you could use localhost
mcast example i gave above.

> BTW, someone created tux, khtpd, knfsd :)

I thoughth there were people who can beat tux from userspace these days
by virtue of numbers. But note again that things like these are datapath
level apps unlike CARP.

> But i think zebra must live in userspace, since it do not need to
> control any kernel parameters.
> 
> CARP _may_ control kernel parameters.
> If you do not need in-kernel functionality just use UCARP.

I am not sure i follow. You are proposing to do something like arp/arpd
now? Look at that code.

> jamal> If you prove that it is too expensive to put it in user space
> jamal> then prove it and lets 
> jamal> have a re-discussion
> 
> Hey-ho, easily :)
> 
> Consider embedded processors.
> Numbers: ppc405gp, 200mhz, 32mb sdram.
> Application - 4-8 DSP processors controlled by ppc.
> Each dsp processor generates 6-8 bytes frame with 8khz frequency in
> each channel(from 1 to 2). 
> Driver reads data from each DSP and doing some postprocessing(mainly
> split it into B/D channels). Driver has clever mapping so
> userspace<->kernelspace dataflow may be zerocopied.

Sure. Maybe mmap would suffice.

> Kernelspace processing takes up to 133mghz of 200.

How did you measure this?

> Consider userspace application that 
> a. makes PCM stereo from different B/D logical channels (zerocopied from
> kernelspace).
> b. send it into network (using tcp by bad historical/compatibility
> reasons).
> 
> Situation: if we have one userspace process(or even thread) per DSP,
> than context switching takes too long time and we see data corruption.
> None network parameter(100 mb network) can improve situation.
> Only one process per 4 DSP may send data into network stack without any
> data loss.

I am suprised abou the threads being problematic in context switch.
 
> P.S. It is 2.4.25 kernel.

I still dont like what you have described above ;-> It needs to be
qunatitative instead of qualitative. i.e "heres some numbers when X was
done and heres the numbers when Y was done".

> I do believe that Peter Chubb (peterc@gelato.unsw.edu.au) will talk
> about big machines where big tasks _may_ have big time latencies.
> 
> May Oracle have little latencies? May. But it also _may_ have big
> latencies. Why not? 
> 
> DSP and sound/video capturing _may_not_ have big latencies.
> 
> Although I do think that talk about userspace drivers is not an issue in
> our discussion :)


I agree. Let me summarize what i think is the most valuable thing you
have said so far - you could disagree, but this is my opinion of what i
think the most valuable thing  you said :

in the model where all things have to cross userspace-kernel boundary,
there is some cost associated. This is plausible when such crossings get
to be _very_ frequent. _very frequent needs to be quantified.
I claim from my experiences (running on small 824x ppc) that the cost is
highly exagerated. 
How about this: Look at the way arp does things and emulate it.
The way arp does it is still insufficient because it maintains a
threshold first that when exceeded is the only time control packets
get sent to user space.
You should have a sysctl where your code ships things to user space
every time when the systcl is set.
This is easy to do if you wrote the whole thing as a tc action instead
of a device driver.

> 	Evgeniy Polyakov ( s0mbre )
> 
> Only failure makes us experts. -- Theo de Raadt

To support mr de Raadt above:

"repeating failures makes you a sinner"
In other words, learn from the failures.

cheers,
jamal
