From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [PATCH v2] netfilter: ipset: Fix sleeping memory allocation in
 atomic context
Date: Thu, 15 Oct 2015 20:25:21 +0200 (CEST)
Message-ID: <alpine.DEB.2.10.1510152015370.12052@blackhole.kfki.hu>
References: <1444906569-9131-1-git-send-email-kernel@kyup.com>  <1444915978.4200.4.camel@edumazet-glaptop2.roam.corp.google.com>  <561FAD24.4050708@kyup.com> <1444919523.4200.16.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Nikolay Borisov <kernel@kyup.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	operations@siteground.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.kfki.hu ([148.6.0.26]:51376 "EHLO smtp1.kfki.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751329AbbJOSYD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2015 14:24:03 -0400
In-Reply-To: <1444919523.4200.16.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Thu, 15 Oct 2015, Eric Dumazet wrote:

> On Thu, 2015-10-15 at 16:41 +0300, Nikolay Borisov wrote:
> > 
> > On 10/15/2015 04:32 PM, Eric Dumazet wrote:
> > > On Thu, 2015-10-15 at 13:56 +0300, Nikolay Borisov wrote:
> > >> Commit 00590fdd5be0 introduced RCU locking in list type and in
> > >> doing so introduced a memory allocation in list_set_add, which
> > >> results in the following splat:
> > >>
> > >> BUG: sleeping function called from invalid context at mm/page_alloc.c:2759
> > >> in_atomic(): 1, irqs_disabled(): 0, pid: 9664, name: ipset
> > >> CPU: 18 PID: 9664 Comm: ipset Tainted: G           O 3.12.47-clouder3 #1
> > >> Hardware name: Supermicro X10DRi/X10DRi, BIOS 1.1 04/14/2015
> > >>  0000000000000002 ffff881fd14273c8 ffffffff8163d891 ffff881fcb4264b0
> > >>  ffff881fcb4260c0 ffff881fd14273e8 ffffffff810ba5bf ffff881fd1427558
> > >>  0000000000000000 ffff881fd1427568 ffffffff81142b33 ffff881f00000000
> > >> Call Trace:
> > >>  [<ffffffff8163d891>] dump_stack+0x58/0x7f
> > >>  [<ffffffff810ba5bf>] __might_sleep+0xdf/0x110
> > >>  [<ffffffff81142b33>] __alloc_pages_nodemask+0x243/0xc20
> > >>  [<ffffffff81181c6e>] alloc_pages_current+0xbe/0x170
> > >>  [<ffffffff81188315>] new_slab+0x295/0x340
> > >>  [<ffffffff81189a40>] __slab_alloc+0x2c0/0x5a0
> > >>  [<ffffffff8164000c>] ? __schedule+0x2dc/0x760
> > >>  [<ffffffff8118a71b>] __kmalloc+0x11b/0x230
> > >>  [<ffffffffa02bd0ac>] ? ip_set_get_byname+0xec/0x100 [ip_set]
> > >>  [<ffffffffa02d23fb>] list_set_uadd+0x16b/0x314 [ip_set_list_set]
> > >>  [<ffffffff81642148>] ? _raw_write_unlock_bh+0x28/0x30
> > >>  [<ffffffffa02d1cfc>] list_set_uadt+0x21c/0x320 [ip_set_list_set]
> > >>  [<ffffffffa02d2290>] ? list_set_create+0x1a0/0x1a0 [ip_set_list_set]
> > >>  [<ffffffffa02be242>] call_ad+0x82/0x200 [ip_set]
> > >>  [<ffffffffa02bb171>] ? find_set_type+0x51/0xa0 [ip_set]
> > >>  [<ffffffff8133f275>] ? nla_parse+0xf5/0x130
> > >>  [<ffffffffa02be8ae>] ip_set_uadd+0x20e/0x2d0 [ip_set]
> > >>  [<ffffffffa02be013>] ? ip_set_create+0x2a3/0x450 [ip_set]
> > >>  [<ffffffffa02be6a0>] ? ip_set_udel+0x2e0/0x2e0 [ip_set]
> > >>  [<ffffffff815b316e>] nfnetlink_rcv_msg+0x31e/0x330
> > >>  [<ffffffff815b2e91>] ? nfnetlink_rcv_msg+0x41/0x330
> > >>  [<ffffffff815b2e50>] ? nfnl_lock+0x30/0x30
> > >>  [<ffffffff815ae179>] netlink_rcv_skb+0xa9/0xd0
> > >>  [<ffffffff815b2d45>] nfnetlink_rcv+0x15/0x20
> > >>  [<ffffffff815ade5f>] netlink_unicast+0x10f/0x190
> > >>  [<ffffffff815aedb0>] netlink_sendmsg+0x2c0/0x660
> > >>  [<ffffffff81567f00>] sock_sendmsg+0x90/0xc0
> > >>  [<ffffffff81565b03>] ? move_addr_to_user+0xa3/0xc0
> > >>  [<ffffffff81568552>] ? ___sys_recvmsg+0x182/0x300
> > >>  [<ffffffff81568064>] SYSC_sendto+0x134/0x180
> > >>  [<ffffffff811c4e01>] ? mntput+0x21/0x30
> > >>  [<ffffffff81572d2f>] ? __kfree_skb+0x3f/0xa0
> > >>  [<ffffffff815680be>] SyS_sendto+0xe/0x10
> > >>  [<ffffffff816434b2>] system_call_fastpath+0x16/0x1b
> > >>
> > >> The call chain leading to this is as follow:
> > >> call_ad -> list_set_uadt -> list_set_uadd -> kzalloc(, GFP_KERNEL).
> > >> And since GFP_KERNEL allows initiating direct reclaim thus
> > >> potentially sleeping in the allocation path, this leads to the
> > >> aforementioned splat.
> > >>
> > >> To fix it change the allocation type to GFP_ATOMIC, to
> > >> correctly reflect that it is occuring in an atomic context.
> > >>
> > >> Fixes: 00590fdd5be0 ("netfilter: ipset: Introduce RCU locking in list type")
> > >>
> > >> Acked-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
> > >> Signed-off-by: Nikolay Borisov <kernel@kyup.com>
> > >> ---
> > >>
> > >> Changes since V1: 
> > >>  * Added acked-by 
> > >>  * Fixed patch header 
> > >>
> > >>  net/netfilter/ipset/ip_set_list_set.c | 2 +-
> > >>  1 file changed, 1 insertion(+), 1 deletion(-)
> > >>
> > >> diff --git a/net/netfilter/ipset/ip_set_list_set.c b/net/netfilter/ipset/ip_set_list_set.c
> > >> index a1fe537..5a30ce6 100644
> > >> --- a/net/netfilter/ipset/ip_set_list_set.c
> > >> +++ b/net/netfilter/ipset/ip_set_list_set.c
> > >> @@ -297,7 +297,7 @@ list_set_uadd(struct ip_set *set, void *value, const struct ip_set_ext *ext,
> > >>  	      ip_set_timeout_expired(ext_timeout(n, set))))
> > >>  		n =  NULL;
> > >>  
> > >> -	e = kzalloc(set->dsize, GFP_KERNEL);
> > >> +	e = kzalloc(set->dsize, GFP_ATOMIC);
> > >>  	if (!e)
> > >>  		return -ENOMEM;
> > >>  	e->id = d->id;
> > > 
> > > This patch looks very bogus to me.
> > > 
> > > Could we fix the root cause please ?
> > > 
> > > Root cause is that somewhere in this controlling path, an erroneous
> > > rcu_read_lock() is used, while it is very probably not needed, as
> > > controlling path should be protected by a mutex, which definitely is
> > > sane, because it allows us to perform GFP_KERNEL allocations and being
> > > preempted.
> > > 
> > > Why are we using rcu_read_lock() in list_set_list() ?
> > > 
> > > This looks as yet another bit of 'let us throw
> > > rcu_read_lock()/rcu_read_unlock() pairs' all over the places because it
> > > feels so good.
> > 
> > I did check the call paths and there isn't an rcu_read_lock called in
> > list_set_uadt/list_set_uadd. On the contrary, this "write" operation to
> > the list is being serialised in call_ad() via set->lock spin_lock.
> > 
> > What am I missing here?
> 
> I was not complaining to you, but to Jozsef ;)
> 
> Looking at commit 00590fdd5be0d7 terse changelog, we have to look at
> whole commit, and find suspicious rcu_read_lock()
> 
> Apparently, before this commit, allocations were safe, in process
> context (and using GFP_KERNEL), but after the commit, we have the
> unfortunate side effect of having potential burst of allocations
> done from bh context, using the special reserves dedicated to GFP_ATOMIC
> true users (processing packets from softirq handlers)

Before commit 00590fdd5be0d7 the elements was stored in a preallocated 
array and there was no need to call kzalloc() at all in list_set_uadd().
 
> I hate when we add more GFP_ATOMIC allocations all over the places,
> as this increases the risk of depleting memory reserves.

I don't like it either - maybe that was the reason I entered GFP_KERNEL 
instead of thinking about that the code is called inside a spinlock.

> Can the spinlock be converted to a mutex ? If not, then instead of
> putting a stack trace in your changelog, a good explanation would be
> more useful.

Nikolay answered this pretty well: we wouldn't need the spinlock at all, 
because all commands are serialized anyway with the netlink mutex. But the 
garbage collector is called by a timer and therefore spinlock is used.

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlecsik.jozsef@wigner.mta.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : Wigner Research Centre for Physics, Hungarian Academy of Sciences
          H-1525 Budapest 114, POB. 49, Hungary
