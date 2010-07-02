From: kaber@trash.net
Subject: [PATCH] netfilter: ip6t_REJECT: fix a dst leak in ipv6 REJECT
Date: Fri,  2 Jul 2010 13:42:22 +0200
Message-ID: <1278070942-26410-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48034 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751311Ab0GBLmX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jul 2010 07:42:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>

We should release dst if dst->error is set.

Bug introduced in 2.6.14 by commit e104411b82f5c
([XFRM]: Always release dst_entry on error in xfrm_lookup)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: stable@kernel.org
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv6/netfilter/ip6t_REJECT.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/netfilter/ip6t_REJECT.c b/net/ipv6/netfilter/ip6t_REJECT.c
index 47d2277..2933396 100644
--- a/net/ipv6/netfilter/ip6t_REJECT.c
+++ b/net/ipv6/netfilter/ip6t_REJECT.c
@@ -97,9 +97,11 @@ static void send_reset(struct net *net, struct sk_buff *oldskb)
 	fl.fl_ip_dport = otcph.source;
 	security_skb_classify_flow(oldskb, &fl);
 	dst = ip6_route_output(net, NULL, &fl);
-	if (dst == NULL)
+	if (dst == NULL || dst->error) {
+		dst_release(dst);
 		return;
-	if (dst->error || xfrm_lookup(net, &dst, &fl, NULL, 0))
+	}
+	if (xfrm_lookup(net, &dst, &fl, NULL, 0))
 		return;
 
 	hh_len = (dst->dev->hard_header_len + 15)&~15;
-- 
1.7.0.4

