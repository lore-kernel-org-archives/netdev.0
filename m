From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net 6/6] sfc: Only bind to EF10 functions with the LinkCtrl
 and Trusted flags
Date: Tue, 8 Oct 2013 18:45:21 +0100
Message-ID: <1381254321.1530.16.camel@bwh-desktop.uk.level5networks.com>
References: <1381254091.1530.9.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56483 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755639Ab3JHRpY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 13:45:24 -0400
In-Reply-To: <1381254091.1530.9.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Although we do not yet enable multiple PFs per port, it is possible
that a board will be reconfigured to enable them while the driver has
not yet been updated to fully support this.

The most obvious problem is that multiple functions may try to set
conflicting link settings.  But we will also run into trouble if the
firmware doesn't consider us fully trusted.  So, abort probing unless
both the LinkCtrl and Trusted flags are set for this function.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.c | 18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index c082562..366c8e3 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -963,7 +963,7 @@ static int efx_mcdi_drv_attach(struct efx_nic *efx, bool driver_operating,
 			       bool *was_attached)
 {
 	MCDI_DECLARE_BUF(inbuf, MC_CMD_DRV_ATTACH_IN_LEN);
-	MCDI_DECLARE_BUF(outbuf, MC_CMD_DRV_ATTACH_OUT_LEN);
+	MCDI_DECLARE_BUF(outbuf, MC_CMD_DRV_ATTACH_EXT_OUT_LEN);
 	size_t outlen;
 	int rc;
 
@@ -981,6 +981,22 @@ static int efx_mcdi_drv_attach(struct efx_nic *efx, bool driver_operating,
 		goto fail;
 	}
 
+	/* We currently assume we have control of the external link
+	 * and are completely trusted by firmware.  Abort probing
+	 * if that's not true for this function.
+	 */
+	if (driver_operating &&
+	    outlen >= MC_CMD_DRV_ATTACH_EXT_OUT_LEN &&
+	    (MCDI_DWORD(outbuf, DRV_ATTACH_EXT_OUT_FUNC_FLAGS) &
+	     (1 << MC_CMD_DRV_ATTACH_EXT_OUT_FLAG_LINKCTRL |
+	      1 << MC_CMD_DRV_ATTACH_EXT_OUT_FLAG_TRUSTED)) !=
+	    (1 << MC_CMD_DRV_ATTACH_EXT_OUT_FLAG_LINKCTRL |
+	     1 << MC_CMD_DRV_ATTACH_EXT_OUT_FLAG_TRUSTED)) {
+		netif_err(efx, probe, efx->net_dev,
+			  "This driver version only supports one function per port\n");
+		return -ENODEV;
+	}
+
 	if (was_attached != NULL)
 		*was_attached = MCDI_DWORD(outbuf, DRV_ATTACH_OUT_OLD_STATE);
 	return 0;

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
