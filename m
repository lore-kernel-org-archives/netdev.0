From: Simon Kirby <sim@hostway.ca>
Subject: Re: net_ns cleanup / RCU overhead
Date: Thu, 28 Aug 2014 17:40:29 -0700
Message-ID: <20140829004029.GA18300@hostway.ca>
References: <20140820055855.GB5579@hostway.ca>
 <20140828192431.GF5001@linux.vnet.ibm.com>
 <20140828194422.GB8867@hostway.ca>
 <87oav4l5g9.fsf@x220.int.ebiederm.org>
 <20140828204658.GL5001@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140828204658.GL5001@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 28, 2014 at 01:46:58PM -0700, Paul E. McKenney wrote:

> On Thu, Aug 28, 2014 at 03:33:42PM -0500, Eric W. Biederman wrote:
> 
> > I just want to add a little bit more analysis to this.
> > 
> > What we desire to be fast is the copy_net_ns, cleanup_net is batched and
> > asynchronous which nothing really cares how long it takes except that
> > cleanup_net holds the net_mutex and thus blocks copy_net_ns.
> > 
> > The puzzle is why and which rcu delays Simon is seeing in the network
> > namespace cleanup path, as it seems like the synchronize_rcu is not
> > the only one, and in the case of vsftp with trivail network namespaces
> > where nothing has been done we should not need to delay.
> 
> Indeed, given the version and .config, I can't see why any individual
> RCU grace-period operation would be particularly slow.
> 
> I suggest using ftrace on synchronize_rcu() and friends.

I made a parallel net namespace create/destroy benchmark that prints the
progress and time to create and cleanup 32 unshare()d child processes:

http://0x.ca/sim/ref/tools/netnsbench.c

I noticed that if I haven't run it for a while, the first batch often is
fast, followed by slowness from then on:

++++++++++++++++++++++++++++++++-------------------------------- 0.039478s
++++++++++++++++++++-----+----------------+++++++++---------++-- 4.463837s
+++++++++++++++++++++++++------+--------------------++++++------ 3.011882s
+++++++++++++++---+-------------++++++++++++++++---------------- 2.283993s

Fiddling around on a stock kernel, "echo 1 > /sys/kernel/rcu_expedited"
makes behaviour change as it did with my patch:

++-++-+++-+-----+-+-++-+-++--++-+--+-+-++--++-+-+-+-++-+--++---- 0.801406s
+-+-+-++-+-+-+-+-++--+-+-++-+--++-+-+-+-+-+-+-+-+-+-+-+--++-+--- 0.872011s
++--+-++--+-++--+-++--+-+-+-+-++-+--++--+-++-+-+-+-+--++-+-+-+-- 0.946745s

How would I use ftrace on synchronize_rcu() here?

As Eric said, cleanup_net() is batched, but while it is cleaning up,
net_mutex is held. Isn't the issue just that net_mutex is held while
some other things are going on that are meant to be lazy / batched?

What is net_mutex protecting in cleanup_net()?

I noticed that [kworker/u16:0]'s stack is often:

[<ffffffff810942a6>] wait_rcu_gp+0x46/0x50
[<ffffffff8109607e>] synchronize_sched+0x2e/0x50
[<ffffffffa00385ac>] nf_nat_net_exit+0x2c/0x50 [nf_nat]
[<ffffffff81720339>] ops_exit_list.isra.4+0x39/0x60
[<ffffffff817209e0>] cleanup_net+0xf0/0x1a0
[<ffffffff81062997>] process_one_work+0x157/0x440
[<ffffffff81063303>] worker_thread+0x63/0x520
[<ffffffff81068b96>] kthread+0xd6/0xf0
[<ffffffff818d412c>] ret_from_fork+0x7c/0xb0
[<ffffffffffffffff>] 0xffffffffffffffff

and

[<ffffffff81095364>] _rcu_barrier+0x154/0x1f0
[<ffffffff81095450>] rcu_barrier+0x10/0x20
[<ffffffff81102c2c>] kmem_cache_destroy+0x6c/0xb0
[<ffffffffa0089e97>] nf_conntrack_cleanup_net_list+0x167/0x1c0 [nf_conntrack]
[<ffffffffa008aab5>] nf_conntrack_pernet_exit+0x65/0x70 [nf_conntrack]
[<ffffffff81720353>] ops_exit_list.isra.4+0x53/0x60
[<ffffffff817209e0>] cleanup_net+0xf0/0x1a0
[<ffffffff81062997>] process_one_work+0x157/0x440
[<ffffffff81063303>] worker_thread+0x63/0x520
[<ffffffff81068b96>] kthread+0xd6/0xf0
[<ffffffff818d412c>] ret_from_fork+0x7c/0xb0
[<ffffffffffffffff>] 0xffffffffffffffff

So I tried flushing iptables rules and rmmoding netfilter bits:

++++++++++++++++++++-+--------------------+++++++++++----------- 0.179940s
++++++++++++++--+-------------+++++++++++++++++----------------- 0.151988s
++++++++++++++++++++++++++++---+--------------------------+++--- 0.159967s
++++++++++++++++++++++----------------------++++++++++---------- 0.175964s

Expedited:

++-+--++-+-+-+-+-+-+--++-+-+-++-+-+-+--++-+-+-+-+-+-+-+-+-+-+--- 0.079988s
++-+-+-+-+-+-+-+-+-+-+-+--++-+--++-+--+-++-+-+--++-+-+-+-+-+-+-- 0.089347s
++++--+++--++--+-+++++++-+++++--------------++-+-+--++-+-+--++-- 0.081566s
+++++-+++-------++-+-+-+-+-+-+-+-+-+-+-++-+-+-+-+-+-+-+-+-+-+--- 0.089026s

So, much faster. It seems that just loading nf_conntrack_ipv4 (like by
running iptables -t nat -nvL) is enough to slow it way down. But it is
still capable of being fast, as above.

Simon-
