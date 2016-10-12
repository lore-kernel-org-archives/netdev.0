From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH] net: ipv4: Do not drop to make_route if oif is l3mdev
Date: Wed, 12 Oct 2016 13:20:11 -0700
Message-ID: <1476303611-28154-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:32895 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932574AbcJLUVM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 16:21:12 -0400
Received: by mail-pf0-f175.google.com with SMTP id 128so23626275pfz.0
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2016 13:20:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit e0d56fdd7342 was a bit aggressive removing l3mdev calls in
the IPv4 stack. If the fib_lookup fails we do not want to drop to
make_route if the oif is an l3mdev device.

Also reverts 19664c6a0009 ("net: l3mdev: Remove netif_index_is_l3_master")
which removed netif_index_is_l3_master.

Fixes: e0d56fdd7342 ("net: l3mdev: remove redundant calls")
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/l3mdev.h | 24 ++++++++++++++++++++++++
 net/ipv4/route.c     |  3 ++-
 2 files changed, 26 insertions(+), 1 deletion(-)

diff --git a/include/net/l3mdev.h b/include/net/l3mdev.h
index b220dabeab45..3832099289c5 100644
--- a/include/net/l3mdev.h
+++ b/include/net/l3mdev.h
@@ -114,6 +114,25 @@ static inline u32 l3mdev_fib_table(const struct net_device *dev)
 	return tb_id;
 }
 
+static inline bool netif_index_is_l3_master(struct net *net, int ifindex)
+{
+	struct net_device *dev;
+	bool rc = false;
+
+	if (ifindex == 0)
+		return false;
+
+	rcu_read_lock();
+
+	dev = dev_get_by_index_rcu(net, ifindex);
+	if (dev)
+		rc = netif_is_l3_master(dev);
+
+	rcu_read_unlock();
+
+	return rc;
+}
+
 struct dst_entry *l3mdev_link_scope_lookup(struct net *net, struct flowi6 *fl6);
 
 static inline
@@ -207,6 +226,11 @@ static inline u32 l3mdev_fib_table_by_index(struct net *net, int ifindex)
 	return 0;
 }
 
+static inline bool netif_index_is_l3_master(struct net *net, int ifindex)
+{
+	return false;
+}
+
 static inline
 struct dst_entry *l3mdev_link_scope_lookup(struct net *net, struct flowi6 *fl6)
 {
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index f2be689a6c85..62d4d90c1389 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2265,7 +2265,8 @@ struct rtable *__ip_route_output_key_hash(struct net *net, struct flowi4 *fl4,
 	if (err) {
 		res.fi = NULL;
 		res.table = NULL;
-		if (fl4->flowi4_oif) {
+		if (fl4->flowi4_oif &&
+		    !netif_index_is_l3_master(net, fl4->flowi4_oif)) {
 			/* Apparently, routing tables are wrong. Assume,
 			   that the destination is on link.
 
-- 
2.1.4
