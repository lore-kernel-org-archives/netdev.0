From: Joe Perches <joe@perches.com>
Subject: [PATCH] net/core: Convert to current logging forms
Date: Tue, 28 Jun 2011 12:40:10 -0700
Message-ID: <385ebf7e98e377e6e6c384beb961b65d4a95fb18.1309289792.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3253 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752184Ab1F1TkQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2011 15:40:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use pr_fmt, pr_<level>, and netdev_<level> as appropriate.

Coalesce long formats.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/core/dev.c           |  121 +++++++++++++++++++---------------------------
 net/core/drop_monitor.c  |   10 ++--
 net/core/neighbour.c     |   15 +++---
 net/core/net_namespace.c |    6 ++-
 net/core/netpoll.c       |   60 +++++++++++-----------
 net/core/pktgen.c        |   27 +++++-----
 net/core/rtnetlink.c     |    9 ++--
 net/core/skbuff.c        |   24 ++++------
 net/core/sock.c          |   21 ++++----
 9 files changed, 136 insertions(+), 157 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 6b6ef14..3401227 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -72,6 +72,8 @@
  *				        - netif_rx() feedback
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <asm/uaccess.h>
 #include <asm/system.h>
 #include <linux/bitops.h>
@@ -433,7 +435,7 @@ void __dev_remove_pack(struct packet_type *pt)
 		}
 	}
 
-	printk(KERN_WARNING "dev_remove_pack: %p not found.\n", pt);
+	pr_warn("dev_remove_pack: %p not found\n", pt);
 out:
 	spin_unlock(&ptype_lock);
 }
@@ -1026,9 +1028,8 @@ rollback:
 			memcpy(dev->name, oldname, IFNAMSIZ);
 			goto rollback;
 		} else {
-			printk(KERN_ERR
-			       "%s: name change rollback failed: %d.\n",
-			       dev->name, ret);
+			netdev_err(dev, "name change rollback failed: %d\n",
+				   ret);
 		}
 	}
 
@@ -1126,9 +1127,10 @@ void dev_load(struct net *net, const char *name)
 		no_module = request_module("netdev-%s", name);
 	if (no_module && capable(CAP_SYS_MODULE)) {
 		if (!request_module("%s", name))
-			pr_err("Loading kernel module for a network device "
-"with CAP_SYS_MODULE (deprecated).  Use CAP_NET_ADMIN and alias netdev-%s "
-"instead\n", name);
+			pr_err(
+"Loading kernel module for a network device with CAP_SYS_MODULE (deprecated)\n"
+"Use CAP_NET_ADMIN and alias netdev-%s instead\n",
+			       name);
 	}
 }
 EXPORT_SYMBOL(dev_load);
@@ -1569,10 +1571,8 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
 			if (skb_network_header(skb2) < skb2->data ||
 			    skb2->network_header > skb2->tail) {
 				if (net_ratelimit())
-					printk(KERN_CRIT "protocol %04x is "
-					       "buggy, dev %s\n",
-					       ntohs(skb2->protocol),
-					       dev->name);
+					netdev_crit(dev, "protocol %04x is buggy\n",
+						    ntohs(skb2->protocol));
 				skb_reset_network_header(skb2);
 			}
 
@@ -1605,9 +1605,7 @@ static void netif_setup_tc(struct net_device *dev, unsigned int txq)
 
 	/* If TC0 is invalidated disable TC mapping */
 	if (tc->offset + tc->count > txq) {
-		pr_warning("Number of in use tx queues changed "
-			   "invalidating tc mappings. Priority "
-			   "traffic classification disabled!\n");
+		netdev_warn(dev, "Number of in use tx queues changed invalidating tc mappings. Priority traffic classification disabled!\n");
 		dev->num_tc = 0;
 		return;
 	}
@@ -1618,11 +1616,8 @@ static void netif_setup_tc(struct net_device *dev, unsigned int txq)
 
 		tc = &dev->tc_to_txq[q];
 		if (tc->offset + tc->count > txq) {
-			pr_warning("Number of in use tx queues "
-				   "changed. Priority %i to tc "
-				   "mapping %i is no longer valid "
-				   "setting map to 0\n",
-				   i, q);
+			netdev_warn(dev, "Number of in use tx queues changed. Priority %i to tc mapping %i is no longer valid. Setting map to 0.\n",
+				    i, q);
 			netdev_set_prio_tc_map(dev, i, 0);
 		}
 	}
@@ -1919,8 +1914,7 @@ EXPORT_SYMBOL(skb_gso_segment);
 void netdev_rx_csum_fault(struct net_device *dev)
 {
 	if (net_ratelimit()) {
-		printk(KERN_ERR "%s: hw csum failure.\n",
-			dev ? dev->name : "<unknown>");
+		netdev_err(dev, "hw csum failure\n");
 		dump_stack();
 	}
 }
