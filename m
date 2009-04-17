From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] netfilter: use per-cpu spinlock rather than RCU (v3)
Date: Fri, 17 Apr 2009 08:00:47 -0700
Message-ID: <20090417150047.GB6742@linux.vnet.ibm.com>
References: <20090416215033.3e648a7a@nehalam> <49E810B0.9000906@cosmosbay.com> <20090417054032.GD6885@linux.vnet.ibm.com> <20090417.010710.59150850.davem@davemloft.net>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dada1@cosmosbay.com, shemminger@vyatta.com, kaber@trash.net,
	torvalds@linux-foundation.org, jeff.chua.linux@gmail.com,
	paulus@samba.org, mingo@elte.hu, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org, mathieu.desnoyers@polymtl.ca
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090417.010710.59150850.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 17, 2009 at 01:07:10AM -0700, David Miller wrote:
> From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
> Date: Thu, 16 Apr 2009 22:40:32 -0700
> 
> > I completely agree that this RCU is absolutely -not- 2.6.30 material.  ;-)
> 
> I don't understand why we're writing such complicated code.
> 
> Oh I see why, it's because not every arch uses the generic SMP helpers
> yet :-)

;-)

> Because if they did universally, we could solve this problem so
> simply, by merely sending a remote softirq to every online cpu.  Once
> those all complete we have enough of a quiesce period, every cpu must
> have exited any netfilter packet processing code path they were in.
> 
> And we could know they complete using an atomic counter or something.

I was with you until you got to the atomic counter, which would require
dealing with CPU hotplug.

