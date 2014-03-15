From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 7/9] netpoll: Consolidate neigh_tx processing in service_neigh_queue
Date: Fri, 14 Mar 2014 18:36:22 -0700
Message-ID: <87a9cstf8p.fsf_-_@xmission.com>
References: <1394540961.21721.22.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140311082312.5ad00119@nehalam.linuxnetplumber.net>
	<87eh28cvi6.fsf@xmission.com>
	<20140313.152311.1995854418463980325.davem@davemloft.net>
	<87eh24uu3d.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: stephen@networkplumber.org, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:60916 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752107AbaCOBg2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 21:36:28 -0400
In-Reply-To: <87eh24uu3d.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Fri, 14 Mar 2014 18:30:14 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Move the bond slave device neigh_tx handling into service_neigh_queue.

In connection with neigh_tx processing remove unnecessary tests of
a NULL netpoll_info.  As the netpoll_poll_dev has already used
and thus verified the existince of the netpoll_info.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/core/netpoll.c |   38 ++++++++++++++++----------------------
 1 files changed, 16 insertions(+), 22 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 0e45835f1737..b69bb3f1ba3f 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -179,14 +179,23 @@ static void poll_napi(struct net_device *dev, int budget)
 	}
 }
 
-static void service_neigh_queue(struct netpoll_info *npi)
+static void service_neigh_queue(struct net_device *dev,
+				struct netpoll_info *npi)
 {
-	if (npi) {
-		struct sk_buff *skb;
-
-		while ((skb = skb_dequeue(&npi->neigh_tx)))
-			netpoll_neigh_reply(skb, npi);
+	struct sk_buff *skb;
+	if (dev->flags & IFF_SLAVE) {
+		struct net_device *bond_dev;
+		struct netpoll_info *bond_ni;
+
+		bond_dev = netdev_master_upper_dev_get_rcu(dev);
+		bond_ni = rcu_dereference_bh(bond_dev->npinfo);
+		while ((skb = skb_dequeue(&npi->neigh_tx))) {
+			skb->dev = bond_dev;
+			skb_queue_tail(&bond_ni->neigh_tx, skb);
+		}
 	}
+	while ((skb = skb_dequeue(&npi->neigh_tx)))
+		netpoll_neigh_reply(skb, npi);
 }
 
 static void netpoll_poll_dev(struct net_device *dev)
@@ -227,22 +236,7 @@ static void netpoll_poll_dev(struct net_device *dev)
 
 	up(&ni->dev_lock);
 
-	if (dev->flags & IFF_SLAVE) {
-		if (ni) {
-			struct net_device *bond_dev;
-			struct sk_buff *skb;
-			struct netpoll_info *bond_ni;
-
-			bond_dev = netdev_master_upper_dev_get_rcu(dev);
-			bond_ni = rcu_dereference_bh(bond_dev->npinfo);
-			while ((skb = skb_dequeue(&ni->neigh_tx))) {
-				skb->dev = bond_dev;
-				skb_queue_tail(&bond_ni->neigh_tx, skb);
-			}
-		}
-	}
-
-	service_neigh_queue(ni);
+	service_neigh_queue(dev, ni);
 
 	zap_completion_queue();
 }
-- 
1.7.5.4
