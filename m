From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next 1/8] liquidio: moved wait_for_pending_requests to
 octeon_network.h
Date: Fri, 11 Aug 2017 18:28:54 -0700
Message-ID: <20170812012854.GA2523@felix-thinkpad.cavium.com>
References: <20170812012818.GA2505@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        intiyaz.basha@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0051.outbound.protection.outlook.com ([104.47.38.51]:23532
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751770AbdHLB3G (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 11 Aug 2017 21:29:06 -0400
Content-Disposition: inline
In-Reply-To: <20170812012818.GA2505@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Intiyaz Basha <intiyaz.basha@cavium.com>

Moving common function wait_for_pending_requests to octeon_network.h

Signed-off-by: Intiyaz Basha <intiyaz.basha@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 .../ethernet/cavium/liquidio/cn23xx_vf_device.h    |  2 --
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 26 --------------------
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 28 +---------------------
 .../net/ethernet/cavium/liquidio/octeon_device.h   |  2 ++
 .../net/ethernet/cavium/liquidio/octeon_network.h  | 26 ++++++++++++++++++++
 5 files changed, 29 insertions(+), 55 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.h b/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.h
index 3f98c73..2d06097 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.h
@@ -36,8 +36,6 @@ struct octeon_cn23xx_vf {
 
 #define CN23XX_MAILBOX_MSGPARAM_SIZE		6
 
-#define MAX_VF_IP_OP_PENDING_PKT_COUNT		100
-
 void cn23xx_vf_ask_pf_to_do_flr(struct octeon_device *oct);
 
 int cn23xx_octeon_pfvf_handshake(struct octeon_device *oct);
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 8bf6dfc..b20d13f 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -273,32 +273,6 @@ static void force_io_queues_off(struct octeon_device *oct)
 }
 
 /**
- * \brief wait for all pending requests to complete
- * @param oct Pointer to Octeon device
- *
- * Called during shutdown sequence
- */
-static int wait_for_pending_requests(struct octeon_device *oct)
-{
-	int i, pcount = 0;
-
-	for (i = 0; i < 100; i++) {
-		pcount =
-			atomic_read(&oct->response_list
-				[OCTEON_ORDERED_SC_LIST].pending_req_count);
-		if (pcount)
-			schedule_timeout_uninterruptible(HZ / 10);
-		else
-			break;
-	}
-
-	if (pcount)
-		return 1;
-
-	return 0;
-}
-
-/**
  * \brief Cause device to go quiet so it can be safely removed/reset/etc
  * @param oct Pointer to Octeon device
  */
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index c6f52f2..17623ed 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -123,7 +123,7 @@ static int lio_wait_for_oq_pkts(struct octeon_device *oct)
 {
 	struct octeon_device_priv *oct_priv =
 	    (struct octeon_device_priv *)oct->priv;
-	int retry = MAX_VF_IP_OP_PENDING_PKT_COUNT;
+	int retry = MAX_IO_PENDING_PKT_COUNT;
 	int pkt_cnt = 0, pending_pkts;
 	int i;
 
@@ -148,32 +148,6 @@ static int lio_wait_for_oq_pkts(struct octeon_device *oct)
 }
 
 /**
- * \brief wait for all pending requests to complete
- * @param oct Pointer to Octeon device
- *
- * Called during shutdown sequence
- */
-static int wait_for_pending_requests(struct octeon_device *oct)
-{
-	int i, pcount = 0;
-
-	for (i = 0; i < MAX_VF_IP_OP_PENDING_PKT_COUNT; i++) {
-		pcount = atomic_read(
-		    &oct->response_list[OCTEON_ORDERED_SC_LIST]
-			 .pending_req_count);
-		if (pcount)
-			schedule_timeout_uninterruptible(HZ / 10);
-		else
-			break;
-	}
-
-	if (pcount)
-		return 1;
-
-	return 0;
-}
-
-/**
  * \brief Cause device to go quiet so it can be safely removed/reset/etc
  * @param oct Pointer to Octeon device
  */
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.h b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
index b014e6a..0ad58f9 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
@@ -568,6 +568,8 @@ struct octeon_device {
 #define CHIP_CONF(oct, TYPE)             \
 	(((struct octeon_ ## TYPE  *)((oct)->chip))->conf)
 
+#define MAX_IO_PENDING_PKT_COUNT 100
+
 /*------------------ Function Prototypes ----------------------*/
 
 /** Initialize device list memory */
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_network.h b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
index ec8504b..043f6e6 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_network.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
@@ -448,4 +448,30 @@ static inline void ifstate_reset(struct lio *lio, int state_flag)
 	atomic_set(&lio->ifstate, (atomic_read(&lio->ifstate) & ~(state_flag)));
 }
 
+/**
+ * \brief wait for all pending requests to complete
+ * @param oct Pointer to Octeon device
+ *
+ * Called during shutdown sequence
+ */
+static inline int wait_for_pending_requests(struct octeon_device *oct)
+{
+	int i, pcount = 0;
+
+	for (i = 0; i < MAX_IO_PENDING_PKT_COUNT; i++) {
+		pcount = atomic_read(
+		    &oct->response_list[OCTEON_ORDERED_SC_LIST]
+			 .pending_req_count);
+		if (pcount)
+			schedule_timeout_uninterruptible(HZ / 10);
+		else
+			break;
+	}
+
+	if (pcount)
+		return 1;
+
+	return 0;
+}
+
 #endif
-- 
2.9.0
