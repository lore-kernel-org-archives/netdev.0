From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 1/6 RFC v3] rtnetlink: Netlink interface for
	setting MAC and VLAN filters
Date: Fri, 28 Oct 2011 19:34:04 -0700
Message-ID: <20111029023404.5198.75962.stgit@rhel6.1>
References: <20111029023159.5198.60245.stgit@rhel6.1>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, dragos.tatulea@gmail.com, kvm@vger.kernel.org,
	arnd@arndb.de, mst@redhat.com, davem@davemloft.net,
	gregory.v.rose@intel.com, mchan@broadcom.com, dwang2@cisco.com,
	shemminger@vyatta.com, eric.dumazet@gmail.com, kaber@trash.net,
	benve@cisco.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-1.cisco.com ([173.36.130.12]:41764 "EHLO
	mtv-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932503Ab1J1Sg4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2011 14:36:56 -0400
In-Reply-To: <20111029023159.5198.60245.stgit@rhel6.1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>

This patch introduces the following netlink interface to set
MAC and VLAN filters on an network interface. It can be used to
set RX filter on any network interface (if supported by the driver) and
also on a SRIOV VF via its PF

Interface to set RX filter on a SRIOV VF
[IFLA_VF_RX_FILTERS] = {
	[IFLA_VF_RX_FILTER] = {
		[IFLA_RX_FILTER_VF]
		[IFLA_RX_FILTER_ADDR] = {
			[IFLA_RX_FILTER_ADDR_FLAGS]
			[IFLA_RX_FILTER_ADDR_UC_LIST] = {
				[IFLA_ADDR_LIST_ENTRY]
			}
			[IFLA_RX_FILTER_ADDR_MC_LIST] = {
				[IFLA_ADDR_LIST_ENTRY]
			}
		}
		[IFLA_RX_FILTER_VLAN] = {
			[IFLA_RX_FILTER_VLAN_BITMAP]
		}
	}
	...
}

Interface to set RX filter on any network interface.:
[IFLA_RX_FILTER] = {
	[IFLA_RX_FILTER_VF]
	[IFLA_RX_FILTER_ADDR] = {
		[IFLA_RX_FILTER_ADDR_FLAGS]
		[IFLA_RX_FILTER_ADDR_UC_LIST] = {
			[IFLA_ADDR_LIST_ENTRY]
		}
		[IFLA_RX_FILTER_ADDR_MC_LIST] = {
			[IFLA_ADDR_LIST_ENTRY]
		}
	}
	[IFLA_RX_FILTER_VLAN] = {
		[IFLA_RX_FILTER_VLAN_BITMAP]
	}
}

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
---
 include/linux/if_link.h |   61 +++++++++++++++++++++++++++++++++++++++++++++++
 net/core/rtnetlink.c    |   20 +++++++++++++++
 2 files changed, 81 insertions(+), 0 deletions(-)


diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index c52d4b5..74a9f17 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -137,6 +137,8 @@ enum {
 	IFLA_AF_SPEC,
 	IFLA_GROUP,		/* Group the device belongs to */
 	IFLA_NET_NS_FD,
+	IFLA_VF_RX_FILTERS,
+	IFLA_RX_FILTER,
 	__IFLA_MAX
 };
 
@@ -390,4 +392,63 @@ struct ifla_port_vsi {
 	__u8 pad[3];
 };
 
+/* VF rx filters management section
+ *
+ *	Nested layout of set/get msg is:
+ *
+ *	[IFLA_VF_RX_FILTERS]
+ *		[IFLA_VF_RX_FILTER]
+ *			[IFLA_RX_FILTER_*], ...
+ *		[IFLA_VF_RX_FILTER]
+ *			[IFLA_RX_FILTER_*], ...
+ *		...
+ *	[IFLA_RX_FILTER]
+ *		[IFLA_RX_FILTER_*], ...
+ */
+enum {
+	IFLA_VF_RX_FILTER_UNSPEC,
+	IFLA_VF_RX_FILTER,			/* nest */
+	__IFLA_VF_RX_FILTER_MAX,
+};
+
+#define IFLA_VF_RX_FILTER_MAX (__IFLA_VF_RX_FILTER_MAX - 1)
+
+enum {
+	IFLA_RX_FILTER_UNSPEC,
+	IFLA_RX_FILTER_VF,		/* __u32 */
+	IFLA_RX_FILTER_ADDR,
+	IFLA_RX_FILTER_VLAN,
+	__IFLA_RX_FILTER_MAX,
+};
+#define IFLA_RX_FILTER_MAX (__IFLA_RX_FILTER_MAX - 1)
+
+enum {
+	IFLA_RX_FILTER_ADDR_UNSPEC,
+	IFLA_RX_FILTER_ADDR_FLAGS,
+	IFLA_RX_FILTER_ADDR_UC_LIST,
+	IFLA_RX_FILTER_ADDR_MC_LIST,
+	__IFLA_RX_FILTER_ADDR_MAX,
+};
+#define IFLA_RX_FILTER_ADDR_MAX (__IFLA_RX_FILTER_ADDR_MAX - 1)
+
+#define RX_FILTER_FLAGS (IFF_UP | IFF_BROADCAST | IFF_MULTICAST | \
+				IFF_PROMISC | IFF_ALLMULTI)
+
+enum {
+	IFLA_ADDR_LIST_UNSPEC,
+	IFLA_ADDR_LIST_ENTRY,
+	__IFLA_ADDR_LIST_MAX,
+};
+#define IFLA_ADDR_LIST_MAX (__IFLA_ADDR_LIST_MAX - 1)
+
+enum {
+	IFLA_RX_FILTER_VLAN_UNSPEC,
+	IFLA_RX_FILTER_VLAN_BITMAP,
+	__IFLA_RX_FILTER_VLAN_MAX,
+};
+#define IFLA_RX_FILTER_VLAN_MAX (__IFLA_RX_FILTER_VLAN_MAX - 1)
+
+#define VLAN_BITMAP_SPLIT_MAX 8
+#define VLAN_BITMAP_SIZE	(VLAN_N_VID/VLAN_BITMAP_SPLIT_MAX)
+
 #endif /* _LINUX_IF_LINK_H */
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 9083e82..9eead8e 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -42,6 +42,7 @@
 
 #include <linux/inet.h>
 #include <linux/netdevice.h>