But your point is a very good one.  We already do have a flavor of
RCU that waits for softirq code, namely rcu-bh.  And it is used
exclusively by the networking code:

     14 net/ipv4/
     13 net/decnet/
     10 net/core/
      6 net/ipv6/
      4 kernel/		[rcutorture, so these four uses don't count.]
      3 net/netfilter/
      2 net/mac80211/
      2 net/packet/

So both yours and Peter's implicit point is quite correct -- the kernel
really does not need yet another flavor of RCU.  So maybe I should instead
be thinking in terms of making the existing rcu-bh be better adapted to
the networking code, like maybe a fast synchronize_rcu_bh().

Or do the networking uses of rcu-bh need it to work exactly the way that
it does now?

							Thanx, Paul

kernel/rcutorture.c __acquires 392 rcu_read_lock_bh();
kernel/rcutorture.c __releases 398 rcu_read_unlock_bh();
kernel/rcutorture.c rcu_bh_torture_deferred_free 408 call_rcu_bh(&p->rtort_rcu, rcu_torture_cb);
kernel/rcutorture.c rcu_bh_torture_synchronize 429 call_rcu_bh(&rcu.head, rcu_bh_torture_wakeme_after_cb);
net/core/dev.c dev_queue_xmit 1844 rcu_read_lock_bh();
net/core/dev.c dev_queue_xmit 1909 rcu_read_unlock_bh();
net/core/dev.c dev_queue_xmit 1915 rcu_read_unlock_bh();
net/core/filter.c sk_filter 88 rcu_read_lock_bh();
net/core/filter.c sk_filter 95 rcu_read_unlock_bh();
net/core/filter.c sk_filter_delayed_uncharge 477 call_rcu_bh(&fp->rcu, sk_filter_rcu_release);
net/core/filter.c sk_attach_filter 517 rcu_read_lock_bh();
net/core/filter.c sk_attach_filter 520 rcu_read_unlock_bh();
net/core/filter.c sk_detach_filter 532 rcu_read_lock_bh();
net/core/filter.c sk_detach_filter 539 rcu_read_unlock_bh();
net/decnet/dn_route.c dnrt_free 148 call_rcu_bh(&rt->u.dst.rcu_head, dst_rcu_free);
net/decnet/dn_route.c dnrt_drop 154 call_rcu_bh(&rt->u.dst.rcu_head, dst_rcu_free);
net/decnet/dn_route.c __dn_route_output_key 1161 rcu_read_lock_bh();
net/decnet/dn_route.c __dn_route_output_key 1170 rcu_read_unlock_bh();
net/decnet/dn_route.c __dn_route_output_key 1175 rcu_read_unlock_bh();
net/decnet/dn_route.c dn_cache_dump 1623 rcu_read_lock_bh();
net/decnet/dn_route.c dn_cache_dump 1634 rcu_read_unlock_bh();
net/decnet/dn_route.c dn_cache_dump 1639 rcu_read_unlock_bh();
net/decnet/dn_route.c dn_rt_cache_get_first 1659 rcu_read_lock_bh();
net/decnet/dn_route.c dn_rt_cache_get_first 1663 rcu_read_unlock_bh();
net/decnet/dn_route.c dn_rt_cache_get_next 1674 rcu_read_unlock_bh();
net/decnet/dn_route.c dn_rt_cache_get_next 1677 rcu_read_lock_bh();
net/decnet/dn_route.c dn_rt_cache_seq_stop 1704 rcu_read_unlock_bh();
net/ipv4/fib_trie.c free_leaf 339 call_rcu_bh(&l->rcu, __leaf_free_rcu);
net/ipv4/route.c rt_cache_get_first 289 rcu_read_lock_bh();
net/ipv4/route.c rt_cache_get_first 297 rcu_read_unlock_bh();
net/ipv4/route.c __rt_cache_get_next 309 rcu_read_unlock_bh();
net/ipv4/route.c __rt_cache_get_next 314 rcu_read_lock_bh();
net/ipv4/route.c rt_cache_seq_stop 367 rcu_read_unlock_bh();
net/ipv4/route.c rt_free 613 call_rcu_bh(&rt->u.dst.rcu_head, dst_rcu_free);
net/ipv4/route.c rt_drop 619 call_rcu_bh(&rt->u.dst.rcu_head, dst_rcu_free);
net/ipv4/route.c __ip_route_output_key 2665 rcu_read_lock_bh();
net/ipv4/route.c __ip_route_output_key 2679 rcu_read_unlock_bh();
net/ipv4/route.c __ip_route_output_key 2685 rcu_read_unlock_bh();
net/ipv4/route.c ip_rt_dump 2983 rcu_read_lock_bh();
net/ipv4/route.c ip_rt_dump 2995 rcu_read_unlock_bh();
net/ipv4/route.c ip_rt_dump 3000 rcu_read_unlock_bh();
net/ipv6/addrconf.c ipv6_add_addr 603 rcu_read_lock_bh();
net/ipv6/addrconf.c ipv6_add_addr 682 rcu_read_unlock_bh();
net/ipv6/addrconf.c ipv6_regen_rndid 1641 rcu_read_lock_bh();
net/ipv6/addrconf.c ipv6_regen_rndid 1665 rcu_read_unlock_bh();
net/ipv6/addrconf.c ipv6_ifa_notify 3967 rcu_read_lock_bh();
net/ipv6/addrconf.c ipv6_ifa_notify 3970 rcu_read_unlock_bh();
net/mac80211/wme.c ieee80211_requeue 256 rcu_read_lock_bh();
net/mac80211/wme.c ieee80211_requeue 294 rcu_read_unlock_bh();
net/netfilter/nf_conntrack_core.c nf_conntrack_tuple_taken 408 rcu_read_lock_bh();
net/netfilter/nf_conntrack_core.c nf_conntrack_tuple_taken 413 rcu_read_unlock_bh();
net/netfilter/nf_conntrack_core.c nf_conntrack_tuple_taken 418 rcu_read_unlock_bh();
net/packet/af_packet.c run_filter 459 rcu_read_lock_bh();
net/packet/af_packet.c run_filter 463 rcu_read_unlock_bh();
