From: "David S. Miller" <davem@redhat.com>
Subject: [PATCH] Move inetdev/ifa over to RCU
Date: Thu, 12 Aug 2004 16:59:54 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040812165954.00429e65.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: robert.olsson@data.slu.se, hadi@cyberus.ca, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


[ Robert, Jamal, Alexey, the previous version I sent you guys
  privately early today had a minor bug, in inet_free_ifa()
  we now need to use in_dev_put() instead of __in_dev_put() ]

The main motivation for this was to make fib_validate_source()
cheaper, as currently it needs a global lock in order to
access the inet device interface lists.

This makes is all use RCU.

I kept the non-RCU lock usage in multicast address list
handling in net/ipv4/igmp.c, but that could use RCU as
well if we wanted to.

While doing this I noticed that devinet.c had these two
counters (inet_ifa_count and inet_dev_count) which were
updated but nobody ever read, so these got killed.

Someone poke holes in this patch please :-)

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/08/12 16:42:07-07:00 davem@nuts.davemloft.net 
#   [IPV4]: Move inetdev/ifa locking over to RCU.
#   
#   Multicast ipv4 address handling still uses rwlock
#   and spinlock synchronization.
#   
#   Signed-off-by: David S. Miller <davem@redhat.com>
# 
# net/sctp/protocol.c
#   2004/08/12 16:41:13-07:00 davem@nuts.davemloft.net +3 -5
#   [IPV4]: Move inetdev/ifa locking over to RCU.
# 
# net/irda/irlan/irlan_eth.c
#   2004/08/12 16:41:13-07:00 davem@nuts.davemloft.net +2 -2
#   [IPV4]: Move inetdev/ifa locking over to RCU.
# 
# net/ipv4/route.c
#   2004/08/12 16:41:13-07:00 davem@nuts.davemloft.net +3 -3
#   [IPV4]: Move inetdev/ifa locking over to RCU.
# 
# net/ipv4/igmp.c
#   2004/08/12 16:41:13-07:00 davem@nuts.davemloft.net +47 -45
#   [IPV4]: Move inetdev/ifa locking over to RCU.
# 
# net/ipv4/icmp.c
#   2004/08/12 16:41:13-07:00 davem@nuts.davemloft.net +2 -2
#   [IPV4]: Move inetdev/ifa locking over to RCU.
# 
# net/ipv4/fib_frontend.c
#   2004/08/12 16:41:13-07:00 davem@nuts.davemloft.net +2 -2
#   [IPV4]: Move inetdev/ifa locking over to RCU.
# 
# net/ipv4/devinet.c
#   2004/08/12 16:41:13-07:00 davem@nuts.davemloft.net +49 -63
#   [IPV4]: Move inetdev/ifa locking over to RCU.
# 
# include/linux/inetdevice.h
#   2004/08/12 16:41:13-07:00 davem@nuts.davemloft.net +17 -11
#   [IPV4]: Move inetdev/ifa locking over to RCU.
# 
diff -Nru a/include/linux/inetdevice.h b/include/linux/inetdevice.h
--- a/include/linux/inetdevice.h	2004-08-12 16:42:31 -07:00
+++ b/include/linux/inetdevice.h	2004-08-12 16:42:31 -07:00
@@ -3,6 +3,8 @@
 
 #ifdef __KERNEL__
 
