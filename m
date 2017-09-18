From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 4/7] ipv6: addrlabel: per netns list
Date: Mon, 18 Sep 2017 12:07:30 -0700
Message-ID: <20170918190733.26272-5-edumazet@google.com>
References: <20170918190733.26272-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:51213 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751283AbdIRTHq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 15:07:46 -0400
Received: by mail-pf0-f171.google.com with SMTP id b70so706585pfl.8
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 12:07:46 -0700 (PDT)
In-Reply-To: <20170918190733.26272-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Having a global list of labels do not scale to thousands of
netns in the cloud era. This causes quadratic behavior on
netns creation and deletion.

This is time having a per netns list of ~10 labels.

Tested:

$ time perf record (for f in `seq 1 3000` ; do ip netns add tast$f; done)
[ perf record: Woken up 1 times to write data ]
[ perf record: Captured and wrote 3.637 MB perf.data (~158898 samples) ]

real    0m20.837s # instead of 0m24.227s
user    0m0.328s
sys     0m20.338s # instead of 0m23.753s

    16.17%       ip  [kernel.kallsyms]  [k] netlink_broadcast_filtered
    12.30%       ip  [kernel.kallsyms]  [k] netlink_has_listeners
     6.76%       ip  [kernel.kallsyms]  [k] _raw_spin_lock_irqsave
     5.78%       ip  [kernel.kallsyms]  [k] memset_erms
     5.77%       ip  [kernel.kallsyms]  [k] kobject_uevent_env
     5.18%       ip  [kernel.kallsyms]  [k] refcount_sub_and_test
     4.96%       ip  [kernel.kallsyms]  [k] _raw_read_lock
     3.82%       ip  [kernel.kallsyms]  [k] refcount_inc_not_zero
     3.33%       ip  [kernel.kallsyms]  [k] _raw_spin_unlock_irqrestore
     2.11%       ip  [kernel.kallsyms]  [k] unmap_page_range
     1.77%       ip  [kernel.kallsyms]  [k] __wake_up
     1.69%       ip  [kernel.kallsyms]  [k] strlen
     1.17%       ip  [kernel.kallsyms]  [k] __wake_up_common
     1.09%       ip  [kernel.kallsyms]  [k] insert_header
     1.04%       ip  [kernel.kallsyms]  [k] page_remove_rmap
     1.01%       ip  [kernel.kallsyms]  [k] consume_skb
     0.98%       ip  [kernel.kallsyms]  [k] netlink_trim
     0.51%       ip  [kernel.kallsyms]  [k] kernfs_link_sibling
     0.51%       ip  [kernel.kallsyms]  [k] filemap_map_pages
     0.46%       ip  [kernel.kallsyms]  [k] memcpy_erms

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/netns/ipv6.h |  5 +++
 net/ipv6/addrlabel.c     | 81 ++++++++++++++++++------------------------------
 2 files changed, 35 insertions(+), 51 deletions(-)

diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index 2544f9760a4263b7f1b8d622331ca63038586137..2ea1ed341ef81901b4fa271b0f7f4592e17c4f8a 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -89,6 +89,11 @@ struct netns_ipv6 {
 	atomic_t		fib6_sernum;
 	struct seg6_pernet_data *seg6_data;
 	struct fib_notifier_ops	*notifier_ops;
+	struct {
+		struct hlist_head head;
+		spinlock_t	lock;
+		u32		seq;
+	} ip6addrlbl_table;
 };
 
 #if IS_ENABLED(CONFIG_NF_DEFRAG_IPV6)
diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
index b055bc79f56d555c89684116c1580984950f77a8..c6311d7108f651c7385cd6316752ba4a86667dcc 100644
--- a/net/ipv6/addrlabel.c
+++ b/net/ipv6/addrlabel.c
@@ -30,7 +30,6 @@
  * Policy Table
  */
 struct ip6addrlbl_entry {
-	possible_net_t lbl_net;
 	struct in6_addr prefix;
 	int prefixlen;
 	int ifindex;
@@ -41,19 +40,6 @@ struct ip6addrlbl_entry {
 	struct rcu_head rcu;
 };
 
-static struct ip6addrlbl_table
-{
-	struct hlist_head head;
-	spinlock_t lock;
-	u32 seq;
-} ip6addrlbl_table;
-
-static inline
-struct net *ip6addrlbl_net(const struct ip6addrlbl_entry *lbl)
-{
-	return read_pnet(&lbl->lbl_net);
-}
-
 /*
  * Default policy table (RFC6724 + extensions)
  *
@@ -148,13 +134,10 @@ static inline void ip6addrlbl_put(struct ip6addrlbl_entry *p)
 }
 
 /* Find label */
-static bool __ip6addrlbl_match(struct net *net,
-			       const struct ip6addrlbl_entry *p,
+static bool __ip6addrlbl_match(const struct ip6addrlbl_entry *p,
 			       const struct in6_addr *addr,
 			       int addrtype, int ifindex)
 {
-	if (!net_eq(ip6addrlbl_net(p), net))
-		return false;
 	if (p->ifindex && p->ifindex != ifindex)
 		return false;
 	if (p->addrtype && p->addrtype != addrtype)
@@ -169,8 +152,9 @@ static struct ip6addrlbl_entry *__ipv6_addr_label(struct net *net,
 						  int type, int ifindex)
 {
 	struct ip6addrlbl_entry *p;
-	hlist_for_each_entry_rcu(p, &ip6addrlbl_table.head, list) {
-		if (__ip6addrlbl_match(net, p, addr, type, ifindex))
+
+	hlist_for_each_entry_rcu(p, &net->ipv6.ip6addrlbl_table.head, list) {
+		if (__ip6addrlbl_match(p, addr, type, ifindex))
 			return p;
 	}
 	return NULL;
@@ -196,8 +180,7 @@ u32 ipv6_addr_label(struct net *net,
 }
 
 /* allocate one entry */
-static struct ip6addrlbl_entry *ip6addrlbl_alloc(struct net *net,
-						 const struct in6_addr *prefix,
+static struct ip6addrlbl_entry *ip6addrlbl_alloc(const struct in6_addr *prefix,
 						 int prefixlen, int ifindex,
 						 u32 label)
 {
@@ -236,24 +219,23 @@ static struct ip6addrlbl_entry *ip6addrlbl_alloc(struct net *net,
 	newp->addrtype = addrtype;
 	newp->label = label;
 	INIT_HLIST_NODE(&newp->list);
-	write_pnet(&newp->lbl_net, net);
 	refcount_set(&newp->refcnt, 1);
 	return newp;
 }
 
 /* add a label */
-static int __ip6addrlbl_add(struct ip6addrlbl_entry *newp, int replace)
+static int __ip6addrlbl_add(struct net *net, struct ip6addrlbl_entry *newp,
+			    int replace)
 {
-	struct hlist_node *n;
 	struct ip6addrlbl_entry *last = NULL, *p = NULL;
+	struct hlist_node *n;
 	int ret = 0;
 
 	ADDRLABEL(KERN_DEBUG "%s(newp=%p, replace=%d)\n", __func__, newp,
 		  replace);
 
-	hlist_for_each_entry_safe(p, n,	&ip6addrlbl_table.head, list) {
+	hlist_for_each_entry_safe(p, n,	&net->ipv6.ip6addrlbl_table.head, list) {
 		if (p->prefixlen == newp->prefixlen &&
-		    net_eq(ip6addrlbl_net(p), ip6addrlbl_net(newp)) &&
 		    p->ifindex == newp->ifindex &&
 		    ipv6_addr_equal(&p->prefix, &newp->prefix)) {
 			if (!replace) {
@@ -273,10 +255,10 @@ static int __ip6addrlbl_add(struct ip6addrlbl_entry *newp, int replace)
 	if (last)
 		hlist_add_behind_rcu(&newp->list, &last->list);
 	else
-		hlist_add_head_rcu(&newp->list, &ip6addrlbl_table.head);
+		hlist_add_head_rcu(&newp->list, &net->ipv6.ip6addrlbl_table.head);
 out:
 	if (!ret)
-		ip6addrlbl_table.seq++;
+		net->ipv6.ip6addrlbl_table.seq++;
 	return ret;
 }
 
@@ -292,12 +274,12 @@ static int ip6addrlbl_add(struct net *net,
 		  __func__, prefix, prefixlen, ifindex, (unsigned int)label,
 		  replace);
 
-	newp = ip6addrlbl_alloc(net, prefix, prefixlen, ifindex, label);
+	newp = ip6addrlbl_alloc(prefix, prefixlen, ifindex, label);
 	if (IS_ERR(newp))
 		return PTR_ERR(newp);
-	spin_lock(&ip6addrlbl_table.lock);
-	ret = __ip6addrlbl_add(newp, replace);
-	spin_unlock(&ip6addrlbl_table.lock);
+	spin_lock(&net->ipv6.ip6addrlbl_table.lock);
+	ret = __ip6addrlbl_add(net, newp, replace);
+	spin_unlock(&net->ipv6.ip6addrlbl_table.lock);
 	if (ret)
 		ip6addrlbl_free(newp);
 	return ret;
@@ -315,9 +297,8 @@ static int __ip6addrlbl_del(struct net *net,
 	ADDRLABEL(KERN_DEBUG "%s(prefix=%pI6, prefixlen=%d, ifindex=%d)\n",
 		  __func__, prefix, prefixlen, ifindex);
 
-	hlist_for_each_entry_safe(p, n, &ip6addrlbl_table.head, list) {
+	hlist_for_each_entry_safe(p, n, &net->ipv6.ip6addrlbl_table.head, list) {
 		if (p->prefixlen == prefixlen &&
-		    net_eq(ip6addrlbl_net(p), net) &&
 		    p->ifindex == ifindex &&
 		    ipv6_addr_equal(&p->prefix, prefix)) {
 			hlist_del_rcu(&p->list);
@@ -340,9 +321,9 @@ static int ip6addrlbl_del(struct net *net,
 		  __func__, prefix, prefixlen, ifindex);
 
 	ipv6_addr_prefix(&prefix_buf, prefix, prefixlen);
-	spin_lock(&ip6addrlbl_table.lock);
+	spin_lock(&net->ipv6.ip6addrlbl_table.lock);
 	ret = __ip6addrlbl_del(net, &prefix_buf, prefixlen, ifindex);
-	spin_unlock(&ip6addrlbl_table.lock);
+	spin_unlock(&net->ipv6.ip6addrlbl_table.lock);
 	return ret;
 }
 
@@ -354,6 +335,9 @@ static int __net_init ip6addrlbl_net_init(struct net *net)
 
 	ADDRLABEL(KERN_DEBUG "%s\n", __func__);
 
+	spin_lock_init(&net->ipv6.ip6addrlbl_table.lock);
+	INIT_HLIST_HEAD(&net->ipv6.ip6addrlbl_table.head);
+
 	for (i = 0; i < ARRAY_SIZE(ip6addrlbl_init_table); i++) {
 		int ret = ip6addrlbl_add(net,
 					 ip6addrlbl_init_table[i].prefix,
@@ -373,14 +357,12 @@ static void __net_exit ip6addrlbl_net_exit(struct net *net)
 	struct hlist_node *n;
 
 	/* Remove all labels belonging to the exiting net */
-	spin_lock(&ip6addrlbl_table.lock);
-	hlist_for_each_entry_safe(p, n, &ip6addrlbl_table.head, list) {
-		if (net_eq(ip6addrlbl_net(p), net)) {
-			hlist_del_rcu(&p->list);
-			ip6addrlbl_put(p);
-		}
+	spin_lock(&net->ipv6.ip6addrlbl_table.lock);
+	hlist_for_each_entry_safe(p, n, &net->ipv6.ip6addrlbl_table.head, list) {
+		hlist_del_rcu(&p->list);
+		ip6addrlbl_put(p);
 	}
-	spin_unlock(&ip6addrlbl_table.lock);
+	spin_unlock(&net->ipv6.ip6addrlbl_table.lock);
 }
 
 static struct pernet_operations ipv6_addr_label_ops = {
@@ -390,8 +372,6 @@ static struct pernet_operations ipv6_addr_label_ops = {
 
 int __init ipv6_addr_label_init(void)
 {
-	spin_lock_init(&ip6addrlbl_table.lock);
-
 	return register_pernet_subsys(&ipv6_addr_label_ops);
 }
 
@@ -510,11 +490,10 @@ static int ip6addrlbl_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	int err;
 
 	rcu_read_lock();
-	hlist_for_each_entry_rcu(p, &ip6addrlbl_table.head, list) {
-		if (idx >= s_idx &&
-		    net_eq(ip6addrlbl_net(p), net)) {
+	hlist_for_each_entry_rcu(p, &net->ipv6.ip6addrlbl_table.head, list) {
+		if (idx >= s_idx) {
 			err = ip6addrlbl_fill(skb, p,
-					      ip6addrlbl_table.seq,
+					      net->ipv6.ip6addrlbl_table.seq,
 					      NETLINK_CB(cb->skb).portid,
 					      cb->nlh->nlmsg_seq,
 					      RTM_NEWADDRLABEL,
@@ -571,7 +550,7 @@ static int ip6addrlbl_get(struct sk_buff *in_skb, struct nlmsghdr *nlh,
 	p = __ipv6_addr_label(net, addr, ipv6_addr_type(addr), ifal->ifal_index);
 	if (p && !ip6addrlbl_hold(p))
 		p = NULL;
-	lseq = ip6addrlbl_table.seq;
+	lseq = net->ipv6.ip6addrlbl_table.seq;
 	rcu_read_unlock();
 
 	if (!p) {
-- 
2.14.1.690.gbb1197296e-goog
