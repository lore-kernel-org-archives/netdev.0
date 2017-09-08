From: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Subject: Re: [RFC net-next 0/5] TSN: Add qdisc-based config interfaces for traffic shapers
Date: Thu, 07 Sep 2017 18:29:00 -0700
Message-ID: <87k21am10j.fsf@intel.com>
References: <20170901012625.14838-1-vinicius.gomes@intel.com> <20170907053411.GA6580@sisyphus.home.austad.us>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        jiri@resnulli.us, intel-wired-lan@lists.osuosl.org,
        andre.guedes@intel.com, ivan.briano@intel.com,
        jesus.sanchez-palencia@intel.com, boon.leong.ong@intel.com,
        richardcochran@gmail.com
To: Henrik Austad <henrik@austad.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:1882 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753103AbdIHB3B (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 7 Sep 2017 21:29:01 -0400
In-Reply-To: <20170907053411.GA6580@sisyphus.home.austad.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Henrik Austad <henrik@austad.us> writes:

> On Thu, Aug 31, 2017 at 06:26:20PM -0700, Vinicius Costa Gomes wrote:
>> Hi,
>>
>> This patchset is an RFC on a proposal of how the Traffic Control subsystem can
>> be used to offload the configuration of traffic shapers into network devices
>> that provide support for them in HW. Our goal here is to start upstreaming
>> support for features related to the Time-Sensitive Networking (TSN) set of
>> standards into the kernel.
>
> Nice to see that others are working on this as well! :)
>
> A short disclaimer; I'm pretty much anchored in the view "linux is the
> end-station in a TSN domain", is this your approach as well, or are you
> looking at this driver to be used in bridges as well? (because that will
> affect the comments on time-aware shaper and frame preemption)
>
> Yet another disclaimer; I am not a linux networking subsystem expert. Not
> by a long shot! There are black magic happening in the internals of the
> networking subsystem that I am not even aware of. So if something I say or
> ask does not make sense _at_all_, that's probably why..
>
> I do know a tiny bit about TSN though, and I have been messing around
> with it for a little while, hence my comments below
>
>> As part of this work, we've assessed previous public discussions related to TSN
>> enabling: patches from Henrik Austad (Cisco), the presentation from Eric Mann
>> at Linux Plumbers 2012, patches from Gangfeng Huang (National Instruments) and
>> the current state of the OpenAVNU project (https://github.com/AVnu/OpenAvnu/).
>
> /me eyes Cc ;p
>
>> Overview
>> ========
>>
>> Time-sensitive Networking (TSN) is a set of standards that aim to address
>> resources availability for providing bandwidth reservation and bounded latency
>> on Ethernet based LANs. The proposal described here aims to cover mainly what is
>> needed to enable the following standards: 802.1Qat, 802.1Qav, 802.1Qbv and
>> 802.1Qbu.
>>
>> The initial target of this work is the Intel i210 NIC, but other controllers'
>> datasheet were also taken into account, like the Renesas RZ/A1H RZ/A1M group and
>> the Synopsis DesignWare Ethernet QoS controller.
>
> NXP has a TSN aware chip on the i.MX7 sabre board as well </fyi>

Cool. Will take a look.

>
>> Proposal
>> ========
>>
>> Feature-wise, what is covered here are configuration interfaces for HW
>> implementations of the Credit-Based shaper (CBS, 802.1Qav), Time-Aware shaper
>> (802.1Qbv) and Frame Preemption (802.1Qbu). CBS is a per-queue shaper, while
>> Qbv and Qbu must be configured per port, with the configuration covering all
>> queues. Given that these features are related to traffic shaping, and that the
>> traffic control subsystem already provides a queueing discipline that offloads
>> config into the device driver (i.e. mqprio), designing new qdiscs for the
>> specific purpose of offloading the config for each shaper seemed like a good
>> fit.
>
> just to be clear, you register sch_cbs as a subclass to mqprio, not as a
> root class?

That's right.

>
>> For steering traffic into the correct queues, we use the socket option
>> SO_PRIORITY and then a mechanism to map priority to traffic classes / Tx queues.
>> The qdisc mqprio is currently used in our tests.
>
> Right, fair enough, I'd prefer the TSN qdisc to be the root-device and
> rather have mqprio for high priority traffic and another for 'everything
> else'', but this would work too. This is not that relevant at this stage I
> guess :)

