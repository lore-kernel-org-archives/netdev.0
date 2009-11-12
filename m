From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] ifb: add multi-queue support
Date: Thu, 12 Nov 2009 17:44:49 +0800
Message-ID: <4AFBD911.6000900@gmail.com>
References: <4AFA8911.7050204@gmail.com>
Reply-To: xiaosuo@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f179.google.com ([209.85.216.179]:61309 "EHLO
	mail-px0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751736AbZKLJou (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 04:44:50 -0500
Received: by pxi9 with SMTP id 9so348258pxi.16
        for <netdev@vger.kernel.org>; Thu, 12 Nov 2009 01:44:55 -0800 (PST)
In-Reply-To: <4AFA8911.7050204@gmail.com>
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

This patch also introduces a ip link option "numtxqs" for specifying the
number of the TX queues. so you can add a new ifb with the command:

ip link add numtxqs 4 type ifb

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
drivers/net/ifb.c | 506 +++++++++++++++++++++++++++++++++++-------------
include/linux/if_link.h | 1
net/core/rtnetlink.c | 3
3 files changed, 375 insertions(+), 135 deletions(-)

diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 69c2566..7116953 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -33,161 +33,166 @@
 #include <linux/etherdevice.h>
 #include <linux/init.h>
 #include <linux/moduleparam.h>
+#include <linux/wait.h>
+#include <linux/sched.h>
+#include <linux/kthread.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <linux/if_vlan.h>
+#include <linux/if_pppox.h>
+#include <net/ip.h>
+#include <net/ipv6.h>
 #include <net/pkt_sched.h>
 #include <net/net_namespace.h>
 
-#define TX_TIMEOUT  (2*HZ)
-
 #define TX_Q_LIMIT    32
+
+struct ifb_private_q {
+	struct net_device	*dev;
+	struct sk_buff_head	rq;
+	wait_queue_head_t	wq;
+	struct task_struct	*task;
+	unsigned long		rx_packets;
+	unsigned long		rx_bytes;
+	unsigned long		rx_dropped;
+} ____cacheline_aligned_in_smp;
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
+	struct ifb_private_q	*pq;
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
+static unsigned int numtxqs = 1;
+module_param(numtxqs, uint, 0444);
+MODULE_PARM_DESC(numtxqs, "Number of TX queues per ifb");
 
-static void ri_tasklet(unsigned long dev)
+static int ifb_thread(void *priv)
 {
-
-	struct net_device *_dev = (struct net_device *)dev;
-	struct ifb_private *dp = netdev_priv(_dev);
-	struct net_device_stats *stats = &_dev->stats;
-	struct netdev_queue *txq;
+	struct ifb_private_q *pq = priv;
+	struct net_device *dev = pq->dev, *_dev;
+	int num = pq - ((struct ifb_private *)netdev_priv(dev))->pq;
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
-				skb_queue_tail(&dp->tq, skb);
-				dp->st_rx2tx_tran++;
-			}
-			__netif_tx_unlock(txq);
-		} else {
-			/* reschedule */
-			dp->st_rxq_notenter++;
-			goto resched;
+	DEFINE_WAIT(wait);
+	struct sk_buff_head tq;
+
+	__skb_queue_head_init(&tq);
+	while (1) {
+		/* move skb from rq to tq */
+		while (1) {
+			prepare_to_wait(&pq->wq, &wait, TASK_UNINTERRUPTIBLE);
+			__netif_tx_lock_bh(txq);
+			skb_queue_splice_tail_init(&pq->rq, &tq);
+			if (netif_queue_stopped(dev))
+				netif_wake_queue(dev);
+			__netif_tx_unlock_bh(txq);
+			if (kthread_should_stop() || !skb_queue_empty(&tq))
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
-		rcu_read_lock();
-		skb->dev = dev_get_by_index_rcu(&init_net, skb->iif);
-		if (!skb->dev) {
-			rcu_read_unlock();
-			dev_kfree_skb(skb);
-			stats->tx_dropped++;
+		finish_wait(&pq->wq, &wait);
+		if (kthread_should_stop()) {
+			__skb_queue_purge(&tq);
 			break;
 		}
-		rcu_read_unlock();
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
-
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
+		if (need_resched())
+			schedule();
+
+		/* transfer packets */
+		while ((skb = __skb_dequeue(&tq)) != NULL) {
+			u32 from = G_TC_FROM(skb->tc_verd);
+	
+			skb->tc_verd = 0;
+			skb->tc_verd = SET_TC_NCLS(skb->tc_verd);
+			txq->tx_packets++;
+			txq->tx_bytes +=skb->len;
+
+			rcu_read_lock();
+			_dev = dev_get_by_index_rcu(&init_net, skb->iif);
+			if (!_dev) {
+				rcu_read_unlock();
+				dev_kfree_skb(skb);
+				txq->tx_dropped++;
+				continue;
+			}
+			if (from & AT_INGRESS)
+				dev_hold(_dev);
+			rcu_read_unlock();
+			skb->dev = _dev;
+			skb->iif = dev->ifindex;
+	
+			if (from & AT_EGRESS) {
+				dev_queue_xmit(skb);
+			} else if (from & AT_INGRESS) {
+				skb_pull(skb, skb->dev->hard_header_len);
+				netif_rx_ni(skb);
+				dev_put(_dev);
+			} else
+				BUG();
 		}
-		__netif_tx_unlock(txq);
-	} else {
-resched:
-		dp->tasklet_pending = 1;
-		tasklet_schedule(&dp->ifb_tasklet);
 	}
 
+	return 0;
 }
 
-static const struct net_device_ops ifb_netdev_ops = {
-	.ndo_open	= ifb_open,
-	.ndo_stop	= ifb_close,
-	.ndo_start_xmit	= ifb_xmit,
-	.ndo_validate_addr = eth_validate_addr,
-};
-
-static void ifb_setup(struct net_device *dev)
+struct net_device_stats* ifb_get_stats(struct net_device *dev)
 {
-	/* Initialize the device structure. */
-	dev->destructor = free_netdev;
-	dev->netdev_ops = &ifb_netdev_ops;
+	struct net_device_stats *stats = &dev->stats;
+	struct ifb_private *dp = netdev_priv(dev);
+	struct ifb_private_q *pq = dp->pq;
+	struct netdev_queue *txq;
+	int i;
+	unsigned long rx_packets = 0, rx_bytes = 0, rx_dropped = 0;
+	unsigned long tx_packets = 0, tx_bytes = 0, tx_dropped = 0;
+
+	for (i = 0; i < dev->real_num_tx_queues; i++) {
+		rx_packets += pq[i].rx_packets;
+		rx_bytes += pq[i].rx_bytes;
+		rx_dropped += pq[i].rx_dropped;
+		txq = netdev_get_tx_queue(dev, i);
+		tx_packets += txq->tx_packets;
+		tx_bytes += txq->tx_bytes;
+		tx_dropped += txq->tx_dropped;
+	}
 
-	/* Fill in device structure with ethernet-generic values. */
-	ether_setup(dev);
-	dev->tx_queue_len = TX_Q_LIMIT;
+	stats->rx_packets = rx_packets;
+	stats->rx_bytes = rx_bytes;
+	stats->rx_dropped = rx_dropped;
+	stats->tx_packets = tx_packets;
+	stats->tx_bytes = tx_bytes;
+	stats->tx_dropped = tx_dropped;
 
-	dev->flags |= IFF_NOARP;
-	dev->flags &= ~IFF_MULTICAST;
-	dev->priv_flags &= ~IFF_XMIT_DST_RELEASE;
-	random_ether_addr(dev->dev_addr);
+	return stats;
 }
 
 static netdev_tx_t ifb_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct ifb_private *dp = netdev_priv(dev);
-	struct net_device_stats *stats = &dev->stats;
 	u32 from = G_TC_FROM(skb->tc_verd);
+	int num = skb_get_queue_mapping(skb);
+	struct ifb_private *dp = netdev_priv(dev);
+	struct ifb_private_q *pq = dp->pq + num;
+	struct netdev_queue *txq = netdev_get_tx_queue(dev, num);
 
-	stats->rx_packets++;
-	stats->rx_bytes+=skb->len;
+	pq->rx_packets++;
+	pq->rx_bytes += skb->len;
 
 	if (!(from & (AT_INGRESS|AT_EGRESS)) || !skb->iif) {
 		dev_kfree_skb(skb);
-		stats->rx_dropped++;
+		pq->rx_dropped++;
 		return NETDEV_TX_OK;
 	}
 
-	if (skb_queue_len(&dp->rq) >= dev->tx_queue_len) {
+	txq->trans_start = jiffies;
+	__skb_queue_tail(&pq->rq, skb);
+	if (skb_queue_len(&pq->rq) >= dev->tx_queue_len)
 		netif_stop_queue(dev);
-	}
-
-	dev->trans_start = jiffies;
-	skb_queue_tail(&dp->rq, skb);
-	if (!dp->tasklet_pending) {
-		dp->tasklet_pending = 1;
-		tasklet_schedule(&dp->ifb_tasklet);
-	}
+	if (skb_queue_len(&pq->rq) == 1)
+		wake_up(&pq->wq);
 
 	return NETDEV_TX_OK;
 }
@@ -195,26 +200,241 @@ static netdev_tx_t ifb_xmit(struct sk_buff *skb, struct net_device *dev)
 static int ifb_close(struct net_device *dev)
 {
 	struct ifb_private *dp = netdev_priv(dev);
+	struct ifb_private_q *pq = dp->pq;
+	int i;
 
-	tasklet_kill(&dp->ifb_tasklet);
 	netif_stop_queue(dev);
-	skb_queue_purge(&dp->rq);
-	skb_queue_purge(&dp->tq);
+	for (i = 0; i < dev->real_num_tx_queues; i++) {
+		kthread_stop(pq[i].task);
+		__skb_queue_purge(&pq[i].rq);
+	}
+
 	return 0;
 }
 
 static int ifb_open(struct net_device *dev)
 {
 	struct ifb_private *dp = netdev_priv(dev);
-
-	tasklet_init(&dp->ifb_tasklet, ri_tasklet, (unsigned long)dev);
-	skb_queue_head_init(&dp->rq);
-	skb_queue_head_init(&dp->tq);
+	struct ifb_private_q *pq = dp->pq;
+	int i;
+	
+	for (i = 0; i < dev->real_num_tx_queues; i++) {
+		pq[i].task = kthread_run(ifb_thread, &pq[i], "%s/%d", dev->name,
+					 i);
+		if (IS_ERR(pq[i].task)) {
+			int err = PTR_ERR(pq[i].task);
+			while (--i >= 0)
+				kthread_stop(pq[i].task);
+			return err;
+		}
+	}
 	netif_start_queue(dev);
 
 	return 0;
 }
 
+static u32 simple_tx_hashrnd;
+
+static inline __be16 pppoe_proto(const struct sk_buff *skb)
+{
+	return *((__be16 *)(skb_mac_header(skb) + ETH_HLEN +
+			sizeof(struct pppoe_hdr)));
+}
+
+static u8 ifb_ipv6_ihl(struct sk_buff *skb, u32 *pihl)
+{
+	struct ipv6hdr *hdr = ipv6_hdr(skb);
+	u32 ihl = sizeof(*hdr);
+	u8 nexthdr = hdr->nexthdr;
+
+	while (1) {
+		switch (nexthdr) {
+		case NEXTHDR_HOP:
+		case NEXTHDR_ROUTING:
+		case NEXTHDR_DEST:
+			if (!pskb_may_pull(skb, ihl + 8) ||
+			    !pskb_may_pull(skb, ihl +
+			    	((skb_network_header(skb)[ihl + 1] + 1) << 3)))
+			return 0;
+			nexthdr = skb_network_header(skb)[ihl];
+			ihl += (skb_network_header(skb)[ihl + 1] + 1) << 3;
+			break;
+		case NEXTHDR_AUTH:
+		case NEXTHDR_ESP:
+		case NEXTHDR_NONE:
+		case NEXTHDR_FRAGMENT:
+			return 0;
+		default:
+			*pihl = ihl;
+			return nexthdr;
+		}
+	}
+}
+
+static u16 ifb_select_queue(struct net_device *dev, struct sk_buff *skb)
+{
+	u32 addr1, addr2;
+	u32 hash, ihl = 0;
+	union {
+		u16 in16[2];
+		u32 in32;
+	} ports;
+	u8 ip_proto;
+	unsigned int pull_len;
+
+	if ((hash = skb_rx_queue_recorded(skb))) {
+		while (hash >= dev->real_num_tx_queues)
+			hash -= dev->real_num_tx_queues;
+		return hash;
+	}
+
+	pull_len = 0;
+	switch (skb->protocol) {
+	case __constant_htons(ETH_P_8021Q):
+		if (unlikely(skb_pull(skb, VLAN_HLEN) == NULL))
+			goto process_other;
+		pull_len = VLAN_HLEN;
+		skb->network_header += pull_len;
+		switch (vlan_eth_hdr(skb)->h_vlan_encapsulated_proto) {
+		case __constant_htons(ETH_P_IP):
+			goto process_ip;
+		case __constant_htons(ETH_P_IPV6):
+			goto process_ipv6;
+		default:
+			goto process_other;
+		}
+		break;
+	case __constant_htons(ETH_P_PPP_SES):
+		if (unlikely(skb_pull(skb, PPPOE_SES_HLEN) == NULL))
+			goto process_other;
+		pull_len = PPPOE_SES_HLEN;
+		skb->network_header += pull_len;
+		switch (pppoe_proto(skb)) {
+		case __constant_htons(ETH_P_IP):
+			goto process_ip;
+		case __constant_htons(ETH_P_IPV6):
+			goto process_ipv6;
+		default:
+			goto process_other;
+		}
+		break;
+	case __constant_htons(ETH_P_IP):
+process_ip:
+		if (unlikely(!pskb_may_pull(skb, sizeof(struct iphdr))))
+			goto process_other;
+		if (!(ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET)))
+			ip_proto = ip_hdr(skb)->protocol;
+		else
+			ip_proto = 0;
+		addr1 = ip_hdr(skb)->saddr;
+		addr2 = ip_hdr(skb)->daddr;
+		ihl = ip_hdrlen(skb);
+		break;
+	case __constant_htons(ETH_P_IPV6):
+process_ipv6:
+		if (unlikely(!pskb_may_pull(skb, sizeof(struct ipv6hdr))))
+			goto process_other;
+		addr1 = ipv6_hdr(skb)->saddr.s6_addr32[3];
+		addr2 = ipv6_hdr(skb)->daddr.s6_addr32[3];
+		ip_proto = ifb_ipv6_ihl(skb, &ihl);
+		break;
+	default:
+process_other:
+		if (pull_len != 0) {
+			skb_push(skb, pull_len);
+			skb->network_header -= pull_len;
+		}
+		return skb->protocol % dev->real_num_tx_queues;
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
+		if (unlikely(!pskb_may_pull(skb, ihl + 4)))
+			goto process_other_trans;
+		ports.in32 = *((u32 *) (skb_network_header(skb) + ihl));
+		if (ports.in16[0] > ports.in16[1])
+			swap(ports.in16[0], ports.in16[1]);
+		break;
+
+	default:
+process_other_trans:
+		ports.in32 = 0;
+		break;
+	}
+
+	if (pull_len != 0) {
+		skb_push(skb, pull_len);
+		skb->network_header -= pull_len;
+	}
+
+	hash = jhash_3words(addr1, addr2, ports.in32,
+			    simple_tx_hashrnd ^ ip_proto);
+
+	return (u16) (((u64) hash * dev->real_num_tx_queues) >> 32);
+}
+
+static int ifb_init(struct net_device *dev)
+{
+	struct ifb_private *dp = netdev_priv(dev);
+	struct ifb_private_q *pq = dp->pq;
+	int i;
+
+	pq = kcalloc(dev->real_num_tx_queues, sizeof(*pq), GFP_KERNEL);
+	if (pq == NULL)
+		return -ENOMEM;
+	dp->pq = pq;
+
+	for (i = 0; i < dev->real_num_tx_queues; i++) {
+		pq[i].dev = dev;
+		__skb_queue_head_init(&pq[i].rq);
+		init_waitqueue_head(&pq[i].wq);
+	}
+
+	return 0;
+}
+
+static void ifb_uninit(struct net_device *dev)
+{
+	struct ifb_private *dp = netdev_priv(dev);
+
+	kfree(dp->pq);
+}
+
+static const struct net_device_ops ifb_netdev_ops = {
+	.ndo_init		= ifb_init,
+	.ndo_uninit		= ifb_uninit,
+	.ndo_open		= ifb_open,
+	.ndo_stop		= ifb_close,
+	.ndo_start_xmit		= ifb_xmit,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_select_queue	= ifb_select_queue,
+	.ndo_get_stats		= ifb_get_stats,
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
@@ -226,25 +446,38 @@ static int ifb_validate(struct nlattr *tb[], struct nlattr *data[])
 	return 0;
 }
 
+static int ifb_get_tx_queues(struct net *net, struct nlattr *tb[],
+			     unsigned int *num_tx_queues,
+			     unsigned int *real_num_tx_queues)
+{
+	if (tb[IFLA_NTXQ]) {
+		*num_tx_queues = nla_get_u32(tb[IFLA_NTXQ]);
+		if (*num_tx_queues < 1)
+			return -EINVAL;
+		*real_num_tx_queues = *num_tx_queues;
+	} else {
+		*num_tx_queues = numtxqs;
+		*real_num_tx_queues = numtxqs;
+	}
+
+	return 0;
+}
+
 static struct rtnl_link_ops ifb_link_ops __read_mostly = {
 	.kind		= "ifb",
-	.priv_size	= sizeof(struct ifb_private),
 	.setup		= ifb_setup,
 	.validate	= ifb_validate,
+	.get_tx_queues	= ifb_get_tx_queues,
+	.priv_size	= sizeof(struct ifb_private),
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
-
+	dev_ifb = alloc_netdev_mq(sizeof(struct ifb_private), "ifb%d",
+				  ifb_setup, numtxqs);
 	if (!dev_ifb)
 		return -ENOMEM;
 
@@ -268,9 +501,12 @@ static int __init ifb_init_module(void)
 {
 	int i, err;
 
+	if (numtxqs < 1)
+		return -EINVAL;
+
+	get_random_bytes(&simple_tx_hashrnd, 4);
 	rtnl_lock();
 	err = __rtnl_link_register(&ifb_link_ops);
-
 	for (i = 0; i < numifbs && !err; i++)
 		err = ifb_init_one(i);
 	if (err)
diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 1d3b242..99da411 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -78,6 +78,7 @@ enum {
 #define IFLA_LINKINFO IFLA_LINKINFO
 	IFLA_NET_NS_PID,
 	IFLA_IFALIAS,
+	IFLA_NTXQ,
 	__IFLA_MAX
 };
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 33148a5..1cbe555 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -597,6 +597,7 @@ static inline size_t if_nlmsg_size(const struct net_device *dev)
 	       + nla_total_size(4) /* IFLA_MASTER */
 	       + nla_total_size(1) /* IFLA_OPERSTATE */
 	       + nla_total_size(1) /* IFLA_LINKMODE */
+	       + nla_total_size(4) /* IFLA_NTXQ */
 	       + rtnl_link_get_size(dev); /* IFLA_LINKINFO */
 }
 
@@ -627,6 +628,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 		   netif_running(dev) ? dev->operstate : IF_OPER_DOWN);
 	NLA_PUT_U8(skb, IFLA_LINKMODE, dev->link_mode);
 	NLA_PUT_U32(skb, IFLA_MTU, dev->mtu);
+	NLA_PUT_U32(skb, IFLA_NTXQ, dev->real_num_tx_queues);
 
 	if (dev->ifindex != dev->iflink)
 		NLA_PUT_U32(skb, IFLA_LINK, dev->iflink);
@@ -725,6 +727,7 @@ const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_LINKINFO]		= { .type = NLA_NESTED },
 	[IFLA_NET_NS_PID]	= { .type = NLA_U32 },
 	[IFLA_IFALIAS]	        = { .type = NLA_STRING, .len = IFALIASZ-1 },
+	[IFLA_NTXQ]		= { .type = NLA_U32 },
 };
 EXPORT_SYMBOL(ifla_policy);
 


