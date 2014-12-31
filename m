From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v1 01/11] net: flow_table: create interface for hw
 match/action tables
Date: Wed, 31 Dec 2014 11:45:46 -0800
Message-ID: <20141231194544.31070.30335.stgit@nitbit.x32>
References: <20141231194057.31070.5244.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, andy@greyhouse.net
To: tgraf@suug.ch, sfeldma@gmail.com, jiri@resnulli.us,
	jhs@mojatatu.com, simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:42726 "EHLO
	mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751026AbaLaTqJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 14:46:09 -0500
Received: by mail-oi0-f47.google.com with SMTP id v63so36654180oia.6
        for <netdev@vger.kernel.org>; Wed, 31 Dec 2014 11:46:09 -0800 (PST)
In-Reply-To: <20141231194057.31070.5244.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, we do not have an interface to query hardware and learn
the capabilities of the device. This makes it very difficult to use
hardware flow tables.

At the moment the only interface we have to work with hardware flow
tables is ethtool. This has many deficiencies, first its ioctl based
making it difficult to use in systems that need to monitor interfaces
because there is no support for multicast, notifiers, etc.

The next big gap is it doesn't support querying devices for
capabilities. The only way to learn hardware entries is by doing a
"try and see" operation. An error perhaps indicating the device can
not support your request but could be possibly for other reasons.
Maybe a table is full for example. The existing flow interface only
supports a single ingress table which is sufficient for some of the
existing NIC host interfaces but limiting for more advanced NIC
interfaces and switch devices.

Also it is not extensible without recompiling both drivers and core
interfaces. It may be possible to reprogram a device with additional
header types, new protocols, whatever and it would be great if the
flow table infrastructure can handle this.

So this patch scraps the ethtool flow classifier interface and
creates a new flow table interface. It is expected that device that
support the existing ethtool interface today can support both
interfaces without too much difficulty. I did a proof point on the
ixgbe driver. Only choosing ixgbe because I have a 82599 10Gbps
device in my development system. A more thorough implementation
was done for the rocker switch showing how to use the interface.

In this patch we create interfaces to get the headers a device
supports, the actions it supports, a header graph showing the
relationship between headers the device supports, the tables
supported by the device and how they are connected.

This patch _only_ provides the get routines in an attempt to
make the patch sequence manageable.

get_headers :

   report a set of headers/fields the device supports. These
   are specified as length/offsets so we can support standard
   protocols or vendor specific headers. This is more flexible
   then bitmasks of pre-defined packet types. In 'tc' for example
   I may use u32 to match on proprietary or vendor specific fields.
   A bitmask approach does not allow for this, but defining the
   fields as a set of offsets and lengths allows for this.

   A device that supports Openflow version 1.x for example could
   provide the set of field/offsets that are equivelent to the
   specification.

   One property of this type of interface is I don't have to
   rebuild my kernel/driver header interfaces, etc to support the
   latest and greatest trendy protocol foo.

   For some types of metadata the device understands we also
   use header fields to represent these. One example of this is
   we may have an ingress_port metadata field to report the
   port a packet was received on. At the moment we expect the
   metadata fields to be defined outside the interface. We can
   standardize on common ones such "ingress_port" across devices.

   Some examples of outside definitions specifying metadata
   might be OVS, internal definitions like skb->mark, or some
   FoRCES definitions.

get_header_graph :

   Simply providing a header/field offset I support is not sufficient
   to learn how many nested 802.1Q tags I can support and other
   similar cases where the ordering of headers matters.

   So we use this operation to query the device for a header
   graph showing how the headers need to be related.
   With this operation and the 'get_headers' operation you can
   interrogate the driver with questions like "do you support
   Q'in'Q?", "how many VLAN tags can I nest before the parser
   breaks?", "Do you support MPLS?", "How about Foo Header in
   a VXLAN tunnel?".

get_actions :

   Report a list of actions supported by the device along with the
   arguments they take. So "drop_packet" action takes no arguments
   and "set_field" action takes two arguments a field and value.

   This suffers again from being slightly opaque. Meaning if a device
   reports back action "foo_bar" with three arguments how do I as a
   consumer of this "know" what that action is? The easy thing to do
   is punt on it and say it should be described outside the driver
   somewhere. OVS for example defines a set of actions. If my FoRCeS
   quick read is correct they define actions using text in the
   messaging interface. A follow up patch series could use a
   description language to describe actions. Possibly using something
   from eBPF or nftables for example. This patch will not try to
   solve the isuse now and expect actions are defined outside the API
   or are well known.

get_tables :

   Hardware may support one or more tables. Each table supports a set
   of matches and a set of actions. The match fields supported are
   defined above by the 'get_headers' operations. Similarly the actions
   supported are defined by the 'get_actions' operation.

   This allows the hardware to report several tables all with distinct
   capabilities. Tables also have table attributes used to describe
   features of the table. Because netlink messages are TLV based we
   can easily add new table attribues as needed.

   Currently a table has two attributes size and source. The size
   indicates how many "slots" are in the table for flow entries. One
   caveat here is a rule in the flow table may consume multiple slots
   in the table. We deal with this in a subsequent patch.

   The source field is used to indicate table boundaries where actions
   are applied. A table with the same source value will not "see"
   actions from tables with the same source. An example where this is
   relavent would be to have an action to re-write the destiniation
   IP address of a packet. If you have a match rule in a table with
   the same source that matches on the new IP address it will not be
   hit. However if it is in a table with a different source value
   _and_ in another table that gets applied the rule will be hit. See
   the next operatoin for querying table ordering.

   Some basic hardware may only support a single table which simplifies
   some things. But even the simple 10/40Gbps NICs support multiple
   tables and different tables depending on ingress/egress.

get_table_graph :

   When a device supports multiple tables we need to identify how the
   tables are connected when each table is executed.

   To do this we provide a table graph which gives the pipeline of the
   device. The graph gives nodes representing each table and the edges
   indicate the criteria to progress to the next flow table. There are
   examples of this type of thing in both FoRCES and OVS. OVS
   prescribes a set of tables reachable with goto actions and FoRCES a
   slightly more flexible arrangement. In software tc's u32 classifier
   allows "linking" hash tables together. The OVS dataplane with the
   support of 'goto' action is completely connected. Without the
   'goto' action the tables are progressed linearly.

   By querying the graph from hardware we can "learn" what table flows
   are supported and map them into software.

   We also provide a bit to indicate if the node is a root node of the
   ingress pipeline or egress pipeline. This is used on devices that
   have different pipelines for ingres and egress. This appears to be
   fairly common for devices. The realtek chip presented at LPC in
   Dusseldorf for example appeared to have a separate ingress/egress
   pipeline.

