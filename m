From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFC] bridge: partial rtnetlink hooks
Date: Wed, 26 Apr 2006 10:45:21 -0700
Message-ID: <20060426104521.44682924@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:40365 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964775AbWDZRpW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2006 13:45:22 -0400
Received: from shell0.pdx.osdl.net (fw.osdl.org [65.172.181.6])
	by smtp.osdl.org (8.12.8/8.12.8) with ESMTP id k3QHjKtH002927
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 26 Apr 2006 10:45:21 -0700
Received: from localhost.localdomain (freekitty.pdx.osdl.net [10.8.0.54])
	by shell0.pdx.osdl.net (8.13.1/8.11.6) with ESMTP id k3QHjKmg002106
	for <netdev@vger.kernel.org>; Wed, 26 Apr 2006 10:45:20 -0700
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is the start of adding support for rtnetlink to the bridge code.
So far it only supports accessing the list of links and notifying
about link changes. It is just a prototype to get early feedback, don't
use to build your own masterpiece yet.

--- bridge-2.6.orig/net/bridge/Makefile
+++ bridge-2.6/net/bridge/Makefile
@@ -6,7 +6,7 @@ obj-$(CONFIG_BRIDGE) += bridge.o
 
 bridge-y	:= br.o br_device.o br_fdb.o br_forward.o br_if.o br_input.o \
 			br_ioctl.o br_notify.o br_stp.o br_stp_bpdu.o \
-			br_stp_if.o br_stp_timer.o
+			br_stp_if.o br_stp_timer.o br_netlink.o
 
 bridge-$(CONFIG_SYSFS) += br_sysfs_if.o br_sysfs_br.o
 
