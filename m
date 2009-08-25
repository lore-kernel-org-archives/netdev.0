From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 4/4] netxen: bridged mode optimizations
Date: Mon, 24 Aug 2009 22:23:28 -0700
Message-ID: <1251177808-16450-4-git-send-email-dhananjay@netxen.com>
References: <1251177808-16450-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org, Narender Kumar <narender.kumar@qlogic.com>
To: davem@davemloft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat-1.pathscale.com ([198.186.3.73]:54417 "HELO unm84.unmin.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S1754480AbZHYFX2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2009 01:23:28 -0400
In-Reply-To: <1251177808-16450-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Narender Kumar <narender.kumar@qlogic.com>

When the interface is put in bridged mode, destination mac
addresses are unknown to firmware. So packets take a slow
path (lower priority) in firmware reducing performance.

Firmware can cache limited number of remote unicast mac
addresses for certain interval, if "dynamic mac learning"
mode is enabled.

Driver needs to enable this "mac learning" mode in firmware.
Currently this is done through net device class sysfs entry,
possibly this can also be done upon netlink notifications to
from bridge.

Signed-off-by: Narender Kumar <narender.kumar@qlogic.com>
Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |    3 +
 drivers/net/netxen/netxen_nic_hw.c   |   31 ++++++++++++
 drivers/net/netxen/netxen_nic_main.c |   84 +++++++++++++++++++++++++++++++++-
 3 files changed, 116 insertions(+), 2 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 63e2f79..449d351 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -964,6 +964,7 @@ typedef struct {
 #define NX_NIC_H2C_OPCODE_PROXY_STOP_DONE		20
 #define NX_NIC_H2C_OPCODE_GET_LINKEVENT			21
 #define NX_NIC_C2C_OPCODE				22
+#define NX_NIC_H2C_OPCODE_CONFIG_BRIDGING               23
 #define NX_NIC_H2C_OPCODE_CONFIG_HW_LRO			24
 #define NX_NIC_H2C_OPCODE_LAST				25
 
@@ -1085,6 +1086,7 @@ typedef struct {
 #define NETXEN_NIC_MSI_ENABLED		0x02
 #define NETXEN_NIC_MSIX_ENABLED		0x04
 #define NETXEN_NIC_LRO_ENABLED		0x08
+#define NETXEN_NIC_BRIDGE_ENABLED       0X10
 #define NETXEN_IS_MSI_FAMILY(adapter) \
 	((adapter)->flags & (NETXEN_NIC_MSI_ENABLED | NETXEN_NIC_MSIX_ENABLED))
 
@@ -1332,6 +1334,7 @@ void netxen_advert_link_change(struct netxen_adapter *adapter, int linkup);
 int nx_fw_cmd_set_mtu(struct netxen_adapter *adapter, int mtu);
 int netxen_nic_change_mtu(struct net_device *netdev, int new_mtu);
 int netxen_config_hw_lro(struct netxen_adapter *adapter, int enable);
+int netxen_config_bridged_mode(struct netxen_adapter *adapter, int enable);
 int netxen_send_lro_cleanup(struct netxen_adapter *adapter);
 
 int netxen_nic_set_mac(struct net_device *netdev, void *p);
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 1a8ad62..db510ce 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -794,6 +794,37 @@ int netxen_config_hw_lro(struct netxen_adapter *adapter, int enable)
 	return rv;
 }
 
+int netxen_config_bridged_mode(struct netxen_adapter *adapter, int enable)
+{
+	nx_nic_req_t req;
+	u64 word;
+	int rv = 0;
+
+	if (!!(adapter->flags & NETXEN_NIC_BRIDGE_ENABLED) == enable)
+		return rv;
+
+	memset(&req, 0, sizeof(nx_nic_req_t));
+
+	req.qhdr = cpu_to_le64(NX_HOST_REQUEST << 23);
+
+	word = NX_NIC_H2C_OPCODE_CONFIG_BRIDGING |
+		((u64)adapter->portnum << 16);
+	req.req_hdr = cpu_to_le64(word);
+
+	req.words[0] = cpu_to_le64(enable);
+
+	rv = netxen_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
+	if (rv != 0) {
+		printk(KERN_ERR "ERROR. Could not send "
+				"configure bridge mode request\n");
+	}
+
+	adapter->flags ^= NETXEN_NIC_BRIDGE_ENABLED;
+
+	return rv;
+}
+
+
 #define RSS_HASHTYPE_IP_TCP	0x3
 
 int netxen_config_rss(struct netxen_adapter *adapter, int enable)
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index bd4589f..fab51d1 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -71,6 +71,10 @@ static int netxen_nic_poll(struct napi_struct *napi, int budget);
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void netxen_nic_poll_controller(struct net_device *netdev);
 #endif
+
+static void netxen_create_sysfs_entries(struct netxen_adapter *adapter);
+static void netxen_remove_sysfs_entries(struct netxen_adapter *adapter);
+
 static irqreturn_t netxen_intr(int irq, void *data);
 static irqreturn_t netxen_msi_intr(int irq, void *data);
 static irqreturn_t netxen_msix_intr(int irq, void *data);
@@ -94,8 +98,6 @@ static struct pci_device_id netxen_pci_tbl[] __devinitdata = {
 
 MODULE_DEVICE_TABLE(pci, netxen_pci_tbl);
 
-static void netxen_watchdog(unsigned long);
-
 static uint32_t crb_cmd_producer[4] = {
 	CRB_CMD_PRODUCER_OFFSET, CRB_CMD_PRODUCER_OFFSET_1,
 	CRB_CMD_PRODUCER_OFFSET_2, CRB_CMD_PRODUCER_OFFSET_3
@@ -995,6 +997,8 @@ netxen_nic_attach(struct netxen_adapter *adapter)
 	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
 		netxen_nic_init_coalesce_defaults(adapter);
 
+	netxen_create_sysfs_entries(adapter);
+
 	adapter->is_up = NETXEN_ADAPTER_UP_MAGIC;
 	return 0;
 
@@ -1012,6 +1016,8 @@ netxen_nic_detach(struct netxen_adapter *adapter)
 	if (adapter->is_up != NETXEN_ADAPTER_UP_MAGIC)
 		return;
 
+	netxen_remove_sysfs_entries(adapter);
+
 	netxen_free_hw_resources(adapter);
 	netxen_release_rx_buffers(adapter);
 	netxen_nic_free_irq(adapter);
@@ -1959,6 +1965,80 @@ static void netxen_nic_poll_controller(struct net_device *netdev)
 }
 #endif
 
+static ssize_t
+netxen_store_bridged_mode(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t len)
+{
+	struct net_device *net = to_net_dev(dev);
+	struct netxen_adapter *adapter = netdev_priv(net);
+	unsigned long new;
+	int ret = -EINVAL;
+
+	if (!(adapter->capabilities & NX_FW_CAPABILITY_BDG))
+		goto err_out;
+
+	if (adapter->is_up != NETXEN_ADAPTER_UP_MAGIC)
+		goto err_out;
+
+	if (strict_strtoul(buf, 2, &new))
+		goto err_out;
+
+	if (!netxen_config_bridged_mode(adapter, !!new))
+		ret = len;
+
+err_out:
+	return ret;
+}
+
+static ssize_t
+netxen_show_bridged_mode(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	struct net_device *net = to_net_dev(dev);
+	struct netxen_adapter *adapter;
+	int bridged_mode = 0;
+
+	adapter = netdev_priv(net);
+
+	if (adapter->capabilities & NX_FW_CAPABILITY_BDG)
+		bridged_mode = !!(adapter->flags & NETXEN_NIC_BRIDGE_ENABLED);
+
+	return sprintf(buf, "%d\n", bridged_mode);
+}
+
+static struct device_attribute dev_attr_bridged_mode = {
+       .attr = {.name = "bridged_mode", .mode = (S_IRUGO | S_IWUSR)},
+       .show = netxen_show_bridged_mode,
+       .store = netxen_store_bridged_mode,
+};
+
+static void
+netxen_create_sysfs_entries(struct netxen_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+	struct device *dev = &netdev->dev;
+
+	if (adapter->capabilities & NX_FW_CAPABILITY_BDG) {
+		/* bridged_mode control */
+		if (device_create_file(dev, &dev_attr_bridged_mode)) {
+			dev_warn(&netdev->dev,
+				"failed to create bridged_mode sysfs entry\n");
+		}
+	}
+}
+
+static void
+netxen_remove_sysfs_entries(struct netxen_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+	struct device *dev = &netdev->dev;
+
+	if (adapter->capabilities & NX_FW_CAPABILITY_BDG)
+		device_remove_file(dev, &dev_attr_bridged_mode);
+}
+
+static void netxen_watchdog(unsigned long);
+
 #ifdef CONFIG_INET
 
 #define is_netxen_netdev(dev) (dev->netdev_ops == &netxen_netdev_ops)
-- 
1.6.0.2

