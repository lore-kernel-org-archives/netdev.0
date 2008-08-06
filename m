From: Brice Goglin <brice@myri.com>
Subject: [PATCH 1/2] myri10ge: update firmware headers
Date: Wed, 06 Aug 2008 16:14:43 +0200
Message-ID: <4899B1D3.9060500@myri.com>
References: <4899B198.1060508@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1996 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750866AbYHFOPK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Aug 2008 10:15:10 -0400
In-Reply-To: <4899B198.1060508@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update myri10ge firmware headers.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge_mcp.h            |   52 ++++++++++++++++++++++---
 drivers/net/myri10ge/myri10ge_mcp_gen_header.h |    2 
 2 files changed, 48 insertions(+), 6 deletions(-)

Index: linux-2.6/drivers/net/myri10ge/myri10ge_mcp.h
===================================================================
--- linux-2.6.orig/drivers/net/myri10ge/myri10ge_mcp.h	2008-05-19 18:13:31.000000000 +0200
+++ linux-2.6/drivers/net/myri10ge/myri10ge_mcp.h	2008-08-04 13:22:07.000000000 +0200
@@ -101,6 +101,8 @@
 #define	MXGEFW_ETH_SEND_3	0x2c0000
 #define	MXGEFW_ETH_RECV_SMALL	0x300000
 #define	MXGEFW_ETH_RECV_BIG	0x340000
+#define	MXGEFW_ETH_SEND_GO	0x380000
+#define	MXGEFW_ETH_SEND_STOP	0x3C0000
 
 #define	MXGEFW_ETH_SEND(n)		(0x200000 + (((n) & 0x03) * 0x40000))
 #define	MXGEFW_ETH_SEND_OFFSET(n)	(MXGEFW_ETH_SEND(n) - MXGEFW_ETH_SEND_4)
@@ -120,6 +122,11 @@
 	 * MXGEFW_CMD_RESET is issued */
 
 	MXGEFW_CMD_SET_INTRQ_DMA,
+	/* data0 = LSW of the host address
+	 * data1 = MSW of the host address
+	 * data2 = slice number if multiple slices are used
+	 */
+
 	MXGEFW_CMD_SET_BIG_BUFFER_SIZE,	/* in bytes, power of 2 */
 	MXGEFW_CMD_SET_SMALL_BUFFER_SIZE,	/* in bytes */
 
@@ -129,6 +136,8 @@
 	MXGEFW_CMD_GET_SEND_OFFSET,
 	MXGEFW_CMD_GET_SMALL_RX_OFFSET,
 	MXGEFW_CMD_GET_BIG_RX_OFFSET,
+	/* data0 = slice number if multiple slices are used */
+
 	MXGEFW_CMD_GET_IRQ_ACK_OFFSET,
 	MXGEFW_CMD_GET_IRQ_DEASSERT_OFFSET,
 
@@ -200,7 +209,12 @@
 	MXGEFW_CMD_SET_STATS_DMA_V2,
 	/* data0, data1 = bus addr,
 	 * data2 = sizeof(struct mcp_irq_data) from driver point of view, allows
-	 * adding new stuff to mcp_irq_data without changing the ABI */
+	 * adding new stuff to mcp_irq_data without changing the ABI
+	 *
+	 * If multiple slices are used, data2 contains both the size of the
+	 * structure (in the lower 16 bits) and the slice number
+	 * (in the upper 16 bits).
+	 */
 
 	MXGEFW_CMD_UNALIGNED_TEST,
 	/* same than DMA_TEST (same args) but abort with UNALIGNED on unaligned
@@ -222,13 +236,18 @@
 	MXGEFW_CMD_GET_MAX_RSS_QUEUES,
 	MXGEFW_CMD_ENABLE_RSS_QUEUES,
 	/* data0 = number of slices n (0, 1, ..., n-1) to enable
-	 * data1 = interrupt mode.
-	 * 0=share one INTx/MSI, 1=use one MSI-X per queue.
+	 * data1 = interrupt mode | use of multiple transmit queues.
+	 * 0=share one INTx/MSI.
+	 * 1=use one MSI-X per queue.
 	 * If all queues share one interrupt, the driver must have set
 	 * RSS_SHARED_INTERRUPT_DMA before enabling queues.
+	 * 2=enable both receive and send queues.
+	 * Without this bit set, only one send queue (slice 0's send queue)
+	 * is enabled.  The receive queues are always enabled.
 	 */
