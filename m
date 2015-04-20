From: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>
Subject: [RFC] [PATCH] FUJITSU Extended Socket network device driver
Date: Mon, 20 Apr 2015 08:37:17 +0000
Message-ID: <E86EADE93E2D054CBCD4E708C38D364A5421C170@G01JPEXMBYT01>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
To: "platform-driver-x86@vger.kernel.org"
	<platform-driver-x86@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <platform-driver-x86-owner@vger.kernel.org>
Content-Language: ja-JP
Sender: platform-driver-x86-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds support for FUJITSU Extended Socket network
device. Extended Socket network device is a shared memory
based high-speed network interface between Extended Partitions of
PRIMEQUEST 2000 series.

#
I know this code needs more refuctoring, but I wanted to post
this code as soon as possible because posting driver code
from scratch is first time for me.
#

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/platform/x86/Kconfig             |    8 +
 drivers/platform/x86/Makefile            |    2 +
 drivers/platform/x86/fjes/Makefile       |   31 +
 drivers/platform/x86/fjes/fjes.h         |   87 ++
 drivers/platform/x86/fjes/fjes_ethtool.c |  135 +++
 drivers/platform/x86/fjes/fjes_hw.c      | 1148 ++++++++++++++++++++++
 drivers/platform/x86/fjes/fjes_hw.h      |  353 +++++++
 drivers/platform/x86/fjes/fjes_main.c    | 1525 ++++++++++++++++++++++++++++++
 drivers/platform/x86/fjes/fjes_regs.h    |  139 +++
 9 files changed, 3428 insertions(+)
 create mode 100644 drivers/platform/x86/fjes/Makefile
 create mode 100755 drivers/platform/x86/fjes/fjes.h
 create mode 100755 drivers/platform/x86/fjes/fjes_ethtool.c
 create mode 100755 drivers/platform/x86/fjes/fjes_hw.c
 create mode 100755 drivers/platform/x86/fjes/fjes_hw.h
 create mode 100755 drivers/platform/x86/fjes/fjes_main.c
 create mode 100755 drivers/platform/x86/fjes/fjes_regs.h

diff --git a/drivers/platform/x86/Kconfig b/drivers/platform/x86/Kconfig
index 9752761..268c7495 100644
--- a/drivers/platform/x86/Kconfig
+++ b/drivers/platform/x86/Kconfig
@@ -884,4 +884,12 @@ config PVPANIC
 	  a paravirtualized device provided by QEMU; it lets a virtual machine
 	  (guest) communicate panic events to the host.
 
+config FUJITSU_ES
+	tristate "FUJITSU Extended Socket Network Device driver"
+	depends on ACPI
+	---help---
+	  This driver provides support for Extended Socket network device on
+	  Extended Partitioning of FUJITSU PRIMEQUEST 2000 series.
+
+
 endif # X86_PLATFORM_DEVICES
diff --git a/drivers/platform/x86/Makefile b/drivers/platform/x86/Makefile
index f82232b..319eb20 100644
--- a/drivers/platform/x86/Makefile
+++ b/drivers/platform/x86/Makefile
@@ -58,3 +58,5 @@ obj-$(CONFIG_INTEL_SMARTCONNECT)	+= intel-smartconnect.o
 
 obj-$(CONFIG_PVPANIC)           += pvpanic.o
 obj-$(CONFIG_ALIENWARE_WMI)	+= alienware-wmi.o
