From: Amir Levy <amir.jer.levy@intel.com>
Subject: [PATCH v9 4/8] thunderbolt: Networking state machine
Date: Wed,  9 Nov 2016 16:20:04 +0200
Message-ID: <1478701208-4585-5-git-send-email-amir.jer.levy@intel.com>
References: <1478701208-4585-1-git-send-email-amir.jer.levy@intel.com>
Cc: andreas.noever@gmail.com, bhelgaas@google.com, corbet@lwn.net,
        linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org,
        netdev@vger.kernel.org, linux-doc@vger.kernel.org,
        mario_limonciello@dell.com, thunderbolt-linux@intel.com,
        mika.westerberg@intel.com, tomas.winkler@intel.com,
        xiong.y.zhang@intel.com, Amir Levy <amir.jer.levy@intel.com>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:43552 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751277AbcKIMVA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Nov 2016 07:21:00 -0500
In-Reply-To: <1478701208-4585-1-git-send-email-amir.jer.levy@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch builds the peer to peer communication path.
Communication is established by a negotiation process whereby messages are
sent back and forth between the peers until a connection is established.
This includes the Thunderbolt Network driver communication with the second
peer via Intel Connection Manager(ICM) firmware.
  +--------------------+            +--------------------+
  |Host 1              |            |Host 2              |
  |                    |            |                    |
  |     +-----------+  |            |     +-----------+  |
  |     |Thunderbolt|  |            |     |Thunderbolt|  |
  |     |Networking |  |            |     |Networking |  |
  |     |Driver     |  |            |     |Driver     |  |
  |     +-----------+  |            |     +-----------+  |
  |              ^     |            |              ^     |
  |              |     |            |              |     |
  | +------------+---+ |            | +------------+---+ |
  | |Thunderbolt |   | |            | |Thunderbolt |   | |
  | |Controller  v   | |            | |Controller  v   | |
  | |         +---+  | |            | |         +---+  | |
  | |         |ICM|<-+-+------------+-+-------->|ICM|  | |
  | |         +---+  | |            | |         +---+  | |
  | +----------------+ |            | +----------------+ |
  +--------------------+            +--------------------+
Note that this patch only establishes the link between the two hosts and
not Network Packet handling - this is dealt with in the next patch.

Signed-off-by: Amir Levy <amir.jer.levy@intel.com>
---
 drivers/thunderbolt/icm/Makefile  |   2 +-
 drivers/thunderbolt/icm/icm_nhi.c | 262 ++++++++++++-
 drivers/thunderbolt/icm/net.c     | 783 ++++++++++++++++++++++++++++++++++++++
 drivers/thunderbolt/icm/net.h     |  70 ++++
 4 files changed, 1109 insertions(+), 8 deletions(-)
 create mode 100644 drivers/thunderbolt/icm/net.c

diff --git a/drivers/thunderbolt/icm/Makefile b/drivers/thunderbolt/icm/Makefile
index f0d0fbb..94a2797 100644
--- a/drivers/thunderbolt/icm/Makefile
+++ b/drivers/thunderbolt/icm/Makefile
@@ -1,2 +1,2 @@
 obj-${CONFIG_THUNDERBOLT_ICM} += thunderbolt-icm.o
-thunderbolt-icm-objs := icm_nhi.o
+thunderbolt-icm-objs := icm_nhi.o net.o
diff --git a/drivers/thunderbolt/icm/icm_nhi.c b/drivers/thunderbolt/icm/icm_nhi.c
index c843ce8..edc910b 100644
--- a/drivers/thunderbolt/icm/icm_nhi.c
+++ b/drivers/thunderbolt/icm/icm_nhi.c
@@ -64,6 +64,13 @@ static const struct nla_policy nhi_genl_policy[NHI_ATTR_MAX + 1] = {
 					.len = TBT_ICM_RING_MAX_FRAME_SIZE },
 	[NHI_ATTR_MSG_FROM_ICM]		= { .type = NLA_BINARY,
 					.len = TBT_ICM_RING_MAX_FRAME_SIZE },
+	[NHI_ATTR_LOCAL_ROUTE_STRING]	= {
+					.len = sizeof(struct route_string) },
+	[NHI_ATTR_LOCAL_UUID]		= { .len = sizeof(uuid_be) },
+	[NHI_ATTR_REMOTE_UUID]		= { .len = sizeof(uuid_be) },
+	[NHI_ATTR_LOCAL_DEPTH]		= { .type = NLA_U8, },
+	[NHI_ATTR_ENABLE_FULL_E2E]	= { .type = NLA_FLAG, },
+	[NHI_ATTR_MATCH_FRAME_ID]	= { .type = NLA_FLAG, },
 };
 
 /* NHI genetlink family */
@@ -480,6 +487,29 @@ int nhi_mailbox(struct tbt_nhi_ctxt *nhi_ctxt, u32 cmd, u32 data, bool deinit)
 	return 0;
 }
 
