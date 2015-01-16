From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net] net: rps: fix cpu unplug
Date: Thu, 15 Jan 2015 17:04:22 -0800
Message-ID: <1421370262.11734.111.camel@edumazet-glaptop2.roam.corp.google.com>
References: <75547b88b7e2d15b35339a6321c3a929.squirrel@www.codeaurora.org>
	 <1421305282.11734.38.camel@edumazet-glaptop2.roam.corp.google.com>
	 <4504851fe2f44615e67cde94286a2fdd.squirrel@www.codeaurora.org>
	 <1421350095.11734.88.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1421358383.11734.97.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Prasad Sodagudi <psodagud@codeaurora.org>, netdev@vger.kernel.org,
	Tom Herbert <therbert@google.com>
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:39107 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753277AbbAPBEX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 20:04:23 -0500
Received: by mail-ie0-f172.google.com with SMTP id tr6so18225147ieb.3
        for <netdev@vger.kernel.org>; Thu, 15 Jan 2015 17:04:23 -0800 (PST)
In-Reply-To: <1421358383.11734.97.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

softnet_data.input_pkt_queue is protected by a spinlock that
we must hold when transferring packets from victim queue to an active
one. This is because other cpus could still be trying to enqueue packets
into victim queue.

A second problem is that when we transfert the NAPI poll_list from
victim to current cpu, we absolutely need to special case the percpu
backlog, because we do not want to add complex locking to protect
process_queue : Only owner cpu is allowed to manipulate it, unless cpu
is offline.

Based on initial patch from Prasad Sodagudi & Subash Abhinov
Kasiviswanathan.

This version is better because we do not slow down packet processing,
only make migration safer.

Reported-by: Prasad Sodagudi <psodagud@codeaurora.org>
Reported-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Tom Herbert <therbert@google.com>
---
 net/core/dev.c |   20 +++++++++++++++-----
 1 file changed, 15 insertions(+), 5 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 1e325adc4367..7f028d441e98 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -7075,10 +7075,20 @@ static int dev_cpu_callback(struct notifier_block *nfb,
 		oldsd->output_queue = NULL;
 		oldsd->output_queue_tailp = &oldsd->output_queue;
 	}
-	/* Append NAPI poll list from offline CPU. */
-	if (!list_empty(&oldsd->poll_list)) {
-		list_splice_init(&oldsd->poll_list, &sd->poll_list);
-		raise_softirq_irqoff(NET_RX_SOFTIRQ);
+	/* Append NAPI poll list from offline CPU, with one exception :
+	 * process_backlog() must be called by cpu owning percpu backlog.
+	 * We properly handle process_queue & input_pkt_queue later.
+	 */
+	while (!list_empty(&oldsd->poll_list)) {
+		struct napi_struct *napi = list_first_entry(&oldsd->poll_list,
+							    struct napi_struct,
+							    poll_list);
+
+		list_del_init(&napi->poll_list);
+		if (napi->poll == process_backlog)
+			napi->state = 0;
+		else
+			____napi_schedule(sd, napi);
 	}
 
 	raise_softirq_irqoff(NET_TX_SOFTIRQ);
@@ -7089,7 +7099,7 @@ static int dev_cpu_callback(struct notifier_block *nfb,
 		netif_rx_internal(skb);
 		input_queue_head_incr(oldsd);
 	}
-	while ((skb = __skb_dequeue(&oldsd->input_pkt_queue))) {
+	while ((skb = skb_dequeue(&oldsd->input_pkt_queue))) {
 		netif_rx_internal(skb);
 		input_queue_head_incr(oldsd);
 	}
