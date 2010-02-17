From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH 6/8] bnx2x: Use firmware 5.2.13
Date: Wed, 17 Feb 2010 14:04:31 +0200
Message-ID: <1266408271.25691.852.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2043 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756999Ab0BQMMz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2010 07:12:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Switch to the new firmware version (5.2.13).

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h          |    4 ++--
 drivers/net/bnx2x_fw_defs.h  |    7 ++++++-
 drivers/net/bnx2x_hsi.h      |   10 ++++++----
 drivers/net/bnx2x_init_ops.h |   13 +++++++++----
 drivers/net/bnx2x_main.c     |    2 +-
 firmware/Makefile            |    2 +-
 firmware/WHENCE              |    6 +++---
 7 files changed, 28 insertions(+), 16 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 602ab86..d997d84 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -1,6 +1,6 @@
 /* bnx2x.h: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2009 Broadcom Corporation
+ * Copyright (c) 2007-2010 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -130,7 +130,7 @@
 				 offset, len32); \
 	} while (0)
 
-#define VIRT_WR_DMAE_LEN(bp, data, addr, len32) \
+#define VIRT_WR_DMAE_LEN(bp, data, addr, len32, le32_swap) \
 	do { \
 		memcpy(GUNZIP_BUF(bp), data, (len32) * 4); \
 		bnx2x_write_big_buf_wb(bp, addr, len32); \
diff --git a/drivers/net/bnx2x_fw_defs.h b/drivers/net/bnx2x_fw_defs.h
index 931dcac..08d71bf 100644
--- a/drivers/net/bnx2x_fw_defs.h
+++ b/drivers/net/bnx2x_fw_defs.h
@@ -1,6 +1,6 @@
 /* bnx2x_fw_defs.h: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2009 Broadcom Corporation
+ * Copyright (c) 2007-2010 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -471,6 +471,11 @@
 
 
 /* Host coalescing constants */
+#define HC_IGU_BC_MODE 0
+#define HC_IGU_NBC_MODE 1
+
+#define HC_REGULAR_SEGMENT 0
+#define HC_DEFAULT_SEGMENT 1
 
 /* index numbers */
 #define HC_USTORM_DEF_SB_NUM_INDICES 8
