From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH] ip_gre: When TOS is inherited, use configured TOS value for non-IP packets
Date: Sun, 27 Jan 2013 18:04:58 -0500
Message-ID: <1359327899-8153-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Timo Teras <timo.teras@iki.fi>, David Ward <david.ward@ll.mit.edu>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:51352 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753080Ab3A0Xjm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Jan 2013 18:39:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A GRE tunnel can be configured so that outgoing tunnel packets inherit
the value of the TOS field from the inner IP header. In doing so, when
a non-IP packet is transmitted through the tunnel, the TOS field will
always be set to 0.

Instead, the user should be able to configure a different TOS value as
the fallback to use for non-IP packets. This is helpful when the non-IP
packets are all control packets and should be handled by routers outside
the tunnel as having Internet Control precedence. One example of this is
the NHRP packets that control a DMVPN-compatible mGRE tunnel; they are
encapsulated directly by GRE and do not contain an inner IP header.

Under the existing behavior, the IFLA_GRE_TOS parameter must be set to
'1' for the TOS value to be inherited. Now, only the least significant
bit of this parameter must be set to '1', and when a non-IP packet is
sent through the tunnel, the upper 6 bits of this same parameter will be
copied into the TOS field. (The ECN bits get masked off as before.)

This behavior is backwards-compatible with existing configurations and
iproute2 versions.

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 net/ipv4/ip_gre.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 303012a..e4c8817 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -818,8 +818,8 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 
 	ttl = tiph->ttl;
 	tos = tiph->tos;
-	if (tos == 1) {
-		tos = 0;
+	if (tos & 0x1) {
+		tos &= ~0x1;
 		if (skb->protocol == htons(ETH_P_IP))
 			tos = old_iph->tos;
 		else if (skb->protocol == htons(ETH_P_IPV6))
-- 
1.7.1
