From: Laszlo Attila Toth <panther@balabit.hu>
Subject: [IFGROUPv5 1/3] rtnetlink: setlink changes are unprotected; with single notification
Date: Fri, 26 Oct 2007 14:30:30 +0200
Message-ID: <11934018354072-git-send-email-panther@balabit.hu>
References: <11934018353825-git-send-email-panther@balabit.hu>
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Laszlo Attila Toth <panther@balabit.hu>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:50179 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752223AbXJZMam (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2007 08:30:42 -0400
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id C01EAC1195
	for <netdev@vger.kernel.org>; Fri, 26 Oct 2007 14:30:41 +0200 (CEST)
In-Reply-To: <11934018353825-git-send-email-panther@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In do_setlink the device changes don't need to be protected. Notification
is sent at the end of the function once if any modification occured
and once if an address has been changed.

Signed-off-by: Laszlo Attila Toth <panther@balabit.hu>
---
 net/core/rtnetlink.c |   32 ++++++++++++++++++++------------
 1 files changed, 20 insertions(+), 12 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 4a2640d..0e278ac 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -537,7 +537,7 @@ int rtnl_put_cacheinfo(struct sk_buff *skb, struct dst_entry *dst, u32 id,
 
 EXPORT_SYMBOL_GPL(rtnl_put_cacheinfo);
 
-static void set_operstate(struct net_device *dev, unsigned char transition)
+static int set_operstate(struct net_device *dev, unsigned char transition)
 {
 	unsigned char operstate = dev->operstate;
 
@@ -557,11 +557,10 @@ static void set_operstate(struct net_device *dev, unsigned char transition)
 	}
 
 	if (dev->operstate != operstate) {
-		write_lock_bh(&dev_base_lock);
 		dev->operstate = operstate;
-		write_unlock_bh(&dev_base_lock);
-		netdev_state_change(dev);
-	}
+		return 1;
+	} else
+		return 0;
 }
 
 static void copy_rtnl_link_stats(struct rtnl_link_stats *a,
@@ -855,6 +854,7 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 	if (tb[IFLA_BROADCAST]) {
 		nla_memcpy(dev->broadcast, tb[IFLA_BROADCAST], dev->addr_len);
 		send_addr_notify = 1;
+		modified = 1;
 	}
 
 	if (ifm->ifi_flags || ifm->ifi_change) {
@@ -867,16 +867,22 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
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
 
-	if (tb[IFLA_OPERSTATE])
-		set_operstate(dev, nla_get_u8(tb[IFLA_OPERSTATE]));
+	if (tb[IFLA_OPERSTATE]) {
+		modified |= set_operstate(dev, nla_get_u8(tb[IFLA_OPERSTATE]));
+	}
 
 	if (tb[IFLA_LINKMODE]) {
-		write_lock_bh(&dev_base_lock);
-		dev->link_mode = nla_get_u8(tb[IFLA_LINKMODE]);
-		write_unlock_bh(&dev_base_lock);
+		if (dev->link_mode != nla_get_u8(tb[IFLA_LINKMODE])) {
+			dev->link_mode = nla_get_u8(tb[IFLA_LINKMODE]);
+			modified = 1;
+		}
 	}
 
 	err = 0;
@@ -890,6 +896,8 @@ errout:
 
 	if (send_addr_notify)
 		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
+	if (modified)
+		netdev_state_change(dev);
 	return err;
 }
 
-- 
1.5.2.5

