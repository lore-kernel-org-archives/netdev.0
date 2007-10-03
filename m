From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH] net: fix race in process_backlog
Date: Wed, 03 Oct 2007 17:44:53 +0200
Message-ID: <1191426293.5599.27.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Jeff Dike <jdike@addtoit.com>,
	David Miller <davem@davemloft.net>
To: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758439AbXJCPuw@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Subject: net: fix race in process_backlog

The recent NAPI rework (4fa57c9ea9f36f9ca852f3a88ca5d2f1aebbc960)
introduced a race between netif_rx() and process_backlog() which
resulted in softirq processing to drop dead.

netif_rx()		process_backlog()

			irq_disable();
			skb = __skb_dequeue();
			irq_enable();

irq_disable();
__skb_queue_tail();
napi_schedule();
irq_enable();

			if (!skb)
			  napi_complete();  <-- oops!

we cleared the napi bit, even though there is data to process.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 net/core/dev.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6/net/core/dev.c
===================================================================
--- linux-2.6.orig/net/core/dev.c
+++ linux-2.6/net/core/dev.c
@@ -2095,11 +2095,11 @@ static int process_backlog(struct napi_s
 
 		local_irq_disable();
 		skb = __skb_dequeue(&queue->input_pkt_queue);
-		local_irq_enable();
 		if (!skb) {
-			napi_complete(napi);
+			__napi_complete(napi);
 			break;
 		}
+		local_irq_enable();
 
 		dev = skb->dev;
 
