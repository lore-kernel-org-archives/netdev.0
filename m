From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 15/23] igb: Remove invalid stats counters
Date: Wed, 28 Oct 2009 02:50:18 -0700
Message-ID: <20091028095018.13156.58845.stgit@localhost.localdomain>
References: <20091028094540.13156.2637.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.westchester.pa.mail.comcast.net ([76.96.62.64]:46447
	"EHLO QMTA07.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751499AbZJ1JyD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 05:54:03 -0400
In-Reply-To: <20091028094540.13156.2637.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

There are several counters being used like they are static when in fact
they are clear on read.  In order to prevent the values from being
incorrect I am removing the defunct counters.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb.h      |    6 ------
 drivers/net/igb/igb_main.c |   18 +-----------------
 2 files changed, 1 insertions(+), 23 deletions(-)

diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index c27dc1a..b9fcfd3 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -269,10 +269,6 @@ struct igb_adapter {
 	/* TX */
 	struct igb_ring *tx_ring;      /* One per active queue */
 	unsigned long tx_queue_len;
-	u32 gotc;
-	u64 gotc_old;
-	u64 tpt_old;
-	u64 colc_old;
 	u32 tx_timeout_count;
 
 	/* RX */
@@ -280,8 +276,6 @@ struct igb_adapter {
 	int num_tx_queues;
 	int num_rx_queues;
 
-	u32 gorc;
-	u64 gorc_old;
 	u32 max_frame_size;
 	u32 min_frame_size;
 
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 5b0f939..cb1acca 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -2925,9 +2925,6 @@ static void igb_watchdog_task(struct work_struct *work)
 	int i;
 
 	link = igb_has_link(adapter);
-	if ((netif_carrier_ok(netdev)) && link)
-		goto link_up;
-
 	if (link) {
 		if (!netif_carrier_ok(netdev)) {
 			u32 ctrl;
@@ -2990,20 +2987,8 @@ static void igb_watchdog_task(struct work_struct *work)
 		}
 	}
 
-link_up:
 	igb_update_stats(adapter);
-
-	hw->mac.tx_packet_delta = adapter->stats.tpt - adapter->tpt_old;
-	adapter->tpt_old = adapter->stats.tpt;
-	hw->mac.collision_delta = adapter->stats.colc - adapter->colc_old;
-	adapter->colc_old = adapter->stats.colc;
-
-	adapter->gorc = adapter->stats.gorc - adapter->gorc_old;
-	adapter->gorc_old = adapter->stats.gorc;
-	adapter->gotc = adapter->stats.gotc - adapter->gotc_old;
-	adapter->gotc_old = adapter->stats.gotc;
-
-	igb_update_adaptive(&adapter->hw);
+	igb_update_adaptive(hw);
 
 	if (!netif_carrier_ok(netdev)) {
 		if (igb_desc_unused(tx_ring) + 1 < tx_ring->count) {
@@ -3875,7 +3860,6 @@ void igb_update_stats(struct igb_adapter *adapter)
 	adapter->stats.bptc += rd32(E1000_BPTC);
 
 	/* used for adaptive IFS */
-
 	hw->mac.tx_packet_delta = rd32(E1000_TPT);
 	adapter->stats.tpt += hw->mac.tx_packet_delta;
 	hw->mac.collision_delta = rd32(E1000_COLC);

