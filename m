From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 1/9] bnxt_en: Fix invalid max channel parameter in ethtool -l.
Date: Sat, 14 May 2016 20:29:40 -0400
Message-ID: <1463272188-30025-2-git-send-email-michael.chan@broadcom.com>
References: <1463272188-30025-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:34581 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753972AbcEOAaA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 May 2016 20:30:00 -0400
Received: by mail-pf0-f172.google.com with SMTP id y69so54327553pfb.1
        for <netdev@vger.kernel.org>; Sat, 14 May 2016 17:30:00 -0700 (PDT)
In-Reply-To: <1463272188-30025-1-git-send-email-michael.chan@broadcom.com>
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
