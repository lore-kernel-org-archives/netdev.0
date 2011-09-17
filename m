From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next 3/3] bna: Eliminate Small Race Condition Window in RX Path
Date: Fri, 16 Sep 2011 18:06:48 -0700
Message-ID: <1316221608-21392-3-git-send-email-rmody@brocade.com>
References: <1316221608-21392-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>,
	Gurunatha Karaje <gkaraje@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:57138 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932145Ab1IQBH7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2011 21:07:59 -0400
In-Reply-To: <1316221608-21392-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - In a continuous sequence of ifconfig up/down operations, there is a small
   window of race between bnad_set_rx_mode() and bnad_cleanup_rx() while the
   former tries to access rx_info->rx & the latter sets it to NULL. This race
   could lead to bna_rx_mode_set() being called with a NULL (rx_info->rx)
   pointer and a crash.
 - Hold bnad->bna_lock while setting / unsetting rx_info->rx in bnad_setup_rx()
   & bnad_cleanup_rx(), thereby eliminating the race described above.

Signed-off-by: Gurunatha Karaje <gkaraje@brocade.com>
Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bnad.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 33ab1f8..abca139 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -1875,10 +1875,10 @@ bnad_cleanup_rx(struct bnad *bnad, u32 rx_id)
 
 	spin_lock_irqsave(&bnad->bna_lock, flags);
 	bna_rx_destroy(rx_info->rx);
-	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 
 	rx_info->rx = NULL;
 	rx_info->rx_id = 0;
+	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 
 	bnad_rx_res_free(bnad, res_info);
 }
@@ -1932,12 +1932,13 @@ bnad_setup_rx(struct bnad *bnad, u32 rx_id)
 	spin_lock_irqsave(&bnad->bna_lock, flags);
 	rx = bna_rx_create(&bnad->bna, bnad, rx_config, &rx_cbfn, res_info,
 			rx_info);
-	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 	if (!rx) {
 		err = -ENOMEM;
+		spin_unlock_irqrestore(&bnad->bna_lock, flags);
 		goto err_return;
 	}
 	rx_info->rx = rx;
+	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 
 	/*
 	 * Init NAPI, so that state is set to NAPI_STATE_SCHED,
-- 
1.7.1
