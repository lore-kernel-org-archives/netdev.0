From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH 5/5] net: add skb.old_queue_mapping
Date: Mon, 13 Dec 2010 22:43:34 +0800
Message-ID: <1292251414-5154-5-git-send-email-xiaosuo@gmail.com>
References: <1292251414-5154-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <hadi@cyberus.ca>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:38554 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754034Ab0LMOon (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 09:44:43 -0500
Received: by ywl5 with SMTP id 5so3286033ywl.19
        for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 06:44:42 -0800 (PST)
In-Reply-To: <1292251414-5154-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For the skbs returned from ifb, we should use the queue_mapping
saved before ifb.

We save old queue_mapping in old_queue_mapping just before calling 
dev_queue_xmit, and restore the old_queue_mapping to queue_mapping
just before reinjecting the skb.

dev_pick_tx() use the current queue_mapping for the skbs reinjected
by ifb.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 drivers/net/ifb.c      |    1 +
 include/linux/skbuff.h |    3 +++
 net/core/dev.c         |    5 +++++
 net/sched/act_mirred.c |    1 +
 4 files changed, 10 insertions(+)
diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 16c767b..481e4b1 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -95,6 +95,7 @@ static void ri_tasklet(unsigned long _dev)
 		u64_stats_update_end(&qp->syncp);
 		skb->skb_iif = dev->ifindex;
 
+		skb->queue_mapping = skb->old_queue_mapping;
 		if (from & AT_EGRESS) {
 			dev_queue_xmit(skb);
 		} else if (from & AT_INGRESS) {
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 19f37a6..2ce2a96 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -403,6 +403,9 @@ struct sk_buff {
 	};
 
 	__u16			vlan_tci;
+#ifdef CONFIG_NET_CLS_ACT
+	__u16			old_queue_mapping;
+#endif
 
 	sk_buff_data_t		transport_header;
 	sk_buff_data_t		network_header;
diff --git a/net/core/dev.c b/net/core/dev.c
index d28b3a0..8e97cfd 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2190,6 +2190,11 @@ static struct netdev_queue *dev_pick_tx(struct net_device *dev,
 	int queue_index;
 	const struct net_device_ops *ops = dev->netdev_ops;
 
+#ifdef CONFIG_NET_CLS_ACT
+	if (skb->tc_verd & TC_NCLS)
+		queue_index = skb_get_queue_mapping(skb);
+	else
+#endif
 	if (dev->real_num_tx_queues == 1)
 		queue_index = 0;
 	else if (ops->ndo_select_queue) {
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 0c311be..853eb30 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -197,6 +197,7 @@ static int tcf_mirred(struct sk_buff *skb, struct tc_action *a,
 
 	skb2->skb_iif = skb->dev->ifindex;
 	skb2->dev = dev;
+	skb2->old_queue_mapping = skb->queue_mapping;
 	dev_queue_xmit(skb2);
 	err = 0;
 
