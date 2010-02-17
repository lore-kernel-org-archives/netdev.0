From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next-2.6] xt_hashlimit: fix locking
Date: Wed, 17 Feb 2010 21:08:49 +0100
Message-ID: <4B7C4CD1.1070105@trash.net>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>	 <20100216145550.2796.32.sendpatchset@x2.localnet> <1266425027.3075.66.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1266425027.3075.66.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Patrick, David
> 
> I believe this patch has a problem, since latest net-next-2.6 triggers :
> 
> [  240.682047] INFO: task iptables:4512 blocked for more than 120
> seconds.
> [  240.682125] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
> disables this message.
> [  240.682198] iptables      D f7a69c48     0  4512   4436 0x00000000
> [  240.682201]  f7a69c5c 00000086 00000002 f7a69c48 c3603304 00000000
> c0379b0d 0000000e
> [  240.682540]  00000138 f8c06504 fffbef49 d15abc2a 00000007 c0785000
> c0788304 00000000
> [  240.682861]  f81af0c0 c078d080 d157e120 00000007 f81aee40 c037a608
> 00000202 f9e38478
> [  240.683191] Call Trace:
> [  240.683247]  [<c0379b0d>] ? get_from_free_list+0x3d/0x50
> [  240.683303]  [<c037a608>] ? ida_pre_get+0x18/0xe0
> [  240.683359]  [<c05503ed>] __mutex_lock_slowpath+0xed/0x230
> [  240.683426]  [<c0550540>] mutex_lock+0x10/0x20
> [  240.683488]  [<c04dee7e>] hashlimit_mt_check+0x29e/0x380
> [  240.683544]  [<c04de02c>] xt_check_match+0x9c/0x1b0
> [  240.683599]  [<c05509a7>] ? __mutex_lock_interruptible_slowpath
> +0x1a7/0x260
> [  240.683657]  [<c05509a7>] ? __mutex_lock_interruptible_slowpath
> +0x1a7/0x260
> [  240.683716]  [<c05502fd>] ? mutex_unlock+0xd/0x10
> [  240.683770]  [<c04ddb1f>] ? xt_find_match+0xdf/0x150
> [  240.683831]  [<c0521994>] translate_table+0x384/0x760
> [  240.683886]  [<c04dde02>] ? xt_alloc_table_info+0x52/0xc0
> [  240.683942]  [<c0522bef>] do_ipt_set_ctl+0x16f/0x440
> [  240.683998]  [<c04da2cb>] nf_sockopt+0x15b/0x1a0
> [  240.684062]  [<c0551ca0>] ? _raw_spin_lock_bh+0x10/0x30
> [  240.684118]  [<c04da369>] nf_setsockopt+0x29/0x30
> [  240.684177]  [<c04eb96e>] ip_setsockopt+0x8e/0xa0
> [  240.684233]  [<c02bd6ec>] ? page_add_new_anon_rmap+0x7c/0x90
> [  240.684289]  [<c0504df4>] raw_setsockopt+0x44/0x80
> [  240.684345]  [<c04aaf87>] sock_common_setsockopt+0x27/0x30
> [  240.684411]  [<c04a9569>] sys_setsockopt+0x59/0xb0
> [  240.684472]  [<c04aa90a>] sys_socketcall+0x12a/0x280
> [  240.684528]  [<c0202c50>] sysenter_do_call+0x12/0x26
> 
> 
> htable_create() is called with hashlimit_mutex already hold

Ah crap, I messed this up during the merge, sorry.

> Maybe original race could be solved using atomic_inc_not_zero() instead
> of atomic_inc() ?

That would have been a possibility, but just getting rid of
the unnecessary locking seems better to me.

> Or following quick & dirty patch just cures the problem.

Thanks, this looks fine.

> [PATCH net-next-2.6] xt_hashlimit: fix locking
> 
> Commit 2eff25c18c3d332d3c4dd98f2ac9b7114e9771b0
> (netfilter: xt_hashlimit: fix race condition and simplify locking)
> added a mutex deadlock :
> htable_create() is called with hashlimit_mutex already locked
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
> index e47fb80..d952806 100644
> --- a/net/netfilter/xt_hashlimit.c
> +++ b/net/netfilter/xt_hashlimit.c
> @@ -262,9 +262,7 @@ static int htable_create_v0(struct net *net, struct xt_hashlimit_info *minfo, u_
>  	hinfo->timer.expires = jiffies + msecs_to_jiffies(hinfo->cfg.gc_interval);
>  	add_timer(&hinfo->timer);
>  
> -	mutex_lock(&hashlimit_mutex);
>  	hlist_add_head(&hinfo->node, &hashlimit_net->htables);
> -	mutex_unlock(&hashlimit_mutex);
>  
>  	return 0;
>  }
> @@ -327,9 +325,7 @@ static int htable_create(struct net *net, struct xt_hashlimit_mtinfo1 *minfo,
>  	hinfo->timer.expires = jiffies + msecs_to_jiffies(hinfo->cfg.gc_interval);
>  	add_timer(&hinfo->timer);
>  
> -	mutex_lock(&hashlimit_mutex);
>  	hlist_add_head(&hinfo->node, &hashlimit_net->htables);
> -	mutex_unlock(&hashlimit_mutex);
>  
>  	return 0;
>  }
> 
> 