That's a scenario I haven't considered, will give it some thought.

>
>> As for the shapers config interface:
>>
>>  * CBS (802.1Qav)
>>
>>    This patchset is proposing a new qdisc called 'cbs'. Its 'tc' cmd line is:
>>    $ tc qdisc add dev IFACE parent ID cbs locredit N hicredit M sendslope S \
>>      idleslope I
>
> So this confuses me a bit, why specify sendSlope?
>
>     sendSlope = portTransmitRate - idleSlope
>
> and portTransmitRate is the speed of the MAC (which you get from the
> driver). Adding sendSlope here is just redundant I think.
>
> Also, does this mean that when you create the qdisc, you have locked the
> bandwidth for the scheduler? Meaning, if I later want to add another
> stream that requires more bandwidth, I have to close all active streams,
> reconfigure the qdisc and then restart?
>
>>    Note that the parameters for this qdisc are the ones defined by the
>>    802.1Q-2014 spec, so no hardware specific functionality is exposed here.
>
> You do need to know if the link is brought up as 100 or 1000 though - which
> the driver already knows.
>
>>  * Time-aware shaper (802.1Qbv):
>>
>>    The idea we are currently exploring is to add a "time-aware", priority based
>>    qdisc, that also exposes the Tx queues available and provides a mechanism for
>>    mapping priority <-> traffic class <-> Tx queues in a similar fashion as
>>    mqprio. We are calling this qdisc 'taprio', and its 'tc' cmd line would be:
>
> As far as I know, this is not supported by i210, and if time-aware shaping
> is enabled in the network - you'll be queued on a bridge until the window
> opens as time-aware shaping is enforced on the tx-port and not on rx. Is
> this required in this driver?

Yeah, i210 doesn't support the time-aware shaper. I think the second
part of your question doesn't really apply, then.

>
>>    $ $ tc qdisc add dev ens4 parent root handle 100 taprio num_tc 4    \
>>      	   map 2 2 1 0 3 3 3 3 3 3 3 3 3 3 3 3                         \
>> 	   queues 0 1 2 3                                              \
>>      	   sched-file gates.sched [base-time <interval>]               \
>>            [cycle-time <interval>] [extension-time <interval>]
>
> That was a lot of priorities! 802.1Q lists 8 priorities, where does these
> 16 come from?

Even if the 802.1Q only defines 8 priorities, the Linux network stack
supports a lot more (and this command line is more than slightly
inspired by the mqprio equivalent).

>
> You map pri 0,1 to queue 2, pri 2 to queue 1 (Class B), pri 3 to queue 0
> (class A) and everythign else to queue 3. This is what I would expect,
> except for the additional 8 priorities.
>
>>    <file> is multi-line, with each line being of the following format:
>>    <cmd> <gate mask> <interval in nanoseconds>
>>
>>    Qbv only defines one <cmd>: "S" for 'SetGates'
>>
>>    For example:
>>
>>    S 0x01 300
>>    S 0x03 500
>>
>>    This means that there are two intervals, the first will have the gate
>>    for traffic class 0 open for 300 nanoseconds, the second will have
>>    both traffic classes open for 500 nanoseconds.
>
> Are you aware of any hw except dedicated switching stuff that supports
> this? (meant as "I'm curious and would like to know")

Not really. I couldn't find any public documentation about products
destined for end stations that support this. I, too, would like to know
more.

>
>>    Additionally, an option to set just one entry of the gate control list will
>>    also be provided by 'taprio':
>>
>>    $ tc qdisc (...) \
>>         sched-row <row number> <cmd> <gate mask> <interval>  \
>>         [base-time <interval>] [cycle-time <interval>] \
>>         [extension-time <interval>]
>>
>>
>>  * Frame Preemption (802.1Qbu):
>
> So Frame preemption is nice, but my understanding of Qbu is that the real
> benefit is at the bridges and not in the endpoints. As jumbo-frames is
> explicitly disallowed in Qav, the maximum latency incurred by a frame in
> flight is 12us on a 1Gbps link. I am not sure if these 12us is what will be
> the main delay in your application.
>
> Or have I missed some crucial point here?


You didn't seem to have missed anything. What I saw as the biggest point
for frame preemption, is when it is used with scheduled traffic, you
could keep the preemptable traffic classes gates always open, have a few
time windows for periodic traffic, and still have predictable behaviour
for an unscheduled "emergency" traffic.


Cheers,
