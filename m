From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH RFC 22/30] net: fec: quiesce packet processing when taking
 link down in fec_enet_adjust_link()
Date: Fri, 20 Jun 2014 13:13:35 +0100
Message-ID: <E1WxxhH-0005YH-Iz@rmk-PC.arm.linux.org.uk>
References: <20140620121118.GR32514@n2100.arm.linux.org.uk>
Cc: Fugang Duan <B38611@freescale.com>, netdev@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:36384 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S967429AbaFTMNh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 08:13:37 -0400
In-Reply-To: <20140620121118.GR32514@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the link goes down, the adjust_link method will be called, but
there is no synchronisation to ensure that we won't be processing some
last remaining packets via the NAPI handlers while performing a reset of
the device.

Add the necessary synchronisation to ensure that packet processing
is complete before we stop and reset the FEC.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/ethernet/freescale/fec_main.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 466268fffadd..b2b8aff3f73c 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1530,7 +1530,11 @@ static void fec_enet_adjust_link(struct net_device *ndev)
 		}
 	} else {
 		if (fep->link) {
+			napi_disable(&fep->napi);
+			netif_tx_lock_bh(ndev);
 			fec_stop(ndev);
+			netif_tx_unlock_bh(ndev);
+			napi_enable(&fep->napi);
 			fep->link = phy_dev->link;
 			status_change = 1;
 		}
-- 
1.8.3.1
