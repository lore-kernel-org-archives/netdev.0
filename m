From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net: rps: fix cpu unplug
Date: Thu, 15 Jan 2015 13:46:23 -0800
Message-ID: <1421358383.11734.97.camel@edumazet-glaptop2.roam.corp.google.com>
References: <75547b88b7e2d15b35339a6321c3a929.squirrel@www.codeaurora.org>
	 <1421305282.11734.38.camel@edumazet-glaptop2.roam.corp.google.com>
	 <4504851fe2f44615e67cde94286a2fdd.squirrel@www.codeaurora.org>
	 <1421350095.11734.88.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Tom Herbert <therbert@google.com>
To: subashab@codeaurora.org, Prasad Sodagudi <psodagud@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:52443 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753573AbbAOVqZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 16:46:25 -0500
Received: by mail-ie0-f182.google.com with SMTP id x19so17437461ier.13
        for <netdev@vger.kernel.org>; Thu, 15 Jan 2015 13:46:25 -0800 (PST)
In-Reply-To: <1421350095.11734.88.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

softnet_data.input_pkt_queue is protected by a spinlock that
we must hold when transferring packets from victim queue to an active
one. This is because other cpus could still be trying to enqueue packets
into victim queue.

Based on initial patch from Prasad Sodagudi & Subash Abhinov
Kasiviswanathan.

This version is better because we do not slow down packet processing,
only make migration safer.

Reported-by: Prasad Sodagudi <psodagud@codeaurora.org>
Reported-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Tom Herbert <therbert@google.com>
---

Could you test this fix instead of yours ? Thanks !

 net/core/dev.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 1e325adc43678084418ef9e1abb1fca8059ff599..76f72762b325cfa927a793af180189c51e9eaffd 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -7089,7 +7089,7 @@ static int dev_cpu_callback(struct notifier_block *nfb,
 		netif_rx_internal(skb);
 		input_queue_head_incr(oldsd);
 	}
-	while ((skb = __skb_dequeue(&oldsd->input_pkt_queue))) {
+	while ((skb = skb_dequeue(&oldsd->input_pkt_queue))) {
 		netif_rx_internal(skb);
 		input_queue_head_incr(oldsd);
 	}
