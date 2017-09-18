From: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Subject: Re: [RFC net-next 0/5] TSN: Add qdisc-based config interfaces for traffic shapers
Date: Mon, 18 Sep 2017 16:06:28 -0700
Message-ID: <87k20vip3f.fsf@intel.com>
References: <20170901012625.14838-1-vinicius.gomes@intel.com> <20170918080214.yrejz67wwnp2pjzf@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        jiri@resnulli.us, intel-wired-lan@lists.osuosl.org,
        andre.guedes@intel.com, ivan.briano@intel.com,
        jesus.sanchez-palencia@intel.com, boon.leong.ong@intel.com
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:36718 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751301AbdIRXG3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 18 Sep 2017 19:06:29 -0400
In-Reply-To: <20170918080214.yrejz67wwnp2pjzf@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Richard,

Richard Cochran <richardcochran@gmail.com> writes:

> On Thu, Aug 31, 2017 at 06:26:20PM -0700, Vinicius Costa Gomes wrote:
>>  * Time-aware shaper (802.1Qbv):
>
> I just posted a working alternative showing how to handle 802.1Qbv and
> many other Ethernet field buses.
>
>>    The idea we are currently exploring is to add a "time-aware", priority based
>>    qdisc, that also exposes the Tx queues available and provides a mechanism for
>>    mapping priority <-> traffic class <-> Tx queues in a similar fashion as
>>    mqprio. We are calling this qdisc 'taprio', and its 'tc' cmd line would be:
>>
>>    $ $ tc qdisc add dev ens4 parent root handle 100 taprio num_tc 4    \
>>      	   map 2 2 1 0 3 3 3 3 3 3 3 3 3 3 3 3                         \
>> 	   queues 0 1 2 3                                              \
>>      	   sched-file gates.sched [base-time <interval>]               \
>>            [cycle-time <interval>] [extension-time <interval>]
>>
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
> The idea of the schedule file will not work in practice.  Consider the
> fact that the application wants to deliver time critical data in a
> particular slot.  How can it find out a) what the time slots are and
> b) when the next slot is scheduled?  With this Qdisc, it cannot do
> this, AFAICT.  The admin might delete the file after configuring the
> Qdisc!

That's the point, the application does not need to know that, and asking
that would be stupid. From the point of view of the Qbv specification,
applications only need to care about its basic bandwidth requirements:
its interval, frame size, frames per interval (using the terms of the
SRP section of 802.1Q). The traffic schedule is provided (off band) by a
"god box" which knows all the requirements of all applications in all
the nodes and how they are connected.

(And that's another nice point of how 802.1Qbv works, applications do
not need to be changed to use it, and I think we should work to achieve
this on the Linux side)

That being said, that only works for kinds of traffic that maps well to
this configuration in advance model, which is the model that the IEEE
(see 802.1Qcc) and the AVNU Alliance[1] are pushing for.

In the real world, I can see multiple types of applications, some using
something like TXTIME, and some configured in advance.

>
> Using the SO_TXTIME option, the application has total control over the
> scheduling.  The great advantages of this approach is that we can
> support any possible combination of periodic or aperiodic scheduling
> and we can support any priority scheme user space dreams up.

It has the disavantage of that the scheduling information has to be
in-band with the data. I *really* think that for scheduled traffic,
there should be a clear separation, we should not mix the dataflow with
scheduling. In short, an application in the network don't need to have
all the information necessary to schedule its own traffic well.

I have two points here: 1. I see both "solutions" (taprio and SO_TXTIME)
as being ortoghonal and useful, both; 2. trying to make one do the job
of the other, however, looks like "If all I have is a hammer, everything
looks like a nail".

In short, I see a per-packet transmission time and a per-queue schedule
as solutions to different problems.

>
> For example, one can imaging running two or more loops that only
> occasionally collide.  When they do collide, which packet should be
> sent first?  Just let user space decide.
>
> Thanks,
> Richard

Cheers,
