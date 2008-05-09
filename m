From: Brice Goglin <brice@myri.com>
Subject: [PATCH 01/16] myri10ge: update firmware headers
Date: Fri, 09 May 2008 02:16:19 +0200
Message-ID: <482397D3.7090300@myri.com>
References: <482397A3.1050604@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1813 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S934246AbYEIAqX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 May 2008 20:46:23 -0400
In-Reply-To: <482397A3.1050604@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update myri10ge firmware headers.

Signed-off-by: Brice Goglin <brice@myri.com>
Signed-off-by: Andrew Gallatin <gallatin@myri.com>
---
 drivers/net/myri10ge/myri10ge_mcp.h            |   56 ++++++++++++++++++++++---
 drivers/net/myri10ge/myri10ge_mcp_gen_header.h |   39 ++++++-----------
 2 files changed, 64 insertions(+), 31 deletions(-)

Index: linux-2.6/drivers/net/myri10ge/myri10ge_mcp.h
===================================================================
--- linux-2.6.orig/drivers/net/myri10ge/myri10ge_mcp.h	2008-05-08 23:59:52.000000000 +0200
+++ linux-2.6/drivers/net/myri10ge/myri10ge_mcp.h	2008-05-09 00:00:00.000000000 +0200
@@ -10,7 +10,7 @@
 	__be32 low;
 };
 
-/* 4 Bytes.  8 Bytes for NDIS drivers. */
+/* 4 Bytes */
 struct mcp_slot {
 	__sum16 checksum;
 	__be16 length;
@@ -144,6 +144,7 @@
 	 * a power of 2 number of entries.  */
 
 	MXGEFW_CMD_SET_INTRQ_SIZE,	/* in bytes */
+#define MXGEFW_CMD_SET_INTRQ_SIZE_FLAG_NO_STRICT_SIZE_CHECK  (1 << 31)
 
 	/* command to bring ethernet interface up.  Above parameters
 	 * (plus mtu & mac address) must have been exchanged prior
@@ -221,10 +222,14 @@
 	MXGEFW_CMD_GET_MAX_RSS_QUEUES,
 	MXGEFW_CMD_ENABLE_RSS_QUEUES,
 	/* data0 = number of slices n (0, 1, ..., n-1) to enable
-	 * data1 = interrupt mode. 0=share one INTx/MSI, 1=use one MSI-X per queue.
+	 * data1 = interrupt mode.
+	 * 0=share one INTx/MSI, 1=use one MSI-X per queue.
 	 * If all queues share one interrupt, the driver must have set
 	 * RSS_SHARED_INTERRUPT_DMA before enabling queues.
 	 */
+#define MXGEFW_SLICE_INTR_MODE_SHARED 0
+#define MXGEFW_SLICE_INTR_MODE_ONE_PER_SLICE 1
+
 	MXGEFW_CMD_GET_RSS_SHARED_INTERRUPT_MASK_OFFSET,
 	MXGEFW_CMD_SET_RSS_SHARED_INTERRUPT_DMA,
 	/* data0, data1 = bus address lsw, msw */
@@ -241,10 +246,14 @@
 	 * 0: disable rss.  nic does not distribute receive packets.
 	 * 1: enable rss.  nic distributes receive packets among queues.
 	 * data1 = hash type
-	 * 1: IPV4
-	 * 2: TCP_IPV4
-	 * 3: IPV4 | TCP_IPV4
+	 * 1: IPV4            (required by RSS)
+	 * 2: TCP_IPV4        (required by RSS)
+	 * 3: IPV4 | TCP_IPV4 (required by RSS)
+	 * 4: source port
 	 */
+#define MXGEFW_RSS_HASH_TYPE_IPV4      0x1
+#define MXGEFW_RSS_HASH_TYPE_TCP_IPV4  0x2
+#define MXGEFW_RSS_HASH_TYPE_SRC_PORT  0x4
 
 	MXGEFW_CMD_GET_MAX_TSO6_HDR_SIZE,
 	/* Return data = the max. size of the entire headers of a IPv6 TSO packet.
@@ -260,6 +269,8 @@
 	 * 0: Linux/FreeBSD style (NIC default)
 	 * 1: NDIS/NetBSD style
 	 */
+#define MXGEFW_TSO_MODE_LINUX  0
+#define MXGEFW_TSO_MODE_NDIS   1
 
 	MXGEFW_CMD_MDIO_READ,
 	/* data0 = dev_addr (PMA/PMD or PCS ...), data1 = register/addr */
@@ -286,6 +297,38 @@
 	/* Return data = NIC memory offset of mcp_vpump_public_global */
 	MXGEFW_CMD_RESET_VPUMP,
 	/* Resets the VPUMP state */
+
+	MXGEFW_CMD_SET_RSS_MCP_SLOT_TYPE,
+	/* data0 = mcp_slot type to use.
+	 * 0 = the default 4B mcp_slot
+	 * 1 = 8B mcp_slot_8
+	 */
+#define MXGEFW_RSS_MCP_SLOT_TYPE_MIN        0
+#define MXGEFW_RSS_MCP_SLOT_TYPE_WITH_HASH  1
+
+	MXGEFW_CMD_SET_THROTTLE_FACTOR,
+	/* set the throttle factor for ethp_z8e
+	 * data0 = throttle_factor
+	 * throttle_factor = 256 * pcie-raw-speed / tx_speed
+	 * tx_speed = 256 * pcie-raw-speed / throttle_factor
+	 *
+	 * For PCI-E x8: pcie-raw-speed == 16Gb/s
+	 * For PCI-E x4: pcie-raw-speed == 8Gb/s
+	 *
+	 * ex1: throttle_factor == 0x1a0 (416), tx_speed == 1.23GB/s == 9.846 Gb/s
+	 * ex2: throttle_factor == 0x200 (512), tx_speed == 1.0GB/s == 8 Gb/s
+	 *
+	 * with tx_boundary == 2048, max-throttle-factor == 8191 => min-speed == 500Mb/s
+	 * with tx_boundary == 4096, max-throttle-factor == 4095 => min-speed == 1Gb/s
+	 */
+
+	MXGEFW_CMD_VPUMP_UP,
+	/* Allocates VPump Connection, Send Request and Zero copy buffer address tables */
+	MXGEFW_CMD_GET_VPUMP_CLK,
+	/* Get the lanai clock */
+
+	MXGEFW_CMD_GET_DCA_OFFSET,
+	/* offset of dca control for WDMAs */
 };
 
 enum myri10ge_mcp_cmd_status {
@@ -302,7 +345,8 @@
 	MXGEFW_CMD_ERROR_UNALIGNED,
 	MXGEFW_CMD_ERROR_NO_MDIO,
 	MXGEFW_CMD_ERROR_XFP_FAILURE,
-	MXGEFW_CMD_ERROR_XFP_ABSENT
+	MXGEFW_CMD_ERROR_XFP_ABSENT,
+	MXGEFW_CMD_ERROR_BAD_PCIE_LINK
 };
 
 #define MXGEFW_OLD_IRQ_DATA_LEN 40
