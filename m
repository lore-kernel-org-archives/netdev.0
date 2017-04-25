From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: [PATCH 4/8] can: complete initial namespace support
Date: Tue, 25 Apr 2017 08:19:41 +0200
Message-ID: <20170425061945.28722-5-socketcan@hartkopp.net>
References: <20170425061945.28722-1-socketcan@hartkopp.net>
Cc: Oliver Hartkopp <socketcan@hartkopp.net>, mkl@pengutronix.de,
        dev@kicherer.org, netdev@vger.kernel.org
To: linux-can@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.161]:26744 "EHLO
        mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S980630AbdDYGUa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 02:20:30 -0400
In-Reply-To: <20170425061945.28722-1-socketcan@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The statistics and its proc output was not implemented as per-net in the
initial network namespace support by Mario Kicherer (8e8cda6d737d).
This patch adds the missing per-net statistics for the CAN subsystem.

Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
---
 include/linux/can/core.h |   4 +-
 include/net/netns/can.h  |   5 ++
 net/can/af_can.c         |  71 +++++++++++++-----------
 net/can/af_can.h         |   5 --
 net/can/proc.c           | 141 +++++++++++++++++++++++++----------------------
 5 files changed, 121 insertions(+), 105 deletions(-)

diff --git a/include/linux/can/core.h b/include/linux/can/core.h
index 319a0da827b8..c9a17bb1221c 100644
--- a/include/linux/can/core.h
+++ b/include/linux/can/core.h
@@ -5,7 +5,7 @@
  *
  * Authors: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
  *          Urs Thuermann   <urs.thuermann@volkswagen.de>
- * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
+ * Copyright (c) 2002-2017 Volkswagen Group Electronic Research
  * All rights reserved.
  *
  */
@@ -17,7 +17,7 @@
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
 
-#define CAN_VERSION "20120528"
+#define CAN_VERSION "20170425"
 
 /* increment this number each time you change some user-space interface */
 #define CAN_ABI_VERSION "9"
diff --git a/include/net/netns/can.h b/include/net/netns/can.h
index e8beba772f1a..574157dbc43a 100644
--- a/include/net/netns/can.h
+++ b/include/net/netns/can.h
@@ -8,6 +8,8 @@
 #include <linux/spinlock.h>
 
 struct dev_rcv_lists;
