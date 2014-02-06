From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH-net] drivers/net: fix build warning in ethernet/sfc/tx.c
Date: Thu, 6 Feb 2014 11:45:12 -0500
Message-ID: <1391705112-27869-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-net-drivers@solarflare.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Jon Cooper <jcooper@solarflare.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:38608 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751651AbaBFQwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 11:52:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit ee45fd92c739db5b7950163d91dfe5f016af6d24 ("sfc: Use TX PIO
for sufficiently small packets") introduced the following warning:

drivers/net/ethernet/sfc/tx.c: In function 'efx_enqueue_skb':
drivers/net/ethernet/sfc/tx.c:432:1: warning: label 'finish_packet' defined but not used

Stick the label inside the same #ifdef that the code which calls
it uses.  Note that this is only seen for arch that do not set
ARCH_HAS_IOREMAP_WC, such as arm, mips, sparc, ..., as the others
enable the write combining code and hence use the label.

Cc: Jon Cooper <jcooper@solarflare.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/ethernet/sfc/tx.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index c49d1fb16965..75d11fa4eb0a 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -429,7 +429,9 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
 	}
 
 	/* Transfer ownership of the skb to the final buffer */
+#ifdef EFX_USE_PIO
 finish_packet:
+#endif
 	buffer->skb = skb;
 	buffer->flags = EFX_TX_BUF_SKB | dma_flags;
 
-- 
1.8.5.2
