From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] decnet: RCU conversion and get rid of dev_base_lock
Date: Fri, 29 Oct 2010 15:09:24 +0200
Message-ID: <1288357764.2560.33.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:60136 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755652Ab0J2NJ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 09:09:29 -0400
Received: by ewy7 with SMTP id 7so2180760ewy.19
        for <netdev@vger.kernel.org>; Fri, 29 Oct 2010 06:09:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While tracking dev_base_lock users, I found decnet used it in
dnet_select_source(), but for a wrong purpose:

Writers only hold RTNL, not dev_base_lock, so readers must use RCU if
they cannot use RTNL.

Adds an rcu_head in struct dn_ifaddr and handle proper RCU management.

Adds __rcu annotation in dn_route as well.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/netdevice.h |    2 
 include/net/dn_dev.h      |   27 ++++++---
 include/net/dst.h         |    8 +-
 net/decnet/af_decnet.c    |    2 
 net/decnet/dn_dev.c       |  100 +++++++++++++++++++++---------------
 net/decnet/dn_fib.c       |    6 +-
 net/decnet/dn_neigh.c     |    2 
 net/decnet/dn_route.c     |   68 ++++++++++++++----------
 8 files changed, 127 insertions(+), 88 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 072652d..f7a2d50 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -951,7 +951,7 @@ struct net_device {
 #endif
 	void 			*atalk_ptr;	/* AppleTalk link 	*/
 	struct in_device __rcu	*ip_ptr;	/* IPv4 specific data	*/
-	void                    *dn_ptr;        /* DECnet specific data */
+	struct dn_dev __rcu     *dn_ptr;        /* DECnet specific data */
 	struct inet6_dev __rcu	*ip6_ptr;       /* IPv6 specific data */
 	void			*ec_ptr;	/* Econet specific data	*/
 	void			*ax25_ptr;	/* AX.25 specific data */
diff --git a/include/net/dn_dev.h b/include/net/dn_dev.h
index 0916bbf..b9e32db 100644
--- a/include/net/dn_dev.h
+++ b/include/net/dn_dev.h
@@ -5,13 +5,14 @@
 struct dn_dev;
 
 struct dn_ifaddr {
-	struct dn_ifaddr *ifa_next;
+	struct dn_ifaddr __rcu *ifa_next;
 	struct dn_dev    *ifa_dev;
 	__le16            ifa_local;
 	__le16            ifa_address;
 	__u8              ifa_flags;
 	__u8              ifa_scope;
 	char              ifa_label[IFNAMSIZ];
+	struct rcu_head   rcu;
 };
 
 #define DN_DEV_S_RU  0 /* Run - working normally   */
@@ -83,7 +84,7 @@ struct dn_dev_parms {
 
 
 struct dn_dev {
-	struct dn_ifaddr *ifa_list;
+	struct dn_ifaddr __rcu *ifa_list;
 	struct net_device *dev;
 	struct dn_dev_parms parms;
 	char use_long;
@@ -171,19 +172,27 @@ extern int unregister_dnaddr_notifier(struct notifier_block *nb);
 
 static inline int dn_dev_islocal(struct net_device *dev, __le16 addr)
 {
-	struct dn_dev *dn_db = dev->dn_ptr;
+	struct dn_dev *dn_db;
 	struct dn_ifaddr *ifa;
+	int res = 0;
 
+	rcu_read_lock();
+	dn_db = rcu_dereference(dev->dn_ptr);
 	if (dn_db == NULL) {
 		printk(KERN_DEBUG "dn_dev_islocal: Called for non DECnet device\n");
-		return 0;
+		goto out;
 	}
 
-	for(ifa = dn_db->ifa_list; ifa; ifa = ifa->ifa_next)
-		if ((addr ^ ifa->ifa_local) == 0)
-			return 1;
-
-	return 0;
+	for (ifa = rcu_dereference(dn_db->ifa_list);
+	     ifa != NULL;
+	     ifa = rcu_dereference(ifa->ifa_next))
+		if ((addr ^ ifa->ifa_local) == 0) {
+			res = 1;
+			break;
+		}
+out:
+	rcu_read_unlock();
+	return res;
 }
 
 #endif /* _NET_DN_DEV_H */
diff --git a/include/net/dst.h b/include/net/dst.h
index ffe9cb7..a5bd726 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -94,10 +94,10 @@ struct dst_entry {
 	int			__use;
 	unsigned long		lastuse;
 	union {
-		struct dst_entry *next;
-		struct rtable __rcu *rt_next;
-		struct rt6_info   *rt6_next;
-		struct dn_route  *dn_next;
+		struct dst_entry	*next;
+		struct rtable __rcu	*rt_next;
+		struct rt6_info		*rt6_next;
+		struct dn_route __rcu	*dn_next;
 	};
 };
 
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index d6b93d1..18b8a2c 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -1848,7 +1848,7 @@ unsigned dn_mss_from_pmtu(struct net_device *dev, int mtu)
 {
 	unsigned mss = 230 - DN_MAX_NSP_DATA_HEADER;
 	if (dev) {
-		struct dn_dev *dn_db = dev->dn_ptr;
+		struct dn_dev *dn_db = rcu_dereference_raw(dev->dn_ptr);
 		mtu -= LL_RESERVED_SPACE(dev);
 		if (dn_db->use_long)
 			mtu -= 21;
diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index 4c409b4..0ba1563 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -267,7 +267,7 @@ static int dn_forwarding_proc(ctl_table *table, int write,
 	if (table->extra1 == NULL)
 		return -EINVAL;
 
-	dn_db = dev->dn_ptr;
+	dn_db = rcu_dereference_raw(dev->dn_ptr);
 	old = dn_db->parms.forwarding;
 
 	err = proc_dointvec(table, write, buffer, lenp, ppos);
@@ -332,14 +332,19 @@ static struct dn_ifaddr *dn_dev_alloc_ifa(void)
 	return ifa;
 }
 
-static __inline__ void dn_dev_free_ifa(struct dn_ifaddr *ifa)
+static void dn_dev_free_ifa_rcu(struct rcu_head *head)
 {
-	kfree(ifa);
+	kfree(container_of(head, struct dn_ifaddr, rcu));
 }
 
-static void dn_dev_del_ifa(struct dn_dev *dn_db, struct dn_ifaddr **ifap, int destroy)
+static void dn_dev_free_ifa(struct dn_ifaddr *ifa)
 {
-	struct dn_ifaddr *ifa1 = *ifap;
+	call_rcu(&ifa->rcu, dn_dev_free_ifa_rcu);
+}
+
+static void dn_dev_del_ifa(struct dn_dev *dn_db, struct dn_ifaddr __rcu **ifap, int destroy)
+{
+	struct dn_ifaddr *ifa1 = rtnl_dereference(*ifap);
 	unsigned char mac_addr[6];
 	struct net_device *dev = dn_db->dev;
 
@@ -373,7 +378,9 @@ static int dn_dev_insert_ifa(struct dn_dev *dn_db, struct dn_ifaddr *ifa)
 	ASSERT_RTNL();
 
 	/* Check for duplicates */
-	for(ifa1 = dn_db->ifa_list; ifa1; ifa1 = ifa1->ifa_next) {
+	for (ifa1 = rtnl_dereference(dn_db->ifa_list);
+	     ifa1 != NULL;
+	     ifa1 = rtnl_dereference(ifa1->ifa_next)) {
 		if (ifa1->ifa_local == ifa->ifa_local)
 			return -EEXIST;
 	}
@@ -386,7 +393,7 @@ static int dn_dev_insert_ifa(struct dn_dev *dn_db, struct dn_ifaddr *ifa)
 	}
 
 	ifa->ifa_next = dn_db->ifa_list;
-	dn_db->ifa_list = ifa;
+	rcu_assign_pointer(dn_db->ifa_list, ifa);
 
 	dn_ifaddr_notify(RTM_NEWADDR, ifa);
 	blocking_notifier_call_chain(&dnaddr_chain, NETDEV_UP, ifa);
@@ -396,7 +403,7 @@ static int dn_dev_insert_ifa(struct dn_dev *dn_db, struct dn_ifaddr *ifa)
 
 static int dn_dev_set_ifa(struct net_device *dev, struct dn_ifaddr *ifa)
 {
-	struct dn_dev *dn_db = dev->dn_ptr;
+	struct dn_dev *dn_db = rtnl_dereference(dev->dn_ptr);
 	int rv;
 
 	if (dn_db == NULL) {
@@ -425,7 +432,8 @@ int dn_dev_ioctl(unsigned int cmd, void __user *arg)
 	struct sockaddr_dn *sdn = (struct sockaddr_dn *)&ifr->ifr_addr;
 	struct dn_dev *dn_db;
 	struct net_device *dev;
-	struct dn_ifaddr *ifa = NULL, **ifap = NULL;
+	struct dn_ifaddr *ifa = NULL;
+	struct dn_ifaddr __rcu **ifap = NULL;
 	int ret = 0;
 
 	if (copy_from_user(ifr, arg, DN_IFREQ_SIZE))
@@ -454,8 +462,10 @@ int dn_dev_ioctl(unsigned int cmd, void __user *arg)
 		goto done;
 	}
 
-	if ((dn_db = dev->dn_ptr) != NULL) {
-		for (ifap = &dn_db->ifa_list; (ifa=*ifap) != NULL; ifap = &ifa->ifa_next)
+	if ((dn_db = rtnl_dereference(dev->dn_ptr)) != NULL) {
+		for (ifap = &dn_db->ifa_list;
+		     (ifa = rtnl_dereference(*ifap)) != NULL;
+		     ifap = &ifa->ifa_next)
 			if (strcmp(ifr->ifr_name, ifa->ifa_label) == 0)
 				break;
 	}
@@ -558,7 +568,7 @@ static struct dn_dev *dn_dev_by_index(int ifindex)
 
 	dev = __dev_get_by_index(&init_net, ifindex);
 	if (dev)
-		dn_dev = dev->dn_ptr;
+		dn_dev = rtnl_dereference(dev->dn_ptr);
 
 	return dn_dev;
 }
@@ -576,7 +586,8 @@ static int dn_nl_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	struct nlattr *tb[IFA_MAX+1];
 	struct dn_dev *dn_db;
 	struct ifaddrmsg *ifm;
-	struct dn_ifaddr *ifa, **ifap;
+	struct dn_ifaddr *ifa;
+	struct dn_ifaddr __rcu **ifap;
 	int err = -EINVAL;
 
 	if (!net_eq(net, &init_net))
@@ -592,7 +603,9 @@ static int dn_nl_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 		goto errout;
 
 	err = -EADDRNOTAVAIL;
-	for (ifap = &dn_db->ifa_list; (ifa = *ifap); ifap = &ifa->ifa_next) {
+	for (ifap = &dn_db->ifa_list;
+	     (ifa = rtnl_dereference(*ifap)) != NULL;
+	     ifap = &ifa->ifa_next) {
 		if (tb[IFA_LOCAL] &&
 		    nla_memcmp(tb[IFA_LOCAL], &ifa->ifa_local, 2))
 			continue;
@@ -632,7 +645,7 @@ static int dn_nl_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	if ((dev = __dev_get_by_index(&init_net, ifm->ifa_index)) == NULL)
 		return -ENODEV;
 
-	if ((dn_db = dev->dn_ptr) == NULL) {
+	if ((dn_db = rtnl_dereference(dev->dn_ptr)) == NULL) {
 		dn_db = dn_dev_create(dev, &err);
 		if (!dn_db)
 			return err;
@@ -748,11 +761,11 @@ static int dn_nl_dump_ifaddr(struct sk_buff *skb, struct netlink_callback *cb)
 			skip_naddr = 0;
 		}
 
-		if ((dn_db = dev->dn_ptr) == NULL)
+		if ((dn_db = rtnl_dereference(dev->dn_ptr)) == NULL)
 			goto cont;
 
-		for (ifa = dn_db->ifa_list, dn_idx = 0; ifa;
-		     ifa = ifa->ifa_next, dn_idx++) {
+		for (ifa = rtnl_dereference(dn_db->ifa_list), dn_idx = 0; ifa;
+		     ifa = rtnl_dereference(ifa->ifa_next), dn_idx++) {
 			if (dn_idx < skip_naddr)
 				continue;
 
@@ -773,21 +786,22 @@ done:
 
 static int dn_dev_get_first(struct net_device *dev, __le16 *addr)
 {
-	struct dn_dev *dn_db = (struct dn_dev *)dev->dn_ptr;
+	struct dn_dev *dn_db;
 	struct dn_ifaddr *ifa;
 	int rv = -ENODEV;
 
+	rcu_read_lock();
+	dn_db = rcu_dereference(dev->dn_ptr);
 	if (dn_db == NULL)
 		goto out;
 
-	rtnl_lock();
-	ifa = dn_db->ifa_list;
+	ifa = rcu_dereference(dn_db->ifa_list);
 	if (ifa != NULL) {
 		*addr = ifa->ifa_local;
 		rv = 0;
 	}
-	rtnl_unlock();
 out:
+	rcu_read_unlock();
 	return rv;
 }
 
@@ -823,7 +837,7 @@ static void dn_send_endnode_hello(struct net_device *dev, struct dn_ifaddr *ifa)
 	struct endnode_hello_message *msg;
 	struct sk_buff *skb = NULL;
 	__le16 *pktlen;
-	struct dn_dev *dn_db = (struct dn_dev *)dev->dn_ptr;
+	struct dn_dev *dn_db = rcu_dereference_raw(dev->dn_ptr);
 
 	if ((skb = dn_alloc_skb(NULL, sizeof(*msg), GFP_ATOMIC)) == NULL)
 		return;
@@ -889,7 +903,7 @@ static int dn_am_i_a_router(struct dn_neigh *dn, struct dn_dev *dn_db, struct dn
 static void dn_send_router_hello(struct net_device *dev, struct dn_ifaddr *ifa)
 {
 	int n;
-	struct dn_dev *dn_db = dev->dn_ptr;
+	struct dn_dev *dn_db = rcu_dereference_raw(dev->dn_ptr);
 	struct dn_neigh *dn = (struct dn_neigh *)dn_db->router;
 	struct sk_buff *skb;
 	size_t size;
@@ -960,7 +974,7 @@ static void dn_send_router_hello(struct net_device *dev, struct dn_ifaddr *ifa)
 
 static void dn_send_brd_hello(struct net_device *dev, struct dn_ifaddr *ifa)
 {
-	struct dn_dev *dn_db = (struct dn_dev *)dev->dn_ptr;
+	struct dn_dev *dn_db = rcu_dereference_raw(dev->dn_ptr);
 
 	if (dn_db->parms.forwarding == 0)
 		dn_send_endnode_hello(dev, ifa);
@@ -998,7 +1012,7 @@ static void dn_send_ptp_hello(struct net_device *dev, struct dn_ifaddr *ifa)
 
 static int dn_eth_up(struct net_device *dev)
 {
-	struct dn_dev *dn_db = dev->dn_ptr;
+	struct dn_dev *dn_db = rcu_dereference_raw(dev->dn_ptr);
 
 	if (dn_db->parms.forwarding == 0)
 		dev_mc_add(dev, dn_rt_all_end_mcast);
@@ -1012,7 +1026,7 @@ static int dn_eth_up(struct net_device *dev)
 
 static void dn_eth_down(struct net_device *dev)
 {
-	struct dn_dev *dn_db = dev->dn_ptr;
+	struct dn_dev *dn_db = rcu_dereference_raw(dev->dn_ptr);
 
 	if (dn_db->parms.forwarding == 0)
 		dev_mc_del(dev, dn_rt_all_end_mcast);
@@ -1025,12 +1039,16 @@ static void dn_dev_set_timer(struct net_device *dev);
 static void dn_dev_timer_func(unsigned long arg)
 {
 	struct net_device *dev = (struct net_device *)arg;
-	struct dn_dev *dn_db = dev->dn_ptr;
+	struct dn_dev *dn_db;
 	struct dn_ifaddr *ifa;
 
+	rcu_read_lock();
+	dn_db = rcu_dereference(dev->dn_ptr);
 	if (dn_db->t3 <= dn_db->parms.t2) {
 		if (dn_db->parms.timer3) {
-			for(ifa = dn_db->ifa_list; ifa; ifa = ifa->ifa_next) {
+			for (ifa = rcu_dereference(dn_db->ifa_list);
+			     ifa;
+			     ifa = rcu_dereference(ifa->ifa_next)) {
 				if (!(ifa->ifa_flags & IFA_F_SECONDARY))
 					dn_db->parms.timer3(dev, ifa);
 			}
@@ -1039,13 +1057,13 @@ static void dn_dev_timer_func(unsigned long arg)
 	} else {
 		dn_db->t3 -= dn_db->parms.t2;
 	}
-
+	rcu_read_unlock();
 	dn_dev_set_timer(dev);
 }
 
 static void dn_dev_set_timer(struct net_device *dev)
 {
-	struct dn_dev *dn_db = dev->dn_ptr;
+	struct dn_dev *dn_db = rcu_dereference_raw(dev->dn_ptr);
 
 	if (dn_db->parms.t2 > dn_db->parms.t3)
 		dn_db->parms.t2 = dn_db->parms.t3;
@@ -1077,8 +1095,8 @@ static struct dn_dev *dn_dev_create(struct net_device *dev, int *err)
 		return NULL;
 
 	memcpy(&dn_db->parms, p, sizeof(struct dn_dev_parms));
-	smp_wmb();
-	dev->dn_ptr = dn_db;
+
+	rcu_assign_pointer(dev->dn_ptr, dn_db);
 	dn_db->dev = dev;
 	init_timer(&dn_db->timer);
 
@@ -1086,7 +1104,7 @@ static struct dn_dev *dn_dev_create(struct net_device *dev, int *err)
 
 	dn_db->neigh_parms = neigh_parms_alloc(dev, &dn_neigh_table);
 	if (!dn_db->neigh_parms) {
-		dev->dn_ptr = NULL;
+		rcu_assign_pointer(dev->dn_ptr, NULL);
 		kfree(dn_db);
 		return NULL;
 	}
@@ -1125,7 +1143,7 @@ void dn_dev_up(struct net_device *dev)
 	struct dn_ifaddr *ifa;
 	__le16 addr = decnet_address;
 	int maybe_default = 0;
-	struct dn_dev *dn_db = (struct dn_dev *)dev->dn_ptr;
+	struct dn_dev *dn_db = rtnl_dereference(dev->dn_ptr);
 
 	if ((dev->type != ARPHRD_ETHER) && (dev->type != ARPHRD_LOOPBACK))
 		return;
@@ -1176,7 +1194,7 @@ void dn_dev_up(struct net_device *dev)
 
 static void dn_dev_delete(struct net_device *dev)
 {
-	struct dn_dev *dn_db = dev->dn_ptr;
+	struct dn_dev *dn_db = rtnl_dereference(dev->dn_ptr);
 
 	if (dn_db == NULL)
 		return;
@@ -1204,13 +1222,13 @@ static void dn_dev_delete(struct net_device *dev)
 
 void dn_dev_down(struct net_device *dev)
 {
-	struct dn_dev *dn_db = dev->dn_ptr;
+	struct dn_dev *dn_db = rtnl_dereference(dev->dn_ptr);
 	struct dn_ifaddr *ifa;
 
 	if (dn_db == NULL)
 		return;
 
-	while((ifa = dn_db->ifa_list) != NULL) {
+	while ((ifa = rtnl_dereference(dn_db->ifa_list)) != NULL) {
 		dn_dev_del_ifa(dn_db, &dn_db->ifa_list, 0);
 		dn_dev_free_ifa(ifa);
 	}
@@ -1270,7 +1288,7 @@ static inline int is_dn_dev(struct net_device *dev)
 }
 
 static void *dn_dev_seq_start(struct seq_file *seq, loff_t *pos)
-	__acquires(rcu)
+	__acquires(RCU)
 {
 	int i;
 	struct net_device *dev;
@@ -1313,7 +1331,7 @@ static void *dn_dev_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 }
 
 static void dn_dev_seq_stop(struct seq_file *seq, void *v)
-	__releases(rcu)
+	__releases(RCU)
 {
 	rcu_read_unlock();
 }
@@ -1340,7 +1358,7 @@ static int dn_dev_seq_show(struct seq_file *seq, void *v)
 		struct net_device *dev = v;
 		char peer_buf[DN_ASCBUF_LEN];
 		char router_buf[DN_ASCBUF_LEN];
-		struct dn_dev *dn_db = dev->dn_ptr;
+		struct dn_dev *dn_db = rcu_dereference(dev->dn_ptr);
 
 		seq_printf(seq, "%-8s %1s     %04u %04u   %04lu %04lu"
 				"   %04hu    %03d %02x    %-10s %-7s %-7s\n",
diff --git a/net/decnet/dn_fib.c b/net/decnet/dn_fib.c
index 4ab96c1..0ef0a81 100644
--- a/net/decnet/dn_fib.c
+++ b/net/decnet/dn_fib.c
@@ -610,10 +610,12 @@ static void dn_fib_del_ifaddr(struct dn_ifaddr *ifa)
 	/* Scan device list */
 	rcu_read_lock();
 	for_each_netdev_rcu(&init_net, dev) {
-		dn_db = dev->dn_ptr;
+		dn_db = rcu_dereference(dev->dn_ptr);
 		if (dn_db == NULL)
 			continue;
-		for(ifa2 = dn_db->ifa_list; ifa2; ifa2 = ifa2->ifa_next) {
+		for (ifa2 = rcu_dereference(dn_db->ifa_list);
+		     ifa2 != NULL;
+		     ifa2 = rcu_dereference(ifa2->ifa_next)) {
 			if (ifa2->ifa_local == ifa->ifa_local) {
 				found_it = 1;
 				break;
diff --git a/net/decnet/dn_neigh.c b/net/decnet/dn_neigh.c
index a085dbc..602dade 100644
--- a/net/decnet/dn_neigh.c
+++ b/net/decnet/dn_neigh.c
@@ -391,7 +391,7 @@ int dn_neigh_router_hello(struct sk_buff *skb)
 		write_lock(&neigh->lock);
 
 		neigh->used = jiffies;
-		dn_db = (struct dn_dev *)neigh->dev->dn_ptr;
+		dn_db = rcu_dereference(neigh->dev->dn_ptr);
 
 		if (!(neigh->nud_state & NUD_PERMANENT)) {
 			neigh->updated = jiffies;
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index df0f3e5..94a9eb1 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -93,7 +93,7 @@
 
 struct dn_rt_hash_bucket
 {
-	struct dn_route *chain;
+	struct dn_route __rcu *chain;
 	spinlock_t lock;
 };
 
@@ -157,15 +157,17 @@ static inline void dnrt_drop(struct dn_route *rt)
 static void dn_dst_check_expire(unsigned long dummy)
 {
 	int i;
-	struct dn_route *rt, **rtp;
+	struct dn_route *rt;
+	struct dn_route __rcu **rtp;
 	unsigned long now = jiffies;
 	unsigned long expire = 120 * HZ;
 
-	for(i = 0; i <= dn_rt_hash_mask; i++) {
+	for (i = 0; i <= dn_rt_hash_mask; i++) {
 		rtp = &dn_rt_hash_table[i].chain;
 
 		spin_lock(&dn_rt_hash_table[i].lock);
-		while((rt=*rtp) != NULL) {
+		while ((rt = rcu_dereference_protected(*rtp,
+						lockdep_is_held(&dn_rt_hash_table[i].lock))) != NULL) {
 			if (atomic_read(&rt->dst.__refcnt) ||
 					(now - rt->dst.lastuse) < expire) {
 				rtp = &rt->dst.dn_next;
@@ -186,17 +188,19 @@ static void dn_dst_check_expire(unsigned long dummy)
 
 static int dn_dst_gc(struct dst_ops *ops)
 {
-	struct dn_route *rt, **rtp;
+	struct dn_route *rt;
+	struct dn_route __rcu **rtp;
 	int i;
 	unsigned long now = jiffies;
 	unsigned long expire = 10 * HZ;
 
-	for(i = 0; i <= dn_rt_hash_mask; i++) {
+	for (i = 0; i <= dn_rt_hash_mask; i++) {
 
 		spin_lock_bh(&dn_rt_hash_table[i].lock);
 		rtp = &dn_rt_hash_table[i].chain;
 
-		while((rt=*rtp) != NULL) {
+		while ((rt = rcu_dereference_protected(*rtp,
+						lockdep_is_held(&dn_rt_hash_table[i].lock))) != NULL) {
 			if (atomic_read(&rt->dst.__refcnt) ||
 					(now - rt->dst.lastuse) < expire) {
 				rtp = &rt->dst.dn_next;
@@ -227,7 +231,7 @@ static void dn_dst_update_pmtu(struct dst_entry *dst, u32 mtu)
 {
 	u32 min_mtu = 230;
 	struct dn_dev *dn = dst->neighbour ?
-			    (struct dn_dev *)dst->neighbour->dev->dn_ptr : NULL;
+			    rcu_dereference_raw(dst->neighbour->dev->dn_ptr) : NULL;
 
 	if (dn && dn->use_long == 0)
 		min_mtu -= 6;
@@ -277,13 +281,15 @@ static inline int compare_keys(struct flowi *fl1, struct flowi *fl2)
 
 static int dn_insert_route(struct dn_route *rt, unsigned hash, struct dn_route **rp)
 {
-	struct dn_route *rth, **rthp;
+	struct dn_route *rth;
+	struct dn_route __rcu **rthp;
 	unsigned long now = jiffies;
 
 	rthp = &dn_rt_hash_table[hash].chain;
 
 	spin_lock_bh(&dn_rt_hash_table[hash].lock);
-	while((rth = *rthp) != NULL) {
+	while ((rth = rcu_dereference_protected(*rthp,
+						lockdep_is_held(&dn_rt_hash_table[hash].lock))) != NULL) {
 		if (compare_keys(&rth->fl, &rt->fl)) {
 			/* Put it first */
 			*rthp = rth->dst.dn_next;
@@ -315,15 +321,15 @@ static void dn_run_flush(unsigned long dummy)
 	int i;
 	struct dn_route *rt, *next;
 
-	for(i = 0; i < dn_rt_hash_mask; i++) {
+	for (i = 0; i < dn_rt_hash_mask; i++) {
 		spin_lock_bh(&dn_rt_hash_table[i].lock);
 
-		if ((rt = xchg(&dn_rt_hash_table[i].chain, NULL)) == NULL)
+		if ((rt = xchg((struct dn_route **)&dn_rt_hash_table[i].chain, NULL)) == NULL)
 			goto nothing_to_declare;
 
-		for(; rt; rt=next) {
-			next = rt->dst.dn_next;
-			rt->dst.dn_next = NULL;
+		for(; rt; rt = next) {
+			next = rcu_dereference_raw(rt->dst.dn_next);
+			RCU_INIT_POINTER(rt->dst.dn_next, NULL);
 			dst_free((struct dst_entry *)rt);
 		}
 
@@ -458,15 +464,16 @@ static int dn_return_long(struct sk_buff *skb)
  */
 static int dn_route_rx_packet(struct sk_buff *skb)
 {
-	struct dn_skb_cb *cb = DN_SKB_CB(skb);
+	struct dn_skb_cb *cb;
 	int err;
 
 	if ((err = dn_route_input(skb)) == 0)
 		return dst_input(skb);
 
+	cb = DN_SKB_CB(skb);
 	if (decnet_debug_level & 4) {
 		char *devname = skb->dev ? skb->dev->name : "???";
-		struct dn_skb_cb *cb = DN_SKB_CB(skb);
+
 		printk(KERN_DEBUG
 			"DECnet: dn_route_rx_packet: rt_flags=0x%02x dev=%s len=%d src=0x%04hx dst=0x%04hx err=%d type=%d\n",
 			(int)cb->rt_flags, devname, skb->len,
@@ -573,7 +580,7 @@ int dn_route_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type
 	struct dn_skb_cb *cb;
 	unsigned char flags = 0;
 	__u16 len = le16_to_cpu(*(__le16 *)skb->data);
-	struct dn_dev *dn = (struct dn_dev *)dev->dn_ptr;
+	struct dn_dev *dn = rcu_dereference(dev->dn_ptr);
 	unsigned char padlen = 0;
 
 	if (!net_eq(dev_net(dev), &init_net))
@@ -728,7 +735,7 @@ static int dn_forward(struct sk_buff *skb)
 {
 	struct dn_skb_cb *cb = DN_SKB_CB(skb);
 	struct dst_entry *dst = skb_dst(skb);
-	struct dn_dev *dn_db = dst->dev->dn_ptr;
+	struct dn_dev *dn_db = rcu_dereference(dst->dev->dn_ptr);
 	struct dn_route *rt;
 	struct neighbour *neigh = dst->neighbour;
 	int header_len;
@@ -835,13 +842,16 @@ static inline int dn_match_addr(__le16 addr1, __le16 addr2)
 static __le16 dnet_select_source(const struct net_device *dev, __le16 daddr, int scope)
 {
 	__le16 saddr = 0;
-	struct dn_dev *dn_db = dev->dn_ptr;
+	struct dn_dev *dn_db;
 	struct dn_ifaddr *ifa;
 	int best_match = 0;
 	int ret;
 
-	read_lock(&dev_base_lock);
-	for(ifa = dn_db->ifa_list; ifa; ifa = ifa->ifa_next) {
+	rcu_read_lock();
+	dn_db = rcu_dereference(dev->dn_ptr);
+	for (ifa = rcu_dereference(dn_db->ifa_list);
+	     ifa != NULL;
+	     ifa = rcu_dereference(ifa->ifa_next)) {
 		if (ifa->ifa_scope > scope)
 			continue;
 		if (!daddr) {
@@ -854,7 +864,7 @@ static __le16 dnet_select_source(const struct net_device *dev, __le16 daddr, int
 		if (best_match == 0)
 			saddr = ifa->ifa_local;
 	}
-	read_unlock(&dev_base_lock);
+	rcu_read_unlock();
 
 	return saddr;
 }
@@ -1020,7 +1030,7 @@ source_ok:
 		err = -ENODEV;
 		if (dev_out == NULL)
 			goto out;
-		dn_db = dev_out->dn_ptr;
+		dn_db = rcu_dereference_raw(dev_out->dn_ptr);
 		/* Possible improvement - check all devices for local addr */
 		if (dn_dev_islocal(dev_out, fl.fld_dst)) {
 			dev_put(dev_out);
@@ -1233,7 +1243,7 @@ static int dn_route_input_slow(struct sk_buff *skb)
 
 	dev_hold(in_dev);
 
-	if ((dn_db = in_dev->dn_ptr) == NULL)
+	if ((dn_db = rcu_dereference(in_dev->dn_ptr)) == NULL)
 		goto out;
 
 	/* Zero source addresses are not allowed */
@@ -1677,15 +1687,15 @@ static struct dn_route *dn_rt_cache_get_next(struct seq_file *seq, struct dn_rou
 {
 	struct dn_rt_cache_iter_state *s = seq->private;
 
-	rt = rt->dst.dn_next;
-	while(!rt) {
+	rt = rcu_dereference_bh(rt->dst.dn_next);
+	while (!rt) {
 		rcu_read_unlock_bh();
 		if (--s->bucket < 0)
 			break;
 		rcu_read_lock_bh();
-		rt = dn_rt_hash_table[s->bucket].chain;
+		rt = rcu_dereference_bh(dn_rt_hash_table[s->bucket].chain);
 	}
-	return rcu_dereference_bh(rt);
+	return rt;
 }
 
 static void *dn_rt_cache_seq_start(struct seq_file *seq, loff_t *pos)