@@ -2233,9 +2227,8 @@ static inline u16 dev_cap_txqueue(struct net_device *dev, u16 queue_index)
 {
 	if (unlikely(queue_index >= dev->real_num_tx_queues)) {
 		if (net_ratelimit()) {
-			pr_warning("%s selects TX queue %d, but "
-				"real number of TX queues is %d\n",
-				dev->name, queue_index, dev->real_num_tx_queues);
+			netdev_warn(dev, "selects TX queue %d, but real number of TX queues is %d\n",
+				    queue_index, dev->real_num_tx_queues);
 		}
 		return 0;
 	}
@@ -2465,16 +2458,14 @@ int dev_queue_xmit(struct sk_buff *skb)
 			}
 			HARD_TX_UNLOCK(dev, txq);
 			if (net_ratelimit())
-				printk(KERN_CRIT "Virtual device %s asks to "
-				       "queue packet!\n", dev->name);
+				netdev_crit(dev, "Virtual device asks to queue packet!\n");
 		} else {
 			/* Recursion is detected! It is possible,
 			 * unfortunately
 			 */
 recursion_alert:
 			if (net_ratelimit())
-				printk(KERN_CRIT "Dead loop on virtual device "
-				       "%s, fix it urgently!\n", dev->name);
+				netdev_crit(dev, "Dead loop on virtual device, fix it urgently!\n");
 		}
 	}
 
@@ -2996,8 +2987,8 @@ static int ing_filter(struct sk_buff *skb, struct netdev_queue *rxq)
 
 	if (unlikely(MAX_RED_LOOP < ttl++)) {
 		if (net_ratelimit())
-			pr_warning( "Redir loop detected Dropping packet (%d->%d)\n",
-			       skb->skb_iif, dev->ifindex);
+			netdev_warn(dev, "Redir loop detected - Dropping packet (%d->%d)\n",
+				    skb->skb_iif, dev->ifindex);
 		return TC_ACT_SHOT;
 	}
 
