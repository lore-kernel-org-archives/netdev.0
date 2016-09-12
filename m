From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: [PATCH net-next] net/sched: act_tunnel_key: Remove rcu_read_lock protection
Date: Mon, 12 Sep 2016 15:19:21 +0300
Message-ID: <1473682762-8150-1-git-send-email-hadarh@mellanox.com>
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
        Jiri Benc <jbenc@redhat.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Eric Dumazet <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Amir Vadai <amirva@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:48004 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754615AbcILMUC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 08:20:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove rcu_read_lock protection from tunnel_key_dump and use
rtnl_dereference, dump operation is protected by  rtnl lock.

Also, remove rcu_read_lock from tunnel_key_release and use
rcu_dereference_protected.

Both operations are running exclusively and a writer couldn't modify
t->params while those functions are executed.

Fixes: 54d94fd89d90 ('net/sched: Introduce act_tunnel_key')
Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
---
 net/sched/act_tunnel_key.c | 17 ++++-------------
 1 file changed, 4 insertions(+), 13 deletions(-)

diff --git a/net/sched/act_tunnel_key.c b/net/sched/act_tunnel_key.c
index dceff74..af47bdf 100644
--- a/net/sched/act_tunnel_key.c
+++ b/net/sched/act_tunnel_key.c
@@ -194,15 +194,12 @@ static void tunnel_key_release(struct tc_action *a, int bind)
 	struct tcf_tunnel_key *t = to_tunnel_key(a);
 	struct tcf_tunnel_key_params *params;
 
-	rcu_read_lock();
-	params = rcu_dereference(t->params);
+	params = rcu_dereference_protected(t->params, 1);
 
 	if (params->tcft_action == TCA_TUNNEL_KEY_ACT_SET)
 		dst_release(&params->tcft_enc_metadata->dst);
 
 	kfree_rcu(params, rcu);
-
-	rcu_read_unlock();
 }
 
 static int tunnel_key_dump_addresses(struct sk_buff *skb,
@@ -245,10 +242,8 @@ static int tunnel_key_dump(struct sk_buff *skb, struct tc_action *a,
 		.bindcnt  = t->tcf_bindcnt - bind,
 	};
 	struct tcf_t tm;
-	int ret = -1;
 
-	rcu_read_lock();
-	params = rcu_dereference(t->params);
+	params = rtnl_dereference(t->params);
 
 	opt.t_action = params->tcft_action;
 	opt.action = params->action;
@@ -272,15 +267,11 @@ static int tunnel_key_dump(struct sk_buff *skb, struct tc_action *a,
 			  &tm, TCA_TUNNEL_KEY_PAD))
 		goto nla_put_failure;
 
-	ret = skb->len;
-	goto out;
+	return skb->len;
 
 nla_put_failure:
 	nlmsg_trim(skb, b);
-out:
-	rcu_read_unlock();
-
-	return ret;
+	return -1;
 }
 
 static int tunnel_key_walker(struct net *net, struct sk_buff *skb,
-- 
1.8.3.1
