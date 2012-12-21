From: Eric Dumazet <erdnetdev@gmail.com>
Subject: [PATCH] ip_gre: fix possible use after free
Date: Thu, 20 Dec 2012 18:00:27 -0800
Message-ID: <1356055227.21834.4097.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Isaku Yamahata <yamahata@valinux.co.jp>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f50.google.com ([209.85.210.50]:59103 "EHLO
	mail-da0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751324Ab2LUCA3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2012 21:00:29 -0500
Received: by mail-da0-f50.google.com with SMTP id h15so1812420dan.37
        for <netdev@vger.kernel.org>; Thu, 20 Dec 2012 18:00:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Once skb_realloc_headroom() is called, tiph might point to freed memory.

Cache tiph->ttl value before the reallocation, to avoid unexpected
behavior.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Isaku Yamahata <yamahata@valinux.co.jp>
---
 net/ipv4/ip_gre.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index a85ae2f..4c22e70 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -750,6 +750,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 	int    gre_hlen;
 	__be32 dst;
 	int    mtu;
+	u8     ttl;
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL &&
 	    skb_checksum_help(skb))
@@ -812,6 +813,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 			goto tx_error;
 	}
 
+	ttl = tiph->ttl;
 	tos = tiph->tos;
 	if (tos == 1) {
 		tos = 0;
@@ -904,6 +906,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 		dev_kfree_skb(skb);
 		skb = new_skb;
 		old_iph = ip_hdr(skb);
+		/* Warning : tiph value might point to freed memory */
 	}
 
 	skb_reset_transport_header(skb);
@@ -927,8 +930,9 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 	iph->tos		=	ipgre_ecn_encapsulate(tos, old_iph, skb);
 	iph->daddr		=	fl4.daddr;
 	iph->saddr		=	fl4.saddr;
+	iph->ttl		=	ttl;
 
-	if ((iph->ttl = tiph->ttl) == 0) {
+	if (ttl == 0) {
 		if (skb->protocol == htons(ETH_P_IP))
 			iph->ttl = old_iph->ttl;
 #if IS_ENABLED(CONFIG_IPV6)
