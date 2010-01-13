From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-2.6] sfc: Fix conditions for MDIO self-test
Date: Wed, 13 Jan 2010 20:59:13 +0000
Message-ID: <1263416353.2797.22.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:18760 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755938Ab0AMU7Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2010 15:59:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MDIO self-test should not be run on boards without an MDIO PHY,
such as SFN5122F-R3 and later revisions.  It should also not try to
address a specific MMD in an MDIO clause 22 PHY.  Check the
mode_support field to decide which mode to use, if any.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/selftest.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index af39335..250c882 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -79,10 +79,14 @@ struct efx_loopback_state {
 static int efx_test_mdio(struct efx_nic *efx, struct efx_self_tests *tests)
 {
 	int rc = 0;
-	int devad = __ffs(efx->mdio.mmds);
+	int devad;
 	u16 physid1, physid2;
 
-	if (efx->phy_type == PHY_TYPE_NONE)
+	if (efx->mdio.mode_support & MDIO_SUPPORTS_C45)
+		devad = __ffs(efx->mdio.mmds);
+	else if (efx->mdio.mode_support & MDIO_SUPPORTS_C22)
+		devad = MDIO_DEVAD_NONE;
+	else
 		return 0;
 
 	mutex_lock(&efx->mac_lock);
-- 
1.5.5

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

