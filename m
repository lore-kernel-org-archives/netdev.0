From: Laszlo Attila Toth <panther@balabit.hu>
Subject: [PATCH] rtnetlink.c: send a single notification on device state changes
Date: Thu,  7 Feb 2008 12:57:50 +0100
Message-ID: <1202385470416-git-send-email-panther@balabit.hu>
References: <20080205.175337.266368079.davem@davemloft.net>
Cc: netdev@vger.kernel.org, Laszlo Attila Toth <panther@balabit.hu>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:33267 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751348AbYBGL54 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Feb 2008 06:57:56 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id 4C7FEC1512
	for <netdev@vger.kernel.org>; Thu,  7 Feb 2008 12:57:52 +0100 (CET)
In-Reply-To: <20080205.175337.266368079.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In do_setlink() a single notification is sent at the end of the function
if any modification occured. If the address has been changed, another
notification is sent.

Both of them is required because originally only the NETDEV_CHANGEADDR
notification was sent and although device state change implies address
change, some programs may expect the original notification. It remains
for compatibity.

If set_operstate() is called from do_setlink(), it doesn't send
a notification, only if it is called from rtnl_create_link() as earlier.

Signed-off-by: Laszlo Attila Toth <panther@balabit.hu>
---
 net/core/rtnetlink.c |   36 ++++++++++++++++++++++++++----------
 1 files changed, 26 insertions(+), 10 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 61ac8d0..ecb02af 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -504,7 +504,7 @@ int rtnl_put_cacheinfo(struct sk_buff *skb, struct dst_entry *dst, u32 id,
 
 EXPORT_SYMBOL_GPL(rtnl_put_cacheinfo);
 
-static void set_operstate(struct net_device *dev, unsigned char transition)
+static int set_operstate(struct net_device *dev, unsigned char transition, bool send_notification)
 {
 	unsigned char operstate = dev->operstate;
 
@@ -527,8 +527,12 @@ static void set_operstate(struct net_device *dev, unsigned char transition)
 		write_lock_bh(&dev_base_lock);
 		dev->operstate = operstate;
 		write_unlock_bh(&dev_base_lock);
-		netdev_state_change(dev);
-	}
+
+		if (send_notification)
+			netdev_state_change(dev);
+		return 1;
+	} else
+		return 0;
 }
 
 static void copy_rtnl_link_stats(struct rtnl_link_stats *a,
@@ -822,6 +826,7 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 	if (tb[IFLA_BROADCAST]) {
 		nla_memcpy(dev->broadcast, tb[IFLA_BROADCAST], dev->addr_len);
 		send_addr_notify = 1;
+		modified = 1;
 	}
 
 	if (ifm->ifi_flags || ifm->ifi_change) {
@@ -834,16 +839,23 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 		dev_change_flags(dev, flags);
 	}
 
-	if (tb[IFLA_TXQLEN])
-		dev->tx_queue_len = nla_get_u32(tb[IFLA_TXQLEN]);
+	if (tb[IFLA_TXQLEN]) {
+		if (dev->tx_queue_len != nla_get_u32(tb[IFLA_TXQLEN])) {
+			dev->tx_queue_len = nla_get_u32(tb[IFLA_TXQLEN]);
+			modified = 1;
+		}
+	}
 
 	if (tb[IFLA_OPERSTATE])
-		set_operstate(dev, nla_get_u8(tb[IFLA_OPERSTATE]));
+		modified |= set_operstate(dev, nla_get_u8(tb[IFLA_OPERSTATE]), false);
 
 	if (tb[IFLA_LINKMODE]) {
-		write_lock_bh(&dev_base_lock);
-		dev->link_mode = nla_get_u8(tb[IFLA_LINKMODE]);
-		write_unlock_bh(&dev_base_lock);
+		if (dev->link_mode != nla_get_u8(tb[IFLA_LINKMODE])) {
+			write_lock_bh(&dev_base_lock);
+			dev->link_mode = nla_get_u8(tb[IFLA_LINKMODE]);
+			write_lock_bh(&dev_base_lock);
+			modified = 1;
+		}
 	}
 
 	err = 0;
@@ -857,6 +869,10 @@ errout:
 
 	if (send_addr_notify)
 		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
+
+	if (modified)
+		netdev_state_change(dev);
+
 	return err;
 }
 
@@ -974,7 +990,7 @@ struct net_device *rtnl_create_link(struct net *net, char *ifname,
 	if (tb[IFLA_TXQLEN])
 		dev->tx_queue_len = nla_get_u32(tb[IFLA_TXQLEN]);
 	if (tb[IFLA_OPERSTATE])
-		set_operstate(dev, nla_get_u8(tb[IFLA_OPERSTATE]));
+		set_operstate(dev, nla_get_u8(tb[IFLA_OPERSTATE]), true);
 	if (tb[IFLA_LINKMODE])
 		dev->link_mode = nla_get_u8(tb[IFLA_LINKMODE]);
 
-- 
1.5.2.5