Index: linux-2.6/drivers/net/myri10ge/myri10ge_mcp_gen_header.h
===================================================================
--- linux-2.6.orig/drivers/net/myri10ge/myri10ge_mcp_gen_header.h	2008-05-08 23:59:52.000000000 +0200
+++ linux-2.6/drivers/net/myri10ge/myri10ge_mcp_gen_header.h	2008-05-09 00:00:00.000000000 +0200
@@ -1,30 +1,6 @@
 #ifndef __MYRI10GE_MCP_GEN_HEADER_H__
 #define __MYRI10GE_MCP_GEN_HEADER_H__
 
-/* this file define a standard header used as a first entry point to
- * exchange information between firmware/driver and driver.  The
- * header structure can be anywhere in the mcp. It will usually be in
- * the .data section, because some fields needs to be initialized at
- * compile time.
- * The 32bit word at offset MX_HEADER_PTR_OFFSET in the mcp must
- * contains the location of the header.
- *
- * Typically a MCP will start with the following:
- * .text
- * .space 52    ! to help catch MEMORY_INT errors
- * bt start     ! jump to real code
- * nop
- * .long _gen_mcp_header
- *
- * The source will have a definition like:
- *
- * mcp_gen_header_t gen_mcp_header = {
- * .header_length = sizeof(mcp_gen_header_t),
- * .mcp_type = MCP_TYPE_XXX,
- * .version = "something $Id: mcp_gen_header.h,v 1.2 2006/05/13 10:04:35 bgoglin Exp $",
- * .mcp_globals = (unsigned)&Globals
- * };
- */
 
 #define MCP_HEADER_PTR_OFFSET  0x3c
 
@@ -32,13 +8,14 @@
 #define MCP_TYPE_PCIE 0x70636965	/* "PCIE" pcie-only MCP */
 #define MCP_TYPE_ETH 0x45544820	/* "ETH " */
 #define MCP_TYPE_MCP0 0x4d435030	/* "MCP0" */
+#define MCP_TYPE_DFLT 0x20202020	/* "    " */
 
 struct mcp_gen_header {
 	/* the first 4 fields are filled at compile time */
 	unsigned header_length;
 	__be32 mcp_type;
 	char version[128];
-	unsigned mcp_globals;	/* pointer to mcp-type specific structure */
+	unsigned mcp_private;	/* pointer to mcp-type specific structure */
 
 	/* filled by the MCP at run-time */
 	unsigned sram_size;
@@ -53,6 +30,18 @@
 	 *
 	 * Never remove any field.  Keep everything naturally align.
 	 */
+
+	/* Specifies if the running mcp is mcp0, 1, or 2. */
+	unsigned char mcp_index;
+	unsigned char disable_rabbit;
+	unsigned char unaligned_tlp;
+	unsigned char pad1;
+	unsigned counters_addr;
+	unsigned copy_block_info;	/* for small mcps loaded with "lload -d" */
+	unsigned short handoff_id_major;	/* must be equal */
+	unsigned short handoff_id_caps;	/* bitfield: new mcp must have superset */
+	unsigned msix_table_addr;	/* start address of msix table in firmware */
+	/* 8 */
 };
 
 #endif				/* __MYRI10GE_MCP_GEN_HEADER_H__ */


