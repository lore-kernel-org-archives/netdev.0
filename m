From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH v2 10/17] ixgbe: Replace ndo_add/del_vxlan_port
 with ndo_add/del_udp_enc_port
Date: Wed, 15 Jun 2016 15:08:20 -0700
Message-ID: <20160615220820.15575.82160.stgit@localhost.localdomain>
References: <20160615220449.15575.17031.stgit@localhost.localdomain>
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
Received: from mail-pf0-f169.google.com ([209.85.192.169]:36195 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932084AbcFOWIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 18:08:22 -0400
Received: by mail-pf0-f169.google.com with SMTP id t190so12749725pfb.3
        for <netdev@vger.kernel.org>; Wed, 15 Jun 2016 15:08:22 -0700 (PDT)
In-Reply-To: <20160615220449.15575.17031.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change replaces the network device operations for adding or removing a
VXLAN port with operations that are more generically defined to be used for
any UDP offload port but provide a type.  As such by just adding a line to
verify that the offload type is VXLAN we can maintain the same
functionality.

In addition I updated the socket address family check so that instead of
excluding IPv6 we instead abort of type is not IPv4.  This makes much more
sense as we should only be supporting IPv4 outer addresses on this
hardware.

The last change is that I pulled the rtnl_lock/unlock into the conditional
statement for IXGBE_FLAG2_VXLAN_REREG_NEEDED.  The motivation behind this
is to avoid unneeded bouncing of the mutex which will just slow down the
handling of this call anyway.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/intel/Kconfig            |   11 -----
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   57 +++++++++++--------------
 2 files changed, 26 insertions(+), 42 deletions(-)

diff --git a/drivers/net/ethernet/intel/Kconfig b/drivers/net/ethernet/intel/Kconfig
index 1fbf9088a4d7..c0e17433f623 100644
--- a/drivers/net/ethernet/intel/Kconfig
+++ b/drivers/net/ethernet/intel/Kconfig
@@ -167,17 +167,6 @@ config IXGBE
 	  To compile this driver as a module, choose M here. The module
 	  will be called ixgbe.
 
-config IXGBE_VXLAN
-	bool "Virtual eXtensible Local Area Network Support"
-	default n
-	depends on IXGBE && VXLAN && !(IXGBE=y && VXLAN=m)
-	---help---
-	  This allows one to create VXLAN virtual interfaces that provide
-	  Layer 2 Networks over Layer 3 Networks. VXLAN is often used
-	  to tunnel virtual network infrastructure in virtualized environments.
-	  Say Y here if you want to use Virtual eXtensible Local Area Network
-	  (VXLAN) in the driver.
-
 config IXGBE_HWMON
 	bool "Intel(R) 10GbE PCI Express adapters HWMON support"
 	default y
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index b488b52974f7..fd5a761c68f3 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -50,7 +50,7 @@
 #include <linux/if_bridge.h>
 #include <linux/prefetch.h>
 #include <scsi/fc/fc_fcoe.h>
-#include <net/vxlan.h>
+#include <net/udp_tunnel.h>
 #include <net/pkt_cls.h>
 #include <net/tc_act/tc_gact.h>
 #include <net/tc_act/tc_mirred.h>
@@ -5722,9 +5722,7 @@ static int ixgbe_sw_init(struct ixgbe_adapter *adapter)
 #ifdef CONFIG_IXGBE_DCA
 		adapter->flags &= ~IXGBE_FLAG_DCA_CAPABLE;
 #endif
-#ifdef CONFIG_IXGBE_VXLAN
 		adapter->flags |= IXGBE_FLAG_VXLAN_OFFLOAD_CAPABLE;
-#endif
 		break;
 	default:
 		break;
@@ -6158,9 +6156,7 @@ int ixgbe_open(struct net_device *netdev)
 	ixgbe_up_complete(adapter);
 
 	ixgbe_clear_vxlan_port(adapter);
-#ifdef CONFIG_IXGBE_VXLAN
-	vxlan_get_rx_port(netdev);
-#endif
+	udp_tunnel_get_rx_info(netdev);
 
 	return 0;
 
@@ -7262,14 +7258,12 @@ static void ixgbe_service_task(struct work_struct *work)
 		ixgbe_service_event_complete(adapter);
 		return;
 	}
-#ifdef CONFIG_IXGBE_VXLAN
-	rtnl_lock();
 	if (adapter->flags2 & IXGBE_FLAG2_VXLAN_REREG_NEEDED) {
+		rtnl_lock();
 		adapter->flags2 &= ~IXGBE_FLAG2_VXLAN_REREG_NEEDED;
-		vxlan_get_rx_port(adapter->netdev);
+		udp_tunnel_get_rx_info(adapter->netdev);
+		rtnl_unlock();
 	}
-	rtnl_unlock();
-#endif /* CONFIG_IXGBE_VXLAN */
 	ixgbe_reset_subtask(adapter);
 	ixgbe_phy_interrupt_subtask(adapter);
 	ixgbe_sfp_detection_subtask(adapter);
