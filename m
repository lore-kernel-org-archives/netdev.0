From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 4/8] sfc: Do not read STAT1.FAULT in
 efx_mdio_check_mmd()
Date: Tue, 01 Mar 2011 01:22:50 +0000
Message-ID: <1298942570.3069.183.camel@localhost>
References: <1298942169.3069.179.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:12053 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753541Ab1CABWy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 20:22:54 -0500
In-Reply-To: <1298942169.3069.179.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This field does not exist in all MMDs we want to check, and all
callers allow it to be set (fault_fatal = 0).

Remove the loopback condition, as STAT2.DEVPRST should be valid
regardless of any fault.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/mdio_10g.c     |   32 +++++---------------------------
 drivers/net/sfc/mdio_10g.h     |    3 +--
 drivers/net/sfc/tenxpress.c    |    2 +-
 drivers/net/sfc/txc43128_phy.c |    2 +-
 4 files changed, 8 insertions(+), 31 deletions(-)

diff --git a/drivers/net/sfc/mdio_10g.c b/drivers/net/sfc/mdio_10g.c
index 56b0266..6e82e5b 100644
--- a/drivers/net/sfc/mdio_10g.c
+++ b/drivers/net/sfc/mdio_10g.c
@@ -51,13 +51,10 @@ int efx_mdio_reset_mmd(struct efx_nic *port, int mmd,
 	return spins ? spins : -ETIMEDOUT;
 }
 
-static int efx_mdio_check_mmd(struct efx_nic *efx, int mmd, int fault_fatal)
+static int efx_mdio_check_mmd(struct efx_nic *efx, int mmd)
 {
 	int status;
 
-	if (LOOPBACK_INTERNAL(efx))
-		return 0;
-
 	if (mmd != MDIO_MMD_AN) {
 		/* Read MMD STATUS2 to check it is responding. */
 		status = efx_mdio_read(efx, mmd, MDIO_STAT2);
@@ -68,20 +65,6 @@ static int efx_mdio_check_mmd(struct efx_nic *efx, int mmd, int fault_fatal)
 		}
 	}
 
-	/* Read MMD STATUS 1 to check for fault. */
-	status = efx_mdio_read(efx, mmd, MDIO_STAT1);
-	if (status & MDIO_STAT1_FAULT) {
-		if (fault_fatal) {
-			netif_err(efx, hw, efx->net_dev,
-				  "PHY MMD %d reporting fatal"
-				  " fault: status %x\n", mmd, status);
-			return -EIO;
-		} else {
-			netif_dbg(efx, hw, efx->net_dev,
-				  "PHY MMD %d reporting status"
-				  " %x (expected)\n", mmd, status);
-		}
-	}
 	return 0;
 }
 
@@ -130,8 +113,7 @@ int efx_mdio_wait_reset_mmds(struct efx_nic *efx, unsigned int mmd_mask)
 	return rc;
 }
 
-int efx_mdio_check_mmds(struct efx_nic *efx,
-			unsigned int mmd_mask, unsigned int fatal_mask)
+int efx_mdio_check_mmds(struct efx_nic *efx, unsigned int mmd_mask)
 {
 	int mmd = 0, probe_mmd, devs1, devs2;
 	u32 devices;
@@ -161,13 +143,9 @@ int efx_mdio_check_mmds(struct efx_nic *efx,
 
 	/* Check all required MMDs are responding and happy. */
 	while (mmd_mask) {
-		if (mmd_mask & 1) {
-			int fault_fatal = fatal_mask & 1;
-			if (efx_mdio_check_mmd(efx, mmd, fault_fatal))
-				return -EIO;
-		}
+		if ((mmd_mask & 1) && efx_mdio_check_mmd(efx, mmd))
+			return -EIO;
 		mmd_mask = mmd_mask >> 1;
-		fatal_mask = fatal_mask >> 1;
 		mmd++;
 	}
 
@@ -337,7 +315,7 @@ int efx_mdio_test_alive(struct efx_nic *efx)
 			  "no MDIO PHY present with ID %d\n", efx->mdio.prtad);
 		rc = -EINVAL;
 	} else {
-		rc = efx_mdio_check_mmds(efx, efx->mdio.mmds, 0);
+		rc = efx_mdio_check_mmds(efx, efx->mdio.mmds);
 	}
 
 	mutex_unlock(&efx->mac_lock);
diff --git a/drivers/net/sfc/mdio_10g.h b/drivers/net/sfc/mdio_10g.h
index 75791d3..44c5dee 100644
--- a/drivers/net/sfc/mdio_10g.h
+++ b/drivers/net/sfc/mdio_10g.h
@@ -68,8 +68,7 @@ extern int efx_mdio_reset_mmd(struct efx_nic *efx, int mmd,
 			      int spins, int spintime);
 
 /* As efx_mdio_check_mmd but for multiple MMDs */
-int efx_mdio_check_mmds(struct efx_nic *efx,
-			unsigned int mmd_mask, unsigned int fatal_mask);
+int efx_mdio_check_mmds(struct efx_nic *efx, unsigned int mmd_mask);
 
 /* Check the link status of specified mmds in bit mask */
 extern bool efx_mdio_links_ok(struct efx_nic *efx, unsigned int mmd_mask);
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index f102912..581911f 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -196,7 +196,7 @@ static int tenxpress_phy_init(struct efx_nic *efx)
 		if (rc < 0)
 			return rc;
 
-		rc = efx_mdio_check_mmds(efx, TENXPRESS_REQUIRED_DEVS, 0);
+		rc = efx_mdio_check_mmds(efx, TENXPRESS_REQUIRED_DEVS);
 		if (rc < 0)
 			return rc;
 	}
diff --git a/drivers/net/sfc/txc43128_phy.c b/drivers/net/sfc/txc43128_phy.c
index 351794a..4e2b48a 100644
--- a/drivers/net/sfc/txc43128_phy.c
+++ b/drivers/net/sfc/txc43128_phy.c
@@ -193,7 +193,7 @@ static int txc_reset_phy(struct efx_nic *efx)
 		goto fail;
 
 	/* Check that all the MMDs we expect are present and responding. */
-	rc = efx_mdio_check_mmds(efx, TXC_REQUIRED_DEVS, 0);
+	rc = efx_mdio_check_mmds(efx, TXC_REQUIRED_DEVS);
 	if (rc < 0)
 		goto fail;
 
-- 
1.5.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

