From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v2 rfc 1/8] net: bridge: Rename mglist to host_joined
Date: Wed,  6 Sep 2017 01:35:03 +0200
Message-ID: <1504654510-31004-2-git-send-email-andrew@lunn.ch>
References: <1504654510-31004-1-git-send-email-andrew@lunn.ch>
Cc: jiri@resnulli.us, nikolay@cumulusnetworks.com,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58249 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753652AbdIEXkC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 5 Sep 2017 19:40:02 -0400
In-Reply-To: <1504654510-31004-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The boolean mglist indicates the host has joined a particular
multicast group on the bridge interface. It is badly named, obscuring
what is means. Rename it.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 net/bridge/br_input.c     |  2 +-
 net/bridge/br_mdb.c       |  2 +-
 net/bridge/br_multicast.c | 14 +++++++-------
 net/bridge/br_private.h   |  2 +-
 4 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 7637f58c1226..0dd55a183391 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -179,7 +179,7 @@ int br_handle_frame_finish(struct net *net, struct sock *sk, struct sk_buff *skb
 		mdst = br_mdb_get(br, skb, vid);
 		if ((mdst || BR_INPUT_SKB_CB_MROUTERS_ONLY(skb)) &&
 		    br_multicast_querier_exists(br, eth_hdr(skb))) {
-			if ((mdst && mdst->mglist) ||
+			if ((mdst && mdst->host_joined) ||
 			    br_multicast_is_router(br)) {
 				local_rcv = true;
 				br->dev->stats.multicast++;
diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index ca01def49af0..71885e251988 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -654,7 +654,7 @@ static int __br_mdb_del(struct net_bridge *br, struct br_mdb_entry *entry)
 		call_rcu_bh(&p->rcu, br_multicast_free_pg);
 		err = 0;
 
-		if (!mp->ports && !mp->mglist &&
+		if (!mp->ports && !mp->host_joined &&
 		    netif_running(br->dev))
 			mod_timer(&mp->timer, jiffies);
 		break;
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 8dc5c8d69bcd..c6b2b8d419e7 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -249,7 +249,7 @@ static void br_multicast_group_expired(unsigned long data)
 	if (!netif_running(br->dev) || timer_pending(&mp->timer))
 		goto out;
 
-	mp->mglist = false;
+	mp->host_joined = false;
 
 	if (mp->ports)
 		goto out;
@@ -292,7 +292,7 @@ static void br_multicast_del_pg(struct net_bridge *br,
 			      p->flags);
 		call_rcu_bh(&p->rcu, br_multicast_free_pg);
 
-		if (!mp->ports && !mp->mglist &&
+		if (!mp->ports && !mp->host_joined &&
 		    netif_running(br->dev))
 			mod_timer(&mp->timer, jiffies);
 
@@ -775,7 +775,7 @@ static int br_multicast_add_group(struct net_bridge *br,
 		goto err;
 
 	if (!port) {
-		mp->mglist = true;
+		mp->host_joined = true;
 		mod_timer(&mp->timer, now + br->multicast_membership_interval);
 		goto out;
 	}
@@ -1451,7 +1451,7 @@ static int br_ip4_multicast_query(struct net_bridge *br,
 
 	max_delay *= br->multicast_last_member_count;
 
-	if (mp->mglist &&
+	if (mp->host_joined &&
 	    (timer_pending(&mp->timer) ?
 	     time_after(mp->timer.expires, now + max_delay) :
 	     try_to_del_timer_sync(&mp->timer) >= 0))
@@ -1535,7 +1535,7 @@ static int br_ip6_multicast_query(struct net_bridge *br,
 		goto out;
 
 	max_delay *= br->multicast_last_member_count;
-	if (mp->mglist &&
+	if (mp->host_joined &&
 	    (timer_pending(&mp->timer) ?
 	     time_after(mp->timer.expires, now + max_delay) :
 	     try_to_del_timer_sync(&mp->timer) >= 0))
@@ -1596,7 +1596,7 @@ br_multicast_leave_group(struct net_bridge *br,
 			br_mdb_notify(br->dev, port, group, RTM_DELMDB,
 				      p->flags);
 
-			if (!mp->ports && !mp->mglist &&
+			if (!mp->ports && !mp->host_joined &&
 			    netif_running(br->dev))
 				mod_timer(&mp->timer, jiffies);
 		}
@@ -1636,7 +1636,7 @@ br_multicast_leave_group(struct net_bridge *br,
 		     br->multicast_last_member_interval;
 
 	if (!port) {
-		if (mp->mglist &&
+		if (mp->host_joined &&
 		    (timer_pending(&mp->timer) ?
 		     time_after(mp->timer.expires, time) :
 		     try_to_del_timer_sync(&mp->timer) >= 0)) {
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index fd9ee73e0a6d..e79e0611908d 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -202,7 +202,7 @@ struct net_bridge_mdb_entry
 	struct rcu_head			rcu;
 	struct timer_list		timer;
 	struct br_ip			addr;
-	bool				mglist;
+	bool				host_joined;
 };
 
 struct net_bridge_mdb_htable
-- 
2.14.1
