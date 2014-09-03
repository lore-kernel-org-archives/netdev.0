From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 13/13] switchdev: introduce Netlink API
Date: Wed,  3 Sep 2014 11:25:00 +0200
Message-ID: <1409736300-12303-14-git-send-email-jiri@resnulli.us>
References: <1409736300-12303-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@cumulusnetworks.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, dev@openvswitch.org, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org, alexei.starovoitov@gmail.com,
	Neil.Jerram@metaswitch.com, ronye@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:42855 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755748AbaICJZj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 05:25:39 -0400
Received: by mail-we0-f176.google.com with SMTP id q59so8237899wes.35
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2014 02:25:37 -0700 (PDT)
In-Reply-To: <1409736300-12303-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch exposes switchdev API using generic Netlink.
Example userspace utility is here:
https://github.com/jpirko/switchdev

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 MAINTAINERS                       |   1 +
 include/uapi/linux/switchdev.h    | 119 +++++++++
 net/switchdev/Kconfig             |  11 +
 net/switchdev/Makefile            |   1 +
 net/switchdev/switchdev_netlink.c | 493 ++++++++++++++++++++++++++++++++++++++
 5 files changed, 625 insertions(+)
 create mode 100644 include/uapi/linux/switchdev.h
 create mode 100644 net/switchdev/switchdev_netlink.c

diff --git a/MAINTAINERS b/MAINTAINERS
index 9797bda..83c4f43 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -8820,6 +8820,7 @@ L:	netdev@vger.kernel.org
 S:	Supported
 F:	net/switchdev/
 F:	include/net/switchdev.h
+F:	include/uapi/linux/switchdev.h
 
 SYNOPSYS ARC ARCHITECTURE
 M:	Vineet Gupta <vgupta@synopsys.com>
