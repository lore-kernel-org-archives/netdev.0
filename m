From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next 09/12] bna: Handle the TX Setup Failures
Date: Tue, 17 Dec 2013 17:07:39 -0800
Message-ID: <1387328862-27213-10-git-send-email-rmody@brocade.com>
References: <1387328862-27213-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	<adapter_linux_open_src_team@Brocade.COM>,
	Rasesh Mody <rmody@Brocade.COM>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:48595 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752286Ab3LRBIt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 20:08:49 -0500
In-Reply-To: <1387328862-27213-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - When bnad_setup_tx() returns NULL, the error is NOT returned to the caller.
   The caller will incorrectly assume success. So Return ENOMEM when bna_tx_create()
   fails.
 - If bnad_tx_msix_register() fails, call bna_tx_destroy() to free tx & to NULL
   the bnad reference to tcb.

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bnad.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 8278ab5..ad8dd75 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -1999,8 +1999,10 @@ bnad_setup_tx(struct bnad *bnad, u32 tx_id)
 	tx = bna_tx_create(&bnad->bna, bnad, tx_config, &tx_cbfn, res_info,
 			tx_info);
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
-	if (!tx)
+	if (!tx) {
+		err = -ENOMEM;
 		goto err_return;
+	}
 	tx_info->tx = tx;
 
 	INIT_DELAYED_WORK(&tx_info->tx_cleanup_work,
@@ -2011,7 +2013,7 @@ bnad_setup_tx(struct bnad *bnad, u32 tx_id)
 		err = bnad_tx_msix_register(bnad, tx_info,
 			tx_id, bnad->num_txq_per_tx);
 		if (err)
-			goto err_return;
+			goto cleanup_tx;
 	}
 
 	spin_lock_irqsave(&bnad->bna_lock, flags);
@@ -2020,6 +2022,12 @@ bnad_setup_tx(struct bnad *bnad, u32 tx_id)
 
 	return 0;
 
+cleanup_tx:
+	spin_lock_irqsave(&bnad->bna_lock, flags);
+	bna_tx_destroy(tx_info->tx);
+	spin_unlock_irqrestore(&bnad->bna_lock, flags);
+	tx_info->tx = NULL;
+	tx_info->tx_id = 0;
 err_return:
 	bnad_tx_res_free(bnad, res_info);
 	return err;
-- 
1.8.2.3
