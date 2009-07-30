From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 1/3] ixgbe: Fix netpoll to be properly multiqueue aware
Date: Thu, 30 Jul 2009 15:25:09 -0700
Message-ID: <20090730222501.26121.2952.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.emeryville.ca.mail.comcast.net ([76.96.30.40]:38691 "EHLO
	QMTA04.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752163AbZG3WZ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 18:25:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

Our ndo_poll_controller callback is broken for anything but non-multiqueue
setups.  This fixes that issue.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 200454f..60c4a8b 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -5360,12 +5360,19 @@ static int ixgbe_del_sanmac_netdev(struct net_device *dev)
 static void ixgbe_netpoll(struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	int i;
 
-	disable_irq(adapter->pdev->irq);
 	adapter->flags |= IXGBE_FLAG_IN_NETPOLL;
-	ixgbe_intr(adapter->pdev->irq, netdev);
+	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
+		int num_q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
+		for (i = 0; i < num_q_vectors; i++) {
+			struct ixgbe_q_vector *q_vector = adapter->q_vector[i];
+			ixgbe_msix_clean_many(0, q_vector);
+		}
+	} else {
+		ixgbe_intr(adapter->pdev->irq, netdev);
+	}
 	adapter->flags &= ~IXGBE_FLAG_IN_NETPOLL;
-	enable_irq(adapter->pdev->irq);
 }
 #endif
 

