From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net] netvsc: handle select_queue when device is being removed
Date: Thu,  9 Mar 2017 14:58:29 -0800
Message-ID: <20170309225829.6051-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: kys@microsoft.com, haiyangz@microsoft.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:33298 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754033AbdCIW6i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 17:58:38 -0500
Received: by mail-pg0-f45.google.com with SMTP id 25so31509987pgy.0
        for <netdev@vger.kernel.org>; Thu, 09 Mar 2017 14:58:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the send indirection table from the inner device (netvsc)
to the network device context.

It is possible that netvsc_device is not present (remove in progress).
This solves potential use after free issues when packet is being
created during MTU change, shutdown, or queue count changes.

Fixes: d8e18ee0fa96 ("netvsc: enhance transmit select_queue")
Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
Needed only for 4.11 and net-next.

 drivers/net/hyperv/hyperv_net.h |  3 ++-
 drivers/net/hyperv/netvsc.c     |  8 ++------
 drivers/net/hyperv/netvsc_drv.c | 11 +++--------
 3 files changed, 7 insertions(+), 15 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index d3e73ac158ae..f9f3dba7a588 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -700,6 +700,8 @@ struct net_device_context {
 
 	u32 tx_checksum_mask;
 
+	u32 tx_send_table[VRSS_SEND_TAB_SIZE];
+
 	/* Ethtool settings */
 	u8 duplex;
 	u32 speed;
@@ -757,7 +759,6 @@ struct netvsc_device {
 
 	struct nvsp_message revoke_packet;
 
-	u32 send_table[VRSS_SEND_TAB_SIZE];
 	u32 max_chn;
 	u32 num_chn;
 	spinlock_t sc_lock; /* Protects num_sc_offered variable */
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index d35ebd993b38..4c1d8cca247b 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -1136,15 +1136,11 @@ static void netvsc_receive(struct net_device *ndev,
 static void netvsc_send_table(struct hv_device *hdev,
 			      struct nvsp_message *nvmsg)
 {
-	struct netvsc_device *nvscdev;
 	struct net_device *ndev = hv_get_drvdata(hdev);
+	struct net_device_context *net_device_ctx = netdev_priv(ndev);
 	int i;
 	u32 count, *tab;
 
-	nvscdev = get_outbound_net_device(hdev);
-	if (!nvscdev)
-		return;
-
 	count = nvmsg->msg.v5_msg.send_table.count;
 	if (count != VRSS_SEND_TAB_SIZE) {
 		netdev_err(ndev, "Received wrong send-table size:%u\n", count);
@@ -1155,7 +1151,7 @@ static void netvsc_send_table(struct hv_device *hdev,
 		      nvmsg->msg.v5_msg.send_table.offset);
 
 	for (i = 0; i < count; i++)
-		nvscdev->send_table[i] = tab[i];
+		net_device_ctx->tx_send_table[i] = tab[i];
 }
 
 static void netvsc_send_vf(struct net_device_context *net_device_ctx,
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index bc05c895d958..5ede87f30463 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -206,17 +206,15 @@ static u16 netvsc_select_queue(struct net_device *ndev, struct sk_buff *skb,
 			void *accel_priv, select_queue_fallback_t fallback)
 {
 	struct net_device_context *net_device_ctx = netdev_priv(ndev);
-	struct netvsc_device *nvsc_dev = net_device_ctx->nvdev;
+	unsigned int num_tx_queues = ndev->real_num_tx_queues;
 	struct sock *sk = skb->sk;
 	int q_idx = sk_tx_queue_get(sk);
 
-	if (q_idx < 0 || skb->ooo_okay ||
-	    q_idx >= ndev->real_num_tx_queues) {
+	if (q_idx < 0 || skb->ooo_okay || q_idx >= num_tx_queues) {
 		u16 hash = __skb_tx_hash(ndev, skb, VRSS_SEND_TAB_SIZE);
 		int new_idx;
 
-		new_idx = nvsc_dev->send_table[hash]
-			% nvsc_dev->num_chn;
+		new_idx = net_device_ctx->tx_send_table[hash] % num_tx_queues;
 
 		if (q_idx != new_idx && sk &&
 		    sk_fullsock(sk) && rcu_access_pointer(sk->sk_dst_cache))
@@ -225,9 +223,6 @@ static u16 netvsc_select_queue(struct net_device *ndev, struct sk_buff *skb,
 		q_idx = new_idx;
 	}
 
-	if (unlikely(!nvsc_dev->chan_table[q_idx].channel))
-		q_idx = 0;
-
 	return q_idx;
 }
 
-- 
2.11.0
