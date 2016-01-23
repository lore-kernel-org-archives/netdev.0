From: Martin Roth <martin.roth@motorolasolutions.com>
Subject: [PATCH] 82xx: FCC: Fixing a bug causing to FCC port lock-up (second try)
Date: Sun, 24 Jan 2016 00:56:19 +0200
Message-ID: <1453589779-13187-1-git-send-email-martin.roth@motorolasolutions.com>
Cc: linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	Martin Roth <martin.roth@motorolasolutions.com>
To: pantelis.antoniou@gmail.com, vbordug@ru.mvista.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an additional patch to the one already submitted recently.
The previous patch was not complete, and the FCC port lock-up scenario
has been reproduced in lab.
I had an opportunity to check the current patch in lab and the FCC
port lock no longer freezes, while the previous patch still locks-up the
FCC port.
The current patch fixes a pointer arithmetic bug (second bug in the same
line), which leads FCC port lock-up during underrun/collision handling.
Within the tx_startup() function in mac-fcc.c, the address of last BD is
not calculated correctly. As a result of wrong calculation of the last BD
address, the next transmitted BD may be set to an area out of the transmit
BD ring. This actually causes to port lock-up and it is not recoverable.

Signed-off-by: Martin Roth <martin.roth@motorolasolutions.com>
---
 drivers/net/ethernet/freescale/fs_enet/mac-fcc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fs_enet/mac-fcc.c b/drivers/net/ethernet/freescale/fs_enet/mac-fcc.c
index 52e0091..1ba359f 100644
--- a/drivers/net/ethernet/freescale/fs_enet/mac-fcc.c
+++ b/drivers/net/ethernet/freescale/fs_enet/mac-fcc.c
@@ -552,7 +552,7 @@ static void tx_restart(struct net_device *dev)
 	cbd_t __iomem *prev_bd;
 	cbd_t __iomem *last_tx_bd;
 
-	last_tx_bd = fep->tx_bd_base + ((fpi->tx_ring - 1) * sizeof(cbd_t));
+	last_tx_bd = fep->tx_bd_base + (fpi->tx_ring - 1);
 
 	/* get the current bd held in TBPTR  and scan back from this point */
 	recheck_bd = curr_tbptr = (cbd_t __iomem *)
-- 
1.7.9.5
