From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH net-next 2/4] qlcnic: Fix NULL dereference in error path.
Date: Tue,  2 Apr 2013 11:34:41 -0400
Message-ID: <1364916883-10109-3-git-send-email-rajesh.borundia@qlogic.com>
References: <1364916883-10109-1-git-send-email-rajesh.borundia@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:48933 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1761330Ab3DBP5v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Apr 2013 11:57:51 -0400
In-Reply-To: <1364916883-10109-1-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Fix for smatch tool reported error
   drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c:2029
   qlcnic_probe() error: potential NULL dereference 'adapter'.
o While returning from an error path in probe, adapter is not
  initialized. So do not access adapter in cleanup path.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 3ee593e..0d00b2b 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -546,11 +546,10 @@ void qlcnic_teardown_intr(struct qlcnic_adapter *adapter)
 	}
 }
 
-static void
-qlcnic_cleanup_pci_map(struct qlcnic_adapter *adapter)
+static void qlcnic_cleanup_pci_map(struct qlcnic_hardware_context *ahw)
 {
-	if (adapter->ahw->pci_base0 != NULL)
-		iounmap(adapter->ahw->pci_base0);
+	if (ahw->pci_base0 != NULL)
+		iounmap(ahw->pci_base0);
 }
 
 static int qlcnic_get_act_pci_func(struct qlcnic_adapter *adapter)
@@ -2026,7 +2025,7 @@ err_out_free_netdev:
 	free_netdev(netdev);
 
 err_out_iounmap:
-	qlcnic_cleanup_pci_map(adapter);
+	qlcnic_cleanup_pci_map(ahw);
 
 err_out_free_hw_res:
 	kfree(ahw);
@@ -2083,7 +2082,7 @@ static void qlcnic_remove(struct pci_dev *pdev)
 
 	qlcnic_remove_sysfs(adapter);
 
-	qlcnic_cleanup_pci_map(adapter);
+	qlcnic_cleanup_pci_map(adapter->ahw);
 
 	qlcnic_release_firmware(adapter);
 
-- 
1.6.3.3
