From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH v2] bridge:  Do not unregister all PF_BRIDGE rtnl operations
Date: Wed, 19 Dec 2012 14:13:48 -0500
Message-ID: <1355944428-32051-1-git-send-email-vyasevic@redhat.com>
Cc: davem@davemloft.net, shemminger@vyatta.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11936 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751278Ab2LSTNu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Dec 2012 14:13:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bridge fdb and link rtnl operations are registered in
core/rtnetlink.  Bridge mdb operations are registred
in bridge/mdb.  When removing bridge module, do not
unregister ALL PF_BRIDGE ops since that would remove
the ops from rtnetlink as well.  Do remove mdb ops when
bridge is destroyed.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_mdb.c       |    7 +++++++
 net/bridge/br_multicast.c |    1 +
 net/bridge/br_netlink.c   |    1 -
 net/bridge/br_private.h   |    1 +
 4 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index 9cf5d2b..3e05cc3 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -482,3 +482,10 @@ void br_mdb_init(void)
 	rtnl_register(PF_BRIDGE, RTM_NEWMDB, br_mdb_add, NULL, NULL);
 	rtnl_register(PF_BRIDGE, RTM_DELMDB, br_mdb_del, NULL, NULL);
 }
+
+void br_mdb_uninit(void)
+{
+	rtnl_unregister(PF_BRIDGE, RTM_GETMDB);
+	rtnl_unregister(PF_BRIDGE, RTM_NEWMDB);
+	rtnl_unregister(PF_BRIDGE, RTM_DELMDB);
+}
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index dce9def..5391ca4 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1633,6 +1633,7 @@ void br_multicast_stop(struct net_bridge *br)
 	del_timer_sync(&br->multicast_querier_timer);
 	del_timer_sync(&br->multicast_query_timer);
 
+	br_mdb_uninit();
 	spin_lock_bh(&br->multicast_lock);
 	mdb = mlock_dereference(br->mdb, br);
 	if (!mdb)
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index dead9df..97ba018 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -305,5 +305,4 @@ int __init br_netlink_init(void)
 void __exit br_netlink_fini(void)
 {
 	rtnl_link_unregister(&br_link_ops);
-	rtnl_unregister_all(PF_BRIDGE);
 }
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 49b85af4..8d83be5 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -447,6 +447,7 @@ extern struct net_bridge_port_group *br_multicast_new_port_group(
 				struct net_bridge_port_group *next,
 				unsigned char state);
 extern void br_mdb_init(void);
+extern void br_mdb_uninit(void);
 extern void br_mdb_notify(struct net_device *dev, struct net_bridge_port *port,
 			  struct br_ip *group, int type);
 
-- 
1.7.7.6
