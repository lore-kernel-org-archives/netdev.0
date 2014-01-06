From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] netfilter: nf_conntrack: release conntrack from rcu
 callback
Date: Mon, 6 Jan 2014 22:53:35 +0100
Message-ID: <20140106215335.GC9894@breakpoint.cc>
References: <1389023672-14351-1-git-send-email-avagin@openvz.org>
 <20140106170235.GJ28854@breakpoint.cc>
 <20140106205414.GA19788@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, Andrey Vagin <avagin@openvz.org>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, vvs@openvz.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	Cyrill Gorcunov <gorcunov@openvz.org>
To: Andrew Vagin <avagin@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140106205414.GA19788@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Vagin <avagin@gmail.com> wrote:
> On Mon, Jan 06, 2014 at 06:02:35PM +0100, Florian Westphal wrote:
> > Andrey Vagin <avagin@openvz.org> wrote:
> > > Lets look at destroy_conntrack:
> > > 
> > > hlist_nulls_del_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode);
> > > ...
> > > nf_conntrack_free(ct)
> > > 	kmem_cache_free(net->ct.nf_conntrack_cachep, ct);
> > > 
> > > The hash is protected by rcu, so readers look up conntracks without
> > > locks.
> > > A conntrack is removed from the hash, but in this moment a few readers
> > > still can use the conntrack, so if we call kmem_cache_free now, all
> > > readers will read released object.
> > > 
> > > Bellow you can find more tricky race condition of three tasks.
> > > 
> > > task 1			task 2			task 3
> > > 			nf_conntrack_find_get
> > > 			 ____nf_conntrack_find
> > > destroy_conntrack
> > >  hlist_nulls_del_rcu
> > >  nf_conntrack_free
> > >  kmem_cache_free
> > > 						__nf_conntrack_alloc
> > > 						 kmem_cache_alloc
> > > 						 memset(&ct->tuplehash[IP_CT_DIR_MAX],
> > > 			 if (nf_ct_is_dying(ct))
> > > 
> > > In this case the task 2 will not understand, that it uses a wrong
> > > conntrack.
> > 
> > Can you elaborate?
> > Yes, nf_ct_is_dying(ct) might be called for the wrong conntrack.
> > 
> > But, in case we _think_ that its the right one we call
> > nf_ct_tuple_equal() to verify we indeed found the right one:
> 
> Ok. task3 creates a new contrack and nf_ct_tuple_equal() returns true on
> it. Looks like it's possible.

IFF we're recycling the exact same tuple (i.e., flow was destroyed/terminated
AND has been re-created in identical fashion on another cpu)
AND it is not yet confirmed (ie. its not in hash table any more but in
unconfirmed list) then, yes, I think you're right.

> unitialized contrack. It's really bad, because the code supposes that
> conntrack can not be initialized in two threads concurrently. For
> example BUG can be triggered from nf_nat_setup_info():
> 
> BUG_ON(nf_nat_initialized(ct, maniptype));

Right, since a new conntrack entry is not supposed to be in the hash
table.

> >                 ct = nf_ct_tuplehash_to_ctrack(h);
> >                 if (unlikely(nf_ct_is_dying(ct) ||
> >                              !atomic_inc_not_zero(&ct->ct_general.use)))
> > 			// which means we should hit this path (0 ref).
> >                         h = NULL;
> >                 else {
> > 			// otherwise, it cannot go away from under us, since
> > 			// we own a reference now.
> >                         if (unlikely(!nf_ct_tuple_equal(tuple, &h->tuple) ||
> >                                      nf_ct_zone(ct) != zone)) {

Perhaps this needs additional !nf_ct_is_confirmed()?

It would cover your case (found a recycled element that has been put on
the unconfirmed list (refcnt already set to 1, ct->tuple is set) on another cpu,
extensions possibly not yet fully initialised), and the same tuple).

Regards,
Florian
