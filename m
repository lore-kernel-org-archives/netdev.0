From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: [PATCH 2/2] net: Add Keystone NetCP ethernet driver
Date: Tue, 22 Apr 2014 17:21:15 -0400
Message-ID: <1398201675-17379-3-git-send-email-santosh.shilimkar@ti.com>
References: <1398201675-17379-1-git-send-email-santosh.shilimkar@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<devicetree@vger.kernel.org>, Sandeep Nair <sandeep_n@ti.com>,
	Rob Herring <robh+dt@kernel.org>,
	Grant Likely <grant.likely@linaro.org>,
	David Miller <davem@davemloft.net>,
	Santosh Shilimkar <santosh.shilimkar@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1398201675-17379-1-git-send-email-santosh.shilimkar@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sandeep Nair <sandeep_n@ti.com>

The network coprocessor (NetCP) is a hardware accelerator that processes
Ethernet packets. NetCP has a gigabit Ethernet (GbE) subsystem with a ethernet
switch sub-module to send and receive packets. NetCP also includes a packet
accelerator (PA) module to perform packet classification operations such as
header matching, and packet modification operations such as checksum
generation. NetCP can also optionally include a Security Accelerator(SA)
capable of performing IPSec operations on ingress/egress packets.

Keystone SoC's also have a 10 Gigabit Ethernet Subsystem (XGbE) which
includes a 3-port Ethernet switch sub-module capable of 10Gb/s and
1Gb/s rates per Ethernet port.

NetCP driver has a plug-in module architecture where each of the NetCP
sub-modules exist as a loadable kernel module which plug in to the netcp
core. These sub-modules are represented as "netcp-devices" in the dts
bindings. It is mandatory to have the ethernet switch sub-module for
the ethernet interface to be operational. Any other sub-module like the
PA is optional.

Both GBE and XGBE network processors supported using common driver. It
is also designed to handle future variants of NetCP.

Cc: Rob Herring <robh+dt@kernel.org>
Cc: Grant Likely <grant.likely@linaro.org>
Cc: David Miller <davem@davemloft.net>

Signed-off-by: Sandeep Nair <sandeep_n@ti.com>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
---
 drivers/net/ethernet/ti/Kconfig          |   16 +-
 drivers/net/ethernet/ti/Makefile         |    4 +
 drivers/net/ethernet/ti/netcp.h          |  226 +++
 drivers/net/ethernet/ti/netcp_core.c     | 2194 ++++++++++++++++++++++++++++++
 drivers/net/ethernet/ti/netcp_ethss.c    | 2177 +++++++++++++++++++++++++++++
 drivers/net/ethernet/ti/netcp_sgmii.c    |  130 ++
 drivers/net/ethernet/ti/netcp_xgbepcsr.c |  502 +++++++
 7 files changed, 5246 insertions(+), 3 deletions(-)
 create mode 100644 drivers/net/ethernet/ti/netcp.h
 create mode 100644 drivers/net/ethernet/ti/netcp_core.c
 create mode 100644 drivers/net/ethernet/ti/netcp_ethss.c
 create mode 100644 drivers/net/ethernet/ti/netcp_sgmii.c
 create mode 100644 drivers/net/ethernet/ti/netcp_xgbepcsr.c

diff --git a/drivers/net/ethernet/ti/Kconfig b/drivers/net/ethernet/ti/Kconfig
index 53150c2..54ea39c 100644
--- a/drivers/net/ethernet/ti/Kconfig
+++ b/drivers/net/ethernet/ti/Kconfig
@@ -5,7 +5,7 @@
 config NET_VENDOR_TI
 	bool "Texas Instruments (TI) devices"
 	default y
-	depends on PCI || EISA || AR7 || (ARM && (ARCH_DAVINCI || ARCH_OMAP3 || SOC_AM33XX))
+	depends on PCI || EISA || AR7 || (ARM && (ARCH_DAVINCI || ARCH_OMAP3 || SOC_AM33XX || ARCH_KEYSTONE))
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
 	  and read the Ethernet-HOWTO, available from
@@ -32,7 +32,7 @@ config TI_DAVINCI_EMAC
 
 config TI_DAVINCI_MDIO
 	tristate "TI DaVinci MDIO Support"
-	depends on ARM && ( ARCH_DAVINCI || ARCH_OMAP3 || SOC_AM33XX )
+	depends on ARM && ( ARCH_DAVINCI || ARCH_OMAP3 || SOC_AM33XX || ARCH_KEYSTONE )
 	select PHYLIB
 	---help---
 	  This driver supports TI's DaVinci MDIO module.
@@ -70,13 +70,23 @@ config TI_CPSW
 
 config TI_CPTS
 	boolean "TI Common Platform Time Sync (CPTS) Support"
-	depends on TI_CPSW
+	depends on TI_CPSW || TI_KEYSTONE_NET
 	select PTP_1588_CLOCK
 	---help---
 	  This driver supports the Common Platform Time Sync unit of
 	  the CPSW Ethernet Switch. The unit can time stamp PTP UDP/IPv4
 	  and Layer 2 packets, and the driver offers a PTP Hardware Clock.
 
+config TI_KEYSTONE_NETCP
+	tristate "TI Keystone NETCP Ethernet subsystem Support"
+	depends on ARCH_KEYSTONE && OF
+	default y if ARCH_KEYSTONE
+	---help---
+	  This driver supports TI's Keystone NETCP Ethernet subsystem.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called keystone_netcp.
+
 config TLAN
 	tristate "TI ThunderLAN support"
 	depends on (PCI || EISA)
diff --git a/drivers/net/ethernet/ti/Makefile b/drivers/net/ethernet/ti/Makefile
index 9cfaab8..465d03d 100644
--- a/drivers/net/ethernet/ti/Makefile
+++ b/drivers/net/ethernet/ti/Makefile
@@ -10,3 +10,7 @@ obj-$(CONFIG_TI_DAVINCI_CPDMA) += davinci_cpdma.o
 obj-$(CONFIG_TI_CPSW_PHY_SEL) += cpsw-phy-sel.o
 obj-$(CONFIG_TI_CPSW) += ti_cpsw.o
 ti_cpsw-y := cpsw_ale.o cpsw.o cpts.o
