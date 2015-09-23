From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] net: revert "net_sched: move tp->root allocation into fw_init()"
Date: Tue, 22 Sep 2015 17:01:11 -0700
Message-ID: <1442966471-22656-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Akshat Kakkar <akshat.1984@gmail.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36558 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934153AbbIWABU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 20:01:20 -0400
Received: by pacbt3 with SMTP id bt3so4709770pac.3
        for <netdev@vger.kernel.org>; Tue, 22 Sep 2015 17:01:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fw filter uses tp->root==NULL to check if it is the old method,
so it doesn't need allocation at all in this case. This patch
reverts the offending commit and adds some comments for old
method to make it obvious.

Fixes: 33f8b9ecdb15 ("net_sched: move tp->root allocation into fw_init()")
Reported-by: Akshat Kakkar <akshat.1984@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/cls_fw.c | 30 +++++++++++++++---------------
 1 file changed, 15 insertions(+), 15 deletions(-)

diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index 715e01e..f23a3b6 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -33,7 +33,6 @@
 
 struct fw_head {
 	u32			mask;
-	bool			mask_set;
 	struct fw_filter __rcu	*ht[HTSIZE];
 	struct rcu_head		rcu;
 };
@@ -84,7 +83,7 @@ static int fw_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 			}
 		}
 	} else {
-		/* old method */
+		/* Old method: classify the packet using its skb mark. */
 		if (id && (TC_H_MAJ(id) == 0 ||
 			   !(TC_H_MAJ(id ^ tp->q->handle)))) {
 			res->classid = id;
@@ -114,14 +113,9 @@ static unsigned long fw_get(struct tcf_proto *tp, u32 handle)
 
 static int fw_init(struct tcf_proto *tp)
 {
-	struct fw_head *head;
-
-	head = kzalloc(sizeof(struct fw_head), GFP_KERNEL);
-	if (head == NULL)
-		return -ENOBUFS;
-
-	head->mask_set = false;
-	rcu_assign_pointer(tp->root, head);
+	/* We don't allocate fw_head here, because in the old method
+	 * we don't need it at all.
+	 */
 	return 0;
 }
 
@@ -252,7 +246,7 @@ static int fw_change(struct net *net, struct sk_buff *in_skb,
 	int err;
 
 	if (!opt)
-		return handle ? -EINVAL : 0;
+		return handle ? -EINVAL : 0; /* Succeed if it is old method. */
 
 	err = nla_parse_nested(tb, TCA_FW_MAX, opt, fw_policy);
 	if (err < 0)
@@ -302,11 +296,17 @@ static int fw_change(struct net *net, struct sk_buff *in_skb,
 	if (!handle)
 		return -EINVAL;
 
-	if (!head->mask_set) {
-		head->mask = 0xFFFFFFFF;
+	if (!head) {
+		u32 mask = 0xFFFFFFFF;
 		if (tb[TCA_FW_MASK])
-			head->mask = nla_get_u32(tb[TCA_FW_MASK]);
-		head->mask_set = true;
+			mask = nla_get_u32(tb[TCA_FW_MASK]);
+
+		head = kzalloc(sizeof(*head), GFP_KERNEL);
+		if (!head)
+			return -ENOBUFS;
+		head->mask = mask;
+
+		rcu_assign_pointer(tp->root, head);
 	}
 
 	f = kzalloc(sizeof(struct fw_filter), GFP_KERNEL);
-- 
1.8.3.1
