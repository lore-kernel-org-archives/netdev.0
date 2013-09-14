From: Hong Zhiguo <honkiko@gmail.com>
Subject: [PATCH net-next 1/2] bridge: use br_port_get_rtnl within rtnl lock
Date: Sat, 14 Sep 2013 22:42:27 +0800
Message-ID: <1379169748-767-2-git-send-email-zhiguohong@tencent.com>
References: <1379169748-767-1-git-send-email-zhiguohong@tencent.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, vyasevic@redhat.com,
	Hong Zhiguo <zhiguohong@tencent.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:38464 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932084Ab3INOol (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Sep 2013 10:44:41 -0400
Received: by mail-pd0-f181.google.com with SMTP id g10so2411064pdj.12
        for <netdev@vger.kernel.org>; Sat, 14 Sep 2013 07:44:41 -0700 (PDT)
In-Reply-To: <1379169748-767-1-git-send-email-zhiguohong@tencent.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hong Zhiguo <zhiguohong@tencent.com>

current br_port_get_rcu is problematic in bridging path
(NULL deref). Change these calls in netlink path first.

Signed-off-by: Hong Zhiguo <zhiguohong@tencent.com>
---
 net/bridge/br_netlink.c | 4 ++--
 net/bridge/br_private.h | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index b9259ef..e74ddc1 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -207,7 +207,7 @@ int br_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 	       struct net_device *dev, u32 filter_mask)
 {
 	int err = 0;
-	struct net_bridge_port *port = br_port_get_rcu(dev);
+	struct net_bridge_port *port = br_port_get_rtnl(dev);
 
 	/* not a bridge port and  */
 	if (!port && !(filter_mask & RTEXT_FILTER_BRVLAN))
@@ -451,7 +451,7 @@ static size_t br_get_link_af_size(const struct net_device *dev)
 	struct net_port_vlans *pv;
 
 	if (br_port_exists(dev))
-		pv = nbp_get_vlan_info(br_port_get_rcu(dev));
+		pv = nbp_get_vlan_info(br_port_get_rtnl(dev));
 	else if (dev->priv_flags & IFF_EBRIDGE)
 		pv = br_get_vlan_info((struct net_bridge *)netdev_priv(dev));
 	else
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 598cb0b..49fb43e 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -208,7 +208,7 @@ static inline struct net_bridge_port *br_port_get_rcu(const struct net_device *d
 	return br_port_exists(dev) ? port : NULL;
 }
 
-static inline struct net_bridge_port *br_port_get_rtnl(struct net_device *dev)
+static inline struct net_bridge_port *br_port_get_rtnl(const struct net_device *dev)
 {
 	return br_port_exists(dev) ?
 		rtnl_dereference(dev->rx_handler_data) : NULL;
-- 
1.8.1.2
