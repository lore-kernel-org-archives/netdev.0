From: Ben Greear <greearb@candelatech.com>
Subject: [PATCH]  pktgen (1.6,-ben)
Date: Tue, 17 Sep 2002 23:40:13 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D881FCD.4040209@candelatech.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030304010606000406080300"
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030304010606000406080300
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Here is an update of my pktgen patch.  This patch is against 2.4.20-pre7.
(I say my, because it is significantly different from the one in the kernel,
and should not be confused with Robert's more official patches, Robert
still gets primary credit for the idea and original code!)

It provides traffic generation and reception features, including latency,
out-of-order & dropped packet counters, and much more.  This particular patch
fixes a divide-by-zero bug in earlier patches I produced (only seen on machines
running at less than 1Ghz).

If anyone has an Intel GigE card or two, I would be interested if it could
sustain pktgen (or other high speed) traffic for more than 6 hours.  My machine
crashes everytime!

Enjoy,
Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear


--------------030304010606000406080300
Content-Type: text/plain;
 name="pg_2.4.19.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="pg_2.4.19.patch"

--- linux-2.4.19/include/linux/if.h	Thu Nov 22 12:47:07 2001
+++ linux-2.4.19.dev/include/linux/if.h	Sun Sep 15 21:56:34 2002
@@ -47,6 +47,12 @@
 
 /* Private (from user) interface flags (netdevice->priv_flags). */
 #define IFF_802_1Q_VLAN 0x1             /* 802.1Q VLAN device.          */
+#define IFF_PKTGEN_RCV  0x2             /* Registered to receive & consume  Pktgen skbs */
+#define IFF_ACCEPT_LOCAL_ADDRS 0x4      /**  Accept pkts even if they come from a local
+                                         * address.  This lets use send pkts to ourselves
+                                         * over external interfaces (when used in conjunction
+                                         * with SO_BINDTODEVICE
+                                         */
 
 /*
  *	Device mapping structure. I'd just gone off and designed a 
--- linux-2.4.19/include/linux/netdevice.h	Fri Aug  2 17:39:45 2002
+++ linux-2.4.19.dev/include/linux/netdevice.h	Sun Sep 15 21:56:35 2002
@@ -162,7 +162,7 @@
 	unsigned fastroute_deferred_out;
 	unsigned fastroute_latency_reduction;
 	unsigned cpu_collision;
-} __attribute__ ((__aligned__(SMP_CACHE_BYTES)));
+} ____cacheline_aligned;
 
 extern struct netif_rx_stats netdev_rx_stat[];
 
@@ -206,7 +206,8 @@
 	__LINK_STATE_START,
 	__LINK_STATE_PRESENT,
 	__LINK_STATE_SCHED,
-	__LINK_STATE_NOCARRIER
+	__LINK_STATE_NOCARRIER,
+	__LINK_STATE_RX_SCHED
 };
 
 
@@ -295,7 +296,9 @@
 
 	unsigned short		flags;	/* interface flags (a la BSD)	*/
 	unsigned short		gflags;
-        unsigned short          priv_flags; /* Like 'flags' but invisible to userspace. */
+        unsigned short          priv_flags; /* Like 'flags' but invisible to userspace,
+                                             * see: if.h for flag definitions.
+                                             */
         unsigned short          unused_alignment_fixer; /* Because we need priv_flags,
                                                          * and we want to be 32-bit aligned.
                                                          */
@@ -330,6 +333,10 @@
 	void                    *ip6_ptr;       /* IPv6 specific data */
 	void			*ec_ptr;	/* Econet specific data	*/
 
+	struct list_head	poll_list;	/* Link to poll list	*/
+	int			quota;
+	int			weight;
+
 	struct Qdisc		*qdisc;
 	struct Qdisc		*qdisc_sleeping;
 	struct Qdisc		*qdisc_list;
@@ -373,6 +380,8 @@
 	int			(*stop)(struct net_device *dev);
 	int			(*hard_start_xmit) (struct sk_buff *skb,
 						    struct net_device *dev);
+#define HAVE_NETDEV_POLL
+	int			(*poll) (struct net_device *dev, int *quota);
 	int			(*hard_header) (struct sk_buff *skb,
 						struct net_device *dev,
 						unsigned short type,
@@ -431,6 +440,7 @@
 	/* this will get initialized at each interface type init routine */
 	struct divert_blk	*divert;
 #endif /* CONFIG_NET_DIVERT */
+
 };
 
 
@@ -492,9 +502,12 @@
 	int			cng_level;
 	int			avg_blog;
 	struct sk_buff_head	input_pkt_queue;
+	struct list_head	poll_list;
 	struct net_device	*output_queue;
 	struct sk_buff		*completion_queue;
-} __attribute__((__aligned__(SMP_CACHE_BYTES)));
+
+	struct net_device	blog_dev;	/* Sorry. 8) */
+} ____cacheline_aligned;
 
 
 extern struct softnet_data softnet_data[NR_CPUS];
@@ -547,6 +560,7 @@
 	return test_bit(__LINK_STATE_START, &dev->state);
 }
 
+
 /* Use this variant when it is known for sure that it
  * is executing from interrupt context.
  */
@@ -578,6 +592,8 @@
 extern void		net_call_rx_atomic(void (*fn)(void));
 #define HAVE_NETIF_RX 1
 extern int		netif_rx(struct sk_buff *skb);
+#define HAVE_NETIF_RECEIVE_SKB 1
+extern int		netif_receive_skb(struct sk_buff *skb);
 extern int		dev_ioctl(unsigned int cmd, void *);
 extern int		dev_change_flags(struct net_device *, unsigned);
 extern void		dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev);
@@ -699,6 +715,78 @@
 #define netif_msg_hw(p)		((p)->msg_enable & NETIF_MSG_HW)
 #define netif_msg_wol(p)	((p)->msg_enable & NETIF_MSG_WOL)
 
+/* Schedule rx intr now? */
+
+static inline int netif_rx_schedule_prep(struct net_device *dev)
+{
+	return netif_running(dev) &&
+		!test_and_set_bit(__LINK_STATE_RX_SCHED, &dev->state);
+}
+
+/* Add interface to tail of rx poll list. This assumes that _prep has
+ * already been called and returned 1.
+ */
+
+static inline void __netif_rx_schedule(struct net_device *dev)
+{
+	unsigned long flags;
+	int cpu = smp_processor_id();
+
+	local_irq_save(flags);
+	dev_hold(dev);
+	list_add_tail(&dev->poll_list, &softnet_data[cpu].poll_list);
+	if (dev->quota < 0)
+		dev->quota += dev->weight;
+	else
+		dev->quota = dev->weight;
+	__cpu_raise_softirq(cpu, NET_RX_SOFTIRQ);
+	local_irq_restore(flags);
+}
+
+/* Try to reschedule poll. Called by irq handler. */
+
+static inline void netif_rx_schedule(struct net_device *dev)
+{
+	if (netif_rx_schedule_prep(dev))
+		__netif_rx_schedule(dev);
+}
+
+/* Try to reschedule poll. Called by dev->poll() after netif_rx_complete().
+ * Do not inline this?
+ */
+static inline int netif_rx_reschedule(struct net_device *dev, int undo)
+{
+	if (netif_rx_schedule_prep(dev)) {
+		unsigned long flags;
+		int cpu = smp_processor_id();
+
+		dev->quota += undo;
+
+		local_irq_save(flags);
+		list_add_tail(&dev->poll_list, &softnet_data[cpu].poll_list);
+		__cpu_raise_softirq(cpu, NET_RX_SOFTIRQ);
+		local_irq_restore(flags);
+		return 1;
+	}
+	return 0;
+}
+
+/* Remove interface from poll list: it must be in the poll list
+ * on current cpu. This primitive is called by dev->poll(), when
+ * it completes the work. The device cannot be out of poll list at this
+ * moment, it is BUG().
+ */
+static inline void netif_rx_complete(struct net_device *dev)
+{
+	unsigned long flags;
+
+	local_irq_save(flags);
+	if (!test_bit(__LINK_STATE_RX_SCHED, &dev->state)) BUG();
+	list_del(&dev->poll_list);
+	clear_bit(__LINK_STATE_RX_SCHED, &dev->state);
+	local_irq_restore(flags);
+}
+
 /* These functions live elsewhere (drivers/net/net_init.c, but related) */
 
 extern void		ether_setup(struct net_device *dev);
@@ -723,6 +811,7 @@
 extern int		netdev_register_fc(struct net_device *dev, void (*stimul)(struct net_device *dev));
 extern void		netdev_unregister_fc(int bit);
 extern int		netdev_max_backlog;
+extern int		weight_p;
 extern unsigned long	netdev_fc_xoff;
 extern atomic_t netdev_dropping;
 extern int		netdev_set_master(struct net_device *dev, struct net_device *master);
--- linux-2.4.19/net/core/dev.c	Fri Aug  2 17:39:46 2002
+++ linux-2.4.19.dev/net/core/dev.c	Sun Sep 15 21:34:11 2002
@@ -1,4 +1,4 @@
-/*
+/* -*-linux-c-*-
  * 	NET3	Protocol independent device support routines.
  *
  *		This program is free software; you can redistribute it and/or
@@ -109,6 +109,11 @@
 #endif
 
 
+#if defined(CONFIG_NET_PKTGEN) || defined(CONFIG_NET_PKTGEN_MODULE)
+#include "pktgen.h"
+#endif
+
+
 /* This define, if set, will randomly drop a packet when congestion
  * is more than moderate.  It helps fairness in the multi-interface
  * case when one of them is a hog, but it kills performance for the
@@ -798,6 +803,19 @@
 
 	clear_bit(__LINK_STATE_START, &dev->state);
 
+	/* Synchronize to scheduled poll. We cannot touch poll list,
+	 * it can be even on different cpu. So just clear netif_running(),
+	 * and wait when poll really will happen. Actually, the best place
+	 * for this is inside dev->stop() after device stopped its irq
+	 * engine, but this requires more changes in devices. */
+
+	smp_mb__after_clear_bit(); /* Commit netif_running(). */
+	while (test_bit(__LINK_STATE_RX_SCHED, &dev->state)) {
+		/* No hurry. */
+		current->state = TASK_INTERRUPTIBLE;
+		schedule_timeout(1);
+	}
+
 	/*
 	 *	Call the device specific close. This cannot fail.
 	 *	Only if device is UP
@@ -1072,6 +1090,7 @@
   =======================================================================*/
 
 int netdev_max_backlog = 300;
+int weight_p = 64;            /* old backlog weight */
 /* These numbers are selected based on intuition and some
  * experimentatiom, if you have more scientific way of doing this
  * please go ahead and fix things.
@@ -1237,13 +1256,11 @@
 enqueue:
 			dev_hold(skb->dev);
 			__skb_queue_tail(&queue->input_pkt_queue,skb);
-			/* Runs from irqs or BH's, no need to wake BH */
-			cpu_raise_softirq(this_cpu, NET_RX_SOFTIRQ);
 			local_irq_restore(flags);
 #ifndef OFFLINE_SAMPLE
 			get_sample_stats(this_cpu);
 #endif
-			return softnet_data[this_cpu].cng_level;
+			return queue->cng_level;
 		}
 
 		if (queue->throttle) {
@@ -1253,6 +1270,8 @@
 				netdev_wakeup();
 #endif
 		}
+
+		netif_rx_schedule(&queue->blog_dev);
 		goto enqueue;
 	}
 
@@ -1308,19 +1327,12 @@
 	return ret;
 }
 
-/* Reparent skb to master device. This function is called
- * only from net_rx_action under BR_NETPROTO_LOCK. It is misuse
- * of BR_NETPROTO_LOCK, but it is OK for now.
- */
 static __inline__ void skb_bond(struct sk_buff *skb)
 {
 	struct net_device *dev = skb->dev;
-	
-	if (dev->master) {
-		dev_hold(dev->master);
+
+	if (dev->master)
 		skb->dev = dev->master;
-		dev_put(dev);
-	}
 }
 
 static void net_tx_action(struct softirq_action *h)
@@ -1384,6 +1396,19 @@
 	br_write_unlock_bh(BR_NETPROTO_LOCK);
 }
 
+#if defined(CONFIG_NET_PKTGEN) || defined(CONFIG_NET_PKTGEN_MODULE)
+#warning "Compiling dev.c for pktgen.";
+
+int (*handle_pktgen_hook)(struct sk_buff *skb) = NULL;
+
+static __inline__ int handle_pktgen_rcv(struct sk_buff* skb) {
+        if (handle_pktgen_hook) {
+                return handle_pktgen_hook(skb);
+        }
+        return -1;
+}
+#endif
+
 #if defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE)
 void (*br_handle_frame_hook)(struct sk_buff *skb) = NULL;
 #endif
@@ -1408,129 +1433,159 @@
 
 
 #ifdef CONFIG_NET_DIVERT
-static inline void handle_diverter(struct sk_buff *skb)
+static inline int handle_diverter(struct sk_buff *skb)
 {
 	/* if diversion is supported on device, then divert */
 	if (skb->dev->divert && skb->dev->divert->divert)
 		divert_frame(skb);
+	return 0;
 }
 #endif   /* CONFIG_NET_DIVERT */
 
