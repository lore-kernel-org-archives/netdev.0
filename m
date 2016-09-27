From: "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>
Subject: [PATCH net] i40e: avoid NULL pointer dereference and recursive errors on early PCI error
Date: Tue, 27 Sep 2016 18:14:31 -0300
Message-ID: <1475010871-31682-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, gpiccoli@linux.vnet.ibm.com
To: jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:43809 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752060AbcI0VOv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 17:14:51 -0400
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8RLDDUh072012
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 17:14:50 -0400
Received: from e24smtp05.br.ibm.com (e24smtp05.br.ibm.com [32.104.18.26])
        by mx0b-001b2d01.pphosted.com with ESMTP id 25qt4ajk44-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 17:14:50 -0400
Received: from localhost
        by e24smtp05.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gpiccoli@linux.vnet.ibm.com>;
        Tue, 27 Sep 2016 18:14:48 -0300
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
        by d24dlp01.br.ibm.com (Postfix) with ESMTP id 1921B3520068
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 17:14:20 -0400 (EDT)
Received: from d24av03.br.ibm.com (d24av03.br.ibm.com [9.8.31.95])
        by d24relay01.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u8RLEiKV4505686
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 18:14:44 -0300
Received: from d24av03.br.ibm.com (localhost [127.0.0.1])
        by d24av03.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u8RLEhc4005894
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 18:14:44 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Although rare, it's possible to hit PCI error early on device
probe, meaning possibly some structs are not entirely initialized,
and some might even be completely uninitialized, leading to NULL
pointer dereference.

The i40e driver currently presents a "bad" behavior if device hits
such early PCI error: firstly, the struct i40e_pf might not be
attached to pci_dev yet, leading to a NULL pointer dereference on
access to pf->state.

Even checking if the struct is NULL and avoiding the access in that
case isn't enough, since the driver cannot recover from PCI error
that early; in our experiments we saw multiple failures on kernel
log, like:

  [549.664] i40e 0007:01:00.1: Initial pf_reset failed: -15
  [549.664] i40e: probe of 0007:01:00.1 failed with error -15
  [...]
  [871.644] i40e 0007:01:00.1: The driver for the device stopped because the
  device firmware failed to init. Try updating your NVM image.
  [871.644] i40e: probe of 0007:01:00.1 failed with error -32
  [...]
  [872.516] i40e 0007:01:00.0: ARQ: Unknown event 0x0000 ignored

Between the first probe failure (error -15) and the second (error -32)
another PCI error happened due to the first bad probe. Also, driver
started to flood console with those ARQ event messages.

This patch will prevent these issues by allowing error recovery
mechanism to remove the failed device from the system instead of
trying to recover from early PCI errors during device probe.

Signed-off-by: Guilherme G. Piccoli <gpiccoli@linux.vnet.ibm.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index d0b3a1b..dad15b6 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -11360,6 +11360,12 @@ static pci_ers_result_t i40e_pci_error_detected(struct pci_dev *pdev,
 
 	dev_info(&pdev->dev, "%s: error %d\n", __func__, error);
 
+	if (!pf) {
+		dev_info(&pdev->dev,
+			 "Cannot recover - error happened during device probe\n");
+		return PCI_ERS_RESULT_DISCONNECT;
+	}
+
 	/* shutdown all operations */
 	if (!test_bit(__I40E_SUSPENDED, &pf->state)) {
 		rtnl_lock();
-- 
2.1.0
