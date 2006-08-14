From: Brice Goglin <brice@myri.com>
Subject: [PATCH 1/3] myri10ge: define some previously hardwired firmware constants
Date: Mon, 14 Aug 2006 17:52:54 -0400
Message-ID: <44E0F0B6.4040406@myri.com>
References: <44E0DA08.9080304@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:40678 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S1752071AbWHNVxV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 17:53:21 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <44E0DA08.9080304@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Define some previously hardwired firmware constants.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c     |   17 ++++++++++-------
 drivers/net/myri10ge/myri10ge_mcp.h |   14 +++++++++++++-
 2 files changed, 23 insertions(+), 8 deletions(-)

Index: linux-mm/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-mm.orig/drivers/net/myri10ge/myri10ge.c	2006-08-14 14:21:47.000000000 -0400
+++ linux-mm/drivers/net/myri10ge/myri10ge.c	2006-08-14 14:21:57.000000000 -0400
@@ -271,7 +271,7 @@
 	struct mcp_cmd *buf;
 	char buf_bytes[sizeof(*buf) + 8];
 	struct mcp_cmd_response *response = mgp->cmd;
-	char __iomem *cmd_addr = mgp->sram + MXGEFW_CMD_OFFSET;
+	char __iomem *cmd_addr = mgp->sram + MXGEFW_ETH_CMD;
 	u32 dma_low, dma_high, result, value;
 	int sleep_total = 0;
 
@@ -404,7 +404,7 @@
 	buf[4] = htonl(dma_low);	/* dummy addr LSW */
 	buf[5] = htonl(enable);	/* enable? */
 
-	submit = mgp->sram + 0xfc01c0;
+	submit = mgp->sram + MXGEFW_BOOT_DUMMY_RDMA;
 
 	myri10ge_pio_copy(submit, &buf, sizeof(buf));
 	for (i = 0; mgp->cmd->data != MYRI10GE_NO_CONFIRM_DATA && i < 20; i++)
@@ -600,7 +600,7 @@
 	buf[5] = htonl(8);	/* where to copy to */
 	buf[6] = htonl(0);	/* where to jump to */
 
-	submit = mgp->sram + 0xfc0000;
+	submit = mgp->sram + MXGEFW_BOOT_HANDOFF;
 
 	myri10ge_pio_copy(submit, &buf, sizeof(buf));
 	mb();
@@ -1648,9 +1648,11 @@
 	}
 
 	if (mgp->mtrr >= 0) {
-		mgp->tx.wc_fifo = (u8 __iomem *) mgp->sram + 0x200000;
-		mgp->rx_small.wc_fifo = (u8 __iomem *) mgp->sram + 0x300000;
-		mgp->rx_big.wc_fifo = (u8 __iomem *) mgp->sram + 0x340000;
+		mgp->tx.wc_fifo = (u8 __iomem *) mgp->sram + MXGEFW_ETH_SEND_4;
+		mgp->rx_small.wc_fifo =
+		    (u8 __iomem *) mgp->sram + MXGEFW_ETH_RECV_SMALL;
+		mgp->rx_big.wc_fifo =
+		    (u8 __iomem *) mgp->sram + MXGEFW_ETH_RECV_BIG;
 	} else {
 		mgp->tx.wc_fifo = NULL;
 		mgp->rx_small.wc_fifo = NULL;
@@ -1841,7 +1843,8 @@
 	if (cnt > 0) {
 		/* pad it to 64 bytes.  The src is 64 bytes bigger than it
 		 * needs to be so that we don't overrun it */
-		myri10ge_pio_copy(tx->wc_fifo + (cnt << 18), src, 64);
+		myri10ge_pio_copy(tx->wc_fifo + MXGEFW_ETH_SEND_OFFSET(cnt),
+				  src, 64);
 		mb();
 	}
 }
Index: linux-mm/drivers/net/myri10ge/myri10ge_mcp.h
===================================================================
--- linux-mm.orig/drivers/net/myri10ge/myri10ge_mcp.h	2006-08-14 14:21:47.000000000 -0400
+++ linux-mm/drivers/net/myri10ge/myri10ge_mcp.h	2006-08-14 14:21:57.000000000 -0400
@@ -91,7 +91,19 @@
 
 /* Commands */
 
-#define MXGEFW_CMD_OFFSET 0xf80000
+#define	MXGEFW_BOOT_HANDOFF	0xfc0000
+#define	MXGEFW_BOOT_DUMMY_RDMA	0xfc01c0
+
+#define	MXGEFW_ETH_CMD		0xf80000
+#define	MXGEFW_ETH_SEND_4	0x200000
+#define	MXGEFW_ETH_SEND_1	0x240000
+#define	MXGEFW_ETH_SEND_2	0x280000
+#define	MXGEFW_ETH_SEND_3	0x2c0000
+#define	MXGEFW_ETH_RECV_SMALL	0x300000
+#define	MXGEFW_ETH_RECV_BIG	0x340000
+
+#define	MXGEFW_ETH_SEND(n)		(0x200000 + (((n) & 0x03) * 0x40000))
+#define	MXGEFW_ETH_SEND_OFFSET(n)	(MXGEFW_ETH_SEND(n) - MXGEFW_ETH_SEND_4)
 
 enum myri10ge_mcp_cmd_type {
 	MXGEFW_CMD_NONE = 0,


