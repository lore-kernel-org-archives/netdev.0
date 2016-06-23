From: Luigi Rizzo <rizzo@iet.unipi.it>
Subject: Re: [PATCH net-next 0/4] net_sched: bulk dequeue and deferred drops
Date: Thu, 23 Jun 2016 18:21:07 +0200
Message-ID: <CA+hQ2+iH23LJ72-q1HPfv6WJcM5hYtnSOXZUiXy8Q3bE_7EdBQ@mail.gmail.com>
References: <1466576212-15012-1-git-send-email-edumazet@google.com>
 <20160622164736.0ab98e6b@redhat.com> <1466607343.6850.37.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160622174441.559023b9@redhat.com> <1466614188.6850.57.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	John Fastabend <john.r.fastabend@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:33742 "EHLO
	mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876AbcFWQVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 12:21:10 -0400
Received: by mail-lf0-f47.google.com with SMTP id f6so98893122lfg.0
        for <netdev@vger.kernel.org>; Thu, 23 Jun 2016 09:21:09 -0700 (PDT)
In-Reply-To: <1466614188.6850.57.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 22, 2016 at 6:49 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2016-06-22 at 17:44 +0200, Jesper Dangaard Brouer wrote:
>> On Wed, 22 Jun 2016 07:55:43 -0700
>> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>
>> > On Wed, 2016-06-22 at 16:47 +0200, Jesper Dangaard Brouer wrote:
>> > > On Tue, 21 Jun 2016 23:16:48 -0700
>> > > Eric Dumazet <edumazet@google.com> wrote:
>> > >
>> > > > First patch adds an additional parameter to ->enqueue() qdisc method
>> > > > so that drops can be done outside of critical section
>> > > > (after locks are released).
>> > > >
>> > > > Then fq_codel can have a small optimization to reduce number of cache
>> > > > lines misses during a drop event
>> > > > (possibly accumulating hundreds of packets to be freed).
>> > > >
>> > > > A small htb change exports the backlog in class dumps.
>> > > >
>> > > > Final patch adds bulk dequeue to qdiscs that were lacking this feature.
>> > > >
>> > > > This series brings a nice qdisc performance increase (more than 80 %
>> > > > in some cases).
>> > >
>> > > Thanks for working on this Eric! this is great work! :-)
>> >
>> > Thanks Jesper
>> >
>> > I worked yesterday on bulk enqueues, but initial results are not that
>> > great.
>>
>> Hi Eric,
>>
>> This is interesting work! But I think you should read Luigi Rizzo's
>> (Cc'ed) paper on title "A Fast and Practical Software Packet Scheduling
>> Architecture"[1]
>>
>> [1] http://info.iet.unipi.it/~luigi/papers/20160511-mysched-preprint.pdf
>>
>> Luigi will be at Netfilter Workshop next week, and will actually
>> present on topic/paper.... you two should talk ;-)
>>
>> The article is not a 100% match for what we need, but there is some
>> good ideas.  The article also have a sort of "prequeue" that
>> enqueue'ing CPUs will place packets into.
>>
>> My understanding of the article:
>>
>> 1. transmitters submit packets to an intermediate queue
>>    (replace q->enqueue call) lockless submit as queue per CPU
>>    (runs in parallel)
>>
>> 2. like we only have _one_ qdisc dequeue process, this process (called
>>    arbiter) empty the intermediate queues, and then invoke q->enqueue()
>>    and q->dequeue(). (in a locked session/region)
>>
>> 3. Packets returned from q->dequeue() is placed on an outgoing
>>    intermediate queue.
>>
>> 4. the transmitter then looks to see there are any packets to drain()
>>    from the outgoing queue.  This can run in parallel.
>>
>> If the transmitter submitting a packet, detect no arbiter is running,
>> it can become the arbiter itself.  Like we do with qdisc_run_begin()
>> setting state __QDISC___STATE_RUNNING.
>>
>> The problem with this scheme is push-back from qdisc->enqueue
>> (NET_XMIT_CN) does not "reach" us.  And push-back in-form of processes
>> blocking on qdisc root lock, but that could be handled by either
>> blocking in article's submit() or returning some congestion return code
>> from submit().
>
> Okay, I see that you prepare upcoming conference in Amsterdam,
> but please keep this thread about existing kernel code, not the one that
> eventually reach a new operating system in 5 years ;)
>
> 1) We _want_ the result of the sends, obviously.
>
> 2) We also want back pressure, without adding complex callbacks and
> ref-counting.
>
> 3) We do not want to burn a cpu per TX queue (at least one per NUMA
> node ???) only to send few packets per second,
> Our model is still interrupt based, plus NAPI for interrupt mitigation.
>
> 4) I do not want to lock an innocent cpu to send packets from other
> threads/cpu without a tight control.
>
> In the patch I sent, I basically replaced a locked operation
> (spin_lock(&q->busylock)) with another one (xchg()) , but I did not add
> yet another queue before the qdisc ones, bufferbloat forbids.
>
> The virtual queue here is one packet per cpu, which basically is the
> same than before this patch, since each cpu spinning on busylock has one
> skb to send anyway.
>
> This is basically a simple extension of MCS locks, where the cpu at the
> head of the queue can queue up to 16 packets, instead of queueing its
> own packet only and give queue owner ship to the following cpu.

