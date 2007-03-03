From: Chris Leech <christopher.leech@intel.com>
Subject: [PATCH 8/9] I/OAT: warning fix
Date: Fri, 02 Mar 2007 18:24:32 -0800
Message-ID: <20070303022432.31033.19248.stgit@gitlost.site>
References: <20070303022238.31033.84558.stgit@gitlost.site>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S2992926AbXCCCmO@vger.kernel.org>
In-Reply-To: <20070303022238.31033.84558.stgit@gitlost.site>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

net/ipv4/tcp.c: In function 'tcp_recvmsg':
net/ipv4/tcp.c:1111: warning: unused variable 'available'

Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Chris Leech <christopher.leech@intel.com>
---

 net/ipv4/tcp.c |   26 ++++++++++++++++----------
 1 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 5ccd5e1..69c525d 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1110,7 +1110,6 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	long timeo;
 	struct task_struct *user_recv = NULL;
 	int copied_early = 0;
-	int available = 0;
 	struct sk_buff *skb;
 
 	lock_sock(sk);
@@ -1139,15 +1138,22 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	tp->ucopy.dma_chan = NULL;
 	preempt_disable();
 	skb = skb_peek_tail(&sk->sk_receive_queue);
-	if (skb)
-		available = TCP_SKB_CB(skb)->seq + skb->len - (*seq);
-	if ((available < target) &&
-	    (len > sysctl_tcp_dma_copybreak) && !(flags & MSG_PEEK) &&
-	    !sysctl_tcp_low_latency && __get_cpu_var(softnet_data).net_dma) {
-		preempt_enable_no_resched();
-		tp->ucopy.pinned_list = dma_pin_iovec_pages(msg->msg_iov, len);
-	} else
-		preempt_enable_no_resched();
+	{
+		int available = 0;
+
+		if (skb)
+			available = TCP_SKB_CB(skb)->seq + skb->len - (*seq);
+		if ((available < target) &&
+		    (len > sysctl_tcp_dma_copybreak) && !(flags & MSG_PEEK) &&
+		    !sysctl_tcp_low_latency &&
+		    __get_cpu_var(softnet_data).net_dma) {
+			preempt_enable_no_resched();
+			tp->ucopy.pinned_list =
+					dma_pin_iovec_pages(msg->msg_iov, len);
+		} else {
+			preempt_enable_no_resched();
+		}
+	}
 #endif
 
 	do {
