From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 07/34] net: sched: cls_u32: use block instead of q in tc_u_common
Date: Thu, 12 Oct 2017 19:17:56 +0200
Message-ID: <20171012171823.1431-8-jiri@resnulli.us>
References: <20171012171823.1431-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        jeffrey.t.kirsher@intel.com, saeedm@mellanox.com,
        matanb@mellanox.com, leonro@mellanox.com, idosch@mellanox.com,
        jakub.kicinski@netronome.com, ast@kernel.org, daniel@iogearbox.net,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        john.hurley@netronome.com, edumazet@google.com, dsahern@gmail.com,
        alexander.h.duyck@intel.com, john.fastabend@gmail.com,
        willemb@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:43848 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753254AbdJLRSc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 13:18:32 -0400
Received: by mail-wm0-f66.google.com with SMTP id m72so24897084wmc.0
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 10:18:31 -0700 (PDT)
In-Reply-To: <20171012171823.1431-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

tc_u_common is now per-q. With blocks, it has to be converted to be
per-block.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_u32.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 094d224..b6d4606 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -93,7 +93,7 @@ struct tc_u_hnode {
 
 struct tc_u_common {
 	struct tc_u_hnode __rcu	*hlist;
-	struct Qdisc		*q;
+	struct tcf_block	*block;
 	int			refcnt;
 	struct idr		handle_idr;
 	struct hlist_node	hnode;
@@ -335,11 +335,7 @@ static struct hlist_head *tc_u_common_hash;
 
 static unsigned int tc_u_hash(const struct tcf_proto *tp)
 {
-	struct net_device *dev = tp->q->dev_queue->dev;
-	u32 qhandle = tp->q->handle;
-	int ifindex = dev->ifindex;
-
-	return hash_64((u64)ifindex << 32 | qhandle, U32_HASH_SHIFT);
+	return hash_64((u64) tp->chain->block, U32_HASH_SHIFT);
 }
 
 static struct tc_u_common *tc_u_common_find(const struct tcf_proto *tp)
@@ -349,7 +345,7 @@ static struct tc_u_common *tc_u_common_find(const struct tcf_proto *tp)
 
 	h = tc_u_hash(tp);
 	hlist_for_each_entry(tc, &tc_u_common_hash[h], hnode) {
-		if (tc->q == tp->q)
+		if (tc->block == tp->chain->block)
 			return tc;
 	}
 	return NULL;
@@ -378,7 +374,7 @@ static int u32_init(struct tcf_proto *tp)
 			kfree(root_ht);
 			return -ENOBUFS;
 		}
-		tp_c->q = tp->q;
+		tp_c->block = tp->chain->block;
 		INIT_HLIST_NODE(&tp_c->hnode);
 		idr_init(&tp_c->handle_idr);
 
-- 
2.9.5
