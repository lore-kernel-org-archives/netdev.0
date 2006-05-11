From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Initial benchmarks of some VJ ideas [mmap memcpy vs copy_to_user].
Date: Thu, 11 May 2006 20:18:15 +0400
Message-ID: <20060511161815.GA623@2ka.mipt.ru>
References: <20060508122418.GA22554@2ka.mipt.ru> <20060510.125848.44052388.davem@davemloft.net> <20060511064037.GB22770@2ka.mipt.ru> <20060511.000721.60889163.davem@davemloft.net> <20060511083031.GA12712@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, caitlinb@broadcom.com, kelly@au1.ibm.com,
	rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:50668 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1030295AbWEKQS1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 May 2006 12:18:27 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060511083031.GA12712@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 11, 2006 at 12:30:32PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> On Thu, May 11, 2006 at 12:07:21AM -0700, David S. Miller (davem@davemloft.net) wrote:
> > You can test with single stream, but then you are only testing
> > in-cache case.  Try several thousand sockets and real load from many
> > unique source systems, it becomes interesting then.
>
> I can test system with large number of streams, but unfortunately only
> from small number of different src/dst ip addresses, so I can not
> benchmark route lookup performance in layered design.

I've run it with 200 UDP sockets in receive path. There were two load
generator machines with 100 clients in each.
There are no copies of skb->data in recvmsg().
Since I only have 1Gb link I'm unable to provide each client with high
bandwith, so they send 4k chunks.
Performance dropped twice down to 55 MB/sec and CPU usage increased noticebly
(slow drift from 12 to 8% compared to 2% with one socket),
but it is not because of cache effect I believe,
but due to highly increased number of syscalls per second.

Here is profile result:
1463625  78.0003  poll_idle
19171     1.0217  _spin_lock_irqsave
15887     0.8467  _read_lock
14712     0.7840  kfree
13370     0.7125  ip_frag_queue
11896     0.6340  delay_pmtmr
11811     0.6294  _spin_lock
11723     0.6247  csum_partial
11399     0.6075  ip_frag_destroy
11063     0.5896  serial_in
10533     0.5613  skb_release_data
10524     0.5609  ip_route_input
10319     0.5499  __alloc_skb
9903      0.5278  ip_defrag
9889      0.5270  _read_unlock
9536      0.5082  _write_unlock
8639      0.4604  _write_lock
7557      0.4027  netif_receive_skb
6748      0.3596  ip_frag_intern
6534      0.3482  preempt_schedule
6220      0.3315  __kmalloc
6005      0.3200  schedule
5924      0.3157  irq_entries_start
5823      0.3103  _spin_unlock_irqrestore
5678      0.3026  ip_rcv
5410      0.2883  __kfree_skb
5056      0.2694  kmem_cache_alloc
5014      0.2672  kfree_skb
4900      0.2611  eth_type_trans
4067      0.2167  kmem_cache_free
3532      0.1882  udp_recvmsg
3531      0.1882  ip_frag_reasm
3331      0.1775  _read_lock_irqsave
3327      0.1773  ipq_kill
3304      0.1761  udp_v4_lookup_longway

I'm going to resurrect zero-copy sniffer project [1] and create special
socket option which would allow to insert pages, which contain
skb->data, into process VMA using VM remapping tricks. Unfortunately it
requires TLB flushing and probably there will be no significant
performance/CPU gain if any, but I think, it is the only way to provide receiving 
zero-copy access to hardware which does not support header split.

Other idea, which I will try, if I understood you correctly, is to create unified cache.
I think some interesting results can be obtained from following
approach: in softint we do not process skb->data at all, but only get
src/dst/sport/dport/protocol numbers (it could require maximum two cache lines,
or it is not fast-path packet (but something like ipsec) and can be processed as usual) 
and create some "initial" cache based on that data, skb is then queued into that
"initial" cache entry and recvmsg() in process context later process' 
that entry.

Back to the drawing board...
Thanks for discussion.

1. zero-copy sniffer
http://tservice.net.ru/~s0mbre/old/?section=projects&item=af_tlb

-- 
	Evgeniy Polyakov