@@ -4366,16 +4357,13 @@ static int __dev_set_promiscuity(struct net_device *dev, int inc)
 			dev->flags &= ~IFF_PROMISC;
 		else {
 			dev->promiscuity -= inc;
-			printk(KERN_WARNING "%s: promiscuity touches roof, "
-				"set promiscuity failed, promiscuity feature "
-				"of device might be broken.\n", dev->name);
+			netdev_warn(dev, "promiscuity touches roof, set promiscuity failed, promiscuity feature of device might be broken\n");
 			return -EOVERFLOW;
 		}
 	}
 	if (dev->flags != old_flags) {
-		printk(KERN_INFO "device %s %s promiscuous mode\n",
-		       dev->name, (dev->flags & IFF_PROMISC) ? "entered" :
-							       "left");
+		netdev_info(dev, "%s promiscuous mode\n",
+			    (dev->flags & IFF_PROMISC) ? "entered" : "left");
 		if (audit_enabled) {
 			current_uid_gid(&uid, &gid);
 			audit_log(current->audit_context, GFP_ATOMIC,
@@ -4448,9 +4436,7 @@ int dev_set_allmulti(struct net_device *dev, int inc)
 			dev->flags &= ~IFF_ALLMULTI;
 		else {
 			dev->allmulti -= inc;
-			printk(KERN_WARNING "%s: allmulti touches roof, "
-				"set allmulti failed, allmulti feature of "
-				"device might be broken.\n", dev->name);
+			netdev_warn(dev, "allmulti touches roof, set allmulti failed, allmulti feature of device might be broken\n");
 			return -EOVERFLOW;
 		}
 	}
@@ -5127,8 +5113,8 @@ static void rollback_registered_many(struct list_head *head)
 		 * devices and proceed with the remaining.
 		 */
 		if (dev->reg_state == NETREG_UNINITIALIZED) {
-			pr_debug("unregister_netdevice: device %s/%p never "
-				 "was registered\n", dev->name, dev);
+			netdev_dbg(dev, "unregister_netdevice: (%p) device never was registered\n",
+				   dev);
 
 			WARN_ON(1);
 			list_del(&dev->unreg_list);
@@ -5204,27 +5190,26 @@ u32 netdev_fix_features(struct net_device *dev, u32 features)
 	/* Fix illegal checksum combinations */
 	if ((features & NETIF_F_HW_CSUM) &&
 	    (features & (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM))) {
-		netdev_warn(dev, "mixed HW and IP checksum settings.\n");
+		netdev_warn(dev, "mixed HW and IP checksum settings\n");
 		features &= ~(NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM);
 	}
 
 	if ((features & NETIF_F_NO_CSUM) &&
 	    (features & (NETIF_F_HW_CSUM|NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM))) {
-		netdev_warn(dev, "mixed no checksumming and other settings.\n");
+		netdev_warn(dev, "mixed no checksumming and other settings\n");
 		features &= ~(NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM|NETIF_F_HW_CSUM);
 	}
 
 	/* Fix illegal SG+CSUM combinations. */
 	if ((features & NETIF_F_SG) &&
 	    !(features & NETIF_F_ALL_CSUM)) {
-		netdev_dbg(dev,
-			"Dropping NETIF_F_SG since no checksum feature.\n");
+		netdev_dbg(dev, "Dropping NETIF_F_SG since no checksum feature\n");
 		features &= ~NETIF_F_SG;
 	}
 
 	/* TSO requires that SG is present as well. */
 	if ((features & NETIF_F_ALL_TSO) && !(features & NETIF_F_SG)) {
-		netdev_dbg(dev, "Dropping TSO features since no SG feature.\n");
+		netdev_dbg(dev, "Dropping TSO features since no SG feature\n");
 		features &= ~NETIF_F_ALL_TSO;
 	}
 
@@ -5234,7 +5219,7 @@ u32 netdev_fix_features(struct net_device *dev, u32 features)
 
 	/* Software GSO depends on SG. */
 	if ((features & NETIF_F_GSO) && !(features & NETIF_F_SG)) {
-		netdev_dbg(dev, "Dropping NETIF_F_GSO since no SG feature.\n");
+		netdev_dbg(dev, "Dropping NETIF_F_GSO since no SG feature\n");
 		features &= ~NETIF_F_GSO;
 	}
 
@@ -5244,14 +5229,12 @@ u32 netdev_fix_features(struct net_device *dev, u32 features)
 		if (!((features & NETIF_F_GEN_CSUM) ||
 		    (features & (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM))
 			    == (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM))) {
-			netdev_dbg(dev,
-				"Dropping NETIF_F_UFO since no checksum offload features.\n");
+			netdev_dbg(dev, "Dropping NETIF_F_UFO since no checksum offload features\n");
 			features &= ~NETIF_F_UFO;
 		}
 
 		if (!(features & NETIF_F_SG)) {
-			netdev_dbg(dev,
-				"Dropping NETIF_F_UFO since no NETIF_F_SG feature.\n");
+			netdev_dbg(dev, "Dropping NETIF_F_UFO since no NETIF_F_SG feature\n");
 			features &= ~NETIF_F_UFO;
 		}
 	}
@@ -5279,15 +5262,14 @@ int __netdev_update_features(struct net_device *dev)
 		return 0;
 
 	netdev_dbg(dev, "Features changed: 0x%08x -> 0x%08x\n",
-		dev->features, features);
+		   dev->features, features);
 
 	if (dev->netdev_ops->ndo_set_features)
 		err = dev->netdev_ops->ndo_set_features(dev, features);
 
 	if (unlikely(err < 0)) {
-		netdev_err(dev,
-			"set_features() failed (%d); wanted 0x%08x, left 0x%08x\n",
-			err, features, dev->features);
+		netdev_err(dev, "set_features() failed (%d); wanted 0x%08x, left 0x%08x\n",
+			   err, features, dev->features);
 		return -1;
 	}
 
@@ -5366,7 +5348,8 @@ static int netif_alloc_rx_queues(struct net_device *dev)
 
 	rx = kcalloc(count, sizeof(struct netdev_rx_queue), GFP_KERNEL);
 	if (!rx) {
-		pr_err("netdev: Unable to allocate %u rx queues.\n", count);
+		netdev_err(dev, "netdev: Unable to allocate %u rx queues\n",
+			   count);
 		return -ENOMEM;
 	}
 	dev->_rx = rx;
@@ -5397,8 +5380,8 @@ static int netif_alloc_netdev_queues(struct net_device *dev)
 
 	tx = kcalloc(count, sizeof(struct netdev_queue), GFP_KERNEL);
 	if (!tx) {
-		pr_err("netdev: Unable to allocate %u tx queues.\n",
-		       count);
+		netdev_err(dev, "netdev: Unable to allocate %u tx queues\n",
+			   count);
 		return -ENOMEM;
 	}
 	dev->_tx = tx;
@@ -5658,10 +5641,8 @@ static void netdev_wait_allrefs(struct net_device *dev)
 		refcnt = netdev_refcnt_read(dev);
 
 		if (time_after(jiffies, warning_time + 10 * HZ)) {
-			printk(KERN_EMERG "unregister_netdevice: "
-			       "waiting for %s to become free. Usage "
-			       "count = %d\n",
-			       dev->name, refcnt);
+			netdev_emerg(dev, "unregister_netdevice: waiting to become free. Usage count = %d\n",
+				     refcnt);
 			warning_time = jiffies;
 		}
 	}
