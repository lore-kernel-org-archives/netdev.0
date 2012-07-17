From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 08/10] sfc: Disable VF queues during register
 self-test
Date: Tue, 17 Jul 2012 19:07:27 +0100
Message-ID: <1342548447.2698.26.camel@bwh-desktop.uk.solarflarecom.com>
References: <1342544740.2698.13.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:49451 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756024Ab2GQSHb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 14:07:31 -0400
In-Reply-To: <1342544740.2698.13.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently VF queues and drivers may remain active during this test.
This could cause memory corruption or spurious test failures.
Therefore we reset the port/function before running these tests on
Siena.

On Falcon this doesn't work: we have to do some additional
initialisation before some blocks will work again.  So refactor the
reset/register-test sequence into an efx_nic_type method so
efx_selftest() doesn't have to consider such quirks.

In the process, fix another minor bug: Siena does not have an
'invisible' reset and the self-test currently fails to push the PHY
configuration after resetting.  Passing RESET_TYPE_ALL to
efx_reset_{down,up}() fixes this.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/falcon.c     |   35 ++++++++++++++++--
 drivers/net/ethernet/sfc/net_driver.h |    7 +++-
 drivers/net/ethernet/sfc/nic.c        |    3 --
 drivers/net/ethernet/sfc/selftest.c   |   62 ++++++++-------------------------
 drivers/net/ethernet/sfc/siena.c      |   29 +++++++++++++--
 5 files changed, 76 insertions(+), 60 deletions(-)

diff --git a/drivers/net/ethernet/sfc/falcon.c b/drivers/net/ethernet/sfc/falcon.c
index 3a1ca2b..12b573a 100644
--- a/drivers/net/ethernet/sfc/falcon.c
+++ b/drivers/net/ethernet/sfc/falcon.c
@@ -25,9 +25,12 @@
 #include "io.h"
 #include "phy.h"
 #include "workarounds.h"
+#include "selftest.h"
 
 /* Hardware control for SFC4000 (aka Falcon). */
 
+static int falcon_reset_hw(struct efx_nic *efx, enum reset_type method);
+
 static const unsigned int
 /* "Large" EEPROM device: Atmel AT25640 or similar
  * 8 KB, 16-bit address, 32 B write block */
@@ -1034,10 +1037,34 @@ static const struct efx_nic_register_test falcon_b0_register_tests[] = {
 	  EFX_OWORD32(0x0003FF0F, 0x00000000, 0x00000000, 0x00000000) },
 };
 
