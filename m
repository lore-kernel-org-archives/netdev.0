From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 16/32] sfc: Make efx_mcdi_init() call
 efx_mcdi_handle_assertion()
Date: Thu, 22 Aug 2013 13:53:19 +0100
Message-ID: <1377175999.1703.21.camel@bwh-desktop.uk.level5networks.com>
References: <1377175392.1703.5.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:13996 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753325Ab3HVMxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 08:53:22 -0400
In-Reply-To: <1377175392.1703.5.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This should probably be done during MCDI initialisation for any NIC.
Change efx_mcdi_init() to return an error code.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.c  | 8 ++++----
 drivers/net/ethernet/sfc/mcdi.h  | 2 +-
 drivers/net/ethernet/sfc/siena.c | 5 +----
 3 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index 5132aba..2b9ef28 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -50,13 +50,10 @@ static inline struct efx_mcdi_iface *efx_mcdi(struct efx_nic *efx)
 	return &nic_data->mcdi;
 }
 
-void efx_mcdi_init(struct efx_nic *efx)
+int efx_mcdi_init(struct efx_nic *efx)
 {
 	struct efx_mcdi_iface *mcdi;
 
-	if (efx_nic_rev(efx) < EFX_REV_SIENA_A0)
-		return;
-
 	mcdi = efx_mcdi(efx);
 	init_waitqueue_head(&mcdi->wq);
 	spin_lock_init(&mcdi->iface_lock);
@@ -64,6 +61,9 @@ void efx_mcdi_init(struct efx_nic *efx)
 	mcdi->mode = MCDI_MODE_POLL;
 
 	(void) efx_mcdi_poll_reboot(efx);
+
+	/* Recover from a failed assertion before probing */
+	return efx_mcdi_handle_assertion(efx);
 }
 
 static void efx_mcdi_copyin(struct efx_nic *efx, unsigned cmd,
diff --git a/drivers/net/ethernet/sfc/mcdi.h b/drivers/net/ethernet/sfc/mcdi.h
index c8f2cd5..6c58dbd 100644
--- a/drivers/net/ethernet/sfc/mcdi.h
+++ b/drivers/net/ethernet/sfc/mcdi.h
@@ -65,7 +65,7 @@ struct efx_mcdi_mon {
 	unsigned int n_attrs;
 };
 
-extern void efx_mcdi_init(struct efx_nic *efx);
+extern int efx_mcdi_init(struct efx_nic *efx);
 
 extern int efx_mcdi_rpc(struct efx_nic *efx, unsigned cmd,
 			const efx_dword_t *inbuf, size_t inlen,
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index b5d5568..3dca771 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -210,10 +210,7 @@ static int siena_probe_nic(struct efx_nic *efx)
 	efx_reado(efx, &reg, FR_AZ_CS_DEBUG);
 	efx->port_num = EFX_OWORD_FIELD(reg, FRF_CZ_CS_PORT_NUM) - 1;
 
-	efx_mcdi_init(efx);
-
-	/* Recover from a failed assertion before probing */
-	rc = efx_mcdi_handle_assertion(efx);
+	rc = efx_mcdi_init(efx);
 	if (rc)
 		goto fail1;
 


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