Hi Eric (and others),

don't worry, my proposal (PSPAT) is not specifically addressing/targeting
the linux qdisc now, but at the same time it does have any of the
faults you are worried about.

My target, at a high level, is a VM hosting node where the guest VMs
may create large amounts of traffic, maybe most of it doomed to be dropped,
but still consuming theirs and system's resources by creating the
packets and pounding on the xmit calls.

The goal of PSPAT is to let those clients know very early (possibly even
before doing lookups or encapsulation) when the underlying path
to the NIC will be essentially free for transmission, at which
point the sender can complete building the packet and push it out.


To comment on your observations, PSPAT has the following features:

1) it does return the result of the send, which is run by the individual
   thread who submitted the packet when it gets grant to
   transmit (this also covers your point #4). Note that by the time
   you can do a send, the underlying path is free so it should
   not fail unless the link goes down. Conversely, if the user-visible
   queue is full or almost full, you'll get a drop or congestion
   notification even before talking to the arbiter.

2) it does support backpressure, because said thread has direct access
   to the queue's state when it submits the request.
   The queue visible to the thread is the same per-flow queue used
   by the scheduler, so it does not create additional queueing,
   and the qdisc->enqueue() will never fail
   (see #A below for more details on queues)

3) it does not burn a core per tx-queue to run the arbiter.
   The thread that in PSPAT runs the arbiter is essentially
   the NAPI thread, and under normal conditions it is asleep.
   It wakes up only on tx-complete interrupts (or timers)
   and does even less than the NAPI thread, as it does not
   even have to (though it can) run the device_xmit code.

   The only case in which the arbiter runs "continuously"
   (with many options to throttle it) is when the load is so
   high that even the NAPI thread would have to run
   continuously.

A) additional remarks on queues:

the model of operation of PSPAT is that
each flow (however you define it) has its own queue,
and the scheduler handles the collection of queues with some
discipline (round robin, fair queueing, priorities...).
When the arbiter marks a packet as "good to send", the underlying
path to the NIC is virtually free for you to use, so you can expect
zero extra delay (other than your own processing).
Individual queue management policies (codel, RED, ECN,
whatever looks at the individual queue) can be done locally.

If you want a single global queue where everybody can write to without
individual limitations (e.g. a bounded size FIFO with K slots), keep in
mind that this model gives no service guarantees other than

   "if you manage to get in, you'll never wait more than K packets"

But, you may never get in so your delay may be infinite
(as it is the case for me now on the beach with flakey cell coverage).

The obvious way to implement this FIFO service is no scheduler,
one TX ring with K slots and let clients contend on it.

If you expect to use M tx rings and still want the 'K packets delay'
guarantee, then PSPAT may still help because you can create a queue
with one or a few slots per client, and when the arbiter
runs (which is more frequently than K packets' time) it may tell you
"you were lucky" or "sorry no room for your packets, drop them".


Finally:

The paper has a ton more details, but it targets an academic audience
which is generally not very interested in implementation issues.
This is why (besides lack of space and some ignorance on my side)
I tried to avoid suggesting how PSPAT could be implemented in
Linux or FreeBSD or userspace software routers or other architectures.

I am happy to hear comments, criticism and suggestions and discuss
details with you or other interested, however I would still suggest
to have first a look at the paper (perhaps skipping the boring section
with formal proofs of the service guarantees) because the description
that we can give on this mailing list is necessarily incomplete
due to space limitations.

Hope to see many of you next week in Amsterdam.

cheers
luigi
