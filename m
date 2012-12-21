From: Isaku Yamahata <yamahata@valinux.co.jp>
Subject: [PATCH] ipv4/ip_gre: make ipgre_tunnel_xmit() not parse network header as IP unconditionally
Date: Fri, 21 Dec 2012 10:12:52 +0900
Message-ID: <9ee0cd8f94e1ee866b40ee7b6755e8d8705325c9.1356052319.git.yamahata@valinux.co.jp>
Cc: yamahata@valinux.co.jp
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.valinux.co.jp ([210.128.90.3]:49593 "EHLO
	mail.valinux.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752267Ab2LUBMy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2012 20:12:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipgre_tunnel_xmit() parses network header as IP unconditionally.
But transmitting packets are not always IP packet. For example such packet
can be sent by packet socket with sockaddr_ll.sll_protocol set.
So make the function check if skb->protocol is IP.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 net/ipv4/ip_gre.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index a85ae2f..8fcf0ed 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -760,7 +760,10 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 
 	if (dev->header_ops && dev->type == ARPHRD_IPGRE) {
 		gre_hlen = 0;
-		tiph = (const struct iphdr *)skb->data;
+		if (skb->protocol == htons(ETH_P_IP))
+			tiph = (const struct iphdr *)skb->data;
+		else
+			tiph = &tunnel->parms.iph;
 	} else {
 		gre_hlen = tunnel->hlen;
 		tiph = &tunnel->parms.iph;
-- 
1.7.10.4
