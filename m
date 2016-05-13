From: Amir Vadai <amir@vadai.me>
Subject: [PATCH net-next 3/8] net/sched: cls_flower: Hardware offloaded filters statistics support
Date: Fri, 13 May 2016 12:55:37 +0000
Message-ID: <1463144142-13810-4-git-send-email-amir@vadai.me>
References: <1463144142-13810-1-git-send-email-amir@vadai.me>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amir@vadai.me>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Amir Vadai <amirva@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:41790 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753028AbcEMM5r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 May 2016 08:57:47 -0400
In-Reply-To: <1463144142-13810-1-git-send-email-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirva@mellanox.com>

Introduce a new command in ndo_setup_tc() for hardware offloaded
filters, to call the NIC driver, and make it update the statistics.
This will be done before dumping the filter and its statistics.

Signed-off-by: Amir Vadai <amirva@mellanox.com>
---
 include/net/pkt_cls.h  |  1 +
 net/sched/cls_flower.c | 21 +++++++++++++++++++++
 2 files changed, 22 insertions(+)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index caa5e18..cc561a8 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -412,6 +412,7 @@ static inline bool tc_should_offload(struct net_device *dev, u32 flags)
 enum tc_fl_command {
 	TC_CLSFLOWER_REPLACE,
 	TC_CLSFLOWER_DESTROY,
+	TC_CLSFLOWER_STATS,
 };
 
 struct tc_cls_flower_offload {
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 2181ffc..730aaca 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -210,6 +210,25 @@ static void fl_hw_replace_filter(struct tcf_proto *tp,
 	dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle, tp->protocol, &tc);
 }
 
+static void fl_hw_update_stats(struct tcf_proto *tp, struct cls_fl_filter *f)
+{
+	struct net_device *dev = tp->q->dev_queue->dev;
+	struct tc_cls_flower_offload offload = {0};
+	struct tc_to_netdev tc;
+
+	if (!tc_should_offload(dev, 0))
+		return;
+
+	offload.command = TC_CLSFLOWER_STATS;
+	offload.cookie = (unsigned long)f;
+	offload.exts = &f->exts;
+
+	tc.type = TC_SETUP_CLSFLOWER;
+	tc.cls_flower = &offload;
+
+	dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle, tp->protocol, &tc);
+}
+
 static bool fl_destroy(struct tcf_proto *tp, bool force)
 {
 	struct cls_fl_head *head = rtnl_dereference(tp->root);
@@ -662,6 +681,8 @@ static int fl_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 			goto nla_put_failure;
 	}
 
+	fl_hw_update_stats(tp, f);
+
 	if (fl_dump_key_val(skb, key->eth.dst, TCA_FLOWER_KEY_ETH_DST,
 			    mask->eth.dst, TCA_FLOWER_KEY_ETH_DST_MASK,
 			    sizeof(key->eth.dst)) ||
-- 
2.8.0
