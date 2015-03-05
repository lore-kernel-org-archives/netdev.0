From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] net_sched: move tp->root allocation into fw_init()
Date: Wed,  4 Mar 2015 20:11:44 -0800
Message-ID: <1425528704-21646-2-git-send-email-xiyou.wangcong@gmail.com>
References: <1425528704-21646-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:34573 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751173AbbCEEME (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 23:12:04 -0500
Received: by pdjg10 with SMTP id g10so63081341pdj.1
        for <netdev@vger.kernel.org>; Wed, 04 Mar 2015 20:12:04 -0800 (PST)
In-Reply-To: <1425528704-21646-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/cls_fw.c | 23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index a5269f7..9d9aa3e 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -33,6 +33,7 @@
 
 struct fw_head {
 	u32			mask;
+	bool			mask_set;
 	struct fw_filter __rcu	*ht[HTSIZE];
 	struct rcu_head		rcu;
 };
@@ -113,6 +114,14 @@ static unsigned long fw_get(struct tcf_proto *tp, u32 handle)
 
 static int fw_init(struct tcf_proto *tp)
 {
+	struct fw_head *head;
+
+	head = kzalloc(sizeof(struct fw_head), GFP_KERNEL);
+	if (head == NULL)
+		return -ENOBUFS;
+
+	head->mask_set = false;
+	rcu_assign_pointer(tp->root, head);
 	return 0;
 }
 
@@ -286,17 +295,11 @@ static int fw_change(struct net *net, struct sk_buff *in_skb,
 	if (!handle)
 		return -EINVAL;
 
-	if (head == NULL) {
-		u32 mask = 0xFFFFFFFF;
+	if (!head->mask_set) {
+		head->mask = 0xFFFFFFFF;
 		if (tb[TCA_FW_MASK])
-			mask = nla_get_u32(tb[TCA_FW_MASK]);
-
-		head = kzalloc(sizeof(struct fw_head), GFP_KERNEL);
-		if (head == NULL)
-			return -ENOBUFS;
-		head->mask = mask;
-
-		rcu_assign_pointer(tp->root, head);
+			head->mask = nla_get_u32(tb[TCA_FW_MASK]);
+		head->mask_set = true;
 	}
 
 	f = kzalloc(sizeof(struct fw_filter), GFP_KERNEL);
-- 
1.8.1.4
