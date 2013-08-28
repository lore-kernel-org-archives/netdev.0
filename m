From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 07/16] sfc: Add a function pointer to abstract
 write of host time into NIC shared memory
Date: Wed, 28 Aug 2013 16:18:56 +0100
Message-ID: <1377703136.2264.29.camel@bwh-desktop.uk.level5networks.com>
References: <1377702837.2264.21.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17210 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753594Ab3H1PS7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 11:18:59 -0400
In-Reply-To: <1377702837.2264.21.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Laurence Evans <levans@solarflare.com>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/net_driver.h |  1 +
 drivers/net/ethernet/sfc/ptp.c        |  3 +--
 drivers/net/ethernet/sfc/siena.c      | 14 ++++++++++++++
 3 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index d33656b..21b1c2a 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -1117,6 +1117,7 @@ struct efx_nic_type {
 			 size_t *retlen, const u8 *buffer);
 	int (*mtd_sync)(struct mtd_info *mtd);
 #endif
+	void (*ptp_write_host_time)(struct efx_nic *efx, u32 host_time);
 
 	int revision;
 	unsigned int txd_ptr_tbl_base;
diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index 4de2f8f..c60cabb 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -390,8 +390,7 @@ static void efx_ptp_send_times(struct efx_nic *efx,
 		host_time = (now.ts_real.tv_sec << MC_NANOSECOND_BITS |
 			     now.ts_real.tv_nsec);
 		/* Update host time in NIC memory */
-		_efx_writed(efx, cpu_to_le32(host_time),
-			    FR_CZ_MC_TREG_SMEM + MC_SMEM_P0_PTP_TIME_OFST);
+		efx->type->ptp_write_host_time(efx, host_time);
 	}
 	*last_time = now;
 }
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index a51d90c..3c0a544 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -855,6 +855,19 @@ fail:
 
 /**************************************************************************
  *
+ * PTP
+ *
+ **************************************************************************
+ */
+
+static void siena_ptp_write_host_time(struct efx_nic *efx, u32 host_time)
+{
+	_efx_writed(efx, cpu_to_le32(host_time),
+		    FR_CZ_MC_TREG_SMEM + MC_SMEM_P0_PTP_TIME_OFST);
+}
+
+/**************************************************************************
+ *
  * Revision-dependent attributes used by efx.c and nic.c
  *
  **************************************************************************
@@ -943,6 +956,7 @@ const struct efx_nic_type siena_a0_nic_type = {
 	.mtd_write = efx_mcdi_mtd_write,
 	.mtd_sync = efx_mcdi_mtd_sync,
 #endif
+	.ptp_write_host_time = siena_ptp_write_host_time,
 
 	.revision = EFX_REV_SIENA_A0,
 	.txd_ptr_tbl_base = FR_BZ_TX_DESC_PTR_TBL,


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
