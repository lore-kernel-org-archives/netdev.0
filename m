From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH] smsc9420: prevent BUG() if ethtool is called with interface down
Date: Wed, 25 Nov 2009 16:21:56 +0000
Message-ID: <1259166116-5036-1-git-send-email-steve.glendinning@smsc.com>
Cc: Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 77-44-110-64.xdsl.murphx.net ([77.44.110.64]:44049 "EHLO
	drevil2.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752637AbZKYQaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 11:30:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a null pointer dereference BUG() if ethtool is used on
an smsc9420 interface while it is down, because the phy_dev is only
allocated while the interface is up.

Please also consider for -stable.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/smsc9420.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/drivers/net/smsc9420.c b/drivers/net/smsc9420.c
index 92e2bbe..12f0f5d 100644
--- a/drivers/net/smsc9420.c
+++ b/drivers/net/smsc9420.c
@@ -252,6 +252,9 @@ static int smsc9420_ethtool_get_settings(struct net_device *dev,
 {
 	struct smsc9420_pdata *pd = netdev_priv(dev);
 
+	if (!pd->phy_dev)
+		return -ENODEV;
+
 	cmd->maxtxpkt = 1;
 	cmd->maxrxpkt = 1;
 	return phy_ethtool_gset(pd->phy_dev, cmd);
@@ -262,6 +265,9 @@ static int smsc9420_ethtool_set_settings(struct net_device *dev,
 {
 	struct smsc9420_pdata *pd = netdev_priv(dev);
 
+	if (!pd->phy_dev)
+		return -ENODEV;
+
 	return phy_ethtool_sset(pd->phy_dev, cmd);
 }
 
@@ -290,6 +296,10 @@ static void smsc9420_ethtool_set_msglevel(struct net_device *netdev, u32 data)
 static int smsc9420_ethtool_nway_reset(struct net_device *netdev)
 {
 	struct smsc9420_pdata *pd = netdev_priv(netdev);
+
+	if (!pd->phy_dev)
+		return -ENODEV;
+
 	return phy_start_aneg(pd->phy_dev);
 }
 
@@ -312,6 +322,10 @@ smsc9420_ethtool_getregs(struct net_device *dev, struct ethtool_regs *regs,
 	for (i = 0; i < 0x100; i += (sizeof(u32)))
 		data[j++] = smsc9420_reg_read(pd, i);
 
+	// cannot read phy registers if the net device is down
+	if (!phy_dev)
+		return;
+
 	for (i = 0; i <= 31; i++)
 		data[j++] = smsc9420_mii_read(phy_dev->bus, phy_dev->addr, i);
 }
-- 
1.6.2.5

