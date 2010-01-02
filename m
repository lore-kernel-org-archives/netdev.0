From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 1/3] qlge: Turn on RX header split based on platform.
Date: Sat,  2 Jan 2010 12:37:42 -0800
Message-ID: <1262464664-14996-2-git-send-email-ron.mercer@qlogic.com>
References: <1262464664-14996-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:37005 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751977Ab0ABUp3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jan 2010 15:45:29 -0500
In-Reply-To: <1262464664-14996-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using 4-byte aligned headers is problematic for some architectures.
Since qlge uses 4-byte aligned rx buffers we split headers for these
architectures into a separate buffer and then recopy to align on 2-byte boundary.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h      |   19 +++++++++++++++----
 drivers/net/qlge/qlge_main.c |    6 +++---
 2 files changed, 18 insertions(+), 7 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index 862c1aa..ee0e2bd 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -54,12 +54,8 @@
 #define RX_RING_SHADOW_SPACE	(sizeof(u64) + \
 		MAX_DB_PAGES_PER_BQ(NUM_SMALL_BUFFERS) * sizeof(u64) + \
 		MAX_DB_PAGES_PER_BQ(NUM_LARGE_BUFFERS) * sizeof(u64))
-#define SMALL_BUFFER_SIZE 512
-#define SMALL_BUF_MAP_SIZE (SMALL_BUFFER_SIZE / 2)
 #define LARGE_BUFFER_MAX_SIZE 8192
 #define LARGE_BUFFER_MIN_SIZE 2048
-#define MAX_SPLIT_SIZE 1023
-#define QLGE_SB_PAD 32
 
 #define MAX_CQ 128
 #define DFLT_COALESCE_WAIT 100	/* 100 usec wait for coalescing */
@@ -737,6 +733,21 @@ enum {
 	PRB_MX_DATA = 0xfc,	/* Use semaphore */
 };
 
+#ifdef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
+#define SMALL_BUFFER_SIZE 256
+#define SMALL_BUF_MAP_SIZE SMALL_BUFFER_SIZE
+#define SPLT_SETTING  FSC_DBRST_1024
+#define SPLT_LEN 0
+#define QLGE_SB_PAD 0
+#else
+#define SMALL_BUFFER_SIZE 512
+#define SMALL_BUF_MAP_SIZE (SMALL_BUFFER_SIZE / 2)
+#define SPLT_SETTING  FSC_SH
+#define SPLT_LEN (SPLT_HDR_EP | \
+	min(SMALL_BUF_MAP_SIZE, 1023))
+#define QLGE_SB_PAD 32
+#endif
+
 /*
  * CAM output format.
  */
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 707b391..c303478 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -3332,15 +3332,15 @@ static int ql_adapter_initialize(struct ql_adapter *qdev)
 
 	/* Enable the function, set pagesize, enable error checking. */
 	value = FSC_FE | FSC_EPC_INBOUND | FSC_EPC_OUTBOUND |
-	    FSC_EC | FSC_VM_PAGE_4K | FSC_SH;
+	    FSC_EC | FSC_VM_PAGE_4K;
+	value |= SPLT_SETTING;
 
 	/* Set/clear header splitting. */
 	mask = FSC_VM_PAGESIZE_MASK |
 	    FSC_DBL_MASK | FSC_DBRST_MASK | (value << 16);
 	ql_write32(qdev, FSC, mask | value);
 
-	ql_write32(qdev, SPLT_HDR, SPLT_HDR_EP |
-		min(SMALL_BUF_MAP_SIZE, MAX_SPLIT_SIZE));
+	ql_write32(qdev, SPLT_HDR, SPLT_LEN);
 
 	/* Set RX packet routing to use port/pci function on which the
 	 * packet arrived on in addition to usual frame routing.
-- 
1.6.0.2

