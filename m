From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next] net: bridge: add notifications for the bridge dev on vlan change
Date: Wed,  1 Nov 2017 12:18:13 +0200
Message-ID: <1509531493-17909-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
        bridge@lists.linux-foundation.org, stephen@networkplumber.org,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:45068 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750729AbdKAKSV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 06:18:21 -0400
Received: by mail-wr0-f193.google.com with SMTP id y9so1517455wrb.2
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 03:18:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the bridge device doesn't generate any notifications upon vlan
modifications on itself because it doesn't use the generic bridge
notifications.
With the recent changes we know if anything was modified in the vlan config
thus we can generate a notification when necessary for the bridge device
so add support to br_ifinfo_notify() similar to how other combined
functions are done - if port is present it takes precedence, otherwise
notify about the bridge. I've explicitly marked the locations where the
notification should be always for the port by setting bridge to NULL.
I've also taken the liberty to rearrange each modified function's local
variables in reverse xmas tree as well.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
There is still one case where a notification is not generated - when using
the vlan flag BRIDGE_VLAN_INFO_MASTER (currently unsupported by iproute2).
I will deal with that in a separate patch.

 net/bridge/br.c           |  2 +-
 net/bridge/br_if.c        |  4 ++--
 net/bridge/br_ioctl.c     |  2 +-
 net/bridge/br_netlink.c   | 58 ++++++++++++++++++++++++++---------------------
 net/bridge/br_private.h   |  3 ++-
 net/bridge/br_stp.c       |  6 ++---
 net/bridge/br_stp_if.c    |  4 ++--
 net/bridge/br_stp_timer.c |  2 +-
 net/bridge/br_sysfs_if.c  |  2 +-
 9 files changed, 45 insertions(+), 38 deletions(-)

diff --git a/net/bridge/br.c b/net/bridge/br.c
index 1407d1ba7577..6bf06e756df2 100644
--- a/net/bridge/br.c
+++ b/net/bridge/br.c
@@ -112,7 +112,7 @@ static int br_device_event(struct notifier_block *unused, unsigned long event, v
 	/* Events that may cause spanning tree to refresh */
 	if (event == NETDEV_CHANGEADDR || event == NETDEV_UP ||
 	    event == NETDEV_CHANGE || event == NETDEV_DOWN)
-		br_ifinfo_notify(RTM_NEWLINK, p);
+		br_ifinfo_notify(RTM_NEWLINK, NULL, p);
 
 	return NOTIFY_DONE;
 }
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index ae38547bbf91..9ba4ed65c52b 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -271,7 +271,7 @@ static void del_nbp(struct net_bridge_port *p)
 	br_stp_disable_port(p);
 	spin_unlock_bh(&br->lock);
 
-	br_ifinfo_notify(RTM_DELLINK, p);
+	br_ifinfo_notify(RTM_DELLINK, NULL, p);
 
 	list_del_rcu(&p->list);
 	if (netdev_get_fwd_headroom(dev) == br->dev->needed_headroom)
