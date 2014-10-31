From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 2/2] net: systemport: do not crash freeing an unitialized TX ring
Date: Fri, 31 Oct 2014 15:51:35 -0700
Message-ID: <1414795895-31612-3-git-send-email-f.fainelli@gmail.com>
References: <1414795895-31612-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:47009 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757265AbaJaWwd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2014 18:52:33 -0400
Received: by mail-pa0-f41.google.com with SMTP id rd3so8571831pab.14
        for <netdev@vger.kernel.org>; Fri, 31 Oct 2014 15:52:33 -0700 (PDT)
In-Reply-To: <1414795895-31612-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Callers of bcm_sysport_init_tx_ring() can currently fail, and will
always call bcm_sysport_fini_tx_ring() in a loop ending at the number of
TX queues (32) without checking if the TX ring was successfully
initialized or not.

Update bcm_sysport_fini_tx_ring() to return early and avoid a crash
de-referencing ring->cbs if the TX ring was not initialized, since
ring->cbs is the last part of the initialization done by
bcm_sysport_init_tx_ring() that could fail.

Fixes: 80105befdb4b ("net: systemport: add Broadcom SYSTEMPORT Ethernet MAC driver")
Reported-by: Maxime Bizon <mbizon@freebox.fr>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index c81bf74685c0..531bb7c57531 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -1175,6 +1175,13 @@ static void bcm_sysport_fini_tx_ring(struct bcm_sysport_priv *priv,
 	if (!(reg & TDMA_DISABLED))
 		netdev_warn(priv->netdev, "TDMA not stopped!\n");
 
+	/* ring->cbs is the last part in bcm_sysport_init_tx_ring which could
+	 * fail, so by checking this pointer we know whether the TX ring was
+	 * fully initialized or not.
+	 */
+	if (!ring->cbs)
+		return;
+
 	napi_disable(&ring->napi);
 	netif_napi_del(&ring->napi);
 
-- 
1.9.1
