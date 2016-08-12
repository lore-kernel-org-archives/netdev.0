From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V2 02/18] liquidio: Firmware version management
Date: Fri, 12 Aug 2016 11:20:19 -0700
Message-ID: <1471026035-15323-3-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1471026035-15323-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0072.outbound.protection.outlook.com ([104.47.41.72]:35104
	"EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751652AbcHLSye (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Aug 2016 14:54:34 -0400
In-Reply-To: <1471026035-15323-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch contains changes for firmware version management.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 12 ++++++++++--
 .../net/ethernet/cavium/liquidio/liquidio_common.h | 22 +++++++++++++++++++---
 2 files changed, 29 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 8e9ada9..06f4094 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -3231,8 +3231,9 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 	union oct_nic_if_cfg if_cfg;
 	unsigned int base_queue;
 	unsigned int gmx_port_id;
-	u32 resp_size, ctx_size;
+	u32 resp_size, ctx_size, data_size;
 	u32 ifidx_or_pfnum;
+	struct lio_version *vdata;
 
 	/* This is to handle link status changes */
 	octeon_register_dispatch_fn(octeon_dev, OPCODE_NIC,
@@ -3254,11 +3255,18 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 	for (i = 0; i < octeon_dev->ifcount; i++) {
 		resp_size = sizeof(struct liquidio_if_cfg_resp);
 		ctx_size = sizeof(struct liquidio_if_cfg_context);
+		data_size = sizeof(struct lio_version);
 		sc = (struct octeon_soft_command *)
-			octeon_alloc_soft_command(octeon_dev, 0,
+			octeon_alloc_soft_command(octeon_dev, data_size,
 						  resp_size, ctx_size);
 		resp = (struct liquidio_if_cfg_resp *)sc->virtrptr;
 		ctx  = (struct liquidio_if_cfg_context *)sc->ctxptr;
+		vdata = (struct lio_version *)sc->virtdptr;
+
+		*((u64 *)vdata) = 0;
+		vdata->major = cpu_to_be16(LIQUIDIO_BASE_MAJOR_VERSION);
+		vdata->minor = cpu_to_be16(LIQUIDIO_BASE_MINOR_VERSION);
+		vdata->micro = cpu_to_be16(LIQUIDIO_BASE_MICRO_VERSION);
 
 		num_iqueues =
 			CFG_GET_NUM_TXQS_NIC_IF(octeon_get_conf(octeon_dev), i);
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
index 199a8b9..0330b52 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
@@ -30,10 +30,26 @@
 
 #include "octeon_config.h"
 
-#define LIQUIDIO_BASE_VERSION   "1.4"
-#define LIQUIDIO_MICRO_VERSION  ".1"
 #define LIQUIDIO_PACKAGE ""
-#define LIQUIDIO_VERSION  "1.4.1"
+#define LIO_STR_HELPER(x)	#x
+#define LIO_STR(x)	LIO_STR_HELPER(x)
+#define LIQUIDIO_BASE_MAJOR_VERSION 1
+#define LIQUIDIO_BASE_MINOR_VERSION 4
+#define LIQUIDIO_BASE_MICRO_VERSION 1
+#define LIQUIDIO_BASE_VERSION   LIO_STR(LIQUIDIO_BASE_MAJOR_VERSION) "." \
+				LIO_STR(LIQUIDIO_BASE_MINOR_VERSION)
+#define LIQUIDIO_MICRO_VERSION  "." LIO_STR(LIQUIDIO_BASE_MICRO_VERSION)
+#define LIQUIDIO_VERSION        LIQUIDIO_PACKAGE \
+				LIO_STR(LIQUIDIO_BASE_MAJOR_VERSION) "." \
+				LIO_STR(LIQUIDIO_BASE_MINOR_VERSION) \
+				"." LIO_STR(LIQUIDIO_BASE_MICRO_VERSION)
+
+struct lio_version {
+	u16  major;
+	u16  minor;
+	u16  micro;
+	u16  reserved;
+};
 
 #define CONTROL_IQ 0
 /** Tag types used by Octeon cores in its work. */
-- 
1.8.3.1
