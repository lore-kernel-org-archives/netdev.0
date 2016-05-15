From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next v2 1/9] bnxt_en: Fix invalid max channel parameter in ethtool -l.
Date: Sun, 15 May 2016 03:04:43 -0400
Message-ID: <1463295891-15216-2-git-send-email-michael.chan@broadcom.com>
References: <1463295891-15216-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:33629 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752749AbcEOHFE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 May 2016 03:05:04 -0400
Received: by mail-pf0-f173.google.com with SMTP id 206so56891008pfu.0
        for <netdev@vger.kernel.org>; Sun, 15 May 2016 00:05:03 -0700 (PDT)
In-Reply-To: <1463295891-15216-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Satish Baddipadige <sbaddipa@broadcom.com>

When there is only 1 MSI-X vector or in INTA mode, tx and rx pre-set
max channel parameters are shown incorrectly in ethtool -l.  With only 1
vector, bnxt_get_max_rings() will return -ENOMEM.  bnxt_get_channels
should check this return value, and set max_rx/max_tx to 0 if it is
non-zero.

Signed-off-by: Satish Baddipadige <sbaddipa@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index d6e41f2..28171f9 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -327,7 +327,11 @@ static void bnxt_get_channels(struct net_device *dev,
 	bnxt_get_max_rings(bp, &max_rx_rings, &max_tx_rings, true);
 	channel->max_combined = max_rx_rings;
 
-	bnxt_get_max_rings(bp, &max_rx_rings, &max_tx_rings, false);
+	if (bnxt_get_max_rings(bp, &max_rx_rings, &max_tx_rings, false)) {
+		max_rx_rings = 0;
+		max_tx_rings = 0;
+	}
+
 	tcs = netdev_get_num_tc(dev);
 	if (tcs > 1)
 		max_tx_rings /= tcs;
-- 
1.8.3.1
