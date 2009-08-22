From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH -next 2/8] bnx2: Check if_running() before touching chip
 registers.
Date: Fri, 21 Aug 2009 19:20:44 -0700
Message-ID: <1250907650-24672-2-git-send-email-mchan@broadcom.com>
References: <1250907650-24672-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4813 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933149AbZHVCNr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Aug 2009 22:13:47 -0400
In-Reply-To: <1250907650-24672-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add this check to bnx2_netif_stop() and bnx2_vlan_rx_register() to
prevent bus lockups on some systems when the chip is in low power state.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index e75b6e9..9cfd460 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -619,6 +619,9 @@ bnx2_disable_int_sync(struct bnx2 *bp)
 	int i;
 
 	atomic_inc(&bp->intr_sem);
+	if (!netif_running(bp->dev))
+		return;
+
 	bnx2_disable_int(bp);
 	for (i = 0; i < bp->irq_nvecs; i++)
 		synchronize_irq(bp->irq_tbl[i].vector);
@@ -6254,9 +6257,14 @@ bnx2_vlan_rx_register(struct net_device *dev, struct vlan_group *vlgrp)
 {
 	struct bnx2 *bp = netdev_priv(dev);
 
-	bnx2_netif_stop(bp);
+	if (netif_running(dev))
+		bnx2_netif_stop(bp);
 
 	bp->vlgrp = vlgrp;
+
+	if (!netif_running(dev))
+		return;
+
 	bnx2_set_rx_mode(dev);
 	if (bp->flags & BNX2_FLAG_CAN_KEEP_VLAN)
 		bnx2_fw_sync(bp, BNX2_DRV_MSG_CODE_KEEP_VLAN_UPDATE, 0, 1);
-- 
1.5.6.GIT


