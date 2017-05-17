From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 1/6] net: bridge: pass net_bridge_port to __br_mdb_add
Date: Wed, 17 May 2017 17:27:04 -0400
Message-ID: <20170517212709.6473-2-vivien.didelot@savoirfairelinux.com>
References: <20170517212709.6473-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        bridge@lists.linux-foundation.org (moderated list:ETHERNET BRIDGE)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170517212709.6473-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The __br_mdb_add function uses exactly the same mechanism as its caller
br_mdb_add to retrieve the net_bridge_port pointer from br_mdb_entry.

Remove it and pass directly the net_bridge_port pointer to __br_mdb_add.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/bridge/br_mdb.c | 18 ++++--------------
 1 file changed, 4 insertions(+), 14 deletions(-)

diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index b0845480a3ae..bef0331f46a4 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -542,25 +542,15 @@ static int br_mdb_add_group(struct net_bridge *br, struct net_bridge_port *port,
 	return 0;
 }
 
-static int __br_mdb_add(struct net *net, struct net_bridge *br,
-			struct br_mdb_entry *entry)
+static int __br_mdb_add(struct net_bridge_port *p, struct br_mdb_entry *entry)
 {
+	struct net_bridge *br = p->br;
 	struct br_ip ip;
-	struct net_device *dev;
-	struct net_bridge_port *p;
 	int ret;
 
 	if (!netif_running(br->dev) || br->multicast_disabled)
 		return -EINVAL;
 
-	dev = __dev_get_by_index(net, entry->ifindex);
-	if (!dev)
-		return -ENODEV;
-
-	p = br_port_get_rtnl(dev);
-	if (!p || p->br != br || p->state == BR_STATE_DISABLED)
-		return -EINVAL;
-
 	__mdb_entry_to_br_ip(entry, &ip);
 
 	spin_lock_bh(&br->multicast_lock);
@@ -602,13 +592,13 @@ static int br_mdb_add(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (br_vlan_enabled(br) && vg && entry->vid == 0) {
 		list_for_each_entry(v, &vg->vlan_list, vlist) {
 			entry->vid = v->vid;
-			err = __br_mdb_add(net, br, entry);
+			err = __br_mdb_add(p, entry);
 			if (err)
 				break;
 			__br_mdb_notify(dev, p, entry, RTM_NEWMDB);
 		}
 	} else {
-		err = __br_mdb_add(net, br, entry);
+		err = __br_mdb_add(p, entry);
 		if (!err)
 			__br_mdb_notify(dev, p, entry, RTM_NEWMDB);
 	}
-- 
2.13.0
