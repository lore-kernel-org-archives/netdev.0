From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.5.69] Network packet type using RCU
Date: Fri, 9 May 2003 14:25:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030509142538.548cbd71.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert network packet type list from using brlock to RCU based list.
Some collataral changes to af_packet were necessary since it needs to
unregister packet types without sleeping.

Summary:
* packet type converted from linked list to list_macro
* writer lock replaced with spin lock, readers use RCU
* add __dev_remove_pack for callers that can't sleep.
* af_packet changes to handle and sleeping requirements, and possible
  races that could cause.

Tested on 8-way SMP running 2.5.69 latest.

Dave, please wait till Monday to apply this in case there are any
comments.

diff -urNp -X dontdiff linux-2.5/include/linux/netdevice.h linux-2.5-nbr/include/linux/netdevice.h
--- linux-2.5/include/linux/netdevice.h	2003-04-14 13:32:21.000000000 -0700
+++ linux-2.5-nbr/include/linux/netdevice.h	2003-05-02 15:07:06.000000000 -0700
@@ -456,7 +456,7 @@ struct packet_type 
 	int			(*func) (struct sk_buff *, struct net_device *,
 					 struct packet_type *);
 	void			*data;	/* Private to the packet type		*/
-	struct packet_type	*next;
+	struct list_head	list;
 };
 
 
