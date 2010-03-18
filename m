From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/9] ipv6: convert addrconf list to hlist
Date: Wed, 17 Mar 2010 23:31:10 -0700
Message-ID: <20100318063122.935061603@vyatta.com>
References: <20100318063108.109693694@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:33113 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752761Ab0CRGgI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Mar 2010 02:36:08 -0400
Content-Disposition: inline; filename=ipv6-addrconf-hlist.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using hash list macros, simplifies code and helps later RCU.

This patch includes some initialization that is not strictly necessary,
since an empty hlist node/list is all zero; and list is in BSS
and node is allocated with kzalloc.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 include/net/if_inet6.h |    2 
 net/ipv6/addrconf.c    |  128 ++++++++++++++++++++-----------------------------
 2 files changed, 54 insertions(+), 76 deletions(-)

--- a/net/ipv6/addrconf.c	2010-03-15 16:10:15.169524547 -0700
+++ b/net/ipv6/addrconf.c	2010-03-15 16:10:22.820461548 -0700
@@ -126,7 +126,7 @@ static int ipv6_count_addresses(struct i
 /*
  *	Configured unicast address hash table
  */
-static struct inet6_ifaddr		*inet6_addr_lst[IN6_ADDR_HSIZE];
+static struct hlist_head inet6_addr_lst[IN6_ADDR_HSIZE];
 static DEFINE_RWLOCK(addrconf_hash_lock);
 
 static void addrconf_verify(unsigned long);
@@ -528,7 +528,7 @@ static int addrconf_fixup_forwarding(str
 void inet6_ifa_finish_destroy(struct inet6_ifaddr *ifp)
 {
 	WARN_ON(ifp->if_next != NULL);
-	WARN_ON(ifp->lst_next != NULL);
+	WARN_ON(!hlist_unhashed(&ifp->addr_lst));
 
 #ifdef NET_REFCNT_DEBUG
 	printk(KERN_DEBUG "inet6_ifa_finish_destroy\n");
@@ -643,6 +643,7 @@ ipv6_add_addr(struct inet6_dev *idev, co
 
 	spin_lock_init(&ifa->lock);
 	init_timer(&ifa->timer);
+	INIT_HLIST_NODE(&ifa->addr_lst);
 	ifa->timer.data = (unsigned long) ifa;
 	ifa->scope = scope;
 	ifa->prefix_len = pfxlen;
@@ -669,8 +670,7 @@ ipv6_add_addr(struct inet6_dev *idev, co
 	/* Add to big hash table */
 	hash = ipv6_addr_hash(addr);
 
-	ifa->lst_next = inet6_addr_lst[hash];
-	inet6_addr_lst[hash] = ifa;
+	hlist_add_head(&ifa->addr_lst, &inet6_addr_lst[hash]);
 	in6_ifa_hold(ifa);
 	write_unlock(&addrconf_hash_lock);
 
@@ -718,15 +718,8 @@ static void ipv6_del_addr(struct inet6_i
 	ifp->dead = 1;
 
 	write_lock_bh(&addrconf_hash_lock);
-	for (ifap = &inet6_addr_lst[hash]; (ifa=*ifap) != NULL;
-	     ifap = &ifa->lst_next) {
-		if (ifa == ifp) {
-			*ifap = ifa->lst_next;
-			__in6_ifa_put(ifp);
-			ifa->lst_next = NULL;
-			break;
-		}
-	}
+	hlist_del_init(&ifp->addr_lst);
+	__in6_ifa_put(ifp);
 	write_unlock_bh(&addrconf_hash_lock);
 
 	write_lock_bh(&idev->lock);
@@ -1277,11 +1270,12 @@ static int ipv6_count_addresses(struct i
 int ipv6_chk_addr(struct net *net, struct in6_addr *addr,
 		  struct net_device *dev, int strict)
 {
-	struct inet6_ifaddr * ifp;
+	struct inet6_ifaddr *ifp = NULL;
+	struct hlist_node *node;
 	u8 hash = ipv6_addr_hash(addr);
 
 	read_lock_bh(&addrconf_hash_lock);
-	for(ifp = inet6_addr_lst[hash]; ifp; ifp=ifp->lst_next) {
+	hlist_for_each_entry(ifp, node, &inet6_addr_lst[hash], addr_lst) {
 		if (!net_eq(dev_net(ifp->idev->dev), net))
 			continue;
 		if (ipv6_addr_equal(&ifp->addr, addr) &&
@@ -1300,10 +1294,11 @@ static
 int ipv6_chk_same_addr(struct net *net, const struct in6_addr *addr,
 		       struct net_device *dev)
 {
-	struct inet6_ifaddr * ifp;
+	struct inet6_ifaddr *ifp;
+	struct hlist_node *node;
 	u8 hash = ipv6_addr_hash(addr);
 
-	for(ifp = inet6_addr_lst[hash]; ifp; ifp=ifp->lst_next) {
+	hlist_for_each_entry(ifp, node, &inet6_addr_lst[hash], addr_lst) {
 		if (!net_eq(dev_net(ifp->idev->dev), net))
 			continue;
 		if (ipv6_addr_equal(&ifp->addr, addr)) {
@@ -1342,11 +1337,12 @@ EXPORT_SYMBOL(ipv6_chk_prefix);
 struct inet6_ifaddr *ipv6_get_ifaddr(struct net *net, const struct in6_addr *addr,
 				     struct net_device *dev, int strict)
 {
-	struct inet6_ifaddr * ifp;
+	struct inet6_ifaddr *ifp = NULL;
+	struct hlist_node *node;
 	u8 hash = ipv6_addr_hash(addr);
 
 	read_lock_bh(&addrconf_hash_lock);
-	for(ifp = inet6_addr_lst[hash]; ifp; ifp=ifp->lst_next) {
+	hlist_for_each_entry(ifp, node, &inet6_addr_lst[hash], addr_lst) {
 		if (!net_eq(dev_net(ifp->idev->dev), net))
 			continue;
 		if (ipv6_addr_equal(&ifp->addr, addr)) {
@@ -2612,7 +2608,6 @@ static int addrconf_ifdown(struct net_de
 	struct inet6_dev *idev;
 	struct inet6_ifaddr *ifa, *keep_list, **bifa;
 	struct net *net = dev_net(dev);
-	int i;
 
 	ASSERT_RTNL();
 
@@ -2637,25 +2632,6 @@ static int addrconf_ifdown(struct net_de
 
 	}
 
-	/* Step 2: clear hash table */
-	for (i=0; i<IN6_ADDR_HSIZE; i++) {
-		bifa = &inet6_addr_lst[i];
-
-		write_lock_bh(&addrconf_hash_lock);
-		while ((ifa = *bifa) != NULL) {
-			if (ifa->idev == idev &&
-			    (how || !(ifa->flags&IFA_F_PERMANENT) ||
-			     ipv6_addr_type(&ifa->addr) & IPV6_ADDR_LINKLOCAL)) {
-				*bifa = ifa->lst_next;
-				ifa->lst_next = NULL;
-				__in6_ifa_put(ifa);
-				continue;
-			}
-			bifa = &ifa->lst_next;
-		}
-		write_unlock_bh(&addrconf_hash_lock);
-	}
-
 	write_lock_bh(&idev->lock);
 
 	/* Step 3: clear flags for stateless addrconf */
@@ -2721,6 +2697,12 @@ static int addrconf_ifdown(struct net_de
 		}
 		write_unlock_bh(&idev->lock);
 
+		/* clear hash table */
+		write_lock_bh(&addrconf_hash_lock);
+		hlist_del_init(&ifa->addr_lst);
+		__in6_ifa_put(ifa);
+		write_unlock_bh(&addrconf_hash_lock);
+
 		__ipv6_ifa_notify(RTM_DELADDR, ifa);
 		atomic_notifier_call_chain(&inet6addr_chain, NETDEV_DOWN, ifa);
 		in6_ifa_put(ifa);
@@ -2963,36 +2945,37 @@ static struct inet6_ifaddr *if6_get_firs
 	struct net *net = seq_file_net(seq);
 
 	for (state->bucket = 0; state->bucket < IN6_ADDR_HSIZE; ++state->bucket) {
-		ifa = inet6_addr_lst[state->bucket];
-
-		while (ifa && !net_eq(dev_net(ifa->idev->dev), net))
-			ifa = ifa->lst_next;
-		if (ifa)
-			break;
+		struct hlist_node *n;
+		hlist_for_each_entry(ifa, n,
+				     &inet6_addr_lst[state->bucket], addr_lst) {
+			if (net_eq(dev_net(ifa->idev->dev), net))
+				return ifa;
+		}
 	}
-	return ifa;
+	return NULL;
 }
 
-static struct inet6_ifaddr *if6_get_next(struct seq_file *seq, struct inet6_ifaddr *ifa)
+static struct inet6_ifaddr *if6_get_next(struct seq_file *seq,
+					 struct inet6_ifaddr *ifa)
 {
 	struct if6_iter_state *state = seq->private;
 	struct net *net = seq_file_net(seq);
+	struct hlist_node *n = &ifa->addr_lst;
 
-	ifa = ifa->lst_next;
-try_again:
-	if (ifa) {
-		if (!net_eq(dev_net(ifa->idev->dev), net)) {
-			ifa = ifa->lst_next;
-			goto try_again;
-		}
+	hlist_for_each_entry_continue(ifa, n, addr_lst) {
+		if (net_eq(dev_net(ifa->idev->dev), net))
+			return ifa;
 	}
 
-	if (!ifa && ++state->bucket < IN6_ADDR_HSIZE) {
-		ifa = inet6_addr_lst[state->bucket];
-		goto try_again;
+	while (++state->bucket < IN6_ADDR_HSIZE) {
+		hlist_for_each_entry(ifa, n,
+				     &inet6_addr_lst[state->bucket], addr_lst) {
+			if (net_eq(dev_net(ifa->idev->dev), net))
+				return ifa;
+		}
 	}
 
-	return ifa;
+	return NULL;
 }
 
 static struct inet6_ifaddr *if6_get_idx(struct seq_file *seq, loff_t pos)
@@ -3094,10 +3077,12 @@ void if6_proc_exit(void)
 int ipv6_chk_home_addr(struct net *net, struct in6_addr *addr)
 {
 	int ret = 0;
-	struct inet6_ifaddr * ifp;
+	struct inet6_ifaddr *ifp = NULL;
+	struct hlist_node *n;
 	u8 hash = ipv6_addr_hash(addr);
+
 	read_lock_bh(&addrconf_hash_lock);
-	for (ifp = inet6_addr_lst[hash]; ifp; ifp = ifp->lst_next) {
+	hlist_for_each_entry(ifp, n, &inet6_addr_lst[hash], addr_lst) {
 		if (!net_eq(dev_net(ifp->idev->dev), net))
 			continue;
 		if (ipv6_addr_equal(&ifp->addr, addr) &&
@@ -3118,6 +3103,7 @@ int ipv6_chk_home_addr(struct net *net, 
 static void addrconf_verify(unsigned long foo)
 {
 	struct inet6_ifaddr *ifp;
+	struct hlist_node *node;
 	unsigned long now, next;
 	int i;
 
@@ -3131,7 +3117,7 @@ static void addrconf_verify(unsigned lon
 
 restart:
 		read_lock(&addrconf_hash_lock);
-		for (ifp=inet6_addr_lst[i]; ifp; ifp=ifp->lst_next) {
+		hlist_for_each_entry(ifp, node, &inet6_addr_lst[i], addr_lst) {
 			unsigned long age;
 #ifdef CONFIG_IPV6_PRIVACY
 			unsigned long regen_advance;
@@ -4550,7 +4536,7 @@ EXPORT_SYMBOL(unregister_inet6addr_notif
 
 int __init addrconf_init(void)
 {
-	int err;
+	int i, err;
 
 	if ((err = ipv6_addr_label_init()) < 0) {
 		printk(KERN_CRIT "IPv6 Addrconf: cannot initialize default policy table: %d.\n",
@@ -4585,6 +4571,9 @@ int __init addrconf_init(void)
 	if (err)
 		goto errlo;
 
+	for (i = 0; i < IN6_ADDR_HSIZE; i++)
+		INIT_HLIST_HEAD(&inet6_addr_lst[i]);
+
 	register_netdevice_notifier(&ipv6_dev_notf);
 
 	addrconf_verify(0);
@@ -4613,7 +4602,6 @@ errlo:
 
 void addrconf_cleanup(void)
 {
-	struct inet6_ifaddr *ifa;
 	struct net_device *dev;
 	int i;
 
@@ -4634,18 +4622,8 @@ void addrconf_cleanup(void)
 	 *	Check hash table.
 	 */
 	write_lock_bh(&addrconf_hash_lock);
-	for (i=0; i < IN6_ADDR_HSIZE; i++) {
-		for (ifa=inet6_addr_lst[i]; ifa; ) {
-			struct inet6_ifaddr *bifa;
-
-			bifa = ifa;
-			ifa = ifa->lst_next;
-			printk(KERN_DEBUG "bug: IPv6 address leakage detected: ifa=%p\n", bifa);
-			/* Do not free it; something is wrong.
-			   Now we can investigate it with debugger.
-			 */
-		}
-	}
+	for (i = 0; i < IN6_ADDR_HSIZE; i++)
+		WARN_ON(!hlist_empty(&inet6_addr_lst[i]));
 	write_unlock_bh(&addrconf_hash_lock);
 
 	del_timer(&addr_chk_timer);
--- a/include/net/if_inet6.h	2010-03-15 16:10:15.159524680 -0700
+++ b/include/net/if_inet6.h	2010-03-15 16:10:22.820461548 -0700
@@ -54,7 +54,7 @@ struct inet6_ifaddr {
 	struct inet6_dev	*idev;
 	struct rt6_info		*rt;
 
-	struct inet6_ifaddr	*lst_next;      /* next addr in addr_lst */
+	struct hlist_node	addr_lst;
 	struct inet6_ifaddr	*if_next;       /* next addr in inet6_dev */
 
 #ifdef CONFIG_IPV6_PRIVACY

-- 