-
-static void net_rx_action(struct softirq_action *h)
+int netif_receive_skb(struct sk_buff *skb)
 {
-	int this_cpu = smp_processor_id();
-	struct softnet_data *queue = &softnet_data[this_cpu];
-	unsigned long start_time = jiffies;
-	int bugdet = netdev_max_backlog;
-
-	br_read_lock(BR_NETPROTO_LOCK);
-
-	for (;;) {
-		struct sk_buff *skb;
-		struct net_device *rx_dev;
-
-		local_irq_disable();
-		skb = __skb_dequeue(&queue->input_pkt_queue);
-		local_irq_enable();
+	struct packet_type *ptype, *pt_prev;
+	int ret = NET_RX_DROP;
+	unsigned short type = skb->protocol;
 
-		if (skb == NULL)
-			break;
+	if (skb->stamp.tv_sec == 0)
+		do_gettimeofday(&skb->stamp);
 
-		skb_bond(skb);
+	skb_bond(skb);
 
-		rx_dev = skb->dev;
+	netdev_rx_stat[smp_processor_id()].total++;
 
 #ifdef CONFIG_NET_FASTROUTE
-		if (skb->pkt_type == PACKET_FASTROUTE) {
-			netdev_rx_stat[this_cpu].fastroute_deferred_out++;
-			dev_queue_xmit(skb);
-			dev_put(rx_dev);
-			continue;
-		}
+	if (skb->pkt_type == PACKET_FASTROUTE) {
+		netdev_rx_stat[smp_processor_id()].fastroute_deferred_out++;
+		return dev_queue_xmit(skb);
+	}
 #endif
-		skb->h.raw = skb->nh.raw = skb->data;
-		{
-			struct packet_type *ptype, *pt_prev;
-			unsigned short type = skb->protocol;
 
-			pt_prev = NULL;
-			for (ptype = ptype_all; ptype; ptype = ptype->next) {
-				if (!ptype->dev || ptype->dev == skb->dev) {
-					if (pt_prev) {
-						if (!pt_prev->data) {
-							deliver_to_old_ones(pt_prev, skb, 0);
-						} else {
-							atomic_inc(&skb->users);
-							pt_prev->func(skb,
-								      skb->dev,
-								      pt_prev);
-						}
-					}
-					pt_prev = ptype;
+	skb->h.raw = skb->nh.raw = skb->data;
+
+	pt_prev = NULL;
+	for (ptype = ptype_all; ptype; ptype = ptype->next) {
+		if (!ptype->dev || ptype->dev == skb->dev) {
+			if (pt_prev) {
+				if (!pt_prev->data) {
+					ret = deliver_to_old_ones(pt_prev, skb, 0);
+				} else {
+					atomic_inc(&skb->users);
+					ret = pt_prev->func(skb, skb->dev, pt_prev);
 				}
 			}
+			pt_prev = ptype;
+		}
+	}
+
+#if defined(CONFIG_NET_PKTGEN) || defined(CONFIG_NET_PKTGEN_MODULE)
+        if ((skb->dev->priv_flags & IFF_PKTGEN_RCV) &&
+            (handle_pktgen_rcv(skb) >= 0)) {
+                /* Pktgen may consume the packet, no need to send
+                 * to further protocols.
+                 */
+                return 0;
+        }
+#endif
 
+        
 #ifdef CONFIG_NET_DIVERT
-			if (skb->dev->divert && skb->dev->divert->divert)
-				handle_diverter(skb);
+	if (skb->dev->divert && skb->dev->divert->divert)
+		ret = handle_diverter(skb);
 #endif /* CONFIG_NET_DIVERT */
 
-			
+        
 #if defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE)
-			if (skb->dev->br_port != NULL &&
-			    br_handle_frame_hook != NULL) {
-				handle_bridge(skb, pt_prev);
-				dev_put(rx_dev);
-				continue;
-			}
+	if (skb->dev->br_port != NULL &&
+	    br_handle_frame_hook != NULL) {
+		return handle_bridge(skb, pt_prev);
+	}
 #endif
 
-			for (ptype=ptype_base[ntohs(type)&15];ptype;ptype=ptype->next) {
-				if (ptype->type == type &&
-				    (!ptype->dev || ptype->dev == skb->dev)) {
-					if (pt_prev) {
-						if (!pt_prev->data)
-							deliver_to_old_ones(pt_prev, skb, 0);
-						else {
-							atomic_inc(&skb->users);
-							pt_prev->func(skb,
-								      skb->dev,
-								      pt_prev);
-						}
-					}
-					pt_prev = ptype;
+	for (ptype=ptype_base[ntohs(type)&15];ptype;ptype=ptype->next) {
+		if (ptype->type == type &&
+		    (!ptype->dev || ptype->dev == skb->dev)) {
+			if (pt_prev) {
+				if (!pt_prev->data) {
+					ret = deliver_to_old_ones(pt_prev, skb, 0);
+				} else {
+					atomic_inc(&skb->users);
+					ret = pt_prev->func(skb, skb->dev, pt_prev);
 				}
 			}
+			pt_prev = ptype;
+		}
+	}
 
-			if (pt_prev) {
-				if (!pt_prev->data)
-					deliver_to_old_ones(pt_prev, skb, 1);
-				else
-					pt_prev->func(skb, skb->dev, pt_prev);
-			} else
-				kfree_skb(skb);
+	if (pt_prev) {
+		if (!pt_prev->data) {
+			ret = deliver_to_old_ones(pt_prev, skb, 1);
+		} else {
+			ret = pt_prev->func(skb, skb->dev, pt_prev);
 		}
+	} else {
+		kfree_skb(skb);
+		/* Jamal, now you will not able to escape explaining
+		 * me how you were going to use this. :-)
+		 */
+		ret = NET_RX_DROP;
+	}
 
-		dev_put(rx_dev);
+	return ret;
+}
 
-		if (bugdet-- < 0 || jiffies - start_time > 1)
-			goto softnet_break;
+static int process_backlog(struct net_device *blog_dev, int *budget)
+{
+	int work = 0;
+	int quota = min(blog_dev->quota, *budget);
+	int this_cpu = smp_processor_id();
+	struct softnet_data *queue = &softnet_data[this_cpu];
+	unsigned long start_time = jiffies;
+
+	for (;;) {
+		struct sk_buff *skb;
+		struct net_device *dev;
+
+		local_irq_disable();
+		skb = __skb_dequeue(&queue->input_pkt_queue);
+		if (skb == NULL)
+			goto job_done;
+		local_irq_enable();
+
+		dev = skb->dev;
+
+		netif_receive_skb(skb);
+
+		dev_put(dev);
+
+		work++;
+
+		if (work >= quota || jiffies - start_time > 1)
+			break;
 
 #ifdef CONFIG_NET_HW_FLOWCONTROL
-	if (queue->throttle && queue->input_pkt_queue.qlen < no_cong_thresh ) {
-		if (atomic_dec_and_test(&netdev_dropping)) {
-			queue->throttle = 0;
-			netdev_wakeup();
-			goto softnet_break;
+		if (queue->throttle && queue->input_pkt_queue.qlen < no_cong_thresh ) {
+			if (atomic_dec_and_test(&netdev_dropping)) {
+				queue->throttle = 0;
+				netdev_wakeup();
+				break;
+			}
 		}
-	}
 #endif
-
 	}
-	br_read_unlock(BR_NETPROTO_LOCK);
 
-	local_irq_disable();
+	blog_dev->quota -= work;
+	*budget -= work;
+	return -1;
+
+job_done:
+	blog_dev->quota -= work;
+	*budget -= work;
+
+	list_del(&blog_dev->poll_list);
+	clear_bit(__LINK_STATE_RX_SCHED, &blog_dev->state);
+
 	if (queue->throttle) {
 		queue->throttle = 0;
 #ifdef CONFIG_NET_HW_FLOWCONTROL
@@ -1539,21 +1594,53 @@
 #endif
 	}
 	local_irq_enable();
+	return 0;
+}
 
-	NET_PROFILE_LEAVE(softnet_process);
-	return;
+static void net_rx_action(struct softirq_action *h)
+{
+	int this_cpu = smp_processor_id();
+	struct softnet_data *queue = &softnet_data[this_cpu];
+	unsigned long start_time = jiffies;
+	int budget = netdev_max_backlog;
 
-softnet_break:
+	br_read_lock(BR_NETPROTO_LOCK);
+	local_irq_disable();
+
+	while (!list_empty(&queue->poll_list)) {
+		struct net_device *dev;
+
+		if (budget <= 0 || jiffies - start_time > 1)
+			goto softnet_break;
+
+		local_irq_enable();
+
+		dev = list_entry(queue->poll_list.next, struct net_device, poll_list);
+
+		if (dev->quota <= 0 || dev->poll(dev, &budget)) {
+			local_irq_disable();
+			list_del(&dev->poll_list);
+			list_add_tail(&dev->poll_list, &queue->poll_list);
+			if (dev->quota < 0)
+				dev->quota += dev->weight;
+			else
+				dev->quota = dev->weight;
+		} else {
+			dev_put(dev);
+			local_irq_disable();
+		}
+	}
+
+	local_irq_enable();
 	br_read_unlock(BR_NETPROTO_LOCK);
+	return;
 
-	local_irq_disable();
+softnet_break:
 	netdev_rx_stat[this_cpu].time_squeeze++;
-	/* This already runs in BH context, no need to wake up BH's */
-	cpu_raise_softirq(this_cpu, NET_RX_SOFTIRQ);
-	local_irq_enable();
+	__cpu_raise_softirq(this_cpu, NET_RX_SOFTIRQ);
 
-	NET_PROFILE_LEAVE(softnet_process);
-	return;
+	local_irq_enable();
+	br_read_unlock(BR_NETPROTO_LOCK);
 }
 
 static gifconf_func_t * gifconf_list [NPROTO];
@@ -2094,6 +2181,24 @@
 			notifier_call_chain(&netdev_chain, NETDEV_CHANGENAME, dev);
 			return 0;
 
+                case SIOCSACCEPTLOCALADDRS:
+                        if (ifr->ifr_flags) {
+                                dev->priv_flags |= IFF_ACCEPT_LOCAL_ADDRS;
+                        }
+                        else {
+                                dev->priv_flags &= ~IFF_ACCEPT_LOCAL_ADDRS;
+                        }
+                        return 0;
+
+                case SIOCGACCEPTLOCALADDRS:
+                        if (dev->priv_flags & IFF_ACCEPT_LOCAL_ADDRS) {
+                                ifr->ifr_flags = 1;
+                        }
+                        else {
+                                ifr->ifr_flags = 0;
+                        }
+                        return 0;
+
 		/*
 		 *	Unknown or private ioctl
 		 */
@@ -2190,6 +2295,7 @@
 		case SIOCGIFMAP:
 		case SIOCGIFINDEX:
 		case SIOCGIFTXQLEN:
+                case SIOCGACCEPTLOCALADDRS:
 			dev_load(ifr.ifr_name);
 			read_lock(&dev_base_lock);
 			ret = dev_ifsioc(&ifr, cmd);
@@ -2253,6 +2359,7 @@
 		case SIOCBONDSLAVEINFOQUERY:
 		case SIOCBONDINFOQUERY:
 		case SIOCBONDCHANGEACTIVE:
+                case SIOCSACCEPTLOCALADDRS:
 			if (!capable(CAP_NET_ADMIN))
 				return -EPERM;
 			dev_load(ifr.ifr_name);
@@ -2607,6 +2714,7 @@
 
 extern void net_device_init(void);
 extern void ip_auto_config(void);
+struct proc_dir_entry *proc_net_drivers;
 #ifdef CONFIG_NET_DIVERT
 extern void dv_init(void);
 #endif /* CONFIG_NET_DIVERT */
@@ -2624,6 +2732,7 @@
 	if (!dev_boot_phase)
 		return 0;
 
+
 #ifdef CONFIG_NET_DIVERT
 	dv_init();
 #endif /* CONFIG_NET_DIVERT */
@@ -2641,8 +2750,13 @@
 		queue->cng_level = 0;
 		queue->avg_blog = 10; /* arbitrary non-zero */
 		queue->completion_queue = NULL;
+		INIT_LIST_HEAD(&queue->poll_list);
+		set_bit(__LINK_STATE_START, &queue->blog_dev.state);
+		queue->blog_dev.weight = weight_p;
+		queue->blog_dev.poll = process_backlog;
+		atomic_set(&queue->blog_dev.refcnt, 1);
 	}
-	
+
 #ifdef CONFIG_NET_PROFILE
 	net_profile_init();
 	NET_PROFILE_REGISTER(dev_queue_xmit);
@@ -2725,6 +2839,7 @@
 #ifdef CONFIG_PROC_FS
 	proc_net_create("dev", 0, dev_get_info);
 	create_proc_read_entry("net/softnet_stat", 0, 0, dev_proc_stats, NULL);
+	proc_net_drivers = proc_mkdir("net/drivers", 0);
 #ifdef WIRELESS_EXT
 	/* Available in net/core/wireless.c */
 	proc_net_create("wireless", 0, dev_get_wireless_info);
@@ -2742,7 +2857,6 @@
 #ifdef CONFIG_NET_SCHED
 	pktsched_init();
 #endif
-
 	/*
 	 *	Initialise network devices
 	 */
--- linux-2.4.19/net/core/pktgen.c	Fri Aug  2 17:39:46 2002
+++ linux-2.4.19.dev/net/core/pktgen.c	Mon Sep 16 23:53:41 2002
@@ -1,8 +1,8 @@
-/* $Id: pg_2.4.19.patch,v 1.5 2002/09/17 07:01:55 greear Exp $
- * pktgen.c: Packet Generator for performance evaluation.
+/* -*-linux-c-*-
  *
  * Copyright 2001, 2002 by Robert Olsson <robert.olsson@its.uu.se>
  *                                 Uppsala University, Sweden
+ *                 2002  Ben Greear <greearb@candelatech.com>
  *
  * A tool for loading the network with preconfigurated packets.
  * The tool is implemented as a linux module.  Parameters are output 
@@ -19,6 +19,33 @@
  * Integrated.  020301 --DaveM
  * Added multiskb option 020301 --DaveM
  * Scaling of results. 020417--sigurdur@linpro.no
+ * Significant re-work of the module:
+ *   *  Convert to threaded model to more efficiently be able to transmit
+ *       and receive on multiple interfaces at once.
+ *   *  Converted many counters to __u64 to allow longer runs.
+ *   *  Allow configuration of ranges, like min/max IP address, MACs,
+ *       and UDP-ports, for both source and destination, and can
+ *       set to use a random distribution or sequentially walk the range.
+ *   *  Can now change most values after starting.
+ *   *  Place 12-byte packet in UDP payload with magic number,
+ *       sequence number, and timestamp.
+ *   *  Add receiver code that detects dropped pkts, re-ordered pkts, and
+ *       latencies (with micro-second) precision.
+ *   *  Add IOCTL interface to easily get counters & configuration.
+ *   --Ben Greear <greearb@candelatech.com>
+ *
+ * Renamed multiskb to clone_skb and cleaned up sending core for two distinct 
+ * skb modes. A clone_skb=0 mode for Ben "ranges" work and a clone_skb != 0 
+ * as a "fastpath" with a configurable number of clones after alloc's.
+ * clone_skb=0 means all packets are allocated this also means ranges time 
+ * stamps etc can be used. clone_skb=100 means 1 malloc is followed by 100 
+ * clones.
+ *
+ * Also moved to /proc/net/pktgen/ 
+ * --ro
+ *
+ * Sept 10:  Fixed threading/locking.  Lots of bone-headed and more clever
+ *    mistakes.  Also merged in DaveM's patch in the -pre6 patch.
  *
  * See Documentation/networking/pktgen.txt for how to use this.
  */
@@ -41,6 +68,7 @@
 #include <asm/bitops.h>
 #include <asm/io.h>
 #include <asm/dma.h>
+#include <asm/uaccess.h>
 
 #include <linux/in.h>
 #include <linux/ip.h>
@@ -52,142 +80,822 @@
 #include <linux/proc_fs.h>
 #include <linux/if_arp.h>
 #include <net/checksum.h>
+#include <net/profile.h>
 #include <asm/timex.h>
 
-#define cycles()	((u32)get_cycles())
+#include <linux/smp_lock.h> /* for lock kernel */
+#include <asm/div64.h> /* do_div */
+
+#include "pktgen.h"
+
 
 static char version[] __initdata = 
-  "pktgen.c: v1.1 020418: Packet Generator for packet performance testing.\n";
+  "pktgen.c: v1.6: Packet Generator for packet performance testing.\n";
+
+/* Used to help with determining the pkts on receive */
+
+#define PKTGEN_MAGIC 0xbe9be955
+
+/* #define PG_DEBUG(a) a */
+#define PG_DEBUG(a) /* a */
+
+/* cycles per micro-second */
+static u32 pg_cycles_per_ns;
+static u32 pg_cycles_per_us;
+static u32 pg_cycles_per_ms;
+
+/* Module parameters, defaults. */
+static int pg_count_d = 0; /* run forever by default */
+static int pg_ipg_d = 0;
+static int pg_multiskb_d = 0;
+static int pg_thread_count = 1; /* Initial threads to create */
+static int debug = 0;
 
-/* Parameters */
-static char pg_outdev[32], pg_dst[32];
-static int pkt_size = ETH_ZLEN;
-static int nfrags = 0;
-static __u32 pg_count = 100000;  /* Default No packets to send */
-static __u32 pg_ipg = 0;  /* Default Interpacket gap in nsec */
-static int pg_multiskb = 0; /* Use multiple SKBs during packet gen. */
-
-static int debug;
-static int forced_stop;
-static int pg_cpu_speed;
-static int pg_busy;
-
-static __u8 hh[14] = { 
-
-  /* Overrun by /proc config  */
-
-    0x00, 0x80, 0xC8, 0x79, 0xB3, 0xCB, 
-
-    /* We fill in SRC address later */
-    0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
-    0x08, 0x00
+
+
+/* List of all running threads */
+static struct pktgen_thread_info* pktgen_threads = NULL;
+spinlock_t _pg_threadlist_lock = SPIN_LOCK_UNLOCKED;
+
+/* Holds interfaces for all threads */
+#define PG_INFO_HASH_MAX 32
+static struct pktgen_interface_info* pg_info_hash[PG_INFO_HASH_MAX];
+spinlock_t _pg_hash_lock = SPIN_LOCK_UNLOCKED;
+
+#define PG_PROC_DIR "pktgen"
+static struct proc_dir_entry *pg_proc_dir = NULL;
+
+char module_fname[128];
+struct proc_dir_entry *module_proc_ent = NULL;
+
+
+static void init_pktgen_kthread(struct pktgen_thread_info *kthread, char *name);
+static int pg_rem_interface_info(struct pktgen_thread_info* pg_thread,
+                                 struct pktgen_interface_info* i);
+static int pg_add_interface_info(struct pktgen_thread_info* pg_thread,
+                                 const char* ifname);
+static void exit_pktgen_kthread(struct pktgen_thread_info *kthread);
+static void stop_pktgen_kthread(struct pktgen_thread_info *kthread);
+static struct pktgen_thread_info* pg_find_thread(const char* name);
+static int pg_add_thread_info(const char* name);
+static struct pktgen_interface_info* pg_find_interface(struct pktgen_thread_info* pg_thread,
+                                                       const char* ifname);
+static int pktgen_device_event(struct notifier_block *, unsigned long, void *);
+
+
+struct notifier_block pktgen_notifier_block = {
+	notifier_call: pktgen_device_event,
 };
 
-static unsigned char *pg_dstmac = hh;
-static char pg_result[512];
+/*  This code works around the fact that do_div cannot handle two 64-bit
+    numbers, and regular 64-bit division doesn't work on x86 kernels.
+    --Ben
+*/
 
-static struct net_device *pg_setup_inject(u32 *saddrp)
-{
-	struct net_device *odev;
-	int p1, p2;
-	u32 saddr;
+#define PG_DIV 0
+#define PG_REM 1
 
-	rtnl_lock();
-	odev = __dev_get_by_name(pg_outdev);
-	if (!odev) {
-		sprintf(pg_result, "No such netdevice: \"%s\"", pg_outdev);
-		goto out_unlock;
-	}
+/* This was emailed to LMKL by: Chris Caputo <ccaputo@alt.net>
+ * Function copied/adapted/optimized from:
+ *
+ *  nemesis.sourceforge.net/browse/lib/static/intmath/ix86/intmath.c.html
+ *
+ * Copyright 1994, University of Cambridge Computer Laboratory
+ * All Rights Reserved.
+ *
+ * TODO: When running on a 64-bit CPU platform, this should no longer be
+ * TODO: necessary.
+ */
+inline static s64 divremdi3(s64 x, s64 y, int type) {
+        u64 a = (x < 0) ? -x : x;
+        u64 b = (y < 0) ? -y : y;
+        u64 res = 0, d = 1;
+
+        if (b > 0) {
+                while (b < a) {
+                        b <<= 1;
+                        d <<= 1;
+                }
+        }
+        
+        do {
+                if ( a >= b ) {
+                        a -= b;
+                        res += d;
+                }
+                b >>= 1;
+                d >>= 1;
+        }
+        while (d);
+
+        if (PG_DIV == type) {
+                return (((x ^ y) & (1ll<<63)) == 0) ? res : -(s64)res;
+        }
+        else {
+                return ((x & (1ll<<63)) == 0) ? a : -(s64)a;
+        }
+}/* divremdi3 */
+
+/* End of hacks to deal with 64-bit math on x86 */
 
-	if (odev->type != ARPHRD_ETHER) {
-		sprintf(pg_result, "Not ethernet device: \"%s\"", pg_outdev);
-		goto out_unlock;
-	}
 
-	if (!netif_running(odev)) {
-		sprintf(pg_result, "Device is down: \"%s\"", pg_outdev);
-		goto out_unlock;
-	}
 
-	for (p1 = 6, p2 = 0; p1 < odev->addr_len + 6; p1++)
-		hh[p1] = odev->dev_addr[p2++];
+inline static void pg_lock_thread_list(char* msg) {
+        if (debug > 1) {
+                printk("before pg_lock_thread_list, msg: %s\n", msg);
+        }
+        spin_lock(&_pg_threadlist_lock);
+        if (debug > 1) {
+                printk("after pg_lock_thread_list, msg: %s\n", msg);
+        }
+}
 
-	saddr = 0;
-	if (odev->ip_ptr) {
-		struct in_device *in_dev = odev->ip_ptr;
+inline static void pg_unlock_thread_list(char* msg) {
+        if (debug > 1) {
+                printk("before pg_unlock_thread_list, msg: %s\n", msg);
+        }
+        spin_unlock(&_pg_threadlist_lock);
+        if (debug > 1) {
+                printk("after pg_unlock_thread_list, msg: %s\n", msg);
+        }
+}
 
-		if (in_dev->ifa_list)
-			saddr = in_dev->ifa_list->ifa_address;
-	}
-	atomic_inc(&odev->refcnt);
-	rtnl_unlock();
+inline static void pg_lock_hash(char* msg) {
+        if (debug > 1) {
+                printk("before pg_lock_hash, msg: %s\n", msg);
+        }
+        spin_lock(&_pg_hash_lock);
+        if (debug > 1) {
+                printk("before pg_lock_hash, msg: %s\n", msg);
+        }
+}
 
-	*saddrp = saddr;
-	return odev;
+inline static void pg_unlock_hash(char* msg) {
+        if (debug > 1) {
+                printk("before pg_unlock_hash, msg: %s\n", msg);
+        }
+        spin_unlock(&_pg_hash_lock);
+        if (debug > 1) {
+                printk("after pg_unlock_hash, msg: %s\n", msg);
+        }
+}
 
-out_unlock:
-	rtnl_unlock();
-	return NULL;
+inline static void pg_lock(struct pktgen_thread_info* pg_thread, char* msg) {
+        if (debug > 1) {
+                printk("before pg_lock thread, msg: %s\n", msg);
+        }
+        spin_lock(&(pg_thread->pg_threadlock));
+        if (debug > 1) {
+                printk("after pg_lock thread, msg: %s\n", msg);
+        }
 }
 
-static u32 idle_acc_lo, idle_acc_hi;
+inline static void pg_unlock(struct pktgen_thread_info* pg_thread, char* msg) {
+        if (debug > 1) {
+                printk("before pg_unlock thread, thread: %p  msg: %s\n",
+                       pg_thread, msg);
+        }
+        spin_unlock(&(pg_thread->pg_threadlock));
+        if (debug > 1) {
+                printk("after pg_unlock thread, thread: %p  msg: %s\n",
+                       pg_thread, msg);
+        }
+}
+
+/** Convert to miliseconds */
+static inline __u64 tv_to_ms(const struct timeval* tv) {
+        __u64 ms = tv->tv_usec / 1000;
+        ms += (__u64)tv->tv_sec * (__u64)1000;
+        return ms;
+}
 
-static void nanospin(int pg_ipg)
+
+/** Convert to micro-seconds */
+static inline __u64 tv_to_us(const struct timeval* tv) {
+        __u64 us = tv->tv_usec;
+        us += (__u64)tv->tv_sec * (__u64)1000000;
+        return us;
+}
+
+
+static inline __u64 pg_div(__u64 n, __u32 base) {
+        __u64 tmp = n;
+        do_div(tmp, base);
+        /* printk("pg_div, n: %llu  base: %d  rv: %llu\n",
+                  n, base, tmp); */
+        return tmp;
+}
+
+/* Fast, not horribly accurate, since the machine started. */
+static inline __u64 getRelativeCurMs(void) {
+        return pg_div(get_cycles(), pg_cycles_per_ms);
+}
+
+/* Since the epoc.  More precise over long periods of time than
+ * getRelativeCurMs
+ */
+static inline __u64 getCurMs(void) {
+        struct timeval tv;
+        do_gettimeofday(&tv);
+        return tv_to_ms(&tv);
+}
+
+/* Since the epoc.  More precise over long periods of time than
+ * getRelativeCurMs
+ */
+static inline __u64 getCurUs(void) {
+        struct timeval tv;
+        do_gettimeofday(&tv);
+        return tv_to_us(&tv);
+}
+
+/* Since the machine booted. */
+static inline __u64 getRelativeCurUs(void) {
+        return pg_div(get_cycles(), pg_cycles_per_us);
+}
+
+/* Since the machine booted. */
+static inline __u64 getRelativeCurNs(void) {
+        return pg_div(get_cycles(), pg_cycles_per_ns);
+}
+
+static inline __u64 tv_diff(const struct timeval* a, const struct timeval* b) {
+        return tv_to_us(a) - tv_to_us(b);
+}
+
+
+
+int pktgen_proc_ioctl(struct inode* inode, struct file* file, unsigned int cmd,
+                      unsigned long arg) {
+        int err = 0;
+        struct pktgen_ioctl_info args;
+        struct pktgen_thread_info* targ = NULL;
+
+        /*
+        if (!capable(CAP_NET_ADMIN)){
+                return -EPERM;
+        }
+        */
+        
+        if (copy_from_user(&args, (void*)arg, sizeof(args))) {
+                return -EFAULT;
+        }
+
+        /* Null terminate the names */
+        args.thread_name[31] = 0;
+        args.interface_name[31] = 0;
+
+        /* printk("pktgen:  thread_name: %s  interface_name: %s\n",
+         *        args.thread_name, args.interface_name);
+         */
+        
+        switch (cmd) {
+         case GET_PKTGEN_INTERFACE_INFO: {
+                 targ = pg_find_thread(args.thread_name);
+                 if (targ) {
+                         struct pktgen_interface_info* info;
+                         info = pg_find_interface(targ, args.interface_name);
+                         if (info) {
+                                 memcpy(&(args.info), info, sizeof(args.info));
+                                 if (copy_to_user((void*)(arg), &args, sizeof(args))) {
+                                         printk("ERROR: pktgen:  copy_to_user failed.\n");
+                                         err = -EFAULT;
+                                 }
+                                 else {
+                                         err = 0;
+                                 }
+                         }
+                         else {
+                                 printk("ERROR: pktgen:  Could not find interface -:%s:-\n",
+                                        args.interface_name);
+                                 err = -ENODEV;
+                         }
+                 }
+                 else {
+                         printk("ERROR: pktgen:  Could not find thread -:%s:-.\n",
+                                args.thread_name);
+                         err = -ENODEV;
+                 }
+                 break;
+         }
+         default:
+                /* pass on to underlying device instead?? */
+                printk(__FUNCTION__ ": Unknown pktgen IOCTL: %x \n",
+                       cmd);
+                return -EINVAL;
+        }
+        
+        return err;
+}/* pktgen_proc_ioctl */
+
+static struct file_operations pktgen_fops = {
+        ioctl:     pktgen_proc_ioctl,
+};
+
+static void remove_pg_info_from_hash(struct pktgen_interface_info* info) {
+        pg_lock_hash(__FUNCTION__);
+        {
+                int device_idx = info->odev ? info->odev->ifindex : 0;
+                int b = device_idx % PG_INFO_HASH_MAX;
+                struct pktgen_interface_info* p = pg_info_hash[b];
+                struct pktgen_interface_info* prev = pg_info_hash[b];
+
+                PG_DEBUG(printk("remove_pg_info_from_hash, p: %p info: %p  device_idx: %i\n",
+                                p, info, device_idx));
+
+                if (p != NULL) {
+                
+                        if (p == info) {
+                                pg_info_hash[b] = p->next_hash;
+                                p->next_hash = NULL;
+                        }
+                        else {
+                                while (prev->next_hash) {
+                                        p = prev->next_hash;
+                                        if (p == info) {
+                                                prev->next_hash = p->next_hash;
+                                                p->next_hash = NULL;
+                                                break;
+                                        }
+                                        prev = p;
+                                }
+                        }
+                }
+                
+                if (info->odev) {
+                        info->odev->priv_flags &= ~(IFF_PKTGEN_RCV);
+                }
+        }
+        pg_unlock_hash(__FUNCTION__);
+}/* remove_pg_info_from_hash */
+
+
+static void add_pg_info_to_hash(struct pktgen_interface_info* info) {
+        /* First remove it, just in case it's already there. */
+        remove_pg_info_from_hash(info);
+        
+        pg_lock_hash(__FUNCTION__);
+        {
+                int device_idx = info->odev ? info->odev->ifindex : 0;
+                int b = device_idx % PG_INFO_HASH_MAX;
+
+                PG_DEBUG(printk("add_pg_info_from_hash, b: %i info: %p  device_idx: %i\n",
+                                b, info, device_idx));
+
+                info->next_hash = pg_info_hash[b];
+                pg_info_hash[b] = info;
+
+
+                if (info->odev) {
+                        info->odev->priv_flags |= (IFF_PKTGEN_RCV);
+                }
+        }
+        pg_unlock_hash(__FUNCTION__);
+}/* add_pg_info_to_hash */
+
+
+/* Find the pktgen_interface_info for a device idx */
+struct pktgen_interface_info* find_pg_info(int device_idx) {
+        struct pktgen_interface_info* p = NULL;
+        if (debug > 1) {
+                printk("in find_pg_info...\n");
+        }
+        pg_lock_hash(__FUNCTION__);
+        {
+                int b = device_idx % PG_INFO_HASH_MAX;
+                p = pg_info_hash[b];
+                while (p) {
+                        if (p->odev && (p->odev->ifindex == device_idx)) {
+                                break;
+                        }
+                        p = p->next_hash;
+                }
+        }
+        pg_unlock_hash(__FUNCTION__);
+        return p;
+}
+
+
+/* Remove an interface from our hash, dissassociate pktgen_interface_info
+ * from interface
+ */
+static void check_remove_device(struct pktgen_interface_info* info) {
+        struct pktgen_interface_info* pi = NULL;
+        if (info->odev) {
+                pi = find_pg_info(info->odev->ifindex);
+                if (pi != info) {
+                        printk("ERROR: pi != info\n");
+                }
+                else {
+                        /* Remove info from our hash */
+                        remove_pg_info_from_hash(info);
+                }
+
+                rtnl_lock();
+                info->odev->priv_flags &= ~(IFF_PKTGEN_RCV);
+                atomic_dec(&(info->odev->refcnt));
+                info->odev = NULL;
+                rtnl_unlock();
+        }
+}/* check_remove_device */
+
+
+static int pg_remove_interface_from_all_threads(const char* dev_name) {
+        int cnt = 0;
+        pg_lock_thread_list(__FUNCTION__);
+        {
+                struct pktgen_thread_info* tmp = pktgen_threads;
+                struct pktgen_interface_info* info = NULL;
+                
+                while (tmp) {
+                        info = pg_find_interface(tmp, dev_name);
+                        if (info) {
+                                pg_rem_interface_info(tmp, info);
+                                cnt++;
+                        }
+                        tmp = tmp->next;
+                }
+        }
+        pg_unlock_thread_list(__FUNCTION__);
+        return cnt;
+}/* pg_rem_interface_from_all_threads */
+
+
+static int pktgen_device_event(struct notifier_block *unused, unsigned long event, void *ptr) {
+	struct net_device *dev = (struct net_device *)(ptr);
+
+	/* It is OK that we do not hold the group lock right now,
+	 * as we run under the RTNL lock.
+	 */
+
+	switch (event) {
+	case NETDEV_CHANGEADDR:
+	case NETDEV_GOING_DOWN:
+	case NETDEV_DOWN:
+	case NETDEV_UP:
+		/* Ignore for now */
+		break;
+		
+	case NETDEV_UNREGISTER:
+                pg_remove_interface_from_all_threads(dev->name);
+		break;
+	};
+
+	return NOTIFY_DONE;
+}
+
+
+/* Associate pktgen_interface_info with a device.
+ */
+static struct net_device* pg_setup_interface(struct pktgen_interface_info* info) {
+	struct net_device *odev;
+
+        check_remove_device(info);                
+        
+	rtnl_lock();
+	odev = __dev_get_by_name(info->ifname);
+	if (!odev) {
+		printk("No such netdevice: \"%s\"\n", info->ifname);
+	}
+	else if (odev->type != ARPHRD_ETHER) {
+		printk("Not an ethernet device: \"%s\"\n", info->ifname);
+	}
+	else if (!netif_running(odev)) {
+		printk("Device is down: \"%s\"\n", info->ifname);
+	}
+	else if (odev->priv_flags & IFF_PKTGEN_RCV) {
+		printk("ERROR: Device: \"%s\" is already assigned to a pktgen interface.\n",
+                       info->ifname);
+	}
+        else {
+                atomic_inc(&odev->refcnt);
+                info->odev = odev;
+                info->odev->priv_flags |= (IFF_PKTGEN_RCV);
+        }
+        
+	rtnl_unlock();
+
+        if (info->odev) {
+                add_pg_info_to_hash(info);
+        }
+        
+        return info->odev;
+}
+
+/* Read info from the interface and set up internal pktgen_interface_info
+ * structure to have the right information to create/send packets
+ */
+static void pg_setup_inject(struct pktgen_interface_info* info)
 {
-	u32 idle_start, idle;
+        if (!info->odev) {
+                /* Try once more, just in case it works now. */
+                pg_setup_interface(info);
+        }
+        
+        if (!info->odev) {
+                printk("ERROR: info->odev == NULL in setup_inject.\n");
+                sprintf(info->result, "ERROR: info->odev == NULL in setup_inject.\n");
+                return;
+        }
+        
+        /* Default to the interface's mac if not explicitly set. */
+        if (!(info->flags & F_SET_SRCMAC)) {
+                memcpy(&(info->hh[6]), info->odev->dev_addr, 6);
+        }
+        else {
+                memcpy(&(info->hh[6]), info->src_mac, 6);
+        }
+
+        /* Set up Dest MAC */
+        memcpy(&(info->hh[0]), info->dst_mac, 6);
+
+        /* Set up pkt size */
+        info->cur_pkt_size = info->min_pkt_size;
+        
+	info->saddr_min = 0;
+	info->saddr_max = 0;
+        if (strlen(info->src_min) == 0) {
+                if (info->odev->ip_ptr) {
+                        struct in_device *in_dev = info->odev->ip_ptr;
+
+                        if (in_dev->ifa_list) {
+                                info->saddr_min = in_dev->ifa_list->ifa_address;
+                                info->saddr_max = info->saddr_min;
+                        }
+                }
+	}
+        else {
+                info->saddr_min = in_aton(info->src_min);
+                info->saddr_max = in_aton(info->src_max);
+        }
+
+        info->daddr_min = in_aton(info->dst_min);
+        info->daddr_max = in_aton(info->dst_max);
+
+        /* Initialize current values. */
+        info->cur_dst_mac_offset = 0;
+        info->cur_src_mac_offset = 0;
+        info->cur_saddr = info->saddr_min;
+        info->cur_daddr = info->daddr_min;
+        info->cur_udp_dst = info->udp_dst_min;
+        info->cur_udp_src = info->udp_src_min;
+}
 
-	idle_start = cycles();
+/* ipg is in nano-seconds */
+static void nanospin(__u32 ipg, struct pktgen_interface_info* info)
+{
+	u64 idle_start = get_cycles();
+        u64 idle;
 
 	for (;;) {
 		barrier();
-		idle = cycles() - idle_start;
-		if (idle * 1000 >= pg_ipg * pg_cpu_speed)
+		idle = get_cycles() - idle_start;
+		if (idle * 1000 >= ipg * pg_cycles_per_us)
 			break;
 	}
-	idle_acc_lo += idle;
-	if (idle_acc_lo < idle)
-		idle_acc_hi++;
+	info->idle_acc += idle;
+}
+
+
+/* ipg is in micro-seconds (usecs) */
+static void pg_udelay(__u32 delay_us, struct pktgen_interface_info* info)
+{
+        u64 start = getRelativeCurUs();
+        u64 now;
+        
+	for (;;) {
+                do_softirq();
+                now = getRelativeCurUs();
+                if (start + delay_us <= (now - 10)) {
+                        break;
+                }
+
+                if (!info->do_run_run) {
+                        return;
+                }
+                
+                if (current->need_resched) {
+                        schedule();
+                }
+                        
+                now = getRelativeCurUs();
+                if (start + delay_us <= (now - 10)) {
+                        break;
+                }
+	}
+
+        info->idle_acc += (1000 * (now - start));
+
+        /* We can break out of the loop up to 10us early, so spend the rest of
+         * it spinning to increase accuracy.
+         */
+        if (start + delay_us > now) {
+                nanospin((start + delay_us) - now, info);
+        }
 }
 
+
+
+
+/* Returns: cycles per micro-second */
 static int calc_mhz(void)
 {
 	struct timeval start, stop;
-	u32 start_s, elapsed;
-
+	u64 start_s;
+        u64 t1, t2;
+        u32 elapsed;
+        u32 clock_time = 0;
+        
 	do_gettimeofday(&start);
-	start_s = cycles();
+	start_s = get_cycles();
+        /* Spin for 50,000,000 cycles */
 	do {
 		barrier();
-		elapsed = cycles() - start_s;
+		elapsed = (u32)(get_cycles() - start_s);
 		if (elapsed == 0)
 			return 0;
-	} while (elapsed < 1000 * 50000);
+	} while (elapsed < 50000000);
 	do_gettimeofday(&stop);
-	return elapsed/(stop.tv_usec-start.tv_usec+1000000*(stop.tv_sec-start.tv_sec));
+
+        t1 = tv_to_us(&start);
+        t2 = tv_to_us(&stop);
+
+        clock_time = (u32)(t2 - t1);
+        if (clock_time == 0) {
+                printk("pktgen: ERROR:  clock_time was zero..things may not work right, t1: %u  t2: %u ...\n",
+                       (u32)(t1), (u32)(t2));
+                return 0x7FFFFFFF;
+        }
+	return elapsed / clock_time;
 }
 
+/* Calibrate cycles per micro-second */
 static void cycles_calibrate(void)
 {
 	int i;
 
 	for (i = 0; i < 3; i++) {
-		int res = calc_mhz();
-		if (res > pg_cpu_speed)
-			pg_cpu_speed = res;
+		u32 res = calc_mhz();
+		if (res > pg_cycles_per_us)
+			pg_cycles_per_us = res;
 	}
+
+        /* Set these up too, only need to calculate these once. */
+        pg_cycles_per_ns = pg_cycles_per_us / 1000;
+        if (pg_cycles_per_ns == 0) {
+                pg_cycles_per_ns = 1;
+        }
+        pg_cycles_per_ms = pg_cycles_per_us * 1000;
+        
+        printk("pktgen: cycles_calibrate, cycles_per_ns: %d  per_us: %d  per_ms: %d\n",
+               pg_cycles_per_ns, pg_cycles_per_us, pg_cycles_per_ms);
 }
 
-static struct sk_buff *fill_packet(struct net_device *odev, __u32 saddr)
+
+/* Increment/randomize headers according to flags and current values
+ * for IP src/dest, UDP src/dst port, MAC-Addr src/dst
+ */
+static void mod_cur_headers(struct pktgen_interface_info* info) {        
+        __u32 imn;
+        __u32 imx;
+        
+	/*  Deal with source MAC */
+        if (info->src_mac_count > 1) {
+                __u32 mc;
+                __u32 tmp;
+                if (info->flags & F_MACSRC_RND) {
+                        mc = net_random() % (info->src_mac_count);
+                }
+                else {
+                        mc = info->cur_src_mac_offset++;
+                        if (info->cur_src_mac_offset > info->src_mac_count) {
+                                info->cur_src_mac_offset = 0;
+                        }
+                }
+
+                tmp = info->src_mac[5] + (mc & 0xFF);
+                info->hh[11] = tmp;
+                tmp = (info->src_mac[4] + ((mc >> 8) & 0xFF) + (tmp >> 8));
+                info->hh[10] = tmp;
+                tmp = (info->src_mac[3] + ((mc >> 16) & 0xFF) + (tmp >> 8));
+                info->hh[9] = tmp;
+                tmp = (info->src_mac[2] + ((mc >> 24) & 0xFF) + (tmp >> 8));
+                info->hh[8] = tmp;
+                tmp = (info->src_mac[1] + (tmp >> 8));
+                info->hh[7] = tmp;        
+        }
+
+        /*  Deal with Destination MAC */
+        if (info->dst_mac_count > 1) {
+                __u32 mc;
+                __u32 tmp;
+                if (info->flags & F_MACDST_RND) {
+                        mc = net_random() % (info->dst_mac_count);
+                }
+                else {
+                        mc = info->cur_dst_mac_offset++;
+                        if (info->cur_dst_mac_offset > info->dst_mac_count) {
+                                info->cur_dst_mac_offset = 0;
+                        }
+                }
+
+                tmp = info->dst_mac[5] + (mc & 0xFF);
+                info->hh[5] = tmp;
+                tmp = (info->dst_mac[4] + ((mc >> 8) & 0xFF) + (tmp >> 8));
+                info->hh[4] = tmp;
+                tmp = (info->dst_mac[3] + ((mc >> 16) & 0xFF) + (tmp >> 8));
+                info->hh[3] = tmp;
+                tmp = (info->dst_mac[2] + ((mc >> 24) & 0xFF) + (tmp >> 8));
+                info->hh[2] = tmp;
+                tmp = (info->dst_mac[1] + (tmp >> 8));
+                info->hh[1] = tmp;        
+        }
+
+        if (info->udp_src_min < info->udp_src_max) {
+                if (info->flags & F_UDPSRC_RND) {
+                        info->cur_udp_src = ((net_random() % (info->udp_src_max - info->udp_src_min))
+                                             + info->udp_src_min);
+                }
+                else {
+                     info->cur_udp_src++;
+                     if (info->cur_udp_src >= info->udp_src_max) {
+                             info->cur_udp_src = info->udp_src_min;
+                     }
+                }
+        }
+
+        if (info->udp_dst_min < info->udp_dst_max) {
+                if (info->flags & F_UDPDST_RND) {
+                        info->cur_udp_dst = ((net_random() % (info->udp_dst_max - info->udp_dst_min))
+                                             + info->udp_dst_min);
+                }
+                else {
+                     info->cur_udp_dst++;
+                     if (info->cur_udp_dst >= info->udp_dst_max) {
+                             info->cur_udp_dst = info->udp_dst_min;
+                     }
+                }
+        }
+
+        if ((imn = ntohl(info->saddr_min)) < (imx = ntohl(info->saddr_max))) {
+                __u32 t;
+                if (info->flags & F_IPSRC_RND) {
+                        t = ((net_random() % (imx - imn)) + imn);
+                }
+                else {
+                     t = ntohl(info->cur_saddr);
+                     t++;
+                     if (t > imx) {
+                             t = imn;
+                     }
+                }
+                info->cur_saddr = htonl(t);
+        }
+
+        if ((imn = ntohl(info->daddr_min)) < (imx = ntohl(info->daddr_max))) {
+                __u32 t;
+                if (info->flags & F_IPDST_RND) {
+                        t = ((net_random() % (imx - imn)) + imn);
+                }
+                else {
+                     t = ntohl(info->cur_daddr);
+                     t++;
+                     if (t > imx) {
+                             t = imn;
+                     }
+                }
+                info->cur_daddr = htonl(t);
+        }
+
+        if (info->min_pkt_size < info->max_pkt_size) {
+                __u32 t;
+                if (info->flags & F_TXSIZE_RND) {
+                        t = ((net_random() % (info->max_pkt_size - info->min_pkt_size))
+                             + info->min_pkt_size);
+                }
+                else {
+                     t = info->cur_pkt_size + 1;
+                     if (t > info->max_pkt_size) {
+                             t = info->min_pkt_size;
+                     }
+                }
+                info->cur_pkt_size = t;
+        }
+}/* mod_cur_headers */
+
+
+static struct sk_buff *fill_packet(struct net_device *odev, struct pktgen_interface_info* info)
 {
-	struct sk_buff *skb;
+	struct sk_buff *skb = NULL;
 	__u8 *eth;
 	struct udphdr *udph;
 	int datalen, iplen;
 	struct iphdr *iph;
-
-	skb = alloc_skb(pkt_size + 64 + 16, GFP_ATOMIC);
+        struct pktgen_hdr *pgh = NULL;
+        
+	skb = alloc_skb(info->cur_pkt_size + 64 + 16, GFP_ATOMIC);
 	if (!skb) {
-		sprintf(pg_result, "No memory");
+		sprintf(info->result, "No memory");
 		return NULL;
 	}
 
@@ -198,25 +906,30 @@
 	iph = (struct iphdr *)skb_put(skb, sizeof(struct iphdr));
 	udph = (struct udphdr *)skb_put(skb, sizeof(struct udphdr));
 
-	/*  Copy the ethernet header  */
-	memcpy(eth, hh, 14);
-
-	datalen = pkt_size - 14 - 20 - 8; /* Eth + IPh + UDPh */
-	if (datalen < 0)
-		datalen = 0;
-
-	udph->source = htons(9);
-	udph->dest = htons(9);
+        /* Update any of the values, used when we're incrementing various
+         * fields.
+         */
+        mod_cur_headers(info);
+
+	memcpy(eth, info->hh, 14);
+        
+	datalen = info->cur_pkt_size - 14 - 20 - 8; /* Eth + IPh + UDPh */
+	if (datalen < sizeof(struct pktgen_hdr)) {
+		datalen = sizeof(struct pktgen_hdr);
+        }
+        
+	udph->source = htons(info->cur_udp_src);
+	udph->dest = htons(info->cur_udp_dst);
 	udph->len = htons(datalen + 8); /* DATA + udphdr */
 	udph->check = 0;  /* No checksum */
 
 	iph->ihl = 5;
 	iph->version = 4;
-	iph->ttl = 3;
+	iph->ttl = 32;
 	iph->tos = 0;
 	iph->protocol = IPPROTO_UDP; /* UDP */
-	iph->saddr = saddr;
-	iph->daddr = in_aton(pg_dst);
+	iph->saddr = info->cur_saddr;
+	iph->daddr = info->cur_daddr;
 	iph->frag_off = 0;
 	iplen = 20 + 8 + datalen;
 	iph->tot_len = htons(iplen);
@@ -227,12 +940,14 @@
 	skb->dev = odev;
 	skb->pkt_type = PACKET_HOST;
 
-	if (nfrags <= 0) {
-		skb_put(skb, datalen);
+	if (info->nfrags <= 0) {
+                pgh = (struct pktgen_hdr *)skb_put(skb, datalen);
 	} else {
-		int frags = nfrags;
+		int frags = info->nfrags;
 		int i;
 
+                pgh = (struct pktgen_hdr*)(((char*)(udph)) + 8);
+                
 		if (frags > MAX_SKB_FRAGS)
 			frags = MAX_SKB_FRAGS;
 		if (datalen > frags*PAGE_SIZE) {
@@ -276,205 +991,980 @@
 		}
 	}
 
+        /* Stamp the time, and sequence number, convert them to network byte order */
+        if (pgh) {
+                pgh->pgh_magic = __constant_htonl(PKTGEN_MAGIC);
+                do_gettimeofday(&(pgh->timestamp));
+                pgh->timestamp.tv_usec = htonl(pgh->timestamp.tv_usec);
+                pgh->timestamp.tv_sec = htonl(pgh->timestamp.tv_sec);
+                pgh->seq_num = htonl(info->seq_num);
+        }
+        info->seq_num++;
+        
 	return skb;
 }
 
 
-static void pg_inject(void)
-{
-	u32 saddr;
-	struct net_device *odev;
-	struct sk_buff *skb;
-	struct timeval start, stop;
-	u32 total, idle;
-	u32 pc, lcount;
-	char *p = pg_result;
-	u32  pkt_rate, data_rate;
-	char rate_unit;
-
-	odev = pg_setup_inject(&saddr);
-	if (!odev)
-		return;
-
-	skb = fill_packet(odev, saddr);
-	if (skb == NULL)
-		goto out_reldev;
-
-	forced_stop = 0;
-	idle_acc_hi = 0;
-	idle_acc_lo = 0;
-	pc = 0;
-	lcount = pg_count;
-	do_gettimeofday(&start);
+static void record_latency(struct pktgen_interface_info* info, int latency) {
+        /* NOTE:  Latency can be negative */
+        int div = 100;
+        int diff;
+        int vl;
+        int i;
+
+        info->pkts_rcvd_since_clear++;
+        
+        if (info->pkts_rcvd_since_clear < 100) {
+                div = info->pkts_rcvd;
+                if (info->pkts_rcvd_since_clear == 1) {
+                        info->avg_latency = latency;
+                }
+        }
+
+        if ((div + 1) == 0) {
+                info->avg_latency = 0;
+        }
+        else {
+                info->avg_latency = ((info->avg_latency * div + latency) / (div + 1));
+        }
+
+        if (latency < info->min_latency) {
+                info->min_latency = latency;
+        }
+        if (latency > info->max_latency) {
+                info->max_latency = latency;
+        }
+
+        /* Place the latency in the right 'bucket' */
+        diff = (latency - info->min_latency);        
+        for (i = 0; i<LAT_BUCKETS_MAX; i++) {
+                vl = (1<<i);
+                if (latency <= vl) {
+                        info->latency_bkts[i]++;
+                        break;
+                }
+        }
+}/* record latency */
+
+
+/* Returns < 0 if the skb is not a pktgen buffer. */
+int pktgen_receive(struct sk_buff* skb) {
+        /* See if we have a pktgen packet */
+        if ((skb->len >= (20 + 8 + sizeof(struct pktgen_hdr))) &&
+            (skb->protocol == __constant_htons(ETH_P_IP))) {
+                
+                /* It's IP, and long enough, lets check the magic number.
+                 * TODO:  This is a hack not always guaranteed to catch the right
+                 * packets.
+                 */
+                /*int i;
+                  char* tmp; */
+                struct pktgen_hdr* pgh;
+                /* printk("Length & protocol passed, skb->data: %p, raw: %p\n",
+                          skb->data, skb->h.raw); */
+                pgh = (struct pktgen_hdr*)(skb->data + 20 + 8);
+                /*
+                tmp = (char*)(skb->data);
+                for (i = 0; i<60; i++) {
+                        printk("%02hx ", tmp[i]);
+                        if (((i + 1) % 15) == 0) {
+                                printk("\n");
+                        }
+                }
+                printk("\n");
+                */
+                
+                if (pgh->pgh_magic == __constant_ntohl(PKTGEN_MAGIC)) {
+                        struct net_device* dev = skb->dev;
+                        struct pktgen_interface_info* info = find_pg_info(dev->ifindex);
+                        
+                        /* Got one! */
+                        /* TODO:  Check UDP checksum ?? */
+                        __u32 seq = ntohl(pgh->seq_num);
+
+                        if (!info) {
+                                return -1;
+                        }
+
+                        info->pkts_rcvd++;
+                        info->bytes_rcvd += (skb->len + 4); /* +4 for the checksum */
+                        
+                        /* Check for out-of-sequence packets */
+                        if (info->last_seq_rcvd == seq) {
+                                info->dup_rcvd++;
+                                info->dup_since_incr++;
+                        }
+                        else {
+                                __s64 rx = tv_to_us(&(skb->stamp));
+                                __s64 tx;
+                                struct timeval txtv;
+                                txtv.tv_usec = ntohl(pgh->timestamp.tv_usec);
+                                txtv.tv_sec = ntohl(pgh->timestamp.tv_sec);
+                                tx = tv_to_us(&txtv);
+                                record_latency(info, rx - tx);
+                                
+                                if ((info->last_seq_rcvd + 1) == seq) {
+                                        if ((info->peer_multiskb > 1) &&
+                                            (info->peer_multiskb > (info->dup_since_incr + 1))) {
+                                                
+                                                info->seq_gap_rcvd += (info->peer_multiskb -
+                                                                       info->dup_since_incr - 1);
+                                        }
+                                        /* Great, in order...all is well */
+                                }
+                                else if (info->last_seq_rcvd < seq) {
+                                        /* sequence gap, means we dropped a pkt most likely */
+                                        info->seq_gap_rcvd += (seq - info->last_seq_rcvd - 1);
+                                }
+                                else {
+                                        info->ooo_rcvd++; /* out-of-order */
+                                }
+                                
+                                info->dup_since_incr = 0;
+                        }
+                        info->last_seq_rcvd = seq;
+                        kfree_skb(skb);
+                        if (debug > 1) {
+                                printk("done with pktgen_receive, free'd pkt\n");
+                        }
+                        return 0;
+                }
+        }
+        return -1; /* Let another protocol handle it, it's not for us! */
+}/* pktgen_receive */
+
+static void pg_reset_latency_counters(struct pktgen_interface_info* info) {
+        int i;
+        info->avg_latency = 0;
+        info->min_latency = 0x7fffffff; /* largest integer */
+        info->max_latency = 0x80000000; /* smallest integer */
+        info->pkts_rcvd_since_clear = 0;
+        for (i = 0; i<LAT_BUCKETS_MAX; i++) {
+                info->latency_bkts[i] = 0;
+        }
+}
 
-	for(;;) {
-		spin_lock_bh(&odev->xmit_lock);
-		if (!netif_queue_stopped(odev)) {
-			struct sk_buff *skb2 = skb;
-
-			if (pg_multiskb)
-				skb2 = skb_copy(skb, GFP_ATOMIC);
-			else
-				atomic_inc(&skb->users);
-			if (!skb2)
-				goto skip;
-			if (odev->hard_start_xmit(skb2, odev)) {
-				kfree_skb(skb2);
-				if (net_ratelimit())
-					printk(KERN_INFO "Hard xmit error\n");
-			}
-			pc++;
-		}
-	skip:
-		spin_unlock_bh(&odev->xmit_lock);
+static void pg_clear_counters(struct pktgen_interface_info* info) {
+        info->seq_num = 1;
+        info->last_seq_rcvd = 0;
+        info->idle_acc = 0;
+	info->sofar = 0;
+        info->tx_bytes = 0;
+        info->errors = 0;
+        info->ooo_rcvd = 0;
+        info->dup_rcvd = 0;
+        info->pkts_rcvd = 0;
+        info->bytes_rcvd = 0;
+        info->seq_gap_rcvd = 0;
+        info->non_pg_pkts_rcvd = 0;
+
+        /* This is a bit of a hack, but it gets the dup counters
+         * in line so we don't have false alarms on dropped pkts.
+         */
+        info->dup_since_incr = info->peer_multiskb - 1;
+        
+        pg_reset_latency_counters(info);
+}
 
-		if (pg_ipg)
-			nanospin(pg_ipg);
-		if (forced_stop)
-			goto out_intr;
-		if (signal_pending(current))
-			goto out_intr;
-
-		if (--lcount == 0) {
-			if (atomic_read(&skb->users) != 1) {
-				u32 idle_start, idle;
-
-				idle_start = cycles();
-				while (atomic_read(&skb->users) != 1) {
-					if (signal_pending(current))
-						goto out_intr;
-					schedule();
-				}
-				idle = cycles() - idle_start;
-				idle_acc_lo += idle;
-				if (idle_acc_lo < idle)
-					idle_acc_hi++;
-			}
-			break;
-		}
+/* Adds an interface to the thread.  The interface will be in
+ * the stopped queue untill started.
+ */
+static int add_interface_to_thread(struct pktgen_thread_info* pg_thread,
+                                   struct pktgen_interface_info* info) {
+        int rv = 0;
+        /* grab lock & insert into the stopped list */
+        pg_lock(pg_thread, __FUNCTION__);
+
+        if (info->pg_thread) {
+                printk("pktgen: ERROR:  Already assigned to a thread.\n");
+                rv = -EBUSY;
+                goto out;
+        }
+        
+        info->next = pg_thread->stopped_if_infos;
+        pg_thread->stopped_if_infos = info;
+        info->pg_thread = pg_thread;
+
+ out:
+        pg_unlock(pg_thread, __FUNCTION__);        
+        return rv;
+}
 
-		if (netif_queue_stopped(odev) || current->need_resched) {
-			u32 idle_start, idle;
+/* Set up structure for sending pkts, clear counters, add to rcv hash,
+ * create initial packet, and move from the stopped to the running
+ * interface_info list
+ */
+static int pg_start_interface(struct pktgen_thread_info* pg_thread,
+                              struct pktgen_interface_info* info) {
+        PG_DEBUG(printk("Entering pg_start_interface..\n"));
+        pg_setup_inject(info);
+
+	if (!info->odev) {
+		return -1;
+        }
+
+        PG_DEBUG(printk("About to clean counters..\n"));
+        pg_clear_counters(info);
+
+        info->do_run_run = 1; /* Cranke yeself! */
+
+	info->skb = NULL;
+
+	info->started_at = getCurUs();
+
+        pg_lock(pg_thread, __FUNCTION__);
+        {
+                /* Remove from the stopped list */
+                struct pktgen_interface_info* p = pg_thread->stopped_if_infos;
+                if (p == info) {
+                        pg_thread->stopped_if_infos = p->next;
+                        p->next = NULL;
+                }
+                else {
+                        while (p) {
+                                if (p->next == info) {
+                                        p->next = p->next->next;
+                                        info->next = NULL;
+                                        break;
+                                }
+                                p = p->next;
+                        }
+                }
+
+                info->next_tx_ns = 0; /* Transmit immediately */
+                
+                /* Move to the front of the running list */
+                info->next = pg_thread->running_if_infos;
+                pg_thread->running_if_infos = info;
+        }
+        pg_unlock(pg_thread, __FUNCTION__);
+        PG_DEBUG(printk("Leaving pg_start_interface..\n"));
+        return 0;
+}/* pg_start_interface */
 
-			idle_start = cycles();
-			do {
-				if (signal_pending(current))
-					goto out_intr;
-				if (!netif_running(odev))
-					goto out_intr;
-				if (current->need_resched)
-					schedule();
-				else
-					do_softirq();
-			} while (netif_queue_stopped(odev));
-			idle = cycles() - idle_start;
-			idle_acc_lo += idle;
-			if (idle_acc_lo < idle)
-				idle_acc_hi++;
-		}
+
+/* set stopped-at timer, remove from running list, do counters & statistics
+ * NOTE:  We do not remove from the rcv hash.
+ */
+static int pg_stop_interface(struct pktgen_thread_info* pg_thread,
+                             struct pktgen_interface_info* info) {
+        __u64 total_us;
+        if (!info->do_run_run) {
+                printk("pktgen interface: %s is already stopped\n", info->ifname);
+                return -EINVAL;
+        }
+        
+        info->stopped_at = getCurMs();
+        info->do_run_run = 0;
+
+        /* The main worker loop will place it onto the stopped list if needed,
+         * next time this interface is asked to be re-inserted into the
+         * list.
+         */
+        
+	total_us = info->stopped_at - info->started_at;
+
+        {
+                __u64 idle = pg_div(info->idle_acc, pg_cycles_per_us);
+		char *p = info->result;
+                __u64 pps = divremdi3(info->sofar * 1000, pg_div(total_us, 1000), PG_DIV);
+                __u64 bps = pps * 8 * (info->cur_pkt_size + 4); /* take 32bit ethernet CRC into account */
+                
+		p += sprintf(p, "OK: %llu(c%llu+d%llu) usec, %llu (%dbyte) %llupps %lluMb/sec (%llubps)  errors: %llu",
+			     total_us, total_us - idle, idle,
+			     info->sofar,
+                             info->cur_pkt_size + 4, /* Add 4 to account for the ethernet checksum */
+			     pps,
+			     bps >> 20, bps, info->errors
+			     );
 	}
+        return 0;
+}/* pg_stop_interface */
 
-	do_gettimeofday(&stop);
 
-	total = (stop.tv_sec - start.tv_sec) * 1000000 +
-		stop.tv_usec - start.tv_usec;
+/* Re-inserts 'last' into the pg_thread's list.  Calling code should
+ * make sure that 'last' is not already in the list.
+ */
+static struct pktgen_interface_info* pg_resort_pginfos(struct pktgen_thread_info* pg_thread,
+                                                       struct pktgen_interface_info* last,
+                                                       int setup_cur_if) {
+        struct pktgen_interface_info* rv = NULL;
+        
+        pg_lock(pg_thread, __FUNCTION__);
+        {
+                struct pktgen_interface_info* p = pg_thread->running_if_infos;
+        
+                if (last) {
+                        if (!last->do_run_run) {
+                                /* If this guy was stopped while 'current', then
+                                 * we'll want to place him on the stopped list
+                                 * here.
+                                 */
+                                last->next = pg_thread->stopped_if_infos;
+                                pg_thread->stopped_if_infos = last;
+                        }
+                        else {
+                                /* re-insert */
+                                if (!p) {
+                                        pg_thread->running_if_infos = last;
+                                        last->next = NULL;
+                                }
+                                else {
+                                        /* Another special case, check to see if we should go at the
+                                         * front of the queue.
+                                         */
+                                        if (p->next_tx_ns > last->next_tx_ns) {
+                                                last->next = p;
+                                                pg_thread->running_if_infos = last;
+                                        }
+                                        else {
+                                                int inserted = 0;
+                                                while (p->next) {
+                                                        if (p->next->next_tx_ns > last->next_tx_ns) {
+                                                                /* Insert into the list */
+                                                                last->next = p->next;
+                                                                p->next = last;
+                                                                inserted = 1;
+                                                                break;
+                                                        }
+                                                        p = p->next;
+                                                }
+                                                if (!inserted) {
+                                                        /* place at the end */
+                                                        last->next = NULL;
+                                                        p->next = last;
+                                                }
+                                        }
+                                }
+                        }
+                }
+
+                /* List is re-sorted, so grab the first one to return */
+                rv = pg_thread->running_if_infos;
+                if (rv) {
+                        /* Pop him off of the list.  We do this here because we already
+                         * have the lock.  Calling code just has to be aware of this
+                         * feature.
+                         */
+                        pg_thread->running_if_infos = rv->next;
+                }
+        }
+
+        if (setup_cur_if) {
+                pg_thread->cur_if = rv;
+        }
+        
+        pg_unlock(pg_thread, __FUNCTION__);
+        return rv;
+}/* pg_resort_pginfos */
+
+
+void pg_stop_all_ifs(struct pktgen_thread_info* pg_thread) {
+        struct pktgen_interface_info* next = NULL;
+
+        pg_lock(pg_thread, __FUNCTION__);
+        if (pg_thread->cur_if) {
+                /* Move it onto the stopped list */
+                pg_stop_interface(pg_thread, pg_thread->cur_if);
+                pg_thread->cur_if->next = pg_thread->stopped_if_infos;
+                pg_thread->stopped_if_infos = pg_thread->cur_if;
+                pg_thread->cur_if = NULL;
+        }
+        pg_unlock(pg_thread, __FUNCTION__);
+
+        /* These have their own locking */
+        next = pg_resort_pginfos(pg_thread, NULL, 0);
+        while (next) {
+                pg_stop_interface(pg_thread, next);
+                next = pg_resort_pginfos(pg_thread, NULL, 0);
+        }
+}/* pg_stop_all_ifs */
+
+
+void pg_rem_all_ifs(struct pktgen_thread_info* pg_thread) {
+        struct pktgen_interface_info* next = NULL;
+        
+        /* Remove all interfaces, clean up memory */
+        while ((next = pg_thread->stopped_if_infos)) {
+                int rv = pg_rem_interface_info(pg_thread, next);
+                if (rv >= 0) {
+                        kfree(next);
+                }
+                else {
+                        printk("ERROR: failed to rem_interface: %i\n", rv);
+                }
+        }
+}/* pg_rem_all_ifs */
+
+
+void pg_rem_from_thread_list(struct pktgen_thread_info* pg_thread) {
+        /* Remove from the thread list */
+        pg_lock_thread_list(__FUNCTION__);
+        {
+                struct pktgen_thread_info* tmp = pktgen_threads;
+                if (tmp == pg_thread) {
+                        pktgen_threads = tmp->next;
+                }
+                else {
+                        while (tmp) {
+                                if (tmp->next == pg_thread) {
+                                        tmp->next = pg_thread->next;
+                                        pg_thread->next = NULL;
+                                        break;
+                                }
+                                tmp = tmp->next;
+                        }
+                }
+        }
+        pg_unlock_thread_list(__FUNCTION__);
+}/* pg_rem_from_thread_list */
 
-	if (total == 0) total = 1;  /* division by zero protection */
- 
-	idle = (((idle_acc_hi<<20)/pg_cpu_speed)<<12)+idle_acc_lo/pg_cpu_speed;
 
-	
-	/* 
-	   Rounding errors is around 1% on pkt_rate when total
-	   is just over 100.000. When total is big (total >=
-	   4.295 sec) pc need to be more than 430 to keep
-	   rounding errors below 1%. Shouldn't be a problem:)
-	   
-	   */
-
-	if (total < 100000) 
-		pkt_rate = (pc*1000000)/total;
-	else if (total < 0xFFFFFFFF/1000)        /* overflow protection: 2^32/1000 */
-		pkt_rate = (pc*1000)/(total/1000);		  
-	else if (total <  0xFFFFFFFF/100)     
-		pkt_rate = (pc*100)/(total/10000);		  
-	else if (total < 0xFFFFFFFF/10)     
-		pkt_rate = (pc*10)/(total/100000);		  
-	else
-		pkt_rate = (pc/(total/1000000));
-	
-	data_rate = (pkt_rate*pkt_size);
-	if (data_rate > 1024*1024 ) {   /* 10 MB/s */
-		data_rate = data_rate / (1024*1024);
-		rate_unit = 'M';
-	} else {
-		data_rate = data_rate / 1024;
-		rate_unit = 'K';
-	}
-	
-	p += sprintf(p, "OK: %u(c%u+d%u) usec, %u (%dbyte,%dfrags) %upps %u%cB/sec",
-		     total, total-idle, idle,
-		     pc, skb->len, skb_shinfo(skb)->nr_frags,
-		     pkt_rate, data_rate, rate_unit
-		);
-	
+/* Main loop of the thread.  Send pkts.
+ */
+void pg_thread_worker(struct pktgen_thread_info* pg_thread) {
+	struct net_device *odev = NULL;
+        __u64 idle_start = 0;
+        struct pktgen_interface_info* next = NULL;
+        u32 next_ipg = 0;
+        u64 now = 0; /* in nano-seconds */
+        u32 tx_since_softirq = 0;
+        
+        /* setup the thread environment */
+        init_pktgen_kthread(pg_thread, "kpktgend");
+        
+        PG_DEBUG(printk("Starting up pktgen thread: %s\n", pg_thread->name));
+        
+        /* an endless loop in which we are doing our work */
+        while (1) {
+
+                /* Re-sorts the list, inserting 'next' (which is really the last one
+                 * we used).  It pops the top one off of the queue and returns it.
+                 * Calling code must make sure to re-insert the returned value
+                 */
+                next = pg_resort_pginfos(pg_thread, next, 1);
+                
+                if (next) {
+
+                        odev = next->odev;
+
+                        if (next->ipg) {
+
+                                now = getRelativeCurNs();
+                                if (now < next->next_tx_ns) {
+                                        next_ipg = (u32)(next->next_tx_ns - now);
+                                        
+                                        /* Try not to busy-spin if we have larger sleep times.
+                                        * TODO:  Investigate better ways to do this.
+                                        */
+                                        if (next_ipg < 10000) { /* 10 usecs or less */
+                                                nanospin(next_ipg, next);
+                                        }
+                                        else if (next_ipg < 10000000) { /* 10ms or less */
+                                                pg_udelay(next_ipg / 1000, next);
+                                        }
+                                        else {
+                                                /* fall asleep for a 10ms or more. */
+                                                pg_udelay(next_ipg / 1000, next);
+                                        }
+                                }
+
+                                /* This is max IPG, this has special meaning of
+                                 * "never transmit"
+                                 */
+                                if (next->ipg == 0x7FFFFFFF) {
+                                        next->next_tx_ns = getRelativeCurNs() + next->ipg;
+                                        continue;
+                                }
+                        }
+                
+                        if (netif_queue_stopped(odev) || current->need_resched) {
+                                
+                                idle_start = get_cycles();
+
+                                if (!netif_running(odev)) {
+                                        pg_stop_interface(pg_thread, next);
+                                        continue;
+                                }
+                                if (current->need_resched) {
+                                        schedule();
+                                }
+                                else {
+                                        do_softirq();
+                                        tx_since_softirq = 0;
+                                }
+                                next->idle_acc += get_cycles() - idle_start;
+
+                                if (netif_queue_stopped(odev)) {
+                                        continue; /* Try the next interface */
+                                }
+                        }
+                        
+                        if (next->last_ok || !next->skb) {
+                                if ((++next->fp_tmp >= next->multiskb ) || (!next->skb)) {
+                                        /* build a new pkt */
+                                        if (next->skb) {
+                                                kfree_skb(next->skb);
+                                        }
+                                        next->skb = fill_packet(odev, next);
+                                        if (next->skb == NULL) {
+                                                printk("ERROR:  Couldn't allocate skb in fill_packet.\n");
+                                                schedule();
+                                                next->fp_tmp--; /* back out increment, OOM */
+                                                continue;
+                                        }
+                                        next->fp++;
+                                        next->fp_tmp = 0; /* reset counter */
+                                        /* Not sure what good knowing nr_frags is...
+                                        next->nr_frags = skb_shinfo(skb)->nr_frags;
+                                        */
+                                }
+                                atomic_inc(&(next->skb->users));
+                        }
+                
+                        spin_lock_bh(&odev->xmit_lock);
+                        if (!netif_queue_stopped(odev)) {
+                                if (odev->hard_start_xmit(next->skb, odev)) {
+                                        if (net_ratelimit()) {
+                                                printk(KERN_INFO "Hard xmit error\n");
+                                        }
+                                        next->errors++;
+                                        next->last_ok = 0;
+                                }
+                                else {
+                                        next->last_ok = 1;
+                                        next->sofar++;
+                                        next->tx_bytes += (next->cur_pkt_size + 4); /* count csum */
+                                }
+
+                                next->next_tx_ns = getRelativeCurNs() + next->ipg;
+                        }
+                        else {  /* Re-try it next time */
+                                next->last_ok = 0;
+                        }
+
+                        spin_unlock_bh(&odev->xmit_lock);
+
+                        if (++tx_since_softirq > pg_thread->max_before_softirq) {
+                                do_softirq();
+                                tx_since_softirq = 0;
+                        }
+
+                        /* If next->count is zero, then run forever */
+                        if ((next->count != 0) && (next->sofar >= next->count)) {
+                                if (atomic_read(&(next->skb->users)) != 1) {
+                                        idle_start = get_cycles();
+                                        while (atomic_read(&(next->skb->users)) != 1) {
+                                                if (signal_pending(current)) {
+                                                        break;
+                                                }
+                                                schedule();
+                                        }
+                                        next->idle_acc += get_cycles() - idle_start;
+                                }
+                                pg_stop_interface(pg_thread, next);
+                        }/* if we're done with a particular interface. */
+
+                }/* if could find the next interface to send on. */
+                else {
+                        /* fall asleep for a bit */
+                        interruptible_sleep_on_timeout(&(pg_thread->queue), HZ/10);
+                }
+                
+                /* here we are back from sleep, either due to the timeout
+                   (one second), or because we caught a signal.
+                */
+                if (pg_thread->terminate || signal_pending(current)) {
+                        /* we received a request to terminate ourself */
+                        break;
+                }
+        }//while true
+
+        /* here we go only in case of termination of the thread */
+
+        PG_DEBUG(printk("pgthread: %s  stopping all Interfaces.\n", pg_thread->name));
+        pg_stop_all_ifs(pg_thread);
+
+        PG_DEBUG(printk("pgthread: %s  removing all Interfaces.\n", pg_thread->name));
+        pg_rem_all_ifs(pg_thread);
+
+        pg_rem_from_thread_list(pg_thread);
+        
+        /* cleanup the thread, leave */
+        PG_DEBUG(printk("pgthread: %s  calling exit_pktgen_kthread.\n", pg_thread->name));
+        exit_pktgen_kthread(pg_thread);
+}
 
-out_relskb:
-	kfree_skb(skb);
-out_reldev:
-        dev_put(odev);
-	return;
-
-out_intr:
-	sprintf(pg_result, "Interrupted");
-	goto out_relskb;
+/* private functions */
+static void kthread_launcher(void *data) {
+        struct pktgen_thread_info *kthread = data;
+        kernel_thread((int (*)(void *))kthread->function, (void *)kthread, 0);       
 }
 
+/* create a new kernel thread. Called by the creator. */
+void start_pktgen_kthread(struct pktgen_thread_info *kthread) {
+
+        /* initialize the semaphore:
+           we start with the semaphore locked. The new kernel
+           thread will setup its stuff and unlock it. This
+           control flow (the one that creates the thread) blocks
+           in the down operation below until the thread has reached
+           the up() operation.
+         */
+        init_MUTEX_LOCKED(&kthread->startstop_sem);
+
+        /* store the function to be executed in the data passed to
+           the launcher */
+        kthread->function = pg_thread_worker;
+        
+        /* create the new thread my running a task through keventd */
+
+        /* initialize the task queue structure */
+        kthread->tq.sync = 0;
+        INIT_LIST_HEAD(&kthread->tq.list);
+        kthread->tq.routine = kthread_launcher;
+        kthread->tq.data = kthread;
+
+        /* and schedule it for execution */
+        schedule_task(&kthread->tq);
+
+        /* wait till it has reached the setup_thread routine */
+        down(&kthread->startstop_sem);
+}
+
+/* stop a kernel thread. Called by the removing instance */
+static void stop_pktgen_kthread(struct pktgen_thread_info *kthread) {
+        PG_DEBUG(printk("pgthread: %s  stop_pktgen_kthread.\n", kthread->name));
+
+        if (kthread->thread == NULL) {
+                printk("stop_kthread: killing non existing thread!\n");
+                return;
+        }
+
+        /* Stop each interface */
+        pg_lock(kthread, __FUNCTION__);
+        {
+                struct pktgen_interface_info* tmp = kthread->running_if_infos;
+                while (tmp) {
+                        tmp->do_run_run = 0;
+                        tmp->next_tx_ns = 0;
+                        tmp = tmp->next;
+                }
+                if (kthread->cur_if) {
+                        kthread->cur_if->do_run_run = 0;
+                        kthread->cur_if->next_tx_ns = 0;
+                }
+        }
+        pg_unlock(kthread, __FUNCTION__);
+
+        /* Wait for everything to fully stop */
+        while (1) {
+                pg_lock(kthread, __FUNCTION__);
+                if (kthread->cur_if || kthread->running_if_infos) {
+                        pg_unlock(kthread, __FUNCTION__);
+                        if (current->need_resched) {
+                                schedule();
+                        }
+                        mdelay(1);
+                }
+                else {
+                        pg_unlock(kthread, __FUNCTION__);
+                        break;
+                }
+        }
+        
+        /* this function needs to be protected with the big
+	   kernel lock (lock_kernel()). The lock must be
+           grabbed before changing the terminate
+	   flag and released after the down() call. */
+        lock_kernel();
+        
+        /* initialize the semaphore. We lock it here, the
+           leave_thread call of the thread to be terminated
+           will unlock it. As soon as we see the semaphore
+           unlocked, we know that the thread has exited.
+	*/
+        init_MUTEX_LOCKED(&kthread->startstop_sem);
+
+        /* We need to do a memory barrier here to be sure that
+           the flags are visible on all CPUs. 
+        */
+        mb();
+
+        /* set flag to request thread termination */
+        kthread->terminate = 1;
+
+        /* We need to do a memory barrier here to be sure that
+           the flags are visible on all CPUs. 
+        */
+        mb();
+        kill_proc(kthread->thread->pid, SIGKILL, 1);
+       
+        /* block till thread terminated */
+        down(&kthread->startstop_sem);
+        kthread->in_use = 0;
+        
+        /* release the big kernel lock */
+        unlock_kernel();
+
+        /* now we are sure the thread is in zombie state. We
+           notify keventd to clean the process up.
+        */
+        kill_proc(2, SIGCHLD, 1);
+
+        PG_DEBUG(printk("pgthread: %s  done with stop_pktgen_kthread.\n", kthread->name));
+}/* stop_pktgen_kthread */
+
+
+/* initialize new created thread. Called by the new thread. */
+void init_pktgen_kthread(struct pktgen_thread_info *kthread, char *name) {
+        /* lock the kernel. A new kernel thread starts without
+           the big kernel lock, regardless of the lock state
+           of the creator (the lock level is *not* inheritated)
+        */
+        lock_kernel();
+
+        /* fill in thread structure */
+        kthread->thread = current;
+
+        /* set signal mask to what we want to respond */
+        siginitsetinv(&current->blocked, sigmask(SIGKILL)|sigmask(SIGINT)|sigmask(SIGTERM));
+
+        /* initialise wait queue */
+        init_waitqueue_head(&kthread->queue);
+
+        /* initialise termination flag */
+        kthread->terminate = 0;
+
+        /* set name of this process (max 15 chars + 0 !) */
+        sprintf(current->comm, name);
+        
+        /* let others run */
+        unlock_kernel();
+
+        /* tell the creator that we are ready and let him continue */
+        up(&kthread->startstop_sem);
+}/* init_pktgen_kthread */
+
+/* cleanup of thread. Called by the exiting thread. */
+static void exit_pktgen_kthread(struct pktgen_thread_info *kthread) {
+        /* we are terminating */
+
+	/* lock the kernel, the exit will unlock it */
+        lock_kernel();
+        kthread->thread = NULL;
+        mb();
+
+        /* Clean up proc file system */
+        if (strlen(kthread->fname)) {
+                remove_proc_entry(kthread->fname, NULL);
+        }
+
+        /* notify the stop_kthread() routine that we are terminating. */
+	up(&kthread->startstop_sem);
+	/* the kernel_thread that called clone() does a do_exit here. */
+
+	/* there is no race here between execution of the "killer" and real termination
+	   of the thread (race window between up and do_exit), since both the
+	   thread and the "killer" function are running with the kernel lock held.
+	   The kernel lock will be freed after the thread exited, so the code
+	   is really not executed anymore as soon as the unload functions gets
+	   the kernel lock back.
+	   The init process may not have made the cleanup of the process here,
+	   but the cleanup can be done safely with the module unloaded.
+	*/
+}/* exit_pktgen_kthread */
+
+
 /* proc/net/pg */
 
-static struct proc_dir_entry *pg_proc_ent = 0;
-static struct proc_dir_entry *pg_busy_proc_ent = 0;
+static char* pg_display_latency(struct pktgen_interface_info* info, char* p, int reset_latency) {
+        int i;
+        p += sprintf(p, "     avg_latency: %dus  min_lat: %dus  max_lat: %dus  pkts_in_sample: %llu\n",
+                     info->avg_latency, info->min_latency, info->max_latency,
+                     info->pkts_rcvd_since_clear);
+        p += sprintf(p, "      Buckets(us) [ ");
+        for (i = 0; i<LAT_BUCKETS_MAX; i++) {
+                p += sprintf(p, "%llu  ", info->latency_bkts[i]);
+        }
+        p += sprintf(p, "]\n");        
+
+        if (reset_latency) {
+                pg_reset_latency_counters(info);
+        }
+        return p;
+}
 
-static int proc_pg_busy_read(char *buf , char **start, off_t offset,
-			     int len, int *eof, void *data)
+static int proc_pg_if_read(char *buf , char **start, off_t offset,
+                           int len, int *eof, void *data)
 {
 	char *p;
-  
+	int i;
+        struct pktgen_interface_info* info = (struct pktgen_interface_info*)(data);
+        __u64 sa;
+        __u64 stopped;
+        __u64 now = getCurUs();
+        __u64 now_rel_ns = getRelativeCurNs();
+        
 	p = buf;
-	p += sprintf(p, "%d\n", pg_busy);
+        p += sprintf(p, "VERSION-1\n"); /* Help with parsing compatibility */
+	p += sprintf(p, "Params: count %llu  min_pkt_size: %u  max_pkt_size: %u\n     frags: %d  ipg: %u  multiskb: %d  ifname: %s\n",
+		     info->count, info->min_pkt_size, info->max_pkt_size,
+                     info->nfrags, info->ipg, info->multiskb, info->ifname);
+        p += sprintf(p, "     dst_min: %s  dst_max: %s\n     src_min: %s  src_max: %s\n",
+                     info->dst_min, info->dst_max, info->src_min, info->src_max);
+        p += sprintf(p, "     src_mac: ");
+	for (i = 0; i < 6; i++) {
+		p += sprintf(p, "%02X%s", info->src_mac[i], i == 5 ? "  " : ":");
+        }
+        p += sprintf(p, "dst_mac: ");
+	for (i = 0; i < 6; i++) {
+		p += sprintf(p, "%02X%s", info->dst_mac[i], i == 5 ? "\n" : ":");
+        }
+        p += sprintf(p, "     udp_src_min: %d  udp_src_max: %d  udp_dst_min: %d  udp_dst_max: %d\n",
+                     info->udp_src_min, info->udp_src_max, info->udp_dst_min,
+                     info->udp_dst_max);
+        p += sprintf(p, "     src_mac_count: %d  dst_mac_count: %d  peer_multiskb: %d\n     Flags: ",
+                     info->src_mac_count, info->dst_mac_count, info->peer_multiskb);
+        if (info->flags &  F_IPSRC_RND) {
+                p += sprintf(p, "IPSRC_RND  ");
+        }
+        if (info->flags & F_IPDST_RND) {
+                p += sprintf(p, "IPDST_RND  ");
+        }
+        if (info->flags & F_TXSIZE_RND) {
+                p += sprintf(p, "TXSIZE_RND  ");
+        }
+        if (info->flags & F_UDPSRC_RND) {
+                p += sprintf(p, "UDPSRC_RND  ");
+        }
+        if (info->flags & F_UDPDST_RND) {
+                p += sprintf(p, "UDPDST_RND  ");
+        }
+        if (info->flags & F_MACSRC_RND) {
+                p += sprintf(p, "MACSRC_RND  ");
+        }
+        if (info->flags & F_MACDST_RND) {
+                p += sprintf(p, "MACDST_RND  ");
+        }
+        p += sprintf(p, "\n");
+        
+        sa = info->started_at;
+        stopped = info->stopped_at;
+        if (info->do_run_run) {
+                stopped = now; /* not really stopped, more like last-running-at */
+        }
+        p += sprintf(p, "Current:\n     pkts-sofar: %llu  errors: %llu\n     started: %lluus  elapsed: %lluus\n     idle: %lluns  next_tx: %llu(%lli)ns\n",
+                     info->sofar, info->errors, sa, (stopped - sa), info->idle_acc,
+                     info->next_tx_ns, (long long)(info->next_tx_ns) - (long long)(now_rel_ns));
+        p += sprintf(p, "     seq_num: %d  cur_dst_mac_offset: %d  cur_src_mac_offset: %d\n",
+                     info->seq_num, info->cur_dst_mac_offset, info->cur_src_mac_offset);
+        p += sprintf(p, "     cur_saddr: 0x%x  cur_daddr: 0x%x  cur_udp_dst: %d  cur_udp_src: %d\n",
+                     info->cur_saddr, info->cur_daddr, info->cur_udp_dst, info->cur_udp_src);
+        p += sprintf(p, "     pkts_rcvd: %llu  bytes_rcvd: %llu  last_seq_rcvd: %d  ooo_rcvd: %llu\n",
+                     info->pkts_rcvd, info->bytes_rcvd, info->last_seq_rcvd, info->ooo_rcvd);
+        p += sprintf(p, "     dup_rcvd: %llu  seq_gap_rcvd(dropped): %llu  non_pg_rcvd: %llu\n",
+                     info->dup_rcvd, info->seq_gap_rcvd, info->non_pg_pkts_rcvd);
+
+        p = pg_display_latency(info, p, 0);
+        
+	if (info->result[0])
+		p += sprintf(p, "Result: %s\n", info->result);
+	else
+		p += sprintf(p, "Result: Idle\n");
 	*eof = 1;
-  
-	return p-buf;
+
+	return p - buf;
 }
 
-static int proc_pg_read(char *buf , char **start, off_t offset,
-			int len, int *eof, void *data)
+
+static int proc_pg_thread_read(char *buf , char **start, off_t offset,
+                               int len, int *eof, void *data)
 {
 	char *p;
-	int i;
-  
+        struct pktgen_thread_info* pg_thread = (struct pktgen_thread_info*)(data);
+        struct pktgen_interface_info* info = NULL;
+
+        if (!pg_thread) {
+                printk("ERROR: could not find pg_thread in proc_pg_thread_read\n");
+                return -EINVAL;
+        }
+        
 	p = buf;
-	p += sprintf(p, "Params: count=%u pkt_size=%u frags %d ipg %u multiskb %d odev \"%s\" dst %s dstmac ",
-		     pg_count, pkt_size, nfrags, pg_ipg, pg_multiskb,
-		     pg_outdev, pg_dst);
-	for (i = 0; i < 6; i++)
-		p += sprintf(p, "%02X%s", pg_dstmac[i], i == 5 ? "\n" : ":");
+        p += sprintf(p, "VERSION-1\n"); /* Help with parsing compatibility */
+	p += sprintf(p, "Name: %s  max_before_softirq: %d\n",
+                     pg_thread->name, pg_thread->max_before_softirq);
+
+        pg_lock(pg_thread, __FUNCTION__);
+        if (pg_thread->cur_if) {
+                p += sprintf(p, "Current: %s\n", pg_thread->cur_if->ifname);
+        }
+        else {
+                p += sprintf(p, "Current: NULL\n");
+        }
+        pg_unlock(pg_thread, __FUNCTION__);
+        
+        p += sprintf(p, "Running: ");
+        
+        pg_lock(pg_thread, __FUNCTION__);
+        info = pg_thread->running_if_infos;
+        while (info) {
+                p += sprintf(p, "%s ", info->ifname);
+                info = info->next;
+        }
+        p += sprintf(p, "\nStopped: ");
+        info = pg_thread->stopped_if_infos;
+        while (info) {
+                p += sprintf(p, "%s ", info->ifname);
+                info = info->next;
+        }
 
-	if (pg_result[0])
-		p += sprintf(p, "Result: %s\n", pg_result);
+	if (pg_thread->result[0])
+		p += sprintf(p, "\nResult: %s\n", pg_thread->result);
 	else
-		p += sprintf(p, "Result: Idle\n");
+		p += sprintf(p, "\nResult: NA\n");
 	*eof = 1;
 
+        pg_unlock(pg_thread, __FUNCTION__);
+
 	return p - buf;
-}
+}/* proc_pg_thread_read */
 
-static int count_trail_chars(const char *buffer, unsigned int maxlen)
+
+static int proc_pg_ctrl_read(char *buf , char **start, off_t offset,
+                             int len, int *eof, void *data)
+{
+	char *p;
+        struct pktgen_thread_info* pg_thread = NULL;
+        
+	p = buf;
+        p += sprintf(p, "VERSION-1\n"); /* Help with parsing compatibility */
+        p += sprintf(p, "Threads: ");
+        
+        pg_lock_thread_list(__FUNCTION__);
+        pg_thread = pktgen_threads;
+        while (pg_thread) {
+                p += sprintf(p, "%s ", pg_thread->name);
+                pg_thread = pg_thread->next;
+        }
+        p += sprintf(p, "\n");
+        
+	*eof = 1;
+
+        pg_unlock_thread_list(__FUNCTION__);
+	return p - buf;
+}/* proc_pg_ctrl_read */
+
+
+static int count_trail_chars(const char *user_buffer, unsigned int maxlen)
 {
 	int i;
 
 	for (i = 0; i < maxlen; i++) {
-		switch (buffer[i]) {
+                char c;
+                if (get_user(c, &user_buffer[i]))
+                        return -EFAULT;
+                switch (c) {
 		case '\"':
 		case '\n':
 		case '\r':
@@ -490,7 +1980,7 @@
 	return i;
 }
 
-static unsigned long num_arg(const char *buffer, unsigned long maxlen, 
+static unsigned long num_arg(const char *user_buffer, unsigned long maxlen, 
 			     unsigned long *num)
 {
 	int i = 0;
@@ -498,21 +1988,27 @@
 	*num = 0;
   
 	for(; i < maxlen; i++) {
-		if ((buffer[i] >= '0') && (buffer[i] <= '9')) {
+                char c;
+                if (get_user(c, &user_buffer[i]))
+                        return -EFAULT;
+                if ((c >= '0') && (c <= '9')) {
 			*num *= 10;
-			*num += buffer[i] -'0';
+			*num += c -'0';
 		} else
 			break;
 	}
 	return i;
 }
 
-static int strn_len(const char *buffer, unsigned int maxlen)
+static int strn_len(const char *user_buffer, unsigned int maxlen)
 {
 	int i = 0;
 
 	for(; i < maxlen; i++) {
-		switch (buffer[i]) {
+                char c;
+                if (get_user(c, &user_buffer[i]))
+                        return -EFAULT;
+                switch (c) {
 		case '\"':
 		case '\n':
 		case '\r':
@@ -526,117 +2022,391 @@
 	return i;
 }
 
-static int proc_pg_write(struct file *file, const char *buffer,
-			 unsigned long count, void *data)
+static int proc_pg_if_write(struct file *file, const char *user_buffer,
+                            unsigned long count, void *data)
 {
 	int i = 0, max, len;
 	char name[16], valstr[32];
 	unsigned long value = 0;
-  
+        struct pktgen_interface_info* info = (struct pktgen_interface_info*)(data);
+        char* pg_result = NULL;
+        int tmp = 0;
+        
+        pg_result = &(info->result[0]);
+        
 	if (count < 1) {
 		sprintf(pg_result, "Wrong command format");
 		return -EINVAL;
 	}
   
 	max = count - i;
-	i += count_trail_chars(&buffer[i], max);
-  
+	tmp = count_trail_chars(&user_buffer[i], max);
+        if (tmp < 0) { return tmp; }
+        i += tmp;
+        
 	/* Read variable name */
 
-	len = strn_len(&buffer[i], sizeof(name) - 1);
+	len = strn_len(&user_buffer[i], sizeof(name) - 1);
+        if (len < 0) { return len; }
 	memset(name, 0, sizeof(name));
-	strncpy(name, &buffer[i], len);
+	copy_from_user(name, &user_buffer[i], len);
 	i += len;
   
 	max = count -i;
-	len = count_trail_chars(&buffer[i], max);
+	len = count_trail_chars(&user_buffer[i], max);
+        if (len < 0) {
+                return len;
+        }
 	i += len;
 
-	if (debug)
-		printk("pg: %s,%lu\n", name, count);
+	if (debug) {
+                char tb[count + 1];
+                copy_from_user(tb, user_buffer, count);
+                tb[count] = 0;
+		printk("pg: %s,%lu  buffer -:%s:-\n", name, count, tb);
+        }
 
-	/* Only stop is allowed when we are running */
-  
 	if (!strcmp(name, "stop")) {
-		forced_stop = 1;
-		if (pg_busy)
+		if (info->do_run_run) {
 			strcpy(pg_result, "Stopping");
+                        pg_stop_interface(info->pg_thread, info);
+                }
+                else {
+                        strcpy(pg_result, "Already stopped...\n");
+                }
 		return count;
 	}
 
-	if (pg_busy) {
-		strcpy(pg_result, "Busy");
-		return -EINVAL;
+	if (!strcmp(name, "min_pkt_size")) {
+		len = num_arg(&user_buffer[i], 10, &value);
+                if (len < 0) { return len; }
+		i += len;
+		if (value < 14+20+8)
+			value = 14+20+8;
+                if (value != info->min_pkt_size) {
+                        info->min_pkt_size = value;
+                        info->cur_pkt_size = value;
+                }
+		sprintf(pg_result, "OK: min_pkt_size=%u", info->min_pkt_size);
+		return count;
 	}
 
-	if (!strcmp(name, "pkt_size")) {
-		len = num_arg(&buffer[i], 10, &value);
+        if (!strcmp(name, "debug")) {
+		len = num_arg(&user_buffer[i], 10, &value);
+                if (len < 0) { return len; }
+		i += len;
+                debug = value;
+		sprintf(pg_result, "OK: debug=%u", debug);
+		return count;
+	}
+
+        if (!strcmp(name, "max_pkt_size")) {
+		len = num_arg(&user_buffer[i], 10, &value);
+                if (len < 0) { return len; }
 		i += len;
 		if (value < 14+20+8)
 			value = 14+20+8;
-		pkt_size = value;
-		sprintf(pg_result, "OK: pkt_size=%u", pkt_size);
+                if (value != info->max_pkt_size) {
+                        info->max_pkt_size = value;
+                        info->cur_pkt_size = value;
+                }
+		sprintf(pg_result, "OK: max_pkt_size=%u", info->max_pkt_size);
 		return count;
 	}
-	if (!strcmp(name, "frags")) {
-		len = num_arg(&buffer[i], 10, &value);
+        
+        if (!strcmp(name, "frags")) {
+		len = num_arg(&user_buffer[i], 10, &value);
+                if (len < 0) { return len; }
 		i += len;
-		nfrags = value;
-		sprintf(pg_result, "OK: frags=%u", nfrags);
+		info->nfrags = value;
+		sprintf(pg_result, "OK: frags=%u", info->nfrags);
 		return count;
 	}
 	if (!strcmp(name, "ipg")) {
-		len = num_arg(&buffer[i], 10, &value);
+		len = num_arg(&user_buffer[i], 10, &value);
+                if (len < 0) { return len; }
+		i += len;
+		info->ipg = value;
+                if ((getRelativeCurNs() + info->ipg) > info->next_tx_ns) {
+                        info->next_tx_ns = getRelativeCurNs() + info->ipg;
+                }
+		sprintf(pg_result, "OK: ipg=%u", info->ipg);
+		return count;
+	}
+ 	if (!strcmp(name, "udp_src_min")) {
+		len = num_arg(&user_buffer[i], 10, &value);
+                if (len < 0) { return len; }
 		i += len;
-		pg_ipg = value;
-		sprintf(pg_result, "OK: ipg=%u", pg_ipg);
+                if (value != info->udp_src_min) {
+                        info->udp_src_min = value;
+                        info->cur_udp_src = value;
+                }       
+		sprintf(pg_result, "OK: udp_src_min=%u", info->udp_src_min);
+		return count;
+	}
+ 	if (!strcmp(name, "udp_dst_min")) {
+		len = num_arg(&user_buffer[i], 10, &value);
+                if (len < 0) { return len; }
+		i += len;
+                if (value != info->udp_dst_min) {
+                        info->udp_dst_min = value;
+                        info->cur_udp_dst = value;
+                }
+		sprintf(pg_result, "OK: udp_dst_min=%u", info->udp_dst_min);
+		return count;
+	}
+ 	if (!strcmp(name, "udp_src_max")) {
+		len = num_arg(&user_buffer[i], 10, &value);
+                if (len < 0) { return len; }
+		i += len;
+                if (value != info->udp_src_max) {
+                        info->udp_src_max = value;
+                        info->cur_udp_src = value;
+                }
+		sprintf(pg_result, "OK: udp_src_max=%u", info->udp_src_max);
+		return count;
+	}
+ 	if (!strcmp(name, "udp_dst_max")) {
+		len = num_arg(&user_buffer[i], 10, &value);
+                if (len < 0) { return len; }
+		i += len;
+                if (value != info->udp_dst_max) {
+                        info->udp_dst_max = value;
+                        info->cur_udp_dst = value;
+                }
+		sprintf(pg_result, "OK: udp_dst_max=%u", info->udp_dst_max);
 		return count;
 	}
 	if (!strcmp(name, "multiskb")) {
-		len = num_arg(&buffer[i], 10, &value);
+		len = num_arg(&user_buffer[i], 10, &value);
+                if (len < 0) { return len; }
 		i += len;
-		pg_multiskb = (value ? 1 : 0);
-		sprintf(pg_result, "OK: multiskb=%d", pg_multiskb);
+                info->multiskb = value;
+	
+		sprintf(pg_result, "OK: multiskb=%d", info->multiskb);
+		return count;
+	}
+	if (!strcmp(name, "peer_multiskb")) {
+		len = num_arg(&user_buffer[i], 10, &value);
+                if (len < 0) { return len; }
+		i += len;
+                info->peer_multiskb = value;
+	
+		sprintf(pg_result, "OK: peer_multiskb=%d", info->peer_multiskb);
 		return count;
 	}
 	if (!strcmp(name, "count")) {
-		len = num_arg(&buffer[i], 10, &value);
+		len = num_arg(&user_buffer[i], 10, &value);
+                if (len < 0) { return len; }
 		i += len;
-		if (value != 0) {
-			pg_count = value;
-			sprintf(pg_result, "OK: count=%u", pg_count);
-		} else 
-			sprintf(pg_result, "ERROR: no point in sending 0 packets. Leaving count=%u", pg_count);
+		info->count = value;
+		sprintf(pg_result, "OK: count=%llu", info->count);
 		return count;
 	}
-	if (!strcmp(name, "odev")) {
-		len = strn_len(&buffer[i], sizeof(pg_outdev) - 1);
-		memset(pg_outdev, 0, sizeof(pg_outdev));
-		strncpy(pg_outdev, &buffer[i], len);
+	if (!strcmp(name, "src_mac_count")) {
+		len = num_arg(&user_buffer[i], 10, &value);
+                if (len < 0) { return len; }
 		i += len;
-		sprintf(pg_result, "OK: odev=%s", pg_outdev);
+		if (info->src_mac_count != value) {
+                        info->src_mac_count = value;
+                        info->cur_src_mac_offset = 0;
+                }
+		sprintf(pg_result, "OK: src_mac_count=%d", info->src_mac_count);
 		return count;
 	}
-	if (!strcmp(name, "dst")) {
-		len = strn_len(&buffer[i], sizeof(pg_dst) - 1);
-		memset(pg_dst, 0, sizeof(pg_dst));
-		strncpy(pg_dst, &buffer[i], len);
+	if (!strcmp(name, "dst_mac_count")) {
+		len = num_arg(&user_buffer[i], 10, &value);
+                if (len < 0) { return len; }
+		i += len;
+		if (info->dst_mac_count != value) {
+                        info->dst_mac_count = value;
+                        info->cur_dst_mac_offset = 0;
+                }
+		sprintf(pg_result, "OK: dst_mac_count=%d", info->dst_mac_count);
+		return count;
+	}
+	if (!strcmp(name, "flag")) {
+                char f[32];
+                memset(f, 0, 32);
+		len = strn_len(&user_buffer[i], sizeof(f) - 1);
+                if (len < 0) { return len; }
+		copy_from_user(f, &user_buffer[i], len);
+		i += len;
+                if (strcmp(f, "IPSRC_RND") == 0) {
+                        info->flags |= F_IPSRC_RND;
+                }
+                else if (strcmp(f, "!IPSRC_RND") == 0) {
+                        info->flags &= ~F_IPSRC_RND;
+                }
+                else if (strcmp(f, "TXSIZE_RND") == 0) {
+                        info->flags |= F_TXSIZE_RND;
+                }
+                else if (strcmp(f, "!TXSIZE_RND") == 0) {
+                        info->flags &= ~F_TXSIZE_RND;
+                }
+                else if (strcmp(f, "IPDST_RND") == 0) {
+                        info->flags |= F_IPDST_RND;
+                }
+                else if (strcmp(f, "!IPDST_RND") == 0) {
+                        info->flags &= ~F_IPDST_RND;
+                }
+                else if (strcmp(f, "UDPSRC_RND") == 0) {
+                        info->flags |= F_UDPSRC_RND;
+                }
+                else if (strcmp(f, "!UDPSRC_RND") == 0) {
+                        info->flags &= ~F_UDPSRC_RND;
+                }
+                else if (strcmp(f, "UDPDST_RND") == 0) {
+                        info->flags |= F_UDPDST_RND;
+                }
+                else if (strcmp(f, "!UDPDST_RND") == 0) {
+                        info->flags &= ~F_UDPDST_RND;
+                }
+                else if (strcmp(f, "MACSRC_RND") == 0) {
+                        info->flags |= F_MACSRC_RND;
+                }
+                else if (strcmp(f, "!MACSRC_RND") == 0) {
+                        info->flags &= ~F_MACSRC_RND;
+                }
+                else if (strcmp(f, "MACDST_RND") == 0) {
+                        info->flags |= F_MACDST_RND;
+                }
+                else if (strcmp(f, "!MACDST_RND") == 0) {
+                        info->flags &= ~F_MACDST_RND;
+                }
+                else {
+                        sprintf(pg_result, "Flag -:%s:- unknown\nAvailable flags, (prepend ! to un-set flag):\n%s",
+                                f,
+                                "IPSRC_RND, IPDST_RND, TXSIZE_RND, UDPSRC_RND, UDPDST_RND, MACSRC_RND, MACDST_RND\n");
+                        return count;
+                }
+		sprintf(pg_result, "OK: flags=0x%x", info->flags);
+		return count;
+	}
+	if (!strcmp(name, "dst_min") || !strcmp(name, "dst")) {
+                char buf[IP_NAME_SZ];
+		len = strn_len(&user_buffer[i], sizeof(info->dst_min) - 1);
+                if (len < 0) { return len; }
+                copy_from_user(buf, &user_buffer[i], len);
+                buf[len] = 0;
+                if (strcmp(buf, info->dst_min) != 0) {
+                        memset(info->dst_min, 0, sizeof(info->dst_min));
+                        strncpy(info->dst_min, buf, len);
+                        info->daddr_min = in_aton(info->dst_min);
+                        info->cur_daddr = info->daddr_min;
+                }
+                if(debug)
+                        printk("pg: dst_min set to: %s\n", info->dst_min);
+                i += len;
+		sprintf(pg_result, "OK: dst_min=%s", info->dst_min);
+		return count;
+	}
+	if (!strcmp(name, "dst_max")) {
+                char buf[IP_NAME_SZ];
+		len = strn_len(&user_buffer[i], sizeof(info->dst_max) - 1);
+                if (len < 0) { return len; }
+                copy_from_user(buf, &user_buffer[i], len);
+                buf[len] = 0;
+                if (strcmp(buf, info->dst_max) != 0) {
+                        memset(info->dst_max, 0, sizeof(info->dst_max));
+                        strncpy(info->dst_max, buf, len);
+                        info->daddr_max = in_aton(info->dst_max);
+                        info->cur_daddr = info->daddr_max;
+                }
+		if(debug)
+			printk("pg: dst_max set to: %s\n", info->dst_max);
+		i += len;
+		sprintf(pg_result, "OK: dst_max=%s", info->dst_max);
+		return count;
+	}
+	if (!strcmp(name, "src_min")) {
+                char buf[IP_NAME_SZ];
+		len = strn_len(&user_buffer[i], sizeof(info->src_min) - 1);
+                if (len < 0) { return len; }
+                copy_from_user(buf, &user_buffer[i], len);
+                buf[len] = 0;
+                if (strcmp(buf, info->src_min) != 0) {
+                        memset(info->src_min, 0, sizeof(info->src_min));
+                        strncpy(info->src_min, buf, len);
+                        info->saddr_min = in_aton(info->src_min);
+                        info->cur_saddr = info->saddr_min;
+                }
+		if(debug)
+			printk("pg: src_min set to: %s\n", info->src_min);
+		i += len;
+		sprintf(pg_result, "OK: src_min=%s", info->src_min);
+		return count;
+	}
+	if (!strcmp(name, "src_max")) {
+                char buf[IP_NAME_SZ];
+		len = strn_len(&user_buffer[i], sizeof(info->src_max) - 1);
+                if (len < 0) { return len; }
+                copy_from_user(buf, &user_buffer[i], len);
+                buf[len] = 0;
+                if (strcmp(buf, info->src_max) != 0) {
+                        memset(info->src_max, 0, sizeof(info->src_max));
+                        strncpy(info->src_max, buf, len);
+                        info->saddr_max = in_aton(info->src_max);
+                        info->cur_saddr = info->saddr_max;
+                }
 		if(debug)
-			printk("pg: dst set to: %s\n", pg_dst);
+			printk("pg: src_max set to: %s\n", info->src_max);
 		i += len;
-		sprintf(pg_result, "OK: dst=%s", pg_dst);
+		sprintf(pg_result, "OK: src_max=%s", info->src_max);
+		return count;
+	}
+	if (!strcmp(name, "dst_mac")) {
+		char *v = valstr;
+                unsigned char old_dmac[6];
+		unsigned char *m = info->dst_mac;
+                memcpy(old_dmac, info->dst_mac, 6);
+                
+		len = strn_len(&user_buffer[i], sizeof(valstr) - 1);
+                if (len < 0) { return len; }
+		memset(valstr, 0, sizeof(valstr));
+		copy_from_user(valstr, &user_buffer[i], len);
+		i += len;
+
+		for(*m = 0;*v && m < info->dst_mac + 6; v++) {
+			if (*v >= '0' && *v <= '9') {
+				*m *= 16;
+				*m += *v - '0';
+			}
+			if (*v >= 'A' && *v <= 'F') {
+				*m *= 16;
+				*m += *v - 'A' + 10;
+			}
+			if (*v >= 'a' && *v <= 'f') {
+				*m *= 16;
+				*m += *v - 'a' + 10;
+			}
+			if (*v == ':') {
+				m++;
+				*m = 0;
+			}
+		}
+
+                if (memcmp(old_dmac, info->dst_mac, 6) != 0) {
+                        /* Set up Dest MAC */
+                        memcpy(&(info->hh[0]), info->dst_mac, 6);
+                }
+                
+		sprintf(pg_result, "OK: dstmac");
 		return count;
 	}
-	if (!strcmp(name, "dstmac")) {
+	if (!strcmp(name, "src_mac")) {
 		char *v = valstr;
-		unsigned char *m = pg_dstmac;
+                unsigned char old_smac[6];
+		unsigned char *m = info->src_mac;
 
-		len = strn_len(&buffer[i], sizeof(valstr) - 1);
+                memcpy(old_smac, info->src_mac, 6);
+		len = strn_len(&user_buffer[i], sizeof(valstr) - 1);
+                if (len < 0) { return len; }
 		memset(valstr, 0, sizeof(valstr));
-		strncpy(valstr, &buffer[i], len);
+		copy_from_user(valstr, &user_buffer[i], len);
 		i += len;
 
-		for(*m = 0;*v && m < pg_dstmac + 6; v++) {
+		for(*m = 0;*v && m < info->src_mac + 6; v++) {
 			if (*v >= '0' && *v <= '9') {
 				*m *= 16;
 				*m += *v - '0';
@@ -654,66 +2424,536 @@
 				*m = 0;
 			}
 		}	  
-		sprintf(pg_result, "OK: dstmac");
+
+                if (memcmp(old_smac, info->src_mac, 6) != 0) {
+                        /* Default to the interface's mac if not explicitly set. */
+                        if ((!(info->flags & F_SET_SRCMAC)) && info->odev) {
+                                memcpy(&(info->hh[6]), info->odev->dev_addr, 6);
+                        }
+                        else {
+                                memcpy(&(info->hh[6]), info->src_mac, 6);
+                        }
+                }
+
+                sprintf(pg_result, "OK: srcmac");
 		return count;
 	}
 
+        if (!strcmp(name, "clear_counters")) {
+                pg_clear_counters(info);
+                sprintf(pg_result, "OK: Clearing counters...\n");
+                return count;
+        }
+        
 	if (!strcmp(name, "inject") || !strcmp(name, "start")) {
-		MOD_INC_USE_COUNT;
-		pg_busy = 1;
-		strcpy(pg_result, "Starting");
-		pg_inject();
-		pg_busy = 0;
-		MOD_DEC_USE_COUNT;
+                if (info->do_run_run) {
+                        strcpy(info->result, "Already running...\n");
+                }
+                else {
+                        int rv;
+                        if ((rv = pg_start_interface(info->pg_thread, info)) >= 0) {
+                                strcpy(info->result, "Starting");
+                        }
+                        else {
+                                sprintf(info->result, "Error starting: %i\n", rv);
+                        }
+                }
 		return count;
 	}
 
-	sprintf(pg_result, "No such parameter \"%s\"", name);
+	sprintf(info->result, "No such parameter \"%s\"", name);
+	return -EINVAL;
+}/* proc_pg_if_write */
+
+
+static int proc_pg_ctrl_write(struct file *file, const char *user_buffer,
+                              unsigned long count, void *data)
+{
+	int i = 0, max, len;
+	char name[16];
+        struct pktgen_thread_info* pg_thread = NULL;
+        
+	if (count < 1) {
+		printk("Wrong command format");
+		return -EINVAL;
+	}
+  
+	max = count - i;
+	len = count_trail_chars(&user_buffer[i], max);
+        if (len < 0) { return len; }
+        i += len;
+        
+	/* Read variable name */
+
+	len = strn_len(&user_buffer[i], sizeof(name) - 1);
+        if (len < 0) { return len; }
+	memset(name, 0, sizeof(name));
+	copy_from_user(name, &user_buffer[i], len);
+	i += len;
+  
+	max = count -i;
+	len = count_trail_chars(&user_buffer[i], max);
+        if (len < 0) { return len; }
+	i += len;
+
+	if (debug)
+		printk("pg_thread: %s,%lu\n", name, count);
+
+	if (!strcmp(name, "stop")) {
+                char f[32];
+                memset(f, 0, 32);
+		len = strn_len(&user_buffer[i], sizeof(f) - 1);
+                if (len < 0) { return len; }
+		copy_from_user(f, &user_buffer[i], len);
+		i += len;
+                pg_thread = pg_find_thread(f);
+                if (pg_thread) {
+                        printk("pktgen INFO: stopping thread: %s\n", pg_thread->name);
+                        stop_pktgen_kthread(pg_thread);
+                }
+                return count;
+	}
+
+        if (!strcmp(name, "start")) {
+                char f[32];
+                memset(f, 0, 32);
+		len = strn_len(&user_buffer[i], sizeof(f) - 1);
+                if (len < 0) { return len; }
+		copy_from_user(f, &user_buffer[i], len);
+		i += len;
+                pg_add_thread_info(f);
+                return count;
+	}
+
+	return -EINVAL;
+}/* proc_pg_ctrl_write */
+
+
+static int proc_pg_thread_write(struct file *file, const char *user_buffer,
+                                unsigned long count, void *data)
+{
+	int i = 0, max, len;
+	char name[16];
+        struct pktgen_thread_info* pg_thread = (struct pktgen_thread_info*)(data);
+        char* pg_result = &(pg_thread->result[0]);
+        unsigned long value = 0;
+        
+	if (count < 1) {
+		sprintf(pg_result, "Wrong command format");
+		return -EINVAL;
+	}
+  
+	max = count - i;
+        len = count_trail_chars(&user_buffer[i], max);
+        if (len < 0) { return len; }
+	i += len;
+  
+	/* Read variable name */
+
+	len = strn_len(&user_buffer[i], sizeof(name) - 1);
+        if (len < 0) { return len; }
+	memset(name, 0, sizeof(name));
+	copy_from_user(name, &user_buffer[i], len);
+	i += len;
+  
+	max = count -i;
+	len = count_trail_chars(&user_buffer[i], max);
+        if (len < 0) { return len; }
+	i += len;
+
+	if (debug) {
+		printk("pg_thread: %s,%lu\n", name, count);
+        }
+        
+        if (!strcmp(name, "add_interface")) {
+                char f[32];
+                memset(f, 0, 32);
+		len = strn_len(&user_buffer[i], sizeof(f) - 1);
+                if (len < 0) { return len; }
+		copy_from_user(f, &user_buffer[i], len);
+		i += len;
+                pg_add_interface_info(pg_thread, f);
+                return count;
+	}
+
+        if (!strcmp(name, "rem_interface")) {
+                struct pktgen_interface_info* info = NULL;
+                char f[32];
+                memset(f, 0, 32);
+                len = strn_len(&user_buffer[i], sizeof(f) - 1);
+                if (len < 0) { return len; }
+                copy_from_user(f, &user_buffer[i], len);
+                i += len;
+                info = pg_find_interface(pg_thread, f);
+                if (info) {
+                        pg_rem_interface_info(pg_thread, info);
+                        return count;
+                }
+                else {
+                        printk("ERROR:  That interface is not found.\n");
+                        return -ENODEV;
+                }
+	}
+
+        if (!strcmp(name, "max_before_softirq")) {
+                len = num_arg(&user_buffer[i], 10, &value);
+                pg_thread->max_before_softirq = value;
+                return count;
+	}
+
+
 	return -EINVAL;
+}/* proc_pg_thread_write */
+
+
+int create_proc_dir(void)
+{
+        int     len;
+        /*  does proc_dir already exists */
+        len = strlen(PG_PROC_DIR);
+
+        for (pg_proc_dir = proc_net->subdir; pg_proc_dir; pg_proc_dir=pg_proc_dir->next) {
+                if ((pg_proc_dir->namelen == len) &&
+                    (! memcmp(pg_proc_dir->name, PG_PROC_DIR, len))) {
+                        break;
+                }
+        }
+        
+        if (!pg_proc_dir) {
+                pg_proc_dir = create_proc_entry(PG_PROC_DIR, S_IFDIR, proc_net);
+        }
+        
+        if (!pg_proc_dir) {
+                return -ENODEV;
+        }
+        
+        return 0;
 }
 
-static int __init pg_init(void)
+int remove_proc_dir(void)
 {
+        remove_proc_entry(PG_PROC_DIR, proc_net);
+        return 0;
+}
+
+static struct pktgen_interface_info* pg_find_interface(struct pktgen_thread_info* pg_thread,
+                                                       const char* ifname) {
+        struct pktgen_interface_info* rv = NULL;
+        pg_lock(pg_thread, __FUNCTION__);
+
+        if (pg_thread->cur_if && (strcmp(pg_thread->cur_if->ifname, ifname) == 0)) {
+                rv = pg_thread->cur_if;
+                goto found;
+        }
+        
+        rv = pg_thread->running_if_infos;
+        while (rv) {
+                if (strcmp(rv->ifname, ifname) == 0) {
+                        goto found;
+                }
+                rv = rv->next;
+        }
+
+        rv = pg_thread->stopped_if_infos;
+        while (rv) {
+                if (strcmp(rv->ifname, ifname) == 0) {
+                        goto found;
+                }
+                rv = rv->next;
+        }
+ found:
+        pg_unlock(pg_thread, __FUNCTION__);
+        return rv;
+}/* pg_find_interface */
+
+
+static int pg_add_interface_info(struct pktgen_thread_info* pg_thread, const char* ifname) {
+        struct pktgen_interface_info* i = pg_find_interface(pg_thread, ifname);
+        if (!i) {
+                i = kmalloc(sizeof(struct pktgen_interface_info), GFP_KERNEL);
+                if (!i) {
+                        return -ENOMEM;
+                }
+                memset(i, 0, sizeof(struct pktgen_interface_info));
+                
+                i->min_pkt_size = ETH_ZLEN;
+                i->max_pkt_size = ETH_ZLEN;
+                i->nfrags = 0;
+                i->multiskb = pg_multiskb_d;
+                i->peer_multiskb = 0;
+                i->ipg = pg_ipg_d;
+                i->count = pg_count_d;
+                i->sofar = 0;
+                i->hh[12] = 0x08; /* fill in protocol.  Rest is filled in later. */
+                i->hh[13] = 0x00;
+                i->udp_src_min = 9; /* sink NULL */
+                i->udp_src_max = 9;
+                i->udp_dst_min = 9;
+                i->udp_dst_max = 9;
+                i->rcv = pktgen_receive;
+
+                strncpy(i->ifname, ifname, 31);
+                sprintf(i->fname, "net/%s/%s", PG_PROC_DIR, ifname);
+
+                if (! pg_setup_interface(i)) {
+                        printk("ERROR: pg_setup_interface failed.\n");
+                        kfree(i);
+                        return -ENODEV;
+                }
+
+                i->proc_ent = create_proc_entry(i->fname, 0600, 0);
+                if (!i->proc_ent) {
+                        printk("pktgen: Error: cannot create %s procfs entry.\n", i->fname);
+                        kfree(i);
+                        return -EINVAL;
+                }
+                i->proc_ent->read_proc = proc_pg_if_read;
+                i->proc_ent->write_proc = proc_pg_if_write;
+                i->proc_ent->data = (void*)(i);
+
+                return add_interface_to_thread(pg_thread, i);
+        }
+        else {
+                printk("ERROR: interface already exists.\n");
+                return -EBUSY;
+        }
+}/* pg_add_interface_info */
+
+
+/* return the first !in_use thread structure */
+static struct pktgen_thread_info* pg_gc_thread_list_helper(void) {
+        struct pktgen_thread_info* rv = NULL;
+        
+        pg_lock_thread_list(__FUNCTION__);
+
+        rv = pktgen_threads;
+        while (rv) {
+                if (!rv->in_use) {
+                        break;
+                }
+                rv = rv->next;
+        }
+        pg_unlock_thread_list(__FUNCTION__);
+        return rv;
+}/* pg_find_thread */
+
+static void pg_gc_thread_list(void) {
+        struct pktgen_thread_info* t = NULL;
+        struct pktgen_thread_info* w = NULL;
+
+        while ((t = pg_gc_thread_list_helper())) {
+                pg_lock_thread_list(__FUNCTION__);
+                if (pktgen_threads == t) {
+                        pktgen_threads = t->next;
+                        kfree(t);
+                }
+                else {
+                        w = pktgen_threads;
+                        while (w) {
+                                if (w->next == t) {
+                                        w->next = t->next;
+                                        t->next = NULL;
+                                        kfree(t);
+                                        break;
+                                }
+                                w = w->next;
+                        }
+                }
+                pg_unlock_thread_list(__FUNCTION__);
+        }
+}/* pg_gc_thread_list */        
+
+
+static struct pktgen_thread_info* pg_find_thread(const char* name) {
+        struct pktgen_thread_info* rv = NULL;
+
+        pg_gc_thread_list();
+        
+        pg_lock_thread_list(__FUNCTION__);
+
+        rv = pktgen_threads;
+        while (rv) {
+                if (strcmp(rv->name, name) == 0) {
+                        break;
+                }
+                rv = rv->next;
+        }
+        pg_unlock_thread_list(__FUNCTION__);
+        return rv;
+}/* pg_find_thread */
+
+
+static int pg_add_thread_info(const char* name) {
+        struct pktgen_thread_info* pg_thread = NULL;
+
+        if (strlen(name) > 31) {
+                printk("pktgen ERROR:  Thread name cannot be more than 31 characters.\n");
+                return -EINVAL;
+        }
+        
+        if (pg_find_thread(name)) {
+                printk("pktgen ERROR: Thread: %s already exists\n", name);
+                return -EINVAL;
+        }
+
+        pg_thread = (struct pktgen_thread_info*)(kmalloc(sizeof(struct pktgen_thread_info), GFP_KERNEL));
+        if (!pg_thread) {
+                printk("pktgen: ERROR: out of memory, can't create new thread.\n");
+                return -ENOMEM;
+        }
+
+        memset(pg_thread, 0, sizeof(struct pktgen_thread_info));
+        strcpy(pg_thread->name, name);
+        spin_lock_init(&(pg_thread->pg_threadlock));
+        pg_thread->in_use = 1;
+        pg_thread->max_before_softirq = 100;
+        
+        sprintf(pg_thread->fname, "net/%s/%s", PG_PROC_DIR, pg_thread->name);
+        pg_thread->proc_ent = create_proc_entry(pg_thread->fname, 0600, 0);
+        if (!pg_thread->proc_ent) {
+                printk("pktgen: Error: cannot create %s procfs entry.\n", pg_thread->fname);
+                kfree(pg_thread);
+                return -EINVAL;
+        }
+        pg_thread->proc_ent->read_proc = proc_pg_thread_read;
+        pg_thread->proc_ent->write_proc = proc_pg_thread_write;
+        pg_thread->proc_ent->data = (void*)(pg_thread);
+
+        pg_thread->next = pktgen_threads;
+        pktgen_threads = pg_thread;
+
+        /* Start the thread running */
+        start_pktgen_kthread(pg_thread);
+        
+        return 0;
+}/* pg_add_thread_info */
+
+
+/* interface_info must be stopped and on the pg_thread stopped list
+ */
+static int pg_rem_interface_info(struct pktgen_thread_info* pg_thread,
+                                 struct pktgen_interface_info* info) {
+        if (info->do_run_run) {
+                printk("WARNING: trying to remove a running interface, stopping it now.\n");
+                pg_stop_interface(pg_thread, info);
+        }
+        
+        /* Diss-associate from the interface */
+        check_remove_device(info);
+        
+        /* Clean up proc file system */
+        if (strlen(info->fname)) {
+                remove_proc_entry(info->fname, NULL);
+        }
+        
+        pg_lock(pg_thread, __FUNCTION__);
+        {
+                /* Remove from the stopped list */
+                struct pktgen_interface_info* p = pg_thread->stopped_if_infos;
+                if (p == info) {
+                        pg_thread->stopped_if_infos = p->next;
+                        p->next = NULL;
+                }
+                else {
+                        while (p) {
+                                if (p->next == info) {
+                                        p->next = p->next->next;
+                                        info->next = NULL;
+                                        break;
+                                }
+                                p = p->next;
+                        }
+                }
+                
+                info->pg_thread = NULL;
+        }
+        pg_unlock(pg_thread, __FUNCTION__);
+        
+        return 0;
+}/* pg_rem_interface_info */
+
+
+static int __init pg_init(void) {
+        int i;
 	printk(version);
+
+        /* Initialize our global variables */
+        for (i = 0; i<PG_INFO_HASH_MAX; i++) {
+                pg_info_hash[i] = NULL;
+        }
+        module_fname[0] = 0;
+        
+        if (handle_pktgen_hook) {
+                printk("pktgen: ERROR: pktgen is already loaded it seems..\n");
+                /* Already loaded */
+                return -EEXIST;
+        }
+
 	cycles_calibrate();
-	if (pg_cpu_speed == 0) {
+	if (pg_cycles_per_us == 0) {
 		printk("pktgen: Error: your machine does not have working cycle counter.\n");
 		return -EINVAL;
 	}
-	pg_proc_ent = create_proc_entry("net/pg", 0600, 0);
-	if (!pg_proc_ent) {
-		printk("pktgen: Error: cannot create net/pg procfs entry.\n");
-		return -ENOMEM;
-	}
-	pg_proc_ent->read_proc = proc_pg_read;
-	pg_proc_ent->write_proc = proc_pg_write;
-	pg_proc_ent->data = 0;
-
-	pg_busy_proc_ent = create_proc_entry("net/pg_busy", 0, 0);
-	if (!pg_busy_proc_ent) {
-		printk("pktgen: Error: cannot create net/pg_busy procfs entry.\n");
-		remove_proc_entry("net/pg", NULL);
-		return -ENOMEM;
-	}
-	pg_busy_proc_ent->read_proc = proc_pg_busy_read;
-	pg_busy_proc_ent->data = 0;
 
-	return 0;
-}
+	create_proc_dir();
+
+        sprintf(module_fname, "net/%s/pgctrl", PG_PROC_DIR);
+        module_proc_ent = create_proc_entry(module_fname, 0600, 0);
+        if (!module_proc_ent) {
+                printk("pktgen: Error: cannot create %s procfs entry.\n", module_fname);
+                return -EINVAL;
+        }
+        module_proc_ent->read_proc = proc_pg_ctrl_read;
+        module_proc_ent->write_proc = proc_pg_ctrl_write;
+        module_proc_ent->proc_fops = &(pktgen_fops); /* IOCTL hook */
+        module_proc_ent->data = NULL;
+
+	/* Register us to receive netdevice events */
+	register_netdevice_notifier(&pktgen_notifier_block);
+        
+        /* Register handler */
+        handle_pktgen_hook = pktgen_receive;
+
+        for (i = 0; i<pg_thread_count; i++) {
+                char buf[30];
+                sprintf(buf, "kpktgend_%i", i);
+                pg_add_thread_info(buf);
+        }
+                
+        
+        return 0;        
+}/* pg_init */
+
 
 static void __exit pg_cleanup(void)
 {
-	remove_proc_entry("net/pg", NULL);
-	remove_proc_entry("net/pg_busy", NULL);
+        /* Un-register handler */
+        handle_pktgen_hook = NULL;
+
+        /* Stop all interfaces & threads */        
+        while (pktgen_threads) {
+                stop_pktgen_kthread(pktgen_threads);
+        }
+        
+        /* Un-register us from receiving netdevice events */
+	unregister_netdevice_notifier(&pktgen_notifier_block);
+
+        /* Clean up proc file system */
+        remove_proc_entry(module_fname, NULL);
+        
+	remove_proc_dir();
+
 }
 
+
 module_init(pg_init);
 module_exit(pg_cleanup);
 
-MODULE_AUTHOR("Robert Olsson <robert.olsson@its.uu.se");
+MODULE_AUTHOR("Robert Olsson <robert.olsson@its.uu.se, Ben Greear<greearb@candelatech.com>");
 MODULE_DESCRIPTION("Packet Generator tool");
 MODULE_LICENSE("GPL");
-MODULE_PARM(pg_count, "i");
-MODULE_PARM(pg_ipg, "i");
-MODULE_PARM(pg_cpu_speed, "i");
-MODULE_PARM(pg_multiskb, "i");
+MODULE_PARM(pg_count_d, "i");
+MODULE_PARM(pg_ipg_d, "i");
+MODULE_PARM(pg_thread_count, "i");
+MODULE_PARM(pg_multiskb_d, "i");
+MODULE_PARM(debug, "i");
--- linux-2.4.19/net/core/pktgen.h	Wed Dec 31 17:00:00 1969
+++ linux-2.4.19.dev/net/core/pktgen.h	Mon Sep 16 23:53:55 2002
@@ -0,0 +1,240 @@
+/* -*-linux-c-*-
+ * $Id: pg_2.4.19.patch,v 1.5 2002/09/17 07:01:55 greear Exp $
+ * pktgen.c: Packet Generator for performance evaluation.
+ *
+ * See pktgen.c for details of changes, etc.
+*/
+
+
+#ifndef PKTGEN_H_INCLUDE_KERNEL__
+#define PKTGEN_H_INCLUDE_KERNEL__
+
+
+/* The buckets are exponential in 'width' */
+#define LAT_BUCKETS_MAX 32
+
+#define IP_NAME_SZ 32
+
+/* Keep information per interface */
+struct pktgen_interface_info {
+        char ifname[32];
+        
+        /* Parameters */
+
+        /* If min != max, then we will either do a linear iteration, or
+         * we will do a random selection from within the range.
+         */
+        __u32 flags;     
+
+#define F_IPSRC_RND   (1<<0)  /* IP-Src Random  */
+#define F_IPDST_RND   (1<<1)  /* IP-Dst Random  */
+#define F_UDPSRC_RND  (1<<2)  /* UDP-Src Random */
+#define F_UDPDST_RND  (1<<3)  /* UDP-Dst Random */
+#define F_MACSRC_RND  (1<<4)  /* MAC-Src Random */
+#define F_MACDST_RND  (1<<5)  /* MAC-Dst Random */
+#define F_SET_SRCMAC  (1<<6)  /* Specify-Src-Mac 
+				 (default is to use Interface's MAC Addr) */
+#define F_SET_SRCIP   (1<<7)  /*  Specify-Src-IP
+				  (default is to use Interface's IP Addr) */ 
+#define F_TXSIZE_RND  (1<<8)  /* Transmit size is random */
+
+        int min_pkt_size;    /* = ETH_ZLEN; */
+        int max_pkt_size;    /* = ETH_ZLEN; */
+        int nfrags;
+        __u32 ipg;    /* Default Interpacket gap in nsec */
+        __u64 count;  /* Default No packets to send */
+        __u64 sofar;  /* How many pkts we've sent so far */
+        __u64 tx_bytes; /* How many bytes we've transmitted */
+        __u64 errors;    /* Errors when trying to transmit, pkts will be re-sent */
+
+        /* runtime counters relating to multiskb */
+        __u64 next_tx_ns;          /* timestamp of when to tx next, in nano-seconds */
+        
+        __u64 fp;
+        __u32 fp_tmp;
+	int last_ok;           /* Was last skb sent? 
+	                        * Or a failed transmit of some sort?  This will keep
+                                * sequence numbers in order, for example.
+                                */
+        /* Fields relating to receiving pkts */
+        __u32 last_seq_rcvd;
+        __u64 ooo_rcvd;  /* out-of-order packets received */
+        __u64 pkts_rcvd; /* packets received */
+        __u64 dup_rcvd;  /* duplicate packets received */
+        __u64 bytes_rcvd; /* total bytes received, as obtained from the skb */
+        __u64 seq_gap_rcvd; /* how many gaps we received.  This coorelates to
+                             * dropped pkts, except perhaps in cases where we also
+                             * have re-ordered pkts.  In that case, you have to tie-break
+                             * by looking at send v/s received pkt totals for the interfaces
+                             * involved.
+                             */
+        __u64 non_pg_pkts_rcvd; /* Count how many non-pktgen skb's we are sent to check. */
+        __u64 dup_since_incr; /* How many dumplicates since the last seq number increment,
+                               * used to detect gaps when multiskb > 1
+                               */
+        int avg_latency; /* in micro-seconds */
+        int min_latency;
+        int max_latency;
+        __u64 latency_bkts[LAT_BUCKETS_MAX];
+        __u64 pkts_rcvd_since_clear; /* with regard to clearing/resetting the latency logic */
+        
+        __u64 started_at; /* micro-seconds */
+        __u64 stopped_at; /* micro-seconds */
+        __u64 idle_acc;
+        __u32 seq_num;
+        
+        int multiskb; /* Use multiple SKBs during packet gen.  If this number
+                          * is greater than 1, then that many coppies of the same
+                          * packet will be sent before a new packet is allocated.
+                          * For instance, if you want to send 1024 identical packets
+                          * before creating a new packet, set multiskb to 1024.
+                          */
+        int peer_multiskb; /* Helps detect drops when multiskb > 1 on peer */
+        int do_run_run;  /* if this changes to false, the test will stop */
+        
+        char dst_min[IP_NAME_SZ]; /* IP, ie 1.2.3.4 */
+        char dst_max[IP_NAME_SZ]; /* IP, ie 1.2.3.4 */
+        char src_min[IP_NAME_SZ]; /* IP, ie 1.2.3.4 */
+        char src_max[IP_NAME_SZ]; /* IP, ie 1.2.3.4 */
+
+        /* If we're doing ranges, random or incremental, then this
+         * defines the min/max for those ranges.
+         */
+        __u32 saddr_min; /* inclusive, source IP address */
+        __u32 saddr_max; /* exclusive, source IP address */
+        __u32 daddr_min; /* inclusive, dest IP address */
+        __u32 daddr_max; /* exclusive, dest IP address */
+
+        __u16 udp_src_min; /* inclusive, source UDP port */
+        __u16 udp_src_max; /* exclusive, source UDP port */
+        __u16 udp_dst_min; /* inclusive, dest UDP port */
+        __u16 udp_dst_max; /* exclusive, dest UDP port */
+
+        __u32 src_mac_count; /* How many MACs to iterate through */
+        __u32 dst_mac_count; /* How many MACs to iterate through */
+        
+        unsigned char dst_mac[6];
+        unsigned char src_mac[6];
+        
+        __u32 cur_dst_mac_offset;
+        __u32 cur_src_mac_offset;
+        __u32 cur_saddr;
+        __u32 cur_daddr;
+        __u16 cur_udp_dst;
+        __u16 cur_udp_src;
+        __u32 cur_pkt_size;
+        
+        __u8 hh[14];
+        /* = { 
+           0x00, 0x80, 0xC8, 0x79, 0xB3, 0xCB, 
+           
+           We fill in SRC address later
+           0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+           0x08, 0x00
+           };
+        */
+        __u16 pad; /* pad out the hh struct to an even 16 bytes */
+        char result[512];
+        /* proc file names */
+        char fname[80];
+
+        /* End of stuff that user-space should care about */
+
+        struct sk_buff* skb; /* skb we are to transmit next, mainly used for when we
+                              * are transmitting the same one multiple times
+                              */
+        struct pktgen_thread_info* pg_thread; /* the owner */
+
+        struct pktgen_interface_info* next_hash; /* Used for chaining in the hash buckets */
+        struct pktgen_interface_info* next; /* Used for chaining in the thread's run-queue */
+
+        
+
+        struct net_device* odev; /* The out-going device.  Note that the device should
+                                  * have it's pg_info pointer pointing back to this
+                                  * device.  This will be set when the user specifies
+                                  * the out-going device name (not when the inject is
+                                  * started as it used to do.)
+                                  */
+        
+        struct proc_dir_entry *proc_ent;
+        
+        int (*rcv) (struct sk_buff *skb);
+}; /* pktgen_interface_info */
+
+
+struct pktgen_hdr {
+        __u32 pgh_magic;
+        __u32 seq_num;
+        struct timeval timestamp;
+};
+
+
+/* Define some IOCTLs.  Just picking random numbers, basically. */
+#define GET_PKTGEN_INTERFACE_INFO 0x7450
+
+struct pktgen_ioctl_info {
+        char thread_name[32];
+        char interface_name[32];
+        struct pktgen_interface_info info;
+};
+
+
+struct pktgen_thread_info {
+        struct pktgen_interface_info* running_if_infos; /* list of running interfaces, current will
+                                                         * not be in this list.
+                                                         */
+        struct pktgen_interface_info* stopped_if_infos; /* list of stopped interfaces. */
+        struct pktgen_interface_info* cur_if;           /* Current (running) interface we are servicing in
+                                                         * the main thread loop.
+                                                         */
+
+        struct pktgen_thread_info* next;
+        char name[32];
+        char fname[128]; /* name of proc file */
+        struct proc_dir_entry *proc_ent;
+        char result[512];
+        u32 max_before_softirq; /* We'll call do_softirq to prevent starvation. */
+        
+        spinlock_t pg_threadlock;
+        
+        /* Linux task structure of thread */
+        struct task_struct *thread;
+        
+        /* Task queue need to launch thread */
+        struct tq_struct tq;
+        
+        /* function to be started as thread */
+        void (*function) (struct pktgen_thread_info *kthread);
+        
+        /* semaphore needed on start and creation of thread. */
+        struct semaphore startstop_sem;
+
+        /* public data */
+
+        /* queue thread is waiting on. Gets initialized by
+           init_kthread, can be used by thread itself.
+        */
+        wait_queue_head_t queue;
+        
+        /* flag to tell thread whether to die or not.
+           When the thread receives a signal, it must check
+           the value of terminate and call exit_kthread and terminate
+           if set.
+        */
+        int terminate;
+
+        int in_use; /* if 0, then we can delete or re-use this struct */
+        
+        /* additional data to pass to kernel thread */
+        void *arg;
+};/* struct pktgen_thread_info */
+
+/* Defined in dev.c */
+extern int (*handle_pktgen_hook)(struct sk_buff *skb);
+
+/* Returns < 0 if the skb is not a pktgen buffer. */
+int pktgen_receive(struct sk_buff* skb);
+
+
+#endif
--- linux-2.4.19/net/netsyms.c	Fri Aug  2 17:39:46 2002
+++ linux-2.4.19.dev/net/netsyms.c	Sat Sep 14 21:55:39 2002
@@ -90,6 +90,14 @@
 extern int sysctl_max_syn_backlog;
 #endif
 
+#ifdef CONFIG_NET_PKTGEN_MODULE
+#warning "EXPORT_SYMBOL(handle_pktgen_hook);";
+extern int (*handle_pktgen_hook)(struct sk_buff *skb);
+/* Would be OK to export as EXPORT_SYMBOL_GPL, but can't get that to work for
+ * some reason. --Ben */
+EXPORT_SYMBOL(handle_pktgen_hook);
+#endif
+
 /* Skbuff symbols. */
 EXPORT_SYMBOL(skb_over_panic);
 EXPORT_SYMBOL(skb_under_panic);
@@ -416,6 +424,9 @@
 EXPORT_SYMBOL(netlink_kernel_create);
 EXPORT_SYMBOL(netlink_dump_start);
 EXPORT_SYMBOL(netlink_ack);
+EXPORT_SYMBOL(netlink_set_nonroot);
+EXPORT_SYMBOL(netlink_register_notifier);
+EXPORT_SYMBOL(netlink_unregister_notifier);
 #if defined(CONFIG_NETLINK_DEV) || defined(CONFIG_NETLINK_DEV_MODULE)
 EXPORT_SYMBOL(netlink_attach);
 EXPORT_SYMBOL(netlink_detach);
@@ -490,6 +501,7 @@
 EXPORT_SYMBOL(skb_clone);
 EXPORT_SYMBOL(skb_copy);
 EXPORT_SYMBOL(netif_rx);
+EXPORT_SYMBOL(netif_receive_skb);
 EXPORT_SYMBOL(dev_add_pack);
 EXPORT_SYMBOL(dev_remove_pack);
 EXPORT_SYMBOL(dev_get);
@@ -588,4 +600,9 @@
 EXPORT_SYMBOL(net_call_rx_atomic);
 EXPORT_SYMBOL(softnet_data);
 
+#if defined(CONFIG_NET_RADIO) || defined(CONFIG_NET_PCMCIA_RADIO)
+#include <net/iw_handler.h>
+EXPORT_SYMBOL(wireless_send_event);
+#endif /* CONFIG_NET_RADIO || CONFIG_NET_PCMCIA_RADIO */
+
 #endif  /* CONFIG_NET */
--- linux-2.4.19/Documentation/networking/pktgen.txt	Fri Aug  2 17:39:42 2002
+++ linux-2.4.19.dev/Documentation/networking/pktgen.txt	Sat Sep 14 21:42:29 2002
@@ -1,50 +1,118 @@
 How to use the Linux packet generator module.
 
-1. Enable CONFIG_NET_PKTGEN to compile and build pktgen.o, install it
-   in the place where insmod may find it.
-2. Cut script "ipg" (see below).
-3. Edit script to set preferred device and destination IP address.
-4. Run in shell: ". ipg"
-5. After this two commands are defined:
-   A. "pg" to start generator and to get results.
-   B. "pgset" to change generator parameters. F.e.
-      pgset "multiskb 1"      use multiple SKBs for packet generation
-      pgset "multiskb 0"      use single SKB for all transmits
-      pgset "pkt_size 9014"   sets packet size to 9014
-      pgset "frags 5"         packet will consist of 5 fragments
-      pgset "count 200000"    sets number of packets to send
-      pgset "ipg 5000"        sets artificial gap inserted between packets
-                              to 5000 nanoseconds
-      pgset "dst 10.0.0.1"    sets IP destination address
-                              (BEWARE! This generator is very aggressive!)
-      pgset "dstmac 00:00:00:00:00:00"    sets MAC destination address
-      pgset stop    	      aborts injection
+1.  Enable CONFIG_NET_PKTGEN to compile and build pktgen.o, install it
+     in the place where insmod may find it.
+2.  Add an interface to the kpktgend_0 thread:
+     echo "add_interface eth1" > /proc/net/pktgen/kpktgend_0
+2a. Add more interfaces as needed.
+3.  Configure interfaces by setting values as defined below.  The
+     general strategy is: echo "command" > /proc/net/pktgen/[device]
+     For example: echo "multiskb 100" > /proc/net/pktgen/eth1
+
+      "multiskb 100"    Will send 100 identical pkts before creating
+                              new packet with new timestamp, etc.
+      "multiskb 0"      Will create new skb for all transmits.
+      "peer_multiskb 100"   Helps us determine dropped & dup pkts, sender's multiskb.
+      "min_pkt_size 60"     sets packet minimum size to 60 (64 counting CRC)
+      "max_pkt_size 1514"   sets packet size to 1514 (1518 counting CRC)
+      "frags 5"         packet will consist of 5 fragments
+      "count 200000"    sets number of packets to send, set to zero
+                         for continious sends untill explicitly
+                         stopped.
+      "ipg 5000"        sets artificial gap inserted between packets
+                         to 5000 nanoseconds
+      "dst 10.0.0.1"    sets IP destination address
+                         (BEWARE! This generator is very aggressive!)
+      "dst_min 10.0.0.1"            Same as dst
+      "dst_max 10.0.0.254"          Set the maximum destination IP.
+      "src_min 10.0.0.1"            Set the minimum (or only) source IP.
+      "src_max 10.0.0.254"          Set the maximum source IP.
+      "dst_mac 00:00:00:00:00:00"   sets MAC destination address
+      "src_mac 00:00:00:00:00:00"   sets MAC source address
+      "src_mac_count 1" Sets the number of MACs we'll range through.  The
+                         'minimum' MAC is what you set with srcmac.
+      "dst_mac_count 1" Sets the number of MACs we'll range through.  The
+                         'minimum' MAC is what you set with dstmac.
+      "flag [name]"     Set a flag to determine behaviour.  Prepend '!' to the
+                         flag to turn it off.  Current flags are:
+                          IPSRC_RND #IP Source is random (between min/max),
+                          IPDST_RND, UDPSRC_RND, TXSIZE_RND
+                          UDPDST_RND, MACSRC_RND, MACDST_RND 
+      "udp_src_min 9"   set UDP source port min, If < udp_src_max, then
+                         cycle through the port range.
+      "udp_src_max 9"   set UDP source port max.
+      "udp_dst_min 9"   set UDP destination port min, If < udp_dst_max, then
+                         cycle through the port range.
+      "udp_dst_max 9"   set UDP destination port max.
+      "stop"            Stops this interface from transmitting.  It will still
+                         receive packets and record their latency, etc.
+      "start"           Starts the interface transmitting packets.
+      "clear_counters"  Clear the packet and latency counters.
+
+You can start and stop threads by echoing commands to the /proc/net/pktgen/pgctrl
+file.  Supported commands are:
+      "stop kpktgend_0"  Stop thread 0.
+      "start threadXX"   Start (create) thread XX.  You may wish to create one thread
+                          per CPU.
       
-  Also, ^C aborts generator.
 
----- cut here
+You can control manage the interfaces on a thread by echoing commands to
+the /proc/net/pktgen/[thread] file.  Supported commands are:
+      "add_interface eth1"  Add interface eth1 to the chosen thread.
+      "rem_interface eth1"  Remove interface eth1 from the chosen thread.
+      "max_before_softirq"  Maximum loops before we cause a call to do_softirq,
+                             this is to help mitigate starvatation on the RX side.
+
+
+You can examine various counters and parameters by reading the appropriate
+proc file:
+
+[root@localhost lanforge]# cat /proc/net/pktgen/kpktgend_0 
+VERSION-1
+Name: kpktgend_0
+Current: eth2
+Running: eth6 
+Stopped: eth1 eth5 
+Result: NA
+
+
+[root@localhost lanforge]# cat /proc/net/pktgen/eth2
+VERSION-1
+Params: count 0  pkt_size: 300  frags: 0  ipg: 0  multiskb: 0 ifname "eth2"
+     dst_min: 172.2.1.1  dst_max: 172.2.1.6  src_min: 172.1.1.4  src_max: 172.1.1.8
+     src_mac: 00:00:00:00:00:00  dst_mac: 00:00:00:00:00:00
+     udp_src_min: 99  udp_src_max: 1005  udp_dst_min: 9  udp_dst_max: 9
+     src_mac_count: 0  dst_mac_count: 0
+     Flags: IPSRC_RND  IPDST_RND  UDPSRC_RND  
+Current:
+     pkts-sofar: 158835950  errors: 0
+     started: 1026024703542360us  elapsed: 4756326418us
+     idle: 1723232054307ns  next_tx: 27997154666566(-3202934)ns
+     seq_num: 158835951  cur_dst_mac_offset: 0  cur_src_mac_offset: 0
+     cur_saddr: 0x60101ac  cur_daddr: 0x30102ac  cur_udp_dst: 9  cur_udp_src: 966
+     pkts_rcvd: 476002  bytes_rcvd: 159929440  last_seq_rcvd: 476002  ooo_rcvd: 0
+     dup_rcvd: 0  seq_gap_rcvd(dropped): 0  non_pg_rcvd: 0
+     avg_latency: 41us  min_latency: 40us  max_latency: 347us  pkts_in_sample: 476002
+      Buckets(us) [ 0  0  0  0  0  0  311968  164008  23  3  0  0  0  0  0  0  0  0  0  0  ]
+Result: OK: ipg=0
+
+[root@localhost lanforge]# cat /proc/net/pktgen/eth6
+VERSION-1
+Params: count 0  pkt_size: 300  frags: 0  ipg: 11062341  multiskb: 0 ifname "eth6"
+     dst_min: 90  dst_max: 90  src_min: 90  src_max: 90
+     src_mac: 00:00:00:00:00:00  dst_mac: 00:00:00:00:00:00
+     udp_src_min: 9  udp_src_max: 9  udp_dst_min: 9  udp_dst_max: 9
+     src_mac_count: 0  dst_mac_count: 0
+     Flags: 
+Current:
+     pkts-sofar: 479940  errors: 0
+     started: 1026024703542707us  elapsed: 4795667656us
+     idle: 109585100905ns  next_tx: 28042807786397(-79364)ns
+     seq_num: 479941  cur_dst_mac_offset: 0  cur_src_mac_offset: 0
+     cur_saddr: 0x0  cur_daddr: 0x0  cur_udp_dst: 9  cur_udp_src: 9
+     pkts_rcvd: 160323509  bytes_rcvd: 50392479910  last_seq_rcvd: 160323509  ooo_rcvd: 0
+     dup_rcvd: 0  seq_gap_rcvd(dropped): 0  non_pg_rcvd: 0
+     avg_latency: 230us  min_latency: 36us  max_latency: 1837us  pkts_in_sample: 160323509
+      Buckets(us) [ 0  0  0  0  0  0  287725  2618755  54130607  98979415  80358  4226649  0  0  0  0  0  0  0  0  ]
+Result: OK: ipg=11062341
 
-#! /bin/sh
-
-modprobe pktgen.o
-
-function pgset() {
-    local result
-
-    echo $1 > /proc/net/pg
-
-    result=`cat /proc/net/pg | fgrep "Result: OK:"`
-    if [ "$result" = "" ]; then
-         cat /proc/net/pg | fgrep Result:
-    fi
-}
-
-function pg() {
-    echo inject > /proc/net/pg
-    cat /proc/net/pg
-}
-
-pgset "odev eth0"
-pgset "dst 0.0.0.0"
-
----- cut here

--------------030304010606000406080300--
