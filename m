From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH net-next 1/1] netns: IPv6 address labels per namespace.
Date: Tue, 27 May 2008 16:40:42 +0200
Message-ID: <20080527144050.754524679@theryb.frec.bull.fr>
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	Benjamin Thery <benjamin.thery@bull.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:47168 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758259AbYE0Ps4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 11:48:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes IPv6 address labels per network namespace.
It keeps the global label tables, ip6addrlbl_table, but 
adds a 'net' member to each ip6addrlbl_entry.
This new member is taken into account when matching labels.

Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 include/net/addrconf.h |    3 +
 net/ipv6/addrconf.c    |   12 +++---
 net/ipv6/addrlabel.c   |   90 ++++++++++++++++++++++++++++++++-----------------
 3 files changed, 68 insertions(+), 37 deletions(-)

Index: net-next-2.6/include/net/addrconf.h
===================================================================
--- net-next-2.6.orig/include/net/addrconf.h
+++ net-next-2.6/include/net/addrconf.h
@@ -99,7 +99,8 @@ extern void			addrconf_leave_solict(stru
  */
 extern int			ipv6_addr_label_init(void);
 extern void			ipv6_addr_label_rtnl_register(void);
-extern u32			ipv6_addr_label(const struct in6_addr *addr,
+extern u32			ipv6_addr_label(struct net *net,
+						const struct in6_addr *addr,
 						int type, int ifindex);
 
 /*
Index: net-next-2.6/net/ipv6/addrconf.c
===================================================================
--- net-next-2.6.orig/net/ipv6/addrconf.c
+++ net-next-2.6/net/ipv6/addrconf.c
@@ -953,7 +953,8 @@ static inline int ipv6_saddr_preferred(i
 	return 0;
 }
 
-static int ipv6_get_saddr_eval(struct ipv6_saddr_score *score,
+static int ipv6_get_saddr_eval(struct net *net,
+			       struct ipv6_saddr_score *score,
 			       struct ipv6_saddr_dst *dst,
 			       int i)
 {
@@ -1032,7 +1033,8 @@ static int ipv6_get_saddr_eval(struct ip
 		break;
 	case IPV6_SADDR_RULE_LABEL:
 		/* Rule 6: Prefer matching label */
-		ret = ipv6_addr_label(&score->ifa->addr, score->addr_type,
+		ret = ipv6_addr_label(net,
+				      &score->ifa->addr, score->addr_type,
 				      score->ifa->idev->dev->ifindex) == dst->label;
 		break;
 #ifdef CONFIG_IPV6_PRIVACY
@@ -1086,7 +1088,7 @@ int ipv6_dev_get_saddr(struct net_device
 	dst.addr = daddr;
 	dst.ifindex = dst_dev ? dst_dev->ifindex : 0;
 	dst.scope = __ipv6_addr_src_scope(dst_type);
-	dst.label = ipv6_addr_label(daddr, dst_type, dst.ifindex);
+	dst.label = ipv6_addr_label(net, daddr, dst_type, dst.ifindex);
 	dst.prefs = prefs;
 
 	hiscore->rule = -1;
@@ -1154,8 +1156,8 @@ int ipv6_dev_get_saddr(struct net_device
 			for (i = 0; i < IPV6_SADDR_RULE_MAX; i++) {
 				int minihiscore, miniscore;
 
-				minihiscore = ipv6_get_saddr_eval(hiscore, &dst, i);
-				miniscore = ipv6_get_saddr_eval(score, &dst, i);
+				minihiscore = ipv6_get_saddr_eval(net, hiscore, &dst, i);
+				miniscore = ipv6_get_saddr_eval(net, score, &dst, i);
 
 				if (minihiscore > miniscore) {
 					if (i == IPV6_SADDR_RULE_SCOPE &&
Index: net-next-2.6/net/ipv6/addrlabel.c
===================================================================
--- net-next-2.6.orig/net/ipv6/addrlabel.c
+++ net-next-2.6/net/ipv6/addrlabel.c
@@ -29,6 +29,7 @@
  */
 struct ip6addrlbl_entry
 {
+	struct net *net;
 	struct in6_addr prefix;
 	int prefixlen;
 	int ifindex;
@@ -65,7 +66,7 @@ static struct ip6addrlbl_table
 
 #define IPV6_ADDR_LABEL_DEFAULT	0xffffffffUL
 
-static const __initdata struct ip6addrlbl_init_table
+static const __net_initdata struct ip6addrlbl_init_table
 {
 	const struct in6_addr *prefix;
 	int prefixlen;
@@ -108,6 +109,7 @@ static const __initdata struct ip6addrlb
 /* Object management */
 static inline void ip6addrlbl_free(struct ip6addrlbl_entry *p)
 {
+	release_net(p->net);
 	kfree(p);
 }
 
@@ -128,10 +130,13 @@ static inline void ip6addrlbl_put(struct
 }
 
 /* Find label */
-static int __ip6addrlbl_match(struct ip6addrlbl_entry *p,
+static int __ip6addrlbl_match(struct net *net,
+			      struct ip6addrlbl_entry *p,
 			      const struct in6_addr *addr,
 			      int addrtype, int ifindex)
 {
+	if (!net_eq(p->net, net))
+		return 0;
 	if (p->ifindex && p->ifindex != ifindex)
 		return 0;
 	if (p->addrtype && p->addrtype != addrtype)
@@ -141,19 +146,21 @@ static int __ip6addrlbl_match(struct ip6
 	return 1;
 }
 
-static struct ip6addrlbl_entry *__ipv6_addr_label(const struct in6_addr *addr,
+static struct ip6addrlbl_entry *__ipv6_addr_label(struct net *net,
+						  const struct in6_addr *addr,
 						  int type, int ifindex)
 {
 	struct hlist_node *pos;
 	struct ip6addrlbl_entry *p;
 	hlist_for_each_entry_rcu(p, pos, &ip6addrlbl_table.head, list) {
-		if (__ip6addrlbl_match(p, addr, type, ifindex))
+		if (__ip6addrlbl_match(net, p, addr, type, ifindex))
 			return p;
 	}
 	return NULL;
 }
 
-u32 ipv6_addr_label(const struct in6_addr *addr, int type, int ifindex)
+u32 ipv6_addr_label(struct net *net,
+		    const struct in6_addr *addr, int type, int ifindex)
 {
 	u32 label;
 	struct ip6addrlbl_entry *p;
@@ -161,7 +168,7 @@ u32 ipv6_addr_label(const struct in6_add
 	type &= IPV6_ADDR_MAPPED | IPV6_ADDR_COMPATv4 | IPV6_ADDR_LOOPBACK;
 
 	rcu_read_lock();
-	p = __ipv6_addr_label(addr, type, ifindex);
+	p = __ipv6_addr_label(net, addr, type, ifindex);
 	label = p ? p->label : IPV6_ADDR_LABEL_DEFAULT;
 	rcu_read_unlock();
 
@@ -174,7 +181,8 @@ u32 ipv6_addr_label(const struct in6_add
 }
 
 /* allocate one entry */
-static struct ip6addrlbl_entry *ip6addrlbl_alloc(const struct in6_addr *prefix,
+static struct ip6addrlbl_entry *ip6addrlbl_alloc(struct net *net,
+						 const struct in6_addr *prefix,
 						 int prefixlen, int ifindex,
 						 u32 label)
 {
@@ -216,6 +224,7 @@ static struct ip6addrlbl_entry *ip6addrl
 	newp->addrtype = addrtype;
 	newp->label = label;
 	INIT_HLIST_NODE(&newp->list);
+	newp->net = hold_net(net);
 	atomic_set(&newp->refcnt, 1);
 	return newp;
 }
@@ -237,6 +246,7 @@ static int __ip6addrlbl_add(struct ip6ad
 		hlist_for_each_entry_safe(p, pos, n,
 					  &ip6addrlbl_table.head, list) {
 			if (p->prefixlen == newp->prefixlen &&
+			    net_eq(p->net, newp->net) &&
 			    p->ifindex == newp->ifindex &&
 			    ipv6_addr_equal(&p->prefix, &newp->prefix)) {
 				if (!replace) {
@@ -261,7 +271,8 @@ out:
 }
 
 /* add a label */
-static int ip6addrlbl_add(const struct in6_addr *prefix, int prefixlen,
+static int ip6addrlbl_add(struct net *net,
+			  const struct in6_addr *prefix, int prefixlen,
 			  int ifindex, u32 label, int replace)
 {
 	struct ip6addrlbl_entry *newp;
@@ -274,7 +285,7 @@ static int ip6addrlbl_add(const struct i
 			(unsigned int)label,
 			replace);
 
-	newp = ip6addrlbl_alloc(prefix, prefixlen, ifindex, label);
+	newp = ip6addrlbl_alloc(net, prefix, prefixlen, ifindex, label);
 	if (IS_ERR(newp))
 		return PTR_ERR(newp);
 	spin_lock(&ip6addrlbl_table.lock);
@@ -286,7 +297,8 @@ static int ip6addrlbl_add(const struct i
 }
 
 /* remove a label */
-static int __ip6addrlbl_del(const struct in6_addr *prefix, int prefixlen,
+static int __ip6addrlbl_del(struct net *net,
+			    const struct in6_addr *prefix, int prefixlen,
 			    int ifindex)
 {
 	struct ip6addrlbl_entry *p = NULL;
@@ -300,6 +312,7 @@ static int __ip6addrlbl_del(const struct
 
 	hlist_for_each_entry_safe(p, pos, n, &ip6addrlbl_table.head, list) {
 		if (p->prefixlen == prefixlen &&
+		    net_eq(p->net, net) &&
 		    p->ifindex == ifindex &&
 		    ipv6_addr_equal(&p->prefix, prefix)) {
 			hlist_del_rcu(&p->list);
@@ -311,7 +324,8 @@ static int __ip6addrlbl_del(const struct
 	return ret;
 }
 
-static int ip6addrlbl_del(const struct in6_addr *prefix, int prefixlen,
+static int ip6addrlbl_del(struct net *net,
+			  const struct in6_addr *prefix, int prefixlen,
 			  int ifindex)
 {
 	struct in6_addr prefix_buf;
@@ -324,13 +338,13 @@ static int ip6addrlbl_del(const struct i
 
 	ipv6_addr_prefix(&prefix_buf, prefix, prefixlen);
 	spin_lock(&ip6addrlbl_table.lock);
-	ret = __ip6addrlbl_del(&prefix_buf, prefixlen, ifindex);
+	ret = __ip6addrlbl_del(net, &prefix_buf, prefixlen, ifindex);
 	spin_unlock(&ip6addrlbl_table.lock);
 	return ret;
 }
 
 /* add default label */
-static __init int ip6addrlbl_init(void)
+static int __net_init ip6addrlbl_net_init(struct net *net)
 {
 	int err = 0;
 	int i;
@@ -338,7 +352,8 @@ static __init int ip6addrlbl_init(void)
 	ADDRLABEL(KERN_DEBUG "%s()\n", __func__);
 
 	for (i = 0; i < ARRAY_SIZE(ip6addrlbl_init_table); i++) {
-		int ret = ip6addrlbl_add(ip6addrlbl_init_table[i].prefix,
+		int ret = ip6addrlbl_add(net,
+					 ip6addrlbl_init_table[i].prefix,
 					 ip6addrlbl_init_table[i].prefixlen,
 					 0,
 					 ip6addrlbl_init_table[i].label, 0);
@@ -349,11 +364,32 @@ static __init int ip6addrlbl_init(void)
 	return err;
 }
 
+static void __net_exit ip6addrlbl_net_exit(struct net *net)
+{
+	struct ip6addrlbl_entry *p = NULL;
+	struct hlist_node *pos, *n;
+
+	/* Remove all labels belonging to the exiting net */
+	spin_lock(&ip6addrlbl_table.lock);
+	hlist_for_each_entry_safe(p, pos, n, &ip6addrlbl_table.head, list) {
+		if (net_eq(p->net, net)) {
+			hlist_del_rcu(&p->list);
+			ip6addrlbl_put(p);
+		}
+	}
+	spin_unlock(&ip6addrlbl_table.lock);
+}
+
+static struct pernet_operations ipv6_addr_label_ops = {
+	.init = ip6addrlbl_net_init,
+	.exit = ip6addrlbl_net_exit,
+};
+
 int __init ipv6_addr_label_init(void)
 {
 	spin_lock_init(&ip6addrlbl_table.lock);
 
-	return ip6addrlbl_init();
+	return register_pernet_subsys(&ipv6_addr_label_ops);
 }
 
 static const struct nla_policy ifal_policy[IFAL_MAX+1] = {
@@ -371,9 +407,6 @@ static int ip6addrlbl_newdel(struct sk_b
 	u32 label;
 	int err = 0;
 
-	if (net != &init_net)
-		return 0;
-
 	err = nlmsg_parse(nlh, sizeof(*ifal), tb, IFAL_MAX, ifal_policy);
 	if (err < 0)
 		return err;
@@ -385,7 +418,7 @@ static int ip6addrlbl_newdel(struct sk_b
 		return -EINVAL;
 
 	if (ifal->ifal_index &&
-	    !__dev_get_by_index(&init_net, ifal->ifal_index))
+	    !__dev_get_by_index(net, ifal->ifal_index))
 		return -EINVAL;
 
 	if (!tb[IFAL_ADDRESS])
@@ -403,12 +436,12 @@ static int ip6addrlbl_newdel(struct sk_b
 
 	switch(nlh->nlmsg_type) {
 	case RTM_NEWADDRLABEL:
-		err = ip6addrlbl_add(pfx, ifal->ifal_prefixlen,
+		err = ip6addrlbl_add(net, pfx, ifal->ifal_prefixlen,
 				     ifal->ifal_index, label,
 				     nlh->nlmsg_flags & NLM_F_REPLACE);
 		break;
 	case RTM_DELADDRLABEL:
-		err = ip6addrlbl_del(pfx, ifal->ifal_prefixlen,
+		err = ip6addrlbl_del(net, pfx, ifal->ifal_prefixlen,
 				     ifal->ifal_index);
 		break;
 	default:
@@ -458,12 +491,10 @@ static int ip6addrlbl_dump(struct sk_buf
 	int idx = 0, s_idx = cb->args[0];
 	int err;
 
-	if (net != &init_net)
-		return 0;
-
 	rcu_read_lock();
 	hlist_for_each_entry_rcu(p, pos, &ip6addrlbl_table.head, list) {
-		if (idx >= s_idx) {
+		if (idx >= s_idx &&
+		    net_eq(p->net, net)) {
 			if ((err = ip6addrlbl_fill(skb, p,
 						   ip6addrlbl_table.seq,
 						   NETLINK_CB(cb->skb).pid,
@@ -499,9 +530,6 @@ static int ip6addrlbl_get(struct sk_buff
 	struct ip6addrlbl_entry *p;
 	struct sk_buff *skb;
 
-	if (net != &init_net)
-		return 0;
-
 	err = nlmsg_parse(nlh, sizeof(*ifal), tb, IFAL_MAX, ifal_policy);
 	if (err < 0)
 		return err;
@@ -513,7 +541,7 @@ static int ip6addrlbl_get(struct sk_buff
 		return -EINVAL;
 
 	if (ifal->ifal_index &&
-	    !__dev_get_by_index(&init_net, ifal->ifal_index))
+	    !__dev_get_by_index(net, ifal->ifal_index))
 		return -EINVAL;
 
 	if (!tb[IFAL_ADDRESS])
@@ -524,7 +552,7 @@ static int ip6addrlbl_get(struct sk_buff
 		return -EINVAL;
 
 	rcu_read_lock();
-	p = __ipv6_addr_label(addr, ipv6_addr_type(addr), ifal->ifal_index);
+	p = __ipv6_addr_label(net, addr, ipv6_addr_type(addr), ifal->ifal_index);
 	if (p && ip6addrlbl_hold(p))
 		p = NULL;
 	lseq = ip6addrlbl_table.seq;
@@ -552,7 +580,7 @@ static int ip6addrlbl_get(struct sk_buff
 		goto out;
 	}
 
-	err = rtnl_unicast(skb, &init_net, NETLINK_CB(in_skb).pid);
+	err = rtnl_unicast(skb, net, NETLINK_CB(in_skb).pid);
 out:
 	return err;
 }

-- 