--- bridge-2.6.orig/net/bridge/br.c
+++ bridge-2.6/net/bridge/br.c
@@ -30,17 +30,20 @@ static struct llc_sap *br_stp_sap;
 
 static int __init br_init(void)
 {
+	int err = -EADDRINUSE;
+
 	br_stp_sap = llc_sap_open(LLC_SAP_BSPAN, br_stp_rcv);
 	if (!br_stp_sap) {
 		printk(KERN_ERR "bridge: can't register sap for STP\n");
-		return -EBUSY;
+		goto out;
 	}
 
 	br_fdb_init();
 
 #ifdef CONFIG_BRIDGE_NETFILTER
-	if (br_netfilter_init())
-		return 1;
+	err = br_netfilter_init();
+	if (err)
+		goto unregister_sap;
 #endif
 	brioctl_set(br_ioctl_deviceless_stub);
 	br_handle_frame_hook = br_handle_frame;
@@ -50,13 +53,23 @@ static int __init br_init(void)
 
 	register_netdevice_notifier(&br_device_notifier);
 
+	br_netlink_init();
+
 	return 0;
+#ifdef CONFIG_BRIDGE_NETFILTER
+ unregister_sap:
+	llc_sap_close(br_stp_sap);
+#endif
+ out:
+	return err;
 }
 
 static void __exit br_deinit(void)
 {
 	llc_sap_close(br_stp_sap);
 
+	br_netlink_exit();
+
 #ifdef CONFIG_BRIDGE_NETFILTER
 	br_netfilter_fini();
 #endif
--- /dev/null
+++ bridge-2.6/net/bridge/br_netlink.c
@@ -0,0 +1,135 @@
+/*
+ *	Bridge netlink control interface
+ *
+ *	Authors:
+ *	Stephen Hemminger		<shemminger@osdl.org>
+ *
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License
+ *	as published by the Free Software Foundation; either version
+ *	2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/kernel.h>
+#include <linux/rtnetlink.h>
+#include "br_private.h"
+
+static int br_fill_ifinfo(struct sk_buff *skb, const struct net_bridge_port *port,
+			  u32 pid, u32 seq, int event, unsigned int flags)
+{
+	const struct net_bridge *br = port->br;
+	const struct net_device *dev = port->dev;
+	struct ifinfomsg *r;
+	struct nlmsghdr *nlh;
+	unsigned char *b = skb->tail;
+	u32 mtu = dev->mtu;
+	u8 operstate = netif_running(dev) ? dev->operstate : IF_OPER_DOWN;
+
+	printk(KERN_DEBUG "bridge fill %s %s\n", dev->name, br->dev->name);
+
+	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*r), flags);
+	r = NLMSG_DATA(nlh);
+	r->ifi_family = AF_BRIDGE;
+	r->__ifi_pad = 0;
+	r->ifi_type = dev->type;
+	r->ifi_index = dev->ifindex;
+	r->ifi_flags = dev_get_flags(dev);
+	r->ifi_change = 0;
+
+	RTA_PUT(skb, IFLA_IFNAME, strlen(dev->name)+1, dev->name);
+
+	RTA_PUT(skb, IFLA_MASTER, sizeof(int), &br->dev->ifindex);
+
+	if (dev->addr_len)
+		RTA_PUT(skb, IFLA_ADDRESS, dev->addr_len, dev->dev_addr);
+
+	RTA_PUT(skb, IFLA_MTU, sizeof(mtu), &mtu);
+	if (dev->ifindex != dev->iflink)
+		RTA_PUT(skb, IFLA_LINK, sizeof(int), &dev->iflink);
+
+
+	RTA_PUT(skb, IFLA_OPERSTATE, sizeof(operstate), &operstate);
+
+	if (event == RTM_NEWLINK) {
+		struct brifinfo portstate = {
+			.state = port->state,
+			.cost  = port->path_cost,
+		};
+		RTA_PUT(skb, IFLA_PROTINFO, sizeof(portstate), &portstate);
+	}
+
+	nlh->nlmsg_len = skb->tail - b;
+
+	return skb->len;
+
+nlmsg_failure:
+rtattr_failure:
+
+	skb_trim(skb, b - skb->data);
+	return -1;
+}
+
+
+void br_ifinfo_notify(int event, struct net_bridge_port *port)
+{
+	struct sk_buff *skb;
+
+	printk(KERN_DEBUG "bridge notify event=%d\n", event);
+	skb = alloc_skb(NLMSG_SPACE(sizeof(struct ifinfomsg) + 128),
+			GFP_ATOMIC);
+	if (!skb) {
+		netlink_set_err(rtnl, 0, RTNLGRP_BRIDGE_IFINFO, ENOBUFS);
+		return;
+	}
+	if (br_fill_ifinfo(skb, port, current->pid, 0, event, 0) < 0) {
+		kfree_skb(skb);
+		netlink_set_err(rtnl, 0, RTNLGRP_BRIDGE_IFINFO, EINVAL);
+		return;
+	}
+	NETLINK_CB(skb).dst_group = RTNLGRP_IPV6_IFINFO;
+	netlink_broadcast(rtnl, skb, 0, RTNLGRP_BRIDGE_IFINFO, GFP_ATOMIC);
+}
+
+static int br_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct net_device *dev;
+	int idx = 0;
+	int err = 0;
+
+	printk(KERN_DEBUG "bridge dump ifinfo\n");
+	for (dev = dev_base; dev; dev = dev->next) {
+		struct net_bridge_port *p = rcu_dereference(dev->br_port);
+
+		/* not a bridge port */
+		if (!p)
+			continue;
+		/* asking about a specific bridge */
+		if (cb->args[1] && cb->args[1] != p->br->dev->ifindex)
+			continue;
+
+		/* limit to N values */
+		if (idx >= cb->args[0])
+			break;
+		err = br_fill_ifinfo(skb, p, NETLINK_CB(cb->skb).pid,
+				     cb->nlh->nlmsg_seq, RTM_NEWLINK, NLM_F_MULTI);
+		if (err <= 0)
+			break;
+		++idx;
+	}
+	cb->args[0] = idx;
+	return err;
+}
+
+static struct rtnetlink_link bridge_rtnetlink_table[RTM_NR_MSGTYPES] = {
+	[RTM_GETLINK - RTM_BASE] = { .dumpit	= br_dump_ifinfo, },
+};
+
+void __init br_netlink_init(void)
+{
+	rtnetlink_links[PF_BRIDGE] = bridge_rtnetlink_table;
+}
+
+void __exit br_netlink_exit(void)
+{
+	rtnetlink_links[PF_BRIDGE] = NULL;
+}
--- bridge-2.6.orig/net/bridge/br_private.h
+++ bridge-2.6/net/bridge/br_private.h
@@ -29,7 +29,7 @@
 
 #define BR_PORT_DEBOUNCE (HZ/10)
 
