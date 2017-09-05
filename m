From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v2 rfc 3/8] net: bridge: Add/del switchdev object on host join/leave
Date: Wed,  6 Sep 2017 01:35:05 +0200
Message-ID: <1504654510-31004-4-git-send-email-andrew@lunn.ch>
References: <1504654510-31004-1-git-send-email-andrew@lunn.ch>
Cc: jiri@resnulli.us, nikolay@cumulusnetworks.com,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58242 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753652AbdIEXjb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 5 Sep 2017 19:39:31 -0400
In-Reply-To: <1504654510-31004-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the host joins or leaves a multicast group, use switchdev to add
an object to the hardware to forward traffic for the group to the
host.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 include/net/switchdev.h   |  1 +
 net/bridge/br_mdb.c       | 39 +++++++++++++++++++++++++++++++++++++++
 net/switchdev/switchdev.c |  2 ++
 3 files changed, 42 insertions(+)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index d767b7991887..b298a6b4c11d 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -75,6 +75,7 @@ enum switchdev_obj_id {
 	SWITCHDEV_OBJ_ID_UNDEFINED,
 	SWITCHDEV_OBJ_ID_PORT_VLAN,
 	SWITCHDEV_OBJ_ID_PORT_MDB,
+	SWITCHDEV_OBJ_ID_HOST_MDB,
 };
 
 struct switchdev_obj {
diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index 80fa91ccc50c..a9c03f3a3b88 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -291,6 +291,42 @@ static void br_mdb_complete(struct net_device *dev, int err, void *priv)
 	kfree(priv);
 }
 
+static void br_mdb_switchdev_host_port(struct net_device *dev,
+				       struct net_device *lower_dev,
+				       struct br_mdb_entry *entry, int type)
+{
+	struct switchdev_obj_port_mdb mdb = {
+		.obj = {
+			.id = SWITCHDEV_OBJ_ID_HOST_MDB,
+			.flags = SWITCHDEV_F_DEFER,
+		},
+		.vid = entry->vid,
+	};
+
+	if (entry->addr.proto == htons(ETH_P_IP))
+		ip_eth_mc_map(entry->addr.u.ip4, mdb.addr);
+#if IS_ENABLED(CONFIG_IPV6)
+	else
+		ipv6_eth_mc_map(&entry->addr.u.ip6, mdb.addr);
+#endif
+
+	mdb.obj.orig_dev = dev;
+	if (type == RTM_NEWMDB)
+		switchdev_port_obj_add(lower_dev, &mdb.obj);
+	if (type == RTM_DELMDB)
+		switchdev_port_obj_del(lower_dev, &mdb.obj);
+}
+
+static void br_mdb_switchdev_host(struct net_device *dev,
+				  struct br_mdb_entry *entry, int type)
+{
+	struct net_device *lower_dev;
+	struct list_head *iter;
+
+	netdev_for_each_lower_dev(dev, lower_dev, iter)
+		br_mdb_switchdev_host_port(dev, lower_dev, entry, type);
+}
+
 static void __br_mdb_notify(struct net_device *dev, struct net_bridge_port *p,
 			    struct br_mdb_entry *entry, int type)
 {
@@ -330,6 +366,9 @@ static void __br_mdb_notify(struct net_device *dev, struct net_bridge_port *p,
 		switchdev_port_obj_del(port_dev, &mdb.obj);
 	}
 
+	if (!p)
+		br_mdb_switchdev_host(dev, entry, type);
+
 	skb = nlmsg_new(rtnl_mdb_nlmsg_size(), GFP_ATOMIC);
 	if (!skb)
 		goto errout;
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 0531b41d1f2d..74b9d916a58b 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -345,6 +345,8 @@ static size_t switchdev_obj_size(const struct switchdev_obj *obj)
 		return sizeof(struct switchdev_obj_port_vlan);
 	case SWITCHDEV_OBJ_ID_PORT_MDB:
 		return sizeof(struct switchdev_obj_port_mdb);
+	case SWITCHDEV_OBJ_ID_HOST_MDB:
+		return sizeof(struct switchdev_obj_port_mdb);
 	default:
 		BUG();
 	}
-- 
2.14.1
