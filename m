From: Cong Wang <amwang@redhat.com>
Subject: [PATCH net-next v3] bridge: export multicast database via
	netlink
Date: Wed,  5 Dec 2012 10:50:04 +0800
Message-ID: <1354675804-13310-1-git-send-email-amwang@redhat.com>
Cc: Cong Wang <amwang@redhat.com>, bridge@lists.linux-foundation.org,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Jesper Dangaard Brouer <brouer@redhat.com>, Thomas Graf <tgraf@suug.ch>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

V3: drop debugging printk's
    update selinux perm table as well

V2: drop patch 1/2, export ifindex directly
    Redesign netlink attributes
    Improve netlink seq check
    Handle IPv6 addr as well

This patch exports bridge multicast database via netlink
message type RTM_GETMDB. Similar to fdb, but currently bridge-specific.
We may need to support modify multicast database too (RTM_{ADD,DEL}MDB).

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Thomas Graf <tgraf@suug.ch>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Cong Wang <amwang@redhat.com>
    
---
 include/uapi/linux/if_bridge.h |   55 ++++++++++++++
 include/uapi/linux/rtnetlink.h |    3 +
 net/bridge/Makefile            |    2 +-
 net/bridge/br_mdb.c            |  161 ++++++++++++++++++++++++++++++++++++++++
 net/bridge/br_multicast.c      |    2 +
 net/bridge/br_private.h        |    2 +
 security/selinux/nlmsgtab.c    |    1 +
 7 files changed, 225 insertions(+), 1 deletions(-)

diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
index b388579..9a0f6ff 100644
--- a/include/uapi/linux/if_bridge.h
+++ b/include/uapi/linux/if_bridge.h
@@ -116,4 +116,59 @@ enum {
 	__IFLA_BRIDGE_MAX,
 };
 #define IFLA_BRIDGE_MAX (__IFLA_BRIDGE_MAX - 1)
+
+/* Bridge multicast database attributes
+ * [MDBA_MDB] = {
+ *     [MDBA_MDB_ENTRY] = {
+ *         [MDBA_MDB_ENTRY_INFO]
+ *     }
+ * }
+ * [MDBA_ROUTER] = {
+ *    [MDBA_ROUTER_PORT]
+ * }
+ */
+enum {
+	MDBA_UNSPEC,
+	MDBA_MDB,
+	MDBA_ROUTER,
+	__MDBA_MAX,
+};
+#define MDBA_MAX (__MDBA_MAX - 1)
+
+enum {
+	MDBA_MDB_UNSPEC,
+	MDBA_MDB_ENTRY,
+	__MDBA_MDB_MAX,
+};
+#define MDBA_MDB_MAX (__MDBA_MDB_MAX - 1)
+
+enum {
+	MDBA_MDB_ENTRY_UNSPEC,
+	MDBA_MDB_ENTRY_INFO,
+	__MDBA_MDB_ENTRY_MAX,
+};
+#define MDBA_MDB_ENTRY_MAX (__MDBA_MDB_ENTRY_MAX - 1)
+
+enum {
+	MDBA_ROUTER_UNSPEC,
+	MDBA_ROUTER_PORT,
+	__MDBA_ROUTER_MAX,
+};
+#define MDBA_ROUTER_MAX (__MDBA_ROUTER_MAX - 1)
+
+struct br_port_msg {
+	__u32 ifindex;
+};
+
+struct br_mdb_entry {
+	__u32 ifindex;
+	struct {
+		union {
+			__be32	ip4;
+			struct in6_addr ip6;
+		} u;
+		__be16		proto;
+	} addr;
+};
+
 #endif /* _UAPI_LINUX_IF_BRIDGE_H */
diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index 33d29ce..354a1e7 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -125,6 +125,9 @@ enum {
 	RTM_GETNETCONF = 82,
 #define RTM_GETNETCONF RTM_GETNETCONF
 
+	RTM_GETMDB = 86,
+#define RTM_GETMDB RTM_GETMDB
+
 	__RTM_MAX,
 #define RTM_MAX		(((__RTM_MAX + 3) & ~3) - 1)
 };