+struct s_stats;
+struct s_pstats;
 
 struct netns_can {
 #if IS_ENABLED(CONFIG_PROC_FS)
@@ -26,6 +28,9 @@ struct netns_can {
 	/* receive filters subscribed for 'all' CAN devices */
 	struct dev_rcv_lists *can_rx_alldev_list;
 	spinlock_t can_rcvlists_lock;
+	struct timer_list can_stattimer;/* timer for statistics update */
+	struct s_stats *can_stats;	/* packet statistics */
+	struct s_pstats *can_pstats;	/* receive list statistics */
 };
 
 #endif /* __NETNS_CAN_H__ */
diff --git a/net/can/af_can.c b/net/can/af_can.c
index 421b60fc42c3..b6406fe33c76 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -2,7 +2,7 @@
  * af_can.c - Protocol family CAN core module
  *            (used by different CAN protocol modules)
  *
- * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
+ * Copyright (c) 2002-2017 Volkswagen Group Electronic Research
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -81,10 +81,6 @@ static struct kmem_cache *rcv_cache __read_mostly;
 static const struct can_proto *proto_tab[CAN_NPROTO] __read_mostly;
 static DEFINE_MUTEX(proto_tab_lock);
 
-struct timer_list can_stattimer;   /* timer for statistics update */
-struct s_stats    can_stats;       /* packet statistics */
-struct s_pstats   can_pstats;      /* receive list statistics */
-
 static atomic_t skbcounter = ATOMIC_INIT(0);
 
 /*
@@ -221,6 +217,7 @@ int can_send(struct sk_buff *skb, int loop)
 {
 	struct sk_buff *newskb = NULL;
 	struct canfd_frame *cfd = (struct canfd_frame *)skb->data;
+	struct s_stats *can_stats = dev_net(skb->dev)->can.can_stats;
 	int err = -EINVAL;
 
 	if (skb->len == CAN_MTU) {
@@ -309,8 +306,8 @@ int can_send(struct sk_buff *skb, int loop)
 		netif_rx_ni(newskb);
 
 	/* update statistics */
-	can_stats.tx_frames++;
-	can_stats.tx_frames_delta++;
+	can_stats->tx_frames++;
+	can_stats->tx_frames_delta++;
 
 	return 0;
 
@@ -468,6 +465,7 @@ int can_rx_register(struct net *net, struct net_device *dev, canid_t can_id,
 	struct receiver *r;
 	struct hlist_head *rl;
 	struct dev_rcv_lists *d;
+	struct s_pstats *can_pstats = net->can.can_pstats;
 	int err = 0;
 
 	/* insert new receiver  (dev,canid,mask) -> (func,data) */
@@ -499,9 +497,9 @@ int can_rx_register(struct net *net, struct net_device *dev, canid_t can_id,
 		hlist_add_head_rcu(&r->list, rl);
 		d->entries++;
 
-		can_pstats.rcv_entries++;
-		if (can_pstats.rcv_entries_max < can_pstats.rcv_entries)
-			can_pstats.rcv_entries_max = can_pstats.rcv_entries;
+		can_pstats->rcv_entries++;
+		if (can_pstats->rcv_entries_max < can_pstats->rcv_entries)
+			can_pstats->rcv_entries_max = can_pstats->rcv_entries;
 	} else {
 		kmem_cache_free(rcv_cache, r);
 		err = -ENODEV;
@@ -543,6 +541,7 @@ void can_rx_unregister(struct net *net, struct net_device *dev, canid_t can_id,
 {
 	struct receiver *r = NULL;
 	struct hlist_head *rl;
+	struct s_pstats *can_pstats = net->can.can_pstats;
 	struct dev_rcv_lists *d;
 
 	if (dev && dev->type != ARPHRD_CAN)
@@ -589,8 +588,8 @@ void can_rx_unregister(struct net *net, struct net_device *dev, canid_t can_id,
 	hlist_del_rcu(&r->list);
 	d->entries--;
 
-	if (can_pstats.rcv_entries > 0)
-		can_pstats.rcv_entries--;
+	if (can_pstats->rcv_entries > 0)
+		can_pstats->rcv_entries--;
 
 	/* remove device structure requested by NETDEV_UNREGISTER */
 	if (d->remove_on_zero_entries && !d->entries) {
@@ -684,11 +683,13 @@ static int can_rcv_filter(struct dev_rcv_lists *d, struct sk_buff *skb)
 static void can_receive(struct sk_buff *skb, struct net_device *dev)
 {
 	struct dev_rcv_lists *d;
+	struct net *net = dev_net(dev);
+	struct s_stats *can_stats = net->can.can_stats;
 	int matches;
 
 	/* update statistics */
-	can_stats.rx_frames++;
-	can_stats.rx_frames_delta++;
+	can_stats->rx_frames++;
+	can_stats->rx_frames_delta++;
 
 	/* create non-zero unique skb identifier together with *skb */
 	while (!(can_skb_prv(skb)->skbcnt))
@@ -697,10 +698,10 @@ static void can_receive(struct sk_buff *skb, struct net_device *dev)
 	rcu_read_lock();
 
 	/* deliver the packet to sockets listening on all devices */
-	matches = can_rcv_filter(dev_net(dev)->can.can_rx_alldev_list, skb);
+	matches = can_rcv_filter(net->can.can_rx_alldev_list, skb);
 
 	/* find receive list for this device */
-	d = find_dev_rcv_lists(dev_net(dev), dev);
+	d = find_dev_rcv_lists(net, dev);
 	if (d)
 		matches += can_rcv_filter(d, skb);
 
@@ -710,8 +711,8 @@ static void can_receive(struct sk_buff *skb, struct net_device *dev)
 	consume_skb(skb);
 
 	if (matches > 0) {
-		can_stats.matches++;
-		can_stats.matches_delta++;
+		can_stats->matches++;
+		can_stats->matches_delta++;
 	}
 }
 
@@ -876,8 +877,20 @@ static int can_pernet_init(struct net *net)
 	net->can.can_rx_alldev_list =
 		kzalloc(sizeof(struct dev_rcv_lists), GFP_KERNEL);
 
-	if (IS_ENABLED(CONFIG_PROC_FS))
+	net->can.can_stats = kzalloc(sizeof(struct s_stats), GFP_KERNEL);
+	net->can.can_pstats = kzalloc(sizeof(struct s_pstats), GFP_KERNEL);
+
+	if (IS_ENABLED(CONFIG_PROC_FS)) {
+		/* the statistics are updated every second (timer triggered) */
+		if (stats_timer) {
+			setup_timer(&net->can.can_stattimer, can_stat_update,
+				    (unsigned long)net);
+			mod_timer(&net->can.can_stattimer,
+				  round_jiffies(jiffies + HZ));
+		}
+		net->can.can_stats->jiffies_init = jiffies;
 		can_init_proc(net);
+	}
 
 	return 0;
 }
@@ -886,8 +899,11 @@ static void can_pernet_exit(struct net *net)
 {
 	struct net_device *dev;
 
-	if (IS_ENABLED(CONFIG_PROC_FS))
+	if (IS_ENABLED(CONFIG_PROC_FS)) {
 		can_remove_proc(net);
+		if (stats_timer)
+			del_timer_sync(&net->can.can_stattimer);
+	}
 
 	/* remove created dev_rcv_lists from still registered CAN devices */
 	rcu_read_lock();
@@ -903,6 +919,8 @@ static void can_pernet_exit(struct net *net)
 	rcu_read_unlock();
 
 	kfree(net->can.can_rx_alldev_list);
+	kfree(net->can.can_stats);
+	kfree(net->can.can_pstats);
 }
 
 /*
@@ -950,14 +968,6 @@ static __init int can_init(void)
 	if (!rcv_cache)
 		return -ENOMEM;
 
-	if (IS_ENABLED(CONFIG_PROC_FS)) {
-		if (stats_timer) {
-		/* the statistics are updated every second (timer triggered) */
-			setup_timer(&can_stattimer, can_stat_update, 0);
-			mod_timer(&can_stattimer, round_jiffies(jiffies + HZ));
-		}
-	}
-
 	register_pernet_subsys(&can_pernet_ops);
 
 	/* protocol register */
@@ -971,11 +981,6 @@ static __init int can_init(void)
 
 static __exit void can_exit(void)
 {
-	if (IS_ENABLED(CONFIG_PROC_FS)) {
-		if (stats_timer)
-			del_timer_sync(&can_stattimer);
-	}
-
 	/* protocol unregister */
 	dev_remove_pack(&canfd_packet);
 	dev_remove_pack(&can_packet);
diff --git a/net/can/af_can.h b/net/can/af_can.h
index 84a35e97c5e0..d0ef45bb2a72 100644
--- a/net/can/af_can.h
+++ b/net/can/af_can.h
@@ -115,9 +115,4 @@ void can_init_proc(struct net *net);
 void can_remove_proc(struct net *net);
 void can_stat_update(unsigned long data);
 
-/* structures and variables from af_can.c needed in proc.c for reading */
-extern struct timer_list can_stattimer;    /* timer for statistics update */
-extern struct s_stats    can_stats;        /* packet statistics */
-extern struct s_pstats   can_pstats;       /* receive list statistics */
-
 #endif /* AF_CAN_H */
diff --git a/net/can/proc.c b/net/can/proc.c
index 9a8d54d57b22..83045f00c63c 100644
--- a/net/can/proc.c
+++ b/net/can/proc.c
@@ -75,21 +75,23 @@ static const char rx_list_name[][8] = {
  * af_can statistics stuff
  */
 
-static void can_init_stats(void)
+static void can_init_stats(struct net *net)
 {
+	struct s_stats *can_stats = net->can.can_stats;
+	struct s_pstats *can_pstats = net->can.can_pstats;
 	/*
 	 * This memset function is called from a timer context (when
 	 * can_stattimer is active which is the default) OR in a process
 	 * context (reading the proc_fs when can_stattimer is disabled).
 	 */
-	memset(&can_stats, 0, sizeof(can_stats));
-	can_stats.jiffies_init = jiffies;
+	memset(can_stats, 0, sizeof(struct s_stats));
+	can_stats->jiffies_init = jiffies;
 
-	can_pstats.stats_reset++;
+	can_pstats->stats_reset++;
 
 	if (user_reset) {
 		user_reset = 0;
-		can_pstats.user_reset++;
+		can_pstats->user_reset++;
 	}
 }
 
@@ -115,64 +117,66 @@ static unsigned long calc_rate(unsigned long oldjif, unsigned long newjif,
 
 void can_stat_update(unsigned long data)
 {
+	struct net *net = (struct net *)data;
+	struct s_stats *can_stats = net->can.can_stats;
 	unsigned long j = jiffies; /* snapshot */
 
 	/* restart counting in timer context on user request */
 	if (user_reset)
-		can_init_stats();
+		can_init_stats(net);
 
 	/* restart counting on jiffies overflow */
-	if (j < can_stats.jiffies_init)
-		can_init_stats();
+	if (j < can_stats->jiffies_init)
+		can_init_stats(net);
 
 	/* prevent overflow in calc_rate() */
-	if (can_stats.rx_frames > (ULONG_MAX / HZ))
-		can_init_stats();
+	if (can_stats->rx_frames > (ULONG_MAX / HZ))
+		can_init_stats(net);
 
 	/* prevent overflow in calc_rate() */
-	if (can_stats.tx_frames > (ULONG_MAX / HZ))
-		can_init_stats();
+	if (can_stats->tx_frames > (ULONG_MAX / HZ))
+		can_init_stats(net);
 
 	/* matches overflow - very improbable */
-	if (can_stats.matches > (ULONG_MAX / 100))
-		can_init_stats();
+	if (can_stats->matches > (ULONG_MAX / 100))
+		can_init_stats(net);
 
 	/* calc total values */
-	if (can_stats.rx_frames)
-		can_stats.total_rx_match_ratio = (can_stats.matches * 100) /
-			can_stats.rx_frames;
+	if (can_stats->rx_frames)
+		can_stats->total_rx_match_ratio = (can_stats->matches * 100) /
+			can_stats->rx_frames;
 
-	can_stats.total_tx_rate = calc_rate(can_stats.jiffies_init, j,
-					    can_stats.tx_frames);
-	can_stats.total_rx_rate = calc_rate(can_stats.jiffies_init, j,
-					    can_stats.rx_frames);
+	can_stats->total_tx_rate = calc_rate(can_stats->jiffies_init, j,
+					    can_stats->tx_frames);
+	can_stats->total_rx_rate = calc_rate(can_stats->jiffies_init, j,
+					    can_stats->rx_frames);
 
 	/* calc current values */
-	if (can_stats.rx_frames_delta)
-		can_stats.current_rx_match_ratio =
-			(can_stats.matches_delta * 100) /
-			can_stats.rx_frames_delta;
+	if (can_stats->rx_frames_delta)
+		can_stats->current_rx_match_ratio =
+			(can_stats->matches_delta * 100) /
+			can_stats->rx_frames_delta;
 
-	can_stats.current_tx_rate = calc_rate(0, HZ, can_stats.tx_frames_delta);
-	can_stats.current_rx_rate = calc_rate(0, HZ, can_stats.rx_frames_delta);
+	can_stats->current_tx_rate = calc_rate(0, HZ, can_stats->tx_frames_delta);
+	can_stats->current_rx_rate = calc_rate(0, HZ, can_stats->rx_frames_delta);
 
 	/* check / update maximum values */
-	if (can_stats.max_tx_rate < can_stats.current_tx_rate)
-		can_stats.max_tx_rate = can_stats.current_tx_rate;
+	if (can_stats->max_tx_rate < can_stats->current_tx_rate)
+		can_stats->max_tx_rate = can_stats->current_tx_rate;
 
-	if (can_stats.max_rx_rate < can_stats.current_rx_rate)
-		can_stats.max_rx_rate = can_stats.current_rx_rate;
+	if (can_stats->max_rx_rate < can_stats->current_rx_rate)
+		can_stats->max_rx_rate = can_stats->current_rx_rate;
 
-	if (can_stats.max_rx_match_ratio < can_stats.current_rx_match_ratio)
-		can_stats.max_rx_match_ratio = can_stats.current_rx_match_ratio;
+	if (can_stats->max_rx_match_ratio < can_stats->current_rx_match_ratio)
+		can_stats->max_rx_match_ratio = can_stats->current_rx_match_ratio;
 
 	/* clear values for 'current rate' calculation */
-	can_stats.tx_frames_delta = 0;
-	can_stats.rx_frames_delta = 0;
-	can_stats.matches_delta   = 0;
+	can_stats->tx_frames_delta = 0;
+	can_stats->rx_frames_delta = 0;
+	can_stats->matches_delta   = 0;
 
 	/* restart timer (one second) */
-	mod_timer(&can_stattimer, round_jiffies(jiffies + HZ));
+	mod_timer(&net->can.can_stattimer, round_jiffies(jiffies + HZ));
 }
 
 /*
@@ -206,57 +210,61 @@ static void can_print_recv_banner(struct seq_file *m)
 
 static int can_stats_proc_show(struct seq_file *m, void *v)
 {
+	struct net *net = m->private;
+	struct s_stats *can_stats = net->can.can_stats;
+	struct s_pstats *can_pstats = net->can.can_pstats;
+
 	seq_putc(m, '\n');
-	seq_printf(m, " %8ld transmitted frames (TXF)\n", can_stats.tx_frames);
-	seq_printf(m, " %8ld received frames (RXF)\n", can_stats.rx_frames);
-	seq_printf(m, " %8ld matched frames (RXMF)\n", can_stats.matches);
+	seq_printf(m, " %8ld transmitted frames (TXF)\n", can_stats->tx_frames);
+	seq_printf(m, " %8ld received frames (RXF)\n", can_stats->rx_frames);
+	seq_printf(m, " %8ld matched frames (RXMF)\n", can_stats->matches);
 
 	seq_putc(m, '\n');
 
-	if (can_stattimer.function == can_stat_update) {
+	if (net->can.can_stattimer.function == can_stat_update) {
 		seq_printf(m, " %8ld %% total match ratio (RXMR)\n",
-				can_stats.total_rx_match_ratio);
+				can_stats->total_rx_match_ratio);
 
 		seq_printf(m, " %8ld frames/s total tx rate (TXR)\n",
-				can_stats.total_tx_rate);
+				can_stats->total_tx_rate);
 		seq_printf(m, " %8ld frames/s total rx rate (RXR)\n",
-				can_stats.total_rx_rate);
+				can_stats->total_rx_rate);
 
 		seq_putc(m, '\n');
 
 		seq_printf(m, " %8ld %% current match ratio (CRXMR)\n",
-				can_stats.current_rx_match_ratio);
+				can_stats->current_rx_match_ratio);
 
 		seq_printf(m, " %8ld frames/s current tx rate (CTXR)\n",
-				can_stats.current_tx_rate);
+				can_stats->current_tx_rate);
 		seq_printf(m, " %8ld frames/s current rx rate (CRXR)\n",
-				can_stats.current_rx_rate);
+				can_stats->current_rx_rate);
 
 		seq_putc(m, '\n');
 
 		seq_printf(m, " %8ld %% max match ratio (MRXMR)\n",
-				can_stats.max_rx_match_ratio);
+				can_stats->max_rx_match_ratio);
 
 		seq_printf(m, " %8ld frames/s max tx rate (MTXR)\n",
-				can_stats.max_tx_rate);
+				can_stats->max_tx_rate);
 		seq_printf(m, " %8ld frames/s max rx rate (MRXR)\n",
-				can_stats.max_rx_rate);
+				can_stats->max_rx_rate);
 
 		seq_putc(m, '\n');
 	}
 
 	seq_printf(m, " %8ld current receive list entries (CRCV)\n",
-			can_pstats.rcv_entries);
+			can_pstats->rcv_entries);
 	seq_printf(m, " %8ld maximum receive list entries (MRCV)\n",
-			can_pstats.rcv_entries_max);
+			can_pstats->rcv_entries_max);
 
-	if (can_pstats.stats_reset)
+	if (can_pstats->stats_reset)
 		seq_printf(m, "\n %8ld statistic resets (STR)\n",
-				can_pstats.stats_reset);
+				can_pstats->stats_reset);
 
-	if (can_pstats.user_reset)
+	if (can_pstats->user_reset)
 		seq_printf(m, " %8ld user statistic resets (USTR)\n",
-				can_pstats.user_reset);
+				can_pstats->user_reset);
 
 	seq_putc(m, '\n');
 	return 0;
@@ -264,7 +272,7 @@ static int can_stats_proc_show(struct seq_file *m, void *v)
 
 static int can_stats_proc_open(struct inode *inode, struct file *file)
 {
-	return single_open(file, can_stats_proc_show, NULL);
+	return single_open_net(inode, file, can_stats_proc_show);
 }
 
 static const struct file_operations can_stats_proc_fops = {
@@ -277,25 +285,28 @@ static const struct file_operations can_stats_proc_fops = {
 
 static int can_reset_stats_proc_show(struct seq_file *m, void *v)
 {
+	struct net *net = m->private;
+	struct s_pstats *can_pstats = net->can.can_pstats;
+	struct s_stats *can_stats = net->can.can_stats;
+
 	user_reset = 1;
 
-	if (can_stattimer.function == can_stat_update) {
+	if (net->can.can_stattimer.function == can_stat_update) {
 		seq_printf(m, "Scheduled statistic reset #%ld.\n",
-				can_pstats.stats_reset + 1);
-
+				can_pstats->stats_reset + 1);
 	} else {
-		if (can_stats.jiffies_init != jiffies)
-			can_init_stats();
+		if (can_stats->jiffies_init != jiffies)
+			can_init_stats(net);
 
 		seq_printf(m, "Performed statistic reset #%ld.\n",
-				can_pstats.stats_reset);
+				can_pstats->stats_reset);
 	}
 	return 0;
 }
 
 static int can_reset_stats_proc_open(struct inode *inode, struct file *file)
 {
-	return single_open(file, can_reset_stats_proc_show, NULL);
+	return single_open_net(inode, file, can_reset_stats_proc_show);
 }
 
 static const struct file_operations can_reset_stats_proc_fops = {
@@ -314,7 +325,7 @@ static int can_version_proc_show(struct seq_file *m, void *v)
 
 static int can_version_proc_open(struct inode *inode, struct file *file)
 {
-	return single_open(file, can_version_proc_show, NULL);
+	return single_open_net(inode, file, can_version_proc_show);
 }
 
 static const struct file_operations can_version_proc_fops = {
-- 
2.11.0
