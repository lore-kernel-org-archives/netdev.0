From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 1/2] netns bridge: allow bridges in netns!
Date: Sat, 6 Sep 2008 10:43:05 +0400
Message-ID: <20080906064304.GA7810@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, containers@osdl.org
To: davem@davemloft.net, shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.185]:16514 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750937AbYIFGlV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Sep 2008 02:41:21 -0400
Received: by mu-out-0910.google.com with SMTP id g7so590435muf.1
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2008 23:41:19 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bridge as netdevice doesn't cross netns boundaries.

Bridge ports and bridge itself live in same netns.

Notifiers are fixed.

netns propagated from userspace socket for setup and teardown.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/bridge/br_device.c   |    3 ++-
 net/bridge/br_if.c       |   11 ++++++-----
 net/bridge/br_ioctl.c    |   20 ++++++++++----------
 net/bridge/br_netlink.c  |   15 +++++----------
 net/bridge/br_notify.c   |    3 ---
 net/bridge/br_private.h  |    4 ++--
 net/bridge/br_stp_bpdu.c |    3 ---
 7 files changed, 25 insertions(+), 34 deletions(-)

--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -178,5 +178,6 @@ void br_dev_setup(struct net_device *dev)
 	dev->priv_flags = IFF_EBRIDGE;
 
 	dev->features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_HIGHDMA |
-			NETIF_F_GSO_MASK | NETIF_F_NO_CSUM | NETIF_F_LLTX;
+			NETIF_F_GSO_MASK | NETIF_F_NO_CSUM | NETIF_F_LLTX |
+			NETIF_F_NETNS_LOCAL;
 }
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -168,7 +168,7 @@ static void del_br(struct net_bridge *br)
 	unregister_netdevice(br->dev);
 }
 
