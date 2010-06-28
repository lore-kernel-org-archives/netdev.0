From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH -next] netxen: fail when try to setup unsupported features
Date: Mon, 28 Jun 2010 11:33:29 +0200
Message-ID: <20100628113329.3206bdbe@dhcp-lab-109.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Amerigo Wang <amwang@redhat.com>,
	Amit Kumar Salecha <amit.salecha@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63528 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750867Ab0F1Jdm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jun 2010 05:33:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
 drivers/net/netxen/netxen_nic_ethtool.c |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index 20f7c58..6d94ee5 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -887,12 +887,19 @@ static int netxen_nic_set_flags(struct net_device *netdev, u32 data)
 	struct netxen_adapter *adapter = netdev_priv(netdev);
 	int hw_lro;
 
+	if (data & ~ETH_FLAG_LRO)
+		return -EOPNOTSUPP;
+
 	if (!(adapter->capabilities & NX_FW_CAPABILITY_HW_LRO))
 		return -EINVAL;
 
-	ethtool_op_set_flags(netdev, data);
-
-	hw_lro = (data & ETH_FLAG_LRO) ? NETXEN_NIC_LRO_ENABLED : 0;
+	if (data & ETH_FLAG_LRO) {
+		hw_lro = NETXEN_NIC_LRO_ENABLED;
+		netdev->features |= NETIF_F_LRO;
+	} else {
+		hw_lro = 0;
+		netdev->features &= ~NETIF_F_LRO;
+	}
 
 	if (netxen_config_hw_lro(adapter, hw_lro))
 		return -EIO;
-- 
1.5.5.6

