From: Mika Westerberg <mika.westerberg@linux.intel.com>
Subject: [PATCH v2 15/16] thunderbolt: Allocate ring HopID automatically if requested
Date: Mon, 25 Sep 2017 14:07:37 +0300
Message-ID: <20170925110738.68382-16-mika.westerberg@linux.intel.com>
References: <20170925110738.68382-1-mika.westerberg@linux.intel.com>
Cc: Andreas Noever <andreas.noever@gmail.com>,
        Michael Jamet <michael.jamet@intel.com>,
        Yehezkel Bernat <yehezkel.bernat@intel.com>,
        Amir Levy <amir.jer.levy@intel.com>,
        Mario.Limonciello@dell.com, Lukas Wunner <lukas@wunner.de>,
        Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Mika Westerberg <mika.westerberg@linux.intel.com>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170925110738.68382-1-mika.westerberg@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thunderbolt services should not care which HopID (ring) they use for
sending and receiving packets over the high-speed DMA path, so make
tb_ring_alloc_rx() and tb_ring_alloc_tx() accept negative HopID. This
means that the NHI will allocate next available HopID for the caller
automatically.

These HopIDs will be allocated from the range which is not reserved for
the Thunderbolt protocol (8 .. hop_count - 1).

The allocated HopID can be retrieved from ring->hop field after the ring
has been allocated successfully if needed.

Signed-off-by: Mika Westerberg <mika.westerberg@linux.intel.com>
Reviewed-by: Michael Jamet <michael.jamet@intel.com>
Reviewed-by: Yehezkel Bernat <yehezkel.bernat@intel.com>
---
 drivers/thunderbolt/nhi.c | 78 ++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 60 insertions(+), 18 deletions(-)

diff --git a/drivers/thunderbolt/nhi.c b/drivers/thunderbolt/nhi.c
index 5bc3f77cc1f3..b9e3980aa4fc 100644
--- a/drivers/thunderbolt/nhi.c
+++ b/drivers/thunderbolt/nhi.c
@@ -26,6 +26,8 @@
  * use this ring for anything else.
  */
 #define RING_E2E_UNUSED_HOPID	2
+/* HopIDs 0-7 are reserved by the Thunderbolt protocol */
+#define RING_FIRST_USABLE_HOPID	8
 
 /*
  * Minimal number of vectors when we use MSI-X. Two for control channel
@@ -411,6 +413,62 @@ static void ring_release_msix(struct tb_ring *ring)
 	ring->irq = 0;
 }
 
+static int nhi_alloc_hop(struct tb_nhi *nhi, struct tb_ring *ring)
+{
+	int ret = 0;
+
+	spin_lock_irq(&nhi->lock);
+
+	if (ring->hop < 0) {
+		unsigned int i;
+
+		/*
+		 * Automatically allocate HopID from the non-reserved
+		 * range 8 .. hop_count - 1.
+		 */
+		for (i = RING_FIRST_USABLE_HOPID; i < nhi->hop_count; i++) {
+			if (ring->is_tx) {
+				if (!nhi->tx_rings[i]) {
+					ring->hop = i;
+					break;
+				}
+			} else {
+				if (!nhi->rx_rings[i]) {
+					ring->hop = i;
+					break;
+				}
+			}
+		}
+	}
+
+	if (ring->hop < 0 || ring->hop >= nhi->hop_count) {
+		dev_warn(&nhi->pdev->dev, "invalid hop: %d\n", ring->hop);
+		ret = -EINVAL;
+		goto err_unlock;
+	}
+	if (ring->is_tx && nhi->tx_rings[ring->hop]) {
+		dev_warn(&nhi->pdev->dev, "TX hop %d already allocated\n",
+			 ring->hop);
+		ret = -EBUSY;
+		goto err_unlock;
+	} else if (!ring->is_tx && nhi->rx_rings[ring->hop]) {
+		dev_warn(&nhi->pdev->dev, "RX hop %d already allocated\n",
+			 ring->hop);
+		ret = -EBUSY;
+		goto err_unlock;
+	}
+
+	if (ring->is_tx)
+		nhi->tx_rings[ring->hop] = ring;
+	else
+		nhi->rx_rings[ring->hop] = ring;
+
+err_unlock:
+	spin_unlock_irq(&nhi->lock);
+
+	return ret;
+}
+
 static struct tb_ring *tb_ring_alloc(struct tb_nhi *nhi, u32 hop, int size,
 				     bool transmit, unsigned int flags,
 				     u16 sof_mask, u16 eof_mask,
@@ -456,28 +514,12 @@ static struct tb_ring *tb_ring_alloc(struct tb_nhi *nhi, u32 hop, int size,
 	if (ring_request_msix(ring, flags & RING_FLAG_NO_SUSPEND))
 		goto err_free_descs;
 
-	spin_lock_irq(&nhi->lock);
-	if (hop >= nhi->hop_count) {
-		dev_WARN(&nhi->pdev->dev, "invalid hop: %d\n", hop);
+	if (nhi_alloc_hop(nhi, ring))
 		goto err_release_msix;
-	}
-	if (transmit && nhi->tx_rings[hop]) {
-		dev_WARN(&nhi->pdev->dev, "TX hop %d already allocated\n", hop);
-		goto err_release_msix;
-	} else if (!transmit && nhi->rx_rings[hop]) {
-		dev_WARN(&nhi->pdev->dev, "RX hop %d already allocated\n", hop);
-		goto err_release_msix;
-	}
-	if (transmit)
-		nhi->tx_rings[hop] = ring;
-	else
-		nhi->rx_rings[hop] = ring;
-	spin_unlock_irq(&nhi->lock);
 
 	return ring;
 
 err_release_msix:
-	spin_unlock_irq(&nhi->lock);
 	ring_release_msix(ring);
 err_free_descs:
 	dma_free_coherent(&ring->nhi->pdev->dev,
@@ -506,7 +548,7 @@ EXPORT_SYMBOL_GPL(tb_ring_alloc_tx);
 /**
  * tb_ring_alloc_rx() - Allocate DMA ring for receive
  * @nhi: Pointer to the NHI the ring is to be allocated
- * @hop: HopID (ring) to allocate
+ * @hop: HopID (ring) to allocate. Pass %-1 for automatic allocation.
  * @size: Number of entries in the ring
  * @flags: Flags for the ring
  * @sof_mask: Mask of PDF values that start a frame
-- 
2.14.1
