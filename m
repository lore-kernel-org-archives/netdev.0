From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 1/5] igb: force all queues to interrupt once every 2 seconds
Date: Tue, 26 Aug 2008 04:25:03 -0700
Message-ID: <20080826112503.15627.3855.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.232]:37230 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752642AbYHZLZD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 07:25:03 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2099147rvb.1
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2008 04:25:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Set the EICS bit for each of the RX queues at least once every 2 seconds to
prevent the rx queues from stalling.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 drivers/net/igb/igb_main.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 4b19abb..40a205e 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -2279,7 +2279,9 @@ static void igb_watchdog_task(struct work_struct *work)
 	struct igb_ring *tx_ring = adapter->tx_ring;
 	struct e1000_mac_info *mac = &adapter->hw.mac;
 	u32 link;
+	u32 eics = 0;
 	s32 ret_val;
+	int i;
 
 	if ((netif_carrier_ok(netdev)) &&
 	    (rd32(E1000_STATUS) & E1000_STATUS_LU))
@@ -2381,7 +2383,13 @@ link_up:
 	}
 
 	/* Cause software interrupt to ensure rx ring is cleaned */
-	wr32(E1000_ICS, E1000_ICS_RXDMT0);
+	if (adapter->msix_entries) {
+		for (i = 0; i < adapter->num_rx_queues; i++)
+			eics |= adapter->rx_ring[i].eims_value;
+		wr32(E1000_EICS, eics);
+	} else {
+		wr32(E1000_ICS, E1000_ICS_RXDMT0);
+	}
 
 	/* Force detection of hung controller every watchdog period */
 	tx_ring->detect_tx_hung = true;

