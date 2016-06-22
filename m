From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/4] net_sched: bulk dequeue and deferred drops
Date: Wed, 22 Jun 2016 09:49:48 -0700
Message-ID: <1466614188.6850.57.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1466576212-15012-1-git-send-email-edumazet@google.com>
	 <20160622164736.0ab98e6b@redhat.com>
	 <1466607343.6850.37.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160622174441.559023b9@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	John Fastabend <john.r.fastabend@intel.com>,
	Luigi Rizzo <rizzo@iet.unipi.it>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:36531 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751768AbcFVQtv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 12:49:51 -0400
Received: by mail-pf0-f180.google.com with SMTP id t190so19317485pfb.3
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 09:49:50 -0700 (PDT)
In-Reply-To: <20160622174441.559023b9@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-06-22 at 17:44 +0200, Jesper Dangaard Brouer wrote:
> On Wed, 22 Jun 2016 07:55:43 -0700
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > On Wed, 2016-06-22 at 16:47 +0200, Jesper Dangaard Brouer wrote:
> > > On Tue, 21 Jun 2016 23:16:48 -0700
> > > Eric Dumazet <edumazet@google.com> wrote:
> > >   
> > > > First patch adds an additional parameter to ->enqueue() qdisc method
> > > > so that drops can be done outside of critical section
> > > > (after locks are released).
> > > > 
> > > > Then fq_codel can have a small optimization to reduce number of cache
> > > > lines misses during a drop event
> > > > (possibly accumulating hundreds of packets to be freed).
> > > > 
> > > > A small htb change exports the backlog in class dumps.
> > > > 
> > > > Final patch adds bulk dequeue to qdiscs that were lacking this feature.
> > > > 
> > > > This series brings a nice qdisc performance increase (more than 80 %
> > > > in some cases).  
> > > 
> > > Thanks for working on this Eric! this is great work! :-)  
> > 
> > Thanks Jesper
> > 
> > I worked yesterday on bulk enqueues, but initial results are not that
> > great.
> 
> Hi Eric,
> 
> This is interesting work! But I think you should read Luigi Rizzo's
> (Cc'ed) paper on title "A Fast and Practical Software Packet Scheduling
> Architecture"[1]
> 
> [1] http://info.iet.unipi.it/~luigi/papers/20160511-mysched-preprint.pdf
> 
> Luigi will be at Netfilter Workshop next week, and will actually
> present on topic/paper.... you two should talk ;-)
> 
> The article is not a 100% match for what we need, but there is some
> good ideas.  The article also have a sort of "prequeue" that
> enqueue'ing CPUs will place packets into.
> 
> My understanding of the article:
> 
> 1. transmitters submit packets to an intermediate queue
>    (replace q->enqueue call) lockless submit as queue per CPU
>    (runs in parallel)
> 
> 2. like we only have _one_ qdisc dequeue process, this process (called
>    arbiter) empty the intermediate queues, and then invoke q->enqueue()
>    and q->dequeue(). (in a locked session/region)
> 
> 3. Packets returned from q->dequeue() is placed on an outgoing
>    intermediate queue.
> 
> 4. the transmitter then looks to see there are any packets to drain()
>    from the outgoing queue.  This can run in parallel.
> 
> If the transmitter submitting a packet, detect no arbiter is running,
> it can become the arbiter itself.  Like we do with qdisc_run_begin()
> setting state __QDISC___STATE_RUNNING.
> 
> The problem with this scheme is push-back from qdisc->enqueue
> (NET_XMIT_CN) does not "reach" us.  And push-back in-form of processes
> blocking on qdisc root lock, but that could be handled by either
> blocking in article's submit() or returning some congestion return code
> from submit(). 

Okay, I see that you prepare upcoming conference in Amsterdam,
but please keep this thread about existing kernel code, not the one that
eventually reach a new operating system in 5 years ;)

1) We _want_ the result of the sends, obviously.

2) We also want back pressure, without adding complex callbacks and
ref-counting.

3) We do not want to burn a cpu per TX queue (at least one per NUMA
node ???) only to send few packets per second,
Our model is still interrupt based, plus NAPI for interrupt mitigation.

4) I do not want to lock an innocent cpu to send packets from other
threads/cpu without a tight control.

In the patch I sent, I basically replaced a locked operation
(spin_lock(&q->busylock)) with another one (xchg()) , but I did not add
yet another queue before the qdisc ones, bufferbloat forbids.

The virtual queue here is one packet per cpu, which basically is the
same than before this patch, since each cpu spinning on busylock has one
skb to send anyway.

This is basically a simple extension of MCS locks, where the cpu at the
head of the queue can queue up to 16 packets, instead of queueing its
own packet only and give queue owner ship to the following cpu.
