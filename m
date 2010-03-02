From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 06/12] IPv6: convert addrconf hash list to RCU
Date: Tue, 02 Mar 2010 15:32:49 -0800
Message-ID: <20100302234003.262703041@vyatta.com>
References: <20100302233243.259794027@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58947 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757603Ab0CBXrL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Mar 2010 18:47:11 -0500
Content-Disposition: inline; filename=ipv6-addrconf-rcu.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert from reader/writer lock to RCU and spinlock for addrconf
hash list.

Adds an additional helper macro for hlist_for_each_entry_continue_rcu
to handle the continue case.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 include/linux/rculist.h |   13 +++++++
 include/net/if_inet6.h  |    1 
 net/ipv6/addrconf.c     |   80 +++++++++++++++++++++++++-----------------------
 3 files changed, 57 insertions(+), 37 deletions(-)

--- a/net/ipv6/addrconf.c	2010-03-02 14:29:25.444951749 -0800
+++ b/net/ipv6/addrconf.c	2010-03-02 14:33:59.033450885 -0800
@@ -127,7 +127,7 @@ static int ipv6_count_addresses(struct i
  *	Configured unicast address hash table
  */
 static struct hlist_head inet6_addr_lst[IN6_ADDR_HSIZE];
-static DEFINE_RWLOCK(addrconf_hash_lock);
+static DEFINE_SPINLOCK(addrconf_hash_lock);
 
 static void addrconf_verify(unsigned long);
 
@@ -523,8 +523,13 @@ static int addrconf_fixup_forwarding(str
 }
 #endif
 
-/* Nobody refers to this ifaddr, destroy it */
+static void inet6_ifa_finish_destroy_rcu(struct rcu_head *head)
+{
+	struct inet6_ifaddr *ifp = container_of(head, struct inet6_ifaddr, rcu);
+	kfree(ifp);
+}
 
+/* Nobody refers to this ifaddr, destroy it */
 void inet6_ifa_finish_destroy(struct inet6_ifaddr *ifp)
 {
 	WARN_ON(ifp->if_next != NULL);
@@ -545,7 +550,7 @@ void inet6_ifa_finish_destroy(struct ine
 	}
 	dst_release(&ifp->rt->u.dst);
 
-	kfree(ifp);
+	call_rcu(&ifp->rcu, inet6_ifa_finish_destroy_rcu);
 }
 
 static void
@@ -616,7 +621,7 @@ ipv6_add_addr(struct inet6_dev *idev, co
 		goto out2;
 	}
 
-	write_lock(&addrconf_hash_lock);
+	spin_lock(&addrconf_hash_lock);
 
 	/* Ignore adding duplicate addresses on an interface */
 	if (ipv6_chk_same_addr(dev_net(idev->dev), addr, idev->dev)) {
@@ -670,9 +675,9 @@ ipv6_add_addr(struct inet6_dev *idev, co
 	/* Add to big hash table */
 	hash = ipv6_addr_hash(addr);
 
-	hlist_add_head(&ifa->addr_lst, &inet6_addr_lst[hash]);
+	hlist_add_head_rcu(&ifa->addr_lst, &inet6_addr_lst[hash]);
 	in6_ifa_hold(ifa);
-	write_unlock(&addrconf_hash_lock);
+	spin_unlock(&addrconf_hash_lock);
 
 	write_lock(&idev->lock);
 	/* Add to inet6_dev unicast addr list. */
@@ -699,7 +704,7 @@ out2:
 
 	return ifa;
 out:
-	write_unlock(&addrconf_hash_lock);
+	spin_unlock(&addrconf_hash_lock);
 	goto out2;
 }
 
@@ -717,10 +722,10 @@ static void ipv6_del_addr(struct inet6_i
 
 	ifp->dead = 1;
 
-	write_lock_bh(&addrconf_hash_lock);
-	hlist_del_init(&ifp->addr_lst);
+	spin_lock_bh(&addrconf_hash_lock);
+	hlist_del_init_rcu(&ifp->addr_lst);
 	__in6_ifa_put(ifp);
-	write_unlock_bh(&addrconf_hash_lock);
+	spin_unlock_bh(&addrconf_hash_lock);
 
 	write_lock_bh(&idev->lock);
 #ifdef CONFIG_IPV6_PRIVACY
@@ -1274,8 +1279,8 @@ int ipv6_chk_addr(struct net *net, struc
 	struct hlist_node *node;
 	u8 hash = ipv6_addr_hash(addr);
 
-	read_lock_bh(&addrconf_hash_lock);
-	hlist_for_each_entry(ifp, node, &inet6_addr_lst[hash], addr_lst) {
+	rcu_read_lock_bh();
+	hlist_for_each_entry_rcu(ifp, node, &inet6_addr_lst[hash], addr_lst) {
 		if (!net_eq(dev_net(ifp->idev->dev), net))
 			continue;
 		if (ipv6_addr_equal(&ifp->addr, addr) &&
@@ -1285,7 +1290,8 @@ int ipv6_chk_addr(struct net *net, struc
 				break;
 		}
 	}
-	read_unlock_bh(&addrconf_hash_lock);
+	rcu_read_unlock_bh();
+
 	return ifp != NULL;
 }
 EXPORT_SYMBOL(ipv6_chk_addr);
@@ -1341,8 +1347,8 @@ struct inet6_ifaddr *ipv6_get_ifaddr(str
 	struct hlist_node *node;
 	u8 hash = ipv6_addr_hash(addr);
 
-	read_lock_bh(&addrconf_hash_lock);
-	hlist_for_each_entry(ifp, node, &inet6_addr_lst[hash], addr_lst) {
+	rcu_read_lock_bh();
+	hlist_for_each_entry_rcu(ifp, node, &inet6_addr_lst[hash], addr_lst) {
 		if (!net_eq(dev_net(ifp->idev->dev), net))
 			continue;
 		if (ipv6_addr_equal(&ifp->addr, addr)) {
@@ -1353,7 +1359,7 @@ struct inet6_ifaddr *ipv6_get_ifaddr(str
 			}
 		}
 	}
-	read_unlock_bh(&addrconf_hash_lock);
+	rcu_read_unlock_bh();
 
 	return ifp;
 }
@@ -2691,10 +2697,10 @@ static int addrconf_ifdown(struct net_de
 		write_unlock_bh(&idev->lock);
 
 		/* clear hash table */
-		write_lock_bh(&addrconf_hash_lock);
-		hlist_del_init(&ifa->addr_lst);
+		spin_lock_bh(&addrconf_hash_lock);
+		hlist_del_init_rcu(&ifa->addr_lst);
 		__in6_ifa_put(ifa);
-		write_unlock_bh(&addrconf_hash_lock);
+		spin_unlock_bh(&addrconf_hash_lock);
 
 		__ipv6_ifa_notify(RTM_DELADDR, ifa);
 		atomic_notifier_call_chain(&inet6addr_chain, NETDEV_DOWN, ifa);
@@ -2936,11 +2942,10 @@ static struct inet6_ifaddr *if6_get_firs
 
 	for (state->bucket = 0; state->bucket < IN6_ADDR_HSIZE; ++state->bucket) {
 		struct hlist_node *n;
-		hlist_for_each_entry(ifa, n,
-				     &inet6_addr_lst[state->bucket], addr_lst) {
+		hlist_for_each_entry_rcu(ifa, n, &inet6_addr_lst[state->bucket],
+					 addr_lst)
 			if (net_eq(dev_net(ifa->idev->dev), net))
 				return ifa;
-		}
 	}
 	return NULL;
 }
@@ -2952,10 +2957,9 @@ static struct inet6_ifaddr *if6_get_next
 	struct net *net = seq_file_net(seq);
 	struct hlist_node *n = &ifa->addr_lst;
 
-	hlist_for_each_entry_continue(ifa, n, addr_lst) {
+	hlist_for_each_entry_continue_rcu(ifa, n, addr_lst)
 		if (net_eq(dev_net(ifa->idev->dev), net))
 			return ifa;
-	}
 
 	while (++state->bucket < IN6_ADDR_HSIZE) {
 		hlist_for_each_entry(ifa, n,
@@ -2979,9 +2983,9 @@ static struct inet6_ifaddr *if6_get_idx(
 }
 
 static void *if6_seq_start(struct seq_file *seq, loff_t *pos)
-	__acquires(addrconf_hash_lock)
+	__acquires(rcu)
 {
-	read_lock_bh(&addrconf_hash_lock);
+	rcu_read_lock_bh();
 	return if6_get_idx(seq, *pos);
 }
 
@@ -2995,9 +2999,9 @@ static void *if6_seq_next(struct seq_fil
 }
 
 static void if6_seq_stop(struct seq_file *seq, void *v)
-	__releases(addrconf_hash_lock)
+	__releases(rcu)
 {
-	read_unlock_bh(&addrconf_hash_lock);
+	rcu_read_unlock_bh();
 }
 
 static int if6_seq_show(struct seq_file *seq, void *v)
@@ -3071,8 +3075,8 @@ int ipv6_chk_home_addr(struct net *net, 
 	struct hlist_node *n;
 	u8 hash = ipv6_addr_hash(addr);
 
-	read_lock_bh(&addrconf_hash_lock);
-	hlist_for_each_entry(ifp, n, &inet6_addr_lst[hash], addr_lst) {
+	rcu_read_lock_bh();
+	hlist_for_each_entry_rcu(ifp, n, &inet6_addr_lst[hash], addr_lst) {
 		if (!net_eq(dev_net(ifp->idev->dev), net))
 			continue;
 		if (ipv6_addr_equal(&ifp->addr, addr) &&
@@ -3081,7 +3085,7 @@ int ipv6_chk_home_addr(struct net *net, 
 			break;
 		}
 	}
-	read_unlock_bh(&addrconf_hash_lock);
+	rcu_read_unlock_bh();
 	return ret;
 }
 #endif
@@ -3097,7 +3101,8 @@ static void addrconf_verify(unsigned lon
 	unsigned long now, next;
 	int i;
 
-	spin_lock_bh(&addrconf_verify_lock);
+	rcu_read_lock_bh();
+	spin_lock(&addrconf_verify_lock);
 	now = jiffies;
 	next = now + ADDR_CHECK_FREQUENCY;
 
@@ -3106,8 +3111,8 @@ static void addrconf_verify(unsigned lon
 	for (i=0; i < IN6_ADDR_HSIZE; i++) {
 
 restart:
-		read_lock(&addrconf_hash_lock);
-		hlist_for_each_entry(ifp, node, &inet6_addr_lst[i], addr_lst) {
+		hlist_for_each_entry_rcu(ifp, node,
+					 &inet6_addr_lst[i], addr_lst) {
 			unsigned long age;
 #ifdef CONFIG_IPV6_PRIVACY
 			unsigned long regen_advance;
@@ -3129,7 +3134,6 @@ restart:
 			    age >= ifp->valid_lft) {
 				spin_unlock(&ifp->lock);
 				in6_ifa_hold(ifp);
-				read_unlock(&addrconf_hash_lock);
 				ipv6_del_addr(ifp);
 				goto restart;
 			} else if (ifp->prefered_lft == INFINITY_LIFE_TIME) {
@@ -3151,7 +3155,6 @@ restart:
 
 				if (deprecate) {
 					in6_ifa_hold(ifp);
-					read_unlock(&addrconf_hash_lock);
 
 					ipv6_ifa_notify(0, ifp);
 					in6_ifa_put(ifp);
@@ -3169,7 +3172,7 @@ restart:
 						in6_ifa_hold(ifp);
 						in6_ifa_hold(ifpub);
 						spin_unlock(&ifp->lock);
-						read_unlock(&addrconf_hash_lock);
+
 						spin_lock(&ifpub->lock);
 						ifpub->regen_count = 0;
 						spin_unlock(&ifpub->lock);
@@ -3189,12 +3192,12 @@ restart:
 				spin_unlock(&ifp->lock);
 			}
 		}
-		read_unlock(&addrconf_hash_lock);
 	}
 
 	addr_chk_timer.expires = time_before(next, jiffies + HZ) ? jiffies + HZ : next;
 	add_timer(&addr_chk_timer);
-	spin_unlock_bh(&addrconf_verify_lock);
+	spin_unlock(&addrconf_verify_lock);
+	rcu_read_unlock_bh();
 }
 
 static struct in6_addr *extract_addr(struct nlattr *addr, struct nlattr *local)
@@ -4611,10 +4614,10 @@ void addrconf_cleanup(void)
 	/*
 	 *	Check hash table.
 	 */
-	write_lock_bh(&addrconf_hash_lock);
+	spin_lock_bh(&addrconf_hash_lock);
 	for (i = 0; i < IN6_ADDR_HSIZE; i++)
 		WARN_ON(!hlist_empty(&inet6_addr_lst[i]));
-	write_unlock_bh(&addrconf_hash_lock);
+	spin_unlock_bh(&addrconf_hash_lock);
 
 	del_timer(&addr_chk_timer);
 	rtnl_unlock();
--- a/include/linux/rculist.h	2010-03-01 08:22:23.456662311 -0800
+++ b/include/linux/rculist.h	2010-03-02 14:29:56.641076077 -0800
@@ -428,5 +428,18 @@ static inline void hlist_add_after_rcu(s
 		({ tpos = hlist_entry(pos, typeof(*tpos), member); 1; }); \
 		pos = rcu_dereference_raw(pos->next))
 
+/**
+ * hlist_for_each_entry_continue_rcu - iterate over a hlist continuing after current point
+ * @tpos:	the type * to use as a loop cursor.
+ * @pos:	the &struct hlist_node to use as a loop cursor.
+ * @member:	the name of the hlist_node within the struct.
+ */
+#define hlist_for_each_entry_continue_rcu(tpos, pos, member)		\
+	for (pos = rcu_dereference((pos)->next);			\
+	     pos && ({ prefetch(pos->next); 1; }) &&			\
+	     ({ tpos = hlist_entry(pos, typeof(*tpos), member); 1; });  \
+	     pos = rcu_dereference(pos->next))
+
+
 #endif	/* __KERNEL__ */
 #endif
--- a/include/net/if_inet6.h	2010-03-02 14:29:25.465077512 -0800
+++ b/include/net/if_inet6.h	2010-03-02 14:31:13.137385294 -0800
@@ -64,6 +64,7 @@ struct inet6_ifaddr {
 #endif
 
 	int			dead;
+	struct rcu_head		rcu;
 };
 
 struct ip6_sf_socklist {

-- 

