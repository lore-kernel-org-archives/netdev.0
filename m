From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [RFC Patch net-next 5/6] net_sched: use rcu in fast path
Date: Thu,  1 Sep 2016 22:57:19 -0700
Message-ID: <1472795840-31901-6-git-send-email-xiyou.wangcong@gmail.com>
References: <1472795840-31901-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: jhs@mojatatu.com, Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36187 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751872AbcIBF5u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 01:57:50 -0400
Received: by mail-pf0-f196.google.com with SMTP id a143so2068105pfa.3
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 22:57:50 -0700 (PDT)
In-Reply-To: <1472795840-31901-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/act_api.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 2f8db3c..fb6ff52 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -470,10 +470,14 @@ int tcf_action_exec(struct sk_buff *skb, struct tc_action **actions,
 		goto exec_done;
 	}
 	for (i = 0; i < nr_actions; i++) {
-		const struct tc_action *a = actions[i];
+		const struct tc_action *a;
 
+		rcu_read_lock();
+		a = rcu_dereference(actions[i]);
 repeat:
 		ret = a->ops->act(skb, a, res);
+		rcu_read_unlock();
+
 		if (ret == TC_ACT_REPEAT)
 			goto repeat;	/* we need a ttl - JHS */
 		if (ret != TC_ACT_PIPE)
-- 
2.1.0
