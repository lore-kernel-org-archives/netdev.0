From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 6/6] net: bridge: add br_mdb_do
Date: Wed, 17 May 2017 17:27:09 -0400
Message-ID: <20170517212709.6473-7-vivien.didelot@savoirfairelinux.com>
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

Now that the two functions br_mdb_add and br_mdb_del are identical, keep
a single function named br_mdb_do and register it for both RTM_NEWMDB
and RTM_DELMDB message types.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/bridge/br_mdb.c | 61 +++++------------------------------------------------
 1 file changed, 5 insertions(+), 56 deletions(-)

diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index d280b20587cb..1a1da25f3727 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -556,57 +556,6 @@ static int __br_mdb_add(struct net_bridge_port *p, struct br_mdb_entry *entry)
 	return ret;
 }
 
-static int __br_mdb_do(struct net_bridge_port *p, struct br_mdb_entry *entry,
-		       int msgtype);
-
-static int br_mdb_add(struct sk_buff *skb, struct nlmsghdr *nlh,
-		      struct netlink_ext_ack *extack)
-{
-	struct net *net = sock_net(skb->sk);
-	struct net_bridge_vlan_group *vg;
-	struct net_device *dev, *pdev;
-	struct br_mdb_entry *entry;
-	struct net_bridge_port *p;
-	struct net_bridge_vlan *v;
-	struct net_bridge *br;
-	int msgtype = nlh->nlmsg_type;
-	int err;
-
-	err = br_mdb_parse(skb, nlh, &dev, &entry);
-	if (err < 0)
-		return err;
-
-	br = netdev_priv(dev);
-
-	if (!netif_running(br->dev) || br->multicast_disabled)
-		return -EINVAL;
-
-	/* If vlan filtering is enabled and VLAN is not specified
-	 * install mdb entry on all vlans configured on the port.
-	 */
-	pdev = __dev_get_by_index(net, entry->ifindex);
-	if (!pdev)
-		return -ENODEV;
-
-	p = br_port_get_rtnl(pdev);
-	if (!p || p->br != br || p->state == BR_STATE_DISABLED)
-		return -EINVAL;
-
-	vg = nbp_vlan_group(p);
-	if (br_vlan_enabled(br) && vg && entry->vid == 0) {
-		list_for_each_entry(v, &vg->vlan_list, vlist) {
-			entry->vid = v->vid;
-			err = __br_mdb_do(p, entry, msgtype);
-			if (err)
-				break;
-		}
-	} else {
-		err = __br_mdb_do(p, entry, msgtype);
-	}
-
-	return err;
-}
-
 static int __br_mdb_del(struct net_bridge *br, struct br_mdb_entry *entry)
 {
 	struct net_bridge_mdb_htable *mdb;
@@ -668,8 +617,8 @@ static int __br_mdb_do(struct net_bridge_port *p, struct br_mdb_entry *entry,
 	return err;
 }
 
-static int br_mdb_del(struct sk_buff *skb, struct nlmsghdr *nlh,
-		      struct netlink_ext_ack *extack)
+static int br_mdb_do(struct sk_buff *skb, struct nlmsghdr *nlh,
+		     struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(skb->sk);
 	struct net_bridge_vlan_group *vg;
@@ -691,7 +640,7 @@ static int br_mdb_del(struct sk_buff *skb, struct nlmsghdr *nlh,
 		return -EINVAL;
 
 	/* If vlan filtering is enabled and VLAN is not specified
-	 * delete mdb entry on all vlans configured on the port.
+	 * add or delete mdb entry on all vlans configured on the port.
 	 */
 	pdev = __dev_get_by_index(net, entry->ifindex);
 	if (!pdev)
@@ -719,8 +668,8 @@ static int br_mdb_del(struct sk_buff *skb, struct nlmsghdr *nlh,
 void br_mdb_init(void)
 {
 	rtnl_register(PF_BRIDGE, RTM_GETMDB, NULL, br_mdb_dump, NULL);
-	rtnl_register(PF_BRIDGE, RTM_NEWMDB, br_mdb_add, NULL, NULL);
-	rtnl_register(PF_BRIDGE, RTM_DELMDB, br_mdb_del, NULL, NULL);
+	rtnl_register(PF_BRIDGE, RTM_NEWMDB, br_mdb_do, NULL, NULL);
+	rtnl_register(PF_BRIDGE, RTM_DELMDB, br_mdb_do, NULL, NULL);
 }
 
 void br_mdb_uninit(void)
-- 
2.13.0
