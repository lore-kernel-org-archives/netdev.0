From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 13/14][VLAN]: Allows vlan devices registration in net namespace.
Date: Thu, 10 Apr 2008 19:22:15 +0400
Message-ID: <47FE30A7.4020503@openvz.org>
References: <47FE2AD4.9080609@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>, Denis Lunev <den@openvz.org>,
	Linux Containers <containers@lists.osdl.org>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:41711 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756558AbYDJO6K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Apr 2008 10:58:10 -0400
In-Reply-To: <47FE2AD4.9080609@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This one is similar to what I've done for TUN - set the proper
net after device allocation and clean VLANs on net exit.

Plus, drop explicit init_net usage.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/8021q/vlan.c         |    7 +++----
 net/8021q/vlan_dev.c     |    3 ---
 net/8021q/vlan_netlink.c |    2 +-
 3 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 5cacad0..7e9d22e 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -340,6 +340,7 @@ static int register_vlan_device(struct net_device *real_dev,
 	if (new_dev == NULL)
 		return -ENOBUFS;
 
+	dev_net_set(new_dev, net);
 	/* need 4 bytes for extra VLAN header info,
 	 * hope the underlying device can handle it.
 	 */
@@ -406,9 +407,6 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 	int i, flgs;
 	struct net_device *vlandev;
 
-	if (dev_net(dev) != &init_net)
-		return NOTIFY_DONE;
-
 	if (is_vlan_dev(dev)) {
 		__vlan_device_event(dev, event);
 		goto out;
@@ -534,7 +532,7 @@ static int vlan_ioctl_handler(struct net *net, void __user *arg)
 	case GET_VLAN_REALDEV_NAME_CMD:
 	case GET_VLAN_VID_CMD:
 		err = -ENODEV;
-		dev = __dev_get_by_name(&init_net, args.device1);
+		dev = __dev_get_by_name(net, args.device1);
 		if (!dev)
 			goto out;
 
@@ -665,6 +663,7 @@ static void vlan_exit_net(struct net *net)
 	struct vlan_net *vn;
 
 	vn = net_generic(net, vlan_net_id);
+	rtnl_kill_links(net, &vlan_link_ops);
 	vlan_proc_cleanup(net);
 	kfree(vn);
 }
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 0e3b2d3..9fa6b90 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -153,9 +153,6 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 	struct net_device_stats *stats;
 	unsigned short vlan_TCI;
 
-	if (dev_net(dev) != &init_net)
-		goto err_free;
-
 	skb = skb_share_check(skb, GFP_ATOMIC);
 	if (skb == NULL)
 		goto err_free;
diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
index e32eeb3..c93e69e 100644
--- a/net/8021q/vlan_netlink.c
+++ b/net/8021q/vlan_netlink.c
@@ -113,7 +113,7 @@ static int vlan_newlink(struct net_device *dev,
 
 	if (!tb[IFLA_LINK])
 		return -EINVAL;
-	real_dev = __dev_get_by_index(&init_net, nla_get_u32(tb[IFLA_LINK]));
+	real_dev = __dev_get_by_index(dev_net(dev), nla_get_u32(tb[IFLA_LINK]));
 	if (!real_dev)
 		return -ENODEV;
 
-- 
1.5.3.4

