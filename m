From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 3/4] net/sched: cls_u32: Use skip flags to reflect HW offload status
Date: Thu,  9 Feb 2017 16:18:07 +0200
Message-ID: <1486649888-2786-4-git-send-email-ogerlitz@mellanox.com>
References: <1486649888-2786-1-git-send-email-ogerlitz@mellanox.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        John Fastabend <john.r.fastabend@intel.com>,
        Amir Vadai <amirva@vadai.me>, netdev@vger.kernel.org,
        Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:52572 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752505AbdBIOSW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 09:18:22 -0500
In-Reply-To: <1486649888-2786-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently there is no way of querying whether a filter is
offloaded to HW or not when using both policy (no flag).

Reuse the skip flags to show the insertion status by setting
the skip_hw flag in case the filter wasn't offloaded.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 net/sched/cls_u32.c | 20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index a6ec3e4b..97411d5 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -493,7 +493,7 @@ static void u32_clear_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h)
 }
 
 static int u32_replace_hw_knode(struct tcf_proto *tp, struct tc_u_knode *n,
-				u32 flags)
+				u32 *flags)
 {
 	struct net_device *dev = tp->q->dev_queue->dev;
 	struct tc_cls_u32_offload u32_offload = {0};
@@ -503,8 +503,12 @@ static int u32_replace_hw_knode(struct tcf_proto *tp, struct tc_u_knode *n,
 	offload.type = TC_SETUP_CLSU32;
 	offload.cls_u32 = &u32_offload;
 
-	if (!tc_should_offload(dev, tp, flags))
-		return tc_skip_sw(flags) ? -EINVAL : 0;
+	if (!tc_should_offload(dev, tp, *flags)) {
+		if (tc_skip_sw(*flags))
+			return -EINVAL;
+		*flags = TCA_CLS_FLAGS_SKIP_HW;
+		return 0;
+	}
 
 	offload.cls_u32->command = TC_CLSU32_REPLACE_KNODE;
 	offload.cls_u32->knode.handle = n->handle;
@@ -523,9 +527,11 @@ static int u32_replace_hw_knode(struct tcf_proto *tp, struct tc_u_knode *n,
 
 	err = dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
 					    tp->protocol, &offload);
-	if (tc_skip_sw(flags))
+	if (tc_skip_sw(*flags))
 		return err;
 
+	if (err)
+		*flags = TCA_CLS_FLAGS_SKIP_HW;
 	return 0;
 }
 
@@ -889,12 +895,13 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 			return err;
 		}
 
-		err = u32_replace_hw_knode(tp, new, flags);
+		err = u32_replace_hw_knode(tp, new, &flags);
 		if (err) {
 			u32_destroy_key(tp, new, false);
 			return err;
 		}
 
+		n->flags |= flags;
 		u32_replace_knode(tp, tp_c, new);
 		tcf_unbind_filter(tp, &n->res);
 		call_rcu(&n->rcu, u32_delete_key_rcu);
@@ -1010,10 +1017,11 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 		struct tc_u_knode __rcu **ins;
 		struct tc_u_knode *pins;
 
-		err = u32_replace_hw_knode(tp, n, flags);
+		err = u32_replace_hw_knode(tp, n, &flags);
 		if (err)
 			goto errhw;
 
+		n->flags |= flags;
 		ins = &ht->ht[TC_U32_HASH(handle)];
 		for (pins = rtnl_dereference(*ins); pins;
 		     ins = &pins->next, pins = rtnl_dereference(*ins))
-- 
2.3.7
