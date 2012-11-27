From: Cong Wang <amwang@redhat.com>
Subject: [RFC PATCH 2/2] bridge: export multicast database via netlink
Date: Tue, 27 Nov 2012 17:49:44 +0800
Message-ID: <1354009785-20014-2-git-send-email-amwang@redhat.com>
References: <1354009785-20014-1-git-send-email-amwang@redhat.com>
Cc: bridge@lists.linux-foundation.org, Cong Wang <amwang@redhat.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10270 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758349Ab2K0JvK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2012 04:51:10 -0500
In-Reply-To: <1354009785-20014-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on net-next.

Warning: this patch is still a draft! :)

This patch exports bridge multicast database via netlink
message type RTM_GETMDB. Similar to fdb, but currently bridge-specific.
We may need to support modify multicast database too (RTM_{ADD,DEL}MDB).

So, the questions are:

1) Is this design okay?
2) Do we need to make it generic like fdb?
3) Do we need to support RTM_{ADD,DEL}MDB?

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Thomas Graf <tgraf@suug.ch>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 include/uapi/linux/if_bridge.h |   37 +++++++++
 include/uapi/linux/rtnetlink.h |    3 +
 net/bridge/Makefile            |    2 +-
 net/bridge/br_mdb.c            |  174 ++++++++++++++++++++++++++++++++++++++++
 net/bridge/br_multicast.c      |    1 +
 net/bridge/br_private.h        |    1 +
 6 files changed, 217 insertions(+), 1 deletions(-)
 create mode 100644 net/bridge/br_mdb.c

diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
index b388579..f5655ea 100644
--- a/include/uapi/linux/if_bridge.h
+++ b/include/uapi/linux/if_bridge.h
@@ -116,4 +116,41 @@ enum {
 	__IFLA_BRIDGE_MAX,
 };
 #define IFLA_BRIDGE_MAX (__IFLA_BRIDGE_MAX - 1)
+
+/* Bridge multicast database attributes
+ * [MDBA_MDB] = {
+ *    [MDBA_MCADDR]
+ *    [MDBA_BRPORT] = {
+ *        [MDBA_BRPORT_NO]
+ *    }
+ * }
+ * [MDBA_ROUTER] = {
+ *    [MDBA_BRPORT] = {
+ *        [MDBA_BRPORT_NO]
+ *    }
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
+	MDBA_MDB_MCADDR,
+	MDBA_MDB_BRPORT,
+	__MDBA_MDB_MAX,
+};
+#define MDBA_MDB_MAX (__MDBA_MDB_MAX - 1)
+
+enum {
+	MDBA_BRPORT_UNSPEC,
+	MDBA_BRPORT_NO,
+	__MDBA_BRPORT_MAX,
+};
+#define MDBA_BRPORT_MAX (__MDBA_BRPORT_MAX - 1)
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
index 0000000..dc73091
--- /dev/null
+++ b/net/bridge/br_mdb.c
@@ -0,0 +1,174 @@
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
+	struct nlattr *nest, *nest2;
+
+	if (!br->multicast_router || hlist_empty(&br->router_list)) {
+		printk(KERN_INFO "no router on bridge\n");
+		return 0;
+	}
+
+	nest = nla_nest_start(skb, MDBA_ROUTER);
+	if (nest == NULL)
+		return -EMSGSIZE;
+	nest2 = nla_nest_start(skb, MDBA_MDB_BRPORT);
+	if (nest2 == NULL)
+		goto fail;
+
+	hlist_for_each_entry_rcu(p, n, &br->router_list, rlist) {
+		if (p && nla_put_u16(skb, MDBA_BRPORT_NO, p->port_no)) {
+			nla_nest_cancel(skb, nest2);
+			goto fail;
+		}
+	}
+
+	nla_nest_end(skb, nest2);
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
+	struct nlattr *nest, *nest2;
+	unsigned int i;
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
+			if (nla_put_be32(skb, MDBA_MDB_MCADDR, mp->addr.u.ip4))
+				goto fail;
+
+			nest2 = nla_nest_start(skb, MDBA_MDB_BRPORT);
+			if (nest2 == NULL)
+				goto fail;
+
+			for (pp = &mp->ports;
+			     (p = rcu_dereference(*pp)) != NULL;
+			      pp = &p->next) {
+				port = p->port;
+				if (port) {
+					printk(KERN_INFO "port %u, mcaddr: %pI4\n", port->port_no, &mp->addr.u.ip4);
+					if (nla_put_u16(skb, MDBA_BRPORT_NO, port->port_no)) {
+						goto fail;
+					}
+				}
+			}
+
+			nla_nest_end(skb, nest2);
+		}
+	}
+
+	nla_nest_end(skb, nest);
+	return 0;
+fail:
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
+	cb->seq = net->dev_base_seq;
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
index 2417434..be69cd4 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1584,6 +1584,7 @@ void br_multicast_init(struct net_bridge *br)
 		    br_multicast_querier_expired, (unsigned long)br);
 	setup_timer(&br->multicast_query_timer, br_multicast_query_expired,
 		    (unsigned long)br);
+	br_mdb_init();
 }
 
 void br_multicast_open(struct net_bridge *br)
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index eb9cd42..bf0f6d5 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -432,6 +432,7 @@ extern int br_multicast_set_port_router(struct net_bridge_port *p,
 extern int br_multicast_toggle(struct net_bridge *br, unsigned long val);
 extern int br_multicast_set_querier(struct net_bridge *br, unsigned long val);
 extern int br_multicast_set_hash_max(struct net_bridge *br, unsigned long val);
+extern void br_mdb_init(void);
 
 static inline bool br_multicast_is_router(struct net_bridge *br)
 {
-- 
1.7.7.6
