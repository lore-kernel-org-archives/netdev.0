From: Stephen Hemminger <shemminger@osdl.org>
Subject: [patch 3/3] bridge: netlink interface for link management
Date: Wed, 24 May 2006 10:12:19 -0700
Message-ID: <20060524171348.001557000@localhost.localdomain>
References: <20060524171216.706750000@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:50103 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932416AbWEXRPU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 May 2006 13:15:20 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline; filename=bridge-netlink.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add basic netlink support to the Ethernet bridge. Including:
 * dump interfaces in bridges
 * monitor link status changes
 * change state of bridge port

For some demo programs see:
	http://developer.osdl.org/shemminger/prototypes/brnl.tar.gz

These are to allow building a daemon that does alternative implementations
of Spanning Tree Protocol.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- br.orig/net/bridge/Makefile
+++ br/net/bridge/Makefile
@@ -6,7 +6,7 @@ obj-$(CONFIG_BRIDGE) += bridge.o
 
 bridge-y	:= br.o br_device.o br_fdb.o br_forward.o br_if.o br_input.o \
 			br_ioctl.o br_notify.o br_stp.o br_stp_bpdu.o \
-			br_stp_if.o br_stp_timer.o
+			br_stp_if.o br_stp_timer.o br_netlink.o
 
 bridge-$(CONFIG_SYSFS) += br_sysfs_if.o br_sysfs_br.o
 
--- /dev/null
+++ br/net/bridge/br_netlink.c
@@ -0,0 +1,199 @@
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
+/*
+ * Create one netlink message for one interface
+ * Contains port and master info as well as carrier and bridge state.
+ */
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
+	u8 portstate = port->state;
+
+	pr_debug("br_fill_info event %d port %s master %s\n",
+		 event, dev->name, br->dev->name);
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
+	if (event == RTM_NEWLINK)
+		RTA_PUT(skb, IFLA_PROTINFO, sizeof(portstate), &portstate);
+
+	nlh->nlmsg_len = skb->tail - b;
+
+	return skb->len;
+
+nlmsg_failure:
+rtattr_failure:
+
+	skb_trim(skb, b - skb->data);
+	return -EINVAL;
+}
+
+/*
+ * Notify listeners of a change in port information
+ */
+void br_ifinfo_notify(int event, struct net_bridge_port *port)
+{
+	struct sk_buff *skb;
+	int err = -ENOMEM;
+
+	pr_debug("bridge notify event=%d\n", event);
+	skb = alloc_skb(NLMSG_SPACE(sizeof(struct ifinfomsg) + 128),
+			GFP_ATOMIC);
+	if (!skb)
+		goto err_out;
+
+	err = br_fill_ifinfo(skb, port, current->pid, 0, event, 0);
+	if (err)
+		goto err_kfree;
+
+	NETLINK_CB(skb).dst_group = RTNLGRP_LINK;
+	netlink_broadcast(rtnl, skb, 0, RTNLGRP_LINK, GFP_ATOMIC);
+	return;
+
+err_kfree:
+	kfree_skb(skb);
+err_out:
+	netlink_set_err(rtnl, 0, RTNLGRP_LINK, err);
+}
+
+/*
+ * Dump information about all ports, in response to GETLINK
+ */
+static int br_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct net_device *dev;
+	int idx;
+	int s_idx = cb->args[0];
+	int err = 0;
+
+	read_lock(&dev_base_lock);
+	for (dev = dev_base, idx = 0; dev; dev = dev->next) {
+		struct net_bridge_port *p = dev->br_port;
+
+		/* not a bridge port */
+		if (!p)
+			continue;
+
+		if (idx < s_idx)
+			continue;
+
+		err = br_fill_ifinfo(skb, p, NETLINK_CB(cb->skb).pid,
+				     cb->nlh->nlmsg_seq, RTM_NEWLINK, NLM_F_MULTI);
+		if (err <= 0)
+			break;
+		++idx;
+	}
+	read_unlock(&dev_base_lock);
+
+	cb->args[0] = idx;
+
+	return skb->len;
+}
+
+/*
+ * Change state of port (ie from forwarding to blocking etc)
+ * Used by spanning tree in user space.
+ */
+static int br_rtm_setlink(struct sk_buff *skb,  struct nlmsghdr *nlh, void *arg)
+{
+	struct rtattr  **rta = arg;
+	struct ifinfomsg *ifm = NLMSG_DATA(nlh);
+	struct net_device *dev;
+	struct net_bridge_port *p;
+	u8 new_state;
+
+	if (ifm->ifi_family != AF_BRIDGE)
+		return -EPFNOSUPPORT;
+
+	/* Must pass valid state as PROTINFO */
+	if (rta[IFLA_PROTINFO-1]) {
+		u8 *pstate = RTA_DATA(rta[IFLA_PROTINFO-1]);
+		new_state = *pstate;
+	} else
+		return -EINVAL;
+
+	if (new_state > BR_STATE_BLOCKING)
+		return -EINVAL;
+
+	/* Find bridge port */
+	dev = __dev_get_by_index(ifm->ifi_index);
+	if (!dev)
+		return -ENODEV;
+
+	p = dev->br_port;
+	if (!p)
+		return -EINVAL;
+
+	/* if kernel STP is running, don't allow changes */
+	if (p->br->stp_enabled)
+		return -EBUSY;
+
+	if (!netif_running(dev))
+		return -ENETDOWN;
+
+	if (!netif_carrier_ok(dev) && new_state != BR_STATE_DISABLED)
+		return -ENETDOWN;
+
+	p->state = new_state;
+	br_log_state(p);
+	return 0;
+}
+
+
+static struct rtnetlink_link bridge_rtnetlink_table[RTM_NR_MSGTYPES] = {
+	[RTM_GETLINK - RTM_BASE] = { .dumpit	= br_dump_ifinfo, },
+	[RTM_SETLINK - RTM_BASE] = { .doit      = br_rtm_setlink, },
+};
+
+void __init br_netlink_init(void)
+{
+	rtnetlink_links[PF_BRIDGE] = bridge_rtnetlink_table;
+}
+
+void __exit br_netlink_fini(void)
+{
+	rtnetlink_links[PF_BRIDGE] = NULL;
+}
+
--- br.orig/net/bridge/br_private.h
+++ br/net/bridge/br_private.h
@@ -29,7 +29,7 @@
 
 #define BR_PORT_DEBOUNCE (HZ/10)
 
