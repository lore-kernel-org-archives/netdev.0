From: Magnus Damm <magnus.damm@gmail.com>
Subject: [PATCH] net: sh_eth alignment fix for sh7724 using NET_IP_ALIGN
Date: Mon, 14 Dec 2009 19:34:43 +0900
Message-ID: <20091214103443.13082.84079.sendpatchset@rxone.opensource.se>
Cc: Magnus Damm <magnus.damm@gmail.com>, lethal@linux-sh.org,
	davem@davemloft.net, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Magnus Damm <damm@opensource.se>

Fix sh_eth for sh7724 by adding NET_IP_ALIGN support.
Without this patch the receive data is misaligned.

Signed-off-by: Magnus Damm <damm@opensource.se>
---

 Tested on Ecovec24. Perhaps for the sh-2.6 tree?

 drivers/net/sh_eth.c |    8 ++++++++
 1 file changed, 8 insertions(+)

--- 0001/drivers/net/sh_eth.c
+++ work/drivers/net/sh_eth.c	2009-12-14 15:27:25.000000000 +0900
@@ -84,6 +84,10 @@ static struct sh_eth_cpu_data sh_eth_my_
 	.mpr		= 1,
 	.tpauser	= 1,
 	.hw_swap	= 1,
+#if NET_IP_ALIGN == 2
+	.rpadir		= 1,
+	.rpadir_value	= 0x00020000,
+#endif
 };
 
 #elif defined(CONFIG_CPU_SUBTYPE_SH7763)
@@ -501,6 +505,8 @@ static int sh_eth_ring_init(struct net_d
 	 */
 	mdp->rx_buf_sz = (ndev->mtu <= 1492 ? PKT_BUF_SZ :
 			  (((ndev->mtu + 26 + 7) & ~7) + 2 + 16));
+	if (mdp->cd->rpadir)
+		mdp->rx_buf_sz += NET_IP_ALIGN;
 
 	/* Allocate RX and TX skb rings */
 	mdp->rx_skbuff = kmalloc(sizeof(*mdp->rx_skbuff) * RX_RING_SIZE,
@@ -715,6 +721,8 @@ static int sh_eth_rx(struct net_device *
 					pkt_len + 2);
 			skb = mdp->rx_skbuff[entry];
 			mdp->rx_skbuff[entry] = NULL;
+			if (mdp->cd->rpadir)
+				skb_reserve(skb, NET_IP_ALIGN);
 			skb_put(skb, pkt_len);
 			skb->protocol = eth_type_trans(skb, ndev);
 			netif_rx(skb);