@@ -5706,8 +5687,8 @@ void netdev_run_todo(void)
 		list_del(&dev->todo_list);
 
 		if (unlikely(dev->reg_state != NETREG_UNREGISTERING)) {
-			printk(KERN_ERR "network todo '%s' but state %d\n",
-			       dev->name, dev->reg_state);
+			netdev_err(dev, "network todo but state %d\n",
+				   dev->reg_state);
 			dump_stack();
 			continue;
 		}
@@ -5822,15 +5803,13 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 	BUG_ON(strlen(name) >= sizeof(dev->name));
 
 	if (txqs < 1) {
-		pr_err("alloc_netdev: Unable to allocate device "
-		       "with zero queues.\n");
+		pr_err("alloc_netdev: Unable to allocate device with zero queues\n");
 		return NULL;
 	}
 
 #ifdef CONFIG_RPS
 	if (rxqs < 1) {
-		pr_err("alloc_netdev: Unable to allocate device "
-		       "with zero RX queues.\n");
+		pr_err("alloc_netdev: Unable to allocate device with zero RX queues\n");
 		return NULL;
 	}
 #endif
@@ -5846,7 +5825,7 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 
 	p = kzalloc(alloc_size, GFP_KERNEL);
 	if (!p) {
-		printk(KERN_ERR "alloc_netdev: Unable to allocate device.\n");
+		pr_err("alloc_netdev: Unable to allocate device\n");
 		return NULL;
 	}
 
@@ -6380,8 +6359,8 @@ static void __net_exit default_device_exit(struct net *net)
 		snprintf(fb_name, IFNAMSIZ, "dev%d", dev->ifindex);
 		err = dev_change_net_namespace(dev, &init_net, fb_name);
 		if (err) {
-			printk(KERN_EMERG "%s: failed to move %s to init_net: %d\n",
-				__func__, dev->name, err);
+			pr_emerg("%s: failed to move %s to init_net: %d\n",
+				 __func__, dev->name, err);
 			BUG();
 		}
 	}
diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
index 7f36b38..b1677c4 100644
--- a/net/core/drop_monitor.c
+++ b/net/core/drop_monitor.c
@@ -4,6 +4,8 @@
  * Copyright (C) 2009 Neil Horman <nhorman@tuxdriver.com>
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/string.h>
@@ -342,10 +344,10 @@ static int __init init_net_drop_monitor(void)
 	struct per_cpu_dm_data *data;
 	int cpu, rc;
 
-	printk(KERN_INFO "Initializing network drop monitor service\n");
+	pr_info("Initializing network drop monitor service\n");
 
 	if (sizeof(void *) > 8) {
-		printk(KERN_ERR "Unable to store program counters on this arch, Drop monitor failed\n");
+		pr_err("Unable to store program counters on this arch, Drop monitor failed\n");
 		return -ENOSPC;
 	}
 
@@ -353,13 +355,13 @@ static int __init init_net_drop_monitor(void)
 					   dropmon_ops,
 					   ARRAY_SIZE(dropmon_ops));
 	if (rc) {
-		printk(KERN_ERR "Could not create drop monitor netlink family\n");
+		pr_err("Could not create drop monitor netlink family\n");
 		return rc;
 	}
 
 	rc = register_netdevice_notifier(&dropmon_net_notifier);
 	if (rc < 0) {
-		printk(KERN_CRIT "Failed to register netdevice notifier\n");
+		pr_crit("Failed to register netdevice notifier\n");
 		goto out_unreg;
 	}
 
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index ceb505b..adcf198 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -15,6 +15,8 @@
  *	Harald Welte		Add neighbour cache statistics like rtstat
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/slab.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
@@ -693,14 +695,13 @@ void neigh_destroy(struct neighbour *neigh)
 	NEIGH_CACHE_STAT_INC(neigh->tbl, destroys);
 
 	if (!neigh->dead) {
-		printk(KERN_WARNING
-		       "Destroying alive neighbour %p\n", neigh);
+		pr_warn("Destroying alive neighbour %p\n", neigh);
 		dump_stack();
 		return;
 	}
 
 	if (neigh_del_timer(neigh))
