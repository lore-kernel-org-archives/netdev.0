From: =?utf-8?Q?=C3=89meric?= Vigier
	<emeric.vigier@savoirfairelinux.com>
Subject: [PATCH] smsc95xx: support ethtool get_regs
Date: Fri, 6 Jul 2012 14:15:31 -0400 (EDT)
Message-ID: <1847398984.224080.1341598531284.JavaMail.root@mail.savoirfairelinux.com>
References: <1291035348.223127.1341596173191.JavaMail.root@mail.savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Nancy Lin <nancy.lin@smsc.com>
To: Steve Glendinning <steve@shawell.net>,
	steve glendinning <steve.glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:60299 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756118Ab2GFSPd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 14:15:33 -0400
In-Reply-To: <1291035348.223127.1341596173191.JavaMail.root@mail.savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emeric Vigier <emeric.vigier@savoirfairelinux.com>

Inspired by implementation in smsc911x.c and smsc9420.c
Tested on ARM/pandaboard rev A3

Signed-off-by: Emeric Vigier <emeric.vigier@savoirfairelinux.com>
---
 drivers/net/usb/smsc95xx.c |   37 +++++++++++++++++++++++++++++++++++++
 1 files changed, 37 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index b1112e7..bce14f6 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -578,6 +578,41 @@ static int smsc95xx_ethtool_set_eeprom(struct net_device *netdev,
 	return smsc95xx_write_eeprom(dev, ee->offset, ee->len, data);
 }
 
+
+static int smsc95xx_ethtool_getregslen(struct net_device *dev)
+{
+	/* all smsc95xx registers plus all phy registers */
+	return COE_CR - ID_REV + 1 + 32 * sizeof(u32);
+}
+
+static void
+smsc95xx_ethtool_getregs(struct net_device *netdev, struct ethtool_regs *regs,
+			 void *buf)
+{
+	struct usbnet *dev = netdev_priv(netdev);
+	unsigned int i, j = 0, retval;
+	u32 *data = buf;
+
+	netif_dbg(dev, hw, dev->net, "ethtool_getregs\n");
+
+	retval = smsc95xx_read_reg(dev, ID_REV, &regs->version);
+	if (retval < 0) {
+		netdev_warn(dev->net, "REGS: cannot read ID_REV\n");
+		return;
+	}
+
+	for (i = 0; i <= COE_CR; i += (sizeof(u32))) {
+		retval = smsc95xx_read_reg(dev, i, &data[j++]);
+		if (retval < 0) {
+			netdev_warn(dev->net, "REGS: cannot read reg[%x]\n", i);
+			return;
+		}
+	}
+
+	for (i = 0; i <= PHY_SPECIAL; i++)
+		data[j++] = smsc95xx_mdio_read(netdev, dev->mii.phy_id, i);
+}
+
 static const struct ethtool_ops smsc95xx_ethtool_ops = {
 	.get_link	= usbnet_get_link,
 	.nway_reset	= usbnet_nway_reset,
@@ -589,6 +624,8 @@ static const struct ethtool_ops smsc95xx_ethtool_ops = {
 	.get_eeprom_len	= smsc95xx_ethtool_get_eeprom_len,
 	.get_eeprom	= smsc95xx_ethtool_get_eeprom,
 	.set_eeprom	= smsc95xx_ethtool_set_eeprom,
+	.get_regs_len	= smsc95xx_ethtool_getregslen,
+	.get_regs	= smsc95xx_ethtool_getregs,
 };
 
 static int smsc95xx_ioctl(struct net_device *netdev, struct ifreq *rq, int cmd)
-- 
1.7.5.4

Emeric
