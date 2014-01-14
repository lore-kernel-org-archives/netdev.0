From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] [RFC] netfilter: nf_conntrack: don't relase a conntrack
 with non-zero refcnt
Date: Tue, 14 Jan 2014 19:53:29 +0100
Message-ID: <20140114185329.GB28205@breakpoint.cc>
References: <1389710201.31367.255.camel@edumazet-glaptop2.roam.corp.google.com>
 <1389720948-7883-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netfilter@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, vvs@openvz.org,
	Florian Westphal <fw@strlen.de>,
	Cyrill Gorcunov <gorcunov@openvz.org>,
	Vasiliy Averin <vvs@parallels.com>
To: Andrey Vagin <avagin@openvz.org>
Return-path: <netfilter-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1389720948-7883-1-git-send-email-avagin@openvz.org>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrey Vagin <avagin@openvz.org> wrote:
> ----
> Eric and Florian, could you look at this patch. When you say,
> that it looks good, I will ask the user to validate it.
> I can't reorder these actions, because it's reproduced on a real host
> with real users. Thanks.
> ----
> 
> nf_conntrack_free can't be called for a conntract with non-zero ref-counter,
> because it can race with nf_conntrack_find_get().

Indeed.

> A conntrack slab is created with SLAB_DESTROY_BY_RCU. Non-zero
> ref-conunter says that this conntrack is used now. So when we release a
> conntrack with non-zero counter, we break this assumption.
> 
> CPU1                                    CPU2
> ____nf_conntrack_find()
>                                         nf_ct_put()
>                                          destroy_conntrack()
>                                         ...
>                                         init_conntrack
>                                          __nf_conntrack_alloc (set use = 1)
> atomic_inc_not_zero(&ct->use) (use = 2)
>                                          if (!l4proto->new(ct, skb, dataoff, timeouts))
>                                           nf_conntrack_free(ct); (use = 2 !!!)
>                                         ...

Yes, I think this sequence is possible; we must not use nf_conntrack_free here.

> -	/* We overload first tuple to link into unconfirmed or dying list.*/
> -	BUG_ON(hlist_nulls_unhashed(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode));
> -	hlist_nulls_del_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode);
> +	if (!hlist_nulls_unhashed(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode))
> +		hlist_nulls_del_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode);

This is the only thing that I don't like about this patch.  Currently
all the conntracks in the system are always put on a list before they're
supposed to be visible/handled via refcnt system (unconfirmed, hash, or
dying list).

I think it would be nice if we could keep it that way.
If everything fails we could proably intoduce a 'larval' dummy list
similar to the one used by template conntracks?
