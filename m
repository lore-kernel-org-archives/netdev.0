From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 3/5] qlcnic: seperate interrupt for TX
Date: Thu, 17 Jun 2010 05:56:40 -0700
Message-ID: <1276779402-496-4-git-send-email-amit.salecha@qlogic.com>
References: <1276779402-496-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	schacko <schacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:21256 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751037Ab0FQM4n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jun 2010 08:56:43 -0400
In-Reply-To: <1276779402-496-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: schacko <schacko@qlogic.com>

Earlier all poll routine can process rx and tx, But now
one poll routine to process rx + tx and other for rx only.
Last msix vector will be used for separate tx interrupt.

o This is supported from fw version 4.4.2.
o Bump version 5.0.5

Signed-off-by: Sony Chacko <schacko@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |   14 +++++++++-----
 drivers/net/qlcnic/qlcnic_ctx.c  |    7 ++++++-
 drivers/net/qlcnic/qlcnic_init.c |   35 +++++++++++++++++++++++++----------
 drivers/net/qlcnic/qlcnic_main.c |   35 ++++++++++++++++++++++++++++++++---
 4 files changed, 72 insertions(+), 19 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 7d31caa..9970cff 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -51,8 +51,8 @@
 
 #define _QLCNIC_LINUX_MAJOR 5
 #define _QLCNIC_LINUX_MINOR 0
-#define _QLCNIC_LINUX_SUBVERSION 4
-#define QLCNIC_LINUX_VERSIONID  "5.0.4"
+#define _QLCNIC_LINUX_SUBVERSION 5
+#define QLCNIC_LINUX_VERSIONID  "5.0.5"
 #define QLCNIC_DRV_IDC_VER  0x01
 
 #define QLCNIC_VERSION_CODE(a, b, c)	(((a) << 24) + ((b) << 16) + (c))
@@ -68,6 +68,7 @@
 #define QLCNIC_DECODE_VERSION(v) \
 	QLCNIC_VERSION_CODE(((v) & 0xff), (((v) >> 8) & 0xff), ((v) >> 16))
 
+#define QLCNIC_MIN_FW_VERSION     QLCNIC_VERSION_CODE(4, 4, 2)
 #define QLCNIC_NUM_FLASH_SECTORS (64)
 #define QLCNIC_FLASH_SECTOR_SIZE (64 * 1024)
 #define QLCNIC_FLASH_TOTAL_SIZE  (QLCNIC_NUM_FLASH_SECTORS \
