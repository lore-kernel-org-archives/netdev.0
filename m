From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next 02/12] bna: PCI Probe Fix
Date: Tue, 30 Aug 2011 18:27:38 -0700
Message-ID: <1314754068-31978-3-git-send-email-rmody@brocade.com>
References: <1314754068-31978-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>,
	Gurunatha Karaje <gkaraje@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:35096 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752557Ab1HaB2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 21:28:09 -0400
In-Reply-To: <1314754068-31978-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - Return error as -EIO if bnad_res_alloc fails
 - Release the configuration lock before registering with net_device layer.

Signed-off-by: Gurunatha Karaje <gkaraje@brocade.com>
Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bnad.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 218768f..5784f99 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -3253,8 +3253,10 @@ bnad_pci_probe(struct pci_dev *pdev,
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 
 	err = bnad_res_alloc(bnad, &bnad->mod_res_info[0], BNA_MOD_RES_T_MAX);
-	if (err)
+	if (err) {
+		err = -EIO;
 		goto disable_ioceth;
+	}
 
 	spin_lock_irqsave(&bnad->bna_lock, flags);
 	bna_mod_init(&bnad->bna, &bnad->mod_res_info[0]);
@@ -3266,6 +3268,8 @@ bnad_pci_probe(struct pci_dev *pdev,
 	bnad_set_netdev_perm_addr(bnad);
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 
+	mutex_unlock(&bnad->conf_mutex);
+
 	/* Finally, reguister with net_device layer */
 	err = register_netdev(netdev);
 	if (err) {
@@ -3274,6 +3278,8 @@ bnad_pci_probe(struct pci_dev *pdev,
 	}
 	set_bit(BNAD_RF_NETDEV_REGISTERED, &bnad->run_flags);
 
+	return 0;
+
 probe_success:
 	mutex_unlock(&bnad->conf_mutex);
 	return 0;
-- 
1.7.1
