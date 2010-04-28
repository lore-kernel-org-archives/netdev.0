From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 3/4] bridge: multicast port group RCU fix
Date: Tue, 27 Apr 2010 18:01:06 -0700
Message-ID: <20100428010336.237294971@vyatta.com>
References: <20100428010103.386761596@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:46581 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751396Ab0D1BHM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Apr 2010 21:07:12 -0400
Content-Disposition: inline; filename=br-portlist-rcu.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The recently introduced bridge mulitcast port group list was only
partially using RCU correctly. It was missing rcu_dereference()
and missing the necessary barrier on deletion.

The code should have used one of the standard list methods (list or hlist)
instead of open coding a RCU based link list.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/bridge/br_forward.c	2010-04-27 17:51:27.909588950 -0700
+++ b/net/bridge/br_forward.c	2010-04-27 17:53:18.790721091 -0700
@@ -217,7 +217,7 @@ static void br_multicast_flood(struct ne
 	prev = NULL;
 
 	rp = rcu_dereference(br->router_list.first);
-	p = mdst ? mdst->ports : NULL;
+	p = mdst ? rcu_dereference(mdst->ports) : NULL;
 	while (p || rp) {
 		lport = p ? p->port : NULL;
 		rport = rp ? hlist_entry(rp, struct net_bridge_port, rlist) :
@@ -231,7 +231,7 @@ static void br_multicast_flood(struct ne
 			goto out;
 
 		if ((unsigned long)lport >= (unsigned long)port)
-			p = p->next;
+			p = rcu_dereference(p->next);
 		if ((unsigned long)rport >= (unsigned long)port)
 			rp = rcu_dereference(rp->next);
 	}
--- a/net/bridge/br_multicast.c	2010-04-27 17:51:31.509593914 -0700
+++ b/net/bridge/br_multicast.c	2010-04-27 17:52:48.209243982 -0700
@@ -259,7 +259,7 @@ static void br_multicast_del_pg(struct n
 		if (p != pg)
 			continue;
 
-		*pp = p->next;
+		rcu_assign_pointer(*pp, p->next);
 		hlist_del_init(&p->mglist);
 		del_timer(&p->timer);
 		del_timer(&p->query_timer);

-- 

