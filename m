From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 10/20] sfc: Test for PHYXS faults whenever we cannot test
	link state bits
Date: Thu, 29 Jan 2009 19:19:49 +0000
Message-ID: <1233256789.3656.31.camel@achroite>
References: <1233256358.3656.9.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:33167 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753567AbZA2TTv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 14:19:51 -0500
In-Reply-To: <1233256358.3656.9.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=EF=BB=BFFrom: Steve Hodgson <shodgson@solarflare.com>

Depending on the loopback mode, there may be no pertinent link state
bits.  In this case we test the PHYXS RX fault bit instead.  Make
sure to do this in all cases where there are no link state bits.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/mdio_10g.c |   16 +++++++++-------
 1 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/sfc/mdio_10g.c b/drivers/net/sfc/mdio_10g.c
index 3303628..c1a6b26 100644
--- a/drivers/net/sfc/mdio_10g.c
+++ b/drivers/net/sfc/mdio_10g.c
@@ -181,17 +181,12 @@ bool mdio_clause45_links_ok(struct efx_nic *efx, =
unsigned int mmd_mask)
 		return false;
 	else if (efx_phy_mode_disabled(efx->phy_mode))
 		return false;
-	else if (efx->loopback_mode =3D=3D LOOPBACK_PHYXS) {
+	else if (efx->loopback_mode =3D=3D LOOPBACK_PHYXS)
 		mmd_mask &=3D ~(MDIO_MMDREG_DEVS_PHYXS |
 			      MDIO_MMDREG_DEVS_PCS |
 			      MDIO_MMDREG_DEVS_PMAPMD |
 			      MDIO_MMDREG_DEVS_AN);
-		if (!mmd_mask) {
-			reg =3D mdio_clause45_read(efx, phy_id, MDIO_MMD_PHYXS,
-						 MDIO_PHYXS_STATUS2);
-			return !(reg & (1 << MDIO_PHYXS_STATUS2_RX_FAULT_LBN));
-		}
-	} else if (efx->loopback_mode =3D=3D LOOPBACK_PCS)
+	else if (efx->loopback_mode =3D=3D LOOPBACK_PCS)
 		mmd_mask &=3D ~(MDIO_MMDREG_DEVS_PCS |
 			      MDIO_MMDREG_DEVS_PMAPMD |
 			      MDIO_MMDREG_DEVS_AN);
@@ -199,6 +194,13 @@ bool mdio_clause45_links_ok(struct efx_nic *efx, u=
nsigned int mmd_mask)
 		mmd_mask &=3D ~(MDIO_MMDREG_DEVS_PMAPMD |
 			      MDIO_MMDREG_DEVS_AN);
=20
+	if (!mmd_mask) {
+		/* Use presence of XGMII faults in leui of link state */
+		reg =3D mdio_clause45_read(efx, phy_id, MDIO_MMD_PHYXS,
+					 MDIO_PHYXS_STATUS2);
+		return !(reg & (1 << MDIO_PHYXS_STATUS2_RX_FAULT_LBN));
+	}
+
 	while (mmd_mask) {
 		if (mmd_mask & 1) {
 			/* Double reads because link state is latched, and a

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