+#include <linux/rcupdate.h>
+
 struct ipv4_devconf
 {
 	int	accept_redirects;
@@ -31,13 +33,13 @@
 
 struct in_device
 {
-	struct net_device		*dev;
+	struct net_device	*dev;
 	atomic_t		refcnt;
-	rwlock_t		lock;
 	int			dead;
 	struct in_ifaddr	*ifa_list;	/* IP ifaddr chain		*/
+	rwlock_t		mc_list_lock;
 	struct ip_mc_list	*mc_list;	/* IP multicast filter chain    */
-	rwlock_t		mc_lock;	/* for mc_tomb */
+	spinlock_t		mc_tomb_lock;
 	struct ip_mc_list	*mc_tomb;
 	unsigned long		mr_v1_seen;
 	unsigned long		mr_v2_seen;
@@ -50,6 +52,7 @@
 
 	struct neigh_parms	*arp_parms;
 	struct ipv4_devconf	cnf;
+	struct rcu_head		rcu_head;
 };
 
 #define IN_DEV_FORWARD(in_dev)		((in_dev)->cnf.forwarding)
@@ -80,6 +83,7 @@
 {
 	struct in_ifaddr	*ifa_next;
 	struct in_device	*ifa_dev;
+	struct rcu_head		rcu_head;
 	u32			ifa_local;
 	u32			ifa_address;
 	u32			ifa_mask;
@@ -133,19 +137,16 @@
 
 #define endfor_ifa(in_dev) }
 
-extern rwlock_t inetdev_lock;
-
-
 static __inline__ struct in_device *
 in_dev_get(const struct net_device *dev)
 {
 	struct in_device *in_dev;
 
-	read_lock(&inetdev_lock);
+	rcu_read_lock();
 	in_dev = dev->ip_ptr;
 	if (in_dev)
 		atomic_inc(&in_dev->refcnt);
-	read_unlock(&inetdev_lock);
+	rcu_read_unlock();
 	return in_dev;
 }
 
@@ -157,11 +158,16 @@
 
 extern void in_dev_finish_destroy(struct in_device *idev);
 
-static __inline__ void
-in_dev_put(struct in_device *idev)
+static inline void in_dev_rcu_destroy(struct rcu_head *head)
+{
+	struct in_device *idev = container_of(head, struct in_device, rcu_head);
+	in_dev_finish_destroy(idev);
+}
+
+static inline void in_dev_put(struct in_device *idev)
 {
 	if (atomic_dec_and_test(&idev->refcnt))
-		in_dev_finish_destroy(idev);
+		call_rcu(&idev->rcu_head, in_dev_rcu_destroy);
 }
 
 #define __in_dev_put(idev)  atomic_dec(&(idev)->refcnt)
diff -Nru a/net/ipv4/devinet.c b/net/ipv4/devinet.c
--- a/net/ipv4/devinet.c	2004-08-12 16:42:31 -07:00
+++ b/net/ipv4/devinet.c	2004-08-12 16:42:31 -07:00
@@ -88,12 +88,9 @@
 static void devinet_sysctl_unregister(struct ipv4_devconf *p);
 #endif
 
-int inet_ifa_count;
-int inet_dev_count;
-
 /* Locks all the inet devices. */
 
-rwlock_t inetdev_lock = RW_LOCK_UNLOCKED;
+static spinlock_t inetdev_lock = SPIN_LOCK_UNLOCKED;
 
 static struct in_ifaddr *inet_alloc_ifa(void)
 {
@@ -101,18 +98,24 @@
 
 	if (ifa) {
 		memset(ifa, 0, sizeof(*ifa));
-		inet_ifa_count++;
+		INIT_RCU_HEAD(&ifa->rcu_head);
 	}
 
 	return ifa;
 }
 
-static __inline__ void inet_free_ifa(struct in_ifaddr *ifa)
+static inline void inet_free_ifa(struct in_ifaddr *ifa)
 {
 	if (ifa->ifa_dev)
-		__in_dev_put(ifa->ifa_dev);
+		in_dev_put(ifa->ifa_dev);
 	kfree(ifa);
-	inet_ifa_count--;
+}
+
+static void inet_rcu_free_ifa(struct rcu_head *head)
+{
+	struct in_ifaddr *ifa = container_of(head, struct in_ifaddr, rcu_head);
+
+	inet_free_ifa(ifa);
 }
 
 void in_dev_finish_destroy(struct in_device *idev)
@@ -129,7 +132,6 @@
 	if (!idev->dead)
 		printk("Freeing alive in_device %p\n", idev);
 	else {
-		inet_dev_count--;
 		kfree(idev);
 	}
 }
@@ -144,24 +146,23 @@
 	if (!in_dev)
 		goto out;
 	memset(in_dev, 0, sizeof(*in_dev));
-	in_dev->lock = RW_LOCK_UNLOCKED;
+	INIT_RCU_HEAD(&in_dev->rcu_head);
 	memcpy(&in_dev->cnf, &ipv4_devconf_dflt, sizeof(in_dev->cnf));
 	in_dev->cnf.sysctl = NULL;
 	in_dev->dev = dev;
 	if ((in_dev->arp_parms = neigh_parms_alloc(dev, &arp_tbl)) == NULL)
 		goto out_kfree;
-	inet_dev_count++;
 	/* Reference in_dev->dev */
 	dev_hold(dev);
 #ifdef CONFIG_SYSCTL
 	neigh_sysctl_register(dev, in_dev->arp_parms, NET_IPV4,
 			      NET_IPV4_NEIGH, "ipv4", NULL);
 #endif
-	write_lock_bh(&inetdev_lock);
+	spin_lock_bh(&inetdev_lock);
 	dev->ip_ptr = in_dev;
 	/* Account for reference dev->ip_ptr */
 	in_dev_hold(in_dev);
-	write_unlock_bh(&inetdev_lock);
+	spin_unlock_bh(&inetdev_lock);
 #ifdef CONFIG_SYSCTL
 	devinet_sysctl_register(in_dev, &in_dev->cnf);
 #endif
@@ -188,16 +189,16 @@
 
 	while ((ifa = in_dev->ifa_list) != NULL) {
 		inet_del_ifa(in_dev, &in_dev->ifa_list, 0);
-		inet_free_ifa(ifa);
+		call_rcu(&ifa->rcu_head, inet_rcu_free_ifa);
 	}
 
 #ifdef CONFIG_SYSCTL
 	devinet_sysctl_unregister(&in_dev->cnf);
 #endif
-	write_lock_bh(&inetdev_lock);
+	spin_lock_bh(&inetdev_lock);
 	in_dev->dev->ip_ptr = NULL;
 	/* in_dev_put following below will kill the in_device */
-	write_unlock_bh(&inetdev_lock);
+	spin_unlock_bh(&inetdev_lock);
 
 #ifdef CONFIG_SYSCTL
 	neigh_sysctl_unregister(in_dev->arp_parms);
@@ -208,16 +209,16 @@
 
 int inet_addr_onlink(struct in_device *in_dev, u32 a, u32 b)
 {
-	read_lock(&in_dev->lock);
+	rcu_read_lock();
 	for_primary_ifa(in_dev) {
 		if (inet_ifa_match(a, ifa)) {
 			if (!b || inet_ifa_match(b, ifa)) {
-				read_unlock(&in_dev->lock);
+				rcu_read_unlock();
 				return 1;
 			}
 		}
 	} endfor_ifa(in_dev);
-	read_unlock(&in_dev->lock);
+	rcu_read_unlock();
 	return 0;
 }
 
@@ -241,21 +242,21 @@
 				ifap1 = &ifa->ifa_next;
 				continue;
 			}
