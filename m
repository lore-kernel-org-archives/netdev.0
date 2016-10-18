From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net] bridge: multicast: restore perm router ports on multicast enable
Date: Tue, 18 Oct 2016 15:10:38 +0200
Message-ID: <1476796238-9384-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: herbert@gondor.apana.org.au, roopa@cumulusnetworks.com,
        stephen@networkplumber.org,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f177.google.com ([209.85.161.177]:34323 "EHLO
        mail-yw0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758894AbcJRNLo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 09:11:44 -0400
Received: by mail-yw0-f177.google.com with SMTP id w3so136627710ywg.1
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2016 06:11:44 -0700 (PDT)
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

Fixes: 561f1103a2b7 ("bridge: Add multicast_snooping sysfs toggle")
Reported-by: Satish Ashok <sashok@cumulusnetworks.com>
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_multicast.c | 18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index c5fea9393946..1bc807f1d633 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1992,10 +1992,25 @@ static void br_multicast_start_querier(struct net_bridge *br,
 	}
 }
 
+static void br_multicast_start_router(struct net_bridge *br)
+{
+	struct net_bridge_port *port;
+
+	list_for_each_entry(port, &br->port_list, list) {
+		if (port->state == BR_STATE_DISABLED ||
+		    port->state == BR_STATE_BLOCKING)
+			continue;
+
+		if (port->multicast_router == MDB_RTR_TYPE_PERM &&
+		    hlist_unhashed(&port->rlist))
+			br_multicast_add_router(br, port);
+	}
+}
+
 int br_multicast_toggle(struct net_bridge *br, unsigned long val)
 {
-	int err = 0;
 	struct net_bridge_mdb_htable *mdb;
+	int err = 0;
 
 	spin_lock_bh(&br->multicast_lock);
 	if (br->multicast_disabled == !val)
@@ -2027,6 +2042,7 @@ int br_multicast_toggle(struct net_bridge *br, unsigned long val)
 #if IS_ENABLED(CONFIG_IPV6)
 	br_multicast_start_querier(br, &br->ip6_own_query);
 #endif
+	br_multicast_start_router(br);
 
 unlock:
 	spin_unlock_bh(&br->multicast_lock);
-- 
2.1.4
