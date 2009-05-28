From: Haiying Wang <Haiying.Wang@freescale.com>
Subject: [PATCH 2/4] fsl_pq_mido: Set the first UCC as the mii management interface master
Date: Thu, 28 May 2009 09:20:28 -0400
Message-ID: <1243516833328-git-send-email-Haiying.Wang@freescale.com>
References: <12435168302841-git-send-email-Haiying.Wang@freescale.com>
Cc: Haiying Wang <Haiying.Wang@freescale.com>
To: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:48107 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754675AbZE1NUH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2009 09:20:07 -0400
In-Reply-To: <12435168302841-git-send-email-Haiying.Wang@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current code makes the UCC whose register range includes the current mdio
register to be the MII managemnt interface master of the QE. If there is more
than one mdio bus for QE, the UCC of the last mdio bus will be the MII
management interface master which will make the primary mdio bus working
unproperly, e.g. can notget the right clock. Normally the primary mdio bus is
the first UEC's mdio bus.
This patch allows the first UCC to be the MII management interface master of the
multiple UCC mdio buses.

Signed-off-by: Haiying Wang <Haiying.Wang@freescale.com>
---
 drivers/net/fsl_pq_mdio.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/fsl_pq_mdio.c b/drivers/net/fsl_pq_mdio.c
index aa1eb88..fd317a0 100644
--- a/drivers/net/fsl_pq_mdio.c
+++ b/drivers/net/fsl_pq_mdio.c
@@ -338,13 +338,17 @@ static int fsl_pq_mdio_probe(struct of_device *ofdev,
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

