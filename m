From: Mike McCormack <mikem@ring3k.org>
Subject: Re: [PATCH] sky2: Fix a race between sky2_down and sky2_poll
Date: Fri, 12 Jun 2009 22:16:42 +0900
Message-ID: <392fb48f0906120616n123d8b57h9ef7c8e1735d26bf@mail.gmail.com>
References: <392fb48f0906090703q66fbaf56wbf1157f90b97df0f@mail.gmail.com>
	 <20090611100448.09a9b730@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f216.google.com ([209.85.220.216]:49539 "EHLO
	mail-fx0-f216.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764672AbZFLNQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2009 09:16:41 -0400
Received: by fxm12 with SMTP id 12so613247fxm.37
        for <netdev@vger.kernel.org>; Fri, 12 Jun 2009 06:16:42 -0700 (PDT)
In-Reply-To: <20090611100448.09a9b730@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/6/12 Stephen Hemminger <shemminger@linux-foundation.org>

> Does the following fix the problem?

I tried your patch out, but it still got a crash.

The patch below does fix the problem. Does this look better?

thanks,

Mike

-----------------------------

Subject: [PATCH] sky2: Shutdown receive path cleanly in sky2_down

If sky2_down was called while receiving a packet, receive interrupts
would still occur after the receive buffer was free'd causing a crash in
sky2_status_intr.

To avoid further receive interrupts after sky2_down:

* make sure NAPI and interrupts are fully disabled during shutdown
* call sky2_rx_stop after shutting down the receiver
* clear received packets after shutdown

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |   21 +++++++++++++++------
 1 files changed, 15 insertions(+), 6 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index a2ff9cb..136b362 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1805,10 +1805,13 @@ static int sky2_down(struct net_device *dev)
 	/* Disable port IRQ */
 	imask = sky2_read32(hw, B0_IMSK);
 	imask &= ~portirq_msk[port];
-	sky2_write32(hw, B0_IMSK, imask);
+	sky2_write32(hw, B0_IMSK, 0);

 	synchronize_irq(hw->pdev->irq);

+	/* disable soft interrupts */
+	napi_disable(&hw->napi);
+
 	sky2_gmac_reset(hw, port);

 	/* Stop transmitter */
@@ -1822,9 +1825,6 @@ static int sky2_down(struct net_device *dev)
 	ctrl &= ~(GM_GPCR_TX_ENA | GM_GPCR_RX_ENA);
 	gma_write16(hw, port, GM_GP_CTRL, ctrl);

-	/* Make sure no packets are pending */
-	napi_synchronize(&hw->napi);
-
 	sky2_write8(hw, SK_REG(port, GPHY_CTRL), GPC_RST_SET);

 	/* Workaround shared GMAC reset */
@@ -1850,11 +1850,11 @@ static int sky2_down(struct net_device *dev)

 	sky2_write32(hw, RB_ADDR(txqaddr[port], RB_CTRL), RB_RST_SET);

-	sky2_rx_stop(sky2);
-
 	sky2_write8(hw, SK_REG(port, RX_GMF_CTRL_T), GMF_RST_SET);
 	sky2_write8(hw, SK_REG(port, TX_GMF_CTRL_T), GMF_RST_SET);

+	sky2_rx_stop(sky2);
+
 	sky2_phy_power_down(hw, port);

 	/* turn off LED's */
@@ -1878,6 +1878,15 @@ static int sky2_down(struct net_device *dev)
 	sky2->rx_ring = NULL;
 	sky2->tx_ring = NULL;

+	/* clear receive interrupt condition and IRQ */
+	hw->st_idx = sky2_read16(hw, STAT_PUT_IDX);
+
+	/* re-enable interrupts */
+	sky2_write32(hw, B0_IMSK, imask);
+
+	/* re-enable soft interrupts */
+	napi_enable(&hw->napi);
+
 	return 0;
 }

-- 
1.5.6.5