-#define BR_VERSION	"2.1"
+#define BR_VERSION	"2.2"
 
 typedef struct bridge_id bridge_id;
 typedef struct mac_addr mac_addr;
@@ -232,6 +232,11 @@ extern struct net_bridge_fdb_entry *(*br
 extern void (*br_fdb_put_hook)(struct net_bridge_fdb_entry *ent);
 
 
+/* br_netlink.c */
+extern void br_netlink_init(void);
+extern void br_netlink_exit(void);
+extern void br_ifinfo_notify(int event, struct net_bridge_port *port);
+
 #ifdef CONFIG_SYSFS
 /* br_sysfs_if.c */
 extern struct sysfs_ops brport_sysfs_ops;
--- bridge-2.6.orig/include/linux/rtnetlink.h
+++ bridge-2.6/include/linux/rtnetlink.h
@@ -200,6 +200,7 @@ enum
 #define RTPROT_DNROUTED	13	/* DECnet routing daemon */
 #define RTPROT_XORP	14	/* XORP */
 #define RTPROT_NTK	15	/* Netsukuku */
+#define RTPROT_STP	16	/* Bridge Spanning Tree Protocol */
 
 /* rtm_scope
 
@@ -850,6 +851,7 @@ enum
 #define RTMGRP_DECnet_ROUTE     0x4000
 
 #define RTMGRP_IPV6_PREFIX	0x20000
+
 #endif
 
 /* RTnetlink multicast groups */
@@ -889,6 +891,10 @@ enum rtnetlink_groups {
 	RTNLGRP_NOP4,
 	RTNLGRP_IPV6_PREFIX,
 #define RTNLGRP_IPV6_PREFIX	RTNLGRP_IPV6_PREFIX
+	RTNLGRP_BRIDGE_IFINFO,
+#define RTNLGRP_BRIDGE_IFINFO	RTNLGRP_BRIDGE_IFINFO
+	RTNLGRP_BRIDGE_FDB,
+#define RTNLGRP_BRIDGE_FDB	RTNLGRP_BRIDGE_FDB
 	__RTNLGRP_MAX
 };
 #define RTNLGRP_MAX	(__RTNLGRP_MAX - 1)
--- bridge-2.6.orig/include/linux/if_bridge.h
+++ bridge-2.6/include/linux/if_bridge.h
@@ -100,6 +100,11 @@ struct __fdb_entry
 	__u32 unused;
 };
 
+struct brifinfo {
+	__u8	state;
+	__u32	cost;
+};
+
 #ifdef __KERNEL__
 
 #include <linux/netdevice.h>
--- bridge-2.6.orig/net/bridge/br_notify.c
+++ bridge-2.6/net/bridge/br_notify.c
@@ -14,6 +14,7 @@
  */
 
 #include <linux/kernel.h>
+#include <linux/rtnetlink.h>
 
 #include "br_private.h"
 
@@ -49,6 +50,7 @@ static int br_device_event(struct notifi
 
 	case NETDEV_CHANGEADDR:
 		br_fdb_changeaddr(p, dev->dev_addr);
+		br_ifinfo_notify(RTM_NEWLINK, p);
 		br_stp_recalculate_bridge_id(br);
 		break;
 
--- bridge-2.6.orig/net/bridge/br_stp_if.c
+++ bridge-2.6/net/bridge/br_stp_if.c
@@ -16,6 +16,7 @@
 #include <linux/kernel.h>
 #include <linux/smp_lock.h>
 #include <linux/etherdevice.h>
+#include <linux/rtnetlink.h>
 
 #include "br_private.h"
 #include "br_private_stp.h"
@@ -86,6 +87,7 @@ void br_stp_disable_bridge(struct net_br
 void br_stp_enable_port(struct net_bridge_port *p)
 {
 	br_init_port(p);
+	br_ifinfo_notify(RTM_NEWLINK, p);
 	br_port_state_selection(p->br);
 }
 
@@ -99,6 +101,8 @@ void br_stp_disable_port(struct net_brid
 	printk(KERN_INFO "%s: port %i(%s) entering %s state\n",
 	       br->dev->name, p->port_no, p->dev->name, "disabled");
 
+	br_ifinfo_notify(RTM_DELLINK, p);
+
 	wasroot = br_is_root_bridge(br);
 	br_become_designated_port(p);
 	p->state = BR_STATE_DISABLED;
