From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net v2] net: Flush local routes when device changes vrf association
Date: Thu, 10 Dec 2015 10:25:24 -0800
Message-ID: <1449771924-21775-1-git-send-email-dsa@cumulusnetworks.com>
Cc: ja@ssi.bg, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33348 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753188AbbLJSZb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2015 13:25:31 -0500
Received: by pabur14 with SMTP id ur14so51477662pab.0
        for <netdev@vger.kernel.org>; Thu, 10 Dec 2015 10:25:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The VRF driver cycles netdevs when an interface is enslaved or released:
the down event is used to flush neighbor and route tables and the up
event (if the interface was already up) effectively moves local and
connected routes to the proper table.

As of 4f823defdd5b the local route is left hanging around after a link
down, so when a netdev is moved from one VRF to another (or released
from a VRF altogether) local routes are left in the wrong table.

Fix by handling the NETDEV_CHANGEUPPER event. When the upper dev is
an L3mdev then call fib_disable_ip to flush all routes, local ones
to.

Fixes: 4f823defdd5b ("ipv4: fix to not remove local route on link down")
Cc: Julian Anastasov <ja@ssi.bg>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v2
- key off NETDEV_CHANGEUPPER event vs using a new event

 net/ipv4/fib_frontend.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index cc8f3e506cde..473447593060 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -1155,6 +1155,7 @@ static int fib_inetaddr_event(struct notifier_block *this, unsigned long event,
 static int fib_netdev_event(struct notifier_block *this, unsigned long event, void *ptr)
 {
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
+	struct netdev_notifier_changeupper_info *info;
 	struct in_device *in_dev;
 	struct net *net = dev_net(dev);
 	unsigned int flags;
@@ -1193,6 +1194,14 @@ static int fib_netdev_event(struct notifier_block *this, unsigned long event, vo
 	case NETDEV_CHANGEMTU:
 		rt_cache_flush(net);
 		break;
+	case NETDEV_CHANGEUPPER:
+		info = ptr;
+		/* flush all routes if dev is linked to or unlinked from
+		 * an L3 master device (e.g., VRF)
+		 */
+		if (info->upper_dev && netif_is_l3_master(info->upper_dev))
+			fib_disable_ip(dev, NETDEV_DOWN, true);
+		break;
 	}
 	return NOTIFY_DONE;
 }
-- 
1.9.1
