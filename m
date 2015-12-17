From: Venkat Duvvuru <venkatkumar.duvvuru@avagotech.com>
Subject: [PATCH net] be2net: Avoid accessing eq object in be_msix_register routine, when i < 0.
Date: Fri, 18 Dec 2015 01:40:50 +0530
Message-ID: <1450383050-25106-1-git-send-email-venkatkumar.duvvuru@avagotech.com>
Cc: venkatkumar.duvvuru@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:50719 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755866AbbLQPuV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 10:50:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the first request_irq fails in be_msix_register, i value
would be zero. The current code decrements the i value and
accesses the eq object without validating the decremented
"i" value. This can cause an "invalid memory address access"
violation.

This patch fixes the problem by accessing the eq object after
validating the "i" value.

Signed-off-by: Venkat Duvvuru <venkatkumar.duvvuru@avagotech.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index b6ad029..6598820 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3299,8 +3299,10 @@ static int be_msix_register(struct be_adapter *adapter)
 
 	return 0;
 err_msix:
-	for (i--, eqo = &adapter->eq_obj[i]; i >= 0; i--, eqo--)
+	for (i--; i >= 0; i--) {
+		eqo = &adapter->eq_obj[i];
 		free_irq(be_msix_vec_get(adapter, eqo), eqo);
+	}
 	dev_warn(&adapter->pdev->dev, "MSIX Request IRQ failed - err %d\n",
 		 status);
 	be_msix_disable(adapter);
-- 
1.8.3.1
