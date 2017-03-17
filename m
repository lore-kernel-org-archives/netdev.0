From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: remove duplicate code
Date: Fri, 17 Mar 2017 10:50:05 -0700
Message-ID: <20170317175005.GA2276@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0062.outbound.protection.outlook.com ([104.47.38.62]:5056
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751101AbdCQSGG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 17 Mar 2017 14:06:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Satanand Burla <satananda.burla@cavium.com>

Remove code duplicated in PF and VF; define that code once only in a common
header file included by PF and VF.
 
Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 36 ----------------------
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 36 ----------------------
 .../net/ethernet/cavium/liquidio/octeon_network.h  | 36 ++++++++++++++++++++++
 3 files changed, 36 insertions(+), 72 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index ca529a7..7e9227c 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -60,12 +60,6 @@ MODULE_PARM_DESC(fw_type, "Type of firmware to be loaded. Default \"nic\"");
 
 static int ptp_enable = 1;
 
-/* Bit mask values for lio->ifstate */
-#define   LIO_IFSTATE_DROQ_OPS             0x01
-#define   LIO_IFSTATE_REGISTERED           0x02
-#define   LIO_IFSTATE_RUNNING              0x04
-#define   LIO_IFSTATE_RX_TIMESTAMP_ENABLED 0x08
-
 /* Polling interval for determining when NIC application is alive */
 #define LIQUIDIO_STARTER_POLL_INTERVAL_MS 100
 
@@ -531,36 +525,6 @@ static void liquidio_deinit_pci(void)
 }
 
 /**
- * \brief check interface state
- * @param lio per-network private data
- * @param state_flag flag state to check
- */
-static inline int ifstate_check(struct lio *lio, int state_flag)
-{
-	return atomic_read(&lio->ifstate) & state_flag;
-}
-
-/**
- * \brief set interface state
- * @param lio per-network private data
- * @param state_flag flag state to set
- */
-static inline void ifstate_set(struct lio *lio, int state_flag)
-{
-	atomic_set(&lio->ifstate, (atomic_read(&lio->ifstate) | state_flag));
-}
-
-/**
- * \brief clear interface state
- * @param lio per-network private data
- * @param state_flag flag state to clear
- */
-static inline void ifstate_reset(struct lio *lio, int state_flag)
-{
-	atomic_set(&lio->ifstate, (atomic_read(&lio->ifstate) & ~(state_flag)));
-}
-
-/**
  * \brief Stop Tx queues
  * @param netdev network device
  */
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index 7b83be4..c37c165 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -39,12 +39,6 @@ MODULE_PARM_DESC(debug, "NETIF_MSG debug bits");
 
 #define DEFAULT_MSG_ENABLE (NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF_MSG_LINK)
 
-/* Bit mask values for lio->ifstate */
-#define   LIO_IFSTATE_DROQ_OPS             0x01
-#define   LIO_IFSTATE_REGISTERED           0x02
-#define   LIO_IFSTATE_RUNNING              0x04
-#define   LIO_IFSTATE_RX_TIMESTAMP_ENABLED 0x08
-
 struct liquidio_if_cfg_context {
 	int octeon_id;
 
@@ -336,36 +330,6 @@ static struct pci_driver liquidio_vf_pci_driver = {
 };
 
 /**
- * \brief check interface state
- * @param lio per-network private data
- * @param state_flag flag state to check
- */
-static int ifstate_check(struct lio *lio, int state_flag)
-{
-	return atomic_read(&lio->ifstate) & state_flag;
-}
-
-/**
- * \brief set interface state
- * @param lio per-network private data
- * @param state_flag flag state to set
- */
-static void ifstate_set(struct lio *lio, int state_flag)
-{
-	atomic_set(&lio->ifstate, (atomic_read(&lio->ifstate) | state_flag));
-}
-
-/**
- * \brief clear interface state
- * @param lio per-network private data
- * @param state_flag flag state to clear
- */
-static void ifstate_reset(struct lio *lio, int state_flag)
-{
-	atomic_set(&lio->ifstate, (atomic_read(&lio->ifstate) & ~(state_flag)));
-}
-
-/**
  * \brief Stop Tx queues
  * @param netdev network device
  */
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_network.h b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
index eef2a1e..ddb61bf 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_network.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
@@ -28,6 +28,12 @@
 #define LIO_MAX_MTU_SIZE (OCTNET_MAX_FRM_SIZE - OCTNET_FRM_HEADER_SIZE)
 #define LIO_MIN_MTU_SIZE ETH_MIN_MTU
 
+/* Bit mask values for lio->ifstate */
+#define   LIO_IFSTATE_DROQ_OPS             0x01
+#define   LIO_IFSTATE_REGISTERED           0x02
+#define   LIO_IFSTATE_RUNNING              0x04
+#define   LIO_IFSTATE_RX_TIMESTAMP_ENABLED 0x08
+
 struct oct_nic_stats_resp {
 	u64     rh;
 	struct oct_link_stats stats;
@@ -438,4 +444,34 @@ static inline void octeon_fast_packet_next(struct octeon_droq *droq,
 	       get_rbd(droq->recv_buf_list[idx].buffer), copy_len);
 }
 
+/**
+ * \brief check interface state
+ * @param lio per-network private data
+ * @param state_flag flag state to check
+ */
+static inline int ifstate_check(struct lio *lio, int state_flag)
+{
+	return atomic_read(&lio->ifstate) & state_flag;
+}
+
+/**
+ * \brief set interface state
+ * @param lio per-network private data
+ * @param state_flag flag state to set
+ */
+static inline void ifstate_set(struct lio *lio, int state_flag)
+{
+	atomic_set(&lio->ifstate, (atomic_read(&lio->ifstate) | state_flag));
+}
+
+/**
+ * \brief clear interface state
+ * @param lio per-network private data
+ * @param state_flag flag state to clear
+ */
+static inline void ifstate_reset(struct lio *lio, int state_flag)
+{
+	atomic_set(&lio->ifstate, (atomic_read(&lio->ifstate) & ~(state_flag)));
+}
+
 #endif
