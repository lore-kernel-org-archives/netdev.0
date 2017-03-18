From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Subject: [PATCH net 1/2] tcp: fix SCM_TIMESTAMPING_OPT_STATS for normal skbs
Date: Sat, 18 Mar 2017 17:02:59 -0400
Message-ID: <20170318210300.163288-1-soheil.kdev@gmail.com>
Cc: zzoru007@gmail.com, Soheil Hassas Yeganeh <soheil@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:33166 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751187AbdCRVMZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 18 Mar 2017 17:12:25 -0400
Received: by mail-qt0-f196.google.com with SMTP id r45so13363433qte.0
        for <netdev@vger.kernel.org>; Sat, 18 Mar 2017 14:12:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Soheil Hassas Yeganeh <soheil@google.com>

__sock_recv_timestamp can be called for both normal skbs (for
receive timestamps) and for skbs on the error queue (for transmit
timestamps).

Commit 1c885808e456
(tcp: SOF_TIMESTAMPING_OPT_STATS option for SO_TIMESTAMPING)
assumes any skb passed to __sock_recv_timestamp are from
the error queue, containing OPT_STATS in the content of the skb.
This results in accessing invalid memory or generating junk
data.

To fix this, set skb->pkt_type to PACKET_OUTGOING for packets
on the error queue. This is safe because on the receive path
on local sockets skb->pkt_type is never set to PACKET_OUTGOING.
With that, copy OPT_STATS from a packet, only if its pkt_type
is PACKET_OUTGOING.

Fixes: 1c885808e456 ("tcp: SOF_TIMESTAMPING_OPT_STATS option for SO_TIMESTAMPING")
Reported-by: JongHwan Kim <zzoru007@gmail.com>
Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/core/skbuff.c | 10 ++++++++++
 net/socket.c      | 13 ++++++++++++-
 2 files changed, 22 insertions(+), 1 deletion(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index cd4ba8c6b609..b1fbd1958eb6 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3694,6 +3694,15 @@ static void sock_rmem_free(struct sk_buff *skb)
 	atomic_sub(skb->truesize, &sk->sk_rmem_alloc);
 }
 
+static void skb_set_err_queue(struct sk_buff *skb)
+{
+	/* pkt_type of skbs received on local sockets is never PACKET_OUTGOING.
+	 * So, it is safe to (mis)use it to mark skbs on the error queue.
+	 */
+	skb->pkt_type = PACKET_OUTGOING;
+	BUILD_BUG_ON(PACKET_OUTGOING == 0);
+}
+
 /*
  * Note: We dont mem charge error packets (no sk_forward_alloc changes)
  */
@@ -3707,6 +3716,7 @@ int sock_queue_err_skb(struct sock *sk, struct sk_buff *skb)
 	skb->sk = sk;
 	skb->destructor = sock_rmem_free;
 	atomic_add(skb->truesize, &sk->sk_rmem_alloc);
+	skb_set_err_queue(skb);
 
 	/* before exiting rcu section, make sure dst is refcounted */
 	skb_dst_force(skb);
diff --git a/net/socket.c b/net/socket.c
index e034fe4164be..692d6989d2c2 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -652,6 +652,16 @@ int kernel_sendmsg(struct socket *sock, struct msghdr *msg,
 }
 EXPORT_SYMBOL(kernel_sendmsg);
 
+static bool skb_is_err_queue(const struct sk_buff *skb)
+{
+	/* pkt_type of skbs enqueued on the error queue are set to
+	 * PACKET_OUTGOING in skb_set_err_queue(). This is only safe to do
+	 * in recvmsg, since skbs received on a local socket will never
+	 * have a pkt_type of PACKET_OUTGOING.
+	 */
+	return skb->pkt_type == PACKET_OUTGOING;
+}
+
 /*
  * called from sock_recv_timestamp() if sock_flag(sk, SOCK_RCVTSTAMP)
  */
@@ -695,7 +705,8 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
 		put_cmsg(msg, SOL_SOCKET,
 			 SCM_TIMESTAMPING, sizeof(tss), &tss);
 
-		if (skb->len && (sk->sk_tsflags & SOF_TIMESTAMPING_OPT_STATS))
+		if (skb_is_err_queue(skb) && skb->len &&
+		    (sk->sk_tsflags & SOF_TIMESTAMPING_OPT_STATS))
 			put_cmsg(msg, SOL_SOCKET, SCM_TIMESTAMPING_OPT_STATS,
 				 skb->len, skb->data);
 	}
-- 
2.12.0.367.g23dc2f6d3c-goog
