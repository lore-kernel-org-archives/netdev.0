From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH net-next 3/3 v7] drivers: net: ethernet: qualcomm: rmnet: Initial implementation
Date: Mon, 21 Aug 2017 16:36:59 -0600
Message-ID: <1503355019-12236-4-git-send-email-subashab@codeaurora.org>
References: <1503355019-12236-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
To: netdev@vger.kernel.org, davem@davemloft.net,
        fengguang.wu@intel.com, dcbw@redhat.com, jiri@resnulli.us,
        stephen@networkplumber.org, David.Laight@ACULAB.COM,
        marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:51200 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754341AbdHUWhe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 18:37:34 -0400
In-Reply-To: <1503355019-12236-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RmNet driver provides a transport agnostic MAP (multiplexing and
aggregation protocol) support in embedded module. Module provides
virtual network devices which can be attached to any IP-mode
physical device. This will be used to provide all MAP functionality
on future hardware in a single consistent location.

Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
---
 Documentation/networking/rmnet.txt                 |  82 ++++
 drivers/net/ethernet/qualcomm/Kconfig              |   2 +
 drivers/net/ethernet/qualcomm/Makefile             |   2 +
 drivers/net/ethernet/qualcomm/rmnet/Kconfig        |  12 +
 drivers/net/ethernet/qualcomm/rmnet/Makefile       |  12 +
 drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c | 418 +++++++++++++++++++++
 drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h |  54 +++
 .../net/ethernet/qualcomm/rmnet/rmnet_handlers.c   | 276 ++++++++++++++
 .../net/ethernet/qualcomm/rmnet/rmnet_handlers.h   |  26 ++
 drivers/net/ethernet/qualcomm/rmnet/rmnet_map.h    |  88 +++++
 .../ethernet/qualcomm/rmnet/rmnet_map_command.c    | 116 ++++++
 .../net/ethernet/qualcomm/rmnet/rmnet_map_data.c   | 105 ++++++
 .../net/ethernet/qualcomm/rmnet/rmnet_private.h    |  45 +++
 drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c    | 263 +++++++++++++
 drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.h    |  32 ++
 15 files changed, 1533 insertions(+)
 create mode 100644 Documentation/networking/rmnet.txt
 create mode 100644 drivers/net/ethernet/qualcomm/rmnet/Kconfig
 create mode 100644 drivers/net/ethernet/qualcomm/rmnet/Makefile
 create mode 100644 drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c
 create mode 100644 drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h
 create mode 100644 drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c
 create mode 100644 drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.h
 create mode 100644 drivers/net/ethernet/qualcomm/rmnet/rmnet_map.h
 create mode 100644 drivers/net/ethernet/qualcomm/rmnet/rmnet_map_command.c
 create mode 100644 drivers/net/ethernet/qualcomm/rmnet/rmnet_map_data.c
 create mode 100644 drivers/net/ethernet/qualcomm/rmnet/rmnet_private.h
 create mode 100644 drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
 create mode 100644 drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.h

diff --git a/Documentation/networking/rmnet.txt b/Documentation/networking/rmnet.txt
new file mode 100644
index 0000000..6b341ea
--- /dev/null
+++ b/Documentation/networking/rmnet.txt
@@ -0,0 +1,82 @@
+1. Introduction
+
+rmnet driver is used for supporting the Multiplexing and aggregation
+Protocol (MAP). This protocol is used by all recent chipsets using Qualcomm
+Technologies, Inc. modems.
+
+This driver can be used to register onto any physical network device in
+IP mode. Physical transports include USB, HSIC, PCIe and IP accelerator.
+
+Multiplexing allows for creation of logical netdevices (rmnet devices) to
+handle multiple private data networks (PDN) like a default internet, tethering,
+multimedia messaging service (MMS) or IP media subsystem (IMS). Hardware sends
+packets with MAP headers to rmnet. Based on the multiplexer id, rmnet
+routes to the appropriate PDN after removing the MAP header.
+
+Aggregation is required to achieve high data rates. This involves hardware
+sending aggregated bunch of MAP frames. rmnet driver will de-aggregate
+these MAP frames and send them to appropriate PDN's.
+
+2. Packet format
+
+a. MAP packet (data / control)
+
+MAP header has the same endianness of the IP packet.
+
+Packet format -
+
+Bit             0             1           2-7      8 - 15           16 - 31
+Function   Command / Data   Reserved     Pad   Multiplexer ID    Payload length
+Bit            32 - x
+Function     Raw  Bytes
+
+Command (1)/ Data (0) bit value is to indicate if the packet is a MAP command
+or data packet. Control packet is used for transport level flow control. Data
+packets are standard IP packets.
+
+Reserved bits are usually zeroed out and to be ignored by receiver.
+
+Padding is number of bytes to be added for 4 byte alignment if required by
+hardware.
+
+Multiplexer ID is to indicate the PDN on which data has to be sent.
+
+Payload length includes the padding length but does not include MAP header
+length.
+
+b. MAP packet (command specific)
+
+Bit             0             1           2-7      8 - 15           16 - 31
+Function   Command         Reserved     Pad   Multiplexer ID    Payload length
+Bit          32 - 39        40 - 45    46 - 47       48 - 63
+Function   Command name    Reserved   Command Type   Reserved
+Bit          64 - 95
+Function   Transaction ID
+Bit          96 - 127
+Function   Command data
+
+Command 1 indicates disabling flow while 2 is enabling flow
+
+Command types -
+0 for MAP command request
+1 is to acknowledge the receipt of a command
+2 is for unsupported commands
+3 is for error during processing of commands
+
+c. Aggregation
+
+Aggregation is multiple MAP packets (can be data or command) delivered to
+rmnet in a single linear skb. rmnet will process the individual
+packets and either ACK the MAP command or deliver the IP packet to the
+network stack as needed
+
+MAP header|IP Packet|Optional padding|MAP header|IP Packet|Optional padding....
+MAP header|IP Packet|Optional padding|MAP header|Command Packet|Optional pad...
+
+3. Userspace configuration
+
+rmnet userspace configuration is done through netlink library librmnetctl
+and command line utility rmnetcli. Utility is hosted in codeaurora forum git.
+The driver uses rtnl_link_ops for communication.
+
+https://source.codeaurora.org/quic/la/platform/vendor/qcom-opensource/dataservices/tree/rmnetctl
diff --git a/drivers/net/ethernet/qualcomm/Kconfig b/drivers/net/ethernet/qualcomm/Kconfig
index 877675a..f520071 100644
--- a/drivers/net/ethernet/qualcomm/Kconfig
+++ b/drivers/net/ethernet/qualcomm/Kconfig
@@ -59,4 +59,6 @@ config QCOM_EMAC
 	  low power, Receive-Side Scaling (RSS), and IEEE 1588-2008
 	  Precision Clock Synchronization Protocol.
 
+source "drivers/net/ethernet/qualcomm/rmnet/Kconfig"
+
 endif # NET_VENDOR_QUALCOMM
diff --git a/drivers/net/ethernet/qualcomm/Makefile b/drivers/net/ethernet/qualcomm/Makefile
index 92fa7c4..1847350 100644
--- a/drivers/net/ethernet/qualcomm/Makefile
+++ b/drivers/net/ethernet/qualcomm/Makefile
@@ -9,3 +9,5 @@ obj-$(CONFIG_QCA7000_UART) += qcauart.o
 qcauart-objs := qca_uart.o
 
 obj-y += emac/
