From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] net: neighbour: add neighbour dead check for neigh_timer_handler()
Date: Wed, 18 Dec 2013 08:51:31 +0100
Message-ID: <20131218075131.GD27460@order.stressinduktion.org>
References: <529E9579.7090201@cn.fujitsu.com> <529EA9CF.2090008@huawei.com> <20131203.232122.852236751455974887.davem@davemloft.net> <529EC95A.5080908@huawei.com> <1386138457.30495.86.camel@edumazet-glaptop2.roam.corp.google.com> <529EF30A.4050609@huawei.com> <1386170645.30495.108.camel@edumazet-glaptop2.roam.corp.google.com> <529FC980.8020101@cn.fujitsu.com> <529FF066.1070307@huawei.com> <52B142AF.8070708@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, yoshfuji@linux-ipv6.org,
	joe@perches.com, vfalico@redhat.com, netdev@vger.kernel.org
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:35554 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751987Ab3LRHvd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 02:51:33 -0500
Content-Disposition: inline
In-Reply-To: <52B142AF.8070708@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ding!

May I step in for short?

On Wed, Dec 18, 2013 at 02:37:35PM +0800, Ding Tianhong wrote:
> On 2013/12/5 11:17, Ding Tianhong wrote:
> > On 2013/12/5 8:32, Gao feng wrote:
> >> On 12/04/2013 11:24 PM, Eric Dumazet wrote:
> >>> On Wed, 2013-12-04 at 17:16 +0800, Ding Tianhong wrote:
> >>>>>> 						base->running_timer = neigh->timer;
> >>>>>> 						neigh_timer_handler() => at this time, refcnt is 2;
> >>>>>>
> >>>>>> user->	neigh_changeaddr()
> >>>>>> 	neigh_flush_dev();
> >>>>>> 	neigh_del_imer, refcnt dec to 1;
> >>>>>
> >>>>> Nope : del_timer() would return 0 here, so we do not decrement refcnt.
> >>>>>
> >>>>
> >>>> The first call for del_timer() will return 1, because the timer->entry.next is not NULL,
> >>>> then in the neigh_destroy, the del_timer() again will return 0 because timer->entry.next is NULL. 
> >>>
> >>> Again no. You are very mistaken.
> >>>
> >>> del_timer() return code is not a hint. Its a precise meaning.
> >>>
> >>> It cannot return 1 if the timer function is running or is about to run.
> >>>
> >>> If you believe there is  bug in del_timer(), fix it ;)
> >>>
> >>>
> >>
> >> Yes, you are right, __run_timers did this job.
> >> So We still don't know what's the root reason.
> >>
> > Yes, I miss it, the running timer is detached from the list, thanks for all above.
> > 
> > Regards
> > Ding
> > 
> 
> 
> Hi Eric:
> 
> I was so doubt about the situation, can you give me some advise?
> 
> 	CPU0					  CPU1					  CPU2
>       --------		      			--------                		---------
> neigh_timer_handler				
> write_lock(n->lock);		
> 	...
> write_unlock(n->lock);
> n->ref_cnt = 2 or 3(if mode_time)				
> 	...					neigh_flush_dev
> 						write_lock(n->lock);
> 						n->ref_cnt = 2;
> 						n->nud_state = NUD_NONE;
> 						write_unlock(n->lock);
> 						neigh_release()
> 						n->ref_cnt = 1;
> 						...					neigh_periodic_work
> 											write_lock(n->lock);
> 											write_unlock(n->lock);
> 											neigh_release();
> 											kfree(n)
> n->ops->solicit()									...
> ...
> 
> if that possible? or I was totally wrong? pls give me some advise if I miss something, thanks a lot.

When you first posted the patch I had my doubts that there is such
race. E.g. n->dead was 0 in the neigh you posted. After all the neigh
timer has its own reference and does check ->dead before proceeding. I maybe
wrong because the memory could already be overwritten.

(Maybe we should move the ->dead check inside the write_lock to use it as a
barrier.)

Maybe there was another dereference which caused the bug. Could you check if
you have the code section from the panic? It should look something like

Code: FF FF FF .. <FF> ..

Sometimes using addr2line on vmlinux with the RIP could give another hint.

Greetings,

  Hannes
