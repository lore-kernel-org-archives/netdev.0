From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net: use netif_rx_ni() from process context
Date: Thu, 05 Feb 2015 14:58:14 -0800
Message-ID: <1423177094.31870.93.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:50476 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751296AbbBEW6Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 17:58:16 -0500
Received: by mail-ig0-f177.google.com with SMTP id z20so2562375igj.4
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 14:58:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Hotpluging a cpu might be rare, yet we have to use proper
handlers when taking over packets found in backlog queues.

dev_cpu_callback() runs from process context, thus we should
call netif_rx_ni() to properly invoke softirq handler.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
I never saw real operational issues, but I suspect this patch cannot
hurt.

 net/core/dev.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 7fe82929f509..6c1556aeec29 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -7064,11 +7064,11 @@ static int dev_cpu_callback(struct notifier_block *nfb,
 
 	/* Process offline CPU's input_pkt_queue */
 	while ((skb = __skb_dequeue(&oldsd->process_queue))) {
-		netif_rx_internal(skb);
+		netif_rx_ni(skb);
 		input_queue_head_incr(oldsd);
 	}
 	while ((skb = skb_dequeue(&oldsd->input_pkt_queue))) {
-		netif_rx_internal(skb);
+		netif_rx_ni(skb);
 		input_queue_head_incr(oldsd);
 	}
 
