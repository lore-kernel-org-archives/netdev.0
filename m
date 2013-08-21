From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH] be2net: fix disabling TX in be_close()
Date: Wed, 21 Aug 2013 15:52:14 +0530
Message-ID: <1377080534-19509-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:55446 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751611Ab3HUKSc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 06:18:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit fba875591 disabled TX in be_close() to protect be_xmit() from
touching freed up queues in the AER recovery flow.
But, TX must be disabled *before* cleaning up TX completions in the
close() path, not after. This allows be_tx_compl_clean() to free up
all TX-req skbs that were notified to the HW.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 181edb5..4559c35 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2563,8 +2563,8 @@ static int be_close(struct net_device *netdev)
 	/* Wait for all pending tx completions to arrive so that
 	 * all tx skbs are freed.
 	 */
-	be_tx_compl_clean(adapter);
 	netif_tx_disable(netdev);
+	be_tx_compl_clean(adapter);
 
 	be_rx_qs_destroy(adapter);
 
-- 
1.8.3.4
