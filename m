From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH 3/4] bnx2x: change smp_mb() comment to conform the true
Date: Tue,  9 Mar 2010 17:55:02 +0100
Message-ID: <1268153703-4186-3-git-send-email-sgruszka@redhat.com>
References: <1268153703-4186-1-git-send-email-sgruszka@redhat.com>
 <1268153703-4186-2-git-send-email-sgruszka@redhat.com>
Cc: Vladislav Zolotarov <vladz@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28942 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755106Ab0CIQ44 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Mar 2010 11:56:56 -0500
In-Reply-To: <1268153703-4186-2-git-send-email-sgruszka@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Access to fp->tx_bp_prod is protected by __netif_tx_lock,
smp_mb() is not needed for that.

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
 drivers/net/bnx2x_main.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index ae62b67..6c042a7 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -11428,9 +11428,12 @@ static netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (unlikely(bnx2x_tx_avail(fp) < MAX_SKB_FRAGS + 3)) {
 		netif_tx_stop_queue(txq);
-		/* We want bnx2x_tx_int to "see" the updated tx_bd_prod
-		   if we put Tx into XOFF state. */
+
+		/* paired memory barrier is in bnx2x_tx_int(), we have to keep
+		 * ordering of set_bit() in netif_tx_stop_queue() and read of
+		 * fp->bd_tx_cons */
 		smp_mb();
+
 		fp->eth_q_stats.driver_xoff++;
 		if (bnx2x_tx_avail(fp) >= MAX_SKB_FRAGS + 3)
 			netif_tx_wake_queue(txq);
-- 
1.6.2.5

