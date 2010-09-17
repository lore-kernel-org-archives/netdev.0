From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCHv2 NEXT 3/5] qlcnic: vlan lro support
Date: Thu, 16 Sep 2010 22:14:41 -0700
Message-ID: <1284700483-16397-4-git-send-email-amit.salecha@qlogic.com>
References: <1284700483-16397-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:6346 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751338Ab0IQFOo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Sep 2010 01:14:44 -0400
In-Reply-To: <1284700483-16397-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

LRO + GRO + vlan rx accleration support, performance increases
around 20% and cpu utilization reduces around 70% on vlan interface.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_main.c |   39 +++++++++++++++++++++++++++++--------
 1 files changed, 30 insertions(+), 9 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index f7eb30b..ea729a5 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -107,7 +107,7 @@ static irqreturn_t qlcnic_msi_intr(int irq, void *data);
 static irqreturn_t qlcnic_msix_intr(int irq, void *data);
 
 static struct net_device_stats *qlcnic_get_stats(struct net_device *netdev);
-static void qlcnic_config_indev_addr(struct net_device *dev, unsigned long);
+static void qlcnic_restore_indev_addr(struct net_device *dev, unsigned long);
 static int qlcnic_start_firmware(struct qlcnic_adapter *);
 
 static void qlcnic_alloc_lb_filters_mem(struct qlcnic_adapter *adapter);
@@ -1759,7 +1759,7 @@ qlcnic_resume(struct pci_dev *pdev)
 		if (err)
 			goto done;
 
-		qlcnic_config_indev_addr(netdev, NETDEV_UP);
+		qlcnic_restore_indev_addr(netdev, NETDEV_UP);
 	}
 done:
 	netif_device_attach(netdev);
@@ -2958,7 +2958,7 @@ attach:
 		if (qlcnic_up(adapter, netdev))
 			goto done;
 
-		qlcnic_config_indev_addr(netdev, NETDEV_UP);
+		qlcnic_restore_indev_addr(netdev, NETDEV_UP);
 	}
 
 done:
@@ -3120,7 +3120,7 @@ static int qlcnic_attach_func(struct pci_dev *pdev)
 		if (err)
 			goto done;
 
-		qlcnic_config_indev_addr(netdev, NETDEV_UP);
+		qlcnic_restore_indev_addr(netdev, NETDEV_UP);
 	}
  done:
 	netif_device_attach(netdev);
@@ -4035,10 +4035,10 @@ qlcnic_remove_diag_entries(struct qlcnic_adapter *adapter)
 #define is_qlcnic_netdev(dev) (dev->netdev_ops == &qlcnic_netdev_ops)
 
 static void
-qlcnic_config_indev_addr(struct net_device *dev, unsigned long event)
+qlcnic_config_indev_addr(struct qlcnic_adapter *adapter,
+			struct net_device *dev, unsigned long event)
 {
 	struct in_device *indev;
-	struct qlcnic_adapter *adapter = netdev_priv(dev);
 
 	indev = in_dev_get(dev);
 	if (!indev)
@@ -4062,6 +4062,27 @@ qlcnic_config_indev_addr(struct net_device *dev, unsigned long event)
 	in_dev_put(indev);
 }
 
+static void
+qlcnic_restore_indev_addr(struct net_device *netdev, unsigned long event)
+{
+	struct qlcnic_adapter *adapter = netdev_priv(netdev);
+	struct net_device *dev;
+	u16 vid;
+
+	qlcnic_config_indev_addr(adapter, netdev, event);
+
+	if (!adapter->vlgrp)
+		return;
+
+	for (vid = 0; vid < VLAN_GROUP_ARRAY_LEN; vid++) {
+		dev = vlan_group_get_device(adapter->vlgrp, vid);
+		if (!dev)
+			continue;
+
+		qlcnic_config_indev_addr(adapter, dev, event);
+	}
+}
+
 static int qlcnic_netdev_event(struct notifier_block *this,
 				 unsigned long event, void *ptr)
 {
@@ -4088,7 +4109,7 @@ recheck:
 	if (!test_bit(__QLCNIC_DEV_UP, &adapter->state))
 		goto done;
 
-	qlcnic_config_indev_addr(dev, event);
+	qlcnic_config_indev_addr(adapter, dev, event);
 done:
 	return NOTIFY_DONE;
 }
@@ -4105,7 +4126,7 @@ qlcnic_inetaddr_event(struct notifier_block *this,
 	dev = ifa->ifa_dev ? ifa->ifa_dev->dev : NULL;
 
 recheck:
-	if (dev == NULL || !netif_running(dev))
+	if (dev == NULL)
 		goto done;
 
 	if (dev->priv_flags & IFF_802_1Q_VLAN) {
@@ -4148,7 +4169,7 @@ static struct notifier_block qlcnic_inetaddr_cb = {
 };
 #else
 static void
-qlcnic_config_indev_addr(struct net_device *dev, unsigned long event)
+qlcnic_restore_indev_addr(struct net_device *dev, unsigned long event)
 { }
 #endif
 static struct pci_error_handlers qlcnic_err_handler = {
-- 
1.6.0.2

