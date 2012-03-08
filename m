From: pablo@netfilter.org
Subject: [PATCH 20/23] netfilter: add cttimeout infrastructure for fine timeout tuning
Date: Thu,  8 Mar 2012 02:01:09 +0100
Message-ID: <1331168472-5820-21-git-send-email-pablo@netfilter.org>
References: <1331168472-5820-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1331168472-5820-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch adds the infrastructure to add fine timeout tuning
over nfnetlink. Now you can use the NFNL_SUBSYS_CTNETLINK_TIMEOUT
subsystem to create/delete/dump timeout objects that contain some
specific timeout policy for one flow.

The follow up patches will allow you attach timeout policy object
to conntrack via the CT target and the conntrack extension
infrastructure.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/Kbuild                 |    1 +
 include/linux/netfilter/nfnetlink.h            |    3 +-
 include/linux/netfilter/nfnetlink_cttimeout.h  |  114 +++++++
 include/net/netfilter/nf_conntrack_l4proto.h   |   11 +
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |   47 +++
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |   47 +++
 net/netfilter/Kconfig                          |   11 +
 net/netfilter/Makefile                         |    1 +
 net/netfilter/nf_conntrack_proto_dccp.c        |   70 ++++
 net/netfilter/nf_conntrack_proto_generic.c     |   48 +++
 net/netfilter/nf_conntrack_proto_gre.c         |   55 ++++
 net/netfilter/nf_conntrack_proto_sctp.c        |   69 ++++
 net/netfilter/nf_conntrack_proto_tcp.c         |  127 ++++++++
 net/netfilter/nf_conntrack_proto_udp.c         |   64 ++++
 net/netfilter/nf_conntrack_proto_udplite.c     |   66 ++++
 net/netfilter/nfnetlink_cttimeout.c            |  398 ++++++++++++++++++++++++
 16 files changed, 1131 insertions(+), 1 deletions(-)
 create mode 100644 include/linux/netfilter/nfnetlink_cttimeout.h
 create mode 100644 net/netfilter/nfnetlink_cttimeout.c

diff --git a/include/linux/netfilter/Kbuild b/include/linux/netfilter/Kbuild
index aaa72aa..1697036 100644
--- a/include/linux/netfilter/Kbuild
+++ b/include/linux/netfilter/Kbuild
@@ -10,6 +10,7 @@ header-y += nfnetlink.h
 header-y += nfnetlink_acct.h
 header-y += nfnetlink_compat.h
 header-y += nfnetlink_conntrack.h
+header-y += nfnetlink_cttimeout.h
 header-y += nfnetlink_log.h
 header-y += nfnetlink_queue.h
 header-y += x_tables.h
