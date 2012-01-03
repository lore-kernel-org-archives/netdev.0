From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: [PATCH] net/davinci: do not use all descriptors for tx packets
Date: Tue,  3 Jan 2012 16:27:47 +0100
Message-ID: <1325604467-15122-1-git-send-email-s.hauer@pengutronix.de>
Cc: Anant Gole <anantgole@ti.com>, davem@davemloft.net, srk@ti.com,
	Sascha Hauer <s.hauer@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:34384 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753442Ab2ACP2D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 10:28:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver uses a shared pool for both rx and tx descriptors.
During open it queues fixed number of 128 descriptors for receive
packets. For each received packet it tries to queue another
descriptor. If this fails the descriptor is lost for rx.
The driver has no limitation on tx descriptors to use, so it
can happen during a nmap / ping -f attack that the driver
allocates all descriptors for tx and looses all rx descriptors.
The driver stops working then.
To fix this limit the number of tx descriptors used to half of
the descriptors available, the rx path uses the other half.

Tested on a custom board using nmap / ping -f to the board from
two different hosts.

Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
---
 drivers/net/ethernet/ti/davinci_emac.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 815c797..794ac30 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -115,6 +115,7 @@ static const char emac_version_string[] = "TI DaVinci EMAC Linux v6.1";
 #define EMAC_DEF_TX_CH			(0) /* Default 0th channel */
 #define EMAC_DEF_RX_CH			(0) /* Default 0th channel */
 #define EMAC_DEF_RX_NUM_DESC		(128)
+#define EMAC_DEF_TX_NUM_DESC		(128)
 #define EMAC_DEF_MAX_TX_CH		(1) /* Max TX channels configured */
 #define EMAC_DEF_MAX_RX_CH		(1) /* Max RX channels configured */
 #define EMAC_POLL_WEIGHT		(64) /* Default NAPI poll weight */
@@ -336,6 +337,7 @@ struct emac_priv {
 	u32 mac_hash2;
 	u32 multicast_hash_cnt[EMAC_NUM_MULTICAST_BITS];
 	u32 rx_addr_type;
+	atomic_t cur_tx;
 	const char *phy_id;
 	struct phy_device *phydev;
 	spinlock_t lock;
@@ -1044,6 +1046,9 @@ static void emac_tx_handler(void *token, int len, int status)
 {
 	struct sk_buff		*skb = token;
 	struct net_device	*ndev = skb->dev;
+	struct emac_priv	*priv = netdev_priv(ndev);
+
+	atomic_dec(&priv->cur_tx);
 
 	if (unlikely(netif_queue_stopped(ndev)))
 		netif_start_queue(ndev);
@@ -1092,6 +1097,9 @@ static int emac_dev_xmit(struct sk_buff *skb, struct net_device *ndev)
 		goto fail_tx;
 	}
 
+	if (atomic_inc_return(&priv->cur_tx) >= EMAC_DEF_TX_NUM_DESC)
+		netif_stop_queue(ndev);
+
 	return NETDEV_TX_OK;
 
 fail_tx:
-- 
1.7.7.3
