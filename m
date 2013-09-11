From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf] netfilter: use RCU safe kfree for conntrack extensions
Date: Wed, 11 Sep 2013 19:50:43 +0200
Message-ID: <20130911175043.GA4824@localhost>
References: <20130911090900.0129AE8AFF@unicorn.suse.cz>
 <20130911145715.GA2882@linuxace.com>
 <20130911152804.GA5397@unicorn.suse.cz>
 <20130911170946.GA2926@linuxace.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michal Kubecek <mkubecek@suse.cz>, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
To: Phil Oester <kernel@linuxace.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:52034 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755372Ab3IKRuu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Sep 2013 13:50:50 -0400
Content-Disposition: inline
In-Reply-To: <20130911170946.GA2926@linuxace.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 11, 2013 at 10:09:47AM -0700, Phil Oester wrote:
> On Wed, Sep 11, 2013 at 05:28:05PM +0200, Michal Kubecek wrote:
> > > Looking at
> > > your proposed fix, the NAT extension data should have been cleaned
> > > from the bysource list in nf_nat_cleanup_conntrack (via __nf_ct_ext_destroy)
> > > before reaching the kfree.  Would you agree?
> > 
> > It is cleaned from the list but as it is an RCU list, other readers can
> > still be holding pointers to it. We have to wait for the RCU grace
> > period before we can reuse it.
> 
> Agreed - looks like your fix should work.  However, two nits:
> 
> 1) normally RCU functions have _rcu suffixes.  So nf_ct_ext_free should
> become nf_ct_ext_free_rcu.

That postfix is there if the function requires to be called holding
rcu read lock, not this case. I'll take this patch.

> 2) kfree_rcu was not added to the kernel until 3.0.  All of the bug
> reports I've been looking into (including the original in netfilter bugzilla
> at http://bugzilla.netfilter.org/show_bug.cgi?id=714) have been reported in
> 2.6.32 or earlier kernels.  So a different fix would need to be backported for
> -stable.  For that, we would probably export __nf_ct_ext_free_rcu from
> nf_conntrack_extend.c and change the kfree call in nf_ct_ext_free_rcu to
> call_rcu(&ct->ext->rcu, __nf_ct_ext_free_rcu). Of course the alternative
> is just to use this fix for both old and new kernels for simplicity.

Either way, we need a specific backport for 2.6.x indeed.

Thanks for tracking up this issue.
