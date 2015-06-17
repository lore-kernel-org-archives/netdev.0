From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net v2] packet: avoid out of bounds read in round robin fanout
Date: Wed, 17 Jun 2015 15:59:34 -0400
Message-ID: <1434571174-8356-1-git-send-email-willemb@google.com>
References: <55816378.1020602@cogentembedded.com>
Cc: davem@davemloft.net, edumazet@google.com,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f47.google.com ([209.85.213.47]:33703 "EHLO
	mail-yh0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752552AbbFQT7p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 15:59:45 -0400
Received: by yhpn97 with SMTP id n97so41746948yhp.0
        for <netdev@vger.kernel.org>; Wed, 17 Jun 2015 12:59:45 -0700 (PDT)
In-Reply-To: <55816378.1020602@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

PACKET_FANOUT_LB computes f->rr_cur such that it is modulo
f->num_members. It returns the old value unconditionally, but
f->num_members may have changed since the last store. Ensure
that the return value is always < num.

When modifying the logic, simplify it further by replacing the loop
with an unconditional atomic increment.

Fixes: dc99f600698d ("packet: Add fanout support.")
Suggested-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/packet/af_packet.c | 18 ++----------------
 1 file changed, 2 insertions(+), 16 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index b5989c6..104f902 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1272,16 +1272,6 @@ static void packet_sock_destruct(struct sock *sk)
 	sk_refcnt_debug_dec(sk);
 }
 
-static int fanout_rr_next(struct packet_fanout *f, unsigned int num)
-{
-	int x = atomic_read(&f->rr_cur) + 1;
-
-	if (x >= num)
-		x = 0;
-
-	return x;
-}
-
 static unsigned int fanout_demux_hash(struct packet_fanout *f,
 				      struct sk_buff *skb,
 				      unsigned int num)
@@ -1293,13 +1283,9 @@ static unsigned int fanout_demux_lb(struct packet_fanout *f,
 				    struct sk_buff *skb,
 				    unsigned int num)
 {
-	int cur, old;
+	unsigned int val = atomic_inc_return(&f->rr_cur);
 
-	cur = atomic_read(&f->rr_cur);
-	while ((old = atomic_cmpxchg(&f->rr_cur, cur,
-				     fanout_rr_next(f, num))) != cur)
-		cur = old;
-	return cur;
+	return val % num;
 }
 
 static unsigned int fanout_demux_cpu(struct packet_fanout *f,
-- 
2.4.3.573.g4eafbef
