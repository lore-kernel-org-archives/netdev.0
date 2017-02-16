From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V4 5/7] net/sched: cls_matchall: Reflect HW offloading status
Date: Thu, 16 Feb 2017 10:31:14 +0200
Message-ID: <1487233876-28576-6-git-send-email-ogerlitz@mellanox.com>
References: <1487233876-28576-1-git-send-email-ogerlitz@mellanox.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, Roi Dayan <roid@mellanox.com>,
        netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44999 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752956AbdBPIbi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 03:31:38 -0500
In-Reply-To: <1487233876-28576-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matchall support for the "in hw" offloading flags.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Amir Vadai <amir@vadai.me>
Acked-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_matchall.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/net/sched/cls_matchall.c b/net/sched/cls_matchall.c
index 35ef1c1..224eb2c 100644
--- a/net/sched/cls_matchall.c
+++ b/net/sched/cls_matchall.c
@@ -56,6 +56,7 @@ static int mall_replace_hw_filter(struct tcf_proto *tp,
 	struct net_device *dev = tp->q->dev_queue->dev;
 	struct tc_to_netdev offload;
 	struct tc_cls_matchall_offload mall_offload = {0};
+	int err;
 
 	offload.type = TC_SETUP_MATCHALL;
 	offload.cls_mall = &mall_offload;
@@ -63,8 +64,12 @@ static int mall_replace_hw_filter(struct tcf_proto *tp,
 	offload.cls_mall->exts = &head->exts;
 	offload.cls_mall->cookie = cookie;
 
-	return dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle, tp->protocol,
-					     &offload);
+	err = dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle, tp->protocol,
+					    &offload);
+	if (!err)
+		head->flags |= TCA_CLS_FLAGS_IN_HW;
+
+	return err;
 }
 
 static void mall_destroy_hw_filter(struct tcf_proto *tp,
@@ -194,6 +199,9 @@ static int mall_change(struct net *net, struct sk_buff *in_skb,
 		}
 	}
 
+	if (!tc_in_hw(new->flags))
+		new->flags |= TCA_CLS_FLAGS_NOT_IN_HW;
+
 	*arg = (unsigned long) head;
 	rcu_assign_pointer(tp->root, new);
 	if (head)
-- 
2.5.5
