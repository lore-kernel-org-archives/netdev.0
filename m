From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: if6_get_next() fix
Date: Mon, 03 May 2010 22:50:14 +0200
Message-ID: <1272919814.2407.149.camel@edumazet-laptop>
References: <1272916007.2407.75.camel@edumazet-laptop>
	 <20100503.130902.172620141.davem@davemloft.net>
	 <1272917635.2407.106.camel@edumazet-laptop>
	 <20100503.132442.200112018.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, shemminger@vyatta.com,
	Valdis.Kletnieks@vt.edu, akpm@linux-foundation.org,
	peterz@infradead.org, kaber@trash.net,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100503.132442.200112018.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Paul, David, here the patch I was thinking about :

Feel free to split it in two parts if you like, I am too tired and must
sleep now ;)

Thanks

[PATCH net-next-2.6] net: rcu fixes

Add hlist_for_each_entry_rcu_bh() and
hlist_for_each_entry_continue_rcu_bh() macros, and use them in
ipv6_get_ifaddr(), if6_get_first() and if6_get_next() to fix lockdeps
warnings.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/rculist.h |   29 +++++++++++++++++++++++++++++
 net/ipv6/addrconf.c     |   16 ++++++++--------
 2 files changed, 37 insertions(+), 8 deletions(-)

diff --git a/include/linux/rculist.h b/include/linux/rculist.h
index 004908b..4ec3b38 100644
--- a/include/linux/rculist.h
+++ b/include/linux/rculist.h
@@ -429,6 +429,23 @@ static inline void hlist_add_after_rcu(struct hlist_node *prev,
 		pos = rcu_dereference_raw(pos->next))
 
 /**
+ * hlist_for_each_entry_rcu_bh - iterate over rcu list of given type
+ * @tpos:	the type * to use as a loop cursor.
+ * @pos:	the &struct hlist_node to use as a loop cursor.
+ * @head:	the head for your list.
+ * @member:	the name of the hlist_node within the struct.
+ *
+ * This list-traversal primitive may safely run concurrently with
+ * the _rcu list-mutation primitives such as hlist_add_head_rcu()
+ * as long as the traversal is guarded by rcu_read_lock().
+ */
+#define hlist_for_each_entry_rcu_bh(tpos, pos, head, member)		 \
+	for (pos = rcu_dereference_bh((head)->first);			 \
+		pos && ({ prefetch(pos->next); 1; }) &&			 \
+		({ tpos = hlist_entry(pos, typeof(*tpos), member); 1; }); \
+		pos = rcu_dereference_bh(pos->next))
+
+/**
  * hlist_for_each_entry_continue_rcu - iterate over a hlist continuing after current point
  * @tpos:	the type * to use as a loop cursor.
  * @pos:	the &struct hlist_node to use as a loop cursor.
@@ -440,6 +457,18 @@ static inline void hlist_add_after_rcu(struct hlist_node *prev,
 	     ({ tpos = hlist_entry(pos, typeof(*tpos), member); 1; });  \
 	     pos = rcu_dereference(pos->next))
 
+/**
+ * hlist_for_each_entry_continue_rcu_bh - iterate over a hlist continuing after current point
+ * @tpos:	the type * to use as a loop cursor.
+ * @pos:	the &struct hlist_node to use as a loop cursor.
+ * @member:	the name of the hlist_node within the struct.
+ */
+#define hlist_for_each_entry_continue_rcu_bh(tpos, pos, member)		\
+	for (pos = rcu_dereference_bh((pos)->next);			\
+	     pos && ({ prefetch(pos->next); 1; }) &&			\
+	     ({ tpos = hlist_entry(pos, typeof(*tpos), member); 1; });  \
+	     pos = rcu_dereference_bh(pos->next))
+
 
 #endif	/* __KERNEL__ */
 #endif
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 34d2d64..3984f52 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1346,7 +1346,7 @@ struct inet6_ifaddr *ipv6_get_ifaddr(struct net *net, const struct in6_addr *add
 	struct hlist_node *node;
 
 	rcu_read_lock_bh();
-	hlist_for_each_entry_rcu(ifp, node, &inet6_addr_lst[hash], addr_lst) {
+	hlist_for_each_entry_rcu_bh(ifp, node, &inet6_addr_lst[hash], addr_lst) {
 		if (!net_eq(dev_net(ifp->idev->dev), net))
 			continue;
 		if (ipv6_addr_equal(&ifp->addr, addr)) {
@@ -2959,7 +2959,7 @@ static struct inet6_ifaddr *if6_get_first(struct seq_file *seq)
 
 	for (state->bucket = 0; state->bucket < IN6_ADDR_HSIZE; ++state->bucket) {
 		struct hlist_node *n;
-		hlist_for_each_entry_rcu(ifa, n, &inet6_addr_lst[state->bucket],
+		hlist_for_each_entry_rcu_bh(ifa, n, &inet6_addr_lst[state->bucket],
 					 addr_lst)
 			if (net_eq(dev_net(ifa->idev->dev), net))
 				return ifa;
@@ -2974,12 +2974,12 @@ static struct inet6_ifaddr *if6_get_next(struct seq_file *seq,
 	struct net *net = seq_file_net(seq);
 	struct hlist_node *n = &ifa->addr_lst;
 
-	hlist_for_each_entry_continue_rcu(ifa, n, addr_lst)
+	hlist_for_each_entry_continue_rcu_bh(ifa, n, addr_lst)
 		if (net_eq(dev_net(ifa->idev->dev), net))
 			return ifa;
 
 	while (++state->bucket < IN6_ADDR_HSIZE) {
-		hlist_for_each_entry(ifa, n,
+		hlist_for_each_entry_rcu_bh(ifa, n,
 				     &inet6_addr_lst[state->bucket], addr_lst) {
 			if (net_eq(dev_net(ifa->idev->dev), net))
 				return ifa;
@@ -3000,7 +3000,7 @@ static struct inet6_ifaddr *if6_get_idx(struct seq_file *seq, loff_t pos)
 }
 
 static void *if6_seq_start(struct seq_file *seq, loff_t *pos)
-	__acquires(rcu)
+	__acquires(rcu_bh)
 {
 	rcu_read_lock_bh();
 	return if6_get_idx(seq, *pos);
@@ -3016,7 +3016,7 @@ static void *if6_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 }
 
 static void if6_seq_stop(struct seq_file *seq, void *v)
-	__releases(rcu)
+	__releases(rcu_bh)
 {
 	rcu_read_unlock_bh();
 }
@@ -3093,7 +3093,7 @@ int ipv6_chk_home_addr(struct net *net, struct in6_addr *addr)
 	unsigned int hash = ipv6_addr_hash(addr);
 
 	rcu_read_lock_bh();
-	hlist_for_each_entry_rcu(ifp, n, &inet6_addr_lst[hash], addr_lst) {
+	hlist_for_each_entry_rcu_bh(ifp, n, &inet6_addr_lst[hash], addr_lst) {
 		if (!net_eq(dev_net(ifp->idev->dev), net))
 			continue;
 		if (ipv6_addr_equal(&ifp->addr, addr) &&
@@ -3127,7 +3127,7 @@ static void addrconf_verify(unsigned long foo)
 
 	for (i = 0; i < IN6_ADDR_HSIZE; i++) {
 restart:
-		hlist_for_each_entry_rcu(ifp, node,
+		hlist_for_each_entry_rcu_bh(ifp, node,
 					 &inet6_addr_lst[i], addr_lst) {
 			unsigned long age;
 


