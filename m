From: sthemmin@exchange.microsoft.com
Subject: [PATCH 01/14] hv_netvsc: fix rtnl locking in callback
Date: Tue, 23 Aug 2016 12:17:44 -0700
Message-ID: <1471979877-17802-1-git-send-email-sthemmin@exchange.microsoft.com>
Reply-To: sthemmin@microsoft.com
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: "K. Y. Srinivasan" <kys@microsoft.com>,
        Haiyang Zhang <haiyangz@microsoft.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtps2ded04.prod.phx3.secureserver.net ([208.109.80.198]:38276
        "EHLO p3plsmtps2ded04.prod.phx3.secureserver.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752298AbcHWSH4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 Aug 2016 14:07:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <sthemmin@microsoft.com>

The function get_netvsc_net_device had conditional locking. This was
unnecessary, incorrect, but harmless. It was unnecessary since the
code is only called from netlink netdev event callback where RTNL
is always acquired before the callbacks are run. It was incorrect
because of use of trylock and then continuing.
Fix by replacing with proper assertion.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index eb2c122..6924d01a 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -1167,9 +1167,8 @@ static void netvsc_free_netdev(struct net_device *netdev)
 static struct net_device *get_netvsc_net_device(char *mac)
 {
 	struct net_device *dev, *found = NULL;
-	int rtnl_locked;
 
-	rtnl_locked = rtnl_trylock();
+	ASSERT_RTNL();
 
 	for_each_netdev(&init_net, dev) {
 		if (memcmp(dev->dev_addr, mac, ETH_ALEN) == 0) {
@@ -1179,8 +1178,6 @@ static struct net_device *get_netvsc_net_device(char *mac)
 			break;
 		}
 	}
-	if (rtnl_locked)
-		rtnl_unlock();
 
 	return found;
 }
-- 
2.9.3
