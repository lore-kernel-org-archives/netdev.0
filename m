From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v2 5/5] net: Add Open vSwitch kernel components.
Date: Mon, 21 Nov 2011 13:30:29 -0800
Message-ID: <1321911029-20707-6-git-send-email-jesse@nicira.com>
References: <1321911029-20707-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1321911029-20707-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Open vSwitch is a multilayer Ethernet switch targeted at virtualized
environments.  In addition to supporting a variety of features
expected in a traditional hardware switch, it enables fine-grained
programmatic extension and flow-based control of the network.
This control is useful in a wide variety of applications but is
particularly important in multi-server virtualization deployments,
which are often characterized by highly dynamic endpoints and the need
to maintain logical abstractions for multiple tenants.

The Open vSwitch datapath provides an in-kernel fast path for packet
forwarding.  It is complemented by a userspace daemon, ovs-vswitchd,
which is able to accept configuration from a variety of sources and
translate it into packet processing rules.

See http://openvswitch.org for more information and userspace
utilities.

Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
v2:
 - Use u64_stats_sync instead of seqcount directly.
 - Always send port deleted notifications to correct namespace.
 - Remove unused variable in dp_notify.c
 - Drop wrappers for accessing data protected by RCU/genl/RTNL
   locks in favor of more general lockdep/sparse checking.
---
 Documentation/networking/00-INDEX        |    2 +
 Documentation/networking/openvswitch.txt |  195 +++
 MAINTAINERS                              |    8 +
 include/linux/openvswitch.h              |  452 +++++++
 net/Kconfig                              |    1 +
 net/Makefile                             |    1 +
 net/openvswitch/Kconfig                  |   28 +
 net/openvswitch/Makefile                 |   14 +
 net/openvswitch/actions.c                |  415 +++++++
 net/openvswitch/datapath.c               | 1878 ++++++++++++++++++++++++++++++
 net/openvswitch/datapath.h               |  125 ++
 net/openvswitch/dp_notify.c              |   67 ++
 net/openvswitch/flow.c                   | 1373 ++++++++++++++++++++++
 net/openvswitch/flow.h                   |  195 +++
 net/openvswitch/vport-internal_dev.c     |  241 ++++
 net/openvswitch/vport-internal_dev.h     |   28 +
 net/openvswitch/vport-netdev.c           |  200 ++++
 net/openvswitch/vport-netdev.h           |   42 +
 net/openvswitch/vport.c                  |  396 +++++++
 net/openvswitch/vport.h                  |  205 ++++
 20 files changed, 5866 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/networking/openvswitch.txt
 create mode 100644 include/linux/openvswitch.h
 create mode 100644 net/openvswitch/Kconfig
 create mode 100644 net/openvswitch/Makefile
 create mode 100644 net/openvswitch/actions.c
 create mode 100644 net/openvswitch/datapath.c
 create mode 100644 net/openvswitch/datapath.h
 create mode 100644 net/openvswitch/dp_notify.c
 create mode 100644 net/openvswitch/flow.c
 create mode 100644 net/openvswitch/flow.h
 create mode 100644 net/openvswitch/vport-internal_dev.c
 create mode 100644 net/openvswitch/vport-internal_dev.h
 create mode 100644 net/openvswitch/vport-netdev.c
 create mode 100644 net/openvswitch/vport-netdev.h
 create mode 100644 net/openvswitch/vport.c
 create mode 100644 net/openvswitch/vport.h

diff --git a/Documentation/networking/00-INDEX b/Documentation/networking/00-INDEX
index bbce121..9ad9dde 100644
--- a/Documentation/networking/00-INDEX
+++ b/Documentation/networking/00-INDEX
@@ -144,6 +144,8 @@ nfc.txt
 	- The Linux Near Field Communication (NFS) subsystem.
 olympic.txt
 	- IBM PCI Pit/Pit-Phy/Olympic Token Ring driver info.
+openvswitch.txt
+	- Open vSwitch developer documentation.
 operstates.txt
 	- Overview of network interface operational states.
 packet_mmap.txt
diff --git a/Documentation/networking/openvswitch.txt b/Documentation/networking/openvswitch.txt
new file mode 100644
index 0000000..b8a048b
--- /dev/null
+++ b/Documentation/networking/openvswitch.txt
@@ -0,0 +1,195 @@
+Open vSwitch datapath developer documentation
+=============================================
+
+The Open vSwitch kernel module allows flexible userspace control over
+flow-level packet processing on selected network devices.  It can be
+used to implement a plain Ethernet switch, network device bonding,
+VLAN processing, network access control, flow-based network control,
+and so on.
+
+The kernel module implements multiple "datapaths" (analogous to
+bridges), each of which can have multiple "vports" (analogous to ports
+within a bridge).  Each datapath also has associated with it a "flow
+table" that userspace populates with "flows" that map from keys based
+on packet headers and metadata to sets of actions.  The most common
+action forwards the packet to another vport; other actions are also
+implemented.
+
+When a packet arrives on a vport, the kernel module processes it by
+extracting its flow key and looking it up in the flow table.  If there
+is a matching flow, it executes the associated actions.  If there is
+no match, it queues the packet to userspace for processing (as part of
+its processing, userspace will likely set up a flow to handle further
+packets of the same type entirely in-kernel).
+
+
+Flow key compatibility
+----------------------
+
+Network protocols evolve over time.  New protocols become important
+and existing protocols lose their prominence.  For the Open vSwitch
+kernel module to remain relevant, it must be possible for newer
+versions to parse additional protocols as part of the flow key.  It
+might even be desirable, someday, to drop support for parsing
+protocols that have become obsolete.  Therefore, the Netlink interface
+to Open vSwitch is designed to allow carefully written userspace
+applications to work with any version of the flow key, past or future.
+
+To support this forward and backward compatibility, whenever the
+kernel module passes a packet to userspace, it also passes along the
+flow key that it parsed from the packet.  Userspace then extracts its
+own notion of a flow key from the packet and compares it against the
+kernel-provided version:
+
+    - If userspace's notion of the flow key for the packet matches the
+      kernel's, then nothing special is necessary.
+
+    - If the kernel's flow key includes more fields than the userspace
+      version of the flow key, for example if the kernel decoded IPv6
+      headers but userspace stopped at the Ethernet type (because it
+      does not understand IPv6), then again nothing special is
+      necessary.  Userspace can still set up a flow in the usual way,
+      as long as it uses the kernel-provided flow key to do it.
+
+    - If the userspace flow key includes more fields than the
+      kernel's, for example if userspace decoded an IPv6 header but
+      the kernel stopped at the Ethernet type, then userspace can
+      forward the packet manually, without setting up a flow in the
+      kernel.  This case is bad for performance because every packet
+      that the kernel considers part of the flow must go to userspace,
+      but the forwarding behavior is correct.  (If userspace can
+      determine that the values of the extra fields would not affect
+      forwarding behavior, then it could set up a flow anyway.)
+
+How flow keys evolve over time is important to making this work, so
+the following sections go into detail.
+
+
+Flow key format
+---------------
+
+A flow key is passed over a Netlink socket as a sequence of Netlink
+attributes.  Some attributes represent packet metadata, defined as any
+information about a packet that cannot be extracted from the packet
+itself, e.g. the vport on which the packet was received.  Most
+attributes, however, are extracted from headers within the packet,
+e.g. source and destination addresses from Ethernet, IP, or TCP
+headers.
+
+The <linux/openvswitch.h> header file defines the exact format of the
+flow key attributes.  For informal explanatory purposes here, we write
+them as comma-separated strings, with parentheses indicating arguments
+and nesting.  For example, the following could represent a flow key
+corresponding to a TCP packet that arrived on vport 1:
+
+    in_port(1), eth(src=e0:91:f5:21:d0:b2, dst=00:02:e3:0f:80:a4),
+    eth_type(0x0800), ipv4(src=172.16.0.20, dst=172.18.0.52, proto=17, tos=0,
+    frag=no), tcp(src=49163, dst=80)
+
+Often we ellipsize arguments not important to the discussion, e.g.:
+
+    in_port(1), eth(...), eth_type(0x0800), ipv4(...), tcp(...)
+
+
+Basic rule for evolving flow keys
+---------------------------------
+
+Some care is needed to really maintain forward and backward
+compatibility for applications that follow the rules listed under
+"Flow key compatibility" above.
+
+The basic rule is obvious:
+
+    ------------------------------------------------------------------
+    New network protocol support must only supplement existing flow
+    key attributes.  It must not change the meaning of already defined
+    flow key attributes.
+    ------------------------------------------------------------------
+
+This rule does have less-obvious consequences so it is worth working
+through a few examples.  Suppose, for example, that the kernel module
+did not already implement VLAN parsing.  Instead, it just interpreted
+the 802.1Q TPID (0x8100) as the Ethertype then stopped parsing the
+packet.  The flow key for any packet with an 802.1Q header would look
+essentially like this, ignoring metadata:
+
+    eth(...), eth_type(0x8100)
+
+Naively, to add VLAN support, it makes sense to add a new "vlan" flow
+key attribute to contain the VLAN tag, then continue to decode the
+encapsulated headers beyond the VLAN tag using the existing field
+definitions.  With this change, an TCP packet in VLAN 10 would have a
+flow key much like this:
+
+    eth(...), vlan(vid=10, pcp=0), eth_type(0x0800), ip(proto=6, ...), tcp(...)
+
+But this change would negatively affect a userspace application that
+has not been updated to understand the new "vlan" flow key attribute.
+The application could, following the flow compatibility rules above,
+ignore the "vlan" attribute that it does not understand and therefore
+assume that the flow contained IP packets.  This is a bad assumption
+(the flow only contains IP packets if one parses and skips over the
+802.1Q header) and it could cause the application's behavior to change
+across kernel versions even though it follows the compatibility rules.
+
+The solution is to use a set of nested attributes.  This is, for
+example, why 802.1Q support uses nested attributes.  A TCP packet in
+VLAN 10 is actually expressed as:
+
+    eth(...), eth_type(0x8100), vlan(vid=10, pcp=0), encap(eth_type(0x0800),
+    ip(proto=6, ...), tcp(...)))
+
+Notice how the "eth_type", "ip", and "tcp" flow key attributes are
+nested inside the "encap" attribute.  Thus, an application that does
+not understand the "vlan" key will not see either of those attributes
+and therefore will not misinterpret them.  (Also, the outer eth_type
+is still 0x8100, not changed to 0x0800.)
+
+Handling malformed packets
+--------------------------
+
+Don't drop packets in the kernel for malformed protocol headers, bad
+checksums, etc.  This would prevent userspace from implementing a
+simple Ethernet switch that forwards every packet.
+
+Instead, in such a case, include an attribute with "empty" content.
+It doesn't matter if the empty content could be valid protocol values,
+as long as those values are rarely seen in practice, because userspace
+can always forward all packets with those values to userspace and
+handle them individually.
+
+For example, consider a packet that contains an IP header that
+indicates protocol 6 for TCP, but which is truncated just after the IP
+header, so that the TCP header is missing.  The flow key for this
+packet would include a tcp attribute with all-zero src and dst, like
+this:
+
+    eth(...), eth_type(0x0800), ip(proto=6, ...), tcp(src=0, dst=0)
+
+As another example, consider a packet with an Ethernet type of 0x8100,
+indicating that a VLAN TCI should follow, but which is truncated just
+after the Ethernet type.  The flow key for this packet would include
+an all-zero-bits vlan and an empty encap attribute, like this:
+
+    eth(...), eth_type(0x8100), vlan(0), encap()
+
+Unlike a TCP packet with source and destination ports 0, an
+all-zero-bits VLAN TCI is not that rare, so the CFI bit (aka
+VLAN_TAG_PRESENT inside the kernel) is ordinarily set in a vlan
+attribute expressly to allow this situation to be distinguished.
+Thus, the flow key in this second example unambiguously indicates a
+missing or malformed VLAN TCI.
+
+Other rules
+-----------
+
+The other rules for flow keys are much less subtle:
+
+    - Duplicate attributes are not allowed at a given nesting level.
+
+    - Ordering of attributes is not significant.
+
+    - When the kernel sends a given flow key to userspace, it always
+      composes it the same way.  This allows userspace to hash and
+      compare entire flow keys that it may not be able to fully
+      interpret.
diff --git a/MAINTAINERS b/MAINTAINERS
index 717d9e9..019aed5 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4852,6 +4852,14 @@ S:	Maintained
 T:	git git://openrisc.net/~jonas/linux
 F:	arch/openrisc
 
+OPENVSWITCH
+M:	Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
+L:	dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
+W:	http://openvswitch.org
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/jesse/openvswitch.git
+S:	Maintained
+F:	net/openvswitch/
+
 OPL4 DRIVER
 M:	Clemens Ladisch <clemens-P6GI/4k7KOmELgA04lAiVw@public.gmane.org>
 L:	alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org (moderated for non-subscribers)
diff --git a/include/linux/openvswitch.h b/include/linux/openvswitch.h
new file mode 100644
index 0000000..eb1efa5
--- /dev/null
+++ b/include/linux/openvswitch.h
@@ -0,0 +1,452 @@
+/*
+ * Copyright (c) 2007-2011 Nicira Networks.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ */
+
+#ifndef _LINUX_OPENVSWITCH_H
+#define _LINUX_OPENVSWITCH_H 1
+
+#include <linux/types.h>
+
+/**
+ * struct ovs_header - header for OVS Generic Netlink messages.
+ * @dp_ifindex: ifindex of local port for datapath (0 to make a request not
+ * specific to a datapath).
+ *
+ * Attributes following the header are specific to a particular OVS Generic
+ * Netlink family, but all of the OVS families use this header.
+ */
+
+struct ovs_header {
+	int dp_ifindex;
+};
+
+/* Datapaths. */
+
+#define OVS_DATAPATH_FAMILY  "ovs_datapath"
+#define OVS_DATAPATH_MCGROUP "ovs_datapath"
+#define OVS_DATAPATH_VERSION 0x1
+
+enum ovs_datapath_cmd {
+	OVS_DP_CMD_UNSPEC,
+	OVS_DP_CMD_NEW,
+	OVS_DP_CMD_DEL,
+	OVS_DP_CMD_GET,
+	OVS_DP_CMD_SET
+};
+
+/**
+ * enum ovs_datapath_attr - attributes for %OVS_DP_* commands.
+ * @OVS_DP_ATTR_NAME: Name of the network device that serves as the "local
+ * port".  This is the name of the network device whose dp_ifindex is given in
+ * the &struct ovs_header.  Always present in notifications.  Required in
+ * %OVS_DP_NEW requests.  May be used as an alternative to specifying
+ * dp_ifindex in other requests (with a dp_ifindex of 0).
+ * @OVS_DP_ATTR_UPCALL_PID: The Netlink socket in userspace that is initially
+ * set on the datapath port (for OVS_ACTION_ATTR_MISS).  Only valid on
+ * %OVS_DP_CMD_NEW requests. A value of zero indicates that upcalls should
+ * not be sent.
+ * @OVS_DP_ATTR_STATS: Statistics about packets that have passed through the
+ * datapath.  Always present in notifications.
+ *
+ * These attributes follow the &struct ovs_header within the Generic Netlink
+ * payload for %OVS_DP_* commands.
+ */
+enum ovs_datapath_attr {
+	OVS_DP_ATTR_UNSPEC,
+	OVS_DP_ATTR_NAME,       /* name of dp_ifindex netdev */
+	OVS_DP_ATTR_UPCALL_PID, /* Netlink PID to receive upcalls */
+	OVS_DP_ATTR_STATS,      /* struct ovs_dp_stats */
+	__OVS_DP_ATTR_MAX
+};
+
+#define OVS_DP_ATTR_MAX (__OVS_DP_ATTR_MAX - 1)
+
+struct ovs_dp_stats {
+	__u64 n_hit;             /* Number of flow table matches. */
+	__u64 n_missed;          /* Number of flow table misses. */
+	__u64 n_lost;            /* Number of misses not sent to userspace. */
+	__u64 n_flows;           /* Number of flows present */
+};
+
+struct ovs_vport_stats {
+	__u64   rx_packets;		/* total packets received       */
+	__u64   tx_packets;		/* total packets transmitted    */
+	__u64   rx_bytes;		/* total bytes received         */
+	__u64   tx_bytes;		/* total bytes transmitted      */
+	__u64   rx_errors;		/* bad packets received         */
+	__u64   tx_errors;		/* packet transmit problems     */
+	__u64   rx_dropped;		/* no space in linux buffers    */
+	__u64   tx_dropped;		/* no space available in linux  */
+};
+
+/* Fixed logical ports. */
+#define OVSP_LOCAL      ((__u16)0)
+
+/* Packet transfer. */
+
+#define OVS_PACKET_FAMILY "ovs_packet"
+#define OVS_PACKET_VERSION 0x1
+
+enum ovs_packet_cmd {
+	OVS_PACKET_CMD_UNSPEC,
+
+	/* Kernel-to-user notifications. */
+	OVS_PACKET_CMD_MISS,    /* Flow table miss. */
+	OVS_PACKET_CMD_ACTION,  /* OVS_ACTION_ATTR_USERSPACE action. */
+
+	/* Userspace commands. */
+	OVS_PACKET_CMD_EXECUTE  /* Apply actions to a packet. */
+};
+
+/**
+ * enum ovs_packet_attr - attributes for %OVS_PACKET_* commands.
+ * @OVS_PACKET_ATTR_PACKET: Present for all notifications.  Contains the entire
+ * packet as received, from the start of the Ethernet header onward.  For
+ * %OVS_PACKET_CMD_ACTION, %OVS_PACKET_ATTR_PACKET reflects changes made by
+ * actions preceding %OVS_ACTION_ATTR_USERSPACE, but %OVS_PACKET_ATTR_KEY is
+ * the flow key extracted from the packet as originally received.
+ * @OVS_PACKET_ATTR_KEY: Present for all notifications.  Contains the flow key
+ * extracted from the packet as nested %OVS_KEY_ATTR_* attributes.  This allows
+ * userspace to adapt its flow setup strategy by comparing its notion of the
+ * flow key against the kernel's.
+ * @OVS_PACKET_ATTR_ACTIONS: Contains actions for the packet.  Used
+ * for %OVS_PACKET_CMD_EXECUTE.  It has nested %OVS_ACTION_ATTR_* attributes.
+ * @OVS_PACKET_ATTR_USERDATA: Present for an %OVS_PACKET_CMD_ACTION
+ * notification if the %OVS_ACTION_ATTR_USERSPACE action specified an
+ * %OVS_USERSPACE_ATTR_USERDATA attribute.
+ *
+ * These attributes follow the &struct ovs_header within the Generic Netlink
+ * payload for %OVS_PACKET_* commands.
+ */
+enum ovs_packet_attr {
+	OVS_PACKET_ATTR_UNSPEC,
+	OVS_PACKET_ATTR_PACKET,      /* Packet data. */
+	OVS_PACKET_ATTR_KEY,         /* Nested OVS_KEY_ATTR_* attributes. */
+	OVS_PACKET_ATTR_ACTIONS,     /* Nested OVS_ACTION_ATTR_* attributes. */
+	OVS_PACKET_ATTR_USERDATA,    /* u64 OVS_ACTION_ATTR_USERSPACE arg. */
+	__OVS_PACKET_ATTR_MAX
+};
+
+#define OVS_PACKET_ATTR_MAX (__OVS_PACKET_ATTR_MAX - 1)
+
+/* Virtual ports. */
+
+#define OVS_VPORT_FAMILY  "ovs_vport"
+#define OVS_VPORT_MCGROUP "ovs_vport"
+#define OVS_VPORT_VERSION 0x1
+
+enum ovs_vport_cmd {
+	OVS_VPORT_CMD_UNSPEC,
+	OVS_VPORT_CMD_NEW,
+	OVS_VPORT_CMD_DEL,
+	OVS_VPORT_CMD_GET,
+	OVS_VPORT_CMD_SET
+};
+
+enum ovs_vport_type {
+	OVS_VPORT_TYPE_UNSPEC,
+	OVS_VPORT_TYPE_NETDEV,   /* network device */
+	OVS_VPORT_TYPE_INTERNAL, /* network device implemented by datapath */
+	__OVS_VPORT_TYPE_MAX
+};
+
+#define OVS_VPORT_TYPE_MAX (__OVS_VPORT_TYPE_MAX - 1)
+
+/**
+ * enum ovs_vport_attr - attributes for %OVS_VPORT_* commands.
+ * @OVS_VPORT_ATTR_PORT_NO: 32-bit port number within datapath.
+ * @OVS_VPORT_ATTR_TYPE: 32-bit %OVS_VPORT_TYPE_* constant describing the type
+ * of vport.
+ * @OVS_VPORT_ATTR_NAME: Name of vport.  For a vport based on a network device
+ * this is the name of the network device.  Maximum length %IFNAMSIZ-1 bytes
+ * plus a null terminator.
+ * @OVS_VPORT_ATTR_OPTIONS: Vport-specific configuration information.
+ * @OVS_VPORT_ATTR_UPCALL_PID: The Netlink socket in userspace that
+ * OVS_PACKET_CMD_MISS upcalls will be directed to for packets received on
+ * this port.  A value of zero indicates that upcalls should not be sent.
+ * @OVS_VPORT_ATTR_STATS: A &struct ovs_vport_stats giving statistics for
+ * packets sent or received through the vport.
+ *
+ * These attributes follow the &struct ovs_header within the Generic Netlink
+ * payload for %OVS_VPORT_* commands.
+ *
+ * For %OVS_VPORT_CMD_NEW requests, the %OVS_VPORT_ATTR_TYPE and
+ * %OVS_VPORT_ATTR_NAME attributes are required.  %OVS_VPORT_ATTR_PORT_NO is
+ * optional; if not specified a free port number is automatically selected.
+ * Whether %OVS_VPORT_ATTR_OPTIONS is required or optional depends on the type
+ * of vport.
+ * and other attributes are ignored.
+ *
+ * For other requests, if %OVS_VPORT_ATTR_NAME is specified then it is used to
+ * look up the vport to operate on; otherwise dp_idx from the &struct
+ * ovs_header plus %OVS_VPORT_ATTR_PORT_NO determine the vport.
+ */
+enum ovs_vport_attr {
+	OVS_VPORT_ATTR_UNSPEC,
+	OVS_VPORT_ATTR_PORT_NO,	/* u32 port number within datapath */
+	OVS_VPORT_ATTR_TYPE,	/* u32 OVS_VPORT_TYPE_* constant. */
+	OVS_VPORT_ATTR_NAME,	/* string name, up to IFNAMSIZ bytes long */
+	OVS_VPORT_ATTR_OPTIONS, /* nested attributes, varies by vport type */
+	OVS_VPORT_ATTR_UPCALL_PID, /* u32 Netlink PID to receive upcalls */
+	OVS_VPORT_ATTR_STATS,	/* struct ovs_vport_stats */
+	__OVS_VPORT_ATTR_MAX
+};
+
+#define OVS_VPORT_ATTR_MAX (__OVS_VPORT_ATTR_MAX - 1)
+
+/* Flows. */
+
+#define OVS_FLOW_FAMILY  "ovs_flow"
+#define OVS_FLOW_MCGROUP "ovs_flow"
+#define OVS_FLOW_VERSION 0x1
+
+enum ovs_flow_cmd {
+	OVS_FLOW_CMD_UNSPEC,
+	OVS_FLOW_CMD_NEW,
+	OVS_FLOW_CMD_DEL,
+	OVS_FLOW_CMD_GET,
+	OVS_FLOW_CMD_SET
+};
+
+struct ovs_flow_stats {
+	__u64 n_packets;         /* Number of matched packets. */
+	__u64 n_bytes;           /* Number of matched bytes. */
+};
+
+enum ovs_key_attr {
+	OVS_KEY_ATTR_UNSPEC,
+	OVS_KEY_ATTR_ENCAP,	/* Nested set of encapsulated attributes. */
+	OVS_KEY_ATTR_PRIORITY,  /* u32 skb->priority */
+	OVS_KEY_ATTR_IN_PORT,   /* u32 OVS dp port number */
+	OVS_KEY_ATTR_ETHERNET,  /* struct ovs_key_ethernet */
+	OVS_KEY_ATTR_VLAN,	/* be16 VLAN TCI */
+	OVS_KEY_ATTR_ETHERTYPE,	/* be16 Ethernet type */
+	OVS_KEY_ATTR_IPV4,      /* struct ovs_key_ipv4 */
+	OVS_KEY_ATTR_IPV6,      /* struct ovs_key_ipv6 */
+	OVS_KEY_ATTR_TCP,       /* struct ovs_key_tcp */
+	OVS_KEY_ATTR_UDP,       /* struct ovs_key_udp */
+	OVS_KEY_ATTR_ICMP,      /* struct ovs_key_icmp */
+	OVS_KEY_ATTR_ICMPV6,    /* struct ovs_key_icmpv6 */
+	OVS_KEY_ATTR_ARP,       /* struct ovs_key_arp */
+	OVS_KEY_ATTR_ND,        /* struct ovs_key_nd */
+	__OVS_KEY_ATTR_MAX
+};
+
+#define OVS_KEY_ATTR_MAX (__OVS_KEY_ATTR_MAX - 1)
+
+/**
+ * enum ovs_frag_type - IPv4 and IPv6 fragment type
+ * @OVS_FRAG_TYPE_NONE: Packet is not a fragment.
+ * @OVS_FRAG_TYPE_FIRST: Packet is a fragment with offset 0.
+ * @OVS_FRAG_TYPE_LATER: Packet is a fragment with nonzero offset.
+ *
+ * Used as the @ipv4_frag in &struct ovs_key_ipv4 and as @ipv6_frag &struct
+ * ovs_key_ipv6.
+ */
+enum ovs_frag_type {
+	OVS_FRAG_TYPE_NONE,
+	OVS_FRAG_TYPE_FIRST,
+	OVS_FRAG_TYPE_LATER,
+	__OVS_FRAG_TYPE_MAX
+};
+
+#define OVS_FRAG_TYPE_MAX (__OVS_FRAG_TYPE_MAX - 1)
+
+struct ovs_key_ethernet {
+	__u8	 eth_src[6];
+	__u8	 eth_dst[6];
+};
+
+struct ovs_key_ipv4 {
+	__be32 ipv4_src;
+	__be32 ipv4_dst;
+	__u8   ipv4_proto;
+	__u8   ipv4_tos;
+	__u8   ipv4_ttl;
+	__u8   ipv4_frag;	/* One of OVS_FRAG_TYPE_*. */
+};
+
+struct ovs_key_ipv6 {
+	__be32 ipv6_src[4];
+	__be32 ipv6_dst[4];
+	__be32 ipv6_label;	/* 20-bits in least-significant bits. */
+	__u8   ipv6_proto;
+	__u8   ipv6_tclass;
+	__u8   ipv6_hlimit;
+	__u8   ipv6_frag;	/* One of OVS_FRAG_TYPE_*. */
+};
+
+struct ovs_key_tcp {
+	__be16 tcp_src;
+	__be16 tcp_dst;
+};
+
+struct ovs_key_udp {
+	__be16 udp_src;
+	__be16 udp_dst;
+};
+
+struct ovs_key_icmp {
+	__u8 icmp_type;
+	__u8 icmp_code;
+};
+
+struct ovs_key_icmpv6 {
+	__u8 icmpv6_type;
+	__u8 icmpv6_code;
+};
+
+struct ovs_key_arp {
+	__be32 arp_sip;
+	__be32 arp_tip;
+	__be16 arp_op;
+	__u8   arp_sha[6];
+	__u8   arp_tha[6];
+};
+
+struct ovs_key_nd {
+	__u32 nd_target[4];
+	__u8  nd_sll[6];
+	__u8  nd_tll[6];
+};
+
+/**
+ * enum ovs_flow_attr - attributes for %OVS_FLOW_* commands.
+ * @OVS_FLOW_ATTR_KEY: Nested %OVS_KEY_ATTR_* attributes specifying the flow
+ * key.  Always present in notifications.  Required for all requests (except
+ * dumps).
+ * @OVS_FLOW_ATTR_ACTIONS: Nested %OVS_ACTION_ATTR_* attributes specifying
+ * the actions to take for packets that match the key.  Always present in
+ * notifications.  Required for %OVS_FLOW_CMD_NEW requests, optional for
+ * %OVS_FLOW_CMD_SET requests.
+ * @OVS_FLOW_ATTR_STATS: &struct ovs_flow_stats giving statistics for this
+ * flow.  Present in notifications if the stats would be nonzero.  Ignored in
+ * requests.
+ * @OVS_FLOW_ATTR_TCP_FLAGS: An 8-bit value giving the OR'd value of all of the
+ * TCP flags seen on packets in this flow.  Only present in notifications for
+ * TCP flows, and only if it would be nonzero.  Ignored in requests.
+ * @OVS_FLOW_ATTR_USED: A 64-bit integer giving the time, in milliseconds on
+ * the system monotonic clock, at which a packet was last processed for this
+ * flow.  Only present in notifications if a packet has been processed for this
+ * flow.  Ignored in requests.
+ * @OVS_FLOW_ATTR_CLEAR: If present in a %OVS_FLOW_CMD_SET request, clears the
+ * last-used time, accumulated TCP flags, and statistics for this flow.
+ * Otherwise ignored in requests.  Never present in notifications.
+ *
+ * These attributes follow the &struct ovs_header within the Generic Netlink
+ * payload for %OVS_FLOW_* commands.
+ */
+enum ovs_flow_attr {
+	OVS_FLOW_ATTR_UNSPEC,
+	OVS_FLOW_ATTR_KEY,       /* Sequence of OVS_KEY_ATTR_* attributes. */
+	OVS_FLOW_ATTR_ACTIONS,   /* Nested OVS_ACTION_ATTR_* attributes. */
+	OVS_FLOW_ATTR_STATS,     /* struct ovs_flow_stats. */
+	OVS_FLOW_ATTR_TCP_FLAGS, /* 8-bit OR'd TCP flags. */
+	OVS_FLOW_ATTR_USED,      /* u64 msecs last used in monotonic time. */
+	OVS_FLOW_ATTR_CLEAR,     /* Flag to clear stats, tcp_flags, used. */
+	__OVS_FLOW_ATTR_MAX
+};
+
+#define OVS_FLOW_ATTR_MAX (__OVS_FLOW_ATTR_MAX - 1)
+
+/**
+ * enum ovs_sample_attr - Attributes for %OVS_ACTION_ATTR_SAMPLE action.
+ * @OVS_SAMPLE_ATTR_PROBABILITY: 32-bit fraction of packets to sample with
+ * @OVS_ACTION_ATTR_SAMPLE.  A value of 0 samples no packets, a value of
+ * %UINT32_MAX samples all packets and intermediate values sample intermediate
+ * fractions of packets.
+ * @OVS_SAMPLE_ATTR_ACTIONS: Set of actions to execute in sampling event.
+ * Actions are passed as nested attributes.
+ *
+ * Executes the specified actions with the given probability on a per-packet
+ * basis.
+ */
+enum ovs_sample_attr {
+	OVS_SAMPLE_ATTR_UNSPEC,
+	OVS_SAMPLE_ATTR_PROBABILITY, /* u32 number */
+	OVS_SAMPLE_ATTR_ACTIONS,     /* Nested OVS_ACTION_ATTR_* attributes. */
+	__OVS_SAMPLE_ATTR_MAX,
+};
+
+#define OVS_SAMPLE_ATTR_MAX (__OVS_SAMPLE_ATTR_MAX - 1)
+
+/**
+ * enum ovs_userspace_attr - Attributes for %OVS_ACTION_ATTR_USERSPACE action.
+ * @OVS_USERSPACE_ATTR_PID: u32 Netlink PID to which the %OVS_PACKET_CMD_ACTION
+ * message should be sent.  Required.
+ * @OVS_USERSPACE_ATTR_USERDATA: If present, its u64 argument is copied to the
+ * %OVS_PACKET_CMD_ACTION message as %OVS_PACKET_ATTR_USERDATA,
+ */
+enum ovs_userspace_attr {
+	OVS_USERSPACE_ATTR_UNSPEC,
+	OVS_USERSPACE_ATTR_PID,	      /* u32 Netlink PID to receive upcalls. */
+	OVS_USERSPACE_ATTR_USERDATA,  /* u64 optional user-specified cookie. */
+	__OVS_USERSPACE_ATTR_MAX
+};
+
+#define OVS_USERSPACE_ATTR_MAX (__OVS_USERSPACE_ATTR_MAX - 1)
+
+/**
+ * struct ovs_action_push_vlan - %OVS_ACTION_ATTR_PUSH_VLAN action argument.
+ * @vlan_tpid: Tag protocol identifier (TPID) to push.
+ * @vlan_tci: Tag control identifier (TCI) to push.  The CFI bit must be set
+ * (but it will not be set in the 802.1Q header that is pushed).
+ *
+ * The @vlan_tpid value is typically %ETH_P_8021Q.  The only acceptable TPID
+ * values are those that the kernel module also parses as 802.1Q headers, to
+ * prevent %OVS_ACTION_ATTR_PUSH_VLAN followed by %OVS_ACTION_ATTR_POP_VLAN
+ * from having surprising results.
+ */
+struct ovs_action_push_vlan {
+	__be16 vlan_tpid;	/* 802.1Q TPID. */
+	__be16 vlan_tci;	/* 802.1Q TCI (VLAN ID and priority). */
+};
+
+/**
+ * enum ovs_action_attr - Action types.
+ *
+ * @OVS_ACTION_ATTR_OUTPUT: Output packet to port.
+ * @OVS_ACTION_ATTR_USERSPACE: Send packet to userspace according to nested
+ * %OVS_USERSPACE_ATTR_* attributes.
+ * @OVS_ACTION_ATTR_SET: Replaces the contents of an existing header.  The
+ * single nested %OVS_KEY_ATTR_* attribute specifies a header to modify and its
+ * value.
+ * @OVS_ACTION_ATTR_PUSH_VLAN: Push a new outermost 802.1Q header onto the
+ * packet.
+ * @OVS_ACTION_ATTR_POP_VLAN: Pop the outermost 802.1Q header off the packet.
+ * @OVS_ACTION_ATTR_SAMPLE: Probabilitically executes actions, as specified in
+ * the nested %OVS_SAMPLE_ATTR_* attributes.
+ *
+ * Only a single header can be set with a single %OVS_ACTION_ATTR_SET.  Not all
+ * fields within a header are modifiable, e.g. the IPv4 protocol and fragment
+ * type may not be changed.
+ */
+
+enum ovs_action_attr {
+	OVS_ACTION_ATTR_UNSPEC,
+	OVS_ACTION_ATTR_OUTPUT,	      /* u32 port number. */
+	OVS_ACTION_ATTR_USERSPACE,    /* Nested OVS_USERSPACE_ATTR_*. */
+	OVS_ACTION_ATTR_SET,          /* One nested OVS_KEY_ATTR_*. */
+	OVS_ACTION_ATTR_PUSH_VLAN,    /* struct ovs_action_push_vlan. */
+	OVS_ACTION_ATTR_POP_VLAN,     /* No argument. */
+	OVS_ACTION_ATTR_SAMPLE,       /* Nested OVS_SAMPLE_ATTR_*. */
+	__OVS_ACTION_ATTR_MAX
+};
+
+#define OVS_ACTION_ATTR_MAX (__OVS_ACTION_ATTR_MAX - 1)
+
+#endif /* _LINUX_OPENVSWITCH_H */
diff --git a/net/Kconfig b/net/Kconfig
index a073148..2c4e126 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -215,6 +215,7 @@ source "net/sched/Kconfig"
 source "net/dcb/Kconfig"
 source "net/dns_resolver/Kconfig"
 source "net/batman-adv/Kconfig"