-		printk(KERN_WARNING "Impossible event.\n");
+		pr_warn("Impossible event\n");
 
 	while ((hh = neigh->hh) != NULL) {
 		neigh->hh = hh->hh_next;
@@ -882,7 +883,7 @@ static void neigh_timer_handler(unsigned long arg)
 
 	if (!(state & NUD_IN_TIMER)) {
 #ifndef CONFIG_SMP
-		printk(KERN_WARNING "neigh: timer & !nud_in_timer\n");
+		pr_warn("timer & !nud_in_timer\n");
 #endif
 		goto out;
 	}
@@ -1575,8 +1576,8 @@ void neigh_table_init(struct neigh_table *tbl)
 	write_unlock(&neigh_tbl_lock);
 
 	if (unlikely(tmp)) {
-		printk(KERN_ERR "NEIGH: Registering multiple tables for "
-		       "family %d\n", tbl->family);
+		pr_err("Registering multiple tables for family %d\n",
+		       tbl->family);
 		dump_stack();
 	}
 }
@@ -1592,7 +1593,7 @@ int neigh_table_clear(struct neigh_table *tbl)
 	pneigh_queue_purge(&tbl->proxy_queue);
 	neigh_ifdown(tbl, NULL);
 	if (atomic_read(&tbl->entries))