+static inline bool nhi_is_path_disconnected(u32 cmd, u8 num_ports)
+{
+	return (cmd >= DISCONNECT_PORT_A_INTER_DOMAIN_PATH &&
+		cmd < (DISCONNECT_PORT_A_INTER_DOMAIN_PATH + num_ports));
+}
+
+static int nhi_mailbox_disconn_path(struct tbt_nhi_ctxt *nhi_ctxt, u32 cmd)
+	__releases(&controllers_list_mutex)
+{
+	struct port_net_dev *port;
+	u32 port_num = cmd - DISCONNECT_PORT_A_INTER_DOMAIN_PATH;
+
+	port = &(nhi_ctxt->net_devices[port_num]);
+	mutex_lock(&port->state_mutex);
+
+	mutex_unlock(&controllers_list_mutex);
+	port->medium_sts = MEDIUM_READY_FOR_APPROVAL;
+	if (port->net_dev)
+		negotiation_events(port->net_dev, MEDIUM_DISCONNECTED);
+	mutex_unlock(&port->state_mutex);
+	return  0;
+}
+
 static int nhi_mailbox_generic(struct tbt_nhi_ctxt *nhi_ctxt, u32 mb_cmd)
 	__releases(&controllers_list_mutex)
 {
@@ -526,13 +556,90 @@ static int nhi_genl_mailbox(__always_unused struct sk_buff *u_skb,
 		return -ERESTART;
 
 	nhi_ctxt = nhi_search_ctxt(*(u32 *)info->userhdr);
-	if (nhi_ctxt && !nhi_ctxt->d0_exit)
-		return nhi_mailbox_generic(nhi_ctxt, mb_cmd);
+	if (nhi_ctxt && !nhi_ctxt->d0_exit) {
+
+		/* rwsem is released later by the below functions */
+		if (nhi_is_path_disconnected(cmd, nhi_ctxt->num_ports))
+			return nhi_mailbox_disconn_path(nhi_ctxt, cmd);
+		else
+			return nhi_mailbox_generic(nhi_ctxt, mb_cmd);
+
+	}
 
 	mutex_unlock(&controllers_list_mutex);
 	return -ENODEV;
 }
 
+static int nhi_genl_approve_networking(__always_unused struct sk_buff *u_skb,
+				       struct genl_info *info)
+{
+	struct tbt_nhi_ctxt *nhi_ctxt;
+	struct route_string *route_str;
+	int res = -ENODEV;
+	u8 port_num;
+
+	if (!info || !info->userhdr || !info->attrs ||
+	    !info->attrs[NHI_ATTR_LOCAL_ROUTE_STRING] ||
+	    !info->attrs[NHI_ATTR_LOCAL_UUID] ||
+	    !info->attrs[NHI_ATTR_REMOTE_UUID] ||
+	    !info->attrs[NHI_ATTR_LOCAL_DEPTH])
+		return -EINVAL;
+
+	/*
+	 * route_str is an unique topological address
+	 * used for approving remote controller
+	 */
+	route_str = nla_data(info->attrs[NHI_ATTR_LOCAL_ROUTE_STRING]);
+	/* extracts the port we're connected to */
+	port_num = PORT_NUM_FROM_LINK(L0_PORT_NUM(route_str->lo));
+
+	if (mutex_lock_interruptible(&controllers_list_mutex))
+		return -ERESTART;
+
+	nhi_ctxt = nhi_search_ctxt(*(u32 *)info->userhdr);
+	if (nhi_ctxt && !nhi_ctxt->d0_exit) {
+		struct port_net_dev *port;
+
+		if (port_num >= nhi_ctxt->num_ports) {
+			res = -EINVAL;
+			goto free_ctl_list;
+		}
+
+		port = &(nhi_ctxt->net_devices[port_num]);
+
+		mutex_lock(&port->state_mutex);
+		mutex_unlock(&controllers_list_mutex);
+
+		if (port->medium_sts != MEDIUM_READY_FOR_APPROVAL)
+			goto unlock;
+
+		port->medium_sts = MEDIUM_READY_FOR_CONNECTION;
+
+		if (!port->net_dev) {
+			port->net_dev = nhi_alloc_etherdev(nhi_ctxt, port_num,
+							   info);
+			if (!port->net_dev) {
+				mutex_unlock(&port->state_mutex);
+				return -ENOMEM;
+			}
+		} else {
+			nhi_update_etherdev(nhi_ctxt, port->net_dev, info);
+
+			negotiation_events(port->net_dev,
+					   MEDIUM_READY_FOR_CONNECTION);
+		}
+
+unlock:
+		mutex_unlock(&port->state_mutex);
+
+		return 0;
+	}
+
+free_ctl_list:
+	mutex_unlock(&controllers_list_mutex);
+
+	return res;
+}
 
 static int nhi_genl_send_msg(struct tbt_nhi_ctxt *nhi_ctxt, enum pdf_value pdf,
 			     const u8 *msg, u32 msg_len)
@@ -579,17 +686,127 @@ static int nhi_genl_send_msg(struct tbt_nhi_ctxt *nhi_ctxt, enum pdf_value pdf,
 	return res;
 }
 
+static bool nhi_handle_inter_domain_msg(struct tbt_nhi_ctxt *nhi_ctxt,
+					struct thunderbolt_ip_header *hdr)
+{
+	struct port_net_dev *port;
+	u8 port_num;
+
+	const uuid_be proto_uuid = APPLE_THUNDERBOLT_IP_PROTOCOL_UUID;
+
+	if (uuid_be_cmp(proto_uuid, hdr->apple_tbt_ip_proto_uuid) != 0)
+		return true;
+
+	port_num = PORT_NUM_FROM_LINK(
+				L0_PORT_NUM(be32_to_cpu(hdr->route_str.lo)));
+
+	if (unlikely(port_num >= nhi_ctxt->num_ports))
+		return false;
+
+	port = &(nhi_ctxt->net_devices[port_num]);
+	mutex_lock(&port->state_mutex);
+	if (port->net_dev != NULL)
+		negotiation_messages(port->net_dev, hdr);
+	mutex_unlock(&port->state_mutex);
+
+	return false;
+}
+
+static void nhi_handle_notification_msg(struct tbt_nhi_ctxt *nhi_ctxt,
+					const u8 *msg)
+{
+	struct port_net_dev *port;
+	u8 port_num;
+
+#define INTER_DOMAIN_LINK_SHIFT 0
+#define INTER_DOMAIN_LINK_MASK	GENMASK(2, INTER_DOMAIN_LINK_SHIFT)
+	switch (msg[3]) {
+
+	case NC_INTER_DOMAIN_CONNECTED:
+		port_num = PORT_NUM_FROM_MSG(msg[5]);
+#define INTER_DOMAIN_APPROVED BIT(3)
+		if (port_num < nhi_ctxt->num_ports &&
+		    !(msg[5] & INTER_DOMAIN_APPROVED))
+			nhi_ctxt->net_devices[port_num].medium_sts =
+						MEDIUM_READY_FOR_APPROVAL;
+		break;
+
+	case NC_INTER_DOMAIN_DISCONNECTED:
+		port_num = PORT_NUM_FROM_MSG(msg[5]);
+
+		if (unlikely(port_num >= nhi_ctxt->num_ports))
+			break;
+
+		port = &(nhi_ctxt->net_devices[port_num]);
+		mutex_lock(&port->state_mutex);
+		port->medium_sts = MEDIUM_DISCONNECTED;
+
+		if (port->net_dev != NULL)
+			negotiation_events(port->net_dev,
+					   MEDIUM_DISCONNECTED);
+		mutex_unlock(&port->state_mutex);
+		break;
+	}
+}
+
+static bool nhi_handle_icm_response_msg(struct tbt_nhi_ctxt *nhi_ctxt,
+					const u8 *msg)
+{
+	struct port_net_dev *port;
+	bool send_event = true;
+	u8 port_num;
+
+	if (nhi_ctxt->ignore_icm_resp &&
+	    msg[3] == RC_INTER_DOMAIN_PKT_SENT) {
+		nhi_ctxt->ignore_icm_resp = false;
+		send_event = false;
+	}
+	if (nhi_ctxt->wait_for_icm_resp) {
+		nhi_ctxt->wait_for_icm_resp = false;
+		up(&nhi_ctxt->send_sem);
+	}
+
+	if (msg[3] == RC_APPROVE_INTER_DOMAIN_CONNECTION) {
+#define APPROVE_INTER_DOMAIN_ERROR BIT(0)
+		if (unlikely(msg[2] & APPROVE_INTER_DOMAIN_ERROR))
+			return send_event;
+
+		port_num = PORT_NUM_FROM_LINK((msg[5]&INTER_DOMAIN_LINK_MASK)>>
+					       INTER_DOMAIN_LINK_SHIFT);
+
+		if (unlikely(port_num >= nhi_ctxt->num_ports))
+			return send_event;
+
+		port = &(nhi_ctxt->net_devices[port_num]);
+		mutex_lock(&port->state_mutex);
+		port->medium_sts = MEDIUM_CONNECTED;
+
+		if (port->net_dev != NULL)
+			negotiation_events(port->net_dev, MEDIUM_CONNECTED);
+		mutex_unlock(&port->state_mutex);
+	}
+
+	return send_event;
+}
+
 static bool nhi_msg_from_icm_analysis(struct tbt_nhi_ctxt *nhi_ctxt,
 					enum pdf_value pdf,
 					const u8 *msg, u32 msg_len)
 {
-	/*
-	 * preparation for messages that won't be sent,
-	 * currently unused in this patch.
-	 */
 	bool send_event = true;
 
 	switch (pdf) {
+	case PDF_INTER_DOMAIN_REQUEST:
+	case PDF_INTER_DOMAIN_RESPONSE:
+		send_event = nhi_handle_inter_domain_msg(
+					nhi_ctxt,
+					(struct thunderbolt_ip_header *)msg);
+		break;
+
+	case PDF_FW_TO_SW_NOTIFICATION:
+		nhi_handle_notification_msg(nhi_ctxt, msg);
+		break;
+
 	case PDF_ERROR_NOTIFICATION:
 		/* fallthrough */
 	case PDF_WRITE_CONFIGURATION_REGISTERS:
@@ -599,7 +816,12 @@ static bool nhi_msg_from_icm_analysis(struct tbt_nhi_ctxt *nhi_ctxt,
 			nhi_ctxt->wait_for_icm_resp = false;
 			up(&nhi_ctxt->send_sem);
 		}
-		/* fallthrough */
+		break;
+
+	case PDF_FW_TO_SW_RESPONSE:
+		send_event = nhi_handle_icm_response_msg(nhi_ctxt, msg);
+		break;
+
 	default:
 		break;
 	}
@@ -788,6 +1010,12 @@ static const struct genl_ops nhi_ops[] = {
 		.doit = nhi_genl_mailbox,
 		.flags = GENL_ADMIN_PERM,
 	},
+	{
+		.cmd = NHI_CMD_APPROVE_TBT_NETWORKING,
+		.policy = nhi_genl_policy,
+		.doit = nhi_genl_approve_networking,
+		.flags = GENL_ADMIN_PERM,
+	},
 };
 
 static int nhi_suspend(struct device *dev) __releases(&nhi_ctxt->send_sem)
@@ -795,6 +1023,17 @@ static int nhi_suspend(struct device *dev) __releases(&nhi_ctxt->send_sem)
 	struct tbt_nhi_ctxt *nhi_ctxt = pci_get_drvdata(to_pci_dev(dev));
 	void __iomem *rx_reg, *tx_reg;
 	u32 rx_reg_val, tx_reg_val;
+	int i;
+
+	for (i = 0; i < nhi_ctxt->num_ports; i++) {
+		struct port_net_dev *port = &nhi_ctxt->net_devices[i];
+
+		mutex_lock(&port->state_mutex);
+		port->medium_sts = MEDIUM_DISCONNECTED;
+		if (port->net_dev)
+			negotiation_events(port->net_dev, MEDIUM_DISCONNECTED);
+		mutex_unlock(&port->state_mutex);
+	}
 
 	/* must be after negotiation_events, since messages might be sent */
 	nhi_ctxt->d0_exit = true;
@@ -954,6 +1193,15 @@ static void icm_nhi_remove(struct pci_dev *pdev)
 
 	nhi_suspend(&pdev->dev);
 
+	for (i = 0; i < nhi_ctxt->num_ports; i++) {
+		mutex_lock(&nhi_ctxt->net_devices[i].state_mutex);
+		if (nhi_ctxt->net_devices[i].net_dev) {
+			nhi_dealloc_etherdev(nhi_ctxt->net_devices[i].net_dev);
+			nhi_ctxt->net_devices[i].net_dev = NULL;
+		}
+		mutex_unlock(&nhi_ctxt->net_devices[i].state_mutex);
+	}
+
 	if (nhi_ctxt->net_workqueue)
 		destroy_workqueue(nhi_ctxt->net_workqueue);
 
diff --git a/drivers/thunderbolt/icm/net.c b/drivers/thunderbolt/icm/net.c
new file mode 100644
index 0000000..beeafb3
--- /dev/null
+++ b/drivers/thunderbolt/icm/net.c
@@ -0,0 +1,783 @@
+/*******************************************************************************
+ *
+ * Intel Thunderbolt(TM) driver
+ * Copyright(c) 2014 - 2016 Intel Corporation.
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
+ ******************************************************************************/
+
+#include <linux/etherdevice.h>
+#include <linux/crc32.h>
+#include <linux/prefetch.h>
+#include <linux/highmem.h>
+#include <linux/if_vlan.h>
+#include <linux/jhash.h>
+#include <linux/vmalloc.h>
+#include <net/ip6_checksum.h>
+#include "icm_nhi.h"
+#include "net.h"
+
+#define DEFAULT_MSG_ENABLE (NETIF_MSG_PROBE | NETIF_MSG_LINK | NETIF_MSG_IFUP)
+static int debug = -1;
+module_param(debug, int, 0000);
+MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
+
+#define TBT_NET_RX_HDR_SIZE 256
+
+#define NUM_TX_LOGIN_RETRIES 60
+
+#define APPLE_THUNDERBOLT_IP_PROTOCOL_REVISION 1
+
+#define LOGIN_TX_PATH 0xf
+
+#define TBT_NET_MTU (64 * 1024)
+
+/* Number of Rx buffers we bundle into one write to the hardware */
+#define TBT_NET_RX_BUFFER_WRITE	16
+
+#define TBT_NET_MULTICAST_HASH_TABLE_SIZE 1024
+#define TBT_NET_ETHER_ADDR_HASH(addr) (((addr[4] >> 4) | (addr[5] << 4)) % \
+				       TBT_NET_MULTICAST_HASH_TABLE_SIZE)
+
+#define BITS_PER_U32 (sizeof(u32) * BITS_PER_BYTE)
+
+#define TBT_NET_NUM_TX_BUFS 256
+#define TBT_NET_NUM_RX_BUFS 256
+#define TBT_NET_SIZE_TOTAL_DESCS ((TBT_NET_NUM_TX_BUFS + TBT_NET_NUM_RX_BUFS) \
+				  * sizeof(struct tbt_buf_desc))
+
+
+#define TBT_NUM_FRAMES_PER_PAGE (PAGE_SIZE / TBT_RING_MAX_FRAME_SIZE)
+
+#define TBT_NUM_BUFS_BETWEEN(idx1, idx2, num_bufs) \
+	(((num_bufs) - 1) - \
+	 ((((idx1) - (idx2)) + (num_bufs)) & ((num_bufs) - 1)))
+
+#define TX_WAKE_THRESHOLD (2 * DIV_ROUND_UP(TBT_NET_MTU, \
+			   TBT_RING_MAX_FRM_DATA_SZ))
+
+#define TBT_NET_DESC_ATTR_SOF_EOF (((PDF_TBT_NET_START_OF_FRAME << \
+				     DESC_ATTR_SOF_SHIFT) & \
+				    DESC_ATTR_SOF_MASK) | \
+				   ((PDF_TBT_NET_END_OF_FRAME << \
+				     DESC_ATTR_EOF_SHIFT) & \
+				    DESC_ATTR_EOF_MASK))
+
+/* E2E workaround */
+#define TBT_EXIST_BUT_UNUSED_HOPID 2
+
+enum tbt_net_frame_pdf {
+	PDF_TBT_NET_MIDDLE_FRAME,
+	PDF_TBT_NET_START_OF_FRAME,
+	PDF_TBT_NET_END_OF_FRAME,
+};
+
+struct thunderbolt_ip_login {
+	struct thunderbolt_ip_header header;
+	__be32 protocol_revision;
+	__be32 transmit_path;
+	__be32 reserved[4];
+	__be32 crc;
+};
+
+struct thunderbolt_ip_login_response {
+	struct thunderbolt_ip_header header;
+	__be32 status;
+	__be32 receiver_mac_address[2];
+	__be32 receiver_mac_address_length;
+	__be32 reserved[4];
+	__be32 crc;
+};
+
+struct thunderbolt_ip_logout {
+	struct thunderbolt_ip_header header;
+	__be32 crc;
+};
+
+struct thunderbolt_ip_status {
+	struct thunderbolt_ip_header header;
+	__be32 status;
+	__be32 crc;
+};
+
+struct approve_inter_domain_connection_cmd {
+	__be32 req_code;
+	__be32 attributes;
+#define AIDC_ATTR_LINK_SHIFT	16
+#define AIDC_ATTR_LINK_MASK	GENMASK(18, AIDC_ATTR_LINK_SHIFT)
+#define AIDC_ATTR_DEPTH_SHIFT	20
+#define AIDC_ATTR_DEPTH_MASK	GENMASK(23, AIDC_ATTR_DEPTH_SHIFT)
+	uuid_be remote_uuid;
+	__be16 transmit_ring_number;
+	__be16 transmit_path;
+	__be16 receive_ring_number;
+	__be16 receive_path;
+	__be32 crc;
+
+};
+
+enum neg_event {
+	RECEIVE_LOGOUT = NUM_MEDIUM_STATUSES,
+	RECEIVE_LOGIN_RESPONSE,
+	RECEIVE_LOGIN,
+	NUM_NEG_EVENTS
+};
+
+enum disconnect_path_stage {
+	STAGE_1 = BIT(0),
+	STAGE_2 = BIT(1)
+};
+
+/**
+ *  struct tbt_port - the basic tbt_port structure
+ *  @tbt_nhi_ctxt:		context of the nhi controller.
+ *  @net_dev:			networking device object.
+ *  @login_retry_work:		work queue for sending login requests.
+ *  @login_response_work:	work queue for sending login responses.
+ *  @work_struct logout_work:	work queue for sending logout requests.
+ *  @status_reply_work:		work queue for sending logout replies.
+ *  @approve_inter_domain_work:	work queue for sending interdomain to icm.
+ *  @route_str:			allows to route the messages to destination.
+ *  @interdomain_local_uuid:	allows to route the messages from local source.
+ *  @interdomain_remote_uuid:	allows to route the messages to destination.
+ *  @command_id			a number that identifies the command.
+ *  @negotiation_status:	holds the network negotiation state.
+ *  @msg_enable:		used for debugging filters.
+ *  @seq_num:			a number that identifies the session.
+ *  @login_retry_count:		counts number of login retries sent.
+ *  @local_depth:		depth of the remote peer in the chain.
+ *  @transmit_path:		routing parameter for the icm.
+ *  @frame_id:			counting ID of frames.
+ *  @num:			port number.
+ *  @local_path:		routing parameter for the icm.
+ *  @enable_full_e2e:		whether to enable full E2E.
+ *  @match_frame_id:		whether to match frame id on incoming packets.
+ */
+struct tbt_port {
+	struct tbt_nhi_ctxt *nhi_ctxt;
+	struct net_device *net_dev;
+	struct delayed_work login_retry_work;
+	struct work_struct login_response_work;
+	struct work_struct logout_work;
+	struct work_struct status_reply_work;
+	struct work_struct approve_inter_domain_work;
+	struct route_string route_str;
+	uuid_be interdomain_local_uuid;
+	uuid_be interdomain_remote_uuid;
+	u32 command_id;
+	u16 negotiation_status;
+	u16 msg_enable;
+	u8 seq_num;
+	u8 login_retry_count;
+	u8 local_depth;
+	u8 transmit_path;
+	u16 frame_id;
+	u8 num;
+	u8 local_path;
+	bool enable_full_e2e : 1;
+	bool match_frame_id : 1;
+};
+
+static void disconnect_path(struct tbt_port *port,
+			    enum disconnect_path_stage stage)
+{
+	u32 cmd = (DISCONNECT_PORT_A_INTER_DOMAIN_PATH + port->num);
+
+	cmd <<= REG_INMAIL_CMD_CMD_SHIFT;
+	cmd &= REG_INMAIL_CMD_CMD_MASK;
+	cmd |= REG_INMAIL_CMD_REQUEST;
+
+	mutex_lock(&port->nhi_ctxt->mailbox_mutex);
+	if (!mutex_trylock(&port->nhi_ctxt->d0_exit_mailbox_mutex)) {
+		netif_notice(port, link, port->net_dev, "controller id %#x is existing D0\n",
+			     port->nhi_ctxt->id);
+	} else {
+		nhi_mailbox(port->nhi_ctxt, cmd, stage, false);
+
+		port->nhi_ctxt->net_devices[port->num].medium_sts =
+					MEDIUM_READY_FOR_CONNECTION;
+
+		mutex_unlock(&port->nhi_ctxt->d0_exit_mailbox_mutex);
+	}
+	mutex_unlock(&port->nhi_ctxt->mailbox_mutex);
+}
+
+static void tbt_net_tear_down(struct net_device *net_dev, bool send_logout)
+{
+	struct tbt_port *port = netdev_priv(net_dev);
+	void __iomem *iobase = port->nhi_ctxt->iobase;
+	void __iomem *tx_reg = NULL;
+	u32 tx_reg_val = 0;
+
+	netif_carrier_off(net_dev);
+	netif_stop_queue(net_dev);
+
+	if (port->negotiation_status & BIT(MEDIUM_CONNECTED)) {
+		void __iomem *rx_reg = iobase + REG_RX_OPTIONS_BASE +
+		      (port->local_path * REG_OPTS_STEP);
+		u32 rx_reg_val = ioread32(rx_reg) & ~REG_OPTS_E2E_EN;
+
+		tx_reg = iobase + REG_TX_OPTIONS_BASE +
+			 (port->local_path * REG_OPTS_STEP);
+		tx_reg_val = ioread32(tx_reg) & ~REG_OPTS_E2E_EN;
+
+		disconnect_path(port, STAGE_1);
+
+		/* disable RX flow control  */
+		iowrite32(rx_reg_val, rx_reg);
+		/* disable TX flow control  */
+		iowrite32(tx_reg_val, tx_reg);
+		/* disable RX ring  */
+		iowrite32(rx_reg_val & ~REG_OPTS_VALID, rx_reg);
+
+		rx_reg = iobase + REG_RX_RING_BASE +
+			 (port->local_path * REG_RING_STEP);
+		iowrite32(0, rx_reg + REG_RING_PHYS_LO_OFFSET);
+		iowrite32(0, rx_reg + REG_RING_PHYS_HI_OFFSET);
+	}
+
+	/* Stop login messages */
+	cancel_delayed_work_sync(&port->login_retry_work);
+
+	if (send_logout)
+		queue_work(port->nhi_ctxt->net_workqueue, &port->logout_work);
+
+	if (port->negotiation_status & BIT(MEDIUM_CONNECTED)) {
+		unsigned long flags;
+
+		/* wait for TX to finish */
+		usleep_range(5 * USEC_PER_MSEC, 7 * USEC_PER_MSEC);
+		/* disable TX ring  */
+		iowrite32(tx_reg_val & ~REG_OPTS_VALID, tx_reg);
+
+		disconnect_path(port, STAGE_2);
+
+		spin_lock_irqsave(&port->nhi_ctxt->lock, flags);
+		/* disable RX and TX interrupts */
+		RING_INT_DISABLE_TX_RX(iobase, port->local_path,
+				       port->nhi_ctxt->num_paths);
+		spin_unlock_irqrestore(&port->nhi_ctxt->lock, flags);
+	}
+}
+
+static inline int send_message(struct tbt_port *port, const char *func,
+				enum pdf_value pdf, u32 msg_len,
+				const void *msg)
+{
+	u32 crc_offset = msg_len - sizeof(__be32);
+	__be32 *crc = (__be32 *)((u8 *)msg + crc_offset);
+	bool is_intdom = (pdf == PDF_INTER_DOMAIN_RESPONSE);
+	int res;
+
+	*crc = cpu_to_be32(~__crc32c_le(~0, msg, crc_offset));
+	res = down_timeout(&port->nhi_ctxt->send_sem,
+			   msecs_to_jiffies(3 * MSEC_PER_SEC));
+	if (res) {
+		netif_err(port, link, port->net_dev, "%s: controller id %#x timeout on send semaphore\n",
+			  func, port->nhi_ctxt->id);
+		return res;
+	}
+
+	if (!mutex_trylock(&port->nhi_ctxt->d0_exit_send_mutex)) {
+		up(&port->nhi_ctxt->send_sem);
+		netif_notice(port, link, port->net_dev, "%s: controller id %#x is existing D0\n",
+			     func, port->nhi_ctxt->id);
+		return -ENODEV;
+	}
+
+	res = nhi_send_message(port->nhi_ctxt, pdf, msg_len, msg, is_intdom);
+
+	mutex_unlock(&port->nhi_ctxt->d0_exit_send_mutex);
+	if (res)
+		up(&port->nhi_ctxt->send_sem);
+
+	return res;
+}
+
+static void approve_inter_domain(struct work_struct *work)
+{
+	struct tbt_port *port = container_of(work, typeof(*port),
+					     approve_inter_domain_work);
+	struct approve_inter_domain_connection_cmd approve_msg = {
+		.req_code = cpu_to_be32(CC_APPROVE_INTER_DOMAIN_CONNECTION),
+		.transmit_path = cpu_to_be16(LOGIN_TX_PATH),
+	};
+	u32 aidc = (L0_PORT_NUM(port->route_str.lo) << AIDC_ATTR_LINK_SHIFT) &
+		    AIDC_ATTR_LINK_MASK;
+
+	aidc |= (port->local_depth << AIDC_ATTR_DEPTH_SHIFT) &
+		 AIDC_ATTR_DEPTH_MASK;
+
+	approve_msg.attributes = cpu_to_be32(aidc);
+
+	memcpy(&approve_msg.remote_uuid, &port->interdomain_remote_uuid,
+	       sizeof(approve_msg.remote_uuid));
+	approve_msg.transmit_ring_number = cpu_to_be16(port->local_path);
+	approve_msg.receive_ring_number = cpu_to_be16(port->local_path);
+	approve_msg.receive_path = cpu_to_be16(port->transmit_path);
+
+	send_message(port, __func__, PDF_SW_TO_FW_COMMAND, sizeof(approve_msg),
+		     &approve_msg);
+}
+
+static inline void prepare_header(struct thunderbolt_ip_header *header,
+				  struct tbt_port *port,
+				  enum thunderbolt_ip_packet_type packet_type,
+				  u8 len_dwords)
+{
+	const uuid_be proto_uuid = APPLE_THUNDERBOLT_IP_PROTOCOL_UUID;
+
+	header->packet_type = cpu_to_be32(packet_type);
+	header->route_str.hi = cpu_to_be32(port->route_str.hi);
+	header->route_str.lo = cpu_to_be32(port->route_str.lo);
+	header->attributes = cpu_to_be32(
+		((port->seq_num << HDR_ATTR_SEQ_NUM_SHIFT) &
+		 HDR_ATTR_SEQ_NUM_MASK) |
+		((len_dwords << HDR_ATTR_LEN_SHIFT) & HDR_ATTR_LEN_MASK));
+	memcpy(&header->apple_tbt_ip_proto_uuid, &proto_uuid,
+	       sizeof(header->apple_tbt_ip_proto_uuid));
+	memcpy(&header->initiator_uuid, &port->interdomain_local_uuid,
+	       sizeof(header->initiator_uuid));
+	memcpy(&header->target_uuid, &port->interdomain_remote_uuid,
+	       sizeof(header->target_uuid));
+	header->command_id = cpu_to_be32(port->command_id);
+
+	port->command_id++;
+}
+
+static void status_reply(struct work_struct *work)
+{
+	struct tbt_port *port = container_of(work, typeof(*port),
+					     status_reply_work);
+	struct thunderbolt_ip_status status_msg = {
+		.status = 0,
+	};
+
+	prepare_header(&status_msg.header, port,
+		       THUNDERBOLT_IP_STATUS_TYPE,
+		       (offsetof(struct thunderbolt_ip_status, crc) -
+			offsetof(struct thunderbolt_ip_status,
+				 header.apple_tbt_ip_proto_uuid)) /
+		       sizeof(u32));
+
+	send_message(port, __func__, PDF_INTER_DOMAIN_RESPONSE,
+		     sizeof(status_msg), &status_msg);
+
+}
+
+static void logout(struct work_struct *work)
+{
+	struct tbt_port *port = container_of(work, typeof(*port),
+					     logout_work);
+	struct thunderbolt_ip_logout logout_msg;
+
+	prepare_header(&logout_msg.header, port,
+		       THUNDERBOLT_IP_LOGOUT_TYPE,
+		       (offsetof(struct thunderbolt_ip_logout, crc) -
+			offsetof(struct thunderbolt_ip_logout,
+			       header.apple_tbt_ip_proto_uuid)) / sizeof(u32));
+
+	send_message(port, __func__, PDF_INTER_DOMAIN_RESPONSE,
+		     sizeof(logout_msg), &logout_msg);
+
+}
+
+static void login_response(struct work_struct *work)
+{
+	struct tbt_port *port = container_of(work, typeof(*port),
+					     login_response_work);
+	struct thunderbolt_ip_login_response login_res_msg = {
+		.receiver_mac_address_length = cpu_to_be32(ETH_ALEN),
+	};
+
+	prepare_header(&login_res_msg.header, port,
+		       THUNDERBOLT_IP_LOGIN_RESPONSE_TYPE,
+		       (offsetof(struct thunderbolt_ip_login_response, crc) -
+			offsetof(struct thunderbolt_ip_login_response,
+			       header.apple_tbt_ip_proto_uuid)) / sizeof(u32));
+
+	ether_addr_copy((u8 *)login_res_msg.receiver_mac_address,
+			port->net_dev->dev_addr);
+
+	send_message(port, __func__, PDF_INTER_DOMAIN_RESPONSE,
+		     sizeof(login_res_msg), &login_res_msg);
+
+}
+
+static void login_retry(struct work_struct *work)
+{
+	struct tbt_port *port = container_of(work, typeof(*port),
+					     login_retry_work.work);
+	struct thunderbolt_ip_login login_msg = {
+		.protocol_revision = cpu_to_be32(
+				APPLE_THUNDERBOLT_IP_PROTOCOL_REVISION),
+		.transmit_path = cpu_to_be32(LOGIN_TX_PATH),
+	};
+
+
+	if (port->nhi_ctxt->d0_exit)
+		return;
+
+	port->login_retry_count++;
+
+	prepare_header(&login_msg.header, port,
+		       THUNDERBOLT_IP_LOGIN_TYPE,
+		       (offsetof(struct thunderbolt_ip_login, crc) -
+		       offsetof(struct thunderbolt_ip_login,
+		       header.apple_tbt_ip_proto_uuid)) / sizeof(u32));
+
+	if (send_message(port, __func__, PDF_INTER_DOMAIN_RESPONSE,
+			 sizeof(login_msg), &login_msg) == -ENODEV)
+		return;
+
+	if (likely(port->login_retry_count < NUM_TX_LOGIN_RETRIES))
+		queue_delayed_work(port->nhi_ctxt->net_workqueue,
+				   &port->login_retry_work,
+				   msecs_to_jiffies(5 * MSEC_PER_SEC));
+	else
+		netif_notice(port, link, port->net_dev, "port %u (%#x) login timeout after %u retries\n",
+			     port->num, port->negotiation_status,
+			     port->login_retry_count);
+}
+
+void negotiation_events(struct net_device *net_dev,
+			enum medium_status medium_sts)
+{
+	struct tbt_port *port = netdev_priv(net_dev);
+	void __iomem *iobase = port->nhi_ctxt->iobase;
+	u32 sof_eof_en, tx_ring_conf, rx_ring_conf, e2e_en;
+	void __iomem *reg;
+	unsigned long flags;
+	u16 hop_id;
+	bool send_logout;
+
+	if (!netif_running(net_dev)) {
+		netif_dbg(port, link, net_dev, "port %u (%#x) is down\n",
+			  port->num, port->negotiation_status);
+		return;
+	}
+
+	netif_dbg(port, link, net_dev, "port %u (%#x) receive event %u\n",
+		  port->num, port->negotiation_status, medium_sts);
+
+	switch (medium_sts) {
+	case MEDIUM_DISCONNECTED:
+		send_logout = (port->negotiation_status
+				& (BIT(MEDIUM_CONNECTED)
+				   |  BIT(MEDIUM_READY_FOR_CONNECTION)));
+		send_logout = send_logout && !(port->negotiation_status &
+					       BIT(RECEIVE_LOGOUT));
+
+		tbt_net_tear_down(net_dev, send_logout);
+		port->negotiation_status = BIT(MEDIUM_DISCONNECTED);
+		break;
+
+	case MEDIUM_CONNECTED:
+		/*
+		 * check if meanwhile other side sent logout
+		 * if yes, just don't allow connection to take place
+		 * and disconnect path
+		 */
+		if (port->negotiation_status & BIT(RECEIVE_LOGOUT)) {
+			disconnect_path(port, STAGE_1 | STAGE_2);
+			break;
+		}
+
+		port->negotiation_status = BIT(MEDIUM_CONNECTED);
+
+		/* configure TX ring */
+		reg = iobase + REG_TX_RING_BASE +
+		      (port->local_path * REG_RING_STEP);
+
+		tx_ring_conf = (TBT_NET_NUM_TX_BUFS << REG_RING_SIZE_SHIFT) &
+				REG_RING_SIZE_MASK;
+
+		iowrite32(tx_ring_conf, reg + REG_RING_SIZE_OFFSET);
+
+		/* enable the rings */
+		reg = iobase + REG_TX_OPTIONS_BASE +
+		      (port->local_path * REG_OPTS_STEP);
+		if (port->enable_full_e2e) {
+			iowrite32(REG_OPTS_VALID | REG_OPTS_E2E_EN, reg);
+			hop_id = port->local_path;
+		} else {
+			iowrite32(REG_OPTS_VALID, reg);
+			hop_id = TBT_EXIST_BUT_UNUSED_HOPID;
+		}
+
+		reg = iobase + REG_RX_OPTIONS_BASE +
+		      (port->local_path * REG_OPTS_STEP);
+
+		sof_eof_en = (BIT(PDF_TBT_NET_START_OF_FRAME) <<
+			      REG_RX_OPTS_MASK_SOF_SHIFT) &
+			     REG_RX_OPTS_MASK_SOF_MASK;
+
+		sof_eof_en |= (BIT(PDF_TBT_NET_END_OF_FRAME) <<
+			       REG_RX_OPTS_MASK_EOF_SHIFT) &
+			      REG_RX_OPTS_MASK_EOF_MASK;
+
+		iowrite32(sof_eof_en, reg + REG_RX_OPTS_MASK_OFFSET);
+
+		e2e_en = REG_OPTS_VALID | REG_OPTS_E2E_EN;
+		e2e_en |= (hop_id << REG_RX_OPTS_TX_E2E_HOP_ID_SHIFT) &
+			  REG_RX_OPTS_TX_E2E_HOP_ID_MASK;
+
+		iowrite32(e2e_en, reg);
+
+		/*
+		 * Configure RX ring
+		 * must be after enable ring for E2E to work
+		 */
+		reg = iobase + REG_RX_RING_BASE +
+		      (port->local_path * REG_RING_STEP);
+
+		rx_ring_conf = (TBT_NET_NUM_RX_BUFS << REG_RING_SIZE_SHIFT) &
+				REG_RING_SIZE_MASK;
+
+		rx_ring_conf |= (TBT_RING_MAX_FRAME_SIZE <<
+				 REG_RING_BUF_SIZE_SHIFT) &
+				REG_RING_BUF_SIZE_MASK;
+
+		iowrite32(rx_ring_conf, reg + REG_RING_SIZE_OFFSET);
+
+		spin_lock_irqsave(&port->nhi_ctxt->lock, flags);
+		/* enable RX interrupt */
+		iowrite32(ioread32(iobase + REG_RING_INTERRUPT_BASE) |
+			  REG_RING_INT_RX_PROCESSED(port->local_path,
+						    port->nhi_ctxt->num_paths),
+			  iobase + REG_RING_INTERRUPT_BASE);
+		spin_unlock_irqrestore(&port->nhi_ctxt->lock, flags);
+
+		netif_info(port, link, net_dev, "Thunderbolt(TM) Networking port %u - ready\n",
+			   port->num);
+
+		netif_carrier_on(net_dev);
+		netif_start_queue(net_dev);
+		break;
+
+	case MEDIUM_READY_FOR_CONNECTION:
+		/*
+		 * If medium is connected, no reason to go back,
+		 * keep it 'connected'.
+		 * If received login response, don't need to trigger login
+		 * retries again.
+		 */
+		if (unlikely(port->negotiation_status &
+			     (BIT(MEDIUM_CONNECTED) |
+			      BIT(RECEIVE_LOGIN_RESPONSE))))
+			break;
+
+		port->negotiation_status = BIT(MEDIUM_READY_FOR_CONNECTION);
+		port->login_retry_count = 0;
+		queue_delayed_work(port->nhi_ctxt->net_workqueue,
+				   &port->login_retry_work, 0);
+		break;
+
+	default:
+		break;
+	}
+}
+
+void negotiation_messages(struct net_device *net_dev,
+			  struct thunderbolt_ip_header *hdr)
+{
+	struct tbt_port *port = netdev_priv(net_dev);
+	__be32 status;
+
+	if (!netif_running(net_dev)) {
+		netif_dbg(port, link, net_dev, "port %u (%#x) is down\n",
+			  port->num, port->negotiation_status);
+		return;
+	}
+
+	switch (hdr->packet_type) {
+	case cpu_to_be32(THUNDERBOLT_IP_LOGIN_TYPE):
+		port->transmit_path = be32_to_cpu(
+			((struct thunderbolt_ip_login *)hdr)->transmit_path);
+		netif_dbg(port, link, net_dev, "port %u (%#x) receive ThunderboltIP login message with transmit path %u\n",
+			  port->num, port->negotiation_status,
+			  port->transmit_path);
+
+		if (unlikely(port->negotiation_status &
+			     BIT(MEDIUM_DISCONNECTED)))
+			break;
+
+		queue_work(port->nhi_ctxt->net_workqueue,
+			   &port->login_response_work);
+
+		if (unlikely(port->negotiation_status & BIT(MEDIUM_CONNECTED)))
+			break;
+
+		/*
+		 *  In case a login response received from other peer
+		 * on my login and acked their login for the first time,
+		 * so just approve the inter-domain now
+		 */
+		if (port->negotiation_status & BIT(RECEIVE_LOGIN_RESPONSE)) {
+			if (!(port->negotiation_status & BIT(RECEIVE_LOGIN)))
+				queue_work(port->nhi_ctxt->net_workqueue,
+					   &port->approve_inter_domain_work);
+		/*
+		 * if we reached the number of max retries or previous
+		 * logout, schedule another round of login retries
+		 */
+		} else if ((port->login_retry_count >= NUM_TX_LOGIN_RETRIES) ||
+			   (port->negotiation_status & BIT(RECEIVE_LOGOUT))) {
+			port->negotiation_status &= ~(BIT(RECEIVE_LOGOUT));
+			port->login_retry_count = 0;
+			queue_delayed_work(port->nhi_ctxt->net_workqueue,
+					   &port->login_retry_work, 0);
+		}
+
+		port->negotiation_status |= BIT(RECEIVE_LOGIN);
+
+		break;
+
+	case cpu_to_be32(THUNDERBOLT_IP_LOGIN_RESPONSE_TYPE):
+		status = ((struct thunderbolt_ip_login_response *)hdr)->status;
+		if (likely(status == 0)) {
+			netif_dbg(port, link, net_dev, "port %u (%#x) receive ThunderboltIP login response message\n",
+				  port->num,
+				  port->negotiation_status);
+
+			if (unlikely(port->negotiation_status &
+				     (BIT(MEDIUM_DISCONNECTED) |
+				      BIT(MEDIUM_CONNECTED) |
+				      BIT(RECEIVE_LOGIN_RESPONSE))))
+				break;
+
+			port->negotiation_status |=
+						BIT(RECEIVE_LOGIN_RESPONSE);
+			cancel_delayed_work_sync(&port->login_retry_work);
+			/*
+			 * login was received from other peer and now response
+			 * on our login so approve the inter-domain
+			 */
+			if (port->negotiation_status & BIT(RECEIVE_LOGIN))
+				queue_work(port->nhi_ctxt->net_workqueue,
+					   &port->approve_inter_domain_work);
+			else
+				port->negotiation_status &=
+							~BIT(RECEIVE_LOGOUT);
+		} else {
+			netif_notice(port, link, net_dev, "port %u (%#x) receive ThunderboltIP login response message with status %u\n",
+				     port->num,
+				     port->negotiation_status,
+				     be32_to_cpu(status));
+		}
+		break;
+
+	case cpu_to_be32(THUNDERBOLT_IP_LOGOUT_TYPE):
+		netif_dbg(port, link, net_dev, "port %u (%#x) receive ThunderboltIP logout message\n",
+			  port->num, port->negotiation_status);
+
+		queue_work(port->nhi_ctxt->net_workqueue,
+			   &port->status_reply_work);
+		port->negotiation_status &= ~(BIT(RECEIVE_LOGIN) |
+					      BIT(RECEIVE_LOGIN_RESPONSE));
+		port->negotiation_status |= BIT(RECEIVE_LOGOUT);
+
+		if (!(port->negotiation_status & BIT(MEDIUM_CONNECTED))) {
+			tbt_net_tear_down(net_dev, false);
+			break;
+		}
+
+		tbt_net_tear_down(net_dev, true);
+
+		port->negotiation_status |= BIT(MEDIUM_READY_FOR_CONNECTION);
+		port->negotiation_status &= ~(BIT(MEDIUM_CONNECTED));
+		break;
+
+	case cpu_to_be32(THUNDERBOLT_IP_STATUS_TYPE):
+		netif_dbg(port, link, net_dev, "port %u (%#x) receive ThunderboltIP status message with status %u\n",
+			  port->num, port->negotiation_status,
+			  be32_to_cpu(
+			  ((struct thunderbolt_ip_status *)hdr)->status));
+		break;
+	}
+}
+
+void nhi_dealloc_etherdev(struct net_device *net_dev)
+{
+	unregister_netdev(net_dev);
+	free_netdev(net_dev);
+}
+
+void nhi_update_etherdev(struct tbt_nhi_ctxt *nhi_ctxt,
+			 struct net_device *net_dev, struct genl_info *info)
+{
+	struct tbt_port *port = netdev_priv(net_dev);
+
+	nla_memcpy(&(port->route_str),
+		   info->attrs[NHI_ATTR_LOCAL_ROUTE_STRING],
+		   sizeof(port->route_str));
+	nla_memcpy(&port->interdomain_remote_uuid,
+		   info->attrs[NHI_ATTR_REMOTE_UUID],
+		   sizeof(port->interdomain_remote_uuid));
+	port->local_depth = nla_get_u8(info->attrs[NHI_ATTR_LOCAL_DEPTH]);
+	port->enable_full_e2e = nhi_ctxt->support_full_e2e ?
+		nla_get_flag(info->attrs[NHI_ATTR_ENABLE_FULL_E2E]) : false;
+	port->match_frame_id =
+		nla_get_flag(info->attrs[NHI_ATTR_MATCH_FRAME_ID]);
+	port->frame_id = 0;
+}
+
+struct net_device *nhi_alloc_etherdev(struct tbt_nhi_ctxt *nhi_ctxt,
+				      u8 port_num, struct genl_info *info)
+{
+	struct tbt_port *port;
+	struct net_device *net_dev = alloc_etherdev(sizeof(struct tbt_port));
+	u32 hash;
+
+	if (!net_dev)
+		return NULL;
+
+	SET_NETDEV_DEV(net_dev, &nhi_ctxt->pdev->dev);
+
+	port = netdev_priv(net_dev);
+	port->nhi_ctxt = nhi_ctxt;
+	port->net_dev = net_dev;
+	nla_memcpy(&port->interdomain_local_uuid,
+		   info->attrs[NHI_ATTR_LOCAL_UUID],
+		   sizeof(port->interdomain_local_uuid));
+	nhi_update_etherdev(nhi_ctxt, net_dev, info);
+	port->num = port_num;
+	port->local_path = PATH_FROM_PORT(nhi_ctxt->num_paths, port_num);
+
+	port->msg_enable = netif_msg_init(debug, DEFAULT_MSG_ENABLE);
+
+	net_dev->addr_assign_type = NET_ADDR_PERM;
+	/* unicast and locally administred MAC */
+	net_dev->dev_addr[0] = (port_num << 4) | 0x02;
+	hash = jhash2((u32 *)&port->interdomain_local_uuid,
+		      sizeof(port->interdomain_local_uuid)/sizeof(u32), 0);
+
+	memcpy(net_dev->dev_addr + 1, &hash, sizeof(hash));
+	hash = jhash2((u32 *)&port->interdomain_local_uuid,
+		      sizeof(port->interdomain_local_uuid)/sizeof(u32), hash);
+
+	net_dev->dev_addr[5] = hash & 0xff;
+
+	scnprintf(net_dev->name, sizeof(net_dev->name), "tbtnet%%dp%hhu",
+		  port_num);
+
+	INIT_DELAYED_WORK(&port->login_retry_work, login_retry);
+	INIT_WORK(&port->login_response_work, login_response);
+	INIT_WORK(&port->logout_work, logout);
+	INIT_WORK(&port->status_reply_work, status_reply);
+	INIT_WORK(&port->approve_inter_domain_work, approve_inter_domain);
+
+	netif_info(port, probe, net_dev,
+		   "Thunderbolt(TM) Networking port %u - MAC Address: %pM\n",
+		   port_num, net_dev->dev_addr);
+
+	return net_dev;
+}
diff --git a/drivers/thunderbolt/icm/net.h b/drivers/thunderbolt/icm/net.h
index 0281201..1cb6701 100644
--- a/drivers/thunderbolt/icm/net.h
+++ b/drivers/thunderbolt/icm/net.h
@@ -23,6 +23,10 @@
 #include <linux/semaphore.h>
 #include <net/genetlink.h>
 
