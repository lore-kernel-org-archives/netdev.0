From: Patrick McHardy <kaber@trash.net>
Subject: pkt_sched 02/02: remove unnecessary xchg() in packet classifiers
Date: Wed, 19 Nov 2008 19:03:09 +0100
Message-ID: <492454DD.2050603@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000000090802080805090801"
To: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36539 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753462AbYKSSDQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 13:03:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000000090802080805090801
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------000000090802080805090801
Content-Type: text/x-patch;
 name="02.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02.diff"

commit 40bed8277a202ff329488dd975bd9fd3655363f0
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Nov 19 18:58:18 2008 +0100

    pkt_sched: remove unnecessary xchg() in packet classifiers
    
    The use of xchg() hasn't been necessary since 2.2.something when proper
    locking was added to packet schedulers. In the case of classifiers they
    mostly weren't even necessary before that since they're mainly used
    to assign a NULL pointer to the filter root in the ->destroy path;
    the root is destroyed immediately after that.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 16e7ac9..173fcc4 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -531,7 +531,8 @@ void tcf_exts_change(struct tcf_proto *tp, struct tcf_exts *dst,
 	if (src->action) {
 		struct tc_action *act;
 		tcf_tree_lock(tp);
-		act = xchg(&dst->action, src->action);
+		act = dst->action;
+		dst->action = src->action;
 		tcf_tree_unlock(tp);
 		if (act)
 			tcf_action_destroy(act, TCA_ACT_UNBIND);
diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index 956915c..4e2bda8 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -102,7 +102,7 @@ static inline void basic_delete_filter(struct tcf_proto *tp,
 
 static void basic_destroy(struct tcf_proto *tp)
 {
-	struct basic_head *head = (struct basic_head *) xchg(&tp->root, NULL);
+	struct basic_head *head = tp->root;
 	struct basic_filter *f, *n;
 
 	list_for_each_entry_safe(f, n, &head->flist, link) {
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 53ada2c..0d68b19 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -201,9 +201,7 @@ static int cls_cgroup_change(struct tcf_proto *tp, unsigned long base,
 
 static void cls_cgroup_destroy(struct tcf_proto *tp)
 {
-	struct cls_cgroup_head *head;
-
-	head = (struct cls_cgroup_head *)xchg(&tp->root, NULL);
+	struct cls_cgroup_head *head = tp->root;
 
 	if (head) {
 		tcf_exts_destroy(tp, &head->exts);
diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index b0f90e5..6d6e875 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -148,7 +148,7 @@ fw_delete_filter(struct tcf_proto *tp, struct fw_filter *f)
 
 static void fw_destroy(struct tcf_proto *tp)
 {
-	struct fw_head *head = (struct fw_head*)xchg(&tp->root, NULL);
+	struct fw_head *head = tp->root;
 	struct fw_filter *f;
 	int h;
 
diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index e3d8455..bdf1f41 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -260,7 +260,7 @@ route4_delete_filter(struct tcf_proto *tp, struct route4_filter *f)
 
 static void route4_destroy(struct tcf_proto *tp)
 {
-	struct route4_head *head = xchg(&tp->root, NULL);
+	struct route4_head *head = tp->root;
 	int h1, h2;
 
 	if (head == NULL)
diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index 7a7bff5..e806f23 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -13,12 +13,6 @@
 #include <net/netlink.h>
 #include <net/pkt_cls.h>
 
-
-/*
- * Not quite sure if we need all the xchgs Alexey uses when accessing things.
- * Can always add them later ... :)
- */
-
 /*
  * Passing parameters to the root seems to be done more awkwardly than really
  * necessary. At least, u32 doesn't seem to use such dirty hacks. To be
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 246f906..05d1780 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -387,7 +387,7 @@ static int u32_destroy_hnode(struct tcf_proto *tp, struct tc_u_hnode *ht)
 static void u32_destroy(struct tcf_proto *tp)
 {
 	struct tc_u_common *tp_c = tp->data;
-	struct tc_u_hnode *root_ht = xchg(&tp->root, NULL);
+	struct tc_u_hnode *root_ht = tp->root;
 
 	WARN_ON(root_ht == NULL);
 
@@ -479,7 +479,7 @@ static int u32_set_parms(struct tcf_proto *tp, unsigned long base,
 	err = -EINVAL;
 	if (tb[TCA_U32_LINK]) {
 		u32 handle = nla_get_u32(tb[TCA_U32_LINK]);
-		struct tc_u_hnode *ht_down = NULL;
+		struct tc_u_hnode *ht_down = NULL, *ht_old;
 
 		if (TC_U32_KEY(handle))
 			goto errout;
@@ -493,11 +493,12 @@ static int u32_set_parms(struct tcf_proto *tp, unsigned long base,
 		}
 
 		tcf_tree_lock(tp);
-		ht_down = xchg(&n->ht_down, ht_down);
+		ht_old = n->ht_down;
+		n->ht_down = ht_down;
 		tcf_tree_unlock(tp);
 
-		if (ht_down)
-			ht_down->refcnt--;
+		if (ht_old)
+			ht_old->refcnt--;
 	}
 	if (tb[TCA_U32_CLASSID]) {
 		n->res.classid = nla_get_u32(tb[TCA_U32_CLASSID]);

--------------000000090802080805090801--