+
+obj-$(CONFIG_TI_KEYSTONE_NETCP) += keystone_netcp.o
+keystone_netcp-y := netcp_core.o netcp_ethss.o	netcp_sgmii.o \
+			netcp_xgbepcsr.o cpsw_ale.o cpts.o
diff --git a/drivers/net/ethernet/ti/netcp.h b/drivers/net/ethernet/ti/netcp.h
new file mode 100644
index 0000000..b784d78
--- /dev/null
+++ b/drivers/net/ethernet/ti/netcp.h
@@ -0,0 +1,226 @@
+/*
+ * NetCP driver local header
+ *
+ * Copyright (C) 2014 Texas Instruments Incorporated
+ * Authors:	Sandeep Nair <sandeep_n@ti.com>
+ *		Sandeep Paulraj <s-paulraj@ti.com>
+ *		Cyril Chemparathy <cyril@ti.com>
+ *		Santosh Shilimkar <santosh.shilimkar@ti.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation version 2.
+ *
+ * This program is distributed "as is" WITHOUT ANY WARRANTY of any
+ * kind, whether express or implied; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+#ifndef __NETCP_H__
+#define __NETCP_H__
+
+#include <linux/netdevice.h>
+#include <linux/soc/ti/knav_dma.h>
+
+/* Maximum Ethernet frame size supported by Keystone switch */
+#define NETCP_MAX_FRAME_SIZE		9504
+
+#define SGMII_LINK_MAC_MAC_AUTONEG	0
+#define SGMII_LINK_MAC_PHY		1
+#define SGMII_LINK_MAC_MAC_FORCED	2
+#define SGMII_LINK_MAC_FIBER		3
+#define SGMII_LINK_MAC_PHY_NO_MDIO	4
+#define XGMII_LINK_MAC_PHY		10
+#define XGMII_LINK_MAC_MAC_FORCED	11
+
+struct netcp_device;
+
+struct netcp_tx_pipe {
+	struct netcp_device	*netcp_device;
+	void	*dma_queue;
+	unsigned		dma_queue_id;
+	u8			dma_psflags;
+	void			*dma_channel;
+	unsigned		dma_chan_id;
+};
+
+#define ADDR_NEW			BIT(0)
+#define ADDR_VALID			BIT(1)
+
+enum netcp_addr_type {
+	ADDR_ANY,
+	ADDR_DEV,
+	ADDR_UCAST,
+	ADDR_MCAST,
+	ADDR_BCAST
+};
+
+struct netcp_addr {
+	struct netcp_intf	*netcp;
+	unsigned char		addr[MAX_ADDR_LEN];
+	enum netcp_addr_type	type;
+	unsigned int		flags;
+	struct list_head	node;
+};
+
+struct netcp_intf {
+	struct device		*dev;
+	struct device		*ndev_dev;
+	struct net_device	*ndev;
+	bool			big_endian;
+	unsigned		tx_compl_qid;
+	void			*tx_pool;
+	struct list_head	txhook_list_head;
+	unsigned int		tx_pause_threshold;
+	void			*tx_compl_q;
+
+	unsigned int		tx_resume_threshold;
+	void			*rx_queue;
+	void			*rx_pool;
+	struct list_head	rxhook_list_head;
+	unsigned		rx_queue_id;
+	void			*rx_fdq[KNAV_DMA_FDQ_PER_CHAN];
+	u32			rx_buffer_sizes[KNAV_DMA_FDQ_PER_CHAN];
+	struct napi_struct	rx_napi;
+	struct napi_struct	tx_napi;
+
+	void			*rx_channel;
+	unsigned		dma_chan_id;
+	u32			rx_pool_size;
+	u32			rx_pool_region_id;
+	u32			tx_pool_size;
+	u32			tx_pool_region_id;
+	struct list_head	module_head;
+	struct list_head	interface_list;
+	struct list_head	addr_list;
+	bool			netdev_registered;
+	bool			primary_module_attached;
+
+	/* Lock used for protecting Rx/Tx hook list management */
+	spinlock_t		lock;
+	struct netcp_device	*netcp_device;
+	struct device_node	*node_interface;
+
+	/* DMA configuration data */
+	u32			msg_enable;
+	u32			rx_queue_depths[KNAV_DMA_FDQ_PER_CHAN];
+};
+
+#define	NETCP_PSDATA_LEN		KNAV_DMA_NUM_PS_WORDS
+struct netcp_packet {
+	struct sk_buff		*skb;
+	u32			*epib;
+	u32			*psdata;
+	unsigned int		psdata_len;
+	struct netcp_intf	*netcp;
+	struct netcp_tx_pipe	*tx_pipe;
+	bool			rxtstamp_complete;
+	void			*ts_context;
+	int	(*txtstamp_complete)(void *ctx, struct netcp_packet *pkt);
+};
+
+static inline u32 *netcp_push_psdata(struct netcp_packet *p_info,
+				     unsigned bytes)
+{
+	u32		*buf;
+	unsigned	 words;
+
+	if ((bytes & 0x03) != 0)
+		return NULL;
+	words = bytes >> 2;
+
+	if ((p_info->psdata_len + words) > NETCP_PSDATA_LEN)
+		return NULL;
+
+	p_info->psdata_len += words;
+	buf = &p_info->psdata[NETCP_PSDATA_LEN - p_info->psdata_len];
+	return buf;
+}
+
+static inline int netcp_align_psdata(struct netcp_packet *p_info,
+				     unsigned byte_align)
+{
+	int	padding;
+
+	switch (byte_align) {
+	case 0:
+		padding = -EINVAL;
+		break;
+	case 1:
+	case 2:
+	case 4:
+		padding = 0;
+		break;
+	case 8:
+		padding = (p_info->psdata_len << 2) % 8;
+		break;
+	case 16:
+		padding = (p_info->psdata_len << 2) % 16;
+		break;
+	default:
+		padding = (p_info->psdata_len << 2) % byte_align;
+		break;
+	}
+	return padding;
+}
+
+struct netcp_module {
+	const char		*name;
+	struct module		*owner;
+	bool			primary;
+
+	/* probe/remove: called once per NETCP instance */
+	int	(*probe)(struct netcp_device *netcp_device,
+			 struct device *device, struct device_node *node,
+			 void **inst_priv);
+	int	(*remove)(struct netcp_device *netcp_device, void *inst_priv);
+
+	/* attach/release: called once per network interface */
+	int	(*attach)(void *inst_priv, struct net_device *ndev,
+			  struct device_node *node, void **intf_priv);
+	int	(*release)(void *intf_priv);
+	int	(*open)(void *intf_priv, struct net_device *ndev);
+	int	(*close)(void *intf_priv, struct net_device *ndev);
+	int	(*add_addr)(void *intf_priv, struct netcp_addr *naddr);
+	int	(*del_addr)(void *intf_priv, struct netcp_addr *naddr);
+	int	(*add_vid)(void *intf_priv, int vid);
+	int	(*del_vid)(void *intf_priv, int vid);
+	int	(*ioctl)(void *intf_priv, struct ifreq *req, int cmd);
+
+	/* used internally */
+	struct list_head	module_list;
+	struct list_head	interface_list;
+};
+
+int netcp_register_module(struct netcp_module *module);
+void netcp_unregister_module(struct netcp_module *module);
+void *netcp_module_get_intf_data(struct netcp_module *module,
+				 struct netcp_intf *intf);
+
+int netcp_txpipe_init(struct netcp_tx_pipe *tx_pipe,
+		      struct netcp_device *netcp_device, unsigned dma_chan_id,
+		      unsigned dma_queue_id);
+int netcp_txpipe_open(struct netcp_tx_pipe *tx_pipe);
+int netcp_txpipe_close(struct netcp_tx_pipe *tx_pipe);
+
+typedef int netcp_hook_rtn(int order, void *data, struct netcp_packet *packet);
+int netcp_register_txhook(struct netcp_intf *netcp_priv, int order,
+			  netcp_hook_rtn *hook_rtn, void *hook_data);
+int netcp_unregister_txhook(struct netcp_intf *netcp_priv, int order,
+			    netcp_hook_rtn *hook_rtn, void *hook_data);
+int netcp_register_rxhook(struct netcp_intf *netcp_priv, int order,
+			  netcp_hook_rtn *hook_rtn, void *hook_data);
+int netcp_unregister_rxhook(struct netcp_intf *netcp_priv, int order,
+			    netcp_hook_rtn *hook_rtn, void *hook_data);
+void *netcp_device_find_module(struct netcp_device *netcp_device,
+			       const char *name);
+
+/* SGMII functions */
+int netcp_sgmii_reset(void __iomem *sgmii_ofs, int port);
+int netcp_sgmii_get_port_link(void __iomem *sgmii_ofs, int port);
+int netcp_sgmii_config(void __iomem *sgmii_ofs, int port, u32 interface);
+
+/* XGBE SERDES init functions */
+int netcp_xgbe_serdes_init(void __iomem *serdes_regs, void __iomem *xgbe_regs);
+
+#endif	/* __NETCP_H__ */
diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
new file mode 100644
index 0000000..94feebc
--- /dev/null
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -0,0 +1,2194 @@
+/*
+ * Keystone NetCP Core driver
+ *
+ * Copyright (C) 2014 Texas Instruments Incorporated
+ * Authors:	Sandeep Nair <sandeep_n@ti.com>
+ *		Sandeep Paulraj <s-paulraj@ti.com>
+ *		Cyril Chemparathy <cyril@ti.com>
+ *		Santosh Shilimkar <santosh.shilimkar@ti.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation version 2.
+ *
+ * This program is distributed "as is" WITHOUT ANY WARRANTY of any
+ * kind, whether express or implied; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#include <linux/io.h>
+#include <linux/module.h>
+#include <linux/of_net.h>
+#include <linux/of_address.h>
+#include <linux/if_vlan.h>
+#include <linux/pm_runtime.h>
+#include <linux/platform_device.h>
+#include <linux/soc/ti/knav_qmss.h>
+#include <linux/soc/ti/knav_dma.h>
+
+#include "netcp.h"
+
+#define NETCP_SOP_OFFSET	(NET_IP_ALIGN + NET_SKB_PAD)
+#define NETCP_NAPI_WEIGHT	64
+#define NETCP_TX_TIMEOUT	(5 * HZ)
+#define NETCP_MIN_PACKET_SIZE	ETH_ZLEN
+#define NETCP_MAX_MCAST_ADDR	16
+
+#define NETCP_EFUSE_REG_INDEX	0
+
+#define NETCP_MOD_PROBE_SKIPPED	1
+#define NETCP_MOD_PROBE_FAILED	2
+
+#define NETCP_DEBUG (NETIF_MSG_HW	| NETIF_MSG_WOL		|	\
+		    NETIF_MSG_DRV	| NETIF_MSG_LINK	|	\
+		    NETIF_MSG_IFUP	| NETIF_MSG_INTR	|	\
+		    NETIF_MSG_PROBE	| NETIF_MSG_TIMER	|	\
+		    NETIF_MSG_IFDOWN	| NETIF_MSG_RX_ERR	|	\
+		    NETIF_MSG_TX_ERR	| NETIF_MSG_TX_DONE	|	\
+		    NETIF_MSG_PKTDATA	| NETIF_MSG_TX_QUEUED	|	\
+		    NETIF_MSG_RX_STATUS)
+
+#define knav_queue_get_id(q)	knav_queue_device_control(q, \
+				KNAV_QUEUE_GET_ID, (unsigned long) NULL)
+
+#define knav_queue_enable_notify(q) knav_queue_device_control(q,	\
+					KNAV_QUEUE_ENABLE_NOTIFY,	\
+					(unsigned long) NULL)
+
+#define knav_queue_disable_notify(q) knav_queue_device_control(q,	\
+					KNAV_QUEUE_DISABLE_NOTIFY,	\
+					(unsigned long) NULL)
+
+#define knav_queue_get_count(q)	knav_queue_device_control(q, \
+				KNAV_QUEUE_GET_COUNT, (unsigned long) NULL)
+
+#define for_each_netcp_module(module)			\
+	list_for_each_entry(module, &netcp_modules, module_list)
+
+#define for_each_netcp_device_module(netcp_device, inst_modpriv) \
+	list_for_each_entry(inst_modpriv, \
+		&((netcp_device)->modpriv_head), inst_list)
+
+#define for_each_module(netcp, intf_modpriv)			\
+	list_for_each_entry(intf_modpriv, &netcp->module_head, intf_list)
+
+/* Module management structures */
+struct netcp_device {
+	struct list_head	device_list;
+	struct list_head	interface_head;
+	struct list_head	modpriv_head;
+	struct device		*device;
+	bool			big_endian;
+	unsigned		dma_id;
+};
+
+struct netcp_inst_modpriv {
+	struct netcp_device	*netcp_device;
+	struct netcp_module	*netcp_module;
+	struct list_head	inst_list;
+	void			*module_priv;
+};
+
+struct netcp_intf_modpriv {
+	struct netcp_intf	*netcp_priv;
+	struct netcp_module	*netcp_module;
+	struct list_head	intf_list;
+	void			*module_priv;
+};
+
+static LIST_HEAD(netcp_devices);
+static LIST_HEAD(netcp_modules);
+static DEFINE_MUTEX(netcp_modules_lock);
+
+static int netcp_debug_level = -1;
+module_param(netcp_debug_level, int, 0);
+MODULE_PARM_DESC(netcp_debug_level, "Netcp debug level (NETIF_MSG bits) (0=none,...,16=all)");
+
+static inline u32 hwval_to_host(bool big_endian, u32 hwval)
+{
+	if (big_endian)
+		return be32_to_cpu(hwval);
+	else
+		return le32_to_cpu(hwval);
+}
+
+/* Read the e-fuse value as 32 bit values to be endian independent */
+static inline int emac_arch_get_mac_addr(char *x, void __iomem *efuse_mac)
+{
+	unsigned int addr0, addr1;
+
+	addr1 = readl_relaxed(efuse_mac + 4);
+	addr0 = readl_relaxed(efuse_mac);
+
+	x[0] = (addr1 & 0x0000ff00) >> 8;
+	x[1] = addr1 & 0x000000ff;
+	x[2] = (addr0 & 0xff000000) >> 24;
+	x[3] = (addr0 & 0x00ff0000) >> 16;
+	x[4] = (addr0 & 0x0000ff00) >> 8;
+	x[5] = addr0 & 0x000000ff;
+
+	return 0;
+}
+
+static const char *netcp_node_name(struct device_node *node)
+{
+	const char *name;
+
+	if (of_property_read_string(node, "label", &name) < 0)
+		name = node->name;
+	if (!name)
+		name = "unknown";
+	return name;
+}
+
+/* Module management routines */
+static int netcp_register_interface(struct netcp_intf *netcp)
+{
+	int ret;
+
+	ret = register_netdev(netcp->ndev);
+	if (!ret)
+		netcp->netdev_registered = true;
+	return ret;
+}
+
+static int netcp_module_probe(struct netcp_device *netcp_device,
+			      struct netcp_module *module)
+{
+	struct device *dev = netcp_device->device;
+	struct device_node *devices, *interface, *node = dev->of_node;
+	struct device_node *child;
+	struct netcp_inst_modpriv *inst_modpriv;
+	struct netcp_intf *netcp_intf;
+	struct netcp_module *tmp;
+	bool primary_module_registered = false;
+	int ret;
+
+	/* Find this module in the sub-tree for this device */
+	devices = of_get_child_by_name(node, "netcp-devices");
+	if (!devices) {
+		dev_err(dev, "could not find netcp-devices node\n");
+		return NETCP_MOD_PROBE_SKIPPED;
+	}
+
+	for_each_available_child_of_node(devices, child) {
+		const char *name = netcp_node_name(child);
+		if (!strcasecmp(module->name, name))
+			break;
+	}
+
+	/* If module not used for this device, skip it */
+	if (child == NULL) {
+		dev_warn(dev, "module(%s) not used for device\n", module->name);
+		return NETCP_MOD_PROBE_SKIPPED;
+	}
+
+	inst_modpriv = devm_kzalloc(dev, sizeof(*inst_modpriv), GFP_KERNEL);
+	if (!inst_modpriv) {
+		dev_err(dev, "Failed to allocate instance for %s\n",
+			module->name);
+		return -ENOMEM;
+	}
+
+	inst_modpriv->netcp_device = netcp_device;
+	inst_modpriv->netcp_module = module;
+	list_add_tail(&inst_modpriv->inst_list, &netcp_device->modpriv_head);
+
+	ret = module->probe(netcp_device, dev, child,
+			    &inst_modpriv->module_priv);
+	if (ret) {
+		dev_err(dev, "Probe of module(%s) failed with %d\n",
+			module->name, ret);
+		list_del(&inst_modpriv->inst_list);
+		devm_kfree(dev, inst_modpriv);
+		return NETCP_MOD_PROBE_FAILED;
+	}
+
+	/* Attach modules only if the primary module is probed */
+	for_each_netcp_module(tmp) {
+		if (tmp->primary)
+			primary_module_registered = true;
+	}
+
+	if (!primary_module_registered)
+		return 0;
+
+	/* Attach module to interfaces */
+	list_for_each_entry(netcp_intf, &netcp_device->interface_head,
+			    interface_list) {
+		struct netcp_intf_modpriv *intf_modpriv;
+
+		/* If interface not registered then register now */
+		if (!netcp_intf->netdev_registered)
+			ret = netcp_register_interface(netcp_intf);
+
+		if (ret)
+			return -ENODEV;
+
+		intf_modpriv = devm_kzalloc(dev, sizeof(*intf_modpriv),
+					    GFP_KERNEL);
+		if (!intf_modpriv) {
+			dev_err(dev, "Error allocating intf_modpriv for %s\n",
+				module->name);
+			return -ENOMEM;
+		}
+
+		interface = of_parse_phandle(netcp_intf->node_interface,
+					     module->name, 0);
+
+		intf_modpriv->netcp_priv = netcp_intf;
+		intf_modpriv->netcp_module = module;
+		list_add_tail(&intf_modpriv->intf_list,
+			      &netcp_intf->module_head);
+
+		ret = module->attach(inst_modpriv->module_priv,
+				     netcp_intf->ndev, interface,
+				     &intf_modpriv->module_priv);
+		of_node_put(interface);
+		if (ret) {
+			dev_dbg(dev, "Attach of module %s declined with %d\n",
+				 module->name, ret);
+			list_del(&intf_modpriv->intf_list);
+			devm_kfree(dev, intf_modpriv);
+			continue;
+		}
+	}
+	return 0;
+}
+
+int netcp_register_module(struct netcp_module *module)
+{
+	struct netcp_device *netcp_device;
+	struct netcp_module *tmp;
+	int ret;
+
+	if (!module->name) {
+		WARN(1, "error registering netcp module: no name\n");
+		return -EINVAL;
+	}
+
+	if (!module->probe) {
+		WARN(1, "error registering netcp module: no probe\n");
+		return -EINVAL;
+	}
+
+	mutex_lock(&netcp_modules_lock);
+
+	for_each_netcp_module(tmp) {
+		if (!strcasecmp(tmp->name, module->name)) {
+			mutex_unlock(&netcp_modules_lock);
+			return -EEXIST;
+		}
+	}
+	list_add_tail(&module->module_list, &netcp_modules);
+
+	list_for_each_entry(netcp_device, &netcp_devices, device_list) {
+		ret = netcp_module_probe(netcp_device, module);
+		if (ret < 0)
+			goto fail;
+	}
+
+	mutex_unlock(&netcp_modules_lock);
+	return 0;
+
+fail:
+	mutex_unlock(&netcp_modules_lock);
+	netcp_unregister_module(module);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(netcp_register_module);
+
+static void netcp_release_module(struct netcp_device *netcp_device,
+				 struct netcp_module *module)
+{
+	struct netcp_inst_modpriv *inst_modpriv, *inst_tmp;
+	struct netcp_intf *netcp_intf, *netcp_tmp;
+	struct device *dev = netcp_device->device;
+
+	/* Release the module from each interface */
+	list_for_each_entry_safe(netcp_intf, netcp_tmp,
+				 &netcp_device->interface_head,
+				 interface_list) {
+		struct netcp_intf_modpriv *intf_modpriv, *intf_tmp;
+
+		list_for_each_entry_safe(intf_modpriv, intf_tmp,
+					 &netcp_intf->module_head,
+					 intf_list) {
+			if (intf_modpriv->netcp_module == module) {
+				module->release(intf_modpriv->module_priv);
+				list_del(&intf_modpriv->intf_list);
+				devm_kfree(dev, intf_modpriv);
+				break;
+			}
+		}
+	}
+
+	/* Remove the module from each instance */
+	list_for_each_entry_safe(inst_modpriv, inst_tmp,
+				 &netcp_device->modpriv_head, inst_list) {
+		if (inst_modpriv->netcp_module == module) {
+			module->remove(netcp_device,
+				       inst_modpriv->module_priv);
+			list_del(&inst_modpriv->inst_list);
+			devm_kfree(dev, inst_modpriv);
+			break;
+		}
+	}
+}
+
+void netcp_unregister_module(struct netcp_module *module)
+{
+	struct netcp_device *netcp_device;
+	struct netcp_module *module_tmp;
+
+	mutex_lock(&netcp_modules_lock);
+
+	list_for_each_entry(netcp_device, &netcp_devices, device_list) {
+		netcp_release_module(netcp_device, module);
+	}
+
+	/* Remove the module from the module list */
+	for_each_netcp_module(module_tmp) {
+		if (module == module_tmp) {
+			list_del(&module->module_list);
+			break;
+		}
+	}
+
+	mutex_unlock(&netcp_modules_lock);
+}
+EXPORT_SYMBOL_GPL(netcp_unregister_module);
+
+void *netcp_module_get_intf_data(struct netcp_module *module,
+				 struct netcp_intf *intf)
+{
+	struct netcp_intf_modpriv *intf_modpriv;
+	list_for_each_entry(intf_modpriv, &intf->module_head, intf_list)
+		if (intf_modpriv->netcp_module == module)
+			return intf_modpriv->module_priv;
+	return NULL;
+}
+EXPORT_SYMBOL_GPL(netcp_module_get_intf_data);
+
+/* Module TX and RX Hook management */
+struct netcp_hook_list {
+	struct list_head	 list;
+	netcp_hook_rtn		*hook_rtn;
+	void			*hook_data;
+	int			 order;
+};
+
+int netcp_register_txhook(struct netcp_intf *netcp_priv, int order,
+			  netcp_hook_rtn *hook_rtn, void *hook_data)
+{
+	struct netcp_hook_list *entry;
+	struct netcp_hook_list *next;
+	unsigned long flags;
+
+	entry = devm_kzalloc(netcp_priv->dev, sizeof(*entry), GFP_KERNEL);
+	if (!entry)
+		return -ENOMEM;
+
+	entry->hook_rtn  = hook_rtn;
+	entry->hook_data = hook_data;
+	entry->order     = order;
+
+	spin_lock_irqsave(&netcp_priv->lock, flags);
+	list_for_each_entry(next, &netcp_priv->txhook_list_head, list) {
+		if (next->order > order)
+			break;
+	}
+	__list_add(&entry->list, next->list.prev, &next->list);
+	spin_unlock_irqrestore(&netcp_priv->lock, flags);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(netcp_register_txhook);
+
+int netcp_unregister_txhook(struct netcp_intf *netcp_priv, int order,
+			    netcp_hook_rtn *hook_rtn, void *hook_data)
+{
+	struct netcp_hook_list *next, *n;
+	unsigned long flags;
+
+	spin_lock_irqsave(&netcp_priv->lock, flags);
+	list_for_each_entry_safe(next, n, &netcp_priv->txhook_list_head, list) {
+		if ((next->order     == order) &&
+		    (next->hook_rtn  == hook_rtn) &&
+		    (next->hook_data == hook_data)) {
+			list_del(&next->list);
+			spin_unlock_irqrestore(&netcp_priv->lock, flags);
+			devm_kfree(netcp_priv->dev, next);
+			return 0;
+		}
+	}
+	spin_unlock_irqrestore(&netcp_priv->lock, flags);
+	return -ENOENT;
+}
+EXPORT_SYMBOL_GPL(netcp_unregister_txhook);
+
+int netcp_register_rxhook(struct netcp_intf *netcp_priv, int order,
+			  netcp_hook_rtn *hook_rtn, void *hook_data)
+{
+	struct netcp_hook_list *entry;
+	struct netcp_hook_list *next;
+	unsigned long flags;
+
+	entry = devm_kzalloc(netcp_priv->dev, sizeof(*entry), GFP_KERNEL);
+	if (!entry)
+		return -ENOMEM;
+
+	entry->hook_rtn  = hook_rtn;
+	entry->hook_data = hook_data;
+	entry->order     = order;
+
+	spin_lock_irqsave(&netcp_priv->lock, flags);
+	list_for_each_entry(next, &netcp_priv->rxhook_list_head, list) {
+		if (next->order > order)
+			break;
+	}
+	__list_add(&entry->list, next->list.prev, &next->list);
+	spin_unlock_irqrestore(&netcp_priv->lock, flags);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(netcp_register_rxhook);
+
+int netcp_unregister_rxhook(struct netcp_intf *netcp_priv, int order,
+			    netcp_hook_rtn *hook_rtn, void *hook_data)
+{
+	struct netcp_hook_list *next, *n;
+	unsigned long flags;
+
+	spin_lock_irqsave(&netcp_priv->lock, flags);
+	list_for_each_entry_safe(next, n, &netcp_priv->rxhook_list_head, list) {
+		if ((next->order     == order) &&
+		    (next->hook_rtn  == hook_rtn) &&
+		    (next->hook_data == hook_data)) {
+			list_del(&next->list);
+			spin_unlock_irqrestore(&netcp_priv->lock, flags);
+			devm_kfree(netcp_priv->dev, next);
+			return 0;
+		}
+	}
+	spin_unlock_irqrestore(&netcp_priv->lock, flags);
+
+	return -ENOENT;
+}
+EXPORT_SYMBOL_GPL(netcp_unregister_rxhook);
+
+static inline void netcp_frag_free(bool is_frag, void *ptr)
+{
+	if (is_frag)
+		put_page(virt_to_head_page(ptr));
+	else
+		kfree(ptr);
+}
+
+static void netcp_free_rx_desc_chain(struct netcp_intf *netcp,
+				     struct knav_dma_desc *desc)
+{
+	struct knav_dma_desc *ndesc;
+	dma_addr_t dma_desc, dma_buf;
+	unsigned buf_len, dma_sz = sizeof(*ndesc);
+	void *buf_ptr;
+
+	dma_desc = hwval_to_host(netcp->big_endian, desc->next_desc);
+
+	while (dma_desc) {
+		ndesc = knav_pool_desc_unmap(netcp->rx_pool, dma_desc, dma_sz);
+		if (unlikely(!ndesc)) {
+			dev_err(netcp->ndev_dev, "failed to unmap Rx desc\n");
+			break;
+		}
+		if (netcp->big_endian) {
+			dma_buf = be32_to_cpu(ndesc->buff);
+			buf_ptr = (void *)be32_to_cpu(ndesc->pad[0]);
+			dma_desc = be32_to_cpu(ndesc->next_desc);
+		} else {
+			dma_buf = le32_to_cpu(ndesc->buff);
+			buf_ptr = (void *)le32_to_cpu(ndesc->pad[0]);
+			dma_desc = le32_to_cpu(ndesc->next_desc);
+		}
+		dma_unmap_page(netcp->dev, dma_buf, PAGE_SIZE, DMA_FROM_DEVICE);
+		__free_page(buf_ptr);
+		knav_pool_desc_put(netcp->rx_pool, desc);
+	}
+
+	if (netcp->big_endian) {
+		buf_ptr = (void *)be32_to_cpu(desc->pad[0]);
+		buf_len = be32_to_cpu(desc->pad[1]);
+	} else {
+		buf_ptr = (void *)le32_to_cpu(desc->pad[0]);
+		buf_len = le32_to_cpu(desc->pad[1]);
+	}
+	if (buf_ptr)
+		netcp_frag_free(buf_len <= PAGE_SIZE, buf_ptr);
+	knav_pool_desc_put(netcp->rx_pool, desc);
+}
+
+static void netcp_empty_rx_queue(struct netcp_intf *netcp)
+{
+	struct knav_dma_desc *desc;
+	unsigned dma_sz;
+	dma_addr_t dma;
+
+	for (; ;) {
+		dma = knav_queue_pop(netcp->rx_queue, &dma_sz);
+		if (!dma)
+			break;
+
+		desc = knav_pool_desc_unmap(netcp->rx_pool, dma, dma_sz);
+		if (unlikely(!desc)) {
+			dev_err(netcp->ndev_dev, "%s: failed to unmap Rx desc\n",
+				__func__);
+			netcp->ndev->stats.rx_errors++;
+			continue;
+		}
+		netcp_free_rx_desc_chain(netcp, desc);
+		netcp->ndev->stats.rx_dropped++;
+	}
+}
+
+static inline int netcp_process_one_rx_packet(struct netcp_intf *netcp)
+{
+	unsigned dma_sz, buf_len, org_buf_len;
+	struct knav_dma_desc *desc, *ndesc;
+	unsigned pkt_sz = 0, accum_sz;
+	struct netcp_hook_list *rx_hook;
+	dma_addr_t dma_desc, dma_buff;
+	struct netcp_packet p_info;
+	struct sk_buff *skb;
+	void *org_buf_ptr;
+
+	dma_desc = knav_queue_pop(netcp->rx_queue, &dma_sz);
+	if (!dma_desc)
+		return -1;
+
+	desc = knav_pool_desc_unmap(netcp->rx_pool, dma_desc, dma_sz);
+	if (unlikely(!desc)) {
+		dev_err(netcp->ndev_dev, "failed to unmap Rx desc\n");
+		return 0;
+	}
+
+	if (netcp->big_endian) {
+		pkt_sz = be32_to_cpu(desc->desc_info);
+		buf_len = be32_to_cpu(desc->buff_len);
+		dma_buff = be32_to_cpu(desc->buff);
+		dma_desc = be32_to_cpu(desc->next_desc);
+		org_buf_ptr = (void *)be32_to_cpu(desc->pad[0]);
+		org_buf_len = be32_to_cpu(desc->pad[1]);
+	} else {
+		pkt_sz = le32_to_cpu(desc->desc_info);
+		buf_len = le32_to_cpu(desc->buff_len);
+		dma_buff = le32_to_cpu(desc->buff);
+		dma_desc = le32_to_cpu(desc->next_desc);
+		org_buf_ptr = (void *)le32_to_cpu(desc->pad[0]);
+		org_buf_len = le32_to_cpu(desc->pad[1]);
+	}
+
+	if (unlikely(!org_buf_ptr)) {
+		dev_err(netcp->ndev_dev, "NULL bufptr in desc\n");
+		goto free_desc;
+	}
+
+	pkt_sz &= KNAV_DMA_DESC_PKT_LEN_MASK;
+	accum_sz = buf_len;
+	dma_unmap_single(netcp->dev, dma_buff, buf_len, DMA_FROM_DEVICE);
+
+	/* Build a new sk_buff for the primary buffer */
+	skb = build_skb(org_buf_ptr, org_buf_len);
+	if (unlikely(!skb)) {
+		dev_err(netcp->ndev_dev, "build_skb() failed\n");
+		goto free_desc;
+	}
+
+	/* update data, tail and len */
+	skb_reserve(skb, NETCP_SOP_OFFSET);
+	__skb_put(skb, buf_len);
+
+	/* Fill in the page fragment list */
+	while (dma_desc) {
+		struct page *page;
+
+		ndesc = knav_pool_desc_unmap(netcp->rx_pool, dma_desc, dma_sz);
+		if (unlikely(!ndesc)) {
+			dev_err(netcp->ndev_dev, "failed to unmap Rx desc\n");
+			goto free_desc;
+		}
+
+		if (netcp->big_endian) {
+			dma_buff = be32_to_cpu(ndesc->buff);
+			buf_len = be32_to_cpu(ndesc->buff_len);
+			dma_desc = be32_to_cpu(ndesc->next_desc);
+			page = (void *)be32_to_cpu(ndesc->pad[0]);
+		} else {
+			dma_buff = le32_to_cpu(ndesc->buff);
+			buf_len = le32_to_cpu(ndesc->buff_len);
+			dma_desc = le32_to_cpu(ndesc->next_desc);
+			page = (void *)le32_to_cpu(ndesc->pad[0]);
+		}
+
+		if (likely(dma_buff && buf_len && page)) {
+			dma_unmap_page(netcp->dev, dma_buff, PAGE_SIZE,
+				       DMA_FROM_DEVICE);
+		} else {
+			dev_err(netcp->ndev_dev, "Bad Rx desc dma_buff(%p), len(%d), page(%p)\n",
+				(void *)dma_buff, buf_len, page);
+			goto free_desc;
+		}
+
+		skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags, page,
+				offset_in_page(dma_buff), buf_len, PAGE_SIZE);
+		accum_sz += buf_len;
+
+		/* Free the descriptor */
+		knav_pool_desc_put(netcp->rx_pool, ndesc);
+	}
+
+	/* Free the primary descriptor */
+	knav_pool_desc_put(netcp->rx_pool, desc);
+
+	/* check for packet len and warn */
+	if (unlikely(pkt_sz != accum_sz))
+		dev_dbg(netcp->ndev_dev, "mismatch in packet size(%d) & sum of fragments(%d)\n",
+			 pkt_sz, accum_sz);
+
+	/* Remove ethernet FCS from the packet */
+	__pskb_trim(skb, skb->len - ETH_FCS_LEN);
+
+	/* Call each of the RX hooks */
+	p_info.skb = skb;
+	p_info.rxtstamp_complete = false;
+	list_for_each_entry(rx_hook, &netcp->rxhook_list_head, list) {
+		int ret;
+
+		ret = rx_hook->hook_rtn(rx_hook->order, rx_hook->hook_data,
+					&p_info);
+		if (unlikely(ret)) {
+			dev_err(netcp->ndev_dev, "RX hook %d failed: %d\n",
+				rx_hook->order, ret);
+			netcp->ndev->stats.rx_errors++;
+			dev_kfree_skb(skb);
+			return 0;
+		}
+	}
+
+	netcp->ndev->last_rx = jiffies;
+	netcp->ndev->stats.rx_packets++;
+	netcp->ndev->stats.rx_bytes += skb->len;
+
+	/* push skb up the stack */
+	skb->protocol = eth_type_trans(skb, netcp->ndev);
+	netif_receive_skb(skb);
+	return 0;
+
+free_desc:
+	netcp_free_rx_desc_chain(netcp, desc);
+	netcp->ndev->stats.rx_errors++;
+	return 0;
+}
+
+static inline int netcp_process_rx_packets(struct netcp_intf *netcp,
+					   unsigned budget)
+{
+	int i;
+
+	for (i = 0; (i < budget) && !netcp_process_one_rx_packet(netcp); i++)
+		;
+	return i;
+}
+
+/* Release descriptors and attached buffers from Rx FDQ */
+static inline void netcp_free_rx_buf(struct netcp_intf *netcp, int fdq)
+{
+	struct knav_dma_desc *desc;
+	unsigned int buf_len, dma_sz;
+	dma_addr_t dma;
+	void *buf_ptr;
+
+	/* Allocate descriptor */
+	while ((dma = knav_queue_pop(netcp->rx_fdq[fdq], &dma_sz))) {
+		desc = knav_pool_desc_unmap(netcp->rx_pool, dma, dma_sz);
+		if (unlikely(!desc)) {
+			dev_err(netcp->ndev_dev, "failed to unmap Rx desc\n");
+			continue;
+		}
+
+		if (netcp->big_endian) {
+			dma = be32_to_cpu(desc->orig_buff);
+			buf_len = be32_to_cpu(desc->orig_len);
+			buf_ptr = (void *)be32_to_cpu(desc->pad[0]);
+		} else {
+			dma = le32_to_cpu(desc->orig_buff);
+			buf_len = le32_to_cpu(desc->orig_len);
+			buf_ptr = (void *)le32_to_cpu(desc->pad[0]);
+		}
+
+		if (unlikely(!dma)) {
+			dev_err(netcp->ndev_dev, "NULL orig_buff in desc\n");
+			knav_pool_desc_put(netcp->rx_pool, desc);
+			continue;
+		}
+
+		if (unlikely(!buf_ptr)) {
+			dev_err(netcp->ndev_dev, "NULL bufptr in desc\n");
+			knav_pool_desc_put(netcp->rx_pool, desc);
+			continue;
+		}
+
+		if (fdq == 0) {
+			dma_unmap_single(netcp->dev, dma, buf_len,
+					 DMA_FROM_DEVICE);
+			netcp_frag_free((buf_len <= PAGE_SIZE), buf_ptr);
+		} else {
+			dma_unmap_page(netcp->dev, dma, buf_len,
+				       DMA_FROM_DEVICE);
+			__free_page(buf_ptr);
+		}
+
+		knav_pool_desc_put(netcp->rx_pool, desc);
+	}
+}
+
+static void netcp_rxpool_free(struct netcp_intf *netcp)
+{
+	int i;
+
+	for (i = 0; i < KNAV_DMA_FDQ_PER_CHAN &&
+	     !IS_ERR_OR_NULL(netcp->rx_fdq[i]); i++)
+		netcp_free_rx_buf(netcp, i);
+
+	if (knav_pool_count(netcp->rx_pool) != netcp->rx_pool_size)
+		dev_err(netcp->ndev_dev, "Lost Rx (%d) descriptors\n",
+			netcp->rx_pool_size - knav_pool_count(netcp->rx_pool));
+
+	knav_pool_destroy(netcp->rx_pool);
+	netcp->rx_pool = NULL;
+}
+
+static inline void netcp_allocate_rx_buf(struct netcp_intf *netcp, int fdq)
+{
+	struct knav_dma_desc *hwdesc;
+	unsigned int buf_len, dma_sz;
+	u32 desc_info, pkt_info;
+	struct page *page;
+	dma_addr_t dma;
+	void *bufptr;
+	u32 pad[2];
+
+	/* Allocate descriptor */
+	hwdesc = knav_pool_desc_get(netcp->rx_pool);
+	if (IS_ERR_OR_NULL(hwdesc)) {
+		dev_dbg(netcp->ndev_dev, "out of rx pool desc\n");
+		return;
+	}
+
+	if (likely(fdq == 0)) {
+		unsigned int primary_buf_len;
+		/* Allocate a primary receive queue entry */
+		buf_len = netcp->rx_buffer_sizes[0] + NETCP_SOP_OFFSET;
+		primary_buf_len = SKB_DATA_ALIGN(buf_len) +
+				SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
+
+		if (primary_buf_len <= PAGE_SIZE) {
+			bufptr = netdev_alloc_frag(primary_buf_len);
+			pad[1] = primary_buf_len;
+		} else {
+			bufptr = kmalloc(primary_buf_len, GFP_ATOMIC |
+					 GFP_DMA32 | __GFP_COLD);
+			pad[1] = 0;
+		}
+
+		if (unlikely(!bufptr)) {
+			dev_warn_ratelimited(netcp->ndev_dev, "Primary RX buffer alloc failed\n");
+			goto fail;
+		}
+		dma = dma_map_single(netcp->dev, bufptr, buf_len,
+				     DMA_TO_DEVICE);
+		pad[0] = (u32)bufptr;
+
+	} else {
+		/* Allocate a secondary receive queue entry */
+		page = alloc_page(GFP_ATOMIC | GFP_DMA32 | __GFP_COLD);
+		if (unlikely(!page)) {
+			dev_warn_ratelimited(netcp->ndev_dev, "Secondary page alloc failed\n");
+			goto fail;
+		}
+		buf_len = PAGE_SIZE;
+		dma = dma_map_page(netcp->dev, page, 0, buf_len, DMA_TO_DEVICE);
+		pad[0] = (u32)page;
+		pad[1] = 0;
+	}
+
+	desc_info =  KNAV_DMA_DESC_PS_INFO_IN_DESC;
+	desc_info |= buf_len & KNAV_DMA_DESC_PKT_LEN_MASK;
+	pkt_info =  KNAV_DMA_DESC_HAS_EPIB;
+	pkt_info |= KNAV_DMA_NUM_PS_WORDS << KNAV_DMA_DESC_PSLEN_SHIFT;
+	pkt_info |= (netcp->rx_queue_id & KNAV_DMA_DESC_RETQ_MASK) <<
+		    KNAV_DMA_DESC_RETQ_SHIFT;
+
+	if (unlikely(netcp->big_endian)) {
+		hwdesc->desc_info    = cpu_to_be32(desc_info);
+		hwdesc->packet_info  = cpu_to_be32(pkt_info);
+		hwdesc->orig_len     = cpu_to_be32(buf_len);
+		hwdesc->orig_buff    = cpu_to_be32(dma);
+		hwdesc->pad[0]       = cpu_to_be32(pad[0]);
+		hwdesc->pad[1]       = cpu_to_be32(pad[1]);
+	} else {
+		hwdesc->desc_info    = cpu_to_le32(desc_info);
+		hwdesc->packet_info  = cpu_to_le32(pkt_info);
+		hwdesc->orig_len     = cpu_to_le32(buf_len);
+		hwdesc->orig_buff    = cpu_to_le32(dma);
+		hwdesc->pad[0]       = cpu_to_le32(pad[0]);
+		hwdesc->pad[1]       = cpu_to_le32(pad[1]);
+	}
+
+	/* Push to FDQs */
+	knav_pool_desc_map(netcp->rx_pool, hwdesc, sizeof(*hwdesc), &dma,
+			   &dma_sz);
+	knav_queue_push(netcp->rx_fdq[fdq], dma, sizeof(*hwdesc), 0);
+	return;
+
+fail:
+	knav_pool_desc_put(netcp->rx_pool, hwdesc);
+}
+
+/* Refill Rx FDQ with descriptors & attached buffers */
+static inline void netcp_rxpool_refill(struct netcp_intf *netcp)
+{
+	u32 fdq_deficit[KNAV_DMA_FDQ_PER_CHAN] = {0};
+	int i;
+
+	/* Calculate the FDQ deficit and refill */
+	for (i = 0; i < KNAV_DMA_FDQ_PER_CHAN && netcp->rx_fdq[i]; i++) {
+		fdq_deficit[i] = netcp->rx_queue_depths[i] -
+				 knav_queue_get_count(netcp->rx_fdq[i]);
+
+		while (fdq_deficit[i]--)
+			netcp_allocate_rx_buf(netcp, i);
+	} /* end for fdqs */
+}
+
+/* NAPI poll */
+static int netcp_rx_poll(struct napi_struct *napi, int budget)
+{
+	struct netcp_intf *netcp = container_of(napi, struct netcp_intf,
+						rx_napi);
+	unsigned packets;
+
+	packets = netcp_process_rx_packets(netcp, budget);
+
+	if (packets < budget) {
+		napi_complete(&netcp->rx_napi);
+		knav_queue_enable_notify(netcp->rx_queue);
+	}
+
+	netcp_rxpool_refill(netcp);
+	return packets;
+}
+
+static void netcp_rx_notify(void *arg)
+{
+	struct netcp_intf *netcp = arg;
+
+	knav_queue_disable_notify(netcp->rx_queue);
+	napi_schedule(&netcp->rx_napi);
+}
+
+static inline void netcp_free_tx_desc_chain(struct netcp_intf *netcp,
+					    struct knav_dma_desc *desc,
+					    unsigned desc_sz)
+{
+	struct knav_dma_desc *ndesc = desc;
+	dma_addr_t dma_desc, dma_buf;
+	unsigned buf_len;
+
+	while (ndesc) {
+		if (netcp->big_endian) {
+			dma_buf  = cpu_to_be32(ndesc->buff);
+			buf_len  = cpu_to_be32(ndesc->buff_len);
+			dma_desc = cpu_to_be32(ndesc->next_desc);
+		} else {
+			dma_buf  = cpu_to_le32(ndesc->buff);
+			buf_len  = cpu_to_le32(ndesc->buff_len);
+			dma_desc = cpu_to_le32(ndesc->next_desc);
+		}
+
+		if (dma_buf && buf_len)
+			dma_unmap_single(netcp->dev, dma_buf, buf_len,
+					 DMA_TO_DEVICE);
+		else
+			dev_warn(netcp->ndev_dev, "bad Tx desc buf(%p), len(%d)\n",
+				 (void *)dma_buf, buf_len);
+
+		knav_pool_desc_put(netcp->tx_pool, ndesc);
+		ndesc = NULL;
+		if (dma_desc) {
+			ndesc = knav_pool_desc_unmap(netcp->tx_pool, dma_desc,
+						     desc_sz);
+			if (!ndesc)
+				dev_err(netcp->ndev_dev, "failed to unmap Tx desc\n");
+		}
+	}
+}
+
+static inline int netcp_process_tx_compl_packets(struct netcp_intf *netcp,
+						 unsigned budget)
+{
+	struct knav_dma_desc *desc;
+	struct sk_buff *skb;
+	unsigned dma_sz;
+	dma_addr_t dma;
+	int pkts = 0;
+
+	while (budget--) {
+		dma = knav_queue_pop(netcp->tx_compl_q, &dma_sz);
+		if (!dma)
+			break;
+		desc = knav_pool_desc_unmap(netcp->tx_pool, dma, dma_sz);
+		if (unlikely(!desc)) {
+			dev_err(netcp->ndev_dev, "failed to unmap Tx desc\n");
+			netcp->ndev->stats.tx_errors++;
+			continue;
+		}
+		skb = (void *)hwval_to_host(netcp->big_endian, desc->pad[0]);
+		netcp_free_tx_desc_chain(netcp, desc, dma_sz);
+		if (!skb) {
+			dev_err(netcp->ndev_dev, "No skb in Tx desc\n");
+			netcp->ndev->stats.tx_errors++;
+			continue;
+		}
+
+		if (netif_subqueue_stopped(netcp->ndev, skb) &&
+		    netif_running(netcp->ndev) &&
+		    (knav_pool_count(netcp->tx_pool) >
+		    netcp->tx_resume_threshold)) {
+			u16 subqueue = skb_get_queue_mapping(skb);
+
+			netif_wake_subqueue(netcp->ndev, subqueue);
+		}
+
+		netcp->ndev->stats.tx_packets++;
+		netcp->ndev->stats.tx_bytes += skb->len;
+		dev_kfree_skb(skb);
+		pkts++;
+	}
+	return pkts;
+}
+
+static int netcp_tx_poll(struct napi_struct *napi, int budget)
+{
+	int packets;
+	struct netcp_intf *netcp = container_of(napi, struct netcp_intf,
+						tx_napi);
+
+	packets = netcp_process_tx_compl_packets(netcp, budget);
+	if (packets < budget) {
+		napi_complete(&netcp->tx_napi);
+		knav_queue_enable_notify(netcp->tx_compl_q);
+	}
+
+	return packets;
+}
+
+static void netcp_tx_notify(void *arg)
+{
+	struct netcp_intf *netcp = arg;
+
+	knav_queue_disable_notify(netcp->tx_compl_q);
+	napi_schedule(&netcp->tx_napi);
+}
+
+static inline struct knav_dma_desc*
+netcp_tx_map_skb(struct sk_buff *skb, struct netcp_intf *netcp)
+{
+	struct knav_dma_desc *desc, *ndesc, *pdesc;
+	unsigned int pkt_len = skb_headlen(skb);
+	struct device *dev = netcp->dev;
+	dma_addr_t dma_addr;
+	unsigned dma_sz;
+	int i;
+
+	/* Map the linear buffer */
+	dma_addr = dma_map_single(dev, skb->data, pkt_len, DMA_TO_DEVICE);
+	if (unlikely(!dma_addr)) {
+		dev_err(netcp->ndev_dev, "Failed to map skb buffer\n");
+		return NULL;
+	}
+
+	desc = knav_pool_desc_get(netcp->tx_pool);
+	if (unlikely(IS_ERR_OR_NULL(desc))) {
+		dev_err(netcp->ndev_dev, "out of TX desc\n");
+		dma_unmap_single(dev, dma_addr, pkt_len, DMA_TO_DEVICE);
+		return NULL;
+	}
+
+	if (netcp->big_endian) {
+		desc->buff = cpu_to_be32(dma_addr);
+		desc->buff_len = cpu_to_be32(pkt_len);
+		desc->next_desc = 0;
+	} else {
+		desc->buff = cpu_to_le32(dma_addr);
+		desc->buff_len = cpu_to_le32(pkt_len);
+		desc->next_desc = 0;
+	}
+
+	if (skb_is_nonlinear(skb)) {
+		prefetchw(skb_shinfo(skb));
+	} else {
+		desc->next_desc = 0;
+		goto upd_pkt_len;
+	}
+
+	pdesc = desc;
+
+	/* Handle the case where skb is fragmented in pages */
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+		struct page *page = skb_frag_page(frag);
+		u32 page_offset = frag->page_offset;
+		u32 buf_len = skb_frag_size(frag);
+		dma_addr_t desc_dma;
+		u32 pkt_info;
+
+		dma_addr = dma_map_page(dev, page, page_offset, buf_len,
+					DMA_TO_DEVICE);
+		if (unlikely(!dma_addr)) {
+			dev_err(netcp->ndev_dev, "Failed to map skb page\n");
+			goto free_descs;
+		}
+
+		ndesc = knav_pool_desc_get(netcp->tx_pool);
+		if (unlikely(IS_ERR_OR_NULL(ndesc))) {
+			dev_err(netcp->ndev_dev, "out of TX desc for frags\n");
+			dma_unmap_page(dev, dma_addr, buf_len, DMA_TO_DEVICE);
+			goto free_descs;
+		}
+
+		desc_dma = knav_pool_desc_virt_to_dma(netcp->tx_pool,
+						      (void *)ndesc);
+
+		pkt_info =
+			(netcp->tx_compl_qid & KNAV_DMA_DESC_RETQ_MASK) <<
+				KNAV_DMA_DESC_RETQ_SHIFT;
+
+		if (unlikely(netcp->big_endian)) {
+			ndesc->buff = cpu_to_be32(dma_addr);
+			ndesc->buff_len = cpu_to_be32(buf_len);
+			ndesc->packet_info = cpu_to_be32(pkt_info);
+			ndesc->next_desc = 0;
+			pdesc->next_desc = cpu_to_be32(desc_dma);
+		} else {
+			ndesc->buff = cpu_to_le32(dma_addr);
+			ndesc->buff_len = cpu_to_le32(buf_len);
+			ndesc->packet_info = cpu_to_le32(pkt_info);
+			ndesc->next_desc = 0;
+			pdesc->next_desc = cpu_to_le32(desc_dma);
+		}
+
+		pkt_len += buf_len;
+		if (pdesc != desc)
+			knav_pool_desc_map(netcp->tx_pool, pdesc,
+					   sizeof(*pdesc), &desc_dma, &dma_sz);
+		pdesc = ndesc;
+	}
+	if (pdesc != desc)
+		knav_pool_desc_map(netcp->tx_pool, pdesc, sizeof(*pdesc),
+				   &dma_addr, &dma_sz);
+
+	/* frag list based linkage is not supported for now. */
+	if (skb_shinfo(skb)->frag_list) {
+		dev_err_ratelimited(netcp->ndev_dev, "NETIF_F_FRAGLIST not supported\n");
+		goto free_descs;
+	}
+
+upd_pkt_len:
+	WARN_ON(pkt_len != skb->len);
+
+	pkt_len &= KNAV_DMA_DESC_PKT_LEN_MASK;
+	if (netcp->big_endian)
+		desc->desc_info = cpu_to_be32(pkt_len);
+	else
+		desc->desc_info = cpu_to_le32(pkt_len);
+
+	return desc;
+
+free_descs:
+	netcp_free_tx_desc_chain(netcp, desc, sizeof(*desc));
+	return NULL;
+}
+
+static inline int netcp_tx_submit_skb(struct netcp_intf *netcp,
+				      struct sk_buff *skb,
+				      struct knav_dma_desc *desc)
+{
+	struct netcp_tx_pipe *tx_pipe = NULL;
+	struct netcp_hook_list *tx_hook;
+	struct netcp_packet p_info;
+	u32 packet_info = 0;
+	unsigned dma_sz;
+	dma_addr_t dma;
+	int i, ret = 0;
+
+	p_info.netcp = netcp;
+	p_info.skb = skb;
+	p_info.tx_pipe = NULL;
+	p_info.psdata_len = 0;
+	p_info.ts_context = NULL;
+	p_info.txtstamp_complete = NULL;
+	p_info.epib = desc->epib;
+	p_info.psdata = desc->psdata;
+	memset(p_info.epib, 0, KNAV_DMA_NUM_EPIB_WORDS * sizeof(u32));
+
+	/* Find out where to inject the packet for transmission */
+	list_for_each_entry(tx_hook, &netcp->txhook_list_head, list) {
+		ret = tx_hook->hook_rtn(tx_hook->order, tx_hook->hook_data,
+					&p_info);
+		if (unlikely(ret != 0)) {
+			dev_err(netcp->ndev_dev, "TX hook %d rejected the packet with reason(%d)\n",
+				tx_hook->order, ret);
+			ret = (ret < 0) ? ret : NETDEV_TX_OK;
+			goto out;
+		}
+	}
+
+	/* Make sure some TX hook claimed the packet */
+	tx_pipe = p_info.tx_pipe;
+	if (tx_pipe == NULL) {
+		dev_err(netcp->ndev_dev, "No TX hook claimed the packet!\n");
+		ret = -ENXIO;
+		goto out;
+	}
+
+	/* update descriptor */
+	if (p_info.psdata_len) {
+		u32 *psdata = p_info.psdata;
+
+		memmove(p_info.psdata, p_info.psdata + p_info.psdata_len,
+			p_info.psdata_len);
+
+		if (netcp->big_endian) {
+			for (i = 0; i < p_info.psdata_len; i++, psdata++)
+				*psdata = cpu_to_be32(*psdata);
+		} else {
+			for (i = 0; i < p_info.psdata_len; i++, psdata++)
+				*psdata = cpu_to_le32(*psdata);
+		}
+		packet_info |=
+			(p_info.psdata_len & KNAV_DMA_DESC_PSLEN_MASK) <<
+			KNAV_DMA_DESC_PSLEN_SHIFT;
+	}
+
+	packet_info |= KNAV_DMA_DESC_HAS_EPIB |
+		((netcp->tx_compl_qid & KNAV_DMA_DESC_RETQ_MASK) <<
+		KNAV_DMA_DESC_RETQ_SHIFT) |
+		((tx_pipe->dma_psflags & KNAV_DMA_DESC_PSFLAG_MASK) <<
+		KNAV_DMA_DESC_PSFLAG_SHIFT);
+
+	if (netcp->big_endian) {
+		desc->packet_info = cpu_to_be32(packet_info);
+		desc->pad[0] = cpu_to_be32((u32)skb);
+	} else {
+		desc->packet_info = cpu_to_le32(packet_info);
+		desc->pad[0] = cpu_to_le32((u32)skb);
+	}
+
+	/* submit packet descriptor */
+	ret = knav_pool_desc_map(netcp->tx_pool, desc, sizeof(*desc), &dma,
+				 &dma_sz);
+	if (unlikely(ret)) {
+		dev_err(netcp->ndev_dev, "%s() failed to map desc\n", __func__);
+		ret = -ENOMEM;
+		goto out;
+	}
+	skb_tx_timestamp(skb);
+	knav_queue_push(tx_pipe->dma_queue, dma, dma_sz, 0);
+
+out:
+	return ret;
+}
+
+/* Submit the packet */
+static int netcp_ndo_start_xmit(struct sk_buff *skb, struct net_device *ndev)
+{
+	struct netcp_intf *netcp = netdev_priv(ndev);
+	int subqueue = skb_get_queue_mapping(skb);
+	struct knav_dma_desc *desc;
+	int desc_count, ret = 0;
+
+	if (unlikely(skb->len <= 0)) {
+		dev_kfree_skb(skb);
+		return NETDEV_TX_OK;
+	}
+
+	if (unlikely(skb->len < NETCP_MIN_PACKET_SIZE)) {
+		ret = skb_padto(skb, NETCP_MIN_PACKET_SIZE);
+		if (ret < 0) {
+			/* If we get here, the skb has already been dropped */
+			dev_warn(netcp->ndev_dev, "padding failed (%d), packet dropped\n",
+				 ret);
+			ndev->stats.tx_dropped++;
+			return ret;
+		}
+		skb->len = NETCP_MIN_PACKET_SIZE;
+	}
+
+	desc = netcp_tx_map_skb(skb, netcp);
+	if (unlikely(!desc)) {
+		netif_stop_subqueue(ndev, subqueue);
+		ret = -ENOBUFS;
+		goto drop;
+	}
+
+	ret = netcp_tx_submit_skb(netcp, skb, desc);
+	if (ret)
+		goto drop;
+
+	ndev->trans_start = jiffies;
+
+	/* Check Tx pool count & stop subqueue if needed */
+	desc_count = knav_pool_count(netcp->tx_pool);
+	if (desc_count < netcp->tx_pause_threshold) {
+		dev_dbg(netcp->ndev_dev, "pausing tx, count(%d)\n", desc_count);
+		netif_stop_subqueue(ndev, subqueue);
+	}
+	return NETDEV_TX_OK;
+
+drop:
+	ndev->stats.tx_dropped++;
+	if (desc)
+		netcp_free_tx_desc_chain(netcp, desc, sizeof(*desc));
+	dev_kfree_skb(skb);
+	return ret;
+}
+
+int netcp_txpipe_close(struct netcp_tx_pipe *tx_pipe)
+{
+	if (tx_pipe->dma_channel) {
+		knav_dma_close_channel(tx_pipe->dma_channel);
+		tx_pipe->dma_channel = NULL;
+	}
+	return 0;
+}
+EXPORT_SYMBOL_GPL(netcp_txpipe_close);
+
+int netcp_txpipe_open(struct netcp_tx_pipe *tx_pipe)
+{
+	struct device *dev = tx_pipe->netcp_device->device;
+	unsigned dma_id = tx_pipe->netcp_device->dma_id;
+	struct knav_dma_cfg config;
+	int ret = 0;
+	u8 name[16];
+
+	memset(&config, 0, sizeof(config));
+	config.direction = DMA_MEM_TO_DEV;
+	config.chan_num = tx_pipe->dma_chan_id;
+	config.u.tx.filt_einfo = false;
+	config.u.tx.filt_pswords = false;
+	config.u.tx.priority = DMA_PRIO_MED_L;
+
+	tx_pipe->dma_channel = knav_dma_open_channel(dma_id, &config);
+	if (IS_ERR_OR_NULL(tx_pipe->dma_channel)) {
+		dev_err(dev, "failed opening tx chan(%d)\n",
+			tx_pipe->dma_chan_id);
+		goto err;
+	}
+
+	snprintf(name, sizeof(name), "tx-pipe-%s", dev_name(dev));
+	tx_pipe->dma_queue = knav_queue_open(name, tx_pipe->dma_queue_id,
+					     KNAV_QUEUE_SHARED);
+	if (IS_ERR(tx_pipe->dma_queue)) {
+		dev_err(dev, "Could not open DMA queue for channel \"%s\": %d\n",
+			name, ret);
+		ret = PTR_ERR(tx_pipe->dma_queue);
+		goto err;
+	}
+
+	dev_dbg(dev, "opened tx pipe %s\n", name);
+	return 0;
+
+err:
+	if (!IS_ERR_OR_NULL(tx_pipe->dma_channel))
+		knav_dma_close_channel(tx_pipe->dma_channel);
+	tx_pipe->dma_channel = NULL;
+	return ret;
+}
+EXPORT_SYMBOL_GPL(netcp_txpipe_open);
+
+int netcp_txpipe_init(struct netcp_tx_pipe *tx_pipe,
+		      struct netcp_device *netcp_device,
+		      unsigned dma_chan_id, unsigned dma_queue_id)
+{
+	memset(tx_pipe, 0, sizeof(*tx_pipe));
+	tx_pipe->netcp_device = netcp_device;
+	tx_pipe->dma_chan_id = dma_chan_id;
+	tx_pipe->dma_queue_id = dma_queue_id;
+	return 0;
+}
+EXPORT_SYMBOL_GPL(netcp_txpipe_init);
+
+static struct netcp_addr *netcp_addr_find(struct netcp_intf *netcp,
+					  const u8 *addr,
+					  enum netcp_addr_type type)
+{
+	struct netcp_addr *naddr;
+
+	list_for_each_entry(naddr, &netcp->addr_list, node) {
+		if (naddr->type != type)
+			continue;
+		if (addr && memcmp(addr, naddr->addr, ETH_ALEN))
+			continue;
+		return naddr;
+	}
+
+	return NULL;
+}
+
+static struct netcp_addr *netcp_addr_add(struct netcp_intf *netcp,
+					 const u8 *addr,
+					 enum netcp_addr_type type)
+{
+	struct netcp_addr *naddr;
+
+	naddr = devm_kmalloc(netcp->dev, sizeof(*naddr), GFP_ATOMIC);
+	if (!naddr)
+		return NULL;
+
+	naddr->type = type;
+	naddr->flags = 0;
+	naddr->netcp = netcp;
+	if (addr)
+		ether_addr_copy(naddr->addr, addr);
+	else
+		memset(naddr->addr, 0, ETH_ALEN);
+	list_add_tail(&naddr->node, &netcp->addr_list);
+
+	return naddr;
+}
+
+static void netcp_addr_del(struct netcp_intf *netcp, struct netcp_addr *naddr)
+{
+	list_del(&naddr->node);
+	devm_kfree(netcp->dev, naddr);
+}
+
+static void netcp_addr_clear_mark(struct netcp_intf *netcp)
+{
+	struct netcp_addr *naddr;
+
+	list_for_each_entry(naddr, &netcp->addr_list, node)
+		naddr->flags = 0;
+}
+
+static void netcp_addr_add_mark(struct netcp_intf *netcp, const u8 *addr,
+				enum netcp_addr_type type)
+{
+	struct netcp_addr *naddr;
+
+	naddr = netcp_addr_find(netcp, addr, type);
+	if (naddr) {
+		naddr->flags |= ADDR_VALID;
+		return;
+	}
+
+	naddr = netcp_addr_add(netcp, addr, type);
+	if (!WARN_ON(!naddr))
+		naddr->flags |= ADDR_NEW;
+}
+
+static void netcp_addr_sweep_del(struct netcp_intf *netcp)
+{
+	struct netcp_addr *naddr, *tmp;
+	struct netcp_intf_modpriv *priv;
+	struct netcp_module *module;
+	int error;
+
+	list_for_each_entry_safe(naddr, tmp, &netcp->addr_list, node) {
+		if (naddr->flags & (ADDR_VALID | ADDR_NEW))
+			continue;
+		dev_dbg(netcp->ndev_dev, "deleting address %pM, type %x\n",
+			naddr->addr, naddr->type);
+		mutex_lock(&netcp_modules_lock);
+		for_each_module(netcp, priv) {
+			module = priv->netcp_module;
+			if (!module->del_addr)
+				continue;
+			error = module->del_addr(priv->module_priv,
+						 naddr);
+			WARN_ON(error);
+		}
+		mutex_unlock(&netcp_modules_lock);
+		netcp_addr_del(netcp, naddr);
+	}
+}
+
+static void netcp_addr_sweep_add(struct netcp_intf *netcp)
+{
+	struct netcp_addr *naddr, *tmp;
+	struct netcp_intf_modpriv *priv;
+	struct netcp_module *module;
+	int error;
+
+	list_for_each_entry_safe(naddr, tmp, &netcp->addr_list, node) {
+		if (!(naddr->flags & ADDR_NEW))
+			continue;
+		dev_dbg(netcp->ndev_dev, "adding address %pM, type %x\n",
+			naddr->addr, naddr->type);
+		mutex_lock(&netcp_modules_lock);
+		for_each_module(netcp, priv) {
+			module = priv->netcp_module;
+			if (!module->add_addr)
+				continue;
+			error = module->add_addr(priv->module_priv, naddr);
+			WARN_ON(error);
+		}
+		mutex_unlock(&netcp_modules_lock);
+	}
+}
+
+static void netcp_set_rx_mode(struct net_device *ndev)
+{
+	struct netcp_intf *netcp = netdev_priv(ndev);
+	struct netdev_hw_addr *ndev_addr;
+	bool promisc;
+
+	promisc = (ndev->flags & IFF_PROMISC ||
+		   ndev->flags & IFF_ALLMULTI ||
+		   netdev_mc_count(ndev) > NETCP_MAX_MCAST_ADDR);
+
+	/* first clear all marks */
+	netcp_addr_clear_mark(netcp);
+
+	/* next add new entries, mark existing ones */
+	netcp_addr_add_mark(netcp, ndev->broadcast, ADDR_BCAST);
+	for_each_dev_addr(ndev, ndev_addr)
+		netcp_addr_add_mark(netcp, ndev_addr->addr, ADDR_DEV);
+	netdev_for_each_uc_addr(ndev_addr, ndev)
+		netcp_addr_add_mark(netcp, ndev_addr->addr, ADDR_UCAST);
+	netdev_for_each_mc_addr(ndev_addr, ndev)
+		netcp_addr_add_mark(netcp, ndev_addr->addr, ADDR_MCAST);
+
+	if (promisc)
+		netcp_addr_add_mark(netcp, NULL, ADDR_ANY);
+
+	/* finally sweep and callout into modules */
+	netcp_addr_sweep_del(netcp);
+	netcp_addr_sweep_add(netcp);
+}
+
+static void netcp_free_navigator_resources(struct netcp_intf *netcp)
+{
+	int i;
+
+	if (netcp->rx_channel) {
+		knav_dma_close_channel(netcp->rx_channel);
+		netcp->rx_channel = NULL;
+	}
+
+	if (!IS_ERR_OR_NULL(netcp->rx_pool))
+		netcp_rxpool_free(netcp);
+
+	if (!IS_ERR_OR_NULL(netcp->rx_queue)) {
+		knav_queue_close(netcp->rx_queue);
+		netcp->rx_queue = NULL;
+	}
+
+	for (i = 0; i < KNAV_DMA_FDQ_PER_CHAN &&
+	     !IS_ERR_OR_NULL(netcp->rx_fdq[i]) ; ++i) {
+		knav_queue_close(netcp->rx_fdq[i]);
+		netcp->rx_fdq[i] = NULL;
+	}
+
+	if (!IS_ERR_OR_NULL(netcp->tx_compl_q)) {
+		knav_queue_close(netcp->tx_compl_q);
+		netcp->tx_compl_q = NULL;
+	}
+
+	if (!IS_ERR_OR_NULL(netcp->tx_pool)) {
+		knav_pool_destroy(netcp->tx_pool);
+		netcp->tx_pool = NULL;
+	}
+}
+
+static int netcp_setup_navigator_resources(struct net_device *ndev)
+{
+	struct netcp_intf *netcp = netdev_priv(ndev);
+	struct knav_queue_notify_config notify_cfg;
+	struct knav_dma_cfg config;
+	unsigned dma_id = netcp->netcp_device->dma_id;
+	u32 last_fdq = 0;
+	u8 name[16];
+	int ret;
+	int i;
+
+	/* Create Rx/Tx descriptor pools */
+	snprintf(name, sizeof(name), "rx-pool-%s", ndev->name);
+	netcp->rx_pool = knav_pool_create(name, netcp->rx_pool_size,
+						netcp->rx_pool_region_id);
+	if (IS_ERR_OR_NULL(netcp->rx_pool)) {
+		dev_err(netcp->ndev_dev, "Couldn't create rx pool\n");
+		ret = PTR_ERR(netcp->rx_pool);
+		goto fail;
+	}
+
+	snprintf(name, sizeof(name), "tx-pool-%s", ndev->name);
+	netcp->tx_pool = knav_pool_create(name, netcp->tx_pool_size,
+						netcp->tx_pool_region_id);
+	if (IS_ERR_OR_NULL(netcp->tx_pool)) {
+		dev_err(netcp->ndev_dev, "Couldn't create tx pool\n");
+		ret = PTR_ERR(netcp->tx_pool);
+		goto fail;
+	}
+
+	/* open Tx completion queue */
+	snprintf(name, sizeof(name), "tx-compl-%s", ndev->name);
+	netcp->tx_compl_q = knav_queue_open(name, netcp->tx_compl_qid, 0);
+	if (IS_ERR_OR_NULL(netcp->tx_compl_q)) {
+		ret = PTR_ERR(netcp->tx_compl_q);
+		goto fail;
+	}
+	netcp->tx_compl_qid = knav_queue_get_id(netcp->tx_compl_q);
+
+	/* Set notification for Tx completion */
+	notify_cfg.fn = netcp_tx_notify;
+	notify_cfg.fn_arg = netcp;
+	ret = knav_queue_device_control(netcp->tx_compl_q,
+					KNAV_QUEUE_SET_NOTIFIER,
+					(unsigned long) &notify_cfg);
+	if (ret)
+		goto fail;
+
+	knav_queue_disable_notify(netcp->tx_compl_q);
+
+	/* open Rx completion queue */
+	snprintf(name, sizeof(name), "rx-compl-%s", ndev->name);
+	netcp->rx_queue = knav_queue_open(name, netcp->rx_queue_id, 0);
+	if (IS_ERR_OR_NULL(netcp->rx_queue)) {
+		ret = PTR_ERR(netcp->rx_queue);
+		goto fail;
+	}
+	netcp->rx_queue_id = knav_queue_get_id(netcp->rx_queue);
+
+	/* Set notification for Rx completion */
+	notify_cfg.fn = netcp_rx_notify;
+	notify_cfg.fn_arg = netcp;
+	ret = knav_queue_device_control(netcp->rx_queue,
+					KNAV_QUEUE_SET_NOTIFIER,
+					(unsigned long) &notify_cfg);
+	if (ret)
+		goto fail;
+
+	knav_queue_disable_notify(netcp->rx_queue);
+
+	/* open Rx FDQs */
+	for (i = 0; i < KNAV_DMA_FDQ_PER_CHAN &&
+	     netcp->rx_queue_depths[i] && netcp->rx_buffer_sizes[i]; ++i) {
+		snprintf(name, sizeof(name), "rx-fdq-%s-%d", ndev->name, i);
+		netcp->rx_fdq[i] = knav_queue_open(name, KNAV_QUEUE_GP, 0);
+		if (IS_ERR_OR_NULL(netcp->rx_fdq[i])) {
+			ret = PTR_ERR(netcp->rx_fdq[i]);
+			goto fail;
+		}
+	}
+
+	memset(&config, 0, sizeof(config));
+	config.direction		= DMA_DEV_TO_MEM;
+	config.chan_num			= netcp->dma_chan_id;
+	config.u.rx.einfo_present	= true;
+	config.u.rx.psinfo_present	= true;
+	config.u.rx.err_mode		= DMA_DROP;
+	config.u.rx.desc_type		= DMA_DESC_HOST;
+	config.u.rx.psinfo_at_sop	= false;
+	config.u.rx.sop_offset		= NETCP_SOP_OFFSET;
+	config.u.rx.dst_q		= netcp->rx_queue_id;
+	config.u.rx.thresh		= DMA_THRESH_NONE;
+
+	for (i = 0; i < KNAV_DMA_FDQ_PER_CHAN; ++i) {
+		if (netcp->rx_fdq[i])
+			last_fdq = knav_queue_get_id(netcp->rx_fdq[i]);
+		config.u.rx.fdq[i] = last_fdq;
+	}
+
+	netcp->rx_channel = knav_dma_open_channel(dma_id, &config);
+	if (IS_ERR_OR_NULL(netcp->rx_channel)) {
+		dev_err(netcp->ndev_dev, "failed opening rx chan(%d)\n",
+			netcp->dma_chan_id);
+		goto fail;
+	}
+
+	dev_dbg(netcp->ndev_dev, "opened RX channel: %p\n", netcp->rx_channel);
+	return 0;
+
+fail:
+	netcp_free_navigator_resources(netcp);
+	return ret;
+}
+
+/* Open the device */
+static int netcp_ndo_open(struct net_device *ndev)
+{
+	struct netcp_intf *netcp = netdev_priv(ndev);
+	struct netcp_intf_modpriv *intf_modpriv;
+	struct netcp_module *module;
+	int ret;
+
+	netif_carrier_off(ndev);
+	ret = netcp_setup_navigator_resources(ndev);
+	if (ret) {
+		dev_err(netcp->ndev_dev, "Failed to setup navigator resources\n");
+		goto fail;
+	}
+
+	mutex_lock(&netcp_modules_lock);
+	for_each_module(netcp, intf_modpriv) {
+		module = intf_modpriv->netcp_module;
+		if (module->open != NULL) {
+			ret = module->open(intf_modpriv->module_priv, ndev);
+			if (ret != 0) {
+				dev_err(netcp->ndev_dev, "module open failed\n");
+				goto fail_open;
+			}
+		}
+	}
+	mutex_unlock(&netcp_modules_lock);
+
+	netcp_rxpool_refill(netcp);
+	napi_enable(&netcp->rx_napi);
+	napi_enable(&netcp->tx_napi);
+	knav_queue_enable_notify(netcp->tx_compl_q);
+	knav_queue_enable_notify(netcp->rx_queue);
+	netif_tx_wake_all_queues(ndev);
+	dev_dbg(netcp->ndev_dev, "netcp device %s opened\n", ndev->name);
+	return 0;
+
+fail_open:
+	for_each_module(netcp, intf_modpriv) {
+		module = intf_modpriv->netcp_module;
+		if (module->close != NULL)
+			module->close(intf_modpriv->module_priv, ndev);
+	}
+	mutex_unlock(&netcp_modules_lock);
+
+fail:
+	netcp_free_navigator_resources(netcp);
+	return ret;
+}
+
+/* Close the device */
+static int netcp_ndo_stop(struct net_device *ndev)
+{
+	struct netcp_intf *netcp = netdev_priv(ndev);
+	struct netcp_intf_modpriv *intf_modpriv;
+	struct netcp_module *module;
+	int err = 0;
+
+	netif_tx_stop_all_queues(ndev);
+	netif_carrier_off(ndev);
+	netcp_addr_clear_mark(netcp);
+	netcp_addr_sweep_del(netcp);
+	knav_queue_disable_notify(netcp->rx_queue);
+	knav_queue_disable_notify(netcp->tx_compl_q);
+	napi_disable(&netcp->rx_napi);
+	napi_disable(&netcp->tx_napi);
+
+	mutex_lock(&netcp_modules_lock);
+	for_each_module(netcp, intf_modpriv) {
+		module = intf_modpriv->netcp_module;
+		if (module->close != NULL) {
+			err = module->close(intf_modpriv->module_priv, ndev);
+			if (err != 0)
+				dev_err(netcp->ndev_dev, "Close failed\n");
+		}
+	}
+	mutex_unlock(&netcp_modules_lock);
+
+	/* Recycle Rx descriptors from completion queue */
+	netcp_empty_rx_queue(netcp);
+
+	/* Recycle Tx descriptors from completion queue */
+	netcp_process_tx_compl_packets(netcp, netcp->tx_pool_size);
+
+	if (knav_pool_count(netcp->tx_pool) != netcp->tx_pool_size)
+		dev_err(netcp->ndev_dev, "Lost (%d) Tx descs\n",
+			netcp->tx_pool_size - knav_pool_count(netcp->tx_pool));
+
+	netcp_free_navigator_resources(netcp);
+	dev_dbg(netcp->ndev_dev, "netcp device %s stopped\n", ndev->name);
+	return 0;
+}
+
+static int netcp_ndo_ioctl(struct net_device *ndev,
+			   struct ifreq *req, int cmd)
+{
+	struct netcp_intf *netcp = netdev_priv(ndev);
+	struct netcp_intf_modpriv *intf_modpriv;
+	struct netcp_module *module;
+	int ret = -1, err = -EOPNOTSUPP;
+
+	if (!netif_running(ndev))
+		return -EINVAL;
+
+	mutex_lock(&netcp_modules_lock);
+	for_each_module(netcp, intf_modpriv) {
+		module = intf_modpriv->netcp_module;
+		if (!module->ioctl)
+			continue;
+
+		err = module->ioctl(intf_modpriv->module_priv, req, cmd);
+		if ((err < 0) && (err != -EOPNOTSUPP)) {
+			ret = err;
+			goto out;
+		}
+		if (err == 0)
+			ret = err;
+	}
+
+out:
+	mutex_unlock(&netcp_modules_lock);
+	return (ret == 0) ? 0 : err;
+}
+
+static int netcp_ndo_change_mtu(struct net_device *ndev, int new_mtu)
+{
+	struct netcp_intf *netcp = netdev_priv(ndev);
+
+	/* MTU < 68 is an error for IPv4 traffic */
+	if ((new_mtu < 68) ||
+	    (new_mtu > (NETCP_MAX_FRAME_SIZE - ETH_HLEN - ETH_FCS_LEN))) {
+		dev_err(netcp->ndev_dev, "Invalid mtu size = %d\n", new_mtu);
+		return -EINVAL;
+	}
+
+	ndev->mtu = new_mtu;
+	return 0;
+}
+
+static void netcp_ndo_tx_timeout(struct net_device *ndev)
+{
+	struct netcp_intf *netcp = netdev_priv(ndev);
+	unsigned descs = knav_pool_count(netcp->tx_pool);
+
+	dev_err(netcp->ndev_dev, "transmit timed out tx descs(%d)\n", descs);
+	netcp_process_tx_compl_packets(netcp, netcp->tx_pool_size);
+	ndev->trans_start = jiffies;
+	netif_tx_wake_all_queues(ndev);
+}
+
+static int netcp_rx_add_vid(struct net_device *ndev, __be16 proto, u16 vid)
+{
+	struct netcp_intf *netcp = netdev_priv(ndev);
+	struct netcp_intf_modpriv *intf_modpriv;
+	struct netcp_module *module;
+	int err = 0;
+
+	dev_dbg(netcp->ndev_dev, "adding rx vlan id: %d\n", vid);
+
+	mutex_lock(&netcp_modules_lock);
+	for_each_module(netcp, intf_modpriv) {
+		module = intf_modpriv->netcp_module;
+		if ((module->add_vid != NULL) && (vid != 0)) {
+			err = module->add_vid(intf_modpriv->module_priv, vid);
+			if (err != 0) {
+				dev_err(netcp->ndev_dev, "Could not add vlan id = %d\n",
+					vid);
+				return -ENODEV;
+			}
+		}
+	}
+	mutex_unlock(&netcp_modules_lock);
+	return 0;
+}
+
+static int netcp_rx_kill_vid(struct net_device *ndev, __be16 proto, u16 vid)
+{
+	struct netcp_intf *netcp = netdev_priv(ndev);
+	struct netcp_intf_modpriv *intf_modpriv;
+	struct netcp_module *module;
+	int err = 0;
+
+	dev_dbg(netcp->ndev_dev, "removing rx vlan id: %d\n", vid);
+
+	mutex_lock(&netcp_modules_lock);
+	for_each_module(netcp, intf_modpriv) {
+		module = intf_modpriv->netcp_module;
+		if (module->del_vid != NULL) {
+			err = module->del_vid(intf_modpriv->module_priv, vid);
+			if (err != 0) {
+				dev_err(netcp->ndev_dev, "Could not delete vlan id = %d\n",
+					vid);
+				return -ENODEV;
+			}
+		}
+	}
+	mutex_unlock(&netcp_modules_lock);
+	return 0;
+}
+
+static u16 netcp_select_queue(struct net_device *dev, struct sk_buff *skb,
+			      void *accel_priv,
+			      select_queue_fallback_t fallback)
+{
+	return 0;
+}
+
+static int netcp_setup_tc(struct net_device *dev, u8 num_tc)
+{
+	int i;
+
+	/* setup tc must be called under rtnl lock */
+	ASSERT_RTNL();
+
+	/* Sanity-check the number of traffic classes requested */
+	if ((dev->real_num_tx_queues <= 1) ||
+	    (dev->real_num_tx_queues < num_tc))
+		return -EINVAL;
+
+	/* Configure traffic class to queue mappings */
+	if (num_tc) {
+		netdev_set_num_tc(dev, num_tc);
+		for (i = 0; i < num_tc; i++)
+			netdev_set_tc_queue(dev, i, 1, i);
+	} else {
+		netdev_reset_tc(dev);
+	}
+
+	return 0;
+}
+
+static const struct net_device_ops netcp_netdev_ops = {
+	.ndo_open		= netcp_ndo_open,
+	.ndo_stop		= netcp_ndo_stop,
+	.ndo_start_xmit		= netcp_ndo_start_xmit,
+	.ndo_set_rx_mode	= netcp_set_rx_mode,
+	.ndo_do_ioctl           = netcp_ndo_ioctl,
+	.ndo_change_mtu		= netcp_ndo_change_mtu,
+	.ndo_set_mac_address	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_vlan_rx_add_vid	= netcp_rx_add_vid,
+	.ndo_vlan_rx_kill_vid	= netcp_rx_kill_vid,
+	.ndo_tx_timeout		= netcp_ndo_tx_timeout,
+	.ndo_select_queue	= netcp_select_queue,
+	.ndo_setup_tc		= netcp_setup_tc,
+};
+
+int netcp_create_interface(struct netcp_device *netcp_device,
+			   struct device_node *node_interface)
+{
+	struct device *dev = netcp_device->device;
+	struct device_node *node = dev->of_node;
+	struct netcp_intf *netcp;
+	struct net_device *ndev;
+	resource_size_t size;
+	struct resource res;
+	void __iomem *efuse = NULL;
+	u32 efuse_mac = 0;
+	const void *mac_addr;
+	u8 efuse_mac_addr[6];
+	u32 temp[2];
+	int ret = 0;
+
+	ndev = alloc_etherdev_mqs(sizeof(*netcp), 1, 1);
+	if (!ndev) {
+		dev_err(dev, "Error allocating netdev\n");
+		return -ENOMEM;
+	}
+
+	ndev->features |= NETIF_F_SG;
+	ndev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
+	ndev->hw_features = ndev->features;
+	ndev->vlan_features |=  NETIF_F_SG;
+
+	netcp = netdev_priv(ndev);
+	spin_lock_init(&netcp->lock);
+	INIT_LIST_HEAD(&netcp->module_head);
+	INIT_LIST_HEAD(&netcp->txhook_list_head);
+	INIT_LIST_HEAD(&netcp->rxhook_list_head);
+	INIT_LIST_HEAD(&netcp->addr_list);
+	netcp->netcp_device = netcp_device;
+	netcp->dev = netcp_device->device;
+	netcp->ndev = ndev;
+	netcp->ndev_dev  = &ndev->dev;
+	netcp->msg_enable = netif_msg_init(netcp_debug_level, NETCP_DEBUG);
+	netcp->tx_pause_threshold = MAX_SKB_FRAGS;
+	netcp->tx_resume_threshold = netcp->tx_pause_threshold;
+	netcp->big_endian = netcp_device->big_endian;
+	netcp->node_interface = node_interface;
+
+	ret = of_property_read_u32(node_interface, "efuse-mac", &efuse_mac);
+	if (efuse_mac) {
+		if (of_address_to_resource(node, NETCP_EFUSE_REG_INDEX, &res)) {
+			dev_err(dev, "could not find efuse-mac reg resource\n");
+			ret = -ENODEV;
+			goto quit;
+		}
+		size = resource_size(&res);
+
+		if (!devm_request_mem_region(dev, res.start, size,
+					     dev_name(dev))) {
+			dev_err(dev, "could not reserve resource\n");
+			ret = -ENOMEM;
+			goto quit;
+		}
+
+		efuse = devm_ioremap_nocache(dev, res.start, size);
+		if (!efuse) {
+			dev_err(dev, "could not map resource\n");
+			devm_release_mem_region(dev, res.start, size);
+			ret = -ENOMEM;
+			goto quit;
+		}
+
+		emac_arch_get_mac_addr(efuse_mac_addr, efuse);
+		if (is_valid_ether_addr(efuse_mac_addr))
+			ether_addr_copy(ndev->dev_addr, efuse_mac_addr);
+		else
+			random_ether_addr(ndev->dev_addr);
+
+		devm_iounmap(dev, efuse);
+		devm_release_mem_region(dev, res.start, size);
+	} else {
+		mac_addr = of_get_mac_address(node_interface);
+		if (mac_addr)
+			ether_addr_copy(ndev->dev_addr, mac_addr);
+		else
+			random_ether_addr(ndev->dev_addr);
+	}
+
+	ret = of_property_read_u32(node_interface, "rx-channel",
+				   &netcp->dma_chan_id);
+	if (ret < 0) {
+		dev_err(dev, "missing \"rx-channel\" parameter\n");
+		ret = -ENODEV;
+		goto quit;
+	}
+
+	ret = of_property_read_u32(node_interface, "rx-queue",
+				   &netcp->rx_queue_id);
+	if (ret < 0) {
+		dev_warn(dev, "missing \"rx-queue\" parameter\n");
+		netcp->rx_queue_id = KNAV_QUEUE_QPEND;
+	}
+
+	ret = of_property_read_u32_array(node_interface, "rx-queue-depth",
+					 netcp->rx_queue_depths,
+					 KNAV_DMA_FDQ_PER_CHAN);
+	if (ret < 0) {
+		dev_err(dev, "missing \"rx-queue-depth\" parameter\n");
+		netcp->rx_queue_depths[0] = 128;
+	}
+
+	ret = of_property_read_u32_array(node_interface, "rx-buffer-size",
+					 netcp->rx_buffer_sizes,
+					 KNAV_DMA_FDQ_PER_CHAN);
+	if (ret) {
+		dev_err(dev, "missing \"rx-buffer-size\" parameter\n");
+		netcp->rx_buffer_sizes[0] = 1536;
+	}
+
+	ret = of_property_read_u32_array(node_interface, "rx-pool", temp, 2);
+	if (ret < 0) {
+		dev_err(dev, "missing \"rx-pool\" parameter\n");
+		ret = -ENODEV;
+		goto quit;
+	}
+	netcp->rx_pool_size = temp[0];
+	netcp->rx_pool_region_id = temp[1];
+
+	ret = of_property_read_u32_array(node_interface, "tx-pool", temp, 2);
+	if (ret < 0) {
+		dev_err(dev, "missing \"tx-pool\" parameter\n");
+		ret = -ENODEV;
+		goto quit;
+	}
+	netcp->tx_pool_size = temp[0];
+	netcp->tx_pool_region_id = temp[1];
+
+	if (netcp->tx_pool_size < MAX_SKB_FRAGS) {
+		dev_err(dev, "tx-pool size too small, must be atleast(%ld)\n",
+			MAX_SKB_FRAGS);
+		ret = -ENODEV;
+		goto quit;
+	}
+
+	ret = of_property_read_u32(node_interface, "tx-completion-queue",
+				   &netcp->tx_compl_qid);
+	if (ret < 0) {
+		dev_warn(dev, "missing \"tx-completion-queue\" parameter\n");
+		netcp->tx_compl_qid = KNAV_QUEUE_QPEND;
+	}
+
+	/* NAPI register */
+	netif_napi_add(ndev, &netcp->rx_napi, netcp_rx_poll, NETCP_NAPI_WEIGHT);
+	netif_napi_add(ndev, &netcp->tx_napi, netcp_tx_poll, NETCP_NAPI_WEIGHT);
+
+	/* Register the network device */
+	ndev->dev_id		= 0;
+	ndev->watchdog_timeo	= NETCP_TX_TIMEOUT;
+	ndev->netdev_ops	= &netcp_netdev_ops;
+	SET_NETDEV_DEV(ndev, dev);
+
+	list_add_tail(&netcp->interface_list, &netcp_device->interface_head);
+	return 0;
+
+quit:
+	free_netdev(ndev);
+	return ret;
+}
+
+void netcp_delete_interface(struct netcp_device *netcp_device,
+			    struct net_device *ndev)
+{
+	struct netcp_intf_modpriv *intf_modpriv, *tmp;
+	struct netcp_intf *netcp = netdev_priv(ndev);
+	struct netcp_module *module;
+
+	dev_dbg(netcp_device->device, "Removing interface \"%s\"\n",
+		 ndev->name);
+
+	/* Notify each of the modules that the interface is going away */
+	list_for_each_entry_safe(intf_modpriv, tmp, &netcp->module_head,
+				 intf_list) {
+		module = intf_modpriv->netcp_module;
+		dev_dbg(netcp_device->device, "Releasing module \"%s\"\n",
+			module->name);
+		if (module->release)
+			module->release(intf_modpriv->module_priv);
+		list_del(&intf_modpriv->intf_list);
+		kfree(intf_modpriv);
+	}
+	WARN(!list_empty(&netcp->module_head), "%s interface module list is not empty!\n",
+	     ndev->name);
+
+	list_del(&netcp->interface_list);
+
+	of_node_put(netcp->node_interface);
+	unregister_netdev(ndev);
+	netif_napi_del(&netcp->rx_napi);
+	free_netdev(ndev);
+}
+
+static int netcp_probe(struct platform_device *pdev)
+{
+	struct device_node *node = pdev->dev.of_node;
+	struct device_node *child, *interfaces;
+	struct netcp_device *netcp_device;
+	struct device *dev = &pdev->dev;
+	struct netcp_module *module;
+	int ret;
+
+	if (!node) {
+		dev_err(dev, "could not find device info\n");
+		return -ENODEV;
+	}
+
+	pm_runtime_enable(&pdev->dev);
+	ret = pm_runtime_get_sync(&pdev->dev);
+	if (ret < 0) {
+		dev_err(dev, "Failed to enable NETCP power-domain\n");
+		return ret;
+	}
+
+	/* Allocate a new NETCP device instance */
+	netcp_device = devm_kzalloc(dev, sizeof(*netcp_device), GFP_KERNEL);
+	if (!netcp_device) {
+		dev_err(dev, "failure allocating NETCP device\n");
+		return -ENOMEM;
+	}
+
+	netcp_device->big_endian = (of_get_property(node, "big-endian", NULL)
+					!= NULL);
+
+	ret = of_property_read_u32(node, "dma-id", &netcp_device->dma_id);
+	if (ret < 0) {
+		dev_err(dev, "No Packet DMA device id, err %d\n", ret);
+		return -ENODEV;
+	}
+
+	/* Initialize the NETCP device instance */
+	INIT_LIST_HEAD(&netcp_device->interface_head);
+	INIT_LIST_HEAD(&netcp_device->modpriv_head);
+	netcp_device->device = dev;
+	platform_set_drvdata(pdev, netcp_device);
+
+	/* create interfaces */
+	interfaces = of_get_child_by_name(node, "netcp-interfaces");
+	if (!interfaces) {
+		dev_err(dev, "could not find netcp-interfaces node\n");
+		ret = -ENODEV;
+		goto probe_quit;
+	}
+
+	for_each_available_child_of_node(interfaces, child) {
+		ret = netcp_create_interface(netcp_device, child);
+		if (ret) {
+			dev_err(dev, "could not create interface(%s)\n",
+				child->name);
+			goto probe_quit;
+		}
+	}
+
+	/* Add the device instance to the list */
+	list_add_tail(&netcp_device->device_list, &netcp_devices);
+
+	/* Probe & attach any modules already registered */
+	mutex_lock(&netcp_modules_lock);
+	for_each_netcp_module(module) {
+		ret = netcp_module_probe(netcp_device, module);
+		if (ret < 0)
+			dev_err(dev, "module(%s) probe failed\n", module->name);
+	}
+	mutex_unlock(&netcp_modules_lock);
+	return 0;
+
+probe_quit:
+	pm_runtime_put_sync(&pdev->dev);
+	pm_runtime_disable(&pdev->dev);
+	platform_set_drvdata(pdev, NULL);
+	return ret;
+}
+
+static int netcp_remove(struct platform_device *pdev)
+{
+	struct netcp_device *netcp_device = platform_get_drvdata(pdev);
+	struct netcp_inst_modpriv *inst_modpriv, *tmp;
+	struct netcp_module *module;
+
+	list_for_each_entry_safe(inst_modpriv, tmp, &netcp_device->modpriv_head,
+				 inst_list) {
+		module = inst_modpriv->netcp_module;
+		dev_dbg(&pdev->dev, "Removing module \"%s\"\n", module->name);
+		module->remove(netcp_device, inst_modpriv->module_priv);
+		list_del(&inst_modpriv->inst_list);
+		kfree(inst_modpriv);
+	}
+	WARN(!list_empty(&netcp_device->interface_head), "%s interface list not empty!\n",
+	     pdev->name);
+
+	devm_kfree(&pdev->dev, netcp_device);
+	pm_runtime_put_sync(&pdev->dev);
+	pm_runtime_disable(&pdev->dev);
+	platform_set_drvdata(pdev, NULL);
+	return 0;
+}
+
+static struct of_device_id of_match[] = {
+	{ .compatible = "ti,netcp-1.0", },
+	{},
+};
+MODULE_DEVICE_TABLE(of, of_match);
+
+static struct platform_driver netcp_driver = {
+	.driver = {
+		.name		= "netcp-1.0",
+		.owner		= THIS_MODULE,
+		.of_match_table	= of_match,
+	},
+	.probe = netcp_probe,
+	.remove = netcp_remove,
+};
+module_platform_driver(netcp_driver);
+
+MODULE_LICENSE("GPL v2");
+MODULE_DESCRIPTION("TI NETCP driver for Keystone SOCs");
diff --git a/drivers/net/ethernet/ti/netcp_ethss.c b/drivers/net/ethernet/ti/netcp_ethss.c
new file mode 100644
index 0000000..23ecf95
--- /dev/null
+++ b/drivers/net/ethernet/ti/netcp_ethss.c
@@ -0,0 +1,2177 @@
+/*
+ * Keystone GBE and XGBE subsystem code
+ *
+ * Copyright (C) 2014 Texas Instruments Incorporated
+ * Authors:	Sandeep Nair <sandeep_n@ti.com>
+ *		Sandeep Paulraj <s-paulraj@ti.com>
+ *		Cyril Chemparathy <cyril@ti.com>
+ *		Santosh Shilimkar <santosh.shilimkar@ti.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation version 2.
+ *
+ * This program is distributed "as is" WITHOUT ANY WARRANTY of any
+ * kind, whether express or implied; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#include <linux/io.h>
+#include <linux/of_mdio.h>
+#include <linux/of_address.h>
+#include <linux/if_vlan.h>
+#include <linux/ethtool.h>
+
+#include "cpsw_ale.h"
+#include "netcp.h"
+
+#define NETCP_DRIVER_NAME		"TI KeyStone Ethernet Driver"
+#define NETCP_DRIVER_VERSION		"v1.0"
+
+#define GBE_IDENT(reg)			((reg >> 16) & 0xffff)
+#define GBE_MAJOR_VERSION(reg)		(reg >> 8 & 0x7)
+#define GBE_MINOR_VERSION(reg)		(reg & 0xff)
+#define GBE_RTL_VERSION(reg)		((reg >> 11) & 0x1f)
+
+/* 1G Ethernet SS defines */
+#define GBE_MODULE_NAME			"netcp-gbe"
+#define GBE_SS_VERSION_14		0x4ed21104
+
+#define GBE13_SGMII_MODULE_OFFSET	0x100
+#define GBE13_SGMII34_MODULE_OFFSET	0x400
+#define GBE13_SWITCH_MODULE_OFFSET	0x800
+#define GBE13_HOST_PORT_OFFSET		0x834
+#define GBE13_SLAVE_PORT_OFFSET		0x860
+#define GBE13_EMAC_OFFSET		0x900
+#define GBE13_SLAVE_PORT2_OFFSET	0xa00
+#define GBE13_HW_STATS_OFFSET		0xb00
+#define GBE13_ALE_OFFSET		0xe00
+#define GBE13_HOST_PORT_NUM		0
+#define GBE13_NUM_SLAVES		4
+#define GBE13_NUM_ALE_PORTS		(GBE13_NUM_SLAVES + 1)
+#define GBE13_NUM_ALE_ENTRIES		1024
+
+/* 10G Ethernet SS defines */
+#define XGBE_MODULE_NAME		"netcp-xgbe"
+#define XGBE_SS_VERSION_10		0x4ee42100
+
+#define XGBE_SERDES_REG_INDEX		1
+#define XGBE10_SGMII_MODULE_OFFSET	0x100
+#define XGBE10_SWITCH_MODULE_OFFSET	0x1000
+#define XGBE10_HOST_PORT_OFFSET		0x1034
+#define XGBE10_SLAVE_PORT_OFFSET	0x1064
+#define XGBE10_EMAC_OFFSET		0x1400
+#define XGBE10_ALE_OFFSET		0x1700
+#define XGBE10_HW_STATS_OFFSET		0x1800
+#define XGBE10_HOST_PORT_NUM		0
+#define XGBE10_NUM_SLAVES		2
+#define XGBE10_NUM_ALE_PORTS		(XGBE10_NUM_SLAVES + 1)
+#define XGBE10_NUM_ALE_ENTRIES		1024
+
+#define	GBE_TIMER_INTERVAL			(HZ / 2)
+
+/* Soft reset register values */
+#define SOFT_RESET_MASK				BIT(0)
+#define SOFT_RESET				BIT(0)
+#define DEVICE_EMACSL_RESET_POLL_COUNT		100
+#define GMACSL_RET_WARN_RESET_INCOMPLETE	-2
+
+#define MACSL_RX_ENABLE_CSF			BIT(23)
+#define MACSL_ENABLE_EXT_CTL			BIT(18)
+#define MACSL_XGMII_ENABLE			BIT(13)
+#define MACSL_XGIG_MODE				BIT(8)
+#define MACSL_GIG_MODE				BIT(7)
+#define MACSL_GMII_ENABLE			BIT(5)
+#define MACSL_FULLDUPLEX			BIT(0)
+
+#define GBE_CTL_P0_ENABLE			BIT(2)
+#define GBE_REG_VAL_STAT_ENABLE_ALL		0xff
+#define XGBE_REG_VAL_STAT_ENABLE_ALL		0xf
+#define GBE_STATS_CD_SEL			BIT(28)
+
+#define GBE_PORT_MASK(x)			(BIT(x) - 1)
+#define GBE_MASK_NO_PORTS			0
+
+#define GBE_DEF_1G_MAC_CONTROL					\
+		(MACSL_GIG_MODE | MACSL_GMII_ENABLE |		\
+		 MACSL_ENABLE_EXT_CTL |	MACSL_RX_ENABLE_CSF)
+
+#define GBE_DEF_10G_MAC_CONTROL				\
+		(MACSL_XGIG_MODE | MACSL_XGMII_ENABLE |		\
+		 MACSL_ENABLE_EXT_CTL |	MACSL_RX_ENABLE_CSF)
+
+#define GBE_STATSA_MODULE			0
+#define GBE_STATSB_MODULE			1
+#define GBE_STATSC_MODULE			2
+#define GBE_STATSD_MODULE			3
+
+#define XGBE_STATS0_MODULE			0
+#define XGBE_STATS1_MODULE			1
+#define XGBE_STATS2_MODULE			2
+
+#define MAX_SLAVES				GBE13_NUM_SLAVES
+/* s: 0-based slave_port */
+#define SGMII_BASE(s) \
+	(((s) < 2) ? gbe_dev->sgmii_port_regs : gbe_dev->sgmii_port34_regs)
+
+#define GBE_TX_QUEUE				648
+#define	GBE_TXHOOK_ORDER			0
+#define GBE_DEFAULT_ALE_AGEOUT			30
+#define SLAVE_LINK_IS_XGMII(s) ((s)->link_interface >= XGMII_LINK_MAC_PHY)
+#define NETCP_LINK_STATE_INVALID		-1
+
+#define GBE_SET_REG_OFS(p, rb, rn) p->rb##_ofs.rn = \
+		offsetof(struct gbe##_##rb, rn)
+#define XGBE_SET_REG_OFS(p, rb, rn) p->rb##_ofs.rn = \
+		offsetof(struct xgbe##_##rb, rn)
+#define GBE_REG_ADDR(p, rb, rn) (p->rb + p->rb##_ofs.rn)
+
+struct xgbe_ss_regs {
+	u32	id_ver;
+	u32	synce_count;
+	u32	synce_mux;
+	u32	control;
+};
+
+struct xgbe_switch_regs {
+	u32	id_ver;
+	u32	control;
+	u32	emcontrol;
+	u32	stat_port_en;
+	u32	ptype;
+	u32	soft_idle;
+	u32	thru_rate;
+	u32	gap_thresh;
+	u32	tx_start_wds;
+	u32	flow_control;
+	u32	cppi_thresh;
+};
+
+struct xgbe_port_regs {
+	u32	blk_cnt;
+	u32	port_vlan;
+	u32	tx_pri_map;
+	u32	sa_lo;
+	u32	sa_hi;
+	u32	ts_ctl;
+	u32	ts_seq_ltype;
+	u32	ts_vlan;
+	u32	ts_ctl_ltype2;
+	u32	ts_ctl2;
+	u32	control;
+};
+
+struct xgbe_host_port_regs {
+	u32	blk_cnt;
+	u32	port_vlan;
+	u32	tx_pri_map;
+	u32	src_id;
+	u32	rx_pri_map;
+	u32	rx_maxlen;
+};
+
+struct xgbe_emac_regs {
+	u32	id_ver;
+	u32	mac_control;
+	u32	mac_status;
+	u32	soft_reset;
+	u32	rx_maxlen;
+	u32	__reserved_0;
+	u32	rx_pause;
+	u32	tx_pause;
+	u32	em_control;
+	u32	__reserved_1;
+	u32	tx_gap;
+	u32	rsvd[4];
+};
+
+struct xgbe_host_hw_stats {
+	u32	rx_good_frames;
+	u32	rx_broadcast_frames;
+	u32	rx_multicast_frames;
+	u32	__rsvd_0[3];
+	u32	rx_oversized_frames;
+	u32	__rsvd_1;
+	u32	rx_undersized_frames;
+	u32	__rsvd_2;
+	u32	overrun_type4;
+	u32	overrun_type5;
+	u32	rx_bytes;
+	u32	tx_good_frames;
+	u32	tx_broadcast_frames;
+	u32	tx_multicast_frames;
+	u32	__rsvd_3[9];
+	u32	tx_bytes;
+	u32	tx_64byte_frames;
+	u32	tx_65_to_127byte_frames;
+	u32	tx_128_to_255byte_frames;
+	u32	tx_256_to_511byte_frames;
+	u32	tx_512_to_1023byte_frames;
+	u32	tx_1024byte_frames;
+	u32	net_bytes;
+	u32	rx_sof_overruns;
+	u32	rx_mof_overruns;
+	u32	rx_dma_overruns;
+};
+
+struct xgbe_hw_stats {
+	u32	rx_good_frames;
+	u32	rx_broadcast_frames;
+	u32	rx_multicast_frames;
+	u32	rx_pause_frames;
+	u32	rx_crc_errors;
+	u32	rx_align_code_errors;
+	u32	rx_oversized_frames;
+	u32	rx_jabber_frames;
+	u32	rx_undersized_frames;
+	u32	rx_fragments;
+	u32	overrun_type4;
+	u32	overrun_type5;
+	u32	rx_bytes;
+	u32	tx_good_frames;
+	u32	tx_broadcast_frames;
+	u32	tx_multicast_frames;
+	u32	tx_pause_frames;
+	u32	tx_deferred_frames;
+	u32	tx_collision_frames;
+	u32	tx_single_coll_frames;
+	u32	tx_mult_coll_frames;
+	u32	tx_excessive_collisions;
+	u32	tx_late_collisions;
+	u32	tx_underrun;
+	u32	tx_carrier_sense_errors;
+	u32	tx_bytes;
+	u32	tx_64byte_frames;
+	u32	tx_65_to_127byte_frames;
+	u32	tx_128_to_255byte_frames;
+	u32	tx_256_to_511byte_frames;
+	u32	tx_512_to_1023byte_frames;
+	u32	tx_1024byte_frames;
+	u32	net_bytes;
+	u32	rx_sof_overruns;
+	u32	rx_mof_overruns;
+	u32	rx_dma_overruns;
+};
+#define XGBE10_NUM_STAT_ENTRIES (sizeof(struct xgbe_hw_stats)/sizeof(u32))
+
+struct gbe_ss_regs {
+	u32	id_ver;
+	u32	soft_reset;
+	u32	control;
+	u32	int_control;
+	u32	rx_thresh_en;
+	u32	rx_en;
+	u32	tx_en;
+	u32	misc_en;
+	u32	mem_allign1[8];
+	u32	rx_thresh_stat;
+	u32	rx_stat;
+	u32	tx_stat;
+	u32	misc_stat;
+	u32	mem_allign2[8];
+	u32	rx_imax;
+	u32	tx_imax;
+};
+
+struct gbe_ss_regs_ofs {
+	u16	id_ver;
+	u16	control;
+};
+
+struct gbe_switch_regs {
+	u32	id_ver;
+	u32	control;
+	u32	soft_reset;
+	u32	stat_port_en;
+	u32	ptype;
+	u32	soft_idle;
+	u32	thru_rate;
+	u32	gap_thresh;
+	u32	tx_start_wds;
+	u32	flow_control;
+};
+
+struct gbe_switch_regs_ofs {
+	u16	id_ver;
+	u16	control;
+	u16	soft_reset;
+	u16	emcontrol;
+	u16	stat_port_en;
+	u16	ptype;
+	u16	flow_control;
+};
+
+struct gbe_port_regs {
+	u32	max_blks;
+	u32	blk_cnt;
+	u32	port_vlan;
+	u32	tx_pri_map;
+	u32	sa_lo;
+	u32	sa_hi;
+	u32	ts_ctl;
+	u32	ts_seq_ltype;
+	u32	ts_vlan;
+	u32	ts_ctl_ltype2;
+	u32	ts_ctl2;
+};
+
+struct gbe_port_regs_ofs {
+	u16	port_vlan;
+	u16	tx_pri_map;
+	u16	sa_lo;
+	u16	sa_hi;
+	u16	ts_ctl;
+	u16	ts_seq_ltype;
+	u16	ts_vlan;
+	u16	ts_ctl_ltype2;
+	u16	ts_ctl2;
+};
+
+struct gbe_host_port_regs {
+	u32	src_id;
+	u32	port_vlan;
+	u32	rx_pri_map;
+	u32	rx_maxlen;
+};
+
+struct gbe_host_port_regs_ofs {
+	u16	port_vlan;
+	u16	tx_pri_map;
+	u16	rx_maxlen;
+};
+
+struct gbe_emac_regs {
+	u32	id_ver;
+	u32	mac_control;
+	u32	mac_status;
+	u32	soft_reset;
+	u32	rx_maxlen;
+	u32	__reserved_0;
+	u32	rx_pause;
+	u32	tx_pause;
+	u32	__reserved_1;
+	u32	rx_pri_map;
+	u32	rsvd[6];
+};
+
+struct gbe_emac_regs_ofs {
+	u16	mac_control;
+	u16	soft_reset;
+	u16	rx_maxlen;
+};
+
+struct gbe_hw_stats {
+	u32	rx_good_frames;
+	u32	rx_broadcast_frames;
+	u32	rx_multicast_frames;
+	u32	rx_pause_frames;
+	u32	rx_crc_errors;
+	u32	rx_align_code_errors;
+	u32	rx_oversized_frames;
+	u32	rx_jabber_frames;
+	u32	rx_undersized_frames;
+	u32	rx_fragments;
+	u32	__pad_0[2];
+	u32	rx_bytes;
+	u32	tx_good_frames;
+	u32	tx_broadcast_frames;
+	u32	tx_multicast_frames;
+	u32	tx_pause_frames;
+	u32	tx_deferred_frames;
+	u32	tx_collision_frames;
+	u32	tx_single_coll_frames;
+	u32	tx_mult_coll_frames;
+	u32	tx_excessive_collisions;
+	u32	tx_late_collisions;
+	u32	tx_underrun;
+	u32	tx_carrier_sense_errors;
+	u32	tx_bytes;
+	u32	tx_64byte_frames;
+	u32	tx_65_to_127byte_frames;
+	u32	tx_128_to_255byte_frames;
+	u32	tx_256_to_511byte_frames;
+	u32	tx_512_to_1023byte_frames;
+	u32	tx_1024byte_frames;
+	u32	net_bytes;
+	u32	rx_sof_overruns;
+	u32	rx_mof_overruns;
+	u32	rx_dma_overruns;
+};
+#define GBE13_NUM_HW_STAT_ENTRIES (sizeof(struct gbe_hw_stats)/sizeof(u32))
+#define GBE13_NUM_HW_STATS_MOD			2
+#define XGBE10_NUM_HW_STATS_MOD			3
+#define GBE_MAX_HW_STAT_MODS			3
+#define GBE_HW_STATS_REG_MAP_SZ			0x100
+
+struct gbe_slave {
+	void __iomem			*port_regs;
+	void __iomem			*emac_regs;
+	struct gbe_port_regs_ofs	port_regs_ofs;
+	struct gbe_emac_regs_ofs	emac_regs_ofs;
+	int				slave_num; /* 0 based logical number */
+	int				port_num;  /* actual port number */
+	atomic_t			link_state;
+	bool				open;
+	struct phy_device		*phy;
+	u32				link_interface;
+	u32				mac_control;
+	u8				phy_port_t;
+	struct device_node		*phy_node;
+	struct list_head		slave_list;
+};
+
+struct gbe_priv {
+	struct device			*dev;
+	struct netcp_device		*netcp_device;
+	struct timer_list		timer;
+	u32				num_slaves;
+	u32				ale_entries;
+	u32				ale_ports;
+	bool				enable_ale;
+	struct netcp_tx_pipe		tx_pipe;
+
+	int				host_port;
+	u32				rx_packet_max;
+	u32				ss_version;
+
+	void __iomem			*ss_regs;
+	void __iomem			*switch_regs;
+	void __iomem			*host_port_regs;
+	void __iomem			*ale_reg;
+	void __iomem			*sgmii_port_regs;
+	void __iomem			*sgmii_port34_regs;
+	void __iomem			*xgbe_serdes_regs;
+	void __iomem			*hw_stats_regs[GBE_MAX_HW_STAT_MODS];
+
+	struct gbe_ss_regs_ofs		ss_regs_ofs;
+	struct gbe_switch_regs_ofs	switch_regs_ofs;
+	struct gbe_host_port_regs_ofs	host_port_regs_ofs;
+
+	struct cpsw_ale			*ale;
+	unsigned int			tx_queue_id;
+	unsigned			dma_chan_id;
+
+	struct list_head		gbe_intf_head;
+	struct list_head		secondary_slaves;
+	struct net_device		*dummy_ndev;
+
+	u64				*hw_stats;
+	const struct netcp_ethtool_stat *et_stats;
+	int				num_et_stats;
+	/*  Lock for updating the hwstats */
+	spinlock_t			hw_stats_lock;
+};
+
+struct gbe_intf {
+	struct net_device	*ndev;
+	struct device		*dev;
+	struct gbe_priv	*gbe_dev;
+	struct netcp_tx_pipe	tx_pipe;
+	struct gbe_slave	*slave;
+	struct list_head	gbe_intf_list;
+	unsigned long		active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
+};
+
+static struct netcp_module gbe_module;
+static struct netcp_module xgbe_module;
+
+/* Statistic management */
+struct netcp_ethtool_stat {
+	char desc[ETH_GSTRING_LEN];
+	int type;
+	u32 size;
+	int offset;
+};
+
+#define GBE_STATSA_INFO(field)		"GBE_A:"#field, GBE_STATSA_MODULE,\
+				FIELD_SIZEOF(struct gbe_hw_stats, field), \
+				offsetof(struct gbe_hw_stats, field)
+
+#define GBE_STATSB_INFO(field)		"GBE_B:"#field, GBE_STATSB_MODULE,\
+				FIELD_SIZEOF(struct gbe_hw_stats, field), \
+				offsetof(struct gbe_hw_stats, field)
+
+#define GBE_STATSC_INFO(field)		"GBE_C:"#field, GBE_STATSC_MODULE,\
+				FIELD_SIZEOF(struct gbe_hw_stats, field), \
+				offsetof(struct gbe_hw_stats, field)
+
+#define GBE_STATSD_INFO(field)		"GBE_D:"#field, GBE_STATSD_MODULE,\
+				FIELD_SIZEOF(struct gbe_hw_stats, field), \
+				offsetof(struct gbe_hw_stats, field)
+
+static const struct netcp_ethtool_stat gbe13_et_stats[] = {
+	/* GBE module A */
+	{GBE_STATSA_INFO(rx_good_frames)},
+	{GBE_STATSA_INFO(rx_broadcast_frames)},
+	{GBE_STATSA_INFO(rx_multicast_frames)},
+	{GBE_STATSA_INFO(rx_pause_frames)},
+	{GBE_STATSA_INFO(rx_crc_errors)},
+	{GBE_STATSA_INFO(rx_align_code_errors)},
+	{GBE_STATSA_INFO(rx_oversized_frames)},
+	{GBE_STATSA_INFO(rx_jabber_frames)},
+	{GBE_STATSA_INFO(rx_undersized_frames)},
+	{GBE_STATSA_INFO(rx_fragments)},
+	{GBE_STATSA_INFO(rx_bytes)},
+	{GBE_STATSA_INFO(tx_good_frames)},
+	{GBE_STATSA_INFO(tx_broadcast_frames)},
+	{GBE_STATSA_INFO(tx_multicast_frames)},
+	{GBE_STATSA_INFO(tx_pause_frames)},
+	{GBE_STATSA_INFO(tx_deferred_frames)},
+	{GBE_STATSA_INFO(tx_collision_frames)},
+	{GBE_STATSA_INFO(tx_single_coll_frames)},
+	{GBE_STATSA_INFO(tx_mult_coll_frames)},
+	{GBE_STATSA_INFO(tx_excessive_collisions)},
+	{GBE_STATSA_INFO(tx_late_collisions)},
+	{GBE_STATSA_INFO(tx_underrun)},
+	{GBE_STATSA_INFO(tx_carrier_sense_errors)},
+	{GBE_STATSA_INFO(tx_bytes)},
+	{GBE_STATSA_INFO(tx_64byte_frames)},
+	{GBE_STATSA_INFO(tx_65_to_127byte_frames)},
+	{GBE_STATSA_INFO(tx_128_to_255byte_frames)},
+	{GBE_STATSA_INFO(tx_256_to_511byte_frames)},
+	{GBE_STATSA_INFO(tx_512_to_1023byte_frames)},
+	{GBE_STATSA_INFO(tx_1024byte_frames)},
+	{GBE_STATSA_INFO(net_bytes)},
+	{GBE_STATSA_INFO(rx_sof_overruns)},
+	{GBE_STATSA_INFO(rx_mof_overruns)},
+	{GBE_STATSA_INFO(rx_dma_overruns)},
+	/* GBE module B */
+	{GBE_STATSB_INFO(rx_good_frames)},
+	{GBE_STATSB_INFO(rx_broadcast_frames)},
+	{GBE_STATSB_INFO(rx_multicast_frames)},
+	{GBE_STATSB_INFO(rx_pause_frames)},
+	{GBE_STATSB_INFO(rx_crc_errors)},
+	{GBE_STATSB_INFO(rx_align_code_errors)},
+	{GBE_STATSB_INFO(rx_oversized_frames)},
+	{GBE_STATSB_INFO(rx_jabber_frames)},
+	{GBE_STATSB_INFO(rx_undersized_frames)},
+	{GBE_STATSB_INFO(rx_fragments)},
+	{GBE_STATSB_INFO(rx_bytes)},
+	{GBE_STATSB_INFO(tx_good_frames)},
+	{GBE_STATSB_INFO(tx_broadcast_frames)},
+	{GBE_STATSB_INFO(tx_multicast_frames)},
+	{GBE_STATSB_INFO(tx_pause_frames)},
+	{GBE_STATSB_INFO(tx_deferred_frames)},
+	{GBE_STATSB_INFO(tx_collision_frames)},
+	{GBE_STATSB_INFO(tx_single_coll_frames)},
+	{GBE_STATSB_INFO(tx_mult_coll_frames)},
+	{GBE_STATSB_INFO(tx_excessive_collisions)},
+	{GBE_STATSB_INFO(tx_late_collisions)},
+	{GBE_STATSB_INFO(tx_underrun)},
+	{GBE_STATSB_INFO(tx_carrier_sense_errors)},
+	{GBE_STATSB_INFO(tx_bytes)},
+	{GBE_STATSB_INFO(tx_64byte_frames)},
+	{GBE_STATSB_INFO(tx_65_to_127byte_frames)},
+	{GBE_STATSB_INFO(tx_128_to_255byte_frames)},
+	{GBE_STATSB_INFO(tx_256_to_511byte_frames)},
+	{GBE_STATSB_INFO(tx_512_to_1023byte_frames)},
+	{GBE_STATSB_INFO(tx_1024byte_frames)},
+	{GBE_STATSB_INFO(net_bytes)},
+	{GBE_STATSB_INFO(rx_sof_overruns)},
+	{GBE_STATSB_INFO(rx_mof_overruns)},
+	{GBE_STATSB_INFO(rx_dma_overruns)},
+	/* GBE module C */
+	{GBE_STATSC_INFO(rx_good_frames)},
+	{GBE_STATSC_INFO(rx_broadcast_frames)},
+	{GBE_STATSC_INFO(rx_multicast_frames)},
+	{GBE_STATSC_INFO(rx_pause_frames)},
+	{GBE_STATSC_INFO(rx_crc_errors)},
+	{GBE_STATSC_INFO(rx_align_code_errors)},
+	{GBE_STATSC_INFO(rx_oversized_frames)},
+	{GBE_STATSC_INFO(rx_jabber_frames)},
+	{GBE_STATSC_INFO(rx_undersized_frames)},
+	{GBE_STATSC_INFO(rx_fragments)},
+	{GBE_STATSC_INFO(rx_bytes)},
+	{GBE_STATSC_INFO(tx_good_frames)},
+	{GBE_STATSC_INFO(tx_broadcast_frames)},
+	{GBE_STATSC_INFO(tx_multicast_frames)},
+	{GBE_STATSC_INFO(tx_pause_frames)},
+	{GBE_STATSC_INFO(tx_deferred_frames)},
+	{GBE_STATSC_INFO(tx_collision_frames)},
+	{GBE_STATSC_INFO(tx_single_coll_frames)},
+	{GBE_STATSC_INFO(tx_mult_coll_frames)},
+	{GBE_STATSC_INFO(tx_excessive_collisions)},
+	{GBE_STATSC_INFO(tx_late_collisions)},
+	{GBE_STATSC_INFO(tx_underrun)},
+	{GBE_STATSC_INFO(tx_carrier_sense_errors)},
+	{GBE_STATSC_INFO(tx_bytes)},
+	{GBE_STATSC_INFO(tx_64byte_frames)},
+	{GBE_STATSC_INFO(tx_65_to_127byte_frames)},
+	{GBE_STATSC_INFO(tx_128_to_255byte_frames)},
+	{GBE_STATSC_INFO(tx_256_to_511byte_frames)},
+	{GBE_STATSC_INFO(tx_512_to_1023byte_frames)},
+	{GBE_STATSC_INFO(tx_1024byte_frames)},
+	{GBE_STATSC_INFO(net_bytes)},
+	{GBE_STATSC_INFO(rx_sof_overruns)},
+	{GBE_STATSC_INFO(rx_mof_overruns)},
+	{GBE_STATSC_INFO(rx_dma_overruns)},
+	/* GBE module D */
+	{GBE_STATSD_INFO(rx_good_frames)},
+	{GBE_STATSD_INFO(rx_broadcast_frames)},
+	{GBE_STATSD_INFO(rx_multicast_frames)},
+	{GBE_STATSD_INFO(rx_pause_frames)},
+	{GBE_STATSD_INFO(rx_crc_errors)},
+	{GBE_STATSD_INFO(rx_align_code_errors)},
+	{GBE_STATSD_INFO(rx_oversized_frames)},
+	{GBE_STATSD_INFO(rx_jabber_frames)},
+	{GBE_STATSD_INFO(rx_undersized_frames)},
+	{GBE_STATSD_INFO(rx_fragments)},
+	{GBE_STATSD_INFO(rx_bytes)},
+	{GBE_STATSD_INFO(tx_good_frames)},
+	{GBE_STATSD_INFO(tx_broadcast_frames)},
+	{GBE_STATSD_INFO(tx_multicast_frames)},
+	{GBE_STATSD_INFO(tx_pause_frames)},
+	{GBE_STATSD_INFO(tx_deferred_frames)},
+	{GBE_STATSD_INFO(tx_collision_frames)},
+	{GBE_STATSD_INFO(tx_single_coll_frames)},
+	{GBE_STATSD_INFO(tx_mult_coll_frames)},
+	{GBE_STATSD_INFO(tx_excessive_collisions)},
+	{GBE_STATSD_INFO(tx_late_collisions)},
+	{GBE_STATSD_INFO(tx_underrun)},
+	{GBE_STATSD_INFO(tx_carrier_sense_errors)},
+	{GBE_STATSD_INFO(tx_bytes)},
+	{GBE_STATSD_INFO(tx_64byte_frames)},
+	{GBE_STATSD_INFO(tx_65_to_127byte_frames)},
+	{GBE_STATSD_INFO(tx_128_to_255byte_frames)},
+	{GBE_STATSD_INFO(tx_256_to_511byte_frames)},
+	{GBE_STATSD_INFO(tx_512_to_1023byte_frames)},
+	{GBE_STATSD_INFO(tx_1024byte_frames)},
+	{GBE_STATSD_INFO(net_bytes)},
+	{GBE_STATSD_INFO(rx_sof_overruns)},
+	{GBE_STATSD_INFO(rx_mof_overruns)},
+	{GBE_STATSD_INFO(rx_dma_overruns)},
+};
+
+#define XGBE_STATS0_INFO(field)	"GBE_0:"#field, XGBE_STATS0_MODULE, \
+				FIELD_SIZEOF(struct xgbe_hw_stats, field), \
+				offsetof(struct xgbe_hw_stats, field)
+
+#define XGBE_STATS1_INFO(field)	"GBE_1:"#field, XGBE_STATS1_MODULE, \
+				FIELD_SIZEOF(struct xgbe_hw_stats, field), \
+				offsetof(struct xgbe_hw_stats, field)
+
+#define XGBE_STATS2_INFO(field)	"GBE_2:"#field, XGBE_STATS2_MODULE, \
+				FIELD_SIZEOF(struct xgbe_hw_stats, field), \
+				offsetof(struct xgbe_hw_stats, field)
+
+static const struct netcp_ethtool_stat xgbe10_et_stats[] = {
+	/* GBE module 0 */
+	{XGBE_STATS0_INFO(rx_good_frames)},
+	{XGBE_STATS0_INFO(rx_broadcast_frames)},
+	{XGBE_STATS0_INFO(rx_multicast_frames)},
+	{XGBE_STATS0_INFO(rx_oversized_frames)},
+	{XGBE_STATS0_INFO(rx_undersized_frames)},
+	{XGBE_STATS0_INFO(overrun_type4)},
+	{XGBE_STATS0_INFO(overrun_type5)},
+	{XGBE_STATS0_INFO(rx_bytes)},
+	{XGBE_STATS0_INFO(tx_good_frames)},
+	{XGBE_STATS0_INFO(tx_broadcast_frames)},
+	{XGBE_STATS0_INFO(tx_multicast_frames)},
+	{XGBE_STATS0_INFO(tx_bytes)},
+	{XGBE_STATS0_INFO(tx_64byte_frames)},
+	{XGBE_STATS0_INFO(tx_65_to_127byte_frames)},
+	{XGBE_STATS0_INFO(tx_128_to_255byte_frames)},
+	{XGBE_STATS0_INFO(tx_256_to_511byte_frames)},
+	{XGBE_STATS0_INFO(tx_512_to_1023byte_frames)},
+	{XGBE_STATS0_INFO(tx_1024byte_frames)},
+	{XGBE_STATS0_INFO(net_bytes)},
+	{XGBE_STATS0_INFO(rx_sof_overruns)},
+	{XGBE_STATS0_INFO(rx_mof_overruns)},
+	{XGBE_STATS0_INFO(rx_dma_overruns)},
+	/* XGBE module 1 */
+	{XGBE_STATS1_INFO(rx_good_frames)},
+	{XGBE_STATS1_INFO(rx_broadcast_frames)},
+	{XGBE_STATS1_INFO(rx_multicast_frames)},
+	{XGBE_STATS1_INFO(rx_pause_frames)},
+	{XGBE_STATS1_INFO(rx_crc_errors)},
+	{XGBE_STATS1_INFO(rx_align_code_errors)},
+	{XGBE_STATS1_INFO(rx_oversized_frames)},
+	{XGBE_STATS1_INFO(rx_jabber_frames)},
+	{XGBE_STATS1_INFO(rx_undersized_frames)},
+	{XGBE_STATS1_INFO(rx_fragments)},
+	{XGBE_STATS1_INFO(overrun_type4)},
+	{XGBE_STATS1_INFO(overrun_type5)},
+	{XGBE_STATS1_INFO(rx_bytes)},
+	{XGBE_STATS1_INFO(tx_good_frames)},
+	{XGBE_STATS1_INFO(tx_broadcast_frames)},
+	{XGBE_STATS1_INFO(tx_multicast_frames)},
+	{XGBE_STATS1_INFO(tx_pause_frames)},
+	{XGBE_STATS1_INFO(tx_deferred_frames)},
+	{XGBE_STATS1_INFO(tx_collision_frames)},
+	{XGBE_STATS1_INFO(tx_single_coll_frames)},
+	{XGBE_STATS1_INFO(tx_mult_coll_frames)},
+	{XGBE_STATS1_INFO(tx_excessive_collisions)},
+	{XGBE_STATS1_INFO(tx_late_collisions)},
+	{XGBE_STATS1_INFO(tx_underrun)},
+	{XGBE_STATS1_INFO(tx_carrier_sense_errors)},
+	{XGBE_STATS1_INFO(tx_bytes)},
+	{XGBE_STATS1_INFO(tx_64byte_frames)},
+	{XGBE_STATS1_INFO(tx_65_to_127byte_frames)},
+	{XGBE_STATS1_INFO(tx_128_to_255byte_frames)},
+	{XGBE_STATS1_INFO(tx_256_to_511byte_frames)},
+	{XGBE_STATS1_INFO(tx_512_to_1023byte_frames)},
+	{XGBE_STATS1_INFO(tx_1024byte_frames)},
+	{XGBE_STATS1_INFO(net_bytes)},
+	{XGBE_STATS1_INFO(rx_sof_overruns)},
+	{XGBE_STATS1_INFO(rx_mof_overruns)},
+	{XGBE_STATS1_INFO(rx_dma_overruns)},
+	/* XGBE module 2 */
+	{XGBE_STATS2_INFO(rx_good_frames)},
+	{XGBE_STATS2_INFO(rx_broadcast_frames)},
+	{XGBE_STATS2_INFO(rx_multicast_frames)},
+	{XGBE_STATS2_INFO(rx_pause_frames)},
+	{XGBE_STATS2_INFO(rx_crc_errors)},
+	{XGBE_STATS2_INFO(rx_align_code_errors)},
+	{XGBE_STATS2_INFO(rx_oversized_frames)},
+	{XGBE_STATS2_INFO(rx_jabber_frames)},
+	{XGBE_STATS2_INFO(rx_undersized_frames)},
+	{XGBE_STATS2_INFO(rx_fragments)},
+	{XGBE_STATS2_INFO(overrun_type4)},
+	{XGBE_STATS2_INFO(overrun_type5)},
+	{XGBE_STATS2_INFO(rx_bytes)},
+	{XGBE_STATS2_INFO(tx_good_frames)},
+	{XGBE_STATS2_INFO(tx_broadcast_frames)},
+	{XGBE_STATS2_INFO(tx_multicast_frames)},
+	{XGBE_STATS2_INFO(tx_pause_frames)},
+	{XGBE_STATS2_INFO(tx_deferred_frames)},
+	{XGBE_STATS2_INFO(tx_collision_frames)},
+	{XGBE_STATS2_INFO(tx_single_coll_frames)},
+	{XGBE_STATS2_INFO(tx_mult_coll_frames)},
+	{XGBE_STATS2_INFO(tx_excessive_collisions)},
+	{XGBE_STATS2_INFO(tx_late_collisions)},
+	{XGBE_STATS2_INFO(tx_underrun)},
+	{XGBE_STATS2_INFO(tx_carrier_sense_errors)},
+	{XGBE_STATS2_INFO(tx_bytes)},
+	{XGBE_STATS2_INFO(tx_64byte_frames)},
+	{XGBE_STATS2_INFO(tx_65_to_127byte_frames)},
+	{XGBE_STATS2_INFO(tx_128_to_255byte_frames)},
+	{XGBE_STATS2_INFO(tx_256_to_511byte_frames)},
+	{XGBE_STATS2_INFO(tx_512_to_1023byte_frames)},
+	{XGBE_STATS2_INFO(tx_1024byte_frames)},
+	{XGBE_STATS2_INFO(net_bytes)},
+	{XGBE_STATS2_INFO(rx_sof_overruns)},
+	{XGBE_STATS2_INFO(rx_mof_overruns)},
+	{XGBE_STATS2_INFO(rx_dma_overruns)},
+};
+
+#define for_each_intf(i, priv) \
+	list_for_each_entry((i), &(priv)->gbe_intf_head, gbe_intf_list)
+
+#define for_each_sec_slave(slave, priv) \
+	list_for_each_entry((slave), &(priv)->secondary_slaves, slave_list)
+
+#define first_sec_slave(priv)					\
+	list_first_entry(&priv->secondary_slaves, \
+			struct gbe_slave, slave_list)
+
+static void keystone_get_drvinfo(struct net_device *ndev,
+				 struct ethtool_drvinfo *info)
+{
+	strncpy(info->driver, NETCP_DRIVER_NAME, sizeof(info->driver));
+	strncpy(info->version, NETCP_DRIVER_VERSION, sizeof(info->version));
+}
+
+static u32 keystone_get_msglevel(struct net_device *ndev)
+{
+	struct netcp_intf *netcp = netdev_priv(ndev);
+	return netcp->msg_enable;
+}
+
+static void keystone_set_msglevel(struct net_device *ndev, u32 value)
+{
+	struct netcp_intf *netcp = netdev_priv(ndev);
+	netcp->msg_enable = value;
+}
+
+static void keystone_get_stat_strings(struct net_device *ndev,
+				      uint32_t stringset, uint8_t *data)
+{
+	struct netcp_intf *netcp = netdev_priv(ndev);
+	struct gbe_intf *gbe_intf;
+	struct gbe_priv *gbe_dev;
+	int i;
+
+	gbe_intf = netcp_module_get_intf_data(&gbe_module, netcp);
+	if (!gbe_intf)
+		return;
+	gbe_dev = gbe_intf->gbe_dev;
+
+	switch (stringset) {
+	case ETH_SS_STATS:
+		for (i = 0; i < gbe_dev->num_et_stats; i++) {
+			memcpy(data, gbe_dev->et_stats[i].desc,
+			       ETH_GSTRING_LEN);
+			data += ETH_GSTRING_LEN;
+		}
+		break;
+	case ETH_SS_TEST:
+		break;
+	}
+}
+
+static int keystone_get_sset_count(struct net_device *ndev, int stringset)
+{
+	struct netcp_intf *netcp = netdev_priv(ndev);
+	struct gbe_intf *gbe_intf;
+	struct gbe_priv *gbe_dev;
+
+	gbe_intf = netcp_module_get_intf_data(&gbe_module, netcp);
+	if (!gbe_intf)
+		return -EINVAL;
+	gbe_dev = gbe_intf->gbe_dev;
+
+	switch (stringset) {
+	case ETH_SS_TEST:
+		return 0;
+	case ETH_SS_STATS:
+		return gbe_dev->num_et_stats;
+	default:
+		return -EINVAL;
+	}
+}
+
+static void gbe_update_stats(struct gbe_priv *gbe_dev, uint64_t *data)
+{
+	void __iomem *base = NULL;
+	u32  __iomem *p;
+	u32 tmp = 0;
+	int i;
+
+	for (i = 0; i < gbe_dev->num_et_stats; i++) {
+		base = gbe_dev->hw_stats_regs[gbe_dev->et_stats[i].type];
+		p = base + gbe_dev->et_stats[i].offset;
+		tmp = readl_relaxed(p);
+		gbe_dev->hw_stats[i] = gbe_dev->hw_stats[i] + tmp;
+		if (data)
+			data[i] = gbe_dev->hw_stats[i];
+		/* write-to-decrement:
+		 * new register value = old register value - write value
+		 */
+		writel_relaxed(tmp, p);
+	}
+	return;
+}
+
+static void gbe_update_stats_ver14(struct gbe_priv *gbe_dev, uint64_t *data)
+{
+	void __iomem *gbe_statsa = gbe_dev->hw_stats_regs[0];
+	void __iomem *gbe_statsb = gbe_dev->hw_stats_regs[1];
+	u64 *hw_stats = &gbe_dev->hw_stats[0];
+	void __iomem *base = NULL;
+	u32  __iomem *p;
+	u32 tmp = 0, val, pair_size = (gbe_dev->num_et_stats / 2);
+	int i, j, pair;
+
+	for (pair = 0; pair < 2; pair++) {
+		val = readl_relaxed(GBE_REG_ADDR(gbe_dev, switch_regs,
+						 stat_port_en));
+
+		if (pair == 0)
+			val &= ~GBE_STATS_CD_SEL;
+		else
+			val |= GBE_STATS_CD_SEL;
+
+		/* make the stat modules visible */
+		writel_relaxed(val, GBE_REG_ADDR(gbe_dev, switch_regs,
+						 stat_port_en));
+
+		for (i = 0; i < pair_size; i++) {
+			j = pair * pair_size + i;
+			switch (gbe_dev->et_stats[j].type) {
+			case GBE_STATSA_MODULE:
+			case GBE_STATSC_MODULE:
+				base = gbe_statsa;
+			break;
+			case GBE_STATSB_MODULE:
+			case GBE_STATSD_MODULE:
+				base  = gbe_statsb;
+			break;
+			}
+
+			p = base + gbe_dev->et_stats[j].offset;
+			tmp = readl_relaxed(p);
+			hw_stats[j] += tmp;
+			if (data)
+				data[j] = hw_stats[j];
+			/* write-to-decrement:
+			 * new register value = old register value - write value
+			 */
+			writel_relaxed(tmp, p);
+		}
+	}
+}
+
+static void keystone_get_ethtool_stats(struct net_device *ndev,
+				       struct ethtool_stats *stats,
+				       uint64_t *data)
+{
+	struct netcp_intf *netcp = netdev_priv(ndev);
+	struct gbe_intf *gbe_intf;
+	struct gbe_priv *gbe_dev;
+
+	gbe_intf = netcp_module_get_intf_data(&gbe_module, netcp);
+	if (!gbe_intf)
+		return;
+
+	gbe_dev = gbe_intf->gbe_dev;
+	spin_lock_bh(&gbe_dev->hw_stats_lock);
+	if (gbe_dev->ss_version == GBE_SS_VERSION_14)
+		gbe_update_stats_ver14(gbe_dev, data);
+	else
+		gbe_update_stats(gbe_dev, data);
+	spin_unlock_bh(&gbe_dev->hw_stats_lock);
+	return;
+}
+
+static int keystone_get_settings(struct net_device *ndev,
+				 struct ethtool_cmd *cmd)
+{
+	struct netcp_intf *netcp = netdev_priv(ndev);
+	struct phy_device *phy = ndev->phydev;
+	struct gbe_intf *gbe_intf;
+	int ret;
+
+	if (!phy)
+		return -EINVAL;
+
+	gbe_intf = netcp_module_get_intf_data(&gbe_module, netcp);
+	if (!gbe_intf)
+		return -EINVAL;
+
+	if (!gbe_intf->slave)
+		return -EINVAL;
+
+	ret = phy_ethtool_gset(phy, cmd);
+	if (!ret)
+		cmd->port = gbe_intf->slave->phy_port_t;
+
+	return ret;
+}
+
+static int keystone_set_settings(struct net_device *ndev,
+				 struct ethtool_cmd *cmd)
+{
+	struct netcp_intf *netcp = netdev_priv(ndev);
+	struct phy_device *phy = ndev->phydev;
+	struct gbe_intf *gbe_intf;
+	u32 features = cmd->advertising & cmd->supported;
+
+	if (!phy)
+		return -EINVAL;
+
+	gbe_intf = netcp_module_get_intf_data(&gbe_module, netcp);
+	if (!gbe_intf)
+		return -EINVAL;
+
+	if (!gbe_intf->slave)
+		return -EINVAL;
+
+	if (cmd->port != gbe_intf->slave->phy_port_t) {
+		if ((cmd->port == PORT_TP) && !(features & ADVERTISED_TP))
+			return -EINVAL;
+
+		if ((cmd->port == PORT_AUI) && !(features & ADVERTISED_AUI))
+			return -EINVAL;
+
+		if ((cmd->port == PORT_BNC) && !(features & ADVERTISED_BNC))
+			return -EINVAL;
+
+		if ((cmd->port == PORT_MII) && !(features & ADVERTISED_MII))
+			return -EINVAL;
+
+		if ((cmd->port == PORT_FIBRE) && !(features & ADVERTISED_FIBRE))
+			return -EINVAL;
+	}
+
+	gbe_intf->slave->phy_port_t = cmd->port;
+	return phy_ethtool_sset(phy, cmd);
+}
+
+static const struct ethtool_ops keystone_ethtool_ops = {
+	.get_drvinfo		= keystone_get_drvinfo,
+	.get_link		= ethtool_op_get_link,
+	.get_msglevel		= keystone_get_msglevel,
+	.set_msglevel		= keystone_set_msglevel,
+	.get_strings		= keystone_get_stat_strings,
+	.get_sset_count		= keystone_get_sset_count,
+	.get_ethtool_stats	= keystone_get_ethtool_stats,
+	.get_settings		= keystone_get_settings,
+	.set_settings		= keystone_set_settings,
+};
+
+#define mac_hi(mac)	(((mac)[0] << 0) | ((mac)[1] << 8) |	\
+			 ((mac)[2] << 16) | ((mac)[3] << 24))
+#define mac_lo(mac)	(((mac)[4] << 0) | ((mac)[5] << 8))
+
+static void gbe_set_slave_mac(struct gbe_slave *slave,
+			      struct gbe_intf *gbe_intf)
+{
+	struct net_device *ndev = gbe_intf->ndev;
+
+	writel_relaxed(mac_hi(ndev->dev_addr),
+		       GBE_REG_ADDR(slave, port_regs, sa_hi));
+	writel_relaxed(mac_lo(ndev->dev_addr),
+		       GBE_REG_ADDR(slave, port_regs, sa_lo));
+}
+
+static inline int gbe_get_slave_port(struct gbe_priv *priv, u32 slave_num)
+{
+	if (priv->host_port == 0)
+		return slave_num + 1;
+	else
+		return slave_num;
+}
+
+static inline void netcp_ethss_link_state_action(struct gbe_priv *gbe_dev,
+						 struct net_device *ndev,
+						 struct gbe_slave *slave,
+						 int up)
+{
+	struct phy_device *phy = slave->phy;
+	u32 mac_control = 0;
+
+	if (up) {
+		mac_control = slave->mac_control;
+		if (phy && (phy->speed == SPEED_1000)) {
+			mac_control |= MACSL_GIG_MODE;
+			mac_control &= ~MACSL_XGIG_MODE;
+		} else if (phy && (phy->speed == SPEED_10000)) {
+			mac_control |= MACSL_XGIG_MODE;
+			mac_control &= ~MACSL_GIG_MODE;
+		}
+
+		writel_relaxed(mac_control,
+			       GBE_REG_ADDR(slave, emac_regs, mac_control));
+
+		cpsw_ale_control_set(gbe_dev->ale, slave->port_num,
+				     ALE_PORT_STATE,
+				     ALE_PORT_STATE_FORWARD);
+
+		if (ndev && slave->open)
+			netif_carrier_on(ndev);
+	} else {
+		writel_relaxed(mac_control,
+			       GBE_REG_ADDR(slave, emac_regs, mac_control));
+		cpsw_ale_control_set(gbe_dev->ale, slave->port_num,
+				     ALE_PORT_STATE,
+				     ALE_PORT_STATE_DISABLE);
+		if (ndev)
+			netif_carrier_off(ndev);
+	}
+
+	if (phy)
+		phy_print_status(phy);
+}
+
+static inline int gbe_phy_link_status(struct gbe_slave *slave)
+{
+	if (!slave->phy)
+		return 1;
+
+	if (slave->phy->link)
+		return 1;
+	else
+		return 0;
+}
+
+static inline void netcp_ethss_update_link_state(struct gbe_priv *gbe_dev,
+						 struct gbe_slave *slave,
+						 struct net_device *ndev)
+{
+	int sp = slave->slave_num;
+	int phy_link_state, sgmii_link_state = 1, link_state;
+
+	if (!slave->open)
+		return;
+
+	if (!SLAVE_LINK_IS_XGMII(slave))
+		sgmii_link_state = netcp_sgmii_get_port_link(SGMII_BASE(sp),
+							     sp);
+	phy_link_state = gbe_phy_link_status(slave);
+	link_state = phy_link_state & sgmii_link_state;
+
+	if (atomic_xchg(&slave->link_state, link_state) != link_state)
+		netcp_ethss_link_state_action(gbe_dev, ndev, slave,
+					      link_state);
+}
+
+static void xgbe_adjust_link(struct net_device *ndev)
+{
+	struct netcp_intf *netcp = netdev_priv(ndev);
+	struct gbe_intf *gbe_intf;
+
+	gbe_intf = netcp_module_get_intf_data(&xgbe_module, netcp);
+	if (!gbe_intf)
+		return;
+
+	netcp_ethss_update_link_state(gbe_intf->gbe_dev, gbe_intf->slave,
+				      ndev);
+}
+
+static void gbe_adjust_link(struct net_device *ndev)
+{
+	struct netcp_intf *netcp = netdev_priv(ndev);
+	struct gbe_intf *gbe_intf;
+
+	gbe_intf = netcp_module_get_intf_data(&gbe_module, netcp);
+	if (!gbe_intf)
+		return;
+
+	netcp_ethss_update_link_state(gbe_intf->gbe_dev, gbe_intf->slave,
+				      ndev);
+}
+
+static void gbe_adjust_link_sec_slaves(struct net_device *ndev)
+{
+	struct gbe_priv *gbe_dev = netdev_priv(ndev);
+	struct gbe_slave *slave;
+
+	for_each_sec_slave(slave, gbe_dev)
+		netcp_ethss_update_link_state(gbe_dev, slave, NULL);
+}
+
+/* Reset EMAC
+ * Soft reset is set and polled until clear, or until a timeout occurs
+ */
+static int gbe_port_reset(struct gbe_slave *slave)
+{
+	u32 i, v;
+
+	/* Set the soft reset bit */
+	writel_relaxed(SOFT_RESET, GBE_REG_ADDR(slave, emac_regs, soft_reset));
+
+	/* Wait for the bit to clear */
+	for (i = 0; i < DEVICE_EMACSL_RESET_POLL_COUNT; i++) {
+		v = readl_relaxed(GBE_REG_ADDR(slave, emac_regs, soft_reset));
+		if ((v & SOFT_RESET_MASK) != SOFT_RESET)
+			return 0;
+	}
+
+	/* Timeout on the reset */
+	return GMACSL_RET_WARN_RESET_INCOMPLETE;
+}
+
+/* Configure EMAC */
+static void gbe_port_config(struct gbe_priv *gbe_dev, struct gbe_slave *slave,
+			    int max_rx_len)
+{
+	u32 xgmii_mode;
+
+	if (max_rx_len > NETCP_MAX_FRAME_SIZE)
+		max_rx_len = NETCP_MAX_FRAME_SIZE;
+
+	/* Enable correct MII mode at SS level */
+	if ((gbe_dev->ss_version == XGBE_SS_VERSION_10) &&
+	    (slave->link_interface >= XGMII_LINK_MAC_PHY)) {
+		xgmii_mode = readl_relaxed(GBE_REG_ADDR(gbe_dev, ss_regs,
+							control));
+		xgmii_mode |= (1 << slave->slave_num);
+		writel_relaxed(xgmii_mode, GBE_REG_ADDR(gbe_dev, ss_regs,
+							control));
+	}
+
+	writel_relaxed(max_rx_len, GBE_REG_ADDR(slave, emac_regs, rx_maxlen));
+	writel_relaxed(slave->mac_control,
+		       GBE_REG_ADDR(slave, emac_regs, mac_control));
+}
+
+static void gbe_slave_stop(struct gbe_intf *intf)
+{
+	struct gbe_priv *gbe_dev = intf->gbe_dev;
+	struct gbe_slave *slave = intf->slave;
+
+	gbe_port_reset(slave);
+	/* Disable forwarding */
+	cpsw_ale_control_set(gbe_dev->ale, slave->port_num,
+			     ALE_PORT_STATE, ALE_PORT_STATE_DISABLE);
+	cpsw_ale_del_mcast(gbe_dev->ale, intf->ndev->broadcast,
+			   1 << slave->port_num, 0, 0);
+
+
+	if (!slave->phy)
+		return;
+
+	phy_stop(slave->phy);
+	phy_disconnect(slave->phy);
+	slave->phy = NULL;
+}
+
+static void gbe_sgmii_config(struct gbe_priv *priv, struct gbe_slave *slave)
+{
+	void __iomem *sgmii_port_regs;
+
+	sgmii_port_regs = priv->sgmii_port_regs;
+	if ((priv->ss_version == GBE_SS_VERSION_14) && (slave->slave_num >= 2))
+		sgmii_port_regs = priv->sgmii_port34_regs;
+
+	if (!SLAVE_LINK_IS_XGMII(slave)) {
+		netcp_sgmii_reset(sgmii_port_regs, slave->slave_num);
+		netcp_sgmii_config(sgmii_port_regs, slave->slave_num,
+				   slave->link_interface);
+	}
+}
+
+static int gbe_slave_open(struct gbe_intf *gbe_intf)
+{
+	struct gbe_priv *priv = gbe_intf->gbe_dev;
+	struct gbe_slave *slave = gbe_intf->slave;
+	void (*hndlr)(struct net_device *) = gbe_adjust_link;
+	phy_interface_t phy_mode;
+	bool has_phy = false;
+
+	gbe_sgmii_config(priv, slave);
+	gbe_port_reset(slave);
+	gbe_port_config(priv, slave, priv->rx_packet_max);
+	gbe_set_slave_mac(slave, gbe_intf);
+	/* enable forwarding */
+	cpsw_ale_control_set(priv->ale, slave->port_num,
+			     ALE_PORT_STATE, ALE_PORT_STATE_FORWARD);
+	cpsw_ale_add_mcast(priv->ale, gbe_intf->ndev->broadcast,
+			   1 << slave->port_num, 0, 0, ALE_MCAST_FWD_2);
+
+	if (slave->link_interface == SGMII_LINK_MAC_PHY) {
+		has_phy = true;
+		phy_mode = PHY_INTERFACE_MODE_SGMII;
+		slave->phy_port_t = PORT_MII;
+	} else if (slave->link_interface == XGMII_LINK_MAC_PHY) {
+		has_phy = true;
+		phy_mode = PHY_INTERFACE_MODE_NA;
+		slave->phy_port_t = PORT_FIBRE;
+	}
+
+	if (has_phy) {
+		if (priv->ss_version == XGBE_SS_VERSION_10)
+			hndlr = xgbe_adjust_link;
+
+		slave->phy = of_phy_connect(gbe_intf->ndev,
+					    slave->phy_node,
+					    hndlr, 0,
+					    phy_mode);
+		if (!slave->phy) {
+			dev_err(priv->dev, "phy not found on slave %d\n",
+				slave->slave_num);
+			return -ENODEV;
+		} else {
+			dev_dbg(priv->dev, "phy found: id is: 0x%s\n",
+				 dev_name(&slave->phy->dev));
+			phy_start(slave->phy);
+			phy_read_status(slave->phy);
+		}
+	}
+	return 0;
+}
+
+static void gbe_init_host_port(struct gbe_priv *priv)
+{
+	int bypass_en = 1;
+	/* Max length register */
+	writel_relaxed(NETCP_MAX_FRAME_SIZE,
+		       GBE_REG_ADDR(priv, host_port_regs, rx_maxlen));
+
+	cpsw_ale_start(priv->ale);
+
+	if (priv->enable_ale)
+		bypass_en = 0;
+
+	cpsw_ale_control_set(priv->ale, 0, ALE_BYPASS, bypass_en);
+
+	cpsw_ale_control_set(priv->ale, 0, ALE_NO_PORT_VLAN, 1);
+
+	cpsw_ale_control_set(priv->ale, priv->host_port,
+			     ALE_PORT_STATE, ALE_PORT_STATE_FORWARD);
+
+	cpsw_ale_control_set(priv->ale, 0,
+			     ALE_PORT_UNKNOWN_VLAN_MEMBER,
+			     GBE_PORT_MASK(priv->ale_ports));
+
+	cpsw_ale_control_set(priv->ale, 0,
+			     ALE_PORT_UNKNOWN_MCAST_FLOOD,
+			     GBE_PORT_MASK(priv->ale_ports - 1));
+
+	cpsw_ale_control_set(priv->ale, 0,
+			     ALE_PORT_UNKNOWN_REG_MCAST_FLOOD,
+			     GBE_PORT_MASK(priv->ale_ports));
+
+	cpsw_ale_control_set(priv->ale, 0,
+			     ALE_PORT_UNTAGGED_EGRESS,
+			     GBE_PORT_MASK(priv->ale_ports));
+}
+
+static void gbe_add_mcast_addr(struct gbe_intf *gbe_intf, u8 *addr)
+{
+	struct gbe_priv *gbe_dev = gbe_intf->gbe_dev;
+	u16 vlan_id;
+
+	cpsw_ale_add_mcast(gbe_dev->ale, addr,
+			   GBE_PORT_MASK(gbe_dev->ale_ports), 0, 0,
+			   ALE_MCAST_FWD_2);
+	for_each_set_bit(vlan_id, gbe_intf->active_vlans, VLAN_N_VID) {
+		cpsw_ale_add_mcast(gbe_dev->ale, addr,
+				   GBE_PORT_MASK(gbe_dev->ale_ports),
+				   ALE_VLAN, vlan_id, ALE_MCAST_FWD_2);
+	}
+}
+
+static void gbe_add_ucast_addr(struct gbe_intf *gbe_intf, u8 *addr)
+{
+	struct gbe_priv *gbe_dev = gbe_intf->gbe_dev;
+	u16 vlan_id;
+
+	cpsw_ale_add_ucast(gbe_dev->ale, addr, gbe_dev->host_port, 0, 0);
+
+	for_each_set_bit(vlan_id, gbe_intf->active_vlans, VLAN_N_VID)
+		cpsw_ale_add_ucast(gbe_dev->ale, addr, gbe_dev->host_port,
+				   ALE_VLAN, vlan_id);
+}
+
+static void gbe_del_mcast_addr(struct gbe_intf *gbe_intf, u8 *addr)
+{
+	struct gbe_priv *gbe_dev = gbe_intf->gbe_dev;
+	u16 vlan_id;
+
+	cpsw_ale_del_mcast(gbe_dev->ale, addr, 0, 0, 0);
+
+	for_each_set_bit(vlan_id, gbe_intf->active_vlans, VLAN_N_VID) {
+		cpsw_ale_del_mcast(gbe_dev->ale, addr, 0, ALE_VLAN, vlan_id);
+	}
+}
+
+static void gbe_del_ucast_addr(struct gbe_intf *gbe_intf, u8 *addr)
+{
+	struct gbe_priv *gbe_dev = gbe_intf->gbe_dev;
+	u16 vlan_id;
+
+	cpsw_ale_del_ucast(gbe_dev->ale, addr, gbe_dev->host_port, 0, 0);
+
+	for_each_set_bit(vlan_id, gbe_intf->active_vlans, VLAN_N_VID) {
+		cpsw_ale_del_ucast(gbe_dev->ale, addr, gbe_dev->host_port,
+				   ALE_VLAN, vlan_id);
+	}
+}
+
+static int gbe_add_addr(void *intf_priv, struct netcp_addr *naddr)
+{
+	struct gbe_intf *gbe_intf = intf_priv;
+	struct gbe_priv *gbe_dev = gbe_intf->gbe_dev;
+
+	dev_dbg(gbe_dev->dev, "ethss adding address %pM, type %d\n",
+		naddr->addr, naddr->type);
+
+	switch (naddr->type) {
+	case ADDR_MCAST:
+	case ADDR_BCAST:
+		gbe_add_mcast_addr(gbe_intf, naddr->addr);
+		break;
+	case ADDR_UCAST:
+	case ADDR_DEV:
+		gbe_add_ucast_addr(gbe_intf, naddr->addr);
+		break;
+	case ADDR_ANY:
+		/* nothing to do for promiscuous */
+	default:
+		break;
+	}
+
+	return 0;
+}
+
+static int gbe_del_addr(void *intf_priv, struct netcp_addr *naddr)
+{
+	struct gbe_intf *gbe_intf = intf_priv;
+	struct gbe_priv *gbe_dev = gbe_intf->gbe_dev;
+
+	dev_dbg(gbe_dev->dev, "ethss deleting address %pM, type %d\n",
+		naddr->addr, naddr->type);
+
+	switch (naddr->type) {
+	case ADDR_MCAST:
+	case ADDR_BCAST:
+		gbe_del_mcast_addr(gbe_intf, naddr->addr);
+		break;
+	case ADDR_UCAST:
+	case ADDR_DEV:
+		gbe_del_ucast_addr(gbe_intf, naddr->addr);
+		break;
+	case ADDR_ANY:
+		/* nothing to do for promiscuous */
+	default:
+		break;
+	}
+
+	return 0;
+}
+
+static int gbe_add_vid(void *intf_priv, int vid)
+{
+	struct gbe_intf *gbe_intf = intf_priv;
+	struct gbe_priv *gbe_dev = gbe_intf->gbe_dev;
+
+	set_bit(vid, gbe_intf->active_vlans);
+
+	cpsw_ale_add_vlan(gbe_dev->ale, vid,
+			  GBE_PORT_MASK(gbe_dev->ale_ports),
+			  GBE_MASK_NO_PORTS,
+			  GBE_PORT_MASK(gbe_dev->ale_ports),
+			  GBE_PORT_MASK(gbe_dev->ale_ports - 1));
+
+	return 0;
+}
+
+static int gbe_del_vid(void *intf_priv, int vid)
+{
+	struct gbe_intf *gbe_intf = intf_priv;
+	struct gbe_priv *gbe_dev = gbe_intf->gbe_dev;
+
+	cpsw_ale_del_vlan(gbe_dev->ale, vid, 0);
+	clear_bit(vid, gbe_intf->active_vlans);
+	return 0;
+}
+
+static int gbe_ioctl(void *intf_priv, struct ifreq *req, int cmd)
+{
+	struct gbe_intf *gbe_intf = intf_priv;
+	struct phy_device *phy = gbe_intf->slave->phy;
+	int ret = -EOPNOTSUPP;
+
+	if (phy)
+		ret = phy_mii_ioctl(phy, req, cmd);
+
+	return ret;
+}
+
+static void netcp_ethss_timer(unsigned long arg)
+{
+	struct gbe_priv *gbe_dev = (struct gbe_priv *)arg;
+	struct gbe_intf *gbe_intf;
+	struct gbe_slave *slave;
+
+	/* Check & update SGMII link state of interfaces */
+	for_each_intf(gbe_intf, gbe_dev) {
+		if (!gbe_intf->slave->open)
+			continue;
+		netcp_ethss_update_link_state(gbe_dev, gbe_intf->slave,
+					      gbe_intf->ndev);
+	}
+
+	/* Check & update SGMII link state of secondary ports */
+	for_each_sec_slave(slave, gbe_dev) {
+		netcp_ethss_update_link_state(gbe_dev, slave, NULL);
+	}
+
+	spin_lock_bh(&gbe_dev->hw_stats_lock);
+
+	if (gbe_dev->ss_version == GBE_SS_VERSION_14)
+		gbe_update_stats_ver14(gbe_dev, NULL);
+	else
+		gbe_update_stats(gbe_dev, NULL);
+
+	spin_unlock_bh(&gbe_dev->hw_stats_lock);
+
+	gbe_dev->timer.expires	= jiffies + GBE_TIMER_INTERVAL;
+	add_timer(&gbe_dev->timer);
+	return;
+}
+
+static int gbe_tx_hook(int order, void *data, struct netcp_packet *p_info)
+{
+	struct gbe_intf *gbe_intf = data;
+	p_info->tx_pipe = &gbe_intf->tx_pipe;
+	return 0;
+}
+
+static int gbe_open(void *intf_priv, struct net_device *ndev)
+{
+	struct gbe_intf *gbe_intf = intf_priv;
+	struct gbe_priv *gbe_dev = gbe_intf->gbe_dev;
+	struct netcp_intf *netcp = netdev_priv(ndev);
+	struct gbe_slave *slave = gbe_intf->slave;
+	int port_num = slave->port_num;
+	u32 reg;
+	int ret;
+
+	reg = readl_relaxed(GBE_REG_ADDR(gbe_dev, switch_regs, id_ver));
+	dev_dbg(gbe_dev->dev, "initializing gbe version %d.%d (%d) GBE identification value 0x%x\n",
+		 GBE_MAJOR_VERSION(reg), GBE_MINOR_VERSION(reg),
+		 GBE_RTL_VERSION(reg), GBE_IDENT(reg));
+
+	if (gbe_dev->enable_ale)
+		gbe_intf->tx_pipe.dma_psflags = 0;
+	else
+		gbe_intf->tx_pipe.dma_psflags = port_num;
+
+
+	dev_dbg(gbe_dev->dev, "opened TX channel %d: %p with psflags %d\n",
+		gbe_intf->tx_pipe.dma_chan_id,
+		gbe_intf->tx_pipe.dma_channel,
+		gbe_intf->tx_pipe.dma_psflags);
+
+	gbe_slave_stop(gbe_intf);
+
+	/* disable priority elevation and enable statistics on all ports */
+	writel_relaxed(0, GBE_REG_ADDR(gbe_dev, switch_regs, ptype));
+
+	/* Control register */
+	writel_relaxed(GBE_CTL_P0_ENABLE, GBE_REG_ADDR(gbe_dev, switch_regs,
+						       control));
+
+	/* All statistics enabled and STAT AB visible by default */
+	writel_relaxed(GBE_REG_VAL_STAT_ENABLE_ALL,
+		       GBE_REG_ADDR(gbe_dev, switch_regs, stat_port_en));
+
+	ret = gbe_slave_open(gbe_intf);
+	if (ret)
+		goto fail;
+
+	netcp_register_txhook(netcp, GBE_TXHOOK_ORDER, gbe_tx_hook,
+			      gbe_intf);
+
+	slave->open = true;
+	netcp_ethss_update_link_state(gbe_dev, slave, ndev);
+	return 0;
+
+fail:
+	gbe_slave_stop(gbe_intf);
+	return ret;
+}
+
+static int gbe_close(void *intf_priv, struct net_device *ndev)
+{
+	struct gbe_intf *gbe_intf = intf_priv;
+	struct netcp_intf *netcp = netdev_priv(ndev);
+
+	gbe_slave_stop(gbe_intf);
+	netcp_unregister_txhook(netcp, GBE_TXHOOK_ORDER, gbe_tx_hook,
+				gbe_intf);
+
+	gbe_intf->slave->open = false;
+	atomic_set(&gbe_intf->slave->link_state, NETCP_LINK_STATE_INVALID);
+	return 0;
+}
+
+static int init_slave(struct gbe_priv *gbe_dev, struct gbe_slave *slave,
+		      struct device_node *node)
+{
+	int port_reg_num;
+	u32 port_reg_ofs, emac_reg_ofs;
+
+	if (of_property_read_u32(node, "slave-port", &slave->slave_num)) {
+		dev_err(gbe_dev->dev, "missing slave-port paramater\n");
+		return -EINVAL;
+	}
+
+	if (of_property_read_u32(node, "link-interface",
+				 &slave->link_interface)) {
+		dev_warn(gbe_dev->dev, "missing link-interface value defaulting to 1G mac-phy link\n");
+		slave->link_interface = SGMII_LINK_MAC_PHY;
+	}
+
+	slave->open = false;
+	slave->phy_node = of_parse_phandle(node, "phy-handle", 0);
+	slave->port_num = gbe_get_slave_port(gbe_dev, slave->slave_num);
+
+	if (slave->link_interface >= XGMII_LINK_MAC_PHY)
+		slave->mac_control = GBE_DEF_10G_MAC_CONTROL;
+	else
+		slave->mac_control = GBE_DEF_1G_MAC_CONTROL;
+
+	/* Emac regs memmap are contiguous but port regs are not */
+	port_reg_num = slave->slave_num;
+	if (gbe_dev->ss_version == GBE_SS_VERSION_14) {
+		if (slave->slave_num > 1) {
+			port_reg_ofs = GBE13_SLAVE_PORT2_OFFSET;
+			port_reg_num -= 2;
+		} else {
+			port_reg_ofs = GBE13_SLAVE_PORT_OFFSET;
+		}
+	} else if (gbe_dev->ss_version == XGBE_SS_VERSION_10) {
+		port_reg_ofs = XGBE10_SLAVE_PORT_OFFSET;
+	} else {
+		dev_err(gbe_dev->dev, "unknown ethss(0x%x)\n",
+			gbe_dev->ss_version);
+		return -EINVAL;
+	}
+
+	if (gbe_dev->ss_version == GBE_SS_VERSION_14)
+		emac_reg_ofs = GBE13_EMAC_OFFSET;
+	else if (gbe_dev->ss_version == XGBE_SS_VERSION_10)
+		emac_reg_ofs = XGBE10_EMAC_OFFSET;
+
+	slave->port_regs = gbe_dev->ss_regs + port_reg_ofs +
+				(0x30 * port_reg_num);
+	slave->emac_regs = gbe_dev->ss_regs + emac_reg_ofs +
+				(0x40 * slave->slave_num);
+
+	if (gbe_dev->ss_version == GBE_SS_VERSION_14) {
+		/* Initialize  slave port register offsets */
+		GBE_SET_REG_OFS(slave, port_regs, port_vlan);
+		GBE_SET_REG_OFS(slave, port_regs, tx_pri_map);
+		GBE_SET_REG_OFS(slave, port_regs, sa_lo);
+		GBE_SET_REG_OFS(slave, port_regs, sa_hi);
+		GBE_SET_REG_OFS(slave, port_regs, ts_ctl);
+		GBE_SET_REG_OFS(slave, port_regs, ts_seq_ltype);
+		GBE_SET_REG_OFS(slave, port_regs, ts_vlan);
+		GBE_SET_REG_OFS(slave, port_regs, ts_ctl_ltype2);
+		GBE_SET_REG_OFS(slave, port_regs, ts_ctl2);
+
+		/* Initialize EMAC register offsets */
+		GBE_SET_REG_OFS(slave, emac_regs, mac_control);
+		GBE_SET_REG_OFS(slave, emac_regs, soft_reset);
+		GBE_SET_REG_OFS(slave, emac_regs, rx_maxlen);
+
+	} else if (gbe_dev->ss_version == XGBE_SS_VERSION_10) {
+		/* Initialize  slave port register offsets */
+		XGBE_SET_REG_OFS(slave, port_regs, port_vlan);
+		XGBE_SET_REG_OFS(slave, port_regs, tx_pri_map);
+		XGBE_SET_REG_OFS(slave, port_regs, sa_lo);
+		XGBE_SET_REG_OFS(slave, port_regs, sa_hi);
+		XGBE_SET_REG_OFS(slave, port_regs, ts_ctl);
+		XGBE_SET_REG_OFS(slave, port_regs, ts_seq_ltype);
+		XGBE_SET_REG_OFS(slave, port_regs, ts_vlan);
+		XGBE_SET_REG_OFS(slave, port_regs, ts_ctl_ltype2);
+		XGBE_SET_REG_OFS(slave, port_regs, ts_ctl2);
+
+		/* Initialize EMAC register offsets */
+		XGBE_SET_REG_OFS(slave, emac_regs, mac_control);
+		XGBE_SET_REG_OFS(slave, emac_regs, soft_reset);
+		XGBE_SET_REG_OFS(slave, emac_regs, rx_maxlen);
+	}
+
+	atomic_set(&slave->link_state, NETCP_LINK_STATE_INVALID);
+	return 0;
+}
+
+static void init_secondary_ports(struct gbe_priv *gbe_dev,
+				 struct device_node *node)
+{
+	struct device *dev = gbe_dev->dev;
+	phy_interface_t phy_mode;
+	struct gbe_priv **priv;
+	struct device_node *port;
+	struct gbe_slave *slave;
+	bool mac_phy_link = false;
+
+	for_each_child_of_node(node, port) {
+		slave = devm_kzalloc(dev, sizeof(*slave), GFP_KERNEL);
+		if (!slave) {
+			dev_err(dev, "memomry alloc failed for secondary port(%s), skipping...\n",
+				port->name);
+			continue;
+		}
+
+		if (init_slave(gbe_dev, slave, port)) {
+			dev_err(dev, "Failed to initialize secondary port(%s), skipping...\n",
+				port->name);
+			devm_kfree(dev, slave);
+			continue;
+		}
+
+		gbe_sgmii_config(gbe_dev, slave);
+		gbe_port_reset(slave);
+		gbe_port_config(gbe_dev, slave, gbe_dev->rx_packet_max);
+		list_add_tail(&slave->slave_list, &gbe_dev->secondary_slaves);
+		gbe_dev->num_slaves++;
+		if ((slave->link_interface == SGMII_LINK_MAC_PHY) ||
+		    (slave->link_interface == XGMII_LINK_MAC_PHY))
+			mac_phy_link = true;
+
+		slave->open = true;
+	}
+
+	/* of_phy_connect() is needed only for MAC-PHY interface */
+	if (!mac_phy_link)
+		return;
+
+	/* Allocate dummy netdev device for attaching to phy device */
+	gbe_dev->dummy_ndev = alloc_netdev(sizeof(gbe_dev), "dummy",
+					    ether_setup);
+	if (!gbe_dev->dummy_ndev) {
+		dev_err(dev, "Failed to allocate dummy netdev for secondary ports, skipping phy_connect()...\n");
+		return;
+	}
+	priv = netdev_priv(gbe_dev->dummy_ndev);
+	*priv = gbe_dev;
+
+	if (slave->link_interface == SGMII_LINK_MAC_PHY) {
+		phy_mode = PHY_INTERFACE_MODE_SGMII;
+		slave->phy_port_t = PORT_MII;
+	} else {
+		phy_mode = PHY_INTERFACE_MODE_NA;
+		slave->phy_port_t = PORT_FIBRE;
+	}
+
+	for_each_sec_slave(slave, gbe_dev) {
+		if ((slave->link_interface != SGMII_LINK_MAC_PHY) &&
+		    (slave->link_interface != XGMII_LINK_MAC_PHY))
+			continue;
+		slave->phy =
+			of_phy_connect(gbe_dev->dummy_ndev,
+				       slave->phy_node,
+				       gbe_adjust_link_sec_slaves,
+				       0, phy_mode);
+		if (IS_ERR_OR_NULL(slave->phy)) {
+			dev_err(dev, "phy not found for slave %d\n",
+				slave->slave_num);
+			slave->phy = NULL;
+		} else {
+			dev_dbg(dev, "phy found: id is: 0x%s\n",
+				 dev_name(&slave->phy->dev));
+			phy_start(slave->phy);
+			phy_read_status(slave->phy);
+		}
+	}
+	return;
+}
+
+static void free_secondary_ports(struct gbe_priv *gbe_dev)
+{
+	struct gbe_slave *slave;
+
+	for (;;) {
+		slave = first_sec_slave(gbe_dev);
+		if (!slave)
+			break;
+		if (slave->phy)
+			phy_disconnect(slave->phy);
+		list_del(&slave->slave_list);
+	}
+	if (gbe_dev->dummy_ndev)
+		free_netdev(gbe_dev->dummy_ndev);
+}
+
+static int set_xgbe_ethss10_priv(struct gbe_priv *gbe_dev,
+				 struct device_node *node)
+{
+	struct resource res;
+	void __iomem *regs;
+	int ret, i;
+
+	ret = of_address_to_resource(node, 0, &res);
+	if (ret) {
+		dev_err(gbe_dev->dev, "Can't translate of node(%s) address for xgbe subsystem regs\n",
+			node->name);
+		return ret;
+	}
+
+	regs = devm_ioremap_resource(gbe_dev->dev, &res);
+	if (IS_ERR(regs)) {
+		dev_err(gbe_dev->dev, "Failed to map xgbe register base\n");
+		return PTR_ERR(regs);
+	}
+	gbe_dev->ss_regs = regs;
+
+	ret = of_address_to_resource(node, XGBE_SERDES_REG_INDEX, &res);
+	if (ret) {
+		dev_err(gbe_dev->dev, "Can't translate of node(%s) address for xgbe serdes regs\n",
+			node->name);
+		return ret;
+	}
+
+	regs = devm_ioremap_resource(gbe_dev->dev, &res);
+	if (IS_ERR(regs)) {
+		dev_err(gbe_dev->dev, "Failed to map xgbe serdes register base\n");
+		return PTR_ERR(regs);
+	}
+	gbe_dev->xgbe_serdes_regs = regs;
+
+	gbe_dev->hw_stats = devm_kzalloc(gbe_dev->dev,
+					  XGBE10_NUM_STAT_ENTRIES *
+					  XGBE10_NUM_SLAVES * sizeof(u64),
+					  GFP_KERNEL);
+	if (!gbe_dev->hw_stats) {
+		dev_err(gbe_dev->dev, "hw_stats memory allocation failed\n");
+		return -ENOMEM;
+	}
+
+	gbe_dev->ss_version = XGBE_SS_VERSION_10;
+	gbe_dev->sgmii_port_regs = regs + XGBE10_SGMII_MODULE_OFFSET;
+	gbe_dev->switch_regs = regs + XGBE10_SWITCH_MODULE_OFFSET;
+	gbe_dev->host_port_regs = regs + XGBE10_HOST_PORT_OFFSET;
+
+	for (i = 0; i < XGBE10_NUM_HW_STATS_MOD; i++)
+		gbe_dev->hw_stats_regs[i] = regs + XGBE10_HW_STATS_OFFSET +
+				(GBE_HW_STATS_REG_MAP_SZ * i);
+
+	gbe_dev->ale_reg = regs + XGBE10_ALE_OFFSET;
+	gbe_dev->ale_ports = XGBE10_NUM_ALE_PORTS;
+	gbe_dev->host_port = XGBE10_HOST_PORT_NUM;
+	gbe_dev->ale_entries = XGBE10_NUM_ALE_ENTRIES;
+	gbe_dev->et_stats = xgbe10_et_stats;
+	gbe_dev->num_et_stats = ARRAY_SIZE(xgbe10_et_stats);
+
+	/* Subsystem registers */
+	XGBE_SET_REG_OFS(gbe_dev, ss_regs, id_ver);
+	XGBE_SET_REG_OFS(gbe_dev, ss_regs, control);
+
+	/* Switch module registers */
+	XGBE_SET_REG_OFS(gbe_dev, switch_regs, id_ver);
+	XGBE_SET_REG_OFS(gbe_dev, switch_regs, control);
+	XGBE_SET_REG_OFS(gbe_dev, switch_regs, ptype);
+	XGBE_SET_REG_OFS(gbe_dev, switch_regs, stat_port_en);
+	XGBE_SET_REG_OFS(gbe_dev, switch_regs, flow_control);
+
+	/* Host port registers */
+	XGBE_SET_REG_OFS(gbe_dev, host_port_regs, port_vlan);
+	XGBE_SET_REG_OFS(gbe_dev, host_port_regs, tx_pri_map);
+	XGBE_SET_REG_OFS(gbe_dev, host_port_regs, rx_maxlen);
+	return 0;
+}
+
+static int set_gbe_ethss14_priv(struct gbe_priv *gbe_dev,
+				struct device_node *node)
+{
+	struct resource res;
+	void __iomem *regs;
+	int ret, i;
+	u32 ver;
+
+	ret = of_address_to_resource(node, 0, &res);
+	if (ret) {
+		dev_err(gbe_dev->dev, "Can't translate of node(%s) address\n",
+			node->name);
+		return ret;
+	}
+
+	regs = devm_ioremap_resource(gbe_dev->dev, &res);
+	if (IS_ERR(regs)) {
+		dev_err(gbe_dev->dev, "Failed to map gbe register base\n");
+		return PTR_ERR(regs);
+	}
+	gbe_dev->ss_regs = regs;
+
+	ver = readl_relaxed(gbe_dev->ss_regs);
+	if (ver != GBE_SS_VERSION_14) {
+		dev_err(gbe_dev->dev, "unknown GBE subsystem version 0x%08x\n",
+			ver);
+		return -ENODEV;
+	}
+
+	gbe_dev->hw_stats = devm_kzalloc(gbe_dev->dev,
+					  GBE13_NUM_HW_STAT_ENTRIES *
+					  GBE13_NUM_SLAVES * sizeof(u64),
+					  GFP_KERNEL);
+	if (!gbe_dev->hw_stats) {
+		dev_err(gbe_dev->dev, "hw_stats memory allocation failed\n");
+		return -ENOMEM;
+	}
+
+	gbe_dev->ss_version = GBE_SS_VERSION_14;
+	gbe_dev->sgmii_port_regs = regs + GBE13_SGMII_MODULE_OFFSET;
+	gbe_dev->sgmii_port34_regs = regs + GBE13_SGMII34_MODULE_OFFSET;
+	gbe_dev->switch_regs = regs + GBE13_SWITCH_MODULE_OFFSET;
+	gbe_dev->host_port_regs = regs + GBE13_HOST_PORT_OFFSET;
+
+	for (i = 0; i < GBE13_NUM_HW_STATS_MOD; i++)
+		gbe_dev->hw_stats_regs[i] = regs + GBE13_HW_STATS_OFFSET +
+				(GBE_HW_STATS_REG_MAP_SZ * i);
+
+	gbe_dev->ale_reg = regs + GBE13_ALE_OFFSET;
+	gbe_dev->ale_ports = GBE13_NUM_ALE_PORTS;
+	gbe_dev->host_port = GBE13_HOST_PORT_NUM;
+	gbe_dev->ale_entries = GBE13_NUM_ALE_ENTRIES;
+	gbe_dev->et_stats = gbe13_et_stats;
+	gbe_dev->num_et_stats = ARRAY_SIZE(gbe13_et_stats);
+
+	/* Subsystem registers */
+	GBE_SET_REG_OFS(gbe_dev, ss_regs, id_ver);
+
+	/* Switch module registers */
+	GBE_SET_REG_OFS(gbe_dev, switch_regs, id_ver);
+	GBE_SET_REG_OFS(gbe_dev, switch_regs, control);
+	GBE_SET_REG_OFS(gbe_dev, switch_regs, soft_reset);
+	GBE_SET_REG_OFS(gbe_dev, switch_regs, stat_port_en);
+	GBE_SET_REG_OFS(gbe_dev, switch_regs, ptype);
+	GBE_SET_REG_OFS(gbe_dev, switch_regs, flow_control);
+
+	/* Host port registers */
+	GBE_SET_REG_OFS(gbe_dev, host_port_regs, port_vlan);
+	GBE_SET_REG_OFS(gbe_dev, host_port_regs, rx_maxlen);
+	return 0;
+}
+
+static int gbe_probe(struct netcp_device *netcp_device, struct device *dev,
+		     struct device_node *node, void **inst_priv)
+{
+	struct device_node *interfaces, *interface;
+	struct device_node *secondary_ports;
+	struct cpsw_ale_params ale_params;
+	struct gbe_priv *gbe_dev;
+	u32 slave_num;
+	int ret = 0;
+
+	if (!node) {
+		dev_err(dev, "device tree info unavailable\n");
+		return -ENODEV;
+	}
+
+	gbe_dev = devm_kzalloc(dev, sizeof(struct gbe_priv), GFP_KERNEL);
+	if (!gbe_dev) {
+		dev_err(dev, "gbe_dev memory allocation failed\n");
+		return -ENOMEM;
+	}
+
+	gbe_dev->dev = dev;
+	gbe_dev->netcp_device = netcp_device;
+	gbe_dev->rx_packet_max = NETCP_MAX_FRAME_SIZE;
+
+	/* init the hw stats lock */
+	spin_lock_init(&gbe_dev->hw_stats_lock);
+
+	if (of_find_property(node, "enable-ale", NULL)) {
+		gbe_dev->enable_ale = true;
+		dev_info(dev, "ALE enabled\n");
+	} else {
+		gbe_dev->enable_ale = false;
+		dev_dbg(dev, "ALE bypass enabled*\n");
+	}
+
+	ret = of_property_read_u32(node, "tx-queue",
+				   &gbe_dev->tx_queue_id);
+	if (ret < 0) {
+		dev_err(dev, "missing tx_queue parameter\n");
+		gbe_dev->tx_queue_id = GBE_TX_QUEUE;
+	}
+
+	ret = of_property_read_u32(node, "tx-channel",
+				   &gbe_dev->dma_chan_id);
+	if (ret < 0) {
+		dev_err(dev, "missing \"tx-channel\" parameter\n");
+		ret = -ENODEV;
+		goto quit;
+	}
+
+	if (!strcmp(node->name, "gbe")) {
+		ret = set_gbe_ethss14_priv(gbe_dev, node);
+		if (ret)
+			goto quit;
+	} else if (!strcmp(node->name, "xgbe")) {
+		ret = set_xgbe_ethss10_priv(gbe_dev, node);
+		if (ret)
+			goto quit;
+		ret = netcp_xgbe_serdes_init(gbe_dev->xgbe_serdes_regs,
+					     gbe_dev->ss_regs);
+		if (ret)
+			goto quit;
+	} else {
+		dev_err(dev, "unknown GBE node(%s)\n", node->name);
+		ret = -ENODEV;
+		goto quit;
+	}
+
+	interfaces = of_get_child_by_name(node, "interfaces");
+	if (!interfaces)
+		dev_err(dev, "could not find interfaces\n");
+
+	ret = netcp_txpipe_init(&gbe_dev->tx_pipe, netcp_device,
+				gbe_dev->dma_chan_id, gbe_dev->tx_queue_id);
+	if (ret)
+		goto quit;
+
+	ret = netcp_txpipe_open(&gbe_dev->tx_pipe);
+	if (ret)
+		goto quit;
+
+	/* Create network interfaces */
+	INIT_LIST_HEAD(&gbe_dev->gbe_intf_head);
+	for_each_child_of_node(interfaces, interface) {
+		ret = of_property_read_u32(interface, "slave-port", &slave_num);
+		if (ret) {
+			dev_err(dev, "missing slave-port parameter, skipping interface configuration for %s\n",
+				interface->name);
+			continue;
+		}
+		gbe_dev->num_slaves++;
+	}
+
+	if (!gbe_dev->num_slaves)
+		dev_warn(dev, "No network interface configured\n");
+
+	/* Initialize Secondary slave ports */
+	secondary_ports = of_get_child_by_name(node, "secondary-slave-ports");
+	INIT_LIST_HEAD(&gbe_dev->secondary_slaves);
+	if (secondary_ports)
+		init_secondary_ports(gbe_dev, secondary_ports);
+	of_node_put(secondary_ports);
+
+	if (!gbe_dev->num_slaves) {
+		dev_err(dev, "No network interface or secondary ports configured\n");
+		ret = -ENODEV;
+		goto quit;
+	}
+
+	memset(&ale_params, 0, sizeof(ale_params));
+	ale_params.dev		= gbe_dev->dev;
+	ale_params.ale_regs	= gbe_dev->ale_reg;
+	ale_params.ale_ageout	= GBE_DEFAULT_ALE_AGEOUT;
+	ale_params.ale_entries	= gbe_dev->ale_entries;
+	ale_params.ale_ports	= gbe_dev->ale_ports;
+
+	gbe_dev->ale = cpsw_ale_create(&ale_params);
+	if (!gbe_dev->ale) {
+		dev_err(gbe_dev->dev, "error initializing ale engine\n");
+		ret = -ENODEV;
+		goto quit;
+	} else {
+		dev_dbg(gbe_dev->dev, "Created a gbe ale engine\n");
+	}
+
+	/* initialize host port */
+	gbe_init_host_port(gbe_dev);
+
+	init_timer(&gbe_dev->timer);
+	gbe_dev->timer.data	 = (unsigned long)gbe_dev;
+	gbe_dev->timer.function = netcp_ethss_timer;
+	gbe_dev->timer.expires	 = jiffies + GBE_TIMER_INTERVAL;
+	add_timer(&gbe_dev->timer);
+	*inst_priv = gbe_dev;
+	return 0;
+
+quit:
+	if (gbe_dev->hw_stats)
+		devm_kfree(dev, gbe_dev->hw_stats);
+	if (gbe_dev->ale)
+		cpsw_ale_destroy(gbe_dev->ale);
+	if (gbe_dev->ss_regs)
+		devm_iounmap(dev, gbe_dev->ss_regs);
+	if (interfaces)
+		of_node_put(interfaces);
+	devm_kfree(dev, gbe_dev);
+	return ret;
+}
+
+static int gbe_attach(void *inst_priv, struct net_device *ndev,
+		      struct device_node *node, void **intf_priv)
+{
+	struct gbe_priv *gbe_dev = inst_priv;
+	struct gbe_intf *gbe_intf;
+	int ret;
+
+	if (!node) {
+		dev_err(gbe_dev->dev, "interface node not available\n");
+		return -ENODEV;
+	}
+
+	gbe_intf = devm_kzalloc(gbe_dev->dev, sizeof(*gbe_intf), GFP_KERNEL);
+	if (!gbe_intf) {
+		dev_err(gbe_dev->dev, "gbe interface memory allocation failed\n");
+		return -ENOMEM;
+	}
+	gbe_intf->ndev = ndev;
+	gbe_intf->dev = gbe_dev->dev;
+	gbe_intf->gbe_dev = gbe_dev;
+
+	gbe_intf->slave = devm_kzalloc(gbe_dev->dev,
+					sizeof(*gbe_intf->slave),
+					GFP_KERNEL);
+	if (!gbe_intf->slave) {
+		dev_err(gbe_dev->dev, "gbe interface slave memory allocation failed\n");
+		ret = -ENOMEM;
+		goto fail;
+	}
+
+	if (init_slave(gbe_dev, gbe_intf->slave, node)) {
+		ret = -ENODEV;
+		goto fail;
+	}
+
+	gbe_intf->tx_pipe = gbe_dev->tx_pipe;
+	SET_ETHTOOL_OPS(ndev, &keystone_ethtool_ops);
+	list_add_tail(&gbe_intf->gbe_intf_list, &gbe_dev->gbe_intf_head);
+	*intf_priv = gbe_intf;
+	return 0;
+
+fail:
+	if (gbe_intf->slave)
+		devm_kfree(gbe_dev->dev, gbe_intf->slave);
+	if (gbe_intf)
+		devm_kfree(gbe_dev->dev, gbe_intf);
+	return ret;
+}
+
+static int gbe_release(void *intf_priv)
+{
+	struct gbe_intf *gbe_intf = intf_priv;
+
+	SET_ETHTOOL_OPS(gbe_intf->ndev, NULL);
+	list_del(&gbe_intf->gbe_intf_list);
+	devm_kfree(gbe_intf->dev, gbe_intf->slave);
+	devm_kfree(gbe_intf->dev, gbe_intf);
+	return 0;
+}
+
+static int gbe_remove(struct netcp_device *netcp_device, void *inst_priv)
+{
+	struct gbe_priv *gbe_dev = inst_priv;
+
+	del_timer_sync(&gbe_dev->timer);
+	cpsw_ale_stop(gbe_dev->ale);
+	cpsw_ale_destroy(gbe_dev->ale);
+	netcp_txpipe_close(&gbe_dev->tx_pipe);
+	free_secondary_ports(gbe_dev);
+
+	if (!list_empty(&gbe_dev->gbe_intf_head))
+		dev_alert(gbe_dev->dev, "unreleased ethss interfaces present\n");
+
+	devm_kfree(gbe_dev->dev, gbe_dev->hw_stats);
+	devm_iounmap(gbe_dev->dev, gbe_dev->ss_regs);
+	memset(gbe_dev, 0x00, sizeof(*gbe_dev));
+	devm_kfree(gbe_dev->dev, gbe_dev);
+	return 0;
+}
+
+static struct netcp_module gbe_module = {
+	.name		= GBE_MODULE_NAME,
+	.owner		= THIS_MODULE,
+	.primary	= true,
+	.probe		= gbe_probe,
+	.open		= gbe_open,
+	.close		= gbe_close,
+	.remove		= gbe_remove,
+	.attach		= gbe_attach,
+	.release	= gbe_release,
+	.add_addr	= gbe_add_addr,
+	.del_addr	= gbe_del_addr,
+	.add_vid	= gbe_add_vid,
+	.del_vid	= gbe_del_vid,
+	.ioctl		= gbe_ioctl,
+};
+
+static struct netcp_module xgbe_module = {
+	.name		= XGBE_MODULE_NAME,
+	.owner		= THIS_MODULE,
+	.primary	= true,
+	.probe		= gbe_probe,
+	.open		= gbe_open,
+	.close		= gbe_close,
+	.remove		= gbe_remove,
+	.attach		= gbe_attach,
+	.release	= gbe_release,
+	.add_addr	= gbe_add_addr,
+	.del_addr	= gbe_del_addr,
+	.add_vid	= gbe_add_vid,
+	.del_vid	= gbe_del_vid,
+	.ioctl		= gbe_ioctl,
+};
+
+static int __init keystone_gbe_init(void)
+{
+	int ret;
+
+	ret = netcp_register_module(&gbe_module);
+	if (ret)
+		return ret;
+
+	ret = netcp_register_module(&xgbe_module);
+	if (ret)
+		return ret;
+
+	return 0;
+}
+module_init(keystone_gbe_init);
+
+static void __exit keystone_gbe_exit(void)
+{
+	netcp_unregister_module(&gbe_module);
+	netcp_unregister_module(&xgbe_module);
+}
+module_exit(keystone_gbe_exit);
diff --git a/drivers/net/ethernet/ti/netcp_sgmii.c b/drivers/net/ethernet/ti/netcp_sgmii.c
new file mode 100644
index 0000000..55a5d61
--- /dev/null
+++ b/drivers/net/ethernet/ti/netcp_sgmii.c
@@ -0,0 +1,130 @@
+/*
+ * SGMI module initialisation
+ *
+ * Copyright (C) 2014 Texas Instruments Incorporated
+ * Authors:	Sandeep Nair <sandeep_n@ti.com>
+ *		Sandeep Paulraj <s-paulraj@ti.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation version 2.
+ *
+ * This program is distributed "as is" WITHOUT ANY WARRANTY of any
+ * kind, whether express or implied; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#include "netcp.h"
+
+#define SGMII_REG_STATUS_LOCK		BIT(4)
+#define	SGMII_REG_STATUS_LINK		BIT(0)
+#define SGMII_REG_STATUS_AUTONEG	BIT(2)
+#define SGMII_REG_CONTROL_AUTONEG	BIT(0)
+
+#define SGMII23_OFFSET(x)	((x - 2) * 0x100)
+#define SGMII_OFFSET(x)		((x <= 1) ? (x * 0x100) : (SGMII23_OFFSET(x)))
+
+/* SGMII registers */
+#define SGMII_SRESET_REG(x)   (SGMII_OFFSET(x) + 0x004)
+#define SGMII_CTL_REG(x)      (SGMII_OFFSET(x) + 0x010)
+#define SGMII_STATUS_REG(x)   (SGMII_OFFSET(x) + 0x014)
+#define SGMII_MRADV_REG(x)    (SGMII_OFFSET(x) + 0x018)
+
+static inline void sgmii_write_reg(void __iomem *base, int reg, u32 val)
+{
+	writel_relaxed(val, base + reg);
+}
+
+static inline u32 sgmii_read_reg(void __iomem *base, int reg)
+{
+	return readl_relaxed(base + reg);
+}
+
+static inline void sgmii_write_reg_bit(void __iomem *base, int reg, u32 val)
+{
+	writel_relaxed((readl_relaxed(base + reg) | val), base + reg);
+}
+
+/* port is 0 based */
+int netcp_sgmii_reset(void __iomem *sgmii_ofs, int port)
+{
+	/* Soft reset */
+	sgmii_write_reg_bit(sgmii_ofs, SGMII_SRESET_REG(port), 0x1);
+	while (sgmii_read_reg(sgmii_ofs, SGMII_SRESET_REG(port)) != 0x0)
+		;
+	return 0;
+}
+
+int netcp_sgmii_get_port_link(void __iomem *sgmii_ofs, int port)
+{
+	u32 status = 0, link = 0;
+
+	status = sgmii_read_reg(sgmii_ofs, SGMII_STATUS_REG(port));
+	if ((status & SGMII_REG_STATUS_LINK) != 0)
+		link = 1;
+	return link;
+}
+
+int netcp_sgmii_config(void __iomem *sgmii_ofs, int port, u32 interface)
+{
+	unsigned int i, status, mask;
+	u32 mr_adv_ability;
+	u32 control;
+
+	switch (interface) {
+	case SGMII_LINK_MAC_MAC_AUTONEG:
+		mr_adv_ability	= 0x9801;
+		control		= 0x21;
+		break;
+
+	case SGMII_LINK_MAC_PHY:
+	case SGMII_LINK_MAC_PHY_NO_MDIO:
+		mr_adv_ability	= 1;
+		control		= 1;
+		break;
+
+	case SGMII_LINK_MAC_MAC_FORCED:
+		mr_adv_ability	= 0x9801;
+		control		= 0x20;
+		break;
+
+	case SGMII_LINK_MAC_FIBER:
+		mr_adv_ability	= 0x20;
+		control		= 0x1;
+		break;
+
+	default:
+		WARN_ONCE(1, "Invalid sgmii interface: %d\n", interface);
+		return -EINVAL;
+	}
+
+	sgmii_write_reg(sgmii_ofs, SGMII_CTL_REG(port), 0);
+
+	/* Wait for the SerDes pll to lock */
+	for (i = 0; i < 1000; i++)  {
+		usleep_range(1000, 2000);
+		status = sgmii_read_reg(sgmii_ofs, SGMII_STATUS_REG(port));
+		if ((status & SGMII_REG_STATUS_LOCK) != 0)
+			break;
+	}
+
+	if ((status & SGMII_REG_STATUS_LOCK) == 0)
+		pr_err("serdes PLL not locked\n");
+
+	sgmii_write_reg(sgmii_ofs, SGMII_MRADV_REG(port), mr_adv_ability);
+	sgmii_write_reg(sgmii_ofs, SGMII_CTL_REG(port), control);
+
+	mask = SGMII_REG_STATUS_LINK;
+	if (control & SGMII_REG_CONTROL_AUTONEG)
+		mask |= SGMII_REG_STATUS_AUTONEG;
+
+	for (i = 0; i < 1000; i++)  {
+		usleep_range(200, 500);
+		status = sgmii_read_reg(sgmii_ofs, SGMII_STATUS_REG(port));
+		if ((status & mask) == mask)
+			break;
+	}
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/ti/netcp_xgbepcsr.c b/drivers/net/ethernet/ti/netcp_xgbepcsr.c
new file mode 100644
index 0000000..b0b3467
--- /dev/null
+++ b/drivers/net/ethernet/ti/netcp_xgbepcsr.c
@@ -0,0 +1,502 @@
+/*
+ * XGE PCSR module initialisation
+ *
+ * Copyright (C) 2014 Texas Instruments Incorporated
+ * Authors:	Sandeep Nair <sandeep_n@ti.com>
+ *		WingMan Kwok <w-kwok2@ti.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation version 2.
+ *
+ * This program is distributed "as is" WITHOUT ANY WARRANTY of any
+ * kind, whether express or implied; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+#include "netcp.h"
+
+/* XGBE registers */
+#define XGBE_CTRL_OFFSET		0x0c
+#define XGBE_SGMII_1_OFFSET		0x0114
+#define XGBE_SGMII_2_OFFSET		0x0214
+
+/* PCS-R registers */
+#define PCSR_CPU_CTRL_OFFSET		0x1fd0
+#define POR_EN				BIT(29)
+
+#define reg_rmw(addr, value, mask) \
+	writel_relaxed(((readl_relaxed(addr) & (~(mask))) | \
+			(value & (mask))), (addr))
+
+/* bit mask of width w at offset s */
+#define MASK_WID_SH(w, s)		(((1 << w) - 1) << s)
+
+/* shift value v to offset s */
+#define VAL_SH(v, s)			(v << s)
+
+#define PHY_A(serdes)			0
+
+struct serdes_cfg {
+	u32 ofs;
+	u32 val;
+	u32 mask;
+};
+
+static struct serdes_cfg cfg_phyb_1p25g_156p25mhz_cmu0[] = {
+	{0x0000, 0x00800002, 0x00ff00ff},
+	{0x0014, 0x00003838, 0x0000ffff},
+	{0x0060, 0x1c44e438, 0xffffffff},
+	{0x0064, 0x00c18400, 0x00ffffff},
+	{0x0068, 0x17078200, 0xffffff00},
+	{0x006c, 0x00000014, 0x000000ff},
+	{0x0078, 0x0000c000, 0x0000ff00},
+	{0x0000, 0x00000003, 0x000000ff},
+};
+
+static struct serdes_cfg cfg_phyb_10p3125g_156p25mhz_cmu1[] = {
+	{0x0c00, 0x00030002, 0x00ff00ff},
+	{0x0c14, 0x00005252, 0x0000ffff},
+	{0x0c28, 0x80000000, 0xff000000},
+	{0x0c2c, 0x000000f6, 0x000000ff},
+	{0x0c3c, 0x04000405, 0xff00ffff},
+	{0x0c40, 0xc0800000, 0xffff0000},
+	{0x0c44, 0x5a202062, 0xffffffff},
+	{0x0c48, 0x40040424, 0xffffffff},
+	{0x0c4c, 0x00004002, 0x0000ffff},
+	{0x0c50, 0x19001c00, 0xff00ff00},
+	{0x0c54, 0x00002100, 0x0000ff00},
+	{0x0c58, 0x00000060, 0x000000ff},
+	{0x0c60, 0x80131e7c, 0xffffffff},
+	{0x0c64, 0x8400cb02, 0xff00ffff},
+	{0x0c68, 0x17078200, 0xffffff00},
+	{0x0c6c, 0x00000016, 0x000000ff},
+	{0x0c74, 0x00000400, 0x0000ff00},
+	{0x0c78, 0x0000c000, 0x0000ff00},
+	{0x0c00, 0x00000003, 0x000000ff},
+};
+
+static struct serdes_cfg cfg_phyb_10p3125g_16bit_lane[] = {
+	{0x0204, 0x00000080, 0x000000ff},
+	{0x0208, 0x0000920d, 0x0000ffff},
+	{0x0204, 0xfc000000, 0xff000000},
+	{0x0208, 0x00009104, 0x0000ffff},
+	{0x0210, 0x1a000000, 0xff000000},
+	{0x0214, 0x00006b58, 0x00ffffff},
+	{0x0218, 0x75800084, 0xffff00ff},
+	{0x022c, 0x00300000, 0x00ff0000},
+	{0x0230, 0x00003800, 0x0000ff00},
+	{0x024c, 0x008f0000, 0x00ff0000},
+	{0x0250, 0x30000000, 0xff000000},
+	{0x0260, 0x00000002, 0x000000ff},
+	{0x0264, 0x00000057, 0x000000ff},
+	{0x0268, 0x00575700, 0x00ffff00},
+	{0x0278, 0xff000000, 0xff000000},
+	{0x0280, 0x00500050, 0x00ff00ff},
+	{0x0284, 0x00001f15, 0x0000ffff},
+	{0x028c, 0x00006f00, 0x0000ff00},
+	{0x0294, 0x00000000, 0xffffff00},
+	{0x0298, 0x00002640, 0xff00ffff},
+	{0x029c, 0x00000003, 0x000000ff},
+	{0x02a4, 0x00000f13, 0x0000ffff},
+	{0x02a8, 0x0001b600, 0x00ffff00},
+	{0x0380, 0x00000030, 0x000000ff},
+	{0x03c0, 0x00000200, 0x0000ff00},
+	{0x03cc, 0x00000018, 0x000000ff},
+	{0x03cc, 0x00000000, 0x000000ff},
+};
+
+static struct serdes_cfg cfg_phyb_10p3125g_comlane[] = {
+	{0x0a00, 0x00000800, 0x0000ff00},
+	{0x0a84, 0x00000000, 0x000000ff},
+	{0x0a8c, 0x00130000, 0x00ff0000},
+	{0x0a90, 0x77a00000, 0xffff0000},
+	{0x0a94, 0x00007777, 0x0000ffff},
+	{0x0b08, 0x000f0000, 0xffff0000},
+	{0x0b0c, 0x000f0000, 0x00ffffff},
+	{0x0b10, 0xbe000000, 0xff000000},
+	{0x0b14, 0x000000ff, 0x000000ff},
+	{0x0b18, 0x00000014, 0x000000ff},
+	{0x0b5c, 0x981b0000, 0xffff0000},
+	{0x0b64, 0x00001100, 0x0000ff00},
+	{0x0b78, 0x00000c00, 0x0000ff00},
+	{0x0abc, 0xff000000, 0xff000000},
+	{0x0ac0, 0x0000008b, 0x000000ff},
+};
+
+static struct serdes_cfg cfg_cm_c1_c2[] = {
+	{0x0208, 0x00000000, 0x00000f00},
+	{0x0208, 0x00000000, 0x0000001f},
+	{0x0204, 0x00000000, 0x00040000},
+	{0x0208, 0x000000a0, 0x000000e0},
+};
+
+static inline void netcp_xgbe_serdes_cmu_init(void __iomem *serdes_regs)
+{
+	int i;
+
+	/* cmu0 setup */
+	for (i = 0; i < ARRAY_SIZE(cfg_phyb_1p25g_156p25mhz_cmu0); i++) {
+		reg_rmw(serdes_regs + cfg_phyb_1p25g_156p25mhz_cmu0[i].ofs,
+			cfg_phyb_1p25g_156p25mhz_cmu0[i].val,
+			cfg_phyb_1p25g_156p25mhz_cmu0[i].mask);
+	}
+
+	/* cmu1 setup */
+	for (i = 0; i < ARRAY_SIZE(cfg_phyb_10p3125g_156p25mhz_cmu1); i++) {
+		reg_rmw(serdes_regs + cfg_phyb_10p3125g_156p25mhz_cmu1[i].ofs,
+			cfg_phyb_10p3125g_156p25mhz_cmu1[i].val,
+			cfg_phyb_10p3125g_156p25mhz_cmu1[i].mask);
+	}
+}
+
+/* lane is 0 based */
+static inline void netcp_xgbe_serdes_lane_config(
+			void __iomem *serdes_regs, int lane)
+{
+	int i;
+
+	/* lane setup */
+	for (i = 0; i < ARRAY_SIZE(cfg_phyb_10p3125g_16bit_lane); i++) {
+		reg_rmw(serdes_regs +
+				cfg_phyb_10p3125g_16bit_lane[i].ofs +
+				(0x200 * lane),
+			cfg_phyb_10p3125g_16bit_lane[i].val,
+			cfg_phyb_10p3125g_16bit_lane[i].mask);
+	}
+
+	/* disable auto negotiation*/
+	reg_rmw(serdes_regs + (0x200 * lane) + 0x0380,
+		0x00000000, 0x00000010);
+
+	/* disable link training */
+	reg_rmw(serdes_regs + (0x200 * lane) + 0x03c0,
+		0x00000000, 0x00000200);
+}
+
+static inline void netcp_xgbe_serdes_com_enable(void __iomem *serdes_regs)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(cfg_phyb_10p3125g_comlane); i++) {
+		reg_rmw(serdes_regs + cfg_phyb_10p3125g_comlane[i].ofs,
+			cfg_phyb_10p3125g_comlane[i].val,
+			cfg_phyb_10p3125g_comlane[i].mask);
+	}
+}
+
+static inline void netcp_xgbe_serdes_lane_enable(
+			void __iomem *serdes_regs, int lane)
+{
+	/* Set Lane Control Rate */
+	writel_relaxed(0xe0e9e038, serdes_regs + 0x1fe0 + (4 * lane));
+}
+
+static inline void netcp_xgbe_serdes_phyb_rst_clr(void __iomem *serdes_regs)
+{
+	reg_rmw(serdes_regs + 0x0a00, 0x0000001f, 0x000000ff);
+}
+
+static inline void netcp_xgbe_serdes_pll_disable(void __iomem *serdes_regs)
+{
+	writel_relaxed(0x88000000, serdes_regs + 0x1ff4);
+}
+
+static inline void netcp_xgbe_serdes_pll_enable(void __iomem *serdes_regs)
+{
+	netcp_xgbe_serdes_phyb_rst_clr(serdes_regs);
+	writel_relaxed(0xee000000, serdes_regs + 0x1ff4);
+}
+
+static int netcp_xgbe_wait_pll_locked(void __iomem *sw_regs)
+{
+	unsigned long timeout;
+	int ret = 0;
+	u32 val_1, val_0;
+
+	timeout = jiffies + msecs_to_jiffies(500);
+	do {
+		val_0 = (readl_relaxed(sw_regs + XGBE_SGMII_1_OFFSET) & BIT(4));
+		val_1 = (readl_relaxed(sw_regs + XGBE_SGMII_2_OFFSET) & BIT(4));
+
+		if (val_1 && val_0)
+			return 0;
+
+		if (time_after(jiffies, timeout)) {
+			ret = -ETIMEDOUT;
+			break;
+		}
+
+		cpu_relax();
+	} while (true);
+
+	pr_err("XGBE serdes not locked: time out.\n");
+	return ret;
+}
+
+static inline void netcp_xgbe_serdes_enable_xgmii_port(void __iomem *sw_regs)
+{
+	writel_relaxed(0x03, sw_regs + XGBE_CTRL_OFFSET);
+}
+
+static u32 netcp_xgbe_serdes_read_tbus_val(void __iomem *serdes_regs)
+{
+	u32 tmp;
+
+	if (PHY_A(serdes_regs)) {
+		tmp  = (readl(serdes_regs + 0x0ec) >> 24) & 0x0ff;
+		tmp |= ((readl(serdes_regs + 0x0fc) >> 16) & 0x00f00);
+	} else {
+		tmp  = (readl(serdes_regs + 0x0f8) >> 16) & 0x0fff;
+	}
+
+	return tmp;
+}
+
+static void netcp_xgbe_serdes_write_tbus_addr(void __iomem *serdes_regs,
+					      int select, int ofs)
+{
+	if (PHY_A(serdes_regs)) {
+		reg_rmw(serdes_regs + 0x0008, ((select << 5) + ofs) << 24,
+			~0x00ffffff);
+		return;
+	}
+
+	/* For 2 lane Phy-B, lane0 is actually lane1 */
+	switch (select) {
+	case 1:
+		select = 2;
+		break;
+	case 2:
+		select = 3;
+		break;
+	default:
+		return;
+	}
+
+	reg_rmw(serdes_regs + 0x00fc, ((select << 8) + ofs) << 16, ~0xf800ffff);
+}
+
+static u32 netcp_xgbe_serdes_read_select_tbus(void __iomem *serdes_regs,
+					      int select, int ofs)
+{
+	/* Set tbus address */
+	netcp_xgbe_serdes_write_tbus_addr(serdes_regs, select, ofs);
+	/* Get TBUS Value */
+	return netcp_xgbe_serdes_read_tbus_val(serdes_regs);
+}
+
+static void netcp_xgbe_serdes_reset_cdr(void __iomem *serdes_regs,
+					void __iomem *sig_detect_reg, int lane)
+{
+	u32 tmp, dlpf, tbus;
+
+	/*Get the DLPF values */
+	tmp = netcp_xgbe_serdes_read_select_tbus(
+			serdes_regs, lane + 1, 5);
+
+	dlpf = tmp >> 2;
+
+	if (dlpf < 400 || dlpf > 700) {
+		reg_rmw(sig_detect_reg, VAL_SH(2, 1), MASK_WID_SH(2, 1));
+		mdelay(1);
+		reg_rmw(sig_detect_reg, VAL_SH(0, 1), MASK_WID_SH(2, 1));
+	} else {
+		tbus = netcp_xgbe_serdes_read_select_tbus(serdes_regs, lane +
+							  1, 0xe);
+
+		pr_debug("XGBE: CDR centered, DLPF: %4d,%d,%d.\n",
+			 tmp >> 2, tmp & 3, (tbus >> 2) & 3);
+	}
+}
+
+/* Call every 100 ms */
+static int netcp_xgbe_check_link_status(void __iomem *serdes_regs,
+					void __iomem *sw_regs, u32 lanes,
+					u32 *current_state, u32 *lane_down)
+{
+	void __iomem *pcsr_base = sw_regs + 0x0600;
+	void __iomem *sig_detect_reg;
+	u32 pcsr_rx_stat, blk_lock, blk_errs;
+	int loss, i, status = 1;
+
+	for (i = 0; i < lanes; i++) {
+		/* Get the Loss bit */
+		loss = readl(serdes_regs + 0x1fc0 + 0x20 + (i * 0x04)) & 0x1;
+
+		/* Get Block Errors and Block Lock bits */
+		pcsr_rx_stat = readl(pcsr_base + 0x0c + (i * 0x80));
+		blk_lock = (pcsr_rx_stat >> 30) & 0x1;
+		blk_errs = (pcsr_rx_stat >> 16) & 0x0ff;
+
+		/* Get Signal Detect Overlay Address */
+		sig_detect_reg = serdes_regs + (i * 0x200) + 0x200 + 0x04;
+
+		/* If Block errors maxed out, attempt recovery! */
+		if (blk_errs == 0x0ff)
+			blk_lock = 0;
+
+		switch (current_state[i]) {
+		case 0:
+			/* if good link lock the signal detect ON! */
+			if (!loss && blk_lock) {
+				pr_debug("XGBE PCSR Linked Lane: %d\n", i);
+				reg_rmw(sig_detect_reg, VAL_SH(3, 1),
+					MASK_WID_SH(2, 1));
+				current_state[i] = 1;
+			} else if (!blk_lock) {
+				/* if no lock, then reset CDR */
+				pr_debug("XGBE PCSR Recover Lane: %d\n", i);
+				netcp_xgbe_serdes_reset_cdr(serdes_regs,
+							    sig_detect_reg, i);
+			}
+			break;
+
+		case 1:
+			if (!blk_lock) {
+				/* Link Lost? */
+				lane_down[i] = 1;
+				current_state[i] = 2;
+			}
+			break;
+
+		case 2:
+			if (blk_lock)
+				/* Nope just noise */
+				current_state[i] = 1;
+			else {
+				/* Lost the block lock, reset CDR if it is
+				 * not centered and go back to sync state
+				 */
+				netcp_xgbe_serdes_reset_cdr(serdes_regs,
+							    sig_detect_reg, i);
+				current_state[i] = 0;
+			}
+			break;
+
+		default:
+			pr_err("XGBE: unknown current_state[%d] %d\n",
+				i, current_state[i]);
+			break;
+		}
+
+		if (blk_errs > 0) {
+			/* Reset the Error counts! */
+			reg_rmw(pcsr_base + 0x08 + (i * 0x80), VAL_SH(0x19, 0),
+				MASK_WID_SH(8, 0));
+
+			reg_rmw(pcsr_base + 0x08 + (i * 0x80), VAL_SH(0x00, 0),
+				MASK_WID_SH(8, 0));
+		}
+
+		status &= (current_state[i] == 1);
+	}
+
+	return status;
+}
+
+static int netcp_xgbe_serdes_check_lane(void __iomem *serdes_regs,
+					void __iomem *sw_regs)
+{
+	u32 current_state[2] = {0, 0};
+	int retries = 0, link_up;
+	u32 lane_down[2];
+
+	do {
+		lane_down[0] = 0;
+		lane_down[1] = 0;
+
+		link_up = netcp_xgbe_check_link_status(serdes_regs, sw_regs, 2,
+						       current_state,
+						       lane_down);
+
+		/* if we did not get link up then wait 100ms before calling
+		 * it again
+		 */
+		if (link_up)
+			break;
+
+		if (lane_down[0])
+			pr_debug("XGBE: detected link down on lane 0\n");
+
+		if (lane_down[1])
+			pr_debug("XGBE: detected link down on lane 1\n");
+
+		if (++retries > 1) {
+			pr_debug("XGBE: timeout waiting for serdes link up\n");
+			return -ETIMEDOUT;
+		}
+		mdelay(100);
+	} while (!link_up);
+
+	pr_debug("XGBE: PCSR link is up\n");
+	return 0;
+}
+
+static inline void netcp_xgbe_serdes_setup_cm_c1_c2(void __iomem *serdes_regs,
+						    int lane, int cm, int c1,
+						    int c2)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(cfg_cm_c1_c2); i++) {
+		reg_rmw(serdes_regs + cfg_cm_c1_c2[i].ofs + (0x200 * lane),
+			cfg_cm_c1_c2[i].val,
+			cfg_cm_c1_c2[i].mask);
+	}
+}
+
+static inline void netcp_xgbe_reset_serdes(void __iomem *serdes_regs)
+{
+	/* Toggle the POR_EN bit in CONFIG.CPU_CTRL */
+	/* enable POR_EN bit */
+	reg_rmw(serdes_regs + PCSR_CPU_CTRL_OFFSET, POR_EN, POR_EN);
+	usleep_range(10, 100);
+
+	/* disable POR_EN bit */
+	reg_rmw(serdes_regs + PCSR_CPU_CTRL_OFFSET, 0, POR_EN);
+	usleep_range(10, 100);
+}
+
+static int netcp_xgbe_serdes_config(void __iomem *serdes_regs,
+				    void __iomem *sw_regs)
+{
+	u32 ret, i;
+
+	netcp_xgbe_serdes_pll_disable(serdes_regs);
+	netcp_xgbe_serdes_cmu_init(serdes_regs);
+
+	for (i = 0; i < 2; i++)
+		netcp_xgbe_serdes_lane_config(serdes_regs, i);
+
+	netcp_xgbe_serdes_com_enable(serdes_regs);
+	/* This is EVM + RTM-BOC specific */
+	for (i = 0; i < 2; i++)
+		netcp_xgbe_serdes_setup_cm_c1_c2(serdes_regs, i, 0, 0, 5);
+
+	netcp_xgbe_serdes_pll_enable(serdes_regs);
+	for (i = 0; i < 2; i++)
+		netcp_xgbe_serdes_lane_enable(serdes_regs, i);
+
+	/* SB PLL Status Poll */
+	ret = netcp_xgbe_wait_pll_locked(sw_regs);
+	if (ret)
+		return ret;
+
+	netcp_xgbe_serdes_enable_xgmii_port(sw_regs);
+	netcp_xgbe_serdes_check_lane(serdes_regs, sw_regs);
+	return ret;
+}
+
+int netcp_xgbe_serdes_init(void __iomem *serdes_regs, void __iomem *xgbe_regs)
+{
+	u32 val;
+
+	/* read COMLANE bits 4:0 */
+	val = readl_relaxed(serdes_regs + 0xa00);
+	if (val & 0x1f) {
+		pr_debug("XGBE: serdes already in operation - reset\n");
+		netcp_xgbe_reset_serdes(serdes_regs);
+	}
+	return netcp_xgbe_serdes_config(serdes_regs, xgbe_regs);
+}
-- 
1.7.9.5
