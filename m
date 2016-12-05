From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] udp: some improvements on RX path.
Date: Mon, 05 Dec 2016 06:28:53 -0800
Message-ID: <1480948133.18162.527.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480905784.18162.509.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480944138.4694.37.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35012 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751654AbcLEOq4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 09:46:56 -0500
Received: by mail-pg0-f65.google.com with SMTP id p66so16655755pga.2
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2016 06:46:56 -0800 (PST)
In-Reply-To: <1480944138.4694.37.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-12-05 at 14:22 +0100, Paolo Abeni wrote:
> Hi Eric,
> 
> On Sun, 2016-12-04 at 18:43 -0800, Eric Dumazet wrote:
> > We currently access 3 cache lines from an skb in receive queue while
> > holding receive queue lock :
> > 
> > First cache line (contains ->next / prev pointers )
> > 2nd cache line (skb->peeked)
> > 3rd cache line (skb->truesize)
> > 
> > I believe we could get rid of skb->peeked completely.
> > 
> > I will cook a patch, but basically the idea is that the last owner of a
> > skb (right before skb->users becomes 0) can have the 'ownership' and
> > thus increase stats.
> 
> Agreed.
> 
> > The 3rd cache line miss is easily avoided by the following patch.
> 
> I run some performance tests on top of your patch "net: reorganize
> struct sock for better data locality", and I see an additional ~7%
> improvement on top of that, in the udp flood scenario. 
> 
> In my tests, the topmost perf offenders for the u/s process are now:
> 
>    9.98%  udp_sink  [kernel.kallsyms]  [k] udp_rmem_release
>    8.76%  udp_sink  [kernel.kallsyms]  [k] inet_recvmsg
>    6.71%  udp_sink  [kernel.kallsyms]  [k] _raw_spin_lock_irqsave
>    5.40%  udp_sink  [kernel.kallsyms]  [k] __skb_try_recv_datagram
>    5.19%  udp_sink  [kernel.kallsyms]  [k] copy_user_enhanced_fast_string
> 
> udp_rmem_release() spends most of its time doing:
> 
>     atomic_sub(size, &sk->sk_rmem_alloc);
> 
> I see a cacheline miss while accessing sk_rmem_alloc; most probably due
> to sk_rmem_alloc being updated by the writer outside the rx queue lock.
> 
> Moving such update inside the lock show remove this cache miss but will
> increase the pressure on the rx lock. What do you think ?

I want to accumulate the sk_rmem_alloc  deficit in another variable in
the same cache line than the secondary list, updated from process
context at udp recvmsg() time.

And only transfer the accumulated deficit in one go when the second
queue is emptied, or if the accumulated deficite is > (rcvbuf/2)

If done right, we should interfere between the softirq flooder(s) and
the process thread only once per batch.

> 
> inet_recvmsg() is there because with "net: reorganize struct sock for
> better data locality" we get a cache miss while accessing skc_rxhash in
> sock_rps_record_flow(); touching sk_drops is dirtying that cacheline -
> sorry for not noticing this before. Do you have CONFIG_RPS disabled ?
> 
> > But I also want to work on the idea I gave few days back, having a
> > separate queue and use splice to transfer the 'softirq queue' into
> > a calm queue in a different cache line.
> > 
> > I expect a 50 % performance increase under load, maybe 1.5 Mpps.
> 
> It should work nicely under contention, but won't that increase the
> overhead for the uncontended/single flow scenario ? the user space
> reader needs to acquire 2 lock when splicing the 'softirq queue'. On my
> system ksoftirqd and the u/s process work at similar speeds, so splicing
> will happen quite often. 

Well, the splice would happen only if you have more than one message in
the softirq queue. So no real overhead for uncontended flow scenario.


This reminds me of the busylock I added in __dev_xmit_skb(), which
basically is acquired only when we detect a possible contention on qdisc
lock.

Thanks.
