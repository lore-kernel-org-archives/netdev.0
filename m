From: Linsys Contractor Mithlesh Thukral <mithlesh@netxen.com>
Subject: [PATCH 1/3]: Updates, removal of unsupported features and minor bug fixes.
Date: Wed, 28 Feb 2007 05:14:07 -0800
Message-ID: <200702281314.l1SDE7Et004331@dut39.unminc.com>
Cc: jeff@garzik.org, mithlesh@netxen.com, netxenproj@linsyssoft.com,
	rob@netxen.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:24806 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932263AbXB1NOI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Feb 2007 08:14:08 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NetXen: Updates, removal of unsupported features and minor bug fixes.

Signed-off-by: Mithlesh Thukral <mithlesh@netxen.com>

---
 netxen_nic.h          |    4 +
 netxen_nic_ethtool.c  |  144 +++++++++-----------------------------------------
 netxen_nic_main.c     |    4 -
 netxen_nic_phan_reg.h |    3 +
 4 files changed, 34 insertions(+), 121 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 2807ef4..81742e4 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -72,6 +72,8 @@ #define NUM_FLASH_SECTORS (64)
 #define FLASH_SECTOR_SIZE (64 * 1024)
 #define FLASH_TOTAL_SIZE  (NUM_FLASH_SECTORS * FLASH_SECTOR_SIZE)
 
+#define PHAN_VENDOR_ID 0x4040
+
 #define RCV_DESC_RINGSIZE	\
 	(sizeof(struct rcv_desc) * adapter->max_rx_desc_count)
 #define STATUS_DESC_RINGSIZE	\
@@ -82,7 +84,7 @@ #define TX_RINGSIZE	\
 	(sizeof(struct netxen_cmd_buffer) * adapter->max_tx_desc_count)
 #define RCV_BUFFSIZE	\
 	(sizeof(struct netxen_rx_buffer) * rcv_desc->max_rx_desc_count)
-#define find_diff_among(a,b,range) ((a)<(b)?((b)-(a)):((b)+(range)-(a)))
+#define find_diff_among(a,b,range) ((a)<=(b)?((b)-(a)):((b)+(range)-(a)))
 
 #define NETXEN_NETDEV_STATUS		0x1
 #define NETXEN_RCV_PRODUCER_OFFSET	0
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index 6252e9a..986ef98 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -82,8 +82,7 @@ static const struct netxen_nic_stats net
 #define NETXEN_NIC_STATS_LEN	ARRAY_SIZE(netxen_nic_gstrings_stats)
 
 static const char netxen_nic_gstrings_test[][ETH_GSTRING_LEN] = {
-	"Register_Test_offline", "EEPROM_Test_offline",
-	"Interrupt_Test_offline", "Loopback_Test_offline",
+	"Register_Test_on_offline",
 	"Link_Test_on_offline"
 };
 
@@ -394,19 +393,12 @@ netxen_nic_get_regs(struct net_device *d
 	}
 }
 
-static void
-netxen_nic_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
-{
-	wol->supported = WAKE_UCAST | WAKE_MCAST | WAKE_BCAST | WAKE_MAGIC;
-	/* options can be added depending upon the mode */
-	wol->wolopts = 0;
-}
-
 static u32 netxen_nic_test_link(struct net_device *dev)
 {
 	struct netxen_port *port = netdev_priv(dev);
 	struct netxen_adapter *adapter = port->adapter;
 	__u32 status;
+	int val;
 
 	/* read which mode */
 	if (adapter->ahw.board_type == NETXEN_NIC_GBE) {
@@ -415,11 +407,13 @@ static u32 netxen_nic_test_link(struct n
 					 NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
 					 &status) != 0)
 			return -EIO;
-		else
-			return (netxen_get_phy_link(status));
+		else {
+			val = netxen_get_phy_link(status);
+			return !val;
+		}
 	} else if (adapter->ahw.board_type == NETXEN_NIC_XGBE) {
-		int val = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_XG_STATE));
-		return val == XG_LINK_UP;
+		val = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_XG_STATE));
+		return (val == XG_LINK_UP) ? 0 : 1;
 	}
 	return -EIO;
 }
