From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH 06/13] net_dma: convert to dma_find_channel
Date: Fri, 14 Nov 2008 14:34:48 -0700
Message-ID: <20081114213447.32354.34821.stgit@dwillia2-linux.ch.intel.com>
References: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: maciej.sosnowski@intel.com, hskinnemoen@atmel.com,
	g.liakhovetski@gmx.de, nicolas.ferre@atmel.com
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:27491 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755746AbYKNVev (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Nov 2008 16:34:51 -0500
In-Reply-To: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the general-purpose channel allocation provided by dmaengine.

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---

 include/linux/netdevice.h |    3 ---
 include/net/netdma.h      |   11 -----------
 net/core/dev.c            |   40 ----------------------------------------
 net/ipv4/tcp.c            |    4 ++--
 net/ipv4/tcp_input.c      |    2 +-
 net/ipv4/tcp_ipv4.c       |    2 +-
 net/ipv6/tcp_ipv6.c       |    2 +-
 7 files changed, 5 insertions(+), 59 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9d77b1d..800866e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1004,9 +1004,6 @@ struct softnet_data
 	struct sk_buff		*completion_queue;
 
 	struct napi_struct	backlog;
-#ifdef CONFIG_NET_DMA
-	struct dma_chan		*net_dma;
-#endif
 };
 
 DECLARE_PER_CPU(struct softnet_data,softnet_data);
diff --git a/include/net/netdma.h b/include/net/netdma.h
index cbe2737..8ba8ce2 100644
--- a/include/net/netdma.h
+++ b/include/net/netdma.h
@@ -24,17 +24,6 @@
 #include <linux/dmaengine.h>
 #include <linux/skbuff.h>
 
-static inline struct dma_chan *get_softnet_dma(void)
-{
-	struct dma_chan *chan;
-
-	rcu_read_lock();
-	chan = rcu_dereference(__get_cpu_var(softnet_data).net_dma);
-	rcu_read_unlock();
-
-	return chan;
-}
-
 int dma_skb_copy_datagram_iovec(struct dma_chan* chan,
 		struct sk_buff *skb, int offset, struct iovec *to,
 		size_t len, struct dma_pinned_list *pinned_list);
diff --git a/net/core/dev.c b/net/core/dev.c
index 301a449..56e6965 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4591,44 +4591,6 @@ static int dev_cpu_callback(struct notifier_block *nfb,
 
 #ifdef CONFIG_NET_DMA
 /**
- * net_dma_rebalance - try to maintain one DMA channel per CPU
- * @net_dma: DMA client and associated data (lock, channels, channel_mask)
- *
- * This is called when the number of channels allocated to the net_dma client
- * changes.  The net_dma client tries to have one DMA channel per CPU.
- */
-
-static void net_dma_rebalance(struct net_dma *net_dma)
-{
-	unsigned int cpu, i, n, chan_idx;
-	struct dma_chan *chan;
-
-	if (cpus_empty(net_dma->channel_mask)) {
-		for_each_online_cpu(cpu)
-			rcu_assign_pointer(per_cpu(softnet_data, cpu).net_dma, NULL);
-		return;
-	}
-
-	i = 0;
-	cpu = first_cpu(cpu_online_map);
-
-	for_each_cpu_mask_nr(chan_idx, net_dma->channel_mask) {
-		chan = net_dma->channels[chan_idx];
-
-		n = ((num_online_cpus() / cpus_weight(net_dma->channel_mask))
-		   + (i < (num_online_cpus() %
-			cpus_weight(net_dma->channel_mask)) ? 1 : 0));
-
-		while(n) {
-			per_cpu(softnet_data, cpu).net_dma = chan;
-			cpu = next_cpu(cpu, cpu_online_map);
-			n--;
-		}
-		i++;
-	}
-}
-
-/**
  * netdev_dma_event - event callback for the net_dma_client
  * @client: should always be net_dma_client
  * @chan: DMA channel for the event
@@ -4657,7 +4619,6 @@ netdev_dma_event(struct dma_client *client, struct dma_chan *chan,
 			ack = DMA_ACK;
 			net_dma->channels[pos] = chan;
 			cpu_set(pos, net_dma->channel_mask);
-			net_dma_rebalance(net_dma);
 		}
 		break;
 	case DMA_RESOURCE_REMOVED:
@@ -4672,7 +4633,6 @@ netdev_dma_event(struct dma_client *client, struct dma_chan *chan,
 			ack = DMA_ACK;
 			cpu_clear(pos, net_dma->channel_mask);
 			net_dma->channels[i] = NULL;
-			net_dma_rebalance(net_dma);
 		}
 		break;
 	default:
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 40ec69f..5da9edb 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1315,7 +1315,7 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		if ((available < target) &&
 		    (len > sysctl_tcp_dma_copybreak) && !(flags & MSG_PEEK) &&
 		    !sysctl_tcp_low_latency &&
-		    __get_cpu_var(softnet_data).net_dma) {
+		    dma_find_channel(DMA_MEMCPY)) {
 			preempt_enable_no_resched();
 			tp->ucopy.pinned_list =
 					dma_pin_iovec_pages(msg->msg_iov, len);
@@ -1525,7 +1525,7 @@ do_prequeue:
 		if (!(flags & MSG_TRUNC)) {
 #ifdef CONFIG_NET_DMA
 			if (!tp->ucopy.dma_chan && tp->ucopy.pinned_list)
-				tp->ucopy.dma_chan = get_softnet_dma();
+				tp->ucopy.dma_chan = dma_find_channel(DMA_MEMCPY);
 
 			if (tp->ucopy.dma_chan) {
 				tp->ucopy.dma_cookie = dma_skb_copy_datagram_iovec(
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d77c0d2..620ca4e 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4682,7 +4682,7 @@ static int tcp_dma_try_early_copy(struct sock *sk, struct sk_buff *skb,
 		return 0;
 
 	if (!tp->ucopy.dma_chan && tp->ucopy.pinned_list)
-		tp->ucopy.dma_chan = get_softnet_dma();
+		tp->ucopy.dma_chan = dma_find_channel(DMA_MEMCPY);
 
 	if (tp->ucopy.dma_chan && skb_csum_unnecessary(skb)) {
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 5c8fa7f..b671d49 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1600,7 +1600,7 @@ process:
 #ifdef CONFIG_NET_DMA
 		struct tcp_sock *tp = tcp_sk(sk);
 		if (!tp->ucopy.dma_chan && tp->ucopy.pinned_list)
-			tp->ucopy.dma_chan = get_softnet_dma();
+			tp->ucopy.dma_chan = dma_find_channel(DMA_MEMCPY);
 		if (tp->ucopy.dma_chan)
 			ret = tcp_v4_do_rcv(sk, skb);
 		else
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index b6b356b..d41a896 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1640,7 +1640,7 @@ process:
 #ifdef CONFIG_NET_DMA
 		struct tcp_sock *tp = tcp_sk(sk);
 		if (!tp->ucopy.dma_chan && tp->ucopy.pinned_list)
-			tp->ucopy.dma_chan = get_softnet_dma();
+			tp->ucopy.dma_chan = dma_find_channel(DMA_MEMCPY);
 		if (tp->ucopy.dma_chan)
 			ret = tcp_v6_do_rcv(sk, skb);
 		else