+source "net/openvswitch/Kconfig"
 
 config RPS
 	boolean
diff --git a/net/Makefile b/net/Makefile
index acdde49..ad432fa 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -69,3 +69,4 @@ obj-$(CONFIG_DNS_RESOLVER)	+= dns_resolver/
 obj-$(CONFIG_CEPH_LIB)		+= ceph/
 obj-$(CONFIG_BATMAN_ADV)	+= batman-adv/
 obj-$(CONFIG_NFC)		+= nfc/
+obj-$(CONFIG_OPENVSWITCH)	+= openvswitch/
diff --git a/net/openvswitch/Kconfig b/net/openvswitch/Kconfig
new file mode 100644
index 0000000..d9ea33c
--- /dev/null
+++ b/net/openvswitch/Kconfig
@@ -0,0 +1,28 @@
+#
+# Open vSwitch
+#
+
+config OPENVSWITCH
+	tristate "Open vSwitch"
+	---help---
+	  Open vSwitch is a multilayer Ethernet switch targeted at virtualized
+	  environments.  In addition to supporting a variety of features
+	  expected in a traditional hardware switch, it enables fine-grained
+	  programmatic extension and flow-based control of the network.  This
+	  control is useful in a wide variety of applications but is
+	  particularly important in multi-server virtualization deployments,
+	  which are often characterized by highly dynamic endpoints and the
+	  need to maintain logical abstractions for multiple tenants.
+
+	  The Open vSwitch datapath provides an in-kernel fast path for packet
+	  forwarding.  It is complemented by a userspace daemon, ovs-vswitchd,
+	  which is able to accept configuration from a variety of sources and
+	  translate it into packet processing rules.
+
+	  See http://openvswitch.org for more information and userspace
+	  utilities.
+
+	  To compile this code as a module, choose M here: the module will be
+	  called openvswitch.
+
+	  If unsure, say N.
diff --git a/net/openvswitch/Makefile b/net/openvswitch/Makefile
new file mode 100644
index 0000000..15e7384
--- /dev/null
+++ b/net/openvswitch/Makefile
@@ -0,0 +1,14 @@
+#
+# Makefile for Open vSwitch.
+#
+
+obj-$(CONFIG_OPENVSWITCH) += openvswitch.o
+
+openvswitch-y := \
+	actions.o \
+	datapath.o \
+	dp_notify.o \
+	flow.o \
+	vport.o \
+	vport-internal_dev.o \
+	vport-netdev.o \
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
new file mode 100644
index 0000000..e824dca
--- /dev/null
+++ b/net/openvswitch/actions.c
@@ -0,0 +1,415 @@
+/*
+ * Copyright (c) 2007-2011 Nicira Networks.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/skbuff.h>
+#include <linux/in.h>
+#include <linux/ip.h>
+#include <linux/openvswitch.h>
+#include <linux/tcp.h>
+#include <linux/udp.h>
+#include <linux/in6.h>
+#include <linux/if_arp.h>
+#include <linux/if_vlan.h>
+#include <net/ip.h>
+#include <net/checksum.h>
+#include <net/dsfield.h>
+
+#include "datapath.h"
+#include "vport.h"
+
+static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
+			const struct nlattr *attr, int len, bool keep_skb);
+
+static int make_writable(struct sk_buff *skb, int write_len)
+{
+	if (!skb_cloned(skb) || skb_clone_writable(skb, write_len))
+		return 0;
+
+	return pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
+}
+
+/* remove VLAN header from packet and update csum accrodingly. */
+static int __pop_vlan_tci(struct sk_buff *skb, __be16 *current_tci)
+{
+	struct vlan_hdr *vhdr;
+	int err;
+
+	err = make_writable(skb, VLAN_ETH_HLEN);
+	if (unlikely(err))
+		return err;
+
+	if (skb->ip_summed == CHECKSUM_COMPLETE)
+		skb->csum = csum_sub(skb->csum, csum_partial(skb->data
+					+ ETH_HLEN, VLAN_HLEN, 0));
+
+	vhdr = (struct vlan_hdr *)(skb->data + ETH_HLEN);
+	*current_tci = vhdr->h_vlan_TCI;
+
+	memmove(skb->data + VLAN_HLEN, skb->data, 2 * ETH_ALEN);
+	__skb_pull(skb, VLAN_HLEN);
+
+	vlan_set_encap_proto(skb, vhdr);
+	skb->mac_header += VLAN_HLEN;
+	skb_reset_mac_len(skb);
+
+	return 0;
+}
+
+static int pop_vlan(struct sk_buff *skb)
+{
+	__be16 tci;
+	int err;
+
+	if (likely(vlan_tx_tag_present(skb))) {
+		skb->vlan_tci = 0;
+	} else {
+		if (unlikely(skb->protocol != htons(ETH_P_8021Q) ||
+			     skb->len < VLAN_ETH_HLEN))
+			return 0;
+
+		err = __pop_vlan_tci(skb, &tci);
+		if (err)
+			return err;
+	}
+	/* move next vlan tag to hw accel tag */
+	if (likely(skb->protocol != htons(ETH_P_8021Q) ||
+		   skb->len < VLAN_ETH_HLEN))
+		return 0;
+
+	err = __pop_vlan_tci(skb, &tci);
+	if (unlikely(err))
+		return err;
+
+	__vlan_hwaccel_put_tag(skb, ntohs(tci));
+	return 0;
+}
+
+static int push_vlan(struct sk_buff *skb, const struct ovs_action_push_vlan *vlan)
+{
+	if (unlikely(vlan_tx_tag_present(skb))) {
+		u16 current_tag;
+
+		/* push down current VLAN tag */
+		current_tag = vlan_tx_tag_get(skb);
+
+		if (!__vlan_put_tag(skb, current_tag))
+			return -ENOMEM;
+
+		if (skb->ip_summed == CHECKSUM_COMPLETE)
+			skb->csum = csum_add(skb->csum, csum_partial(skb->data
+					+ ETH_HLEN, VLAN_HLEN, 0));
+
+	}
+	__vlan_hwaccel_put_tag(skb, ntohs(vlan->vlan_tci) & ~VLAN_TAG_PRESENT);
+	return 0;
+}
+
+static int set_eth_addr(struct sk_buff *skb,
+			const struct ovs_key_ethernet *eth_key)
+{
+	int err;
+	err = make_writable(skb, ETH_HLEN);
+	if (unlikely(err))
+		return err;
+
+	memcpy(eth_hdr(skb)->h_source, eth_key->eth_src, ETH_ALEN);
+	memcpy(eth_hdr(skb)->h_dest, eth_key->eth_dst, ETH_ALEN);
+
+	return 0;
+}
+
+static void set_ip_addr(struct sk_buff *skb, struct iphdr *nh,
+				__be32 *addr, __be32 new_addr)
+{
+	int transport_len = skb->len - skb_transport_offset(skb);
+
+	if (nh->protocol == IPPROTO_TCP) {
+		if (likely(transport_len >= sizeof(struct tcphdr)))
+			inet_proto_csum_replace4(&tcp_hdr(skb)->check, skb,
+						 *addr, new_addr, 1);
+	} else if (nh->protocol == IPPROTO_UDP) {
+		if (likely(transport_len >= sizeof(struct udphdr)))
+			inet_proto_csum_replace4(&udp_hdr(skb)->check, skb,
+						 *addr, new_addr, 1);
+	}
+
+	csum_replace4(&nh->check, *addr, new_addr);
+	skb->rxhash = 0;
+	*addr = new_addr;
+}
+
+static void set_ip_ttl(struct sk_buff *skb, struct iphdr *nh, u8 new_ttl)
+{
+	csum_replace2(&nh->check, htons(nh->ttl << 8), htons(new_ttl << 8));
+	nh->ttl = new_ttl;
+}
+
+static int set_ipv4(struct sk_buff *skb, const struct ovs_key_ipv4 *ipv4_key)
+{
+	struct iphdr *nh;
+	int err;
+
+	err = make_writable(skb, skb_network_offset(skb) +
+				 sizeof(struct iphdr));
+	if (unlikely(err))
+		return err;
+
+	nh = ip_hdr(skb);
+
+	if (ipv4_key->ipv4_src != nh->saddr)
+		set_ip_addr(skb, nh, &nh->saddr, ipv4_key->ipv4_src);
+
+	if (ipv4_key->ipv4_dst != nh->daddr)
+		set_ip_addr(skb, nh, &nh->daddr, ipv4_key->ipv4_dst);
+
+	if (ipv4_key->ipv4_tos != nh->tos)
+		ipv4_change_dsfield(nh, 0, ipv4_key->ipv4_tos);
+
+	if (ipv4_key->ipv4_ttl != nh->ttl)
+		set_ip_ttl(skb, nh, ipv4_key->ipv4_ttl);
+
+	return 0;
+}
+
+/* Must follow make_writable() since that can move the skb data. */
+static void set_tp_port(struct sk_buff *skb, __be16 *port,
+			 __be16 new_port, __sum16 *check)
+{
+	inet_proto_csum_replace2(check, skb, *port, new_port, 0);
+	*port = new_port;
+	skb->rxhash = 0;
+}
+
+static int set_udp_port(struct sk_buff *skb,
+			const struct ovs_key_udp *udp_port_key)
+{
+	struct udphdr *uh;
+	int err;
+
+	err = make_writable(skb, skb_transport_offset(skb) +
+				 sizeof(struct udphdr));
+	if (unlikely(err))
+		return err;
+
+	uh = udp_hdr(skb);
+	if (udp_port_key->udp_src != uh->source)
+		set_tp_port(skb, &uh->source, udp_port_key->udp_src, &uh->check);
+
+	if (udp_port_key->udp_dst != uh->dest)
+		set_tp_port(skb, &uh->dest, udp_port_key->udp_dst, &uh->check);
+
+	return 0;
+}
+
+static int set_tcp_port(struct sk_buff *skb,
+			const struct ovs_key_tcp *tcp_port_key)
+{
+	struct tcphdr *th;
+	int err;
+
+	err = make_writable(skb, skb_transport_offset(skb) +
+				 sizeof(struct tcphdr));
+	if (unlikely(err))
+		return err;
+
+	th = tcp_hdr(skb);
+	if (tcp_port_key->tcp_src != th->source)
+		set_tp_port(skb, &th->source, tcp_port_key->tcp_src, &th->check);
+
+	if (tcp_port_key->tcp_dst != th->dest)
+		set_tp_port(skb, &th->dest, tcp_port_key->tcp_dst, &th->check);
+
+	return 0;
+}
+
+static int do_output(struct datapath *dp, struct sk_buff *skb, int out_port)
+{
+	struct vport *vport;
+
+	if (unlikely(!skb))
+		return -ENOMEM;
+
+	vport = rcu_dereference(dp->ports[out_port]);
+	if (unlikely(!vport)) {
+		kfree_skb(skb);
+		return -ENODEV;
+	}
+
+	vport_send(vport, skb);
+	return 0;
+}
+
+static int output_userspace(struct datapath *dp, struct sk_buff *skb,
+			    const struct nlattr *attr)
+{
+	struct dp_upcall_info upcall;
+	const struct nlattr *a;
+	int rem;
+
+	upcall.cmd = OVS_PACKET_CMD_ACTION;
+	upcall.key = &OVS_CB(skb)->flow->key;
+	upcall.userdata = NULL;
+	upcall.pid = 0;
+
+	for (a = nla_data(attr), rem = nla_len(attr); rem > 0;
+		 a = nla_next(a, &rem)) {
+		switch (nla_type(a)) {
+		case OVS_USERSPACE_ATTR_USERDATA:
+			upcall.userdata = a;
+			break;
+
+		case OVS_USERSPACE_ATTR_PID:
+			upcall.pid = nla_get_u32(a);
+			break;
+		}
+	}
+
+	return dp_upcall(dp, skb, &upcall);
+}
+
+static int sample(struct datapath *dp, struct sk_buff *skb,
+		  const struct nlattr *attr)
+{
+	const struct nlattr *acts_list = NULL;
+	const struct nlattr *a;
+	int rem;
+
+	for (a = nla_data(attr), rem = nla_len(attr); rem > 0;
+		 a = nla_next(a, &rem)) {
+		switch (nla_type(a)) {
+		case OVS_SAMPLE_ATTR_PROBABILITY:
+			if (net_random() >= nla_get_u32(a))
+				return 0;
+			break;
+
+		case OVS_SAMPLE_ATTR_ACTIONS:
+			acts_list = a;
+			break;
+		}
+	}
+
+	return do_execute_actions(dp, skb, nla_data(acts_list),
+						 nla_len(acts_list), true);
+}
+
+static int execute_set_action(struct sk_buff *skb,
+				 const struct nlattr *nested_attr)
+{
+	int err = 0;
+
+	switch (nla_type(nested_attr)) {
+	case OVS_KEY_ATTR_PRIORITY:
+		skb->priority = nla_get_u32(nested_attr);
+		break;
+
+	case OVS_KEY_ATTR_ETHERNET:
+		err = set_eth_addr(skb, nla_data(nested_attr));
+		break;
+
+	case OVS_KEY_ATTR_IPV4:
+		err = set_ipv4(skb, nla_data(nested_attr));
+		break;
+
+	case OVS_KEY_ATTR_TCP:
+		err = set_tcp_port(skb, nla_data(nested_attr));
+		break;
+
+	case OVS_KEY_ATTR_UDP:
+		err = set_udp_port(skb, nla_data(nested_attr));
+		break;
+	}
+
+	return err;
+}
+
+/* Execute a list of actions against 'skb'. */
+static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
+			const struct nlattr *attr, int len, bool keep_skb)
+{
+	/* Every output action needs a separate clone of 'skb', but the common
+	 * case is just a single output action, so that doing a clone and
+	 * then freeing the original skbuff is wasteful.  So the following code
+	 * is slightly obscure just to avoid that. */
+	int prev_port = -1;
+	const struct nlattr *a;
+	int rem;
+
+	for (a = attr, rem = len; rem > 0;
+	     a = nla_next(a, &rem)) {
+		int err = 0;
+
+		if (prev_port != -1) {
+			do_output(dp, skb_clone(skb, GFP_ATOMIC), prev_port);
+			prev_port = -1;
+		}
+
+		switch (nla_type(a)) {
+		case OVS_ACTION_ATTR_OUTPUT:
+			prev_port = nla_get_u32(a);
+			break;
+
+		case OVS_ACTION_ATTR_USERSPACE:
+			output_userspace(dp, skb, a);
+			break;
+
+		case OVS_ACTION_ATTR_PUSH_VLAN:
+			err = push_vlan(skb, nla_data(a));
+			if (unlikely(err)) /* skb already freed. */
+				return err;
+			break;
+
+		case OVS_ACTION_ATTR_POP_VLAN:
+			err = pop_vlan(skb);
+			break;
+
+		case OVS_ACTION_ATTR_SET:
+			err = execute_set_action(skb, nla_data(a));
+			break;
+
+		case OVS_ACTION_ATTR_SAMPLE:
+			err = sample(dp, skb, a);
+			break;
+		}
+
+		if (unlikely(err)) {
+			kfree_skb(skb);
+			return err;
+		}
+	}
+
+	if (prev_port != -1) {
+		if (keep_skb)
+			skb = skb_clone(skb, GFP_ATOMIC);
+
+		do_output(dp, skb, prev_port);
+	} else if (!keep_skb)
+		consume_skb(skb);
+
+	return 0;
+}
+
+/* Execute a list of actions against 'skb'. */
+int execute_actions(struct datapath *dp, struct sk_buff *skb)
+{
+	struct sw_flow_actions *acts = rcu_dereference(OVS_CB(skb)->flow->sf_acts);
+
+	return do_execute_actions(dp, skb, acts->actions,
+					 acts->actions_len, false);
+}
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
new file mode 100644
index 0000000..62635e5
--- /dev/null
+++ b/net/openvswitch/datapath.c
@@ -0,0 +1,1878 @@
+/*
+ * Copyright (c) 2007-2011 Nicira Networks.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/if_arp.h>
+#include <linux/if_vlan.h>
+#include <linux/in.h>
+#include <linux/ip.h>
+#include <linux/jhash.h>
+#include <linux/delay.h>
+#include <linux/time.h>
+#include <linux/etherdevice.h>
+#include <linux/genetlink.h>
+#include <linux/kernel.h>
+#include <linux/kthread.h>
+#include <linux/mutex.h>
+#include <linux/percpu.h>
+#include <linux/rcupdate.h>
+#include <linux/tcp.h>
+#include <linux/udp.h>
+#include <linux/version.h>
+#include <linux/ethtool.h>
+#include <linux/wait.h>
+#include <asm/system.h>
+#include <asm/div64.h>
+#include <linux/highmem.h>
+#include <linux/netfilter_bridge.h>
+#include <linux/netfilter_ipv4.h>
+#include <linux/inetdevice.h>
+#include <linux/list.h>
+#include <linux/openvswitch.h>
+#include <linux/rculist.h>
+#include <linux/dmi.h>
+#include <net/genetlink.h>
+
+#include "datapath.h"
+#include "flow.h"
+#include "vport-internal_dev.h"
+
+/**
+ * DOC: Locking:
+ *
+ * Writes to device state (add/remove datapath, port, set operations on vports,
+ * etc.) are protected by RTNL.
+ *
+ * Writes to other state (flow table modifications, set miscellaneous datapath
+ * parameters, etc.) are protected by genl_mutex.  The RTNL lock nests inside
+ * genl_mutex.
+ *
+ * Reads are protected by RCU.
+ *
+ * There are a few special cases (mostly stats) that have their own
+ * synchronization but they nest under all of above and don't interact with
+ * each other.
+ */
+
+/* Global list of datapaths to enable dumping them all out.
+ * Protected by genl_mutex.
+ */
+static LIST_HEAD(dps);
+
+static struct vport *new_vport(const struct vport_parms *);
+static int queue_gso_packets(int dp_ifindex, struct sk_buff *,
+			     const struct dp_upcall_info *);
+static int queue_userspace_packet(int dp_ifindex, struct sk_buff *,
+				  const struct dp_upcall_info *);
+
+/* Must be called with rcu_read_lock, genl_mutex, or RTNL lock. */
+static struct datapath *get_dp(int dp_ifindex)
+{
+	struct datapath *dp = NULL;
+	struct net_device *dev;
+
+	rcu_read_lock();
+	dev = dev_get_by_index_rcu(&init_net, dp_ifindex);
+	if (dev) {
+		struct vport *vport = internal_dev_get_vport(dev);
+		if (vport)
+			dp = vport->dp;
+	}
+	rcu_read_unlock();
+
+	return dp;
+}
+
+/* Must be called with rcu_read_lock or RTNL lock. */
+const char *dp_name(const struct datapath *dp)
+{
+	struct vport *vport = rcu_dereference_rtnl(dp->ports[OVSP_LOCAL]);
+	return vport->ops->get_name(vport);
+}
+
+static int get_dpifindex(struct datapath *dp)
+{
+	struct vport *local;
+	int ifindex;
+
+	rcu_read_lock();
+
+	local = rcu_dereference(dp->ports[OVSP_LOCAL]);
+	if (local)
+		ifindex = local->ops->get_ifindex(local);
+	else
+		ifindex = 0;
+
+	rcu_read_unlock();
+
+	return ifindex;
+}
+
+static void destroy_dp_rcu(struct rcu_head *rcu)
+{
+	struct datapath *dp = container_of(rcu, struct datapath, rcu);
+
+	flow_tbl_destroy((__force struct flow_table *)dp->table);
+	free_percpu(dp->stats_percpu);
+	kfree(dp);
+}
+
+/* Called with RTNL lock and genl_lock. */
+static struct vport *new_vport(const struct vport_parms *parms)
+{
+	struct vport *vport;
+
+	vport = vport_add(parms);
+	if (!IS_ERR(vport)) {
+		struct datapath *dp = parms->dp;
+
+		rcu_assign_pointer(dp->ports[parms->port_no], vport);
+		list_add(&vport->node, &dp->port_list);
+	}
+
+	return vport;
+}
+
+/* Called with RTNL lock. */
+void dp_detach_port(struct vport *p)
+{
+	ASSERT_RTNL();
+
+	/* First drop references to device. */
+	list_del(&p->node);
+	rcu_assign_pointer(p->dp->ports[p->port_no], NULL);
+
+	/* Then destroy it. */
+	vport_del(p);
+}
+
+/* Must be called with rcu_read_lock. */
+void dp_process_received_packet(struct vport *p, struct sk_buff *skb)
+{
+	struct datapath *dp = p->dp;
+	struct sw_flow *flow;
+	struct dp_stats_percpu *stats;
+	struct sw_flow_key key;
+	u64 *stats_counter;
+	int error;
+	int key_len;
+
+	stats = per_cpu_ptr(dp->stats_percpu, smp_processor_id());
+
+	/* Extract flow from 'skb' into 'key'. */
+	error = flow_extract(skb, p->port_no, &key, &key_len);
+	if (unlikely(error)) {
+		kfree_skb(skb);
+		return;
+	}
+
+	/* Look up flow. */
+	flow = flow_tbl_lookup(rcu_dereference(dp->table), &key, key_len);
+	if (unlikely(!flow)) {
+		struct dp_upcall_info upcall;
+
+		upcall.cmd = OVS_PACKET_CMD_MISS;
+		upcall.key = &key;
+		upcall.userdata = NULL;
+		upcall.pid = p->upcall_pid;
+		dp_upcall(dp, skb, &upcall);
+		consume_skb(skb);
+		stats_counter = &stats->n_missed;
+		goto out;
+	}
+
+	OVS_CB(skb)->flow = flow;
+
+	stats_counter = &stats->n_hit;
+	flow_used(OVS_CB(skb)->flow, skb);
+	execute_actions(dp, skb);
+
+out:
+	/* Update datapath statistics. */
+	u64_stats_update_begin(&stats->sync);
+	(*stats_counter)++;
+	u64_stats_update_end(&stats->sync);
+}
+
+static struct genl_family dp_packet_genl_family = {
+	.id = GENL_ID_GENERATE,
+	.hdrsize = sizeof(struct ovs_header),
+	.name = OVS_PACKET_FAMILY,
+	.version = OVS_PACKET_VERSION,
+	.maxattr = OVS_PACKET_ATTR_MAX
+};
+
+int dp_upcall(struct datapath *dp, struct sk_buff *skb,
+	      const struct dp_upcall_info *upcall_info)
+{
+	struct dp_stats_percpu *stats;
+	int dp_ifindex;
+	int err;
+
+	if (upcall_info->pid == 0) {
+		err = -ENOTCONN;
+		goto err;
+	}
+
+	dp_ifindex = get_dpifindex(dp);
+	if (!dp_ifindex) {
+		err = -ENODEV;
+		goto err;
+	}
+
+	if (!skb_is_gso(skb))
+		err = queue_userspace_packet(dp_ifindex, skb, upcall_info);
+	else
+		err = queue_gso_packets(dp_ifindex, skb, upcall_info);
+	if (err)
+		goto err;
+
+	return 0;
+
+err:
+	stats = per_cpu_ptr(dp->stats_percpu, smp_processor_id());
+
+	u64_stats_update_begin(&stats->sync);
+	stats->n_lost++;
+	u64_stats_update_end(&stats->sync);
+
+	return err;
+}
+
+static int queue_gso_packets(int dp_ifindex, struct sk_buff *skb,
+			     const struct dp_upcall_info *upcall_info)
+{
+	struct dp_upcall_info later_info;
+	struct sw_flow_key later_key;
+	struct sk_buff *segs, *nskb;
+	int err;
+
+	segs = skb_gso_segment(skb, NETIF_F_SG | NETIF_F_HW_CSUM);
+	if (IS_ERR(skb))
+		return PTR_ERR(skb);
+
+	/* Queue all of the segments. */
+	skb = segs;
+	do {
+		err = queue_userspace_packet(dp_ifindex, skb, upcall_info);
+		if (err)
+			break;
+
+		if (skb == segs && skb_shinfo(skb)->gso_type & SKB_GSO_UDP) {
+			/* The initial flow key extracted by flow_extract() in
+			 * this case is for a first fragment, so we need to
+			 * properly mark later fragments.
+			 */
+			later_key = *upcall_info->key;
+			later_key.ip.frag = OVS_FRAG_TYPE_LATER;
+
+			later_info = *upcall_info;
+			later_info.key = &later_key;
+			upcall_info = &later_info;
+		}
+	} while ((skb = skb->next));
+
+	/* Free all of the segments. */
+	skb = segs;
+	do {
+		nskb = skb->next;
+		if (err)
+			kfree_skb(skb);
+		else
+			consume_skb(skb);
+	} while ((skb = nskb));
+	return err;
+}
+
+static int queue_userspace_packet(int dp_ifindex, struct sk_buff *skb,
+				  const struct dp_upcall_info *upcall_info)
+{
+	struct ovs_header *upcall;
+	struct sk_buff *nskb = NULL;
+	struct sk_buff *user_skb; /* to be queued to userspace */
+	struct nlattr *nla;
+	unsigned int len;
+	int err;
+
+	if (vlan_tx_tag_present(skb)) {
+		nskb = skb_clone(skb, GFP_ATOMIC);
+		if (!nskb)
+			return -ENOMEM;
+
+		nskb = __vlan_put_tag(nskb, vlan_tx_tag_get(nskb));
+		if (!skb)
+			return -ENOMEM;
+
+		nskb->vlan_tci = 0;
+		skb = nskb;
+	}
+
+	if (nla_attr_size(skb->len) > USHRT_MAX) {
+		err = -EFBIG;
+		goto out;
+	}
+
+	len = sizeof(struct ovs_header);
+	len += nla_total_size(skb->len);
+	len += nla_total_size(FLOW_BUFSIZE);
+	if (upcall_info->cmd == OVS_PACKET_CMD_ACTION)
+		len += nla_total_size(8);
+
+	user_skb = genlmsg_new(len, GFP_ATOMIC);
+	if (!user_skb) {
+		err = -ENOMEM;
+		goto out;
+	}
+
+	upcall = genlmsg_put(user_skb, 0, 0, &dp_packet_genl_family,
+			     0, upcall_info->cmd);
+	upcall->dp_ifindex = dp_ifindex;
+
+	nla = nla_nest_start(user_skb, OVS_PACKET_ATTR_KEY);
+	flow_to_nlattrs(upcall_info->key, user_skb);
+	nla_nest_end(user_skb, nla);
+
+	if (upcall_info->userdata)
+		nla_put_u64(user_skb, OVS_PACKET_ATTR_USERDATA,
+			    nla_get_u64(upcall_info->userdata));
+
+	nla = __nla_reserve(user_skb, OVS_PACKET_ATTR_PACKET, skb->len);
+
+	skb_copy_and_csum_dev(skb, nla_data(nla));
+
+	err = genlmsg_unicast(&init_net, user_skb, upcall_info->pid);
+
+out:
+	kfree_skb(nskb);
+	return err;
+}
+
+/* Called with genl_mutex. */
+static int flush_flows(int dp_ifindex)
+{
+	struct flow_table *old_table;
+	struct flow_table *new_table;
+	struct datapath *dp;
+
+	dp = get_dp(dp_ifindex);
+	if (!dp)
+		return -ENODEV;
+
+	old_table = genl_dereference(dp->table);
+	new_table = flow_tbl_alloc(TBL_MIN_BUCKETS);
+	if (!new_table)
+		return -ENOMEM;
+
+	rcu_assign_pointer(dp->table, new_table);
+
+	flow_tbl_deferred_destroy(old_table);
+	return 0;
+}
+
+static int validate_actions(const struct nlattr *attr,
+				const struct sw_flow_key *key, int depth);
+
+static int validate_sample(const struct nlattr *attr,
+				const struct sw_flow_key *key, int depth)
+{
+	const struct nlattr *attrs[OVS_SAMPLE_ATTR_MAX + 1];
+	const struct nlattr *probability, *actions;
+	const struct nlattr *a;
+	int rem;
+
+	memset(attrs, 0, sizeof(attrs));
+	nla_for_each_nested(a, attr, rem) {
+		int type = nla_type(a);
+		if (!type || type > OVS_SAMPLE_ATTR_MAX || attrs[type])
+			return -EINVAL;
+		attrs[type] = a;
+	}
+	if (rem)
+		return -EINVAL;
+
+	probability = attrs[OVS_SAMPLE_ATTR_PROBABILITY];
+	if (!probability || nla_len(probability) != sizeof(u32))
+		return -EINVAL;
+
+	actions = attrs[OVS_SAMPLE_ATTR_ACTIONS];
+	if (!actions || (nla_len(actions) && nla_len(actions) < NLA_HDRLEN))
+		return -EINVAL;
+	return validate_actions(actions, key, depth + 1);
+}
+
+static int validate_set(const struct nlattr *a,
+			const struct sw_flow_key *flow_key)
+{
+	const struct nlattr *ovs_key = nla_data(a);
+	int key_type = nla_type(ovs_key);
+
+	/* There can be only one key in a action */
+	if (nla_total_size(nla_len(ovs_key)) != nla_len(a))
+		return -EINVAL;
+
+	if (key_type > OVS_KEY_ATTR_MAX ||
+	    nla_len(ovs_key) != ovs_key_lens[key_type])
+		return -EINVAL;
+
+	switch (key_type) {
+	const struct ovs_key_ipv4 *ipv4_key;
+
+	case OVS_KEY_ATTR_PRIORITY:
+	case OVS_KEY_ATTR_ETHERNET:
+		break;
+
+	case OVS_KEY_ATTR_IPV4:
+		if (flow_key->eth.type != htons(ETH_P_IP))
+			return -EINVAL;
+
+		if (!flow_key->ipv4.addr.src || !flow_key->ipv4.addr.dst)
+			return -EINVAL;
+
+		ipv4_key = nla_data(ovs_key);
+		if (ipv4_key->ipv4_proto != flow_key->ip.proto)
+			return -EINVAL;
+
+		if (ipv4_key->ipv4_frag != flow_key->ip.frag)
+			return -EINVAL;
+
+		break;
+
+	case OVS_KEY_ATTR_TCP:
+		if (flow_key->ip.proto != IPPROTO_TCP)
+			return -EINVAL;
+
+		if (!flow_key->ipv4.tp.src || !flow_key->ipv4.tp.dst)
+			return -EINVAL;
+
+		break;
+
+	case OVS_KEY_ATTR_UDP:
+		if (flow_key->ip.proto != IPPROTO_UDP)
+			return -EINVAL;
+
+		if (!flow_key->ipv4.tp.src || !flow_key->ipv4.tp.dst)
+			return -EINVAL;
+		break;
+
+	default:
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int validate_userspace(const struct nlattr *attr)
+{
+	static const struct nla_policy userspace_policy[OVS_USERSPACE_ATTR_MAX + 1] =	{
+		[OVS_USERSPACE_ATTR_PID] = {.type = NLA_U32 },
+		[OVS_USERSPACE_ATTR_USERDATA] = {.type = NLA_U64 },
+	};
+	struct nlattr *a[OVS_USERSPACE_ATTR_MAX + 1];
+	int error;
+
+	error = nla_parse_nested(a, OVS_USERSPACE_ATTR_MAX,
+				 attr, userspace_policy);
+	if (error)
+		return error;
+
+	if (!a[OVS_USERSPACE_ATTR_PID] ||
+	    !nla_get_u32(a[OVS_USERSPACE_ATTR_PID]))
+		return -EINVAL;
+
+	return 0;
+}
+
+static int validate_actions(const struct nlattr *attr,
+				const struct sw_flow_key *key,  int depth)
+{
+	const struct nlattr *a;
+	int rem, err;
+
+	if (depth >= SAMPLE_ACTION_DEPTH)
+		return -EOVERFLOW;
+
+	nla_for_each_nested(a, attr, rem) {
+		/* Expected argument lengths, (u32)-1 for variable length. */
+		static const u32 action_lens[OVS_ACTION_ATTR_MAX + 1] = {
+			[OVS_ACTION_ATTR_OUTPUT] = sizeof(u32),
+			[OVS_ACTION_ATTR_USERSPACE] = (u32)-1,
+			[OVS_ACTION_ATTR_PUSH_VLAN] = sizeof(struct ovs_action_push_vlan),
+			[OVS_ACTION_ATTR_POP_VLAN] = 0,
+			[OVS_ACTION_ATTR_SET] = (u32)-1,
+			[OVS_ACTION_ATTR_SAMPLE] = (u32)-1
+		};
+		const struct ovs_action_push_vlan *vlan;
+		int type = nla_type(a);
+
+		if (type > OVS_ACTION_ATTR_MAX ||
+		    (action_lens[type] != nla_len(a) &&
+		     action_lens[type] != (u32)-1))
+			return -EINVAL;
+
+		switch (type) {
+		case OVS_ACTION_ATTR_UNSPEC:
+			return -EINVAL;
+
+		case OVS_ACTION_ATTR_USERSPACE:
+			err = validate_userspace(a);
+			if (err)
+				return err;
+			break;
+
+		case OVS_ACTION_ATTR_OUTPUT:
+			if (nla_get_u32(a) >= DP_MAX_PORTS)
+				return -EINVAL;
+			break;
+
+
+		case OVS_ACTION_ATTR_POP_VLAN:
+			break;
+
+		case OVS_ACTION_ATTR_PUSH_VLAN:
+			vlan = nla_data(a);
+			if (vlan->vlan_tpid != htons(ETH_P_8021Q))
+				return -EINVAL;
+			if (!(vlan->vlan_tci & htons(VLAN_TAG_PRESENT)))
+				return -EINVAL;
+			break;
+
+		case OVS_ACTION_ATTR_SET:
+			err = validate_set(a, key);
+			if (err)
+				return err;
+			break;
+
+		case OVS_ACTION_ATTR_SAMPLE:
+			err = validate_sample(a, key, depth);
+			if (err)
+				return err;
+			break;
+
+		default:
+			return -EINVAL;
+		}
+	}
+
+	if (rem > 0)
+		return -EINVAL;
+
+	return 0;
+}
+
+static void clear_stats(struct sw_flow *flow)
+{
+	flow->used = 0;
+	flow->tcp_flags = 0;
+	flow->packet_count = 0;
+	flow->byte_count = 0;
+}
+
+static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
+{
+	struct ovs_header *ovs_header = info->userhdr;
+	struct nlattr **a = info->attrs;
+	struct sw_flow_actions *acts;
+	struct sk_buff *packet;
+	struct sw_flow *flow;
+	struct datapath *dp;
+	struct ethhdr *eth;
+	int len;
+	int err;
+	int key_len;
+
+	err = -EINVAL;
+	if (!a[OVS_PACKET_ATTR_PACKET] || !a[OVS_PACKET_ATTR_KEY] ||
+	    !a[OVS_PACKET_ATTR_ACTIONS] ||
+	    nla_len(a[OVS_PACKET_ATTR_PACKET]) < ETH_HLEN)
+		goto err;
+
+	len = nla_len(a[OVS_PACKET_ATTR_PACKET]);
+	packet = __dev_alloc_skb(NET_IP_ALIGN + len, GFP_KERNEL);
+	err = -ENOMEM;
+	if (!packet)
+		goto err;
+	skb_reserve(packet, NET_IP_ALIGN);
+
+	memcpy(__skb_put(packet, len), nla_data(a[OVS_PACKET_ATTR_PACKET]), len);
+
+	skb_reset_mac_header(packet);
+	eth = eth_hdr(packet);
+
+	/* Normally, setting the skb 'protocol' field would be handled by a
+	 * call to eth_type_trans(), but it assumes there's a sending
+	 * device, which we may not have. */
+	if (ntohs(eth->h_proto) >= 1536)
+		packet->protocol = eth->h_proto;
+	else
+		packet->protocol = htons(ETH_P_802_2);
+
+	/* Build an sw_flow for sending this packet. */
+	flow = flow_alloc();
+	err = PTR_ERR(flow);
+	if (IS_ERR(flow))
+		goto err_kfree_skb;
+
+	err = flow_extract(packet, -1, &flow->key, &key_len);
+	if (err)
+		goto err_flow_free;
+
+	err = flow_metadata_from_nlattrs(&flow->key.phy.priority,
+					 &flow->key.phy.in_port,
+					 a[OVS_PACKET_ATTR_KEY]);
+	if (err)
+		goto err_flow_free;
+
+	err = validate_actions(a[OVS_PACKET_ATTR_ACTIONS], &flow->key, 0);
+	if (err)
+		goto err_flow_free;
+
+	flow->hash = flow_hash(&flow->key, key_len);
+
+	acts = flow_actions_alloc(a[OVS_PACKET_ATTR_ACTIONS]);
+	err = PTR_ERR(acts);
+	if (IS_ERR(acts))
+		goto err_flow_free;
+	rcu_assign_pointer(flow->sf_acts, acts);
+
+	OVS_CB(packet)->flow = flow;
+	packet->priority = flow->key.phy.priority;
+
+	rcu_read_lock();
+	dp = get_dp(ovs_header->dp_ifindex);
+	err = -ENODEV;
+	if (!dp)
+		goto err_unlock;
+
+	local_bh_disable();
+	err = execute_actions(dp, packet);
+	local_bh_enable();
+	rcu_read_unlock();
+
+	flow_free(flow);
+	return err;
+
+err_unlock:
+	rcu_read_unlock();
+err_flow_free:
+	flow_free(flow);
+err_kfree_skb:
+	kfree_skb(packet);
+err:
+	return err;
+}
+
+static const struct nla_policy packet_policy[OVS_PACKET_ATTR_MAX + 1] = {
+	[OVS_PACKET_ATTR_PACKET] = { .type = NLA_UNSPEC },
+	[OVS_PACKET_ATTR_KEY] = { .type = NLA_NESTED },
+	[OVS_PACKET_ATTR_ACTIONS] = { .type = NLA_NESTED },
+};
+
+static struct genl_ops dp_packet_genl_ops[] = {
+	{ .cmd = OVS_PACKET_CMD_EXECUTE,
+	  .flags = GENL_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
+	  .policy = packet_policy,
+	  .doit = ovs_packet_cmd_execute
+	}
+};
+
+static void get_dp_stats(struct datapath *dp, struct ovs_dp_stats *stats)
+{
+	int i;
+	struct flow_table *table = genl_dereference(dp->table);
+
+	stats->n_flows = flow_tbl_count(table);
+
+	stats->n_hit = stats->n_missed = stats->n_lost = 0;
+	for_each_possible_cpu(i) {
+		const struct dp_stats_percpu *percpu_stats;
+		struct dp_stats_percpu local_stats;
+		unsigned int start;
+
+		percpu_stats = per_cpu_ptr(dp->stats_percpu, i);
+
+		do {
+			start = u64_stats_fetch_begin_bh(&percpu_stats->sync);
+			local_stats = *percpu_stats;
+		} while (u64_stats_fetch_retry_bh(&percpu_stats->sync, start));
+
+		stats->n_hit += local_stats.n_hit;
+		stats->n_missed += local_stats.n_missed;
+		stats->n_lost += local_stats.n_lost;
+	}
+}
+
+static const struct nla_policy flow_policy[OVS_FLOW_ATTR_MAX + 1] = {
+	[OVS_FLOW_ATTR_KEY] = { .type = NLA_NESTED },
+	[OVS_FLOW_ATTR_ACTIONS] = { .type = NLA_NESTED },
+	[OVS_FLOW_ATTR_CLEAR] = { .type = NLA_FLAG },
+};
+
+static struct genl_family dp_flow_genl_family = {
+	.id = GENL_ID_GENERATE,
+	.hdrsize = sizeof(struct ovs_header),
+	.name = OVS_FLOW_FAMILY,
+	.version = OVS_FLOW_VERSION,
+	.maxattr = OVS_FLOW_ATTR_MAX
+};
+
+static struct genl_multicast_group dp_flow_multicast_group = {
+	.name = OVS_FLOW_MCGROUP
+};
+
+/* Called with genl_lock. */
+static int ovs_flow_cmd_fill_info(struct sw_flow *flow, struct datapath *dp,
+				  struct sk_buff *skb, u32 pid,
+				  u32 seq, u32 flags, u8 cmd)
+{
+	const int skb_orig_len = skb->len;
+	const struct sw_flow_actions *sf_acts;
+	struct ovs_flow_stats stats;
+	struct ovs_header *ovs_header;
+	struct nlattr *nla;
+	unsigned long used;
+	u8 tcp_flags;
+	int err;
+
+	sf_acts = rcu_dereference_protected(flow->sf_acts,
+					    lockdep_genl_is_held());
+
+	ovs_header = genlmsg_put(skb, pid, seq, &dp_flow_genl_family, flags, cmd);
+	if (!ovs_header)
+		return -EMSGSIZE;
+
+	ovs_header->dp_ifindex = get_dpifindex(dp);
+
+	nla = nla_nest_start(skb, OVS_FLOW_ATTR_KEY);
+	if (!nla)
+		goto nla_put_failure;
+	err = flow_to_nlattrs(&flow->key, skb);
+	if (err)
+		goto error;
+	nla_nest_end(skb, nla);
+
+	spin_lock_bh(&flow->lock);
+	used = flow->used;
+	stats.n_packets = flow->packet_count;
+	stats.n_bytes = flow->byte_count;
+	tcp_flags = flow->tcp_flags;
+	spin_unlock_bh(&flow->lock);
+
+	if (used)
+		NLA_PUT_U64(skb, OVS_FLOW_ATTR_USED, flow_used_time(used));
+
+	if (stats.n_packets)
+		NLA_PUT(skb, OVS_FLOW_ATTR_STATS,
+			sizeof(struct ovs_flow_stats), &stats);
+
+	if (tcp_flags)
+		NLA_PUT_U8(skb, OVS_FLOW_ATTR_TCP_FLAGS, tcp_flags);
+
+	/* If OVS_FLOW_ATTR_ACTIONS doesn't fit, skip dumping the actions if
+	 * this is the first flow to be dumped into 'skb'.  This is unusual for
+	 * Netlink but individual action lists can be longer than
+	 * NLMSG_GOODSIZE and thus entirely undumpable if we didn't do this.
+	 * The userspace caller can always fetch the actions separately if it
+	 * really wants them.  (Most userspace callers in fact don't care.)
+	 *
+	 * This can only fail for dump operations because the skb is always
+	 * properly sized for single flows.
+	 */
+	err = nla_put(skb, OVS_FLOW_ATTR_ACTIONS, sf_acts->actions_len,
+		      sf_acts->actions);
+	if (err < 0 && skb_orig_len)
+		goto error;
+
+	return genlmsg_end(skb, ovs_header);
+
+nla_put_failure:
+	err = -EMSGSIZE;
+error:
+	genlmsg_cancel(skb, ovs_header);
+	return err;
+}
+
+static struct sk_buff *ovs_flow_cmd_alloc_info(struct sw_flow *flow)
+{
+	const struct sw_flow_actions *sf_acts;
+	int len;
+
+	sf_acts = rcu_dereference_protected(flow->sf_acts,
+					    lockdep_genl_is_held());
+
+	/* OVS_FLOW_ATTR_KEY */
+	len = nla_total_size(FLOW_BUFSIZE);
+	/* OVS_FLOW_ATTR_ACTIONS */
+	len += nla_total_size(sf_acts->actions_len);
+	/* OVS_FLOW_ATTR_STATS */
+	len += nla_total_size(sizeof(struct ovs_flow_stats));
+	/* OVS_FLOW_ATTR_TCP_FLAGS */
+	len += nla_total_size(1);
+	/* OVS_FLOW_ATTR_USED */
+	len += nla_total_size(8);
+
+	len += NLMSG_ALIGN(sizeof(struct ovs_header));
+
+	return genlmsg_new(len, GFP_KERNEL);
+}
+
+static struct sk_buff *ovs_flow_cmd_build_info(struct sw_flow *flow,
+					       struct datapath *dp,
+					       u32 pid, u32 seq, u8 cmd)
+{
+	struct sk_buff *skb;
+	int retval;
+
+	skb = ovs_flow_cmd_alloc_info(flow);
+	if (!skb)
+		return ERR_PTR(-ENOMEM);
+
+	retval = ovs_flow_cmd_fill_info(flow, dp, skb, pid, seq, 0, cmd);
+	BUG_ON(retval < 0);
+	return skb;
+}
+
+static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
+{
+	struct nlattr **a = info->attrs;
+	struct ovs_header *ovs_header = info->userhdr;
+	struct sw_flow_key key;
+	struct sw_flow *flow;
+	struct sk_buff *reply;
+	struct datapath *dp;
+	struct flow_table *table;
+	int error;
+	int key_len;
+
+	/* Extract key. */
+	error = -EINVAL;
+	if (!a[OVS_FLOW_ATTR_KEY])
+		goto error;
+	error = flow_from_nlattrs(&key, &key_len, a[OVS_FLOW_ATTR_KEY]);
+	if (error)
+		goto error;
+
+	/* Validate actions. */
+	if (a[OVS_FLOW_ATTR_ACTIONS]) {
+		error = validate_actions(a[OVS_FLOW_ATTR_ACTIONS], &key,  0);
+		if (error)
+			goto error;
+	} else if (info->genlhdr->cmd == OVS_FLOW_CMD_NEW) {
+		error = -EINVAL;
+		goto error;
+	}
+
+	dp = get_dp(ovs_header->dp_ifindex);
+	error = -ENODEV;
+	if (!dp)
+		goto error;
+
+	table = genl_dereference(dp->table);
+	flow = flow_tbl_lookup(table, &key, key_len);
+	if (!flow) {
+		struct sw_flow_actions *acts;
+
+		/* Bail out if we're not allowed to create a new flow. */
+		error = -ENOENT;
+		if (info->genlhdr->cmd == OVS_FLOW_CMD_SET)
+			goto error;
+
+		/* Expand table, if necessary, to make room. */
+		if (flow_tbl_need_to_expand(table)) {
+			struct flow_table *new_table;
+
+			new_table = flow_tbl_expand(table);
+			if (!IS_ERR(new_table)) {
+				rcu_assign_pointer(dp->table, new_table);
+				flow_tbl_deferred_destroy(table);
+				table = genl_dereference(dp->table);
+			}
+		}
+
+		/* Allocate flow. */
+		flow = flow_alloc();
+		if (IS_ERR(flow)) {
+			error = PTR_ERR(flow);
+			goto error;
+		}
+		flow->key = key;
+		clear_stats(flow);
+
+		/* Obtain actions. */
+		acts = flow_actions_alloc(a[OVS_FLOW_ATTR_ACTIONS]);
+		error = PTR_ERR(acts);
+		if (IS_ERR(acts))
+			goto error_free_flow;
+		rcu_assign_pointer(flow->sf_acts, acts);
+
+		/* Put flow in bucket. */
+		flow->hash = flow_hash(&key, key_len);
+		flow_tbl_insert(table, flow);
+
+		reply = ovs_flow_cmd_build_info(flow, dp, info->snd_pid,
+						info->snd_seq,
+						OVS_FLOW_CMD_NEW);
+	} else {
+		/* We found a matching flow. */
+		struct sw_flow_actions *old_acts;
+		struct nlattr *acts_attrs;
+
+		/* Bail out if we're not allowed to modify an existing flow.
+		 * We accept NLM_F_CREATE in place of the intended NLM_F_EXCL
+		 * because Generic Netlink treats the latter as a dump
+		 * request.  We also accept NLM_F_EXCL in case that bug ever
+		 * gets fixed.
+		 */
+		error = -EEXIST;
+		if (info->genlhdr->cmd == OVS_FLOW_CMD_NEW &&
+		    info->nlhdr->nlmsg_flags & (NLM_F_CREATE | NLM_F_EXCL))
+			goto error;
+
+		/* Update actions. */
+		old_acts = rcu_dereference_protected(flow->sf_acts,
+						     lockdep_genl_is_held());
+		acts_attrs = a[OVS_FLOW_ATTR_ACTIONS];
+		if (acts_attrs &&
+		   (old_acts->actions_len != nla_len(acts_attrs) ||
+		   memcmp(old_acts->actions, nla_data(acts_attrs),
+			  old_acts->actions_len))) {
+			struct sw_flow_actions *new_acts;
+
+			new_acts = flow_actions_alloc(acts_attrs);
+			error = PTR_ERR(new_acts);
+			if (IS_ERR(new_acts))
+				goto error;
+
+			rcu_assign_pointer(flow->sf_acts, new_acts);
+			flow_deferred_free_acts(old_acts);
+		}
+
+		reply = ovs_flow_cmd_build_info(flow, dp, info->snd_pid,
+					       info->snd_seq, OVS_FLOW_CMD_NEW);
+
+		/* Clear stats. */
+		if (a[OVS_FLOW_ATTR_CLEAR]) {
+			spin_lock_bh(&flow->lock);
+			clear_stats(flow);
+			spin_unlock_bh(&flow->lock);
+		}
+	}
+
+	if (!IS_ERR(reply))
+		genl_notify(reply, genl_info_net(info), info->snd_pid,
+			   dp_flow_multicast_group.id, info->nlhdr, GFP_KERNEL);
+	else
+		netlink_set_err(init_net.genl_sock, 0,
+				dp_flow_multicast_group.id, PTR_ERR(reply));
+	return 0;
+
+error_free_flow:
+	flow_free(flow);
+error:
+	return error;
+}
+
+static int ovs_flow_cmd_get(struct sk_buff *skb, struct genl_info *info)
+{
+	struct nlattr **a = info->attrs;
+	struct ovs_header *ovs_header = info->userhdr;
+	struct sw_flow_key key;
+	struct sk_buff *reply;
+	struct sw_flow *flow;
+	struct datapath *dp;
+	struct flow_table *table;
+	int err;
+	int key_len;
+
+	if (!a[OVS_FLOW_ATTR_KEY])
+		return -EINVAL;
+	err = flow_from_nlattrs(&key, &key_len, a[OVS_FLOW_ATTR_KEY]);
+	if (err)
+		return err;
+
+	dp = get_dp(ovs_header->dp_ifindex);
+	if (!dp)
+		return -ENODEV;
+
+	table = genl_dereference(dp->table);
+	flow = flow_tbl_lookup(table, &key, key_len);
+	if (!flow)
+		return -ENOENT;
+
+	reply = ovs_flow_cmd_build_info(flow, dp, info->snd_pid,
+					info->snd_seq, OVS_FLOW_CMD_NEW);
+	if (IS_ERR(reply))
+		return PTR_ERR(reply);
+
+	return genlmsg_reply(reply, info);
+}
+
+static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
+{
+	struct nlattr **a = info->attrs;
+	struct ovs_header *ovs_header = info->userhdr;
+	struct sw_flow_key key;
+	struct sk_buff *reply;
+	struct sw_flow *flow;
+	struct datapath *dp;
+	struct flow_table *table;
+	int err;
+	int key_len;
+
+	if (!a[OVS_FLOW_ATTR_KEY])
+		return flush_flows(ovs_header->dp_ifindex);
+	err = flow_from_nlattrs(&key, &key_len, a[OVS_FLOW_ATTR_KEY]);
+	if (err)
+		return err;
+
+	dp = get_dp(ovs_header->dp_ifindex);
+	if (!dp)
+		return -ENODEV;
+
+	table = genl_dereference(dp->table);
+	flow = flow_tbl_lookup(table, &key, key_len);
+	if (!flow)
+		return -ENOENT;
+
+	reply = ovs_flow_cmd_alloc_info(flow);
+	if (!reply)
+		return -ENOMEM;
+
+	flow_tbl_remove(table, flow);
+
+	err = ovs_flow_cmd_fill_info(flow, dp, reply, info->snd_pid,
+				     info->snd_seq, 0, OVS_FLOW_CMD_DEL);
+	BUG_ON(err < 0);
+
+	flow_deferred_free(flow);
+
+	genl_notify(reply, genl_info_net(info), info->snd_pid,
+		    dp_flow_multicast_group.id, info->nlhdr, GFP_KERNEL);
+	return 0;
+}
+
+static int ovs_flow_cmd_dump(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct ovs_header *ovs_header = genlmsg_data(nlmsg_data(cb->nlh));
+	struct datapath *dp;
+	struct flow_table *table;
+
+	dp = get_dp(ovs_header->dp_ifindex);
+	if (!dp)
+		return -ENODEV;
+
+	table = genl_dereference(dp->table);
+
+	for (;;) {
+		struct sw_flow *flow;
+		u32 bucket, obj;
+
+		bucket = cb->args[0];
+		obj = cb->args[1];
+		flow = flow_tbl_next(table, &bucket, &obj);
+		if (!flow)
+			break;
+
+		if (ovs_flow_cmd_fill_info(flow, dp, skb,
+					   NETLINK_CB(cb->skb).pid,
+					   cb->nlh->nlmsg_seq, NLM_F_MULTI,
+					   OVS_FLOW_CMD_NEW) < 0)
+			break;
+
+		cb->args[0] = bucket;
+		cb->args[1] = obj;
+	}
+	return skb->len;
+}
+
+static struct genl_ops dp_flow_genl_ops[] = {
+	{ .cmd = OVS_FLOW_CMD_NEW,
+	  .flags = GENL_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
+	  .policy = flow_policy,
+	  .doit = ovs_flow_cmd_new_or_set
+	},
+	{ .cmd = OVS_FLOW_CMD_DEL,
+	  .flags = GENL_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
+	  .policy = flow_policy,
+	  .doit = ovs_flow_cmd_del
+	},
+	{ .cmd = OVS_FLOW_CMD_GET,
+	  .flags = 0,		    /* OK for unprivileged users. */
+	  .policy = flow_policy,
+	  .doit = ovs_flow_cmd_get,
+	  .dumpit = ovs_flow_cmd_dump
+	},
+	{ .cmd = OVS_FLOW_CMD_SET,
+	  .flags = GENL_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
+	  .policy = flow_policy,
+	  .doit = ovs_flow_cmd_new_or_set,
+	},
+};
+
+static const struct nla_policy datapath_policy[OVS_DP_ATTR_MAX + 1] = {
+	[OVS_DP_ATTR_NAME] = { .type = NLA_NUL_STRING, .len = IFNAMSIZ - 1 },
+	[OVS_DP_ATTR_UPCALL_PID] = { .type = NLA_U32 },
+};
+
+static struct genl_family dp_datapath_genl_family = {
+	.id = GENL_ID_GENERATE,
+	.hdrsize = sizeof(struct ovs_header),
+	.name = OVS_DATAPATH_FAMILY,
+	.version = OVS_DATAPATH_VERSION,
+	.maxattr = OVS_DP_ATTR_MAX
+};
+
+static struct genl_multicast_group dp_datapath_multicast_group = {
+	.name = OVS_DATAPATH_MCGROUP
+};
+
+static int ovs_dp_cmd_fill_info(struct datapath *dp, struct sk_buff *skb,
+				u32 pid, u32 seq, u32 flags, u8 cmd)
+{
+	struct ovs_header *ovs_header;
+	struct ovs_dp_stats dp_stats;
+	int err;
+
+	ovs_header = genlmsg_put(skb, pid, seq, &dp_datapath_genl_family,
+				   flags, cmd);
+	if (!ovs_header)
+		goto error;
+
+	ovs_header->dp_ifindex = get_dpifindex(dp);
+
+	rcu_read_lock();
+	err = nla_put_string(skb, OVS_DP_ATTR_NAME, dp_name(dp));
+	rcu_read_unlock();
+	if (err)
+		goto nla_put_failure;
+
+	get_dp_stats(dp, &dp_stats);
+	NLA_PUT(skb, OVS_DP_ATTR_STATS, sizeof(struct ovs_dp_stats), &dp_stats);
+
+	return genlmsg_end(skb, ovs_header);
+
+nla_put_failure:
+	genlmsg_cancel(skb, ovs_header);
+error:
+	return -EMSGSIZE;
+}
+
+static struct sk_buff *ovs_dp_cmd_build_info(struct datapath *dp, u32 pid,
+					     u32 seq, u8 cmd)
+{
+	struct sk_buff *skb;
+	int retval;
+
+	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!skb)
+		return ERR_PTR(-ENOMEM);
+
+	retval = ovs_dp_cmd_fill_info(dp, skb, pid, seq, 0, cmd);
+	if (retval < 0) {
+		kfree_skb(skb);
+		return ERR_PTR(retval);
+	}
+	return skb;
+}
+
+/* Called with genl_mutex and optionally with RTNL lock also. */
+static struct datapath *lookup_datapath(struct ovs_header *ovs_header,
+					struct nlattr *a[OVS_DP_ATTR_MAX + 1])
+{
+	struct datapath *dp;
+
+	if (!a[OVS_DP_ATTR_NAME])
+		dp = get_dp(ovs_header->dp_ifindex);
+	else {
+		struct vport *vport;
+
+		rcu_read_lock();
+		vport = vport_locate(nla_data(a[OVS_DP_ATTR_NAME]));
+		dp = vport && vport->port_no == OVSP_LOCAL ? vport->dp : NULL;
+		rcu_read_unlock();
+	}
+	return dp ? dp : ERR_PTR(-ENODEV);
+}
+
+static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
+{
+	struct nlattr **a = info->attrs;
+	struct vport_parms parms;
+	struct sk_buff *reply;
+	struct datapath *dp;
+	struct vport *vport;
+	int err;
+
+	err = -EINVAL;
+	if (!a[OVS_DP_ATTR_NAME] || !a[OVS_DP_ATTR_UPCALL_PID])
+		goto err;
+
+	rtnl_lock();
+	err = -ENODEV;
+	if (!try_module_get(THIS_MODULE))
+		goto err_unlock_rtnl;
+
+	err = -ENOMEM;
+	dp = kzalloc(sizeof(*dp), GFP_KERNEL);
+	if (dp == NULL)
+		goto err_put_module;
+	INIT_LIST_HEAD(&dp->port_list);
+
+	/* Allocate table. */
+	err = -ENOMEM;
+	rcu_assign_pointer(dp->table, flow_tbl_alloc(TBL_MIN_BUCKETS));
+	if (!dp->table)
+		goto err_free_dp;
+
+	dp->stats_percpu = alloc_percpu(struct dp_stats_percpu);
+	if (!dp->stats_percpu) {
+		err = -ENOMEM;
+		goto err_destroy_table;
+	}
+
+	/* Set up our datapath device. */
+	parms.name = nla_data(a[OVS_DP_ATTR_NAME]);
+	parms.type = OVS_VPORT_TYPE_INTERNAL;
+	parms.options = NULL;
+	parms.dp = dp;
+	parms.port_no = OVSP_LOCAL;
+	parms.upcall_pid = nla_get_u32(a[OVS_DP_ATTR_UPCALL_PID]);
+
+	vport = new_vport(&parms);
+	if (IS_ERR(vport)) {
+		err = PTR_ERR(vport);
+		if (err == -EBUSY)
+			err = -EEXIST;
+
+		goto err_destroy_percpu;
+	}
+
+	reply = ovs_dp_cmd_build_info(dp, info->snd_pid,
+				      info->snd_seq, OVS_DP_CMD_NEW);
+	err = PTR_ERR(reply);
+	if (IS_ERR(reply))
+		goto err_destroy_local_port;
+
+	list_add_tail(&dp->list_node, &dps);
+	rtnl_unlock();
+
+	genl_notify(reply, genl_info_net(info), info->snd_pid,
+		    dp_datapath_multicast_group.id, info->nlhdr, GFP_KERNEL);
+	return 0;
+
+err_destroy_local_port:
+	dp_detach_port(rtnl_dereference(dp->ports[OVSP_LOCAL]));
+err_destroy_percpu:
+	free_percpu(dp->stats_percpu);
+err_destroy_table:
+	flow_tbl_destroy(genl_dereference(dp->table));
+err_free_dp:
+	kfree(dp);
+err_put_module:
+	module_put(THIS_MODULE);
+err_unlock_rtnl:
+	rtnl_unlock();
+err:
+	return err;
+}
+
+static int ovs_dp_cmd_del(struct sk_buff *skb, struct genl_info *info)
+{
+	struct vport *vport, *next_vport;
+	struct sk_buff *reply;
+	struct datapath *dp;
+	int err;
+
+	rtnl_lock();
+	dp = lookup_datapath(info->userhdr, info->attrs);
+	err = PTR_ERR(dp);
+	if (IS_ERR(dp))
+		goto exit_unlock;
+
+	reply = ovs_dp_cmd_build_info(dp, info->snd_pid,
+				      info->snd_seq, OVS_DP_CMD_DEL);
+	err = PTR_ERR(reply);
+	if (IS_ERR(reply))
+		goto exit_unlock;
+
+	list_for_each_entry_safe(vport, next_vport, &dp->port_list, node)
+		if (vport->port_no != OVSP_LOCAL)
+			dp_detach_port(vport);
+
+	list_del(&dp->list_node);
+	dp_detach_port(rtnl_dereference(dp->ports[OVSP_LOCAL]));
+
+	/* rtnl_unlock() will wait until all the references to devices that
+	 * are pending unregistration have been dropped.  We do it here to
+	 * ensure that any internal devices (which contain DP pointers) are
+	 * fully destroyed before freeing the datapath.
+	 */
+	rtnl_unlock();
+
+	call_rcu(&dp->rcu, destroy_dp_rcu);
+	module_put(THIS_MODULE);
+
+	genl_notify(reply, genl_info_net(info), info->snd_pid,
+		    dp_datapath_multicast_group.id, info->nlhdr, GFP_KERNEL);
+
+	return 0;
+
+exit_unlock:
+	rtnl_unlock();
+	return err;
+}
+
+static int ovs_dp_cmd_set(struct sk_buff *skb, struct genl_info *info)
+{
+	struct sk_buff *reply;
+	struct datapath *dp;
+	int err;
+
+	dp = lookup_datapath(info->userhdr, info->attrs);
+	if (IS_ERR(dp))
+		return PTR_ERR(dp);
+
+	reply = ovs_dp_cmd_build_info(dp, info->snd_pid,
+				      info->snd_seq, OVS_DP_CMD_NEW);
+	if (IS_ERR(reply)) {
+		err = PTR_ERR(reply);
+		netlink_set_err(init_net.genl_sock, 0,
+				dp_datapath_multicast_group.id, err);
+		return 0;
+	}
+
+	genl_notify(reply, genl_info_net(info), info->snd_pid,
+		    dp_datapath_multicast_group.id, info->nlhdr, GFP_KERNEL);
+	return 0;
+}
+
+static int ovs_dp_cmd_get(struct sk_buff *skb, struct genl_info *info)
+{
+	struct sk_buff *reply;
+	struct datapath *dp;
+
+	dp = lookup_datapath(info->userhdr, info->attrs);
+	if (IS_ERR(dp))
+		return PTR_ERR(dp);
+
+	reply = ovs_dp_cmd_build_info(dp, info->snd_pid,
+				      info->snd_seq, OVS_DP_CMD_NEW);
+	if (IS_ERR(reply))
+		return PTR_ERR(reply);
+
+	return genlmsg_reply(reply, info);
+}
+
+static int ovs_dp_cmd_dump(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct datapath *dp;
+	int skip = cb->args[0];
+	int i = 0;
+
+	list_for_each_entry(dp, &dps, list_node) {
+		if (i < skip)
+			continue;
+		if (ovs_dp_cmd_fill_info(dp, skb, NETLINK_CB(cb->skb).pid,
+					 cb->nlh->nlmsg_seq, NLM_F_MULTI,
+					 OVS_DP_CMD_NEW) < 0)
+			break;
+		i++;
+	}
+
+	cb->args[0] = i;
+
+	return skb->len;
+}
+
+static struct genl_ops dp_datapath_genl_ops[] = {
+	{ .cmd = OVS_DP_CMD_NEW,
+	  .flags = GENL_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
+	  .policy = datapath_policy,
+	  .doit = ovs_dp_cmd_new
+	},
+	{ .cmd = OVS_DP_CMD_DEL,
+	  .flags = GENL_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
+	  .policy = datapath_policy,
+	  .doit = ovs_dp_cmd_del
+	},
+	{ .cmd = OVS_DP_CMD_GET,
+	  .flags = 0,		    /* OK for unprivileged users. */
+	  .policy = datapath_policy,
+	  .doit = ovs_dp_cmd_get,
+	  .dumpit = ovs_dp_cmd_dump
+	},
+	{ .cmd = OVS_DP_CMD_SET,
+	  .flags = GENL_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
+	  .policy = datapath_policy,
+	  .doit = ovs_dp_cmd_set,
+	},
+};
+
+static const struct nla_policy vport_policy[OVS_VPORT_ATTR_MAX + 1] = {
+	[OVS_VPORT_ATTR_NAME] = { .type = NLA_NUL_STRING, .len = IFNAMSIZ - 1 },
+	[OVS_VPORT_ATTR_STATS] = { .len = sizeof(struct ovs_vport_stats) },
+	[OVS_VPORT_ATTR_PORT_NO] = { .type = NLA_U32 },
+	[OVS_VPORT_ATTR_TYPE] = { .type = NLA_U32 },
+	[OVS_VPORT_ATTR_UPCALL_PID] = { .type = NLA_U32 },
+	[OVS_VPORT_ATTR_OPTIONS] = { .type = NLA_NESTED },
+};
+
+static struct genl_family dp_vport_genl_family = {
+	.id = GENL_ID_GENERATE,
+	.hdrsize = sizeof(struct ovs_header),
+	.name = OVS_VPORT_FAMILY,
+	.version = OVS_VPORT_VERSION,
+	.maxattr = OVS_VPORT_ATTR_MAX
+};
+
+struct genl_multicast_group dp_vport_multicast_group = {
+	.name = OVS_VPORT_MCGROUP
+};
+
+/* Called with RTNL lock or RCU read lock. */
+static int ovs_vport_cmd_fill_info(struct vport *vport, struct sk_buff *skb,
+				   u32 pid, u32 seq, u32 flags, u8 cmd)
+{
+	struct ovs_header *ovs_header;
+	struct ovs_vport_stats vport_stats;
+	int err;
+
+	ovs_header = genlmsg_put(skb, pid, seq, &dp_vport_genl_family,
+				 flags, cmd);
+	if (!ovs_header)
+		return -EMSGSIZE;
+
+	ovs_header->dp_ifindex = get_dpifindex(vport->dp);
+
+	NLA_PUT_U32(skb, OVS_VPORT_ATTR_PORT_NO, vport->port_no);
+	NLA_PUT_U32(skb, OVS_VPORT_ATTR_TYPE, vport->ops->type);
+	NLA_PUT_STRING(skb, OVS_VPORT_ATTR_NAME, vport->ops->get_name(vport));
+	NLA_PUT_U32(skb, OVS_VPORT_ATTR_UPCALL_PID, vport->upcall_pid);
+
+	vport_get_stats(vport, &vport_stats);
+	NLA_PUT(skb, OVS_VPORT_ATTR_STATS, sizeof(struct ovs_vport_stats),
+		&vport_stats);
+
+	err = vport_get_options(vport, skb);
+	if (err == -EMSGSIZE)
+		goto error;
+
+	return genlmsg_end(skb, ovs_header);
+
+nla_put_failure:
+	err = -EMSGSIZE;
+error:
+	genlmsg_cancel(skb, ovs_header);
+	return err;
+}
+
+/* Called with RTNL lock or RCU read lock. */
+struct sk_buff *ovs_vport_cmd_build_info(struct vport *vport, u32 pid,
+					 u32 seq, u8 cmd)
+{
+	struct sk_buff *skb;
+	int retval;
+
+	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_ATOMIC);
+	if (!skb)
+		return ERR_PTR(-ENOMEM);
+
+	retval = ovs_vport_cmd_fill_info(vport, skb, pid, seq, 0, cmd);
+	if (retval < 0) {
+		kfree_skb(skb);
+		return ERR_PTR(retval);
+	}
+	return skb;
+}
+
+/* Called with RTNL lock or RCU read lock. */
+static struct vport *lookup_vport(struct ovs_header *ovs_header,
+				  struct nlattr *a[OVS_VPORT_ATTR_MAX + 1])
+{
+	struct datapath *dp;
+	struct vport *vport;
+
+	if (a[OVS_VPORT_ATTR_NAME]) {
+		vport = vport_locate(nla_data(a[OVS_VPORT_ATTR_NAME]));
+		if (!vport)
+			return ERR_PTR(-ENODEV);
+		return vport;
+	} else if (a[OVS_VPORT_ATTR_PORT_NO]) {
+		u32 port_no = nla_get_u32(a[OVS_VPORT_ATTR_PORT_NO]);
+
+		if (port_no >= DP_MAX_PORTS)
+			return ERR_PTR(-EFBIG);
+
+		dp = get_dp(ovs_header->dp_ifindex);
+		if (!dp)
+			return ERR_PTR(-ENODEV);
+
+		vport = rcu_dereference_rtnl(dp->ports[port_no]);
+		if (!vport)
+			return ERR_PTR(-ENOENT);
+		return vport;
+	} else
+		return ERR_PTR(-EINVAL);
+}
+
+static int ovs_vport_cmd_new(struct sk_buff *skb, struct genl_info *info)
+{
+	struct nlattr **a = info->attrs;
+	struct ovs_header *ovs_header = info->userhdr;
+	struct vport_parms parms;
+	struct sk_buff *reply;
+	struct vport *vport;
+	struct datapath *dp;
+	u32 port_no;
+	int err;
+
+	err = -EINVAL;
+	if (!a[OVS_VPORT_ATTR_NAME] || !a[OVS_VPORT_ATTR_TYPE] ||
+	    !a[OVS_VPORT_ATTR_UPCALL_PID])
+		goto exit;
+
+	rtnl_lock();
+	dp = get_dp(ovs_header->dp_ifindex);
+	err = -ENODEV;
+	if (!dp)
+		goto exit_unlock;
+
+	if (a[OVS_VPORT_ATTR_PORT_NO]) {
+		port_no = nla_get_u32(a[OVS_VPORT_ATTR_PORT_NO]);
+
+		err = -EFBIG;
+		if (port_no >= DP_MAX_PORTS)
+			goto exit_unlock;
+
+		vport = rtnl_dereference(dp->ports[port_no]);
+		err = -EBUSY;
+		if (vport)
+			goto exit_unlock;
+	} else {
+		for (port_no = 1; ; port_no++) {
+			if (port_no >= DP_MAX_PORTS) {
+				err = -EFBIG;
+				goto exit_unlock;
+			}
+			vport = rtnl_dereference(dp->ports[port_no]);
+			if (!vport)
+				break;
+		}
+	}
+
+	parms.name = nla_data(a[OVS_VPORT_ATTR_NAME]);
+	parms.type = nla_get_u32(a[OVS_VPORT_ATTR_TYPE]);
+	parms.options = a[OVS_VPORT_ATTR_OPTIONS];
+	parms.dp = dp;
+	parms.port_no = port_no;
+	parms.upcall_pid = nla_get_u32(a[OVS_VPORT_ATTR_UPCALL_PID]);
+
+	vport = new_vport(&parms);
+	err = PTR_ERR(vport);
+	if (IS_ERR(vport))
+		goto exit_unlock;
+
+	reply = ovs_vport_cmd_build_info(vport, info->snd_pid, info->snd_seq,
+					 OVS_VPORT_CMD_NEW);
+	if (IS_ERR(reply)) {
+		err = PTR_ERR(reply);
+		dp_detach_port(vport);
+		goto exit_unlock;
+	}
+	genl_notify(reply, genl_info_net(info), info->snd_pid,
+		    dp_vport_multicast_group.id, info->nlhdr, GFP_KERNEL);
+
+
+exit_unlock:
+	rtnl_unlock();
+exit:
+	return err;
+}
+
+static int ovs_vport_cmd_set(struct sk_buff *skb, struct genl_info *info)
+{
+	struct nlattr **a = info->attrs;
+	struct sk_buff *reply;
+	struct vport *vport;
+	int err;
+
+	rtnl_lock();
+	vport = lookup_vport(info->userhdr, a);
+	err = PTR_ERR(vport);
+	if (IS_ERR(vport))
+		goto exit_unlock;
+
+	err = 0;
+	if (a[OVS_VPORT_ATTR_TYPE] &&
+	    nla_get_u32(a[OVS_VPORT_ATTR_TYPE]) != vport->ops->type)
+		err = -EINVAL;
+
+	if (!err && a[OVS_VPORT_ATTR_OPTIONS])
+		err = vport_set_options(vport, a[OVS_VPORT_ATTR_OPTIONS]);
+	if (!err && a[OVS_VPORT_ATTR_UPCALL_PID])
+		vport->upcall_pid = nla_get_u32(a[OVS_VPORT_ATTR_UPCALL_PID]);
+
+	reply = ovs_vport_cmd_build_info(vport, info->snd_pid, info->snd_seq,
+					 OVS_VPORT_CMD_NEW);
+	if (IS_ERR(reply)) {
+		err = PTR_ERR(reply);
+		netlink_set_err(init_net.genl_sock, 0,
+				dp_vport_multicast_group.id, err);
+		return 0;
+	}
+
+	genl_notify(reply, genl_info_net(info), info->snd_pid,
+		    dp_vport_multicast_group.id, info->nlhdr, GFP_KERNEL);
+
+exit_unlock:
+	rtnl_unlock();
+	return err;
+}
+
+static int ovs_vport_cmd_del(struct sk_buff *skb, struct genl_info *info)
+{
+	struct nlattr **a = info->attrs;
+	struct sk_buff *reply;
+	struct vport *vport;
+	int err;
+
+	rtnl_lock();
+	vport = lookup_vport(info->userhdr, a);
+	err = PTR_ERR(vport);
+	if (IS_ERR(vport))
+		goto exit_unlock;
+
+	if (vport->port_no == OVSP_LOCAL) {
+		err = -EINVAL;
+		goto exit_unlock;
+	}
+
+	reply = ovs_vport_cmd_build_info(vport, info->snd_pid, info->snd_seq,
+					 OVS_VPORT_CMD_DEL);
+	err = PTR_ERR(reply);
+	if (IS_ERR(reply))
+		goto exit_unlock;
+
+	dp_detach_port(vport);
+
+	genl_notify(reply, genl_info_net(info), info->snd_pid,
+		    dp_vport_multicast_group.id, info->nlhdr, GFP_KERNEL);
+
+exit_unlock:
+	rtnl_unlock();
+	return err;
+}
+
+static int ovs_vport_cmd_get(struct sk_buff *skb, struct genl_info *info)
+{
+	struct nlattr **a = info->attrs;
+	struct ovs_header *ovs_header = info->userhdr;
+	struct sk_buff *reply;
+	struct vport *vport;
+	int err;
+
+	rcu_read_lock();
+	vport = lookup_vport(ovs_header, a);
+	err = PTR_ERR(vport);
+	if (IS_ERR(vport))
+		goto exit_unlock;
+
+	reply = ovs_vport_cmd_build_info(vport, info->snd_pid, info->snd_seq,
+					 OVS_VPORT_CMD_NEW);
+	err = PTR_ERR(reply);
+	if (IS_ERR(reply))
+		goto exit_unlock;
+
+	rcu_read_unlock();
+
+	return genlmsg_reply(reply, info);
+
+exit_unlock:
+	rcu_read_unlock();
+	return err;
+}
+
+static int ovs_vport_cmd_dump(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct ovs_header *ovs_header = genlmsg_data(nlmsg_data(cb->nlh));
+	struct datapath *dp;
+	u32 port_no;
+	int retval;
+
+	dp = get_dp(ovs_header->dp_ifindex);
+	if (!dp)
+		return -ENODEV;
+
+	rcu_read_lock();
+	for (port_no = cb->args[0]; port_no < DP_MAX_PORTS; port_no++) {
+		struct vport *vport;
+
+		vport = rcu_dereference(dp->ports[port_no]);
+		if (!vport)
+			continue;
+
+		if (ovs_vport_cmd_fill_info(vport, skb, NETLINK_CB(cb->skb).pid,
+					    cb->nlh->nlmsg_seq, NLM_F_MULTI,
+					    OVS_VPORT_CMD_NEW) < 0)
+			break;
+	}
+	rcu_read_unlock();
+
+	cb->args[0] = port_no;
+	retval = skb->len;
+
+	return retval;
+}
+
+static struct genl_ops dp_vport_genl_ops[] = {
+	{ .cmd = OVS_VPORT_CMD_NEW,
+	  .flags = GENL_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
+	  .policy = vport_policy,
+	  .doit = ovs_vport_cmd_new
+	},
+	{ .cmd = OVS_VPORT_CMD_DEL,
+	  .flags = GENL_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
+	  .policy = vport_policy,
+	  .doit = ovs_vport_cmd_del
+	},
+	{ .cmd = OVS_VPORT_CMD_GET,
+	  .flags = 0,		    /* OK for unprivileged users. */
+	  .policy = vport_policy,
+	  .doit = ovs_vport_cmd_get,
+	  .dumpit = ovs_vport_cmd_dump
+	},
+	{ .cmd = OVS_VPORT_CMD_SET,
+	  .flags = GENL_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
+	  .policy = vport_policy,
+	  .doit = ovs_vport_cmd_set,
+	},
+};
+
+struct genl_family_and_ops {
+	struct genl_family *family;
+	struct genl_ops *ops;
+	int n_ops;
+	struct genl_multicast_group *group;
+};
+
+static const struct genl_family_and_ops dp_genl_families[] = {
+	{ &dp_datapath_genl_family,
+	  dp_datapath_genl_ops, ARRAY_SIZE(dp_datapath_genl_ops),
+	  &dp_datapath_multicast_group },
+	{ &dp_vport_genl_family,
+	  dp_vport_genl_ops, ARRAY_SIZE(dp_vport_genl_ops),
+	  &dp_vport_multicast_group },
+	{ &dp_flow_genl_family,
+	  dp_flow_genl_ops, ARRAY_SIZE(dp_flow_genl_ops),
+	  &dp_flow_multicast_group },
+	{ &dp_packet_genl_family,
+	  dp_packet_genl_ops, ARRAY_SIZE(dp_packet_genl_ops),
+	  NULL },
+};
+
+static void dp_unregister_genl(int n_families)
+{
+	int i;
+
+	for (i = 0; i < n_families; i++)
+		genl_unregister_family(dp_genl_families[i].family);
+}
+
+static int dp_register_genl(void)
+{
+	int n_registered;
+	int err;
+	int i;
+
+	n_registered = 0;
+	for (i = 0; i < ARRAY_SIZE(dp_genl_families); i++) {
+		const struct genl_family_and_ops *f = &dp_genl_families[i];
+
+		err = genl_register_family_with_ops(f->family, f->ops,
+						    f->n_ops);
+		if (err)
+			goto error;
+		n_registered++;
+
+		if (f->group) {
+			err = genl_register_mc_group(f->family, f->group);
+			if (err)
+				goto error;
+		}
+	}
+
+	return 0;
+
+error:
+	dp_unregister_genl(n_registered);
+	return err;
+}
+
+static int __init dp_init(void)
+{
+	struct sk_buff *dummy_skb;
+	int err;
+
+	BUILD_BUG_ON(sizeof(struct ovs_skb_cb) > sizeof(dummy_skb->cb));
+
+	pr_info("Open vSwitch switching datapath\n");
+
+	err = flow_init();
+	if (err)
+		goto error;
+
+	err = vport_init();
+	if (err)
+		goto error_flow_exit;
+
+	err = register_netdevice_notifier(&dp_device_notifier);
+	if (err)
+		goto error_vport_exit;
+
+	err = dp_register_genl();
+	if (err < 0)
+		goto error_unreg_notifier;
+
+	return 0;
+
+error_unreg_notifier:
+	unregister_netdevice_notifier(&dp_device_notifier);
+error_vport_exit:
+	vport_exit();
+error_flow_exit:
+	flow_exit();
+error:
+	return err;
+}
+
+static void dp_cleanup(void)
+{
+	rcu_barrier();
+	dp_unregister_genl(ARRAY_SIZE(dp_genl_families));
+	unregister_netdevice_notifier(&dp_device_notifier);
+	vport_exit();
+	flow_exit();
+}
+
+module_init(dp_init);
+module_exit(dp_cleanup);
+
+MODULE_DESCRIPTION("Open vSwitch switching datapath");
+MODULE_LICENSE("GPL");
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
new file mode 100644
index 0000000..f0f65e6
--- /dev/null
+++ b/net/openvswitch/datapath.h
@@ -0,0 +1,125 @@
+/*
+ * Copyright (c) 2007-2011 Nicira Networks.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ */
+
+#ifndef DATAPATH_H
+#define DATAPATH_H 1
+
+#include <asm/page.h>
+#include <linux/kernel.h>
+#include <linux/mutex.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <linux/u64_stats_sync.h>
+#include <linux/version.h>
+
+#include "flow.h"
+
+struct vport;
+
+#define DP_MAX_PORTS 1024
+#define SAMPLE_ACTION_DEPTH 3
+
+/**
+ * struct dp_stats_percpu - per-cpu packet processing statistics for a given
+ * datapath.
+ * @n_hit: Number of received packets for which a matching flow was found in
+ * the flow table.
+ * @n_miss: Number of received packets that had no matching flow in the flow
+ * table.  The sum of @n_hit and @n_miss is the number of packets that have
+ * been received by the datapath.
+ * @n_lost: Number of received packets that had no matching flow in the flow
+ * table that could not be sent to userspace (normally due to an overflow in
+ * one of the datapath's queues).
+ */
+struct dp_stats_percpu {
+	u64 n_hit;
+	u64 n_missed;
+	u64 n_lost;
+	struct u64_stats_sync sync;
+};
+
+/**
+ * struct datapath - datapath for flow-based packet switching
+ * @rcu: RCU callback head for deferred destruction.
+ * @list_node: Element in global 'dps' list.
+ * @n_flows: Number of flows currently in flow table.
+ * @table: Current flow table.  Protected by genl_lock and RCU.
+ * @ports: Map from port number to &struct vport.  %OVSP_LOCAL port
+ * always exists, other ports may be %NULL.  Protected by RTNL and RCU.
+ * @port_list: List of all ports in @ports in arbitrary order.  RTNL required
+ * to iterate or modify.
+ * @stats_percpu: Per-CPU datapath statistics.
+ *
+ * Context: See the comment on locking at the top of datapath.c for additional
+ * locking information.
+ */
+struct datapath {
+	struct rcu_head rcu;
+	struct list_head list_node;
+
+	/* Flow table. */
+	struct flow_table __rcu *table;
+
+	/* Switch ports. */
+	struct vport __rcu *ports[DP_MAX_PORTS];
+	struct list_head port_list;
+
+	/* Stats. */
+	struct dp_stats_percpu __percpu *stats_percpu;
+};
+
+/**
+ * struct ovs_skb_cb - OVS data in skb CB
+ * @flow: The flow associated with this packet.  May be %NULL if no flow.
+ */
+struct ovs_skb_cb {
+	struct sw_flow		*flow;
+};
+#define OVS_CB(skb) ((struct ovs_skb_cb *)(skb)->cb)
+
+/**
+ * struct dp_upcall - metadata to include with a packet to send to userspace
+ * @cmd: One of %OVS_PACKET_CMD_*.
+ * @key: Becomes %OVS_PACKET_ATTR_KEY.  Must be nonnull.
+ * @userdata: If nonnull, its u64 value is extracted and passed to userspace as
+ * %OVS_PACKET_ATTR_USERDATA.
+ * @pid: Netlink PID to which packet should be sent.  If @pid is 0 then no
+ * packet is sent and the packet is accounted in the datapath's @n_lost
+ * counter.
+ */
+struct dp_upcall_info {
+	u8 cmd;
+	const struct sw_flow_key *key;
+	const struct nlattr *userdata;
+	u32 pid;
+};
+
+extern struct notifier_block dp_device_notifier;
+extern struct genl_multicast_group dp_vport_multicast_group;
+
+void dp_process_received_packet(struct vport *, struct sk_buff *);
+void dp_detach_port(struct vport *);
+int dp_upcall(struct datapath *, struct sk_buff *,
+	      const struct dp_upcall_info *);
+
+const char *dp_name(const struct datapath *dp);
+struct sk_buff *ovs_vport_cmd_build_info(struct vport *, u32 pid, u32 seq,
+					 u8 cmd);
+
+int execute_actions(struct datapath *dp, struct sk_buff *skb);
+#endif /* datapath.h */
diff --git a/net/openvswitch/dp_notify.c b/net/openvswitch/dp_notify.c
new file mode 100644
index 0000000..be1a539
--- /dev/null
+++ b/net/openvswitch/dp_notify.c
@@ -0,0 +1,67 @@
+/*
+ * Copyright (c) 2007-2011 Nicira Networks.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ */
+
+#include <linux/netdevice.h>
+#include <net/genetlink.h>
+
+#include "datapath.h"
+#include "vport-internal_dev.h"
+#include "vport-netdev.h"
+
+static int dp_device_event(struct notifier_block *unused, unsigned long event,
+			   void *ptr)
+{
+	struct net_device *dev = ptr;
+	struct vport *vport;
+
+	if (is_internal_dev(dev))
+		vport = internal_dev_get_vport(dev);
+	else
+		vport = netdev_get_vport(dev);
+
+	if (!vport)
+		return NOTIFY_DONE;
+
+	switch (event) {
+	case NETDEV_UNREGISTER:
+		if (!is_internal_dev(dev)) {
+			struct sk_buff *notify;
+
+			notify = ovs_vport_cmd_build_info(vport, 0, 0,
+							  OVS_VPORT_CMD_DEL);
+			dp_detach_port(vport);
+			if (IS_ERR(notify)) {
+				netlink_set_err(init_net.genl_sock, 0,
+						dp_vport_multicast_group.id,
+						PTR_ERR(notify));
+				break;
+			}
+
+			genlmsg_multicast(notify, 0, dp_vport_multicast_group.id,
+					  GFP_KERNEL);
+		}
+		break;
+
+	}
+
+	return NOTIFY_DONE;
+}
+
+struct notifier_block dp_device_notifier = {
+	.notifier_call = dp_device_event
+};
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
new file mode 100644
index 0000000..77c16c7
--- /dev/null
+++ b/net/openvswitch/flow.c
@@ -0,0 +1,1373 @@
+/*
+ * Copyright (c) 2007-2011 Nicira Networks.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ */
+
+#include "flow.h"
+#include "datapath.h"
+#include <linux/uaccess.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/if_ether.h>
+#include <linux/if_vlan.h>
+#include <net/llc_pdu.h>
+#include <linux/kernel.h>
+#include <linux/jhash.h>
+#include <linux/jiffies.h>
+#include <linux/llc.h>
+#include <linux/module.h>
+#include <linux/in.h>
+#include <linux/rcupdate.h>
+#include <linux/if_arp.h>
+#include <linux/if_ether.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <linux/tcp.h>
+#include <linux/udp.h>
+#include <linux/icmp.h>
+#include <linux/icmpv6.h>
+#include <linux/rculist.h>
+#include <net/ip.h>
+#include <net/ipv6.h>
+#include <net/ndisc.h>
+
+static struct kmem_cache *flow_cache;
+static unsigned int hash_seed __read_mostly;
+
+static int check_header(struct sk_buff *skb, int len)
+{
+	if (unlikely(skb->len < len))
+		return -EINVAL;
+	if (unlikely(!pskb_may_pull(skb, len)))
+		return -ENOMEM;
+	return 0;
+}
+
+static bool arphdr_ok(struct sk_buff *skb)
+{
+	return pskb_may_pull(skb, skb_network_offset(skb) +
+				  sizeof(struct arp_eth_header));
+}
+
+static int check_iphdr(struct sk_buff *skb)
+{
+	unsigned int nh_ofs = skb_network_offset(skb);
+	unsigned int ip_len;
+	int err;
+
+	err = check_header(skb, nh_ofs + sizeof(struct iphdr));
+	if (unlikely(err))
+		return err;
+
+	ip_len = ip_hdrlen(skb);
+	if (unlikely(ip_len < sizeof(struct iphdr) ||
+		     skb->len < nh_ofs + ip_len))
+		return -EINVAL;
+
+	skb_set_transport_header(skb, nh_ofs + ip_len);
+	return 0;
+}
+
+static bool tcphdr_ok(struct sk_buff *skb)
+{
+	int th_ofs = skb_transport_offset(skb);
+	int tcp_len;
+
+	if (unlikely(!pskb_may_pull(skb, th_ofs + sizeof(struct tcphdr))))
+		return false;
+
+	tcp_len = tcp_hdrlen(skb);
+	if (unlikely(tcp_len < sizeof(struct tcphdr) ||
+		     skb->len < th_ofs + tcp_len))
+		return false;
+
+	return true;
+}
+
+static bool udphdr_ok(struct sk_buff *skb)
+{
+	return pskb_may_pull(skb, skb_transport_offset(skb) +
+				  sizeof(struct udphdr));
+}
+
+static bool icmphdr_ok(struct sk_buff *skb)
+{
+	return pskb_may_pull(skb, skb_transport_offset(skb) +
+				  sizeof(struct icmphdr));
+}
+
+u64 flow_used_time(unsigned long flow_jiffies)
+{
+	struct timespec cur_ts;
+	u64 cur_ms, idle_ms;
+
+	ktime_get_ts(&cur_ts);
+	idle_ms = jiffies_to_msecs(jiffies - flow_jiffies);
+	cur_ms = (u64)cur_ts.tv_sec * MSEC_PER_SEC +
+		 cur_ts.tv_nsec / NSEC_PER_MSEC;
+
+	return cur_ms - idle_ms;
+}
+
+#define SW_FLOW_KEY_OFFSET(field)		\
+	(offsetof(struct sw_flow_key, field) +	\
+	 FIELD_SIZEOF(struct sw_flow_key, field))
+
+/**
+ * skip_exthdr - skip any IPv6 extension headers
+ * @skb: skbuff to parse
+ * @start: offset of first extension header
+ * @nexthdrp: Initially, points to the type of the extension header at @start.
+ * This function updates it to point to the extension header at the final
+ * offset.
+ * @frag: Points to the @frag member in a &struct sw_flow_key.  This
+ * function sets an appropriate %OVS_FRAG_TYPE_* value.
+ *
+ * This is based on ipv6_skip_exthdr() but adds the updates to *@frag.
+ *
+ * When there is more than one fragment header, this version reports whether
+ * the final fragment header that it examines is a first fragment.
+ *
+ * Returns the final payload offset, or -1 on error.
+ */
+static int skip_exthdr(const struct sk_buff *skb, int start, u8 *nexthdrp,
+		       u8 *frag)
+{
+	u8 nexthdr = *nexthdrp;
+
+	while (ipv6_ext_hdr(nexthdr)) {
+		struct ipv6_opt_hdr _hdr, *hp;
+		int hdrlen;
+
+		if (nexthdr == NEXTHDR_NONE)
+			return -1;
+		hp = skb_header_pointer(skb, start, sizeof(_hdr), &_hdr);
+		if (hp == NULL)
+			return -1;
+		if (nexthdr == NEXTHDR_FRAGMENT) {
+			__be16 _frag_off, *fp;
+			fp = skb_header_pointer(skb,
+						start+offsetof(struct frag_hdr,
+							       frag_off),
+						sizeof(_frag_off),
+						&_frag_off);
+			if (fp == NULL)
+				return -1;
+
+			if (ntohs(*fp) & ~0x7) {
+				*frag = OVS_FRAG_TYPE_LATER;
+				break;
+			}
+			*frag = OVS_FRAG_TYPE_FIRST;
+			hdrlen = 8;
+		} else if (nexthdr == NEXTHDR_AUTH)
+			hdrlen = (hp->hdrlen+2)<<2;
+		else
+			hdrlen = ipv6_optlen(hp);
+
+		nexthdr = hp->nexthdr;
+		start += hdrlen;
+	}
+
+	*nexthdrp = nexthdr;
+	return start;
+}
+
+static int parse_ipv6hdr(struct sk_buff *skb, struct sw_flow_key *key,
+			 int *key_lenp)
+{
+	unsigned int nh_ofs = skb_network_offset(skb);
+	unsigned int nh_len;
+	int payload_ofs;
+	struct ipv6hdr *nh;
+	uint8_t nexthdr;
+	int err;
+
+	*key_lenp = SW_FLOW_KEY_OFFSET(ipv6.label);
+
+	err = check_header(skb, nh_ofs + sizeof(*nh));
+	if (unlikely(err))
+		return err;
+
+	nh = ipv6_hdr(skb);
+	nexthdr = nh->nexthdr;
+	payload_ofs = (u8 *)(nh + 1) - skb->data;
+
+	key->ip.proto = NEXTHDR_NONE;
+	key->ip.tos = ipv6_get_dsfield(nh);
+	key->ip.ttl = nh->hop_limit;
+	key->ipv6.label = *(__be32 *)nh & htonl(IPV6_FLOWINFO_FLOWLABEL);
+	ipv6_addr_copy(&key->ipv6.addr.src, &nh->saddr);
+	ipv6_addr_copy(&key->ipv6.addr.dst, &nh->daddr);
+
+	payload_ofs = skip_exthdr(skb, payload_ofs, &nexthdr, &key->ip.frag);
+	if (unlikely(payload_ofs < 0))
+		return -EINVAL;
+
+	nh_len = payload_ofs - nh_ofs;
+	skb_set_transport_header(skb, nh_ofs + nh_len);
+	key->ip.proto = nexthdr;
+	return nh_len;
+}
+
+static bool icmp6hdr_ok(struct sk_buff *skb)
+{
+	return pskb_may_pull(skb, skb_transport_offset(skb) +
+				  sizeof(struct icmp6hdr));
+}
+
+#define TCP_FLAGS_OFFSET 13
+#define TCP_FLAG_MASK 0x3f
+
+void flow_used(struct sw_flow *flow, struct sk_buff *skb)
+{
+	u8 tcp_flags = 0;
+
+	if (flow->key.eth.type == htons(ETH_P_IP) &&
+	    flow->key.ip.proto == IPPROTO_TCP) {
+		u8 *tcp = (u8 *)tcp_hdr(skb);
+		tcp_flags = *(tcp + TCP_FLAGS_OFFSET) & TCP_FLAG_MASK;
+	}
+
+	spin_lock(&flow->lock);
+	flow->used = jiffies;
+	flow->packet_count++;
+	flow->byte_count += skb->len;
+	flow->tcp_flags |= tcp_flags;
+	spin_unlock(&flow->lock);
+}
+
+struct sw_flow_actions *flow_actions_alloc(const struct nlattr *actions)
+{
+	int actions_len = nla_len(actions);
+	struct sw_flow_actions *sfa;
+
+	/* At least DP_MAX_PORTS actions are required to be able to flood a
+	 * packet to every port.  Factor of 2 allows for setting VLAN tags,
+	 * etc. */
+	if (actions_len > 2 * DP_MAX_PORTS * nla_total_size(4))
+		return ERR_PTR(-EINVAL);
+
+	sfa = kmalloc(sizeof(*sfa) + actions_len, GFP_KERNEL);
+	if (!sfa)
+		return ERR_PTR(-ENOMEM);
+
+	sfa->actions_len = actions_len;
+	memcpy(sfa->actions, nla_data(actions), actions_len);
+	return sfa;
+}
+
+struct sw_flow *flow_alloc(void)
+{
+	struct sw_flow *flow;
+
+	flow = kmem_cache_alloc(flow_cache, GFP_KERNEL);
+	if (!flow)
+		return ERR_PTR(-ENOMEM);
+
+	spin_lock_init(&flow->lock);
+	flow->sf_acts = NULL;
+
+	return flow;
+}
+
+static struct hlist_head *find_bucket(struct flow_table *table, u32 hash)
+{
+	return flex_array_get(table->buckets,
+				(hash & (table->n_buckets - 1)));
+}
+
+static struct flex_array *alloc_buckets(unsigned int n_buckets)
+{
+	struct flex_array *buckets;
+	int i, err;
+
+	buckets = flex_array_alloc(sizeof(struct hlist_head *),
+				   n_buckets, GFP_KERNEL);
+	if (!buckets)
+		return NULL;
+
+	err = flex_array_prealloc(buckets, 0, n_buckets, GFP_KERNEL);
+	if (err) {
+		flex_array_free(buckets);
+		return NULL;
+	}
+
+	for (i = 0; i < n_buckets; i++)
+		INIT_HLIST_HEAD((struct hlist_head *)
+					flex_array_get(buckets, i));
+
+	return buckets;
+}
+
+static void free_buckets(struct flex_array *buckets)
+{
+	flex_array_free(buckets);
+}
+
+struct flow_table *flow_tbl_alloc(int new_size)
+{
+	struct flow_table *table = kmalloc(sizeof(*table), GFP_KERNEL);
+
+	if (!table)
+		return NULL;
+
+	table->buckets = alloc_buckets(new_size);
+
+	if (!table->buckets) {
+		kfree(table);
+		return NULL;
+	}
+	table->n_buckets = new_size;
+	table->count = 0;
+
+	return table;
+}
+
+void flow_tbl_destroy(struct flow_table *table)
+{
+	int i;
+
+	if (!table)
+		return;
+
+	for (i = 0; i < table->n_buckets; i++) {
+		struct sw_flow *flow;
+		struct hlist_head *head = flex_array_get(table->buckets, i);
+		struct hlist_node *node, *n;
+
+		hlist_for_each_entry_safe(flow, node, n, head, hash_node) {
+			hlist_del_init_rcu(&flow->hash_node);
+			flow_free(flow);
+		}
+	}
+
+	free_buckets(table->buckets);
+	kfree(table);
+}
+
+static void flow_tbl_destroy_rcu_cb(struct rcu_head *rcu)
+{
+	struct flow_table *table = container_of(rcu, struct flow_table, rcu);
+
+	flow_tbl_destroy(table);
+}
+
+void flow_tbl_deferred_destroy(struct flow_table *table)
+{
+	if (!table)
+		return;
+
+	call_rcu(&table->rcu, flow_tbl_destroy_rcu_cb);
+}
+
+struct sw_flow *flow_tbl_next(struct flow_table *table, u32 *bucket, u32 *last)
+{
+	struct sw_flow *flow;
+	struct hlist_head *head;
+	struct hlist_node *n;
+	int i;
+
+	while (*bucket < table->n_buckets) {
+		i = 0;
+		head = flex_array_get(table->buckets, *bucket);
+		hlist_for_each_entry_rcu(flow, n, head, hash_node) {
+			if (i < *last) {
+				i++;
+				continue;
+			}
+			*last = i + 1;
+			return flow;
+		}
+		(*bucket)++;
+		*last = 0;
+	}
+
+	return NULL;
+}
+
+struct flow_table *flow_tbl_expand(struct flow_table *table)
+{
+	struct flow_table *new_table;
+	int n_buckets = table->n_buckets * 2;
+	int i;
+
+	new_table = flow_tbl_alloc(n_buckets);
+	if (!new_table)
+		return ERR_PTR(-ENOMEM);
+
+	for (i = 0; i < table->n_buckets; i++) {
+		struct sw_flow *flow;
+		struct hlist_head *head;
+		struct hlist_node *n, *pos;
+
+		head = flex_array_get(table->buckets, i);
+
+		hlist_for_each_entry_safe(flow, n, pos, head, hash_node) {
+			hlist_del_init_rcu(&flow->hash_node);
+			flow_tbl_insert(new_table, flow);
+		}
+	}
+
+	return new_table;
+}
+
+void flow_free(struct sw_flow *flow)
+{
+	if (unlikely(!flow))
+		return;
+
+	kfree((struct sf_flow_acts __force *)flow->sf_acts);
+	kmem_cache_free(flow_cache, flow);
+}
+
+/* RCU callback used by flow_deferred_free. */
+static void rcu_free_flow_callback(struct rcu_head *rcu)
+{
+	struct sw_flow *flow = container_of(rcu, struct sw_flow, rcu);
+
+	flow_free(flow);
+}
+
+/* Schedules 'flow' to be freed after the next RCU grace period.
+ * The caller must hold rcu_read_lock for this to be sensible. */
+void flow_deferred_free(struct sw_flow *flow)
+{
+	call_rcu(&flow->rcu, rcu_free_flow_callback);
+}
+
+/* RCU callback used by flow_deferred_free_acts. */
+static void rcu_free_acts_callback(struct rcu_head *rcu)
+{
+	struct sw_flow_actions *sf_acts = container_of(rcu,
+			struct sw_flow_actions, rcu);
+	kfree(sf_acts);
+}
+
+/* Schedules 'sf_acts' to be freed after the next RCU grace period.
+ * The caller must hold rcu_read_lock for this to be sensible. */
+void flow_deferred_free_acts(struct sw_flow_actions *sf_acts)
+{
+	call_rcu(&sf_acts->rcu, rcu_free_acts_callback);
+}
+
+static int parse_vlan(struct sk_buff *skb, struct sw_flow_key *key)
+{
+	struct qtag_prefix {
+		__be16 eth_type; /* ETH_P_8021Q */
+		__be16 tci;
+	};
+	struct qtag_prefix *qp;
+
+	if (unlikely(skb->len < sizeof(struct qtag_prefix) + sizeof(__be16)))
+		return 0;
+
+	if (unlikely(!pskb_may_pull(skb, sizeof(struct qtag_prefix) +
+					 sizeof(__be16))))
+		return -ENOMEM;
+
+	qp = (struct qtag_prefix *) skb->data;
+	key->eth.tci = qp->tci | htons(VLAN_TAG_PRESENT);
+	__skb_pull(skb, sizeof(struct qtag_prefix));
+
+	return 0;
+}
+
+static __be16 parse_ethertype(struct sk_buff *skb)
+{
+	struct llc_snap_hdr {
+		u8  dsap;  /* Always 0xAA */
+		u8  ssap;  /* Always 0xAA */
+		u8  ctrl;
+		u8  oui[3];
+		__be16 ethertype;
+	};
+	struct llc_snap_hdr *llc;
+	__be16 proto;
+
+	proto = *(__be16 *) skb->data;
+	__skb_pull(skb, sizeof(__be16));
+
+	if (ntohs(proto) >= 1536)
+		return proto;
+
+	if (skb->len < sizeof(struct llc_snap_hdr))
+		return htons(ETH_P_802_2);
+
+	if (unlikely(!pskb_may_pull(skb, sizeof(struct llc_snap_hdr))))
+		return htons(0);
+
+	llc = (struct llc_snap_hdr *) skb->data;
+	if (llc->dsap != LLC_SAP_SNAP ||
+	    llc->ssap != LLC_SAP_SNAP ||
+	    (llc->oui[0] | llc->oui[1] | llc->oui[2]) != 0)
+		return htons(ETH_P_802_2);
+
+	__skb_pull(skb, sizeof(struct llc_snap_hdr));
+	return llc->ethertype;
+}
+
+static int parse_icmpv6(struct sk_buff *skb, struct sw_flow_key *key,
+			int *key_lenp, int nh_len)
+{
+	struct icmp6hdr *icmp = icmp6_hdr(skb);
+	int error = 0;
+	int key_len;
+
+	/* The ICMPv6 type and code fields use the 16-bit transport port
+	 * fields, so we need to store them in 16-bit network byte order.
+	 */
+	key->ipv6.tp.src = htons(icmp->icmp6_type);
+	key->ipv6.tp.dst = htons(icmp->icmp6_code);
+	key_len = SW_FLOW_KEY_OFFSET(ipv6.tp);
+
+	if (icmp->icmp6_code == 0 &&
+	    (icmp->icmp6_type == NDISC_NEIGHBOUR_SOLICITATION ||
+	     icmp->icmp6_type == NDISC_NEIGHBOUR_ADVERTISEMENT)) {
+		int icmp_len = skb->len - skb_transport_offset(skb);
+		struct nd_msg *nd;
+		int offset;
+
+		key_len = SW_FLOW_KEY_OFFSET(ipv6.nd);
+
+		/* In order to process neighbor discovery options, we need the
+		 * entire packet.
+		 */
+		if (unlikely(icmp_len < sizeof(*nd)))
+			goto out;
+		if (unlikely(skb_linearize(skb))) {
+			error = -ENOMEM;
+			goto out;
+		}
+
+		nd = (struct nd_msg *)skb_transport_header(skb);
+		ipv6_addr_copy(&key->ipv6.nd.target, &nd->target);
+		key_len = SW_FLOW_KEY_OFFSET(ipv6.nd);
+
+		icmp_len -= sizeof(*nd);
+		offset = 0;
+		while (icmp_len >= 8) {
+			struct nd_opt_hdr *nd_opt =
+				 (struct nd_opt_hdr *)(nd->opt + offset);
+			int opt_len = nd_opt->nd_opt_len * 8;
+
+			if (unlikely(!opt_len || opt_len > icmp_len))
+				goto invalid;
+
+			/* Store the link layer address if the appropriate
+			 * option is provided.  It is considered an error if
+			 * the same link layer option is specified twice.
+			 */
+			if (nd_opt->nd_opt_type == ND_OPT_SOURCE_LL_ADDR
+			    && opt_len == 8) {
+				if (unlikely(!is_zero_ether_addr(key->ipv6.nd.sll)))
+					goto invalid;
+				memcpy(key->ipv6.nd.sll,
+				    &nd->opt[offset+sizeof(*nd_opt)], ETH_ALEN);
+			} else if (nd_opt->nd_opt_type == ND_OPT_TARGET_LL_ADDR
+				   && opt_len == 8) {
+				if (unlikely(!is_zero_ether_addr(key->ipv6.nd.tll)))
+					goto invalid;
+				memcpy(key->ipv6.nd.tll,
+				    &nd->opt[offset+sizeof(*nd_opt)], ETH_ALEN);
+			}
+
+			icmp_len -= opt_len;
+			offset += opt_len;
+		}
+	}
+
+	goto out;
+
+invalid:
+	memset(&key->ipv6.nd.target, 0, sizeof(key->ipv6.nd.target));
+	memset(key->ipv6.nd.sll, 0, sizeof(key->ipv6.nd.sll));
+	memset(key->ipv6.nd.tll, 0, sizeof(key->ipv6.nd.tll));
+
+out:
+	*key_lenp = key_len;
+	return error;
+}
+
+/**
+ * flow_extract - extracts a flow key from an Ethernet frame.
+ * @skb: sk_buff that contains the frame, with skb->data pointing to the
+ * Ethernet header
+ * @in_port: port number on which @skb was received.
+ * @key: output flow key
+ * @key_lenp: length of output flow key
+ *
+ * The caller must ensure that skb->len >= ETH_HLEN.
+ *
+ * Returns 0 if successful, otherwise a negative errno value.
+ *
+ * Initializes @skb header pointers as follows:
+ *
+ *    - skb->mac_header: the Ethernet header.
+ *
+ *    - skb->network_header: just past the Ethernet header, or just past the
+ *      VLAN header, to the first byte of the Ethernet payload.
+ *
+ *    - skb->transport_header: If key->dl_type is ETH_P_IP or ETH_P_IPV6
+ *      on output, then just past the IP header, if one is present and
+ *      of a correct length, otherwise the same as skb->network_header.
+ *      For other key->dl_type values it is left untouched.
+ */
+int flow_extract(struct sk_buff *skb, u16 in_port, struct sw_flow_key *key,
+		 int *key_lenp)
+{
+	int error = 0;
+	int key_len = SW_FLOW_KEY_OFFSET(eth);
+	struct ethhdr *eth;
+
+	memset(key, 0, sizeof(*key));
+
+	key->phy.priority = skb->priority;
+	key->phy.in_port = in_port;
+
+	skb_reset_mac_header(skb);
+
+	/* Link layer.  We are guaranteed to have at least the 14 byte Ethernet
+	 * header in the linear data area.
+	 */
+	eth = eth_hdr(skb);
+	memcpy(key->eth.src, eth->h_source, ETH_ALEN);
+	memcpy(key->eth.dst, eth->h_dest, ETH_ALEN);
+
+	__skb_pull(skb, 2 * ETH_ALEN);
+
+	if (vlan_tx_tag_present(skb))
+		key->eth.tci = htons(skb->vlan_tci);
+	else if (eth->h_proto == htons(ETH_P_8021Q))
+		if (unlikely(parse_vlan(skb, key)))
+			return -ENOMEM;
+
+	key->eth.type = parse_ethertype(skb);
+	if (unlikely(key->eth.type == htons(0)))
+		return -ENOMEM;
+
+	skb_reset_network_header(skb);
+	__skb_push(skb, skb->data - skb_mac_header(skb));
+
+	/* Network layer. */
+	if (key->eth.type == htons(ETH_P_IP)) {
+		struct iphdr *nh;
+		__be16 offset;
+
+		key_len = SW_FLOW_KEY_OFFSET(ipv4.addr);
+
+		error = check_iphdr(skb);
+		if (unlikely(error)) {
+			if (error == -EINVAL) {
+				skb->transport_header = skb->network_header;
+				error = 0;
+			}
+			goto out;
+		}
+
+		nh = ip_hdr(skb);
+		key->ipv4.addr.src = nh->saddr;
+		key->ipv4.addr.dst = nh->daddr;
+
+		key->ip.proto = nh->protocol;
+		key->ip.tos = nh->tos;
+		key->ip.ttl = nh->ttl;
+
+		offset = nh->frag_off & htons(IP_OFFSET);
+		if (offset) {
+			key->ip.frag = OVS_FRAG_TYPE_LATER;
+			goto out;
+		}
+		if (nh->frag_off & htons(IP_MF) ||
+			 skb_shinfo(skb)->gso_type & SKB_GSO_UDP)
+			key->ip.frag = OVS_FRAG_TYPE_FIRST;
+
+		/* Transport layer. */
+		if (key->ip.proto == IPPROTO_TCP) {
+			key_len = SW_FLOW_KEY_OFFSET(ipv4.tp);
+			if (tcphdr_ok(skb)) {
+				struct tcphdr *tcp = tcp_hdr(skb);
+				key->ipv4.tp.src = tcp->source;
+				key->ipv4.tp.dst = tcp->dest;
+			}
+		} else if (key->ip.proto == IPPROTO_UDP) {
+			key_len = SW_FLOW_KEY_OFFSET(ipv4.tp);
+			if (udphdr_ok(skb)) {
+				struct udphdr *udp = udp_hdr(skb);
+				key->ipv4.tp.src = udp->source;
+				key->ipv4.tp.dst = udp->dest;
+			}
+		} else if (key->ip.proto == IPPROTO_ICMP) {
+			key_len = SW_FLOW_KEY_OFFSET(ipv4.tp);
+			if (icmphdr_ok(skb)) {
+				struct icmphdr *icmp = icmp_hdr(skb);
+				/* The ICMP type and code fields use the 16-bit
+				 * transport port fields, so we need to store
+				 * them in 16-bit network byte order. */
+				key->ipv4.tp.src = htons(icmp->type);
+				key->ipv4.tp.dst = htons(icmp->code);
+			}
+		}
+
+	} else if (key->eth.type == htons(ETH_P_ARP) && arphdr_ok(skb)) {
+		struct arp_eth_header *arp;
+
+		arp = (struct arp_eth_header *)skb_network_header(skb);
+
+		if (arp->ar_hrd == htons(ARPHRD_ETHER)
+				&& arp->ar_pro == htons(ETH_P_IP)
+				&& arp->ar_hln == ETH_ALEN
+				&& arp->ar_pln == 4) {
+
+			/* We only match on the lower 8 bits of the opcode. */
+			if (ntohs(arp->ar_op) <= 0xff)
+				key->ip.proto = ntohs(arp->ar_op);
+
+			if (key->ip.proto == ARPOP_REQUEST
+					|| key->ip.proto == ARPOP_REPLY) {
+				memcpy(&key->ipv4.addr.src, arp->ar_sip, sizeof(key->ipv4.addr.src));
+				memcpy(&key->ipv4.addr.dst, arp->ar_tip, sizeof(key->ipv4.addr.dst));
+				memcpy(key->ipv4.arp.sha, arp->ar_sha, ETH_ALEN);
+				memcpy(key->ipv4.arp.tha, arp->ar_tha, ETH_ALEN);
+				key_len = SW_FLOW_KEY_OFFSET(ipv4.arp);
+			}
+		}
+	} else if (key->eth.type == htons(ETH_P_IPV6)) {
+		int nh_len;             /* IPv6 Header + Extensions */
+
+		nh_len = parse_ipv6hdr(skb, key, &key_len);
+		if (unlikely(nh_len < 0)) {
+			if (nh_len == -EINVAL)
+				skb->transport_header = skb->network_header;
+			else
+				error = nh_len;
+			goto out;
+		}
+
+		if (key->ip.frag == OVS_FRAG_TYPE_LATER)
+			goto out;
+		if (skb_shinfo(skb)->gso_type & SKB_GSO_UDP)
+			key->ip.frag = OVS_FRAG_TYPE_FIRST;
+
+		/* Transport layer. */
+		if (key->ip.proto == NEXTHDR_TCP) {
+			key_len = SW_FLOW_KEY_OFFSET(ipv6.tp);
+			if (tcphdr_ok(skb)) {
+				struct tcphdr *tcp = tcp_hdr(skb);
+				key->ipv6.tp.src = tcp->source;
+				key->ipv6.tp.dst = tcp->dest;
+			}
+		} else if (key->ip.proto == NEXTHDR_UDP) {
+			key_len = SW_FLOW_KEY_OFFSET(ipv6.tp);
+			if (udphdr_ok(skb)) {
+				struct udphdr *udp = udp_hdr(skb);
+				key->ipv6.tp.src = udp->source;
+				key->ipv6.tp.dst = udp->dest;
+			}
+		} else if (key->ip.proto == NEXTHDR_ICMP) {
+			key_len = SW_FLOW_KEY_OFFSET(ipv6.tp);
+			if (icmp6hdr_ok(skb)) {
+				error = parse_icmpv6(skb, key, &key_len, nh_len);
+				if (error < 0)
+					goto out;
+			}
+		}
+	}
+
+out:
+	*key_lenp = key_len;
+	return error;
+}
+
+u32 flow_hash(const struct sw_flow_key *key, int key_len)
+{
+	return jhash2((u32 *)key, DIV_ROUND_UP(key_len, sizeof(u32)), hash_seed);
+}
+
+struct sw_flow *flow_tbl_lookup(struct flow_table *table,
+				struct sw_flow_key *key, int key_len)
+{
+	struct sw_flow *flow;
+	struct hlist_node *n;
+	struct hlist_head *head;
+	u32 hash;
+
+	hash = flow_hash(key, key_len);
+
+	head = find_bucket(table, hash);
+	hlist_for_each_entry_rcu(flow, n, head, hash_node) {
+
+		if (flow->hash == hash &&
+		    !memcmp(&flow->key, key, key_len)) {
+			return flow;
+		}
+	}
+	return NULL;
+}
+
+void flow_tbl_insert(struct flow_table *table, struct sw_flow *flow)
+{
+	struct hlist_head *head;
+
+	head = find_bucket(table, flow->hash);
+	hlist_add_head_rcu(&flow->hash_node, head);
+	table->count++;
+}
+
+void flow_tbl_remove(struct flow_table *table, struct sw_flow *flow)
+{
+	if (!hlist_unhashed(&flow->hash_node)) {
+		hlist_del_init_rcu(&flow->hash_node);
+		table->count--;
+		BUG_ON(table->count < 0);
+	}
+}
+
+/* The size of the argument for each %OVS_KEY_ATTR_* Netlink attribute.  */
+const int ovs_key_lens[OVS_KEY_ATTR_MAX + 1] = {
+	[OVS_KEY_ATTR_ENCAP] = -1,
+	[OVS_KEY_ATTR_PRIORITY] = sizeof(u32),
+	[OVS_KEY_ATTR_IN_PORT] = sizeof(u32),
+	[OVS_KEY_ATTR_ETHERNET] = sizeof(struct ovs_key_ethernet),
+	[OVS_KEY_ATTR_VLAN] = sizeof(__be16),
+	[OVS_KEY_ATTR_ETHERTYPE] = sizeof(__be16),
+	[OVS_KEY_ATTR_IPV4] = sizeof(struct ovs_key_ipv4),
+	[OVS_KEY_ATTR_IPV6] = sizeof(struct ovs_key_ipv6),
+	[OVS_KEY_ATTR_TCP] = sizeof(struct ovs_key_tcp),
+	[OVS_KEY_ATTR_UDP] = sizeof(struct ovs_key_udp),
+	[OVS_KEY_ATTR_ICMP] = sizeof(struct ovs_key_icmp),
+	[OVS_KEY_ATTR_ICMPV6] = sizeof(struct ovs_key_icmpv6),
+	[OVS_KEY_ATTR_ARP] = sizeof(struct ovs_key_arp),
+	[OVS_KEY_ATTR_ND] = sizeof(struct ovs_key_nd),
+};
+
+static int ipv4_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_len,
+				  const struct nlattr *a[], u32 *attrs)
+{
+	const struct ovs_key_icmp *icmp_key;
+	const struct ovs_key_tcp *tcp_key;
+	const struct ovs_key_udp *udp_key;
+
+	switch (swkey->ip.proto) {
+	case IPPROTO_TCP:
+		if (!(*attrs & (1 << OVS_KEY_ATTR_TCP)))
+			return -EINVAL;
+		*attrs &= ~(1 << OVS_KEY_ATTR_TCP);
+
+		*key_len = SW_FLOW_KEY_OFFSET(ipv4.tp);
+		tcp_key = nla_data(a[OVS_KEY_ATTR_TCP]);
+		swkey->ipv4.tp.src = tcp_key->tcp_src;
+		swkey->ipv4.tp.dst = tcp_key->tcp_dst;
+		break;
+
+	case IPPROTO_UDP:
+		if (!(*attrs & (1 << OVS_KEY_ATTR_UDP)))
+			return -EINVAL;
+		*attrs &= ~(1 << OVS_KEY_ATTR_UDP);
+
+		*key_len = SW_FLOW_KEY_OFFSET(ipv4.tp);
+		udp_key = nla_data(a[OVS_KEY_ATTR_UDP]);
+		swkey->ipv4.tp.src = udp_key->udp_src;
+		swkey->ipv4.tp.dst = udp_key->udp_dst;
+		break;
+
+	case IPPROTO_ICMP:
+		if (!(*attrs & (1 << OVS_KEY_ATTR_ICMP)))
+			return -EINVAL;
+		*attrs &= ~(1 << OVS_KEY_ATTR_ICMP);
+
+		*key_len = SW_FLOW_KEY_OFFSET(ipv4.tp);
+		icmp_key = nla_data(a[OVS_KEY_ATTR_ICMP]);
+		swkey->ipv4.tp.src = htons(icmp_key->icmp_type);
+		swkey->ipv4.tp.dst = htons(icmp_key->icmp_code);
+		break;
+	}
+
+	return 0;
+}
+
+static int ipv6_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_len,
+				  const struct nlattr *a[], u32 *attrs)
+{
+	const struct ovs_key_icmpv6 *icmpv6_key;
+	const struct ovs_key_tcp *tcp_key;
+	const struct ovs_key_udp *udp_key;
+
+	switch (swkey->ip.proto) {
+	case IPPROTO_TCP:
+		if (!(*attrs & (1 << OVS_KEY_ATTR_TCP)))
+			return -EINVAL;
+		*attrs &= ~(1 << OVS_KEY_ATTR_TCP);
+
+		*key_len = SW_FLOW_KEY_OFFSET(ipv6.tp);
+		tcp_key = nla_data(a[OVS_KEY_ATTR_TCP]);
+		swkey->ipv6.tp.src = tcp_key->tcp_src;
+		swkey->ipv6.tp.dst = tcp_key->tcp_dst;
+		break;
+
+	case IPPROTO_UDP:
+		if (!(*attrs & (1 << OVS_KEY_ATTR_UDP)))
+			return -EINVAL;
+		*attrs &= ~(1 << OVS_KEY_ATTR_UDP);
+
+		*key_len = SW_FLOW_KEY_OFFSET(ipv6.tp);
+		udp_key = nla_data(a[OVS_KEY_ATTR_UDP]);
+		swkey->ipv6.tp.src = udp_key->udp_src;
+		swkey->ipv6.tp.dst = udp_key->udp_dst;
+		break;
+
+	case IPPROTO_ICMPV6:
+		if (!(*attrs & (1 << OVS_KEY_ATTR_ICMPV6)))
+			return -EINVAL;
+		*attrs &= ~(1 << OVS_KEY_ATTR_ICMPV6);
+
+		*key_len = SW_FLOW_KEY_OFFSET(ipv6.tp);
+		icmpv6_key = nla_data(a[OVS_KEY_ATTR_ICMPV6]);
+		swkey->ipv6.tp.src = htons(icmpv6_key->icmpv6_type);
+		swkey->ipv6.tp.dst = htons(icmpv6_key->icmpv6_code);
+
+		if (swkey->ipv6.tp.src == htons(NDISC_NEIGHBOUR_SOLICITATION) ||
+		    swkey->ipv6.tp.src == htons(NDISC_NEIGHBOUR_ADVERTISEMENT)) {
+			const struct ovs_key_nd *nd_key;
+
+			if (!(*attrs & (1 << OVS_KEY_ATTR_ND)))
+				return -EINVAL;
+			*attrs &= ~(1 << OVS_KEY_ATTR_ND);
+
+			*key_len = SW_FLOW_KEY_OFFSET(ipv6.nd);
+			nd_key = nla_data(a[OVS_KEY_ATTR_ND]);
+			memcpy(&swkey->ipv6.nd.target, nd_key->nd_target,
+			       sizeof(swkey->ipv6.nd.target));
+			memcpy(swkey->ipv6.nd.sll, nd_key->nd_sll, ETH_ALEN);
+			memcpy(swkey->ipv6.nd.tll, nd_key->nd_tll, ETH_ALEN);
+		}
+		break;
+	}
+
+	return 0;
+}
+
+static int parse_flow_nlattrs(const struct nlattr *attr,
+			      const struct nlattr *a[], u32 *attrsp)
+{
+	const struct nlattr *nla;
+	u32 attrs;
+	int rem;
+
+	attrs = 0;
+	nla_for_each_nested(nla, attr, rem) {
+		u16 type = nla_type(nla);
+		int expected_len;
+
+		if (type > OVS_KEY_ATTR_MAX || attrs & (1 << type))
+			return -EINVAL;
+
+		expected_len = ovs_key_lens[type];
+		if (nla_len(nla) != expected_len && expected_len != -1)
+			return -EINVAL;
+
+		attrs |= 1 << type;
+		a[type] = nla;
+	}
+	if (rem)
+		return -EINVAL;
+
+	*attrsp = attrs;
+	return 0;
+}
+
+/**
+ * flow_from_nlattrs - parses Netlink attributes into a flow key.
+ * @swkey: receives the extracted flow key.
+ * @key_lenp: number of bytes used in @swkey.
+ * @attr: Netlink attribute holding nested %OVS_KEY_ATTR_* Netlink attribute
+ * sequence.
+ */
+int flow_from_nlattrs(struct sw_flow_key *swkey, int *key_lenp,
+		      const struct nlattr *attr)
+{
+	const struct nlattr *a[OVS_KEY_ATTR_MAX + 1];
+	const struct ovs_key_ethernet *eth_key;
+	int key_len;
+	u32 attrs;
+	int err;
+
+	memset(swkey, 0, sizeof(struct sw_flow_key));
+	key_len = SW_FLOW_KEY_OFFSET(eth);
+
+	err = parse_flow_nlattrs(attr, a, &attrs);
+	if (err)
+		return err;
+
+	/* Metadata attributes. */
+	if (attrs & (1 << OVS_KEY_ATTR_PRIORITY)) {
+		swkey->phy.priority = nla_get_u32(a[OVS_KEY_ATTR_PRIORITY]);
+		attrs &= ~(1 << OVS_KEY_ATTR_PRIORITY);
+	}
+	if (attrs & (1 << OVS_KEY_ATTR_IN_PORT)) {
+		u32 in_port = nla_get_u32(a[OVS_KEY_ATTR_IN_PORT]);
+		if (in_port >= DP_MAX_PORTS)
+			return -EINVAL;
+		swkey->phy.in_port = in_port;
+		attrs &= ~(1 << OVS_KEY_ATTR_IN_PORT);
+	} else {
+		swkey->phy.in_port = USHRT_MAX;
+	}
+
+	/* Data attributes. */
+	if (!(attrs & (1 << OVS_KEY_ATTR_ETHERNET)))
+		return -EINVAL;
+	attrs &= ~(1 << OVS_KEY_ATTR_ETHERNET);
+
+	eth_key = nla_data(a[OVS_KEY_ATTR_ETHERNET]);
+	memcpy(swkey->eth.src, eth_key->eth_src, ETH_ALEN);
+	memcpy(swkey->eth.dst, eth_key->eth_dst, ETH_ALEN);
+
+	if (attrs & (1u << OVS_KEY_ATTR_ETHERTYPE) &&
+	    nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]) == htons(ETH_P_8021Q)) {
+		const struct nlattr *encap;
+		__be16 tci;
+
+		if (attrs != ((1 << OVS_KEY_ATTR_VLAN) |
+			      (1 << OVS_KEY_ATTR_ETHERTYPE) |
+			      (1 << OVS_KEY_ATTR_ENCAP)))
+			return -EINVAL;
+
+		encap = a[OVS_KEY_ATTR_ENCAP];
+		tci = nla_get_be16(a[OVS_KEY_ATTR_VLAN]);
+		if (tci & htons(VLAN_TAG_PRESENT)) {
+			swkey->eth.tci = tci;
+
+			err = parse_flow_nlattrs(encap, a, &attrs);
+			if (err)
+				return err;
+		} else if (!tci) {
+			/* Corner case for truncated 802.1Q header. */
+			if (nla_len(encap))
+				return -EINVAL;
+
+			swkey->eth.type = htons(ETH_P_8021Q);
+			*key_lenp = key_len;
+			return 0;
+		} else {
+			return -EINVAL;
+		}
+	}
+
+	if (attrs & (1 << OVS_KEY_ATTR_ETHERTYPE)) {
+		swkey->eth.type = nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]);
+		if (ntohs(swkey->eth.type) < 1536)
+			return -EINVAL;
+		attrs &= ~(1 << OVS_KEY_ATTR_ETHERTYPE);
+	} else {
+		swkey->eth.type = htons(ETH_P_802_2);
+	}
+
+	if (swkey->eth.type == htons(ETH_P_IP)) {
+		const struct ovs_key_ipv4 *ipv4_key;
+
+		if (!(attrs & (1 << OVS_KEY_ATTR_IPV4)))
+			return -EINVAL;
+		attrs &= ~(1 << OVS_KEY_ATTR_IPV4);
+
+		key_len = SW_FLOW_KEY_OFFSET(ipv4.addr);
+		ipv4_key = nla_data(a[OVS_KEY_ATTR_IPV4]);
+		if (ipv4_key->ipv4_frag > OVS_FRAG_TYPE_MAX)
+			return -EINVAL;
+		swkey->ip.proto = ipv4_key->ipv4_proto;
+		swkey->ip.tos = ipv4_key->ipv4_tos;
+		swkey->ip.ttl = ipv4_key->ipv4_ttl;
+		swkey->ip.frag = ipv4_key->ipv4_frag;
+		swkey->ipv4.addr.src = ipv4_key->ipv4_src;
+		swkey->ipv4.addr.dst = ipv4_key->ipv4_dst;
+
+		if (swkey->ip.frag != OVS_FRAG_TYPE_LATER) {
+			err = ipv4_flow_from_nlattrs(swkey, &key_len, a, &attrs);
+			if (err)
+				return err;
+		}
+	} else if (swkey->eth.type == htons(ETH_P_IPV6)) {
+		const struct ovs_key_ipv6 *ipv6_key;
+
+		if (!(attrs & (1 << OVS_KEY_ATTR_IPV6)))
+			return -EINVAL;
+		attrs &= ~(1 << OVS_KEY_ATTR_IPV6);
+
+		key_len = SW_FLOW_KEY_OFFSET(ipv6.label);
+		ipv6_key = nla_data(a[OVS_KEY_ATTR_IPV6]);
+		if (ipv6_key->ipv6_frag > OVS_FRAG_TYPE_MAX)
+			return -EINVAL;
+		swkey->ipv6.label = ipv6_key->ipv6_label;
+		swkey->ip.proto = ipv6_key->ipv6_proto;
+		swkey->ip.tos = ipv6_key->ipv6_tclass;
+		swkey->ip.ttl = ipv6_key->ipv6_hlimit;
+		swkey->ip.frag = ipv6_key->ipv6_frag;
+		memcpy(&swkey->ipv6.addr.src, ipv6_key->ipv6_src,
+		       sizeof(swkey->ipv6.addr.src));
+		memcpy(&swkey->ipv6.addr.dst, ipv6_key->ipv6_dst,
+		       sizeof(swkey->ipv6.addr.dst));
+
+		if (swkey->ip.frag != OVS_FRAG_TYPE_LATER) {
+			err = ipv6_flow_from_nlattrs(swkey, &key_len, a, &attrs);
+			if (err)
+				return err;
+		}
+	} else if (swkey->eth.type == htons(ETH_P_ARP)) {
+		const struct ovs_key_arp *arp_key;
+
+		if (!(attrs & (1 << OVS_KEY_ATTR_ARP)))
+			return -EINVAL;
+		attrs &= ~(1 << OVS_KEY_ATTR_ARP);
+
+		key_len = SW_FLOW_KEY_OFFSET(ipv4.arp);
+		arp_key = nla_data(a[OVS_KEY_ATTR_ARP]);
+		swkey->ipv4.addr.src = arp_key->arp_sip;
+		swkey->ipv4.addr.dst = arp_key->arp_tip;
+		if (arp_key->arp_op & htons(0xff00))
+			return -EINVAL;
+		swkey->ip.proto = ntohs(arp_key->arp_op);
+		memcpy(swkey->ipv4.arp.sha, arp_key->arp_sha, ETH_ALEN);
+		memcpy(swkey->ipv4.arp.tha, arp_key->arp_tha, ETH_ALEN);
+	}
+
+	if (attrs)
+		return -EINVAL;
+	*key_lenp = key_len;
+
+	return 0;
+}
+
+/**
+ * flow_metadata_from_nlattrs - parses Netlink attributes into a flow key.
+ * @in_port: receives the extracted input port.
+ * @key: Netlink attribute holding nested %OVS_KEY_ATTR_* Netlink attribute
+ * sequence.
+ *
+ * This parses a series of Netlink attributes that form a flow key, which must
+ * take the same form accepted by flow_from_nlattrs(), but only enough of it to
+ * get the metadata, that is, the parts of the flow key that cannot be
+ * extracted from the packet itself.
+ */
+int flow_metadata_from_nlattrs(u32 *priority, u16 *in_port,
+			       const struct nlattr *attr)
+{
+	const struct nlattr *nla;
+	int rem;
+
+	*in_port = USHRT_MAX;
+	*priority = 0;
+
+	nla_for_each_nested(nla, attr, rem) {
+		int type = nla_type(nla);
+
+		if (type <= OVS_KEY_ATTR_MAX && ovs_key_lens[type] > 0) {
+			if (nla_len(nla) != ovs_key_lens[type])
+				return -EINVAL;
+
+			switch (type) {
+			case OVS_KEY_ATTR_PRIORITY:
+				*priority = nla_get_u32(nla);
+				break;
+
+			case OVS_KEY_ATTR_IN_PORT:
+				if (nla_get_u32(nla) >= DP_MAX_PORTS)
+					return -EINVAL;
+				*in_port = nla_get_u32(nla);
+				break;
+			}
+		}
+	}
+	if (rem)
+		return -EINVAL;
+	return 0;
+}
+
+int flow_to_nlattrs(const struct sw_flow_key *swkey, struct sk_buff *skb)
+{
+	struct ovs_key_ethernet *eth_key;
+	struct nlattr *nla, *encap;
+
+	if (swkey->phy.priority)
+		NLA_PUT_U32(skb, OVS_KEY_ATTR_PRIORITY, swkey->phy.priority);
+
+	if (swkey->phy.in_port != USHRT_MAX)
+		NLA_PUT_U32(skb, OVS_KEY_ATTR_IN_PORT, swkey->phy.in_port);
+
+	nla = nla_reserve(skb, OVS_KEY_ATTR_ETHERNET, sizeof(*eth_key));
+	if (!nla)
+		goto nla_put_failure;
+	eth_key = nla_data(nla);
+	memcpy(eth_key->eth_src, swkey->eth.src, ETH_ALEN);
+	memcpy(eth_key->eth_dst, swkey->eth.dst, ETH_ALEN);
+
+	if (swkey->eth.tci || swkey->eth.type == htons(ETH_P_8021Q)) {
+		NLA_PUT_BE16(skb, OVS_KEY_ATTR_ETHERTYPE, htons(ETH_P_8021Q));
+		NLA_PUT_BE16(skb, OVS_KEY_ATTR_VLAN, swkey->eth.tci);
+		encap = nla_nest_start(skb, OVS_KEY_ATTR_ENCAP);
+		if (!swkey->eth.tci)
+			goto unencap;
+	} else {
+		encap = NULL;
+	}
+
+	if (swkey->eth.type == htons(ETH_P_802_2))
+		goto unencap;
+
+	NLA_PUT_BE16(skb, OVS_KEY_ATTR_ETHERTYPE, swkey->eth.type);
+
+	if (swkey->eth.type == htons(ETH_P_IP)) {
+		struct ovs_key_ipv4 *ipv4_key;
+
+		nla = nla_reserve(skb, OVS_KEY_ATTR_IPV4, sizeof(*ipv4_key));
+		if (!nla)
+			goto nla_put_failure;
+		ipv4_key = nla_data(nla);
+		ipv4_key->ipv4_src = swkey->ipv4.addr.src;
+		ipv4_key->ipv4_dst = swkey->ipv4.addr.dst;
+		ipv4_key->ipv4_proto = swkey->ip.proto;
+		ipv4_key->ipv4_tos = swkey->ip.tos;
+		ipv4_key->ipv4_ttl = swkey->ip.ttl;
+		ipv4_key->ipv4_frag = swkey->ip.frag;
+	} else if (swkey->eth.type == htons(ETH_P_IPV6)) {
+		struct ovs_key_ipv6 *ipv6_key;
+
+		nla = nla_reserve(skb, OVS_KEY_ATTR_IPV6, sizeof(*ipv6_key));
+		if (!nla)
+			goto nla_put_failure;
+		ipv6_key = nla_data(nla);
+		memcpy(ipv6_key->ipv6_src, &swkey->ipv6.addr.src,
+				sizeof(ipv6_key->ipv6_src));
+		memcpy(ipv6_key->ipv6_dst, &swkey->ipv6.addr.dst,
+				sizeof(ipv6_key->ipv6_dst));
+		ipv6_key->ipv6_label = swkey->ipv6.label;
+		ipv6_key->ipv6_proto = swkey->ip.proto;
+		ipv6_key->ipv6_tclass = swkey->ip.tos;
+		ipv6_key->ipv6_hlimit = swkey->ip.ttl;
+		ipv6_key->ipv6_frag = swkey->ip.frag;
+	} else if (swkey->eth.type == htons(ETH_P_ARP)) {
+		struct ovs_key_arp *arp_key;
+
+		nla = nla_reserve(skb, OVS_KEY_ATTR_ARP, sizeof(*arp_key));
+		if (!nla)
+			goto nla_put_failure;
+		arp_key = nla_data(nla);
+		memset(arp_key, 0, sizeof(struct ovs_key_arp));
+		arp_key->arp_sip = swkey->ipv4.addr.src;
+		arp_key->arp_tip = swkey->ipv4.addr.dst;
+		arp_key->arp_op = htons(swkey->ip.proto);
+		memcpy(arp_key->arp_sha, swkey->ipv4.arp.sha, ETH_ALEN);
+		memcpy(arp_key->arp_tha, swkey->ipv4.arp.tha, ETH_ALEN);
+	}
+
+	if ((swkey->eth.type == htons(ETH_P_IP) ||
+	     swkey->eth.type == htons(ETH_P_IPV6)) &&
+	     swkey->ip.frag != OVS_FRAG_TYPE_LATER) {
+
+		if (swkey->ip.proto == IPPROTO_TCP) {
+			struct ovs_key_tcp *tcp_key;
+
+			nla = nla_reserve(skb, OVS_KEY_ATTR_TCP, sizeof(*tcp_key));
+			if (!nla)
+				goto nla_put_failure;
+			tcp_key = nla_data(nla);
+			if (swkey->eth.type == htons(ETH_P_IP)) {
+				tcp_key->tcp_src = swkey->ipv4.tp.src;
+				tcp_key->tcp_dst = swkey->ipv4.tp.dst;
+			} else if (swkey->eth.type == htons(ETH_P_IPV6)) {
+				tcp_key->tcp_src = swkey->ipv6.tp.src;
+				tcp_key->tcp_dst = swkey->ipv6.tp.dst;
+			}
+		} else if (swkey->ip.proto == IPPROTO_UDP) {
+			struct ovs_key_udp *udp_key;
+
+			nla = nla_reserve(skb, OVS_KEY_ATTR_UDP, sizeof(*udp_key));
+			if (!nla)
+				goto nla_put_failure;
+			udp_key = nla_data(nla);
+			if (swkey->eth.type == htons(ETH_P_IP)) {
+				udp_key->udp_src = swkey->ipv4.tp.src;
+				udp_key->udp_dst = swkey->ipv4.tp.dst;
+			} else if (swkey->eth.type == htons(ETH_P_IPV6)) {
+				udp_key->udp_src = swkey->ipv6.tp.src;
+				udp_key->udp_dst = swkey->ipv6.tp.dst;
+			}
+		} else if (swkey->eth.type == htons(ETH_P_IP) &&
+			   swkey->ip.proto == IPPROTO_ICMP) {
+			struct ovs_key_icmp *icmp_key;
+
+			nla = nla_reserve(skb, OVS_KEY_ATTR_ICMP, sizeof(*icmp_key));
+			if (!nla)
+				goto nla_put_failure;
+			icmp_key = nla_data(nla);
+			icmp_key->icmp_type = ntohs(swkey->ipv4.tp.src);
+			icmp_key->icmp_code = ntohs(swkey->ipv4.tp.dst);
+		} else if (swkey->eth.type == htons(ETH_P_IPV6) &&
+			   swkey->ip.proto == IPPROTO_ICMPV6) {
+			struct ovs_key_icmpv6 *icmpv6_key;
+
+			nla = nla_reserve(skb, OVS_KEY_ATTR_ICMPV6,
+						sizeof(*icmpv6_key));
+			if (!nla)
+				goto nla_put_failure;
+			icmpv6_key = nla_data(nla);
+			icmpv6_key->icmpv6_type = ntohs(swkey->ipv6.tp.src);
+			icmpv6_key->icmpv6_code = ntohs(swkey->ipv6.tp.dst);
+
+			if (icmpv6_key->icmpv6_type == NDISC_NEIGHBOUR_SOLICITATION ||
+			    icmpv6_key->icmpv6_type == NDISC_NEIGHBOUR_ADVERTISEMENT) {
+				struct ovs_key_nd *nd_key;
+
+				nla = nla_reserve(skb, OVS_KEY_ATTR_ND, sizeof(*nd_key));
+				if (!nla)
+					goto nla_put_failure;
+				nd_key = nla_data(nla);
+				memcpy(nd_key->nd_target, &swkey->ipv6.nd.target,
+							sizeof(nd_key->nd_target));
+				memcpy(nd_key->nd_sll, swkey->ipv6.nd.sll, ETH_ALEN);
+				memcpy(nd_key->nd_tll, swkey->ipv6.nd.tll, ETH_ALEN);
+			}
+		}
+	}
+
+unencap:
+	if (encap)
+		nla_nest_end(skb, encap);
+
+	return 0;
+
+nla_put_failure:
+	return -EMSGSIZE;
+}
+
+/* Initializes the flow module.
+ * Returns zero if successful or a negative error code. */
+int flow_init(void)
+{
+	flow_cache = kmem_cache_create("sw_flow", sizeof(struct sw_flow), 0,
+					0, NULL);
+	if (flow_cache == NULL)
+		return -ENOMEM;
+
+	get_random_bytes(&hash_seed, sizeof(hash_seed));
+
+	return 0;
+}
+
+/* Uninitializes the flow module. */
+void flow_exit(void)
+{
+	kmem_cache_destroy(flow_cache);
+}
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
new file mode 100644
index 0000000..b98596f
--- /dev/null
+++ b/net/openvswitch/flow.h
@@ -0,0 +1,195 @@
+/*
+ * Copyright (c) 2007-2011 Nicira Networks.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ */
+
+#ifndef FLOW_H
+#define FLOW_H 1
+
+#include <linux/kernel.h>
+#include <linux/netlink.h>
+#include <linux/openvswitch.h>
+#include <linux/spinlock.h>
+#include <linux/types.h>
+#include <linux/rcupdate.h>
+#include <linux/if_ether.h>
+#include <linux/in6.h>
+#include <linux/jiffies.h>
+#include <linux/time.h>
+#include <linux/flex_array.h>
+#include <net/inet_ecn.h>
+
+struct sk_buff;
+
+struct sw_flow_actions {
+	struct rcu_head rcu;
+	u32 actions_len;
+	struct nlattr actions[];
+};
+
+struct sw_flow_key {
+	struct {
+		u32	priority;	/* Packet QoS priority. */
+		u16	in_port;	/* Input switch port (or USHRT_MAX). */
+	} phy;
+	struct {
+		u8     src[ETH_ALEN];	/* Ethernet source address. */
+		u8     dst[ETH_ALEN];	/* Ethernet destination address. */
+		__be16 tci;		/* 0 if no VLAN, VLAN_TAG_PRESENT set otherwise. */
+		__be16 type;		/* Ethernet frame type. */
+	} eth;
+	struct {
+		u8     proto;		/* IP protocol or lower 8 bits of ARP opcode. */
+		u8     tos;		/* IP ToS. */
+		u8     ttl;		/* IP TTL/hop limit. */
+		u8     frag;		/* One of OVS_FRAG_TYPE_*. */
+	} ip;
+	union {
+		struct {
+			struct {
+				__be32 src;	/* IP source address. */
+				__be32 dst;	/* IP destination address. */
+			} addr;
+			union {
+				struct {
+					__be16 src;		/* TCP/UDP source port. */
+					__be16 dst;		/* TCP/UDP destination port. */
+				} tp;
+				struct {
+					u8 sha[ETH_ALEN];	/* ARP source hardware address. */
+					u8 tha[ETH_ALEN];	/* ARP target hardware address. */
+				} arp;
+			};
+		} ipv4;
+		struct {
+			struct {
+				struct in6_addr src;	/* IPv6 source address. */
+				struct in6_addr dst;	/* IPv6 destination address. */
+			} addr;
+			__be32 label;			/* IPv6 flow label. */
+			struct {
+				__be16 src;		/* TCP/UDP source port. */
+				__be16 dst;		/* TCP/UDP destination port. */
+			} tp;
+			struct {
+				struct in6_addr target;	/* ND target address. */
+				u8 sll[ETH_ALEN];	/* ND source link layer address. */
+				u8 tll[ETH_ALEN];	/* ND target link layer address. */
+			} nd;
+		} ipv6;
+	};
+};
+
+struct sw_flow {
+	struct rcu_head rcu;
+	struct hlist_node  hash_node;
+	u32 hash;
+
+	struct sw_flow_key key;
+	struct sw_flow_actions __rcu *sf_acts;
+
+	spinlock_t lock;	/* Lock for values below. */
+	unsigned long used;	/* Last used time (in jiffies). */
+	u64 packet_count;	/* Number of packets matched. */
+	u64 byte_count;		/* Number of bytes matched. */
+	u8 tcp_flags;		/* Union of seen TCP flags. */
+};
+
+struct arp_eth_header {
+	__be16      ar_hrd;	/* format of hardware address   */
+	__be16      ar_pro;	/* format of protocol address   */
+	unsigned char   ar_hln;	/* length of hardware address   */
+	unsigned char   ar_pln;	/* length of protocol address   */
+	__be16      ar_op;	/* ARP opcode (command)     */
+
+	/* Ethernet+IPv4 specific members. */
+	unsigned char       ar_sha[ETH_ALEN];	/* sender hardware address  */
+	unsigned char       ar_sip[4];		/* sender IP address        */
+	unsigned char       ar_tha[ETH_ALEN];	/* target hardware address  */
+	unsigned char       ar_tip[4];		/* target IP address        */
+} __packed;
+
+int flow_init(void);
+void flow_exit(void);
+
+struct sw_flow *flow_alloc(void);
+void flow_deferred_free(struct sw_flow *);
+void flow_free(struct sw_flow *flow);
+
+struct sw_flow_actions *flow_actions_alloc(const struct nlattr *);
+void flow_deferred_free_acts(struct sw_flow_actions *);
+
+int flow_extract(struct sk_buff *, u16 in_port, struct sw_flow_key *,
+		 int *key_lenp);
+void flow_used(struct sw_flow *, struct sk_buff *);
+u64 flow_used_time(unsigned long flow_jiffies);
+
+/* Upper bound on the length of a nlattr-formatted flow key.  The longest
+ * nlattr-formatted flow key would be:
+ *
+ *                         struct  pad  nl hdr  total
+ *                         ------  ---  ------  -----
+ *  OVS_KEY_ATTR_PRIORITY      4    --     4      8
+ *  OVS_KEY_ATTR_IN_PORT       4    --     4      8
+ *  OVS_KEY_ATTR_ETHERNET     12    --     4     16
+ *  OVS_KEY_ATTR_8021Q         4    --     4      8
+ *  OVS_KEY_ATTR_ETHERTYPE     2     2     4      8
+ *  OVS_KEY_ATTR_IPV6         40    --     4     44
+ *  OVS_KEY_ATTR_ICMPV6        2     2     4      8
+ *  OVS_KEY_ATTR_ND           28    --     4     32
+ *  -------------------------------------------------
+ *  total                                       132
+ */
+#define FLOW_BUFSIZE 132
+
+int flow_to_nlattrs(const struct sw_flow_key *, struct sk_buff *);
+int flow_from_nlattrs(struct sw_flow_key *swkey, int *key_lenp,
+		      const struct nlattr *);
+int flow_metadata_from_nlattrs(u32 *priority, u16 *in_port,
+			       const struct nlattr *);
+
+#define TBL_MIN_BUCKETS		1024
+
+struct flow_table {
+	struct flex_array *buckets;
+	unsigned int count, n_buckets;
+	struct rcu_head rcu;
+};
+
+static inline int flow_tbl_count(struct flow_table *table)
+{
+	return table->count;
+}
+
+static inline int flow_tbl_need_to_expand(struct flow_table *table)
+{
+	return (table->count > table->n_buckets);
+}
+
+struct sw_flow *flow_tbl_lookup(struct flow_table *table,
+				struct sw_flow_key *key,    int len);
+void flow_tbl_destroy(struct flow_table *table);
+void flow_tbl_deferred_destroy(struct flow_table *table);
+struct flow_table *flow_tbl_alloc(int new_size);
+struct flow_table *flow_tbl_expand(struct flow_table *table);
+void flow_tbl_insert(struct flow_table *table, struct sw_flow *flow);
+void flow_tbl_remove(struct flow_table *table, struct sw_flow *flow);
+u32 flow_hash(const struct sw_flow_key *key, int key_len);
+
+struct sw_flow *flow_tbl_next(struct flow_table *table, u32 *bucket, u32 *idx);
+extern const int ovs_key_lens[OVS_KEY_ATTR_MAX + 1];
+
+#endif /* flow.h */
diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
new file mode 100644
index 0000000..89f7be4
--- /dev/null
+++ b/net/openvswitch/vport-internal_dev.c
@@ -0,0 +1,241 @@
+/*
+ * Copyright (c) 2007-2011 Nicira Networks.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ */
+
+#include <linux/hardirq.h>
+#include <linux/if_vlan.h>
+#include <linux/kernel.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/ethtool.h>
+#include <linux/skbuff.h>
+#include <linux/version.h>
+
+#include "datapath.h"
+#include "vport-internal_dev.h"
+#include "vport-netdev.h"
+
+struct internal_dev {
+	struct vport *vport;
+};
+
+static struct internal_dev *internal_dev_priv(struct net_device *netdev)
+{
+	return netdev_priv(netdev);
+}
+
+/* This function is only called by the kernel network layer.*/
+static struct rtnl_link_stats64 *internal_dev_get_stats(struct net_device *netdev,
+							struct rtnl_link_stats64 *stats)
+{
+	struct vport *vport = internal_dev_get_vport(netdev);
+	struct ovs_vport_stats vport_stats;
+
+	vport_get_stats(vport, &vport_stats);
+
+	/* The tx and rx stats need to be swapped because the
+	 * switch and host OS have opposite perspectives. */
+	stats->rx_packets	= vport_stats.tx_packets;
+	stats->tx_packets	= vport_stats.rx_packets;
+	stats->rx_bytes		= vport_stats.tx_bytes;
+	stats->tx_bytes		= vport_stats.rx_bytes;
+	stats->rx_errors	= vport_stats.tx_errors;
+	stats->tx_errors	= vport_stats.rx_errors;
+	stats->rx_dropped	= vport_stats.tx_dropped;
+	stats->tx_dropped	= vport_stats.rx_dropped;
+
+	return stats;
+}
+
+static int internal_dev_mac_addr(struct net_device *dev, void *p)
+{
+	struct sockaddr *addr = p;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
+	return 0;
+}
+
+/* Called with rcu_read_lock_bh. */
+static int internal_dev_xmit(struct sk_buff *skb, struct net_device *netdev)
+{
+	rcu_read_lock();
+	vport_receive(internal_dev_priv(netdev)->vport, skb);
+	rcu_read_unlock();
+	return 0;
+}
+
+static int internal_dev_open(struct net_device *netdev)
+{
+	netif_start_queue(netdev);
+	return 0;
+}
+
+static int internal_dev_stop(struct net_device *netdev)
+{
+	netif_stop_queue(netdev);
+	return 0;
+}
+
+static void internal_dev_getinfo(struct net_device *netdev,
+				 struct ethtool_drvinfo *info)
+{
+	strcpy(info->driver, "openvswitch");
+}
+
+static const struct ethtool_ops internal_dev_ethtool_ops = {
+	.get_drvinfo	= internal_dev_getinfo,
+	.get_link	= ethtool_op_get_link,
+};
+
+static int internal_dev_change_mtu(struct net_device *netdev, int new_mtu)
+{
+	if (new_mtu < 68)
+		return -EINVAL;
+
+	netdev->mtu = new_mtu;
+	return 0;
+}
+
+static void internal_dev_destructor(struct net_device *dev)
+{
+	struct vport *vport = internal_dev_get_vport(dev);
+
+	vport_free(vport);
+	free_netdev(dev);
+}
+
+static const struct net_device_ops internal_dev_netdev_ops = {
+	.ndo_open = internal_dev_open,
+	.ndo_stop = internal_dev_stop,
+	.ndo_start_xmit = internal_dev_xmit,
+	.ndo_set_mac_address = internal_dev_mac_addr,
+	.ndo_change_mtu = internal_dev_change_mtu,
+	.ndo_get_stats64 = internal_dev_get_stats,
+};
+
+static void do_setup(struct net_device *netdev)
+{
+	ether_setup(netdev);
+
+	netdev->netdev_ops = &internal_dev_netdev_ops;
+
+	netdev->priv_flags &= ~IFF_TX_SKB_SHARING;
+	netdev->destructor = internal_dev_destructor;
+	SET_ETHTOOL_OPS(netdev, &internal_dev_ethtool_ops);
+	netdev->tx_queue_len = 0;
+
+	netdev->features = NETIF_F_LLTX | NETIF_F_SG | NETIF_F_FRAGLIST |
+				NETIF_F_HIGHDMA | NETIF_F_HW_CSUM | NETIF_F_TSO;
+
+	netdev->vlan_features = netdev->features;
+	netdev->features |= NETIF_F_HW_VLAN_TX;
+	netdev->hw_features = netdev->features & ~NETIF_F_LLTX;
+	random_ether_addr(netdev->dev_addr);
+}
+
+static struct vport *internal_dev_create(const struct vport_parms *parms)
+{
+	struct vport *vport;
+	struct netdev_vport *netdev_vport;
+	struct internal_dev *internal_dev;
+	int err;
+
+	vport = vport_alloc(sizeof(struct netdev_vport),
+			    &internal_vport_ops, parms);
+	if (IS_ERR(vport)) {
+		err = PTR_ERR(vport);
+		goto error;
+	}
+
+	netdev_vport = netdev_vport_priv(vport);
+
+	netdev_vport->dev = alloc_netdev(sizeof(struct internal_dev),
+					 parms->name, do_setup);
+	if (!netdev_vport->dev) {
+		err = -ENOMEM;
+		goto error_free_vport;
+	}
+
+	internal_dev = internal_dev_priv(netdev_vport->dev);
+	internal_dev->vport = vport;
+
+	err = register_netdevice(netdev_vport->dev);
+	if (err)
+		goto error_free_netdev;
+
+	dev_set_promiscuity(netdev_vport->dev, 1);
+	netif_start_queue(netdev_vport->dev);
+
+	return vport;
+
+error_free_netdev:
+	free_netdev(netdev_vport->dev);
+error_free_vport:
+	vport_free(vport);
+error:
+	return ERR_PTR(err);
+}
+
+static void internal_dev_destroy(struct vport *vport)
+{
+	struct netdev_vport *netdev_vport = netdev_vport_priv(vport);
+
+	netif_stop_queue(netdev_vport->dev);
+	dev_set_promiscuity(netdev_vport->dev, -1);
+
+	/* unregister_netdevice() waits for an RCU grace period. */
+	unregister_netdevice(netdev_vport->dev);
+}
+
+static int internal_dev_recv(struct vport *vport, struct sk_buff *skb)
+{
+	struct net_device *netdev = netdev_vport_priv(vport)->dev;
+	int len;
+
+	len = skb->len;
+	skb->dev = netdev;
+	skb->pkt_type = PACKET_HOST;
+	skb->protocol = eth_type_trans(skb, netdev);
+
+	netif_rx(skb);
+
+	return len;
+}
+
+const struct vport_ops internal_vport_ops = {
+	.type		= OVS_VPORT_TYPE_INTERNAL,
+	.create		= internal_dev_create,
+	.destroy	= internal_dev_destroy,
+	.get_name	= netdev_get_name,
+	.get_ifindex	= netdev_get_ifindex,
+	.send		= internal_dev_recv,
+};
+
+int is_internal_dev(const struct net_device *netdev)
+{
+	return netdev->netdev_ops == &internal_dev_netdev_ops;
+}
+
+struct vport *internal_dev_get_vport(struct net_device *netdev)
+{
+	if (!is_internal_dev(netdev))
+		return NULL;
+
+	return internal_dev_priv(netdev)->vport;
+}
diff --git a/net/openvswitch/vport-internal_dev.h b/net/openvswitch/vport-internal_dev.h
new file mode 100644
index 0000000..91002cb
--- /dev/null
+++ b/net/openvswitch/vport-internal_dev.h
@@ -0,0 +1,28 @@
+/*
+ * Copyright (c) 2007-2011 Nicira Networks.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ */
+
+#ifndef VPORT_INTERNAL_DEV_H
+#define VPORT_INTERNAL_DEV_H 1
+
+#include "datapath.h"
+#include "vport.h"
+
+int is_internal_dev(const struct net_device *);
+struct vport *internal_dev_get_vport(struct net_device *);
+
+#endif /* vport-internal_dev.h */
diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
new file mode 100644
index 0000000..2aa4814
--- /dev/null
+++ b/net/openvswitch/vport-netdev.c
@@ -0,0 +1,200 @@
+/*
+ * Copyright (c) 2007-2011 Nicira Networks.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/if_arp.h>
+#include <linux/if_bridge.h>
+#include <linux/if_vlan.h>
+#include <linux/kernel.h>
+#include <linux/llc.h>
+#include <linux/rtnetlink.h>
+#include <linux/skbuff.h>
+
+#include <net/llc.h>
+
+#include "datapath.h"
+#include "vport-internal_dev.h"
+#include "vport-netdev.h"
+
+/* Must be called with rcu_read_lock. */
+static void netdev_port_receive(struct vport *vport, struct sk_buff *skb)
+{
+	if (unlikely(!vport)) {
+		kfree_skb(skb);
+		return;
+	}
+
+	/* Make our own copy of the packet.  Otherwise we will mangle the
+	 * packet for anyone who came before us (e.g. tcpdump via AF_PACKET).
+	 * (No one comes after us, since we tell handle_bridge() that we took
+	 * the packet.) */
+	skb = skb_share_check(skb, GFP_ATOMIC);
+	if (unlikely(!skb))
+		return;
+
+	skb_push(skb, ETH_HLEN);
+	vport_receive(vport, skb);
+}
+
+/* Called with rcu_read_lock and bottom-halves disabled. */
+static rx_handler_result_t netdev_frame_hook(struct sk_buff **pskb)
+{
+	struct sk_buff *skb = *pskb;
+	struct vport *vport;
+
+	if (unlikely(skb->pkt_type == PACKET_LOOPBACK))
+		return RX_HANDLER_PASS;
+
+	vport = netdev_get_vport(skb->dev);
+
+	netdev_port_receive(vport, skb);
+
+	return RX_HANDLER_CONSUMED;
+}
+
+static struct vport *netdev_create(const struct vport_parms *parms)
+{
+	struct vport *vport;
+	struct netdev_vport *netdev_vport;
+	int err;
+
+	vport = vport_alloc(sizeof(struct netdev_vport),
+			    &netdev_vport_ops, parms);
+	if (IS_ERR(vport)) {
+		err = PTR_ERR(vport);
+		goto error;
+	}
+
+	netdev_vport = netdev_vport_priv(vport);
+
+	netdev_vport->dev = dev_get_by_name(&init_net, parms->name);
+	if (!netdev_vport->dev) {
+		err = -ENODEV;
+		goto error_free_vport;
+	}
+
+	if (netdev_vport->dev->flags & IFF_LOOPBACK ||
+	    netdev_vport->dev->type != ARPHRD_ETHER ||
+	    is_internal_dev(netdev_vport->dev)) {
+		err = -EINVAL;
+		goto error_put;
+	}
+
+	err = netdev_rx_handler_register(netdev_vport->dev, netdev_frame_hook,
+					 vport);
+	if (err)
+		goto error_put;
+
+	dev_set_promiscuity(netdev_vport->dev, 1);
+	netdev_vport->dev->priv_flags |= IFF_OVS_DATAPATH;
+
+	return vport;
+
+error_put:
+	dev_put(netdev_vport->dev);
+error_free_vport:
+	vport_free(vport);
+error:
+	return ERR_PTR(err);
+}
+
+static void netdev_destroy(struct vport *vport)
+{
+	struct netdev_vport *netdev_vport = netdev_vport_priv(vport);
+
+	netdev_vport->dev->priv_flags &= ~IFF_OVS_DATAPATH;
+	netdev_rx_handler_unregister(netdev_vport->dev);
+	dev_set_promiscuity(netdev_vport->dev, -1);
+
+	synchronize_rcu();
+
+	dev_put(netdev_vport->dev);
+	vport_free(vport);
+}
+
+const char *netdev_get_name(const struct vport *vport)
+{
+	const struct netdev_vport *netdev_vport = netdev_vport_priv(vport);
+	return netdev_vport->dev->name;
+}
+
+int netdev_get_ifindex(const struct vport *vport)
+{
+	const struct netdev_vport *netdev_vport = netdev_vport_priv(vport);
+	return netdev_vport->dev->ifindex;
+}
+
+
+static unsigned packet_length(const struct sk_buff *skb)
+{
+	unsigned length = skb->len - ETH_HLEN;
+
+	if (skb->protocol == htons(ETH_P_8021Q))
+		length -= VLAN_HLEN;
+
+	return length;
+}
+
+static int netdev_send(struct vport *vport, struct sk_buff *skb)
+{
+	struct netdev_vport *netdev_vport = netdev_vport_priv(vport);
+	int mtu = netdev_vport->dev->mtu;
+	int len;
+
+	if (unlikely(packet_length(skb) > mtu && !skb_is_gso(skb))) {
+		if (net_ratelimit())
+			pr_warn("%s: dropped over-mtu packet: %d > %d\n",
+				dp_name(vport->dp), packet_length(skb), mtu);
+		goto error;
+	}
+
+	if (unlikely(skb_warn_if_lro(skb)))
+		goto error;
+
+	skb->dev = netdev_vport->dev;
+	len = skb->len;
+	dev_queue_xmit(skb);
+
+	return len;
+
+error:
+	kfree_skb(skb);
+	vport_record_error(vport, VPORT_E_TX_DROPPED);
+	return 0;
+}
+
+/* Returns null if this device is not attached to a datapath. */
+struct vport *netdev_get_vport(struct net_device *dev)
+{
+	if (likely(dev->priv_flags & IFF_OVS_DATAPATH))
+		return (struct vport *)
+			rcu_dereference_rtnl(dev->rx_handler_data);
+	else
+		return NULL;
+}
+
+const struct vport_ops netdev_vport_ops = {
+	.type		= OVS_VPORT_TYPE_NETDEV,
+	.create		= netdev_create,
+	.destroy	= netdev_destroy,
+	.get_name	= netdev_get_name,
+	.get_ifindex	= netdev_get_ifindex,
+	.send		= netdev_send,
+};
+
diff --git a/net/openvswitch/vport-netdev.h b/net/openvswitch/vport-netdev.h
new file mode 100644
index 0000000..6cc8719
--- /dev/null
+++ b/net/openvswitch/vport-netdev.h
@@ -0,0 +1,42 @@
+/*
+ * Copyright (c) 2007-2011 Nicira Networks.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ */
+
+#ifndef VPORT_NETDEV_H
+#define VPORT_NETDEV_H 1
+
+#include <linux/netdevice.h>
+
+#include "vport.h"
+
+struct vport *netdev_get_vport(struct net_device *dev);
+
+struct netdev_vport {
+	struct net_device *dev;
+};
+
+static inline struct netdev_vport *
+netdev_vport_priv(const struct vport *vport)
+{
+	return vport_priv(vport);
+}
+
+const char *netdev_get_name(const struct vport *);
+const char *netdev_get_config(const struct vport *);
+int netdev_get_ifindex(const struct vport *);
+
+#endif /* vport_netdev.h */
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
new file mode 100644
index 0000000..0332312
--- /dev/null
+++ b/net/openvswitch/vport.c
@@ -0,0 +1,396 @@
+/*
+ * Copyright (c) 2007-2011 Nicira Networks.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ */
+
+#include <linux/dcache.h>
+#include <linux/etherdevice.h>
+#include <linux/if.h>
+#include <linux/if_vlan.h>
+#include <linux/kernel.h>
+#include <linux/list.h>
+#include <linux/mutex.h>
+#include <linux/percpu.h>
+#include <linux/rcupdate.h>
+#include <linux/rtnetlink.h>
+#include <linux/compat.h>
+#include <linux/version.h>
+
+#include "vport.h"
+#include "vport-internal_dev.h"
+
+/* List of statically compiled vport implementations.  Don't forget to also
+ * add yours to the list at the bottom of vport.h. */
+static const struct vport_ops *vport_ops_list[] = {
+	&netdev_vport_ops,
+	&internal_vport_ops,
+};
+
+/* Protected by RCU read lock for reading, RTNL lock for writing. */
+static struct hlist_head *dev_table;
+#define VPORT_HASH_BUCKETS 1024
+
+/**
+ *	vport_init - initialize vport subsystem
+ *
+ * Called at module load time to initialize the vport subsystem.
+ */
+int vport_init(void)
+{
+	dev_table = kzalloc(VPORT_HASH_BUCKETS * sizeof(struct hlist_head),
+			    GFP_KERNEL);
+	if (!dev_table)
+		return -ENOMEM;
+
+	return 0;
+}
+
+/**
+ *	vport_exit - shutdown vport subsystem
+ *
+ * Called at module exit time to shutdown the vport subsystem.
+ */
+void vport_exit(void)
+{
+	kfree(dev_table);
+}
+
+static struct hlist_head *hash_bucket(const char *name)
+{
+	unsigned int hash = full_name_hash(name, strlen(name));
+	return &dev_table[hash & (VPORT_HASH_BUCKETS - 1)];
+}
+
+/**
+ *	vport_locate - find a port that has already been created
+ *
+ * @name: name of port to find
+ *
+ * Must be called with RTNL or RCU read lock.
+ */
+struct vport *vport_locate(const char *name)
+{
+	struct hlist_head *bucket = hash_bucket(name);
+	struct vport *vport;
+	struct hlist_node *node;
+
+	hlist_for_each_entry_rcu(vport, node, bucket, hash_node)
+		if (!strcmp(name, vport->ops->get_name(vport)))
+			return vport;
+
+	return NULL;
+}
+
+/**
+ *	vport_alloc - allocate and initialize new vport
+ *
+ * @priv_size: Size of private data area to allocate.
+ * @ops: vport device ops
+ *
+ * Allocate and initialize a new vport defined by @ops.  The vport will contain
+ * a private data area of size @priv_size that can be accessed using
+ * vport_priv().  vports that are no longer needed should be released with
+ * vport_free().
+ */
+struct vport *vport_alloc(int priv_size, const struct vport_ops *ops,
+			  const struct vport_parms *parms)
+{
+	struct vport *vport;
+	size_t alloc_size;
+
+	alloc_size = sizeof(struct vport);
+	if (priv_size) {
+		alloc_size = ALIGN(alloc_size, VPORT_ALIGN);
+		alloc_size += priv_size;
+	}
+
+	vport = kzalloc(alloc_size, GFP_KERNEL);
+	if (!vport)
+		return ERR_PTR(-ENOMEM);
+
+	vport->dp = parms->dp;
+	vport->port_no = parms->port_no;
+	vport->upcall_pid = parms->upcall_pid;
+	vport->ops = ops;
+
+	vport->percpu_stats = alloc_percpu(struct vport_percpu_stats);
+	if (!vport->percpu_stats)
+		return ERR_PTR(-ENOMEM);
+
+	spin_lock_init(&vport->stats_lock);
+
+	return vport;
+}
+
+/**
+ *	vport_free - uninitialize and free vport
+ *
+ * @vport: vport to free
+ *
+ * Frees a vport allocated with vport_alloc() when it is no longer needed.
+ *
+ * The caller must ensure that an RCU grace period has passed since the last
+ * time @vport was in a datapath.
+ */
+void vport_free(struct vport *vport)
+{
+	free_percpu(vport->percpu_stats);
+	kfree(vport);
+}
+
+/**
+ *	vport_add - add vport device (for kernel callers)
+ *
+ * @parms: Information about new vport.
+ *
+ * Creates a new vport with the specified configuration (which is dependent on
+ * device type).  RTNL lock must be held.
+ */
+struct vport *vport_add(const struct vport_parms *parms)
+{
+	struct vport *vport;
+	int err = 0;
+	int i;
+
+	ASSERT_RTNL();
+
+	for (i = 0; i < ARRAY_SIZE(vport_ops_list); i++) {
+		if (vport_ops_list[i]->type == parms->type) {
+			vport = vport_ops_list[i]->create(parms);
+			if (IS_ERR(vport)) {
+				err = PTR_ERR(vport);
+				goto out;
+			}
+
+			hlist_add_head_rcu(&vport->hash_node,
+					   hash_bucket(vport->ops->get_name(vport)));
+			return vport;
+		}
+	}
+
+	err = -EAFNOSUPPORT;
+
+out:
+	return ERR_PTR(err);
+}
+
+/**
+ *	vport_set_options - modify existing vport device (for kernel callers)
+ *
+ * @vport: vport to modify.
+ * @port: New configuration.
+ *
+ * Modifies an existing device with the specified configuration (which is
+ * dependent on device type).  RTNL lock must be held.
+ */
+int vport_set_options(struct vport *vport, struct nlattr *options)
+{
+	ASSERT_RTNL();
+
+	if (!vport->ops->set_options)
+		return -EOPNOTSUPP;
+	return vport->ops->set_options(vport, options);
+}
+
+/**
+ *	vport_del - delete existing vport device
+ *
+ * @vport: vport to delete.
+ *
+ * Detaches @vport from its datapath and destroys it.  It is possible to fail
+ * for reasons such as lack of memory.  RTNL lock must be held.
+ */
+void vport_del(struct vport *vport)
+{
+	ASSERT_RTNL();
+
+	hlist_del_rcu(&vport->hash_node);
+
+	vport->ops->destroy(vport);
+}
+
+/**
+ *	vport_get_stats - retrieve device stats
+ *
+ * @vport: vport from which to retrieve the stats
+ * @stats: location to store stats
+ *
+ * Retrieves transmit, receive, and error stats for the given device.
+ *
+ * Must be called with RTNL lock or rcu_read_lock.
+ */
+void vport_get_stats(struct vport *vport, struct ovs_vport_stats *stats)
+{
+	int i;
+
+	memset(stats, 0, sizeof(*stats));
+
+	/* We potentially have 2 sources of stats that need to be combined:
+	 * those we have collected (split into err_stats and percpu_stats) from
+	 * set_stats() and device error stats from netdev->get_stats() (for
+	 * errors that happen  downstream and therefore aren't reported through
+	 * our vport_record_error() function).
+	 * Stats from first source are reported by ovs (OVS_VPORT_ATTR_STATS).
+	 * netdev-stats can be directly read over netlink-ioctl.
+	 */
+
+	spin_lock_bh(&vport->stats_lock);
+
+	stats->rx_errors	= vport->err_stats.rx_errors;
+	stats->tx_errors	= vport->err_stats.tx_errors;
+	stats->tx_dropped	= vport->err_stats.tx_dropped;
+	stats->rx_dropped	= vport->err_stats.rx_dropped;
+
+	spin_unlock_bh(&vport->stats_lock);
+
+	for_each_possible_cpu(i) {
+		const struct vport_percpu_stats *percpu_stats;
+		struct vport_percpu_stats local_stats;
+		unsigned int start;
+
+		percpu_stats = per_cpu_ptr(vport->percpu_stats, i);
+
+		do {
+			start = u64_stats_fetch_begin_bh(&percpu_stats->sync);
+			local_stats = *percpu_stats;
+		} while (u64_stats_fetch_retry_bh(&percpu_stats->sync, start));
+
+		stats->rx_bytes		+= local_stats.rx_bytes;
+		stats->rx_packets	+= local_stats.rx_packets;
+		stats->tx_bytes		+= local_stats.tx_bytes;
+		stats->tx_packets	+= local_stats.tx_packets;
+	}
+}
+
+/**
+ *	vport_get_options - retrieve device options
+ *
+ * @vport: vport from which to retrieve the options.
+ * @skb: sk_buff where options should be appended.
+ *
+ * Retrieves the configuration of the given device, appending an
+ * %OVS_VPORT_ATTR_OPTIONS attribute that in turn contains nested
+ * vport-specific attributes to @skb.
+ *
+ * Returns 0 if successful, -EMSGSIZE if @skb has insufficient room, or another
+ * negative error code if a real error occurred.  If an error occurs, @skb is
+ * left unmodified.
+ *
+ * Must be called with RTNL lock or rcu_read_lock.
+ */
+int vport_get_options(const struct vport *vport, struct sk_buff *skb)
+{
+	struct nlattr *nla;
+
+	nla = nla_nest_start(skb, OVS_VPORT_ATTR_OPTIONS);
+	if (!nla)
+		return -EMSGSIZE;
+
+	if (vport->ops->get_options) {
+		int err = vport->ops->get_options(vport, skb);
+		if (err) {
+			nla_nest_cancel(skb, nla);
+			return err;
+		}
+	}
+
+	nla_nest_end(skb, nla);
+	return 0;
+}
+
+/**
+ *	vport_receive - pass up received packet to the datapath for processing
+ *
+ * @vport: vport that received the packet
+ * @skb: skb that was received
+ *
+ * Must be called with rcu_read_lock.  The packet cannot be shared and
+ * skb->data should point to the Ethernet header.  The caller must have already
+ * called compute_ip_summed() to initialize the checksumming fields.
+ */
+void vport_receive(struct vport *vport, struct sk_buff *skb)
+{
+	struct vport_percpu_stats *stats;
+
+	stats = per_cpu_ptr(vport->percpu_stats, smp_processor_id());
+
+	u64_stats_update_begin(&stats->sync);
+	stats->rx_packets++;
+	stats->rx_bytes += skb->len;
+	u64_stats_update_end(&stats->sync);
+
+	dp_process_received_packet(vport, skb);
+}
+
+/**
+ *	vport_send - send a packet on a device
+ *
+ * @vport: vport on which to send the packet
+ * @skb: skb to send
+ *
+ * Sends the given packet and returns the length of data sent.  Either RTNL
+ * lock or rcu_read_lock must be held.
+ */
+int vport_send(struct vport *vport, struct sk_buff *skb)
+{
+	int sent = vport->ops->send(vport, skb);
+
+	if (likely(sent)) {
+		struct vport_percpu_stats *stats;
+
+		stats = per_cpu_ptr(vport->percpu_stats, smp_processor_id());
+
+		u64_stats_update_begin(&stats->sync);
+		stats->tx_packets++;
+		stats->tx_bytes += sent;
+		u64_stats_update_end(&stats->sync);
+	}
+	return sent;
+}
+
+/**
+ *	vport_record_error - indicate device error to generic stats layer
+ *
+ * @vport: vport that encountered the error
+ * @err_type: one of enum vport_err_type types to indicate the error type
+ *
+ * If using the vport generic stats layer indicate that an error of the given
+ * type has occured.
+ */
+void vport_record_error(struct vport *vport, enum vport_err_type err_type)
+{
+	spin_lock(&vport->stats_lock);
+
+	switch (err_type) {
+	case VPORT_E_RX_DROPPED:
+		vport->err_stats.rx_dropped++;
+		break;
+
+	case VPORT_E_RX_ERROR:
+		vport->err_stats.rx_errors++;
+		break;
+
+	case VPORT_E_TX_DROPPED:
+		vport->err_stats.tx_dropped++;
+		break;
+
+	case VPORT_E_TX_ERROR:
+		vport->err_stats.tx_errors++;
+		break;
+	};
+
+	spin_unlock(&vport->stats_lock);
+}
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
new file mode 100644
index 0000000..da093cd
--- /dev/null
+++ b/net/openvswitch/vport.h
@@ -0,0 +1,205 @@
+/*
+ * Copyright (c) 2007-2011 Nicira Networks.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ */
+
+#ifndef VPORT_H
+#define VPORT_H 1
+
+#include <linux/list.h>
+#include <linux/openvswitch.h>
+#include <linux/skbuff.h>
+#include <linux/spinlock.h>
+#include <linux/u64_stats_sync.h>
+
+#include "datapath.h"
+
+struct vport;
+struct vport_parms;
+
+/* The following definitions are for users of the vport subsytem: */
+
+int vport_init(void);
+void vport_exit(void);
+
+struct vport *vport_add(const struct vport_parms *);
+void vport_del(struct vport *);
+
+struct vport *vport_locate(const char *name);
+
+void vport_get_stats(struct vport *, struct ovs_vport_stats *);
+
+int vport_set_options(struct vport *, struct nlattr *options);
+int vport_get_options(const struct vport *, struct sk_buff *);
+
+int vport_send(struct vport *, struct sk_buff *);
+
+/* The following definitions are for implementers of vport devices: */
+
+struct vport_percpu_stats {
+	u64 rx_bytes;
+	u64 rx_packets;
+	u64 tx_bytes;
+	u64 tx_packets;
+	struct u64_stats_sync sync;
+};
+
+struct vport_err_stats {
+	u64 rx_dropped;
+	u64 rx_errors;
+	u64 tx_dropped;
+	u64 tx_errors;
+};
+
+/**
+ * struct vport - one port within a datapath
+ * @rcu: RCU callback head for deferred destruction.
+ * @port_no: Index into @dp's @ports array.
+ * @dp: Datapath to which this port belongs.
+ * @node: Element in @dp's @port_list.
+ * @upcall_pid: The Netlink port to use for packets received on this port that
+ * miss the flow table.
+ * @hash_node: Element in @dev_table hash table in vport.c.
+ * @ops: Class structure.
+ * @percpu_stats: Points to per-CPU statistics used and maintained by vport
+ * @stats_lock: Protects @err_stats;
+ * @err_stats: Points to error statistics used and maintained by vport
+ */
+struct vport {
+	struct rcu_head rcu;
+	u16 port_no;
+	struct datapath	*dp;
+	struct list_head node;
+	u32 upcall_pid;
+
+	struct hlist_node hash_node;
+	const struct vport_ops *ops;
+
+	struct vport_percpu_stats __percpu *percpu_stats;
+
+	spinlock_t stats_lock;
+	struct vport_err_stats err_stats;
+};
+
+/**
+ * struct vport_parms - parameters for creating a new vport
+ *
+ * @name: New vport's name.
+ * @type: New vport's type.
+ * @options: %OVS_VPORT_ATTR_OPTIONS attribute from Netlink message, %NULL if
+ * none was supplied.
+ * @dp: New vport's datapath.
+ * @port_no: New vport's port number.
+ */
+struct vport_parms {
+	const char *name;
+	enum ovs_vport_type type;
+	struct nlattr *options;
+
+	/* For vport_alloc(). */
+	struct datapath *dp;
+	u16 port_no;
+	u32 upcall_pid;
+};
+
+/**
+ * struct vport_ops - definition of a type of virtual port
+ *
+ * @type: %OVS_VPORT_TYPE_* value for this type of virtual port.
+ * @create: Create a new vport configured as specified.  On success returns
+ * a new vport allocated with vport_alloc(), otherwise an ERR_PTR() value.
+ * @destroy: Destroys a vport.  Must call vport_free() on the vport but not
+ * before an RCU grace period has elapsed.
+ * @set_options: Modify the configuration of an existing vport.  May be %NULL
+ * if modification is not supported.
+ * @get_options: Appends vport-specific attributes for the configuration of an
+ * existing vport to a &struct sk_buff.  May be %NULL for a vport that does not
+ * have any configuration.
+ * @get_name: Get the device's name.
+ * @get_config: Get the device's configuration.
+ * @get_ifindex: Get the system interface index associated with the device.
+ * May be null if the device does not have an ifindex.
+ * @send: Send a packet on the device.  Returns the length of the packet sent.
+ */
+struct vport_ops {
+	enum ovs_vport_type type;
+
+	/* Called with RTNL lock. */
+	struct vport *(*create)(const struct vport_parms *);
+	void (*destroy)(struct vport *);
+
+	int (*set_options)(struct vport *, struct nlattr *);
+	int (*get_options)(const struct vport *, struct sk_buff *);
+
+	/* Called with rcu_read_lock or RTNL lock. */
+	const char *(*get_name)(const struct vport *);
+	void (*get_config)(const struct vport *, void *);
+	int (*get_ifindex)(const struct vport *);
+
+	int (*send)(struct vport *, struct sk_buff *);
+};
+
+enum vport_err_type {
+	VPORT_E_RX_DROPPED,
+	VPORT_E_RX_ERROR,
+	VPORT_E_TX_DROPPED,
+	VPORT_E_TX_ERROR,
+};
+
+struct vport *vport_alloc(int priv_size, const struct vport_ops *,
+			  const struct vport_parms *);
+void vport_free(struct vport *);
+
+#define VPORT_ALIGN 8
+
+/**
+ *	vport_priv - access private data area of vport
+ *
+ * @vport: vport to access
+ *
+ * If a nonzero size was passed in priv_size of vport_alloc() a private data
+ * area was allocated on creation.  This allows that area to be accessed and
+ * used for any purpose needed by the vport implementer.
+ */
+static inline void *vport_priv(const struct vport *vport)
+{
+	return (u8 *)vport + ALIGN(sizeof(struct vport), VPORT_ALIGN);
+}
+
+/**
+ *	vport_from_priv - lookup vport from private data pointer
+ *
+ * @priv: Start of private data area.
+ *
+ * It is sometimes useful to translate from a pointer to the private data
+ * area to the vport, such as in the case where the private data pointer is
+ * the result of a hash table lookup.  @priv must point to the start of the
+ * private data area.
+ */
+static inline struct vport *vport_from_priv(const void *priv)
+{
+	return (struct vport *)(priv - ALIGN(sizeof(struct vport), VPORT_ALIGN));
+}
+
+void vport_receive(struct vport *, struct sk_buff *);
+void vport_record_error(struct vport *, enum vport_err_type err_type);
+
+/* List of statically compiled vport implementations.  Don't forget to also
+ * add yours to the list at the top of vport.c. */
+extern const struct vport_ops netdev_vport_ops;
+extern const struct vport_ops internal_vport_ops;
+
+#endif /* vport.h */
-- 
1.7.5.4
