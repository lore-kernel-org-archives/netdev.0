From: Brice Goglin <brice@myri.com>
Subject: [PATCH 11/16] myri10ge: cleanup retrieving of firmware capabilities
Date: Fri, 09 May 2008 02:20:25 +0200
Message-ID: <482398C9.9090506@myri.com>
References: <482397A3.1050604@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1813 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933269AbYEIAqV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 May 2008 20:46:21 -0400
In-Reply-To: <482397A3.1050604@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add myri10ge_get_firmware_capabilities() to retrieve TSO6 and
interrupt slots capabilities from the firmware.

Signed-off-by: Brice Goglin <brice@myri.com>
Signed-off-by: Andrew Gallatin <gallatin@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |   42 +++++++++++++++++++++++++++++-----------
 1 file changed, 31 insertions(+), 11 deletions(-)

Index: linux-2.6/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-2.6.orig/drivers/net/myri10ge/myri10ge.c	2008-05-09 00:11:31.000000000 +0200
+++ linux-2.6/drivers/net/myri10ge/myri10ge.c	2008-05-09 00:11:37.000000000 +0200
@@ -194,6 +194,7 @@
 	int csum_flag;		/* rx_csums?            */
 	int small_bytes;
 	int big_bytes;
+	int max_intr_slots;
 	struct net_device *dev;
 	struct net_device_stats stats;
 	spinlock_t stats_lock;
@@ -634,13 +635,38 @@
 	return status;
 }
 
+int myri10ge_get_firmware_capabilities(struct myri10ge_priv *mgp)
+{
+	struct myri10ge_cmd cmd;
+	int status;
+
+	/* probe for IPv6 TSO support */
+	mgp->features = NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_TSO;
+	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_MAX_TSO6_HDR_SIZE,
+				   &cmd, 0);
+	if (status == 0) {
+		mgp->max_tso6 = cmd.data0;
+		mgp->features |= NETIF_F_TSO6;
+	}
+
+	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_RX_RING_SIZE, &cmd, 0);
+	if (status != 0) {
+		dev_err(&mgp->pdev->dev,
+			"failed MXGEFW_CMD_GET_RX_RING_SIZE\n");
+		return -ENXIO;
+	}
+
+	mgp->max_intr_slots = 2 * (cmd.data0 / sizeof(struct mcp_dma_addr));
+
+	return 0;
+}
+
 static int myri10ge_load_firmware(struct myri10ge_priv *mgp)
 {
 	char __iomem *submit;
 	__be32 buf[16] __attribute__ ((__aligned__(8)));
 	u32 dma_low, dma_high, size;
 	int status, i;
-	struct myri10ge_cmd cmd;
 
 	size = 0;
 	status = myri10ge_load_hotplug_firmware(mgp, &size);
@@ -672,6 +698,8 @@
 
 		mgp->fw_name = "adopted";
 		mgp->tx_boundary = 2048;
+		myri10ge_dummy_rdma(mgp, 1);
+		status = myri10ge_get_firmware_capabilities(mgp);
 		return status;
 	}
 
@@ -714,18 +742,10 @@
 		dev_err(&mgp->pdev->dev, "handoff failed\n");
 		return -ENXIO;
 	}
-	dev_info(&mgp->pdev->dev, "handoff confirmed\n");
 	myri10ge_dummy_rdma(mgp, 1);
+	status = myri10ge_get_firmware_capabilities(mgp);
 
-	/* probe for IPv6 TSO support */
-	mgp->features = NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_TSO;
-	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_MAX_TSO6_HDR_SIZE,
-				   &cmd, 0);
-	if (status == 0) {
-		mgp->max_tso6 = cmd.data0;
-		mgp->features |= NETIF_F_TSO6;
-	}
-	return 0;
+	return status;
 }
 
 static int myri10ge_update_mac_address(struct myri10ge_priv *mgp, u8 * addr)


