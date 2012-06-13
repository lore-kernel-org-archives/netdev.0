From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] netpoll: fix netpoll_send_udp() bugs
Date: Wed, 13 Jun 2012 07:30:21 +0200
Message-ID: <1339565421.22704.310.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Bogdan Hamciuc <bogdan.hamciuc@freescale.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Neil Horman <nhorman@tuxdriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:42247 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752036Ab2FMFaY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2012 01:30:24 -0400
Received: by eaak11 with SMTP id k11so38217eaa.19
        for <netdev@vger.kernel.org>; Tue, 12 Jun 2012 22:30:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Bogdan Hamciuc diagnosed and fixed following bug in netpoll_send_udp() :

"skb->len += len;" instead of "skb_put(skb, len);"

Meaning that _if_ a network driver needs to call skb_realloc_headroom(),
only packet headers would be copied, leaving garbage in the payload.

However the skb_realloc_headroom() must be avoided as much as possible
since it requires memory and netpoll tries hard to work even if memory
is exhausted (using a pool of preallocated skbs)

It appears netpoll_send_udp() reserved 16 bytes for the ethernet header,
which happens to work for typicall drivers but not all.

Right thing is to use LL_RESERVED_SPACE(dev)
(And also add dev->needed_tailroom of tailroom)

This patch combines both fixes.

Many thanks to Bogdan for raising this issue.

Reported-by: Bogdan Hamciuc <bogdan.hamciuc@freescale.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Tested-by: Bogdan Hamciuc <bogdan.hamciuc@freescale.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Neil Horman <nhorman@tuxdriver.com>
---
 net/core/netpoll.c |   11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 3d84fb9..f9f40b9 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -362,22 +362,23 @@ EXPORT_SYMBOL(netpoll_send_skb_on_dev);
 
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
+	total_len = ip_len + LL_RESERVED_SPACE(np->dev);
 
-	skb = find_skb(np, total_len, total_len - len);
+	skb = find_skb(np, total_len + np->dev->needed_tailroom,
+		       total_len - len);
 	if (!skb)
 		return;
 
 	skb_copy_to_linear_data(skb, msg, len);
-	skb->len += len;
+	skb_put(skb, len);
 
 	skb_push(skb, sizeof(*udph));
 	skb_reset_transport_header(skb);
