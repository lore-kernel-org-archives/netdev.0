From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] net: sched: fix use-after-free in tcf_action_destroy and tcf_del_walker
Date: Wed, 13 Sep 2017 17:32:37 +0200
Message-ID: <20170913153237.26408-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        kubakici@wp.pl, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:35253 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751010AbdIMPck (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2017 11:32:40 -0400
Received: by mail-wr0-f194.google.com with SMTP id n64so293724wrb.2
        for <netdev@vger.kernel.org>; Wed, 13 Sep 2017 08:32:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Recent commit d7fb60b9cafb ("net_sched: get rid of tcfa_rcu") removed
freeing in call_rcu, which changed already existing hard-to-hit
race condition into 100% hit:

[  598.599825] BUG: unable to handle kernel NULL pointer dereference at 0000000000000030
[  598.607782] IP: tcf_action_destroy+0xc0/0x140

Or:

[   40.858924] BUG: unable to handle kernel NULL pointer dereference at 0000000000000030
[   40.862840] IP: tcf_generic_walker+0x534/0x820

Fix this by storing the ops and use them directly for module_put call.

Fixes: a85a970af265 ("net_sched: move tc_action into tcf_common")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/act_api.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index fcd7dc7..da6fa82 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -180,7 +180,7 @@ static int tcf_del_walker(struct tcf_idrinfo *idrinfo, struct sk_buff *skb,
 	idr_for_each_entry_ext(idr, p, id) {
 		ret = __tcf_idr_release(p, false, true);
 		if (ret == ACT_P_DELETED) {
-			module_put(p->ops->owner);
+			module_put(ops->owner);
 			n_i++;
 		} else if (ret < 0) {
 			goto nla_put_failure;
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
-- 
2.9.3