With these five operations software can learn what types of fields
the hardware flow table supports and how they are arranged. Subsequent
patches will address programming the flow tables.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/linux/if_flow.h      |   93 +++++
 include/linux/netdevice.h    |   12 +
 include/uapi/linux/if_flow.h |  363 ++++++++++++++++++
 net/Kconfig                  |    7 
 net/core/Makefile            |    1 
 net/core/flow_table.c        |  837 ++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 1313 insertions(+)
 create mode 100644 include/linux/if_flow.h
 create mode 100644 include/uapi/linux/if_flow.h
 create mode 100644 net/core/flow_table.c

diff --git a/include/linux/if_flow.h b/include/linux/if_flow.h
new file mode 100644
index 0000000..1b6c1ea
--- /dev/null
+++ b/include/linux/if_flow.h
@@ -0,0 +1,93 @@
+/*
+ * include/linux/net/if_flow.h - Flow table interface for Switch devices
+ * Copyright (c) 2014 John Fastabend <john.r.fastabend@intel.com>
+ *
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
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Author: John Fastabend <john.r.fastabend@intel.com>
+ */
+
+#ifndef _IF_FLOW_H
+#define _IF_FLOW_H
+
+#include <uapi/linux/if_flow.h>
+
+/**
+ * @struct net_flow_header
+ * @brief defines a match (header/field) an endpoint can use
+ *
+ * @uid unique identifier for header
+ * @field_sz number of fields are in the set
+ * @fields the set of fields in the net_flow_header
+ */
+struct net_flow_header {
+	char name[NET_FLOW_NAMSIZ];
+	int uid;
+	int field_sz;
+	struct net_flow_field *fields;
+};
+
+/**
+ * @struct net_flow_action
+ * @brief a description of a endpoint defined action
+ *
+ * @name printable name
+ * @uid unique action identifier
+ * @types NET_FLOW_ACTION_TYPE_NULL terminated list of action types
+ */
+struct net_flow_action {
+	char name[NET_FLOW_NAMSIZ];
+	int uid;
+	struct net_flow_action_arg *args;
+};
+
+/**
+ * @struct net_flow_table
+ * @brief define flow table with supported match/actions
+ *
+ * @uid unique identifier for table
+ * @source uid of parent table
+ * @size max number of entries for table or -1 for unbounded
+ * @matches null terminated set of supported match types given by match uid
+ * @actions null terminated set of supported action types given by action uid
+ * @flows set of flows
+ */
+struct net_flow_table {
+	char name[NET_FLOW_NAMSIZ];
+	int uid;
+	int source;
+	int size;
+	struct net_flow_field_ref *matches;
+	int *actions;
+};
+
+/* net_flow_hdr_node: node in a header graph of header fields.
+ *
+ * @uid : unique id of the graph node
+ * @flwo_header_ref : identify the hdrs that can handled by this node
+ * @net_flow_jump_table : give a case jump statement
+ */
+struct net_flow_hdr_node {
+	char name[NET_FLOW_NAMSIZ];
+	int uid;
+	int *hdrs;
+	struct net_flow_jump_table *jump;
+};
+
+struct net_flow_tbl_node {
+	int uid;
+	__u32 flags;
+	struct net_flow_jump_table *jump;
+};
+#endif
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 29c92ee..3c3c856 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -52,6 +52,11 @@
 #include <linux/neighbour.h>
 #include <uapi/linux/netdevice.h>
 
+#ifdef CONFIG_NET_FLOW_TABLES
+#include <linux/if_flow.h>
+#include <uapi/linux/if_flow.h>
+#endif
+
 struct netpoll_info;
 struct device;
 struct phy_device;