diff --git a/include/uapi/linux/switchdev.h b/include/uapi/linux/switchdev.h
new file mode 100644
index 0000000..83692e2
--- /dev/null
+++ b/include/uapi/linux/switchdev.h
@@ -0,0 +1,119 @@
+/*
+ * include/uapi/linux/switchdev.h - Netlink interface to Switch device
+ * Copyright (c) 2014 Jiri Pirko <jiri@resnulli.us>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef _UAPI_LINUX_SWITCHDEV_H_
+#define _UAPI_LINUX_SWITCHDEV_H_
+
+enum {
+	SWDEV_CMD_NOOP,
+	SWDEV_CMD_FLOW_INSERT,
+	SWDEV_CMD_FLOW_REMOVE,
+};
+
+enum {
+	SWDEV_ATTR_UNSPEC,
+	SWDEV_ATTR_IFINDEX,			/* u32 */
+	SWDEV_ATTR_FLOW,			/* nest */
+
+	__SWDEV_ATTR_MAX,
+	SWDEV_ATTR_MAX = (__SWDEV_ATTR_MAX - 1),
+};
+
+enum {
+	SWDEV_ATTR_FLOW_KEY_UNSPEC,
+	SWDEV_ATTR_FLOW_KEY_TUN_ID,		/* be64 */
+	SWDEV_ATTR_FLOW_KEY_TUN_IPV4_SRC,	/* be32 */
+	SWDEV_ATTR_FLOW_KEY_TUN_IPV4_DST,	/* be32 */
+	SWDEV_ATTR_FLOW_KEY_TUN_FLAGS,		/* be16 */
+	SWDEV_ATTR_FLOW_KEY_TUN_IPV4_TOS,	/* u8 */
+	SWDEV_ATTR_FLOW_KEY_TUN_IPV4_TTL,	/* u8 */
+	SWDEV_ATTR_FLOW_KEY_PHY_PRIORITY,	/* u32 */
+	SWDEV_ATTR_FLOW_KEY_PHY_IN_PORT,	/* u32 (ifindex) */
+	SWDEV_ATTR_FLOW_KEY_ETH_SRC,		/* ETH_ALEN */
+	SWDEV_ATTR_FLOW_KEY_ETH_DST,		/* ETH_ALEN */
+	SWDEV_ATTR_FLOW_KEY_ETH_TCI,		/* be16 */
+	SWDEV_ATTR_FLOW_KEY_ETH_TYPE,		/* be16 */
+	SWDEV_ATTR_FLOW_KEY_IP_PROTO,		/* u8 */
+	SWDEV_ATTR_FLOW_KEY_IP_TOS,		/* u8 */
+	SWDEV_ATTR_FLOW_KEY_IP_TTL,		/* u8 */
+	SWDEV_ATTR_FLOW_KEY_IP_FRAG,		/* u8 */
+	SWDEV_ATTR_FLOW_KEY_TP_SRC,		/* be16 */
+	SWDEV_ATTR_FLOW_KEY_TP_DST,		/* be16 */
+	SWDEV_ATTR_FLOW_KEY_TP_FLAGS,		/* be16 */
+	SWDEV_ATTR_FLOW_KEY_IPV4_ADDR_SRC,	/* be32 */
+	SWDEV_ATTR_FLOW_KEY_IPV4_ADDR_DST,	/* be32 */
+	SWDEV_ATTR_FLOW_KEY_IPV4_ARP_SHA,	/* ETH_ALEN */
+	SWDEV_ATTR_FLOW_KEY_IPV4_ARP_THA,	/* ETH_ALEN */
+	SWDEV_ATTR_FLOW_KEY_IPV6_ADDR_SRC,	/* struct in6_addr */
+	SWDEV_ATTR_FLOW_KEY_IPV6_ADDR_DST,	/* struct in6_addr */
+	SWDEV_ATTR_FLOW_KEY_IPV6_LABEL,		/* be32 */
+	SWDEV_ATTR_FLOW_KEY_IPV6_ND_TARGET,	/* struct in6_addr */
+	SWDEV_ATTR_FLOW_KEY_IPV6_ND_SLL,	/* ETH_ALEN */
+	SWDEV_ATTR_FLOW_KEY_IPV6_ND_TLL,	/* ETH_ALEN */
+
+	__SWDEV_ATTR_FLOW_KEY_MAX,
+	SWDEV_ATTR_FLOW_KEY_MAX = (__SWDEV_ATTR_FLOW_KEY_MAX - 1),
+};
+
+enum {
+	SWDEV_FLOW_ACTION_TYPE_OUTPUT,
+	SWDEV_FLOW_ACTION_TYPE_VLAN_PUSH,
+	SWDEV_FLOW_ACTION_TYPE_VLAN_POP,
+};
+
+enum {
+	SWDEV_ATTR_FLOW_ACTION_UNSPEC,
+	SWDEV_ATTR_FLOW_ACTION_TYPE,		/* u32 */
+	SWDEV_ATTR_FLOW_ACTION_OUT_PORT,	/* u32 (ifindex) */
+	SWDEV_ATTR_FLOW_ACTION_VLAN_PROTO,	/* be16 */
+	SWDEV_ATTR_FLOW_ACTION_VLAN_TCI,	/* u16 */
+
+	__SWDEV_ATTR_FLOW_ACTION_MAX,
+	SWDEV_ATTR_FLOW_ACTION_MAX = (__SWDEV_ATTR_FLOW_ACTION_MAX - 1),
+};
+
+enum {
+	SWDEV_ATTR_FLOW_ITEM_UNSPEC,
+	SWDEV_ATTR_FLOW_ITEM_ACTION,		/* nest */
+
+	__SWDEV_ATTR_FLOW_ITEM_MAX,
+	SWDEV_ATTR_FLOW_ITEM_MAX = (__SWDEV_ATTR_FLOW_ITEM_MAX - 1),
+};
+
+enum {
+	SWDEV_ATTR_FLOW_UNSPEC,
+	SWDEV_ATTR_FLOW_KEY,			/* nest */
+	SWDEV_ATTR_FLOW_MASK,			/* nest */
+	SWDEV_ATTR_FLOW_LIST_ACTION,		/* nest */
+
+	__SWDEV_ATTR_FLOW_MAX,
+	SWDEV_ATTR_FLOW_MAX = (__SWDEV_ATTR_FLOW_MAX - 1),
+};
+
+/* Nested layout of flow add/remove command message:
+ *
+ *	[SWDEV_ATTR_IFINDEX]
+ *	[SWDEV_ATTR_FLOW]
+ *		[SWDEV_ATTR_FLOW_KEY]
+ *			[SWDEV_ATTR_FLOW_KEY_*], ...
+ *		[SWDEV_ATTR_FLOW_MASK]
+ *			[SWDEV_ATTR_FLOW_KEY_*], ...
+ *		[SWDEV_ATTR_FLOW_LIST_ACTION]
+ *			[SWDEV_ATTR_FLOW_ITEM_ACTION]
+ *				[SWDEV_ATTR_FLOW_ACTION_*], ...
+ *			[SWDEV_ATTR_FLOW_ITEM_ACTION]
+ *				[SWDEV_ATTR_FLOW_ACTION_*], ...
+ *			...
+ */
+
+#define SWITCHDEV_GENL_NAME "switchdev"
+#define SWITCHDEV_GENL_VERSION 0x1
+
+#endif /* _UAPI_LINUX_SWITCHDEV_H_ */
diff --git a/net/switchdev/Kconfig b/net/switchdev/Kconfig
index 20e8ed2..4470d6e 100644
--- a/net/switchdev/Kconfig
+++ b/net/switchdev/Kconfig
@@ -7,3 +7,14 @@ config NET_SWITCHDEV
 	depends on INET
 	---help---
 	  This module provides support for hardware switch chips.
