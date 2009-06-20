From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Subject: [PATCH] econet: have failed ec_queue_packet() call return
 NET_RX_BAD
Date: Sat, 20 Jun 2009 20:04:38 +0930
Message-ID: <20090620200438.b5443520.lk-netdev@lk-netdev.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.adam.net.au ([202.136.110.251]:49725 "EHLO
	smtp2.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750900AbZFTKek (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jun 2009 06:34:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

econet_rcv() calls ec_queue_packet(). The return from ec_queue_packet()
is the direct result of a call to sock_queue_rcv_skb(). Error returns
from ec_queue_packet() and therefore sock_queue_rcv_skb() are due to
kernel errors, so have econet_rcv() return NET_RX_BAD in this case.

If my understanding is correct, then

Signed-off-by: Mark Smith <markzzzsmith@yahoo.com.au>

diff --git a/net/econet/af_econet.c b/net/econet/af_econet.c
index 6f479fa..07f0f90 100644
--- a/net/econet/af_econet.c
+++ b/net/econet/af_econet.c
@@ -1092,8 +1092,10 @@ static int econet_rcv(struct sk_buff *skb, struct net_device *dev, struct packet
 		goto drop;
 
 	if (ec_queue_packet(sk, skb, edev->net, hdr->src_stn, hdr->cb,
-			    hdr->port))
-		goto drop;
+			    hdr->port)) {
+		kfree_skb(skb);
+		return NET_RX_BAD;
+	}
 
 	return 0;
 

