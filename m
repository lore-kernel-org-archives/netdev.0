From: David Miller <davem@davemloft.net>
Subject: [PATCH 9/18] pkt_sched: act_api: Move away from NLMSG_PUT().
Date: Tue, 26 Jun 2012 22:02:29 -0700 (PDT)
Message-ID: <20120626.220229.271920038298770697.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39211 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751772Ab2F0FC3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 01:02:29 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 545DC584191
	for <netdev@vger.kernel.org>; Tue, 26 Jun 2012 22:02:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Move away from NLMSG_NEW() as well.

And use nlmsg_data() while we're here too.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sched/act_api.c |   59 +++++++++++++++++++++++++++------------------------
 1 file changed, 31 insertions(+), 28 deletions(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 5cfb160..e3d2c78 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -652,27 +652,27 @@ tca_get_fill(struct sk_buff *skb, struct tc_action *a, u32 pid, u32 seq,
 	unsigned char *b = skb_tail_pointer(skb);
 	struct nlattr *nest;
 
-	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*t), flags);
-
-	t = NLMSG_DATA(nlh);
+	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*t), flags);
+	if (!nlh)
+		goto out_nlmsg_trim;
+	t = nlmsg_data(nlh);
 	t->tca_family = AF_UNSPEC;
 	t->tca__pad1 = 0;
 	t->tca__pad2 = 0;
 
 	nest = nla_nest_start(skb, TCA_ACT_TAB);
 	if (nest == NULL)
-		goto nla_put_failure;
+		goto out_nlmsg_trim;
 
 	if (tcf_action_dump(skb, a, bind, ref) < 0)
-		goto nla_put_failure;
+		goto out_nlmsg_trim;
 
 	nla_nest_end(skb, nest);
 
 	nlh->nlmsg_len = skb_tail_pointer(skb) - b;
 	return skb->len;
 
-nla_put_failure:
-nlmsg_failure:
+out_nlmsg_trim:
 	nlmsg_trim(skb, b);
 	return -1;
 }
@@ -799,19 +799,21 @@ static int tca_action_flush(struct net *net, struct nlattr *nla,
 	if (a->ops == NULL)
 		goto err_out;
 
-	nlh = NLMSG_PUT(skb, pid, n->nlmsg_seq, RTM_DELACTION, sizeof(*t));
-	t = NLMSG_DATA(nlh);
+	nlh = nlmsg_put(skb, pid, n->nlmsg_seq, RTM_DELACTION, sizeof(*t), 0);
+	if (!nlh)
+		goto out_module_put;
+	t = nlmsg_data(nlh);
 	t->tca_family = AF_UNSPEC;
 	t->tca__pad1 = 0;
 	t->tca__pad2 = 0;
 
 	nest = nla_nest_start(skb, TCA_ACT_TAB);
 	if (nest == NULL)
-		goto nla_put_failure;
+		goto out_module_put;
 
 	err = a->ops->walk(skb, &dcb, RTM_DELACTION, a);
 	if (err < 0)
-		goto nla_put_failure;
+		goto out_module_put;
 	if (err == 0)
 		goto noflush_out;
 
@@ -828,8 +830,7 @@ static int tca_action_flush(struct net *net, struct nlattr *nla,
 
 	return err;
 
-nla_put_failure:
-nlmsg_failure:
+out_module_put:
 	module_put(a->ops->owner);
 err_out:
 noflush_out:
@@ -919,18 +920,20 @@ static int tcf_add_notify(struct net *net, struct tc_action *a,
 
 	b = skb_tail_pointer(skb);
 
-	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*t), flags);
-	t = NLMSG_DATA(nlh);
+	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*t), flags);
+	if (!nlh)
+		goto out_kfree_skb;
+	t = nlmsg_data(nlh);
 	t->tca_family = AF_UNSPEC;
 	t->tca__pad1 = 0;
 	t->tca__pad2 = 0;
 
 	nest = nla_nest_start(skb, TCA_ACT_TAB);
 	if (nest == NULL)
-		goto nla_put_failure;
+		goto out_kfree_skb;
 
 	if (tcf_action_dump(skb, a, 0, 0) < 0)
-		goto nla_put_failure;
+		goto out_kfree_skb;
 
 	nla_nest_end(skb, nest);
 
@@ -942,8 +945,7 @@ static int tcf_add_notify(struct net *net, struct tc_action *a,
 		err = 0;
 	return err;
 
-nla_put_failure:
-nlmsg_failure:
+out_kfree_skb:
 	kfree_skb(skb);
 	return -1;
 }
@@ -1062,7 +1064,7 @@ tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
 	struct tc_action_ops *a_o;
 	struct tc_action a;
 	int ret = 0;
-	struct tcamsg *t = (struct tcamsg *) NLMSG_DATA(cb->nlh);
+	struct tcamsg *t = (struct tcamsg *) nlmsg_data(cb->nlh);
 	struct nlattr *kind = find_dump_kind(cb->nlh);
 
 	if (kind == NULL) {
@@ -1080,23 +1082,25 @@ tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
 	if (a_o->walk == NULL) {
 		WARN(1, "tc_dump_action: %s !capable of dumping table\n",
 		     a_o->kind);
-		goto nla_put_failure;
+		goto out_module_put;
 	}
 
-	nlh = NLMSG_PUT(skb, NETLINK_CB(cb->skb).pid, cb->nlh->nlmsg_seq,
-			cb->nlh->nlmsg_type, sizeof(*t));
-	t = NLMSG_DATA(nlh);
+	nlh = nlmsg_put(skb, NETLINK_CB(cb->skb).pid, cb->nlh->nlmsg_seq,
+			cb->nlh->nlmsg_type, sizeof(*t), 0);
+	if (!nlh)
+		goto out_module_put;
+	t = nlmsg_data(nlh);
 	t->tca_family = AF_UNSPEC;
 	t->tca__pad1 = 0;
 	t->tca__pad2 = 0;
 
 	nest = nla_nest_start(skb, TCA_ACT_TAB);
 	if (nest == NULL)
-		goto nla_put_failure;
+		goto out_module_put;
 
 	ret = a_o->walk(skb, cb, RTM_GETACTION, &a);
 	if (ret < 0)
-		goto nla_put_failure;
+		goto out_module_put;
 
 	if (ret > 0) {
 		nla_nest_end(skb, nest);
@@ -1110,8 +1114,7 @@ tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
 	module_put(a_o->owner);
 	return skb->len;
 
-nla_put_failure:
-nlmsg_failure:
+out_module_put:
 	module_put(a_o->owner);
 	nlmsg_trim(skb, b);
 	return skb->len;
-- 
1.7.10.2
