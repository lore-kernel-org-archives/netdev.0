From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net] net: bridge: don't increment tx_dropped in br_do_proxy_arp
Date: Tue, 30 Aug 2016 17:44:29 +0200
Message-ID: <1472571869-3005-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Kyeyoon Park <kyeyoonp@codeaurora.org>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        bridge@lists.linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:36773 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751527AbcH3PqI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 11:46:08 -0400
Received: by mail-wm0-f53.google.com with SMTP id q128so126936653wma.1
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 08:46:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pskb_may_pull may fail due to various reasons (e.g. alloc failure), but the
skb isn't changed/dropped and processing continues so we shouldn't
increment tx_dropped.

CC: Kyeyoon Park <kyeyoonp@codeaurora.org>
CC: Roopa Prabhu <roopa@cumulusnetworks.com>
CC: Stephen Hemminger <stephen@networkplumber.org>
CC: bridge@lists.linux-foundation.org
Fixes: 958501163ddd ("bridge: Add support for IEEE 802.11 Proxy ARP")
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_input.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 8e486203d133..abe11f085479 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -80,13 +80,10 @@ static void br_do_proxy_arp(struct sk_buff *skb, struct net_bridge *br,
 
 	BR_INPUT_SKB_CB(skb)->proxyarp_replied = false;
 
-	if (dev->flags & IFF_NOARP)
+	if ((dev->flags & IFF_NOARP) ||
+	    !pskb_may_pull(skb, arp_hdr_len(dev)))
 		return;
 
-	if (!pskb_may_pull(skb, arp_hdr_len(dev))) {
-		dev->stats.tx_dropped++;
-		return;
-	}
 	parp = arp_hdr(skb);
 
 	if (parp->ar_pro != htons(ETH_P_IP) ||
-- 
2.1.4
