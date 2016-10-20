From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: relax listening_hash operations
Date: Wed, 19 Oct 2016 21:24:58 -0700
Message-ID: <1476937498.5650.102.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35977 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751441AbcJTEZC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 00:25:02 -0400
Received: by mail-it0-f68.google.com with SMTP id 66so4050391itl.3
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2016 21:25:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

softirq handlers use RCU protection to lookup listeners,
and write operations all happen from process context.
We do not need to block BH for dump operations.

Also SYN_RECV since request sockets are stored in the ehash table :

 1) inet_diag_dump_icsk() no longer need to clear
    cb->args[3] and cb->args[4] that were used as cursors while
    iterating the old per listener hash table.

 2) Also factorize a test : No need to scan listening_hash[]
    if r->id.idiag_dport is not zero.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/inet_diag.c |   16 ++++------------
 net/ipv4/tcp_ipv4.c  |    6 +++---
 2 files changed, 7 insertions(+), 15 deletions(-)

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index e4d16fc5bbb3fec077f8e3bb3ff8811a66046edc..0a1d4a896a261dcb67e69a2d8c9aff83332fadd7 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -863,7 +863,7 @@ void inet_diag_dump_icsk(struct inet_hashinfo *hashinfo, struct sk_buff *skb,
 	s_num = num = cb->args[2];
 
 	if (cb->args[0] == 0) {
-		if (!(idiag_states & TCPF_LISTEN))
+		if (!(idiag_states & TCPF_LISTEN) || r->id.idiag_dport)
 			goto skip_listen_ht;
 
 		for (i = s_i; i < INET_LHTABLE_SIZE; i++) {
@@ -872,7 +872,7 @@ void inet_diag_dump_icsk(struct inet_hashinfo *hashinfo, struct sk_buff *skb,
 
 			num = 0;
 			ilb = &hashinfo->listening_hash[i];
-			spin_lock_bh(&ilb->lock);
+			spin_lock(&ilb->lock);
 			sk_for_each(sk, &ilb->head) {
 				struct inet_sock *inet = inet_sk(sk);
 
@@ -892,26 +892,18 @@ void inet_diag_dump_icsk(struct inet_hashinfo *hashinfo, struct sk_buff *skb,
 				    r->id.idiag_sport)
 					goto next_listen;
 
-				if (r->id.idiag_dport ||
-				    cb->args[3] > 0)
-					goto next_listen;
-
 				if (inet_csk_diag_dump(sk, skb, cb, r,
 						       bc, net_admin) < 0) {
-					spin_unlock_bh(&ilb->lock);
+					spin_unlock(&ilb->lock);
 					goto done;
 				}
 
 next_listen:
-				cb->args[3] = 0;
-				cb->args[4] = 0;
 				++num;
 			}
-			spin_unlock_bh(&ilb->lock);
+			spin_unlock(&ilb->lock);
 
 			s_num = 0;
-			cb->args[3] = 0;
-			cb->args[4] = 0;
 		}
 skip_listen_ht:
 		cb->args[0] = 1;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index bd5e8d10893fb6abffa6b0aa65de239b0000fe5b..83b3d0b8c4812d734728360a694a596a17257d02 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1893,7 +1893,7 @@ static void *listening_get_next(struct seq_file *seq, void *cur)
 	if (!sk) {
 get_head:
 		ilb = &tcp_hashinfo.listening_hash[st->bucket];
-		spin_lock_bh(&ilb->lock);
+		spin_lock(&ilb->lock);
 		sk = sk_head(&ilb->head);
 		st->offset = 0;
 		goto get_sk;
@@ -1911,7 +1911,7 @@ static void *listening_get_next(struct seq_file *seq, void *cur)
 			return sk;
 		icsk = inet_csk(sk);
 	}
-	spin_unlock_bh(&ilb->lock);
+	spin_unlock(&ilb->lock);
 	st->offset = 0;
 	if (++st->bucket < INET_LHTABLE_SIZE)
 		goto get_head;
@@ -2119,7 +2119,7 @@ static void tcp_seq_stop(struct seq_file *seq, void *v)
 	switch (st->state) {
 	case TCP_SEQ_STATE_LISTENING:
 		if (v != SEQ_START_TOKEN)
-			spin_unlock_bh(&tcp_hashinfo.listening_hash[st->bucket].lock);
+			spin_unlock(&tcp_hashinfo.listening_hash[st->bucket].lock);
 		break;
 	case TCP_SEQ_STATE_ESTABLISHED:
 		if (v)
