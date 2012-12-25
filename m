From: Isaku Yamahata <yamahata@valinux.co.jp>
Subject: [PATCH 2/2] ipv6/ip6_gre: set transport header correctly
Date: Tue, 25 Dec 2012 11:51:04 +0900
Message-ID: <8b3ad21951fd0ab05910ce5d4f4646142b18663a.1356403806.git.yamahata@valinux.co.jp>
References: <a6eb43766a3959d111cde14b237d435de0b19e15.1356403805.git.yamahata@valinux.co.jp>
Cc: yamahata@valinux.co.jp
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.valinux.co.jp ([210.128.90.3]:44087 "EHLO
	mail.valinux.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753428Ab2LYCvG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Dec 2012 21:51:06 -0500
In-Reply-To: <a6eb43766a3959d111cde14b237d435de0b19e15.1356403805.git.yamahata@valinux.co.jp>
In-Reply-To: <a6eb43766a3959d111cde14b237d435de0b19e15.1356403805.git.yamahata@valinux.co.jp>
References: <a6eb43766a3959d111cde14b237d435de0b19e15.1356403805.git.yamahata@valinux.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip6gre_xmit2() incorrectly sets transport header to inner payload
instead of GRE header. It seems copy-and-pasted from ipip.c.
Set transport header to gre header.
(In ipip case the transport header is the inner ip header, so that's
correct.)

Found by inspection. In practice the incorrect transport header
doesn't matter because the skb usually is sent to another net_device
or socket, so the transport header isn't referenced.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 net/ipv6/ip6_gre.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 867466c..c727e47 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -758,8 +758,6 @@ static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb,
 		skb_dst_set_noref(skb, dst);
 	}
 
-	skb->transport_header = skb->network_header;
-
 	proto = NEXTHDR_GRE;
 	if (encap_limit >= 0) {
 		init_tel_txopt(&opt, encap_limit);
@@ -768,6 +766,7 @@ static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb,
 
 	skb_push(skb, gre_hlen);
 	skb_reset_network_header(skb);
+	skb_set_transport_header(skb, sizeof(*ipv6h));
 
 	/*
 	 *	Push down and install the IP header.
-- 
1.7.10.4
