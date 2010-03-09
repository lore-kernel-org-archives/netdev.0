From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH 2/4] bnx2x: remove not necessary compiler barrier
Date: Tue,  9 Mar 2010 17:55:01 +0100
Message-ID: <1268153703-4186-2-git-send-email-sgruszka@redhat.com>
References: <1268153703-4186-1-git-send-email-sgruszka@redhat.com>
Cc: Vladislav Zolotarov <vladz@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39258 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753955Ab0CIQ4y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Mar 2010 11:56:54 -0500
In-Reply-To: <1268153703-4186-1-git-send-email-sgruszka@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Access to fp->tx_bd_prod is protected by __netif_tx_lock, so we do not
need any barrier for that.

Update of fp->tx_bd_cons in bnx2x_tx_int() is not protected by lock, but
barrier() nor smb_mb() in bnx2x_tx_avail() not guarantee we will see
values that is written on other cpu. Ordering issues between
netif_tx_stop_queue(), netif_tx_queue_stopped(), fp->tx_bd_cons = bd_cons
and bnx2x_tx_avail() are already handled by smp_mb() in bnx2x_tx_int()
and bnx2x_start_xmit().

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
 drivers/net/bnx2x_main.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 9fc0f6a..ae62b67 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -893,7 +893,6 @@ static inline u16 bnx2x_tx_avail(struct bnx2x_fastpath *fp)
 	u16 prod;
 	u16 cons;
 
-	barrier(); /* Tell compiler that prod and cons can change */
 	prod = fp->tx_bd_prod;
 	cons = fp->tx_bd_cons;
 
-- 
1.6.2.5

