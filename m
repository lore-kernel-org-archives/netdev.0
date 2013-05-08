From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH 4/4] be2net: disable TX in be_close()
Date: Wed, 8 May 2013 17:35:50 +0530
Message-ID: <1368014750-25065-5-git-send-email-sathya.perla@emulex.com>
References: <1368014750-25065-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:10935 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755334Ab3EHMDk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 May 2013 08:03:40 -0400
In-Reply-To: <1368014750-25065-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

be_close() followed by be_clear() is called as a part of cleanup in the
EEH/AER flow.  This patch stops TX in be_close() before cleaning/freeing
up the TX queues in be_clear(). This prevents be_xmit() from being called
while TX queues no longer exist.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 792d838..a444110 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2559,6 +2559,7 @@ static int be_close(struct net_device *netdev)
 	 * all tx skbs are freed.
 	 */
 	be_tx_compl_clean(adapter);
+	netif_tx_disable(netdev);
 
 	be_rx_qs_destroy(adapter);
 
@@ -2667,6 +2668,7 @@ static int be_open(struct net_device *netdev)
 	if (!status)
 		be_link_status_update(adapter, link_status);
 
+	netif_tx_start_all_queues(netdev);
 	be_roce_dev_open(adapter);
 	return 0;
 err:
-- 
1.7.1
