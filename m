From: Girish Moodalbail <girish.moodalbail@oracle.com>
Subject: [PATCH net-next] macsec: double accounting of dropped rx/tx packets
Date: Fri, 19 May 2017 15:25:44 -0700
Message-ID: <1495232744-17075-1-git-send-email-girish.moodalbail@oracle.com>
Cc: davem@davemloft.net, sd@queasysnail.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:50274 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751816AbdESWgv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 18:36:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The macsec implementation shouldn't account for rx/tx packets that are
dropped in the netdev framework. The netdev framework itself accounts
for such packets by atomically updating struct net_device`rx_dropped and
struct net_device`tx_dropped fields. Later on when the stats for macsec
link is retrieved, the packets dropped in netdev framework will be
included in dev_get_stats() after calling macsec.c`macsec_get_stats64()

Signed-off-by: Girish Moodalbail <girish.moodalbail@oracle.com>
---
 drivers/net/macsec.c | 15 +++------------
 1 file changed, 3 insertions(+), 12 deletions(-)

diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index cdc347b..91642fd 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -588,8 +588,6 @@ static void count_tx(struct net_device *dev, int ret, int len)
 		stats->tx_packets++;
 		stats->tx_bytes += len;
 		u64_stats_update_end(&stats->syncp);
-	} else {
-		dev->stats.tx_dropped++;
 	}
 }
 
@@ -883,7 +881,7 @@ static void macsec_decrypt_done(struct crypto_async_request *base, int err)
 	struct macsec_dev *macsec = macsec_priv(dev);
 	struct macsec_rx_sa *rx_sa = macsec_skb_cb(skb)->rx_sa;
 	struct macsec_rx_sc *rx_sc = rx_sa->sc;
-	int len, ret;
+	int len;
 	u32 pn;
 
 	aead_request_free(macsec_skb_cb(skb)->req);
@@ -904,11 +902,8 @@ static void macsec_decrypt_done(struct crypto_async_request *base, int err)
 	macsec_reset_skb(skb, macsec->secy.netdev);
 
 	len = skb->len;
-	ret = gro_cells_receive(&macsec->gro_cells, skb);
-	if (ret == NET_RX_SUCCESS)
+	if (gro_cells_receive(&macsec->gro_cells, skb) == NET_RX_SUCCESS)
 		count_rx(dev, len);
-	else
-		macsec->secy.netdev->stats.rx_dropped++;
 
 	rcu_read_unlock_bh();
 
@@ -1037,7 +1032,6 @@ static void handle_not_macsec(struct sk_buff *skb)
 	 */
 	list_for_each_entry_rcu(macsec, &rxd->secys, secys) {
 		struct sk_buff *nskb;
-		int ret;
 		struct pcpu_secy_stats *secy_stats = this_cpu_ptr(macsec->stats);
 
 		if (macsec->secy.validate_frames == MACSEC_VALIDATE_STRICT) {
@@ -1054,13 +1048,10 @@ static void handle_not_macsec(struct sk_buff *skb)
 
 		nskb->dev = macsec->secy.netdev;
 
-		ret = netif_rx(nskb);
-		if (ret == NET_RX_SUCCESS) {
+		if (netif_rx(nskb) == NET_RX_SUCCESS) {
 			u64_stats_update_begin(&secy_stats->syncp);
 			secy_stats->stats.InPktsUntagged++;
 			u64_stats_update_end(&secy_stats->syncp);
-		} else {
-			macsec->secy.netdev->stats.rx_dropped++;
 		}
 	}
 
-- 
1.8.3.1
