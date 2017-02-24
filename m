From: Florian Westphal <fw@strlen.de>
Subject: Re: net: possible deadlock in skb_queue_tail
Date: Fri, 24 Feb 2017 03:56:50 +0100
Message-ID: <20170224025650.GA16439@breakpoint.cc>
References: <CAAeHK+yCwsZE9iv+OLHJaU+7FEka8UHy_t5vMqFUBpQ8srBbsQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, pabeni@redhat.com,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAAeHK+yCwsZE9iv+OLHJaU+7FEka8UHy_t5vMqFUBpQ8srBbsQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrey Konovalov <andreyknvl@google.com> wrote:

[ CC Paolo ]

> I've got the following error report while fuzzing the kernel with syzkaller.
> 
> On commit c470abd4fde40ea6a0846a2beab642a578c0b8cd (4.10).
> 
> Unfortunately I can't reproduce it.

This needs NETLINK_BROADCAST_ERROR enabled on a netlink socket
that then subscribes to netfilter conntrack (ctnetlink) events.
probably syzkaller did this by accident -- impressive.

(one task is the ctnetlink event redelivery worker
 which won't be scheduled otherwise).

> ======================================================
> [ INFO: possible circular locking dependency detected ]
> 4.10.0-rc8+ #201 Not tainted
> -------------------------------------------------------
> kworker/0:2/1404 is trying to acquire lock:
>  (&(&list->lock)->rlock#3){+.-...}, at: [<ffffffff8335b23f>]
> skb_queue_tail+0xcf/0x2f0 net/core/skbuff.c:2478
> 
> but task is already holding lock:
>  (&(&pcpu->lock)->rlock){+.-...}, at: [<ffffffff8366b55f>] spin_lock
> include/linux/spinlock.h:302 [inline]
>  (&(&pcpu->lock)->rlock){+.-...}, at: [<ffffffff8366b55f>]
> ecache_work_evict_list+0xaf/0x590
> net/netfilter/nf_conntrack_ecache.c:48
> 
> which lock already depends on the new lock.

Cong is correct, this is a false positive.

However we should fix this splat.

Paolo, this happens since 7c13f97ffde63cc792c49ec1513f3974f2f05229
('udp: do fwd memory scheduling on dequeue'), before this
commit kfree_skb() was invoked outside of the locked section in
first_packet_length().

cpu 0 call chain:
- first_packet_length (hold udp sk_receive_queue lock)
   - kfree_skb
      - nf_conntrack_destroy
         - spin_lock(net->ct.pcpu->lock)

cpu 1 call chain:
- ecache_work_evict_list
  - spin_lock( net->ct.pcpu->lock)
  - nf_conntrack_event
     - aquire netlink socket sk_receive_queue

So this could only ever deadlock if a netlink socket
calls kfree_skb while holding its sk_receive_queue lock, but afaics
this is never the case.

There are two ways to avoid this splat (other than lockdep annotation):

1. re-add the list to first_packet_length() and free the
skbs outside of locked section.

2. change ecache_work_evict_list to not call nf_conntrack_event()
while holding the pcpu lock.

doing #2 might be a good idea anyway to avoid potential deadlock
when kfree_skb gets invoked while other cpu holds its sk_receive_queue
lock, I'll have a look if this is feasible.
