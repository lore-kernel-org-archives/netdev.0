From: Madalin Bucur <madalin.bucur@freescale.com>
Subject: [PATCH RFC 03/10] dpaa_eth: add configurable bpool thresholds
Date: Wed, 1 Apr 2015 19:19:49 +0300
Message-ID: <1427905196-27778-2-git-send-email-madalin.bucur@freescale.com>
References: <1427905196-27778-1-git-send-email-madalin.bucur@freescale.com>
Reply-To: <madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
	Madalin Bucur <madalin.bucur@freescale.com>
To: <netdev@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1427905196-27778-1-git-send-email-madalin.bucur@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow the user to tweak the refill threshold and the total number
of buffers in the buffer pool. The provided values are for one CPU.

Signed-off-by: Madalin Bucur <madalin.bucur@freescale.com>
---
 drivers/net/ethernet/freescale/dpaa/Kconfig       | 20 ++++++++++++++++++++
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c    |  2 +-
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.h    |  3 ---
 drivers/net/ethernet/freescale/dpaa/dpaa_eth_sg.c |  6 +++---
 4 files changed, 24 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/freescale/dpaa/Kconfig b/drivers/net/ethernet/freescale/dpaa/Kconfig
index 7ef703c..9db7d25 100644
--- a/drivers/net/ethernet/freescale/dpaa/Kconfig
+++ b/drivers/net/ethernet/freescale/dpaa/Kconfig
@@ -11,6 +11,26 @@ menuconfig FSL_DPAA_ETH
 
 if FSL_DPAA_ETH
 
+config FSL_DPAA_ETH_MAX_BUF_COUNT
+	int "Maximum nuber of buffers in private bpool"
+	depends on FSL_DPAA_ETH
+	range 64 2048
+	default "128"
+	---help---
+	  The maximum number of buffers to be by default allocated in the DPAA-Ethernet private port's
+	  buffer pool. One needn't normally modify this, as it has probably been tuned for performance
+	  already. This cannot be lower than DPAA_ETH_REFILL_THRESHOLD.
+
+config FSL_DPAA_ETH_REFILL_THRESHOLD
+	int "Private bpool refill threshold"
+	depends on FSL_DPAA_ETH
+	range 32 FSL_DPAA_ETH_MAX_BUF_COUNT
+	default "80"
+	---help---
+	  The DPAA-Ethernet driver will start replenishing buffer pools whose count
+	  falls below this threshold. This must be related to DPAA_ETH_MAX_BUF_COUNT. One needn't normally
+	  modify this value unless one has very specific performance reasons.
+
 config FSL_DPAA_CS_THRESHOLD_1G
 	hex "Egress congestion threshold on 1G ports"
 	depends on FSL_DPAA_ETH
diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
index ee65ca2..9e78371 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
@@ -481,7 +481,7 @@ dpa_priv_bp_probe(struct device *dev)
 	}
 
 	dpa_bp->percpu_count = devm_alloc_percpu(dev, *dpa_bp->percpu_count);
-	dpa_bp->target_count = FSL_DPAA_ETH_MAX_BUF_COUNT;
+	dpa_bp->target_count = CONFIG_FSL_DPAA_ETH_MAX_BUF_COUNT;
 
 	dpa_bp->seed_cb = dpa_bp_priv_seed;
 	dpa_bp->free_buf_cb = _dpa_bp_free_pf;
diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h
index b643c52..5f3157d 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h
@@ -126,9 +126,6 @@ struct dpa_buffer_layout_s {
 
 #define DPAA_ETH_RX_QUEUES	128
 
-#define FSL_DPAA_ETH_MAX_BUF_COUNT	128
-#define FSL_DPAA_ETH_REFILL_THRESHOLD	80
-
 /* More detailed FQ types - used for fine-grained WQ assignments */
 enum dpa_fq_type {
 	FQ_TYPE_RX_DEFAULT = 1, /* Rx Default FQs */
diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth_sg.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth_sg.c
index ef3117e..1b3dc28 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth_sg.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth_sg.c
@@ -153,7 +153,7 @@ int dpaa_eth_refill_bpools(struct dpa_bp *dpa_bp, int *countptr)
 	int count = *countptr;
 	int new_bufs;
 
-	if (unlikely(count < FSL_DPAA_ETH_REFILL_THRESHOLD)) {
+	if (unlikely(count < CONFIG_FSL_DPAA_ETH_REFILL_THRESHOLD)) {
 		do {
 			new_bufs = _dpa_bp_add_8_bufs(dpa_bp);
 			if (unlikely(!new_bufs)) {
@@ -164,10 +164,10 @@ int dpaa_eth_refill_bpools(struct dpa_bp *dpa_bp, int *countptr)
 				break;
 			}
 			count += new_bufs;
-		} while (count < FSL_DPAA_ETH_MAX_BUF_COUNT);
+		} while (count < CONFIG_FSL_DPAA_ETH_MAX_BUF_COUNT);
 
 		*countptr = count;
-		if (unlikely(count < FSL_DPAA_ETH_MAX_BUF_COUNT))
+		if (unlikely(count < CONFIG_FSL_DPAA_ETH_MAX_BUF_COUNT))
 			return -ENOMEM;
 	}
 
-- 
1.7.11.7
