From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH net-next] net: rps: fix the support for PPPOE
Date: Wed, 21 Sep 2011 16:36:07 +0800
Message-ID: <1316594167-12313-1-git-send-email-xiaosuo@gmail.com>
Cc: netdev@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yi0-f46.google.com ([209.85.218.46]:58100 "EHLO
	mail-yi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752041Ab1IUIzY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2011 04:55:24 -0400
Received: by yib18 with SMTP id 18so896907yib.19
        for <netdev@vger.kernel.org>; Wed, 21 Sep 2011 01:55:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The upper protocol numbers of PPPOE are different, and should be treated
specially.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/core/dev.c |   12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)
diff --git a/net/core/dev.c b/net/core/dev.c
index 4b9981c..8395fea 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -135,6 +135,7 @@
 #include <linux/cpu_rmap.h>
 #include <linux/if_tunnel.h>
 #include <linux/if_pppox.h>
+#include <linux/ppp_defs.h>
 
 #include "net-sysfs.h"
 
@@ -2548,6 +2549,7 @@ void __skb_get_rxhash(struct sk_buff *skb)
 again:
 	switch (proto) {
 	case __constant_htons(ETH_P_IP):
+ip:
 		if (!pskb_may_pull(skb, sizeof(*ip) + nhoff))
 			goto done;
 
@@ -2561,6 +2563,7 @@ again:
 		nhoff += ip->ihl * 4;
 		break;
 	case __constant_htons(ETH_P_IPV6):
+ipv6:
 		if (!pskb_may_pull(skb, sizeof(*ip6) + nhoff))
 			goto done;
 
@@ -2583,7 +2586,14 @@ again:
 		proto = *((__be16 *) (skb->data + nhoff +
 				      sizeof(struct pppoe_hdr)));
 		nhoff += PPPOE_SES_HLEN;
-		goto again;
+		switch (proto) {
+		case __constant_htons(PPP_IP):
+			goto ip;
+		case __constant_htons(PPP_IPV6):
+			goto ipv6;
+		default:
+			goto done;
+		}
 	default:
 		goto done;
 	}
