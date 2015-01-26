From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next] vlan: take link netns into account in vlan_newlink()
Date: Mon, 26 Jan 2015 10:44:15 +0100
Message-ID: <1422265455-4331-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:40032 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754572AbbAZJo1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 04:44:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When IFLA_LINK_NETNSID is set, the ifindex from IFLA_LINK comes from another
netns.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/8021q/vlan_netlink.c | 13 ++++++++++++-
 net/core/net_namespace.c |  1 +
 2 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
index c92b52f37d38..e7875c7f3cb4 100644
--- a/net/8021q/vlan_netlink.c
+++ b/net/8021q/vlan_netlink.c
@@ -118,6 +118,7 @@ static int vlan_newlink(struct net *src_net, struct net_device *dev,
 {
 	struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
 	struct net_device *real_dev;
+	struct net *link_net;
 	__be16 proto;
 	int err;
 
@@ -126,7 +127,17 @@ static int vlan_newlink(struct net *src_net, struct net_device *dev,
 
 	if (!tb[IFLA_LINK])
 		return -EINVAL;
-	real_dev = __dev_get_by_index(src_net, nla_get_u32(tb[IFLA_LINK]));
+	if (tb[IFLA_LINK_NETNSID]) {
+		int id = nla_get_s32(tb[IFLA_LINK_NETNSID]);
+
+		link_net = get_net_ns_by_id(src_net, id);
+		if (!link_net)
+			return -EINVAL;
+	} else {
+		link_net = get_net(src_net);
+	}
+	real_dev = __dev_get_by_index(link_net, nla_get_u32(tb[IFLA_LINK]));
+	put_net(link_net);
 	if (!real_dev)
 		return -ENODEV;
 
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index b7bde551ef76..8e24f974c665 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -219,6 +219,7 @@ struct net *get_net_ns_by_id(struct net *net, int id)
 
 	return peer;
 }
+EXPORT_SYMBOL(get_net_ns_by_id);
 
 /*
  * setup_net runs the initializers for the network namespace object.
-- 
2.2.2
