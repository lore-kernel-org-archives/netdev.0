From: Cong Wang <amwang@redhat.com>
Subject: [PATCH net-next v1 2/2] bridge: export multicast database
	via netlink
Date: Fri, 30 Nov 2012 17:58:33 +0800
Message-ID: <1354269514-1863-2-git-send-email-amwang@redhat.com>
References: <1354269514-1863-1-git-send-email-amwang@redhat.com>
Cc: Cong Wang <amwang@redhat.com>, bridge@lists.linux-foundation.org,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Jesper Dangaard Brouer <brouer@redhat.com>, Thomas Graf <tgraf@suug.ch>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1354269514-1863-1-git-send-email-amwang@redhat.com>
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
 include/uapi/linux/if_bridge.h |   26 ++++++
 include/uapi/linux/rtnetlink.h |    3 +
 net/bridge/Makefile            |    2 +-
 net/bridge/br_mdb.c            |  166 ++++++++++++++++++++++++++++++++++++++++
 net/bridge/br_multicast.c      |    2 +
 net/bridge/br_private.h        |    2 +
 6 files changed, 200 insertions(+), 1 deletions(-)

diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
index b388579..c30c236 100644
--- a/include/uapi/linux/if_bridge.h
+++ b/include/uapi/linux/if_bridge.h
@@ -116,4 +116,30 @@ enum {
 	__IFLA_BRIDGE_MAX,
 };
 #define IFLA_BRIDGE_MAX (__IFLA_BRIDGE_MAX - 1)
+
+/* Bridge multicast database attributes
+ * [MDBA_MDB] = {
+ *     [MDBA_MCADDR]
+ *     [MDBA_BRPORT_NO]
+ * }
+ * [MDBA_ROUTER] = {
+ *    [MDBA_BRPORT_NO]
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
+	MDBA_MCADDR,
+	MDBA_BRPORT_NO,
+	__MDBA_MDB_MAX,
+};
+#define MDBA_MDB_MAX (__MDBA_MDB_MAX - 1)
+
 #endif /* _UAPI_LINUX_IF_BRIDGE_H */
diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index 3dee071..0df623f 100644
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
index 0000000..3751f7d
--- /dev/null
+++ b/net/bridge/br_mdb.c
@@ -0,0 +1,166 @@
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
+struct br_port_msg {
+	int ifindex;
+};
+
+static int br_rports_fill_info(struct sk_buff *skb, struct netlink_callback *cb,
+			       u32 seq, struct net_device *dev)
+{
+	struct net_bridge *br = netdev_priv(dev);
+	struct net_bridge_port *p;
+	struct hlist_node *n;
+	struct nlattr *nest;
+
+	if (!br->multicast_router || hlist_empty(&br->router_list)) {
+		printk(KERN_INFO "no router on bridge\n");
+		return 0;
+	}
+
+	nest = nla_nest_start(skb, MDBA_ROUTER);
+	if (nest == NULL)
+		return -EMSGSIZE;
+
+	hlist_for_each_entry_rcu(p, n, &br->router_list, rlist) {
+		if (p && nla_put_u16(skb, MDBA_BRPORT_NO, p->port_no))
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
+			    u32 seq, struct net_device *dev)
+{
+	struct net_bridge *br = netdev_priv(dev);
+	struct net_bridge_mdb_htable *mdb;
+	struct nlattr *nest;
+	unsigned int i;
+	int s_idx;
+
+	if (br->multicast_disabled) {
+		printk(KERN_INFO "multicast is disabled on bridge\n");
+		return 0;
+	}
+
+	mdb = rcu_dereference(br->mdb);
+	if (!mdb) {
+		printk(KERN_INFO "no mdb on bridge\n");
+		return 0;
+	}
+
+	cb->seq = mdb->seq;
+	s_idx = cb->args[1];
+	if (s_idx >= mdb->max)
+		return 0;
+
+	nest = nla_nest_start(skb, MDBA_MDB);
+	if (nest == NULL)
+		return -EMSGSIZE;
+
+	for (i = s_idx; i < mdb->max; i++) {
+		struct hlist_node *h;
+		struct net_bridge_mdb_entry *mp;
+		struct net_bridge_port_group *p, **pp;
+		struct net_bridge_port *port;
+
+		hlist_for_each_entry_rcu(mp, h, &mdb->mhash[i], hlist[mdb->ver]) {
+			for (pp = &mp->ports;
+			     (p = rcu_dereference(*pp)) != NULL;
+			      pp = &p->next) {
+				port = p->port;
+				if (port) {
+					printk(KERN_INFO "port %u, mcaddr: %pI4\n", port->port_no, &mp->addr.u.ip4);
+					if (nla_put_u16(skb, MDBA_BRPORT_NO, port->port_no) ||
+					    nla_put_be32(skb, MDBA_MCADDR, p->addr.u.ip4))
+						goto fail;
+				}
+			}
+		}
+	}
+
+	cb->args[1] = i;
+	nla_nest_end(skb, nest);
+	return 0;
+fail:
+	cb->args[1] = i;
+	nla_nest_cancel(skb, nest);
+	return -EMSGSIZE;
+}
+
+static int br_mdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct net_device *dev;
+	struct net *net = sock_net(skb->sk);
+	struct nlmsghdr *nlh;
+	u32 seq = cb->nlh->nlmsg_seq;
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
+					seq, RTM_GETMDB,
+					sizeof(*bpm), NLM_F_MULTI);
+			if (nlh == NULL)
+				break;
+
+			bpm = nlmsg_data(nlh);
+			bpm->ifindex = dev->ifindex;
+			if (br_mdb_fill_info(skb, cb, seq, dev) < 0) {
+				printk(KERN_INFO "br_mdb_fill_info failed\n");
+				goto fail;
+			}
+			if (br_rports_fill_info(skb, cb, seq, dev) < 0) {
+				printk(KERN_INFO "br_rports_fill_info failed\n");
+				goto fail;
+			}
+
+			nlmsg_end(skb, nlh);
+cont:
+			idx++;
+		}
+	}
+
+	rcu_read_unlock();
+	cb->args[0] = idx;
+	return skb->len;
+
+fail:
+	rcu_read_unlock();
+	nlmsg_cancel(skb, nlh);
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
