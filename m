From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 22/32] sfc: Add efx_nic_type operation for NVRAM self-test
Date: Sat, 28 Nov 2009 03:50:42 +0000
Message-ID: <1259380242.2811.50.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:42704 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754044AbZK1Dui (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2009 22:50:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c     |   10 +++++++++-
 drivers/net/sfc/falcon.h     |    3 ---
 drivers/net/sfc/net_driver.h |    2 ++
 drivers/net/sfc/selftest.c   |    9 ++++++---
 4 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index f0541d4..c689206 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -2345,7 +2345,8 @@ static void falcon_remove_port(struct efx_nic *efx)
  *
  **************************************************************************/
 
-int falcon_read_nvram(struct efx_nic *efx, struct falcon_nvconfig *nvconfig_out)
+static int
+falcon_read_nvram(struct efx_nic *efx, struct falcon_nvconfig *nvconfig_out)
 {
 	struct falcon_nvconfig *nvconfig;
 	struct efx_spi_device *spi;
@@ -2408,6 +2409,11 @@ int falcon_read_nvram(struct efx_nic *efx, struct falcon_nvconfig *nvconfig_out)
 	return rc;
 }
 
+static int falcon_test_nvram(struct efx_nic *efx)
+{
+	return falcon_read_nvram(efx, NULL);
+}
+
 /* Registers tested in the falcon register test */
 static struct {
 	unsigned address;
@@ -3290,6 +3296,7 @@ struct efx_nic_type falcon_a1_nic_type = {
 	.get_wol = falcon_get_wol,
 	.set_wol = falcon_set_wol,
 	.resume_wol = efx_port_dummy_op_void,
+	.test_nvram = falcon_test_nvram,
 	.default_mac_ops = &falcon_xmac_operations,
 
 	.revision = EFX_REV_FALCON_A1,
@@ -3329,6 +3336,7 @@ struct efx_nic_type falcon_b0_nic_type = {
 	.set_wol = falcon_set_wol,
 	.resume_wol = efx_port_dummy_op_void,
 	.test_registers = falcon_b0_test_registers,
+	.test_nvram = falcon_test_nvram,
 	.default_mac_ops = &falcon_xmac_operations,
 
 	.revision = EFX_REV_FALCON_B0,
diff --git a/drivers/net/sfc/falcon.h b/drivers/net/sfc/falcon.h
index cfcc2a3..464c274 100644
--- a/drivers/net/sfc/falcon.h
+++ b/drivers/net/sfc/falcon.h
@@ -151,9 +151,6 @@ extern void falcon_stop_nic_stats(struct efx_nic *efx);
 extern int falcon_reset_xaui(struct efx_nic *efx);
 
 /* Tests */
-struct falcon_nvconfig;
-extern int falcon_read_nvram(struct efx_nic *efx,
-			     struct falcon_nvconfig *nvconfig);
 
 /**************************************************************************
  *
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index c465610..e75235b 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -865,6 +865,7 @@ static inline const char *efx_dev_name(struct efx_nic *efx)
  * @set_wol: Push WoL configuration to the NIC
  * @resume_wol: Synchronise WoL state between driver and MC (e.g. after resume)
  * @test_registers: Test read/write functionality of control registers
+ * @test_nvram: Test validity of NVRAM contents
  * @default_mac_ops: efx_mac_operations to set at startup
  * @revision: Hardware architecture revision
  * @mem_map_size: Memory BAR mapped size
@@ -906,6 +907,7 @@ struct efx_nic_type {
 	int (*set_wol)(struct efx_nic *efx, u32 type);
 	void (*resume_wol)(struct efx_nic *efx);
 	int (*test_registers)(struct efx_nic *efx);
+	int (*test_nvram)(struct efx_nic *efx);
 	struct efx_mac_operations *default_mac_ops;
 
 	int revision;
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index f303552..fa56e2e 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -113,10 +113,13 @@ out:
 
 static int efx_test_nvram(struct efx_nic *efx, struct efx_self_tests *tests)
 {
-	int rc;
+	int rc = 0;
+
+	if (efx->type->test_nvram) {
+		rc = efx->type->test_nvram(efx);
+		tests->nvram = rc ? -1 : 1;
+	}
 
-	rc = falcon_read_nvram(efx, NULL);
-	tests->nvram = rc ? -1 : 1;
 	return rc;
 }
 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

