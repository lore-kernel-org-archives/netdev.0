From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 31/33] netfilter: nfnetlink_log: use proper net to allocate skb
Date: Fri,  4 Oct 2013 10:33:16 +0200
Message-ID: <1380875598-5250-32-git-send-email-pablo@netfilter.org>
References: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55947 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754480Ab3JDIez (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Oct 2013 04:34:55 -0400
In-Reply-To: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>

Use proper net struct to allocate skb, otherwise
netlink mmap will be of no effect.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_log.c |   11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index d92cc31..3c4b69e 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -319,7 +319,8 @@ nfulnl_set_flags(struct nfulnl_instance *inst, u_int16_t flags)
 }
 
 static struct sk_buff *
-nfulnl_alloc_skb(u32 peer_portid, unsigned int inst_size, unsigned int pkt_size)
+nfulnl_alloc_skb(struct net *net, u32 peer_portid, unsigned int inst_size,
+		 unsigned int pkt_size)
 {
 	struct sk_buff *skb;
 	unsigned int n;
@@ -328,13 +329,13 @@ nfulnl_alloc_skb(u32 peer_portid, unsigned int inst_size, unsigned int pkt_size)
 	 * message.  WARNING: has to be <= 128k due to slab restrictions */
 
 	n = max(inst_size, pkt_size);
-	skb = nfnetlink_alloc_skb(&init_net, n, peer_portid, GFP_ATOMIC);
+	skb = nfnetlink_alloc_skb(net, n, peer_portid, GFP_ATOMIC);
 	if (!skb) {
 		if (n > pkt_size) {
 			/* try to allocate only as much as we need for current
 			 * packet */
 
-			skb = nfnetlink_alloc_skb(&init_net, pkt_size,
+			skb = nfnetlink_alloc_skb(net, pkt_size,
 						  peer_portid, GFP_ATOMIC);
 			if (!skb)
 				pr_err("nfnetlink_log: can't even alloc %u bytes\n",
@@ -702,8 +703,8 @@ nfulnl_log_packet(struct net *net,
 	}
 
 	if (!inst->skb) {
-		inst->skb = nfulnl_alloc_skb(inst->peer_portid, inst->nlbufsiz,
-					     size);
+		inst->skb = nfulnl_alloc_skb(net, inst->peer_portid,
+					     inst->nlbufsiz, size);
 		if (!inst->skb)
 			goto alloc_failure;
 	}
-- 
1.7.10.4
