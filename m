From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net 2/2] bnx2x: fix napi poll return value for repoll
Date: Tue, 20 Jan 2015 18:46:16 +0530
Message-ID: <1421759776-376-3-git-send-email-_govind@gmx.com>
References: <1421759776-376-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, benve@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org, ariel.elior@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.201]:56723 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754272AbbATNRd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jan 2015 08:17:33 -0500
In-Reply-To: <1421759776-376-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the commit d75b1ade567ffab ("net: less interrupt masking in NAPI") napi repoll
is done only when work_done == budget. When in busy_poll is we return 0 in
napi_poll. We should return budget. Also do not return workdone > budget.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 1d1147c..ebcbe92 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -3175,7 +3175,7 @@ static int bnx2x_poll(struct napi_struct *napi, int budget)
 		}
 #endif
 		if (!bnx2x_fp_lock_napi(fp))
-			return work_done;
+			return budget;
 
 		for_each_cos_in_tx_queue(fp, cos)
 			if (bnx2x_tx_queue_has_work(fp->txdata_ptr[cos]))
@@ -3187,7 +3187,7 @@ static int bnx2x_poll(struct napi_struct *napi, int budget)
 			/* must not complete if we consumed full budget */
 			if (work_done >= budget) {
 				bnx2x_fp_unlock_napi(fp);
-				break;
+				return budget;
 			}
 		}
 
-- 
2.2.2
