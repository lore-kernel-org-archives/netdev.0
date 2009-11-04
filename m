From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/2 02/15] wimax/i2400m/sdio: clear the INTR status bit after reading size
Date: Wed,  4 Nov 2009 13:39:43 -0800
Message-ID: <339ccc362cb60b48e478ff494172efadb385c0ab.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
Cc: Cindy H Kao <cindy.h.kao@intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:20702 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758260AbZKDVl5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:41:57 -0500
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cindy H Kao <cindy.h.kao@intel.com>

In order to avoid issues during high-load traffic, the interrupt
status register has to be cleared ONLY after the RX size is read.

Signed-off-by: Cindy H Kao <cindy.h.kao@intel.com>
Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/sdio-rx.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wimax/i2400m/sdio-rx.c b/drivers/net/wimax/i2400m/sdio-rx.c
index f6ca51a..1c90469 100644
--- a/drivers/net/wimax/i2400m/sdio-rx.c
+++ b/drivers/net/wimax/i2400m/sdio-rx.c
@@ -138,6 +138,11 @@ void i2400ms_rx(struct i2400ms *i2400ms)
 		ret = rx_size;
 		goto error_get_size;
 	}
+	/*
+	 * Hardware quirk: make sure to clear the INTR status register
+	 * AFTER getting the data transfer size.
+	 */
+	sdio_writeb(func, 1, I2400MS_INTR_CLEAR_ADDR, &ret);
 
 	ret = -ENOMEM;
 	skb = alloc_skb(rx_size, GFP_ATOMIC);
@@ -209,7 +214,6 @@ void i2400ms_irq(struct sdio_func *func)
 		dev_err(dev, "RX: BUG? got IRQ but no interrupt ready?\n");
 		goto error_no_irq;
 	}
-	sdio_writeb(func, 1, I2400MS_INTR_CLEAR_ADDR, &ret);
 	i2400ms_rx(i2400ms);
 error_no_irq:
 	d_fnend(6, dev, "(i2400ms %p) = void\n", i2400ms);
-- 
1.6.2.5

