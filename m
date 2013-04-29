From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next 2/3] bridge: only expire the mdb entry when query is received
Date: Mon, 29 Apr 2013 15:26:31 +0800
Message-ID: <1367220392-17496-2-git-send-email-amwang@redhat.com>
References: <1367220392-17496-1-git-send-email-amwang@redhat.com>
Cc: Herbert Xu <herbert@gondor.hengli.com.au>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Adam Baker <linux@baker-net.org.uk>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13129 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751899Ab3D2H1P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Apr 2013 03:27:15 -0400
In-Reply-To: <1367220392-17496-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

Currently we arm the expire timer when the mdb entry is added,
however, this causes problem when there is no querier sent
out after that.

So we should only arm the timer when a corresponding query is
received, as suggested by Herbert.

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Adam Baker <linux@baker-net.org.uk>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/bridge/br_multicast.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 6cb937c..a821a4e 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -616,8 +616,6 @@ rehash:
 
 	mp->br = br;
 	mp->addr = *group;
-	setup_timer(&mp->timer, br_multicast_group_expired,
-		    (unsigned long)mp);
 
 	hlist_add_head_rcu(&mp->hlist[mdb->ver], &mdb->mhash[hash]);
 	mdb->size++;
@@ -655,7 +653,6 @@ static int br_multicast_add_group(struct net_bridge *br,
 	struct net_bridge_mdb_entry *mp;
 	struct net_bridge_port_group *p;
 	struct net_bridge_port_group __rcu **pp;
-	unsigned long now = jiffies;
 	int err;
 
 	spin_lock(&br->multicast_lock);
@@ -670,7 +667,6 @@ static int br_multicast_add_group(struct net_bridge *br,
 
 	if (!port) {
 		mp->mglist = true;
-		mod_timer(&mp->timer, now + br->multicast_membership_interval);
 		goto out;
 	}
 
@@ -678,7 +674,7 @@ static int br_multicast_add_group(struct net_bridge *br,
 	     (p = mlock_dereference(*pp, br)) != NULL;
 	     pp = &p->next) {
 		if (p->port == port)
-			goto found;
+			goto out;
 		if ((unsigned long)p->port < (unsigned long)port)
 			break;
 	}
@@ -689,8 +685,6 @@ static int br_multicast_add_group(struct net_bridge *br,
 	rcu_assign_pointer(*pp, p);
 	br_mdb_notify(br->dev, port, group, RTM_NEWMDB);
 
-found:
-	mod_timer(&p->timer, now + br->multicast_membership_interval);
 out:
 	err = 0;
 
@@ -1130,6 +1124,9 @@ static int br_ip4_multicast_query(struct net_bridge *br,
 	if (!mp)
 		goto out;
 
+	setup_timer(&mp->timer, br_multicast_group_expired, (unsigned long)mp);
+	mod_timer(&mp->timer, now + br->multicast_membership_interval);
+
 	max_delay *= br->multicast_last_member_count;
 
 	if (mp->mglist &&
@@ -1204,6 +1201,8 @@ static int br_ip6_multicast_query(struct net_bridge *br,
 	if (!mp)
 		goto out;
 
+	setup_timer(&mp->timer, br_multicast_group_expired, (unsigned long)mp);
+	mod_timer(&mp->timer, now + br->multicast_membership_interval);
 	max_delay *= br->multicast_last_member_count;
 	if (mp->mglist &&
 	    (timer_pending(&mp->timer) ?
-- 
1.7.7.6
