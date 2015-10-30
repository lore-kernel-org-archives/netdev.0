From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCHv3 net 1/2] ipv4: fix to not remove local route on link down
Date: Fri, 30 Oct 2015 10:23:33 +0200
Message-ID: <1446193414-8244-2-git-send-email-ja@ssi.bg>
References: <1446193414-8244-1-git-send-email-ja@ssi.bg>
Cc: netdev@vger.kernel.org, Andy Gospodarek <gospo@cumulusnetworks.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:49555 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1030234AbbJ3IX4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Oct 2015 04:23:56 -0400
In-Reply-To: <1446193414-8244-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When fib_netdev_event calls fib_disable_ip on NETDEV_DOWN event
we should not delete the local routes if the local address
is still present. The confusion comes from the fact that both
fib_netdev_event and fib_inetaddr_event use the NETDEV_DOWN
constant. Fix it by returning back the variable 'force'.

Steps to reproduce:
modprobe dummy
ifconfig dummy0 192.168.168.1 up
ifconfig dummy0 down
ip route list table local | grep dummy | grep host
local 192.168.168.1 dev dummy0  proto kernel  scope host  src 192.168.168.1

Fixes: 8a3d03166f19 ("net: track link-status of ipv4 nexthops")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_fib.h     |  2 +-
 net/ipv4/fib_frontend.c  | 13 +++++++------
 net/ipv4/fib_semantics.c | 11 ++++++++---
 3 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 727d6e9..965fa5b 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -317,7 +317,7 @@ void fib_flush_external(struct net *net);
 
 /* Exported by fib_semantics.c */
 int ip_fib_check_default(__be32 gw, struct net_device *dev);
-int fib_sync_down_dev(struct net_device *dev, unsigned long event);
+int fib_sync_down_dev(struct net_device *dev, unsigned long event, bool force);
 int fib_sync_down_addr(struct net *net, __be32 local);
 int fib_sync_up(struct net_device *dev, unsigned int nh_flags);
 void fib_select_multipath(struct fib_result *res);
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 690bcbc..457b2cd 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -1110,9 +1110,10 @@ static void nl_fib_lookup_exit(struct net *net)
 	net->ipv4.fibnl = NULL;
 }
 
-static void fib_disable_ip(struct net_device *dev, unsigned long event)
+static void fib_disable_ip(struct net_device *dev, unsigned long event,
+			   bool force)
 {
-	if (fib_sync_down_dev(dev, event))
+	if (fib_sync_down_dev(dev, event, force))
 		fib_flush(dev_net(dev));
 	rt_cache_flush(dev_net(dev));
 	arp_ifdown(dev);
@@ -1140,7 +1141,7 @@ static int fib_inetaddr_event(struct notifier_block *this, unsigned long event,
 			/* Last address was deleted from this interface.
 			 * Disable IP.
 			 */
-			fib_disable_ip(dev, event);
+			fib_disable_ip(dev, event, true);
 		} else {
 			rt_cache_flush(dev_net(dev));
 		}
@@ -1157,7 +1158,7 @@ static int fib_netdev_event(struct notifier_block *this, unsigned long event, vo
 	unsigned int flags;
 
 	if (event == NETDEV_UNREGISTER) {
-		fib_disable_ip(dev, event);
+		fib_disable_ip(dev, event, true);
 		rt_flush_dev(dev);
 		return NOTIFY_DONE;
 	}
@@ -1178,14 +1179,14 @@ static int fib_netdev_event(struct notifier_block *this, unsigned long event, vo
 		rt_cache_flush(net);
 		break;
 	case NETDEV_DOWN:
-		fib_disable_ip(dev, event);
+		fib_disable_ip(dev, event, false);
 		break;
 	case NETDEV_CHANGE:
 		flags = dev_get_flags(dev);
 		if (flags & (IFF_RUNNING | IFF_LOWER_UP))
 			fib_sync_up(dev, RTNH_F_LINKDOWN);
 		else
-			fib_sync_down_dev(dev, event);
+			fib_sync_down_dev(dev, event, false);
 		/* fall through */
 	case NETDEV_CHANGEMTU:
 		rt_cache_flush(net);
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 064bd3c..2aa5b5e 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -1281,7 +1281,13 @@ int fib_sync_down_addr(struct net *net, __be32 local)
 	return ret;
 }
 
-int fib_sync_down_dev(struct net_device *dev, unsigned long event)
+/* Event              force Flags           Description
+ * NETDEV_CHANGE      0     LINKDOWN        Carrier OFF, not for scope host
+ * NETDEV_DOWN        0     LINKDOWN|DEAD   Link down, not for scope host
+ * NETDEV_DOWN        1     LINKDOWN|DEAD   Last address removed
+ * NETDEV_UNREGISTER  1     LINKDOWN|DEAD   Device removed
+ */
+int fib_sync_down_dev(struct net_device *dev, unsigned long event, bool force)
 {
 	int ret = 0;
 	int scope = RT_SCOPE_NOWHERE;
@@ -1290,8 +1296,7 @@ int fib_sync_down_dev(struct net_device *dev, unsigned long event)
 	struct hlist_head *head = &fib_info_devhash[hash];
 	struct fib_nh *nh;
 
-	if (event == NETDEV_UNREGISTER ||
-	    event == NETDEV_DOWN)
+	if (force)
 		scope = -1;
 
 	hlist_for_each_entry(nh, head, nh_hash) {
-- 
1.9.3
