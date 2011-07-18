From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 33/45] bna: Device Init Fix
Date: Mon, 18 Jul 2011 01:22:53 -0700
Message-ID: <1310977385-5268-23-git-send-email-rmody@brocade.com>
References: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>, <dradovan@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:37826 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753918Ab1GRIYs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 04:24:48 -0400
In-Reply-To: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - Do not return probe failure when device initialization fails so that the
   driver stays loaded and the hardware is accessible for debugging.

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bnad.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bna/bnad.c b/drivers/net/bna/bnad.c
index 6d1b82b..2b716ed 100644
--- a/drivers/net/bna/bnad.c
+++ b/drivers/net/bna/bnad.c
@@ -3308,19 +3308,21 @@ bnad_pci_probe(struct pci_dev *pdev,
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 
 	err = bnad_res_alloc(bnad, &bnad->mod_res_info[0], BNA_MOD_RES_T_MAX);
-	if (err)
+	if (err) {
+		err = -EIO;
 		goto disable_ioceth;
+	}
 
 	spin_lock_irqsave(&bnad->bna_lock, flags);
 	bna_mod_init(&bnad->bna, &bnad->mod_res_info[0]);
-	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 
 	/* Get the burnt-in mac */
-	spin_lock_irqsave(&bnad->bna_lock, flags);
 	bna_enet_perm_mac_get(&bna->enet, &bnad->perm_addr);
 	bnad_set_netdev_perm_addr(bnad);
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 
+	mutex_unlock(&bnad->conf_mutex);
+
 	/* Finally, reguister with net_device layer */
 	err = register_netdev(netdev);
 	if (err) {
@@ -3329,6 +3331,8 @@ bnad_pci_probe(struct pci_dev *pdev,
 	}
 	set_bit(BNAD_RF_NETDEV_REGISTERED, &bnad->run_flags);
 
+	return 0;
+
 probe_success:
 	mutex_unlock(&bnad->conf_mutex);
 	return 0;
-- 
1.7.1

