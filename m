From: Anjali Singhai Jain <anjali.singhai@intel.com>
Subject: [PATCH v1 6/6] i40e:Add geneve tunnel offload support
Date: Mon, 23 Nov 2015 13:02:59 -0800
Message-ID: <1448312579-159544-7-git-send-email-anjali.singhai@intel.com>
References: <1448312579-159544-1-git-send-email-anjali.singhai@intel.com>
Cc: jesse@kernel.org, Anjali Singhai Jain <anjali.singhai@intel.com>,
	Kiran Patil <kiran.patil@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:52384 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755130AbbKWUqT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2015 15:46:19 -0500
In-Reply-To: <1448312579-159544-1-git-send-email-anjali.singhai@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds driver hooks to implement ndo_ops to add/del udp
port in the HW to identify GENEVE tunnels.

Also cleans up the features_check path now that we support
multiple udp based tunnels.

Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Kiran Patil <kiran.patil@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      |  1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c | 35 +++++++++++++++++++++--------
 drivers/net/ethernet/intel/i40e/i40e_txrx.c |  2 +-
 3 files changed, 28 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index c701bbb..69c2c88 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -336,6 +336,7 @@ struct i40e_pf {
 #define I40E_FLAG_MULTIPLE_TCP_UDP_RSS_PCTYPE	BIT_ULL(38)
 #define I40E_FLAG_LINK_POLLING_ENABLED		BIT_ULL(39)
 #define I40E_FLAG_VEB_MODE_ENABLED		BIT_ULL(40)
+#define I40E_FLAG_GENEVE_OFFLOAD_CAPABLE	BIT_ULL(41)
 #define I40E_FLAG_NO_PCI_LINK_CHECK		BIT_ULL(42)
 
 	/* tracks features that get auto disabled by errors */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index f6447c7..e0e40c3 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -30,6 +30,9 @@
 #if IS_ENABLED(CONFIG_VXLAN)
 #include <net/vxlan.h>
 #endif
+#if IS_ENABLED(CONFIG_GENEVE)
+#include <net/geneve.h>
+#endif
 #include <net/udp_tunnel.h>
 #include <net/protocol.h>
 
@@ -6990,7 +6993,7 @@ static void i40e_handle_mdd_event(struct i40e_pf *pf)
  **/
 static void i40e_sync_udp_filters_subtask(struct i40e_pf *pf)
 {
-#if IS_ENABLED(CONFIG_VXLAN)
+#if IS_ENABLED(CONFIG_VXLAN) || IS_ENABLED(CONFIG_GENEVE)
 	struct i40e_hw *hw = &pf->hw;
 	i40e_status ret;
 	__be16 port;
@@ -8174,7 +8177,8 @@ static int i40e_sw_init(struct i40e_pf *pf)
 			     I40E_FLAG_HW_ATR_EVICT_CAPABLE |
 			     I40E_FLAG_OUTER_UDP_CSUM_CAPABLE |
 			     I40E_FLAG_WB_ON_ITR_CAPABLE |
-			     I40E_FLAG_MULTIPLE_TCP_UDP_RSS_PCTYPE;
+			     I40E_FLAG_MULTIPLE_TCP_UDP_RSS_PCTYPE |
+			     I40E_FLAG_GENEVE_OFFLOAD_CAPABLE;
 	}
 	pf->eeprom_version = 0xDEAD;
 	pf->lan_veb = I40E_NO_VEB;
@@ -8273,7 +8277,7 @@ static int i40e_set_features(struct net_device *netdev,
 	return 0;
 }
 
-#if IS_ENABLED(CONFIG_VXLAN)
+#if IS_ENABLED(CONFIG_VXLAN) || IS_ENABLED(CONFIG_GENEVE)
 /**
  * i40e_get_udp_port_idx - Lookup a possibly offloaded for Rx UDP port
  * @pf: board private structure
@@ -8308,14 +8312,18 @@ static void i40e_add_tunnel_port(struct net_device *netdev,
 				 sa_family_t sa_family, __be16 port,
 				 u32 type)
 {
-#if IS_ENABLED(CONFIG_VXLAN)
+#if IS_ENABLED(CONFIG_VXLAN) || IS_ENABLED(CONFIG_GENEVE)
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
 	struct i40e_pf *pf = vsi->back;
 	u8 next_idx;
 	u8 idx;
 
-	if (type != UDP_TUNNEL_VXLAN)
+	if (!(type == UDP_TUNNEL_VXLAN || type == UDP_TUNNEL_GENEVE))
+		return;
+
+	if ((type == UDP_TUNNEL_GENEVE) &&
+	    (!(pf->flags & I40E_FLAG_GENEVE_OFFLOAD_CAPABLE)))
 		return;
 
 	if (sa_family == AF_INET6)
@@ -8343,6 +8351,8 @@ static void i40e_add_tunnel_port(struct net_device *netdev,
 	pf->udp_ports[next_idx].index = port;
 	if (type == UDP_TUNNEL_VXLAN)
 		pf->udp_ports[next_idx].type = I40E_AQC_TUNNEL_TYPE_VXLAN;
+	else if (type == UDP_TUNNEL_GENEVE)
+		pf->udp_ports[next_idx].type = I40E_AQC_TUNNEL_TYPE_NGE;
 
 	pf->pending_udp_bitmap |= BIT_ULL(next_idx);
 	pf->flags |= I40E_FLAG_UDP_FILTER_SYNC;
@@ -8363,13 +8373,13 @@ static void i40e_del_tunnel_port(struct net_device *netdev,
 				 sa_family_t sa_family, __be16 port,
 				 u32 type)
 {
-#if IS_ENABLED(CONFIG_VXLAN)
+#if IS_ENABLED(CONFIG_VXLAN) || IS_ENABLED(CONFIG_GENEVE)
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
 	struct i40e_pf *pf = vsi->back;
 	u8 idx;
 
-	if (type != UDP_TUNNEL_VXLAN)
+	if (!(type == UDP_TUNNEL_VXLAN || type == UDP_TUNNEL_GENEVE))
 		return;
 
 	if (sa_family == AF_INET6)
@@ -8569,7 +8579,10 @@ static int i40e_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 				       nlflags, 0, 0, filter_mask, NULL);
 }
 
-#define I40E_MAX_TUNNEL_HDR_LEN 80
+/* Hardware supports L4 tunnel length of 128B (=2^7) which includes
+ * inner mac plus all inner ethertypes.
+ */
+#define I40E_MAX_TUNNEL_HDR_LEN 128
 /**
  * i40e_features_check - Validate encapsulated packet conforms to limits
  * @skb: skb buff
@@ -8581,7 +8594,7 @@ static netdev_features_t i40e_features_check(struct sk_buff *skb,
 					     netdev_features_t features)
 {
 	if (skb->encapsulation &&
-	    (skb_inner_mac_header(skb) - skb_transport_header(skb) >
+	    ((skb_inner_network_header(skb) - skb_transport_header(skb)) >
 	     I40E_MAX_TUNNEL_HDR_LEN))
 		return features & ~(NETIF_F_ALL_CSUM | NETIF_F_GSO_MASK);
 
@@ -8651,6 +8664,7 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
 	np->vsi = vsi;
 
 	netdev->hw_enc_features |= NETIF_F_IP_CSUM	 |
+				  NETIF_F_RXCSUM	 |
 				  NETIF_F_GSO_UDP_TUNNEL |
 				  NETIF_F_GSO_GRE	 |
 				  NETIF_F_TSO;
@@ -10165,6 +10179,9 @@ static void i40e_print_features(struct i40e_pf *pf)
 #if IS_ENABLED(CONFIG_VXLAN)
 	buf += sprintf(buf, "VxLAN ");
 #endif
+#if IS_ENABLED(CONFIG_GENVE)
+	i += snprintf(&buf[i], REMAIN(i), "Geneve ");
+#endif
 	if (pf->flags & I40E_FLAG_PTP)
 		buf += sprintf(buf, "PTP ");
 #ifdef I40E_FCOE
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 46556b6..a66d590 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1374,7 +1374,7 @@ static inline void i40e_rx_checksum(struct i40e_vsi *vsi,
 	if (rx_error & BIT(I40E_RX_DESC_ERROR_PPRS_SHIFT))
 		return;
 
-	/* If VXLAN traffic has an outer UDPv4 checksum we need to check
+	/* If VXLAN/GENEVE traffic has an outer UDPv4 checksum we need to check
 	 * it in the driver, hardware does not do it for us.
 	 * Since L3L4P bit was set we assume a valid IHL value (>=5)
 	 * so the total length of IPv4 header is IHL*4 bytes
-- 
1.8.1.4
