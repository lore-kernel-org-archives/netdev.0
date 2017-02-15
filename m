From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V3 6/7] net/sched: cls_u32: Reflect HW offload status
Date: Wed, 15 Feb 2017 10:52:36 +0200
Message-ID: <1487148757-24809-7-git-send-email-ogerlitz@mellanox.com>
References: <1487148757-24809-1-git-send-email-ogerlitz@mellanox.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>,
        John Fastabend <john.r.fastabend@intel.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Roi Dayan <roid@mellanox.com>, Jiri Pirko <jiri@mellanox.com>,
        netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:36646 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751362AbdBOIwp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 03:52:45 -0500
In-Reply-To: <1487148757-24809-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

U32 support for the "in hw" offloading flags.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Amir Vadai <amir@vadai.me>
---
 net/sched/cls_u32.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index a6ec3e4b..8c6cc39 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -523,6 +523,10 @@ static int u32_replace_hw_knode(struct tcf_proto *tp, struct tc_u_knode *n,
 
 	err = dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
 					    tp->protocol, &offload);
+
+	if (!err)
+		n->flags |= TCA_CLS_FLAGS_IN_HW;
+
 	if (tc_skip_sw(flags))
 		return err;
 
@@ -895,6 +899,9 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 			return err;
 		}
 
+		if (!(tc_in_hw(new->flags)))
+			new->flags |= TCA_CLS_FLAGS_NOT_IN_HW;
+
 		u32_replace_knode(tp, tp_c, new);
 		tcf_unbind_filter(tp, &n->res);
 		call_rcu(&n->rcu, u32_delete_key_rcu);
@@ -1014,6 +1021,9 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 		if (err)
 			goto errhw;
 
+		if (!(tc_in_hw(n->flags)))
+			n->flags |= TCA_CLS_FLAGS_NOT_IN_HW;
+
 		ins = &ht->ht[TC_U32_HASH(handle)];
 		for (pins = rtnl_dereference(*ins); pins;
 		     ins = &pins->next, pins = rtnl_dereference(*ins))
-- 
2.3.7
