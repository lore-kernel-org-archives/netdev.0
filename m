From: Brice Goglin <brice@myri.com>
Subject: [PATCH 2/2] myri10ge: use multicast support in the firmware
Date: Mon, 21 Aug 2006 17:36:56 -0400
Message-ID: <44EA2778.6030304@myri.com>
References: <44EA2575.7070307@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:9703 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S1751190AbWHUVhJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2006 17:37:09 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <44EA2575.7070307@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PATCH] myri10ge: use multicast support in the firmware

Some recent myri10ge firmwares support multicast filtering as well
as an extended mcp_irq_data structure (64 instead of 40 bytes).
The new command MXGEFW_CMD_SET_STATS_DMA_V2 is used to check
whether the firmware support those. mgp->fw_multicast_support
is defined accordingly.

When fw_multicast_support is set, some new multicast filtering
commands is passed to the board in myri10ge_set_multicast_list().

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c     |   99 ++++++++++++++++++++++++++++++++++--
 drivers/net/myri10ge/myri10ge_mcp.h |   33 ++++++++++--
 2 files changed, 124 insertions(+), 8 deletions(-)

Index: linux-mm/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-mm.orig/drivers/net/myri10ge/myri10ge.c	2006-08-21 17:14:06.000000000 -0400
+++ linux-mm/drivers/net/myri10ge/myri10ge.c	2006-08-21 17:14:18.000000000 -0400
@@ -187,6 +187,7 @@
 	u8 mac_addr[6];		/* eeprom mac address */
 	unsigned long serial_number;
 	int vendor_specific_offset;
+	int fw_multicast_support;
 	u32 devctl;
 	u16 msi_flags;
 	u32 read_dma;
