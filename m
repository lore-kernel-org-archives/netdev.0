From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/14] fm10k: add support for Rx offloads on one Geneve tunnel
Date: Mon, 29 Aug 2016 02:13:43 -0700
Message-ID: <1472462026-42133-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1472462026-42133-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:56356 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756755AbcH2JNv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 29 Aug 2016 05:13:51 -0400
In-Reply-To: <1472462026-42133-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Similar to how we handle VXLAN offload, enable support for a single
Geneve tunnel.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k.h        |  1 +
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c | 30 ++++++++++++++++++++++---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c    |  3 ++-
 drivers/net/ethernet/intel/fm10k/fm10k_type.h   |  1 +
 4 files changed, 31 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index 209268a..67ff01a 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -335,6 +335,7 @@ struct fm10k_intfc {
 
 	/* UDP encapsulation port tracking information */
 	struct list_head vxlan_port;
+	struct list_head geneve_port;
 
 #ifdef CONFIG_DEBUG_FS
 	struct dentry *dbg_intfc;
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index 07c5a68..0562938 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -387,7 +387,7 @@ static void fm10k_request_glort_range(struct fm10k_intfc *interface)
  * fm10k_free_udp_port_info
  * @interface: board private structure
  *
- * This function frees the entire vxlan_port list
+ * This function frees both geneve_port and vxlan_port structures
  **/
 static void fm10k_free_udp_port_info(struct fm10k_intfc *interface)
 {
@@ -403,6 +403,17 @@ static void fm10k_free_udp_port_info(struct fm10k_intfc *interface)
 						struct fm10k_udp_port,
 						list);
 	}
+
+	/* flush all entries from geneve list */
+	port = list_first_entry_or_null(&interface->geneve_port,
+					struct fm10k_udp_port, list);
+	while (port) {
+		list_del(&port->list);
+		kfree(port);
+		port = list_first_entry_or_null(&interface->vxlan_port,
+						struct fm10k_udp_port,
+						list);
+	}
 }
 
 /**
@@ -427,6 +438,13 @@ static void fm10k_restore_udp_port_info(struct fm10k_intfc *interface)
 	fm10k_write_reg(hw, FM10K_TUNNEL_CFG,
 			(port ? ntohs(port->port) : 0) |
 			(ETH_P_TEB << FM10K_TUNNEL_CFG_NVGRE_SHIFT));
+
+	port = list_first_entry_or_null(&interface->geneve_port,
+					struct fm10k_udp_port, list);
+
+	/* restore Geneve tunnel configuration register */
+	fm10k_write_reg(hw, FM10K_TUNNEL_CFG_GENEVE,
+			(port ? ntohs(port->port) : 0));
 }
 
 static struct fm10k_udp_port *
@@ -472,8 +490,8 @@ static void fm10k_insert_tunnel_port(struct list_head *ports,
  * @ti: Tunnel endpoint information
  *
  * This function is called when a new UDP tunnel port has been added.
- * Currently we only support VXLAN and only one port will actually be
- * offloaded due to hardware restrictions.
+ * Due to hardware restrictions, only one port per type can be offloaded at
+ * once.
  **/
 static void fm10k_udp_tunnel_add(struct net_device *dev,
 				 struct udp_tunnel_info *ti)
@@ -488,6 +506,9 @@ static void fm10k_udp_tunnel_add(struct net_device *dev,
 	case UDP_TUNNEL_TYPE_VXLAN:
 		fm10k_insert_tunnel_port(&interface->vxlan_port, ti);
 		break;
+	case UDP_TUNNEL_TYPE_GENEVE:
+		fm10k_insert_tunnel_port(&interface->geneve_port, ti);
+		break;
 	default:
 		return;
 	}
@@ -517,6 +538,9 @@ static void fm10k_udp_tunnel_del(struct net_device *dev,
 	case UDP_TUNNEL_TYPE_VXLAN:
 		port = fm10k_remove_tunnel_port(&interface->vxlan_port, ti);
 		break;
+	case UDP_TUNNEL_TYPE_GENEVE:
+		port = fm10k_remove_tunnel_port(&interface->geneve_port, ti);
+		break;
 	default:
 		return;
 	}
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 860fe04..0a20ca1 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -1835,8 +1835,9 @@ static int fm10k_sw_init(struct fm10k_intfc *interface,
 	interface->tx_itr = FM10K_TX_ITR_DEFAULT;
 	interface->rx_itr = FM10K_ITR_ADAPTIVE | FM10K_RX_ITR_DEFAULT;
 
-	/* initialize vxlan_port list */
+	/* initialize udp port lists */
 	INIT_LIST_HEAD(&interface->vxlan_port);
+	INIT_LIST_HEAD(&interface->geneve_port);
 
 	netdev_rss_key_fill(rss_key, sizeof(rss_key));
 	memcpy(interface->rssrk, rss_key, sizeof(rss_key));
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_type.h b/drivers/net/ethernet/intel/fm10k/fm10k_type.h
index f4e75c4..6bb16c1 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_type.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_type.h
@@ -154,6 +154,7 @@ struct fm10k_hw;
 #define FM10K_DGLORTDEC_INNERRSS_ENABLE		0x08000000
 #define FM10K_TUNNEL_CFG	0x0040
 #define FM10K_TUNNEL_CFG_NVGRE_SHIFT		16
+#define FM10K_TUNNEL_CFG_GENEVE	0x0041
 #define FM10K_SWPRI_MAP(_n)	((_n) + 0x0050)
 #define FM10K_SWPRI_MAX		16
 #define FM10K_RSSRK(_n, _m)	(((_n) * 0x10) + (_m) + 0x0800)
-- 
2.7.4
