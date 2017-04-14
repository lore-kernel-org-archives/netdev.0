From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH net-next 1/1 v3] drivers: net: rmnet: Initial implementation
Date: Thu, 13 Apr 2017 23:05:29 -0600
Message-ID: <1492146329-4304-2-git-send-email-subashab@codeaurora.org>
References: <1492146329-4304-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
To: netdev@vger.kernel.org, davem@davemloft.net,
        fengguang.wu@intel.com, dcbw@redhat.com, jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:59168 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751546AbdDNFFw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 01:05:52 -0400
In-Reply-To: <1492146329-4304-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RmNet driver provides a transport agnostic MAP (multiplexing and
aggregation protocol) support in embedded module. Module provides
virtual network devices which can be attached to any IP-mode
physical device. This will be used to provide all MAP functionality
on future hardware in a single consistent location.

Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
---
 Documentation/networking/rmnet.txt    |  83 +++++
 drivers/net/Kconfig                   |   2 +
 drivers/net/Makefile                  |   1 +
 drivers/net/rmnet/Kconfig             |  23 ++
 drivers/net/rmnet/Makefile            |  14 +
 drivers/net/rmnet/rmnet_config.c      | 592 ++++++++++++++++++++++++++++++++++
 drivers/net/rmnet/rmnet_config.h      |  79 +++++
 drivers/net/rmnet/rmnet_handlers.c    | 517 +++++++++++++++++++++++++++++
 drivers/net/rmnet/rmnet_handlers.h    |  24 ++
 drivers/net/rmnet/rmnet_main.c        |  52 +++
 drivers/net/rmnet/rmnet_map.h         | 100 ++++++
 drivers/net/rmnet/rmnet_map_command.c | 180 +++++++++++
 drivers/net/rmnet/rmnet_map_data.c    | 145 +++++++++
 drivers/net/rmnet/rmnet_private.h     |  76 +++++
 drivers/net/rmnet/rmnet_stats.c       |  86 +++++
 drivers/net/rmnet/rmnet_stats.h       |  61 ++++
 drivers/net/rmnet/rmnet_vnd.c         | 353 ++++++++++++++++++++
 drivers/net/rmnet/rmnet_vnd.h         |  34 ++
 include/uapi/linux/Kbuild             |   1 +
 include/uapi/linux/if_arp.h           |   1 +
 include/uapi/linux/if_ether.h         |   4 +-
 include/uapi/linux/rmnet.h            |  34 ++
 22 files changed, 2461 insertions(+), 1 deletion(-)
 create mode 100644 Documentation/networking/rmnet.txt
 create mode 100644 drivers/net/rmnet/Kconfig
 create mode 100644 drivers/net/rmnet/Makefile
 create mode 100644 drivers/net/rmnet/rmnet_config.c
 create mode 100644 drivers/net/rmnet/rmnet_config.h
 create mode 100644 drivers/net/rmnet/rmnet_handlers.c
 create mode 100644 drivers/net/rmnet/rmnet_handlers.h
 create mode 100644 drivers/net/rmnet/rmnet_main.c
 create mode 100644 drivers/net/rmnet/rmnet_map.h
 create mode 100644 drivers/net/rmnet/rmnet_map_command.c
 create mode 100644 drivers/net/rmnet/rmnet_map_data.c
 create mode 100644 drivers/net/rmnet/rmnet_private.h
 create mode 100644 drivers/net/rmnet/rmnet_stats.c
 create mode 100644 drivers/net/rmnet/rmnet_stats.h
 create mode 100644 drivers/net/rmnet/rmnet_vnd.c
 create mode 100644 drivers/net/rmnet/rmnet_vnd.h
 create mode 100644 include/uapi/linux/rmnet.h

diff --git a/Documentation/networking/rmnet.txt b/Documentation/networking/rmnet.txt
new file mode 100644
index 0000000..58d3ea2
--- /dev/null
+++ b/Documentation/networking/rmnet.txt
@@ -0,0 +1,83 @@
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
+https://source.codeaurora.org/quic/la/platform/vendor/qcom-opensource/\
+dataservices/tree/rmnetctl
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 100fbdc..c4ccd6d 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -477,4 +477,6 @@ config FUJITSU_ES
 
 source "drivers/net/hyperv/Kconfig"
 
+source "drivers/net/rmnet/Kconfig"
+
 endif # NETDEVICES
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 98ed4d9..29b3945 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -74,3 +74,4 @@ obj-$(CONFIG_HYPERV_NET) += hyperv/
 obj-$(CONFIG_NTB_NETDEV) += ntb_netdev.o
 
 obj-$(CONFIG_FUJITSU_ES) += fjes/
