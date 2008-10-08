From: Andreas Oberritter <obi@linuxtv.org>
Subject: [PATCH v2] 8139too: move wmb before TX DMA start
Date: Wed, 08 Oct 2008 18:14:16 +0200
Message-ID: <48ECDC58.1020603@linuxtv.org>
References: <48EC64E1.5070806@linuxtv.org> <20081008101558.GH7331@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ffm.saftware.de ([83.141.3.46]:45157 "EHLO ffm.saftware.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754110AbYJHQOQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2008 12:14:16 -0400
In-Reply-To: <20081008101558.GH7331@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Oberritter <obi@linuxtv.org>

The write barrier should be used before starting a DMA transfer. This fixes
a problem, where almost all packets received on another machine had garbled
content. Tested with an RTL8100C on a MIPS machine.

Signed-off-by: Andreas Oberritter <obi@linuxtv.org>
---
Added a comment on Ben's request explaining the reason for the barrier.

diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index 53bd903..3c5fac6 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -1716,13 +1716,18 @@ static int rtl8139_start_xmit (struct sk_buff *skb, struct net_device *dev)
 	}
 
 	spin_lock_irqsave(&tp->lock, flags);
+	/*
+	 * Writing to TxStatus triggers a DMA transfer of the data
+	 * copied to tp->tx_buf[entry] above. Use a memory barrier
+	 * to make sure that the device sees the updated data.
+	 */
+	wmb();
 	RTL_W32_F (TxStatus0 + (entry * sizeof (u32)),
 		   tp->tx_flag | max(len, (unsigned int)ETH_ZLEN));
 
 	dev->trans_start = jiffies;
 
 	tp->cur_tx++;
-	wmb();
 
 	if ((tp->cur_tx - NUM_TX_DESC) == tp->dirty_tx)
 		netif_stop_queue (dev);