@@ -606,100 +600,21 @@ netxen_nic_set_pauseparam(struct net_dev
 
 static int netxen_nic_reg_test(struct net_device *dev)
 {
-	struct netxen_port *port = netdev_priv(dev);
-	struct netxen_adapter *adapter = port->adapter;
-	u32 data_read, data_written, save;
-	__u32 mode;
-
-	/* 
-	 * first test the "Read Only" registers by writing which mode
-	 */
-	netxen_nic_read_w0(adapter, NETXEN_NIU_MODE, &mode);
-	if (netxen_get_niu_enable_ge(mode)) {	/* GB Mode */
-		netxen_nic_read_w0(adapter,
-				   NETXEN_NIU_GB_MII_MGMT_STATUS(port->portnum),
-				   &data_read);
-
-		save = data_read;
-		if (data_read)
-			data_written = data_read & NETXEN_NIC_INVALID_DATA;
-		else
-			data_written = NETXEN_NIC_INVALID_DATA;
-		netxen_nic_write_w0(adapter,
-				    NETXEN_NIU_GB_MII_MGMT_STATUS(port->
-								  portnum),
-				    data_written);
-		netxen_nic_read_w0(adapter,
-				   NETXEN_NIU_GB_MII_MGMT_STATUS(port->portnum),
-				   &data_read);
-
-		if (data_written == data_read) {
-			netxen_nic_write_w0(adapter,
-					    NETXEN_NIU_GB_MII_MGMT_STATUS(port->
-									  portnum),
-					    save);
-
-			return 0;
-		}
-
-		/* netxen_niu_gb_mii_mgmt_indicators is read only */
-		netxen_nic_read_w0(adapter,
-				   NETXEN_NIU_GB_MII_MGMT_INDICATE(port->
-								   portnum),
-				   &data_read);
-
-		save = data_read;
-		if (data_read)
-			data_written = data_read & NETXEN_NIC_INVALID_DATA;
-		else
-			data_written = NETXEN_NIC_INVALID_DATA;
-		netxen_nic_write_w0(adapter,
-				    NETXEN_NIU_GB_MII_MGMT_INDICATE(port->
-								    portnum),
-				    data_written);
-
-		netxen_nic_read_w0(adapter,
-				   NETXEN_NIU_GB_MII_MGMT_INDICATE(port->
-								   portnum),
-				   &data_read);
-
-		if (data_written == data_read) {
-			netxen_nic_write_w0(adapter,
-					    NETXEN_NIU_GB_MII_MGMT_INDICATE
-					    (port->portnum), save);
-			return 0;
-		}
+	struct netxen_adapter *adapter = netdev_priv(dev);
+	u32 data_read, data_written;
 
-		/* netxen_niu_gb_interface_status is read only */
-		netxen_nic_read_w0(adapter,
-				   NETXEN_NIU_GB_INTERFACE_STATUS(port->
-								  portnum),
-				   &data_read);
+	netxen_nic_read_w0(adapter, NETXEN_PCIX_PH_REG(0), &data_read);
+	if ((data_read & 0xffff) != PHAN_VENDOR_ID)
+	return 1;
 
-		save = data_read;
-		if (data_read)
-			data_written = data_read & NETXEN_NIC_INVALID_DATA;
-		else
-			data_written = NETXEN_NIC_INVALID_DATA;
-		netxen_nic_write_w0(adapter,
-				    NETXEN_NIU_GB_INTERFACE_STATUS(port->
-								   portnum),
-				    data_written);
+	data_written = (u32)0xa5a5a5a5;
 
-		netxen_nic_read_w0(adapter,
-				   NETXEN_NIU_GB_INTERFACE_STATUS(port->
-								  portnum),
-				   &data_read);
+	netxen_nic_reg_write(adapter, CRB_SCRATCHPAD_TEST, data_written);
+	data_read = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_SCRATCHPAD_TEST));
+	if (data_written != data_read)
+		return 1;
 
-		if (data_written == data_read) {
-			netxen_nic_write_w0(adapter,
-					    NETXEN_NIU_GB_INTERFACE_STATUS
-					    (port->portnum), save);
-
-			return 0;
-		}
-	}			/* GB Mode */
-	return 1;
+	return 0;
 }
 
 static int netxen_nic_diag_test_count(struct net_device *dev)
