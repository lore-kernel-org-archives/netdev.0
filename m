From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH -next] qlcnic: fail when try to setup unsupported features
Date: Mon, 28 Jun 2010 11:31:34 +0200
Message-ID: <20100628113134.0c5208b0@dhcp-lab-109.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Amerigo Wang <amwang@redhat.com>,
	Amit Kumar Salecha <amit.salecha@qlogic.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50537 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751313Ab0F1Jbm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jun 2010 05:31:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
 drivers/net/qlcnic/qlcnic_ethtool.c |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index d4e803e..b9d5acb 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -983,12 +983,19 @@ static int qlcnic_set_flags(struct net_device *netdev, u32 data)
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	int hw_lro;
 
+	if (data & ~ETH_FLAG_LRO)
+		return -EOPNOTSUPP;
+
 	if (!(adapter->capabilities & QLCNIC_FW_CAPABILITY_HW_LRO))
 		return -EINVAL;
 
-	ethtool_op_set_flags(netdev, data);
-
-	hw_lro = (data & ETH_FLAG_LRO) ? QLCNIC_LRO_ENABLED : 0;
+	if (data & ETH_FLAG_LRO) {
+		hw_lro = QLCNIC_LRO_ENABLED;
+		netdev->features |= NETIF_F_LRO;
+	} else {
+		hw_lro = 0;
+		netdev->features &= ~NETIF_F_LRO;
+	}
 
 	if (qlcnic_config_hw_lro(adapter, hw_lro))
 		return -EIO;
-- 
1.5.5.6

