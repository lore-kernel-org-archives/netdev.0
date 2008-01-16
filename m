From: Stefan Roese <sr@denx.de>
Subject: [PATCH] net: EMAC: Fix problem with mtu > 4080 on non TAH equipped 4xx PPC's
Date: Wed, 16 Jan 2008 08:10:24 +0100
Message-ID: <1200467424-1616-1-git-send-email-sr@denx.de>
Cc: ebs@ebshome.net
To: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:50857 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752883AbYAPHLS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2008 02:11:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, all non TAH equipped 4xx PPC's call emac_start_xmit() upon
xmit. This routine doesn't check if the frame length exceeds the max.
MAL buffer size.

This patch now changes the driver to call emac_start_xmit_sg() on all
GigE platforms and not only the TAH equipped ones (440GX). This enables
an MTU of 9000 instead 4080.

Tested on Kilauea (405EX) with GigE link -> jumbo frames enabled.

Signed-off-by: Stefan Roese <sr@denx.de>
---
 drivers/net/ibm_emac/ibm_emac_core.c |   12 ++++--------
 1 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ibm_emac/ibm_emac_core.c b/drivers/net/ibm_emac/ibm_emac_core.c
index 73664f2..8d1901e 100644
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
@@ -2163,11 +2159,8 @@ static int __init emac_probe(struct ocp_device *ocpdev)
 
 	/* Fill in the driver function table */
 	ndev->open = &emac_open;
-	if (dev->tah_dev) {
-		ndev->hard_start_xmit = &emac_start_xmit_sg;
+	if (dev->tah_dev)
 		ndev->features |= NETIF_F_IP_CSUM | NETIF_F_SG;
-	} else
-		ndev->hard_start_xmit = &emac_start_xmit;
 	ndev->tx_timeout = &emac_full_tx_reset;
 	ndev->watchdog_timeo = 5 * HZ;
 	ndev->stop = &emac_close;
@@ -2175,8 +2168,11 @@ static int __init emac_probe(struct ocp_device *ocpdev)
 	ndev->set_multicast_list = &emac_set_multicast_list;
 	ndev->do_ioctl = &emac_ioctl;
 	if (emac_phy_supports_gige(emacdata->phy_mode)) {
+		ndev->hard_start_xmit = &emac_start_xmit_sg;
 		ndev->change_mtu = &emac_change_mtu;
 		dev->commac.ops = &emac_commac_sg_ops;
+	} else {
+		ndev->hard_start_xmit = &emac_start_xmit;
 	}
 	SET_ETHTOOL_OPS(ndev, &emac_ethtool_ops);
 
-- 
1.5.4.rc3

