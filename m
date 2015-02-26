From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: [RFC][PATCH] sh_eth: Fix RX recovery in case of RX ring underrun
Date: Thu, 26 Feb 2015 20:51:24 +0000
Message-ID: <1424983884.4444.87.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@lists.codethink.co.uk,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
To: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:47203 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752483AbbBZUva (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 15:51:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case of RX ring underrun, we attempt to reset the software
descriptor pointers (dirty_rx and cur_rx) to match where the hardware
stopped.  This behaviour was added by commit 79fba9f51755 ("net:
sh_eth: fix the rxdesc pointer when rx descriptor empty happens").  I
think the problem it's addressing is that the RX DMA engine may
advance its descriptor pointer beyond the first dirty descriptor, so
that when we re-enable RX it will skip some descriptors.

This fix is problematic because:

1. If the quota is smaller than the ring size, changing cur_rx may
   mean that we skip (and thus drop) packets that were received
   successfully.
2. If we've previously seen dirty descriptors and failed to allocate
   new buffers for them, changing dirty_rx means that we won't try to
   refill them on the next poll.  This will result in another ring
   underrun.

Instead, we should find the first clean descriptor and write the
correct address to RDFAR (if defined).

This is entirely untested.

Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
---
This depends on "sh_eth: Fix RX recovery on R-Car in case of RX ring
underrun" and "sh_eth: WARN on access to a register not implemented in a
particular chip" which I sent earlier.  I don't have any hardware
to test this with, or any need to make it work.  If you want this fix,
please test and re-submit it yoursef.

You should be able to reproduce these problems by inserting udelay(10)
into the main loop and then sending minimum-length frames to the sh_eth
interface using pktgen, and also
(for problem 1) changing the RX ring size to >64, or
(for problem 2) injecting memory allocation failures (e.g. using
CONFIG_FAIL_PAGE_ALLOC)

Ben.

 drivers/net/ethernet/renesas/sh_eth.c |   28 +++++++++++++++++++++-------
 1 file changed, 21 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index c3bc01ccad3e..49c8ee857de3 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1550,23 +1550,37 @@ static int sh_eth_rx(struct net_device *ndev, u32 intr_status, int *quota)
 				cpu_to_edmac(mdp, RD_RACT | RD_RFP);
 	}
 
+	*quota -= limit - boguscnt - 1;
+
 	/* Restart Rx engine if stopped. */
 	/* If we don't need to check status, don't. -KDU */
 	if (!(sh_eth_read(ndev, EDRRR) & EDRRR_R)) {
-		/* fix the values for the next receiving if RDE is set */
+		/* fix the value for the next receive if RDE is set */
 		if (intr_status & EESR_RDE &&
 		    mdp->reg_offset[RDFAR] != SH_ETH_OFFSET_INVALID) {
-			u32 count = (sh_eth_read(ndev, RDFAR) -
-				     sh_eth_read(ndev, RDLAR)) >> 4;
+			int entry = mdp->cur_rx % mdp->num_rx_ring;
 
-			mdp->cur_rx = count;
-			mdp->dirty_rx = count;
+			/* If we did not finish receiving packets on
+			 * this iteration, search ahead for the first
+			 * clean descriptor.
+			 */
+			if (*quota <= 0) {
+				while (boguscnt > 0 &&
+				       !(mdp->rx_ring[entry].status &
+					 cpu_to_edmac(mdp, RD_RACT))) {
+					--boguscnt;
+					entry = (entry + 1) % mdp->num_rx_ring;
+				}
+			}
+
+			sh_eth_write(ndev,
+				     mdp->rx_desc_dma +
+				     entry * sizeof(struct sh_eth_rxdesc),
+				     RDFAR);
 		}
 		sh_eth_write(ndev, EDRRR_R, EDRRR);
 	}
 
-	*quota -= limit - boguscnt - 1;
-
 	return *quota <= 0;
 }
 
-- 
1.7.10.4
