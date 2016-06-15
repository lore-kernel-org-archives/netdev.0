From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH v2 08/17] fm10k: Replace ndo_add/del_vxlan_port
 with ndo_add/del_udp_enc_port
Date: Wed, 15 Jun 2016 15:08:06 -0700
Message-ID: <20160615220806.15575.6984.stgit@localhost.localdomain>
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
Received: from mail-pf0-f174.google.com ([209.85.192.174]:36169 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932084AbcFOWIL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 18:08:11 -0400
Received: by mail-pf0-f174.google.com with SMTP id t190so12748349pfb.3
        for <netdev@vger.kernel.org>; Wed, 15 Jun 2016 15:08:11 -0700 (PDT)
In-Reply-To: <20160615220449.15575.17031.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change replaces the network device operations for adding or removing a
VXLAN port with operations that are more generically defined to be used for
any UDP offload port but provide a type.  As such by just adding a line to
verify that the offload type if VXLAN we can maintain the same
functionality.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/intel/Kconfig              |   11 -------
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c |   36 +++++++++++++----------
 2 files changed, 20 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/intel/Kconfig b/drivers/net/ethernet/intel/Kconfig
index 714bd1014ddb..11fc5e8ea968 100644
--- a/drivers/net/ethernet/intel/Kconfig
+++ b/drivers/net/ethernet/intel/Kconfig
@@ -307,15 +307,4 @@ config FM10K
 	  To compile this driver as a module, choose M here. The module
 	  will be called fm10k.  MSI-X interrupt support is required
 
-config FM10K_VXLAN
-	bool "Virtual eXtensible Local Area Network Support"
-	default n
-	depends on FM10K && VXLAN && !(FM10K=y && VXLAN=m)
-	---help---
-	  This allows one to create VXLAN virtual interfaces that provide
-	  Layer 2 Networks over Layer 3 Networks. VXLAN is often used
-	  to tunnel virtual network infrastructure in virtualized environments.
-	  Say Y here if you want to use Virtual eXtensible Local Area Network
-	  (VXLAN) in the driver.
-
 endif # NET_VENDOR_INTEL
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index 2a08d3f5b6df..d00cb193da9a 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -20,9 +20,7 @@
 
 #include "fm10k.h"
 #include <linux/vmalloc.h>
-#ifdef CONFIG_FM10K_VXLAN
-#include <net/vxlan.h>
-#endif /* CONFIG_FM10K_VXLAN */
+#include <net/udp_tunnel.h>
 
 /**
  * fm10k_setup_tx_resources - allocate Tx resources (Descriptors)
@@ -436,6 +434,7 @@ static void fm10k_restore_vxlan_port(struct fm10k_intfc *interface)
  * @netdev: network interface device structure
  * @sa_family: Address family of new port
  * @port: port number used for VXLAN
+ * @type: Enumerated value specifying udp encapsulation type
  *
  * This function is called when a new VXLAN interface has added a new port
  * number to the range that is currently in use for VXLAN.  The new port
@@ -444,18 +443,21 @@ static void fm10k_restore_vxlan_port(struct fm10k_intfc *interface)
  * is always used as the VXLAN port number for offloads.
  **/
 static void fm10k_add_vxlan_port(struct net_device *dev,
-				 sa_family_t sa_family, __be16 port) {
+				 struct udp_tunnel_info *ti)
+{
 	struct fm10k_intfc *interface = netdev_priv(dev);
 	struct fm10k_vxlan_port *vxlan_port;
 
+	if (ti->type != UDP_TUNNEL_TYPE_VXLAN)
+		return;
 	/* only the PF supports configuring tunnels */
 	if (interface->hw.mac.type != fm10k_mac_pf)
 		return;
 
 	/* existing ports are pulled out so our new entry is always last */
 	fm10k_vxlan_port_for_each(vxlan_port, interface) {
-		if ((vxlan_port->port == port) &&
-		    (vxlan_port->sa_family == sa_family)) {
+		if ((vxlan_port->port == ti->port) &&
+		    (vxlan_port->sa_family == ti->sa_family)) {
 			list_del(&vxlan_port->list);
 			goto insert_tail;
 		}
@@ -465,8 +467,8 @@ static void fm10k_add_vxlan_port(struct net_device *dev,
 	vxlan_port = kmalloc(sizeof(*vxlan_port), GFP_ATOMIC);
 	if (!vxlan_port)
 		return;
-	vxlan_port->port = port;
-	vxlan_port->sa_family = sa_family;
+	vxlan_port->port = ti->port;
+	vxlan_port->sa_family = ti->sa_family;
 
 insert_tail:
 	/* add new port value to list */
@@ -480,6 +482,7 @@ insert_tail:
  * @netdev: network interface device structure
  * @sa_family: Address family of freed port
  * @port: port number used for VXLAN
+ * @type: Enumerated value specifying udp encapsulation type
  *
  * This function is called when a new VXLAN interface has freed a port
  * number from the range that is currently in use for VXLAN.  The freed
@@ -487,17 +490,20 @@ insert_tail:
  * the port number for offloads.
  **/
 static void fm10k_del_vxlan_port(struct net_device *dev,
-				 sa_family_t sa_family, __be16 port) {
+				 struct udp_tunnel_info *ti)
+{
 	struct fm10k_intfc *interface = netdev_priv(dev);
 	struct fm10k_vxlan_port *vxlan_port;
 
+	if (ti->type != UDP_TUNNEL_TYPE_VXLAN)
+		return;
 	if (interface->hw.mac.type != fm10k_mac_pf)
 		return;
 
 	/* find the port in the list and free it */
 	fm10k_vxlan_port_for_each(vxlan_port, interface) {
-		if ((vxlan_port->port == port) &&
-		    (vxlan_port->sa_family == sa_family)) {
+		if ((vxlan_port->port == ti->port) &&
+		    (vxlan_port->sa_family == ti->sa_family)) {
 			list_del(&vxlan_port->list);
 			kfree(vxlan_port);
 			break;
@@ -553,10 +559,8 @@ int fm10k_open(struct net_device *netdev)
 	if (err)
 		goto err_set_queues;
 
-#ifdef CONFIG_FM10K_VXLAN
 	/* update VXLAN port configuration */
-	vxlan_get_rx_port(netdev);
-#endif
+	udp_tunnel_get_rx_info(netdev);
 
 	fm10k_up(interface);
 
@@ -1375,8 +1379,8 @@ static const struct net_device_ops fm10k_netdev_ops = {
 	.ndo_set_vf_vlan	= fm10k_ndo_set_vf_vlan,
 	.ndo_set_vf_rate	= fm10k_ndo_set_vf_bw,
 	.ndo_get_vf_config	= fm10k_ndo_get_vf_config,
-	.ndo_add_vxlan_port	= fm10k_add_vxlan_port,
-	.ndo_del_vxlan_port	= fm10k_del_vxlan_port,
+	.ndo_udp_tunnel_add	= fm10k_add_vxlan_port,
+	.ndo_udp_tunnel_del	= fm10k_del_vxlan_port,
 	.ndo_dfwd_add_station	= fm10k_dfwd_add_station,
 	.ndo_dfwd_del_station	= fm10k_dfwd_del_station,
 #ifdef CONFIG_NET_POLL_CONTROLLER