-			write_lock_bh(&in_dev->lock);
+			spin_lock_bh(&inetdev_lock);
 			*ifap1 = ifa->ifa_next;
-			write_unlock_bh(&in_dev->lock);
+			spin_unlock_bh(&inetdev_lock);
 
 			rtmsg_ifa(RTM_DELADDR, ifa);
 			notifier_call_chain(&inetaddr_chain, NETDEV_DOWN, ifa);
-			inet_free_ifa(ifa);
+			call_rcu(&ifa->rcu_head, inet_rcu_free_ifa);
 		}
 	}
 
 	/* 2. Unlink it */
 
-	write_lock_bh(&in_dev->lock);
+	spin_lock_bh(&inetdev_lock);
 	*ifap = ifa1->ifa_next;
-	write_unlock_bh(&in_dev->lock);
+	spin_unlock_bh(&inetdev_lock);
 
 	/* 3. Announce address deletion */
 
@@ -270,7 +271,7 @@
 	rtmsg_ifa(RTM_DELADDR, ifa1);
 	notifier_call_chain(&inetaddr_chain, NETDEV_DOWN, ifa1);
 	if (destroy) {
-		inet_free_ifa(ifa1);
+		call_rcu(&ifa1->rcu_head, inet_rcu_free_ifa);
 
 		if (!in_dev->ifa_list)
 			inetdev_destroy(in_dev);
@@ -285,7 +286,7 @@
 	ASSERT_RTNL();
 
 	if (!ifa->ifa_local) {
-		inet_free_ifa(ifa);
+		call_rcu(&ifa->rcu_head, inet_rcu_free_ifa);
 		return 0;
 	}
 
@@ -300,11 +301,11 @@
 		if (ifa1->ifa_mask == ifa->ifa_mask &&
 		    inet_ifa_match(ifa1->ifa_address, ifa)) {
 			if (ifa1->ifa_local == ifa->ifa_local) {
-				inet_free_ifa(ifa);
+				call_rcu(&ifa->rcu_head, inet_rcu_free_ifa);
 				return -EEXIST;
 			}
 			if (ifa1->ifa_scope != ifa->ifa_scope) {
-				inet_free_ifa(ifa);
+				call_rcu(&ifa->rcu_head, inet_rcu_free_ifa);
 				return -EINVAL;
 			}
 			ifa->ifa_flags |= IFA_F_SECONDARY;
@@ -317,9 +318,9 @@
 	}
 
 	ifa->ifa_next = *ifap;
-	write_lock_bh(&in_dev->lock);
+	spin_lock_bh(&inetdev_lock);
 	*ifap = ifa;
-	write_unlock_bh(&in_dev->lock);
+	spin_unlock_bh(&inetdev_lock);
 
 	/* Send message first, then call notifier.
 	   Notifier will trigger FIB update, so that
@@ -339,7 +340,7 @@
 	if (!in_dev) {
 		in_dev = inetdev_init(dev);
 		if (!in_dev) {
-			inet_free_ifa(ifa);
+			call_rcu(&ifa->rcu_head, inet_rcu_free_ifa);
 			return -ENOBUFS;
 		}
 	}
@@ -771,12 +772,11 @@
 	u32 addr = 0;
 	struct in_device *in_dev;
 
-	read_lock(&inetdev_lock);
+	rcu_read_lock();
 	in_dev = __in_dev_get(dev);
 	if (!in_dev)
 		goto out_unlock_inetdev;
 
-	read_lock(&in_dev->lock);
 	for_primary_ifa(in_dev) {
 		if (ifa->ifa_scope > scope)
 			continue;
@@ -787,8 +787,7 @@
 		if (!addr)
 			addr = ifa->ifa_local;
 	} endfor_ifa(in_dev);
-	read_unlock(&in_dev->lock);
-	read_unlock(&inetdev_lock);
+	rcu_read_unlock();
 
 	if (addr)
 		goto out;
@@ -798,30 +797,25 @@
 	   in dev_base list.
 	 */
 	read_lock(&dev_base_lock);
-	read_lock(&inetdev_lock);
+	rcu_read_lock();
 	for (dev = dev_base; dev; dev = dev->next) {
 		if ((in_dev = __in_dev_get(dev)) == NULL)
 			continue;
 
-		read_lock(&in_dev->lock);
 		for_primary_ifa(in_dev) {
 			if (ifa->ifa_scope != RT_SCOPE_LINK &&
 			    ifa->ifa_scope <= scope) {
-				read_unlock(&in_dev->lock);
 				addr = ifa->ifa_local;
 				goto out_unlock_both;
 			}
 		} endfor_ifa(in_dev);
-		read_unlock(&in_dev->lock);
 	}
 out_unlock_both:
-	read_unlock(&inetdev_lock);
 	read_unlock(&dev_base_lock);
+out_unlock_inetdev:
+	rcu_read_unlock();
 out:
 	return addr;
-out_unlock_inetdev:
-	read_unlock(&inetdev_lock);
-	goto out;
 }
 
 static u32 confirm_addr_indev(struct in_device *in_dev, u32 dst,
@@ -874,29 +868,24 @@
 	struct in_device *in_dev;
 
 	if (dev) {
-		read_lock(&inetdev_lock);
-		if ((in_dev = __in_dev_get(dev))) {
-			read_lock(&in_dev->lock);
+		rcu_read_lock();
+		if ((in_dev = __in_dev_get(dev)))
 			addr = confirm_addr_indev(in_dev, dst, local, scope);
-			read_unlock(&in_dev->lock);
-		}
-		read_unlock(&inetdev_lock);
+		rcu_read_unlock();
 
 		return addr;
 	}
 
 	read_lock(&dev_base_lock);
-	read_lock(&inetdev_lock);
+	rcu_read_lock();
 	for (dev = dev_base; dev; dev = dev->next) {
 		if ((in_dev = __in_dev_get(dev))) {
-			read_lock(&in_dev->lock);
 			addr = confirm_addr_indev(in_dev, dst, local, scope);
-			read_unlock(&in_dev->lock);
 			if (addr)
 				break;
 		}
 	}
-	read_unlock(&inetdev_lock);
+	rcu_read_unlock();
 	read_unlock(&dev_base_lock);
 
 	return addr;
@@ -1065,12 +1054,12 @@
 			continue;
 		if (idx > s_idx)
 			s_ip_idx = 0;
-		read_lock(&inetdev_lock);
+		rcu_read_lock();
 		if ((in_dev = __in_dev_get(dev)) == NULL) {
-			read_unlock(&inetdev_lock);
+			rcu_read_unlock();
 			continue;
 		}
-		read_lock(&in_dev->lock);
+
 		for (ifa = in_dev->ifa_list, ip_idx = 0; ifa;
 		     ifa = ifa->ifa_next, ip_idx++) {
 			if (ip_idx < s_ip_idx)
@@ -1078,13 +1067,11 @@
 			if (inet_fill_ifaddr(skb, ifa, NETLINK_CB(cb->skb).pid,
 					     cb->nlh->nlmsg_seq,
 					     RTM_NEWADDR) <= 0) {
-				read_unlock(&in_dev->lock);
-				read_unlock(&inetdev_lock);
+				rcu_read_unlock();
 				goto done;
 			}
 		}
-		read_unlock(&in_dev->lock);
-		read_unlock(&inetdev_lock);
+		rcu_read_unlock();
 	}
 
 done:
