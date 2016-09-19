From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 05/10] bnxt_en: Fix ethtool -l|-L inconsistent channel counts.
Date: Mon, 19 Sep 2016 03:58:04 -0400
Message-ID: <1474271889-8229-6-git-send-email-michael.chan@broadcom.com>
References: <1474271889-8229-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:35465 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760151AbcISH6a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 03:58:30 -0400
Received: by mail-pf0-f178.google.com with SMTP id z123so48337415pfz.2
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 00:58:28 -0700 (PDT)
In-Reply-To: <1474271889-8229-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The existing code is inconsistent in reporting and accepting the combined
channel count.  bnxt_get_channels() reports maximum combined as the
maximum rx count.  bnxt_set_channels() accepts combined count that
cannot be bigger than max rx or max tx.

For example, if max rx = 2 and max tx = 1, we report max supported
combined to be 2.  But if the user tries to set combined to 2, it will
fail because 2 is bigger than max tx which is 1.

Fix the code to be consistent.  Max allowed combined = max(max_rx, max_tx).
We will accept a combined channel count <= max(max_rx, max_tx).

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index 4a430b6..c74ce69 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -348,7 +348,7 @@ static void bnxt_get_channels(struct net_device *dev,
 	int max_rx_rings, max_tx_rings, tcs;
 
 	bnxt_get_max_rings(bp, &max_rx_rings, &max_tx_rings, true);
-	channel->max_combined = max_rx_rings;
+	channel->max_combined = max_t(int, max_rx_rings, max_tx_rings);
 
 	if (bnxt_get_max_rings(bp, &max_rx_rings, &max_tx_rings, false)) {
 		max_rx_rings = 0;
@@ -406,8 +406,8 @@ static int bnxt_set_channels(struct net_device *dev,
 	if (tcs > 1)
 		max_tx_rings /= tcs;
 
-	if (sh && (channel->combined_count > max_rx_rings ||
-		   channel->combined_count > max_tx_rings))
+	if (sh &&
+	    channel->combined_count > max_t(int, max_rx_rings, max_tx_rings))
 		return -ENOMEM;
 
 	if (!sh && (channel->rx_count > max_rx_rings ||
@@ -430,8 +430,10 @@ static int bnxt_set_channels(struct net_device *dev,
 
 	if (sh) {
 		bp->flags |= BNXT_FLAG_SHARED_RINGS;
-		bp->rx_nr_rings = channel->combined_count;
-		bp->tx_nr_rings_per_tc = channel->combined_count;
+		bp->rx_nr_rings = min_t(int, channel->combined_count,
+					max_rx_rings);
+		bp->tx_nr_rings_per_tc = min_t(int, channel->combined_count,
+					       max_tx_rings);
 	} else {
 		bp->flags &= ~BNXT_FLAG_SHARED_RINGS;
 		bp->rx_nr_rings = channel->rx_count;
-- 
1.8.3.1
