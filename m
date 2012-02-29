From: John Fastabend <john.r.fastabend@intel.com>
Subject: [RFC PATCH 1/3] net: refactor br_fdb_xxx rtnetlink routines
Date: Tue, 28 Feb 2012 23:17:14 -0800
Message-ID: <20120229071714.10937.97679.stgit@jf-dev1-dcblab>
References: <20120229070418.10937.8692.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, bhutchings@solarflare.com, roprabhu@cisco.com,
	mst@redhat.com, netdev@vger.kernel.org, gregory.v.rose@intel.com,
	davem@davemloft.net
To: jhs@mojatatu.com, shemminger@vyatta.com, kernel@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:51744 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030751Ab2B2H3R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Feb 2012 02:29:17 -0500
In-Reply-To: <20120229070418.10937.8692.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refactor PF_BRIDGE:RTM_NEWNEIGH, PF_BRIDGE:RTM_DELNEIGH, and
PF_BRIDGE:RTM_GETNEIGH messages to be handled by other ports
besides IFF_BRIDGE_PORT.

This is setup work to manage embedded FDB tables.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 net/bridge/br_fdb.c     |   88 ++++++++++++--------------------------------
 net/bridge/br_netlink.c |   95 ++++++++++++++++++++++++++++++++++++++++++++---
 net/bridge/br_private.h |    9 +++-
 3 files changed, 119 insertions(+), 73 deletions(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 5ba0c84..888a15f 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -535,44 +535,34 @@ errout:
 }
 
 /* Dump information about entries, in response to GETNEIGH */
