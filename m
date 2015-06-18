From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH 04/22] fjes: platform_driver's .probe and .remove routine
Date: Thu, 18 Jun 2015 09:49:29 +0900
Message-ID: <1434588587-25655-4-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1434588359-25589-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <1434588587-25655-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: rkhan@redhat.com, alexander.h.duyck@redhat.com,
	netdev@vger.kernel.org, linux-acpi@vger.kernel.org,
	Taku Izumi <izumi.taku@jp.fujitsu.com>
To: platform-driver-x86@vger.kernel.org, dvhart@infradead.org
Return-path: <platform-driver-x86-owner@vger.kernel.org>
In-Reply-To: <1434588587-25655-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: platform-driver-x86-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch implements platform_driver's .probe and .remove
routine, and also adds board specific private data structure.

This driver registers net_device at platform_driver's .probe
routine and unregisters net_device at its .remove routine.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/platform/x86/fjes/fjes.h      | 27 ++++++++++
 drivers/platform/x86/fjes/fjes_main.c | 96 +++++++++++++++++++++++++++++++++++
 2 files changed, 123 insertions(+)

diff --git a/drivers/platform/x86/fjes/fjes.h b/drivers/platform/x86/fjes/fjes.h
index 5586305..3515572 100644
--- a/drivers/platform/x86/fjes/fjes.h
+++ b/drivers/platform/x86/fjes/fjes.h
@@ -25,7 +25,34 @@
 
 #include <linux/acpi.h>
 
+#include "fjes_hw.h"
+
 #define FJES_ACPI_SYMBOL	"Extended Socket"
+#define FJES_MAX_QUEUES		1
+#define FJES_TX_RETRY_INTERVAL	(20 * HZ)
+
+
+/* board specific private data structure */
+struct fjes_adapter {
+
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
diff --git a/drivers/platform/x86/fjes/fjes_main.c b/drivers/platform/x86/fjes/fjes_main.c
index 258929a1..f38e0af 100644
--- a/drivers/platform/x86/fjes/fjes_main.c
+++ b/drivers/platform/x86/fjes/fjes_main.c
@@ -23,6 +23,7 @@
 #include <linux/types.h>
 #include <linux/nls.h>
 #include <linux/platform_device.h>
+#include <linux/netdevice.h>
 
 #include "fjes.h"
 
@@ -51,6 +52,9 @@ static acpi_status fjes_get_acpi_resource(struct acpi_resource *, void*);
 static int fjes_probe(struct platform_device *);
 static int fjes_remove(struct platform_device *);
 
+static int fjes_sw_init(struct fjes_adapter *);
+static void fjes_netdev_setup(struct net_device *);
+
 
 static const struct acpi_device_id fjes_acpi_ids[] = {
 	{"PNP0C02", 0},
@@ -169,6 +173,9 @@ static acpi_status fjes_get_acpi_resource(struct acpi_resource *acpi_res,
 	return AE_OK;
 }
 
+static const struct net_device_ops fjes_netdev_ops = {
+};
+
 /*
  *  fjes_probe - Device Initialization Routine
  *
@@ -176,7 +183,67 @@ static acpi_status fjes_get_acpi_resource(struct acpi_resource *acpi_res,
  */
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
+			NET_NAME_UNKNOWN, fjes_netdev_setup, FJES_MAX_QUEUES);
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
+	hw->hw_res.size = res->end - res->start;
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
 
 /*
@@ -184,9 +251,38 @@ static int fjes_probe(struct platform_device *plat_dev)
  */
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
+/*
+ *  fjes_netdev_setup - netdevice initialization routine
+ */
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
 
 /*
  *  fjes_init_module - Driver Registration Routine
-- 
1.8.3.1
