From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 2/3] bridge: mdb: Common function for mdb entry translation
Date: Thu, 21 Apr 2016 12:52:44 +0200
Message-ID: <1461235965-3930-3-git-send-email-jiri@resnulli.us>
References: <1461235965-3930-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	stephen@networkplumber.org, nikolay@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:36809 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751543AbcDUKwu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 06:52:50 -0400
Received: by mail-wm0-f53.google.com with SMTP id v188so239268881wme.1
        for <netdev@vger.kernel.org>; Thu, 21 Apr 2016 03:52:50 -0700 (PDT)
In-Reply-To: <1461235965-3930-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Raz <eladr@mellanox.com>

There is duplicate code that translates br_mdb_entry to br_ip let's wrap it
in a common function.

Signed-off-by: Elad Raz <eladr@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Acked-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_mdb.c | 33 +++++++++++++++------------------
 1 file changed, 15 insertions(+), 18 deletions(-)

diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index 253bc77..b258120 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -61,6 +61,19 @@ static void __mdb_entry_fill_flags(struct br_mdb_entry *e, unsigned char flags)
 		e->flags |= MDB_FLAGS_OFFLOAD;
 }
 
+static void __mdb_entry_to_br_ip(struct br_mdb_entry *entry, struct br_ip *ip)
+{
+	memset(ip, 0, sizeof(struct br_ip));
+	ip->vid = entry->vid;
+	ip->proto = entry->addr.proto;
+	if (ip->proto == htons(ETH_P_IP))
+		ip->u.ip4 = entry->addr.u.ip4;
+#if IS_ENABLED(CONFIG_IPV6)
+	else
+		ip->u.ip6 = entry->addr.u.ip6;
+#endif
+}
+
 static int br_mdb_fill_info(struct sk_buff *skb, struct netlink_callback *cb,
 			    struct net_device *dev)
 {
@@ -509,15 +522,7 @@ static int __br_mdb_add(struct net *net, struct net_bridge *br,
 	if (!p || p->br != br || p->state == BR_STATE_DISABLED)
 		return -EINVAL;
 
-	memset(&ip, 0, sizeof(ip));
-	ip.vid = entry->vid;
-	ip.proto = entry->addr.proto;
-	if (ip.proto == htons(ETH_P_IP))
-		ip.u.ip4 = entry->addr.u.ip4;
-#if IS_ENABLED(CONFIG_IPV6)
-	else
-		ip.u.ip6 = entry->addr.u.ip6;
-#endif
+	__mdb_entry_to_br_ip(entry, &ip);
 
 	spin_lock_bh(&br->multicast_lock);
 	ret = br_mdb_add_group(br, p, &ip, entry->state, pg);
@@ -584,15 +589,7 @@ static int __br_mdb_del(struct net_bridge *br, struct br_mdb_entry *entry)
 	if (!netif_running(br->dev) || br->multicast_disabled)
 		return -EINVAL;
 
-	memset(&ip, 0, sizeof(ip));
-	ip.vid = entry->vid;
-	ip.proto = entry->addr.proto;
-	if (ip.proto == htons(ETH_P_IP))
-		ip.u.ip4 = entry->addr.u.ip4;
-#if IS_ENABLED(CONFIG_IPV6)
-	else
-		ip.u.ip6 = entry->addr.u.ip6;
-#endif
+	__mdb_entry_to_br_ip(entry, &ip);
 
 	spin_lock_bh(&br->multicast_lock);
 	mdb = mlock_dereference(br->mdb, br);
-- 
2.5.5
