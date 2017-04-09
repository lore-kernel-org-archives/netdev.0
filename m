From: Haiyang Zhang <haiyangz@exchange.microsoft.com>
Subject: [PATCH net-next,1/3] hv_netvsc: Use per socket hash when available
Date: Sat,  8 Apr 2017 17:53:59 -0700
Message-ID: <1491699241-9944-1-git-send-email-haiyangz@exchange.microsoft.com>
Reply-To: haiyangz@microsoft.com
Cc: haiyangz@microsoft.com, kys@microsoft.com, olaf@aepfle.de,
        vkuznets@redhat.com, linux-kernel@vger.kernel.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>

The per socket hash is set when a socket is connected. Use it, when
available, to save CPU cycles on repeatedly computing hash on the same
connection.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index f24c289..0a129cb 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -211,9 +211,14 @@ static u16 netvsc_select_queue(struct net_device *ndev, struct sk_buff *skb,
 	int q_idx = sk_tx_queue_get(sk);
 
 	if (q_idx < 0 || skb->ooo_okay || q_idx >= num_tx_queues) {
-		u16 hash = __skb_tx_hash(ndev, skb, VRSS_SEND_TAB_SIZE);
+		u16 hash;
 		int new_idx;
 
+		if (sk)
+			skb_set_hash_from_sk(skb, sk);
+
+		hash = __skb_tx_hash(ndev, skb, VRSS_SEND_TAB_SIZE);
+
 		new_idx = net_device_ctx->tx_send_table[hash] % num_tx_queues;
 
 		if (q_idx != new_idx && sk &&
-- 
1.7.1
