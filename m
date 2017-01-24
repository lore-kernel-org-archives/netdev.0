From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH 08/18] netvsc: enhance transmit select_queue
Date: Tue, 24 Jan 2017 13:06:05 -0800
Message-ID: <20170124210615.18628-9-sthemmin@microsoft.com>
References: <20170124210615.18628-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net, kys@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:35323 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750828AbdAXVG7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 16:06:59 -0500
Received: by mail-pg0-f49.google.com with SMTP id 194so57794409pgd.2
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 13:06:25 -0800 (PST)
In-Reply-To: <20170124210615.18628-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The netvsc select queue function was missing many of the flow caching
features that exist in default tx queue selection. Add the same
logic to remember queue based on socket and implement two level
mapping (like RSS).

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 35 +++++++++++++++++++++++++++--------
 1 file changed, 27 insertions(+), 8 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index a09602e59cf5..86feab3f5443 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -191,22 +191,41 @@ static void *init_ppi_data(struct rndis_message *msg, u32 ppi_size,
 	return ppi;
 }
 
+/*
+ * Select queue for transmit.
+ *
+ * If a valid queue has already been assigned, then use that.
+ * Otherwise compute tx queue based on hash and the send table.
+ *
+ * This is basically similar to default (__netdev_pick_tx) with the added step
+ * of using the host send_table when no other queue has been assigned.
+ *
+ * TODO support XPS - but get_xps_queue not exported
+ */
 static u16 netvsc_select_queue(struct net_device *ndev, struct sk_buff *skb,
 			void *accel_priv, select_queue_fallback_t fallback)
 {
 	struct net_device_context *net_device_ctx = netdev_priv(ndev);
 	struct netvsc_device *nvsc_dev = net_device_ctx->nvdev;
-	u32 hash;
-	u16 q_idx = 0;
+	struct sock *sk = skb->sk;
+	int q_idx = sk_tx_queue_get(sk);
 
-	if (nvsc_dev == NULL || ndev->real_num_tx_queues <= 1)
-		return 0;
+	if (q_idx < 0 || skb->ooo_okay ||
+	    q_idx >= ndev->real_num_tx_queues) {
+		u16 hash = __skb_tx_hash(ndev, skb, VRSS_SEND_TAB_SIZE);
+		int new_idx;
+
+		new_idx = nvsc_dev->send_table[hash]
+			% nvsc_dev->num_chn;
 
-	hash = skb_get_hash(skb);
-	q_idx = nvsc_dev->send_table[hash % VRSS_SEND_TAB_SIZE] %
-		ndev->real_num_tx_queues;
+		if (q_idx != new_idx && sk &&
+		    sk_fullsock(sk) && rcu_access_pointer(sk->sk_dst_cache))
+			sk_tx_queue_set(sk, new_idx);
+
+		q_idx = new_idx;
+	}
 
-	if (!nvsc_dev->chn_table[q_idx])
+	if (unlikely(!nvsc_dev->chn_table[q_idx]))
 		q_idx = 0;
 
 	return q_idx;
-- 
2.11.0
