From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 12/14] sfc: Cope with permissions enforcement added
 to firmware for SR-IOV
Date: Wed, 6 May 2015 00:59:18 +0100
Message-ID: <55495956.1040808@solarflare.com>
References: <554957DF.2010307@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:59817 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755662AbbEEX7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 19:59:24 -0400
In-Reply-To: <554957DF.2010307@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>

* Accept EPERM in some simple cases, the following cases are handled:
1) efx_mcdi_read_assertion()
Unprivileged PCI functions aren't allowed to GET_ASSERTS.
We return success as it's up to the primary PF to deal with asserts.
2) efx_mcdi_mon_probe() in efx_ef10_probe()
Unprivileged PCI functions aren't allowed to read sensor info, and
worrying about sensor data is the primary PF's job.
3) phy_op->reconfigure() in efx_init_port() and efx_reset_up()
Unprivileged functions aren't allowed to MC_CMD_SET_LINK, they just have
to accept the settings (including flow-control, which is what
efx_init_port() is worried about) they've been given.
4) Fallback to GET_WORKAROUNDS in efx_ef10_probe()
Unprivileged PCI functions aren't allowed to set workarounds. So if
efx_mcdi_set_workaround() fails EPERM, use efx_mcdi_get_workarounds()
to find out if workaround_35388 is enabled.
5) If DRV_ATTACH gets EPERM, try without specifying fw-variant
Unprivileged PCI functions have to use a FIRMWARE_ID of 0xffffffff
(MC_CMD_FW_DONT_CARE).
6) Don't try to exit_assertion unless one had fired
Previously we called efx_mcdi_exit_assertion even if
efx_mcdi_read_assertion had received MC_CMD_GET_ASSERTS_FLAGS_NO_FAILS.
This is unnecessary, and the resulting MC_CMD_REBOOT, even if the
AFTER_ASSERTION flag made it a no-op, would fail EPERM for unprivileged
PCI functions.
So make efx_mcdi_read_assertion return whether an assert happened, and only
call efx_mcdi_exit_assertion if it has.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c      | 16 ++++++-
 drivers/net/ethernet/sfc/efx.c       |  5 ++-
 drivers/net/ethernet/sfc/mcdi.c      | 82 ++++++++++++++++++++++++++++++------
 drivers/net/ethernet/sfc/mcdi.h      |  2 +
 drivers/net/ethernet/sfc/mcdi_pcol.h | 23 ++++++++++
 5 files changed, 111 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 0dff812..ae0ed2a 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -286,10 +286,22 @@ static int efx_ef10_probe(struct efx_nic *efx)
 		goto fail3;
 	efx->timer_quantum_ns = 1536000 / rc; /* 1536 cycles */
 
-	/* Check whether firmware supports bug 35388 workaround */
+	/* Check whether firmware supports bug 35388 workaround.
+	 * First try to enable it, then if we get EPERM, just
+	 * ask if it's already enabled
+	 */
 	rc = efx_mcdi_set_workaround(efx, MC_CMD_WORKAROUND_BUG35388, true);
 	if (rc == 0)
 		nic_data->workaround_35388 = true;
+	else if (rc == -EPERM) {
+		unsigned int enabled;
+
+		rc = efx_mcdi_get_workarounds(efx, NULL, &enabled);
+		if (rc)
+			goto fail3;
+		nic_data->workaround_35388 = enabled &
+			MC_CMD_GET_WORKAROUNDS_OUT_BUG35388;
+	}
 	else if (rc != -ENOSYS && rc != -ENOENT)
 		goto fail3;
 	netif_dbg(efx, probe, efx->net_dev,
@@ -297,7 +309,7 @@ static int efx_ef10_probe(struct efx_nic *efx)
 		  nic_data->workaround_35388 ? "en" : "dis");
 
 	rc = efx_mcdi_mon_probe(efx);
-	if (rc)
+	if (rc && rc != -EPERM)
 		goto fail3;
 
 	efx_ptp_probe(efx, NULL);
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 8b2edda..78f7760 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1046,7 +1046,7 @@ static int efx_init_port(struct efx_nic *efx)
 
 	/* Ensure the PHY advertises the correct flow control settings */
 	rc = efx->phy_op->reconfigure(efx);
-	if (rc)
+	if (rc && rc != -EPERM)
 		goto fail2;
 
 	mutex_unlock(&efx->mac_lock);
@@ -2429,7 +2429,8 @@ int efx_reset_up(struct efx_nic *efx, enum reset_type method, bool ok)
 		rc = efx->phy_op->init(efx);
 		if (rc)
 			goto fail;
-		if (efx->phy_op->reconfigure(efx))
+		rc = efx->phy_op->reconfigure(efx);
+		if (rc && rc != -EPERM)
 			netif_err(efx, drv, efx->net_dev,
 				  "could not restore PHY settings\n");
 	}
diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index 6e0c789..1ffe289 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -1142,10 +1142,26 @@ static int efx_mcdi_drv_attach(struct efx_nic *efx, bool driver_operating,
 	MCDI_SET_DWORD(inbuf, DRV_ATTACH_IN_UPDATE, 1);
 	MCDI_SET_DWORD(inbuf, DRV_ATTACH_IN_FIRMWARE_ID, MC_CMD_FW_LOW_LATENCY);
 
-	rc = efx_mcdi_rpc(efx, MC_CMD_DRV_ATTACH, inbuf, sizeof(inbuf),
-			  outbuf, sizeof(outbuf), &outlen);
-	if (rc)
+	rc = efx_mcdi_rpc_quiet(efx, MC_CMD_DRV_ATTACH, inbuf, sizeof(inbuf),
+				outbuf, sizeof(outbuf), &outlen);
+	/* If we're not the primary PF, trying to ATTACH with a FIRMWARE_ID
+	 * specified will fail with EPERM, and we have to tell the MC we don't
+	 * care what firmware we get.
+	 */
+	if (rc == -EPERM) {
+		netif_dbg(efx, probe, efx->net_dev,
+			  "efx_mcdi_drv_attach with fw-variant setting failed EPERM, trying without it\n");
+		MCDI_SET_DWORD(inbuf, DRV_ATTACH_IN_FIRMWARE_ID,
+			       MC_CMD_FW_DONT_CARE);
+		rc = efx_mcdi_rpc_quiet(efx, MC_CMD_DRV_ATTACH, inbuf,
+					sizeof(inbuf), outbuf, sizeof(outbuf),
+					&outlen);
+	}
+	if (rc) {
+		efx_mcdi_display_error(efx, MC_CMD_DRV_ATTACH, sizeof(inbuf),
+				       outbuf, outlen, rc);
 		goto fail;
+	}
 	if (outlen < MC_CMD_DRV_ATTACH_OUT_LEN) {
 		rc = -EIO;
 		goto fail;
@@ -1377,6 +1393,9 @@ fail1:
 	return rc;
 }
 
+/* Returns 1 if an assertion was read, 0 if no assertion had fired,
+ * negative on error.
+ */
 static int efx_mcdi_read_assertion(struct efx_nic *efx)
 {
 	MCDI_DECLARE_BUF(inbuf, MC_CMD_GET_ASSERTS_IN_LEN);
@@ -1398,6 +1417,8 @@ static int efx_mcdi_read_assertion(struct efx_nic *efx)
 		rc = efx_mcdi_rpc_quiet(efx, MC_CMD_GET_ASSERTS,
 					inbuf, MC_CMD_GET_ASSERTS_IN_LEN,
 					outbuf, sizeof(outbuf), &outlen);
+		if (rc == -EPERM)
+			return 0;
 	} while ((rc == -EINTR || rc == -EIO) && retry-- > 0);
 
 	if (rc) {
@@ -1435,24 +1456,31 @@ static int efx_mcdi_read_assertion(struct efx_nic *efx)
 			  MCDI_ARRAY_DWORD(outbuf, GET_ASSERTS_OUT_GP_REGS_OFFS,
 					   index));
 
-	return 0;
+	return 1;
 }
 
-static void efx_mcdi_exit_assertion(struct efx_nic *efx)
+static int efx_mcdi_exit_assertion(struct efx_nic *efx)
 {
 	MCDI_DECLARE_BUF(inbuf, MC_CMD_REBOOT_IN_LEN);
+	int rc;
 
 	/* If the MC is running debug firmware, it might now be
 	 * waiting for a debugger to attach, but we just want it to
 	 * reboot.  We set a flag that makes the command a no-op if it
-	 * has already done so.  We don't know what return code to
-	 * expect (0 or -EIO), so ignore it.
+	 * has already done so.
+	 * The MCDI will thus return either 0 or -EIO.
 	 */
 	BUILD_BUG_ON(MC_CMD_REBOOT_OUT_LEN != 0);
 	MCDI_SET_DWORD(inbuf, REBOOT_IN_FLAGS,
 		       MC_CMD_REBOOT_FLAGS_AFTER_ASSERTION);
-	(void) efx_mcdi_rpc(efx, MC_CMD_REBOOT, inbuf, MC_CMD_REBOOT_IN_LEN,
-			    NULL, 0, NULL);
+	rc = efx_mcdi_rpc_quiet(efx, MC_CMD_REBOOT, inbuf, MC_CMD_REBOOT_IN_LEN,
+				NULL, 0, NULL);
+	if (rc == -EIO)
+		rc = 0;
+	if (rc)
+		efx_mcdi_display_error(efx, MC_CMD_REBOOT, MC_CMD_REBOOT_IN_LEN,
+				       NULL, 0, rc);
+	return rc;
 }
 
 int efx_mcdi_handle_assertion(struct efx_nic *efx)
@@ -1460,12 +1488,10 @@ int efx_mcdi_handle_assertion(struct efx_nic *efx)
 	int rc;
 
 	rc = efx_mcdi_read_assertion(efx);
-	if (rc)
+	if (rc <= 0)
 		return rc;
 