diff --git a/net/bridge/Makefile b/net/bridge/Makefile
index d0359ea..e859098 100644
--- a/net/bridge/Makefile
+++ b/net/bridge/Makefile
@@ -12,6 +12,6 @@ bridge-$(CONFIG_SYSFS) += br_sysfs_if.o br_sysfs_br.o
 
 bridge-$(CONFIG_BRIDGE_NETFILTER) += br_netfilter.o
 
-bridge-$(CONFIG_BRIDGE_IGMP_SNOOPING) += br_multicast.o
+bridge-$(CONFIG_BRIDGE_IGMP_SNOOPING) += br_multicast.o br_mdb.o
 
 obj-$(CONFIG_BRIDGE_NF_EBTABLES) += netfilter/
diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
new file mode 100644
index 0000000..f0f4dcf
--- /dev/null
+++ b/net/bridge/br_mdb.c
@@ -0,0 +1,161 @@
+#include <linux/err.h>
+#include <linux/if_ether.h>
+#include <linux/igmp.h>
+#include <linux/kernel.h>
+#include <linux/netdevice.h>
+#include <linux/rculist.h>
+#include <linux/skbuff.h>
+#include <linux/slab.h>
+#include <net/ip.h>
+#if IS_ENABLED(CONFIG_IPV6)
+#include <net/ipv6.h>
+#include <net/mld.h>
+#include <net/addrconf.h>
+#include <net/ip6_checksum.h>
+#endif
+
+#include "br_private.h"
+
+static int br_rports_fill_info(struct sk_buff *skb, struct netlink_callback *cb,
+			       struct net_device *dev)
+{
+	struct net_bridge *br = netdev_priv(dev);
+	struct net_bridge_port *p;
+	struct hlist_node *n;
+	struct nlattr *nest;
+
+	if (!br->multicast_router || hlist_empty(&br->router_list))
+		return 0;
+
+	nest = nla_nest_start(skb, MDBA_ROUTER);
+	if (nest == NULL)
+		return -EMSGSIZE;
+
+	hlist_for_each_entry_rcu(p, n, &br->router_list, rlist) {
+		if (p && nla_put_u32(skb, MDBA_ROUTER_PORT, p->dev->ifindex))
+			goto fail;
+	}
+
+	nla_nest_end(skb, nest);
+	return 0;
+fail:
+	nla_nest_cancel(skb, nest);
+	return -EMSGSIZE;
+}
+
+static int br_mdb_fill_info(struct sk_buff *skb, struct netlink_callback *cb,
+			    struct net_device *dev)
+{
+	struct net_bridge *br = netdev_priv(dev);
+	struct net_bridge_mdb_htable *mdb;
+	struct nlattr *nest, *nest2;
+	int i, err = 0;
+	int idx = 0, s_idx = cb->args[1];
+
+	if (br->multicast_disabled)
+		return 0;
+
+	mdb = rcu_dereference(br->mdb);
+	if (!mdb)
+		return 0;
+
+	nest = nla_nest_start(skb, MDBA_MDB);
+	if (nest == NULL)
+		return -EMSGSIZE;
+
+	for (i = 0; i < mdb->max; i++) {
+		struct hlist_node *h;
+		struct net_bridge_mdb_entry *mp;
+		struct net_bridge_port_group *p, **pp;
+		struct net_bridge_port *port;
+
+		hlist_for_each_entry_rcu(mp, h, &mdb->mhash[i], hlist[mdb->ver]) {
+			if (idx < s_idx)
+				goto skip;
+
+			nest2 = nla_nest_start(skb, MDBA_MDB_ENTRY);
+			if (nest2 == NULL) {
+				err = -EMSGSIZE;
+				goto out;
+			}
+
+			for (pp = &mp->ports;
+			     (p = rcu_dereference(*pp)) != NULL;
+			      pp = &p->next) {
+				port = p->port;
+				if (port) {
+					struct br_mdb_entry e;
+					e.ifindex = port->dev->ifindex;
+					e.addr.u.ip4 = p->addr.u.ip4;
+#if IS_ENABLED(CONFIG_IPV6)
+					e.addr.u.ip6 = p->addr.u.ip6;
+#endif
+					e.addr.proto = p->addr.proto;
+					if (nla_put(skb, MDBA_MDB_ENTRY_INFO, sizeof(e), &e)) {
+						nla_nest_cancel(skb, nest2);
+						err = -EMSGSIZE;
+						goto out;
+					}
+				}
+			}
+			nla_nest_end(skb, nest2);
+		skip:
+			idx++;
+		}
+	}
+
+out:
+	cb->args[1] = idx;
+	cb->args[2] = mdb->seq;
+	nla_nest_end(skb, nest);
+	return err;
+}
+
+static int br_mdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct net_device *dev;
+	struct net *net = sock_net(skb->sk);
+	struct nlmsghdr *nlh;
+	int idx = 0, s_idx;
+
+	s_idx = cb->args[0];
+
+	rcu_read_lock();
+
+	for_each_netdev_rcu(net, dev) {
+		if (dev->priv_flags & IFF_EBRIDGE) {
+			struct br_port_msg *bpm;
+
+			if (idx < s_idx)
+				goto cont;
+
+			nlh = nlmsg_put(skb, NETLINK_CB(cb->skb).portid,
+					cb->nlh->nlmsg_seq, RTM_GETMDB,
+					sizeof(*bpm), NLM_F_MULTI);
+			if (nlh == NULL)
+				break;
+
+			bpm = nlmsg_data(nlh);
+			bpm->ifindex = dev->ifindex;
+			if (br_mdb_fill_info(skb, cb, dev) < 0)
+				goto out;
+			if (br_rports_fill_info(skb, cb, dev) < 0)
+				goto out;
+
+			nlmsg_end(skb, nlh);
+		cont:
+			idx++;
+		}
+	}
+
+out:
+	cb->seq = cb->args[2];
+	rcu_read_unlock();
+	cb->args[0] = idx;
+	return skb->len;
+}
+
+void br_mdb_init(void)
+{
+	rtnl_register(PF_BRIDGE, RTM_GETMDB, NULL, br_mdb_dump, NULL);
+}
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 2417434..d53e4f4 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -322,6 +322,7 @@ static int br_mdb_rehash(struct net_bridge_mdb_htable __rcu **mdbp, int max,
 
 	mdb->size = old ? old->size : 0;
 	mdb->ver = old ? old->ver ^ 1 : 0;
+	mdb->seq = old ? (old->seq + 1): 0;
 
 	if (!old || elasticity)
 		get_random_bytes(&mdb->secret, sizeof(mdb->secret));
@@ -1584,6 +1585,7 @@ void br_multicast_init(struct net_bridge *br)
 		    br_multicast_querier_expired, (unsigned long)br);
 	setup_timer(&br->multicast_query_timer, br_multicast_query_expired,
 		    (unsigned long)br);