@@ -713,26 +628,20 @@ netxen_nic_diag_test(struct net_device *
 {
 	if (eth_test->flags == ETH_TEST_FL_OFFLINE) {	/* offline tests */
 		/* link test */
-		if (!(data[4] = (u64) netxen_nic_test_link(dev)))
+		if ((data[1] = (u64) netxen_nic_test_link(dev)))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
-		if (netif_running(dev))
-			dev->stop(dev);
-
 		/* register tests */
-		if (!(data[0] = netxen_nic_reg_test(dev)))
+		if ((data[0] = netxen_nic_reg_test(dev)))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
-		/* other tests pass as of now */
-		data[1] = data[2] = data[3] = 1;
-		if (netif_running(dev))
-			dev->open(dev);
 	} else {		/* online tests */
-		/* link test */
-		if (!(data[4] = (u64) netxen_nic_test_link(dev)))
+		/* register tests */
+		if((data[0] = netxen_nic_reg_test(dev)))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
-		/* other tests pass by default */
-		data[0] = data[1] = data[2] = data[3] = 1;
+		/* link test */
+		if ((data[1] = (u64) netxen_nic_test_link(dev)))
+			eth_test->flags |= ETH_TEST_FL_FAILED;
 	}
 }
 
@@ -783,7 +692,6 @@ struct ethtool_ops netxen_nic_ethtool_op
 	.get_drvinfo = netxen_nic_get_drvinfo,
 	.get_regs_len = netxen_nic_get_regs_len,
 	.get_regs = netxen_nic_get_regs,
-	.get_wol = netxen_nic_get_wol,
 	.get_link = ethtool_op_get_link,
 	.get_eeprom_len = netxen_nic_get_eeprom_len,
 	.get_eeprom = netxen_nic_get_eeprom,
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 1bf3d49..2227504 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -42,8 +42,6 @@ #include "netxen_nic_phan_reg.h"
 #include <linux/dma-mapping.h>
 #include <linux/vmalloc.h>
 
-#define PHAN_VENDOR_ID 0x4040
-
 MODULE_DESCRIPTION("NetXen Multi port (1/10) Gigabit Network Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(NETXEN_NIC_LINUX_VERSIONID);
@@ -379,6 +377,8 @@ #endif
 		netdev->tx_timeout = netxen_tx_timeout;
 		netdev->watchdog_timeo = HZ;
 
+		netxen_nic_change_mtu(netdev, netdev->mtu);
+
 		SET_ETHTOOL_OPS(netdev, &netxen_nic_ethtool_ops);
 		netdev->poll = netxen_nic_poll;
 		netdev->weight = NETXEN_NETDEV_WEIGHT;
diff --git a/drivers/net/netxen/netxen_nic_phan_reg.h b/drivers/net/netxen/netxen_nic_phan_reg.h
index 7879f85..0c7c943 100644
--- a/drivers/net/netxen/netxen_nic_phan_reg.h
+++ b/drivers/net/netxen/netxen_nic_phan_reg.h
@@ -102,6 +102,9 @@ #define CRB_CMD_PRODUCER_OFFSET_1   NETX
 #define CRB_CMD_CONSUMER_OFFSET_1   NETXEN_NIC_REG(0x1b0)
 #define CRB_TEMP_STATE              NETXEN_NIC_REG(0x1b4)
 
+/* used for ethtool tests */
+#define CRB_SCRATCHPAD_TEST	    NETXEN_NIC_REG(0x280)
+
 /*
  * CrbPortPhanCntrHi/Lo is used to pass the address of HostPhantomIndex address
  * which can be read by the Phantom host to get producer/consumer indexes from
