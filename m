From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [PATCH 2/2] ipv4: factorize cache clearing for batched unregister operations
Date: Tue, 17 Nov 2009 01:49:49 +0200
Message-ID: <200911170149.50011.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:3519 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754582AbZKPXwv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 18:52:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---
 net/ipv4/fib_frontend.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 816e218..6c1e56a 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -895,11 +895,11 @@ static void nl_fib_lookup_exit(struct net *net)
 	net->ipv4.fibnl = NULL;
 }
 
-static void fib_disable_ip(struct net_device *dev, int force)
+static void fib_disable_ip(struct net_device *dev, int force, int delay)
 {
 	if (fib_sync_down_dev(dev, force))
 		fib_flush(dev_net(dev));
-	rt_cache_flush(dev_net(dev), 0);
+	rt_cache_flush(dev_net(dev), delay);
 	arp_ifdown(dev);
 }
 
@@ -922,7 +922,7 @@ static int fib_inetaddr_event(struct notifier_block *this, unsigned long event,
 			/* Last address was deleted from this interface.
 			   Disable IP.
 			 */
-			fib_disable_ip(dev, 1);
+			fib_disable_ip(dev, 1, 0);
 		} else {
 			rt_cache_flush(dev_net(dev), -1);
 		}
@@ -937,7 +937,7 @@ static int fib_netdev_event(struct notifier_block *this, unsigned long event, vo
 	struct in_device *in_dev = __in_dev_get_rtnl(dev);
 
 	if (event == NETDEV_UNREGISTER) {
-		fib_disable_ip(dev, 2);
+		fib_disable_ip(dev, 2, -1);
 		return NOTIFY_DONE;
 	}
 
@@ -955,10 +955,11 @@ static int fib_netdev_event(struct notifier_block *this, unsigned long event, vo
 		rt_cache_flush(dev_net(dev), -1);
 		break;
 	case NETDEV_DOWN:
-		fib_disable_ip(dev, 0);
+		fib_disable_ip(dev, 0, 0);
 		break;
 	case NETDEV_CHANGEMTU:
 	case NETDEV_CHANGE:
+	case NETDEV_UNREGISTER_PERNET:
 		rt_cache_flush(dev_net(dev), 0);
 		break;
 	}
-- 
1.5.6.5

