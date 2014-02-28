From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [nf-next PATCH 3/5] netfilter: avoid race with exp->master ct
Date: Fri, 28 Feb 2014 12:30:37 +0100
Message-ID: <20140228123037.568fdcd9@redhat.com>
References: <20140227182220.25907.12758.stgit@dragon>
 <20140227182340.25907.6773.stgit@dragon>
 <20140227213452.GE9965@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54558 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751896AbaB1Lch (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Feb 2014 06:32:37 -0500
In-Reply-To: <20140227213452.GE9965@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 27 Feb 2014 22:34:52 +0100
Florian Westphal <fw@strlen.de> wrote:

> Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> > Preparation for disconnecting the nf_conntrack_lock from the
> > expectations code.  Once the nf_conntrack_lock is lifted, a race
> > condition is exposed.
> > 
> > The expectations master conntrack exp->master, can race with
> > delete operations, as the refcnt increment happens too late in
> > init_conntrack().  Race is against other CPUs invoking
> > ->destroy() (destroy_conntrack()), or nf_ct_delete() (via timeout
> > or early_drop()).
> > 
> > Avoid this race in nf_ct_find_expectation() by using atomic_inc_not_zero(),
> > and checking if nf_ct_is_dying() (path via nf_ct_delete()).
> > 
> > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> > Signed-off-by: Florian Westphal <fw@strlen.de>
> > ---
> > 
> >  net/netfilter/nf_conntrack_core.c   |    2 +-
> >  net/netfilter/nf_conntrack_expect.c |   16 +++++++++++++++-
> >  2 files changed, 16 insertions(+), 2 deletions(-)
> > 
> > diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
> > index ac85fd1..a822720 100644
> > --- a/net/netfilter/nf_conntrack_core.c
> > +++ b/net/netfilter/nf_conntrack_core.c
> > @@ -898,6 +898,7 @@ init_conntrack(struct net *net, struct nf_conn *tmpl,
> >  			 ct, exp);
> >  		/* Welcome, Mr. Bond.  We've been expecting you... */
> >  		__set_bit(IPS_EXPECTED_BIT, &ct->status);
> > +		/* exp->master safe, refcnt bumped in nf_ct_find_expectation */
> >  		ct->master = exp->master;
> >  		if (exp->helper) {
> >  			help = nf_ct_helper_ext_add(ct, exp->helper,
> > @@ -912,7 +913,6 @@ init_conntrack(struct net *net, struct nf_conn *tmpl,
> >  #ifdef CONFIG_NF_CONNTRACK_SECMARK
> >  		ct->secmark = exp->master->secmark;
> >  #endif
> > -		nf_conntrack_get(&ct->master->ct_general);
> >  		NF_CT_STAT_INC(net, expect_new);
> >  	} else {
> >  		__nf_ct_try_assign_helper(ct, tmpl, GFP_ATOMIC);
> > diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
> > index 4fd1ca9..2c4ffdb 100644
> > --- a/net/netfilter/nf_conntrack_expect.c
> > +++ b/net/netfilter/nf_conntrack_expect.c
> > @@ -147,13 +147,27 @@ nf_ct_find_expectation(struct net *net, u16 zone,
> >  	if (!exp)
> >  		return NULL;
> >  
> > +	/* Avoid race with other CPUs, that for exp->master ct, is
> > +	 * about to invoke ->destroy(), or nf_ct_delete() via timeout
> > +	 * or early_drop().
> > +	 *
> > +	 * The atomic_inc_not_zero() check tells:  If that fails, we
> > +	 * know that the ct is being destroyed.  If it succeeds, we
> > +	 * can be sure the ct cannot disappear underneath.
> > +	 */
> > +	if (unlikely(nf_ct_is_dying(exp->master) ||
> > +		     !atomic_inc_not_zero(&exp->master->ct_general.use)))
> > +		return NULL;
> > +
> >  	/* If master is not in hash table yet (ie. packet hasn't left
> >  	   this machine yet), how can other end know about expected?
> >  	   Hence these are not the droids you are looking for (if
> >  	   master ct never got confirmed, we'd hold a reference to it
> >  	   and weird things would happen to future packets). */
> > -	if (!nf_ct_is_confirmed(exp->master))
> > +	if (!nf_ct_is_confirmed(exp->master)) {
> > +		atomic_dec(&exp->master->ct_general.use);
> >  		return NULL;
> > +	}
> 
> Not sure if this is safe.
> 
> What about:
> CPU0: atomic_inc_not_zero()
> CPU1: calls nf_conntrack_put()
> CPU0: atomic_dec() -> zero refcnt without invocation of ->destroy

Okay, so, you are saying CPU0 should use nf_ct_put() or nf_conntrack_put().

> [ Cannot happen now because of nf_conntrack_lock ]
> 
> I'd suggest to test nf_ct_is_confirmed() first, it avoids the need to
> undo the atomic_inc_not_zero.

Okay, guess that should be okay.

> You also need to deal with the "timer-deletion-fails" a bit later in the same
> function:
> 
>         if (exp->flags & NF_CT_EXPECT_PERMANENT) {
>                 atomic_inc(&exp->use);
>                 return exp;
>         } else if (del_timer(&exp->timeout)) {
>                 nf_ct_unlink_expect(exp);
>                 return exp;
>         }
> 	// Problem: exp->master ref was bumped
> 	nf_ct_put(exp->master); // missing
>         return NULL;

True, and yes, use of use nf_ct_put() or nf_conntrack_put() would be
necessary here instead of manual refcnt dec.

Thanks for your review, I will fix it up...

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
