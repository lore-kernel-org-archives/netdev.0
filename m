From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 5/5] ixgbe: use EIAM to automask MSI-X
Date: Thu, 03 Dec 2009 13:33:54 -0800
Message-ID: <20091203213353.9291.64013.stgit@localhost.localdomain>
References: <20091203213221.9291.34218.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:47580
	"EHLO QMTA04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755158AbZLCVeI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 16:34:08 -0500
In-Reply-To: <20091203213221.9291.34218.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

when disabling interrupts, driver was writing with IO, this is no
necessary because on ixgbe parts the hardware can "oneshot"
disable and clear the interrupt.  So on 82598/82599 use of EIAM
should avoid one posted write per interrupt when in MSI-X mode.
This should improve performance and seems to in my limited
testing, reduce CPU utilization VERY slightly.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   25 +++++++++++++++++++------
 1 files changed, 19 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index db05030..247ed2a 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1329,8 +1329,7 @@ static irqreturn_t ixgbe_msix_clean_tx(int irq, void *data)
 		                      r_idx + 1);
 	}
 
-	/* disable interrupts on this vector only */
-	ixgbe_irq_disable_queues(adapter, ((u64)1 << q_vector->v_idx));
+	/* EIAM disabled interrupts (on this vector) for us */
 	napi_schedule(&q_vector->napi);
 
 	return IRQ_HANDLED;
@@ -1362,7 +1361,7 @@ static irqreturn_t ixgbe_msix_clean_rx(int irq, void *data)
 		return IRQ_HANDLED;
 
 	/* disable interrupts on this vector only */
-	ixgbe_irq_disable_queues(adapter, ((u64)1 << q_vector->v_idx));
+	/* EIAM disabled interrupts (on this vector) for us */
 	napi_schedule(&q_vector->napi);
 
 	return IRQ_HANDLED;
@@ -1397,8 +1396,7 @@ static irqreturn_t ixgbe_msix_clean_many(int irq, void *data)
 		                      r_idx + 1);
 	}
 
-	/* disable interrupts on this vector only */
-	ixgbe_irq_disable_queues(adapter, ((u64)1 << q_vector->v_idx));
+	/* EIAM disabled interrupts (on this vector) for us */
 	napi_schedule(&q_vector->napi);
 
 	return IRQ_HANDLED;
@@ -2716,7 +2714,22 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 		IXGBE_WRITE_REG(hw, IXGBE_GPIE, gpie);
 	}
 
-	if (!(adapter->flags & IXGBE_FLAG_MSIX_ENABLED)) {
+	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
+		/*
+		 * use EIAM to auto-mask when MSI-X interrupt is asserted
+		 * this saves a register write for every interrupt
+		 */
+		switch (hw->mac.type) {
+		case ixgbe_mac_82598EB:
+			IXGBE_WRITE_REG(hw, IXGBE_EIAM, IXGBE_EICS_RTX_QUEUE);
+			break;
+		default:
+		case ixgbe_mac_82599EB:
+			IXGBE_WRITE_REG(hw, IXGBE_EIAM_EX(0), 0xFFFFFFFF);
+			IXGBE_WRITE_REG(hw, IXGBE_EIAM_EX(1), 0xFFFFFFFF);
+			break;
+		}
+	} else {
 		/* legacy interrupts, use EIAM to auto-mask when reading EICR,
 		 * specifically only auto mask tx and rx interrupts */
 		IXGBE_WRITE_REG(hw, IXGBE_EIAM, IXGBE_EICS_RTX_QUEUE);