-static struct net_device *new_bridge_dev(const char *name)
+static struct net_device *new_bridge_dev(struct net *net, const char *name)
 {
 	struct net_bridge *br;
 	struct net_device *dev;
@@ -178,6 +178,7 @@ static struct net_device *new_bridge_dev(const char *name)
 
 	if (!dev)
 		return NULL;
+	dev_net_set(dev, net);
 
 	br = netdev_priv(dev);
 	br->dev = dev;
@@ -262,12 +263,12 @@ static struct net_bridge_port *new_nbp(struct net_bridge *br,
 	return p;
 }
 
-int br_add_bridge(const char *name)
+int br_add_bridge(struct net *net, const char *name)
 {
 	struct net_device *dev;
 	int ret;
 
-	dev = new_bridge_dev(name);
+	dev = new_bridge_dev(net, name);
 	if (!dev)
 		return -ENOMEM;
 
@@ -294,13 +295,13 @@ out_free:
 	goto out;
 }
 
-int br_del_bridge(const char *name)
+int br_del_bridge(struct net *net, const char *name)
 {
 	struct net_device *dev;
 	int ret = 0;
 
 	rtnl_lock();
-	dev = __dev_get_by_name(&init_net, name);
+	dev = __dev_get_by_name(net, name);
 	if (dev == NULL)
 		ret =  -ENXIO; 	/* Could not find device */
 
--- a/net/bridge/br_ioctl.c
+++ b/net/bridge/br_ioctl.c
@@ -21,12 +21,12 @@
 #include "br_private.h"
 
 /* called with RTNL */
-static int get_bridge_ifindices(int *indices, int num)
+static int get_bridge_ifindices(struct net *net, int *indices, int num)
 {
 	struct net_device *dev;
 	int i = 0;
 
-	for_each_netdev(&init_net, dev) {
+	for_each_netdev(net, dev) {
 		if (i >= num)
 			break;
 		if (dev->priv_flags & IFF_EBRIDGE)
@@ -89,7 +89,7 @@ static int add_del_if(struct net_bridge *br, int ifindex, int isadd)
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
 
-	dev = dev_get_by_index(&init_net, ifindex);
+	dev = dev_get_by_index(dev_net(br->dev), ifindex);
 	if (dev == NULL)
 		return -EINVAL;
 
@@ -309,7 +309,7 @@ static int old_dev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	return -EOPNOTSUPP;
 }
 
-static int old_deviceless(void __user *uarg)
+static int old_deviceless(struct net *net, void __user *uarg)
 {
 	unsigned long args[3];
 
@@ -331,7 +331,7 @@ static int old_deviceless(void __user *uarg)
 		if (indices == NULL)
 			return -ENOMEM;
 
-		args[2] = get_bridge_ifindices(indices, args[2]);
+		args[2] = get_bridge_ifindices(net, indices, args[2]);
 
 		ret = copy_to_user((void __user *)args[1], indices, args[2]*sizeof(int))
 			? -EFAULT : args[2];
@@ -354,9 +354,9 @@ static int old_deviceless(void __user *uarg)
 		buf[IFNAMSIZ-1] = 0;
 
 		if (args[0] == BRCTL_ADD_BRIDGE)
-			return br_add_bridge(buf);
+			return br_add_bridge(net, buf);
 
-		return br_del_bridge(buf);
+		return br_del_bridge(net, buf);
 	}
 	}
 
@@ -368,7 +368,7 @@ int br_ioctl_deviceless_stub(struct net *net, unsigned int cmd, void __user *uar
 	switch (cmd) {
 	case SIOCGIFBR:
 	case SIOCSIFBR:
-		return old_deviceless(uarg);
+		return old_deviceless(net, uarg);
 
 	case SIOCBRADDBR:
 	case SIOCBRDELBR:
@@ -383,9 +383,9 @@ int br_ioctl_deviceless_stub(struct net *net, unsigned int cmd, void __user *uar
 
 		buf[IFNAMSIZ-1] = 0;
 		if (cmd == SIOCBRADDBR)
-			return br_add_bridge(buf);
+			return br_add_bridge(net, buf);
 
-		return br_del_bridge(buf);
+		return br_del_bridge(net, buf);
 	}
 	}
 	return -EOPNOTSUPP;
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -82,6 +82,7 @@ nla_put_failure:
  */
 void br_ifinfo_notify(int event, struct net_bridge_port *port)
 {
+	struct net *net = dev_net(port->dev);
 	struct sk_buff *skb;
 	int err = -ENOBUFS;
 
@@ -97,10 +98,10 @@ void br_ifinfo_notify(int event, struct net_bridge_port *port)
 		kfree_skb(skb);
 		goto errout;
 	}
-	err = rtnl_notify(skb, &init_net,0, RTNLGRP_LINK, NULL, GFP_ATOMIC);
+	err = rtnl_notify(skb, net, 0, RTNLGRP_LINK, NULL, GFP_ATOMIC);
 errout:
 	if (err < 0)
-		rtnl_set_sk_err(&init_net, RTNLGRP_LINK, err);
+		rtnl_set_sk_err(net, RTNLGRP_LINK, err);
 }
 
 /*
@@ -112,11 +113,8 @@ static int br_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 	struct net_device *dev;
 	int idx;
 
-	if (net != &init_net)
-		return 0;
-
 	idx = 0;
-	for_each_netdev(&init_net, dev) {
+	for_each_netdev(net, dev) {
 		/* not a bridge port */
 		if (dev->br_port == NULL || idx < cb->args[0])
 			goto skip;
@@ -147,9 +145,6 @@ static int br_rtm_setlink(struct sk_buff *skb,  struct nlmsghdr *nlh, void *arg)
 	struct net_bridge_port *p;
 	u8 new_state;
 
-	if (net != &init_net)
-		return -EINVAL;
-
 	if (nlmsg_len(nlh) < sizeof(*ifm))
 		return -EINVAL;
 
@@ -165,7 +160,7 @@ static int br_rtm_setlink(struct sk_buff *skb,  struct nlmsghdr *nlh, void *arg)
 	if (new_state > BR_STATE_BLOCKING)
 		return -EINVAL;
 
-	dev = __dev_get_by_index(&init_net, ifm->ifi_index);
+	dev = __dev_get_by_index(net, ifm->ifi_index);
 	if (!dev)
 		return -ENODEV;
 
--- a/net/bridge/br_notify.c
+++ b/net/bridge/br_notify.c
@@ -35,9 +35,6 @@ static int br_device_event(struct notifier_block *unused, unsigned long event, v
 	struct net_bridge_port *p = dev->br_port;
 	struct net_bridge *br;
 
-	if (!net_eq(dev_net(dev), &init_net))
-		return NOTIFY_DONE;
-
 	/* not a port of a bridge */
 	if (p == NULL)
 		return NOTIFY_DONE;
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -178,8 +178,8 @@ extern void br_flood_forward(struct net_bridge *br, struct sk_buff *skb);
 
 /* br_if.c */
 extern void br_port_carrier_check(struct net_bridge_port *p);
-extern int br_add_bridge(const char *name);
-extern int br_del_bridge(const char *name);
+extern int br_add_bridge(struct net *net, const char *name);
+extern int br_del_bridge(struct net *net, const char *name);
 extern void br_cleanup_bridges(void);
 extern int br_add_if(struct net_bridge *br,
 	      struct net_device *dev);
--- a/net/bridge/br_stp_bpdu.c
+++ b/net/bridge/br_stp_bpdu.c
@@ -140,9 +140,6 @@ void br_stp_rcv(const struct stp_proto *proto, struct sk_buff *skb,
 	struct net_bridge *br;
 	const unsigned char *buf;
 
-	if (!net_eq(dev_net(dev), &init_net))
-		goto err;
-
 	if (!p)
 		goto err;
 

