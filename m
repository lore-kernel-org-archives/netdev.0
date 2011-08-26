From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] netpoll: fix incorrect access to skb data in __netpoll_rx
Date: Fri, 26 Aug 2011 18:26:15 +0200
Message-ID: <1314375975.2563.8.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:35895 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754755Ab1HZQ0Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2011 12:26:16 -0400
Received: by wyg24 with SMTP id 24so2594277wyg.19
        for <netdev@vger.kernel.org>; Fri, 26 Aug 2011 09:26:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__netpoll_rx() doesnt properly handle skbs with small header

pskb_may_pull() or pskb_trim_rcsum() can change skb->data, we must
reload it.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/netpoll.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index adf84dd..5262251 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -558,13 +558,14 @@ int __netpoll_rx(struct sk_buff *skb)
 	if (skb_shared(skb))
 		goto out;
 
-	iph = (struct iphdr *)skb->data;
 	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
 		goto out;
+	iph = (struct iphdr *)skb->data;
 	if (iph->ihl < 5 || iph->version != 4)
 		goto out;
 	if (!pskb_may_pull(skb, iph->ihl*4))
 		goto out;
+	iph = (struct iphdr *)skb->data;
 	if (ip_fast_csum((u8 *)iph, iph->ihl) != 0)
 		goto out;
 
@@ -579,6 +580,7 @@ int __netpoll_rx(struct sk_buff *skb)
 	if (pskb_trim_rcsum(skb, len))
 		goto out;
 
+	iph = (struct iphdr *)skb->data;
 	if (iph->protocol != IPPROTO_UDP)
 		goto out;
 
