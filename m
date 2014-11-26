From: roopa@cumulusnetworks.com
Subject: [PATCH net-next] bridge: add vlan id to mdb notifications
Date: Wed, 26 Nov 2014 05:53:33 -0800
Message-ID: <1417010013-31454-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, wkok@cumulusnetworks.com,
	gospo@cumulusnetworks.com, jtoppins@cumulusnetworks.com,
	sashok@cumulusnetworks.com
To: vyasevich@gmail.com, stephen@networkplumber.org,
	roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:55130 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750951AbaKZNxg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 08:53:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch adds vlan id to bridge mdb notifications.

I have tested it with older iproute2 and does not seem to break
compatibility.

Signed-off-by: Wilson kok <wkok@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 include/uapi/linux/if_bridge.h |    1 +
 net/bridge/br_mdb.c            |    4 ++++
 2 files changed, 5 insertions(+)

diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
index da17e45..db061fd 100644
--- a/include/uapi/linux/if_bridge.h
+++ b/include/uapi/linux/if_bridge.h
@@ -185,6 +185,7 @@ struct br_mdb_entry {
 			struct in6_addr ip6;
 		} u;
 		__be16		proto;
+		__be16		vid;
 	} addr;
 };
 
diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index 5df0526..fa28540 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -92,6 +92,7 @@ static int br_mdb_fill_info(struct sk_buff *skb, struct netlink_callback *cb,
 						e.addr.u.ip6 = p->addr.u.ip6;
 #endif
 					e.addr.proto = p->addr.proto;
+					e.addr.vid = p->addr.vid;
 					if (nla_put(skb, MDBA_MDB_ENTRY_INFO, sizeof(e), &e)) {
 						nla_nest_cancel(skb, nest2);
 						err = -EMSGSIZE;
@@ -240,6 +241,7 @@ void br_mdb_notify(struct net_device *dev, struct net_bridge_port *port,
 #if IS_ENABLED(CONFIG_IPV6)
 	entry.addr.u.ip6 = group->u.ip6;
 #endif
+	entry.addr.vid = group->vid;
 	__br_mdb_notify(dev, &entry, type);
 }
 
@@ -377,6 +379,7 @@ static int __br_mdb_add(struct net *net, struct net_bridge *br,
 	else
 		ip.u.ip6 = entry->addr.u.ip6;
 #endif
+	ip.vid = entry->addr.vid;
 
 	spin_lock_bh(&br->multicast_lock);
 	ret = br_mdb_add_group(br, p, &ip, entry->state);
@@ -430,6 +433,7 @@ static int __br_mdb_del(struct net_bridge *br, struct br_mdb_entry *entry)
 		ip.u.ip6 = entry->addr.u.ip6;
 #endif
 	}
+	ip.vid = entry->addr.vid;
 
 	spin_lock_bh(&br->multicast_lock);
 	mdb = mlock_dereference(br->mdb, br);
-- 
1.7.10.4
