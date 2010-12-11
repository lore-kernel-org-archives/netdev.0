From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH 1/4] s2io: rx_ring_sz bounds checking
Date: Fri, 10 Dec 2010 19:40:01 -0600
Message-ID: <1292031604-16628-1-git-send-email-jon.mason@exar.com>
Cc: netdev@vger.kernel.org,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Ram Vepa <ram.vepa@exar.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:61969 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753200Ab0LKBkL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 20:40:11 -0500
Received: by yxt3 with SMTP id 3so2420114yxt.19
        for <netdev@vger.kernel.org>; Fri, 10 Dec 2010 17:40:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

modparm rx_ring_sz can be set to be greater than the maximum allowable
number of blocks.  This results in an array overrun when probing the
driver, and causes memory corruption.

Also, the MAX_RX_DESC_1 multiply the max number of rings by max number
of blocker per ring by 127, but the driver does the same calculation
with 127+1.  This results in the possibility of the value being set
being larger than the maximum allowable value.

Finally, clean-up the s2io_ethtool_gringparam code to be more
intuitive.

Signed-off-by: Jon Mason <jon.mason@exar.com>
---
 drivers/net/s2io.c |   40 ++++++++++++++++++++++++----------------
 drivers/net/s2io.h |    5 ++---
 2 files changed, 26 insertions(+), 19 deletions(-)

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 0f4219c..a6d3eaf 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -5568,30 +5568,27 @@ static void s2io_ethtool_gringparam(struct net_device *dev,
 	struct s2io_nic *sp = netdev_priv(dev);
 	int i, tx_desc_count = 0, rx_desc_count = 0;
 
-	if (sp->rxd_mode == RXD_MODE_1)
+	if (sp->rxd_mode == RXD_MODE_1) {
 		ering->rx_max_pending = MAX_RX_DESC_1;
-	else if (sp->rxd_mode == RXD_MODE_3B)
+		ering->rx_jumbo_max_pending = MAX_RX_DESC_1;
+	} else {
 		ering->rx_max_pending = MAX_RX_DESC_2;
+		ering->rx_jumbo_max_pending = MAX_RX_DESC_2;
+	}
 
+	ering->rx_mini_max_pending = 0;
 	ering->tx_max_pending = MAX_TX_DESC;
-	for (i = 0 ; i < sp->config.tx_fifo_num ; i++)
-		tx_desc_count += sp->config.tx_cfg[i].fifo_len;
 
-	DBG_PRINT(INFO_DBG, "max txds: %d\n", sp->config.max_txds);
-	ering->tx_pending = tx_desc_count;
-	rx_desc_count = 0;
-	for (i = 0 ; i < sp->config.rx_ring_num ; i++)
+	for (i = 0; i < sp->config.rx_ring_num; i++)
 		rx_desc_count += sp->config.rx_cfg[i].num_rxd;
-
 	ering->rx_pending = rx_desc_count;
-
-	ering->rx_mini_max_pending = 0;
-	ering->rx_mini_pending = 0;
-	if (sp->rxd_mode == RXD_MODE_1)
-		ering->rx_jumbo_max_pending = MAX_RX_DESC_1;
-	else if (sp->rxd_mode == RXD_MODE_3B)
-		ering->rx_jumbo_max_pending = MAX_RX_DESC_2;
 	ering->rx_jumbo_pending = rx_desc_count;
+	ering->rx_mini_pending = 0;
+
+	for (i = 0; i < sp->config.tx_fifo_num; i++)
+		tx_desc_count += sp->config.tx_cfg[i].fifo_len;
+	ering->tx_pending = tx_desc_count;
+	DBG_PRINT(INFO_DBG, "max txds: %d\n", sp->config.max_txds);
 }
 
 /**
@@ -7692,6 +7689,8 @@ static void s2io_init_pci(struct s2io_nic *sp)
 static int s2io_verify_parm(struct pci_dev *pdev, u8 *dev_intr_type,
 			    u8 *dev_multiq)
 {
+	int i;
+
 	if ((tx_fifo_num > MAX_TX_FIFOS) || (tx_fifo_num < 1)) {
 		DBG_PRINT(ERR_DBG, "Requested number of tx fifos "
 			  "(%d) not supported\n", tx_fifo_num);
@@ -7750,6 +7749,15 @@ static int s2io_verify_parm(struct pci_dev *pdev, u8 *dev_intr_type,
 		DBG_PRINT(ERR_DBG, "Defaulting to 1-buffer mode\n");
 		rx_ring_mode = 1;
 	}
+
+	for (i = 0; i < MAX_RX_RINGS; i++)
+		if (rx_ring_sz[i] > MAX_RX_BLOCKS_PER_RING) {
+			DBG_PRINT(ERR_DBG, "Requested rx ring size not "
+				  "supported\nDefaulting to %d\n",
+				  MAX_RX_BLOCKS_PER_RING);
+			rx_ring_sz[i] = MAX_RX_BLOCKS_PER_RING;
+		}
+
 	return SUCCESS;
 }
 
diff --git a/drivers/net/s2io.h b/drivers/net/s2io.h
index 00b8614..1671443 100644
--- a/drivers/net/s2io.h
+++ b/drivers/net/s2io.h
@@ -355,9 +355,8 @@ struct stat_block {
 #define FIFO_OTHER_MAX_NUM			1
 
 
-#define MAX_RX_DESC_1  (MAX_RX_RINGS * MAX_RX_BLOCKS_PER_RING * 127 )
-#define MAX_RX_DESC_2  (MAX_RX_RINGS * MAX_RX_BLOCKS_PER_RING * 85 )
-#define MAX_RX_DESC_3  (MAX_RX_RINGS * MAX_RX_BLOCKS_PER_RING * 85 )
+#define MAX_RX_DESC_1  (MAX_RX_RINGS * MAX_RX_BLOCKS_PER_RING * 128)
+#define MAX_RX_DESC_2  (MAX_RX_RINGS * MAX_RX_BLOCKS_PER_RING * 86)
 #define MAX_TX_DESC    (MAX_AVAILABLE_TXDS)
 
 /* FIFO mappings for all possible number of fifos configured */
-- 
1.7.0.4

