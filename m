From: levipearson@gmail.com
Subject: Re: [RFC net-next 0/5] TSN: Add qdisc-based config interfaces for traffic shapers
Date: Tue, 19 Sep 2017 19:59:11 -0600
Message-ID: <20170920015911.18999-1-levipearson@gmail.com>
References: <20170901012625.14838-1-vinicius.gomes@intel.com>
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
        andre.guedes@intel.com, ivan.briano@intel.com,
        jesus.sanchez-palencia@intel.com, boon.leong.ong@intel.com,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        richardcochran@gmail.com, henrik@austad.us
To: vinicius.gomes@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36220 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750733AbdITB7V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 21:59:21 -0400
Received: by mail-pf0-f193.google.com with SMTP id f84so585312pfj.3
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 18:59:21 -0700 (PDT)
In-Reply-To: <20170901012625.14838-1-vinicius.gomes@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, Aug 31, 2017 at 06:26:20PM -0700, Vinicius Costa Gomes wrote:
> Hi,
> 
> This patchset is an RFC on a proposal of how the Traffic Control subsystem can
> be used to offload the configuration of traffic shapers into network devices
> that provide support for them in HW. Our goal here is to start upstreaming
> support for features related to the Time-Sensitive Networking (TSN) set of
> standards into the kernel.

I'm very excited to see these features moving into the kernel! I am one of the
maintainers of the OpenAvnu project and I've been involved in building AVB/TSN
systems and working on the standards for around 10 years, so the support that's
been slowly making it into more silicon and now Linux drivers is very
encouraging.

My team at Harman is working on endpoint code based on what's in the OpenAvnu
project and a few Linux-based platforms. The Qav interface you've proposed will
fit nicely with our traffic shaper management daemon, which already uses mqprio
as a base but uses the htb shaper to approximate the Qav credit-based shaper on
platforms where launch time scheduling isn't available.

I've applied your patches and plan on testing them in conjunction with our
shaper manager to see if we run into any hitches, but I don't expect any
problems.

