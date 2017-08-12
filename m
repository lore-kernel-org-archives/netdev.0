From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next 3/8] liquidio: moved octeon_setup_droq to lio_core.c
Date: Fri, 11 Aug 2017 18:29:05 -0700
Message-ID: <20170812012905.GA2549@felix-thinkpad.cavium.com>
References: <20170812012818.GA2505@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        intiyaz.basha@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0089.outbound.protection.outlook.com ([104.47.36.89]:11808
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751770AbdHLB3Q (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 11 Aug 2017 21:29:16 -0400
Content-Disposition: inline
In-Reply-To: <20170812012818.GA2505@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Intiyaz Basha <intiyaz.basha@cavium.com>

Moving common octeon_setup_droq to lio_core.c

Signed-off-by: Intiyaz Basha <intiyaz.basha@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_core.c    | 35 ++++++++++++++++++++
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 37 ----------------------
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 35 --------------------
 .../net/ethernet/cavium/liquidio/octeon_network.h  |  2 ++
 4 files changed, 37 insertions(+), 72 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_core.c b/drivers/net/ethernet/cavium/liquidio/lio_core.c
index b55ab75..90583ce 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_core.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_core.c
@@ -397,3 +397,38 @@ void lio_update_txq_status(struct octeon_device *oct, int iq_num)
 		netif_wake_queue(netdev);
 	}
 }
+
+/**
+ * \brief Setup output queue
+ * @param oct octeon device
+ * @param q_no which queue
+ * @param num_descs how many descriptors
+ * @param desc_size size of each descriptor
+ * @param app_ctx application context
+ */
+int octeon_setup_droq(struct octeon_device *oct, int q_no, int num_descs,
+		      int desc_size, void *app_ctx)
+{
+	int ret_val;
+
+	dev_dbg(&oct->pci_dev->dev, "Creating Droq: %d\n", q_no);
+	/* droq creation and local register settings. */
+	ret_val = octeon_create_droq(oct, q_no, num_descs, desc_size, app_ctx);
+	if (ret_val < 0)
+		return ret_val;
+
+	if (ret_val == 1) {
+		dev_dbg(&oct->pci_dev->dev, "Using default droq %d\n", q_no);
+		return 0;
+	}
+
+	/* Enable the droq queues */
+	octeon_set_droq_pkt_op(oct, q_no, 1);
+
+	/* Send Credit for Octeon Output queues. Credits are always
+	 * sent after the output queue is enabled.
+	 */
+	writel(oct->droq[q_no]->max_count, oct->droq[q_no]->pkts_credit_reg);
+
+	return ret_val;
+}
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index ba1b493..a814d58 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -2196,43 +2196,6 @@ static int load_firmware(struct octeon_device *oct)
 }
 
 /**
- * \brief Setup output queue
- * @param oct octeon device
- * @param q_no which queue
- * @param num_descs how many descriptors
- * @param desc_size size of each descriptor
- * @param app_ctx application context
- */
-static int octeon_setup_droq(struct octeon_device *oct, int q_no, int num_descs,
-			     int desc_size, void *app_ctx)
-{
-	int ret_val = 0;
-
-	dev_dbg(&oct->pci_dev->dev, "Creating Droq: %d\n", q_no);
-	/* droq creation and local register settings. */
-	ret_val = octeon_create_droq(oct, q_no, num_descs, desc_size, app_ctx);
-	if (ret_val < 0)
-		return ret_val;
-
-	if (ret_val == 1) {
-		dev_dbg(&oct->pci_dev->dev, "Using default droq %d\n", q_no);
-		return 0;
-	}
-	/* tasklet creation for the droq */
-
-	/* Enable the droq queues */
-	octeon_set_droq_pkt_op(oct, q_no, 1);
-
-	/* Send Credit for Octeon Output queues. Credits are always
-	 * sent after the output queue is enabled.
-	 */
-	writel(oct->droq[q_no]->max_count,
-	       oct->droq[q_no]->pkts_credit_reg);
-
-	return ret_val;
-}
-
-/**
  * \brief Callback for getting interface configuration
  * @param status status of request
  * @param buf pointer to resp structure
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index dd0265a..a6efd75 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -1345,41 +1345,6 @@ static void free_netsgbuf_with_resp(void *buf)
 }
 
 /**
- * \brief Setup output queue
- * @param oct octeon device
- * @param q_no which queue
- * @param num_descs how many descriptors
- * @param desc_size size of each descriptor
- * @param app_ctx application context
- */
-static int octeon_setup_droq(struct octeon_device *oct, int q_no, int num_descs,
-			     int desc_size, void *app_ctx)
-{
-	int ret_val;
-
-	dev_dbg(&oct->pci_dev->dev, "Creating Droq: %d\n", q_no);
-	/* droq creation and local register settings. */
-	ret_val = octeon_create_droq(oct, q_no, num_descs, desc_size, app_ctx);
-	if (ret_val < 0)
-		return ret_val;
-
-	if (ret_val == 1) {
-		dev_dbg(&oct->pci_dev->dev, "Using default droq %d\n", q_no);
-		return 0;
-	}
-
-	/* Enable the droq queues */
-	octeon_set_droq_pkt_op(oct, q_no, 1);
-
-	/* Send Credit for Octeon Output queues. Credits are always
-	 * sent after the output queue is enabled.
-	 */
-	writel(oct->droq[q_no]->max_count, oct->droq[q_no]->pkts_credit_reg);
-
-	return ret_val;
-}
-
-/**
  * \brief Callback for getting interface configuration
  * @param status status of request
  * @param buf pointer to resp structure
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_network.h b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
index 0e44ee1..b2bb34d 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_network.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
@@ -475,4 +475,6 @@ static inline int wait_for_pending_requests(struct octeon_device *oct)
 }
 
 void lio_update_txq_status(struct octeon_device *oct, int iq_num);
+int octeon_setup_droq(struct octeon_device *oct, int q_no, int num_descs,
+		      int desc_size, void *app_ctx);
 #endif
-- 
2.9.0
