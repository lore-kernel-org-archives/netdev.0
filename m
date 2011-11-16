From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [rfc 00/18] slub: irqless/lockless slow allocation paths
Date: Wed, 16 Nov 2011 18:39:58 +0100
Message-ID: <1321465198.4182.35.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20111111200711.156817886@linux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes
 <rientjes@google.com>,  Andi Kleen <andi@firstfloor.org>, tj@kernel.org,
 Metathronius Galabant <m.galabant@googlemail.com>,  Matt Mackall
 <mpm@selenic.com>, Adrian Drzewiecki <z@drze.net>, Shaohua Li
 <shaohua.li@intel.com>, Alex Shi <alex.shi@intel.com>, linux-mm@kvack.org,
 netdev <netdev@vger.kernel.org>
To: Christoph Lameter <cl@linux.com>, David Miller <davem@davemloft.net>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20111111200711.156817886@linux.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Le vendredi 11 novembre 2011 =C3=A0 14:07 -0600, Christoph Lameter a =C3=A9=
crit :
> This is a patchset that makes the allocator slow path also lockless lik=
e
> the free paths. However, in the process it is making processing more
> complex so that this is not a performance improvement. I am going to
> drop this series unless someone comes up with a bright idea to fix the
> following performance issues:
>=20
> 1. Had to reduce the per cpu state kept to two words in order to
>    be able to operate without preempt disable / interrupt disable only
>    through cmpxchg_double(). This means that the node information and
>    the page struct location have to be calculated from the free pointer=
.
>    That is possible but relatively expensive and has to be done frequen=
tly
>    in fast paths.
>=20
> 2. If the freepointer becomes NULL then the page struct location can
>    no longer be determined. So per cpu slabs must be deactivated when
>    the last object is retrieved from them causing more regressions.
>=20
> If these issues remain unresolved then I am fine with the way things ar=
e
> right now in slub. Currently interrupts are disabled in the slow paths =
and
> then multiple fields in the kmem_cache_cpu structure are modified witho=
ut
> regard to instruction atomicity.
>=20

I believe this is a wrong idea.

You try to have a lockless slow path, while I believe you should not,
and instead batch things a bit like SLAB, and be smart about false
sharing.

The lock cost is nothing compared to cache line ping pongs.

Here is a real use case I am facing right now :

In traditional NIC driver model, rx path used a ring buffer of
pre-allocated skbs (256 ... 4096 elems per ring), and feed them to upper
stack when interrupts signal frames are available.

If the skb is delivered to a socket, and consumed/freed by another cpu,
we had no particular problem because skb was part of a page that was
completely used (no free objects in it), because of the RX ring buffer
buffering (frame N is delivered to stack if allocations N+1 ... N+1024
were already done)

This model has a downside, since we initialize skb at allocation time,
then add it in the ring buffer. Later, we handle the frame while sk_buff
content had been taken out of cpu caches, so cpu must reload sk_buff
from memory before sending skb to stack, this adds some latency to
receive path (about 5 cache line misses per packet)

We now want to allocate/populate the sk_buff right before sending it to
upper stack. (see build_skb() infrastructure in net-next tree :

http://git.kernel.org/?p=3Dlinux/kernel/git/davem/net-next.git;a=3Dcommit=
;h=3Db2b5ce9d1ccf1c45f8ac68e5d901112ab76ba199

http://git.kernel.org/?p=3Dlinux/kernel/git/davem/net-next.git;a=3Dcommit=
;h=3De52fcb2462ac484e6dd6e68869536609f0216938

)

But... we now ping-pong in slab_alloc() in the case skb consumer is on a
different cpu (this is typically the case if one cpu is fully used in
softirq handling / stress situation, or if RPS/RFS techniques are used).

So softirq handler and consumers compete on heavy contended cache line
for _every_ allocation and free.

Switching to SLAB solves the problem.

perf profile for SLAB (no packet drops, and 5% of idle stil available),
for CPU0 (the one handling softirqs) : We see normal network functions
in a network workload :)


  9.45%  [kernel]  [k] ipt_do_table
  7.81%  [kernel]  [k] __udp4_lib_lookup.clone.46
  7.11%  [kernel]  [k] build_skb
  5.85%  [tg3]     [k] tg3_poll_work
  4.39%  [kernel]  [k] udp_queue_rcv_skb
  4.37%  [kernel]  [k] sock_def_readable
  4.21%  [kernel]  [k] __sk_mem_schedule
  3.72%  [kernel]  [k] __netif_receive_skb
  3.21%  [kernel]  [k] __udp4_lib_rcv
  2.98%  [kernel]  [k] nf_iterate
  2.85%  [kernel]  [k] _raw_spin_lock
  2.85%  [kernel]  [k] ip_route_input_common
  2.83%  [kernel]  [k] sock_queue_rcv_skb
  2.77%  [kernel]  [k] ip_rcv
  2.76%  [kernel]  [k] __kmalloc
  2.03%  [kernel]  [k] kmem_cache_alloc
  1.93%  [kernel]  [k] _raw_spin_lock_irqsave
  1.76%  [kernel]  [k] eth_type_trans
  1.49%  [kernel]  [k] nf_hook_slow
  1.46%  [kernel]  [k] inet_gro_receive
  1.27%  [tg3]     [k] tg3_alloc_rx_data

