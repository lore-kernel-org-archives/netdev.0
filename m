From: Patrick McLean <chutzpah@gentoo.org>
Subject: Re: [Bug 86851] New: Reproducible panic on heavy UDP traffic
Date: Mon, 27 Oct 2014 15:59:38 -0700
Message-ID: <20141027155938.28248b5e@gentoo.org>
References: <20141025141038.26fa5ac2@uryu.home.lan>
	<20141025214448.GB28407@breakpoint.cc>
	<544D8386.9030609@redhat.com>
	<1414370826.16231.1.camel@edumazet-glaptop2.roam.corp.google.com>
	<544E06CF.30709@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Florian Westphal <fw@strlen.de>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:49377 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751664AbaJ0W7l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2014 18:59:41 -0400
In-Reply-To: <544E06CF.30709@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 27 Oct 2014 09:48:15 +0100
Nikolay Aleksandrov <nikolay@redhat.com> wrote:

> On 10/27/2014 01:47 AM, Eric Dumazet wrote:
> > On Mon, 2014-10-27 at 00:28 +0100, Nikolay Aleksandrov wrote:
> > 
> >>
> >> Thanks for CCing me.
> >> I'll dig in the code tomorrow but my first thought when I saw this
> >> was could it be possible that we have a race condition between
> >> ip_frag_queue() and inet_frag_evict(), more precisely between the
> >> ipq_kill() calls from ip_frag_queue and inet_frag_evict since the
> >> frag could be found before we have entered the evictor which then
> >> can add it to its expire list but the ipq_kill() from
> >> ip_frag_queue() can do a list_del after we release the chain lock
> >> in the evictor so we may end up like this ?
> > 
> > Yes, either we use hlist_del_init() but loose poison aid, or test if
> > frag was evicted :
> > 
> > Not sure about refcount.
> > 
> > diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
> > index 9eb89f3f0ee4..894ec30c5896 100644
> > --- a/net/ipv4/inet_fragment.c
> > +++ b/net/ipv4/inet_fragment.c
> > @@ -285,7 +285,8 @@ static inline void fq_unlink(struct
> > inet_frag_queue *fq, struct inet_frags *f) struct inet_frag_bucket
> > *hb; 
> >  	hb = get_frag_bucket_locked(fq, f);
> > -	hlist_del(&fq->list);
> > +	if (!(fq->flags & INET_FRAG_EVICTED))
> > +		hlist_del(&fq->list);
> >  	spin_unlock(&hb->chain_lock);
> >  }
> >  
> > 
> > 
> 
> Exactly, I was thinking about a similar fix since the evict flag is
> only set with the chain lock. IMO the refcount should be fine.
> CCing the reporter.
> Patrick could you please try Eric's patch ?
> 

It no longer panics with that patch, but it does produce a large amount
of warnings, here is an example of what I am getting. I will attach the
full log to the bug.

