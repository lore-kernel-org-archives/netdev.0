From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/5] netfilter: nfnetlink_queue: fix missing HW protocol
Date: Mon, 10 Jun 2013 18:07:40 +0200
Message-ID: <1370880461-4265-5-git-send-email-pablo@netfilter.org>
References: <1370880461-4265-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59101 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754021Ab3FJQHx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jun 2013 12:07:53 -0400
In-Reply-To: <1370880461-4265-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Locally generated IPv4 and IPv6 traffic gets skb->protocol unset,
thus passing zero.

ip6tables -I OUTPUT -j NFQUEUE
libmnl/examples/netfilter# ./nf-queue 0 &
ping6 ::1
packet received (id=1 hw=0x0000 hook=3)
                         ^^^^^^

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_queue_core.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index 4e27fa0..5352b2d 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -637,9 +637,6 @@ nfqnl_enqueue_packet(struct nf_queue_entry *entry, unsigned int queuenum)
 	if (queue->copy_mode == NFQNL_COPY_NONE)
 		return -EINVAL;
 
-	if ((queue->flags & NFQA_CFG_F_GSO) || !skb_is_gso(entry->skb))
-		return __nfqnl_enqueue_packet(net, queue, entry);
-
 	skb = entry->skb;
 
 	switch (entry->pf) {
@@ -651,6 +648,9 @@ nfqnl_enqueue_packet(struct nf_queue_entry *entry, unsigned int queuenum)
 		break;
 	}
 
+	if ((queue->flags & NFQA_CFG_F_GSO) || !skb_is_gso(skb))
+		return __nfqnl_enqueue_packet(net, queue, entry);
+
 	nf_bridge_adjust_skb_data(skb);
 	segs = skb_gso_segment(skb, 0);
 	/* Does not use PTR_ERR to limit the number of error codes that can be
-- 
1.7.10.4