-int br_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
+int br_fdb_dump(struct sk_buff *skb,
+		struct netlink_callback *cb,
+		struct net_device *dev,
+		int idx)
 {
-	struct net *net = sock_net(skb->sk);
-	struct net_device *dev;
-	int idx = 0;
-
-	rcu_read_lock();
-	for_each_netdev_rcu(net, dev) {
-		struct net_bridge *br = netdev_priv(dev);
-		int i;
-
-		if (!(dev->priv_flags & IFF_EBRIDGE))
-			continue;
-
-		for (i = 0; i < BR_HASH_SIZE; i++) {
-			struct hlist_node *h;
-			struct net_bridge_fdb_entry *f;
+	struct net_bridge *br = netdev_priv(dev);
+	int i;
 
-			hlist_for_each_entry_rcu(f, h, &br->hash[i], hlist) {
-				if (idx < cb->args[0])
-					goto skip;
+	for (i = 0; i < BR_HASH_SIZE; i++) {
+		struct hlist_node *h;
+		struct net_bridge_fdb_entry *f;
 
-				if (fdb_fill_info(skb, br, f,
-						  NETLINK_CB(cb->skb).pid,
-						  cb->nlh->nlmsg_seq,
-						  RTM_NEWNEIGH,
-						  NLM_F_MULTI) < 0)
-					break;
+		hlist_for_each_entry_rcu(f, h, &br->hash[i], hlist) {
+			if (idx < cb->args[0])
+				goto skip;
+
+			if (fdb_fill_info(skb, br, f,
+					  NETLINK_CB(cb->skb).pid,
+					  cb->nlh->nlmsg_seq,
+					  RTM_NEWNEIGH,
+					  NLM_F_MULTI) < 0)
+				break;
 skip:
-				++idx;
-			}
+			++idx;
 		}
 	}
-	rcu_read_unlock();
-
-	cb->args[0] = idx;
 
-	return skb->len;
+	return idx;
 }
 
 /* Update (create or replace) forwarding database entry */
@@ -614,12 +604,10 @@ static int fdb_add_entry(struct net_bridge_port *source, const __u8 *addr,
 }
 
 /* Add new permanent fdb entry with RTM_NEWNEIGH */
-int br_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+int br_fdb_add(struct nlmsghdr *nlh, struct net_device *dev)
 {
-	struct net *net = sock_net(skb->sk);
 	struct ndmsg *ndm;
 	struct nlattr *tb[NDA_MAX+1];
-	struct net_device *dev;
 	struct net_bridge_port *p;
 	const __u8 *addr;
 	int err;
@@ -630,17 +618,6 @@ int br_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 		return err;
 
 	ndm = nlmsg_data(nlh);
-	if (ndm->ndm_ifindex == 0) {
-		pr_info("bridge: RTM_NEWNEIGH with invalid ifindex\n");
-		return -EINVAL;
-	}
-
-	dev = __dev_get_by_index(net, ndm->ndm_ifindex);
-	if (dev == NULL) {
-		pr_info("bridge: RTM_NEWNEIGH with unknown ifindex\n");
-		return -ENODEV;
-	}
-
 	if (!tb[NDA_LLADDR] || nla_len(tb[NDA_LLADDR]) != ETH_ALEN) {
 		pr_info("bridge: RTM_NEWNEIGH with invalid address\n");
 		return -EINVAL;
@@ -692,33 +669,16 @@ static int fdb_delete_by_addr(struct net_bridge_port *p, const u8 *addr)
 }
 
 /* Remove neighbor entry with RTM_DELNEIGH */
-int br_fdb_delete(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+int br_fdb_del(struct nlmsghdr *nlh, struct net_device *dev)
 {
-	struct net *net = sock_net(skb->sk);
-	struct ndmsg *ndm;
 	struct net_bridge_port *p;
 	struct nlattr *llattr;
 	const __u8 *addr;
-	struct net_device *dev;
 	int err;
 
 	ASSERT_RTNL();
-	if (nlmsg_len(nlh) < sizeof(*ndm))
-		return -EINVAL;
-
-	ndm = nlmsg_data(nlh);
-	if (ndm->ndm_ifindex == 0) {
-		pr_info("bridge: RTM_DELNEIGH with invalid ifindex\n");
-		return -EINVAL;
-	}
-
-	dev = __dev_get_by_index(net, ndm->ndm_ifindex);
-	if (dev == NULL) {
-		pr_info("bridge: RTM_DELNEIGH with unknown ifindex\n");
-		return -ENODEV;
-	}
 
-	llattr = nlmsg_find_attr(nlh, sizeof(*ndm), NDA_LLADDR);
+	llattr = nlmsg_find_attr(nlh, sizeof(struct ndmsg), NDA_LLADDR);
 	if (llattr == NULL || nla_len(llattr) != ETH_ALEN) {
 		pr_info("bridge: RTM_DELNEIGH with invalid address\n");
 		return -EINVAL;
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index a1daf82..9e70191 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -211,6 +211,86 @@ static int br_validate(struct nlattr *tb[], struct nlattr *data[])
 	return 0;
 }
 
+static int rtnl_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+{
+	struct net *net = sock_net(skb->sk);
+	struct ndmsg *ndm;
+	struct nlattr *tb[NDA_MAX+1];
+	struct net_device *dev;
+	int err;
+
+	err = nlmsg_parse(nlh, sizeof(*ndm), tb, NDA_MAX, NULL);
+	if (err < 0)
+		return err;
+
+	ndm = nlmsg_data(nlh);
+	if (ndm->ndm_ifindex == 0) {
+		pr_info("bridge: RTM_NEWNEIGH with invalid ifindex\n");
+		return -EINVAL;
+	}
+
+	dev = __dev_get_by_index(net, ndm->ndm_ifindex);
+	if (dev == NULL) {
+		pr_info("bridge: RTM_NEWNEIGH with unknown ifindex\n");
+		return -ENODEV;
+	}
+
+	if (dev->priv_flags & IFF_BRIDGE_PORT)
+		err = br_fdb_add(nlh, dev);
+	else
+		err = -ENODEV;
+
+	return err;
+}
+
+static int rtnl_fdb_del(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+{
+	struct net *net = sock_net(skb->sk);
+	struct ndmsg *ndm;
+	struct net_device *dev;
+	int err;
+
+	ASSERT_RTNL();
+	if (nlmsg_len(nlh) < sizeof(*ndm))
+		return -EINVAL;
+
+	ndm = nlmsg_data(nlh);
+	if (ndm->ndm_ifindex == 0) {
+		pr_info("bridge: RTM_DELNEIGH with invalid ifindex\n");
+		return -EINVAL;
+	}
+
+	dev = __dev_get_by_index(net, ndm->ndm_ifindex);
+	if (dev == NULL) {
+		pr_info("bridge: RTM_DELNEIGH with unknown ifindex\n");
+		return -ENODEV;
+	}
+
+	if (dev->priv_flags & IFF_BRIDGE_PORT)
+		err = br_fdb_del(nlh, dev);
+	else
+		err = -ENODEV;
+
+	return err;
+}
+
+static int rtnl_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	int idx = 0;
+	struct net *net = sock_net(skb->sk);
+	struct net_device *dev;
+
+	rcu_read_lock();
+	for_each_netdev_rcu(net, dev) {
+		if (dev->priv_flags & IFF_EBRIDGE)
+			idx = br_fdb_dump(skb, cb, dev, idx);
+	}
+	rcu_read_unlock();
+
+	cb->args[0] = idx;
+	return skb->len;
+}
+
 static struct rtnl_link_ops br_link_ops __read_mostly = {
 	.kind		= "bridge",
 	.priv_size	= sizeof(struct net_bridge),
@@ -235,18 +315,21 @@ int __init br_netlink_init(void)
 			      br_rtm_setlink, NULL, NULL);
 	if (err)
 		goto err3;
+
 	err = __rtnl_register(PF_BRIDGE, RTM_NEWNEIGH,
-			      br_fdb_add, NULL, NULL);
+			      rtnl_fdb_add, NULL, NULL);
 	if (err)
-		goto err3;
+		goto  err3;
+
 	err = __rtnl_register(PF_BRIDGE, RTM_DELNEIGH,
-			      br_fdb_delete, NULL, NULL);
+			      rtnl_fdb_del, NULL, NULL);
 	if (err)
-		goto err3;
+		goto  err3;
+
 	err = __rtnl_register(PF_BRIDGE, RTM_GETNEIGH,
-			      NULL, br_fdb_dump, NULL);
+			      NULL, rtnl_fdb_dump, NULL);
 	if (err)
-		goto err3;
+		goto  err3;
 
 	return 0;
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 0b67a63..d56518a 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -363,9 +363,12 @@ extern int br_fdb_insert(struct net_bridge *br,
 extern void br_fdb_update(struct net_bridge *br,
 			  struct net_bridge_port *source,
 			  const unsigned char *addr);
-extern int br_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb);
-extern int br_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg);
-extern int br_fdb_delete(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg);
+extern int br_fdb_dump(struct sk_buff *skb,
+		       struct netlink_callback *cb,
+		       struct net_device *dev,
+		       int idx);
+extern int br_fdb_add(struct nlmsghdr *nlh, struct net_device *dev);
+extern int br_fdb_del(struct nlmsghdr *nlh, struct net_device *dev);
 
 /* br_forward.c */
 extern void br_deliver(const struct net_bridge_port *to,
