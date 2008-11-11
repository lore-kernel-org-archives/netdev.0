From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] bnx2: fix poll_controller method so that proper structures
	are passed and all rx queues are checked
Date: Tue, 11 Nov 2008 09:00:55 -0500
Message-ID: <20081111140055.GA30481@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nhorman@tuxdriver.com
To: mchan@broadcom.com, netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:39602 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753762AbYKKODH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 09:03:07 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey-
	I noted recently that bnx2 had a few problems with its poll_controller
method:

1) It passes a net_device structure to bnx2_interrupt, but bnx2_interrupt
expects a bnx2_napi structure.

2) bnx2_interrupt never checks all its rx queues, so theres no guarantee that
we'll see incomming frames.

This patch should fix both those problems

Regards
Neil

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 bnx2.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)


diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 430d430..9e1f0e3 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -7203,10 +7203,12 @@ bnx2_change_mtu(struct net_device *dev, int new_mtu)
 static void
 poll_bnx2(struct net_device *dev)
 {
+	int i;
 	struct bnx2 *bp = netdev_priv(dev);
 
 	disable_irq(bp->pdev->irq);
-	bnx2_interrupt(bp->pdev->irq, dev);
+	for (i = 0; i < bp->irq_nvecs; i++)
+		bnx2_interrupt(bp->pdev->irq, &bp->bnx2_napi[i]);
 	enable_irq(bp->pdev->irq);
 }
 #endif
-- 
/****************************************************
 * Neil Horman <nhorman@tuxdriver.com>
 * Software Engineer, Red Hat
 ****************************************************/
