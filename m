From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next 5/8] liquidio: moved liquidio_napi_drv_callback to
 lio_core.c
Date: Fri, 11 Aug 2017 18:29:15 -0700
Message-ID: <20170812012915.GA2575@felix-thinkpad.cavium.com>
References: <20170812012818.GA2505@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        intiyaz.basha@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0048.outbound.protection.outlook.com ([104.47.37.48]:21955
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752016AbdHLB3W (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 11 Aug 2017 21:29:22 -0400
Content-Disposition: inline
In-Reply-To: <20170812012818.GA2505@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Intiyaz Basha <intiyaz.basha@cavium.com>

Moving common liquidio_napi_drv_callback to lio_core.c

Signed-off-by: Intiyaz Basha <intiyaz.basha@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_core.c    | 39 ++++++++++++++++++++++
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 38 ---------------------
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 13 +-------
 .../net/ethernet/cavium/liquidio/octeon_network.h  |  1 +
 4 files changed, 41 insertions(+), 50 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_core.c b/drivers/net/ethernet/cavium/liquidio/lio_core.c
index b0b246e..8cba927 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_core.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_core.c
@@ -581,3 +581,42 @@ liquidio_push_packet(u32 octeon_id __attribute__((unused)),
 		recv_buffer_free(skb);
 	}
 }
+
+/**
+ * \brief wrapper for calling napi_schedule
+ * @param param parameters to pass to napi_schedule
+ *
+ * Used when scheduling on different CPUs
+ */
+static void napi_schedule_wrapper(void *param)
+{
+	struct napi_struct *napi = param;
+
+	napi_schedule(napi);
+}
+
+/**
+ * \brief callback when receive interrupt occurs and we are in NAPI mode
+ * @param arg pointer to octeon output queue
+ */
+void liquidio_napi_drv_callback(void *arg)
+{
+	struct octeon_device *oct;
+	struct octeon_droq *droq = arg;
+	int this_cpu = smp_processor_id();
+
+	oct = droq->oct_dev;
+
+	if (OCTEON_CN23XX_PF(oct) || OCTEON_CN23XX_VF(oct) ||
+	    droq->cpu_id == this_cpu) {
+		napi_schedule_irqoff(&droq->napi);
+	} else {
+		struct call_single_data *csd = &droq->csd;
+
+		csd->func = napi_schedule_wrapper;
+		csd->info = &droq->napi;
+		csd->flags = 0;
+
+		smp_call_function_single_async(droq->cpu_id, csd);
+	}
+}
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 68a94c4..4241949 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -2229,44 +2229,6 @@ static void if_cfg_callback(struct octeon_device *oct,
 }
 
 /**
- * \brief wrapper for calling napi_schedule
- * @param param parameters to pass to napi_schedule
- *
- * Used when scheduling on different CPUs
- */
-static void napi_schedule_wrapper(void *param)
-{
-	struct napi_struct *napi = param;
-
-	napi_schedule(napi);
-}
-
-/**
- * \brief callback when receive interrupt occurs and we are in NAPI mode
- * @param arg pointer to octeon output queue
- */
-static void liquidio_napi_drv_callback(void *arg)
-{
-	struct octeon_device *oct;
-	struct octeon_droq *droq = arg;
-	int this_cpu = smp_processor_id();
-
-	oct = droq->oct_dev;
-
-	if (OCTEON_CN23XX_PF(oct) || droq->cpu_id == this_cpu) {
-		napi_schedule_irqoff(&droq->napi);
-	} else {
-		struct call_single_data *csd = &droq->csd;
-
-		csd->func = napi_schedule_wrapper;
-		csd->info = &droq->napi;
-		csd->flags = 0;
-
-		smp_call_function_single_async(droq->cpu_id, csd);
-	}
-}
-
-/**
  * \brief Entry point for NAPI polling
  * @param napi NAPI structure
  * @param budget maximum number of items to process
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index 013a861..2663bd6 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -1377,17 +1377,6 @@ static void if_cfg_callback(struct octeon_device *oct,
 }
 
 /**
- * \brief callback when receive interrupt occurs and we are in NAPI mode
- * @param arg pointer to octeon output queue
- */
-static void liquidio_vf_napi_drv_callback(void *arg)
-{
-	struct octeon_droq *droq = arg;
-
-	napi_schedule_irqoff(&droq->napi);
-}
-
-/**
  * \brief Entry point for NAPI polling
  * @param napi NAPI structure
  * @param budget maximum number of items to process
@@ -1473,7 +1462,7 @@ static int setup_io_queues(struct octeon_device *octeon_dev, int ifidx)
 	droq_ops.farg = netdev;
 
 	droq_ops.poll_mode = 1;
-	droq_ops.napi_fn = liquidio_vf_napi_drv_callback;
+	droq_ops.napi_fn = liquidio_napi_drv_callback;
 	cpu_id = 0;
 	cpu_id_modulus = num_present_cpus();
 
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_network.h b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
index 5d78fd6..076fdfc 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_network.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
@@ -484,4 +484,5 @@ liquidio_push_packet(u32 octeon_id __attribute__((unused)),
 		     union octeon_rh *rh,
 		     void *param,
 		     void *arg);
+void liquidio_napi_drv_callback(void *arg);
 #endif
-- 
2.9.0
