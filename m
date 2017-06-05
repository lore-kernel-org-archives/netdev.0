From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 03/19] net: bridge: Add support for calling FDB external learning under rcu
Date: Mon,  5 Jun 2017 11:20:27 +0200
Message-ID: <20170605092043.3523-4-jiri@resnulli.us>
References: <20170605092043.3523-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com, roopa@cumulusnetworks.com,
        stephen@networkplumber.org, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:33994 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751748AbdFEJUz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 05:20:55 -0400
Received: by mail-wr0-f193.google.com with SMTP id u101so4374152wrc.1
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 02:20:49 -0700 (PDT)
In-Reply-To: <20170605092043.3523-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

This is done as a preparation to moving the switchdev notifier chain
to be atomic. The FDB external learning should be called under rtnl
or rcu.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/bridge/br.c         | 4 ++--
 net/bridge/br_fdb.c     | 2 --
 net/bridge/br_private.h | 6 ++++++
 3 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/bridge/br.c b/net/bridge/br.c
index 889e564..e962fff 100644
--- a/net/bridge/br.c
+++ b/net/bridge/br.c
@@ -121,7 +121,7 @@ static struct notifier_block br_device_notifier = {
 	.notifier_call = br_device_event
 };
 
-/* called with RTNL */
+/* called with RTNL or RCU */
 static int br_switchdev_event(struct notifier_block *unused,
 			      unsigned long event, void *ptr)
 {
@@ -131,7 +131,7 @@ static int br_switchdev_event(struct notifier_block *unused,
 	struct switchdev_notifier_fdb_info *fdb_info;
 	int err = NOTIFY_DONE;
 
-	p = br_port_get_rtnl(dev);
+	p = br_port_get_rtnl_rcu(dev);
 	if (!p)
 		goto out;
 
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index ab0c7cc..5c780cd 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -1075,7 +1075,6 @@ int br_fdb_external_learn_add(struct net_bridge *br, struct net_bridge_port *p,
 	struct net_bridge_fdb_entry *fdb;
 	int err = 0;
 
-	ASSERT_RTNL();
 	spin_lock_bh(&br->hash_lock);
 
 	head = &br->hash[br_mac_hash(addr, vid)];
@@ -1110,7 +1109,6 @@ int br_fdb_external_learn_del(struct net_bridge *br, struct net_bridge_port *p,
 	struct net_bridge_fdb_entry *fdb;
 	int err = 0;
 
-	ASSERT_RTNL();
 	spin_lock_bh(&br->hash_lock);
 
 	fdb = br_fdb_find(br, addr, vid);
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 5dc30ed..69ba3ba 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -288,6 +288,12 @@ static inline struct net_bridge_port *br_port_get_rtnl(const struct net_device *
 		rtnl_dereference(dev->rx_handler_data) : NULL;
 }
 
+static inline struct net_bridge_port *br_port_get_rtnl_rcu(const struct net_device *dev)
+{
+	return br_port_exists(dev) ?
+		rcu_dereference_rtnl(dev->rx_handler_data) : NULL;
+}
+
 struct net_bridge {
 	spinlock_t			lock;
 	spinlock_t			hash_lock;
-- 
2.9.3
