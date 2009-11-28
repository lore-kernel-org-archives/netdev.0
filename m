From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 21/32] sfc: Add efx_nic_type operation for register
	self-test
Date: Sat, 28 Nov 2009 03:50:32 +0000
Message-ID: <1259380232.2811.48.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:42693 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754033AbZK1Du2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2009 22:50:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c     |    3 ++-
 drivers/net/sfc/falcon.h     |    1 -
 drivers/net/sfc/net_driver.h |    2 ++
 drivers/net/sfc/selftest.c   |   12 ++++++------
 4 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 67ad54d..f0541d4 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -2458,7 +2458,7 @@ static bool efx_masked_compare_oword(const efx_oword_t *a, const efx_oword_t *b,
 		((a->u64[1] ^ b->u64[1]) & mask->u64[1]);
 }
 
-int falcon_test_registers(struct efx_nic *efx)
+static int falcon_b0_test_registers(struct efx_nic *efx)
 {
 	unsigned address = 0, i, j;
 	efx_oword_t mask, imask, original, reg, buf;
@@ -3328,6 +3328,7 @@ struct efx_nic_type falcon_b0_nic_type = {
 	.get_wol = falcon_get_wol,
 	.set_wol = falcon_set_wol,
 	.resume_wol = efx_port_dummy_op_void,
+	.test_registers = falcon_b0_test_registers,
 	.default_mac_ops = &falcon_xmac_operations,
 
 	.revision = EFX_REV_FALCON_B0,
diff --git a/drivers/net/sfc/falcon.h b/drivers/net/sfc/falcon.h
index 560a3f9..cfcc2a3 100644
--- a/drivers/net/sfc/falcon.h
+++ b/drivers/net/sfc/falcon.h
@@ -154,7 +154,6 @@ extern int falcon_reset_xaui(struct efx_nic *efx);
 struct falcon_nvconfig;
 extern int falcon_read_nvram(struct efx_nic *efx,
 			     struct falcon_nvconfig *nvconfig);
-extern int falcon_test_registers(struct efx_nic *efx);
 
 /**************************************************************************
  *
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index ee2b445..c465610 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -864,6 +864,7 @@ static inline const char *efx_dev_name(struct efx_nic *efx)
  * @get_wol: Get WoL configuration from driver state
  * @set_wol: Push WoL configuration to the NIC
  * @resume_wol: Synchronise WoL state between driver and MC (e.g. after resume)
+ * @test_registers: Test read/write functionality of control registers
  * @default_mac_ops: efx_mac_operations to set at startup
  * @revision: Hardware architecture revision
  * @mem_map_size: Memory BAR mapped size
@@ -904,6 +905,7 @@ struct efx_nic_type {
 	void (*get_wol)(struct efx_nic *efx, struct ethtool_wolinfo *wol);
 	int (*set_wol)(struct efx_nic *efx, u32 type);
 	void (*resume_wol)(struct efx_nic *efx);
+	int (*test_registers)(struct efx_nic *efx);
 	struct efx_mac_operations *default_mac_ops;
 
 	int revision;
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index f45bf74..f303552 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -122,14 +122,14 @@ static int efx_test_nvram(struct efx_nic *efx, struct efx_self_tests *tests)
 
 static int efx_test_chip(struct efx_nic *efx, struct efx_self_tests *tests)
 {
-	int rc;
+	int rc = 0;
 
-	/* Not supported on A-series silicon */
-	if (efx_nic_rev(efx) < EFX_REV_FALCON_B0)
-		return 0;
+	/* Test register access */
+	if (efx->type->test_registers) {
+		rc = efx->type->test_registers(efx);
+		tests->registers = rc ? -1 : 1;
+	}
 
-	rc = falcon_test_registers(efx);
-	tests->registers = rc ? -1 : 1;
 	return rc;
 }
 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

