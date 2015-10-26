From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net] amd-xgbe: Fix race between access of desc and desc index
Date: Mon, 26 Oct 2015 17:13:54 -0500
Message-ID: <20151026221354.927.9237.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0079.outbound.protection.outlook.com ([207.46.100.79]:35568
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752110AbbJZWOB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Oct 2015 18:14:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During Tx cleanup it's still possible for the descriptor data to be
read ahead of the descriptor index. A memory barrier is required between
the read of the descriptor index and the start of the Tx cleanup loop.
This allows a change to a lighter-weight barrier in the Tx transmit
routine just before updating the current descriptor index.

Since the memory barrier does result in extra overhead on arm64, keep
the previous change to not chase the current descriptor value. This
prevents the execution of the barrier for each loop performed.

Suggested-by: Alexander Duyck <alexander.duyck@gmail.com>
Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c |    2 +-
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c |    4 ++++
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index e9ab8b9..f672dba 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -1595,7 +1595,7 @@ static void xgbe_dev_xmit(struct xgbe_channel *channel)
 				  packet->rdesc_count, 1);
 
 	/* Make sure ownership is written to the descriptor */
-	wmb();
+	smp_wmb();
 
 	ring->cur = cur_index + 1;
 	if (!packet->skb->xmit_more ||
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index d2b77d9..dde0486 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -1816,6 +1816,10 @@ static int xgbe_tx_poll(struct xgbe_channel *channel)
 		return 0;
 
 	cur = ring->cur;
+
+	/* Be sure we get ring->cur before accessing descriptor data */
+	smp_rmb();
+
 	txq = netdev_get_tx_queue(netdev, channel->queue_index);
 
 	while ((processed < XGBE_TX_DESC_MAX_PROC) &&
