From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: fix tcp_xmit_retransmit_queue() after rbtree
 introduction
Date: Mon, 16 Oct 2017 19:38:35 -0700
Message-ID: <1508207915.31614.87.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:47714 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932328AbdJQCih (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 22:38:37 -0400
Received: by mail-pf0-f193.google.com with SMTP id z11so258589pfk.4
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 19:38:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

I tried to hard avoiding a call to rb_first() (via tcp_rtx_queue_head)
in tcp_xmit_retransmit_queue(). But this was probably too bold.

Quoting Yuchung :

We might miss re-arming the RTO if tp->retransmit_skb_hint is not NULL.
This can happen when RACK marks the first packet lost again and resets
tp->retransmit_skb_hint for example (tcp_rack_mark_skb_lost())

Fixes: 75c119afe14f ("tcp: implement rb-tree based retransmit queue")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_output.c |    9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 6c74f2a3977876e691e7355045d4a84a98af1e30..53dc1267c85e668d9a6d5d60d24e6101f7a9c56b 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2921,7 +2921,7 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb, int segs)
 void tcp_xmit_retransmit_queue(struct sock *sk)
 {
 	const struct inet_connection_sock *icsk = inet_csk(sk);
-	struct sk_buff *skb, *rtx_head = NULL, *hole = NULL;
+	struct sk_buff *skb, *rtx_head, *hole = NULL;
 	struct tcp_sock *tp = tcp_sk(sk);
 	u32 max_segs;
 	int mib_idx;
@@ -2929,11 +2929,8 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 	if (!tp->packets_out)
 		return;
 
-	skb = tp->retransmit_skb_hint;
-	if (!skb) {
-		rtx_head = tcp_rtx_queue_head(sk);
-		skb = rtx_head;
-	}
+	rtx_head = tcp_rtx_queue_head(sk);
+	skb = tp->retransmit_skb_hint ?: rtx_head;
 	max_segs = tcp_tso_segs(sk, tcp_current_mss(sk));
 	skb_rbtree_walk_from(skb) {
 		__u8 sacked;
