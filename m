From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 08/10] e1000: implement more efficient tx queue locking
Date: Fri, 14 Apr 2006 11:37:05 -0700
Message-ID: <20060414183705.3461.52759.stgit@gitlost.site>
References: <20060414183423.3461.32772.stgit@gitlost.site>
Cc: "Ronciak, John" <john.ronciak@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kirsher, Jeff" <Jeffrey.t.kirsher@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:56836 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1751403AbWDNSd1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2006 14:33:27 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	"Miller, David" <davem@davemloft.net>
In-Reply-To: <20060414183423.3461.32772.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Implement more efficient locking (avoid the lock) when checking for
a stopped queue.  Also don't wake the queue unless the threshold is
reached to avoid queue on/off thrash.


Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
---

 drivers/net/e1000/e1000_main.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index f604a1d..3c37c40 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3400,13 +3400,15 @@ e1000_clean_tx_irq(struct e1000_adapter 
 
 	tx_ring->next_to_clean = i;
 
-	spin_lock(&tx_ring->tx_lock);
-
+#define TX_WAKE_THRESHOLD 32
 	if (unlikely(cleaned && netif_queue_stopped(netdev) &&
-		    netif_carrier_ok(netdev)))
-		netif_wake_queue(netdev);
-
-	spin_unlock(&tx_ring->tx_lock);
+	             netif_carrier_ok(netdev))) {
+		spin_lock(&tx_ring->tx_lock);
+		if (netif_queue_stopped(netdev) &&
+		    (E1000_DESC_UNUSED(tx_ring) >= TX_WAKE_THRESHOLD))
+			netif_wake_queue(netdev);
+		spin_unlock(&tx_ring->tx_lock);
+	}
 
 	if (adapter->detect_tx_hung) {
 		/* Detect a transmit hang in hardware, this serializes the



--
Auke Kok <auke-jan.h.kok@intel.com>
Intel Pro Ethernet Driver Group
LAN Access Division / Digital Enterprise Group 
