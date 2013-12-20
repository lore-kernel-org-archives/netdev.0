From: roy.qing.li@gmail.com
Subject: [PATCH] ipv6: release dst properly in ipip6_tunnel_xmit
Date: Fri, 20 Dec 2013 17:20:12 +0800
Message-ID: <1387531212-17034-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:41964 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754720Ab3LTJUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 04:20:20 -0500
Received: by mail-pb0-f53.google.com with SMTP id ma3so2356964pbc.40
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 01:20:19 -0800 (PST)
Received: from localhost ([1.202.252.122])
        by mx.google.com with ESMTPSA id oc9sm12937568pbb.10.2013.12.20.01.20.16
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 20 Dec 2013 01:20:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

if a dst is not attached to anywhere, it should be released before
exit ipip6_tunnel_xmit, otherwise cause dst memory leakage.

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/ipv6/sit.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 366fbba..d68a224 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -966,8 +966,10 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 	tos = INET_ECN_encapsulate(tos, ipv6_get_dsfield(iph6));
 
 	skb = iptunnel_handle_offloads(skb, false, SKB_GSO_SIT);
-	if (IS_ERR(skb))
+	if (IS_ERR(skb)) {
+		ip_rt_put(rt);
 		goto out;
+	}
 
 	err = iptunnel_xmit(rt, skb, fl4.saddr, fl4.daddr, IPPROTO_IPV6, tos,
 			    ttl, df, !net_eq(tunnel->net, dev_net(dev)));
-- 
1.7.10.4
