From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCHv1 (Repost)] bnx2x: Allow ethtool to enable/disable loopback.
Date: Fri, 13 May 2011 18:08:49 -0700
Message-ID: <1305335329-32700-1-git-send-email-maheshb@google.com>
References: <1304472033-510-1-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>, Tom Herbert <therbert@google.com>,
	Mahesh Bandewar <maheshb@google.com>
To: Eilon Greenstein <eilong@broadcom.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:37701 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765Ab1ENBI4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 21:08:56 -0400
In-Reply-To: <1304472033-510-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the bnx2x_set_features() to handle loopback mode.
When enabled; it sets internal-MAC loopback.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/bnx2x/bnx2x_cmn.c  |   16 ++++++++++++++++
 drivers/net/bnx2x/bnx2x_main.c |    3 +++
 2 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index 8729061..e944d2a 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -2506,15 +2506,31 @@ int bnx2x_set_features(struct net_device *dev, u32 features)
 {
 	struct bnx2x *bp = netdev_priv(dev);
 	u32 flags = bp->flags;
+	bool bnx2x_reload = false;
 
 	if (features & NETIF_F_LRO)
 		flags |= TPA_ENABLE_FLAG;
 	else
 		flags &= ~TPA_ENABLE_FLAG;
 
+	if (features & NETIF_F_LOOPBACK) {
+		if (bp->link_params.loopback_mode != LOOPBACK_BMAC) {
+			bp->link_params.loopback_mode = LOOPBACK_BMAC;
+			bnx2x_reload = true;
+		}
+	} else {
+		if (bp->link_params.loopback_mode != LOOPBACK_NONE) {
+			bp->link_params.loopback_mode = LOOPBACK_NONE;
+			bnx2x_reload = true;
+		}
+	}
+
 	if (flags ^ bp->flags) {
 		bp->flags = flags;
+		bnx2x_reload = true;
+	}
 
+	if (bnx2x_reload) {
 		if (bp->recovery_state == BNX2X_RECOVERY_DONE)
 			return bnx2x_reload_if_running(dev);
 		/* else: bnx2x_nic_load() will be called at end of recovery */
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index bfd7ac9..2c6b5e2 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -9435,6 +9435,9 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 	if (bp->flags & USING_DAC_FLAG)
 		dev->features |= NETIF_F_HIGHDMA;
 
+	/* Add Loopback capability to the device */
+	dev->hw_features |= NETIF_F_LOOPBACK;
+
 #ifdef BCM_DCBNL
 	dev->dcbnl_ops = &bnx2x_dcbnl_ops;
 #endif
-- 
1.7.3.1