-#define MXGEFW_SLICE_INTR_MODE_SHARED 0
-#define MXGEFW_SLICE_INTR_MODE_ONE_PER_SLICE 1
+#define MXGEFW_SLICE_INTR_MODE_SHARED          0x0
+#define MXGEFW_SLICE_INTR_MODE_ONE_PER_SLICE   0x1
+#define MXGEFW_SLICE_ENABLE_MULTIPLE_TX_QUEUES 0x2
 
 	MXGEFW_CMD_GET_RSS_SHARED_INTERRUPT_MASK_OFFSET,
 	MXGEFW_CMD_SET_RSS_SHARED_INTERRUPT_DMA,
@@ -250,10 +269,13 @@
 	 * 2: TCP_IPV4        (required by RSS)
 	 * 3: IPV4 | TCP_IPV4 (required by RSS)
 	 * 4: source port
+	 * 5: source port + destination port
 	 */
 #define MXGEFW_RSS_HASH_TYPE_IPV4      0x1
 #define MXGEFW_RSS_HASH_TYPE_TCP_IPV4  0x2
 #define MXGEFW_RSS_HASH_TYPE_SRC_PORT  0x4
+#define MXGEFW_RSS_HASH_TYPE_SRC_DST_PORT 0x5
+#define MXGEFW_RSS_HASH_TYPE_MAX 0x5
 
 	MXGEFW_CMD_GET_MAX_TSO6_HDR_SIZE,
 	/* Return data = the max. size of the entire headers of a IPv6 TSO packet.
@@ -329,6 +351,20 @@
 
 	MXGEFW_CMD_GET_DCA_OFFSET,
 	/* offset of dca control for WDMAs */
+
+	/* VMWare NetQueue commands */
+	MXGEFW_CMD_NETQ_GET_FILTERS_PER_QUEUE,
+	MXGEFW_CMD_NETQ_ADD_FILTER,
+	/* data0 = filter_id << 16 | queue << 8 | type */
+	/* data1 = MS4 of MAC Addr */
+	/* data2 = LS2_MAC << 16 | VLAN_tag */
+	MXGEFW_CMD_NETQ_DEL_FILTER,
+	/* data0 = filter_id */
+	MXGEFW_CMD_NETQ_QUERY1,
+	MXGEFW_CMD_NETQ_QUERY2,
+	MXGEFW_CMD_NETQ_QUERY3,
+	MXGEFW_CMD_NETQ_QUERY4,
+
 };
 
 enum myri10ge_mcp_cmd_status {
@@ -381,4 +417,10 @@
 	u8 valid;
 };
 
+/* definitions for NETQ filter type */
+#define MXGEFW_NETQ_FILTERTYPE_NONE 0
+#define MXGEFW_NETQ_FILTERTYPE_MACADDR 1
+#define MXGEFW_NETQ_FILTERTYPE_VLAN 2
+#define MXGEFW_NETQ_FILTERTYPE_VLANMACADDR 3
+
 #endif				/* __MYRI10GE_MCP_H__ */
Index: linux-2.6/drivers/net/myri10ge/myri10ge_mcp_gen_header.h
===================================================================
--- linux-2.6.orig/drivers/net/myri10ge/myri10ge_mcp_gen_header.h	2008-05-19 18:13:31.000000000 +0200
+++ linux-2.6/drivers/net/myri10ge/myri10ge_mcp_gen_header.h	2008-08-04 13:22:07.000000000 +0200
@@ -35,7 +35,7 @@
 	unsigned char mcp_index;
 	unsigned char disable_rabbit;
 	unsigned char unaligned_tlp;
-	unsigned char pad1;
+	unsigned char pcie_link_algo;
 	unsigned counters_addr;
 	unsigned copy_block_info;	/* for small mcps loaded with "lload -d" */
 	unsigned short handoff_id_major;	/* must be equal */


