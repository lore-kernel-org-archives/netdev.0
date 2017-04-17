From: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Subject: [PATCH net] be2net: VxLAN offload should be re-enabled when only 1 UDP port is left
Date: Mon, 17 Apr 2017 21:33:13 +0530
Message-ID: <20170417160313.1548-1-sriharsha.basavapatna@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:38455 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753266AbdDQJ2D (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 05:28:03 -0400
Received: by mail-wm0-f44.google.com with SMTP id t189so29094669wmt.1
        for <netdev@vger.kernel.org>; Mon, 17 Apr 2017 02:28:03 -0700 (PDT)
Received: from dhcp-10-192-207-73.iig.avagotech.net ([192.19.239.250])
        by smtp.gmail.com with ESMTPSA id w52sm13494395wrc.14.2017.04.17.02.27.59
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Apr 2017 02:28:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We disable VxLAN offload when more than 1 UDP port is added to the driver,
since Skyhawk doesn't support offload with multiple ports. The existing
driver design expects the user to delete all port configurations and create
a configuration with a single UDP port for VxLAN offload to be re-enabled.
Remove this restriction by tracking the ports added and re-enabling offload
when ports get deleted and only 1 port is left.

Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Reviewed-by: Sathya Perla <sathya.perla@broadcom.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |  12 ++-
 drivers/net/ethernet/emulex/benet/be_main.c | 134 +++++++++++++++++++---------
 2 files changed, 102 insertions(+), 44 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index d49528ad7821..50566243e6fa 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -567,6 +567,12 @@ struct be_error_recovery {
 /* Ethtool priv_flags */
 #define	BE_DISABLE_TPE_RECOVERY	0x1
 
+struct be_vxlan_port {
+	struct list_head list;
+	__be16 port;		/* VxLAN UDP dst port */
+	int port_aliases;	/* alias count */
+};
+
 struct be_adapter {
 	struct pci_dev *pdev;
 	struct net_device *netdev;
@@ -671,9 +677,9 @@ struct be_adapter {
 	u32 sli_family;
 	u8 hba_port_num;
 	u16 pvid;
-	__be16 vxlan_port;
-	int vxlan_port_count;
-	int vxlan_port_aliases;
+	__be16 vxlan_port;		/* offloaded vxlan port num */
+	int vxlan_port_count;		/* active vxlan port count */
+	struct list_head vxlan_port_list;	/* vxlan port list */
 	struct phy_info phy;
 	u8 wol_cap;
 	bool wol_en;
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 6be3b9aba8ed..8702661b99c0 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3857,6 +3857,44 @@ static void be_cancel_err_detection(struct be_adapter *adapter)
 	}
 }
 
+static int be_enable_vxlan_offloads(struct be_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+	struct device *dev = &adapter->pdev->dev;
+	struct be_vxlan_port *vxlan_port;
+	__be16 port;
+	int status;
+
+	vxlan_port = list_first_entry(&adapter->vxlan_port_list,
+				      struct be_vxlan_port, list);
+	port = vxlan_port->port;
+
+	status = be_cmd_manage_iface(adapter, adapter->if_handle,
+				     OP_CONVERT_NORMAL_TO_TUNNEL);
+	if (status) {
+		dev_warn(dev, "Failed to convert normal interface to tunnel\n");
+		return status;
+	}
+	adapter->flags |= BE_FLAGS_VXLAN_OFFLOADS;
+
+	status = be_cmd_set_vxlan_port(adapter, port);
+	if (status) {
+		dev_warn(dev, "Failed to add VxLAN port\n");
+		return status;
+	}
+	adapter->vxlan_port = port;
+
+	netdev->hw_enc_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
+				   NETIF_F_TSO | NETIF_F_TSO6 |
+				   NETIF_F_GSO_UDP_TUNNEL;
+	netdev->hw_features |= NETIF_F_GSO_UDP_TUNNEL;
+	netdev->features |= NETIF_F_GSO_UDP_TUNNEL;
+
+	dev_info(dev, "Enabled VxLAN offloads for UDP port %d\n",
+		 be16_to_cpu(port));
+	return 0;
+}
+
 static void be_disable_vxlan_offloads(struct be_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
@@ -4903,63 +4941,59 @@ static struct be_cmd_work *be_alloc_work(struct be_adapter *adapter,
  * those other tunnels are unexported on the fly through ndo_features_check().
  *
  * Skyhawk supports VxLAN offloads only for one UDP dport. So, if the stack
- * adds more than one port, disable offloads and don't re-enable them again
- * until after all the tunnels are removed.
+ * adds more than one port, disable offloads and re-enable them again when
+ * there's only one port left. We maintain a list of ports for this purpose.
  */
 static void be_work_add_vxlan_port(struct work_struct *work)
 {
 	struct be_cmd_work *cmd_work =
 				container_of(work, struct be_cmd_work, work);
 	struct be_adapter *adapter = cmd_work->adapter;
-	struct net_device *netdev = adapter->netdev;
 	struct device *dev = &adapter->pdev->dev;
 	__be16 port = cmd_work->info.vxlan_port;
+	struct be_vxlan_port *vxlan_port;
 	int status;
 
-	if (adapter->vxlan_port == port && adapter->vxlan_port_count) {
-		adapter->vxlan_port_aliases++;
-		goto done;
+	/* Bump up the alias count if it is an existing port */
+	list_for_each_entry(vxlan_port, &adapter->vxlan_port_list, list) {
+		if (vxlan_port->port == port) {
+			vxlan_port->port_aliases++;
+			goto done;
+		}
 	}
 
+	/* Add a new port to our list. We don't need a lock here since port
+	 * add/delete are done only in the context of a single-threaded work
+	 * queue (be_wq).
+	 */
+	vxlan_port = kzalloc(sizeof(*vxlan_port), GFP_KERNEL);
+	if (!vxlan_port)
+		goto done;
+
+	vxlan_port->port = port;
+	INIT_LIST_HEAD(&vxlan_port->list);
+	list_add_tail(&vxlan_port->list, &adapter->vxlan_port_list);
+	adapter->vxlan_port_count++;
+
 	if (adapter->flags & BE_FLAGS_VXLAN_OFFLOADS) {
 		dev_info(dev,
 			 "Only one UDP port supported for VxLAN offloads\n");
 		dev_info(dev, "Disabling VxLAN offloads\n");
-		adapter->vxlan_port_count++;
 		goto err;
 	}
 
-	if (adapter->vxlan_port_count++ >= 1)
+	if (adapter->vxlan_port_count > 1)
 		goto done;
 
-	status = be_cmd_manage_iface(adapter, adapter->if_handle,
-				     OP_CONVERT_NORMAL_TO_TUNNEL);
-	if (status) {
-		dev_warn(dev, "Failed to convert normal interface to tunnel\n");
-		goto err;
-	}
-
-	status = be_cmd_set_vxlan_port(adapter, port);
-	if (status) {
-		dev_warn(dev, "Failed to add VxLAN port\n");
-		goto err;
-	}
-	adapter->flags |= BE_FLAGS_VXLAN_OFFLOADS;
-	adapter->vxlan_port = port;
-
-	netdev->hw_enc_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
-				   NETIF_F_TSO | NETIF_F_TSO6 |
-				   NETIF_F_GSO_UDP_TUNNEL;
-	netdev->hw_features |= NETIF_F_GSO_UDP_TUNNEL;
-	netdev->features |= NETIF_F_GSO_UDP_TUNNEL;
+	status = be_enable_vxlan_offloads(adapter);
+	if (!status)
+		goto done;
 
-	dev_info(dev, "Enabled VxLAN offloads for UDP port %d\n",
-		 be16_to_cpu(port));
-	goto done;
 err:
 	be_disable_vxlan_offloads(adapter);
 done:
 	kfree(cmd_work);
+	return;
 }
 
 static void be_work_del_vxlan_port(struct work_struct *work)
@@ -4968,23 +5002,40 @@ static void be_work_del_vxlan_port(struct work_struct *work)
 				container_of(work, struct be_cmd_work, work);
 	struct be_adapter *adapter = cmd_work->adapter;
 	__be16 port = cmd_work->info.vxlan_port;
+	struct be_vxlan_port *vxlan_port;
 
-	if (adapter->vxlan_port != port)
-		goto done;
+	/* Nothing to be done if a port alias is being deleted */
+	list_for_each_entry(vxlan_port, &adapter->vxlan_port_list, list) {
+		if (vxlan_port->port == port) {
+			if (vxlan_port->port_aliases) {
+				vxlan_port->port_aliases--;
+				goto done;
+			}
+			break;
+		}
+	}
+
+	/* No port aliases left; delete the port from the list */
+	list_del(&vxlan_port->list);
+	adapter->vxlan_port_count--;
 
-	if (adapter->vxlan_port_aliases) {
-		adapter->vxlan_port_aliases--;
+	/* Disable VxLAN offload if this is the offloaded port */
+	if (adapter->vxlan_port == vxlan_port->port) {
+		WARN_ON(adapter->vxlan_port_count);
+		be_disable_vxlan_offloads(adapter);
+		dev_info(&adapter->pdev->dev,
+			 "Disabled VxLAN offloads for UDP port %d\n",
+			 be16_to_cpu(port));
 		goto out;
 	}
 
-	be_disable_vxlan_offloads(adapter);
+	/* If only 1 port is left, re-enable VxLAN offload */
+	if (adapter->vxlan_port_count == 1)
+		be_enable_vxlan_offloads(adapter);
 
-	dev_info(&adapter->pdev->dev,
-		 "Disabled VxLAN offloads for UDP port %d\n",
-		 be16_to_cpu(port));
-done:
-	adapter->vxlan_port_count--;
 out:
+	kfree(vxlan_port);
+done:
 	kfree(cmd_work);
 }
 
@@ -5626,6 +5677,7 @@ static int be_drv_init(struct be_adapter *adapter)
 	/* Must be a power of 2 or else MODULO will BUG_ON */
 	adapter->be_get_temp_freq = 64;
 
+	INIT_LIST_HEAD(&adapter->vxlan_port_list);
 	return 0;
 
 free_rx_filter:
-- 
2.11.0.258.ge05806da9
