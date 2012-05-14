From: Jiang Liu <liuj97@gmail.com>
Subject: [RFC PATCH v2 4/7] dmaengine: enhance network subsystem to support DMA device hotplug
Date: Mon, 14 May 2012 21:47:06 +0800
Message-ID: <1337003229-9158-5-git-send-email-jiang.liu@huawei.com>
References: <1337003229-9158-1-git-send-email-jiang.liu@huawei.com>
Cc: Jiang Liu <jiang.liu@huawei.com>,
	Keping Chen <chenkeping@huawei.com>,
	linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Jiang Liu <liuj97@gmail.com>
To: Dan Williams <dan.j.williams@intel.com>,
	Maciej Sosnowski <maciej.sosnowski@intel.com>,
	Vinod Koul <vinod.koul@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:61835 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755210Ab2ENNuc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 09:50:32 -0400
In-Reply-To: <1337003229-9158-1-git-send-email-jiang.liu@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiang Liu <jiang.liu@huawei.com>

Enhance network subsystem to correctly update DMA channel reference counts,
so it won't break DMA device hotplug logic.

Signed-off-by: Jiang Liu <liuj97@gmail.com>
---
 include/net/netdma.h |   26 ++++++++++++++++++++++++++
 net/ipv4/tcp.c       |   10 +++-------
 net/ipv4/tcp_input.c |    5 +----
 net/ipv4/tcp_ipv4.c  |    4 +---
 net/ipv6/tcp_ipv6.c  |    4 +---
 5 files changed, 32 insertions(+), 17 deletions(-)

diff --git a/include/net/netdma.h b/include/net/netdma.h
index 8ba8ce2..6d71724 100644
--- a/include/net/netdma.h
+++ b/include/net/netdma.h
@@ -24,6 +24,32 @@
 #include <linux/dmaengine.h>
 #include <linux/skbuff.h>
 
+static inline bool
+net_dma_capable(void)
+{
+	struct dma_chan *chan = net_dma_find_channel();
+	dma_put_channel(chan);
+
+	return !!chan;
+}
+
+static inline struct dma_chan *
+net_dma_get_channel(struct tcp_sock *tp)
+{
+	if (!tp->ucopy.dma_chan && tp->ucopy.pinned_list)
+		tp->ucopy.dma_chan = net_dma_find_channel();
+	return tp->ucopy.dma_chan;
+}
+
+static inline void
+net_dma_put_channel(struct tcp_sock *tp)
+{
+	if (tp->ucopy.dma_chan) {
+		dma_put_channel(tp->ucopy.dma_chan);
+		tp->ucopy.dma_chan = NULL;
+	}
+}
+
 int dma_skb_copy_datagram_iovec(struct dma_chan* chan,
 		struct sk_buff *skb, int offset, struct iovec *to,
 		size_t len, struct dma_pinned_list *pinned_list);
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 8bb6ade..aea4032 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1451,8 +1451,7 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 			available = TCP_SKB_CB(skb)->seq + skb->len - (*seq);
 		if ((available < target) &&
 		    (len > sysctl_tcp_dma_copybreak) && !(flags & MSG_PEEK) &&
-		    !sysctl_tcp_low_latency &&
-		    net_dma_find_channel()) {
+		    !sysctl_tcp_low_latency && net_dma_capable()) {
 			preempt_enable_no_resched();
 			tp->ucopy.pinned_list =
 					dma_pin_iovec_pages(msg->msg_iov, len);
@@ -1666,10 +1665,7 @@ do_prequeue:
 
 		if (!(flags & MSG_TRUNC)) {
 #ifdef CONFIG_NET_DMA
-			if (!tp->ucopy.dma_chan && tp->ucopy.pinned_list)
-				tp->ucopy.dma_chan = net_dma_find_channel();
-
-			if (tp->ucopy.dma_chan) {
+			if (net_dma_get_channel(tp)) {
 				tp->ucopy.dma_cookie = dma_skb_copy_datagram_iovec(
 					tp->ucopy.dma_chan, skb, offset,
 					msg->msg_iov, used,
@@ -1758,7 +1754,7 @@ skip_copy:
 
 #ifdef CONFIG_NET_DMA
 	tcp_service_net_dma(sk, true);  /* Wait for queue to drain */
-	tp->ucopy.dma_chan = NULL;
+	net_dma_put_channel(tp);
 
 	if (tp->ucopy.pinned_list) {
 		dma_unpin_iovec_pages(tp->ucopy.pinned_list);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 9944c1d..3878916 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5227,10 +5227,7 @@ static int tcp_dma_try_early_copy(struct sock *sk, struct sk_buff *skb,
 	if (tp->ucopy.wakeup)
 		return 0;
 
-	if (!tp->ucopy.dma_chan && tp->ucopy.pinned_list)
-		tp->ucopy.dma_chan = net_dma_find_channel();
-
-	if (tp->ucopy.dma_chan && skb_csum_unnecessary(skb)) {
+	if (net_dma_get_channel(tp) && skb_csum_unnecessary(skb)) {
 
 		dma_cookie = dma_skb_copy_datagram_iovec(tp->ucopy.dma_chan,
 							 skb, hlen,
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 0cb86ce..90ea1c0 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1729,9 +1729,7 @@ process:
 	if (!sock_owned_by_user(sk)) {
 #ifdef CONFIG_NET_DMA
 		struct tcp_sock *tp = tcp_sk(sk);
-		if (!tp->ucopy.dma_chan && tp->ucopy.pinned_list)
-			tp->ucopy.dma_chan = net_dma_find_channel();
-		if (tp->ucopy.dma_chan)
+		if (net_dma_get_channel(tp))
 			ret = tcp_v4_do_rcv(sk, skb);
 		else
 #endif
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 86cfe60..fb81bbd 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1644,9 +1644,7 @@ process:
 	if (!sock_owned_by_user(sk)) {
 #ifdef CONFIG_NET_DMA
 		struct tcp_sock *tp = tcp_sk(sk);
-		if (!tp->ucopy.dma_chan && tp->ucopy.pinned_list)
-			tp->ucopy.dma_chan = net_dma_find_channel();
-		if (tp->ucopy.dma_chan)
+		if (net_dma_get_channel(tp))
 			ret = tcp_v6_do_rcv(sk, skb);
 		else
 #endif
-- 
1.7.9.5
