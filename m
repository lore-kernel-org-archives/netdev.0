From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] [RFC] netfilter: nf_conntrack: don't relase a conntrack
 with non-zero refcnt
Date: Tue, 14 Jan 2014 21:44:22 +0400
Message-ID: <20140114174421.GC1916@moon>
References: <1389710201.31367.255.camel@edumazet-glaptop2.roam.corp.google.com>
 <1389720948-7883-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netfilter@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	vvs@openvz.org, Florian Westphal <fw@strlen.de>,
	Vasiliy Averin <vvs@parallels.com>
To: Andrey Vagin <avagin@openvz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1389720948-7883-1-git-send-email-avagin@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 14, 2014 at 09:35:48PM +0400, Andrey Vagin wrote:
> ----
> Eric and Florian, could you look at this patch. When you say,
> that it looks good, I will ask the user to validate it.
> I can't reorder these actions, because it's reproduced on a real host
> with real users. Thanks.
> ----
> 
> nf_conntrack_free can't be called for a conntract with non-zero ref-counter,
> because it can race with nf_conntrack_find_get().
> 
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
>                                         __nf_conntrack_alloc (set use = 1)
>  if (!nf_ct_key_equal(h, tuple, zone))
>   nf_ct_put(ct); (use = 0)
>    destroy_conntrack()
>                                         /* continue to work with CT */

If I didn't miss something obvious this looks like a pretty possible
scenario. Thanks!
