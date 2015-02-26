From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: [PATCH net 2/4] sh_eth: Fix RX recovery on R-Car in case of RX ring
 underrun
Date: Thu, 26 Feb 2015 14:19:08 +0000
Message-ID: <1424960348.4444.19.camel@xylophone.i.decadent.org.uk>
References: <1424959937.4444.12.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@lists.codethink.co.uk,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>,
	Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:34852 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753190AbbBZOTQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 09:19:16 -0500
In-Reply-To: <1424959937.4444.12.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case of RX ring underrun (RDE), we attempt to reset the software
descriptor pointers (dirty_rx and cur_rx) to match where the hardware
will read the next descriptor from, as that might not be the first
dirty descriptor.  This relies on reading RDFAR, but that register
doesn't exist on all supported chips - specifically, not on the R-Car
chips.  This will result in unpredictable behaviour on those chips
after an RDE.

Make this pointer reset conditional and assume that it isn't needed on
the R-Car chips.  This fix also assumes that RDFAR is never exposed at
offset 0 in the memory map - this is currently true, and a subsequent
commit will fix the ambiguity between offset 0 and no-offset in the
register offset maps.

Fixes: 79fba9f51755 ("net: sh_eth: fix the rxdesc pointer when rx ...")
Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
---
I was able to trigger RDE by adding a udelay(10) to the loop in
sh_eth_rx() (limiting RX to <100,000 pps) and sending minimum size
frames with pktgen (~160,000 pps at 100M).  The RDE was recorded in the
netdev stats.  After the RDE and recover I could still pass traffic
successfully so no extra code appears to be needed for this chip.

Ben.

 drivers/net/ethernet/renesas/sh_eth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 2bc0be45c751..ed67951f5271 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1540,7 +1540,7 @@ static int sh_eth_rx(struct net_device *ndev, u32 intr_status, int *quota)
 	/* If we don't need to check status, don't. -KDU */
 	if (!(sh_eth_read(ndev, EDRRR) & EDRRR_R)) {
 		/* fix the values for the next receiving if RDE is set */
-		if (intr_status & EESR_RDE) {
+		if (intr_status & EESR_RDE && mdp->reg_offset[RDFAR] != 0) {
 			u32 count = (sh_eth_read(ndev, RDFAR) -
 				     sh_eth_read(ndev, RDLAR)) >> 4;
 
-- 
1.7.10.4
