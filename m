From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [Patch net-next] net_sched: avoid calling tcf_unbind_filter()
 in call_rcu callback
Date: Tue, 30 Sep 2014 17:53:42 -0700
Message-ID: <542B5096.2040106@gmail.com>
References: <1412118444-29179-1-git-send-email-xiyou.wangcong@gmail.com> <1412118444-29179-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	John Fastabend <john.r.fastabend@intel.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:53444 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750833AbaJAAx7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 20:53:59 -0400
Received: by mail-ob0-f176.google.com with SMTP id vb8so86885obc.35
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 17:53:59 -0700 (PDT)
In-Reply-To: <1412118444-29179-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/30/2014 04:07 PM, Cong Wang wrote:
> This fixes the following crash:
>
> [   63.976822] general protection fault: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> [   63.980094] CPU: 1 PID: 15 Comm: ksoftirqd/1 Not tainted 3.17.0-rc6+ #648
> [   63.980094] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> [   63.980094] task: ffff880117dea690 ti: ffff880117dfc000 task.ti: ffff880117dfc000
> [   63.980094] RIP: 0010:[<ffffffff817e6d07>]  [<ffffffff817e6d07>] u32_destroy_key+0x27/0x6d
> [   63.980094] RSP: 0018:ffff880117dffcc0  EFLAGS: 00010202
> [   63.980094] RAX: ffff880117dea690 RBX: ffff8800d02e0820 RCX: 0000000000000000
> [   63.980094] RDX: 0000000000000001 RSI: 0000000000000002 RDI: 6b6b6b6b6b6b6b6b
> [   63.980094] RBP: ffff880117dffcd0 R08: 0000000000000000 R09: 0000000000000000
> [   63.980094] R10: 00006c0900006ba8 R11: 00006ba100006b9d R12: 0000000000000001
> [   63.980094] R13: ffff8800d02e0898 R14: ffffffff817e6d4d R15: ffff880117387a30
> [   63.980094] FS:  0000000000000000(0000) GS:ffff88011a800000(0000) knlGS:0000000000000000
> [   63.980094] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [   63.980094] CR2: 00007f07e6732fed CR3: 000000011665b000 CR4: 00000000000006e0
> [   63.980094] Stack:
> [   63.980094]  ffff88011a9cd300 ffffffff82051ac0 ffff880117dffce0 ffffffff817e6d68
> [   63.980094]  ffff880117dffd70 ffffffff810cb4c7 ffffffff810cb3cd ffff880117dfffd8
> [   63.980094]  ffff880117dea690 ffff880117dea690 ffff880117dfffd8 000000000000000a
> [   63.980094] Call Trace:
> [   63.980094]  [<ffffffff817e6d68>] u32_delete_key_freepf_rcu+0x1b/0x1d
> [   63.980094]  [<ffffffff810cb4c7>] rcu_process_callbacks+0x3bb/0x691
> [   63.980094]  [<ffffffff810cb3cd>] ? rcu_process_callbacks+0x2c1/0x691
> [   63.980094]  [<ffffffff817e6d4d>] ? u32_destroy_key+0x6d/0x6d
> [   63.980094]  [<ffffffff810780a4>] __do_softirq+0x142/0x323
> [   63.980094]  [<ffffffff810782a8>] run_ksoftirqd+0x23/0x53
> [   63.980094]  [<ffffffff81092126>] smpboot_thread_fn+0x203/0x221
> [   63.980094]  [<ffffffff81091f23>] ? smpboot_unpark_thread+0x33/0x33
> [   63.980094]  [<ffffffff8108e44d>] kthread+0xc9/0xd1
> [   63.980094]  [<ffffffff819e00ea>] ? do_wait_for_common+0xf8/0x125
> [   63.980094]  [<ffffffff8108e384>] ? __kthread_parkme+0x61/0x61
> [   63.980094]  [<ffffffff819e43ec>] ret_from_fork+0x7c/0xb0
> [   63.980094]  [<ffffffff8108e384>] ? __kthread_parkme+0x61/0x61
>
> tp could be freed in call_rcu callback too, the order is not guaranteed.
>
> Cc: John Fastabend <john.r.fastabend@intel.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---

