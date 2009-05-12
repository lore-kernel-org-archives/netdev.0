From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v2] Receive Packet Steering
Date: Tue, 12 May 2009 10:28:33 -0700
Message-ID: <65634d660905121028s18034ee3w6da360a450d3b117@mail.gmail.com>
References: <65634d660905032103h614225dbg9911e290f5537fbf@mail.gmail.com>
	 <49FE7D63.6050102@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.13]:62405 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753277AbZELR2f convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2009 13:28:35 -0400
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id n4CHSZuK008823
	for <netdev@vger.kernel.org>; Tue, 12 May 2009 10:28:35 -0700
Received: from rv-out-0708.google.com (rvfc5.prod.google.com [10.140.180.5])
	by wpaz37.hot.corp.google.com with ESMTP id n4CHSQkx029749
	for <netdev@vger.kernel.org>; Tue, 12 May 2009 10:28:33 -0700
Received: by rv-out-0708.google.com with SMTP id c5so71641rvf.22
        for <netdev@vger.kernel.org>; Tue, 12 May 2009 10:28:33 -0700 (PDT)
In-Reply-To: <49FE7D63.6050102@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 3, 2009 at 10:30 PM, Eric Dumazet <dada1@cosmosbay.com> wro=
te:
>
> Tom Herbert a =E9crit :
> > This is an update of the receive packet steering patch (RPS) based =
on received
> > comments (thanks for all the comments).  Improvements are:
> >
> > 1) Removed config option for the feature.
> > 2) Made scheduling of backlog NAPI devices between CPUs lockless an=
d much
> > simpler.
> > 3) Added new softirq to do defer sending IPIs for coalescing.
> > 4) Imported hash from simple_rx_hash.  Eliminates modulo operation =
to convert
> > hash to index.
> > 5) If no cpu is found for packet steering, then netif_receive_skb p=
rocesses
> > packet inline as before without queueing.  In paritcular if RPS is =
not
> > configured on a device the receive path is unchanged from current f=
or
> > NAPI devices (one additional conditional).
> >
> > Tom
>
> Seems cool, but I found two errors this morning before my cofee ;)
>
> Is it a working patch or an RFC ?
>
Patch mostly works.  It's based on code from an earlier kernel that
we've been running for more than year.

> Its also not clear from ChangeLog how this is working, and even
> after reading your patch, its not yet very clear. Please provide
> more documentation, on every submission.
>
Okay.

> What about latencies ? I really do think that if cpu handling
> device is lightly loaded, it should handle packet itself, without
> giving it to another cpu, incurring many cache lines bounces.
>

While it's true that this scheme adds overhead for processing a single
packet at a time, we've found that by setting the per device CPU mask
to CPUs sharing the same L2/L3 cache we can reduce that overhead
substantially to the point that even for a small number of active
connections (around ten in out setup) the benefits of parallelizing
the path overcome the extra overhead resulting in lower average
latency.  So this would increase latency for doing a single ping, but
even for a moderate loaded server we see latency improvements.

> > +static int enqueue_to_backlog(struct sk_buff *skb, int cpu)
> > +{
> > +     struct softnet_data *queue;
> > +     unsigned long flags;
> > +
> > +     queue =3D &per_cpu(softnet_data, cpu);
> > +     spin_lock_irqsave(&queue->input_pkt_queue.lock, flags);
>
> I wonder... isnt it going to really hurt with cache line ping pongs ?
>

I suppose it is possible, although we haven't see this pop up in
profiling.  Coalescing packets before doing the IPI might be
alleviating that.


> > +             /* Schedule NAPI for backlog device */
> > +             if (napi_schedule_prep(&queue->backlog)) {
> > +                     if (cpu !=3D smp_processor_id()) {
> > +                             cpu_set(cpu,
> > +                                 get_cpu_var(rps_remote_softirq_cp=
us));
>
> get_cpu_var() increases preempt_count (preempt_disable), where is the=
 opposite decrease ?
>

Right, should be __get_cpu_var.

Tom
