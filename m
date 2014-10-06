From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sched: cls_cgroup tear down exts and ematch from
 rcu callback
Date: Sun, 05 Oct 2014 21:31:46 -0400 (EDT)
Message-ID: <20141005.213146.1400362219156302379.davem@davemloft.net>
References: <20141003163333.20118.59609.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, netdev@vger.kernel.org, jhs@mojatatu.com,
	eric.dumazet@gmail.com
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56624 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751809AbaJFBbs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2014 21:31:48 -0400
In-Reply-To: <20141003163333.20118.59609.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Fri, 03 Oct 2014 09:33:35 -0700

> It is not RCU safe to destroy the action chain while there
> is a possibility of readers accessing it. Move this code
> into the rcu callback using the same rcu callback used in the
> code patch to make a change to head.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
 ...
> @@ -156,10 +156,8 @@ static void cls_cgroup_destroy(struct tcf_proto *tp)
>  	struct cls_cgroup_head *head = rtnl_dereference(tp->root);
>  
>  	if (head) {
> -		tcf_exts_destroy(&head->exts);
> -		tcf_em_tree_destroy(head->net, &head->ematches);
>  		RCU_INIT_POINTER(tp->root, NULL);
> -		kfree_rcu(head, rcu);
> +		call_rcu(&head->rcu, cls_cgroup_destroy_rcu);
>  	}

tcf_em_tree_destroy() takes head->tp as it's first argument in my
net-next tree, maybe you need to respin this?
