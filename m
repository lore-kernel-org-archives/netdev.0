From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 1/2] net_sched: acquire RTNL in tc_action_net_exit()
Date: Wed,  1 Nov 2017 10:23:49 -0700
Message-ID: <20171101172350.12842-2-xiyou.wangcong@gmail.com>
References: <20171101172350.12842-1-xiyou.wangcong@gmail.com>
Cc: lucasb@mojatatu.com, Cong Wang <xiyou.wangcong@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@resnulli.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:54262 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754751AbdKARYC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 13:24:02 -0400
Received: by mail-pg0-f65.google.com with SMTP id s2so2650569pge.10
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 10:24:02 -0700 (PDT)
In-Reply-To: <20171101172350.12842-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I forgot to acquire RTNL in tc_action_net_exit()
which leads that action ops->cleanup() is not always
called with RTNL. This usually is not a big deal because
this function is called after all netns refcnt are gone,
but given RTNL protects more than just actions, add it
for safety and consistency.

Also add an assertion to catch other potential bugs.

Fixes: ddf97ccdd7cb ("net_sched: add network namespace support for tc actions")
Reported-by: Lucas Bates <lucasb@mojatatu.com>
Tested-by: Lucas Bates <lucasb@mojatatu.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: Jiri Pirko <jiri@resnulli.us>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/act_api.h | 2 ++
 net/sched/act_api.c   | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index b944e0eb93be..5072446d5f06 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -122,7 +122,9 @@ void tcf_idrinfo_destroy(const struct tc_action_ops *ops,
 
 static inline void tc_action_net_exit(struct tc_action_net *tn)
 {
+	rtnl_lock();
 	tcf_idrinfo_destroy(tn->ops, tn->idrinfo);
+	rtnl_unlock();
 	kfree(tn->idrinfo);
 }
 
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index da6fa82c98a8..8f2c63514956 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -86,6 +86,8 @@ int __tcf_idr_release(struct tc_action *p, bool bind, bool strict)
 {
 	int ret = 0;
 
+	ASSERT_RTNL();
+
 	if (p) {
 		if (bind)
 			p->tcfa_bindcnt--;
-- 
2.13.0