-static int falcon_b0_test_registers(struct efx_nic *efx)
+static int
+falcon_b0_test_chip(struct efx_nic *efx, struct efx_self_tests *tests)
 {
-	return efx_nic_test_registers(efx, falcon_b0_register_tests,
-				      ARRAY_SIZE(falcon_b0_register_tests));
+	enum reset_type reset_method = RESET_TYPE_INVISIBLE;
+	int rc, rc2;
+
+	mutex_lock(&efx->mac_lock);
+	if (efx->loopback_modes) {
+		/* We need the 312 clock from the PHY to test the XMAC
+		 * registers, so move into XGMII loopback if available */
+		if (efx->loopback_modes & (1 << LOOPBACK_XGMII))
+			efx->loopback_mode = LOOPBACK_XGMII;
+		else
+			efx->loopback_mode = __ffs(efx->loopback_modes);
+	}
+	__efx_reconfigure_port(efx);
+	mutex_unlock(&efx->mac_lock);
+
+	efx_reset_down(efx, reset_method);
+
+	tests->registers =
+		efx_nic_test_registers(efx, falcon_b0_register_tests,
+				       ARRAY_SIZE(falcon_b0_register_tests))
+		? -1 : 1;
+
+	rc = falcon_reset_hw(efx, reset_method);
+	rc2 = efx_reset_up(efx, reset_method, rc == 0);
+	return rc ? rc : rc2;
 }
 
 /**************************************************************************
@@ -1818,7 +1845,7 @@ const struct efx_nic_type falcon_b0_nic_type = {
 	.get_wol = falcon_get_wol,
 	.set_wol = falcon_set_wol,
 	.resume_wol = efx_port_dummy_op_void,
-	.test_registers = falcon_b0_test_registers,
+	.test_chip = falcon_b0_test_chip,
 	.test_nvram = falcon_test_nvram,
 
 	.revision = EFX_REV_FALCON_B0,
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 8a9f6d4..55be2fd 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -68,6 +68,8 @@
 #define EFX_TXQ_TYPES		4
 #define EFX_MAX_TX_QUEUES	(EFX_TXQ_TYPES * EFX_MAX_CHANNELS)
 
+struct efx_self_tests;
+
 /**
  * struct efx_special_buffer - An Efx special buffer
  * @addr: CPU base address of the buffer
@@ -901,7 +903,8 @@ static inline unsigned int efx_port_num(struct efx_nic *efx)
  * @get_wol: Get WoL configuration from driver state
  * @set_wol: Push WoL configuration to the NIC
  * @resume_wol: Synchronise WoL state between driver and MC (e.g. after resume)
- * @test_registers: Test read/write functionality of control registers
+ * @test_chip: Test registers.  Should use efx_nic_test_registers(), and is
+ *	expected to reset the NIC.
  * @test_nvram: Test validity of NVRAM contents
  * @revision: Hardware architecture revision
  * @mem_map_size: Memory BAR mapped size
@@ -946,7 +949,7 @@ struct efx_nic_type {
 	void (*get_wol)(struct efx_nic *efx, struct ethtool_wolinfo *wol);
 	int (*set_wol)(struct efx_nic *efx, u32 type);
 	void (*resume_wol)(struct efx_nic *efx);
-	int (*test_registers)(struct efx_nic *efx);
+	int (*test_chip)(struct efx_nic *efx, struct efx_self_tests *tests);
 	int (*test_nvram)(struct efx_nic *efx);
 
 	int revision;
diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index 287738d..326d799 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -124,9 +124,6 @@ int efx_nic_test_registers(struct efx_nic *efx,
 	unsigned address = 0, i, j;
 	efx_oword_t mask, imask, original, reg, buf;
 
-	/* Falcon should be in loopback to isolate the XMAC from the PHY */
-	WARN_ON(!LOOPBACK_INTERNAL(efx));
-
 	for (i = 0; i < n_regs; ++i) {
 		address = regs[i].address;
 		mask = imask = regs[i].mask;
diff --git a/drivers/net/ethernet/sfc/selftest.c b/drivers/net/ethernet/sfc/selftest.c
index ccc428f..96068d1 100644
--- a/drivers/net/ethernet/sfc/selftest.c
+++ b/drivers/net/ethernet/sfc/selftest.c
@@ -120,19 +120,6 @@ static int efx_test_nvram(struct efx_nic *efx, struct efx_self_tests *tests)
 	return rc;
 }
 
-static int efx_test_chip(struct efx_nic *efx, struct efx_self_tests *tests)
-{
-	int rc = 0;
-
-	/* Test register access */
-	if (efx->type->test_registers) {
-		rc = efx->type->test_registers(efx);
-		tests->registers = rc ? -1 : 1;
-	}
-
-	return rc;
-}
-
 /**************************************************************************
  *
  * Interrupt and event queue testing
@@ -699,8 +686,7 @@ int efx_selftest(struct efx_nic *efx, struct efx_self_tests *tests,
 {
 	enum efx_loopback_mode loopback_mode = efx->loopback_mode;
 	int phy_mode = efx->phy_mode;
-	enum reset_type reset_method = RESET_TYPE_INVISIBLE;
-	int rc_test = 0, rc_reset = 0, rc;
+	int rc_test = 0, rc_reset, rc;
 
 	efx_selftest_async_cancel(efx);
 
@@ -737,44 +723,26 @@ int efx_selftest(struct efx_nic *efx, struct efx_self_tests *tests,
 	 */
 	netif_device_detach(efx->net_dev);
 
