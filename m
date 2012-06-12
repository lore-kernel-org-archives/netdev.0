From: Bogdan Hamciuc <bogdan.hamciuc@freescale.com>
Subject: [PATCH] netpoll: Fix skb tail pointer in netpoll_send_udp()
Date: Tue, 12 Jun 2012 13:26:04 +0300
Message-ID: <1339496765-3093-1-git-send-email-bogdan.hamciuc@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Bogdan Hamciuc <bogdan.hamciuc@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe002.messaging.microsoft.com ([65.55.88.12]:17810 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751378Ab2FLK1R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 06:27:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As skb->tail wasn't updated after skb_copy_to_linear_data(), subsequent
calls to skb_realloc_headroom() (as made by an ethernet driver's
ndo_start_xmit routine) would only effectively copy the packet headers,
leaving garbage in the payload.

In the process, removed some unnecessary code.

Signed-off-by: Bogdan Hamciuc <bogdan.hamciuc@freescale.com>
---
 net/core/netpoll.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 3d84fb9..9a08068 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -362,22 +362,22 @@ EXPORT_SYMBOL(netpoll_send_skb_on_dev);
 
 void netpoll_send_udp(struct netpoll *np, const char *msg, int len)
 {
-	int total_len, eth_len, ip_len, udp_len;
+	int total_len, ip_len, udp_len;
 	struct sk_buff *skb;
 	struct udphdr *udph;
 	struct iphdr *iph;
 	struct ethhdr *eth;
 
 	udp_len = len + sizeof(*udph);
-	ip_len = eth_len = udp_len + sizeof(*iph);
-	total_len = eth_len + ETH_HLEN + NET_IP_ALIGN;
+	ip_len = udp_len + sizeof(*iph);
+	total_len = ip_len + ETH_HLEN + NET_IP_ALIGN;
 
 	skb = find_skb(np, total_len, total_len - len);
 	if (!skb)
 		return;
 
 	skb_copy_to_linear_data(skb, msg, len);
-	skb->len += len;
+	skb_put(skb, len);
 
 	skb_push(skb, sizeof(*udph));
 	skb_reset_transport_header(skb);
-- 
1.5.6.3
