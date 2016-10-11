From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH 1/6] fjes: ethtool -d support for fjes driver
Date: Tue, 11 Oct 2016 17:54:54 +0900
Message-ID: <1476176094-18724-1-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1476176047-18670-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: Taku Izumi <izumi.taku@jp.fujitsu.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwkm03.jp.fujitsu.com ([202.219.69.170]:52371 "EHLO
        mgwkm03.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752634AbcJKJRZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2016 05:17:25 -0400
Received: from m3050.s.css.fujitsu.com (msm.b.css.fujitsu.com [10.134.21.208])
        by kw-mxq.gw.nic.fujitsu.com (Postfix) with ESMTP id B1A58AC00C2
        for <netdev@vger.kernel.org>; Tue, 11 Oct 2016 18:05:54 +0900 (JST)
In-Reply-To: <1476176047-18670-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds implementation of supporting
ethtool -d for fjes driver. By using ethtool -d,
you can get registers dump of Exetnded socket device.

  # ethtool -d es0

Offset          Values
------          ------
0x0000:         01 00 00 00 08 00 00 00 00 00 00 00 00 00 00 00
0x0010:         00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0x0020:         02 00 00 80 02 00 00 80 64 a6 58 08 07 00 00 00
0x0030:         00 00 00 00 28 80 00 00 00 00 f9 e3 06 00 00 00
0x0040:         00 00 00 00 18 00 00 00 80 a4 58 08 07 00 00 00
0x0050:         00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0x0060:         00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0x0070:         00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0x0080:         00 00 00 00 00 00 e0 7f 00 00 01 00 00 00 01 00
0x0090:         00 00 00 00

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/fjes/fjes_ethtool.c | 48 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 48 insertions(+)

diff --git a/drivers/net/fjes/fjes_ethtool.c b/drivers/net/fjes/fjes_ethtool.c
index 9c218e1..8397634 100644
--- a/drivers/net/fjes/fjes_ethtool.c
+++ b/drivers/net/fjes/fjes_ethtool.c
@@ -121,12 +121,60 @@ static int fjes_get_settings(struct net_device *netdev,
 	return 0;
 }
 
+static int fjes_get_regs_len(struct net_device *netdev)
+{
+#define FJES_REGS_LEN	37
+	return FJES_REGS_LEN * sizeof(u32);
+}
+
+static void fjes_get_regs(struct net_device *netdev,
+			  struct ethtool_regs *regs, void *p)
+{
+	struct fjes_adapter *adapter = netdev_priv(netdev);
+	struct fjes_hw *hw = &adapter->hw;
+	u32 *regs_buff = p;
+
+	memset(p, 0, FJES_REGS_LEN * sizeof(u32));
+
+	regs->version = 1;
+
+	/* Information registers */
+	regs_buff[0] = rd32(XSCT_OWNER_EPID);
+	regs_buff[1] = rd32(XSCT_MAX_EP);
+
+	/* Device Control registers */
+	regs_buff[4] = rd32(XSCT_DCTL);
+
+	/* Command Control registers */
+	regs_buff[8] = rd32(XSCT_CR);
+	regs_buff[9] = rd32(XSCT_CS);
+	regs_buff[10] = rd32(XSCT_SHSTSAL);
+	regs_buff[11] = rd32(XSCT_SHSTSAH);
+
+	regs_buff[13] = rd32(XSCT_REQBL);
+	regs_buff[14] = rd32(XSCT_REQBAL);
+	regs_buff[15] = rd32(XSCT_REQBAH);
+
+	regs_buff[17] = rd32(XSCT_RESPBL);
+	regs_buff[18] = rd32(XSCT_RESPBAL);
+	regs_buff[19] = rd32(XSCT_RESPBAH);
+
+	/* Interrupt Control registers */
+	regs_buff[32] = rd32(XSCT_IS);
+	regs_buff[33] = rd32(XSCT_IMS);
+	regs_buff[34] = rd32(XSCT_IMC);
+	regs_buff[35] = rd32(XSCT_IG);
+	regs_buff[36] = rd32(XSCT_ICTL);
+}
+
 static const struct ethtool_ops fjes_ethtool_ops = {
 		.get_settings		= fjes_get_settings,
 		.get_drvinfo		= fjes_get_drvinfo,
 		.get_ethtool_stats = fjes_get_ethtool_stats,
 		.get_strings      = fjes_get_strings,
 		.get_sset_count   = fjes_get_sset_count,
+		.get_regs		= fjes_get_regs,
+		.get_regs_len		= fjes_get_regs_len,
 };
 
 void fjes_set_ethtool_ops(struct net_device *netdev)
-- 
2.6.6
