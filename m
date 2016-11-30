From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: [PATCH net-next 1/8] net/sched: Add separate check for skip_hw flag
Date: Wed, 30 Nov 2016 16:41:28 +0200
Message-ID: <1480516895-29545-2-git-send-email-hadarh@mellanox.com>
References: <1480516895-29545-1-git-send-email-hadarh@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:45992 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753283AbcK3PhJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 10:37:09 -0500
In-Reply-To: <1480516895-29545-1-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Creating a difference between two possible cases:
1. Not offloading tc rule since the user sets 'skip_hw' flag.
2. Not offloading tc rule since the device doesn't support offloading.

This patch doesn't add any new functionality.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Reviewed-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/pkt_cls.h | 19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 767b03a..45ad9aa 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -425,16 +425,14 @@ struct tc_cls_u32_offload {
 	};
 };
 
-static inline bool tc_should_offload(const struct net_device *dev,
-				     const struct tcf_proto *tp, u32 flags)
+static inline bool tc_can_offload(const struct net_device *dev,
+				  const struct tcf_proto *tp)
 {
 	const struct Qdisc *sch = tp->q;
 	const struct Qdisc_class_ops *cops = sch->ops->cl_ops;
 
 	if (!(dev->features & NETIF_F_HW_TC))
 		return false;
-	if (flags & TCA_CLS_FLAGS_SKIP_HW)
-		return false;
 	if (!dev->netdev_ops->ndo_setup_tc)
 		return false;
 	if (cops && cops->tcf_cl_offload)
@@ -443,6 +441,19 @@ static inline bool tc_should_offload(const struct net_device *dev,
 	return true;
 }
 
+static inline bool tc_skip_hw(u32 flags)
+{
+	return (flags & TCA_CLS_FLAGS_SKIP_HW) ? true : false;
+}
+
+static inline bool tc_should_offload(const struct net_device *dev,
+				     const struct tcf_proto *tp, u32 flags)
+{
+	if (tc_skip_hw(flags))
+		return false;
+	return tc_can_offload(dev, tp);
+}
+
 static inline bool tc_skip_sw(u32 flags)
 {
 	return (flags & TCA_CLS_FLAGS_SKIP_SW) ? true : false;
-- 
1.8.3.1
