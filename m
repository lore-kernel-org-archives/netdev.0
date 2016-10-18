From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net v2] bridge: multicast: restore perm router ports on multicast enable
Date: Tue, 18 Oct 2016 18:09:48 +0200
Message-ID: <1476806988-20557-1-git-send-email-nikolay@cumulusnetworks.com>
References: <1476796238-9384-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: sashok@cumulusnetworks.com, roopa@cumulusnetworks.com,
        herbert@gondor.apana.org.au, stephen@networkplumber.org,
        davem@davemloft.net,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:33158 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1030230AbcJRQJ5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 12:09:57 -0400
Received: by mail-wm0-f54.google.com with SMTP id g16so308723wmg.0
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2016 09:09:56 -0700 (PDT)
In-Reply-To: <1476796238-9384-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Satish reported a problem with the perm multicast router ports not getting
reenabled after some series of events, in particular if it happens that the
multicast snooping has been disabled and the port goes to disabled state
then it will be deleted from the router port list, but if it moves into
non-disabled state it will not be re-added because the mcast snooping is
still disabled, and enabling snooping later does nothing.

Here are the steps to reproduce, setup br0 with snooping enabled and eth1
added as a perm router (multicast_router = 2):
1. $ echo 0 > /sys/class/net/br0/bridge/multicast_snooping
2. $ ip l set eth1 down
^ This step deletes the interface from the router list
3. $ ip l set eth1 up
^ This step does not add it again because mcast snooping is disabled
4. $ echo 1 > /sys/class/net/br0/bridge/multicast_snooping
5. $ bridge -d -s mdb show
<empty>

At this point we have mcast enabled and eth1 as a perm router (value = 2)
but it is not in the router list which is incorrect.

After this change:
1. $ echo 0 > /sys/class/net/br0/bridge/multicast_snooping
2. $ ip l set eth1 down
^ This step deletes the interface from the router list
3. $ ip l set eth1 up
^ This step does not add it again because mcast snooping is disabled
4. $ echo 1 > /sys/class/net/br0/bridge/multicast_snooping
5. $ bridge -d -s mdb show
router ports on br0: eth1

Note: we can directly do br_multicast_enable_port for all because the
querier timer already has checks for the port state and will simply
expire if it's in blocking/disabled. See the comment added by
commit 9aa66382163e7 ("bridge: multicast: add a comment to
br_port_state_selection about blocking state")

Fixes: 561f1103a2b7 ("bridge: Add multicast_snooping sysfs toggle")
Reported-by: Satish Ashok <sashok@cumulusnetworks.com>
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
v2: just call br_multicast_enable_port for all ports and use
br_multicast_open

 net/bridge/br_multicast.c | 23 ++++++++++++++---------
 1 file changed, 14 insertions(+), 9 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index c5fea9393946..2136e45f5277 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -972,13 +972,12 @@ static void br_multicast_enable(struct bridge_mcast_own_query *query)
 		mod_timer(&query->timer, jiffies);
 }
 
-void br_multicast_enable_port(struct net_bridge_port *port)
+static void __br_multicast_enable_port(struct net_bridge_port *port)
 {
 	struct net_bridge *br = port->br;
 
-	spin_lock(&br->multicast_lock);
 	if (br->multicast_disabled || !netif_running(br->dev))
-		goto out;
+		return;
 
 	br_multicast_enable(&port->ip4_own_query);
 #if IS_ENABLED(CONFIG_IPV6)
@@ -987,8 +986,14 @@ void br_multicast_enable_port(struct net_bridge_port *port)
 	if (port->multicast_router == MDB_RTR_TYPE_PERM &&
 	    hlist_unhashed(&port->rlist))
 		br_multicast_add_router(br, port);
+}
 
-out:
+void br_multicast_enable_port(struct net_bridge_port *port)
+{
+	struct net_bridge *br = port->br;
+
+	spin_lock(&br->multicast_lock);
+	__br_multicast_enable_port(port);
 	spin_unlock(&br->multicast_lock);
 }
 
@@ -1994,8 +1999,9 @@ static void br_multicast_start_querier(struct net_bridge *br,
 
 int br_multicast_toggle(struct net_bridge *br, unsigned long val)
 {
-	int err = 0;
 	struct net_bridge_mdb_htable *mdb;
+	struct net_bridge_port *port;
+	int err = 0;
 
 	spin_lock_bh(&br->multicast_lock);
 	if (br->multicast_disabled == !val)
@@ -2023,10 +2029,9 @@ int br_multicast_toggle(struct net_bridge *br, unsigned long val)
 			goto rollback;
 	}
 
-	br_multicast_start_querier(br, &br->ip4_own_query);
-#if IS_ENABLED(CONFIG_IPV6)
-	br_multicast_start_querier(br, &br->ip6_own_query);
-#endif
+	br_multicast_open(br);
+	list_for_each_entry(port, &br->port_list, list)
+		__br_multicast_enable_port(port);
 
 unlock:
 	spin_unlock_bh(&br->multicast_lock);
-- 
2.1.4
