From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH v2.2 04/22] fjes: platform_driver's .probe and .remove routine
Date: Thu, 20 Aug 2015 17:46:08 +0900
Message-ID: <1440060386-13189-4-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1440060306-13040-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <1440060386-13189-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: platform-driver-x86@vger.kernel.org, dvhart@infradead.org,
	rkhan@redhat.com, alexander.h.duyck@redhat.com,
	linux-acpi@vger.kernel.org, joe@perches.com,
	sergei.shtylyov@cogentembedded.com, stephen@networkplumber.org,
	yasu.isimatu@gmail.com, Taku Izumi <izumi.taku@jp.fujitsu.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwym01.jp.fujitsu.com ([211.128.242.40]:32623 "EHLO
	mgwym01.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752426AbbHTIv3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 04:51:29 -0400
In-Reply-To: <1440060386-13189-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements platform_driver's .probe and .remove
routine, and also adds board specific private data structure.

This driver registers net_device at platform_driver's .probe
routine and unregisters net_device at its .remove routine.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/fjes/fjes.h      | 25 ++++++++++++
 drivers/net/fjes/fjes_main.c | 95 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 120 insertions(+)

diff --git a/drivers/net/fjes/fjes.h b/drivers/net/fjes/fjes.h
index 15ded96..54bc189 100644
--- a/drivers/net/fjes/fjes.h
+++ b/drivers/net/fjes/fjes.h
@@ -24,7 +24,32 @@
 
 #include <linux/acpi.h>
 
+#include "fjes_hw.h"
+
 #define FJES_ACPI_SYMBOL	"Extended Socket"
+#define FJES_MAX_QUEUES		1
+#define FJES_TX_RETRY_INTERVAL	(20 * HZ)
+
+/* board specific private data structure */
+struct fjes_adapter {
+	struct net_device *netdev;
+	struct platform_device *plat_dev;
+
+	struct napi_struct napi;
+	struct rtnl_link_stats64 stats64;
+
+	unsigned int tx_retry_count;
+	unsigned long tx_start_jiffies;
+	unsigned long rx_last_jiffies;
+	bool unset_rx_last;
+
+	bool force_reset;
+	bool open_guard;
+
+	bool irq_registered;
+
+	struct fjes_hw hw;
+};
 
 extern char fjes_driver_name[];
 extern char fjes_driver_version[];
diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
index ab4d20c..7695b84 100644
--- a/drivers/net/fjes/fjes_main.c
+++ b/drivers/net/fjes/fjes_main.c
@@ -23,6 +23,7 @@
 #include <linux/types.h>
 #include <linux/nls.h>
 #include <linux/platform_device.h>
+#include <linux/netdevice.h>
 
 #include "fjes.h"
 
@@ -49,6 +50,9 @@ static acpi_status fjes_get_acpi_resource(struct acpi_resource *, void*);
 static int fjes_probe(struct platform_device *);
 static int fjes_remove(struct platform_device *);
 
+static int fjes_sw_init(struct fjes_adapter *);
+static void fjes_netdev_setup(struct net_device *);
+
 static const struct acpi_device_id fjes_acpi_ids[] = {
 	{"PNP0C02", 0},
 	{"", 0},
@@ -166,18 +170,109 @@ fjes_get_acpi_resource(struct acpi_resource *acpi_res, void *data)
 	return AE_OK;
 }
 
+static const struct net_device_ops fjes_netdev_ops = {
+};
+
 /* fjes_probe - Device Initialization Routine */
 static int fjes_probe(struct platform_device *plat_dev)
 {
+	struct net_device *netdev;
+	struct fjes_adapter *adapter;
+	struct fjes_hw *hw;
+	struct resource *res;
+	int err;
+
+	err = -ENOMEM;
+	netdev = alloc_netdev_mq(sizeof(struct fjes_adapter), "es%d",
+				 NET_NAME_UNKNOWN, fjes_netdev_setup,
+				 FJES_MAX_QUEUES);
+
+	if (!netdev)
+		goto err_alloc_netdev;
+
+	SET_NETDEV_DEV(netdev, &plat_dev->dev);
+
+	dev_set_drvdata(&plat_dev->dev, netdev);
+	adapter = netdev_priv(netdev);
+	adapter->netdev = netdev;
+	adapter->plat_dev = plat_dev;
+	hw = &adapter->hw;
+	hw->back = adapter;
+
+	/* setup the private structure */
+	err = fjes_sw_init(adapter);
+	if (err)
+		goto err_sw_init;
+
+	adapter->force_reset = false;
+	adapter->open_guard = false;
+
+	res = platform_get_resource(plat_dev, IORESOURCE_MEM, 0);
+	hw->hw_res.start = res->start;
+	hw->hw_res.size = res->end - res->start + 1;
+	hw->hw_res.irq = platform_get_irq(plat_dev, 0);
+	err = fjes_hw_init(&adapter->hw);
+	if (err)
+		goto err_hw_init;
+
+	/* setup MAC address (02:00:00:00:00:[epid])*/
+	netdev->dev_addr[0] = 2;
+	netdev->dev_addr[1] = 0;
+	netdev->dev_addr[2] = 0;
+	netdev->dev_addr[3] = 0;
+	netdev->dev_addr[4] = 0;
+	netdev->dev_addr[5] = hw->my_epid; /* EPID */
+
+	err = register_netdev(netdev);
+	if (err)
+		goto err_register;
+
+	netif_carrier_off(netdev);
+
 	return 0;
+
+err_register:
+	fjes_hw_exit(&adapter->hw);
+err_hw_init:
+err_sw_init:
+	free_netdev(netdev);
+err_alloc_netdev:
+	return err;
 }
 
 /* fjes_remove - Device Removal Routine */
 static int fjes_remove(struct platform_device *plat_dev)
 {
+	struct net_device *netdev = dev_get_drvdata(&plat_dev->dev);
+	struct fjes_adapter *adapter = netdev_priv(netdev);
+	struct fjes_hw *hw = &adapter->hw;
+
+	unregister_netdev(netdev);
+
+	fjes_hw_exit(hw);
+
+	free_netdev(netdev);
+
 	return 0;
 }
 
+static int fjes_sw_init(struct fjes_adapter *adapter)
+{
+	return 0;
+}
+
+/* fjes_netdev_setup - netdevice initialization routine */
+static void fjes_netdev_setup(struct net_device *netdev)
+{
+	ether_setup(netdev);
+
+	netdev->watchdog_timeo = FJES_TX_RETRY_INTERVAL;
+	netdev->netdev_ops = &fjes_netdev_ops;
+	netdev->mtu = fjes_support_mtu[0];
+	netdev->flags |= IFF_BROADCAST;
+	netdev->features |= NETIF_F_HW_CSUM | NETIF_F_HW_VLAN_CTAG_FILTER;
+}
+
 /* fjes_init_module - Driver Registration Routine */
 static int __init fjes_init_module(void)
 {
-- 
1.8.3.1
