From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 06/15] fm10k: Replace ndo_add/del_vxlan_port with
 ndo_add/del_udp_enc_port
Date: Mon, 13 Jun 2016 10:48:40 -0700
Message-ID: <20160613174840.15186.22206.stgit@localhost.localdomain>
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
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34458 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423248AbcFMRsp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 13:48:45 -0400
Received: by mail-pa0-f49.google.com with SMTP id bz2so47756775pad.1
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 10:48:45 -0700 (PDT)
In-Reply-To: <20160613173750.15186.24381.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change replaces the network device operations for adding or removing a
VXLAN port with operations that are more generically defined to be used for
any UDP offload port but provide a type.  As such by just adding a line to
verify that the offload type if VXLAN we can maintain the same
functionality.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c |   18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index 2a08d3f5b6df..dd107af28e3d 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -436,6 +436,7 @@ static void fm10k_restore_vxlan_port(struct fm10k_intfc *interface)
  * @netdev: network interface device structure
  * @sa_family: Address family of new port
  * @port: port number used for VXLAN
+ * @type: Enumerated value specifying udp encapsulation type
  *
  * This function is called when a new VXLAN interface has added a new port
  * number to the range that is currently in use for VXLAN.  The new port
@@ -444,10 +445,13 @@ static void fm10k_restore_vxlan_port(struct fm10k_intfc *interface)
  * is always used as the VXLAN port number for offloads.
  **/
 static void fm10k_add_vxlan_port(struct net_device *dev,
-				 sa_family_t sa_family, __be16 port) {
+				 sa_family_t sa_family, __be16 port,
+				 unsigned int type) {
 	struct fm10k_intfc *interface = netdev_priv(dev);
 	struct fm10k_vxlan_port *vxlan_port;
 
+	if (type != UDP_ENC_OFFLOAD_TYPE_VXLAN)
+		return;
 	/* only the PF supports configuring tunnels */
 	if (interface->hw.mac.type != fm10k_mac_pf)
 		return;
@@ -480,6 +484,7 @@ insert_tail:
  * @netdev: network interface device structure
  * @sa_family: Address family of freed port
  * @port: port number used for VXLAN
+ * @type: Enumerated value specifying udp encapsulation type
  *
  * This function is called when a new VXLAN interface has freed a port
  * number from the range that is currently in use for VXLAN.  The freed
@@ -487,10 +492,13 @@ insert_tail:
  * the port number for offloads.
  **/
 static void fm10k_del_vxlan_port(struct net_device *dev,
-				 sa_family_t sa_family, __be16 port) {
+				 sa_family_t sa_family, __be16 port,
+				 unsigned int type) {
 	struct fm10k_intfc *interface = netdev_priv(dev);
 	struct fm10k_vxlan_port *vxlan_port;
 
+	if (type != UDP_ENC_OFFLOAD_TYPE_VXLAN)
+		return;
 	if (interface->hw.mac.type != fm10k_mac_pf)
 		return;
 
@@ -555,7 +563,7 @@ int fm10k_open(struct net_device *netdev)
 
 #ifdef CONFIG_FM10K_VXLAN
 	/* update VXLAN port configuration */
-	vxlan_get_rx_port(netdev);
+	udp_tunnel_get_rx_port(netdev);
 #endif
 
 	fm10k_up(interface);
@@ -1375,8 +1383,8 @@ static const struct net_device_ops fm10k_netdev_ops = {
 	.ndo_set_vf_vlan	= fm10k_ndo_set_vf_vlan,
 	.ndo_set_vf_rate	= fm10k_ndo_set_vf_bw,
 	.ndo_get_vf_config	= fm10k_ndo_get_vf_config,
-	.ndo_add_vxlan_port	= fm10k_add_vxlan_port,
-	.ndo_del_vxlan_port	= fm10k_del_vxlan_port,
+	.ndo_add_udp_enc_port	= fm10k_add_vxlan_port,
+	.ndo_del_udp_enc_port	= fm10k_del_vxlan_port,
 	.ndo_dfwd_add_station	= fm10k_dfwd_add_station,
 	.ndo_dfwd_del_station	= fm10k_dfwd_del_station,
 #ifdef CONFIG_NET_POLL_CONTROLLER
