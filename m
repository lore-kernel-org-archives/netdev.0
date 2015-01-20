From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v3 04/12] net: flow_table: create a set of common
 headers and actions
Date: Tue, 20 Jan 2015 12:27:53 -0800
Message-ID: <20150120202752.1741.13810.stgit@nitbit.x32>
References: <20150120202404.1741.8658.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, davem@davemloft.net,
	gerlitz.or@gmail.com, andy@greyhouse.net, ast@plumgrid.com
To: tgraf@suug.ch, simon.horman@netronome.com, sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:48520 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751152AbbATU2N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 15:28:13 -0500
Received: by mail-ob0-f181.google.com with SMTP id nt9so5021346obb.12
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2015 12:28:13 -0800 (PST)
In-Reply-To: <20150120202404.1741.8658.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds common headers and actions that drivers can use.

I have not yet moved the header graphs into the common header
because I'm not entirely convinced its re-usable. The devices
I have been looking at have different enough header graphs that
they wouldn't be re-usable. However possibly many 40Gbp NICs
for example could share a common header graph. When we get
multiple implementations we can move this into the common file
if it makes sense.

And table structures seem to be unique enough that there is
little value in putting each devices table layout into the
common file so its left for device specific implementation.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/linux/if_flow_common.h |  257 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 257 insertions(+)
 create mode 100644 include/linux/if_flow_common.h

