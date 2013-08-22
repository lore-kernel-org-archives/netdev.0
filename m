From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net] be2net: fix disabling TX in be_close()
Date: Thu, 22 Aug 2013 12:23:41 +0530
Message-ID: <1377154421-32013-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:4425 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753620Ab3HVGtw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 02:49:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit fba875591 ("disable TX in be_close()") disabled TX in be_close()
to protect be_xmit() from touching freed up queues in the AER recovery
flow.  But, TX must be disabled *before* cleaning up TX completions in
the close() path, not after. This allows be_tx_compl_clean() to free up
all TX-req skbs that were notified to the HW.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
Re-sending the patch with summary line of the commit referenced in
the change log.

 drivers/net/ethernet/emulex/benet/be_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

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
1.7.1