> As part of this work, we've assessed previous public discussions related to TSN
> enabling: patches from Henrik Austad (Cisco), the presentation from Eric Mann
> at Linux Plumbers 2012, patches from Gangfeng Huang (National Instruments) and
> the current state of the OpenAVNU project (https://github.com/AVnu/OpenAvnu/).
> 
> Please note that the patches provided as part of this RFC are implementing what
> is needed only for 802.1Qav (FQTSS) only, but we'd like to take advantage of
> this discussion and share our WIP ideas for the 802.1Qbv and 802.1Qbu interfaces
> as well. The current patches are only providing support for HW offload of the
> configs.
> 
> 
> Overview
> ========
> 
> Time-sensitive Networking (TSN) is a set of standards that aim to address
> resources availability for providing bandwidth reservation and bounded latency
> on Ethernet based LANs. The proposal described here aims to cover mainly what is
> needed to enable the following standards: 802.1Qat, 802.1Qav, 802.1Qbv and
> 802.1Qbu.
> 
> The initial target of this work is the Intel i210 NIC, but other controllers'
> datasheet were also taken into account, like the Renesas RZ/A1H RZ/A1M group and
> the Synopsis DesignWare Ethernet QoS controller.

Recent SoCs from NXP (the i.MX 6 SoloX, and all the i.MX 7 and 8 parts) support
Qav shaping as well as scheduled launch functionality; these are the parts I 
have been mostly working with. Marvell silicon (some subset of Armada processors
and Link Street DSA switches) generally supports traffic shaping as well.

I think a lack of an interface like this has probably slowed upstream driver
support for this functionality where it exists; most vendors have an out-of-
tree version of their driver with TSN functionality enabled via non-standard
interfaces. Hopefully making it available will encourage vendors to upstream
their driver support!

> Proposal
> ========
> 
> Feature-wise, what is covered here are configuration interfaces for HW
> implementations of the Credit-Based shaper (CBS, 802.1Qav), Time-Aware shaper
> (802.1Qbv) and Frame Preemption (802.1Qbu). CBS is a per-queue shaper, while
> Qbv and Qbu must be configured per port, with the configuration covering all
> queues. Given that these features are related to traffic shaping, and that the
> traffic control subsystem already provides a queueing discipline that offloads
> config into the device driver (i.e. mqprio), designing new qdiscs for the
> specific purpose of offloading the config for each shaper seemed like a good
> fit.

This makes sense to me too. The 802.1Q standards are all based on the sort of
mappings between priority, traffic class, and hardware queues that the existing
tc infrastructure seems to be modeling. I believe the mqprio module's mapping
scheme is flexible enough to meet any TSN needs in conjunction with the other
parts of the kernel qdisc system.

> For steering traffic into the correct queues, we use the socket option
> SO_PRIORITY and then a mechanism to map priority to traffic classes / Txqueues.
> The qdisc mqprio is currently used in our tests.
> 
> As for the shapers config interface:
> 
>  * CBS (802.1Qav)
> 
>    This patchset is proposing a new qdisc called 'cbs'. Its 'tc' cmd line is:
>    $ tc qdisc add dev IFACE parent ID cbs locredit N hicredit M sendslope S \
>      idleslope I
> 
>    Note that the parameters for this qdisc are the ones defined by the
>    802.1Q-2014 spec, so no hardware specific functionality is exposed here.

These parameters look good to me as a baseline; some additional optional
parameters may be useful for software-based implementations--such as setting an
interval at which to recalculate queues--but those can be discussed later.

>  * Time-aware shaper (802.1Qbv):

I haven't come across any specific NIC or SoC MAC that does Qbv, but I have
been experimenting with an EspressoBin board, which has a "Topaz" DSA switch
in it that has some features intended for Qbv support, although they were done
with a draft version in mind.

I haven't looked at the interaction between the qdisc subsystem and DSA yet,
but this mechanism might be useful to configure Qbv on the slave ports in
that context. I've got both the board and the documentation, so I might be
able to work on an implementation at some point.

If some endpoint device shows up with direct Qbv support, this interface would
probably work well there too, although a talker would need to be able to
schedule its transmits pretty precisely to achieve the lowest possible latency.

>    The idea we are currently exploring is to add a "time-aware", priority based
>    qdisc, that also exposes the Tx queues available and provides a mechanism for
>    mapping priority <-> traffic class <-> Tx queues in a similar fashion as
>    mqprio. We are calling this qdisc 'taprio', and its 'tc' cmd line would be:
> 
>    $ $ tc qdisc add dev ens4 parent root handle 100 taprio num_tc 4    \
>      	   map 2 2 1 0 3 3 3 3 3 3 3 3 3 3 3 3                         \
> 	   queues 0 1 2 3                                              \
>      	   sched-file gates.sched [base-time <interval>]               \
>            [cycle-time <interval>] [extension-time <interval>]

One concern here is calling the base-time parameter an interval; it's really
an absolute time with respect to the PTP timescale. Good documentation will
be important to this one, since the specification discusses some subtleties
regarding the impact of different time values chosen here.

The format for specifying the actual intervals such as cycle-time could prove
to be an important detail as well; Qbv specifies cycle-time as a ratio of two
integers expressed in seconds, while extension-time is specified as an integer
number of nanoseconds.

Precision with the cycle-time is especially important, since base-time can be
almost arbitrarily far in the past or future, and any given cycle start should
be calculable from the base-time plus/minus some integer multiple of cycle-
time.

>    <file> is multi-line, with each line being of the following format:
>    <cmd> <gate mask> <interval in nanoseconds>
> 
>    Qbv only defines one <cmd>: "S" for 'SetGates'
> 
>    For example:
> 
>    S 0x01 300
>    S 0x03 500
> 
>    This means that there are two intervals, the first will have the gate
>    for traffic class 0 open for 300 nanoseconds, the second will have
>    both traffic classes open for 500 nanoseconds.
> 
>    Additionally, an option to set just one entry of the gate control list will
>    also be provided by 'taprio':
> 
>    $ tc qdisc (...) \
>         sched-row <row number> <cmd> <gate mask> <interval>  \
>         [base-time <interval>] [cycle-time <interval>] \
>         [extension-time <interval>]

If I understand correctly, 'sched-row' is meant to be usable multiple times in
a single command and the 'sched-file' option is just a shorthand version for
large tables? Or is it meant to update an existing schedule table? It doesn't
seem very useful if it can only be specified once when the whole taprio intance
is being established.

>  * Frame Preemption (802.1Qbu):
> 
>    To control even further the latency, it may prove useful to signal which
>    traffic classes are marked as preemptable. For that, 'taprio' provides the
>    preemption command so you set each traffic class as preemptable or not:
> 
>    $ tc qdisc (...) \
>         preemption 0 1 1 1
> 
> 
>  * Time-aware shaper + Preemption:
> 
>    As an example of how Qbv and Qbu can be used together, we may specify
>    both the schedule and the preempt-mask, and this way we may also
>    specify the Set-Gates-and-Hold and Set-Gates-and-Release commands as
>    specified in the Qbu spec:
> 
>    $ tc qdisc add dev ens4 parent root handle 100 taprio num_tc 4 \
>      	   map 2 2 1 0 3 3 3 3 3 3 3 3 3 3 3 3                    \
> 	   queues 0 1 2 3                                         \
>      	   preemption 0 1 1 1                                     \
> 	   sched-file preempt_gates.sched
> 
>     <file> is multi-line, with each line being of the following format:
>     <cmd> <gate mask> <interval in nanoseconds>
> 
>     For this case, two new commands are introduced:
> 
>     "H" for 'set gates and hold'
>     "R" for 'set gates and release'
> 
>     H 0x01 300
>     R 0x03 500
> 

The new Hold and Release gate commands look right, but I'm not sure about the
preemption flags. Qbu describes a preemption parameter table indexed by
*priority* rather than traffic class or queue. These select which of two MAC
service interfaces is used by the frame at the ISS layer, either express or
preemptable, at the time the frame is selected for transmit. If my
understanding is correct, it's possible to map a preemptable priority as well
as an express priority to the same queue, so flagging preemptability at the
queue level is not correct.

I'm not aware of any endpoint interfaces that support Qbu either, nor do I 
know of any switches that support it that someone could experiment with right
now, so there's no pressure on getting that interface nailed down yet.

Hopefully you find this feedback useful, and I appreciate the effort taken to
get the RFC posted here!

Levi
