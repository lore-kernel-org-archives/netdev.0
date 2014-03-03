From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] net: fix for a race condition in the inet frag code
Date: Mon, 3 Mar 2014 18:17:04 +0100
Message-ID: <20140303171704.GA21818@breakpoint.cc>
References: <1393855520-18334-1-git-send-email-nikolay@redhat.com>
 <20140303144026.GH9965@breakpoint.cc>
 <53149694.6070603@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:52073 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751662AbaCCRRH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 12:17:07 -0500
Content-Disposition: inline
In-Reply-To: <53149694.6070603@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nikolay Aleksandrov <nikolay@redhat.com> wrote:
> On 03/03/2014 03:40 PM, Florian Westphal wrote:
> > Nikolay Aleksandrov <nikolay@redhat.com> wrote:
> >> I stumbled upon this very serious bug while hunting for another one,
> >> it's a very subtle race condition between inet_frag_evictor,
> >> inet_frag_intern and the IPv4/6 frag_queue and expire functions (basically
> >> the users of inet_frag_kill/inet_frag_put).
> >> What happens is that after a fragment has been added to the hash chain but
> >> before it's been added to the lru_list (inet_frag_lru_add), it may get
> >> deleted (either by an expired timer if the system load is high or the
> >> timer sufficiently low, or by the fraq_queue function for different
> >> reasons) before it's added to the lru_list
> > 
> > Sorry.  Not following here, see below.
> > 
> >> diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
> >> index bb075fc9a14f..322dcebfc588 100644
> >> --- a/net/ipv4/inet_fragment.c
> >> +++ b/net/ipv4/inet_fragment.c
> >> @@ -278,9 +278,10 @@ static struct inet_frag_queue *inet_frag_intern(struct netns_frags *nf,
> >>  
> >>  	atomic_inc(&qp->refcnt);
> >>  	hlist_add_head(&qp->list, &hb->chain);
> >> +	inet_frag_lru_add(nf, qp);
> >>  	spin_unlock(&hb->chain_lock);
> >>  	read_unlock(&f->lock);
> > 
> > If I understand correctly your're saying that qp can be free'd on
> > another/cpu timer right after dropping the locks.  But how is it
> > possible?
> > 
> > ->refcnt is bumped above when arming the timer (before dropping chain
> > lock), so even if the frag_expire timer fires instantly it should not
> > free qp.
> > 
> > What am I missing?
> > 
> > Thanks,
> > Florian
> > 
> An important point is that inet_frag_kill removes both the timer's refcnt and
> has an unconditional atomic_dec to remove the original/guarding refcnt, so it
> basically removes everything that's in the way.

You're right.

Problem is that when we return from inet_frag_intern() we can end up
with a qp that is no longer in the hash (inet_frag_kill was invoked)
but has been added to the lru list _after_ inet_frag_kill supposedly
removed it.

The refcnt is not 0 (yet) by the time inet_frag_intern returns
but it turns to 0 soon after on the next _put event.

Your fix makes 'in hash table but not on lru list' impossible and
thus avoids the problem.

Thanks for explaining!
