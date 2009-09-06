From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 3/6] netxen: fix ip addr hashing after firmware reset
Date: Sat,  5 Sep 2009 20:43:09 -0700
Message-ID: <1252208592-2240-4-git-send-email-dhananjay@netxen.com>
References: <1252208592-2240-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org, Amit Kumar Salecha <amit@netxen.com>
To: davem@davemloft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat-1.pathscale.com ([198.186.3.73]:25070 "HELO unm84.unmin.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S1754038AbZIFDnM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Sep 2009 23:43:12 -0400
In-Reply-To: <1252208592-2240-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit@netxen.com>

Reprogram local IP addresses after firmware is reset
or after resuming from suspend.

Signed-off-by: Amit Kumar Salecha <amit@netxen.com>
Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_main.c |   61 +++++++++++++++++++++------------
 1 files changed, 39 insertions(+), 22 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 4989436..7038e1b 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -86,6 +86,8 @@ static irqreturn_t netxen_intr(int irq, void *data);
 static irqreturn_t netxen_msi_intr(int irq, void *data);
 static irqreturn_t netxen_msix_intr(int irq, void *data);
 
+static void netxen_config_indev_addr(struct net_device *dev, unsigned long);
+
 /*  PCI Device ID Table  */
 #define ENTRY(device) \
 	{PCI_DEVICE(PCI_VENDOR_ID_NETXEN, (device)), \
@@ -1411,6 +1413,8 @@ netxen_nic_resume(struct pci_dev *pdev)
 			goto err_out_detach;
 
 		netif_device_attach(netdev);
+
+		netxen_config_indev_addr(netdev, NETDEV_UP);
 	}
 
 	netxen_schedule_work(adapter, netxen_fw_poll_work, FW_POLL_DELAY);
@@ -2057,6 +2061,7 @@ netxen_attach_work(struct work_struct *work)
 			goto done;
 		}
 
+		netxen_config_indev_addr(netdev, NETDEV_UP);
 	}
 
 	netif_device_attach(netdev);
@@ -2282,12 +2287,43 @@ netxen_destip_supported(struct netxen_adapter *adapter)
 	return 1;
 }
 
+static void
+netxen_config_indev_addr(struct net_device *dev, unsigned long event)
+{
+	struct in_device *indev;
+	struct netxen_adapter *adapter = netdev_priv(dev);
+
+	if (netxen_destip_supported(adapter))
+		return;
+
+	indev = in_dev_get(dev);
+	if (!indev)
+		return;
+
+	for_ifa(indev) {
+		switch (event) {
+		case NETDEV_UP:
+			netxen_config_ipaddr(adapter,
+					ifa->ifa_address, NX_IP_UP);
+			break;
+		case NETDEV_DOWN:
+			netxen_config_ipaddr(adapter,
+					ifa->ifa_address, NX_IP_DOWN);
+			break;
+		default:
+			break;
+		}
+	} endfor_ifa(indev);
+
+	in_dev_put(indev);
+	return;
+}
+
 static int netxen_netdev_event(struct notifier_block *this,
 				 unsigned long event, void *ptr)
 {
 	struct netxen_adapter *adapter;
 	struct net_device *dev = (struct net_device *)ptr;
-	struct in_device *indev;
 
 recheck:
 	if (dev == NULL)
@@ -2303,32 +2339,13 @@ recheck:
 
 	adapter = netdev_priv(dev);
 
-	if (!adapter || !netxen_destip_supported(adapter))
+	if (!adapter)
 		goto done;
 
 	if (adapter->is_up != NETXEN_ADAPTER_UP_MAGIC)
 		goto done;
 
-	indev = in_dev_get(dev);
-	if (!indev)
-		goto done;
-
-	for_ifa(indev) {
-		switch (event) {
-		case NETDEV_UP:
-			netxen_config_ipaddr(adapter,
-					ifa->ifa_address, NX_IP_UP);
-			break;
-		case NETDEV_DOWN:
-			netxen_config_ipaddr(adapter,
-					ifa->ifa_address, NX_IP_DOWN);
-			break;
-		default:
-			break;
-		}
-	} endfor_ifa(indev);
-
-	in_dev_put(indev);
+	netxen_config_indev_addr(dev, event);
 done:
 	return NOTIFY_DONE;
 }
-- 
1.6.0.2

