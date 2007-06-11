From: Mithlesh Thukral <mithlesh@netxen.com>
Subject: [PATCH 2/2] NetXen: Add correct routines to setup multicast address
Date: Mon, 11 Jun 2007 03:31:42 -0700
Message-ID: <200706111031.l5BAVgKn005837@dut39.unminc.com>
Cc: amitkale@netxen.com, jeff@garzik.org, mithlesh@netxen.com,
	netxenproj@linsyssoft.com, rob@netxen.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:3482 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756983AbXFKKbn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 06:31:43 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NetXen: Add multi cast filter code
This patch adds multi cast filter code to NetXen NIC driver.
It also adds capabilities to setup the multicast address in hardware
from the host side.

Signed-off by: Mithlesh Thukral <mithlesh@netxen.com>
---

 drivers/net/netxen/netxen_nic.h     |   24 ++++
 drivers/net/netxen/netxen_nic_hdr.h |    3 
 drivers/net/netxen/netxen_nic_hw.c  |  132 +++++++++++++++++++++++++-
 3 files changed, 156 insertions(+), 3 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index a0b39ee..2fddfd1 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -261,6 +261,27 @@ #define netxen_set_msg_ctxid(config_word
 #define netxen_set_msg_opcode(config_word, val)	\
 	((config_word) &= ~(0xf<<28), (config_word) |= (val & 0xf) << 28)
 
