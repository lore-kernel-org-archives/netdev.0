From: leitao@linux.vnet.ibm.com
Subject: [PATCH] bnx2: reset_task is crashing the kernel. Fixing it.
Date: Wed, 16 Dec 2009 13:12:39 -0600
Message-ID: <1260990759-16236-1-git-send-email-leitao@linux.vnet.ibm.com>
References: <1260988830.31045.79.camel@nseg_linux_HP1.broadcom.com>
Cc: netdev@vger.kernel.org, Breno Leitao <leitao@linux.vnet.ibm.com>
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp05.br.ibm.com ([32.104.18.26]:46461 "EHLO
	e24smtp05.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762968AbZLPTN1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2009 14:13:27 -0500
Received: from mailhub3.br.ibm.com (mailhub3.br.ibm.com [9.18.232.110])
	by e24smtp05.br.ibm.com (8.14.3/8.13.1) with ESMTP id nBGJ4wF2026517
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2009 17:04:58 -0200
Received: from d24av04.br.ibm.com (d24av04.br.ibm.com [9.8.31.97])
	by mailhub3.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBGJF8ek1421378
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2009 17:15:09 -0200
Received: from d24av04.br.ibm.com (loopback [127.0.0.1])
	by d24av04.br.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBGJDNc4028651
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2009 17:13:23 -0200
In-Reply-To: <1260988830.31045.79.camel@nseg_linux_HP1.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If bnx2 schedules a reset via the reset_task, e.g., due to a TX
timeout, it's possible for the NIC to be disabled with packets
pending for transmit.  In this case, napi_disable will loop forever,
eventually crashing the kernel.  This patch moves the disable of
the device to after the napi_disable call.

Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
---
 drivers/net/bnx2.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index f81f082..65df1de 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -653,7 +653,6 @@ static void
 bnx2_netif_stop(struct bnx2 *bp)
 {
 	bnx2_cnic_stop(bp);
-	bnx2_disable_int_sync(bp);
 	if (netif_running(bp->dev)) {
 		int i;
 
@@ -667,6 +666,7 @@ bnx2_netif_stop(struct bnx2 *bp)
 			txq->trans_start = jiffies;
 		}
 	}
+	bnx2_disable_int_sync(bp);
 }
 
 static void
-- 
1.6.0.2

