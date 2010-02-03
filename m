From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 05/10] sfc: Implement NVRAM selftest for SFC9000 family
Date: Wed, 03 Feb 2010 19:31:01 +0000
Message-ID: <1265225461.2116.5.camel@achroite.uk.solarflarecom.com>
References: <1265225294.2116.1.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:28044 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932160Ab0BCTbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 14:31:04 -0500
In-Reply-To: <1265225294.2116.1.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/mcdi.c  |   46 ++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/sfc/mcdi.h  |    1 +
 drivers/net/sfc/siena.c |    1 +
 3 files changed, 48 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sfc/mcdi.c b/drivers/net/sfc/mcdi.c
index e9f0e5e..86610db 100644
--- a/drivers/net/sfc/mcdi.c
+++ b/drivers/net/sfc/mcdi.c
@@ -896,6 +896,52 @@ fail:
 	return rc;
 }
 
+static int efx_mcdi_nvram_test(struct efx_nic *efx, unsigned int type)
+{
+	u8 inbuf[MC_CMD_NVRAM_TEST_IN_LEN];
+	u8 outbuf[MC_CMD_NVRAM_TEST_OUT_LEN];
+	int rc;
+
+	MCDI_SET_DWORD(inbuf, NVRAM_TEST_IN_TYPE, type);
+
+	rc = efx_mcdi_rpc(efx, MC_CMD_NVRAM_TEST, inbuf, sizeof(inbuf),
+			  outbuf, sizeof(outbuf), NULL);
+	if (rc)
+		return rc;
+
+	switch (MCDI_DWORD(outbuf, NVRAM_TEST_OUT_RESULT)) {
+	case MC_CMD_NVRAM_TEST_PASS:
+	case MC_CMD_NVRAM_TEST_NOTSUPP:
+		return 0;
+	default:
+		return -EIO;
+	}
+}
+
+int efx_mcdi_nvram_test_all(struct efx_nic *efx)
+{
+	u32 nvram_types;
+	unsigned int type;
+	int rc;
+
+	rc = efx_mcdi_nvram_types(efx, &nvram_types);
+	if (rc)
+		return rc;
+
+	type = 0;
+	while (nvram_types != 0) {
+		if (nvram_types & 1) {
+			rc = efx_mcdi_nvram_test(efx, type);
+			if (rc)
+				return rc;
+		}
+		type++;
+		nvram_types >>= 1;
+	}
+
+	return 0;
+}
+
 static int efx_mcdi_read_assertion(struct efx_nic *efx)
 {
 	u8 inbuf[MC_CMD_GET_ASSERTS_IN_LEN];
diff --git a/drivers/net/sfc/mcdi.h b/drivers/net/sfc/mcdi.h
index 10ce98f..f1f89ad 100644
--- a/drivers/net/sfc/mcdi.h
+++ b/drivers/net/sfc/mcdi.h
@@ -116,6 +116,7 @@ extern int efx_mcdi_nvram_erase(struct efx_nic *efx, unsigned int type,
 				loff_t offset, size_t length);
 extern int efx_mcdi_nvram_update_finish(struct efx_nic *efx,
 					unsigned int type);
+extern int efx_mcdi_nvram_test_all(struct efx_nic *efx);
 extern int efx_mcdi_handle_assertion(struct efx_nic *efx);
 extern void efx_mcdi_set_id_led(struct efx_nic *efx, enum efx_led_mode mode);
 extern int efx_mcdi_reset_port(struct efx_nic *efx);
diff --git a/drivers/net/sfc/siena.c b/drivers/net/sfc/siena.c
index f6a5389..8e13112 100644
--- a/drivers/net/sfc/siena.c
+++ b/drivers/net/sfc/siena.c
@@ -583,6 +583,7 @@ struct efx_nic_type siena_a0_nic_type = {
 	.set_wol = siena_set_wol,
 	.resume_wol = siena_init_wol,
 	.test_registers = siena_test_registers,
+	.test_nvram = efx_mcdi_nvram_test_all,
 	.default_mac_ops = &efx_mcdi_mac_operations,
 
 	.revision = EFX_REV_SIENA_A0,
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