@@ -7697,7 +7691,6 @@ static void ixgbe_atr(struct ixgbe_ring *ring,
 	/* snag network header to get L4 type and address */
 	skb = first->skb;
 	hdr.network = skb_network_header(skb);
-#ifdef CONFIG_IXGBE_VXLAN
 	if (skb->encapsulation &&
 	    first->protocol == htons(ETH_P_IP) &&
 	    hdr.ipv4->protocol != IPPROTO_UDP) {
@@ -7708,7 +7701,6 @@ static void ixgbe_atr(struct ixgbe_ring *ring,
 		    udp_hdr(skb)->dest == adapter->vxlan_port)
 			hdr.network = skb_inner_network_header(skb);
 	}
-#endif /* CONFIG_IXGBE_VXLAN */
 
 	/* Currently only IPv4/IPv6 with TCP is supported */
 	switch (hdr.ipv4->version) {
@@ -8840,14 +8832,12 @@ static int ixgbe_set_features(struct net_device *netdev,
 
 	netdev->features = features;
 
-#ifdef CONFIG_IXGBE_VXLAN
 	if ((adapter->flags & IXGBE_FLAG_VXLAN_OFFLOAD_CAPABLE)) {
 		if (features & NETIF_F_RXCSUM)
 			adapter->flags2 |= IXGBE_FLAG2_VXLAN_REREG_NEEDED;
 		else
 			ixgbe_clear_vxlan_port(adapter);
 	}
-#endif /* CONFIG_IXGBE_VXLAN */
 
 	if (need_reset)
 		ixgbe_do_reset(netdev);
@@ -8858,23 +8848,27 @@ static int ixgbe_set_features(struct net_device *netdev,
 	return 0;
 }
 
-#ifdef CONFIG_IXGBE_VXLAN
 /**
  * ixgbe_add_vxlan_port - Get notifications about VXLAN ports that come up
  * @dev: The port's netdev
  * @sa_family: Socket Family that VXLAN is notifiying us about
  * @port: New UDP port number that VXLAN started listening to
+ * @type: Enumerated type specifying UDP tunnel type
  **/
-static void ixgbe_add_vxlan_port(struct net_device *dev, sa_family_t sa_family,
-				 __be16 port)
+static void ixgbe_add_vxlan_port(struct net_device *dev,
+				 struct udp_tunnel_info *ti)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
 	struct ixgbe_hw *hw = &adapter->hw;
+	__be16 port = ti->port;
 
-	if (!(adapter->flags & IXGBE_FLAG_VXLAN_OFFLOAD_CAPABLE))
+	if (ti->type != UDP_TUNNEL_TYPE_VXLAN)
 		return;
 
-	if (sa_family == AF_INET6)
+	if (ti->sa_family != AF_INET)
+		return;
+
+	if (!(adapter->flags & IXGBE_FLAG_VXLAN_OFFLOAD_CAPABLE))
 		return;
 
 	if (adapter->vxlan_port == port)
@@ -8896,28 +8890,31 @@ static void ixgbe_add_vxlan_port(struct net_device *dev, sa_family_t sa_family,
  * @dev: The port's netdev
  * @sa_family: Socket Family that VXLAN is notifying us about
  * @port: UDP port number that VXLAN stopped listening to
+ * @type: Enumerated type specifying UDP tunnel type
  **/
-static void ixgbe_del_vxlan_port(struct net_device *dev, sa_family_t sa_family,
-				 __be16 port)
+static void ixgbe_del_vxlan_port(struct net_device *dev,
+				 struct udp_tunnel_info *ti)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
 
-	if (!(adapter->flags & IXGBE_FLAG_VXLAN_OFFLOAD_CAPABLE))
+	if (ti->type != UDP_TUNNEL_TYPE_VXLAN)
 		return;
 
-	if (sa_family == AF_INET6)
+	if (ti->sa_family != AF_INET)
 		return;
 
-	if (adapter->vxlan_port != port) {
+	if (!(adapter->flags & IXGBE_FLAG_VXLAN_OFFLOAD_CAPABLE))
+		return;
+
+	if (adapter->vxlan_port != ti->port) {
 		netdev_info(dev, "Port %d was not found, not deleting\n",
-			    ntohs(port));
+			    ntohs(ti->port));
 		return;
 	}
 
 	ixgbe_clear_vxlan_port(adapter);
 	adapter->flags2 |= IXGBE_FLAG2_VXLAN_REREG_NEEDED;
 }
-#endif /* CONFIG_IXGBE_VXLAN */
 
 static int ixgbe_ndo_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 			     struct net_device *dev,
@@ -9230,10 +9227,8 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_bridge_getlink	= ixgbe_ndo_bridge_getlink,
 	.ndo_dfwd_add_station	= ixgbe_fwd_add,
 	.ndo_dfwd_del_station	= ixgbe_fwd_del,
-#ifdef CONFIG_IXGBE_VXLAN
-	.ndo_add_vxlan_port	= ixgbe_add_vxlan_port,
-	.ndo_del_vxlan_port	= ixgbe_del_vxlan_port,
-#endif /* CONFIG_IXGBE_VXLAN */
+	.ndo_udp_tunnel_add	= ixgbe_add_vxlan_port,
+	.ndo_udp_tunnel_del	= ixgbe_del_vxlan_port,
 	.ndo_features_check	= ixgbe_features_check,
 };
 
