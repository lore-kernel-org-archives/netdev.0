From: Andrew Vagin <avagin@parallels.com>
Subject: Re: [PATCH] [RFC] netfilter: nf_conntrack: don't relase a conntrack
 with non-zero refcnt
Date: Mon, 27 Jan 2014 17:44:54 +0400
Message-ID: <20140127134453.GA26336@paralelels.com>
References: <1389710201.31367.255.camel@edumazet-glaptop2.roam.corp.google.com>
 <1389720948-7883-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="koi8-r"
Cc: <netfilter-devel@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	<netfilter@vger.kernel.org>, <coreteam@netfilter.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<vvs@openvz.org>, Florian Westphal <fw@strlen.de>,
	Cyrill Gorcunov <gorcunov@openvz.org>,
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

We didn't get new reports from users for the last week, so these patches
fix the problem.

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
> 
> After applying the path "[PATCH] netfilter: nf_conntrack: fix RCU race
> in nf_conntrack_find_get (v3)" another bug was triggered in
> destroy_conntrack():
> <4>[67096.759334] ------------[ cut here ]------------
> <2>[67096.759353] kernel BUG at net/netfilter/nf_conntrack_core.c:211!
> ...
> <4>[67096.759837] Pid: 498649, comm: atdd veid: 666 Tainted: G         C ---------------    2.6.32-042stab084.18 #1 042stab084_18 /DQ45CB
> <4>[67096.759932] RIP: 0010:[<ffffffffa03d99ac>]  [<ffffffffa03d99ac>] destroy_conntrack+0x15c/0x190 [nf_conntrack]
> <4>[67096.760255] Call Trace:
> <4>[67096.760255]  [<ffffffff814844a7>] nf_conntrack_destroy+0x17/0x30
> <4>[67096.760255]  [<ffffffffa03d9bb5>] nf_conntrack_find_get+0x85/0x130 [nf_conntrack]
> <4>[67096.760255]  [<ffffffffa03d9fb2>] nf_conntrack_in+0x352/0xb60 [nf_conntrack]
> <4>[67096.760255]  [<ffffffffa048c771>] ipv4_conntrack_local+0x51/0x60 [nf_conntrack_ipv4]
> <4>[67096.760255]  [<ffffffff81484419>] nf_iterate+0x69/0xb0
> <4>[67096.760255]  [<ffffffff814b5b00>] ? dst_output+0x0/0x20
> <4>[67096.760255]  [<ffffffff814845d4>] nf_hook_slow+0x74/0x110
> <4>[67096.760255]  [<ffffffff814b5b00>] ? dst_output+0x0/0x20
> <4>[67096.760255]  [<ffffffff814b66d5>] raw_sendmsg+0x775/0x910
> <4>[67096.760255]  [<ffffffff8104c5a8>] ? flush_tlb_others_ipi+0x128/0x130
> <4>[67096.760255]  [<ffffffff8100bc4e>] ? apic_timer_interrupt+0xe/0x20
> <4>[67096.760255]  [<ffffffff8100bc4e>] ? apic_timer_interrupt+0xe/0x20
> <4>[67096.760255]  [<ffffffff814c136a>] inet_sendmsg+0x4a/0xb0
> <4>[67096.760255]  [<ffffffff81444e93>] ? sock_sendmsg+0x13/0x140
> <4>[67096.760255]  [<ffffffff81444f97>] sock_sendmsg+0x117/0x140
> <4>[67096.760255]  [<ffffffff8102e299>] ? native_smp_send_reschedule+0x49/0x60
> <4>[67096.760255]  [<ffffffff81519beb>] ? _spin_unlock_bh+0x1b/0x20
> <4>[67096.760255]  [<ffffffff8109d930>] ? autoremove_wake_function+0x0/0x40
> <4>[67096.760255]  [<ffffffff814960f0>] ? do_ip_setsockopt+0x90/0xd80
> <4>[67096.760255]  [<ffffffff8100bc4e>] ? apic_timer_interrupt+0xe/0x20
> <4>[67096.760255]  [<ffffffff8100bc4e>] ? apic_timer_interrupt+0xe/0x20
> <4>[67096.760255]  [<ffffffff814457c9>] sys_sendto+0x139/0x190
> <4>[67096.760255]  [<ffffffff810efa77>] ? audit_syscall_entry+0x1d7/0x200
> <4>[67096.760255]  [<ffffffff810ef7c5>] ? __audit_syscall_exit+0x265/0x290
> <4>[67096.760255]  [<ffffffff81474daf>] compat_sys_socketcall+0x13f/0x210
> <4>[67096.760255]  [<ffffffff8104dea3>] ia32_sysret+0x0/0x5
> 
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Florian Westphal <fw@strlen.de>
> Cc: Cyrill Gorcunov <gorcunov@openvz.org>
> Cc: Vasiliy Averin <vvs@parallels.com>
> Signed-off-by: Andrey Vagin <avagin@openvz.org>
> ---
>  include/net/netfilter/nf_conntrack.h |  1 -
>  net/netfilter/nf_conntrack_core.c    | 18 +++++++++++-------
>  net/netfilter/nf_conntrack_netlink.c |  2 +-
>  net/netfilter/nf_synproxy_core.c     |  4 ++--
>  net/netfilter/xt_CT.c                |  2 +-
>  5 files changed, 15 insertions(+), 12 deletions(-)
> 
> diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
> index 01ea6ee..d338316 100644
> --- a/include/net/netfilter/nf_conntrack.h
> +++ b/include/net/netfilter/nf_conntrack.h
> @@ -243,7 +243,6 @@ void nf_ct_untracked_status_or(unsigned long bits);
>  void nf_ct_iterate_cleanup(struct net *net,
>  			   int (*iter)(struct nf_conn *i, void *data),
>  			   void *data, u32 portid, int report);
> -void nf_conntrack_free(struct nf_conn *ct);
>  struct nf_conn *nf_conntrack_alloc(struct net *net, u16 zone,
>  				   const struct nf_conntrack_tuple *orig,
>  				   const struct nf_conntrack_tuple *repl,
> diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
> index b56e53b..c38cc74 100644
> --- a/net/netfilter/nf_conntrack_core.c
> +++ b/net/netfilter/nf_conntrack_core.c
> @@ -198,6 +198,8 @@ clean_from_lists(struct nf_conn *ct)
>  	nf_ct_remove_expectations(ct);
>  }
>  
> +static void nf_conntrack_free(struct nf_conn *ct);
> +
>  static void
>  destroy_conntrack(struct nf_conntrack *nfct)
>  {
> @@ -226,9 +228,8 @@ destroy_conntrack(struct nf_conntrack *nfct)
>  	 * too. */
>  	nf_ct_remove_expectations(ct);
>  
> -	/* We overload first tuple to link into unconfirmed or dying list.*/
> -	BUG_ON(hlist_nulls_unhashed(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode));
> -	hlist_nulls_del_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode);
> +	if (!hlist_nulls_unhashed(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode))
> +		hlist_nulls_del_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode);
>  
>  	NF_CT_STAT_INC(net, delete);
>  	spin_unlock_bh(&nf_conntrack_lock);
> @@ -772,18 +773,21 @@ struct nf_conn *nf_conntrack_alloc(struct net *net, u16 zone,
>  }
>  EXPORT_SYMBOL_GPL(nf_conntrack_alloc);
>  
> -void nf_conntrack_free(struct nf_conn *ct)
> +static void nf_conntrack_free(struct nf_conn *ct)
>  {
>  	struct net *net = nf_ct_net(ct);
>  
> +	/* A freed object has refcnt == 0, thats
> +	 * the golden rule for SLAB_DESTROY_BY_RCU
> +	 */
> +	NF_CT_ASSERT(atomic_read(&ct->ct_general.use) == 0);
> +
>  	nf_ct_ext_destroy(ct);
>  	nf_ct_ext_free(ct);
>  	kmem_cache_free(net->ct.nf_conntrack_cachep, ct);
>  	smp_mb__before_atomic_dec();
>  	atomic_dec(&net->ct.count);
>  }
> -EXPORT_SYMBOL_GPL(nf_conntrack_free);
> -
>  
>  /* Allocate a new conntrack: we return -ENOMEM if classification
>     failed due to stress.  Otherwise it really is unclassifiable. */
> @@ -835,7 +839,7 @@ init_conntrack(struct net *net, struct nf_conn *tmpl,
>  	}
>  
>  	if (!l4proto->new(ct, skb, dataoff, timeouts)) {
> -		nf_conntrack_free(ct);
> +		nf_ct_put(ct);
>  		pr_debug("init conntrack: can't track with proto module\n");
>  		return NULL;
>  	}
> diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
> index 3e91ad3..fadd0f3 100644
> --- a/net/netfilter/nf_conntrack_netlink.c
> +++ b/net/netfilter/nf_conntrack_netlink.c
> @@ -1732,7 +1732,7 @@ ctnetlink_create_conntrack(struct net *net, u16 zone,
>  err2:
>  	rcu_read_unlock();
>  err1:
> -	nf_conntrack_free(ct);
> +	nf_ct_put(ct);
>  	return ERR_PTR(err);
>  }
>  
> diff --git a/net/netfilter/nf_synproxy_core.c b/net/netfilter/nf_synproxy_core.c
> index 9858e3e..d12234c 100644
> --- a/net/netfilter/nf_synproxy_core.c
> +++ b/net/netfilter/nf_synproxy_core.c
> @@ -381,7 +381,7 @@ static int __net_init synproxy_net_init(struct net *net)
>  err3:
>  	free_percpu(snet->stats);
>  err2:
> -	nf_conntrack_free(ct);
> +	nf_ct_put(ct);
>  err1:
>  	return err;
>  }
> @@ -390,7 +390,7 @@ static void __net_exit synproxy_net_exit(struct net *net)
>  {
>  	struct synproxy_net *snet = synproxy_pernet(net);
>  
> -	nf_conntrack_free(snet->tmpl);
> +	nf_ct_put(snet->tmpl);
>  	synproxy_proc_exit(net);
>  	free_percpu(snet->stats);
>  }
> diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
> index da35ac0..da4edfe 100644
> --- a/net/netfilter/xt_CT.c
> +++ b/net/netfilter/xt_CT.c
> @@ -237,7 +237,7 @@ out:
>  	return 0;
>  
>  err3:
> -	nf_conntrack_free(ct);
> +	nf_ct_put(ct);
>  err2:
>  	nf_ct_l3proto_module_put(par->family);
>  err1:
> -- 
> 1.8.4.2
> 
