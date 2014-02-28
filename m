From: Florian Westphal <fw@strlen.de>
Subject: Re: [nf-next PATCH V2 4/5] netfilter: conntrack: seperate expect
 locking from nf_conntrack_lock
Date: Fri, 28 Feb 2014 16:08:52 +0100
Message-ID: <20140228150852.GG9965@breakpoint.cc>
References: <20140228121529.20347.38300.stgit@dragon>
 <20140228121731.20347.20481.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>,
	Patrick McHardy <kaber@trash.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:43968 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752639AbaB1PI6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 10:08:58 -0500
Content-Disposition: inline
In-Reply-To: <20140228121731.20347.20481.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> Netfilter expectations are protected with the same lock as conntrack
> entries (nf_conntrack_lock).  This patch split out expectations locking
> to use it's own lock (nf_conntrack_expect_lock).
> --- a/net/netfilter/nf_conntrack_helper.c
> +++ b/net/netfilter/nf_conntrack_helper.c
> @@ -258,7 +258,7 @@ static inline int unhelp(struct nf_conntrack_tuple_hash *i,
>  
>  	if (help && rcu_dereference_protected(
>  			help->helper,
> -			lockdep_is_held(&nf_conntrack_lock)
> +			lockdep_is_held(&nf_conntrack_expect_lock)
>  			) == me) {
>  		nf_conntrack_event(IPCT_HELPER, ct);
>  		RCU_INIT_POINTER(help->helper, NULL);

Not sure if the lockdep_is_held is correct.

> @@ -399,13 +399,14 @@ static void __nf_conntrack_helper_unregister(struct nf_conntrack_helper *me,
>  	int cpu;
>  
>  	/* Get rid of expectations */
> +	spin_lock_bh(&nf_conntrack_expect_lock);
>  	for (i = 0; i < nf_ct_expect_hsize; i++) {
>  		hlist_for_each_entry_safe(exp, next,
>  					  &net->ct.expect_hash[i], hnode) {
>  			struct nf_conn_help *help = nfct_help(exp->master);
>  			if ((rcu_dereference_protected(
>  					help->helper,
> -					lockdep_is_held(&nf_conntrack_lock)
> +					lockdep_is_held(&nf_conntrack_expect_lock)
>  					) == me || exp->helper == me) &&
>  			    del_timer(&exp->timeout)) {
>  				nf_ct_unlink_expect(exp);
> @@ -413,6 +414,7 @@ static void __nf_conntrack_helper_unregister(struct nf_conntrack_helper *me,
>  			}
>  		}
>  	}
> +	spin_unlock_bh(&nf_conntrack_expect_lock);

expect_lock is released here but

>  	/* Get rid of expecteds, set helpers to NULL. */
>  	for_each_possible_cpu(cpu) {

will invoke unhelp()

AFAIU unhelp() is safe in all cases even without
nf_conntrack_expect_lock being held:

* in first loop we hold nf_conntrack_expect_lock
* in 2nd loop we are holding the list lock, i.e.
  if the ct is in the list it cannot disappear underneath
* in last loop you'll hold the hashed lock for the particular hash
  list, so can't go away either.

So I think the lockdep annotation in uhelp is incorrect and not the
patch itself.
