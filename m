From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: bridge: Do not send queries on multicast group leaves
Date: Wed, 4 Apr 2012 19:01:20 +0800
Message-ID: <20120404110119.GA11576@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sting.hengli.com.au ([178.18.18.71]:34604 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932067Ab2DDLBY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 07:01:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

bridge: Do not send queries on multicast group leaves

As it stands the bridge IGMP snooping system will respond to
group leave messages with queries for remaining membership.
This is both unnecessary and undesirable.  First of all any
multicast routers present should be doing this rather than us.
What's more the queries that we send may end up upsetting other
multicast snooping swithces in the system that are buggy.

In fact, we can simply remove the code that send these queries
because the existing membership expiry mechanism doesn't rely
on them anyway.

So this patch simply removes all code associated with group
queries in response to group leave messages.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>


diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 702a1ae..27ca25e 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -241,7 +241,6 @@ static void br_multicast_group_expired(unsigned long data)
 	hlist_del_rcu(&mp->hlist[mdb->ver]);
 	mdb->size--;
 
-	del_timer(&mp->query_timer);
 	call_rcu_bh(&mp->rcu, br_multicast_free_group);
 
 out:
@@ -271,7 +270,6 @@ static void br_multicast_del_pg(struct net_bridge *br,
 		rcu_assign_pointer(*pp, p->next);
 		hlist_del_init(&p->mglist);
 		del_timer(&p->timer);
-		del_timer(&p->query_timer);
 		call_rcu_bh(&p->rcu, br_multicast_free_pg);
 
 		if (!mp->ports && !mp->mglist &&
@@ -507,74 +505,6 @@ static struct sk_buff *br_multicast_alloc_query(struct net_bridge *br,
 	return NULL;
 }
 
-static void br_multicast_send_group_query(struct net_bridge_mdb_entry *mp)
-{
-	struct net_bridge *br = mp->br;
-	struct sk_buff *skb;
-
-	skb = br_multicast_alloc_query(br, &mp->addr);
-	if (!skb)
-		goto timer;
-
-	netif_rx(skb);
-
-timer:
-	if (++mp->queries_sent < br->multicast_last_member_count)
-		mod_timer(&mp->query_timer,
-			  jiffies + br->multicast_last_member_interval);
-}
-
-static void br_multicast_group_query_expired(unsigned long data)
-{
-	struct net_bridge_mdb_entry *mp = (void *)data;
-	struct net_bridge *br = mp->br;
-
-	spin_lock(&br->multicast_lock);
-	if (!netif_running(br->dev) || !mp->mglist ||
-	    mp->queries_sent >= br->multicast_last_member_count)
-		goto out;
-
-	br_multicast_send_group_query(mp);
-
-out:
-	spin_unlock(&br->multicast_lock);
-}
-
-static void br_multicast_send_port_group_query(struct net_bridge_port_group *pg)
-{
-	struct net_bridge_port *port = pg->port;
-	struct net_bridge *br = port->br;
-	struct sk_buff *skb;
-
-	skb = br_multicast_alloc_query(br, &pg->addr);
-	if (!skb)
-		goto timer;
-
-	br_deliver(port, skb);
-
-timer:
-	if (++pg->queries_sent < br->multicast_last_member_count)
-		mod_timer(&pg->query_timer,
-			  jiffies + br->multicast_last_member_interval);
-}
-
-static void br_multicast_port_group_query_expired(unsigned long data)
-{
-	struct net_bridge_port_group *pg = (void *)data;
-	struct net_bridge_port *port = pg->port;
-	struct net_bridge *br = port->br;
-
-	spin_lock(&br->multicast_lock);
-	if (!netif_running(br->dev) || hlist_unhashed(&pg->mglist) ||
-	    pg->queries_sent >= br->multicast_last_member_count)
-		goto out;
-
-	br_multicast_send_port_group_query(pg);
-
-out:
-	spin_unlock(&br->multicast_lock);
-}
-
 static struct net_bridge_mdb_entry *br_multicast_get_group(
 	struct net_bridge *br, struct net_bridge_port *port,
 	struct br_ip *group, int hash)
@@ -690,8 +620,6 @@ rehash:
 	mp->addr = *group;
 	setup_timer(&mp->timer, br_multicast_group_expired,
 		    (unsigned long)mp);
-	setup_timer(&mp->query_timer, br_multicast_group_query_expired,
-		    (unsigned long)mp);
 
 	hlist_add_head_rcu(&mp->hlist[mdb->ver], &mdb->mhash[hash]);
 	mdb->size++;
@@ -746,8 +674,6 @@ static int br_multicast_add_group(struct net_bridge *br,
 	hlist_add_head(&p->mglist, &port->mglist);
 	setup_timer(&p->timer, br_multicast_port_group_expired,
 		    (unsigned long)p);
-	setup_timer(&p->query_timer, br_multicast_port_group_query_expired,
-		    (unsigned long)p);
 
 	rcu_assign_pointer(*pp, p);
 
@@ -1291,9 +1217,6 @@ static void br_multicast_leave_group(struct net_bridge *br,
 		     time_after(mp->timer.expires, time) :
 		     try_to_del_timer_sync(&mp->timer) >= 0)) {
 			mod_timer(&mp->timer, time);
-
-			mp->queries_sent = 0;
-			mod_timer(&mp->query_timer, now);
 		}
 
 		goto out;
@@ -1310,9 +1233,6 @@ static void br_multicast_leave_group(struct net_bridge *br,
 		     time_after(p->timer.expires, time) :
 		     try_to_del_timer_sync(&p->timer) >= 0)) {
 			mod_timer(&p->timer, time);
-
-			p->queries_sent = 0;
-			mod_timer(&p->query_timer, now);
 		}
 
 		break;
@@ -1681,7 +1601,6 @@ void br_multicast_stop(struct net_bridge *br)
 		hlist_for_each_entry_safe(mp, p, n, &mdb->mhash[i],
 					  hlist[ver]) {
 			del_timer(&mp->timer);
-			del_timer(&mp->query_timer);
 			call_rcu_bh(&mp->rcu, br_multicast_free_group);
 		}
 	}
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 0b67a63..e1d8822 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -82,9 +82,7 @@ struct net_bridge_port_group {
 	struct hlist_node		mglist;
 	struct rcu_head			rcu;
 	struct timer_list		timer;
-	struct timer_list		query_timer;
 	struct br_ip			addr;
-	u32				queries_sent;
 };
 
 struct net_bridge_mdb_entry
@@ -94,10 +92,8 @@ struct net_bridge_mdb_entry
 	struct net_bridge_port_group __rcu *ports;
 	struct rcu_head			rcu;
 	struct timer_list		timer;
-	struct timer_list		query_timer;
 	struct br_ip			addr;
 	bool				mglist;
-	u32				queries_sent;
 };
 
 struct net_bridge_mdb_htable
Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
