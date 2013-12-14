From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 01/15] sfc: Store flags from MC_CMD_DRV_ATTACH for
 later use
Date: Sat, 14 Dec 2013 23:01:02 +0000
Message-ID: <1387062062.12172.59.camel@deadeye.wl.decadent.org.uk>
References: <1387061852.12172.58.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	"Richard Cochran" <richardcochran@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17255 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753858Ab3LNXBH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Dec 2013 18:01:07 -0500
In-Reply-To: <1387061852.12172.58.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.c |   18 ++++++++++++++++--
 drivers/net/ethernet/sfc/mcdi.h |    2 ++
 2 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index d317dfdee845..d608838f6729 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -1132,13 +1132,27 @@ static int efx_mcdi_drv_attach(struct efx_nic *efx, bool driver_operating,
 		goto fail;
 	}
 
+	if (driver_operating) {
+		if (outlen >= MC_CMD_DRV_ATTACH_EXT_OUT_LEN) {
+			efx->mcdi->fn_flags =
+				MCDI_DWORD(outbuf,
+					   DRV_ATTACH_EXT_OUT_FUNC_FLAGS);
+		} else {
+			/* Synthesise flags for Siena */
+			efx->mcdi->fn_flags =
+				1 << MC_CMD_DRV_ATTACH_EXT_OUT_FLAG_LINKCTRL |
+				1 << MC_CMD_DRV_ATTACH_EXT_OUT_FLAG_TRUSTED |
+				(efx_port_num(efx) == 0) <<
+				MC_CMD_DRV_ATTACH_EXT_OUT_FLAG_PRIMARY;
+		}
+	}
+
 	/* We currently assume we have control of the external link
 	 * and are completely trusted by firmware.  Abort probing
 	 * if that's not true for this function.
 	 */
 	if (driver_operating &&
-	    outlen >= MC_CMD_DRV_ATTACH_EXT_OUT_LEN &&
-	    (MCDI_DWORD(outbuf, DRV_ATTACH_EXT_OUT_FUNC_FLAGS) &
+	    (efx->mcdi->fn_flags &
 	     (1 << MC_CMD_DRV_ATTACH_EXT_OUT_FLAG_LINKCTRL |
 	      1 << MC_CMD_DRV_ATTACH_EXT_OUT_FLAG_TRUSTED)) !=
 	    (1 << MC_CMD_DRV_ATTACH_EXT_OUT_FLAG_LINKCTRL |
diff --git a/drivers/net/ethernet/sfc/mcdi.h b/drivers/net/ethernet/sfc/mcdi.h
index 171f5f58f84a..52931aebf3c3 100644
--- a/drivers/net/ethernet/sfc/mcdi.h
+++ b/drivers/net/ethernet/sfc/mcdi.h
@@ -94,12 +94,14 @@ struct efx_mcdi_mtd_partition {
  * struct efx_mcdi_data - extra state for NICs that implement MCDI
  * @iface: Interface/protocol state
  * @hwmon: Hardware monitor state
+ * @fn_flags: Flags for this function, as returned by %MC_CMD_DRV_ATTACH.
  */
 struct efx_mcdi_data {
 	struct efx_mcdi_iface iface;
 #ifdef CONFIG_SFC_MCDI_MON
 	struct efx_mcdi_mon hwmon;
 #endif
+	u32 fn_flags;
 };
 
 #ifdef CONFIG_SFC_MCDI_MON


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