@@ -1186,6 +1191,13 @@ struct net_device_ops {
 	int			(*ndo_switch_port_stp_update)(struct net_device *dev,
 							      u8 state);
 #endif
+#ifdef CONFIG_NET_FLOW_TABLES
+	struct net_flow_action  **(*ndo_flow_get_actions)(struct net_device *dev);
+	struct net_flow_table	**(*ndo_flow_get_tables)(struct net_device *dev);
+	struct net_flow_header	**(*ndo_flow_get_headers)(struct net_device *dev);
+	struct net_flow_hdr_node **(*ndo_flow_get_hdr_graph)(struct net_device *dev);
+	struct net_flow_tbl_node **(*ndo_flow_get_tbl_graph)(struct net_device *dev);
+#endif
 };
 
 /**
diff --git a/include/uapi/linux/if_flow.h b/include/uapi/linux/if_flow.h
new file mode 100644
index 0000000..2acdb38
--- /dev/null
+++ b/include/uapi/linux/if_flow.h
@@ -0,0 +1,363 @@
+/*
+ * include/uapi/linux/if_flow.h - Flow table interface for Switch devices
+ * Copyright (c) 2014 John Fastabend <john.r.fastabend@intel.com>
+ *
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
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Author: John Fastabend <john.r.fastabend@intel.com>
+ */
+
+/* Netlink description:
+ *
+ * Table definition used to describe running tables. The following
+ * describes the netlink message returned from a flow API messages.
+ *
+ * Flow table definitions used to define tables.
+ *
+ * [NET_FLOW_TABLE_IDENTIFIER_TYPE]
+ * [NET_FLOW_TABLE_IDENTIFIER]
+ * [NET_FLOW_TABLE_TABLES]
+ *     [NET_FLOW_TABLE]
+ *       [NET_FLOW_TABLE_ATTR_NAME]
+ *       [NET_FLOW_TABLE_ATTR_UID]
+ *       [NET_FLOW_TABLE_ATTR_SOURCE]
+ *       [NET_FLOW_TABLE_ATTR_SIZE]
+ *	 [NET_FLOW_TABLE_ATTR_MATCHES]
+ *	   [NET_FLOW_FIELD_REF]
+ *	   [NET_FLOW_FIELD_REF]
+ *	     [...]
+ *	   [...]
+ *	 [NET_FLOW_TABLE_ATTR_ACTIONS]
+ *	   [NET_FLOW_ACTION]
+ *	     [NET_FLOW_ACTION_ATTR_NAME]
+ *	     [NET_FLOW_ACTION_ATTR_UID]
+ *	     [NET_FLOW_ACTION_ATTR_SIGNATURE]
+ *		 [NET_FLOW_ACTION_ARG]
+ *	         [NET_FLOW_ACTION_ARG]
+ *	         [...]
+ *	   [NET_FLOW_ACTION]
+ *	     [...]
+ *	   [...]
+ *     [NET_FLOW_TABLE]
+ *       [...]
+ *
+ * Header definitions used to define headers with user friendly
+ * names.
+ *
+ * [NET_FLOW_TABLE_HEADERS]
+ *   [NET_FLOW_HEADER]
+ *	[NET_FLOW_HEADER_ATTR_NAME]
+ *	[NET_FLOW_HEADER_ATTR_UID]
+ *	[NET_FLOW_HEADER_ATTR_FIELDS]
+ *	  [NET_FLOW_HEADER_ATTR_FIELD]
+ *	    [NET_FLOW_FIELD_ATTR_NAME]
+ *	    [NET_FLOW_FIELD_ATTR_UID]
+ *	    [NET_FLOW_FIELD_ATTR_BITWIDTH]
+ *	  [NET_FLOW_HEADER_ATTR_FIELD]
+ *	    [...]
+ *	  [...]
+ *   [NET_FLOW_HEADER]
+ *      [...]
+ *   [...]
+ *
+ * Action definitions supported by tables
+ *
+ * [NET_FLOW_TABLE_ACTIONS]
+ *   [NET_FLOW_TABLE_ATTR_ACTIONS]
+ *	[NET_FLOW_ACTION]
+ *	  [NET_FLOW_ACTION_ATTR_NAME]
+ *	  [NET_FLOW_ACTION_ATTR_UID]
+ *	  [NET_FLOW_ACTION_ATTR_SIGNATURE]
+ *		 [NET_FLOW_ACTION_ARG]
+ *	         [NET_FLOW_ACTION_ARG]
+ *               [...]
+ *	[NET_FLOW_ACTION]
+ *	     [...]
+ *
+ * Parser definition used to unambiguously define match headers.
+ *
+ * [NET_FLOW_TABLE_PARSE_GRAPH]
+ *
+ * Primitive Type descriptions
+ *
+ * Get Table Graph <Request> only requires msg preamble.
+ *
+ * Get Table Graph <Reply> description
+ *
+ * [NET_FLOW_TABLE_TABLE_GRAPH]
+ *   [TABLE_GRAPH_NODE]
+ *	[TABLE_GRAPH_NODE_UID]
+ *	[TABLE_GRAPH_NODE_JUMP]
+ *	  [NET_FLOW_JUMP_TABLE_ENTRY]
+ *	  [NET_FLOW_JUMP_TABLE_ENTRY]
+ *	    [...]
+ *   [TABLE_GRAPH_NODE]
+ *	[..]
+ */
+
+#ifndef _UAPI_LINUX_IF_FLOW
+#define _UAPI_LINUX_IF_FLOW
+
+#include <linux/types.h>
+#include <linux/netlink.h>
+#include <linux/if.h>
+
+#define NET_FLOW_NAMSIZ 80
+
+/**
+ * @struct net_flow_fields
+ * @brief defines a field in a header
+ */
+struct net_flow_field {
+	char name[NET_FLOW_NAMSIZ];
+	int uid;
+	int bitwidth;
+};
+
+enum {
+	NET_FLOW_FIELD_UNSPEC,
+	NET_FLOW_FIELD,
+	__NET_FLOW_FIELD_MAX,
+};
+#define NET_FLOW_FIELD_MAX (__NET_FLOW_FIELD_MAX - 1)
+
+enum {
+	NET_FLOW_FIELD_ATTR_UNSPEC,
+	NET_FLOW_FIELD_ATTR_NAME,
+	NET_FLOW_FIELD_ATTR_UID,
+	NET_FLOW_FIELD_ATTR_BITWIDTH,
+	__NET_FLOW_FIELD_ATTR_MAX,
+};
+#define NET_FLOW_FIELD_ATTR_MAX (__NET_FLOW_FIELD_ATTR_MAX - 1)
+
+enum {
+	NET_FLOW_HEADER_UNSPEC,
+	NET_FLOW_HEADER,
+	__NET_FLOW_HEADER_MAX,
+};
+#define NET_FLOW_HEADER_MAX (__NET_FLOW_HEADER_MAX - 1)
+
+enum {
+	NET_FLOW_HEADER_ATTR_UNSPEC,
+	NET_FLOW_HEADER_ATTR_NAME,
+	NET_FLOW_HEADER_ATTR_UID,
+	NET_FLOW_HEADER_ATTR_FIELDS,
+	__NET_FLOW_HEADER_ATTR_MAX,
+};
+#define NET_FLOW_HEADER_ATTR_MAX (__NET_FLOW_HEADER_ATTR_MAX - 1)
+
+enum {
+	NET_FLOW_MASK_TYPE_UNSPEC,
+	NET_FLOW_MASK_TYPE_EXACT,
+	NET_FLOW_MASK_TYPE_LPM,
+};
+
+/**
+ * @struct net_flow_field_ref
+ * @brief uniquely identify field as header:field tuple
+ */
+struct net_flow_field_ref {
+	int instance;
+	int header;
+	int field;
+	int mask_type;
+	int type;
+	union {	/* Are these all the required data types */
+		__u8 value_u8;
+		__u16 value_u16;
+		__u32 value_u32;
+		__u64 value_u64;
+	};
+	union {	/* Are these all the required data types */
+		__u8 mask_u8;
+		__u16 mask_u16;
+		__u32 mask_u32;
+		__u64 mask_u64;
+	};
+};
+
+enum {
+	NET_FLOW_FIELD_REF_UNSPEC,
+	NET_FLOW_FIELD_REF,
+	__NET_FLOW_FIELD_REF_MAX,
+};
+#define NET_FLOW_FIELD_REF_MAX (__NET_FLOW_FIELD_REF_MAX - 1)
+
+enum {
+	NET_FLOW_FIELD_REF_ATTR_TYPE_UNSPEC,
+	NET_FLOW_FIELD_REF_ATTR_TYPE_U8,
+	NET_FLOW_FIELD_REF_ATTR_TYPE_U16,
+	NET_FLOW_FIELD_REF_ATTR_TYPE_U32,
+	NET_FLOW_FIELD_REF_ATTR_TYPE_U64,
+	/* Need more types for ether.addrs, ip.addrs, ... */
+};
+
+enum net_flow_action_arg_type {
+	NET_FLOW_ACTION_ARG_TYPE_NULL,
+	NET_FLOW_ACTION_ARG_TYPE_U8,
+	NET_FLOW_ACTION_ARG_TYPE_U16,
+	NET_FLOW_ACTION_ARG_TYPE_U32,
+	NET_FLOW_ACTION_ARG_TYPE_U64,
+	__NET_FLOW_ACTION_ARG_TYPE_VAL_MAX,
+};
+
+struct net_flow_action_arg {
+	char name[NET_FLOW_NAMSIZ];
+	enum net_flow_action_arg_type type;
+	union {
+		__u8  value_u8;
+		__u16 value_u16;
+		__u32 value_u32;
+		__u64 value_u64;
+	};
+};
+
+enum {
+	NET_FLOW_ACTION_ARG_UNSPEC,
+	NET_FLOW_ACTION_ARG,
+	__NET_FLOW_ACTION_ARG_MAX,
+};
+#define NET_FLOW_ACTION_ARG_MAX (__NET_FLOW_ACTION_ARG_MAX - 1)
+
+enum {
+	NET_FLOW_ACTION_UNSPEC,
+	NET_FLOW_ACTION,
+	__NET_FLOW_ACTION_MAX,
+};
+#define NET_FLOW_ACTION_MAX (__NET_FLOW_ACTION_MAX - 1)
+
+enum {
+	NET_FLOW_ACTION_ATTR_UNSPEC,
+	NET_FLOW_ACTION_ATTR_NAME,
+	NET_FLOW_ACTION_ATTR_UID,
+	NET_FLOW_ACTION_ATTR_SIGNATURE,
+	__NET_FLOW_ACTION_ATTR_MAX,
+};
+#define NET_FLOW_ACTION_ATTR_MAX (__NET_FLOW_ACTION_ATTR_MAX - 1)
+
+enum {
+	NET_FLOW_ACTION_SET_UNSPEC,
+	NET_FLOW_ACTION_SET_ACTIONS,
+	__NET_FLOW_ACTION_SET_MAX,
+};
+#define NET_FLOW_ACTION_SET_MAX (__NET_FLOW_ACTION_SET_MAX - 1)
+
+enum {
+	NET_FLOW_TABLE_UNSPEC,
+	NET_FLOW_TABLE,
+	__NET_FLOW_TABLE_MAX,
+};
+#define NET_FLOW_TABLE_MAX (__NET_FLOW_TABLE_MAX - 1)
+
+enum {
+	NET_FLOW_TABLE_ATTR_UNSPEC,
+	NET_FLOW_TABLE_ATTR_NAME,
+	NET_FLOW_TABLE_ATTR_UID,
+	NET_FLOW_TABLE_ATTR_SOURCE,
+	NET_FLOW_TABLE_ATTR_SIZE,
+	NET_FLOW_TABLE_ATTR_MATCHES,
+	NET_FLOW_TABLE_ATTR_ACTIONS,
+	__NET_FLOW_TABLE_ATTR_MAX,
+};
+#define NET_FLOW_TABLE_ATTR_MAX (__NET_FLOW_TABLE_ATTR_MAX - 1)
+
+struct net_flow_jump_table {
+	struct net_flow_field_ref field;
+	int node; /* <0 is a parser error */
+};
+
+#define NET_FLOW_JUMP_TABLE_DONE	-1
+
+enum {
+	NET_FLOW_JUMP_TABLE_ENTRY_UNSPEC,
+	NET_FLOW_JUMP_TABLE_ENTRY,
+	__NET_FLOW_JUMP_TABLE_ENTRY_MAX,
+};
+
+enum {
+	NET_FLOW_HEADER_NODE_HDRS_UNSPEC,
+	NET_FLOW_HEADER_NODE_HDRS_VALUE,
+	__NET_FLOW_HEADER_NODE_HDRS_MAX,
+};
+#define NET_FLOW_HEADER_NODE_HDRS_MAX (__NET_FLOW_HEADER_NODE_HDRS_MAX - 1)
+
+enum {
+	NET_FLOW_HEADER_NODE_UNSPEC,
+	NET_FLOW_HEADER_NODE_NAME,
+	NET_FLOW_HEADER_NODE_UID,
+	NET_FLOW_HEADER_NODE_HDRS,
+	NET_FLOW_HEADER_NODE_JUMP,
+	__NET_FLOW_HEADER_NODE_MAX,
+};
+#define NET_FLOW_HEADER_NODE_MAX (__NET_FLOW_HEADER_NODE_MAX - 1)
+
+enum {
+	NET_FLOW_HEADER_GRAPH_UNSPEC,
+	NET_FLOW_HEADER_GRAPH_NODE,
+	__NET_FLOW_HEADER_GRAPH_MAX,
+};
+#define NET_FLOW_HEADER_GRAPH_MAX (__NET_FLOW_HEADER_GRAPH_MAX - 1)
+
+#define NET_FLOW_TABLE_EGRESS_ROOT 1
+#define	NET_FLOW_TABLE_INGRESS_ROOT 2
+
+enum {
+	NET_FLOW_TABLE_GRAPH_NODE_UNSPEC,
+	NET_FLOW_TABLE_GRAPH_NODE_UID,
+	NET_FLOW_TABLE_GRAPH_NODE_FLAGS,
+	NET_FLOW_TABLE_GRAPH_NODE_JUMP,
+	__NET_FLOW_TABLE_GRAPH_NODE_MAX,
+};
+#define NET_FLOW_TABLE_GRAPH_NODE_MAX (__NET_FLOW_TABLE_GRAPH_NODE_MAX - 1)
+
+enum {
+	NET_FLOW_TABLE_GRAPH_UNSPEC,
+	NET_FLOW_TABLE_GRAPH_NODE,
+	__NET_FLOW_TABLE_GRAPH_MAX,
+};
+#define NET_FLOW_TABLE_GRAPH_MAX (__NET_FLOW_TABLE_GRAPH_MAX - 1)
+
+enum {
+	NET_FLOW_IDENTIFIER_IFINDEX, /* net_device ifindex */
+};
+
+enum {
+	NET_FLOW_UNSPEC,
+	NET_FLOW_IDENTIFIER_TYPE,
+	NET_FLOW_IDENTIFIER,
+
+	NET_FLOW_TABLES,
+	NET_FLOW_HEADERS,
+	NET_FLOW_ACTIONS,
+	NET_FLOW_HEADER_GRAPH,
+	NET_FLOW_TABLE_GRAPH,
+
+	__NET_FLOW_MAX,
+	NET_FLOW_MAX = (__NET_FLOW_MAX - 1),
+};
+
+enum {
+	NET_FLOW_TABLE_CMD_GET_TABLES,
+	NET_FLOW_TABLE_CMD_GET_HEADERS,
+	NET_FLOW_TABLE_CMD_GET_ACTIONS,
+	NET_FLOW_TABLE_CMD_GET_HDR_GRAPH,
+	NET_FLOW_TABLE_CMD_GET_TABLE_GRAPH,
+
+	__NET_FLOW_CMD_MAX,
+	NET_FLOW_CMD_MAX = (__NET_FLOW_CMD_MAX - 1),
+};
+
+#define NET_FLOW_GENL_NAME "net_flow_table"
+#define NET_FLOW_GENL_VERSION 0x1
+#endif /* _UAPI_LINUX_IF_FLOW */
diff --git a/net/Kconfig b/net/Kconfig
index ff9ffc1..8380bfe 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -293,6 +293,13 @@ config NET_FLOW_LIMIT
 	  with many clients some protection against DoS by a single (spoofed)
 	  flow that greatly exceeds average workload.
 