-	efx_mcdi_exit_assertion(efx);
-
-	return 0;
+	return efx_mcdi_exit_assertion(efx);
 }
 
 void efx_mcdi_set_id_led(struct efx_nic *efx, enum efx_led_mode mode)
@@ -1680,6 +1706,36 @@ int efx_mcdi_set_workaround(struct efx_nic *efx, u32 type, bool enabled)
 			    NULL, 0, NULL);
 }
 
+int efx_mcdi_get_workarounds(struct efx_nic *efx, unsigned int *impl_out,
+			     unsigned int *enabled_out)
+{
+	MCDI_DECLARE_BUF_OUT_OR_ERR(outbuf, MC_CMD_GET_WORKAROUNDS_OUT_LEN);
+	size_t outlen;
+	int rc;
+
+	rc = efx_mcdi_rpc(efx, MC_CMD_GET_WORKAROUNDS, NULL, 0,
+			  outbuf, sizeof(outbuf), &outlen);
+	if (rc)
+		goto fail;
+
+	if (outlen < MC_CMD_GET_WORKAROUNDS_OUT_LEN) {
+		rc = -EIO;
+		goto fail;
+	}
+
+	if (impl_out)
+		*impl_out = MCDI_DWORD(outbuf, GET_WORKAROUNDS_OUT_IMPLEMENTED);
+
+	if (enabled_out)
+		*enabled_out = MCDI_DWORD(outbuf, GET_WORKAROUNDS_OUT_ENABLED);
+
+	return 0;
+
+fail:
+	netif_err(efx, hw, efx->net_dev, "%s: failed rc=%d\n", __func__, rc);
+	return rc;
+}
+
 #ifdef CONFIG_SFC_MTD
 
 #define EFX_MCDI_NVRAM_LEN_MAX 128
diff --git a/drivers/net/ethernet/sfc/mcdi.h b/drivers/net/ethernet/sfc/mcdi.h
index 56465f7..5df1e98 100644
--- a/drivers/net/ethernet/sfc/mcdi.h
+++ b/drivers/net/ethernet/sfc/mcdi.h
@@ -339,6 +339,8 @@ bool efx_mcdi_mac_check_fault(struct efx_nic *efx);
 enum reset_type efx_mcdi_map_reset_reason(enum reset_type reason);
 int efx_mcdi_reset(struct efx_nic *efx, enum reset_type method);
 int efx_mcdi_set_workaround(struct efx_nic *efx, u32 type, bool enabled);
+int efx_mcdi_get_workarounds(struct efx_nic *efx, unsigned int *impl_out,
+			     unsigned int *enabled_out);
 
 #ifdef CONFIG_SFC_MCDI_MON
 int efx_mcdi_mon_probe(struct efx_nic *efx);
diff --git a/drivers/net/ethernet/sfc/mcdi_pcol.h b/drivers/net/ethernet/sfc/mcdi_pcol.h
index e028de1..4fa6eb2 100644
--- a/drivers/net/ethernet/sfc/mcdi_pcol.h
+++ b/drivers/net/ethernet/sfc/mcdi_pcol.h
@@ -1875,6 +1875,8 @@
 #define          MC_CMD_FW_FULL_FEATURED 0x0
 /* enum: Prefer to use firmware with fewer features but lower latency */
 #define          MC_CMD_FW_LOW_LATENCY 0x1
+/* enum: Only this option is allowed for non-admin functions */
+#define          MC_CMD_FW_DONT_CARE  0xffffffff
 
 /* MC_CMD_DRV_ATTACH_OUT msgresponse */
 #define    MC_CMD_DRV_ATTACH_OUT_LEN 4
@@ -4087,6 +4089,27 @@
 
 
 /***********************************/
+/* MC_CMD_GET_WORKAROUNDS
+ * Read the list of all implemented and all currently enabled workarounds. The
+ * enums here must correspond with those in MC_CMD_WORKAROUND.
+ */
+#define MC_CMD_GET_WORKAROUNDS 0x59
+
+/* MC_CMD_GET_WORKAROUNDS_OUT msgresponse */
+#define    MC_CMD_GET_WORKAROUNDS_OUT_LEN 8
+/* Each workaround is represented by a single bit according to the enums below.
+ */
+#define       MC_CMD_GET_WORKAROUNDS_OUT_IMPLEMENTED_OFST 0
+#define       MC_CMD_GET_WORKAROUNDS_OUT_ENABLED_OFST 4
+/* enum: Bug 17230 work around. */
+#define          MC_CMD_GET_WORKAROUNDS_OUT_BUG17230 0x2
+/* enum: Bug 35388 work around (unsafe EVQ writes). */
+#define          MC_CMD_GET_WORKAROUNDS_OUT_BUG35388 0x4
+/* enum: Bug35017 workaround (A64 tables must be identity map) */
+#define          MC_CMD_GET_WORKAROUNDS_OUT_BUG35017 0x8
+
+
+/***********************************/
 /* MC_CMD_READ_REGS
  * Get a dump of the MCPU registers
  */