+obj-$(CONFIG_RMNET) += rmnet/
diff --git a/drivers/net/rmnet/Kconfig b/drivers/net/rmnet/Kconfig
new file mode 100644
index 0000000..63cd477
--- /dev/null
+++ b/drivers/net/rmnet/Kconfig
@@ -0,0 +1,23 @@
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
+if RMNET
+
+config RMNET_DEBUG
+	bool "RmNet Debug Logging"
+	default n
+	---help---
+	  Say Y here if you want RmNet to be able to log packets in main
+	  system log. This should not be enabled on production builds as it can
+	  impact system performance. Note that simply enabling it here will not
+	  enable the logging; it must be enabled at run-time as well.
+endif # RMNET
diff --git a/drivers/net/rmnet/Makefile b/drivers/net/rmnet/Makefile
new file mode 100644
index 0000000..2b6c9cf
--- /dev/null
+++ b/drivers/net/rmnet/Makefile
@@ -0,0 +1,14 @@
+#
+# Makefile for the RMNET module
+#
+
+rmnet-y		 := rmnet_main.o
+rmnet-y		 += rmnet_config.o
+rmnet-y		 += rmnet_vnd.o
+rmnet-y		 += rmnet_handlers.o
+rmnet-y		 += rmnet_map_data.o
+rmnet-y		 += rmnet_map_command.o
+rmnet-y		 += rmnet_stats.o
+obj-$(CONFIG_RMNET) += rmnet.o
+
+CFLAGS_rmnet_main.o := -I$(src)
diff --git a/drivers/net/rmnet/rmnet_config.c b/drivers/net/rmnet/rmnet_config.c
new file mode 100644
index 0000000..a4bc76b
--- /dev/null
+++ b/drivers/net/rmnet/rmnet_config.c
@@ -0,0 +1,592 @@
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
+#include <linux/skbuff.h>
+#include <linux/spinlock.h>
+#include <linux/rmnet.h>
+#include "rmnet_config.h"
+#include "rmnet_handlers.h"
+#include "rmnet_vnd.h"
+#include "rmnet_private.h"
+
+RMNET_LOG_MODULE(RMNET_LOGMASK_CONFIG);
+
+/* Local Definitions and Declarations */
+#define RMNET_LOCAL_LOGICAL_ENDPOINT -1
+
+/* _rmnet_is_physical_endpoint_associated() - Determines if device is associated
+ * @dev:      Device to get check
+ *
+ * Compares device rx_handler callback pointer against known function
+ */
+static inline int _rmnet_is_physical_endpoint_associated(struct net_device *dev)
+{
+	rx_handler_func_t *rx_handler;
+
+	rx_handler = rcu_dereference(dev->rx_handler);
+
+	if (rx_handler == rmnet_rx_handler)
+		return 1;
+	else
+		return 0;
+}
+
+/* _rmnet_get_phys_ep_config() - Get physical ep config for an associated device
+ * @dev:      Device to get endpoint configuration from
+ */
+static inline struct rmnet_phys_ep_conf_s *_rmnet_get_phys_ep_config
+						(struct net_device *dev)
+{
+	if (_rmnet_is_physical_endpoint_associated(dev))
+		return (struct rmnet_phys_ep_conf_s *)
+			rcu_dereference(dev->rx_handler_data);
+	else
+		return 0;
+}
+
+struct rmnet_free_vnd_work {
+	struct work_struct work;
+	int vnd_id[RMNET_MAX_VND];
+	int count;
+};
+
+/* _rmnet_get_logical_ep() - Gets the logical end point configuration
+ * structure for a network device
+ * @dev:             Device to get endpoint configuration from
+ * @config_id:       Logical endpoint id on device
+ * Retrieves the logical_endpoint_config structure.
+ */
+static struct rmnet_logical_ep_conf_s *_rmnet_get_logical_ep
+	(struct net_device *dev, int config_id)
+{
+	struct rmnet_phys_ep_conf_s *config;
+	struct rmnet_logical_ep_conf_s *epconfig_l;
+
+	if (rmnet_vnd_is_vnd(dev)) {
+		epconfig_l = rmnet_vnd_get_le_config(dev);
+	} else {
+		config = _rmnet_get_phys_ep_config(dev);
+
+		if (!config)
+			return NULL;
+
+		if (config_id == RMNET_LOCAL_LOGICAL_ENDPOINT)
+			epconfig_l = &config->local_ep;
+		else
+			epconfig_l = &config->muxed_ep[config_id];
+	}
+
+	return epconfig_l;
+}
+
+/* rmnet_unassociate_network_device() - Unassociate network device
+ * @dev:      Device to unassociate
+ *
+ * Frees all structures generate for device. Unregisters rx_handler
+ */
+static int rmnet_unassociate_network_device(struct net_device *dev)
+{
+	struct rmnet_phys_ep_conf_s *config;
+	int config_id = RMNET_LOCAL_LOGICAL_ENDPOINT;
+	struct rmnet_logical_ep_conf_s *epconfig_l;
+
+	ASSERT_RTNL();
+
+	LOGL("(%s);", dev->name);
+
+	if (!dev || !_rmnet_is_physical_endpoint_associated(dev))
+		return -EINVAL;
+
+	for (; config_id < RMNET_MAX_LOGICAL_EP; config_id++) {
+		epconfig_l = _rmnet_get_logical_ep(dev, config_id);
+		if (epconfig_l && epconfig_l->refcount)
+			return -EINVAL;
+	}
+
+	config = (struct rmnet_phys_ep_conf_s *)
+		  rcu_dereference(dev->rx_handler_data);
+
+	if (!config)
+		return -EINVAL;
+
+	kfree(config);
+
+	netdev_rx_handler_unregister(dev);
+
+	dev_put(dev);
+	return 0;
+}
+
+/* rmnet_set_ingress_data_format() - Set ingress data format on network device
+ * @dev:                 Device to ingress data format on
+ * @egress_data_format:  32-bit unsigned bitmask of ingress format
+ *
+ * Network device must already have association with RmNet Data driver
+ */
+static int rmnet_set_ingress_data_format(struct net_device *dev,
+					 u32 ingress_data_format)
+{
+	struct rmnet_phys_ep_conf_s *config;
+
+	ASSERT_RTNL();
+
+	LOGL("(%s,0x%08X);", dev->name, ingress_data_format);
+
+	if (!dev)
+		return -EINVAL;
+
+	config = _rmnet_get_phys_ep_config(dev);
+	if (!config)
+		return -EINVAL;
+
+	config->ingress_data_format = ingress_data_format;
+
+	return 0;
+}
+
+/* rmnet_set_egress_data_format() - Set egress data format on network device
+ * @dev:                 Device to egress data format on
+ * @egress_data_format:  32-bit unsigned bitmask of egress format
+ *
+ * Network device must already have association with RmNet Data driver
+ */
+static int rmnet_set_egress_data_format(struct net_device *dev,
+					u32 egress_data_format,
+					u16 agg_size,
+					u16 agg_count)
+{
+	struct rmnet_phys_ep_conf_s *config;
+
+	ASSERT_RTNL();
+
+	LOGL("(%s,0x%08X, %d, %d);",
+	     dev->name, egress_data_format, agg_size, agg_count);
+
+	if (!dev)
+		return -EINVAL;
+
+	config = _rmnet_get_phys_ep_config(dev);
+	if (!config)
+		return -EINVAL;
+
+	config->egress_data_format = egress_data_format;
+
+	return 0;
+}
+
+/* rmnet_associate_network_device() - Associate network device
+ * @dev:      Device to register with RmNet data
+ *
+ * Typically used on physical network devices. Registers RX handler and private
+ * metadata structures.
+ */
+static int rmnet_associate_network_device(struct net_device *dev)
+{
+	struct rmnet_phys_ep_conf_s *config;
+	int rc;
+
+	ASSERT_RTNL();
+
+	LOGL("(%s);\n", dev->name);
+
+	if (!dev || _rmnet_is_physical_endpoint_associated(dev) ||
+	    rmnet_vnd_is_vnd(dev)) {
+		LOGM("cannot register with this dev");
+		return -EINVAL;
+	}
+
+	config = kmalloc(sizeof(*config), GFP_ATOMIC);
+	if (!config)
+		return -ENOMEM;
+
+	memset(config, 0, sizeof(struct rmnet_phys_ep_conf_s));
+	config->dev = dev;
+
+	rc = netdev_rx_handler_register(dev, rmnet_rx_handler, config);
+
+	if (rc) {
+		LOGM("netdev_rx_handler_register returns %d", rc);
+		kfree(config);
+		return -EBUSY;
+	}
+
+	dev_hold(dev);
+	return 0;
+}
+
+/* __rmnet_set_logical_endpoint_config() - Set logical endpoing config on device
+ * @dev:         Device to set endpoint configuration on
+ * @config_id:   logical endpoint id on device
+ * @epconfig:    endpoint configuration structure to set
+ */
+static int __rmnet_set_logical_endpoint_config
+	(struct net_device *dev,
+	 int config_id,
+	 struct rmnet_logical_ep_conf_s *epconfig)
+{
+	struct rmnet_logical_ep_conf_s *epconfig_l;
+
+	ASSERT_RTNL();
+
+	if (!dev || config_id < RMNET_LOCAL_LOGICAL_ENDPOINT ||
+	    config_id >= RMNET_MAX_LOGICAL_EP)
+		return -EINVAL;
+
+	epconfig_l = _rmnet_get_logical_ep(dev, config_id);
+
+	if (!epconfig_l || epconfig_l->refcount)
+		return -EINVAL;
+
+	memcpy(epconfig_l, epconfig, sizeof(struct rmnet_logical_ep_conf_s));
+	if (config_id == RMNET_LOCAL_LOGICAL_ENDPOINT)
+		epconfig_l->mux_id = 0;
+	else
+		epconfig_l->mux_id = config_id;
+
+	/* Explicitly hold a reference to the egress device */
+	dev_hold(epconfig_l->egress_dev);
+	return 0;
+}
+
+/* _rmnet_unset_logical_endpoint_config() - Un-set the logical endpoing config
+ * on device
+ * @dev:         Device to set endpoint configuration on
+ * @config_id:   logical endpoint id on device
+ */
+static int _rmnet_unset_logical_endpoint_config(struct net_device *dev,
+						int config_id)
+{
+	struct rmnet_logical_ep_conf_s *epconfig_l = 0;
+
+	ASSERT_RTNL();
+
+	if (!dev || config_id < RMNET_LOCAL_LOGICAL_ENDPOINT ||
+	    config_id >= RMNET_MAX_LOGICAL_EP)
+		return -EINVAL;
+
+	epconfig_l = _rmnet_get_logical_ep(dev, config_id);
+
+	if (!epconfig_l || !epconfig_l->refcount)
+		return -EINVAL;
+
+	/* Explicitly release the reference from the egress device */
+	dev_put(epconfig_l->egress_dev);
+	memset(epconfig_l, 0, sizeof(struct rmnet_logical_ep_conf_s));
+
+	return 0;
+}
+
+/* rmnet_set_logical_endpoint_config() - Set logical endpoint config on a device
+ * @dev:            Device to set endpoint configuration on
+ * @config_id:      logical endpoint id on device
+ * @rmnet_mode:     endpoint mode. Values from: rmnet_config_endpoint_modes_e
+ * @egress_device:  device node to forward packet to once done processing in
+ *                  ingress/egress handlers
+ *
+ * Creates a logical_endpoint_config structure and fills in the information from
+ * function arguments. Calls __rmnet_set_logical_endpoint_config() to finish
+ * configuration. Network device must already have association with RmNet Data
+ * driver
+ */
+static int rmnet_set_logical_endpoint_config(struct net_device *dev,
+					     int config_id,
+					     u8 rmnet_mode,
+					     struct net_device *egress_dev)
+{
+	struct rmnet_logical_ep_conf_s epconfig;
+
+	LOGL("(%s, %d, %d, %s);",
+	     dev->name, config_id, rmnet_mode, egress_dev->name);
+
+	if (!egress_dev ||
+	    ((!_rmnet_is_physical_endpoint_associated(egress_dev)) &&
+	    (!rmnet_vnd_is_vnd(egress_dev)))) {
+		return -EINVAL;
+	}
+
+	memset(&epconfig, 0, sizeof(struct rmnet_logical_ep_conf_s));
+	epconfig.refcount = 1;
+	epconfig.rmnet_mode = rmnet_mode;
+	epconfig.egress_dev = egress_dev;
+
+	return __rmnet_set_logical_endpoint_config(dev, config_id, &epconfig);
+}
+
+/* rmnet_unset_logical_endpoint_config() - Un-set logical endpoing configuration
+ * on a device
+ * @dev:            Device to set endpoint configuration on
+ * @config_id:      logical endpoint id on device
+ *
+ * Retrieves the logical_endpoint_config structure and frees the egress device.
+ * Network device must already have association with RmNet Data driver
+ */
+static int rmnet_unset_logical_endpoint_config(struct net_device *dev,
+					       int config_id)
+{
+	LOGL("(%s, %d);", dev->name, config_id);
+
+	if (!dev || ((!_rmnet_is_physical_endpoint_associated(dev)) &&
+		     (!rmnet_vnd_is_vnd(dev)))) {
+		return -EINVAL;
+	}
+
+	return _rmnet_unset_logical_endpoint_config(dev, config_id);
+}
+
+/* rmnet_free_vnd() - Free virtual network device node
+ * @id:       RmNet virtual device node id
+ */
+int rmnet_free_vnd(int id)
+{
+	LOGL("(%d);", id);
+	return rmnet_vnd_free_dev(id);
+}
+
+static void _rmnet_free_vnd_later(struct work_struct *work)
+{
+	int i;
+	struct rmnet_free_vnd_work *fwork;
+
+	fwork = container_of(work, struct rmnet_free_vnd_work, work);
+
+	for (i = 0; i < fwork->count; i++)
+		rmnet_free_vnd(fwork->vnd_id[i]);
+	kfree(fwork);
+}
+
+/* rmnet_force_unassociate_device() - Force a device to unassociate
+ * @dev:       Device to unassociate
+ */
+static void rmnet_force_unassociate_device(struct net_device *dev)
+{
+	int i, j;
+	struct net_device *vndev;
+	struct rmnet_phys_ep_conf_s *config;
+	struct rmnet_logical_ep_conf_s *cfg;
+	struct rmnet_free_vnd_work *vnd_work;
+
+	ASSERT_RTNL();
+	if (!dev)
+		return;
+
+	if (!_rmnet_is_physical_endpoint_associated(dev)) {
+		LOGM("%s", "Called on unassociated device, skipping");
+		return;
+	}
+
+	vnd_work = kmalloc(sizeof(*vnd_work), GFP_KERNEL);
+	if (!vnd_work)
+		return;
+
+	INIT_WORK(&vnd_work->work, _rmnet_free_vnd_later);
+	vnd_work->count = 0;
+
+	/* Check the VNDs for offending mappings */
+	for (i = 0, j = 0; i < RMNET_MAX_VND &&
+	     j < RMNET_MAX_VND; i++) {
+		vndev = rmnet_vnd_get_by_id(i);
+		if (!vndev) {
+			LOGL("VND %d not in use; skipping", i);
+			continue;
+		}
+		cfg = rmnet_vnd_get_le_config(vndev);
+		if (!cfg) {
+			LOGD("Got NULL config from VND %d", i);
+			continue;
+		}
+		if (cfg->refcount && (cfg->egress_dev == dev)) {
+			/* Make sure the device is down before clearing any of
+			 * the mappings. Otherwise we could see a potential
+			 * race condition if packets are actively being
+			 * transmitted.
+			 */
+			dev_close(vndev);
+			rmnet_unset_logical_endpoint_config
+				(vndev, RMNET_LOCAL_LOGICAL_ENDPOINT);
+			vnd_work->vnd_id[j] = i;
+			j++;
+		}
+	}
+	if (j > 0) {
+		vnd_work->count = j;
+		schedule_work(&vnd_work->work);
+	} else {
+		kfree(vnd_work);
+	}
+
+	config = _rmnet_get_phys_ep_config(dev);
+
+	if (config) {
+		cfg = &config->local_ep;
+
+		if (cfg && cfg->refcount)
+			rmnet_unset_logical_endpoint_config
+			(cfg->egress_dev, RMNET_LOCAL_LOGICAL_ENDPOINT);
+	}
+
+	/* Clear the mappings on the phys ep */
+	rmnet_unset_logical_endpoint_config(dev, RMNET_LOCAL_LOGICAL_ENDPOINT);
+	for (i = 0; i < RMNET_MAX_LOGICAL_EP; i++)
+		rmnet_unset_logical_endpoint_config(dev, i);
+	rmnet_unassociate_network_device(dev);
+}
+
+/* rmnet_config_notify_cb() - Callback for netdevice notifier chain
+ * @nb:       Notifier block data
+ * @event:    Netdevice notifier event ID
+ * @data:     Contains a net device for which we are getting notified
+ */
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
+		LOGM("Kernel is trying to unregister %s", dev->name);
+		rmnet_force_unassociate_device(dev);
+		break;
+
+	default:
+		LOGD("Unhandeled event [%lu]", event);
+		break;
+	}
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block rmnet_dev_notifier = {
+	.notifier_call = rmnet_config_notify_cb,
+	.next = 0,
+	.priority = 0
+};
+
+static int rmnet_newlink(struct net *src_net, struct net_device *dev,
+			 struct nlattr *tb[], struct nlattr *data[])
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
+	if (!real_dev)
+		return -ENODEV;
+
+	if (!data[IFLA_RMNET_MUX_ID])
+		return -EINVAL;
+
+	mux_id = nla_get_u16(data[IFLA_VLAN_ID]);
+	if (rmnet_vnd_newlink(mux_id, dev))
+		return -EINVAL;
+
+	rmnet_associate_network_device(real_dev);
+	rmnet_set_egress_data_format(real_dev, egress_format, 0, 0);
+	rmnet_set_ingress_data_format(real_dev, ingress_format);
+	rmnet_set_logical_endpoint_config(real_dev, mux_id, mode, dev);
+	rmnet_set_logical_endpoint_config(dev, mux_id, mode, real_dev);
+	return 0;
+}
+
+static void rmnet_delink(struct net_device *dev, struct list_head *head)
+{
+	struct rmnet_logical_ep_conf_s *cfg;
+	int mux_id;
+
+	mux_id = rmnet_vnd_is_vnd(dev);
+	if (!mux_id)
+		return;
+
+/* rmnet_vnd_is_vnd() gives mux_id + 1, so subtract 1 to get the correct mux_id
+ */
+	mux_id--;
+	cfg = rmnet_vnd_get_le_config(dev);
+
+	if (cfg && cfg->refcount) {
+		_rmnet_unset_logical_endpoint_config(cfg->egress_dev, mux_id);
+		_rmnet_unset_logical_endpoint_config(dev, mux_id);
+		rmnet_vnd_remove_ref_dev(mux_id);
+		rmnet_unassociate_network_device(cfg->egress_dev);
+	}
+
+	unregister_netdevice_queue(dev, head);
+}
+
+static int rmnet_rtnl_validate(struct nlattr *tb[], struct nlattr *data[])
+{
+	u16 mux_id;
+
+	if (!data || !data[IFLA_RMNET_MUX_ID])
+		return -EINVAL;
+
+	mux_id = nla_get_u16(data[IFLA_RMNET_MUX_ID]);
+	if (!mux_id || mux_id > (RMNET_MAX_LOGICAL_EP - 1))
+		return -ERANGE;
+
+	return 0;
+}
+
+static size_t rmnet_get_size(const struct net_device *dev)
+{
+	return nla_total_size(2); /* IFLA_RMNET_MUX_ID */
+}
+
+struct rtnl_link_ops rmnet_link_ops __read_mostly = {
+	.kind		= "rmnet",
+	.maxtype	= __IFLA_RMNET_MAX,
+	.priv_size	= sizeof(struct rmnet_vnd_private_s),
+	.setup		= rmnet_vnd_setup,
+	.validate	= rmnet_rtnl_validate,
+	.newlink	= rmnet_newlink,
+	.dellink	= rmnet_delink,
+	.get_size	= rmnet_get_size,
+};
+
+int rmnet_config_init(void)
+{
+	int rc;
+
+	rc = register_netdevice_notifier(&rmnet_dev_notifier);
+	if (rc != 0) {
+		LOGE("Failed to register device notifier; rc=%d", rc);
+		return rc;
+	}
+
+	rc = rtnl_link_register(&rmnet_link_ops);
+	if (rc != 0) {
+		unregister_netdevice_notifier(&rmnet_dev_notifier);
+		LOGE("Failed to register netlink handler; rc=%d", rc);
+		return rc;
+	}
+	return rc;
+}
+
+void rmnet_config_exit(void)
+{
+	unregister_netdevice_notifier(&rmnet_dev_notifier);
+	rtnl_link_unregister(&rmnet_link_ops);
+}
diff --git a/drivers/net/rmnet/rmnet_config.h b/drivers/net/rmnet/rmnet_config.h
new file mode 100644
index 0000000..0ef58e8
--- /dev/null
+++ b/drivers/net/rmnet/rmnet_config.h
@@ -0,0 +1,79 @@
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
+#include <linux/types.h>
+#include <linux/time.h>
+#include <linux/skbuff.h>
+
+#ifndef _RMNET_CONFIG_H_
+#define _RMNET_CONFIG_H_
+
+#define RMNET_MAX_LOGICAL_EP 255
+
+/* struct rmnet_logical_ep_conf_s - Logical end-point configuration
+ *
+ * @refcount: Reference count for this endpoint. 0 signifies the endpoint is not
+ *            configured for use
+ * @rmnet_mode: Specifies how the traffic should be finally delivered. Possible
+ *            options are available in enum rmnet_config_endpoint_modes_e
+ * @mux_id: Virtual channel ID used by MAP protocol
+ * @egress_dev: Next device to deliver the packet to. Exact usage of this
+ *            parmeter depends on the rmnet_mode
+ */
+struct rmnet_logical_ep_conf_s {
+	u8 refcount;
+	u8 rmnet_mode;
+	u8 mux_id;
+	struct timespec flush_time;
+	struct net_device *egress_dev;
+};
+
+/* struct rmnet_phys_ep_conf_s - Physical endpoint configuration
+ * One instance of this structure is instantiated for each net_device associated
+ * with rmnet.
+ *
+ * @dev: The device which is associated with rmnet. Corresponds to this
+ *       specific instance of rmnet_phys_ep_conf_s
+ * @local_ep: Default non-muxed endpoint. Used for non-MAP protocols/formats
+ * @muxed_ep: All multiplexed logical endpoints associated with this device
+ * @ingress_data_format: RMNET_INGRESS_FORMAT_* flags from rmnet.h
+ * @egress_data_format: RMNET_EGRESS_FORMAT_* flags from rmnet.h
+ *
+ * @egress_agg_size: Maximum size (bytes) of data which should be aggregated
+ * @egress_agg_count: Maximum count (packets) of data which should be aggregated
+ *                  Smaller of the two parameters above are chosen for
+ *                  aggregation
+ * @tail_spacing: Guaranteed padding (bytes) when de-aggregating ingress frames
+ * @agg_time: Wall clock time when aggregated frame was created
+ * @agg_last: Last time the aggregation routing was invoked
+ */
+struct rmnet_phys_ep_conf_s {
+	struct net_device *dev;
+	struct rmnet_logical_ep_conf_s local_ep;
+	struct rmnet_logical_ep_conf_s muxed_ep[RMNET_MAX_LOGICAL_EP];
+	u32 ingress_data_format;
+	u32 egress_data_format;
+};
+
+int rmnet_config_init(void);
+void rmnet_config_exit(void);
+int rmnet_free_vnd(int id);
+
+extern struct rtnl_link_ops rmnet_link_ops;
+
+struct rmnet_vnd_private_s {
+	struct rmnet_logical_ep_conf_s local_ep;
+};
+#endif /* _RMNET_CONFIG_H_ */
diff --git a/drivers/net/rmnet/rmnet_handlers.c b/drivers/net/rmnet/rmnet_handlers.c
new file mode 100644
index 0000000..bf8b3bb
--- /dev/null
+++ b/drivers/net/rmnet/rmnet_handlers.c
@@ -0,0 +1,517 @@
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
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <linux/module.h>
+#include <linux/rmnet.h>
+#include <linux/netdev_features.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include "rmnet_private.h"
+#include "rmnet_config.h"
+#include "rmnet_vnd.h"
+#include "rmnet_map.h"
+#include "rmnet_stats.h"
+#include "rmnet_handlers.h"
+
+RMNET_LOG_MODULE(RMNET_LOGMASK_HANDLER);
+
+#ifdef CONFIG_RMNET_DEBUG
+unsigned int dump_pkt_rx;
+module_param(dump_pkt_rx, uint, 0644);
+MODULE_PARM_DESC(dump_pkt_rx, "Dump packets entering ingress handler");
+
+unsigned int dump_pkt_tx;
+module_param(dump_pkt_tx, uint, 0644);
+MODULE_PARM_DESC(dump_pkt_tx, "Dump packets exiting egress handler");
+#endif /* CONFIG_RMNET_DEBUG */
+
+#define RMNET_IP_VERSION_4 0x40
+#define RMNET_IP_VERSION_6 0x60
+
+/* Helper Functions */
+
+/* __rmnet_set_skb_proto() - Set skb->protocol field
+ * @skb:      packet being modified
+ *
+ * Peek at the first byte of the packet and set the protocol. There is not
+ * good way to determine if a packet has a MAP header. As of writing this,
+ * the reserved bit in the MAP frame will prevent it from overlapping with
+ * IPv4/IPv6 frames. This could change in the future!
+ */
+static inline void __rmnet_set_skb_proto(struct sk_buff *skb)
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
+#ifdef CONFIG_RMNET_DEBUG
+/* rmnet_print_packet() - Print packet / diagnostics
+ * @skb:      Packet to print
+ * @printlen: Number of bytes to print
+ * @dev:      Name of interface
+ * @dir:      Character representing direction (e.g.. 'r' for receive)
+ *
+ * This function prints out raw bytes in an SKB. Use of this will have major
+ * performance impacts and may even trigger watchdog resets if too much is being
+ * printed. Hence, this should always be compiled out unless absolutely needed.
+ */
+void rmnet_print_packet(const struct sk_buff *skb, const char *dev, char dir)
+{
+	char buffer[200];
+	unsigned int len, printlen;
+	int i, buffloc = 0;
+
+	switch (dir) {
+	case 'r':
+		printlen = dump_pkt_rx;
+		break;
+
+	case 't':
+		printlen = dump_pkt_tx;
+		break;
+
+	default:
+		printlen = 0;
+		break;
+	}
+
+	if (!printlen)
+		return;
+
+	pr_err("[%s][%c] - PKT skb->len=%d skb->head=%pK skb->data=%pK\n",
+	       dev, dir, skb->len, (void *)skb->head, (void *)skb->data);
+	pr_err("[%s][%c] - PKT skb->tail=%pK skb->end=%pK\n",
+	       dev, dir, skb_tail_pointer(skb), skb_end_pointer(skb));
+
+	if (skb->len > 0)
+		len = skb->len;
+	else
+		len = ((unsigned int)(uintptr_t)skb->end) -
+		      ((unsigned int)(uintptr_t)skb->data);
+
+	pr_err("[%s][%c] - PKT len: %d, printing first %d bytes\n",
+	       dev, dir, len, printlen);
+
+	memset(buffer, 0, sizeof(buffer));
+	for (i = 0; (i < printlen) && (i < len); i++) {
+		if ((i % 16) == 0) {
+			pr_err("[%s][%c] - PKT%s\n", dev, dir, buffer);
+			memset(buffer, 0, sizeof(buffer));
+			buffloc = 0;
+			buffloc += snprintf(&buffer[buffloc],
+					sizeof(buffer) - buffloc, "%04X:",
+					i);
+		}
+
+		buffloc += snprintf(&buffer[buffloc], sizeof(buffer) - buffloc,
+					" %02x", skb->data[i]);
+	}
+	pr_err("[%s][%c] - PKT%s\n", dev, dir, buffer);
+}
+#else
+void rmnet_print_packet(const struct sk_buff *skb, const char *dev, char dir)
+{
+}
+#endif /* CONFIG_RMNET_DEBUG */
+
+/* Generic handler */
+
+/* rmnet_bridge_handler() - Bridge related functionality
+ */
+static rx_handler_result_t rmnet_bridge_handler
+	(struct sk_buff *skb, struct rmnet_logical_ep_conf_s *ep)
+{
+	if (!ep->egress_dev) {
+		LOGD("Missing egress device for packet arriving on %s",
+		     skb->dev->name);
+		rmnet_kfree_skb(skb, RMNET_STATS_SKBFREE_BRDG_NO_EGRESS);
+	} else {
+		rmnet_egress_handler(skb, ep);
+	}
+
+	return RX_HANDLER_CONSUMED;
+}
+
+#ifdef NET_SKBUFF_DATA_USES_OFFSET
+static void rmnet_reset_mac_header(struct sk_buff *skb)
+{
+	skb->mac_header = 0;
+	skb->mac_len = 0;
+}
+#else
+static void rmnet_reset_mac_header(struct sk_buff *skb)
+{
+	skb->mac_header = skb->network_header;
+	skb->mac_len = 0;
+}
+#endif /*NET_SKBUFF_DATA_USES_OFFSET*/
+
+/* __rmnet_deliver_skb() - Deliver skb
+ *
+ * Determines where to deliver skb. Options are: consume by network stack,
+ * pass to bridge handler, or pass to virtual network device
+ */
+static rx_handler_result_t __rmnet_deliver_skb
+	(struct sk_buff *skb, struct rmnet_logical_ep_conf_s *ep)
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
+			rmnet_reset_mac_header(skb);
+			netif_receive_skb(skb);
+			return RX_HANDLER_CONSUMED;
+		}
+		return RX_HANDLER_PASS;
+
+	default:
+		LOGD("Unknown ep mode %d", ep->rmnet_mode);
+		rmnet_kfree_skb(skb, RMNET_STATS_SKBFREE_DELIVER_NO_EP);
+		return RX_HANDLER_CONSUMED;
+	}
+}
+
+/* rmnet_ingress_deliver_packet() - Ingress handler for raw IP and bridged
+ *                                  MAP packets.
+ * @skb:     Packet needing a destination.
+ * @config:  Physical end point configuration that the packet arrived on.
+ */
+static rx_handler_result_t rmnet_ingress_deliver_packet
+	(struct sk_buff *skb, struct rmnet_phys_ep_conf_s *config)
+{
+	if (!config) {
+		LOGD("%s", "NULL physical EP provided");
+		kfree_skb(skb);
+		return RX_HANDLER_CONSUMED;
+	}
+
+	if (!(config->local_ep.refcount)) {
+		LOGD("Packet on %s has no local endpoint configuration",
+		     skb->dev->name);
+		rmnet_kfree_skb(skb, RMNET_STATS_SKBFREE_IPINGRESS_NO_EP);
+		return RX_HANDLER_CONSUMED;
+	}
+
+	skb->dev = config->local_ep.egress_dev;
+
+	return __rmnet_deliver_skb(skb, &config->local_ep);
+}
+
+/* MAP handler */
+
+/* _rmnet_map_ingress_handler() - Actual MAP ingress handler
+ * @skb:        Packet being received
+ * @config:     Physical endpoint configuration for the ingress device
+ *
+ * Most MAP ingress functions are processed here. Packets are processed
+ * individually; aggregated packets should use rmnet_map_ingress_handler()
+ */
+static rx_handler_result_t _rmnet_map_ingress_handler
+	(struct sk_buff *skb, struct rmnet_phys_ep_conf_s *config)
+{
+	struct rmnet_logical_ep_conf_s *ep;
+	u8 mux_id;
+	u16 len;
+
+	if (RMNET_MAP_GET_CD_BIT(skb)) {
+		if (config->ingress_data_format
+		    & RMNET_INGRESS_FORMAT_MAP_COMMANDS)
+			return rmnet_map_command(skb, config);
+
+		LOGM("MAP command packet on %s; %s", skb->dev->name,
+		     "Not configured for MAP commands");
+		rmnet_kfree_skb(skb,
+				RMNET_STATS_SKBFREE_INGRESS_NOT_EXPECT_MAPC);
+		return RX_HANDLER_CONSUMED;
+	}
+
+	mux_id = RMNET_MAP_GET_MUX_ID(skb);
+	len = RMNET_MAP_GET_LENGTH(skb) - RMNET_MAP_GET_PAD(skb);
+
+	if (mux_id >= RMNET_MAX_LOGICAL_EP) {
+		LOGD("Got packet on %s with bad mux id %d",
+		     skb->dev->name, mux_id);
+		rmnet_kfree_skb(skb, RMNET_STATS_SKBFREE_MAPINGRESS_BAD_MUX);
+			return RX_HANDLER_CONSUMED;
+	}
+
+	ep = &config->muxed_ep[mux_id];
+
+	if (!ep->refcount) {
+		LOGD("Packet on %s:%d; has no logical endpoint config",
+		     skb->dev->name, mux_id);
+
+		rmnet_kfree_skb(skb, RMNET_STATS_SKBFREE_MAPINGRESS_MUX_NO_EP);
+		return RX_HANDLER_CONSUMED;
+	}
+
+	if (config->ingress_data_format & RMNET_INGRESS_FORMAT_DEMUXING)
+		skb->dev = ep->egress_dev;
+
+	/* Subtract MAP header */
+	skb_pull(skb, sizeof(struct rmnet_map_header_s));
+	skb_trim(skb, len);
+	__rmnet_set_skb_proto(skb);
+	return __rmnet_deliver_skb(skb, ep);
+}
+
+/* rmnet_map_ingress_handler() - MAP ingress handler
+ * @skb:        Packet being received
+ * @config:     Physical endpoint configuration for the ingress device
+ *
+ * Called if and only if MAP is configured in the ingress device's ingress data
+ * format. Deaggregation is done here, actual MAP processing is done in
+ * _rmnet_map_ingress_handler().
+ */
+static rx_handler_result_t rmnet_map_ingress_handler
+	(struct sk_buff *skb, struct rmnet_phys_ep_conf_s *config)
+{
+	struct sk_buff *skbn;
+	int rc, co = 0;
+
+	if (config->ingress_data_format & RMNET_INGRESS_FORMAT_DEAGGREGATION) {
+		while ((skbn = rmnet_map_deaggregate(skb, config)) != NULL) {
+			_rmnet_map_ingress_handler(skbn, config);
+			co++;
+		}
+		LOGD("De-aggregated %d packets", co);
+		rmnet_stats_deagg_pkts(co);
+		rmnet_kfree_skb(skb, RMNET_STATS_SKBFREE_MAPINGRESS_AGGBUF);
+		rc = RX_HANDLER_CONSUMED;
+	} else {
+		rc = _rmnet_map_ingress_handler(skb, config);
+	}
+
+	return rc;
+}
+
+/* rmnet_map_egress_handler() - MAP egress handler
+ * @skb:        Packet being sent
+ * @config:     Physical endpoint configuration for the egress device
+ * @ep:         logical endpoint configuration of the packet originator
+ *              (e.g.. RmNet virtual network device)
+ * @orig_dev:   The originator vnd device
+ *
+ * Called if and only if MAP is configured in the egress device's egress data
+ * format. Will expand skb if there is insufficient headroom for MAP protocol.
+ * Note: headroomexpansion will incur a performance penalty.
+ */
+static int rmnet_map_egress_handler(struct sk_buff *skb,
+				    struct rmnet_phys_ep_conf_s *config,
+				    struct rmnet_logical_ep_conf_s *ep,
+				    struct net_device *orig_dev)
+{
+	int required_headroom, additional_header_length;
+	struct rmnet_map_header_s *map_header;
+
+	additional_header_length = 0;
+	required_headroom = sizeof(struct rmnet_map_header_s);
+
+	LOGD("headroom of %d bytes", required_headroom);
+
+	if (skb_headroom(skb) < required_headroom) {
+		if (pskb_expand_head(skb, required_headroom, 0, GFP_KERNEL)) {
+			LOGD("Failed to add headroom of %d bytes",
+			     required_headroom);
+			return RMNET_MAP_CONSUMED;
+		}
+	}
+
+	map_header = rmnet_map_add_map_header
+		(skb, additional_header_length, RMNET_MAP_NO_PAD_BYTES);
+	if (!map_header) {
+		LOGD("%s", "Failed to add MAP header to egress packet");
+		return RMNET_MAP_CONSUMED;
+	}
+
+	if (config->egress_data_format & RMNET_EGRESS_FORMAT_MUXING) {
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
+/* rmnet_ingress_handler() - Ingress handler entry point
+ * @skb: Packet being received
+ *
+ * Processes packet as per ingress data format for receiving device. Logical
+ * endpoint is determined from packet inspection. Packet is then sent to the
+ * egress device listed in the logical endpoint configuration.
+ */
+rx_handler_result_t rmnet_ingress_handler(struct sk_buff *skb)
+{
+	struct rmnet_phys_ep_conf_s *config;
+	struct net_device *dev;
+	int rc;
+
+	if (!skb)
+		return RX_HANDLER_CONSUMED;
+
+	dev = skb->dev;
+	rmnet_print_packet(skb, dev->name, 'r');
+
+	config = (struct rmnet_phys_ep_conf_s *)
+		rcu_dereference(skb->dev->rx_handler_data);
+
+	if (!config) {
+		LOGD("%s is not associated with rmnet", skb->dev->name);
+		kfree_skb(skb);
+		return RX_HANDLER_CONSUMED;
+	}
+
+	/* Sometimes devices operate in ethernet mode even thouth there is no
+	 * ethernet header. This causes the skb->protocol to contain a bogus
+	 * value and the skb->data pointer to be off by 14 bytes. Fix it if
+	 * configured to do so
+	 */
+	if (config->ingress_data_format & RMNET_INGRESS_FIX_ETHERNET) {
+		skb_push(skb, RMNET_ETHERNET_HEADER_LENGTH);
+		__rmnet_set_skb_proto(skb);
+	}
+
+	if (config->ingress_data_format & RMNET_INGRESS_FORMAT_MAP) {
+		rc = rmnet_map_ingress_handler(skb, config);
+	} else {
+		switch (ntohs(skb->protocol)) {
+		case ETH_P_MAP:
+			if (config->local_ep.rmnet_mode ==
+				RMNET_EPMODE_BRIDGE) {
+				rc = rmnet_ingress_deliver_packet(skb, config);
+			} else {
+				LOGD("MAP packet on %s; MAP not set",
+				     dev->name);
+				rmnet_kfree_skb
+				(skb,
+				 RMNET_STATS_SKBFREE_INGRESS_NOT_EXPECT_MAPD);
+				rc = RX_HANDLER_CONSUMED;
+			}
+			break;
+
+		case ETH_P_ARP:
+		case ETH_P_IP:
+		case ETH_P_IPV6:
+			rc = rmnet_ingress_deliver_packet(skb, config);
+			break;
+
+		default:
+			LOGD("Unknown skb->proto 0x%04X\n",
+			     ntohs(skb->protocol) & 0xFFFF);
+			rc = RX_HANDLER_PASS;
+		}
+	}
+
+	return rc;
+}
+
+/* rmnet_rx_handler() - Rx handler callback registered with kernel
+ * @pskb: Packet to be processed by rx handler
+ *
+ * Standard kernel-expected footprint for rx handlers. Calls
+ * rmnet_ingress_handler with correctly formatted arguments
+ */
+rx_handler_result_t rmnet_rx_handler(struct sk_buff **pskb)
+{
+	return rmnet_ingress_handler(*pskb);
+}
+
+/* rmnet_egress_handler() - Egress handler entry point
+ * @skb:        packet to transmit
+ * @ep:         logical endpoint configuration of the packet originator
+ *              (e.g.. RmNet virtual network device)
+ *
+ * Modifies packet as per logical endpoint configuration and egress data format
+ * for egress device configured in logical endpoint. Packet is then transmitted
+ * on the egress device.
+ */
+void rmnet_egress_handler(struct sk_buff *skb,
+			  struct rmnet_logical_ep_conf_s *ep)
+{
+	struct rmnet_phys_ep_conf_s *config;
+	struct net_device *orig_dev;
+	int rc;
+
+	orig_dev = skb->dev;
+	skb->dev = ep->egress_dev;
+
+	config = (struct rmnet_phys_ep_conf_s *)
+		rcu_dereference(skb->dev->rx_handler_data);
+
+	if (!config) {
+		LOGD("%s is not associated with rmnet", skb->dev->name);
+		kfree_skb(skb);
+		return;
+	}
+
+	LOGD("Packet going out on %s with egress format 0x%08X",
+	     skb->dev->name, config->egress_data_format);
+
+	if (config->egress_data_format & RMNET_EGRESS_FORMAT_MAP) {
+		switch (rmnet_map_egress_handler(skb, config, ep, orig_dev)) {
+		case RMNET_MAP_CONSUMED:
+			LOGD("%s", "MAP process consumed packet");
+			return;
+
+		case RMNET_MAP_SUCCESS:
+			break;
+
+		default:
+			LOGD("MAP egress failed on packet on %s",
+			     skb->dev->name);
+			rmnet_kfree_skb(skb, RMNET_STATS_SKBFREE_EGR_MAPFAIL);
+			return;
+		}
+	}
+
+	if (ep->rmnet_mode == RMNET_EPMODE_VND)
+		rmnet_vnd_tx_fixup(skb, orig_dev);
+
+	rmnet_print_packet(skb, skb->dev->name, 't');
+	rc = dev_queue_xmit(skb);
+	if (rc != 0) {
+		LOGD("Failed to queue packet for transmission on [%s]",
+		     skb->dev->name);
+	}
+	rmnet_stats_queue_xmit(rc, RMNET_STATS_QUEUE_XMIT_EGRESS);
+}
diff --git a/drivers/net/rmnet/rmnet_handlers.h b/drivers/net/rmnet/rmnet_handlers.h
new file mode 100644
index 0000000..43c42c2
--- /dev/null
+++ b/drivers/net/rmnet/rmnet_handlers.h
@@ -0,0 +1,24 @@
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
+void rmnet_egress_handler(struct sk_buff *skb,
+			  struct rmnet_logical_ep_conf_s *ep);
+
+rx_handler_result_t rmnet_rx_handler(struct sk_buff **pskb);
+
+#endif /* _RMNET_HANDLERS_H_ */
diff --git a/drivers/net/rmnet/rmnet_main.c b/drivers/net/rmnet/rmnet_main.c
new file mode 100644
index 0000000..f8b7a20
--- /dev/null
+++ b/drivers/net/rmnet/rmnet_main.c
@@ -0,0 +1,52 @@
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
+ *
+ * RMNET Data generic framework
+ *
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/export.h>
+#include "rmnet_private.h"
+#include "rmnet_config.h"
+#include "rmnet_vnd.h"
+
+/* Module Parameters */
+unsigned int rmnet_log_level = RMNET_LOG_LVL_ERR | RMNET_LOG_LVL_HI;
+module_param(rmnet_log_level, uint, 0644);
+MODULE_PARM_DESC(log_level, "Logging level");
+
+unsigned int rmnet_log_module_mask;
+module_param(rmnet_log_module_mask, uint, 0644);
+MODULE_PARM_DESC(rmnet_log_module_mask, "Logging module mask");
+
+/* Startup/Shutdown */
+
+static int __init rmnet_init(void)
+{
+	rmnet_config_init();
+	rmnet_vnd_init();
+
+	LOGL("%s", "RMNET Data driver loaded successfully");
+	return 0;
+}
+
+static void __exit rmnet_exit(void)
+{
+	rmnet_config_exit();
+	rmnet_vnd_exit();
+}
+
+module_init(rmnet_init)
+module_exit(rmnet_exit)
+MODULE_LICENSE("GPL v2");
diff --git a/drivers/net/rmnet/rmnet_map.h b/drivers/net/rmnet/rmnet_map.h
new file mode 100644
index 0000000..7d533aa
--- /dev/null
+++ b/drivers/net/rmnet/rmnet_map.h
@@ -0,0 +1,100 @@
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
+#include <linux/types.h>
+#include <linux/spinlock.h>
+
+#ifndef _RMNET_MAP_H_
+#define _RMNET_MAP_H_
+
+struct rmnet_map_control_command_s {
+	u8  command_name;
+	u8  cmd_type:2;
+	u8  reserved:6;
+	u16 reserved2;
+	u32 transaction_id;
+	union {
+		u8  data[65528];
+		struct {
+			u16 ip_family:2;
+			u16 reserved:14;
+			u16 flow_control_seq_num;
+			u32 qos_id;
+		} flow_control;
+	};
+}  __aligned(1);
+
+enum rmnet_map_results_e {
+	RMNET_MAP_SUCCESS,
+	RMNET_MAP_CONSUMED,
+	RMNET_MAP_GENERAL_FAILURE,
+	RMNET_MAP_NOT_ENABLED,
+	RMNET_MAP_FAILED_AGGREGATION,
+	RMNET_MAP_FAILED_MUX
+};
+
+enum rmnet_map_mux_errors_e {
+	RMNET_MAP_MUX_SUCCESS,
+	RMNET_MAP_MUX_INVALID_MUX_ID,
+	RMNET_MAP_MUX_INVALID_PAD_LENGTH,
+	RMNET_MAP_MUX_INVALID_PKT_LENGTH,
+	/* This should always be the last element */
+	RMNET_MAP_MUX_ENUM_LENGTH
+};
+
+enum rmnet_map_commands_e {
+	RMNET_MAP_COMMAND_NONE,
+	RMNET_MAP_COMMAND_FLOW_DISABLE,
+	RMNET_MAP_COMMAND_FLOW_ENABLE,
+	/* These should always be the last 2 elements */
+	RMNET_MAP_COMMAND_UNKNOWN,
+	RMNET_MAP_COMMAND_ENUM_LENGTH
+};
+
+struct rmnet_map_header_s {
+	u8  pad_len:6;
+	u8  reserved_bit:1;
+	u8  cd_bit:1;
+	u8  mux_id;
+	u16 pkt_len;
+}  __aligned(1);
+
+#define RMNET_MAP_GET_MUX_ID(Y) (((struct rmnet_map_header_s *) \
+				 (Y)->data)->mux_id)
+#define RMNET_MAP_GET_CD_BIT(Y) (((struct rmnet_map_header_s *) \
+				(Y)->data)->cd_bit)
+#define RMNET_MAP_GET_PAD(Y) (((struct rmnet_map_header_s *) \
+				(Y)->data)->pad_len)
+#define RMNET_MAP_GET_CMD_START(Y) ((struct rmnet_map_control_command_s *) \
+				    ((Y)->data + \
+				      sizeof(struct rmnet_map_header_s)))
+#define RMNET_MAP_GET_LENGTH(Y) (ntohs(((struct rmnet_map_header_s *) \
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
+				      struct rmnet_phys_ep_conf_s *config);
+
+struct rmnet_map_header_s *rmnet_map_add_map_header(struct sk_buff *skb,
+						    int hdrlen, int pad);
+rx_handler_result_t rmnet_map_command(struct sk_buff *skb,
+				      struct rmnet_phys_ep_conf_s *config);
+
+#endif /* _RMNET_MAP_H_ */
diff --git a/drivers/net/rmnet/rmnet_map_command.c b/drivers/net/rmnet/rmnet_map_command.c
new file mode 100644
index 0000000..13bcee3
--- /dev/null
+++ b/drivers/net/rmnet/rmnet_map_command.c
@@ -0,0 +1,180 @@
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
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <linux/rmnet.h>
+#include <net/pkt_sched.h>
+#include "rmnet_config.h"
+#include "rmnet_map.h"
+#include "rmnet_private.h"
+#include "rmnet_vnd.h"
+#include "rmnet_stats.h"
+
+RMNET_LOG_MODULE(RMNET_LOGMASK_MAPC);
+
+unsigned long int rmnet_map_command_stats[RMNET_MAP_COMMAND_ENUM_LENGTH];
+module_param_array(rmnet_map_command_stats, ulong, 0, 0444);
+MODULE_PARM_DESC(rmnet_map_command_stats, "MAP command statistics");
+
+/* rmnet_map_do_flow_control() - Process MAP flow control command
+ * @skb: Socket buffer containing the MAP flow control message
+ * @config: Physical end-point configuration of ingress device
+ * @enable: boolean for enable/disable
+ *
+ * Process in-band MAP flow control messages. Assumes mux ID is mapped to a
+ * RmNet Data vitrual network device.
+ *
+ * Return:
+ *      - RMNET_MAP_COMMAND_UNSUPPORTED on any error
+ *      - RMNET_MAP_COMMAND_ACK on success
+ */
+static u8 rmnet_map_do_flow_control(struct sk_buff *skb,
+				    struct rmnet_phys_ep_conf_s *config,
+				    int enable)
+{
+	struct rmnet_map_control_command_s *cmd;
+	struct net_device *vnd;
+	struct rmnet_logical_ep_conf_s *ep;
+	u8 mux_id;
+	u16 ip_family;
+	u16 fc_seq;
+	u32 qos_id;
+	int r;
+
+	if (unlikely(!skb || !config))
+		return RX_HANDLER_CONSUMED;
+
+	mux_id = RMNET_MAP_GET_MUX_ID(skb);
+	cmd = RMNET_MAP_GET_CMD_START(skb);
+
+	if (mux_id >= RMNET_MAX_LOGICAL_EP) {
+		LOGD("Got packet on %s with bad mux id %d",
+		     skb->dev->name, mux_id);
+		rmnet_kfree_skb(skb, RMNET_STATS_SKBFREE_MAPC_BAD_MUX);
+		return RX_HANDLER_CONSUMED;
+	}
+
+	ep = &config->muxed_ep[mux_id];
+
+	if (!ep->refcount) {
+		LOGD("Packet on %s:%d; has no logical endpoint config",
+		     skb->dev->name, mux_id);
+
+		rmnet_kfree_skb(skb, RMNET_STATS_SKBFREE_MAPC_MUX_NO_EP);
+			return RX_HANDLER_CONSUMED;
+	}
+
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
+	r = rmnet_vnd_do_flow_control(vnd, enable);
+	LOGD("dev:%s, qos_id:0x%08X, ip_family:%hd, fc_seq %hd, en:%d",
+	     skb->dev->name, qos_id, ip_family & 3, fc_seq, enable);
+
+	if (r) {
+		rmnet_kfree_skb(skb, RMNET_STATS_SKBFREE_MAPC_UNSUPPORTED);
+		return RMNET_MAP_COMMAND_UNSUPPORTED;
+	} else {
+		return RMNET_MAP_COMMAND_ACK;
+	}
+}
+
+/* rmnet_map_send_ack() - Send N/ACK message for MAP commands
+ * @skb: Socket buffer containing the MAP command message
+ * @type: N/ACK message selector
+ * @config: Physical end-point configuration of ingress device
+ *
+ * skb is modified to contain the message type selector. The message is then
+ * transmitted on skb->dev. Note that this function grabs global Tx lock on
+ * skb->dev for latency reasons.
+ *
+ * Return:
+ *      - void
+ */
+static void rmnet_map_send_ack(struct sk_buff *skb,
+			       unsigned char type,
+			       struct rmnet_phys_ep_conf_s *config)
+{
+	struct rmnet_map_control_command_s *cmd;
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
+
+	LOGD("MAP command ACK=%hhu sent with rc: %d", type & 0x03, xmit_status);
+}
+
+/* rmnet_map_command() - Entry point for handling MAP commands
+ * @skb: Socket buffer containing the MAP command message
+ * @config: Physical end-point configuration of ingress device
+ *
+ * Process MAP command frame and send N/ACK message as appropriate. Message cmd
+ * name is decoded here and appropriate handler is called.
+ *
+ * Return:
+ *      - RX_HANDLER_CONSUMED. Command frames are always consumed.
+ */
+rx_handler_result_t rmnet_map_command(struct sk_buff *skb,
+				      struct rmnet_phys_ep_conf_s *config)
+{
+	struct rmnet_map_control_command_s *cmd;
+	unsigned char command_name;
+	unsigned char rc = 0;
+
+	if (unlikely(!skb))
+		return RX_HANDLER_CONSUMED;
+
+	cmd = RMNET_MAP_GET_CMD_START(skb);
+	command_name = cmd->command_name;
+
+	if (command_name < RMNET_MAP_COMMAND_ENUM_LENGTH)
+		rmnet_map_command_stats[command_name]++;
+
+	switch (command_name) {
+	case RMNET_MAP_COMMAND_FLOW_ENABLE:
+		rc = rmnet_map_do_flow_control(skb, config, 1);
+		break;
+
+	case RMNET_MAP_COMMAND_FLOW_DISABLE:
+		rc = rmnet_map_do_flow_control(skb, config, 0);
+		break;
+
+	default:
+		rmnet_map_command_stats[RMNET_MAP_COMMAND_UNKNOWN]++;
+		LOGM("Uknown MAP command: %d", command_name);
+		rc = RMNET_MAP_COMMAND_UNSUPPORTED;
+		rmnet_kfree_skb(skb, RMNET_STATS_SKBFREE_MAPC_UNSUPPORTED);
+		break;
+	}
+	if (rc == RMNET_MAP_COMMAND_ACK)
+		rmnet_map_send_ack(skb, rc, config);
+	return RX_HANDLER_CONSUMED;
+}
diff --git a/drivers/net/rmnet/rmnet_map_data.c b/drivers/net/rmnet/rmnet_map_data.c
new file mode 100644
index 0000000..93af3c9
--- /dev/null
+++ b/drivers/net/rmnet/rmnet_map_data.c
@@ -0,0 +1,145 @@
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
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <linux/rmnet.h>
+#include <linux/spinlock.h>
+#include <linux/workqueue.h>
+#include <linux/time.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <linux/udp.h>
+#include <linux/tcp.h>
+#include <linux/in.h>
+#include <net/ip.h>
+#include <net/checksum.h>
+#include <net/ip6_checksum.h>
+#include "rmnet_config.h"
+#include "rmnet_map.h"
+#include "rmnet_private.h"
+#include "rmnet_stats.h"
+
+RMNET_LOG_MODULE(RMNET_LOGMASK_MAPD);
+
+#define RMNET_MAP_DEAGGR_SPACING  64
+#define RMNET_MAP_DEAGGR_HEADROOM (RMNET_MAP_DEAGGR_SPACING / 2)
+
+/* rmnet_map_add_map_header() - Adds MAP header to front of skb->data
+ * @skb:        Socket buffer ("packet") to modify
+ * @hdrlen:     Number of bytes of header data which should not be included in
+ *              MAP length field
+ * @pad:        Specify if padding the MAP packet to make it 4 byte aligned is
+ *              necessary
+ *
+ * Padding is calculated and set appropriately in MAP header. Mux ID is
+ * initialized to 0.
+ *
+ * Return:
+ *      - Pointer to MAP structure
+ *      - 0 (null) if insufficient headroom
+ *      - 0 (null) if insufficient tailroom for padding bytes
+ */
+struct rmnet_map_header_s *rmnet_map_add_map_header(struct sk_buff *skb,
+						    int hdrlen, int pad)
+{
+	u32 padding, map_datalen;
+	u8 *padbytes;
+	struct rmnet_map_header_s *map_header;
+
+	if (skb_headroom(skb) < sizeof(struct rmnet_map_header_s))
+		return 0;
+
+	map_datalen = skb->len - hdrlen;
+	map_header = (struct rmnet_map_header_s *)
+			skb_push(skb, sizeof(struct rmnet_map_header_s));
+	memset(map_header, 0, sizeof(struct rmnet_map_header_s));
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
+	LOGD("pad: %d", padding);
+	memset(padbytes, 0, padding);
+
+done:
+	map_header->pkt_len = htons(map_datalen + padding);
+	map_header->pad_len = padding & 0x3F;
+
+	return map_header;
+}
+
+/* rmnet_map_deaggregate() - Deaggregates a single packet
+ * @skb:        Source socket buffer containing multiple MAP frames
+ * @config:     Physical endpoint configuration of the ingress device
+ *
+ * A whole new buffer is allocated for each portion of an aggregated frame.
+ * Caller should keep calling deaggregate() on the source skb until 0 is
+ * returned, indicating that there are no more packets to deaggregate. Caller
+ * is responsible for freeing the original skb.
+ *
+ * Return:
+ *     - Pointer to new skb
+ *     - 0 (null) if no more aggregated packets
+ */
+struct sk_buff *rmnet_map_deaggregate(struct sk_buff *skb,
+				      struct rmnet_phys_ep_conf_s *config)
+{
+	struct sk_buff *skbn;
+	struct rmnet_map_header_s *maph;
+	u32 packet_len;
+
+	if (skb->len == 0)
+		return 0;
+
+	maph = (struct rmnet_map_header_s *)skb->data;
+	packet_len = ntohs(maph->pkt_len) + sizeof(struct rmnet_map_header_s);
+
+	if ((((int)skb->len) - ((int)packet_len)) < 0) {
+		LOGM("%s", "Got malformed packet. Dropping");
+		return 0;
+	}
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
+		LOGD("Dropping empty MAP frame");
+		rmnet_kfree_skb(skbn, RMNET_STATS_SKBFREE_DEAGG_DATA_LEN_0);
+		return 0;
+	}
+
+	return skbn;
+}
diff --git a/drivers/net/rmnet/rmnet_private.h b/drivers/net/rmnet/rmnet_private.h
new file mode 100644
index 0000000..f27e0b3
--- /dev/null
+++ b/drivers/net/rmnet/rmnet_private.h
@@ -0,0 +1,76 @@
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
+#define RMNET_DEV_NAME_STR         "rmnet"
+#define RMNET_NEEDED_HEADROOM      16
+#define RMNET_TX_QUEUE_LEN         1000
+#define RMNET_ETHERNET_HEADER_LENGTH    14
+
+extern unsigned int rmnet_log_level;
+extern unsigned int rmnet_log_module_mask;
+
+#define RMNET_INIT_OK     0
+#define RMNET_INIT_ERROR  1
+
+#define RMNET_LOG_LVL_DBG BIT(4)
+#define RMNET_LOG_LVL_LOW BIT(3)
+#define RMNET_LOG_LVL_MED BIT(2)
+#define RMNET_LOG_LVL_HI  BIT(1)
+#define RMNET_LOG_LVL_ERR BIT(0)
+
+#define RMNET_LOG_MODULE(X) \
+	static u32 rmnet_mod_mask = X
+
+#define RMNET_LOGMASK_CONFIG  BIT(0)
+#define RMNET_LOGMASK_HANDLER BIT(1)
+#define RMNET_LOGMASK_VND     BIT(2)
+#define RMNET_LOGMASK_MAPD    BIT(3)
+#define RMNET_LOGMASK_MAPC    BIT(4)
+
+#define LOGE(fmt, ...) do { if (rmnet_log_level & RMNET_LOG_LVL_ERR) \
+			pr_err("[RMNET:ERR] %s(): " fmt "\n", __func__, \
+				##__VA_ARGS__); \
+			} while (0)
+
+#define LOGH(fmt, ...) do { if (rmnet_log_level & RMNET_LOG_LVL_HI) \
+			pr_err("[RMNET:HI] %s(): " fmt "\n", __func__, \
+				##__VA_ARGS__); \
+			} while (0)
+
+#define LOGM(fmt, ...) do { if (rmnet_log_level & RMNET_LOG_LVL_MED) \
+			pr_warn("[RMNET:MED] %s(): " fmt "\n", __func__, \
+				##__VA_ARGS__); \
+			} while (0)
+
+#define LOGL(fmt, ...) do { if (unlikely \
+			(rmnet_log_level & RMNET_LOG_LVL_LOW)) \
+			pr_notice("[RMNET:LOW] %s(): " fmt "\n", __func__, \
+				##__VA_ARGS__); \
+			} while (0)
+
+/* Don't use pr_debug as it is compiled out of the kernel. We can be sure of
+ * minimal impact as LOGD is not enabled by default.
+ */
+#define LOGD(fmt, ...) do { if (unlikely( \
+			    (rmnet_log_level & RMNET_LOG_LVL_DBG) &&\
+			    (rmnet_log_module_mask & rmnet_mod_mask))) \
+			pr_notice("[RMNET:DBG] %s(): " fmt "\n", __func__, \
+				  ##__VA_ARGS__); \
+			} while (0)
+
+#endif /* _RMNET_PRIVATE_H_ */
diff --git a/drivers/net/rmnet/rmnet_stats.c b/drivers/net/rmnet/rmnet_stats.c
new file mode 100644
index 0000000..d53ce38
--- /dev/null
+++ b/drivers/net/rmnet/rmnet_stats.c
@@ -0,0 +1,86 @@
+/* Copyright (c) 2014, 2016-2017 The Linux Foundation. All rights reserved.
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
+ * RMNET Data statistics
+ *
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/export.h>
+#include <linux/skbuff.h>
+#include <linux/spinlock.h>
+#include <linux/netdevice.h>
+#include "rmnet_private.h"
+#include "rmnet_stats.h"
+#include "rmnet_config.h"
+#include "rmnet_map.h"
+
+enum rmnet_deagg_e {
+	RMNET_STATS_AGG_BUFF,
+	RMNET_STATS_AGG_PKT,
+	RMNET_STATS_AGG_MAX
+};
+
+static DEFINE_SPINLOCK(rmnet_skb_free_lock);
+unsigned long int skb_free[RMNET_STATS_SKBFREE_MAX];
+module_param_array(skb_free, ulong, 0, 0444);
+MODULE_PARM_DESC(skb_free, "SKBs dropped or freed");
+
+static DEFINE_SPINLOCK(rmnet_queue_xmit_lock);
+unsigned long int queue_xmit[RMNET_STATS_QUEUE_XMIT_MAX * 2];
+module_param_array(queue_xmit, ulong, 0, 0444);
+MODULE_PARM_DESC(queue_xmit, "SKBs queued for transmit");
+
+static DEFINE_SPINLOCK(rmnet_deagg_count);
+unsigned long int deagg_count[RMNET_STATS_AGG_MAX];
+module_param_array(deagg_count, ulong, 0, 0444);
+MODULE_PARM_DESC(deagg_count, "SKBs De-aggregated");
+
+void rmnet_kfree_skb(struct sk_buff *skb, unsigned int reason)
+{
+	unsigned long flags;
+
+	if (reason >= RMNET_STATS_SKBFREE_MAX)
+		reason = RMNET_STATS_SKBFREE_UNKNOWN;
+
+	spin_lock_irqsave(&rmnet_skb_free_lock, flags);
+	skb_free[reason]++;
+	spin_unlock_irqrestore(&rmnet_skb_free_lock, flags);
+
+	if (skb)
+		kfree_skb(skb);
+}
+
+void rmnet_stats_queue_xmit(int rc, unsigned int reason)
+{
+	unsigned long flags;
+
+	if (rc != 0)
+		reason += RMNET_STATS_QUEUE_XMIT_MAX;
+	if (reason >= RMNET_STATS_QUEUE_XMIT_MAX * 2)
+		reason = RMNET_STATS_SKBFREE_UNKNOWN;
+
+	spin_lock_irqsave(&rmnet_queue_xmit_lock, flags);
+	queue_xmit[reason]++;
+	spin_unlock_irqrestore(&rmnet_queue_xmit_lock, flags);
+}
+
+void rmnet_stats_deagg_pkts(int aggcount)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&rmnet_deagg_count, flags);
+	deagg_count[RMNET_STATS_AGG_BUFF]++;
+	deagg_count[RMNET_STATS_AGG_PKT] += aggcount;
+	spin_unlock_irqrestore(&rmnet_deagg_count, flags);
+}
diff --git a/drivers/net/rmnet/rmnet_stats.h b/drivers/net/rmnet/rmnet_stats.h
new file mode 100644
index 0000000..c8d0469
--- /dev/null
+++ b/drivers/net/rmnet/rmnet_stats.h
@@ -0,0 +1,61 @@
+/* Copyright (c) 2014, 2016-2017 The Linux Foundation. All rights reserved.
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
+ * RMNET Data statistics
+ *
+ */
+
+#ifndef _RMNET_STATS_H_
+#define _RMNET_STATS_H_
+
+enum rmnet_skb_free_e {
+	RMNET_STATS_SKBFREE_UNKNOWN,
+	RMNET_STATS_SKBFREE_BRDG_NO_EGRESS,
+	RMNET_STATS_SKBFREE_DELIVER_NO_EP,
+	RMNET_STATS_SKBFREE_IPINGRESS_NO_EP,
+	RMNET_STATS_SKBFREE_MAPINGRESS_BAD_MUX,
+	RMNET_STATS_SKBFREE_MAPINGRESS_MUX_NO_EP,
+	RMNET_STATS_SKBFREE_MAPINGRESS_AGGBUF,
+	RMNET_STATS_SKBFREE_INGRESS_NOT_EXPECT_MAPD,
+	RMNET_STATS_SKBFREE_INGRESS_NOT_EXPECT_MAPC,
+	RMNET_STATS_SKBFREE_EGR_MAPFAIL,
+	RMNET_STATS_SKBFREE_VND_NO_EGRESS,
+	RMNET_STATS_SKBFREE_MAPC_BAD_MUX,
+	RMNET_STATS_SKBFREE_MAPC_MUX_NO_EP,
+	RMNET_STATS_SKBFREE_AGG_CPY_EXPAND,
+	RMNET_STATS_SKBFREE_AGG_INTO_BUFF,
+	RMNET_STATS_SKBFREE_DEAGG_MALFORMED,
+	RMNET_STATS_SKBFREE_DEAGG_CLONE_FAIL,
+	RMNET_STATS_SKBFREE_DEAGG_UNKNOWN_IP_TYPE,
+	RMNET_STATS_SKBFREE_DEAGG_DATA_LEN_0,
+	RMNET_STATS_SKBFREE_INGRESS_BAD_MAP_CKSUM,
+	RMNET_STATS_SKBFREE_MAPC_UNSUPPORTED,
+	RMNET_STATS_SKBFREE_MAX
+};
+
+enum rmnet_queue_xmit_e {
+	RMNET_STATS_QUEUE_XMIT_UNKNOWN,
+	RMNET_STATS_QUEUE_XMIT_EGRESS,
+	RMNET_STATS_QUEUE_XMIT_AGG_FILL_BUFFER,
+	RMNET_STATS_QUEUE_XMIT_AGG_TIMEOUT,
+	RMNET_STATS_QUEUE_XMIT_AGG_CPY_EXP_FAIL,
+	RMNET_STATS_QUEUE_XMIT_AGG_SKIP,
+	RMNET_STATS_QUEUE_XMIT_MAX
+};
+
+void rmnet_kfree_skb(struct sk_buff *skb, unsigned int reason);
+void rmnet_stats_queue_xmit(int rc, unsigned int reason);
+void rmnet_stats_deagg_pkts(int aggcount);
+void rmnet_stats_agg_pkts(int aggcount);
+void rmnet_stats_dl_checksum(unsigned int rc);
+void rmnet_stats_ul_checksum(unsigned int rc);
+#endif /* _RMNET_STATS_H_ */
diff --git a/drivers/net/rmnet/rmnet_vnd.c b/drivers/net/rmnet/rmnet_vnd.c
new file mode 100644
index 0000000..a737d0e
--- /dev/null
+++ b/drivers/net/rmnet/rmnet_vnd.c
@@ -0,0 +1,353 @@
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
+#include <linux/types.h>
+#include <linux/rmnet.h>
+#include <linux/etherdevice.h>
+#include <linux/if_arp.h>
+#include <linux/spinlock.h>
+#include <net/pkt_sched.h>
+#include <linux/atomic.h>
+#include "rmnet_config.h"
+#include "rmnet_handlers.h"
+#include "rmnet_private.h"
+#include "rmnet_map.h"
+#include "rmnet_vnd.h"
+#include "rmnet_stats.h"
+
+RMNET_LOG_MODULE(RMNET_LOGMASK_VND);
+
+struct net_device *rmnet_devices[RMNET_MAX_VND];
+
+/* RX/TX Fixup */
+
+/* rmnet_vnd_rx_fixup() - Virtual Network Device receive fixup hook
+ * @skb:        Socket buffer ("packet") to modify
+ * @dev:        Virtual network device
+ *
+ * Additional VND specific packet processing for ingress packets
+ */
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
+/* rmnet_vnd_tx_fixup() - Virtual Network Device transmic fixup hook
+ * @skb:      Socket buffer ("packet") to modify
+ * @dev:      Virtual network device
+ *
+ * Additional VND specific packet processing for egress packets
+ */
+int rmnet_vnd_tx_fixup(struct sk_buff *skb, struct net_device *dev)
+{
+	struct rmnet_vnd_private_s *dev_conf;
+
+	dev_conf = (struct rmnet_vnd_private_s *)netdev_priv(dev);
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
+/* rmnet_vnd_start_xmit() - Transmit NDO callback
+ * @skb:        Socket buffer ("packet") being sent from network stack
+ * @dev:        Virtual Network Device
+ *
+ * Standard network driver operations hook to transmit packets on virtual
+ * network device. Called by network stack. Packet is not transmitted directly
+ * from here; instead it is given to the rmnet egress handler.
+ */
+static netdev_tx_t rmnet_vnd_start_xmit(struct sk_buff *skb,
+					struct net_device *dev)
+{
+	struct rmnet_vnd_private_s *dev_conf;
+
+	dev_conf = (struct rmnet_vnd_private_s *)netdev_priv(dev);
+	if (dev_conf->local_ep.egress_dev) {
+		rmnet_egress_handler(skb, &dev_conf->local_ep);
+	} else {
+		dev->stats.tx_dropped++;
+		rmnet_kfree_skb(skb, RMNET_STATS_SKBFREE_VND_NO_EGRESS);
+	}
+	return NETDEV_TX_OK;
+}
+
+/* rmnet_vnd_change_mtu() - Change MTU NDO callback
+ * @dev:         Virtual network device
+ * @new_mtu:     New MTU value to set (in bytes)
+ *
+ * Standard network driver operations hook to set the MTU. Called by kernel to
+ * set the device MTU. Checks if desired MTU is less than zero or greater than
+ * RMNET_MAX_PACKET_SIZE;
+ */
+static int rmnet_vnd_change_mtu(struct net_device *dev, int new_mtu)
+{
+	if (new_mtu < 0 || new_mtu > RMNET_MAX_PACKET_SIZE)
+		return -EINVAL;
+
+	dev->mtu = new_mtu;
+	return 0;
+}
+
+static const struct net_device_ops rmnet_vnd_ops = {
+	.ndo_init = 0,
+	.ndo_start_xmit = rmnet_vnd_start_xmit,
+	.ndo_change_mtu = rmnet_vnd_change_mtu,
+	.ndo_set_mac_address = 0,
+	.ndo_validate_addr = 0,
+};
+
+static void rmnet_vnd_free(struct net_device *dev)
+{
+	free_netdev(dev);
+}
+
+/* rmnet_vnd_setup() - net_device initialization callback
+ * @dev:      Virtual network device
+ *
+ * Called by kernel whenever a new rmnet<n> device is created. Sets MTU,
+ * flags, ARP type, needed headroom, etc...
+ */
+void rmnet_vnd_setup(struct net_device *dev)
+{
+	struct rmnet_vnd_private_s *dev_conf;
+
+	LOGM("Setting up device %s", dev->name);
+
+	/* Clear out private data */
+	dev_conf = (struct rmnet_vnd_private_s *)netdev_priv(dev);
+	memset(dev_conf, 0, sizeof(struct rmnet_vnd_private_s));
+
+	dev->netdev_ops = &rmnet_vnd_ops;
+	dev->mtu = RMNET_DFLT_PACKET_SIZE;
+	dev->needed_headroom = RMNET_NEEDED_HEADROOM;
+	random_ether_addr(dev->dev_addr);
+	dev->tx_queue_len = RMNET_TX_QUEUE_LEN;
+
+	/* Raw IP mode */
+	dev->header_ops = 0;  /* No header */
+	dev->type = ARPHRD_RAWIP;
+	dev->hard_header_len = 0;
+	dev->flags &= ~(IFF_BROADCAST | IFF_MULTICAST);
+
+	dev->destructor	= rmnet_vnd_free;
+}
+
+/* Exposed API */
+
+/* rmnet_vnd_exit() - Shutdown cleanup hook
+ *
+ * Called by RmNet main on module unload. Cleans up data structures and
+ * unregisters/frees net_devices.
+ */
+void rmnet_vnd_exit(void)
+{
+	int i;
+
+	for (i = 0; i < RMNET_MAX_VND; i++)
+		if (rmnet_devices[i]) {
+			unregister_netdev(rmnet_devices[i]);
+			free_netdev(rmnet_devices[i]);
+	}
+}
+
+/* rmnet_vnd_init() - Init hook
+ *
+ * Called by RmNet main on module load. Initializes data structures
+ */
+int rmnet_vnd_init(void)
+{
+	memset(rmnet_devices, 0, sizeof(struct net_device *) * RMNET_MAX_VND);
+	return 0;
+}
+
+/* rmnet_vnd_create_dev() - Create a new virtual network device node.
+ * @id:         Virtual device node id
+ * @new_device: Pointer to newly created device node
+ * @prefix:     Device name prefix
+ *
+ * Allocates structures for new virtual network devices. Sets the name of the
+ * new device and registers it with the network stack. Device will appear in
+ * ifconfig list after this is called. If the prefix is null, then
+ * RMNET_DEV_NAME_STR will be assumed.
+ */
+int rmnet_vnd_newlink(int id, struct net_device *new_device)
+{
+	int rc;
+
+	if (rmnet_devices[id])
+		return -EINVAL;
+
+	rc = register_netdevice(new_device);
+	if (!rc) {
+		rmnet_devices[id] = new_device;
+		new_device->rtnl_link_ops = &rmnet_link_ops;
+	}
+
+	return rc;
+}
+
+/* rmnet_vnd_free_dev() - free a virtual network device node.
+ * @id:         Virtual device node id
+ *
+ * Unregisters the virtual network device node and frees it.
+ * unregister_netdev locks the rtnl mutex, so the mutex must not be locked
+ * by the caller of the function. unregister_netdev enqueues the request to
+ * unregister the device into a TODO queue. The requests in the TODO queue
+ * are only done after rtnl mutex is unlocked, therefore free_netdev has to
+ * called after unlocking rtnl mutex.
+ */
+int rmnet_vnd_free_dev(int id)
+{
+	struct rmnet_logical_ep_conf_s *epconfig_l;
+	struct net_device *dev;
+
+	rtnl_lock();
+	if ((id < 0) || (id >= RMNET_MAX_VND) || !rmnet_devices[id]) {
+		rtnl_unlock();
+		LOGM("Invalid id [%d]", id);
+		return -EINVAL;
+	}
+
+	epconfig_l = rmnet_vnd_get_le_config(rmnet_devices[id]);
+	if (epconfig_l && epconfig_l->refcount) {
+		rtnl_unlock();
+		return -EINVAL;
+	}
+
+	dev = rmnet_devices[id];
+	rmnet_devices[id] = 0;
+	rtnl_unlock();
+
+	if (dev) {
+		unregister_netdev(dev);
+		free_netdev(dev);
+		return 0;
+	} else {
+		return -EINVAL;
+	}
+}
+
+int rmnet_vnd_remove_ref_dev(int id)
+{
+	struct rmnet_logical_ep_conf_s *epconfig_l;
+
+	if ((id < 0) || (id >= RMNET_MAX_VND) || !rmnet_devices[id])
+		return -EINVAL;
+
+	epconfig_l = rmnet_vnd_get_le_config(rmnet_devices[id]);
+	if (epconfig_l && epconfig_l->refcount)
+		return -EBUSY;
+
+	rmnet_devices[id] = 0;
+	return 0;
+}
+
+/* rmnet_vnd_is_vnd() - Determine if net_device is RmNet owned virtual devices
+ * @dev:        Network device to test
+ *
+ * Searches through list of known RmNet virtual devices. This function is O(n)
+ * and should not be used in the data path.
+ *
+ * To get the read id, subtract this result by 1.
+ */
+int rmnet_vnd_is_vnd(struct net_device *dev)
+{
+	/* This is not an efficient search, but, this will only be called in
+	 * a configuration context, and the list is small.
+	 */
+	int i;
+
+	if (!dev)
+		return 0;
+
+	for (i = 0; i < RMNET_MAX_VND; i++)
+		if (dev == rmnet_devices[i])
+			return i + 1;
+
+	return 0;
+}
+
+/* rmnet_vnd_get_le_config() - Get the logical endpoint configuration
+ * @dev:      Virtual device node
+ *
+ * Gets the logical endpoint configuration for a RmNet virtual network device
+ * node. Caller should confirm that devices is a RmNet VND before calling.
+ */
+struct rmnet_logical_ep_conf_s *rmnet_vnd_get_le_config(struct net_device *dev)
+{
+	struct rmnet_vnd_private_s *dev_conf;
+
+	if (!dev)
+		return 0;
+
+	dev_conf = (struct rmnet_vnd_private_s *)netdev_priv(dev);
+	if (!dev_conf)
+		return 0;
+
+	return &dev_conf->local_ep;
+}
+
+/* rmnet_vnd_do_flow_control() - Process flow control request
+ * @dev: Virtual network device node to do lookup on
+ * @enable: boolean to enable/disable flow.
+ */
+int rmnet_vnd_do_flow_control(struct net_device *dev, int enable)
+{
+	struct rmnet_vnd_private_s *dev_conf;
+
+	if (unlikely(!dev) || !rmnet_vnd_is_vnd(dev))
+		return -EINVAL;
+
+	dev_conf = (struct rmnet_vnd_private_s *)netdev_priv(dev);
+	if (unlikely(!dev_conf))
+		return -EINVAL;
+
+	LOGD("Setting VND TX queue state to %d", enable);
+	/* Although we expect similar number of enable/disable
+	 * commands, optimize for the disable. That is more
+	 * latency sensitive than enable
+	 */
+	if (unlikely(enable))
+		netif_wake_queue(dev);
+	else
+		netif_stop_queue(dev);
+
+	return 0;
+}
+
+/* rmnet_vnd_get_by_id() - Get VND by array index ID
+ * @id: Virtual network deice id [0:RMNET_MAX_VND]
+ */
+struct net_device *rmnet_vnd_get_by_id(int id)
+{
+	if (id < 0 || id >= RMNET_MAX_VND)
+		return 0;
+
+	return rmnet_devices[id];
+}
diff --git a/drivers/net/rmnet/rmnet_vnd.h b/drivers/net/rmnet/rmnet_vnd.h
new file mode 100644
index 0000000..8095e91
--- /dev/null
+++ b/drivers/net/rmnet/rmnet_vnd.h
@@ -0,0 +1,34 @@
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
+#include <linux/types.h>
+
+#ifndef _RMNET_VND_H_
+#define _RMNET_VND_H_
+
+int rmnet_vnd_do_flow_control(struct net_device *dev, int enable);
+struct rmnet_logical_ep_conf_s *rmnet_vnd_get_le_config(struct net_device *dev);
+int rmnet_vnd_free_dev(int id);
+int rmnet_vnd_remove_ref_dev(int id);
+int rmnet_vnd_rx_fixup(struct sk_buff *skb, struct net_device *dev);
+int rmnet_vnd_tx_fixup(struct sk_buff *skb, struct net_device *dev);
+int rmnet_vnd_is_vnd(struct net_device *dev);
+int rmnet_vnd_init(void);
+void rmnet_vnd_exit(void);
+struct net_device *rmnet_vnd_get_by_id(int id);
+void rmnet_vnd_setup(struct net_device *dev);
+int rmnet_vnd_newlink(int id, struct net_device *new_device);
+
+#endif /* _RMNET_VND_H_ */
diff --git a/include/uapi/linux/Kbuild b/include/uapi/linux/Kbuild
index dd9820b..ec29d61 100644
--- a/include/uapi/linux/Kbuild
+++ b/include/uapi/linux/Kbuild
@@ -370,6 +370,7 @@ header-y += resource.h
 header-y += rfkill.h
 header-y += rio_cm_cdev.h
 header-y += rio_mport_cdev.h
+header-y += rmnet.h
 header-y += romfs_fs.h
 header-y += rose.h
 header-y += route.h
diff --git a/include/uapi/linux/if_arp.h b/include/uapi/linux/if_arp.h
index 4d024d7..e762447 100644
--- a/include/uapi/linux/if_arp.h
+++ b/include/uapi/linux/if_arp.h
@@ -59,6 +59,7 @@
 #define ARPHRD_LAPB	516		/* LAPB				*/
 #define ARPHRD_DDCMP    517		/* Digital's DDCMP protocol     */
 #define ARPHRD_RAWHDLC	518		/* Raw HDLC			*/
+#define ARPHRD_RAWIP	530		/* Raw IP			*/
 
 #define ARPHRD_TUNNEL	768		/* IPIP tunnel			*/
 #define ARPHRD_TUNNEL6	769		/* IP6IP6 tunnel       		*/
diff --git a/include/uapi/linux/if_ether.h b/include/uapi/linux/if_ether.h
index 5bc9bfd..70520da 100644
--- a/include/uapi/linux/if_ether.h
+++ b/include/uapi/linux/if_ether.h
@@ -104,7 +104,9 @@
 #define ETH_P_QINQ3	0x9300		/* deprecated QinQ VLAN [ NOT AN OFFICIALLY REGISTERED ID ] */
 #define ETH_P_EDSA	0xDADA		/* Ethertype DSA [ NOT AN OFFICIALLY REGISTERED ID ] */
 #define ETH_P_AF_IUCV   0xFBFB		/* IBM af_iucv [ NOT AN OFFICIALLY REGISTERED ID ] */
-
+#define ETH_P_MAP	0xDA1A		/* Multiplexing and Aggregation Protocol
+					 *  NOT AN OFFICIALLY REGISTERED ID ]
+					 */
 #define ETH_P_802_3_MIN	0x0600		/* If the value in the ethernet type is less than this value
 					 * then the frame is Ethernet II. Else it is 802.3 */
 
