From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] ifb: add multi-queue support
Date: Tue, 10 Nov 2009 16:30:29 +0800
Message-ID: <4AF924A5.1050303@gmail.com>
Reply-To: xiaosuo@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiaosuo <xiaosuo@gmail.com>,
	Tom Herbert <therbert@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:42998 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752549AbZKJIa3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 03:30:29 -0500
Received: by pwi3 with SMTP id 3so1162554pwi.21
        for <netdev@vger.kernel.org>; Tue, 10 Nov 2009 00:30:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ifb: add multi-queue support

Add multi-queue support, and one kernel thread is created for per queue.
It can used to emulate multi-queue NIC in software, and distribute work
among CPUs.
gentux linux # modprobe ifb numtxqs=2
gentux linux # ifconfig ifb0 up
gentux linux # pgrep ifb0
18508
18509
gentux linux # taskset -p 1 18508
pid 18508's current affinity mask: 3
pid 18508's new affinity mask: 1
gentux linux # taskset -p 2 18509
pid 18509's current affinity mask: 3
pid 18509's new affinity mask: 2
gentux linux # tc qdisc add dev br0 ingress
gentux linux # tc filter add dev br0 parent ffff: protocol ip basic
action mirred egress redirect dev ifb0

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
drivers/net/ifb.c | 309
++++++++++++++++++++++++++++++++----------------------
1 file changed, 186 insertions(+), 123 deletions(-)

diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 030913f..6e04188 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -33,139 +33,101 @@
 #include <linux/etherdevice.h>
 #include <linux/init.h>
 #include <linux/moduleparam.h>
+#include <linux/wait.h>
+#include <linux/sched.h>
+#include <linux/kthread.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <net/ip.h>
 #include <net/pkt_sched.h>
 #include <net/net_namespace.h>
 
-#define TX_TIMEOUT  (2*HZ)
-
 #define TX_Q_LIMIT    32
+
 struct ifb_private {
-	struct tasklet_struct   ifb_tasklet;
-	int     tasklet_pending;
-	/* mostly debug stats leave in for now */
-	unsigned long   st_task_enter; /* tasklet entered */
-	unsigned long   st_txq_refl_try; /* transmit queue refill attempt */
-	unsigned long   st_rxq_enter; /* receive queue entered */
-	unsigned long   st_rx2tx_tran; /* receive to trasmit transfers */
-	unsigned long   st_rxq_notenter; /*receiveQ not entered, resched */
-	unsigned long   st_rx_frm_egr; /* received from egress path */
-	unsigned long   st_rx_frm_ing; /* received from ingress path */
-	unsigned long   st_rxq_check;
-	unsigned long   st_rxq_rsch;
-	struct sk_buff_head     rq;
-	struct sk_buff_head     tq;
+	struct net_device	*dev;
+	struct sk_buff_head	rq;
+	struct sk_buff_head	tq;
+	wait_queue_head_t	wq;
+	struct task_struct	*task;
 };
 
+/* Number of ifb devices to be set up by this module. */
 static int numifbs = 2;
+module_param(numifbs, int, 0444);
+MODULE_PARM_DESC(numifbs, "Number of ifb devices");
 
-static void ri_tasklet(unsigned long dev);
-static netdev_tx_t ifb_xmit(struct sk_buff *skb, struct net_device *dev);
-static int ifb_open(struct net_device *dev);
-static int ifb_close(struct net_device *dev);
+/* Number of TX queues per ifb */
+static int numtxqs = 1;
+module_param(numtxqs, int, 0444);
+MODULE_PARM_DESC(numtxqs, "Number of TX queues per ifb");
 
