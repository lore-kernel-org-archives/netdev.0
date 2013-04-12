From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: GSO should be TSQ friendly
Date: Fri, 12 Apr 2013 14:31:52 -0700
Message-ID: <1365802312.4459.82.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Tom Herbert <therbert@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:37135 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751998Ab3DLVby (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 17:31:54 -0400
Received: by mail-pa0-f41.google.com with SMTP id kx1so1670418pab.0
        for <netdev@vger.kernel.org>; Fri, 12 Apr 2013 14:31:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

I noticed that TSQ (TCP Small queues) was less effective when TSO is
turned off, and GSO is on. If BQL is not enabled, TSQ has then no
effect.

It turns out the GSO engine frees the original gso_skb at the time the
fragments are generated and queued to the NIC.

We should instead call the tcp_wfree() destructor for the last fragment,
to keep the flow control as intended in TSQ. This effectively limits
the number of queued packets on qdisc + NIC layers.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Tom Herbert <therbert@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Nandita Dukkipati <nanditad@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
---
 include/net/tcp.h     |    1 +
 net/ipv4/tcp.c        |   12 ++++++++++++
 net/ipv4/tcp_output.c |    2 +-
 3 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 4475aaf..5bba80f 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -370,6 +370,7 @@ extern int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 extern int tcp_sendpage(struct sock *sk, struct page *page, int offset,
 			size_t size, int flags);
 extern void tcp_release_cb(struct sock *sk);
+extern void tcp_wfree(struct sk_buff *skb);
 extern void tcp_write_timer_handler(struct sock *sk);
 extern void tcp_delack_timer_handler(struct sock *sk);
 extern int tcp_ioctl(struct sock *sk, int cmd, unsigned long arg);
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index a96f7b5..963bda1 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2885,6 +2885,7 @@ struct sk_buff *tcp_tso_segment(struct sk_buff *skb,
 	__be32 delta;
 	unsigned int oldlen;
 	unsigned int mss;
+	struct sk_buff *gso_skb = skb;
 
 	if (!pskb_may_pull(skb, sizeof(*th)))
 		goto out;
@@ -2953,6 +2954,17 @@ struct sk_buff *tcp_tso_segment(struct sk_buff *skb,
 		th->cwr = 0;
 	} while (skb->next);
 
+	/* Following permits TCP Small Queues to work well with GSO :
+	 * The callback to TCP stack will be called at the time last frag
+	 * is freed at TX completion, and not right now when gso_skb
+	 * is freed by GSO engine
+	 */
+	if (gso_skb->destructor == tcp_wfree) {
+		swap(gso_skb->sk, skb->sk);
+		swap(gso_skb->destructor, skb->destructor);
+		swap(gso_skb->truesize, skb->truesize);
+	}
+
 	delta = htonl(oldlen + (skb->tail - skb->transport_header) +
 		      skb->data_len);
 	th->check = ~csum_fold((__force __wsum)((__force u32)th->check +
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index af354c98..d126943 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -787,7 +787,7 @@ void __init tcp_tasklet_init(void)
  * We cant xmit new skbs from this context, as we might already
  * hold qdisc lock.
  */
-static void tcp_wfree(struct sk_buff *skb)
+void tcp_wfree(struct sk_buff *skb)
 {
 	struct sock *sk = skb->sk;
 	struct tcp_sock *tp = tcp_sk(sk);
