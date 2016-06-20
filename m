From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 2/2] act_ife: acquire ife_mod_lock before reading ifeoplist
Date: Mon, 20 Jun 2016 13:37:19 -0700
Message-ID: <1466455039-23268-3-git-send-email-xiyou.wangcong@gmail.com>
References: <1466455039-23268-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: khoroshilov@ispras.ru, Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:33218 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752662AbcFTVih (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 17:38:37 -0400
Received: by mail-pa0-f66.google.com with SMTP id ts6so11698126pac.0
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 14:38:37 -0700 (PDT)
In-Reply-To: <1466455039-23268-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/act_ife.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/net/sched/act_ife.c b/net/sched/act_ife.c
index e407659..ea4a2fe 100644
--- a/net/sched/act_ife.c
+++ b/net/sched/act_ife.c
@@ -277,7 +277,7 @@ static int load_metaops_and_vet(struct tcf_ife_info *ife, u32 metaid,
  * under ife->tcf_lock for existing action
 */
 static int add_metainfo(struct tcf_ife_info *ife, u32 metaid, void *metaval,
-			int len, bool exists)
+			int len, bool atomic)
 {
 	struct tcf_meta_info *mi = NULL;
 	struct tcf_meta_ops *ops = find_ife_oplist(metaid);
@@ -286,7 +286,7 @@ static int add_metainfo(struct tcf_ife_info *ife, u32 metaid, void *metaval,
 	if (!ops)
 		return -ENOENT;
 
-	mi = kzalloc(sizeof(*mi), exists ? GFP_ATOMIC : GFP_KERNEL);
+	mi = kzalloc(sizeof(*mi), atomic ? GFP_ATOMIC : GFP_KERNEL);
 	if (!mi) {
 		/*put back what find_ife_oplist took */
 		module_put(ops->owner);
@@ -296,7 +296,7 @@ static int add_metainfo(struct tcf_ife_info *ife, u32 metaid, void *metaval,
 	mi->metaid = metaid;
 	mi->ops = ops;
 	if (len > 0) {
-		ret = ops->alloc(mi, metaval, exists ? GFP_ATOMIC : GFP_KERNEL);
+		ret = ops->alloc(mi, metaval, atomic ? GFP_ATOMIC : GFP_KERNEL);
 		if (ret != 0) {
 			kfree(mi);
 			module_put(ops->owner);
@@ -309,17 +309,19 @@ static int add_metainfo(struct tcf_ife_info *ife, u32 metaid, void *metaval,
 	return ret;
 }
 
-static int use_all_metadata(struct tcf_ife_info *ife, bool exists)
+static int use_all_metadata(struct tcf_ife_info *ife)
 {
 	struct tcf_meta_ops *o;
 	int rc = 0;
 	int installed = 0;
 
+	read_lock(&ife_mod_lock);
 	list_for_each_entry(o, &ifeoplist, list) {
-		rc = add_metainfo(ife, o->metaid, NULL, 0, exists);
+		rc = add_metainfo(ife, o->metaid, NULL, 0, true);
 		if (rc == 0)
 			installed += 1;
 	}
+	read_unlock(&ife_mod_lock);
 
 	if (installed)
 		return 0;
@@ -523,7 +525,7 @@ static int tcf_ife_init(struct net *net, struct nlattr *nla,
 		 * as we can. You better have at least one else we are
 		 * going to bail out
 		 */
-		err = use_all_metadata(ife, exists);
+		err = use_all_metadata(ife);
 		if (err) {
 			if (ret == ACT_P_CREATED)
 				_tcf_ife_cleanup(a, bind);
-- 
2.1.0
