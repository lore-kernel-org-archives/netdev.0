From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH] smsc9420: add ethtool register dump support
Date: Fri, 12 Dec 2008 08:57:32 +0000
Message-ID: <1229072252-7188-1-git-send-email-steve.glendinning@smsc.com>
Cc: Vlad Lyalikov <vlad.lyalikov@smsc.com>,
	Ian Saturley <ian.saturley@smsc.com>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [86.54.240.115] ([86.54.240.115]:60175 "EHLO
	drevil2.shawell.net" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750719AbYLLI5a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 03:57:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for SMSC's LAN9420 PCI ethernet controller
to ethtool's dump registers (-d) command.

This patch is for use with an accompanying ethtool patch, which decodes
the register dump.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/smsc9420.c |   25 +++++++++++++++++++++++++
 1 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/drivers/net/smsc9420.c b/drivers/net/smsc9420.c
index 2a8e9b7..bc9879d 100644
--- a/drivers/net/smsc9420.c
+++ b/drivers/net/smsc9420.c
@@ -293,6 +293,29 @@ static int smsc9420_ethtool_nway_reset(struct net_device *netdev)
 	return phy_start_aneg(pd->phy_dev);
 }
 
+static int smsc9420_ethtool_getregslen(struct net_device *dev)
+{
+	/* all smsc9420 registers plus all phy registers */
+	return 0x100 + (32 * sizeof(u32));
+}
+
+static void
+smsc9420_ethtool_getregs(struct net_device *dev, struct ethtool_regs *regs,
+			 void *buf)
+{
+	struct smsc9420_pdata *pd = netdev_priv(dev);
+	struct phy_device *phy_dev = pd->phy_dev;
+	unsigned int i, j = 0;
+	u32 *data = buf;
+
+	regs->version = smsc9420_reg_read(pd, ID_REV);
+	for (i = 0; i < 0x100; i += (sizeof(u32)))
+		data[j++] = smsc9420_reg_read(pd, i);
+
+	for (i = 0; i <= 31; i++)
+		data[j++] = smsc9420_mii_read(phy_dev->bus, phy_dev->addr, i);
+}
+
 static void smsc9420_eeprom_enable_access(struct smsc9420_pdata *pd)
 {
 	unsigned int temp = smsc9420_reg_read(pd, GPIO_CFG);
@@ -422,6 +445,8 @@ static const struct ethtool_ops smsc9420_ethtool_ops = {
 	.get_eeprom_len = smsc9420_ethtool_get_eeprom_len,
 	.get_eeprom = smsc9420_ethtool_get_eeprom,
 	.set_eeprom = smsc9420_ethtool_set_eeprom,
+	.get_regs_len = smsc9420_ethtool_getregslen,
+	.get_regs = smsc9420_ethtool_getregs,
 };
 
 /* Sets the device MAC address to dev_addr */
-- 
1.5.6.5

