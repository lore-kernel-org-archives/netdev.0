From: Levi Pearson <levipearson@gmail.com>
Subject: Re: [RFC net-next 0/5] TSN: Add qdisc-based config interfaces for
 traffic shapers
Date: Mon, 2 Oct 2017 15:48:46 -0600
Message-ID: <CAEYbN3TWwPjoHW-wQ9DC=ubXELoZ4jbMUTX_+D3Rn_h=6LHvDA@mail.gmail.com>
References: <DM2PR0401MB1389A950EAC6FB54D4186B9C927E0@DM2PR0401MB1389.namprd04.prod.outlook.com>
 <CAEYbN3STY+7ZOodQLaP4MfbvwCovWsav52PXBmjHND7QOO=srg@mail.gmail.com> <DM2PR0401MB138982C6B22DF8154A82DB39927D0@DM2PR0401MB1389.namprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Vinicius Costa Gomes <vinicius.gomes@intel.com>,
        Henrik Austad <henrik@austad.us>,
        "richardcochran@gmail.com" <richardcochran@gmail.com>,
        "jesus.sanchez-palencia@intel.com" <jesus.sanchez-palencia@intel.com>,
        "andre.guedes@intel.com" <andre.guedes@intel.com>
To: Rodney Cummings <rodney.cummings@ni.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:45459 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751756AbdJBVss (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 17:48:48 -0400
Received: by mail-wm0-f42.google.com with SMTP id q124so13157609wmb.0
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 14:48:48 -0700 (PDT)
In-Reply-To: <DM2PR0401MB138982C6B22DF8154A82DB39927D0@DM2PR0401MB1389.namprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Rodney,

On Mon, Oct 2, 2017 at 1:40 PM, Rodney Cummings <rodney.cummings@ni.com> wrote:

> It's a shame that someone built such hardware. Speaking as a manufacturer
> of daisy-chainable products for industrial/automotive applications, I
> wouldn't use that hardware in my products. The whole point of scheduling
> is to obtain close-to-optimal network determinism. If the hardware
> doesn't schedule properly, the product is probably better off using CBS.

I should note that the hardware I'm using was not designed to be a TSN
endpoint. It just happens that the hardware, designed for other
reasons, happens to have hardware support for Qbv and thus makes it an
interesting and inexpensive platform on which to do Qbv experiments.
Nevertheless, I believe the right combination of driver support for
the hardware shaping and appropriate software in the network stack
would allow it to schedule things fairly precisely in the
application-centric manner you've described. I will ultimately defer
to your judgement on that, though, and spend some time with the Qcc
draft to see where I may be wrong.

> It would be great if all of the user-level application code was scheduled
> as tightly as the network, but the reality is that we aren't there yet.
> Also, even if the end-station has a separately timed RT Linux thread for
> each stream, the order of those threads can vary. Therefore, when the
> end-station (SoC) has more than one talker, the frames for each talker
> can be written into the Qbv queue at any time, in any order.
> There is no scheduling of frames (i.e. streams)... only the queue.

Frames are presented to *the kernel* in any order. The qdisc
infrastructure provides mechanisms by which other scheduling policy
can be added between presentation to the kernel and presentation to
hardware queues.

Even with i210-style LaunchTime functionality, this must also be
provided. The hardware cannot re-order time-scheduled frames, and
reviewers of the SO_TXTIME proposal rejected the idea of having the
driver try to re-order scheduled frames already submitted to the
hardware-visible descriptor chains, and rightly so I think.

So far, I have thought of 3 places this ordering constraint might be provided:

1. Built into each driver with offload support for SO_TXTIME
2. A qdisc module that will re-order scheduled skbuffs within a certain window
3. Left to userspace to coordinate

I think 1 is particularly bad due to duplication of code. 3 is the
easy default from the point of view of the kernel, but not attractive
from the point of view of precise scheduling and low latency to
egress. Unless someone has a better idea, I think 2 would be the most
appropriate choice. I can think of a number of ways one might be
designed, but I have not thought them through fully yet.

> From the perspective of the CNC, that means that a Qbv-only end-station is
> sloppy. In contrast, an end-station using per-stream scheduling
> (e.g. i210 with LaunchTime) is precise, because each frame has a known time.
> It's true that P802.1Qcc supports both, so the CNC might support both.
> Nevertheless, the CNC is likely to compute a network-wide schedule
> that optimizes for the per-stream end-stations, and locates the windows
> for the Qbv-only end-stations in a slower interval.

Because out-of-order submission of frames to LaunchTime hardware would
result in the frame that is enqueued later but scheduled earlier only
transmitting once the later-scheduled frame completes, enqueuing
frames immediately with LaunchTime information results in even *worse*
sloppiness if two applications don't always submit their frames in the
correct order to the kernel during a cycle. If your queue is simply
gated at the time of the first scheduled launch, the frame that should
have been first will only be late by the length of the queued-first
frame. If they both have precise launch times, the frame that should
have been first will have to wait until the normal launch time of the
later-scheduled frame plus the time it takes for it to egress!

In either case, re-ordering is required if it is not controlled for in
userspace. In other words, I am not disagreeing with you about the
insufficiency of a Qbv shaper for an endpoint! I am just pointing out
that neither hardware LaunchTime support nor hardware Qbv window
support are sufficient by themselves. Nor, for that case, is the CBS
offload support sufficient to meet multi-stream requirements from SRP.
All of these provide a low-layer mechanism by which appropriate
scheduling of a multi-stream or multi-application endpoint can be
enhanced, but none of them provide the complete story by themselves.

> I realize that we are only doing CBS for now. I guess my main point is that
> if/when we add scheduling, it cannot be limited to Qbv. Per-stream scheduling
> is essential, because that is the assumption for most CNC designs that
> I'm aware of.

I understand and completely agree. I have believed that per-stream
shaping/scheduling in some form is essential from the beginning.
Likewise, CBS is not sufficient in itself for multi-stream systems in
which multiple applications provide streams scheduled for the same
traffic class. But CBS and SO_TXTIME are good first steps; they
provides hooks for drivers to finally support the mechanisms provided
by hardware, and also in the case of SO_TXTIME a hook on which further
time-sensitive enhancements to the network stack can be hung, such as
qdiscs that can store and release frames based on scheduled launch
times. When these are in place, I think stream-based scheduling via
qdisc would be a reasonable next step; perhaps a common design could
be found to work both for media streams over CBS and industrial
streams scheduled by launch time.


Levi
