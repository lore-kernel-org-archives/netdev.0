From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/3] ethtool: Move n-tuple capability check into
	set_flags
Date: Fri, 12 Feb 2010 15:48:25 -0800
Message-ID: <20100212234823.2346.32285.stgit@localhost.localdomain>
References: <20100212234715.2346.60380.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.emeryville.ca.mail.comcast.net ([76.96.30.40]:32888 "EHLO
	qmta04.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756165Ab0BLXsm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2010 18:48:42 -0500
In-Reply-To: <20100212234715.2346.60380.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>

set_flags should check if the underlying device supports
n-tuple filter programming before setting the device flags
on the netdevice.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 net/core/ethtool.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index fbbe4b4..794cf57 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -134,15 +134,21 @@ u32 ethtool_op_get_flags(struct net_device *dev)
 
 int ethtool_op_set_flags(struct net_device *dev, u32 data)
 {
+	const struct ethtool_ops *ops = dev->ethtool_ops;
+
 	if (data & ETH_FLAG_LRO)
 		dev->features |= NETIF_F_LRO;
 	else
 		dev->features &= ~NETIF_F_LRO;
 
-	if (data & ETH_FLAG_NTUPLE)
+	if (data & ETH_FLAG_NTUPLE) {
+		if (!ops->set_rx_ntuple)
+			return -EOPNOTSUPP;
 		dev->features |= NETIF_F_NTUPLE;
-	else
+	} else {
+		/* safe to clear regardless */
 		dev->features &= ~NETIF_F_NTUPLE;
+	}
 
 	return 0;
 }
@@ -318,9 +324,6 @@ static int ethtool_set_rx_ntuple(struct net_device *dev, void __user *useraddr)
 	struct ethtool_rx_ntuple_flow_spec_container *fsc = NULL;
 	int ret;
 
-	if (!ops->set_rx_ntuple)
-		return -EOPNOTSUPP;
-
 	if (!(dev->features & NETIF_F_NTUPLE))
 		return -EINVAL;
 

