From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
Subject: [PATCH net-next 3/4] bridge: add export of multicast database adjacent to net_dev
Date: Wed, 21 May 2014 10:59:01 +0200
Message-ID: <1400662742-31999-4-git-send-email-linus.luessing@web.de>
References: <1400662742-31999-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bridge@lists.linux-foundation.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400662742-31999-1-git-send-email-linus.luessing@web.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With this new, exported function br_multicast_list_adjacent(net_dev) a
list of IPv4/6 addresses is returned. This list contains all multicast
addresses sensed by the bridge multicast snooping feature on all bridge
ports of the bridge interface of net_dev, excluding addresses from the
specified net_device itself.

Adding bridge support to the batman-adv multicast optimization requires
batman-adv knowing about the existence of bridged-in multicast
listeners to be able to reliably serve them with multicast packets.

Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
---
 include/linux/if_bridge.h |   18 ++++++++++++++
 net/bridge/br_multicast.c |   58 +++++++++++++++++++++++++++++++++++++=
++++++++
 net/bridge/br_private.h   |   12 ----------
 3 files changed, 76 insertions(+), 12 deletions(-)

diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
index 1085ffe..44d6eb0 100644
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -16,9 +16,27 @@
 #include <linux/netdevice.h>
 #include <uapi/linux/if_bridge.h>
=20
+struct br_ip {
+	union {
+		__be32	ip4;
+#if IS_ENABLED(CONFIG_IPV6)
+		struct in6_addr ip6;
+#endif
+	} u;
+	__be16		proto;
+	__u16           vid;
+};
+
+struct br_ip_list {
+	struct list_head list;
+	struct br_ip addr;
+};
+
 extern void brioctl_set(int (*ioctl_hook)(struct net *, unsigned int, =
void __user *));
=20
 typedef int br_should_route_hook_t(struct sk_buff *skb);
 extern br_should_route_hook_t __rcu *br_should_route_hook;
+int br_multicast_list_adjacent(struct net_device *dev,
+			       struct list_head *br_ip_list);
=20
 #endif
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 05c6593..f583bf6 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -11,6 +11,7 @@
  */
=20
 #include <linux/err.h>
+#include <linux/export.h>
 #include <linux/if_ether.h>
 #include <linux/igmp.h>
 #include <linux/jhash.h>
@@ -2141,3 +2142,60 @@ unlock:
=20
 	return err;
 }
+
+/**
+ * br_multicast_list_adjacent - Returns snooped multicast addresses
+ * @dev:	The bridge port adjacent to which to retrieve addresses
+ * @br_ip_list:	The list to store found, snooped multicast IP addresse=
s in
+ *
+ * Creates a list of IP addresses (struct br_ip_list) sensed by the mu=
lticast
+ * snooping feature on all bridge ports of dev's bridge device, exclud=
ing
+ * the addresses from dev itself.
+ *
+ * Returns the number of items added to br_ip_list.
+ *
+ * Notes:
+ * - br_ip_list needs to be initialized by caller
+ * - br_ip_list might contain duplicates in the end
+ *   (needs to be taken care of by caller)
+ * - br_ip_list needs to be freed by caller
+ */
+int br_multicast_list_adjacent(struct net_device *dev,
+			       struct list_head *br_ip_list)
+{
+	struct net_bridge *br;
+	struct net_bridge_port *port;
+	struct net_bridge_port_group *group;
+	struct br_ip_list *entry;
+	int count =3D 0;
+
+	rcu_read_lock();
+	if (!br_ip_list || !br_port_exists(dev))
+		goto unlock;
+
+	port =3D br_port_get_rcu(dev);
+	if (!port || !port->br)
+		goto unlock;
+
+	br =3D port->br;
+
+	list_for_each_entry_rcu(port, &br->port_list, list) {
+		if (!port->dev || port->dev =3D=3D dev)
+			continue;
+
+		hlist_for_each_entry_rcu(group, &port->mglist, mglist) {
+			entry =3D kmalloc(sizeof(*entry), GFP_ATOMIC);
+			if (!entry)
+				goto unlock;
+
+			entry->addr =3D group->addr;
+			list_add(&entry->list, br_ip_list);
+			count++;
+		}
+	}
+
+unlock:
+	rcu_read_unlock();
+	return count;
+}
+EXPORT_SYMBOL(br_multicast_list_adjacent);
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index bc1803b..cb704a6 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -54,18 +54,6 @@ struct mac_addr
 	unsigned char	addr[ETH_ALEN];
 };
=20
-struct br_ip
-{
-	union {
-		__be32	ip4;
-#if IS_ENABLED(CONFIG_IPV6)
-		struct in6_addr ip6;
-#endif
-	} u;
-	__be16		proto;
-	__u16		vid;
-};
-
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 /* our own querier */
 struct bridge_mcast_own_query {
--=20
1.7.10.4
