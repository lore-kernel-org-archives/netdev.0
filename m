From: Dave Jiang <dave.jiang@intel.com>
Subject: [PATCH 3/3] netdma: adding alignment check for NETDMA ops
Date: Wed, 04 Apr 2012 16:10:46 -0700
Message-ID: <20120404231046.20605.13918.stgit@djiang5-linux.ch.intel.com>
References: <20120404230749.20605.7000.stgit@djiang5-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Dave Jiang <dave.jiang@intel.com>
To: dan.j.williams@intel.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120404230749.20605.7000.stgit@djiang5-linux.ch.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is the fallout from adding memcpy alignment workaround for certain
IOATDMA hardware. NetDMA will only use DMA engine that can handle byte align
ops.

Signed-off-by: Dave Jiang <dave.jiang@intel.com>
---

 drivers/dma/dmaengine.c   |   14 ++++++++++++++
 include/linux/dmaengine.h |    1 +
 net/ipv4/tcp.c            |    4 ++--
 net/ipv4/tcp_input.c      |    2 +-
 net/ipv4/tcp_ipv4.c       |    2 +-
 net/ipv6/tcp_ipv6.c       |    2 +-
 6 files changed, 20 insertions(+), 5 deletions(-)

diff --git a/drivers/dma/dmaengine.c b/drivers/dma/dmaengine.c
index a6c6051..0f1ca74 100644
--- a/drivers/dma/dmaengine.c
+++ b/drivers/dma/dmaengine.c
@@ -332,6 +332,20 @@ struct dma_chan *dma_find_channel(enum dma_transaction_type tx_type)
 }
 EXPORT_SYMBOL(dma_find_channel);
 
+/*
+ * net_dma_find_channel - find a channel for net_dma
+ * net_dma has alignment requirements
+ */
+struct dma_chan *net_dma_find_channel(void)
+{
+	struct dma_chan *chan = dma_find_channel(DMA_MEMCPY);
+	if (chan && !is_dma_copy_aligned(chan->device, 1, 1, 1))
+		return NULL;
+
+	return chan;
+}
+EXPORT_SYMBOL(net_dma_find_channel);
+
 /**
  * dma_issue_pending_all - flush all pending operations across all channels
  */
diff --git a/include/linux/dmaengine.h b/include/linux/dmaengine.h
index 679b349..a5bb3ad 100644
--- a/include/linux/dmaengine.h
+++ b/include/linux/dmaengine.h
@@ -948,6 +948,7 @@ int dma_async_device_register(struct dma_device *device);
 void dma_async_device_unregister(struct dma_device *device);
 void dma_run_dependencies(struct dma_async_tx_descriptor *tx);
 struct dma_chan *dma_find_channel(enum dma_transaction_type tx_type);
+struct dma_chan *net_dma_find_channel(void);
 #define dma_request_channel(mask, x, y) __dma_request_channel(&(mask), x, y)
 
 /* --- Helper iov-locking functions --- */
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 22ef5f9..8712c5d 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1450,7 +1450,7 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		if ((available < target) &&
 		    (len > sysctl_tcp_dma_copybreak) && !(flags & MSG_PEEK) &&
 		    !sysctl_tcp_low_latency &&
-		    dma_find_channel(DMA_MEMCPY)) {
+		    net_dma_find_channel()) {
 			preempt_enable_no_resched();
 			tp->ucopy.pinned_list =
 					dma_pin_iovec_pages(msg->msg_iov, len);
@@ -1665,7 +1665,7 @@ do_prequeue:
 		if (!(flags & MSG_TRUNC)) {
 #ifdef CONFIG_NET_DMA
 			if (!tp->ucopy.dma_chan && tp->ucopy.pinned_list)
-				tp->ucopy.dma_chan = dma_find_channel(DMA_MEMCPY);
+				tp->ucopy.dma_chan = net_dma_find_channel();
 
 			if (tp->ucopy.dma_chan) {
 				tp->ucopy.dma_cookie = dma_skb_copy_datagram_iovec(
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index b5e315f..27c676d 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5190,7 +5190,7 @@ static int tcp_dma_try_early_copy(struct sock *sk, struct sk_buff *skb,
 		return 0;
 
 	if (!tp->ucopy.dma_chan && tp->ucopy.pinned_list)
-		tp->ucopy.dma_chan = dma_find_channel(DMA_MEMCPY);
+		tp->ucopy.dma_chan = net_dma_find_channel();
 
 	if (tp->ucopy.dma_chan && skb_csum_unnecessary(skb)) {
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index fd54c5f..3810b6f 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1727,7 +1727,7 @@ process:
 #ifdef CONFIG_NET_DMA
 		struct tcp_sock *tp = tcp_sk(sk);
 		if (!tp->ucopy.dma_chan && tp->ucopy.pinned_list)
-			tp->ucopy.dma_chan = dma_find_channel(DMA_MEMCPY);
+			tp->ucopy.dma_chan = net_dma_find_channel();
 		if (tp->ucopy.dma_chan)
 			ret = tcp_v4_do_rcv(sk, skb);
 		else
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 3edd05a..fcb3e4f 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1755,7 +1755,7 @@ process:
 #ifdef CONFIG_NET_DMA
 		struct tcp_sock *tp = tcp_sk(sk);
 		if (!tp->ucopy.dma_chan && tp->ucopy.pinned_list)
-			tp->ucopy.dma_chan = dma_find_channel(DMA_MEMCPY);
+			tp->ucopy.dma_chan = net_dma_find_channel();
 		if (tp->ucopy.dma_chan)
 			ret = tcp_v6_do_rcv(sk, skb);
 		else
