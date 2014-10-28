From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 1/2] net: systemport: enable RX interrupts after NAPI
Date: Tue, 28 Oct 2014 11:12:00 -0700
Message-ID: <1414519921-3246-2-git-send-email-f.fainelli@gmail.com>
References: <1414519921-3246-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:53279 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751591AbaJ1SMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 14:12:32 -0400
Received: by mail-pd0-f177.google.com with SMTP id v10so1204418pde.8
        for <netdev@vger.kernel.org>; Tue, 28 Oct 2014 11:12:31 -0700 (PDT)
In-Reply-To: <1414519921-3246-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is currently a small window during which the SYSTEMPORT adapter
enables its RX interrupts without having enabled its NAPI handler, which
can result in packets to be discarded during interface bringup.

A similar but more serious window exists in bcm_sysport_resume() during
which we can have the RDMA engine not fully prepared to receive packets
and yet having RX interrupts enabled.

Fix this my moving the RX interrupt enable down to
bcm_sysport_netif_start() after napi_enable() for the RX path is called,
which fixes both call sites: bcm_sysport_open() and
bcm_sysport_resume().

Fixes: b02e6d9ba7ad ("net: systemport: add bcm_sysport_netif_{enable,stop}")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 9ae36979bdee..7dce91189e51 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -1397,6 +1397,9 @@ static void bcm_sysport_netif_start(struct net_device *dev)
 	/* Enable NAPI */
 	napi_enable(&priv->napi);
 
+	/* Enable RX interrupt and TX ring full interrupt */
+	intrl2_0_mask_clear(priv, INTRL2_0_RDMA_MBDONE | INTRL2_0_TX_RING_FULL);
+
 	phy_start(priv->phydev);
 
 	/* Enable TX interrupts for the 32 TXQs */
@@ -1499,9 +1502,6 @@ static int bcm_sysport_open(struct net_device *dev)
 	if (ret)
 		goto out_free_rx_ring;
 
-	/* Enable RX interrupt and TX ring full interrupt */
-	intrl2_0_mask_clear(priv, INTRL2_0_RDMA_MBDONE | INTRL2_0_TX_RING_FULL);
-
 	/* Turn on TDMA */
 	ret = tdma_enable_set(priv, 1);
 	if (ret)
@@ -1885,9 +1885,6 @@ static int bcm_sysport_resume(struct device *d)
 
 	netif_device_attach(dev);
 
-	/* Enable RX interrupt and TX ring full interrupt */
-	intrl2_0_mask_clear(priv, INTRL2_0_RDMA_MBDONE | INTRL2_0_TX_RING_FULL);
-
 	/* RX pipe enable */
 	topctrl_writel(priv, 0, RX_FLUSH_CNTL);
 
-- 
1.9.1