+
+config NET_SWITCHDEV_NETLINK
+	tristate "Netlink interface to Switch device"
+	depends on NET_SWITCHDEV
+	default m
+	---help---
+	  This module provides Generic Netlink intercace to hardware switch
+	  chips.
+
+	  To compile this code as a module, choose M here: the
+	  module will be called switchdev_netlink.
diff --git a/net/switchdev/Makefile b/net/switchdev/Makefile
index 5ed63ed..0695b53 100644
--- a/net/switchdev/Makefile
+++ b/net/switchdev/Makefile
@@ -3,3 +3,4 @@
 #
 
 obj-$(CONFIG_NET_SWITCHDEV) += switchdev.o
+obj-$(CONFIG_NET_SWITCHDEV_NETLINK) += switchdev_netlink.o
diff --git a/net/switchdev/switchdev_netlink.c b/net/switchdev/switchdev_netlink.c
new file mode 100644
index 0000000..14a3dd1
--- /dev/null
+++ b/net/switchdev/switchdev_netlink.c
@@ -0,0 +1,493 @@
+/*
+ * net/switchdev/switchdev_netlink.c - Netlink interface to Switch device
+ * Copyright (c) 2014 Jiri Pirko <jiri@resnulli.us>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <net/sw_flow.h>
+#include <net/switchdev.h>
+#include <net/netlink.h>
+#include <net/genetlink.h>
+#include <net/netlink.h>
+#include <uapi/linux/switchdev.h>
+
+static struct genl_family swdev_nl_family = {
+	.id		= GENL_ID_GENERATE,
+	.name		= SWITCHDEV_GENL_NAME,
+	.version	= SWITCHDEV_GENL_VERSION,
+	.maxattr	= SWDEV_ATTR_MAX,
+	.netnsok	= true,
+};
+
+static const struct nla_policy swdev_nl_flow_policy[SWDEV_ATTR_FLOW_MAX + 1] = {
+	[SWDEV_ATTR_FLOW_UNSPEC]		= { .type = NLA_UNSPEC, },
+	[SWDEV_ATTR_FLOW_KEY]			= { .type = NLA_NESTED },
+	[SWDEV_ATTR_FLOW_MASK]			= { .type = NLA_NESTED },
+	[SWDEV_ATTR_FLOW_LIST_ACTION]		= { .type = NLA_NESTED },
+};
+
+#define __IN6_ALEN sizeof(struct in6_addr)
+
+static const struct nla_policy
+swdev_nl_flow_key_policy[SWDEV_ATTR_FLOW_KEY_MAX + 1] = {
+	[SWDEV_ATTR_FLOW_KEY_UNSPEC]		= { .type = NLA_UNSPEC, },
+	[SWDEV_ATTR_FLOW_KEY_TUN_ID]		= { .type = NLA_U64, },
+	[SWDEV_ATTR_FLOW_KEY_TUN_IPV4_SRC]	= { .type = NLA_U32, },
+	[SWDEV_ATTR_FLOW_KEY_TUN_IPV4_DST]	= { .type = NLA_U32, },
+	[SWDEV_ATTR_FLOW_KEY_TUN_FLAGS]		= { .type = NLA_U16, },
+	[SWDEV_ATTR_FLOW_KEY_TUN_IPV4_TOS]	= { .type = NLA_U8, },
+	[SWDEV_ATTR_FLOW_KEY_TUN_IPV4_TTL]	= { .type = NLA_U8, },
+	[SWDEV_ATTR_FLOW_KEY_PHY_PRIORITY]	= { .type = NLA_U32, },
+	[SWDEV_ATTR_FLOW_KEY_PHY_IN_PORT]	= { .type = NLA_U32, },
+	[SWDEV_ATTR_FLOW_KEY_ETH_SRC]		= { .len  = ETH_ALEN, },
+	[SWDEV_ATTR_FLOW_KEY_ETH_DST]		= { .len  = ETH_ALEN, },
+	[SWDEV_ATTR_FLOW_KEY_ETH_TCI]		= { .type = NLA_U16, },
+	[SWDEV_ATTR_FLOW_KEY_ETH_TYPE]		= { .type = NLA_U16, },
+	[SWDEV_ATTR_FLOW_KEY_IP_PROTO]		= { .type = NLA_U8, },
+	[SWDEV_ATTR_FLOW_KEY_IP_TOS]		= { .type = NLA_U8, },
+	[SWDEV_ATTR_FLOW_KEY_IP_TTL]		= { .type = NLA_U8, },
+	[SWDEV_ATTR_FLOW_KEY_IP_FRAG]		= { .type = NLA_U8, },
+	[SWDEV_ATTR_FLOW_KEY_TP_SRC]		= { .type = NLA_U16, },
+	[SWDEV_ATTR_FLOW_KEY_TP_DST]		= { .type = NLA_U16, },
+	[SWDEV_ATTR_FLOW_KEY_TP_FLAGS]		= { .type = NLA_U16, },
+	[SWDEV_ATTR_FLOW_KEY_IPV4_ADDR_SRC]	= { .type = NLA_U32, },
+	[SWDEV_ATTR_FLOW_KEY_IPV4_ADDR_DST]	= { .type = NLA_U32, },
+	[SWDEV_ATTR_FLOW_KEY_IPV4_ARP_SHA]	= { .len  = ETH_ALEN, },
+	[SWDEV_ATTR_FLOW_KEY_IPV4_ARP_THA]	= { .len  = ETH_ALEN, },
+	[SWDEV_ATTR_FLOW_KEY_IPV6_ADDR_SRC]	= { .len  = __IN6_ALEN, },
+	[SWDEV_ATTR_FLOW_KEY_IPV6_ADDR_DST]	= { .len  = __IN6_ALEN, },
+	[SWDEV_ATTR_FLOW_KEY_IPV6_LABEL]	= { .type = NLA_U32, },
+	[SWDEV_ATTR_FLOW_KEY_IPV6_ND_TARGET]	= { .len  = __IN6_ALEN, },
+	[SWDEV_ATTR_FLOW_KEY_IPV6_ND_SLL]	= { .len  = ETH_ALEN },
+	[SWDEV_ATTR_FLOW_KEY_IPV6_ND_TLL]	= { .len  = ETH_ALEN },
+};
+
+static const struct nla_policy
+swdev_nl_flow_action_policy[SWDEV_ATTR_FLOW_ACTION_MAX + 1] = {
+	[SWDEV_ATTR_FLOW_ACTION_UNSPEC]		= { .type = NLA_UNSPEC, },
+	[SWDEV_ATTR_FLOW_ACTION_TYPE]		= { .type = NLA_U32, },
+	[SWDEV_ATTR_FLOW_ACTION_VLAN_PROTO]	= { .type = NLA_U16, },
+	[SWDEV_ATTR_FLOW_ACTION_VLAN_TCI]	= { .type = NLA_U16, },
+};
+
+static int swdev_nl_cmd_noop(struct sk_buff *skb, struct genl_info *info)
+{
+	struct sk_buff *msg;
+	void *hdr;
+	int err;
+
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!msg)
+		return -ENOMEM;
+
+	hdr = genlmsg_put(msg, info->snd_portid, info->snd_seq,
+			  &swdev_nl_family, 0, SWDEV_CMD_NOOP);
+	if (!hdr) {
+		err = -EMSGSIZE;
+		goto err_msg_put;
+	}
+
+	genlmsg_end(msg, hdr);
+
+	return genlmsg_unicast(genl_info_net(info), msg, info->snd_portid);
+
+err_msg_put:
+	nlmsg_free(msg);
+
+	return err;
+}
+
+static int swdev_nl_parse_flow_key(struct nlattr *key_attr,
+				   struct sw_flow_key *flow_key)
+{
+	struct nlattr *attrs[SWDEV_ATTR_FLOW_KEY_MAX + 1];
+	int err;
+
+	err = nla_parse_nested(attrs, SWDEV_ATTR_FLOW_KEY_MAX,
+			       key_attr, swdev_nl_flow_key_policy);
+	if (err)
+		return err;
+
+	if (attrs[SWDEV_ATTR_FLOW_KEY_TUN_ID])
+		flow_key->tun_key.tun_id =
+			nla_get_be64(attrs[SWDEV_ATTR_FLOW_KEY_TUN_ID]);
+
+	if (attrs[SWDEV_ATTR_FLOW_KEY_TUN_IPV4_SRC])
+		flow_key->tun_key.ipv4_src =
+			nla_get_be32(attrs[SWDEV_ATTR_FLOW_KEY_TUN_IPV4_SRC]);
+
+	if (attrs[SWDEV_ATTR_FLOW_KEY_TUN_IPV4_DST])
+		flow_key->tun_key.ipv4_dst =
+			nla_get_be32(attrs[SWDEV_ATTR_FLOW_KEY_TUN_IPV4_DST]);
+
+	if (attrs[SWDEV_ATTR_FLOW_KEY_TUN_FLAGS])
+		flow_key->tun_key.tun_flags =
+			nla_get_be16(attrs[SWDEV_ATTR_FLOW_KEY_TUN_FLAGS]);
+
+	if (attrs[SWDEV_ATTR_FLOW_KEY_TUN_IPV4_TOS])
+		flow_key->tun_key.ipv4_tos =
+			nla_get_u8(attrs[SWDEV_ATTR_FLOW_KEY_TUN_IPV4_TOS]);
+
+	if (attrs[SWDEV_ATTR_FLOW_KEY_TUN_IPV4_TTL])
+		flow_key->tun_key.ipv4_ttl =
+			nla_get_u8(attrs[SWDEV_ATTR_FLOW_KEY_TUN_IPV4_TTL]);
+
+	if (attrs[SWDEV_ATTR_FLOW_KEY_PHY_PRIORITY])
+		flow_key->phy.priority =
+			nla_get_u32(attrs[SWDEV_ATTR_FLOW_KEY_PHY_PRIORITY]);
+
+	if (attrs[SWDEV_ATTR_FLOW_KEY_PHY_IN_PORT])
+		flow_key->misc.in_port_ifindex =
+			nla_get_u32(attrs[SWDEV_ATTR_FLOW_KEY_PHY_IN_PORT]);
+
+	if (attrs[SWDEV_ATTR_FLOW_KEY_ETH_SRC])
+		ether_addr_copy(flow_key->eth.src,
+				nla_data(attrs[SWDEV_ATTR_FLOW_KEY_ETH_SRC]));
+
+	if (attrs[SWDEV_ATTR_FLOW_KEY_ETH_DST])
+		ether_addr_copy(flow_key->eth.dst,
+				nla_data(attrs[SWDEV_ATTR_FLOW_KEY_ETH_DST]));
+
+	if (attrs[SWDEV_ATTR_FLOW_KEY_ETH_TCI])
+		flow_key->eth.tci =
+			nla_get_be16(attrs[SWDEV_ATTR_FLOW_KEY_ETH_TCI]);
+
+	if (attrs[SWDEV_ATTR_FLOW_KEY_ETH_TYPE])
+		flow_key->eth.type =
+			nla_get_be16(attrs[SWDEV_ATTR_FLOW_KEY_ETH_TYPE]);
+
+	if (attrs[SWDEV_ATTR_FLOW_KEY_IP_PROTO])
+		flow_key->ip.proto =
+			nla_get_u8(attrs[SWDEV_ATTR_FLOW_KEY_IP_PROTO]);
+
+	if (attrs[SWDEV_ATTR_FLOW_KEY_IP_TOS])
+		flow_key->ip.tos =
+			nla_get_u8(attrs[SWDEV_ATTR_FLOW_KEY_IP_TOS]);
+
+	if (attrs[SWDEV_ATTR_FLOW_KEY_IP_TTL])
+		flow_key->ip.ttl =
+			nla_get_u8(attrs[SWDEV_ATTR_FLOW_KEY_IP_TTL]);
+
+	if (attrs[SWDEV_ATTR_FLOW_KEY_IP_FRAG])
+		flow_key->ip.frag =
+			nla_get_u8(attrs[SWDEV_ATTR_FLOW_KEY_IP_FRAG]);
+
+	if (attrs[SWDEV_ATTR_FLOW_KEY_TP_SRC])
+		flow_key->tp.src =
+			nla_get_be16(attrs[SWDEV_ATTR_FLOW_KEY_TP_SRC]);
+
+	if (attrs[SWDEV_ATTR_FLOW_KEY_TP_DST])
+		flow_key->tp.dst =
+			nla_get_be16(attrs[SWDEV_ATTR_FLOW_KEY_TP_DST]);
+
+	if (attrs[SWDEV_ATTR_FLOW_KEY_TP_FLAGS])
+		flow_key->tp.flags =
+			nla_get_be16(attrs[SWDEV_ATTR_FLOW_KEY_TP_FLAGS]);
+
+	if (attrs[SWDEV_ATTR_FLOW_KEY_IPV4_ADDR_SRC])
+		flow_key->ipv4.addr.src =
+			nla_get_be32(attrs[SWDEV_ATTR_FLOW_KEY_IPV4_ADDR_SRC]);
+
+	if (attrs[SWDEV_ATTR_FLOW_KEY_IPV4_ADDR_DST])
+		flow_key->ipv4.addr.dst =
+			nla_get_be32(attrs[SWDEV_ATTR_FLOW_KEY_IPV4_ADDR_DST]);
+
+	if (attrs[SWDEV_ATTR_FLOW_KEY_IPV4_ARP_SHA])
+		ether_addr_copy(flow_key->ipv4.arp.sha,
+				nla_data(attrs[SWDEV_ATTR_FLOW_KEY_IPV4_ARP_SHA]));
+
+	if (attrs[SWDEV_ATTR_FLOW_KEY_IPV4_ARP_THA])
+		ether_addr_copy(flow_key->ipv4.arp.tha,
+				nla_data(attrs[SWDEV_ATTR_FLOW_KEY_IPV4_ARP_THA]));
+
+	if (attrs[SWDEV_ATTR_FLOW_KEY_IPV6_ADDR_SRC])
+		memcpy(&flow_key->ipv6.addr.src,
+		       nla_data(attrs[SWDEV_ATTR_FLOW_KEY_IPV6_ADDR_SRC]),
+		       sizeof(flow_key->ipv6.addr.src));
+
+	if (attrs[SWDEV_ATTR_FLOW_KEY_IPV6_ADDR_DST])
+		memcpy(&flow_key->ipv6.addr.dst,
+		       nla_data(attrs[SWDEV_ATTR_FLOW_KEY_IPV6_ADDR_DST]),
+		       sizeof(flow_key->ipv6.addr.dst));
+
+	if (attrs[SWDEV_ATTR_FLOW_KEY_IPV6_LABEL])
+		flow_key->ipv6.label =
+			nla_get_be32(attrs[SWDEV_ATTR_FLOW_KEY_IPV6_LABEL]);
+
+	if (attrs[SWDEV_ATTR_FLOW_KEY_IPV6_ND_TARGET])
+		memcpy(&flow_key->ipv6.nd.target,
+		       nla_data(attrs[SWDEV_ATTR_FLOW_KEY_IPV6_ND_TARGET]),
+		       sizeof(flow_key->ipv6.nd.target));
+
+	if (attrs[SWDEV_ATTR_FLOW_KEY_IPV6_ND_SLL])
+		ether_addr_copy(flow_key->ipv6.nd.sll,
+				nla_data(attrs[SWDEV_ATTR_FLOW_KEY_IPV6_ND_SLL]));
+
+	if (attrs[SWDEV_ATTR_FLOW_KEY_IPV6_ND_TLL])
+		ether_addr_copy(flow_key->ipv6.nd.tll,
+				nla_data(attrs[SWDEV_ATTR_FLOW_KEY_IPV6_ND_TLL]));
+
+	return 0;
+}
+
+static int swdev_nl_parse_flow_mask(struct nlattr *mask_attr,
+				    struct sw_flow_mask **p_flow_mask)
+{
+	struct sw_flow_mask *flow_mask;
+	int err;
+
+	flow_mask = kzalloc(sizeof(*flow_mask), GFP_KERNEL);
+	if (!flow_mask)
+		return -ENOMEM;
+
+	err = swdev_nl_parse_flow_key(mask_attr, &flow_mask->key);
+	if (err)
+		goto out;
+	flow_mask->range.start = 0;
+	flow_mask->range.end = sizeof(flow_mask->key);
+
+	*p_flow_mask = flow_mask;
+	return 0;
+out:
+	kfree(flow_mask);
+	return err;
+}
+
+static int swdev_nl_parse_flow_action(struct nlattr *action_attr,
+				      struct sw_flow_action *flow_action)
+{
+	struct nlattr *attrs[SWDEV_ATTR_FLOW_ACTION_MAX + 1];
+	int err;
+
+	err = nla_parse_nested(attrs, SWDEV_ATTR_FLOW_ACTION_MAX,
+			       action_attr, swdev_nl_flow_action_policy);
+	if (err)
+		return err;
+
+	if (!attrs[SWDEV_ATTR_FLOW_ACTION_TYPE])
+		return -EINVAL;
+
+	switch (nla_get_u32(attrs[SWDEV_ATTR_FLOW_ACTION_TYPE])) {
+	case SWDEV_FLOW_ACTION_TYPE_OUTPUT:
+		if (!attrs[SWDEV_ATTR_FLOW_ACTION_OUT_PORT])
+			return -EINVAL;
+		flow_action->out_port_ifindex =
+			nla_get_u32(attrs[SWDEV_ATTR_FLOW_ACTION_OUT_PORT]);
+		flow_action->type = SW_FLOW_ACTION_TYPE_OUTPUT;
+		break;
+	case SWDEV_FLOW_ACTION_TYPE_VLAN_PUSH:
+		if (!attrs[SWDEV_ATTR_FLOW_ACTION_VLAN_PROTO] ||
+		    !attrs[SWDEV_ATTR_FLOW_ACTION_VLAN_TCI])
+			return -EINVAL;
+		flow_action->vlan.vlan_proto =
+			nla_get_be16(attrs[SWDEV_ATTR_FLOW_ACTION_VLAN_PROTO]);
+		flow_action->vlan.vlan_tci =
+			nla_get_u16(attrs[SWDEV_ATTR_FLOW_ACTION_VLAN_TCI]);
+		flow_action->type = SW_FLOW_ACTION_TYPE_VLAN_PUSH;
+		break;
+	case SWDEV_FLOW_ACTION_TYPE_VLAN_POP:
+		flow_action->type = SW_FLOW_ACTION_TYPE_VLAN_POP;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int swdev_nl_parse_flow_actions(struct nlattr *actions_attr,
+				       struct sw_flow_actions **p_flow_actions)
+{
+	struct sw_flow_actions *flow_actions;
+	struct sw_flow_action *cur;
+	struct nlattr *action_attr;
+	int rem;
+	int count = 0;
+	int err;
+
+	nla_for_each_nested(action_attr, actions_attr, rem) {
+		if (nla_type(action_attr) != SWDEV_ATTR_FLOW_ITEM_ACTION)
+			return -EINVAL;
+		count++;
+	}
+
+	flow_actions = kzalloc(sizeof(struct sw_flow_actions) +
+			       sizeof(struct sw_flow_action) * count,
+			       GFP_KERNEL);
+	if (!flow_actions)
+		return -ENOMEM;
+
+	cur = flow_actions->actions;
+	nla_for_each_nested(action_attr, actions_attr, rem) {
+		err = swdev_nl_parse_flow_action(action_attr, cur);
+		if (err)
+			goto out;
+		cur++;
+	}
+
+	flow_actions->count = count;
+	*p_flow_actions = flow_actions;
+	return 0;
+out:
+	kfree(flow_actions);
+	return err;
+}
+
+static void swdev_nl_free_flow(struct sw_flow *flow)
+{
+	kfree(flow->actions);
+	kfree(flow->mask);
+	kfree(flow);
+}
+
+static int swdev_nl_parse_flow(struct nlattr *flow_attr, struct sw_flow **p_flow)
+{
+	struct sw_flow *flow;
+	struct nlattr *attrs[SWDEV_ATTR_FLOW_MAX + 1];
+	int err;
+
+	err = nla_parse_nested(attrs, SWDEV_ATTR_FLOW_MAX,
+			       flow_attr, swdev_nl_flow_policy);
+	if (err)
+		return err;
+
+	if (!attrs[SWDEV_ATTR_FLOW_KEY] || !attrs[SWDEV_ATTR_FLOW_MASK] ||
+	    !attrs[SWDEV_ATTR_FLOW_LIST_ACTION])
+		return -EINVAL;
+
+	flow = kzalloc(sizeof(*flow), GFP_KERNEL);
+	if (!flow)
+		return -ENOMEM;
+
+	err = swdev_nl_parse_flow_key(attrs[SWDEV_ATTR_FLOW_KEY], &flow->key);
+	if (err)
+		goto out;
+
+	err = swdev_nl_parse_flow_mask(attrs[SWDEV_ATTR_FLOW_MASK], &flow->mask);
+	if (err)
+		goto out;
+
+	err = swdev_nl_parse_flow_actions(attrs[SWDEV_ATTR_FLOW_LIST_ACTION],
+					  &flow->actions);
+	if (err)
+		goto out;
+
+	*p_flow = flow;
+	return 0;
+
+out:
+	kfree(flow);
+	return err;
+}
+
+static struct net_device *swdev_nl_dev_get(struct genl_info *info)
+{
+	struct net *net = genl_info_net(info);
+	int ifindex;
+
+	if (!info->attrs[SWDEV_ATTR_IFINDEX])
+		return NULL;
+
+	ifindex = nla_get_u32(info->attrs[SWDEV_ATTR_IFINDEX]);
+	return dev_get_by_index(net, ifindex);
+}
+
+static void swdev_nl_dev_put(struct net_device *dev)
+{
+	dev_put(dev);
+}
+
+static int swdev_nl_cmd_flow_insert(struct sk_buff *skb, struct genl_info *info)
+{
+	struct net_device *dev;
+	struct sw_flow *flow;
+	int err;
+
+	if (!info->attrs[SWDEV_ATTR_FLOW])
+		return -EINVAL;
+
+	dev = swdev_nl_dev_get(info);
+	if (!dev)
+		return -EINVAL;
+
+	err = swdev_nl_parse_flow(info->attrs[SWDEV_ATTR_FLOW], &flow);
+	if (err)
+		goto dev_put;
+
+	err = swdev_flow_insert(dev, flow);
+	swdev_nl_free_flow(flow);
+dev_put:
+	swdev_nl_dev_put(dev);
+	return err;
+}
+
+static int swdev_nl_cmd_flow_remove(struct sk_buff *skb, struct genl_info *info)
+{
+	struct net_device *dev;
+	struct sw_flow *flow;
+	int err;
+
+	if (!info->attrs[SWDEV_ATTR_FLOW])
+		return -EINVAL;
+
+	dev = swdev_nl_dev_get(info);
+	if (!dev)
+		return -EINVAL;
+
+	err = swdev_nl_parse_flow(info->attrs[SWDEV_ATTR_FLOW], &flow);
+	if (err)
+		goto dev_put;
+
+	err = swdev_flow_remove(dev, flow);
+	swdev_nl_free_flow(flow);
+dev_put:
+	swdev_nl_dev_put(dev);
+	return err;
+}
+
+static const struct genl_ops swdev_nl_ops[] = {
+	{
+		.cmd = SWDEV_CMD_NOOP,
+		.doit = swdev_nl_cmd_noop,
+	},
+	{
+		.cmd = SWDEV_CMD_FLOW_INSERT,
+		.doit = swdev_nl_cmd_flow_insert,
+		.policy = swdev_nl_flow_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
+	{
+		.cmd = SWDEV_CMD_FLOW_REMOVE,
+		.doit = swdev_nl_cmd_flow_remove,
+		.policy = swdev_nl_flow_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
+};
+
+static int __init swdev_nl_module_init(void)
+{
+	return genl_register_family_with_ops(&swdev_nl_family, swdev_nl_ops);
+}
+
+static void swdev_nl_module_fini(void)
+{
+	genl_unregister_family(&swdev_nl_family);
+}
+
+module_init(swdev_nl_module_init);
+module_exit(swdev_nl_module_fini);
+
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Jiri Pirko <jiri@resnulli.us>");
+MODULE_DESCRIPTION("Netlink interface to Switch device");
+MODULE_ALIAS_GENL_FAMILY(SWITCHDEV_GENL_NAME);
-- 
1.9.3
