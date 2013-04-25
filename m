From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v2] bridge: do not expire mdb entry as long as bridge still uses it
Date: Thu, 25 Apr 2013 16:21:23 +0800
Message-ID: <1366878083-22797-1-git-send-email-amwang@redhat.com>
Cc: Herbert Xu <herbert@gondor.hengli.com.au>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Adam Baker <linux@baker-net.org.uk>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42244 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756045Ab3DYIVx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Apr 2013 04:21:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This bug can be observed in virt environment, when a KVM guest
communicates with the host via multicast. After some time (should
be 260 sec, I didn't measure), the multicast traffic suddenly
terminates.

This is due to the mdb entry for bridge itself expires automatically,
it should not expire as long as the bridge still generates multicast
traffic. It should expire when the bridge leaves the multicast group,
OR when there is no multicast traffic on this bridge.

I fix this by adding another bool which is set when there is
multicast traffic goes to the bridge, cleared in the expire timer and
when IGMP leave is received. I ran omping for 15 minutes, everything
looks good now.

This might not be the best fix, but might be the simplest fix.

(Adam, this problem is probably different with your problem,
at least this problem can _not_ be workarounded by setting
querier to 1.)

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Adam Baker <linux@baker-net.org.uk>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
v2: rename ->busy to ->for_br

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 828e2bc..4f0e50f 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -99,9 +99,12 @@ int br_handle_frame_finish(struct sk_buff *skb)
 	else if (is_multicast_ether_addr(dest)) {
 		mdst = br_mdb_get(br, skb, vid);
 		if (mdst || BR_INPUT_SKB_CB_MROUTERS_ONLY(skb)) {
-			if ((mdst && mdst->mglist) ||
-			    br_multicast_is_router(br))
+			bool to_br = mdst && mdst->mglist;
+			if (to_br || br_multicast_is_router(br))
 				skb2 = skb;
+			/* Hold this mdb entry for bridge itself */
+			if (to_br)
+				mdst->for_br = true;
 			br_multicast_forward(mdst, skb, skb2);
 			skb = NULL;
 			if (!skb2)
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 81f2389..a86aa42 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -228,11 +228,16 @@ static void br_multicast_group_expired(unsigned long data)
 	if (!netif_running(br->dev) || timer_pending(&mp->timer))
 		goto out;
 
-	mp->mglist = false;
-
 	if (mp->ports)
 		goto out;
 
+	if (mp->mglist && mp->for_br) {
+		mp->for_br = false;
+		goto out;
+	}
+
+	mp->mglist = false;
+
 	mdb = mlock_dereference(br->mdb, br);
 
 	hlist_del_rcu(&mp->hlist[mdb->ver]);
@@ -668,7 +673,7 @@ static int br_multicast_add_group(struct net_bridge *br,
 		goto err;
 
 	if (!port) {
-		mp->mglist = true;
+		mp->mglist = mp->for_br = true;
 		mod_timer(&mp->timer, now + br->multicast_membership_interval);
 		goto out;
 	}
@@ -1280,6 +1285,7 @@ static void br_multicast_leave_group(struct net_bridge *br,
 			mod_timer(&mp->timer, time);
 		}
 
+		mp->for_br = false;
 		goto out;
 	}
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index d2c043a..c96bf19 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -112,6 +112,7 @@ struct net_bridge_mdb_entry
 	struct timer_list		timer;
 	struct br_ip			addr;
 	bool				mglist;
+	bool				for_br; /* update this only when mglist == true */
 };
 
 struct net_bridge_mdb_htable