diff --git a/include/linux/if_flow_common.h b/include/linux/if_flow_common.h
new file mode 100644
index 0000000..ef2d66f
--- /dev/null
+++ b/include/linux/if_flow_common.h
@@ -0,0 +1,257 @@
+#ifndef _IF_FLOW_COMMON_H_
+#define _IF_FLOW_COMMON_H_
+
+#include <linux/if_flow.h>
+
+/* Common header definition this section provides a set of common or
+ * standard headers that device driver writers may use to simplify the
+ * driver creation. We do not want vendor or driver specific headers
+ * here though. Driver authors can keep these contained to their driver
+ *
+ * Driver authors may use unique IDs greater than HEADER_MAX_UID it is
+ * guaranteed to be larger than any unique IDs used here.
+ */
+#define HEADER_MAX_UID 100
+
+enum net_flow_headers {
+	HEADER_UNSPEC,
+	HEADER_ETHERNET,
+	HEADER_VLAN,
+	HEADER_IPV4,
+};
+
+enum net_flow_ethernet_fields_ids {
+	HEADER_ETHERNET_UNSPEC,
+	HEADER_ETHERNET_SRC_MAC,
+	HEADER_ETHERNET_DST_MAC,
+	HEADER_ETHERNET_ETHERTYPE,
+};
+
+struct net_flow_field net_flow_ethernet_fields[] = {
+	{ .name = "src_mac", .uid = HEADER_ETHERNET_SRC_MAC, .bitwidth = 48},
+	{ .name = "dst_mac", .uid = HEADER_ETHERNET_DST_MAC, .bitwidth = 48},
+	{ .name = "ethertype",
+	  .uid = HEADER_ETHERNET_ETHERTYPE,
+	  .bitwidth = 16},
+};
+
+struct net_flow_hdr net_flow_ethernet = {
+	.name = "ethernet",
+	.uid = HEADER_ETHERNET,
+	.field_sz = ARRAY_SIZE(net_flow_ethernet_fields),
+	.fields = net_flow_ethernet_fields,
+};
+
+enum net_flow_vlan_fields_ids {
+	HEADER_VLAN_UNSPEC,
+	HEADER_VLAN_PCP,
+	HEADER_VLAN_CFI,
+	HEADER_VLAN_VID,
+	HEADER_VLAN_ETHERTYPE,
+};
+
+struct net_flow_field net_flow_vlan_fields[] = {
+	{ .name = "pcp", .uid = HEADER_VLAN_PCP, .bitwidth = 3,},
+	{ .name = "cfi", .uid = HEADER_VLAN_CFI, .bitwidth = 1,},
+	{ .name = "vid", .uid = HEADER_VLAN_VID, .bitwidth = 12,},
+	{ .name = "ethertype", .uid = HEADER_VLAN_ETHERTYPE, .bitwidth = 16,},
+};
+
+struct net_flow_hdr net_flow_vlan = {
+	.name = "vlan",
+	.uid = HEADER_VLAN,
+	.field_sz = ARRAY_SIZE(net_flow_vlan_fields),
+	.fields = net_flow_vlan_fields,
+};
+
+enum net_flow_ipv4_fields_ids {
+	HEADER_IPV4_UNSPEC,
+	HEADER_IPV4_VERSION,
+	HEADER_IPV4_IHL,
+	HEADER_IPV4_DSCP,
+	HEADER_IPV4_ECN,
+	HEADER_IPV4_LENGTH,
+	HEADER_IPV4_IDENTIFICATION,
+	HEADER_IPV4_FLAGS,
+	HEADER_IPV4_FRAGMENT_OFFSET,
+	HEADER_IPV4_TTL,
+	HEADER_IPV4_PROTOCOL,
+	HEADER_IPV4_CSUM,
+	HEADER_IPV4_SRC_IP,
+	HEADER_IPV4_DST_IP,
+	HEADER_IPV4_OPTIONS,
+};
+
+struct net_flow_field net_flow_ipv4_fields[] = {
+	{ .name = "version",
+	  .uid = HEADER_IPV4_VERSION,
+	  .bitwidth = 4,},
+	{ .name = "ihl",
+	  .uid = HEADER_IPV4_IHL,
+	  .bitwidth = 4,},
+	{ .name = "dscp",
+	  .uid = HEADER_IPV4_DSCP,
+	  .bitwidth = 6,},
+	{ .name = "ecn",
+	  .uid = HEADER_IPV4_ECN,
+	  .bitwidth = 2,},
+	{ .name = "length",
+	  .uid = HEADER_IPV4_LENGTH,
+	  .bitwidth = 8,},
+	{ .name = "identification",
+	  .uid = HEADER_IPV4_IDENTIFICATION,
+	  .bitwidth = 8,},
+	{ .name = "flags",
+	  .uid = HEADER_IPV4_FLAGS,
+	  .bitwidth = 3,},
+	{ .name = "fragment_offset",
+	  .uid = HEADER_IPV4_FRAGMENT_OFFSET,
+	  .bitwidth = 13,},
+	{ .name = "ttl",
+	  .uid = HEADER_IPV4_TTL,
+	  .bitwidth = 1,},
+	{ .name = "protocol",
+	  .uid = HEADER_IPV4_PROTOCOL,
+	  .bitwidth = 8,},
+	{ .name = "csum",
+	  .uid = HEADER_IPV4_CSUM,
+	  .bitwidth = 8,},
+	{ .name = "src_ip",
+	  .uid = HEADER_IPV4_SRC_IP,
+	  .bitwidth = 32,},
+	{ .name = "dst_ip",
+	  .uid = HEADER_IPV4_DST_IP,
+	  .bitwidth = 32,},
+	{ .name = "options",
+	  .uid = HEADER_IPV4_OPTIONS,
+	  .bitwidth = 0,},
+};
+
+struct net_flow_hdr net_flow_ipv4 = {
+	.name = "ipv4",
+	.uid = HEADER_IPV4,
+	.field_sz = ARRAY_SIZE(net_flow_ipv4_fields),
+	.fields = net_flow_ipv4_fields,
+};
+
+/* Common set of actions. Below are the list of actions that are or we expect
+ * are common enough to be supported by multiple devices.
+ *
+ * Driver authors may use unique IDs greater than ACTION_MAX_UID it is
+ * guaranteed to be larger than any unique IDs used here.
+ */
+#define ACTION_MAX_UID 100
+
+enum net_flow_action_ids {
+	ACTION_SET_UNSPEC,
+	ACTION_SET_VLAN_ID,
+	ACTION_COPY_TO_CPU,
+	ACTION_POP_VLAN,
+	ACTION_SET_ETH_SRC,
+	ACTION_SET_ETH_DST,
+	ACTION_SET_OUT_PORT,
+	ACTION_CHECK_TTL_DROP,
+};
+
+struct net_flow_action_arg net_flow_null_args[] = {
+	{
+		.name = "",
+		.type = NFL_ACTION_ARG_TYPE_NULL,
+	},
+};
+
+struct net_flow_action net_flow_null_action = {
+	.name = "", .uid = 0, .args = NULL,
+};
+
+struct net_flow_action_arg net_flow_set_vlan_id_args[] = {
+	{
+		.name = "vlan_id",
+		.type = NFL_ACTION_ARG_TYPE_U16,
+		.value_u16 = 0,
+	},
+	{
+		.name = "",
+		.type = NFL_ACTION_ARG_TYPE_NULL,
+	},
+};
+
+struct net_flow_action net_flow_set_vlan_id = {
+	.name = "set_vlan_id",
+	.uid = ACTION_SET_VLAN_ID,
+	.args = net_flow_set_vlan_id_args,
+};
+
+struct net_flow_action net_flow_copy_to_cpu = {
+	.name = "copy_to_cpu",
+	.uid = ACTION_COPY_TO_CPU,
+	.args = net_flow_null_args,
+};
+
+struct net_flow_action net_flow_pop_vlan = {
+	.name = "pop_vlan",
+	.uid = ACTION_POP_VLAN,
+	.args = net_flow_null_args,
+};
+
+struct net_flow_action_arg net_flow_set_eth_src_args[] = {
+	{
+		.name = "eth_src",
+		.type = NFL_ACTION_ARG_TYPE_U64,
+		.value_u64 = 0,
+	},
+	{
+		.name = "",
+		.type = NFL_ACTION_ARG_TYPE_NULL,
+	},
+};
+
+struct net_flow_action net_flow_set_eth_src = {
+	.name = "set_eth_src",
+	.uid = ACTION_SET_ETH_SRC,
+	.args = net_flow_set_eth_src_args,
+};
+
+struct net_flow_action_arg net_flow_set_eth_dst_args[] = {
+	{
+		.name = "eth_dst",
+		.type = NFL_ACTION_ARG_TYPE_U64,
+		.value_u64 = 0,
+	},
+	{
+		.name = "",
+		.type = NFL_ACTION_ARG_TYPE_NULL,
+	},
+};
+
+struct net_flow_action net_flow_set_eth_dst = {
+	.name = "set_eth_dst",
+	.uid = ACTION_SET_ETH_DST,
+	.args = net_flow_set_eth_dst_args,
+};
+
+struct net_flow_action_arg net_flow_set_out_port_args[] = {
+	{
+		.name = "set_out_port",
+		.type = NFL_ACTION_ARG_TYPE_U32,
+		.value_u32 = 0,
+	},
+	{
+		.name = "",
+		.type = NFL_ACTION_ARG_TYPE_NULL,
+	},
+};
+
+struct net_flow_action net_flow_set_out_port = {
+	.name = "set_out_port",
+	.uid = ACTION_SET_OUT_PORT,
+	.args = net_flow_set_out_port_args,
+};
+
+struct net_flow_action net_flow_check_ttl_drop = {
+	.name = "check_ttl_drop",
+	.uid = ACTION_CHECK_TTL_DROP,
+	.args = net_flow_null_args,
+};
+
+#endif