Thanks for catching this. What if we just drop tcf_exts_result
I can't see how its being used anymore. It appears to just be passed
around the ./net/sched files for some historic reason that is lost on
me. Would you mind testing a patch if I sent it out?

Maybe Jamal can shed some light?


>   include/net/pkt_cls.h |  6 +-----
>   net/sched/cls_u32.c   | 10 ++++++----
>   2 files changed, 7 insertions(+), 9 deletions(-)
>
> diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
> index 73f9532..ef44ad9 100644
> --- a/include/net/pkt_cls.h
> +++ b/include/net/pkt_cls.h
> @@ -20,11 +20,7 @@ int unregister_tcf_proto_ops(struct tcf_proto_ops *ops);
>   static inline unsigned long
>   __cls_set_class(unsigned long *clp, unsigned long cl)
>   {
> -	unsigned long old_cl;
> -
> -	old_cl = *clp;
> -	*clp = cl;
> -	return old_cl;
> +	return xchg(clp, cl);
>   }
>
>   static inline unsigned long
> diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
> index 4be3ebf..0472909 100644
> --- a/net/sched/cls_u32.c
> +++ b/net/sched/cls_u32.c
> @@ -358,7 +358,6 @@ static int u32_destroy_key(struct tcf_proto *tp,
>   			   struct tc_u_knode *n,
>   			   bool free_pf)
>   {
> -	tcf_unbind_filter(tp, &n->res);
>   	tcf_exts_destroy(&n->exts);
>   	if (n->ht_down)
>   		n->ht_down->refcnt--;
> @@ -416,6 +415,7 @@ static int u32_delete_key(struct tcf_proto *tp, struct tc_u_knode *key)
>   			if (pkp == key) {
>   				RCU_INIT_POINTER(*kp, key->next);
>
> +				tcf_unbind_filter(tp, &key->res);
>   				call_rcu(&key->rcu, u32_delete_key_freepf_rcu);
>   				return 0;
>   			}
> @@ -425,7 +425,7 @@ static int u32_delete_key(struct tcf_proto *tp, struct tc_u_knode *key)
>   	return 0;
>   }
>
> -static void u32_clear_hnode(struct tc_u_hnode *ht)
> +static void u32_clear_hnode(struct tcf_proto *tp, struct tc_u_hnode *ht)
>   {
>   	struct tc_u_knode *n;
>   	unsigned int h;
> @@ -434,6 +434,7 @@ static void u32_clear_hnode(struct tc_u_hnode *ht)
>   		while ((n = rtnl_dereference(ht->ht[h])) != NULL) {
>   			RCU_INIT_POINTER(ht->ht[h],
>   					 rtnl_dereference(n->next));
> +			tcf_unbind_filter(tp, &n->res);
>   			call_rcu(&n->rcu, u32_delete_key_freepf_rcu);
>   		}
>   	}
> @@ -447,7 +448,7 @@ static int u32_destroy_hnode(struct tcf_proto *tp, struct tc_u_hnode *ht)
>
>   	WARN_ON(ht->refcnt);
>
> -	u32_clear_hnode(ht);
> +	u32_clear_hnode(tp, ht);
>
>   	hn = &tp_c->hlist;
>   	for (phn = rtnl_dereference(*hn);
> @@ -482,7 +483,7 @@ static void u32_destroy(struct tcf_proto *tp)
>   		     ht;
>   		     ht = rtnl_dereference(ht->next)) {
>   			ht->refcnt--;
> -			u32_clear_hnode(ht);
> +			u32_clear_hnode(tp, ht);
>   		}
>
>   		while ((ht = rtnl_dereference(tp_c->hlist)) != NULL) {
> @@ -731,6 +732,7 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
>   		}
>
>   		u32_replace_knode(tp, tp_c, new);
> +		tcf_unbind_filter(tp, &n->res);
>   		call_rcu(&n->rcu, u32_delete_key_rcu);
>   		return 0;
>   	}
>


-- 
John Fastabend         Intel Corporation
