From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 05/12] be2net: Add a dma_mapping_error counter in ethtool
Date: Mon, 1 Sep 2014 11:54:17 +0530
Message-ID: <1409552664-15990-6-git-send-email-sathya.perla@emulex.com>
References: <1409552664-15990-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:19158 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751251AbaIAGVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 02:21:55 -0400
In-Reply-To: <1409552664-15990-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

Add a dma_mapping_error counter to count the number of packets dropped
due to DMA mapping errors.

Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h         |    1 +
 drivers/net/ethernet/emulex/benet/be_ethtool.c |    2 ++
 drivers/net/ethernet/emulex/benet/be_main.c    |    3 ++-
 3 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index d491ac6..069bdda 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -323,6 +323,7 @@ struct be_rx_obj {
 struct be_drv_stats {
 	u32 be_on_die_temperature;
 	u32 eth_red_drops;
+	u32 dma_map_errors;
 	u32 rx_drops_no_pbuf;
 	u32 rx_drops_no_txpb;
 	u32 rx_drops_no_erx_descr;
diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index 3a7ade4..2fd3826 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -119,6 +119,8 @@ static const struct be_ethtool_stat et_stats[] = {
 	 * is more than 9018 bytes
 	 */
 	{DRVSTAT_INFO(rx_drops_mtu)},
+	/* Number of dma mapping errors */
+	{DRVSTAT_INFO(dma_map_errors)},
 	/* Number of packets dropped due to random early drop function */
 	{DRVSTAT_INFO(eth_red_drops)},
 	{DRVSTAT_INFO(be_on_die_temperature)},
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index e9658f7..c95998f 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -849,6 +849,7 @@ dma_err:
 		unmap_tx_frag(dev, wrb, map_single);
 		map_single = false;
 		copied -= wrb->frag_len;
+		adapter->drv_stats.dma_map_errors++;
 		queue_head_inc(txq);
 	}
 	return 0;
@@ -1877,7 +1878,7 @@ static void be_post_rx_frags(struct be_rx_obj *rxo, gfp_t gfp)
 			if (dma_mapping_error(dev, page_dmaaddr)) {
 				put_page(pagep);
 				pagep = NULL;
-				rx_stats(rxo)->rx_post_fail++;
+				adapter->drv_stats.dma_map_errors++;
 				break;
 			}
 			page_offset = 0;
-- 
1.7.1
