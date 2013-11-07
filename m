From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: flow_dissector: small optimizations in IPv4
 dissect
Date: Thu, 07 Nov 2013 08:37:28 -0800
Message-ID: <1383842248.9412.84.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f49.google.com ([209.85.216.49]:46840 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751924Ab3KGQhi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 11:37:38 -0500
Received: by mail-qa0-f49.google.com with SMTP id cm18so629635qab.8
        for <netdev@vger.kernel.org>; Thu, 07 Nov 2013 08:37:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

By moving code around, we avoid :

1) A reload of iph->ihl (bit field, so needs a mask)

2) A conditional test (replaced by a conditional mov on x86)
   Fast path loads iph->protocol anyway.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/flow_dissector.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 0242035192f1..d6ef17322500 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -68,13 +68,13 @@ ip:
 		iph = skb_header_pointer(skb, nhoff, sizeof(_iph), &_iph);
 		if (!iph || iph->ihl < 5)
 			return false;
+		nhoff += iph->ihl * 4;
 
+		ip_proto = iph->protocol;
 		if (ip_is_fragment(iph))
 			ip_proto = 0;
-		else
-			ip_proto = iph->protocol;
+
 		iph_to_flow_copy_addrs(flow, iph);
-		nhoff += iph->ihl * 4;
 		break;
 	}
 	case __constant_htons(ETH_P_IPV6): {
