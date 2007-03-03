From: Chris Leech <christopher.leech@intel.com>
Subject: [PATCH 7/9] I/OAT: Only offload copies for TCP when there will be a context switch
Date: Fri, 02 Mar 2007 18:24:30 -0800
Message-ID: <20070303022430.31033.18636.stgit@gitlost.site>
References: <20070303022238.31033.84558.stgit@gitlost.site>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S2992905AbXCCCjT@vger.kernel.org>
In-Reply-To: <20070303022238.31033.84558.stgit@gitlost.site>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The performance wins come with having the DMA copy engine doing the copies
in parallel with the context switch.  If there is enough data ready on the
socket at recv time just use a regular copy.

Signed-off-by: Chris Leech <christopher.leech@intel.com>
---

 net/ipv4/tcp.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 74c4d10..5ccd5e1 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1110,6 +1110,8 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	long timeo;
 	struct task_struct *user_recv = NULL;
 	int copied_early = 0;
+	int available = 0;
+	struct sk_buff *skb;
 
 	lock_sock(sk);
 
@@ -1136,7 +1138,11 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 #ifdef CONFIG_NET_DMA
 	tp->ucopy.dma_chan = NULL;
 	preempt_disable();
-	if ((len > sysctl_tcp_dma_copybreak) && !(flags & MSG_PEEK) &&
+	skb = skb_peek_tail(&sk->sk_receive_queue);
+	if (skb)
+		available = TCP_SKB_CB(skb)->seq + skb->len - (*seq);
+	if ((available < target) &&
+	    (len > sysctl_tcp_dma_copybreak) && !(flags & MSG_PEEK) &&
 	    !sysctl_tcp_low_latency && __get_cpu_var(softnet_data).net_dma) {
 		preempt_enable_no_resched();
 		tp->ucopy.pinned_list = dma_pin_iovec_pages(msg->msg_iov, len);
@@ -1145,7 +1151,6 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 #endif
 
 	do {
-		struct sk_buff *skb;
 		u32 offset;
 
 		/* Are we at urgent data? Stop if we have read anything or have SIGURG pending. */
@@ -1433,7 +1438,6 @@ skip_copy:
 
 #ifdef CONFIG_NET_DMA
 	if (tp->ucopy.dma_chan) {
-		struct sk_buff *skb;
 		dma_cookie_t done, used;
 
 		dma_async_memcpy_issue_pending(tp->ucopy.dma_chan);
