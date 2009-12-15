From: Magnus Damm <magnus.damm@gmail.com>
Subject: [PATCH] net: sh_eth alignment fix for sh7724 using NET_IP_ALIGN V2
Date: Tue, 15 Dec 2009 20:03:44 +0900
Message-ID: <20091215110344.13016.27379.sendpatchset@rxone.opensource.se>
Cc: Magnus Damm <magnus.damm@gmail.com>, lethal@linux-sh.org,
	davem@davemloft.net, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:46433 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757767AbZLOLJb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2009 06:09:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Magnus Damm <damm@opensource.se>

Fix sh_eth for sh7724 by adding NET_IP_ALIGN support V2.
Without this patch the receive data is misaligned.

Signed-off-by: Magnus Damm <damm@opensource.se>
---

 Thanks to Dave Miller for feedback!
 Tested on sh7724 / Ecovec24.

 Changes since V1:
 - dropped #ifdef around sh7724 .rpadir and .rpadir_value
 - removed sh7763 .rpadir

 drivers/net/sh_eth.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

--- 0001/drivers/net/sh_eth.c
+++ work/drivers/net/sh_eth.c	2009-12-15 19:58:55.000000000 +0900
@@ -84,6 +84,8 @@ static struct sh_eth_cpu_data sh_eth_my_
 	.mpr		= 1,
 	.tpauser	= 1,
 	.hw_swap	= 1,
+	.rpadir		= 1,
+	.rpadir_value	= 0x00020000, /* NET_IP_ALIGN assumed to be 2 */
 };
 
 #elif defined(CONFIG_CPU_SUBTYPE_SH7763)
@@ -175,7 +177,6 @@ static struct sh_eth_cpu_data sh_eth_my_
 	.tpauser	= 1,
 	.bculr		= 1,
 	.hw_swap	= 1,
-	.rpadir		= 1,
 	.no_trimd	= 1,
 	.no_ade		= 1,
 };
@@ -501,6 +502,8 @@ static int sh_eth_ring_init(struct net_d
 	 */
 	mdp->rx_buf_sz = (ndev->mtu <= 1492 ? PKT_BUF_SZ :
 			  (((ndev->mtu + 26 + 7) & ~7) + 2 + 16));
+	if (mdp->cd->rpadir)
+		mdp->rx_buf_sz += NET_IP_ALIGN;
 
 	/* Allocate RX and TX skb rings */
 	mdp->rx_skbuff = kmalloc(sizeof(*mdp->rx_skbuff) * RX_RING_SIZE,
@@ -715,6 +718,8 @@ static int sh_eth_rx(struct net_device *
 					pkt_len + 2);
 			skb = mdp->rx_skbuff[entry];
 			mdp->rx_skbuff[entry] = NULL;
+			if (mdp->cd->rpadir)
+				skb_reserve(skb, NET_IP_ALIGN);
 			skb_put(skb, pkt_len);
 			skb->protocol = eth_type_trans(skb, ndev);
 			netif_rx(skb);
