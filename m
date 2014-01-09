From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: gro: change GRO overflow strategy
Date: Thu, 09 Jan 2014 14:12:19 -0800
Message-ID: <1389305539.31367.65.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Jerry Chu <hkchu@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f170.google.com ([209.85.161.170]:35188 "EHLO
	mail-gg0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753005AbaAIWMW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 17:12:22 -0500
Received: by mail-gg0-f170.google.com with SMTP id i1so943299ggn.29
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 14:12:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

GRO layer has a limit of 8 flows being held in GRO list,
for performance reason.

When a packet comes for a flow not yet in the list,
and list is full, we immediately give it to upper
stacks, lowering aggregation performance.

With TSO auto sizing and FQ packet scheduler, this situation
happens more often.

This patch changes strategy to simply evict the oldest flow of
the list. This works better because of the nature of packet
trains for which GRO is efficient. This also has the effect
of lowering the GRO latency if many flows are competing.

Tested :

Used a 40Gbps NIC, with 4 RX queues, and 200 concurrent TCP_STREAM
netperf.

Before patch, aggregate rate is 11Gbps (while a single flow can reach
30Gbps)

After patch, line rate is reached.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Jerry Chu <hkchu@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
---
 net/core/dev.c |   17 +++++++++++++++--
 1 file changed, 15 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index ce01847793c0..a8280154c42a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3882,10 +3882,23 @@ static enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff
 	if (same_flow)
 		goto ok;
 
-	if (NAPI_GRO_CB(skb)->flush || napi->gro_count >= MAX_GRO_SKBS)
+	if (NAPI_GRO_CB(skb)->flush)
 		goto normal;
 
-	napi->gro_count++;
+	if (unlikely(napi->gro_count >= MAX_GRO_SKBS)) {
+		struct sk_buff *nskb = napi->gro_list;
+
+		/* locate the end of the list to select the 'oldest' flow */
+		while (nskb->next) {
+			pp = &nskb->next;
+			nskb = *pp;
+		}
+		*pp = NULL;
+		nskb->next = NULL;
+		napi_gro_complete(nskb);
+	} else {
+		napi->gro_count++;
+	}
 	NAPI_GRO_CB(skb)->count = 1;
 	NAPI_GRO_CB(skb)->age = jiffies;
 	skb_shinfo(skb)->gso_size = skb_gro_len(skb);
