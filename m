From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.5.70] e100 initialize fields prior to register_netdevice
Date: Thu, 29 May 2003 10:36:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030529103650.64d61340.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>,
   Scott Feldman
 <scott.feldman@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The e100 driver sets many of the fields in the netdevice structure after
calling the register function.  This confuses the sysfs setup, because
it uses the presence of the get_stats function pointer to decide whether
to setup a statistics directory or not.  The earlier patch to net-sysfs
keeps this from causing a crash.

This patch moves the initialization earlier before registration.  It probably
closes other races as well, where some program could access the e100 driver
before the pointers were setup.

--- linux-2.5/drivers/net/e100/e100_main.c	2003-05-27 11:04:34.000000000 -0700
+++ linux-2.5-sysfs/drivers/net/e100/e100_main.c	2003-05-29 08:56:47.000000000 -0700
@@ -614,6 +614,22 @@
 		goto err_dealloc;
 	}
 
+	dev->vlan_rx_register = e100_vlan_rx_register;
+	dev->vlan_rx_add_vid = e100_vlan_rx_add_vid;
+	dev->vlan_rx_kill_vid = e100_vlan_rx_kill_vid;
+	dev->irq = pcid->irq;
+	dev->open = &e100_open;
+	dev->hard_start_xmit = &e100_xmit_frame;
+	dev->stop = &e100_close;
+	dev->change_mtu = &e100_change_mtu;
+	dev->get_stats = &e100_get_stats;
+	dev->set_multicast_list = &e100_set_multi;
+	dev->set_mac_address = &e100_set_mac;
+	dev->do_ioctl = &e100_ioctl;
+	if (bdp->flags & USE_IPCB)
+		dev->features = NETIF_F_SG | NETIF_F_HW_CSUM |
+				NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
+
 	if ((rc = register_netdev(dev)) != 0) {
 		goto err_pci;
 	}
@@ -660,23 +676,6 @@
                 goto err_unregister_netdev;
 	}
 	
-	dev->vlan_rx_register = e100_vlan_rx_register;
-	dev->vlan_rx_add_vid = e100_vlan_rx_add_vid;
-	dev->vlan_rx_kill_vid = e100_vlan_rx_kill_vid;
-	dev->irq = pcid->irq;
-	dev->open = &e100_open;
-	dev->hard_start_xmit = &e100_xmit_frame;
-	dev->stop = &e100_close;
-	dev->change_mtu = &e100_change_mtu;
-	dev->get_stats = &e100_get_stats;
-	dev->set_multicast_list = &e100_set_multi;
-	dev->set_mac_address = &e100_set_mac;
-	dev->do_ioctl = &e100_ioctl;
-
-	if (bdp->flags & USE_IPCB)
-	dev->features = NETIF_F_SG | NETIF_F_HW_CSUM |
-			NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-		
 	e100nics++;
 
 	e100_get_speed_duplex_caps(bdp);