+#include <linux/if_vlan.h>
 #include <net/ip.h>
 #include <net/protocol.h>
 #include <net/arp.h>
@@ -1097,6 +1098,8 @@ const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_VF_PORTS]		= { .type = NLA_NESTED },
 	[IFLA_PORT_SELF]	= { .type = NLA_NESTED },
 	[IFLA_AF_SPEC]		= { .type = NLA_NESTED },
+	[IFLA_VF_RX_FILTERS]	= { .type = NLA_NESTED },
+	[IFLA_RX_FILTER]	= { .type = NLA_NESTED },
 };
 EXPORT_SYMBOL(ifla_policy);
 
@@ -1132,6 +1135,23 @@ static const struct nla_policy ifla_port_policy[IFLA_PORT_MAX+1] = {
 	[IFLA_PORT_RESPONSE]	= { .type = NLA_U16, },
 };
 
+static const struct nla_policy ifla_rx_filter_policy[IFLA_RX_FILTER_MAX+1] = {
+	[IFLA_RX_FILTER_VF]	= { .type = NLA_U32 },
+	[IFLA_RX_FILTER_ADDR]	= { .type = NLA_NESTED },
+	[IFLA_RX_FILTER_VLAN]	= { .type = NLA_NESTED },
+};
+
+static const struct nla_policy ifla_addr_filter_policy[IFLA_RX_FILTER_ADDR_MAX+1] = {
+	[IFLA_RX_FILTER_ADDR_FLAGS]	= { .type = NLA_U32 },
+	[IFLA_RX_FILTER_ADDR_UC_LIST]	= { .type = NLA_NESTED },
+	[IFLA_RX_FILTER_ADDR_MC_LIST]	= { .type = NLA_NESTED },
+};
+
+static const struct nla_policy ifla_vlan_filter_policy[IFLA_RX_FILTER_VLAN_MAX+1] = {
+	[IFLA_RX_FILTER_VLAN_BITMAP]	= { .type = NLA_BINARY,
+					    .len = VLAN_BITMAP_SIZE },
+};
+
 struct net *rtnl_link_get_net(struct net *src_net, struct nlattr *tb[])
 {
 	struct net *net;
