From: Brice Goglin <brice@myri.com>
Subject: [PATCH 2/5] myri10ge: update firmware headers
Date: Sat, 13 Oct 2007 12:32:58 +0200
Message-ID: <47109EDA.3070703@myri.com>
References: <47109E8A.8080205@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:2005 "EHLO myri.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753550AbXJMKdj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Oct 2007 06:33:39 -0400
In-Reply-To: <47109E8A.8080205@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update myri10ge firmware headers to latest upstream version with
TSO6 and RSS support.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge_mcp.h |   90 ++++++++++++++++++++++++++++++++++--
 1 file changed, 86 insertions(+), 4 deletions(-)

Index: linux-git/drivers/net/myri10ge/myri10ge_mcp.h
===================================================================
--- linux-git.orig/drivers/net/myri10ge/myri10ge_mcp.h	2007-10-13 11:58:18.000000000 +0200
+++ linux-git/drivers/net/myri10ge/myri10ge_mcp.h	2007-10-13 12:02:31.000000000 +0200
@@ -10,7 +10,7 @@
 	__be32 low;
 };
 
-/* 4 Bytes */
+/* 4 Bytes.  8 Bytes for NDIS drivers. */
 struct mcp_slot {
 	__sum16 checksum;
 	__be16 length;
@@ -205,8 +205,87 @@
 	/* same than DMA_TEST (same args) but abort with UNALIGNED on unaligned
 	 * chipset */
 
-	MXGEFW_CMD_UNALIGNED_STATUS
-	    /* return data = boolean, true if the chipset is known to be unaligned */
+	MXGEFW_CMD_UNALIGNED_STATUS,
+	/* return data = boolean, true if the chipset is known to be unaligned */
+
+	MXGEFW_CMD_ALWAYS_USE_N_BIG_BUFFERS,
+	/* data0 = number of big buffers to use.  It must be 0 or a power of 2.
+	 * 0 indicates that the NIC consumes as many buffers as they are required
+	 * for packet. This is the default behavior.
+	 * A power of 2 number indicates that the NIC always uses the specified
+	 * number of buffers for each big receive packet.
+	 * It is up to the driver to ensure that this value is big enough for
+	 * the NIC to be able to receive maximum-sized packets.
+	 */
+
+	MXGEFW_CMD_GET_MAX_RSS_QUEUES,
+	MXGEFW_CMD_ENABLE_RSS_QUEUES,
+	/* data0 = number of slices n (0, 1, ..., n-1) to enable
+	 * data1 = interrupt mode. 0=share one INTx/MSI, 1=use one MSI-X per queue.
+	 * If all queues share one interrupt, the driver must have set
+	 * RSS_SHARED_INTERRUPT_DMA before enabling queues.
+	 */
+	MXGEFW_CMD_GET_RSS_SHARED_INTERRUPT_MASK_OFFSET,
+	MXGEFW_CMD_SET_RSS_SHARED_INTERRUPT_DMA,
+	/* data0, data1 = bus address lsw, msw */
+	MXGEFW_CMD_GET_RSS_TABLE_OFFSET,
+	/* get the offset of the indirection table */
+	MXGEFW_CMD_SET_RSS_TABLE_SIZE,
+	/* set the size of the indirection table */
+	MXGEFW_CMD_GET_RSS_KEY_OFFSET,
+	/* get the offset of the secret key */
+	MXGEFW_CMD_RSS_KEY_UPDATED,
+	/* tell nic that the secret key's been updated */
+	MXGEFW_CMD_SET_RSS_ENABLE,
+	/* data0 = enable/disable rss
+	 * 0: disable rss.  nic does not distribute receive packets.
+	 * 1: enable rss.  nic distributes receive packets among queues.
+	 * data1 = hash type
+	 * 1: IPV4
+	 * 2: TCP_IPV4
+	 * 3: IPV4 | TCP_IPV4
+	 */
+
+	MXGEFW_CMD_GET_MAX_TSO6_HDR_SIZE,
+	/* Return data = the max. size of the entire headers of a IPv6 TSO packet.
+	 * If the header size of a IPv6 TSO packet is larger than the specified
+	 * value, then the driver must not use TSO.
+	 * This size restriction only applies to IPv6 TSO.
+	 * For IPv4 TSO, the maximum size of the headers is fixed, and the NIC
+	 * always has enough header buffer to store maximum-sized headers.
+	 */
+
+	MXGEFW_CMD_SET_TSO_MODE,
+	/* data0 = TSO mode.
+	 * 0: Linux/FreeBSD style (NIC default)
+	 * 1: NDIS/NetBSD style
+	 */
+
+	MXGEFW_CMD_MDIO_READ,
+	/* data0 = dev_addr (PMA/PMD or PCS ...), data1 = register/addr */
+	MXGEFW_CMD_MDIO_WRITE,
+	/* data0 = dev_addr,  data1 = register/addr, data2 = value  */
+
+	MXGEFW_CMD_XFP_I2C_READ,
+	/* Starts to get a fresh copy of one byte or of the whole xfp i2c table, the
+	 * obtained data is cached inside the xaui-xfi chip :
+	 *   data0 : "all" flag : 0 => get one byte, 1=> get 256 bytes,
+	 *   data1 : if (data0 == 0): index of byte to refresh [ not used otherwise ]
+	 * The operation might take ~1ms for a single byte or ~65ms when refreshing all 256 bytes
+	 * During the i2c operation,  MXGEFW_CMD_XFP_I2C_READ or MXGEFW_CMD_XFP_BYTE attempts
+	 *  will return MXGEFW_CMD_ERROR_BUSY
+	 */
+	MXGEFW_CMD_XFP_BYTE,
+	/* Return the last obtained copy of a given byte in the xfp i2c table
+	 * (copy cached during the last relevant MXGEFW_CMD_XFP_I2C_READ)
+	 *   data0 : index of the desired table entry
+	 *  Return data = the byte stored at the requested index in the table
+	 */
+
+	MXGEFW_CMD_GET_VPUMP_OFFSET,
+	/* Return data = NIC memory offset of mcp_vpump_public_global */
+	MXGEFW_CMD_RESET_VPUMP,
+	/* Resets the VPUMP state */
 };
 
 enum myri10ge_mcp_cmd_status {
@@ -220,7 +299,10 @@
 	MXGEFW_CMD_ERROR_BAD_PORT,
 	MXGEFW_CMD_ERROR_RESOURCES,
 	MXGEFW_CMD_ERROR_MULTICAST,
-	MXGEFW_CMD_ERROR_UNALIGNED
+	MXGEFW_CMD_ERROR_UNALIGNED,
+	MXGEFW_CMD_ERROR_NO_MDIO,
+	MXGEFW_CMD_ERROR_XFP_FAILURE,
+	MXGEFW_CMD_ERROR_XFP_ABSENT
 };
 
 #define MXGEFW_OLD_IRQ_DATA_LEN 40


