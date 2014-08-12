From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net 1/2] net-timestamp: fix missing ACK timestamp
Date: Tue, 12 Aug 2014 14:53:16 -0400
Message-ID: <1407869597-9583-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	richardcochran@gmail.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f73.google.com ([209.85.219.73]:45367 "EHLO
	mail-oa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754036AbaHLSx2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2014 14:53:28 -0400
Received: by mail-oa0-f73.google.com with SMTP id g18so1906225oah.2
        for <netdev@vger.kernel.org>; Tue, 12 Aug 2014 11:53:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ACK timestamps are generated in tcp_clean_rtx_queue. The TSO datapath
can break out early, causing the timestamp code to be skipped. Move
the code up before the break.

Reported-by: David S. Miller <davem@davemloft.net>

Also fix a boundary condition: tp->snd_una is the next unacknowledged
byte and between tests inclusive (a <= b <= c), so generate a an ACK
timestamp if (prior_snd_una <= tskey <= tp->snd_una - 1).

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/ipv4/tcp_input.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a3d47af..1a8e89f 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3050,10 +3050,15 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 	first_ackt.v64 = 0;
 
 	while ((skb = tcp_write_queue_head(sk)) && skb != tcp_send_head(sk)) {
+		struct skb_shared_info *shinfo = skb_shinfo(skb);
 		struct tcp_skb_cb *scb = TCP_SKB_CB(skb);
 		u8 sacked = scb->sacked;
 		u32 acked_pcount;
 
+		if (unlikely(shinfo->tx_flags & SKBTX_ACK_TSTAMP) &&
+		    between(shinfo->tskey, prior_snd_una, tp->snd_una - 1))
+			__skb_tstamp_tx(skb, NULL, sk, SCM_TSTAMP_ACK);
+
 		/* Determine how many packets and what bytes were acked, tso and else */
 		if (after(scb->end_seq, tp->snd_una)) {
 			if (tcp_skb_pcount(skb) == 1 ||
@@ -3107,11 +3112,6 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 			tp->retrans_stamp = 0;
 		}
 
-		if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_ACK_TSTAMP) &&
-		    between(skb_shinfo(skb)->tskey, prior_snd_una,
-			    tp->snd_una + 1))
-			__skb_tstamp_tx(skb, NULL, sk, SCM_TSTAMP_ACK);
-
 		if (!fully_acked)
 			break;
 
-- 
2.1.0.rc2.206.gedb03e5