@@ -1138,11 +1125,11 @@
 	read_lock(&dev_base_lock);
 	for (dev = dev_base; dev; dev = dev->next) {
 		struct in_device *in_dev;
-		read_lock(&inetdev_lock);
+		rcu_read_lock();
 		in_dev = __in_dev_get(dev);
 		if (in_dev)
 			in_dev->cnf.forwarding = on;
-		read_unlock(&inetdev_lock);
+		rcu_read_unlock();
 	}
 	read_unlock(&dev_base_lock);
 
@@ -1508,6 +1495,5 @@
 EXPORT_SYMBOL(in_dev_finish_destroy);
 EXPORT_SYMBOL(inet_select_addr);
 EXPORT_SYMBOL(inetdev_by_index);
-EXPORT_SYMBOL(inetdev_lock);
 EXPORT_SYMBOL(register_inetaddr_notifier);
 EXPORT_SYMBOL(unregister_inetaddr_notifier);
diff -Nru a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
--- a/net/ipv4/fib_frontend.c	2004-08-12 16:42:31 -07:00
+++ b/net/ipv4/fib_frontend.c	2004-08-12 16:42:31 -07:00
@@ -172,13 +172,13 @@
 	int ret;
 
 	no_addr = rpf = 0;
-	read_lock(&inetdev_lock);
+	rcu_read_lock();
 	in_dev = __in_dev_get(dev);
 	if (in_dev) {
 		no_addr = in_dev->ifa_list == NULL;
 		rpf = IN_DEV_RPFILTER(in_dev);
 	}
