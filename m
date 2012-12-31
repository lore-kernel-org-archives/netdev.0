From: Andreas Mohr <andi@lisas.de>
Subject: [PATCH RFC 12/15] via-rhine: implement get_regs() ethtool ops.
Date: Mon, 31 Dec 2012 16:25:46 +0100
Message-ID: <1356967549-5056-13-git-send-email-andi@lisas.de>
References: <1356967549-5056-1-git-send-email-andi@lisas.de>
Cc: Roger Luethi <rl@hellgate.ch>, netdev@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>
To: andim2@users.sf.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhlx01.hs-esslingen.de ([129.143.116.10]:54115 "EHLO
	rhlx01.hs-esslingen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751374Ab2LaPep (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2012 10:34:45 -0500
In-Reply-To: <1356967549-5056-1-git-send-email-andi@lisas.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Mohr <andim2@users.sf.net>

Quite useful to pinpoint pre-suspend vs. post-resume register mismatches.
Adds io_size member for use in rhine_ethop_get_regs_len().

Signed-off-by: Andreas Mohr <andim2@users.sf.net>
---
 drivers/net/ethernet/via/via-rhine.c |   40 ++++++++++++++++++++++++++++++++++
 1 files changed, 40 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 8950eb0..90d109a 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -452,6 +452,7 @@ struct rhine_private {
 	struct work_struct reset_task;
 
 	u32 msg_enable;
+	int io_size;
 
 	/* Frequently used values: keep some adjacent for cache effect. */
 	u32 quirks;
@@ -1001,6 +1002,7 @@ static int rhine_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	rp = netdev_priv(dev);
 	rp->dev = dev;
+	rp->io_size = io_size;
 	rp->quirks = quirks;
 	rp->pioaddr = pioaddr;
 	rp->pdev = pdev;
@@ -2199,6 +2201,42 @@ static void netdev_set_msglevel(struct net_device *dev, u32 value)
 	rp->msg_enable = value;
 }
 
+/*
+ * ethtool get_regs() handlers.
+ * Use e.g. to pinpoint pre-suspend vs. post-resume register mismatches
+ * due to yet another all-too-frequent suspend/resume issue.
+ */
+static int
+rhine_ethop_get_regs_len(struct net_device *dev)
+{
+	struct rhine_private *rp = netdev_priv(dev);
+	return rp->io_size;
+}
+
+static void
+rhine_ethop_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *p)
+{
+	struct rhine_private *rp = netdev_priv(dev);
+	unsigned long flags;
+	void __iomem *ioaddr = rp->base;
+	u8 *p8 = (u8 *)p;
+	int len = regs->len;
+	int len_max = rhine_ethop_get_regs_len(dev);
+	int i = 0;
+
+	if (len > len_max)
+		len = len_max;
+
+	regs->version = 1;
+
+	memset(p, 0xFF, len);
+
+	spin_lock_irqsave(&rp->lock, flags);
+	for (i = 0; i < len; ++i)
+		p8[i] = ioread8(ioaddr + i);
+	spin_unlock_irqrestore(&rp->lock, flags);
+}
+
 /* Indicates the set of WOL features supported by this card rev. */
 static inline u32
 rhine_wol_support_bits_get(struct rhine_private *rp)
@@ -2241,6 +2279,8 @@ rhine_ethop_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 
 static const struct ethtool_ops netdev_ethtool_ops = {
 	.get_drvinfo		= netdev_get_drvinfo,
+	.get_regs_len		= rhine_ethop_get_regs_len,
+	.get_regs		= rhine_ethop_get_regs,
 	.get_settings		= netdev_get_settings,
 	.set_settings		= netdev_set_settings,
 	.nway_reset		= netdev_nway_reset,
-- 
1.7.2.5
