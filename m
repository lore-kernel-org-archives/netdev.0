From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH v3 15/17] qlcnic: Replace ndo_add/del_vxlan_port
 with ndo_add/del_udp_enc_port
Date: Thu, 16 Jun 2016 12:23:04 -0700
Message-ID: <20160616192304.20872.39924.stgit@localhost.localdomain>
References: <20160616191851.20872.67154.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: hannes@redhat.com, jesse@kernel.org, eugenia@mellanox.com,
	jbenc@redhat.com, alexander.duyck@gmail.com, saeedm@mellanox.com,
	ariel.elior@qlogic.com, tom@herbertland.com,
	michael.chan@broadcom.com, Dept-GELinuxNICDev@qlogic.com,
	davem@davemloft.net
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34117 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753919AbcFPTXI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 15:23:08 -0400
Received: by mail-pa0-f44.google.com with SMTP id bz2so20788353pad.1
        for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 12:23:08 -0700 (PDT)
In-Reply-To: <20160616191851.20872.67154.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change replaces the network device operations for adding or removing a
VXLAN port with operations that are more generically defined to be used for
any UDP offload port but provide a type.  As such by just adding a line to
verify that the offload type is VXLAN we can maintain the same
functionality.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/qlogic/Kconfig                |   10 -------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |    2 -
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |    4 ---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |   30 +++++++++-----------
 4 files changed, 14 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/Kconfig b/drivers/net/ethernet/qlogic/Kconfig
index 613dd2874644..6ba48406899e 100644
--- a/drivers/net/ethernet/qlogic/Kconfig
+++ b/drivers/net/ethernet/qlogic/Kconfig
@@ -54,16 +54,6 @@ config QLCNIC_DCB
 	  mode of DCB is supported. PG and PFC values are related only
 	  to Tx.
 
