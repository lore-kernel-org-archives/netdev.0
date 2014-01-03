From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] cls_cgroup: fix memory leak in cls_cgroup_change()
Date: Fri,  3 Jan 2014 11:13:19 -0800
Message-ID: <1388776399-27657-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>, Thomas Graf <tgraf@suug.ch>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:48121 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752436AbaACTNd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 14:13:33 -0500
Received: by mail-pd0-f180.google.com with SMTP id q10so15633376pdj.25
        for <netdev@vger.kernel.org>; Fri, 03 Jan 2014 11:13:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix it by moving allocation to ->init().

Cc: Thomas Graf <tgraf@suug.ch>
Cc: David S. Miller <davem@davemloft.net>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/cls_cgroup.c | 19 ++++++-------------
 1 file changed, 6 insertions(+), 13 deletions(-)

diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 16006c9..f0d1e81 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -169,6 +169,11 @@ static void cls_cgroup_put(struct tcf_proto *tp, unsigned long f)
 
 static int cls_cgroup_init(struct tcf_proto *tp)
 {
+	struct cls_cgroup_head *head;
+	head = kzalloc(sizeof(*head), GFP_KERNEL);
+	if (head == NULL)
+		return -ENOBUFS;
+	tp->root = head;
 	return 0;
 }
 
@@ -195,21 +200,9 @@ static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
 	if (!tca[TCA_OPTIONS])
 		return -EINVAL;
 
-	if (head == NULL) {
-		if (!handle)
-			return -EINVAL;
-
-		head = kzalloc(sizeof(*head), GFP_KERNEL);
-		if (head == NULL)
-			return -ENOBUFS;
-
+	if (head->handle == 0)
 		head->handle = handle;
 
-		tcf_tree_lock(tp);
-		tp->root = head;
-		tcf_tree_unlock(tp);
-	}
-
 	if (handle != head->handle)
 		return -ENOENT;
 
-- 
1.8.3.1
