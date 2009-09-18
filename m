From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 3/3] ixgbe: move rx queue RSC configuration to a
	separate function
Date: Fri, 18 Sep 2009 12:46:27 -0700
Message-ID: <20090918194627.28898.75773.stgit@localhost.localdomain>
References: <20090918194533.28898.49436.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Shannon Nelson <shannon.nelson@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.westchester.pa.mail.comcast.net ([76.96.59.243]:36968
	"EHLO QMTA13.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751530AbZIRTqp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2009 15:46:45 -0400
In-Reply-To: <20090918194533.28898.49436.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nelson, Shannon <shannon.nelson@intel.com>

Shorten ixgbe_configure_rx() and lessen indent depth.

Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   78 ++++++++++++++++++++++++----------------
 1 files changed, 47 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 1aa9f6a..c407bd9 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1970,6 +1970,50 @@ static u32 ixgbe_setup_mrqc(struct ixgbe_adapter *adapter)
 }
 
 /**
+ * ixgbe_configure_rscctl - enable RSC for the indicated ring
+ * @adapter:    address of board private structure
+ * @index:      index of ring to set
+ * @rx_buf_len: rx buffer length
+ **/
+static void ixgbe_configure_rscctl(struct ixgbe_adapter *adapter, int index,
+                                   int rx_buf_len)
+{
+	struct ixgbe_ring *rx_ring;
+	struct ixgbe_hw *hw = &adapter->hw;
+	int j;
+	u32 rscctrl;
+
+	rx_ring = &adapter->rx_ring[index];
+	j = rx_ring->reg_idx;
+	rscctrl = IXGBE_READ_REG(hw, IXGBE_RSCCTL(j));
+	rscctrl |= IXGBE_RSCCTL_RSCEN;
+	/*
+	 * we must limit the number of descriptors so that the
+	 * total size of max desc * buf_len is not greater
+	 * than 65535
+	 */
+	if (rx_ring->flags & IXGBE_RING_RX_PS_ENABLED) {
+#if (MAX_SKB_FRAGS > 16)
+		rscctrl |= IXGBE_RSCCTL_MAXDESC_16;
+#elif (MAX_SKB_FRAGS > 8)
+		rscctrl |= IXGBE_RSCCTL_MAXDESC_8;
+#elif (MAX_SKB_FRAGS > 4)
+		rscctrl |= IXGBE_RSCCTL_MAXDESC_4;
+#else
+		rscctrl |= IXGBE_RSCCTL_MAXDESC_1;
+#endif
+	} else {
+		if (rx_buf_len < IXGBE_RXBUFFER_4096)
+			rscctrl |= IXGBE_RSCCTL_MAXDESC_16;
+		else if (rx_buf_len < IXGBE_RXBUFFER_8192)
+			rscctrl |= IXGBE_RSCCTL_MAXDESC_8;
+		else
+			rscctrl |= IXGBE_RSCCTL_MAXDESC_4;
+	}
+	IXGBE_WRITE_REG(hw, IXGBE_RSCCTL(j), rscctrl);
+}
+
+/**
  * ixgbe_configure_rx - Configure 8259x Receive Unit after Reset
  * @adapter: board private structure
  *
@@ -1990,7 +2034,6 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 	u32 fctrl, hlreg0;
 	u32 reta = 0, mrqc = 0;
 	u32 rdrxctl;
-	u32 rscctrl;
 	int rx_buf_len;
 
 	/* Decide whether to use packet split mode or not */
@@ -2148,36 +2191,9 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 
 	if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED) {
 		/* Enable 82599 HW-RSC */
-		for (i = 0; i < adapter->num_rx_queues; i++) {
-			rx_ring = &adapter->rx_ring[i];
-			j = rx_ring->reg_idx;
-			rscctrl = IXGBE_READ_REG(hw, IXGBE_RSCCTL(j));
-			rscctrl |= IXGBE_RSCCTL_RSCEN;
-			/*
-			 * we must limit the number of descriptors so that the
-			 * total size of max desc * buf_len is not greater
-			 * than 65535
-			 */
-			if (rx_ring->flags & IXGBE_RING_RX_PS_ENABLED) {
-#if (MAX_SKB_FRAGS > 16)
-				rscctrl |= IXGBE_RSCCTL_MAXDESC_16;
-#elif (MAX_SKB_FRAGS > 8)
-				rscctrl |= IXGBE_RSCCTL_MAXDESC_8;
-#elif (MAX_SKB_FRAGS > 4)
-				rscctrl |= IXGBE_RSCCTL_MAXDESC_4;
-#else
-				rscctrl |= IXGBE_RSCCTL_MAXDESC_1;
-#endif
-			} else {
-				if (rx_buf_len < IXGBE_RXBUFFER_4096)
-					rscctrl |= IXGBE_RSCCTL_MAXDESC_16;
-				else if (rx_buf_len < IXGBE_RXBUFFER_8192)
-					rscctrl |= IXGBE_RSCCTL_MAXDESC_8;
-				else
-					rscctrl |= IXGBE_RSCCTL_MAXDESC_4;
-			}
-			IXGBE_WRITE_REG(hw, IXGBE_RSCCTL(j), rscctrl);
-		}
+		for (i = 0; i < adapter->num_rx_queues; i++)
+			ixgbe_configure_rscctl(adapter, i, rx_buf_len);
+
 		/* Disable RSC for ACK packets */
 		IXGBE_WRITE_REG(hw, IXGBE_RSCDBU,
 		   (IXGBE_RSCDBU_RSCACKDIS | IXGBE_READ_REG(hw, IXGBE_RSCDBU)));

