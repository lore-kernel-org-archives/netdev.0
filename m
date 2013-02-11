From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH v2 2/2] netpoll: cleanup sparse warnings
Date: Mon, 11 Feb 2013 15:25:31 -0500
Message-ID: <1360614331-29247-3-git-send-email-nhorman@tuxdriver.com>
References: <1360248961-30721-1-git-send-email-nhorman@tuxdriver.com>
 <1360614331-29247-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>, fengguang.wu@intel.com,
	David Miller <davem@davemloft.net>, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:35212 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932095Ab3BKU0Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2013 15:26:24 -0500
In-Reply-To: <1360614331-29247-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With my recent commit I introduced two sparse warnings.  Looking closer there
were a few more in the same file, so I fixed them all up.  Basic rcu pointer
dereferencing suff.

I've validated these changes using CONFIG_PROVE_RCU while starting and stopping
netconsole repeatedly in bonded and non-bonded configurations

Signed-offy-by: Neil Horman <nhorman@tuxdriver.com>
CC: fengguang.wu@intel.com
CC: David Miller <davem@davemloft.net>
CC: eric.dumazet@gmail.com
---
 net/core/netpoll.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index c536474..bcfd4f4 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -206,7 +206,7 @@ static void netpoll_poll_dev(struct net_device *dev)
 	 * the dev_open/close paths use this to block netpoll activity
 	 * while changing device state
 	 */
-	if (!mutex_trylock(&dev->npinfo->dev_lock))
+	if (!mutex_trylock(&ni->dev_lock))
 		return;
 
 	if (!dev || !netif_running(dev))
@@ -221,7 +221,7 @@ static void netpoll_poll_dev(struct net_device *dev)
 
 	poll_napi(dev);
 
-	mutex_unlock(&dev->npinfo->dev_lock);
+	mutex_unlock(&ni->dev_lock);
 
 	if (dev->flags & IFF_SLAVE) {
 		if (ni) {
@@ -1056,7 +1056,7 @@ int __netpoll_setup(struct netpoll *np, struct net_device *ndev, gfp_t gfp)
 				goto free_npinfo;
 		}
 	} else {
-		npinfo = ndev->npinfo;
+		npinfo = rtnl_dereference(ndev->npinfo);
 		atomic_inc(&npinfo->refcnt);
 	}
 
@@ -1236,7 +1236,11 @@ void __netpoll_cleanup(struct netpoll *np)
 	struct netpoll_info *npinfo;
 	unsigned long flags;
 
-	npinfo = np->dev->npinfo;
+	/* rtnl_dereference would be preferable here but
+	 * rcu_cleanup_netpoll path can put us in here safely without
+	 * holding the rtnl, so plain rcu_dereference it is
+	 */
+	npinfo = rtnl_dereference(np->dev->npinfo);
 	if (!npinfo)
 		return;
 
-- 
1.7.11.7
