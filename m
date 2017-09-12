From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [Patch net v3 1/3] net_sched: get rid of tcfa_rcu
Date: Tue, 12 Sep 2017 12:40:04 +0200
Message-ID: <20170912104004.GE2036@nanopsycho>
References: <20170911233332.7594-1-xiyou.wangcong@gmail.com>
 <20170911233332.7594-2-xiyou.wangcong@gmail.com>
 <20170912094215.GB2036@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jiri@mellanox.com,
        jakub.kicinski@netronome.com, jhs@mojatatu.com,
        Eric Dumazet <edumazet@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:33028 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751313AbdILKkH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2017 06:40:07 -0400
Received: by mail-wr0-f196.google.com with SMTP id b9so5812983wra.0
        for <netdev@vger.kernel.org>; Tue, 12 Sep 2017 03:40:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170912094215.GB2036@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Sep 12, 2017 at 11:42:15AM CEST, jiri@resnulli.us wrote:
>Tue, Sep 12, 2017 at 01:33:30AM CEST, xiyou.wangcong@gmail.com wrote:
>>gen estimator has been rewritten in commit 1c0d32fde5bd
>>("net_sched: gen_estimator: complete rewrite of rate estimators"),
>>the caller is no longer needed to wait for a grace period.
>>So this patch gets rid of it.
>>
>>This also completely closes a race condition between action free
>>path and filter chain add/remove path for the following patch.
>>Because otherwise the nested RCU callback can't be caught by
>>rcu_barrier().
>>
>>Please see also the comments in code.
>
>Looks like this is causing a null pointer dereference bug for me, 100%
>of the time. Just add and remove any rule with action and you get:
>

[...]

>
>Looks like you need to save owner of the module before you call
>__tcf_idr_release so you can later on use it for module_put

This patch helps:

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index fcd7dc7..de73e71 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -514,13 +514,15 @@ EXPORT_SYMBOL(tcf_action_exec);
 
 int tcf_action_destroy(struct list_head *actions, int bind)
 {
+	const struct tc_action_ops *ops;
 	struct tc_action *a, *tmp;
 	int ret = 0;
 
 	list_for_each_entry_safe(a, tmp, actions, list) {
+		ops = a->ops;
 		ret = __tcf_idr_release(a, bind, true);
 		if (ret == ACT_P_DELETED)
-			module_put(a->ops->owner);
+			module_put(ops->owner);
 		else if (ret < 0)
 			return ret;
 	}
