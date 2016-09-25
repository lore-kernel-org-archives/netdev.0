From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 36/53] netfilter: xt_TCPMSS: Refactor the codes to decrease one condition check and more readable
Date: Mon, 26 Sep 2016 01:06:46 +0200
Message-ID: <1474844823-2026-37-git-send-email-pablo@netfilter.org>
References: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54750 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1034826AbcIYXH5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Sep 2016 19:07:57 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id EFB5FC109C
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:55 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id DE290DA817
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:55 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id BC510DA818
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:53 +0200 (CEST)
In-Reply-To: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

The origin codes perform two condition checks with dst_mtu(skb_dst(skb))
and in_mtu. And the last statement is "min(dst_mtu(skb_dst(skb)),
in_mtu) - minlen". It may let reader think about how about the result.
Would it be negative.

Now assign the result of min(dst_mtu(skb_dst(skb)), in_mtu) to a new
variable, then only perform one condition check, and it is more readable.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_TCPMSS.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
index e118397254af..872db2d0e2a9 100644
--- a/net/netfilter/xt_TCPMSS.c
+++ b/net/netfilter/xt_TCPMSS.c
@@ -110,18 +110,14 @@ tcpmss_mangle_packet(struct sk_buff *skb,
 	if (info->mss == XT_TCPMSS_CLAMP_PMTU) {
 		struct net *net = par->net;
 		unsigned int in_mtu = tcpmss_reverse_mtu(net, skb, family);
+		unsigned int min_mtu = min(dst_mtu(skb_dst(skb)), in_mtu);
 
-		if (dst_mtu(skb_dst(skb)) <= minlen) {
+		if (min_mtu <= minlen) {
 			net_err_ratelimited("unknown or invalid path-MTU (%u)\n",
-					    dst_mtu(skb_dst(skb)));
+					    min_mtu);
 			return -1;
 		}
-		if (in_mtu <= minlen) {
-			net_err_ratelimited("unknown or invalid path-MTU (%u)\n",
-					    in_mtu);
-			return -1;
-		}
-		newmss = min(dst_mtu(skb_dst(skb)), in_mtu) - minlen;
+		newmss = min_mtu - minlen;
 	} else
 		newmss = info->mss;
 
-- 
2.1.4
