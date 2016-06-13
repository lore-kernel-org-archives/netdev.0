From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 08/15] ixgbe: Replace ndo_add/del_vxlan_port with
 ndo_add/del_udp_enc_port
Date: Mon, 13 Jun 2016 10:48:59 -0700
Message-ID: <20160613174859.15186.97125.stgit@localhost.localdomain>
References: <20160613173750.15186.24381.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: hannes@redhat.com, jesse@kernel.org, jbenc@redhat.com,
	alexander.duyck@gmail.com, saeedm@mellanox.com,
	ariel.elior@qlogic.com, tom@herbertland.com,
	Dept-GELinuxNICDev@qlogic.com, davem@davemloft.net,
	eugenia@mellanox.com
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:36194 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423248AbcFMRtI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 13:49:08 -0400
Received: by mail-pf0-f182.google.com with SMTP id t190so48306282pfb.3
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 10:49:08 -0700 (PDT)
In-Reply-To: <20160613173750.15186.24381.stgit@localhost.localdomain>
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
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   36 ++++++++++++++-----------
 1 file changed, 20 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index b488b52974f7..05f095509122 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6159,7 +6159,7 @@ int ixgbe_open(struct net_device *netdev)
 
 	ixgbe_clear_vxlan_port(adapter);
 #ifdef CONFIG_IXGBE_VXLAN
-	vxlan_get_rx_port(netdev);
+	udp_tunnel_get_rx_port(netdev);
 #endif
 
 	return 0;
@@ -7263,12 +7263,12 @@ static void ixgbe_service_task(struct work_struct *work)
 		return;
 	}
 #ifdef CONFIG_IXGBE_VXLAN
-	rtnl_lock();
 	if (adapter->flags2 & IXGBE_FLAG2_VXLAN_REREG_NEEDED) {
+		rtnl_lock();
 		adapter->flags2 &= ~IXGBE_FLAG2_VXLAN_REREG_NEEDED;
-		vxlan_get_rx_port(adapter->netdev);
+		udp_tunnel_get_rx_port(adapter->netdev);
+		rtnl_unlock();
 	}
-	rtnl_unlock();
 #endif /* CONFIG_IXGBE_VXLAN */
 	ixgbe_reset_subtask(adapter);
 	ixgbe_phy_interrupt_subtask(adapter);
@@ -8858,23 +8858,26 @@ static int ixgbe_set_features(struct net_device *netdev,
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
 static void ixgbe_add_vxlan_port(struct net_device *dev, sa_family_t sa_family,
-				 __be16 port)
+				 __be16 port, unsigned int type)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
 	struct ixgbe_hw *hw = &adapter->hw;
 
-	if (!(adapter->flags & IXGBE_FLAG_VXLAN_OFFLOAD_CAPABLE))
+	if (type != UDP_ENC_OFFLOAD_TYPE_VXLAN)
+		return;
+
+	if (sa_family != AF_INET)
 		return;
 
-	if (sa_family == AF_INET6)
+	if (!(adapter->flags & IXGBE_FLAG_VXLAN_OFFLOAD_CAPABLE))
 		return;
 
 	if (adapter->vxlan_port == port)
@@ -8896,16 +8899,20 @@ static void ixgbe_add_vxlan_port(struct net_device *dev, sa_family_t sa_family,
  * @dev: The port's netdev
  * @sa_family: Socket Family that VXLAN is notifying us about
  * @port: UDP port number that VXLAN stopped listening to
+ * @type: Enumerated type specifying UDP tunnel type
  **/
 static void ixgbe_del_vxlan_port(struct net_device *dev, sa_family_t sa_family,
-				 __be16 port)
+				 __be16 port, unsigned int type)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
 
-	if (!(adapter->flags & IXGBE_FLAG_VXLAN_OFFLOAD_CAPABLE))
+	if (type != UDP_ENC_OFFLOAD_TYPE_VXLAN)
+		return;
+
+	if (sa_family != AF_INET)
 		return;
 
-	if (sa_family == AF_INET6)
+	if (!(adapter->flags & IXGBE_FLAG_VXLAN_OFFLOAD_CAPABLE))
 		return;
 
 	if (adapter->vxlan_port != port) {
@@ -8917,7 +8924,6 @@ static void ixgbe_del_vxlan_port(struct net_device *dev, sa_family_t sa_family,
 	ixgbe_clear_vxlan_port(adapter);
 	adapter->flags2 |= IXGBE_FLAG2_VXLAN_REREG_NEEDED;
 }
-#endif /* CONFIG_IXGBE_VXLAN */
 
 static int ixgbe_ndo_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 			     struct net_device *dev,
@@ -9230,10 +9236,8 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_bridge_getlink	= ixgbe_ndo_bridge_getlink,
 	.ndo_dfwd_add_station	= ixgbe_fwd_add,
 	.ndo_dfwd_del_station	= ixgbe_fwd_del,
-#ifdef CONFIG_IXGBE_VXLAN
-	.ndo_add_vxlan_port	= ixgbe_add_vxlan_port,
-	.ndo_del_vxlan_port	= ixgbe_del_vxlan_port,
-#endif /* CONFIG_IXGBE_VXLAN */
+	.ndo_add_udp_enc_port	= ixgbe_add_vxlan_port,
+	.ndo_del_udp_enc_port	= ixgbe_del_vxlan_port,
 	.ndo_features_check	= ixgbe_features_check,
 };
 
