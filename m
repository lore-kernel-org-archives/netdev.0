From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [Patch net-next] net_sched: only create filter chains for new
 filters/actions
Date: Wed, 24 May 2017 08:37:52 +0200
Message-ID: <20170524063752.GA1908@nanopsycho>
References: <1495557757-31371-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@mellanox.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35887 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757411AbdEXGhz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 02:37:55 -0400
Received: by mail-wm0-f68.google.com with SMTP id k15so43513374wmh.3
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 23:37:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1495557757-31371-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, May 23, 2017 at 06:42:37PM CEST, xiyou.wangcong@gmail.com wrote:
>tcf_chain_get() always creates a new filter chain if not found
>in existing ones. This is totally unnecessary when we get or
>delete filters, new chain should be only created for new filters
>(or new actions).
>
>Fixes: 5bc1701881e3 ("net: sched: introduce multichain support for filters")
>Cc: Jamal Hadi Salim <jhs@mojatatu.com>
>Cc: Jiri Pirko <jiri@mellanox.com>
>Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>---
> include/net/pkt_cls.h |  3 ++-
> net/sched/act_api.c   |  2 +-
> net/sched/cls_api.c   | 13 +++++++++----
> 3 files changed, 12 insertions(+), 6 deletions(-)
>
>diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
>index 2c213a6..f776229 100644
>--- a/include/net/pkt_cls.h
>+++ b/include/net/pkt_cls.h
>@@ -18,7 +18,8 @@ int register_tcf_proto_ops(struct tcf_proto_ops *ops);
> int unregister_tcf_proto_ops(struct tcf_proto_ops *ops);
> 
> #ifdef CONFIG_NET_CLS
>-struct tcf_chain *tcf_chain_get(struct tcf_block *block, u32 chain_index);
>+struct tcf_chain *tcf_chain_get(struct tcf_block *block, u32 chain_index,
>+				bool create);
> void tcf_chain_put(struct tcf_chain *chain);
> int tcf_block_get(struct tcf_block **p_block,
> 		  struct tcf_proto __rcu **p_filter_chain);
>diff --git a/net/sched/act_api.c b/net/sched/act_api.c
>index 0ecf2a8..aed6cf2 100644
>--- a/net/sched/act_api.c
>+++ b/net/sched/act_api.c
>@@ -34,7 +34,7 @@ static int tcf_action_goto_chain_init(struct tc_action *a, struct tcf_proto *tp)
> 
> 	if (!tp)
> 		return -EINVAL;
>-	a->goto_chain = tcf_chain_get(tp->chain->block, chain_index);
>+	a->goto_chain = tcf_chain_get(tp->chain->block, chain_index, true);
> 	if (!a->goto_chain)
> 		return -ENOMEM;
> 	return 0;
>diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
>index 01a8b8b..23d2236 100644
>--- a/net/sched/cls_api.c
>+++ b/net/sched/cls_api.c
>@@ -220,7 +220,8 @@ static void tcf_chain_destroy(struct tcf_chain *chain)
> 	kfree(chain);
> }
> 
>-struct tcf_chain *tcf_chain_get(struct tcf_block *block, u32 chain_index)
>+struct tcf_chain *tcf_chain_get(struct tcf_block *block, u32 chain_index,
>+				bool create)
> {
> 	struct tcf_chain *chain;
> 
>@@ -230,7 +231,10 @@ struct tcf_chain *tcf_chain_get(struct tcf_block *block, u32 chain_index)
> 			return chain;
> 		}
> 	}
>-	return tcf_chain_create(block, chain_index);
>+	if (create)
>+		return tcf_chain_create(block, chain_index);
>+	else
>+		return NULL;
> }
> EXPORT_SYMBOL(tcf_chain_get);
> 
>@@ -509,9 +513,10 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
> 		err = -EINVAL;
> 		goto errout;
> 	}
>-	chain = tcf_chain_get(block, chain_index);
>+	chain = tcf_chain_get(block, chain_index,
>+			      n->nlmsg_type == RTM_NEWTFILTER);

First of all, I really hate all these true/false arg dances. Totaly
confusing all the time.



> 	if (!chain) {
>-		err = -ENOMEM;
>+		err = n->nlmsg_type == RTM_NEWTFILTER ? -ENOMEM : -EINVAL;

Confusing. Please do not obfuscate the code for a corner cases. Thanks.



> 		goto errout;
> 	}
> 
>-- 
>2.5.5
>