diff --git a/include/linux/netfilter/nfnetlink.h b/include/linux/netfilter/nfnetlink.h
index b64454c..6fd1f0d 100644
--- a/include/linux/netfilter/nfnetlink.h
+++ b/include/linux/netfilter/nfnetlink.h
@@ -49,7 +49,8 @@ struct nfgenmsg {
 #define NFNL_SUBSYS_OSF			5
 #define NFNL_SUBSYS_IPSET		6
 #define NFNL_SUBSYS_ACCT		7
-#define NFNL_SUBSYS_COUNT		8
+#define NFNL_SUBSYS_CTNETLINK_TIMEOUT	8
+#define NFNL_SUBSYS_COUNT		9
 
 #ifdef __KERNEL__
 
diff --git a/include/linux/netfilter/nfnetlink_cttimeout.h b/include/linux/netfilter/nfnetlink_cttimeout.h
new file mode 100644
index 0000000..a2810a7
--- /dev/null
+++ b/include/linux/netfilter/nfnetlink_cttimeout.h
@@ -0,0 +1,114 @@
+#ifndef _CTTIMEOUT_NETLINK_H
+#define _CTTIMEOUT_NETLINK_H
+#include <linux/netfilter/nfnetlink.h>
+
+enum ctnl_timeout_msg_types {
+	IPCTNL_MSG_TIMEOUT_NEW,
+	IPCTNL_MSG_TIMEOUT_GET,
+	IPCTNL_MSG_TIMEOUT_DELETE,
+
+	IPCTNL_MSG_TIMEOUT_MAX
+};
+
+enum ctattr_timeout {
+	CTA_TIMEOUT_UNSPEC,
+	CTA_TIMEOUT_NAME,
+	CTA_TIMEOUT_L3PROTO,
+	CTA_TIMEOUT_L4PROTO,
+	CTA_TIMEOUT_DATA,
+	CTA_TIMEOUT_USE,
+	__CTA_TIMEOUT_MAX
+};
+#define CTA_TIMEOUT_MAX (__CTA_TIMEOUT_MAX - 1)
+
+enum ctattr_timeout_generic {
+	CTA_TIMEOUT_GENERIC_UNSPEC,
+	CTA_TIMEOUT_GENERIC_TIMEOUT,
+	__CTA_TIMEOUT_GENERIC_MAX
+};
+#define CTA_TIMEOUT_GENERIC_MAX (__CTA_TIMEOUT_GENERIC_MAX - 1)
+
+enum ctattr_timeout_tcp {
+	CTA_TIMEOUT_TCP_UNSPEC,
+	CTA_TIMEOUT_TCP_SYN_SENT,
+	CTA_TIMEOUT_TCP_SYN_RECV,
+	CTA_TIMEOUT_TCP_ESTABLISHED,
+	CTA_TIMEOUT_TCP_FIN_WAIT,
+	CTA_TIMEOUT_TCP_CLOSE_WAIT,
+	CTA_TIMEOUT_TCP_LAST_ACK,
+	CTA_TIMEOUT_TCP_TIME_WAIT,
+	CTA_TIMEOUT_TCP_CLOSE,
+	CTA_TIMEOUT_TCP_SYN_SENT2,
+	CTA_TIMEOUT_TCP_RETRANS,
+	CTA_TIMEOUT_TCP_UNACK,
+	__CTA_TIMEOUT_TCP_MAX
+};
+#define CTA_TIMEOUT_TCP_MAX (__CTA_TIMEOUT_TCP_MAX - 1)
+
+enum ctattr_timeout_udp {
+	CTA_TIMEOUT_UDP_UNSPEC,
+	CTA_TIMEOUT_UDP_UNREPLIED,
+	CTA_TIMEOUT_UDP_REPLIED,
+	__CTA_TIMEOUT_UDP_MAX
+};
+#define CTA_TIMEOUT_UDP_MAX (__CTA_TIMEOUT_UDP_MAX - 1)
+
+enum ctattr_timeout_udplite {
+	CTA_TIMEOUT_UDPLITE_UNSPEC,
+	CTA_TIMEOUT_UDPLITE_UNREPLIED,
+	CTA_TIMEOUT_UDPLITE_REPLIED,
+	__CTA_TIMEOUT_UDPLITE_MAX
+};
+#define CTA_TIMEOUT_UDPLITE_MAX (__CTA_TIMEOUT_UDPLITE_MAX - 1)
+
+enum ctattr_timeout_icmp {
+	CTA_TIMEOUT_ICMP_UNSPEC,
+	CTA_TIMEOUT_ICMP_TIMEOUT,
+	__CTA_TIMEOUT_ICMP_MAX
+};
+#define CTA_TIMEOUT_ICMP_MAX (__CTA_TIMEOUT_ICMP_MAX - 1)
+
+enum ctattr_timeout_dccp {
+	CTA_TIMEOUT_DCCP_UNSPEC,
+	CTA_TIMEOUT_DCCP_REQUEST,
+	CTA_TIMEOUT_DCCP_RESPOND,
+	CTA_TIMEOUT_DCCP_PARTOPEN,
+	CTA_TIMEOUT_DCCP_OPEN,
+	CTA_TIMEOUT_DCCP_CLOSEREQ,
+	CTA_TIMEOUT_DCCP_CLOSING,
+	CTA_TIMEOUT_DCCP_TIMEWAIT,
+	__CTA_TIMEOUT_DCCP_MAX
+};
+#define CTA_TIMEOUT_DCCP_MAX (__CTA_TIMEOUT_DCCP_MAX - 1)
+
+enum ctattr_timeout_sctp {
+	CTA_TIMEOUT_SCTP_UNSPEC,
+	CTA_TIMEOUT_SCTP_CLOSED,
+	CTA_TIMEOUT_SCTP_COOKIE_WAIT,
+	CTA_TIMEOUT_SCTP_COOKIE_ECHOED,
+	CTA_TIMEOUT_SCTP_ESTABLISHED,
+	CTA_TIMEOUT_SCTP_SHUTDOWN_SENT,
+	CTA_TIMEOUT_SCTP_SHUTDOWN_RECD,
+	CTA_TIMEOUT_SCTP_SHUTDOWN_ACK_SENT,
+	__CTA_TIMEOUT_SCTP_MAX
+};
+#define CTA_TIMEOUT_SCTP_MAX (__CTA_TIMEOUT_SCTP_MAX - 1)
+
+enum ctattr_timeout_icmpv6 {
+	CTA_TIMEOUT_ICMPV6_UNSPEC,
+	CTA_TIMEOUT_ICMPV6_TIMEOUT,
+	__CTA_TIMEOUT_ICMPV6_MAX
+};
+#define CTA_TIMEOUT_ICMPV6_MAX (__CTA_TIMEOUT_ICMPV6_MAX - 1)
+
+enum ctattr_timeout_gre {
+	CTA_TIMEOUT_GRE_UNSPEC,
+	CTA_TIMEOUT_GRE_UNREPLIED,
+	CTA_TIMEOUT_GRE_REPLIED,
+	__CTA_TIMEOUT_GRE_MAX
+};
+#define CTA_TIMEOUT_GRE_MAX (__CTA_TIMEOUT_GRE_MAX - 1)
+
+#define CTNL_TIMEOUT_NAME_MAX	32
+
+#endif
diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net/netfilter/nf_conntrack_l4proto.h
index c48b674..90c67c7 100644
--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
@@ -83,6 +83,17 @@ struct nf_conntrack_l4proto {
 
 	size_t nla_size;
 
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK_TIMEOUT)
+	struct {
+		size_t obj_size;
+		int (*nlattr_to_obj)(struct nlattr *tb[], void *data);
+		int (*obj_to_nlattr)(struct sk_buff *skb, const void *data);
+
+		unsigned int nlattr_max;
+		const struct nla_policy *nla_policy;
+	} ctnl_timeout;
+#endif
+
 #ifdef CONFIG_SYSCTL
 	struct ctl_table_header	**ctl_table_header;
 	struct ctl_table	*ctl_table;
diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
index 6b80112..7cbe9cb 100644
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -269,6 +269,44 @@ static int icmp_nlattr_tuple_size(void)
 }
 #endif
 
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK_TIMEOUT)
+
+#include <linux/netfilter/nfnetlink.h>
+#include <linux/netfilter/nfnetlink_cttimeout.h>
+
+static int icmp_timeout_nlattr_to_obj(struct nlattr *tb[], void *data)
+{
+	unsigned int *timeout = data;
+
+	if (tb[CTA_TIMEOUT_ICMP_TIMEOUT]) {
+		*timeout =
+			ntohl(nla_get_be32(tb[CTA_TIMEOUT_ICMP_TIMEOUT])) * HZ;
+	} else {
+		/* Set default ICMP timeout. */
+		*timeout = nf_ct_icmp_timeout;
+	}
+	return 0;
+}
+
+static int
+icmp_timeout_obj_to_nlattr(struct sk_buff *skb, const void *data)
+{
+	const unsigned int *timeout = data;
+
+	NLA_PUT_BE32(skb, CTA_TIMEOUT_ICMP_TIMEOUT, htonl(*timeout / HZ));
+
+	return 0;
+
+nla_put_failure:
+	return -ENOSPC;
+}
+
+static const struct nla_policy
+icmp_timeout_nla_policy[CTA_TIMEOUT_ICMP_MAX+1] = {
+	[CTA_TIMEOUT_ICMP_TIMEOUT]	= { .type = NLA_U32 },
+};
+#endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
+
 #ifdef CONFIG_SYSCTL
 static struct ctl_table_header *icmp_sysctl_header;
 static struct ctl_table icmp_sysctl_table[] = {
@@ -315,6 +353,15 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_icmp __read_mostly =
 	.nlattr_to_tuple	= icmp_nlattr_to_tuple,
 	.nla_policy		= icmp_nla_policy,
 #endif
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK_TIMEOUT)
+	.ctnl_timeout		= {
+		.nlattr_to_obj	= icmp_timeout_nlattr_to_obj,
+		.obj_to_nlattr	= icmp_timeout_obj_to_nlattr,
+		.nlattr_max	= CTA_TIMEOUT_ICMP_MAX,
+		.obj_size	= sizeof(unsigned int),
+		.nla_policy	= icmp_timeout_nla_policy,
+	},
+#endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
 #ifdef CONFIG_SYSCTL
 	.ctl_table_header	= &icmp_sysctl_header,
 	.ctl_table		= icmp_sysctl_table,
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index 2eb9751..92cc9f2 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -276,6 +276,44 @@ static int icmpv6_nlattr_tuple_size(void)
 }
 #endif
 
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK_TIMEOUT)
+
+#include <linux/netfilter/nfnetlink.h>
+#include <linux/netfilter/nfnetlink_cttimeout.h>
+
+static int icmpv6_timeout_nlattr_to_obj(struct nlattr *tb[], void *data)
+{
+	unsigned int *timeout = data;
+
+	if (tb[CTA_TIMEOUT_ICMPV6_TIMEOUT]) {
+		*timeout =
+		    ntohl(nla_get_be32(tb[CTA_TIMEOUT_ICMPV6_TIMEOUT])) * HZ;
+	} else {
+		/* Set default ICMPv6 timeout. */
+		*timeout = nf_ct_icmpv6_timeout;
+	}
+	return 0;
+}
+
+static int
+icmpv6_timeout_obj_to_nlattr(struct sk_buff *skb, const void *data)
+{
+	const unsigned int *timeout = data;
+
+	NLA_PUT_BE32(skb, CTA_TIMEOUT_ICMPV6_TIMEOUT, htonl(*timeout / HZ));
+
+	return 0;
+
+nla_put_failure:
+	return -ENOSPC;
+}
+
+static const struct nla_policy
+icmpv6_timeout_nla_policy[CTA_TIMEOUT_ICMPV6_MAX+1] = {
+	[CTA_TIMEOUT_ICMPV6_TIMEOUT]	= { .type = NLA_U32 },
+};
+#endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
+
 #ifdef CONFIG_SYSCTL
 static struct ctl_table_header *icmpv6_sysctl_header;
 static struct ctl_table icmpv6_sysctl_table[] = {
@@ -308,6 +346,15 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_icmpv6 __read_mostly =
 	.nlattr_to_tuple	= icmpv6_nlattr_to_tuple,
 	.nla_policy		= icmpv6_nla_policy,
 #endif
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK_TIMEOUT)
+	.ctnl_timeout		= {
+		.nlattr_to_obj	= icmpv6_timeout_nlattr_to_obj,
+		.obj_to_nlattr	= icmpv6_timeout_obj_to_nlattr,
+		.nlattr_max	= CTA_TIMEOUT_ICMP_MAX,
+		.obj_size	= sizeof(unsigned int),
+		.nla_policy	= icmpv6_timeout_nla_policy,
+	},
+#endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
 #ifdef CONFIG_SYSCTL
 	.ctl_table_header	= &icmpv6_sysctl_header,
 	.ctl_table		= icmpv6_sysctl_table,
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index b895d8b..f3efb65 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -314,6 +314,17 @@ config NF_CT_NETLINK
 	help
 	  This option enables support for a netlink-based userspace interface
 
