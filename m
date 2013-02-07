From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] netpoll: cleanup sparse warnings
Date: Thu,  7 Feb 2013 09:56:01 -0500
Message-ID: <1360248961-30721-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>, fengguang.wu@intel.com,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:41208 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754000Ab3BGO4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2013 09:56:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With my recent commit I introduced two sparse warnings.  Looking closer there
were a few more in the same file, so I fixed them all up.  Basic rcu pointer
dereferencing suff

Signed-offy-by: Neil Horman <nhorman@tuxdriver.com>
CC: fengguang.wu@intel.com
CC: David Miller <davem@davemloft.net>
---
 net/core/netpoll.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index edcd9ad..1c829c0 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -205,7 +205,7 @@ static void netpoll_poll_dev(struct net_device *dev)
 	 * the dev_open/close paths use this to block netpoll activity
 	 * while changing device state
 	 */
-	if (!mutex_trylock(&dev->npinfo->dev_lock))
+	if (!mutex_trylock(&ni->dev_lock))
 		return;
 
 	if (!dev || !netif_running(dev))
@@ -220,7 +220,7 @@ static void netpoll_poll_dev(struct net_device *dev)
 
 	poll_napi(dev);
 
-	mutex_unlock(&dev->npinfo->dev_lock);
+	mutex_unlock(&ni->dev_lock);
 
 	if (dev->flags & IFF_SLAVE) {
 		if (ni) {
@@ -1054,7 +1054,7 @@ int __netpoll_setup(struct netpoll *np, struct net_device *ndev, gfp_t gfp)
 				goto free_npinfo;
 		}
 	} else {
-		npinfo = ndev->npinfo;
+		npinfo = rtnl_dereference(ndev->npinfo);
 		atomic_inc(&npinfo->refcnt);
 	}
 
@@ -1234,7 +1234,11 @@ void __netpoll_cleanup(struct netpoll *np)
 	struct netpoll_info *npinfo;
 	unsigned long flags;
 
-	npinfo = np->dev->npinfo;
+	/* rtnl_dereference would be preferable here but
+	 * rcu_cleanup_netpoll path can put us in here safely without
+	 * holding the rtnl, so plain rcu_dereference it is
+	 */
+	npinfo = rcu_dereference(np->dev->npinfo);
 	if (!npinfo)
 		return;
 
-- 
1.7.11.7
