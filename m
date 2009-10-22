From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] rtnetlink: speedup rtnl_dump_ifinfo()
Date: Thu, 22 Oct 2009 16:34:41 +0200
Message-ID: <4AE06D81.4050003@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Benjamin LaHaise <bcrl@lhnet.ca>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:35158 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754812AbZJVOeq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2009 10:34:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When handling large number of netdevice, rtnl_dump_ifinfo()
is very slow because it has O(N^2) complexity.

Instead of scanning one single list, we can use the 256 sub lists
of the dev_index hash table.

This considerably speedups "ip link" operations

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/net_namespace.h |    4 +++
 net/core/dev.c              |    7 +-----
 net/core/rtnetlink.c        |   37 ++++++++++++++++++++++------------
 3 files changed, 30 insertions(+), 18 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 6994101..0addd45 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -28,6 +28,10 @@ struct ctl_table_header;
 struct net_generic;
 struct sock;
 
+
+#define NETDEV_HASHBITS    8
+#define NETDEV_HASHENTRIES (1 << NETDEV_HASHBITS)
+
 struct net {
 	atomic_t		count;		/* To decided when the network
 						 *  namespace should be freed.
diff --git a/net/core/dev.c b/net/core/dev.c
index fa88dcd..e7bada1 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -193,18 +193,15 @@ static struct list_head ptype_all __read_mostly;	/* Taps */
 DEFINE_RWLOCK(dev_base_lock);
 EXPORT_SYMBOL(dev_base_lock);
 
-#define NETDEV_HASHBITS	8
-#define NETDEV_HASHENTRIES (1 << NETDEV_HASHBITS)
-
 static inline struct hlist_head *dev_name_hash(struct net *net, const char *name)
 {
 	unsigned hash = full_name_hash(name, strnlen(name, IFNAMSIZ));
-	return &net->dev_name_head[hash & ((1 << NETDEV_HASHBITS) - 1)];
+	return &net->dev_name_head[hash & (NETDEV_HASHENTRIES - 1)];
 }
 
 static inline struct hlist_head *dev_index_hash(struct net *net, int ifindex)
 {
-	return &net->dev_index_head[ifindex & ((1 << NETDEV_HASHBITS) - 1)];
+	return &net->dev_index_head[ifindex & (NETDEV_HASHENTRIES - 1)];
 }
 
 /* Device list insertion */
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index ba13b09..52ea418 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -682,22 +682,33 @@ nla_put_failure:
 static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct net *net = sock_net(skb->sk);
-	int idx;
-	int s_idx = cb->args[0];
+	int h, s_h;
+	int idx = 0, s_idx;
 	struct net_device *dev;
-
-	idx = 0;
-	for_each_netdev(net, dev) {
-		if (idx < s_idx)
-			goto cont;
-		if (rtnl_fill_ifinfo(skb, dev, RTM_NEWLINK,
-				     NETLINK_CB(cb->skb).pid,
-				     cb->nlh->nlmsg_seq, 0, NLM_F_MULTI) <= 0)
-			break;
+	struct hlist_head *head;
+	struct hlist_node *node;
+
+	s_h = cb->args[0];
+	s_idx = cb->args[1];
+
+	for (h = s_h; h < NETDEV_HASHENTRIES; h++, s_idx = 0) {
+		idx = 0;
+		head = &net->dev_index_head[h];
+		hlist_for_each_entry(dev, node, head, index_hlist) {
+			if (idx < s_idx)
+				goto cont;
+			if (rtnl_fill_ifinfo(skb, dev, RTM_NEWLINK,
+					     NETLINK_CB(cb->skb).pid,
+					     cb->nlh->nlmsg_seq, 0,
+					     NLM_F_MULTI) <= 0)
+				goto out;
 cont:
-		idx++;
+			idx++;
+		}
 	}
-	cb->args[0] = idx;
+out:
+	cb->args[1] = idx;
+	cb->args[0] = h;
 
 	return skb->len;
 }
