From: Kai Engert <kengert@redhat.com>
Subject: [PATCH 2.6.19.1] prism54: add ethtool -i interface
Date: Tue, 12 Dec 2006 21:09:41 +0100
Message-ID: <457F0C85.7030303@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:33155 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932425AbWLLUJo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Dec 2006 15:09:44 -0500
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id kBCK9hDd026512
	for <netdev@vger.kernel.org>; Tue, 12 Dec 2006 15:09:43 -0500
Received: from pobox.stuttgart.redhat.com (pobox.stuttgart.redhat.com [172.16.2.10])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id kBCK9gmN018158
	for <netdev@vger.kernel.org>; Tue, 12 Dec 2006 15:09:43 -0500
Received: from [10.32.4.13] (vpn-4-13.str.redhat.com [10.32.4.13])
	by pobox.stuttgart.redhat.com (8.12.8/8.12.8) with ESMTP id kBCK9fxY002206
	for <netdev@vger.kernel.org>; Tue, 12 Dec 2006 21:09:42 +0100
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for "ethtool -i" to prism54 driver.

ethtool -i queries the specified device for 
associated driver information.

This helps tools like Fedora's system-config-network to 
provide GUI management of network devices.
I learned how to write this patch by reading the ipw2100 
driver code.

Signed-off-by: Kai Engert <kengert@redhat.com>

--- linux-2.6.19.1/drivers/net/wireless/prism54/islpci_dev.h.preke	2006-12-11 20:32:53.000000000 +0100
+++ linux-2.6.19.1/drivers/net/wireless/prism54/islpci_dev.h	2006-12-12 20:33:09.000000000 +0100
@@ -212,4 +212,8 @@

int islpci_free_memory(islpci_private *);
struct net_device *islpci_setup(struct pci_dev *);
+
+#define DRV_NAME	"prism54"
+#define DRV_VERSION	"1.2"
+
#endif				/* _ISLPCI_DEV_H */
--- linux-2.6.19.1/drivers/net/wireless/prism54/islpci_dev.c.preke	2006-12-11 20:32:53.000000000 +0100
+++ linux-2.6.19.1/drivers/net/wireless/prism54/islpci_dev.c	2006-12-12 20:33:09.000000000 +0100
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
--- linux-2.6.19.1/drivers/net/wireless/prism54/islpci_hotplug.c.preke	2006-12-11 20:32:53.000000000 +0100
+++ linux-2.6.19.1/drivers/net/wireless/prism54/islpci_hotplug.c	2006-12-12 20:33:09.000000000 +0100
@@ -29,9 +29,6 @@
#include "islpci_mgt.h"		/* for pc_debug */
#include "isl_oid.h"

-#define DRV_NAME	"prism54"
-#define DRV_VERSION	"1.2"
-
MODULE_AUTHOR("[Intersil] R.Bastings and W.Termorshuizen, The prism54.org Development Team <prism54-devel@prism54.org>");
MODULE_DESCRIPTION("The Prism54 802.11 Wireless LAN adapter");
MODULE_LICENSE("GPL");



