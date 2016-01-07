From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2 1/2] net, sched: add skb_at_tc_ingress helper
Date: Thu,  7 Jan 2016 15:50:22 +0100
Message-ID: <9217fc7175fd37df60c7fdac811a35dc957d9326.1452176592.git.daniel@iogearbox.net>
References: <cover.1452176592.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, hannes@stressinduktion.org,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42945 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751057AbcAGOu1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 09:50:27 -0500
In-Reply-To: <cover.1452176592.git.daniel@iogearbox.net>
In-Reply-To: <cover.1452176592.git.daniel@iogearbox.net>
References: <cover.1452176592.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a skb_at_tc_ingress() as this will be needed elsewhere as well and
can hide the ugly ifdef.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/net/sch_generic.h | 9 +++++++++
 net/sched/cls_bpf.c       | 6 +-----
 2 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index b2a8e63..636a362 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -407,6 +407,15 @@ bool tcf_destroy(struct tcf_proto *tp, bool force);
 void tcf_destroy_chain(struct tcf_proto __rcu **fl);
 int skb_do_redirect(struct sk_buff *);
 
+static inline bool skb_at_tc_ingress(const struct sk_buff *skb)
+{
+#ifdef CONFIG_NET_CLS_ACT
+	return G_TC_AT(skb->tc_verd) & AT_INGRESS;
+#else
+	return false;
+#endif
+}
+
 /* Reset all TX qdiscs greater then index of a device.  */
 static inline void qdisc_reset_all_tx_gt(struct net_device *dev, unsigned int i)
 {
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 99259f5..8dc8430 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -79,12 +79,8 @@ static int cls_bpf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 			    struct tcf_result *res)
 {
 	struct cls_bpf_head *head = rcu_dereference_bh(tp->root);
+	bool at_ingress = skb_at_tc_ingress(skb);
 	struct cls_bpf_prog *prog;
-#ifdef CONFIG_NET_CLS_ACT
-	bool at_ingress = G_TC_AT(skb->tc_verd) & AT_INGRESS;
-#else
-	bool at_ingress = false;
-#endif
 	int ret = -1;
 
 	if (unlikely(!skb_mac_header_was_set(skb)))
-- 
1.9.3
