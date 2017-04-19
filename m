From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next v4 2/2] net_sched: remove useless NULL to tp->root
Date: Wed, 19 Apr 2017 14:21:22 -0700
Message-ID: <1492636882-19571-3-git-send-email-xiyou.wangcong@gmail.com>
References: <1492636882-19571-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        John Fastabend <john.fastabend@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:35526 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966940AbdDSVVj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 17:21:39 -0400
Received: by mail-io0-f193.google.com with SMTP id d203so7670825iof.2
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 14:21:38 -0700 (PDT)
In-Reply-To: <1492636882-19571-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need to NULL tp->root in ->destroy(), since tp is
going to be freed very soon, and existing readers are still
safe to read them.

For cls_route, we always init its tp->root, so it can't be NULL,
we can drop more useless code.

Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: John Fastabend <john.fastabend@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/cls_fw.c    |  1 -
 net/sched/cls_route.c | 15 ---------------
 net/sched/cls_rsvp.h  |  4 ----
 3 files changed, 20 deletions(-)

diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index 78ccb4a..d388536 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -144,7 +144,6 @@ static void fw_destroy(struct tcf_proto *tp)
 			call_rcu(&f->rcu, fw_delete_filter);
 		}
 	}
-	RCU_INIT_POINTER(tp->root, NULL);
 	kfree_rcu(head, rcu);
 }
 
diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index f4d687e..d63d550 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -140,8 +140,6 @@ static int route4_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 		goto failure;
 
 	id = dst->tclassid;
-	if (head == NULL)
-		goto old_method;
 
 	iif = inet_iif(skb);
 
@@ -194,15 +192,6 @@ static int route4_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 		route4_set_fastmap(head, id, iif, ROUTE4_FAILURE);
 failure:
 	return -1;
-
-old_method:
-	if (id && (TC_H_MAJ(id) == 0 ||
-		   !(TC_H_MAJ(id^tp->q->handle)))) {
-		res->classid = id;
-		res->class = 0;
-		return 0;
-	}
-	return -1;
 }
 
 static inline u32 to_hash(u32 id)
@@ -234,9 +223,6 @@ static unsigned long route4_get(struct tcf_proto *tp, u32 handle)
 	struct route4_filter *f;
 	unsigned int h1, h2;
 
-	if (!head)
-		return 0;
-
 	h1 = to_hash(handle);
 	if (h1 > 256)
 		return 0;
@@ -305,7 +291,6 @@ static void route4_destroy(struct tcf_proto *tp)
 			kfree_rcu(b, rcu);
 		}
 	}
-	RCU_INIT_POINTER(tp->root, NULL);
 	kfree_rcu(head, rcu);
 }
 
diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
index 18a9470..0d9d077 100644
--- a/net/sched/cls_rsvp.h
+++ b/net/sched/cls_rsvp.h
@@ -152,8 +152,6 @@ static int rsvp_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 		return -1;
 	nhptr = ip_hdr(skb);
 #endif
-	if (unlikely(!head))
-		return -1;
 restart:
 
 #if RSVP_DST_LEN == 4
@@ -310,8 +308,6 @@ static void rsvp_destroy(struct tcf_proto *tp)
 	if (data == NULL)
 		return;
 
-	RCU_INIT_POINTER(tp->root, NULL);
-
 	for (h1 = 0; h1 < 256; h1++) {
 		struct rsvp_session *s;
 
-- 
2.5.5
