From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 5/7] qlcnic: protect qlicnic_attach_func with rtnl_lock
Date: Mon, 18 Apr 2016 21:19:46 +0200
Message-ID: <1461007188-1603-6-git-send-email-hannes@stressinduktion.org>
References: <1461007188-1603-1-git-send-email-hannes@stressinduktion.org>
Cc: jesse@kernel.org, Dept-GELinuxNICDev@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:36989 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751509AbcDRTUI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 15:20:08 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 266D321498
	for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 15:20:07 -0400 (EDT)
In-Reply-To: <1461007188-1603-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

qlcnic_attach_func requires rtnl_lock to be held.

Cc: Dept-GELinuxNICDev@qlogic.com
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 1205f6f9c94173..1c29105b6c364f 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -3952,8 +3952,14 @@ static pci_ers_result_t qlcnic_82xx_io_error_detected(struct pci_dev *pdev,
 
 static pci_ers_result_t qlcnic_82xx_io_slot_reset(struct pci_dev *pdev)
 {
-	return qlcnic_attach_func(pdev) ? PCI_ERS_RESULT_DISCONNECT :
-				PCI_ERS_RESULT_RECOVERED;
+	pci_ers_result_t res;
+
+	rtnl_lock();
+	res = qlcnic_attach_func(pdev) ? PCI_ERS_RESULT_DISCONNECT :
+					 PCI_ERS_RESULT_RECOVERED;
+	rtnl_unlock();
+
+	return res;
 }
 
 static void qlcnic_82xx_io_resume(struct pci_dev *pdev)
-- 
2.5.5
