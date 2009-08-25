From: Sascha Hlusiak <contact@saschahlusiak.de>
Subject: [PATCH] sit: allow ip fragmentation when using nopmtudisc to fix package loss
Date: Tue, 25 Aug 2009 12:48:42 +0200
Message-ID: <1251197322-3177-1-git-send-email-contact@saschahlusiak.de>
Cc: Sascha Hlusiak <contact@saschahlusiak.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.10]:54055 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754237AbZHYKrU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 06:47:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

if tunnel parameters have frag_off set to IP_DF, pmtudisc on the ipv4 link
will be performed by deriving the mtu from the ipv4 link and setting the
DF-Flag of the encapsulating IPv4 Header. If fragmentation is needed on the
way, the IPv4 pmtu gets adjusted, the ipv6 package will be resent eventually,
using the new and lower mtu and everyone is happy.

If the frag_off parameter is unset, the mtu for the tunnel will be derived
from the tunnel device or the ipv6 pmtu, which might be higher than the ipv4
pmtu. In that case we must allow the fragmentation of the IPv4 packet because
the IPv6 mtu wouldn't 'learn' from the adjusted IPv4 pmtu, resulting in
frequent icmp_frag_needed and package loss on the IPv6 layer.

This patch allows fragmentation when tunnel was created with parameter
nopmtudisc, like in ipip/gre tunnels.

Signed-off-by: Sascha Hlusiak <contact@saschahlusiak.de>
---
 net/ipv6/sit.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 98b7327..386f1e9 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -778,7 +778,7 @@ static int ipip6_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	iph->version		=	4;
 	iph->ihl		=	sizeof(struct iphdr)>>2;
 	if (mtu > IPV6_MIN_MTU)
-		iph->frag_off	=	htons(IP_DF);
+		iph->frag_off	=	tiph->frag_off;
 	else
 		iph->frag_off	=	0;
 
-- 
1.6.4

