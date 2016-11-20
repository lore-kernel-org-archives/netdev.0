From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: [PATCH net 04/18] net/ena: reduce the severity of ena printouts
Date: Sun, 20 Nov 2016 10:45:33 +0200
Message-ID: <1479631547-29354-5-git-send-email-netanel@annapurnalabs.com>
References: <1479631547-29354-1-git-send-email-netanel@annapurnalabs.com>
Cc: Netanel Belgazal <netanel@annapurnalabs.com>, dwmw@amazon.com,
        zorik@annapurnalabs.com, alex@annapurnalabs.com,
        saeed@annapurnalabs.com, msw@amazon.com, aliguori@amazon.com,
        nafea@annapurnalabs.com
To: linux-kernel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479631547-29354-1-git-send-email-netanel@annapurnalabs.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>
---
 drivers/net/ethernet/amazon/ena/ena_com.c    | 27 +++++++++++++++++----------
 drivers/net/ethernet/amazon/ena/ena_netdev.c | 14 +++++++++++---
 2 files changed, 28 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_com.c b/drivers/net/ethernet/amazon/ena/ena_com.c
index 3066d9c..6bd2b9b 100644
--- a/drivers/net/ethernet/amazon/ena/ena_com.c
+++ b/drivers/net/ethernet/amazon/ena/ena_com.c
@@ -784,7 +784,7 @@ static int ena_com_get_feature_ex(struct ena_com_dev *ena_dev,
 	int ret;
 
 	if (!ena_com_check_supported_feature_id(ena_dev, feature_id)) {
-		pr_info("Feature %d isn't supported\n", feature_id);
+		pr_debug("Feature %d isn't supported\n", feature_id);
 		return -EPERM;
 	}
 
@@ -1126,7 +1126,13 @@ int ena_com_execute_admin_command(struct ena_com_admin_queue *admin_queue,
 	comp_ctx = ena_com_submit_admin_cmd(admin_queue, cmd, cmd_size,
 					    comp, comp_size);
 	if (unlikely(IS_ERR(comp_ctx))) {
-		pr_err("Failed to submit command [%ld]\n", PTR_ERR(comp_ctx));
+		if (comp_ctx == ERR_PTR(-ENODEV))
+			pr_debug("Failed to submit command [%ld]\n",
+				 PTR_ERR(comp_ctx));
+		else
+			pr_err("Failed to submit command [%ld]\n",
+			       PTR_ERR(comp_ctx));
+
 		return PTR_ERR(comp_ctx);
 	}
 
@@ -1895,7 +1901,7 @@ int ena_com_set_dev_mtu(struct ena_com_dev *ena_dev, int mtu)
 	int ret;
 
 	if (!ena_com_check_supported_feature_id(ena_dev, ENA_ADMIN_MTU)) {
-		pr_info("Feature %d isn't supported\n", ENA_ADMIN_MTU);
+		pr_debug("Feature %d isn't supported\n", ENA_ADMIN_MTU);
 		return -EPERM;
 	}
 
@@ -1948,8 +1954,8 @@ int ena_com_set_hash_function(struct ena_com_dev *ena_dev)
 
 	if (!ena_com_check_supported_feature_id(ena_dev,
 						ENA_ADMIN_RSS_HASH_FUNCTION)) {
-		pr_info("Feature %d isn't supported\n",
-			ENA_ADMIN_RSS_HASH_FUNCTION);
+		pr_debug("Feature %d isn't supported\n",
+			 ENA_ADMIN_RSS_HASH_FUNCTION);
 		return -EPERM;
 	}
 
@@ -2112,7 +2118,8 @@ int ena_com_set_hash_ctrl(struct ena_com_dev *ena_dev)
 
 	if (!ena_com_check_supported_feature_id(ena_dev,
 						ENA_ADMIN_RSS_HASH_INPUT)) {
-		pr_info("Feature %d isn't supported\n", ENA_ADMIN_RSS_HASH_INPUT);
+		pr_debug("Feature %d isn't supported\n",
+			 ENA_ADMIN_RSS_HASH_INPUT);
 		return -EPERM;
 	}
 
@@ -2270,8 +2277,8 @@ int ena_com_indirect_table_set(struct ena_com_dev *ena_dev)
 
 	if (!ena_com_check_supported_feature_id(
 		    ena_dev, ENA_ADMIN_RSS_REDIRECTION_TABLE_CONFIG)) {
-		pr_info("Feature %d isn't supported\n",
-			ENA_ADMIN_RSS_REDIRECTION_TABLE_CONFIG);
+		pr_debug("Feature %d isn't supported\n",
+			 ENA_ADMIN_RSS_REDIRECTION_TABLE_CONFIG);
 		return -EPERM;
 	}
 
@@ -2542,8 +2549,8 @@ int ena_com_init_interrupt_moderation(struct ena_com_dev *ena_dev)
 
 	if (rc) {
 		if (rc == -EPERM) {
-			pr_info("Feature %d isn't supported\n",
-				ENA_ADMIN_INTERRUPT_MODERATION);
+			pr_debug("Feature %d isn't supported\n",
+				 ENA_ADMIN_INTERRUPT_MODERATION);
 			rc = 0;
 		} else {
 			pr_err("Failed to get interrupt moderation admin cmd. rc: %d\n",
diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
index e3acf76..7247abb 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
@@ -566,6 +566,7 @@ static void ena_free_all_rx_bufs(struct ena_adapter *adapter)
  */
 static void ena_free_tx_bufs(struct ena_ring *tx_ring)
 {
+	bool print_once = true;
 	u32 i;
 
 	for (i = 0; i < tx_ring->ring_size; i++) {
@@ -577,9 +578,16 @@ static void ena_free_tx_bufs(struct ena_ring *tx_ring)
 		if (!tx_info->skb)
 			continue;
 
-		netdev_notice(tx_ring->netdev,
-			      "free uncompleted tx skb qid %d idx 0x%x\n",
-			      tx_ring->qid, i);
+		if (print_once) {
+			netdev_notice(tx_ring->netdev,
+				      "free uncompleted tx skb qid %d idx 0x%x\n",
+				      tx_ring->qid, i);
+			print_once = false;
+		} else {
+			netdev_dbg(tx_ring->netdev,
+				   "free uncompleted tx skb qid %d idx 0x%x\n",
+				   tx_ring->qid, i);
+		}
 
 		ena_buf = tx_info->bufs;
 		dma_unmap_single(tx_ring->dev,
-- 
1.9.1
