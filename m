From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: [PATCH net 2/4] sh_eth: Fix RX recovery on R-Car in case of RX ring
 underrun
Date: Tue, 03 Mar 2015 00:52:08 +0000
Message-ID: <1425343928.4288.10.camel@xylophone.i.decadent.org.uk>
References: <1425343868.4288.8.camel@xylophone.i.decadent.org.uk>
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
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:40363 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755101AbbCCAwN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 19:52:13 -0500
In-Reply-To: <1425343868.4288.8.camel@xylophone.i.decadent.org.uk>
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
 drivers/net/ethernet/renesas/sh_eth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 5c212a833bcf..3309494d12ad 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1543,7 +1543,7 @@ static int sh_eth_rx(struct net_device *ndev, u32 intr_status, int *quota)
 	/* If we don't need to check status, don't. -KDU */
 	if (!(sh_eth_read(ndev, EDRRR) & EDRRR_R)) {
 		/* fix the values for the next receiving if RDE is set */
-		if (intr_status & EESR_RDE) {
+		if (intr_status & EESR_RDE && mdp->reg_offset[RDFAR] != 0) {
 			u32 count = (sh_eth_read(ndev, RDFAR) -
 				     sh_eth_read(ndev, RDLAR)) >> 4;
 
-- 
1.7.10.4
