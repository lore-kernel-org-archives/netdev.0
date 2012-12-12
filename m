From: Cong Wang <amwang@redhat.com>
Subject: [PATCH net-next 1/2] bridge: notify mdb changes via netlink
Date: Wed, 12 Dec 2012 16:23:07 +0800
Message-ID: <1355300590-2390-1-git-send-email-amwang@redhat.com>
Cc: bridge@lists.linux-foundation.org, Cong Wang <amwang@redhat.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60528 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751160Ab2LLIXv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2012 03:23:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

As Stephen mentioned, we need to monitor the mdb
changes in user-space, so add notifications via netlink too.

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 include/uapi/linux/rtnetlink.h |    6 +++
 net/bridge/br_mdb.c            |   80 ++++++++++++++++++++++++++++++++++++++++
 net/bridge/br_multicast.c      |    2 +
 net/bridge/br_private.h        |    2 +
 4 files changed, 90 insertions(+), 0 deletions(-)

diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index 354a1e7..7a5eb19 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -125,6 +125,10 @@ enum {
 	RTM_GETNETCONF = 82,
 #define RTM_GETNETCONF RTM_GETNETCONF
 
+	RTM_NEWMDB = 84,
+#define RTM_NEWMDB RTM_NEWMDB
+	RTM_DELMDB = 85,
+#define RTM_DELMDB RTM_DELMDB
 	RTM_GETMDB = 86,
 #define RTM_GETMDB RTM_GETMDB
 
@@ -607,6 +611,8 @@ enum rtnetlink_groups {
 #define RTNLGRP_IPV4_NETCONF	RTNLGRP_IPV4_NETCONF
 	RTNLGRP_IPV6_NETCONF,
 #define RTNLGRP_IPV6_NETCONF	RTNLGRP_IPV6_NETCONF
+	RTNLGRP_MDB,
+#define RTNLGRP_MDB		RTNLGRP_MDB
 	__RTNLGRP_MAX
 };
 #define RTNLGRP_MAX	(__RTNLGRP_MAX - 1)
diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index ccc43a9..a8cfbf5 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -155,6 +155,86 @@ out:
 	return skb->len;
 }
 
+static int nlmsg_populate_mdb_fill(struct sk_buff *skb,
+				   struct net_device *dev,
+				   struct br_mdb_entry *entry, u32 pid,
+				   u32 seq, int type, unsigned int flags)
+{
+	struct nlmsghdr *nlh;
+	struct br_port_msg *bpm;
+	struct nlattr *nest, *nest2;
+
+	nlh = nlmsg_put(skb, pid, seq, type, sizeof(*bpm), NLM_F_MULTI);
+	if (!nlh)
+		return -EMSGSIZE;
+
+	bpm = nlmsg_data(nlh);
+	bpm->family  = AF_BRIDGE;
+	bpm->ifindex = dev->ifindex;
+	nest = nla_nest_start(skb, MDBA_MDB);
+	if (nest == NULL)
+		goto cancel;
+	nest2 = nla_nest_start(skb, MDBA_MDB_ENTRY);
+	if (nest2 == NULL)
+		goto end;
+
+	if (nla_put(skb, MDBA_MDB_ENTRY_INFO, sizeof(*entry), entry))
+		goto end;
+
+	nla_nest_end(skb, nest2);
+	nla_nest_end(skb, nest);
+	return nlmsg_end(skb, nlh);
+
+end:
+	nla_nest_end(skb, nest);
+cancel:
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
+}
+
+static inline size_t rtnl_mdb_nlmsg_size(void)
+{
+	return NLMSG_ALIGN(sizeof(struct br_port_msg))
+		+ nla_total_size(sizeof(struct br_mdb_entry));
+}
+
+static void __br_mdb_notify(struct net_device *dev, struct br_mdb_entry *entry,
+			    int type)
+{
+	struct net *net = dev_net(dev);
+	struct sk_buff *skb;
+	int err = -ENOBUFS;
+
+	skb = nlmsg_new(rtnl_mdb_nlmsg_size(), GFP_ATOMIC);
+	if (!skb)
+		goto errout;
+
+	err = nlmsg_populate_mdb_fill(skb, dev, entry, 0, 0, type, NTF_SELF);
+	if (err < 0) {
+		kfree_skb(skb);
+		goto errout;
+	}
+
+	rtnl_notify(skb, net, 0, RTNLGRP_MDB, NULL, GFP_ATOMIC);
+	return;
+errout:
+	rtnl_set_sk_err(net, RTNLGRP_MDB, err);
+}
+
+void br_mdb_notify(struct net_device *dev, struct net_bridge_port *port,
+		   struct br_ip *group, int type)
+{
+	struct br_mdb_entry entry;
+
+	entry.ifindex = port->dev->ifindex;
+	entry.addr.proto = group->proto;
+	entry.addr.u.ip4 = group->u.ip4;
+#if IS_ENABLED(CONFIG_IPV6)
+	entry.addr.u.ip6 = group->u.ip6;
+#endif
+	__br_mdb_notify(dev, &entry, type);
+}
+
 void br_mdb_init(void)
 {
 	rtnl_register(PF_BRIDGE, RTM_GETMDB, NULL, br_mdb_dump, NULL);
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 847b98a1..d929586 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -681,6 +681,7 @@ static int br_multicast_add_group(struct net_bridge *br,
 		    (unsigned long)p);
 
 	rcu_assign_pointer(*pp, p);
+	br_mdb_notify(br->dev, port, group, RTM_NEWMDB);
 
 found:
 	mod_timer(&p->timer, now + br->multicast_membership_interval);
@@ -1240,6 +1241,7 @@ static void br_multicast_leave_group(struct net_bridge *br,
 			hlist_del_init(&p->mglist);
 			del_timer(&p->timer);
 			call_rcu_bh(&p->rcu, br_multicast_free_pg);
+			br_mdb_notify(br->dev, port, group, RTM_DELMDB);
 
 			if (!mp->ports && !mp->mglist &&
 			    netif_running(br->dev))
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index f95b766..2807c76 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -435,6 +435,8 @@ extern int br_multicast_toggle(struct net_bridge *br, unsigned long val);
 extern int br_multicast_set_querier(struct net_bridge *br, unsigned long val);
 extern int br_multicast_set_hash_max(struct net_bridge *br, unsigned long val);
 extern void br_mdb_init(void);
+extern void br_mdb_notify(struct net_device *dev, struct net_bridge_port *port,
+			  struct br_ip *group, int type);
 
 static inline bool br_multicast_is_router(struct net_bridge *br)
 {
-- 
1.7.7.6
