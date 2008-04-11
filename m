From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH][NET_SCHED] cls_u32: refcounting fix for u32_delete()
Date: Fri, 11 Apr 2008 12:45:19 +0000
Message-ID: <20080411124519.GA2701@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <hadi@cyberus.ca>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:50689 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758112AbYDKMnP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 08:43:15 -0400
Received: by yw-out-2324.google.com with SMTP id 5so184030ywb.1
        for <netdev@vger.kernel.org>; Fri, 11 Apr 2008 05:42:54 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


[NET_SCHED] cls_u32: refcounting fix for u32_delete()

Deleting of nonroot hnodes mostly doesn't work in u32_delete():
refcnt == 1 is expected, but such hnodes' refcnts are initialized
with 0 and charged only with "link" nodes. Now they'll start with
1 like usual.


Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
Cc: Jamal Hadi Salim <hadi@cyberus.ca>

---

 net/sched/cls_u32.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index c5c16b4..4f150b9 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -411,8 +411,10 @@ static void u32_destroy(struct tcf_proto *tp)
 			}
 		}
 
-		for (ht=tp_c->hlist; ht; ht = ht->next)
+		for (ht = tp_c->hlist; ht; ht = ht->next) {
+			ht->refcnt--;
 			u32_clear_hnode(tp, ht);
+		}
 
 		while ((ht = tp_c->hlist) != NULL) {
 			tp_c->hlist = ht->next;
@@ -441,8 +443,10 @@ static int u32_delete(struct tcf_proto *tp, unsigned long arg)
 	if (tp->root == ht)
 		return -EINVAL;
 
-	if (--ht->refcnt == 0)
+	if (ht->refcnt == 1) {
+		ht->refcnt--;
 		u32_destroy_hnode(tp, ht);
+	}
 
 	return 0;
 }
@@ -568,7 +572,7 @@ static int u32_change(struct tcf_proto *tp, unsigned long base, u32 handle,
 		if (ht == NULL)
 			return -ENOBUFS;
 		ht->tp_c = tp_c;
-		ht->refcnt = 0;
+		ht->refcnt = 1;
 		ht->divisor = divisor;
 		ht->handle = handle;
 		ht->prio = tp->prio;
