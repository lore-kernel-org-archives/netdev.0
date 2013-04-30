From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v3 2/3] bridge: only expire the mdb entry when query is received
Date: Tue, 30 Apr 2013 15:10:18 +0800
Message-ID: <1367305819-14013-2-git-send-email-amwang@redhat.com>
References: <1367305819-14013-1-git-send-email-amwang@redhat.com>
Cc: Herbert Xu <herbert@gondor.hengli.com.au>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Adam Baker <linux@baker-net.org.uk>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9911 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753270Ab3D3HKv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Apr 2013 03:10:51 -0400
In-Reply-To: <1367305819-14013-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

Currently we arm the expire timer when the mdb entry is added,
however, this causes problem when there is no querier sent
out after that.

So we should only arm the timer when a corresponding query is
received, as suggested by Herbert.

And "if there is no querier then group subscriptions shouldn't expire.
There has to be at least one querier in the network for this thing to
work.  Otherwise it just degenerates into a non-snooping switch,
which is OK."

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Adam Baker <linux@baker-net.org.uk>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
v3: fix the code in br_multicast_leave_group()
v2: add a flag to check if timer is fired or not

 net/bridge/br_multicast.c |   21 ++++++++++++---------
 net/bridge/br_private.h   |    1 +
 2 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index c52d4f3..6a05522 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -617,8 +617,6 @@ rehash:
 
 	mp->br = br;
 	mp->addr = *group;
-	setup_timer(&mp->timer, br_multicast_group_expired,
-		    (unsigned long)mp);
 
 	hlist_add_head_rcu(&mp->hlist[mdb->ver], &mdb->mhash[hash]);
 	mdb->size++;
@@ -656,7 +654,6 @@ static int br_multicast_add_group(struct net_bridge *br,
 	struct net_bridge_mdb_entry *mp;
 	struct net_bridge_port_group *p;
 	struct net_bridge_port_group __rcu **pp;
-	unsigned long now = jiffies;
 	int err;
 
 	spin_lock(&br->multicast_lock);
@@ -671,7 +668,6 @@ static int br_multicast_add_group(struct net_bridge *br,
 
 	if (!port) {
 		mp->mglist = true;
-		mod_timer(&mp->timer, now + br->multicast_membership_interval);
 		goto out;
 	}
 
@@ -679,7 +675,7 @@ static int br_multicast_add_group(struct net_bridge *br,
 	     (p = mlock_dereference(*pp, br)) != NULL;
 	     pp = &p->next) {
 		if (p->port == port)
-			goto found;
+			goto out;
 		if ((unsigned long)p->port < (unsigned long)port)
 			break;
 	}
@@ -690,8 +686,6 @@ static int br_multicast_add_group(struct net_bridge *br,
 	rcu_assign_pointer(*pp, p);
 	br_mdb_notify(br->dev, port, group, RTM_NEWMDB);
 
-found:
-	mod_timer(&p->timer, now + br->multicast_membership_interval);
 out:
 	err = 0;
 
@@ -1131,6 +1125,10 @@ static int br_ip4_multicast_query(struct net_bridge *br,
 	if (!mp)
 		goto out;
 
+	setup_timer(&mp->timer, br_multicast_group_expired, (unsigned long)mp);
+	mod_timer(&mp->timer, now + br->multicast_membership_interval);
+	mp->timer_armed = true;
+
 	max_delay *= br->multicast_last_member_count;
 
 	if (mp->mglist &&
@@ -1205,6 +1203,10 @@ static int br_ip6_multicast_query(struct net_bridge *br,
 	if (!mp)
 		goto out;
 
+	setup_timer(&mp->timer, br_multicast_group_expired, (unsigned long)mp);
+	mod_timer(&mp->timer, now + br->multicast_membership_interval);
+	mp->timer_armed = true;
+
 	max_delay *= br->multicast_last_member_count;
 	if (mp->mglist &&
 	    (timer_pending(&mp->timer) ?
@@ -1263,7 +1265,7 @@ static void br_multicast_leave_group(struct net_bridge *br,
 			call_rcu_bh(&p->rcu, br_multicast_free_pg);
 			br_mdb_notify(br->dev, port, group, RTM_DELMDB);
 
-			if (!mp->ports && !mp->mglist &&
+			if (!mp->ports && !mp->mglist && mp->timer_armed &&
 			    netif_running(br->dev))
 				mod_timer(&mp->timer, jiffies);
 		}
@@ -1275,7 +1277,7 @@ static void br_multicast_leave_group(struct net_bridge *br,
 		     br->multicast_last_member_interval;
 
 	if (!port) {
-		if (mp->mglist &&
+		if (mp->mglist && mp->timer_armed &&
 		    (timer_pending(&mp->timer) ?
 		     time_after(mp->timer.expires, time) :
 		     try_to_del_timer_sync(&mp->timer) >= 0)) {
@@ -1674,6 +1676,7 @@ void br_multicast_stop(struct net_bridge *br)
 		hlist_for_each_entry_safe(mp, n, &mdb->mhash[i],
 					  hlist[ver]) {
 			del_timer(&mp->timer);
+			mp->timer_armed = false;
 			call_rcu_bh(&mp->rcu, br_multicast_free_group);
 		}
 	}
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 695033f..cd2552c 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -112,6 +112,7 @@ struct net_bridge_mdb_entry
 	struct timer_list		timer;
 	struct br_ip			addr;
 	bool				mglist;
+	bool				timer_armed;
 };
 
 struct net_bridge_mdb_htable
-- 
1.7.7.6