@@ -472,6 +472,7 @@ extern int 			netdev_boot_setup_check(st
 extern struct net_device    *dev_getbyhwaddr(unsigned short type, char *hwaddr);
 extern void		dev_add_pack(struct packet_type *pt);
 extern void		dev_remove_pack(struct packet_type *pt);
+extern void		__dev_remove_pack(struct packet_type *pt);
 extern int		dev_get(const char *name);
 extern struct net_device	*dev_get_by_flags(unsigned short flags,
 						  unsigned short mask);
diff -urNp -X dontdiff linux-2.5/net/core/dev.c linux-2.5-nbr/net/core/dev.c
--- linux-2.5/net/core/dev.c	2003-05-05 09:41:03.000000000 -0700
+++ linux-2.5-nbr/net/core/dev.c	2003-05-05 09:44:36.000000000 -0700
@@ -90,7 +90,6 @@
 #include <linux/etherdevice.h>
 #include <linux/notifier.h>
 #include <linux/skbuff.h>
-#include <linux/brlock.h>
 #include <net/sock.h>
 #include <linux/rtnetlink.h>
 #include <linux/proc_fs.h>
@@ -170,8 +169,9 @@ const char *if_port_text[] = {
  *		86DD	IPv6
  */
 
-static struct packet_type *ptype_base[16];	/* 16 way hashed list */
-static struct packet_type *ptype_all;		/* Taps */
+static spinlock_t ptype_lock = SPIN_LOCK_UNLOCKED;
+static struct list_head ptype_base[16];	/* 16 way hashed list */
+static struct list_head ptype_all;		/* Taps */
 
 #ifdef OFFLINE_SAMPLE
 static void sample_queue(unsigned long dummy);
@@ -239,14 +239,17 @@ int netdev_nit;
  *	Add a protocol handler to the networking stack. The passed &packet_type
  *	is linked into kernel lists and may not be freed until it has been
  *	removed from the kernel lists.
+ *
+ *	This call does not sleep therefore it can not 
+ *	guarantee all CPU's that are in middle of receiving packets
+ *	will see the new packet type (until the next received packet).
  */
 
 void dev_add_pack(struct packet_type *pt)
 {
 	int hash;
 
-	br_write_lock_bh(BR_NETPROTO_LOCK);
-
+	spin_lock_bh(&ptype_lock);
 #ifdef CONFIG_NET_FASTROUTE
 	/* Hack to detect packet socket */
 	if (pt->data && (long)(pt->data) != 1) {
@@ -256,52 +259,76 @@ void dev_add_pack(struct packet_type *pt
 #endif
 	if (pt->type == htons(ETH_P_ALL)) {
 		netdev_nit++;
-		pt->next  = ptype_all;
-		ptype_all = pt;
+		list_add_rcu(&pt->list, &ptype_all);
 	} else {
 		hash = ntohs(pt->type) & 15;
-		pt->next = ptype_base[hash];
-		ptype_base[hash] = pt;
+		list_add_rcu(&pt->list, &ptype_base[hash]);
 	}
-	br_write_unlock_bh(BR_NETPROTO_LOCK);
+	spin_unlock_bh(&ptype_lock);
 }
 
 extern void linkwatch_run_queue(void);
 
+
+
 /**
- *	dev_remove_pack	 - remove packet handler
+ *	__dev_remove_pack	 - remove packet handler
  *	@pt: packet type declaration
  *
  *	Remove a protocol handler that was previously added to the kernel
  *	protocol handlers by dev_add_pack(). The passed &packet_type is removed
  *	from the kernel lists and can be freed or reused once this function
- *	returns.
+ *	returns. 
+ *
+ *      The packet type might still be in use by receivers
+ *	and must not be freed until after all the CPU's have gone
+ *	through a quiescent state.
  */
-void dev_remove_pack(struct packet_type *pt)
+void __dev_remove_pack(struct packet_type *pt)
 {
-	struct packet_type **pt1;
+	struct list_head *head;
+	struct packet_type *pt1;
 
-	br_write_lock_bh(BR_NETPROTO_LOCK);
+	spin_lock_bh(&ptype_lock);
 
 	if (pt->type == htons(ETH_P_ALL)) {
 		netdev_nit--;
-		pt1 = &ptype_all;
+		head = &ptype_all;
 	} else
-		pt1 = &ptype_base[ntohs(pt->type) & 15];
+		head = &ptype_base[ntohs(pt->type) & 15];
 
-	for (; *pt1; pt1 = &((*pt1)->next)) {
-		if (pt == *pt1) {
-			*pt1 = pt->next;
+	list_for_each_entry(pt1, head, list) {
+		if (pt == pt1) {
 #ifdef CONFIG_NET_FASTROUTE
 			if (pt->data)
 				netdev_fastroute_obstacles--;
 #endif
+			list_del_rcu(&pt->list);
 			goto out;
 		}
 	}
+
 	printk(KERN_WARNING "dev_remove_pack: %p not found.\n", pt);
 out:
-	br_write_unlock_bh(BR_NETPROTO_LOCK);
+	spin_unlock_bh(&ptype_lock);
+}
+/**
+ *	dev_remove_pack	 - remove packet handler
+ *	@pt: packet type declaration
+ *
+ *	Remove a protocol handler that was previously added to the kernel
+ *	protocol handlers by dev_add_pack(). The passed &packet_type is removed
+ *	from the kernel lists and can be freed or reused once this function
+ *	returns.
+ *
+ *	This call sleeps to guarantee that no CPU is looking at the packet
+ *	type after return.
+ */
+void dev_remove_pack(struct packet_type *pt)
+{
+	__dev_remove_pack(pt);
+	
+	synchronize_net();
 }
 
 /******************************************************************************
@@ -943,8 +970,8 @@ void dev_queue_xmit_nit(struct sk_buff *
 	struct packet_type *ptype;
 	do_gettimeofday(&skb->stamp);
 
-	br_read_lock(BR_NETPROTO_LOCK);
-	for (ptype = ptype_all; ptype; ptype = ptype->next) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(ptype, &ptype_all, list) {
 		/* Never send packets back to the socket
 		 * they originated from - MvS (miquels@drinkel.ow.org)
 		 */
@@ -974,7 +1001,7 @@ void dev_queue_xmit_nit(struct sk_buff *
 			ptype->func(skb2, skb->dev, ptype);
 		}
 	}
-	br_read_unlock(BR_NETPROTO_LOCK);
+	rcu_read_unlock();
 }
 
 /* Calculate csum in the case, when packet is misrouted.
@@ -1488,7 +1515,8 @@ int netif_receive_skb(struct sk_buff *sk
 	skb->h.raw = skb->nh.raw = skb->data;
 
 	pt_prev = NULL;
-	for (ptype = ptype_all; ptype; ptype = ptype->next) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(ptype, &ptype_all, list) {
 		if (!ptype->dev || ptype->dev == skb->dev) {
 			if (pt_prev) {
 				if (!pt_prev->data) {
@@ -1511,17 +1539,15 @@ int netif_receive_skb(struct sk_buff *sk
 
 #if defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE)
 	if (skb->dev->br_port) {
-		int ret;
-
 		ret = handle_bridge(skb, pt_prev);
 		if (br_handle_frame_hook(skb) == 0) 
-			return ret;
+			goto out;
 
 		pt_prev = NULL;
 	}
 #endif
 
-	for (ptype = ptype_base[ntohs(type) & 15]; ptype; ptype = ptype->next) {
+	list_for_each_entry_rcu(ptype, &ptype_base[ntohs(type)&15], list) {
 		if (ptype->type == type &&
 		    (!ptype->dev || ptype->dev == skb->dev)) {
 			if (pt_prev) {
@@ -1552,6 +1578,8 @@ int netif_receive_skb(struct sk_buff *sk
 		ret = NET_RX_DROP;
 	}
 
+ out:
+	rcu_read_unlock();
 	return ret;
 }
 
@@ -1625,7 +1653,8 @@ static void net_rx_action(struct softirq
 	unsigned long start_time = jiffies;
 	int budget = netdev_max_backlog;
 
-	br_read_lock(BR_NETPROTO_LOCK);
+	
+	preempt_disable();
 	local_irq_disable();
 
 	while (!list_empty(&queue->poll_list)) {
@@ -1654,7 +1683,7 @@ static void net_rx_action(struct softirq
 	}
 out:
 	local_irq_enable();
-	br_read_unlock(BR_NETPROTO_LOCK);
+	preempt_enable();
 	return;
 
 softnet_break:
@@ -1995,9 +2024,9 @@ int netdev_set_master(struct net_device 
 		dev_hold(master);
 	}
 
-	br_write_lock_bh(BR_NETPROTO_LOCK);
 	slave->master = master;
-	br_write_unlock_bh(BR_NETPROTO_LOCK);
+	
+	synchronize_net();
 
 	if (old)
 		dev_put(old);
@@ -2661,8 +2690,8 @@ int netdev_finish_unregister(struct net_
 /* Synchronize with packet receive processing. */
 void synchronize_net(void) 
 {
-	br_write_lock_bh(BR_NETPROTO_LOCK);
-	br_write_unlock_bh(BR_NETPROTO_LOCK);
+	might_sleep();
+	synchronize_kernel();
 }
 
 /**
@@ -2846,6 +2875,10 @@ static int __init net_dev_init(void)
 
 	subsystem_register(&net_subsys);
 
+	INIT_LIST_HEAD(&ptype_all);
+	for (i = 0; i < 16; i++) 
+		INIT_LIST_HEAD(&ptype_base[i]);
+
 #ifdef CONFIG_NET_DIVERT
 	dv_init();
 #endif /* CONFIG_NET_DIVERT */
diff -urNp -X dontdiff linux-2.5/net/netsyms.c linux-2.5-nbr/net/netsyms.c
--- linux-2.5/net/netsyms.c	2003-05-05 09:41:03.000000000 -0700
+++ linux-2.5-nbr/net/netsyms.c	2003-05-05 09:44:36.000000000 -0700
@@ -577,6 +577,7 @@ EXPORT_SYMBOL(netif_rx);
 EXPORT_SYMBOL(netif_receive_skb);
 EXPORT_SYMBOL(dev_add_pack);
 EXPORT_SYMBOL(dev_remove_pack);
+EXPORT_SYMBOL(__dev_remove_pack);
 EXPORT_SYMBOL(dev_get);
 EXPORT_SYMBOL(dev_alloc);
 EXPORT_SYMBOL(dev_alloc_name);
diff -urNp -X dontdiff linux-2.5/net/packet/af_packet.c linux-2.5-nbr/net/packet/af_packet.c
--- linux-2.5/net/packet/af_packet.c	2003-05-05 09:41:03.000000000 -0700
+++ linux-2.5-nbr/net/packet/af_packet.c	2003-05-05 11:14:52.000000000 -0700
@@ -774,6 +774,7 @@ static int packet_release(struct socket 
 		 */
 		dev_remove_pack(&po->prot_hook);
 		po->running = 0;
+		po->num = 0;
 		__sock_put(sk);
 	}
 
@@ -819,9 +820,12 @@ static int packet_do_bind(struct sock *s
 
 	spin_lock(&po->bind_lock);
 	if (po->running) {
-		dev_remove_pack(&po->prot_hook);
 		__sock_put(sk);
 		po->running = 0;
+		po->num = 0;
+		spin_unlock(&po->bind_lock);
+		dev_remove_pack(&po->prot_hook);
+		spin_lock(&po->bind_lock);
 	}
 
 	po->num = protocol;
@@ -1374,7 +1378,7 @@ static int packet_notifier(struct notifi
 			if (dev->ifindex == po->ifindex) {
 				spin_lock(&po->bind_lock);
 				if (po->running) {
-					dev_remove_pack(&po->prot_hook);
+					__dev_remove_pack(&po->prot_hook);
 					__sock_put(sk);
 					po->running = 0;
 					sk->err = ENETDOWN;
@@ -1618,9 +1622,14 @@ static int packet_set_ring(struct sock *
 
 	/* Detach socket from network */
 	spin_lock(&po->bind_lock);
-	if (po->running)
-		dev_remove_pack(&po->prot_hook);
+	if (po->running) {
+		__dev_remove_pack(&po->prot_hook);
+		po->num = 0;
+		po->running = 0;
+	}
 	spin_unlock(&po->bind_lock);
+		
+	synchronize_net();
 
 	err = -EBUSY;
 	if (closing || atomic_read(&po->mapped) == 0) {
