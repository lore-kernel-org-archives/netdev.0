From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH v2 net-next] qlcnic: Fix build failure due to undefined reference to `vxlan_get_rx_port'
Date: Tue, 1 Apr 2014 16:29:32 -0400
Message-ID: <1396384172-28007-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:23706 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751397AbaDAVGX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 17:06:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Commit 2b3d7b758c687("qlcnic: Add VXLAN Rx offload support") uses
vxlan_get_rx_port() which caused build failure when VXLAN=m.

This patch fixes the build failure by adding dependency on VXLAN
in Kconfig of qlcnic module and use vxlan_get_rx_port() and support
code accordingly.

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
v2: Cover .ndo_{add|del}_vxlan_port() and support code under
    CONFIG_QLCNIC_VXLAN check

Please apply to net-next.

Thanks,
Shahed
---
 drivers/net/ethernet/qlogic/Kconfig                |   10 ++++++++++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |    3 +++
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |    8 +++++---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |    8 ++++++++
 4 files changed, 26 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/Kconfig b/drivers/net/ethernet/qlogic/Kconfig
index f59e6be..c14bd31 100644
--- a/drivers/net/ethernet/qlogic/Kconfig
+++ b/drivers/net/ethernet/qlogic/Kconfig
@@ -56,6 +56,16 @@ config QLCNIC_DCB
 	  mode of DCB is supported. PG and PFC values are related only
 	  to Tx.
 
+config QLCNIC_VXLAN
+	bool "Virtual eXtensible Local Area Network (VXLAN) offload support"
+	default n
+	depends on QLCNIC && VXLAN && !(QLCNIC=y && VXLAN=m)
+	---help---
+	  This enables hardware offload support for VXLAN protocol over QLogic's
+	  84XX series adapters.
+	  Say Y here if you want to enable hardware offload support for
+	  Virtual eXtensible Local Area Network (VXLAN) in the driver.
+
 config QLGE
 	tristate "QLogic QLGE 10Gb Ethernet Driver Support"
 	depends on PCI
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index b9039b5..f31bb5e 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -1011,8 +1011,11 @@ struct qlcnic_ipaddr {
 #define QLCNIC_APP_CHANGED_FLAGS	0x20000
 #define QLCNIC_HAS_PHYS_PORT_ID		0x40000
 #define QLCNIC_TSS_RSS			0x80000
+
+#ifdef CONFIG_QLCNIC_VXLAN
 #define QLCNIC_ADD_VXLAN_PORT		0x100000
 #define QLCNIC_DEL_VXLAN_PORT		0x200000
+#endif
 
 #define QLCNIC_IS_MSI_FAMILY(adapter) \
 	((adapter)->flags & (QLCNIC_MSI_ENABLED | QLCNIC_MSIX_ENABLED))
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
index 2d91975..b48737d 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
@@ -1020,6 +1020,7 @@ static int qlcnic_83xx_idc_check_state_validity(struct qlcnic_adapter *adapter,
 	return 0;
 }
 
+#ifdef CONFIG_QLCNIC_VXLAN
 #define QLC_83XX_ENCAP_TYPE_VXLAN	BIT_1
 #define QLC_83XX_MATCH_ENCAP_ID		BIT_2
 #define QLC_83XX_SET_VXLAN_UDP_DPORT	BIT_3
@@ -1088,14 +1089,14 @@ static int qlcnic_set_vxlan_parsing(struct qlcnic_adapter *adapter,
 
 	return ret;
 }
+#endif
 
 static void qlcnic_83xx_periodic_tasks(struct qlcnic_adapter *adapter)
 {
-	struct qlcnic_hardware_context *ahw = adapter->ahw;
-
 	if (adapter->fhash.fnum)
 		qlcnic_prune_lb_filters(adapter);
 
+#ifdef CONFIG_QLCNIC_VXLAN
 	if (adapter->flags & QLCNIC_ADD_VXLAN_PORT) {
 		if (qlcnic_set_vxlan_port(adapter))
 			return;
@@ -1108,9 +1109,10 @@ static void qlcnic_83xx_periodic_tasks(struct qlcnic_adapter *adapter)
 		if (qlcnic_set_vxlan_parsing(adapter, false))
 			return;
 
-		ahw->vxlan_port = 0;
+		adapter->ahw->vxlan_port = 0;
 		adapter->flags &= ~QLCNIC_DEL_VXLAN_PORT;
 	}
+#endif
 }
 
 /**
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 79be451..309d056 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -21,7 +21,9 @@
 #include <linux/aer.h>
 #include <linux/log2.h>
 #include <linux/pci.h>
+#ifdef CONFIG_QLCNIC_VXLAN
 #include <net/vxlan.h>
+#endif
 
 MODULE_DESCRIPTION("QLogic 1/10 GbE Converged/Intelligent Ethernet Driver");
 MODULE_LICENSE("GPL");
@@ -462,6 +464,7 @@ static int qlcnic_get_phys_port_id(struct net_device *netdev,
 	return 0;
 }
 
+#ifdef CONFIG_QLCNIC_VXLAN
 static void qlcnic_add_vxlan_port(struct net_device *netdev,
 				  sa_family_t sa_family, __be16 port)
 {
@@ -490,6 +493,7 @@ static void qlcnic_del_vxlan_port(struct net_device *netdev,
 
 	adapter->flags |= QLCNIC_DEL_VXLAN_PORT;
 }
+#endif
 
 static const struct net_device_ops qlcnic_netdev_ops = {
 	.ndo_open	   = qlcnic_open,
@@ -509,8 +513,10 @@ static const struct net_device_ops qlcnic_netdev_ops = {
 	.ndo_fdb_del		= qlcnic_fdb_del,
 	.ndo_fdb_dump		= qlcnic_fdb_dump,
 	.ndo_get_phys_port_id	= qlcnic_get_phys_port_id,
+#ifdef CONFIG_QLCNIC_VXLAN
 	.ndo_add_vxlan_port	= qlcnic_add_vxlan_port,
 	.ndo_del_vxlan_port	= qlcnic_del_vxlan_port,
+#endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = qlcnic_poll_controller,
 #endif
@@ -1975,8 +1981,10 @@ qlcnic_attach(struct qlcnic_adapter *adapter)
 
 	qlcnic_create_sysfs_entries(adapter);
 
+#ifdef CONFIG_QLCNIC_VXLAN
 	if (qlcnic_encap_rx_offload(adapter))
 		vxlan_get_rx_port(netdev);
+#endif
 
 	adapter->is_up = QLCNIC_ADAPTER_UP_MAGIC;
 	return 0;
-- 
1.5.6
