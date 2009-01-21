From: Thomas Klein <tklein@de.ibm.com>
Subject: [PATCH 1/3] ehea: Use net_device_ops structure
Date: Wed, 21 Jan 2009 15:49:00 +0100
Message-ID: <200901211549.01120.tklein@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <ossthema@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	netdev <netdev@vger.kernel.org>,
	Thomas Klein <tklein@de.ibm.com>,
	Hannes Hering <hering2@de.ibm.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:37503 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755427AbZAUOwu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 09:52:50 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adapt to lately introduced net_device_ops structure.

Signed-off-by: Thomas Klein <tklein@de.ibm.com>

---
diff -Nurp -X dontdiff linux-2.6.29/drivers/net/ehea/ehea.h patched_kernel/drivers/net/ehea/ehea.h
--- linux-2.6.29/drivers/net/ehea/ehea.h	2009-01-16 12:03:27.000000000 +0100
+++ patched_kernel/drivers/net/ehea/ehea.h	2009-01-20 15:10:28.000000000 +0100
@@ -40,7 +40,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0096"
+#define DRV_VERSION	"EHEA_0097"
 
 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
diff -Nurp -X dontdiff linux-2.6.29/drivers/net/ehea/ehea_main.c patched_kernel/drivers/net/ehea/ehea_main.c
--- linux-2.6.29/drivers/net/ehea/ehea_main.c	2009-01-16 12:03:27.000000000 +0100
+++ patched_kernel/drivers/net/ehea/ehea_main.c	2009-01-20 15:10:28.000000000 +0100
@@ -3069,6 +3069,22 @@ static void ehea_unregister_port(struct
 	of_device_unregister(&port->ofdev);
 }
 
+static const struct net_device_ops ehea_netdev_ops = {
+	.ndo_open		= ehea_open,
+	.ndo_stop		= ehea_stop,
+	.ndo_start_xmit		= ehea_start_xmit,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= ehea_netpoll,
+#endif
+	.ndo_get_stats		= ehea_get_stats,
+	.ndo_set_mac_address	= ehea_set_mac_addr,
+	.ndo_set_multicast_list	= ehea_set_multicast_list,
+	.ndo_change_mtu		= ehea_change_mtu,
+	.ndo_vlan_rx_register	= ehea_vlan_rx_register,
+	.ndo_vlan_rx_add_vid	= ehea_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid	= ehea_vlan_rx_kill_vid
+};
+
 struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
 					 u32 logical_port_id,
 					 struct device_node *dn)
@@ -3121,19 +3137,9 @@ struct ehea_port *ehea_setup_single_port
 	/* initialize net_device structure */
 	memcpy(dev->dev_addr, &port->mac_addr, ETH_ALEN);
 
-	dev->open = ehea_open;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = ehea_netpoll;
-#endif
-	dev->stop = ehea_stop;
-	dev->hard_start_xmit = ehea_start_xmit;
-	dev->get_stats = ehea_get_stats;
-	dev->set_multicast_list = ehea_set_multicast_list;
-	dev->set_mac_address = ehea_set_mac_addr;
-	dev->change_mtu = ehea_change_mtu;
-	dev->vlan_rx_register = ehea_vlan_rx_register;
-	dev->vlan_rx_add_vid = ehea_vlan_rx_add_vid;
-	dev->vlan_rx_kill_vid = ehea_vlan_rx_kill_vid;
+	dev->netdev_ops = &ehea_netdev_ops;
+	ehea_set_ethtool_ops(dev);
+
 	dev->features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_TSO
 		      | NETIF_F_HIGHDMA | NETIF_F_IP_CSUM | NETIF_F_HW_VLAN_TX
 		      | NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER
@@ -3142,7 +3148,6 @@ struct ehea_port *ehea_setup_single_port
 	dev->watchdog_timeo = EHEA_WATCH_DOG_TIMEOUT;
 
 	INIT_WORK(&port->reset_task, ehea_reset_port);
-	ehea_set_ethtool_ops(dev);
 
 	ret = register_netdev(dev);
 	if (ret) {
