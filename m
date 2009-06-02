From: Haiying Wang <Haiying.Wang@freescale.com>
Subject: [PATCH 2/4] fsl_pq_mido: Set the first UCC as the mii management interface master
Date: Tue,  2 Jun 2009 10:04:14 -0400
Message-ID: <1243951456-4685-2-git-send-email-Haiying.Wang@freescale.com>
References: <1243951456-4685-1-git-send-email-Haiying.Wang@freescale.com>
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	Haiying Wang <Haiying.Wang@freescale.com>
To: davem@davemloft.net, galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:44581 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755756AbZFBODr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 10:03:47 -0400
In-Reply-To: <1243951456-4685-1-git-send-email-Haiying.Wang@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current code makes the UCC whose register range includes the current mdio
register to be the MII managemnt interface master of the QE. If there is more
than one mdio bus for QE, the UCC of the last mdio bus will be the MII
management interface master which will make the primary mdio bus working
unproperly, e.g. can not get the right clock. Normally the primary mdio bus is
the first UEC's mdio bus.
This patch allows the first UCC to be the MII management interface master of the
multiple UCC mdio buses.

Signed-off-by: Haiying Wang <Haiying.Wang@freescale.com>
---
 drivers/net/fsl_pq_mdio.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/fsl_pq_mdio.c b/drivers/net/fsl_pq_mdio.c
index d12e0e0..3af5813 100644
--- a/drivers/net/fsl_pq_mdio.c
+++ b/drivers/net/fsl_pq_mdio.c
@@ -301,13 +301,17 @@ static int fsl_pq_mdio_probe(struct of_device *ofdev,
 			of_device_is_compatible(np, "ucc_geth_phy")) {
 #ifdef CONFIG_UCC_GETH
 		u32 id;
+		static u32 mii_mng_master;
 
 		tbipa = &regs->utbipar;
 
 		if ((err = get_ucc_id_for_range(addr, addr + size, &id)))
 			goto err_free_irqs;
 
-		ucc_set_qe_mux_mii_mng(id - 1);
+		if (!mii_mng_master) {
+			mii_mng_master = id;
+			ucc_set_qe_mux_mii_mng(id - 1);
+		}
 #else
 		err = -ENODEV;
 		goto err_free_irqs;
-- 
1.6.0.2

