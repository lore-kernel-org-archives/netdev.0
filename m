From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 4/8 net-2.6.25] [ARP] Remove overkill checks from neigh_param_alloc.
Date: Mon, 14 Jan 2008 17:59:57 +0300
Message-ID: <1200322801-19054-4-git-send-email-den@openvz.org>
References: <478B78CB.4030404@openvz.org>
Cc: netdev@vger.kernel.org, devel@openvz.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:65496 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750963AbYANPAB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2008 10:00:01 -0500
In-Reply-To: <478B78CB.4030404@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Valid network device is always passed into neigh_param_alloc, so remove
extra checking for dev == NULL. Additionally, cleanup bogus netns assignment.

Signed-off-by: Denis V. Lunev <den@openvz.org>
Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 net/core/neighbour.c |   18 +++++++-----------
 1 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index af49137..32f1a23 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1301,10 +1301,7 @@ struct neigh_parms *neigh_parms_alloc(struct net_device *dev,
 	struct neigh_parms *p, *ref;
 	struct net *net;
 
-	net = &init_net;
-	if (dev)
-		net = dev->nd_net;
-
+	net = dev->nd_net;
 	ref = lookup_neigh_params(tbl, net, 0);
 	if (!ref)
 		return NULL;
@@ -1316,15 +1313,14 @@ struct neigh_parms *neigh_parms_alloc(struct net_device *dev,
 		INIT_RCU_HEAD(&p->rcu_head);
 		p->reachable_time =
 				neigh_rand_reach_time(p->base_reachable_time);
-		if (dev) {
-			if (dev->neigh_setup && dev->neigh_setup(dev, p)) {
-				kfree(p);
-				return NULL;
-			}
 
-			dev_hold(dev);
-			p->dev = dev;
+		if (dev->neigh_setup && dev->neigh_setup(dev, p)) {
+			kfree(p);
+			return NULL;
 		}
+
+		dev_hold(dev);
+		p->dev = dev;
 		p->net = hold_net(net);
 		p->sysctl_table = NULL;
 		write_lock_bh(&tbl->lock);
-- 
1.5.3.rc5