diff --git a/include/uapi/linux/rmnet.h b/include/uapi/linux/rmnet.h
new file mode 100644
index 0000000..dce5763
--- /dev/null
+++ b/include/uapi/linux/rmnet.h
@@ -0,0 +1,34 @@
+#ifndef _RMNET_DATA_H_
+#define _RMNET_DATA_H_
+
+/* Constants */
+#define RMNET_EGRESS_FORMAT__RESERVED__         (1<<0)
+#define RMNET_EGRESS_FORMAT_MAP                 (1<<1)
+#define RMNET_EGRESS_FORMAT_AGGREGATION         (1<<2)
+#define RMNET_EGRESS_FORMAT_MUXING              (1<<3)
+#define RMNET_EGRESS_FORMAT_MAP_CKSUMV3         (1<<4)
+#define RMNET_EGRESS_FORMAT_MAP_CKSUMV4         (1<<5)
+
+#define RMNET_INGRESS_FIX_ETHERNET              (1<<0)
+#define RMNET_INGRESS_FORMAT_MAP                (1<<1)
+#define RMNET_INGRESS_FORMAT_DEAGGREGATION      (1<<2)
+#define RMNET_INGRESS_FORMAT_DEMUXING           (1<<3)
+#define RMNET_INGRESS_FORMAT_MAP_COMMANDS       (1<<4)
+#define RMNET_INGRESS_FORMAT_MAP_CKSUMV3        (1<<5)
+#define RMNET_INGRESS_FORMAT_MAP_CKSUMV4        (1<<6)
+
+/* Pass the frame up the stack with no modifications to skb->dev */
+#define RMNET_EPMODE_NONE (0)
+/* Replace skb->dev to a virtual rmnet device and pass up the stack */
+#define	RMNET_EPMODE_VND (1)
+/* Pass the frame directly to another device with dev_queue_xmit() */
+#define	RMNET_EPMODE_BRIDGE (2)
+
+enum {
+	IFLA_RMNET_UNSPEC,
+	IFLA_RMNET_MUX_ID,
+	__IFLA_RMNET_MAX,
+};
+#define __IFLA_RMNET_MAX	(__IFLA_RMNET_MAX - 1)
+
+#endif /* _RMNET_DATA_H_ */
-- 
1.9.1
