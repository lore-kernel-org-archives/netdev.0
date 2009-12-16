From: leitao@linux.vnet.ibm.com
Subject: [PATCH] bnx2: reset_task is crashing the kernel. Fixing it.
Date: Wed, 16 Dec 2009 06:09:25 -0600
Message-ID: <1260965365-14255-3-git-send-email-leitao@linux.vnet.ibm.com>
References: <1260965365-14255-1-git-send-email-leitao@linux.vnet.ibm.com>
 <1260965365-14255-2-git-send-email-leitao@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, Breno Leitao <leitao@linux.vnet.ibm.com>
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp03.br.ibm.com ([32.104.18.24]:42499 "EHLO
	e24smtp03.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761162AbZLPMKR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2009 07:10:17 -0500
Received: from mailhub1.br.ibm.com (mailhub1.br.ibm.com [9.18.232.109])
	by e24smtp03.br.ibm.com (8.14.3/8.13.1) with ESMTP id nBGC9bv2028213
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2009 10:09:37 -0200
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by mailhub1.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBGCBtaR1012116
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2009 10:11:56 -0200
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBGCACHs009672
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2009 10:10:13 -0200
In-Reply-To: <1260965365-14255-2-git-send-email-leitao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acutally if a BNX2 interface gets time outs, the reset_task is
called to restart the interface. But, the NIC is turned off with
some packages to transmitt, and this causes the function
napi_disable() to loop forever, crashing the kernel.

Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
---
 drivers/net/bnx2.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index f81f082..40c883b 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -652,8 +652,6 @@ bnx2_napi_enable(struct bnx2 *bp)
 static void
 bnx2_netif_stop(struct bnx2 *bp)
 {
-	bnx2_cnic_stop(bp);
-	bnx2_disable_int_sync(bp);
 	if (netif_running(bp->dev)) {
 		int i;
 
@@ -667,6 +665,8 @@ bnx2_netif_stop(struct bnx2 *bp)
 			txq->trans_start = jiffies;
 		}
 	}
+	bnx2_cnic_stop(bp);
+	bnx2_disable_int_sync(bp);
 }
 
 static void
-- 
1.6.0.2

