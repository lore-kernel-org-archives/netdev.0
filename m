From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net] net: Flush local routes when device changes vrf association
Date: Wed,  9 Dec 2015 17:35:08 -0800
Message-ID: <1449711308-35842-1-git-send-email-dsa@cumulusnetworks.com>
Cc: ja@ssi.bg, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33322 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750910AbbLJBfh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 20:35:37 -0500
Received: by pfnn128 with SMTP id n128so38979026pfn.0
        for <netdev@vger.kernel.org>; Wed, 09 Dec 2015 17:35:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The VRF driver cycles netdevs when an interface is enslaved or released:
the down event is used to flush neighbor and route tables and the up
event (if the interface was already up) effectively moves local and
connected routes to the proper table.

As of 4f823defdd5b the local route is left hanging around after a link
down, so when a netdev is moved from one VRF to another (or released
from a VRF altogether) local routes are left in the wrong table.

Fix by introducing a NETDEV_VRF_CHANGE event that can be used to trigger
the flush of all routes, including local ones.

Fixes: 4f823defdd5b ("ipv4: fix to not remove local route on link down")
Cc: Julian Anastasov <ja@ssi.bg>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
Dave: longer term I would like to use the NETDEV_VRF_CHANGE event
      to reduce the processing on a VRF change, for instance not losing
      IPv6 addresses on the move.

 drivers/net/vrf.c         | 9 +++++++--
 include/linux/netdevice.h | 1 +
 net/ipv4/fib_frontend.c   | 3 +++
 3 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index b9918e8415ea..36d57f06efde 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -601,12 +601,17 @@ static void cycle_netdev(struct net_device *dev)
 	unsigned int flags = dev->flags;
 	int ret;
 
-	if (!netif_running(dev))
+	if (!netif_running(dev)) {
+		call_netdevice_notifiers(NETDEV_VRF_CHANGE, dev);
 		return;
+	}
 
 	ret = dev_change_flags(dev, flags & ~IFF_UP);
-	if (ret >= 0)
+	if (ret >= 0) {
+		call_netdevice_notifiers(NETDEV_VRF_CHANGE, dev);
+
 		ret = dev_change_flags(dev, flags);
+	}
 
 	if (ret < 0) {
 		netdev_err(dev,
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 1bb21ff0fa64..858fa09423ea 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2165,6 +2165,7 @@ struct netdev_lag_lower_state_info {
 #define NETDEV_BONDING_INFO	0x0019
 #define NETDEV_PRECHANGEUPPER	0x001A
 #define NETDEV_CHANGELOWERSTATE	0x001B
+#define NETDEV_VRF_CHANGE	0x001C
 
 int register_netdevice_notifier(struct notifier_block *nb);
 int unregister_netdevice_notifier(struct notifier_block *nb);
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index cc8f3e506cde..7d30f6436e3b 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -1193,6 +1193,9 @@ static int fib_netdev_event(struct notifier_block *this, unsigned long event, vo
 	case NETDEV_CHANGEMTU:
 		rt_cache_flush(net);
 		break;
+	case NETDEV_VRF_CHANGE:
+		fib_disable_ip(dev, NETDEV_DOWN, true);
+		break;
 	}
 	return NOTIFY_DONE;
 }
-- 
1.9.1