+#define APPLE_THUNDERBOLT_IP_PROTOCOL_UUID	\
+	UUID_BE(0x9E588F79, 0x478A, 0x1636,		\
+		0x64, 0x56, 0xC6, 0x97, 0xDD, 0xC8, 0x20, 0xA9)
+
 /*
  * Each physical port contains 2 channels.
  * Devices are exposed to user based on physical ports.
@@ -33,6 +37,9 @@
  * host channel/link which starts from 1.
  */
 #define PORT_NUM_FROM_LINK(link) (((link) - 1) / CHANNELS_PER_PORT_NUM)
+#define PORT_NUM_FROM_MSG(msg) PORT_NUM_FROM_LINK(((msg) & \
+			       INTER_DOMAIN_LINK_MASK) >> \
+			       INTER_DOMAIN_LINK_SHIFT)
 
 #define TBT_TX_RING_FULL(prod, cons, size) ((((prod) + 1) % (size)) == (cons))
 #define TBT_TX_RING_EMPTY(prod, cons) ((prod) == (cons))
@@ -125,6 +132,17 @@ enum {
 	CC_SET_FW_MODE_FDA_DA_ALL
 };
 
+struct route_string {
+	u32 hi;
+	u32 lo;
+};
+
+struct route_string_be {
+	__be32 hi;
+	__be32 lo;
+};
+
+#define L0_PORT_NUM(cpu_route_str_lo) ((cpu_route_str_lo) & GENMASK(5, 0))
 
 /* NHI genetlink attributes */
 enum {
@@ -138,12 +156,53 @@ enum {
 	NHI_ATTR_PDF,
 	NHI_ATTR_MSG_TO_ICM,
 	NHI_ATTR_MSG_FROM_ICM,
+	NHI_ATTR_LOCAL_ROUTE_STRING,
+	NHI_ATTR_LOCAL_UUID,
+	NHI_ATTR_REMOTE_UUID,
+	NHI_ATTR_LOCAL_DEPTH,
+	NHI_ATTR_ENABLE_FULL_E2E,
+	NHI_ATTR_MATCH_FRAME_ID,
 	__NHI_ATTR_MAX,
 };
 #define NHI_ATTR_MAX (__NHI_ATTR_MAX - 1)
 
+/* ThunderboltIP Packet Types */
+enum thunderbolt_ip_packet_type {
+	THUNDERBOLT_IP_LOGIN_TYPE,
+	THUNDERBOLT_IP_LOGIN_RESPONSE_TYPE,
+	THUNDERBOLT_IP_LOGOUT_TYPE,
+	THUNDERBOLT_IP_STATUS_TYPE
+};
+
+struct thunderbolt_ip_header {
+	struct route_string_be route_str;
+	__be32 attributes;
+#define HDR_ATTR_LEN_SHIFT	0
+#define HDR_ATTR_LEN_MASK	GENMASK(5, HDR_ATTR_LEN_SHIFT)
+#define HDR_ATTR_SEQ_NUM_SHIFT	27
+#define HDR_ATTR_SEQ_NUM_MASK	GENMASK(28, HDR_ATTR_SEQ_NUM_SHIFT)
+	uuid_be apple_tbt_ip_proto_uuid;
+	uuid_be initiator_uuid;
+	uuid_be target_uuid;
+	__be32 packet_type;
+	__be32 command_id;
+};
+
+enum medium_status {
+	/* Handle cable disconnection or peer down */
+	MEDIUM_DISCONNECTED,
+	/* Connection is fully established */
+	MEDIUM_CONNECTED,
+	/*  Awaiting for being approved by user-space module */
+	MEDIUM_READY_FOR_APPROVAL,
+	/* Approved by user-space, awaiting for establishment flow to finish */
+	MEDIUM_READY_FOR_CONNECTION,
+	NUM_MEDIUM_STATUSES
+};
+
 struct port_net_dev {
 	struct net_device *net_dev;
+	enum medium_status medium_sts;
 	struct mutex state_mutex;
 };
 
@@ -213,5 +272,16 @@ struct tbt_nhi_ctxt {
 int nhi_send_message(struct tbt_nhi_ctxt *nhi_ctxt, enum pdf_value pdf,
 		      u32 msg_len, const void *msg, bool ignore_icm_resp);
 int nhi_mailbox(struct tbt_nhi_ctxt *nhi_ctxt, u32 cmd, u32 data, bool deinit);
+struct net_device *nhi_alloc_etherdev(struct tbt_nhi_ctxt *nhi_ctxt,
+				      u8 port_num, struct genl_info *info);
+void nhi_update_etherdev(struct tbt_nhi_ctxt *nhi_ctxt,
+			 struct net_device *net_dev, struct genl_info *info);
+void nhi_dealloc_etherdev(struct net_device *net_dev);
+void negotiation_events(struct net_device *net_dev,
+			enum medium_status medium_sts);
+void negotiation_messages(struct net_device *net_dev,
+			  struct thunderbolt_ip_header *hdr);
+void tbt_net_rx_msi(struct net_device *net_dev);
+void tbt_net_tx_msi(struct net_device *net_dev);
 
 #endif
-- 
2.7.4