@@ -567,6 +568,7 @@ struct qlcnic_recv_context {
 #define QLCNIC_CAP0_LSO 		(1 << 6)
 #define QLCNIC_CAP0_JUMBO_CONTIGUOUS	(1 << 7)
 #define QLCNIC_CAP0_LRO_CONTIGUOUS	(1 << 8)
+#define QLCNIC_CAP0_VALIDOFF		(1 << 11)
 
 /*
  * Context state
@@ -602,9 +604,10 @@ struct qlcnic_hostrq_rx_ctx {
 	__le32 sds_ring_offset;	/* Offset to SDS config */
 	__le16 num_rds_rings;	/* Count of RDS rings */
 	__le16 num_sds_rings;	/* Count of SDS rings */
-	__le16 rsvd1;		/* Padding */
-	__le16 rsvd2;		/* Padding */
-	u8  reserved[128]; 	/* reserve space for future expansion*/
+	__le16 valid_field_offset;
+	u8  txrx_sds_binding;
+	u8  msix_handler;
+	u8  reserved[128];      /* reserve space for future expansion*/
 	/* MUST BE 64-bit aligned.
 	   The following is packed:
 	   - N hostrq_rds_rings
@@ -1109,6 +1112,7 @@ void qlcnic_request_firmware(struct qlcnic_adapter *adapter);
 void qlcnic_release_firmware(struct qlcnic_adapter *adapter);
 int qlcnic_pinit_from_rom(struct qlcnic_adapter *adapter);
 int qlcnic_setup_idc_param(struct qlcnic_adapter *adapter);
+int qlcnic_check_flash_fw_ver(struct qlcnic_adapter *adapter);
 
 int qlcnic_rom_fast_read(struct qlcnic_adapter *adapter, int addr, int *valp);
 int qlcnic_rom_fast_read_words(struct qlcnic_adapter *adapter, int addr,
diff --git a/drivers/net/qlcnic/qlcnic_ctx.c b/drivers/net/qlcnic/qlcnic_ctx.c
index 90ed6fb..7c96c8e 100644
--- a/drivers/net/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/qlcnic/qlcnic_ctx.c
@@ -152,9 +152,14 @@ qlcnic_fw_cmd_create_rx_ctx(struct qlcnic_adapter *adapter)
 
 	prq->host_rsp_dma_addr = cpu_to_le64(cardrsp_phys_addr);
 
-	cap = (QLCNIC_CAP0_LEGACY_CONTEXT | QLCNIC_CAP0_LEGACY_MN);
+	cap = (QLCNIC_CAP0_LEGACY_CONTEXT | QLCNIC_CAP0_LEGACY_MN
+						| QLCNIC_CAP0_VALIDOFF);
 	cap |= (QLCNIC_CAP0_JUMBO_CONTIGUOUS | QLCNIC_CAP0_LRO_CONTIGUOUS);
 
+	prq->valid_field_offset = offsetof(struct qlcnic_hostrq_rx_ctx,
+							 msix_handler);
+	prq->txrx_sds_binding = nsds_rings - 1;
+
 	prq->capabilities[0] = cpu_to_le32(cap);
 	prq->host_int_crb_mode =
 		cpu_to_le32(QLCNIC_HOST_INT_CRB_MODE_SHARED);
diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index 317750d..2bd00d5 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -543,16 +543,34 @@ qlcnic_setup_idc_param(struct qlcnic_adapter *adapter) {
 	return 0;
 }
 
+int
+qlcnic_check_flash_fw_ver(struct qlcnic_adapter *adapter)
+{
+	u32 ver = -1, min_ver;
+
+	qlcnic_rom_fast_read(adapter, QLCNIC_FW_VERSION_OFFSET, (int *)&ver);
+
+	ver = QLCNIC_DECODE_VERSION(ver);
+	min_ver = QLCNIC_MIN_FW_VERSION;
+
+	if (ver < min_ver) {
+		dev_err(&adapter->pdev->dev,
+			"firmware version %d.%d.%d unsupported."
+			"Min supported version %d.%d.%d\n",
+			_major(ver), _minor(ver), _build(ver),
+			_major(min_ver), _minor(min_ver), _build(min_ver));
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
 static int
 qlcnic_has_mn(struct qlcnic_adapter *adapter)
 {
-	u32 capability, flashed_ver;
+	u32 capability;
 	capability = 0;
 
-	qlcnic_rom_fast_read(adapter,
-			QLCNIC_FW_VERSION_OFFSET, (int *)&flashed_ver);
-	flashed_ver = QLCNIC_DECODE_VERSION(flashed_ver);
-
 	capability = QLCRD32(adapter, QLCNIC_PEG_TUNE_CAPABILITY);
 	if (capability & QLCNIC_PEG_TUNE_MN_PRESENT)
 		return 1;
@@ -1006,7 +1024,7 @@ static int
 qlcnic_validate_firmware(struct qlcnic_adapter *adapter)
 {
 	__le32 val;
-	u32 ver, min_ver, bios, min_size;
+	u32 ver, bios, min_size;
 	struct pci_dev *pdev = adapter->pdev;
 	const struct firmware *fw = adapter->fw;
 	u8 fw_type = adapter->fw_type;
@@ -1028,12 +1046,9 @@ qlcnic_validate_firmware(struct qlcnic_adapter *adapter)
 		return -EINVAL;
 
 	val = qlcnic_get_fw_version(adapter);
-
-	min_ver = QLCNIC_VERSION_CODE(4, 0, 216);
-
 	ver = QLCNIC_DECODE_VERSION(val);
 
-	if ((_major(ver) > _QLCNIC_LINUX_MAJOR) || (ver < min_ver)) {
+	if (ver < QLCNIC_MIN_FW_VERSION) {
 		dev_err(&pdev->dev,
 				"%s: firmware version %d.%d.%d unsupported\n",
 		fw_name[fw_type], _major(ver), _minor(ver), _build(ver));
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 28ed28c..06d2dfd 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -83,6 +83,7 @@ static void qlcnic_schedule_work(struct qlcnic_adapter *adapter,
 		work_func_t func, int delay);
 static void qlcnic_cancel_fw_work(struct qlcnic_adapter *adapter);
 static int qlcnic_poll(struct napi_struct *napi, int budget);
+static int qlcnic_rx_poll(struct napi_struct *napi, int budget);
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void qlcnic_poll_controller(struct net_device *netdev);
 #endif
@@ -195,8 +196,13 @@ qlcnic_napi_add(struct qlcnic_adapter *adapter, struct net_device *netdev)
 
 	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
 		sds_ring = &recv_ctx->sds_rings[ring];
-		netif_napi_add(netdev, &sds_ring->napi,
-				qlcnic_poll, QLCNIC_NETDEV_WEIGHT);
+
+		if (ring == adapter->max_sds_rings - 1)
+			netif_napi_add(netdev, &sds_ring->napi, qlcnic_poll,
+				QLCNIC_NETDEV_WEIGHT/adapter->max_sds_rings);
+		else
+			netif_napi_add(netdev, &sds_ring->napi,
+				qlcnic_rx_poll, QLCNIC_NETDEV_WEIGHT*2);
 	}
 
 	return 0;
@@ -743,8 +749,12 @@ qlcnic_start_firmware(struct qlcnic_adapter *adapter)
 
 	if (load_fw_file)
 		qlcnic_request_firmware(adapter);
-	else
+	else {
+		if (qlcnic_check_flash_fw_ver(adapter))
+			goto err_out;
+
 		adapter->fw_type = QLCNIC_FLASH_ROMIMAGE;
+	}
 
 	err = qlcnic_need_fw_reset(adapter);
 	if (err < 0)
@@ -2060,6 +2070,25 @@ static int qlcnic_poll(struct napi_struct *napi, int budget)
 	return work_done;
 }
 
+static int qlcnic_rx_poll(struct napi_struct *napi, int budget)
+{
+	struct qlcnic_host_sds_ring *sds_ring =
+		container_of(napi, struct qlcnic_host_sds_ring, napi);
+
+	struct qlcnic_adapter *adapter = sds_ring->adapter;
+	int work_done;
+
+	work_done = qlcnic_process_rcv_ring(sds_ring, budget);
+
+	if (work_done < budget) {
+		napi_complete(&sds_ring->napi);
+		if (test_bit(__QLCNIC_DEV_UP, &adapter->state))
+			qlcnic_enable_int(sds_ring);
+	}
+
+	return work_done;
+}
+
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void qlcnic_poll_controller(struct net_device *netdev)
 {
-- 
1.6.0.2

