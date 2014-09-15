From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next v2] net_sched: fix memory leak in cls_tcindex
Date: Mon, 15 Sep 2014 16:43:42 -0700
Message-ID: <1410824623-27516-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: john.fastabend@gmail.com, "David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:49858 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755667AbaIOXnv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 19:43:51 -0400
Received: by mail-pd0-f170.google.com with SMTP id fp1so7358469pdb.1
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 16:43:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: commit 331b72922c5f58d48fd ("net: sched: RCU cls_tcindex")
Cc: John Fastabend <john.fastabend@gmail.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---

v2: fix err = -ENOMEM

 net/sched/cls_tcindex.c | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index dd2d691..ee52542 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -242,8 +242,10 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 	 * perfect hash and hash pointers from old data.
 	 */
 	cp = kzalloc(sizeof(*cp), GFP_KERNEL);
-	if (!cp)
-		return -ENOMEM;
+	if (!cp) {
+		err = -ENOMEM;
+		goto errout;
+	}
 
 	cp->mask = p->mask;
 	cp->shift = p->shift;
@@ -257,6 +259,7 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 				      sizeof(*r) * cp->hash, GFP_KERNEL);
 		if (!cp->perfect)
 			goto errout;
+		balloc = 1;
 	}
 	cp->h = p->h;
 
@@ -282,9 +285,9 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
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
@@ -311,7 +314,7 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 	 */
 	if (cp->perfect || valid_perfect_hash(cp))
 		if (handle >= cp->alloc_hash)
-			goto errout;
+			goto errout_alloc;
 
 
 	err = -ENOMEM;
@@ -321,7 +324,7 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 
 			cp->perfect = kcalloc(cp->hash, sizeof(*r), GFP_KERNEL);
 			if (!cp->perfect)
-				goto errout;
+				goto errout_alloc;
 			for (i = 0; i < cp->hash; i++)
 				tcf_exts_init(&cp->perfect[i].exts,
 					      TCA_TCINDEX_ACT,
@@ -335,7 +338,7 @@ tcindex_set_parms(struct net *net, struct tcf_proto *tp, unsigned long base,
 				       GFP_KERNEL);
 
 			if (!hash)
-				goto errout;
+				goto errout_alloc;
 
 			cp->h = hash;
 			balloc = 2;
-- 
1.8.3.1
