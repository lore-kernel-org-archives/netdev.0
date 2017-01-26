From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 2/3] sfc: refactor debug-or-warnings printks
Date: Thu, 26 Jan 2017 17:53:48 +0000
Message-ID: <15f3ecb9-1785-8688-93b9-51d400ee12bc@solarflare.com>
References: <39d8923f-4400-506c-dd50-250636ff83fa@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:48408 "EHLO
        nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754012AbdAZRyA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 12:54:00 -0500
In-Reply-To: <39d8923f-4400-506c-dd50-250636ff83fa@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Cooper <jcooper@solarflare.com>

Rationalise several debug-or-warnings printks in to a macro that switches
 between netif_dbg and netif_warn to make output more consistent.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c       |  8 ++++----
 drivers/net/ethernet/sfc/mcdi.c       | 19 ++++++++-----------
 drivers/net/ethernet/sfc/net_driver.h |  9 +++++++++
 3 files changed, 21 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index b64b47b..d0c1ed0e 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -4881,10 +4881,10 @@ static int efx_ef10_filter_insert_def(struct efx_nic *efx,
 
 	rc = efx_ef10_filter_insert(efx, &spec, true);
 	if (rc < 0) {
-		netif_printk(efx, drv, rc == -EPERM ? KERN_DEBUG : KERN_WARNING,
-			     efx->net_dev,
-			     "%scast mismatch filter insert failed rc=%d\n",
-			     multicast ? "Multi" : "Uni", rc);
+		netif_cond_dbg(efx, drv, efx->net_dev,
+			       rc == -EPERM, warn,
+			       "%scast mismatch filter insert failed rc=%d\n",
+			       multicast ? "Multi" : "Uni", rc);
 	} else if (multicast) {
 		EFX_WARN_ON_PARANOID(vlan->mcdef != EFX_EF10_FILTER_ID_INVALID);
 		vlan->mcdef = efx_ef10_filter_get_unsafe_id(efx, rc);
diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index 9956513..24b271b 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -837,11 +837,9 @@ static int _efx_mcdi_rpc(struct efx_nic *efx, unsigned int cmd,
 						  outbuf, outlen, outlen_actual,
 						  quiet, NULL, raw_rc);
 		} else {
-			netif_printk(efx, hw,
-				     rc == -EPERM ? KERN_DEBUG : KERN_ERR,
-				     efx->net_dev,
-				     "MC command 0x%x failed after proxy auth rc=%d\n",
-				     cmd, rc);
+			netif_cond_dbg(efx, hw, efx->net_dev, rc == -EPERM, err,
+				       "MC command 0x%x failed after proxy auth rc=%d\n",
+				       cmd, rc);
 
 			if (rc == -EINTR || rc == -EIO)
 				efx_schedule_reset(efx, RESET_TYPE_MC_FAILURE);
@@ -1084,10 +1082,9 @@ void efx_mcdi_display_error(struct efx_nic *efx, unsigned cmd,
 		code = MCDI_DWORD(outbuf, ERR_CODE);
 	if (outlen >= MC_CMD_ERR_ARG_OFST + 4)
 		err_arg = MCDI_DWORD(outbuf, ERR_ARG);
-	netif_printk(efx, hw, rc == -EPERM ? KERN_DEBUG : KERN_ERR,
-		     efx->net_dev,
-		     "MC command 0x%x inlen %zu failed rc=%d (raw=%d) arg=%d\n",
-		     cmd, inlen, rc, code, err_arg);
+	netif_cond_dbg(efx, hw, efx->net_dev, rc == -EPERM, err,
+		       "MC command 0x%x inlen %zu failed rc=%d (raw=%d) arg=%d\n",
+		       cmd, inlen, rc, code, err_arg);
 }
 
 /* Switch to polled MCDI completions.  This can be called in various
@@ -2057,8 +2054,8 @@ int efx_mcdi_get_workarounds(struct efx_nic *efx, unsigned int *impl_out,
 	/* Older firmware lacks GET_WORKAROUNDS and this isn't especially
 	 * terrifying.  The call site will have to deal with it though.
 	 */
-	netif_printk(efx, hw, rc == -ENOSYS ? KERN_DEBUG : KERN_ERR,
-		     efx->net_dev, "%s: failed rc=%d\n", __func__, rc);
+	netif_cond_dbg(efx, hw, efx->net_dev, rc == -ENOSYS, err,
+		       "%s: failed rc=%d\n", __func__, rc);
 	return rc;
 }
 
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 5927c20..c640955 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -51,6 +51,15 @@
 #define EFX_WARN_ON_PARANOID(x) do {} while (0)
 #endif
 
+/* if @cond then downgrade to debug, else print at @level */
+#define netif_cond_dbg(priv, type, netdev, cond, level, fmt, args...)     \
+	do {                                                              \
+		if (cond)                                                 \
+			netif_dbg(priv, type, netdev, fmt, ##args);       \
+		else                                                      \
+			netif_ ## level(priv, type, netdev, fmt, ##args); \
+	} while (0)
+
 /**************************************************************************
  *
  * Efx data structures
