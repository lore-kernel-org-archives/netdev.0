From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH 2/2] b44: always set duplex mode why phy changes
Date: Sun,  2 Mar 2014 17:29:34 +0100
Message-ID: <1393777774-7400-2-git-send-email-hauke@hauke-m.de>
References: <1393777774-7400-1-git-send-email-hauke@hauke-m.de>
Cc: zambrano@broadcom.com, netdev@vger.kernel.org,
	Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:56399 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750890AbaCBQ3p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Mar 2014 11:29:45 -0500
In-Reply-To: <1393777774-7400-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Without this patch b44_check_phy() was called when the phy called the
adjust callback. This method only change the mac duplex mode when the
carrier was off. When the phy changed the duplex mode after the carrier
was on the mac was not changed. This happened when an external phy was
used.

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 drivers/net/ethernet/broadcom/b44.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
index e8046e1..8a7bf7d 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -2229,7 +2229,12 @@ static void b44_adjust_link(struct net_device *dev)
 	}
 
 	if (status_changed) {
-		b44_check_phy(bp);
+		u32 val = br32(bp, B44_TX_CTRL);
+		if (bp->flags & B44_FLAG_FULL_DUPLEX)
+			val |= TX_CTRL_DUPLEX;
+		else
+			val &= ~TX_CTRL_DUPLEX;
+		bw32(bp, B44_TX_CTRL, val);
 		phy_print_status(phydev);
 	}
 }
-- 
1.7.10.4
