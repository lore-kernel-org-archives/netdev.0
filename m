From: "Amit S. Kale" <amitkale@netxen.com>
Subject: [PATCH 2/2] NetXen: Updates for ethtool support
Date: Fri, 9 Feb 2007 05:49:08 -0800
Message-ID: <200702091349.l19Dn8oR010933@dut39.unminc.com>
Cc: amitkale@netxen.com, jeff@garzik.org, netxenproj@linsyssoft.com,
	rob@netxen.com, sanjeev@netxen.com, wendyx@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:23772 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1946463AbXBINtJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Feb 2007 08:49:09 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NetXen: Updates for ethtool support.

Signed-off-by: Amit S. Kale <amitkale@netxen.com>

---

 netxen_nic.h         |    1 +
 netxen_nic_ethtool.c |    9 +++++----
 netxen_nic_init.c    |    8 ++++++++
 3 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 3f3896e..e021a30 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -1040,6 +1040,7 @@ int netxen_flash_unlock(struct netxen_ad
 int netxen_backup_crbinit(struct netxen_adapter *adapter);
 int netxen_flash_erase_secondary(struct netxen_adapter *adapter);
 int netxen_flash_erase_primary(struct netxen_adapter *adapter);
+void netxen_halt_pegs(struct netxen_adapter *adapter);
 
 int netxen_rom_fast_write(struct netxen_adapter *adapter, int addr, int data);
 int netxen_rom_se(struct netxen_adapter *adapter, int addr);
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index cc0efe2..6252e9a 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -402,7 +402,7 @@ netxen_nic_get_wol(struct net_device *de
 	wol->wolopts = 0;
 }
 
-static u32 netxen_nic_get_link(struct net_device *dev)
+static u32 netxen_nic_test_link(struct net_device *dev)
 {
 	struct netxen_port *port = netdev_priv(dev);
 	struct netxen_adapter *adapter = port->adapter;
@@ -459,6 +459,7 @@ netxen_nic_set_eeprom(struct net_device 
 	int ret;
 
 	if (flash_start == 0) {
+		netxen_halt_pegs(adapter);
 		ret = netxen_flash_unlock(adapter);
 		if (ret < 0) {
 			printk(KERN_ERR "%s: Flash unlock failed.\n",
@@ -712,7 +713,7 @@ netxen_nic_diag_test(struct net_device *
 {
 	if (eth_test->flags == ETH_TEST_FL_OFFLINE) {	/* offline tests */
 		/* link test */
-		if (!(data[4] = (u64) netxen_nic_get_link(dev)))
+		if (!(data[4] = (u64) netxen_nic_test_link(dev)))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
 		if (netif_running(dev))
@@ -727,7 +728,7 @@ netxen_nic_diag_test(struct net_device *
 			dev->open(dev);
 	} else {		/* online tests */
 		/* link test */
-		if (!(data[4] = (u64) netxen_nic_get_link(dev)))
+		if (!(data[4] = (u64) netxen_nic_test_link(dev)))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
 		/* other tests pass by default */
@@ -783,7 +784,7 @@ struct ethtool_ops netxen_nic_ethtool_op
 	.get_regs_len = netxen_nic_get_regs_len,
 	.get_regs = netxen_nic_get_regs,
 	.get_wol = netxen_nic_get_wol,
-	.get_link = netxen_nic_get_link,
+	.get_link = ethtool_op_get_link,
 	.get_eeprom_len = netxen_nic_get_eeprom_len,
 	.get_eeprom = netxen_nic_get_eeprom,
 	.set_eeprom = netxen_nic_set_eeprom,
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index c243c16..2f32436 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -717,6 +717,14 @@ netxen_flash_erase_primary(struct netxen
 	return ret;
 }
 
+void netxen_halt_pegs(struct netxen_adapter *adapter)
+{
+	 netxen_crb_writelit_adapter(adapter, NETXEN_CRB_PEG_NET_0 + 0x3c, 1);
+	 netxen_crb_writelit_adapter(adapter, NETXEN_CRB_PEG_NET_1 + 0x3c, 1);
+	 netxen_crb_writelit_adapter(adapter, NETXEN_CRB_PEG_NET_2 + 0x3c, 1);
+	 netxen_crb_writelit_adapter(adapter, NETXEN_CRB_PEG_NET_3 + 0x3c, 1);
+}
+
 int netxen_flash_unlock(struct netxen_adapter *adapter)
 {
 	int ret = 0;
