From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] tcp: Fast/early SYN handling to mitigate SYN floods
Date: Thu, 24 May 2012 16:51:17 +0200
Message-ID: <1337871077.3140.12.camel@edumazet-glaptop>
References: <1337864467.13491.15.camel@localhost>
	 <4FBE3709.6070806@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Martin Topholm <mph@hoth.dk>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: christoph.paasch@uclouvain.be,
	Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:39126 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755926Ab2EXOvW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2012 10:51:22 -0400
Received: by eeit10 with SMTP id t10so2461453eei.19
        for <netdev@vger.kernel.org>; Thu, 24 May 2012 07:51:21 -0700 (PDT)
In-Reply-To: <4FBE3709.6070806@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-05-24 at 15:26 +0200, Christoph Paasch wrote:
> Hello,
> 
> On 05/24/2012 03:01 PM, Jesper Dangaard Brouer wrote:
> > I have been doing some TCP performance measurements with SYN flooding,
> > and have found that, we don't handle this case well.
> > 
> > I have made a patch for fast/early SYN handling in tcp_v4_rcv() in
> > net/ipv4/tcp_ipv4.c.  This increases SYN performance from 130 kpps to
> > 750 kpps (max of the generator), with idle CPU cycles.
> > 
> > Current locking:
> >  During a SYN flood (against a single port) all CPUs are spinning on
> > the same spinlock, namely bh_lock_sock_nested(sk), in tcp_ipv4.c.  The
> > lock dates back to a commit by DaveM in May 1999, see historic
> > commit[1].  It seem that TCP runs fully locked, per sock.
> > 
> > I need some help with locking, as the patch seems to work fine, with
> > NO-PREEMPT, but with PREEMPT enabled I start to see warnings (in
> > reqsk_queue_destroy) and oopses (in inet_csk_reqsk_queue_prune).
> > 
> > What am I missing?
> 
> For each retransmission of a SYN you will add a request-sock to the
> syn_table, because you do not pass by tcp_v4_hnd_req(), which checks
> this by calling inet_csk_search_req().
> 
> And your warning in reqsk_queue_destroy is because the access to the the
> request_sock_queue is no more protected by a lock.
> 
> 
> The request_sock_queue is a shared resource, which must be protect by a
> lock. As you allow "parallel" SYN-processing, the queue will get corrupted.
> 

Hi guys, that's a very interesting subject.

I began work on fully converting this stuff to RCU some weeks ago but
got distracted by codel / fq_codel and other cool stuff (TCP coalescing
and skb->frag_head)

I dont know if you remember the SO_REUSEPORT patch(s) posted by Tom
Herbert in the past. The remaining issue was about adding/removing a new
listener to a pool of listeners to same port, and hash function was
changed so we could lost some connexions in SYN_RECV state at this
stage.

So I was working having a shared table, and not anymore using a central
spinlock, but an array of spinlock, as done elsewhere
(ESTABLISHED/TIMEWAIT hash tables)

My work is probably a ~500 LOC target, allowing concurrent processing by
all cpus of the host.

Jesper, my goals are probably different than yours, unless I
misunderstood your intention.

I feel you want to have an emergency mode, when listener is overflowed
to immediately send a SYNCOOKIE ?
