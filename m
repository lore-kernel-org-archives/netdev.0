From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 1/8] amd-xgbe: Add a read memory barrier to
 Tx/Rx path
Date: Thu, 20 Nov 2014 11:03:26 -0600
Message-ID: <20141120170326.15397.96332.stgit@tlendack-t1.amdoffice.net>
References: <20141120170320.15397.10583.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0132.outbound.protection.outlook.com ([157.56.110.132]:8096
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756934AbaKTRDd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Nov 2014 12:03:33 -0500
In-Reply-To: <20141120170320.15397.10583.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a read memory barrier to the Tx and Rx paths where the ownership
bit is checked to be sure that all descriptor fields are read after
having read the ownership bit for the descriptor.

This has not been an issue to date, but it's a good safe-guard to have.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c |    3 +++
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c |    4 ++++
 2 files changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index f6014d3..9b1d9fa 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -1558,6 +1558,9 @@ static int xgbe_dev_read(struct xgbe_channel *channel)
 	if (XGMAC_GET_BITS_LE(rdesc->desc3, RX_NORMAL_DESC3, OWN))
 		return 1;
 
+	/* Make sure descriptor fields are read after reading the OWN bit */
+	rmb();
+
 #ifdef XGMAC_ENABLE_RX_DESC_DUMP
 	xgbe_dump_rx_desc(ring, rdesc, ring->cur);
 #endif
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 0544931..eebb787 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -1791,6 +1791,10 @@ static int xgbe_tx_poll(struct xgbe_channel *channel)
 		if (!hw_if->tx_complete(rdesc))
 			break;
 
+		/* Make sure descriptor fields are read after reading the OWN
+		 * bit */
+		rmb();
+
 #ifdef XGMAC_ENABLE_TX_DESC_DUMP
 		xgbe_dump_tx_desc(ring, ring->dirty, 1, 0);
 #endif
