From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 1/2] cls_cgroup: factor out classid retrieval
Date: Wed, 15 Jul 2015 14:21:41 +0200
Message-ID: <2e73f303ae3f3d3e05d2f1f6d3651fb4407a9680.1436961536.git.daniel@iogearbox.net>
References: <cover.1436961536.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37686 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753511AbbGOMVq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 08:21:46 -0400
In-Reply-To: <cover.1436961536.git.daniel@iogearbox.net>
In-Reply-To: <cover.1436961536.git.daniel@iogearbox.net>
References: <cover.1436961536.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Split out retrieving the cgroups net_cls classid retrieval into its
own function, so that it can be reused later on from other parts of
the traffic control subsystem. If there's no skb->sk, then the small
helper returns 0 as well, which in cls_cgroup terms means 'could not
classify'.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Cc: Thomas Graf <tgraf@suug.ch>
---
 include/net/cls_cgroup.h | 29 +++++++++++++++++++++++++++++
 net/sched/cls_cgroup.c   | 23 ++---------------------
 2 files changed, 31 insertions(+), 21 deletions(-)

diff --git a/include/net/cls_cgroup.h b/include/net/cls_cgroup.h
index c15d394..e85a22d 100644
--- a/include/net/cls_cgroup.h
+++ b/include/net/cls_cgroup.h
@@ -49,9 +49,38 @@ static inline void sock_update_classid(struct sock *sk)
 	if (classid != sk->sk_classid)
 		sk->sk_classid = classid;
 }
+
+static inline u32 task_get_classid(const struct sk_buff *skb)
+{
+	u32 classid = task_cls_state(current)->classid;
+
+	/* Due to the nature of the classifier it is required to ignore all
+	 * packets originating from softirq context as accessing `current'
+	 * would lead to false results.
+	 *
+	 * This test assumes that all callers of dev_queue_xmit() explicitly
+	 * disable bh. Knowing this, it is possible to detect softirq based
+	 * calls by looking at the number of nested bh disable calls because
+	 * softirqs always disables bh.
+	 */
+	if (in_serving_softirq()) {
+		/* If there is an sk_classid we'll use that. */
+		if (!skb->sk)
+			return 0;
+
+		classid = skb->sk->sk_classid;
+	}
+
+	return classid;
+}
 #else /* !CONFIG_CGROUP_NET_CLASSID */
 static inline void sock_update_classid(struct sock *sk)
 {
 }
+
+static inline u32 task_get_classid(const struct sk_buff *skb)
+{
+	return 0;
+}
 #endif /* CONFIG_CGROUP_NET_CLASSID */
 #endif  /* _NET_CLS_CGROUP_H */
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index ea611b21..4c85bd3 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -30,35 +30,16 @@ static int cls_cgroup_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 			       struct tcf_result *res)
 {
 	struct cls_cgroup_head *head = rcu_dereference_bh(tp->root);
-	u32 classid;
-
-	classid = task_cls_state(current)->classid;
-
-	/*
-	 * Due to the nature of the classifier it is required to ignore all
-	 * packets originating from softirq context as accessing `current'
-	 * would lead to false results.
-	 *
-	 * This test assumes that all callers of dev_queue_xmit() explicitely
-	 * disable bh. Knowing this, it is possible to detect softirq based
-	 * calls by looking at the number of nested bh disable calls because
-	 * softirqs always disables bh.
-	 */
-	if (in_serving_softirq()) {
-		/* If there is an sk_classid we'll use that. */
-		if (!skb->sk)
-			return -1;
-		classid = skb->sk->sk_classid;
-	}
+	u32 classid = task_get_classid(skb);
 
 	if (!classid)
 		return -1;
-
 	if (!tcf_em_tree_match(skb, &head->ematches, NULL))
 		return -1;
 
 	res->classid = classid;
 	res->class = 0;
+
 	return tcf_exts_exec(skb, &head->exts, res);
 }
 
-- 
1.9.3