-	read_unlock(&inetdev_lock);
+	rcu_read_unlock();
 
 	if (in_dev == NULL)
 		goto e_inval;
diff -Nru a/net/ipv4/icmp.c b/net/ipv4/icmp.c
--- a/net/ipv4/icmp.c	2004-08-12 16:42:31 -07:00
+++ b/net/ipv4/icmp.c	2004-08-12 16:42:31 -07:00
@@ -878,7 +878,7 @@
 	in_dev = in_dev_get(dev);
 	if (!in_dev)
 		goto out;
-	read_lock(&in_dev->lock);
+	rcu_read_lock();
 	if (in_dev->ifa_list &&
 	    IN_DEV_LOG_MARTIANS(in_dev) &&
 	    IN_DEV_FORWARD(in_dev)) {
@@ -895,7 +895,7 @@
 			       NIPQUAD(mask), dev->name, NIPQUAD(rt->rt_src));
 		}
 	}
-	read_unlock(&in_dev->lock);
+	rcu_read_unlock();
 	in_dev_put(in_dev);
 out:;
 }
diff -Nru a/net/ipv4/igmp.c b/net/ipv4/igmp.c
--- a/net/ipv4/igmp.c	2004-08-12 16:42:31 -07:00
+++ b/net/ipv4/igmp.c	2004-08-12 16:42:31 -07:00
@@ -487,7 +487,7 @@
 	int type;
 
 	if (!pmc) {
-		read_lock(&in_dev->lock);
+		read_lock(&in_dev->mc_list_lock);
 		for (pmc=in_dev->mc_list; pmc; pmc=pmc->next) {
 			if (pmc->multiaddr == IGMP_ALL_HOSTS)
 				continue;
@@ -499,7 +499,7 @@
 			skb = add_grec(skb, pmc, type, 0, 0);
 			spin_unlock_bh(&pmc->lock);
 		}
-		read_unlock(&in_dev->lock);
+		read_unlock(&in_dev->mc_list_lock);
 	} else {
 		spin_lock_bh(&pmc->lock);
 		if (pmc->sfcount[MCAST_EXCLUDE])
@@ -541,8 +541,8 @@
 	struct sk_buff *skb = NULL;
 	int type, dtype;
 
-	read_lock(&in_dev->lock);
-	write_lock_bh(&in_dev->mc_lock);
+	read_lock(&in_dev->mc_list_lock);
+	spin_lock_bh(&in_dev->mc_tomb_lock);
 
 	/* deleted MCA's */
 	pmc_prev = NULL;
@@ -575,7 +575,7 @@
 		} else
 			pmc_prev = pmc;
 	}
-	write_unlock_bh(&in_dev->mc_lock);
+	spin_unlock_bh(&in_dev->mc_tomb_lock);
 
 	/* change recs */
 	for (pmc=in_dev->mc_list; pmc; pmc=pmc->next) {
@@ -601,7 +601,8 @@
 		}
 		spin_unlock_bh(&pmc->lock);
 	}
-	read_unlock(&in_dev->lock);
+	read_unlock(&in_dev->mc_list_lock);
+
 	if (!skb)
 		return;
 	(void) igmpv3_sendpack(skb);
@@ -759,14 +760,14 @@
 	if (group == IGMP_ALL_HOSTS)
 		return;
 
-	read_lock(&in_dev->lock);
+	read_lock(&in_dev->mc_list_lock);
 	for (im=in_dev->mc_list; im!=NULL; im=im->next) {
 		if (im->multiaddr == group) {
 			igmp_stop_timer(im);
 			break;
 		}
 	}