+
+obj-$(CONFIG_FUJITSU_ES)	+= fjes/
diff --git a/drivers/platform/x86/fjes/Makefile b/drivers/platform/x86/fjes/Makefile
new file mode 100644
index 0000000..45dc9d3
--- /dev/null
+++ b/drivers/platform/x86/fjes/Makefile
@@ -0,0 +1,31 @@
+################################################################################
+# 
+# FUJITSU Extended Socket Network Device driver
+# Copyright (c) 2015 FUJITSU LIMITED
+#
+# This program is free software; you can redistribute it and/or modify it
+# under the terms and conditions of the GNU General Public License,
+# version 2, as published by the Free Software Foundation.
+#
+# This program is distributed in the hope it will be useful, but WITHOUT
+# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+# more details.
+#
+# You should have received a copy of the GNU General Public License along with
+# this program; if not, see <http://www.gnu.org/licenses/>.
+#
+# The full GNU General Public License is included in this distribution in
+# the file called "COPYING".
+#
+################################################################################
+
+
+#
+# Makefile for the FUJITSU Extended Socket network device driver
+#
+
+obj-$(CONFIG_FUJITSU_ES) += fjes.o
+
+fjes-objs := fjes_main.o fjes_ethtool.o fjes_hw.o
+
diff --git a/drivers/platform/x86/fjes/fjes.h b/drivers/platform/x86/fjes/fjes.h
new file mode 100755
index 0000000..890f16f
--- /dev/null
+++ b/drivers/platform/x86/fjes/fjes.h
@@ -0,0 +1,87 @@
+/*
+ *  FUJITSU Extended Socket Network Device driver
+ *  Copyright (c) 2015 FUJITSU LIMITED
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, see <http://www.gnu.org/licenses/>.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ */
+
+
+#ifndef FJES_H_
+#define FJES_H_
+
+#include <linux/acpi.h>
+#include <linux/workqueue.h>
+
+#include "fjes_hw.h"
+
+struct fjes_adapter;
+
+#define FJES_ACPI_SYMBOL	"Extended Socket"
+
+#define FJES_MAX_QUEUES		1
+#define FJES_TX_RETRY_INTERVAL	(20 * HZ)
+#define FJES_TX_RETRY_TIMEOUT	(100)
+#define FJES_TX_TX_STALL_TIMEOUT	(FJES_TX_RETRY_INTERVAL/2)
+#define FJES_OPEN_ZONE_UPDATE_WAIT	(300) /* msec */
+#define FJES_IRQ_WATCH_DELAY	(HZ)
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
+
+	struct work_struct force_close_task;
+	bool force_reset;
+	bool open_guard;
+
+	bool irq_registered;
+
+	struct workqueue_struct *txrx_wq;
+	struct workqueue_struct *control_wq;
+
+	struct work_struct tx_stall_task;
+	struct work_struct raise_intr_rxdata_task;
+
+	struct work_struct unshare_watch_task;
+	unsigned long unshare_watch_bitmask;
+
+	struct delayed_work interrupt_watch_task;
+	bool interrupt_watch_enable;
+
+	struct fjes_hw hw;
+
+};
+
+extern char fjes_driver_name[];
+extern char fjes_driver_version[];
+extern u32 fjes_support_mtu[];
+
+
+void fjes_set_ethtool_ops(struct net_device *);
+
+#endif /* FJES_H_ */
diff --git a/drivers/platform/x86/fjes/fjes_ethtool.c b/drivers/platform/x86/fjes/fjes_ethtool.c
new file mode 100755
index 0000000..49974d2
--- /dev/null
+++ b/drivers/platform/x86/fjes/fjes_ethtool.c
@@ -0,0 +1,135 @@
+/*
+ *  FUJITSU Extended Socket Network Device driver
+ *  Copyright (c) 2015 FUJITSU LIMITED
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, see <http://www.gnu.org/licenses/>.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ */
+
+/* ethtool support for fjes */
+
+#include <linux/vmalloc.h>
+#include <linux/netdevice.h>
+#include <linux/ethtool.h>
+
+#include "fjes.h"
+
+
+struct fjes_stats {
+	char stat_string[ETH_GSTRING_LEN];
+	int sizeof_stat;
+	int stat_offset;
+};
+
+#define FJES_STAT(name, stat) { \
+	.stat_string = name, \
+	.sizeof_stat = FIELD_SIZEOF(struct fjes_adapter, stat), \
+	.stat_offset = offsetof(struct fjes_adapter, stat) \
+}
+
+
+static const struct fjes_stats fjes_gstrings_stats[] = {
+	FJES_STAT("rx_packets", stats64.rx_packets),
+	FJES_STAT("tx_packets", stats64.tx_packets),
+	FJES_STAT("rx_bytes", stats64.rx_bytes),
+	FJES_STAT("tx_bytes", stats64.rx_bytes),
+	FJES_STAT("rx_dropped", stats64.rx_dropped),
+	FJES_STAT("tx_dropped", stats64.tx_dropped),
+};
+
+static void fjes_get_ethtool_stats(struct net_device *netdev,
+		struct ethtool_stats *stats, u64 *data)
+{
+	struct fjes_adapter *adapter = netdev_priv(netdev);
+	int i;
+	char *p = NULL;
+
+	for (i = 0; i < ARRAY_SIZE(fjes_gstrings_stats); i++) {
+		p = (char *)adapter + fjes_gstrings_stats[i].stat_offset;
+		data[i] = (fjes_gstrings_stats[i].sizeof_stat == sizeof(u64))
+			? *(u64 *)p : *(u32 *)p;
+	}
+}
+
+static void fjes_get_strings(struct net_device *netdev,
+		u32 stringset, u8 *data)
+{
+	u8 *p = data;
+	int i;
+
+	switch (stringset) {
+	case ETH_SS_STATS:
+		for (i = 0; i < ARRAY_SIZE(fjes_gstrings_stats); i++) {
+			memcpy(p, fjes_gstrings_stats[i].stat_string,
+				ETH_GSTRING_LEN);
+			p += ETH_GSTRING_LEN;
+		}
+		break;
+	}
+}
+
+
+static int fjes_get_sset_count(struct net_device *netdev, int sset)
+{
+	switch (sset) {
+	case ETH_SS_STATS:
+		return ARRAY_SIZE(fjes_gstrings_stats);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static void fjes_get_drvinfo(struct net_device *netdev,
+		struct ethtool_drvinfo *drvinfo)
+{
+	strlcpy(drvinfo->driver, fjes_driver_name, sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, fjes_driver_version,
+			sizeof(drvinfo->version));
+
+	strlcpy(drvinfo->fw_version, "none", sizeof(drvinfo->fw_version));
+	strlcpy(drvinfo->bus_info, "none", sizeof(drvinfo->bus_info));
+	drvinfo->regdump_len = 0;
+	drvinfo->eedump_len = 0;
+
+}
+
+
+static int fjes_get_settings(struct net_device *netdev,
+		struct ethtool_cmd *ecmd)
+{
+	ecmd->supported = 0;
+	ecmd->advertising = 0;
+	ecmd->duplex = DUPLEX_FULL;
+	ecmd->autoneg = AUTONEG_DISABLE;
+	ecmd->transceiver = XCVR_DUMMY1;
+	ecmd->port = PORT_NONE;
+	ethtool_cmd_speed_set(ecmd, 20000);	/* 20Gb/s */
+	return 0;
+}
+
+
+static const struct ethtool_ops fjes_ethtool_ops = {
+		.get_settings		= fjes_get_settings,
+		.get_drvinfo		= fjes_get_drvinfo,
+		.get_ethtool_stats = fjes_get_ethtool_stats,
+		.get_strings      = fjes_get_strings,
+		.get_sset_count   = fjes_get_sset_count,
+};
+
+void fjes_set_ethtool_ops(struct net_device *netdev)
+{
+	netdev->ethtool_ops = &fjes_ethtool_ops;
+}
diff --git a/drivers/platform/x86/fjes/fjes_hw.c b/drivers/platform/x86/fjes/fjes_hw.c
new file mode 100755
index 0000000..324bedd
--- /dev/null
+++ b/drivers/platform/x86/fjes/fjes_hw.c
@@ -0,0 +1,1148 @@
+/*
+ *  FUJITSU Extended Socket Network Device driver
+ *  Copyright (c) 2015 FUJITSU LIMITED
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, see <http://www.gnu.org/licenses/>.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ */
+
+#include "fjes_hw.h"
+#include "fjes.h"
+
+
+static void fjes_hw_update_zone_task(struct work_struct *);
+static void fjes_hw_epstop_task(struct work_struct *);
+
+
+static u8 *fjes_hw_iomap(struct fjes_hw *hw)
+{
+	u8 *base;
+
+	if (!request_mem_region(hw->hw_res.start, hw->hw_res.size,
+			fjes_driver_name)) {
+		pr_err("request_mem_region failed");
+		return NULL;
+	}
+
+	base = (u8 *)ioremap_nocache(hw->hw_res.start, hw->hw_res.size);
+
+	return base;
+}
+
+static void fjes_hw_iounmap(struct fjes_hw *hw)
+{
+	iounmap(hw->base);
+	release_mem_region(hw->hw_res.start, hw->hw_res.size);
+}
+
+
+int fjes_hw_reset(struct fjes_hw *hw)
+{
+
+	int timeout;
+	union REG_DCTL dctl;
+
+	dctl.Reg = 0;
+	dctl.Bits.reset = 1;
+	wr32(dctl.Reg, XSCT_DCTL);
+
+
+	timeout = FJES_DEVICE_RESET_TIMEOUT * 1000;
+	dctl.Reg = rd32(XSCT_DCTL);
+	while ((dctl.Bits.reset == 1) && (timeout > 0)) {
+		msleep(1000);
+		dctl.Reg = rd32(XSCT_DCTL);
+		timeout -= 1000;
+	}
+
+	return timeout > 0 ? 0 : -EIO;
+
+}
+
+static int fjes_hw_get_max_epid(struct fjes_hw *hw)
+{
+	union REG_MAX_EP info;
+
+	info.Reg = rd32(XSCT_MAX_EP);
+
+	return info.Bits.maxep;
+}
+
+static int fjes_hw_get_my_epid(struct fjes_hw *hw)
+{
+	union REG_OWNER_EPID info;
+
+	info.Reg = rd32(XSCT_OWNER_EPID);
+
+	return info.Bits.epid;
+}
+
+static int fjes_hw_alloc_shared_status_region(struct fjes_hw *hw)
+{
+	size_t size;
+
+	size = sizeof(struct fjes_device_shared_info) +
+	    (sizeof(u8) * hw->max_epid);
+	hw->hw_info.share = kzalloc(size, GFP_KERNEL);
+	if (!hw->hw_info.share)
+		return -ENOMEM;
+
+	hw->hw_info.share->epnum = hw->max_epid;
+
+	return 0;
+}
+
+static void fjes_hw_free_shared_status_region(struct fjes_hw *hw)
+{
+	kfree(hw->hw_info.share);
+	hw->hw_info.share = NULL;
+}
+
+static int fjes_hw_alloc_epbuf(struct epbuf_handler *epbh)
+{
+	void *mem;
+
+	mem = vmalloc(EP_BUFFER_SIZE);
+	if (!mem)
+		return -ENOMEM;
+	memset(mem, 0, EP_BUFFER_SIZE);
+
+	epbh->buffer = mem;
+	epbh->size = EP_BUFFER_SIZE;
+
+	epbh->info = (union ep_buffer_info *)mem;
+	epbh->ring = (u8 *) (mem + sizeof(union ep_buffer_info));
+
+	return 0;
+}
+
+static void fjes_hw_free_epbuf(struct epbuf_handler *epbh)
+{
+	if (epbh->buffer)
+		vfree(epbh->buffer);
+
+	epbh->buffer = NULL;
+	epbh->size = 0;
+
+	epbh->info = NULL;
+	epbh->ring = NULL;
+}
+
+
+void fjes_hw_setup_epbuf(struct epbuf_handler *epbh, u8 *mac_addr, u32 mtu)
+{
+
+	union ep_buffer_info *info = epbh->info;
+	int i;
+	u16 vlan_id[EP_BUFFER_SUPPORT_VLAN_MAX];
+
+	for (i = 0; i < EP_BUFFER_SUPPORT_VLAN_MAX; i++)
+		vlan_id[i] = info->v1i.vlan_id[i];
+
+	memset((void *)info, 0, sizeof(union ep_buffer_info));
+
+	info->v1i.version = 0;  /* version 0 */
+
+	for (i = 0; i < ETH_ALEN; i++)
+		info->v1i.mac_addr[i] = mac_addr[i];
+
+	info->v1i.head = 0;
+	info->v1i.tail = 1;
+
+	info->v1i.info_size = sizeof(union ep_buffer_info);
+	info->v1i.buffer_size = epbh->size - info->v1i.info_size;
+
+	info->v1i.frame_max = FJES_MTU_TO_FRAME_SIZE(mtu);
+	info->v1i.count_max =
+	    EP_RING_NUM(info->v1i.buffer_size, info->v1i.frame_max);
+
+	for (i = 0; i < EP_BUFFER_SUPPORT_VLAN_MAX; i++)
+		info->v1i.vlan_id[i] = vlan_id[i];
+
+}
+
+
+void fjes_hw_init_command_registers(struct fjes_hw *hw,
+		struct fjes_device_command_param *param)
+{
+
+	/* Request Buffer length */
+	wr32(__cpu_to_le32(param->req_len), XSCT_REQBL);
+	/* Response Buffer Length */
+	wr32(__cpu_to_le32(param->res_len), XSCT_RESPBL);
+
+	/* Request Buffer Address */
+	wr32(__cpu_to_le32(param->req_start & GENMASK_ULL(31, 0)),
+			XSCT_REQBAL);
+	wr32(__cpu_to_le32(param->req_start & GENMASK_ULL(63, 32) >> 32),
+			XSCT_REQBAH);
+
+
+	/* Response Buffer Address */
+	wr32(__cpu_to_le32(param->res_start & GENMASK_ULL(31, 0)),
+			XSCT_RESPBAL);
+	wr32(__cpu_to_le32(param->res_start & GENMASK_ULL(63, 32) >> 32),
+			XSCT_RESPBAH);
+
+	/* Share status address */
+	wr32(__cpu_to_le32(param->share_start & GENMASK_ULL(31, 0)),
+			XSCT_SHSTSAL);
+	wr32(__cpu_to_le32(param->share_start & GENMASK_ULL(63, 32) >> 32),
+			XSCT_SHSTSAH);
+}
+
+
+static int fjes_hw_setup(struct fjes_hw *hw)
+{
+	int epidx;
+	void *buf;
+	struct ep_share_mem_info *buf_pair;
+	size_t mem_size;
+	int result;
+	u8 mac[ETH_ALEN] = { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };
+	struct fjes_device_command_param param;
+
+	hw->hw_info.max_epid = &(hw->max_epid);
+	hw->hw_info.my_epid = &(hw->my_epid);
+
+
+	mem_size = sizeof(struct ep_share_mem_info) * (hw->max_epid);
+	buf = kzalloc(mem_size, GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
+
+	hw->ep_shm_info = (struct ep_share_mem_info *)buf;
+
+	mem_size = FJES_DEV_REQ_BUF_SIZE(hw->max_epid);
+	hw->hw_info.req_buf = kzalloc(mem_size, GFP_KERNEL);
+	if (!(hw->hw_info.req_buf))
+		return -ENOMEM;
+
+	hw->hw_info.req_buf_size = mem_size;
+
+	mem_size = FJES_DEV_RES_BUF_SIZE(hw->max_epid);
+	hw->hw_info.res_buf = kzalloc(mem_size, GFP_KERNEL);
+	if (!(hw->hw_info.res_buf))
+		return -ENOMEM;
+
+	hw->hw_info.res_buf_size = mem_size;
+
+	result = fjes_hw_alloc_shared_status_region(hw);
+	if (result)
+		return result;
+
+	hw->hw_info.buffer_share_bit = 0;
+	hw->hw_info.buffer_unshare_reserve_bit = 0;
+
+	for (epidx = 0; epidx < hw->max_epid; epidx++) {
+		if (epidx != hw->my_epid) {
+			buf_pair = &(hw->ep_shm_info[epidx]);
+
+			result = fjes_hw_alloc_epbuf(&(buf_pair->tx));
+			if (result)
+				return result;
+
+			result = fjes_hw_alloc_epbuf(&(buf_pair->rx));
+			if (result)
+				return result;
+
+			fjes_hw_setup_epbuf(&(buf_pair->tx), mac,
+						  fjes_support_mtu[0]);
+			fjes_hw_setup_epbuf(&(buf_pair->rx), mac,
+						  fjes_support_mtu[0]);
+		}
+	}
+
+	memset((void *)&param, 0, sizeof(param));
+
+	param.req_len = hw->hw_info.req_buf_size;
+	param.req_start = __pa(hw->hw_info.req_buf);
+	param.res_len = hw->hw_info.res_buf_size;
+	param.res_start = __pa(hw->hw_info.res_buf);
+
+	param.share_start = __pa(hw->hw_info.share->ep_status);
+
+	fjes_hw_init_command_registers(hw, &param);
+
+	return 0;
+}
+
+static void fjes_hw_cleanup(struct fjes_hw *hw)
+{
+	int epidx;
+
+	if (!hw->ep_shm_info)
+		return;
+
+	fjes_hw_free_shared_status_region(hw);
+
+	kfree(hw->hw_info.req_buf);
+	hw->hw_info.req_buf = NULL;
+
+	kfree(hw->hw_info.res_buf);
+	hw->hw_info.res_buf = NULL;
+
+	for (epidx = 0; epidx < hw->max_epid ; epidx++) {
+		if (epidx == hw->my_epid)
+			continue;
+		fjes_hw_free_epbuf(&hw->ep_shm_info[epidx].tx);
+		fjes_hw_free_epbuf(&hw->ep_shm_info[epidx].rx);
+	}
+
+	kfree(hw->ep_shm_info);
+	hw->ep_shm_info = NULL;
+
+}
+
+
+int fjes_hw_init(struct fjes_hw *hw)
+{
+	int ret;
+
+	hw->base = fjes_hw_iomap(hw);
+	if (hw->base == NULL)
+		return -EIO;
+
+	ret = fjes_hw_reset(hw);
+	if (ret)
+		return ret;
+
+	fjes_hw_set_irqmask(hw, REG_ICTL_MASK_ALL, true);
+
+	INIT_WORK(&hw->update_zone_task, fjes_hw_update_zone_task);
+	INIT_WORK(&hw->epstop_task, fjes_hw_epstop_task);
+
+	mutex_init(&hw->hw_info.lock);
+
+	hw->max_epid = fjes_hw_get_max_epid(hw);
+	hw->my_epid = fjes_hw_get_my_epid(hw);
+
+	if ((hw->my_epid == 0) || (hw->my_epid >= hw->max_epid))
+		return -ENXIO;
+
+	ret = fjes_hw_setup(hw);
+
+	return ret;
+}
+
+void fjes_hw_exit(struct fjes_hw *hw)
+{
+	int ret;
+
+	if (hw->base) {
+		ret = fjes_hw_reset(hw);
+		if (ret)
+			pr_err("%s: reset error", __func__);
+
+		fjes_hw_iounmap(hw);
+		hw->base = NULL;
+	}
+
+	fjes_hw_cleanup(hw);
+}
+
+static enum fjes_dev_command_response_e fjes_hw_issue_request_command(
+	struct fjes_hw *hw, enum fjes_dev_command_request_type type)
+{
+	union REG_CR cr;
+	union REG_CS cs;
+	enum fjes_dev_command_response_e ret = FJES_CMD_STATUS_UNKNOWN;
+	int timeout;
+
+	cr.Reg = 0;
+	cr.Bits.req_start = 1;
+	cr.Bits.req_code = type;
+	wr32(cr.Reg, XSCT_CR);
+	cr.Reg = rd32(XSCT_CR);
+
+	if (cr.Bits.error == 0) {
+		timeout = FJES_COMMAND_REQ_TIMEOUT * 1000;
+		cs.Reg = rd32(XSCT_CS);
+
+		while ((cs.Bits.complete != 1) && timeout > 0) {
+			msleep(1000);
+			cs.Reg = rd32(XSCT_CS);
+			timeout -= 1000;
+		}
+
+		if (cs.Bits.complete == 1)
+			ret = FJES_CMD_STATUS_NORMAL;
+		else if (timeout < 0)
+			ret = FJES_CMD_STATUS_TIMEOUT;
+
+	} else {
+		switch (cr.Bits.err_info) {
+		case FJES_CMD_REQ_ERR_INFO_PARAM:
+			ret = FJES_CMD_STATUS_ERROR_PARAM;
+			break;
+		case FJES_CMD_REQ_ERR_INFO_STATUS:
+			ret = FJES_CMD_STATUS_ERROR_STATUS;
+			break;
+		default:
+			ret = FJES_CMD_STATUS_UNKNOWN;
+			break;
+		}
+	}
+
+	return ret;
+}
+
+
+int fjes_hw_request_info(struct fjes_hw *hw)
+{
+	union fjes_device_command_req *req_buf = hw->hw_info.req_buf;
+	union fjes_device_command_res *res_buf = hw->hw_info.res_buf;
+	enum fjes_dev_command_response_e ret;
+	int result;
+
+	memset(req_buf, 0, hw->hw_info.req_buf_size);
+	memset(res_buf, 0, hw->hw_info.res_buf_size);
+
+	req_buf->info.length = FJES_DEV_COMMAND_INFO_REQ_LEN;
+
+	res_buf->info.length = 0;
+	res_buf->info.code = 0;
+
+	ret = fjes_hw_issue_request_command(hw, FJES_CMD_REQ_INFO);
+
+	result = 0;
+
+	if (FJES_DEV_COMMAND_INFO_RES_LEN((*(hw->hw_info.max_epid))) !=
+		res_buf->info.length) {
+		result = -ENOMSG;
+	} else if (ret == FJES_CMD_STATUS_NORMAL) {
+
+		switch (res_buf->info.code) {
+		case FJES_CMD_REQ_RES_CODE_NORMAL:
+			result = 0;
+			break;
+		default:
+			result = -EPERM;
+			break;
+		}
+	} else {
+		switch (ret) {
+		case FJES_CMD_STATUS_UNKNOWN:
+			result = -EPERM;
+			break;
+		case FJES_CMD_STATUS_TIMEOUT:
+			result = -EBUSY;
+			break;
+		case FJES_CMD_STATUS_ERROR_PARAM:
+			result = -EPERM;
+			break;
+		case FJES_CMD_STATUS_ERROR_STATUS:
+			result = -EPERM;
+			break;
+		default:
+			result = -EPERM;
+			break;
+		}
+	}
+
+	return result;
+}
+
+int fjes_hw_register_buff_addr(struct fjes_hw *hw, int dest_epid,
+		struct ep_share_mem_info *buf_pair)
+{
+	union fjes_device_command_req *req_buf = hw->hw_info.req_buf;
+	union fjes_device_command_res *res_buf = hw->hw_info.res_buf;
+	enum fjes_dev_command_response_e ret;
+	int i, idx;
+	int page_count;
+	void *addr;
+	int timeout;
+	int result;
+
+	if (test_bit(dest_epid, &hw->hw_info.buffer_share_bit))
+		return 0;
+
+	memset(req_buf, 0, hw->hw_info.req_buf_size);
+	memset(res_buf, 0, hw->hw_info.res_buf_size);
+
+	req_buf->share_buffer.length =
+		FJES_DEV_COMMAND_SHARE_BUFFER_REQ_LEN(buf_pair->tx.size,
+				buf_pair->rx.size);
+	req_buf->share_buffer.epid = dest_epid;
+
+	idx = 0;
+	req_buf->share_buffer.buffer[idx++] = buf_pair->tx.size;
+	page_count = buf_pair->tx.size / EP_BUFFER_INFO_SIZE;
+	for (i = 0; i < page_count; i++) {
+		addr = ((u8 *)(buf_pair->tx.buffer)) +
+				(i * EP_BUFFER_INFO_SIZE);
+		req_buf->share_buffer.buffer[idx++] =
+				(__le64)(page_to_phys(vmalloc_to_page(addr)) +
+						offset_in_page(addr));
+	}
+
+	req_buf->share_buffer.buffer[idx++] = buf_pair->rx.size;
+	page_count = buf_pair->rx.size / EP_BUFFER_INFO_SIZE;
+	for (i = 0; i < page_count; i++) {
+		addr = ((u8 *)(buf_pair->rx.buffer)) +
+				(i * EP_BUFFER_INFO_SIZE);
+		req_buf->share_buffer.buffer[idx++] =
+				(__le64)(page_to_phys(vmalloc_to_page(addr)) +
+						offset_in_page(addr));
+	}
+
+	res_buf->share_buffer.length = 0;
+	res_buf->share_buffer.code = 0;
+
+	ret = fjes_hw_issue_request_command(hw, FJES_CMD_REQ_SHARE_BUFFER);
+
+	timeout = FJES_COMMAND_REQ_BUFF_TIMEOUT * 1000;
+	while ((ret == FJES_CMD_STATUS_NORMAL) &&
+		   (res_buf->share_buffer.length ==
+				   FJES_DEV_COMMAND_SHARE_BUFFER_RES_LEN) &&
+		   (res_buf->share_buffer.code == FJES_CMD_REQ_RES_CODE_BUSY) &&
+		   (timeout > 0)) {
+
+			msleep(200 + hw->my_epid * 20);
+			timeout -= (200 + hw->my_epid * 20);
+
+			res_buf->share_buffer.length = 0;
+			res_buf->share_buffer.code = 0;
+
+			ret = fjes_hw_issue_request_command(hw,
+					FJES_CMD_REQ_SHARE_BUFFER);
+	}
+
+	result = 0;
+
+	if (res_buf->share_buffer.length !=
+			FJES_DEV_COMMAND_SHARE_BUFFER_RES_LEN)
+		result = -ENOMSG;
+	else if (ret == FJES_CMD_STATUS_NORMAL) {
+		switch (res_buf->share_buffer.code) {
+		case FJES_CMD_REQ_RES_CODE_NORMAL:
+			result = 0;
+			set_bit(dest_epid, &hw->hw_info.buffer_share_bit);
+			break;
+		case FJES_CMD_REQ_RES_CODE_BUSY:
+			result = -EBUSY;
+			break;
+		default:
+			result = -EPERM;
+			break;
+		}
+	} else {
+		switch (ret) {
+		case FJES_CMD_STATUS_UNKNOWN:
+			result = -EPERM;
+			break;
+		case FJES_CMD_STATUS_TIMEOUT:
+			result = -EBUSY;
+			break;
+		case FJES_CMD_STATUS_ERROR_PARAM:
+		case FJES_CMD_STATUS_ERROR_STATUS:
+		default:
+			result = -EPERM;
+			break;
+		}
+	}
+
+	return result;
+}
+
+
+int fjes_hw_unregister_buff_addr(struct fjes_hw *hw, int dest_epid)
+{
+	union fjes_device_command_req *req_buf = hw->hw_info.req_buf;
+	union fjes_device_command_res *res_buf = hw->hw_info.res_buf;
+	struct fjes_device_shared_info *share = hw->hw_info.share;
+	enum fjes_dev_command_response_e ret;
+	int result;
+	int timeout;
+
+
+	if (!hw->base)
+		return -EPERM;
+
+	if (req_buf == NULL || res_buf == NULL || share == NULL)
+		return -EPERM;
+
+	if (!test_bit(dest_epid, &hw->hw_info.buffer_share_bit))
+		return 0;
+
+	memset(req_buf, 0, hw->hw_info.req_buf_size);
+	memset(res_buf, 0, hw->hw_info.res_buf_size);
+
+	req_buf->unshare_buffer.length =
+			FJES_DEV_COMMAND_UNSHARE_BUFFER_REQ_LEN;
+	req_buf->unshare_buffer.epid = dest_epid;
+
+	res_buf->unshare_buffer.length = 0;
+	res_buf->unshare_buffer.code = 0;
+
+	ret = fjes_hw_issue_request_command(hw, FJES_CMD_REQ_UNSHARE_BUFFER);
+
+	timeout = FJES_COMMAND_REQ_BUFF_TIMEOUT * 1000;
+	while ((ret == FJES_CMD_STATUS_NORMAL) &&
+		   (res_buf->unshare_buffer.length ==
+				FJES_DEV_COMMAND_UNSHARE_BUFFER_RES_LEN) &&
+		   (res_buf->unshare_buffer.code ==
+				FJES_CMD_REQ_RES_CODE_BUSY) &&
+		   (timeout > 0)) {
+
+		msleep(200 + hw->my_epid * 20);
+			timeout -= (200 + hw->my_epid * 20);
+
+		res_buf->unshare_buffer.length = 0;
+		res_buf->unshare_buffer.code = 0;
+
+		ret = fjes_hw_issue_request_command(hw,
+				FJES_CMD_REQ_UNSHARE_BUFFER);
+	}
+
+	result = 0;
+
+	if (res_buf->unshare_buffer.length !=
+			FJES_DEV_COMMAND_UNSHARE_BUFFER_RES_LEN) {
+		result = -ENOMSG;
+	} else if (ret == FJES_CMD_STATUS_NORMAL) {
+		switch (res_buf->unshare_buffer.code) {
+		case FJES_CMD_REQ_RES_CODE_NORMAL:
+			result = 0;
+			clear_bit(dest_epid, &hw->hw_info.buffer_share_bit);
+			break;
+		case FJES_CMD_REQ_RES_CODE_BUSY:
+			result = -EBUSY;
+			break;
+		default:
+			result = -EPERM;
+			break;
+		}
+	} else {
+		switch (ret) {
+		case FJES_CMD_STATUS_UNKNOWN:
+			result = -EPERM;
+			break;
+		case FJES_CMD_STATUS_TIMEOUT:
+			result = -EBUSY;
+			break;
+		case FJES_CMD_STATUS_ERROR_PARAM:
+		case FJES_CMD_STATUS_ERROR_STATUS:
+		default:
+			result = -EPERM;
+			break;
+		}
+	}
+
+	return result;
+}
+
+
+int fjes_hw_raise_interrupt(struct fjes_hw *hw, int dest_epid,
+		enum REG_ICTL_MASK  mask)
+{
+	u32 ig = mask | dest_epid;
+
+	wr32(cpu_to_le32(ig), XSCT_IG);
+	return 0;
+}
+
+u32 fjes_hw_capture_interrupt_status(struct fjes_hw *hw)
+{
+	u32 cur_is;
+
+	cur_is = rd32(XSCT_IS);
+	return cur_is;
+}
+
+void fjes_hw_set_irqmask(struct fjes_hw *hw, enum REG_ICTL_MASK intr_mask,
+		bool mask)
+{
+	if (mask)
+		wr32(intr_mask, XSCT_IMS);
+	else
+		wr32(intr_mask, XSCT_IMC);
+}
+
+
+bool fjes_hw_epid_is_same_zone(struct fjes_hw *hw, int epid)
+{
+	if (epid >= hw->max_epid)
+		return false;
+
+	if ((hw->ep_shm_info[epid].es_status !=
+			FJES_ZONING_STATUS_ENABLE) ||
+		(hw->ep_shm_info[hw->my_epid].zone ==
+			FJES_ZONING_ZONE_TYPE_NONE))
+		return false;
+	else
+		return (hw->ep_shm_info[epid].zone ==
+				hw->ep_shm_info[hw->my_epid].zone);
+
+}
+
+
+int fjes_hw_epid_is_shared(struct fjes_device_shared_info *share,
+		int dest_epid)
+{
+	int value = false;
+
+	if (dest_epid < share->epnum)
+		value = share->ep_status[dest_epid];
+
+	return value;
+}
+
+static bool fjes_hw_epid_is_stop_requested(struct fjes_hw *hw, int src_epid)
+{
+	return test_bit(src_epid, &hw->txrx_stop_req_bit);
+}
+
+static bool fjes_hw_epid_is_stop_process_done(struct fjes_hw *hw, int src_epid)
+{
+	return (hw->ep_shm_info[src_epid].tx.info->v1i.rx_status &
+			FJES_RX_STOP_REQ_DONE);
+}
+
+enum ep_partner_status
+fjes_hw_get_partner_ep_status(struct fjes_hw *hw, int epid)
+{
+	enum ep_partner_status status;
+
+	if (fjes_hw_epid_is_shared(hw->hw_info.share, epid)) {
+		if (fjes_hw_epid_is_stop_requested(hw, epid))
+			status = EP_PARTNER_WAITING;
+		else {
+			if (fjes_hw_epid_is_stop_process_done(hw, epid))
+				status = EP_PARTNER_COMPLETE;
+			else
+				status = EP_PARTNER_SHARED;
+		}
+	} else {
+		status = EP_PARTNER_UNSHARE;
+	}
+
+	return status;
+}
+
+
+void fjes_hw_raise_epstop(struct fjes_hw *hw)
+{
+	int epidx;
+	enum ep_partner_status status;
+
+	for (epidx = 0; epidx < hw->max_epid; epidx++) {
+		if (epidx == hw->my_epid)
+			continue;
+
+		status = fjes_hw_get_partner_ep_status(hw, epidx);
+		switch (status) {
+		case EP_PARTNER_SHARED:
+			fjes_hw_raise_interrupt(hw, epidx,
+					REG_ICTL_MASK_TXRX_STOP_REQ);
+			break;
+		default:
+			break;
+		}
+
+		set_bit(epidx, &hw->hw_info.buffer_unshare_reserve_bit);
+		set_bit(epidx, &hw->txrx_stop_req_bit);
+
+		hw->ep_shm_info[epidx].tx.info->v1i.rx_status |=
+				FJES_RX_STOP_REQ_REQUEST;
+
+	}
+
+}
+
+int fjes_hw_wait_epstop(struct fjes_hw *hw)
+{
+	int epidx;
+	int wait_time = 0;
+	enum ep_partner_status status;
+	union ep_buffer_info *info;
+
+	while (hw->hw_info.buffer_unshare_reserve_bit &&
+		   (wait_time < FJES_COMMAND_EPSTOP_WAIT_TIMEOUT * 1000)) {
+
+		for (epidx = 0; epidx < hw->max_epid; epidx++) {
+			if (epidx == hw->my_epid)
+				continue;
+			status = fjes_hw_epid_is_shared(hw->hw_info.share,
+					epidx);
+			info = hw->ep_shm_info[epidx].rx.info;
+			if ((!status ||
+				 (info->v1i.rx_status &
+					FJES_RX_STOP_REQ_DONE)) &&
+				test_bit(epidx,
+				 &hw->hw_info.buffer_unshare_reserve_bit)) {
+				clear_bit(epidx,
+				 &hw->hw_info.buffer_unshare_reserve_bit);
+			}
+		}
+
+		msleep(100);
+		wait_time += 100;
+
+	}
+
+	for (epidx = 0; epidx < hw->max_epid; epidx++) {
+		if (epidx == hw->my_epid)
+			continue;
+		if (test_bit(epidx, &hw->hw_info.buffer_unshare_reserve_bit))
+			clear_bit(epidx,
+				&hw->hw_info.buffer_unshare_reserve_bit);
+	}
+
+	return (wait_time < FJES_COMMAND_EPSTOP_WAIT_TIMEOUT * 1000)
+			? 0 : -EBUSY;
+}
+
+
+bool fjes_hw_check_epbuf_version(struct epbuf_handler *epbh, u32 version)
+{
+	union ep_buffer_info *info = epbh->info;
+
+	return (info->common.version == version);
+}
+
+bool fjes_hw_check_mtu(struct epbuf_handler *epbh, u32 mtu)
+{
+	union ep_buffer_info *info = epbh->info;
+
+	return (info->v1i.frame_max == FJES_MTU_TO_FRAME_SIZE(mtu));
+}
+
+bool fjes_hw_check_vlan_id(struct epbuf_handler *epbh, u16 vlan_id)
+{
+	union ep_buffer_info *info = epbh->info;
+	int i;
+	bool ret = false;
+
+	if (vlan_id == 0) {
+		ret = true;
+	} else {
+		for (i = 0; i < EP_BUFFER_SUPPORT_VLAN_MAX; i++) {
+			if (vlan_id == info->v1i.vlan_id[i]) {
+				ret = true;
+				break;
+			}
+		}
+	}
+	return ret;
+}
+
+
+bool fjes_hw_set_vlan_id(struct epbuf_handler *epbh, u16 vlan_id)
+{
+	union ep_buffer_info *info = epbh->info;
+	int i;
+
+	for (i = 0; i < EP_BUFFER_SUPPORT_VLAN_MAX; i++) {
+		if (info->v1i.vlan_id[i] == 0) {
+			info->v1i.vlan_id[i] = vlan_id;
+			return true;
+		}
+	}
+	return false;
+}
+
+void fjes_hw_del_vlan_id(struct epbuf_handler *epbh, u16 vlan_id)
+{
+	union ep_buffer_info *info = epbh->info;
+	int i;
+
+	if (0 != vlan_id) {
+		for (i = 0; i < EP_BUFFER_SUPPORT_VLAN_MAX; i++) {
+			if (vlan_id == info->v1i.vlan_id[i])
+				info->v1i.vlan_id[i] = 0;
+		}
+	}
+}
+
+bool fjes_hw_epbuf_rx_is_empty(struct epbuf_handler *epbh)
+{
+	union ep_buffer_info *info;
+	static bool log_output;
+
+	info = epbh->info;
+
+	if (info->v1i.count_max == 0) {
+		if (false == log_output)
+			log_output = true;
+		return true;
+	}
+	return EP_RING_EMPTY(info->v1i.head, info->v1i.tail,
+			info->v1i.count_max);
+}
+
+void *fjes_hw_epbuf_rx_curpkt_get_addr(struct epbuf_handler *epbh,
+	size_t *psize)
+{
+	union ep_buffer_info *info = epbh->info;
+	struct esmem_frame_t *ring_frame;
+	void *frame;
+
+	ring_frame =
+	    (struct esmem_frame_t *)
+		  &(epbh->ring[EP_RING_INDEX(info->v1i.head, 
+			info->v1i.count_max) *
+			info->v1i.frame_max]);
+
+	*psize = (size_t) ring_frame->frame_size;
+
+	frame = ring_frame->frame_data;
+
+	return frame;
+}
+
+void fjes_hw_epbuf_rx_curpkt_drop(struct epbuf_handler *epbh)
+{
+	union ep_buffer_info *info = epbh->info;
+
+	if (fjes_hw_epbuf_rx_is_empty(epbh))
+		return;
+
+	EP_RING_INDEX_INC(epbh->info->v1i.head, info->v1i.count_max);
+}
+
+int fjes_hw_epbuf_tx_pkt_send(struct epbuf_handler *epbh,
+		void *frame, size_t size)
+{
+	union ep_buffer_info *info = epbh->info;
+	struct esmem_frame_t *ring_frame;
+
+	if (EP_RING_FULL(info->v1i.head, info->v1i.tail, info->v1i.count_max))
+		return -ENOBUFS;
+
+	ring_frame =
+	    (struct esmem_frame_t *)&(epbh->
+				      ring[EP_RING_INDEX
+					   (info->v1i.tail - 1,
+					    info->v1i.count_max) *
+					   info->v1i.frame_max]);
+
+	ring_frame->frame_size = size;
+	memcpy((void *)(ring_frame->frame_data), (void *)frame, size);
+
+	EP_RING_INDEX_INC(epbh->info->v1i.tail, info->v1i.count_max);
+
+	return 0;
+}
+
+static void fjes_hw_update_zone_task(struct work_struct *work)
+{
+
+	struct fjes_hw *hw = container_of(work,
+			struct fjes_hw, update_zone_task);
+	struct fjes_adapter *adapter = (struct fjes_adapter *)hw->back;
+	struct net_device *netdev = adapter->netdev;
+	int ret;
+	int epidx;
+	enum ep_partner_status pstatus;
+	unsigned long share_bit = 0;
+	unsigned long unshare_bit = 0;
+	unsigned long irq_bit = 0;
+	bool update = false;
+	union fjes_device_command_res *res_buf =
+			hw->hw_info.res_buf;
+
+	mutex_lock(&hw->hw_info.lock);
+
+	ret = fjes_hw_request_info(hw);
+	switch (ret) {
+	case -ENOMSG:
+	case -EBUSY:
+	default:
+		if (!work_pending(&adapter->force_close_task)) {
+			adapter->force_reset = true;
+			schedule_work(&adapter->force_close_task);
+		}
+		break;
+
+	case 0:
+
+		for (epidx = 0; epidx < hw->max_epid; epidx++) {
+			if (epidx != hw->my_epid) {
+
+				pstatus = fjes_hw_get_partner_ep_status(hw, epidx);
+				switch (pstatus) {
+				case EP_PARTNER_UNSHARE:
+				default:
+					if ((res_buf->info.info[epidx].zone !=
+						FJES_ZONING_ZONE_TYPE_NONE) &&
+					    (res_buf->info.info[epidx].es_status ==
+						FJES_ZONING_STATUS_ENABLE) &&
+					    (res_buf->info.info[epidx].zone ==
+						res_buf->info.info[hw->my_epid].zone))
+						set_bit(epidx, &share_bit);
+					else
+						set_bit(epidx, &unshare_bit);
+					break;
+
+				case EP_PARTNER_COMPLETE:
+				case EP_PARTNER_WAITING:
+					if ((res_buf->info.info[epidx].zone ==
+						FJES_ZONING_ZONE_TYPE_NONE) ||
+					    (res_buf->info.info[epidx].es_status !=
+						FJES_ZONING_STATUS_ENABLE) ||
+					    (res_buf->info.info[epidx].zone !=
+						res_buf->info.
+						  info[hw->my_epid].zone)) {
+
+						set_bit(epidx, 
+						  &adapter->unshare_watch_bitmask);
+						set_bit(epidx,
+						  &hw->hw_info.buffer_unshare_reserve_bit);
+					}
+					break;
+
+				case EP_PARTNER_SHARED:
+					if ((res_buf->info.info[epidx].zone ==
+						FJES_ZONING_ZONE_TYPE_NONE) ||
+					    (res_buf->info.info[epidx].es_status !=
+						FJES_ZONING_STATUS_ENABLE) ||
+					    (res_buf->info.info[epidx].zone !=
+						res_buf->info.
+						  info[hw->my_epid].zone))
+
+						set_bit(epidx, &irq_bit);
+					break;
+				}
+
+			}
+
+			if (hw->ep_shm_info[epidx].zone !=
+						res_buf->info.info[epidx].zone)
+				update = true;
+			hw->ep_shm_info[epidx].es_status =
+				res_buf->info.info[epidx].es_status;
+			hw->ep_shm_info[epidx].zone =
+				res_buf->info.info[epidx].zone;
+
+		}
+		break;
+	}
+
+	mutex_unlock(&hw->hw_info.lock);
+
+	for (epidx = 0; epidx < hw->max_epid; epidx++) {
+
+		if (epidx == hw->my_epid)
+			continue;
+
+		if (test_bit(epidx, &share_bit)) {
+
+			fjes_hw_setup_epbuf(&hw->ep_shm_info[epidx].tx,
+				netdev->dev_addr, netdev->mtu);
+
+			mutex_lock(&hw->hw_info.lock);
+
+			ret = fjes_hw_register_buff_addr(hw, epidx,
+				&hw->ep_shm_info[epidx]);
+
+			switch (ret) {
+			case 0:
+				break;
+			case -ENOMSG:
+			case -EBUSY:
+			default:
+				if (!work_pending(&adapter->force_close_task)) {
+					adapter->force_reset = true;
+					schedule_work(
+					  &adapter->force_close_task);
+				}
+				break;
+			}
+
+			mutex_unlock(&hw->hw_info.lock);
+		}
+
+
+		if (test_bit(epidx, &unshare_bit)) {
+
+			mutex_lock(&hw->hw_info.lock);
+
+			ret = fjes_hw_unregister_buff_addr(hw, epidx);
+
+			switch (ret) {
+			case 0:
+				break;
+			case -ENOMSG:
+			case -EBUSY:
+			default:
+				if (!work_pending(&adapter->force_close_task)) {
+					adapter->force_reset = true;
+					schedule_work(
+					  &adapter->force_close_task);
+				}
+				break;
+			}
+
+			mutex_unlock(&hw->hw_info.lock);
+
+			if (ret == 0)
+				fjes_hw_setup_epbuf(&hw->ep_shm_info[epidx].tx,
+					netdev->dev_addr, netdev->mtu);
+
+		}
+
+		if (test_bit(epidx, &irq_bit)) {
+			fjes_hw_raise_interrupt(hw, epidx,
+				REG_ICTL_MASK_TXRX_STOP_REQ);
+
+			set_bit(epidx, &hw->txrx_stop_req_bit);
+			hw->ep_shm_info[epidx].tx.
+				info->v1i.rx_status |=
+					FJES_RX_STOP_REQ_REQUEST;
+			set_bit(epidx, &hw->hw_info.buffer_unshare_reserve_bit);
+		}
+
+	}
+
+	if (irq_bit || adapter->unshare_watch_bitmask) {
+		if (!work_pending(&adapter->unshare_watch_task))
+			queue_work(adapter->control_wq,
+				&adapter->unshare_watch_task);
+	}
+}
+
+static void fjes_hw_epstop_task(struct work_struct *work)
+{
+	struct fjes_hw *hw = container_of(work,
+			struct fjes_hw, update_zone_task);
+	struct fjes_adapter *adapter = (struct fjes_adapter *)hw->back;
+	int epid_bit;
+	unsigned long remain_bit;
+
+	while ((remain_bit = hw->epstop_req_bit)) {
+
+		for (epid_bit = 0; remain_bit; (remain_bit >>= 1),
+			(epid_bit++)) {
+
+			if (remain_bit & 1) {
+
+				hw->ep_shm_info[epid_bit].
+					tx.info->v1i.rx_status |=
+						FJES_RX_STOP_REQ_DONE;
+
+				clear_bit(epid_bit, &hw->epstop_req_bit);
+				set_bit(epid_bit,
+					&adapter->unshare_watch_bitmask);
+
+				if (!work_pending(&adapter->unshare_watch_task))
+					queue_work(adapter->control_wq,
+						&adapter->unshare_watch_task);
+			}
+		}
+	}
+}
diff --git a/drivers/platform/x86/fjes/fjes_hw.h b/drivers/platform/x86/fjes/fjes_hw.h
new file mode 100755
index 0000000..fbd6af4
--- /dev/null
+++ b/drivers/platform/x86/fjes/fjes_hw.h
@@ -0,0 +1,353 @@
+/*
+ *  FUJITSU Extended Socket Network Device driver
+ *  Copyright (c) 2015 FUJITSU LIMITED
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, see <http://www.gnu.org/licenses/>.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ */
+
+#ifndef FJES_HW_H_
+#define FJES_HW_H_
+
+#include <linux/netdevice.h>
+#include <linux/if_vlan.h>
+
+#include "fjes_regs.h"
+
+
+struct fjes_hw;
+
+#define EP_BUFFER_SUPPORT_VLAN_MAX 4
+#define EP_BUFFER_INFO_SIZE 4096
+
+
+/* Frame & MTU */
+struct esmem_frame_t {
+	__le32 frame_size;
+	u8 frame_data[];
+};
+
+#define FJES_MTU_TO_BUFFER_SIZE(mtu) \
+	(ETH_HLEN + VLAN_HLEN + (mtu) + ETH_FCS_LEN)
+#define FJES_MTU_TO_FRAME_SIZE(mtu) \
+	(sizeof(struct esmem_frame_t) + FJES_MTU_TO_BUFFER_SIZE(mtu))
+#define FJES_MTU_DEFINE(size) \
+	((size) - sizeof(struct esmem_frame_t) - \
+	(ETH_HLEN + VLAN_HLEN + ETH_FCS_LEN))
+
+enum ep_partner_status {
+	EP_PARTNER_UNSHARE,
+	EP_PARTNER_SHARED,
+	EP_PARTNER_WAITING,
+	EP_PARTNER_COMPLETE,
+	EP_PARTNER_STATUS_MAX,
+};
+
+
+#define FJES_DEVICE_RESET_TIMEOUT  ((17 + 1) * 3) /* sec */
+#define FJES_COMMAND_REQ_TIMEOUT  (5 + 1) /* sec */
+#define FJES_COMMAND_REQ_BUFF_TIMEOUT	(8 * 3) /* sec */
+#define FJES_COMMAND_EPSTOP_WAIT_TIMEOUT	(1) /* sec */
+
+
+/* shared status region */
+struct fjes_device_shared_info {
+	int epnum;
+	u8 ep_status[];
+};
+
+/* structures for command control request data*/
+
+union fjes_device_command_req {
+	struct {
+		__le32 length;
+	} info;
+	struct {
+		__le32 length;
+		__le32 epid;
+		__le64 buffer[];
+	} share_buffer;
+	struct {
+		__le32 length;
+		__le32 epid;
+	} unshare_buffer;
+	struct {
+		__le32 length;
+		__le32 mode;
+		__le64 buffer_len;
+		__le64 buffer[];
+	} start_trace;
+	struct {
+		__le32 length;
+	} stop_trace;
+};
+#define FJES_DEV_COMMAND_INFO_REQ_LEN	(4)
+#define FJES_DEV_COMMAND_SHARE_BUFFER_REQ_LEN(txb, rxb) \
+	(24 + (8 * ((txb)/EP_BUFFER_INFO_SIZE + (rxb)/EP_BUFFER_INFO_SIZE)))
+#define FJES_DEV_COMMAND_UNSHARE_BUFFER_REQ_LEN	(8)
+
+#define FJES_DEV_REQ_BUF_SIZE(maxep) \
+	FJES_DEV_COMMAND_SHARE_BUFFER_REQ_LEN(EP_BUFFER_SIZE, EP_BUFFER_SIZE)
+
+
+/* structures for command control response data */
+union fjes_device_command_res {
+	struct {
+		__le32 length;
+		__le32 code;
+		struct {
+			u8 es_status;
+			u8 zone;
+		} info[];
+	} info;
+	struct {
+		__le32 length;
+		__le32 code;
+	} share_buffer;
+	struct {
+		__le32 length;
+		__le32 code;
+	} unshare_buffer;
+	struct {
+		__le32 length;
+		__le32 code;
+	} start_trace;
+	struct {
+		__le32 length;
+		__le32 code;
+	} stop_trace;
+};
+
+#define FJES_DEV_COMMAND_INFO_RES_LEN(epnum) (8 + 2*(epnum))
+#define FJES_DEV_COMMAND_SHARE_BUFFER_RES_LEN	(8)
+#define FJES_DEV_COMMAND_UNSHARE_BUFFER_RES_LEN	(8)
+#define FJES_DEV_RES_BUF_SIZE(maxep) \
+		FJES_DEV_COMMAND_INFO_RES_LEN(maxep)
+
+
+
+/* request command type */
+enum fjes_dev_command_request_type {
+	FJES_CMD_REQ_INFO			= 0x0001,
+	FJES_CMD_REQ_SHARE_BUFFER	= 0x0002,
+	FJES_CMD_REQ_UNSHARE_BUFFER = 0x0004,
+};
+
+
+/* parameter for command control */
+struct fjes_device_command_param {
+	u32 req_len;
+	phys_addr_t req_start;
+	u32 res_len;
+	phys_addr_t res_start;
+	phys_addr_t share_start;
+};
+
+/* error code for command control */
+enum fjes_dev_command_response_e {
+	FJES_CMD_STATUS_UNKNOWN,
+	FJES_CMD_STATUS_NORMAL,
+	FJES_CMD_STATUS_TIMEOUT,
+	FJES_CMD_STATUS_ERROR_PARAM,
+	FJES_CMD_STATUS_ERROR_STATUS,
+};
+
+#define FJES_CMD_REQ_ERR_INFO_PARAM  (0x0001)
+#define FJES_CMD_REQ_ERR_INFO_STATUS (0x0002)
+
+#define FJES_CMD_REQ_RES_CODE_NORMAL (0)
+#define FJES_CMD_REQ_RES_CODE_BUSY   (1)
+
+#define FJES_ZONING_STATUS_DISABLE	(0x00)
+#define FJES_ZONING_STATUS_ENABLE	(0x01)
+#define FJES_ZONING_STATUS_INVALID	(0xFF)
+
+#define FJES_ZONING_ZONE_TYPE_NONE (0xFF)
+
+#define FJES_TX_DELAY_SEND_NONE		(0)
+#define FJES_TX_DELAY_SEND_PENDING	(1)
+
+#define FJES_RX_STOP_REQ_NONE		(0x0)
+#define FJES_RX_STOP_REQ_DONE		(0x1)
+#define FJES_RX_STOP_REQ_REQUEST	(0x2)
+#define FJES_RX_POLL_WORK			(0x4)
+
+
+struct es_device_trace {
+	u32 record_num;
+	u32 current_record;
+	u32 status_flag;
+	u32 _rsv;
+
+	struct {
+			u16 epid;
+			u16 dir_offset;
+			u32 data;
+			u64 tsc;
+	} record[];
+};
+
+
+
+
+union ep_buffer_info {
+	u8 raw[EP_BUFFER_INFO_SIZE];
+
+	struct _ep_buffer_info_common_t {
+		u32 version;
+	} common;
+
+	struct _ep_buffer_info_v1_t {
+		u32 version;
+		u32 info_size;
+
+		u32 buffer_size;
+		u16 count_max;
+
+		u16 _rsv_1;
+
+		u32 frame_max;
+		u8 mac_addr[ETH_ALEN];
+
+		u16 _rsv_2;
+		u32 _rsv_3;
+
+		u16 tx_status;
+		u16 rx_status;
+
+		u32 head;
+		u32 tail;
+
+		u16 vlan_id[EP_BUFFER_SUPPORT_VLAN_MAX];
+
+	} v1i;
+
+};
+
+#define EP_BUFFER_SIZE \
+	(((sizeof(union ep_buffer_info) + (128 * (64 * 1024))) \
+		/ EP_BUFFER_INFO_SIZE) * EP_BUFFER_INFO_SIZE)
+
+#define EP_RING_NUM(buffer_size, frame_size) \
+		(u32)((buffer_size) / (frame_size))
+
+#define EP_RING_INDEX(_num, _max) (((_num) + (_max)) % (_max))
+#define EP_RING_FULL(_head, _tail, _max) \
+	(0 == EP_RING_INDEX(((_tail) - (_head)), (_max)))
+#define EP_RING_EMPTY(_head, _tail, _max) \
+	(1 == EP_RING_INDEX(((_tail) - (_head)), (_max)))
+#define EP_RING_INDEX_INC(_num, _max) do { \
+		(_num) = EP_RING_INDEX((_num) + 1, (_max)); \
+	} while (0)
+
+/* buffer pair for Extended Partition */
+struct ep_share_mem_info {
+	struct epbuf_handler {
+		void *buffer;
+		size_t size;
+		union ep_buffer_info *info;
+		u8 *ring;
+	} tx, rx;
+
+	struct rtnl_link_stats64 net_stats;
+
+	u16 tx_status_work;
+
+	u8 es_status;
+	u8 zone;
+};
+
+
+struct fjes_hw_info {
+	struct fjes_device_shared_info *share;
+	union fjes_device_command_req *req_buf;
+	u64 req_buf_size;
+	union fjes_device_command_res *res_buf;
+	u64 res_buf_size;
+
+	int *my_epid;
+	int *max_epid;
+
+	struct es_device_trace *trace;
+	u64 trace_size;
+
+	struct mutex lock;
+
+	unsigned long buffer_share_bit;
+	unsigned long buffer_unshare_reserve_bit;
+};
+
+
+struct fjes_hw {
+
+	void *back;
+
+	unsigned long txrx_stop_req_bit;
+	unsigned long epstop_req_bit;
+	struct work_struct update_zone_task;
+	struct work_struct epstop_task;
+
+	int my_epid;
+	int max_epid;
+
+	struct ep_share_mem_info *ep_shm_info;
+
+	struct fjes_hw_resource {
+		u64 start;
+		u64 size;
+		int irq;
+	} hw_res;
+
+
+	u8 *base;
+
+	struct fjes_hw_info hw_info;
+};
+
+
+int fjes_hw_init(struct fjes_hw *);
+void fjes_hw_exit(struct fjes_hw *);
+int fjes_hw_reset(struct fjes_hw *);
+int fjes_hw_request_info(struct fjes_hw *);
+int fjes_hw_register_buff_addr(struct fjes_hw *, int,
+		struct ep_share_mem_info *);
+int fjes_hw_unregister_buff_addr(struct fjes_hw *, int);
+void fjes_hw_init_command_registers(struct fjes_hw *,
+		struct fjes_device_command_param *);
+void fjes_hw_setup_epbuf(struct epbuf_handler *, u8 *, u32);
+int fjes_hw_raise_interrupt(struct fjes_hw *, int, enum REG_ICTL_MASK);
+void fjes_hw_set_irqmask(struct fjes_hw *, enum REG_ICTL_MASK, bool);
+u32 fjes_hw_capture_interrupt_status(struct fjes_hw *);
+void fjes_hw_raise_epstop(struct fjes_hw *);
+int fjes_hw_wait_epstop(struct fjes_hw *);
+enum ep_partner_status
+	fjes_hw_get_partner_ep_status(struct fjes_hw *, int);
+
+bool fjes_hw_epid_is_same_zone(struct fjes_hw *, int);
+int fjes_hw_epid_is_shared(struct fjes_device_shared_info *, int);
+bool fjes_hw_check_epbuf_version(struct epbuf_handler *, u32);
+bool fjes_hw_check_mtu(struct epbuf_handler *, u32);
+bool fjes_hw_check_vlan_id(struct epbuf_handler *, u16);
+bool fjes_hw_set_vlan_id(struct epbuf_handler *, u16);
+void fjes_hw_del_vlan_id(struct epbuf_handler *, u16);
+bool fjes_hw_epbuf_rx_is_empty(struct epbuf_handler *);
+void *fjes_hw_epbuf_rx_curpkt_get_addr(struct epbuf_handler *,
+		size_t *);
+void fjes_hw_epbuf_rx_curpkt_drop(struct epbuf_handler *);
+
+int fjes_hw_epbuf_tx_pkt_send(struct epbuf_handler *, void *, size_t);
+
+#endif /* FJES_HW_H_ */
diff --git a/drivers/platform/x86/fjes/fjes_main.c b/drivers/platform/x86/fjes/fjes_main.c
new file mode 100755
index 0000000..1583a22
--- /dev/null
+++ b/drivers/platform/x86/fjes/fjes_main.c
@@ -0,0 +1,1525 @@
+/*
+ *  FUJITSU Extended Socket Network Device driver
+ *  Copyright (c) 2015 FUJITSU LIMITED
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, see <http://www.gnu.org/licenses/>.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ */
+
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/platform_device.h>
+#include <linux/netdevice.h>
+#include <linux/nls.h>
+#include <linux/interrupt.h>
+
+#include "fjes.h"
+
+#define MAJ 1
+#define MIN 0
+#define DRV_VERSION __stringify(MAJ) "." __stringify(MIN)
+#define DRV_NAME	"fjes"
+char fjes_driver_name[] = DRV_NAME;
+char fjes_driver_version[] = DRV_VERSION;
+static const char fjes_driver_string[] =
+		"FUJITSU Extended Socket Network Device Driver";
+static const char fjes_copyright[] =
+		"Copyright (c) 2015 FUJITSU LIMITED";
+
+
+MODULE_AUTHOR("Taku Izumi <izumi.taku@jp.fujitsu.com>");
+MODULE_DESCRIPTION("FUJITSU Extended Socket Network Device Driver");
+MODULE_LICENSE("GPL");
+MODULE_VERSION(DRV_VERSION);
+
+
+static int fjes_request_irq(struct fjes_adapter *);
+static void fjes_free_irq(struct fjes_adapter *);
+
+static int fjes_open(struct net_device *);
+static int fjes_close(struct net_device *);
+static int fjes_setup_resources(struct fjes_adapter *);
+static void fjes_free_resources(struct fjes_adapter *);
+static netdev_tx_t fjes_xmit_frame(struct sk_buff *,
+		struct net_device *);
+static void fjes_tx_retry(struct net_device *);
+static struct rtnl_link_stats64
+*fjes_get_stats64(struct net_device *, struct rtnl_link_stats64 *);
+static int fjes_change_mtu(struct net_device *, int);
+static int fjes_vlan_rx_add_vid(struct net_device *, __be16 proto, u16);
+static int fjes_vlan_rx_kill_vid(struct net_device *, __be16 proto, u16);
+static irqreturn_t fjes_intr(int, void*);
+
+static int fjes_acpi_add(struct acpi_device *);
+static int fjes_acpi_remove(struct acpi_device *);
+static acpi_status fjes_get_acpi_resource(struct acpi_resource *, void*);
+
+static int fjes_probe(struct platform_device *);
+static int fjes_remove(struct platform_device *);
+
+static int fjes_sw_init(struct fjes_adapter *);
+static void fjes_force_close_task(struct work_struct *);
+static void fjes_tx_stall_task(struct work_struct *);
+static void fjes_raise_intr_rxdata_task(struct work_struct *);
+static void fjes_watch_unsahre_task(struct work_struct *);
+static void fjes_irq_watch_task(struct work_struct *);
+static void fjes_netdev_setup(struct net_device *);
+
+static void fjes_rx_irq(struct fjes_adapter *, int);
+static int fjes_poll(struct napi_struct *, int);
+
+
+static const struct acpi_device_id fjes_acpi_ids[] = {
+	{"PNP0C02", 0},
+	{"", 0},
+};
+MODULE_DEVICE_TABLE(acpi, fjes_acpi_ids);
+
+static struct acpi_driver fjes_acpi_driver = {
+	.name = DRV_NAME,
+	.class = DRV_NAME,
+	.owner = THIS_MODULE,
+	.ids = fjes_acpi_ids,
+	.ops = {
+		.add = fjes_acpi_add,
+		.remove = fjes_acpi_remove,
+	},
+};
+
+static struct platform_driver fjes_driver = {
+	.driver = {
+		.name = DRV_NAME,
+		.owner = THIS_MODULE,
+	},
+	.probe = fjes_probe,
+	.remove = fjes_remove,
+};
+
+static struct resource fjes_resource[] = {
+	{
+		.flags = IORESOURCE_MEM,
+		.start = 0,
+		.end = 0,
+	},
+	{
+		.flags = IORESOURCE_IRQ,
+		.start = 0,
+		.end = 0,
+	},
+};
+
+
+u32 fjes_support_mtu[] = {
+	FJES_MTU_DEFINE(8 * 1024),
+	FJES_MTU_DEFINE(16 * 1024),
+	FJES_MTU_DEFINE(32 * 1024),
+	FJES_MTU_DEFINE(64 * 1024),
+	0
+};
+
+/*
+ *  fjes_init_module - Driver Registration Routine
+ *
+ *  fjes_init_module is the first routine called when the driver is
+ *  loaded.
+ */
+static int __init fjes_init_module(void)
+{
+	int result;
+
+	pr_info("%s - version %s\n",
+			fjes_driver_string, fjes_driver_version);
+	pr_info("%s\n", fjes_copyright);
+
+	result = platform_driver_register(&fjes_driver);
+	if (result < 0)
+		return result;
+
+	result = acpi_bus_register_driver(&fjes_acpi_driver);
+	if (result < 0)
+		goto fail_acpi_driver;
+
+	return 0;
+
+fail_acpi_driver:
+	platform_driver_unregister(&fjes_driver);
+	return result;
+}
+
+module_init(fjes_init_module);
+
+
+/*
+ *  fjes_exit_module - Driver Exit Cleanup Routine
+ *
+ *  fjes_exit_module is called just before the driver is removed from memory.
+ */
+static void __exit fjes_exit_module(void)
+{
+	acpi_bus_unregister_driver(&fjes_acpi_driver);
+	platform_driver_unregister(&fjes_driver);
+}
+
+module_exit(fjes_exit_module);
+
+
+u32 fjes_rd32(struct fjes_hw *hw, u32 reg)
+{
+	u8 *base = hw->base;
+	u32 value = 0;
+
+	value = readl(&base[reg]);
+
+	return value;
+}
+
+
+static int fjes_request_irq(struct fjes_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+	int result = -1;
+
+	adapter->interrupt_watch_enable = true;
+	if (!delayed_work_pending(&adapter->interrupt_watch_task)) {
+		queue_delayed_work(adapter->control_wq,
+				&adapter->interrupt_watch_task,
+				FJES_IRQ_WATCH_DELAY);
+	}
+
+	if (!adapter->irq_registered) {
+		result = request_irq(adapter->hw.hw_res.irq, fjes_intr,
+					IRQF_SHARED, netdev->name, adapter);
+		if (result)
+			adapter->irq_registered = false;
+		else
+			adapter->irq_registered = true;
+	}
+
+	return result;
+}
+
+
+static void fjes_free_irq(struct fjes_adapter *adapter)
+{
+	struct fjes_hw *hw = &adapter->hw;
+
+	adapter->interrupt_watch_enable = false;
+	cancel_delayed_work_sync(&adapter->interrupt_watch_task);
+
+	fjes_hw_set_irqmask(hw, REG_ICTL_MASK_ALL, true);
+
+	if (adapter->irq_registered) {
+		free_irq(adapter->hw.hw_res.irq, adapter);
+		adapter->irq_registered = false;
+	}
+}
+
+
+
+static const struct net_device_ops fjes_netdev_ops = {
+	.ndo_open		= fjes_open,
+	.ndo_stop		= fjes_close,
+	.ndo_start_xmit		= fjes_xmit_frame,
+	.ndo_get_stats64	= fjes_get_stats64,
+	.ndo_change_mtu		= fjes_change_mtu,
+	.ndo_tx_timeout		= fjes_tx_retry,
+	.ndo_vlan_rx_add_vid	= fjes_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid = fjes_vlan_rx_kill_vid,
+};
+
+
+/*
+ *  fjes_open - Called when a network interface is made active
+ */
+static int fjes_open(struct net_device *netdev)
+{
+	int result;
+	struct fjes_adapter *adapter = netdev_priv(netdev);
+	struct fjes_hw *hw = &adapter->hw;
+
+	if (adapter->open_guard)
+		return -ENXIO;
+
+	result = fjes_setup_resources(adapter);
+	if (result)
+		goto err_setup_res;
+
+	hw->txrx_stop_req_bit = 0;
+	hw->epstop_req_bit = 0;
+
+	napi_enable(&adapter->napi);
+
+	fjes_hw_capture_interrupt_status(hw);
+
+	result = fjes_request_irq(adapter);
+	if (result)
+		goto err_req_irq;
+
+	fjes_hw_set_irqmask(hw, REG_ICTL_MASK_ALL, false);
+
+	netif_tx_start_all_queues(netdev);
+	netif_carrier_on(netdev);
+
+	return 0;
+
+err_req_irq:
+	fjes_free_irq(adapter);
+	napi_disable(&adapter->napi);
+
+err_setup_res:
+	fjes_free_resources(adapter);
+	return result;
+
+}
+
+/*
+ *  fjes_close - Disables a network interface
+ */
+static int fjes_close(struct net_device *netdev)
+{
+	struct fjes_adapter *adapter = netdev_priv(netdev);
+	struct fjes_hw *hw = &adapter->hw;
+	int epidx;
+
+	netif_tx_stop_all_queues(netdev);
+	netif_carrier_off(netdev);
+
+	fjes_hw_raise_epstop(hw);
+
+	napi_disable(&adapter->napi);
+
+	for (epidx = 0; epidx < hw->max_epid; epidx++) {
+		if (epidx == hw->my_epid)
+			continue;
+
+		adapter->hw.ep_shm_info[epidx].tx.info->v1i.rx_status &=
+			~FJES_RX_POLL_WORK;
+	}
+
+	fjes_free_irq(adapter);
+
+	cancel_work_sync(&adapter->tx_stall_task);
+	cancel_work_sync(&adapter->raise_intr_rxdata_task);
+	cancel_work_sync(&adapter->unshare_watch_task);
+	adapter->unshare_watch_bitmask = 0;
+
+	cancel_work_sync(&hw->update_zone_task);
+	cancel_work_sync(&hw->epstop_task);
+
+	fjes_hw_wait_epstop(hw);
+
+	fjes_free_resources(adapter);
+
+	return 0;
+}
+
+
+static int fjes_setup_resources(struct fjes_adapter *adapter)
+{
+	int epidx;
+	struct ep_share_mem_info *buf_pair;
+	int result;
+	struct fjes_hw *hw = &adapter->hw;
+	struct net_device *netdev = adapter->netdev;
+
+
+	mutex_lock(&hw->hw_info.lock);
+	result = fjes_hw_request_info(hw);
+	switch (result) {
+	case 0:
+		for (epidx = 0; epidx < hw->max_epid; epidx++) {
+			hw->ep_shm_info[epidx].es_status =
+			    hw->hw_info.res_buf->info.info[epidx].es_status;
+			hw->ep_shm_info[epidx].zone =
+			    hw->hw_info.res_buf->info.info[epidx].zone;
+		}
+		break;
+	default:
+	case -ENOMSG:
+	case -EBUSY:
+		adapter->force_reset = true;
+
+		mutex_unlock(&hw->hw_info.lock);
+		return result;
+	}
+	mutex_unlock(&hw->hw_info.lock);
+
+
+	for (epidx = 0; epidx < (hw->max_epid); epidx++) {
+		if ((epidx != hw->my_epid) &&
+			(hw->ep_shm_info[epidx].es_status ==
+				FJES_ZONING_STATUS_ENABLE)) {
+			fjes_hw_raise_interrupt(hw, epidx,
+					REG_ICTL_MASK_INFO_UPDATE);
+		}
+	}
+
+	msleep(FJES_OPEN_ZONE_UPDATE_WAIT * hw->max_epid);
+
+
+	for (epidx = 0; epidx < (hw->max_epid); epidx++) {
+		if (epidx == hw->my_epid)
+			continue;
+
+		buf_pair = &(hw->ep_shm_info[epidx]);
+
+		fjes_hw_setup_epbuf(&(buf_pair->tx), netdev->dev_addr,
+				netdev->mtu);
+
+		if (fjes_hw_epid_is_same_zone(hw, epidx)) {
+			mutex_lock(&hw->hw_info.lock);
+			result = fjes_hw_register_buff_addr(hw, epidx,
+					buf_pair);
+			mutex_unlock(&hw->hw_info.lock);
+
+			switch (result) {
+			case 0:
+				break;
+			case -ENOMSG:
+			case -EBUSY:
+			default:
+				adapter->force_reset = true;
+				return result;
+			}
+		}
+	}
+
+	return 0;
+}
+
+static void fjes_free_resources(struct fjes_adapter *adapter)
+{
+	int epidx;
+	struct ep_share_mem_info *buf_pair;
+	int result;
+	struct fjes_hw *hw = &adapter->hw;
+	struct net_device *netdev = adapter->netdev;
+	struct fjes_device_command_param param;
+	bool reset_flag = false;
+
+	for (epidx = 0; epidx < hw->max_epid; epidx++) {
+		if (epidx == hw->my_epid)
+			continue;
+
+		mutex_lock(&hw->hw_info.lock);
+		result = fjes_hw_unregister_buff_addr(hw, epidx);
+		mutex_unlock(&hw->hw_info.lock);
+
+		if (result)
+			reset_flag = true;
+
+		buf_pair = &hw->ep_shm_info[epidx];
+
+		fjes_hw_setup_epbuf(&buf_pair->tx, netdev->dev_addr,
+				netdev->mtu);
+
+		clear_bit(epidx, &hw->txrx_stop_req_bit);
+	}
+
+	if (reset_flag || adapter->force_reset) {
+
+		result = fjes_hw_reset(hw);
+
+		adapter->force_reset = false;
+
+		if (result)
+			adapter->open_guard = true;
+
+		hw->hw_info.buffer_share_bit = 0;
+
+		memset((void *)&param, 0, sizeof(param));
+
+		param.req_len = hw->hw_info.req_buf_size;
+		param.req_start = __pa(hw->hw_info.req_buf);
+		param.res_len = hw->hw_info.res_buf_size;
+		param.res_start = __pa(hw->hw_info.res_buf);
+		param.share_start = __pa(hw->hw_info.share->ep_status);
+
+		fjes_hw_init_command_registers(hw, &param);
+	}
+
+
+}
+
+
+static int fjes_tx_send(struct fjes_adapter *adapter, int dest,
+				void *data, size_t len)
+{
+	int retval;
+
+	retval = fjes_hw_epbuf_tx_pkt_send(
+		&(adapter->hw.ep_shm_info[dest].tx), data, len);
+	if (retval)
+		return retval;
+
+	adapter->hw.ep_shm_info[dest].tx.info->v1i.tx_status =
+		FJES_TX_DELAY_SEND_PENDING;
+	if (!work_pending(&adapter->raise_intr_rxdata_task))
+		queue_work(adapter->txrx_wq, &adapter->raise_intr_rxdata_task);
+
+	retval = 0;
+	return retval;
+}
+
+static netdev_tx_t fjes_xmit_frame(struct sk_buff *skb,
+		struct net_device *netdev)
+{
+	struct fjes_adapter *adapter = netdev_priv(netdev);
+	struct fjes_hw *hw = &adapter->hw;
+	enum ep_partner_status pstatus;
+
+	int len;
+	char *data, shortpkt[VLAN_ETH_HLEN];
+
+	u16 queue_no = 0;
+	struct netdev_queue *cur_queue = netdev_get_tx_queue(netdev, queue_no);
+	netdev_tx_t ret = NETDEV_TX_OK;
+	struct ethhdr *eth;
+	int dest_epid;
+
+	int max_epid, my_epid;
+	u16 vlan_id = 0;
+	bool vlan = false;
+	bool is_multi = false;
+	bool rv = false;
+
+	eth = (struct ethhdr *)skb->data;
+	my_epid = hw->my_epid;
+
+	vlan = (vlan_get_tag(skb, &vlan_id) == 0) ? true : false;
+
+	data = skb->data;
+	len = skb->len;
+
+	if (is_multicast_ether_addr(eth->h_dest)) {
+		dest_epid = 0;
+		max_epid = hw->max_epid;
+		is_multi = true;
+	} else if (is_local_ether_addr(eth->h_dest)) {
+
+		dest_epid = eth->h_dest[ETH_ALEN - 1];
+		max_epid = dest_epid + 1;
+
+		if ((eth->h_dest[0] == 0x02) &&
+			(0x00 == (eth->h_dest[1] | eth->h_dest[2] |
+				eth->h_dest[3] | eth->h_dest[4])) &&
+			(dest_epid < hw->max_epid)) {
+			;
+		} else {
+
+			dest_epid = 0;
+			max_epid = 0;
+			ret = NETDEV_TX_OK;
+
+			adapter->stats64.tx_packets += 1;
+			hw->ep_shm_info[my_epid].net_stats.tx_packets += 1;
+			adapter->stats64.tx_bytes += len;
+			hw->ep_shm_info[my_epid].net_stats.tx_bytes += len;
+
+		}
+	} else {
+
+		dest_epid = 0;
+		max_epid = 0;
+		ret = NETDEV_TX_OK;
+
+		adapter->stats64.tx_packets += 1;
+		hw->ep_shm_info[my_epid].net_stats.tx_packets += 1;
+		adapter->stats64.tx_bytes += len;
+		hw->ep_shm_info[my_epid].net_stats.tx_bytes += len;
+
+	}
+
+	for (; dest_epid < max_epid; dest_epid++) {
+
+		if (my_epid == dest_epid)
+			continue;
+
+		pstatus = fjes_hw_get_partner_ep_status(hw, dest_epid);
+		if (pstatus != EP_PARTNER_SHARED)
+			ret = NETDEV_TX_OK;
+		else
+			/* check if version is 0 */
+			rv = fjes_hw_check_epbuf_version(
+				&(adapter->hw.ep_shm_info[dest_epid].rx), 0);
+			if (!rv) {
+				adapter->stats64.tx_carrier_errors += 1;
+				hw->ep_shm_info[my_epid].net_stats.
+					tx_carrier_errors += 1;
+
+				ret = NETDEV_TX_OK;
+			} else
+				rv = fjes_hw_check_mtu(
+						  &(adapter->hw.ep_shm_info[dest_epid].rx),
+						  netdev->mtu);
+				if (!rv) {
+					adapter->stats64.tx_dropped += 1;
+					hw->ep_shm_info[my_epid].net_stats.
+						tx_dropped += 1;
+					adapter->stats64.tx_errors += 1;
+					hw->ep_shm_info[my_epid].net_stats.
+						tx_errors += 1;
+
+					ret = NETDEV_TX_OK;
+				} else if ((vlan == true) &&
+					!fjes_hw_check_vlan_id(
+						&(adapter->hw.ep_shm_info[dest_epid].rx),
+						vlan_id)) {
+
+					ret = NETDEV_TX_OK;
+				} else {
+
+					if (len < VLAN_ETH_HLEN) {
+						memset(shortpkt, 0, VLAN_ETH_HLEN);
+						memcpy(shortpkt, skb->data, skb->len);
+						len = VLAN_ETH_HLEN;
+						data = shortpkt;
+					}
+
+					if (adapter->tx_retry_count == 0) {
+						adapter->tx_start_jiffies = jiffies;
+						adapter->tx_retry_count = 1;
+					} else {
+						adapter->tx_retry_count++;
+					}
+
+					if (fjes_tx_send(adapter, dest_epid, data, len)) {
+
+						if (is_multi) {
+							ret = NETDEV_TX_OK;
+						} else if (((long)jiffies - (long)adapter->tx_start_jiffies) >= FJES_TX_RETRY_TIMEOUT) {
+
+
+							adapter->stats64.tx_fifo_errors += 1;
+							hw->ep_shm_info[my_epid].net_stats.tx_fifo_errors += 1;
+							adapter->stats64.tx_errors += 1;
+							hw->ep_shm_info[my_epid].net_stats.tx_errors += 1;
+
+
+							ret = NETDEV_TX_OK;
+						} else {
+							netdev->trans_start = jiffies;
+
+							netif_tx_stop_queue(cur_queue);
+
+							if (!work_pending(&adapter->tx_stall_task))
+								queue_work(adapter->txrx_wq, &adapter->tx_stall_task);
+
+							ret = NETDEV_TX_BUSY;
+						}
+					} else {
+
+						if (!is_multi) {
+
+							adapter->stats64.tx_packets += 1;
+							hw->ep_shm_info[my_epid].net_stats.tx_packets += 1;
+							adapter->stats64.tx_bytes += len;
+							hw->ep_shm_info[my_epid].net_stats.tx_bytes += len;
+						}
+
+						adapter->tx_retry_count = 0;
+						ret = NETDEV_TX_OK;
+					}
+				}
+	}
+
+
+	if (ret == NETDEV_TX_OK) {
+		dev_kfree_skb(skb);
+		if (is_multi) {
+			adapter->stats64.tx_packets += 1;
+			hw->ep_shm_info[my_epid].net_stats.tx_packets += 1;
+			adapter->stats64.tx_bytes += 1;
+			hw->ep_shm_info[my_epid].net_stats.tx_bytes += len;
+		}
+	}
+
+	return ret;
+}
+
+static void fjes_tx_retry(struct net_device *netdev)
+{
+	struct netdev_queue *curQueue = netdev_get_tx_queue(netdev, 0);
+
+	netif_tx_wake_queue(curQueue);
+}
+
+
+
+static struct rtnl_link_stats64
+*fjes_get_stats64(struct net_device *netdev,
+		struct rtnl_link_stats64 *stats)
+{
+	struct fjes_adapter *adapter = netdev_priv(netdev);
+
+	memcpy(stats, &adapter->stats64, sizeof(struct rtnl_link_stats64));
+
+	return stats;
+}
+
+
+static int fjes_change_mtu(struct net_device *netdev, int new_mtu)
+{
+	int idx;
+	bool running = netif_running(netdev);
+	int ret = 0;
+
+	for (idx = 0; fjes_support_mtu[idx] != 0; idx++) {
+		if (new_mtu <= fjes_support_mtu[idx]) {
+
+			new_mtu = fjes_support_mtu[idx];
+			if (new_mtu == netdev->mtu)
+				return 0;
+
+			if (running)
+				fjes_close(netdev);
+
+			netdev->mtu = new_mtu;
+
+			if (running)
+				ret = fjes_open(netdev);
+
+			return ret;
+		}
+	}
+
+	return -EINVAL;
+}
+
+
+static int fjes_vlan_rx_add_vid(struct net_device *netdev,
+		__be16 proto, u16 vid)
+{
+	struct fjes_adapter *adapter = netdev_priv(netdev);
+	bool ret = true;
+	int epid;
+
+	for (epid = 0; epid < adapter->hw.max_epid; epid++) {
+		if (epid == adapter->hw.my_epid)
+			continue;
+
+		if (!fjes_hw_check_vlan_id(
+			&(adapter->hw.ep_shm_info[epid].tx), vid))
+			ret = fjes_hw_set_vlan_id(
+				&(adapter->hw.ep_shm_info[epid].tx), vid);
+	}
+
+	return ret ? 0 : -ENOSPC;
+}
+
+static int fjes_vlan_rx_kill_vid(struct net_device *netdev,
+		__be16 proto, u16 vid)
+{
+	struct fjes_adapter *adapter = netdev_priv(netdev);
+	int epid;
+
+	for (epid = 0; epid < adapter->hw.max_epid; epid++) {
+		if (epid == adapter->hw.my_epid)
+			continue;
+
+		fjes_hw_del_vlan_id(&(adapter->hw.ep_shm_info[epid].tx), vid);
+	}
+
+	return 0;
+}
+
+static void fjes_txrx_stop_req_irq(struct fjes_adapter *adapter,
+		int src_epid)
+{
+	struct fjes_hw *hw = &adapter->hw;
+	enum ep_partner_status status;
+
+	status = fjes_hw_get_partner_ep_status(hw, src_epid);
+	switch (status) {
+	case EP_PARTNER_UNSHARE:
+	default:
+		break;
+	case EP_PARTNER_COMPLETE:
+		break;
+	case EP_PARTNER_WAITING:
+		if (src_epid < hw->my_epid) {
+			hw->ep_shm_info[src_epid].tx.info->v1i.rx_status |=
+				FJES_RX_STOP_REQ_DONE;
+
+			clear_bit(src_epid, &hw->txrx_stop_req_bit);
+			set_bit(src_epid, &adapter->unshare_watch_bitmask);
+
+			if (!work_pending(&adapter->unshare_watch_task))
+				queue_work(adapter->control_wq,
+						&adapter->unshare_watch_task);
+		}
+		break;
+	case EP_PARTNER_SHARED:
+		if (hw->ep_shm_info[src_epid].rx.info->v1i.rx_status
+				& FJES_RX_STOP_REQ_REQUEST) {
+
+			set_bit(src_epid, &hw->epstop_req_bit);
+
+			if (!work_pending(&hw->epstop_task))
+				queue_work(adapter->control_wq, &hw->epstop_task);
+
+		}
+		break;
+	}
+}
+
+static void fjes_stop_req_irq(struct fjes_adapter *adapter,
+		int src_epid)
+{
+	struct fjes_hw *hw = &adapter->hw;
+	enum ep_partner_status status;
+
+	set_bit(src_epid, &hw->hw_info.buffer_unshare_reserve_bit);
+
+	status = fjes_hw_get_partner_ep_status(hw, src_epid);
+	switch (status) {
+	case EP_PARTNER_WAITING:
+		hw->ep_shm_info[src_epid].tx.info->v1i.rx_status |=
+				FJES_RX_STOP_REQ_DONE;
+		clear_bit(src_epid, &hw->txrx_stop_req_bit);
+		/* fall through */
+	case EP_PARTNER_UNSHARE:
+	case EP_PARTNER_COMPLETE:
+	default:
+		set_bit(src_epid, &adapter->unshare_watch_bitmask);
+		if (!work_pending(&adapter->unshare_watch_task))
+			queue_work(adapter->control_wq,
+					&adapter->unshare_watch_task);
+
+		break;
+	case EP_PARTNER_SHARED:
+		set_bit(src_epid, &hw->epstop_req_bit);
+
+		if (!work_pending(&hw->epstop_task))
+			queue_work(adapter->control_wq, &hw->epstop_task);
+
+		break;
+	}
+
+}
+
+static void fjes_update_zone_irq(struct fjes_adapter *adapter,
+		int src_epid)
+{
+	struct fjes_hw *hw = &adapter->hw;
+
+	if (!work_pending(&hw->update_zone_task))
+		queue_work(adapter->control_wq, &hw->update_zone_task);
+}
+
+static irqreturn_t fjes_intr(int irq, void *data)
+{
+	struct fjes_adapter *adapter = data;
+	struct fjes_hw *hw = &adapter->hw;
+	irqreturn_t ret;
+	u32 icr;
+
+	icr = fjes_hw_capture_interrupt_status(hw);
+
+	if (icr & REG_IS_MASK_IS_ASSERT) {
+
+		if (icr & REG_ICTL_MASK_RX_DATA)
+			fjes_rx_irq(adapter, icr & REG_IS_MASK_EPID);
+
+		if (icr & REG_ICTL_MASK_TXRX_STOP_REQ)
+			fjes_txrx_stop_req_irq(adapter, icr & REG_IS_MASK_EPID);
+
+		if (icr & REG_ICTL_MASK_TXRX_STOP_DONE)
+			fjes_hw_set_irqmask(hw,
+				REG_ICTL_MASK_TXRX_STOP_DONE, true);
+
+		if (icr & REG_ICTL_MASK_DEV_STOP_REQ)
+			fjes_stop_req_irq(adapter, icr & REG_IS_MASK_EPID);
+
+		if (icr & REG_ICTL_MASK_INFO_UPDATE)
+			fjes_update_zone_irq(adapter, icr & REG_IS_MASK_EPID);
+
+		ret = IRQ_HANDLED;
+	} else
+		ret = IRQ_NONE;
+
+	return ret;
+}
+
+static int fjes_rxframe_search_exist(struct fjes_adapter *adapter, int start_epid)
+{
+	struct fjes_hw *hw = &adapter->hw;
+	int cur_epid;
+	int max_epid;
+	int i;
+	enum ep_partner_status pstatus;
+
+	max_epid = hw->max_epid;
+	start_epid = (start_epid + 1 + max_epid) % max_epid;
+
+	for (i = 0; i < max_epid; i++) {
+		cur_epid = (start_epid + i) % max_epid;
+		if (cur_epid == hw->my_epid)
+			continue;
+
+		pstatus = fjes_hw_get_partner_ep_status(hw, cur_epid);
+		if (pstatus == EP_PARTNER_SHARED) {
+
+			if (!fjes_hw_epbuf_rx_is_empty(&hw->ep_shm_info[cur_epid].rx))
+				return cur_epid;
+
+		}
+
+	}
+	return -1;
+}
+
+static void *fjes_rxframe_get(struct fjes_adapter *adapter, size_t *psize,
+		int *cur_epid)
+{
+	void *frameBuf;
+
+	*cur_epid = fjes_rxframe_search_exist(adapter, *cur_epid);
+	if (*cur_epid < 0)
+		return NULL;
+
+	frameBuf =
+	    fjes_hw_epbuf_rx_curpkt_get_addr(&
+					   (adapter->hw.
+					    ep_shm_info[*cur_epid].rx), psize);
+
+	return frameBuf;
+}
+
+static void fjes_rxframe_release(struct fjes_adapter *adapter,
+		int cur_epid)
+{
+	fjes_hw_epbuf_rx_curpkt_drop(&(adapter->hw.ep_shm_info[cur_epid].rx));
+}
+
+
+static void fjes_rx_irq(struct fjes_adapter *adapter, int src_epid)
+{
+	struct fjes_hw *hw = &adapter->hw;
+
+	fjes_hw_set_irqmask(hw, REG_ICTL_MASK_RX_DATA , true);
+
+	adapter->unset_rx_last = true;
+	napi_schedule(&adapter->napi);
+
+}
+
+static int fjes_poll(struct napi_struct *napi, int budget)
+{
+
+	struct fjes_adapter *adapter =
+			container_of(napi, struct fjes_adapter, napi);
+	struct fjes_hw *hw = &adapter->hw;
+	struct net_device *netdev = napi->dev;
+	int npackets = 0;
+	struct sk_buff *skb;
+	void *frameData;
+	size_t frameLen;
+	int cur_epid = 0;
+	int epidx = 0;
+
+	for (epidx = 0; epidx < hw->max_epid; epidx++) {
+		if (epidx == hw->my_epid)
+			continue;
+
+		adapter->hw.ep_shm_info[epidx].tx.info->v1i.rx_status |=
+			FJES_RX_POLL_WORK;
+	}
+
+	while (npackets < budget) {
+
+		prefetch(&adapter->hw);
+		frameData = fjes_rxframe_get(adapter, &frameLen, &cur_epid);
+
+		if (frameData) {
+			skb = netdev_alloc_skb_ip_align(netdev, frameLen);
+			if (!skb) {
+
+				adapter->stats64.rx_dropped += 1;
+				hw->ep_shm_info[cur_epid].net_stats.rx_dropped += 1;
+				adapter->stats64.rx_errors += 1;
+				hw->ep_shm_info[cur_epid].net_stats.rx_errors += 1;
+
+			} else {
+
+				memcpy(skb_put(skb, frameLen), frameData,
+					frameLen);
+				skb->dev = netdev;
+				skb->protocol = eth_type_trans(skb, netdev);
+				skb->ip_summed = CHECKSUM_UNNECESSARY;	/* don't check it */
+
+				netif_receive_skb(skb);
+
+				npackets++;
+
+				adapter->stats64.rx_packets += 1;
+				hw->ep_shm_info[cur_epid].net_stats.rx_packets += 1;
+				adapter->stats64.rx_bytes += frameLen;
+				hw->ep_shm_info[cur_epid].net_stats.rx_bytes += frameLen;
+
+
+				if (is_multicast_ether_addr
+					(((struct ethhdr *)frameData)->h_dest)) {
+
+					adapter->stats64.multicast += 1;
+					hw->ep_shm_info[cur_epid].net_stats.multicast += 1;
+
+				}
+
+			}
+
+			fjes_rxframe_release(adapter, cur_epid);
+			adapter->unset_rx_last = true;
+		} else {
+			break;
+		}
+	}
+
+
+	if (!npackets) {
+
+		napi_complete(napi);
+
+		if (adapter->unset_rx_last) {
+			adapter->rx_last_jiffies = jiffies;
+			adapter->unset_rx_last = false;
+		}
+
+		if (((long)jiffies - (long)adapter->rx_last_jiffies) < 3)
+			napi_reschedule(napi);
+		else {
+
+			for (epidx = 0; epidx < hw->max_epid; epidx++) {
+				if (epidx == hw->my_epid)
+					continue;
+				adapter->hw.ep_shm_info[epidx].tx.info->v1i.rx_status &=
+						~FJES_RX_POLL_WORK;
+			}
+
+			fjes_hw_set_irqmask(hw, REG_ICTL_MASK_RX_DATA , false);
+		}
+	}
+	return npackets;
+}
+
+
+static int fjes_acpi_add(struct acpi_device *device)
+{
+	acpi_status status;
+	struct acpi_buffer buffer = { ACPI_ALLOCATE_BUFFER, NULL};
+	union acpi_object *str;
+	char str_buf[sizeof(FJES_ACPI_SYMBOL) + 1];
+	int result;
+	struct platform_device *plat_dev;
+
+	status = acpi_evaluate_object(device->handle, "_STR", NULL, &buffer);
+	if (ACPI_FAILURE(status))
+		return -ENODEV;
+
+	str = buffer.pointer;
+	result = utf16s_to_utf8s((wchar_t *)str->string.pointer,
+				str->string.length, UTF16_LITTLE_ENDIAN,
+				str_buf, sizeof(str_buf) - 1);
+	str_buf[result] = 0;
+
+	if (strncmp(FJES_ACPI_SYMBOL, str_buf, strlen(FJES_ACPI_SYMBOL)) != 0) {
+		kfree(buffer.pointer);
+		return -ENODEV;
+	}
+	kfree(buffer.pointer);
+
+	status = acpi_walk_resources(device->handle, METHOD_NAME__CRS,
+				fjes_get_acpi_resource, fjes_resource);
+	if (ACPI_FAILURE(status))
+		return -ENODEV;
+
+
+	/* create platform_device */
+	plat_dev = platform_device_register_simple(DRV_NAME, 0,
+				fjes_resource, ARRAY_SIZE(fjes_resource));
+	platform_set_drvdata(plat_dev, device);
+
+	return 0;
+}
+
+static int fjes_acpi_remove(struct acpi_device *device)
+{
+	/* when to call platform_device_unregister(plat_dev); */
+	return 0;
+}
+
+static acpi_status fjes_get_acpi_resource(struct acpi_resource *acpi_res,
+		void *data)
+{
+	struct resource *res = data;
+	struct acpi_resource_address32 *addr;
+	struct acpi_resource_irq *irq;
+
+	switch (acpi_res->type) {
+	case ACPI_RESOURCE_TYPE_ADDRESS32:
+		addr = &acpi_res->data.address32;
+		res[0].start = addr->address.minimum;
+		res[0].end = addr->address.minimum + 
+			addr->address.address_length;
+		break;
+
+	case ACPI_RESOURCE_TYPE_IRQ:
+		irq = &acpi_res->data.irq;
+		if (irq->interrupt_count != 1)
+			return AE_ERROR;
+		res[1].start = irq->interrupts[0];
+		res[1].end = irq->interrupts[0];
+		break;
+
+	default:
+		break;
+	}
+
+	return AE_OK;
+}
+
+/*
+ *  fjes_probe - Device Initialization Routine
+ *
+ *  Returns 0 on success, negative on failure
+ */
+static int fjes_probe(struct platform_device *plat_dev)
+{
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
+
+	/* setup the private structure */
+	err = fjes_sw_init(adapter);
+	if (err)
+		goto err_sw_init;
+
+
+	INIT_WORK(&adapter->force_close_task, fjes_force_close_task);
+	adapter->force_reset = false;
+	adapter->open_guard = false;
+
+	adapter->txrx_wq = create_workqueue(DRV_NAME"/txrx");
+	adapter->control_wq = create_workqueue(DRV_NAME"/control");
+
+	INIT_WORK(&adapter->tx_stall_task, fjes_tx_stall_task);
+	INIT_WORK(&adapter->raise_intr_rxdata_task,
+			fjes_raise_intr_rxdata_task);
+	INIT_WORK(&adapter->unshare_watch_task, fjes_watch_unsahre_task);
+	adapter->unshare_watch_bitmask = 0;
+
+	INIT_DELAYED_WORK(&adapter->interrupt_watch_task, fjes_irq_watch_task);
+	adapter->interrupt_watch_enable = false;
+
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
+
+	err = register_netdev(netdev);
+	if (err)
+		goto err_register;
+
+	netif_carrier_off(netdev);
+
+	return 0;
+
+err_register:
+err_hw_init:
+err_sw_init:
+err_alloc_netdev:
+	return err;
+}
+
+
+/*
+ *  fjes_remove - Device Removal Routine
+ */
+static int fjes_remove(struct platform_device *plat_dev)
+{
+	struct net_device *netdev = dev_get_drvdata(&plat_dev->dev);
+	struct fjes_adapter *adapter = netdev_priv(netdev);
+	struct fjes_hw *hw = &adapter->hw;
+
+	cancel_delayed_work_sync(&adapter->interrupt_watch_task);
+	cancel_work_sync(&adapter->unshare_watch_task);
+	cancel_work_sync(&adapter->raise_intr_rxdata_task);
+	cancel_work_sync(&adapter->tx_stall_task);
+	cancel_work_sync(&adapter->force_close_task);
+	destroy_workqueue(adapter->control_wq);
+	destroy_workqueue(adapter->txrx_wq);
+
+	fjes_hw_exit(hw);
+	cancel_work_sync(&hw->update_zone_task);
+	cancel_work_sync(&hw->epstop_task);
+
+	unregister_netdev(netdev);
+
+	netif_napi_del(&adapter->napi);
+
+	free_netdev(netdev);
+
+	return 0;
+}
+
+
+static int fjes_sw_init(struct fjes_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+
+	netif_napi_add(netdev, &adapter->napi, fjes_poll, 64);
+
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
+	fjes_set_ethtool_ops(netdev);
+	netdev->mtu = fjes_support_mtu[0];
+	netdev->flags |= IFF_BROADCAST;
+	netdev->features |= NETIF_F_HW_CSUM | NETIF_F_HW_VLAN_CTAG_FILTER;
+
+}
+
+static void fjes_force_close_task(struct work_struct *work)
+{
+	struct fjes_adapter *adapter = container_of(work,
+			struct fjes_adapter, force_close_task);
+	struct net_device *netdev = adapter->netdev;
+
+	rtnl_lock();
+	dev_close(netdev);
+	rtnl_unlock();
+}
+
+static void fjes_tx_stall_task(struct work_struct *work)
+{
+	struct fjes_adapter *adapter = container_of(work,
+			struct fjes_adapter, tx_stall_task);
+	struct fjes_hw *hw = &adapter->hw;
+	struct net_device *netdev = adapter->netdev;
+	enum ep_partner_status pstatus;
+	int epid;
+	int max_epid, my_epid;
+	union ep_buffer_info *info;
+	int all_queue_available;
+	int i;
+	int sendable;
+
+	if (((long)jiffies -
+		(long)(netdev->trans_start)) > FJES_TX_TX_STALL_TIMEOUT) {
+		netif_wake_queue(netdev);
+		return;
+	}
+
+	my_epid = hw->my_epid;
+	max_epid = hw->max_epid;
+
+	for (i = 0; i < 5; i++) {
+		all_queue_available = 1;
+
+		for (epid = 0; epid < max_epid; epid++) {
+
+			if (my_epid == epid)
+				continue;
+
+			pstatus = fjes_hw_get_partner_ep_status(hw, epid);
+			sendable = (pstatus == EP_PARTNER_SHARED);
+			if (!sendable)
+				continue;
+
+			info = adapter->hw.ep_shm_info[epid].tx.info;
+
+			if (EP_RING_FULL(info->v1i.head, info->v1i.tail,
+				info->v1i.count_max)) {
+				all_queue_available = 0;
+				break;
+			}
+		}
+
+		if (all_queue_available) {
+			netif_wake_queue(netdev);
+			return;
+		}
+	}
+
+	usleep_range(50, 100);
+
+	queue_work(adapter->txrx_wq, &adapter->tx_stall_task);
+}
+
+static void fjes_raise_intr_rxdata_task(struct work_struct *work)
+{
+	struct fjes_adapter *adapter = container_of(work,
+			struct fjes_adapter, raise_intr_rxdata_task);
+	struct fjes_hw *hw = &adapter->hw;
+	int epid;
+	int max_epid, my_epid;
+	enum ep_partner_status pstatus;
+
+	my_epid = hw->my_epid;
+	max_epid = hw->max_epid;
+
+	for (epid = 0; epid < max_epid; epid++)
+		hw->ep_shm_info[epid].tx_status_work = 0;
+
+	for (epid = 0; epid < max_epid; epid++) {
+		if (epid == my_epid)
+			continue;
+
+		pstatus = fjes_hw_get_partner_ep_status(hw, epid);
+		if (pstatus == EP_PARTNER_SHARED) {
+
+			hw->ep_shm_info[epid].tx_status_work =
+				hw->ep_shm_info[epid].tx.info->v1i.tx_status;
+
+			if (hw->ep_shm_info[epid].tx_status_work ==
+				FJES_TX_DELAY_SEND_PENDING) {
+				hw->ep_shm_info[epid].tx.info->v1i.tx_status =
+					FJES_TX_DELAY_SEND_NONE;
+			}
+		}
+
+	}
+
+	for (epid = 0; epid < max_epid; epid++) {
+		if (epid == my_epid)
+			continue;
+
+		pstatus = fjes_hw_get_partner_ep_status(hw, epid);
+		if ((hw->ep_shm_info[epid].tx_status_work ==
+				FJES_TX_DELAY_SEND_PENDING) &&
+			(pstatus == EP_PARTNER_SHARED) &&
+			!(hw->ep_shm_info[epid].rx.info->v1i.rx_status)) {
+
+			fjes_hw_raise_interrupt(hw, epid, REG_ICTL_MASK_RX_DATA);
+
+		}
+
+	}
+
+	usleep_range(500, 1000);
+
+}
+
+static void fjes_watch_unsahre_task(struct work_struct *work)
+{
+	struct fjes_adapter *adapter = container_of(work,
+			struct fjes_adapter, unshare_watch_task);
+	struct fjes_hw *hw = &adapter->hw;
+	struct net_device *netdev = adapter->netdev;
+	int epidx;
+	int max_epid, my_epid;
+	unsigned long unshare_watch_bitmask;
+	int wait_time = 0;
+	int is_shared;
+	int ret;
+
+	my_epid = hw->my_epid;
+	max_epid = hw->max_epid;
+
+	unshare_watch_bitmask = adapter->unshare_watch_bitmask;
+	adapter->unshare_watch_bitmask = 0;
+
+	while ((unshare_watch_bitmask || hw->txrx_stop_req_bit) &&
+			(wait_time < 3000)) {
+
+		for (epidx = 0; epidx < hw->max_epid; epidx++) {
+
+			if (epidx == hw->my_epid)
+				continue;
+
+			if (test_bit(epidx, &hw->txrx_stop_req_bit)) {
+
+				is_shared = fjes_hw_epid_is_shared(hw->hw_info.share, epidx);
+				if (!is_shared ||
+					(is_shared &&
+					 (FJES_RX_STOP_REQ_DONE &
+					  hw->ep_shm_info[epidx].rx.info->v1i.rx_status))) {
+
+					mutex_lock(&hw->hw_info.lock);
+					ret = fjes_hw_unregister_buff_addr(hw, epidx);
+					switch (ret) {
+					case 0:
+						break;
+					case -ENOMSG:
+					case -EBUSY:
+					default:
+
+						if (!work_pending(&adapter->force_close_task)) {
+							adapter->force_reset = true;
+							schedule_work(&adapter->force_close_task);
+						}
+						break;
+					}
+					mutex_unlock(&hw->hw_info.lock);
+
+					fjes_hw_setup_epbuf(&hw->ep_shm_info[epidx].tx,
+						netdev->dev_addr, netdev->mtu);
+
+					clear_bit(epidx, &hw->txrx_stop_req_bit);
+					clear_bit(epidx, &unshare_watch_bitmask);
+					clear_bit(epidx, &hw->hw_info.buffer_unshare_reserve_bit);
+
+				}
+			}
+
+			is_shared = fjes_hw_epid_is_shared(hw->hw_info.share, epidx);
+			if (!is_shared && test_bit(epidx, &unshare_watch_bitmask)) {
+
+				if (test_bit(epidx, &hw->hw_info.buffer_unshare_reserve_bit)) {
+
+					mutex_lock(&hw->hw_info.lock);
+					ret = fjes_hw_unregister_buff_addr(hw, epidx);
+					switch (ret) {
+					case 0:
+						break;
+					case -ENOMSG:
+					case -EBUSY:
+					default:
+
+						if (!work_pending(&adapter->force_close_task)) {
+							adapter->force_reset = true;
+							schedule_work(&adapter->force_close_task);
+						}
+						break;
+					}
+					mutex_unlock(&hw->hw_info.lock);
+
+					fjes_hw_setup_epbuf(&hw->ep_shm_info[epidx].tx,
+						netdev->dev_addr, netdev->mtu);
+
+					clear_bit(epidx, &hw->txrx_stop_req_bit);
+					clear_bit(epidx, &unshare_watch_bitmask);
+					clear_bit(epidx, &hw->hw_info.buffer_unshare_reserve_bit);
+
+				}
+			}
+
+		}
+		msleep(100);
+		wait_time += 100;
+	}
+
+	if (hw->hw_info.buffer_unshare_reserve_bit) {
+
+		for (epidx = 0; epidx < hw->max_epid; epidx++) {
+
+			if (epidx == hw->my_epid)
+				continue;
+
+			if (test_bit(epidx, &hw->hw_info.buffer_unshare_reserve_bit)) {
+
+				mutex_lock(&hw->hw_info.lock);
+
+				ret = fjes_hw_unregister_buff_addr(hw, epidx);
+				switch (ret) {
+				case 0:
+					break;
+				case -ENOMSG:
+				case -EBUSY:
+				default:
+
+					if (!work_pending(&adapter->force_close_task)) {
+						adapter->force_reset = true;
+						schedule_work(&adapter->force_close_task);
+					}
+					break;
+				}
+				mutex_unlock(&hw->hw_info.lock);
+
+				fjes_hw_setup_epbuf(&hw->ep_shm_info[epidx].tx,
+					netdev->dev_addr, netdev->mtu);
+
+				clear_bit(epidx, &hw->txrx_stop_req_bit);
+				clear_bit(epidx, &unshare_watch_bitmask);
+				clear_bit(epidx, 
+				  &hw->hw_info.buffer_unshare_reserve_bit);
+			}
+
+			if (test_bit(epidx, &unshare_watch_bitmask)) {
+				hw->ep_shm_info[epidx].tx.info->v1i.rx_status &=
+						~FJES_RX_STOP_REQ_DONE;
+			}
+		}
+
+	}
+
+}
+
+static void fjes_irq_watch_task(struct work_struct *work)
+{
+	struct fjes_adapter *adapter = container_of(to_delayed_work(work),
+			struct fjes_adapter, interrupt_watch_task);
+
+	local_irq_disable();
+	fjes_intr(adapter->hw.hw_res.irq, adapter);
+	local_irq_enable();
+
+	if (fjes_rxframe_search_exist(adapter, 0) >= 0)
+		napi_schedule(&adapter->napi);
+
+
+	if (adapter->interrupt_watch_enable) {
+		if (!delayed_work_pending(&adapter->interrupt_watch_task))
+			queue_delayed_work(adapter->control_wq,
+					&adapter->interrupt_watch_task,
+					FJES_IRQ_WATCH_DELAY);
+	}
+
+}
+
+
+
diff --git a/drivers/platform/x86/fjes/fjes_regs.h b/drivers/platform/x86/fjes/fjes_regs.h
new file mode 100755
index 0000000..1802851
--- /dev/null
+++ b/drivers/platform/x86/fjes/fjes_regs.h
@@ -0,0 +1,139 @@
+/*
+ * fjes_regs.h
+ *
+ *  Created on: 2015/04/18
+ *      Author: izumi
+ */
+
+#ifndef FJES_REGS_H_
+#define FJES_REGS_H_
+
+#include <linux/bitops.h>
+
+
+#define XSCT_DEVICE_REGISTER_SIZE 0x1000
+
+/*
+ *  register offset
+ */
+
+/* Information registers */
+#define XSCT_OWNER_EPID     0x0000  /* Owner EPID */
+#define XSCT_MAX_EP         0x0004  /* Maximum EP */
+
+/* Device Control registers */
+#define XSCT_DCTL           0x0010  /* Device Control */
+
+/* Command Control registers */
+#define XSCT_CR             0x0020  /* Command request */
+#define XSCT_CS             0x0024  /* Command status */
+#define XSCT_SHSTSAL        0x0028  /* Share status address Low */
+#define XSCT_SHSTSAH        0x002C  /* Share status address High */
+
+#define XSCT_REQBL          0x0034  /* Request Buffer length */
+#define XSCT_REQBAL         0x0038  /* Request Buffer Address Low */
+#define XSCT_REQBAH         0x003C  /* Request Buffer Address High */
+
+#define XSCT_RESPBL         0x0044  /* Response Buffer Length */
+#define XSCT_RESPBAL        0x0048  /* Response Buffer Address Low */
+#define XSCT_RESPBAH        0x004C  /* Response Buffer Address High */
+
+/* Interrupt Control registers */
+#define XSCT_IS             0x0080  /* Interrupt status */
+#define XSCT_IMS            0x0084  /* Interrupt mas set */
+#define XSCT_IMC            0x0088  /* Interrupt mask clear */
+#define XSCT_IG             0x008C  /* Interrupt generator */
+#define XSCT_ICTL           0x0090  /* Interrupt control */
+
+
+/*
+ * register structure
+ */
+
+/* Information registers */
+union REG_OWNER_EPID {
+	struct {
+		__le32 epid:16;
+		__le32:16;
+	} Bits;
+	__le32 Reg;
+};
+
+union REG_MAX_EP {
+	struct {
+		__le32 maxep:16;
+		__le32:16;
+	} Bits;
+	__le32 Reg;
+};
+
+/* Device Control registers */
+union REG_DCTL {
+	struct {
+		__le32 reset:1;
+		__le32 rsv0:15;
+		__le32 rsv1:16;
+	} Bits;
+	__le32 Reg;
+};
+
+
+/* Command Control registers */
+union REG_CR {
+	struct {
+		__le32 req_code:16;
+		__le32 err_info:14;
+		__le32 error:1;
+		__le32 req_start:1;
+	} Bits;
+	__le32 Reg;
+};
+
+union REG_CS {
+	struct {
+		__le32 req_code:16;
+		__le32 rsv0:14;
+		__le32 busy:1;
+		__le32 complete:1;
+	} Bits;
+	__le32 Reg;
+};
+
+/* Interrupt Control registers */
+union REG_ICTL {
+	struct {
+		__le32 automak:1;
+		__le32 rsv0:31;
+	} Bits;
+	__le32 Reg;
+};
+
+enum REG_ICTL_MASK {
+	REG_ICTL_MASK_INFO_UPDATE     = 1 << 20,
+	REG_ICTL_MASK_DEV_STOP_REQ    = 1 << 19,
+	REG_ICTL_MASK_TXRX_STOP_REQ   = 1 << 18,
+	REG_ICTL_MASK_TXRX_STOP_DONE  = 1 << 17,
+	REG_ICTL_MASK_RX_DATA         = 1 << 16,
+	REG_ICTL_MASK_ALL             = GENMASK(20, 16),
+};
+
+enum REG_IS_MASK {
+	REG_IS_MASK_IS_ASSERT	= 1 << 31,
+	REG_IS_MASK_EPID		= GENMASK(15, 0),
+};
+
+struct fjes_hw;
+
+u32 fjes_rd32(struct fjes_hw *hw, u32 reg);
+
+#define wr32(reg, val) \
+do { \
+	u8 *base = hw->base; \
+	writel((val), &base[(reg)]); \
+} while (0)
+
+#define rd32(reg) (fjes_rd32(hw, reg))
+
+
+
+#endif /* FJES_REGS_H_ */
-- 
1.9.1