@@ -589,7 +589,7 @@ int br_add_if(struct net_bridge *br, struct net_device *dev,
 		br_stp_enable_port(p);
 	spin_unlock_bh(&br->lock);
 
-	br_ifinfo_notify(RTM_NEWLINK, p);
+	br_ifinfo_notify(RTM_NEWLINK, NULL, p);
 
 	if (changed_addr)
 		call_netdevice_notifiers(NETDEV_CHANGEADDR, br->dev);
diff --git a/net/bridge/br_ioctl.c b/net/bridge/br_ioctl.c
index 16d01a3ff33f..73b957fd639d 100644
--- a/net/bridge/br_ioctl.c
+++ b/net/bridge/br_ioctl.c
@@ -293,7 +293,7 @@ static int old_dev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 
 	if (!ret) {
 		if (p)
-			br_ifinfo_notify(RTM_NEWLINK, p);
+			br_ifinfo_notify(RTM_NEWLINK, NULL, p);
 		else
 			netdev_state_change(br->dev);
 	}
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index e732403669c6..f96548ba99d3 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -361,14 +361,14 @@ static int br_fill_ifvlaninfo(struct sk_buff *skb,
  * Contains port and master info as well as carrier and bridge state.
  */
 static int br_fill_ifinfo(struct sk_buff *skb,
-			  struct net_bridge_port *port,
+			  const struct net_bridge_port *port,
 			  u32 pid, u32 seq, int event, unsigned int flags,
 			  u32 filter_mask, const struct net_device *dev)
 {
+	u8 operstate = netif_running(dev) ? dev->operstate : IF_OPER_DOWN;
 	struct net_bridge *br;
 	struct ifinfomsg *hdr;
 	struct nlmsghdr *nlh;
-	u8 operstate = netif_running(dev) ? dev->operstate : IF_OPER_DOWN;
 
 	if (port)
 		br = port->br;
@@ -454,28 +454,36 @@ static int br_fill_ifinfo(struct sk_buff *skb,
 	return -EMSGSIZE;
 }
 
-/*
- * Notify listeners of a change in port information
- */
-void br_ifinfo_notify(int event, struct net_bridge_port *port)
+/* Notify listeners of a change in bridge or port information */
+void br_ifinfo_notify(int event, const struct net_bridge *br,
+		      const struct net_bridge_port *port)
 {
-	struct net *net;
+	u32 filter = RTEXT_FILTER_BRVLAN_COMPRESSED;
+	struct net_device *dev;
 	struct sk_buff *skb;
 	int err = -ENOBUFS;
-	u32 filter = RTEXT_FILTER_BRVLAN_COMPRESSED;
+	struct net *net;
+	u16 port_no = 0;
 
-	if (!port)
+	if (WARN_ON(!port && !br))
 		return;
 
-	net = dev_net(port->dev);
-	br_debug(port->br, "port %u(%s) event %d\n",
-		 (unsigned int)port->port_no, port->dev->name, event);
+	if (port) {
+		dev = port->dev;
+		br = port->br;
+		port_no = port->port_no;
+	} else {
+		dev = br->dev;
+	}
+
+	net = dev_net(dev);
+	br_debug(br, "port %u(%s) event %d\n", port_no, dev->name, event);
 
-	skb = nlmsg_new(br_nlmsg_size(port->dev, filter), GFP_ATOMIC);
+	skb = nlmsg_new(br_nlmsg_size(dev, filter), GFP_ATOMIC);
 	if (skb == NULL)
 		goto errout;
 
-	err = br_fill_ifinfo(skb, port, 0, 0, event, 0, filter, port->dev);
+	err = br_fill_ifinfo(skb, port, 0, 0, event, 0, filter, dev);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in br_nlmsg_size() */
 		WARN_ON(err == -EMSGSIZE);
@@ -488,7 +496,6 @@ void br_ifinfo_notify(int event, struct net_bridge_port *port)
 	rtnl_set_sk_err(net, RTNLGRP_LINK, err);
 }
 
-
 /*
  * Dump information about all ports, in response to GETLINK
  */
@@ -808,10 +815,11 @@ static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
 /* Change state and parameters on port. */
 int br_setlink(struct net_device *dev, struct nlmsghdr *nlh, u16 flags)
 {
+	struct net_bridge *br = (struct net_bridge *)netdev_priv(dev);
+	struct nlattr *tb[IFLA_BRPORT_MAX + 1];
+	struct net_bridge_port *p;
 	struct nlattr *protinfo;
 	struct nlattr *afspec;
-	struct net_bridge_port *p;
-	struct nlattr *tb[IFLA_BRPORT_MAX + 1];
 	bool changed = false;
 	int err = 0;
 
@@ -851,13 +859,11 @@ int br_setlink(struct net_device *dev, struct nlmsghdr *nlh, u16 flags)
 		changed = true;
 	}
 
-	if (afspec) {
-		err = br_afspec((struct net_bridge *)netdev_priv(dev), p,
-				afspec, RTM_SETLINK, &changed);
-	}
+	if (afspec)
+		err = br_afspec(br, p, afspec, RTM_SETLINK, &changed);
 
 	if (changed)
-		br_ifinfo_notify(RTM_NEWLINK, p);
+		br_ifinfo_notify(RTM_NEWLINK, br, p);
 out:
 	return err;
 }
@@ -865,8 +871,9 @@ int br_setlink(struct net_device *dev, struct nlmsghdr *nlh, u16 flags)
 /* Delete port information */
 int br_dellink(struct net_device *dev, struct nlmsghdr *nlh, u16 flags)
 {
-	struct nlattr *afspec;
+	struct net_bridge *br = (struct net_bridge *)netdev_priv(dev);
 	struct net_bridge_port *p;
+	struct nlattr *afspec;
 	bool changed = false;
 	int err = 0;
 
@@ -879,13 +886,12 @@ int br_dellink(struct net_device *dev, struct nlmsghdr *nlh, u16 flags)
 	if (!p && !(dev->priv_flags & IFF_EBRIDGE))
 		return -EINVAL;
 
-	err = br_afspec((struct net_bridge *)netdev_priv(dev), p,
-			afspec, RTM_DELLINK, &changed);
+	err = br_afspec(br, p, afspec, RTM_DELLINK, &changed);
 	if (changed)
 		/* Send RTM_NEWLINK because userspace
 		 * expects RTM_NEWLINK for vlan dels
 		 */
-		br_ifinfo_notify(RTM_NEWLINK, p);
+		br_ifinfo_notify(RTM_NEWLINK, br, p);
 
 	return err;
 }
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 860e4afaf71a..40553d832b6e 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -1071,7 +1071,8 @@ extern int (*br_fdb_test_addr_hook)(struct net_device *dev, unsigned char *addr)
 extern struct rtnl_link_ops br_link_ops;
 int br_netlink_init(void);
 void br_netlink_fini(void);
-void br_ifinfo_notify(int event, struct net_bridge_port *port);
+void br_ifinfo_notify(int event, const struct net_bridge *br,
+		      const struct net_bridge_port *port);
 int br_setlink(struct net_device *dev, struct nlmsghdr *nlmsg, u16 flags);
 int br_dellink(struct net_device *dev, struct nlmsghdr *nlmsg, u16 flags);
 int br_getlink(struct sk_buff *skb, u32 pid, u32 seq, struct net_device *dev,
diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index 8f56c2d1f1a7..b6941961a876 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -123,7 +123,7 @@ static void br_root_port_block(const struct net_bridge *br,
 		  (unsigned int) p->port_no, p->dev->name);
 
 	br_set_state(p, BR_STATE_LISTENING);
-	br_ifinfo_notify(RTM_NEWLINK, p);
+	br_ifinfo_notify(RTM_NEWLINK, NULL, p);
 
 	if (br->forward_delay > 0)
 		mod_timer(&p->forward_delay_timer, jiffies + br->forward_delay);
@@ -403,7 +403,7 @@ static void br_make_blocking(struct net_bridge_port *p)
 			br_topology_change_detection(p->br);
 
 		br_set_state(p, BR_STATE_BLOCKING);
-		br_ifinfo_notify(RTM_NEWLINK, p);
+		br_ifinfo_notify(RTM_NEWLINK, NULL, p);
 
 		del_timer(&p->forward_delay_timer);
 	}
@@ -426,7 +426,7 @@ static void br_make_forwarding(struct net_bridge_port *p)
 	else
 		br_set_state(p, BR_STATE_LEARNING);
 
-	br_ifinfo_notify(RTM_NEWLINK, p);
+	br_ifinfo_notify(RTM_NEWLINK, NULL, p);
 
 	if (br->forward_delay != 0)
 		mod_timer(&p->forward_delay_timer, jiffies + br->forward_delay);
diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
index 89110319ef0f..808e2b914015 100644
--- a/net/bridge/br_stp_if.c
+++ b/net/bridge/br_stp_if.c
@@ -96,7 +96,7 @@ void br_stp_enable_port(struct net_bridge_port *p)
 {
 	br_init_port(p);
 	br_port_state_selection(p->br);
-	br_ifinfo_notify(RTM_NEWLINK, p);
+	br_ifinfo_notify(RTM_NEWLINK, NULL, p);
 }
 
 /* called under bridge lock */
@@ -111,7 +111,7 @@ void br_stp_disable_port(struct net_bridge_port *p)
 	p->topology_change_ack = 0;
 	p->config_pending = 0;
 
-	br_ifinfo_notify(RTM_NEWLINK, p);
+	br_ifinfo_notify(RTM_NEWLINK, NULL, p);
 
 	del_timer(&p->message_age_timer);
 	del_timer(&p->forward_delay_timer);
diff --git a/net/bridge/br_stp_timer.c b/net/bridge/br_stp_timer.c
index 60b6fe277a8b..b54c1a331450 100644
--- a/net/bridge/br_stp_timer.c
+++ b/net/bridge/br_stp_timer.c
@@ -99,7 +99,7 @@ static void br_forward_delay_timer_expired(unsigned long arg)
 		netif_carrier_on(br->dev);
 	}
 	rcu_read_lock();
-	br_ifinfo_notify(RTM_NEWLINK, p);
+	br_ifinfo_notify(RTM_NEWLINK, NULL, p);
 	rcu_read_unlock();
 	spin_unlock(&br->lock);
 }
diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index 0a1fa9ccd8b7..0254c35b2bf0 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -280,7 +280,7 @@ static ssize_t brport_store(struct kobject *kobj,
 			ret = brport_attr->store(p, val);
 			spin_unlock_bh(&p->br->lock);
 			if (!ret) {
-				br_ifinfo_notify(RTM_NEWLINK, p);
+				br_ifinfo_notify(RTM_NEWLINK, NULL, p);
 				ret = count;
 			}
 		}
-- 
2.1.4
