From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH net-next 1/1 v2] net: rmnet_data: Initial implementation
Date: Mon, 13 Mar 2017 01:43:09 -0600
Message-ID: <1489390989-2408-2-git-send-email-subashab@codeaurora.org>
References: <1489390989-2408-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
To: netdev@vger.kernel.org, davem@davemloft.net, fengguang.wu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:43184 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750977AbdCMHno (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 03:43:44 -0400
In-Reply-To: <1489390989-2408-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RmNet Data driver provides a transport agnostic MAP (multiplexing and
aggregation protocol) support in embedded and bridge modes. Module
provides virtual network devices which can be attached to any IP-mode
physical device. This will be used to provide all MAP functionality
on future hardware in a single consistent location.

Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
---
 Documentation/networking/rmnet_data.txt |   82 +++
 include/uapi/linux/Kbuild               |    1 +
 include/uapi/linux/if_arp.h             |    1 +
 include/uapi/linux/if_ether.h           |    4 +-
 include/uapi/linux/rmnet_data.h         |  214 ++++++
 net/Kconfig                             |    1 +
 net/Makefile                            |    1 +
 net/rmnet_data/Kconfig                  |   21 +
 net/rmnet_data/Makefile                 |   14 +
 net/rmnet_data/rmnet_data_config.c      | 1168 +++++++++++++++++++++++++++++++
 net/rmnet_data/rmnet_data_config.h      |  107 +++
 net/rmnet_data/rmnet_data_handlers.c    |  556 +++++++++++++++
 net/rmnet_data/rmnet_data_handlers.h    |   24 +
 net/rmnet_data/rmnet_data_main.c        |   60 ++
 net/rmnet_data/rmnet_data_private.h     |   76 ++
 net/rmnet_data/rmnet_data_stats.c       |   86 +++
 net/rmnet_data/rmnet_data_stats.h       |   61 ++
 net/rmnet_data/rmnet_data_trace.h       |  198 ++++++
 net/rmnet_data/rmnet_data_vnd.c         |  460 ++++++++++++
 net/rmnet_data/rmnet_data_vnd.h         |   34 +
 net/rmnet_data/rmnet_map.h              |  100 +++
 net/rmnet_data/rmnet_map_command.c      |  180 +++++
 net/rmnet_data/rmnet_map_data.c         |  148 ++++
 23 files changed, 3596 insertions(+), 1 deletion(-)
 create mode 100644 Documentation/networking/rmnet_data.txt
 create mode 100644 include/uapi/linux/rmnet_data.h
 create mode 100644 net/rmnet_data/Kconfig
 create mode 100644 net/rmnet_data/Makefile
 create mode 100644 net/rmnet_data/rmnet_data_config.c
 create mode 100644 net/rmnet_data/rmnet_data_config.h
 create mode 100644 net/rmnet_data/rmnet_data_handlers.c
 create mode 100644 net/rmnet_data/rmnet_data_handlers.h
 create mode 100644 net/rmnet_data/rmnet_data_main.c
 create mode 100644 net/rmnet_data/rmnet_data_private.h
 create mode 100644 net/rmnet_data/rmnet_data_stats.c
 create mode 100644 net/rmnet_data/rmnet_data_stats.h
 create mode 100644 net/rmnet_data/rmnet_data_trace.h
 create mode 100644 net/rmnet_data/rmnet_data_vnd.c
 create mode 100644 net/rmnet_data/rmnet_data_vnd.h
 create mode 100644 net/rmnet_data/rmnet_map.h
 create mode 100644 net/rmnet_data/rmnet_map_command.c
 create mode 100644 net/rmnet_data/rmnet_map_data.c

diff --git a/Documentation/networking/rmnet_data.txt b/Documentation/networking/rmnet_data.txt
new file mode 100644
index 0000000..ff6cce8
--- /dev/null
+++ b/Documentation/networking/rmnet_data.txt
@@ -0,0 +1,82 @@
+1. Introduction
+
+rmnet_data driver is used for supporting the Multiplexing and aggregation
+Protocol (MAP). This protocol is used by all recent chipsets using Qualcomm
+Technologies, Inc. modems.
+
+This driver can be used to register onto any physical network device in
+IP mode. Physical transports include USB, HSIC, PCIe and IP accelerator.
+
+Multiplexing allows for creation of logical netdevices (rmnet_data devices) to
+handle multiple private data networks (PDN) like a default internet, tethering,
+multimedia messaging service (MMS) or IP media subsystem (IMS). Hardware sends
+packets with MAP headers to rmnet_data. Based on the multiplexer id, rmnet_data
+routes to the appropriate PDN after removing the MAP header.
+
+Aggregation is required to achieve high data rates. This involves hardware
+sending aggregated bunch of MAP frames. rmnet_data driver will de-aggregate
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
+rmnet_data in a single linear skb. rmnet_data will process the individual
+packets and either ACK the MAP command or deliver the IP packet to the
+network stack as needed
+
+MAP header|IP Packet|Optional padding|MAP header|IP Packet|Optional padding....
+MAP header|IP Packet|Optional padding|MAP header|Command Packet|Optional pad...
+
+3. Userspace configuration
+
+rmnet_data userspace configuration is done through netlink library librmnetctl
+and command line utility rmnetcli. Utility is hosted in codeaurora forum git
+
+https://source.codeaurora.org/quic/la/platform/vendor/qcom-opensource/\
+dataservices/tree/rmnetctl
diff --git a/include/uapi/linux/Kbuild b/include/uapi/linux/Kbuild
index dd9820b..c488c87 100644
--- a/include/uapi/linux/Kbuild
+++ b/include/uapi/linux/Kbuild
@@ -370,6 +370,7 @@ header-y += resource.h
 header-y += rfkill.h
 header-y += rio_cm_cdev.h
 header-y += rio_mport_cdev.h
+header-y += rmnet_data.h
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
 
diff --git a/include/uapi/linux/rmnet_data.h b/include/uapi/linux/rmnet_data.h
new file mode 100644
index 0000000..04b6646
--- /dev/null
+++ b/include/uapi/linux/rmnet_data.h
@@ -0,0 +1,214 @@
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
+ * RMNET Data configuration specification
+ */
+
+#ifndef _RMNET_DATA_H_
+#define _RMNET_DATA_H_
+
+/* Netlink API */
+#define RMNET_NETLINK_PROTO 31
+#define RMNET_MAX_STR_LEN  16
+#define RMNET_NL_DATA_MAX_LEN 64
+
+#define RMNET_NETLINK_MSG_COMMAND    0
+#define RMNET_NETLINK_MSG_RETURNCODE 1
+#define RMNET_NETLINK_MSG_RETURNDATA 2
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
+struct rmnet_nl_msg_s {
+	__le16 reserved;
+	__le16 message_type;
+	__le16 reserved2:14;
+	__le16 crd:2;
+	union {
+		__le16 arg_length;
+		__le16 return_code;
+	};
+	union {
+		__u8 data[RMNET_NL_DATA_MAX_LEN];
+		struct {
+			__u8   dev[RMNET_MAX_STR_LEN];
+			__le32 flags;
+			__le16 agg_size;
+			__le16 agg_count;
+			__u8   tail_spacing;
+		} data_format;
+		struct {
+			__u8  dev[RMNET_MAX_STR_LEN];
+			__le32 ep_id;
+			__u8  operating_mode;
+			__u8  next_dev[RMNET_MAX_STR_LEN];
+		} local_ep_config;
+		struct {
+			__le32 id;
+			__u8   vnd_name[RMNET_MAX_STR_LEN];
+		} vnd;
+	};
+};
+
+enum rmnet_netlink_message_types_e {
+	/* RMNET_NETLINK_ASSOCIATE_NETWORK_DEVICE - Register RMNET data driver
+	 *                                          on a particular device.
+	 * Args: char[] dev_name: Null terminated ASCII string, max length: 15
+	 * Returns: status code
+	 */
+	RMNET_NETLINK_ASSOCIATE_NETWORK_DEVICE,
+
+	/* RMNET_NETLINK_UNASSOCIATE_NETWORK_DEVICE - Unregister RMNET data
+	 *                                            driver on a particular
+	 *                                            device.
+	 * Args: char[] dev_name: Null terminated ASCII string, max length: 15
+	 * Returns: status code
+	 */
+	RMNET_NETLINK_UNASSOCIATE_NETWORK_DEVICE,
+
+	/* RMNET_NETLINK_GET_NETWORK_DEVICE_ASSOCIATED - Get if RMNET data
+	 *                                            driver is registered on a
+	 *                                            particular device.
+	 * Args: char[] dev_name: Null terminated ASCII string, max length: 15
+	 * Returns: 1 if registered, 0 if not
+	 */
+	RMNET_NETLINK_GET_NETWORK_DEVICE_ASSOCIATED,
+
+	/* RMNET_NETLINK_SET_LINK_EGRESS_DATA_FORMAT - Sets the egress data
+	 *                                             format for a particular
+	 *                                             link.
+	 * Args: __le32 egress_flags
+	 *       char[] dev_name: Null terminated ASCII string, max length: 15
+	 * Returns: status code
+	 */
+	RMNET_NETLINK_SET_LINK_EGRESS_DATA_FORMAT,
+
+	/* RMNET_NETLINK_GET_LINK_EGRESS_DATA_FORMAT - Gets the egress data
+	 *                                             format for a particular
+	 *                                             link.
+	 * Args: char[] dev_name: Null terminated ASCII string, max length: 15
+	 * Returns: 4-bytes data: __le32 egress_flags
+	 */
+	RMNET_NETLINK_GET_LINK_EGRESS_DATA_FORMAT,
+
+	/* RMNET_NETLINK_SET_LINK_INGRESS_DATA_FORMAT - Sets the ingress data
+	 *                                              format for a particular
+	 *                                              link.
+	 * Args: __le32 ingress_flags
+	 *       char[] dev_name: Null terminated ASCII string, max length: 15
+	 * Returns: status code
+	 */
+	RMNET_NETLINK_SET_LINK_INGRESS_DATA_FORMAT,
+
+	/* RMNET_NETLINK_GET_LINK_INGRESS_DATA_FORMAT - Gets the ingress data
+	 *                                              format for a particular
+	 *                                              link.
+	 * Args: char[] dev_name: Null terminated ASCII string, max length: 15
+	 * Returns: 4-bytes data: __le32 ingress_flags
+	 */
+	RMNET_NETLINK_GET_LINK_INGRESS_DATA_FORMAT,
+
+	/* RMNET_NETLINK_SET_LOGICAL_EP_CONFIG - Sets the logical endpoint
+	 *                                       configuration for a particular
+	 *                                       link.
+	 * Args: char[] dev_name: Null terminated ASCII string, max length: 15
+	 *     __le32 logical_ep_id, valid values are -1 through 31
+	 *     __u8 rmnet_mode: one of none, vnd, bridged
+	 *     char[] egress_dev_name: Egress device if operating in bridge mode
+	 * Returns: status code
+	 */
+	RMNET_NETLINK_SET_LOGICAL_EP_CONFIG,
+
+	/* RMNET_NETLINK_UNSET_LOGICAL_EP_CONFIG - Un-sets the logical endpoint
+	 *                                       configuration for a particular
+	 *                                       link.
+	 * Args: char[] dev_name: Null terminated ASCII string, max length: 15
+	 *       __le32 logical_ep_id, valid values are -1 through 31
+	 * Returns: status code
+	 */
+	RMNET_NETLINK_UNSET_LOGICAL_EP_CONFIG,
+
+	/* RMNET_NETLINK_GET_LOGICAL_EP_CONFIG - Gets the logical endpoint
+	 *                                       configuration for a particular
+	 *                                       link.
+	 * Args: char[] dev_name: Null terminated ASCII string, max length: 15
+	 *        __le32 logical_ep_id, valid values are -1 through 31
+	 * Returns: __u8 rmnet_mode: one of none, vnd, bridged
+	 * char[] egress_dev_name: Egress device
+	 */
+	RMNET_NETLINK_GET_LOGICAL_EP_CONFIG,
+
+	/* RMNET_NETLINK_NEW_VND - Creates a new virtual network device node
+	 * Args: __le32 node number
+	 * Returns: status code
+	 */
+	RMNET_NETLINK_NEW_VND,
+
+	/* RMNET_NETLINK_NEW_VND_WITH_PREFIX - Creates a new virtual network
+	 *                                     device node with the specified
+	 *                                     prefix for the device name
+	 * Args: __le32 node number
+	 *       char[] vnd_name - Use as prefix
+	 * Returns: status code
+	 */
+	RMNET_NETLINK_NEW_VND_WITH_PREFIX,
+
+	/* RMNET_NETLINK_GET_VND_NAME - Gets the string name of a VND from ID
+	 * Args: __le32 node number
+	 * Returns: char[] vnd_name
+	 */
+	RMNET_NETLINK_GET_VND_NAME,
+
+	/* RMNET_NETLINK_FREE_VND - Removes virtual network device node
+	 * Args: __le32 node number
+	 * Returns: status code
+	 */
+	RMNET_NETLINK_FREE_VND
+};
+
+enum rmnet_config_endpoint_modes_e {
+	/* Pass the frame up the stack with no modifications to skb->dev      */
+	RMNET_EPMODE_NONE,
+	/* Replace skb->dev to a virtual rmnet device and pass up the stack   */
+	RMNET_EPMODE_VND,
+	/* Pass the frame directly to another device with dev_queue_xmit().   */
+	RMNET_EPMODE_BRIDGE,
+	/* Must be the last item in the list                                  */
+	RMNET_EPMODE_LENGTH
+};
+
+enum rmnet_config_return_codes_e {
+	RMNET_CONFIG_OK,
+	RMNET_CONFIG_UNKNOWN_MESSAGE,
+	RMNET_CONFIG_UNKNOWN_ERROR,
+	RMNET_CONFIG_NOMEM,
+	RMNET_CONFIG_DEVICE_IN_USE,
+	RMNET_CONFIG_INVALID_REQUEST,
+	RMNET_CONFIG_NO_SUCH_DEVICE,
+	RMNET_CONFIG_BAD_ARGUMENTS,
+	RMNET_CONFIG_BAD_EGRESS_DEVICE,
+	RMNET_CONFIG_TC_HANDLE_FULL
+};
+
+#endif /* _RMNET_DATA_H_ */
diff --git a/net/Kconfig b/net/Kconfig
index 102f781..77a0d93 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -239,6 +239,7 @@ source "net/switchdev/Kconfig"
 source "net/l3mdev/Kconfig"
 source "net/qrtr/Kconfig"
 source "net/ncsi/Kconfig"
+source "net/rmnet_data/Kconfig"
 
 config RPS
 	bool
diff --git a/net/Makefile b/net/Makefile
index 9b68155..4a04f56 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -84,3 +84,4 @@ obj-y				+= l3mdev/
 endif
 obj-$(CONFIG_QRTR)		+= qrtr/
 obj-$(CONFIG_NET_NCSI)		+= ncsi/
+obj-$(CONFIG_RMNET_DATA)	+= rmnet_data/
diff --git a/net/rmnet_data/Kconfig b/net/rmnet_data/Kconfig
new file mode 100644
index 0000000..4748a6f
--- /dev/null
+++ b/net/rmnet_data/Kconfig
@@ -0,0 +1,21 @@
+#
+# RMNET Data and MAP driver
+#
+
+menuconfig RMNET_DATA
+	depends on NETDEVICES
+	bool "RmNet Data and MAP driver"
+	---help---
+	  If you say Y here, then the rmnet_data module will be statically
+	  compiled into the kernel. The rmnet data module provides MAP
+	  functionality for embedded and bridged traffic.
+if RMNET_DATA
+
+config RMNET_DATA_DEBUG
+	bool "RmNet Data Debug Logging"
+	---help---
+	  Say Y here if you want RmNet data to be able to log packets in main
+	  system log. This should not be enabled on production builds as it can
+	  impact system performance. Note that simply enabling it here will not
+	  enable the logging; it must be enabled at run-time as well.
+endif # RMNET_DATA
diff --git a/net/rmnet_data/Makefile b/net/rmnet_data/Makefile
new file mode 100644
index 0000000..ccb8b5b
--- /dev/null
+++ b/net/rmnet_data/Makefile
@@ -0,0 +1,14 @@
+#
+# Makefile for the RMNET Data module
+#
+
+rmnet_data-y		 := rmnet_data_main.o
+rmnet_data-y		 += rmnet_data_config.o
+rmnet_data-y		 += rmnet_data_vnd.o
+rmnet_data-y		 += rmnet_data_handlers.o
+rmnet_data-y		 += rmnet_map_data.o
+rmnet_data-y		 += rmnet_map_command.o
+rmnet_data-y		 += rmnet_data_stats.o
+obj-$(CONFIG_RMNET_DATA) += rmnet_data.o
+
+CFLAGS_rmnet_data_main.o := -I$(src)
diff --git a/net/rmnet_data/rmnet_data_config.c b/net/rmnet_data/rmnet_data_config.c
new file mode 100644
index 0000000..38a21d8
--- /dev/null
+++ b/net/rmnet_data/rmnet_data_config.c
@@ -0,0 +1,1168 @@
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
+ * RMNET Data configuration engine
+ *
+ */
+
+#include <net/sock.h>
+#include <linux/module.h>
+#include <linux/netlink.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <linux/spinlock.h>
+#include <linux/rmnet_data.h>
+#include "rmnet_data_config.h"
+#include "rmnet_data_handlers.h"
+#include "rmnet_data_vnd.h"
+#include "rmnet_data_private.h"
+#include "rmnet_data_trace.h"
+
+RMNET_LOG_MODULE(RMNET_DATA_LOGMASK_CONFIG);
+
+/* Local Definitions and Declarations */
+#define RMNET_LOCAL_LOGICAL_ENDPOINT -1
+
+static struct sock *nl_socket_handle;
+
+static struct netlink_kernel_cfg rmnet_netlink_cfg = {
+	.input = rmnet_config_netlink_msg_handler
+};
+
+static struct notifier_block rmnet_dev_notifier = {
+	.notifier_call = rmnet_config_notify_cb,
+	.next = 0,
+	.priority = 0
+};
+
+struct rmnet_free_vnd_work {
+	struct work_struct work;
+	int vnd_id[RMNET_DATA_MAX_VND];
+	int count;
+};
+
+/* Init and Cleanup */
+
+static struct sock *_rmnet_config_start_netlink(void)
+{
+	return netlink_kernel_create(&init_net,
+				     RMNET_NETLINK_PROTO,
+				     &rmnet_netlink_cfg);
+}
+
+/* rmnet_config_init() - Startup init
+ *
+ * Registers netlink protocol with kernel and opens socket. Netlink handler is
+ * registered with kernel.
+ */
+int rmnet_config_init(void)
+{
+	int rc;
+
+	nl_socket_handle = _rmnet_config_start_netlink();
+	if (!nl_socket_handle) {
+		LOGE("%s", "Failed to init netlink socket");
+		return RMNET_INIT_ERROR;
+	}
+
+	rc = register_netdevice_notifier(&rmnet_dev_notifier);
+	if (rc != 0) {
+		LOGE("Failed to register device notifier; rc=%d", rc);
+		/* TODO: Cleanup the nl socket */
+		return RMNET_INIT_ERROR;
+	}
+
+	return 0;
+}
+
+/* rmnet_config_exit() - Cleans up all netlink related resources
+ */
+void rmnet_config_exit(void)
+{
+	int rc;
+
+	netlink_kernel_release(nl_socket_handle);
+	rc = unregister_netdevice_notifier(&rmnet_dev_notifier);
+	if (rc != 0)
+		LOGE("Failed to unregister device notifier; rc=%d", rc);
+}
+
+/* Helper Functions */
+
+/* _rmnet_is_physical_endpoint_associated() - Determines if device is associated
+ * @dev:      Device to get check
+ *
+ * Compares device rx_handler callback pointer against known function
+ *
+ * Return:
+ *      - 1 if associated
+ *      - 0 if NOT associated
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
+ *
+ * Return:
+ *     - pointer to configuration if successful
+ *     - 0 (null) if device is not associated
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
+/* _rmnet_get_logical_ep() - Gets the logical end point configuration
+ * structure for a network device
+ * @dev:             Device to get endpoint configuration from
+ * @config_id:       Logical endpoint id on device
+ * Retrieves the logical_endpoint_config structure.
+ *
+ * Return:
+ *      - End point configuration structure
+ *      - NULL in case of an error
+ */
+struct rmnet_logical_ep_conf_s *_rmnet_get_logical_ep(struct net_device *dev,
+						      int config_id)
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
+static void _rmnet_netlink_set_link_egress_data_format
+					(struct rmnet_nl_msg_s *rmnet_header,
+					 struct rmnet_nl_msg_s *resp_rmnet)
+{
+	struct net_device *dev;
+
+	if (!rmnet_header || !resp_rmnet)
+		return;
+
+	resp_rmnet->crd = RMNET_NETLINK_MSG_RETURNCODE;
+	dev = dev_get_by_name(&init_net, rmnet_header->data_format.dev);
+
+	if (!dev) {
+		resp_rmnet->return_code = RMNET_CONFIG_NO_SUCH_DEVICE;
+		return;
+	}
+
+	resp_rmnet->return_code =
+		rmnet_set_egress_data_format(dev,
+					     rmnet_header->data_format.flags,
+					     rmnet_header->data_format.agg_size,
+					     rmnet_header->data_format.agg_count
+					     );
+	dev_put(dev);
+}
+
+static void _rmnet_netlink_set_link_ingress_data_format
+					(struct rmnet_nl_msg_s *rmnet_header,
+					 struct rmnet_nl_msg_s *resp_rmnet)
+{
+	struct net_device *dev;
+
+	if (!rmnet_header || !resp_rmnet)
+		return;
+
+	resp_rmnet->crd = RMNET_NETLINK_MSG_RETURNCODE;
+
+	dev = dev_get_by_name(&init_net, rmnet_header->data_format.dev);
+	if (!dev) {
+		resp_rmnet->return_code = RMNET_CONFIG_NO_SUCH_DEVICE;
+		return;
+	}
+
+	resp_rmnet->return_code = rmnet_set_ingress_data_format(
+					dev,
+					rmnet_header->data_format.flags);
+	dev_put(dev);
+}
+
+static void _rmnet_netlink_set_logical_ep_config
+					(struct rmnet_nl_msg_s *rmnet_header,
+					 struct rmnet_nl_msg_s *resp_rmnet)
+{
+	struct net_device *dev, *dev2;
+
+	if (!rmnet_header || !resp_rmnet)
+		return;
+
+	resp_rmnet->crd = RMNET_NETLINK_MSG_RETURNCODE;
+	if (rmnet_header->local_ep_config.ep_id < -1 ||
+	    rmnet_header->local_ep_config.ep_id > 254) {
+		resp_rmnet->return_code = RMNET_CONFIG_BAD_ARGUMENTS;
+		return;
+	}
+
+	dev = dev_get_by_name(&init_net,
+			      rmnet_header->local_ep_config.dev);
+
+	dev2 = dev_get_by_name(&init_net,
+			       rmnet_header->local_ep_config.next_dev);
+
+	if (dev && dev2)
+		resp_rmnet->return_code =
+			rmnet_set_logical_endpoint_config(
+				dev,
+				rmnet_header->local_ep_config.ep_id,
+				rmnet_header->local_ep_config.operating_mode,
+				dev2);
+	else
+		resp_rmnet->return_code = RMNET_CONFIG_NO_SUCH_DEVICE;
+
+	if (dev)
+		dev_put(dev);
+	if (dev2)
+		dev_put(dev2);
+}
+
+static void _rmnet_netlink_unset_logical_ep_config
+					(struct rmnet_nl_msg_s *rmnet_header,
+					 struct rmnet_nl_msg_s *resp_rmnet)
+{
+	struct net_device *dev;
+
+	if (!rmnet_header || !resp_rmnet)
+		return;
+
+	resp_rmnet->crd = RMNET_NETLINK_MSG_RETURNCODE;
+	if (rmnet_header->local_ep_config.ep_id < -1 ||
+	    rmnet_header->local_ep_config.ep_id > 254) {
+		resp_rmnet->return_code = RMNET_CONFIG_BAD_ARGUMENTS;
+		return;
+	}
+
+	dev = dev_get_by_name(&init_net, rmnet_header->local_ep_config.dev);
+
+	if (dev) {
+		resp_rmnet->return_code =
+			rmnet_unset_logical_endpoint_config(
+				dev,
+				rmnet_header->local_ep_config.ep_id);
+		dev_put(dev);
+	} else {
+		resp_rmnet->return_code = RMNET_CONFIG_NO_SUCH_DEVICE;
+	}
+}
+
+static void _rmnet_netlink_get_logical_ep_config
+					(struct rmnet_nl_msg_s *rmnet_header,
+					 struct rmnet_nl_msg_s *resp_rmnet)
+{
+	struct net_device *dev;
+
+	if (!rmnet_header || !resp_rmnet)
+		return;
+
+	resp_rmnet->crd = RMNET_NETLINK_MSG_RETURNCODE;
+	if (rmnet_header->local_ep_config.ep_id < -1 ||
+	    rmnet_header->local_ep_config.ep_id > 254) {
+		resp_rmnet->return_code = RMNET_CONFIG_BAD_ARGUMENTS;
+		return;
+	}
+
+	dev = dev_get_by_name(&init_net, rmnet_header->local_ep_config.dev);
+
+	if (dev) {
+		resp_rmnet->return_code =
+			rmnet_get_logical_endpoint_config(
+				dev,
+				rmnet_header->local_ep_config.ep_id,
+				&resp_rmnet->local_ep_config.operating_mode,
+				resp_rmnet->local_ep_config.next_dev,
+				sizeof(resp_rmnet->local_ep_config.next_dev));
+	} else {
+		resp_rmnet->return_code = RMNET_CONFIG_NO_SUCH_DEVICE;
+		return;
+	}
+
+	if (resp_rmnet->return_code == RMNET_CONFIG_OK) {
+		/* Begin Data */
+		resp_rmnet->crd = RMNET_NETLINK_MSG_RETURNDATA;
+		resp_rmnet->arg_length = sizeof(((struct rmnet_nl_msg_s *)0)
+						->local_ep_config);
+	}
+	dev_put(dev);
+}
+
+static void _rmnet_netlink_associate_network_device
+					(struct rmnet_nl_msg_s *rmnet_header,
+					 struct rmnet_nl_msg_s *resp_rmnet)
+{
+	struct net_device *dev;
+
+	if (!rmnet_header || !resp_rmnet)
+		return;
+
+	resp_rmnet->crd = RMNET_NETLINK_MSG_RETURNCODE;
+
+	dev = dev_get_by_name(&init_net, rmnet_header->data);
+	if (!dev) {
+		resp_rmnet->return_code = RMNET_CONFIG_NO_SUCH_DEVICE;
+		return;
+	}
+
+	resp_rmnet->return_code = rmnet_associate_network_device(dev);
+	dev_put(dev);
+}
+
+static void _rmnet_netlink_unassociate_network_device
+					(struct rmnet_nl_msg_s *rmnet_header,
+					 struct rmnet_nl_msg_s *resp_rmnet)
+{
+	struct net_device *dev;
+
+	if (!rmnet_header || !resp_rmnet)
+		return;
+
+	resp_rmnet->crd = RMNET_NETLINK_MSG_RETURNCODE;
+
+	dev = dev_get_by_name(&init_net, rmnet_header->data);
+	if (!dev) {
+		resp_rmnet->return_code = RMNET_CONFIG_NO_SUCH_DEVICE;
+		return;
+	}
+
+	resp_rmnet->return_code = rmnet_unassociate_network_device(dev);
+	dev_put(dev);
+}
+
+static void _rmnet_netlink_get_network_device_associated
+					(struct rmnet_nl_msg_s *rmnet_header,
+					 struct rmnet_nl_msg_s *resp_rmnet)
+{
+	struct net_device *dev;
+
+	if (!rmnet_header || !resp_rmnet)
+		return;
+
+	resp_rmnet->crd = RMNET_NETLINK_MSG_RETURNCODE;
+
+	dev = dev_get_by_name(&init_net, rmnet_header->data);
+	if (!dev) {
+		resp_rmnet->return_code = RMNET_CONFIG_NO_SUCH_DEVICE;
+		return;
+	}
+
+	resp_rmnet->return_code = _rmnet_is_physical_endpoint_associated(dev);
+	resp_rmnet->crd = RMNET_NETLINK_MSG_RETURNDATA;
+	dev_put(dev);
+}
+
+static void _rmnet_netlink_get_link_egress_data_format
+					(struct rmnet_nl_msg_s *rmnet_header,
+					 struct rmnet_nl_msg_s *resp_rmnet)
+{
+	struct net_device *dev;
+	struct rmnet_phys_ep_conf_s *config;
+
+	if (!rmnet_header || !resp_rmnet)
+		return;
+
+	resp_rmnet->crd = RMNET_NETLINK_MSG_RETURNCODE;
+
+	dev = dev_get_by_name(&init_net, rmnet_header->data_format.dev);
+	if (!dev) {
+		resp_rmnet->return_code = RMNET_CONFIG_NO_SUCH_DEVICE;
+		return;
+	}
+
+	config = _rmnet_get_phys_ep_config(dev);
+	if (!config) {
+		resp_rmnet->return_code = RMNET_CONFIG_INVALID_REQUEST;
+		dev_put(dev);
+		return;
+	}
+
+	/* Begin Data */
+	resp_rmnet->crd = RMNET_NETLINK_MSG_RETURNDATA;
+	resp_rmnet->arg_length = sizeof(((struct rmnet_nl_msg_s *)0)
+					->data_format);
+	resp_rmnet->data_format.flags = config->egress_data_format;
+	resp_rmnet->data_format.agg_count = 0;
+	resp_rmnet->data_format.agg_size  = 0;
+	dev_put(dev);
+}
+
+static void _rmnet_netlink_get_link_ingress_data_format
+					(struct rmnet_nl_msg_s *rmnet_header,
+					 struct rmnet_nl_msg_s *resp_rmnet)
+{
+	struct net_device *dev;
+	struct rmnet_phys_ep_conf_s *config;
+
+	if (!rmnet_header || !resp_rmnet)
+		return;
+
+	resp_rmnet->crd = RMNET_NETLINK_MSG_RETURNCODE;
+
+	dev = dev_get_by_name(&init_net, rmnet_header->data_format.dev);
+	if (!dev) {
+		resp_rmnet->return_code = RMNET_CONFIG_NO_SUCH_DEVICE;
+		return;
+	}
+
+	config = _rmnet_get_phys_ep_config(dev);
+	if (!config) {
+		resp_rmnet->return_code = RMNET_CONFIG_INVALID_REQUEST;
+		dev_put(dev);
+		return;
+	}
+
+	/* Begin Data */
+	resp_rmnet->crd = RMNET_NETLINK_MSG_RETURNDATA;
+	resp_rmnet->arg_length = sizeof(((struct rmnet_nl_msg_s *)0)
+					->data_format);
+	resp_rmnet->data_format.flags = config->ingress_data_format;
+	dev_put(dev);
+}
+
+static void _rmnet_netlink_get_vnd_name
+					(struct rmnet_nl_msg_s *rmnet_header,
+					 struct rmnet_nl_msg_s *resp_rmnet)
+{
+	int r;
+
+	if (!rmnet_header || !resp_rmnet)
+		return;
+
+	resp_rmnet->crd = RMNET_NETLINK_MSG_RETURNCODE;
+
+	r = rmnet_vnd_get_name(rmnet_header->vnd.id, resp_rmnet->vnd.vnd_name,
+			       RMNET_MAX_STR_LEN);
+
+	if (r != 0) {
+		resp_rmnet->return_code = RMNET_CONFIG_INVALID_REQUEST;
+		return;
+	}
+
+	/* Begin Data */
+	resp_rmnet->crd = RMNET_NETLINK_MSG_RETURNDATA;
+	resp_rmnet->arg_length = sizeof(((struct rmnet_nl_msg_s *)0)->vnd);
+}
+
+/* rmnet_config_netlink_msg_handler() - Netlink message handler callback
+ * @skb:      Packet containing netlink messages
+ *
+ * Standard kernel-expected format for a netlink message handler. Processes SKBs
+ * which contain RmNet data specific netlink messages.
+ */
+void rmnet_config_netlink_msg_handler(struct sk_buff *skb)
+{
+	struct nlmsghdr *nlmsg_header, *resp_nlmsg;
+	struct rmnet_nl_msg_s *rmnet_header, *resp_rmnet;
+	int return_pid, response_data_length;
+	struct sk_buff *skb_response;
+
+	response_data_length = 0;
+	nlmsg_header = (struct nlmsghdr *)skb->data;
+	rmnet_header = (struct rmnet_nl_msg_s *)nlmsg_data(nlmsg_header);
+
+	if (!nlmsg_header->nlmsg_pid ||
+	    (nlmsg_header->nlmsg_len < sizeof(struct nlmsghdr) +
+				       sizeof(struct rmnet_nl_msg_s)))
+		return;
+
+	LOGL("Netlink message pid=%d, seq=%d, length=%d, rmnet_type=%d",
+	     nlmsg_header->nlmsg_pid,
+	     nlmsg_header->nlmsg_seq,
+	     nlmsg_header->nlmsg_len,
+	     rmnet_header->message_type);
+
+	return_pid = nlmsg_header->nlmsg_pid;
+
+	skb_response = nlmsg_new(sizeof(struct nlmsghdr)
+				 + sizeof(struct rmnet_nl_msg_s),
+				 GFP_KERNEL);
+
+	if (!skb_response) {
+		LOGH("%s", "Failed to allocate response buffer");
+		return;
+	}
+
+	resp_nlmsg = nlmsg_put(skb_response,
+			       0,
+			       nlmsg_header->nlmsg_seq,
+			       NLMSG_DONE,
+			       sizeof(struct rmnet_nl_msg_s),
+			       0);
+
+	resp_rmnet = nlmsg_data(resp_nlmsg);
+
+	if (!resp_rmnet)
+		return;
+
+	resp_rmnet->message_type = rmnet_header->message_type;
+	rtnl_lock();
+	switch (rmnet_header->message_type) {
+	case RMNET_NETLINK_ASSOCIATE_NETWORK_DEVICE:
+		_rmnet_netlink_associate_network_device
+						(rmnet_header, resp_rmnet);
+		break;
+
+	case RMNET_NETLINK_UNASSOCIATE_NETWORK_DEVICE:
+		_rmnet_netlink_unassociate_network_device
+						(rmnet_header, resp_rmnet);
+		break;
+
+	case RMNET_NETLINK_GET_NETWORK_DEVICE_ASSOCIATED:
+		_rmnet_netlink_get_network_device_associated
+						(rmnet_header, resp_rmnet);
+		break;
+
+	case RMNET_NETLINK_SET_LINK_EGRESS_DATA_FORMAT:
+		_rmnet_netlink_set_link_egress_data_format
+						(rmnet_header, resp_rmnet);
+		break;
+
+	case RMNET_NETLINK_GET_LINK_EGRESS_DATA_FORMAT:
+		_rmnet_netlink_get_link_egress_data_format
+						(rmnet_header, resp_rmnet);
+		break;
+
+	case RMNET_NETLINK_SET_LINK_INGRESS_DATA_FORMAT:
+		_rmnet_netlink_set_link_ingress_data_format
+						(rmnet_header, resp_rmnet);
+		break;
+
+	case RMNET_NETLINK_GET_LINK_INGRESS_DATA_FORMAT:
+		_rmnet_netlink_get_link_ingress_data_format
+						(rmnet_header, resp_rmnet);
+		break;
+
+	case RMNET_NETLINK_SET_LOGICAL_EP_CONFIG:
+		_rmnet_netlink_set_logical_ep_config(rmnet_header, resp_rmnet);
+		break;
+
+	case RMNET_NETLINK_UNSET_LOGICAL_EP_CONFIG:
+		_rmnet_netlink_unset_logical_ep_config(rmnet_header,
+						       resp_rmnet);
+		break;
+
+	case RMNET_NETLINK_GET_LOGICAL_EP_CONFIG:
+		_rmnet_netlink_get_logical_ep_config(rmnet_header, resp_rmnet);
+		break;
+
+	case RMNET_NETLINK_NEW_VND:
+		resp_rmnet->crd = RMNET_NETLINK_MSG_RETURNCODE;
+		resp_rmnet->return_code =
+					 rmnet_create_vnd(rmnet_header->vnd.id);
+		break;
+
+	case RMNET_NETLINK_NEW_VND_WITH_PREFIX:
+		resp_rmnet->crd = RMNET_NETLINK_MSG_RETURNCODE;
+		resp_rmnet->return_code = rmnet_create_vnd_prefix(
+						rmnet_header->vnd.id,
+						rmnet_header->vnd.vnd_name);
+		break;
+
+	case RMNET_NETLINK_FREE_VND:
+		resp_rmnet->crd = RMNET_NETLINK_MSG_RETURNCODE;
+		/* Please check rmnet_vnd_free_dev documentation regarding
+		 * the below locking sequence
+		 */
+		rtnl_unlock();
+		resp_rmnet->return_code = rmnet_free_vnd(rmnet_header->vnd.id);
+		rtnl_lock();
+		break;
+
+	case RMNET_NETLINK_GET_VND_NAME:
+		_rmnet_netlink_get_vnd_name(rmnet_header, resp_rmnet);
+		break;
+
+	default:
+		resp_rmnet->crd = RMNET_NETLINK_MSG_RETURNCODE;
+		resp_rmnet->return_code = RMNET_CONFIG_UNKNOWN_MESSAGE;
+		break;
+	}
+	rtnl_unlock();
+	nlmsg_unicast(nl_socket_handle, skb_response, return_pid);
+	LOGD("%s", "Done processing command");
+}
+
+/* Configuration API */
+
+/* rmnet_unassociate_network_device() - Unassociate network device
+ * @dev:      Device to unassociate
+ *
+ * Frees all structures generate for device. Unregisters rx_handler
+ * todo: needs to do some sanity verification first (is device in use, etc...)
+ *
+ * Return:
+ *      - RMNET_CONFIG_OK if successful
+ *      - RMNET_CONFIG_NO_SUCH_DEVICE dev is null
+ *      - RMNET_CONFIG_INVALID_REQUEST if device is not already associated
+ *      - RMNET_CONFIG_DEVICE_IN_USE if device has logical ep that wasn't unset
+ *      - RMNET_CONFIG_UNKNOWN_ERROR net_device private section is null
+ */
+int rmnet_unassociate_network_device(struct net_device *dev)
+{
+	struct rmnet_phys_ep_conf_s *config;
+	int config_id = RMNET_LOCAL_LOGICAL_ENDPOINT;
+	struct rmnet_logical_ep_conf_s *epconfig_l;
+
+	ASSERT_RTNL();
+
+	LOGL("(%s);", dev->name);
+
+	if (!dev)
+		return RMNET_CONFIG_NO_SUCH_DEVICE;
+
+	if (!_rmnet_is_physical_endpoint_associated(dev))
+		return RMNET_CONFIG_INVALID_REQUEST;
+
+	for (; config_id < RMNET_DATA_MAX_LOGICAL_EP; config_id++) {
+		epconfig_l = _rmnet_get_logical_ep(dev, config_id);
+		if (epconfig_l && epconfig_l->refcount)
+			return RMNET_CONFIG_DEVICE_IN_USE;
+	}
+
+	config = (struct rmnet_phys_ep_conf_s *)
+		rcu_dereference(dev->rx_handler_data);
+
+	if (!config)
+		return RMNET_CONFIG_UNKNOWN_ERROR;
+
+	kfree(config);
+
+	netdev_rx_handler_unregister(dev);
+
+	/* Explicitly release the reference from the device */
+	dev_put(dev);
+	trace_rmnet_unassociate(dev);
+	return RMNET_CONFIG_OK;
+}
+
+/* rmnet_set_ingress_data_format() - Set ingress data format on network device
+ * @dev:                 Device to ingress data format on
+ * @egress_data_format:  32-bit unsigned bitmask of ingress format
+ *
+ * Network device must already have association with RmNet Data driver
+ *
+ * Return:
+ *      - RMNET_CONFIG_OK if successful
+ *      - RMNET_CONFIG_NO_SUCH_DEVICE dev is null
+ *      - RMNET_CONFIG_UNKNOWN_ERROR net_device private section is null
+ */
+int rmnet_set_ingress_data_format(struct net_device *dev,
+				  u32 ingress_data_format)
+{
+	struct rmnet_phys_ep_conf_s *config;
+
+	ASSERT_RTNL();
+
+	LOGL("(%s,0x%08X);", dev->name, ingress_data_format);
+
+	if (!dev)
+		return RMNET_CONFIG_NO_SUCH_DEVICE;
+
+	config = _rmnet_get_phys_ep_config(dev);
+
+	if (!config)
+		return RMNET_CONFIG_INVALID_REQUEST;
+
+	config->ingress_data_format = ingress_data_format;
+
+	return RMNET_CONFIG_OK;
+}
+
+/* rmnet_set_egress_data_format() - Set egress data format on network device
+ * @dev:                 Device to egress data format on
+ * @egress_data_format:  32-bit unsigned bitmask of egress format
+ *
+ * Network device must already have association with RmNet Data driver
+ * todo: Bounds check on agg_*
+ *
+ * Return:
+ *      - RMNET_CONFIG_OK if successful
+ *      - RMNET_CONFIG_NO_SUCH_DEVICE dev is null
+ *      - RMNET_CONFIG_UNKNOWN_ERROR net_device private section is null
+ */
+int rmnet_set_egress_data_format(struct net_device *dev,
+				 u32 egress_data_format,
+				 u16 agg_size,
+				 u16 agg_count)
+{
+	struct rmnet_phys_ep_conf_s *config;
+
+	ASSERT_RTNL();
+
+	LOGL("(%s,0x%08X, %d, %d);",
+	     dev->name, egress_data_format, agg_size, agg_count);
+
+	if (!dev)
+		return RMNET_CONFIG_NO_SUCH_DEVICE;
+
+	config = _rmnet_get_phys_ep_config(dev);
+
+	if (!config)
+		return RMNET_CONFIG_UNKNOWN_ERROR;
+
+	config->egress_data_format = egress_data_format;
+
+	return RMNET_CONFIG_OK;
+}
+
+/* rmnet_associate_network_device() - Associate network device
+ * @dev:      Device to register with RmNet data
+ *
+ * Typically used on physical network devices. Registers RX handler and private
+ * metadata structures.
+ *
+ * Return:
+ *      - RMNET_CONFIG_OK if successful
+ *      - RMNET_CONFIG_NO_SUCH_DEVICE dev is null
+ *      - RMNET_CONFIG_INVALID_REQUEST if the device to be associated is a vnd
+ *      - RMNET_CONFIG_DEVICE_IN_USE if dev rx_handler is already filled
+ *      - RMNET_CONFIG_DEVICE_IN_USE if netdev_rx_handler_register() fails
+ */
+int rmnet_associate_network_device(struct net_device *dev)
+{
+	struct rmnet_phys_ep_conf_s *config;
+	int rc;
+
+	ASSERT_RTNL();
+
+	LOGL("(%s);\n", dev->name);
+
+	if (!dev)
+		return RMNET_CONFIG_NO_SUCH_DEVICE;
+
+	if (_rmnet_is_physical_endpoint_associated(dev)) {
+		LOGM("%s is already regestered", dev->name);
+		return RMNET_CONFIG_DEVICE_IN_USE;
+	}
+
+	if (rmnet_vnd_is_vnd(dev)) {
+		LOGM("%s is a vnd", dev->name);
+		return RMNET_CONFIG_INVALID_REQUEST;
+	}
+
+	config = kmalloc(sizeof(*config), GFP_ATOMIC);
+
+	if (!config)
+		return RMNET_CONFIG_NOMEM;
+
+	memset(config, 0, sizeof(struct rmnet_phys_ep_conf_s));
+	config->dev = dev;
+
+	rc = netdev_rx_handler_register(dev, rmnet_rx_handler, config);
+
+	if (rc) {
+		LOGM("netdev_rx_handler_register returns %d", rc);
+		kfree(config);
+		return RMNET_CONFIG_DEVICE_IN_USE;
+	}
+
+	/* Explicitly hold a reference to the device */
+	dev_hold(dev);
+	trace_rmnet_associate(dev);
+	return RMNET_CONFIG_OK;
+}
+
+/* _rmnet_set_logical_endpoint_config() - Set logical endpoing config on device
+ * @dev:         Device to set endpoint configuration on
+ * @config_id:   logical endpoint id on device
+ * @epconfig:    endpoing configuration structure to set
+ *
+ * Return:
+ *      - RMNET_CONFIG_OK if successful
+ *      - RMNET_CONFIG_UNKNOWN_ERROR net_device private section is null
+ *      - RMNET_CONFIG_NO_SUCH_DEVICE if device to set config on is null
+ *      - RMNET_CONFIG_DEVICE_IN_USE if device already has a logical ep
+ *      - RMNET_CONFIG_BAD_ARGUMENTS if logical endpoint id is out of range
+ */
+int _rmnet_set_logical_endpoint_config(struct net_device *dev,
+				       int config_id,
+				       struct rmnet_logical_ep_conf_s *epconfig)
+{
+	struct rmnet_logical_ep_conf_s *epconfig_l;
+
+	ASSERT_RTNL();
+
+	if (!dev)
+		return RMNET_CONFIG_NO_SUCH_DEVICE;
+
+	if (config_id < RMNET_LOCAL_LOGICAL_ENDPOINT ||
+	    config_id >= RMNET_DATA_MAX_LOGICAL_EP)
+		return RMNET_CONFIG_BAD_ARGUMENTS;
+
+	epconfig_l = _rmnet_get_logical_ep(dev, config_id);
+
+	if (!epconfig_l)
+		return RMNET_CONFIG_UNKNOWN_ERROR;
+
+	if (epconfig_l->refcount)
+		return RMNET_CONFIG_DEVICE_IN_USE;
+
+	memcpy(epconfig_l, epconfig, sizeof(struct rmnet_logical_ep_conf_s));
+	if (config_id == RMNET_LOCAL_LOGICAL_ENDPOINT)
+		epconfig_l->mux_id = 0;
+	else
+		epconfig_l->mux_id = config_id;
+
+	/* Explicitly hold a reference to the egress device */
+	dev_hold(epconfig_l->egress_dev);
+	return RMNET_CONFIG_OK;
+}
+
+/* _rmnet_unset_logical_endpoint_config() - Un-set the logical endpoing config
+ * on device
+ * @dev:         Device to set endpoint configuration on
+ * @config_id:   logical endpoint id on device
+ *
+ * Return:
+ *      - RMNET_CONFIG_OK if successful
+ *      - RMNET_CONFIG_UNKNOWN_ERROR net_device private section is null
+ *      - RMNET_CONFIG_NO_SUCH_DEVICE if device to set config on is null
+ *      - RMNET_CONFIG_BAD_ARGUMENTS if logical endpoint id is out of range
+ */
+int _rmnet_unset_logical_endpoint_config(struct net_device *dev,
+					 int config_id)
+{
+	struct rmnet_logical_ep_conf_s *epconfig_l = 0;
+
+	ASSERT_RTNL();
+
+	if (!dev)
+		return RMNET_CONFIG_NO_SUCH_DEVICE;
+
+	if (config_id < RMNET_LOCAL_LOGICAL_ENDPOINT ||
+	    config_id >= RMNET_DATA_MAX_LOGICAL_EP)
+		return RMNET_CONFIG_BAD_ARGUMENTS;
+
+	epconfig_l = _rmnet_get_logical_ep(dev, config_id);
+
+	if (!epconfig_l || !epconfig_l->refcount)
+		return RMNET_CONFIG_NO_SUCH_DEVICE;
+
+	/* Explicitly release the reference from the egress device */
+	dev_put(epconfig_l->egress_dev);
+	memset(epconfig_l, 0, sizeof(struct rmnet_logical_ep_conf_s));
+
+	return RMNET_CONFIG_OK;
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
+ * function arguments. Calls _rmnet_set_logical_endpoint_config() to finish
+ * configuration. Network device must already have association with RmNet Data
+ * driver
+ *
+ * Return:
+ *      - RMNET_CONFIG_OK if successful
+ *      - RMNET_CONFIG_BAD_EGRESS_DEVICE if egress device is null
+ *      - RMNET_CONFIG_BAD_EGRESS_DEVICE if egress device is not handled by
+ *                                       RmNet data module
+ *      - RMNET_CONFIG_UNKNOWN_ERROR net_device private section is null
+ *      - RMNET_CONFIG_NO_SUCH_DEVICE if device to set config on is null
+ *      - RMNET_CONFIG_BAD_ARGUMENTS if logical endpoint id is out of range
+ */
+int rmnet_set_logical_endpoint_config(struct net_device *dev,
+				      int config_id,
+				      u8 rmnet_mode,
+				      struct net_device *egress_dev)
+{
+	struct rmnet_logical_ep_conf_s epconfig;
+
+	LOGL("(%s, %d, %d, %s);",
+	     dev->name, config_id, rmnet_mode, egress_dev->name);
+
+	if (!egress_dev ||
+	    ((!_rmnet_is_physical_endpoint_associated(egress_dev)) &&
+	    (!rmnet_vnd_is_vnd(egress_dev)))) {
+		return RMNET_CONFIG_BAD_EGRESS_DEVICE;
+	}
+
+	memset(&epconfig, 0, sizeof(struct rmnet_logical_ep_conf_s));
+	epconfig.refcount = 1;
+	epconfig.rmnet_mode = rmnet_mode;
+	epconfig.egress_dev = egress_dev;
+
+	return _rmnet_set_logical_endpoint_config(dev, config_id, &epconfig);
+}
+
+/* rmnet_unset_logical_endpoint_config() - Un-set logical endpoing configuration
+ * on a device
+ * @dev:            Device to set endpoint configuration on
+ * @config_id:      logical endpoint id on device
+ *
+ * Retrieves the logical_endpoint_config structure and frees the egress device.
+ * Network device must already have association with RmNet Data driver
+ *
+ * Return:
+ *      - RMNET_CONFIG_OK if successful
+ *      - RMNET_CONFIG_UNKNOWN_ERROR net_device private section is null
+ *      - RMNET_CONFIG_NO_SUCH_DEVICE device is not associated
+ *      - RMNET_CONFIG_BAD_ARGUMENTS if logical endpoint id is out of range
+ */
+int rmnet_unset_logical_endpoint_config(struct net_device *dev,
+					int config_id)
+{
+	LOGL("(%s, %d);", dev->name, config_id);
+
+	if (!dev ||
+	    ((!_rmnet_is_physical_endpoint_associated(dev)) &&
+	    (!rmnet_vnd_is_vnd(dev)))) {
+		return RMNET_CONFIG_NO_SUCH_DEVICE;
+	}
+
+	return _rmnet_unset_logical_endpoint_config(dev, config_id);
+}
+
+/* rmnet_get_logical_endpoint_config() - Gets logical endpoing configuration
+ * for a device
+ * @dev:                  Device to get endpoint configuration on
+ * @config_id:            logical endpoint id on device
+ * @rmnet_mode:           (I/O) logical endpoint mode
+ * @egress_dev_name:      (I/O) logical endpoint egress device name
+ * @egress_dev_name_size: The maximal size of the I/O egress_dev_name
+ *
+ * Retrieves the logical_endpoint_config structure.
+ * Network device must already have association with RmNet Data driver
+ *
+ * Return:
+ *      - RMNET_CONFIG_OK if successful
+ *      - RMNET_CONFIG_UNKNOWN_ERROR net_device private section is null
+ *      - RMNET_CONFIG_NO_SUCH_DEVICE device is not associated
+ *      - RMNET_CONFIG_BAD_ARGUMENTS if logical endpoint id is out of range or
+ *        if the provided buffer size for egress dev name is too short
+ */
+int rmnet_get_logical_endpoint_config(struct net_device *dev,
+				      int config_id,
+				      u8 *rmnet_mode,
+				      u8 *egress_dev_name,
+				      size_t egress_dev_name_size)
+{
+	struct rmnet_logical_ep_conf_s *epconfig_l = 0;
+	size_t strlcpy_res = 0;
+
+	LOGL("(%s, %d);", dev->name, config_id);
+
+	if (!egress_dev_name || !rmnet_mode)
+		return RMNET_CONFIG_BAD_ARGUMENTS;
+	if (config_id < RMNET_LOCAL_LOGICAL_ENDPOINT ||
+	    config_id >= RMNET_DATA_MAX_LOGICAL_EP)
+		return RMNET_CONFIG_BAD_ARGUMENTS;
+
+	epconfig_l = _rmnet_get_logical_ep(dev, config_id);
+
+	if (!epconfig_l || !epconfig_l->refcount)
+		return RMNET_CONFIG_NO_SUCH_DEVICE;
+
+	*rmnet_mode = epconfig_l->rmnet_mode;
+
+	strlcpy_res = strlcpy(egress_dev_name, epconfig_l->egress_dev->name,
+			      egress_dev_name_size);
+
+	if (strlcpy_res >= egress_dev_name_size)
+		return RMNET_CONFIG_BAD_ARGUMENTS;
+
+	return RMNET_CONFIG_OK;
+}
+
+/* rmnet_create_vnd() - Create virtual network device node
+ * @id:       RmNet virtual device node id
+ *
+ * Return:
+ *      - result of rmnet_vnd_create_dev()
+ */
+int rmnet_create_vnd(int id)
+{
+	struct net_device *dev;
+
+	ASSERT_RTNL();
+	LOGL("(%d);", id);
+	return rmnet_vnd_create_dev(id, &dev, NULL);
+}
+
+/* rmnet_create_vnd() - Create virtual network device node
+ * @id:       RmNet virtual device node id
+ * @prefix:   String prefix for device name
+ *
+ * Return:
+ *      - result of rmnet_vnd_create_dev()
+ */
+int rmnet_create_vnd_prefix(int id, const char *prefix)
+{
+	struct net_device *dev;
+
+	ASSERT_RTNL();
+	LOGL("(%d, \"%s\");", id, prefix);
+	return rmnet_vnd_create_dev(id, &dev, prefix);
+}
+
+/* rmnet_free_vnd() - Free virtual network device node
+ * @id:       RmNet virtual device node id
+ *
+ * Return:
+ *      - result of rmnet_vnd_free_dev()
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
+ *
+ * Return:
+ *      - void
+ */
+static void rmnet_force_unassociate_device(struct net_device *dev)
+{
+	int i, j;
+	struct net_device *vndev;
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
+	trace_rmnet_unregister_cb_clear_vnds(dev);
+	vnd_work = kmalloc(sizeof(*vnd_work), GFP_KERNEL);
+	if (!vnd_work) {
+		LOGH("%s", "Out of Memory");
+		return;
+	}
+	INIT_WORK(&vnd_work->work, _rmnet_free_vnd_later);
+	vnd_work->count = 0;
+
+	/* Check the VNDs for offending mappings */
+	for (i = 0, j = 0; i < RMNET_DATA_MAX_VND &&
+	     j < RMNET_DATA_MAX_VND; i++) {
+		vndev = rmnet_vnd_get_by_id(i);
+		if (!vndev) {
+			LOGL("VND %d not in use; skipping", i);
+			continue;
+		}
+		cfg = rmnet_vnd_get_le_config(vndev);
+		if (!cfg) {
+			LOGH("Got NULL config from VND %d", i);
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
+	/* Clear the mappings on the phys ep */
+	trace_rmnet_unregister_cb_clear_lepcs(dev);
+	rmnet_unset_logical_endpoint_config(dev, RMNET_LOCAL_LOGICAL_ENDPOINT);
+	for (i = 0; i < RMNET_DATA_MAX_LOGICAL_EP; i++)
+		rmnet_unset_logical_endpoint_config(dev, i);
+	rmnet_unassociate_network_device(dev);
+}
+
+/* rmnet_config_notify_cb() - Callback for netdevice notifier chain
+ * @nb:       Notifier block data
+ * @event:    Netdevice notifier event ID
+ * @data:     Contains a net device for which we are getting notified
+ *
+ * Return:
+ *      - result of NOTIFY_DONE()
+ */
+int rmnet_config_notify_cb(struct notifier_block *nb,
+			   unsigned long event, void *data)
+{
+	struct net_device *dev = netdev_notifier_info_to_dev(data);
+
+	if (!dev)
+		return NOTIFY_DONE;
+
+	switch (event) {
+	case NETDEV_UNREGISTER_FINAL:
+	case NETDEV_UNREGISTER:
+		trace_rmnet_unregister_cb_entry(dev);
+		LOGH("Kernel is trying to unregister %s", dev->name);
+		rmnet_force_unassociate_device(dev);
+		trace_rmnet_unregister_cb_exit(dev);
+		break;
+
+	default:
+		trace_rmnet_unregister_cb_unhandled(dev);
+		LOGD("Unhandeled event [%lu]", event);
+		break;
+	}
+
+	return NOTIFY_DONE;
+}
diff --git a/net/rmnet_data/rmnet_data_config.h b/net/rmnet_data/rmnet_data_config.h
new file mode 100644
index 0000000..f9da3c6
--- /dev/null
+++ b/net/rmnet_data/rmnet_data_config.h
@@ -0,0 +1,107 @@
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
+#ifndef _RMNET_DATA_CONFIG_H_
+#define _RMNET_DATA_CONFIG_H_
+
+#define RMNET_DATA_MAX_LOGICAL_EP 256
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
+ * with rmnet_data.
+ *
+ * @dev: The device which is associated with rmnet_data. Corresponds to this
+ *       specific instance of rmnet_phys_ep_conf_s
+ * @local_ep: Default non-muxed endpoint. Used for non-MAP protocols/formats
+ * @muxed_ep: All multiplexed logical endpoints associated with this device
+ * @ingress_data_format: RMNET_INGRESS_FORMAT_* flags from rmnet_data.h
+ * @egress_data_format: RMNET_EGRESS_FORMAT_* flags from rmnet_data.h
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
+	struct rmnet_logical_ep_conf_s muxed_ep[RMNET_DATA_MAX_LOGICAL_EP];
+	u32 ingress_data_format;
+	u32 egress_data_format;
+};
+
+int rmnet_config_init(void);
+void rmnet_config_exit(void);
+
+int rmnet_unassociate_network_device(struct net_device *dev);
+int rmnet_set_ingress_data_format(struct net_device *dev,
+				  u32 ingress_data_format);
+int rmnet_set_egress_data_format(struct net_device *dev,
+				 u32 egress_data_format,
+				 u16 agg_size,
+				 u16 agg_count);
+int rmnet_associate_network_device(struct net_device *dev);
+int _rmnet_set_logical_endpoint_config(struct net_device *dev,
+				       int config_id,
+				      struct rmnet_logical_ep_conf_s *epconfig);
+int rmnet_set_logical_endpoint_config(struct net_device *dev,
+				      int config_id,
+				      u8 rmnet_mode,
+				      struct net_device *egress_dev);
+int _rmnet_unset_logical_endpoint_config(struct net_device *dev,
+					 int config_id);
+int rmnet_unset_logical_endpoint_config(struct net_device *dev,
+					int config_id);
+int _rmnet_get_logical_endpoint_config(struct net_device *dev,
+				       int config_id,
+				      struct rmnet_logical_ep_conf_s *epconfig);
+int rmnet_get_logical_endpoint_config(struct net_device *dev,
+				      int config_id,
+				      u8 *rmnet_mode,
+				      u8 *egress_dev_name,
+				      size_t egress_dev_name_size);
+void rmnet_config_netlink_msg_handler (struct sk_buff *skb);
+int rmnet_config_notify_cb(struct notifier_block *nb,
+			   unsigned long event, void *data);
+int rmnet_create_vnd(int id);
+int rmnet_create_vnd_prefix(int id, const char *name);
+int rmnet_free_vnd(int id);
+
+#endif /* _RMNET_DATA_CONFIG_H_ */
diff --git a/net/rmnet_data/rmnet_data_handlers.c b/net/rmnet_data/rmnet_data_handlers.c
new file mode 100644
index 0000000..e95d1ef
--- /dev/null
+++ b/net/rmnet_data/rmnet_data_handlers.c
@@ -0,0 +1,556 @@
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
+#include <linux/rmnet_data.h>
+#include <linux/netdev_features.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include "rmnet_data_private.h"
+#include "rmnet_data_config.h"
+#include "rmnet_data_vnd.h"
+#include "rmnet_map.h"
+#include "rmnet_data_stats.h"
+#include "rmnet_data_trace.h"
+#include "rmnet_data_handlers.h"
+
+RMNET_LOG_MODULE(RMNET_DATA_LOGMASK_HANDLER);
+
+#ifdef CONFIG_RMNET_DATA_DEBUG
+unsigned int dump_pkt_rx;
+module_param(dump_pkt_rx, uint, 0644);
+MODULE_PARM_DESC(dump_pkt_rx, "Dump packets entering ingress handler");
+
+unsigned int dump_pkt_tx;
+module_param(dump_pkt_tx, uint, 0644);
+MODULE_PARM_DESC(dump_pkt_tx, "Dump packets exiting egress handler");
+#endif /* CONFIG_RMNET_DATA_DEBUG */
+
+#define RMNET_DATA_IP_VERSION_4 0x40
+#define RMNET_DATA_IP_VERSION_6 0x60
+
+/* Helper Functions */
+
+/* __rmnet_data_set_skb_proto() - Set skb->protocol field
+ * @skb:      packet being modified
+ *
+ * Peek at the first byte of the packet and set the protocol. There is not
+ * good way to determine if a packet has a MAP header. As of writing this,
+ * the reserved bit in the MAP frame will prevent it from overlapping with
+ * IPv4/IPv6 frames. This could change in the future!
+ */
+static inline void __rmnet_data_set_skb_proto(struct sk_buff *skb)
+{
+	switch (skb->data[0] & 0xF0) {
+	case RMNET_DATA_IP_VERSION_4:
+		skb->protocol = htons(ETH_P_IP);
+		break;
+	case RMNET_DATA_IP_VERSION_6:
+		skb->protocol = htons(ETH_P_IPV6);
+		break;
+	default:
+		skb->protocol = htons(ETH_P_MAP);
+		break;
+	}
+}
+
+#ifdef CONFIG_RMNET_DATA_DEBUG
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
+#endif /* CONFIG_RMNET_DATA_DEBUG */
+
+/* Generic handler */
+
+/* rmnet_bridge_handler() - Bridge related functionality
+ *
+ * Return:
+ *      - RX_HANDLER_CONSUMED in all cases
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
+ *
+ * Return:
+ *      - RX_HANDLER_CONSUMED if packet forwarded or dropped
+ *      - RX_HANDLER_PASS if packet is to be consumed by network stack as-is
+ */
+static rx_handler_result_t __rmnet_deliver_skb
+	(struct sk_buff *skb, struct rmnet_logical_ep_conf_s *ep)
+{
+	trace___rmnet_deliver_skb(skb);
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
+ *
+ * Return:
+ *      - RX_HANDLER_CONSUMED if packet forwarded/dropped
+ *      - RX_HANDLER_PASS if packet should be passed up the stack by caller
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
+ *
+ * Return:
+ *      - RX_HANDLER_CONSUMED if packet is dropped
+ *      - result of __rmnet_deliver_skb() for all other cases
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
+	if (mux_id >= RMNET_DATA_MAX_LOGICAL_EP) {
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
+	__rmnet_data_set_skb_proto(skb);
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
+ *
+ * Return:
+ *      - RX_HANDLER_CONSUMED for aggregated packets
+ *      - RX_HANDLER_CONSUMED for dropped packets
+ *      - result of _rmnet_map_ingress_handler() for all other cases
+ */
+static rx_handler_result_t rmnet_map_ingress_handler
+	(struct sk_buff *skb, struct rmnet_phys_ep_conf_s *config)
+{
+	struct sk_buff *skbn;
+	int rc, co = 0;
+
+	if (config->ingress_data_format & RMNET_INGRESS_FORMAT_DEAGGREGATION) {
+		trace_rmnet_start_deaggregation(skb);
+		while ((skbn = rmnet_map_deaggregate(skb, config)) != NULL) {
+			_rmnet_map_ingress_handler(skbn, config);
+			co++;
+		}
+		trace_rmnet_end_deaggregation(skb, co);
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
+ *
+ * Return:
+ *      - 0 on success
+ *      - 1 on failure
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
+
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
+ *
+ * Return:
+ *      - RX_HANDLER_PASS if packet is not processed by handler (caller must
+ *        deal with the packet)
+ *      - RX_HANDLER_CONSUMED if packet is forwarded or processed by MAP
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
+	trace_rmnet_ingress_handler(skb);
+	rmnet_print_packet(skb, dev->name, 'r');
+
+	config = (struct rmnet_phys_ep_conf_s *)
+		rcu_dereference(skb->dev->rx_handler_data);
+
+	if (!config) {
+		LOGD("%s is not associated with rmnet_data", skb->dev->name);
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
+		__rmnet_data_set_skb_proto(skb);
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
+ *
+ * Return:
+ *      - Whatever rmnet_ingress_handler() returns
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
+		LOGD("%s is not associated with rmnet_data", skb->dev->name);
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
+	trace_rmnet_egress_handler(skb);
+	rc = dev_queue_xmit(skb);
+	if (rc != 0) {
+		LOGD("Failed to queue packet for transmission on [%s]",
+		     skb->dev->name);
+	}
+	rmnet_stats_queue_xmit(rc, RMNET_STATS_QUEUE_XMIT_EGRESS);
+}
diff --git a/net/rmnet_data/rmnet_data_handlers.h b/net/rmnet_data/rmnet_data_handlers.h
new file mode 100644
index 0000000..85a590c
--- /dev/null
+++ b/net/rmnet_data/rmnet_data_handlers.h
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
+#ifndef _RMNET_DATA_HANDLERS_H_
+#define _RMNET_DATA_HANDLERS_H_
+
+void rmnet_egress_handler(struct sk_buff *skb,
+			  struct rmnet_logical_ep_conf_s *ep);
+
+rx_handler_result_t rmnet_rx_handler(struct sk_buff **pskb);
+
+#endif /* _RMNET_DATA_HANDLERS_H_ */
diff --git a/net/rmnet_data/rmnet_data_main.c b/net/rmnet_data/rmnet_data_main.c
new file mode 100644
index 0000000..f0e1ec6
--- /dev/null
+++ b/net/rmnet_data/rmnet_data_main.c
@@ -0,0 +1,60 @@
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
+#include "rmnet_data_private.h"
+#include "rmnet_data_config.h"
+#include "rmnet_data_vnd.h"
+
+/* Trace Points */
+#define CREATE_TRACE_POINTS
+#include "rmnet_data_trace.h"
+
+/* Module Parameters */
+unsigned int rmnet_data_log_level = RMNET_LOG_LVL_ERR | RMNET_LOG_LVL_HI;
+module_param(rmnet_data_log_level, uint, 0644);
+MODULE_PARM_DESC(log_level, "Logging level");
+
+unsigned int rmnet_data_log_module_mask;
+module_param(rmnet_data_log_module_mask, uint, 0644);
+MODULE_PARM_DESC(rmnet_data_log_module_mask, "Logging module mask");
+
+/* Startup/Shutdown */
+
+/* rmnet_init() - Module initialization
+ *
+ * todo: check for (and init) startup errors
+ */
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
diff --git a/net/rmnet_data/rmnet_data_private.h b/net/rmnet_data/rmnet_data_private.h
new file mode 100644
index 0000000..1dfddc1
--- /dev/null
+++ b/net/rmnet_data/rmnet_data_private.h
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
+#ifndef _RMNET_DATA_PRIVATE_H_
+#define _RMNET_DATA_PRIVATE_H_
+
+#define RMNET_DATA_MAX_VND              32
+#define RMNET_DATA_MAX_PACKET_SIZE      16384
+#define RMNET_DATA_DFLT_PACKET_SIZE     1500
+#define RMNET_DATA_DEV_NAME_STR         "rmnet_data"
+#define RMNET_DATA_NEEDED_HEADROOM      16
+#define RMNET_DATA_TX_QUEUE_LEN         1000
+#define RMNET_ETHERNET_HEADER_LENGTH    14
+
+extern unsigned int rmnet_data_log_level;
+extern unsigned int rmnet_data_log_module_mask;
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
+#define RMNET_DATA_LOGMASK_CONFIG  BIT(0)
+#define RMNET_DATA_LOGMASK_HANDLER BIT(1)
+#define RMNET_DATA_LOGMASK_VND     BIT(2)
+#define RMNET_DATA_LOGMASK_MAPD    BIT(3)
+#define RMNET_DATA_LOGMASK_MAPC    BIT(4)
+
+#define LOGE(fmt, ...) do { if (rmnet_data_log_level & RMNET_LOG_LVL_ERR) \
+			pr_err("[RMNET:ERR] %s(): " fmt "\n", __func__, \
+				##__VA_ARGS__); \
+			} while (0)
+
+#define LOGH(fmt, ...) do { if (rmnet_data_log_level & RMNET_LOG_LVL_HI) \
+			pr_err("[RMNET:HI] %s(): " fmt "\n", __func__, \
+				##__VA_ARGS__); \
+			} while (0)
+
+#define LOGM(fmt, ...) do { if (rmnet_data_log_level & RMNET_LOG_LVL_MED) \
+			pr_warn("[RMNET:MED] %s(): " fmt "\n", __func__, \
+				##__VA_ARGS__); \
+			} while (0)
+
+#define LOGL(fmt, ...) do { if (unlikely \
+			(rmnet_data_log_level & RMNET_LOG_LVL_LOW)) \
+			pr_notice("[RMNET:LOW] %s(): " fmt "\n", __func__, \
+				##__VA_ARGS__); \
+			} while (0)
+
+/* Don't use pr_debug as it is compiled out of the kernel. We can be sure of
+ * minimal impact as LOGD is not enabled by default.
+ */
+#define LOGD(fmt, ...) do { if (unlikely( \
+			    (rmnet_data_log_level & RMNET_LOG_LVL_DBG) &&\
+			    (rmnet_data_log_module_mask & rmnet_mod_mask))) \
+			pr_notice("[RMNET:DBG] %s(): " fmt "\n", __func__, \
+				  ##__VA_ARGS__); \
+			} while (0)
+
+#endif /* _RMNET_DATA_PRIVATE_H_ */
diff --git a/net/rmnet_data/rmnet_data_stats.c b/net/rmnet_data/rmnet_data_stats.c
new file mode 100644
index 0000000..4bf7a72
--- /dev/null
+++ b/net/rmnet_data/rmnet_data_stats.c
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
+#include "rmnet_data_private.h"
+#include "rmnet_data_stats.h"
+#include "rmnet_data_config.h"
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
diff --git a/net/rmnet_data/rmnet_data_stats.h b/net/rmnet_data/rmnet_data_stats.h
new file mode 100644
index 0000000..a6f73a2
--- /dev/null
+++ b/net/rmnet_data/rmnet_data_stats.h
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
+#ifndef _RMNET_DATA_STATS_H_
+#define _RMNET_DATA_STATS_H_
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
+#endif /* _RMNET_DATA_STATS_H_ */
diff --git a/net/rmnet_data/rmnet_data_trace.h b/net/rmnet_data/rmnet_data_trace.h
new file mode 100644
index 0000000..264ff61
--- /dev/null
+++ b/net/rmnet_data/rmnet_data_trace.h
@@ -0,0 +1,198 @@
+/* Copyright (c) 2014-2017, The Linux Foundation. All rights reserved.
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
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM rmnet_data
+#define TRACE_INCLUDE_FILE rmnet_data_trace
+
+#if !defined(_RMNET_DATA_TRACE_H_) || defined(TRACE_HEADER_MULTI_READ)
+#define _RMNET_DATA_TRACE_H_
+
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <linux/tracepoint.h>
+
+DECLARE_EVENT_CLASS
+	(rmnet_handler_template,
+
+	TP_PROTO(struct sk_buff *skb),
+
+	TP_ARGS(skb),
+
+	TP_STRUCT__entry(
+		__field(void *, skbaddr)
+		__field(unsigned int, len)
+		__string(name, skb->dev->name)
+	),
+
+	TP_fast_assign(
+		__entry->skbaddr = skb;
+		__entry->len = skb->len;
+		__assign_str(name, skb->dev->name);
+	),
+
+	TP_printk("dev=%s skbaddr=%pK len=%u",
+		  __get_str(name), __entry->skbaddr, __entry->len)
+)
+
+DEFINE_EVENT
+	(rmnet_handler_template, rmnet_egress_handler,
+
+	TP_PROTO(struct sk_buff *skb),
+
+	TP_ARGS(skb)
+);
+
+DEFINE_EVENT
+	(rmnet_handler_template, rmnet_ingress_handler,
+
+	TP_PROTO(struct sk_buff *skb),
+
+	TP_ARGS(skb)
+);
+
+DEFINE_EVENT
+	(rmnet_handler_template, rmnet_vnd_start_xmit,
+
+	TP_PROTO(struct sk_buff *skb),
+
+	TP_ARGS(skb)
+);
+
+DEFINE_EVENT
+	(rmnet_handler_template, __rmnet_deliver_skb,
+
+	TP_PROTO(struct sk_buff *skb),
+
+	TP_ARGS(skb)
+);
+
+TRACE_EVENT
+	(rmnet_start_deaggregation,
+
+	TP_PROTO(struct sk_buff *skb),
+
+	TP_ARGS(skb),
+
+	TP_STRUCT__entry(
+		__string(name, skb->dev->name)
+	),
+
+	TP_fast_assign(
+		__assign_str(name, skb->dev->name);
+	),
+
+	TP_printk("dev: %s, deaggregated first packet", __get_str(name))
+)
+
+TRACE_EVENT
+	(rmnet_end_deaggregation,
+
+	TP_PROTO(struct sk_buff *skb, int num_deagg_packets),
+
+	TP_ARGS(skb, num_deagg_packets),
+
+	TP_STRUCT__entry(
+		__string(name, skb->dev->name)
+		__field(int, num)
+	),
+
+	TP_fast_assign(
+		__assign_str(name, skb->dev->name);
+		__entry->num = num_deagg_packets;
+	),
+
+	TP_printk("dev: %s, deaggregate end count: %d",
+		  __get_str(name), __entry->num)
+)
+
+DECLARE_EVENT_CLASS
+	(rmnet_physdev_action_template,
+
+	TP_PROTO(struct net_device *dev),
+
+	TP_ARGS(dev),
+
+	TP_STRUCT__entry(
+		__string(name, dev->name)
+	),
+
+	TP_fast_assign(
+		__assign_str(name, dev->name);
+	),
+
+	TP_printk("Physical dev=%s", __get_str(name))
+)
+
+DEFINE_EVENT
+	(rmnet_physdev_action_template, rmnet_unregister_cb_unhandled,
+
+	TP_PROTO(struct net_device *dev),
+
+	TP_ARGS(dev)
+);
+
+DEFINE_EVENT
+	(rmnet_physdev_action_template, rmnet_unregister_cb_entry,
+
+	TP_PROTO(struct net_device *dev),
+
+	TP_ARGS(dev)
+);
+
+DEFINE_EVENT
+	(rmnet_physdev_action_template, rmnet_unregister_cb_exit,
+
+	TP_PROTO(struct net_device *dev),
+
+	TP_ARGS(dev)
+);
+
+DEFINE_EVENT
+	(rmnet_physdev_action_template, rmnet_unregister_cb_clear_vnds,
+
+	TP_PROTO(struct net_device *dev),
+
+	TP_ARGS(dev)
+);
+
+DEFINE_EVENT
+	(rmnet_physdev_action_template, rmnet_unregister_cb_clear_lepcs,
+
+	TP_PROTO(struct net_device *dev),
+
+	TP_ARGS(dev)
+);
+
+DEFINE_EVENT
+	(rmnet_physdev_action_template, rmnet_associate,
+
+	TP_PROTO(struct net_device *dev),
+
+	TP_ARGS(dev)
+);
+
+DEFINE_EVENT
+	(rmnet_physdev_action_template, rmnet_unassociate,
+
+	TP_PROTO(struct net_device *dev),
+
+	TP_ARGS(dev)
+);
+
+#endif /* _RMNET_DATA_TRACE_H_ */
+
+/* This part must be outside protection */
+#undef TRACE_INCLUDE_PATH
+#define TRACE_INCLUDE_PATH .
+#include <trace/define_trace.h>
+
diff --git a/net/rmnet_data/rmnet_data_vnd.c b/net/rmnet_data/rmnet_data_vnd.c
new file mode 100644
index 0000000..d48dc23
--- /dev/null
+++ b/net/rmnet_data/rmnet_data_vnd.c
@@ -0,0 +1,460 @@
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
+#include <linux/rmnet_data.h>
+#include <linux/etherdevice.h>
+#include <linux/if_arp.h>
+#include <linux/spinlock.h>
+#include <net/pkt_sched.h>
+#include <linux/atomic.h>
+#include "rmnet_data_config.h"
+#include "rmnet_data_handlers.h"
+#include "rmnet_data_private.h"
+#include "rmnet_map.h"
+#include "rmnet_data_vnd.h"
+#include "rmnet_data_stats.h"
+#include "rmnet_data_trace.h"
+
+RMNET_LOG_MODULE(RMNET_DATA_LOGMASK_VND);
+
+struct net_device *rmnet_devices[RMNET_DATA_MAX_VND];
+
+struct rmnet_vnd_private_s {
+	struct rmnet_logical_ep_conf_s local_ep;
+};
+
+/* RX/TX Fixup */
+
+/* rmnet_vnd_rx_fixup() - Virtual Network Device receive fixup hook
+ * @skb:        Socket buffer ("packet") to modify
+ * @dev:        Virtual network device
+ *
+ * Additional VND specific packet processing for ingress packets
+ *
+ * Return:
+ *      - RX_HANDLER_PASS if packet should continue to process in stack
+ *      - RX_HANDLER_CONSUMED if packet should not be processed in stack
+ *
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
+ *
+ * Return:
+ *      - RX_HANDLER_PASS if packet should continue to be transmitted
+ *      - RX_HANDLER_CONSUMED if packet should not be transmitted by stack
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
+ *
+ * Return:
+ *      - NETDEV_TX_OK under all cirumstances (cannot block/fail)
+ */
+static netdev_tx_t rmnet_vnd_start_xmit(struct sk_buff *skb,
+					struct net_device *dev)
+{
+	struct rmnet_vnd_private_s *dev_conf;
+
+	trace_rmnet_vnd_start_xmit(skb);
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
+ * RMNET_DATA_MAX_PACKET_SIZE;
+ *
+ * Return:
+ *      - 0 if successful
+ *      - -EINVAL if new_mtu is out of range
+ */
+static int rmnet_vnd_change_mtu(struct net_device *dev, int new_mtu)
+{
+	if (new_mtu < 0 || new_mtu > RMNET_DATA_MAX_PACKET_SIZE)
+		return -EINVAL;
+
+	dev->mtu = new_mtu;
+	return 0;
+}
+
+static const struct net_device_ops rmnet_data_vnd_ops = {
+	.ndo_init = 0,
+	.ndo_start_xmit = rmnet_vnd_start_xmit,
+	.ndo_change_mtu = rmnet_vnd_change_mtu,
+	.ndo_set_mac_address = 0,
+	.ndo_validate_addr = 0,
+};
+
+/* rmnet_vnd_setup() - net_device initialization callback
+ * @dev:      Virtual network device
+ *
+ * Called by kernel whenever a new rmnet_data<n> device is created. Sets MTU,
+ * flags, ARP type, needed headroom, etc...
+ */
+static void rmnet_vnd_setup(struct net_device *dev)
+{
+	struct rmnet_vnd_private_s *dev_conf;
+
+	LOGM("Setting up device %s", dev->name);
+
+	/* Clear out private data */
+	dev_conf = (struct rmnet_vnd_private_s *)netdev_priv(dev);
+	memset(dev_conf, 0, sizeof(struct rmnet_vnd_private_s));
+
+	dev->netdev_ops = &rmnet_data_vnd_ops;
+	dev->mtu = RMNET_DATA_DFLT_PACKET_SIZE;
+	dev->needed_headroom = RMNET_DATA_NEEDED_HEADROOM;
+	random_ether_addr(dev->dev_addr);
+	dev->tx_queue_len = RMNET_DATA_TX_QUEUE_LEN;
+
+	/* Raw IP mode */
+	dev->header_ops = 0;  /* No header */
+	dev->type = ARPHRD_RAWIP;
+	dev->hard_header_len = 0;
+	dev->flags &= ~(IFF_BROADCAST | IFF_MULTICAST);
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
+	for (i = 0; i < RMNET_DATA_MAX_VND; i++)
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
+	memset(rmnet_devices, 0,
+	       sizeof(struct net_device *) * RMNET_DATA_MAX_VND);
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
+ * RMNET_DATA_DEV_NAME_STR will be assumed.
+ *
+ * Return:
+ *      - 0 if successful
+ *      - RMNET_CONFIG_BAD_ARGUMENTS if id is out of range or prefix is too long
+ *      - RMNET_CONFIG_DEVICE_IN_USE if id already in use
+ *      - RMNET_CONFIG_NOMEM if net_device allocation failed
+ *      - RMNET_CONFIG_UNKNOWN_ERROR if register_netdevice() fails
+ */
+int rmnet_vnd_create_dev(int id, struct net_device **new_device,
+			 const char *prefix)
+{
+	struct net_device *dev;
+	char dev_prefix[IFNAMSIZ];
+	int p, rc = 0;
+
+	if (id < 0 || id >= RMNET_DATA_MAX_VND) {
+		*new_device = 0;
+		return RMNET_CONFIG_BAD_ARGUMENTS;
+	}
+
+	if (rmnet_devices[id]) {
+		*new_device = 0;
+		return RMNET_CONFIG_DEVICE_IN_USE;
+	}
+
+	if (!prefix)
+		p = scnprintf(dev_prefix, IFNAMSIZ, "%s%%d",
+			      RMNET_DATA_DEV_NAME_STR);
+	else
+		p = scnprintf(dev_prefix, IFNAMSIZ, "%s%%d", prefix);
+	if (p >= (IFNAMSIZ - 1)) {
+		LOGE("Specified prefix longer than IFNAMSIZ");
+		return RMNET_CONFIG_BAD_ARGUMENTS;
+	}
+
+	dev = alloc_netdev(sizeof(struct rmnet_vnd_private_s),
+			   dev_prefix,
+			   NET_NAME_ENUM,
+			   rmnet_vnd_setup);
+	if (!dev) {
+		LOGE("Failed to to allocate netdev for id %d", id);
+		*new_device = 0;
+		return RMNET_CONFIG_NOMEM;
+	}
+
+	rc = register_netdevice(dev);
+	if (rc != 0) {
+		LOGE("Failed to to register netdev [%s]", dev->name);
+		free_netdev(dev);
+		*new_device = 0;
+		rc = RMNET_CONFIG_UNKNOWN_ERROR;
+	} else {
+		rmnet_devices[id] = dev;
+		*new_device = dev;
+		LOGM("Registered device %s", dev->name);
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
+ *
+ * Return:
+ *      - 0 if successful
+ *      - RMNET_CONFIG_NO_SUCH_DEVICE if id is invalid or not in range
+ *      - RMNET_CONFIG_DEVICE_IN_USE if device has logical ep that wasn't unset
+ */
+int rmnet_vnd_free_dev(int id)
+{
+	struct rmnet_logical_ep_conf_s *epconfig_l;
+	struct net_device *dev;
+
+	rtnl_lock();
+	if ((id < 0) || (id >= RMNET_DATA_MAX_VND) || !rmnet_devices[id]) {
+		rtnl_unlock();
+		LOGM("Invalid id [%d]", id);
+		return RMNET_CONFIG_NO_SUCH_DEVICE;
+	}
+
+	epconfig_l = rmnet_vnd_get_le_config(rmnet_devices[id]);
+	if (epconfig_l && epconfig_l->refcount) {
+		rtnl_unlock();
+		return RMNET_CONFIG_DEVICE_IN_USE;
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
+		return RMNET_CONFIG_NO_SUCH_DEVICE;
+	}
+}
+
+/* rmnet_vnd_get_name() - Gets the string name of a VND based on ID
+ * @id:         Virtual device node id
+ * @name:       Buffer to store name of virtual device node
+ * @name_len:   Length of name buffer
+ *
+ * Copies the name of the virtual device node into the users buffer. Will throw
+ * an error if the buffer is null, or too small to hold the device name.
+ *
+ * Return:
+ *      - 0 if successful
+ *      - -EINVAL if name is null
+ *      - -EINVAL if id is invalid or not in range
+ *      - -EINVAL if name is too small to hold things
+ */
+int rmnet_vnd_get_name(int id, char *name, int name_len)
+{
+	int p;
+
+	if (!name) {
+		LOGM("%s", "Bad arguments; name buffer null");
+		return -EINVAL;
+	}
+
+	if ((id < 0) || (id >= RMNET_DATA_MAX_VND) || !rmnet_devices[id]) {
+		LOGM("Invalid id [%d]", id);
+		return -EINVAL;
+	}
+
+	p = strlcpy(name, rmnet_devices[id]->name, name_len);
+	if (p >= name_len) {
+		LOGM("Buffer to small (%d) to fit device name", name_len);
+		return -EINVAL;
+	}
+	LOGL("Found mapping [%d]->\"%s\"", id, name);
+
+	return 0;
+}
+
+/* rmnet_vnd_is_vnd() - Determine if net_device is RmNet owned virtual devices
+ * @dev:        Network device to test
+ *
+ * Searches through list of known RmNet virtual devices. This function is O(n)
+ * and should not be used in the data path.
+ *
+ * Return:
+ *      - 0 if device is not RmNet virtual device
+ *      - 1 if device is RmNet virtual device
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
+	for (i = 0; i < RMNET_DATA_MAX_VND; i++)
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
+ *
+ * Return:
+ *      - Pointer to logical endpoint configuration structure
+ *      - 0 (null) if dev is null
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
+ *
+ * Return:
+ *      - 0 if successful
+ *      - 1 if no mapping is found
+ *      - 2 if dev is not RmNet virtual network device node
+ */
+int rmnet_vnd_do_flow_control(struct net_device *dev, int enable)
+{
+	struct rmnet_vnd_private_s *dev_conf;
+
+	if (unlikely(!dev))
+		return 2;
+
+	if (!rmnet_vnd_is_vnd(dev))
+		return 2;
+
+	dev_conf = (struct rmnet_vnd_private_s *)netdev_priv(dev);
+
+	if (unlikely(!dev_conf))
+		return 2;
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
+ * @id: Virtual network deice id [0:RMNET_DATA_MAX_VND]
+ *
+ * Return:
+ *      - 0 if no device or ID out of range
+ *      - otherwise return pointer to VND net_device struct
+ */
+struct net_device *rmnet_vnd_get_by_id(int id)
+{
+	if (id < 0 || id >= RMNET_DATA_MAX_VND) {
+		pr_err("Bug; VND ID out of bounds");
+		return 0;
+	}
+	return rmnet_devices[id];
+}
diff --git a/net/rmnet_data/rmnet_data_vnd.h b/net/rmnet_data/rmnet_data_vnd.h
new file mode 100644
index 0000000..2903ffe
--- /dev/null
+++ b/net/rmnet_data/rmnet_data_vnd.h
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
+#ifndef _RMNET_DATA_VND_H_
+#define _RMNET_DATA_VND_H_
+
+int rmnet_vnd_do_flow_control(struct net_device *dev, int enable);
+struct rmnet_logical_ep_conf_s *rmnet_vnd_get_le_config(struct net_device *dev);
+int rmnet_vnd_get_name(int id, char *name, int name_len);
+int rmnet_vnd_create_dev(int id, struct net_device **new_device,
+			 const char *prefix);
+int rmnet_vnd_free_dev(int id);
+int rmnet_vnd_rx_fixup(struct sk_buff *skb, struct net_device *dev);
+int rmnet_vnd_tx_fixup(struct sk_buff *skb, struct net_device *dev);
+int rmnet_vnd_is_vnd(struct net_device *dev);
+int rmnet_vnd_init(void);
+void rmnet_vnd_exit(void);
+struct net_device *rmnet_vnd_get_by_id(int id);
+
+#endif /* _RMNET_DATA_VND_H_ */
diff --git a/net/rmnet_data/rmnet_map.h b/net/rmnet_data/rmnet_map.h
new file mode 100644
index 0000000..7d533aa
--- /dev/null
+++ b/net/rmnet_data/rmnet_map.h
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
diff --git a/net/rmnet_data/rmnet_map_command.c b/net/rmnet_data/rmnet_map_command.c
new file mode 100644
index 0000000..acb0b11
--- /dev/null
+++ b/net/rmnet_data/rmnet_map_command.c
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
+#include <linux/rmnet_data.h>
+#include <net/pkt_sched.h>
+#include "rmnet_data_config.h"
+#include "rmnet_map.h"
+#include "rmnet_data_private.h"
+#include "rmnet_data_vnd.h"
+#include "rmnet_data_stats.h"
+
+RMNET_LOG_MODULE(RMNET_DATA_LOGMASK_MAPC);
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
+	if (mux_id >= RMNET_DATA_MAX_LOGICAL_EP) {
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
diff --git a/net/rmnet_data/rmnet_map_data.c b/net/rmnet_data/rmnet_map_data.c
new file mode 100644
index 0000000..33bde72
--- /dev/null
+++ b/net/rmnet_data/rmnet_map_data.c
@@ -0,0 +1,148 @@
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
+#include <linux/rmnet_data.h>
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
+#include "rmnet_data_config.h"
+#include "rmnet_map.h"
+#include "rmnet_data_private.h"
+#include "rmnet_data_stats.h"
+#include "rmnet_data_trace.h"
+
+RMNET_LOG_MODULE(RMNET_DATA_LOGMASK_MAPD);
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
+ *
+ * todo: Parameterize skb alignment
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
-- 
1.9.1
