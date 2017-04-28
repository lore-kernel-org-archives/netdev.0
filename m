From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH net] ipv4: Don't pass IP fragments to upper layer GRO
 handlers.
Date: Fri, 28 Apr 2017 10:54:32 +0200
Message-ID: <20170428085432.GH2649@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:59860 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1034686AbdD1KNV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Apr 2017 06:13:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Upper layer GRO handlers can not handle IP fragments, so
exit GRO processing in this case.

This fixes ESP GRO because the packet must be reassembled
before we can decapsulate, otherwise we get authentication
failures.

It also aligns IPv4 to IPv6 where packets with fragmentation
headers are not passed to upper layer GRO handlers.

Fixes: 7785bba299a8 ("esp: Add a software GRO codepath")
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/af_inet.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 6b1fc6e..13a9a32 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1343,6 +1343,9 @@ struct sk_buff **inet_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 	if (*(u8 *)iph != 0x45)
 		goto out_unlock;
 
+	if (ip_is_fragment(iph))
+		goto out_unlock;
+
 	if (unlikely(ip_fast_csum((u8 *)iph, 5)))
 		goto out_unlock;
 
-- 
2.7.4