+#define netxen_set_addr_ctl_id_pool0(config_word, val)	\
+	((config_word) &= ~3, (config_word) |= val & 0x3)
+#define netxen_set_addr_ctl_enable_xtnd_0(config_word)	\
+	((config_word) |= 1 << 2)
+#define netxen_set_addr_ctl_id_pool1(config_word, val)	\
+	((config_word) &= ~(0x3<<4), (config_word) |= (val & 0x3) << 4)
+#define netxen_set_addr_ctl_enable_xtnd_1(config_word)	\
+	((config_word) |= 1 << 6)
+#define netxen_set_addr_ctl_id_pool2(config_word, val)	\
+	((config_word) &= ~(0x3<<8), (config_word) |= (val & 0x3) << 8)
+#define netxen_set_addr_ctl_enable_xtnd_2(config_word)	\
+	((config_word) |= 1 << 10)
+#define netxen_set_addr_ctl_id_pool3(config_word, val)	\
+	((config_word) &= ~(0x3<<12), (config_word) |= (val & 0x3) << 12)
+#define netxen_set_addr_ctl_enable_xtnd_3(config_word)	\
+	((config_word) |= 1 << 14)
+#define netxen_set_addr_ctl_mode(config_word, val)	\
+	((config_word) &= ~(0x3<<26), (config_word) |= (val & 0x3) << 26)
+#define netxen_set_addr_ctl_enable_poll(config_word, val)	\
+	((config_word) &= ~(0xf<<30), (config_word) |= (val & 0xf) << 30)
+
 struct netxen_rcv_context {
 	__le64 rcv_ring_addr;
 	__le32 rcv_ring_size;
@@ -883,6 +904,9 @@ struct netxen_adapter {
 	unsigned char mac_addr[ETH_ALEN];
 	int mtu;
 	int portnum;
+	u8 promisc;
+	u8 mc_enabled;
+	u8 max_mc_count;
 
 	spinlock_t tx_lock;
 	spinlock_t lock;
diff --git a/drivers/net/netxen/netxen_nic_hdr.h b/drivers/net/netxen/netxen_nic_hdr.h
index 608e37b..2bfecbc 100644
--- a/drivers/net/netxen/netxen_nic_hdr.h
+++ b/drivers/net/netxen/netxen_nic_hdr.h
@@ -545,6 +545,9 @@ #define NETXEN_MULTICAST_ADDR_HI_1	(NETX
 #define NETXEN_MULTICAST_ADDR_HI_2	(NETXEN_CRB_NIU + 0x1018)
 #define NETXEN_MULTICAST_ADDR_HI_3	(NETXEN_CRB_NIU + 0x101c)
 
+#define NETXEN_UNICAST_ADDR_BASE	(NETXEN_CRB_NIU + 0x1080)
+#define NETXEN_MULTICAST_ADDR_BASE	(NETXEN_CRB_NIU + 0x1100)
+
 #define	NETXEN_NIU_GB_MAC_CONFIG_0(I)		\
 	(NETXEN_CRB_NIU + 0x30000 + (I)*0x10000)
 #define	NETXEN_NIU_GB_MAC_CONFIG_1(I)		\
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index baff17a..17ab06a 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -303,6 +303,110 @@ int netxen_nic_set_mac(struct net_device
 	return 0;
 }
 
+#define NETXEN_UNICAST_ADDR(port, index)	\
+	(NETXEN_UNICAST_ADDR_BASE+(port*32)+(index*8))
+
+int netxen_nic_enable_mcast_filter(struct netxen_adapter *adapter)
+{
+	u32 val = 0;
+	u16 port = physical_port[adapter->portnum];
+
+	if (adapter->mc_enabled)
+		return 0;
+	
+	netxen_set_addr_ctl_enable_poll(val, 0xf);
+
+	if (adapter->ahw.board_type == NETXEN_NIC_XGBE)
+		netxen_set_addr_ctl_mode(val, 0x3);
+	else
+		netxen_set_addr_ctl_mode(val, 0x0);
+
+	netxen_set_addr_ctl_id_pool0(val, 0x0);
+	netxen_set_addr_ctl_id_pool1(val, 0x1);
+	netxen_set_addr_ctl_id_pool2(val, 0x2);
+	netxen_set_addr_ctl_id_pool3(val, 0x3);
+
+	netxen_set_addr_ctl_enable_xtnd_0(val);
+	netxen_set_addr_ctl_enable_xtnd_1(val);
+	netxen_set_addr_ctl_enable_xtnd_2(val);
+	netxen_set_addr_ctl_enable_xtnd_3(val);
+	
+	netxen_crb_writelit_adapter(adapter, NETXEN_MAC_ADDR_CNTL_REG, val);
+	
+	val = 0xffffff;
+
+	netxen_crb_writelit_adapter(adapter, NETXEN_UNICAST_ADDR(port,0), val);
+	netxen_crb_writelit_adapter(adapter, NETXEN_UNICAST_ADDR(port,0)+4, 
+					val);
+	
+	val = 0x00;
+	val = (u32) adapter->mac_addr[0] | 
+		((u32) adapter->mac_addr[1] << 8) |
+		((u32) adapter->mac_addr[2] << 16);
+
+	netxen_crb_writelit_adapter(adapter, NETXEN_UNICAST_ADDR(port,1), val);
+
+	val = 0x00;
+	val = (u32) adapter->mac_addr[3] |
+		((u32) adapter->mac_addr[4] << 8) |
+		((u32) adapter->mac_addr[5] << 16);
+	
+	netxen_crb_writelit_adapter(adapter, NETXEN_UNICAST_ADDR(port,1) + 4,
+					val);
+
+	adapter->mc_enabled = 1;
+	return 0;
+}
+
+int netxen_nic_disable_mcast_filter(struct netxen_adapter *adapter)
+{
+	u32 val =  0;
+	u16 port = physical_port[adapter->portnum];
+
+	if(!adapter->mc_enabled)
+		return 0;
+
+	netxen_crb_writelit_adapter(adapter, NETXEN_MAC_ADDR_CNTL_REG, val);
+
+	val = (u32) adapter->mac_addr[0] | 
+		((u32) adapter->mac_addr[1] << 8) |
+		((u32) adapter->mac_addr[2] << 16);
+	netxen_crb_writelit_adapter(adapter, NETXEN_UNICAST_ADDR(port,0), val);
+
+	val = 0x00;
+	val = (u32) adapter->mac_addr[3] |
+		((u32) adapter->mac_addr[4] << 8) |
+		((u32) adapter->mac_addr[5] << 16);
+	netxen_crb_writelit_adapter(adapter, NETXEN_UNICAST_ADDR(port,0) + 4,
+					val);
+
+	adapter->mc_enabled = 0;
+	return 0;
+}
+
+#define NETXEN_MCAST_ADDR(port, index)	\
+	(NETXEN_MULTICAST_ADDR_BASE+(port*0x80)+(index*8))
+
+int netxen_nic_set_mcast_addr(struct netxen_adapter *adapter, int index, 
+				u8 *addr)
+{
+	u32 hi = 0;
+	u32 lo = 0;
+	u16 port = physical_port[adapter->portnum];
+
+	hi = (u32) addr[0] | 
+		((u32) addr[1] << 8) |
+		((u32) addr[2] << 16);
+	lo = (u32) addr[3] |
+		((u32) addr[4] << 8) |
+		((u32) addr[5] << 16);
+		  
+	netxen_crb_writelit_adapter(adapter, NETXEN_MCAST_ADDR(port,index), hi);
+	netxen_crb_writelit_adapter(adapter, NETXEN_MCAST_ADDR(port,index) + 4,
+					lo);
+	return 0;
+}
+
 /*
  * netxen_nic_set_multi - Multicast
  */
@@ -310,17 +414,39 @@ void netxen_nic_set_multi(struct net_dev
 {
 	struct netxen_adapter *adapter = netdev_priv(netdev);
 	struct dev_mc_list *mc_ptr;
+	u8 null_addr[] = {0, 0, 0, 0, 0, 0};
+	int index = 0;
 
 	mc_ptr = netdev->mc_list;
-	if (netdev->flags & IFF_PROMISC) {
-		if (adapter->set_promisc)
+	if ((netdev->flags & IFF_PROMISC) || (netdev->mc_count >
+						adapter->max_mc_count)) {
+		if (adapter->set_promisc) {
 			adapter->set_promisc(adapter,
 					     NETXEN_NIU_PROMISC_MODE);
+			netxen_nic_disable_mcast_filter(adapter);
+			return;
+		}
 	} else {
-		if (adapter->unset_promisc)
+		if ((netdev->mc_count == 0) && (adapter->unset_promisc)) {
 			adapter->unset_promisc(adapter,
 					       NETXEN_NIU_NON_PROMISC_MODE);
+			netxen_nic_disable_mcast_filter(adapter);
+			return;
+		}
 	}
+	adapter->set_promisc(adapter, NETXEN_NIU_PROMISC_MODE);
+	netxen_nic_enable_mcast_filter(adapter);
+
+	for (mc_ptr = netdev->mc_list; mc_ptr; mc_ptr = mc_ptr->next, index++)
+		netxen_nic_set_mcast_addr(adapter, index, mc_ptr->dmi_addr);
+
+	if (index != netdev->mc_count)
+		printk(KERN_ERR"%s: %s multicast address count mismatch\n",
+				netxen_nic_driver_name, netdev->name);
+
+	/* Clear out the remaining addresses	*/
+	for (; index < adapter->max_mc_count; index++)
+		netxen_nic_set_mcast_addr(adapter, index, null_addr);
 }
 
 /*