-	read_unlock(&in_dev->lock);
+	read_unlock(&in_dev->mc_list_lock);
 }
 
 static void igmp_heard_query(struct in_device *in_dev, struct sk_buff *skb,
@@ -840,7 +841,7 @@
 	 * - Use the igmp->igmp_code field as the maximum
 	 *   delay possible
 	 */
-	read_lock(&in_dev->lock);
+	read_lock(&in_dev->mc_list_lock);
 	for (im=in_dev->mc_list; im!=NULL; im=im->next) {
 		if (group && group != im->multiaddr)
 			continue;
@@ -856,7 +857,7 @@
 		spin_unlock_bh(&im->lock);
 		igmp_mod_timer(im, max_delay);
 	}
-	read_unlock(&in_dev->lock);
+	read_unlock(&in_dev->mc_list_lock);
 }
 
 int igmp_rcv(struct sk_buff *skb)
@@ -982,10 +983,10 @@
 	}
 	spin_unlock_bh(&im->lock);
 
-	write_lock_bh(&in_dev->mc_lock);
+	spin_lock_bh(&in_dev->mc_tomb_lock);
 	pmc->next = in_dev->mc_tomb;
 	in_dev->mc_tomb = pmc;
-	write_unlock_bh(&in_dev->mc_lock);
+	spin_unlock_bh(&in_dev->mc_tomb_lock);
 }
 
 static void igmpv3_del_delrec(struct in_device *in_dev, __u32 multiaddr)
@@ -993,7 +994,7 @@
 	struct ip_mc_list *pmc, *pmc_prev;
 	struct ip_sf_list *psf, *psf_next;
 
-	write_lock_bh(&in_dev->mc_lock);
+	spin_lock_bh(&in_dev->mc_tomb_lock);
 	pmc_prev = NULL;
 	for (pmc=in_dev->mc_tomb; pmc; pmc=pmc->next) {
 		if (pmc->multiaddr == multiaddr)
@@ -1006,7 +1007,7 @@
 		else
 			in_dev->mc_tomb = pmc->next;
 	}
-	write_unlock_bh(&in_dev->mc_lock);
+	spin_unlock_bh(&in_dev->mc_tomb_lock);
 	if (pmc) {
 		for (psf=pmc->tomb; psf; psf=psf_next) {
 			psf_next = psf->sf_next;
@@ -1021,10 +1022,10 @@
 {
 	struct ip_mc_list *pmc, *nextpmc;
 
-	write_lock_bh(&in_dev->mc_lock);
+	spin_lock_bh(&in_dev->mc_tomb_lock);
 	pmc = in_dev->mc_tomb;
 	in_dev->mc_tomb = NULL;
-	write_unlock_bh(&in_dev->mc_lock);
+	spin_unlock_bh(&in_dev->mc_tomb_lock);
 
 	for (; pmc; pmc = nextpmc) {
 		nextpmc = pmc->next;
@@ -1033,7 +1034,7 @@
 		kfree(pmc);
 	}
 	/* clear dead sources, too */
-	read_lock(&in_dev->lock);
+	read_lock(&in_dev->mc_list_lock);
 	for (pmc=in_dev->mc_list; pmc; pmc=pmc->next) {
 		struct ip_sf_list *psf, *psf_next;
 
@@ -1046,7 +1047,7 @@
 			kfree(psf);
 		}
 	}
-	read_unlock(&in_dev->lock);
+	read_unlock(&in_dev->mc_list_lock);
 }
 #endif
 
@@ -1167,10 +1168,10 @@
 	im->gsquery = 0;
 #endif
 	im->loaded = 0;
-	write_lock_bh(&in_dev->lock);
+	write_lock_bh(&in_dev->mc_list_lock);
 	im->next=in_dev->mc_list;
 	in_dev->mc_list=im;
-	write_unlock_bh(&in_dev->lock);
+	write_unlock_bh(&in_dev->mc_list_lock);
 #ifdef CONFIG_IP_MULTICAST
 	igmpv3_del_delrec(in_dev, im->multiaddr);
 #endif
@@ -1194,9 +1195,9 @@
 	for (ip=&in_dev->mc_list; (i=*ip)!=NULL; ip=&i->next) {
 		if (i->multiaddr==addr) {
 			if (--i->users == 0) {
-				write_lock_bh(&in_dev->lock);
+				write_lock_bh(&in_dev->mc_list_lock);
 				*ip = i->next;
-				write_unlock_bh(&in_dev->lock);
+				write_unlock_bh(&in_dev->mc_list_lock);
 				igmp_group_dropped(i);
 
 				if (!in_dev->dead)
@@ -1251,7 +1252,8 @@
 	in_dev->mr_qrv = IGMP_Unsolicited_Report_Count;
 #endif
 
-	in_dev->mc_lock = RW_LOCK_UNLOCKED;
+	in_dev->mc_list_lock = RW_LOCK_UNLOCKED;
+	in_dev->mc_tomb_lock = SPIN_LOCK_UNLOCKED;
 }
 
 /* Device going up */
@@ -1281,17 +1283,17 @@
 	/* Deactivate timers */
 	ip_mc_down(in_dev);
 
-	write_lock_bh(&in_dev->lock);
+	write_lock_bh(&in_dev->mc_list_lock);
 	while ((i = in_dev->mc_list) != NULL) {
 		in_dev->mc_list = i->next;
-		write_unlock_bh(&in_dev->lock);
+		write_unlock_bh(&in_dev->mc_list_lock);
 
 		igmp_group_dropped(i);
 		ip_ma_put(i);
 
-		write_lock_bh(&in_dev->lock);
+		write_lock_bh(&in_dev->mc_list_lock);
 	}
-	write_unlock_bh(&in_dev->lock);
+	write_unlock_bh(&in_dev->mc_list_lock);
 }
 
 static struct in_device * ip_mc_find_dev(struct ip_mreqn *imr)
@@ -1391,18 +1393,18 @@
 
 	if (!in_dev)
 		return -ENODEV;
-	read_lock(&in_dev->lock);
+	read_lock(&in_dev->mc_list_lock);
 	for (pmc=in_dev->mc_list; pmc; pmc=pmc->next) {
 		if (*pmca == pmc->multiaddr)
 			break;
 	}
 	if (!pmc) {
 		/* MCA not found?? bug */
-		read_unlock(&in_dev->lock);
+		read_unlock(&in_dev->mc_list_lock);
 		return -ESRCH;
 	}
 	spin_lock_bh(&pmc->lock);
-	read_unlock(&in_dev->lock);
+	read_unlock(&in_dev->mc_list_lock);
 #ifdef CONFIG_IP_MULTICAST
 	sf_markstate(pmc);
 #endif
@@ -1527,18 +1529,18 @@
 
 	if (!in_dev)
 		return -ENODEV;
-	read_lock(&in_dev->lock);
+	read_lock(&in_dev->mc_list_lock);
 	for (pmc=in_dev->mc_list; pmc; pmc=pmc->next) {
 		if (*pmca == pmc->multiaddr)
 			break;
 	}
 	if (!pmc) {
 		/* MCA not found?? bug */
-		read_unlock(&in_dev->lock);
+		read_unlock(&in_dev->mc_list_lock);
 		return -ESRCH;
 	}
 	spin_lock_bh(&pmc->lock);
-	read_unlock(&in_dev->lock);
+	read_unlock(&in_dev->mc_list_lock);
 
 #ifdef CONFIG_IP_MULTICAST
 	sf_markstate(pmc);
@@ -2095,7 +2097,7 @@
 	struct ip_sf_list *psf;
 	int rv = 0;
 
-	read_lock(&in_dev->lock);
+	read_lock(&in_dev->mc_list_lock);
 	for (im=in_dev->mc_list; im; im=im->next) {
 		if (im->multiaddr == mc_addr)
 			break;
@@ -2117,7 +2119,7 @@
 		} else
 			rv = 1; /* unspecified source; tentatively allow */
 	}
-	read_unlock(&in_dev->lock);
+	read_unlock(&in_dev->mc_list_lock);
 	return rv;
 }
 