-		printk(KERN_CRIT "neighbour leakage\n");
+		pr_crit("neighbour leakage\n");
 	write_lock(&neigh_tbl_lock);
 	for (tp = &neigh_tables; *tp; tp = &(*tp)->next) {
 		if (*tp == tbl) {
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index ea489db..95ac0de 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -1,3 +1,5 @@
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/workqueue.h>
 #include <linux/rtnetlink.h>
 #include <linux/cache.h>
@@ -202,8 +204,8 @@ static void net_free(struct net *net)
 {
 #ifdef NETNS_REFCNT_DEBUG
 	if (unlikely(atomic_read(&net->use_count) != 0)) {
-		printk(KERN_EMERG "network namespace not free! Usage: %d\n",
-			atomic_read(&net->use_count));
+		pr_emerg("network namespace not free! Usage: %d\n",
+			 atomic_read(&net->use_count));
 		return;
 	}
 #endif
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 18d9cbd..25e9af5 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -9,6 +9,8 @@
  * Copyright (C) 2002  Red Hat, Inc.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/moduleparam.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
@@ -629,18 +631,18 @@ out:
 
 void netpoll_print_options(struct netpoll *np)
 {
-	printk(KERN_INFO "%s: local port %d\n",
-			 np->name, np->local_port);
-	printk(KERN_INFO "%s: local IP %pI4\n",
-			 np->name, &np->local_ip);
-	printk(KERN_INFO "%s: interface '%s'\n",
-			 np->name, np->dev_name);
-	printk(KERN_INFO "%s: remote port %d\n",
-			 np->name, np->remote_port);
-	printk(KERN_INFO "%s: remote IP %pI4\n",
-			 np->name, &np->remote_ip);
-	printk(KERN_INFO "%s: remote ethernet address %pM\n",
-	                 np->name, np->remote_mac);
+	pr_info("%s: local port %d\n",
+		np->name, np->local_port);
+	pr_info("%s: local IP %pI4\n",
+		np->name, &np->local_ip);
+	pr_info("%s: interface '%s'\n",
+		np->name, np->dev_name);
+	pr_info("%s: remote port %d\n",
+		np->name, np->remote_port);
+	pr_info("%s: remote IP %pI4\n",
+		np->name, &np->remote_ip);
+	pr_info("%s: remote ethernet address %pM\n",
+		np->name, np->remote_mac);
 }
 EXPORT_SYMBOL(netpoll_print_options);
 
@@ -682,8 +684,8 @@ int netpoll_parse_options(struct netpoll *np, char *opt)
 			goto parse_failed;
 		*delim = 0;
 		if (*cur == ' ' || *cur == '\t')
-			printk(KERN_INFO "%s: warning: whitespace"
-					"is not allowed\n", np->name);
+			pr_info("%s: warning: whitespace is not allowed\n",
+				np->name);
 		np->remote_port = simple_strtol(cur, NULL, 10);
 		cur = delim;
 	}
@@ -707,8 +709,8 @@ int netpoll_parse_options(struct netpoll *np, char *opt)
 	return 0;
 
  parse_failed:
-	printk(KERN_INFO "%s: couldn't parse config at '%s'!\n",
-	       np->name, cur);
+	pr_info("%s: couldn't parse config at '%s'!\n",
+		np->name, cur);
 	return -1;
 }
 EXPORT_SYMBOL(netpoll_parse_options);
@@ -723,7 +725,7 @@ int __netpoll_setup(struct netpoll *np)
 
 	if ((ndev->priv_flags & IFF_DISABLE_NETPOLL) ||
 	    !ndev->netdev_ops->ndo_poll_controller) {
-		printk(KERN_ERR "%s: %s doesn't support polling, aborting.\n",
+		pr_err("%s: %s doesn't support polling, aborting\n",
 		       np->name, np->dev_name);
 		err = -ENOTSUPP;
 		goto out;
@@ -787,13 +789,13 @@ int netpoll_setup(struct netpoll *np)
 	if (np->dev_name)
 		ndev = dev_get_by_name(&init_net, np->dev_name);
 	if (!ndev) {
-		printk(KERN_ERR "%s: %s doesn't exist, aborting.\n",
+		pr_err("%s: %s doesn't exist, aborting\n",
 		       np->name, np->dev_name);
 		return -ENODEV;
 	}
 
 	if (ndev->master) {
-		printk(KERN_ERR "%s: %s is a slave device, aborting.\n",
+		pr_err("%s: %s is a slave device, aborting\n",
 		       np->name, np->dev_name);
 		err = -EBUSY;
 		goto put;
@@ -802,15 +804,15 @@ int netpoll_setup(struct netpoll *np)
 	if (!netif_running(ndev)) {
 		unsigned long atmost, atleast;
 
-		printk(KERN_INFO "%s: device %s not up yet, forcing it\n",
-		       np->name, np->dev_name);
+		pr_info("%s: device %s not up yet, forcing it\n",
+			np->name, np->dev_name);
 
 		rtnl_lock();
 		err = dev_open(ndev);
 		rtnl_unlock();
 
 		if (err) {
-			printk(KERN_ERR "%s: failed to open %s\n",
+			pr_err("%s: failed to open %s\n",
 			       np->name, ndev->name);
 			goto put;
 		}
@@ -819,9 +821,8 @@ int netpoll_setup(struct netpoll *np)
 		atmost = jiffies + carrier_timeout * HZ;
 		while (!netif_carrier_ok(ndev)) {
 			if (time_after(jiffies, atmost)) {
-				printk(KERN_NOTICE
-				       "%s: timeout waiting for carrier\n",
-				       np->name);
+				pr_notice("%s: timeout waiting for carrier\n",
+					  np->name);
 				break;
 			}
 			msleep(1);
@@ -833,9 +834,8 @@ int netpoll_setup(struct netpoll *np)
 		 */
 
 		if (time_before(jiffies, atleast)) {
-			printk(KERN_NOTICE "%s: carrier detect appears"
-			       " untrustworthy, waiting 4 seconds\n",
-			       np->name);
+			pr_notice("%s: carrier detect appears untrustworthy, waiting 4 seconds\n",
+				  np->name);
 			msleep(4000);
 		}
 	}
@@ -846,7 +846,7 @@ int netpoll_setup(struct netpoll *np)
 
 		if (!in_dev || !in_dev->ifa_list) {
 			rcu_read_unlock();
-			printk(KERN_ERR "%s: no IP address for %s, aborting\n",
+			pr_err("%s: no IP address for %s, aborting\n",
 			       np->name, np->dev_name);
 			err = -EDESTADDRREQ;
 			goto put;
@@ -854,7 +854,7 @@ int netpoll_setup(struct netpoll *np)
 
 		np->local_ip = in_dev->ifa_list->ifa_local;
 		rcu_read_unlock();
-		printk(KERN_INFO "%s: local IP %pI4\n", np->name, &np->local_ip);
+		pr_info("%s: local IP %pI4\n", np->name, &np->local_ip);
 	}
 
 	np->dev = ndev;
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index f76079c..be6224c 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -505,7 +505,7 @@ static ssize_t pgctrl_write(struct file *file, const char __user *buf,
 		pktgen_reset_all_threads();
 
 	else
-		pr_warning("Unknown command: %s\n", data);
+		pr_warn("Unknown command: %s\n", data);
 
 	err = count;
 
@@ -855,14 +855,14 @@ static ssize_t pktgen_if_write(struct file *file,
 	pg_result = &(pkt_dev->result[0]);
 
 	if (count < 1) {
-		pr_warning("wrong command format\n");
+		pr_warn("wrong command format\n");
 		return -EINVAL;
 	}
 
 	max = count;
 	tmp = count_trail_chars(user_buffer, max);
 	if (tmp < 0) {
-		pr_warning("illegal format\n");
+		pr_warn("illegal format\n");
 		return tmp;
 	}
 	i = tmp;
@@ -2020,15 +2020,15 @@ static void pktgen_setup_inject(struct pktgen_dev *pkt_dev)
 	ntxq = pkt_dev->odev->real_num_tx_queues;
 
 	if (ntxq <= pkt_dev->queue_map_min) {
-		pr_warning("WARNING: Requested queue_map_min (zero-based) (%d) exceeds valid range [0 - %d] for (%d) queues on %s, resetting\n",
-			   pkt_dev->queue_map_min, (ntxq ?: 1) - 1, ntxq,
-			   pkt_dev->odevname);
+		pr_warn("WARNING: Requested queue_map_min (zero-based) (%d) exceeds valid range [0 - %d] for (%d) queues on %s, resetting\n",
+			pkt_dev->queue_map_min, (ntxq ?: 1) - 1, ntxq,
+			pkt_dev->odevname);
 		pkt_dev->queue_map_min = ntxq - 1;
 	}
 	if (pkt_dev->queue_map_max >= ntxq) {
-		pr_warning("WARNING: Requested queue_map_max (zero-based) (%d) exceeds valid range [0 - %d] for (%d) queues on %s, resetting\n",
-			   pkt_dev->queue_map_max, (ntxq ?: 1) - 1, ntxq,
-			   pkt_dev->odevname);
+		pr_warn("WARNING: Requested queue_map_max (zero-based) (%d) exceeds valid range [0 - %d] for (%d) queues on %s, resetting\n",
+			pkt_dev->queue_map_max, (ntxq ?: 1) - 1, ntxq,
+			pkt_dev->odevname);
 		pkt_dev->queue_map_max = ntxq - 1;
 	}
 
@@ -3159,8 +3159,7 @@ static int pktgen_stop_device(struct pktgen_dev *pkt_dev)
 	int nr_frags = pkt_dev->skb ? skb_shinfo(pkt_dev->skb)->nr_frags : -1;
 
 	if (!pkt_dev->running) {
-		pr_warning("interface: %s is already stopped\n",
-			   pkt_dev->odevname);
+		pr_warn("interface: %s is already stopped\n", pkt_dev->odevname);
 		return -EINVAL;
 	}
 
@@ -3675,7 +3674,7 @@ static int pktgen_remove_device(struct pktgen_thread *t,
 	pr_debug("remove_device pkt_dev=%p\n", pkt_dev);
 
 	if (pkt_dev->running) {
-		pr_warning("WARNING: trying to remove a running interface, stopping it now\n");
+		pr_warn("WARNING: trying to remove a running interface, stopping it now\n");
 		pktgen_stop_device(pkt_dev);
 	}
 
@@ -3729,8 +3728,8 @@ static int __init pg_init(void)
 
 		err = pktgen_create_thread(cpu);
 		if (err)
-			pr_warning("WARNING: Cannot create thread for cpu %d (%d)\n",
-				   cpu, err);
+			pr_warn("WARNING: Cannot create thread for cpu %d (%d)\n",
+				cpu, err);
 	}
 
 	if (list_empty(&pktgen_threads)) {
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index a798fc6..53fc9f6 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -16,6 +16,8 @@
  *	Vitaly E. Lavrov		RTA_OK arithmetics was wrong.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/errno.h>
 #include <linux/module.h>
 #include <linux/types.h>
@@ -1468,10 +1470,9 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 
 errout:
 	if (err < 0 && modified && net_ratelimit())
-		printk(KERN_WARNING "A link change request failed with "
-		       "some changes committed already. Interface %s may "
-		       "have been left with an inconsistent configuration, "
-		       "please check.\n", dev->name);
+		netdev_warn(dev,
+"A link change request failed with some changes committed already.\n"
+"Interface may have been left with an inconsistent configuration, please check.\n");
 
 	if (send_addr_notify)
 		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 46cbd28..e67b4a4 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -120,11 +120,9 @@ static const struct pipe_buf_operations sock_pipe_buf_ops = {
  */
 static void skb_over_panic(struct sk_buff *skb, int sz, void *here)
 {
-	printk(KERN_EMERG "skb_over_panic: text:%p len:%d put:%d head:%p "
-			  "data:%p tail:%#lx end:%#lx dev:%s\n",
-	       here, skb->len, sz, skb->head, skb->data,
-	       (unsigned long)skb->tail, (unsigned long)skb->end,
-	       skb->dev ? skb->dev->name : "<NULL>");
+	netdev_emerg(skb->dev, "skb_over_panic: text:%p len:%d put:%d head:%p data:%p tail:%#lx end:%#lx\n",
+		     here, skb->len, sz, skb->head, skb->data,
+		     (unsigned long)skb->tail, (unsigned long)skb->end);
 	BUG();
 }
 
@@ -139,11 +137,9 @@ static void skb_over_panic(struct sk_buff *skb, int sz, void *here)
 
 static void skb_under_panic(struct sk_buff *skb, int sz, void *here)
 {
-	printk(KERN_EMERG "skb_under_panic: text:%p len:%d put:%d head:%p "
-			  "data:%p tail:%#lx end:%#lx dev:%s\n",
-	       here, skb->len, sz, skb->head, skb->data,
-	       (unsigned long)skb->tail, (unsigned long)skb->end,
-	       skb->dev ? skb->dev->name : "<NULL>");
+	netdev_emerg(skb->dev, "skb_under_panic: text:%p len:%d put:%d head:%p data:%p tail:%#lx end:%#lx\n",
+		     here, skb->len, sz, skb->head, skb->data,
+		     (unsigned long)skb->tail, (unsigned long)skb->end);
 	BUG();
 }
 
@@ -3061,9 +3057,8 @@ bool skb_partial_csum_set(struct sk_buff *skb, u16 start, u16 off)
 	if (unlikely(start > skb_headlen(skb)) ||
 	    unlikely((int)start + off > skb_headlen(skb) - 2)) {
 		if (net_ratelimit())
-			printk(KERN_WARNING
-			       "bad partial csum: csum=%u/%u len=%u\n",
-			       start, off, skb_headlen(skb));
+			netdev_warn(skb->dev, "bad partial csum: csum=%u/%u len=%u\n",
+				    start, off, skb_headlen(skb));
 		return false;
 	}
 	skb->ip_summed = CHECKSUM_PARTIAL;
@@ -3076,7 +3071,6 @@ EXPORT_SYMBOL_GPL(skb_partial_csum_set);
 void __skb_warn_lro_forwarding(const struct sk_buff *skb)
 {
 	if (net_ratelimit())
-		pr_warning("%s: received packets cannot be forwarded"
-			   " while LRO is enabled\n", skb->dev->name);
+		netdev_warn(skb->dev, "received packets cannot be forwarded while LRO is enabled\n");
 }
 EXPORT_SYMBOL(__skb_warn_lro_forwarding);
diff --git a/net/core/sock.c b/net/core/sock.c
index 76c4031..26254ca 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -89,6 +89,8 @@
  *		2 of the License, or (at your option) any later version.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/capability.h>
 #include <linux/errno.h>
 #include <linux/types.h>
@@ -243,8 +245,7 @@ static int sock_set_timeout(long *timeo_p, char __user *optval, int optlen)
 		*timeo_p = 0;
 		if (warned < 10 && net_ratelimit()) {
 			warned++;
-			printk(KERN_INFO "sock_set_timeout: `%s' (pid %d) "
-			       "tries to set negative timeout\n",
+			pr_info("sock_set_timeout: `%s' (pid %d) tries to set negative timeout\n",
 				current->comm, task_pid_nr(current));
 		}
 		return 0;
@@ -263,8 +264,8 @@ static void sock_warn_obsolete_bsdism(const char *name)
 	static char warncomm[TASK_COMM_LEN];
 	if (strcmp(warncomm, current->comm) && warned < 5) {
 		strcpy(warncomm,  current->comm);
-		printk(KERN_WARNING "process `%s' is using obsolete "
-		       "%s SO_BSDCOMPAT\n", warncomm, name);
+		pr_warn("process `%s' is using obsolete %s SO_BSDCOMPAT\n",
+			warncomm, name);
 		warned++;
 	}
 }
@@ -1165,7 +1166,7 @@ static void __sk_free(struct sock *sk)
 	sock_disable_timestamp(sk, SOCK_TIMESTAMPING_RX_SOFTWARE);
 
 	if (atomic_read(&sk->sk_omem_alloc))
-		printk(KERN_DEBUG "%s: optmem leakage (%d bytes) detected.\n",
+		printk(KERN_DEBUG "%s: optmem leakage (%d bytes) detected\n",
 		       __func__, atomic_read(&sk->sk_omem_alloc));
 
 	if (sk->sk_peer_cred)
@@ -2336,7 +2337,7 @@ static void assign_proto_idx(struct proto *prot)
 	prot->inuse_idx = find_first_zero_bit(proto_inuse_idx, PROTO_INUSE_NR);
 
 	if (unlikely(prot->inuse_idx == PROTO_INUSE_NR - 1)) {
-		printk(KERN_ERR "PROTO_INUSE_NR exhausted\n");
+		pr_err("PROTO_INUSE_NR exhausted\n");
 		return;
 	}
 
@@ -2366,8 +2367,8 @@ int proto_register(struct proto *prot, int alloc_slab)
 					NULL);
 
 		if (prot->slab == NULL) {
-			printk(KERN_CRIT "%s: Can't create sock SLAB cache!\n",
-			       prot->name);
+			pr_crit("%s: Can't create sock SLAB cache!\n",
+				prot->name);
 			goto out;
 		}
 
@@ -2381,8 +2382,8 @@ int proto_register(struct proto *prot, int alloc_slab)
 								 SLAB_HWCACHE_ALIGN, NULL);
 
 			if (prot->rsk_prot->slab == NULL) {
-				printk(KERN_CRIT "%s: Can't create request sock SLAB cache!\n",
-				       prot->name);
+				pr_crit("%s: Can't create request sock SLAB cache!\n",
+					prot->name);
 				goto out_free_request_sock_slab_name;
 			}
 		}
-- 
1.7.6.rc1

