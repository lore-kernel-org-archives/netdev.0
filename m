From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCHv3 NEXT 4/7] qlcnic: add eswitch statistics support
Date: Tue, 17 Aug 2010 03:34:22 -0700
Message-ID: <1282041265-32591-5-git-send-email-amit.salecha@qlogic.com>
References: <1282041265-32591-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:10223 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1757304Ab0HQKe0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Aug 2010 06:34:26 -0400
In-Reply-To: <1282041265-32591-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding eswitch statistics support. User can get
whole eswitch stats or stats of func belong to that eswitch.

Added:
o command to get statistics of eswitch and function.
o sysfs support to export eswitch and func statatistics.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |   31 +++++++++
 drivers/net/qlcnic/qlcnic_ctx.c  |  125 ++++++++++++++++++++++++++++++++++++
 drivers/net/qlcnic/qlcnic_main.c |  132 +++++++++++++++++++++++++++++++++++++-
 3 files changed, 287 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 9703893..7f4e11b 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -555,6 +555,7 @@ struct qlcnic_recv_context {
 #define QLCNIC_CDRP_CMD_GET_ESWITCH_STATUS	0x00000026
 #define QLCNIC_CDRP_CMD_SET_PORTMIRRORING	0x00000027
 #define QLCNIC_CDRP_CMD_CONFIGURE_ESWITCH	0x00000028
+#define QLCNIC_CDRP_CMD_GET_ESWITCH_STATS	0x0000002a
 
 #define QLCNIC_RCODE_SUCCESS		0
 #define QLCNIC_RCODE_TIMEOUT		17
@@ -1126,6 +1127,31 @@ struct qlcnic_esw_func_cfg {
 	u8	reserved;
 };
 
+#define QLCNIC_STATS_VERSION		1
+#define QLCNIC_STATS_PORT		1
+#define QLCNIC_STATS_ESWITCH		2
+#define QLCNIC_QUERY_RX_COUNTER		0
+#define QLCNIC_QUERY_TX_COUNTER		1
+struct __qlcnic_esw_statistics {
+	__le16 context_id;
+	__le16 version;
+	__le16 size;
+	__le16 unused;
+	__le64 unicast_frames;
+	__le64 multicast_frames;
+	__le64 broadcast_frames;
+	__le64 dropped_frames;
+	__le64 errors;
+	__le64 local_frames;
+	__le64 numbytes;
+	__le64 rsvd[3];
+};
+
+struct qlcnic_esw_statistics {
+	struct __qlcnic_esw_statistics rx;
+	struct __qlcnic_esw_statistics tx;
+};
+
 int qlcnic_fw_cmd_query_phy(struct qlcnic_adapter *adapter, u32 reg, u32 *val);
 int qlcnic_fw_cmd_set_phy(struct qlcnic_adapter *adapter, u32 reg, u32 val);
 
@@ -1252,6 +1278,11 @@ int qlcnic_toggle_eswitch(struct qlcnic_adapter *, u8, u8);
 int qlcnic_config_switch_port(struct qlcnic_adapter *, u8, int, u8, u8,
 			u8, u8, u16);
 int qlcnic_config_port_mirroring(struct qlcnic_adapter *, u8, u8, u8);
+int qlcnic_get_port_stats(struct qlcnic_adapter *, const u8, const u8,
+					struct __qlcnic_esw_statistics *);
+int qlcnic_get_eswitch_stats(struct qlcnic_adapter *, const u8, u8,
+					struct __qlcnic_esw_statistics *);
+int qlcnic_clear_esw_stats(struct qlcnic_adapter *adapter, u8, u8, u8);
 extern int qlcnic_config_tso;
 
 /*
diff --git a/drivers/net/qlcnic/qlcnic_ctx.c b/drivers/net/qlcnic/qlcnic_ctx.c
index cc5d861..57c9b09 100644
--- a/drivers/net/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/qlcnic/qlcnic_ctx.c
@@ -983,3 +983,128 @@ int qlcnic_config_switch_port(struct qlcnic_adapter *adapter, u8 id,
 
 	return err;
 }
+
+int qlcnic_get_port_stats(struct qlcnic_adapter *adapter, const u8 func,
+		const u8 rx_tx, struct __qlcnic_esw_statistics *esw_stats) {
+
+	size_t stats_size = sizeof(struct __qlcnic_esw_statistics);
+	dma_addr_t stats_dma_t;
+	void *stats_addr;
+	u32 arg1;
+	int err;
+
+	if (esw_stats == NULL)
+		return -ENOMEM;
+
+	if (adapter->op_mode != QLCNIC_MGMT_FUNC &&
+	    func != adapter->ahw.pci_func) {
+		dev_err(&adapter->pdev->dev,
+			"Not privilege to query stats for func=%d", func);
+		return -EIO;
+	}
+
+	stats_addr = pci_alloc_consistent(adapter->pdev, stats_size,
+			&stats_dma_t);
+	if (!stats_addr) {
+		dev_err(&adapter->pdev->dev, "Unable to allocate memory\n");
+		return -ENOMEM;
+	}
+	memset(stats_addr, 0, stats_size);
+
+	arg1 = func | QLCNIC_STATS_VERSION << 8 | QLCNIC_STATS_PORT << 12;
+	arg1 |= rx_tx << 15 | stats_size << 16;
+
+	err = qlcnic_issue_cmd(adapter,
+			adapter->ahw.pci_func,
+			adapter->fw_hal_version,
+			arg1,
+			MSD(stats_dma_t),
+			LSD(stats_dma_t),
+			QLCNIC_CDRP_CMD_GET_ESWITCH_STATS);
+
+	if (!err)
+		memcpy(esw_stats, stats_addr, stats_size);
+
+	pci_free_consistent(adapter->pdev, stats_size, stats_addr,
+		stats_dma_t);
+	return err;
+}
+
+int qlcnic_get_eswitch_stats(struct qlcnic_adapter *adapter, const u8 eswitch,
+		const u8 rx_tx, struct __qlcnic_esw_statistics *esw_stats) {
+
+	struct __qlcnic_esw_statistics port_stats;
+	u8 i;
+	int ret = -EIO;
+
+	if (esw_stats == NULL)
+		return -ENOMEM;
+	if (adapter->op_mode != QLCNIC_MGMT_FUNC)
+		return -EIO;
+	if (adapter->npars == NULL)
+		return -EIO;
+
+	memset(esw_stats, 0, sizeof(struct __qlcnic_esw_statistics));
+	esw_stats->context_id = eswitch;
+
+	for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++) {
+		if (adapter->npars[i].phy_port != eswitch)
+			continue;
+
+		memset(&port_stats, 0, sizeof(struct __qlcnic_esw_statistics));
+		if (qlcnic_get_port_stats(adapter, i, rx_tx, &port_stats))
+			continue;
+
+		esw_stats->size = port_stats.size;
+		esw_stats->version = port_stats.version;
+		esw_stats->unicast_frames += port_stats.unicast_frames;
+		esw_stats->multicast_frames += port_stats.multicast_frames;
+		esw_stats->broadcast_frames += port_stats.broadcast_frames;
+		esw_stats->dropped_frames += port_stats.dropped_frames;
+		esw_stats->errors += port_stats.errors;
+		esw_stats->local_frames += port_stats.local_frames;
+		esw_stats->numbytes += port_stats.numbytes;
+
+		ret = 0;
+	}
+	return ret;
+}
+
+int qlcnic_clear_esw_stats(struct qlcnic_adapter *adapter, const u8 func_esw,
+		const u8 port, const u8 rx_tx)
+{
+
+	u32 arg1;
+
+	if (adapter->op_mode != QLCNIC_MGMT_FUNC)
+		return -EIO;
+
+	if (func_esw == QLCNIC_STATS_PORT) {
+		if (port >= QLCNIC_MAX_PCI_FUNC)
+			goto err_ret;
+	} else if (func_esw == QLCNIC_STATS_ESWITCH) {
+		if (port >= QLCNIC_NIU_MAX_XG_PORTS)
+			goto err_ret;
+	} else {
+		goto err_ret;
+	}
+
+	if (rx_tx > QLCNIC_QUERY_TX_COUNTER)
+		goto err_ret;
+
+	arg1 = port | QLCNIC_STATS_VERSION << 8 | func_esw << 12;
+	arg1 |= BIT_14 | rx_tx << 15;
+
+	return qlcnic_issue_cmd(adapter,
+			adapter->ahw.pci_func,
+			adapter->fw_hal_version,
+			arg1,
+			0,
+			0,
+			QLCNIC_CDRP_CMD_GET_ESWITCH_STATS);
+
+err_ret:
+	dev_err(&adapter->pdev->dev, "Invalid argument func_esw=%d port=%d"
+		"rx_ctx=%d\n", func_esw, port, rx_tx);
+	return -EIO;
+}
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 06ffd76..a30bde5 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -3378,6 +3378,115 @@ qlcnic_sysfs_read_npar_config(struct file *file, struct kobject *kobj,
 }
 
 static ssize_t
+qlcnic_sysfs_get_port_stats(struct file *file, struct kobject *kobj,
+	struct bin_attribute *attr, char *buf, loff_t offset, size_t size)
+{
+	struct device *dev = container_of(kobj, struct device, kobj);
+	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
+	struct qlcnic_esw_statistics port_stats;
+	int ret;
+
+	if (size != sizeof(struct qlcnic_esw_statistics))
+		return QL_STATUS_INVALID_PARAM;
+
+	if (offset >= QLCNIC_MAX_PCI_FUNC)
+		return QL_STATUS_INVALID_PARAM;
+
+	memset(&port_stats, 0, size);
+	ret = qlcnic_get_port_stats(adapter, offset, QLCNIC_QUERY_RX_COUNTER,
+								&port_stats.rx);
+	if (ret)
+		return ret;
+
+	ret = qlcnic_get_port_stats(adapter, offset, QLCNIC_QUERY_TX_COUNTER,
+								&port_stats.tx);
+	if (ret)
+		return ret;
+
+	memcpy(buf, &port_stats, size);
+	return size;
+}
+
+static ssize_t
+qlcnic_sysfs_get_esw_stats(struct file *file, struct kobject *kobj,
+	struct bin_attribute *attr, char *buf, loff_t offset, size_t size)
+{
+	struct device *dev = container_of(kobj, struct device, kobj);
+	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
+	struct qlcnic_esw_statistics esw_stats;
+	int ret;
+
+	if (size != sizeof(struct qlcnic_esw_statistics))
+		return QL_STATUS_INVALID_PARAM;
+
+	if (offset >= QLCNIC_NIU_MAX_XG_PORTS)
+		return QL_STATUS_INVALID_PARAM;
+
+	memset(&esw_stats, 0, size);
+	ret = qlcnic_get_eswitch_stats(adapter, offset, QLCNIC_QUERY_RX_COUNTER,
+								&esw_stats.rx);
+	if (ret)
+		return ret;
+
+	ret = qlcnic_get_eswitch_stats(adapter, offset, QLCNIC_QUERY_TX_COUNTER,
+								&esw_stats.tx);
+	if (ret)
+		return ret;
+
+	memcpy(buf, &esw_stats, size);
+	return size;
+}
+
+static ssize_t
+qlcnic_sysfs_clear_esw_stats(struct file *file, struct kobject *kobj,
+	struct bin_attribute *attr, char *buf, loff_t offset, size_t size)
+{
+	struct device *dev = container_of(kobj, struct device, kobj);
+	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
+	int ret;
+
+	if (offset >= QLCNIC_NIU_MAX_XG_PORTS)
+		return QL_STATUS_INVALID_PARAM;
+
+	ret = qlcnic_clear_esw_stats(adapter, QLCNIC_STATS_ESWITCH, offset,
+						QLCNIC_QUERY_RX_COUNTER);
+	if (ret)
+		return ret;
+
+	ret = qlcnic_clear_esw_stats(adapter, QLCNIC_STATS_ESWITCH, offset,
+						QLCNIC_QUERY_TX_COUNTER);
+	if (ret)
+		return ret;
+
+	return size;
+}
+
+static ssize_t
+qlcnic_sysfs_clear_port_stats(struct file *file, struct kobject *kobj,
+	struct bin_attribute *attr, char *buf, loff_t offset, size_t size)
+{
+
+	struct device *dev = container_of(kobj, struct device, kobj);
+	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
+	int ret;
+
+	if (offset >= QLCNIC_MAX_PCI_FUNC)
+		return QL_STATUS_INVALID_PARAM;
+
+	ret = qlcnic_clear_esw_stats(adapter, QLCNIC_STATS_PORT, offset,
+						QLCNIC_QUERY_RX_COUNTER);
+	if (ret)
+		return ret;
+
+	ret = qlcnic_clear_esw_stats(adapter, QLCNIC_STATS_PORT, offset,
+						QLCNIC_QUERY_TX_COUNTER);
+	if (ret)
+		return ret;
+
+	return size;
+}
+
+static ssize_t
 qlcnic_sysfs_read_pci_config(struct file *file, struct kobject *kobj,
 	struct bin_attribute *attr, char *buf, loff_t offset, size_t size)
 {
@@ -3426,6 +3535,20 @@ static struct bin_attribute bin_attr_pci_config = {
 	.write = NULL,
 };
 
+static struct bin_attribute bin_attr_port_stats = {
+	.attr = {.name = "port_stats", .mode = (S_IRUGO | S_IWUSR)},
+	.size = 0,
+	.read = qlcnic_sysfs_get_port_stats,
+	.write = qlcnic_sysfs_clear_port_stats,
+};
+
+static struct bin_attribute bin_attr_esw_stats = {
+	.attr = {.name = "esw_stats", .mode = (S_IRUGO | S_IWUSR)},
+	.size = 0,
+	.read = qlcnic_sysfs_get_esw_stats,
+	.write = qlcnic_sysfs_clear_esw_stats,
+};
+
 static struct bin_attribute bin_attr_esw_config = {
 	.attr = {.name = "esw_config", .mode = (S_IRUGO | S_IWUSR)},
 	.size = 0,
@@ -3465,6 +3588,9 @@ qlcnic_create_diag_entries(struct qlcnic_adapter *adapter)
 {
 	struct device *dev = &adapter->pdev->dev;
 
+	if (device_create_bin_file(dev, &bin_attr_port_stats))
+		dev_info(dev, "failed to create port stats sysfs entry");
+
 	if (adapter->op_mode == QLCNIC_NON_PRIV_FUNC)
 		return;
 	if (device_create_file(dev, &dev_attr_diag_mode))
@@ -3484,7 +3610,8 @@ qlcnic_create_diag_entries(struct qlcnic_adapter *adapter)
 		dev_info(dev, "failed to create esw config sysfs entry");
 	if (device_create_bin_file(dev, &bin_attr_pm_config))
 		dev_info(dev, "failed to create pm config sysfs entry");
-
+	if (device_create_bin_file(dev, &bin_attr_esw_stats))
+		dev_info(dev, "failed to create eswitch stats sysfs entry");
 }
 
 static void
@@ -3492,6 +3619,8 @@ qlcnic_remove_diag_entries(struct qlcnic_adapter *adapter)
 {
 	struct device *dev = &adapter->pdev->dev;
 
+	device_remove_bin_file(dev, &bin_attr_port_stats);
+
 	if (adapter->op_mode == QLCNIC_NON_PRIV_FUNC)
 		return;
 	device_remove_file(dev, &dev_attr_diag_mode);
@@ -3504,6 +3633,7 @@ qlcnic_remove_diag_entries(struct qlcnic_adapter *adapter)
 	device_remove_bin_file(dev, &bin_attr_npar_config);
 	device_remove_bin_file(dev, &bin_attr_esw_config);
 	device_remove_bin_file(dev, &bin_attr_pm_config);
+	device_remove_bin_file(dev, &bin_attr_esw_stats);
 }
 
 #ifdef CONFIG_INET
-- 
1.6.0.2

