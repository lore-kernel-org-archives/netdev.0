From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 1/8 RFC v2] rtnetlink: Netlink interface for
	setting MAC and VLAN filters
Date: Tue, 18 Oct 2011 23:25:59 -0700
Message-ID: <20111019062559.7242.87299.stgit@savbu-pc100.cisco.com>
References: <20111019062543.7242.3969.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, dragos.tatulea@gmail.com, arnd@arndb.de,
	kvm@vger.kernel.org, mst@redhat.com, davem@davemloft.net,
	mchan@broadcom.com, dwang2@cisco.com, shemminger@vyatta.com,
	eric.dumazet@gmail.com, kaber@trash.net, benve@cisco.com
To: netdev@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20111019062543.7242.3969.stgit@savbu-pc100.cisco.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roopa Prabhu <roprabhu@cisco.com>

This patch introduces the following netlink interface to set
MAC and VLAN filters on an network interface

[IFLA_RX_FILTER] = {
                [IFLA_ADDR_FILTER] = {
                        [IFLA_ADDR_FILTER_FLAGS]
                        [IFLA_ADDR_FILTER_UC_LIST] = {
                                [IFLA_ADDR_LIST_ENTRY]
                        }
                        [IFLA_ADDR_FILTER_MC_LIST] = {
                                [IFLA_ADDR_LIST_ENTRY]
                        }
                }
                [IFLA_VLAN_FILTER] = {
                        [IFLA_VLAN_BITMAP]
                }
}

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
---
 include/linux/if_link.h |   39 +++++++++++++++++++++++++++++++++++++++
 net/core/rtnetlink.c    |   18 ++++++++++++++++++
 2 files changed, 57 insertions(+), 0 deletions(-)


diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index c52d4b5..41dbcbe 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -137,6 +137,7 @@ enum {
 	IFLA_AF_SPEC,
 	IFLA_GROUP,		/* Group the device belongs to */
 	IFLA_NET_NS_FD,
+	IFLA_RX_FILTER,
 	__IFLA_MAX
 };
 
@@ -390,4 +391,42 @@ struct ifla_port_vsi {
 	__u8 pad[3];
 };
 
+/* Addr filters */
+enum {
+	IFLA_RX_FILTER_UNSPEC,
+	IFLA_RX_ADDR_FILTER,
+	IFLA_RX_VLAN_FILTER,
+	__IFLA_RX_FILTER_MAX,
+};
+#define IFLA_RX_FILTER_MAX (__IFLA_RX_FILTER_MAX - 1)
+
+enum {
+	IFLA_ADDR_FILTER_UNSPEC,
+	IFLA_ADDR_FILTER_FLAGS,
+	IFLA_ADDR_FILTER_UC_LIST,
+	IFLA_ADDR_FILTER_MC_LIST,
+	__IFLA_ADDR_FILTER_MAX,
+};
+#define IFLA_ADDR_FILTER_MAX (__IFLA_ADDR_FILTER_MAX - 1)
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
+	IFLA_VLAN_FILTER_UNSPEC,
+	IFLA_VLAN_BITMAP,
+	__IFLA_VLAN_FILTER_MAX,
+};
+#define IFLA_VLAN_FILTER_MAX (__IFLA_VLAN_FILTER_MAX - 1)
+
+#define VLAN_BITMAP_SPLIT_MAX 8
+#define VLAN_BITMAP_SIZE	(VLAN_N_VID/VLAN_BITMAP_SPLIT_MAX)
+
 #endif /* _LINUX_IF_LINK_H */
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 9083e82..a3b213f 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -42,6 +42,7 @@
 
 #include <linux/inet.h>
 #include <linux/netdevice.h>
+#include <linux/if_vlan.h>
 #include <net/ip.h>
 #include <net/protocol.h>
 #include <net/arp.h>
@@ -1097,9 +1098,26 @@ const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_VF_PORTS]		= { .type = NLA_NESTED },
 	[IFLA_PORT_SELF]	= { .type = NLA_NESTED },
 	[IFLA_AF_SPEC]		= { .type = NLA_NESTED },
+	[IFLA_RX_FILTER]	= { .type = NLA_NESTED },
 };
 EXPORT_SYMBOL(ifla_policy);
 
+static const struct nla_policy ifla_rx_filter_policy[IFLA_RX_FILTER_MAX+1] = {
+	[IFLA_RX_ADDR_FILTER]	= { .type = NLA_NESTED },
+	[IFLA_RX_VLAN_FILTER]	 = { .type = NLA_NESTED },
+};
+
+static const struct nla_policy ifla_addr_filter_policy[IFLA_ADDR_FILTER_MAX+1] = {
+	[IFLA_ADDR_FILTER_FLAGS] = { .type = NLA_U32 },
+	[IFLA_ADDR_FILTER_UC_LIST] = { .type = NLA_NESTED },
+	[IFLA_ADDR_FILTER_MC_LIST] = { .type = NLA_NESTED },
+};
+
+static const struct nla_policy ifla_vlan_filter_policy[IFLA_VLAN_FILTER_MAX+1] = {
+	[IFLA_VLAN_BITMAP]	 = { .type = NLA_BINARY,
+				     .len = VLAN_BITMAP_SIZE },
+};
+
 static const struct nla_policy ifla_info_policy[IFLA_INFO_MAX+1] = {
 	[IFLA_INFO_KIND]	= { .type = NLA_STRING },
 	[IFLA_INFO_DATA]	= { .type = NLA_NESTED },

