From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net-next] bnx2x: Disable local BHes to prevent a
 dead-lock situation
Date: Wed, 24 Nov 2010 15:45:10 +0200
Message-ID: <1290606310.25676.7.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>,
	"netdev list" <netdev@vger.kernel.org>,
	"Eric Dumazet" <eric.dumazet@gmail.com>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4205 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754685Ab0KXNp1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Nov 2010 08:45:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>

According to Eric's suggestion:
Disable local BHes to prevent a dead-lock situation between sch_direct_xmit()
(Soft_IRQ context) and bnx2x_tx_int (called by bnx2x_run_loopback() - syscall
context), as both are taking a netif_tx_lock().

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
CCing Eric... :)

 drivers/net/bnx2x/bnx2x_ethtool.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_ethtool.c b/drivers/net/bnx2x/bnx2x_ethtool.c
index d02ffbd..0301278 100644
--- a/drivers/net/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/bnx2x/bnx2x_ethtool.c
@@ -1499,8 +1499,15 @@ static int bnx2x_run_loopback(struct bnx2x *bp, int loopback_mode, u8 link_up)
 	 * updates that have been performed while interrupts were
 	 * disabled.
 	 */
-	if (bp->common.int_block == INT_BLOCK_IGU)
+	if (bp->common.int_block == INT_BLOCK_IGU) {
+		/* Disable local BHes to prevent a dead-lock situation between
+		 * sch_direct_xmit() and bnx2x_run_loopback() (calling
+		 * bnx2x_tx_int()), as both are taking netif_tx_lock().
+		 */
+		local_bh_disable();
 		bnx2x_tx_int(fp_tx);
+		local_bh_enable();
+	}
 
 	rx_idx = le16_to_cpu(*fp_rx->rx_cons_sb);
 	if (rx_idx != rx_start_idx + num_pkts)
-- 
1.7.0.4




