From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/2] tcp: do not enqueue skb with SYN flag
Date: Mon,  1 Feb 2016 21:03:08 -0800
Message-ID: <1454389388-1506-3-git-send-email-edumazet@google.com>
References: <1454389388-1506-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Sara Dickinson <sara@sinodun.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:36829 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750710AbcBBFDi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 00:03:38 -0500
Received: by mail-pa0-f41.google.com with SMTP id yy13so94327901pab.3
        for <netdev@vger.kernel.org>; Mon, 01 Feb 2016 21:03:37 -0800 (PST)
In-Reply-To: <1454389388-1506-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we remove the SYN flag from the skbs that tcp_fastopen_add_skb()
places in socket receive queue, then we can remove the test that
tcp_recvmsg() has to perform in fast path.

All we have to do is to adjust SEQ in the slow path.

For the moment, we place an unlikely() and output a message
if we find an skb having SYN flag set.
Goal would be to get rid of the test completely.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp.c          | 8 ++++++--
 net/ipv4/tcp_fastopen.c | 3 +++
 2 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 19746b3fcbbe..c5075779e017 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1466,8 +1466,10 @@ static struct sk_buff *tcp_recv_skb(struct sock *sk, u32 seq, u32 *off)
 
 	while ((skb = skb_peek(&sk->sk_receive_queue)) != NULL) {
 		offset = seq - TCP_SKB_CB(skb)->seq;
-		if (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_SYN)
+		if (unlikely(TCP_SKB_CB(skb)->tcp_flags & TCPHDR_SYN)) {
+			pr_err_once("%s: found a SYN, please report !\n", __func__);
 			offset--;
+		}
 		if (offset < skb->len || (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN)) {
 			*off = offset;
 			return skb;
@@ -1657,8 +1659,10 @@ int tcp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int nonblock,
 				break;
 
 			offset = *seq - TCP_SKB_CB(skb)->seq;
-			if (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_SYN)
+			if (unlikely(TCP_SKB_CB(skb)->tcp_flags & TCPHDR_SYN)) {
+				pr_err_once("%s: found a SYN, please report !\n", __func__);
 				offset--;
+			}
 			if (offset < skb->len)
 				goto found_ok_skb;
 			if (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN)
diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index 467d3e985411..6a6e11e54bae 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -143,6 +143,9 @@ void tcp_fastopen_add_skb(struct sock *sk, struct sk_buff *skb)
 	__skb_pull(skb, tcp_hdrlen(skb));
 	skb_set_owner_r(skb, sk);
 
+	TCP_SKB_CB(skb)->seq++;
+	TCP_SKB_CB(skb)->tcp_flags &= ~TCPHDR_SYN;
+
 	tp->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
 	__skb_queue_tail(&sk->sk_receive_queue, skb);
 	tp->syn_data_acked = 1;
-- 
2.7.0.rc3.207.g0ac5344
