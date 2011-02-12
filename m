From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: bridge: Fix mglist corruption that leads to memory corruption
Date: Sat, 12 Feb 2011 17:05:38 +1100
Message-ID: <20110212060538.GA911@gondor.apana.org.au>
References: <20110211223655.GA5585@gondor.apana.org.au> <20110211225559.GA5922@gondor.apana.org.au> <20110211.215804.15260765.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ihands@redhat.com, jbacik@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:35494 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751097Ab1BLGFm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Feb 2011 01:05:42 -0500
Content-Disposition: inline
In-Reply-To: <20110211.215804.15260765.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 11, 2011 at 09:58:04PM -0800, David Miller wrote:
>
> Well if it's a bool, please use "true" and "false" instead of "1" and
> "0" :-)

Serves me right for trying to be green :)

bridge: Replace mp->mglist hlist with a bool

As it turns out we never need to walk through the list of multicast
groups subscribed by the bridge interface itself (the only time we'd
want to do that is when we shut down the bridge, in which case we
simply walk through all multicast groups), we don't really need to
keep an hlist for mp->mglist.

This means that we can replace it with just a single bit to indicate
whether the bridge interface is subscribed to a group.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 6f6d8e1..88e4aa9 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -80,7 +80,7 @@ int br_handle_frame_finish(struct sk_buff *skb)
 	if (is_multicast_ether_addr(dest)) {
 		mdst = br_mdb_get(br, skb);
 		if (mdst || BR_INPUT_SKB_CB_MROUTERS_ONLY(skb)) {
-			if ((mdst && !hlist_unhashed(&mdst->mglist)) ||
+			if ((mdst && mdst->mglist) ||
 			    br_multicast_is_router(br))
 				skb2 = skb;
 			br_multicast_forward(mdst, skb, skb2);
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index c558274..30e3a08 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -232,8 +232,7 @@ static void br_multicast_group_expired(unsigned long data)
 	if (!netif_running(br->dev) || timer_pending(&mp->timer))
 		goto out;
 
-	if (!hlist_unhashed(&mp->mglist))
-		hlist_del_init(&mp->mglist);
+	mp->mglist = false;
 
 	if (mp->ports)
 		goto out;
@@ -276,7 +275,7 @@ static void br_multicast_del_pg(struct net_bridge *br,
 		del_timer(&p->query_timer);
 		call_rcu_bh(&p->rcu, br_multicast_free_pg);
 
-		if (!mp->ports && hlist_unhashed(&mp->mglist) &&
+		if (!mp->ports && !mp->mglist &&
 		    netif_running(br->dev))
 			mod_timer(&mp->timer, jiffies);
 
@@ -528,7 +527,7 @@ static void br_multicast_group_query_expired(unsigned long data)
 	struct net_bridge *br = mp->br;
 
 	spin_lock(&br->multicast_lock);
-	if (!netif_running(br->dev) || hlist_unhashed(&mp->mglist) ||
+	if (!netif_running(br->dev) || !mp->mglist ||
 	    mp->queries_sent >= br->multicast_last_member_count)
 		goto out;
 
@@ -719,8 +718,7 @@ static int br_multicast_add_group(struct net_bridge *br,
 		goto err;
 
 	if (!port) {
-		if (hlist_unhashed(&mp->mglist))
-			hlist_add_head(&mp->mglist, &br->mglist);
+		mp->mglist = true;
 		mod_timer(&mp->timer, now + br->multicast_membership_interval);
 		goto out;
 	}
@@ -1166,7 +1164,7 @@ static int br_ip4_multicast_query(struct net_bridge *br,
 
 	max_delay *= br->multicast_last_member_count;
 
-	if (!hlist_unhashed(&mp->mglist) &&
+	if (mp->mglist &&
 	    (timer_pending(&mp->timer) ?
 	     time_after(mp->timer.expires, now + max_delay) :
 	     try_to_del_timer_sync(&mp->timer) >= 0))
@@ -1237,7 +1235,7 @@ static int br_ip6_multicast_query(struct net_bridge *br,
 		goto out;
 
 	max_delay *= br->multicast_last_member_count;
-	if (!hlist_unhashed(&mp->mglist) &&
+	if (mp->mglist &&
 	    (timer_pending(&mp->timer) ?
 	     time_after(mp->timer.expires, now + max_delay) :
 	     try_to_del_timer_sync(&mp->timer) >= 0))
@@ -1284,7 +1282,7 @@ static void br_multicast_leave_group(struct net_bridge *br,
 		     br->multicast_last_member_interval;
 
 	if (!port) {
-		if (!hlist_unhashed(&mp->mglist) &&
+		if (mp->mglist &&
 		    (timer_pending(&mp->timer) ?
 		     time_after(mp->timer.expires, time) :
 		     try_to_del_timer_sync(&mp->timer) >= 0)) {
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 84aac77..4e1b620 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -84,13 +84,13 @@ struct net_bridge_port_group {
 struct net_bridge_mdb_entry
 {
 	struct hlist_node		hlist[2];
-	struct hlist_node		mglist;
 	struct net_bridge		*br;
 	struct net_bridge_port_group __rcu *ports;
 	struct rcu_head			rcu;
 	struct timer_list		timer;
 	struct timer_list		query_timer;
 	struct br_ip			addr;
+	bool				mglist;
 	u32				queries_sent;
 };
 
@@ -238,7 +238,6 @@ struct net_bridge
 	spinlock_t			multicast_lock;
 	struct net_bridge_mdb_htable __rcu *mdb;
 	struct hlist_head		router_list;
-	struct hlist_head		mglist;
 
 	struct timer_list		multicast_router_timer;
 	struct timer_list		multicast_querier_timer;

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
