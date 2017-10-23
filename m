From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 04/15] net_sched: remove RCU callbacks in matchall filter
Date: Mon, 23 Oct 2017 15:02:53 -0700
Message-ID: <20171023220304.2268-5-xiyou.wangcong@gmail.com>
References: <20171023220304.2268-1-xiyou.wangcong@gmail.com>
Cc: paulmck@linux.vnet.ibm.com, jhs@mojatatu.com,
        john.fastabend@gmail.com, Chris Mi <chrism@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Jiri Pirko <jiri@resnulli.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:55338 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751272AbdJWWDh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 18:03:37 -0400
Received: by mail-pf0-f193.google.com with SMTP id 17so18105395pfn.12
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 15:03:37 -0700 (PDT)
In-Reply-To: <20171023220304.2268-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace call_rcu() with synchronize_rcu().

Reported-by: Chris Mi <chrism@mellanox.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Jiri Pirko <jiri@resnulli.us>
Cc: John Fastabend <john.fastabend@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/cls_matchall.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/sched/cls_matchall.c b/net/sched/cls_matchall.c
index eeac606c95ab..459614cf4186 100644
--- a/net/sched/cls_matchall.c
+++ b/net/sched/cls_matchall.c
@@ -21,7 +21,6 @@ struct cls_mall_head {
 	struct tcf_result res;
 	u32 handle;
 	u32 flags;
-	struct rcu_head	rcu;
 };
 
 static int mall_classify(struct sk_buff *skb, const struct tcf_proto *tp,
@@ -41,11 +40,8 @@ static int mall_init(struct tcf_proto *tp)
 	return 0;
 }
 
-static void mall_destroy_rcu(struct rcu_head *rcu)
+static void __mall_destroy(struct cls_mall_head *head)
 {
-	struct cls_mall_head *head = container_of(rcu, struct cls_mall_head,
-						  rcu);
-
 	tcf_exts_destroy(&head->exts);
 	kfree(head);
 }
@@ -96,7 +92,8 @@ static void mall_destroy(struct tcf_proto *tp)
 	if (tc_should_offload(dev, head->flags))
 		mall_destroy_hw_filter(tp, head, (unsigned long) head);
 
-	call_rcu(&head->rcu, mall_destroy_rcu);
+	synchronize_rcu();
+	__mall_destroy(head);
 }
 
 static void *mall_get(struct tcf_proto *tp, u32 handle)
-- 
2.13.0
