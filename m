From: Kai Engert <kengert@redhat.com>
Subject: [patch] Add ethtool -i interface to Prism54
Date: Thu, 19 Oct 2006 03:33:34 +0200
Message-ID: <4536D5EE.4060405@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080503040608000603070702"
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:21655 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1945955AbWJSBdd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 21:33:33 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id k9J1XWQl026127
	for <netdev@vger.kernel.org>; Wed, 18 Oct 2006 21:33:32 -0400
Received: from pobox.stuttgart.redhat.com (pobox.stuttgart.redhat.com [172.16.2.10])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id k9J1XVus012412
	for <netdev@vger.kernel.org>; Wed, 18 Oct 2006 21:33:31 -0400
Received: from [10.32.4.10] (vpn-4-10.str.redhat.com [10.32.4.10])
	by pobox.stuttgart.redhat.com (8.12.8/8.12.8) with ESMTP id k9J1XUtc015409
	for <netdev@vger.kernel.org>; Thu, 19 Oct 2006 03:33:31 +0200
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080503040608000603070702
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Attached is a small patch that will add support for
  ethtool -i
to the prism54 driver.

ethtool -i queries the specified ethernet device for associated driver 
information.

This helps tools like Fedora's system-config-network to provide GUI 
management of network devices.
I learned how to write this patch by reading the ipw2100 driver code.

Thanks for considering to take it.
Kai


--------------080503040608000603070702
Content-Type: text/plain;
 name="prism54ethtool"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="prism54ethtool"

--- linux-2.6.16/drivers/net/wireless/prism54/islpci_dev.h.preke	2006-03-20 06:53:29.000000000 +0100
+++ linux-2.6.16/drivers/net/wireless/prism54/islpci_dev.h	2006-04-12 15:12:30.000000000 +0200
@@ -210,4 +210,8 @@
 
 int islpci_free_memory(islpci_private *);
 struct net_device *islpci_setup(struct pci_dev *);
+
+#define DRV_NAME	"prism54"
+#define DRV_VERSION	"1.2"
+
 #endif				/* _ISLPCI_DEV_H */
--- linux-2.6.16/drivers/net/wireless/prism54/islpci_dev.c.preke	2006-04-12 14:56:12.000000000 +0200
+++ linux-2.6.16/drivers/net/wireless/prism54/islpci_dev.c	2006-04-13 01:39:27.000000000 +0200
@@ -22,6 +22,7 @@
 #include <linux/module.h>
 
 #include <linux/netdevice.h>
+#include <linux/ethtool.h>
 #include <linux/pci.h>
 #include <linux/etherdevice.h>
 #include <linux/delay.h>
@@ -788,6 +789,17 @@
 }
 #endif
 
+static void islpci_ethtool_get_drvinfo(struct net_device *dev,
+                                       struct ethtool_drvinfo *info)
+{
+	strcpy(info->driver, DRV_NAME);
+	strcpy(info->version, DRV_VERSION);
+}
+
+static struct ethtool_ops islpci_ethtool_ops = {
+	.get_drvinfo = islpci_ethtool_get_drvinfo,
+};
+
 struct net_device *
 islpci_setup(struct pci_dev *pdev)
 {
@@ -814,6 +826,7 @@
 	ndev->do_ioctl = &prism54_ioctl;
 	ndev->wireless_handlers =
 	    (struct iw_handler_def *) &prism54_handler_def;
+	ndev->ethtool_ops = &islpci_ethtool_ops;
 
 	ndev->hard_start_xmit = &islpci_eth_transmit;
 	/* ndev->set_multicast_list = &islpci_set_multicast_list; */
--- linux-2.6.16/drivers/net/wireless/prism54/islpci_hotplug.c.preke	2006-04-12 14:56:22.000000000 +0200
+++ linux-2.6.16/drivers/net/wireless/prism54/islpci_hotplug.c	2006-04-12 15:14:16.000000000 +0200
@@ -28,9 +28,6 @@
 #include "islpci_mgt.h"		/* for pc_debug */
 #include "isl_oid.h"
 
-#define DRV_NAME	"prism54"
-#define DRV_VERSION	"1.2"
-
 MODULE_AUTHOR("[Intersil] R.Bastings and W.Termorshuizen, The prism54.org Development Team <prism54-devel@prism54.org>");
 MODULE_DESCRIPTION("The Prism54 802.11 Wireless LAN adapter");
 MODULE_LICENSE("GPL");

--------------080503040608000603070702--
