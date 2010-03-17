From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: Re: [PATCH 1/1] KS8695: update ksp->next_rx_desc_read at the end of
	rx loop
Date: Wed, 17 Mar 2010 10:40:10 +0100
Message-ID: <f69abfc31003170240u717283egf2c66adfaaa9aca7@mail.gmail.com>
References: <f69abfc31003160842r59c25bbdl2029d3f20e668e53@mail.gmail.com>
	 <1268754720.3094.55.camel@edumazet-laptop>
	 <f69abfc31003170239k2d64aa8bgbe3f3ae59a074a05@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:43940 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753860Ab0CQJkM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Mar 2010 05:40:12 -0400
Received: by ewy20 with SMTP id 20so308737ewy.1
        for <netdev@vger.kernel.org>; Wed, 17 Mar 2010 02:40:10 -0700 (PDT)
In-Reply-To: <f69abfc31003170239k2d64aa8bgbe3f3ae59a074a05@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

KS8695: update ksp->next_rx_desc_read at the end of rx loop

There is no need to adjust the next rx descriptor after each packet,
so do it only once at the end of the routine.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Yegor Yefremov <yegorslists@googlemail.com>

Index: linux-2.6.34-rc1/drivers/net/arm/ks8695net.c
===================================================================
--- linux-2.6.34-rc1.orig/drivers/net/arm/ks8695net.c
+++ linux-2.6.34-rc1/drivers/net/arm/ks8695net.c
@@ -449,11 +449,10 @@ ks8695_rx_irq(int irq, void *dev_id)
 }

 /**
- *	ks8695_rx - Receive packets  called by NAPI poll method
+ *	ks8695_rx - Receive packets called by NAPI poll method
  *	@ksp: Private data for the KS8695 Ethernet
- *	@budget: The max packets would be receive
+ *	@budget: Number of packets allowed to process
  */
-
 static int ks8695_rx(struct ks8695_priv *ksp, int budget)
 {
 	struct net_device *ndev = ksp->ndev;
@@ -461,7 +460,6 @@ static int ks8695_rx(struct ks8695_priv
 	int buff_n;
 	u32 flags;
 	int pktlen;
-	int last_rx_processed = -1;
 	int received = 0;

 	buff_n = ksp->next_rx_desc_read;
@@ -471,6 +469,7 @@ static int ks8695_rx(struct ks8695_priv
 					cpu_to_le32(RDES_OWN)))) {
 			rmb();
 			flags = le32_to_cpu(ksp->rx_ring[buff_n].status);
+
 			/* Found an SKB which we own, this means we
 			 * received a packet
 			 */
@@ -533,23 +532,18 @@ rx_failure:
 			ksp->rx_ring[buff_n].status = cpu_to_le32(RDES_OWN);
 rx_finished:
 			received++;
-			/* And note this as processed so we can start
-			 * from here next time
-			 */
-			last_rx_processed = buff_n;
 			buff_n = (buff_n + 1) & MAX_RX_DESC_MASK;
-			/*And note which RX descriptor we last did */
-			if (likely(last_rx_processed != -1))
-				ksp->next_rx_desc_read =
-					(last_rx_processed + 1) &
-					MAX_RX_DESC_MASK;
 	}
+
+	/* And note which RX descriptor we last did */
+	ksp->next_rx_desc_read = buff_n;
+
 	/* And refill the buffers */
 	ks8695_refill_rxbuffers(ksp);

-	/* Kick the RX DMA engine, in case it became
-	 *  suspended */
+	/* Kick the RX DMA engine, in case it became suspended */
 	ks8695_writereg(ksp, KS8695_DRSC, 0);
+
 	return received;
 }