-config QLCNIC_VXLAN
-	bool "Virtual eXtensible Local Area Network (VXLAN) offload support"
-	default n
-	depends on QLCNIC && VXLAN && !(QLCNIC=y && VXLAN=m)
-	---help---
-	  This enables hardware offload support for VXLAN protocol over QLogic's
-	  84XX series adapters.
-	  Say Y here if you want to enable hardware offload support for
-	  Virtual eXtensible Local Area Network (VXLAN) in the driver.
-
 config QLCNIC_HWMON
 	bool "QLOGIC QLCNIC 82XX and 83XX family HWMON support"
 	depends on QLCNIC && HWMON && !(QLCNIC=y && HWMON=m)
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index caf6ddb7ea76..fd973f4f16c7 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -1026,10 +1026,8 @@ struct qlcnic_ipaddr {
 #define QLCNIC_HAS_PHYS_PORT_ID		0x40000
 #define QLCNIC_TSS_RSS			0x80000
 
-#ifdef CONFIG_QLCNIC_VXLAN
 #define QLCNIC_ADD_VXLAN_PORT		0x100000
 #define QLCNIC_DEL_VXLAN_PORT		0x200000
-#endif
 
 #define QLCNIC_VLAN_FILTERING		0x800000
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
index bf892160dd5f..a496390b8632 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
@@ -1020,7 +1020,6 @@ static int qlcnic_83xx_idc_check_state_validity(struct qlcnic_adapter *adapter,
 	return 0;
 }
 
-#ifdef CONFIG_QLCNIC_VXLAN
 #define QLC_83XX_ENCAP_TYPE_VXLAN	BIT_1
 #define QLC_83XX_MATCH_ENCAP_ID		BIT_2
 #define QLC_83XX_SET_VXLAN_UDP_DPORT	BIT_3
@@ -1089,14 +1088,12 @@ static int qlcnic_set_vxlan_parsing(struct qlcnic_adapter *adapter,
 
 	return ret;
 }
-#endif
 
 static void qlcnic_83xx_periodic_tasks(struct qlcnic_adapter *adapter)
 {
 	if (adapter->fhash.fnum)
 		qlcnic_prune_lb_filters(adapter);
 
-#ifdef CONFIG_QLCNIC_VXLAN
 	if (adapter->flags & QLCNIC_ADD_VXLAN_PORT) {
 		if (qlcnic_set_vxlan_port(adapter))
 			return;
@@ -1112,7 +1109,6 @@ static void qlcnic_83xx_periodic_tasks(struct qlcnic_adapter *adapter)
 		adapter->ahw->vxlan_port = 0;
 		adapter->flags &= ~QLCNIC_DEL_VXLAN_PORT;
 	}
-#endif
 }
 
 /**
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 1c29105b6c36..3ebef27e0964 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -16,9 +16,7 @@
 #include <linux/aer.h>
 #include <linux/log2.h>
 #include <linux/pci.h>
-#ifdef CONFIG_QLCNIC_VXLAN
 #include <net/vxlan.h>
-#endif
 
 #include "qlcnic.h"
 #include "qlcnic_sriov.h"
@@ -474,13 +472,15 @@ static int qlcnic_get_phys_port_id(struct net_device *netdev,
 	return 0;
 }
 
-#ifdef CONFIG_QLCNIC_VXLAN
 static void qlcnic_add_vxlan_port(struct net_device *netdev,
-				  sa_family_t sa_family, __be16 port)
+				  struct udp_tunnel_info *ti)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
+	if (ti->type != UDP_TUNNEL_TYPE_VXLAN)
+		return;
+
 	/* Adapter supports only one VXLAN port. Use very first port
 	 * for enabling offload
 	 */
@@ -488,23 +488,26 @@ static void qlcnic_add_vxlan_port(struct net_device *netdev,
 		return;
 	if (!ahw->vxlan_port_count) {
 		ahw->vxlan_port_count = 1;
-		ahw->vxlan_port = ntohs(port);
+		ahw->vxlan_port = ntohs(ti->port);
 		adapter->flags |= QLCNIC_ADD_VXLAN_PORT;
 		return;
 	}
-	if (ahw->vxlan_port == ntohs(port))
+	if (ahw->vxlan_port == ntohs(ti->port))
 		ahw->vxlan_port_count++;
 
 }
 
 static void qlcnic_del_vxlan_port(struct net_device *netdev,
-				  sa_family_t sa_family, __be16 port)
+				  struct udp_tunnel_info *ti)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
+	if (ti->type != UDP_TUNNEL_TYPE_VXLAN)
+		return;
+
 	if (!qlcnic_encap_rx_offload(adapter) || !ahw->vxlan_port_count ||
-	    (ahw->vxlan_port != ntohs(port)))
+	    (ahw->vxlan_port != ntohs(ti->port)))
 		return;
 
 	ahw->vxlan_port_count--;
@@ -519,7 +522,6 @@ static netdev_features_t qlcnic_features_check(struct sk_buff *skb,
 	features = vlan_features_check(skb, features);
 	return vxlan_features_check(skb, features);
 }
-#endif
 
 static const struct net_device_ops qlcnic_netdev_ops = {
 	.ndo_open	   = qlcnic_open,
@@ -539,11 +541,9 @@ static const struct net_device_ops qlcnic_netdev_ops = {
 	.ndo_fdb_del		= qlcnic_fdb_del,
 	.ndo_fdb_dump		= qlcnic_fdb_dump,
 	.ndo_get_phys_port_id	= qlcnic_get_phys_port_id,
-#ifdef CONFIG_QLCNIC_VXLAN
-	.ndo_add_vxlan_port	= qlcnic_add_vxlan_port,
-	.ndo_del_vxlan_port	= qlcnic_del_vxlan_port,
+	.ndo_udp_tunnel_add	= qlcnic_add_vxlan_port,
+	.ndo_udp_tunnel_del	= qlcnic_del_vxlan_port,
 	.ndo_features_check	= qlcnic_features_check,
-#endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = qlcnic_poll_controller,
 #endif
@@ -2015,10 +2015,8 @@ qlcnic_attach(struct qlcnic_adapter *adapter)
 
 	qlcnic_create_sysfs_entries(adapter);
 
-#ifdef CONFIG_QLCNIC_VXLAN
 	if (qlcnic_encap_rx_offload(adapter))
-		vxlan_get_rx_port(netdev);
-#endif
+		udp_tunnel_get_rx_info(netdev);
 
 	adapter->is_up = QLCNIC_ADAPTER_UP_MAGIC;
 	return 0;
