From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 15/17] sfc: Add Siena PHY BIST and cable diagnostic support
Date: Wed, 28 Apr 2010 20:30:22 +0100
Message-ID: <1272483022.2549.31.camel@achroite.uk.solarflarecom.com>
References: <1272482722.2549.17.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:12622 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756747Ab0D1TaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 15:30:25 -0400
In-Reply-To: <1272482722.2549.17.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Hodgson <shodgson@solarflare.com>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/mcdi_phy.c |  146 +++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 144 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/mcdi_phy.c b/drivers/net/sfc/mcdi_phy.c
index 5d34487..6032c0e 100644
--- a/drivers/net/sfc/mcdi_phy.c
+++ b/drivers/net/sfc/mcdi_phy.c
@@ -17,6 +17,8 @@
 #include "mcdi.h"
 #include "mcdi_pcol.h"
 #include "mdio_10g.h"
+#include "nic.h"
+#include "selftest.h"
 
 struct efx_mcdi_phy_cfg {
 	u32 flags;
@@ -594,6 +596,146 @@ static int efx_mcdi_phy_test_alive(struct efx_nic *efx)
 	return 0;
 }
 
+static const char *const mcdi_sft9001_cable_diag_names[] = {
+	"cable.pairA.length",
+	"cable.pairB.length",
+	"cable.pairC.length",
+	"cable.pairD.length",
+	"cable.pairA.status",
+	"cable.pairB.status",
+	"cable.pairC.status",
+	"cable.pairD.status",
+};
+
+static int efx_mcdi_bist(struct efx_nic *efx, unsigned int bist_mode,
+			 int *results)
+{
+	unsigned int retry, i, count = 0;
+	size_t outlen;
+	u32 status;
+	u8 *buf, *ptr;
+	int rc;
+
+	buf = kzalloc(0x100, GFP_KERNEL);
+	if (buf == NULL)
+		return -ENOMEM;
+
+	BUILD_BUG_ON(MC_CMD_START_BIST_OUT_LEN != 0);
+	MCDI_SET_DWORD(buf, START_BIST_IN_TYPE, bist_mode);
+	rc = efx_mcdi_rpc(efx, MC_CMD_START_BIST, buf, MC_CMD_START_BIST_IN_LEN,
+			  NULL, 0, NULL);
+	if (rc)
+		goto out;
+
+	/* Wait up to 10s for BIST to finish */
+	for (retry = 0; retry < 100; ++retry) {
+		BUILD_BUG_ON(MC_CMD_POLL_BIST_IN_LEN != 0);
+		rc = efx_mcdi_rpc(efx, MC_CMD_POLL_BIST, NULL, 0,
+				  buf, 0x100, &outlen);
+		if (rc)
+			goto out;
+
+		status = MCDI_DWORD(buf, POLL_BIST_OUT_RESULT);
+		if (status != MC_CMD_POLL_BIST_RUNNING)
+			goto finished;
+
+		msleep(100);
+	}
+
+	rc = -ETIMEDOUT;
+	goto out;
+
+finished:
+	results[count++] = (status == MC_CMD_POLL_BIST_PASSED) ? 1 : -1;
+
+	/* SFT9001 specific cable diagnostics output */
+	if (efx->phy_type == PHY_TYPE_SFT9001B &&
+	    (bist_mode == MC_CMD_PHY_BIST_CABLE_SHORT ||
+	     bist_mode == MC_CMD_PHY_BIST_CABLE_LONG)) {
+		ptr = MCDI_PTR(buf, POLL_BIST_OUT_SFT9001_CABLE_LENGTH_A);
+		if (status == MC_CMD_POLL_BIST_PASSED &&
+		    outlen >= MC_CMD_POLL_BIST_OUT_SFT9001_LEN) {
+			for (i = 0; i < 8; i++) {
+				results[count + i] =
+					EFX_DWORD_FIELD(((efx_dword_t *)ptr)[i],
+							EFX_DWORD_0);
+			}
+		}
+		count += 8;
+	}
+	rc = count;
+
+out:
+	kfree(buf);
+
+	return rc;
+}
+
+static int efx_mcdi_phy_run_tests(struct efx_nic *efx, int *results,
+				  unsigned flags)
+{
+	struct efx_mcdi_phy_cfg *phy_cfg = efx->phy_data;
+	u32 mode;
+	int rc;
+
+	if (phy_cfg->flags & (1 << MC_CMD_GET_PHY_CFG_BIST_LBN)) {
+		rc = efx_mcdi_bist(efx, MC_CMD_PHY_BIST, results);
+		if (rc < 0)
+			return rc;
+
+		results += rc;
+	}
+
+	/* If we support both LONG and SHORT, then run each in response to
+	 * break or not. Otherwise, run the one we support */
+	mode = 0;
+	if (phy_cfg->flags & (1 << MC_CMD_GET_PHY_CFG_BIST_CABLE_SHORT_LBN)) {
+		if ((flags & ETH_TEST_FL_OFFLINE) &&
+		    (phy_cfg->flags &
+		     (1 << MC_CMD_GET_PHY_CFG_BIST_CABLE_LONG_LBN)))
+			mode = MC_CMD_PHY_BIST_CABLE_LONG;
+		else
+			mode = MC_CMD_PHY_BIST_CABLE_SHORT;
+	} else if (phy_cfg->flags &
+		   (1 << MC_CMD_GET_PHY_CFG_BIST_CABLE_LONG_LBN))
+		mode = MC_CMD_PHY_BIST_CABLE_LONG;
+
+	if (mode != 0) {
+		rc = efx_mcdi_bist(efx, mode, results);
+		if (rc < 0)
+			return rc;
+		results += rc;
+	}
+
+	return 0;
+}
+
+const char *efx_mcdi_phy_test_name(struct efx_nic *efx, unsigned int index)
+{
+	struct efx_mcdi_phy_cfg *phy_cfg = efx->phy_data;
+
+	if (phy_cfg->flags & (1 << MC_CMD_GET_PHY_CFG_BIST_LBN)) {
+		if (index == 0)
+			return "bist";
+		--index;
+	}
+
+	if (phy_cfg->flags & ((1 << MC_CMD_GET_PHY_CFG_BIST_CABLE_SHORT_LBN) |
+			      (1 << MC_CMD_GET_PHY_CFG_BIST_CABLE_LONG_LBN))) {
+		if (index == 0)
+			return "cable";
+		--index;
+
+		if (efx->phy_type == PHY_TYPE_SFT9001B) {
+			if (index < ARRAY_SIZE(mcdi_sft9001_cable_diag_names))
+				return mcdi_sft9001_cable_diag_names[index];
+			index -= ARRAY_SIZE(mcdi_sft9001_cable_diag_names);
+		}
+	}
+
+	return NULL;
+}
+
 struct efx_phy_operations efx_mcdi_phy_ops = {
 	.probe		= efx_mcdi_phy_probe,
 	.init 	 	= efx_port_dummy_op_int,
@@ -604,6 +746,6 @@ struct efx_phy_operations efx_mcdi_phy_ops = {
 	.get_settings	= efx_mcdi_phy_get_settings,
 	.set_settings	= efx_mcdi_phy_set_settings,
 	.test_alive	= efx_mcdi_phy_test_alive,
-	.run_tests	= NULL,
-	.test_name	= NULL,
+	.run_tests	= efx_mcdi_phy_run_tests,
+	.test_name	= efx_mcdi_phy_test_name,
 };
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

