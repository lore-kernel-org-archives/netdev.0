From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH] bridge: Correctly unregister MDB rtnetlink handlers
Date: Wed,  2 Jan 2013 14:41:25 -0500
Message-ID: <1357155685-14672-1-git-send-email-vyasevic@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42416 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752695Ab3ABTlc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jan 2013 14:41:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 63233159fd4e596568f5f168ecb0879b61631d47:
    bridge: Do not unregister all PF_BRIDGE rtnl operations
introduced a bug where a removal of a single bridge from a
multi-bridge system would remove MDB netlink handlers.
The handlers should only be removed once all bridges are gone, but
since we don't keep track of the number of bridge interfaces, it's
simpler to do it when the bridge module is unloaded.  To make it
consistent, move the registration code into module initialization
code path.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_multicast.c |    2 --
 net/bridge/br_netlink.c   |   13 ++++++++++++-
 2 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 5391ca4..6d6f265 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1608,7 +1608,6 @@ void br_multicast_init(struct net_bridge *br)
 		    br_multicast_querier_expired, (unsigned long)br);
 	setup_timer(&br->multicast_query_timer, br_multicast_query_expired,
 		    (unsigned long)br);
-	br_mdb_init();
 }
 
 void br_multicast_open(struct net_bridge *br)
@@ -1633,7 +1632,6 @@ void br_multicast_stop(struct net_bridge *br)
 	del_timer_sync(&br->multicast_querier_timer);
 	del_timer_sync(&br->multicast_query_timer);
 
-	br_mdb_uninit();
 	spin_lock_bh(&br->multicast_lock);
 	mdb = mlock_dereference(br->mdb, br);
 	if (!mdb)
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 97ba018..5dc66ab 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -299,10 +299,21 @@ struct rtnl_link_ops br_link_ops __read_mostly = {
 
 int __init br_netlink_init(void)
 {
-	return rtnl_link_register(&br_link_ops);
+	int err;
+
+	br_mdb_init();
+	err = rtnl_link_register(&br_link_ops);
+	if (err)
+		goto out;
+
+	return 0;
+out:
+	br_mdb_uninit();
+	return err;
 }
 
 void __exit br_netlink_fini(void)
 {
+	br_mdb_uninit();
 	rtnl_link_unregister(&br_link_ops);
 }
-- 
1.7.7.6
