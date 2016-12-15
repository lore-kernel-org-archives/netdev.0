From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net] sfc: skip ptp allocations on secondary interfaces
Date: Thu, 15 Dec 2016 15:31:04 -0500
Message-ID: <20161215203104.12714-1-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>, linux-net-drivers@solarflare.com,
        Edward Cree <ecree@solarflare.com>,
        Bert Kenward <bkenward@solarflare.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42588 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755212AbcLOUbm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Dec 2016 15:31:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rather than allocating efx_ptp_data, a buffer, a workqueue, etc., and then
ultimately deciding not to call ptp_clock_register() for non-primary
interfaces, just exit out of efx_ptp_prober() earlier. Saves a little
memory and speeds up init and teardown slightly.

CC: linux-net-drivers@solarflare.com
CC: Edward Cree <ecree@solarflare.com>
CC: Bert Kenward <bkenward@solarflare.com>
CC: netdev@vger.kernel.org
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/net/ethernet/sfc/ptp.c | 32 +++++++++++++++++---------------
 1 file changed, 17 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index 60cdb97..45df9f0 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -1220,6 +1220,10 @@ int efx_ptp_probe(struct efx_nic *efx, struct efx_channel *channel)
 	int rc = 0;
 	unsigned int pos;
 
+	if (!(efx->mcdi->fn_flags &
+	    (1 << MC_CMD_DRV_ATTACH_EXT_OUT_FLAG_PRIMARY)))
+		return 0;
+
 	ptp = kzalloc(sizeof(struct efx_ptp_data), GFP_KERNEL);
 	efx->ptp_data = ptp;
 	if (!efx->ptp_data)
@@ -1261,23 +1265,21 @@ int efx_ptp_probe(struct efx_nic *efx, struct efx_channel *channel)
 	if (rc < 0)
 		goto fail3;
 
-	if (efx->mcdi->fn_flags &
-	    (1 << MC_CMD_DRV_ATTACH_EXT_OUT_FLAG_PRIMARY)) {
-		ptp->phc_clock_info = efx_phc_clock_info;
-		ptp->phc_clock = ptp_clock_register(&ptp->phc_clock_info,
-						    &efx->pci_dev->dev);
-		if (IS_ERR(ptp->phc_clock)) {
-			rc = PTR_ERR(ptp->phc_clock);
-			goto fail3;
-		} else if (ptp->phc_clock) {
-			INIT_WORK(&ptp->pps_work, efx_ptp_pps_worker);
-			ptp->pps_workwq = create_singlethread_workqueue("sfc_pps");
-			if (!ptp->pps_workwq) {
-				rc = -ENOMEM;
-				goto fail4;
-			}
+	ptp->phc_clock_info = efx_phc_clock_info;
+	ptp->phc_clock = ptp_clock_register(&ptp->phc_clock_info,
+					    &efx->pci_dev->dev);
+	if (IS_ERR(ptp->phc_clock)) {
+		rc = PTR_ERR(ptp->phc_clock);
+		goto fail3;
+	} else if (ptp->phc_clock) {
+		INIT_WORK(&ptp->pps_work, efx_ptp_pps_worker);
+		ptp->pps_workwq = create_singlethread_workqueue("sfc_pps");
+		if (!ptp->pps_workwq) {
+			rc = -ENOMEM;
+			goto fail4;
 		}
 	}
+
 	ptp->nic_ts_enabled = false;
 
 	return 0;
-- 
2.10.0
