From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] net: sched: fix memleak for chain zero
Date: Wed,  6 Sep 2017 13:14:19 +0200
Message-ID: <20170906111419.5115-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        kubakici@wp.pl, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33884 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752485AbdIFLOW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 07:14:22 -0400
Received: by mail-wm0-f65.google.com with SMTP id l19so2084632wmi.1
        for <netdev@vger.kernel.org>; Wed, 06 Sep 2017 04:14:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

There's a memleak happening for chain 0. The thing is, chain 0 needs to
be always present, not created on demand. Therefore tcf_block_get upon
creation of block calls the tcf_chain_create function directly. The
chain is created with refcnt == 1, which is not correct in this case and
causes the memleak. So move the refcnt increment into tcf_chain_get
function even for the case when chain needs to be created.

Reported-by: Jakub Kicinski <kubakici@wp.pl>
Fixes: 5bc1701881e3 ("net: sched: introduce multichain support for filters")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_api.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 6c5ea84..30ef466 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -197,7 +197,7 @@ static struct tcf_chain *tcf_chain_create(struct tcf_block *block,
 	list_add_tail(&chain->list, &block->chain_list);
 	chain->block = block;
 	chain->index = chain_index;
-	chain->refcnt = 1;
+	chain->refcnt = 0;
 	return chain;
 }
 
@@ -232,15 +232,15 @@ struct tcf_chain *tcf_chain_get(struct tcf_block *block, u32 chain_index,
 	struct tcf_chain *chain;
 
 	list_for_each_entry(chain, &block->chain_list, list) {
-		if (chain->index == chain_index) {
-			chain->refcnt++;
-			return chain;
-		}
+		if (chain->index == chain_index)
+			goto incref;
 	}
-	if (create)
-		return tcf_chain_create(block, chain_index);
-	else
-		return NULL;
+	chain = create ? tcf_chain_create(block, chain_index) : NULL;
+
+incref:
+	if (chain)
+		chain->refcnt++;
+	return chain;
 }
 EXPORT_SYMBOL(tcf_chain_get);
 
-- 
2.9.3