diff --git a/drivers/net/bnx2x_hsi.h b/drivers/net/bnx2x_hsi.h
index 5258533..7600693 100644
--- a/drivers/net/bnx2x_hsi.h
+++ b/drivers/net/bnx2x_hsi.h
@@ -1,6 +1,6 @@
 /* bnx2x_hsi.h: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2009 Broadcom Corporation
+ * Copyright (c) 2007-2010 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -1261,7 +1261,7 @@ struct host_func_stats {
 
 #define BCM_5710_FW_MAJOR_VERSION			5
 #define BCM_5710_FW_MINOR_VERSION			2
-#define BCM_5710_FW_REVISION_VERSION			7
+#define BCM_5710_FW_REVISION_VERSION			13
 #define BCM_5710_FW_ENGINEERING_VERSION 		0
 #define BCM_5710_FW_COMPILE_FLAGS			1
 
@@ -2433,8 +2433,10 @@ struct common_ramrod_eth_rx_cqe {
 	u8 ramrod_type;
 #define COMMON_RAMROD_ETH_RX_CQE_TYPE (0x1<<0)
 #define COMMON_RAMROD_ETH_RX_CQE_TYPE_SHIFT 0
-#define COMMON_RAMROD_ETH_RX_CQE_RESERVED0 (0x7F<<1)
-#define COMMON_RAMROD_ETH_RX_CQE_RESERVED0_SHIFT 1
+#define COMMON_RAMROD_ETH_RX_CQE_ERROR (0x1<<1)
+#define COMMON_RAMROD_ETH_RX_CQE_ERROR_SHIFT 1
+#define COMMON_RAMROD_ETH_RX_CQE_RESERVED0 (0x3F<<2)
+#define COMMON_RAMROD_ETH_RX_CQE_RESERVED0_SHIFT 2
 	u8 conn_type;
 	__le16 reserved1;
 	__le32 conn_and_cmd_data;
diff --git a/drivers/net/bnx2x_init_ops.h b/drivers/net/bnx2x_init_ops.h
index 38b970a..2b1363a 100644
--- a/drivers/net/bnx2x_init_ops.h
+++ b/drivers/net/bnx2x_init_ops.h
@@ -2,7 +2,7 @@
  *               Static functions needed during the initialization.
  *               This file is "included" in bnx2x_main.c.
  *
- * Copyright (c) 2007-2009 Broadcom Corporation
+ * Copyright (c) 2007-2010 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -138,11 +138,16 @@ static void bnx2x_write_big_buf_wb(struct bnx2x *bp, u32 addr, u32 len)
 static void bnx2x_init_wr_wb(struct bnx2x *bp, u32 addr, const u32 *data,
 			     u32 len)
 {
+	const u32 *old_data = data;
+
 	data = (const u32 *)bnx2x_sel_blob(bp, addr, (const u8 *)data);
 
-	if (bp->dmae_ready)
-		VIRT_WR_DMAE_LEN(bp, data, addr, len);
-	else
+	if (bp->dmae_ready) {
+		if (old_data != data)
+			VIRT_WR_DMAE_LEN(bp, data, addr, len, 1);
+		else
+			VIRT_WR_DMAE_LEN(bp, data, addr, len, 0);
+	} else
 		bnx2x_init_ind_wr(bp, addr, data, len);
 }
 
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 24fe083..164a5e8 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -1,6 +1,6 @@
 /* bnx2x_main.c: Broadcom Everest network driver.
  *
- * Copyright (c) 2007-2009 Broadcom Corporation
+ * Copyright (c) 2007-2010 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/firmware/Makefile b/firmware/Makefile
index 1c00d05..0063c3a 100644
--- a/firmware/Makefile
+++ b/firmware/Makefile
@@ -32,7 +32,7 @@ fw-shipped-$(CONFIG_ADAPTEC_STARFIRE) += adaptec/starfire_rx.bin \
 					 adaptec/starfire_tx.bin
 fw-shipped-$(CONFIG_ATARI_DSP56K) += dsp56k/bootstrap.bin
 fw-shipped-$(CONFIG_ATM_AMBASSADOR) += atmsar11.fw
-fw-shipped-$(CONFIG_BNX2X) += bnx2x-e1-5.2.7.0.fw bnx2x-e1h-5.2.7.0.fw
+fw-shipped-$(CONFIG_BNX2X) += bnx2x-e1-5.2.13.0.fw bnx2x-e1h-5.2.13.0.fw
 fw-shipped-$(CONFIG_BNX2) += bnx2/bnx2-mips-09-5.0.0.j3.fw \
 			     bnx2/bnx2-rv2p-09-5.0.0.j3.fw \
 			     bnx2/bnx2-rv2p-09ax-5.0.0.j3.fw \
diff --git a/firmware/WHENCE b/firmware/WHENCE
index ac174fe..e8e550f 100644
--- a/firmware/WHENCE
+++ b/firmware/WHENCE
@@ -679,11 +679,11 @@ Found in hex form in kernel source.
 
 Driver: bnx2x: Broadcom Everest
 
-File: bnx2x-e1-5.2.7.0.fw.ihex
-File: bnx2x-e1h-5.2.7.0.fw.ihex
+File: bnx2x-e1-5.2.13.0.fw
+File: bnx2x-e1h-5.2.13.0.fw
 
 License:
-  Copyright (c) 2007-2009 Broadcom Corporation
+  Copyright (c) 2007-2010 Broadcom Corporation
 
   This file contains firmware data derived from proprietary unpublished
   source code, Copyright (c) 2007-2009 Broadcom Corporation.
-- 
1.6.3.3




