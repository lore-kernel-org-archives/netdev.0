From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/2] CARP implementation. HA master's failover.
Date: Sat, 17 Jul 2004 18:00:19 +0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040717180019.7db1473f@zanzibar.2ka.mipt.ru>
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
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netfilter-failover@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1090068454.1064.1258.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 17 Jul 2004 08:47:34 -0400
jamal <hadi@cyberus.ca> wrote:

jamal> I relabeled the Apps. I suppose you see some apps using ctsyncd
for something?

>>You need to connect each application daemon to carpd, even using
>>broadcast netlink. And for any in-kernel access you will need to
>>create
>>new App and new kernel part.

jamal> App2app doesnt have to go across kernel unless it turns out it is
jamal> the best way.
jamal> Alternatives include: unix or local host sockets, IPCs such as
jamal> pipes or 
jamal> just shared libraries.

MICROKERNEL, I see it :)
Non broacast/multicast will _strongly_ complicate protocol.
Broadcast will waste apprication/kernel "bandwidth".

>>If we will extrapolate it we can create following:
>>userspace carp determines that it is a master, it will suspend all
>>kernel memory or dump /proc/kmem and begins to advertise it. Remote
>>node
>>receives it and has pretty the same firewall settings, flow controls
>>and
>>any in-kernel state.

jamal> I havent studied what Harald proposes in details. I think that
jamal> the slave would 
jamal> continously be getting master updates.

Is it is.

jamal> The interesting thing about CARP is the ARP balancing feature in
jamal> which X nodes 
jamal> maybe masters of different IP flows all within the
jamal> same subnet. 
jamal> VRRP load balances by subnet. I am not sure how
jamal> challenge this will present to 
jamal> to ctsyncd.

CARP may do it, but it requires in-kernel hack into arp code.
Actually OpenBSD's one has it's entry in if_ether.c so their CARP always
has access to any network dataflow.

BTW, with your approach hack from arp code needs to send a message to
userspace carp to ask if it "good or bad" packet.
Or you need to create tc for arp.

Or to communicate with in-kernel CARP. :)

>>No matter that it takes a long time.

>>It make sence if App#X needs userspace access only.
>>But here is other diagram:

                                        userspace
                 |
-----------------+-------------------------------
                CARP                  kernelspace
                 |
                 |
+----------+-----+-----+---------+-------
|          |           |         |
ct_sync  iSCSI       e1000      CPU


>>My main idea for in-kernel CARP was to implement invisible HA
>>mechanism
>>suitable for in-kernel use. You do not need to create netlink protocol
>>parser, you do not need to create extra userspace overhead, you do not
>>need to create suitable for userspace control hooks in kernel
>>infrastructure. Just register callback.
>>But even with such simple approach you have opportunity to collaborate
>>with userspace. If you need.

>>Why creating all userspace cruft if/when you need only kernel one?

jamal> 
jamal> so we now move appA, B, C to the kernel too?
jamal> There is absolutely no need to put this in kernel space.
jamal> If you do this, your next step should be to put zebra in the
jamal> kernel

No.
And this is the beauty of the in-kernel CARP.
You _already_ has in-kernel parts which may need master/slave failover.

You just need to connect it to arbiter.

With userspace you _need_ to create all those Apps connected to
userspace carp, with in-kernel CARP you need to just register callback.
One function call.

BTW, someone created tux, khtpd, knfsd :)
But i think zebra must live in userspace, since it do not need to
control any kernel parameters.

CARP _may_ control kernel parameters.
If you do not need in-kernel functionality just use UCARP.

>>Resume: 
>>With your approach any data flow MUST go through userspace arbiters
>>with
>>all overhead and complexity. With my approach any data flow _MAY_ go
>>through userspace arbiters, but if you do_need/only_has in-kernel
>>access
>>than using in-kernel CARP is the only solution.

jamal> Yes, there is a cost. How much? Read the paper on user space
jamal> drivers it actually does 
jamal> some cost analysis.
jamal> If you prove that it is too expensive to put it in user space
jamal> then prove it and lets 
jamal> have a re-discussion

Hey-ho, easily :)

Consider embedded processors.
Numbers: ppc405gp, 200mhz, 32mb sdram.
Application - 4-8 DSP processors controlled by ppc.
Each dsp processor generates 6-8 bytes frame with 8khz frequency in
each channel(from 1 to 2). 
Driver reads data from each DSP and doing some postprocessing(mainly
split it into B/D channels). Driver has clever mapping so
userspace<->kernelspace dataflow may be zerocopied.

Kernelspace processing takes up to 133mghz of 200.

Consider userspace application that 
a. makes PCM stereo from different B/D logical channels (zerocopied from
kernelspace).
b. send it into network (using tcp by bad historical/compatibility
reasons).

Situation: if we have one userspace process(or even thread) per DSP,
than context switching takes too long time and we see data corruption.
None network parameter(100 mb network) can improve situation.
Only one process per 4 DSP may send data into network stack without any
data loss.

P.S. It is 2.4.25 kernel.

I do believe that Peter Chubb (peterc@gelato.unsw.edu.au) will talk
about big machines where big tasks _may_ have big time latencies.

May Oracle have little latencies? May. But it also _may_ have big
latencies. Why not? 

DSP and sound/video capturing _may_not_ have big latencies.

Although I do think that talk about userspace drivers is not an issue in
our discussion :)


> 
> cheers,
> jamal
> 


	Evgeniy Polyakov ( s0mbre )

Only failure makes us experts. -- Theo de Raadt
