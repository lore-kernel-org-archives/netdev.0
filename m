From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 3/3] igbvf: fix memory leak when ring size changed
	while interface down
Date: Mon, 26 Oct 2009 14:32:25 -0700
Message-ID: <20091026213225.9993.25681.stgit@localhost.localdomain>
References: <20091026213147.9993.9778.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta12.emeryville.ca.mail.comcast.net ([76.96.27.227]:57087
	"EHLO QMTA12.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753912AbZJZVgA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 17:36:00 -0400
In-Reply-To: <20091026213147.9993.9778.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch resolves a memory leak which occurs while changing the ring size
while the interface is down.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igbvf/ethtool.c |   30 +++++++++++++++++-------------
 1 files changed, 17 insertions(+), 13 deletions(-)

diff --git a/drivers/net/igbvf/ethtool.c b/drivers/net/igbvf/ethtool.c
index ee17a09..c68265b 100644
--- a/drivers/net/igbvf/ethtool.c
+++ b/drivers/net/igbvf/ethtool.c
@@ -279,7 +279,7 @@ static int igbvf_set_ringparam(struct net_device *netdev,
 {
 	struct igbvf_adapter *adapter = netdev_priv(netdev);
 	struct igbvf_ring *temp_ring;
-	int err;
+	int err = 0;
 	u32 new_rx_count, new_tx_count;
 
 	if ((ring->rx_mini_pending) || (ring->rx_jumbo_pending))
@@ -299,15 +299,22 @@ static int igbvf_set_ringparam(struct net_device *netdev,
 		return 0;
 	}
 
-	temp_ring = vmalloc(sizeof(struct igbvf_ring));
-	if (!temp_ring)
-		return -ENOMEM;
-
 	while (test_and_set_bit(__IGBVF_RESETTING, &adapter->state))
 		msleep(1);
 
-	if (netif_running(adapter->netdev))
-		igbvf_down(adapter);
+	if (!netif_running(adapter->netdev)) {
+		adapter->tx_ring->count = new_tx_count;
+		adapter->rx_ring->count = new_rx_count;
+		goto clear_reset;
+	}
+
+	temp_ring = vmalloc(sizeof(struct igbvf_ring));
+	if (!temp_ring) {
+		err = -ENOMEM;
+		goto clear_reset;
+	}
+
+	igbvf_down(adapter);
 
 	/*
 	 * We can't just free everything and then setup again,
@@ -339,14 +346,11 @@ static int igbvf_set_ringparam(struct net_device *netdev,
 
 		memcpy(adapter->rx_ring, temp_ring,sizeof(struct igbvf_ring));
 	}
-
-	err = 0;
 err_setup:
-	if (netif_running(adapter->netdev))
-		igbvf_up(adapter);
-
-	clear_bit(__IGBVF_RESETTING, &adapter->state);
+	igbvf_up(adapter);
 	vfree(temp_ring);
+clear_reset:
+	clear_bit(__IGBVF_RESETTING, &adapter->state);
 	return err;
 }
 

