From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 05/14] be2net: fix return status of some ethtool methods
Date: Thu, 17 Jul 2014 16:20:23 +0530
Message-ID: <1405594232-30818-6-git-send-email-sathya.perla@emulex.com>
References: <1405594232-30818-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:9070 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756779AbaGQKsg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 06:48:36 -0400
In-Reply-To: <1405594232-30818-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

ethtool expects a -ve status value to be returned when a driver method
encounters an error. The driver was directly passing the
error status returned by FW (a positive value) to ethtool.
This patch fixes this by returning -EIO status in cases where FW returns
an error.
Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h         |    2 ++
 drivers/net/ethernet/emulex/benet/be_ethtool.c |   12 +++++++-----
 2 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index d3d871b..3e639e8 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -672,6 +672,8 @@ static inline void swap_dws(void *wrb, int len)
 #endif				/* __BIG_ENDIAN */
 }
 
+#define be_cmd_status(status)		(status > 0 ? -EIO : status)
+
 static inline u8 is_tcp_pkt(struct sk_buff *skb)
 {
 	u8 val = 0;
diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index e2da4d2..25f516d 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -643,7 +643,7 @@ be_set_pauseparam(struct net_device *netdev, struct ethtool_pauseparam *ecmd)
 	if (status)
 		dev_warn(&adapter->pdev->dev, "Pause param set failed.\n");
 
-	return status;
+	return be_cmd_status(status);
 }
 
 static int be_set_phys_id(struct net_device *netdev,
@@ -762,7 +762,7 @@ static int be_test_ddr_dma(struct be_adapter *adapter)
 err:
 	dma_free_coherent(&adapter->pdev->dev, ddrdma_cmd.size, ddrdma_cmd.va,
 			  ddrdma_cmd.dma);
-	return ret;
+	return be_cmd_status(ret);
 }
 
 static u64 be_loopback_test(struct be_adapter *adapter, u8 loopback_type,
@@ -885,7 +885,7 @@ static int be_read_eeprom(struct net_device *netdev,
 	dma_free_coherent(&adapter->pdev->dev, eeprom_cmd.size, eeprom_cmd.va,
 			  eeprom_cmd.dma);
 
-	return status;
+	return be_cmd_status(status);
 }
 
 static u32 be_get_msg_level(struct net_device *netdev)
@@ -1042,7 +1042,7 @@ static int be_set_rss_hash_opts(struct be_adapter *adapter,
 	if (!status)
 		adapter->rss_info.rss_flags = rss_flags;
 
-	return status;
+	return be_cmd_status(status);
 }
 
 static int be_set_rxnfc(struct net_device *netdev, struct ethtool_rxnfc *cmd)
@@ -1080,6 +1080,7 @@ static int be_set_channels(struct net_device  *netdev,
 			   struct ethtool_channels *ch)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
+	int status;
 
 	if (ch->rx_count || ch->tx_count || ch->other_count ||
 	    !ch->combined_count || ch->combined_count > be_max_qs(adapter))
@@ -1087,7 +1088,8 @@ static int be_set_channels(struct net_device  *netdev,
 
 	adapter->cfg_num_qs = ch->combined_count;
 
-	return be_update_queues(adapter);
+	status = be_update_queues(adapter);
+	return be_cmd_status(status);
 }
 
 static u32 be_get_rxfh_indir_size(struct net_device *netdev)
-- 
1.7.1
