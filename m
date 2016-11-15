From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 5/5] bnx2x: switch to napi_complete_done()
Date: Tue, 15 Nov 2016 10:15:15 -0800
Message-ID: <1479233715-9905-6-git-send-email-edumazet@google.com>
References: <1479233715-9905-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Adam Belay <abelay@google.com>, Zach Brown <zach.brown@ni.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>,
        Ariel Elior <ariel.elior@cavium.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:36171 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936535AbcKOSQF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 13:16:05 -0500
Received: by mail-pg0-f53.google.com with SMTP id f188so69003013pgc.3
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 10:16:05 -0800 (PST)
In-Reply-To: <1479233715-9905-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Switch from napi_complete() to napi_complete_done()
for better GRO support (gro_flush_timeout) and core NAPI
features.

Do not rearm interrupts if we are busy polling,
to reduce bus and interrupts overhead.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Willem de Bruijn <willemb@google.com>
Cc: Adam Belay <abelay@google.com>
Cc: Tariq Toukan <tariqt@mellanox.com>
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
Cc: Ariel Elior <ariel.elior@cavium.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index ed42c1009685..3fd36b421d51 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -3248,13 +3248,14 @@ static int bnx2x_poll(struct napi_struct *napi, int budget)
 			rmb();
 
 			if (!(bnx2x_has_rx_work(fp) || bnx2x_has_tx_work(fp))) {
-				napi_complete(napi);
-				/* Re-enable interrupts */
-				DP(NETIF_MSG_RX_STATUS,
-				   "Update index to %d\n", fp->fp_hc_idx);
-				bnx2x_ack_sb(bp, fp->igu_sb_id, USTORM_ID,
-					     le16_to_cpu(fp->fp_hc_idx),
-					     IGU_INT_ENABLE, 1);
+				if (napi_complete_done(napi, rx_work_done)) {
+					/* Re-enable interrupts */
+					DP(NETIF_MSG_RX_STATUS,
+					   "Update index to %d\n", fp->fp_hc_idx);
+					bnx2x_ack_sb(bp, fp->igu_sb_id, USTORM_ID,
+						     le16_to_cpu(fp->fp_hc_idx),
+						     IGU_INT_ENABLE, 1);
+				}
 			} else {
 				rx_work_done = budget;
 			}
-- 
2.8.0.rc3.226.g39d4020