> [  205.042923] ------------[ cut here ]------------
> [  205.042933] WARNING: CPU: 4 PID: 615 at net/ipv4/inet_fragment.c:149 inet_evict_bucket+0x172/0x180()
> [  205.042934] Modules linked in: nfs fscache nfsd auth_rpcgss nfs_acl lockd grace sunrpc 8021q garp mrp bonding x86_pkg_temp_thermal joydev sb_edac edac_core ioatdma tpm_tis ext4 mbcache jbd2 igb ixgbe i2c_algo_bit raid1 mdio crc32c_intel megaraid_sas dca
> [  205.042953] CPU: 4 PID: 615 Comm: kworker/4:2 Not tainted 3.18.0-rc2-base-7+ #3
> [  205.042955] Hardware name: Intel Corporation S2600GZ/S2600GZ, BIOS SE5C600.86B.02.03.0003.041920141333 04/19/2014
> [  205.042957] Workqueue: events inet_frag_worker
> [  205.042958]  0000000000000000 0000000000000009 ffffffff81624cd2 0000000000000000
> [  205.042960]  ffffffff81117b7d ffff8817c83a4740 0000000000000000 ffffffff81aa6820
> [  205.042962]  ffff8817ce073d70 ffff8817c83a4738 ffffffff81597cb2 ffffffff81aa8e28
> [  205.042964] Call Trace:
> [  205.042969]  [<ffffffff81624cd2>] ? dump_stack+0x41/0x51
> [  205.042973]  [<ffffffff81117b7d>] ? warn_slowpath_common+0x6d/0x90
> [  205.042975]  [<ffffffff81597cb2>] ? inet_evict_bucket+0x172/0x180
> [  205.042976]  [<ffffffff81597d22>] ? inet_frag_worker+0x62/0x210
> [  205.042979]  [<ffffffff8112c312>] ? process_one_work+0x132/0x360
> [  205.042981]  [<ffffffff8112ca23>] ? worker_thread+0x113/0x590
> [  205.042983]  [<ffffffff8112c910>] ? rescuer_thread+0x3d0/0x3d0
> [  205.042986]  [<ffffffff8113123c>] ? kthread+0xbc/0xe0
> [  205.042991]  [<ffffffff81040000>] ? xen_teardown_timer+0x10/0x70
> [  205.042993]  [<ffffffff81131180>] ? kthread_create_on_node+0x170/0x170
> [  205.042996]  [<ffffffff8162a9fc>] ? ret_from_fork+0x7c/0xb0
> [  205.042998]  [<ffffffff81131180>] ? kthread_create_on_node+0x170/0x170
> [  205.043000] ---[ end trace ed2bb7d412e082bc ]---
> [  205.752744] ------------[ cut here ]------------
> [  205.752752] WARNING: CPU: 2 PID: 610 at net/ipv4/inet_fragment.c:149 inet_evict_bucket+0x172/0x180()
> [  205.752754] Modules linked in: nfs fscache nfsd auth_rpcgss nfs_acl lockd grace sunrpc 8021q garp mrp bonding x86_pkg_temp_thermal joydev sb_edac edac_core ioatdma tpm_tis ext4 mbcache jbd2 igb ixgbe i2c_algo_bit raid1 mdio crc32c_intel megaraid_sas dca
> [  205.752773] CPU: 2 PID: 610 Comm: kworker/2:2 Tainted: G        W      3.18.0-rc2-base-7+ #3 
> [  205.752774] Hardware name: Intel Corporation S2600GZ/S2600GZ, BIOS SE5C600.86B.02.03.0003.041920141333 04/19/2014
> [  205.752777] Workqueue: events inet_frag_worker
> [  205.752779]  0000000000000000 0000000000000009 ffffffff81624cd2 0000000000000000
> [  205.752780]  ffffffff81117b7d ffff882fc473c740 0000000000000000 ffffffff81aa6820
> [  205.752782]  ffff8817ce7afd70 ffff882fc473c738 ffffffff81597cb2 ffffffff81aa87a8
> [  205.752784] Call Trace:
> [  205.752790]  [<ffffffff81624cd2>] ? dump_stack+0x41/0x51
> [  205.752793]  [<ffffffff81117b7d>] ? warn_slowpath_common+0x6d/0x90
> [  205.752795]  [<ffffffff81597cb2>] ? inet_evict_bucket+0x172/0x180
> [  205.752797]  [<ffffffff81597d22>] ? inet_frag_worker+0x62/0x210
> [  205.752799]  [<ffffffff8112c312>] ? process_one_work+0x132/0x360
> [  205.752801]  [<ffffffff8112ca23>] ? worker_thread+0x113/0x590
> [  205.752803]  [<ffffffff8112c910>] ? rescuer_thread+0x3d0/0x3d0
> [  205.752806]  [<ffffffff8113123c>] ? kthread+0xbc/0xe0
> [  205.752810]  [<ffffffff81040000>] ? xen_teardown_timer+0x10/0x70
> [  205.752812]  [<ffffffff81131180>] ? kthread_create_on_node+0x170/0x170
> [  205.752815]  [<ffffffff8162a9fc>] ? ret_from_fork+0x7c/0xb0
> [  205.752818]  [<ffffffff81131180>] ? kthread_create_on_node+0x170/0x170
> [  205.752820] ---[ end trace ed2bb7d412e082bd ]---
> [  206.737865] ------------[ cut here ]------------