+
+obj-$(CONFIG_RMNET) += rmnet/
diff --git a/drivers/net/ethernet/qualcomm/rmnet/Kconfig b/drivers/net/ethernet/qualcomm/rmnet/Kconfig
new file mode 100644
index 0000000..4948f14
--- /dev/null
+++ b/drivers/net/ethernet/qualcomm/rmnet/Kconfig
@@ -0,0 +1,12 @@
+#
+# RMNET MAP driver
+#
+
+menuconfig RMNET
+	depends on NETDEVICES
+	bool "RmNet MAP driver"
+	default n
+	---help---
+	  If you say Y here, then the rmnet module will be statically
+	  compiled into the kernel. The rmnet module provides MAP
+	  functionality for embedded and bridged traffic.
diff --git a/drivers/net/ethernet/qualcomm/rmnet/Makefile b/drivers/net/ethernet/qualcomm/rmnet/Makefile
new file mode 100644
index 0000000..1c43e2f
--- /dev/null
+++ b/drivers/net/ethernet/qualcomm/rmnet/Makefile
@@ -0,0 +1,12 @@
+#
+# Makefile for the RMNET module
+#
+
+rmnet-y		 := rmnet_config.o
+rmnet-y		 += rmnet_vnd.o
+rmnet-y		 += rmnet_handlers.o
+rmnet-y		 += rmnet_map_data.o
+rmnet-y		 += rmnet_map_command.o
+obj-$(CONFIG_RMNET) += rmnet.o
+
+CFLAGS_rmnet.o := -I$(src)
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c
new file mode 100644
index 0000000..94fe73a
--- /dev/null
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c
@@ -0,0 +1,418 @@
+/* Copyright (c) 2013-2017, The Linux Foundation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 and
+ * only version 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * RMNET configuration engine
+ *
+ */
+
+#include <net/sock.h>
+#include <linux/module.h>
+#include <linux/netlink.h>
+#include <linux/netdevice.h>
+#include "rmnet_config.h"
+#include "rmnet_handlers.h"
+#include "rmnet_vnd.h"
+#include "rmnet_private.h"
+
+/* Local Definitions and Declarations */
+#define RMNET_LOCAL_LOGICAL_ENDPOINT -1
+
+struct rmnet_free_work {
+	struct work_struct work;
+	struct net_device *rmnet_dev;
+};
+
+static int rmnet_is_real_dev_registered(const struct net_device *real_dev)
+{
+	rx_handler_func_t *rx_handler;
+
+	rx_handler = rcu_dereference(real_dev->rx_handler);
+	return (rx_handler == rmnet_rx_handler);
+}
+
+static struct rmnet_real_dev_info*
+__rmnet_get_real_dev_info(const struct net_device *real_dev)
+{
+	if (rmnet_is_real_dev_registered(real_dev))
+		return (struct rmnet_real_dev_info *)
+			rcu_dereference(real_dev->rx_handler_data);
+	else
+		return 0;
+}
+
+static struct rmnet_endpoint*
+rmnet_get_endpoint(struct net_device *dev, int config_id)
+{
+	struct rmnet_real_dev_info *rdinfo;
+	struct rmnet_endpoint *ep;
+
+	if (!rmnet_is_real_dev_registered(dev)) {
+		ep = rmnet_vnd_get_endpoint(dev);
+	} else {
+		rdinfo = __rmnet_get_real_dev_info(dev);
+
+		if (!rdinfo)
+			return NULL;
+
+		if (config_id == RMNET_LOCAL_LOGICAL_ENDPOINT)
+			ep = &rdinfo->local_ep;
+		else
+			ep = &rdinfo->muxed_ep[config_id];
+	}
+
+	return ep;
+}
+
+static int rmnet_unregister_real_device(struct net_device *real_dev)
+{
+	struct rmnet_real_dev_info *rdinfo;
+	struct list_head *iter;
+
+	ASSERT_RTNL();
+
+	if (!rmnet_is_real_dev_registered(real_dev) ||
+	    netdev_lower_get_next(real_dev, &iter))
+		return -EINVAL;
+
+	rdinfo = __rmnet_get_real_dev_info(real_dev);
+	kfree(rdinfo);
+
+	netdev_rx_handler_unregister(real_dev);
+
+	/* release reference on real_dev */
+	dev_put(real_dev);
+
+	netdev_info(real_dev, "Removed from rmnet\n");
+	return 0;
+}
+
+static int rmnet_register_real_device(struct net_device *real_dev)
+{
+	struct rmnet_real_dev_info *rdinfo;
+	int rc;
+
+	ASSERT_RTNL();
+
+	if (rmnet_is_real_dev_registered(real_dev))
+		return -EINVAL;
+
+	rdinfo = kzalloc(sizeof(*rdinfo), GFP_ATOMIC);
+	if (!rdinfo)
+		return -ENOMEM;
+
+	rdinfo->dev = real_dev;
+	rc = netdev_rx_handler_register(real_dev, rmnet_rx_handler, rdinfo);
+
+	if (rc) {
+		kfree(rdinfo);
+		return -EBUSY;
+	}
+
+	/* hold on to real dev for MAP data */
+	dev_hold(real_dev);
+
+	netdev_info(real_dev, "registered with rmnet\n");
+	return 0;
+}
+
+static int rmnet_set_ingress_data_format(struct net_device *dev, u32 idf)
+{
+	struct rmnet_real_dev_info *rdinfo;
+
+	ASSERT_RTNL();
+
+	netdev_info(dev, "Ingress format 0x%08X\n", idf);
+
+	rdinfo = __rmnet_get_real_dev_info(dev);
+	if (!rdinfo)
+		return -EINVAL;
+
+	rdinfo->ingress_data_format = idf;
+
+	return 0;
+}
+
+static int rmnet_set_egress_data_format(struct net_device *dev, u32 edf,
+					u16 agg_size, u16 agg_count)
+{
+	struct rmnet_real_dev_info *rdinfo;
+
+	ASSERT_RTNL();
+
+	netdev_info(dev, "Egress format 0x%08X agg size %d cnt %d\n",
+		    edf, agg_size, agg_count);
+
+	rdinfo = __rmnet_get_real_dev_info(dev);
+	if (!rdinfo)
+		return -EINVAL;
+
+	rdinfo->egress_data_format = edf;
+
+	return 0;
+}
+
+static int __rmnet_set_endpoint_config(struct net_device *dev, int config_id,
+				       struct rmnet_endpoint *ep)
+{
+	struct rmnet_endpoint *dev_ep;
+
+	ASSERT_RTNL();
+
+	dev_ep = rmnet_get_endpoint(dev, config_id);
+
+	if (!dev_ep)
+		return -EINVAL;
+
+	memcpy(dev_ep, ep, sizeof(struct rmnet_endpoint));
+	if (config_id == RMNET_LOCAL_LOGICAL_ENDPOINT)
+		dev_ep->mux_id = 0;
+	else
+		dev_ep->mux_id = config_id;
+
+	return 0;
+}
+
+static int __rmnet_unset_endpoint_config(struct net_device *dev, int config_id)
+{
+	struct rmnet_endpoint *ep = 0;
+
+	ASSERT_RTNL();
+
+	ep = rmnet_get_endpoint(dev, config_id);
+	if (!ep)
+		return -EINVAL;
+
+	memset(ep, 0, sizeof(struct rmnet_endpoint));
+
+	return 0;
+}
+
+static int rmnet_set_endpoint_config(struct net_device *dev,
+				     int config_id, u8 rmnet_mode,
+				     struct net_device *egress_dev)
+{
+	struct rmnet_endpoint ep;
+
+	netdev_info(dev, "id %d mode %d dev %s\n",
+		    config_id, rmnet_mode, egress_dev->name);
+
+	if (config_id < RMNET_LOCAL_LOGICAL_ENDPOINT ||
+	    config_id >= RMNET_MAX_LOGICAL_EP)
+		return -EINVAL;
+
+	memset(&ep, 0, sizeof(struct rmnet_endpoint));
+	ep.rmnet_mode = rmnet_mode;
+	ep.egress_dev = egress_dev;
+
+	return __rmnet_set_endpoint_config(dev, config_id, &ep);
+}
+
+static int rmnet_unset_endpoint_config(struct net_device *dev, int config_id)
+{
+	netdev_info(dev, "id %d\n", config_id);
+
+	if (config_id < RMNET_LOCAL_LOGICAL_ENDPOINT ||
+	    config_id >= RMNET_MAX_LOGICAL_EP)
+		return -EINVAL;
+
+	return __rmnet_unset_endpoint_config(dev, config_id);
+}
+
+static int rmnet_newlink(struct net *src_net, struct net_device *dev,
+			 struct nlattr *tb[], struct nlattr *data[],
+			 struct netlink_ext_ack *extack)
+{
+	int ingress_format = RMNET_INGRESS_FORMAT_DEMUXING |
+			     RMNET_INGRESS_FORMAT_DEAGGREGATION |
+			     RMNET_INGRESS_FORMAT_MAP;
+	int egress_format = RMNET_EGRESS_FORMAT_MUXING |
+			    RMNET_EGRESS_FORMAT_MAP;
+	struct net_device *real_dev;
+	int mode = RMNET_EPMODE_VND;
+	u16 mux_id;
+
+	real_dev = __dev_get_by_index(src_net, nla_get_u32(tb[IFLA_LINK]));
+	if (!real_dev || !dev)
+		return -ENODEV;
+
+	if (!data[IFLA_VLAN_ID])
+		return -EINVAL;
+
+	mux_id = nla_get_u16(data[IFLA_VLAN_ID]);
+
+	rmnet_register_real_device(real_dev);
+
+	if (rmnet_vnd_newlink(real_dev, mux_id, dev))
+		return -EINVAL;
+
+	rmnet_set_egress_data_format(real_dev, egress_format, 0, 0);
+	rmnet_set_ingress_data_format(real_dev, ingress_format);
+	rmnet_set_endpoint_config(real_dev, mux_id, mode, dev);
+	rmnet_set_endpoint_config(dev, mux_id, mode, real_dev);
+	netdev_master_upper_dev_link(dev, real_dev, NULL, NULL);
+	return 0;
+}
+
+static void rmnet_delink(struct net_device *dev, struct list_head *head)
+{
+	struct net_device *real_dev;
+	int mux_id;
+
+	real_dev = netdev_master_upper_dev_get_rcu(dev);
+	if (real_dev) {
+		mux_id = rmnet_vnd_get_mux(real_dev, dev);
+
+		/* rmnet_vnd_get_mux() gives mux_id + 1,
+		 * so subtract 1 to get the correct mux_id
+		 */
+		mux_id--;
+		rmnet_unset_endpoint_config(real_dev, mux_id);
+		rmnet_unset_endpoint_config(dev, mux_id);
+		rmnet_vnd_remove_ref_dev(real_dev, mux_id);
+		netdev_upper_dev_unlink(dev, real_dev);
+		rmnet_unregister_real_device(real_dev);
+	}
+
+	unregister_netdevice_queue(dev, head);
+}
+
+static void rmnet_free_later(struct work_struct *work)
+{
+	struct rmnet_free_work *fwork;
+
+	fwork = container_of(work, struct rmnet_free_work, work);
+
+	rtnl_lock();
+	rmnet_delink(fwork->rmnet_dev, NULL);
+	rtnl_unlock();
+
+	kfree(fwork);
+}
+
+static int rmnet_dev_walk(struct net_device *lower_dev, void *data)
+{
+	struct net_device *real_dev = data;
+	struct rmnet_free_work *vnd_work;
+	int rc = 0;
+
+	netdev_upper_dev_unlink(lower_dev, real_dev);
+
+	vnd_work = kzalloc(sizeof(*vnd_work), GFP_KERNEL);
+	if (!vnd_work)
+		return -ENOMEM;
+
+	INIT_WORK(&vnd_work->work, rmnet_free_later);
+	vnd_work->rmnet_dev = lower_dev;
+	schedule_work(&vnd_work->work);
+
+	return rc;
+}
+
+static void rmnet_force_unassociate_device(struct net_device *dev)
+{
+	struct net_device *real_dev = dev;
+
+	if (!rmnet_is_real_dev_registered(real_dev))
+		return;
+
+	netdev_walk_all_lower_dev(real_dev, rmnet_dev_walk, real_dev);
+	rmnet_unregister_real_device(real_dev);
+}
+
+static int rmnet_config_notify_cb(struct notifier_block *nb,
+				  unsigned long event, void *data)
+{
+	struct net_device *dev = netdev_notifier_info_to_dev(data);
+
+	if (!dev)
+		return NOTIFY_DONE;
+
+	switch (event) {
+	case NETDEV_UNREGISTER_FINAL:
+	case NETDEV_UNREGISTER:
+		netdev_info(dev, "Kernel unregister\n");
+		rmnet_force_unassociate_device(dev);
+		break;
+
+	default:
+		break;
+	}
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block rmnet_dev_notifier __read_mostly = {
+	.notifier_call = rmnet_config_notify_cb,
+};
+
+static int rmnet_rtnl_validate(struct nlattr *tb[], struct nlattr *data[],
+			       struct netlink_ext_ack *extack)
+{
+	u16 mux_id;
+
+	if (!data || !data[IFLA_VLAN_ID])
+		return -EINVAL;
+
+	mux_id = nla_get_u16(data[IFLA_VLAN_ID]);
+	if (!mux_id || mux_id > (RMNET_MAX_LOGICAL_EP - 1))
+		return -ERANGE;
+
+	return 0;
+}
+
+static size_t rmnet_get_size(const struct net_device *dev)
+{
+	return nla_total_size(2); /* IFLA_VLAN_ID */
+}
+
+struct rtnl_link_ops rmnet_link_ops __read_mostly = {
+	.kind		= "rmnet",
+	.maxtype	= __IFLA_VLAN_MAX,
+	.priv_size	= sizeof(struct rmnet_priv),
+	.setup		= rmnet_vnd_setup,
+	.validate	= rmnet_rtnl_validate,
+	.newlink	= rmnet_newlink,
+	.dellink	= rmnet_delink,
+	.get_size	= rmnet_get_size,
+};
+
+struct rmnet_real_dev_info*
+rmnet_get_real_dev_info(struct net_device *real_dev)
+{
+	return __rmnet_get_real_dev_info(real_dev);
+}
+
+/* Startup/Shutdown */
+
+static int __init rmnet_init(void)
+{
+	int rc;
+
+	rc = register_netdevice_notifier(&rmnet_dev_notifier);
+	if (rc != 0)
+		return rc;
+
+	rc = rtnl_link_register(&rmnet_link_ops);
+	if (rc != 0) {
+		unregister_netdevice_notifier(&rmnet_dev_notifier);
+		return rc;
+	}
+	return rc;
+}
+
+static void __exit rmnet_exit(void)
+{
+	unregister_netdevice_notifier(&rmnet_dev_notifier);
+	rtnl_link_unregister(&rmnet_link_ops);
+}
+
+module_init(rmnet_init)
+module_exit(rmnet_exit)
+MODULE_LICENSE("GPL v2");
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h
new file mode 100644
index 0000000..8f5a073
--- /dev/null
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h
@@ -0,0 +1,54 @@
+/* Copyright (c) 2013-2014, 2016-2017 The Linux Foundation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 and
+ * only version 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * RMNET Data configuration engine
+ *
+ */
+
+#include <linux/skbuff.h>
+
+#ifndef _RMNET_CONFIG_H_
+#define _RMNET_CONFIG_H_
+
+#define RMNET_MAX_LOGICAL_EP 255
+#define RMNET_MAX_VND        32
+
+/* Information about the next device to deliver the packet to.
+ * Exact usage of this parameter depends on the rmnet_mode.
+ */
+struct rmnet_endpoint {
+	u8 rmnet_mode;
+	u8 mux_id;
+	struct net_device *egress_dev;
+};
+
+/* One instance of this structure is instantiated for each real_dev associated
+ * with rmnet.
+ */
+struct rmnet_real_dev_info {
+	struct net_device *dev;
+	struct rmnet_endpoint local_ep;
+	struct rmnet_endpoint muxed_ep[RMNET_MAX_LOGICAL_EP];
+	u32 ingress_data_format;
+	u32 egress_data_format;
+	struct net_device *rmnet_devices[RMNET_MAX_VND];
+};
+
+extern struct rtnl_link_ops rmnet_link_ops;
+
+struct rmnet_priv {
+	struct rmnet_endpoint local_ep;
+};
+
+struct rmnet_real_dev_info*
+rmnet_get_real_dev_info(struct net_device *real_dev);
+
+#endif /* _RMNET_CONFIG_H_ */
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c
new file mode 100644
index 0000000..be2bd69
--- /dev/null
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c
@@ -0,0 +1,276 @@
+/* Copyright (c) 2013-2017, The Linux Foundation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 and
+ * only version 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * RMNET Data ingress/egress handler
+ *
+ */
+
+#include <linux/netdevice.h>
+#include <linux/netdev_features.h>
+#include "rmnet_private.h"
+#include "rmnet_config.h"
+#include "rmnet_vnd.h"
+#include "rmnet_map.h"
+#include "rmnet_handlers.h"
+
+#define RMNET_IP_VERSION_4 0x40
+#define RMNET_IP_VERSION_6 0x60
+
+/* Helper Functions */
+
+static void rmnet_set_skb_proto(struct sk_buff *skb)
+{
+	switch (skb->data[0] & 0xF0) {
+	case RMNET_IP_VERSION_4:
+		skb->protocol = htons(ETH_P_IP);
+		break;
+	case RMNET_IP_VERSION_6:
+		skb->protocol = htons(ETH_P_IPV6);
+		break;
+	default:
+		skb->protocol = htons(ETH_P_MAP);
+		break;
+	}
+}
+
+/* Generic handler */
+
+static rx_handler_result_t
+rmnet_bridge_handler(struct sk_buff *skb, struct rmnet_endpoint *ep)
+{
+	if (!ep->egress_dev)
+		kfree_skb(skb);
+	else
+		rmnet_egress_handler(skb, ep);
+
+	return RX_HANDLER_CONSUMED;
+}
+
+static rx_handler_result_t
+rmnet_deliver_skb(struct sk_buff *skb, struct rmnet_endpoint *ep)
+{
+	switch (ep->rmnet_mode) {
+	case RMNET_EPMODE_NONE:
+		return RX_HANDLER_PASS;
+
+	case RMNET_EPMODE_BRIDGE:
+		return rmnet_bridge_handler(skb, ep);
+
+	case RMNET_EPMODE_VND:
+		skb_reset_transport_header(skb);
+		skb_reset_network_header(skb);
+		switch (rmnet_vnd_rx_fixup(skb, skb->dev)) {
+		case RX_HANDLER_CONSUMED:
+			return RX_HANDLER_CONSUMED;
+
+		case RX_HANDLER_PASS:
+			skb->pkt_type = PACKET_HOST;
+			skb_set_mac_header(skb, 0);
+			netif_receive_skb(skb);
+			return RX_HANDLER_CONSUMED;
+		}
+		return RX_HANDLER_PASS;
+
+	default:
+		kfree_skb(skb);
+		return RX_HANDLER_CONSUMED;
+	}
+}
+
+static rx_handler_result_t
+rmnet_ingress_deliver_packet(struct sk_buff *skb,
+			     struct rmnet_real_dev_info *rdinfo)
+{
+	if (!rdinfo) {
+		kfree_skb(skb);
+		return RX_HANDLER_CONSUMED;
+	}
+
+	skb->dev = rdinfo->local_ep.egress_dev;
+
+	return rmnet_deliver_skb(skb, &rdinfo->local_ep);
+}
+
+/* MAP handler */
+
+static rx_handler_result_t
+__rmnet_map_ingress_handler(struct sk_buff *skb,
+			    struct rmnet_real_dev_info *rdinfo)
+{
+	struct rmnet_endpoint *ep;
+	u8 mux_id;
+	u16 len;
+
+	if (RMNET_MAP_GET_CD_BIT(skb)) {
+		if (rdinfo->ingress_data_format
+		    & RMNET_INGRESS_FORMAT_MAP_COMMANDS)
+			return rmnet_map_command(skb, rdinfo);
+
+		kfree_skb(skb);
+		return RX_HANDLER_CONSUMED;
+	}
+
+	mux_id = RMNET_MAP_GET_MUX_ID(skb);
+	len = RMNET_MAP_GET_LENGTH(skb) - RMNET_MAP_GET_PAD(skb);
+
+	if (mux_id >= RMNET_MAX_LOGICAL_EP) {
+		kfree_skb(skb);
+		return RX_HANDLER_CONSUMED;
+	}
+
+	ep = &rdinfo->muxed_ep[mux_id];
+
+	if (rdinfo->ingress_data_format & RMNET_INGRESS_FORMAT_DEMUXING)
+		skb->dev = ep->egress_dev;
+
+	/* Subtract MAP header */
+	skb_pull(skb, sizeof(struct rmnet_map_header));
+	skb_trim(skb, len);
+	rmnet_set_skb_proto(skb);
+	return rmnet_deliver_skb(skb, ep);
+}
+
+static rx_handler_result_t
+rmnet_map_ingress_handler(struct sk_buff *skb,
+			  struct rmnet_real_dev_info *rdinfo)
+{
+	struct sk_buff *skbn;
+	int rc;
+
+	if (rdinfo->ingress_data_format & RMNET_INGRESS_FORMAT_DEAGGREGATION) {
+		while ((skbn = rmnet_map_deaggregate(skb, rdinfo)) != NULL)
+			__rmnet_map_ingress_handler(skbn, rdinfo);
+
+		consume_skb(skb);
+		rc = RX_HANDLER_CONSUMED;
+	} else {
+		rc = __rmnet_map_ingress_handler(skb, rdinfo);
+	}
+
+	return rc;
+}
+
+static int rmnet_map_egress_handler(struct sk_buff *skb,
+				    struct rmnet_real_dev_info *rdinfo,
+				    struct rmnet_endpoint *ep,
+				    struct net_device *orig_dev)
+{
+	int required_headroom, additional_header_len;
+	struct rmnet_map_header *map_header;
+
+	additional_header_len = 0;
+	required_headroom = sizeof(struct rmnet_map_header);
+
+	if (skb_headroom(skb) < required_headroom) {
+		if (pskb_expand_head(skb, required_headroom, 0, GFP_KERNEL))
+			return RMNET_MAP_CONSUMED;
+	}
+
+	map_header = rmnet_map_add_map_header(skb, additional_header_len, 0);
+	if (!map_header)
+		return RMNET_MAP_CONSUMED;
+
+	if (rdinfo->egress_data_format & RMNET_EGRESS_FORMAT_MUXING) {
+		if (ep->mux_id == 0xff)
+			map_header->mux_id = 0;
+		else
+			map_header->mux_id = ep->mux_id;
+	}
+
+	skb->protocol = htons(ETH_P_MAP);
+
+	return RMNET_MAP_SUCCESS;
+}
+
+/* Ingress / Egress Entry Points */
+
+/* Processes packet as per ingress data format for receiving device. Logical
+ * endpoint is determined from packet inspection. Packet is then sent to the
+ * egress device listed in the logical endpoint configuration.
+ */
+rx_handler_result_t rmnet_rx_handler(struct sk_buff **pskb)
+{
+	struct rmnet_real_dev_info *rdinfo;
+	struct sk_buff *skb = *pskb;
+	struct net_device *dev;
+	int rc;
+
+	if (!skb)
+		return RX_HANDLER_CONSUMED;
+
+	dev = skb->dev;
+	rdinfo = rmnet_get_real_dev_info(dev);
+
+	if (rdinfo->ingress_data_format & RMNET_INGRESS_FORMAT_MAP) {
+		rc = rmnet_map_ingress_handler(skb, rdinfo);
+	} else {
+		switch (ntohs(skb->protocol)) {
+		case ETH_P_MAP:
+			if (rdinfo->local_ep.rmnet_mode ==
+				RMNET_EPMODE_BRIDGE) {
+				rc = rmnet_ingress_deliver_packet(skb, rdinfo);
+			} else {
+				kfree_skb(skb);
+				rc = RX_HANDLER_CONSUMED;
+			}
+			break;
+
+		case ETH_P_IP:
+		case ETH_P_IPV6:
+			rc = rmnet_ingress_deliver_packet(skb, rdinfo);
+			break;
+
+		default:
+			rc = RX_HANDLER_PASS;
+		}
+	}
+
+	return rc;
+}
+
+/* Modifies packet as per logical endpoint configuration and egress data format
+ * for egress device configured in logical endpoint. Packet is then transmitted
+ * on the egress device.
+ */
+void rmnet_egress_handler(struct sk_buff *skb,
+			  struct rmnet_endpoint *ep)
+{
+	struct rmnet_real_dev_info *rdinfo;
+	struct net_device *orig_dev;
+
+	orig_dev = skb->dev;
+	skb->dev = ep->egress_dev;
+
+	rdinfo = rmnet_get_real_dev_info(skb->dev);
+	if (!rdinfo) {
+		kfree_skb(skb);
+		return;
+	}
+
+	if (rdinfo->egress_data_format & RMNET_EGRESS_FORMAT_MAP) {
+		switch (rmnet_map_egress_handler(skb, rdinfo, ep, orig_dev)) {
+		case RMNET_MAP_CONSUMED:
+			return;
+
+		case RMNET_MAP_SUCCESS:
+			break;
+
+		default:
+			kfree_skb(skb);
+			return;
+		}
+	}
+
+	if (ep->rmnet_mode == RMNET_EPMODE_VND)
+		rmnet_vnd_tx_fixup(skb, orig_dev);
+
+	dev_queue_xmit(skb);
+}
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.h b/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.h
new file mode 100644
index 0000000..f2638cf
--- /dev/null
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.h
@@ -0,0 +1,26 @@
+/* Copyright (c) 2013, 2016-2017 The Linux Foundation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 and
+ * only version 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * RMNET Data ingress/egress handler
+ *
+ */
+
+#ifndef _RMNET_HANDLERS_H_
+#define _RMNET_HANDLERS_H_
+
+#include "rmnet_config.h"
+
+void rmnet_egress_handler(struct sk_buff *skb,
+			  struct rmnet_endpoint *ep);
+
+rx_handler_result_t rmnet_rx_handler(struct sk_buff **pskb);
+
+#endif /* _RMNET_HANDLERS_H_ */
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_map.h b/drivers/net/ethernet/qualcomm/rmnet/rmnet_map.h
new file mode 100644
index 0000000..2aabad2
--- /dev/null
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_map.h
@@ -0,0 +1,88 @@
+/* Copyright (c) 2013-2017, The Linux Foundation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 and
+ * only version 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#ifndef _RMNET_MAP_H_
+#define _RMNET_MAP_H_
+
+struct rmnet_map_control_command {
+	u8  command_name;
+	u8  cmd_type:2;
+	u8  reserved:6;
+	u16 reserved2;
+	u32 transaction_id;
+	union {
+		struct {
+			u16 ip_family:2;
+			u16 reserved:14;
+			u16 flow_control_seq_num;
+			u32 qos_id;
+		} flow_control;
+		u8 data[0];
+	};
+}  __aligned(1);
+
+enum rmnet_map_results {
+	RMNET_MAP_SUCCESS,
+	RMNET_MAP_CONSUMED,
+	RMNET_MAP_GENERAL_FAILURE,
+	RMNET_MAP_NOT_ENABLED,
+	RMNET_MAP_FAILED_AGGREGATION,
+	RMNET_MAP_FAILED_MUX
+};
+
+enum rmnet_map_commands {
+	RMNET_MAP_COMMAND_NONE,
+	RMNET_MAP_COMMAND_FLOW_DISABLE,
+	RMNET_MAP_COMMAND_FLOW_ENABLE,
+	/* These should always be the last 2 elements */
+	RMNET_MAP_COMMAND_UNKNOWN,
+	RMNET_MAP_COMMAND_ENUM_LENGTH
+};
+
+struct rmnet_map_header {
+	u8  pad_len:6;
+	u8  reserved_bit:1;
+	u8  cd_bit:1;
+	u8  mux_id;
+	u16 pkt_len;
+}  __aligned(1);
+
+#define RMNET_MAP_GET_MUX_ID(Y) (((struct rmnet_map_header *) \
+				 (Y)->data)->mux_id)
+#define RMNET_MAP_GET_CD_BIT(Y) (((struct rmnet_map_header *) \
+				(Y)->data)->cd_bit)
+#define RMNET_MAP_GET_PAD(Y) (((struct rmnet_map_header *) \
+				(Y)->data)->pad_len)
+#define RMNET_MAP_GET_CMD_START(Y) ((struct rmnet_map_control_command *) \
+				    ((Y)->data + \
+				      sizeof(struct rmnet_map_header)))
+#define RMNET_MAP_GET_LENGTH(Y) (ntohs(((struct rmnet_map_header *) \
+					(Y)->data)->pkt_len))
+
+#define RMNET_MAP_COMMAND_REQUEST     0
+#define RMNET_MAP_COMMAND_ACK         1
+#define RMNET_MAP_COMMAND_UNSUPPORTED 2
+#define RMNET_MAP_COMMAND_INVALID     3
+
+#define RMNET_MAP_NO_PAD_BYTES        0
+#define RMNET_MAP_ADD_PAD_BYTES       1
+
+u8 rmnet_map_demultiplex(struct sk_buff *skb);
+struct sk_buff *rmnet_map_deaggregate(struct sk_buff *skb,
+				      struct rmnet_real_dev_info *rdinfo);
+
+struct rmnet_map_header *rmnet_map_add_map_header(struct sk_buff *skb,
+						  int hdrlen, int pad);
+rx_handler_result_t rmnet_map_command(struct sk_buff *skb,
+				      struct rmnet_real_dev_info *rdinfo);
+
+#endif /* _RMNET_MAP_H_ */
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_map_command.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_map_command.c
new file mode 100644
index 0000000..2de93e5
--- /dev/null
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_map_command.c
@@ -0,0 +1,116 @@
+/* Copyright (c) 2013-2017, The Linux Foundation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 and
+ * only version 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#include <linux/netdevice.h>
+#include "rmnet_config.h"
+#include "rmnet_map.h"
+#include "rmnet_private.h"
+#include "rmnet_vnd.h"
+
+static u8 rmnet_map_do_flow_control(struct sk_buff *skb,
+				    struct rmnet_real_dev_info *rdinfo,
+				    int enable)
+{
+	struct rmnet_map_control_command *cmd;
+	struct rmnet_endpoint *ep;
+	struct net_device *vnd;
+	u16 ip_family;
+	u16 fc_seq;
+	u32 qos_id;
+	u8 mux_id;
+	int r;
+
+	if (unlikely(!skb || !rdinfo))
+		return RX_HANDLER_CONSUMED;
+
+	mux_id = RMNET_MAP_GET_MUX_ID(skb);
+	cmd = RMNET_MAP_GET_CMD_START(skb);
+
+	if (mux_id >= RMNET_MAX_LOGICAL_EP) {
+		kfree_skb(skb);
+		return RX_HANDLER_CONSUMED;
+	}
+
+	ep = &rdinfo->muxed_ep[mux_id];
+	vnd = ep->egress_dev;
+
+	ip_family = cmd->flow_control.ip_family;
+	fc_seq = ntohs(cmd->flow_control.flow_control_seq_num);
+	qos_id = ntohl(cmd->flow_control.qos_id);
+
+	/* Ignore the ip family and pass the sequence number for both v4 and v6
+	 * sequence. User space does not support creating dedicated flows for
+	 * the 2 protocols
+	 */
+	r = rmnet_vnd_do_flow_control(rdinfo, vnd, enable);
+	if (r) {
+		kfree_skb(skb);
+		return RMNET_MAP_COMMAND_UNSUPPORTED;
+	} else {
+		return RMNET_MAP_COMMAND_ACK;
+	}
+}
+
+static void rmnet_map_send_ack(struct sk_buff *skb,
+			       unsigned char type,
+			       struct rmnet_real_dev_info *rdinfo)
+{
+	struct rmnet_map_control_command *cmd;
+	int xmit_status;
+
+	if (unlikely(!skb))
+		return;
+
+	skb->protocol = htons(ETH_P_MAP);
+
+	cmd = RMNET_MAP_GET_CMD_START(skb);
+	cmd->cmd_type = type & 0x03;
+
+	netif_tx_lock(skb->dev);
+	xmit_status = skb->dev->netdev_ops->ndo_start_xmit(skb, skb->dev);
+	netif_tx_unlock(skb->dev);
+}
+
+/* Process MAP command frame and send N/ACK message as appropriate. Message cmd
+ * name is decoded here and appropriate handler is called.
+ */
+rx_handler_result_t rmnet_map_command(struct sk_buff *skb,
+				      struct rmnet_real_dev_info *rdinfo)
+{
+	struct rmnet_map_control_command *cmd;
+	unsigned char command_name;
+	unsigned char rc = 0;
+
+	if (unlikely(!skb))
+		return RX_HANDLER_CONSUMED;
+
+	cmd = RMNET_MAP_GET_CMD_START(skb);
+	command_name = cmd->command_name;
+
+	switch (command_name) {
+	case RMNET_MAP_COMMAND_FLOW_ENABLE:
+		rc = rmnet_map_do_flow_control(skb, rdinfo, 1);
+		break;
+
+	case RMNET_MAP_COMMAND_FLOW_DISABLE:
+		rc = rmnet_map_do_flow_control(skb, rdinfo, 0);
+		break;
+
+	default:
+		rc = RMNET_MAP_COMMAND_UNSUPPORTED;
+		kfree_skb(skb);
+		break;
+	}
+	if (rc == RMNET_MAP_COMMAND_ACK)
+		rmnet_map_send_ack(skb, rc, rdinfo);
+	return RX_HANDLER_CONSUMED;
+}
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_map_data.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_map_data.c
new file mode 100644
index 0000000..6d16c6ac
--- /dev/null
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_map_data.c
@@ -0,0 +1,105 @@
+/* Copyright (c) 2013-2017, The Linux Foundation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 and
+ * only version 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * RMNET Data MAP protocol
+ *
+ */
+
+#include <linux/netdevice.h>
+#include "rmnet_config.h"
+#include "rmnet_map.h"
+#include "rmnet_private.h"
+
+#define RMNET_MAP_DEAGGR_SPACING  64
+#define RMNET_MAP_DEAGGR_HEADROOM (RMNET_MAP_DEAGGR_SPACING / 2)
+
+/* Adds MAP header to front of skb->data
+ * Padding is calculated and set appropriately in MAP header. Mux ID is
+ * initialized to 0.
+ */
+struct rmnet_map_header *rmnet_map_add_map_header(struct sk_buff *skb,
+						  int hdrlen, int pad)
+{
+	struct rmnet_map_header *map_header;
+	u32 padding, map_datalen;
+	u8 *padbytes;
+
+	if (skb_headroom(skb) < sizeof(struct rmnet_map_header))
+		return 0;
+
+	map_datalen = skb->len - hdrlen;
+	map_header = (struct rmnet_map_header *)
+			skb_push(skb, sizeof(struct rmnet_map_header));
+	memset(map_header, 0, sizeof(struct rmnet_map_header));
+
+	if (pad == RMNET_MAP_NO_PAD_BYTES) {
+		map_header->pkt_len = htons(map_datalen);
+		return map_header;
+	}
+
+	padding = ALIGN(map_datalen, 4) - map_datalen;
+
+	if (padding == 0)
+		goto done;
+
+	if (skb_tailroom(skb) < padding)
+		return 0;
+
+	padbytes = (u8 *)skb_put(skb, padding);
+	memset(padbytes, 0, padding);
+
+done:
+	map_header->pkt_len = htons(map_datalen + padding);
+	map_header->pad_len = padding & 0x3F;
+
+	return map_header;
+}
+
+/* Deaggregates a single packet
+ * A whole new buffer is allocated for each portion of an aggregated frame.
+ * Caller should keep calling deaggregate() on the source skb until 0 is
+ * returned, indicating that there are no more packets to deaggregate. Caller
+ * is responsible for freeing the original skb.
+ */
+struct sk_buff *rmnet_map_deaggregate(struct sk_buff *skb,
+				      struct rmnet_real_dev_info *rdinfo)
+{
+	struct rmnet_map_header *maph;
+	struct sk_buff *skbn;
+	u32 packet_len;
+
+	if (skb->len == 0)
+		return 0;
+
+	maph = (struct rmnet_map_header *)skb->data;
+	packet_len = ntohs(maph->pkt_len) + sizeof(struct rmnet_map_header);
+
+	if (((int)skb->len - (int)packet_len) < 0)
+		return 0;
+
+	skbn = alloc_skb(packet_len + RMNET_MAP_DEAGGR_SPACING, GFP_ATOMIC);
+	if (!skbn)
+		return 0;
+
+	skbn->dev = skb->dev;
+	skb_reserve(skbn, RMNET_MAP_DEAGGR_HEADROOM);
+	skb_put(skbn, packet_len);
+	memcpy(skbn->data, skb->data, packet_len);
+	skb_pull(skb, packet_len);
+
+	/* Some hardware can send us empty frames. Catch them */
+	if (ntohs(maph->pkt_len) == 0) {
+		kfree_skb(skb);
+		return 0;
+	}
+
+	return skbn;
+}
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_private.h b/drivers/net/ethernet/qualcomm/rmnet/rmnet_private.h
new file mode 100644
index 0000000..ed820b5
--- /dev/null
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_private.h
@@ -0,0 +1,45 @@
+/* Copyright (c) 2013-2014, 2016-2017 The Linux Foundation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 and
+ * only version 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#ifndef _RMNET_PRIVATE_H_
+#define _RMNET_PRIVATE_H_
+
+#define RMNET_MAX_VND              32
+#define RMNET_MAX_PACKET_SIZE      16384
+#define RMNET_DFLT_PACKET_SIZE     1500
+#define RMNET_NEEDED_HEADROOM      16
+#define RMNET_TX_QUEUE_LEN         1000
+
+/* Constants */
+#define RMNET_EGRESS_FORMAT__RESERVED__         BIT(0)
+#define RMNET_EGRESS_FORMAT_MAP                 BIT(1)
+#define RMNET_EGRESS_FORMAT_AGGREGATION         BIT(2)
+#define RMNET_EGRESS_FORMAT_MUXING              BIT(3)
+#define RMNET_EGRESS_FORMAT_MAP_CKSUMV3         BIT(4)
+#define RMNET_EGRESS_FORMAT_MAP_CKSUMV4         BIT(5)
+
+#define RMNET_INGRESS_FIX_ETHERNET              BIT(0)
+#define RMNET_INGRESS_FORMAT_MAP                BIT(1)
+#define RMNET_INGRESS_FORMAT_DEAGGREGATION      BIT(2)
+#define RMNET_INGRESS_FORMAT_DEMUXING           BIT(3)
+#define RMNET_INGRESS_FORMAT_MAP_COMMANDS       BIT(4)
+#define RMNET_INGRESS_FORMAT_MAP_CKSUMV3        BIT(5)
+#define RMNET_INGRESS_FORMAT_MAP_CKSUMV4        BIT(6)
+
+/* Pass the frame up the stack with no modifications to skb->dev */
+#define RMNET_EPMODE_NONE (0)
+/* Replace skb->dev to a virtual rmnet device and pass up the stack */
+#define RMNET_EPMODE_VND (1)
+/* Pass the frame directly to another device with dev_queue_xmit() */
+#define RMNET_EPMODE_BRIDGE (2)
+
+#endif /* _RMNET_PRIVATE_H_ */
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
new file mode 100644
index 0000000..2813d84
--- /dev/null
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
@@ -0,0 +1,263 @@
+/* Copyright (c) 2013-2017, The Linux Foundation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 and
+ * only version 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ *
+ * RMNET Data virtual network driver
+ *
+ */
+
+#include <linux/etherdevice.h>
+#include <linux/if_arp.h>
+#include <net/pkt_sched.h>
+#include "rmnet_config.h"
+#include "rmnet_handlers.h"
+#include "rmnet_private.h"
+#include "rmnet_map.h"
+#include "rmnet_vnd.h"
+
+/* RX/TX Fixup */
+
+int rmnet_vnd_rx_fixup(struct sk_buff *skb, struct net_device *dev)
+{
+	if (unlikely(!dev || !skb))
+		return RX_HANDLER_CONSUMED;
+
+	dev->stats.rx_packets++;
+	dev->stats.rx_bytes += skb->len;
+
+	return RX_HANDLER_PASS;
+}
+
+int rmnet_vnd_tx_fixup(struct sk_buff *skb, struct net_device *dev)
+{
+	struct rmnet_priv *priv;
+
+	priv = netdev_priv(dev);
+
+	if (unlikely(!dev || !skb))
+		return RX_HANDLER_CONSUMED;
+
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += skb->len;
+
+	return RX_HANDLER_PASS;
+}
+
+/* Network Device Operations */
+
+static netdev_tx_t rmnet_vnd_start_xmit(struct sk_buff *skb,
+					struct net_device *dev)
+{
+	struct rmnet_priv *priv;
+
+	priv = netdev_priv(dev);
+	if (priv->local_ep.egress_dev) {
+		rmnet_egress_handler(skb, &priv->local_ep);
+	} else {
+		dev->stats.tx_dropped++;
+		kfree_skb(skb);
+	}
+	return NETDEV_TX_OK;
+}
+
+static int rmnet_vnd_change_mtu(struct net_device *rmnet_dev, int new_mtu)
+{
+	if (new_mtu < 0 || new_mtu > RMNET_MAX_PACKET_SIZE)
+		return -EINVAL;
+
+	rmnet_dev->mtu = new_mtu;
+	return 0;
+}
+
+static const struct net_device_ops rmnet_vnd_ops = {
+	.ndo_start_xmit = rmnet_vnd_start_xmit,
+	.ndo_change_mtu = rmnet_vnd_change_mtu,
+};
+
+/* Called by kernel whenever a new rmnet<n> device is created. Sets MTU,
+ * flags, ARP type, needed headroom, etc...
+ */
+void rmnet_vnd_setup(struct net_device *rmnet_dev)
+{
+	struct rmnet_priv *priv;
+
+	/* Clear out private data */
+	priv = netdev_priv(rmnet_dev);
+	memset(priv, 0, sizeof(struct rmnet_priv));
+
+	netdev_info(rmnet_dev, "Setting up device %s\n", rmnet_dev->name);
+
+	rmnet_dev->netdev_ops = &rmnet_vnd_ops;
+	rmnet_dev->mtu = RMNET_DFLT_PACKET_SIZE;
+	rmnet_dev->needed_headroom = RMNET_NEEDED_HEADROOM;
+	random_ether_addr(rmnet_dev->dev_addr);
+	rmnet_dev->tx_queue_len = RMNET_TX_QUEUE_LEN;
+
+	/* Raw IP mode */
+	rmnet_dev->header_ops = 0;  /* No header */
+	rmnet_dev->type = ARPHRD_RAWIP;
+	rmnet_dev->hard_header_len = 0;
+	rmnet_dev->flags &= ~(IFF_BROADCAST | IFF_MULTICAST);
+
+	rmnet_dev->needs_free_netdev = true;
+}
+
+/* Exposed API */
+
+int rmnet_vnd_newlink(struct net_device *real_dev, int id,
+		      struct net_device *rmnet_dev)
+{
+	struct rmnet_real_dev_info *rdinfo;
+	int rc;
+
+	rdinfo = rmnet_get_real_dev_info(real_dev);
+
+	if (rdinfo->rmnet_devices[id])
+		return -EINVAL;
+
+	rc = register_netdevice(rmnet_dev);
+	if (!rc) {
+		rdinfo->rmnet_devices[id] = rmnet_dev;
+		rmnet_dev->rtnl_link_ops = &rmnet_link_ops;
+	}
+	return rc;
+}
+
+/* Unregisters the virtual network device node and frees it.
+ * unregister_netdev locks the rtnl mutex, so the mutex must not be locked
+ * by the caller of the function. unregister_netdev enqueues the request to
+ * unregister the device into a TODO queue. The requests in the TODO queue
+ * are only done after rtnl mutex is unlocked, therefore free_netdev has to
+ * called after unlocking rtnl mutex.
+ */
+int rmnet_vnd_free_dev(struct net_device *real_dev, int id)
+{
+	struct rmnet_real_dev_info *rdinfo;
+	struct net_device *rmnet_dev;
+	struct rmnet_endpoint *ep;
+
+	rdinfo = rmnet_get_real_dev_info(real_dev);
+
+	rtnl_lock();
+	if (id < 0 || id >= RMNET_MAX_VND || !rdinfo->rmnet_devices[id]) {
+		rtnl_unlock();
+		return -EINVAL;
+	}
+
+	ep = rmnet_vnd_get_endpoint(rdinfo->rmnet_devices[id]);
+	if (ep) {
+		rtnl_unlock();
+		return -EINVAL;
+	}
+
+	rmnet_dev = rdinfo->rmnet_devices[id];
+	rdinfo->rmnet_devices[id] = 0;
+	rtnl_unlock();
+
+	if (rmnet_dev) {
+		unregister_netdev(rmnet_dev);
+		free_netdev(rmnet_dev);
+		return 0;
+	} else {
+		return -EINVAL;
+	}
+}
+
+int rmnet_vnd_remove_ref_dev(struct net_device *real_dev, int id)
+{
+	struct rmnet_real_dev_info *rdinfo;
+	struct rmnet_endpoint *ep;
+
+	rdinfo = rmnet_get_real_dev_info(real_dev);
+	if (id < 0 || id >= RMNET_MAX_VND || !rdinfo->rmnet_devices[id])
+		return -EINVAL;
+
+	ep = rmnet_vnd_get_endpoint(rdinfo->rmnet_devices[id]);
+	rdinfo->rmnet_devices[id] = 0;
+	return 0;
+}
+
+/* Searches through list of known RmNet virtual devices. This function is O(n)
+ * and should not be used in the data path.
+ *
+ * To get the read id, subtract this result by 1.
+ */
+int rmnet_vnd_get_mux(struct net_device *real_dev,
+		      struct net_device *rmnet_dev)
+{
+	/* This is not an efficient search, but, this will only be called in
+	 * a configuration context, and the list is small.
+	 */
+	struct rmnet_real_dev_info *rdinfo;
+	int i;
+
+	rdinfo = rmnet_get_real_dev_info(real_dev);
+
+	if (!rmnet_dev)
+		return 0;
+
+	for (i = 0; i < RMNET_MAX_VND; i++)
+		if (rmnet_dev == rdinfo->rmnet_devices[i])
+			return i + 1;
+
+	return 0;
+}
+
+/* Gets the logical endpoint configuration for a RmNet virtual network device
+ * node. Caller should confirm that devices is a RmNet VND before calling.
+ */
+struct rmnet_endpoint *rmnet_vnd_get_endpoint(struct net_device *rmnet_dev)
+{
+	struct rmnet_priv *priv;
+
+	if (!rmnet_dev)
+		return 0;
+
+	priv = netdev_priv(rmnet_dev);
+	if (!priv)
+		return 0;
+
+	return &priv->local_ep;
+}
+
+int rmnet_vnd_do_flow_control(struct rmnet_real_dev_info *rdinfo,
+			      struct net_device *rmnet_dev, int enable)
+{
+	struct rmnet_priv *priv;
+
+	priv = netdev_priv(rmnet_dev);
+	if (unlikely(!priv))
+		return -EINVAL;
+
+	netdev_info(rmnet_dev, "Setting VND TX queue state to %d\n", enable);
+	/* Although we expect similar number of enable/disable
+	 * commands, optimize for the disable. That is more
+	 * latency sensitive than enable
+	 */
+	if (unlikely(enable))
+		netif_wake_queue(rmnet_dev);
+	else
+		netif_stop_queue(rmnet_dev);
+
+	return 0;
+}
+
+struct net_device *rmnet_vnd_get_by_id(struct net_device *real_dev, int id)
+{
+	struct rmnet_real_dev_info *rdinfo;
+
+	rdinfo = rmnet_get_real_dev_info(real_dev);
+
+	if (id < 0 || id >= RMNET_MAX_VND)
+		return 0;
+
+	return rdinfo->rmnet_devices[id];
+}
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.h b/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.h
new file mode 100644
index 0000000..3020646
--- /dev/null
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.h
@@ -0,0 +1,32 @@
+/* Copyright (c) 2013-2017, The Linux Foundation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 and
+ * only version 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * RMNET Data Virtual Network Device APIs
+ *
+ */
+
+#ifndef _RMNET_VND_H_
+#define _RMNET_VND_H_
+
+int rmnet_vnd_do_flow_control(struct rmnet_real_dev_info *rdinfo,
+			      struct net_device *dev, int enable);
+struct rmnet_endpoint *rmnet_vnd_get_endpoint(struct net_device *dev);
+int rmnet_vnd_free_dev(struct net_device *real_dev, int id);
+int rmnet_vnd_remove_ref_dev(struct net_device *real_dev, int id);
+int rmnet_vnd_rx_fixup(struct sk_buff *skb, struct net_device *dev);
+int rmnet_vnd_tx_fixup(struct sk_buff *skb, struct net_device *dev);
+int rmnet_vnd_get_mux(struct net_device *real_dev,
+		      struct net_device *rmnet_dev);
+struct net_device *rmnet_vnd_get_by_id(struct net_device *real_dev, int id);
+void rmnet_vnd_setup(struct net_device *dev);
+int rmnet_vnd_newlink(struct net_device *real_dev, int id,
+		      struct net_device *new_device);
+#endif /* _RMNET_VND_H_ */
-- 
1.9.1
