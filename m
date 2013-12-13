From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next 09/12] bna: Handle the TX Setup Failures
Date: Thu, 12 Dec 2013 17:54:35 -0800
Message-ID: <1386899678-18591-10-git-send-email-rmody@brocade.com>
References: <1386899678-18591-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	<adapter_linux_open_src_team@Brocade.COM>,
	Rasesh Mody <rmody@Brocade.COM>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:14819 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751946Ab3LMBzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 20:55:42 -0500
In-Reply-To: <1386899678-18591-1-git-send-email-rmody@brocade.com>
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
index 89a5a91..5ee4a53 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -1983,8 +1983,10 @@ bnad_setup_tx(struct bnad *bnad, u32 tx_id)
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
@@ -1995,7 +1997,7 @@ bnad_setup_tx(struct bnad *bnad, u32 tx_id)
 		err = bnad_tx_msix_register(bnad, tx_info,
 			tx_id, bnad->num_txq_per_tx);
 		if (err)
-			goto err_return;
+			goto cleanup_tx;
 	}
 
 	spin_lock_irqsave(&bnad->bna_lock, flags);
@@ -2004,6 +2006,12 @@ bnad_setup_tx(struct bnad *bnad, u32 tx_id)
 
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
