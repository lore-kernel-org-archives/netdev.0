From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net-next] bnx2x: Resolving a possible dead-lock
 situation
Date: Tue, 23 Nov 2010 18:15:12 +0200
Message-ID: <1290528912.15453.3.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>,
	"netdev list" <netdev@vger.kernel.org>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1771 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753708Ab0KWQPt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Nov 2010 11:15:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a possible dead-lock situation between sch_direct_xmit() 
(called from soft_IRQ context) and bnx2x_tx_int() when called from 
an ethtool self-test flow (syscall context).

To prevent a dead-lock, disable bottom-halves on a local CPU when taking
a tx_lock from bnx2x_tx_int() (use __netif_tx_lock_bh(txq)).

The flow in the bnx2x_tx_int() where tx_lock is taken should be hit
very rarely thus performance penalty of this change should be minimal.

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_cmn.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index 94d5f59..5189788 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -144,14 +144,14 @@ int bnx2x_tx_int(struct bnx2x_fastpath *fp)
 		 * stops the queue
 		 */
 
-		__netif_tx_lock(txq, smp_processor_id());
+		__netif_tx_lock_bh(txq);
 
 		if ((netif_tx_queue_stopped(txq)) &&
 		    (bp->state == BNX2X_STATE_OPEN) &&
 		    (bnx2x_tx_avail(fp) >= MAX_SKB_FRAGS + 3))
 			netif_tx_wake_queue(txq);
 
-		__netif_tx_unlock(txq);
+		__netif_tx_unlock_bh(txq);
 	}
 	return 0;
 }
-- 
1.7.0.4