@@ -328,6 +329,8 @@
 		if (result == 0) {
 			data->data0 = value;
 			return 0;
+		} else if (result == MXGEFW_CMD_UNKNOWN) {
+			return -ENOSYS;
 		} else {
 			dev_err(&mgp->pdev->dev,
 				"command %d failed, result = %d\n",
@@ -1309,8 +1312,8 @@
 	"tx_req", "tx_done", "rx_small_cnt", "rx_big_cnt",
 	"wake_queue", "stop_queue", "watchdog_resets", "tx_linearized",
 	"link_changes", "link_up", "dropped_link_overflow",
-	"dropped_link_error_or_filtered", "dropped_runt",
-	"dropped_overrun", "dropped_no_small_buffer",
+	"dropped_link_error_or_filtered", "dropped_multicast_filtered",
+	"dropped_runt", "dropped_overrun", "dropped_no_small_buffer",
 	"dropped_no_big_buffer"
 };
 
@@ -1366,6 +1369,8 @@
 	data[i++] = (unsigned int)ntohl(mgp->fw_stats->dropped_link_overflow);
 	data[i++] =
 	    (unsigned int)ntohl(mgp->fw_stats->dropped_link_error_or_filtered);
+	data[i++] =
+	    (unsigned int)ntohl(mgp->fw_stats->dropped_multicast_filtered);
 	data[i++] = (unsigned int)ntohl(mgp->fw_stats->dropped_runt);
 	data[i++] = (unsigned int)ntohl(mgp->fw_stats->dropped_overrun);
 	data[i++] = (unsigned int)ntohl(mgp->fw_stats->dropped_no_small_buffer);
@@ -1722,7 +1727,21 @@
 
 	cmd.data0 = MYRI10GE_LOWPART_TO_U32(mgp->fw_stats_bus);
 	cmd.data1 = MYRI10GE_HIGHPART_TO_U32(mgp->fw_stats_bus);
-	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_SET_STATS_DMA, &cmd, 0);
+	cmd.data2 = sizeof(struct mcp_irq_data);
+	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_SET_STATS_DMA_V2, &cmd, 0);
+	if (status == -ENOSYS) {
+		dma_addr_t bus = mgp->fw_stats_bus;
+		bus += offsetof(struct mcp_irq_data, send_done_count);
+		cmd.data0 = MYRI10GE_LOWPART_TO_U32(bus);
+		cmd.data1 = MYRI10GE_HIGHPART_TO_U32(bus);
+		status = myri10ge_send_cmd(mgp,
+					   MXGEFW_CMD_SET_STATS_DMA_OBSOLETE,
+					   &cmd, 0);
+		/* Firmware cannot support multicast without STATS_DMA_V2 */
+		mgp->fw_multicast_support = 0;
+	} else {
+		mgp->fw_multicast_support = 1;
+	}
 	if (status) {
 		printk(KERN_ERR "myri10ge: %s: Couldn't set stats DMA\n",
 		       dev->name);
@@ -2177,9 +2196,81 @@
 
 static void myri10ge_set_multicast_list(struct net_device *dev)
 {
+	struct myri10ge_cmd cmd;
+	struct myri10ge_priv *mgp;
+	struct dev_mc_list *mc_list;
+	int err;
+
+	mgp = netdev_priv(dev);
 	/* can be called from atomic contexts,
 	 * pass 1 to force atomicity in myri10ge_send_cmd() */
-	myri10ge_change_promisc(netdev_priv(dev), dev->flags & IFF_PROMISC, 1);
+	myri10ge_change_promisc(mgp, dev->flags & IFF_PROMISC, 1);
+
+	/* This firmware is known to not support multicast */
+	if (!mgp->fw_multicast_support)
+		return;
+
+	/* Disable multicast filtering */
+
+	err = myri10ge_send_cmd(mgp, MXGEFW_ENABLE_ALLMULTI, &cmd, 1);
+	if (err != 0) {
+		printk(KERN_ERR "myri10ge: %s: Failed MXGEFW_ENABLE_ALLMULTI,"
+		       " error status: %d\n", dev->name, err);
+		goto abort;
+	}
+
+	if (dev->flags & IFF_ALLMULTI) {
+		/* request to disable multicast filtering, so quit here */
+		return;
+	}
+
+	/* Flush the filters */
+
+	err = myri10ge_send_cmd(mgp, MXGEFW_LEAVE_ALL_MULTICAST_GROUPS,
+				&cmd, 1);
+	if (err != 0) {
+		printk(KERN_ERR
+		       "myri10ge: %s: Failed MXGEFW_LEAVE_ALL_MULTICAST_GROUPS"
+		       ", error status: %d\n", dev->name, err);
+		goto abort;
+	}
+
+	/* Walk the multicast list, and add each address */
+	for (mc_list = dev->mc_list; mc_list != NULL; mc_list = mc_list->next) {
+		memcpy(&cmd.data0, &mc_list->dmi_addr, 4);
+		memcpy(&cmd.data1, ((char *)&mc_list->dmi_addr) + 4, 2);
+		cmd.data0 = htonl(cmd.data0);
+		cmd.data1 = htonl(cmd.data1);
+		err = myri10ge_send_cmd(mgp, MXGEFW_JOIN_MULTICAST_GROUP,
+					&cmd, 1);
+
+		if (err != 0) {
+			printk(KERN_ERR "myri10ge: %s: Failed "
+			       "MXGEFW_JOIN_MULTICAST_GROUP, error status:"
+			       "%d\t", dev->name, err);
+			printk(KERN_ERR "MAC %02x:%02x:%02x:%02x:%02x:%02x\n",
+			       ((unsigned char *)&mc_list->dmi_addr)[0],
+			       ((unsigned char *)&mc_list->dmi_addr)[1],
+			       ((unsigned char *)&mc_list->dmi_addr)[2],
+			       ((unsigned char *)&mc_list->dmi_addr)[3],
+			       ((unsigned char *)&mc_list->dmi_addr)[4],
+			       ((unsigned char *)&mc_list->dmi_addr)[5]
+			    );
+			goto abort;
+		}
+	}
+	/* Enable multicast filtering */
+	err = myri10ge_send_cmd(mgp, MXGEFW_DISABLE_ALLMULTI, &cmd, 1);
+	if (err != 0) {
+		printk(KERN_ERR "myri10ge: %s: Failed MXGEFW_DISABLE_ALLMULTI,"
+		       "error status: %d\n", dev->name, err);
+		goto abort;
+	}
+
+	return;
+
+abort:
+	return;
 }
 
 static int myri10ge_set_mac_address(struct net_device *dev, void *addr)
Index: linux-mm/drivers/net/myri10ge/myri10ge_mcp.h
===================================================================
--- linux-mm.orig/drivers/net/myri10ge/myri10ge_mcp.h	2006-08-21 17:13:53.000000000 -0400
+++ linux-mm/drivers/net/myri10ge/myri10ge_mcp.h	2006-08-21 17:14:18.000000000 -0400
@@ -166,7 +166,7 @@
 	MXGEFW_CMD_SET_MTU,
 	MXGEFW_CMD_GET_INTR_COAL_DELAY_OFFSET,	/* in microseconds */
 	MXGEFW_CMD_SET_STATS_INTERVAL,	/* in microseconds */
-	MXGEFW_CMD_SET_STATS_DMA,
+	MXGEFW_CMD_SET_STATS_DMA_OBSOLETE,	/* replaced by SET_STATS_DMA_V2 */
 
 	MXGEFW_ENABLE_PROMISC,
 	MXGEFW_DISABLE_PROMISC,
@@ -180,7 +180,26 @@
 	 * data2       = RDMA length (MSH), WDMA length (LSH)
 	 * command return data = repetitions (MSH), 0.5-ms ticks (LSH)
 	 */
-	MXGEFW_DMA_TEST
+	MXGEFW_DMA_TEST,
+
+	MXGEFW_ENABLE_ALLMULTI,
+	MXGEFW_DISABLE_ALLMULTI,
+
+	/* returns MXGEFW_CMD_ERROR_MULTICAST
+	 * if there is no room in the cache
+	 * data0,MSH(data1) = multicast group address */
+	MXGEFW_JOIN_MULTICAST_GROUP,
+	/* returns MXGEFW_CMD_ERROR_MULTICAST
+	 * if the address is not in the cache,
+	 * or is equal to FF-FF-FF-FF-FF-FF
+	 * data0,MSH(data1) = multicast group address */
+	MXGEFW_LEAVE_MULTICAST_GROUP,
+	MXGEFW_LEAVE_ALL_MULTICAST_GROUPS,
+
+	MXGEFW_CMD_SET_STATS_DMA_V2,
+	/* data0, data1 = bus addr,
+	 * data2 = sizeof(struct mcp_irq_data) from driver point of view, allows
+	 * adding new stuff to mcp_irq_data without changing the ABI */
 };
 
 enum myri10ge_mcp_cmd_status {
@@ -192,11 +211,17 @@
 	MXGEFW_CMD_ERROR_CLOSED,
 	MXGEFW_CMD_ERROR_HASH_ERROR,
 	MXGEFW_CMD_ERROR_BAD_PORT,
-	MXGEFW_CMD_ERROR_RESOURCES
+	MXGEFW_CMD_ERROR_RESOURCES,
+	MXGEFW_CMD_ERROR_MULTICAST
 };
 
-/* 40 Bytes */
+#define MXGEFW_OLD_IRQ_DATA_LEN 40
+
 struct mcp_irq_data {
+	/* add new counters at the beginning */
+	u32 future_use[5];
+	u32 dropped_multicast_filtered;
+	/* 40 Bytes */
 	u32 send_done_count;
 
 	u32 link_up;


