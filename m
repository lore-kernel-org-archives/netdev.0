From: Amit Salecha <amit.salecha@qlogic.com>
Subject: RE: [PATCH -next] qlcnic: fail when try to setup unsupported
 features
Date: Mon, 28 Jun 2010 07:36:04 -0500
Message-ID: <99737F4847ED0A48AECC9F4A1974A4B80F82CB7D46@MNEXMB2.qlogic.org>
References: <20100628113134.0c5208b0@dhcp-lab-109.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Amerigo Wang <amwang@redhat.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: Stanislaw Gruszka <sgruszka@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexcashub1.qlogic.com ([198.70.193.61]:29808 "EHLO
	avexcashub1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752410Ab0F1MgJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jun 2010 08:36:09 -0400
In-Reply-To: <20100628113134.0c5208b0@dhcp-lab-109.englab.brq.redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

Above hunk is unnecessary.

-Amit

-----Original Message-----
From: Stanislaw Gruszka [mailto:sgruszka@redhat.com] 
Sent: Monday, June 28, 2010 3:02 PM
To: netdev@vger.kernel.org
Cc: Amerigo Wang; Amit Salecha; Anirban Chakraborty
Subject: [PATCH -next] qlcnic: fail when try to setup unsupported features

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