-static void ri_tasklet(unsigned long dev)
+static int ifb_thread(void *priv)
 {
-
-	struct net_device *_dev = (struct net_device *)dev;
-	struct ifb_private *dp = netdev_priv(_dev);
-	struct net_device_stats *stats = &_dev->stats;
-	struct netdev_queue *txq;
+	struct ifb_private *dp = (struct ifb_private*)priv;
+	struct net_device *dev = dp->dev;
+	struct net_device_stats *stats = &dev->stats;
+	unsigned int num = dp - (struct ifb_private*)netdev_priv(dev);
+	struct netdev_queue *txq = netdev_get_tx_queue(dev, num);
 	struct sk_buff *skb;
-
-	txq = netdev_get_tx_queue(_dev, 0);
-	dp->st_task_enter++;
-	if ((skb = skb_peek(&dp->tq)) == NULL) {
-		dp->st_txq_refl_try++;
-		if (__netif_tx_trylock(txq)) {
-			dp->st_rxq_enter++;
-			while ((skb = skb_dequeue(&dp->rq)) != NULL) {
+	DEFINE_WAIT(wait);
+
+	while (1) {
+		/* move skb from rq to tq */
+		while (1) {
+			prepare_to_wait(&dp->wq, &wait, TASK_UNINTERRUPTIBLE);
+			while (!__netif_tx_trylock(txq))
+				yield();
+			while ((skb = skb_dequeue(&dp->rq)) != NULL)
 				skb_queue_tail(&dp->tq, skb);
-				dp->st_rx2tx_tran++;
-			}
+			if (netif_queue_stopped(dev))
+				netif_wake_queue(dev);
 			__netif_tx_unlock(txq);
-		} else {
-			/* reschedule */
-			dp->st_rxq_notenter++;
-			goto resched;
+			if (kthread_should_stop() || !skb_queue_empty(&dp->tq))
+				break;
+			schedule();
 		}
-	}
-
-	while ((skb = skb_dequeue(&dp->tq)) != NULL) {
-		u32 from = G_TC_FROM(skb->tc_verd);
-
-		skb->tc_verd = 0;
-		skb->tc_verd = SET_TC_NCLS(skb->tc_verd);
-		stats->tx_packets++;
-		stats->tx_bytes +=skb->len;
-
-		skb->dev = dev_get_by_index(&init_net, skb->iif);
-		if (!skb->dev) {
-			dev_kfree_skb(skb);
-			stats->tx_dropped++;
+		finish_wait(&dp->wq, &wait);
+		if (kthread_should_stop())
 			break;
-		}
-		dev_put(skb->dev);
-		skb->iif = _dev->ifindex;
-
-		if (from & AT_EGRESS) {
-			dp->st_rx_frm_egr++;
-			dev_queue_xmit(skb);
-		} else if (from & AT_INGRESS) {
-			dp->st_rx_frm_ing++;
-			skb_pull(skb, skb->dev->hard_header_len);
-			netif_rx(skb);
-		} else
-			BUG();
-	}
 
-	if (__netif_tx_trylock(txq)) {
-		dp->st_rxq_check++;
-		if ((skb = skb_peek(&dp->rq)) == NULL) {
-			dp->tasklet_pending = 0;
-			if (netif_queue_stopped(_dev))
-				netif_wake_queue(_dev);
-		} else {
-			dp->st_rxq_rsch++;
-			__netif_tx_unlock(txq);
-			goto resched;
+		/* transfer packets */
+		while ((skb = skb_dequeue(&dp->tq)) != NULL) {
+			u32 from = G_TC_FROM(skb->tc_verd);
+	
+			skb->tc_verd = 0;
+			skb->tc_verd = SET_TC_NCLS(skb->tc_verd);
+			stats->tx_packets++;
+			stats->tx_bytes +=skb->len;
+	
+			skb->dev = dev_get_by_index(&init_net, skb->iif);
+			if (!skb->dev) {
+				dev_kfree_skb(skb);
+				stats->tx_dropped++;
+				break;
+			}
+			dev_put(skb->dev);
+			skb->iif = dev->ifindex;
+	
+			if (from & AT_EGRESS) {
+				dev_queue_xmit(skb);
+			} else if (from & AT_INGRESS) {
+				skb_pull(skb, skb->dev->hard_header_len);
+				netif_rx_ni(skb);
+			} else
+				BUG();
 		}
-		__netif_tx_unlock(txq);
-	} else {
-resched:
-		dp->tasklet_pending = 1;
-		tasklet_schedule(&dp->ifb_tasklet);
 	}
 
-}
-
-static const struct net_device_ops ifb_netdev_ops = {
-	.ndo_open	= ifb_open,
-	.ndo_stop	= ifb_close,
-	.ndo_start_xmit	= ifb_xmit,
-	.ndo_validate_addr = eth_validate_addr,
-};
-
-static void ifb_setup(struct net_device *dev)
-{
-	/* Initialize the device structure. */
-	dev->destructor = free_netdev;
-	dev->netdev_ops = &ifb_netdev_ops;
-
-	/* Fill in device structure with ethernet-generic values. */
-	ether_setup(dev);
-	dev->tx_queue_len = TX_Q_LIMIT;
-
-	dev->flags |= IFF_NOARP;
-	dev->flags &= ~IFF_MULTICAST;
-	dev->priv_flags &= ~IFF_XMIT_DST_RELEASE;
-	random_ether_addr(dev->dev_addr);
+	return 0;
 }
 
 static netdev_tx_t ifb_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct ifb_private *dp = netdev_priv(dev);
 	struct net_device_stats *stats = &dev->stats;
 	u32 from = G_TC_FROM(skb->tc_verd);
+	int num = skb_get_queue_mapping(skb);
+	struct ifb_private *dp = ((struct ifb_private*)netdev_priv(dev)) + num;
 
 	stats->rx_packets++;
 	stats->rx_bytes+=skb->len;
@@ -182,10 +144,8 @@ static netdev_tx_t ifb_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	dev->trans_start = jiffies;
 	skb_queue_tail(&dp->rq, skb);
-	if (!dp->tasklet_pending) {
-		dp->tasklet_pending = 1;
-		tasklet_schedule(&dp->ifb_tasklet);
-	}
+	if (skb_queue_len(&dp->rq) == 1)
+		wake_up(&dp->wq);
 
 	return NETDEV_TX_OK;
 }
@@ -193,26 +153,132 @@ static netdev_tx_t ifb_xmit(struct sk_buff *skb, struct net_device *dev)
 static int ifb_close(struct net_device *dev)
 {
 	struct ifb_private *dp = netdev_priv(dev);
+	int i;
+
+	for (i = 0; i < dev->real_num_tx_queues; i++) {
+		kthread_stop(dp[i].task);
+		skb_queue_purge(&dp[i].tq);
+		skb_queue_purge(&dp[i].rq);
+	}
 
-	tasklet_kill(&dp->ifb_tasklet);
 	netif_stop_queue(dev);
-	skb_queue_purge(&dp->rq);
-	skb_queue_purge(&dp->tq);
+
 	return 0;
 }
 
 static int ifb_open(struct net_device *dev)
 {
 	struct ifb_private *dp = netdev_priv(dev);
+	int i;
+	
+	for (i = 0; i < dev->real_num_tx_queues; i++) {
+		dp[i].dev = dev;
+		skb_queue_head_init(&dp[i].rq);
+		skb_queue_head_init(&dp[i].tq);
+		init_waitqueue_head(&dp[i].wq);
+		dp[i].task = kthread_run(ifb_thread, &dp[i], "%s/%d", dev->name,
+					i);
+		if (IS_ERR(dp[i].task)) {
+			int err = PTR_ERR(dp[i].task);
+			while (--i >= 0)
+				kthread_stop(dp[i].task);
+			return err;
+		}
+	}
 
-	tasklet_init(&dp->ifb_tasklet, ri_tasklet, (unsigned long)dev);
-	skb_queue_head_init(&dp->rq);
-	skb_queue_head_init(&dp->tq);
 	netif_start_queue(dev);
 
 	return 0;
 }
 
+static u32 simple_tx_hashrnd;
+
+static u16 ifb_select_queue(struct net_device *dev, struct sk_buff *skb)
+{
+	u32 addr1, addr2;
+	u32 hash, ihl;
+	union {
+		u16 in16[2];
+		u32 in32;
+	} ports;
+	u8 ip_proto;
+
+	if ((hash = skb_rx_queue_recorded(skb))) {
+		while (hash >= dev->real_num_tx_queues)
+			hash -= dev->real_num_tx_queues;
+		return hash;
+	}
+
+	switch (skb->protocol) {
+	case __constant_htons(ETH_P_IP):
+		if (!(ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET)))
+			ip_proto = ip_hdr(skb)->protocol;
+		else
+			ip_proto = 0;
+		addr1 = ip_hdr(skb)->saddr;
+		addr2 = ip_hdr(skb)->daddr;
+		ihl = ip_hdr(skb)->ihl << 2;
+		break;
+	case __constant_htons(ETH_P_IPV6):
+		ip_proto = ipv6_hdr(skb)->nexthdr;
+		addr1 = ipv6_hdr(skb)->saddr.s6_addr32[3];
+		addr2 = ipv6_hdr(skb)->daddr.s6_addr32[3];
+		ihl = 10;
+		break;
+	default:
+		return 0;
+	}
+	if (addr1 > addr2)
+		swap(addr1, addr2);
+
+	switch (ip_proto) {
+	case IPPROTO_TCP:
+	case IPPROTO_UDP:
+	case IPPROTO_DCCP:
+	case IPPROTO_ESP:
+	case IPPROTO_AH:
+	case IPPROTO_SCTP:
+	case IPPROTO_UDPLITE:
+		ports.in32 = *((u32 *) (skb_network_header(skb) + ihl));
+		if (ports.in16[0] > ports.in16[1])
+			swap(ports.in16[0], ports.in16[1]);
+		break;
+
+	default:
+		ports.in32 = 0;
+		break;
+	}
+
+	hash = jhash_3words(addr1, addr2, ports.in32,
+			    simple_tx_hashrnd ^ ip_proto);
+
+	return (u16) (((u64) hash * dev->real_num_tx_queues) >> 32);
+}
+
+static const struct net_device_ops ifb_netdev_ops = {
+	.ndo_open		= ifb_open,
+	.ndo_stop		= ifb_close,
+	.ndo_start_xmit		= ifb_xmit,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_select_queue	= ifb_select_queue,
+};
+
+static void ifb_setup(struct net_device *dev)
+{
+	/* Initialize the device structure. */
+	dev->destructor = free_netdev;
+	dev->netdev_ops = &ifb_netdev_ops;
+
+	/* Fill in device structure with ethernet-generic values. */
+	ether_setup(dev);
+	dev->tx_queue_len = TX_Q_LIMIT;
+
+	dev->flags |= IFF_NOARP;
+	dev->flags &= ~IFF_MULTICAST;
+	dev->priv_flags &= ~IFF_XMIT_DST_RELEASE;
+	random_ether_addr(dev->dev_addr);
+}
+
 static int ifb_validate(struct nlattr *tb[], struct nlattr *data[])
 {
 	if (tb[IFLA_ADDRESS]) {
@@ -231,17 +297,13 @@ static struct rtnl_link_ops ifb_link_ops __read_mostly = {
 	.validate	= ifb_validate,
 };
 
-/* Number of ifb devices to be set up by this module. */
-module_param(numifbs, int, 0);
-MODULE_PARM_DESC(numifbs, "Number of ifb devices");
-
 static int __init ifb_init_one(int index)
 {
 	struct net_device *dev_ifb;
 	int err;
 
-	dev_ifb = alloc_netdev(sizeof(struct ifb_private),
-				 "ifb%d", ifb_setup);
+	dev_ifb = alloc_netdev_mq(sizeof(struct ifb_private) * numtxqs, "ifb%d",
+				  ifb_setup, numtxqs);
 
 	if (!dev_ifb)
 		return -ENOMEM;
@@ -266,6 +328,7 @@ static int __init ifb_init_module(void)
 {
 	int i, err;
 
+	get_random_bytes(&simple_tx_hashrnd, 4);
 	rtnl_lock();
 	err = __rtnl_link_register(&ifb_link_ops);
 