+config NET_FLOW_TABLES
+	boolean "Support network flow tables"
+	---help---
+	This feature provides an interface for device drivers to report
+	flow tables and supported matches and actions. If you do not
+	want to support hardware offloads for flow tables, say N here.
+
 menu "Network testing"
 
 config NET_PKTGEN
diff --git a/net/core/Makefile b/net/core/Makefile
index 235e6c5..1eea785 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -23,3 +23,4 @@ obj-$(CONFIG_NETWORK_PHY_TIMESTAMPING) += timestamping.o
 obj-$(CONFIG_NET_PTP_CLASSIFY) += ptp_classifier.o
 obj-$(CONFIG_CGROUP_NET_PRIO) += netprio_cgroup.o
 obj-$(CONFIG_CGROUP_NET_CLASSID) += netclassid_cgroup.o
+obj-$(CONFIG_NET_FLOW_TABLES) += flow_table.o
diff --git a/net/core/flow_table.c b/net/core/flow_table.c
new file mode 100644
index 0000000..ec3f06d
--- /dev/null
+++ b/net/core/flow_table.c
@@ -0,0 +1,837 @@
+/*
+ * include/uapi/linux/if_flow.h - Flow table interface for Switch devices
+ * Copyright (c) 2014 John Fastabend <john.r.fastabend@intel.com>
+ *
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
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Author: John Fastabend <john.r.fastabend@intel.com>
+ */
+
+#include <uapi/linux/if_flow.h>
+#include <linux/if_flow.h>
+#include <linux/if_bridge.h>
+#include <linux/types.h>
+#include <net/netlink.h>
+#include <net/genetlink.h>
+#include <net/rtnetlink.h>
+#include <linux/module.h>
+
+static struct genl_family net_flow_nl_family = {
+	.id		= GENL_ID_GENERATE,
+	.name		= NET_FLOW_GENL_NAME,
+	.version	= NET_FLOW_GENL_VERSION,
+	.maxattr	= NET_FLOW_MAX,
+	.netnsok	= true,
+};
+
+static struct net_device *net_flow_get_dev(struct genl_info *info)
+{
+	struct net *net = genl_info_net(info);
+	int type, ifindex;
+
+	if (!info->attrs[NET_FLOW_IDENTIFIER_TYPE] ||
+	    !info->attrs[NET_FLOW_IDENTIFIER])
+		return NULL;
+
+	type = nla_get_u32(info->attrs[NET_FLOW_IDENTIFIER_TYPE]);
+	switch (type) {
+	case NET_FLOW_IDENTIFIER_IFINDEX:
+		ifindex = nla_get_u32(info->attrs[NET_FLOW_IDENTIFIER]);
+		break;
+	default:
+		return NULL;
+	}
+
+	return dev_get_by_index(net, ifindex);
+}
+
+static int net_flow_put_act_types(struct sk_buff *skb,
+				  struct net_flow_action_arg *args)
+{
+	int i, err;
+
+	for (i = 0; args[i].type; i++) {
+		err = nla_put(skb, NET_FLOW_ACTION_ARG,
+			      sizeof(struct net_flow_action_arg), &args[i]);
+		if (err)
+			return -EMSGSIZE;
+	}
+	return 0;
+}
+
+static const
+struct nla_policy net_flow_action_policy[NET_FLOW_ACTION_ATTR_MAX + 1] = {
+	[NET_FLOW_ACTION_ATTR_NAME]	 = {.type = NLA_STRING,
+					    .len = NET_FLOW_NAMSIZ-1 },
+	[NET_FLOW_ACTION_ATTR_UID]	 = {.type = NLA_U32 },
+	[NET_FLOW_ACTION_ATTR_SIGNATURE] = {.type = NLA_NESTED },
+};
+
+static int net_flow_put_action(struct sk_buff *skb, struct net_flow_action *a)
+{
+	struct net_flow_action_arg *this;
+	struct nlattr *nest;
+	int err, args = 0;
+
+	if (a->name && nla_put_string(skb, NET_FLOW_ACTION_ATTR_NAME, a->name))
+		return -EMSGSIZE;
+
+	if (nla_put_u32(skb, NET_FLOW_ACTION_ATTR_UID, a->uid))
+		return -EMSGSIZE;
+
+	if (!a->args)
+		return 0;
+
+	for (this = &a->args[0]; strlen(this->name) > 0; this++)
+		args++;
+
+	if (args) {
+		nest = nla_nest_start(skb, NET_FLOW_ACTION_ATTR_SIGNATURE);
+		if (!nest)
+			goto nest_put_failure;
+
+		err = net_flow_put_act_types(skb, a->args);
+		if (err) {
+			nla_nest_cancel(skb, nest);
+			return err;
+		}
+		nla_nest_end(skb, nest);
+	}
+
+	return 0;
+nest_put_failure:
+	return -EMSGSIZE;
+}
+
+static int net_flow_put_actions(struct sk_buff *skb,
+				struct net_flow_action **acts)
+{
+	struct nlattr *actions;
+	int err, i;
+
+	actions = nla_nest_start(skb, NET_FLOW_ACTIONS);
+	if (!actions)
+		return -EMSGSIZE;
+
+	for (i = 0; acts[i]->uid; i++) {
+		struct nlattr *action = nla_nest_start(skb, NET_FLOW_ACTION);
+
+		if (!action)
+			goto action_put_failure;
+
+		err = net_flow_put_action(skb, acts[i]);
+		if (err)
+			goto action_put_failure;
+		nla_nest_end(skb, action);
+	}
+	nla_nest_end(skb, actions);
+
+	return 0;
+action_put_failure:
+	nla_nest_cancel(skb, actions);
+	return -EMSGSIZE;
+}
+
+struct sk_buff *net_flow_build_actions_msg(struct net_flow_action **a,
+					   struct net_device *dev,
+					   u32 portid, int seq, u8 cmd)
+{
+	struct genlmsghdr *hdr;
+	struct sk_buff *skb;
+	int err = -ENOBUFS;
+
+	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!skb)
+		return ERR_PTR(-ENOBUFS);
+
+	hdr = genlmsg_put(skb, portid, seq, &net_flow_nl_family, 0, cmd);
+	if (!hdr)
+		goto out;
+
+	if (nla_put_u32(skb,
+			NET_FLOW_IDENTIFIER_TYPE,
+			NET_FLOW_IDENTIFIER_IFINDEX) ||
+	    nla_put_u32(skb, NET_FLOW_IDENTIFIER, dev->ifindex)) {
+		err = -ENOBUFS;
+		goto out;
+	}
+
+	err = net_flow_put_actions(skb, a);
+	if (err < 0)
+		goto out;
+
+	err = genlmsg_end(skb, hdr);
+	if (err < 0)
+		goto out;
+
+	return skb;
+out:
+	nlmsg_free(skb);
+	return ERR_PTR(err);
+}
+
+static int net_flow_cmd_get_actions(struct sk_buff *skb,
+				    struct genl_info *info)
+{
+	struct net_flow_action **a;
+	struct net_device *dev;
+	struct sk_buff *msg;
+
+	dev = net_flow_get_dev(info);
+	if (!dev)
+		return -EINVAL;
+
+	if (!dev->netdev_ops->ndo_flow_get_actions) {
+		dev_put(dev);
+		return -EOPNOTSUPP;
+	}
+
+	a = dev->netdev_ops->ndo_flow_get_actions(dev);
+	if (!a)
+		return -EBUSY;
+
+	msg = net_flow_build_actions_msg(a, dev,
+					 info->snd_portid,
+					 info->snd_seq,
+					 NET_FLOW_TABLE_CMD_GET_ACTIONS);
+	dev_put(dev);
+
+	if (IS_ERR(msg))
+		return PTR_ERR(msg);
+
+	return genlmsg_reply(msg, info);
+}
+
+static int net_flow_put_table(struct net_device *dev,
+			      struct sk_buff *skb,
+			      struct net_flow_table *t)
+{
+	struct nlattr *matches, *actions;
+	int i;
+
+	if (nla_put_string(skb, NET_FLOW_TABLE_ATTR_NAME, t->name) ||
+	    nla_put_u32(skb, NET_FLOW_TABLE_ATTR_UID, t->uid) ||
+	    nla_put_u32(skb, NET_FLOW_TABLE_ATTR_SOURCE, t->source) ||
+	    nla_put_u32(skb, NET_FLOW_TABLE_ATTR_SIZE, t->size))
+		return -EMSGSIZE;
+
+	matches = nla_nest_start(skb, NET_FLOW_TABLE_ATTR_MATCHES);
+	if (!matches)
+		return -EMSGSIZE;
+
+	for (i = 0; t->matches[i].instance; i++)
+		nla_put(skb, NET_FLOW_FIELD_REF,
+			sizeof(struct net_flow_field_ref),
+			&t->matches[i]);
+	nla_nest_end(skb, matches);
+
+	actions = nla_nest_start(skb, NET_FLOW_TABLE_ATTR_ACTIONS);
+	if (!actions)
+		return -EMSGSIZE;
+
+	for (i = 0; t->actions[i]; i++) {
+		if (nla_put_u32(skb,
+				NET_FLOW_ACTION_ATTR_UID,
+				t->actions[i])) {
+			nla_nest_cancel(skb, actions);
+			return -EMSGSIZE;
+		}
+	}
+	nla_nest_end(skb, actions);
+
+	return 0;
+}
+
+static int net_flow_put_tables(struct net_device *dev,
+			       struct sk_buff *skb,
+			       struct net_flow_table **tables)
+{
+	struct nlattr *nest, *t;
+	int i, err = 0;
+
+	nest = nla_nest_start(skb, NET_FLOW_TABLES);
+	if (!nest)
+		return -EMSGSIZE;
+
+	for (i = 0; tables[i]->uid; i++) {
+		t = nla_nest_start(skb, NET_FLOW_TABLE);
+		if (!t) {
+			err = -EMSGSIZE;
+			goto errout;
+		}
+
+		err = net_flow_put_table(dev, skb, tables[i]);
+		if (err) {
+			nla_nest_cancel(skb, t);
+			goto errout;
+		}
+		nla_nest_end(skb, t);
+	}
+	nla_nest_end(skb, nest);
+	return 0;
+errout:
+	nla_nest_cancel(skb, nest);
+	return err;
+}
+
+static struct sk_buff *net_flow_build_tables_msg(struct net_flow_table **t,
+						 struct net_device *dev,
+						 u32 portid, int seq, u8 cmd)
+{
+	struct genlmsghdr *hdr;
+	struct sk_buff *skb;
+	int err = -ENOBUFS;
+
+	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!skb)
+		return ERR_PTR(-ENOBUFS);
+
+	hdr = genlmsg_put(skb, portid, seq, &net_flow_nl_family, 0, cmd);
+	if (!hdr)
+		goto out;
+
+	if (nla_put_u32(skb,
+			NET_FLOW_IDENTIFIER_TYPE,
+			NET_FLOW_IDENTIFIER_IFINDEX) ||
+	    nla_put_u32(skb, NET_FLOW_IDENTIFIER, dev->ifindex)) {
+		err = -ENOBUFS;
+		goto out;
+	}
+
+	err = net_flow_put_tables(dev, skb, t);
+	if (err < 0)
+		goto out;
+
+	err = genlmsg_end(skb, hdr);
+	if (err < 0)
+		goto out;
+
+	return skb;
+out:
+	nlmsg_free(skb);
+	return ERR_PTR(err);
+}
+
+static int net_flow_cmd_get_tables(struct sk_buff *skb,
+				   struct genl_info *info)
+{
+	struct net_flow_table **tables;
+	struct net_device *dev;
+	struct sk_buff *msg;
+
+	dev = net_flow_get_dev(info);
+	if (!dev)
+		return -EINVAL;
+
+	if (!dev->netdev_ops->ndo_flow_get_tables) {
+		dev_put(dev);
+		return -EOPNOTSUPP;
+	}
+
+	tables = dev->netdev_ops->ndo_flow_get_tables(dev);
+	if (!tables) /* transient failure should always have some table */
+		return -EBUSY;
+
+	msg = net_flow_build_tables_msg(tables, dev,
+					info->snd_portid,
+					info->snd_seq,
+					NET_FLOW_TABLE_CMD_GET_TABLES);
+	dev_put(dev);
+
+	if (IS_ERR(msg))
+		return PTR_ERR(msg);
+
+	return genlmsg_reply(msg, info);
+}
+
+static
+int net_flow_put_fields(struct sk_buff *skb, const struct net_flow_header *h)
+{
+	struct net_flow_field *f;
+	int count = h->field_sz;
+	struct nlattr *field;
+
+	for (f = h->fields; count; count--, f++) {
+		field = nla_nest_start(skb, NET_FLOW_FIELD);
+		if (!field)
+			goto field_put_failure;
+
+		if (nla_put_string(skb, NET_FLOW_FIELD_ATTR_NAME, f->name) ||
+		    nla_put_u32(skb, NET_FLOW_FIELD_ATTR_UID, f->uid) ||
+		    nla_put_u32(skb, NET_FLOW_FIELD_ATTR_BITWIDTH, f->bitwidth))
+			goto out;
+
+		nla_nest_end(skb, field);
+	}
+
+	return 0;
+out:
+	nla_nest_cancel(skb, field);
+field_put_failure:
+	return -EMSGSIZE;
+}
+
+static int net_flow_put_headers(struct sk_buff *skb,
+				struct net_flow_header **headers)
+{
+	struct nlattr *nest, *hdr, *fields;
+	struct net_flow_header *h;
+	int i, err;
+
+	nest = nla_nest_start(skb, NET_FLOW_HEADERS);
+	if (!nest)
+		return -EMSGSIZE;
+
+	for (i = 0; headers[i]->uid; i++) {
+		err = -EMSGSIZE;
+		h = headers[i];
+
+		hdr = nla_nest_start(skb, NET_FLOW_HEADER);
+		if (!hdr)
+			goto hdr_put_failure;
+
+		if (nla_put_string(skb, NET_FLOW_HEADER_ATTR_NAME, h->name) ||
+		    nla_put_u32(skb, NET_FLOW_HEADER_ATTR_UID, h->uid))
+			goto attr_put_failure;
+
+		fields = nla_nest_start(skb, NET_FLOW_HEADER_ATTR_FIELDS);
+		if (!fields)
+			goto attr_put_failure;
+
+		err = net_flow_put_fields(skb, h);
+		if (err)
+			goto fields_put_failure;
+
+		nla_nest_end(skb, fields);
+
+		nla_nest_end(skb, hdr);
+	}
+	nla_nest_end(skb, nest);
+
+	return 0;
+fields_put_failure:
+	nla_nest_cancel(skb, fields);
+attr_put_failure:
+	nla_nest_cancel(skb, hdr);
+hdr_put_failure:
+	nla_nest_cancel(skb, nest);
+	return err;
+}
+
+static struct sk_buff *net_flow_build_headers_msg(struct net_flow_header **h,
+						  struct net_device *dev,
+						  u32 portid, int seq, u8 cmd)
+{
+	struct genlmsghdr *hdr;
+	struct sk_buff *skb;
+	int err = -ENOBUFS;
+
+	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!skb)
+		return ERR_PTR(-ENOBUFS);
+
+	hdr = genlmsg_put(skb, portid, seq, &net_flow_nl_family, 0, cmd);
+	if (!hdr)
+		goto out;
+
+	if (nla_put_u32(skb,
+			NET_FLOW_IDENTIFIER_TYPE,
+			NET_FLOW_IDENTIFIER_IFINDEX) ||
+	    nla_put_u32(skb, NET_FLOW_IDENTIFIER, dev->ifindex)) {
+		err = -ENOBUFS;
+		goto out;
+	}
+
+	err = net_flow_put_headers(skb, h);
+	if (err < 0)
+		goto out;
+
+	err = genlmsg_end(skb, hdr);
+	if (err < 0)
+		goto out;
+
+	return skb;
+out:
+	nlmsg_free(skb);
+	return ERR_PTR(err);
+}
+
+static int net_flow_cmd_get_headers(struct sk_buff *skb,
+				    struct genl_info *info)
+{
+	struct net_flow_header **h;
+	struct net_device *dev;
+	struct sk_buff *msg;
+
+	dev = net_flow_get_dev(info);
+	if (!dev)
+		return -EINVAL;
+
+	if (!dev->netdev_ops->ndo_flow_get_headers) {
+		dev_put(dev);
+		return -EOPNOTSUPP;
+	}
+
+	h = dev->netdev_ops->ndo_flow_get_headers(dev);
+	if (!h)
+		return -EBUSY;
+
+	msg = net_flow_build_headers_msg(h, dev,
+					 info->snd_portid,
+					 info->snd_seq,
+					 NET_FLOW_TABLE_CMD_GET_HEADERS);
+	dev_put(dev);
+
+	if (IS_ERR(msg))
+		return PTR_ERR(msg);
+
+	return genlmsg_reply(msg, info);
+}
+
+static int net_flow_put_header_node(struct sk_buff *skb,
+				    struct net_flow_hdr_node *node)
+{
+	struct nlattr *hdrs, *jumps;
+	int i, err;
+
+	if (nla_put_string(skb, NET_FLOW_HEADER_NODE_NAME, node->name) ||
+	    nla_put_u32(skb, NET_FLOW_HEADER_NODE_UID, node->uid))
+		return -EMSGSIZE;
+
+	/* Insert the set of headers that get extracted at this node */
+	hdrs = nla_nest_start(skb, NET_FLOW_HEADER_NODE_HDRS);
+	if (!hdrs)
+		return -EMSGSIZE;
+	for (i = 0; node->hdrs[i]; i++) {
+		if (nla_put_u32(skb, NET_FLOW_HEADER_NODE_HDRS_VALUE,
+				node->hdrs[i])) {
+			nla_nest_cancel(skb, hdrs);
+			return -EMSGSIZE;
+		}
+	}
+	nla_nest_end(skb, hdrs);
+
+	/* Then give the jump table to find next header node in graph */
+	jumps = nla_nest_start(skb, NET_FLOW_HEADER_NODE_JUMP);
+	if (!jumps)
+		return -EMSGSIZE;
+
+	for (i = 0; node->jump[i].node; i++) {
+		err = nla_put(skb, NET_FLOW_JUMP_TABLE_ENTRY,
+			      sizeof(struct net_flow_jump_table),
+			      &node->jump[i]);
+		if (err) {
+			nla_nest_cancel(skb, jumps);
+			return -EMSGSIZE;
+		}
+	}
+	nla_nest_end(skb, jumps);
+
+	return 0;
+}
+
+static int net_flow_put_header_graph(struct sk_buff *skb,
+				     struct net_flow_hdr_node **g)
+{
+	struct nlattr *nodes, *node;
+	int err, i;
+
+	nodes = nla_nest_start(skb, NET_FLOW_HEADER_GRAPH);
+	if (!nodes)
+		return -EMSGSIZE;
+
+	for (i = 0; g[i]->uid; i++) {
+		node = nla_nest_start(skb, NET_FLOW_HEADER_GRAPH_NODE);
+		if (!node) {
+			err = -EMSGSIZE;
+			goto nodes_put_error;
+		}
+
+		err = net_flow_put_header_node(skb, g[i]);
+		if (err)
+			goto node_put_error;
+
+		nla_nest_end(skb, node);
+	}
+
+	nla_nest_end(skb, nodes);
+	return 0;
+node_put_error:
+	nla_nest_cancel(skb, node);
+nodes_put_error:
+	nla_nest_cancel(skb, nodes);
+	return err;
+}
+
+static
+struct sk_buff *net_flow_build_header_graph_msg(struct net_flow_hdr_node **g,
+						struct net_device *dev,
+						u32 portid, int seq, u8 cmd)
+{
+	struct genlmsghdr *hdr;
+	struct sk_buff *skb;
+	int err = -ENOBUFS;
+
+	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!skb)
+		return ERR_PTR(-ENOBUFS);
+
+	hdr = genlmsg_put(skb, portid, seq, &net_flow_nl_family, 0, cmd);
+	if (!hdr)
+		goto out;
+
+	if (nla_put_u32(skb,
+			NET_FLOW_IDENTIFIER_TYPE,
+			NET_FLOW_IDENTIFIER_IFINDEX) ||
+	    nla_put_u32(skb, NET_FLOW_IDENTIFIER, dev->ifindex)) {
+		err = -ENOBUFS;
+		goto out;
+	}
+
+	err = net_flow_put_header_graph(skb, g);
+	if (err < 0)
+		goto out;
+
+	err = genlmsg_end(skb, hdr);
+	if (err < 0)
+		goto out;
+
+	return skb;
+out:
+	nlmsg_free(skb);
+	return ERR_PTR(err);
+}
+
+static int net_flow_cmd_get_header_graph(struct sk_buff *skb,
+					 struct genl_info *info)
+{
+	struct net_flow_hdr_node **h;
+	struct net_device *dev;
+	struct sk_buff *msg;
+
+	dev = net_flow_get_dev(info);
+	if (!dev)
+		return -EINVAL;
+
+	if (!dev->netdev_ops->ndo_flow_get_hdr_graph) {
+		dev_put(dev);
+		return -EOPNOTSUPP;
+	}
+
+	h = dev->netdev_ops->ndo_flow_get_hdr_graph(dev);
+	if (!h)
+		return -EBUSY;
+
+	msg = net_flow_build_header_graph_msg(h, dev,
+					      info->snd_portid,
+					      info->snd_seq,
+					      NET_FLOW_TABLE_CMD_GET_HDR_GRAPH);
+	dev_put(dev);
+
+	if (IS_ERR(msg))
+		return PTR_ERR(msg);
+
+	return genlmsg_reply(msg, info);
+}
+
+static int net_flow_put_table_node(struct sk_buff *skb,
+				   struct net_flow_tbl_node *node)
+{
+	struct nlattr *nest, *jump;
+	int i, err = -EMSGSIZE;
+
+	nest = nla_nest_start(skb, NET_FLOW_TABLE_GRAPH_NODE);
+	if (!nest)
+		return err;
+
+	if (nla_put_u32(skb, NET_FLOW_TABLE_GRAPH_NODE_UID, node->uid) ||
+	    nla_put_u32(skb, NET_FLOW_TABLE_GRAPH_NODE_FLAGS, node->flags))
+		goto node_put_failure;
+
+	jump = nla_nest_start(skb, NET_FLOW_TABLE_GRAPH_NODE_JUMP);
+	if (!jump)
+		goto node_put_failure;
+
+	for (i = 0; node->jump[i].node; i++) {
+		err = nla_put(skb, NET_FLOW_JUMP_TABLE_ENTRY,
+			      sizeof(struct net_flow_jump_table),
+			      &node->jump[i]);
+		if (err)
+			goto jump_put_failure;
+	}
+
+	nla_nest_end(skb, jump);
+	nla_nest_end(skb, nest);
+	return 0;
+jump_put_failure:
+	nla_nest_cancel(skb, jump);
+node_put_failure:
+	nla_nest_cancel(skb, nest);
+	return err;
+}
+
+static int net_flow_put_table_graph(struct sk_buff *skb,
+				    struct net_flow_tbl_node **nodes)
+{
+	struct nlattr *graph;
+	int err, i = 0;
+
+	graph = nla_nest_start(skb, NET_FLOW_TABLE_GRAPH);
+	if (!graph)
+		return -EMSGSIZE;
+
+	for (i = 0; nodes[i]->uid; i++) {
+		err = net_flow_put_table_node(skb, nodes[i]);
+		if (err) {
+			nla_nest_cancel(skb, graph);
+			return -EMSGSIZE;
+		}
+	}
+
+	nla_nest_end(skb, graph);
+	return 0;
+}
+
+static
+struct sk_buff *net_flow_build_graph_msg(struct net_flow_tbl_node **g,
+					 struct net_device *dev,
+					 u32 portid, int seq, u8 cmd)
+{
+	struct genlmsghdr *hdr;
+	struct sk_buff *skb;
+	int err = -ENOBUFS;
+
+	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!skb)
+		return ERR_PTR(-ENOBUFS);
+
+	hdr = genlmsg_put(skb, portid, seq, &net_flow_nl_family, 0, cmd);
+	if (!hdr)
+		goto out;
+
+	if (nla_put_u32(skb,
+			NET_FLOW_IDENTIFIER_TYPE,
+			NET_FLOW_IDENTIFIER_IFINDEX) ||
+	    nla_put_u32(skb, NET_FLOW_IDENTIFIER, dev->ifindex)) {
+		err = -ENOBUFS;
+		goto out;
+	}
+
+	err = net_flow_put_table_graph(skb, g);
+	if (err < 0)
+		goto out;
+
+	err = genlmsg_end(skb, hdr);
+	if (err < 0)
+		goto out;
+
+	return skb;
+out:
+	nlmsg_free(skb);
+	return ERR_PTR(err);
+}
+
+static int net_flow_cmd_get_table_graph(struct sk_buff *skb,
+					struct genl_info *info)
+{
+	struct net_flow_tbl_node **g;
+	struct net_device *dev;
+	struct sk_buff *msg;
+
+	dev = net_flow_get_dev(info);
+	if (!dev)
+		return -EINVAL;
+
+	if (!dev->netdev_ops->ndo_flow_get_tbl_graph) {
+		dev_put(dev);
+		return -EOPNOTSUPP;
+	}
+
+	g = dev->netdev_ops->ndo_flow_get_tbl_graph(dev);
+	if (!g)
+		return -EBUSY;
+
+	msg = net_flow_build_graph_msg(g, dev,
+				       info->snd_portid,
+				       info->snd_seq,
+				       NET_FLOW_TABLE_CMD_GET_TABLE_GRAPH);
+	dev_put(dev);
+
+	if (IS_ERR(msg))
+		return PTR_ERR(msg);
+
+	return genlmsg_reply(msg, info);
+}
+
+static const struct nla_policy net_flow_cmd_policy[NET_FLOW_MAX + 1] = {
+	[NET_FLOW_IDENTIFIER_TYPE] = {.type = NLA_U32, },
+	[NET_FLOW_IDENTIFIER]	   = {.type = NLA_U32, },
+	[NET_FLOW_TABLES]	   = {.type = NLA_NESTED, },
+	[NET_FLOW_HEADERS]	   = {.type = NLA_NESTED, },
+	[NET_FLOW_ACTIONS]	   = {.type = NLA_NESTED, },
+	[NET_FLOW_HEADER_GRAPH]	   = {.type = NLA_NESTED, },
+	[NET_FLOW_TABLE_GRAPH]	   = {.type = NLA_NESTED, },
+};
+
+static const struct genl_ops net_flow_table_nl_ops[] = {
+	{
+		.cmd = NET_FLOW_TABLE_CMD_GET_TABLES,
+		.doit = net_flow_cmd_get_tables,
+		.policy = net_flow_cmd_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
+	{
+		.cmd = NET_FLOW_TABLE_CMD_GET_HEADERS,
+		.doit = net_flow_cmd_get_headers,
+		.policy = net_flow_cmd_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
+	{
+		.cmd = NET_FLOW_TABLE_CMD_GET_ACTIONS,
+		.doit = net_flow_cmd_get_actions,
+		.policy = net_flow_cmd_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
+	{
+		.cmd = NET_FLOW_TABLE_CMD_GET_HDR_GRAPH,
+		.doit = net_flow_cmd_get_header_graph,
+		.policy = net_flow_cmd_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
+	{
+		.cmd = NET_FLOW_TABLE_CMD_GET_TABLE_GRAPH,
+		.doit = net_flow_cmd_get_table_graph,
+		.policy = net_flow_cmd_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
+};
+
+static int __init net_flow_nl_module_init(void)
+{
+	return genl_register_family_with_ops(&net_flow_nl_family,
+					     net_flow_table_nl_ops);
+}
+
+static void net_flow_nl_module_fini(void)
+{
+	genl_unregister_family(&net_flow_nl_family);
+}
+
+module_init(net_flow_nl_module_init);
+module_exit(net_flow_nl_module_fini);
+
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("John Fastabend <john.r.fastabend@intel.com>");
+MODULE_DESCRIPTION("Netlink interface to Flow Tables");
+MODULE_ALIAS_GENL_FAMILY(NET_FLOW_GENL_NAME);
