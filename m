From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: make sure skb is not shared before using skb_get()
Date: Fri, 13 Feb 2015 04:47:12 -0800
Message-ID: <1423831632.4942.25.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f45.google.com ([209.85.216.45]:61607 "EHLO
	mail-qa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752068AbbBMMrP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2015 07:47:15 -0500
Received: by mail-qa0-f45.google.com with SMTP id j7so12211631qaq.4
        for <netdev@vger.kernel.org>; Fri, 13 Feb 2015 04:47:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

IPv6 can keep a copy of SYN message using skb_get() in
tcp_v6_conn_request() so that caller wont free the skb when calling
kfree_skb() later.
    
Therefore TCP fast open has to clone the skb it is queuing in
child->sk_receive_queue, as all skbs consumed from receive_queue are
freed using __kfree_skb() (ie assuming skb->users == 1)
    
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Fixes: 5b7ed0892f2af ("tcp: move fastopen functions to tcp_fastopen.c")
---
 net/ipv4/tcp_fastopen.c |   32 ++++++++++++++++++++++++--------
 1 file changed, 24 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index 53db2c309572..ea82fd492c1b 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -134,6 +134,7 @@ static bool tcp_fastopen_create_child(struct sock *sk,
 	struct tcp_sock *tp;
 	struct request_sock_queue *queue = &inet_csk(sk)->icsk_accept_queue;
 	struct sock *child;
+	u32 end_seq;
 
 	req->num_retrans = 0;
 	req->num_timeout = 0;
@@ -185,20 +186,35 @@ static bool tcp_fastopen_create_child(struct sock *sk,
 
 	/* Queue the data carried in the SYN packet. We need to first
 	 * bump skb's refcnt because the caller will attempt to free it.
+	 * Note that IPv6 might also have used skb_get() trick
+	 * in tcp_v6_conn_request() to keep this SYN around (treq->pktopts)
+	 * So we need to eventually get a clone of the packet,
+	 * before inserting it in sk_receive_queue.
 	 *
 	 * XXX (TFO) - we honor a zero-payload TFO request for now,
 	 * (any reason not to?) but no need to queue the skb since
 	 * there is no data. How about SYN+FIN?
 	 */
-	if (TCP_SKB_CB(skb)->end_seq != TCP_SKB_CB(skb)->seq + 1) {
-		skb = skb_get(skb);
-		skb_dst_drop(skb);
-		__skb_pull(skb, tcp_hdr(skb)->doff * 4);
-		skb_set_owner_r(skb, child);
-		__skb_queue_tail(&child->sk_receive_queue, skb);
-		tp->syn_data_acked = 1;
+	end_seq = TCP_SKB_CB(skb)->end_seq;
+	if (end_seq != TCP_SKB_CB(skb)->seq + 1) {
+		struct sk_buff *skb2;
+
+		if (unlikely(skb_shared(skb)))
+			skb2 = skb_clone(skb, GFP_ATOMIC);
+		else
+			skb2 = skb_get(skb);
+
+		if (likely(skb2)) {
+			skb_dst_drop(skb2);
+			__skb_pull(skb2, tcp_hdrlen(skb));
+			skb_set_owner_r(skb2, child);
+			__skb_queue_tail(&child->sk_receive_queue, skb2);
+			tp->syn_data_acked = 1;
+		} else {
+			end_seq = TCP_SKB_CB(skb)->seq + 1;
+		}
 	}
-	tcp_rsk(req)->rcv_nxt = tp->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
+	tcp_rsk(req)->rcv_nxt = tp->rcv_nxt = end_seq;
 	sk->sk_data_ready(sk);
 	bh_unlock_sock(child);
 	sock_put(child);
