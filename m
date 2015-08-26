From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v2 net-next 3/5] net_sched: convert tcindex to call tcf_exts_destroy from rcu callback
Date: Tue, 25 Aug 2015 20:06:33 -0700
Message-ID: <1440558395-7765-4-git-send-email-ast@plumgrid.com>
References: <1440558395-7765-1-git-send-email-ast@plumgrid.com>
Cc: Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35414 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751816AbbHZDGp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 23:06:45 -0400
Received: by pacdd16 with SMTP id dd16so144535806pac.2
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 20:06:45 -0700 (PDT)
In-Reply-To: <1440558395-7765-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adjust destroy path of cls_tcindex to call tcf_exts_destroy() after
rcu grace period.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 net/sched/cls_tcindex.c |   29 +++++++++++++++++++++++++----
 1 file changed, 25 insertions(+), 4 deletions(-)

diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index a557dbaf5afe..944c8ff45055 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -27,6 +27,7 @@
 struct tcindex_filter_result {
 	struct tcf_exts		exts;
 	struct tcf_result	res;
+	struct rcu_head		rcu;
 };
 
 struct tcindex_filter {
@@ -133,8 +134,23 @@ static int tcindex_init(struct tcf_proto *tp)
 	return 0;
 }
 
-static int
-tcindex_delete(struct tcf_proto *tp, unsigned long arg)
+static void tcindex_destroy_rexts(struct rcu_head *head)
+{
+	struct tcindex_filter_result *r;
+
+	r = container_of(head, struct tcindex_filter_result, rcu);
+	tcf_exts_destroy(&r->exts);
+}
+
+static void tcindex_destroy_fexts(struct rcu_head *head)
+{
+	struct tcindex_filter *f = container_of(head, struct tcindex_filter, rcu);
+
+	tcf_exts_destroy(&f->result.exts);
+	kfree(f);
+}
+
+static int tcindex_delete(struct tcf_proto *tp, unsigned long arg)
 {
 	struct tcindex_data *p = rtnl_dereference(tp->root);
 	struct tcindex_filter_result *r = (struct tcindex_filter_result *) arg;
@@ -162,9 +178,14 @@ found:
 		rcu_assign_pointer(*walk, rtnl_dereference(f->next));
 	}
 	tcf_unbind_filter(tp, &r->res);
-	tcf_exts_destroy(&r->exts);
+	/* all classifiers are required to call tcf_exts_destroy() after rcu
+	 * grace period, since converted-to-rcu actions are relying on that
+	 * in cleanup() callback
+	 */
 	if (f)
-		kfree_rcu(f, rcu);
+		call_rcu(&f->rcu, tcindex_destroy_fexts);
+	else
+		call_rcu(&r->rcu, tcindex_destroy_rexts);
 	return 0;
 }
 
-- 
1.7.9.5
