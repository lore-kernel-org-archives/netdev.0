From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net-next 3/3] bna: remove global bnad_list_mutex
Date: Fri, 29 Jul 2016 19:52:58 +0200
Message-ID: <1469814778-23186-4-git-send-email-ivecera@redhat.com>
References: <1469814778-23186-1-git-send-email-ivecera@redhat.com>
Cc: rasesh.mody@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41468 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753217AbcG2RxF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jul 2016 13:53:05 -0400
In-Reply-To: <1469814778-23186-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove global bnad_list_mutex as it is not used anymore. This makes
bnad_add_to_list() and bnad_remove_from_list() empty so remove them too.

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/brocade/bna/bnad.c | 20 --------------------
 1 file changed, 20 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 2bed050..f9df4b5 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -55,7 +55,6 @@ MODULE_PARM_DESC(bna_debugfs_enable, "Enables debugfs feature, default=1,"
  */
 static u32 bnad_rxqs_per_cq = 2;
 static atomic_t bna_id;
-static struct mutex bnad_list_mutex;
 static const u8 bnad_bcast_addr[] __aligned(2) =
 	{ 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
 
@@ -75,20 +74,6 @@ do {								\
 	(_res_info)->res_u.mem_info.len = (_size);		\
 } while (0)
 
-static void
-bnad_add_to_list(struct bnad *bnad)
-{
-	mutex_lock(&bnad_list_mutex);
-	mutex_unlock(&bnad_list_mutex);
-}
-
-static void
-bnad_remove_from_list(struct bnad *bnad)
-{
-	mutex_lock(&bnad_list_mutex);
-	mutex_unlock(&bnad_list_mutex);
-}
-
 /*
  * Reinitialize completions in CQ, once Rx is taken down
  */
@@ -3569,14 +3554,12 @@ bnad_lock_init(struct bnad *bnad)
 {
 	spin_lock_init(&bnad->bna_lock);
 	mutex_init(&bnad->conf_mutex);
-	mutex_init(&bnad_list_mutex);
 }
 
 static void
 bnad_lock_uninit(struct bnad *bnad)
 {
 	mutex_destroy(&bnad->conf_mutex);
-	mutex_destroy(&bnad_list_mutex);
 }
 
 /* PCI Initialization */
@@ -3649,7 +3632,6 @@ bnad_pci_probe(struct pci_dev *pdev,
 	}
 	bnad = netdev_priv(netdev);
 	bnad_lock_init(bnad);
-	bnad_add_to_list(bnad);
 	bnad->id = atomic_inc_return(&bna_id) - 1;
 
 	mutex_lock(&bnad->conf_mutex);
@@ -3804,7 +3786,6 @@ pci_uninit:
 	bnad_pci_uninit(pdev);
 unlock_mutex:
 	mutex_unlock(&bnad->conf_mutex);
-	bnad_remove_from_list(bnad);
 	bnad_lock_uninit(bnad);
 	free_netdev(netdev);
 	return err;
@@ -3842,7 +3823,6 @@ bnad_pci_remove(struct pci_dev *pdev)
 	bnad_disable_msix(bnad);
 	bnad_pci_uninit(pdev);
 	mutex_unlock(&bnad->conf_mutex);
-	bnad_remove_from_list(bnad);
 	bnad_lock_uninit(bnad);
 	/* Remove the debugfs node for this bnad */
 	kfree(bnad->regdata);
-- 
2.7.3
