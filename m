From: Johannes Stezenbach <js@sig21.net>
Subject: Re: [PATCH 8/8] alx: remove WoL support
Date: Sun, 30 Jun 2013 17:03:04 +0200
Message-ID: <20130630150304.GA24189@sig21.net>
References: <1372526600-15934-1-git-send-email-johannes@sipsolutions.net>
 <1372526600-15934-9-git-send-email-johannes@sipsolutions.net>
 <20130629191248.GA10570@sig21.net>
 <1372534845.17242.0.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bar.sig21.net ([80.81.252.164]:43635 "EHLO bar.sig21.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751675Ab3F3PEN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Jun 2013 11:04:13 -0400
Content-Disposition: inline
In-Reply-To: <1372534845.17242.0.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Johannes,

I applied patches 1-7 of your series and the patch below
on top of it.  I had added some debug prints and found
that today alx_select_powersaving_speed() always found
a valid link after __alx_stop(), even though in
previous testing I had apparently unintialized data
in my logs from the "wol: ctrl=%X, speed=%d\n" message, no idea why.

The patch below seems to fix the wakeup issue, but WOL is
still mostly broken (immediately wakes up with
"ethtool -s eth0 wol g", but "wol p" can be used
to wake up when the cable is plugged in,
i.e. unplug -> suspend -> plug -> wake-up).
I just had one spurious wake-up after "wol p" ->
wake-up -> "wol d" -> spurious wake-up -> try again -> works.

So, if you still want to rip out WOL handling, go ahead.
My patch is just the minimal change to make the driver
behave well for my needs.

BTW, one issue that bugs me is that the link is still
up after "ifconfig eth0 down" (and it is up after loading
the driver before configuring the interface).  It seems
the ALX_PHY_CTRL_POWER_DOWN in alx_pre_suspend would
do the job, but I'm not sure and now out of time to do
more experiments.  I'm not sure how much power is wasted
by an unused PHY link.


Thanks,
Johannes


>From 1e2abe93f8b05deaeea485637f100d347a308aba Mon Sep 17 00:00:00 2001
From: Johannes Stezenbach <js@sig21.net>
Date: Sun, 30 Jun 2013 16:23:53 +0200
Subject: [PATCH] alx: disable WOL by default and fix immediate wakeups

WOL is still broken, but at least the driver doesn't
cause immediate wakeups anymore when it is disabled,
and the link is down when the system is suspended.

Signed-off-by: Johannes Stezenbach <js@sig21.net>

diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
index 148b4b9..6311acc 100644
--- a/drivers/net/ethernet/atheros/alx/main.c
+++ b/drivers/net/ethernet/atheros/alx/main.c
@@ -706,7 +706,7 @@ static int alx_init_sw(struct alx_priv *alx)
 	alx->rxbuf_size = ALIGN(ALX_RAW_MTU(hw->mtu), 8);
 	alx->tx_ringsz = 256;
 	alx->rx_ringsz = 512;
-	hw->sleep_ctrl = ALX_SLEEP_WOL_MAGIC | ALX_SLEEP_WOL_PHY;
+	hw->sleep_ctrl = 0;
 	hw->imt = 200;
 	alx->int_mask = ALX_ISR_MISC;
 	hw->dma_chnl = hw->max_dma_chnl;
@@ -983,20 +983,20 @@ static int __alx_shutdown(struct pci_dev *pdev, bool *wol_en)
 	err = alx_select_powersaving_speed(hw, &speed, &duplex);
 	if (err)
 		return err;
-	err = alx_clear_phy_intr(hw);
+	err = alx_config_wol(hw);
 	if (err)
 		return err;
 	err = alx_pre_suspend(hw, speed, duplex);
 	if (err)
 		return err;
-	err = alx_config_wol(hw);
+	err = alx_clear_phy_intr(hw);
 	if (err)
 		return err;
 
 	*wol_en = false;
 	if (hw->sleep_ctrl & ALX_SLEEP_ACTIVE) {
 		netif_info(alx, wol, netdev,
-			   "wol: ctrl=%X, speed=%X\n",
+			   "wol: ctrl=%X, speed=%d\n",
 			   hw->sleep_ctrl, speed);
 		device_set_wakeup_enable(&pdev->dev, true);
 		*wol_en = true;
