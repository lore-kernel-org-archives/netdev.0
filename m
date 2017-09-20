From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] net_sched: remove cls_flower idr on failure
Date: Wed, 20 Sep 2017 09:18:45 -0700
Message-ID: <20170920161845.28753-1-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Chris Mi <chrism@mellanox.com>, Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33073 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751697AbdITQS4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 12:18:56 -0400
Received: by mail-pg0-f65.google.com with SMTP id i130so1905758pgc.0
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 09:18:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: c15ab236d69d ("net/sched: Change cls_flower to use IDR")
Cc: Chris Mi <chrism@mellanox.com>
Cc: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/cls_flower.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 1a267e77c6de..d230cb4c8094 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -922,28 +922,28 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
 
 		if (!tc_flags_valid(fnew->flags)) {
 			err = -EINVAL;
-			goto errout;
+			goto errout_idr;
 		}
 	}
 
 	err = fl_set_parms(net, tp, fnew, &mask, base, tb, tca[TCA_RATE], ovr);
 	if (err)
-		goto errout;
+		goto errout_idr;
 
 	err = fl_check_assign_mask(head, &mask);
 	if (err)
-		goto errout;
+		goto errout_idr;
 
 	if (!tc_skip_sw(fnew->flags)) {
 		if (!fold && fl_lookup(head, &fnew->mkey)) {
 			err = -EEXIST;
-			goto errout;
+			goto errout_idr;
 		}
 
 		err = rhashtable_insert_fast(&head->ht, &fnew->ht_node,
 					     head->ht_params);
 		if (err)
-			goto errout;
+			goto errout_idr;
 	}
 
 	if (!tc_skip_hw(fnew->flags)) {
@@ -952,7 +952,7 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
 					   &mask.key,
 					   fnew);
 		if (err)
-			goto errout;
+			goto errout_idr;
 	}
 
 	if (!tc_in_hw(fnew->flags))
@@ -981,6 +981,9 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
 	kfree(tb);
 	return 0;
 
+errout_idr:
+	if (fnew->handle)
+		idr_remove_ext(&head->handle_idr, fnew->handle);
 errout:
 	tcf_exts_destroy(&fnew->exts);
 	kfree(fnew);
-- 
2.13.0