-	mutex_lock(&efx->mac_lock);
-	if (efx->loopback_modes) {
-		/* We need the 312 clock from the PHY to test the XMAC
-		 * registers, so move into XGMII loopback if available */
-		if (efx->loopback_modes & (1 << LOOPBACK_XGMII))
-			efx->loopback_mode = LOOPBACK_XGMII;
-		else
-			efx->loopback_mode = __ffs(efx->loopback_modes);
-	}
-
-	__efx_reconfigure_port(efx);
-	mutex_unlock(&efx->mac_lock);
-
-	/* free up all consumers of SRAM (including all the queues) */
-	efx_reset_down(efx, reset_method);
-
-	rc = efx_test_chip(efx, tests);
-	if (rc && !rc_test)
-		rc_test = rc;
+	if (efx->type->test_chip) {
+		rc_reset = efx->type->test_chip(efx, tests);
+		if (rc_reset) {
+			netif_err(efx, hw, efx->net_dev,
+				  "Unable to recover from chip test\n");
+			efx_schedule_reset(efx, RESET_TYPE_DISABLE);
+			return rc_reset;
+		}
 
-	/* reset the chip to recover from the register test */
-	rc_reset = efx->type->reset(efx, reset_method);
+		if ((tests->registers < 0) && !rc_test)
+			rc_test = -EIO;
+	}
 
 	/* Ensure that the phy is powered and out of loopback
 	 * for the bist and loopback tests */
+	mutex_lock(&efx->mac_lock);
 	efx->phy_mode &= ~PHY_MODE_LOW_POWER;
 	efx->loopback_mode = LOOPBACK_NONE;
-
-	rc = efx_reset_up(efx, reset_method, rc_reset == 0);
-	if (rc && !rc_reset)
-		rc_reset = rc;
-
-	if (rc_reset) {
-		netif_err(efx, drv, efx->net_dev,
-			  "Unable to recover from chip test\n");
-		efx_schedule_reset(efx, RESET_TYPE_DISABLE);
-		return rc_reset;
-	}
+	__efx_reconfigure_port(efx);
+	mutex_unlock(&efx->mac_lock);
 
 	rc = efx_test_phy(efx, tests, flags);
 	if (rc && !rc_test)
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index 9f8d7ce..2354886 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -25,10 +25,12 @@
 #include "workarounds.h"
 #include "mcdi.h"
 #include "mcdi_pcol.h"
+#include "selftest.h"
 
 /* Hardware control for SFC9000 family including SFL9021 (aka Siena). */
 
 static void siena_init_wol(struct efx_nic *efx);
+static int siena_reset_hw(struct efx_nic *efx, enum reset_type method);
 

 static void siena_push_irq_moderation(struct efx_channel *channel)
@@ -154,10 +156,29 @@ static const struct efx_nic_register_test siena_register_tests[] = {
 	  EFX_OWORD32(0xFFFFFFFF, 0xFFFFFFFF, 0x00000007, 0x00000000) },
 };
 
-static int siena_test_registers(struct efx_nic *efx)
+static int siena_test_chip(struct efx_nic *efx, struct efx_self_tests *tests)
 {
-	return efx_nic_test_registers(efx, siena_register_tests,
-				      ARRAY_SIZE(siena_register_tests));
+	enum reset_type reset_method = reset_method;
+	int rc, rc2;
+
+	efx_reset_down(efx, reset_method);
+
+	/* Reset the chip immediately so that it is completely
+	 * quiescent regardless of what any VF driver does.
+	 */
+	rc = siena_reset_hw(efx, reset_method);
+	if (rc)
+		goto out;
+
+	tests->registers =
+		efx_nic_test_registers(efx, siena_register_tests,
+				       ARRAY_SIZE(siena_register_tests))
+		? -1 : 1;
+
+	rc = siena_reset_hw(efx, reset_method);
+out:
+	rc2 = efx_reset_up(efx, reset_method, rc == 0);
+	return rc ? rc : rc2;
 }
 
 /**************************************************************************
@@ -649,7 +670,7 @@ const struct efx_nic_type siena_a0_nic_type = {
 	.get_wol = siena_get_wol,
 	.set_wol = siena_set_wol,
 	.resume_wol = siena_init_wol,
-	.test_registers = siena_test_registers,
+	.test_chip = siena_test_chip,
 	.test_nvram = efx_mcdi_nvram_test_all,
 
 	.revision = EFX_REV_SIENA_A0,
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
