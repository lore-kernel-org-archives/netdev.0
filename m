From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: Avoid accessing skb after submitting to
 input queue
Date: Thu, 26 Jan 2017 11:52:35 -0800
Message-ID: <20170126195235.GA3875@felix.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <raghu.vatsavayi@cavium.com>,
        <derek.chickles@cavium.com>, <satananda.burla@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0073.outbound.protection.outlook.com ([104.47.38.73]:12512
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753184AbdAZTxv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Jan 2017 14:53:51 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Satanand Burla <satananda.burla@cavium.com>

Accessing skb after submitting to input queue can cause
access to stale pointers if the skb ends up being transmitted
and freed by that time.

Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 6 +++---
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 6 +++---
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 5ee3f00..9261ddc 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -3316,11 +3316,11 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 
 	netif_trans_update(netdev);
 
-	if (skb_shinfo(skb)->gso_size)
-		stats->tx_done += skb_shinfo(skb)->gso_segs;
+	if (tx_info->s.gso_segs)
+		stats->tx_done += tx_info->s.gso_segs;
 	else
 		stats->tx_done++;
-	stats->tx_tot_bytes += skb->len;
+	stats->tx_tot_bytes += ndata.datasize;
 
 	return NETDEV_TX_OK;
 
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index e96cf6c..a6587d7 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -2433,11 +2433,11 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 
 	netif_trans_update(netdev);
 
-	if (skb_shinfo(skb)->gso_size)
-		stats->tx_done += skb_shinfo(skb)->gso_segs;
+	if (tx_info->s.gso_segs)
+		stats->tx_done += tx_info->s.gso_segs;
 	else
 		stats->tx_done++;
-	stats->tx_tot_bytes += skb->len;
+	stats->tx_tot_bytes += ndata.datasize;
 
 	return NETDEV_TX_OK;
