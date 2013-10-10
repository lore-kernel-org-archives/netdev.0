From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: tcp_transmit_skb() optimizations
Date: Thu, 10 Oct 2013 08:43:00 -0700
Message-ID: <1381419780.4971.84.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, MF Nowlan <fitz@cs.yale.edu>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:60103 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755779Ab3JJPnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Oct 2013 11:43:03 -0400
Received: by mail-pb0-f48.google.com with SMTP id ma3so2746573pbc.21
        for <netdev@vger.kernel.org>; Thu, 10 Oct 2013 08:43:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

1) We need to take a timestamp only for skb that should be cloned.

Other skbs are not in write queue and no rtt estimation is done on them.

2) the unlikely() hint is wrong for receivers (they send pure ACK)

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: MF Nowlan <fitz@cs.yale.edu>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp_output.c |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index faec813..c40f608 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -850,15 +850,15 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 
 	BUG_ON(!skb || !tcp_skb_pcount(skb));
 
-	/* If congestion control is doing timestamping, we must
-	 * take such a timestamp before we potentially clone/copy.
-	 */
-	if (icsk->icsk_ca_ops->flags & TCP_CONG_RTT_STAMP)
-		__net_timestamp(skb);
-
-	if (likely(clone_it)) {
+	if (clone_it) {
 		const struct sk_buff *fclone = skb + 1;
 
+		/* If congestion control is doing timestamping, we must
+		 * take such a timestamp before we potentially clone/copy.
+		 */
+		if (icsk->icsk_ca_ops->flags & TCP_CONG_RTT_STAMP)
+			__net_timestamp(skb);
+
 		if (unlikely(skb->fclone == SKB_FCLONE_ORIG &&
 			     fclone->fclone == SKB_FCLONE_CLONE))
 			NET_INC_STATS_BH(sock_net(sk),