@@ -2141,13 +2143,13 @@
 		in_dev = in_dev_get(state->dev);
 		if (!in_dev)
 			continue;
-		read_lock(&in_dev->lock);
+		read_lock(&in_dev->mc_list_lock);
 		im = in_dev->mc_list;
 		if (im) {
 			state->in_dev = in_dev;
 			break;
 		}
-		read_unlock(&in_dev->lock);
+		read_unlock(&in_dev->mc_list_lock);
 		in_dev_put(in_dev);
 	}
 	return im;
@@ -2159,7 +2161,7 @@
 	im = im->next;
 	while (!im) {
 		if (likely(state->in_dev != NULL)) {
-			read_unlock(&state->in_dev->lock);
+			read_unlock(&state->in_dev->mc_list_lock);
 			in_dev_put(state->in_dev);
 		}
 		state->dev = state->dev->next;
@@ -2170,7 +2172,7 @@
 		state->in_dev = in_dev_get(state->dev);
 		if (!state->in_dev)
 			continue;
-		read_lock(&state->in_dev->lock);
+		read_lock(&state->in_dev->mc_list_lock);
 		im = state->in_dev->mc_list;
 	}
 	return im;
@@ -2206,7 +2208,7 @@
 {
 	struct igmp_mc_iter_state *state = igmp_mc_seq_private(seq);
 	if (likely(state->in_dev != NULL)) {
-		read_unlock(&state->in_dev->lock);
+		read_unlock(&state->in_dev->mc_list_lock);
 		in_dev_put(state->in_dev);
 		state->in_dev = NULL;
 	}
@@ -2304,7 +2306,7 @@
 		idev = in_dev_get(state->dev);
 		if (unlikely(idev == NULL))
 			continue;
-		read_lock_bh(&idev->lock);
+		read_lock(&idev->mc_list_lock);
 		im = idev->mc_list;
 		if (likely(im != NULL)) {
 			spin_lock_bh(&im->lock);
@@ -2316,7 +2318,7 @@
 			}
 			spin_unlock_bh(&im->lock);
 		}
