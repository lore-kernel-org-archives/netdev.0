From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 2/5] net_sched: fix memory leak in cls_tcindex
Date: Mon, 15 Sep 2014 14:06:47 -0700
Message-ID: <1410815210-6693-3-git-send-email-xiyou.wangcong@gmail.com>
References: <1410815210-6693-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: john.fastabend@gmail.com, "David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:33579 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758975AbaIOVHG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 17:07:06 -0400
Received: by mail-pd0-f175.google.com with SMTP id z10so7108215pdj.6
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 14:07:05 -0700 (PDT)
In-Reply-To: <1410815210-6693-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: commit 331b72922c5f58d48fd ("net: sched: RCU cls_tcindex")
Cc: John Fastabend <john.fastabend@gmail.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/cls_tcindex.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index a02ca72..16ec1ed 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -243,7 +243,7 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 	 */
 	cp = kzalloc(sizeof(*cp), GFP_KERNEL);
 	if (!cp)
-		return -ENOMEM;
+		goto errout;
 
 	cp->mask = p->mask;
 	cp->shift = p->shift;
@@ -257,6 +257,7 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 				      sizeof(*r) * cp->hash, GFP_KERNEL);
 		if (!cp->perfect)
 			goto errout;
+		balloc = 1;
 	}
 	cp->h = p->h;
 
@@ -285,9 +286,9 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 	if (cp->perfect) {
 		if (!valid_perfect_hash(cp) ||
 		    cp->hash > cp->alloc_hash)
-			goto errout;
+			goto errout_alloc;
 	} else if (cp->h && cp->hash != cp->alloc_hash) {
-		goto errout;
+		goto errout_alloc;
 	}
 
 	err = -EINVAL;
@@ -314,7 +315,7 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 	 */
 	if (cp->perfect || valid_perfect_hash(cp))
 		if (handle >= cp->alloc_hash)
-			goto errout;
+			goto errout_alloc;
 
 
 	err = -ENOMEM;
@@ -324,7 +325,7 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 
 			cp->perfect = kcalloc(cp->hash, sizeof(*r), GFP_KERNEL);
 			if (!cp->perfect)
-				goto errout;
+				goto errout_alloc;
 			for (i = 0; i < cp->hash; i++)
 				tcf_exts_init(&cp->perfect[i].exts,
 					      TCA_TCINDEX_ACT,
@@ -338,7 +339,7 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 				       GFP_KERNEL);
 
 			if (!hash)
-				goto errout;
+				goto errout_alloc;
 
 			cp->h = hash;
 			balloc = 2;
-- 
1.8.3.1
