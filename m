From: Paul Menage <menage@google.com>
Subject: [PATCH] cls_cgroup: read classid atomically in classifier
Date: Tue, 26 May 2009 12:59:11 -0700
Message-ID: <20090526195840.8464.36548.stgit@menage.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: lizf@cn.fujitsu.com, akpm@linux-foundation.org,
	davem@davemloft.net, tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:55552 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756686AbZEZUAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 16:00:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cls_cgroup: read classid atomically in classifier

Avoid reading the unsynchronized value cs->classid multiple times,
since it could change concurrently from non-zero to zero; this would
result in the classifier returning a positive result with a bogus
(zero) classid.

Signed-off-by: Paul Menage <menage@google.com>
Reviewed-by: Li Zefan <lizf@cn.fujitsu.com>

---

Fixes a whitespace issue from the previous version of the patch

 net/sched/cls_cgroup.c |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 1ab4542..0f815cc 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -98,8 +98,7 @@ static int cls_cgroup_classify(struct sk_buff *skb, struct tcf_proto *tp,
 			       struct tcf_result *res)
 {
 	struct cls_cgroup_head *head = tp->root;
-	struct cgroup_cls_state *cs;
-	int ret = 0;
+	u32 classid;
 
 	/*
 	 * Due to the nature of the classifier it is required to ignore all
@@ -115,17 +114,18 @@ static int cls_cgroup_classify(struct sk_buff *skb, struct tcf_proto *tp,
 		return -1;
 
 	rcu_read_lock();
-	cs = task_cls_state(current);
-	if (cs->classid && tcf_em_tree_match(skb, &head->ematches, NULL)) {
-		res->classid = cs->classid;
-		res->class = 0;
-		ret = tcf_exts_exec(skb, &head->exts, res);
-	} else
-		ret = -1;
-
+	classid = task_cls_state(current)->classid;
 	rcu_read_unlock();
 
-	return ret;
+	if (!classid)
+		return -1;
+
+	if (!tcf_em_tree_match(skb, &head->ematches, NULL))
+		return -1;
+
+	res->classid = classid;
+	res->class = 0;
+	return tcf_exts_exec(skb, &head->exts, res);
 }
 
 static unsigned long cls_cgroup_get(struct tcf_proto *tp, u32 handle)