+	br_mdb_init();
 }
 
 void br_multicast_open(struct net_bridge *br)
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index eb9cd42..6484069 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -105,6 +105,7 @@ struct net_bridge_mdb_htable
 	u32				max;
 	u32				secret;
 	u32				ver;
+	u32				seq;
 };
 
 struct net_bridge_port
@@ -432,6 +433,7 @@ extern int br_multicast_set_port_router(struct net_bridge_port *p,
 extern int br_multicast_toggle(struct net_bridge *br, unsigned long val);
 extern int br_multicast_set_querier(struct net_bridge *br, unsigned long val);
 extern int br_multicast_set_hash_max(struct net_bridge *br, unsigned long val);
+extern void br_mdb_init(void);
 
 static inline bool br_multicast_is_router(struct net_bridge *br)
 {
diff --git a/security/selinux/nlmsgtab.c b/security/selinux/nlmsgtab.c
index d309e7f..163aaa7 100644
--- a/security/selinux/nlmsgtab.c
+++ b/security/selinux/nlmsgtab.c
@@ -67,6 +67,7 @@ static struct nlmsg_perm nlmsg_route_perms[] =
 	{ RTM_GETADDRLABEL,	NETLINK_ROUTE_SOCKET__NLMSG_READ  },
 	{ RTM_GETDCB,		NETLINK_ROUTE_SOCKET__NLMSG_READ  },
 	{ RTM_SETDCB,		NETLINK_ROUTE_SOCKET__NLMSG_WRITE },
+	{ RTM_GETMDB,		NETLINK_ROUTE_SOCKET__NLMSG_READ  },
 };
 
 static struct nlmsg_perm nlmsg_tcpdiag_perms[] =
