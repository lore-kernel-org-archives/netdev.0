From: Laszlo Attila Toth <panther@balabit.hu>
Subject: [PATCH 2/2] rtnetlink: send a single notification on device state changes
Date: Fri,  1 Feb 2008 17:07:34 +0100
Message-ID: <12018820542704-git-send-email-panther@balabit.hu>
References: <12018820194128-git-send-email-panther@balabit.hu>
Cc: netdev@vger.kernel.org, Laszlo Attila Toth <panther@balabit.hu>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:53331 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754547AbYBAQHh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2008 11:07:37 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id B6F44C163B
	for <netdev@vger.kernel.org>; Fri,  1 Feb 2008 17:07:36 +0100 (CET)
In-Reply-To: <12018820194128-git-send-email-panther@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In do_setlink() a single notification is sent at the end of the function
if any modification occured. If the address has been changed, another
notification is sent.

Both of them is required because originally only the NETDEV_CHANGEADDR
notification was sent and although device state change implies address
change, some programs may expect the original notification. It remains
for compatibity.

Signed-off-by: Laszlo Attila Toth <panther@balabit.hu>
---
 net/core/rtnetlink.c |   27 ++++++++++++++++++++-------
 1 files changed, 20 insertions(+), 7 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 724e8f5..d67b950 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -545,7 +545,7 @@ int rtnl_put_cacheinfo(struct sk_buff *skb, struct dst_entry *dst, u32 id,
 
 EXPORT_SYMBOL_GPL(rtnl_put_cacheinfo);
 
-static void set_operstate(struct net_device *dev, unsigned char transition)
+static int set_operstate(struct net_device *dev, unsigned char transition)
 {
 	unsigned char operstate = dev->operstate;
 
@@ -566,8 +566,9 @@ static void set_operstate(struct net_device *dev, unsigned char transition)
 
 	if (dev->operstate != operstate) {
 		dev->operstate = operstate;
-		netdev_state_change(dev);
-	}
+		return 1;
+	} else
+		return 0;
 }
 
 static void copy_rtnl_link_stats(struct rtnl_link_stats *a,
@@ -861,6 +862,7 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 	if (tb[IFLA_BROADCAST]) {
 		nla_memcpy(dev->broadcast, tb[IFLA_BROADCAST], dev->addr_len);
 		send_addr_notify = 1;
+		modified = 1;
 	}
 
 	if (ifm->ifi_flags || ifm->ifi_change) {
@@ -873,14 +875,21 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
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
+		modified |= set_operstate(dev, nla_get_u8(tb[IFLA_OPERSTATE]));
 
 	if (tb[IFLA_LINKMODE]) {
-		dev->link_mode = nla_get_u8(tb[IFLA_LINKMODE]);
+		if (dev->link_mode != nla_get_u8(tb[IFLA_LINKMODE])) {
+			dev->link_mode = nla_get_u8(tb[IFLA_LINKMODE]);
+			modified = 1;
+		}
 	}
 
 	err = 0;
@@ -894,6 +903,10 @@ errout:
 
 	if (send_addr_notify)
 		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
+
+	if (modified)
+		netdev_state_change(dev);
+
 	return err;
 }
 
-- 
1.5.2.5

