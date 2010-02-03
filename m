From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 02/10] sfc: Handle firmware assertion failure while
 resetting
Date: Wed, 03 Feb 2010 19:30:17 +0000
Message-ID: <1265225417.2116.2.camel@achroite.uk.solarflarecom.com>
References: <1265225294.2116.1.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:27917 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757095Ab0BCTaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 14:30:21 -0500
In-Reply-To: <1265225294.2116.1.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Hodgson <shodgson@solarflare.com>

This allows the driver to recover if the MC firmware has crashed due
to an assertion failure.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/mcdi.c  |   63 ++++++++++++++++++++++++++++------------------
 drivers/net/sfc/siena.c |    6 ++++
 2 files changed, 44 insertions(+), 25 deletions(-)

diff --git a/drivers/net/sfc/mcdi.c b/drivers/net/sfc/mcdi.c
index 9f035b9..e9f0e5e 100644
--- a/drivers/net/sfc/mcdi.c
+++ b/drivers/net/sfc/mcdi.c
@@ -896,29 +896,27 @@ fail:
 	return rc;
 }
 
-int efx_mcdi_handle_assertion(struct efx_nic *efx)
+static int efx_mcdi_read_assertion(struct efx_nic *efx)
 {
-	union {
-		u8 asserts[MC_CMD_GET_ASSERTS_IN_LEN];
-		u8 reboot[MC_CMD_REBOOT_IN_LEN];
-	} inbuf;
-	u8 assertion[MC_CMD_GET_ASSERTS_OUT_LEN];
+	u8 inbuf[MC_CMD_GET_ASSERTS_IN_LEN];
+	u8 outbuf[MC_CMD_GET_ASSERTS_OUT_LEN];
 	unsigned int flags, index, ofst;
 	const char *reason;
 	size_t outlen;
 	int retry;
 	int rc;
 
-	/* Check if the MC is in the assertion handler, retrying twice. Once
+	/* Attempt to read any stored assertion state before we reboot
+	 * the mcfw out of the assertion handler. Retry twice, once
 	 * because a boot-time assertion might cause this command to fail
 	 * with EINTR. And once again because GET_ASSERTS can race with
 	 * MC_CMD_REBOOT running on the other port. */
 	retry = 2;
 	do {
-		MCDI_SET_DWORD(inbuf.asserts, GET_ASSERTS_IN_CLEAR, 0);
+		MCDI_SET_DWORD(inbuf, GET_ASSERTS_IN_CLEAR, 1);
 		rc = efx_mcdi_rpc(efx, MC_CMD_GET_ASSERTS,
-				  inbuf.asserts, MC_CMD_GET_ASSERTS_IN_LEN,
-				  assertion, sizeof(assertion), &outlen);
+				  inbuf, MC_CMD_GET_ASSERTS_IN_LEN,
+				  outbuf, sizeof(outbuf), &outlen);
 	} while ((rc == -EINTR || rc == -EIO) && retry-- > 0);
 
 	if (rc)
@@ -926,21 +924,11 @@ int efx_mcdi_handle_assertion(struct efx_nic *efx)
 	if (outlen < MC_CMD_GET_ASSERTS_OUT_LEN)
 		return -EINVAL;
 
-	flags = MCDI_DWORD(assertion, GET_ASSERTS_OUT_GLOBAL_FLAGS);
+	/* Print out any recorded assertion state */
+	flags = MCDI_DWORD(outbuf, GET_ASSERTS_OUT_GLOBAL_FLAGS);
 	if (flags == MC_CMD_GET_ASSERTS_FLAGS_NO_FAILS)
 		return 0;
 
-	/* Reset the hardware atomically such that only one port with succeed.
-	 * This command will succeed if a reboot is no longer required (because
-	 * the other port did it first), but fail with EIO if it succeeds.
-	 */
-	BUILD_BUG_ON(MC_CMD_REBOOT_OUT_LEN != 0);
-	MCDI_SET_DWORD(inbuf.reboot, REBOOT_IN_FLAGS,
-		       MC_CMD_REBOOT_FLAGS_AFTER_ASSERTION);
-	efx_mcdi_rpc(efx, MC_CMD_REBOOT, inbuf.reboot, MC_CMD_REBOOT_IN_LEN,
-		     NULL, 0, NULL);
-
-	/* Print out the assertion */
 	reason = (flags == MC_CMD_GET_ASSERTS_FLAGS_SYS_FAIL)
 		? "system-level assertion"
 		: (flags == MC_CMD_GET_ASSERTS_FLAGS_THR_FAIL)
@@ -949,20 +937,45 @@ int efx_mcdi_handle_assertion(struct efx_nic *efx)
 		? "watchdog reset"
 		: "unknown assertion";
 	EFX_ERR(efx, "MCPU %s at PC = 0x%.8x in thread 0x%.8x\n", reason,
-		MCDI_DWORD(assertion, GET_ASSERTS_OUT_SAVED_PC_OFFS),
-		MCDI_DWORD(assertion, GET_ASSERTS_OUT_THREAD_OFFS));
+		MCDI_DWORD(outbuf, GET_ASSERTS_OUT_SAVED_PC_OFFS),
+		MCDI_DWORD(outbuf, GET_ASSERTS_OUT_THREAD_OFFS));
 
 	/* Print out the registers */
 	ofst = MC_CMD_GET_ASSERTS_OUT_GP_REGS_OFFS_OFST;
 	for (index = 1; index < 32; index++) {
 		EFX_ERR(efx, "R%.2d (?): 0x%.8x\n", index,
-			MCDI_DWORD2(assertion, ofst));
+			MCDI_DWORD2(outbuf, ofst));
 		ofst += sizeof(efx_dword_t);
 	}
 
 	return 0;
 }
 
+static void efx_mcdi_exit_assertion(struct efx_nic *efx)
+{
+	u8 inbuf[MC_CMD_REBOOT_IN_LEN];
+
+	/* Atomically reboot the mcfw out of the assertion handler */
+	BUILD_BUG_ON(MC_CMD_REBOOT_OUT_LEN != 0);
+	MCDI_SET_DWORD(inbuf, REBOOT_IN_FLAGS,
+		       MC_CMD_REBOOT_FLAGS_AFTER_ASSERTION);
+	efx_mcdi_rpc(efx, MC_CMD_REBOOT, inbuf, MC_CMD_REBOOT_IN_LEN,
+		     NULL, 0, NULL);
+}
+
+int efx_mcdi_handle_assertion(struct efx_nic *efx)
+{
+	int rc;
+
+	rc = efx_mcdi_read_assertion(efx);
+	if (rc)
+		return rc;
+
+	efx_mcdi_exit_assertion(efx);
+
+	return 0;
+}
+
 void efx_mcdi_set_id_led(struct efx_nic *efx, enum efx_led_mode mode)
 {
 	u8 inbuf[MC_CMD_SET_ID_LED_IN_LEN];
diff --git a/drivers/net/sfc/siena.c b/drivers/net/sfc/siena.c
index f8c6771..0e4c13a 100644
--- a/drivers/net/sfc/siena.c
+++ b/drivers/net/sfc/siena.c
@@ -181,6 +181,12 @@ static int siena_test_registers(struct efx_nic *efx)
 
 static int siena_reset_hw(struct efx_nic *efx, enum reset_type method)
 {
+	int rc;
+
+	/* Recover from a failed assertion pre-reset */
+	rc = efx_mcdi_handle_assertion(efx);
+	if (rc)
+		return rc;
 
 	if (method == RESET_TYPE_WORLD)
 		return efx_mcdi_reset_mc(efx);
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

