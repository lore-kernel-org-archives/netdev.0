From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [nf-next PATCH V2 4/5] netfilter: conntrack: seperate expect
 locking from nf_conntrack_lock
Date: Mon, 3 Mar 2014 12:33:39 +0100
Message-ID: <20140303123339.6f6d5c84@redhat.com>
References: <20140228121529.20347.38300.stgit@dragon>
	<20140228121731.20347.20481.stgit@dragon>
	<20140228150852.GG9965@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20140228150852.GG9965@breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 28 Feb 2014 16:08:52 +0100
Florian Westphal <fw@strlen.de> wrote:

> Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> > Netfilter expectations are protected with the same lock as conntrack
> > entries (nf_conntrack_lock).  This patch split out expectations locking
> > to use it's own lock (nf_conntrack_expect_lock).
> > --- a/net/netfilter/nf_conntrack_helper.c
> > +++ b/net/netfilter/nf_conntrack_helper.c
> > @@ -258,7 +258,7 @@ static inline int unhelp(struct nf_conntrack_tuple_hash *i,
> >  
> >  	if (help && rcu_dereference_protected(
> >  			help->helper,
> > -			lockdep_is_held(&nf_conntrack_lock)
> > +			lockdep_is_held(&nf_conntrack_expect_lock)
> >  			) == me) {
> >  		nf_conntrack_event(IPCT_HELPER, ct);
> >  		RCU_INIT_POINTER(help->helper, NULL);
> 
> Not sure if the lockdep_is_held is correct.
> 
> > @@ -399,13 +399,14 @@ static void __nf_conntrack_helper_unregister(struct nf_conntrack_helper *me,
> >  	int cpu;
> >  
> >  	/* Get rid of expectations */
> > +	spin_lock_bh(&nf_conntrack_expect_lock);
> >  	for (i = 0; i < nf_ct_expect_hsize; i++) {
> >  		hlist_for_each_entry_safe(exp, next,
> >  					  &net->ct.expect_hash[i], hnode) {
> >  			struct nf_conn_help *help = nfct_help(exp->master);
> >  			if ((rcu_dereference_protected(
> >  					help->helper,
> > -					lockdep_is_held(&nf_conntrack_lock)
> > +					lockdep_is_held(&nf_conntrack_expect_lock)
> >  					) == me || exp->helper == me) &&
> >  			    del_timer(&exp->timeout)) {
> >  				nf_ct_unlink_expect(exp);
> > @@ -413,6 +414,7 @@ static void __nf_conntrack_helper_unregister(struct nf_conntrack_helper *me,
> >  			}
> >  		}
> >  	}
> > +	spin_unlock_bh(&nf_conntrack_expect_lock);
> 
> expect_lock is released here but
> 
> >  	/* Get rid of expecteds, set helpers to NULL. */
> >  	for_each_possible_cpu(cpu) {
> 
> will invoke unhelp()
> 
> AFAIU unhelp() is safe in all cases even without
> nf_conntrack_expect_lock being held:
> 
> * in first loop we hold nf_conntrack_expect_lock
> * in 2nd loop we are holding the list lock, i.e.
>   if the ct is in the list it cannot disappear underneath
> * in last loop you'll hold the hashed lock for the particular hash
>   list, so can't go away either.
> 
> So I think the lockdep annotation in uhelp is incorrect and not the
> patch itself.

Yes, I agree with your analysis.  The code is safe, and the lockdep
annotation in unhelp is just incorrect.

I think I'm going to use rcu_dereference_raw() in unhelp this case, as
I don't think I can use rcu_dereference() there (because we are not in a
rcu read section).  And I'll add a comment to unhelp, that ct locking
is needed.  Besides in the call points of unhelp, it is quite
visible/clear that we are taking a lock protecting the ct's.

I'll send a V3 of the patchset soon with this update.
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
