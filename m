From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 3/3] dp83640: add time stamp insertion for sync messages
Date: Tue, 20 Sep 2011 13:43:16 +0200
Message-ID: <bcaabccfb473de088680ce44eaba8c0bc6216c1c.1316518333.git.richard.cochran@omicron.at>
References: <cover.1316518332.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:55213 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755369Ab1ITLnI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2011 07:43:08 -0400
Received: by mail-ey0-f174.google.com with SMTP id 28so124723eya.19
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2011 04:43:08 -0700 (PDT)
In-Reply-To: <cover.1316518332.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1316518332.git.richard.cochran@omicron.at>
References: <cover.1316518332.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit adds one step support to the phyter. When enabled, the
hardware does not provide time stamps for transmitted sync messages but
instead inserts the stamp into the outgoing packet.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/net/phy/dp83640.c |   70 ++++++++++++++++++++++++++++++++++++--------
 1 files changed, 57 insertions(+), 13 deletions(-)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index d3c6a2e..c588a16 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -761,6 +761,41 @@ static void decode_status_frame(struct dp83640_private *dp83640,
 	}
 }
 
+static int is_sync(struct sk_buff *skb, int type)
+{
+	u8 *data = skb->data, *msgtype;
+	unsigned int offset = 0;
+
+	switch (type) {
+	case PTP_CLASS_V1_IPV4:
+	case PTP_CLASS_V2_IPV4:
+		offset = ETH_HLEN + IPV4_HLEN(data) + UDP_HLEN;
+		break;
+	case PTP_CLASS_V1_IPV6:
+	case PTP_CLASS_V2_IPV6:
+		offset = OFF_PTP6;
+		break;
+	case PTP_CLASS_V2_L2:
+		offset = ETH_HLEN;
+		break;
+	case PTP_CLASS_V2_VLAN:
+		offset = ETH_HLEN + VLAN_HLEN;
+		break;
+	default:
+		return 0;
+	}
+
+	if (type & PTP_CLASS_V1)
+		offset += OFF_PTP_CONTROL;
+
+	if (skb->len < offset + 1)
+		return 0;
+
+	msgtype = data + offset;
+
+	return (*msgtype & 0xf) == 0;
+}
+
 static int match(struct sk_buff *skb, unsigned int type, struct rxts *rxts)
 {
 	u16 *seqid;
@@ -1010,16 +1045,10 @@ static int dp83640_hwtstamp(struct phy_device *phydev, struct ifreq *ifr)
 	if (cfg.flags) /* reserved for future extensions */
 		return -EINVAL;
 
-	switch (cfg.tx_type) {
-	case HWTSTAMP_TX_OFF:
-		dp83640->hwts_tx_en = 0;
-		break;
-	case HWTSTAMP_TX_ON:
-		dp83640->hwts_tx_en = 1;
-		break;
-	default:
+	if (cfg.tx_type < 0 || cfg.tx_type > HWTSTAMP_TX_ONESTEP_SYNC)
 		return -ERANGE;
-	}
+
+	dp83640->hwts_tx_en = cfg.tx_type;
 
 	switch (cfg.rx_filter) {
 	case HWTSTAMP_FILTER_NONE:
@@ -1074,6 +1103,9 @@ static int dp83640_hwtstamp(struct phy_device *phydev, struct ifreq *ifr)
 	if (dp83640->hwts_tx_en)
 		txcfg0 |= TX_TS_EN;
 
+	if (dp83640->hwts_tx_en == HWTSTAMP_TX_ONESTEP_SYNC)
+		txcfg0 |= SYNC_1STEP | CHK_1STEP;
+
 	if (dp83640->hwts_rx_en)
 		rxcfg0 |= RX_TS_EN;
 
@@ -1156,12 +1188,24 @@ static void dp83640_txtstamp(struct phy_device *phydev,
 {
 	struct dp83640_private *dp83640 = phydev->priv;
 
-	if (!dp83640->hwts_tx_en) {
+	switch (dp83640->hwts_tx_en) {
+
+	case HWTSTAMP_TX_ONESTEP_SYNC:
+		if (is_sync(skb, type)) {
+			kfree_skb(skb);
+			return;
+		}
+		/* fall through */
+	case HWTSTAMP_TX_ON:
+		skb_queue_tail(&dp83640->tx_queue, skb);
+		schedule_work(&dp83640->ts_work);
+		break;
+
+	case HWTSTAMP_TX_OFF:
+	default:
 		kfree_skb(skb);
-		return;
+		break;
 	}
-	skb_queue_tail(&dp83640->tx_queue, skb);
-	schedule_work(&dp83640->ts_work);
 }
 
 static struct phy_driver dp83640_driver = {
-- 
1.7.2.5