With SLUB : We see contention in __slab_alloc, and packet drops.

 13.13%  [kernel]  [k] __slab_alloc.clone.56
  8.81%  [kernel]  [k] ipt_do_table
  7.41%  [kernel]  [k] __udp4_lib_lookup.clone.46
  4.64%  [tg3]     [k] tg3_poll_work
  3.93%  [kernel]  [k] build_skb
  3.65%  [kernel]  [k] udp_queue_rcv_skb
  3.33%  [kernel]  [k] __netif_receive_skb
  3.26%  [kernel]  [k] kmem_cache_alloc
  3.16%  [kernel]  [k] sock_def_readable
  3.15%  [kernel]  [k] nf_iterate
  3.13%  [kernel]  [k] __sk_mem_schedule
  2.81%  [kernel]  [k] __udp4_lib_rcv
  2.58%  [kernel]  [k] setup_object.clone.50
  2.54%  [kernel]  [k] sock_queue_rcv_skb
  2.32%  [kernel]  [k] ip_route_input_common
  2.25%  [kernel]  [k] ip_rcv
  2.14%  [kernel]  [k] _raw_spin_lock
  1.95%  [kernel]  [k] eth_type_trans
  1.55%  [kernel]  [k] inet_gro_receive
  1.50%  [kernel]  [k] ksize
  1.42%  [kernel]  [k] __kmalloc
  1.29%  [kernel]  [k] _raw_spin_lock_irqsave

Notice new_slab() is not there at all.

Adding SLUB_STATS gives :

$ cd /sys/kernel/slab/skbuff_head_cache ; grep . *
aliases:6
align:8
grep: alloc_calls: Function not implemented
alloc_fastpath:89181782 C0=3D89173048 C1=3D1599 C2=3D1357 C3=3D2140 C4=3D=
802 C5=3D675 C6=3D638 C7=3D1523
alloc_from_partial:412658 C0=3D412658
alloc_node_mismatch:0
alloc_refill:593417 C0=3D593189 C1=3D19 C2=3D15 C3=3D24 C4=3D51 C5=3D18 C=
6=3D17 C7=3D84
alloc_slab:2831313 C0=3D2831285 C1=3D2 C2=3D2 C3=3D2 C4=3D2 C5=3D12 C6=3D=
4 C7=3D4
alloc_slowpath:4430371 C0=3D4430112 C1=3D20 C2=3D17 C3=3D25 C4=3D57 C5=3D=
31 C6=3D21 C7=3D88
cache_dma:0
cmpxchg_double_cpu_fail:0
cmpxchg_double_fail:1 C0=3D1
cpu_partial:30
cpu_partial_alloc:592991 C0=3D592981 C2=3D1 C4=3D5 C5=3D2 C6=3D1 C7=3D1
cpu_partial_free:4429836 C0=3D592981 C1=3D25 C2=3D19 C3=3D23 C4=3D3836767=
 C5=3D6 C6=3D8 C7=3D7
cpuslab_flush:0
cpu_slabs:107
deactivate_bypass:3836954 C0=3D3836923 C1=3D1 C2=3D2 C3=3D1 C4=3D6 C5=3D1=
3 C6=3D4 C7=3D4
deactivate_empty:2831168 C4=3D2831168
deactivate_full:0
deactivate_remote_frees:0
deactivate_to_head:0
deactivate_to_tail:0
destroy_by_rcu:0
free_add_partial:0
grep: free_calls: Function not implemented
free_fastpath:21192924 C0=3D21186268 C1=3D1420 C2=3D1204 C3=3D1966 C4=3D5=
72 C5=3D349 C6=3D380 C7=3D765
free_frozen:67988498 C0=3D516 C1=3D121 C2=3D85 C3=3D841 C4=3D67986468 C5=3D=
215 C6=3D76 C7=3D176
free_remove_partial:18 C4=3D18
free_slab:2831186 C4=3D2831186
free_slowpath:71825749 C0=3D609 C1=3D146 C2=3D104 C3=3D864 C4=3D71823538 =
C5=3D221 C6=3D84 C7=3D183
hwcache_align:0
min_partial:5
objects:2494
object_size:192
objects_partial:121
objs_per_slab:21
order:0
order_fallback:0
partial:14
poison:0
reclaim_account:0
red_zone:0
reserved:0
sanity_checks:0
slabs:127
slabs_cpu_partial:99(99) C1=3D25(25) C2=3D18(18) C3=3D23(23) C4=3D16(16) =
C5=3D4(4) C6=3D7(7) C7=3D6(6)
slab_size:192
store_user:0
total_objects:2667
trace:0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
