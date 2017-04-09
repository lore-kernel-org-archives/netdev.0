From: Haiyang Zhang <haiyangz@exchange.microsoft.com>
Subject: [PATCH net-next,2/3] hv_netvsc: Fix the queue index computation in forwarding case
Date: Sat,  8 Apr 2017 17:54:00 -0700
Message-ID: <1491699241-9944-2-git-send-email-haiyangz@exchange.microsoft.com>
References: <1491699241-9944-1-git-send-email-haiyangz@exchange.microsoft.com>
Reply-To: haiyangz@microsoft.com
Cc: haiyangz@microsoft.com, kys@microsoft.com, olaf@aepfle.de,
        vkuznets@redhat.com, linux-kernel@vger.kernel.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1491699241-9944-1-git-send-email-haiyangz@exchange.microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>

If the outgoing skb has a RX queue mapping available, we use the queue
number directly, other than put it through Send Indirection Table.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h |    2 +-
 drivers/net/hyperv/netvsc_drv.c |   54 ++++++++++++++++++++++++--------------
 2 files changed, 35 insertions(+), 21 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 4747ad4..768b3ae 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -633,7 +633,7 @@ struct nvsp_message {
 
 #define NETVSC_PACKET_SIZE                      4096
 
-#define VRSS_SEND_TAB_SIZE 16
+#define VRSS_SEND_TAB_SIZE 16  /* must be power of 2 */
 #define VRSS_CHANNEL_MAX 64
 #define VRSS_CHANNEL_DEFAULT 8
 
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 0a129cb..fad864f 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -191,6 +191,27 @@ static int netvsc_close(struct net_device *net)
 	return ppi;
 }
 
+static inline int netvsc_get_tx_queue(struct net_device *ndev,
+				      struct sk_buff *skb, int old_idx)
+{
+	const struct net_device_context *ndc = netdev_priv(ndev);
+	struct sock *sk = skb->sk;
+	int q_idx;
+
+	if (sk)
+		skb_set_hash_from_sk(skb, sk);
+
+	q_idx = ndc->tx_send_table[skb_get_hash(skb) &
+				   (VRSS_SEND_TAB_SIZE - 1)];
+
+	/* If queue index changed record the new value */
+	if (q_idx != old_idx &&
+	    sk && sk_fullsock(sk) && rcu_access_pointer(sk->sk_dst_cache))
+		sk_tx_queue_set(sk, q_idx);
+
+	return q_idx;
+}
+
 /*
  * Select queue for transmit.
  *
@@ -205,29 +226,22 @@ static int netvsc_close(struct net_device *net)
 static u16 netvsc_select_queue(struct net_device *ndev, struct sk_buff *skb,
 			void *accel_priv, select_queue_fallback_t fallback)
 {
-	struct net_device_context *net_device_ctx = netdev_priv(ndev);
 	unsigned int num_tx_queues = ndev->real_num_tx_queues;
-	struct sock *sk = skb->sk;
-	int q_idx = sk_tx_queue_get(sk);
-
-	if (q_idx < 0 || skb->ooo_okay || q_idx >= num_tx_queues) {
-		u16 hash;
-		int new_idx;
-
-		if (sk)
-			skb_set_hash_from_sk(skb, sk);
-
-		hash = __skb_tx_hash(ndev, skb, VRSS_SEND_TAB_SIZE);
+	int q_idx = sk_tx_queue_get(skb->sk);
 
-		new_idx = net_device_ctx->tx_send_table[hash] % num_tx_queues;
-
-		if (q_idx != new_idx && sk &&
-		    sk_fullsock(sk) && rcu_access_pointer(sk->sk_dst_cache))
-			sk_tx_queue_set(sk, new_idx);
-
-		q_idx = new_idx;
+	if (q_idx < 0 || skb->ooo_okay) {
+		/* If forwarding a packet, we use the recorded queue when
+		 * available for better cache locality.
+		 */
+		if (skb_rx_queue_recorded(skb))
+			q_idx = skb_get_rx_queue(skb);
+		else
+			q_idx = netvsc_get_tx_queue(ndev, skb, q_idx);
 	}
 
+	while (unlikely(q_idx >= num_tx_queues))
+		q_idx -= num_tx_queues;
+
 	return q_idx;
 }
 
-- 
1.7.1
