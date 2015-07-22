From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next] cxgb4: Allow firmware flash, only if cxgb4 is the master driver
Date: Wed, 22 Jul 2015 22:54:50 +0530
Message-ID: <1437585890-7405-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:26146 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S934024AbbGVMKh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 08:10:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adapter can go for a toss, if cxgb4 is loaded as slave and we try to
upgrade the firmware. So add a check for the same before flashing
firmware using ethtool.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
index 687acf7..5eedb98 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
@@ -925,6 +925,20 @@ static int set_flash(struct net_device *netdev, struct ethtool_flash *ef)
 	const struct firmware *fw;
 	struct adapter *adap = netdev2adap(netdev);
 	unsigned int mbox = PCIE_FW_MASTER_M + 1;
+	u32 pcie_fw;
+	unsigned int master;
+	u8 master_vld = 0;
+
+	pcie_fw = t4_read_reg(adap, PCIE_FW_A);
+	master = PCIE_FW_MASTER_G(pcie_fw);
+	if (pcie_fw & PCIE_FW_MASTER_VLD_F)
+		master_vld = 1;
+	/* if csiostor is the master return */
+	if (master_vld && (master != adap->pf)) {
+		dev_warn(adap->pdev_dev,
+			 "cxgb4 driver needs to be loaded as MASTER to support FW flash\n");
+		return -EOPNOTSUPP;
+	}
 
 	ef->data[sizeof(ef->data) - 1] = '\0';
 	ret = request_firmware(&fw, ef->data, adap->pdev_dev);
-- 
2.3.4
