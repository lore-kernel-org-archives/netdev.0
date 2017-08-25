From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH] hinic: skb_pad() frees on error
Date: Fri, 25 Aug 2017 11:24:28 +0300
Message-ID: <20170825082428.hpnbs4i74bubm4cz@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The skb_pad() function frees the skb on error, so this code has a double
free.

Fixes: 00e57a6d4ad3 ("net-next/hinic: Add Tx operation")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/huawei/hinic/hinic_tx.c b/drivers/net/ethernet/huawei/hinic/hinic_tx.c
index 5bf6a32faa46..abe3e38cd342 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_tx.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_tx.c
@@ -192,7 +192,7 @@ netdev_tx_t hinic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	if (skb->len < MIN_SKB_LEN) {
 		if (skb_pad(skb, MIN_SKB_LEN - skb->len)) {
 			netdev_err(netdev, "Failed to pad skb\n");
-			goto skb_error;
+			goto update_error_stats;
 		}
 
 		skb->len = MIN_SKB_LEN;
@@ -237,6 +237,7 @@ netdev_tx_t hinic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 skb_error:
 	dev_kfree_skb_any(skb);
 
+update_error_stats:
 	u64_stats_update_begin(&txq->txq_stats.syncp);
 	txq->txq_stats.tx_dropped++;
 	u64_stats_update_end(&txq->txq_stats.syncp);