-		read_unlock_bh(&idev->lock);
+		read_unlock(&idev->mc_list_lock);
 		in_dev_put(idev);
 	}
 	return psf;
@@ -2332,7 +2334,7 @@
 		state->im = state->im->next;
 		while (!state->im) {
 			if (likely(state->idev != NULL)) {
-				read_unlock_bh(&state->idev->lock);
+				read_unlock(&state->idev->mc_list_lock);
 				in_dev_put(state->idev);
 			}
 			state->dev = state->dev->next;
@@ -2343,7 +2345,7 @@
 			state->idev = in_dev_get(state->dev);
 			if (!state->idev)
 				continue;
-			read_lock_bh(&state->idev->lock);
+			read_lock(&state->idev->mc_list_lock);
 			state->im = state->idev->mc_list;
 		}
 		if (!state->im)
@@ -2389,7 +2391,7 @@
 		state->im = NULL;
 	}
 	if (likely(state->idev != NULL)) {
-		read_unlock_bh(&state->idev->lock);
+		read_unlock(&state->idev->mc_list_lock);
 		in_dev_put(state->idev);
 		state->idev = NULL;
 	}
diff -Nru a/net/ipv4/route.c b/net/ipv4/route.c
--- a/net/ipv4/route.c	2004-08-12 16:42:31 -07:00
+++ b/net/ipv4/route.c	2004-08-12 16:42:31 -07:00
@@ -1855,7 +1855,7 @@
 	if (MULTICAST(daddr)) {
 		struct in_device *in_dev;
 
-		read_lock(&inetdev_lock);
+		rcu_read_lock();
 		if ((in_dev = __in_dev_get(dev)) != NULL) {
 			int our = ip_check_mc(in_dev, daddr, saddr,
 				skb->nh.iph->protocol);
@@ -1864,12 +1864,12 @@
 			    || (!LOCAL_MCAST(daddr) && IN_DEV_MFORWARD(in_dev))
 #endif
 			    ) {
-				read_unlock(&inetdev_lock);
+				rcu_read_unlock();
 				return ip_route_input_mc(skb, daddr, saddr,
 							 tos, dev, our);
 			}
 		}
-		read_unlock(&inetdev_lock);
+		rcu_read_unlock();
 		return -EINVAL;
 	}
 	return ip_route_input_slow(skb, daddr, saddr, tos, dev);
diff -Nru a/net/irda/irlan/irlan_eth.c b/net/irda/irlan/irlan_eth.c
--- a/net/irda/irlan/irlan_eth.c	2004-08-12 16:42:31 -07:00
+++ b/net/irda/irlan/irlan_eth.c	2004-08-12 16:42:31 -07:00
@@ -306,7 +306,7 @@
 	in_dev = in_dev_get(dev);
 	if (in_dev == NULL)
 		return;
-	read_lock(&in_dev->lock);
+	rcu_read_lock();
 	if (in_dev->ifa_list)
 		
 	arp_send(ARPOP_REQUEST, ETH_P_ARP, 
@@ -314,7 +314,7 @@
 		 dev, 
 		 in_dev->ifa_list->ifa_address,
 		 NULL, dev->dev_addr, NULL);
-	read_unlock(&in_dev->lock);
+	rcu_read_unlock();
 	in_dev_put(in_dev);
 #endif /* CONFIG_INET */
 }
diff -Nru a/net/sctp/protocol.c b/net/sctp/protocol.c
--- a/net/sctp/protocol.c	2004-08-12 16:42:31 -07:00
+++ b/net/sctp/protocol.c	2004-08-12 16:42:31 -07:00
@@ -148,13 +148,12 @@
 	struct in_ifaddr *ifa;
 	struct sctp_sockaddr_entry *addr;
 
-	read_lock(&inetdev_lock);
+	rcu_read_lock();
 	if ((in_dev = __in_dev_get(dev)) == NULL) {
-		read_unlock(&inetdev_lock);
+		rcu_read_unlock();
 		return;
 	}
 
-	read_lock(&in_dev->lock);
 	for (ifa = in_dev->ifa_list; ifa; ifa = ifa->ifa_next) {
 		/* Add the address to the local list.  */
 		addr = t_new(struct sctp_sockaddr_entry, GFP_ATOMIC);
@@ -166,8 +165,7 @@
 		}
 	}
 
-	read_unlock(&in_dev->lock);
-	read_unlock(&inetdev_lock);
+	rcu_read_unlock();
 }
 
 /* Extract our IP addresses from the system and stash them in the