+config NF_CT_NETLINK_TIMEOUT
+	tristate  'Connection tracking timeout tuning via Netlink'
+	select NETFILTER_NETLINK
+	depends on NETFILTER_ADVANCED
+	help
+	  This option enables support for connection tracking timeout
+	  fine-grain tuning. This allows you to attach specific timeout
+	  policies to flows, instead of using the global timeout policy.
+
+	  If unsure, say `N'.
+
 endif # NF_CONNTRACK
 
 # transparent proxy support
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index a28c2a6..cf7cdd6 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -22,6 +22,7 @@ obj-$(CONFIG_NF_CT_PROTO_UDPLITE) += nf_conntrack_proto_udplite.o
 
 # netlink interface for nf_conntrack
 obj-$(CONFIG_NF_CT_NETLINK) += nf_conntrack_netlink.o
+obj-$(CONFIG_NF_CT_NETLINK_TIMEOUT) += nfnetlink_cttimeout.o
 
 # connection tracking helpers
 nf_conntrack_h323-objs := nf_conntrack_h323_main.o nf_conntrack_h323_asn1.o
diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index 8ea3359..24fdce2 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -706,8 +706,60 @@ static int dccp_nlattr_size(void)
 	return nla_total_size(0)	/* CTA_PROTOINFO_DCCP */
 		+ nla_policy_len(dccp_nla_policy, CTA_PROTOINFO_DCCP_MAX + 1);
 }
+
 #endif
 
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK_TIMEOUT)
+
+#include <linux/netfilter/nfnetlink.h>
+#include <linux/netfilter/nfnetlink_cttimeout.h>
+
+static int dccp_timeout_nlattr_to_obj(struct nlattr *tb[], void *data)
+{
+	struct dccp_net *dn = dccp_pernet(&init_net);
+	unsigned int *timeouts = data;
+	int i;
+
+	/* set default DCCP timeouts. */
+	for (i=0; i<CT_DCCP_MAX; i++)
+		timeouts[i] = dn->dccp_timeout[i];
+
+	/* there's a 1:1 mapping between attributes and protocol states. */
+	for (i=CTA_TIMEOUT_DCCP_UNSPEC+1; i<CTA_TIMEOUT_DCCP_MAX+1; i++) {
+		if (tb[i]) {
+			timeouts[i] = ntohl(nla_get_be32(tb[i])) * HZ;
+		}
+	}
+	return 0;
+}
+
+static int
+dccp_timeout_obj_to_nlattr(struct sk_buff *skb, const void *data)
+{
+        const unsigned int *timeouts = data;
+	int i;
+
+	for (i=CTA_TIMEOUT_DCCP_UNSPEC+1; i<CTA_TIMEOUT_DCCP_MAX+1; i++)
+		NLA_PUT_BE32(skb, i, htonl(timeouts[i] / HZ));
+
+	return 0;
+
+nla_put_failure:
+	return -ENOSPC;
+}
+
+static const struct nla_policy
+dccp_timeout_nla_policy[CTA_TIMEOUT_DCCP_MAX+1] = {
+	[CTA_TIMEOUT_DCCP_REQUEST]	= { .type = NLA_U32 },
+	[CTA_TIMEOUT_DCCP_RESPOND]	= { .type = NLA_U32 },
+	[CTA_TIMEOUT_DCCP_PARTOPEN]	= { .type = NLA_U32 },
+	[CTA_TIMEOUT_DCCP_OPEN]		= { .type = NLA_U32 },
+	[CTA_TIMEOUT_DCCP_CLOSEREQ]	= { .type = NLA_U32 },
+	[CTA_TIMEOUT_DCCP_CLOSING]	= { .type = NLA_U32 },
+	[CTA_TIMEOUT_DCCP_TIMEWAIT]	= { .type = NLA_U32 },
+};
+#endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
+
 #ifdef CONFIG_SYSCTL
 /* template, data assigned later */
 static struct ctl_table dccp_sysctl_table[] = {
@@ -784,6 +836,15 @@ static struct nf_conntrack_l4proto dccp_proto4 __read_mostly = {
 	.nlattr_to_tuple	= nf_ct_port_nlattr_to_tuple,
 	.nla_policy		= nf_ct_port_nla_policy,
 #endif
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK_TIMEOUT)
+	.ctnl_timeout		= {
+		.nlattr_to_obj	= dccp_timeout_nlattr_to_obj,
+		.obj_to_nlattr	= dccp_timeout_obj_to_nlattr,
+		.nlattr_max	= CTA_TIMEOUT_DCCP_MAX,
+		.obj_size	= sizeof(unsigned int) * CT_DCCP_MAX,
+		.nla_policy	= dccp_timeout_nla_policy,
+	},
+#endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
 };
 
 static struct nf_conntrack_l4proto dccp_proto6 __read_mostly = {
@@ -807,6 +868,15 @@ static struct nf_conntrack_l4proto dccp_proto6 __read_mostly = {
 	.nlattr_to_tuple	= nf_ct_port_nlattr_to_tuple,
 	.nla_policy		= nf_ct_port_nla_policy,
 #endif
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK_TIMEOUT)
+	.ctnl_timeout		= {
+		.nlattr_to_obj	= dccp_timeout_nlattr_to_obj,
+		.obj_to_nlattr	= dccp_timeout_obj_to_nlattr,
+		.nlattr_max	= CTA_TIMEOUT_DCCP_MAX,
+		.obj_size	= sizeof(unsigned int) * CT_DCCP_MAX,
+		.nla_policy	= dccp_timeout_nla_policy,
+	},
+#endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
 };
 
 static __net_init int dccp_net_init(struct net *net)
diff --git a/net/netfilter/nf_conntrack_proto_generic.c b/net/netfilter/nf_conntrack_proto_generic.c
index 0e6c545..835e24c 100644
--- a/net/netfilter/nf_conntrack_proto_generic.c
+++ b/net/netfilter/nf_conntrack_proto_generic.c
@@ -65,6 +65,45 @@ static bool generic_new(struct nf_conn *ct, const struct sk_buff *skb,
 	return true;
 }
 
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK_TIMEOUT)
+
+#include <linux/netfilter/nfnetlink.h>
+#include <linux/netfilter/nfnetlink_cttimeout.h>
+
+static int generic_timeout_nlattr_to_obj(struct nlattr *tb[], void *data)
+{
+	unsigned int *timeout = data;
+
+	if (tb[CTA_TIMEOUT_GENERIC_TIMEOUT])
+		*timeout =
+		    ntohl(nla_get_be32(tb[CTA_TIMEOUT_GENERIC_TIMEOUT])) * HZ;
+	else {
+		/* Set default generic timeout. */
+		*timeout = nf_ct_generic_timeout;
+	}
+
+	return 0;
+}
+
+static int
+generic_timeout_obj_to_nlattr(struct sk_buff *skb, const void *data)
+{
+	const unsigned int *timeout = data;
+
+	NLA_PUT_BE32(skb, CTA_TIMEOUT_GENERIC_TIMEOUT, htonl(*timeout / HZ));
+
+	return 0;
+
+nla_put_failure:
+        return -ENOSPC;
+}
+
+static const struct nla_policy
+generic_timeout_nla_policy[CTA_TIMEOUT_GENERIC_MAX+1] = {
+	[CTA_TIMEOUT_GENERIC_TIMEOUT]	= { .type = NLA_U32 },
+};
+#endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
+
 #ifdef CONFIG_SYSCTL
 static struct ctl_table_header *generic_sysctl_header;
 static struct ctl_table generic_sysctl_table[] = {
@@ -102,6 +141,15 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_generic __read_mostly =
 	.packet			= generic_packet,
 	.get_timeouts		= generic_get_timeouts,
 	.new			= generic_new,
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK_TIMEOUT)
+	.ctnl_timeout		= {
+		.nlattr_to_obj	= generic_timeout_nlattr_to_obj,
+		.obj_to_nlattr	= generic_timeout_obj_to_nlattr,
+		.nlattr_max	= CTA_TIMEOUT_GENERIC_MAX,
+		.obj_size	= sizeof(unsigned int),
+		.nla_policy	= generic_timeout_nla_policy,
+	},
+#endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
 #ifdef CONFIG_SYSCTL
 	.ctl_table_header	= &generic_sysctl_header,
 	.ctl_table		= generic_sysctl_table,
diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_conntrack_proto_gre.c
index 1bf01c9..659648c 100644
--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -292,6 +292,52 @@ static void gre_destroy(struct nf_conn *ct)
 		nf_ct_gre_keymap_destroy(master);
 }
 
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK_TIMEOUT)
+
+#include <linux/netfilter/nfnetlink.h>
+#include <linux/netfilter/nfnetlink_cttimeout.h>
+
+static int gre_timeout_nlattr_to_obj(struct nlattr *tb[], void *data)
+{
+	unsigned int *timeouts = data;
+
+	/* set default timeouts for GRE. */
+	timeouts[GRE_CT_UNREPLIED] = gre_timeouts[GRE_CT_UNREPLIED];
+	timeouts[GRE_CT_REPLIED] = gre_timeouts[GRE_CT_REPLIED];
+
+	if (tb[CTA_TIMEOUT_GRE_UNREPLIED]) {
+		timeouts[GRE_CT_UNREPLIED] =
+			ntohl(nla_get_be32(tb[CTA_TIMEOUT_GRE_UNREPLIED])) * HZ;
+	}
+	if (tb[CTA_TIMEOUT_GRE_REPLIED]) {
+		timeouts[GRE_CT_REPLIED] =
+			ntohl(nla_get_be32(tb[CTA_TIMEOUT_GRE_REPLIED])) * HZ;
+	}
+	return 0;
+}
+
+static int
+gre_timeout_obj_to_nlattr(struct sk_buff *skb, const void *data)
+{
+	const unsigned int *timeouts = data;
+
+	NLA_PUT_BE32(skb, CTA_TIMEOUT_GRE_UNREPLIED,
+			htonl(timeouts[GRE_CT_UNREPLIED] / HZ));
+	NLA_PUT_BE32(skb, CTA_TIMEOUT_GRE_REPLIED,
+			htonl(timeouts[GRE_CT_REPLIED] / HZ));
+	return 0;
+
+nla_put_failure:
+	return -ENOSPC;
+}
+
+static const struct nla_policy
+gre_timeout_nla_policy[CTA_TIMEOUT_GRE_MAX+1] = {
+	[CTA_TIMEOUT_GRE_UNREPLIED]	= { .type = NLA_U32 },
+	[CTA_TIMEOUT_GRE_REPLIED]	= { .type = NLA_U32 },
+};
+#endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
+
 /* protocol helper struct */
 static struct nf_conntrack_l4proto nf_conntrack_l4proto_gre4 __read_mostly = {
 	.l3proto	 = AF_INET,
@@ -312,6 +358,15 @@ static struct nf_conntrack_l4proto nf_conntrack_l4proto_gre4 __read_mostly = {
 	.nlattr_to_tuple = nf_ct_port_nlattr_to_tuple,
 	.nla_policy	 = nf_ct_port_nla_policy,
 #endif
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK_TIMEOUT)
+	.ctnl_timeout    = {
+		.nlattr_to_obj	= gre_timeout_nlattr_to_obj,
+		.obj_to_nlattr	= gre_timeout_obj_to_nlattr,
+		.nlattr_max	= CTA_TIMEOUT_GRE_MAX,
+		.obj_size	= sizeof(unsigned int) * GRE_CT_MAX,
+		.nla_policy	= gre_timeout_nla_policy,
+	},
+#endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
 };
 
 static int proto_gre_net_init(struct net *net)
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index 2a07033..72b5088 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -549,6 +549,57 @@ static int sctp_nlattr_size(void)
 }
 #endif
 
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK_TIMEOUT)
+
+#include <linux/netfilter/nfnetlink.h>
+#include <linux/netfilter/nfnetlink_cttimeout.h>
+
+static int sctp_timeout_nlattr_to_obj(struct nlattr *tb[], void *data)
+{
+	unsigned int *timeouts = data;
+	int i;
+
+	/* set default SCTP timeouts. */
+	for (i=0; i<SCTP_CONNTRACK_MAX; i++)
+		timeouts[i] = sctp_timeouts[i];
+
+	/* there's a 1:1 mapping between attributes and protocol states. */
+	for (i=CTA_TIMEOUT_SCTP_UNSPEC+1; i<CTA_TIMEOUT_SCTP_MAX+1; i++) {
+		if (tb[i]) {
+			timeouts[i] = ntohl(nla_get_be32(tb[i])) * HZ;
+		}
+	}
+	return 0;
+}
+
+static int
+sctp_timeout_obj_to_nlattr(struct sk_buff *skb, const void *data)
+{
+        const unsigned int *timeouts = data;
+	int i;
+
+	for (i=CTA_TIMEOUT_SCTP_UNSPEC+1; i<CTA_TIMEOUT_SCTP_MAX+1; i++)
+	        NLA_PUT_BE32(skb, i, htonl(timeouts[i] / HZ));
+
+        return 0;
+
+nla_put_failure:
+        return -ENOSPC;
+}
+
+static const struct nla_policy
+sctp_timeout_nla_policy[CTA_TIMEOUT_SCTP_MAX+1] = {
+	[CTA_TIMEOUT_SCTP_CLOSED]		= { .type = NLA_U32 },
+	[CTA_TIMEOUT_SCTP_COOKIE_WAIT]		= { .type = NLA_U32 },
+	[CTA_TIMEOUT_SCTP_COOKIE_ECHOED]	= { .type = NLA_U32 },
+	[CTA_TIMEOUT_SCTP_ESTABLISHED]		= { .type = NLA_U32 },
+	[CTA_TIMEOUT_SCTP_SHUTDOWN_SENT]	= { .type = NLA_U32 },
+	[CTA_TIMEOUT_SCTP_SHUTDOWN_RECD]	= { .type = NLA_U32 },
+	[CTA_TIMEOUT_SCTP_SHUTDOWN_ACK_SENT]	= { .type = NLA_U32 },
+};
+#endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
+
+
 #ifdef CONFIG_SYSCTL
 static unsigned int sctp_sysctl_table_users;
 static struct ctl_table_header *sctp_sysctl_header;
@@ -682,6 +733,15 @@ static struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp4 __read_mostly = {
 	.nlattr_to_tuple	= nf_ct_port_nlattr_to_tuple,
 	.nla_policy		= nf_ct_port_nla_policy,
 #endif
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK_TIMEOUT)
+	.ctnl_timeout		= {
+		.nlattr_to_obj	= sctp_timeout_nlattr_to_obj,
+		.obj_to_nlattr	= sctp_timeout_obj_to_nlattr,
+		.nlattr_max	= CTA_TIMEOUT_SCTP_MAX,
+		.obj_size	= sizeof(unsigned int) * SCTP_CONNTRACK_MAX,
+		.nla_policy	= sctp_timeout_nla_policy,
+	},
+#endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
 #ifdef CONFIG_SYSCTL
 	.ctl_table_users	= &sctp_sysctl_table_users,
 	.ctl_table_header	= &sctp_sysctl_header,
@@ -712,6 +772,15 @@ static struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp6 __read_mostly = {
 	.nlattr_tuple_size	= nf_ct_port_nlattr_tuple_size,
 	.nlattr_to_tuple	= nf_ct_port_nlattr_to_tuple,
 	.nla_policy		= nf_ct_port_nla_policy,
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK_TIMEOUT)
+	.ctnl_timeout		= {
+		.nlattr_to_obj	= sctp_timeout_nlattr_to_obj,
+		.obj_to_nlattr	= sctp_timeout_obj_to_nlattr,
+		.nlattr_max	= CTA_TIMEOUT_SCTP_MAX,
+		.obj_size	= sizeof(unsigned int) * SCTP_CONNTRACK_MAX,
+		.nla_policy	= sctp_timeout_nla_policy,
+	},
+#endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
 #endif
 #ifdef CONFIG_SYSCTL
 	.ctl_table_users	= &sctp_sysctl_table_users,
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 8372bb4..361eade 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -1244,6 +1244,113 @@ static int tcp_nlattr_tuple_size(void)
 }
 #endif
 
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK_TIMEOUT)
+
+#include <linux/netfilter/nfnetlink.h>
+#include <linux/netfilter/nfnetlink_cttimeout.h>
+
+static int tcp_timeout_nlattr_to_obj(struct nlattr *tb[], void *data)
+{
+	unsigned int *timeouts = data;
+	int i;
+
+	/* set default TCP timeouts. */
+	for (i=0; i<TCP_CONNTRACK_TIMEOUT_MAX; i++)
+		timeouts[i] = tcp_timeouts[i];
+
+	if (tb[CTA_TIMEOUT_TCP_SYN_SENT]) {
+		timeouts[TCP_CONNTRACK_SYN_SENT] =
+			ntohl(nla_get_be32(tb[CTA_TIMEOUT_TCP_SYN_SENT]))*HZ;
+	}
+	if (tb[CTA_TIMEOUT_TCP_SYN_RECV]) {
+		timeouts[TCP_CONNTRACK_SYN_RECV] =
+			ntohl(nla_get_be32(tb[CTA_TIMEOUT_TCP_SYN_RECV]))*HZ;
+	}
+	if (tb[CTA_TIMEOUT_TCP_ESTABLISHED]) {
+		timeouts[TCP_CONNTRACK_ESTABLISHED] =
+			ntohl(nla_get_be32(tb[CTA_TIMEOUT_TCP_ESTABLISHED]))*HZ;
+	}
+	if (tb[CTA_TIMEOUT_TCP_FIN_WAIT]) {
+		timeouts[TCP_CONNTRACK_FIN_WAIT] =
+			ntohl(nla_get_be32(tb[CTA_TIMEOUT_TCP_FIN_WAIT]))*HZ;
+	}
+	if (tb[CTA_TIMEOUT_TCP_CLOSE_WAIT]) {
+		timeouts[TCP_CONNTRACK_CLOSE_WAIT] =
+			ntohl(nla_get_be32(tb[CTA_TIMEOUT_TCP_CLOSE_WAIT]))*HZ;
+	}
+	if (tb[CTA_TIMEOUT_TCP_LAST_ACK]) {
+		timeouts[TCP_CONNTRACK_LAST_ACK] =
+			ntohl(nla_get_be32(tb[CTA_TIMEOUT_TCP_LAST_ACK]))*HZ;
+	}
+	if (tb[CTA_TIMEOUT_TCP_TIME_WAIT]) {
+		timeouts[TCP_CONNTRACK_TIME_WAIT] =
+			ntohl(nla_get_be32(tb[CTA_TIMEOUT_TCP_TIME_WAIT]))*HZ;
+	}
+	if (tb[CTA_TIMEOUT_TCP_CLOSE]) {
+		timeouts[TCP_CONNTRACK_CLOSE] =
+			ntohl(nla_get_be32(tb[CTA_TIMEOUT_TCP_CLOSE]))*HZ;
+	}
+	if (tb[CTA_TIMEOUT_TCP_SYN_SENT2]) {
+		timeouts[TCP_CONNTRACK_SYN_SENT2] =
+			ntohl(nla_get_be32(tb[CTA_TIMEOUT_TCP_SYN_SENT2]))*HZ;
+	}
+	if (tb[CTA_TIMEOUT_TCP_RETRANS]) {
+		timeouts[TCP_CONNTRACK_RETRANS] =
+			ntohl(nla_get_be32(tb[CTA_TIMEOUT_TCP_RETRANS]))*HZ;
+	}
+	if (tb[CTA_TIMEOUT_TCP_UNACK]) {
+		timeouts[TCP_CONNTRACK_UNACK] =
+			ntohl(nla_get_be32(tb[CTA_TIMEOUT_TCP_UNACK]))*HZ;
+	}
+	return 0;
+}
+
+static int
+tcp_timeout_obj_to_nlattr(struct sk_buff *skb, const void *data)
+{
+	const unsigned int *timeouts = data;
+
+	NLA_PUT_BE32(skb, CTA_TIMEOUT_TCP_SYN_SENT,
+			htonl(timeouts[TCP_CONNTRACK_SYN_SENT] / HZ));
+	NLA_PUT_BE32(skb, CTA_TIMEOUT_TCP_SYN_RECV,
+			htonl(timeouts[TCP_CONNTRACK_SYN_RECV] / HZ));
+	NLA_PUT_BE32(skb, CTA_TIMEOUT_TCP_ESTABLISHED,
+			htonl(timeouts[TCP_CONNTRACK_ESTABLISHED] / HZ));
+	NLA_PUT_BE32(skb, CTA_TIMEOUT_TCP_FIN_WAIT,
+			htonl(timeouts[TCP_CONNTRACK_FIN_WAIT] / HZ));
+	NLA_PUT_BE32(skb, CTA_TIMEOUT_TCP_CLOSE_WAIT,
+			htonl(timeouts[TCP_CONNTRACK_CLOSE_WAIT] / HZ));
+	NLA_PUT_BE32(skb, CTA_TIMEOUT_TCP_LAST_ACK,
+			htonl(timeouts[TCP_CONNTRACK_LAST_ACK] / HZ));
+	NLA_PUT_BE32(skb, CTA_TIMEOUT_TCP_TIME_WAIT,
+			htonl(timeouts[TCP_CONNTRACK_TIME_WAIT] / HZ));
+	NLA_PUT_BE32(skb, CTA_TIMEOUT_TCP_CLOSE,
+			htonl(timeouts[TCP_CONNTRACK_CLOSE] / HZ));
+	NLA_PUT_BE32(skb, CTA_TIMEOUT_TCP_SYN_SENT2,
+			htonl(timeouts[TCP_CONNTRACK_SYN_SENT2] / HZ));
+	NLA_PUT_BE32(skb, CTA_TIMEOUT_TCP_RETRANS,
+			htonl(timeouts[TCP_CONNTRACK_RETRANS] / HZ));
+	NLA_PUT_BE32(skb, CTA_TIMEOUT_TCP_UNACK,
+			htonl(timeouts[TCP_CONNTRACK_UNACK] / HZ));
+	return 0;
+
+nla_put_failure:
+	return -ENOSPC;
+}
+
+static const struct nla_policy tcp_timeout_nla_policy[CTA_TIMEOUT_TCP_MAX+1] = {
+	[CTA_TIMEOUT_TCP_SYN_SENT]	= { .type = NLA_U32 },
+	[CTA_TIMEOUT_TCP_SYN_RECV]	= { .type = NLA_U32 },
+	[CTA_TIMEOUT_TCP_ESTABLISHED]	= { .type = NLA_U32 },
+	[CTA_TIMEOUT_TCP_FIN_WAIT]	= { .type = NLA_U32 },
+	[CTA_TIMEOUT_TCP_CLOSE_WAIT]	= { .type = NLA_U32 },
+	[CTA_TIMEOUT_TCP_LAST_ACK]	= { .type = NLA_U32 },
+	[CTA_TIMEOUT_TCP_TIME_WAIT]	= { .type = NLA_U32 },
+	[CTA_TIMEOUT_TCP_CLOSE]		= { .type = NLA_U32 },
+	[CTA_TIMEOUT_TCP_SYN_SENT2]	= { .type = NLA_U32 },
+};
+#endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
+
 #ifdef CONFIG_SYSCTL
 static unsigned int tcp_sysctl_table_users;
 static struct ctl_table_header *tcp_sysctl_header;
@@ -1462,6 +1569,16 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_tcp4 __read_mostly =
 	.nlattr_tuple_size	= tcp_nlattr_tuple_size,
 	.nla_policy		= nf_ct_port_nla_policy,
 #endif
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK_TIMEOUT)
+	.ctnl_timeout		= {
+		.nlattr_to_obj	= tcp_timeout_nlattr_to_obj,
+		.obj_to_nlattr	= tcp_timeout_obj_to_nlattr,
+		.nlattr_max	= CTA_TIMEOUT_TCP_MAX,
+		.obj_size	= sizeof(unsigned int) *
+					TCP_CONNTRACK_TIMEOUT_MAX,
+		.nla_policy	= tcp_timeout_nla_policy,
+	},
+#endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
 #ifdef CONFIG_SYSCTL
 	.ctl_table_users	= &tcp_sysctl_table_users,
 	.ctl_table_header	= &tcp_sysctl_header,
@@ -1495,6 +1612,16 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_tcp6 __read_mostly =
 	.nlattr_tuple_size	= tcp_nlattr_tuple_size,
 	.nla_policy		= nf_ct_port_nla_policy,
 #endif
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK_TIMEOUT)
+	.ctnl_timeout		= {
+		.nlattr_to_obj	= tcp_timeout_nlattr_to_obj,
+		.obj_to_nlattr	= tcp_timeout_obj_to_nlattr,
+		.nlattr_max	= CTA_TIMEOUT_TCP_MAX,
+		.obj_size	= sizeof(unsigned int) *
+					TCP_CONNTRACK_TIMEOUT_MAX,
+		.nla_policy	= tcp_timeout_nla_policy,
+	},
+#endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
 #ifdef CONFIG_SYSCTL
 	.ctl_table_users	= &tcp_sysctl_table_users,
 	.ctl_table_header	= &tcp_sysctl_header,
diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index 70e0059..a9073dc 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -152,6 +152,52 @@ static int udp_error(struct net *net, struct nf_conn *tmpl, struct sk_buff *skb,
 	return NF_ACCEPT;
 }
 
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK_TIMEOUT)
+
+#include <linux/netfilter/nfnetlink.h>
+#include <linux/netfilter/nfnetlink_cttimeout.h>
+
+static int udp_timeout_nlattr_to_obj(struct nlattr *tb[], void *data)
+{
+	unsigned int *timeouts = data;
+
+	/* set default timeouts for UDP. */
+	timeouts[UDP_CT_UNREPLIED] = udp_timeouts[UDP_CT_UNREPLIED];
+	timeouts[UDP_CT_REPLIED] = udp_timeouts[UDP_CT_REPLIED];
+
+	if (tb[CTA_TIMEOUT_UDP_UNREPLIED]) {
+		timeouts[UDP_CT_UNREPLIED] =
+			ntohl(nla_get_be32(tb[CTA_TIMEOUT_UDP_UNREPLIED])) * HZ;
+	}
+	if (tb[CTA_TIMEOUT_UDP_REPLIED]) {
+		timeouts[UDP_CT_REPLIED] =
+			ntohl(nla_get_be32(tb[CTA_TIMEOUT_UDP_REPLIED])) * HZ;
+	}
+	return 0;
+}
+
+static int
+udp_timeout_obj_to_nlattr(struct sk_buff *skb, const void *data)
+{
+	const unsigned int *timeouts = data;
+
+	NLA_PUT_BE32(skb, CTA_TIMEOUT_UDP_UNREPLIED,
+			htonl(timeouts[UDP_CT_UNREPLIED] / HZ));
+	NLA_PUT_BE32(skb, CTA_TIMEOUT_UDP_REPLIED,
+			htonl(timeouts[UDP_CT_REPLIED] / HZ));
+	return 0;
+
+nla_put_failure:
+	return -ENOSPC;
+}
+
+static const struct nla_policy
+udp_timeout_nla_policy[CTA_TIMEOUT_UDP_MAX+1] = {
+       [CTA_TIMEOUT_UDP_UNREPLIED]	= { .type = NLA_U32 },
+       [CTA_TIMEOUT_UDP_REPLIED]	= { .type = NLA_U32 },
+};
+#endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
+
 #ifdef CONFIG_SYSCTL
 static unsigned int udp_sysctl_table_users;
 static struct ctl_table_header *udp_sysctl_header;
@@ -211,6 +257,15 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_udp4 __read_mostly =
 	.nlattr_tuple_size	= nf_ct_port_nlattr_tuple_size,
 	.nla_policy		= nf_ct_port_nla_policy,
 #endif
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK_TIMEOUT)
+	.ctnl_timeout		= {
+		.nlattr_to_obj	= udp_timeout_nlattr_to_obj,
+		.obj_to_nlattr	= udp_timeout_obj_to_nlattr,
+		.nlattr_max	= CTA_TIMEOUT_UDP_MAX,
+		.obj_size	= sizeof(unsigned int) * CTA_TIMEOUT_UDP_MAX,
+		.nla_policy	= udp_timeout_nla_policy,
+	},
+#endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
 #ifdef CONFIG_SYSCTL
 	.ctl_table_users	= &udp_sysctl_table_users,
 	.ctl_table_header	= &udp_sysctl_header,
@@ -240,6 +295,15 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_udp6 __read_mostly =
 	.nlattr_tuple_size	= nf_ct_port_nlattr_tuple_size,
 	.nla_policy		= nf_ct_port_nla_policy,
 #endif
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK_TIMEOUT)
+	.ctnl_timeout		= {
+		.nlattr_to_obj	= udp_timeout_nlattr_to_obj,
+		.obj_to_nlattr	= udp_timeout_obj_to_nlattr,
+		.nlattr_max	= CTA_TIMEOUT_UDP_MAX,
+		.obj_size	= sizeof(unsigned int) * CTA_TIMEOUT_UDP_MAX,
+		.nla_policy	= udp_timeout_nla_policy,
+	},
+#endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
 #ifdef CONFIG_SYSCTL
 	.ctl_table_users	= &udp_sysctl_table_users,
 	.ctl_table_header	= &udp_sysctl_header,
diff --git a/net/netfilter/nf_conntrack_proto_udplite.c b/net/netfilter/nf_conntrack_proto_udplite.c
index 0b32ccb..e060639 100644
--- a/net/netfilter/nf_conntrack_proto_udplite.c
+++ b/net/netfilter/nf_conntrack_proto_udplite.c
@@ -156,6 +156,52 @@ static int udplite_error(struct net *net, struct nf_conn *tmpl,
 	return NF_ACCEPT;
 }
 
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK_TIMEOUT)
+
+#include <linux/netfilter/nfnetlink.h>
+#include <linux/netfilter/nfnetlink_cttimeout.h>
+
+static int udplite_timeout_nlattr_to_obj(struct nlattr *tb[], void *data)
+{
+	unsigned int *timeouts = data;
+
+	/* set default timeouts for UDPlite. */
+	timeouts[UDPLITE_CT_UNREPLIED] = udplite_timeouts[UDPLITE_CT_UNREPLIED];
+	timeouts[UDPLITE_CT_REPLIED] = udplite_timeouts[UDPLITE_CT_REPLIED];
+
+	if (tb[CTA_TIMEOUT_UDPLITE_UNREPLIED]) {
+		timeouts[UDPLITE_CT_UNREPLIED] =
+		  ntohl(nla_get_be32(tb[CTA_TIMEOUT_UDPLITE_UNREPLIED])) * HZ;
+	}
+	if (tb[CTA_TIMEOUT_UDPLITE_REPLIED]) {
+		timeouts[UDPLITE_CT_REPLIED] =
+		  ntohl(nla_get_be32(tb[CTA_TIMEOUT_UDPLITE_REPLIED])) * HZ;
+	}
+	return 0;
+}
+
+static int
+udplite_timeout_obj_to_nlattr(struct sk_buff *skb, const void *data)
+{
+	const unsigned int *timeouts = data;
+
+	NLA_PUT_BE32(skb, CTA_TIMEOUT_UDPLITE_UNREPLIED,
+			htonl(timeouts[UDPLITE_CT_UNREPLIED] / HZ));
+	NLA_PUT_BE32(skb, CTA_TIMEOUT_UDPLITE_REPLIED,
+			htonl(timeouts[UDPLITE_CT_REPLIED] / HZ));
+	return 0;
+
+nla_put_failure:
+	return -ENOSPC;
+}
+
+static const struct nla_policy
+udplite_timeout_nla_policy[CTA_TIMEOUT_UDPLITE_MAX+1] = {
+	[CTA_TIMEOUT_UDPLITE_UNREPLIED]	= { .type = NLA_U32 },
+	[CTA_TIMEOUT_UDPLITE_REPLIED]	= { .type = NLA_U32 },
+};
+#endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
+
 #ifdef CONFIG_SYSCTL
 static unsigned int udplite_sysctl_table_users;
 static struct ctl_table_header *udplite_sysctl_header;
@@ -196,6 +242,16 @@ static struct nf_conntrack_l4proto nf_conntrack_l4proto_udplite4 __read_mostly =
 	.nlattr_to_tuple	= nf_ct_port_nlattr_to_tuple,
 	.nla_policy		= nf_ct_port_nla_policy,
 #endif
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK_TIMEOUT)
+	.ctnl_timeout		= {
+		.nlattr_to_obj	= udplite_timeout_nlattr_to_obj,
+		.obj_to_nlattr	= udplite_timeout_obj_to_nlattr,
+		.nlattr_max	= CTA_TIMEOUT_UDPLITE_MAX,
+		.obj_size	= sizeof(unsigned int) *
+					CTA_TIMEOUT_UDPLITE_MAX,
+		.nla_policy	= udplite_timeout_nla_policy,
+	},
+#endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
 #ifdef CONFIG_SYSCTL
 	.ctl_table_users	= &udplite_sysctl_table_users,
 	.ctl_table_header	= &udplite_sysctl_header,
@@ -221,6 +277,16 @@ static struct nf_conntrack_l4proto nf_conntrack_l4proto_udplite6 __read_mostly =
 	.nlattr_to_tuple	= nf_ct_port_nlattr_to_tuple,
 	.nla_policy		= nf_ct_port_nla_policy,
 #endif
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK_TIMEOUT)
+	.ctnl_timeout		= {
+		.nlattr_to_obj	= udplite_timeout_nlattr_to_obj,
+		.obj_to_nlattr	= udplite_timeout_obj_to_nlattr,
+		.nlattr_max	= CTA_TIMEOUT_UDPLITE_MAX,
+		.obj_size	= sizeof(unsigned int) *
+					CTA_TIMEOUT_UDPLITE_MAX,
+		.nla_policy	= udplite_timeout_nla_policy,
+	},
+#endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
 #ifdef CONFIG_SYSCTL
 	.ctl_table_users	= &udplite_sysctl_table_users,
 	.ctl_table_header	= &udplite_sysctl_header,
diff --git a/net/netfilter/nfnetlink_cttimeout.c b/net/netfilter/nfnetlink_cttimeout.c
new file mode 100644
index 0000000..b860d52
--- /dev/null
+++ b/net/netfilter/nfnetlink_cttimeout.c
@@ -0,0 +1,398 @@
+/*
+ * (C) 2012 by Pablo Neira Ayuso <pablo@netfilter.org>
+ * (C) 2012 by Vyatta Inc. <http://www.vyatta.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation (or any later at your option).
+ */
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/rculist.h>
+#include <linux/rculist_nulls.h>
+#include <linux/types.h>
+#include <linux/timer.h>
+#include <linux/security.h>
+#include <linux/skbuff.h>
+#include <linux/errno.h>
+#include <linux/netlink.h>
+#include <linux/spinlock.h>
+#include <linux/interrupt.h>
+#include <linux/slab.h>
+
+#include <linux/netfilter.h>
+#include <net/netlink.h>
+#include <net/sock.h>
+#include <net/netfilter/nf_conntrack.h>
+#include <net/netfilter/nf_conntrack_core.h>
+#include <net/netfilter/nf_conntrack_l3proto.h>
+#include <net/netfilter/nf_conntrack_l4proto.h>
+#include <net/netfilter/nf_conntrack_tuple.h>
+
+#include <linux/netfilter/nfnetlink.h>
+#include <linux/netfilter/nfnetlink_cttimeout.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Pablo Neira Ayuso <pablo@netfilter.org>");
+MODULE_DESCRIPTION("cttimeout: Extended Netfilter Connection Tracking timeout tuning");
+
+struct ctnl_timeout {
+	struct list_head	head;
+	struct rcu_head		rcu_head;
+	atomic_t		refcnt;
+	char			name[CTNL_TIMEOUT_NAME_MAX];
+	__u16			l3num;
+	__u8			l4num;
+	char			data[0];
+};
+
+static LIST_HEAD(cttimeout_list);
+
+static const struct nla_policy cttimeout_nla_policy[CTA_TIMEOUT_MAX+1] = {
+	[CTA_TIMEOUT_NAME]	= { .type = NLA_NUL_STRING },
+	[CTA_TIMEOUT_L3PROTO]	= { .type = NLA_U16 },
+	[CTA_TIMEOUT_L4PROTO]	= { .type = NLA_U8 },
+	[CTA_TIMEOUT_DATA]	= { .type = NLA_NESTED },
+};
+
+static int
+ctnl_timeout_parse_policy(struct ctnl_timeout *timeout,
+			       struct nf_conntrack_l4proto *l4proto,
+			       const struct nlattr *attr)
+{
+	int ret = 0;
+
+	if (likely(l4proto->ctnl_timeout.nlattr_to_obj)) {
+		struct nlattr *tb[l4proto->ctnl_timeout.nlattr_max+1];
+
+		nla_parse_nested(tb, l4proto->ctnl_timeout.nlattr_max,
+				 attr, l4proto->ctnl_timeout.nla_policy);
+
+		ret = l4proto->ctnl_timeout.nlattr_to_obj(tb, &timeout->data);
+	}
+	return ret;
+}
+
+static int
+cttimeout_new_timeout(struct sock *ctnl, struct sk_buff *skb,
+		      const struct nlmsghdr *nlh,
+		      const struct nlattr * const cda[])
+{
+	__u16 l3num;
+	__u8 l4num;
+	struct nf_conntrack_l4proto *l4proto;
+	struct ctnl_timeout *timeout, *matching = NULL;
+	char *name;
+	int ret;
+
+	if (!cda[CTA_TIMEOUT_NAME] ||
+	    !cda[CTA_TIMEOUT_L3PROTO] ||
+	    !cda[CTA_TIMEOUT_L4PROTO] ||
+	    !cda[CTA_TIMEOUT_DATA])
+		return -EINVAL;
+
+	name = nla_data(cda[CTA_TIMEOUT_NAME]);
+	l3num = ntohs(nla_get_be16(cda[CTA_TIMEOUT_L3PROTO]));
+	l4num = nla_get_u8(cda[CTA_TIMEOUT_L4PROTO]);
+
+	list_for_each_entry(timeout, &cttimeout_list, head) {
+		if (strncmp(timeout->name, name, CTNL_TIMEOUT_NAME_MAX) != 0)
+			continue;
+
+		if (nlh->nlmsg_flags & NLM_F_EXCL)
+			return -EEXIST;
+
+		matching = timeout;
+		break;
+	}
+
+	l4proto = __nf_ct_l4proto_find(l3num, l4num);
+
+	/* This protocol is not supportted, skip. */
+	if (l4proto->l4proto != l4num)
+		return -EOPNOTSUPP;
+
+	if (matching) {
+		if (nlh->nlmsg_flags & NLM_F_REPLACE) {
+			/* You cannot replace one timeout policy by another of
+			 * different kind, sorry.
+			 */
+			if (matching->l3num != l3num ||
+			    matching->l4num != l4num)
+				return -EINVAL;
+
+			ret = ctnl_timeout_parse_policy(matching, l4proto,
+							cda[CTA_TIMEOUT_DATA]);
+			return ret;
+		}
+		return -EBUSY;
+	}
+
+	timeout = kzalloc(sizeof(struct ctnl_timeout) +
+			  l4proto->ctnl_timeout.obj_size, GFP_KERNEL);
+	if (timeout == NULL)
+		return -ENOMEM;
+
+	ret = ctnl_timeout_parse_policy(timeout, l4proto,
+					cda[CTA_TIMEOUT_DATA]);
+	if (ret < 0)
+		goto err;
+
+	strcpy(timeout->name, nla_data(cda[CTA_TIMEOUT_NAME]));
+	timeout->l3num = l3num;
+	timeout->l4num = l4num;
+	atomic_set(&timeout->refcnt, 1);
+	list_add_tail_rcu(&timeout->head, &cttimeout_list);
+
+	return 0;
+err:
+	kfree(timeout);
+	return ret;
+}
+
+static int
+ctnl_timeout_fill_info(struct sk_buff *skb, u32 pid, u32 seq, u32 type,
+		       int event, struct ctnl_timeout *timeout)
+{
+	struct nlmsghdr *nlh;
+	struct nfgenmsg *nfmsg;
+	unsigned int flags = pid ? NLM_F_MULTI : 0;
+	struct nf_conntrack_l4proto *l4proto;
+
+	event |= NFNL_SUBSYS_CTNETLINK_TIMEOUT << 8;
+	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*nfmsg), flags);
+	if (nlh == NULL)
+		goto nlmsg_failure;
+
+	nfmsg = nlmsg_data(nlh);
+	nfmsg->nfgen_family = AF_UNSPEC;
+	nfmsg->version = NFNETLINK_V0;
+	nfmsg->res_id = 0;
+
+	NLA_PUT_STRING(skb, CTA_TIMEOUT_NAME, timeout->name);
+	NLA_PUT_BE16(skb, CTA_TIMEOUT_L3PROTO, htons(timeout->l3num));
+	NLA_PUT_U8(skb, CTA_TIMEOUT_L4PROTO, timeout->l4num);
+	NLA_PUT_BE32(skb, CTA_TIMEOUT_USE,
+			htonl(atomic_read(&timeout->refcnt)));
+
+	l4proto = __nf_ct_l4proto_find(timeout->l3num, timeout->l4num);
+
+	/* If the timeout object does not match the layer 4 protocol tracker,
+	 * then skip dumping the data part since we don't know how to
+	 * interpret it. This may happen for UPDlite, SCTP and DCCP since
+	 * you can unload the module.
+	 */
+	if (timeout->l4num != l4proto->l4proto)
+		goto out;
+
+	if (likely(l4proto->ctnl_timeout.obj_to_nlattr)) {
+		struct nlattr *nest_parms;
+		int ret;
+
+		nest_parms = nla_nest_start(skb,
+					    CTA_TIMEOUT_DATA | NLA_F_NESTED);
+		if (!nest_parms)
+			goto nla_put_failure;
+
+		ret = l4proto->ctnl_timeout.obj_to_nlattr(skb, &timeout->data);
+		if (ret < 0)
+			goto nla_put_failure;
+
+		nla_nest_end(skb, nest_parms);
+	}
+out:
+	nlmsg_end(skb, nlh);
+	return skb->len;
+
+nlmsg_failure:
+nla_put_failure:
+	nlmsg_cancel(skb, nlh);
+	return -1;
+}
+
+static int
+ctnl_timeout_dump(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct ctnl_timeout *cur, *last;
+
+	if (cb->args[2])
+		return 0;
+
+	last = (struct ctnl_timeout *)cb->args[1];
+	if (cb->args[1])
+		cb->args[1] = 0;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(cur, &cttimeout_list, head) {
+		if (last && cur != last)
+			continue;
+
+		if (ctnl_timeout_fill_info(skb, NETLINK_CB(cb->skb).pid,
+					   cb->nlh->nlmsg_seq,
+					   NFNL_MSG_TYPE(cb->nlh->nlmsg_type),
+					   IPCTNL_MSG_TIMEOUT_NEW, cur) < 0) {
+			cb->args[1] = (unsigned long)cur;
+			break;
+		}
+	}
+	if (!cb->args[1])
+		cb->args[2] = 1;
+	rcu_read_unlock();
+	return skb->len;
+}
+
+static int
+cttimeout_get_timeout(struct sock *ctnl, struct sk_buff *skb,
+		      const struct nlmsghdr *nlh,
+		      const struct nlattr * const cda[])
+{
+	int ret = -ENOENT;
+	char *name;
+	struct ctnl_timeout *cur;
+
+	if (nlh->nlmsg_flags & NLM_F_DUMP) {
+		struct netlink_dump_control c = {
+			.dump = ctnl_timeout_dump,
+		};
+		return netlink_dump_start(ctnl, skb, nlh, &c);
+	}
+
+	if (!cda[CTA_TIMEOUT_NAME])
+		return -EINVAL;
+	name = nla_data(cda[CTA_TIMEOUT_NAME]);
+
+	list_for_each_entry(cur, &cttimeout_list, head) {
+		struct sk_buff *skb2;
+
+		if (strncmp(cur->name, name, CTNL_TIMEOUT_NAME_MAX) != 0)
+			continue;
+
+		skb2 = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+		if (skb2 == NULL) {
+			ret = -ENOMEM;
+			break;
+		}
+
+		ret = ctnl_timeout_fill_info(skb2, NETLINK_CB(skb).pid,
+					     nlh->nlmsg_seq,
+					     NFNL_MSG_TYPE(nlh->nlmsg_type),
+					     IPCTNL_MSG_TIMEOUT_NEW, cur);
+		if (ret <= 0) {
+			kfree_skb(skb2);
+			break;
+		}
+		ret = netlink_unicast(ctnl, skb2, NETLINK_CB(skb).pid,
+					MSG_DONTWAIT);
+		if (ret > 0)
+			ret = 0;
+
+		/* this avoids a loop in nfnetlink. */
+		return ret == -EAGAIN ? -ENOBUFS : ret;
+	}
+	return ret;
+}
+
+/* try to delete object, fail if it is still in use. */
+static int ctnl_timeout_try_del(struct ctnl_timeout *timeout)
+{
+	int ret = 0;
+
+	/* we want to avoid races with nf_ct_timeout_find_get. */
+	if (atomic_dec_and_test(&timeout->refcnt)) {
+		/* We are protected by nfnl mutex. */
+		list_del_rcu(&timeout->head);
+		kfree_rcu(timeout, rcu_head);
+	} else {
+		/* still in use, restore reference counter. */
+		atomic_inc(&timeout->refcnt);
+		ret = -EBUSY;
+	}
+	return ret;
+}
+
+static int
+cttimeout_del_timeout(struct sock *ctnl, struct sk_buff *skb,
+		      const struct nlmsghdr *nlh,
+		      const struct nlattr * const cda[])
+{
+	char *name;
+	struct ctnl_timeout *cur;
+	int ret = -ENOENT;
+
+	if (!cda[CTA_TIMEOUT_NAME]) {
+		list_for_each_entry(cur, &cttimeout_list, head)
+			ctnl_timeout_try_del(cur);
+
+		return 0;
+	}
+	name = nla_data(cda[CTA_TIMEOUT_NAME]);
+
+	list_for_each_entry(cur, &cttimeout_list, head) {
+		if (strncmp(cur->name, name, CTNL_TIMEOUT_NAME_MAX) != 0)
+			continue;
+
+		ret = ctnl_timeout_try_del(cur);
+		if (ret < 0)
+			return ret;
+
+		break;
+	}
+	return ret;
+}
+
+static const struct nfnl_callback cttimeout_cb[IPCTNL_MSG_TIMEOUT_MAX] = {
+	[IPCTNL_MSG_TIMEOUT_NEW]	= { .call = cttimeout_new_timeout,
+					    .attr_count = CTA_TIMEOUT_MAX,
+					    .policy = cttimeout_nla_policy },
+	[IPCTNL_MSG_TIMEOUT_GET]	= { .call = cttimeout_get_timeout,
+					    .attr_count = CTA_TIMEOUT_MAX,
+					    .policy = cttimeout_nla_policy },
+	[IPCTNL_MSG_TIMEOUT_DELETE]	= { .call = cttimeout_del_timeout,
+					    .attr_count = CTA_TIMEOUT_MAX,
+					    .policy = cttimeout_nla_policy },
+};
+
+static const struct nfnetlink_subsystem cttimeout_subsys = {
+	.name				= "conntrack_timeout",
+	.subsys_id			= NFNL_SUBSYS_CTNETLINK_TIMEOUT,
+	.cb_count			= IPCTNL_MSG_TIMEOUT_MAX,
+	.cb				= cttimeout_cb,
+};
+
+MODULE_ALIAS_NFNL_SUBSYS(NFNL_SUBSYS_CTNETLINK_TIMEOUT);
+
+static int __init cttimeout_init(void)
+{
+	int ret;
+
+	ret = nfnetlink_subsys_register(&cttimeout_subsys);
+	if (ret < 0) {
+		pr_err("cttimeout_init: cannot register cttimeout with "
+			"nfnetlink.\n");
+		goto err_out;
+	}
+	return 0;
+
+err_out:
+	return ret;
+}
+
+static void __exit cttimeout_exit(void)
+{
+	struct ctnl_timeout *cur, *tmp;
+
+	pr_info("cttimeout: unregistering from nfnetlink.\n");
+
+	nfnetlink_subsys_unregister(&cttimeout_subsys);
+	list_for_each_entry_safe(cur, tmp, &cttimeout_list, head) {
+		list_del_rcu(&cur->head);
+		/* We are sure that our objects have no clients at this point,
+		 * it's safe to release them all without checking refcnt.
+		 */
+		kfree_rcu(cur, rcu_head);
+	}
+}
+
+module_init(cttimeout_init);
+module_exit(cttimeout_exit);
-- 
1.7.7.3

