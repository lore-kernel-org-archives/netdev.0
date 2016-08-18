From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH v2 1/1] ppp: Fix one deadlock issue of PPP when send frame
Date: Thu, 18 Aug 2016 18:13:15 +0200
Message-ID: <20160818161315.6wnv45tzw6v5napa@alphalink.fr>
References: <1471347218-24472-1-git-send-email-fgao@ikuai8.com>
 <20160817174219.y4opmhj4u77m3ufq@alphalink.fr>
 <CA+6hz4qROeAKSgQJ-tf3qaDp5zBqssq4gV39wqyUT0ctp1DHcg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gao Feng <fgao@ikuai8.com>, paulus@samba.org,
        linux-ppp@vger.kernel.org,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Feng Gao <gfree.wind@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:57493 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753888AbcHSBkF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 21:40:05 -0400
Content-Disposition: inline
In-Reply-To: <CA+6hz4qROeAKSgQJ-tf3qaDp5zBqssq4gV39wqyUT0ctp1DHcg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 18, 2016 at 08:58:31AM +0800, Feng Gao wrote:
> On Thu, Aug 18, 2016 at 1:42 AM, Guillaume Nault <g.nault@alphalink.fr> wrote:
> > On Tue, Aug 16, 2016 at 07:33:38PM +0800, fgao@ikuai8.com wrote:
> >> From: Gao Feng <fgao@ikuai8.com>
> >>
> >> PPP channel holds one spinlock before send frame. But the skb may
> >> select the same PPP channel with wrong route policy. As a result,
> >> the skb reaches the same channel path. It tries to get the same
> >> spinlock which is held before. Bang, the deadlock comes out.
> >>
> > Unless I misunderstood the problem you're trying to solve, this patch
> > doesn't really help: deadlock still occurs if the same IP is used for
> > L2TP and PPP's peer address.
> >
> 
> The deadlock happens because the same cpu try to hold the spinlock
> which is already held before by itself.
> Now the PPP_CHANNEL_LOCK_BH sets the lock owner after hold lock, then
> when the same cpu
> invokes PPP_CHANNEL_LOCK_BH again. The cl.owner equals current cpu id,
> so it only increases
> the lock_cnt without trying to hold the lock again.
> So it avoids the deadlock.
> 
I'm sorry but, again, it just _moves_ the deadlock down to L2TP. The
kernel still oops because, now, l2tp_xmit_skb() is called recursively
while holding its tunnel socket.

> >> Now add one lock owner to avoid it like xmit_lock_owner of
> >> netdev_queue. Check the lock owner before try to get the spinlock.
> >> If the current cpu is already the owner, needn't lock again. When
> >> PPP channel holds the spinlock at the first time, it sets owner
> >> with current CPU ID.
> >>
> > I think you should forbid lock recursion entirely, and drop the packet
> > if the owner tries to re-acquire the channel lock. Otherwise you just
> > move the deadlock down the stack (l2tp_xmit_skb() can't be called
> > recursively).
> 
> The reason that fix it in ppp is that there are other layer on the ppp module.
> We resolve it in ppp module, it could avoid all similar potential issues.
>
Not sure if I understand your point here.
The xmit path of PPP and its sub-layers hasn't been designed to be
reentrant. Allowing recursive sends thus require to review the full
path.

Beyond the L2TP issue discussed above, just consider the locking
dependencies used in PPP: ppp->wlock has to be held before
channel->downl. Sending a packet directly on a channel will lock
channel->downl. If this packet is routed back to the parent unit then
ppp_xmit_process() will lock ppp->wlock, effectively leading to lock
inversion and potential deadlock.

So we have two options: adapt the whole xmit path to handle recursive
sends or forbid recursion entirely. Unfortunately none of these options
looks easy to achieve:

  * Making PPP xmit path reentrant will be hard and error prone because
    of all the locking dependencies. Looks like simplifying PPP's
    locking scheme will be required first.

  * I can't see any way to reliably prevent settings where a packet sent
    on a given channel would be routed back to the parent unit.


OTOH, we can try to limit the impact of recursive sends for simple
cases:

  * Following your approach, either adapt the lower layers
    (like l2tp_xmit_skb() for L2TP), or drop the packet when
    cl.owner == smp_processor_id(). This is very limited in scope and
    doesn't address issues like locking inversions. But it may let the
    system survive long enough for the PPP to time out.

  * In the lower layer, check where the packet is going to be enqueued
    and drop it if it's the parent device. That should reliably handle
    simple and common cases. However this requires to update at least
    L2TP and PPTP and to get a way to access the parent device. Also,
    it doesn't prevent recursion with stacked interfaces.
