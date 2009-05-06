From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] igb: resolve panic on shutdown when SR-IOV is enabled
Date: Wed, 06 May 2009 13:27:51 -0700
Message-ID: <20090506202749.17405.13051.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta15.emeryville.ca.mail.comcast.net ([76.96.27.228]:46298
	"EHLO QMTA15.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757492AbZEFU2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 16:28:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The setup_rctl call was making a call into the ring structure after it had
been freed.  This was causing a panic on shutdown.  This call wasn't
necessary since it is possible to get the needed index from
adapter->vfs_allocated_count.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   12 +++++-------
 1 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 08c8014..e253435 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -2006,7 +2006,7 @@ static void igb_setup_rctl(struct igb_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 	u32 rctl;
 	u32 srrctl = 0;
-	int i, j;
+	int i;
 
 	rctl = rd32(E1000_RCTL);
 
@@ -2071,8 +2071,6 @@ static void igb_setup_rctl(struct igb_adapter *adapter)
 	if (adapter->vfs_allocated_count) {
 		u32 vmolr;
 
-		j = adapter->rx_ring[0].reg_idx;
-
 		/* set all queue drop enable bits */
 		wr32(E1000_QDE, ALL_QUEUES);
 		srrctl |= E1000_SRRCTL_DROP_EN;
@@ -2080,16 +2078,16 @@ static void igb_setup_rctl(struct igb_adapter *adapter)
 		/* disable queue 0 to prevent tail write w/o re-config */
 		wr32(E1000_RXDCTL(0), 0);
 
-		vmolr = rd32(E1000_VMOLR(j));
+		vmolr = rd32(E1000_VMOLR(adapter->vfs_allocated_count));
 		if (rctl & E1000_RCTL_LPE)
 			vmolr |= E1000_VMOLR_LPE;
-		if (adapter->num_rx_queues > 0)
+		if (adapter->num_rx_queues > 1)
 			vmolr |= E1000_VMOLR_RSSE;
-		wr32(E1000_VMOLR(j), vmolr);
+		wr32(E1000_VMOLR(adapter->vfs_allocated_count), vmolr);
 	}
 
 	for (i = 0; i < adapter->num_rx_queues; i++) {
-		j = adapter->rx_ring[i].reg_idx;
+		int j = adapter->rx_ring[i].reg_idx;
 		wr32(E1000_SRRCTL(j), srrctl);
 	}
 

