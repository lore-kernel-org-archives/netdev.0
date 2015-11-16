From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net] macvlan: fix leak in macvlan_handle_frame
Date: Mon, 16 Nov 2015 22:54:20 +0100
Message-ID: <d4141a7c4841ae5f631858a8537968419f0e396b.1447705984.git.sd@queasysnail.net>
Cc: jiri@resnulli.us, kaber@trash.net,
	Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46171 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752013AbbKPVyc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Nov 2015 16:54:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reset pskb in macvlan_handle_frame in case skb_share_check returned a
clone.

Fixes: 8a4eb5734e8d ("net: introduce rx_handler results and logic around that")
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 drivers/net/macvlan.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 86f6c6292c27..06c8bfeaccd6 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -415,6 +415,7 @@ static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
 		skb = ip_check_defrag(dev_net(skb->dev), skb, IP_DEFRAG_MACVLAN);
 		if (!skb)
 			return RX_HANDLER_CONSUMED;
+		*pskb = skb;
 		eth = eth_hdr(skb);
 		macvlan_forward_source(skb, port, eth->h_source);
 		src = macvlan_hash_lookup(port, eth->h_source);
@@ -456,6 +457,7 @@ static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
 		goto out;
 	}
 
+	*pskb = skb;
 	skb->dev = dev;
 	skb->pkt_type = PACKET_HOST;
 
-- 
2.6.2
