From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] fec: fix tx bounce handling
Date: Mon, 06 Feb 2012 14:44:43 +0100
Message-ID: <1328535883.2220.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1328520810-28030-1-git-send-email-hector.palacios@digi.com>
	 <1328522191.2220.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4F2FB39B.9010205@digi.com>
	 <1328532924.2220.25.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"jgq516@gmail.com" <jgq516@gmail.com>,
	"rostedt@goodmis.org" <rostedt@goodmis.org>,
	"tim.sander@hbm.com" <tim.sander@hbm.com>,
	"u.kleine-koenig@pengutronix.de" <u.kleine-koenig@pengutronix.de>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	Zeng Zhaoming <b32542@freescale.com>,
	Frank Li <Frank.Li@freescale.com>
To: Hector Palacios <hector.palacios@digi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:62222 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753420Ab2BFNoq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 08:44:46 -0500
Received: by werb13 with SMTP id b13so4276475wer.19
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2012 05:44:45 -0800 (PST)
In-Reply-To: <1328532924.2220.25.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fec_enet_alloc_buffers() doesnt check for allocation
failures for tx bounce buffers, and assumes kmalloc() returns aligned
blocks of memory. This is not always true.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Shawn Guo <shawn.guo@linaro.org>
---
Compile tested only.

 drivers/net/ethernet/freescale/fec.c |   11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 7b25e9c..f831d0d 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -319,8 +319,8 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	if (((unsigned long) bufaddr) & FEC_ALIGNMENT) {
 		unsigned int index;
 		index = bdp - fep->tx_bd_base;
-		memcpy(fep->tx_bounce[index], skb->data, skb->len);
-		bufaddr = fep->tx_bounce[index];
+		bufaddr = PTR_ALIGN(fep->tx_bounce[index], FEC_ALIGNMENT + 1);
+		memcpy(bufaddr, skb->data, skb->len);
 	}
 
 	/*
@@ -1196,7 +1196,6 @@ static void fec_enet_free_buffers(struct net_device *ndev)
 		bdp++;
 	}
 
-	bdp = fep->tx_bd_base;
 	for (i = 0; i < TX_RING_SIZE; i++)
 		kfree(fep->tx_bounce[i]);
 }
@@ -1210,7 +1209,7 @@ static int fec_enet_alloc_buffers(struct net_device *ndev)
 
 	bdp = fep->rx_bd_base;
 	for (i = 0; i < RX_RING_SIZE; i++) {
-		skb = dev_alloc_skb(FEC_ENET_RX_FRSIZE);
+		skb = __dev_alloc_skb(FEC_ENET_RX_FRSIZE, GFP_KERNEL);
 		if (!skb) {
 			fec_enet_free_buffers(ndev);
 			return -ENOMEM;
@@ -1230,6 +1229,10 @@ static int fec_enet_alloc_buffers(struct net_device *ndev)
 	bdp = fep->tx_bd_base;
 	for (i = 0; i < TX_RING_SIZE; i++) {
 		fep->tx_bounce[i] = kmalloc(FEC_ENET_TX_FRSIZE, GFP_KERNEL);
+		if (!fep->tx_bounce[i]) {
+			fec_enet_free_buffers(ndev);
+			return -ENOMEM;
+		}
 
 		bdp->cbd_sc = 0;
 		bdp->cbd_bufaddr = 0;
