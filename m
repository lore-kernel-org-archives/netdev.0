From: Stefan Roese <sr@denx.de>
Subject: [PATCH] net: EMAC: Fix problem with mtu > 4080 on non TAH equipped 4xx PPC's
Date: Tue, 15 Jan 2008 13:40:09 +0100
Message-ID: <1200400809-19720-1-git-send-email-sr@denx.de>
Cc: ebs@ebshome.net, benh@kernel.crashing.org
To: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.188]:61669 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752483AbYAOMkc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 07:40:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, all non TAH equipped 4xx PPC's call emac_start_xmit() upon
xmit. This routine doesn't check if the frame length exceeds the max.
MAL buffer size.

This patch now changes the driver to call emac_start_xmit_sg() on all
platforms and not only the TAH equipped ones (440GX). This enables an
MTU of 9000 instead 4080.

Tested on Kilauea (405EX) with gbit link -> jumbo frames enabled.

Signed-off-by: Stefan Roese <sr@denx.de>
---
Eugene & Ben, do you see any problems with this patch? If not, then I'll
send another version for the newemac driver too.

Thanks.

 drivers/net/ibm_emac/ibm_emac_core.c |   10 ++--------
 1 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ibm_emac/ibm_emac_core.c b/drivers/net/ibm_emac/ibm_emac_core.c
index 73664f2..198de44 100644
--- a/drivers/net/ibm_emac/ibm_emac_core.c
+++ b/drivers/net/ibm_emac/ibm_emac_core.c
@@ -1089,7 +1089,6 @@ static int emac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	return emac_xmit_finish(dev, len);
 }
 
-#if defined(CONFIG_IBM_EMAC_TAH)
 static inline int emac_xmit_split(struct ocp_enet_private *dev, int slot,
 				  u32 pd, int len, int last, u16 base_ctrl)
 {
@@ -1203,9 +1202,6 @@ static int emac_start_xmit_sg(struct sk_buff *skb, struct net_device *ndev)
 	DBG2("%d: stopped TX queue" NL, dev->def->index);
 	return 1;
 }
-#else
-# define emac_start_xmit_sg	emac_start_xmit
-#endif	/* !defined(CONFIG_IBM_EMAC_TAH) */
 
 /* BHs disabled */
 static void emac_parse_tx_error(struct ocp_enet_private *dev, u16 ctrl)
@@ -2163,11 +2159,9 @@ static int __init emac_probe(struct ocp_device *ocpdev)
 
 	/* Fill in the driver function table */
 	ndev->open = &emac_open;
-	if (dev->tah_dev) {
-		ndev->hard_start_xmit = &emac_start_xmit_sg;
+	ndev->hard_start_xmit = &emac_start_xmit_sg;
+	if (dev->tah_dev)
 		ndev->features |= NETIF_F_IP_CSUM | NETIF_F_SG;
-	} else
-		ndev->hard_start_xmit = &emac_start_xmit;
 	ndev->tx_timeout = &emac_full_tx_reset;
 	ndev->watchdog_timeo = 5 * HZ;
 	ndev->stop = &emac_close;
-- 
1.5.4.rc3

