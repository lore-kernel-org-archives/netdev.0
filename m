From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCHv2 06/11] netxen: remove netxen_nic_isr.c
Date: Fri, 18 Jul 2008 16:44:04 -0700
Message-ID: <1216424649-4597-7-git-send-email-dhananjay@netxen.com>
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.209.101.202] ([64.209.101.202]:55552 "EHLO unm84.unminc.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756775AbYGRXoL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jul 2008 19:44:11 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It had only couple of functions which are moved to main.c

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/Makefile          |    2 +-
 drivers/net/netxen/netxen_nic.h      |    6 +-
 drivers/net/netxen/netxen_nic_init.c |   56 ---------
 drivers/net/netxen/netxen_nic_isr.c  |  220 ----------------------------------
 drivers/net/netxen/netxen_nic_main.c |  121 ++++++++++++++++++-
 5 files changed, 122 insertions(+), 283 deletions(-)
 delete mode 100644 drivers/net/netxen/netxen_nic_isr.c

diff --git a/drivers/net/netxen/Makefile b/drivers/net/netxen/Makefile
index a07cdc6..c63a207 100644
--- a/drivers/net/netxen/Makefile
+++ b/drivers/net/netxen/Makefile
@@ -32,4 +32,4 @@
 obj-$(CONFIG_NETXEN_NIC) := netxen_nic.o
 
 netxen_nic-y := netxen_nic_hw.o netxen_nic_main.o netxen_nic_init.o \
-	netxen_nic_isr.o netxen_nic_ethtool.o netxen_nic_niu.o
+	netxen_nic_ethtool.o netxen_nic_niu.o
diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index b23a5a4..87be0a6 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -810,8 +810,7 @@ struct netxen_hardware_context {
 	u8 revision_id;
 	u16 board_type;
 	struct netxen_board_info boardcfg;
-	u32 xg_linkup;
-	u32 qg_linksup;
+	u32 linkup;
 	/* Address of cmd ring in Phantom */
 	struct cmd_desc_type0 *cmd_desc_head;
 	dma_addr_t cmd_desc_phys_addr;
@@ -965,7 +964,6 @@ struct netxen_adapter {
 	int msi_mode;
 	int (*enable_phy_interrupts) (struct netxen_adapter *);
 	int (*disable_phy_interrupts) (struct netxen_adapter *);
-	void (*handle_phy_intr) (struct netxen_adapter *);
 	int (*macaddr_set) (struct netxen_adapter *, netxen_ethernet_macaddr_t);
 	int (*set_mtu) (struct netxen_adapter *, int);
 	int (*set_promisc) (struct netxen_adapter *, netxen_niu_prom_mode_t);
@@ -1049,8 +1047,6 @@ int netxen_niu_xgbe_enable_phy_interrupts(struct netxen_adapter *adapter);
 int netxen_niu_gbe_enable_phy_interrupts(struct netxen_adapter *adapter);
 int netxen_niu_xgbe_disable_phy_interrupts(struct netxen_adapter *adapter);
 int netxen_niu_gbe_disable_phy_interrupts(struct netxen_adapter *adapter);
-void netxen_nic_xgbe_handle_phy_intr(struct netxen_adapter *adapter);
-void netxen_nic_gbe_handle_phy_intr(struct netxen_adapter *adapter);
 int netxen_niu_gbe_phy_read(struct netxen_adapter *adapter, long reg,
 			    __u32 * readval);
 int netxen_niu_gbe_phy_write(struct netxen_adapter *adapter,
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index c6e2bc7..7c3fbc4 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -324,7 +324,6 @@ void netxen_initialize_adapter_ops(struct netxen_adapter *adapter)
 		    netxen_niu_gbe_enable_phy_interrupts;
 		adapter->disable_phy_interrupts =
 		    netxen_niu_gbe_disable_phy_interrupts;
-		adapter->handle_phy_intr = netxen_nic_gbe_handle_phy_intr;
 		adapter->macaddr_set = netxen_niu_macaddr_set;
 		adapter->set_mtu = netxen_nic_set_mtu_gb;
 		adapter->set_promisc = netxen_niu_set_promiscuous_mode;
@@ -339,7 +338,6 @@ void netxen_initialize_adapter_ops(struct netxen_adapter *adapter)
 		    netxen_niu_xgbe_enable_phy_interrupts;
 		adapter->disable_phy_interrupts =
 		    netxen_niu_xgbe_disable_phy_interrupts;
-		adapter->handle_phy_intr = netxen_nic_xgbe_handle_phy_intr;
 		adapter->macaddr_set = netxen_niu_xg_macaddr_set;
 		adapter->set_mtu = netxen_nic_set_mtu_xgb;
 		adapter->init_port = netxen_niu_xg_init_port;
@@ -1139,60 +1137,6 @@ int netxen_receive_peg_ready(struct netxen_adapter *adapter)
 	return 0;
 }
 
-static int netxen_nic_check_temp(struct netxen_adapter *adapter)
-{
-	struct net_device *netdev = adapter->netdev;
-	uint32_t temp, temp_state, temp_val;
-	int rv = 0;
-
-	temp = adapter->pci_read_normalize(adapter, CRB_TEMP_STATE);
-
-	temp_state = nx_get_temp_state(temp);
-	temp_val = nx_get_temp_val(temp);
-
-	if (temp_state == NX_TEMP_PANIC) {
-		printk(KERN_ALERT
-		       "%s: Device temperature %d degrees C exceeds"
-		       " maximum allowed. Hardware has been shut down.\n",
-		       netxen_nic_driver_name, temp_val);
-
-		netif_carrier_off(netdev);
-		netif_stop_queue(netdev);
-		rv = 1;
-	} else if (temp_state == NX_TEMP_WARN) {
-		if (adapter->temp == NX_TEMP_NORMAL) {
-			printk(KERN_ALERT
-			       "%s: Device temperature %d degrees C "
-			       "exceeds operating range."
-			       " Immediate action needed.\n",
-			       netxen_nic_driver_name, temp_val);
-		}
-	} else {
-		if (adapter->temp == NX_TEMP_WARN) {
-			printk(KERN_INFO
-			       "%s: Device temperature is now %d degrees C"
-			       " in normal range.\n", netxen_nic_driver_name,
-			       temp_val);
-		}
-	}
-	adapter->temp = temp_state;
-	return rv;
-}
-
-void netxen_watchdog_task(struct work_struct *work)
-{
-	struct netxen_adapter *adapter =
-		container_of(work, struct netxen_adapter, watchdog_task);
-
-	if ((adapter->portnum  == 0) && netxen_nic_check_temp(adapter))
-		return;
-
-	if (adapter->handle_phy_intr)
-		adapter->handle_phy_intr(adapter);
-
-	mod_timer(&adapter->watchdog_timer, jiffies + 2 * HZ);
-}
-
 /*
  * netxen_process_rcv() send the received packet to the protocol stack.
  * and if the number of receives exceeds RX_BUFFERS_REFILL, then we
diff --git a/drivers/net/netxen/netxen_nic_isr.c b/drivers/net/netxen/netxen_nic_isr.c
deleted file mode 100644
index 104c287..0000000
--- a/drivers/net/netxen/netxen_nic_isr.c
+++ /dev/null
@@ -1,220 +0,0 @@
-/*
- * Copyright (C) 2003 - 2006 NetXen, Inc.
- * All rights reserved.
- *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of the GNU General Public License
- * as published by the Free Software Foundation; either version 2
- * of the License, or (at your option) any later version.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- * GNU General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place - Suite 330, Boston,
- * MA  02111-1307, USA.
- *
- * The full GNU General Public License is included in this distribution
- * in the file called LICENSE.
- *
- * Contact Information:
- *    info@netxen.com
- * NetXen,
- * 3965 Freedom Circle, Fourth floor,
- * Santa Clara, CA 95054
- */
-
-#include <linux/netdevice.h>
-#include <linux/delay.h>
-
-#include "netxen_nic.h"
-#include "netxen_nic_hw.h"
-#include "netxen_nic_phan_reg.h"
-
-/*
- * netxen_nic_get_stats - Get System Network Statistics
- * @netdev: network interface device structure
- */
-struct net_device_stats *netxen_nic_get_stats(struct net_device *netdev)
-{
-	struct netxen_adapter *adapter = netdev_priv(netdev);
-	struct net_device_stats *stats = &adapter->net_stats;
-
-	memset(stats, 0, sizeof(*stats));
-
-	/* total packets received   */
-	stats->rx_packets = adapter->stats.no_rcv;
-	/* total packets transmitted    */
-	stats->tx_packets = adapter->stats.xmitedframes +
-		adapter->stats.xmitfinished;
-	/* total bytes received     */
-	stats->rx_bytes = adapter->stats.rxbytes;
-	/* total bytes transmitted  */
-	stats->tx_bytes = adapter->stats.txbytes;
-	/* bad packets received     */
-	stats->rx_errors = adapter->stats.rcvdbadskb;
-	/* packet transmit problems */
-	stats->tx_errors = adapter->stats.nocmddescriptor;
-	/* no space in linux buffers    */
-	stats->rx_dropped = adapter->stats.rxdropped;
-	/* no space available in linux  */
-	stats->tx_dropped = adapter->stats.txdropped;
-
-	return stats;
-}
-
-static void netxen_indicate_link_status(struct netxen_adapter *adapter,
-					u32 link)
-{
-	struct net_device *netdev = adapter->netdev;
-
-	if (link)
-		netif_carrier_on(netdev);
-	else
-		netif_carrier_off(netdev);
-}
-
-#if 0
-void netxen_handle_port_int(struct netxen_adapter *adapter, u32 enable)
-{
-	__u32 int_src;
-
-	/*  This should clear the interrupt source */
-	if (adapter->phy_read)
-		adapter->phy_read(adapter,
-				  NETXEN_NIU_GB_MII_MGMT_ADDR_INT_STATUS,
-				  &int_src);
-	if (int_src == 0) {
-		DPRINTK(INFO, "No phy interrupts for port #%d\n", portno);
-		return;
-	}
-	if (adapter->disable_phy_interrupts)
-		adapter->disable_phy_interrupts(adapter);
-
-	if (netxen_get_phy_int_jabber(int_src))
-		DPRINTK(INFO, "Jabber interrupt \n");
-
-	if (netxen_get_phy_int_polarity_changed(int_src))
-		DPRINTK(INFO, "POLARITY CHANGED int \n");
-
-	if (netxen_get_phy_int_energy_detect(int_src))
-		DPRINTK(INFO, "ENERGY DETECT INT \n");
-
-	if (netxen_get_phy_int_downshift(int_src))
-		DPRINTK(INFO, "DOWNSHIFT INT \n");
-	/* write it down later.. */
-	if ((netxen_get_phy_int_speed_changed(int_src))
-	    || (netxen_get_phy_int_link_status_changed(int_src))) {
-		__u32 status;
-
-		DPRINTK(INFO, "SPEED CHANGED OR LINK STATUS CHANGED \n");
-
-		if (adapter->phy_read
-		    && adapter->phy_read(adapter,
-					 NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
-					 &status) == 0) {
-			if (netxen_get_phy_int_link_status_changed(int_src)) {
-				if (netxen_get_phy_link(status)) {
-					printk(KERN_INFO "%s: %s Link UP\n",
-					       netxen_nic_driver_name,
-					       adapter->netdev->name);
-
-				} else {
-					printk(KERN_INFO "%s: %s Link DOWN\n",
-					       netxen_nic_driver_name,
-					       adapter->netdev->name);
-				}
-				netxen_indicate_link_status(adapter,
-							    netxen_get_phy_link
-							    (status));
-			}
-		}
-	}
-	if (adapter->enable_phy_interrupts)
-		adapter->enable_phy_interrupts(adapter);
-}
-#endif  /*  0  */
-
-static void netxen_nic_isr_other(struct netxen_adapter *adapter)
-{
-	int portno = adapter->portnum;
-	u32 val, linkup, qg_linksup;
-
-	/* verify the offset */
-	val = adapter->pci_read_normalize(adapter, CRB_XG_STATE);
-	val = val >> adapter->physical_port;
-	if (val == adapter->ahw.qg_linksup)
-		return;
-
-	qg_linksup = adapter->ahw.qg_linksup;
-	adapter->ahw.qg_linksup = val;
-	DPRINTK(INFO, "link update 0x%08x\n", val);
-
-	linkup = val & 1;
-
-	if (linkup != (qg_linksup & 1)) {
-		printk(KERN_INFO "%s: %s PORT %d link %s\n",
-		       adapter->netdev->name,
-		       netxen_nic_driver_name, portno,
-		       ((linkup == 0) ? "down" : "up"));
-		netxen_indicate_link_status(adapter, linkup);
-		if (linkup)
-			netxen_nic_set_link_parameters(adapter);
-
-	}
-}
-
-void netxen_nic_gbe_handle_phy_intr(struct netxen_adapter *adapter)
-{
-	netxen_nic_isr_other(adapter);
-}
-
-#if 0
-int netxen_nic_link_ok(struct netxen_adapter *adapter)
-{
-	switch (adapter->ahw.board_type) {
-	case NETXEN_NIC_GBE:
-		return ((adapter->ahw.qg_linksup) & 1);
-
-	case NETXEN_NIC_XGBE:
-		return ((adapter->ahw.xg_linkup) & 1);
-
-	default:
-		printk(KERN_ERR"%s: Function: %s, Unknown board type\n",
-			netxen_nic_driver_name, __FUNCTION__);
-		break;
-	}
-
-	return 0;
-}
-#endif  /*  0  */
-
-void netxen_nic_xgbe_handle_phy_intr(struct netxen_adapter *adapter)
-{
-	struct net_device *netdev = adapter->netdev;
-	u32 val;
-
-	/* WINDOW = 1 */
-	val = adapter->pci_read_normalize(adapter, CRB_XG_STATE);
-	val >>= (adapter->physical_port * 8);
-	val &= 0xff;
-
-	if (adapter->ahw.xg_linkup == 1 && val != XG_LINK_UP) {
-		printk(KERN_INFO "%s: %s NIC Link is down\n",
-		       netxen_nic_driver_name, netdev->name);
-		adapter->ahw.xg_linkup = 0;
-		if (netif_running(netdev)) {
-			netif_carrier_off(netdev);
-			netif_stop_queue(netdev);
-		}
-	} else if (adapter->ahw.xg_linkup == 0 && val == XG_LINK_UP) {
-		printk(KERN_INFO "%s: %s NIC Link is up\n",
-		       netxen_nic_driver_name, netdev->name);
-		adapter->ahw.xg_linkup = 1;
-		netif_carrier_on(netdev);
-		netif_wake_queue(netdev);
-	}
-}
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 4d32f3c..2d0963f 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -904,7 +904,7 @@ request_msi:
 		goto err_out_disable_msi;
 
 	init_timer(&adapter->watchdog_timer);
-	adapter->ahw.xg_linkup = 0;
+	adapter->ahw.linkup = 0;
 	adapter->watchdog_timer.function = &netxen_watchdog;
 	adapter->watchdog_timer.data = (unsigned long)adapter;
 	INIT_WORK(&adapter->watchdog_task, netxen_watchdog_task);
@@ -1335,6 +1335,80 @@ static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	return NETDEV_TX_OK;
 }
 
+static int netxen_nic_check_temp(struct netxen_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+	uint32_t temp, temp_state, temp_val;
+	int rv = 0;
+
+	temp = adapter->pci_read_normalize(adapter, CRB_TEMP_STATE);
+
+	temp_state = nx_get_temp_state(temp);
+	temp_val = nx_get_temp_val(temp);
+
+	if (temp_state == NX_TEMP_PANIC) {
+		printk(KERN_ALERT
+		       "%s: Device temperature %d degrees C exceeds"
+		       " maximum allowed. Hardware has been shut down.\n",
+		       netxen_nic_driver_name, temp_val);
+
+		netif_carrier_off(netdev);
+		netif_stop_queue(netdev);
+		rv = 1;
+	} else if (temp_state == NX_TEMP_WARN) {
+		if (adapter->temp == NX_TEMP_NORMAL) {
+			printk(KERN_ALERT
+			       "%s: Device temperature %d degrees C "
+			       "exceeds operating range."
+			       " Immediate action needed.\n",
+			       netxen_nic_driver_name, temp_val);
+		}
+	} else {
+		if (adapter->temp == NX_TEMP_WARN) {
+			printk(KERN_INFO
+			       "%s: Device temperature is now %d degrees C"
+			       " in normal range.\n", netxen_nic_driver_name,
+			       temp_val);
+		}
+	}
+	adapter->temp = temp_state;
+	return rv;
+}
+
+static void netxen_nic_handle_phy_intr(struct netxen_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+	u32 val, port, linkup;
+
+	port = adapter->physical_port;
+
+	val = adapter->pci_read_normalize(adapter, CRB_XG_STATE);
+	if (adapter->ahw.board_type == NETXEN_NIC_GBE)
+		linkup = (val >> port) & 1;
+	else {
+		val = (val >> port*8) & 0xff;
+		linkup = (val == XG_LINK_UP);
+	}
+
+	if (adapter->ahw.linkup && !linkup) {
+		printk(KERN_INFO "%s: %s NIC Link is down\n",
+		       netxen_nic_driver_name, netdev->name);
+		adapter->ahw.linkup = 0;
+		if (netif_running(netdev)) {
+			netif_carrier_off(netdev);
+			netif_stop_queue(netdev);
+		}
+	} else if (!adapter->ahw.linkup && linkup) {
+		printk(KERN_INFO "%s: %s NIC Link is up\n",
+		       netxen_nic_driver_name, netdev->name);
+		adapter->ahw.linkup = 1;
+		if (netif_running(netdev)) {
+			netif_carrier_on(netdev);
+			netif_wake_queue(netdev);
+		}
+	}
+}
+
 static void netxen_watchdog(unsigned long v)
 {
 	struct netxen_adapter *adapter = (struct netxen_adapter *)v;
@@ -1342,6 +1416,19 @@ static void netxen_watchdog(unsigned long v)
 	SCHEDULE_WORK(&adapter->watchdog_task);
 }
 
+void netxen_watchdog_task(struct work_struct *work)
+{
+	struct netxen_adapter *adapter =
+		container_of(work, struct netxen_adapter, watchdog_task);
+
+	if ((adapter->portnum  == 0) && netxen_nic_check_temp(adapter))
+		return;
+
+	netxen_nic_handle_phy_intr(adapter);
+
+	mod_timer(&adapter->watchdog_timer, jiffies + 2 * HZ);
+}
+
 static void netxen_tx_timeout(struct net_device *netdev)
 {
 	struct netxen_adapter *adapter = (struct netxen_adapter *)
@@ -1367,6 +1454,38 @@ static void netxen_tx_timeout_task(struct work_struct *work)
 	netif_wake_queue(adapter->netdev);
 }
 
+/*
+ * netxen_nic_get_stats - Get System Network Statistics
+ * @netdev: network interface device structure
+ */
+struct net_device_stats *netxen_nic_get_stats(struct net_device *netdev)
+{
+	struct netxen_adapter *adapter = netdev_priv(netdev);
+	struct net_device_stats *stats = &adapter->net_stats;
+
+	memset(stats, 0, sizeof(*stats));
+
+	/* total packets received   */
+	stats->rx_packets = adapter->stats.no_rcv;
+	/* total packets transmitted    */
+	stats->tx_packets = adapter->stats.xmitedframes +
+		adapter->stats.xmitfinished;
+	/* total bytes received     */
+	stats->rx_bytes = adapter->stats.rxbytes;
+	/* total bytes transmitted  */
+	stats->tx_bytes = adapter->stats.txbytes;
+	/* bad packets received     */
+	stats->rx_errors = adapter->stats.rcvdbadskb;
+	/* packet transmit problems */
+	stats->tx_errors = adapter->stats.nocmddescriptor;
+	/* no space in linux buffers    */
+	stats->rx_dropped = adapter->stats.rxdropped;
+	/* no space available in linux  */
+	stats->tx_dropped = adapter->stats.txdropped;
+
+	return stats;
+}
+
 static inline void
 netxen_handle_int(struct netxen_adapter *adapter)
 {
-- 
1.5.4.3

