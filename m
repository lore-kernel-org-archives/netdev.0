From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] netfilter: nf_conntrack: release conntrack from rcu
 callback
Date: Mon, 6 Jan 2014 18:02:35 +0100
Message-ID: <20140106170235.GJ28854@breakpoint.cc>
References: <1389023672-14351-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, vvs@openvz.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	Cyrill Gorcunov <gorcunov@openvz.org>
To: Andrey Vagin <avagin@openvz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1389023672-14351-1-git-send-email-avagin@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrey Vagin <avagin@openvz.org> wrote:
> Lets look at destroy_conntrack:
> 
> hlist_nulls_del_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode);
> ...
> nf_conntrack_free(ct)
> 	kmem_cache_free(net->ct.nf_conntrack_cachep, ct);
> 
> The hash is protected by rcu, so readers look up conntracks without
> locks.
> A conntrack is removed from the hash, but in this moment a few readers
> still can use the conntrack, so if we call kmem_cache_free now, all
> readers will read released object.
> 
> Bellow you can find more tricky race condition of three tasks.
> 
> task 1			task 2			task 3
> 			nf_conntrack_find_get
> 			 ____nf_conntrack_find
> destroy_conntrack
>  hlist_nulls_del_rcu
>  nf_conntrack_free
>  kmem_cache_free
> 						__nf_conntrack_alloc
> 						 kmem_cache_alloc
> 						 memset(&ct->tuplehash[IP_CT_DIR_MAX],
> 			 if (nf_ct_is_dying(ct))
> 
> In this case the task 2 will not understand, that it uses a wrong
> conntrack.

Can you elaborate?
Yes, nf_ct_is_dying(ct) might be called for the wrong conntrack.

But, in case we _think_ that its the right one we call
nf_ct_tuple_equal() to verify we indeed found the right one:

       h = ____nf_conntrack_find(net, zone, tuple, hash);
       if (h) { // might be released right now, but page won't go away (SLAB_BY_RCU)
                ct = nf_ct_tuplehash_to_ctrack(h);
                if (unlikely(nf_ct_is_dying(ct) ||
                             !atomic_inc_not_zero(&ct->ct_general.use)))
			// which means we should hit this path (0 ref).
                        h = NULL;
                else {
			// otherwise, it cannot go away from under us, since
			// we own a reference now.
                        if (unlikely(!nf_ct_tuple_equal(tuple, &h->tuple) ||
                                     nf_ct_zone(ct) != zone)) {
			// if we get here, the entry got recycled on other cpu
			// for a different tuple, we can bail out and drop
			// the reference safely and re-try the lookup
                                nf_ct_put(ct);
                                goto begin;
                        }
                }
