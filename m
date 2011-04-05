From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 5/7] bridge: allow creating/deleting fdb entries via netlink
Date: Mon, 04 Apr 2011 17:03:31 -0700
Message-ID: <20110405000537.372602366@vyatta.com>
References: <20110405000326.714524584@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42825 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750906Ab1DEAJu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2011 20:09:50 -0400
Content-Disposition: inline; filename=br-fdb-newneigh.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use RTM_NEWNEIGH and RTM_DELNEIGH to allow updating of entries
in bridge forwarding table. This allows manipulating static entries
which is not possible with existing tools.

Example (using bridge extensions to iproute2)
   # br fdb add 00:02:03:04:05:06 dev eth0

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 net/bridge/br_fdb.c     |  139 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/bridge/br_netlink.c |    3 +
 net/bridge/br_private.h |    2 
 3 files changed, 144 insertions(+)

--- a/net/bridge/br_fdb.c	2011-03-22 10:25:00.329008182 -0700
+++ b/net/bridge/br_fdb.c	2011-03-22 10:25:01.057042585 -0700
@@ -555,3 +555,142 @@ skip:
 
 	return skb->len;
 }
+
+/* Create new static fdb entry */
+static int fdb_add_entry(struct net_bridge_port *source, const __u8 *addr,
+			 __u16 state)
+{
+	struct net_bridge *br = source->br;
+	struct hlist_head *head = &br->hash[br_mac_hash(addr)];
+	struct net_bridge_fdb_entry *fdb;
+
+	fdb = fdb_find(head, addr);
+	if (fdb)
+		return -EEXIST;
+
+	fdb = fdb_create(head, source, addr);
+	if (!fdb)
+		return -ENOMEM;
+
+	if (state & NUD_PERMANENT)
+		fdb->is_local = fdb->is_static = 1;
+	else if (state & NUD_NOARP)
+		fdb->is_static = 1;
+	return 0;
+}
+
+/* Add new permanent fdb entry with RTM_NEWNEIGH */
+int br_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+{
+	struct net *net = sock_net(skb->sk);
+	struct ndmsg *ndm;
+	struct nlattr *tb[NDA_MAX+1];
+	struct net_device *dev;
+	struct net_bridge_port *p;
+	const __u8 *addr;
+	int err;
+
+	ASSERT_RTNL();
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
+	if (!tb[NDA_LLADDR] || nla_len(tb[NDA_LLADDR]) != ETH_ALEN) {
+		pr_info("bridge: RTM_NEWNEIGH with invalid address\n");
+		return -EINVAL;
+	}
+
+	addr = nla_data(tb[NDA_LLADDR]);
+	if (!is_valid_ether_addr(addr)) {
+		pr_info("bridge: RTM_NEWNEIGH with invalid ether address\n");
+		return -EINVAL;
+	}
+
+	p = br_port_get_rtnl(dev);
+	if (p == NULL) {
+		pr_info("bridge: RTM_NEWNEIGH %s not a bridge port\n",
+			dev->name);
+		return -EINVAL;
+	}
+
+	spin_lock_bh(&p->br->hash_lock);
+	err = fdb_add_entry(p, addr, ndm->ndm_state);
+	spin_unlock_bh(&p->br->hash_lock);
+
+	return err;
+}
+
+static int fdb_delete_by_addr(struct net_bridge_port *p, const u8 *addr)
+{
+	struct net_bridge *br = p->br;
+	struct hlist_head *head = &br->hash[br_mac_hash(addr)];
+	struct net_bridge_fdb_entry *fdb;
+
+	fdb = fdb_find(head, addr);
+	if (!fdb)
+		return -ENOENT;
+
+	fdb_delete(fdb);
+	return 0;
+}
+
+/* Remove neighbor entry with RTM_DELNEIGH */
+int br_fdb_delete(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+{
+	struct net *net = sock_net(skb->sk);
+	struct ndmsg *ndm;
+	struct net_bridge_port *p;
+	struct nlattr *llattr;
+	const __u8 *addr;
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
+	llattr = nlmsg_find_attr(nlh, sizeof(*ndm), NDA_LLADDR);
+	if (llattr == NULL || nla_len(llattr) != ETH_ALEN) {
+		pr_info("bridge: RTM_DELNEIGH with invalid address\n");
+		return -EINVAL;
+	}
+
+	addr = nla_data(llattr);
+
+	p = br_port_get_rtnl(dev);
+	if (p == NULL) {
+		pr_info("bridge: RTM_DELNEIGH %s not a bridge port\n",
+			dev->name);
+		return -EINVAL;
+	}
+
+	spin_lock_bh(&p->br->hash_lock);
+	err = fdb_delete_by_addr(p, addr);
+	spin_unlock_bh(&p->br->hash_lock);
+
+	return err;
+}
--- a/net/bridge/br_netlink.c	2011-03-22 10:25:00.329008182 -0700
+++ b/net/bridge/br_netlink.c	2011-03-22 10:25:01.057042585 -0700
@@ -196,6 +196,9 @@ int __init br_netlink_init(void)
 
 	/* Only the first call to __rtnl_register can fail */
 	__rtnl_register(PF_BRIDGE, RTM_SETLINK, br_rtm_setlink, NULL);
+
+	__rtnl_register(PF_BRIDGE, RTM_NEWNEIGH, br_fdb_add, NULL);
+	__rtnl_register(PF_BRIDGE, RTM_DELNEIGH, br_fdb_delete, NULL);
 	__rtnl_register(PF_BRIDGE, RTM_GETNEIGH, NULL, br_fdb_dump);
 
 	return 0;
--- a/net/bridge/br_private.h	2011-03-22 10:25:00.329008182 -0700
+++ b/net/bridge/br_private.h	2011-03-22 10:25:01.057042585 -0700
@@ -355,6 +355,8 @@ extern void br_fdb_update(struct net_bri
 			  struct net_bridge_port *source,
 			  const unsigned char *addr);
 extern int br_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb);
+extern int br_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg);
+extern int br_fdb_delete(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg);
 
 /* br_forward.c */
 extern void br_deliver(const struct net_bridge_port *to,


