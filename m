From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 1/4] bnxt_en: Perform function reset earlier during probe.
Date: Wed,  8 Mar 2017 18:44:32 -0500
Message-ID: <1489016675-16097-2-git-send-email-michael.chan@broadcom.com>
References: <1489016675-16097-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:36921 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752315AbdCHXqD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 18:46:03 -0500
Received: by mail-wm0-f52.google.com with SMTP id n11so43543811wma.0
        for <netdev@vger.kernel.org>; Wed, 08 Mar 2017 15:44:49 -0800 (PST)
In-Reply-To: <1489016675-16097-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The firmware call to do function reset is done too late.  It is causing
the rings that have been reserved to be freed.  In NPAR mode, this bug
is causing us to run out of rings.

Fixes: 391be5c27364 ("bnxt_en: Implement new scheme to reserve tx rings.")
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 235733e..33293ac 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -7444,6 +7444,10 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (rc)
 		goto init_err_pci_clean;
 
+	rc = bnxt_hwrm_func_reset(bp);
+	if (rc)
+		goto init_err_pci_clean;
+
 	bnxt_hwrm_fw_set_time(bp);
 
 	dev->hw_features = NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM | NETIF_F_SG |
@@ -7554,10 +7558,6 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (rc)
 		goto init_err_pci_clean;
 
-	rc = bnxt_hwrm_func_reset(bp);
-	if (rc)
-		goto init_err_pci_clean;
-
 	rc = bnxt_init_int_mode(bp);
 	if (rc)
 		goto init_err_pci_clean;
-- 
1.8.3.1
