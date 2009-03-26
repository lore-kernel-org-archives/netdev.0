From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.29 forcedeth hang W/O NAPI enabled
Date: Wed, 25 Mar 2009 17:05:15 -0700 (PDT)
Message-ID: <20090325.170515.175107737.davem@davemloft.net>
References: <774003.62326.qm@web57708.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, berkley@cs.wustl.edu
To: adam_richter2004@yahoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45582
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752699AbZCZAF1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 20:05:27 -0400
In-Reply-To: <774003.62326.qm@web57708.mail.re3.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Adam Richter <adam_richter2004@yahoo.com>
Date: Wed, 25 Mar 2009 16:24:47 -0700 (PDT)

> 	When I can find some time, I plan to try to narrow the problem
> with git bisect, but that may not be today.

We're pretty sure we know exactly what commit causes this.

Can you try playing with a patch Jarek P. just posted in
the thread where this bug is being discussed?  (Subject:
Revert "gro: Fix legacy path napi_complete crash"):

diff --git a/net/core/dev.c b/net/core/dev.c
index e3fe5c7..cf53c24 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2589,7 +2589,11 @@ static int process_backlog(struct napi_struct *napi, int quota)
 		skb = __skb_dequeue(&queue->input_pkt_queue);
 		if (!skb) {
 			local_irq_enable();
-			napi_complete(napi);
+			napi_gro_flush(napi);
+			local_irq_disable();
+			if (skb_queue_empty(&queue->input_pkt_queue))
+				__napi_complete(napi);
+			local_irq_enable();
 			goto out;
 		}
 		local_irq_enable();

