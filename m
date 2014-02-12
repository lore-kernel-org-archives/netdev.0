From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: [PATCH net-next] ipv4: ip_forward: perform skb->pkt_type check at the beginning
Date: Wed, 12 Feb 2014 12:10:32 +0400
Message-ID: <1392192632-24513-1-git-send-email-kda@linux-powerpc.org>
Cc: Denis Kirjanov <kda@linux-powerpc.org>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:49699 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750711AbaBLILD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 03:11:03 -0500
Received: by mail-lb0-f182.google.com with SMTP id w7so6705860lbi.41
        for <netdev@vger.kernel.org>; Wed, 12 Feb 2014 00:11:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Packets which have L2 address different from ours should be
already filtered before entering into ip_forward().

Perform that check at the beginning to avoid processing such packets.

Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
---
 net/ipv4/ip_forward.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index e9f1217..1a07056 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -59,6 +59,10 @@ int ip_forward(struct sk_buff *skb)
 	struct rtable *rt;	/* Route we use */
 	struct ip_options *opt	= &(IPCB(skb)->opt);
 
+    /* that should never happen */
+    if (skb->pkt_type != PACKET_HOST)
+        goto drop;
+
 	if (skb_warn_if_lro(skb))
 		goto drop;
 
@@ -68,9 +72,6 @@ int ip_forward(struct sk_buff *skb)
 	if (IPCB(skb)->opt.router_alert && ip_call_ra_chain(skb))
 		return NET_RX_SUCCESS;
 
-	if (skb->pkt_type != PACKET_HOST)
-		goto drop;
-
 	skb_forward_csum(skb);
 
 	/*
-- 
1.8.3.2
