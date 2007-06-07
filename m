From: Mithlesh Thukral <mithlesh@netxen.com>
Subject: [PATCH 1/4] NetXen: Fix link status messages
Date: Thu, 7 Jun 2007 04:30:57 -0700
Message-ID: <200706071130.l57BUvcO007523@dut39.unminc.com>
Cc: amitkale@netxen.com, jeff@garzik.org, mithlesh@netxen.com,
	netxenproj@linsyssoft.com, rob@netxen.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:22826 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753558AbXFGLa6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 07:30:58 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NetXen: Fix incorrect link status even with switch turned OFF.
NetXen driver failed to accurately indicate when a link is up or down. 
This was encountered during failover testing, when the first port 
indicated that the link was up even when the 10G switch it was assigned
to in the Bladecenter was turned off completely. 

Signed-off by: Wen Xiong <wenxiong@us.ibm.com>
Signed-off by: Mithlesh Thukral <mithlesh@netxen.com>
---

 drivers/net/netxen/netxen_nic.h      |    1 +
 drivers/net/netxen/netxen_nic_init.c |   21 +++++++++++++--------
 drivers/net/netxen/netxen_nic_isr.c  |   24 ++++++++++++++++++++++++
 3 files changed, 38 insertions(+), 8 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index ad6688e..a0b39ee 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -1048,6 +1048,7 @@ int netxen_rom_se(struct netxen_adapter 
 int netxen_do_rom_se(struct netxen_adapter *adapter, int addr);
 
 /* Functions from netxen_nic_isr.c */
+int netxen_nic_link_ok(struct netxen_adapter *adapter);
 void netxen_nic_isr_other(struct netxen_adapter *adapter);
 void netxen_indicate_link_status(struct netxen_adapter *adapter, u32 link);
 void netxen_handle_port_int(struct netxen_adapter *adapter, u32 enable);
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index a368924..0446d13 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -1036,18 +1036,23 @@ void netxen_watchdog_task(struct work_st
 	if ((adapter->portnum  == 0) && netxen_nic_check_temp(adapter))
 		return;
 
+	if (adapter->handle_phy_intr)
+		adapter->handle_phy_intr(adapter);
+
 	netdev = adapter->netdev;
-	if ((netif_running(netdev)) && !netif_carrier_ok(netdev)) {
-		printk(KERN_INFO "%s port %d, %s carrier is now ok\n",
-		       netxen_nic_driver_name, adapter->portnum, netdev->name);
+	if ((netdev->flags & IFF_UP) && !netif_carrier_ok(netdev) &&
+			netxen_nic_link_ok(adapter) ) {
+		printk(KERN_INFO "%s %s (port %d), Link is up\n",
+			       netxen_nic_driver_name, netdev->name, adapter->portnum);
 		netif_carrier_on(netdev);
-	}
-
-	if (netif_queue_stopped(netdev))
 		netif_wake_queue(netdev);
+	} else if(!(netdev->flags & IFF_UP) && netif_carrier_ok(netdev)) {
+		printk(KERN_ERR "%s %s Link is Down\n",
+				netxen_nic_driver_name, netdev->name);
+		netif_carrier_off(netdev);
+		netif_stop_queue(netdev);
+	}
 
-	if (adapter->handle_phy_intr)
-		adapter->handle_phy_intr(adapter);
 	mod_timer(&adapter->watchdog_timer, jiffies + 2 * HZ);
 }
 
diff --git a/drivers/net/netxen/netxen_nic_isr.c b/drivers/net/netxen/netxen_nic_isr.c
index b213b06..b2de6b6 100644
--- a/drivers/net/netxen/netxen_nic_isr.c
+++ b/drivers/net/netxen/netxen_nic_isr.c
@@ -169,6 +169,24 @@ void netxen_nic_gbe_handle_phy_intr(stru
 	netxen_nic_isr_other(adapter);
 }
 
+int netxen_nic_link_ok(struct netxen_adapter *adapter)
+{
+	switch (adapter->ahw.board_type) {
+	case NETXEN_NIC_GBE:
+		return ((adapter->ahw.qg_linksup) & 1);
+
+	case NETXEN_NIC_XGBE:
+		return ((adapter->ahw.xg_linkup) & 1);
+
+	default:
+		printk(KERN_ERR"%s: Function: %s, Unknown board type\n",
+			netxen_nic_driver_name, __FUNCTION__);
+		break;
+	}
+
+	return 0;
+}
+
 void netxen_nic_xgbe_handle_phy_intr(struct netxen_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
@@ -183,6 +201,10 @@ void netxen_nic_xgbe_handle_phy_intr(str
 		printk(KERN_INFO "%s: %s NIC Link is down\n",
 		       netxen_nic_driver_name, netdev->name);
 		adapter->ahw.xg_linkup = 0;
+		if (netif_running(netdev)) {
+			netif_carrier_off(netdev);
+			netif_stop_queue(netdev);
+		}
 		/* read twice to clear sticky bits */
 		/* WINDOW = 0 */
 		netxen_nic_read_w0(adapter, NETXEN_NIU_XG_STATUS, &val1);
@@ -196,5 +218,7 @@ void netxen_nic_xgbe_handle_phy_intr(str
 		printk(KERN_INFO "%s: %s NIC Link is up\n",
 		       netxen_nic_driver_name, netdev->name);
 		adapter->ahw.xg_linkup = 1;
+		netif_carrier_on(netdev);
+		netif_wake_queue(netdev);
 	}
 }
