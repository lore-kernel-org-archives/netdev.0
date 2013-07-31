From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: ipv4: crash at leaf_walk_rcu
Date: Wed, 31 Jul 2013 15:13:23 +0200
Message-ID: <20130731131323.GB31245@order.stressinduktion.org>
References: <CAOaiJ-k14g6ihjVfgHqgq48KV7-dRJ1_owNyDkza-r=36gscsQ@mail.gmail.com> <20130731125513.GS26694@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: vinayak menon <vinayakm.list@gmail.com>,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	getarunks@gmail.com, netdev@vger.kernel.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130731125513.GS26694@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 31, 2013 at 05:55:13AM -0700, Paul E. McKenney wrote:
> On Wed, Jul 31, 2013 at 04:40:47PM +0530, vinayak menon wrote:
> > Hi,
> > 
> > A crash was seen on 3.4.5 kernel during some random wlan operations.
> > 
> > CPU: Single core ARM Cortex A9.
> > 
> > fib_route_seq_next was called with second argument (void *v) as 0xd6e3e360
> > which is a "freed" object of the "ip_fib_trie" cache. I confirmed that the
> > object was freed with crash utility.
> > 
> > Sequence: fib_route_seq_next->trie_nextleaf->leaf_walk_rcu
> > 
> > As "v" was a freed object, inside trie_nextleaf(), node_parent_rcu()
> > returned an invalid tnode. But as I had enabled slab poisoning and the
> > object was already freed, the tnode was 0x6b6b6b6b. And this was passed to
> > leaf_walk_rcu and resulted in the crash.
> > 
> > fib_route_seq_start, takes rcu_read_lock(), but free_leaf
> > calls call_rcu_bh. Can this be the problem ?
> > Should rcu_read_lock() in fib_route_seq_start be changed to rcu_read_lock_bh()
> > ?
> 
> One way or the other, the RCU read-side primitives need to match the RCU
> update-side primitives.  Adding netdev...

Already fixed by:

commit 0c03eca3d995e73d691edea8c787e25929ec156d
Author: Eric Dumazet <edumazet@google.com>
Date:   Tue Aug 7 00:47:11 2012 +0000

    net: fib: fix incorrect call_rcu_bh()
    
    After IP route cache removal, I believe rcu_bh() has very little use and
    we should remove this RCU variant, since it adds some cycles in fast
    path.
    
    Anyway, the call_rcu_bh() use in fib_true is obviously wrong, since
    some users only assert rcu_read_lock().
