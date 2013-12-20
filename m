From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net_sched: fix a regression in
 tcf_proto_lookup_ops()
Date: Fri, 20 Dec 2013 10:04:18 -0800
Message-ID: <1387562658.19078.448.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1387526931-21814-1-git-send-email-xiyou.wangcong@gmail.com>
	 <52B434FA.8080309@mojatatu.com>
	 <1387550222.19078.434.camel@edumazet-glaptop2.roam.corp.google.com>
	 <52B45851.90208@mojatatu.com>
	 <1387555659.19078.439.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1387560028.19078.442.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1387560578.19078.443.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f42.google.com ([209.85.128.42]:61606 "EHLO
	mail-qe0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750963Ab3LTSEW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 13:04:22 -0500
Received: by mail-qe0-f42.google.com with SMTP id b4so2702985qen.29
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 10:04:21 -0800 (PST)
In-Reply-To: <1387560578.19078.443.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

list_for_each_entry(t, &tcf_proto_base, head) doesn't
exit with t = NULL if we reached the end of the list.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Fixes: 3627287463b4 ("net_sched: convert tcf_proto_ops to use struct 
list_head")
Cc: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/cls_api.c |   22 ++++++++++------------
 1 file changed, 10 insertions(+), 12 deletions(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 6b085cf27a65..12e882ef596b 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -40,20 +40,20 @@ static DEFINE_RWLOCK(cls_mod_lock);
 
 static const struct tcf_proto_ops *tcf_proto_lookup_ops(struct nlattr *kind)
 {
-	const struct tcf_proto_ops *t = NULL;
+	const struct tcf_proto_ops *t, *res = NULL;
 
 	if (kind) {
 		read_lock(&cls_mod_lock);
 		list_for_each_entry(t, &tcf_proto_base, head) {
 			if (nla_strcmp(kind, t->kind) == 0) {
-				if (!try_module_get(t->owner))
-					t = NULL;
+				if (try_module_get(t->owner))
+					res = t;
 				break;
 			}
 		}
 		read_unlock(&cls_mod_lock);
 	}
-	return t;
+	return res;
 }
 
 /* Register(unregister) new classifier type */
@@ -82,15 +82,13 @@ int unregister_tcf_proto_ops(struct tcf_proto_ops *ops)
 	int rc = -ENOENT;
 
 	write_lock(&cls_mod_lock);
-	list_for_each_entry(t, &tcf_proto_base, head)
-		if (t == ops)
+	list_for_each_entry(t, &tcf_proto_base, head) {
+		if (t == ops) {
+			list_del(&t->head);
+			rc = 0;
 			break;
-
-	if (!t)
-		goto out;
-	list_del(&t->head);
-	rc = 0;
-out:
+		}
+	}
 	write_unlock(&cls_mod_lock);
 	return rc;
 }