-#define BR_VERSION	"2.1"
+#define BR_VERSION	"2.2"
 
 typedef struct bridge_id bridge_id;
 typedef struct mac_addr mac_addr;
@@ -237,6 +237,11 @@ extern struct net_bridge_fdb_entry *(*br
 extern void (*br_fdb_put_hook)(struct net_bridge_fdb_entry *ent);
 
 
+/* br_netlink.c */
+extern void br_netlink_init(void);
+extern void br_netlink_fini(void);
+extern void br_ifinfo_notify(int event, struct net_bridge_port *port);
+
 #ifdef CONFIG_SYSFS
 /* br_sysfs_if.c */
 extern struct sysfs_ops brport_sysfs_ops;
--- br.orig/net/bridge/br_notify.c
+++ br/net/bridge/br_notify.c
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
 
--- br.orig/net/bridge/br_stp_if.c
+++ br/net/bridge/br_stp_if.c
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
--- br.orig/net/bridge/br.c
+++ br/net/bridge/br.c
@@ -48,6 +48,7 @@ static int __init br_init(void)
 	if (err)
 		goto err_out2;
 
+	br_netlink_init();
 	brioctl_set(br_ioctl_deviceless_stub);
 	br_handle_frame_hook = br_handle_frame;
 
@@ -67,6 +68,7 @@ static void __exit br_deinit(void)
 {
 	rcu_assign_pointer(br_stp_sap->rcv_func, NULL);
 
+	br_netlink_fini();
 	br_netfilter_fini();
 	unregister_netdevice_notifier(&br_device_notifier);
 	brioctl_set(NULL);

--

